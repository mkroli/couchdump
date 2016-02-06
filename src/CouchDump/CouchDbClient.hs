{-|
Copyright 2015-2016 Michael Krolikowski

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

{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings             #-}

module CouchDump.CouchDbClient (fetchDatabase, writeDatabase) where

import           Control.Monad
import           CouchDump.Misc
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.ByteString.Char8      as B
import qualified Data.ByteString.Lazy.Char8 as LB
import           Data.Foldable
import           Data.Maybe
import           Network.HTTP.Conduit
import           Network.HTTP.Types.Method
import           GHC.Generics

httpReq :: Request -> IO LB.ByteString
httpReq req = do
  manager <- newManager tlsManagerSettings
  response <- httpLbs req manager
  return $ responseBody response

fetchDatabase :: String -> IO LB.ByteString
fetchDatabase url = do
  baseReq <- parseUrl url
  let allDocsReq = baseReq { path = B.append (path baseReq) "/_all_docs" }
      allIncludedReq = setQueryString [("include_docs", Just "true"), ("attachments", Just "true")] allDocsReq
  httpReq allIncludedReq

data BulkResponse = BulkSuccessResponse {id :: String, ok :: Bool} | BulkErrorResponse {id :: String, error :: String, reason :: String} deriving (Show, Generic, ToJSON)
instance FromJSON BulkResponse where
  parseJSON = withObject "BulkResponse" $ \o -> asum [
    BulkSuccessResponse <$> o .: "id" <*> o .: "ok",
    BulkErrorResponse   <$> o .: "id" <*> o .: "error" <*> o .: "reason" ]

bulkErrorResponseErrorMessage :: BulkResponse -> Maybe String
bulkErrorResponseErrorMessage (BulkErrorResponse id error reason) = Just $ "Error with document " ++ id ++ ": " ++ error ++ " " ++ reason
bulkErrorResponseErrorMessage _ = Nothing

bulkResponseErrorMessage :: [BulkResponse] -> [String]
bulkResponseErrorMessage = mapMaybe bulkErrorResponseErrorMessage

writeDatabase :: String -> LB.ByteString -> IO ()
writeDatabase url contents = do
  baseReq <- parseUrl url
  httpReq baseReq { method = methodPut, checkStatus = \_ _ _ -> Nothing }
  httpResp <- httpReq baseReq { path = B.append (path baseReq) "/_bulk_docs",
                                method = methodPost,
                                requestHeaders = ("Content-Type", "application/json") : requestHeaders baseReq,
                                requestBody = RequestBodyLBS contents }
  response <- decodeWithFailure httpResp :: IO [BulkResponse]
  case bulkResponseErrorMessage response of
    [] -> return ()
    e -> fail $ joinList e "\n"
