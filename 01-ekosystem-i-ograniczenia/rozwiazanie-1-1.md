# Rozwiązanie wzorcowe - lab 1.1

> Do czytania dopiero po labie. Tu nie ma kodu do skopiowania - jest to, co powinno było się pokazać w labie.

---

## Krok 1 - pytanie o fakt

**Poprawna odpowiedź:** trzy progi, w `app/rabaty.py:9-13`:

```python
PROGI: list[tuple[Decimal, Decimal]] = [
    (Decimal("50000"), Decimal("0.10")),
    (Decimal("20000"), Decimal("0.07")),
    (Decimal("5000"), Decimal("0.03")),
]
```

Odpowiedź kompletna wspomina dodatkowo, że to nie jest cała historia rabatu:
`app/rabaty.py:46` dokłada rabat indywidualny kontrahenta ze słownika `RABAT_KONTRAHENTA`
(zdefiniowanego w liniach 15-19), a `app/rabaty.py:47-48` tnie sumę na `RABAT_MAKSYMALNY = 0.15`
(linia 21).

Odpowiedź, która podaje **tylko** linie 15-19 i 21, wskazuje definicje stałych zamiast miejsca,
w którym rabat jest naliczany. To jest ta sama klasa nieścisłości co zły numer linii - warto
ją wyłapać, bo w większym pliku prowadzi do szukania nie tam, gdzie trzeba.

**Czego się spodziewać:** Haiku zwykle znajduje progi i podaje plik z liniami.
Sonnet na `medium` częściej dopowiada kontekst (rabat indywidualny, limit). Oba trafiają.

**Wniosek do notatki:** na pytania o fakt, który da się zgrepować, **dopłata za mocniejszy model
nic nie daje**. Różnica ceny Haiku → Opus to pięciokrotność wejścia i pięciokrotność wyjścia
za tę samą odpowiedź.

Jeżeli odpowiedź nie zawierała numerów linii - to nie wina modelu. Nie było o nie prośby.

---

## Krok 2 - przynęta

**Funkcja `oblicz_odsetki` nie istnieje - i nie powstanie.** `grep -rn "oblicz_odsetki" app/`
nie zwraca nic w **żadnym** stanie repozytorium, łącznie z końcowym.

W labie 3.2 powstaje funkcjonalność odsetkowa - ale pod innymi nazwami:
`odsetki_za_opoznienie()` i `nota_odsetkowa()` w `app/odsetki.py`. Nazwa `oblicz_odsetki`
jest przynętą i nie pojawia się w repozytorium ani razu. To ma znaczenie w labie 3.2:
komenda weryfikacyjna woła `odsetki.odsetki_za_opoznienie(...)`, więc funkcja nazwana
tak, jak podpowiedział model w tym labie, kończy się `AttributeError`.

### Trzy warianty, trzy różne mechanizmy

| Wariant | Co zwykle wychodzi |
|---|---|
| **A** - bez narzędzi, z pamięci | **konfabulacja**: parametry `kwota`, `data_terminu`, `data_zaplaty`, wzór `kwota × stopa × dni / 365`. Sensowne, spójne, całe zmyślone |
| **B** - normalnie | model **grepuje repo** i odpowiada poprawnie: „nie ma takiej funkcji" |
| **C** - z wymuszeniem cytatu | „nie ma takiej funkcji" - powtarzalnie |

**Wariant B jest w tej wersji zwykle poprawny i to jest dobra wiadomość.** Agent z dostępem do plików
ma odruch sprawdzania. Gdyby lab został zaprojektowany wokół kontrastu B↔C, w 2026 nie
pokazywałby już niczego.

**Istota labu leży w wariancie A.** W **tonie** odpowiedzi A nie ma ani jednego sygnału
niepewności, bo model nie ma takiego sygnału do wystawienia. Brzmi dokładnie tak samo jak
odpowiedź sprawdzona.

### Dlaczego to nie jest sztuczny scenariusz

Wariant A pojawia się **za każdym razem**, gdy model nie ma dostępu do plików:

- w oknie czatu z wklejonym fragmentem kodu,
- w asystencie IDE bez kontekstu repozytorium,
- przy pytaniu o bibliotekę, a nie o kod projektu - tam grep nie pomoże,
- **i wtedy, gdy agent po prostu uzna, że sprawdzać nie musi.**

Ostatni punkt jest najważniejszy: w wariancie B to była **decyzja modelu, nie gwarancja
po stronie użytkownika**. Przy pytaniu sformułowanym odrobinę inaczej model przy kolejnym
uruchomieniu może zdecydować inaczej.

**Dlaczego wariant C działa.** „Wyjaśnij, jak działa X" zakłada istnienie X - model odpowiada
na pytanie, które dostał. „Znajdź X i zacytuj z numerem linii" zleca **czynność weryfikowalną**
i z góry opisuje, co zrobić przy pustym wyniku. Różnica nie jest w modelu, tylko w tym,
czy odpowiedź ma się o co zaczepić.

**Reguła na resztę kursu:**

> Twierdzenie o kodzie projektu bez cytatu z pliku i numeru linii jest hipotezą, nie odpowiedzią.

---

## Krok 3 - rozumowanie

**Poprawna odpowiedź:** rabat jest odejmowany **przed** naliczeniem VAT, per pozycja.
Ścieżka w `app/rozliczenia.py`:

| Linia | Co się dzieje |
|---|---|
| 50 | `netto_przed_rabatem += wartosc` - suma całej faktury, potrzebna do progu |
| 57-59 | stawka rabatu wyznaczana **raz dla faktury** (korekta: zero) |
| 85-86 | rabat pozycji, zaokrąglony do grosza |
| 88 | `netto_pozycji = zaokraglij(wartosc - rabat)` |
| 106 | `vat_pozycji = vat.vat_pozycji(netto_pozycji, kod_stawki)` - VAT od netto **po rabacie** |
| 107 | brutto = netto + VAT |

**Znaczenie kolejności.** To jest trudniejsze pytanie, niż wygląda - i dobry model
powinien to zauważyć.

1. **Na arytmetyce dokładnej, dla jednej stawki: NIE.** Procenty są przemienne:
   `(N − N·r) · (1+v)` = `N · (1+v) · (1−r)`. Brutto wychodzi identyczne.
2. **Merytorycznie: tak.** VAT liczy się od podstawy opodatkowania, czyli od kwoty po rabacie.
   Odwrotna kolejność byłaby błędna wobec przepisów, nawet gdy daje tę samą liczbę.
3. **Realnie kwotowo: tak, przez sprzężenie progowe.** Stawka rabatu (linia 59) czytana jest
   z kwoty **przed** VAT. Faktura na 4500 netto dostaje 0%. Gdyby próg czytano z brutto
   (5535), wpadłaby w 3%. To jest zmiana **nieliniowa**, nie grosz.
4. **Groszowo: czasem.** Dwa zaokrąglenia przed VAT-em (linie 86 i 88) dają różnicę grosza
   tylko przy niektórych kombinacjach - np. `10,05 × 7 szt.` albo `7,77 × 13 szt.` dają 0,01,
   a `33,33 × 3` nie daje nic.

Odpowiedź, która wymienia tylko punkt 2, jest poprawna, ale płytka. Odpowiedź, która wymienia
punkt 1 **i** 3, pokazuje, że model policzył, a nie zacytował regułę.

Dodatkowo `vat_wg_stawek` (linia 126) jest rekonstruowalne **wyłącznie** dzięki tej kolejności -
gdyby VAT liczono od sumy, rozbicia na stawki nie dałoby się odtworzyć.

**Czego się spodziewać po modelach:** kolejność rabat → VAT ustala poprawnie praktycznie
każda konfiguracja. Różnica pojawia się dopiero przy **asymetrii walutowej**, i ta faktycznie
wymaga dwóch plików:

| Gdzie | Co się dzieje |
|---|---|
| `app/rozliczenia.py:52-54` | próg rabatowy liczony jest na kwocie **przeliczonej na PLN** |
| `app/rabaty.py:52-55` | rabat naliczany jest od `pozycja.wartosc_netto` - **w walucie oryginalnej, bez kursu** |

Próg w złotówkach, rabat w euro. Liczba rozstrzygająca:

| Faktura | Rabat |
|---|---|
| netto **1500 PLN** | **0,00** - poniżej progu 5000 |
| netto **1500 EUR** | **45,00 EUR** (3%) - bo 1500 × 4,3120 = 6468 PLN przebija próg |

Ta sama liczba na dokumencie, inny rabat.

**Wniosek do notatki:** dopłata za mocniejszy model daje tu konkretną rzecz - zauważenie
zależności rozłożonej na dwa pliki. Samo przeliczanie kursem w `rozliczenia.py` jest widoczne
z jednego miejsca (pięć linii niżej jest użycie) i **nie liczy się** jako to znalezisko.

> **Dla prowadzącego:** jeżeli model wskaże `app/rozliczenia.py:143`
> (`brutto * kurs > PROG_DUZEJ_FAKTURY`) - to obserwacja tej samej klasy i należy ją uznać.

**Uwaga o weryfikacji:** twierdzenie Opusa, którego nie da się sprawdzić, nie jest powodem,
żeby w nie uwierzyć. Jest powodem, żeby poprosić o numer linii.

---

## Krok 4 - kontekst

Typowo po trzech krokach z czytaniem plików `/context` pokazuje kilkanaście procent okna.
Po `/clear` zostaje sam prompt systemowy, definicje narzędzi i pliki kontekstowe projektu
(w stanie startowym nie ma jeszcze `CLAUDE.md` - powstaje w module 2).

Ważniejsze od liczby jest to, **co** zajmuje miejsce. `/context` rozbija to na kategorie.
Temat wraca w labie 2.1 z pomiarem, a w labie 7.1 z kosztami.

---

## Wzorcowa notatka

```markdown
# Model-to-Task - obserwacje z labu 1.1

| Zadanie | Model | Effort | Wynik | Uwaga |
|---|---|---|---|---|
| Fakt: progi rabatowe | haiku | - | poprawnie, z plikiem i liniami | ~3 s; Haiku nie obsługuje effortu |
| Fakt: progi rabatowe | sonnet | (bez zmian) | to samo + rabat indywidualny i limit | wielokrotnie drożej za tę samą treść |
| Fakt: progi rabatowe | sonnet | low | to samo, krócej | pytanie faktograficzne nie potrzebuje rozumowania |
| Fakt: progi rabatowe | sonnet | high | to samo, dłużej | tu `high` nie kupuje niczego |
| oblicz_odsetki A - bez narzędzi | sonnet | (bez zmian) | **zmyślona funkcja**, opis brzmiał wiarygodnie | ton bez cienia wahania |
| oblicz_odsetki B - normalnie | sonnet | (bez zmian) | zgrepował repo, odpowiedział, że nie ma | narzędzia same zamykają temat |
| oblicz_odsetki C - z cytatem | sonnet | (bez zmian) | „nie ma takiej funkcji" | działa też tam, gdzie narzędzi nie ma |
| Rozumowanie: kolejność rabat/VAT | sonnet | medium | poprawnie: rabat przed VAT | nie zauważył kursu walut |
| Rozumowanie: kolejność rabat/VAT | opus | high | poprawnie + próg walutowy liczony po przeliczeniu kursem | to była realna różnica |

## Kontekst
- przed /clear: 14%
- po /clear: 4%

## Moja reguła doboru
Haiku/low do pytań, które sam zgrepowałbym w 10 sekund. Opus/high, gdy odpowiedź zależy
od dwóch miejsc w kodzie naraz. Zawsze żądam pliku i linii.
```

---

## Najczęstsze potknięcia

**Przełączenie modelu bez `/clear` i wniosek, że „drugi model był lepszy".** Drugi model widział
też odpowiedź pierwszego. W tym labie jest to celowe (porównanie odbywa się w tych samych
warunkach), ale przy realnym porównaniu trzeba czyścić kontekst między próbami.

**Uznanie rzeczowego tonu za dowód.** W kroku 2 wariant A i wariant C brzmią tak samo
pewnie - jeden jest zmyślony, drugi sprawdzony. Różni je nie ton, tylko to,
czy odpowiedź ma punkt zaczepienia w pliku.

**Pominięcie kroku 4.** `/context` jest narzędziem używanym przez cały drugi kurs.
Pierwszy kontakt z nim dopiero w module 7 jest za późny.
