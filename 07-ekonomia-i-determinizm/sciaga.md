# Ściąga - moduł 7

## Kolejność obniżania kosztów

```
1. higiena kontextu (/clear, celowane czytanie)   darmowe
2. prompt caching                                 darmowe
3. Batch API                                      −50%, kosztuje czas
4. niższy effort                                  kosztuje głębokość
5. tańszy model                                   kosztuje jakość I CACHE
```

**Zmiana modelu jest ostatnia.** Cache jest przypisany do modelu.

## Prompt caching

**Kolejność renderowania: `tools` → `system` → `messages`.**
Stabilne na początek, zmienne po ostatnim punkcie cache'owania.

```python
system=[{"type": "text", "text": PROMPT, "cache_control": {"type": "ephemeral"}}],
messages=[{"role": "user", "content": zmienne}],
```

Maks. **4 punkty** na żądanie. Minimalny prefiks 512-4096 tokenów (krócej - nie zacache'uje się).

**TTL domyślny: 1 h na subskrypcji, 5 min na kluczu API.** To domyślka, nie limit -
na kluczu API godzinę włącza `promptCacheTtl: "1h"` albo `ENABLE_PROMPT_CACHING_1H=1`;
w API bezpośrednio `cache_control: {"type":"ephemeral","ttl":"1h"}`.
Godzina obejmuje wyłącznie główną rozmowę w ramach limitu planu: subagenci, workflows,
forki i kompakcja mają 5 min nawet na subskrypcji (`subagentPromptCacheTtl`), a po
przejściu na usage credits główna rozmowa też spada do 5 min.

**Weryfikacja: `usage.cache_read_input_tokens`.** Zero przy powtórzeniach = cichy invalidator.

Cisi zabójcy: `datetime.now()` w prompcie · ID żądania · nieposortowany JSON ·
dynamiczna lista narzędzi (`tools` idzie **przed** `system`) · **zmiana modelu**.

## Kontrola kontekstu

| Narzędzie | Kiedy |
|---|---|
| `/clear` | między niepowiązanymi zadaniami - **kosztuje zero** |
| `/compact <instrukcja>` | gdy potrzebna ciągłość (sam jest dużym żądaniem) |
| `# Compact instructions` w `CLAUDE.md` | stałe instrukcje kompakcji |
| Celowany prompt | podać **co ustalić**, nie **jak czytać** |

Hook `PreToolUse` filtrujący wyjście komendy:
```json
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow",
 "updatedInput": {"command": "pytest -q > /tmp/pytest.log 2>&1; k=$?; grep -E \"FAIL|ERROR\" /tmp/pytest.log | head -50; exit $k"}}}
```

> `updatedInput` zastępuje **całe** wejście narzędzia - w jq: `(.tool_input + {command: $filtered})`.
> Filtr musi zwrócić kod `pytest`, nie kod `head` - inaczej nieudane testy wyglądają jak udane.

## Batch API

50% ceny, asynchronicznie (zwykle <1 h, maks. 24 h).

```python
paczka = klient.messages.batches.create(requests=[Request(custom_id=..., params=...)])
klient.messages.batches.retrieve(paczka.id).processing_status   # aż "ended"
klient.messages.batches.results(paczka.id)
```

> **Wyniki w DOWOLNEJ kolejności.** Kluczowanie po `custom_id`, nigdy po pozycji.

## Pomiar

**Pro/Max:** `/usage` → paski limitu planu, **atrybucja** (skille, subagenci, MCP),
flagi zachowań (≥10% zużycia), `d`/`w`. Linia `Prompt cache (main)`.
Kwota z bloku `Session` **nie jest rachunkiem** - liczona lokalnie po cenniku katalogowym.

**Klucz API:** `usage.input_tokens`, `usage.output_tokens`, `usage.cache_read_input_tokens`.

Mierzy się **koszt na ukończone zadanie**, nie na zapytanie.

## Determinizm w produkcie

```
1. REGUŁA TWARDA w kodzie   → bez modelu (darmowe, powtarzalne - ale dopasowanie
                              fragmentu to nadal heurystyka)
2. MODEL + SCHEMAT          → tylko to, czego reguła nie objęła
3. WALIDACJA POZA SCHEMATEM → schemat gwarantuje kształt, nie sens
4. DECYZJA PROGOWA w kodzie → model proponuje, kod rozstrzyga
```

```python
class Wynik(BaseModel):
    wartosc: Literal["a", "b", "c"]
    pewnosc: float = Field(ge=0.0, le=1.0)

odp = klient.messages.parse(model=..., max_tokens=512,
                            messages=[...], output_format=Wynik)
odp.parsed_output
```

Surowy schemat: `output_config={"format": {"type": "json_schema", "schema": {...}}}`.
Parametr `output_format` na `create()` jest **przestarzały**.
Narzędzia: `strict: true` **na definicji narzędzia**, schemat z `additionalProperties: false`.

## Golden set

Trzy rzeczy, które czynią go użytecznym:

1. sprawdza **źródło decyzji**, nie tylko wynik,
2. działa **offline** (odpowiedzi modelu w pliku, testy na mocku),
3. zmiana wyniku jest **świadoma** - aktualizacja razem z uzasadnieniem w commicie.

> Próg pewności chroni przed niepewnością, **nie przed pewnym błędem**.
