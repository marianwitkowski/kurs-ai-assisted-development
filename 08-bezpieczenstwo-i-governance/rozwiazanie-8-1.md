# Rozwiązanie wzorcowe - lab 8.1

```bash
git diff lab-8-1-start lab-8-2-start
git show lab-8-2-start:docs/incydent-klucz-ksef.md
```

```
 .env.example                 |   1 +
 Makefile                     |   6 +-
 app/db.py                    |  10 ++-
 app/eksport.py               |  17 ++++-
 app/konfiguracja.py          |   9 ++-
 app/main.py                  |  30 +++++---
 docs/incydent-klucz-ksef.md  |  67 +++++++++++++++++
 skrypty/skan_sekretow.sh     |  32 ++++++++
 tests/test_bezpieczenstwo.py | 146 +++++++++++++++++++++++++++++++++++
 9 files changed, 300 insertions(+), 18 deletions(-)
```

---

## Krok 1 - dlaczego pusty hash, a nie tag

```bash
git diff --stat lab-1-1-start lab-8-1-start -- app/db.py app/konfiguracja.py
# (pusto)
```

Przez siedem modułów nikt nie dotknął `app/db.py` ani `app/konfiguracja.py`.
Wstrzyknięcie SQL i klucz API są w repozytorium **od pierwszego commita** -
i dlatego **nie ma ich w żadnym diffie**.

W `app/main.py` diff istnieje, ale zawiera wyłącznie dopisany endpoint odsetek.
`szczegoly_faktury` nie pojawia się nawet w kontekście hunków.

| Zakres przeglądu | Co zobaczy skill |
|---|---|
| `git diff lab-1-1-start` | zmiany z siedmiu modułów - **żadnej z trzech luk** |
| `git diff 4b825dc…` (puste drzewo) | cały projekt jako dodany - **wszystkie trzy** |

**Lekcja ogólna:** przegląd diffa widzi **zmiany**, nie **stan**. Luka odziedziczona
po poprzednikach jest niewidoczna dla każdego procesu opartego wyłącznie na review
pull requestów - a to jest dominujący sposób pracy w większości zespołów.

Dlatego przegląd diffa i przegląd całego projektu to **dwie różne czynności**
o różnej częstotliwości: diff przy każdej zmianie, całość okresowo.

---

## Luka 1 - SQL Injection

```python
# BYŁO
sql = (
    "SELECT * FROM faktury "
    f"WHERE kontrahent_nip = '{nip}' AND kontrahent_id = {kontrahent_id} "
    "ORDER BY data_wystawienia DESC"
)
return [_faktura(con, w) for w in con.execute(sql)]

# JEST
sql = (
    "SELECT * FROM faktury "
    "WHERE kontrahent_nip = ? AND kontrahent_id = ? "
    "ORDER BY data_wystawienia DESC"
)
return [_faktura(con, w) for w in con.execute(sql, (nip, kontrahent_id))]
```

Przed poprawką ładunek `' OR 1=1 --` zamieniał zapytanie w:

```sql
SELECT * FROM faktury WHERE kontrahent_nip = '' OR 1=1 --' AND kontrahent_id = 3
```

Warunek kontrahenta trafiał do komentarza. **204 faktury 20 kontrahentów zamiast 11 własnych.**

To jest przypadek, w którym filtr bezpieczeństwa i filtr biznesowy są w tym samym zapytaniu -
i wstrzyknięcie usuwa oba naraz.

---

## Luka 2 - autoryzacja per zasób, **cztery** endpointy

Raport z kroku 1 zwykle wskazuje jeden. Są cztery:

| Endpoint | Co zwracał |
|---|---|
| `GET /faktury/{id}` | dowolną fakturę w systemie |
| `GET /faktury/{id}/rozliczenie` | to samo |
| `GET /raporty/przeterminowane` | faktury **wszystkich** kontrahentów |
| `GET /eksport/faktury.csv` | **całą bazę** w CSV |

Ostatni jest najgorszy i najłatwiejszy do przeoczenia, bo `eksport.faktury_csv(con)`
wygląda niewinnie - nie przyjmuje identyfikatora kontrahenta, więc nie widać,
że powinien.

### Poprawka: wydzielona funkcja

```python
def _kontrahent_z_naglowka(authorization: str | None) -> int:
    """Uwierzytelnienie: kto to jest. To NIE jest autoryzacja."""
    ...

def _faktura_kontrahenta(con, faktura_id: int, kontrahent_id: int):
    """Autoryzacja: czy ta faktura należy do tego kontrahenta.

    Cudza faktura daje 404, nie 403 - żeby nie potwierdzać, że taki numer istnieje.
    """
    faktura = db.pobierz_fakture(con, faktura_id)
    if faktura is None or faktura.kontrahent_id != kontrahent_id:
        raise HTTPException(status_code=404, detail="nie ma takiej faktury")
    return faktura
```

Dwie funkcje z docstringami mówiącymi wprost, która robi co. **Ta para nazw jest częścią
rozwiązania** - następna osoba, która doda endpoint, zobaczy obie i zada sobie pytanie,
czy użyła właściwej.

### Dlaczego 404, a nie 403

403 mówi: „ten zasób istnieje, ale nie wolno ci go zobaczyć". Przy sekwencyjnych
identyfikatorach pozwala policzyć cudze faktury i wywnioskować obroty konkurencji.

Test pilnuje, żeby oba przypadki wyglądały identycznie:

```python
def test_cudza_faktura_daje_404_a_nie_403(polaczenie):
    nieistniejaca = KLIENT.get("/faktury/999999", headers=TOKEN_K3)
    cudza_odp = KLIENT.get(f"/faktury/{cudza}", headers=TOKEN_K3)
    assert nieistniejaca.status_code == cudza_odp.status_code == 404
```

---

## Luka 3 - sekret

```python
# BYŁO
# TODO(ROZL-412): przeniesc do zmiennych srodowiskowych przed wdrozeniem produkcyjnym
KLUCZ_API_KSEF = "ksef_live_7f3a9c21e84b4d6fa0c5e19b3d7a2f88"

# JEST
KLUCZ_API_KSEF = os.environ.get("KSEF_API_KEY", "")
```

Plus błąd zamiast cichego wysłania - w `app/eksport.py`, w `naglowki_ksef()`, czyli
w miejscu wysyłki, a nie na poziomie modułu konfiguracji:

```python
if not KLUCZ_API_KSEF:
    raise RuntimeError("brak KSEF_API_KEY w srodowisku")
```

**Brak wartości domyślnej jest celowy.** `os.environ.get("KSEF_API_KEY", "jakas-wartosc")`
to ten sam problem przeniesiony w inne miejsce - a `os.environ.get(..., "")` bez sprawdzenia
daje ciche wysłanie z pustym nagłówkiem, czyli błąd trudniejszy do zdiagnozowania
niż brak klucza.

Zwróć uwagę na komentarz `TODO(ROZL-412)`. Jest z **tego samego commita** co klucz.
Ktoś wiedział, że tak nie powinno być, i zostawił to na później. To jest najczęstsza
droga sekretu do repozytorium.

---

## Krok 5 - dlaczego skan sekretów dopiero teraz

Bramka `make gate` powstała w labie 5.1 jako `ruff check` + `pytest`. Gdyby wtedy
zawierała skan sekretów:

- znalazłby `ksef_live_...` w module 5,
- hook `Stop` nie pozwoliłby zamknąć labu 5.1,
- lab 8.1 straciłby sens, bo problem byłby już znany.

**To nie jest sztuczka dydaktyczna - tak to działa w zespołach.** Bramka rośnie
wraz z tym, czego zespół się nauczył. Włączenie wszystkich kontroli naraz w projekcie,
który ich nie przechodzi, kończy się wyłączeniem bramki.

Kolejność wdrażania, która działa: najpierw to, co projekt przechodzi (format, lint),
potem to, co da się naprawić w jeden dzień (testy), na końcu to, co wymaga incydentu
i decyzji (sekrety, licencje).

### Skaner - dlaczego krótki

```bash
wzorce=(
  'ksef_live_[A-Za-z0-9]{16,}'
  'sk-ant-[A-Za-z0-9_-]{20,}'
  'AKIA[0-9A-Z]{16}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '(password|haslo|secret|token)[[:space:]]*=[[:space:]]*["\047][^"\047]{8,}["\047]'
)
```

Pięć wzorców, `git ls-files` jako zakres, kod wyjścia 1 przy znalezieniu.
To nie zastępuje `gitleaks` - ma być **szybkie i zrozumiałe**, żeby nikt go nie wyłączył.

Skaner wyklucza sam siebie i plik testów, bo oba zawierają wzorce z definicji.
To jest typowy problem przy takich narzędziach i lepiej go rozwiązać jawnie
niż przez przypadkowe dopasowanie.

---

## Krok 6 - sedno całego labu

```bash
git log -p --all -- app/konfiguracja.py | grep -c "ksef_live_"
# wynik > 0 - dokładna liczba zależy od tego, ile commitów zdążyłeś zrobić
```

Klucz jest usunięty z pliku i **nadal jest w repozytorium**. Zostanie tam.

`docs/incydent-klucz-ksef.md` zapisuje trzy rzeczy, o których za pół roku nikt
nie będzie pamiętał:

**Zasięg.** Nie tylko „kod źródłowy", ale też: historia gita, każdy klon, każdy fork,
**kontekst każdej sesji agenta czytającej ten plik**. Ten ostatni wiersz jest nowy
i łatwo o nim zapomnieć - plik konfiguracyjny jest czytany przy większości zadań.

**Czego nie zrobiono i dlaczego.** Nie przepisano historii. `git filter-repo` + force-push
unieważnia wszystkie klony, psuje odwołania do commitów w zgłoszeniach i **nie daje
gwarancji**, że nikt nie ma kopii.

**Wniosek, który ma zostać:**

> Usunięcie sekretu z pliku nie usuwa go z repozytorium. Jedyną czynnością, która
> faktycznie zamyka incydent, jest **unieważnienie sekretu**. Przepisanie historii
> jest kosmetyką wykonywaną po unieważnieniu - nie zamiast niego.

---

## Testy: dlaczego docstring jest obowiązkowy

```python
def test_wyszukiwanie_nie_daje_sie_wstrzyknac(polaczenie):
    """BYŁA LUKA: f-string w zapytaniu. Ładunek ' OR 1=1 -- zwracał wszystkie faktury."""
```

Za rok ktoś zobaczy ten test przy refaktorze `db.py` i zada sobie pytanie, po co on jest.
Docstring odpowiada. Bez niego test wygląda na nadmiarowy i ktoś go usunie „przy porządkach".

Nagłówek pliku mówi to samo o całym zestawie:

> Te testy nie są po to, żeby udowodnić, że kod jest bezpieczny - są po to,
> żeby ta konkretna luka nie wróciła.

---

## Najczęstsze potknięcia

**Naprawa tylko tego, co wskazał raport.** Cztery endpointy, nie jeden.
Narzędzie daje punkt zaczepienia, nie listę.

**403 zamiast 404.**

**Wartość domyślna dla sekretu.**

**Brak testu po naprawie.** Wróci przy pierwszym refaktorze.

**„Usunąłem klucz, problem rozwiązany."** Najczęstszy i najdroższy błąd z tego labu.
