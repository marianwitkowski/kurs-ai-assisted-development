# Ściąga - moduł 1

## Komendy, bez których nie ruszysz

| Komenda | Do czego |
|---|---|
| `claude` | start sesji w bieżącym katalogu |
| `/model` | zmiana modelu, pokazuje listę i ceny |
| `/effort` | `low` · `medium` · `high` · `xhigh` · `max`. **Haiku nie obsługuje.** Wpisany poziom **zapisuje się jako domyślny na kolejne sesje** |
| `/context` | co zajmuje okno kontekstowe |
| `/usage` | zużycie, limity planu, atrybucja, statystyki cache |
| `/clear` | koniec zadania, czyścimy kontekst |
| `/rewind` | cofnięcie rozmowy **i** kodu |
| `/status` | wersja, model, załadowane pliki ustawień |
| `Shift+Tab` | przełączanie trybu uprawnień (w tym planowania) |
| `Esc` | **przerwanie natychmiast** |
| `Esc Esc` | wybór punktu, do którego cofnąć rozmowę |

## Modele (wrzesień 2026, API Anthropic)

| Model | ID | Kontekst | We $/1M | Wy $/1M |
|---|---|---|---|---|
| Opus 5 | `claude-opus-5` | 1M | 5 | 25 |
| Sonnet 5 | `claude-sonnet-5` | 1M | 2 | 10 |
| Haiku 4.5 | `claude-haiku-4-5` | 200K | 1 | 5 |

Sprawdzenie na żywo: `/model` albo `client.models.list()`.

## Dobór do zadania

| Zadanie | Model | Effort |
|---|---|---|
| Decyzja architektoniczna, plan migracji | Opus | `high`-`max` |
| Implementacja wg specyfikacji | Sonnet | `medium`-`high` |
| Masowe przekształcenia mechaniczne | Haiku (bez effortu) / Sonnet | `low` |
| Subagent zbierający fakty | Haiku | - (nie obsługuje) |
| Review bezpieczeństwa | Opus | `high`-`max` |
| Debug bez hipotezy | Opus | `xhigh` |

**Najpierw schodź z effortu, potem z modelu.** Cache jest przypisany do modelu.

## Cztery tryby porażki

| Tryb | Reguła przeciwdziałania |
|---|---|
| Halucynacja | żądaj cytatu: plik + numer linii |
| Błędne założenie | precyzyjna specyfikacja (moduł 3) |
| Nadmierna pewność | kalibruj po weryfikowalności, nie po tonie |
| Rozrost kontekstu | `/clear` między zadaniami |

## Pliki kontekstowe innych narzędzi

| Narzędzie | Plik |
|---|---|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursor/rules/` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Codex CLI | `AGENTS.md` |
| Gemini CLI | `GEMINI.md` |
