# rozliczenia - zasady projektu

Serwis rozliczeń faktur B2B. Poniżej tylko to, czego nie widać wprost w kodzie.

## Uruchamianie i weryfikacja

```bash
python seed.py        # odtwarza rozliczenia.db od zera, deterministycznie (seed 42)
make dev              # uvicorn na porcie 8000
make test             # pytest
make lint             # ruff check app
```

Bazy `rozliczenia.db` NIE ma w repozytorium - generuje ja `seed.py`, a `make` odtwarza
automatycznie, gdy jej brakuje. Baza jest generowana, nie migrowana.
Nie ma migracji schematu - zmiana struktury tabel oznacza zmianę `seed.py`.

## Konwencje

- Nazwy domenowe **po polsku, bez znaków diakrytycznych** (`oblicz_fakture`, `stawka_vat`,
  `termin_platnosci`). Terminy techniczne po angielsku.
- **Kwoty pieniężne wyłącznie jako `Decimal`.** Nigdy `float`. Zaokrąglanie wyłącznie przez
  `app.vat.zaokraglij()` (`ROUND_HALF_UP`, dwa miejsca).
- Długość linii 100 (`pyproject.toml`).
- Daty jako `datetime.date`, w bazie jako ISO 8601 w kolumnach `TEXT`.

## Ostrzeżenia

**`app/rozliczenia.py` - `oblicz_fakture()`.** Ta funkcja zawiera reguły biznesowe, których
nikt nie opisał i których nie widać z samego kodu. Część tego, co wygląda na błąd albo
na zbędną komplikację, jest celowa i kosztowna w usunięciu.

> Nie zmieniaj zachowania tej funkcji, dopóki nie ma testów utrwalających jej obecne
> wyniki. Jeżeli refaktoryzujesz - najpierw testy charakterystyki, potem zmiana,
> testy muszą przejść bez modyfikacji.

To samo dotyczy `app/rabaty.py`, `app/vat.py`, `app/terminy.py` i `app/korekty.py` -
`oblicz_fakture()` tylko je spina.

**Kolejność operacji ma znaczenie finansowe.** Rabat jest odejmowany przed naliczeniem VAT,
a zaokrąglenia następują w konkretnych miejscach. Przestawienie kolejności zmienia kwoty.

## Czego w repozytorium nie ma

- Testów (katalog `tests/` nie istnieje).
- Migracji schematu bazy.
- Obsługi wielu walut poza przelicznikiem w `app/konfiguracja.py` - kursy są wpisane ręcznie.

## Praca ze zmianami

- Zmiana w `app/` bez testu wymaga wyraźnej zgody - napisz, że go nie ma, zamiast zakładać,
  że nie jest potrzebny.
- Nie dopisuj zależności do `requirements.txt` bez pytania.
- Każde twierdzenie o tym kodzie popieraj ścieżką pliku i numerem linii.

<!-- Utrzymuje zespół rozliczeń. Plik czytany przez agenta w każdej sesji - trzymać poniżej 60 linii. -->
