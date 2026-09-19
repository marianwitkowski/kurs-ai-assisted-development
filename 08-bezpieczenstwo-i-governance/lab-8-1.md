# Lab 8.1 - Audyt bezpieczeństwa własnym skillem

**Tag startowy: `lab-8-1-start`** · **Produkt: poprawki w `app/`, `tests/test_bezpieczenstwo.py`, skan sekretów w `make gate`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-8-1-start
make gate          # zielone: 93 testy
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-7-2"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-8-1`
> **przed** skokiem.

Tag zawiera skill `/przeglad-bezpieczenstwa` zbudowany w labie 5.2.

---

## Cel

Uruchomić na tym repozytorium workflow zbudowany w labie 5.2, znaleźć trzy klasy luk,
naprawić je i **zabezpieczyć przed powrotem**.

---

## Krok 1 - przegląd

```
/przeglad-bezpieczenstwa 4b825dc642cb6eb9a060e54bf8d69288fbee4904
```

> **Skąd ten hash.** To jest identyfikator **pustego drzewa** w gicie - ten sam
> w każdym repozytorium. `git diff <pusty-hash>` pokazuje **cały projekt jako dodany**,
> a nie zmiany między dwoma stanami.
>
> To nie jest sztuczka na pokaz. Zasiane luki - SQL Injection, brak autoryzacji, klucz
> w kodzie - są w tym repozytorium **od pierwszego commita**. Nie ma ich w żadnym diffie,
> bo nikt ich nie wprowadził; one tam po prostu były. Potwierdza to komenda:
>
> ```bash
> git diff --stat lab-1-1-start lab-8-1-start -- app/db.py app/konfiguracja.py
> ```
>
> Wynik jest pusty. **Przegląd diffa widzi zmiany, nie stan.** Luka odziedziczona
> wymaga przejścia po całym projekcie - i to jest lekcja z tego kroku,
> jeszcze przed raportem.

Skill przejdzie cały projekt. Raport wymaga przeglądu:

- [ ] czy tabela checklisty ma **wszystkie siedem** wierszy,
- [ ] czy każde ustalenie ma `plik:linia`,
- [ ] czy sekcja „Czego nie sprawdzałem" nie jest pusta,
- [ ] czy nie ma uwag stylistycznych (skill ich nie zgłasza).

Powinien znaleźć trzy klasy problemów. **Przy mniejszej liczbie poprawić skill, nie kod -
przed przejściem dalej.** To jest ten moment, w którym artefakt zespołowy zarabia na siebie.

---

## Krok 2 - potwierdzenie luk

Raport to hipoteza. Wymaga potwierdzenia.

**SQL Injection:**

```bash
.venv/bin/python -c "
from fastapi.testclient import TestClient
from app.main import app
from app import db
c = TestClient(app); H = {'Authorization': 'Bearer tok-gamma'}   # kontrahent 3
con = db.polacz()
nip = con.execute('SELECT nip FROM kontrahenci WHERE id=3').fetchone()['nip']
print('normalnie:   ', len(c.get('/faktury', params={'nip': nip}, headers=H).json()), 'faktur')
inj = c.get('/faktury', params={'nip': \"' OR 1=1 --\"}, headers=H).json()
print('po ladunku:  ', len(inj), 'faktur,', len({f['kontrahent_id'] for f in inj}), 'kontrahentow')
"
```

**Brak autoryzacji per zasób:**

```bash
.venv/bin/python -c "
from fastapi.testclient import TestClient
from app.main import app
from app import db
c = TestClient(app); H = {'Authorization': 'Bearer tok-gamma'}
con = db.polacz()
cudza = con.execute('SELECT id, kontrahent_id FROM faktury WHERE kontrahent_id != 3 LIMIT 1').fetchone()
r = c.get(f\"/faktury/{cudza['id']}\", headers=H)
print(f\"faktura kontrahenta {cudza['kontrahent_id']} czytana tokenem kontrahenta 3 -> HTTP {r.status_code}\")
print('raport przeterminowanych:', len({w['kontrahent_id'] for w in c.get('/raporty/przeterminowane', headers=H).json()}), 'kontrahentow')
print('eksport CSV:', len(c.get('/eksport/faktury.csv', headers=H).text.splitlines())-1, 'wierszy')
"
```

**Sekret:**

```bash
grep -n "ksef_live_" app/konfiguracja.py
```

**Do notatek:** ile **dokładnie** endpointów ma problem z autoryzacją. Raport mógł wskazać
jeden - sprawdzić wszystkie.

---

## Krok 3 - naprawa

```
Napraw luki wskazane w raporcie. Zakres: tylko te trzy klasy problemów,
żadnych poprawek przy okazji.

1. SQL Injection w app/db.py - parametry przez placeholdery.

2. Autoryzacja per zasób. Sprawdź WSZYSTKIE endpointy w app/main.py, nie tylko ten
   z raportu. Cudzy zasób ma dawać 404, nie 403 - uzasadnij dlaczego w komentarzu.

3. Klucz KSeF do zmiennej środowiskowej, BEZ wartości domyślnej. Brak klucza ma być
   błędem, nie cichym wysłaniem z pustym nagłówkiem. Zaktualizuj .env.example.

Nie zmieniaj istniejących testów. make gate ma być zielone.
```

Po zakończeniu - **przegląd diffa**:

```bash
git diff
```

Do sprawdzenia: czy agent poprawił wszystkie cztery endpointy z problemem autoryzacji,
czy tylko ten, który był w raporcie.

---

## Krok 4 - testy regresyjne

Naprawa bez testu wróci przy najbliższym refaktorze.

```
Napisz tests/test_bezpieczenstwo.py - po jednym teście na każdą naprawioną lukę.

Każdy test ma mieć w docstringu opis luki, która BYŁA, żeby za rok było wiadomo,
po co ten test istnieje.

Dla SQL Injection: przetestuj kilka ładunków przez parametryzację.
Dla autoryzacji: cudza faktura, cudze rozliczenie, raport, eksport CSV,
oraz test, że cudzy zasób daje 404, a nie 403.
Dla sekretu: test, że w źródle nie ma klucza, i że brak klucza to błąd.
```

```bash
make gate
```

---

## Krok 5 - bramka rośnie

Test chroni przed **tą** luką. Skan chroni przed **klasą** luk.

```
Napisz skrypty/skan_sekretow.sh i dołóż go do celu gate w Makefile.

Skanuje pliki śledzone przez gita. Kilka wzorców, które faktycznie wpadają
do repozytoriów: klucze API, klucze prywatne, przypisania hasła do zmiennej.
Krótka lista, zrozumiała - nie zastępujemy gitleaks, ma być szybki.

Kod wyjścia 1 przy znalezieniu.
```

Sprawdzenie skuteczności - sekret wraca do pliku:

```bash
cp app/konfiguracja.py /tmp/konf.bak
echo 'KLUCZ_TESTOWY = "ksef_live_7f3a9c21e84b4d6fa0c5e19b3d7a2f88"' >> app/konfiguracja.py
./skrypty/skan_sekretow.sh; echo "exit=$?  (ma być 1)"
cp /tmp/konf.bak app/konfiguracja.py
make gate
```

> Linia idzie na koniec pliku zamiast podmiany istniejącej przez `sed` - poprawka
> z kroku 3 mogła wyglądać inaczej niż wzorcowa i wzorzec `sed` by nie trafił. Test skanera
> ma sprawdzać **skaner**, a nie trafność zgadywania kształtu cudzej poprawki.

> Dlaczego skan sekretów wchodzi do bramki **dopiero teraz**, a nie w labie 5.1:
> znalazłby ten klucz trzy moduły wcześniej i hook `Stop` nie pozwoliłby zamknąć
> tamtego labu. To nie jest przypadek - **bramka rośnie razem z zespołem.**

---

## Krok 6 - to, co zostaje w historii

Klucz jest usunięty z pliku. Czy jest usunięty z repozytorium, pokazuje historia:

```bash
git log -p --all -- app/konfiguracja.py | grep -c "ksef_live_"
```

**Wynik jest większy od zera.**

Trzy pytania do rozstrzygnięcia:

1. Kto miał dostęp do tego klucza, odkąd trafił do repozytorium?
2. Czy usunięcie go z pliku cokolwiek tu zmieniło?
3. Jaka jest **pierwsza** czynność, którą trzeba wykonać?

Odpowiedź na trzecie: **unieważnić klucz**. Nie przepisać historii, nie usunąć pliku -
unieważnić. Wszystko inne jest kosmetyką wykonywaną po tym.

Do spisania:

```
Napisz docs/incydent-klucz-ksef.md: co się stało, jaki był zasięg (uwzględnij
historię gita i konteksty sesji agenta), co zostało zrobione, czego NIE zrobiono
i dlaczego (nie przepisujemy historii), jak to weryfikować i co zmieniamy w procesie.
```

```bash
git add -A
git commit -m "Naprawa luk bezpieczenstwa znalezionych przez /przeglad-bezpieczenstwa"
```

---

## Kryteria zaliczenia

- [ ] Skill znalazł wszystkie trzy klasy luk, a raport miał komplet checklisty.
- [ ] Każda luka jest potwierdzona **wykonaniem**, nie tylko czytaniem raportu.
- [ ] Naprawione są **wszystkie cztery** endpointy z problemem autoryzacji.
- [ ] Cudzy zasób daje 404, z uzasadnieniem, dlaczego nie 403.
- [ ] Testy regresyjne mają w docstringu opis luki, która była.
- [ ] `make gate` zawiera skan sekretów i skan **wyłapuje** klucz po jego przywróceniu.
- [ ] Wiadomo, że klucz nadal jest w historii gita, i wiadomo, co z tym zrobić.

## Pułapki

**Naprawa tylko tego, co wskazał raport.** Raport wskazał jeden endpoint bez autoryzacji.
Są cztery. Narzędzie daje punkt zaczepienia, nie wyczerpującą listę.

**403 zamiast 404.** 403 potwierdza, że zasób istnieje. Przy sekwencyjnych
identyfikatorach pozwala policzyć cudze faktury.

**Naprawa bez testu.** Wróci przy pierwszym refaktorze i nikt nie zauważy.

**„Usunąłem klucz, problem rozwiązany."** Klucz jest w historii, w każdym klonie
i w każdym worktree. **Unieważnienie jest jedyną czynnością, która zamyka incydent.**

**Wartość domyślna dla sekretu.** `os.environ.get("KSEF_API_KEY", "jakas-wartosc")`
to ten sam problem w innym miejscu. Brak klucza ma być błędem.

---

[Rozwiązanie wzorcowe](rozwiazanie-8-1.md) · [Następny lab](lab-8-2.md)
