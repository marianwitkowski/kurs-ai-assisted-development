# Rozwiązanie wzorcowe - lab 5.2

```bash
git show lab-6-1-start:.claude/skills/przeglad-bezpieczenstwa/SKILL.md
git diff lab-5-2-start lab-6-1-start
```

Jeden plik, 83 linie.

---

## Krok 1 - czego dowodzi pomiar bez skilla

Prompt „przejrzyj kod pod kątem bezpieczeństwa" daje za każdym razem inny zakres.
Model sam decyduje, co przeczytać i czego szukać, więc:

- **nie wiesz, czego nie sprawdzono** - brak ustalenia wygląda jak brak problemu,
- **dwa przeglądy nie są porównywalne** - nie da się powiedzieć „ta sama checklista,
  inny wynik",
- **koszt jest nieprzewidywalny** - raz trzy pliki, raz całe repo.

Skill rozwiązuje wszystkie trzy przez jedno: **stałą listę punktów, po których trzeba przejść.**

---

## Frontmatter

```yaml
---
name: Przegląd bezpieczeństwa
description: Przegląd zmian w kodzie pod kątem bezpieczeństwa według stałej checklisty zespołu. Sprawdza wstrzyknięcia SQL, autoryzację per zasób, sekrety w kodzie, walidację danych wejściowych i wyciek danych w odpowiedziach. Zwraca raport w ustalonym formacie.
argument-hint: "[zakres, np. HEAD, staged, lab-1-1-start]"
allowed-tools: Bash(git diff *), Bash(git status *), Bash(git log *), Read, Grep, Glob
---
```

| Pole | Po co |
|---|---|
| `description` | model czyta to, decydując, czy sięgnąć po skill sam z siebie - dlatego wylicza kategorie, a nie mówi „sprawdza bezpieczeństwo" |
| `argument-hint` | podpowiedź przy wpisywaniu komendy |
| `allowed-tools` | **brak `Edit` i `Write`** - skill raportuje, nie poprawia |

Ostatni wiersz jest decyzją projektową, nie ostrożnością. Przegląd, który po drodze poprawia,
traci wartość dowodową: po zakończeniu nie wiadomo, co było w kodzie, a co skill zmienił.

**Nazwa komendy bierze się z katalogu.** `.claude/skills/przeglad-bezpieczenstwa/` daje
`/przeglad-bezpieczenstwa`, niezależnie od tego, co jest w polu `name`.

---

## Wstrzyknięcie diffa i problem czystego drzewa

````markdown
Stan roboczy w chwili wywołania:

!`git status --short`

Zmiany niezacommitowane:

!`git diff HEAD`
````

Komendy uruchamiają się **zanim model zobaczy treść skilla**. Model dostaje diff w kontekście
i nie może o nim zapomnieć ani wybrać innego zakresu.

Problem: na czystym drzewie oba bloki są puste. Jutro w module 8 wywołasz skill zaraz
po `git checkout` i dostaniesz pusty raport.

Rozwiązanie w treści skilla:

```markdown
**Jeżeli oba powyższe bloki są puste**, a użytkownik nie podał argumentu, uruchom
`git diff lab-1-1-start` i przejrzyj to. Jeżeli podał - użyj jego zakresu.
Nie przeglądaj całego repozytorium, gdy masz konkretny diff.
```

Trzy zdania, które ratują skill przed byciem bezużytecznym w najczęstszym scenariuszu.
Ostatnie zdanie jest ogranicznikiem kosztu: bez niego model przy pustym diffie
czyta całe repozytorium.

---

## Punkt, który decyduje o wartości całego skilla

```markdown
2. **Autoryzacja per zasób.** Czy dla każdego endpointu zwracającego dane sprawdzane jest,
   że zasób należy do uwierzytelnionego podmiotu? Uwierzytelnienie (kto to jest)
   to nie to samo co autoryzacja (czy wolno mu to zobaczyć). Szukaj miejsc, w których
   wynik funkcji autoryzacyjnej jest wywoływany, ale nieużywany.
```

Luka w `app/main.py:43-47` wygląda tak:

```python
def szczegoly_faktury(faktura_id: int, authorization: str | None = Header(default=None)) -> dict:
    _kontrahent_z_naglowka(authorization)      # wywołane, wynik wyrzucony
    con = db.polacz()
    try:
        faktura = db.pobierz_fakture(con, faktura_id)
```

Funkcja autoryzacyjna **jest wywołana**. Zły token daje 401. Brakuje jednego porównania:
`faktura.kontrahent_id != kontrahent_id`. Analiza statyczna tego nie złapie -
nie ma nieużywanej zmiennej, nie ma martwego kodu, jest poprawnie obsłużony wyjątek.

**Ostatnie zdanie punktu 2 jest tym, co sprawia, że skill to znajdzie.** Bez niego model
przeczyta ten kod, zobaczy wywołanie i wpisze „ok".

To jest ogólniejsza lekcja o pisaniu checklist: punkt „sprawdź autoryzację" jest
bezwartościowy. Punkt, który mówi **jak wygląda ta konkretna luka**, działa.

---

## Format raportu

Trzy elementy, każdy z osobnego powodu:

**Tabela ustaleń** - waga, punkt checklisty, `plik:linia`, opis, propozycja.
Kolumna `plik:linia` jest obowiązkowa: ustalenie bez lokalizacji nie trafia do tabeli.
To eliminuje zdania w rodzaju „walidacja danych wejściowych wydaje się niewystarczająca".

**Tabela przejścia checklisty** - siedem wierszy, każdy z wynikiem `ok` / `ZNALEZIONO` / `n/d`.
To jest jedyny sposób, żeby odróżnić „sprawdzone i czyste" od „nie sprawdzone".
Bez tej tabeli brak ustalenia wygląda tak samo jak brak sprawdzenia.

**„Czego nie sprawdzałem"** - nie może być pusta. Raport bez granic czyta się jak gwarancja.
Zdanie „nie sprawdzałem konfiguracji wdrożeniowej ani zależności tranzytywnych" zamienia
raport w to, czym jest: przeglądem konkretnego diffa.

---

## Test z kroku 6

Po dopisaniu do `app/db.py`:

```python
def szukaj_po_numerze(con, numer):
    return list(con.execute(f"SELECT * FROM faktury WHERE numer = '{numer}'"))
```

Poprawny raport zawiera:

| # | Waga | Punkt | Plik:linia | Opis |
|---|---|---|---|---|
| 1 | krytyczna | 1. Wstrzyknięcie SQL | `app/db.py:146` | f-string w zapytaniu, `numer` wstawiany bez placeholdera |

...oraz **siedem** wierszy tabeli checklisty, z `n/d` przy punktach, które tego diffa
nie dotyczą, i niepustą sekcją „Czego nie sprawdzałem".

Jeżeli twój raport ma trzy wiersze checklisty zamiast siedmiu - model „dostosował"
checklistę do diffa. Dopisz do skilla wprost: *żadnego punktu nie wolno pominąć milcząco*.

---

## Skill, hook, `CLAUDE.md` - trzy różne narzędzia

| | Kiedy działa | Kto decyduje |
|---|---|---|
| `CLAUDE.md` | zawsze, jako kontekst | model, czy zastosować |
| **Skill** | **na wywołanie** | **człowiek, że teraz** |
| Hook | przy zdarzeniu | nikt, dzieje się |

Przegląd bezpieczeństwa jest skillem, bo **decyzja „przeglądamy teraz" należy do człowieka**.
Gdyby miał się dziać zawsze przed commitem - byłby hookiem albo krokiem w CI.

Nie jest przypadkiem, że wszystkie trzy mieszkają w repozytorium. To jest ta sama teza,
co przy specyfikacji z modułu 3: **wiedza zespołu ma być wersjonowana, nie opowiadana.**

---

## Najczęstsze potknięcia

**Checklista, która „dostosowuje się do diffa".** Wtedy skill to droższy prompt.
Cała wartość jest w tym, że punkty są stałe, a pominięcie jest widoczne.

**Skill z `Edit` w `allowed-tools`.** Model poprawi po drodze i raport przestanie opisywać
stan, który zastał.

**Brak `---` w pierwszej linii.** Frontmatter musi zaczynać plik. Nawet pusta linia przed
nim sprawia, że cały blok jest treścią.

**Za ogólne punkty checklisty.** „Sprawdź, czy kod jest bezpieczny" nie jest punktem.
Punkt mówi, **jak wygląda** ta klasa problemu w tym języku i tym frameworku.

**Zapomniany przypadek pustego diffa.** Skill wywołany na czystym drzewie bez instrukcji
awaryjnej zwraca pusty raport, który wygląda jak „nic nie znaleziono".
