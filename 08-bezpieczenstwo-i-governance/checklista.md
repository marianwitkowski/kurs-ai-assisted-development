# Checklista samooceny - moduł 8

- [ ] Wiem, że katalog podatności się nie zmienił - zmieniło się tempo i to,
      jak płytko autor zna kod. → *8.1*
- [ ] Umiem wskazać, co model robi dobrze, a co źle w kwestii bezpieczeństwa,
      i dlaczego trzeba pytać **wprost**. → *8.1*
- [ ] Umiem odróżnić uwierzytelnienie od autoryzacji i rozpoznać kod,
      w którym jest jedno, a brakuje drugiego. → *8.2*
- [ ] Wiem, dlaczego cudzy zasób ma dawać **404**, a nie 403. → *8.2*
- [ ] Rozumiem, dlaczego prompt injection to ta sama klasa błędu co SQL Injection -
      i dlaczego **nie ma odpowiednika placeholderów**. → *8.3*
- [ ] Wiem, że zdanie w prompcie systemowym to instrukcja, nie zabezpieczenie. → *8.3*
- [ ] Umiem zbudować obronę w kodzie: limit, wykrycie wzorców, zamknięty schemat,
      ścieżka do człowieka. → *8.3, lab 8.2*
- [ ] Wiem, dlaczego podejrzanego tekstu **nie sanityzujemy**. → *8.3, lab 8.2*
- [ ] Umiem wskazać, co w mojej obronie jest heurystyką, a co gwarancją. → *lab 8.2 krok 4*
- [ ] Znam pięć wektorów wstrzyknięcia, o których się zapomina - łącznie z serwerem MCP
      i treścią zgłoszenia czytaną przez agenta. → *8.3*
- [ ] Znam trzy miejsca, w których sekret przecieka przy pracy z agentem. → *8.4*
- [ ] Wiem, że usunięcie sekretu z pliku **nie usuwa go z repozytorium**,
      i wiem, jaka jest pierwsza czynność po wykryciu. → *8.4, lab 8.1 krok 6*
- [ ] Wiem, że odpowiedzialność za zmianę należy do człowieka, który ją zgłosił. → *8.5*
- [ ] Znam sześć obszarów, na które w review patrzę uważniej niż kiedyś. → *8.5*
- [ ] Wiem, czego review **nie wykryje** - i dlaczego specyfikacja przechodzi review osobno. → *8.5*
- [ ] Wiem, że pisanie kodu obsługującego dane osobowe jest w porządku,
      a wklejanie tych danych do promptu nie jest. → *8.6*
- [ ] Umiem zadać właściwe pytania o RODO i AI Act - i wiem, że nie rozstrzygam ich sam. → *8.7*
- [ ] Wiem, które ryzyko licencyjne jest jedynym egzekwowalnym mechanicznie. → *8.6*
- [ ] Przy każdej zasadzie w mojej polityce wiem, czym ją egzekwuję -
      i uczciwie oznaczam te, których nie egzekwuję niczym. → *8.8*
- [ ] Wiem, czego **nie** wpisywać do komunikatów commitów i opisów pull requestów. → *8.8*

## Jeśli zostało ci pięć minut

Otwórz repozytorium, nad którym pracujesz, i sprawdź jedno:
czy jest w nim endpoint, który sprawdza token, a nie sprawdza, czyj jest zasób.

To zajmuje pięć minut i jest najczęstszą luką w systemach, które „mają uwierzytelnianie".

---

[Teoria](teoria.md) · [Ściąga](sciaga.md)
