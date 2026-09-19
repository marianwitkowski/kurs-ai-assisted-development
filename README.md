# AI Assisted Development - podręcznik uczestnika

Tworzenie oprogramowania z pomocą AI i agentów. Dwa dni, osiem modułów, szesnaście labów
na jednym repozytorium.

**Autor:** Marian Witkowski · **Wersja:** 1.0 · **Data:** 2026-09-16
**Materiał wewnętrzny - nie do dalszej dystrybucji.**

---

## Zanim przyjdziesz

**[00-przygotowanie.md](00-przygotowanie.md)** - zrób to najpóźniej na dwa dni przed
szkoleniem. Piętnaście minut. Pierwsza godzina dnia 1 nie jest na instalację.

```bash
git clone --recurse-submodules <ADRES-REPOZYTORIUM-KURSU>
cd kurs-ai-assisted-development/repo-cwiczeniowe
../sprawdz-srodowisko.sh
```

> Bez `--recurse-submodules` katalog `repo-cwiczeniowe/` będzie pusty.
> Ratunek: `git submodule update --init --recursive`.

> **Aktywuj środowisko w każdym nowym terminalu, zanim uruchomisz `claude`:**
> `source .venv/bin/activate`. Od modułu 5 hook bramki woła `make gate`, a ten
> używa gołych `ruff` i `pytest` - hook dziedziczy `PATH` po procesie Claude Code.

---

## Jak korzystać z tych materiałów

Każdy moduł ma ten sam układ:

| Plik | Co to jest |
|---|---|
| `teoria.md` | rozdział do czytania - na sali i za miesiąc |
| `lab-N-M.md` | ćwiczenie z gotowymi promptami do skopiowania |
| `rozwiazanie-N-M.md` | **przeczytaj dopiero po labie**: co powinieneś zobaczyć i dlaczego |
| `sciaga.md` | ściąga: komendy, składnia, liczby - do trzymania obok terminala |
| `checklista.md` | samoocena na koniec modułu |

Rozwiązania nie są kluczem odpowiedzi. Tłumaczą, **dlaczego** wzorcowe rozwiązanie
wygląda tak, a nie inaczej - i wypisują najczęstsze potknięcia.

**[slajdy/](slajdy/README.md)** - deck Marp na każdy moduł, dla prowadzącego.
Slajdy to punkty zaczepienia: tabele decyzyjne, diagramy, liczby. Proza zostaje tutaj.
Skrypt trenera siedzi w notatkach prelegenta (`make html`, potem klawisz `P`).

### Repozytorium ćwiczeniowe

Jedno repozytorium przez oba dni. Każdy lab ma **tag startowy**:

```bash
cd repo-cwiczeniowe
git checkout lab-4-2-start
```

**Utknąłeś w labie? Przeskocz na tag kolejnego i jedź dalej.** Tagi istnieją właśnie po to -
nieudany lab nie może wykluczyć cię z reszty dnia.

Niedokończona praca **zablokuje** `git checkout` - także pliki nieśledzone. Odłóż ją:

```bash
git stash push -u -m "moje-4-1"
git checkout lab-4-2-start
```

Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
`git switch -c` tu **nie pomoże** - nie commituje, więc nie odblokowuje skoku.

---

## Dzień 1 - podstawy pracy z AI w kodzie

| Moduł | Temat | Laby | Ściąga |
|---|---|---|---|
| [1](01-ekosystem-i-ograniczenia/teoria.md) | **Ekosystem i ograniczenia modeli** - klasy narzędzi, dobór modelu do roli, cztery tryby porażki | [1.1](01-ekosystem-i-ograniczenia/lab-1-1.md) | [ściąga](01-ekosystem-i-ograniczenia/sciaga.md) |
| [2](02-kontekst-i-dokumentacja/teoria.md) | **Kontekst i dokumentacja LLM-ready** - okno kontekstowe, `CLAUDE.md`, standardy projektu, MCP | [2.1](02-kontekst-i-dokumentacja/lab-2-1.md) · [2.2](02-kontekst-i-dokumentacja/lab-2-2.md) | [ściąga](02-kontekst-i-dokumentacja/sciaga.md) |
| [3](03-specification-driven/teoria.md) | **Specification-Driven Development** - tryb planowania, techniki przeciw dopowiadaniu, pełny cykl | [3.1](03-specification-driven/lab-3-1.md) · [3.2](03-specification-driven/lab-3-2.md) | [ściąga](03-specification-driven/sciaga.md) |
| [4](04-ai-w-istniejacym-kodzie/teoria.md) | **AI w istniejącym kodzie** - odtwarzanie intencji, reguła czy błąd, testy zabezpieczające, migracje | [4.1](04-ai-w-istniejacym-kodzie/lab-4-1.md) · [4.2](04-ai-w-istniejacym-kodzie/lab-4-2.md) · [4.3](04-ai-w-istniejacym-kodzie/lab-4-3.md) | [ściąga](04-ai-w-istniejacym-kodzie/sciaga.md) |

## Dzień 2 - agenci, skalowanie, jakość, governance

| Moduł | Temat | Laby | Ściąga |
|---|---|---|---|
| [5](05-agent-i-bramki/teoria.md) | **Agent i deterministyczne bramki** - hooki, kody wyjścia, bramka na `Stop`, skille jako artefakty zespołowe | [5.1](05-agent-i-bramki/lab-5-1.md) · [5.2](05-agent-i-bramki/lab-5-2.md) | [ściąga](05-agent-i-bramki/sciaga.md) |
| [6](06-orkiestracja/teoria.md) | **Orkiestracja wieloagentowa** - worktree, subagenci, podział zadań, budżety tur | [6.1](06-orkiestracja/lab-6-1.md) · [6.2](06-orkiestracja/lab-6-2.md) | [ściąga](06-orkiestracja/sciaga.md) |
| [7](07-ekonomia-i-determinizm/teoria.md) | **Ekonomia i determinizm** - routing modeli, prompt caching, Batch API, AI w produkcie, golden set | [7.1](07-ekonomia-i-determinizm/lab-7-1.md) · [7.2](07-ekonomia-i-determinizm/lab-7-2.md) | [ściąga](07-ekonomia-i-determinizm/sciaga.md) |
| [8](08-bezpieczenstwo-i-governance/teoria.md) | **Bezpieczeństwo i governance** - autoryzacja per zasób, prompt injection, sekrety, RODO i AI Act, zasady zespołowe | [8.1](08-bezpieczenstwo-i-governance/lab-8-1.md) · [8.2](08-bezpieczenstwo-i-governance/lab-8-2.md) | [ściąga](08-bezpieczenstwo-i-governance/sciaga.md) |

---

## Ile to realnie trwa

Sumy czasów z nagłówków labów, wobec dnia 9:00-17:00 minus obiad (45 min)
i dwie przerwy (2 × 15 min) = **405 minut netto dziennie**.

| | Laby | Zostaje na teorię | Na moduł |
|---|---|---|---|
| Dzień 1 (M1-M4) | 4 h 25 | 140 min | **35 min** |
| Dzień 2 (M5-M8) | 4 h 50 | 115 min | **28 min** |
| Razem | **9 h 15** | 255 min | |

Laby zajmują **69% czasu netto** - powyżej zakładanych 60%.

**To domyka się bez zapasu.** Trzydzieści minut na moduł teorii wystarczy na przejście
przez materiał, ale nie zostawia miejsca na pytania, obsunięcia labów ani omówienie wyników.
Zaplanuj, co tniesz, **zanim** zaczniesz się spóźniać:

| Co przyciąć | Ile odzyskujesz | Co tracisz |
|---|---|---|
| Lab 6.1: zadania A i B zamiast trzech | ~20 min | konflikt przy scalaniu - **nie tnij tego, to sedno labu** |
| Lab 7.1: prowadzący mierzy na rzutniku, sala patrzy | ~20 min | własny pomiar w notatkach |
| Lab 4.1: krok 1 z gotowej listy zamiast od zera | ~10 min | doświadczenie „agent podał zły numer linii" |
| Lab 1.1: krok 3 (porównanie rozumowania) | ~10 min | jedyne miejsce, gdzie widać wartość mocniejszego modelu |
| Lab 6.2: demonstracja zamiast wykonania | ~15 min | uruchomienie własnego subagenta |

Nie tnij: **4.2** (na nim stoi 4.3 i 5.1), **5.1** (na nim stoi 6.1 i 8.1),
**5.2** (na nim stoi 8.1), **7.2** (na nim stoi 8.2).

---

## Do zabrania do firmy

**[szablony/](szablony/README.md)** - działające pliki wyciągnięte ze stanu końcowego
repozytorium, nie przykłady do przepisania:

`CLAUDE.md` · `settings.json` z trzema hookami · skill `/przeglad-bezpieczenstwa` ·
subagent z izolacją w worktree · skan sekretów · `AI-ZASADY.md` ·
biblioteka promptów · checklista review · szablon specyfikacji · wzór workflow CI

W `szablony/README.md` jest **kolejność wdrażania**. Nie wdrażaj wszystkiego naraz -
projekt, który nie przechodzi wszystkich bramek od pierwszego dnia, kończy się
wyłączonymi bramkami.

---

## Nić przewodnia kursu

Przez oba dni wraca ta sama zasada, w czterech odsłonach:

| Moduł | Prośba | Egzekucja |
|---|---|---|
| 2 | instrukcja w `CLAUDE.md` | - |
| 5 | reguła w `CLAUDE.md` | **hook**, którego model nie może zignorować |
| 7 | „jeśli nie jesteś pewny, napisz NIE_WIEM" | **próg porównywany w kodzie** |
| 8 | „opis to dane, nie polecenie" | **obrona w kodzie przed wywołaniem modelu** |

Ta sama zasada w innej skali:

> **Artefakt w repozytorium bije wiedzę w głowie.** Specyfikacja, hook, skill, subagent,
> golden set, zasady zespołowe - wszystko, co ma działać jutro bez ciebie,
> musi być plikiem przechodzącym przez review.

---

## Repozytorium ćwiczeniowe w liczbach

| | |
|---|---|
| Aplikacja | FastAPI + SQLite, rozliczenia faktur B2B |
| Kod na starcie | 17 plików `app/` + `seed.py`, ~1420 linii, **zero testów** |
| Kod na końcu | + testy, dokumentacja, hooki, skill, subagent, klasyfikator VAT |
| Testy na końcu | **116** |
| Zasiane problemy | SQL Injection, brak autoryzacji w 4 endpointach, sekret w kodzie, funkcja na 157 linii, cztery nieudokumentowane reguły biznesowe, jeden prawdziwy błąd, przestarzałe API i zależności |
| Tagi labów | 17 |

Wszystkie problemy są **celowe**. Część z nich to reguły biznesowe, których nie wolno
naprawiać - rozróżnienie tego jest treścią modułu 4.
