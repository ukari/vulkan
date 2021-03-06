{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverloadedLists #-}

module Vulkan.Utils.Reflect
  ( ShaderStage (..)
  , ShaderInfo (..)
  , reflection
  , reflection'
  , makeShaderInfo
  , makeDescriptorInfo
  , makeInputInfo
  ) where

import Vulkan.Zero (zero)
import Vulkan.CStruct.Extends (SomeStruct (..))
import Vulkan.NamedType ((:::))
import Vulkan.Core10.Shader (ShaderModuleCreateInfo (..), ShaderModule (..))
import Vulkan.Core10.Enums.Format (Format (..))
import Vulkan.Core10.Enums.DescriptorType (DescriptorType (..))
import Vulkan.Core10.Enums.VertexInputRate (VertexInputRate (..))
import Vulkan.Core10.DescriptorSet (DescriptorSetLayoutBinding (..), DescriptorSetLayoutCreateInfo (..))
import Vulkan.Core10.Pipeline (ShaderStageFlagBits (..), PipelineShaderStageCreateInfo (..), PipelineVertexInputStateCreateInfo (..),  VertexInputBindingDescription (..), VertexInputAttributeDescription (..))

import Foreign.Storable (Storable (sizeOf))
import GHC.Generics (Generic)
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString.Char8 as B
import Data.Aeson ((.=), (.:), (.:?), FromJSON (..), ToJSON (..), Value (String), decode, object, pairs, withObject, withText)
import Data.Aeson.Types (prependFailure, unexpected)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import System.FilePath ((</>))
import System.Process.Typed (proc, readProcess)
import System.IO.Temp (withSystemTempDirectory)
import Control.Monad.IO.Class (MonadIO, liftIO)

import Data.List (sortOn, groupBy)
import Data.Map (Map)
import qualified Data.Map as M
import Data.Function (on)
import Data.Maybe (fromMaybe, catMaybes)
import Data.Word (Word32)
import Control.Applicative (liftA2)
import Control.Monad (join)
import Control.Exception (Exception (..), throw)

data EntryPoint = EntryPoint
  { name :: Text
  , mode :: ShaderStage
  } deriving (Show, Generic, FromJSON, ToJSON)

data Input = Input
  { type' :: VertexAttributeType
  , name :: Text
  , location :: Int
  , array :: Maybe (Vector Int)
  } deriving (Show, Generic)

instance FromJSON Input where
  parseJSON = withObject "inputs" $ \v -> Input
    <$> v .: "type"
    <*> v .: "name"
    <*> v .: "location"
    <*> v .:? "array"

instance ToJSON Input where
  toJSON (Input type' name location array) = object
    [ "type" .= type'
    , "name" .= name
    , "location" .= location
    , "array" .= array
    ]
  toEncoding (Input type' name location array) = pairs
    (  "type" .= type'
    <> "name" .= name
    <> "location" .= location
    <> "array" .= array
    )

data Ubo = Ubo
  { name :: Text
  , set :: Int
  , binding :: Int
  , array :: Maybe (Vector Int)
  } deriving (Show, Generic, FromJSON, ToJSON)

data Texture = Texture
  { type' :: TextureDescriptorType
  , name :: Text
  , set :: Int
  , binding :: Int
  , array :: Maybe (Vector Int)
  } deriving (Show, Generic)

instance FromJSON Texture where
  parseJSON = withObject "textures" $ \v -> Texture
    <$> v .: "type"
    <*> v .: "name"
    <*> v .: "set"
    <*> v .: "binding"
    <*> v .:? "array"

instance ToJSON Texture where
  toJSON (Texture type' name set binding array) = object
    [ "type" .= type'
    , "name" .= name
    , "set" .= set
    , "binding" .= binding
    , "array" .= array
    ]
  toEncoding (Texture type' name set binding array) = pairs
    (  "type" .= type'
    <> "name" .= name
    <> "set" .= set
    <> "binding" .= binding
    <> "array" .= array
    )

data Reflection = Reflection
  { entryPoints :: Vector EntryPoint
  , inputs :: Maybe (Vector Input)
  , textures :: Maybe (Vector Texture)
  , ubos :: Maybe (Vector Ubo)
  } deriving (Show, Generic, FromJSON, ToJSON)

data ConvertException = ConvertException Text Text
  deriving (Show)

instance Exception ConvertException

class Convert a where
  eitherFrom :: Text -> Either ConvertException a
  from :: Text -> a
  from x = case eitherFrom x of
    Left ex -> throw ex
    Right res -> res
  to :: a -> Text

data ShaderStage
  = Vert
  | Frag
  | Comp
  | Tesc
  | Tese
  | Geom
  | Rgen
  | Rint
  | Rahit
  | Rchit
  | Rmiss
  | Rcall
  | Task
  | Mesh
  deriving (Eq, Show)

instance Convert ShaderStage where
  eitherFrom = \case
    "vert" -> Right Vert
    "frag" -> Right Frag
    "comp" -> Right Comp
    "tesc" -> Right Tesc
    "tese" -> Right Tese
    "geom" -> Right Geom
    "rgen" -> Right Rgen
    "rint" -> Right Rint
    "rahit" -> Right Rahit
    "rchit" -> Right Rchit
    "rmiss" -> Right Rmiss
    "rcall" -> Right Rcall
    "task" -> Right Task
    "mesh" -> Right Mesh
    unsupport -> Left $ ConvertException unsupport $ "ShaderStage not support '" <> unsupport <> "'"
  to = \case
    Vert -> "vert"
    Frag -> "frag"
    Comp -> "comp"
    Tesc -> "tesc"
    Tese -> "tese"
    Geom -> "geom"
    Rgen -> "rgen"
    Rint -> "rint"
    Rahit -> "rahit"
    Rchit -> "rchit"
    Rmiss -> "rmiss"
    Rcall -> "rcall"
    Task -> "task"
    Mesh -> "mesh"

instance FromJSON ShaderStage where
  parseJSON value@(String x) = case eitherFrom @ShaderStage x of
    Left (ConvertException _e err) -> prependFailure (T.unpack $ err <> ", ") . unexpected $ value
    Right _stage -> withText "mode" (pure . from) value
  parseJSON value = withText "mode" (pure . from) value

instance ToJSON ShaderStage where
  toJSON = String . to
  toEncoding = toEncoding . to

convertStage :: ShaderStage -> ShaderStageFlagBits
convertStage = \case
  Vert -> SHADER_STAGE_VERTEX_BIT
  Frag -> SHADER_STAGE_FRAGMENT_BIT
  Comp -> SHADER_STAGE_COMPUTE_BIT
  Tesc -> SHADER_STAGE_TESSELLATION_CONTROL_BIT
  Tese -> SHADER_STAGE_TESSELLATION_EVALUATION_BIT
  Geom -> SHADER_STAGE_GEOMETRY_BIT
  Rgen -> SHADER_STAGE_RAYGEN_BIT_KHR
  Rint -> SHADER_STAGE_INTERSECTION_BIT_KHR
  Rahit -> SHADER_STAGE_ANY_HIT_BIT_KHR
  Rchit -> SHADER_STAGE_CLOSEST_HIT_BIT_KHR
  Rmiss -> SHADER_STAGE_MISS_BIT_KHR
  Rcall -> SHADER_STAGE_CALLABLE_BIT_KHR
  Task -> SHADER_STAGE_TASK_BIT_NV
  Mesh -> SHADER_STAGE_MESH_BIT_NV

data Shader = Shader
  { stage :: ShaderStage
  , code :: B.ByteString
  } deriving (Show)

data ShaderInfo = ShaderInfo
  { shaderModuleCreateInfo:: ShaderModuleCreateInfo '[]
  , pipelineShaderStageCreateInfos :: ShaderModule -> Vector (SomeStruct PipelineShaderStageCreateInfo)
  }

makeShaderInfo :: (Shader, Reflection) -> ShaderInfo
makeShaderInfo (Shader {..}, Reflection {..}) = ShaderInfo {..}
  where
    shaderModuleCreateInfo = makeShaderModuleCreateInfo code
    pipelineShaderStageCreateInfos = (SomeStruct <$>) . makePipelineShaderStageCreateInfos stage entryPoints

makeDescriptorInfo :: Vector (Shader, Reflection) -> Vector (DescriptorSetLayoutCreateInfo '[])
makeDescriptorInfo = makeDescriptorSetLayoutCreateInfos . join . V.map (makeDescriptorSetLayoutBindings . (stage :: Shader -> ShaderStage) . fst <*> fromMaybe [] . ubos . snd <*> fromMaybe [] . textures . snd)

makeInputInfo :: Vector (Shader, Reflection) -> Maybe (SomeStruct PipelineVertexInputStateCreateInfo)
makeInputInfo = (SomeStruct <$>) . makePipelineVertexInputStateCreateInfo . join . V.fromList . catMaybes . (inputs . snd <$>) . filter ((== Vert) . (stage :: Shader -> ShaderStage) . fst) . V.toList

makeShaderModuleCreateInfo :: "code" ::: B.ByteString -> ShaderModuleCreateInfo '[]
makeShaderModuleCreateInfo code = zero { code = code }

makePipelineShaderStageCreateInfo :: ShaderStage -> ShaderModule -> EntryPoint -> PipelineShaderStageCreateInfo '[]
makePipelineShaderStageCreateInfo stage shaderModule EntryPoint {..} = zero
  { stage = convertStage stage
  , module' = shaderModule
  , name = B.pack . T.unpack $ name
  }

makePipelineShaderStageCreateInfos :: ShaderStage -> Vector EntryPoint -> ShaderModule -> Vector (PipelineShaderStageCreateInfo '[])
makePipelineShaderStageCreateInfos stage entryPoints shaderModule = V.map (makePipelineShaderStageCreateInfo stage shaderModule) entryPoints

-- https://github.com/KhronosGroup/GLSL/blob/master/extensions/khr/GL_KHR_vulkan_glsl.txt
-- https://vulkan.lunarg.com/doc/view/1.2.135.0/linux/tutorial/html/08-init_pipeline_layout.html
makeUboDescriptorSetLayoutBinding :: ShaderStage -> Ubo -> (Int, DescriptorSetLayoutBinding)
makeUboDescriptorSetLayoutBinding stage Ubo {..} = (set, zero
  { binding = fromIntegral binding
  , descriptorType = DESCRIPTOR_TYPE_UNIFORM_BUFFER
  , descriptorCount = maybe 1 (V.sum . (fromIntegral <$>)) array
  , stageFlags = convertStage stage
  })

data TextureDescriptorType
  = Sampler2D
  deriving (Show)

instance Convert TextureDescriptorType where
  eitherFrom = \case
    "sampler2D" -> Right Sampler2D
    unsupport -> Left $ ConvertException unsupport $ "TextureDescriptorType not support '" <> unsupport <> "'"
  to = \case
    Sampler2D -> "sampler2D"

instance FromJSON TextureDescriptorType where
  parseJSON value@(String x) = case eitherFrom @TextureDescriptorType x of
    Left (ConvertException _e err) -> prependFailure (T.unpack $ err <> ", ") . unexpected $ value
    Right _stage -> withText "type" (pure . from) value
  parseJSON value = withText "type" (pure . from) value

instance ToJSON TextureDescriptorType where
  toJSON = String . to
  toEncoding = toEncoding . to

convertTextureDescriptorType :: TextureDescriptorType -> DescriptorType
convertTextureDescriptorType = \case
  Sampler2D -> DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER

makeTextureDescriptorSetLayoutBinding :: ShaderStage -> Texture -> (Int, DescriptorSetLayoutBinding)
makeTextureDescriptorSetLayoutBinding stage Texture {..} = (set, zero
  { binding = fromIntegral binding
  , descriptorType = convertTextureDescriptorType type'
  , descriptorCount = maybe 1 (V.sum . (fromIntegral <$>)) array
  , stageFlags = convertStage stage
  })

makeDescriptorSetLayoutBindings :: ShaderStage -> Vector Ubo -> Vector Texture -> Vector (Int, DescriptorSetLayoutBinding)
makeDescriptorSetLayoutBindings stage ubos textures = uboBindings <> textureBindings
  where
    uboBindings = V.map (makeUboDescriptorSetLayoutBinding stage) ubos
    textureBindings = V.map (makeTextureDescriptorSetLayoutBinding stage) textures

makeDescriptorSetLayoutCreateInfos :: Vector (Int, DescriptorSetLayoutBinding) -> V.Vector (DescriptorSetLayoutCreateInfo '[])
makeDescriptorSetLayoutCreateInfos bindings = V.map makeDescriptorSetLayoutCreateInfo . V.fromList . M.elems . M.unionWith (V.++) sets $ setsMap
  where
    setSize = V.maximum . (fst <$>) $ bindings :: Int
    sets :: Map Int (Vector DescriptorSetLayoutBinding)
    sets = M.fromList . map (, []) $ [ 0 .. setSize ]
    setsMap :: Map Int (Vector DescriptorSetLayoutBinding)
    setsMap = M.fromList . map (liftA2 (,) (fst . head) (V.fromList . (snd <$>))) . groupBy ((==) `on` fst) . sortOn fst . V.toList $ bindings

makeDescriptorSetLayoutCreateInfo :: Vector DescriptorSetLayoutBinding -> DescriptorSetLayoutCreateInfo '[]
makeDescriptorSetLayoutCreateInfo bindings = zero { bindings = bindings }

data VertexAttributeType
  = Vec2
  | Vec3
  | Vec4
  deriving (Show)

instance Convert VertexAttributeType where
  eitherFrom = \case
    "vec2" -> Right Vec2
    "vec3" -> Right Vec3
    "vec4" -> Right Vec4
    unsupport -> Left $ ConvertException unsupport $ "VertexAttributeType not support '" <> unsupport <> "'"
  to = \case
    Vec2 -> "vec2"
    Vec3 -> "vec3"
    Vec4 -> "vec4"

instance FromJSON VertexAttributeType where
  parseJSON value@(String x) = case eitherFrom @VertexAttributeType x of
    Left (ConvertException _e err) -> prependFailure (T.unpack $ err <> ", ") . unexpected $ value
    Right _stage -> withText "type" (pure . from) value
  parseJSON value = withText "type" (pure . from) value

instance ToJSON VertexAttributeType where
  toJSON = String . to
  toEncoding = toEncoding . to

convertVertexAttributeType :: VertexAttributeType -> (Word32, Format)
convertVertexAttributeType = \case
  Vec2 -> (fromIntegral $ 2 * sizeOf (undefined :: Word32), FORMAT_R32G32_SFLOAT)
  Vec3 -> (fromIntegral $ 3 * sizeOf (undefined :: Word32), FORMAT_R32G32B32_SFLOAT)
  Vec4 -> (fromIntegral $ 4 * sizeOf (undefined :: Word32), FORMAT_R32G32B32A32_SFLOAT)

data VertexAttribute = VertexAttribute
  { binding :: Word32
  , location :: Word32
  , size :: Word32
  , format :: Format
  } deriving (Show)

-- only support single binding for input vertex
-- [SaschaWillems - Multiple Vulkan buffer binding points](https://gist.github.com/SaschaWillems/428d15ed4b5d71ead462bc63adffa93a)
-- maybe can provide a binding map parameter to specify individual binding by name, like `foo [(1, ["inPos", "inColor"]) (2, ["texCoord"])]` speficies that `(binding = 1) inPos, (binding = 1) inColor, (binding = 2) texCoord`
-- [island pipeline](https://github.com/tgfrerer/island/blob/76d0d38cba74181fa3774cef38aba4d96b6861dc/modules/le_backend_vk/le_pipeline.cpp#L21)
makePipelineVertexInputStateCreateInfo :: Vector Input -> Maybe (PipelineVertexInputStateCreateInfo '[])
makePipelineVertexInputStateCreateInfo [] = Nothing
makePipelineVertexInputStateCreateInfo inputs = Just zero
  { vertexBindingDescriptions
  , vertexAttributeDescriptions
  }
  where
    vertexAttributes = join . V.map makeVertexAttribute $ inputs :: Vector VertexAttribute
    vertexAttributeDescriptions = makeVertexInputAttributeDescriptions vertexAttributes :: Vector VertexInputAttributeDescription
    vertexBindingDescriptions = makeVertexInputBindingDescriptions vertexAttributes :: Vector VertexInputBindingDescription

makeVertexInputBindingDescriptions :: Vector VertexAttribute -> Vector VertexInputBindingDescription
makeVertexInputBindingDescriptions = V.fromList . map makeVertexInputBindingDescription . calculate . groupBy ((==) `on` fst) . sortOn fst . extract
  where
    extract :: Vector VertexAttribute -> [ ("binding" ::: Int, "size" ::: Int) ]
    extract = map ((,) . fromIntegral . (binding :: VertexAttribute -> Word32) <*> fromIntegral . size) . V.toList
    calculate :: [ [ ("binding" ::: Int, "size" ::: Int) ] ] -> [ ("binding" ::: Int, "stride" ::: Int) ]
    calculate = map (liftA2 (,) (fst . head) (sum . (snd <$>)))

makeVertexInputBindingDescription :: ("binding" ::: Int, "stride" ::: Int) -> VertexInputBindingDescription
makeVertexInputBindingDescription (binding, stride) = zero
  { binding = fromIntegral binding
  , stride = fromIntegral stride
  , inputRate = VERTEX_INPUT_RATE_VERTEX
  }

makeVertexAttribute :: Input -> Vector VertexAttribute
makeVertexAttribute Input {..} = V.map (\i -> VertexAttribute
  { binding = 0
  , location = fromIntegral . (+ location) $ i
  , size
  , format
  })
  [ 0 .. count - 1
  ]
  where
    count = maybe 1 V.sum array :: Int
    (size, format) = convertVertexAttributeType type'

makeVertexInputAttributeDescriptions :: Vector VertexAttribute -> Vector VertexInputAttributeDescription
makeVertexInputAttributeDescriptions = V.fromList . join . map process . groupBy ((==) `on` (binding :: VertexAttribute -> Word32)) . V.toList
  where
    process :: [ VertexAttribute ] -> [ VertexInputAttributeDescription ]
    process = snd . foldl (\(nextOffset, acc) cur -> liftA2 (,) fst ((acc ++) . pure . snd) (makeVertexInputAttributeDescription nextOffset cur)) (0, [])

makeVertexInputAttributeDescription :: Word32 -> VertexAttribute -> (Word32, VertexInputAttributeDescription)
makeVertexInputAttributeDescription offset VertexAttribute {..} = (offset + size, zero
  { binding
  , location
  , offset
  , format
  })

reflect :: MonadIO m => ShaderStage -> "code" ::: Text -> m (B.ByteString, BL.ByteString)
reflect shaderStage code = liftIO . withSystemTempDirectory "th-spirv" $ \dir -> do
  let stage = T.unpack . to $ shaderStage
  let shader = dir </> "glsl." <> stage
  let spv = dir </> stage <> ".spv"
  T.writeFile shader code
  (_exitCode, _spv, _err) <- readProcess . proc "glslangValidator" $ [ "-S", stage, "-V", shader, "-o", spv]
  spirv <- B.readFile spv
  (_exitCode, reflectionRaw, _err) <- readProcess . proc "spirv-cross" $ [spv, "--vulkan-semantics", "--reflect"]
  pure (spirv, reflectionRaw)

reflect' :: MonadIO m => "spirv" ::: B.ByteString -> m BL.ByteString
reflect' spirv = liftIO . withSystemTempDirectory "th-spirv" $ \dir -> do
  let spv = dir </> "glsl.spv"
  B.writeFile spv spirv
  (_exitCode, reflectionRaw, _err) <- readProcess . proc "spirv-cross" $ [spv, "--vulkan-semantics", "--reflect"]
  pure reflectionRaw

reflection :: MonadIO m => ShaderStage -> "code" ::: Text -> m (Shader, Reflection)
reflection stage code = do
  (spirv, reflectionRaw) <- reflect stage code
  case decode reflectionRaw of
    Just reflection -> pure (Shader {stage, code = spirv}, reflection)
    Nothing -> error "fail to reflect"

reflection' :: MonadIO m => "spirv" ::: B.ByteString -> m (Shader, Reflection)
reflection' spirv = do
  reflectionRaw <- reflect' spirv
  case decode reflectionRaw of
    Just reflection -> pure (Shader {stage = getShaderStage reflection, code = spirv}, reflection)
    Nothing -> error "fail to reflect"

getShaderStage :: Reflection -> ShaderStage
getShaderStage Reflection {..} = mode . V.head $ entryPoints
