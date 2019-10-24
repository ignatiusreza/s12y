# S12y.Registries

This directory house all of the supported registries lookup.

Each registry lookup can be written in whichever language deemed to be fit, but it is desirable that each registry lookup are written in the language it meant to process (e.g. `hexpm` lookup are written in `elixir`). The minimum API that needs to be satisfied are:

- `bin/build.sh`: handle building the registry, accept no arguments
- `bin/run.sh`: handle running the registry lookup, accept 2 arguments [name] & [version]

Each registry are expected to be dockerize, this is to help make the build reproducible by isolating the dependencies, and to sandbox the lookup process.
