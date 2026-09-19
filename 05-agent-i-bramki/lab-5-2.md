# Lab 5.2 - Skill jako artefakt zespołowy

**Tag startowy: `lab-5-2-start`** · **Produkt: `.claude/skills/przeglad-bezpieczenstwa/SKILL.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-5-2-start
make gate          # zielone; hooki z labu 5.1 są w repo
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-5-1"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-5-2`
> **przed** skokiem.

---

## Cel

Zbudować `/przeglad-bezpieczenstwa` - workflow, który w module 8 faktycznie znajdzie luki
w tym repozytorium. I zrozumieć, dlaczego to musi być plik w repo, a nie prompt w notatniku.

---

## Krok 1 - dlaczego nie prompt

Zanim powstanie skill, warto zobaczyć, co zastępuje:

```
Przejrzyj kod tego serwisu pod kątem bezpieczeństwa.
```

Do zanotowania trzy rzeczy:
- ile plików przeczytał (`/context` przed i po),
- czy sprawdził **wszystkie** kategorie, czy tylko te, które rzuciły mu się w oczy,
- czy raport da się porównać z raportem kolegi.

Odpowiedź na trzecie pytanie brzmi „nie" i to jest główny problem. Dwa przeglądy
tym samym promptem dają dwa różne zakresy. Nie da się powiedzieć, czy coś zostało
sprawdzone, czy pominięte.

```
/clear
```

---

## Krok 2 - szkielet skilla

```
Utwórz .claude/skills/przeglad-bezpieczenstwa/SKILL.md.

Frontmatter (--- musi być w pierwszej linii pliku):
- name: Przegląd bezpieczeństwa
- description: kiedy po to sięgać i co to robi
- argument-hint: "[zakres, np. HEAD, staged, lab-1-1-start]"
- allowed-tools: tylko odczyt i git diff - skill ma raportować, nie poprawiać

Treść na razie pusta, dopiszemy ją w kolejnym kroku.
```

**Jedna rzecz do zapamiętania:** nazwa komendy bierze się z **nazwy katalogu**,
nie z pola `name`. Katalog `przeglad-bezpieczenstwa` daje `/przeglad-bezpieczenstwa`.
Pole `name` to tylko etykieta na liście skilli.

Sprawdzenie, czy się załadował: po wpisaniu `/przeglad` ma pojawić się podpowiedź.

---

## Krok 3 - wstrzyknięcie diffa

To jest mechanizm, który odróżnia skill od wklejonego promptu.

````markdown
Stan roboczy w chwili wywołania:

!`git status --short`

Zmiany niezacommitowane:

!`git diff HEAD`
````

Komenda w `` !`…` `` uruchamia się **zanim model zobaczy treść skilla**, a jej wynik
podmienia placeholder w miejscu. Model dostaje gotowy diff w kontekście - nie musi
po niego sięgać i nie może o nim zapomnieć.

### Problem, który trzeba rozwiązać

Na czystym drzewie `git diff HEAD` jest pusty. Skill nie ma czego przeglądać.

Treść skilla wymaga instrukcji na ten przypadek:

```markdown
**Jeżeli oba powyższe bloki są puste**, a użytkownik nie podał argumentu, uruchom
`git diff lab-1-1-start` i przejrzyj to. Jeżeli podał - użyj jego zakresu.
Nie przeglądaj całego repozytorium, gdy masz konkretny diff.
```

Bez tego wywołanie skilla na czystym repo w module 8 kończy się pustym raportem.

---

## Krok 4 - checklista

Tu jest cała wartość skilla. Checklista ma być **stała** - to ona sprawia,
że dwa przeglądy są porównywalne.

```
Dopisz do skilla sekcję "Checklista". Siedem punktów, każdy z konkretem,
czego szukać. Ma pokrywać:
1. wstrzyknięcie SQL,
2. autoryzację per zasób (to nie to samo co uwierzytelnienie),
3. sekrety w kodzie,
4. walidację danych wejściowych,
5. wyciek danych w odpowiedzi,
6. ścieżki plików budowane z danych użytkownika,
7. nowe zależności.

Dopisz zasadę: model ma przejść WSZYSTKIE punkty po kolei i przy każdym,
który nie dotyczy tego diffa, wpisać "n/d". Żadnego nie wolno pominąć milcząco.
```

**Punkt 2 wymaga precyzyjnego sformułowania.** To jest luka, która w module 8 ma zostać znaleziona,
a jest najtrudniejsza do wykrycia, bo kod *wygląda* poprawnie:

```markdown
2. **Autoryzacja per zasób.** Czy dla każdego endpointu zwracającego dane sprawdzane jest,
   że zasób należy do uwierzytelnionego podmiotu? Uwierzytelnienie (kto to jest)
   to nie to samo co autoryzacja (czy wolno mu to zobaczyć). Szukaj miejsc, w których
   wynik funkcji autoryzacyjnej jest wywoływany, ale nieużywany.
```

Ostatnie zdanie jest tu najważniejsze. Bez niego model przeczyta `app/main.py`,
zobaczy wywołanie `_kontrahent_z_naglowka()` i uzna, że autoryzacja jest.

---

## Krok 5 - format raportu

```
Dopisz sekcję "Format raportu". Ma wymuszać:
- tabelę ustaleń: waga, punkt checklisty, plik:linia, opis, proponowana poprawka,
- tabelę przejścia checklisty: siedem wierszy, każdy z wynikiem ok / ZNALEZIONO / n/d,
- sekcję "Czego nie sprawdzałem", która nie może być pusta.

Dopisz zasady:
- każde ustalenie musi mieć plik i numer linii, bez tego nie trafia do tabeli,
- nie zgłaszamy problemów stylistycznych ani wydajnościowych,
- skill nie poprawia kodu, tylko raportuje.
```

**Dlaczego sekcja „Czego nie sprawdzałem" nie może być pusta.** Raport bez granic
czyta się jak gwarancja. Zdanie „nie sprawdzałem konfiguracji wdrożeniowej ani zależności
tranzytywnych" zamienia raport w to, czym naprawdę jest: przeglądem konkretnego diffa.

---

## Krok 6 - test

Kontrolowana zmiana do przejrzenia:

```bash
cat >> app/db.py <<'EOF'


def szukaj_po_numerze(con, numer):
    return list(con.execute(f"SELECT * FROM faktury WHERE numer = '{numer}'"))
EOF
```

```
/przeglad-bezpieczenstwa
```

Do sprawdzenia:
- [ ] czy raport ma **wszystkie siedem** wierszy w tabeli checklisty,
- [ ] czy znalazł wstrzyknięcie SQL z numerem linii,
- [ ] czy nie zgłosił problemów stylistycznych,
- [ ] czy sekcja „Czego nie sprawdzałem" nie jest pusta.

```bash
git checkout -- app/db.py
```

Teraz test na czystym drzewie - tak będzie w module 8:

```
/przeglad-bezpieczenstwa lab-1-1-start
```

Ma przejrzeć diff od stanu startowego i wypełnić całą tabelę checklisty.
Diff obejmuje też realny kod: nowy moduł `app/odsetki.py`, nowy endpoint
`/raporty/odsetki` w `app/main.py` i refaktoryzację `app/rozliczenia.py`.
Oczekiwany wynik: `n/d` przy sekretach, ścieżkach plików i zależnościach,
`ok`/`ZNALEZIONO` przy autoryzacji, walidacji i wycieku danych.

> **Ten wynik przydaje się w module 8.** Moduł 8 pokazuje, dlaczego przegląd **diffa**
> nie znajduje luk obecnych w repozytorium od pierwszego commita - i czym się to różni
> od przeglądu **całego projektu**.

```bash
git add .claude/skills/
git commit -m "Skill /przeglad-bezpieczenstwa"
```

---

## Kryteria zaliczenia

- [ ] `/przeglad-bezpieczenstwa` działa i jest widoczny na liście.
- [ ] Wstrzyknięcie `` !`git diff` `` daje modelowi diff bez proszenia o niego.
- [ ] Skill radzi sobie z czystym drzewem roboczym.
- [ ] Raport ma stałą strukturę i siedem wierszy checklisty.
- [ ] Znalazł wstrzyknięcie SQL w teście z kroku 6.
- [ ] Plik jest **zacommitowany** - przejdzie przez review jak kod.

## Pułapki

**Skill, który poprawia kod.** `allowed-tools` bez `Edit` i `Write` to nie ozdoba.
Przegląd, który po drodze poprawia, traci wartość dowodową: nie wiadomo, co było,
a co jest.

**Checklista, która „dostosowuje się do diffa".** Cała wartość leży w tym, że jest stała.
Model decydujący sam, które punkty pominąć, sprowadza skill z powrotem do promptu z kroku 1.

**Nazwa komendy z pola `name`.** Nie. Z nazwy katalogu. `name: Przegląd bezpieczeństwa`
w katalogu `sec-review` daje komendę `/sec-review`.

**Brak `---` w pierwszej linii.** Frontmatter musi zaczynać plik. Pusta linia przed nim
oznacza, że cały blok zostanie potraktowany jako treść.

**Skill zamiast hooka.** Skill trzeba wywołać. Przegląd, który ma dziać się
zawsze, jest zadaniem dla hooka albo CI. Skill wchodzi wtedy, gdy człowiek decyduje,
że teraz.

---

[Rozwiązanie wzorcowe](rozwiazanie-5-2.md) · [Checklista modułu](checklista.md)
