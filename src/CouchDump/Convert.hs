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

{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module CouchDump.Convert (convert) where

import           Control.Monad
import           CouchDump.Misc
import           Data.Aeson
import           Data.ByteString.Lazy
import           Data.HashMap.Strict
import           GHC.Generics

newtype Row = Row {doc :: Object} deriving (Show, Generic, FromJSON, ToJSON)
newtype ExportDocument = ExportDocument {rows :: [Row]} deriving (Show, Generic, FromJSON, ToJSON)
newtype ImportDocument = ImportDocument {docs :: [Object]} deriving (Show, Generic, FromJSON, ToJSON)

exportToImport :: ExportDocument -> ImportDocument
exportToImport (ExportDocument rows) = ImportDocument $ liftM (delete "_rev" . doc) rows

decodeImportDocument :: Monad m => ByteString -> m ImportDocument
decodeImportDocument content = case decode content :: Maybe ExportDocument of
  Just r -> return $ exportToImport r
  Nothing -> decodeWithFailure content

convert :: Monad m => ByteString -> m ByteString
convert i = liftM encode $ decodeImportDocument i
