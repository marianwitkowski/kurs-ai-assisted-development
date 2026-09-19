"""Ewaluacja promptu na oznaczonym zbiorze - to, czego testy offline nie robia.

    PYTHONPATH=. python skrypty/ewaluacja_promptu.py tests/golden/vat.jsonl

Testy offline (tests/test_golden_vat.py) sprawdzaja KOD klasyfikatora na zapisanych
odpowiedziach. Podmiana PROMPT_SYSTEMOWY zostawia je zielone, bo prompt nie jest
w nich wykonywany. Ten skrypt robi rzecz przeciwna: wola prawdziwy model i sprawdza,
czy prompt nadal daje te odpowiedzi, ktore powinien.

Uruchamia sie go przy ZMIANIE PROMPTU ALBO MODELU, nie przy kazdym commicie:
kosztuje tokeny i nie jest deterministyczny.

Dwa prompty naraz:

    PYTHONPATH=. python skrypty/ewaluacja_promptu.py tests/golden/vat.jsonl \\
        --prompt-b promptt/wariant_b.txt

Wtedy wypisuje obie trafnosci obok siebie i liste przypadkow, ktore sie roznia.
To jest jedyny sposob, zeby powiedziec "nowy prompt jest lepszy" z pokryciem w danych.
"""

import argparse
import json
import pathlib
import sys
from collections import Counter

from app.klasyfikacja_vat import PROMPT_SYSTEMOWY, KlasyfikatorLLM, klasyfikuj


def wczytaj(sciezka: pathlib.Path) -> list[dict]:
    with sciezka.open(encoding="utf-8") as f:
        return [json.loads(w) for w in f if w.strip()]


def przebieg(przypadki: list[dict], prompt: str, model: str) -> dict:
    """Jeden przebieg calego zbioru przez model. Zwraca wyniki i liczniki."""
    import anthropic

    import app.klasyfikacja_vat as kv

    poprzedni = kv.PROMPT_SYSTEMOWY
    kv.PROMPT_SYSTEMOWY = prompt          # podmiana na czas przebiegu
    try:
        zrodlo = KlasyfikatorLLM(model=model, klient=anthropic.Anthropic())
        wyniki = []
        for p in przypadki:
            w = klasyfikuj(p["opis"], zrodlo)
            wyniki.append(
                {
                    "opis": p["opis"],
                    "oczekiwana": p["oczekiwana"],
                    "otrzymana": w.stawka,
                    "zrodlo": w.zrodlo,
                    "trafiona": w.stawka == p["oczekiwana"],
                    "do_weryfikacji": w.wymaga_weryfikacji,
                }
            )
    finally:
        kv.PROMPT_SYSTEMOWY = poprzedni

    return {
        "wyniki": wyniki,
        "trafnosc": sum(w["trafiona"] for w in wyniki) / len(wyniki),
        "do_weryfikacji": sum(w["do_weryfikacji"] for w in wyniki),
        "zrodla": Counter(w["zrodlo"] for w in wyniki),
    }


def raport(nazwa: str, r: dict) -> None:
    n = len(r["wyniki"])
    print(f"\n{nazwa}")
    print(f"  trafnosc:          {r['trafnosc']:.1%}  ({sum(w['trafiona'] for w in r['wyniki'])}/{n})")
    print(f"  do weryfikacji:    {r['do_weryfikacji']}/{n}  ({r['do_weryfikacji'] / n:.1%})")
    print(f"  zrodlo decyzji:    {dict(r['zrodla'])}")
    bledy = [w for w in r["wyniki"] if not w["trafiona"]]
    if bledy:
        print("  nietrafione:")
        for w in bledy[:10]:
            print(f"    {w['opis'][:46]:46} oczekiwano {w['oczekiwana']:>3}, "
                  f"jest {w['otrzymana']:>3} ({w['zrodlo']})")
        if len(bledy) > 10:
            print(f"    ... i {len(bledy) - 10} wiecej")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("zbior", type=pathlib.Path, help="plik .jsonl z polami opis i oczekiwana")
    ap.add_argument("--model", default="claude-haiku-4-5")
    ap.add_argument("--prompt-b", type=pathlib.Path, help="drugi prompt do porownania")
    a = ap.parse_args()

    przypadki = wczytaj(a.zbior)
    print(f"Zbior: {a.zbior} - {len(przypadki)} przypadkow, model {a.model}")
    print("UWAGA: to wola prawdziwe API i kosztuje.")

    a_ = przebieg(przypadki, PROMPT_SYSTEMOWY, a.model)
    raport("PROMPT A (obecny)", a_)

    if a.prompt_b:
        b_ = przebieg(przypadki, a.prompt_b.read_text(encoding="utf-8"), a.model)
        raport(f"PROMPT B ({a.prompt_b})", b_)

        print("\nRoznice miedzy promptami:")
        rozne = [
            (x, y) for x, y in zip(a_["wyniki"], b_["wyniki"]) if x["otrzymana"] != y["otrzymana"]
        ]
        if not rozne:
            print("  brak - oba prompty daly ten sam wynik na kazdym przypadku")
        for x, y in rozne[:20]:
            print(f"  {x['opis'][:42]:42} A={x['otrzymana']:>3} B={y['otrzymana']:>3} "
                  f"(oczekiwano {x['oczekiwana']})")

        print(f"\n  trafnosc A: {a_['trafnosc']:.1%}   trafnosc B: {b_['trafnosc']:.1%}")
        print(f"  do weryfikacji A: {a_['do_weryfikacji']}   B: {b_['do_weryfikacji']}")
        print("\nWyzsza trafnosc przy WIEKSZEJ liczbie przypadkow do weryfikacji nie jest")
        print("wygrana - to przesuniecie pracy na czlowieka. Oba wskazniki czyta sie razem.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
