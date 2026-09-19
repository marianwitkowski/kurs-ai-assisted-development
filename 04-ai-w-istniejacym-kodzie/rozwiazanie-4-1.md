# Rozwiązanie wzorcowe - lab 4.1

```bash
git show lab-4-2-start:docs/mapa-ryzyka.md
```

---

## Krok 1 - co powinno wyjść z inwentaryzacji

Jedenaście pozycji. Te, które agent znajduje niezawodnie:

| Problem | Gdzie |
|---|---|
| Sklejanie SQL-a ze stringów | `app/db.py:113-120` |
| Klucz API w kodzie | `app/konfiguracja.py:6` |
| `datetime.utcnow()` - przestarzałe od 3.12 | `app/rabaty.py:29`, `app/raporty.py:48`, `app/powiadomienia.py:53`, `app/platnosci.py:32` |
| Funkcja na 157 linii | `app/rozliczenia.py:13-169` |
| Brak testów dla logiki rozliczeniowej | całe `app/` poza `odsetki` |
| Stare piny w `requirements.txt` | sprzed ~2,5 roku |
| Przeliczanie wszystkich faktur w raporcie przeterminowanych | `app/raporty.py:47-66` |

Te, które znajduje rzadziej - bo wymagają zrozumienia, a nie dopasowania wzorca:

| Problem | Gdzie | Dlaczego trudne |
|---|---|---|
| Endpoint zwraca fakturę bez sprawdzenia, czyja jest | `app/main.py:43-54` | kod **wygląda** poprawnie, jest wywołanie `_kontrahent_z_naglowka()` - tyle że jego wynik nie jest do niczego użyty |
| Kursy walut wpisane ręcznie | `app/konfiguracja.py:14-18` | to nie jest błąd w kodzie, tylko w procesie |

Zwróć uwagę na pierwszy z nich. `app/main.py:44` woła funkcję autoryzacyjną i **wyrzuca
jej wynik do kosza**. Statyczna analiza tego nie złapie: token jest sprawdzany, wyjątek
przy złym tokenie leci poprawnie. Brakuje jednego porównania, którego nie ma czym wykryć
poza czytaniem ze zrozumieniem. Wrócimy do tego w module 8.

## Weryfikacja numerów linii

Trzy losowe sprawdzenia wystarczą, żeby ocenić, czy model czytał, czy pamiętał:

```bash
sed -n '113,120p' app/db.py
grep -rn "utcnow" app/
sed -n '6p' app/konfiguracja.py
```

Jeżeli choć jeden numer jest przesunięty o więcej niż linię-dwie, traktuj całą listę
jako punkt wyjścia do własnego sprawdzenia, a nie jako wynik.

---

## Krok 2 - znalezisko, które wymaga dwóch plików naraz

Pytanie brzmiało: *czy wynik przeliczenia faktury zależy od czegokolwiek poza danymi
faktury i kontrahenta?*

Odpowiedź: **tak, od daty systemowej.**

```python
# app/rabaty.py:29
dzis = datetime.utcnow().date()
```

`oblicz_fakture()` woła `rabaty.promocja_aktywna()`, żeby zdecydować, czy pozycja jest liczona
po cenie promocyjnej, czy pełnej. Ta sama faktura przeliczona dziś i za miesiąc może dać
inną kwotę, bez żadnej zmiany w danych.

**Dlaczego to nie wychodzi z inwentaryzacji plik po pliku.** `app/rozliczenia.py` wygląda
na funkcję czystą: przyjmuje obiekty, zwraca obiekt, nie dotyka bazy ani sieci.
Nieczystość jest o jeden poziom niżej. Trzeba prześledzić wywołania, a nie przejrzeć pliki.

Konsekwencje, które trzeba dopisać do mapy:
- nie da się napisać stabilnego testu bez sterowania „dzisiaj",
- raport archiwalny pokaże co innego niż wydruk z dnia wystawienia,
- błąd jest niewidoczny, dopóki ktoś nie porówna dwóch wydruków tej samej faktury.

To jest jedyna pozycja z całej listy, która **psuje testowalność wszystkiego innego**.
Dlatego w mapie wzorcowej ma ryzyko **wysokie**, mimo że to jedna linia.

---

## Krok 3 - dlaczego ocena nie może przyjść od agenta

Porównaj dwa zdania o tej samej pozycji:

> **Agent:** „Zalecam refaktoryzację `oblicz_fakture()` - funkcja jest zbyt długa
> i narusza zasadę pojedynczej odpowiedzialności."

> **Ocena zespołu:** „Jeśli nie ruszymy: rośnie koszt każdej zmiany. Jeśli ruszymy i się
> pomylimy: **zmieniają się kwoty na fakturach**. Czym sprawdzimy: **nijak**, nie ma testów.
> Wniosek: najpierw testy, refaktoryzacja potem."

Pierwsze zdanie jest prawdziwe dla większości kodu na świecie i nie prowadzi do żadnej decyzji.
Drugie ustawia kolejność pracy na dwa najbliższe laby.

**Reguła porządkująca całą tabelę:**

> Pozycja z odpowiedzią „nijak" na pytanie „czym sprawdzimy" nie nadaje się do naprawy.
> Nadaje się do napisania testu.

W tym repozytorium „nijak" mają cztery pozycje: SQL Injection, brak autoryzacji,
funkcja-moloch i raport przeterminowanych. Dwie pierwsze to moduł 8, trzecia to lab 4.2.

---

## Krok 4 - plan migracji `utcnow()`

Pięć wystąpień w czterech plikach, **dwie różne sytuacje**:

| Wystąpienie | Funkcja | Kontekst | Klasyfikacja |
|---|---|---|---|
| `app/raporty.py:48` | `przeterminowane()` | domyślna wartość `na_dzien` | mechaniczne |
| `app/raporty.py:80` | `noty_odsetkowe()` | domyślna wartość `na_dzien` | mechaniczne |
| `app/powiadomienia.py:53` | `kolejka()` | domyślna wartość `na_dzien` | mechaniczne |
| `app/platnosci.py:32` | `dopisz_wplate()` | domyślna data wpłaty | mechaniczne |
| `app/rabaty.py:29` | `promocja_aktywna()` | **decyzja o cenie pozycji na fakturze** | wymaga decyzji |

**Dwa wystąpienia siedzą w jednym pliku** - i to jest pułapka tego kroku.
Agent, który wypisze cztery, przejrzał **pliki**, a nie **wystąpienia**.
`app/raporty.py:80` powstało dopiero w labie 3.2, razem z `noty_odsetkowe()`.

Różnica techniczna: `datetime.utcnow()` zwraca obiekt **bez strefy**, `datetime.now(UTC)` -
**ze strefą**. Wszędzie tam, gdzie natychmiast bierzemy `.date()`, różnicy nie ma.
Gdyby wynik był porównywany z inną datą albo zapisywany - byłaby.

**Dla `app/rabaty.py:29` właściwą poprawką nie jest zamiana wywołania.** Właściwą poprawką
jest wstrzyknięcie daty jako parametru, żeby przeliczenie faktury przestało zależeć od zegara.
To jest zmiana sygnatury, czyli zmiana zachowania, czyli wymaga testów przed - i osobnego
wdrożenia.

Dobra odpowiedź agenta rozróżnia te dwie rzeczy. Odpowiedź „wszystkie cztery to prosta
zamiana `utcnow()` na `now(UTC)`" jest typowa i błędna.

---

## Najczęstsze potknięcia

**Lista rekomendacji zamiast listy faktów.** Prompt z kroku 1 wprost zakazuje ocen.
Jeśli dostałeś kolumnę „priorytet: wysoki/średni/niski" - model ocenił za ciebie,
nie znając ani twojego biznesu, ani twojego kalendarza.

**Zaufanie numerom linii bez sprawdzenia.** To najtańsza weryfikacja w całym kursie:
trzy komendy `sed`.

**Pominięcie kroku 2.** Bez niego mapa ryzyka jest listą rzeczy, które i tak byś zauważył.
Cała wartość jest w znalezisku, którego nie widać z jednego pliku.
