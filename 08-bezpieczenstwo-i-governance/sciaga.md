# Ściąga - moduł 8

## Uwierzytelnienie ≠ autoryzacja

| | Pytanie | Przykład |
|---|---|---|
| Uwierzytelnienie | kto to jest? | `kontrahent_z_tokenu(authorization)` |
| **Autoryzacja** | czy wolno mu to zobaczyć? | `zasob.wlasciciel_id != kontrahent_id` |

Szukać miejsc, w których **wynik funkcji autoryzacyjnej jest wywoływany, ale nieużywany**.
Analiza statyczna tego nie złapie.

**Cudzy zasób → 404, nie 403.** 403 potwierdza, że zasób istnieje.

## Checklista przeglądu bezpieczeństwa

1. Wstrzyknięcie SQL - także przy warunkach budowanych dynamicznie
2. **Autoryzacja per zasób** - dla każdego endpointu zwracającego dane
3. Sekrety - też w testach i danych przykładowych
4. Walidacja wejścia - typ, zakres, długość, format
5. Wyciek danych w odpowiedzi - pola wewnętrzne, ślady stosu
6. Ścieżki plików z danych użytkownika
7. Nowe zależności

Każdy punkt przechodzimy, przy niedotyczących wpisujemy `n/d`. Brak ustalenia
musi być odróżnialny od braku sprawdzenia.

## Prompt injection

To samo co SQL Injection - **mieszanie instrukcji z danymi**.
Różnica: **nie ma odpowiednika placeholderów.**

| Obrona | Rodzaj |
|---|---|
| Zdanie w prompcie systemowym | **instrukcja**, nie zabezpieczenie |
| Limit długości wejścia | heurystyka |
| Wykrycie wzorców instrukcji | heurystyka |
| **Zamknięty zbiór wartości w schemacie** | **gwarancja** |
| **Decyzja progowa w kodzie** | **gwarancja** |
| **Ścieżka do człowieka** | **gwarancja** |

Podejrzanego tekstu **nie sanityzujemy** - kierujemy do człowieka.
Sprawdzenie **przed** wywołaniem modelu, **po** regule twardej.

**Wektory, o których się zapomina:** dane w bazie · treść pliku z zależności ·
wyjście komendy (nazwa brancha, treść zgłoszenia) · **serwer MCP** · pobrana strona.

## Sekrety

Trzy miejsca przecieku przy pracy z agentem: **plik kontekstowy** (czytany co sesję) ·
**wynik komendy** (`env`, `cat .env`) · **plik konfiguracyjny w repo**.

| Mechanizm | Skuteczność |
|---|---|
| `permissions.deny` na `Read(./.env)` | działa **natychmiast** |
| Skan sekretów w bramce | wysoka |
| Skan w CI | wysoka |
| Zasada w `CLAUDE.md` | prośba |

```bash
git log -p --all -- <plik> | grep -c "<wzorzec>"
```

> Usunięcie sekretu z pliku **nie usuwa go z repozytorium**.
> **Sekret trzeba unieważnić.** Przepisanie historii to kosmetyka wykonywana po tym.

## Review kodu tworzonego z agentem

Uważniej: **zakres diffa** · **zmienione testy** · **usunięte warunki brzegowe** ·
nowe zależności · kod na granicy zaufania · obsługa błędów (`except: pass`).

**Review nie sprawdza, czy „to" jest właściwe** - dlatego specyfikacja przechodzi
review osobno.

Wszystko sprawdzalne mechanicznie - **przed** review.

## Dane

Nigdy, w żadnym narzędziu: sekrety · dane osobowe · dane klientów objęte poufnością ·
zawartość systemów produkcyjnych.

Dotyczy promptów, plików kontekstowych, załączników i **wyników komend agenta**.

Dane testowe: **generator syntetyczny**, nie anonimizowana kopia produkcji.

## Pytania do prawników

**RODO:** czy trafiają dane osobowe? · podstawa prawna i umowa powierzenia? ·
gdzie fizycznie i jak długo?

**AI Act - rozróżnienie, które rozstrzyga najwięcej:**
- używamy AI **do wytwarzania** oprogramowania → narzędzie pracy,
- nasz produkt **zawiera model** → obowiązki dotyczące produktu.

## Egzekwowanie

Przy każdej zasadzie dopisać kolumnę **czym to egzekwujemy**:
hook / CI / skill / `permissions.deny` / `CLAUDE.md` (**prośba**) / **proces** / **nic**.

Wiersze z „nic" to lista zadań. Wiersze z „proces" są w porządku -
pod warunkiem że wiadomo, że to proces.
