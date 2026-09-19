# Rozwiązanie wzorcowe - lab 2.2

Gotowe pliki są w repozytorium pod tagiem `lab-3-1-start`:

```bash
git show lab-3-1-start:CLAUDE.md
git show lab-3-1-start:docs/architektura.md
git diff lab-2-2-start lab-3-1-start
```

Poniżej to, **dlaczego** wyglądają tak, a nie inaczej.

---

## Krok 1 - czego spodziewać się w pomiarze „przed"

Prompt prosi o zmianę zaokrąglania VAT z „per pozycja" na „od sumy netto".

Bez `CLAUDE.md` model typowo:

- **planuje zmianę**, zamiast ostrzec, że rusza kwoty na fakturach,
- proponuje sensowny refaktor `vat.podsumuj()` i wywołania w `rozliczenia.py`,
- **nie wie, że testów nie ma** - albo zakłada, że są,
- nie wie, jak uruchamia się testy w tym projekcie,
- nie pyta, czy wolno.

To nie jest głupota modelu. **W kodzie nie ma odpowiedzi na to pytanie.** Zaokrąglanie
per pozycja wygląda jak zbędna komplikacja, a nikt nigdzie nie napisał, że jest celowe.

> **Dlaczego nie pytamy o `Decimal`.** Pierwsza wersja tego kroku pytała o typ liczbowy
> w nowej funkcji w `app/vat.py`. To był **zepsuty pomiar**: prompt sam wskazywał plik,
> w którym `Decimal` stoi kilkanaście razy, więc model odczytywał konwencję z kodu
> w kilka sekund i pomiar „przed" wychodził identyczny jak „po".
>
> Dobry pomiar wymaga pytania, na które **kod nie odpowiada**.
>
> To nie znaczy, że konwencji nie wpisujemy do `CLAUDE.md` - wpisujemy, i krok 3 tego wymaga.
> Ale wpisujemy je po to, żeby zachowanie było **powtarzalne**, a nie żeby model w ogóle
> trafił. Różnica: bez pliku model trafia, **gdy zajrzy do właściwego pliku**;
> z plikiem trafia **zawsze**. Tej różnicy nie da się zmierzyć jednym pytaniem -
> i dlatego do pomiaru bierzemy coś innego.

## Krok 2 - co wyrzucić z wyniku `/init`

`/init` zwykle generuje sekcje w rodzaju:

> ## Struktura projektu
> - `app/main.py` - endpointy FastAPI
> - `app/db.py` - dostęp do bazy SQLite
> - `app/rozliczenia.py` - logika przeliczania faktur
> …

**Wszystko to model odczyta z repo w kilka sekund.** W pliku ładowanym do każdej sesji
to jest czysty koszt. Do usunięcia.

Zostaw z wyniku `/init` tylko komendy uruchomieniowe - i to po sprawdzeniu, że są prawdziwe.

---

## Krok 3 - struktura wzorcowego `CLAUDE.md`

55 linii, cztery sekcje:

| Sekcja | Po co |
|---|---|
| Uruchamianie i weryfikacja | komendy, których model nie zgadnie: `python seed.py`, `make test`, `make lint`, plus fakt, że baza jest generowana, nie migrowana |
| Konwencje | polskie nazwy, `Decimal` zamiast `float`, zaokrąglanie tylko przez `vat.zaokraglij()`, długość linii |
| Ostrzeżenia | `oblicz_fakture()` zawiera nieudokumentowane reguły; kolejność operacji ma skutki finansowe |
| Czego nie ma | brak testów, brak migracji, kursy walut wpisane ręcznie |

### Kluczowy fragment - ostrzeżenie napisane uczciwie

```markdown
**`app/rozliczenia.py` - `oblicz_fakture()`.** Ta funkcja zawiera reguły biznesowe, których
nikt nie opisał i których nie widać z samego kodu. Część tego, co wygląda na błąd albo
na zbędną komplikację, jest celowa i kosztowna w usunięciu.

> Nie zmieniaj zachowania tej funkcji, dopóki nie ma testów utrwalających jej obecne
> wyniki.
```

Zwróć uwagę, czego tu **nie ma**: nie ma wyliczenia reguł. Bo dziś ich nie znasz.
Poznasz je jutro, w labie 4.2, i wtedy ten akapit będzie można rozwinąć.

To jest wzorzec, który warto zabrać do pracy: **plik kontekstowy ma mówić prawdę o stanie
wiedzy zespołu, a nie sprawiać wrażenie kompletnego.** „Tu są nieudokumentowane reguły,
uważaj" jest użyteczne. Wymyślona lista reguł jest szkodliwa - utrwala zgadywanie
jako dokumentację.

### Komentarz dla ludzi

Ostatnia linia pliku:

```markdown
<!-- Utrzymuje zespół rozliczeń. Plik czytany przez agenta w każdej sesji - trzymać poniżej 60 linii. -->
```

Komentarze HTML są wycinane przed wysłaniem do modelu. Człowiek widzi notatkę o utrzymaniu,
model nie płaci za nią tokenami.

---

## Krok 4 - pomiar „po"

Z załadowanym plikiem model powinien sam z siebie: użyć `Decimal`, nazwać po polsku,
zaokrąglić przez `vat.zaokraglij()`, wspomnieć o teście i o `make test`.

**Jeśli nie - wina jest po stronie pliku, nie modelu.** Najczęstsza przyczyna:
instrukcja niesprawdzalna. Porównaj:

| Nie działa | Działa |
|---|---|
| „Używaj odpowiednich typów liczbowych" | „Kwoty pieniężne wyłącznie jako `Decimal`. Nigdy `float`." |
| „Trzymaj się konwencji projektu" | „Nazwy domenowe po polsku, bez znaków diakrytycznych" |
| „Pamiętaj o testach" | „Zmiana w `app/` bez testu wymaga wyraźnej zgody" |

Reguła: jeśli **ty** nie umiesz jednoznacznie stwierdzić, czy instrukcja została spełniona,
model też nie.

---

## Krok 5 - `docs/architektura.md`

Trzy części, żadna z nich nie jest opisem „co robi każdy moduł".

**1. Graf zależności z faktycznych importów.** Weryfikacja jedną komendą:

```bash
grep -n "^from app" app/*.py
```

Jeżeli diagram nie zgadza się z wynikiem - masz halucynację w dokumentacji.
To jest najczęstszy błąd w tym kroku: model rysuje diagram „jak to zwykle wygląda",
zamiast odczytać go z kodu.

**2. Warstwy, które z grafu wynikają.** To jest wartość dodana ponad sam graf:

| Warstwa | Zasada |
|---|---|
| `modele`, `konfiguracja` | nie importują niczego z `app` |
| `vat`, `rabaty`, `terminy`, `korekty`, `walidacja` | zależą tylko od podstawy |
| `rozliczenia` | spina reguły, **nie dotyka bazy** |
| `db` | główny dostęp do danych; SQL jest też w `importer` i `platnosci` (ten drugi tworzy własną tabelę `wplaty`) |
| `raporty`, `platnosci`, `powiadomienia`, `eksport`, `importer` | łączą dane z regułami |
| `main` | FastAPI, bez logiki biznesowej |

Zdanie „`rozliczenia` nie dotyka bazy" jest ważniejsze niż cały diagram: mówi, że tę funkcję
da się testować bez SQLite. Wykorzystasz to jutro w labie 4.2.

**3. Miejsca, w których kolejność zmienia kwotę.** Siedem linii z numerami.
To jest dokładnie ten rodzaj wiedzy, której nie da się odczytać z jednego pliku,
bo rozkłada się na `rozliczenia.py` i `vat.py`.

---

## Diff, który powinieneś uzyskać

```bash
git diff --stat lab-2-2-start lab-3-1-start
```

```
 CLAUDE.md            |  55 +++++++++++++++++++++++++
 docs/architektura.md | 114 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 169 insertions(+)
```

Dwa pliki, żadnej zmiany w kodzie. Cała wartość tego labu leży w tym, co model teraz wie
od pierwszej sekundy sesji.

---

## Najczęstsze potknięcia

**Wpisanie klucza z `app/konfiguracja.py`.** Jeśli opisując konfigurację przepisałeś
wartość `KLUCZ_API_KSEF` - właśnie powieliłeś sekret do drugiego pliku w repo
i do kontekstu każdej sesji. Wzorcowy `docs/architektura.md` wspomina o problemie
(`app/db.py` skleja zapytania, kursy są wpisane ręcznie), ale **nie cytuje żadnej wartości**.

**„Plik na 150 linii jest lepszy, bo kompletniejszy."** Zmierz. Jeżeli odpowiedź w kroku 4
jest taka sama jak przy 55 liniach, to nadmiar nic nie kupił - a kosztuje w każdej sesji
do końca projektu.

**Wpisanie do `CLAUDE.md` reguły, która musi zadziałać zawsze.** „Nigdy nie commituj
bez uruchomienia testów" to prośba. Model ją przeczyta i zwykle się zastosuje - ale nie zawsze.
Jutro w labie 5.1 ta sama reguła stanie się hookiem `Stop` i przestanie być prośbą.

**Diagram, którego nie sprawdziłeś.** Dokumentacja architektury, która kłamie, jest gorsza
niż jej brak: człowiek jej ufa, a model bierze ją za podstawę decyzji.
