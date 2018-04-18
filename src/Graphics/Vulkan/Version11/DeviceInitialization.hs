{-# language Strict #-}
{-# language CPP #-}
{-# language DataKinds #-}
{-# language TypeOperators #-}

module Graphics.Vulkan.Version11.DeviceInitialization
  ( vkEnumerateInstanceVersion
  ) where

import Data.Word
  ( Word32
  )
import Foreign.Ptr
  ( Ptr
  )
import Graphics.Vulkan.NamedType
  ( (:::)
  )


import Graphics.Vulkan.Version10.Core
  ( VkResult(..)
  )


-- | 
foreign import ccall "vkEnumerateInstanceVersion" vkEnumerateInstanceVersion :: ("pApiVersion" ::: Ptr Word32) -> IO VkResult