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

import           Control.Exception
import           CouchDump.Args
import           CouchDump.Convert
import           CouchDump.CouchDbClient
import qualified Data.ByteString.Lazy.Char8 as LB
import           Data.Maybe
import           Network.HTTP.Conduit
import           System.IO.Error

isUrl :: String -> Bool
isUrl = isJust . parseUrl

fetchContents :: String -> IO LB.ByteString
fetchContents "-" = LB.getContents
fetchContents loc
  | isUrl loc = fetchDatabase loc
  | otherwise = LB.readFile loc

writeContents :: String -> LB.ByteString -> IO ()
writeContents "-" = LB.putStrLn
writeContents loc
  | isUrl loc = writeDatabase loc
  | otherwise = LB.writeFile loc

main :: IO ()
main = do
    args <- arguments
    contents <- fetchContents $ source args
    converted <- convert contents
    writeContents (destination args) converted
  `catch` \e -> do
    putStrLn $ ioeGetErrorString (e :: IOException)
    return ()
