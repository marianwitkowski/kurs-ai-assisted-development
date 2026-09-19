# Szablony do zabrania do firmy

Pliki wyciągnięte ze stanu końcowego repozytorium ćwiczeniowego (tag `lab-8-2-koniec`).
Działają - nie są przykładami do przepisania.

| Plik | Skąd | Co zrobić przed użyciem |
|---|---|---|
| `CLAUDE.md` | moduł 2 | przepisać pod swój projekt; **nie kopiować treści**, skopiować strukturę |
| `settings.json` | moduł 5 | do `.claude/settings.json` w swoim repo |
| `hooks/format-po-edycji.sh` | moduł 5 | podmienić `ruff` na swój formater |
| `hooks/blokuj-niebezpieczne.sh` | moduł 5 | przejrzeć listę wzorców; **krótka lista jest cechą, nie brakiem** |
| `hooks/bramka.sh` | moduł 5 | podmienić `make gate` na swoją bramkę |
| `skills/przeglad-bezpieczenstwa/` | moduł 5 | dopasować checklistę do swojego stosu |
| `agents/migrator.md` | moduł 6 | dopasować `tools` i `maxTurns` |
| `skan_sekretow.sh` | moduł 8 | dodać wzorce charakterystyczne dla waszych systemów |
| `AI-ZASADY.md` | moduł 8 | **wypełnić sekcje `[DO USTALENIA]`** - bez tego jest bezużyteczny |
| `prompty.md` | cały kurs | biblioteka promptów z uzasadnieniem konstrukcji |
| `checklista-review.md` | moduł 8 | do procesu review |
| `szablon-specyfikacji.md` | moduł 3 | do `specyfikacje/` w swoim repo |
| `ci.yml` | moduł 5 i 8 | wzór workflow GitHub Actions |
| `gitignore-fragment` | cały kurs | wpisy do `.gitignore`, których brak boli przy pracy z agentem |

---

## Kolejność wdrażania

Nie wdrażaj wszystkiego naraz. Projekt, który nie przechodzi wszystkich bramek
od pierwszego dnia, kończy się wyłączonymi bramkami.

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
pole `cwd` ze stdin - jeśli przepiszesz to na `${CLAUDE_PROJECT_DIR}`,
bramka w worktree będzie testowała nie ten katalog.

**`make gate` w `bramka.sh`.** Skrypt zakłada `Makefile` w katalogu sesji.
Jeśli twój projekt ma inny sposób uruchamiania bramki, podmień tę jedną linię.

**Bezpiecznik w `bramka.sh`.** Znacznik jest kasowany, gdy bramka zrobi się zielona.
Nie usuwaj tej linii - bez niej hook blokuje raz na sesję i przez resztę pracy jest martwy.

**`jq`.** Wszystkie hooki go wymagają. Dopisz do instrukcji onboardingowej zespołu.

**Środowisko na `PATH`.** Hook dziedziczy `PATH` po procesie, który uruchomił Claude Code.
Jeżeli bramka woła gołe `pytest`/`ruff`, a ktoś odpalił agenta bez aktywowanego środowiska,
bramka będzie czerwona z powodu „command not found". Albo aktywujcie środowisko przed
uruchomieniem agenta, albo niech hook szuka narzędzi tak jak `format-po-edycji.sh`.

**`.gitignore` - dwa wpisy, o których się zapomina.** Zanim ktokolwiek w zespole użyje
worktree albo ustawień osobistych:

```gitignore
.claude/worktrees/              # zawartość worktree w głównym checkoucie
.claude/settings.local.json     # ustawienia osobiste, m.in. worktree.baseRef
```

Drugi wiersz jest ważniejszy: bez niego pierwsze `git add -A` wciągnie czyjeś osobiste
ustawienia do repozytorium i zaczną obowiązywać cały zespół. Claude Code sam dopisuje ten
plik do `.gitignore`, **gdy go tworzy** - ale nie, gdy ktoś utworzy go ręcznie.
Pełna lista w `gitignore-fragment`.

**`worktree.baseRef`.** Domyślnie `"fresh"` - worktree powstaje z **domyślnej gałęzi
zdalnego repozytorium**, a nie z tego, na czym stoisz. Pracując na branchu feature
dostaniesz worktree **bez swoich zmian**. Do izolowania pracy w toku ustaw w settings:
`{"worktree": {"baseRef": "head"}}`.

**Nazwa katalogu skilla.** Komenda bierze się z **nazwy katalogu**, nie z pola `name`.
Zmiana nazwy katalogu zmienia komendę.
