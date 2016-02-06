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

{-# LANGUAGE DeriveDataTypeable #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}

module CouchDump.Args where

import           System.Console.CmdArgs.Implicit

data Arguments = Arguments {source :: String, destination :: String} deriving (Show, Data, Typeable)

arguments :: IO Arguments
arguments = cmdArgs_ $ record Arguments{} [
  source      := "-" += typ "location" += help "the source DB (URL, path or - for stdin, default is -)",
  destination := "-" += typ "location" += help "the destination DB (URL, path or - for stdout, default is -)"]
    += summary "couchdump 0.1"
    += program "couchdump"
