# Lab 7.2 - Determinizm w produkcie: klasyfikator VAT

**Tag startowy: `lab-7-2-start`** · **Produkt: `app/klasyfikacja_vat.py`, `tests/golden/vat.jsonl`, `tests/test_golden_vat.py`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-7-2-start
make gate          # 47 testów zielonych
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-7-1"
> ```
>
> Powrót do niej: `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.
>
> **Ten lab kończy się commitem, a `git checkout <tag>` stawia repozytorium
> w odpiętym `HEAD`.** Commit nie należy wtedy do żadnej gałęzi i przy skoku
> na kolejny tag przestaje być osiągalny. Git ostrzeże o tym po angielsku
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-7-2`
> **przed** skokiem.

---

## Wymaganie

> **Od kierownika działu rozliczeń:**
> Handlowcy wpisują opisy pozycji własnymi słowami i połowa faktur ma złą stawkę VAT.
> Dałoby się to podpowiadać automatycznie?

Odpowiedź brzmi: da się - **pod warunkiem że system nie będzie zależał od tego,
czy model akurat trafi.**

---

## Cel

Zbudować pierwszy w tym kursie fragment, w którym model jest **częścią produktu**,
a nie narzędziem programisty - i zrobić to tak, żeby był przewidywalny.

To działa **offline**, bez klucza API. Prawdziwe wywołania to skrypty do uruchomienia
u siebie w firmie.

---

## Krok 1 - trzy warstwy, zanim padnie pierwsza linia kodu

```
Zaprojektuj (bez pisania kodu) klasyfikator stawki VAT dla opisu pozycji faktury.

Wymaganie: system ma być przewidywalny. Ta sama pozycja ma dostać tę samą stawkę,
a pozycja, co do której nie ma pewności, ma trafić do człowieka, a nie dostać
strzał modelu.

Zaproponuj podział na warstwy i powiedz, KTÓRA WARSTWA PODEJMUJE KTÓRĄ DECYZJĘ.
Nie pisz kodu.
```

Minimum, które musi się znaleźć:

1. **Reguła twarda w kodzie** - to, co da się rozstrzygnąć słowem kluczowym
   (usługi medyczne → `zw`, książka → `5`), rozstrzygamy **bez modelu**.
2. **Model ze schematem** - tylko to, czego reguła nie objęła.
3. **Decyzja progowa w kodzie** - model zwraca stawkę **i pewność**; to, czy pewności
   wystarczy, rozstrzyga kod.

**Czego się spodziewać.** Agent najprawdopodobniej odda **cztery albo pięć** warstw:
normalizację opisu do klucza kanonicznego, słownik albo cache decyzji, model, bramkę progową
i kolejkę człowieka. To dobrze - prompt sam dyktuje większość tej struktury.

Krok 1 nie polega więc na doliczaniu brakującej warstwy. Polega na sprawdzeniu **jednej** rzeczy:

> **Czy próg pewności jest liczbą porównywaną w kodzie, czy instrukcją w prompcie?**

Jeżeli w projekcie pojawiło się „w prompcie każemy modelowi odpowiedzieć NIE_WIEM, gdy nie jest
pewny" - to jest warstwa, której nie ma, i **wtedy trzeba dopytać**. Model, który sam
decyduje, czy jest wystarczająco pewny, jest modelem bez nadzoru.

Wyjątkowo agent oddaje tylko dwie warstwy (model + walidacja) - to ten sam brak
i to samo dopytanie o trzecią.

> **Zawężenie na potrzeby labu.** W kolejnych krokach zakres schodzi do **trzech** warstw -
> cache decyzji i kolejka człowieka wykraczają poza zakres tego labu. Przy propozycji cache'u
> wymaganie idzie do agenta wprost: pole `zrodlo` ma mieć dokładnie trzy wartości -
> `regula`, `model`, `domyslna`.

---

## Krok 2 - schemat i kontrakt

```
Napisz app/klasyfikacja_vat.py.

Schemat odpowiedzi modelu (Pydantic):
- stawka: Literal ograniczony do stawek z app/vat.py,
- pewnosc: float 0..1,
- uzasadnienie: str, niepusty, maksymalnie 300 znaków.

Wynik zwracany przez moduł ma zawierać: opis, stawkę, ZRODLO decyzji
("regula" | "model" | "domyslna"), pewność, uzasadnienie i flagę wymaga_weryfikacji.

Dodatkowo zdefiniuj Protocol "Klasyfikator" z jedną metodą sklasyfikuj(opis).
Dwie implementacje: KlasyfikatorMock (odpowiedzi z przygotowanej mapy, offline)
i KlasyfikatorLLM (prawdziwe API). Import anthropic ma być LENIWY - moduł musi
dać się zaimportować bez tego pakietu.
```

**Pole `zrodlo` jest najważniejsze w całym module.** Bez niego nie da się odróżnić
„model trafił" od „reguła zadziałała" od „nie wiedzieliśmy i wzięliśmy domyślną".
A to są trzy zupełnie różne sytuacje z punktu widzenia księgowości.

---

## Krok 3 - reguły twarde i decyzja progowa

```
Dodaj:
- REGULY_TWARDE: mapa fragment opisu -> stawka. Minimum 10 pozycji,
  pokrywających stawki zw, 5, 8 i 0.
- PROG_PEWNOSCI = 0.85 i STAWKA_DOMYSLNA = "23".
- funkcję klasyfikuj(opis, klasyfikator) realizującą trzy warstwy.

Kolejność jest istotna: reguła twarda SPRAWDZANA PRZED wywołaniem modelu.
Pozycja rozstrzygnięta regułą nie może kosztować wywołania API.

Dodaj też walidację POZA schematem: jeżeli model zwróci stawkę, której nie ma
w app/vat.py STAWKI, potraktuj to jak brak odpowiedzi.
```

Dwie decyzje warte uzasadnienia:

**Dlaczego `STAWKA_DOMYSLNA = "23"`, a nie „nie wiem".** Zaniżenie VAT-u to zaległość
podatkowa z odsetkami. Zawyżenie to korekta. Domyślna wartość jest **zawyżona celowo** -
i to jest decyzja biznesowa, nie techniczna. Jej miejsce jest w komentarzu.

**Dlaczego walidacja poza schematem.** Schemat gwarantuje **kształt**, nie **sens**.
Model może zwrócić stawkę składniowo poprawną, ale nieobsługiwaną przez system.

---

## Krok 4 - golden set

```
Utwórz tests/golden/vat.jsonl - minimum 20 przypadków.

Każdy wiersz: opis, oczekiwana stawka, oczekiwane ZRODLO decyzji.
Dla przypadków idących do modelu dodaj pole "odpowiedz" z tym, co model ma zwrócić
(stawka, pewnosc, uzasadnienie) - dzięki temu testy działają offline.

Pokryj wszystkie trzy źródła:
- minimum 8 rozstrzyganych regułą twardą,
- kilka z wysoką pewnością modelu,
- co najmniej 3 z pewnością PONIŻEJ progu,
- jeden, w którym model zwraca stawkę spoza słownika (np. "7") z wysoką pewnością.

Potem napisz tests/test_golden_vat.py:
- test na stawkę dla każdego przypadku,
- test na ŹRÓDŁO decyzji dla każdego przypadku,
- test, że pozycje rozstrzygane regułą NIE wołają modelu,
- test, że każda stawka rozstrzygana regułą twardą ma przykład w golden secie.
```

**Test na źródło jest ważniejszy niż test na stawkę.** Prompt, który przypadkiem trafia
dobrą stawkę, nie jest tym samym co reguła, która trafia zawsze. Bez tego testu zmiana
w kodzie - usunięta reguła twarda albo przestawiona kolejność warstw - mogłaby po cichu
przenieść rozstrzygnięcia z warstwy deterministycznej do modelu, przy identycznych wynikach.

```bash
make gate
```

---

## Krok 5 - próba złamania

Sprawdzenie, czy warstwy trzymają:

```bash
.venv/bin/python -c "
from app.klasyfikacja_vat import klasyfikuj, KlasyfikacjaVAT, KlasyfikatorMock
# model bardzo pewny i bardzo w błędzie
m = KlasyfikatorMock({'Sprzedaz samochodu osobowego': KlasyfikacjaVAT(
    stawka='0', pewnosc=0.99, uzasadnienie='Pojazdy sa zwolnione.')})
w = klasyfikuj('Sprzedaz samochodu osobowego', m)
print(w.stawka, w.zrodlo, w.pewnosc, w.wymaga_weryfikacji)
"
```

**Wynik: `0 model 0.99 False`.** Model był pewny i się mylił, a system mu uwierzył.

To jest granica tego mechanizmu i trzeba ją znać: **próg pewności chroni przed niepewnością,
nie przed pewnym błędem.** Przed pewnym błędem chroni tylko człowiek. Reguła twarda przenosi decyzję do kodu
i czyni ją powtarzalną, ale dopasowanie fragmentu to nadal heurystyka - też potrafi
pewnie się mylić (moduł 8, lab 8.2).

Do zapisania w komentarzu w kodzie albo w `docs/`. Za pół roku ktoś o to zapyta.

```bash
git add app/klasyfikacja_vat.py tests/
git commit -m "Klasyfikacja stawki VAT przez model, z determinizmem w kodzie"
```

---

## Krok 6 - skrypty na później (rozszerzenie)

> **Rozszerzenie.** Ta część nie jest potrzebna do przejścia labów tego modułu.
> Wymaga **własnego klucza API** - na subskrypcji Pro/Max te skrypty nie zadziałają.
> Do wykonania później, w firmie, na własnym repozytorium.

Trzy skrypty w `skrypty/` do uruchomienia z firmowym kluczem API:

| Skrypt | Pokazuje |
|---|---|
| `klasyfikuj_api.py` | structured output + prompt caching, z **zmierzonym** kosztem z pola `usage` |
| `batch_klasyfikacja.py` | Batch API, **połowa ceny**, wyniki w dowolnej kolejności |
| `pomiar_kosztu.py` | koszt per rola: planista / wykonawca / zbieracz faktów |
| `ewaluacja_promptu.py` *(z `szablony/skrypty/`)* | **to, czego testy offline nie robią**: wywołuje prawdziwy model na golden secie |

> **Trzy kategorie tokenów wejściowych mają trzy różne ceny** i API raportuje je osobno:
> `input_tokens` po pełnej stawce, `cache_creation_input_tokens` po 1,25 raza drożej
> (przy TTL 5 minut), `cache_read_input_tokens` po jednej dziesiątej. Liczenie ich razem
> zaniża rachunek przy pierwszym wywołaniu i zawyża przy kolejnych - oba skrypty liczą
> je osobno.
>
> **Zerowy odczyt cache’u przy pierwszym uruchomieniu jest normalny** - cache dopiero
> powstaje. Przy kolejnym oznacza albo zbyt krótki prefiks (minimum zależy od modelu:
> 512 tokenów na Opusie 5, 1024 na Sonnecie 5, 4096 na Haiku 4.5), albo zmianę czegoś
> przed nim.

### Ewaluacja promptu - jedyny sposób, żeby powiedzieć „nowy prompt jest lepszy"

Golden set z tego labu sprawdza kod klasyfikatora. Prompt sprawdza dopiero to:

```bash
cp ../szablony/skrypty/ewaluacja_promptu.py skrypty/
PYTHONPATH=. python skrypty/ewaluacja_promptu.py tests/golden/vat.jsonl
```

Skrypt puszcza cały oznaczony zbiór przez **prawdziwy model** i wypisuje trafność,
liczbę przypadków skierowanych do weryfikacji oraz rozkład źródeł decyzji.

Porównanie dwóch promptów na tym samym zbiorze:

```bash
PYTHONPATH=. python skrypty/ewaluacja_promptu.py tests/golden/vat.jsonl \
    --prompt-b prompty/wariant_b.txt
```

**Dwie liczby czyta się razem.** Prompt, który podniósł trafność, ale podwoił liczbę
pozycji „do weryfikacji", nie wygrał - przesunął pracę na człowieka. Sam wskaźnik
trafności tego nie pokaże.

> Ten przebieg **kosztuje** i nie jest deterministyczny: ten sam prompt na tym samym
> zbiorze może dać nieco inny wynik. Dlatego nie chodzi w CI przy każdym commicie,
> tylko przy zmianie promptu albo modelu - i dlatego przy decyzji patrzy się na
> kilka przebiegów, a nie na jeden.

```bash
pip install anthropic
export ANTHROPIC_API_KEY=sk-ant-...
PYTHONPATH=. python skrypty/pomiar_kosztu.py
```

> **`PYTHONPATH=.` jest obowiązkowe.** `python skrypty/X.py` stawia na `sys.path` katalog
> skryptu, nie katalog roboczy - bez tego `from app import ...` kończy się
> `ModuleNotFoundError: No module named 'app'`.

---

## Kryteria zaliczenia

- [ ] Trzy warstwy istnieją i **decyzja progowa jest w kodzie**, nie w modelu.
- [ ] Reguła twarda jest sprawdzana **przed** wywołaniem modelu - jest na to test.
- [ ] Jest walidacja poza schematem (stawka spoza słownika).
- [ ] Golden set ma ≥20 przypadków i pokrywa wszystkie trzy źródła decyzji.
- [ ] Testy sprawdzają **źródło decyzji**, nie tylko wynik.
- [ ] Testy działają offline - `make gate` nie potrzebuje sieci ani klucza.
- [ ] Ustalone i zapisane, przed czym próg pewności **nie** chroni.

## Pułapki

**Próg pewności wewnątrz promptu.** „Jeśli nie jesteś pewny, odpowiedz NIE_WIEM" przenosi
decyzję z powrotem do modelu. Próg ma być liczbą porównywaną w kodzie.

**Golden set bez przypadków poniżej progu.** Wtedy fallback nigdy nie jest testowany
i przy pierwszej zmianie progu nikt tego nie zauważy.

**Testy wołające prawdziwe API.** CI zaczyna kosztować, zależy od sieci i zaczyna
migotać. Odpowiedzi modelu należą do golden setu.

**Brak testu na źródło decyzji.** Bez niego zmiana w kodzie - usunięta reguła twarda albo
przestawiona kolejność warstw - może przenieść rozstrzygnięcia z reguł do modelu przy
identycznych wynikach, a jedynym sygnałem będzie faktura.

**Reguły twarde sprawdzane po modelu.** Wtedy koszt obejmuje każdą pozycję, także tę,
którą rozstrzyga jedno słowo kluczowe. W tym repozytorium reguły pokrywają
4 z 12 unikalnych opisów - jedna trzecia wywołań za darmo.

---

[Rozwiązanie wzorcowe](rozwiazanie-7-2.md) · [Checklista modułu](checklista.md)
