# Lab 4.2 - Odtworzenie intencji i testy zabezpieczające

**Czas: ~35 min** · **Tag startowy: `lab-4-2-start`** · **Produkt: `tests/test_charakterystyka_rozliczen.py`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-4-2-start
make test          # ma przejść: testy odsetek z labu 3.2
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-4-1"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.
>
> **Ten lab kończy się commitem, a `git checkout <tag>` stawia repozytorium
> w odpiętym `HEAD`.** Commit nie należy wtedy do żadnej gałęzi i przy skoku
> na kolejny tag przestaje być osiągalny. Git ostrzeże o tym po angielsku
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-4-2`
> **przed** skokiem.

---

## Cel

Wydobyć z `oblicz_fakture()` reguły, których nikt nie zapisał, **odróżnić regułę od błędu**,
i utrwalić jedno i drugie testem. To jest najważniejszy lab pierwszego dnia.

---

## Krok 1 - zachowanie, nie kod (8 min)

```
Przeczytaj oblicz_fakture() w app/rozliczenia.py i funkcje, które woła.

Opisz jej zachowanie jako listę reguł w formie:
"JEŻELI <warunek wejściowy> TO <obserwowalny skutek na wyniku>".

Zasady:
- Nie opisuj struktury kodu ("iteruje po pozycjach", "sprawdza warunek").
- Nie używaj nazw zmiennych lokalnych.
- Przy każdej regule podaj plik i numer linii, z której ją odczytałeś.
```

Powinno wyjść kilkanaście reguł. Jeśli dostałeś opis w stylu „funkcja waliduje dane wejściowe,
następnie oblicza sumę netto…" - to jest przepisany kod. Powtórz prompt, podkreślając
formę „JEŻELI… TO…".

---

## Krok 2 - zaskoczenia (5 min)

```
Które z tych zachowań zaskoczyłyby programistę, który zna domenę fakturowania,
ale nie zna tego kodu? Wypisz je od najbardziej zaskakującego, z numerami linii.
```

To wydobywa dokładnie te miejsca, gdzie siedzi nieudokumentowana decyzja.
Spodziewaj się czterech-pięciu. Zapisz je - w kroku 3 będziesz je klasyfikował.

---

## Krok 3 - reguła czy błąd (7 min)

```
Dla każdego zaskakującego zachowania powiedz, czy to:
(a) celowa reguła biznesowa,
(b) błąd,
(c) nie da się rozstrzygnąć na podstawie kodu.

Przy (a) i (b) podaj, JAKI DOWÓD w repozytorium to potwierdza.
Jeżeli dowodu nie ma - klasyfikacja to (c).
```

**Ostatnie zdanie jest całym promptem.** Bez niego dostaniesz stanowcze „to jest celowa reguła"
bez cienia dowodu - dokładnie tak, jak w labie 2.1.

Zwróć uwagę na jedno miejsce: `app/rabaty.py:52-55`.

```python
def rabat_pozycji(pozycja: PozycjaFaktury, stawka: Decimal) -> Decimal:
    if pozycja.cena_promocyjna is not None:
        return Decimal("0")
    return pozycja.wartosc_netto * stawka
```

Ten jeden `if` obsługuje **dwa różne przypadki**. Zapytaj wprost:

```
Ten warunek sprawdza tylko, czy pole cena_promocyjna jest ustawione.
Co się dzieje, gdy promocja JUŻ WYGASŁA - pozycja jest liczona po cenie pełnej?
Sprawdź to w app/rozliczenia.py i powiedz, czy dostaje rabat progowy.
```

---

## Krok 4 - testy charakterystyki (12 min)

```
Napisz tests/test_charakterystyka_rozliczen.py.

Zasady - przeczytaj je uważnie, bo od nich zależy sens tych testów:
- Testy utrwalają zachowanie, które funkcja ma TERAZ, nie to, które uważasz
  za poprawne.
- Wartości oczekiwane wylicz, URUCHAMIAJĄC funkcję, nie z własnych obliczeń.
- Jeżeli jakaś wartość wygląda na błędną, zapisz ją taką, jaka jest, i dodaj
  komentarz "# WYGLADA NA BLAD - do potwierdzenia u biznesu".
- Nie zmieniaj ani jednej linii w app/.

Pokryj: fakturę bez rabatu, każdy z trzech progów, rabat indywidualny z limitem,
pozycję z promocją aktywną, pozycję z promocją wygasłą, tę samą pozycję bez pola
cena_promocyjna (jako punkt odniesienia), wiele stawek VAT, zaokrąglanie VAT,
fakturę walutową, korektę, zaliczkę, stałego klienta, termin wypadający w weekend.
```

### Uwaga o oknach promocji

`rabaty.promocja_aktywna()` czyta bieżącą datę z zegara (`app/rabaty.py:29`).
Jeżeli w teście dasz wąskie okno promocji, test przestanie przechodzić po upływie daty.
Użyj okien szerokich:

```python
PROMOCJA_AKTYWNA = (date(2020, 1, 1), date(2030, 12, 31))
PROMOCJA_WYGASLA = (date(2024, 1, 1), date(2024, 6, 30))
```

To jest obejście, nie rozwiązanie. Prawdziwym rozwiązaniem jest wstrzyknięcie daty -
i to jest zmiana zachowania, więc nie robimy jej dzisiaj.

### Weryfikacja

```bash
make test
```

**Wszystkie testy muszą przejść na niezmienionym kodzie.** To jest definicja testu
charakterystyki. Jeśli któryś nie przechodzi - to nie kod jest zły, tylko test opisuje
twoje wyobrażenie, a nie rzeczywistość.

```bash
git diff app/          # MUSI być puste
git add tests/ && git commit -m "Testy charakterystyki dla oblicz_fakture()"
```

---

## Krok 5 - jeden test, który jest wart całego labu (3 min)

Sprawdź, czy masz **parę** testów: pozycja z promocją wygasłą i ta sama pozycja bez pola
`cena_promocyjna`. Jeśli nie - dopisz:

```python
def test_pozycja_z_wygasla_promocja_placi_cene_pelna_i_tez_nie_dostaje_rabatu():
    # netto = 9075.00, rabat = 225.00

def test_ta_sama_pozycja_bez_pola_cena_promocyjna_dostaje_rabat():
    # netto = 9021.00, rabat = 279.00
```

Ta sama cena jednostkowa, ten sam próg, **różnica 54 zł** - wyłącznie dlatego, że w jednym
przypadku pole `cena_promocyjna` jest ustawione, choć promocja dawno wygasła.

Pojedynczy test niczego nie pokazuje. Para pokazuje wszystko.

---

## Kryteria zaliczenia

- [ ] Wszystkie testy przechodzą **na niezmienionym** `app/`.
- [ ] `git diff app/` jest puste.
- [ ] Testy porównują wejście z wyjściem, nie zaglądają do funkcji prywatnych.
- [ ] Liczby są utrwalone, a nie przeliczane w teście tą samą formułą co w kodzie.
- [ ] Masz **parę** testów pokazujących różnicę 54 zł.
- [ ] Miejsca wyglądające na błąd są utrwalone i opatrzone komentarzem.
- [ ] Umiesz powiedzieć, które zachowania są regułą, które błędem, a których
      nie da się rozstrzygnąć bez rozmowy z biznesem.

## Pułapki

**Test, który liczy to samo, co kod.**

```python
assert w.vat == w.netto * Decimal("0.23")     # ŹLE - zawsze zielony
assert w.vat == Decimal("142.60")             # DOBRZE
```

**„Poprawienie" kodu przy okazji pisania testów.** Jeśli `git diff app/` nie jest puste -
cofnij. Testy charakterystyki piszemy **na kodzie, którego nie ruszamy.**

**Test napisany z własnych obliczeń.** 7 500 × 3% = 225, to łatwo policzyć w głowie.
Ale przy `netto=9075.00` z dwóch pozycji, z których jedna ma wygasłą promocję, ręczne
liczenie prowadzi do testu, który opisuje twoje wyobrażenie. Uruchom funkcję i przepisz wynik.

**Wąskie okno promocji.** Test z `promocja_do=date(2026, 12, 31)` zacznie się wywalać
1 stycznia 2027 i nikt nie będzie wiedział dlaczego.

**Testowanie funkcji prywatnych.** Test charakterystyki ma opisywać **kontrakt**, a nie
wnętrze. Jutro zrefaktoryzujesz wnętrze i testy mają przetrwać.

---

[Rozwiązanie wzorcowe](rozwiazanie-4-2.md) · [Następny lab](lab-4-3.md)
