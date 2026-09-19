# Lab 6.2 - Subagent z izolacją i budżetem

**Czas: ~20 min** · **Tag startowy: `lab-6-2-start`** · **Produkt: `.claude/agents/migrator.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-6-2-start
make gate          # 47 testów zielonych, 0 ostrzeżeń
cat .claude/settings.local.json     # ma zawierać worktree.baseRef
```

> **Warunek startowy, o którym łatwo zapomnieć.** Subagent z `isolation: worktree` używa
> tej samej gałęzi bazowej co `claude --worktree` - czyli domyślnej gałęzi zdalnego
> repozytorium, chyba że `worktree.baseRef` jest ustawiony na `"head"`.
>
> To ustawienie powstało w labie 6.1, w pliku `.claude/settings.local.json`,
> który jest **nieśledzony** - `git checkout lab-6-2-start` go nie przyniesie.
> Jeśli robiłeś checkout albo `git stash -u` po labie 6.1, odtwórz je:
>
> ```bash
> echo '{"worktree": {"baseRef": "head"}}' > .claude/settings.local.json
> ```
>
> Bez tego migrator dostanie worktree ze **stanu z modułu 1**: bez `tests/`,
> bez `CLAUDE.md`, bez celu `gate` w `Makefile`. Zaraportuje `BRAMKA: czerwona`
> z komunikatem `No rule to make target 'gate'` - a ty tego nie zobaczysz w trakcie,
> bo subagenta nie widać.

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-6-1"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-6-2`
> **przed** skokiem.

---

## Cel

Zapisać w repozytorium subagenta wielokrotnego użytku - z izolacją, budżetem tur
i narzuconym formatem wyniku. I sprawdzić na własne oczy, co naprawdę wraca
do sesji głównej.

---

## Krok 1 - definicja (7 min)

```
Utwórz .claude/agents/migrator.md - subagenta do mechanicznych przekształceń
w wielu plikach naraz.

Frontmatter:
- name: migrator
- description: kiedy po niego sięgać i - to ważne - do czego NIE służy
- tools: tylko to, czego potrzebuje
- model: sonnet (zadanie jest mechaniczne, nie wymaga rozumowania)
- isolation: worktree
- maxTurns: 25

Treść ma wymuszać kolejność: inwentaryzacja → klasyfikacja (mechaniczne vs
wymagające decyzji) → zmiana → make gate.

Zasady: nic poza zakresem, żadnych poprawek przy okazji, nie modyfikować testów,
żeby przechodziły, nie dodawać zależności.
```

Dwa pola, które decydują o tym, czy ten agent jest bezpieczny:

**`isolation: worktree`** - agent pracuje we własnym, tymczasowym katalogu.
Jeśli zrobi coś głupiego, twój checkout jest nietknięty. Worktree bez zmian znika
automatycznie po zakończeniu.

**`maxTurns: 25`** - twardy limit. Subagenta **nie widzisz w trakcie pracy**.
Sesję główną przerwiesz `Esc`; subagent bez limitu tur zużyje budżet i wróci
ze streszczeniem, którego nie da się użyć.

---

## Krok 2 - format wyniku (5 min)

Subagent zwraca to, co uzna za stosowne, chyba że mu powiesz. Dopisz do treści:

```
ZAKRES: <co miało być zmienione>
ZMIENIONE: <liczba> wystąpień w <liczba> plikach
  - ścieżka:linia - opis zmiany
POMINIĘTE: <co wymaga decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ pierwsze 5 linii błędu)
RYZYKA: <co może się zepsuć, czego nie sprawdziłem>
```

Plus: **limit 40 linii**.

**Sekcja `POMINIĘTE` jest najważniejsza.** To jest jedyne miejsce, w którym subagent
ma prawo powiedzieć „tego nie ruszyłem, bo wymaga decyzji" - i jedyne, które chroni
przed cichym rozstrzygnięciem. Bez niej agent albo zrobi wszystko po swojemu,
albo zatrzyma się w pół drogi bez wyjaśnienia.

**Limit długości** jest drugi w kolejności. Bez niego dostaniesz streszczenie,
które jest transkryptem w przebraniu - i cały zysk kontekstowy znika.

---

## Krok 3 - uruchomienie (5 min)

Zmierz kontekst przed:

```
/context
```

Uruchom agenta na realnym zadaniu:

```
Użyj subagenta migrator: w app/ zamień wszystkie wystąpienia
`from decimal import Decimal` na import z jawną kolejnością alfabetyczną
w bloku importów, zgodnie z ruff isort. Nic więcej nie zmieniaj.
```

> Jeśli `ruff` już to wymusił i nie ma czego zmieniać - tym lepiej. Zobaczysz raport
> z zerem zmian i sekcją `POMINIĘTE`, co jest równie pouczające.

Zmierz kontekst po:

```
/context
```

**Porównaj przyrost z tym, ile plików agent musiał przeczytać.** Subagent startuje
z pustym kontekstem, czyta u siebie, a do ciebie wraca kilkanaście linii streszczenia.
To jest jego cała wartość.

---

## Krok 4 - co wróciło, a co zostało (3 min)

Odpowiedz sobie:

- Czy widzisz, **które pliki** agent przeczytał? (nie - to zostało w jego kontekście)
- Czy widzisz **wynik** jego pracy? (tak - w streszczeniu i w diffie)
- Czy widzisz, **jak** doszedł do wyniku? (nie)
- Czy to jest problem?

Odpowiedź na ostatnie pytanie brzmi: **zależy od zadania.** Przy przekształceniu
mechanicznym - nie, liczy się diff. Przy zadaniu wymagającym decyzji - tak,
i dlatego takich zadań nie zleca się subagentowi.

To jest kryterium wyboru: **subagent do zadań, które ocenisz po wyniku.
Sesja główna do zadań, w których musisz widzieć drogę.**

```bash
git add .claude/agents/
git commit -m "Subagent migrator z izolacja w worktree"
```

---

## Kryteria zaliczenia

- [ ] `.claude/agents/migrator.md` jest w repo i ma poprawny frontmatter.
- [ ] `description` mówi też, do czego agent **nie** służy.
- [ ] Ma `isolation: worktree` i `maxTurns`.
- [ ] Format wyniku jest narzucony, z sekcją `POMINIĘTE` i limitem długości.
- [ ] Uruchomiłeś go i porównałeś `/context` przed i po.
- [ ] Umiesz powiedzieć, kiedy zadanie nadaje się dla subagenta, a kiedy nie.

## Pułapki

**Subagent bez `maxTurns`.** Nie widzisz go w trakcie. Limit tur jest jedynym
mechanizmem, który zatrzyma pętlę, zanim zje budżet.

**`description` mówiące tylko, co agent robi.** Model czyta ten opis, decydując,
czy sięgnąć po agenta samodzielnie. Zdanie o tym, do czego agent **nie** służy,
jest równie ważne - bez niego dostaniesz migratora przy zadaniu wymagającym decyzji
projektowej.

**Zlecenie subagentowi zadania wymagającego decyzji.** Wróci streszczenie mówiące,
że zdecydował - bez pokazania, na jakiej podstawie. Takie zadania zostają w sesji głównej.

**Brak limitu długości wyniku.** Streszczenie na trzysta linii nie jest streszczeniem.
Cały sens subagenta polega na tym, że gadatliwe wyjście **zostaje u niego**.

**`tools` odziedziczone w całości.** Agent do przekształceń mechanicznych nie potrzebuje
`WebFetch` ani `Task`. Zawężenie listy to nie paranoja, tylko mniejszy kontekst
i mniej sposobów na zboczenie z kursu.

---

[Rozwiązanie wzorcowe](rozwiazanie-6-2.md) · [Checklista modułu](checklista.md)
