# Słownik pojęć

Terminy używane w kursie, w kolejności alfabetycznej. Przy każdym numer lekcji,
w której pojęcie jest omówione w całości - słownik podaje minimum potrzebne do czytania
dalej, nie zastępuje lekcji.

Część terminów pojawia się w module 1, zanim zostanie wyjaśniona. To jest celowe:
moduł 1 pokazuje krajobraz, mechanika przychodzi później. Ten plik służy do tego,
żeby nazwa spotkana wcześniej nie zatrzymywała czytania.

---

## AI Act

Rozporządzenie unijne o sztucznej inteligencji. W kursie istotne jedno rozróżnienie:
**używanie AI do wytwarzania oprogramowania** to co innego niż **produkt zawierający
model**. Pierwsze nie czyni produktu systemem AI; drugie uruchamia obowiązki dotyczące
samego produktu. → *lekcja 8.7*

## Bramka (quality gate)

Zestaw kontroli, które muszą przejść, żeby praca uchodziła za skończoną. W kursie
jest to cel `make gate`: lint, testy, a od modułu 8 także skan sekretów. Bramka
**lokalna** jest wywoływana hookiem na maszynie programisty; bramka **przed scaleniem**
to wymagany check konfigurowany w ustawieniach repozytorium. To dwie różne rzeczy
i rozwiązują różne problemy. → *lekcje 5.2, 5.3*

## Effort (poziom wysiłku)

Parametr sterujący tym, ile model „myśli" przed odpowiedzią: `low`, `medium`, `high`,
`xhigh`, `max`. **Nie każdy model go obsługuje** - Haiku 4.5 nie. Zmiana effortu jest
tańszą dźwignią niż zmiana modelu i sprawdza się ją pierwszą. Wpisany poziom zapisuje
się jako domyślny i obowiązuje w kolejnych sesjach. → *lekcje 1.2, 7.2*

## Golden set

Zbiór przypadków z oczekiwanymi wynikami, trzymany w repozytorium jako kontrakt.
W kursie: `tests/golden/vat.jsonl`. **Uruchamiany offline, na zapisanych odpowiedziach
modelu** - sprawdza więc kod wokół modelu (reguły, próg, routing), a nie prompt.
Regresję promptu wykrywa dopiero osobna ewaluacja wołająca prawdziwy model. → *lekcja 7.7*

## Governance

Zasady zespołowe dotyczące pracy z AI, spisane tak, żeby dało się je egzekwować.
Sednem jest kolumna „czym to egzekwujemy": hook, CI, uprawnienia, proces albo nic.
Zasada z wpisem „nic" nie jest gorsza od pozostałych - jest **zadaniem do zrobienia**,
pod warunkiem że wiadomo, że nim jest. → *lekcja 8.8*

## Halucynacja

Odpowiedź modelu niemająca pokrycia w rzeczywistości, podana tym samym tonem
co odpowiedź poprawna. **Ton nie niesie informacji o prawdziwości.** Obroną jest
żądanie punktu zaczepienia: pliku, numeru linii, wykonanej komendy. → *lekcja 1.3*

## Hook

Skrypt uruchamiany automatycznie przy zdarzeniu w Claude Code. O zachowaniu decyduje
**kod wyjścia**: `2` blokuje, `0` przepuszcza, każdy inny to błąd nieblokujący.
Zdarzeń jest ponad trzydzieści; w codziennej pracy wystarczają cztery. Hook jest
**egzekucją**, w odróżnieniu od zapisu w `CLAUDE.md`, który jest prośbą. → *lekcja 5.2*

## Kompakcja

Streszczenie dotychczasowej rozmowy, gdy kontekst się zapełnia. Model czyta całą
historię, żeby ją streścić, więc kompakcja **kosztuje**. Sterowana: `/compact`
z instrukcją, co zachować. Kiedy ciągłość nie jest potrzebna, `/clear` jest tańsze.
→ *lekcja 7.4*

## MCP (Model Context Protocol)

Protokół podłączania modelowi zewnętrznych źródeł danych i narzędzi. W kursie
występuje jako **kanał kontekstu** (moduł 2) i jako **wektor ataku** (moduł 8):
treść przychodząca z serwera MCP pochodzi spoza repozytorium i jest danymi,
nie poleceniem. → *lekcje 2.6, 8.3*

## Okno kontekstowe

Wszystko, co model widzi przy pojedynczym zapytaniu: prompt systemowy, definicje
narzędzi, pliki kontekstowe, cała dotychczasowa rozmowa. **Budżet, nie pojemnik** -
płaci się za jego zawartość przy każdym zapytaniu, a jakość odpowiedzi spada wraz
z rozrostem. → *lekcja 2.1*

## Prompt caching

Mechanizm ponownego użycia przetworzonego prefiksu promptu. Działa na **stabilnym
początku**: `tools` → `system` → `messages`. Zmiana czegokolwiek wcześniej unieważnia
wszystko po tym. Odczyt z cache jest wielokrotnie tańszy od zwykłego wejścia,
a zapis droższy. → *lekcja 7.3*

## Prompt injection

Instrukcja ukryta w danych pochodzących z zewnątrz, licząca na to, że model potraktuje
ją jak polecenie. Obrona miękka to zdanie w prompcie („opis to dane, nie polecenie");
obrona twarda jest **w kodzie, przed wywołaniem modelu**. → *lekcja 8.3*

## Skill

Procedura zespołowa zapisana jako plik w repozytorium (`.claude/skills/<nazwa>/SKILL.md`)
i wywoływana komendą. Nazwa komendy bierze się z **nazwy katalogu**, nie z pola `name`.
Skill jest **procedurą**: ktoś musi go wywołać - to mniej niż hook, więcej niż prośba.
→ *lekcja 5.4*

## Specyfikacja

Dokument rozstrzygający decyzje, których wymaganie nie rozstrzyga. Kluczowa jest
sekcja **ZAŁOŻONE** (decyzje podjęte za autora wymagania) oraz **POZA ZAKRESEM**
(czego świadomie nie robimy). Agent zwykle nie dopyta - lukę wypełni najbardziej
prawdopodobną treścią. → *lekcje 3.1, 3.5*

## Structured output

Wymuszenie na modelu odpowiedzi zgodnej ze schematem, walidowanej automatycznie
zamiast parsowanej ręcznie. **Schemat gwarantuje kształt, nie sens**: odrzuci wartość
spoza słownika, przyjmie wartość dopuszczalną, ale merytorycznie błędną. → *lekcja 7.7*

## Subagent

Osobna sesja modelu z **własnym, pustym kontekstem**, uruchamiana przez agenta głównego
i zwracająca wynik. Definiowany plikiem w `.claude/agents/`. Służy do oddzielenia pracy
pochłaniającej kontekst od rozmowy, która ma zostać czysta. → *lekcja 6.3*

## Tag startowy

Znacznik gita wskazujący stan repozytorium ćwiczeniowego na początek danego labu,
w formacie `lab-<moduł>-<numer>-start`. Pozwala wejść w dowolny lab bez wykonywania
poprzednich. Odtwarza stan **techniczny**, nie zastępuje wiedzy z pominiętego ćwiczenia.
→ *README, sekcja „Repozytorium ćwiczeniowe"*

## Test charakterystyki (characterization test)

Test utrwalający **obecne** zachowanie kodu, zanim ktokolwiek go zmieni. Nie mówi
„tak ma być", tylko „tak jest w tej wersji, a zmiana wymaga świadomej decyzji".
Podstawowe narzędzie przy refaktoryzacji legacy bez testów. → *lekcja 4.5*

## Worktree

Drugi katalog roboczy tego samego repozytorium, z osobną gałęzią. Pozwala pracować
równolegle bez przełączania gałęzi. **To świeży checkout**: nie ma w nim niczego
z `.gitignore`, więc środowisko trzeba zapewnić osobno. → *lekcja 6.4*

---

## Skróty i komendy

| | |
|---|---|
| `/context` | co faktycznie siedzi w oknie kontekstowym, w rozbiciu na kategorie |
| `/clear` | czyści rozmowę; zostaje prompt systemowy, narzędzia i pliki kontekstowe |
| `/compact` | streszcza rozmowę zamiast ją czyścić; kosztuje, bo model czyta całość |
| `/usage` | zużycie i pasek limitów planu |
| `/model`, `/effort` | zmiana modelu i poziomu wysiłku w sesji |
| `/hooks`, `/status` | co jest faktycznie załadowane i z których plików ustawień |
| `make gate` | bramka jakości: lint, testy, od modułu 8 także skan sekretów |
