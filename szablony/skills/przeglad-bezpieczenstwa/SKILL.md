---
name: Przegląd bezpieczeństwa
description: Przegląd zmian w kodzie pod kątem bezpieczeństwa według stałej checklisty zespołu. Sprawdza wstrzyknięcia SQL, autoryzację per zasób, sekrety w kodzie, walidację danych wejściowych i wyciek danych w odpowiedziach. Zwraca raport w ustalonym formacie.
argument-hint: "[zakres, np. HEAD, staged, lab-1-1-start]"
allowed-tools: Bash(git diff *), Bash(git status *), Bash(git log *), Read, Grep, Glob
---

## Zakres do przejrzenia

Domyślnie: niezacommitowane zmiany. Jeżeli użytkownik podał argument, potraktuj go
jako zakres dla `git diff` (np. `staged`, `HEAD~1`, `lab-1-1-start`).

Stan roboczy w chwili wywołania:

!`git status --short`

Zmiany niezacommitowane:

!`git diff HEAD`

**Jeżeli oba powyższe bloki są puste**, a użytkownik nie podał argumentu, uruchom
`git diff lab-1-1-start` i przejrzyj to. Jeżeli podał - użyj jego zakresu.
Nie przeglądaj całego repozytorium, gdy masz konkretny diff.

## Checklista

Przejdź **wszystkie** pozycje po kolei. Żadnej nie wolno pominąć, nawet jeśli wydaje się
nie dotyczyć tego diffa - wtedy zapisz `n/d`.

1. **Wstrzyknięcie SQL.** Czy jakiekolwiek zapytanie jest budowane przez sklejanie stringów,
   f-string albo `%`? Parametry zapytania muszą iść przez placeholdery (`?`), nigdy przez
   interpolację. Sprawdź też fragmenty sklejane warunkowo.
2. **Autoryzacja per zasób.** Czy dla każdego endpointu zwracającego dane sprawdzane jest,
   że zasób należy do uwierzytelnionego podmiotu? Uwierzytelnienie (kto to jest)
   to nie to samo co autoryzacja (czy wolno mu to zobaczyć). Szukaj miejsc, w których
   wynik funkcji autoryzacyjnej jest wywoływany, ale nieużywany.
3. **Sekrety.** Czy w diffie są klucze API, hasła, tokeny, ciągi połączeń? Sprawdź też
   pliki konfiguracyjne, testy i dane przykładowe.
4. **Walidacja danych wejściowych.** Czy dane z zewnątrz są walidowane przed użyciem?
   Typ, zakres, długość, format. Szczególnie: identyfikatory z URL-a i parametry zapytań.
5. **Wyciek danych w odpowiedzi.** Czy odpowiedź zawiera więcej, niż powinien zobaczyć
   wywołujący? Pola wewnętrzne, komunikaty błędów ze szczegółami technicznymi, ślady stosu.
6. **Ścieżki plików.** Czy dane od użytkownika trafiają do operacji na plikach bez sprawdzenia?
7. **Zależności.** Czy diff dodaje nową zależność? Jeśli tak - wypisz ją osobno.

## Format raportu

Wypisz dokładnie w tej strukturze, bez dodatkowych sekcji:

```
# Przegląd bezpieczeństwa - <zakres>

## Ustalenia

| # | Waga | Punkt checklisty | Plik:linia | Opis | Proponowana poprawka |
|---|------|------------------|------------|------|----------------------|

## Checklista

| # | Punkt | Wynik |
|---|-------|-------|
| 1 | Wstrzyknięcie SQL | ok / ZNALEZIONO / n/d |
| 2 | Autoryzacja per zasób | |
| 3 | Sekrety | |
| 4 | Walidacja danych wejściowych | |
| 5 | Wyciek danych w odpowiedzi | |
| 6 | Ścieżki plików | |
| 7 | Zależności | |

## Czego nie sprawdzałem
<jednym zdaniem: co wykracza poza ten diff i wymaga osobnego przeglądu>
```

Waga: `krytyczna` (możliwy wyciek albo przejęcie danych), `wysoka` (podatność wymagająca
dodatkowych warunków), `średnia` (brak zabezpieczenia w głębi), `niska` (higiena).

## Zasady

- **Każde ustalenie musi mieć plik i numer linii.** Bez tego nie wpisuj go do tabeli.
- Nie zgłaszaj problemów stylistycznych ani wydajnościowych. To jest przegląd bezpieczeństwa.
- Nie poprawiaj kodu. Ten skill tylko raportuje.
- Jeżeli czegoś nie da się rozstrzygnąć z samego diffa - napisz to wprost zamiast zgadywać.
- Sekcja „Czego nie sprawdzałem" nie może być pusta.
