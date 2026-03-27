# syntax=docker/dockerfile:1
#
# Builder image: https://hub.docker.com/r/hexpm/elixir/tags
# Runner image:  https://hub.docker.com/_/debian/tags?name=bookworm-slim

ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.3.1
ARG DEBIAN_VERSION=bookworm-20260316-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# Install build dependencies
# hadolint ignore=DL3008
RUN apt-get update -y && apt-get install -y --no-install-recommends \
      build-essential git curl

# Install d2 (required for compile-time SVG diagram rendering in blog posts)
RUN /bin/bash -o pipefail -c "curl -fsSL https://d2lang.com/install.sh | sh -s --"

WORKDIR /app

ENV MIX_ENV=prod

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Install and compile mix dependencies as separate layers so they are
# only re-run when mix.exs/mix.lock change.
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# Copy compile-time config before compiling deps so config changes
# trigger a dep recompile.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
RUN mix compile

COPY assets assets
RUN mix assets.deploy

# runtime.exs changes don't require recompiling code
COPY config/runtime.exs config/

RUN mix release

# ---- runner ----
FROM ${RUNNER_IMAGE}

# hadolint ignore=DL3008
RUN apt-get update -y && apt-get install -y --no-install-recommends \
      libstdc++6 openssl libncurses6 locales ca-certificates \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PHX_SERVER=true

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/prod/rel/personal_site ./

USER nobody

CMD ["/app/bin/personal_site", "start"]
