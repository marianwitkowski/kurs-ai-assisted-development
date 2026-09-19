# Lab 2.1 - Audyt okna kontekstowego

**Czas: ~30 min** · **Tag startowy: `lab-2-1-start`** · **Produkt: `notatki/audyt-kontekstu.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-2-1-start
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-1-1"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.


W tym labie **nie zmieniasz kodu**. Zmieniasz to, co sam robisz z kontekstem.

---

## Cel

Zmierzyć - nie oszacować, zmierzyć - ile kosztuje niedbałe wciąganie plików do kontekstu,
i sprawdzić, że celowane pytanie daje tę samą odpowiedź kilkanaście razy taniej.

---

## Krok 1 - pomiar zerowy (3 min)

Świeża sesja:

```bash
claude
```

```
/context
```

Zapisz do notatek:
- ile procent okna zajęte,
- co składa się na te procenty (przepisz kategorie i wartości),
- **czy w sekcji „Memory files" cokolwiek jest.**

To jest twój punkt odniesienia. W stanie startowym repo nie ma jeszcze `CLAUDE.md`,
więc „Memory files" powinno być puste albo zawierać wyłącznie twój plik użytkownika.

---

## Krok 2 - droga na skróty (7 min)

```
Przeczytaj wszystkie pliki w katalogu app/ i powiedz mi, gdzie liczony jest
rabat progowy.
```

Poczekaj na odpowiedź. Potem:

```
/context
```

Zapisz: ile procent teraz, o ile wzrosło, ile tokenów poszło na same pliki.

---

## Krok 3 - droga celowana (7 min)

```
/clear
/context
```

Potwierdź, że wróciłeś do punktu wyjścia. Teraz to samo pytanie inaczej:

```
Nie czytaj całych plików. Użyj grepa, żeby znaleźć miejsce, w którym liczony jest
rabat progowy. Przeczytaj tylko ten jeden plik i podaj nazwę funkcji z numerem linii.
```

```
/context
```

Zapisz przyrost. Porównaj z krokiem 2.

**Pytanie kontrolne:** czy odpowiedź jest gorsza?

---

## Krok 4 - koszt braku dokumentacji (8 min)

```
/clear
```

Zadaj pytanie, na które **nie ma odpowiedzi w kodzie**:

```
Dlaczego pozycja z ceną promocyjną nie dostaje rabatu progowego? To celowa reguła
biznesowa czy błąd? Odpowiedz tylko na podstawie tego, co jest w repozytorium.
```

Obserwuj dwie rzeczy:
1. **Ile plików model przeczytał**, zanim odpowiedział (i ile to kosztowało - `/context`).
2. **Czy odpowiedział twierdząco**, mimo że w repo nie ma na to żadnego dowodu.

Zapisz odpowiedź dosłownie. Wrócisz do niej w module 4, gdy poznasz prawdę o tym kodzie.

---

## Krok 5 - notatka (5 min)

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

To jest repozytorium ćwiczeniowe. W twoim repo w pracy ta sama różnica będzie liczona
w setkach tysięcy tokenów i będzie się powtarzać przy każdym zapytaniu w sesji.

---

## Kryteria zaliczenia

- [ ] Masz zmierzoną, a nie zgadniętą różnicę między czytaniem hurtowym a celowanym.
- [ ] Wiesz, gdzie w `/context` sprawdzić, czy plik kontekstowy się załadował.
- [ ] Widziałeś, jak model odpowiada na pytanie „dlaczego", na które kod nie daje odpowiedzi.
- [ ] Umiesz sformułować prompt, który ogranicza czytanie.

## Pułapki

**„Okno ma milion tokenów, 9 tysięcy to nic."** To prawda przy pierwszym zapytaniu.
Przy dwudziestym te 9 tysięcy zostało wysłane dwadzieścia razy - i przez cały czas rozpychało
istotną instrukcję.

**Pomiar bez `/clear` między krokami.** Bez wyczyszczenia porównujesz sumę, nie przyrost.

**Uznanie, że model „wie", bo odpowiedział.** W kroku 4 odpowiedź nie mogła być oparta
na niczym z repo. Zapamiętaj ją - za kilka godzin sprawdzisz, czy trafił.

---

[Rozwiązanie wzorcowe](rozwiazanie-2-1.md) · [Następny lab](lab-2-2.md)
