# Ściąga - moduł 4

## Trzy pytania oceniające ryzyko

1. Co się stanie **bez zmiany**? (nic / dług / awaria / strata pieniędzy)
2. Co się stanie **przy zmianie z pomyłką**? (nic / test złapie / produkcja)
3. **Czym sprawdzić**, że nic się nie zepsuło? (testy / ręcznie / **nijak**)

> „Nijak" na pytanie 3 → pozycja **nie nadaje się do naprawy**, nadaje się do napisania testu.

## Prompty do legacy

**Zachowanie, nie kod:**
```
Opisz zachowanie jako listę reguł: "JEŻELI <warunek> TO <skutek na wyniku>".
Nie opisuj struktury kodu. Przy każdej regule podaj numer linii.
```

**Zaskoczenia:**
```
Które zachowania zaskoczyłyby programistę, który zna domenę, ale nie zna tego kodu?
```

**Reguła czy błąd:**
```
(a) celowa reguła / (b) błąd / (c) nie da się rozstrzygnąć z kodu.
Przy (a) i (b) podaj, JAKI DOWÓD w repozytorium to potwierdza.
Jeżeli dowodu nie ma - to (c).
```

**Testy charakterystyki:**
```
Utrwalają zachowanie, które funkcja ma TERAZ.
Wartości wylicz URUCHAMIAJĄC funkcję, nie z własnych obliczeń.
Wartość wyglądająca na błędną: zapisz JAKA JEST + komentarz.
Nie zmieniaj ani jednej linii w app/.
```

**Refaktoryzacja zachowawcza:**
```
Te same wejścia → te same wyjścia CO DO GROSZA. Ostrzeżenia identyczne.
Nie zmieniaj testów. Uważasz, że coś jest błędem - NAPISZ, ale nie poprawiaj.
```

## Reguła kontra błąd

| | Reguła biznesowa | Błąd |
|---|---|---|
| „Uproszczenie" | **strata pieniędzy** | poprawa |
| Test utrwala | na stałe | tymczasowo, z komentarzem |
| Zmiana wymaga | decyzji biznesu | poprawki |

**Wygląd nie rozstrzyga.** Reguła w legacy wygląda dokładnie jak błąd.

## Kolejność w legacy

```
zrozum → testy na obecny stan → testy ZIELONE na niezmienionym kodzie
       → refaktor → testy zielone bez zmian w testach → dopiero zmiana zachowania
```

## Cztery poziomy obrony przed „uproszczeniem"

| Poziom | Rodzaj |
|---|---|
| Prompt | **prośba** |
| `CLAUDE.md` | **prośba** |
| Testy charakterystyki | **fakt** |
| Hook uruchamiający testy | **fakt** |

## Sygnały w wypowiedzi agenta

„Uprościłem też…" · „Przy okazji poprawiłem…" · „Ten warunek wydawał się zbędny…" ·
„Ujednoliciłem zaokrąglanie…" · „To wyglądało na pomyłkę, więc…"

## Antywzorzec testu

```python
assert wynik.vat == wynik.netto * Decimal("0.23")   # ŹLE - zawsze zielony
assert wynik.vat == Decimal("142.60")               # DOBRZE
```

## Sprawdzenie refaktoryzacji poza testami

```bash
git stash -q && <zapisz wyniki> > /tmp/przed.txt
git stash pop -q && <zapisz wyniki> > /tmp/po.txt
diff /tmp/przed.txt /tmp/po.txt
```
