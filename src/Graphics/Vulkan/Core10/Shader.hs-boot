{-# language CPP #-}
module Graphics.Vulkan.Core10.Shader  (ShaderModuleCreateInfo) where

import Data.Kind (Type)
import {-# SOURCE #-} Graphics.Vulkan.CStruct.Extends (Chain)
import Graphics.Vulkan.CStruct (FromCStruct)
import {-# SOURCE #-} Graphics.Vulkan.CStruct.Extends (PeekChain)
import {-# SOURCE #-} Graphics.Vulkan.CStruct.Extends (PokeChain)
import Graphics.Vulkan.CStruct (ToCStruct)
type role ShaderModuleCreateInfo nominal
data ShaderModuleCreateInfo (es :: [Type])

instance PokeChain es => ToCStruct (ShaderModuleCreateInfo es)
instance Show (Chain es) => Show (ShaderModuleCreateInfo es)

instance PeekChain es => FromCStruct (ShaderModuleCreateInfo es)
