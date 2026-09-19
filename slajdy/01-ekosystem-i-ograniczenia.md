---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 1'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Ekosystem i ograniczenia modeli

## Moduł 1 · Dzień 1

Klasy narzędzi · dobór modelu do roli · cztery tryby porażki

<!--
CO POWIEDZIEĆ: Ten moduł nie uczy promptowania. Uczy dwóch rzeczy: do czego jest która
klasa narzędzia i w których czterech miejscach model zawodzi. Wszystko, co robimy przez
kolejne dwa dni, jest procesem wokół tych czterech miejsc.
CZAS: ~1 min
-->

---

# Trzy klasy narzędzi, trzy kontrakty

| | Model konwersacyjny<br>claude.ai, ChatGPT | Asystent w IDE<br>Copilot inline | Agent w repozytorium<br>Claude Code, Cursor Agent |
|---|---|---|---|
| Co widzi | to, co wkleisz | otwarty plik + kilka sąsiednich | całe repo, ale czyta selektywnie |
| Co może zrobić | wypisać tekst | wstawić fragment kodu | czytać, pisać, uruchamiać komendy, commitować |
| Kto weryfikuje | ty, przed wklejeniem | ty, przy akceptacji podpowiedzi | **musisz to zorganizować** |
| Pętla zwrotna | brak | kompilator / linter w IDE | testy, hooki, CI - jeśli je masz |
| Koszt błędu | zero, nic się nie stało | mały, widzisz diff od razu | **duży, wiele plików naraz** |

<!--
CO POWIEDZIEĆ: To nie jest tabela o wygodzie, tylko o kontrakcie. Przy czacie i przy
asystencie w IDE weryfikacja jest wbudowana w sposób użycia: patrzysz na wynik, zanim
go przyjmiesz. Przy agencie nikt jej za ciebie nie ustawi - stąd cały drugi dzień kursu.
NA CO UWAŻAĆ: sala patrzy na wiersz „co może zrobić" i nie zauważa wiersza „kto weryfikuje".
To ten drugi jest powodem, dla którego agent wymaga procesu, a nie tylko dobrego promptu.
PYTANIE Z SALI: „Asystent w IDE i agent to przecież to samo narzędzie?" Nie: asystent widzi
otwarty plik i wstawia fragment, agent widzi repo i może uruchamiać komendy oraz commitować.
Inny koszt błędu, więc inny wymagany proces.
CZAS: ~4 min
-->

---

# Które narzędzie: rozstrzyga jedno pytanie

> Czy trzeba coś **przeczytać w repo**, zanim się zacznie pisać?

<div class="rozgalezienie">
  <div>
    <div class="galaz nie">
      <span class="etykieta">NIE</span>
      Wiem dokładnie, co ma powstać → <strong>asystent w IDE</strong><br>
      Nie wiem, kształt dopiero się rodzi → <strong>model konwersacyjny</strong>
    </div>
  </div>
  <div>
    <div class="galaz tak">
      <span class="etykieta">TAK</span>
      Zmiana w jednym pliku → <strong>agent, mały krok</strong> + review diffa<br>
      Zmiana w wielu plikach → <strong>agent, tryb planowania</strong> + specyfikacja + bramki
    </div>
  </div>
</div>

Najczęstszy błąd na starcie: agent do zadania z gałęzi NIE - płacisz za czytanie repo,
którego nie potrzebujesz.

<!--
CO POWIEDZIEĆ: Jedno pytanie zamiast przeczucia. Wszystko, co zaczyna się od „znajdź,
a potem zmień", jest po stronie TAK. Wszystko, co masz w głowie gotowe, jest po stronie NIE.
NA CO UWAŻAĆ: drugi kierunek błędu jest rzadziej widoczny - asystent w IDE do zadania
z wielu plików daje kod spójny lokalnie, który nie pasuje do reszty systemu.
PYTANIE Z SALI: „Skoro mam agenta, po co mi jeszcze czat?" Model konwersacyjny nie ma
kontekstu projektu i to jest jego zaleta: nie zasugeruje się tym, jak coś zrobiono
u was do tej pory. Wybór biblioteki albo ocena trzech podejść do migracji to jego zadania.
CZAS: ~3 min
-->

---

# Dwie dźwignie, w tej kolejności

<div class="przeplyw">
  <div class="krok">Za drogo<small>trzeba zejść z kosztu</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Najpierw zejdź z effortu<small>ten sam model, cache zostaje</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Dopiero potem z modelu<small>cache jest przypisany do modelu</small></div>
</div>

Poziom wysiłku: `low` · `medium` · `high` · `xhigh` · `max`.
Nowszy model na niskim efforcie często wypada lepiej niż starszy na wysokim.

**Model dobieraj do kosztu błędu, nie do trudności zadania.**

<!--
CO POWIEDZIEĆ: Ludzie znają jedną dźwignię - wybór modelu. Druga, effort, jest tańsza
w użyciu i nie rozbija cache'u, bo cache siedzi przy modelu. Dlatego kolejność jest taka,
a nie odwrotna.
NA CO UWAŻAĆ: „Opus był lepszy, więc zawsze biorę Opusa". Na pytaniu o prosty fakt z kodu
różnica bywa żadna, a cennik pięciokrotny. Zysk z mocniejszego modelu pojawia się dopiero
tam, gdzie zadanie wymaga rozumowania: decyzja architektoniczna, review bezpieczeństwa,
debug bez hipotezy.
CZAS: ~3 min
-->

---

# Pułapka: `/effort` zapisuje się na stałe

`/effort` z **wpisanym** poziomem ustawia go jako domyślny na kolejne sesje.
To samo robi wybór modelu w `/model`.

| Zostajesz na | Co się dzieje przez resztę kursu |
|---|---|
| Opus / `high` | limity planu wyczerpują się około modułu 6-7, czyli w najdroższych labach |
| Haiku / `low` | laby 4.2 i 4.3 przestają działać - cała pointa zależy tam od jakości rozumowania |

Druga rzecz: **Haiku 4.5 nie obsługuje effortu** - ustawienie poziomu nic tam nie zmienia.
Gdy ustawisz poziom, którego model nie ma, schodzi do najwyższego obsługiwanego.

<!--
CO POWIEDZIEĆ: To jedyny slajd w tym module z konsekwencją na dwa dni do przodu.
Ustawienie wybrane rano do jednego pytania jedzie z wami przez piętnaście kolejnych labów.
Dlatego lab 1.1 ma krok 6, który przywraca stan wyjściowy.
NA CO UWAŻAĆ: ludzie pomijają krok 6 jako „formalność" i potem w module 6 dziwią się,
skąd wyczerpane limity.
PYTANIE Z SALI: „Jak sprawdzę, na czym aktualnie jestem?" `/status` - pokazuje wersję,
model i załadowane pliki ustawień.
CZAS: ~3 min
-->

---

# Cztery tryby porażki

| Tryb | Czy się wywali? |
|---|---|
| Halucynacja | **tak** - funkcji, parametru albo pliku po prostu nie ma |
| Błędne założenie | nie - kod działa i przechodzi testy, tylko realizuje inne wymaganie |
| Nadmierna pewność | nie - odpowiedź zmyślona i sprawdzona brzmią identycznie |
| Rozrost kontekstu | nie - rośnie koszt, spada jakość, wracają porzucone pomysły |

Groźniejsze jest to, co **przechodzi**. To nie są wady, które kiedyś naprawią - to
właściwości działania modeli. Łapie je proces, nie nadzieja.

<!--
CO POWIEDZIEĆ: Halucynacja jest najgłośniejsza, ale najmniej kosztowna - wywala się przy
pierwszym uruchomieniu. Błędne założenie wchodzi do produkcji, bo testy są zielone.
Modułowi 3, o specyfikacji odpornej na dopowiadanie, poświęcamy cały blok właśnie dlatego.
NA CO UWAŻAĆ: sala chce usłyszeć, który model halucynuje najmniej. To złe pytanie -
halucynacja nie jest cechą modelu, tylko cechą sytuacji: czy odpowiedź ma się o co zaczepić.
PYTANIE Z SALI: „Czy nowsze modele tego nie naprawią?" Nie w tym sensie. Model nie ma
wbudowanego sygnału „nie wiem", więc nie odróżnisz odpowiedzi sprawdzonej po sposobie pisania.
CZAS: ~4 min
-->

---

<!-- _class: haslo -->

## Ton odpowiedzi nie niesie żadnej informacji o jej prawdziwości.

Kalibruj po weryfikowalności: cytat z pliku, przechodzące testy, wykonana komenda.

<!--
CO POWIEDZIEĆ: To jest zdanie, które ma zostać z tego modułu, gdy reszta się zatrze.
Odpowiedź bez punktu zaczepienia w rzeczywistości traktuj jak hipotezę, niezależnie od tego,
jak rzeczowo brzmi.
NA CO UWAŻAĆ: typowy odruch to uznanie dłuższej i bardziej szczegółowej odpowiedzi
za lepszą. W labie 1.1 wariant A i wariant C brzmią tym samym rzeczowym tonem -
jeden jest zmyślony, drugi sprawdzony.
CZAS: ~2 min
-->

---

# Halucynacja ginie od wymuszonego cytatu

<div class="rozgalezienie">
  <div>
    <div class="galaz nie">
      <span class="etykieta">Bez narzędzi, z pamięci</span>
      „Nie używaj narzędzi i nie czytaj plików. Odpowiedz wyłącznie z tego,
      co pamiętasz: jak działa funkcja X w tym projekcie?"<br>
      → opis, który brzmi wiarygodnie
    </div>
  </div>
  <div>
    <div class="galaz tak">
      <span class="etykieta">Zleca czynność weryfikowalną</span>
      „Znajdź X, zacytuj sygnaturę ze ścieżką i numerem linii.
      Jeżeli nie ma - napisz dokładnie: nie ma takiej funkcji."<br>
      → „nie znalazłem"
    </div>
  </div>
</div>

Różnica nie siedzi w modelu, tylko w tym, czy odpowiedź ma się o co zaczepić.

<!--
CO POWIEDZIEĆ: Pytanie „wyjaśnij, jak działa X" zakłada istnienie X, więc model odpowiada
na pytanie, które dostał. Drugie sformułowanie zleca czynność i z góry opisuje, co zrobić
przy pustym wyniku. To jest reguła na cały kurs: twierdzenie o twoim kodzie bez cytatu
z pliku i numeru linii jest hipotezą, nie odpowiedzią.
NA CO UWAŻAĆ: nie zdradzaj tu przykładu z labu ani tego, co wyjdzie w kroku 2.
Cała wartość ćwiczenia leży w tym, że sala zobaczy to na własnych oczach.
CZAS: ~3 min
-->

---

# Higiena sesji: trzy odruchy

- **`/context`** - ile okna zajęte i, ważniejsze, **co** je zajmuje
- **`/clear`** - między niepowiązanymi zadaniami. Jedna sesja = jedno zadanie
- **`Esc`** - przerywa pracę modelu natychmiast; koszt przerwania po trzech sekundach
  jest zerowy, koszt czekania do końca jest pełny

Sesja niesie wszystko: pliki sprzed pół godziny, wyniki komend, ślepe uliczki.
Cała historia jedzie przy każdym zapytaniu.

<!--
CO POWIEDZIEĆ: Rozrost kontekstu kosztuje dwa razy: płacisz za historię i tracisz jakość,
bo właściwa instrukcja tonie wśród nieistotnych szczegółów. Najgorszy objaw jest trzeci:
model wraca do podejścia, które godzinę temu odrzuciliście.
NA CO UWAŻAĆ: `Esc` to najważniejszy klawisz z tej listy i najrzadziej używany.
Ludzie czekają, aż model skończy iść w złą stronę.
PYTANIE Z SALI: „Czym `/clear` różni się od `/rewind`?" `/clear` czyści kontekst i kończy
zadanie. `/rewind` cofa rozmowę **i** kod do wcześniejszego punktu.
CZAS: ~3 min
-->

---

# Co wyniesiesz do własnego narzędzia

| Przenosi się: sposób pracy | Nie przenosi się: mechanika |
|---|---|
| specyfikacja przed implementacją | składnia hooków |
| małe kroki, review diffa przed commitem | format skilla |
| deterministyczne bramki, higiena kontekstu | nazwa pliku kontekstowego |

Pierwsza kolumna to około **80% tego kursu** i działa wszędzie.

W zespole mieszanym: plików kontekstowych tyle, ile narzędzi, ale **treść jedna** -
jeden plik źródłowy, reszta go dołącza albo jest generowana.

<!--
CO POWIEDZIEĆ: Prowadzimy kurs na Claude Code nie dlatego, że to jedyne słuszne narzędzie,
tylko dlatego, że ma komplet mechanizmów, o których mówimy: pliki kontekstowe, tryb
planowania, hooki, subagentów, worktree i widoczne liczniki zużycia. Da się na nim pokazać
każdy element programu.
NA CO UWAŻAĆ: dwie rozjeżdżające się wersje standardów projektu są gorsze niż żadna.
PYTANIE Z SALI: „Mamy w firmie Copilota, czy to ma dla mnie sens?" Tak - przenosi się sposób
pracy, czyli większość kursu. Przetłumaczyć trzeba mechanikę: plik kontekstowy nazywa się
tam `.github/copilot-instructions.md`, a hooków na zdarzenia Copilot nie ma w ogóle.
CZAS: ~3 min
-->

---

# Czego ten kurs nie obiecuje

| Czego kurs nie obiecuje | Co jest naprawdę |
|---|---|
| agent zastąpi zrozumienie problemu | „napisz ten kod" → **„sprawdź ten kod"** |
| szybciej generuje, więc szybciej dostarczasz | wąskim gardłem staje się **weryfikacja** |
| opłaca się na każdym zadaniu | sesja ma stały narzut: kontekst, diff, review |

**Dlatego dzień 2 jest o weryfikacji deterministycznej, a nie o szybszym pisaniu.**

<!--
CO POWIEDZIEĆ: Ustawiamy to teraz, żeby nie wróciło jako rozczarowanie w module 5.
Jeśli nie umiesz ocenić diffa, agent cię nie przyspiesza - przyspiesza wjazd długu
technicznego. Jednolinijkowa poprawka, którą znasz na pamięć, nadal jest szybsza z klawiatury.
CZAS: ~2 min
-->

---

<!-- _class: lab -->

# Lab 1.1 - Model-to-Task Mapping na żywym repo

**~30 min** · tag `lab-1-1-start` · produkt `notatki/model-to-task.md`

- **Krok 1** - to samo pytanie o fakt na czterech konfiguracjach, zmieniając **jedną rzecz naraz**
- **Krok 2** - trzy sformułowania tego samego pytania o funkcję; zapisz wszystkie trzy odpowiedzi
- **Krok 3** - pytanie wymagające rozumowania: `sonnet`/`medium` kontra `opus`/`high`
- **Krok 4** - `/context`, `/clear`, `/context` i różnica między odczytami
- **Krok 6** - **przywróć `/model sonnet` i `/effort high`**; ten krok nie jest opcjonalny

Masz niezacommitowaną pracę? `git stash push -u -m "moje-1-1"` przed `git checkout`.

<!--
CO POWIEDZIEĆ: Cel labu jest jeden: zobaczyć na własne oczy, że odpowiedź zmyślona
i sprawdzona brzmią tym samym tonem. Reszta to notatki, które będą wam potrzebne
w module 7, gdy policzymy to w pieniądzach.
NA CO UWAŻAĆ: w krokach 1-3 nie robimy `/clear` - porównujemy odpowiedzi w tych samych
warunkach. Przy realnym porównaniu modeli trzeba czyścić kontekst między próbami.
I pilnujcie kroku 6, inaczej cały kurs pojedzie na konfiguracji wybranej do jednego pytania.
PYTANIE Z SALI: „Mam nieczysty katalog, `git checkout` nie działa." `git stash push -u`,
z `-u`, bo blokują też pliki nieśledzone. `git switch -c` tu nie pomoże - nic nie commituje,
więc nie odblokowuje skoku na tag.
CZAS: ~2 min
-->
