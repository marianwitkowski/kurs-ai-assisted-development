# Ściąga - moduł 6

## Worktree

```bash
claude --worktree nazwa            # albo -w; .claude/worktrees/nazwa/, branch worktree-nazwa
claude --worktree "#1234"          # z pull requesta (cudzysłów!)

git worktree add ../projekt-a -b feature-a
git worktree add .claude/worktrees/x -b worktree-x <tag>
git worktree list
git worktree remove <ścieżka>      # --force przy zmianach
git worktree unlock <ścieżka>      # gdy git odmawia
```

Do `.gitignore`, zanim ktokolwiek użyje worktree:
```gitignore
.claude/worktrees/
.claude/settings.local.json
```

| Ustawienie | Znaczenie |
|---|---|
| `worktree.baseRef: "fresh"` | **domyślne** - branch z domyślnej gałęzi **remote** |
| `worktree.baseRef: "head"` | branch z bieżącego lokalnego `HEAD` |

> **Pułapka:** `"fresh"` na branchu feature daje worktree **bez twoich zmian**.
> Do izolowania pracy w toku: `{"worktree": {"baseRef": "head"}}`.

## Środowisko per worktree

Worktree to **świeży checkout** - nie ma w nim niczego z `.gitignore`.

`.worktreeinclude` (składnia `.gitignore`) kopiuje pliki spoza gita:
```text
.env
.env.local
config/sekrety.json
```
Kopiowane są tylko pliki pasujące do wzorca **i** gitignorowane.

Reszta wymaga decyzji: zależności, baza testowa, porty.

## Cztery kontrole izolacji

1. edycja pliku w głównym checkoucie
2. komenda z cwd w głównym checkoucie
3. przekierowanie gita (`git -C`, `--git-dir`, `GIT_DIR`, `cd`)
4. komenda, której kształtu nie da się zweryfikować - **nie da się wyłączyć**

## Subagenci

```
.claude/agents/<nazwa>.md
```

```yaml
---
name: migrator
description: kiedy używać i do czego NIE
tools: Read, Edit, Grep, Glob, Bash
model: sonnet          # haiku|sonnet|opus|fable|pełne ID|inherit
isolation: worktree
maxTurns: 25
---
```

Kolejność wyboru modelu: parametr wywołania → frontmatter →
`CLAUDE_CODE_SUBAGENT_MODEL` → model sesji głównej.

**Limity:** 20 równolegle (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`),
3 poziomy zagnieżdżenia (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`).

**Subagent = własny pusty kontekst + streszczenie na wyjściu.**

## Format wyniku - narzuć go

```
ZAKRES: …
ZMIENIONE: <n> wystąpień w <n> plikach
  - ścieżka:linia - opis
POMINIĘTE: <co wymaga decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ 5 linii błędu)
RYZYKA: …
```
**Limit długości obowiązkowy.** Sekcja `POMINIĘTE` najważniejsza.

## Osie podziału zadań

| Oś | Ryzyko konfliktu |
|---|---|
| Po plikach | bardzo niskie |
| Po warstwach (testy / dokumentacja / kod) | niskie |
| Po funkcjach | średnie |
| „Autor i recenzent" | **to nie jest podział równoległy** |

**Scalaj od najmniejszego zasięgu.**

## Objawy agenta w pętli

Ta sama komenda trzeci raz · „spróbuję innego podejścia" ×3 · czytanie plików bez zmian
w kodzie · rosnące ogólniki · **modyfikacja testu, żeby przeszedł** (najgroźniejszy)

Limity: `maxTurns` (frontmatter subagenta) · `timeout` hooka · `Esc` (sesja interaktywna) ·
`--max-budget-usd` **tylko z `-p`**, nie w sesji interaktywnej.
