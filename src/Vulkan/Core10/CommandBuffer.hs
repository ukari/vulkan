{-# language CPP #-}
module Vulkan.Core10.CommandBuffer  ( allocateCommandBuffers
                                    , withCommandBuffers
                                    , freeCommandBuffers
                                    , beginCommandBuffer
                                    , useCommandBuffer
                                    , endCommandBuffer
                                    , resetCommandBuffer
                                    , CommandBufferAllocateInfo(..)
                                    , CommandBufferInheritanceInfo(..)
                                    , CommandBufferBeginInfo(..)
                                    , CommandBuffer(..)
                                    , CommandBufferLevel(..)
                                    , QueryControlFlagBits(..)
                                    , QueryControlFlags
                                    , CommandBufferUsageFlagBits(..)
                                    , CommandBufferUsageFlags
                                    , CommandBufferResetFlagBits(..)
                                    , CommandBufferResetFlags
                                    ) where

import Control.Exception.Base (bracket)
import Control.Monad (unless)
import Control.Monad.IO.Class (liftIO)
import Data.Typeable (eqT)
import Foreign.Marshal.Alloc (allocaBytesAligned)
import Foreign.Marshal.Alloc (callocBytes)
import Foreign.Marshal.Alloc (free)
import Foreign.Marshal.Utils (maybePeek)
import GHC.Base (when)
import GHC.IO (throwIO)
import GHC.Ptr (castPtr)
import GHC.Ptr (nullFunPtr)
import Foreign.Ptr (nullPtr)
import Foreign.Ptr (plusPtr)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Cont (evalContT)
import Data.Vector (generateM)
import qualified Data.Vector (imapM_)
import qualified Data.Vector (length)
import Control.Monad.IO.Class (MonadIO)
import Data.Type.Equality ((:~:)(Refl))
import Data.Typeable (Typeable)
import Foreign.Storable (Storable)
import Foreign.Storable (Storable(peek))
import Foreign.Storable (Storable(poke))
import qualified Foreign.Storable (Storable(..))
import GHC.Generics (Generic)
import GHC.IO.Exception (IOErrorType(..))
import GHC.IO.Exception (IOException(..))
import Foreign.Ptr (FunPtr)
import Foreign.Ptr (Ptr)
import Data.Word (Word32)
import Data.Kind (Type)
import Control.Monad.Trans.Cont (ContT(..))
import Data.Vector (Vector)
import Vulkan.CStruct.Utils (advancePtrBytes)
import Vulkan.Core10.FundamentalTypes (bool32ToBool)
import Vulkan.Core10.FundamentalTypes (boolToBool32)
import Vulkan.CStruct.Extends (forgetExtensions)
import Vulkan.CStruct.Extends (peekSomeCStruct)
import Vulkan.CStruct.Extends (withSomeCStruct)
import Vulkan.NamedType ((:::))
import Vulkan.Core10.FundamentalTypes (Bool32)
import Vulkan.CStruct.Extends (Chain)
import Vulkan.Core10.Handles (CommandBuffer)
import Vulkan.Core10.Handles (CommandBuffer(..))
import Vulkan.Core10.Handles (CommandBuffer(CommandBuffer))
import {-# SOURCE #-} Vulkan.Extensions.VK_EXT_conditional_rendering (CommandBufferInheritanceConditionalRenderingInfoEXT)
import {-# SOURCE #-} Vulkan.Extensions.VK_QCOM_render_pass_transform (CommandBufferInheritanceRenderPassTransformInfoQCOM)
import Vulkan.Core10.Enums.CommandBufferLevel (CommandBufferLevel)
import Vulkan.Core10.Enums.CommandBufferResetFlagBits (CommandBufferResetFlagBits(..))
import Vulkan.Core10.Enums.CommandBufferResetFlagBits (CommandBufferResetFlags)
import Vulkan.Core10.Enums.CommandBufferUsageFlagBits (CommandBufferUsageFlags)
import Vulkan.Core10.Handles (CommandBuffer_T)
import Vulkan.Core10.Handles (CommandPool)
import Vulkan.Core10.Handles (CommandPool(..))
import Vulkan.Core10.Handles (Device)
import Vulkan.Core10.Handles (Device(..))
import Vulkan.Dynamic (DeviceCmds(pVkAllocateCommandBuffers))
import Vulkan.Dynamic (DeviceCmds(pVkBeginCommandBuffer))
import Vulkan.Dynamic (DeviceCmds(pVkEndCommandBuffer))
import Vulkan.Dynamic (DeviceCmds(pVkFreeCommandBuffers))
import Vulkan.Dynamic (DeviceCmds(pVkResetCommandBuffer))
import {-# SOURCE #-} Vulkan.Core11.Promoted_From_VK_KHR_device_group (DeviceGroupCommandBufferBeginInfo)
import Vulkan.Core10.Handles (Device_T)
import Vulkan.CStruct.Extends (Extends)
import Vulkan.CStruct.Extends (Extendss)
import Vulkan.CStruct.Extends (Extensible(..))
import Vulkan.Core10.Handles (Framebuffer)
import Vulkan.CStruct (FromCStruct)
import Vulkan.CStruct (FromCStruct(..))
import Vulkan.CStruct.Extends (PeekChain)
import Vulkan.CStruct.Extends (PeekChain(..))
import Vulkan.CStruct.Extends (PokeChain)
import Vulkan.CStruct.Extends (PokeChain(..))
import Vulkan.Core10.Enums.QueryControlFlagBits (QueryControlFlags)
import Vulkan.Core10.Enums.QueryPipelineStatisticFlagBits (QueryPipelineStatisticFlags)
import Vulkan.Core10.Handles (RenderPass)
import Vulkan.Core10.Enums.Result (Result)
import Vulkan.Core10.Enums.Result (Result(..))
import Vulkan.CStruct.Extends (SomeStruct)
import Vulkan.Core10.Enums.StructureType (StructureType)
import Vulkan.CStruct (ToCStruct)
import Vulkan.CStruct (ToCStruct(..))
import Vulkan.Exception (VulkanException(..))
import Vulkan.Zero (Zero(..))
import Vulkan.Core10.Enums.StructureType (StructureType(STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO))
import Vulkan.Core10.Enums.StructureType (StructureType(STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO))
import Vulkan.Core10.Enums.StructureType (StructureType(STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO))
import Vulkan.Core10.Enums.Result (Result(SUCCESS))
import Vulkan.Core10.Handles (CommandBuffer(..))
import Vulkan.Core10.Enums.CommandBufferLevel (CommandBufferLevel(..))
import Vulkan.Core10.Enums.CommandBufferResetFlagBits (CommandBufferResetFlagBits(..))
import Vulkan.Core10.Enums.CommandBufferResetFlagBits (CommandBufferResetFlags)
import Vulkan.Core10.Enums.CommandBufferUsageFlagBits (CommandBufferUsageFlagBits(..))
import Vulkan.Core10.Enums.CommandBufferUsageFlagBits (CommandBufferUsageFlags)
import Vulkan.Core10.Enums.QueryControlFlagBits (QueryControlFlagBits(..))
import Vulkan.Core10.Enums.QueryControlFlagBits (QueryControlFlags)
foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkAllocateCommandBuffers
  :: FunPtr (Ptr Device_T -> Ptr CommandBufferAllocateInfo -> Ptr (Ptr CommandBuffer_T) -> IO Result) -> Ptr Device_T -> Ptr CommandBufferAllocateInfo -> Ptr (Ptr CommandBuffer_T) -> IO Result

-- | vkAllocateCommandBuffers - Allocate command buffers from an existing
-- command pool
--
-- = Description
--
-- 'allocateCommandBuffers' /can/ be used to create multiple command
-- buffers. If the creation of any of those command buffers fails, the
-- implementation /must/ destroy all successfully created command buffer
-- objects from this command, set all entries of the @pCommandBuffers@
-- array to @NULL@ and return the error.
--
-- When command buffers are first allocated, they are in the
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle initial state>.
--
-- == Valid Usage (Implicit)
--
-- -   @device@ /must/ be a valid 'Vulkan.Core10.Handles.Device' handle
--
-- -   @pAllocateInfo@ /must/ be a valid pointer to a valid
--     'CommandBufferAllocateInfo' structure
--
-- -   @pCommandBuffers@ /must/ be a valid pointer to an array of
--     @pAllocateInfo->commandBufferCount@
--     'Vulkan.Core10.Handles.CommandBuffer' handles
--
-- -   @pAllocateInfo->commandBufferCount@ /must/ be greater than @0@
--
-- == Host Synchronization
--
-- -   Host access to @pAllocateInfo->commandPool@ /must/ be externally
--     synchronized
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_HOST_MEMORY'
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_DEVICE_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Core10.Handles.CommandBuffer', 'CommandBufferAllocateInfo',
-- 'Vulkan.Core10.Handles.Device'
allocateCommandBuffers :: forall io
                        . (MonadIO io)
                       => -- | @device@ is the logical device that owns the command pool.
                          Device
                       -> -- | @pAllocateInfo@ is a pointer to a 'CommandBufferAllocateInfo' structure
                          -- describing parameters of the allocation.
                          CommandBufferAllocateInfo
                       -> io (("commandBuffers" ::: Vector CommandBuffer))
allocateCommandBuffers device allocateInfo = liftIO . evalContT $ do
  let cmds = deviceCmds (device :: Device)
  let vkAllocateCommandBuffersPtr = pVkAllocateCommandBuffers cmds
  lift $ unless (vkAllocateCommandBuffersPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkAllocateCommandBuffers is null" Nothing Nothing
  let vkAllocateCommandBuffers' = mkVkAllocateCommandBuffers vkAllocateCommandBuffersPtr
  pAllocateInfo <- ContT $ withCStruct (allocateInfo)
  pPCommandBuffers <- ContT $ bracket (callocBytes @(Ptr CommandBuffer_T) ((fromIntegral $ commandBufferCount ((allocateInfo) :: CommandBufferAllocateInfo)) * 8)) free
  r <- lift $ vkAllocateCommandBuffers' (deviceHandle (device)) pAllocateInfo (pPCommandBuffers)
  lift $ when (r < SUCCESS) (throwIO (VulkanException r))
  pCommandBuffers <- lift $ generateM (fromIntegral $ commandBufferCount ((allocateInfo) :: CommandBufferAllocateInfo)) (\i -> do
    pCommandBuffersElem <- peek @(Ptr CommandBuffer_T) ((pPCommandBuffers `advancePtrBytes` (8 * (i)) :: Ptr (Ptr CommandBuffer_T)))
    pure $ (\h -> CommandBuffer h cmds ) pCommandBuffersElem)
  pure $ (pCommandBuffers)

-- | A convenience wrapper to make a compatible pair of calls to
-- 'allocateCommandBuffers' and 'freeCommandBuffers'
--
-- To ensure that 'freeCommandBuffers' is always called: pass
-- 'Control.Exception.bracket' (or the allocate function from your
-- favourite resource management library) as the first argument.
-- To just extract the pair pass '(,)' as the first argument.
--
withCommandBuffers :: forall io r . MonadIO io => Device -> CommandBufferAllocateInfo -> (io (Vector CommandBuffer) -> ((Vector CommandBuffer) -> io ()) -> r) -> r
withCommandBuffers device pAllocateInfo b =
  b (allocateCommandBuffers device pAllocateInfo)
    (\(o0) -> freeCommandBuffers device (commandPool (pAllocateInfo :: CommandBufferAllocateInfo)) o0)


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkFreeCommandBuffers
  :: FunPtr (Ptr Device_T -> CommandPool -> Word32 -> Ptr (Ptr CommandBuffer_T) -> IO ()) -> Ptr Device_T -> CommandPool -> Word32 -> Ptr (Ptr CommandBuffer_T) -> IO ()

-- | vkFreeCommandBuffers - Free command buffers
--
-- = Description
--
-- Any primary command buffer that is in the
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle recording or executable state>
-- and has any element of @pCommandBuffers@ recorded into it, becomes
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle invalid>.
--
-- == Valid Usage
--
-- -   All elements of @pCommandBuffers@ /must/ not be in the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle pending state>
--
-- -   @pCommandBuffers@ /must/ be a valid pointer to an array of
--     @commandBufferCount@ 'Vulkan.Core10.Handles.CommandBuffer' handles,
--     each element of which /must/ either be a valid handle or @NULL@
--
-- == Valid Usage (Implicit)
--
-- -   @device@ /must/ be a valid 'Vulkan.Core10.Handles.Device' handle
--
-- -   @commandPool@ /must/ be a valid 'Vulkan.Core10.Handles.CommandPool'
--     handle
--
-- -   @commandBufferCount@ /must/ be greater than @0@
--
-- -   @commandPool@ /must/ have been created, allocated, or retrieved from
--     @device@
--
-- -   Each element of @pCommandBuffers@ that is a valid handle /must/ have
--     been created, allocated, or retrieved from @commandPool@
--
-- == Host Synchronization
--
-- -   Host access to @commandPool@ /must/ be externally synchronized
--
-- -   Host access to each member of @pCommandBuffers@ /must/ be externally
--     synchronized
--
-- = See Also
--
-- 'Vulkan.Core10.Handles.CommandBuffer',
-- 'Vulkan.Core10.Handles.CommandPool', 'Vulkan.Core10.Handles.Device'
freeCommandBuffers :: forall io
                    . (MonadIO io)
                   => -- | @device@ is the logical device that owns the command pool.
                      Device
                   -> -- | @commandPool@ is the command pool from which the command buffers were
                      -- allocated.
                      CommandPool
                   -> -- | @pCommandBuffers@ is a pointer to an array of handles of command buffers
                      -- to free.
                      ("commandBuffers" ::: Vector CommandBuffer)
                   -> io ()
freeCommandBuffers device commandPool commandBuffers = liftIO . evalContT $ do
  let vkFreeCommandBuffersPtr = pVkFreeCommandBuffers (deviceCmds (device :: Device))
  lift $ unless (vkFreeCommandBuffersPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkFreeCommandBuffers is null" Nothing Nothing
  let vkFreeCommandBuffers' = mkVkFreeCommandBuffers vkFreeCommandBuffersPtr
  pPCommandBuffers <- ContT $ allocaBytesAligned @(Ptr CommandBuffer_T) ((Data.Vector.length (commandBuffers)) * 8) 8
  lift $ Data.Vector.imapM_ (\i e -> poke (pPCommandBuffers `plusPtr` (8 * (i)) :: Ptr (Ptr CommandBuffer_T)) (commandBufferHandle (e))) (commandBuffers)
  lift $ vkFreeCommandBuffers' (deviceHandle (device)) (commandPool) ((fromIntegral (Data.Vector.length $ (commandBuffers)) :: Word32)) (pPCommandBuffers)
  pure $ ()


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkBeginCommandBuffer
  :: FunPtr (Ptr CommandBuffer_T -> Ptr (SomeStruct CommandBufferBeginInfo) -> IO Result) -> Ptr CommandBuffer_T -> Ptr (SomeStruct CommandBufferBeginInfo) -> IO Result

-- | vkBeginCommandBuffer - Start recording a command buffer
--
-- == Valid Usage
--
-- -   @commandBuffer@ /must/ not be in the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle recording or pending state>
--
-- -   If @commandBuffer@ was allocated from a
--     'Vulkan.Core10.Handles.CommandPool' which did not have the
--     'Vulkan.Core10.Enums.CommandPoolCreateFlagBits.COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT'
--     flag set, @commandBuffer@ /must/ be in the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle initial state>
--
-- -   If @commandBuffer@ is a secondary command buffer, the
--     @pInheritanceInfo@ member of @pBeginInfo@ /must/ be a valid
--     'CommandBufferInheritanceInfo' structure
--
-- -   If @commandBuffer@ is a secondary command buffer and either the
--     @occlusionQueryEnable@ member of the @pInheritanceInfo@ member of
--     @pBeginInfo@ is 'Vulkan.Core10.FundamentalTypes.FALSE', or the
--     precise occlusion queries feature is not enabled, the @queryFlags@
--     member of the @pInheritanceInfo@ member @pBeginInfo@ /must/ not
--     contain
--     'Vulkan.Core10.Enums.QueryControlFlagBits.QUERY_CONTROL_PRECISE_BIT'
--
-- -   If @commandBuffer@ is a primary command buffer, then
--     @pBeginInfo->flags@ /must/ not set both the
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT'
--     and the
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT'
--     flags
--
-- == Valid Usage (Implicit)
--
-- -   @commandBuffer@ /must/ be a valid
--     'Vulkan.Core10.Handles.CommandBuffer' handle
--
-- -   @pBeginInfo@ /must/ be a valid pointer to a valid
--     'CommandBufferBeginInfo' structure
--
-- == Host Synchronization
--
-- -   Host access to @commandBuffer@ /must/ be externally synchronized
--
-- -   Host access to the 'Vulkan.Core10.Handles.CommandPool' that
--     @commandBuffer@ was allocated from /must/ be externally synchronized
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_HOST_MEMORY'
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_DEVICE_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Core10.Handles.CommandBuffer', 'CommandBufferBeginInfo'
beginCommandBuffer :: forall a io
                    . (Extendss CommandBufferBeginInfo a, PokeChain a, MonadIO io)
                   => -- | @commandBuffer@ is the handle of the command buffer which is to be put
                      -- in the recording state.
                      CommandBuffer
                   -> -- | @pBeginInfo@ points to a 'CommandBufferBeginInfo' structure defining
                      -- additional information about how the command buffer begins recording.
                      (CommandBufferBeginInfo a)
                   -> io ()
beginCommandBuffer commandBuffer beginInfo = liftIO . evalContT $ do
  let vkBeginCommandBufferPtr = pVkBeginCommandBuffer (deviceCmds (commandBuffer :: CommandBuffer))
  lift $ unless (vkBeginCommandBufferPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkBeginCommandBuffer is null" Nothing Nothing
  let vkBeginCommandBuffer' = mkVkBeginCommandBuffer vkBeginCommandBufferPtr
  pBeginInfo <- ContT $ withCStruct (beginInfo)
  r <- lift $ vkBeginCommandBuffer' (commandBufferHandle (commandBuffer)) (forgetExtensions pBeginInfo)
  lift $ when (r < SUCCESS) (throwIO (VulkanException r))

-- | This function will call the supplied action between calls to
-- 'beginCommandBuffer' and 'endCommandBuffer'
--
-- Note that 'endCommandBuffer' is *not* called if an exception is thrown
-- by the inner action.
useCommandBuffer :: forall a io r . (Extendss CommandBufferBeginInfo a, PokeChain a, MonadIO io) => CommandBuffer -> CommandBufferBeginInfo a -> io r -> io r
useCommandBuffer commandBuffer pBeginInfo a =
  (beginCommandBuffer commandBuffer pBeginInfo) *> a <* (endCommandBuffer commandBuffer)


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkEndCommandBuffer
  :: FunPtr (Ptr CommandBuffer_T -> IO Result) -> Ptr CommandBuffer_T -> IO Result

-- | vkEndCommandBuffer - Finish recording a command buffer
--
-- = Description
--
-- If there was an error during recording, the application will be notified
-- by an unsuccessful return code returned by 'endCommandBuffer'. If the
-- application wishes to further use the command buffer, the command buffer
-- /must/ be reset. The command buffer /must/ have been in the
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle recording state>,
-- and is moved to the
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle executable state>.
--
-- == Valid Usage
--
-- -   @commandBuffer@ /must/ be in the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle recording state>
--
-- -   If @commandBuffer@ is a primary command buffer, there /must/ not be
--     an active render pass instance
--
-- -   All queries made
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#queries-operation-active active>
--     during the recording of @commandBuffer@ /must/ have been made
--     inactive
--
-- -   Conditional rendering /must/ not be
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#active-conditional-rendering active>
--
-- -   If @commandBuffer@ is a secondary command buffer, there /must/ not
--     be an outstanding
--     'Vulkan.Extensions.VK_EXT_debug_utils.cmdBeginDebugUtilsLabelEXT'
--     command recorded to @commandBuffer@ that has not previously been
--     ended by a call to
--     'Vulkan.Extensions.VK_EXT_debug_utils.cmdEndDebugUtilsLabelEXT'
--
-- -   If @commandBuffer@ is a secondary command buffer, there /must/ not
--     be an outstanding
--     'Vulkan.Extensions.VK_EXT_debug_marker.cmdDebugMarkerBeginEXT'
--     command recorded to @commandBuffer@ that has not previously been
--     ended by a call to
--     'Vulkan.Extensions.VK_EXT_debug_marker.cmdDebugMarkerEndEXT'
--
-- == Valid Usage (Implicit)
--
-- -   @commandBuffer@ /must/ be a valid
--     'Vulkan.Core10.Handles.CommandBuffer' handle
--
-- == Host Synchronization
--
-- -   Host access to @commandBuffer@ /must/ be externally synchronized
--
-- -   Host access to the 'Vulkan.Core10.Handles.CommandPool' that
--     @commandBuffer@ was allocated from /must/ be externally synchronized
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_HOST_MEMORY'
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_DEVICE_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Core10.Handles.CommandBuffer'
endCommandBuffer :: forall io
                  . (MonadIO io)
                 => -- | @commandBuffer@ is the command buffer to complete recording.
                    CommandBuffer
                 -> io ()
endCommandBuffer commandBuffer = liftIO $ do
  let vkEndCommandBufferPtr = pVkEndCommandBuffer (deviceCmds (commandBuffer :: CommandBuffer))
  unless (vkEndCommandBufferPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkEndCommandBuffer is null" Nothing Nothing
  let vkEndCommandBuffer' = mkVkEndCommandBuffer vkEndCommandBufferPtr
  r <- vkEndCommandBuffer' (commandBufferHandle (commandBuffer))
  when (r < SUCCESS) (throwIO (VulkanException r))


foreign import ccall
#if !defined(SAFE_FOREIGN_CALLS)
  unsafe
#endif
  "dynamic" mkVkResetCommandBuffer
  :: FunPtr (Ptr CommandBuffer_T -> CommandBufferResetFlags -> IO Result) -> Ptr CommandBuffer_T -> CommandBufferResetFlags -> IO Result

-- | vkResetCommandBuffer - Reset a command buffer to the initial state
--
-- = Description
--
-- Any primary command buffer that is in the
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle recording or executable state>
-- and has @commandBuffer@ recorded into it, becomes
-- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle invalid>.
--
-- == Valid Usage
--
-- -   @commandBuffer@ /must/ not be in the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle pending state>
--
-- -   @commandBuffer@ /must/ have been allocated from a pool that was
--     created with the
--     'Vulkan.Core10.Enums.CommandPoolCreateFlagBits.COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT'
--
-- == Valid Usage (Implicit)
--
-- -   @commandBuffer@ /must/ be a valid
--     'Vulkan.Core10.Handles.CommandBuffer' handle
--
-- -   @flags@ /must/ be a valid combination of
--     'Vulkan.Core10.Enums.CommandBufferResetFlagBits.CommandBufferResetFlagBits'
--     values
--
-- == Host Synchronization
--
-- -   Host access to @commandBuffer@ /must/ be externally synchronized
--
-- == Return Codes
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-successcodes Success>]
--
--     -   'Vulkan.Core10.Enums.Result.SUCCESS'
--
-- [<https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#fundamentals-errorcodes Failure>]
--
--     -   'Vulkan.Core10.Enums.Result.ERROR_OUT_OF_DEVICE_MEMORY'
--
-- = See Also
--
-- 'Vulkan.Core10.Handles.CommandBuffer',
-- 'Vulkan.Core10.Enums.CommandBufferResetFlagBits.CommandBufferResetFlags'
resetCommandBuffer :: forall io
                    . (MonadIO io)
                   => -- | @commandBuffer@ is the command buffer to reset. The command buffer /can/
                      -- be in any state other than
                      -- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle pending>,
                      -- and is moved into the
                      -- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#commandbuffers-lifecycle initial state>.
                      CommandBuffer
                   -> -- | @flags@ is a bitmask of
                      -- 'Vulkan.Core10.Enums.CommandBufferResetFlagBits.CommandBufferResetFlagBits'
                      -- controlling the reset operation.
                      CommandBufferResetFlags
                   -> io ()
resetCommandBuffer commandBuffer flags = liftIO $ do
  let vkResetCommandBufferPtr = pVkResetCommandBuffer (deviceCmds (commandBuffer :: CommandBuffer))
  unless (vkResetCommandBufferPtr /= nullFunPtr) $
    throwIO $ IOError Nothing InvalidArgument "" "The function pointer for vkResetCommandBuffer is null" Nothing Nothing
  let vkResetCommandBuffer' = mkVkResetCommandBuffer vkResetCommandBufferPtr
  r <- vkResetCommandBuffer' (commandBufferHandle (commandBuffer)) (flags)
  when (r < SUCCESS) (throwIO (VulkanException r))


-- | VkCommandBufferAllocateInfo - Structure specifying the allocation
-- parameters for command buffer object
--
-- == Valid Usage (Implicit)
--
-- = See Also
--
-- 'Vulkan.Core10.Enums.CommandBufferLevel.CommandBufferLevel',
-- 'Vulkan.Core10.Handles.CommandPool',
-- 'Vulkan.Core10.Enums.StructureType.StructureType',
-- 'allocateCommandBuffers'
data CommandBufferAllocateInfo = CommandBufferAllocateInfo
  { -- | @commandPool@ is the command pool from which the command buffers are
    -- allocated.
    --
    -- @commandPool@ /must/ be a valid 'Vulkan.Core10.Handles.CommandPool'
    -- handle
    commandPool :: CommandPool
  , -- | @level@ is a 'Vulkan.Core10.Enums.CommandBufferLevel.CommandBufferLevel'
    -- value specifying the command buffer level.
    --
    -- @level@ /must/ be a valid
    -- 'Vulkan.Core10.Enums.CommandBufferLevel.CommandBufferLevel' value
    level :: CommandBufferLevel
  , -- | @commandBufferCount@ is the number of command buffers to allocate from
    -- the pool.
    --
    -- @commandBufferCount@ /must/ be greater than @0@
    commandBufferCount :: Word32
  }
  deriving (Typeable, Eq)
#if defined(GENERIC_INSTANCES)
deriving instance Generic (CommandBufferAllocateInfo)
#endif
deriving instance Show CommandBufferAllocateInfo

instance ToCStruct CommandBufferAllocateInfo where
  withCStruct x f = allocaBytesAligned 32 8 $ \p -> pokeCStruct p x (f p)
  pokeCStruct p CommandBufferAllocateInfo{..} f = do
    poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO)
    poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) (nullPtr)
    poke ((p `plusPtr` 16 :: Ptr CommandPool)) (commandPool)
    poke ((p `plusPtr` 24 :: Ptr CommandBufferLevel)) (level)
    poke ((p `plusPtr` 28 :: Ptr Word32)) (commandBufferCount)
    f
  cStructSize = 32
  cStructAlignment = 8
  pokeZeroCStruct p f = do
    poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO)
    poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) (nullPtr)
    poke ((p `plusPtr` 16 :: Ptr CommandPool)) (zero)
    poke ((p `plusPtr` 24 :: Ptr CommandBufferLevel)) (zero)
    poke ((p `plusPtr` 28 :: Ptr Word32)) (zero)
    f

instance FromCStruct CommandBufferAllocateInfo where
  peekCStruct p = do
    commandPool <- peek @CommandPool ((p `plusPtr` 16 :: Ptr CommandPool))
    level <- peek @CommandBufferLevel ((p `plusPtr` 24 :: Ptr CommandBufferLevel))
    commandBufferCount <- peek @Word32 ((p `plusPtr` 28 :: Ptr Word32))
    pure $ CommandBufferAllocateInfo
             commandPool level commandBufferCount

instance Storable CommandBufferAllocateInfo where
  sizeOf ~_ = 32
  alignment ~_ = 8
  peek = peekCStruct
  poke ptr poked = pokeCStruct ptr poked (pure ())

instance Zero CommandBufferAllocateInfo where
  zero = CommandBufferAllocateInfo
           zero
           zero
           zero


-- | VkCommandBufferInheritanceInfo - Structure specifying command buffer
-- inheritance info
--
-- == Valid Usage
--
-- -   If the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-inheritedQueries inherited queries>
--     feature is not enabled, @occlusionQueryEnable@ /must/ be
--     'Vulkan.Core10.FundamentalTypes.FALSE'
--
-- -   If the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-inheritedQueries inherited queries>
--     feature is enabled, @queryFlags@ /must/ be a valid combination of
--     'Vulkan.Core10.Enums.QueryControlFlagBits.QueryControlFlagBits'
--     values
--
-- -   If the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-inheritedQueries inherited queries>
--     feature is not enabled, @queryFlags@ /must/ be @0@
--
-- -   If the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-pipelineStatisticsQuery pipeline statistics queries>
--     feature is enabled, @pipelineStatistics@ /must/ be a valid
--     combination of
--     'Vulkan.Core10.Enums.QueryPipelineStatisticFlagBits.QueryPipelineStatisticFlagBits'
--     values
--
-- -   If the
--     <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-pipelineStatisticsQuery pipeline statistics queries>
--     feature is not enabled, @pipelineStatistics@ /must/ be @0@
--
-- == Valid Usage (Implicit)
--
-- -   @sType@ /must/ be
--     'Vulkan.Core10.Enums.StructureType.STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO'
--
-- -   Each @pNext@ member of any structure (including this one) in the
--     @pNext@ chain /must/ be either @NULL@ or a pointer to a valid
--     instance of
--     'Vulkan.Extensions.VK_EXT_conditional_rendering.CommandBufferInheritanceConditionalRenderingInfoEXT'
--     or
--     'Vulkan.Extensions.VK_QCOM_render_pass_transform.CommandBufferInheritanceRenderPassTransformInfoQCOM'
--
-- -   The @sType@ value of each struct in the @pNext@ chain /must/ be
--     unique
--
-- -   Both of @framebuffer@, and @renderPass@ that are valid handles of
--     non-ignored parameters /must/ have been created, allocated, or
--     retrieved from the same 'Vulkan.Core10.Handles.Device'
--
-- = See Also
--
-- 'Vulkan.Core10.FundamentalTypes.Bool32', 'CommandBufferBeginInfo',
-- 'Vulkan.Core10.Handles.Framebuffer',
-- 'Vulkan.Core10.Enums.QueryControlFlagBits.QueryControlFlags',
-- 'Vulkan.Core10.Enums.QueryPipelineStatisticFlagBits.QueryPipelineStatisticFlags',
-- 'Vulkan.Core10.Handles.RenderPass',
-- 'Vulkan.Core10.Enums.StructureType.StructureType'
data CommandBufferInheritanceInfo (es :: [Type]) = CommandBufferInheritanceInfo
  { -- | @pNext@ is @NULL@ or a pointer to a structure extending this structure.
    next :: Chain es
  , -- | @renderPass@ is a 'Vulkan.Core10.Handles.RenderPass' object defining
    -- which render passes the 'Vulkan.Core10.Handles.CommandBuffer' will be
    -- <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#renderpass-compatibility compatible>
    -- with and /can/ be executed within. If the
    -- 'Vulkan.Core10.Handles.CommandBuffer' will not be executed within a
    -- render pass instance, @renderPass@ is ignored.
    renderPass :: RenderPass
  , -- | @subpass@ is the index of the subpass within the render pass instance
    -- that the 'Vulkan.Core10.Handles.CommandBuffer' will be executed within.
    -- If the 'Vulkan.Core10.Handles.CommandBuffer' will not be executed within
    -- a render pass instance, @subpass@ is ignored.
    subpass :: Word32
  , -- | @framebuffer@ optionally refers to the
    -- 'Vulkan.Core10.Handles.Framebuffer' object that the
    -- 'Vulkan.Core10.Handles.CommandBuffer' will be rendering to if it is
    -- executed within a render pass instance. It /can/ be
    -- 'Vulkan.Core10.APIConstants.NULL_HANDLE' if the framebuffer is not
    -- known, or if the 'Vulkan.Core10.Handles.CommandBuffer' will not be
    -- executed within a render pass instance.
    --
    -- Note
    --
    -- Specifying the exact framebuffer that the secondary command buffer will
    -- be executed with /may/ result in better performance at command buffer
    -- execution time.
    framebuffer :: Framebuffer
  , -- | @occlusionQueryEnable@ specifies whether the command buffer /can/ be
    -- executed while an occlusion query is active in the primary command
    -- buffer. If this is 'Vulkan.Core10.FundamentalTypes.TRUE', then this
    -- command buffer /can/ be executed whether the primary command buffer has
    -- an occlusion query active or not. If this is
    -- 'Vulkan.Core10.FundamentalTypes.FALSE', then the primary command buffer
    -- /must/ not have an occlusion query active.
    occlusionQueryEnable :: Bool
  , -- | @queryFlags@ specifies the query flags that /can/ be used by an active
    -- occlusion query in the primary command buffer when this secondary
    -- command buffer is executed. If this value includes the
    -- 'Vulkan.Core10.Enums.QueryControlFlagBits.QUERY_CONTROL_PRECISE_BIT'
    -- bit, then the active query /can/ return boolean results or actual sample
    -- counts. If this bit is not set, then the active query /must/ not use the
    -- 'Vulkan.Core10.Enums.QueryControlFlagBits.QUERY_CONTROL_PRECISE_BIT'
    -- bit.
    queryFlags :: QueryControlFlags
  , -- | @pipelineStatistics@ is a bitmask of
    -- 'Vulkan.Core10.Enums.QueryPipelineStatisticFlagBits.QueryPipelineStatisticFlagBits'
    -- specifying the set of pipeline statistics that /can/ be counted by an
    -- active query in the primary command buffer when this secondary command
    -- buffer is executed. If this value includes a given bit, then this
    -- command buffer /can/ be executed whether the primary command buffer has
    -- a pipeline statistics query active that includes this bit or not. If
    -- this value excludes a given bit, then the active pipeline statistics
    -- query /must/ not be from a query pool that counts that statistic.
    pipelineStatistics :: QueryPipelineStatisticFlags
  }
  deriving (Typeable)
#if defined(GENERIC_INSTANCES)
deriving instance Generic (CommandBufferInheritanceInfo (es :: [Type]))
#endif
deriving instance Show (Chain es) => Show (CommandBufferInheritanceInfo es)

instance Extensible CommandBufferInheritanceInfo where
  extensibleType = STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO
  setNext x next = x{next = next}
  getNext CommandBufferInheritanceInfo{..} = next
  extends :: forall e b proxy. Typeable e => proxy e -> (Extends CommandBufferInheritanceInfo e => b) -> Maybe b
  extends _ f
    | Just Refl <- eqT @e @CommandBufferInheritanceRenderPassTransformInfoQCOM = Just f
    | Just Refl <- eqT @e @CommandBufferInheritanceConditionalRenderingInfoEXT = Just f
    | otherwise = Nothing

instance (Extendss CommandBufferInheritanceInfo es, PokeChain es) => ToCStruct (CommandBufferInheritanceInfo es) where
  withCStruct x f = allocaBytesAligned 56 8 $ \p -> pokeCStruct p x (f p)
  pokeCStruct p CommandBufferInheritanceInfo{..} f = evalContT $ do
    lift $ poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO)
    pNext'' <- fmap castPtr . ContT $ withChain (next)
    lift $ poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) pNext''
    lift $ poke ((p `plusPtr` 16 :: Ptr RenderPass)) (renderPass)
    lift $ poke ((p `plusPtr` 24 :: Ptr Word32)) (subpass)
    lift $ poke ((p `plusPtr` 32 :: Ptr Framebuffer)) (framebuffer)
    lift $ poke ((p `plusPtr` 40 :: Ptr Bool32)) (boolToBool32 (occlusionQueryEnable))
    lift $ poke ((p `plusPtr` 44 :: Ptr QueryControlFlags)) (queryFlags)
    lift $ poke ((p `plusPtr` 48 :: Ptr QueryPipelineStatisticFlags)) (pipelineStatistics)
    lift $ f
  cStructSize = 56
  cStructAlignment = 8
  pokeZeroCStruct p f = evalContT $ do
    lift $ poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO)
    pNext' <- fmap castPtr . ContT $ withZeroChain @es
    lift $ poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) pNext'
    lift $ poke ((p `plusPtr` 24 :: Ptr Word32)) (zero)
    lift $ poke ((p `plusPtr` 40 :: Ptr Bool32)) (boolToBool32 (zero))
    lift $ f

instance (Extendss CommandBufferInheritanceInfo es, PeekChain es) => FromCStruct (CommandBufferInheritanceInfo es) where
  peekCStruct p = do
    pNext <- peek @(Ptr ()) ((p `plusPtr` 8 :: Ptr (Ptr ())))
    next <- peekChain (castPtr pNext)
    renderPass <- peek @RenderPass ((p `plusPtr` 16 :: Ptr RenderPass))
    subpass <- peek @Word32 ((p `plusPtr` 24 :: Ptr Word32))
    framebuffer <- peek @Framebuffer ((p `plusPtr` 32 :: Ptr Framebuffer))
    occlusionQueryEnable <- peek @Bool32 ((p `plusPtr` 40 :: Ptr Bool32))
    queryFlags <- peek @QueryControlFlags ((p `plusPtr` 44 :: Ptr QueryControlFlags))
    pipelineStatistics <- peek @QueryPipelineStatisticFlags ((p `plusPtr` 48 :: Ptr QueryPipelineStatisticFlags))
    pure $ CommandBufferInheritanceInfo
             next renderPass subpass framebuffer (bool32ToBool occlusionQueryEnable) queryFlags pipelineStatistics

instance es ~ '[] => Zero (CommandBufferInheritanceInfo es) where
  zero = CommandBufferInheritanceInfo
           ()
           zero
           zero
           zero
           zero
           zero
           zero


-- | VkCommandBufferBeginInfo - Structure specifying a command buffer begin
-- operation
--
-- == Valid Usage
--
-- -   If @flags@ contains
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT',
--     the @renderPass@ member of @pInheritanceInfo@ /must/ be a valid
--     'Vulkan.Core10.Handles.RenderPass'
--
-- -   If @flags@ contains
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT',
--     the @subpass@ member of @pInheritanceInfo@ /must/ be a valid subpass
--     index within the @renderPass@ member of @pInheritanceInfo@
--
-- -   If @flags@ contains
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT',
--     the @framebuffer@ member of @pInheritanceInfo@ /must/ be either
--     'Vulkan.Core10.APIConstants.NULL_HANDLE', or a valid
--     'Vulkan.Core10.Handles.Framebuffer' that is compatible with the
--     @renderPass@ member of @pInheritanceInfo@
--
-- == Valid Usage (Implicit)
--
-- -   @sType@ /must/ be
--     'Vulkan.Core10.Enums.StructureType.STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO'
--
-- -   @pNext@ /must/ be @NULL@ or a pointer to a valid instance of
--     'Vulkan.Core11.Promoted_From_VK_KHR_device_group.DeviceGroupCommandBufferBeginInfo'
--
-- -   The @sType@ value of each struct in the @pNext@ chain /must/ be
--     unique
--
-- -   @flags@ /must/ be a valid combination of
--     'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.CommandBufferUsageFlagBits'
--     values
--
-- = See Also
--
-- 'CommandBufferInheritanceInfo',
-- 'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.CommandBufferUsageFlags',
-- 'Vulkan.Core10.Enums.StructureType.StructureType', 'beginCommandBuffer'
data CommandBufferBeginInfo (es :: [Type]) = CommandBufferBeginInfo
  { -- | @pNext@ is @NULL@ or a pointer to a structure extending this structure.
    next :: Chain es
  , -- | @flags@ is a bitmask of
    -- 'Vulkan.Core10.Enums.CommandBufferUsageFlagBits.CommandBufferUsageFlagBits'
    -- specifying usage behavior for the command buffer.
    flags :: CommandBufferUsageFlags
  , -- | @pInheritanceInfo@ is a pointer to a 'CommandBufferInheritanceInfo'
    -- structure, used if @commandBuffer@ is a secondary command buffer. If
    -- this is a primary command buffer, then this value is ignored.
    inheritanceInfo :: Maybe (SomeStruct CommandBufferInheritanceInfo)
  }
  deriving (Typeable)
#if defined(GENERIC_INSTANCES)
deriving instance Generic (CommandBufferBeginInfo (es :: [Type]))
#endif
deriving instance Show (Chain es) => Show (CommandBufferBeginInfo es)

instance Extensible CommandBufferBeginInfo where
  extensibleType = STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
  setNext x next = x{next = next}
  getNext CommandBufferBeginInfo{..} = next
  extends :: forall e b proxy. Typeable e => proxy e -> (Extends CommandBufferBeginInfo e => b) -> Maybe b
  extends _ f
    | Just Refl <- eqT @e @DeviceGroupCommandBufferBeginInfo = Just f
    | otherwise = Nothing

instance (Extendss CommandBufferBeginInfo es, PokeChain es) => ToCStruct (CommandBufferBeginInfo es) where
  withCStruct x f = allocaBytesAligned 32 8 $ \p -> pokeCStruct p x (f p)
  pokeCStruct p CommandBufferBeginInfo{..} f = evalContT $ do
    lift $ poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO)
    pNext'' <- fmap castPtr . ContT $ withChain (next)
    lift $ poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) pNext''
    lift $ poke ((p `plusPtr` 16 :: Ptr CommandBufferUsageFlags)) (flags)
    pInheritanceInfo'' <- case (inheritanceInfo) of
      Nothing -> pure nullPtr
      Just j -> ContT @_ @_ @(Ptr (CommandBufferInheritanceInfo '[])) $ \cont -> withSomeCStruct @CommandBufferInheritanceInfo (j) (cont . castPtr)
    lift $ poke ((p `plusPtr` 24 :: Ptr (Ptr (CommandBufferInheritanceInfo _)))) pInheritanceInfo''
    lift $ f
  cStructSize = 32
  cStructAlignment = 8
  pokeZeroCStruct p f = evalContT $ do
    lift $ poke ((p `plusPtr` 0 :: Ptr StructureType)) (STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO)
    pNext' <- fmap castPtr . ContT $ withZeroChain @es
    lift $ poke ((p `plusPtr` 8 :: Ptr (Ptr ()))) pNext'
    lift $ f

instance (Extendss CommandBufferBeginInfo es, PeekChain es) => FromCStruct (CommandBufferBeginInfo es) where
  peekCStruct p = do
    pNext <- peek @(Ptr ()) ((p `plusPtr` 8 :: Ptr (Ptr ())))
    next <- peekChain (castPtr pNext)
    flags <- peek @CommandBufferUsageFlags ((p `plusPtr` 16 :: Ptr CommandBufferUsageFlags))
    pInheritanceInfo <- peek @(Ptr (CommandBufferInheritanceInfo _)) ((p `plusPtr` 24 :: Ptr (Ptr (CommandBufferInheritanceInfo a))))
    pInheritanceInfo' <- maybePeek (\j -> peekSomeCStruct (forgetExtensions (j))) pInheritanceInfo
    pure $ CommandBufferBeginInfo
             next flags pInheritanceInfo'

instance es ~ '[] => Zero (CommandBufferBeginInfo es) where
  zero = CommandBufferBeginInfo
           ()
           zero
           Nothing

