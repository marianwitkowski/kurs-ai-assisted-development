---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 2'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Kontekst i dokumentacja LLM-ready

## Moduł 2 · Dzień 1

Okno kontekstowe · `CLAUDE.md` · standardy projektu · MCP

**Świadomie decydować, co model ma wiedzieć, a co go tylko zaśmieca.**

<!--
CO POWIEDZIEĆ: Moduł pierwszy był o tym, co model potrafi. Ten jest o tym, co model wie
w chwili, gdy go pytasz. Wiedza nie bierze się z pamięci - bierze się z okna kontekstowego,
a ono jest w całości pod naszą kontrolą.
CZAS: ~1 min
-->

---

<!-- _class: haslo -->

## Okno kontekstowe to budżet, nie pojemnik

Koszt rośnie kwadratowo z długością sesji. Jakość spada wraz z rozrostem.

<!--
CO POWIEDZIEĆ: Model nie pamięta projektu. Przy każdym zapytaniu dostaje z powrotem całą
treść rozmowy: prompt systemowy, definicje narzędzi, pliki kontekstowe, wszystkie
przeczytane pliki i wyniki komend. Dziesiąte pytanie w sesji jest znacznie droższe niż
pierwsze, nawet jeśli brzmi identycznie. Drugi skutek jest mniej oczywisty i ważniejszy:
instrukcja utopiona wśród czterdziestu przeczytanych plików działa słabiej niż ta sama
instrukcja w czystej sesji.
NA CO UWAŻAĆ: sala słyszy „oszczędzanie" i myśli o rachunku. Rachunek to połowa sprawy -
druga połowa to jakość odpowiedzi, której na fakturze nie widać.
PYTANIE Z SALI: „Mam okno miliona tokenów, po co mi to?" - Model o oknie 1M nie rozumie
miliona tokenów równie dobrze jak dziesięciu tysięcy. Duże okno to bufor bezpieczeństwa,
nie zaproszenie do wrzucania wszystkiego.
CZAS: ~3 min
-->

---

# `/context`: co faktycznie siedzi w oknie

| Kategoria | Co to jest |
|---|---|
| System prompt | stały prompt Claude Code |
| Tool definitions | opisy narzędzi, którymi model dysponuje |
| MCP tools | narzędzia z serwerów MCP |
| **Memory files** | **`CLAUDE.md` i pokrewne** |
| Messages | historia rozmowy |
| Free space | to, co zostało |

**Memory files to jedyny dowód, że twój plik kontekstowy działa.** Nie ma go tam - model go nie widzi.

<!--
CO POWIEDZIEĆ: Jedna komenda, jeden nawyk. Przed pracą i po dłuższej sesji warto zerknąć,
co zjada okno. Ale prawdziwy powód, dla którego ta komenda jest w tym module, to jedna
sekcja: Memory files. Napisałeś plik kontekstowy i chcesz wiedzieć, czy zadziałał -
to jest jedyne miejsce, w którym to widać.
NA CO UWAŻAĆ: procenty zależą od konfiguracji sali (serwery MCP, pliki użytkownika),
więc nie porównujemy ich między uczestnikami. Porównujemy przyrosty u siebie.
PYTANIE Z SALI: „Napisałem `CLAUDE.md`, skąd mam wiedzieć, że model go czyta?" -
`/context`, sekcja Memory files. Jeśli pliku tam nie ma, jest w złym miejscu.
CZAS: ~3 min
-->

---

# Trzy odruchy higieny kontekstu

1. **`/clear` między niepowiązanymi zadaniami.** Jedna sesja = jedno zadanie.
   Kosztuje zero, działa natychmiast.
2. **Czytanie celowane zamiast hurtowego.** Ta sama odpowiedź, kilkanaście razy taniej.
3. **`Esc`, gdy model wciąga niepotrzebne pliki.**

> Nie da się wyjąć czegoś z kontekstu. Da się tylko nie wpuścić.

<!--
CO POWIEDZIEĆ: Trzy rzeczy, które można zacząć robić dziś po południu, bez żadnej
konfiguracji. Najtańsza optymalizacja, jaka istnieje, to `/clear` - i najczęściej pomijana,
bo kusi trzymanie jednej długiej sesji na cały dzień.
NA CO UWAŻAĆ: ostatni punkt jest asymetryczny i to jest jego sedno. Kontekst jest
jednokierunkowy: wpuszczone zostaje do końca sesji albo do `/clear`.
CZAS: ~3 min
-->

---

# Dziewięć tysięcy kontra czterysta

<div class="rozgalezienie">
  <div>
    <div class="galaz nie">
      <span class="etykieta">instrukcja proceduralna</span>
      „Przeczytaj wszystkie pliki w <code>app/</code>"<br>
      17 plików, 1204 linie, <strong>~9 000 tokenów</strong>
    </div>
  </div>
  <div>
    <div class="galaz tak">
      <span class="etykieta">instrukcja celowa</span>
      „Znajdź, gdzie liczony jest rabat progowy"<br>
      jeden plik, <strong>~400 tokenów</strong>
    </div>
  </div>
</div>

**Ta sama odpowiedź, około dwudziestokrotna różnica.** Mów, **co ustalić**, nie **jak czytać**.

<!--
CO POWIEDZIEĆ: To jest najważniejsza liczba w tym module i uczestnicy zmierzą ją sami
w labie 2.1. Nie zależy od modelu, od planu ani od wielkości okna - zależy wyłącznie
od sformułowania promptu. Narzuconą procedurę model wykona dosłownie, nawet gdy jest
kosztowna. Cel zostawia mu wybór najtańszej drogi, a `Grep` jest tańszy niż `Read`.
NA CO UWAŻAĆ: to repo ćwiczeniowe. W firmowym repozytorium ta sama różnica liczy się
w setkach tysięcy tokenów i powtarza przy każdym zapytaniu w sesji.
PYTANIE Z SALI: „Czyli grep jest zawsze lepszy?" - Nie. Gdy zadanie polega na zrozumieniu
przepływu przez pięć modułów, model musi je przeczytać. Chodzi o to, żeby czytał dlatego,
że zadanie tego wymaga, a nie dlatego, że tak mu kazałeś.
CZAS: ~3 min
-->

---

# Cztery kanały wiedzy

| | Pliki projektowe | Long context | RAG |
|---|---|---|---|
| Kiedy | kod, który jest w repo | jeden duży dokument, praca jednorazowa | duży, wolno zmienny zbiór spoza repo |
| Aktualność | zawsze bieżąca | tyle, ile wkleiłeś | tyle, ile ma indeks |
| Zawodzi | gdy wiedzy nie ma w repo | gdy „wszystko" nie mieści się w oknie | gdy pytanie nie trafia w indeks |

**Nie buduj RAG-a nad własnym repozytorium.** Próg to pytanie: *czy to da się przeczytać
narzędziem plikowym?*

**MCP to kanał czwarty.** Gdy istnieje CLI (`gh`, `aws`), jest tańszy kontekstowo.
Zwrócony tekst działa na model jak instrukcja - wracamy do tego w module 8.

<!--
CO POWIEDZIEĆ: Te cztery sposoby nie konkurują, rozwiązują różne problemy. Reguła
praktyczna jest jednozdaniowa: wiedza o kodzie idzie przez pliki projektowe, zawsze.
Agent ma `Grep` i `Read` i sam dojdzie tam, gdzie trzeba. RAG zaczyna mieć sens dopiero
dla wiedzy spoza repo i dużej: dokumentacja wewnętrzna na tysiąc stron, archiwum zgłoszeń,
regulacje branżowe.
NA CO UWAŻAĆ: definicje narzędzi MCP są domyślnie odroczone przez `ToolSearch`, ale
`/context` i tak pokaże ich koszt. `/mcp` pozwala wyłączyć nieużywane serwery.
PYTANIE Z SALI: „Mamy zbudować RAG nad naszym repo?" - Nie. Kosztuje utrzymanie indeksu,
a agent dostaje nieaktualne fragmenty zamiast bieżącego pliku z dysku.
CZAS: ~3 min
-->

---

# Dokumentacja: co pisać, czego nie

<div class="rozgalezienie">
  <div>
    <div class="galaz nie">
      <span class="etykieta">model przeczyta sam</span>
      struktura katalogów<br>
      lista zależności<br>
      sygnatury i typy<br>
      co robi funkcja
    </div>
  </div>
  <div>
    <div class="galaz tak">
      <span class="etykieta">model nie przeczyta nigdy</span>
      dlaczego tak, skoro prościej się da<br>
      co jest celowe, choć wygląda na błąd<br>
      czego nie wolno ruszać bez rozmowy<br>
      jak się to uruchamia i weryfikuje
    </div>
  </div>
</div>

**Ten sam plik:** „`rabaty.py` liczy rabaty" kontra „pozycja promocyjna wlicza się do progu,
ale sama rabatu nie dostaje - to reguła biznesowa, nie błąd".

<!--
CO POWIEDZIEĆ: Dobra wiadomość: dokumentacja dla modelu i dla nowego człowieka w zespole
to ta sama dokumentacja. Różnica jest jedna - model jest bardziej bezlitosny wobec braków,
bo nie dopyta. Zamiast tego dopowie. Opis architektury wyliczający katalogi i zależności
to najczęstszy typ dokumentacji bezużytecznej dla modelu: zajmuje kontekst i nie wnosi nic.
NA CO UWAŻAĆ: uczestnicy zobaczą to na własne oczy w labie 2.2, gdy `/init` wygeneruje
im dokładnie tę pierwszą kolumnę i trzeba będzie ją skasować.
CZAS: ~3 min
-->

---

# `CLAUDE.md`: cztery zakresy, jedna skleina

| Zakres | Gdzie | Kto widzi |
|---|---|---|
| Managed policy | katalog systemowy | wszyscy w organizacji, **nie da się wyłączyć** |
| Użytkownik | `~/.claude/CLAUDE.md` | ty, we wszystkich projektach |
| Projekt | `./CLAUDE.md` albo `./.claude/CLAUDE.md` | zespół, przez repozytorium |
| Lokalny | `./CLAUDE.local.md` | ty, w tym projekcie (do `.gitignore`) |

- **Pliki się sklejają, nie nadpisują.** Nie ma przesłonięcia reguły z wyższego poziomu.
- Podkatalogi ładują się dopiero, gdy model sięgnie po plik z tego katalogu.
- Po kompakcji projektowy `CLAUDE.md` z korzenia wraca z dysku. Wyjaśnienie z rozmowy przepada.

<!--
CO POWIEDZIEĆ: Kolejność idzie od korzenia systemu plików w dół do katalogu, w którym
odpalono sesję - bliższe miejsca uruchomienia model czyta jako ostatnie. Ale kluczowe jest
słowo „sklejają". Jeśli twój plik użytkownika mówi „zawsze po angielsku", a projektowy
„zawsze po polsku", model dostaje obie instrukcje naraz.
NA CO UWAŻAĆ: ładowanie podkatalogów na żądanie to mechanizm oszczędzający kontekst
w monorepo - i pułapka, gdy ktoś liczy, że reguła zadziała od startu sesji.
PYTANIE Z SALI: „Która reguła wygrywa przy sprzeczności?" - Żadna. Model wybiera
w zasadzie losowo, a ty nie wiesz którą. Sprzeczne reguły są gorsze niż brak reguł.
CZAS: ~3 min
-->

---

# Rośnie? Tnij w tej kolejności

Cel: **poniżej 200 linii.** Powyżej 4 MiB plik jest pomijany w całości.

<div class="drabina">
  <div class="stopien"><span class="nr">1</span> Skill<span class="cena">ładuje się na wywołanie</span></div>
  <div class="stopien"><span class="nr">2</span> Reguła z <code>paths:</code> w <code>.claude/rules/</code><span class="cena">przy dotknięciu pasującego pliku</span></div>
  <div class="stopien"><span class="nr">3</span> <code>@import</code><span class="cena">zawsze, przy starcie sesji</span></div>
</div>

**`@import` porządkuje pliki, nie oszczędza kontekstu.** Maksymalnie cztery poziomy zagnieżdżenia.

<!--
CO POWIEDZIEĆ: Dwieście linii to nie estetyka. Dłuższe pliki zjadają kontekst w każdej sesji
i realnie obniżają przestrzeganie instrukcji - płacisz dwa razy za to, co miało pomóc.
Gdy plik rośnie, kolejność cięcia jest odwrotna do intuicji: najpierw proceduralne workflow
do skilla, potem instrukcje dotyczące wycinka kodu do reguły z `paths:`, i dopiero na końcu
rozbijanie przez `@import`.
NA CO UWAŻAĆ: skille i hooki to moduł 5 - dziś wystarczy wiedzieć, że istnieje gdzie
odłożyć treść. Reguła z `paths:` to najlepszy sposób na krótki `CLAUDE.md` w dużym repo.
PYTANIE Z SALI: „Czyli podzielę plik na trzy i będzie taniej?" - Nie. Import ładuje się
przy starcie dokładnie tak samo jak treść wklejona wprost.
CZAS: ~3 min
-->

---

<!-- _class: gesta -->

# Czego tam nie wolno wpisać

| Nie wpisuj | Dlaczego | Gdzie zamiast tego |
|---|---|---|
| Sekretów, tokenów, haseł | plik jest w repo i w kontekście każdej sesji | zmienne środowiskowe, menedżer sekretów |
| Danych osobowych, treści klienta | to samo | nigdzie |
| Listy katalogów, listy zależności | model to widzi sam | usunąć |
| Opisu, co robi każda funkcja | model to czyta z kodu | usunąć |
| Reguł, które **muszą** zadziałać | to kontekst, nie wymuszenie | **hook** (moduł 5) |
| Długich procedur krok po kroku | siedzą w kontekście, gdy są niepotrzebne | **skill** (moduł 5) |

Komentarze `<!-- … -->` są wycinane przed wysłaniem. Człowiek je widzi, model za nie nie płaci.

<!--
CO POWIEDZIEĆ: Pierwsze dwa wiersze to higiena bezpieczeństwa: plik kontekstowy trafia
do repozytorium i do każdej sesji, więc sekret wpisany tutaj rozchodzi się dwoma kanałami
naraz. Środkowe dwa to czysty koszt. Dwa ostatnie wiersze są najważniejszą rzeczą
w tym module i wracamy do nich jutro.
NA CO UWAŻAĆ: w labie 2.2 w `app/konfiguracja.py` jest coś, czego tam być nie powinno.
Jeśli ktoś zacytuje to w `CLAUDE.md` albo w opisie architektury - usunąć od razu.
PYTANIE Z SALI: „Mogę wpisać notatkę dla zespołu, kto ten plik utrzymuje?" - Tak,
w komentarzu HTML. Komentarze są wycinane przed wysłaniem do modelu.
CZAS: ~2 min
-->

---

# Prośba kontra egzekucja

<div class="przeplyw">
  <div class="krok"><code>CLAUDE.md</code>, reguły<small>model stara się stosować</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Skill<small>procedura, gdy wywołana</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Hook<small>wykonuje się zawsze</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">CI<small>blokuje scalenie</small></div>
</div>

Test, który rozstrzyga: **„co się stanie, jeśli model to zignoruje?"**

„Nic strasznego, poprawię na review" → `CLAUDE.md` wystarczy.
„Wejdzie nam sekret do repo" → to musi być hook albo CI.

<!--
CO POWIEDZIEĆ: To jest oś, która wraca przez cały kurs - dziś w module 2, jutro
w modułach 5, 7 i 8. `CLAUDE.md` trafia do modelu jako wiadomość użytkownika po prompcie
systemowym. Model ją czyta i stara się stosować. To nie jest warstwa egzekucji. Jeśli coś
musi się wydarzyć zawsze, to jest zadanie dla hooka, nie dla instrukcji.
NA CO UWAŻAĆ: to nie są alternatywy. Każda warstwa ma swoje miejsce i nikt nie wpisuje
konwencji nazewniczych do CI.
PYTANIE Z SALI: „Wpiszę „nigdy nie commituj bez testów" do `CLAUDE.md` i tyle?" - To prośba,
nie gwarancja. Model zwykle się zastosuje, ale nie zawsze. Jutro w labie 5.1 ta sama reguła
stanie się hookiem `Stop` i przestanie być prośbą.
CZAS: ~3 min
-->

---

# Instrukcja sprawdzalna

| Słabo | Dobrze |
|---|---|
| „Dbaj o jakość kodu" | „Przed commitem uruchom `make gate`" |
| „Testuj zmiany" | „Każda zmiana w `app/rozliczenia.py` wymaga testu w `tests/`" |
| „Formatuj kod" | „`ruff format`, długość linii 100" |

**Jeśli nie umiesz napisać, jak sprawdzić, czy instrukcja została spełniona -
model też nie będzie umiał.**

<!--
CO POWIEDZIEĆ: Prawa kolumna nie jest dłuższa od lewej, jest konkretniejsza. To jest
jedyne kryterium, jakie trzeba zapamiętać: sprawdzalność. Uczestnicy zmierzą to
w labie 2.2 - ta sama prośba przed i po napisaniu pliku ma dać inny wynik. Jeśli nie dała,
wina jest po stronie pliku, nie modelu, a najczęstszą przyczyną jest instrukcja życzeniowa.
NA CO UWAŻAĆ: przy przeglądzie standardów szukać sprzeczności między plikiem użytkownika,
projektowym, zagnieżdżonymi i regułami. Dwie sprzeczne reguły to gorszy stan niż brak reguły.
CZAS: ~2 min
-->

---

<!-- _class: lab -->

# Laby 2.1 i 2.2

**2.1 - Audyt okna kontekstowego** (~30 min, tag `lab-2-1-start`)
Zmierzyć, nie oszacować: hurtowo kontra celowanie. Potem pytanie „dlaczego", na które
w repo nie ma odpowiedzi. Produkt: `notatki/audyt-kontekstu.md`.

**2.2 - Pliki kontekstowe dla tego repozytorium** (~35 min, tag `lab-2-2-start`)
Pomiar przed, `/init`, przepisanie poniżej 60 linii, pomiar po.
Produkt: `CLAUDE.md` i `docs/architektura.md`.

Niezacommitowana praca zablokuje `git checkout`, także pliki nieśledzone:
`git stash push -u -m "moje-2-1"`.

<!--
CO POWIEDZIEĆ: Lab 2.1 nie zmienia ani linii kodu - zmienia to, co uczestnik robi
z kontekstem. Krok 4 jest tym, który uzasadnia istnienie labu 2.2: model zapytany
„dlaczego", bez dowodów w repo, nie milczy - zgaduje stanowczym tonem. Tę odpowiedź trzeba
zapisać dosłownie, bo wracamy do niej jeszcze dziś, w module 4.
NA CO UWAŻAĆ: bez `/clear` między krokami porównuje się sumę, nie przyrost - i cały pomiar
traci sens. W labie 2.2 ostrzeżenie o `oblicz_fakture()` ma mówić o istnieniu
nieudokumentowanych reguł, nie wymyślać, jakie one są.
PYTANIE Z SALI: „`git switch -c` wystarczy, żeby odłożyć pracę?" - Nie. Nie commituje
niczego, więc ani nie zachowuje pracy, ani nie odblokowuje skoku na tag. Od tego jest
`git stash push -u`.
CZAS: ~2 min
-->
