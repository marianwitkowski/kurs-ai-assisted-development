# Rozwiązanie wzorcowe - lab 6.1

```bash
git log --oneline --graph lab-6-1-start..lab-6-2-start
git diff --stat lab-6-1-start lab-6-2-start
```

```
 app/platnosci.py     |   4 +-
 app/powiadomienia.py |   4 +-
 app/rabaty.py        |  16 ++++++-
 app/raporty.py       |   6 +--
 docs/api.md          | 115 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/test_rabaty.py |  87 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 223 insertions(+), 9 deletions(-)
```

Trzy branche, jeden konflikt, 47 testów zielonych, zero ostrzeżeń.

---

## Dlaczego ten podział działa

| Zadanie | Pliki | Nakłada się z |
|---|---|---|
| A - testy + docstringi | `tests/test_rabaty.py` (nowy), `app/rabaty.py` | **C** |
| B - dokumentacja | `docs/api.md` (nowy) | niczym |
| C - migracja `utcnow()` | `app/rabaty.py`, `raporty.py`, `powiadomienia.py`, `platnosci.py` | **A** |

Dwa z trzech zadań tworzą **nowe pliki** - te nie mogą się skonfliktować z niczym.
Nakładanie jest dokładnie jedno i wiadomo o nim przed startem.

To jest wzorzec, który przenosi się do realnej pracy: **gdy da się podzielić tak,
żeby większość zadań tworzyła nowe pliki, tak właśnie należy podzielić.**

---

## Konflikt: jedna linia

```
<<<<<<< HEAD
    dzis = datetime.utcnow().date()  # zaleznosc od zegara: docs/mapa-ryzyka.md, poz. 7
=======
    dzis = datetime.now(UTC).date()
>>>>>>> worktree-zadanie-c
```

Rozwiązanie:

```python
    dzis = datetime.now(UTC).date()  # zaleznosc od zegara: docs/mapa-ryzyka.md, poz. 7
```

**Obie zmiany są potrzebne.** A dodał komentarz wyjaśniający, dlaczego ta linia jest
problemem architektonicznym. C zmienił samo wywołanie. Komentarz pozostaje prawdziwy
po migracji - `datetime.now(UTC)` nadal czyta zegar.

`git checkout --ours` albo `--theirs` skasowałoby połowę pracy i przeszłoby przez bramkę,
bo testy nie sprawdzają komentarzy.

### Czego git nie zgłosił

Linia importu zmieniła się **tylko w C**:

```python
from datetime import datetime          # przed
from datetime import UTC, datetime     # po
```

Scaliła się automatycznie. To jest normalne i warto to zauważyć: git konfliktuje
na **nakładających się zmianach**, nie na „tym samym pliku".

### Dlaczego ten konflikt był pewny

Zadanie A prosi wprost o **komentarz w linii z `utcnow()`**. Gdyby A dodał tylko docstring
pod `def`, git scaliłby oba branche bez konfliktu - zmiany byłyby oddalone o kilka linii.

Konflikt powstaje, gdy dwie strony zmieniają **tę samą linię albo linie sąsiadujące**.
To jest przydatna wiedza przy planowaniu podziału: „dotykają tego samego pliku"
to za mało, żeby przewidzieć konflikt.

---

## Kryterium akceptacji migracji: 4 → 0

```bash
pytest -q 2>&1 | tail -1
# przed:  32 passed, 4 warnings
# po:     47 passed
```

Cztery `DeprecationWarning` z `datetime.utcnow()` znikają. To jest **sprawdzalne jedną
komendą** i dlatego jest dobrym kryterium akceptacji - w przeciwieństwie do
„migracja została wykonana poprawnie".

Drugie kryterium, równie tanie:

```bash
grep -rn "utcnow" app/ || echo "brak"
```

Każda migracja powinna mieć takie dwa zdania: **co ma zniknąć** i **co ma się pojawić**,
oba sprawdzalne komendą.

---

## Klasyfikacja w zadaniu C - czego szukać w odpowiedzi

Poprawna klasyfikacja **pięciu** wystąpień w czterech plikach:

| Wystąpienie | Kontekst | Zamiana równoważna? |
|---|---|---|
| `app/raporty.py:48` | domyślna wartość `na_dzien` w `przeterminowane()` | tak |
| `app/raporty.py:80` | domyślna wartość `na_dzien` w `noty_odsetkowe()` | tak |
| `app/powiadomienia.py:53` | domyślna wartość `na_dzien` | tak |
| `app/platnosci.py:32` | domyślna data wpłaty | tak |
| `app/rabaty.py:29` | **decyzja o cenie pozycji na fakturze** | tak, **ale to nie rozwiązuje problemu** |

Dwa pierwsze wiersze: **jeden plik, dwa wystąpienia**. Agent, który
odpowie „cztery", policzył pliki. `app/raporty.py:80` przyszło z labu 3.2 -
czyli z pracy uczestnika, nie z kodu startowego.

We wszystkich pięciu wynik trafia od razu do `.date()`, więc różnica między obiektem
ze strefą a bez strefy nie ma znaczenia. **Zamiana jest równoważna wszędzie.**

Ale w `app/rabaty.py` problemem nie jest `utcnow()` - problemem jest to, że przeliczenie
faktury w ogóle czyta zegar. Po migracji to nadal jest prawdą. Prawdziwa poprawka
to wstrzyknięcie daty jako parametru, czyli zmiana sygnatury, czyli zmiana zachowania,
czyli osobne zadanie z testami.

Wzorcowy komunikat commita mówi to wprost:

> W trzech miejscach to domyslna wartosc parametru i zamiana jest rownowazna.
> W app/rabaty.py wynik trafia od razu do .date(), wiec zamiana tez jest rownowazna -
> ale nie usuwa glebszego problemu: przeliczenie faktury nadal zalezy od zegara.

Agent, który odpowiedział „wszystkie cztery to prosta zamiana", ma rację technicznie
i pominął to, co istotne.

---

## Rachunek uczciwy

Praca w tym labie rozkłada się tak:

| Etap | Udział |
|---|---|
| Przygotowanie trzech worktree i środowisk | ~1/8 |
| Trzy zadania równolegle | ~1/2 |
| Scalanie + konflikt | ~1/4 |
| Sprzątanie | ~1/8 |

Cztery pozycje, z których **tylko jedna jest właściwą pracą**. Pozostałe trzy to narzut,
którego przy wykonaniu sekwencyjnym nie ma prawie wcale.

**Przy tej skali równoległość się nie opłaciła** - wyszła drożej niż to samo zrobione
po kolei. Narzut jest stały, a zadania są zbyt małe, żeby go pokryć.

Kiedy się opłaca:

- gdy **samo wczytanie się w kod** każdego zadania jest kosztowne (wtedy narzut rozkłada
  się na coś, co go pokrywa),
- gdy zadania są długie i niezależne (migracja w pięciu modułach),
- gdy izolacja jest i tak potrzebna (eksperyment, który nie ma trafić do głównego checkoutu).

Kiedy się nie opłaca:

- trzy krótkie zadania, jak w tym labie,
- zadania dotykające tych samych plików,
- gdy nie da się z góry wskazać, gdzie będzie konflikt.

**Wiedza, kiedy tego nie robić, jest tu warta tyle samo co umiejętność zrobienia tego.**

---

## Najczęstsze potknięcia

**Worktree bez środowiska.** Pierwsze `make test` kończy się błędem na braku `.venv`.
To nie jest awaria - to jest właściwość świeżego checkoutu. Do rozwiązania raz,
świadomie: instalacja per worktree, `PATH` do wspólnego interpretera albo `.worktreeinclude`.

**Scalanie w przypadkowej kolejności.** Od najmniejszego zasięgu. B (nowy plik) → A
(nowy plik + jedna linia) → C (cztery pliki). Wtedy konflikt dotyczy jednego pliku.

**Rozwiązanie konfliktu przez wybór strony.** Szybkie i kasuje pracę.
Konflikt w jednej linii zawsze warto przeczytać.

**Porzucone worktree.** `git worktree list` po zakończeniu pracy ma być odruchem.
Po tygodniu nikt nie pamięta, co było w `zadanie-c`, a branch blokuje sprzątanie.

**Hook bramki testujący główny checkout.** Jeśli `bramka.sh` z labu 5.1 używa
`${CLAUDE_PROJECT_DIR}` zamiast `cwd`, w worktree testuje nie ten katalog -
i świeci na zielono dla kodu, którego nikt nie zmienił. To jest najgroźniejszy błąd
z tego labu, bo wygląda jak sukces.
