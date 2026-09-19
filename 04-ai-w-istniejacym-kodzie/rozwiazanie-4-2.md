# Rozwiązanie wzorcowe - lab 4.2

```bash
git show lab-4-3-start:tests/test_charakterystyka_rozliczen.py
```

**20 testów w tym pliku** (32 w całym pakiecie, razem z testami odsetek z labu 3.2).
Poniżej to, co z nich wynika.

---

## Reguły wydobyte z kodu

Sześć zachowań, których nie widać z żadnego pojedynczego pliku:

| # | Reguła | Skąd |
|---|---|---|
| 1 | Stawka rabatu wyznaczana **raz dla całej faktury**, nie per pozycja | `app/rozliczenia.py:57-59` |
| 2 | Pozycja promocyjna **wlicza się do progu**, ale rabatu nie dostaje | `app/rozliczenia.py:45-50`, `app/rabaty.py:52-55` |
| 3 | Próg faktury walutowej liczony **po przeliczeniu kursem** | `app/rozliczenia.py:52-54` |
| 4 | VAT zaokrąglany **per pozycja**, suma to suma zaokrągleń | `app/vat.py:30-39` |
| 5 | Korekta **dziedziczy stawkę VAT** z faktury pierwotnej | `app/rozliczenia.py:90-100` |
| 6 | Stały klient (≥12 faktur) dostaje **+7 dni** terminu | `app/terminy.py:26-35` |

Plus jedno zachowanie, które jest **błędem** - o tym niżej.

---

## Cztery liczby, które warto zapamiętać

### Próg walutowy (reguła 3)

```
2 000 EUR × kurs 4,3120 = 8 624 PLN  →  próg 5 000 przekroczony  →  rabat 3%
2 000 PLN                            →  próg 5 000 nieprzekroczony  →  rabat 0%
```

Ta sama liczba na fakturze, inny rabat. To jest reguła, nie błąd: próg rabatowy jest
progiem wartości handlowej, a nie liczby wydrukowanej na dokumencie. Ale nikt tego
nie zapisał, więc przy pierwszej migracji ktoś to „ujednolici".

### Zaokrąglanie VAT (reguła 4)

```
Trzy pozycje po 10,11 zł:
  per pozycja:  3 × 2,33 = 6,99
  od sumy:      30,33 × 23% = 6,9759 → 6,98
```

Grosz różnicy. Na jednej fakturze nieistotny, na miesięcznym zestawieniu - pozycja
w uzgodnieniu z księgowością.

### Rabat indywidualny i limit

```
Kontrahent 11: próg 10% + indywidualny 8% = 18% → obcięte do 15%
60 000 × 15% = 9 000
```

### Termin stałego klienta

```
11 faktur historycznych → termin 2026-03-24
12 faktur historycznych → termin 2026-03-31
```

Próg jest twardy i nieudokumentowany. Faktura wystawiona dzień przed dwunastą ma inny termin
niż wystawiona dzień po.

---

## Reguła czy błąd - para testów, która rozstrzyga

To jest sedno całego labu. Trzy testy, ta sama pozycja, trzy różne wyniki:

| Test | Cena Licencji | Rabat pozycji | Netto faktury |
|---|---|---|---|
| promocja **aktywna** | 1 440,00 (promocyjna) | 0,00 | **8 715,00** |
| promocja **wygasła** | 1 800,00 (pełna) | 0,00 | **9 075,00** |
| **brak** pola `cena_promocyjna` | 1 800,00 (pełna) | 54,00 | **9 021,00** |

Dwa ostatnie wiersze: **ta sama cena, ten sam próg, różnica 54 zł.**

Wyjaśnienie jest w trzech linijkach:

```python
# app/rabaty.py:52-55
def rabat_pozycji(pozycja: PozycjaFaktury, stawka: Decimal) -> Decimal:
    if pozycja.cena_promocyjna is not None:
        return Decimal("0")
    return pozycja.wartosc_netto * stawka
```

Ten `if` sprawdza tylko, czy **pole jest ustawione**. Nie sprawdza, czy promocja obowiązuje.

**Przypadek pierwszy to reguła biznesowa:** rabat nie łączy się z promocją.
Sensowne, celowe, nie wolno ruszać.

**Przypadek drugi to błąd:** promocja wygasła, klient płaci pełną cenę - i traci rabat
progowy, który by mu się należał. Nikt tego nie chciał.

**Jeden warunek, dwa przypadki, przeciwne oceny.** Dlatego nie da się rozstrzygnąć
„reguła czy błąd" patrząc na kod. Trzeba rozstrzygnąć **per przypadek wejściowy** -
i dlatego narzędziem jest test, a nie czytanie.

### Jak to zapisać w teście

```python
def test_pozycja_z_wygasla_promocja_placi_cene_pelna_i_tez_nie_dostaje_rabatu():
    """WYGLADA NA BLAD (app/rabaty.py:52-55) - do potwierdzenia u biznesu.

    Promocja wygasla, wiec pozycja jest liczona po cenie pelnej 1 800 - i mimo to
    nie dostaje rabatu progowego (...)

    Porownaj z testem ponizej: ta sama cena, ten sam prog, rabat o 54,00 wiekszy.
    """
```

Test **utrwala błąd** i jednocześnie **mówi, że to błąd**. To nie jest sprzeczność -
to jest cała idea testu charakterystyki:

> Test charakterystyki nie mówi „tak ma być".
> Mówi „tak jest dzisiaj i jeśli to zmieniasz, rób to świadomie".

Gdyby ten test nie istniał, ktoś poprawiłby `rabaty.py` przy najbliższej okazji
i zmieniłby kwoty na fakturach, nie zauważając. Gdyby istniał bez komentarza -
błąd zostałby na zawsze, bo „testy tego pilnują".

---

## Okna promocji: obejście, nie rozwiązanie

```python
PROMOCJA_AKTYWNA = (date(2020, 1, 1), date(2030, 12, 31))
PROMOCJA_WYGASLA = (date(2024, 1, 1), date(2024, 6, 30))
```

`rabaty.promocja_aktywna()` czyta `datetime.utcnow()`, więc test z wąskim oknem zacznie się
wywalać po upływie daty. Szerokie okno odsuwa problem do 2031 roku.

To jest **obejście** i tak jest opisane w komentarzu w pliku testów. Prawdziwe rozwiązanie -
wstrzyknięcie daty jako parametru - jest zmianą sygnatury, czyli zmianą zachowania.
Nie robi się jej w labie o utrwalaniu zachowania.

**Zapisanie obejścia razem z powodem** jest tu tak samo ważne jak sam test.
Bez komentarza za trzy lata ktoś zobaczy datę 2030 i uzna ją za przypadkową.

---

## Czego te testy nie robią

- **Nie testują funkcji prywatnych.** Tylko wejście i wyjście `oblicz_fakture()`.
  Dzięki temu jutro przetrwają refaktoryzację wnętrza.
- **Nie liczą niczego samodzielnie.** Każda liczba została odczytana z uruchomionej funkcji.
- **Nie oceniają.** Poza komentarzami, które wprost mówią „to wygląda na błąd,
  do potwierdzenia u biznesu".

---

## Najczęstsze potknięcia

**Test, który powtarza formułę z kodu.**

```python
assert w.vat == w.netto * Decimal("0.23")
```

Ten test przejdzie także wtedy, gdy zaokrąglanie jest zepsute - bo powiela ten sam błąd.
Utrwalona liczba (`Decimal("142.60")`) nie ma tej wady.

**Brak pary porównawczej.** Test „pozycja z wygasłą promocją daje netto 9 075,00" sam z siebie
niczego nie pokazuje. Dopiero obok testu „ta sama bez pola promocyjnego daje 9 021,00"
widać, że coś jest nie tak. Wzorcowy plik ma tę parę w sąsiadujących funkcjach,
z komentarzem odsyłającym jeden do drugiego.

**„Poprawienie" kodu przy okazji.** `git diff app/` musi być puste. Jeśli agent naprawił
`rabaty.py`, żeby test „przechodził poprawnie" - masz test sprawdzający kod, który sam
przed chwilą napisał.

**Wartości przeliczone ręcznie.** `netto=9075.00` powstaje z dwóch pozycji, z których jedna
ma wygasłą promocję, a druga dostaje 3% rabatu. Policzenie tego w głowie jest wykonalne
i prowadzi do testu opisującego wyobrażenie. Uruchom funkcję, przepisz wynik.
