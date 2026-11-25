#!/usr/bin/env bash
# Seletor de device/emulador para Flutter (usado pelas tasks do Zed).
#
# Uso:
#   flutter-device.sh run [args do flutter run...]  # escolhe device/emulador e roda o app
#   flutter-device.sh emulator                      # escolhe um emulador e só liga
set -u
cd "$(dirname "$0")/.." || exit 1

MODE="${1:-run}"
shift || true

if [ -f .fvmrc ] && command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi
if ! command -v "${FLUTTER[0]}" >/dev/null 2>&1; then
  echo "Erro: '${FLUTTER[0]}' não encontrado no PATH."
  exit 1
fi

trim() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

# adb (opcional): usado só para saber quais emuladores já estão ligados
ADB="$(command -v adb 2>/dev/null || true)"
if [ -z "$ADB" ]; then
  for root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Android/Sdk" "$HOME/Library/Android/sdk"; do
    [ -n "$root" ] && [ -x "$root/platform-tools/adb" ] && ADB="$root/platform-tools/adb" && break
  done
fi

list_devices() { # imprime "nome|id" por linha
  "${FLUTTER[@]}" devices 2>/dev/null | grep ' • ' | while IFS='•' read -r name id _; do
    echo "$(echo "$name" | trim)|$(echo "$id" | trim)"
  done
}

echo "Buscando devices e emuladores..."
KINDS=(); VALS=(); LABELS=()
RUNNING_AVDS=" "

while IFS='|' read -r name id; do
  [ -z "$id" ] && continue
  KINDS+=(device); VALS+=("$id"); LABELS+=("[ligado]  $name ($id)")
  if [ -n "$ADB" ] && [[ "$id" == emulator-* ]]; then
    avd="$("$ADB" -s "$id" emu avd name 2>/dev/null | head -1 | tr -d '\r')"
    [ -n "$avd" ] && RUNNING_AVDS="$RUNNING_AVDS$avd "
  fi
done < <(list_devices)

while IFS='•' read -r id name _; do
  id="$(echo "$id" | trim)"; name="$(echo "$name" | trim)"
  [ -z "$id" ] && continue
  [[ "$RUNNING_AVDS" == *" $id "* ]] && continue
  KINDS+=(emulator); VALS+=("$id"); LABELS+=("[desligado] emulador $name")
done < <("${FLUTTER[@]}" emulators 2>/dev/null | grep ' • ' | grep -v '^Id ')

if [ "${#KINDS[@]}" -eq 0 ]; then
  echo "Nenhum device ligado nem emulador instalado."
  exit 1
fi

# No modo 'emulator' só interessam os emuladores desligados
echo
echo "Escolha:"
shown=()
for i in "${!KINDS[@]}"; do
  if [ "$MODE" = "emulator" ] && [ "${KINDS[$i]}" != "emulator" ]; then continue; fi
  shown+=("$i")
  echo "  ${#shown[@]}) ${LABELS[$i]}"
done
if [ "${#shown[@]}" -eq 0 ]; then
  echo "Nenhum emulador desligado disponível."
  exit 0
fi

read -rp "Número: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#shown[@]}" ]; then
  echo "Opção inválida."
  exit 1
fi
idx="${shown[$((choice - 1))]}"
kind="${KINDS[$idx]}"
val="${VALS[$idx]}"

if [ "$kind" = "emulator" ]; then
  before=" $(list_devices | cut -d'|' -f2 | tr '\n' ' ')"
  echo "Ligando emulador $val..."
  log="${TMPDIR:-/tmp}/flutter-emulator-$val.log"
  # setsid desvincula o emulador do terminal do Zed (senão ele fecha com a task)
  if command -v setsid >/dev/null 2>&1; then
    setsid -f "${FLUTTER[@]}" emulators --launch "$val" >"$log" 2>&1
  else
    nohup "${FLUTTER[@]}" emulators --launch "$val" >"$log" 2>&1 &
  fi

  if [ "$MODE" = "emulator" ]; then
    echo "Emulador iniciado. Quando terminar de ligar, use a task de rodar."
    exit 0
  fi

  echo "Aguardando o emulador aparecer como device (até 3 min)..."
  val=""
  for _ in $(seq 1 90); do
    sleep 2
    for did in $(list_devices | cut -d'|' -f2); do
      if [[ "$before" != *" $did "* ]]; then val="$did"; break 2; fi
    done
  done
  if [ -z "$val" ]; then
    echo "O emulador não apareceu a tempo. Veja o log: $log"
    exit 1
  fi
  echo "Device: $val"
elif [ "$MODE" = "emulator" ]; then
  echo "Já está ligado."
  exit 0
fi

exec "${FLUTTER[@]}" run -d "$val" "$@"
