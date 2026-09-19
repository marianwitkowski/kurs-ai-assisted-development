---
marp: true
theme: kurs
paginate: true
footer: 'AI Assisted Development · Moduł 5'
---

<!-- _class: tytul -->
<!-- _paginate: false -->

# Agent i deterministyczne bramki

## Moduł 5 · dzień 2

Małe kroki, które da się cofnąć. Hooki, kody wyjścia, bramka na `Stop`.
Skill jako artefakt zespołowy.

**Reguła w `CLAUDE.md` to prośba. Hook to egzekucja.**

<!--
CO POWIEDZIEĆ: moduł 2 dał modelowi kontekst i prośby. Dziś zamieniamy trzy z tych próśb
na mechanizmy, których model nie może zignorować, i pakujemy workflow w plik, który
przechodzi przez review jak kod.
CZAS: ~1 min
-->

---

# Wąskim gardłem nie jest kod, tylko weryfikacja

| Krok | Diff | Weryfikacja | Koszt pomyłki |
|---|---|---|---|
| jedna funkcja + test | ~50 linii | czytasz całość | minuty |
| jeden moduł | ~300 linii | czytasz wyrywkowo | godzina |
| „zrób tę funkcjonalność" | 1500+ linii | nie weryfikujesz | dni, często na produkcji |

**Krok kończy się tam, gdzie repo nadaje się do commita.**

Nie umiesz napisać sensownego komunikatu commita? Krok był za duży
albo obejmował dwie różne rzeczy.

<!--
CO POWIEDZIEĆ: koszt weryfikacji rośnie szybciej niż liniowo z wielkością diffa.
Agent generuje szybciej, niż ty czytasz, więc to ty jesteś wąskim gardłem, a nie model.
Wielkość kroku dobieraj do tego, ile jesteś w stanie przeczytać.
NA CO UWAŻAĆ: sala czyta trzeci wiersz jako przesadę. Zapytaj, kto w ostatnim miesiącu
zaakceptował diff, którego nie przeczytał w całości.
PYTANIE Z SALI: „A jeśli zadanie naprawdę jest duże?" Wtedy dzielisz je na kroki
po jednym commicie. Test jest prosty: jeśli komunikat commita brzmi „różne poprawki",
to były dwa kroki, nie jeden.
CZAS: ~3 min
-->

---

# Cztery narzędzia kontroli

| Narzędzie | Kiedy | Co daje |
|---|---|---|
| `git diff` | po każdym kroku | jedyny wiarygodny opis tego, co się stało |
| `git commit` | na końcu kroku | punkt, do którego można wrócić |
| review | przed commitem | twoja odpowiedzialność, nie agenta |
| `/rewind`, `Esc Esc` | gdy poszło źle | cofnięcie rozmowy **i** kodu |

**`git diff` bije opis agenta.** „Dodałem funkcję i testy" bywa prawdziwe
i niekompletne jednocześnie. Diff nie ma takiej możliwości.

<!--
CO POWIEDZIEĆ: podsumowanie agenta jest streszczeniem, a nie protokołem. Diff jest
protokołem. Czytamy diff, potem commitujemy, a gdy poszło źle, cofamy rozmowę razem z kodem.
NA CO UWAŻAĆ: ktoś powie, że `git checkout -- <plik>` wystarczy. Wystarczy do kodu,
ale nie do rozmowy.
PYTANIE Z SALI: „Czym różni się `/rewind` od `git checkout`?" `/rewind` cofa rozmowę
i kod jednocześnie. Po samym `git checkout` model nadal pamięta, że napisał coś,
czego już nie ma, i będzie się do tego odwoływał.
CZAS: ~3 min
-->

---

<!-- _class: haslo -->

## Prośba działa w większości przypadków.
## W większości, nie zawsze.

Moduł 2 dał prośbę. Tu dokładamy egzekucję.
Wróci to w module 7 jako próg w kodzie i w module 8 jako obrona przed wywołaniem modelu.

<!--
CO POWIEDZIEĆ: to jest nić przewodnia całego kursu, w drugiej odsłonie. Reguła
„zmiana w app/ bez testu wymaga wyraźnej zgody" jest kontekstem, nie gwarancją.
Model ją czyta i zwykle stosuje. „Zwykle" jest tu słowem kluczowym.
NA CO UWAŻAĆ: to nie jest argument przeciw `CLAUDE.md`. To argument za tym,
żeby wiedzieć, czego się po nim spodziewać: konwencji tak, gwarancji nie.
CZAS: ~2 min
-->

---

# Test rozstrzygający: co, jeśli model to zignoruje?

<div class="rozgalezienie">
  <div class="galaz tak">
    <span class="etykieta">nic strasznego</span>
    „Kod będzie brzydszy, poprawię na review"<br><br>
    → <strong>CLAUDE.md</strong><br><small>konwencje, wyjaśnienia, pułapki</small>
  </div>
  <div class="galaz nie">
    <span class="etykieta">nieodwracalne</span>
    „Wejdzie nam sekret do repo"<br>„Wypchniemy czerwone testy"<br><br>
    → <strong>hook</strong><br><small>format, blokady, bramki</small>
  </div>
</div>

Hook nie potrafi wyjaśnić, **dlaczego** reguła istnieje.
Najlepsze reguły mają obie formy.

<!--
CO POWIEDZIEĆ: jedno pytanie rozstrzyga, gdzie trafia reguła. Jeśli konsekwencja
zignorowania jest kosmetyczna, to kontekst. Jeśli konsekwencja jest nieodwracalna
albo trafia na produkcję, to kod uruchamiany przy zdarzeniu.
NA CO UWAŻAĆ: sala po tym slajdzie chce przenieść wszystko do hooków. Hook kosztuje
czas wykonania skryptu przy każdym zdarzeniu i nie tłumaczy niczego.
PYTANIE Z SALI: „To po co nam jeszcze `CLAUDE.md`?" Bo hook nie wyjaśni, dlaczego
reguła istnieje, a to jest połowa wartości pliku kontekstowego. Najlepsze reguły
mają wyjaśnienie w `CLAUDE.md` i egzekucję w hooku.
CZAS: ~3 min
-->

---

# Zdarzeń jest ponad trzydzieści. Wystarczą cztery

| Zdarzenie | Kiedy | Typowe zastosowanie |
|---|---|---|
| `SessionStart` | start, wznowienie, `/clear`, kompakcja | wstrzyknięcie kontekstu (stdout **trafia do modelu**) |
| `PreToolUse` | **przed** wywołaniem narzędzia | blokada niebezpiecznych komend |
| `PostToolUse` | **po** wywołaniu narzędzia | auto-format, walidacja tego, co powstało |
| `Stop` | model chce zakończyć turę | bramka jakości: testy, lint |

Z nazwy warto znać jeszcze: `UserPromptSubmit`, `SubagentStop`, `PreCompact`,
`SessionEnd`, `WorktreeCreate`, `FileChanged`, `PermissionRequest`.

<!--
CO POWIEDZIEĆ: nie trzeba znać całej listy. Te cztery pokrywają codzienną pracę,
a trzy z nich napiszemy w labie. Reszta przyda się wtedy, gdy trafisz na konkretny problem.
NA CO UWAŻAĆ: `PreToolUse` kontra `PostToolUse` myli się przy pierwszym pisaniu.
Blokować da się tylko przed wywołaniem, po wywołaniu narzędzie już się wykonało.
PYTANIE Z SALI: „Gdzie się to konfiguruje?" W `hooks` w pliku ustawień, z matcherem
i ścieżką do skryptu. Matcher bez znaków specjalnych to dokładny string albo lista
typu `Edit|Write`, cokolwiek innego to regex JavaScript, niezakotwiczony.
CZAS: ~3 min
-->

---

# Kod wyjścia to cała mechanika

<div class="przeplyw">
  <div class="krok">Zdarzenie<small>w sesji</small></div>
  <div class="strzalka">→</div>
  <div class="krok">Hook<small>zwykły skrypt</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">Kod wyjścia<small>decyduje, co dalej</small></div>
</div>

| Kod | Znaczenie |
|---|---|
| **0** | sukces; stdout parsowany jako JSON, jeśli zaczyna się `{` i kończy `}` |
| **2** | **blokada**; komunikat z pola `reason` albo ze stderr |
| inny | błąd nieblokujący: akcja przechodzi, w transkrypcie notka o błędzie |

<!--
CO POWIEDZIEĆ: hook to zwykły skrypt, który czyta JSON ze stdin i kończy się kodem.
Cała jego moc siedzi w tym kodzie. Zero przechodzi, dwa blokuje, wszystko inne
to błąd, którego nikt nie zauważy.
NA CO UWAŻAĆ: skoro hook to zwykły skrypt, testuj go bez Claude Code, podając mu JSON
na stdin. Tak właśnie zrobimy w labie.
PYTANIE Z SALI: „Dlaczego nie `exit 1`?" Bo jedynka to błąd nieblokujący: akcja
przechodzi, a ty dostajesz tylko notkę w transkrypcie, łatwą do przeoczenia.
Blokuje wyłącznie dwójka.
CZAS: ~3 min
-->

---

<!-- _class: gesta -->

# „Nie blokuje" to nie to samo co „ignoruje"

| Zdarzenie | Co robi kod 2 |
|---|---|
| `PreToolUse`, `UserPromptSubmit`, `Stop`, `SubagentStop` i dziewięć innych | **blokuje** |
| `PostToolUse`, `PostToolUseFailure` | nie blokuje, ale **pokazuje stderr modelowi** |
| `SessionStart`, `SessionEnd`, `FileChanged`, `CwdChanged` | pokazuje stderr **tylko użytkownikowi** |
| `PermissionRequest`, `PermissionDenied`, `Notification`, `Setup` | ignoruje całkowicie |

**stdout trafia do modelu tylko przy czterech zdarzeniach:** `SessionStart`,
`UserPromptSubmit`, `UserPromptExpansion`, `PostModelSwitch`.
Poza nimi: JSON z polem `systemMessage` albo stderr przy blokadzie.

<!--
CO POWIEDZIEĆ: to jest slajd, który warto sfotografować. Trzy różne zachowania
wyglądają w dokumentacji tak samo, a robią co innego. Drugi wiersz jest użyteczny:
to jedyny sposób, żeby hook `PostToolUse` powiedział cokolwiek modelowi.
NA CO UWAŻAĆ: przy kodzie 0 stderr idzie wyłącznie do logu debugowania i model
go nie widzi. Ludzie piszą `echo ... >&2` i dziwią się, że nic się nie dzieje.
PYTANIE Z SALI: „Jak więc hook `PostToolUse` ma zgłosić problem?" Kodem 2. Narzędzie
już się wykonało, więc niczego nie zablokuje, ale ostrzeżenie dotrze do modelu.
CZAS: ~3 min
-->

---

# Bramka na `Stop`: ochrona przed pętlą już jest

<div class="przeplyw pion">
  <div class="krok zly">czerwona, <code>stop_hook_active</code> = false<small>exit 2, wynik na stderr - tura trwa dalej</small></div>
  <div class="strzalka">→</div>
  <div class="krok">model próbuje naprawić<small>ta sama tura</small></div>
  <div class="strzalka">→</div>
  <div class="krok wyroz">nadal czerwona, <code>stop_hook_active</code> = true<small>exit 0 + <code>systemMessage</code></small></div>
</div>

Zielona bramka: `exit 0`. Twardy limit: po **8 kolejnych blokadach**
Claude Code kończy turę sam. Uzbrojenie wraca samo w nowej turze.

**Nie pisz własnego znacznika. Przeczytaj schemat wejścia.**

<!--
CO POWIEDZIEĆ: exit 2 na `Stop` mówi modelowi „pracuj dalej", więc hook, który zawsze
zwraca 2 przy czerwonej bramce, zapętliłby sesję. Claude Code daje na to dwa gotowe
mechanizmy i oba są w schemacie wejścia: pole `stop_hook_active` i limit 8 blokad.
NA CO UWAŻAĆ: pole może nie przyjść. `jq -r '.stop_hook_active // false'` musi dać
wartość domyślną, inaczej hook porówna pusty string i zachowa się nieprzewidywalnie.
PYTANIE Z SALI: „A jeśli model nie umie naprawić bramki?" Druga próba przechodzi,
bo `stop_hook_active` jest wtedy `true`, a niezależnie od tego po ośmiu kolejnych
blokadach Claude Code nadpisuje hook i kończy turę sam.
CZAS: ~4 min
-->

---

# Trzy miejsca, w których zabezpieczenie cicho przestaje działać

| Pułapka | Co się dzieje | Jak trzeba |
|---|---|---|
| `${CLAUDE_PROJECT_DIR}` w bramce | w worktree testuje główny checkout i **świeci na zielono** | czytaj `cwd` ze stdin |
| hook w `~/.claude/settings.json` | twoja prywatna wygoda, nie standard zespołu | `.claude/settings.json`, commitowany |
| blokada jako brak `allow` | `allow` czeka na **zaufanie folderu** | wpisz `deny`, działa natychmiast |

Listy w plikach ustawień **łączą się**, nie nadpisują.
Weryfikacja: `/hooks` pokazuje załadowane hooki, `/status` - źródła ustawień.

<!--
CO POWIEDZIEĆ: `${CLAUDE_PROJECT_DIR}` wskazuje katalog startu sesji i nie zmienia się,
gdy model wejdzie w worktree. `cwd` idzie za sesją. Pierwszy wiersz zobaczycie
w module 6, na własnej skórze, bo bramka będzie zielona dla kodu, którego nikt nie zmieniał.
NA CO UWAŻAĆ: fałszywy spokój jest gorszy niż brak bramki. Zielone światło, którego
nikt nie kwestionuje, wyłącza czujność całego zespołu.
PYTANIE Z SALI: „Trzeba restartować sesję po zmianie ustawień?" Nie, pliki są
przeładowywane na żywo. `/hooks` pokaże, co jest faktycznie załadowane.
CZAS: ~2 min
-->

---

# Skill: procedura ładowana na wywołanie

```
.claude/skills/<nazwa-katalogu>/SKILL.md
```

**Nazwa komendy bierze się z katalogu**, nie z pola `name`.
Wynik komendy wstrzykuje się, zanim model zobaczy treść skilla:

```markdown
!`git diff HEAD`
```

| | Kiedy ładowane | Do czego |
|---|---|---|
| `CLAUDE.md` | zawsze | fakty i konwencje potrzebne w każdej sesji |
| Reguła z `paths:` | gdy model dotknie pasującego pliku | zasady dla wycinka kodu |
| **Skill** | **na wywołanie** | procedura wieloetapowa, używana od czasu do czasu |

<!--
CO POWIEDZIEĆ: procedura na dwadzieścia kroków w `CLAUDE.md` kosztuje tokeny w każdej
sesji, także wtedy, gdy pracujesz nad czymś zupełnie innym. Ten sam tekst jako skill
kosztuje zero, dopóki go nie wywołasz.
NA CO UWAŻAĆ: `---` musi być w pierwszej linii pliku. Pusta linia przed frontmatterem
oznacza, że cały blok zostanie potraktowany jako treść.
PYTANIE Z SALI: „Czym to się różni od wklejonego promptu?" Wstrzyknięciem wyniku
komendy. Model dostaje gotowy diff w kontekście, nie musi po niego sięgać
i nie może o nim zapomnieć. Do tego skill jest w repo, więc ma wersję i historię.
CZAS: ~3 min
-->

---

<!-- _class: lab -->

# Laby: trzy hooki i jeden skill

**Lab 5.1 (~45 min)** - tag `lab-5-1-start`. Cel `gate` w `Makefile`, potem trzy hooki:
format po edycji, blokada niebezpiecznych komend, bramka na `Stop`.
Testujesz je **bez Claude Code**, podając JSON na stdin.

**Lab 5.2 (~40 min)** - tag `lab-5-2-start`. Skill `/przeglad-bezpieczenstwa`
ze stałą checklistą, który w module 8 znajdzie luki w tym repozytorium.

Zanim zaczniesz: `git checkout lab-5-1-start`, `make test` (32 testy zielone),
`jq --version`, a niezacommitowaną pracę odłóż przez `git stash push -u`.

<!--
CO POWIEDZIEĆ: w 5.1 lista blokowanych wzorców ma mieć najwyżej siedem pozycji.
Długa lista daje złudzenie bezpieczeństwa, blokuje pracę przy pierwszym fałszywym
trafieniu i kończy się tym, że ktoś wyłącza cały hook. `rm plik.txt` ma przejść.
NA CO UWAŻAĆ: bramka wymaga `jq`, a hook formatujący ma szukać `ruff` najpierw
w `.venv/bin`, dopiero potem w PATH - rozwiązanie wzorcowe sprawdza oba miejsca
i nigdy nie zatrzymuje pracy, gdy `ruff` jest nieosiągalny.
PYTANIE Z SALI: „Nie mam `jq`." `brew install jq` albo `apt install jq`. Hooki
parsujące JSON grepem działają do pierwszego cudzysłowu w komendzie.
CZAS: ~2 min
-->

---

<!-- _class: haslo -->

## Artefakt w repozytorium bije wiedzę w głowie.

Hook, skill, `settings.json` - wszystko, co ma działać jutro bez ciebie,
musi być plikiem przechodzącym przez review.

<!--
CO POWIEDZIEĆ: to samo zdanie wróci przy subagentach, golden secie i zasadach
zespołowych. Hook w katalogu domowym jest twoją prywatną wygodą. Ten sam hook
w repozytorium jest standardem zespołu, bo można o nim dyskutować w pull requeście.
CZAS: ~1 min
-->
