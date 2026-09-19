# Lab 4.1 - Mapa ryzyka i plan migracji

**Tag startowy: `lab-4-1-start`** · **Produkt: `docs/mapa-ryzyka.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-4-1-start
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-3-2"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-4-1`
> **przed** skokiem.


---

## Cel

Oddzielić dwie czynności, które zwykle się zlewają: **inwentaryzację** (agent robi ją dobrze)
i **ocenę ryzyka** (po stronie człowieka, bo agent nie zna domeny biznesowej). Efektem ma być
lista, z której da się wybrać, co zrobić w następnej kolejności.

---

## Krok 1 - inwentaryzacja bez ocen

```
Zrób inwentaryzację problemów w katalogu app/. Dla każdego podaj:
plik, numer linii, rodzaj problemu, jednozdaniowy opis.

Zasady:
- Nie proponuj poprawek.
- Nie oceniaj ważności ani pilności.
- Nie pisz, co "warto" albo "należy" zrobić.
- Każda pozycja musi mieć numer linii, który sprawdziłeś.
Posortuj po pliku.
```

Wyrywkowo sprawdzić trzy pozycje:

```bash
sed -n '113,120p' app/db.py
grep -rn "utcnow" app/
```

**Jeżeli któryś numer linii się nie zgadza - cała lista jest podejrzana.**
Halucynacja w numerze linii oznacza, że model nie czytał, tylko pamiętał.

---

## Krok 2 - dwa pytania, których agent sam nie zada

Inwentaryzacja jest płaska. Teraz w grę wchodzą rzeczy widoczne dopiero z kilku miejsc naraz:

```
Dwa pytania:

1. Czy wynik przeliczenia faktury zależy od czegokolwiek poza danymi faktury
   i kontrahenta? Sprawdź to, a nie zgaduj - prześledź, co woła oblicz_fakture()
   i czego te funkcje używają.

2. Które z problemów z twojej listy uniemożliwiają napisanie stabilnego testu?
```

Pierwsze pytanie prowadzi do `app/rabaty.py:29`. To jest najważniejsze znalezisko
w tym labie i nie wyjdzie z inwentaryzacji plik po pliku.

---

## Krok 3 - ocena ryzyka

Teraz część po stronie człowieka. Na każdą pozycję z listy trzy pytania:

| Pytanie | Możliwe odpowiedzi |
|---|---|
| Co się stanie bez zmiany? | nic / rośnie dług / awaria / **strata pieniędzy** |
| Co się stanie przy zmianie z pomyłką? | nic / test złapie / **produkcja** |
| Czym sprawdzić, że nic się nie zepsuło? | testy / ręcznie / **nijak** |

Zapisać `docs/mapa-ryzyka.md` z tabelą. Formatowanie tabeli można zlecić agentowi,
ale **oceny wpisuje człowiek** - to jest cała wartość tego kroku.

Reguła porządkująca:

> Pozycja z odpowiedzią **„nijak"** na trzecie pytanie nie nadaje się do naprawy.
> Nadaje się do napisania testu.

---

## Krok 4 - plan migracji `datetime.utcnow()`

```
W repozytorium są wywołania datetime.utcnow(). Znajdź WSZYSTKIE - policz je
sam, nie zakładaj liczby. Dla każdego powiedz,
czy zamiana na datetime.now(UTC) jest równoważna, czy zmienia zachowanie.
Uzasadnij osobno dla każdego miejsca - nie odpowiadaj zbiorczo.
```

Wynik dopisać do `docs/mapa-ryzyka.md` jako sekcję „Plan migracji".

**Dwie rzeczy do sprawdzenia w odpowiedzi.**

Po pierwsze - **czy policzył dobrze**. Wystąpień jest **pięć, w czterech plikach**:
`app/raporty.py` ma dwa (`:48` i `:80`). Agent, który wypisze cztery, przejrzał pliki,
a nie wystąpienia - i to jest dokładnie ten błąd, przed którym ostrzega krok 1.

Po drugie - **czy rozróżnił konteksty**. Cztery z pięciu to domyślne wartości parametrów,
tam zamiana jest mechaniczna. Piąte jest wewnątrz decyzji o cenie pozycji na fakturze.

```bash
git add docs/ && git commit -m "Mapa ryzyka i plan migracji"
```

---

## Kryteria zaliczenia

- [ ] Numery linii z inwentaryzacji sprawdzone wyrywkowo.
- [ ] Zależność przeliczenia faktury od zegara systemowego znaleziona.
- [ ] Każda pozycja ma ocenę uczestnika, nie ocenę agenta.
- [ ] Wiadomo, które pozycje trzeba najpierw obudować testami.
- [ ] Plan migracji rozróżnia zamiany mechaniczne od wymagających decyzji.

## Pułapki

**Przyjęcie listy rekomendacji od agenta.** „Zalecam refaktoryzację `oblicz_fakture()`
i dodanie testów" to zdanie prawdziwe dla 90% kodu na świecie. Nie jest oceną ryzyka,
tylko ogólnikiem. Ocena ryzyka to zdanie, które da się sfalsyfikować.

**Pominięcie kroku 2.** Inwentaryzacja plik po pliku nie znajdzie problemu rozłożonego
na dwa moduły. Zależność przeliczenia od zegara jest właśnie taka: `app/rozliczenia.py`
wygląda na czystą funkcję, a `app/rabaty.py:29` czyta `datetime.utcnow()`.

**Uznanie migracji `utcnow()` za mechaniczną.** `datetime.utcnow()` zwraca obiekt **bez strefy**,
`datetime.now(UTC)` - **ze strefą**. Tam, gdzie od razu wchodzi `.date()`, różnicy nie ma.
Gdzie indziej jest.

---

[Rozwiązanie wzorcowe](rozwiazanie-4-1.md) · [Następny lab](lab-4-2.md)
