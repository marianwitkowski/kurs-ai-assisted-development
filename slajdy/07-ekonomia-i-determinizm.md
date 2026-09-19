---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 7'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Ekonomia i determinizm

## Moduł 7 · 7 lekcji · 2 laby

Kolejność obniżania kosztów, prompt caching, Batch API.
Potem model przestaje być narzędziem programisty i staje się częścią produktu.

**Zmiana modelu na tańszy jest ostatnim ruchem, nie pierwszym.**

<!--
CO POWIEDZIEĆ: Pierwsza połowa modułu to pieniądze: co obniża koszt i w jakiej kolejności.
Druga to determinizm: jak zbudować fragment produktu, który działa bez autora, mimo że
w środku siedzi model.
-->

---

# Kolejność, w której obniża się koszty

<div class="drabina">
  <div class="stopien"><span class="nr">1</span><span>Higiena kontekstu: <code>/clear</code>, celowane czytanie</span><span class="cena">bez strat</span></div>
  <div class="stopien"><span class="nr">2</span><span>Prompt caching</span><span class="cena">bez strat</span></div>
  <div class="stopien"><span class="nr">3</span><span>Batch API</span><span class="cena">-50%, kosztuje natychmiastowość</span></div>
  <div class="stopien"><span class="nr">4</span><span>Niższy <code>effort</code></span><span class="cena">kosztuje głębokość rozumowania</span></div>
  <div class="stopien"><span class="nr">5</span><span>Tańszy model</span><span class="cena">kosztuje jakość <strong>i cache</strong></span></div>
</div>

**Cache jest przypisany do modelu.** Przeskakiwanie między modelami w jednej sesji
oznacza budowanie cache'u od nowa za każdym razem.

<!--
CO POWIEDZIEĆ: Najczęstszy błąd to zacząć od piątego stopnia, bo jest najbardziej widoczny.
Cztery stopnie nad nim nie kosztują jakości, a dwa pierwsze nie kosztują nic.
NA CO UWAŻAĆ: Ostatni wiersz ma dopisek, o którym łatwo zapomnieć - tańszy model zabiera
nie tylko jakość, ale i cache, bo cache jest per model.
PYTANIE Z SALI: „Okno ma milion tokenów, po co ta higiena?" Okno to nie budżet, tylko
sufit. Opłacie podlega to, co w nim siedzi, przy każdym zapytaniu.
-->

---

# Model dobiera się do roli, nie do trudności zadania

| Rola | Model | Effort | Dlaczego |
|---|---|---|---|
| Planista, decyzje architektoniczne | Opus | `high`-`max` | błąd kosztuje dni pracy |
| Czego Opus na `max` nie domyka | Fable | `high`-`max` | 2× drożej - dopiero po nieudanej próbie |
| Wykonawca wg specyfikacji | Sonnet | `medium`-`high` | kształt jest ustalony |
| Zbieracz faktów, subagent | Haiku | - | wynik to lista, nie rozumowanie |
| Przekształcenia mechaniczne | Haiku (bez effortu) / Sonnet | `low` | liczy się konsekwencja |
| Przegląd bezpieczeństwa | Opus | `high`-`max` | fałszywy negatyw droższy niż model |

`/model` i `/effort` w sesji · `model:` we frontmatterze subagenta ·
`CLAUDE_CODE_SUBAGENT_MODEL` jako **domyślny** model subagentów -
frontmatter `model:` ma nad nią pierwszeństwo.

> **Haiku nie obsługuje effortu.**

<!--
CO POWIEDZIEĆ: Przypisuj model do roli w procesie, a nie do wrażenia, że zadanie jest
trudne. Rola mówi, ile kosztuje błąd, i to jest właściwe kryterium.
NA CO UWAŻAĆ: Czwarty wiersz ma dopisek „bez effortu" nie przez przypadek - dla Haiku
nie ma czego ustawiać, `low` dotyczy tylko wariantu z Sonnetem.
PYTANIE Z SALI: „Zbuduję kaskadę: tani model robi pierwsze podejście, drogi poprawia?"
Najpierw zmierz prostszy wariant: mocniejszy model na niższym efforcie. Kaskada to dwa
modele, czyli dwa cache'e i dwa razy więcej kodu do utrzymania.
-->

---

# Caching działa na prefiksie: stabilne na początek

<div class="przeplyw">
  <div class="krok"><code>tools</code><small>stabilne</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz"><code>system</code><small>stabilne, tu punkt cache'owania</small></div>
  <div class="strzalka">→</div>
  <div class="krok"><code>messages</code><small>zmienne</small></div>
</div>

```python
system=[{
    "type": "text",
    "text": PROMPT_SYSTEMOWY,                  # stały prefiks
    "cache_control": {"type": "ephemeral"},    # punkt cache'owania
}],
messages=[{"role": "user", "content": f"Opis pozycji: {opis}"}],
```

Zmiana **jednego bajtu** w prefiksie unieważnia wszystko po niej.

<!--
CO POWIEDZIEĆ: Kolejność renderowania to tools, system, messages. Wszystko, co stabilne,
ląduje przed ostatnim punktem cache'owania, wszystko zmienne po nim.
NA CO UWAŻAĆ: Sala myśli o cache'u jak o cache'u odpowiedzi. To cache prefiksu wejścia:
liczy się, czy początek żądania jest bajt w bajt taki sam.
-->

---

# Cache psuje się po cichu

| Co | Dlaczego psuje |
|---|---|
| `datetime.now()` w prompcie systemowym | każdy request ma inny prefiks |
| identyfikator żądania w nagłówku systemowym | to samo |
| nieposortowany JSON w kontekście | kolejność kluczy zmienia bajty |
| lista narzędzi budowana dynamicznie | `tools` idzie **przed** `system` |
| zmiana modelu | cache jest per model |

**Jedyny sygnał: `usage.cache_read_input_tokens`.** Zero przy powtarzanych żądaniach
oznacza cichy invalidator. W Claude Code to samo widać w `/usage`, w linii
`Prompt cache (main)`.

<!--
CO POWIEDZIEĆ: To jest kategoria błędu, której nie widać: wszystko działa poprawnie,
tylko drożej. Nie ma innego sposobu, żeby to wykryć, niż spojrzeć na licznik odczytów
z cache'u.
NA CO UWAŻAĆ: W labie 7.1 zdarza się zero trafień. Najczęstsze przyczyny to przełączanie
modelu między pytaniami, zmiana zestawu serwerów MCP i edycja plików kontekstowych
w trakcie sesji.
-->

---

# TTL: godzina kontra pięć minut

| Gdzie | Domyślny TTL | Co to znaczy w praktyce |
|---|---|---|
| Subskrypcja | **1 h** | przerwa na kawę nie kosztuje |
| Klucz API | **5 min** | przerwa kosztuje przeliczenie całego kontekstu |

To jest domyślka, nie limit platformy. Godzinę na kluczu API włącza
`promptCacheTtl: "1h"` (v2.1.242+) albo `ENABLE_PROMPT_CACHING_1H=1`;
w API bezpośrednio `cache_control: {"type": "ephemeral", "ttl": "1h"}`.

Limity: maksymalnie **4 punkty cache'owania** na żądanie,
minimalny prefiks **512-4096 tokenów** zależnie od modelu.

<!--
CO POWIEDZIEĆ: Ta jedna liczba zmienia sposób pracy. Na subskrypcji można wstać od
biurka, na kluczu API domyślnie płaci się za powrót.
NA CO UWAŻAĆ: Prefiks krótszy niż minimum po prostu się nie zacache'uje i nikt o tym
nie poinformuje.
PYTANIE Z SALI: „Jak sprawdzić, który TTL faktycznie poszedł?"
`claude -p "hello" --output-format json` i pole `usage.cache_creation` - zapisy godzinne
raportowane są jako `ephemeral_1h_input_tokens`.
-->

---

# `/clear` kontra `/compact`

| | `/clear` | `/compact <instrukcja>` |
|---|---|---|
| Koszt | **zero** | duże żądanie: czyta całą historię, żeby ją streścić |
| Kiedy | między niepowiązanymi zadaniami | gdy potrzebna jest ciągłość |
| Przed użyciem | `/rename`, gdy sesja ma być dostępna przez `/resume` | wskazanie, co zachować |

**Co przeżywa kompakcję:** projektowy `CLAUDE.md` z korzenia - czytany ponownie z dysku.
Instrukcja podana tylko w rozmowie przepada.

Stałe instrukcje kompakcji wpisuje się do `CLAUDE.md` pod `# Compact instructions`.

<!--
CO POWIEDZIEĆ: Jedna sesja to jedno zadanie. Gdy ciągłość nie jest potrzebna, `/clear`
jest darmowy, a kompakcja nie - sama jest dużym żądaniem.
NA CO UWAŻAĆ: Kompakcja bez potrzeby ciągłości to płacenie za streszczenie historii,
która i tak nie będzie potrzebna. Pytanie brzmi zawsze: czy potrzebuję ciągłości.
-->

---

# Filtrowanie w powłoce, nie w kontekście

<div class="przeplyw">
  <div class="krok zly">10 000 linii logu<small>surowe wyjście <code>pytest</code></small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">hook <code>PreToolUse</code><small><code>updatedInput</code> przerabia komendę</small></div>
  <div class="strzalka">→</div>
  <div class="krok dobry">same błędy<small>tyle wchodzi do kontekstu</small></div>
</div>

```json
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow",
 "updatedInput": {"command": "pytest -q > /tmp/pytest.log 2>&1; k=$?; grep -E \"FAIL|ERROR\" /tmp/pytest.log | head -50; exit $k"}}}
```

> `updatedInput` zastępuje **całe** wejście narzędzia, nie scala się z nim.
> W `jq` buduje się je przez `(.tool_input + {command: $filtered})`.
> Filtr zwraca kod `pytest`, nie kod `head`: `head` kończy się sukcesem zawsze.

To samo robi subagent zwracający streszczenie (moduł 6), skill zamiast rozdętego
`CLAUDE.md` (moduł 2), CLI zamiast serwera MCP.

<!--
CO POWIEDZIEĆ: Hook `PreToolUse` może przerobić komendę, zanim się wykona. Filtrowanie
przenosi się z kontekstu modelu do powłoki, gdzie jest darmowe.
NA CO UWAŻAĆ: To najbardziej niedoceniana dźwignia z całego modułu - ten sam mechanizm
hooka, który w module 5 blokował, tutaj tylko przycina wejście.
-->

---

# Batch API: połowa ceny za cierpliwość

| Wymiar | Batch API |
|---|---|
| Cena | **50%** |
| Czas | zwykle do godziny, maksymalnie 24 h |
| Nadaje się do | przeklasyfikowania archiwum, masowej ekstrakcji, oceny golden setu |
| Nie nadaje się do | czegokolwiek interaktywnego |
| Gdzie działa | klucz API, **nie** subskrypcja Pro/Max |

> **Wyniki wracają w dowolnej kolejności.** Kluczowanie po `custom_id`, nigdy po pozycji
> na liście.

<!--
CO POWIEDZIEĆ: Wszystko, na co nikt nie czeka, powinno iść batchem. To jedyna dźwignia,
która daje połowę ceny i nie kosztuje jakości.
NA CO UWAŻAĆ: Kluczowanie po pozycji na liście przechodzi testy na paczce
trzyelementowej i psuje dane na tysiącu.
-->

---

# Pomiar: bez niego to rozmowa o wrażeniach

| Metryka | Po co |
|---|---|
| Koszt **na ukończone zadanie** | jedyna, która ma sens biznesowy |
| Udział tokenów z cache | czy prompt jest dobrze ułożony |
| Zużycie per rola | gdzie routing się nie opłaca |
| Liczba tur do ukończenia | czy zadania są dobrze postawione |

Na Pro/Max: `/usage` - paski limitu planu, atrybucja (skille, subagenci, MCP),
flagi zachowań powyżej 10% zużycia. Na kluczu API: `usage.input_tokens`,
`usage.output_tokens`, `usage.cache_read_input_tokens`.

Kalibracja z dokumentacji: ok. **13 USD** na dewelopera na dzień aktywny,
**150-250 USD** miesięcznie we wdrożeniach korporacyjnych.

<!--
CO POWIEDZIEĆ: Tańsze zapytanie, które wymaga trzech kolejnych tur, nie jest tańsze.
Dlatego liczy się koszt na ukończone zadanie, a nie na zapytanie.
NA CO UWAŻAĆ: Blok `Session` w `/usage` pokazuje kwotę w dolarach, ale na subskrypcji
ta liczba nie ma związku z rachunkiem - jest liczona lokalnie po cenniku katalogowym.
Istotne są paski limitu i atrybucja.
PYTANIE Z SALI: „Co zrobić z tą wiedzą od razu?" Otworzyć `/usage` i spojrzeć na atrybucję.
Jeśli serwer MCP, plugin albo skill odpowiada za więcej niż kilka procent zużycia,
a nie jest używany w tym projekcie, wyłączcie go teraz. Serwery MCP wyłącza `/mcp`.
-->

---

# Model w produkcie: trzy warstwy

<div class="przeplyw pion">
  <div class="krok dobry">1. Reguła twarda w kodzie<small>co da się rozstrzygnąć deterministycznie, rozstrzygamy bez modelu</small></div>
  <div class="strzalka">→</div>
  <div class="krok">2. Model ze schematem<small>tylko to, czego reguła nie objęła; odpowiedź walidowana, nie parsowana</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">3. Decyzja progowa w kodzie<small>pewność poniżej progu: wartość domyślna + flaga do weryfikacji</small></div>
</div>

Schemat gwarantuje **kształt**, nie **sens** - stawka spoza słownika, data w przyszłości
i absurdalna kwota to sprawdzenia w kodzie.

<!--
CO POWIEDZIEĆ: Model zwraca wynik i pewność, ale to kod decyduje, czy tej pewności
wystarczy. Model, który sam decyduje, czy jest wystarczająco pewny, jest modelem
bez nadzoru.
NA CO UWAŻAĆ: Kolejność jest częścią projektu. Reguła twarda sprawdzana po modelu
oznacza płacenie za pozycje, które rozstrzyga jedno słowo kluczowe - w repozytorium
ćwiczeniowym reguły pokrywają 4 z 12 unikalnych opisów.
PYTANIE Z SALI: „Skoro model może być pewny i w błędzie, to po co próg?" Próg chroni
przed niepewnością, nie przed pewnym błędem. Przed pewnym błędem chroni tylko reguła
twarda albo człowiek.
-->

---

# Golden set: co testuje, a czego nie

| | Co uruchamia | Co wykrywa |
|---|---|---|
| **Testy offline** | kod klasyfikatora, na zapisanych odpowiedziach | reguły, próg, routing, obsługę odpowiedzi |
| **Ewaluacja promptu** | prawdziwy model na oznaczonym zbiorze | regresję promptu i zmianę modelu |

**Podmiana `PROMPT_SYSTEMOWY` zostawia testy offline zielone** - prompt nigdy nie jest
w nich wykonywany. To ich zakres, nie wada. Wadą jest nazwać je testem promptu.

```
{"opis": "Hosting miesieczny", "oczekiwana": "23", "zrodlo": "model", "odpowiedz": {...}}
```

<!--
CO POWIEDZIEĆ: To jest slajd, na którym najłatwiej uśpić czujność sali. Testy offline
są szybkie, darmowe i zielone - i nie mówią nic o prompcie. Sprawdzają kod wokół modelu.
NA CO UWAŻAĆ: Test na źródło decyzji jest ważniejszy niż test na stawkę: bez niego zmiana
w kodzie - usunięta reguła twarda albo przestawiona kolejność warstw - może po cichu
przenieść rozstrzygnięcia z warstwy deterministycznej do modelu
przy identycznych wynikach, a jedynym sygnałem będzie faktura.
PYTANIE Z SALI: „To po co w ogóle te testy offline?" Bo łapią regresje w regułach twardych,
progu i routingu - czyli w kodzie napisanym w tym labie. Ewaluacja promptu jest osobna,
kosztuje tokeny i nie musi chodzić przy każdym commicie.
-->

---

<!-- _class: haslo -->

## „Jeśli nie jesteś pewny, odpowiedz NIE_WIEM" to prośba.
## Próg porównywany w kodzie to egzekucja.

Moduł 2: instrukcja w `CLAUDE.md`. Moduł 5: hook zamiast reguły.
Moduł 7: liczba w kodzie zamiast zdania w prompcie. Moduł 8: to samo z danymi wejściowymi.

<!--
CO POWIEDZIEĆ: Ta oś wraca czwarty raz i zawsze kończy się tak samo - to, co ma działać
bez autora, musi być artefaktem w repozytorium, a nie prośbą skierowaną do modelu.
NA CO UWAŻAĆ: To jest dokładnie ta pułapka z labu 7.2. Jeżeli w projekcie warstw pojawi
się „w prompcie każemy modelowi odpowiedzieć NIE_WIEM", brakuje całej warstwy.
-->

---

<!-- _class: lab -->

# Laby 7.1 i 7.2

**Lab 7.1 - pomiar, tag `lab-7-1-start`.** Kod zostaje bez zmian, jest tylko pomiar:
to samo pytanie w sesji rozdętej i po `/clear`, potem statystyki prompt cache
i atrybucja z `/usage`. Produkt: `notatki/pomiar-kosztu.md`.
Wymagane `claude --version` **2.1.251 lub nowsze** - inaczej nie ma statystyk cache.

**Lab 7.2 - klasyfikator VAT, tag `lab-7-2-start`.** Trzy warstwy,
golden set na minimum 20 przypadków, `make gate` **offline, bez klucza API**.
Produkt: `app/klasyfikacja_vat.py`, `tests/golden/vat.jsonl`, `tests/test_golden_vat.py`.

Niezacommitowana praca z labu 6.2 zablokuje `git checkout`: `git stash push -u -m "moje-6-2"`.

<!--
CO POWIEDZIEĆ: Pierwszy lab to liczby na własnym terminalu, drugi to pierwszy w kursie
fragment, w którym model jest częścią produktu, a nie narzędziem programisty.
NA CO UWAŻAĆ: `git switch -c` nie odblokowuje skoku na tag - niczego nie commituje.
Od tego jest `git stash push -u`, także dla plików nieśledzonych.
-->
