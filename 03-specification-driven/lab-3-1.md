# Lab 3.1 - Specyfikacja przed kodem

**Tag startowy: `lab-3-1-start`** · **Produkt: `specyfikacje/noty-odsetkowe.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-3-1-start
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-2-2"
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
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-3-1`
> **przed** skokiem.


W tym labie **nie powstaje ani linia kodu produkcyjnego.** Agent edytujący pliki w połowie
oznacza wyjście z trybu planowania.

---

## Wymaganie biznesowe

Wymaganie przychodzi dokładnie w tej formie, w jakiej trafia do zespołu w pracy:

> **Od kierownika działu rozliczeń:**
> Klienci płacą po terminie i nic ich to nie kosztuje. Chcemy im naliczać odsetki
> za opóźnienie i pokazywać to na zestawieniu. Zrobicie to na następny sprint?

To wszystko. Nic więcej nie przychodzi.

---

## Cel

Wyprodukować specyfikację, po której implementacja jest mechaniczna - i ustalić,
ile rozstrzygnięć agent podjąłby sam, dostając polecenie pisania kodu od razu.

---

## Krok 1 - pomiar „bez specyfikacji"

Świeża sesja, **normalny tryb** (nie planowania):

```bash
claude
```

Wymaganie do wklejenia w oryginalnej formie:

```
Klienci płacą po terminie i nic ich to nie kosztuje. Chcemy im naliczać odsetki
za opóźnienie i pokazywać to na zestawieniu. Nie pisz kodu - powiedz mi tylko,
jak to zaimplementujesz. Krótko.
```

**Odpowiedź zostaje zapisana.** Potem powstaje z niej lista: **ile decyzji model podjął,
nie pytając.** Do sprawdzenia konkretnie:

- jaką stopę odsetek przyjął i skąd ją wziął,
- od którego dnia liczy,
- od kwoty brutto czy netto,
- 365 czy 366 dni,
- czy uwzględnił wpłaty częściowe (w repo jest `app/platnosci.py`),
- czy uwzględnił korekty (w repo jest `app/korekty.py`),
- czy uwzględnił faktury walutowe.

Policzyć je. **Ta liczba jest wynikiem kroku 1.**

```
/clear
```

---

## Krok 2 - lista pytań zamiast odpowiedzi

Wejście w tryb planowania:

```
Shift+Tab   (aż pasek statusu pokaże: ⏸ plan mode on)
```

> Na planie Pro/Max sesja startuje w trybie **auto**. Pierwsze `Shift+Tab` przenosi
> do Manual, kolejne do accept edits, następne do plan. Rozstrzyga pasek statusu.

```
Wymaganie od biznesu: "Klienci płacą po terminie i nic ich to nie kosztuje.
Chcemy im naliczać odsetki za opóźnienie i pokazywać to na zestawieniu."

Zanim cokolwiek zaproponujesz: przeczytaj kod tego serwisu i wypisz listę pytań,
na które musisz znać odpowiedź, żeby to zaimplementować poprawnie.
Przy każdym pytaniu podaj, którego miejsca w kodzie dotyczy (plik + linia).
Nie odpowiadaj na te pytania. Nie proponuj rozwiązania.
```

**Porównanie z krokiem 1.** Liczy się, ile z tych pytań model wcześniej rozstrzygnął po cichu.

---

## Krok 3 - odpowiedzi biznesu

Rolę biznesu gra ta kartka. Ustalenia z kierownikiem działu rozliczeń:

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

Dwa ostatnie wiersze są tu najważniejsze. **„Poza zakresem" i „czego nie robimy"
to najcenniejsze części każdej specyfikacji.** Bez nich agent zrobi wszystko, co mu przyjdzie
do głowy, i będzie miał rację, bo nikt nie powiedział, że nie.

---

## Krok 4 - specyfikacja

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

**Wynik wymaga krytycznego czytania.** Do sprawdzenia konkretnie:

- Czy kryteria akceptacji to **liczby**, czy opisy w rodzaju „powinno policzyć poprawnie".
- Czy ryzyka wskazują **konkretne miejsca w kodzie**. Podpowiedź: zachowanie
  `app/raporty.py` przy fakturze walutowej.
- Czy sekcja „Otwarte pytania" **nie jest pusta**. Pusta oznacza, że model coś ukrył
  w regułach - to trzeba znaleźć.

Braki poprawia kolejny prompt albo `Ctrl+G` i ręczna edycja.

---

## Krok 5 - zatwierdzenie i commit

Zatwierdzić plan opcją z ręcznym zatwierdzaniem edycji - zapis pliku ma być widoczny.

```bash
git add specyfikacje/
git commit -m "Specyfikacja not odsetkowych"
```

---

## Kryteria zaliczenia

- [ ] Liczba rozstrzygnięć podjętych przez agenta w kroku 1 jest ustalona i zapisana.
- [ ] Specyfikacja ma co najmniej 6 kryteriów akceptacji wyrażonych **liczbami**.
- [ ] Sekcja „Zakres" wprost wymienia, czego **nie** robimy.
- [ ] Ryzyka wskazują pliki i linie, nie ogólniki.
- [ ] Sekcja „Otwarte pytania" nie jest pusta.
- [ ] Nie powstała ani jedna linia kodu produkcyjnego.

## Pułapki

**Wyjście z trybu planowania w połowie.** Agent edytujący `app/` oznacza plan zatwierdzony
za wcześnie. Ratunek: `git checkout -- app/` i powrót do planowania.

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
