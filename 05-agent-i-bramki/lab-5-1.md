# Lab 5.1 - Trzy hooki i deterministyczna bramka

**Czas: ~45 min** · **Tag startowy: `lab-5-1-start`** · **Produkt: `.claude/settings.json`, `.claude/hooks/*.sh`, cel `gate` w `Makefile`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-5-1-start
make test          # 32 testy zielone
jq --version       # potrzebne do hooków; brak -> brew install jq / apt install jq
```

> **Masz niezacommitowaną pracę z poprzedniego labu?** `git checkout` ją zablokuje -
> także pliki **nieśledzone** (hooki, `tests/`, `docs/`). Odłóż wszystko jedną komendą:
>
> ```bash
> git stash push -u -m "moje-4-3"
> ```
>
> Wracasz do niej przez `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.
>
> **Ten lab kończy się commitem, a `git checkout <tag>` stawia repozytorium
> w odpiętym `HEAD`.** Commit nie należy wtedy do żadnej gałęzi i przy skoku
> na kolejny tag przestaje być osiągalny. Git ostrzeże o tym po angielsku
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-5-1`
> **przed** skokiem.


---

## Cel

Zamienić trzy prośby z `CLAUDE.md` na trzy mechanizmy, których model nie może zignorować -
i zobaczyć różnicę na własne oczy.

---

## Krok 1 - pokaz różnicy: prośba kontra egzekucja (7 min)

`CLAUDE.md` w tym repozytorium zawiera regułę:

> Zmiana w `app/` bez testu wymaga wyraźnej zgody - napisz, że go nie ma, zamiast zakładać,
> że nie jest potrzebny.

Sprawdź, jak działa **jako prośba**:

```
Dodaj do app/vat.py funkcję stawka_efektywna(netto, vat), która zwraca
efektywną stawkę VAT jako Decimal. Krótko, bez ceregieli.
```

Zanotuj: czy model dopisał test? Czy chociaż wspomniał, że go nie ma?

Powtórz to samo kilka razy albo poproś sąsiada o porównanie. **Wynik bywa różny** -
i to jest cała pointa. Prośba działa w większości przypadków. W większości, nie zawsze.

```bash
git checkout -- app/ && rm -f tests/test_vat.py
```

---

## Krok 2 - bramka w `Makefile` (5 min)

Zanim będzie hook, musi być co uruchamiać.

```bash
cat >> Makefile <<'EOF'

gate:
	@ruff check app tests
	@pytest -q
EOF
make gate
```

> Uwaga: `gate` to **na razie** lint i testy. Skan sekretów dołożysz w module 8 -
> gdyby wszedł teraz, znalazłby coś, czego jeszcze nie szukamy.
>
> `pytest` pokazuje 4 ostrzeżenia `DeprecationWarning` z `datetime.utcnow()`.
> Bramka ich **nie** traktuje jako czerwonych. Usuniesz je jutro w labie 6.1.

---

## Krok 3 - hook formatujący (8 min)

`PostToolUse`, matcher `Edit|Write`. Ma sformatować **tylko plik, który właśnie powstał**,
i **nigdy** nie zatrzymywać pracy.

```
Napisz .claude/hooks/format-po-edycji.sh oraz wpis w .claude/settings.json.

Hook dostaje na stdin JSON. Interesują cię pola:
  .tool_input.file_path  - plik, który zmieniono
  .cwd                   - katalog roboczy sesji

Wymagania:
- parsuj JSON przez jq,
- działaj tylko na plikach .py, które istnieją,
- uruchom `ruff format` na TYM JEDNYM pliku, nie na katalogu,
- szukaj ruff najpierw w .venv/bin, potem w PATH,
- ZAWSZE kończ kodem 0, nawet gdy ruff nie istnieje albo się wywali.
- zrób plik wykonywalnym.

Matcher w settings.json: "Edit|Write".
Ścieżkę podaj jako ${CLAUDE_PROJECT_DIR}/.claude/hooks/format-po-edycji.sh
```

**Test bez Claude Code** - hook to zwykły skrypt, sprawdź go wprost:

```bash
cat > app/_test_hook.py <<'EOF'
def   f( a,b ):
    return a+b
EOF
echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PWD/app/_test_hook.py\"},\"cwd\":\"$PWD\"}" \
  | .claude/hooks/format-po-edycji.sh; echo "exit=$?"
cat app/_test_hook.py     # ma być sformatowane
rm app/_test_hook.py
```

Sprawdź też przypadki brzegowe - `.md` zamiast `.py`, plik, którego nie ma.
Oba mają dać `exit=0` i nic nie zrobić.

---

## Krok 4 - hook blokujący (10 min)

`PreToolUse`, matcher `Bash`, `exit 2` przy trafieniu.

```
Napisz .claude/hooks/blokuj-niebezpieczne.sh.

Czyta z stdin JSON, bierze .tool_input.command przez jq.
Jeżeli komenda pasuje do któregoś wzorca - wypisz powód na stderr i zakończ kodem 2.
W przeciwnym razie kod 0.

Lista wzorców ma być KRÓTKA i OCZYWISTA. Zaproponuj maksymalnie 7 pozycji
i uzasadnij każdą jednym zdaniem.
```

**Dlaczego krótka.** Długa lista daje złudzenie bezpieczeństwa, blokuje pracę przy pierwszym
fałszywym trafieniu i kończy się tym, że ktoś wyłącza cały hook. Siedem oczywistych
wzorców, które ktoś faktycznie wykona, bije siedemdziesiąt teoretycznych.

**Test:**

```bash
for c in "rm -rf /tmp/x" "git push --force origin main" "git reset --hard HEAD~3" "DROP TABLE faktury"; do
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$c\"}}" | .claude/hooks/blokuj-niebezpieczne.sh 2>/dev/null
  printf "%-32s exit=%s (ma być 2)\n" "$c" "$?"
done
for c in "git status" "make test" "rm plik.txt" "git push origin main"; do
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$c\"}}" | .claude/hooks/blokuj-niebezpieczne.sh 2>/dev/null
  printf "%-32s exit=%s (ma być 0)\n" "$c" "$?"
done
```

**Fałszywe trafienie jest gorsze niż przepuszczenie.** `rm plik.txt` musi przejść.
Jeśli twój wzorzec blokuje każde `rm`, hook przeżyje jeden dzień.

---

## Krok 5 - bramka na `Stop` (12 min)

To jest hook, który realnie zmienia sposób pracy. I to jest hook, przy którym najłatwiej
napisać obejście problemu, który został już rozwiązany za ciebie.

**Zanim napiszesz prompt, przeczytaj schemat wejścia.** Zdarzenie `Stop` dostaje na stdin
pola wspólne plus `stop_hook_active`, `last_assistant_message`, `background_tasks`
i `session_crons`. Jedno z nich jest tu kluczowe.

```
Napisz .claude/hooks/bramka.sh dla zdarzenia Stop.

Ma uruchamiać `make gate` i nie pozwalać zakończyć tury, gdy bramka jest czerwona.

OCHRONA PRZED PĘTLĄ. Exit 2 na Stop każe modelowi pracować dalej, więc hook, który
zawsze zwraca 2 przy czerwonej bramce, zapętliłby sesję. Claude Code daje na to dwa
mechanizmy, oba w schemacie wejścia zdarzenia Stop:
  - pole .stop_hook_active - true, gdy tura trwa dalej WŁAŚNIE dlatego,
    że poprzedni hook Stop ją zablokował,
  - twardy limit: po 8 kolejnych blokadach Claude Code kończy turę sam.

Użyj pola .stop_hook_active. NIE pisz własnego znacznika w pliku - wejście
już niesie tę informację.

Maszyna stanów:
  bramka zielona                   -> exit 0
  czerwona, stop_hook_active=false -> exit 2, wynik na stderr
  czerwona, stop_hook_active=true  -> exit 0 + JSON {"systemMessage": "..."}

Bramkę uruchom w katalogu z pola .cwd, NIE w ${CLAUDE_PROJECT_DIR}.
Powiedz mi, dlaczego to ma znaczenie.
```

Ostatnie zdanie jest testem dla agenta. Poprawna odpowiedź: w git worktree te dwie ścieżki
są różne, więc hook używający `${CLAUDE_PROJECT_DIR}` testowałby główny checkout zamiast
worktree, w którym faktycznie pracuje sesja. Zobaczysz to jutro w labie 6.1.

### Dlaczego to jest ważniejsze niż sam hook

Odruch przy tym zadaniu brzmi: „muszę jakoś zapamiętać, że już blokowałem" - i piszesz
plik-znacznik w `scratchpad_dir`, kluczowany po `session_id`. To działa. Jest dwa razy
dłuższe, wymaga obsługi nieobecnego pola `scratchpad_dir` i trzeba pamiętać o kasowaniu
znacznika przy zielonej bramce, bo inaczej hook blokuje **raz na sesję** i przez resztę
pracy jest martwy.

Jedno pole na wejściu robi to wszystko - i wraca do stanu wyjściowego samo, bo
`stop_hook_active` jest `false` w każdej turze rozpoczętej normalnie.

> **Przeczytaj schemat wejścia, zanim napiszesz obejście.** To jest ta sama zasada,
> co żądanie cytatu z modułu 1: sprawdź, co jest, zamiast zakładać, czego nie ma.

### Test maszyny stanów

```bash
WE_PIERWSZA='{"cwd":"'"$PWD"'","stop_hook_active":false}'
WE_KOLEJNA='{"cwd":"'"$PWD"'","stop_hook_active":true}'

printf 'def test_czerwony():\n    assert 1 == 2\n' > tests/test_czerwony.py

echo "$WE_PIERWSZA" | .claude/hooks/bramka.sh >/dev/null 2>&1; echo "1. czerwona, pierwsza proba -> $?  (ma być 2)"
echo "$WE_KOLEJNA"  | .claude/hooks/bramka.sh >/dev/null 2>&1; echo "2. czerwona, po blokadzie   -> $?  (ma być 0)"
rm tests/test_czerwony.py
echo "$WE_PIERWSZA" | .claude/hooks/bramka.sh >/dev/null 2>&1; echo "3. zielona                  -> $?  (ma być 0)"
printf 'def test_czerwony():\n    assert 1 == 2\n' > tests/test_czerwony.py
echo "$WE_PIERWSZA" | .claude/hooks/bramka.sh >/dev/null 2>&1; echo "4. znowu czerwona           -> $?  (ma być 2)"
rm tests/test_czerwony.py

echo '{"cwd":"'"$PWD"'"}' | .claude/hooks/bramka.sh >/dev/null 2>&1; echo "5. brak pola w JSON         -> $?  (ma być 0)"
```

**Krok 5 jest sednem testu.** Pole `stop_hook_active` może nie przyjść - `jq -r '.stop_hook_active // false'`
musi dać wartość domyślną, inaczej hook porówna pusty string i zachowa się nieprzewidywalnie.

---

## Krok 6 - sprawdzenie na żywo (3 min)

```
/hooks
```

Wszystkie trzy mają być widoczne pod swoimi zdarzeniami. Potem powtórz krok 1:

```
Dodaj do app/vat.py funkcję stawka_efektywna(netto, vat), która zwraca
efektywną stawkę VAT jako Decimal. Krótko, bez ceregieli.
```

Teraz, gdy model spróbuje zakończyć turę, hook `Stop` uruchomi `make gate`.
Jeśli funkcja nie ma testu - testy przejdą (bramka nie sprawdza pokrycia), ale jeśli
`ruff` zgłosi cokolwiek, model nie zakończy pracy, dopóki tego nie naprawi.

Żeby zobaczyć blokadę wprost, poproś o coś, co zepsuje lint:

```
Dodaj na początku app/vat.py import os. Nie używaj go nigdzie.
```

`ruff` zgłosi nieużywany import, bramka zrobi się czerwona, hook zablokuje zakończenie.
**To jest ta sama reguła co w `CLAUDE.md` - tyle że teraz nie da się jej zignorować.**

```bash
git checkout -- app/
git add .claude/ Makefile
git commit -m "Hooki: format po edycji, blokada niebezpiecznych komend, bramka na Stop"
```

---

## Kryteria zaliczenia

- [ ] `/hooks` pokazuje trzy hooki pod właściwymi zdarzeniami.
- [ ] Hook formatujący działa na `.py`, ignoruje resztę, zawsze kończy kodem 0.
- [ ] Hook blokujący zwraca 2 na wzorce i 0 na `rm plik.txt` oraz `git push origin main`.
- [ ] Bramka przechodzi wszystkie cztery stany testu, łącznie z ponownym uzbrojeniem.
- [ ] Bramka używa `.cwd`, nie `${CLAUDE_PROJECT_DIR}` - i wiesz dlaczego.
- [ ] Widziałeś blokadę na żywo: model nie mógł zakończyć tury przy czerwonym lincie.
- [ ] `.claude/settings.json` jest **zacommitowany** - to standard zespołu, nie twoje ustawienie.

## Pułapki

**Hook w `~/.claude/settings.json` zamiast w repo.** Wtedy to jest twoja prywatna wygoda,
a nie standard zespołowy. Cała teza tego modułu brzmi: reguła w repo przechodzi przez review.

**Własny znacznik zamiast `stop_hook_active`.** Działa, ale jest dwa razy dłuższy
i wymaga pamiętania o kasowaniu przy zielonej bramce. Zajrzyj do schematu wejścia,
zanim napiszesz obejście.

**Za długa lista blokad.** Jeśli zablokowałeś `rm` w ogóle, `git push` w ogóle albo
`curl` - zablokowałeś pracę, nie ryzyko. Po dwóch godzinach ktoś wyłączy hook i zostaniesz
bez niczego.

**Formatowanie całego katalogu w hooku `PostToolUse`.** `ruff format app/` przy każdej edycji
dorzuca do diffa pliki, których nikt nie ruszał, i robi review nieczytelnym.
Formatuj wyłącznie `.tool_input.file_path`.

**`exit 1` zamiast `exit 2`.** Kod 1 to błąd nieblokujący: akcja przechodzi, a ty widzisz
tylko notkę w transkrypcie. Blokuje wyłącznie **2**.

**Brak `jq`.** Hooki parsujące JSON grepem działają do pierwszego cudzysłowu w komendzie.

---

[Rozwiązanie wzorcowe](rozwiazanie-5-1.md) · [Następny lab](lab-5-2.md)
