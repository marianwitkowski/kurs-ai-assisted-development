# Checklista samooceny - moduł 7

Lista do uczciwego wypełnienia. Każde „nie" wskazuje **lekcję**, do której warto wrócić.

- [ ] Znam kolejność obniżania kosztów i wiem, dlaczego zmiana modelu jest **ostatnia**. → *7.1*
- [ ] Wiem, że cache jest przypisany do modelu - i co to znaczy dla kaskady modeli. → *7.1, 7.2*
- [ ] Umiem przypisać model i effort do **roli**, nie do „trudności zadania". → *7.2*
- [ ] Wiem, że przed budową kaskady modeli mierzy się mocniejszy model na niższym efforcie. → *7.2*
- [ ] Znam kolejność renderowania `tools → system → messages` i układam prompt
      stabilne-najpierw. → *7.3*
- [ ] Umiem wymienić trzy cichych zabójców cache'u. → *7.3*
- [ ] Wiem, że `usage.cache_read_input_tokens` równe zero przy powtórzeniach
      to jedyny sygnał, że cache nie działa. → *7.3, lab 7.1*
- [ ] Znam różnicę TTL: godzina na subskrypcji, pięć minut na kluczu API. → *7.3*
- [ ] Wiem, czym różni się `/compact` od `/clear` i co przeżywa kompakcję. → *7.4*
- [ ] Wiem, że hook `PreToolUse` może odfiltrować wyjście komendy przed wejściem
      do kontekstu. → *7.4*
- [ ] Wiem, do czego nadaje się Batch API - i że wyniki wracają w **dowolnej kolejności**. → *7.5*
- [ ] Umiem odczytać `/usage` na subskrypcji: paski, atrybucja, flagi zachowań -
      i wiem, że kwota z bloku `Session` nie jest moim rachunkiem. → *7.6, lab 7.1*
- [ ] Mierzę koszt **na ukończone zadanie**, nie na zapytanie. → *7.6*
- [ ] Umiem zaprojektować trzy warstwy: reguła w kodzie → model ze schematem →
      **decyzja progowa w kodzie**. → *7.7, lab 7.2*
- [ ] Wiem, dlaczego pole „źródło decyzji" jest ważniejsze niż sam wynik. → *lab 7.2*
- [ ] Wiem, że schemat gwarantuje kształt, nie sens - i co dopisać w kodzie. → *7.7*
- [ ] Umiem zbudować golden set, który działa offline i sprawdza źródło decyzji. → *7.7, lab 7.2*
- [ ] Wiem, przed czym próg pewności **nie** chroni. → *lab 7.2 krok 5*

## Ćwiczenie dodatkowe

Otworzyć `/usage` i sprawdzić atrybucję. Serwer MCP, plugin albo skill, który odpowiada
za więcej niż kilka procent zużycia, a nie jest używany w tym projekcie - do wyłączenia
od razu. To jest najtańsza optymalizacja z całego modułu.

---

[Teoria](teoria.md) · [Ściąga](sciaga.md)
