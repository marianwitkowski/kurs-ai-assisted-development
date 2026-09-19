# Lab 2.2 - Pliki kontekstowe dla tego repozytorium

**Tag startowy: `lab-2-2-start`** · **Produkt: `CLAUDE.md`, `docs/architektura.md`**

---

## Stan startowy

```bash
cd repo-cwiczeniowe
git checkout lab-2-2-start
```

> **Niezacommitowana praca z poprzedniego labu blokuje `git checkout`** - także pliki
> **nieśledzone** (hooki, `tests/`, `docs/`). Wszystko odkłada jedna komenda:
>
> ```bash
> git stash push -u -m "moje-2-1"
> ```
>
> Powrót do niej: `git stash list` i `git stash apply stash@{0}`.
>
> `git switch -c` **nie wystarczy** - nie commituje niczego, więc ani nie zachowuje pracy,
> ani nie odblokowuje skoku na tag.
>
> **Ten lab kończy się commitem, a `git checkout <tag>` stawia repozytorium
> w odpiętym `HEAD`.** Commit nie należy wtedy do żadnej gałęzi i przy skoku
> na kolejny tag przestaje być osiągalny. Git ostrzeże o tym po angielsku
> i poda komendę ratunkową; prościej wyprzedzić go przez `git branch moje-2-2`
> **przed** skokiem.


---

## Cel

Napisać pliki kontekstowe, które **zmierzalnie** zmieniają zachowanie agenta: ta sama prośba
przed i po ma dać inny wynik. I nauczyć się rozpoznawać, co do takiego pliku **nie należy**.

---

## Krok 1 - pomiar „przed"

Świeża sesja; odpowiedź zapisać dosłownie:

```bash
claude
```

```
Chcę zmienić zaokrąglanie VAT w app/rozliczenia.py: zamiast zaokrąglać per pozycja,
policz VAT raz, od sumy netto całej faktury. To prostsze i mniej kodu.

Nie pisz jeszcze kodu - powiedz mi tylko, jak to zrobisz i czego będę potrzebował,
żeby mieć pewność, że niczego nie zepsułem.
```

**Do notatek:**
- czy **ostrzegł**, że to zmienia kwoty na fakturach, czy po prostu zaplanował zmianę,
- czy zauważył, że w repozytorium **nie ma żadnych testów** tej funkcji,
- czy powiedział, jak w tym projekcie w ogóle uruchamia się testy,
- czy zapytał, czy wolno mu to ruszać.

Model nie ma na tym etapie pisać kodu. Istotne jest to, co **założy**, gdy nikt mu nie powiedział.

> **Dlaczego akurat to pytanie.** Wcześniejsza wersja tego kroku pytała o typ liczbowy
> (`float` czy `Decimal`). To był zły pomiar: prompt sam wskazywał `app/vat.py`, gdzie
> `Decimal` stoi kilkanaście razy, więc model trafiał bez `CLAUDE.md` i pomiar „przed"
> nie różnił się od „po".
>
> Pytanie o zaokrąglanie VAT nie ma odpowiedzi **nigdzie w kodzie**. To, że ta zmiana
> jest kosztowna, wie tylko człowiek - i dokładnie po to jest plik kontekstowy.

```
/clear
```

---

## Krok 2 - szkic przez `/init`

```
/init
```

Claude Code przeanalizuje repo i zaproponuje startowy `CLAUDE.md`.

**Plik nie może zostać w tej postaci.** Wymaga krytycznego przeczytania i oznaczenia
(mentalnie albo w notatkach), które linie:
- **model przeczytałby sam z kodu** → do usunięcia,
- są **prawdziwe i nieoczywiste** → zostają,
- są **zgadywaniem** → do usunięcia albo sprawdzenia.

Typowo `/init` produkuje sporo pierwszej kategorii: listę katalogów, listę zależności,
opis „co robi każdy moduł". To jest dokładnie to, przed czym ostrzega teoria.

---

## Krok 3 - przepisanie `CLAUDE.md`

Napisać plik **poniżej 60 linii**. Ma zawierać wyłącznie to, czego model nie wyczyta z kodu.

Minimum, które musi się znaleźć:

1. **Jak uruchomić i zweryfikować** - konkretne komendy (`python seed.py`, `make test`, `make lint`).
2. **Konwencje, które nie są domyślne** - polskie nazwy domenowe, kwoty jako `Decimal`,
   długość linii 100.
3. **Ostrzeżenie o `app/rozliczenia.py`** - że `oblicz_fakture()` zawiera **nieudokumentowane
   reguły biznesowe** i nie wolno jej upraszczać bez testów zabezpieczających.
   > Ostrzeżenie dotyczy **istnienia** reguł. Ich treść ujawnia moduł 4 i wtedy można ją
   > dopisać. Na tym etapie nie jest znana, a plik ma mówić prawdę.
4. **Czego w repo nie ma** - nie ma testów, nie ma migracji schematu, baza jest generowana
   przez `seed.py`.

Plik może napisać agent - ale **każde zdanie wymaga weryfikacji**.
Sugerowany prompt:

```
Napisz CLAUDE.md dla tego repozytorium, maksymalnie 60 linii. Zasady:
- nie wpisuj niczego, co da się odczytać wprost z kodu (struktura katalogów,
  lista zależności, opis co robi każda funkcja),
- wpisz konwencje, które nie są oczywiste, i komendy do uruchomienia oraz weryfikacji,
- wpisz ostrzeżenia o miejscach, gdzie łatwo zepsuć coś nieoczywistego,
- każde twierdzenie o kodzie poprzyj plikiem i numerem linii, które sprawdziłeś.
Pokaż mi treść, zanim zapiszesz plik.
```

Po zapisaniu sprawdzić, że plik się załadował:

```
/clear
/context
```

Plik ma być widoczny w sekcji **Memory files**. Jeśli go tam nie ma - jest w złym miejscu.

---

## Krok 4 - pomiar „po"

W sesji z załadowanym `CLAUDE.md` powtórzyć **dosłownie** prompt z kroku 1.

Obie odpowiedzi do porównania. Kontrola dotyczy tego, czy model teraz sam z siebie:
- **ostrzega**, że `oblicz_fakture()` zawiera nieudokumentowane reguły biznesowe,
- odmawia zmiany bez testów zabezpieczających, zamiast zaplanować ją od razu,
- wie, że testów w tym repozytorium **nie ma**, i mówi to wprost,
- podaje `make test` jako sposób weryfikacji.

**Jeśli nie - plik nie jest wystarczająco konkretny.** Wymaga poprawki i ponownego pomiaru.
To jest cały lab: pisanie pod pomiar, nie pod poczucie kompletności.

---

## Krok 5 - `docs/architektura.md`

Teraz opis architektury - dla ludzi **i** dla modelu, bez powielania `CLAUDE.md`.

Ma zawierać:
- **granice modułów** - kto od kogo zależy (diagram Mermaid),
- **przepływ przeliczenia faktury** - od żądania HTTP do wyniku,
- **decyzje, które widać w kodzie, ale nie widać ich uzasadnienia**.

Prompt:

```
Napisz docs/architektura.md. Zawrzyj:
1. Diagram Mermaid zależności między modułami w app/ - zbuduj go na podstawie
   faktycznych importów, nie zgaduj.
2. Przepływ przeliczenia faktury od endpointu do wyniku, z nazwami funkcji
   i numerami linii.
3. Listę miejsc, w których kolejność operacji ma znaczenie dla wyniku finansowego.
Nie opisuj, co robi każda funkcja z osobna.
```

**Diagram wymaga weryfikacji.** `grep -n "^from app" app/*.py` pokaże prawdziwe zależności.
Rozbieżność oznacza pierwszą złapaną halucynację w dokumentacji.

---

## Krok 6 - commit

```bash
git add CLAUDE.md docs/
git commit -m "Pliki kontekstowe: CLAUDE.md i opis architektury"
```

---

## Kryteria zaliczenia

- [ ] `CLAUDE.md` ma poniżej 60 linii i widać go w `/context` → Memory files.
- [ ] Ta sama prośba przed i po dała **mierzalnie inny** wynik.
- [ ] W pliku nie ma niczego, co model przeczytałby z kodu.
- [ ] Ostrzeżenie o `oblicz_fakture()` mówi o **istnieniu** nieudokumentowanych reguł,
      a nie zmyśla, jakie one są.
- [ ] Diagram w `docs/architektura.md` zgadza się z faktycznymi importami.

## Pułapki

**Wpisanie sekretu.** W `app/konfiguracja.py` jest coś, co nie powinno tam być.
Zacytowanie tego w `CLAUDE.md` albo `docs/architektura.md` wymaga usunięcia **natychmiast**.
Plik kontekstowy trafia do repo i do każdej sesji. Wraca do tego moduł 8.

**Plik na 200 linii, bo „wszystko ważne".** Efekt trzeba zmierzyć. Jeśli dłuższy plik
nie zmienił odpowiedzi, nie jest lepszy - jest droższy.

**Wpisanie reguły, która musi zadziałać zawsze.** „Nigdy nie commituj bez testów"
w `CLAUDE.md` to prośba, nie gwarancja. W module 5 ta sama reguła staje się hookiem.

**Zmyślenie reguł biznesowych.** Zapis „rabat nie łączy się z promocją, ponieważ
cena promocyjna już zawiera obniżkę" utrwala zgadywanie z labu 2.1 jako
dokumentację projektu. Do pliku trafia to, co jest wiadome: że reguły są, że nie są opisane,
że wymagają testów przed zmianą.

---

[Rozwiązanie wzorcowe](rozwiazanie-2-2.md) · [Checklista modułu](checklista.md)
