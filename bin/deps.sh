#!/bin/sh

ROOT=$(pwd)
FOLDERS=$(find -name "mix.exs" | grep -v "deps\|tmp\|node_modules" | xargs dirname)
COMMAND=$1
shift

for f in $FOLDERS
do
  cd "${f}"
  mix deps."$COMMAND" $@
  cd "${ROOT}"
done

cd "${ROOT}"
