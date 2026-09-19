# Checklista samooceny - moduł 5

Odpowiedzi tylko dla siebie, uczciwie. Każde „nie" wskazuje **lekcję**, do której warto wrócić.

- [ ] Wiem, że wąskim gardłem jest weryfikacja, i umiem dobrać wielkość kroku
      do tego, ile jestem w stanie przeczytać. → *5.1*
- [ ] Czytam `git diff`, a nie podsumowanie agenta. → *5.1*
- [ ] Wiem, czym różni się `/rewind` od `git checkout`. → *5.1*
- [ ] Znam cztery zdarzenia, które wystarczą w codziennej pracy, i wiem, co robi każde. → *5.2*
- [ ] Wiem, że kod **2** blokuje, **0** przepuszcza, a każdy inny to błąd nieblokujący. → *5.2*
- [ ] Wiem, że „nie blokuje" i „ignoruje" to **nie to samo**: przy kodzie 2 `PostToolUse`
      pokazuje stderr **modelowi**, `SessionStart` tylko **użytkownikowi**,
      a `PermissionRequest` ignoruje całkowicie. → *5.2*
- [ ] Wiem, przy których czterech zdarzeniach stdout trafia do modelu. → *5.2*
- [ ] Rozumiem różnicę między `${CLAUDE_PROJECT_DIR}` a `cwd` - i wiem, kiedy to zaboli. → *5.2*
- [ ] Wiem, że hook `Stop` ma **gotową** ochronę przed pętlą: pole `stop_hook_active`
      i limit 8 kolejnych blokad - i że własny znacznik jest obejściem problemu,
      który już rozwiązano. → *5.2, lab 5.1 krok 5*
- [ ] Czytam schemat wejścia zdarzenia, zanim napiszę obejście. → *lab 5.1 krok 5*
- [ ] Znam kolejność plików ustawień i wiem, że listy się **łączą**. → *5.2*
- [ ] Umiem zastosować test „co się stanie, jeśli model to zignoruje?" → *5.3*
- [ ] Wiem, dlaczego lista blokowanych komend ma być krótka. → *5.3, lab 5.1 krok 4*
- [ ] Wiem, że nazwa skilla bierze się z **katalogu**, nie z pola `name`. → *5.4*
- [ ] Umiem wstrzyknąć wynik komendy do treści skilla i wiem, kiedy się wykonuje. → *5.4*
- [ ] Umiem rozstrzygnąć, czy coś ma być `CLAUDE.md`, regułą, skillem czy hookiem. → *5.4*
- [ ] Moje hooki i skille są **w repozytorium**, nie w katalogu domowym. → *rozwiązania*

## Ćwiczenie dodatkowe

Do wypisania trzy reguły powtarzane w zespole na każdym review.
Przy każdej rozstrzygnięcie: `CLAUDE.md`, skill czy hook. Reguła, która wypadła
na „hook", a nie jest zautomatyzowana, jest zadaniem do zrobienia.

---

[Teoria](teoria.md) · [Ściąga](sciaga.md)
