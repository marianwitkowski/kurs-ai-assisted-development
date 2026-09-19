# Lab 6.1 - Trzy worktree, trzy zadania, jeden konflikt

**Czas: ~60 min** · **Tag startowy: `lab-6-1-start`** · **Produkt: trzy scalone branche, rozwiązany konflikt, czysty `git worktree list`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-6-1-start
make gate            # zielone: 32 testy, lint czysty
pytest -q 2>&1 | tail -1     # zapisz liczbę ostrzeżeń - wrócisz do niej na końcu
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-5-2"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.
>
> **Ten lab kończy się commitem, a `git checkout <tag>` stawia repozytorium
> w odpiętym `HEAD`.** Commit nie należy wtedy do żadnej gałęzi i przy skoku
> na kolejny tag przestaje być osiągalny. Git ostrzeże o tym po angielsku
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-6-1`
> **przed** skokiem.

---

## Cel

Puścić trzy niezależne zadania równolegle, w izolowanych katalogach, scalić je
i rozwiązać **zaplanowany** konflikt. Plus zobaczyć, co worktree kosztuje w praktyce.

---

## Podział pracy

| Zadanie | Co robi | Które pliki dotyka |
|---|---|---|
| **A** | Testy jednostkowe dla `app/rabaty.py` + uzupełnienie docstringów w tym pliku | `tests/test_rabaty.py`, **`app/rabaty.py`** |
| **B** | Dokumentacja API w `docs/api.md` | `docs/api.md` |
| **C** | Migracja `datetime.utcnow()` → `datetime.now(UTC)` | **`app/rabaty.py`**, `app/raporty.py`, `app/powiadomienia.py`, `app/platnosci.py` |

**Zauważ, zanim zaczniesz: A i C dotykają tego samego pliku.** To jest celowe.
Konflikt jest zaplanowany i wiesz z góry, gdzie będzie - w `app/rabaty.py`,
w linii z `datetime.utcnow()`.

To jest cała pointa podziału: **nie unikamy konfliktu, tylko go lokalizujemy.**

---

## Krok 1 - trzy worktree (7 min)

**Najpierw jedno ustawienie.** Domyślnie Claude Code tworzy worktree z **domyślnej gałęzi
zdalnego repozytorium** (`worktree.baseRef: "fresh"`). W tym repozytorium `origin/main`
wskazuje **stan startowy z modułu 1** - a ty stoisz sześć modułów dalej, na tagu
`lab-6-1-start`.

Worktree utworzony z `main` nie miałby ani `CLAUDE.md`, ani testów, ani hooków, ani skilla.
`make gate` w nim nie przejdzie, bo nie ma czego uruchomić - a ty spędzisz kwadrans
na szukaniu, dlaczego.

```bash
echo '{"worktree": {"baseRef": "head"}}' > .claude/settings.local.json
```

> Jeśli plik już istnieje z innymi ustawieniami, **nie nadpisuj go** - scal:
> ```bash
> jq '. * {worktree: {baseRef: "head"}}' .claude/settings.local.json > /tmp/s.json \
>   && mv /tmp/s.json .claude/settings.local.json
> ```
>
> **Nie kasuj tego pliku po labie** - lab 6.2 też go potrzebuje, a jest nieśledzony,
> więc `git stash -u` i `git checkout` go zabiorą.

`"head"` każe tworzyć worktree z **bieżącego lokalnego `HEAD`** - czyli z tagu,
na którym właśnie stoisz.

`.claude/settings.local.json` jest plikiem **osobistym**: twoje ustawienia, nie zespołu.
Jest w `.gitignore` tego repozytorium, więc `git status` go nie pokaże i nie wciągnie go
żadne `git add -A`. W swoim projekcie dopisz go tam, zanim ktokolwiek zacznie go używać -
inaczej pierwsza osoba, która ustawi sobie `baseRef`, narzuci to całemu zespołowi.

> To jest realna pułapka, nie artefakt szkolenia. Zawsze gdy pracujesz na czymkolwiek
> innym niż domyślna gałąź - na branchu feature, na tagu, na cudzym pull requeście -
> `"fresh"` da ci worktree **bez tej pracy**. Domyślne zachowanie jest słuszne
> (izolowany eksperyment z czystego stanu) i dokładnie dlatego zaskakuje, gdy chcesz
> czegoś innego.

Aktywuj środowisko Pythona **przed** uruchomieniem Claude Code - hook bramki dziedziczy
`PATH` po procesie, który go uruchomił:

```bash
source .venv/bin/activate
```

Wariant wbudowany, po jednym terminalu na zadanie:

```bash
claude --worktree zadanie-a
claude --worktree zadanie-b
claude --worktree zadanie-c
```

Wariant ręczny, jeśli wolisz widzieć mechanikę:

```bash
git worktree add .claude/worktrees/zadanie-a -b worktree-zadanie-a lab-6-1-start
git worktree add .claude/worktrees/zadanie-b -b worktree-zadanie-b lab-6-1-start
git worktree add .claude/worktrees/zadanie-c -b worktree-zadanie-c lab-6-1-start
git worktree list
```

**Sprawdź, czego w nich nie ma:**

```bash
ls -a .claude/worktrees/zadanie-a | grep -E '^\.venv$|^\.env$' || echo "brak .venv i .env - świeży checkout"
```

Worktree to świeży checkout. Nie ma w nim **niczego z `.gitignore`** - ani `.venv`,
ani bazy `rozliczenia.db`.

Baza to nie problem: `Makefile` ma ją jako zależność, więc pierwszy `make test` w worktree
odtworzy ją z `seed.py`. Środowisko to problem - `.venv` nikt za ciebie nie zbuduje.

Najprostsze obejście na czas labu: użyj `.venv` z głównego checkoutu w każdym terminalu.

```bash
source /pełna/ścieżka/do/repo-cwiczeniowe/.venv/bin/activate
```

**Zrób to zanim uruchomisz `claude` w tym terminalu.** Hook bramki z labu 5.1 woła
`make gate`, a `Makefile` używa gołych `ruff` i `pytest` - bez aktywowanego środowiska
bramka zrobi się czerwona z powodu „command not found".

W realnym projekcie tę decyzję podejmuje się raz: instalacja per worktree, współdzielony
interpreter albo `.worktreeinclude` dla plików spoza gita.

---

## Krok 2 - trzy zlecenia (25 min)

Odpal je równolegle, każde w swoim terminalu.

### Zadanie A

```
Napisz tests/test_rabaty.py - testy jednostkowe dla app/rabaty.py.

Pokryj: wszystkie trzy progi Z GRANICAMI (4999.99 i 5000, 19999.99 i 20000,
49999.99 i 50000), rabat indywidualny kontrahenta, obcięcie do rabatu maksymalnego,
promocję bez okna dat, promocję z oknem zamkniętym w przeszłości, pozycję bez
ceny promocyjnej.

Dodatkowo uzupełnij docstringi w app/rabaty.py - funkcje promocja_aktywna,
stawka_rabatu i rabat_pozycji nie mają żadnych. W docstringu promocja_aktywna
napisz wprost, że funkcja czyta bieżącą datę z zegara systemowego, i dodaj
komentarz w tej linii z odwołaniem do docs/mapa-ryzyka.md.

NIE zmieniaj zachowania żadnej funkcji. make gate musi być zielone.
```

### Zadanie B

```
Napisz docs/api.md - dokumentację API tego serwisu.

Dla każdego endpointu: metoda, ścieżka, parametry, wymagany nagłówek, przykładowa
odpowiedź, kody błędów. Endpointy odczytaj z app/main.py, struktury odpowiedzi
z app/modele.py.

Dopisz sekcję "Znane ograniczenia" na podstawie tego, co faktycznie widzisz w kodzie.

NIE zmieniaj żadnego pliku poza docs/api.md.
```

### Zadanie C

```
Zmigruj wszystkie wystąpienia datetime.utcnow() na datetime.now(UTC).

Najpierw: wypisz wszystkie wystąpienia z plikami i numerami linii, policz je
i powiedz, w których zamiana jest równoważna, a w których zmienia zachowanie.
Dopiero potem zmieniaj.

Zakres: tylko ta zamiana. Żadnych poprawek przy okazji.
make gate musi być zielone, a pytest ma przestać pokazywać DeprecationWarning.
```

**W zadaniu C sprawdź odpowiedź na pierwszą część.** Poprawna klasyfikacja:
**pięć wystąpień w czterech plikach** (`app/raporty.py` ma dwa), z czego cztery to
domyślne wartości parametrów, a piąte (`app/rabaty.py`) jest wewnątrz decyzji o cenie
pozycji. Zamiana jest równoważna we wszystkich pięciu
(wynik od razu trafia do `.date()`), ale **w czwartym nie usuwa głębszego problemu**:
przeliczenie faktury nadal zależy od zegara.

Agent, który napisze „wszystkie cztery to prosta zamiana", pominął to rozróżnienie.

---

## Krok 3 - scalanie (15 min)

Wróć do głównego checkoutu. Scalaj **od najmniejszego zasięgu**:

```bash
git merge --no-edit worktree-zadanie-b     # tylko docs/api.md - czysto
git merge --no-edit worktree-zadanie-a     # tests/ + app/rabaty.py - czysto
git merge --no-edit worktree-zadanie-c     # KONFLIKT w app/rabaty.py
```

Konflikt wygląda tak:

```
<<<<<<< HEAD
    dzis = datetime.utcnow().date()  # zaleznosc od zegara: docs/mapa-ryzyka.md, poz. 7
=======
    dzis = datetime.now(UTC).date()
>>>>>>> worktree-zadanie-c
```

**Jedna linia, obie zmiany potrzebne.** Rozwiązanie: weź kod z C i komentarz z A.

Zwróć uwagę, czego git **nie** zgłosił: linia importu (`from datetime import UTC, datetime`)
scaliła się automatycznie, bo tylko C ją zmieniał.

```bash
# po rozwiązaniu
grep -rn "utcnow" app/ || echo "brak utcnow - OK"
make gate
pytest -q 2>&1 | tail -1          # ostrzeżeń ma być 0
git add app/rabaty.py && git commit --no-edit
```

**Liczba ostrzeżeń `DeprecationWarning` z 4 na 0** to twierdzenie sprawdzalne jedną komendą.
Tak wygląda kryterium akceptacji dla migracji.

---

## Krok 4 - sprzątanie (8 min)

```bash
git worktree list
git worktree remove .claude/worktrees/zadanie-a
git worktree remove .claude/worktrees/zadanie-b
git worktree remove .claude/worktrees/zadanie-c
git branch -d worktree-zadanie-a worktree-zadanie-b worktree-zadanie-c
git worktree list                 # ma zostać tylko główny checkout
```

Jeśli git odmawia usunięcia:

| Komunikat | Powód | Co zrobić |
|---|---|---|
| `contains modified or untracked files` | jest tam praca | `--force` (tracisz ją) albo najpierw scal |
| `is locked` | agent jeszcze pracuje albo sesja padła | `git worktree unlock <ścieżka>` |

> `.claude/worktrees/` jest już w `.gitignore` tego repozytorium od pierwszego commita.
> W swoim projekcie dopisz to **przed** pierwszym `--worktree`, inaczej zawartość worktree
> pojawi się jako nieśledzone pliki w głównym checkoucie.

---

## Krok 5 - rachunek

Zapisz sobie odpowiedzi:

| Pytanie | Twoja odpowiedź |
|---|---|
| Ile czasu zajęło przygotowanie trzech worktree? | |
| Ile czasu zajęło scalenie i rozwiązanie konfliktu? | |
| Ile czasu zajęłoby to samo sekwencyjnie, jedno po drugim? | |
| Czy się opłaciło? | |

**Uczciwa odpowiedź na trzy zadania tej wielkości brzmi „raczej nie".** Narzut jest stały,
a zadania są krótkie. Równoległość zaczyna się opłacać przy zadaniach, w których
samo czytanie kodu trwa kwadrans - i wtedy trzy kwadranse zamieniają się w jeden.

Wiedza, **kiedy tego nie robić**, jest tu warta tyle samo co umiejętność zrobienia tego.

---

## Kryteria zaliczenia

- [ ] Trzy worktree utworzone i trzy zadania wykonane równolegle.
- [ ] Wiedziałeś **przed** scalaniem, gdzie będzie konflikt.
- [ ] Konflikt rozwiązany tak, że obie zmiany zostały zachowane.
- [ ] `grep -rn "utcnow" app/` nic nie zwraca.
- [ ] `pytest` pokazuje **0 ostrzeżeń** (było 4).
- [ ] `make gate` zielone, 47 testów.
- [ ] `git worktree list` pokazuje tylko główny checkout, branche usunięte.
- [ ] Umiesz powiedzieć, czy w tym przypadku równoległość się opłaciła.

## Pułapki

**Praca w worktree bez środowiska.** Pierwsze `make test` w świeżym worktree wywali się
na braku `.venv`. To nie jest błąd konfiguracji - to jest właściwość worktree,
którą trzeba obsłużyć raz, świadomie.

**Scalanie w przypadkowej kolejności.** Zacznij od zadania o najmniejszym zasięgu.
Dzięki temu konflikt, gdy już przyjdzie, dotyczy jednego pliku, a nie trzech naraz.

**Rozwiązanie konfliktu przez wybór jednej strony.** `git checkout --ours` jest szybkie
i kasuje pracę drugiego zadania. Tu obie zmiany są potrzebne.

**Zapomniane worktree.** `git worktree list` po zakończeniu pracy powinno być odruchem.
Porzucone worktree trzymają branche, blokują usuwanie i po tygodniu nikt nie pamięta,
co w nich jest.

**Hook bramki testujący nie ten katalog.** Jeśli twój `bramka.sh` z labu 5.1 używa
`${CLAUDE_PROJECT_DIR}` zamiast `cwd`, w worktree testuje **główny checkout** -
i świeci na zielono dla kodu, którego nikt nie zmienił. Sprawdź to teraz.

---

[Rozwiązanie wzorcowe](rozwiazanie-6-1.md) · [Następny lab](lab-6-2.md)
