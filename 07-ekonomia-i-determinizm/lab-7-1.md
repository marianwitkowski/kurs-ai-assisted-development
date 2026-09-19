# Lab 7.1 - Pomiar kosztu i higiena kontekstu

**Czas: ~25 min** · **Tag startowy: `lab-7-1-start`** · **Produkt: `notatki/pomiar-kosztu.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-7-1-start
claude --version     # wymagane 2.1.251 lub nowsze - inaczej nie ma statystyk cache
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-6-2"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.

W tym labie **nie zmieniasz kodu**. Mierzysz.

---

## Cel

Zobaczyć na liczbach, ile kosztuje niedbałe prowadzenie sesji - i sprawdzić,
czy prompt caching u ciebie w ogóle działa.

---

## Krok 1 - punkt odniesienia (4 min)

Świeża sesja:

```
/context
```

Zapisz rozbicie na kategorie. Potem:

```
/usage
```

Zapisz:
- pozycję pasków limitu planu,
- czy jest sekcja atrybucji zużycia (skille, subagenci, MCP),
- czy któraś flaga zachowań jest zapalona.

> Blok `Session` pokazuje kwotę w dolarach. **Na subskrypcji Pro/Max ta liczba nie ma
> związku z twoim rachunkiem** - jest liczona lokalnie po cenniku katalogowym.
> Istotne są paski limitu i atrybucja.

---

## Krok 2 - sesja rozdęta (8 min)

Zasymuluj typową sesję, która trwa od rana:

```
Przeczytaj wszystkie pliki w app/ i opisz mi architekturę tego serwisu.
```

```
Teraz przeczytaj wszystkie testy i powiedz, co jest pokryte, a co nie.
```

```
Sprawdź też docs/ i specyfikacje/ i powiedz, czy dokumentacja jest spójna z kodem.
```

```
/context
```

Zapisz procent zajętości. Teraz zadaj **małe** pytanie:

```
W którym pliku jest stała PROG_STALEGO_KLIENTA?
```

```
/usage
```

Zapisz przyrost zużycia po tym jednym, trywialnym pytaniu.

**To jest cały lab w jednym pomiarze.** Pytanie warte dwudziestu tokenów niesie ze sobą
cały kontekst zgromadzony wcześniej - i tak będzie przy każdym następnym.

---

## Krok 3 - sesja czysta (4 min)

```
/clear
```

To samo pytanie:

```
W którym pliku jest stała PROG_STALEGO_KLIENTA?
```

```
/context
/usage
```

Porównaj przyrost z krokiem 2. Odpowiedź jest identyczna.

---

## Krok 4 - statystyki cache (5 min)

Zostań w tej samej sesji. Zadaj trzy pytania pod rząd, każde krótkie:

```
Ile progów rabatowych jest w app/rabaty.py?
```
```
Jaki jest próg stałego klienta w app/terminy.py?
```
```
Jaka jest domyślna liczba dni terminu płatności?
```

```
/usage
```

Znajdź linię `Prompt cache (main)` i zapisz:
- procent tokenów wejściowych z cache,
- liczbę chybień (`misses`),
- czy cache jest `warm` i jaki ma TTL.

**Oczekiwany wynik:** wysoki procent trafień i TTL **1 h** (subskrypcja).
Na kluczu API TTL wynosi 5 minut - to jest różnica, która zmienia sposób pracy:
na subskrypcji przerwa na kawę nie kosztuje nic.

Jeżeli trafień jest zero - coś unieważnia prefiks przy każdym żądaniu.
Najczęstsze przyczyny: przełączanie modelu między pytaniami, zmiana zestawu
serwerów MCP, edycja plików kontekstowych w trakcie sesji.

---

## Krok 5 - notatka (4 min)

`notatki/pomiar-kosztu.md`:

```markdown
# Pomiar - lab 7.1

## Kontekst

| Moment | % okna | Uwagi |
|---|---|---|
| Świeża sesja | | |
| Po trzech zadaniach "przeczytaj wszystko" | | |
| Małe pytanie w rozdętej sesji - przyrost zużycia | | |
| To samo po /clear - przyrost zużycia | | |

Stosunek: ...

## Prompt cache

- % tokenów wejściowych z cache:
- chybienia:
- TTL: ... (subskrypcja = 1 h, klucz API = 5 min)

## Atrybucja z /usage

| Źródło | Udział |
|---|---|
| skille | |
| subagenci | |
| serwery MCP | |

## Trzy rzeczy, które zmieniam w swojej pracy od jutra
1.
2.
3.
```

---

## Kryteria zaliczenia

- [ ] Masz zmierzoną różnicę przyrostu zużycia dla **tego samego pytania**
      w sesji rozdętej i czystej.
- [ ] Umiesz odczytać linię statystyk prompt cache i wiesz, co oznacza `warm` i TTL.
- [ ] Wiesz, że na Pro/Max kwota z bloku `Session` nie jest twoim rachunkiem.
- [ ] Sprawdziłeś atrybucję: co w twojej konfiguracji zjada zużycie, zanim zaczniesz pracę.
- [ ] Masz zapisane trzy konkretne zmiany w sposobie pracy.

## Pułapki

**Wniosek „okno ma milion tokenów, nie ma problemu".** Okno to nie jest budżet -
to jest sufit. Płacisz za to, co w nim siedzi, przy **każdym** zapytaniu.

**Pomiar bez `/clear` między krokami 2 i 3.** Wtedy porównujesz sumę, nie przyrost.

**Przełączanie modelu w trakcie kroku 4.** Cache jest przypisany do modelu.
Zmiana modelu między pytaniami wyzeruje trafienia i zobaczysz wynik, który nic nie znaczy.

**Pominięcie atrybucji.** Jeśli masz podłączone serwery MCP, których nie używasz,
płacisz za nie w każdej sesji. `/mcp` pozwala je wyłączyć.

---

[Rozwiązanie wzorcowe](rozwiazanie-7-1.md) · [Następny lab](lab-7-2.md)
