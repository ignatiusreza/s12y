# build: docker build . -t registries/hexpm:latest
# run: docker run registries/hexpm:latest mix hexpm.lookup [package] [version]
FROM elixir:1.9-slim

ENV MIX_ENV production

WORKDIR /hexpm
COPY . /hexpm

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
