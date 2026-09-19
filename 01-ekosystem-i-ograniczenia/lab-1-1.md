# Lab 1.1 - Model-to-Task Mapping na żywym repo

**Czas: ~30 min** · **Tag startowy: `lab-1-1-start`** · **Produkt: `notatki/model-to-task.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git status                      # ma być czysto
git checkout lab-1-1-start
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


Sprawdź, że aplikacja żyje:

```bash
source .venv/bin/activate
python seed.py
python -c "import app.main; print('OK')"
```

> Nie masz jeszcze `.venv`? Trzy komendy, w tej kolejności - `pip` bez aktywacji
> zainstaluje zależności do interpretera systemowego:
>
> ```bash
> python3.12 -m venv .venv
> source .venv/bin/activate
> pip install -r requirements.txt
> ```

Uruchom Claude Code w katalogu repozytorium:

```bash
claude
```

---

## Cel

Sprawdzić **na własnych oczach**, że wybór modelu i poziomu wysiłku zmienia wynik - i że model
potrafi pewnym tonem opowiedzieć o funkcji, której nie ma. Do tego wyrobić odruch: zanim uwierzysz
w twierdzenie o kodzie, żądaj cytatu.

---

## Krok 1 - pytanie o fakt (5 min)

> **Zanim zaczniesz - dwie rzeczy o `/effort`, które trzeba wiedzieć.**
>
> **Nie każdy model go obsługuje.** Poziom wysiłku działa na Opusie, Sonnecie 5 i Fable.
> **Haiku 4.5 go nie obsługuje** - `/effort low` na Haiku nic nie zmienia.
> Dlatego w tym kroku zmieniamy jedną rzecz naraz.
>
> **Wpisany poziom zapisuje się jako domyślny** i obowiązuje w kolejnych sesjach.
> Na końcu labu jest krok, który przywraca stan wyjściowy - nie pomijaj go,
> bo inaczej cały kurs pojedzie na konfiguracji wybranej teraz.

Najpierw sam **model**, przy nieruszonym poziomie wysiłku:

```
/model haiku
```

Zadaj pytanie:

```
Ile progów rabatowych ma ten serwis i jakie są ich wartości? Podaj plik i numery linii.
```

Zanotuj: czy odpowiedź jest poprawna, ile trwała, czy podała plik i linie.

Powtórz **to samo pytanie** po przełączeniu modelu:

```
/model sonnet
```

Teraz sam **poziom wysiłku**, przy nieruszonym modelu - Sonnet effort obsługuje:

```
/effort low
```

...to samo pytanie jeszcze raz, a potem:

```
/effort high
```

> **Uwaga:** nie rób `/clear` między tymi pytaniami - chcesz porównać odpowiedzi
> w tych samych warunkach. `/clear` przyjdzie w kroku 4.

**Pytania do notatek:** czy droższy **model** dał lepszą odpowiedź na pytanie o prosty fakt?
Czy wyższy **effort** cokolwiek zmienił? To są dwie różne dźwignie i tu widać,
że na tym zadaniu żadna nie kupuje nic.

---

## Krok 2 - przynęta na halucynację (8 min)

Najpierw ustal fakt sam, poza agentem:

```bash
grep -rn "oblicz_odsetki" app/ || echo "brak - zero trafien"
```

Teraz **trzy warianty tego samego pytania**. Zadaj je po kolei i zapisz wszystkie odpowiedzi.

**A - bez narzędzi, z pamięci:**

```
Nie używaj żadnych narzędzi i nie czytaj plików. Odpowiedz wyłącznie z tego,
co pamiętasz po dotychczasowej rozmowie: jak działa funkcja oblicz_odsetki
w tym projekcie? Jakie ma parametry i jak liczy odsetki za zwłokę?
```

**B - normalnie:**

```
Wyjaśnij mi, jak działa funkcja oblicz_odsetki w tym projekcie.
```

**C - z wymuszeniem cytatu:**

```
Znajdź w tym repozytorium funkcję o nazwie oblicz_odsetki. Zacytuj jej sygnaturę
razem ze ścieżką pliku i numerem linii. Jeżeli takiej funkcji nie ma, napisz
dokładnie: "nie ma takiej funkcji" i nie dodawaj nic więcej.
```

**Do notatek:** zapisz wszystkie trzy. Pierwsza jest materiałem dowodowym na resztę kursu.

> **Czego się spodziewać.** W 2026 wariant B najczęściej **zgrepuje repo i odpowie poprawnie** -
> i to jest dobra wiadomość o narzędziu, nie porażka labu. Pointa siedzi w kontraście
> **A kontra C**, nie B kontra C.
>
> Wariant A jest tym, co dostajesz **zawsze**, gdy model nie ma dostępu do plików:
> w oknie czatu, w asystencie IDE bez kontekstu repozytorium, w każdym narzędziu,
> któremu wkleiłeś fragment kodu zamiast dać katalog.

---

## Krok 3 - zadanie wymagające rozumowania (10 min)

```
/model sonnet
/effort medium
```

```
Przeczytaj app/rozliczenia.py i powiedz, w jakiej kolejności ta funkcja stosuje
rabat i VAT. Czy ta kolejność ma znaczenie dla końcowej kwoty? Uzasadnij,
powołując się na konkretne linie.
```

Zanotuj odpowiedź. Potem to samo pytanie na mocniejszej konfiguracji:

```
/model opus
/effort high
```

> Jeżeli twój plan nie daje dostępu do Opusa - użyj `/model sonnet` i `/effort high`.
> Porównanie nadal ma sens: zmieniasz poziom wysiłku przy tym samym modelu.

**Do notatek:** czym się różnią? Czy słabsza konfiguracja coś pominęła? Czy mocniejsza
powiedziała coś, czego nie potrafisz zweryfikować?

---

## Krok 4 - koszt rozrostu kontekstu (5 min)

Sprawdź, co siedzi w kontekście po trzech krokach:

```
/context
```

Zanotuj, ile procent okna jest zajęte i co je zajmuje. Potem:

```
/clear
/context
```

Zanotuj różnicę.

---

## Krok 5 - notatka (2 min)

Zapisz `notatki/model-to-task.md` (katalog `notatki/` jest gitignorowany, to twój brudnopis):

```markdown
# Model-to-Task - obserwacje z labu 1.1

| Zadanie | Model | Effort | Wynik | Uwaga |
|---|---|---|---|---|
| Fakt: progi rabatowe | haiku | - | | |
| Fakt: progi rabatowe | sonnet | (bez zmian) | | |
| Fakt: progi rabatowe | sonnet | low | | |
| Fakt: progi rabatowe | sonnet | high | | |
| oblicz_odsetki A - bez narzędzi | | | | |
| oblicz_odsetki B - normalnie | | | | |
| oblicz_odsetki C - z cytatem | | | | |
| Rozumowanie: kolejność rabat/VAT | sonnet | medium | | |
| Rozumowanie: kolejność rabat/VAT | opus | high | | |

## Kontekst
- przed /clear: ... %
- po /clear: ... %

## Moja reguła doboru na jutro
(jedno zdanie: kiedy schodzę na haiku, kiedy wchodzę na opus)
```

---

## Krok 6 - przywróć stan domyślny (1 min)

**Nie pomijaj tego kroku.**

```
/model sonnet
/effort high
```

`/effort` z wpisanym poziomem **zapisuje go jako domyślny i stosuje w kolejnych sesjach**.
To samo robi wybór modelu w `/model`. Bez tego kroku przez resztę kursu - piętnaście
kolejnych labów - jechałbyś na konfiguracji wybranej pięć minut temu do jednego pytania
o progi rabatowe.

W praktyce oznacza to jedno z dwojga, oba złe:

| Zostajesz na | Co się dzieje |
|---|---|
| Opus / `high` | limity planu wyczerpują się około modułu 6-7, czyli w najdroższych labach |
| Haiku / `low` | laby 4.2 i 4.3 przestają działać - cała pointa zależy tam od jakości rozumowania |

Sprawdź, na czym jesteś: `/status`.

---

## Kryteria zaliczenia

- [ ] Widziałeś odpowiedź poprawną i odpowiedź zmyśloną, podane **tym samym tonem**
      (warianty C i A w kroku 2).
- [ ] Przywróciłeś domyślny model i poziom wysiłku (krok 6).
- [ ] Wiesz, jak sformułować pytanie tak, żeby model musiał przyznać, że czegoś nie ma.
- [ ] Masz własną, zapisaną regułę doboru modelu - nie cudzą tabelę.
- [ ] Umiesz odczytać `/context` i wiesz, co robi `/clear`.

## Pułapki

**„Model w wariancie B odpowiedział poprawnie, więc nie halucynuje."** Halucynacja nie jest
cechą modelu, tylko cechą **sytuacji**: czy odpowiedź ma się o co zaczepić. W wariancie B
model miał dostęp do plików i z niego skorzystał - to była jego decyzja, nie twoja gwarancja.
Wariant A pokazuje, co dostajesz, gdy tego dostępu nie ma.

**„Opus był lepszy, więc zawsze będę używał Opusa."** Na pytaniu o progi rabatowe różnica była
żadna, a koszt pięciokrotny. Zysk z mocniejszego modelu pojawia się dopiero tam, gdzie zadanie
wymaga rozumowania.

**Zapominanie o `Esc`.** Jeśli w którymkolwiek kroku model zaczął czytać całe repo zamiast
odpowiedzieć - przerwij i przeformułuj. Czekanie do końca nic nie daje.

---

[Rozwiązanie wzorcowe](rozwiazanie-1-1.md) · [Checklista modułu](checklista.md)
