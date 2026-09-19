# Ściąga - moduł 1

## Komendy niezbędne od startu

| Komenda | Do czego |
|---|---|
| `claude` | start sesji w bieżącym katalogu |
| `/model` | zmiana modelu, pokazuje listę i ceny |
| `/effort` | `low` · `medium` · `high` · `xhigh` · `max`. **Haiku nie obsługuje.** Wpisany poziom **zapisuje się jako domyślny na kolejne sesje**, poza `max` - ten obowiązuje tylko w bieżącej sesji |
| `/context` | co zajmuje okno kontekstowe |
| `/usage` | zużycie, limity planu, atrybucja, statystyki cache |
| `/clear` | koniec zadania, wyczyszczenie kontekstu |
| `/rewind` | cofnięcie rozmowy **i** kodu |
| `/status` | wersja, model, załadowane pliki ustawień |
| `Shift+Tab` | przełączanie trybu uprawnień (w tym planowania) |
| `Esc` | **przerwanie natychmiast** |
| `Esc Esc` | wybór punktu, do którego cofnąć rozmowę |

## Modele (wrzesień 2026, API Anthropic)

| Model | ID | Kontekst | We $/1M | Wy $/1M |
|---|---|---|---|---|
| Fable 5.1 | `claude-fable-5-1` | 1M | 10 | 50 |
| Opus 5 | `claude-opus-5` | 1M | 5 | 25 |
| Sonnet 5 | `claude-sonnet-5` | 1M | 2 | 10 |
| Haiku 4.5 | `claude-haiku-4-5` | 200K | 1 | 5 |

Odczyt z cache kosztuje na Fable 0,025 ceny wejścia zamiast 0,1.

Sprawdzenie na żywo: `/model` albo `client.models.list()`.

## Dobór do zadania

| Zadanie | Model | Effort |
|---|---|---|
| Decyzja architektoniczna, plan migracji | Opus | `high`-`max` |
| Czego Opus na `max` nie domyka | Fable | `high`-`max` |
| Implementacja wg specyfikacji | Sonnet | `medium`-`high` |
| Masowe przekształcenia mechaniczne | Haiku (bez effortu) / Sonnet | `low` |
| Subagent zbierający fakty | Haiku | - (nie obsługuje) |
| Review bezpieczeństwa | Opus | `high`-`max` |
| Debug bez hipotezy | Opus | `xhigh` |

**Najpierw schodzić z effortu, potem z modelu.** Cache jest przypisany do modelu.

## Cztery tryby porażki

| Tryb | Reguła przeciwdziałania |
|---|---|
| Halucynacja | wymuszony cytat: plik + numer linii |
| Błędne założenie | precyzyjna specyfikacja (moduł 3) |
| Nadmierna pewność | kalibracja po weryfikowalności, nie po tonie |
| Rozrost kontekstu | `/clear` między zadaniami |

## Pliki kontekstowe innych narzędzi

| Narzędzie | Plik |
|---|---|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursor/rules/` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Codex CLI | `AGENTS.md` |
| Gemini CLI | `GEMINI.md` |
