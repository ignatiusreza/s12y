#!/bin/sh
if [ "$MIX_ENV" = 'test' ]; then
  # `docker` is not available in ci, hence, we mock it here
  echo "{}"
else
  docker run --mount type=bind,source="$(pwd)"/tmp,target=/tmp parsers/mix:latest mix mix.parse "$1"
fi
