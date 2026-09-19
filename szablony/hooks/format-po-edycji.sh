#!/usr/bin/env bash
# PostToolUse / Edit|Write - formatuje tylko plik, ktory wlasnie zostal zmieniony.
# Zawsze exit 0: formatowanie nie ma prawa zatrzymac pracy.
set -uo pipefail

wejscie=$(cat)
plik=$(printf '%s' "$wejscie" | jq -r '.tool_input.file_path // ""')
katalog=$(printf '%s' "$wejscie" | jq -r '.cwd // "."')

[[ "$plik" == *.py ]] || exit 0
[[ -f "$plik" ]] || exit 0

ruff=""
for kandydat in "$katalog/.venv/bin/ruff" "$(command -v ruff || true)"; do
  [[ -x "$kandydat" ]] && { ruff="$kandydat"; break; }
done
[[ -n "$ruff" ]] || exit 0

"$ruff" format -q "$plik" >/dev/null 2>&1 || true
exit 0
