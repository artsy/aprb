FROM bitwalker/alpine-elixir-phoenix:1.8.1

# Set up working directory
WORKDIR /app

# Install system dependencies
# Create deploy user
RUN apk --no-cache --quiet add dumb-init && \
    adduser -D -g '' deploy

# Cache elixir deps
ADD mix.exs mix.lock ./

# Install app dependencies
RUN mix do deps.get, deps.compile && \
    mix compile

ENV MIX_ENV prod

# Copy application code
COPY . ./

# Grant permissions to user
# Switch to less-privileged user
RUN chown -R deploy:deploy ./
USER deploy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["mix", "run", "--no-halt"]
