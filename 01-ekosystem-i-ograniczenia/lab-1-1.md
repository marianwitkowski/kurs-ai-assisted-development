# Lab 1.1 - Model-to-Task Mapping na żywym repo

**Tag startowy: `lab-1-1-start`** · **Produkt: `notatki/model-to-task.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git status                      # ma być czysto
git checkout lab-1-1-start
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-1-1"
> ```
>
> Powrót do niej: `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.


Sprawdzenie, że aplikacja działa:

```bash
source .venv/bin/activate
python seed.py
python -c "import app.main; print('OK')"
```

> Przy braku `.venv` - trzy komendy, w tej kolejności; `pip` bez aktywacji
> zainstaluje zależności do interpretera systemowego:
>
> ```bash
> python3.12 -m venv .venv
> source .venv/bin/activate
> pip install -r requirements.txt
> ```

Uruchomić Claude Code w katalogu repozytorium:

```bash
claude
```

---

## Cel

Sprawdzić **na własnych oczach**, że wybór modelu i poziomu wysiłku zmienia wynik - i że model
potrafi pewnym tonem opowiedzieć o funkcji, której nie ma. Do tego wyrobić odruch: twierdzenie
o kodzie wymaga cytatu, zanim zostanie przyjęte.

---

## Krok 1 - pytanie o fakt

> **Przed startem - dwie rzeczy o `/effort`, które trzeba wiedzieć.**
>
> **Nie każdy model go obsługuje.** Poziom wysiłku działa na Opusie, Sonnecie 5 i Fable.
> **Haiku 4.5 go nie obsługuje** - `/effort low` na Haiku nic nie zmienia.
> Dlatego w tym kroku zmienia się jedną rzecz naraz.
>
> **Wpisany poziom zapisuje się jako domyślny** i obowiązuje w kolejnych sesjach.
> Na końcu labu jest krok, który przywraca stan wyjściowy - tego kroku nie należy pomijać,
> bo inaczej cały kurs idzie na konfiguracji wybranej teraz.

Pytanie jest przez cały krok to samo:

```
Ile progów rabatowych ma ten serwis i jakie są ich wartości? Podaj plik i numery linii.
```

### 1a. Porównanie izolowane - to jest pomiar

Cztery warianty, **każdy w czystym kontekście**. `/clear` przed każdym z nich, żeby
model nie widział poprzednich odpowiedzi ani wyników odczytu plików:

```
/clear
/model haiku
<pytanie>

/clear
/model sonnet
<pytanie>

/clear
/effort low
<pytanie>

/clear
/effort high
<pytanie>
```

Zmienia się **jedna rzecz naraz**: najpierw sam model przy nieruszonym poziomie wysiłku,
potem sam poziom wysiłku przy nieruszonym modelu. Haiku nie obsługuje effortu, więc
sprawdzanie go na Haiku niczego nie pokaże.

**Do notatek** dla każdego z czterech przebiegów: czy odpowiedź jest poprawna, czy podała
plik i numery linii, **ile razy model sięgnął po narzędzia**. Ostatnia kolumna bywa
ciekawsza od pozostałych: model, który zgrepował repo trzy razy, rozwiązał inne zadanie
niż ten, który odpowiedział od razu.

> **Jeden przebieg na wariant nie wystarcza do wniosku o jakości.** Odpowiedzi modelu
> nie są identyczne między uruchomieniami. Przy realnym porównaniu robi się kilka powtórzeń
> i patrzy na rozrzut, a nie na pojedynczy wynik. Tutaj chodzi o zobaczenie dźwigni,
> nie o zmierzenie modeli - ale wniosek „Sonnet jest lepszy" nie ma na tej próbce pokrycia.

### 1b. To samo bez `/clear` - demonstracja wpływu historii

Teraz świadomie odwrotnie. **Bez `/clear`**, w jednej rozmowie, po kolei:

```
/model haiku
<pytanie>
/model sonnet
<pytanie>
```

**Do notatek:** czy druga odpowiedź różni się od tej, którą ten sam model dał
w izolacji w kroku 1a.

To jest sedno tego kroku. W jednej rozmowie drugi model widzi odpowiedź pierwszego
i wyniki odczytu plików, więc **nie odpowiada na to samo pytanie w tych samych warunkach**.
Zmieniają się dwie rzeczy naraz: konfiguracja i dostępna informacja. Porównanie
przeprowadzone w ten sposób mierzy wpływ historii rozmowy, a nie wpływ modelu -
i właśnie dlatego jest najczęstszym błędem przy „sprawdzaniu, który model jest lepszy".

Kontekst z tego kroku zostaje: potrzebny jest w kroku 4.

---

## Krok 2 - przynęta na halucynację

Najpierw ustalenie faktu poza agentem:

```bash
grep -rn "oblicz_odsetki" app/ || echo "brak - zero trafien"
```

Teraz **trzy warianty tego samego pytania**. Zadać je po kolei i zapisać wszystkie odpowiedzi.

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

**Do notatek:** wszystkie trzy odpowiedzi. Pierwsza jest materiałem dowodowym na resztę kursu.

> **Czego się spodziewać.** W 2026 wariant B najczęściej **zgrepuje repo i odpowie poprawnie** -
> i to jest dobra wiadomość o narzędziu, nie porażka labu. Istota porównania leży w kontraście
> **A kontra C**, nie B kontra C.
>
> Wariant A to **zawsze** ten sam wynik, gdy model nie ma dostępu do plików:
> w oknie czatu, w asystencie IDE bez kontekstu repozytorium, w każdym narzędziu,
> które dostało wklejony fragment kodu zamiast katalogu.

---

## Krok 3 - zadanie wymagające rozumowania

```
/model sonnet
/effort medium
```

```
Przeczytaj app/rozliczenia.py i powiedz, w jakiej kolejności ta funkcja stosuje
rabat i VAT. Czy ta kolejność ma znaczenie dla końcowej kwoty? Uzasadnij,
powołując się na konkretne linie.
```

Zanotować odpowiedź. Potem to samo pytanie na mocniejszej konfiguracji:

```
/model opus
/effort high
```

> Przy planie bez dostępu do Opusa - `/model sonnet` i `/effort high`.
> Porównanie nadal ma sens: zmienia się poziom wysiłku przy tym samym modelu.

**Do notatek:** czym się różnią obie odpowiedzi, czy słabsza konfiguracja coś pominęła,
czy mocniejsza powiedziała coś nieweryfikowalnego.

---

## Krok 4 - koszt rozrostu kontekstu

Zawartość kontekstu po trzech krokach pokazuje `/context`:

```
/context
```

**Do notatek:** ile procent okna jest zajęte i co je zajmuje. Potem:

```
/clear
/context
```

Zanotować różnicę.

---

## Krok 5 - notatka

Zapisać `notatki/model-to-task.md` (katalog `notatki/` jest gitignorowany, to brudnopis uczestnika):

```markdown
# Model-to-Task - obserwacje z labu 1.1

| Zadanie | Model | Effort | Narzędzia | Wynik | Uwaga |
|---|---|---|---|---|---|
| 1a Fakt: progi (izolacja) | haiku | - | | | |
| 1a Fakt: progi (izolacja) | sonnet | (bez zmian) | | | |
| 1a Fakt: progi (izolacja) | sonnet | low | | | |
| 1a Fakt: progi (izolacja) | sonnet | high | | | |
| 1b Fakt: progi (jedna rozmowa) | sonnet | (bez zmian) | | | |
| oblicz_odsetki A - bez narzędzi | | | | | |
| oblicz_odsetki B - normalnie | | | | | |
| oblicz_odsetki C - z cytatem | | | | | |
| Rozumowanie: kolejność rabat/VAT | sonnet | medium | | | |
| Rozumowanie: kolejność rabat/VAT | opus | high | | | |

## Kontekst
- przed /clear: ... %
- po /clear: ... %

## Moja reguła doboru
(jedno zdanie: kiedy schodzę na haiku, kiedy wchodzę na opus)
```

---

## Krok 6 - przywrócenie stanu domyślnego

**Tego kroku nie należy pomijać.**

```
/model sonnet
/effort high
```

`/effort` z wpisanym poziomem **zapisuje go jako domyślny i stosuje w kolejnych sesjach**.
To samo robi wybór modelu w `/model`. Bez tego kroku reszta kursu - piętnaście
kolejnych labów - idzie na konfiguracji dobranej do jednego pytania o progi rabatowe.

W praktyce oznacza to jedno z dwojga, oba złe:

| Pozostawiona konfiguracja | Co się dzieje |
|---|---|
| Opus / `high` | limity planu wyczerpują się około modułu 6-7, czyli w najdroższych labach |
| Haiku / `low` | laby 4.2 i 4.3 przestają działać - cała pointa zależy tam od jakości rozumowania |

Aktualną konfigurację pokazuje `/status`.

---

## Kryteria zaliczenia

- [ ] Porównane trzy warianty pytania o `oblicz_odsetki` i rozpoznane, **czym różni się
      odpowiedź mająca punkt zaczepienia w pliku od odpowiedzi bez niego**. Jeżeli wariant A
      poprawnie przyznał „nie wiem" zamiast zmyślać - to też jest wynik i też zalicza.
- [ ] Przywrócony domyślny model i poziom wysiłku (krok 6).
- [ ] Znany sposób sformułowania pytania, po którym model musi przyznać, że czegoś nie ma.
- [ ] Zapisana własna reguła doboru modelu - nie cudza tabela.
- [ ] Opanowany odczyt `/context` i działanie `/clear`.

## Pułapki

**„Model w wariancie B odpowiedział poprawnie, więc nie halucynuje."** Halucynacja nie jest
cechą modelu, tylko cechą **sytuacji**: czy odpowiedź ma się o co zaczepić. W wariancie B
model miał dostęp do plików i z niego skorzystał - to była jego decyzja, nie gwarancja
po stronie użytkownika. Wariant A pokazuje wynik, gdy tego dostępu nie ma.

**„Opus był lepszy, więc zawsze będę używał Opusa."** Na pytaniu o progi rabatowe różnica była
żadna, a koszt pięciokrotny. Zysk z mocniejszego modelu pojawia się dopiero tam, gdzie zadanie
wymaga rozumowania.

**Zapominanie o `Esc`.** Jeżeli w którymkolwiek kroku model zaczął czytać całe repo zamiast
odpowiedzieć - przerwać i przeformułować pytanie. Czekanie do końca nic nie daje.

---

[Rozwiązanie wzorcowe](rozwiazanie-1-1.md) · [Checklista modułu](checklista.md)
