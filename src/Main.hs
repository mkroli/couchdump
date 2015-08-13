{-|
Copyright 2015 Michael Krolikowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

import qualified Data.ByteString.Lazy.Char8 as B
import Data.Aeson
import GHC.Generics
import Control.Applicative
import Data.HashMap.Strict

data Row = Row {doc :: Object}
  deriving (Show,Generic)
instance FromJSON Row
instance ToJSON Row

data ExportDocument = ExportDocument {rows :: [Row]}
  deriving (Show,Generic)
instance FromJSON ExportDocument
instance ToJSON ExportDocument

data ImportDocument = ImportDocument {docs :: [Object]}
  deriving (Show,Generic)
instance FromJSON ImportDocument
instance ToJSON ImportDocument

exportToImport :: ExportDocument -> ImportDocument
exportToImport (ExportDocument rows) = ImportDocument $ fmap (delete "_rev" . doc) rows

putStrLnMaybe :: Maybe B.ByteString -> IO ()
putStrLnMaybe (Just a) = B.putStrLn a
putStrLnMaybe Nothing = return ()

main :: IO ()
main = let
    content = B.getContents
    json = decode <$> content
    converted = fmap exportToImport <$> json
    convertedJson = fmap encode <$> converted
  in
    convertedJson >>= putStrLnMaybe
