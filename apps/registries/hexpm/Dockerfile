FROM elixir:1.9-slim

ENV MIX_ENV production

WORKDIR /hexpm
COPY . /hexpm

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
