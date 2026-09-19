# Lab 7.2 - Determinizm w produkcie: klasyfikator VAT

**Czas: ~35 min** · **Tag startowy: `lab-7-2-start`** · **Produkt: `app/klasyfikacja_vat.py`, `tests/golden/vat.jsonl`, `tests/test_golden_vat.py`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-7-2-start
make gate          # 47 testów zielonych
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-7-1"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
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

## Krok 1 - trzy warstwy, zanim padnie pierwsza linia kodu (5 min)

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
pewny" - to jest warstwa, której nie ma, i **wtedy dopytaj**. Model, który sam decyduje,
czy jest wystarczająco pewny, jest modelem bez nadzoru.

Jeżeli agent wyjątkowo oddał tylko dwie warstwy (model + walidacja) - też dopytaj o trzecią.

> **Zawężenie na potrzeby labu.** W kolejnych krokach schodzimy do **trzech** warstw -
> cache decyzji i kolejka człowieka nie mieszczą się w 35 minutach. Jeżeli agent zaproponował
> cache, powiedz mu wprost: pole `zrodlo` ma mieć dokładnie trzy wartości -
> `regula`, `model`, `domyslna`.

---

## Krok 2 - schemat i kontrakt (7 min)

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

## Krok 3 - reguły twarde i decyzja progowa (8 min)

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
i to jest decyzja biznesowa, nie techniczna. Zapisz ją w komentarzu.

**Dlaczego walidacja poza schematem.** Schemat gwarantuje **kształt**, nie **sens**.
Model może zwrócić stawkę składniowo poprawną, ale nieobsługiwaną przez system.

---

## Krok 4 - golden set (10 min)

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
dobrą stawkę, nie jest tym samym co reguła, która trafia zawsze. Bez tego testu
zmiana promptu mogłaby po cichu przenieść rozstrzygnięcia z warstwy deterministycznej
do modelu - przy identycznych wynikach.

```bash
make gate
```

---

## Krok 5 - próba złamania (5 min)

Sprawdź, czy twoje warstwy trzymają:

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
nie przed pewnym błędem.** Przed pewnym błędem chroni tylko reguła twarda albo człowiek.

Zapisz to w komentarzu w kodzie albo w `docs/`. Za pół roku ktoś zapyta.

```bash
git add app/klasyfikacja_vat.py tests/
git commit -m "Klasyfikacja stawki VAT przez model, z determinizmem w kodzie"
```

---

## Krok 6 - skrypty na później (opcjonalnie, w firmie)

Trzy skrypty w `skrypty/` do uruchomienia z firmowym kluczem API:

| Skrypt | Pokazuje |
|---|---|
| `klasyfikuj_api.py` | structured output + prompt caching na żywo |
| `batch_klasyfikacja.py` | Batch API, **połowa ceny**, wyniki w dowolnej kolejności |
| `pomiar_kosztu.py` | koszt per rola: planista / wykonawca / zbieracz faktów |

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
- [ ] Umiesz powiedzieć, przed czym próg pewności **nie** chroni.

## Pułapki

**Próg pewności wewnątrz promptu.** „Jeśli nie jesteś pewny, odpowiedz NIE_WIEM" przenosi
decyzję z powrotem do modelu. Próg ma być liczbą porównywaną w kodzie.

**Golden set bez przypadków poniżej progu.** Wtedy fallback nigdy nie jest testowany
i przy pierwszej zmianie progu nikt tego nie zauważy.

**Testy wołające prawdziwe API.** CI zaczyna kosztować, zależy od sieci i zaczyna
migotać. Odpowiedzi modelu należą do golden setu.

**Brak testu na źródło decyzji.** Bez niego zmiana promptu może przenieść rozstrzygnięcia
z reguł do modelu przy identycznych wynikach - i dowiesz się o tym z faktury.

**Reguły twarde sprawdzane po modelu.** Wtedy płacisz za każdą pozycję, także tę,
którą rozstrzyga jedno słowo kluczowe. W tym repozytorium reguły pokrywają
4 z 12 unikalnych opisów - jedna trzecia wywołań za darmo.

---

[Rozwiązanie wzorcowe](rozwiazanie-7-2.md) · [Checklista modułu](checklista.md)
