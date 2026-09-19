---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 3'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Specification-Driven Development

## Moduł 3 · Dzień 1

Tryb planowania · techniki przeciw dopowiadaniu · pełny cykl
od wymagania do review

<!--
CO POWIEDZIEĆ: Moduł 2 był o tym, co agent wie o projekcie. Ten moduł jest o tym,
co agent zrobi, gdy czegoś nie wie. Odpowiedź brzmi: zgadnie, i nie powie, że zgadł.
Cały moduł to jedno pytanie - jak zamienić milczące rozstrzygnięcia w widoczne.
CZAS: ~1 min
-->

---

<!-- _class: haslo -->

## Jeśli specyfikacja nie rozstrzyga, rozstrzygnie statystyka.

Model zawsze produkuje najbardziej prawdopodobną kontynuację.

<!--
CO POWIEDZIEĆ: Agent dostaje lukę i wypełnia ją tym, co najczęściej występowało w kodzie,
na którym się uczył. Nie tym, co jest prawdą w tym projekcie. To nie jest wada do naprawienia
lepszym modelem - to jest właściwość mechanizmu.
PYTANIE Z SALI: „Czy mocniejszy model to naprawi?" Nie. To nie jest wada do naprawienia
lepszym modelem, tylko właściwość mechanizmu: model zawsze produkuje najbardziej
prawdopodobną kontynuację.
CZAS: ~2 min
-->

---

# Kolega kontra agent

| Człowiek, któremu dajesz zadanie | Agent |
|---|---|
| Zna kontekst biznesowy, wie, których klientów to dotyczy | Nie wie, których klientów to dotyczy |
| **Przyjdzie zapytać**, gdy coś jest niejasne | Wypełnia lukę i idzie dalej |
| Zawaha się, gdy czuje, że robi coś ryzykownego | Nie zawaha się |
| Ma opinię i powie ci, że pomysł jest zły | Nie powie ci, że pomysł jest zły |

Kiedy przekazujesz zadanie człowiekowi, **zostawiasz luki celowo.**

<!--
CO POWIEDZIEĆ: „Dodaj noty odsetkowe za przeterminowane faktury" wystarczy koledze, bo kolega
robi cztery rzeczy z lewej kolumny. Agent nie robi żadnej z nich. Ta sama prośba, inny odbiorca,
inny wynik.
NA CO UWAŻAĆ: Sala zwykle słyszy „trzeba pisać lepsze prompty". Nie o to chodzi. Chodzi o to,
że brak pytania ze strony agenta nie oznacza, że wszystko było jasne.
CZAS: ~2 min
-->

---

<!-- _class: gesta -->

# Jedno zdanie, osiem rozstrzygnięć

*„Dodaj naliczanie odsetek za przeterminowane faktury."*

| Luka | Co agent najpewniej założy | Co może być prawdą u ciebie |
|---|---|---|
| Stopa odsetek | ustawowa, jedna, na sztywno | różna dla umów, zmienna w czasie |
| Od kiedy liczyć | od dnia po terminie | od terminu, od doręczenia, od wezwania |
| Podstawa naliczania | kwota brutto | netto albo po odliczeniu wpłat |
| Rok bazowy | 365 dni | 365, 366 albo 360 zależnie od umowy |
| Zaokrąglanie | na końcu | po każdym dniu, do grosza, w dół |
| Faktury walutowe | tak samo jak złotówkowe | przewalutowanie po kursie z dnia zapłaty |
| Korekty | pominie temat | zmniejszają podstawę wstecz |
| Częściowe wpłaty | pominie temat | zmniejszają podstawę od dnia wpłaty |

<!--
CO POWIEDZIEĆ: Osiem rozstrzygnięć, o które nikt nie zapytał. Kod powstanie, testy napisane
do tego samego założenia przejdą, review nie zauważy - bo review sprawdza, czy kod robi to,
co mówi, a nie czy „to" jest właściwe.
NA CO UWAŻAĆ: Dwa ostatnie wiersze dotyczą modułów, które są w repozytorium ćwiczeniowym:
`app/platnosci.py` i `app/korekty.py`. Agent nie musiał ich zgadywać, musiał je zauważyć.
Nie zauważył, bo nikt nie kazał mu szukać.
PYTANIE Z SALI: „Skąd model weźmie stopę?" Zwykle napisze „ustawowe" bez podania wartości
albo wpisze jedną liczbę na sztywno. Obie odpowiedzi wyglądają rozsądnie i obie są zgadywaniem.
CZAS: ~4 min
-->

---

# Groźniejsze jest to, co działa

<div class="rozgalezienie">
  <div class="galaz tak">
    <span class="etykieta">Halucynacja</span>
    Kod woła coś, czego nie ma.<br>
    <strong>Wywala się.</strong> Test czerwony, widzisz ją od razu.
  </div>
  <div class="galaz nie">
    <span class="etykieta">Błędne założenie</span>
    365 zamiast 360, brutto zamiast netto.<br>
    <strong>Działa.</strong> Testy przejdą, review nie zauważy.
  </div>
</div>

Review sprawdza, czy kod robi to, co mówi - a nie czy „to" jest właściwe.

<!--
CO POWIEDZIEĆ: Odwrotnie niż podpowiada intuicja. Halucynacji boi się cała branża,
a to ona jest łatwa - sama się zgłasza. Błędne założenie przechodzi przez każdą bramkę,
którą masz, bo każda z nich sprawdza spójność, a nie prawdziwość.
NA CO UWAŻAĆ: Testy nie ratują, jeśli powstały z tego samego założenia co kod. To jest dokładnie
pułapka, którą rozbieramy przy kryteriach akceptacji.
CZAS: ~2 min
-->

---

# Tryb planowania

Agent czyta pliki, uruchamia komendy eksploracyjne i pisze plan.
**Edycje są zablokowane, dopóki nie zatwierdzisz planu.**

Rozdziela dwie czynności, które inaczej zlewają się w jedną:
**ustalenie, co zrobić** i **zrobienie tego**.

> **Na planach Pro, Max i Team sesja startuje w trybie auto**, w którym działania ocenia
> klasyfikator, a nie ty. Naciskaj `Shift+Tab`, aż pasek statusu pokaże `⏸ plan mode on`.

`⏸ manual mode on` · `⏵⏵ accept edits on` · `⏸ plan mode on` · `⏵⏵ auto mode on`

<!--
CO POWIEDZIEĆ: Wejścia są cztery: `Shift+Tab` w trakcie sesji, `/plan` w trakcie sesji (`/plan open` pokazuje plan),
`claude --permission-mode plan` na całą sesję i `defaultMode` w `.claude/settings.json`
na cały projekt. Wszystkie cztery są na ściądze, nie przepisuj ich z ekranu.
NA CO UWAŻAĆ: Najczęstsza wpadka w labie 3.1 to zatwierdzenie planu w kroku 2 - wtedy agent
zaczyna pisać kod i lab się kończy. Wyjście bez zatwierdzania to `Shift+Tab` jeszcze raz.
PYTANIE Z SALI: „Ile razy nacisnąć `Shift+Tab`?" Nie licz naciśnięć. Kolejność w cyklu zależy
od wersji i od tego, które tryby opcjonalne są dostępne. Pasek statusu jest jedynym pewnym źródłem.
CZAS: ~3 min
-->

---

# Plan wart zatwierdzenia

1. **Co ustalono z kodu** - z plikami i numerami linii, czyli weryfikowalnie.
2. **Jakie założenia przyjęto** - wypisane wprost, każde osobno.
3. **Jakie są ryzyka** - co może się zepsuć poza obszarem zmiany.
4. **Jak to zweryfikujemy** - jakie testy, jakie przypadki brzegowe.

> Punkt drugi jest najważniejszy.
> **Założenia wypisane to założenia, które możesz odrzucić.** Milczące trafiają prosto do kodu.

<!--
CO POWIEDZIEĆ: Plan, który mówi „zrobię X, potem Y, potem Z", nie wnosi nic - to lista rzeczy,
które i tak by się wydarzyły. Żądaj tych czterech elementów, a z planu zrobi się dokument,
który da się odrzucić w pięć minut.
PYTANIE Z SALI: „Czy nie szybciej poprawić plan promptem?" Zwykle nie. `Ctrl+G` otwiera plan
w edytorze i szybciej jest skreślić trzy linie, niż tłumaczyć agentowi, dlaczego są złe.
CZAS: ~3 min
-->

---

# Cztery techniki przeciw dopowiadaniu

<div class="drabina">
  <div class="stopien"><span class="nr">1</span><span>Każ wypisać <strong>pytania</strong>, nie odpowiedzi. „Nie odpowiadaj na nie sam."</span><span class="cena">pytania na ekranie</span></div>
  <div class="stopien"><span class="nr">2</span><span>Każ oddzielić <strong>USTALONE</strong> (plik i linia) od <strong>ZAŁOŻONEGO</strong>.</span><span class="cena">lista założeń</span></div>
  <div class="stopien"><span class="nr">3</span><span>Podaj wprost <strong>zakres i granice</strong>. Co wolno tknąć, czego nie.</span><span class="cena">diff w zakresie</span></div>
  <div class="stopien"><span class="nr">4</span><span>Podaj <strong>kryteria akceptacji jako liczby</strong>: wejście → wynik.</span><span class="cena">gotowe testy</span></div>
</div>

Technika 1 jest najtańsza w całym kursie: zamienia osiem milczących rozstrzygnięć
w osiem pytań na ekranie.

<!--
CO POWIEDZIEĆ: Od najprostszej do najskuteczniejszej. Pierwsza nie wymaga trybu planowania,
specyfikacji ani narzędzi. Wymaga tylko tego, żeby o nią poprosić.
NA CO UWAŻAĆ: Przy technice 2 dopowiedz zdanie: „Jeżeli sekcja ZAŁOŻONE jest pusta, to znaczy,
że czegoś nie zauważyłeś." Bez niego model chętnie deklaruje, że niczego nie założył.
Przy technice 3 pamiętaj, że agent domyślnie „naprawia po drodze" - bez granic dostajesz diff,
w którym zmiana docelowa tonie wśród pięciu poprawek, o które nikt nie prosił.
CZAS: ~4 min
-->

---

# Kryterium akceptacji to liczba

| Nie da się zamienić w test | Zamienia się jeden do jednego |
|---|---|
| „odsetki mają być poprawnie naliczone za okres opóźnienia" | podstawa 10 000,00; termin 2026-01-10; rozliczenie 2026-02-10 → **123,15 zł** |
| „powinien obsługiwać wpłaty częściowe" | wpłata 4 000,00 dnia 2026-01-26 → **97,73 zł** |
| „małe kwoty pomijamy" | 2 520,00 przez 10 dni → 10,01 zł, nota jest; 2 515,00 → 9,99 zł, noty nie ma |

**Para graniczna z obu stron progu** wykrywa błąd `>=` kontra `>`.
Sześć „normalnych" przypadków to jeden przypadek zapisany sześć razy.

<!--
CO POWIEDZIEĆ: Trzy liczby są warte więcej niż akapit prozy. Są jednoznaczne, weryfikowalne
i zamieniają się wprost w testy. I powstają przed implementacją - inaczej test sprawdza kod,
a nie wymaganie.
NA CO UWAŻAĆ: Liczby podane przez model trzeba sprawdzić. Jeśli model podał 123,45 zamiast 123,15,
a nikt tego nie policzył, właśnie utrwaliliście halucynację jako kryterium akceptacji.
Policzenie tego to trzy linijki Pythona.
PYTANIE Z SALI: „Wynik 1 453,97 zł za rok przestępny wygląda na błąd, bo to więcej niż 14,5%
od 10 000 zł." Nie jest błędem: reguła mówi, że rok bazowy to zawsze 365, także w latach
przestępnych. 366 dni dzielone przez 365 daje więcej niż stopa roczna.
CZAS: ~3 min
-->

---

# Odrzucaj wcześnie, bo wtedy jest tanio

Sześć etapów: wymaganie, specyfikacja, plan, implementacja, testy, review.

<div class="przeplyw">
  <div class="krok dobry">Specyfikacja<small>odrzucenie: 5 minut</small></div>
  <div class="strzalka">→</div>
  <div class="krok dobry">Plan<small>odrzucenie: przed pierwszą edycją</small></div>
  <div class="strzalka">→</div>
  <div class="krok zly">Implementacja<small>odrzucenie: godzina czytania</small></div>
  <div class="strzalka">→</div>
  <div class="krok zly">Review<small>odrzucenie: cała praca agenta</small></div>
</div>

Sens podziału jest jeden: **każdy etap można odrzucić osobno.**

<!--
CO POWIEDZIEĆ: Ten sam mechanizm, co w kolejności pracy w labie 3.2: najdroższe zmiany na koniec.
Kroki „testy" i „implementacja" dotykają tylko nowych plików, więc odrzucenie ich kosztuje zero.
Dopiero adapter i endpoint wchodzą w istniejący kod.
NA CO UWAŻAĆ: Przy odbiorze testów pytanie brzmi: czy testują wymaganie, czy implementację.
Agent, który pisze testy patrząc na własny kod, produkuje testy przechodzące zawsze.
CZAS: ~3 min
-->

---

# Zakres negatywny

**Świadomie nie robimy w tej iteracji:**

- faktur walutowych - zwracamy jawny błąd zamiast liczyć,
- faktur korygujących,
- zapisu not do bazy, wysyłki, numeracji, PDF-ów,
- zmiennej stopy w czasie,
- jakiejkolwiek zmiany w `app/rozliczenia.py` i `oblicz_fakture()`.

> To, co masz zrobić, wynika z wymagania.
> **To, czego nie masz robić, nie wynika z niczego - musi być napisane.**

<!--
CO POWIEDZIEĆ: Pięć linii, które w labie 3.2 oszczędzają pół godziny czytania diffa.
Bez nich agent doda numerację not, bo „nota musi mieć numer", i zapis do bazy,
bo „przecież trzeba to gdzieś trzymać". I będzie miał rację, bo nikt nie powiedział, że nie.
NA CO UWAŻAĆ: To jest też odpowiedź na pytanie, po co w specyfikacji sekcja „Otwarte pytania".
Jeśli jest pusta, model przeniósł niepewność do reguł, gdzie wygląda na ustaloną.
CZAS: ~2 min
-->

---

# Specyfikacja zostaje w repozytorium

`specyfikacje/*.md` to nie formalność:

- jest **kontekstem** dla agenta przy następnej zmianie w tym obszarze,
- jest **dokumentacją decyzji** - mówi, czego celowo nie zrobiliśmy,
- przechodzi przez **code review** jak kod,
- daje się **zdiffować**, gdy wymaganie się zmieni.

> **Artefakt w repozytorium bije wiedzę w głowie.**
> W module 5 ten sam mechanizm zamieni workflow w skill.

<!--
CO POWIEDZIEĆ: To wraca przez cały kurs w tej samej formie: specyfikacja, hook, skill,
subagent, golden set, zasady zespołowe. Wszystko, co ma działać jutro bez ciebie,
musi być plikiem przechodzącym przez review.
CZAS: ~2 min
-->

---

<!-- _class: lab -->

# Laby 3.1 i 3.2

**3.1 Specyfikacja przed kodem** · ~40 min · tag `lab-3-1-start`
Produkt: `specyfikacje/noty-odsetkowe.md`. **Ani jednej linii kodu produkcyjnego.**
Krok 1 to pomiar: ile rozstrzygnięć agent podjął za ciebie bez specyfikacji.

**3.2 Implementacja według specyfikacji** · ~40 min · tag `lab-3-2-start`
Produkt: `app/odsetki.py`, `tests/test_odsetki.py`. Testy przed implementacją.
**Najważniejszy krok to review diffa**, nie pisanie kodu.

Niezacommitowana praca zablokuje `git checkout`, także pliki nieśledzone:
`git stash push -u -m "moje-2-2"`

<!--
CO POWIEDZIEĆ: Dwa laby na jednym wymaganiu biznesowym: „klienci płacą po terminie
i nic ich to nie kosztuje". W 3.1 zamieniasz je w specyfikację, w 3.2 w kod.
Rolę biznesu gra kartka z labu, więc nikt nie musi niczego zgadywać.
NA CO UWAŻAĆ: W 3.1 nie zatwierdzajcie planu w kroku 2. W 3.2 po kroku 1 `make test`
ma się wywalić na `ImportError` - to jest poprawny stan, modułu jeszcze nie ma.
PYTANIE Z SALI: „Co, jeśli utknę?" Przeskocz na tag kolejnego labu i jedź dalej.
Tagi istnieją właśnie po to. `git switch -c` nie odblokuje skoku, od tego jest `git stash push -u`.
CZAS: ~2 min
-->
