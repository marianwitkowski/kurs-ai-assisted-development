# Rozwiązanie wzorcowe - lab 6.2

```bash
git show lab-7-1-start:.claude/agents/migrator.md
```

---

## Frontmatter

```yaml
---
name: migrator
description: Wykonuje mechaniczne, powtarzalne przeksztalcenia w wielu plikach naraz - zamiane przestarzalego API, ujednolicenie importow, przeniesienie stalej. Uzywaj, gdy zmiana jest jednoznaczna i chodzi wylacznie o jej konsekwentne zastosowanie. NIE uzywaj do zmian wymagajacych decyzji projektowej.
tools: Read, Edit, Write, Grep, Glob, Bash
model: sonnet
isolation: worktree
maxTurns: 25
color: cyan
---
```

| Pole | Decyzja |
|---|---|
| `description` | dwa zdania: kiedy używać i **kiedy nie**. Model czyta to, decydując, czy sięgnąć po agenta sam |
| `tools` | bez `WebFetch`, bez `Task` - przekształcenie mechaniczne ich nie potrzebuje |
| `model: sonnet` | zadanie nie wymaga rozumowania, wymaga konsekwencji |
| `isolation: worktree` | agent pracuje we własnym katalogu; główny checkout zostaje nietknięty |
| `maxTurns: 25` | **jedyny hamulec bez udziału człowieka**, który zatrzyma pętlę - subagenta nie widać w trakcie (pozostałe twarde limity: teoria.md) |

### Zdanie, które robi najwięcej

> **NIE uzywaj do zmian wymagajacych decyzji projektowej.**

Bez niego model sięgnie po migratora przy zadaniu typu „ujednolić obsługę błędów w API" -
które wygląda mechanicznie, a wymaga decyzji o tym, jak ma wyglądać wynik.

Opis subagenta to nie dokumentacja dla człowieka. To jest **kryterium wyboru dla modelu**.

---

## Treść: kolejność pracy

```markdown
1. **Inwentaryzacja przed zmiana.** Znajdz wszystkie wystapienia (`Grep`) i wypisz je
   z plikami oraz numerami linii. Policz je.
2. **Klasyfikacja.** Podziel wystapienia na mechaniczne i takie, ktore zmieniaja zachowanie.
   Jezeli ktorekolwiek nalezy do drugiej grupy - **zatrzymaj sie i zapytaj**, zamiast zgadywac.
3. **Zmiana.** Wykonaj przeksztalcenie w grupie mechanicznej.
4. **Weryfikacja.** `make gate`. Bramka musi byc zielona przed zakonczeniem.
```

Krok 2 jest tym, który odróżnia migratora od `sed -i`. Agent ma **prawo się zatrzymać** -
i to prawo musi być zapisane, inaczej dokończy zadanie po swojemu, bo tak brzmiało zlecenie.

---

## Format wyniku

```
ZAKRES: <co mialo byc zmienione>
ZMIENIONE: <liczba> wystapien w <liczba> plikach
  - sciezka:linia - opis zmiany
POMINIETE: <wystapienia, ktore wymagaja decyzji, z uzasadnieniem>
BRAMKA: zielona | czerwona (+ pierwsze 5 linii bledu)
RYZYKA: <co moze sie zepsuc, czego nie sprawdzilem>
```

Limit: 40 linii.

**Dlaczego `POMINIĘTE` jest najważniejsze.** Subagent, który nie ma tej sekcji, ma dwa
wyjścia: zrobić wszystko po swojemu albo zatrzymać się bez wyjaśnienia. Sekcja daje trzecie:
zrobić część i **powiedzieć, czego nie ruszył i dlaczego**.

**Dlaczego limit długości.** Bez niego streszczenie rozrasta się do transkryptu, a cały
zysk kontekstowy znika. Subagent istnieje po to, żeby gadatliwe wyjście **zostało u niego**.

**Dlaczego `BRAMKA` jako osobne pole.** Bez tego „gotowe" znaczy „skończyłem pisać",
a nie „testy przechodzą". Pole wymusza uruchomienie.

---

## Co naprawdę wraca do sesji głównej

| | Widoczne |
|---|---|
| Które pliki agent przeczytał | **nie** - zostało w jego kontekście |
| Wynik jego pracy | **tak** - streszczenie + diff |
| Jak doszedł do wyniku | **nie** |
| Ile to kosztowało | tak, w `/usage` (atrybucja subagentów) |

Przyrost kontekstu w sesji głównej to kilkanaście linii streszczenia, niezależnie od tego,
czy agent przeczytał trzy pliki, czy trzydzieści. **To jest cała wartość subagenta.**

---

## Kiedy subagent, a kiedy sesja główna

| | Subagent | Sesja główna |
|---|---|---|
| Zadanie | oceniane po wyniku | trzeba widzieć drogę |
| Przykład | migracja API, inwentaryzacja, masowy rename | decyzja architektoniczna, debug nieznanego błędu |
| Kontekst | oszczędność | koszt |
| Kontrola w trakcie | brak | `Esc` |

**Kryterium jest jedno: czy wynik da się ocenić bez oglądania drogi.**

Migracja `utcnow()` → tak, wystarczy diff i zielona bramka.
„Dlaczego ten raport pokazuje złe kwoty" → nie, cała wartość jest w drodze,
a błędna hipoteza postawiona w trzeciej turze zniknie ze streszczenia.

---

## Najczęstsze potknięcia

**Brak `maxTurns`.** Subagenta nie widać. Limit tur jest jedynym hamulcem
działającym bez udziału człowieka, który przerwie pętlę, zanim zje budżet.

**`description` mówiące tylko, co agent robi.** Połowa wartości opisu to zdanie
o tym, do czego agent **nie** służy.

**Zlecenie zadania wymagającego decyzji.** Wróci streszczenie mówiące, że zdecydował,
bez pokazania podstaw. Diff będzie wyglądał sensownie. Problem wyjdzie za miesiąc.

**Odziedziczone wszystkie narzędzia.** Mniej narzędzi to mniejszy kontekst startowy
i mniej sposobów na zboczenie z zadania.

**Streszczenie bez limitu.** Trzysta linii „streszczenia" to transkrypt w przebraniu.
