#!/usr/bin/env bash
# Stop - deterministyczna bramka jakosci. Nie pozwala zakonczyc tury,
# dopoki `make gate` jest czerwone.
#
# OCHRONA PRZED PETLA - czytaj, zanim napiszesz wlasna.
#
# Exit 2 na Stop kaze modelowi pracowac dalej. Hook, ktory zawsze zwraca 2
# przy czerwonej bramce, zapetlilby sesje. Claude Code daje na to DWA mechanizmy
# i oba sa w dokumentacji zdarzenia Stop:
#
#   1. pole `stop_hook_active` na wejsciu - `true`, gdy tura trwa dalej
#      WLASNIE dlatego, ze poprzedni hook Stop ja zablokowal;
#   2. twardy limit: po 8 kolejnych blokadach Claude Code nadpisuje hook
#      i konczy ture sam.
#
# Nie pisz wiec wlasnego znacznika w scratchpadzie - wejscie juz niesie
# te informacje. Czytaj schemat wejscia, zanim napiszesz obejscie.
#
# Maszyna stanow:
#   bramka zielona                  -> exit 0
#   czerwona, stop_hook_active=false -> exit 2 (pierwsza blokada, model naprawia)
#   czerwona, stop_hook_active=true  -> exit 0 + systemMessage
#                                       (juz probowal, nie zapetlamy)
set -uo pipefail

wejscie=$(cat)
katalog=$(printf '%s' "$wejscie" | jq -r '.cwd // "."')
juz_blokowano=$(printf '%s' "$wejscie" | jq -r '.stop_hook_active // false')

# Bramke uruchamiamy w katalogu sesji (cwd), nie w ${CLAUDE_PROJECT_DIR}.
# W worktree te dwie sciezki sa rozne - patrz modul 6.
cd "$katalog" || exit 0
[[ -f Makefile ]] || exit 0

if wynik=$(make gate 2>&1); then
  exit 0
fi

if [[ "$juz_blokowano" == "true" ]]; then
  printf '%s\n' "$wynik" | tail -20 >&2
  jq -n '{systemMessage: "Bramka jakosci nadal jest czerwona po probie naprawy. Nie blokuje ponownie. Napraw to albo powiedz uzytkownikowi, czego potrzebujesz."}'
  exit 0
fi

{
  echo "Bramka jakosci jest czerwona - nie moge zakonczyc pracy."
  echo "---"
  printf '%s\n' "$wynik" | tail -30
} >&2
exit 2
