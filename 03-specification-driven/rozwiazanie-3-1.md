# Rozwiązanie wzorcowe - lab 3.1

Gotowa specyfikacja jest w repozytorium:

```bash
git show lab-3-2-start:specyfikacje/noty-odsetkowe.md
```

---

## Krok 1 - ile decyzji podjął agent

Typowa odpowiedź na gołe wymaganie zawiera **od sześciu do dziewięciu milczących rozstrzygnięć**.
Najczęstsze:

| Rozstrzygnięcie | Co model zwykle przyjmuje | Dlaczego to nie jest oczywiste |
|---|---|---|
| Stopa odsetek | jedna, na sztywno, często „ustawowe" bez wartości | jest ich kilka rodzajów, zmieniają się w czasie |
| Pierwszy dzień | dzień po terminie | bywa: od terminu, od doręczenia, od wezwania |
| Podstawa | brutto z faktury | w repo podstawa to `do_zaplaty`, czyli kwota po odliczeniu zaliczki |
| Rok bazowy | 365 | bywa 360 (umowy) albo 366 w latach przestępnych |
| Wpłaty częściowe | **pomijane** | w repo jest `app/platnosci.py` z wpłatami |
| Korekty | **pomijane** | w repo jest `app/korekty.py` |
| Waluty | liczone tak samo | `app/konfiguracja.py` ma kursy, faktury w EUR i USD są w bazie |
| Próg minimalny | nie istnieje | koszt obsługi noty na 80 groszy przewyższa kwotę |
| Zaokrąglanie | domyślne Pythona | `ROUND_HALF_UP` do grosza, i tylko na końcu |

**Dwa pominięcia dotyczą modułów, które są w tym repo.** Agent nie musiał
ich zgadywać - musiał je zauważyć. Nie zauważył, bo nikt nie kazał mu szukać.

**To jest wynik kroku 1:** zapisana liczba. Wynik poniżej sześciu wymaga porównania
z listą powyżej - część rozstrzygnięć bywa tak cicha, że przechodzi niezauważona.
To jest dokładnie ten problem.

---

## Krok 2 - czym różni się lista pytań

Ten sam model, to samo repo, inne polecenie. Zamiast propozycji przychodzi 8-15 pytań,
zwykle z odniesieniami do kodu:

> - Od jakiej podstawy liczyć - `Rozliczenie.brutto` czy `Rozliczenie.do_zaplaty`
>   (`app/modele.py:73-75`)?
> - Czy wpłaty z `app/platnosci.py` obniżają podstawę? `rozksieguj()` (`app/platnosci.py:65`)
>   rozlicza je FIFO na poziomie kontrahenta, nie faktury.
> - Co z fakturami w EUR i USD? `app/konfiguracja.py:13-18` ma kursy, ale aktualizowane ręcznie.
> - Czy faktury ze statusem `korekta` mają być pomijane?
> - `raporty.przeterminowane()` (`app/raporty.py:47-66`) już liczy dni po terminie - czy nowa
>   funkcja ma z niego korzystać, czy być niezależna?

**Zmieniło się jedno słowo w prompcie** - „wypisz pytania" zamiast „powiedz, jak
zaimplementujesz" - i osiem milczących decyzji stało się widocznych.

To jest najtańsza technika w całym kursie. Nie wymaga trybu planowania, specyfikacji ani
narzędzi. Wymaga tylko tego, żeby o nią poprosić.

---

## Krok 4 - co odróżnia dobrą specyfikację od ładnej

### Kryteria akceptacji muszą być liczbami

| Źle | Dobrze |
|---|---|
| „Odsetki powinny być poprawnie naliczone za okres opóźnienia" | „podstawa 10 000,00; termin 2026-01-10; rozliczenie 2026-02-10 → **123,15 zł**" |
| „Powinien obsługiwać wpłaty częściowe" | „wpłata 4 000,00 dnia 2026-01-26 → **97,73 zł** (15 dni od 10 000 + 16 dni od 6 000)" |
| „Małe kwoty pomijamy" | „2 520,00 przez 10 dni → 10,01 zł, nota jest; 2 515,00 przez 10 dni → 9,99 zł, noty nie ma" |

Lewa kolumna nie daje się zamienić w test. Prawa zamienia się w test jeden do jednego.

### Pary graniczne

A7 i A8 we wzorcowej specyfikacji to jedna reguła sprawdzona **z obu stron progu**:
10,01 zł (nota jest) i 9,99 zł (noty nie ma). Sześć przypadków „normalnych" nie wykryje
błędu w warunku `>=` kontra `>`. Jedna para graniczna wykryje.

A9 sprawdza rok przestępny: 366 dni podzielone przez stałe 365 daje **1 453,97 zł**,
czyli więcej niż 14,5% od 10 000 zł. To wygląda na błąd i **nie jest błędem** -
tak działa reguła R5. Bez tego przypadku ktoś „poprawi" to za pół roku.

### Ryzyka wskazują linie

| Ogólnik | Konkret |
|---|---|
| „może być problem z walutami" | „faktury walutowe przechodzą przez `rozlicz_fakture_z_bazy()` bez ostrzeżenia - `app/rozliczenia.py:52-54` przelicza bazę rabatu kursem, ale kwota wynikowa jest w walucie faktury" |
| „trzeba uważać na duplikację" | „`raporty.przeterminowane()` (`app/raporty.py:47-66`) już liczy dni po terminie własnym kodem - powstałyby dwa źródła prawdy" |

### Sekcja „Otwarte pytania" nie może być pusta

We wzorcowej specyfikacji jest ich pięć. Najważniejsze:

> **Czy stopa 14,5% obowiązuje przez cały okres opóźnienia?** Odsetki ustawowe zmieniają się
> w czasie. W tej iteracji przyjmujemy jedną stałą stopę. Przy dłuższych opóźnieniach
> wynik będzie się różnił od prawidłowego.

To jest **znany, zapisany, świadomie zaakceptowany błąd**. Różnica między nim a błędem
z dopowiedzenia jest cała: ten jest w dokumencie, przeszedł przez czyjeś oczy i ma termin.

Pusta sekcja „Otwarte pytania" oznacza, że model przeniósł niepewność do sekcji
„Reguły obliczeniowe", gdzie wygląda na ustaloną. Reguły wymagają wtedy ponownego
przeczytania i wyłowienia tych, których nikt nie potwierdził.

---

## Sekcja, którą najłatwiej pominąć

```markdown
**Świadomie nie robimy w tej iteracji:**
- faktur walutowych - zwracamy jawny błąd zamiast liczyć,
- faktur korygujących,
- zapisu not do bazy,
- wysyłki, generowania PDF-ów, numeracji not,
- zmiennej stopy w czasie,
- jakiejkolwiek zmiany w app/rozliczenia.py i oblicz_fakture().
```

Sześć linii, które w labie 3.2 oszczędzają pół godziny czytania diffa.
Bez nich agent doda numerację not, bo „nota musi mieć numer", i zapis do bazy,
bo „przecież trzeba to gdzieś trzymać".

**Zakres negatywny jest ważniejszy od pozytywnego.** To, co ma powstać, wynika z wymagania.
To, co ma nie powstać, nie wynika z niczego - musi być napisane.

---

## Najczęstsze potknięcia

**Zatwierdzenie planu w kroku 2.** Wtedy agent zaczyna pisać kod, a lab się kończy.
`Shift+Tab` zamiast zatwierdzania.

**Pominięcie kroku 1.** Bez pomiaru „bez specyfikacji" reszta labu wygląda na biurokrację.
Cała wartość leży w porównaniu.

**Specyfikacja opisująca implementację.** Jeśli w sekcji „Reguły obliczeniowe" pojawiają się
nazwy funkcji i pętle - to nie jest specyfikacja, tylko plan zapisany nie tam, gdzie trzeba.
Reguły mówią **co ma być prawdą**, plan mówi **jak to osiągnąć**.

**Przyjęcie liczb od modelu bez sprawdzenia.** Wartości w kryteriach akceptacji można
policzyć w trzy linijki Pythona. Niesprawdzona wartość 123,45 zamiast 123,15 utrwala
halucynację jako kryterium akceptacji - a test napisany do niej będzie „przechodził"
na złym kodzie.
