# Checklista gotowości - zanim model wejdzie do produktu

Do przejścia przed wpuszczeniem modelu na ścieżkę, na której jego odpowiedź ma
konsekwencje: pieniądze, zobowiązania, dane osobowe, decyzje wobec klienta.

Każdy punkt ma tę samą konstrukcję: **co jest zadeklarowane** kontra **co to faktycznie
robi**. Rozjazd między tymi dwiema kolumnami jest jedynym powodem, dla którego ta
checklista istnieje.

---

## 1. Flaga kontra proces

| | |
|---|---|
| **Flaga** | pole `wymaga_weryfikacji` ustawione na `true`; wynik i tak idzie dalej |
| **Proces** | wynik **nie jest używany**, dopóki człowiek go nie zatwierdzi |

- [ ] Wiadomo, która z tych dwóch rzeczy istnieje w systemie.
- [ ] Jeżeli flaga: **kto** ją ogląda, **jak często** i **co się dzieje**, gdy nie obejrzy.
- [ ] Istnieje miara zaległości - liczba pozycji oznaczonych i nieprzejrzanych.
- [ ] Ktoś zobaczy tę miarę, gdy zacznie rosnąć.

> Flaga bez odbiorcy jest logowaniem, nie kontrolą. Działa dokładnie do pierwszego
> tygodnia, w którym nikt nie ma czasu przejrzeć kolejki.

---

## 2. Bramka lokalna kontra blokada scalenia

| | |
|---|---|
| **Hook lokalny** | działa na maszynie, na której go zainstalowano; da się wyłączyć jednym plikiem |
| **Wymagany check** | blokuje scalenie w ustawieniach repozytorium; nie zależy od dobrej woli |

- [ ] Wiadomo, które kontrole są lokalne, a które blokują scalenie.
- [ ] Sam plik workflow **nie ustanawia** wymaganego warunku - warunek włącza się
      w ustawieniach repozytorium. Zostało to zrobione.
- [ ] Konfiguracja bramki jest chroniona przed zmianą w tym samym pull requeście,
      który zmienia kod.
- [ ] Wiadomo, co się dzieje, gdy bramka jest czerwona po drugiej próbie naprawy.

---

## 3. Gwarancje warstw

Dla każdej warstwy odpowiedź na jedno pytanie: **czego ta warstwa NIE gwarantuje.**

- [ ] **Schemat** gwarantuje kształt odpowiedzi. Nie gwarantuje, że wartość jest właściwa -
      odrzuci `0%`, przyjmie błędne `0`.
- [ ] **Próg pewności** przenosi decyzję do kodu. Nie jest miarą trafności: pewność `0,99`
      przy złej odpowiedzi przechodzi próg. Wartość progu ma uzasadnienie **z pomiaru
      na oznaczonych danych**, a nie z intuicji.
- [ ] **Reguła w kodzie** jest powtarzalna. Dopasowanie fragmentu tekstu to nadal
      heurystyka: `"To nie jest eksport"` zawiera słowo `eksport`.
- [ ] **Filtr wejścia** wykrywa to, co przewidziano. Nie jest ostatnią linią obrony.

---

## 4. Testy kontra ewaluacja

- [ ] Testy offline sprawdzają **kod** wokół modelu: reguły, próg, routing, obsługę odpowiedzi.
- [ ] Istnieje osobna **ewaluacja promptu** na oznaczonym zbiorze, wołająca prawdziwy model.
- [ ] Wiadomo, **kiedy** się ją uruchamia: przy zmianie promptu i przy zmianie modelu.
- [ ] Zapisywane są: wersja promptu, model, konfiguracja, surowe odpowiedzi, trafność
      i udział przypadków skierowanych do weryfikacji.
- [ ] Trafność i liczba pozycji do weryfikacji czytane są **razem**. Wzrost trafności
      okupiony podwojeniem kolejki do człowieka nie jest poprawą.

---

## 5. Koszt

- [ ] Koszt jest **zmierzony** z pola `usage`, a nie oszacowany z długości tekstu.
- [ ] Liczone są wszystkie trzy kategorie tokenów wejściowych osobno - zwykłe wejście,
      zapis do cache i odczyt z cache mają różne ceny.
- [ ] Wiadomo, którego wariantu cache dotyczą użyte mnożniki: pięciominutowy i godzinny
      wyceniają zapis inaczej.
- [ ] Pozycje rozstrzygnięte bez wywołania modelu nie są liczone jako wywołania.

---

## 6. Dane

- [ ] Wiadomo, co trafia do promptu i skąd pochodzi.
- [ ] Treść pochodząca od klienta jest traktowana jako **dane**, nie jako polecenie -
      i jest to egzekwowane w kodzie przed wywołaniem modelu, nie prośbą w prompcie.
- [ ] Dane osobowe nie wchodzą do promptu albo istnieje podstawa prawna i zapis tej decyzji.
- [ ] Wiadomo, kto odpowiada za odpowiedź modelu wobec klienta.

---

## Jak tego użyć

Punkt, którego nie da się odhaczyć, nie jest porażką - jest **pozycją na liście zadań**.
Dokument, w którym wszystko jest odhaczone przy pierwszym czytaniu, zwykle znaczy,
że czytano go zbyt pobłażliwie.
