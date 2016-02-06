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

module CouchDump.Misc where

import           Data.Aeson
import           Data.ByteString.Lazy

eitherErrorToMonad :: Monad m => Either String a -> m a
eitherErrorToMonad (Left e) = fail e
eitherErrorToMonad (Right r) = return r

decodeWithFailure :: (Monad m, FromJSON a) => ByteString -> m a
decodeWithFailure = eitherErrorToMonad . eitherDecode

joinList :: [[a]] -> [a] -> [a]
joinList [] sep = []
joinList [head] _ = head
joinList (head:tail) sep = head ++ sep ++ joinList tail sep
