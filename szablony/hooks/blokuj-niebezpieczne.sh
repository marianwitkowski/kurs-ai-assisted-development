#!/usr/bin/env bash
# PreToolUse / Bash - blokuje komendy, ktorych w tym repozytorium nie wykonujemy.
# Exit 2 = blokada. Komunikat ze stderr trafia do modelu i do uzytkownika.
set -uo pipefail

wejscie=$(cat)
komenda=$(printf '%s' "$wejscie" | jq -r '.tool_input.command // ""')

# Krotka, oczywista lista. Dluga lista daje zludzenie bezpieczenstwa
# i blokuje prace przy pierwszym falszywym trafieniu.
wzorce=(
  'rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-{1,2}[rRf]'
  'git[[:space:]]+push[[:space:]]+.*--force'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+.*-[a-zA-Z]*f'
  'DROP[[:space:]]+TABLE'
  'chmod[[:space:]]+777'
  '>[[:space:]]*/dev/sd'
)

for wzorzec in "${wzorce[@]}"; do
  if printf '%s' "$komenda" | grep -qEi "$wzorzec"; then
    echo "Zablokowane przez hook projektu: komenda pasuje do wzorca '${wzorzec}'." >&2
    echo "Jezeli naprawde tego potrzebujesz, uruchom to sam w terminalu." >&2
    exit 2
  fi
done

exit 0
