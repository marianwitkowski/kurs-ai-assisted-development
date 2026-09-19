# Lab 3.2 - Implementacja według specyfikacji

**Czas: ~40 min** · **Tag startowy: `lab-3-2-start`** · **Produkt: `app/odsetki.py`, `tests/test_odsetki.py`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-3-2-start
cat specyfikacje/noty-odsetkowe.md
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-3-1"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-3-2`
> **przed** skokiem.

> Możesz też pracować dalej na własnej - wtedy liczby w twoich testach będą inne niż wzorcowe
> i tak ma być.

Tag `lab-3-2-start` zawiera **wzorcową specyfikację**. Przeczytaj ją, zanim zaczniesz -
to jest teraz twój kontrakt.

---

## Cel

Przejść pełną ścieżkę wymaganie → kod → testy → review, pilnując **dwóch** rzeczy:
żeby testy sprawdzały specyfikację, a nie implementację, i żeby diff nie wyszedł poza zakres.

---

## Krok 1 - testy przed implementacją (12 min)

To nie jest ortodoksja TDD. To jest ochrona przed konkretnym mechanizmem: agent, który
najpierw napisze kod, a potem testy patrząc na ten kod, wyprodukuje testy przechodzące zawsze.

```
Przeczytaj specyfikacje/noty-odsetkowe.md, sekcja 4 (Kryteria akceptacji).

Napisz tests/test_odsetki.py: po jednym teście na każde kryterium A1-A11.
Testy mają wołać funkcje, których jeszcze nie ma - nazwij je tak, jak uważasz
za sensowne, i wypisz mi ich sygnatury.

Zasady:
- Utwórz też pusty plik tests/__init__.py.
- Liczby w testach bierz DOSŁOWNIE ze specyfikacji. Nie przeliczaj ich sam.
- Docstring każdego testu to numer kryterium i jego treść.
- Nie pisz jeszcze app/odsetki.py.
```

> **Dlaczego `tests/__init__.py`.** `make test` woła gołe `pytest`, a to nie dokłada
> katalogu bieżącego do `sys.path`. Bez tego pliku dostaniesz
> `ModuleNotFoundError: No module named 'app'` - komunikat, który wygląda,
> jakbyś zepsuł aplikację, a nie jakby brakowało modułu, którego jeszcze nie napisałeś.

Uruchom:

```bash
make test
```

**Oczekiwany wynik:** pytest przerywa **na etapie zbierania testów**, jednym błędem:

```
ImportError: cannot import name 'odsetki' from 'app'
!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!
```

To jest poprawny stan - modułu jeszcze nie ma. Zwróć uwagę, że pytest **nie uruchamia**
żadnego testu: jeden błąd importu zatrzymuje całą kolekcję.

> Jeśli widzisz `No module named 'app'` - brakuje `tests/__init__.py`.
>
> Jeśli testy przeszły, to znaczy, że agent mimo wszystko napisał implementację.
> `git status` i usuń ją. Ten krok ma sens tylko wtedy, gdy testy istnieją **przed** kodem.

---

## Krok 2 - implementacja (12 min)

```
Teraz napisz app/odsetki.py tak, żeby testy z tests/test_odsetki.py przeszły.

Zakres - czytaj sekcję 2 specyfikacji:
- tylko app/odsetki.py,
- NIE zmieniaj app/rozliczenia.py, app/vat.py ani schematu bazy,
- NIE dodawaj zapisu do bazy, numeracji not ani wysyłki,
- NIE zmieniaj testów, żeby przechodziły.

Funkcja licząca ma być czysta: bez dostępu do bazy, jak app/rozliczenia.py.
Zaokrąglaj przez app.vat.zaokraglij() - tak mówi CLAUDE.md.

Jeżeli któreś kryterium akceptacji jest sprzeczne z innym albo niewykonalne -
zatrzymaj się i powiedz, zamiast zmieniać test.
```

```bash
make test
make lint
```

---

## Krok 3 - review diffa (8 min)

**To jest najważniejszy krok tego labu.**

```bash
git diff
git status
```

Sprawdź po kolei:

- [ ] Czy zmieniły się **tylko** pliki wymienione w zakresie?
- [ ] Czy agent nie „poprawił po drodze" czegoś w istniejących modułach?
- [ ] Czy nie doszła zależność do `requirements.txt`?
- [ ] Czy któryś test został zmieniony **po** napisaniu implementacji?
      Sprawdź: `git diff tests/` po kroku 2 powinno być puste, jeśli commitowałeś po kroku 1.
- [ ] Czy rok bazowy to stałe 365, także dla roku przestępnego (A9)?
- [ ] Czy zaokrąglenie jest **tylko na końcu**, a nie po każdym odcinku (R6)?

Ostatnie dwa punkty są miejscami, w których model najczęściej „poprawia" specyfikację
na to, co uważa za rozsądniejsze.

Sprawdź też, czy odsetki liczą się od właściwego dnia:

```bash
.venv/bin/python -c "
from datetime import date
from decimal import Decimal
from app import odsetki
print(odsetki.odsetki_za_opoznienie(Decimal('10000.00'), date(2026,1,10), date(2026,1,11)))
"
```

Ma wyjść kwota za **jeden** dzień (`3.97`), nie zero i nie za dwa dni.

---

## Krok 4 - adapter i endpoint (6 min)

Dopiero teraz dotykamy istniejącego kodu. Punkt 7 specyfikacji, kroki 3-4.

```
Zgodnie z sekcją 7 specyfikacji, kroki 3 i 4:

1. Dodaj do app/raporty.py funkcję noty_odsetkowe(con, kontrahent_id, na_dzien=None),
   która dociąga dane z bazy i woła funkcję z app/odsetki.py.
   Wpłaty bierz z platnosci.wplaty_kontrahenta().
2. Dodaj endpoint GET /raporty/odsetki w app/main.py, wzorując się na istniejących
   endpointach raportowych.

Uwaga: reguła R7 każe funkcji zgłosić błąd dla faktury walutowej, ale raport zbiorczy
nie może się z tego powodu wywalić. Rozstrzygnij to i powiedz mi, jak.
```

To ostatnie zdanie jest celowe: specyfikacja **nie rozstrzyga** tego przypadku.
Zobacz, czy agent to zauważy, czy po cichu wybierze.

Weryfikacja:

```bash
.venv/bin/python -c "
from fastapi.testclient import TestClient
from app.main import app
c = TestClient(app)
r = c.get('/raporty/odsetki', headers={'Authorization': 'Bearer tok-gamma'})
print(r.status_code, len(r.json()))
print(r.json()[0])
"
```

---

## Krok 5 - commit

```bash
make test && make lint
git add app/odsetki.py tests/ app/raporty.py app/main.py
git commit -m "Noty odsetkowe wedlug specyfikacji"
```

---

## Kryteria zaliczenia

- [ ] `make test` przechodzi, `make lint` przechodzi.
- [ ] Testy powstały **przed** implementacją i nie były zmieniane, żeby przeszły.
- [ ] Liczby w testach są dosłownie ze specyfikacji.
- [ ] Diff nie wychodzi poza zakres z sekcji 2 specyfikacji.
- [ ] Umiesz wskazać w kodzie każdą regułę R1-R10.
- [ ] Wiesz, jak rozstrzygnięto przypadek faktury walutowej w raporcie zbiorczym
      - i wiesz, że specyfikacja tego nie rozstrzygała.

## Pułapki

**Test zmieniony, żeby przeszedł.** Najczęściej dotyczy A9 (rok przestępny): 1 453,97 zł
wygląda na błąd, bo to więcej niż 14,5% od 10 000 zł. **Nie jest błędem** - reguła R5 mówi,
że rok bazowy to zawsze 365. Jeśli agent „poprawił" ten test na 1 450,00 - cofnij.

**Zaokrąglanie po każdym odcinku.** W A4 dwa odcinki: 59,589041 + 38,136986 = 97,726027 → 97,73.
Przy zaokrąglaniu po każdym odcinku: 59,59 + 38,14 = 97,73. Tu wychodzi tyle samo -
ale nie zawsze. Reguła R6 jest jednoznaczna i kod ma ją odzwierciedlać, nawet jeśli
w tym akurat przypadku wynik się zgadza.

**Zakres rozszerzony „przy okazji".** Klasyka: agent zauważa `datetime.utcnow()`
w `app/raporty.py` i poprawia to od razu. Poprawka jest słuszna - i jest poza zakresem.
Migracją zajmiesz się jutro, w labie 6.1. Dziś wycofaj.

**Podstawa z `brutto` zamiast `do_zaplaty`.** Reguła R3 mówi wprost: `Rozliczenie.do_zaplaty`,
czyli po odliczeniu zaliczki. Faktury z zaliczką są w bazie (co dziesiąta), więc błąd
przejdzie niezauważony na fakturach bez zaliczki.

**Pominięcie kroku 3.** Jeśli nie czytasz diffa, cały ten workflow jest teatrem.
Specyfikacja i testy służą temu, żeby review było **szybkie**, a nie żeby było niepotrzebne.

---

[Rozwiązanie wzorcowe](rozwiazanie-3-2.md) · [Checklista modułu](checklista.md)
