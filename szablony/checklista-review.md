# Checklista code review - kod tworzony z udziałem agenta

Do użycia **po** przejściu bramek automatycznych. Jeśli recenzent wyłapuje nieużywane
importy, bramka jest źle ustawiona.

## Zanim zaczniesz czytać

- [ ] Bramka automatyczna przeszła (format, lint, testy, skan sekretów).
- [ ] Opis zmiany mówi **co i dlaczego**, nie jakim narzędziem.
- [ ] Jest specyfikacja albo zgłoszenie, do którego da się porównać zakres.

## Zakres

- [ ] Diff mieści się w zakresie z opisu. Nic „przy okazji".
- [ ] Nie ma niepowiązanych zmian formatowania rozpychających diff.
- [ ] Liczba plików odpowiada opisowi zmiany.

## Testy

- [ ] Nowa logika ma test.
- [ ] **Żaden istniejący test nie został zmieniony**, żeby przejść.
      Jeśli został - czy zmiana zachowania jest zamierzona i opisana?
- [ ] Testy sprawdzają wymaganie, nie powtarzają formuły z kodu.
- [ ] Są przypadki brzegowe, nie tylko ścieżka szczęśliwa.

## Zachowanie

- [ ] Usunięte warunki i gałęzie: czy to uproszczenie, czy usunięcie reguły biznesowej?
- [ ] Zmienione wartości domyślne - czy ktoś tego chciał?
- [ ] Obsługa błędów: brak `except: pass` i połykania wyjątków.
- [ ] Zmiany w obliczeniach finansowych mają test utrwalający liczby.

## Granica zaufania

- [ ] Dane wejściowe z zewnątrz są walidowane przed użyciem.
- [ ] **Autoryzacja per zasób**, nie tylko uwierzytelnienie.
      *Czy wynik funkcji autoryzacyjnej jest gdziekolwiek użyty?*
- [ ] Zapytania do bazy przez placeholdery, także te budowane warunkowo.
- [ ] Odpowiedź nie zawiera więcej, niż wywołujący ma prawo zobaczyć.
- [ ] Dane od użytkownika trafiające do promptu: czy jest obrona w kodzie?

## Zależności i sekrety

- [ ] Brak nowych zależności - albo jest uzasadnienie i sprawdzona licencja.
- [ ] Brak sekretów, także w testach i danych przykładowych.
- [ ] Brak danych osobowych w danych testowych.

## Dokumentacja

- [ ] Nieoczywiste decyzje mają komentarz mówiący **dlaczego**, nie **co**.
- [ ] Zmiana reguły biznesowej jest odnotowana tam, gdzie ktoś jej poszuka.
- [ ] Znane błędy zostawione świadomie są oznaczone i mają odnośnik.

## Pytanie na koniec

> **Czy rozumiem każdą linię, którą zatwierdzam?**

Jeśli nie - to nie jest powód do odrzucenia zmiany. To jest powód do zadania pytania
autorowi. Odpowiedź „tak wygenerował agent" nie zamyka tematu.
