# Zasady korzystania z AI w zespole

**Wersja szablonowa.** Ten plik jest punktem wyjścia, nie gotową polityką.
Sekcje oznaczone **[DO USTALENIA]** wymagają decyzji po stronie organizacji,
a części prawne - potwierdzenia z działem prawnym albo inspektorem ochrony danych.

Dokument dotyczy **pracy nad kodem**. Zasady dla AI w produkcie są w sekcji 6.

---

## 1. Kiedy wolno używać AI

| Zastosowanie | Status | Uwagi |
|---|---|---|
| Kod w repozytoriach wewnętrznych | ✅ | z zachowaniem reszty zasad |
| Analiza i refaktoryzacja istniejącego kodu | ✅ | testy zabezpieczające przed zmianą |
| Testy, dokumentacja, komunikaty commitów | ✅ | |
| Prototypy i eksperymenty | ✅ | |
| Kod obsługujący dane osobowe | ⚠️ | kod tak, **dane produkcyjne nie** |
| Kod w komponentach bezpieczeństwa (uwierzytelnianie, kryptografia, autoryzacja) | ⚠️ | wymaga przeglądu drugiej osoby, zawsze |
| Kod objęty umową z klientem zakazującą narzędzi zewnętrznych | ❌ | umowa do sprawdzenia **przed** rozpoczęciem |
| Repozytoria z kodem osób trzecich na licencji zakazującej | ❌ | |

**[DO USTALENIA]** Lista projektów i klientów, których umowy ograniczają użycie narzędzi AI.
Bez tej listy powyższe wiersze są teoretyczne.

---

## 2. Dane - co wolno, czego nie

### Nigdy, w żadnym narzędziu

- **Sekrety**: klucze API, hasła, tokeny, ciągi połączeń, klucze prywatne.
- **Dane osobowe**: imiona i nazwiska, adresy, PESEL, NIP osób fizycznych, e-maile,
  numery telefonów, dane z systemów produkcyjnych.
- **Dane klientów objęte umowami o poufności.**
- **Zawartość systemów produkcyjnych**: zrzuty baz, logi z danymi, wyniki zapytań.

To dotyczy **wszystkiego**, co trafia do modelu: promptów, plików kontekstowych,
załączonych plików, wyników komend uruchamianych przez agenta.

> Plik kontekstowy jest czytany w **każdej** sesji. Sekret w `CLAUDE.md` wychodzi
> przy pierwszym uruchomieniu agenta i przy każdym następnym.

### Do danych testowych

Obowiązuje generator danych syntetycznych, nie kopia produkcji. W tym repozytorium
robi to `seed.py` - deterministycznie, z syntetycznymi NIP-ami.

Anonimizacja kopii produkcyjnej jest trudniejsza, niż wygląda, i zwykle niepełna.
Generowanie od zera jest tańsze i bezpieczniejsze.

### Narzędzia publiczne a firmowe

| | Narzędzie publiczne (konto prywatne) | Narzędzie firmowe |
|---|---|---|
| Kod wewnętrzny | ❌ | ✅ |
| Pytania ogólne o język, bibliotekę, algorytm | ✅ | ✅ |
| Fragment kodu bez kontekstu biznesowego | **[DO USTALENIA]** | ✅ |
| Dane osobowe | ❌ | ❌ |

**[DO USTALENIA]** Które konta i plany są uznane za firmowe, kto je wydaje,
jak są rozliczane i co się dzieje przy odejściu pracownika.

---

## 3. RODO

Trzy pytania, na które trzeba mieć odpowiedź **przed** wdrożeniem narzędzia AI w zespole.
Odpowiedzi udziela dział prawny albo inspektor ochrony danych, nie zespół.

1. **Czy do narzędzia trafiają dane osobowe?** Jeżeli w promptach, plikach kontekstowych
   albo danych testowych są dane osób fizycznych - tak, niezależnie od tego,
   czy było to zamierzone.
2. **Jaka jest podstawa prawna i czy jest umowa powierzenia przetwarzania?**
   Dostawca narzędzia przetwarza dane w imieniu organizacji.
3. **Gdzie fizycznie trafiają dane i jak długo są przechowywane?**
   To rozstrzyga o wyborze endpointu: API dostawcy, chmura firmowa (Bedrock, Vertex, Foundry),
   instalacja własna.

**Praktyczna konsekwencja dla zespołu:** najprostszą drogą do zgodności jest
**nie wysyłać danych osobowych** - a nie ustalać, na jakiej podstawie wolno je wysyłać.
Zasady z sekcji 2 realizują minimalizację danych na poziomie, na którym da się ją egzekwować.

**[DO USTALENIA]** Wskazanie osoby odpowiedzialnej, rejestr czynności przetwarzania,
ocena skutków (DPIA), jeśli wymagana.

---

## 4. AI Act

Rozporządzenie UE o sztucznej inteligencji. Obowiązki zależą od **roli** i od **klasy ryzyka**,
a poszczególne części rozporządzenia stosuje się od różnych dat.

**Tego nie rozstrzyga się samodzielnie.** Poniżej struktura pytań do zadania prawnikom -
nie odpowiedzi.

| Pytanie | Dlaczego istotne |
|---|---|
| W jakiej roli występujemy: dostawca systemu AI czy podmiot stosujący? | od tego zależy cały zestaw obowiązków |
| Czy nasz produkt zawiera system AI, czy tylko używamy AI przy jego wytwarzaniu? | **to jest kluczowe rozróżnienie** |
| Jeżeli zawiera - do jakiej klasy ryzyka należy? | obowiązki rosną wraz z klasą |
| Czy użytkownik wchodzi w interakcję z systemem AI? | obowiązki informacyjne |
| Od kiedy stosuje się przepisy, które nas dotyczą? | harmonogram jest etapowy |

**Rozróżnienie, które rozstrzyga najwięcej:**

- **Używamy AI do wytwarzania oprogramowania** (agent pisze kod, który potem recenzujemy) -
  to jest narzędzie pracy. Powstały produkt nie staje się przez to systemem AI.
- **Nasz produkt zawiera model** (jak klasyfikator VAT z modułu 7) - tutaj zaczynają się
  obowiązki dotyczące samego produktu.

W tym repozytorium granica jest namacalna: cały kod poza `app/klasyfikacja_vat.py`
należy do pierwszej kategorii, a ten jeden moduł do drugiej.

**[DO USTALENIA]** Klasyfikacja każdego produktu, w którym używamy modelu,
z datą i osobą, która ją przeprowadziła.

---

## 5. Licencje

### Kod generowany

| Ryzyko | Co robimy |
|---|---|
| Kod podobny do istniejącego, objętego licencją | przy dłuższych, charakterystycznych fragmentach sprawdzamy, czy nie są cytatem |
| Niejasność co do praw autorskich do wygenerowanego kodu | **[DO USTALENIA]** - stanowisko organizacji |
| Zależność dodana przez agenta | **każda nowa zależność wymaga świadomej akceptacji** |

Ostatni wiersz jest jedyny, który da się wyegzekwować mechanicznie - i dlatego jest
najważniejszy. Agent, który „przy okazji" dodaje bibliotekę, dodaje też jej licencję,
jej zależności i jej podatności.

W tym repozytorium zasada jest w `CLAUDE.md`: *nie dopisuj zależności do
`requirements.txt` bez pytania.*

### Egzekwowanie

- Skan licencji zależności w CI.
- Blokada zmian w pliku zależności bez przeglądu.
- **[DO USTALENIA]** Lista licencji dopuszczonych i zakazanych.

---

## 6. AI w produkcie

Gdy model jest częścią działającego systemu, obowiązują dodatkowe zasady.
Wzorcem jest `app/klasyfikacja_vat.py`.

1. **Decyzje w kodzie, nie w modelu.** To, co da się rozstrzygnąć deterministycznie,
   rozstrzygamy bez modelu. Próg pewności jest liczbą porównywaną w kodzie.
2. **Wyjście modelu jest walidowane** względem schematu - i dodatkowo w kodzie,
   bo schemat gwarantuje kształt, nie sens.
3. **Wejście od użytkownika jest niezaufane.** Opis pozycji faktury pochodzi
   od kontrahenta i jest wektorem wstrzyknięcia promptu. Obrona jest w kodzie,
   nie w treści promptu.
4. **Prompt jest kodem**: w repozytorium, przez review, z ewaluacją na oznaczonym zbiorze
   uruchamianą przy zmianie promptu albo modelu. Golden set offline testuje kod wokół
   modelu, nie prompt.
5. **Widać, kto podjął decyzję.** Pole `zrodlo` w wyniku: reguła, model czy wartość domyślna.
6. **Jest ścieżka do człowieka.** Pozycja z flagą `wymaga_weryfikacji` jest **oznaczona**.
   Sama flaga nie zatrzymuje użycia wyniku - o tym, czy pozycja trafi na fakturę,
   decyduje proces, nie flaga.

**[DO USTALENIA]** Kto obsługuje kolejkę weryfikacji i w jakim czasie.

### Serwery MCP i narzędzia zewnętrzne

Serwer MCP dostarcza modelowi **tekst**, który działa na niego jak instrukcja:
opisy narzędzi, nazwy zasobów, zwracane dane. Niezaufany serwer może sterować agentem.

- Podłączamy wyłącznie serwery z listy zatwierdzonych.
- Nowy serwer wymaga przeglądu: kto go utrzymuje, do czego ma dostęp, co zwraca.
- Nieużywane serwery wyłączamy - zużywają kontekst i poszerzają powierzchnię ataku.

**[DO USTALENIA]** Lista zatwierdzonych serwerów MCP i osoba, która ją utrzymuje.

---

## 7. Code review po nowemu

Rola recenzenta się zmienia: kodu jest więcej, powstaje szybciej, a autor zna go płycej.

### Co się nie zmienia

Odpowiedzialność. **Autorem zmiany jest człowiek, który ją zgłosił** - niezależnie od tego,
ile z niej napisał model. „Tak wygenerował agent" nie jest odpowiedzią na uwagę w review.

### Na co patrzeć uważniej niż kiedyś

| Obszar | Dlaczego |
|---|---|
| Zakres diffa | agent „poprawia przy okazji"; zmiany spoza zakresu są najczęstszym problemem |
| Zmienione testy | test zmieniony po napisaniu kodu nie sprawdza wymagania |
| Usunięte warunki brzegowe | „uproszczenie" bywa usunięciem reguły biznesowej |
| Nowe zależności | patrz sekcja 5 |
| Kod obsługujący dane wejściowe | walidacja, autoryzacja per zasób, sklejanie zapytań |
| Obsługa błędów | agent lubi `except: pass` |

### Czego review nie wykryje

Review sprawdza, czy kod robi to, co mówi. **Nie sprawdza, czy „to" jest właściwe.**
Błędne założenie przyjęte na etapie specyfikacji przechodzi przez review niezauważone -
bo kod jest wewnętrznie spójny.

Dlatego specyfikacja (moduł 3) jest osobnym artefaktem i osobno przechodzi przez review.

### Deterministyczne bramki przed review

Wszystko, co da się sprawdzić mechanicznie, **ma być sprawdzone przed** review:
format, lint, testy, skan sekretów, skan licencji. Recenzent ma czytać logikę,
a nie wyłapywać nieużywane importy.

W tym repozytorium: `make gate` lokalnie (hook `Stop`) i w CI.

---

## 8. Dokumentowanie użycia AI

### Co zapisujemy

| Gdzie | Co |
|---|---|
| Komunikat commita | **nic o narzędziu** - liczy się, co i dlaczego zmieniono |
| Specyfikacja | założenia i otwarte pytania (tu ląduje to, czego model nie wiedział) |
| `docs/` | decyzje architektoniczne wraz z odrzuconymi wariantami |
| Opis pull requesta | zakres zmiany i sposób weryfikacji |

**[DO USTALENIA]** Czy organizacja wymaga oznaczania zmian tworzonych z udziałem AI.
Jeżeli tak - w jakiej formie i po co. Znacznik, którego nikt nie czyta, jest kosztem bez wartości.

### Czego nie robimy

- Nie wklejamy odnośników do sesji ani transkryptów do commitów i pull requestów.
  Są bezużyteczne dla każdego poza autorem, a raz wypchnięte zostają na zawsze.
- Nie traktujemy „wygenerowane przez AI" jako informacji o jakości. Jakość mierzą
  testy i review.

---

## 9. Egzekwowanie

Zasada bez mechanizmu jest życzeniem. Zestawienie, co czym egzekwujemy:

| Zasada | Mechanizm | Gdzie |
|---|---|---|
| Brak sekretów w repo | skan sekretów | `make gate`, CI |
| Format i lint | hook `PostToolUse`, lint w bramce | `.claude/settings.json` |
| Testy przed zakończeniem pracy | hook `Stop` | `.claude/settings.json` |
| Niebezpieczne komendy | hook `PreToolUse` | `.claude/settings.json` |
| Brak odczytu `.env` przez agenta | `permissions.deny` | `.claude/settings.json` |
| Przegląd bezpieczeństwa diffa | skill `/przeglad-bezpieczenstwa` - procedura, ktoś musi ją wywołać | `.claude/skills/` |
| Konwencje projektu | `CLAUDE.md` | repozytorium |
| Nowe zależności | review + `CLAUDE.md` | proces |

Ostatni wiersz jest tu istotny: część zasad zostaje procesem, bo **nie da się** ich
wyegzekwować mechanicznie. To jest w porządku, pod warunkiem że wiadomo które.

---

## 10. Przegląd tego dokumentu

**[DO USTALENIA]** Kto i jak często. Narzędzia i przepisy zmieniają się szybciej
niż dokumenty - polityka sprzed roku bywa myląca bardziej niż jej brak.

Sugestia: przegląd co kwartał, z tym samym rygorem co przegląd zależności.
