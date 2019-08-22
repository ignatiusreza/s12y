# build: docker build . -t parsers/mix:latest
# run: docker run --mount type=bind,source="$(pwd)"/tmp,target=/tmp parsers/mix:latest mix mix.parse [path]
FROM elixir:1.9-slim

ENV MIX_ENV production

WORKDIR /mix
COPY . /mix

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
