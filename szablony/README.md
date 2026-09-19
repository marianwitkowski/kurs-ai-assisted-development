# Szablony do zabrania do firmy

`settings.json`, hooki, skill, subagent, `skan_sekretow.sh` i `gitignore-fragment`
to kopie ze stanu końcowego repozytorium ćwiczeniowego (tag `lab-8-2-koniec`).
Działają, ale z zaszytymi komendami, ścieżkami i tagami tego repozytorium,
które wymagają podmiany - kolumna obok wymienia je z numerami linii.
`CLAUDE.md` i `AI-ZASADY.md` też stamtąd pochodzą, są jednak dokumentami do napisania
od nowa pod własny projekt. Pozostałe pozycje - `prompty.md`, obie checklisty,
`szablon-specyfikacji.md`, `ci.yml` i `skrypty/ewaluacja_promptu.py` - powstały
na potrzeby kursu, w repozytorium ćwiczeniowym ich nie ma; to przykłady do przepisania.

| Plik | Skąd | Co zrobić przed użyciem |
|---|---|---|
| `CLAUDE.md` | moduł 2 | przepisać pod swój projekt; **nie kopiować treści**, skopiować strukturę |
| `settings.json` | moduł 5 | do `.claude/settings.json` w swoim repo |
| `hooks/format-po-edycji.sh` | moduł 5 | podmienić `ruff` w trzech miejscach: rozszerzenie pliku (linia 10), ścieżka do lokalnego środowiska (linia 14), składnia komendy (linia 19) |
| `hooks/blokuj-niebezpieczne.sh` | moduł 5 | przejrzeć listę wzorców; **krótka lista jest cechą, nie brakiem** |
| `hooks/bramka.sh` | moduł 5 | podmienić `make gate` na swoją bramkę - w liniach 35 i 37 |
| `skills/przeglad-bezpieczenstwa/` | moduł 5 | dopasować checklistę do swojego stosu; podmienić domyślny zakres `lab-1-1-start` (linie 4 i 22) na własny, np. `origin/main...HEAD` |
| `agents/migrator.md` | moduł 6 | dopasować `tools`, `maxTurns` oraz komendę bramki `make gate` (linia 20) |
| `skan_sekretow.sh` | moduł 8 | dodać wzorce charakterystyczne dla własnych systemów **i rozszerzenia plików własnego stosu (linia 16)** - lista jest zamknięta, poza nią skan milczy |
| `AI-ZASADY.md` | moduł 8 | **wypełnić sekcje `[DO USTALENIA]`** - bez tego jest bezużyteczny; wymienić przykłady z repozytorium ćwiczeniowego (`app/klasyfikacja_vat.py`, `seed.py`, `make gate`) na własne |
| `prompty.md` | cały kurs | biblioteka promptów z uzasadnieniem konstrukcji |
| `checklista-review.md` | moduł 8 | do procesu review |
| `szablon-specyfikacji.md` | moduł 3 | do `specyfikacje/` w swoim repo |
| `ci.yml` | moduł 5 i 8 | wzór workflow GitHub Actions |
| `gitignore-fragment` | cały kurs | cały `.gitignore` repozytorium ćwiczeniowego; część uniwersalną (Python, edytory, systemowe) zabrać bez zmian; wpisy projektowe (`rozliczenia.db` z komentarzem o `seed.py`, `notatki/`) zastąpić własnymi, a komentarze odsyłające do labów (`settings.local.json`, `*.bak`) skrócić albo usunąć |
| `skrypty/ewaluacja_promptu.py` | moduł 7 | ewaluacja promptu na oznaczonym zbiorze - przykład do przepisania pod własny moduł klasyfikatora; wywołuje model, więc kosztuje |
| `checklista-gotowosci.md` | moduł 7 i 8 | przed wpuszczeniem modelu do produktu |

---

## Kolejność wdrażania

Wdrażanie wszystkiego naraz się nie sprawdza. Projekt, który nie przechodzi
wszystkich bramek od pierwszego dnia, kończy się wyłączonymi bramkami.

1. **`CLAUDE.md`** - jeden dzień, efekt widoczny natychmiast.
2. **Hook formatujący** - nikt nie zauważy, wszyscy skorzystają.
3. **Bramka na `Stop`** z tym, co projekt **już** przechodzi (lint).
4. **Skill przeglądu** - pierwszy artefakt zespołowy przechodzący przez review.
5. **Testy w bramce** - gdy są testy warte uruchamiania.
6. **Skan sekretów** - na końcu, bo prawdopodobnie coś znajdzie.
7. **`AI-ZASADY.md`** - gdy macie już odpowiedzi na `[DO USTALENIA]`.

---

## Pułapki przy przenoszeniu

**`${CLAUDE_PROJECT_DIR}` w hookach.** Wskazuje katalog, w którym wystartowała sesja,
i **nie zmienia się** po wejściu w git worktree. `bramka.sh` czyta z tego powodu
pole `cwd` ze stdin - po przepisaniu tego na `${CLAUDE_PROJECT_DIR}`
bramka w worktree testuje nie ten katalog.

**`make gate` w `bramka.sh`.** Skrypt zakłada `Makefile` w katalogu sesji.
Przy innym sposobie uruchamiania bramki podmienia się dwie linie: strażnika
`[[ -f Makefile ]]` (linia 35) i samo wywołanie (linia 37). Podmiana wyłącznie
wywołania jest cicha: bez `Makefile` hook kończy `exit 0` i nikt nie dostaje sygnału,
że bramka w ogóle się nie uruchomiła.

**Bezpiecznik w `bramka.sh`.** Hook czyta pole `stop_hook_active` z wejścia: `false`
oznacza pierwszą próbę, `true` - że tura trwa dalej właśnie dlatego, że hook ją zablokował.
Drugiej blokady nie ma, żeby sesja nie kręciła się w kółko. Ta gałąź jest konieczna;
wycięcie jej zamienia hook w pętlę.

**`jq`.** Wszystkie hooki go wymagają. Do dopisania w instrukcji onboardingowej zespołu.

**`CLAUDE.md` starzeje się razem z projektem.** Sekcja „Czego w repozytorium nie ma"
jest najbardziej narażona: wystarczy, że ktoś dopisze testy, a plik zaczyna kłamać.
Plik kontekstowy, który opisuje nieaktualny stan, jest gorszy od jego braku - model
przyjmuje go za prawdę i nie sprawdza. Warto dopisać jego przegląd do definicji
ukończenia zadania, obok testów i dokumentacji.

**Środowisko na `PATH`.** Hook dziedziczy `PATH` po procesie, który uruchomił Claude Code.
Jeżeli bramka woła gołe `pytest`/`ruff`, a agent wystartował bez aktywowanego środowiska,
bramka będzie czerwona z powodu „command not found". Wyjścia są dwa: aktywacja środowiska
przed uruchomieniem agenta albo hook szukający narzędzi tak jak `format-po-edycji.sh`.

**`.gitignore` - dwa wpisy, o których się zapomina.** Zanim ktokolwiek w zespole użyje
worktree albo ustawień osobistych:

```gitignore
.claude/worktrees/              # zawartość worktree w głównym checkoucie
.claude/settings.local.json     # ustawienia osobiste, m.in. worktree.baseRef
```

Drugi wiersz jest ważniejszy: bez niego pierwsze `git add -A` wciągnie czyjeś osobiste
ustawienia do repozytorium i zaczną obowiązywać cały zespół. Claude Code, gdy sam tworzy
ten plik, dopisuje `**/.claude/settings.local.json` do **globalnych exclude'ów gita**
(`core.excludesFile` albo `~/.config/git/ignore`) - chroni to jedną maszynę, a nie
repozytorium, więc plik kolegi z zespołu nadal wjedzie przez `git add -A`.
Gdy plik powstaje ręcznie, nie ma nawet tego. Wpis w `.gitignore` repozytorium
jest więc potrzebny mimo wszystko. Pełna lista w `gitignore-fragment`.

**`worktree.baseRef`.** Domyślnie `"fresh"` - worktree powstaje z **domyślnej gałęzi
zdalnego repozytorium**, a nie z bieżącego stanu. Praca na branchu feature daje worktree
**bez tych zmian**. Do izolowania pracy w toku służy wpis w settings:
`{"worktree": {"baseRef": "head"}}`.

**Nazwa katalogu skilla.** Komenda bierze się z **nazwy katalogu**, nie z pola `name`.
Zmiana nazwy katalogu zmienia komendę.
