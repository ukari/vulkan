{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE RecordWildCards   #-}

module Write.Bespoke
  ( bespokeWriteElements
  ) where

import           Data.Text                                (Text)
import           Prelude                                  hiding (Enum)
import           Text.InterpolatedString.Perl6.Unindented

import           Spec.Savvy.Enum
import           Write.Element
import           Write.Type.Enum

bespokeWriteElements :: [WriteElement]
bespokeWriteElements =
  [namedType, versions, nullHandle, bools] ++ concat [win32, x11, xcb, wayland, mir, android]

namedType :: WriteElement
namedType =
  let weDoc = [qci|
        -- | Annotate a type with a name
        type (name :: k) ::: a = a
      |]
      weImports = []
      weExtensions = ["PolyKinds", "TypeOperators"]
      weName = "NamedType"
      weProvides = [ TypeAlias "(:::)" ]
      weDepends = []
  in WriteElement{..}

versions :: WriteElement
versions =
  let weDoc = [qci|
        pattern VK_MAKE_VERSION :: Word32 -> Word32 -> Word32 -> Word32
        pattern VK_MAKE_VERSION major minor patch <-
          (\v -> (_VK_VERSION_MAJOR v, _VK_VERSION_MINOR v, _VK_VERSION_PATCH v) -> (major, minor, patch))
          where VK_MAKE_VERSION major minor patch = major `shiftL` 22 .|. minor `shiftL` 12 .|. patch

        pattern VK_API_VERSION_1_0 :: Word32
        pattern VK_API_VERSION_1_0 = VK_MAKE_VERSION 1 0 0

        pattern VK_API_VERSION_1_1 :: Word32
        pattern VK_API_VERSION_1_1 = VK_MAKE_VERSION 1 1 0

        _VK_VERSION_MAJOR :: Word32 -> Word32
        _VK_VERSION_MAJOR v = v `shiftR` 22

        _VK_VERSION_MINOR :: Word32 -> Word32
        _VK_VERSION_MINOR v = v `shiftR` 12 .&. 0x3ff

        _VK_VERSION_PATCH :: Word32 -> Word32
        _VK_VERSION_PATCH v = v .&. 0xfff
      |]
      weImports = [ Import "Data.Word" ["Word32"]
                  , Import "Data.Bits" ["(.&.)", "(.|.)", "shiftL", "shiftR"]
                  ]
      weExtensions = ["PatternSynonyms", "ViewPatterns"]
      weName = "Version Macros"
      weProvides = [ Pattern "VK_MAKE_VERSION"
                   , Pattern "VK_API_VERSION_1_0"
                   , Pattern "VK_API_VERSION_1_1"
                   , Term "_VK_VERSION_MAJOR"
                   , Term "_VK_VERSION_MINOR"
                   , Term "_VK_VERSION_PATCH"
                   ]
      weDepends = []
  in WriteElement{..}

nullHandle :: WriteElement
nullHandle =
  let weDoc = [qci|
        pattern VK_NULL_HANDLE :: Ptr a
        pattern VK_NULL_HANDLE <- ((== nullPtr) -> True)
          where VK_NULL_HANDLE = nullPtr
|]
      weImports = [Import "Foreign.Ptr" ["Ptr", "nullPtr"]]
      weExtensions = ["PatternSynonyms", "ViewPatterns"]
      weName = "Null handle"
      weProvides = [Pattern "VK_NULL_HANDLE"]
      weDepends = []
  in WriteElement{..}

bools :: WriteElement
bools = writeEnum
  Enum { eName = "VkBool32"
       , eType = EnumTypeEnum
       , eAliases = []
       , eComment = Just "Note that VkBool32 is not strongly typed in the specification"
       , eElements = [EnumElement "VK_FALSE" (Left 0) Nothing
                     ,EnumElement "VK_TRUE" (Left 1) Nothing
                     ]
       , eExtensions = []
       }

voidDataWriteElement :: Text -> WriteElement
voidDataWriteElement n =
  let weDoc = [qci|
        data {n}
|]
      weImports = []
      weExtensions = []
      weName = n
      weProvides = [WithoutConstructors (TypeName n)]
      weDepends = []
  in WriteElement{..}

unitPtrAliasWriteElement :: Text -> WriteElement
unitPtrAliasWriteElement t =
  aliasWriteElement t "Ptr ()" [Import "Foreign.Ptr" ["Ptr"]]

selfPtrWriteElement :: Text -> WriteElement
selfPtrWriteElement t =
  newtypeWriteElement t [qci|{t} (Ptr {t})|] [Import "Foreign.Ptr" ["Ptr"]]

aliasWriteElement
  :: Text
  -- ^ Name
  -> Text
  -- ^ Alias
  -> [Import]
  -- ^ Imports
  -> WriteElement
aliasWriteElement = newtypeOrTypeWriteElement "type"

newtypeWriteElement
  :: Text
  -- ^ Name
  -> Text
  -- ^ Alias
  -> [Import]
  -- ^ Imports
  -> WriteElement
newtypeWriteElement = newtypeOrTypeWriteElement "newtype"

newtypeOrTypeWriteElement
  :: Text
  -- ^ Declarator
  -> Text
  -- ^ Name
  -> Text
  -- ^ Alias
  -> [Import]
  -- ^ Imports
  -> WriteElement
newtypeOrTypeWriteElement decl n t is =
  let weDoc = [qci|
        {decl} {n} = {t}
|]
      weImports = is
      weExtensions = []
      weName = t
      -- TODO: Tidy
      weProvides = if decl == "newtype"
                     then [WithConstructors (TypeName n)]
                     else [WithoutConstructors (TypeName n)]
      weDepends = []
  in WriteElement{..}

win32 :: [WriteElement]
win32 =
  [ unitPtrAliasWriteElement "HINSTANCE"
  , unitPtrAliasWriteElement "HWND"
  , unitPtrAliasWriteElement "HANDLE"
  , voidDataWriteElement "SECURITY_ATTRIBUTES"
  , aliasWriteElement "DWORD" "Word32" [Import "Data.Word" ["Word32"]]
  , aliasWriteElement
    "LPCWSTR"
    "Ptr CWchar"
    [Import "Foreign.Ptr" ["Ptr"], Import "Foreign.C.Types" ["CWchar"]]
  ]

x11 :: [WriteElement]
x11 =
  [ selfPtrWriteElement "Display"
  , aliasWriteElement "VisualID" "Word64" [Import "Data.Word" ["Word64"]]
  , aliasWriteElement "Window"   "Word64" [Import "Data.Word" ["Word64"]]
  , aliasWriteElement "RROutput" "Word64" [Import "Data.Word" ["Word64"]]
  ]

xcb :: [WriteElement]
xcb =
  [ voidDataWriteElement "Xcb_connection_t"
  , aliasWriteElement "Xcb_visualid_t" "Word32" [Import "Data.Word" ["Word32"]]
  , aliasWriteElement "Xcb_window_t"   "Word32" [Import "Data.Word" ["Word32"]]
  ]

wayland :: [WriteElement]
wayland =
  [ voidDataWriteElement "Wl_display"
  , voidDataWriteElement "Wl_surface"
  ]

mir :: [WriteElement]
mir = [voidDataWriteElement "MirConnection", voidDataWriteElement "MirSurface"]

android :: [WriteElement]
android =
  [voidDataWriteElement "AHardwareBuffer", voidDataWriteElement "ANativeWindow"]

