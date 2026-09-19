# Slajdy

Osiem decków Marp, po jednym na moduł. Źródłem jest `teoria.md` każdego modułu -
slajdy są **punktami zaczepienia**, nie podręcznikiem na ekranie. Proza zostaje
w podręczniku, który uczestnik ma w repozytorium.

## Budowanie

Potrzebny tylko Node (`npx` ściąga `marp-cli` przy pierwszym uruchomieniu).

```bash
make html      # osiem plików .html - to wystarcza do prowadzenia
make podglad   # serwer z przeładowaniem przy zapisie
make czysc
```

HTML otwiera się w każdej przeglądarce i ma **tryb prezentera pod klawiszem `P`** -
notatki, podgląd następnego slajdu, zegar. To jest domyślna droga.

```bash
make pdf       # wymaga Chrome'a albo Chromium (marp-cli odpala go w tle)
make pptx
```

`make pdf` dokłada notatki prelegenta do pliku (`--pdf-notes`), więc nadaje się
do wydruku i do wysłania komuś, kto ma poprowadzić moduł zamiast Ciebie.

Wyniki budowania są w `.gitignore` - do repozytorium trafiają tylko źródła.

## Co jest w notatkach prelegenta

Każdy slajd ma komentarz HTML, który Marp pokazuje w trybie prezentera:

```
CO POWIEDZIEĆ: teza slajdu własnymi słowami.
NA CO UWAŻAĆ: typowy błąd sali.
PYTANIE Z SALI: pytanie, które pada, i odpowiedź.
CZAS: ~N min
```

Suma `CZAS` w każdym decku to **33-34 minuty**. Plan dnia daje na teorię modułu
**35 minut pierwszego dnia i 28 minut drugiego** (`README.md`, sekcja „Ile to realnie trwa").

Czyli: dzień 1 domyka się bez zapasu, a **dzień 2 jest o 5-6 minut za krótki na deck
w całości**. To nie jest błąd do naprawienia w slajdach, tylko konsekwencja tego,
że laby zajmują 69% czasu netto. Wejdź na salę wiedząc, co tniesz:

- tnij slajdy z najmniejszym `CZAS` - zwykle te z pojedynczą tabelą,
- **nie tnij slajdów z klasą `lab`** - one zapowiadają ćwiczenie i bez nich
  uczestnik nie wie, po co je robi,
- nie tnij slajdu z tezą modułu - w siedmiu deckach to klasa `haslo`, w module 8
  teza siedzi na slajdzie zamykającym („Zasada bez mechanizmu jest życzeniem").
  To jedno zdanie zostaje w głowie po tygodniu.

## Motyw

`motyw.css` - jasne tło, wysoki kontrast, minimalny rozmiar tekstu 22px
(tabele 20px), bo sala bywa oświetlona, a ostatni rząd ma czytać.

Diagramy są pisane w HTML-u z klasami z tego pliku (`.przeplyw`, `.rozgalezienie`,
`.drabina`, `.kolumny`), **nie w Mermaidzie**. Marp nie renderuje Mermaida, a
`mermaid-cli` ciągnie za sobą headless Chromium - czyli dokładnie tę zależność,
której `make html` unika.

Zestaw klas i przykłady użycia: `motyw.css` oraz dowolny gotowy deck.

## Zmiana treści

Slajd nie może twierdzić niczego, czego nie ma w materiałach modułu. Gdy poprawiasz
`teoria.md`, sprawdź, czy deck tego samego modułu nie powtarza starej liczby albo
starej nazwy flagi.
