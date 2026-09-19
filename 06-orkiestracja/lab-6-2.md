# Lab 6.2 - Subagent z izolacją i budżetem

**Tag startowy: `lab-6-2-start`** · **Produkt: `.claude/agents/migrator.md`**

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
> Po checkoucie albo `git stash -u` wykonanym po labie 6.1 trzeba je odtworzyć:
>
> ```bash
> echo '{"worktree": {"baseRef": "head"}}' > .claude/settings.local.json
> ```
>
> Bez tego migrator dostanie worktree ze **stanu z modułu 1**: bez `tests/`,
> bez `CLAUDE.md`, bez celu `gate` w `Makefile`. Zaraportuje `BRAMKA: czerwona`
> z komunikatem `No rule to make target 'gate'` - i wyjdzie to dopiero na końcu,
> bo subagenta nie widać w trakcie.

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-6-1"
> ```
>
> Powrót do niej: `git stash list` i `git stash apply stash@{0}`.
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
i narzuconym formatem wyniku. I sprawdzić, co naprawdę wraca do sesji głównej.

---

## Krok 1 - definicja

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
Przy błędnym działaniu agenta główny checkout zostaje nietknięty. Worktree bez zmian
znika automatycznie po zakończeniu.

**`maxTurns: 25`** - twardy limit. Subagenta **nie widać w trakcie pracy**.
Sesję główną przerywa `Esc`; subagent bez limitu tur zużyje budżet i wróci
ze streszczeniem, którego nie da się użyć.

---

## Krok 2 - format wyniku

Bez narzuconego formatu subagent zwraca to, co uzna za stosowne. Do treści agenta trafia:

```
ZAKRES: <co miało być zmienione>
ZMIENIONE: <liczba> wystąpień w <liczba> plikach
  - ścieżka:linia - opis zmiany
POMINIĘTE: <co wymaga decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ pierwsze 5 linii błędu)
RYZYKA: <co może się zepsuć, czego nie sprawdziłem>
```

Do tego **limit 40 linii**.

**Sekcja `POMINIĘTE` jest najważniejsza.** To jest jedyne miejsce, w którym subagent
ma prawo powiedzieć „tego nie ruszyłem, bo wymaga decyzji" - i jedyne, które chroni
przed cichym rozstrzygnięciem. Bez niej agent albo zrobi wszystko po swojemu,
albo zatrzyma się w pół drogi bez wyjaśnienia.

**Limit długości** jest drugi w kolejności. Bez niego streszczenie jest transkryptem
w przebraniu, a cały zysk kontekstowy znika.

---

## Krok 3 - uruchomienie

Pomiar kontekstu przed:

```
/context
```

Uruchomienie agenta na realnym zadaniu:

```
Użyj subagenta migrator: w app/ zamień wszystkie wystąpienia
`from decimal import Decimal` na import z jawną kolejnością alfabetyczną
w bloku importów, zgodnie z ruff isort. Nic więcej nie zmieniaj.
```

> Gdy `ruff` już to wymusił i nie ma czego zmieniać - tym lepiej. Raport przyjdzie
> z zerem zmian i sekcją `POMINIĘTE`, co jest równie pouczające.

Pomiar kontekstu po:

```
/context
```

**Przyrost warto porównać z liczbą plików, które agent musiał przeczytać.** Subagent
startuje z pustym kontekstem, czyta u siebie, a do sesji głównej wraca kilkanaście linii
streszczenia. To jest jego cała wartość.

---

## Krok 4 - co wróciło, a co zostało

Widoczność po stronie sesji głównej:

- **które pliki** agent przeczytał - nie widać, to zostało w jego kontekście,
- **wynik** jego pracy - widać, w streszczeniu i w diffie,
- **jak** doszedł do wyniku - nie widać.

Czy to jest problem: **zależy od zadania.** Przy przekształceniu mechanicznym - nie,
liczy się diff. Przy zadaniu wymagającym decyzji - tak, i dlatego takich zadań
nie zleca się subagentowi.

To jest kryterium wyboru: **subagent do zadań ocenianych po wyniku.
Sesja główna do zadań, w których trzeba widzieć drogę.**

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
- [ ] Agent uruchomiony, `/context` porównany przed i po.
- [ ] Rozstrzygnięte, kiedy zadanie nadaje się dla subagenta, a kiedy nie.

## Pułapki

**Subagent bez `maxTurns`.** W trakcie pracy nie widać go wcale. Limit tur jest jedynym
mechanizmem, który zatrzyma pętlę, zanim zje budżet.

**`description` mówiące tylko, co agent robi.** Model czyta ten opis, decydując,
czy sięgnąć po agenta samodzielnie. Zdanie o tym, do czego agent **nie** służy,
jest równie ważne - bez niego migrator trafi do zadania wymagającego decyzji
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
