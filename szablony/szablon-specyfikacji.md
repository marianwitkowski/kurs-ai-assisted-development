# Specyfikacja: <nazwa zmiany>

Status: szkic | do przeglądu | zatwierdzona · Iteracja N · Autor wymagania: <rola>

## 1. Wymaganie biznesowe

Jeden akapit, **językiem biznesu**. Po co to jest, komu służy, co się zmieni,
gdy to powstanie. Bez rozwiązania technicznego.

## 2. Zakres

**Robimy:**
- …

**Świadomie nie robimy w tej iteracji:**
- …

> Zakres negatywny jest ważniejszy od pozytywnego. To, co masz zrobić, wynika z wymagania.
> To, czego masz **nie** robić, nie wynika z niczego - musi być napisane.

## 3. Reguły

| # | Reguła |
|---|---|
| R1 | Jednoznaczna, sprawdzalna, jedno zdanie. |
| R2 | Każde twierdzenie o istniejącym kodzie z plikiem i numerem linii. |

## 4. Kryteria akceptacji

**Liczby, nie opisy.** Minimum sześć przypadków, w tym przypadki brzegowe
i **pary graniczne** (tuż pod progiem i tuż nad nim).

| # | Dane wejściowe | Oczekiwany wynik |
|---|---|---|
| A1 | … | … |
| A2 | przypadek brzegowy | … |
| A3 | druga strona tego samego progu | … |

Kryterium, którego nie da się zamienić w test, nie jest kryterium akceptacji.

## 5. Ryzyka

| Ryzyko | Gdzie (plik:linia) | Jak ograniczamy |
|---|---|---|
| … | … | … |

Ryzyko bez lokalizacji w kodzie jest ogólnikiem.

## 6. Otwarte pytania

**Ta sekcja nie może być pusta.** Jeżeli jest - niepewność została przeniesiona
do sekcji „Reguły", gdzie wygląda na ustaloną.

1. …
2. …

## 7. Plan realizacji

Kolejność ma znaczenie: **najdroższe zmiany na koniec.** Kroki dotykające tylko nowych
plików dają się odrzucić bez konsekwencji.

1. … (nowe pliki)
2. … (nowe pliki)
3. … (istniejący kod)
