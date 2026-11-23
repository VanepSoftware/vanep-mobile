#!/usr/bin/env bash
# Prepara o workspace do CI para o deploy no Google Play (fastlane):
#   - ANDROID_KEYSTORE_BASE64      -> android/app/upload.jks
#   - ANDROID_KEYSTORE_PASSWORD,
#     ANDROID_KEY_ALIAS,
#     ANDROID_KEY_PASSWORD         -> android/key.properties
#   - DART_DEFINE_ENV_FILE         -> .env (asset do flutter_dotenv)
#   - GOOGLE_SERVICES_JSON         -> android/app/google-services.json (Firebase)
#   - PLAY_SERVICE_ACCOUNT_JSON    -> arquivo temporário fora do repo; o caminho
#                                     vai para PLAY_SERVICE_ACCOUNT_JSON_PATH via $GITHUB_ENV
#
# Nunca imprime o valor de nenhum secret.
set -euo pipefail

readonly REQUIRED_VARIABLES=(
  ANDROID_KEYSTORE_BASE64
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
  PLAY_SERVICE_ACCOUNT_JSON
  DART_DEFINE_ENV_FILE
  GOOGLE_SERVICES_JSON
)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly KEYSTORE_PATH="$REPO_ROOT/android/app/upload.jks"
readonly KEY_PROPERTIES_PATH="$REPO_ROOT/android/key.properties"
readonly ENV_FILE_PATH="$REPO_ROOT/.env"
readonly GOOGLE_SERVICES_JSON_PATH="$REPO_ROOT/android/app/google-services.json"

fail() {
  echo "::error title=Preparo do deploy no Google Play::$1" >&2
  exit 1
}

# Properties trata '\' como escape; sem isso uma senha com '\' chegaria alterada ao Gradle.
escape_property_value() {
  printf '%s' "${1//\\/\\\\}"
}

ensure_running_in_ci() {
  if [[ "${CI:-}" != "true" ]]; then
    fail "este script só roda no CI: ele sobrescreve .env, android/key.properties e android/app/google-services.json"
  fi
}

ensure_required_variables() {
  local variable_name
  for variable_name in "${REQUIRED_VARIABLES[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
      fail "variável $variable_name ausente ou vazia"
    fi
  done
}

write_keystore() {
  if ! printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 --decode > "$KEYSTORE_PATH" 2>/dev/null; then
    fail "ANDROID_KEYSTORE_BASE64 não é base64 válido"
  fi
  if [[ ! -s "$KEYSTORE_PATH" ]]; then
    fail "ANDROID_KEYSTORE_BASE64 decodificou para um arquivo vazio"
  fi
}

write_key_properties() {
  {
    printf 'storePassword=%s\n' "$(escape_property_value "$ANDROID_KEYSTORE_PASSWORD")"
    printf 'keyPassword=%s\n' "$(escape_property_value "$ANDROID_KEY_PASSWORD")"
    printf 'keyAlias=%s\n' "$(escape_property_value "$ANDROID_KEY_ALIAS")"
    printf 'storeFile=%s\n' "$(escape_property_value "$KEYSTORE_PATH")"
  } > "$KEY_PROPERTIES_PATH"
}

write_env_file() {
  printf '%s\n' "$DART_DEFINE_ENV_FILE" > "$ENV_FILE_PATH"
}

write_google_services_json() {
  printf '%s\n' "$GOOGLE_SERVICES_JSON" > "$GOOGLE_SERVICES_JSON_PATH"
}

write_service_account_json() {
  local secrets_directory
  secrets_directory="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/play-deploy.XXXXXX")"
  local service_account_path="$secrets_directory/play-service-account.json"

  printf '%s' "$PLAY_SERVICE_ACCOUNT_JSON" > "$service_account_path"

  if [[ -n "${GITHUB_ENV:-}" ]]; then
    echo "PLAY_SERVICE_ACCOUNT_JSON_PATH=$service_account_path" >> "$GITHUB_ENV"
  else
    echo "export PLAY_SERVICE_ACCOUNT_JSON_PATH=$service_account_path"
  fi
}

main() {
  ensure_running_in_ci
  ensure_required_variables
  umask 077
  write_keystore
  write_key_properties
  write_env_file
  write_google_services_json
  write_service_account_json
  echo "Keystore, key.properties, .env, google-services.json e service account do Play preparados."
}

main "$@"
