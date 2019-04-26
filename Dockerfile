FROM bitwalker/alpine-elixir-phoenix:1.8.1

# Set up working directory
RUN mkdir /app
ADD . /app
WORKDIR /app

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

RUN mix compile

ENV PORT 4000
ENV MIX_ENV prod

CMD mix run --no-halt
