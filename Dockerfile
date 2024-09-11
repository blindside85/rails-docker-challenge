# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.5

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives


# Throw-away build stage to reduce size of final image
FROM base AS build

WORKDIR /rails

# I'd rather not have to do this, but rails gets mad if they aren't here. If we
# *have* to have it, using --mount=type=secret would be much better
ENV DATABASE_NAME=${DATABASE_NAME}\
  DATABASE_USER=${DATABASE_USER} \
  DATABASE_PASSWORD=${DATABASE_PASSWORD}

# Install packages needed to build gems
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ /usr/local/bundle/cache /usr/local/bundle/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copy application code
# Need to spend more time combing through the built image to make sure extra
# files aren't being baked in
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


FROM base AS final

WORKDIR /rails

# Copy built artifacts: gems, application
RUN mkdir -p /rails/db /rails/log /rails/storage /rails/tmp
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails .

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
  chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
