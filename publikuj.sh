#!/usr/bin/env bash
# Publikacja kursu na GitHuba: repo cwiczeniowe jako submodul repozytorium z materialami.
#
#     ./publikuj.sh <wlasciciel-github>              # pokazuje, co zrobi (nic nie zmienia)
#     ./publikuj.sh <wlasciciel-github> --wykonaj    # wykonuje
#
# Domyslne nazwy repozytoriow mozna zmienic zmiennymi srodowiskowymi:
#     REPO_KURS=kurs-ai REPO_CWICZENIA=rozliczenia ./publikuj.sh marian-w --wykonaj
#
# Wymaga: gh (zalogowany: gh auth status), git.

set -euo pipefail

WLASCICIEL="${1:-}"
WYKONAJ="${2:-}"
REPO_KURS="${REPO_KURS:-kurs-ai-assisted-development}"
REPO_CWICZENIA="${REPO_CWICZENIA:-rozliczenia-cwiczenia}"

KATALOG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CWICZENIA="$KATALOG/repo-cwiczeniowe"

URL_KURS="https://github.com/${WLASCICIEL}/${REPO_KURS}.git"
URL_CWICZENIA="https://github.com/${WLASCICIEL}/${REPO_CWICZENIA}.git"

czerwony() { printf '\033[31m%s\033[0m\n' "$1"; }
zielony()  { printf '\033[32m%s\033[0m\n' "$1"; }
krok()     { printf '\n\033[1m%s\033[0m\n' "$1"; }
polecenie(){ printf '    %s\n' "$1"; }

if [[ -z "$WLASCICIEL" ]]; then
  czerwony "Podaj wlasciciela repozytoriow na GitHubie."
  echo "    ./publikuj.sh <wlasciciel-github> [--wykonaj]"
  exit 1
fi

SUCHO=1
[[ "$WYKONAJ" == "--wykonaj" ]] && SUCHO=0

if [[ "$SUCHO" -eq 1 ]]; then
  printf '\033[33m%s\033[0m\n' "TRYB NA SUCHO - nic nie zostanie zmienione ani wyslane."
  printf '%s\n' "Dodaj --wykonaj, zeby wykonac naprawde."
fi

echo
echo "  wlasciciel:        $WLASCICIEL"
echo "  repo materialow:   $REPO_KURS          -> $URL_KURS"
echo "  repo cwiczeniowe:  $REPO_CWICZENIA     -> $URL_CWICZENIA"

# ---------------------------------------------------------------- kontrole wstepne

krok "0. Kontrole wstepne"

command -v gh  >/dev/null || { czerwony "brak gh"; exit 1; }
command -v git >/dev/null || { czerwony "brak git"; exit 1; }
gh auth status >/dev/null 2>&1 || { czerwony "gh niezalogowany - uruchom: gh auth login"; exit 1; }
zielony "  gh zalogowany"

[[ -d "$CWICZENIA/.git" ]] || { czerwony "brak repozytorium w $CWICZENIA"; exit 1; }

if [[ -n "$(git -C "$CWICZENIA" status --porcelain)" ]]; then
  czerwony "  repo cwiczeniowe ma niezacommitowane zmiany:"
  git -C "$CWICZENIA" status --short | sed 's/^/      /'
  exit 1
fi
zielony "  repo cwiczeniowe czyste"

LICZBA_TAGOW=$(git -C "$CWICZENIA" tag | grep -c '^lab-' || true)
if [[ "$LICZBA_TAGOW" -lt 17 ]]; then
  czerwony "  tagow lab-*: $LICZBA_TAGOW (oczekiwane 17)"
  exit 1
fi
zielony "  tagow lab-*: $LICZBA_TAGOW"

if [[ -d "$KATALOG/.git" ]]; then
  czerwony "  $KATALOG jest juz repozytorium git - ten skrypt zaklada, ze nie jest."
  echo "      Usun .git albo wykonaj kroki recznie."
  exit 1
fi

[[ -f "$KATALOG/.gitignore" ]] || { czerwony "  brak .gitignore w katalogu kursu"; exit 1; }
grep -q '^\.kb/$' "$KATALOG/.gitignore" \
  || { czerwony "  .gitignore nie wyklucza .kb/ - notatki autorskie trafilyby do repozytorium"; exit 1; }
zielony "  .gitignore katalogu kursu wyklucza .kb/"

grep -q 'settings\.local\.json' "$CWICZENIA/.gitignore" \
  || { czerwony "  .gitignore repo cwiczeniowego nie wyklucza .claude/settings.local.json"
       echo "      Lab 6.1 kaze uczestnikowi utworzyc ten plik, a lab 8.1 robi git add -A."
       echo "      Uruchom najpierw: .kb/przepisz-historie.sh --wykonaj"
       exit 1; }
grep -q '^\*\.db-journal$' "$CWICZENIA/.gitignore" \
  || { czerwony "  .gitignore repo cwiczeniowego nie wyklucza plikow tymczasowych SQLite"; exit 1; }

# Baza jest generowana przez seed.py i NIE moze byc sledzona: `make` odtwarza ja
# u kazdego uczestnika, a sledzony plik binarny zablokowalby `git checkout <tag>`.
grep -q '^rozliczenia\.db$' "$CWICZENIA/.gitignore" \
  || { czerwony "  .gitignore repo cwiczeniowego nie wyklucza rozliczenia.db"
       czerwony "  - uczestnik zobaczylby ja jako nieznany plik po pierwszym 'make test'"; exit 1; }
zielony "  .gitignore repo cwiczeniowego kompletny"

# ---------------------------------------------------------------- 1. main na start

krok "1. Ustawienie main repozytorium cwiczeniowego na stan poczatkowy"
echo "  Uczestnik po sklonowaniu ma zobaczyc legacy, nie rozwiazania."
echo "  Pozostale commity zostaja osiagalne przez tagi."
polecenie "git -C repo-cwiczeniowe checkout main"
polecenie "git -C repo-cwiczeniowe reset --hard lab-1-1-start"

if [[ "$SUCHO" -eq 0 ]]; then
  git -C "$CWICZENIA" checkout -q main
  git -C "$CWICZENIA" reset -q --hard lab-1-1-start
  zielony "  main -> $(git -C "$CWICZENIA" rev-parse --short HEAD) (lab-1-1-start)"
fi

# ---------------------------------------------------------------- 2. repo cwiczeniowe

krok "2. Utworzenie i wypchniecie repozytorium cwiczeniowego"
polecenie "gh repo create $WLASCICIEL/$REPO_CWICZENIA --public --description 'Repozytorium cwiczeniowe kursu AI Assisted Development'"
polecenie "git -C repo-cwiczeniowe remote add origin $URL_CWICZENIA"
polecenie "git -C repo-cwiczeniowe push -u origin main"
polecenie "git -C repo-cwiczeniowe push origin --tags"

if [[ "$SUCHO" -eq 0 ]]; then
  gh repo create "$WLASCICIEL/$REPO_CWICZENIA" --public \
     --description "Repozytorium cwiczeniowe kursu AI Assisted Development" >/dev/null
  git -C "$CWICZENIA" remote remove origin 2>/dev/null || true
  git -C "$CWICZENIA" remote add origin "$URL_CWICZENIA"
  git -C "$CWICZENIA" push -q -u origin main
  git -C "$CWICZENIA" push -q origin --tags
  zielony "  wypchniete: main + $LICZBA_TAGOW tagow"
fi

# ---------------------------------------------------------------- 3. repo materialow

krok "3. Repozytorium materialow z submodulem"
echo "  .kb/ (notatki autorskie, program w docx) NIE trafia do repozytorium."
polecenie "git init -b main"
polecenie "rm -rf repo-cwiczeniowe   # zastapione submodulem"
polecenie "git submodule add $URL_CWICZENIA repo-cwiczeniowe"
polecenie "git add -A && git commit"
polecenie "gh repo create $WLASCICIEL/$REPO_KURS --public --source=. --push"

if [[ "$SUCHO" -eq 0 ]]; then
  cd "$KATALOG"
  git init -q -b main
  rm -rf "$CWICZENIA"
  git submodule -q add "$URL_CWICZENIA" repo-cwiczeniowe
  git add -A
  git -c user.name="$(git config --global user.name)" \
      -c user.email="$(git config --global user.email)" \
      commit -q -m "Kurs AI Assisted Development: podrecznik uczestnika

Osiem modulow, szesnascie labow, repozytorium cwiczeniowe jako submodul.
Kazdy modul: teoria, laby z gotowymi promptami, rozwiazania wzorcowe,
sciaga i checklista samooceny. Szablony do wdrozenia w firmie."
  gh repo create "$WLASCICIEL/$REPO_KURS" --public --source=. --push \
     --description "Kurs AI Assisted Development - podrecznik uczestnika" >/dev/null
  zielony "  wypchniete"
fi

# ---------------------------------------------------------------- 4. weryfikacja

krok "4. Weryfikacja: klon z czystego katalogu"
polecenie "git clone --recurse-submodules $URL_KURS <katalog-tymczasowy>"
polecenie "sprawdzenie: 17 tagow, main na stanie poczatkowym, brak .kb/"

if [[ "$SUCHO" -eq 0 ]]; then
  TMP=$(mktemp -d)
  git clone -q --recurse-submodules "$URL_KURS" "$TMP/klon"
  bledy=0

  [[ -f "$TMP/klon/repo-cwiczeniowe/app/main.py" ]] \
    && zielony "  submodul pobrany" || { czerwony "  submodul PUSTY"; bledy=1; }

  T=$(git -C "$TMP/klon/repo-cwiczeniowe" tag | grep -c '^lab-' || true)
  [[ "$T" -ge 17 ]] \
    && zielony "  tagow: $T" || { czerwony "  tagow: $T (oczekiwane 17)"; bledy=1; }

  if git -C "$TMP/klon/repo-cwiczeniowe" show HEAD:app/konfiguracja.py | grep -q "ksef_live_"; then
    zielony "  main na stanie poczatkowym (zasiany klucz obecny)"
  else
    czerwony "  main NIE jest na stanie poczatkowym"; bledy=1
  fi

  [[ -d "$TMP/klon/.kb" ]] && { czerwony "  .kb/ trafilo do repozytorium"; bledy=1; } \
                           || zielony "  .kb/ pominiete"

  [[ -f "$TMP/klon/repo-cwiczeniowe/tests/test_odsetki.py" ]] \
    && { czerwony "  main zawiera rozwiazania"; bledy=1; } \
    || zielony "  main bez rozwiazan"

  if git -C "$TMP/klon/repo-cwiczeniowe" show lab-6-1-start:.gitignore \
       | grep -q 'settings\.local\.json' \
     && git -C "$TMP/klon/repo-cwiczeniowe" show lab-6-1-start:.gitignore \
       | grep -q '^rozliczenia\.db$'; then
    zielony "  .gitignore poprawny takze w tagach"
  else
    czerwony "  .gitignore w tagach niekompletny (settings.local.json / rozliczenia.db)"; bledy=1
  fi

  S=$(ls "$TMP/klon/slajdy"/[0-9][0-9]-*.md 2>/dev/null | wc -l | tr -d ' ')
  [[ "$S" -eq 8 ]] \
    && zielony "  slajdy: 8 deckow zrodlowych" \
    || { czerwony "  slajdy: $S deckow (oczekiwane 8)"; bledy=1; }

  # Wynik renderowania jest w .gitignore - zrodlem jest .md, nie HTML.
  ls "$TMP/klon/slajdy"/*.html "$TMP/klon/slajdy"/*.pdf >/dev/null 2>&1 \
    && { czerwony "  slajdy: zrenderowane pliki trafily do repozytorium"; bledy=1; } \
    || zielony "  slajdy: bez plikow zrenderowanych"

  rm -rf "$TMP"
  [[ "$bledy" -eq 0 ]] || { czerwony "Weryfikacja nie przeszla."; exit 1; }
fi

# ---------------------------------------------------------------- 5. co zostalo

krok "5. Co zrobic recznie po publikacji"
cat <<EOF
  1. Wstaw adres do materialow (teraz jest placeholder):

         grep -rn "ADRES-REPOZYTORIUM-KURSU" --include="*.md" .

     Podmien na: $URL_KURS

  2. Sprawdz, ze README renderuje sie na GitHubie razem z diagramami Mermaid.

  3. Zbuduj slajdy dla siebie - do repozytorium trafiaja tylko zrodla:

         cd slajdy && make html

     HTML ma tryb prezentera pod klawiszem P, razem z notatkami.

  4. Wyslij uczestnikom 00-przygotowanie.md najpozniej dwa dni przed szkoleniem.
EOF

echo
if [[ "$SUCHO" -eq 1 ]]; then
  printf '\033[33m%s\033[0m\n' "To byl tryb na sucho. Dodaj --wykonaj, zeby wykonac."
else
  zielony "Opublikowane."
fi
