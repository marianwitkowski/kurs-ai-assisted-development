# Przygotowanie przed szkoleniem

> **Zrób to najpóźniej na dwa dni przed szkoleniem.** Pierwsza godzina dnia 1 jest
> na pracę z kodem, nie na instalację. Jeżeli coś nie zadziała, będziesz mieć czas
> to rozwiązać.

Całość zajmuje **15-20 minut**, z czego większość to czekanie na pobieranie.

---

## 1. Co musisz mieć

| Narzędzie | Wersja | Uwagi |
|---|---|---|
| **Claude Code** | **2.1.251 lub nowsza** | starsze nie mają statystyk prompt cache, których używamy w labie 7.1 |
| Aktywna subskrypcja Claude Pro lub Max | - | albo dostęp firmowy; ustal to **przed** szkoleniem |
| Python | **3.12** albo **3.11** | **3.13 nie zadziała** - wyjaśnienie niżej |
| git | dowolna współczesna | |
| `jq` | dowolna | **wymagane** - hooki z modułu 5 parsują nim JSON |
| `make` | dowolna | |
| Edytor | dowolny | VS Code, JetBrains, Vim - bez znaczenia |
| Terminal | - | będziesz potrzebować **trzech** okien naraz w module 6 |

### Instalacja brakujących

> **Dlaczego nie 3.13.** Repozytorium ćwiczeniowe ma **celowo przestarzałe** wersje
> zależności - to jeden z zasianych problemów, który odkryjesz w module 4.
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

> **Windows:** kurs zakłada powłokę POSIX. Pracuj w **WSL2**, nie w PowerShellu.
> Hooki z modułu 5 są skryptami bashowymi. Komendy w materiałach są w wariancie
> macOS/Linux; miejsca, w których WSL wymaga uwagi, są zaznaczone.

---

## 2. Sprawdź, że Claude Code działa

```bash
claude --version
```

Wersja musi być **2.1.251 lub nowsza**. Jeżeli nie - zaktualizuj.

Uruchom w dowolnym katalogu i zamknij:

```bash
claude
```

```
/status
```

Ma pokazać zalogowane konto i model. Jeżeli nie jesteś zalogowany - `/login`.

> Jeżeli w twojej firmie Claude Code chodzi przez Bedrock, Vertex albo bramkę firmową,
> **ustal to przed szkoleniem**. Część ćwiczeń z modułu 7 zachowuje się inaczej
> na kluczu API niż na subskrypcji - w materiałach jest to opisane, ale lepiej
> wiedzieć z góry, na czym pracujesz.

---

## 3. Sklonuj repozytorium ćwiczeniowe

Materiały i repozytorium ćwiczeniowe są w **jednym klonie** - repozytorium ćwiczeniowe
jest podłączone jako submoduł.

```bash
git clone --recurse-submodules <ADRES-REPOZYTORIUM-KURSU>
cd kurs-ai-assisted-development
```

> **Zapomniałeś `--recurse-submodules`?** Katalog `repo-cwiczeniowe/` będzie **pusty**.
> To jest najczęstszy błąd przy pierwszym klonowaniu. Ratunek bez klonowania od nowa:
>
> ```bash
> git submodule update --init --recursive
> ```

Sprawdź, że repozytorium ćwiczeniowe się pobrało wraz z tagami:

```bash
cd repo-cwiczeniowe
git fetch --tags
git tag | head -20
```

Powinno pokazać **17 tagów** zaczynających się od `lab-`. Jeżeli katalog jest pusty
albo tagów nie ma - wróć do ratunku powyżej.

---

## 4. Przygotuj środowisko Pythona

```bash
python3.12 -m venv .venv          # albo python3.11
source .venv/bin/activate
pip install -r requirements.txt
python seed.py
```

`seed.py` odtwarza bazę `rozliczenia.db` od zera - deterministycznie, więc u wszystkich
będzie identyczna.

> **Aktywuj środowisko w każdym nowym terminalu, zanim uruchomisz `claude`.**
>
> ```bash
> source .venv/bin/activate
> ```
>
> Od modułu 5 hook bramki uruchamia `make gate`, a `Makefile` woła gołe `ruff` i `pytest`.
> Hook dziedziczy `PATH` po procesie, który uruchomił Claude Code - bez aktywowanego
> środowiska bramka będzie czerwona z powodu „command not found", a nie z powodu kodu.

---

## 5. Uruchom test środowiska

```bash
../sprawdz-srodowisko.sh
```

Skrypt wypisze raport. **Każda linia `BLAD` wymaga reakcji przed szkoleniem.**
Linie `OSTRZEZ` oznaczają, że zadziała, ale część ćwiczeń będzie ograniczona.

Oczekiwany wynik na czystym środowisku:

```
Podsumowanie
  bledow: 0, ostrzezen: 0

Wszystko gotowe. Do zobaczenia na szkoleniu.
```

---

## 6. Sprawdź, że aplikacja wstaje

```bash
.venv/bin/python -m uvicorn app.main:app --port 8000
```

W drugim terminalu:

```bash
curl -s localhost:8000/zdrowie
curl -s -H "Authorization: Bearer tok-gamma" "localhost:8000/faktury/1/rozliczenie" | head -c 300
```

Zatrzymaj serwer (`Ctrl+C`). Do samych ćwiczeń nie jest potrzebny - używamy głównie
`pytest` i klienta testowego - ale dobrze wiedzieć, że działa.

---

## 7. Zarezerwuj sobie warunki pracy

To nie jest formalność. Kurs zakłada **minimum 60% czasu przy klawiaturze**.

- **Trzy okna terminala** - w module 6 pracujesz w trzech katalogach naraz.
- **Uprawnienia do instalacji** - jeżeli firmowy laptop blokuje `brew`/`apt`,
  załatw to teraz, nie w trakcie.
- **Dostęp do internetu** bez blokady na `api.anthropic.com`.
- **Brak konfliktu w kalendarzu.** Moduł, który przegapisz, blokuje kolejny -
  laby są sekwencyjne.

---

## Czego **nie** musisz robić

- Nie musisz czytać materiałów przed szkoleniem.
- Nie musisz znać tego repozytorium - poznanie go jest częścią modułu 1.
- Nie musisz instalować `anthropic` ani mieć klucza API. Skrypty z modułu 7,
  które go wymagają, uruchamiasz później w firmie.

## Czego oczekujemy, że już umiesz

- Pracy z gitem: branch, commit, diff, merge, rozwiązanie konfliktu.
- Czytania cudzego kodu i uczestnictwa w code review.
- Uruchomienia testów w swoim projekcie.
- Uruchomienia Claude Code albo porównywalnego agenta **przynajmniej kilka razy**.

Jeżeli ostatni punkt cię nie dotyczy - powiedz o tym przed szkoleniem. Istnieje
osobny termin w wersji „Foundations" i lepiej zacząć od niego.

---

## Jeśli coś nie działa

Napisz przed szkoleniem, z wynikiem:

```bash
../sprawdz-srodowisko.sh 2>&1 | tail -30
```

Rozwiązanie problemu z instalacją zajmuje pięć minut w poniedziałek i godzinę
na sali, gdzie czeka dwanaście osób.
