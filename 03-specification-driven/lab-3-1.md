# Lab 3.1 - Specyfikacja przed kodem

**Czas: ~40 min** · **Tag startowy: `lab-3-1-start`** · **Produkt: `specyfikacje/noty-odsetkowe.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-3-1-start
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-2-2"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-3-1`
> **przed** skokiem.


W tym labie **nie piszesz ani linii kodu produkcyjnego.** Jeśli w połowie przyłapiesz się
na tym, że agent edytuje pliki - wyszedłeś z trybu planowania.

---

## Wymaganie biznesowe

Dostajesz je dokładnie w tej formie, w jakiej trafiłoby do ciebie w pracy:

> **Od kierownika działu rozliczeń:**
> Klienci płacą po terminie i nic ich to nie kosztuje. Chcemy im naliczać odsetki
> za opóźnienie i pokazywać to na zestawieniu. Zrobicie to na następny sprint?

To wszystko. Tyle dostajesz.

---

## Cel

Wyprodukować specyfikację, po której implementacja jest mechaniczna - i zobaczyć,
ile rozstrzygnięć agent podjąłby za ciebie, gdybyś kazał mu od razu pisać kod.

---

## Krok 1 - pomiar „bez specyfikacji" (7 min)

Świeża sesja, **normalny tryb** (nie planowania):

```bash
claude
```

Wklej wymaganie tak, jak je dostałeś:

```
Klienci płacą po terminie i nic ich to nie kosztuje. Chcemy im naliczać odsetki
za opóźnienie i pokazywać to na zestawieniu. Nie pisz kodu - powiedz mi tylko,
jak to zaimplementujesz. Krótko.
```

**Zapisz odpowiedź.** Potem zrób z niej listę: **ile decyzji podjął, nie pytając?**
Sprawdź konkretnie:

- jaką stopę odsetek przyjął i skąd ją wziął,
- od którego dnia liczy,
- od kwoty brutto czy netto,
- 365 czy 366 dni,
- czy uwzględnił wpłaty częściowe (w repo jest `app/platnosci.py`),
- czy uwzględnił korekty (w repo jest `app/korekty.py`),
- czy uwzględnił faktury walutowe.

Policz je. **Ta liczba jest wynikiem kroku 1.**

```
/clear
```

---

## Krok 2 - lista pytań zamiast odpowiedzi (8 min)

Wejdź w tryb planowania:

```
Shift+Tab   (aż pasek statusu pokaże: ⏸ plan mode on)
```

> Na planie Pro/Max sesja startuje w trybie **auto**. Pierwsze `Shift+Tab` przenosi
> do Manual, kolejne do accept edits, następne do plan. Patrz na pasek statusu.

```
Wymaganie od biznesu: "Klienci płacą po terminie i nic ich to nie kosztuje.
Chcemy im naliczać odsetki za opóźnienie i pokazywać to na zestawieniu."

Zanim cokolwiek zaproponujesz: przeczytaj kod tego serwisu i wypisz listę pytań,
na które musisz znać odpowiedź, żeby to zaimplementować poprawnie.
Przy każdym pytaniu podaj, którego miejsca w kodzie dotyczy (plik + linia).
Nie odpowiadaj na te pytania. Nie proponuj rozwiązania.
```

**Porównaj z krokiem 1.** Ile z tych pytań model wcześniej rozstrzygnął po cichu?

---

## Krok 3 - odpowiedzi biznesu (5 min)

Rolę biznesu gra ta kartka. Oto ustalenia z kierownika działu rozliczeń:

| Pytanie | Decyzja biznesu |
|---|---|
| Stopa odsetek | Ustawowe za opóźnienie w transakcjach handlowych. Jedna stawka, **konfigurowalna**, domyślnie 14,5% rocznie |
| Od którego dnia | Od **dnia następnego** po terminie płatności, włącznie z dniem zapłaty |
| Podstawa | **Kwota do zapłaty** (brutto minus zaliczka), pomniejszona o wpłaty od dnia każdej wpłaty |
| Rok bazowy | **365 dni**, zawsze, także w latach przestępnych |
| Zaokrąglanie | Do grosza, **na końcu**, `ROUND_HALF_UP` |
| Faktury walutowe | **Poza zakresem tej iteracji.** Zwróć jasny błąd zamiast liczyć |
| Korekty | **Poza zakresem tej iteracji.** Faktury ze statusem `korekta` pomijamy |
| Próg minimalny | Nie naliczamy noty poniżej **10 zł** - koszt obsługi przewyższa kwotę |
| Gdzie to widać | Nowy endpoint `GET /raporty/odsetki` oraz funkcja do użycia w `app/powiadomienia.py` |
| Czego **nie** robimy | Nie wysyłamy, nie zapisujemy do bazy, nie generujemy PDF-ów, nie zmieniamy `oblicz_fakture()` |

Zwróć uwagę na dwa ostatnie wiersze. **„Poza zakresem" i „czego nie robimy" to najcenniejsze
części każdej specyfikacji.** Bez nich agent zrobi wszystko, co mu przyjdzie do głowy,
i będzie miał rację, bo nikt nie powiedział, że nie.

---

## Krok 4 - specyfikacja (15 min)

Nadal w trybie planowania:

```
Oto odpowiedzi biznesu: [wklej tabelę z kroku 3]

Napisz specyfikację do pliku specyfikacje/noty-odsetkowe.md. Struktura:

1. Wymaganie biznesowe - jednym akapitem, językiem biznesu.
2. Zakres - co robimy i czego świadomie nie robimy w tej iteracji.
3. Reguły obliczeniowe - ponumerowane, każda jednoznaczna.
4. Kryteria akceptacji - minimum 6 przypadków jako konkretne liczby
   (dane wejściowe → oczekiwany wynik), łącznie z przypadkami brzegowymi.
5. Ryzyka - co może się zepsuć poza obszarem zmiany, z plikami i liniami.
6. Otwarte pytania - czego nadal nie wiemy.

Zasady:
- Każde twierdzenie o istniejącym kodzie popieraj plikiem i numerem linii.
- Jeżeli coś przyjmujesz, a nie zostało to rozstrzygnięte - wypisz to w sekcji
  "Otwarte pytania", nie w regułach.
- Nie pisz kodu.
```

**Przeczytaj wynik krytycznie.** Konkretnie sprawdź:

- Czy kryteria akceptacji to **liczby**, czy opisy w rodzaju „powinno policzyć poprawnie"?
- Czy ryzyka wskazują **konkretne miejsca w kodzie**? Podpowiedź: co się stanie,
  gdy `app/raporty.py` przeliczy fakturę walutową?
- Czy sekcja „Otwarte pytania" **nie jest pusta**? Jeśli jest - model coś ukrył
  w regułach. Znajdź to.

Jeżeli coś nie gra, popraw promptem albo `Ctrl+G` i ręcznie w edytorze.

---

## Krok 5 - zatwierdzenie i commit (5 min)

Zatwierdź plan (opcja z ręcznym zatwierdzaniem edycji - chcesz zobaczyć, co zapisuje),
żeby agent zapisał plik.

```bash
git add specyfikacje/
git commit -m "Specyfikacja not odsetkowych"
```

---

## Kryteria zaliczenia

- [ ] Wiesz, ile rozstrzygnięć agent podjął za ciebie w kroku 1. Masz tę liczbę zapisaną.
- [ ] Specyfikacja ma co najmniej 6 kryteriów akceptacji wyrażonych **liczbami**.
- [ ] Sekcja „Zakres" wprost wymienia, czego **nie** robimy.
- [ ] Ryzyka wskazują pliki i linie, nie ogólniki.
- [ ] Sekcja „Otwarte pytania" nie jest pusta.
- [ ] Nie powstała ani jedna linia kodu produkcyjnego.

## Pułapki

**Wyjście z trybu planowania w połowie.** Jeśli agent zaczął edytować `app/`, zatwierdziłeś plan
za wcześnie. `git checkout -- app/` i wróć do planowania.

**Przyjęcie specyfikacji, bo „wygląda profesjonalnie".** Długość i formatowanie nie są kryterium.
Kryterium jest: *czy dwie osoby, czytając to osobno, zaimplementują to samo?*

**Pusta sekcja „Otwarte pytania".** Przy tym wymaganiu **zawsze** zostaje coś otwartego.
Choćby: co zrobić, gdy wpłata przewyższa kwotę faktury? Albo: czy stopa 14,5% obowiązuje
przez cały okres opóźnienia, czy zmienia się w czasie? Jeżeli specyfikacja tego nie wymienia,
to znaczy, że model to rozstrzygnął po cichu - czyli dokładnie to, przed czym jest ten lab.

**Kryteria akceptacji bez przypadków brzegowych.** Sześć przypadków, w których wszystko jest
normalne, to jeden przypadek zapisany sześć razy. Przypadki brzegowe: zapłacone w terminie,
kwota poniżej progu 10 zł, faktura walutowa, wpłata częściowa w środku okresu.

---

[Rozwiązanie wzorcowe](rozwiazanie-3-1.md) · [Następny lab](lab-3-2.md)
