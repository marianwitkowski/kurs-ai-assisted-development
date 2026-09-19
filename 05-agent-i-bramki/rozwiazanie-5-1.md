# Rozwiązanie wzorcowe - lab 5.1

```bash
git show lab-5-2-start:.claude/settings.json
git show lab-5-2-start:.claude/hooks/bramka.sh
git diff lab-5-1-start lab-5-2-start
```

---

## Krok 1 - czego dowodzi pierwszy pomiar

Reguła z `CLAUDE.md` („zmiana w `app/` bez testu wymaga wyraźnej zgody") jest **kontekstem,
nie egzekucją**. Model dostaje ją jako wiadomość użytkownika po prompcie systemowym,
czyta ją i zwykle stosuje.

„Zwykle" jest tu słowem kluczowym. Przy tym samym prompcie raz dostaniesz test, raz wzmiankę
„nie dopisałem testu", raz nic. Nie ma w tym błędu - tak działa kontekst.

To nie jest argument przeciw `CLAUDE.md`. To jest argument za tym, żeby **wiedzieć,
czego się po nim spodziewać**: konwencji tak, gwarancji nie.

---

## Krok 3 - hook formatujący

```bash
plik=$(printf '%s' "$wejscie" | jq -r '.tool_input.file_path // ""')
katalog=$(printf '%s' "$wejscie" | jq -r '.cwd // "."')

[[ "$plik" == *.py ]] || exit 0
[[ -f "$plik" ]] || exit 0

ruff=""
for kandydat in "$katalog/.venv/bin/ruff" "$(command -v ruff || true)"; do
  [[ -x "$kandydat" ]] && { ruff="$kandydat"; break; }
done
[[ -n "$ruff" ]] || exit 0

"$ruff" format -q "$plik" >/dev/null 2>&1 || true
exit 0
```

Cztery decyzje warte uwagi:

| Decyzja | Dlaczego |
|---|---|
| `// ""` w jq i sprawdzenie `-f` | pole może nie istnieć; hook nie ma prawa się wywalić |
| tylko `.py` | `ruff format` na `.md` to hałas w diffie |
| jeden plik, nie katalog | `ruff format app/` dorzuca do diffa pliki, których nikt nie ruszał |
| `\|\| true` i zawsze `exit 0` | brak `ruff` w PATH nie może zatrzymać pracy |

Ostatni punkt wymaga doprecyzowania, bo łatwo go zapamiętać źle. `PostToolUse`
**nie potrafi zablokować** - narzędzie już się wykonało. Ale kod 2 **nie jest tam
ignorowany**: stderr trafia wtedy **do modelu**.

To jest jedyny sposób, żeby hook `PostToolUse` powiedział coś modelowi - przy kodzie 0
stderr idzie wyłącznie do logu debugowania. Przydatne np. w hooku, który waliduje to,
co właśnie powstało, i chce zgłosić problem.

Dla hooka **formatującego** i tak chcemy `exit 0`: formatowanie nie jest problemem,
o którym model ma się dowiedzieć.

---

## Krok 4 - hook blokujący

Wzorcowa lista ma **siedem** pozycji:

```bash
wzorce=(
  'rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-{1,2}[rRf]'
  'git[[:space:]]+push[[:space:]]+.*--force'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+.*-[a-zA-Z]*f'
  'DROP[[:space:]]+TABLE'
  'chmod[[:space:]]+777'
  '>[[:space:]]*/dev/sd'
)
```

Wynik testu:

| Komenda | Wynik |
|---|---|
| `rm -rf /tmp/x` | **2** |
| `git push --force origin main` | **2** |
| `git reset --hard HEAD~3` | **2** |
| `DROP TABLE faktury` | **2** |
| `chmod 777 app` | **2** |
| `git status` | 0 |
| `make test` | 0 |
| **`rm plik.txt`** | **0** |
| **`git push origin main`** | **0** |

Dwa ostatnie wiersze są ważniejsze od pięciu pierwszych.

**Dlaczego lista musi być krótka.** Hook blokujący ma jedną realną wadę: fałszywe trafienie
zatrzymuje pracę. Człowiek, któremu hook zablokuje `rm plik.txt`, po drugim razie wyłączy
cały hook - i zostanie bez `rm -rf` też. Siedem wzorców, które ktoś faktycznie wykona
przez pomyłkę, chroni lepiej niż siedemdziesiąt wyobrażonych.

Komunikat idzie na **stderr**, bo przy kodzie 2 to stderr trafia do modelu i do użytkownika:

```bash
echo "Zablokowane przez hook projektu: komenda pasuje do wzorca '${wzorzec}'." >&2
echo "Jezeli naprawde tego potrzebujesz, uruchom to sam w terminalu." >&2
exit 2
```

Drugie zdanie jest celowe. Hook nie ma udawać, że czegoś się nie da - ma wymusić,
żeby zrobił to człowiek świadomie.

---

## Krok 5 - bramka i ochrona przed pętlą

To jest najważniejszy fragment całego modułu - i miejsce, w którym najłatwiej napisać
poprawne rozwiązanie złego problemu.

```bash
juz_blokowano=$(printf '%s' "$wejscie" | jq -r '.stop_hook_active // false')

if wynik=$(make gate 2>&1); then
  exit 0
fi

if [[ "$juz_blokowano" == "true" ]]; then
  printf '%s\n' "$wynik" | tail -20 >&2
  jq -n '{systemMessage: "Bramka jakosci nadal jest czerwona po probie naprawy..."}'
  exit 0
fi

{ echo "Bramka jakosci jest czerwona - nie moge zakonczyc pracy."; printf '%s\n' "$wynik" | tail -30; } >&2
exit 2
```

Wynik testu:

```
1. czerwona, pierwsza proba -> 2   (blokada)
2. czerwona, po blokadzie   -> 0   (nie blokujemy w kółko)
3. zielona                  -> 0
4. znowu czerwona           -> 2   (uzbrojenie wraca samo)
5. brak pola w JSON         -> 0   (domyslka // false)
```

### Dlaczego to jest ważniejsze niż sam hook

Naturalny odruch przy tym zadaniu brzmi: *„muszę zapamiętać, że już blokowałem"* - i piszesz
plik-znacznik w `scratchpad_dir`, kluczowany po `session_id`, kasowany przy zielonej bramce.

Ta wersja **działa**. Jest tylko:

- dwa razy dłuższa,
- wymaga obsługi `scratchpad_dir`, które bywa nieobecne (`${TMPDIR:-/tmp}`),
- wymaga pamiętania o kasowaniu znacznika przy zielonej bramce - a bez tego hook
  blokuje **raz na sesję** i przez resztę pracy jest martwy, czego nie widać,
- i rozwiązuje problem, który Claude Code już rozwiązał.

Schemat wejścia zdarzenia `Stop` niesie:

| Pole / mechanizm | Co daje |
|---|---|
| `stop_hook_active` | `true`, gdy tura trwa dalej **przez poprzednią blokadę** tego hooka |
| limit 8 kolejnych blokad | Claude Code nadpisuje hook i kończy turę sam |

Uzbrojenie wraca samo, bo `stop_hook_active` jest `false` w każdej turze rozpoczętej
normalnie. Nie ma czego kasować.

> **Przeczytaj schemat wejścia, zanim napiszesz obejście.**
>
> To jest ta sama zasada, co żądanie cytatu z modułu 1: sprawdź, co **jest**, zamiast
> zakładać, czego **nie ma**. Różnica polega na tym, że tutaj obejście przechodzi testy,
> działa na sali i nikt nigdy się nie dowie, że było zbędne.

### Jedna rzecz, która zostaje bez zmian

```bash
katalog=$(printf '%s' "$wejscie" | jq -r '.cwd // "."')
cd "$katalog" || exit 0
```

`${CLAUDE_PROJECT_DIR}` wskazuje katalog, w którym **wystartowała sesja**, i **nie zmienia się**,
gdy model wejdzie w git worktree. Pole `cwd` idzie za sesją.

Hook używający `${CLAUDE_PROJECT_DIR}` w module 6 testowałby główny checkout zamiast worktree -
i przepuszczałby zielone testy dla kodu, którego nikt nie zmieniał. To jest trudny do wykrycia
fałszywy spokój, bo bramka **świeci na zielono**.

---

## Dlaczego `.claude/settings.json`, a nie `~/.claude/settings.json`

| | `~/.claude/settings.json` | `.claude/settings.json` |
|---|---|---|
| Kto ma | ty | cały zespół po `git pull` |
| Zmiana | edytujesz plik | pull request |
| Historia | brak | `git log` |
| Nowy człowiek w zespole | nie ma | ma od pierwszego dnia |

Hook w katalogu domowym to twoja prywatna wygoda. Hook w repozytorium to **standard zespołu**
- i dlatego może być przedmiotem dyskusji, a nie tylko twoją preferencją.

Uwaga na precedencję: `permissions.allow` z pliku projektowego czeka na **zaufanie folderu**
przez każdego członka zespołu. Reguły `deny` i `ask` działają natychmiast.
Dlatego blokady wpisuj jako `deny`.

---

## Najczęstsze potknięcia

**`exit 1` zamiast `exit 2`.** Blokuje wyłącznie 2. Przy 1 akcja przechodzi,
a w transkrypcie pojawia się notka `hook error` - łatwa do przeoczenia.

**Formatowanie katalogu w `PostToolUse`.** Diff puchnie o pliki, których nikt nie dotykał.
Po dwóch dniach review staje się nieczytelne i ktoś wyłącza hook.

**Bramka bez limitu czasu.** `make gate` na dużym projekcie może trwać minuty.
Domyślny timeout hooka to 600 s, ale w tym repozytorium ustawiamy 180 s -
lepiej, żeby bramka poddała się szybko, niż żeby sesja stała.

**Blokada, której nie da się obejść świadomie.** Hook ma chronić przed pomyłką,
nie przed człowiekiem. Komunikat zawsze mówi, co zrobić, gdy naprawdę trzeba.
