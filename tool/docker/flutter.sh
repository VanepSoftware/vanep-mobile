#!/usr/bin/env bash
# Runs a command with the Flutter version pinned in .fvmrc, inside Docker, with
# the repo mounted at /app. No local Flutter install needed.
#
#   tool/docker/flutter.sh flutter test
#   tool/docker/flutter.sh flutter analyze --fatal-infos
#   VANEP_PREVIEW=1 tool/docker/flutter.sh flutter test test/preview --update-goldens
#
# .dart_tool and the pub cache live in Docker volumes so the Linux build state
# never mixes with a local (Windows/macOS) Flutter install.
set -euo pipefail

cd "$(dirname "$0")/../.."

flutter_version=$(sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' .fvmrc)
image="vanep-flutter:${flutter_version}"

if ! docker image inspect "$image" >/dev/null 2>&1; then
  docker build -t "$image" --build-arg "FLUTTER_VERSION=${flutter_version}" tool/docker
fi

# Git Bash on Windows rewrites /app-style paths and needs the Windows form of
# the repo path for the bind mount.
host_dir=$(pwd -W 2>/dev/null || pwd)

MSYS_NO_PATHCONV=1 docker run --rm \
  -e VANEP_PREVIEW \
  -v "${host_dir}:/app" \
  -v vanep-pub-cache:/root/.pub-cache \
  -v vanep-dart-tool:/app/.dart_tool \
  "$image" \
  bash -c '
    set -e
    [ -f .env ] || cp .env.example .env
    # pub get rewrites the committed plugin registrants with LF endings; keep
    # the checked-out bytes so a Windows working tree does not show changes.
    registrants=$(ls linux/flutter/generated_plugin* windows/flutter/generated_plugin* \
      macos/Flutter/GeneratedPluginRegistrant.swift 2>/dev/null || true)
    if [ -n "$registrants" ]; then
      tar cf /tmp/registrants.tar $registrants
      trap "tar xf /tmp/registrants.tar" EXIT
    fi
    flutter pub get >/dev/null
    flutter gen-l10n >/dev/null
    dart run build_runner build --delete-conflicting-outputs >/dev/null
    "$@"
  ' _ "$@"
