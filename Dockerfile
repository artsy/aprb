FROM elixir:1.3.0

RUN mix local.hex --force
RUN mix local.rebar --force

RUN apt-get update && \
      apt-get -y install sudo

ADD . /app
WORKDIR /app
ENV PORT 4000
ENV MIX_ENV prod
RUN mix deps.get
RUN mix compile
CMD mix run --no-halt
