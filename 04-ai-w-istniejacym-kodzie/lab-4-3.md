# Lab 4.3 - Refaktoryzacja pod ochroną testów

**Czas: ~30 min** · **Tag startowy: `lab-4-3-start`** · **Produkt: zrefaktoryzowane `app/rozliczenia.py`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-4-3-start
make test          # 32 testy, wszystkie zielone
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-4-2"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-4-3`
> **przed** skokiem.

Tag zawiera **wzorcowe testy charakterystyki**. Jeśli wolisz pracować na swoich, odłóż moje
przez `git stash push -u` i przywróć swoje przez `git stash apply`. Wtedy ochrona będzie taka,
jaką sobie zbudowałeś.

---

## Cel

Zmniejszyć `oblicz_fakture()` ze 157 linii do czegoś czytelnego, **nie zmieniając ani jednego
grosza** na żadnej fakturze - i złapać agenta, gdy spróbuje „uprościć" regułę biznesową.

---

## Krok 1 - ustaw granice, zanim agent zacznie (3 min)

```
Zrefaktoryzuj oblicz_fakture() w app/rozliczenia.py.

To jest refaktoryzacja czysto strukturalna:
- te same wejścia mają dawać te same wyjścia CO DO GROSZA,
- kolejność i treść ostrzeżeń musi zostać identyczna,
- NIE zmieniaj żadnego zachowania,
- NIE zmieniaj testów w tests/,
- NIE zmieniaj innych plików w app/.

Jeżeli po drodze uznasz, że coś jest błędem - NAPISZ MI O TYM OSOBNO,
ale nie poprawiaj.

Cel: funkcja główna czytelna na jeden ekran, kroki wydzielone do nazwanych funkcji.
Po każdej zmianie uruchom: make test
```

Trzy zdania robią tu robotę: „co do grosza", „napisz, ale nie poprawiaj",
„nie zmieniaj testów".

---

## Krok 2 - refaktoryzacja (12 min)

Pozwól agentowi pracować, ale **czytaj, co pisze w wiadomościach**, nie tylko w kodzie.

Zdania, po których natychmiast zaglądasz w diff:

> „Uprościłem też…" · „Przy okazji poprawiłem…" · „Ten warunek wydawał się zbędny…"
> · „Ujednoliciłem zaokrąglanie…" · „To wyglądało na pomyłkę, więc…"

Po zakończeniu:

```bash
make test
make lint
git diff --stat
git diff tests/       # MUSI być puste
```

---

## Krok 3 - polowanie na uproszczenia (8 min)

Nawet gdy testy są zielone, przejrzyj diff pod kątem czterech konkretnych miejsc.
To są te, które agent „poprawia" najczęściej:

| Co sprawdzić | Gdzie szukać w diffie | Dlaczego to ważne |
|---|---|---|
| Czy VAT nadal liczony **per pozycja**, a nie od sumy | wywołania `vat.podsumuj()` / `vat.vat_pozycji()` | różnica groszowa, testy ją łapią |
| Czy pozycja promocyjna nadal **wlicza się do progu** | funkcja licząca sumę przed rabatem | reguła biznesowa |
| Czy próg faktury walutowej nadal liczony **po kursie** | mnożenie przez kurs przed wyznaczeniem stawki | reguła biznesowa |
| Czy ostrzeżenie o wygasłej promocji pojawia się **raz** | pętla wyznaczająca sumę przed rabatem | test sprawdza treść, ale nie liczbę wystąpień |
| Czy `zaliczka` nadal ma guard **`> 0`** | warunek clampujący zaliczkę do brutto | korekty mają **ujemne** brutto; testy tego nie łapią |

**Dwa ostatnie wiersze to pułapki, których testy nie łapią.**

Ostrzeżenie: oryginalna funkcja miała dwa przebiegi po pozycjach, a ostrzeżenie dopisywała
tylko w pierwszym. Jeśli po refaktoryzacji dopisuje się w obu - testy nadal przechodzą
(sprawdzają `in w.ostrzezenia`), a lista ostrzeżeń w API się zdublowała.

Zaliczka: `if zaliczka > 0 and zaliczka > brutto` wygląda na warunek z nadmiarowym
pierwszym członem. Nie jest - **korekta ma ujemne brutto**, więc bez guardu `0 > -5400`
jest prawdziwe i `do_zaplaty` spada z −5400,00 do 0,00. **32 testy nadal zielone.**

Sprawdź to wprost:

```bash
.venv/bin/python -c "
from datetime import date
from decimal import Decimal
from app.modele import Faktura, Kontrahent, PozycjaFaktury
from app.rozliczenia import oblicz_fakture
k = Kontrahent(id=1, nazwa='T', nip='0010237577', dni_terminu=14)
p = PozycjaFaktury(nazwa='Licencja', ilosc=Decimal('1'), cena_jednostkowa=Decimal('1800.00'),
                   cena_promocyjna=Decimal('1440.00'),
                   promocja_od=date(2024,1,1), promocja_do=date(2024,6,30))
f = Faktura(numer='FV/T/1', kontrahent_id=1, kontrahent_nip='0010237577',
            data_wystawienia=date(2026,3,10), data_sprzedazy=date(2026,3,10), pozycje=[p])
print(oblicz_fakture(f, k).ostrzezenia)
"
```

Ma być **jedno** ostrzeżenie, nie dwa.

---

## Krok 4 - dowód na całej bazie (5 min)

Testy pokrywają kilkanaście przypadków. Baza ma 204 faktury. Porównaj wyniki przed i po:

```bash
zapisz() {
  .venv/bin/python -c "
from app import db, raporty
con = db.polacz()
for f in db.wszystkie_faktury(con):
    r = raporty.rozlicz_fakture_z_bazy(con, f.id)
    print(f.id, r.netto, r.rabat_lacznie, r.vat, r.brutto, r.do_zaplaty,
          r.termin_platnosci, sorted(r.vat_wg_stawek.items()), sorted(r.ostrzezenia))
"
}
git stash -q && zapisz > /tmp/przed.txt
git stash pop -q && zapisz > /tmp/po.txt
diff /tmp/przed.txt /tmp/po.txt && echo "IDENTYCZNE na wszystkich 204 fakturach"
```

To jest ostateczny dowód refaktoryzacji zachowawczej. Jeśli `diff` cokolwiek pokazuje -
zmieniłeś zachowanie, niezależnie od tego, że testy są zielone.

---

## Krok 5 - commit

```bash
git add app/rozliczenia.py
git commit -m "Refaktoryzacja oblicz_fakture() bez zmiany zachowania"
```

---

## Kryteria zaliczenia

- [ ] 32 testy przechodzą, `git diff tests/` puste.
- [ ] `diff` wyników na 204 fakturach jest pusty.
- [ ] `oblicz_fakture()` mieści się na jednym ekranie.
- [ ] Reguły biznesowe mają komentarz mówiący, że są celowe.
- [ ] Znany błąd (rabat przy wygasłej promocji) **nadal tam jest**, z komentarzem.
- [ ] Ostrzeżenie o wygasłej promocji pojawia się dokładnie raz.
- [ ] Jeśli agent zaproponował poprawkę błędu - masz ją zapisaną i **nie zastosowałeś** jej.

## Pułapki

**„Testy są zielone, więc jest dobrze."** Testy pokrywają to, co ktoś pomyślał.
Porównanie na 204 fakturach pokrywa to, co jest w danych. Rób oba.

**Poprawienie znanego błędu przy okazji.** Rabat przy wygasłej promocji **jest** błędem.
Poprawka jest o jedną linię. I nie wolno jej zrobić w tym labie - bo to jest zmiana kwot
na fakturach, która wymaga decyzji działu handlowego i osobnego wdrożenia.
Refaktoryzacja i zmiana zachowania nie jadą w jednym commicie. Nigdy.

**Zmiana testu, żeby przeszedł.** Jeśli pojawiła się pokusa, żeby dotknąć `tests/` -
to znaczy, że refaktoryzacja zmieniła zachowanie. Cofnij refaktoryzację, nie test.

**Rozbicie funkcji na dwadzieścia trzylinijkowych.** Cel to czytelność, nie liczba funkcji.
Sześć-siedem nazwanych kroków wystarczy. Dwadzieścia funkcji z nazwami `_krok_1`, `_krok_2`
jest gorsze niż jedna długa.

---

[Rozwiązanie wzorcowe](rozwiazanie-4-3.md) · [Checklista modułu](checklista.md)
