{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE RecordWildCards   #-}

module Write.Feature
  ( writeFeature
  ) where


import           Data.Text
import           Data.Text.Prettyprint.Doc
import           Prelude                                  hiding (Enum)
import           Text.InterpolatedString.Perl6.Unindented

import           Spec.Savvy.Enum
import           Spec.Savvy.Extension
import           Spec.Savvy.Feature
import           Write.Element

writeFeature :: Feature -> WriteElement
writeFeature e@Feature {..} =
  let weName       = "Feature: " <> fName
      weDoc        = extensionDoc e
      weExtensions = ["PatternSynonyms"]
      weImports    = []
      weProvides =
        (Pattern . exName . snd <$> (rEnumExtensions =<< fRequirements))
          ++ (Pattern . eaName <$> (rEnumAliases =<< fRequirements))
      -- TODO: add the enum type to the depends
      weDepends =
        (PatternName <$> (rEnumNames =<< fRequirements))
          ++ (TermName <$> (rCommandNames =<< fRequirements))
  in  WriteElement {..}

extensionDoc :: Feature -> Doc ()
extensionDoc Feature{..} = [qci|
  {vcat $ uncurry enumFeatureDoc <$> (rEnumExtensions =<< fRequirements)}

  {vcat $ enumAliasDoc <$> (rEnumAliases =<< fRequirements)}
|]

enumFeatureDoc :: Text -> EnumExtension -> Doc ()
enumFeatureDoc extendee EnumExtension{..} = [qci|
  -- | {exComment}
  pattern {exName} :: {extendee}
  pattern {exName} = {extendee} {writeValue exValue}
|]

enumAliasDoc :: EnumAlias -> Doc ()
enumAliasDoc EnumAlias{..} = [qci|
  pattern {eaName} :: {eaExtends}
  pattern {eaName} = {eaAlias}
|]

writeValue :: Either Int32 Word32 -> Doc ()
writeValue = \case
  Left i -> pretty $ showsPrec 10 i ""
  Right i -> pretty $ (printf "0x%08x" i :: String)