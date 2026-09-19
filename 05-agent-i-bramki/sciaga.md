# Ściąga - moduł 5

## Zdarzenia hooków (te, które wystarczą)

| Zdarzenie | Kiedy | Typowe użycie |
|---|---|---|
| `SessionStart` | start, resume, `/clear`, kompakcja | wstrzyknięcie kontekstu (**stdout idzie do modelu**) |
| `PreToolUse` | **przed** narzędziem | blokada komend, podmiana wejścia |
| `PostToolUse` | **po** narzędziu | auto-format, walidacja |
| `Stop` | model chce zakończyć turę | bramka jakości |

Pozostałe warte znajomości: `UserPromptSubmit`, `SubagentStop`, `PreCompact`,
`SessionEnd`, `WorktreeCreate`, `FileChanged`, `PermissionRequest`.

## Kody wyjścia

| Kod | Znaczenie |
|---|---|
| **0** | sukces; stdout parsowany jako JSON, gdy zaczyna się `{` i kończy `}` |
| **2** | **BLOKADA**; komunikat z `reason` albo ze stderr |
| inny | błąd nieblokujący - akcja przechodzi |

**Blokują przy 2 (m.in.):** `PreToolUse`, `UserPromptSubmit`, `UserPromptExpansion`,
`Stop`, `SubagentStop`, `PostToolBatch`, `PreCompact`, `TaskCreated`, `TaskCompleted`,
`ConfigChange`, `PreModelSwitch`, `WorktreeCreate`/`WorktreeRemove`.
**Nie blokują - ale robią różne rzeczy:**
`PostToolUse`, `PostToolUseFailure` → **stderr trafia do modelu** ·
`SessionStart`, `SessionEnd`, `FileChanged` → stderr tylko do użytkownika ·
`PermissionRequest`, `PermissionDenied`, `Notification` → ignorują całkowicie.

**stdout trafia do modelu tylko przy:** `SessionStart`, `UserPromptSubmit`,
`UserPromptExpansion`, `PostModelSwitch`.

`systemMessage` -> **użytkownik**. `additionalContext` -> **model**.
stderr -> model, ale tylko przy blokadzie.

## Konfiguracja

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command",
                  "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/skrypt.sh",
                  "timeout": 180 }]
    }]
  }
}
```

**Matcher:** `"*"`/brak = wszystko · same litery/cyfry/`_`/`-`/`,`/`|` = string albo lista
(`Edit|Write`) · cokolwiek innego = **regex JS**, niezakotwiczony.

Typy: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

## Wejście na stdin

`session_id` · `cwd` · `scratchpad_dir` · `permission_mode` · `hook_event_name`
· zdarzenia toolowe: `tool_name`, `tool_input`, `tool_use_id`

> **`${CLAUDE_PROJECT_DIR}`** = katalog startu sesji, **nie zmienia się** w worktree.
> **`cwd`** = idzie za sesją. Bramka musi używać `cwd`.

## Bramka na `Stop` - maszyna stanów

```
zielona                          → exit 0
czerwona, stop_hook_active=false → exit 2, wynik na stderr
czerwona, stop_hook_active=true  → exit 0 + {"systemMessage": "..."}
```

Wejście `Stop` niesie **`stop_hook_active`** (`true`, gdy tura trwa dalej przez poprzednią
blokadę) oraz twardy limit: po **8 kolejnych blokadach** Claude Code kończy turę sam.
Własny znacznik jest niepotrzebny. `jq -r '.stop_hook_active // false'` - pole może nie przyjść.

## Pliki ustawień - precedencja

1. Managed · 2. `claude --settings` · 3. `.claude/settings.local.json` ·
4. **`.claude/settings.json`** (commitowany) · 5. `~/.claude/settings.json`

Listy (`permissions.allow`) **łączą się**. `deny` i `ask` działają natychmiast;
`allow` czeka na zaufanie folderu. Weryfikacja: `/hooks`, `/status`.

## Skille

```
.claude/skills/<nazwa-katalogu>/SKILL.md
```

**Nazwa komendy z katalogu**, nie z pola `name`.

```yaml
---
name: Nazwa wyświetlana
description: kiedy po to sięgać i do czego NIE służy
argument-hint: "[zakres]"
allowed-tools: Bash(git diff *), Read, Grep
---
```

Wstrzyknięcie wyniku komendy - uruchamia się **zanim model zobaczy treść**:

````markdown
!`git diff HEAD`
````

## Kiedy co

| | Kiedy działa | Kto decyduje |
|---|---|---|
| `CLAUDE.md` | zawsze, jako kontekst | model, czy zastosować |
| Skill | na wywołanie | **człowiek, że teraz** |
| Hook | przy zdarzeniu | nikt, dzieje się |
