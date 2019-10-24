# S12y.Parsers

This directory house all of the supported parsers.

Each parser can be written in whichever language deemed to be fit, but it is desirable that each parser are written in the language it meant to parse (e.g. `mix.exs` parser are written in `elixir`). The minimum API that needs to be satisfied are:

- `bin/build.sh`: handle building the parser, accept no arguments
- `bin/run.sh`: handle running the parsing process, accept a single argument [projectId] in the form of a UUID

Each parser are expected to be dockerize, this is to help make the build reproducible by isolating the dependencies, and to sandbox the parsing process in case the uploaded project configuration contains malicious code.

During the parsing process, each parser should expect that the configuration to be parsed can be found under `/tmp/[projectId]`.
