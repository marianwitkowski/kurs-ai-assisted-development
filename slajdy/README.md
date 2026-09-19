# Slajdy

Osiem decków Marp, po jednym na moduł. Źródłem jest `teoria.md` każdego modułu -
slajdy są **punktami zaczepienia**, nie podręcznikiem na ekranie. Proza zostaje
w podręczniku, który uczestnik ma w repozytorium.

## Budowanie

Potrzebny tylko Node (`npx` ściąga `marp-cli` przy pierwszym uruchomieniu).
Dist-tag `@latest` w `Makefile` wymusza odpytanie rejestru npm przy **każdym**
wywołaniu, także gdy pakiet leży już w cache `npx`, więc bez sieci `make html`
się nie uda. Decki trzeba zbudować przed wyjazdem - gotowe `.html` działają
offline. Alternatywa: przypiąć wersję (`@marp-team/marp-cli@4.x`) i zainstalować
lokalnie. `sprawdz-srodowisko.sh` tego nie weryfikuje - sprawdza wyłącznie
środowisko uczestnika, nie narzędzia prelegenta.

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
do wydruku i do przekazania komuś, kto ma poprowadzić moduł na zastępstwo.

Wyniki budowania są w `.gitignore` - do repozytorium trafiają tylko źródła.

## Co jest w notatkach prelegenta

Każdy slajd ma komentarz HTML, który Marp pokazuje w trybie prezentera:

```
CO POWIEDZIEĆ: teza slajdu własnymi słowami.
NA CO UWAŻAĆ: typowy błąd sali.
PYTANIE Z SALI: pytanie, które pada, i odpowiedź.
```

`CO POWIEDZIEĆ` jest na każdym slajdzie, reszta tam, gdzie było co napisać.

**Nigdzie nie ma minut.** Kurs nie zakłada tempa - ani doby szkoleniowej, ani budżetu
na slajd. Ten sam deck bywa przejściem przez moduł na sali i materiałem, który ktoś
czyta sam w trzech podejściach.

Przy wymuszonym skracaniu obowiązuje kolejność cięć:

- **slajdy z klasą `lab` zostają** - zapowiadają ćwiczenie i bez nich
  uczestnik nie wie, po co je robi,
- slajd z tezą modułu zostaje - w siedmiu deckach to ostatni slajd klasy `haslo`
  (moduł 5 ma dwa takie slajdy, tezą jest ten końcowy), w module 8 teza siedzi
  na przedostatnim slajdzie („Zasada bez mechanizmu jest życzeniem"), bo deck
  zamyka slajd labowy. To jedno zdanie zostaje w głowie po tygodniu,
- do cięcia nadają się slajdy z pojedynczą tabelą, która powtarza to,
  co uczestnik ma w podręczniku.

## Motyw

`motyw.css` - jasne tło, wysoki kontrast, minimalny rozmiar tekstu 22px
(tabele 20px), bo sala bywa oświetlona, a ostatni rząd ma czytać.

Diagramy są pisane w HTML-u z klasami z tego pliku (`.przeplyw`, `.rozgalezienie`,
`.drabina`, `.kolumny`), **nie w Mermaidzie**. Marp nie renderuje Mermaida, a
`mermaid-cli` ciągnie za sobą headless Chromium - czyli dokładnie tę zależność,
której `make html` unika.

Zestaw klas i przykłady użycia: `motyw.css` oraz dowolny gotowy deck.

## Zmiana treści

Slajd nie może twierdzić niczego, czego nie ma w materiałach modułu. Poprawka
w `teoria.md` wymaga sprawdzenia, czy deck tego samego modułu nie powtarza starej
liczby albo starej nazwy flagi.
