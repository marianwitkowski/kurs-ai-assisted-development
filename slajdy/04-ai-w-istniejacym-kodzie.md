---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 4'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# AI w istniejącym kodzie

## Moduł 4 · dzień 1

Odtwarzanie intencji · reguła czy błąd · testy zabezpieczające · migracje

<!--
CO POWIEDZIEĆ: Pisząc nowy kod, agent ma jedno ograniczenie: waszą specyfikację.
W istniejącym kodzie ma drugie, twardsze. Cel modułu: wyciągnąć z legacy to, czego nikt
nie zapisał, odróżnić regułę biznesową od błędu i nie dać agentowi „uprościć" żadnego z nich.
CZAS: ~1 min
-->

---

# Legacy ma drugie ograniczenie

Nowy kod ogranicza tylko twoja specyfikacja.
Istniejący dodatkowo: **wszystko, co już działa i na czym ktoś polega.**

- **Kod niesie decyzje, których nie widać.** Dziwny warunek to pomyłka sprzed trzech lat
  albo wynik spotkania z działem prawnym. Z kodu tego nie odróżnisz.
- **Nie ma sieci bezpieczeństwa.** Testów brakuje dokładnie tam, gdzie są najważniejsze.
- **Agent jest wytrenowany na tym, jak kod wygląda „ładnie".** Spłaszczy zagnieżdżonego ifa,
  zostawi jedno zaokrąglenie z dwóch.

<!--
CO POWIEDZIEĆ: Każda z tych zmian jest sensowna w oderwaniu od kontekstu i każda może
kosztować pieniądze. Agent nie jest złośliwy, jest wytrenowany na kodzie z podręczników,
a nie na waszej funkcji fakturującej.
NA CO UWAŻAĆ: Sala lubi tu zgłaszać „u nas jest tak samo, ale my znamy ten kod".
Odpowiedź jest nicią przewodnią kursu: artefakt w repozytorium bije wiedzę w głowie.
CZAS: ~3 min
-->

---

<!-- _class: haslo -->

## „Czy to można uprościć?"
## **Nie wiem, dopóki nie mam testu, który to utrwala.**

Domyślna odpowiedź w istniejącym kodzie. Zasada całego modułu.

<!--
CO POWIEDZIEĆ: To jedno zdanie streszcza cały moduł. Nie „nie ruszaj legacy", tylko
„najpierw test, potem zmiana". Kolejność, nie zakaz.
CZAS: ~1 min
-->

---

<!-- _class: gesta -->

# Agent inwentaryzuje, ty oceniasz

| Dobrze znajduje | Słabo ocenia |
|---|---|
| długie funkcje, głębokie zagnieżdżenia | czy długość jest uzasadniona |
| duplikację kodu | czy to duplikacja, czy przypadkowe podobieństwo |
| przestarzałe API (`datetime.utcnow()`) | które wywołanie jest krytyczne |
| sklejanie SQL-a ze stringów | czy dane wejściowe są już zwalidowane |
| martwy kod | czy naprawdę martwy, czy wołany dynamicznie |
| brakującą obsługę błędów | czy brak jest celowy |

**Inwentaryzację zlecasz. Ocenę zostawiasz sobie** - agent nie zna ani twojego biznesu,
ani twojego kalendarza.

<!--
CO POWIEDZIEĆ: Praktyczny wniosek jest jeden: każ agentowi zrobić inwentaryzację,
ocenę zostaw sobie. W prompcie z labu 4.1 zakazujemy wprost proponowania poprawek
i oceniania ważności.
NA CO UWAŻAĆ: Kolumna „priorytet: wysoki/średni/niski" w odpowiedzi oznacza, że model
ocenił za was, nie znając ani waszego biznesu, ani waszego kalendarza.
PYTANIE Z SALI: „Po co sprawdzać numery linii?" Bo halucynacja w numerze linii oznacza,
że model nie czytał, tylko pamiętał. Wtedy cała lista jest podejrzana. Trzy komendy `sed`
to najtańsza weryfikacja w całym kursie.
CZAS: ~3 min
-->

---

# Trzy pytania i jedna odpowiedź, która przesądza

| Pytanie | Możliwe odpowiedzi |
|---|---|
| 1. Co się stanie, jeśli tego **nie ruszę**? | nic / rośnie dług / awaria / **strata pieniędzy** |
| 2. Co się stanie, jeśli **ruszę i się pomylę**? | nic / test złapie / **produkcja** |
| 3. **Czym sprawdzę**, że nie zepsułem? | testy / ręcznie / **nijak** |

> Pozycja z odpowiedzią „nijak" na pytanie 3 **nie nadaje się do naprawy**.
> Nadaje się do napisania testu.

W repozytorium ćwiczeniowym „nijak" mają cztery pozycje.

<!--
CO POWIEDZIEĆ: To jest cała kolejność pracy w legacy, w trzech pytaniach. Ocena ryzyka
to zdanie, które da się sfalsyfikować, a nie „zalecam refaktoryzację, bo funkcja jest
za długa" - to drugie jest prawdziwe dla 90% kodu na świecie.
PYTANIE Z SALI: „Które cztery pozycje?" SQL Injection, brak autoryzacji, funkcja-moloch
i raport przeterminowanych. Dwie pierwsze wracają w module 8, trzecia to lab 4.2.
CZAS: ~2 min
-->

---

# Pytaj o zachowanie, nie o kod

<div class="kolumny">
  <div>
    <div class="krok zly">
      <strong>Opis kodu</strong>
      <small>„Funkcja iteruje po pozycjach i sumuje wartości."</small>
    </div>
    <p><em>Przepisany kod prozą. Nikt tego nie potwierdzi i nikt z tego nie zrobi testu.</em></p>
  </div>
  <div>
    <div class="krok dobry">
      <strong>JEŻELI... TO...</strong>
      <small>„JEŻELI pozycja ma cenę promocyjną, TO nie dostaje rabatu progowego, ale jej wartość i tak wlicza się do progu całej faktury."</small>
    </div>
    <p><em>Reguła. Da się ją potwierdzić u biznesu i zamienić w test.</em></p>
  </div>
</div>

Drugie pytanie: **które zachowania zaskoczyłyby programistę, który zna domenę
fakturowania, ale nie zna tego kodu?**

<!--
CO POWIEDZIEĆ: To jest najważniejsza umiejętność tego modułu. Pytamy o zachowanie
obserwowalne z zewnątrz, z numerem linii przy każdej regule. Pytanie o zaskoczenia
wydobywa dokładnie te miejsca, w których siedzi nieudokumentowana decyzja - kod nudny
nikogo nie zaskakuje.
NA CO UWAŻAĆ: Jeśli w labie 4.2 wyjdzie „funkcja waliduje dane wejściowe, następnie
oblicza sumę netto", to jest przepisany kod. Powtórzyć prompt, podkreślając formę
„JEŻELI... TO...".
CZAS: ~3 min
-->

---

# Reguła biznesowa czy błąd

|  | Reguła biznesowa | Błąd |
|---|---|---|
| Kod robi | to, co ktoś zdecydował | to, czego nikt nie chciał |
| „Uproszczenie" | **strata pieniędzy albo zgodności** | poprawa |
| Test charakterystyki | utrwala **na stałe** | utrwala **tymczasowo**, z komentarzem |
| Zmiana wymaga | decyzji biznesu | poprawki |
| Kto rozstrzyga | człowiek znający domenę | programista |

> Reguła biznesowa w legacy wygląda **dokładnie** jak błąd. To jej cecha definicyjna:
> gdyby wyglądała sensownie, nie byłoby problemu.

<!--
CO POWIEDZIEĆ: Ten sam kawałek kodu może być jednym albo drugim, a konsekwencje pomyłki
są odwrotne. Czego nie wolno: rozstrzygać po wyglądzie kodu. Co robić: utrwalić oba
przypadki testem, opisać różnicę w komentarzu, zapytać człowieka o resztę.
NA CO UWAŻAĆ: Przy klasyfikacji żądamy od agenta dowodu z repozytorium. Bez tego zdania
dostaniecie stanowcze „to jest celowa reguła" bez cienia dowodu - dokładnie jak w labie 2.1.
PYTANIE Z SALI: „Po co utrwalać testem coś, co uważam za błąd?" Bo test utrwalający błąd
jest niewygodny i ktoś go w końcu zakwestionuje świadomie, zamiast „poprawić" przy okazji.
Odpowiedź „nie da się rozstrzygnąć z kodu" też jest wartościowa: to lista pytań do człowieka.
CZAS: ~3 min
-->

---

# Jeden `if`, dwa przypadki, różnica 54 zł

```python
# app/rabaty.py:52-55
if pozycja.cena_promocyjna is not None:
    return Decimal("0")
```

| Ta sama pozycja | Cena | Rabat | Netto faktury |
|---|---|---|---|
| promocja **aktywna** | 1 440,00 (promocyjna) | 0,00 | 8 715,00 |
| promocja **wygasła** | 1 800,00 (pełna) | 0,00 | **9 075,00** |
| **brak pola** `cena_promocyjna` | 1 800,00 (pełna) | 54,00 | **9 021,00** |

Warunek sprawdza, czy **pole jest ustawione** - nie czy promocja obowiązuje.
Przypadek pierwszy to reguła. Drugi to błąd.

<!--
CO POWIEDZIEĆ: To jest sedno modułu na jednym slajdzie. Rabat nie łączy się z promocją -
to celowa reguła. Ale gdy promocja wygasła, klient płaci pełną cenę i mimo to traci rabat
progowy, który mu się należy. Nikt tego nie chciał. Jeden warunek, dwa przypadki,
przeciwne oceny - dlatego nie da się tego rozstrzygnąć, patrząc na kod.
NA CO UWAŻAĆ: Pojedynczy test niczego nie pokazuje. Dopiero para sąsiadujących testów
- wygasła promocja obok tej samej pozycji bez pola - pokazuje 54 zł różnicy.
To jest ten jeden test w labie 4.2, który jest wart całego labu.
CZAS: ~4 min
-->

---

# Kolejność, od której nie ma odstępstw

<div class="przeplyw">
  <div class="krok">Zrozum zachowanie<small>JEŻELI... TO...</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Testy na stan TERAZ<small>wartości z uruchomienia</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Zielone na NIEZMIENIONYM kodzie<small>krok pomijany</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Refaktor<small>testy zielone bez zmian w testach</small></div>
</div>

> Jeśli test od razu nie przechodzi, to **nie jest** test charakterystyki. To test twojego
> wyobrażenia o tym kodzie.

Zmiana zachowania dopiero po tym wszystkim - i **nigdy** w commicie refaktoryzacji.

<!--
CO POWIEDZIEĆ: Test charakterystyki nie mówi „tak ma być". Mówi „tak jest dzisiaj i jeśli
to zmieniasz, rób to świadomie". Dlatego wartości oczekiwane wyliczamy, uruchamiając
funkcję, a nie z własnych obliczeń.
NA CO UWAŻAĆ: Trzeci krok wszyscy pomijają. W labie 4.2 kryterium zaliczenia brzmi:
`git diff app/` musi być puste. Jeśli agent „poprawił" kod, żeby test przeszedł, macie
test sprawdzający kod, który sam przed chwilą napisał.
PYTANIE Z SALI: „Test liczący `wynik.vat == wynik.netto * Decimal('0.23')` jest OK?"
Nie. Powtarza logikę produkcyjną, więc powtórzy też błąd w zaokrąglaniu i będzie zielony
zawsze. Utrwalona liczba nie ma tej wady.
CZAS: ~3 min
-->

---

# Cztery poziomy obrony przed „uproszczeniem"

<div class="drabina">
  <div class="stopien"><span class="nr">1</span> Prompt: „nie zmieniaj żadnego zachowania" <span class="cena">prośba</span></div>
  <div class="stopien"><span class="nr">2</span> Zapis w <code>CLAUDE.md</code> (moduł 2) <span class="cena">prośba</span></div>
  <div class="stopien"><span class="nr">3</span> Testy charakterystyki <span class="cena">fakt</span></div>
  <div class="stopien"><span class="nr">4</span> Hook uruchamiający testy (moduł 5) <span class="cena">fakt</span></div>
</div>

Pierwsze dwa poziomy zależą od tego, czy model posłuchał. Dwa ostatnie nie.
**Prośby działają w większości przypadków. Fakty działają zawsze.**

<!--
CO POWIEDZIEĆ: To jest nić przewodnia całego kursu w wersji na legacy. Zasada
w `CLAUDE.md` z modułu 2 to prośba. Test, który wywala się na zmienionej kwocie,
to fakt. W module 5 dokładamy hook, którego model nie może pominąć.
NA CO UWAŻAĆ: To nie jest wybór jednego poziomu, tylko dokładanie kolejnych.
Prompt i `CLAUDE.md` nadal mają sens: prośby działają w większości przypadków.
CZAS: ~3 min
-->

---

# Zdania, po których zaglądasz w diff

> „Uprościłem też..." · „Przy okazji poprawiłem..." · „Ten warunek wydawał się zbędny..."
> · „Ujednoliciłem zaokrąglanie..." · „To wyglądało na pomyłkę, więc..."

Każde z nich oznacza **zmianę zachowania zgłoszoną jako porządki**.

Czytaj, co agent pisze w wiadomościach, nie tylko to, co zostawił w kodzie.

<!--
CO POWIEDZIEĆ: Te zdania padają w wiadomościach agenta, a nie w diffie, i łatwo je
przewinąć. W labie 4.3 każde z nich jest sygnałem do natychmiastowego `git diff`.
NA CO UWAŻAĆ: Jeśli agent zaproponuje poprawkę znanego błędu osobno i nie zastosuje jej -
to jest zachowanie wzorcowe. Propozycja idzie do backlogu z wyliczoną różnicą 54 zł.
CZAS: ~2 min
-->

---

<!-- _class: gesta -->

# Zielone testy to warunek konieczny

| Co agent proponuje przy refaktoryzacji | Testy | Różnice na 204 fakturach |
|---|---|---|
| „Zaokrąglenie VAT lepiej zrobić raz, od sumy" | 31/32 | 9 |
| „Próg rabatowy bez przeliczania kursem" | 31/32 | 20 |
| „Rabat można liczyć per pozycja, to prostsze" | 30/32 | 105 |
| „Policzę rabat wprost" (naprawia znany błąd) | 31/32 | 25 |
| **„`zaliczka > 0` jest zbędne, wystarczy `zaliczka > brutto`"** | **32/32** | **4** |

Korekta ma **ujemne** brutto: bez guardu `0 > -5400` jest prawdziwe, `do_zaplaty` spada
z -5400,00 do 0,00. Łapie to wyłącznie porównanie wyników na całej bazie.

<!--
CO POWIEDZIEĆ: 32 testy pokrywają to, co ktoś wymyślił. 204 faktury pokrywają to,
co jest w danych. Ostatni wiersz jest najważniejszy: wszystkie testy zielone,
a cztery faktury policzone inaczej.
NA CO UWAŻAĆ: Test charakterystyki chroni to, co sprawdza. Nie sprawdza liczby wystąpień
ostrzeżenia, więc tego nie chroni - po refaktoryzacji ostrzeżenie o wygasłej promocji
potrafi się zdublować przy zielonych testach.
PYTANIE Z SALI: „Jak porównać wyniki przed i po?" `git stash`, zapis wyników do pliku,
`git stash pop`, drugi zapis, `diff`. Krok 4 labu 4.3 ma gotową komendę.
CZAS: ~3 min
-->

---

# „Mechaniczna" migracja prawie nigdy nie jest mechaniczna

| Wystąpienie `datetime.utcnow()` | Kontekst | Klasyfikacja |
|---|---|---|
| `app/raporty.py:48` | domyślna wartość `na_dzien` | mechaniczne |
| `app/raporty.py:80` | domyślna wartość `na_dzien` | mechaniczne |
| `app/powiadomienia.py:53` | domyślna wartość `na_dzien` | mechaniczne |
| `app/platnosci.py:32` | domyślna data wpłaty | mechaniczne |
| `app/rabaty.py:29` | **decyzja o cenie pozycji na fakturze** | wymaga decyzji |

**Pięć wystąpień w czterech plikach.** Agent, który wypisze cztery, przejrzał pliki,
a nie wystąpienia. `utcnow()` zwraca obiekt bez strefy, `now(UTC)` - ze strefą.

<!--
CO POWIEDZIEĆ: Migracja to zadanie, w którym agent jest wyjątkowo przydatny, pod warunkiem
że nie planuje jej sam. Zlecamy inwentaryzację, klasyfikację i zmiany mechaniczne partiami.
Nie zlecamy decyzji, czy migrować, ani wyboru wersji docelowej.
NA CO UWAŻAĆ: `app/rabaty.py:29` to nie jest przypadek na zamianę wywołania. Tam właściwą
poprawką jest wstrzyknięcie daty jako parametru, czyli zmiana sygnatury, czyli zmiana
zachowania - osobne wdrożenie. Przez tę jedną linię przeliczenie faktury zależy od zegara
i nie da się napisać stabilnego testu bez szerokiego okna promocji.
CZAS: ~2 min
-->

---

<!-- _class: lab -->

# Laby: od mapy ryzyka do refaktoryzacji

**4.1 Mapa ryzyka i plan migracji** (~25 min, tag `lab-4-1-start`)
Inwentaryzacja od agenta, ocena ryzyka od ciebie. Produkt: `docs/mapa-ryzyka.md`.

**4.2 Odtworzenie intencji i testy zabezpieczające** (~35 min, tag `lab-4-2-start`)
Reguły „JEŻELI... TO...", klasyfikacja z dowodem, para testów z różnicą 54 zł.

**4.3 Refaktoryzacja pod ochroną testów** (~30 min, tag `lab-4-3-start`)
`oblicz_fakture()` ze 157 linii do 57, zero groszy różnicy na 204 fakturach.

Niezacommitowana praca zablokuje skok na tag: `git stash push -u -m "moje-3-2"`.

<!--
CO POWIEDZIEĆ: Trzy laby na jednej funkcji, po kolei: mapa ryzyka, testy, refaktoryzacja.
Lab 4.2 jest tym, którego nie tniemy - stoją na nim 4.3 i 5.1.
NA CO UWAŻAĆ: `git checkout` blokują też pliki nieśledzone, więc `git stash push -u`,
nie samo `git stash`. `git switch -c` tu nie pomoże - nie commituje, więc nie odblokowuje
skoku na tag.
CZAS: ~1 min
-->
