# couchdump
A tool to backup and restore a [CouchDB]-Database.

## Installation
Download from [Releases](https://github.com/mkroli/couchdump/releases) or build:
```bash
git clone https://github.com/mkroli/couchdump.git
cd couchdump
cabal install
```

## Usage
```
$ couchdump --help
couchdump 0.2

couchdump [OPTIONS]

Common flags:
  -s --source=location       the source DB (URL, path or - for stdin, default
                             is -)
  -d --destination=location  the destination DB (URL, path or - for stdout,
                             default is -)
  -? --help                  Display help message
  -V --version               Print version information
     --numeric-version       Print just the version number
```

[CouchDB]:http://couchdb.apache.org/
