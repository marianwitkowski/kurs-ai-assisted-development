# Rozwiązanie wzorcowe - lab 4.3

```bash
git diff lab-4-3-start lab-5-1-start
git show lab-5-1-start:app/rozliczenia.py
```

```
 app/rozliczenia.py | 244 ++++++++++++++++++++++-------------------
 1 file changed, 136 insertions(+), 108 deletions(-)
```

**Jeden plik.** Zero zmian w `tests/`, zero w pozostałych modułach `app/`.
`oblicz_fakture()` ze **157 linii do 57**.

---

## Podział na kroki

| Funkcja | Odpowiedzialność |
|---|---|
| `_sprawdz_wejscie()` | walidacja i ostrzeżenia wstępne |
| `_kurs()` | kurs waluty albo 1.0 z ostrzeżeniem |
| `_cena_pozycji()` | cena do naliczenia + czy liczona jest promocja |
| `_netto_przed_rabatem()` | podstawa progu rabatowego |
| `_stawka_rabatu()` | stawka dla całej faktury |
| `_kod_stawki()` | stawka VAT pozycji, z dziedziczeniem przy korekcie |
| `_wiersz()` | pojedynczy wiersz rozliczenia |
| `_ostrzezenie_o_progu()` | próg raportowania |
| `oblicz_fakture()` | złożenie powyższych |

Dziewięć funkcji, nie dwadzieścia. Każda ma nazwę mówiącą, **co** robi, a nie „krok 3".

---

## Komentarze, które są częścią rozwiązania

Nagłówek modułu:

```python
"""Refaktoryzacja zachowawcza: ta sama logika co wczesniej, rozbita na kroki.
Zachowanie utrwalone w tests/test_charakterystyka_rozliczen.py - te testy musza
przechodzic bez zmian. Kazda roznica w kwotach jest bledem refaktoryzacji.

Miejsca oznaczone "REGULA" sa celowe i udokumentowane w docs/mapa-ryzyka.md.
Miejsca oznaczone "ZNANY BLAD" czekaja na decyzje biznesu - nie poprawiamy ich
przy okazji refaktoryzacji.
"""
```

I w środku, w `_wiersz()`:

```python
# ZNANY BLAD: rabaty.rabat_pozycji() zwraca zero dla kazdej pozycji z ustawionym
# polem cena_promocyjna - takze wtedy, gdy promocja wygasla i pozycja jest liczona
# po cenie pelnej. Patrz docs/mapa-ryzyka.md. Nie poprawiamy tego tutaj.
rabat = Decimal("0") if promocja_liczona else rabaty.rabat_pozycji(pozycja, stawka_rabatu)
```

**Po co ten komentarz, skoro jest test.** Test mówi „tak jest". Komentarz mówi „wiemy,
że tak nie powinno być, i wiemy, dlaczego nie ruszamy tego teraz". Następna osoba,
która tu trafi, nie musi przechodzić całej drogi od nowa.

Cztery funkcje mają komentarz `REGULA` - to są miejsca, których nie wolno upraszczać.
`_wiersz()` ma dodatkowo `ZNANY BLAD` - to jest miejsce, które trzeba naprawić, ale nie tutaj.

---

## Pułapka, której testy nie łapią

Oryginalna funkcja miała **dwa przebiegi** po pozycjach. Ostrzeżenie o wygasłej promocji
dopisywała tylko w pierwszym. Po rozbiciu na funkcje łatwo o taki kod:

```python
def _netto_przed_rabatem(faktura, ostrzezenia):
    for pozycja in faktura.pozycje:
        if pozycja.cena_promocyjna is not None and not rabaty.promocja_aktywna(pozycja):
            ostrzezenia.append(...)         # tu
        cena, _ = _cena_pozycji(pozycja)    # i tu promocja_aktywna wolane drugi raz
```

Testy nadal przechodzą (sprawdzają `"..." in w.ostrzezenia`), a `promocja_aktywna()` liczy się
dwa razy na pozycję - i jeśli `append` trafi także do drugiego przebiegu (`_wiersz()`),
lista ostrzeżeń w odpowiedzi API się zdubluje. Sprawdzenie:

```bash
.venv/bin/python -c "... print(oblicz_fakture(f, k).ostrzezenia)"
```

Ma być **jedno** ostrzeżenie. Wzorcowe rozwiązanie liczy `promocja_aktywna()` raz:

```python
cena, promocja_liczona = _cena_pozycji(pozycja)
if pozycja.cena_promocyjna is not None and not promocja_liczona:
    ostrzezenia.append(f"promocja na pozycji {pozycja.nazwa!r} juz nie obowiazuje")
```

**To jest ogólniejsza lekcja:** test charakterystyki chroni to, co sprawdza.
Nie sprawdza liczby wystąpień ostrzeżenia, więc tego nie chroni.
Dlatego krok 4 labu - porównanie na całej bazie - nie jest ozdobnikiem.

---

## Dowód na 204 fakturach

```
IDENTYCZNE na wszystkich 204 fakturach
```

Porównywane pola: `netto`, `rabat_lacznie`, `vat`, `brutto`, `do_zaplaty`,
`termin_platnosci`, `vat_wg_stawek`, `ostrzezenia`.

32 testy pokrywają to, co ktoś wymyślił. 204 faktury pokrywają to, co jest w danych -
w tym cztery korekty, faktury w EUR i USD, pozycje z promocjami aktywnymi i wygasłymi,
faktury z zaliczkami i nieaktywnego kontrahenta. Kombinacje, których nikt nie wypisał.

**Potrzebne są oba.** Testy są szybkie i mówią, co się zepsuło. Porównanie na danych jest wolniejsze
i mówi tylko, **że** się zepsuło - ale łapie to, o czym nikt nie pomyślał.

---

## Czego agent zwykle próbuje

Cztery propozycje, które pojawiają się najczęściej. Wszystkie są **rozsądne**
i wszystkie zmieniają kwoty:

Wszystkie poniższe zostały **zmierzone**: każda zmiana zastosowana osobno, potem 32 testy
charakterystyki i porównanie na 204 fakturach z bazy.

| Propozycja | Testy | Różnice / 204 |
|---|---|---|
| „Zaokrąglenie VAT lepiej zrobić raz, od sumy netto" | 31/32 | **9** |
| „Próg rabatowy bez przeliczania kursem" | 31/32 | **20** |
| „Rabat można liczyć per pozycja, to prostsze" | 30/32 | **105** |
| „`rabat_pozycji()` zeruje rabat także przy **wygasłej** promocji - policzę rabat wprost: `rabat = pozycja.wartosc_netto * stawka_rabatu`" | 31/32 | **25** (naprawia znany błąd) |
| **„`zaliczka > 0` jest zbędne, wystarczy `zaliczka > brutto`"** | **32/32 ✓** | **4** |

### Pułapka, której nie łapią testy

Ostatni wiersz jest najważniejszy i najmniej oczywisty.

```python
if zaliczka > 0 and zaliczka > brutto:      # było
if zaliczka > brutto:                       # „uproszczone"
```

Wygląda na czyste usunięcie redundancji: skoro `zaliczka` jest kwotą, to `> brutto`
wystarczy. **Wszystkie 32 testy przechodzą.**

Ale korekta ma **ujemne brutto**. Przy zaliczce `0` warunek `0 > -5400` jest prawdziwy,
więc zaliczka zostaje sklampowana do `brutto`, a `do_zaplaty` spada z **−5400,00 do 0,00**.
Do tego pojawia się fałszywe ostrzeżenie „zaliczka wyzsza niz kwota faktury".

Cztery korekty w bazie. Zero czerwonych testów. **Łapie to wyłącznie krok 4** -
porównanie na całych danych.

### Czego NIE należy tu oczekiwać

Kuszące jest wpisanie na tę listę „uproszczenia warunku na cenę promocyjną":

```python
promocja_liczona = rabaty.promocja_aktywna(pozycja)
cena = pozycja.cena_promocyjna if promocja_liczona else pozycja.cena_jednostkowa
```

**Ta zmiana jest w pełni zachowawcza: 32 testy zielone, 0 różnic na 204 fakturach.**
Powód siedzi w `app/rabaty.py:52-55` - `rabat_pozycji()` ma **własny** guard
`if pozycja.cena_promocyjna is not None: return Decimal("0")`. Wygasła promocja i tak nie
dostaje rabatu, niezależnie od tego, jak wygląda warunek na cenę w `rozliczenia.py`.

Żeby naprawić znany błąd, trzeba **obejść** `rabat_pozycji()` - a lab w kroku 1 zabrania
ruszać `app/rabaty.py`. To jest dobra wiadomość: **granica zakresu chroni przed tą pomyłką
skuteczniej niż czujność.**

Druga propozycja jest szczególnie podstępna, bo **agent ma rację co do meritum**.
To naprawdę jest błąd. Ale naprawa błędu w commicie refaktoryzacyjnym oznacza, że:

- diff refaktoryzacji przestaje być weryfikowalny przez testy charakterystyki,
- zmiana kwot wchodzi na produkcję bez decyzji biznesu,
- nie da się jej cofnąć osobno, bo siedzi w środku 136 linii zmian.

**Refaktoryzacja i zmiana zachowania nie trafiają do jednego commita.** To jest twarda reguła,
nie preferencja stylistyczna.

Propozycja zgłoszona przez agenta osobno i niezastosowana oznacza lab zaliczony
tak, jak trzeba. Propozycja trafia do backlogu jako zgłoszenie z uzasadnieniem
i wyliczoną różnicą 54 zł na przykładzie.

---

## Najczęstsze potknięcia

**Rozbicie na dwadzieścia funkcji.** Cel to jeden ekran dla funkcji głównej, nie rekord
liczby funkcji. Nazwy `_krok_1`, `_etap_walidacji_2` są gorsze niż jedna długa funkcja,
bo nie niosą informacji, a dokładają skakanie po pliku.

**Zmiana kolejności ostrzeżeń.** Lista `ostrzezenia` jest częścią odpowiedzi API.
Testy sprawdzają obecność, nie kolejność - ale klient może polegać na pierwszym elemencie.
Porównanie na 204 fakturach zestawia listy posortowane; ostrożniejszy wariant zestawia
je nieposortowane.

**Zatrzymanie się na zielonych testach.** To jest najczęstszy błąd w tym labie.
Testy zielone to warunek konieczny, nie wystarczający.
