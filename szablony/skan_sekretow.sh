#!/usr/bin/env bash
# Skan sekretow w kodzie sledzonym przez gita.
# Celowo prosty: kilka wzorcow, ktore faktycznie wpadaja do repozytoriow.
# Nie zastepuje narzedzia typu gitleaks - ma byc szybki i zrozumialy.
set -uo pipefail

wzorce=(
  'ksef_live_[A-Za-z0-9]{16,}'
  'sk-ant-[A-Za-z0-9_-]{20,}'
  'AKIA[0-9A-Z]{16}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '(password|haslo|secret|token)[[:space:]]*=[[:space:]]*["'"'"'][^"'"'"']{8,}["'"'"']'
)

znalezione=0
pliki=$(git ls-files -- '*.py' '*.sh' '*.json' '*.toml' '*.md' '*.yml' '*.yaml' 2>/dev/null)
[[ -n "$pliki" ]] || exit 0

for wzorzec in "${wzorce[@]}"; do
  # shellcheck disable=SC2086
  trafienia=$(grep -nEI "$wzorzec" $pliki 2>/dev/null \
    | grep -v 'skrypty/skan_sekretow.sh' \
    | grep -v 'tests/test_bezpieczenstwo.py' || true)
  if [[ -n "$trafienia" ]]; then
    echo "SEKRET: wzorzec '${wzorzec}'" >&2
    printf '%s\n' "$trafienia" >&2
    znalezione=1
  fi
done

[[ "$znalezione" -eq 0 ]] || { echo "Skan sekretow: ZNALEZIONO." >&2; exit 1; }
exit 0
