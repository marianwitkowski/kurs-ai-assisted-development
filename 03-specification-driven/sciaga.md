# Ściąga - moduł 3

## Tryb planowania

| Sposób | Kiedy |
|---|---|
| `Shift+Tab` | w trakcie sesji |
| `/plan` | włącza tryb planowania w sesji; `/plan open` - bieżący plan |
| `claude --permission-mode plan` | cała sesja |
| `{"permissions": {"defaultMode": "plan"}}` w `.claude/settings.json` | cały projekt |

Pasek statusu: `⏸ plan mode on`. Wyjście bez zatwierdzania: `Shift+Tab`.

> Na Pro/Max sesja startuje w trybie **auto**. Cykl: auto → Manual → accept edits → plan.

**Zatwierdzenie:** „w trybie auto" / „z auto-akceptacją edycji" / „ręcznie zatwierdzam edycje" /
„planujemy dalej".
`Ctrl+G` - poprawka planu ręcznie w edytorze przed akceptacją.

## Czego żądać od planu

1. Co ustalono **z kodu** - z plikami i liniami.
2. **Jakie założenia przyjęto** - wypisane osobno.
3. Ryzyka - co może się zepsuć poza obszarem zmiany.
4. Jak to zweryfikujemy.

Punkt 2 jest najważniejszy: **założenia wypisane to założenia, które możesz odrzucić.**

## Cztery techniki przeciw dopowiadaniu

```
Wypisz listę pytań, na które musisz znać odpowiedź. Nie odpowiadaj na nie sam.
```
```
Podziel odpowiedź: USTALONE (z pliku i linii) / ZAŁOŻONE (co przyjąłeś).
Jeżeli ZAŁOŻONE jest puste, czegoś nie zauważyłeś.
```
```
Zakres: tylko <pliki>. Nie zmieniaj: <pliki>.
Wymaga zmiany poza zakresem - zatrzymaj się i powiedz.
```
```
Kryteria akceptacji jako liczby: <wejście> → <oczekiwany wynik>.
```

## Czego unikać w prompcie

| Nie pisz | Napisz |
|---|---|
| „w razie potrzeby dodaj…" | wprost, czy ma dodać |
| „zrób to porządnie" | konkretne kryterium |
| „obsłuż przypadki brzegowe" | wymień które |
| „jak w reszcie projektu" | wskaż plik wzorcowy |
| „na razie uproszczona wersja" | wypisz, czego **nie** robimy |

## Workflow

```
wymaganie → specyfikacja → plan → implementacja → testy → review
             ↑ odrzuć tanio        ↑ odrzuć drogo
```

Specyfikacja zostaje w `specyfikacje/*.md`: kontekst dla agenta, dokumentacja decyzji,
przedmiot review, da się zdiffować.

## Sekcje specyfikacji

1. Wymaganie biznesowe · 2. **Zakres - w tym czego NIE robimy** · 3. Reguły ·
4. **Kryteria akceptacji jako liczby, z parami granicznymi** · 5. Ryzyka z liniami ·
6. **Otwarte pytania - nie mogą być puste** · 7. Plan (najdroższe zmiany na koniec)
