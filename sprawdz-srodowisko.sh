#!/usr/bin/env bash
# Sprawdzenie srodowiska przed kursem "AI Assisted Development".
# Do uruchomienia z katalogu materialow kursu albo z repo-cwiczeniowe/:
#
#     ./sprawdz-srodowisko.sh
#
# Wypisuje raport. Kazda linia OSTRZEZENIE albo BLAD wymaga reakcji PRZED szkoleniem.

set -uo pipefail

bledy=0
ostrzezenia=0

ok()      { printf '  \033[32mOK\033[0m        %s\n' "$1"; }
ostrzez() { printf '  \033[33mOSTRZEZ\033[0m   %s\n' "$1"; ostrzezenia=$((ostrzezenia + 1)); }
blad()    { printf '  \033[31mBLAD\033[0m      %s\n' "$1"; bledy=$((bledy + 1)); }
naglowek(){ printf '\n%s\n' "$1"; }

wersja_ge() {
  # wersja_ge "2.1.251" "2.1.300" -> 0 gdy druga >= pierwsza
  printf '%s\n%s\n' "$1" "$2" | sort -V -C
}

naglowek "Narzedzia podstawowe"

if command -v git >/dev/null 2>&1; then
  ok "git $(git --version | awk '{print $3}')"
else
  blad "brak git"
fi

# Obslugiwane: 3.12 i 3.11. NIE 3.13 - pydantic==2.6.1 nie ma dla niego pakietu
# i pip probuje kompilowac pydantic-core z Rusta. To celowo stare piny (modul 4).
py=""
for kandydat in python3.12 python3.11 python3; do
  if command -v "$kandydat" >/dev/null 2>&1; then
    w=$("$kandydat" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || echo "")
    case "$w" in
      3.12|3.11) py="$kandydat"; ok "$kandydat -> Python $w"; break ;;
    esac
  fi
done
if [[ -z "$py" ]]; then
  blad "brak Pythona 3.12 ani 3.11"
  if command -v python3.13 >/dev/null 2>&1; then
    printf "\n  Masz Pythona 3.13 - on NIE zadziala. Zaleznosci sa celowo stare\n"
    printf "  (pydantic 2.6.1 z lutego 2024) i nie maja pakietu dla 3.13.\n"
    printf "  macOS:  brew install python@3.12\n"
    printf "  Ubuntu: sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.12 python3.12-venv\n\n"
  fi
fi

if command -v make >/dev/null 2>&1; then
  ok "make"
else
  blad "brak make (macOS: xcode-select --install, Debian/Ubuntu: apt install make)"
fi

if command -v jq >/dev/null 2>&1; then
  ok "jq $(jq --version)"
else
  blad "brak jq - hooki z modulu 5 go wymagaja (macOS: brew install jq, Debian/Ubuntu: apt install jq)"
fi

naglowek "Claude Code"

if command -v claude >/dev/null 2>&1; then
  wersja=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  if [[ -z "$wersja" ]]; then
    ostrzez "claude zainstalowany, ale nie udalo sie odczytac wersji"
  elif wersja_ge "2.1.251" "$wersja"; then
    ok "claude $wersja"
  else
    ostrzez "claude $wersja - lab 7.1 wymaga 2.1.251+ (statystyki prompt cache). Zaktualizuj."
  fi
else
  blad "brak Claude Code - https://claude.com/claude-code"
fi

naglowek "Slajdy - dotyczy tylko prowadzacego"

# Decki buduje prowadzacy przez Marp (npx sciaga marp-cli), uczestnik ich nie buduje.
# Dlatego brak Node'a NIE jest tu bledem ani ostrzezeniem: nie blokuje zadnego labu,
# a uczestnikowi, ktory zobaczylby "BLAD", kazaloby instalowac cos niepotrzebnego.
if command -v npx >/dev/null 2>&1; then
  ok "npx $(npx --version 2>/dev/null || echo '?') - make html w slajdy/ zadziala"
else
  printf '  \033[36mINFO\033[0m      brak Node/npx: make html w slajdy/ nie zbuduje deckow.\n'
  printf '            Uczestnika to nie dotyczy, prowadzacego tak.\n'
  printf '            macOS: brew install node · Debian/Ubuntu: apt install nodejs npm\n'
fi

naglowek "Repozytorium cwiczeniowe"

# Skrypt lezy w katalogu materialow, a sprawdzac ma repozytorium cwiczeniowe.
# Uruchamiany bywa z obu miejsc, wiec sam sobie znajduje wlasciwy katalog zamiast
# zgadywac po obecnosci `.git` - katalog materialow TEZ jest repozytorium git
# (uczestnik go sklonowal), wiec `.git` niczego nie rozstrzyga.
if [[ -f "app/main.py" && -f "seed.py" ]]; then
  ok "jestes w katalogu repozytorium cwiczeniowego"
elif [[ -f "repo-cwiczeniowe/app/main.py" && -f "repo-cwiczeniowe/seed.py" ]]; then
  cd repo-cwiczeniowe
  ok "wszedlem do repo-cwiczeniowe/"
elif [[ -d "repo-cwiczeniowe" && -z "$(ls -A repo-cwiczeniowe 2>/dev/null)" ]] \
  || [[ "$(basename "$PWD")" == "repo-cwiczeniowe" && -z "$(ls -A . 2>/dev/null)" ]]; then
  blad "katalog repo-cwiczeniowe/ jest PUSTY - submodul sie nie pobral"
  printf '\n  Klon bez --recurse-submodules. Naprawa bez klonowania od nowa:\n'
  printf '      git submodule update --init --recursive\n'
  printf '      (z katalogu materialow kursu)\n'
  printf '\nPodsumowanie: %d bledow, %d ostrzezen\n' "$bledy" "$ostrzezenia"
  exit 1
else
  blad "nie znalazlem repozytorium cwiczeniowego"
  printf '\n  Skrypt uruchamia sie z katalogu materialow kursu albo z repo-cwiczeniowe/:\n'
  printf '      cd kurs-ai-assisted-development && ./sprawdz-srodowisko.sh\n'
  printf '\nPodsumowanie: %d bledow, %d ostrzezen\n' "$bledy" "$ostrzezenia"
  exit 1
fi

if git rev-parse --git-dir >/dev/null 2>&1; then
  liczba_tagow=$(git tag | grep -c '^lab-' || true)
  if [[ "$liczba_tagow" -ge 17 ]]; then
    ok "tagi labow: $liczba_tagow"
  else
    ostrzez "tagow labow: $liczba_tagow (oczekiwane 17) - pobierz je: git fetch --tags"
  fi
else
  blad "to nie jest repozytorium git"
fi

naglowek "Srodowisko Pythona"

if [[ -z "$py" ]]; then
  ostrzez "pominieto - brak Pythona"
else
  if [[ ! -d ".venv" ]]; then
    printf '  tworze .venv...\n'
    "$py" -m venv .venv >/dev/null 2>&1 || blad "nie udalo sie utworzyc .venv"
  fi

  if [[ -x ".venv/bin/python" ]]; then
    ok ".venv istnieje"
    printf '  instaluje zaleznosci...\n'
    if .venv/bin/pip install -q --disable-pip-version-check -r requirements.txt >/dev/null 2>&1; then
      ok "zaleznosci zainstalowane"
    else
      blad "instalacja zaleznosci nie powiodla sie - uruchom recznie: .venv/bin/pip install -r requirements.txt"
    fi

    if .venv/bin/python -c "import fastapi, pydantic, pytest" >/dev/null 2>&1; then
      ok "fastapi, pydantic, pytest importuja sie"
    else
      blad "brakuje ktorejs z zaleznosci"
    fi
  fi
fi

naglowek "Aplikacja"

if [[ -x ".venv/bin/python" ]]; then
  if .venv/bin/python seed.py >/dev/null 2>&1; then
    ok "seed.py odtwarza baze"
  else
    blad "seed.py nie dziala"
  fi

  if .venv/bin/python -c "import app.main" >/dev/null 2>&1; then
    ok "app.main importuje sie"
  else
    blad "app.main nie importuje sie"
  fi

  if .venv/bin/python -c "
from fastapi.testclient import TestClient
from app.main import app
r = TestClient(app).get('/zdrowie')
raise SystemExit(0 if r.status_code == 200 else 1)
" >/dev/null 2>&1; then
    ok "API odpowiada na /zdrowie"
  else
    blad "API nie odpowiada"
  fi

  wynik=$(.venv/bin/python -m pytest -q 2>&1 | tail -1)
  if [[ "$wynik" == *"no tests ran"* ]]; then
    ok "pytest dziala (brak testow - poprawnie dla tagu lab-1-1-start)"
  elif [[ "$wynik" == *passed* && "$wynik" != *failed* ]]; then
    ok "pytest: $wynik"
  else
    ostrzez "pytest: $wynik"
  fi
fi

naglowek "Podsumowanie"
printf '  bledow: %d, ostrzezen: %d\n\n' "$bledy" "$ostrzezenia"

if [[ "$bledy" -gt 0 ]]; then
  printf 'Bledy nalezy naprawic PRZED modulem 1 - lab nie jest miejscem na instalacje.\n'
  exit 1
fi
if [[ "$ostrzezenia" -gt 0 ]]; then
  printf 'Srodowisko zadziala, ale czesc cwiczen moze byc ograniczona.\n'
  exit 0
fi
printf 'Srodowisko gotowe.\n'
exit 0
