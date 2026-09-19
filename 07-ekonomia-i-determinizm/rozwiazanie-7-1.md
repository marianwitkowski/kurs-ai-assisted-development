# Rozwiązanie wzorcowe - lab 7.1

Ten lab nie ma artefaktu w repozytorium. Ma liczby zmierzone samodzielnie.
Poniżej to, co powinny pokazać, i jak je czytać.

---

## Krok 2 i 3 - istota pomiaru

To samo pytanie, dwie sesje:

| | Sesja rozdęta | Sesja po `/clear` |
|---|---|---|
| Kontekst przed pytaniem | 30-50% okna | 4-6% |
| Odpowiedź | identyczna | identyczna |
| Tokeny wejściowe | cały zgromadzony kontekst | prompt systemowy + pytanie |

**Odpowiedź jest identyczna.** Cała różnica to koszt.

Kluczowe zdanie, które ma zostać z tego labu:

> Pytanie warte dwudziestu tokenów niesie ze sobą cały kontekst zgromadzony wcześniej -
> i tak będzie przy **każdym** następnym pytaniu w tej sesji.

Dlatego `/clear` między niepowiązanymi zadaniami jest najtańszą optymalizacją,
jaka istnieje: kosztuje jedno naciśnięcie i działa natychmiast.

### Dlaczego nie „okno ma milion tokenów"

Okno to **sufit**, nie budżet. Dwie rzeczy dzieją się jednocześnie:

- **płaci się** za wszystko, co w nim siedzi, przy każdym żądaniu,
- **jakość spada** - instrukcja utopiona wśród czterdziestu przeczytanych plików
  działa słabiej niż ta sama instrukcja w czystej sesji.

Druga konsekwencja jest mniej oczywista i ważniejsza.

---

## Krok 4 - statystyki cache

Linia do odszukania w `/usage`:

```
Prompt cache (main): 14 requests · 91% of input tokens from cache · 2 misses
                     (last 6m 10s ago, 310.2k tokens re-cached) · warm (1h TTL, last activity 40s ago)
```

| Element | Co znaczy |
|---|---|
| `% of input tokens from cache` | ile z wejścia nie zostało przeliczone od nowa |
| `misses` | żądania, które przetworzyły ponownie to, co mogły wziąć z cache |
| `warm` / `cold` | czy prefiks jest jeszcze w cache |
| `1h TTL` | **subskrypcja**; na kluczu API domyślnie 5 minut, ale 1 h da się włączyć (`promptCacheTtl`) |

**Różnica TTL zmienia sposób pracy.** Na subskrypcji przerwa na kawę nic nie kosztuje -
po powrocie cache jest ciepły. Na kluczu API po piętnastu minutach pierwszy prompt
przelicza cały kontekst od nowa.

### Gdy trafień jest zero

Najczęstsze przyczyny, w kolejności częstości:

1. **Przełączanie modelu między pytaniami.** Cache jest przypisany do modelu.
2. Zmiana zestawu serwerów MCP - `tools` idzie **przed** `system`, więc unieważnia wszystko.
3. Edycja `CLAUDE.md` w trakcie sesji.
4. Coś zmiennego w prefiksie: znacznik czasu, identyfikator żądania.

To jest jedyna wada cache'u, o której trzeba wiedzieć: **gdy nie działa, nic się nie psuje.**
Wszystko odpowiada poprawnie, tylko drożej. Bez zajrzenia w tę linię nie ma jak zauważyć.

---

## Krok 1 - czego szukać w `/usage` na subskrypcji

**Paski limitu planu** - to jest realny budżet. Blok `Session` pokazuje też kwotę
w dolarach, ale na Pro/Max jest ona liczona lokalnie po cenniku katalogowym
i **nie ma związku z rachunkiem**. Z dokumentacji:

> The Session block in `/usage` shows API token usage and is intended for API users.
> Claude Max and Pro subscribers have usage included in their subscription, so the session
> cost figure isn't relevant for billing purposes.

**Atrybucja** jest tym, na co naprawdę warto patrzeć: pokazuje, ile zużycia idzie
na skille, subagentów, pluginy i **poszczególne serwery MCP**.

Typowe znalezisko: podłączony serwer MCP, którego nikt nie używa, a który kosztuje
kilka procent każdej sesji. `/mcp` pozwala go wyłączyć.

**Flagi zachowań** zapalają się, gdy coś odpowiada za ponad 10% zużycia - najczęściej
`long context` albo `cache misses`. To jest gotowa diagnoza.

---

## Wzorcowa notatka

```markdown
# Pomiar - lab 7.1

## Kontekst

| Moment | % okna | Uwagi |
|---|---|---|
| Świeża sesja | 5% | prompt systemowy + narzędzia + CLAUDE.md |
| Po trzech "przeczytaj wszystko" | 38% | app/ + tests/ + docs/ + specyfikacje/ |
| Małe pytanie w rozdętej sesji | +38% wejścia | odpowiedź: app/terminy.py:8 |
| To samo po /clear | +5% wejścia | odpowiedź identyczna |

Stosunek: ~7× więcej tokenów wejściowych za tę samą odpowiedź.

## Prompt cache
- 89% tokenów wejściowych z cache
- 1 chybienie (po przełączeniu modelu - moja wina)
- warm, TTL 1 h (subskrypcja)

## Atrybucja z /usage
| Źródło | Udział |
|---|---|
| skille | 3% |
| subagenci | 0% |
| serwer MCP, którego nie używam | 6% |

## Trzy rzeczy, które zmieniam od jutra
1. /clear po każdym zamkniętym zadaniu, nie „jak się zrobi ciasno".
2. Wyłączam serwery MCP, których nie używam w danym projekcie.
3. Nie przełączam modelu w środku sesji - jak trzeba inny, to /clear i od nowa.
```

---

## Najczęstsze potknięcia

**Brak `/clear` między krokiem 2 a 3.** Wtedy porównywana jest suma, nie przyrost,
i wychodzi, że „czysta sesja też dużo zużywa".

**Przełączanie modelu w kroku 4.** Zeruje trafienia cache, a wynikowa liczba
nic nie znaczy.

**Czytanie kwoty z bloku `Session` jako rachunku.** Na subskrypcji to jest szacunek
po cenniku katalogowym, a nie rzeczywisty koszt.

**Pominięcie atrybucji.** To jedyne miejsce, w którym widać koszt ponoszony jeszcze
przed rozpoczęciem pracy.
