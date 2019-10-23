# run:
#!/bin/sh
if [ "$MIX_ENV" = 'test' ]; then
  # `docker` is not available in ci, hence, we mock it here
  echo "{}"
else
  docker run registries/hexpm:latest mix hexpm.lookup "$1" "$2"
fi
