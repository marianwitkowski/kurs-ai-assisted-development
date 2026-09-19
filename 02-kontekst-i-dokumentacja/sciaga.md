# Ściąga - moduł 2

## Pliki kontekstowe: gdzie i w jakiej kolejności

| Zakres | Ścieżka |
|---|---|
| Managed | macOS `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux/WSL `/etc/claude-code/CLAUDE.md`<br>Windows `C:\Program Files\ClaudeCode\CLAUDE.md` |
| Użytkownik | `~/.claude/CLAUDE.md` |
| Projekt | `./CLAUDE.md` albo `./.claude/CLAUDE.md` |
| Lokalny | `./CLAUDE.local.md` (do `.gitignore`) |

- Pliki **sklejają się**, nie nadpisują. Od korzenia w dół do katalogu startu sesji.
- Podkatalogi ładują się **na żądanie**, gdy model czyta plik z tego katalogu.
- Cel: **poniżej 200 linii**. Powyżej 4 MiB plik jest pomijany w całości.
- Komentarze `<!-- … -->` są **wycinane** przed wysłaniem do modelu.
- Po `/compact` projektowy `CLAUDE.md` z korzenia jest **czytany ponownie z dysku**.

## Import

```markdown
Przegląd: @README.md
```

Maks. **4 poziomy**. Parser pomija bloki i spany kodu: `` `@README` `` to zwykły tekst.
**Import nie oszczędza kontekstu** - ładuje się przy starcie tak samo.

`AGENTS.md` w repo? Nie duplikuj:

```markdown
@AGENTS.md

## Claude Code
<instrukcje specyficzne>
```

## Reguły z zakresem ścieżek

`.claude/rules/nazwa.md`:

```markdown
---
paths:
  - "app/**/*.py"
  - "src/**/*.{ts,tsx}"
---
```

Bez `paths:` - ładowane zawsze. Z `paths:` - dopiero przy dotknięciu pasującego pliku.

## Komendy

| Komenda | Do czego |
|---|---|
| `/init` | generuje startowy `CLAUDE.md` (czyta też reguły Cursora i Copilota) |
| `/memory` | lista i edycja plików pamięci |
| `/context` | sekcja **Memory files** = co faktycznie się załadowało |
| `/doctor` | proponuje przycięcie `CLAUDE.md` |
| `/mcp` | serwery MCP, wyłączanie nieużywanych |

## Cztery warstwy standardów

| Warstwa | Siła | Kiedy |
|---|---|---|
| `CLAUDE.md`, reguły | model *stara się* | konwencje, kontekst, pułapki |
| Skill | procedura na wywołanie | powtarzalne workflow |
| Hook | **zawsze** | format, blokady, bramki |
| CI | **blokuje scalenie** | ostateczna bramka |

Test: **„co się stanie, jeśli model to zignoruje?"**

## Czego nie pisać w `CLAUDE.md`

Sekretów · danych osobowych · listy katalogów · listy zależności · opisu, co robi każda
funkcja · reguł, które **muszą** zadziałać (→ hook) · długich procedur (→ skill).
