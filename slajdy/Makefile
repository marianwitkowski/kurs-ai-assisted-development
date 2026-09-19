.PHONY: html pdf pptx podglad czysc

ZRODLA := $(wildcard [0-9][0-9]-*.md)
HTML   := $(ZRODLA:.md=.html)
MARP   := npx --yes @marp-team/marp-cli@latest --theme motyw.css --allow-local-files

html: $(HTML)

%.html: %.md motyw.css
	$(MARP) $< -o $@ < /dev/null

# PDF i PPTX wymagaja Chrome'a albo Chromium - marp-cli uruchamia go w tle.
# Jesli nie masz, zostan przy HTML-u: otwiera sie w kazdej przegladarce
# i ma tryb prezentera (klawisz P) razem z notatkami.
pdf:
	$(MARP) $(ZRODLA) --pdf --pdf-notes < /dev/null

pptx:
	$(MARP) $(ZRODLA) --pptx < /dev/null

# Podglad na zywo pod http://localhost:8080 - przebudowuje przy kazdym zapisie.
# Serwuje caly katalog; deck wybierasz z listy w przegladarce.
podglad:
	$(MARP) --server . --watch

czysc:
	rm -f *.html *.pdf *.pptx
