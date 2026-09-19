# Biblioteka promptów

Prompty użyte w kursie, zebrane w jednym miejscu. Przy każdym **dlaczego jest tak
sformułowany** - to jest ważniejsze niż sama treść, bo swoje zadania będziesz formułował sam.

---

## Przeciw halucynacji

### Wymuszenie cytatu

```
Znajdź w tym repozytorium funkcję o nazwie <nazwa>. Zacytuj jej sygnaturę razem
ze ścieżką pliku i numerem linii. Jeżeli takiej funkcji nie ma, napisz dokładnie:
"nie ma takiej funkcji" i nie dodawaj nic więcej.
```

**Dlaczego działa:** „wyjaśnij, jak działa X" zakłada istnienie X i model odpowiada
na pytanie, które dostał. „Znajdź i zacytuj" zleca czynność **weryfikowalną**
i z góry opisuje, co zrobić przy pustym wyniku.

### Reguła ogólna

```
Każde twierdzenie o tym kodzie popieraj ścieżką pliku i numerem linii,
które sprawdziłeś.
```

Do wpisania raz do `CLAUDE.md` zamiast powtarzania w każdym prompcie.

---

## Przeciw dopowiadaniu

### Pytania zamiast odpowiedzi

```
Zanim cokolwiek zaproponujesz: przeczytaj kod i wypisz listę pytań, na które musisz
znać odpowiedź, żeby to zaimplementować poprawnie. Przy każdym pytaniu podaj,
którego miejsca w kodzie dotyczy (plik + linia).
Nie odpowiadaj na te pytania. Nie proponuj rozwiązania.
```

**Najtańsza technika w całym kursie.** Zamienia osiem milczących rozstrzygnięć
w osiem pytań na ekranie.

### Rozdzielenie faktów od założeń

```
Podziel odpowiedź na dwie sekcje:
USTALONE - co sprawdziłeś w kodzie, z plikiem i numerem linii.
ZAŁOŻONE - co przyjąłeś, bo nie było tego w kodzie ani w moim poleceniu.
Jeżeli sekcja ZAŁOŻONE jest pusta, to znaczy, że czegoś nie zauważyłeś.
```

Ostatnie zdanie jest konieczne - bez niego model chętnie deklaruje, że niczego nie założył.

### Granice zakresu

```
Zakres: tylko <pliki>.
Nie zmieniaj: <pliki>.
Jeżeli zadanie wymaga zmiany poza zakresem - zatrzymaj się i powiedz, czego potrzebujesz.
Nie rozszerzaj zakresu samodzielnie.
```

Agent domyślnie „naprawia po drodze". Bez granic zmiana docelowa tonie wśród pięciu
poprawek, o które nikt nie prosił.

---

## Specyfikacja

```
Napisz specyfikację do pliku specyfikacje/<nazwa>.md. Struktura:
1. Wymaganie biznesowe - jednym akapitem, językiem biznesu.
2. Zakres - co robimy i czego świadomie NIE robimy w tej iteracji.
3. Reguły - ponumerowane, każda jednoznaczna.
4. Kryteria akceptacji - minimum 6 przypadków jako konkretne liczby
   (dane wejściowe → oczekiwany wynik), łącznie z przypadkami brzegowymi.
5. Ryzyka - co może się zepsuć poza obszarem zmiany, z plikami i liniami.
6. Otwarte pytania - czego nadal nie wiemy.

Zasady:
- Każde twierdzenie o istniejącym kodzie popieraj plikiem i numerem linii.
- Jeżeli coś przyjmujesz, a nie zostało rozstrzygnięte - wypisz to w sekcji
  "Otwarte pytania", nie w regułach.
- Nie pisz kodu.
```

---

## Praca w legacy

### Zachowanie zamiast kodu

```
Przeczytaj <funkcja> w <plik>. Opisz jej zachowanie jako listę reguł w formie:
"JEŻELI <warunek wejściowy> TO <obserwowalny skutek na wyniku>".
Nie opisuj struktury kodu. Nie używaj nazw zmiennych lokalnych.
Przy każdej regule podaj numer linii, z której ją odczytałeś.
```

**Różnica:** „funkcja iteruje po pozycjach i sumuje wartości" to przepisany kod.
„JEŻELI pozycja ma cenę promocyjną, TO nie dostaje rabatu" to reguła - da się ją
potwierdzić u biznesu i zamienić w test.

### Zaskoczenia

```
Które zachowania tej funkcji zaskoczyłyby programistę, który zna domenę,
ale nie zna tego kodu? Wypisz je z numerami linii, od najbardziej zaskakującego.
```

Wydobywa dokładnie te miejsca, gdzie siedzi nieudokumentowana decyzja.
Kod nudny nikogo nie zaskakuje.

### Reguła czy błąd

```
Dla każdego zaskakującego zachowania powiedz, czy to:
(a) celowa reguła biznesowa, (b) błąd, (c) nie da się rozstrzygnąć z kodu.
Przy (a) i (b) podaj, JAKI DOWÓD w repozytorium to potwierdza.
Jeżeli dowodu nie ma - klasyfikacja to (c).
```

Ostatnie zdanie jest całym promptem. Bez niego dostaniesz stanowcze „to jest celowa reguła"
bez cienia dowodu.

### Testy charakterystyki

```
Napisz testy charakterystyki dla <funkcja>.

Zasady:
- Testy utrwalają zachowanie, które funkcja ma TERAZ - nie to, które uważasz za poprawne.
- Wartości oczekiwane wylicz, URUCHAMIAJĄC funkcję, nie z własnych obliczeń.
- Jeżeli wartość wygląda na błędną, ZAPISZ JĄ TAKĄ, JAKA JEST, i dodaj komentarz
  "# WYGLADA NA BLAD - do potwierdzenia u biznesu".
- Nie zmieniaj ani jednej linii w <katalog>.
```

### Refaktoryzacja zachowawcza

```
To jest refaktoryzacja czysto strukturalna:
- te same wejścia mają dawać te same wyjścia CO DO GROSZA,
- kolejność i treść ostrzeżeń musi zostać identyczna,
- NIE zmieniaj żadnego zachowania,
- NIE zmieniaj testów.
Jeżeli po drodze uznasz, że coś jest błędem - NAPISZ MI O TYM OSOBNO, ale nie poprawiaj.
```

---

## Inwentaryzacja i migracja

### Fakty bez ocen

```
Zrób inwentaryzację problemów w <katalog>. Dla każdego podaj: plik, numer linii,
rodzaj problemu, jednozdaniowy opis.
Nie proponuj poprawek. Nie oceniaj ważności ani pilności.
Każda pozycja musi mieć numer linii, który sprawdziłeś.
```

Ocena ryzyka należy do ciebie - agent nie zna twojego biznesu ani twojego kalendarza.

### Klasyfikacja migracji

```
Wypisz wszystkie wystąpienia <wzorzec> z plikami i numerami linii, policz je
i powiedz, w których zamiana jest równoważna, a w których zmienia zachowanie.
Uzasadnij OSOBNO dla każdego miejsca - nie odpowiadaj zbiorczo.
Dopiero potem zmieniaj.
```

„Wszystkie cztery to prosta zamiana" jest typową i zwykle błędną odpowiedzią.

---

## Praca z hookami i skillami

### Hook blokujący

```
Napisz .claude/hooks/<nazwa>.sh dla zdarzenia <zdarzenie>.
Czyta z stdin JSON, bierze <pole> przez jq.
Kod wyjścia 2 = blokada, komunikat na stderr. W przeciwnym razie 0.
Lista wzorców ma być KRÓTKA i OCZYWISTA - maksymalnie 7 pozycji,
uzasadnij każdą jednym zdaniem.
```

### Bramka na `Stop` z bezpiecznikiem

```
UWAGA - bezpiecznik. Exit 2 na Stop każe modelowi pracować dalej. Hook, który zawsze
zwraca 2 przy czerwonej bramce, zapętla sesję. Dokumentacja nie przewiduje pola
chroniącego przed tym - bezpiecznik musisz napisać sam.

Maszyna stanów:
  bramka zielona            -> SKASUJ znacznik, exit 0
  czerwona, brak znacznika  -> ustaw znacznik, exit 2, wynik na stderr
  czerwona, jest znacznik   -> exit 0 + JSON {"systemMessage": "..."}

Znacznik: plik w katalogu z .scratchpad_dir, w nazwie .session_id.
Pole .scratchpad_dir BYWA NIEOBECNE - zrób ścieżkę zapasową ${TMPDIR:-/tmp}.
Bramkę uruchom w katalogu z pola .cwd, NIE w ${CLAUDE_PROJECT_DIR}.
```

---

## Orkiestracja

### Format wyniku subagenta

```
Zwracasz streszczenie, nie transkrypt. Dokładnie te sekcje, nic więcej:

ZAKRES: <co miało być zmienione>
ZMIENIONE: <liczba> wystąpień w <liczba> plikach
  - ścieżka:linia - opis zmiany
POMINIĘTE: <co wymaga decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ pierwsze 5 linii błędu)
RYZYKA: <co może się zepsuć, czego nie sprawdziłem>

Limit: 40 linii.
```

Sekcja `POMINIĘTE` jest najważniejsza - to jedyne miejsce, w którym agent ma prawo
powiedzieć „tego nie ruszyłem, bo wymaga decyzji".

---

## AI w produkcie

### Projekt warstw

```
Zaprojektuj (bez pisania kodu) <funkcjonalność> z użyciem modelu.
Wymaganie: system ma być przewidywalny. To samo wejście ma dać to samo wyjście,
a przypadek niepewny ma trafić do człowieka, a nie dostać strzał modelu.
Zaproponuj podział na warstwy i powiedz, KTÓRA WARSTWA PODEJMUJE KTÓRĄ DECYZJĘ.
```

Jeśli odpowiedź ma dwie warstwy (model + walidacja), dopytaj o trzecią: **decyzję progową
w kodzie**. Model, który sam decyduje, czy jest wystarczająco pewny, jest modelem bez nadzoru.

### Obrona przed wstrzyknięciem

```
Dodaj obronę przed wstrzyknięciem promptu. W kodzie, nie w treści promptu.
1. Limit długości wejścia.
2. Lista wyrażeń regularnych wykrywających tekst wyglądający na instrukcję dla modelu.
3. Podejrzane wejście NIE IDZIE DO MODELU - wraca wartość domyślna z flagą do weryfikacji.
NIE próbuj "czyścić" ani neutralizować wejścia. Kieruj je do człowieka.
```

---

## Jak formułować własne prompty

Pięć wzorców, które powtarzają się we wszystkich powyższych:

| Wzorzec | Przykład |
|---|---|
| **Żądaj dowodu** | „podaj plik i numer linii, który sprawdziłeś" |
| **Opisz przypadek pusty** | „jeżeli nie ma - napisz dokładnie: nie ma takiej funkcji" |
| **Rozdziel czynności** | „wypisz pytania, nie odpowiadaj na nie" |
| **Postaw granice** | „zakres: tylko X; nie zmieniaj Y; zatrzymaj się i powiedz" |
| **Narzuć format wyniku** | „dokładnie te sekcje, nic więcej, limit 40 linii" |

Czego unikać:

| Nie pisz | Bo | Napisz |
|---|---|---|
| „w razie potrzeby dodaj…" | model zawsze uzna, że potrzeba | wprost, czy ma dodać |
| „zrób to porządnie" | nieweryfikowalne | konkretne kryterium |
| „obsłuż przypadki brzegowe" | wymyśli swoje | wymień które |
| „jak w reszcie projektu" | w projekcie są trzy style | wskaż plik wzorcowy |
| „na razie uproszczona wersja" | nie wiadomo, co uproszczone | wypisz, czego **nie** robimy |
