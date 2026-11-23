# Flutter toolchain for lint, tests and screen previews without a local
# Flutter install. FLUTTER_VERSION must match `.fvmrc`.
FROM debian:bookworm-slim

ARG FLUTTER_VERSION=3.47.2

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils make \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git /opt/flutter

ENV FLUTTER_ROOT=/opt/flutter \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH \
    PUB_CACHE=/root/.pub-cache

RUN git config --global --add safe.directory '*' \
  && flutter config --no-analytics --no-cli-animations \
  && flutter precache --no-android --no-ios --no-web \
  && flutter --version

WORKDIR /app
