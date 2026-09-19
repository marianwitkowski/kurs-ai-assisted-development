# Zadanie końcowe - bez gotowego promptu

**Tag startowy: `lab-8-2-koniec`** · **Produkt: specyfikacja, kod, testy i notatka decyzyjna**

---

Szesnaście labów prowadziło krok po kroku: gotowe prompty do skopiowania, opisane
oczekiwane rozpoznania, wzorcowe rozwiązanie na końcu. To jest właściwa kolejność przy
uczeniu procedury i **kiepski sposób sprawdzenia, czy procedura weszła w nawyk.**

Tutaj nie ma promptów. Jest wymaganie w takiej postaci, w jakiej przychodzi z działu
biznesowego: jednym zdaniem, z lukami, których autor nie zauważył.

```bash
cd repo-cwiczeniowe
git checkout lab-8-2-koniec
git checkout -b zadanie-koncowe
make gate          # 116 testów zielonych, bramka zielona
```

> Gałąź, a nie odpięty `HEAD`: praca ma przetrwać przejście na inny tag.

---

## Wymaganie

> **„Kiedy kontrahent zgłasza reklamację do faktury, odsetki za opóźnienie nie powinny
> się naliczać, dopóki reklamacja nie zostanie rozpatrzona."**

Tyle. Tak wygląda oryginał.

---

## Co jest do zrobienia

Cztery produkty. Pierwszy z nich jest ważniejszy niż trzy pozostałe razem wzięte.

### 1. Specyfikacja

Do `specyfikacje/reklamacje.md`, w układzie z `szablony/szablon-specyfikacji.md`.

Wymaganie w tej postaci **nie da się zaimplementować**, nie podejmując po drodze
kilkunastu decyzji, których nikt nie podjął. Część z nich zmienia kwoty na fakturach.

Specyfikacja ma zawierać sekcję **ZAŁOŻONE** z listą tych decyzji i wybraną odpowiedzią
dla każdej. Pusta sekcja ZAŁOŻONE jest sygnałem, że czegoś nie zauważono, a nie że
wymaganie było kompletne.

Kilka pytań, od których warto zacząć - **nie jest to lista zamknięta i nie jest to
lista wystarczająca**:

- Odsetki się **zawieszają** (nie naliczają za okres reklamacji, potem lecą dalej)
  czy **przerywają** (okres reklamacji wypada z naliczania w ogóle)?
- Od którego dnia: zgłoszenia, przyjęcia, czy dnia, którego dotyczy reklamacja?
- Reklamacja odrzucona - odsetki za ten okres naliczają się wstecz, czy przepadają?
- Reklamacja dotyczy części kwoty - zawieszenie obejmuje całą fakturę czy część?
- Co z fakturą, która w trakcie reklamacji została opłacona?
- Co z korektą wystawioną w trakcie reklamacji?

Każda odpowiedź ma być **oznaczona jako decyzja**, nie podana jako fakt. Wymaganie ich
nie rozstrzyga; ktoś je rozstrzygnął - i ma to być widoczne.

Sekcja **POZA ZAKRESEM** jest obowiązkowa. Bez niej agent dopisze interfejs do
zgłaszania reklamacji, powiadomienia i raport, o które nikt nie prosił.

### 2. Implementacja

Ograniczona do tego, co wynika ze specyfikacji.

Twarde ograniczenie: **`app/rozliczenia.py` i `app/rabaty.py` zostają nietknięte.**
Miejsca oznaczone `REGULA` w tym repozytorium są celowe i kosztowne w usunięciu -
rozpoznanie tego było treścią modułu 4. Jeżeli wymaganie wydaje się wymuszać zmianę
w którymś z nich, właściwą reakcją jest opisanie sprzeczności w notatce, nie zmiana kodu.

### 3. Testy

Dobrane przez wykonawcę, nie podane z góry. Kryterium jest jedno i sprawdzalne:

> **Musi istnieć test, który przechodzi na napisanym kodzie i nie przechodzi
> po wprowadzeniu kontrolowanego błędu w regule, którą sprawdza.**

Test, który przechodzi zawsze, nie jest testem tej reguły. Sposób weryfikacji: zmienić
jedną wartość w kodzie, uruchomić testy, sprawdzić, że czerwienią się te właściwe,
cofnąć zmianę.

### 4. Notatka decyzyjna

Do `notatki/zadanie-koncowe.md`. Cztery części:

| Część | Co ma zawierać |
|---|---|
| Założenia | decyzje podjęte za autora wymagania i uzasadnienie każdej |
| Zakres | co zostało zrobione i co świadomie pominięto |
| Weryfikacja | czym potwierdzono poprawność i **na jakim zbiorze** |
| Czego nie sprawdzono | uczciwa lista - to jest najwyżej punktowana część |

---

## Kryteria oceny

Ocenie podlega **proces, nie działający kod**. Rozwiązanie, które działa, ale powstało
bez ujawnienia założeń, jest gorsze od rozwiązania węższego z pełną listą decyzji.

- [ ] **Ujawnione założenia.** Sekcja ZAŁOŻONE wylicza decyzje, których wymaganie nie
      rozstrzyga, i podaje wybraną odpowiedź dla każdej.
- [ ] **Kontrola zakresu.** `git diff --stat` pokrywa się z zakresem specyfikacji.
      Brak plików zmienionych „przy okazji". `app/rozliczenia.py` i `app/rabaty.py`
      bez zmian.
- [ ] **Dobór testów.** Istnieje test, który czerwieni się po kontrolowanym błędzie
      w sprawdzanej regule. Testy sprawdzają zachowanie ze specyfikacji, nie kształt
      implementacji.
- [ ] **Bezpieczeństwo.** Jeżeli powstał endpoint albo pole zmieniane z zewnątrz -
      rozstrzygnięte, **kto** ma prawo je ustawić, i sprawdzone to per zasób, nie tylko
      per token. Dane wejściowe walidowane przed użyciem.
- [ ] **Bramka.** `make gate` zielone, w tym skan sekretów. 116 wcześniejszych testów
      nadal przechodzi.
- [ ] **Uzasadnienie wyniku.** Notatka odpowiada, **skąd wiadomo**, że to działa -
      i na jakim zbiorze to sprawdzono.
- [ ] **Uczciwa lista braków.** Wymienione rzeczy niesprawdzone. Pusta lista jest
      sygnałem ostrzegawczym, nie wynikiem.

---

## Pułapki

**Zaczęcie od kodu.** Wymaganie brzmi na tyle konkretnie, że da się od razu poprosić
agenta o implementację. Powstanie kod realizujący kilkanaście niewypowiedzianych decyzji,
których nikt nie zobaczy, dopóki nie zobaczy ich klient na fakturze.

**Specyfikacja przepisana przez agenta z wymagania.** Agent poproszony o specyfikację
na podstawie jednego zdania **uzupełni luki najbardziej prawdopodobną treścią** i odda
dokument wyglądający na kompletny. Sekcja ZAŁOŻONE powstaje z pytań, nie z dopowiedzeń -
technika z modułu 3: najpierw lista pytań, bez odpowiadania na nie.

**Test napisany po implementacji.** Sprawdza, że kod robi to, co robi. Kontrolowany błąd
w kodzie rozstrzyga, czy test cokolwiek chroni.

**Pominięcie autoryzacji.** Flaga reklamacji zmienia kwoty na fakturze. Pole, które
zmienia kwoty i da się ustawić z zewnątrz, jest granicą zaufania - moduł 8 w całości
był o tym, co się dzieje, gdy sprawdza się token zamiast właściciela zasobu.

---

## Co dalej

Rozwiązania wzorcowego **nie ma i to jest celowe.** Wymaganie dopuszcza kilka poprawnych
odczytań; poprawność polega na tym, że wybrane odczytanie jest widoczne i uzasadnione,
a nie na trafieniu w cudzą odpowiedź.

Do samooceny: [checklista gotowości](szablony/checklista-gotowosci.md) - sekcje 1, 3 i 6
stosują się wprost do tego zadania.
