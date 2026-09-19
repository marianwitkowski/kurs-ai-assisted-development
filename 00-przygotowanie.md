# Przygotowanie przed szkoleniem

> **Do wykonania przed modułem 1.** Moduł 1 zaczyna się od pracy z kodem,
> nie od instalacji. Przygotowanie z wyprzedzeniem zostawia miejsce
> na rozwiązanie problemów ze środowiskiem.

Większość tego to czekanie na pobieranie - można uruchomić i zająć się czymś innym.

---

## 1. Wymagane narzędzia

| Narzędzie | Wersja | Uwagi |
|---|---|---|
| **Claude Code** | **2.1.251 lub nowsza** | starsze nie mają statystyk prompt cache używanych w labie 7.1 |
| Aktywna subskrypcja Claude Pro lub Max | - | albo dostęp firmowy; do ustalenia **przed** szkoleniem |
| Python | **3.12** albo **3.11** | **3.13 nie zadziała** - wyjaśnienie niżej |
| git | dowolna współczesna | |
| `jq` | dowolna | **wymagane** - hooki z modułu 5 parsują nim JSON |
| `make` | dowolna | |
| Edytor | dowolny | VS Code, JetBrains, Vim - bez znaczenia |
| Terminal | - | moduł 6 wymaga **trzech** okien naraz |

### Instalacja brakujących

> **Dlaczego nie 3.13.** Repozytorium ćwiczeniowe ma **celowo przestarzałe** wersje
> zależności - to jeden z zasianych problemów, odkrywany w module 4.
> `pydantic==2.6.1` (luty 2024) nie ma gotowego pakietu dla Pythona 3.13, więc `pip`
> próbuje skompilować go z Rusta i przerywa:
>
> ```
> Failed to build installable wheels for some pyproject.toml based projects
> ╰─> pydantic-core
> ```
>
> To nie jest usterka materiałów - to jest **koszt niemigrowania zależności**, ten sam,
> o którym mówi moduł 4. Sprawdzone: **3.11 i 3.12 działają** (116 testów zielonych),
> **3.13 nie**.

**macOS:**
```bash
brew install python@3.12 jq
xcode-select --install          # daje make i git
```

**Ubuntu / Debian / WSL:**
```bash
sudo apt update
sudo apt install python3.12 python3.12-venv jq make git
```

> Na Ubuntu 25.04 i Debianie 13 (domyślnie Python 3.13) pakietu `python3.12` może nie być
> w repozytoriach. Wtedy `sudo add-apt-repository ppa:deadsnakes/ppa` przed instalacją -
> albo `python3.11`, jeśli jest dostępny.

**Claude Code:** https://claude.com/claude-code

> **Windows:** kurs zakłada powłokę POSIX. Praca odbywa się w **WSL2**, nie w PowerShellu.
> Hooki z modułu 5 są skryptami bashowymi. Komendy w materiałach są w wariancie
> macOS/Linux; miejsca, w których WSL wymaga uwagi, są zaznaczone.

---

## 2. Sprawdzenie, że Claude Code działa

```bash
claude --version
```

Wersja musi być **2.1.251 lub nowsza**. Starsza wymaga aktualizacji.

Uruchomić w dowolnym katalogu i zamknąć:

```bash
claude
```

```
/status
```

Ma pokazać zalogowane konto i model. Przy braku zalogowania - `/login`.

> Claude Code uruchamiany w firmie przez Bedrock, Vertex albo bramkę firmową wymaga
> **ustalenia przed szkoleniem**. Część ćwiczeń z modułu 7 zachowuje się inaczej
> na kluczu API niż na subskrypcji - w materiałach jest to opisane, ale rodzaj
> dostępu warto znać z góry.

---

## 3. Klonowanie repozytorium ćwiczeniowego

Materiały i repozytorium ćwiczeniowe są w **jednym klonie** - repozytorium ćwiczeniowe
jest podłączone jako submoduł.

```bash
git clone --recurse-submodules https://github.com/marianwitkowski/kurs-ai-assisted-development.git
cd kurs-ai-assisted-development
```

> **Klonowanie bez `--recurse-submodules`** zostawia katalog `repo-cwiczeniowe/` **pusty**.
> To najczęstszy błąd przy pierwszym klonowaniu. Naprawa bez klonowania od nowa:
>
> ```bash
> git submodule update --init --recursive
> ```

Sprawdzenie, czy repozytorium ćwiczeniowe pobrało się wraz z tagami:

```bash
cd repo-cwiczeniowe
git fetch --tags
git tag | head -20
```

Powinno pokazać **17 tagów** zaczynających się od `lab-`. Pusty katalog albo brak tagów
oznacza konieczność naprawy opisanej powyżej.

---

## 4. Środowisko Pythona

```bash
python3.12 -m venv .venv          # albo python3.11
source .venv/bin/activate
pip install -r requirements.txt
python seed.py
```

`seed.py` odtwarza bazę `rozliczenia.db` od zera - deterministycznie, więc u wszystkich
będzie identyczna.

> **Środowisko wymaga aktywacji w każdym nowym terminalu, przed uruchomieniem `claude`.**
>
> ```bash
> source .venv/bin/activate
> ```
>
> Od modułu 5 hook bramki uruchamia `make gate`, a `Makefile` woła gołe `ruff` i `pytest`.
> Hook dziedziczy `PATH` po procesie, który uruchomił Claude Code - bez aktywowanego
> środowiska bramka będzie czerwona z powodu „command not found", a nie z powodu kodu.

---

## 5. Test środowiska

Skrypt leży w katalogu materiałów i sam wchodzi do `repo-cwiczeniowe/`, więc uruchamia się
z obu miejsc:

```bash
./sprawdz-srodowisko.sh          # z katalogu materiałów
../sprawdz-srodowisko.sh         # albo z repo-cwiczeniowe/
```

Skrypt wypisze raport. **Każda linia `BLAD` wymaga reakcji przed szkoleniem.**
Linie `OSTRZEZ` oznaczają, że zadziała, ale część ćwiczeń będzie ograniczona.
Linia `INFO` w sekcji „Slajdy" dotyczy wyłącznie prowadzącego - uczestnik nie buduje
decków i brak Node'a niczego mu nie blokuje.

Oczekiwany wynik na czystym środowisku:

```
Podsumowanie
  bledow: 0, ostrzezen: 0

Srodowisko gotowe.
```

---

## 6. Sprawdzenie, że aplikacja wstaje

```bash
.venv/bin/python -m uvicorn app.main:app --port 8000
```

W drugim terminalu:

```bash
curl -s localhost:8000/zdrowie
curl -s -H "Authorization: Bearer tok-gamma" "localhost:8000/faktury/1/rozliczenie" | head -c 300
```

Zatrzymanie serwera: `Ctrl+C`. Do samych ćwiczeń nie jest potrzebny - laby używają głównie
`pytest` i klienta testowego - ale warto wiedzieć, że działa.

---

## 7. Warunki pracy

To nie jest formalność. Kurs zakłada **minimum 60% czasu przy klawiaturze**.

- **Trzy okna terminala** - moduł 6 to praca w trzech katalogach naraz.
- **Uprawnienia do instalacji** - blokadę `brew`/`apt` na firmowym laptopie
  trzeba zdjąć teraz, nie w trakcie.
- **Dostęp do internetu** bez blokady na `api.anthropic.com`.
- **Ciągłość pracy.** Laby są sekwencyjne: każdy startuje ze stanu, w którym zakończył się
  poprzedni. Tag odtwarza stan techniczny pominiętego labu, więc następny da się uruchomić -
  ale nie zastąpi tego, czego lab uczył. Przy pomijaniu warto przeczytać rozwiązanie.

---

## Czego **nie** trzeba robić

- Nie trzeba czytać materiałów przed szkoleniem.
- Nie trzeba znać tego repozytorium - poznanie go jest częścią modułu 1.
- Nie trzeba instalować `anthropic` ani mieć klucza API. Skrypty z modułu 7,
  które go wymagają, uruchamia się później w firmie.

## Czego kurs wymaga na wejściu

- Pracy z gitem: branch, commit, diff, merge, rozwiązanie konfliktu.
- Czytania cudzego kodu i uczestnictwa w code review.
- Uruchomienia testów w swoim projekcie.
- Uruchomienia Claude Code albo porównywalnego agenta **przynajmniej kilka razy**.

Niespełniony ostatni punkt wymaga zgłoszenia przed szkoleniem. Istnieje
osobny termin w wersji „Foundations" i lepiej zacząć od niego.

---

## Jeśli coś nie działa

Zgłoszenie przed szkoleniem, z wynikiem:

```bash
../sprawdz-srodowisko.sh 2>&1 | tail -30
```

Problem z instalacją rozwiązany przed kursem nie zabiera uwagi w trakcie pierwszego labu.
