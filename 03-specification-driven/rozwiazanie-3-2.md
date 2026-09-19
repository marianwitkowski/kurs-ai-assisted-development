# Rozwiązanie wzorcowe - lab 3.2

```bash
git diff lab-3-2-start lab-4-1-start
git show lab-4-1-start:app/odsetki.py
git show lab-4-1-start:tests/test_odsetki.py
```

```
 app/main.py           |  10 +++++
 app/odsetki.py        | 104 ++++++++++++++++++++++++++++++++++++
 app/raporty.py        |  39 +++++++++++-
 tests/__init__.py     |   0
 tests/test_odsetki.py | 114 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 266 insertions(+), 1 deletion(-)
```

**Pięć plików, jedna linia usunięta** (import w `raporty.py`). To jest diff mieszczący się
w zakresie. Wszystko ponad to jest sygnałem, że zakres się rozszerzył.

---

## Dlaczego funkcja jest rozbita na dwie

```python
def odcinki(podstawa, termin, na_dzien, wplaty=None) -> list[tuple[date, date, Decimal]]:
    """Dzieli okres opoznienia na odcinki o stalej podstawie."""

def odsetki_za_opoznienie(podstawa, termin, na_dzien, wplaty=None, stopa=STOPA_USTAWOWA) -> Decimal:
    """Kwota odsetek, zaokraglona tylko na koncu (R6)."""
```

Reguła R4 (wpłaty obniżają podstawę od dnia wpłaty) i R6 (zaokrąglenie tylko na końcu)
są niezależne. Rozdzielenie ich daje dwie korzyści:

- `odcinki()` da się przetestować osobno - i wzorcowe testy to robią
  (`test_odcinki_dziela_okres_bez_luk`: suma dni odcinków = 31, podstawy `[10000, 6000]`),
- błąd „zaokrąglam po każdym odcinku" staje się widoczny w jednym miejscu.

Gdyby to była jedna funkcja z pętlą, oba te błędy siedziałyby w środku, nietestowalne osobno.

---

## Trzy miejsca, w których model zwykle „poprawia" specyfikację

### 1. Rok przestępny (A9)

```python
ROK_BAZOWY = Decimal("365")
```

Dla okresu 2027-12-31 → 2028-12-31 to jest **366 dni podzielone przez 365** = 1 453,97 zł,
czyli więcej niż 14,5% od 10 000 zł.

Wygląda na błąd. Nie jest - reguła R5 mówi „365 dni zawsze, także w latach przestępnych".
Wzorcowy test ma to napisane w docstringu:

```python
def test_a9_rok_bazowy_jest_staly():
    """A9: 366 dni dzielone przez 365 -> 1 453,97, wiecej niz stopa roczna.

    To nie jest blad. Regula R5 mowi: rok bazowy 365 zawsze.
    """
```

**Docstring jest tu częścią rozwiązania, nie ozdobą.** Bez niego ktoś „naprawi" to za pół roku,
bo liczba wygląda źle. Z nim widzi, że ktoś już o tym pomyślał.

### 2. Zaokrąglanie po odcinku

```python
suma = Decimal("0")
for od, do, kwota in odcinki(...):
    dni = (do - od).days + 1
    suma += kwota * stopa * dni / ROK_BAZOWY
return vat.zaokraglij(suma)
```

`vat.zaokraglij()` jest wywołane **raz, poza pętlą**. W przypadku A4 wynik wychodzi taki sam
przy obu podejściach (97,73) - i dlatego to jest podstępne. Test tego nie złapie,
diff złapie.

### 3. Podstawa: `do_zaplaty`, nie `brutto`

Reguła R3 wskazuje `Rozliczenie.do_zaplaty` (`app/modele.py:75`), czyli brutto minus zaliczka.
Co dziesiąta faktura w bazie ma zaliczkę, więc na większości danych oba warianty dają
ten sam wynik. Błąd ujawni się na produkcji, na fakturze z zaliczką.

---

## Przypadek, którego specyfikacja nie rozstrzygała

Krok 4 zawierał celowo pułapkę:

> Reguła R7 każe funkcji zgłosić błąd dla faktury walutowej, ale raport zbiorczy
> nie może się z tego powodu wywalić. Rozstrzygnij to i powiedz mi, jak.

Specyfikacja mówi, co ma zrobić **funkcja** (zgłosić błąd), i milczy o tym, co ma zrobić
**raport**. To jest luka.

Rozwiązanie wzorcowe: raport łapie wyjątek i zapisuje pozycję z adnotacją, zamiast ją pomijać
po cichu:

```python
except odsetki.WalutaNieobslugiwana as e:
    wynik.append({"numer_faktury": f.numer, "pominieta": str(e)})
    continue
```

Sprawdzenie na kontrahencie 5 (faktury w EUR):

```
kontrahent 5: 8 pozycji, pominietych walutowych: 8
```

**Dlaczego adnotacja, a nie ciche pominięcie.** Dział rozliczeń dostaje raport i widzi
na nim osiem faktur bez odsetek z podanym powodem. Przy cichym pominięciu widziałby
pustą listę i uznał, że kontrahent płaci w terminie.

To jest wzorzec ogólniejszy: **przy milczeniu specyfikacji wybierać wariant, który
zostawia ślad.**

Dobra odpowiedź agenta w tym kroku to taka, która **najpierw mówi, że specyfikacja tego nie
rozstrzyga**, a dopiero potem proponuje. Kod napisany od razu, bez komentarza, to świeży
przykład dopowiedzenia - dwadzieścia minut po module o dopowiadaniu.

---

## Kolejność, która robi całą robotę

| Krok | Co dotyka | Koszt odrzucenia |
|---|---|---|
| 1. Testy | nowy plik | zero |
| 2. Implementacja | nowy plik | zero |
| 3. Review diffa | - | - |
| 4. Adapter + endpoint | **istniejące pliki** | realny |

Kroki 1-2 nie dotykają ani jednej linii istniejącego kodu. Można je wyrzucić i zacząć
od nowa bez konsekwencji. Dopiero krok 4 wchodzi w `app/raporty.py` i `app/main.py`.

To jest ta sama zasada, co w specyfikacji: **układać pracę tak, żeby najdroższe zmiany
były ostatnie.** Nie dlatego, że tak wypada, tylko dlatego, że wtedy najczęstszy błąd
- odrzucenie po drodze - kosztuje najmniej.

---

## Najczęstsze potknięcia

**Testy napisane po implementacji.** Rozstrzyga historia: `git log --oneline` powinno
pokazać commit z testami przed commitem z kodem, albo przynajmniej `make test` z błędem
`ImportError` po kroku 1.

Test napisany po kodzie nie jest bezwartościowy - łapie przyszłe regresje tak samo dobrze.
Ryzyko jest inne: **powiela założenia implementacji**, także te błędne. Test napisany
ze specyfikacji sprawdza, czy kod robi to, co miał robić; test napisany z kodu sprawdza,
czy kod robi to, co robi.

**Liczby przeliczone przez agenta.** Prompt w kroku 1 mówi wprost: „liczby bierz dosłownie
ze specyfikacji, nie przeliczaj". Jeżeli agent policzył je sam i wyszło mu 123,16 zamiast
123,15, to test będzie zielony na kodzie, który liczy o grosz za dużo.

**`from datetime import datetime` i `datetime.utcnow()` w nowym module.** Agent kopiuje wzorzec
z `app/raporty.py`. Wzorcowe `app/odsetki.py` nie ma żadnej daty domyślnej - `na_dzien`
jest parametrem obowiązkowym na poziomie funkcji czystej. Ryzyko ze specyfikacji, sekcja 5,
ostatni wiersz.

**Dodanie zapisu not do bazy.** Sekcja 2 wymienia to wprost jako poza zakresem.
`CREATE TABLE noty` w diffie oznacza cofnięcie zmiany i ponowne przeczytanie sekcji 2.
