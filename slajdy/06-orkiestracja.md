---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 6'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Orkiestracja wieloagentowa

## Moduł 6 · dzień 2

Worktree, subagenci, podział zadań, budżety tur.

<!--
CO POWIEDZIEĆ: Ten moduł jest o dzieleniu pracy między agentów tak, żeby scalenie
było tanie. Połowa modułu to umiejętność zrobienia tego, druga połowa to wiedza,
kiedy tego nie robić.
CZAS: ~1 min
-->

---

<!-- _class: haslo -->

## Trzech agentów to trzykrotny koszt i **jedno scalenie**, którego wcześniej nie było.

Uruchomienie trzech agentów nie daje trzykrotnego przyspieszenia.

<!--
CO POWIEDZIEĆ: To jest teza całego modułu. Równoległość nie jest darmowa: płacisz
trzy razy za tokeny i dokładasz sobie pracę, której sekwencyjnie w ogóle by nie było.
Musi się opłacić, a nie zawsze się opłaca.
CZAS: ~1 min
-->

---

# Kiedy równoległość ma sens

| Opłaca się, gdy | Nie opłaca się, gdy |
|---|---|
| zadania są **niezależne**: wynik jednego nie jest wejściem drugiego | zadania dotyczą tego samego pliku (scalenie zje zysk) |
| każde wymaga **czytania** dużej ilości kodu (to jest ta część, która trwa) | jedno zadanie zależy od decyzji podjętej w drugim |
| **konflikty da się przewidzieć**: wiesz z góry, gdzie się zetkną | całość jest krótsza niż narzut na przygotowanie środowisk |

> Jeżeli nie potrafisz z góry powiedzieć, gdzie będzie konflikt, **podział jest zły**.
> Wróć do kartki, zanim odpalisz agentów.

<!--
CO POWIEDZIEĆ: Prawa kolumna jest ważniejsza od lewej. Najdroższy błąd to nie zły
prompt, tylko zrównoleglenie czegoś, co było sekwencyjne. Reguła na dole jest
operacyjna: to test, który robi się na kartce w minutę.
NA CO UWAŻAĆ: Sala instynktownie szuka miejsc, gdzie „da się puścić równolegle".
Odwróć to pytanie: gdzie te zadania się zetkną?
CZAS: ~3 min
-->

---

# Orkiestrator i wykonawcy

<div class="przeplyw">
  <div class="krok wyroz">Orkiestrator<small>podział, granice, scalanie</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Wykonawcy<small>osobny kontekst, jedno zadanie</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Streszczenia<small>nie transkrypty</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Scalanie<small>decyzje wracają do ciebie</small></div>
</div>

Wykonawca odpowiada za **jedno zadanie, od początku do zielonej bramki**.
Nie odpowiada za to, co robią pozostali.

**Podział musi być rozstrzygnięty przed startem.** Wykonawcy nie widzą się nawzajem
i nie dogadają się w trakcie: wszystko, czego potrzebują, jest w zleceniu.

<!--
CO POWIEDZIEĆ: Orkiestrator nie pisze kodu w zadaniach. Jego robota to granice
i scalanie. Jeśli zaczyna pisać kod, przestaje panować nad całością.
NA CO UWAŻAĆ: „A niech się dogadają w trakcie" nie istnieje. Każda informacja,
której wykonawca nie dostał w zleceniu, jest informacją, którą sobie dopowie.
CZAS: ~2 min
-->

---

# Dwie formy równoległości

| | Subagenci w jednej sesji | Osobne sesje w worktree |
|---|---|---|
| Kontekst | osobny per subagent | osobny per sesja |
| Pliki | ten sam katalog (o ile nie ma izolacji) | osobne katalogi |
| Konflikty przy pisaniu | **realne** | nie ma, są dopiero przy scalaniu |
| Kto orkiestruje | sesja główna | ty |
| Widzisz przebieg | streszczenie na końcu | cały, w osobnym terminalu |

Trzecia forma to połączenie: subagent z `isolation: worktree` dostaje własny katalog,
a mimo to jest orkiestrowany przez sesję główną.

<!--
CO POWIEDZIEĆ: Kluczowy wiersz to trzeci. Subagenci w jednym katalogu mogą sobie
nadpisać pliki w trakcie pracy. Worktree przesuwa konflikt na moment scalania,
czyli tam, gdzie git umie go pokazać.
PYTANIE Z SALI: „To po co w ogóle subagenci bez worktree?" Bo nie każde zadanie
pisze do plików. Inwentaryzacja, przeszukanie kodu, przegląd - tam konfliktu nie ma.
CZAS: ~2 min
-->

---

# Po co jest subagent

<div class="przeplyw">
  <div class="krok">Zlecenie<small>tylko to, co mu dasz</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Pusty kontekst<small>nie widzi twojej rozmowy</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Logi, grep, treść plików<small>zostają u niego</small></div>
  <div class="strzalka">→</div>
  <div class="krok dobry">Streszczenie<small>kilkanaście linii wraca</small></div>
</div>

Do sesji głównej wraca **streszczenie, nie transkrypt**.

> To jest główny powód, dla którego subagenci istnieją: oddzielenie pracy pochłaniającej
> kontekst od rozmowy, która musi zostać czysta.

<!--
CO POWIEDZIEĆ: Subagent to nie jest „drugi pracownik". To jest sposób na to, żeby
czytanie trzydziestu plików nie wylądowało w twoim oknie kontekstowym. Przyrost
w sesji głównej jest taki sam, czy przeczytał trzy pliki, czy trzydzieści.
NA CO UWAŻAĆ: Pusty kontekst znaczy też, że subagent nie wie nic z waszej rozmowy
sprzed dziesięciu minut. To najczęstsza przyczyna bezużytecznego wyniku.
CZAS: ~3 min
-->

---

# Definicja w repozytorium

`.claude/agents/<nazwa>.md`

```yaml
---
name: migrator
description: Kiedy sięgnąć po tego agenta i do czego on nie służy.
tools: Read, Edit, Write, Grep, Glob, Bash
model: sonnet
isolation: worktree
maxTurns: 25
---
```

- `isolation: worktree` - własny, tymczasowy katalog; twój checkout nietknięty
- `maxTurns` - twardy budżet tur; subagenta **nie widzisz w trakcie pracy**
- `description` - kryterium wyboru **dla modelu**, nie dokumentacja dla człowieka

Limity: **20** subagentów jednocześnie, **3** poziomy zagnieżdżenia.
Sensowny sufit dla człowieka, który ma potem przeczytać wyniki: trzy-cztery.

<!--
CO POWIEDZIEĆ: Agent jest plikiem w repozytorium, czyli przechodzi przez review
jak każdy inny artefakt. Trzy pola z listy decydują o tym, czy jest bezpieczny.
NA CO UWAŻAĆ: Opis, który mówi wyłącznie, co agent robi, jest wadliwy. Model czyta
go, decydując, czy sięgnąć po agenta sam. Zdanie „do czego NIE służy" robi tu
najwięcej roboty.
PYTANIE Z SALI: „Który model dostanie subagent?" Kolejność: parametr per wywołanie,
potem `model` z frontmattera, potem `CLAUDE_CODE_SUBAGENT_MODEL`, na końcu model
sesji głównej.
CZAS: ~3 min
-->

---

# Format wyniku: narzuć go

```text
ZAKRES: <co miało być zmienione>
ZMIENIONE: <liczba> wystąpień w <liczba> plikach
  - ścieżka:linia - opis zmiany
POMINIĘTE: <co wymaga decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ pierwsze 5 linii błędu)
RYZYKA: <co może się zepsuć, czego nie sprawdziłem>
```

Plus **limit długości**. W labie: 40 linii.

> Sekcja `POMINIĘTE` daje subagentowi trzecie wyjście obok „zrobiłem wszystko po swojemu"
> i „stanąłem bez wyjaśnienia". Jest jedyną rzeczą, która chroni przed cichym
> rozstrzygnięciem.

<!--
CO POWIEDZIEĆ: Bez narzuconego formatu trzy raporty są nieporównywalne i musisz je
czytać jak eseje. Z formatem porównujesz je w kolumnie. `BRAMKA` jako osobne pole
wymusza uruchomienie: bez niego „gotowe" znaczy „skończyłem pisać".
NA CO UWAŻAĆ: Limit długości nie jest kosmetyką. Streszczenie na trzysta linii to
transkrypt w przebraniu i cały zysk kontekstowy znika.
CZAS: ~3 min
-->

---

# Worktree to świeży checkout

Osobny katalog roboczy z własnym branchem. **Nie ma w nim niczego z `.gitignore`**:
ani `.venv`, ani `.env`, ani lokalnych baz.

| Zasób | Problem | Rozwiązanie |
|---|---|---|
| Zależności | brak `.venv` w nowym worktree | instalacja per worktree albo współdzielony interpreter |
| Baza testowa | dwa worktree, jedna baza = wyścig | baza per worktree albo plik SQLite w katalogu |
| Porty | dwa `uvicorn` na 8000 | port per worktree |
| Cache narzędzi | zwykle bezpieczny do współdzielenia | zostawić |

`.worktreeinclude` kopiuje pliki spoza gita. Kopiuje **tylko** te, które pasują
do wzorca **i** są gitignorowane.

<!--
CO POWIEDZIEĆ: Pierwsze `make test` w świeżym worktree wywali się na braku `.venv`.
To nie jest awaria konfiguracji, to jest właściwość worktree. Decyzję podejmuje się
raz, świadomie, dla całego zespołu.
NA CO UWAŻAĆ: Dwie linie do `.gitignore`, zanim ktokolwiek użyje worktree:
`.claude/worktrees/` i `.claude/settings.local.json`. Bez pierwszej pliki z worktree
pokażą się jako nieśledzone w głównym checkoucie. Bez drugiej czyjeś osobiste
ustawienie `baseRef` zacznie obowiązywać cały zespół.
PYTANIE Z SALI: „A baza w repozytorium kursu?" Plik SQLite leży w katalogu worktree,
a `python seed.py` odtwarza ją od zera. Tu akurat problemu nie ma.
CZAS: ~3 min
-->

---

# Pułapka: ścieżki hooków nie idą za worktree

<div class="rozgalezienie">
  <div class="galaz nie">
    <span class="etykieta">źle</span>
    Bramka woła <code>${CLAUDE_PROJECT_DIR}</code><br>
    <small>testuje <strong>główny checkout</strong> i świeci na zielono dla kodu, którego nikt nie zmienił</small>
  </div>
  <div class="galaz tak">
    <span class="etykieta">dobrze</span>
    Bramka czyta pole <code>cwd</code> ze stdin<br>
    <small>testuje worktree, w którym naprawdę trwa praca</small>
  </div>
</div>

`${CLAUDE_PROJECT_DIR}` wskazuje katalog, w którym **wystartowała sesja**, i nie zmienia się
po wejściu w worktree. Ścieżka worktree przychodzi do hooka w polu **`cwd`**.

Dlatego hook bramki z modułu 5 czyta `cwd`. Sprawdź swój dzisiaj.

<!--
CO POWIEDZIEĆ: To jest najgroźniejszy błąd z tego modułu, bo wygląda jak sukces.
Zielona bramka, którą dostajesz, dotyczy kodu, którego nikt nie tknął.
NA CO UWAŻAĆ: To wyjdzie dopiero w labie 6.1, na hooku `bramka.sh` z labu 5.1.
Zapowiedz to teraz, żeby wiedzieli, czego szukać.
CZAS: ~3 min
-->

---

# Cztery osie podziału zadania

| Oś | Przykład | Ryzyko konfliktu |
|---|---|---|
| **Po plikach** | A dotyka `rabaty.py`, B `raporty.py` | bardzo niskie |
| **Po warstwach** | A testy, B dokumentacja, C kod | niskie |
| **Po funkcjach** | trzy niezależne endpointy | średnie |
| **Po etapach** | A pisze, B recenzuje | **sekwencyjne, nie równoległe** |

**Recenzent nie jest wykonawcą równoległym** - recenzuje kod, który jeszcze się zmienia.

| Konflikt | Koszt |
|---|---|
| w jednej linii, przewidziany | minuta |
| w dwustu liniach, nieprzewidziany | wieczór |

<!--
CO POWIEDZIEĆ: Nie unikamy konfliktu, tylko go lokalizujemy. Wypisz przed startem
pliki, których dotknie każde zadanie, część wspólną zaznacz w zleceniu obu wykonawców,
a scalaj od zadania o najmniejszym zasięgu.
NA CO UWAŻAĆ: „Dotykają tego samego pliku" to za mało, żeby przewidzieć konflikt.
Git konfliktuje na nakładających się zmianach, nie na tym samym pliku.
CZAS: ~3 min
-->

---

# Agent kręcący się w kółko: pięć objawów

| Objaw | Co to znaczy |
|---|---|
| Ta sama komenda trzeci raz z drobną zmianą | nie rozumie błędu |
| „Spróbuję innego podejścia" po raz trzeci | brakuje mu informacji, której nie ma w repo |
| Czytanie kolejnych plików bez zmian w kodzie | szuka czegoś, czego nie ma |
| Rosnące, coraz bardziej ogólne komunikaty | stracił kontakt z zadaniem |
| **Modyfikacja testu, żeby przeszedł** | zadanie jest niewykonalne tak, jak je postawiłeś |

Ostatni jest najgroźniejszy, bo **wygląda na sukces**.

<!--
CO POWIEDZIEĆ: To nie jest awaria. To normalny stan, gdy zadanie jest źle postawione
albo agent napotkał przeszkodę, której nie umie nazwać.
NA CO UWAŻAĆ: Ostatni wiersz przechodzi przez bramkę. Zielone testy po zmianie testu
to nie jest zielona bramka, to jest przesunięta poprzeczka. Przy przeglądzie diffu
patrz najpierw, czy testy się nie zmieniły.
CZAS: ~2 min
-->

---

# Twarde limity i co po przerwaniu

| Mechanizm | Gdzie |
|---|---|
| `maxTurns` | frontmatter subagenta |
| `--max-budget-usd` | flaga CLI, **tylko w trybie `-p`** |
| `timeout` | pole hooka |
| `Esc` | ty, natychmiast |

Po przerwaniu **nie „spróbuj jeszcze raz"**: to samo zlecenie da ten sam wynik.
Brakuje informacji → dopisz ją do zlecenia albo do `CLAUDE.md`.
Zadanie źle postawione → podziel je albo rozstrzygnij sam to, czego agent nie może.

Zasada w treści agenta to prośba. `maxTurns` to egzekucja - jak hook z modułu 5.

<!--
CO POWIEDZIEĆ: `maxTurns` na subagencie jest ważniejszy niż na sesji głównej, bo
sesję główną przerwiesz `Esc`, a subagenta nie widzisz w trakcie. Bez limitu tur
zużyje budżet i wróci ze streszczeniem, którego nie da się użyć.
NA CO UWAŻAĆ: `--max-budget-usd` działa tylko z `-p`. W sesji interaktywnej nie ma
go czym zastąpić poza `Esc` i własną uwagą.
CZAS: ~3 min
-->

---

<!-- _class: lab -->

# Laby 6.1 i 6.2

**Zanim cokolwiek odpalisz** (`origin/main` to stan z modułu 1):

```bash
echo '{"worktree": {"baseRef": "head"}}' > .claude/settings.local.json
```

**Lab 6.1 (~60 min)** - trzy worktree, trzy zadania, **jeden zaplanowany konflikt**
w `app/rabaty.py`. Migracja `datetime.utcnow()`: **pięć wystąpień w czterech plikach**.
Kryterium akceptacji: ostrzeżeń z **4 na 0**, `make gate` zielone, **47 testów**.

**Lab 6.2 (~20 min)** - `.claude/agents/migrator.md` z `isolation: worktree`,
`maxTurns: 25` i narzuconym formatem wyniku. `/context` przed i po.

<!--
CO POWIEDZIEĆ: Konflikt w labie 6.1 jest celowy i wiecie z góry, gdzie będzie.
Rozwiązanie polega na wzięciu obu zmian: kodu z zadania C i komentarza z zadania A.
`git checkout --ours` jest szybkie i kasuje połowę pracy.
NA CO UWAŻAĆ: Domyślne `baseRef: "fresh"` dałoby worktree bez testów, bez `CLAUDE.md`
i bez celu `gate` w `Makefile`. Kwadrans szukania przyczyny. To samo ustawienie jest
potrzebne w labie 6.2, a plik jest nieśledzony, więc `git stash -u` go zabierze.
PYTANIE Z SALI: „Czy ta równoległość się opłaciła?" Przy trzech krótkich zadaniach
raczej nie: narzut jest stały. Opłaca się, gdy samo czytanie kodu w każdym zadaniu
trwa kwadrans. Wiedza, kiedy tego nie robić, jest warta tyle samo.
CZAS: ~2 min
-->
