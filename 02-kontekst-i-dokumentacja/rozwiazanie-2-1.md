# Rozwiązanie wzorcowe - lab 2.1

---

## Krok 1 - pomiar zerowy

W świeżej sesji okno zajmuje prompt systemowy, definicje narzędzi i ewentualne narzędzia MCP.
Sekcja **Memory files** w stanie startowym repo jest pusta albo zawiera wyłącznie twój
`~/.claude/CLAUDE.md` - bo `repo-cwiczeniowe/CLAUDE.md` jeszcze nie istnieje.
Dodasz go w następnym labie i wtedy zobaczysz go w tej sekcji.

Jeśli masz podłączone serwery MCP, ich koszt też tu widać. Warto zerknąć, ile zjadają,
zanim w ogóle zacząłeś pracę.

---

## Krok 2 - droga na skróty

Model czyta wszystkie 17 plików `app/` - **1204 linie, około 9 000 tokenów**.
Odpowiedź: `stawka_progowa()` w `app/rabaty.py:37`, korzystająca ze stałej `PROGI`
z `app/rabaty.py:9-13`.

Odpowiedź jest poprawna. Cena - 9 000 tokenów, które zostaną w kontekście do końca sesji
i polecą z **każdym** kolejnym zapytaniem.

---

## Krok 3 - droga celowana

Model wykonuje jedno wyszukiwanie (`grep -rn "prog" app/` albo podobne), trafia do
`app/rabaty.py`, czyta tylko ten plik - **55 linii, ~400 tokenów** - i odpowiada tak samo.

**Różnica: około dwudziestokrotna, przy identycznej odpowiedzi.**

To jest najważniejsza liczba w tym labie. Nie zależy od modelu, od planu ani od wielkości okna.
Zależy wyłącznie od tego, jak sformułowałeś prompt.

**Dlaczego działa.** „Przeczytaj wszystkie pliki w katalogu" to instrukcja proceduralna - model
robi dokładnie to. „Znajdź, gdzie liczony jest X" to instrukcja celowa - model sam wybiera
najtańszą drogę do celu, a `Grep` jest tańszy niż `Read`.

**Uogólnienie:** mów agentowi, **co ma ustalić**, nie **jak ma czytać**. Narzuconą procedurę
wykona dosłownie, nawet jeśli jest kosztowna.

---

## Krok 4 - koszt braku dokumentacji

Pytanie brzmiało: *dlaczego pozycja z ceną promocyjną nie dostaje rabatu progowego -
reguła czy błąd?*

**W repozytorium nie ma na to odpowiedzi.** Cały dowód to cztery linie w `app/rabaty.py:52-55`:

```python
def rabat_pozycji(pozycja: PozycjaFaktury, stawka: Decimal) -> Decimal:
    if pozycja.cena_promocyjna is not None:
        return Decimal("0")
    return pozycja.wartosc_netto * stawka
```

Ani komentarza, ani testu, ani wpisu w dokumentacji. Kod mówi *co się dzieje*
i milczy o tym, *dlaczego*.

**Co zwykle robi model.** Czyta `rabaty.py`, potem `rozliczenia.py`, potem szuka testów
(nie ma), potem czyta `modele.py` - kilka tysięcy tokenów - i formułuje odpowiedź
brzmiącą stanowczo. Najczęściej: „to celowa reguła, rabat nie łączy się z promocją".

**To jest trafna hipoteza podana jako fakt.** Model nie miał podstaw, żeby to rozstrzygnąć.
Co więcej - jest tylko w połowie trafna, o czym przekonasz się w module 4.
(Podpowiedź: ten sam `if` obsługuje też przypadek promocji, która **wygasła**.)

**Wniosek, który ten lab ma zostawić:** brak dokumentacji nie powoduje, że model milczy.
Powoduje, że model **zgaduje pewnym tonem** - i płacisz za to zgadywanie kontekstem.
Trzy linijki w `CLAUDE.md` zastąpiłyby tysiące tokenów czytania **i** usunęłyby zgadywanie.

---

## Wzorcowa notatka

```markdown
# Audyt kontekstu - lab 2.1

## Pomiary

| Moment | Przyrost kontekstu | Uwagi |
|---|---|---|
| Świeża sesja | - | Memory files: pusto (brak CLAUDE.md w repo) |
| Po "przeczytaj cały app/" | **~9 000 tokenów** | 17 plików, wszystkie w kontekście do końca sesji |
| Po /clear | powrót do zera | |
| Po celowanym grepie | **~400 tokenów** | **ta sama odpowiedź, ~20x taniej** |
| Po pytaniu "dlaczego" | ~3 000 tokenów | model przeczytał 4 pliki i tak zgadł |

> Procenty okna zależą od modelu i od twojej konfiguracji (serwery MCP, pliki kontekstowe),
> więc nie podajemy ich jako wzorca - wpisz swoje. **Stały jest stosunek**: ~9 000 kontra ~400
> tokenów za identyczną odpowiedź.

## Odpowiedź na pytanie o rabat i promocję (dosłownie)

> To celowa reguła biznesowa: rabat progowy nie łączy się z ceną promocyjną,
> ponieważ cena promocyjna już zawiera obniżkę. (…)

Brzmi stanowczo. W repo nie ma na to ani jednego dowodu.

## Co z tego wynika dla mojej pracy

Nie każę agentowi czytać katalogów. Każę mu ustalić fakt i zostawiam wybór drogi jemu.
Jeśli pytanie zaczyna się od "dlaczego", a w repo nie ma dokumentacji - odpowiedź
traktuję jak hipotezę do sprawdzenia, nie jak wiedzę.
```

---

## Najczęstsze potknięcia

**Brak `/clear` przed krokiem 3.** Wtedy model ma już całe `app/` w kontekście i „celowane"
pytanie wygląda na darmowe. Porównanie traci sens.

**Wniosek „grep jest zawsze lepszy".** Nie jest. Gdy zadanie polega na zrozumieniu przepływu
przez pięć modułów, model musi je przeczytać. Chodzi o to, żeby czytał **dlatego, że zadanie
tego wymaga**, a nie dlatego, że tak mu kazałeś.

**Pominięcie kroku 4.** To jest jedyny krok, który uzasadnia istnienie następnego labu.
Bez zobaczenia, jak model zgaduje, pisanie `CLAUDE.md` wygląda na biurokrację.
