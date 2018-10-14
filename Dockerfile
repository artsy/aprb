FROM elixir:1.5.0-slim

# Set up deploy user and working directory
RUN adduser --disabled-password --gecos '' deploy

RUN apt-get update && \
      apt-get -y install sudo git

# Set up working directory
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN chown -R deploy:deploy /app

# Switch to deploy user
USER deploy
ENV USER deploy
ENV HOME /home/deploy

RUN mix local.hex --force
RUN mix local.rebar --force

ENV PORT 4000
ENV MIX_ENV prod

RUN mix deps.get
RUN mix compile

CMD mix run --no-halt
