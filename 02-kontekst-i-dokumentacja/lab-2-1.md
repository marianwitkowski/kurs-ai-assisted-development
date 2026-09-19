# Lab 2.1 - Audyt okna kontekstowego

**Tag startowy: `lab-2-1-start`** · **Produkt: `notatki/audyt-kontekstu.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-2-1-start
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-1-1"
> ```
>
> Powrót do niej: `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.


W tym labie **kod nie ulega zmianie**. Zmienia się sposób obchodzenia się z kontekstem.

---

## Cel

Zmierzyć - nie oszacować, zmierzyć - ile kosztuje niedbałe wciąganie plików do kontekstu,
i sprawdzić, że celowane pytanie daje tę samą odpowiedź kilkanaście razy taniej.

---

## Krok 1 - pomiar zerowy

Świeża sesja:

```bash
claude
```

```
/context
```

**Do notatek:**
- ile procent okna zajęte,
- co składa się na te procenty (przepisać kategorie i wartości),
- **czy w sekcji „Memory files" cokolwiek jest.**

To jest punkt odniesienia. W stanie startowym repo nie ma jeszcze `CLAUDE.md`,
więc „Memory files" powinno być puste albo zawierać wyłącznie plik użytkownika.

---

## Krok 2 - droga na skróty

```
Przeczytaj wszystkie pliki w katalogu app/ i powiedz mi, gdzie liczony jest
rabat progowy.
```

Po otrzymaniu odpowiedzi:

```
/context
```

**Do notatek:** ile procent teraz, o ile wzrosło, ile tokenów poszło na same pliki.

---

## Krok 3 - droga celowana

```
/clear
/context
```

Kontekst ma wrócić do punktu wyjścia. To samo pytanie, sformułowane inaczej:

```
Nie czytaj całych plików. Użyj grepa, żeby znaleźć miejsce, w którym liczony jest
rabat progowy. Przeczytaj tylko ten jeden plik i podaj nazwę funkcji z numerem linii.
```

```
/context
```

Zapisać przyrost i porównać z krokiem 2.

**Punkt kontrolny:** czy tańsza droga dała gorszą odpowiedź.

---

## Krok 4 - koszt braku dokumentacji

```
/clear
```

Pytanie, na które **nie ma odpowiedzi w kodzie**:

```
Dlaczego pozycja z ceną promocyjną nie dostaje rabatu progowego? To celowa reguła
biznesowa czy błąd? Odpowiedz tylko na podstawie tego, co jest w repozytorium.
```

Do obserwacji dwie rzeczy:
1. **Ile plików model przeczytał**, zanim odpowiedział (i ile to kosztowało - `/context`).
2. **Czy odpowiedział twierdząco**, mimo że w repo nie ma na to żadnego dowodu.

Odpowiedź zapisać dosłownie. Wraca do niej moduł 4, w którym ujawniona zostaje
faktyczna reguła w tym kodzie.

---

## Krok 5 - notatka

`notatki/audyt-kontekstu.md`:

```markdown
# Audyt kontekstu - lab 2.1

## Pomiary

| Moment | % okna | Przyrost w tokenach | Uwagi |
|---|---|---|---|
| Świeża sesja | | - | Memory files: |
| Po "przeczytaj cały app/" | | | |
| Po /clear | | | |
| Po celowanym grepie | | | |
| Po pytaniu bez odpowiedzi w kodzie | | | |

## Odpowiedź na pytanie o rabat i promocję (dosłownie)

> ...

## Co z tego wynika dla mojej pracy
(dwa zdania - kiedy pozwalam agentowi czytać hurtem, a kiedy każę grepować)
```

---

## Punkt odniesienia

Sam katalog `app/` to **1204 linie, około 9 000 tokenów**. Sam `app/rabaty.py` to **~400 tokenów**.
Różnica między krokiem 2 a krokiem 3 powinna być mniej więcej **dwudziestokrotna** -
przy identycznej odpowiedzi.

To jest repozytorium ćwiczeniowe. W repozytorium produkcyjnym ta sama różnica liczy się
w setkach tysięcy tokenów i powtarza przy każdym zapytaniu w sesji.

---

## Kryteria zaliczenia

- [ ] Różnica między czytaniem hurtowym a celowanym jest zmierzona, a nie zgadnięta.
- [ ] Znane jest miejsce w `/context`, które pokazuje załadowanie pliku kontekstowego.
- [ ] Zaobserwowana jest odpowiedź modelu na pytanie „dlaczego", na które kod nie daje odpowiedzi.
- [ ] Prompt ograniczający czytanie jest sformułowany.

## Pułapki

**„Okno ma milion tokenów, 9 tysięcy to nic."** To prawda przy pierwszym zapytaniu.
Przy dwudziestym te 9 tysięcy zostało wysłane dwadzieścia razy - i przez cały czas rozpychało
istotną instrukcję.

**Pomiar bez `/clear` między krokami.** Bez wyczyszczenia porównanie obejmuje sumę,
nie przyrost.

**Uznanie, że model „wie", bo odpowiedział.** W kroku 4 odpowiedź nie mogła być oparta
na niczym z repo. Zapisana dosłownie, przydaje się w module 4: tam rozstrzyga się,
czy model trafił.

---

[Rozwiązanie wzorcowe](rozwiazanie-2-1.md) · [Następny lab](lab-2-2.md)
