
all: Autodoc

Autodoc: Autodoc.Mod AutodocParser.Mod AutodocHtml.Mod
	fob Autodoc.Mod

run: Autodoc
	clear;./Autodoc -o Test ../Int.Mod Test/A.Mod

#	clear;./Autodoc --template T.html -o Test Test/*.Mod -a -t "Библиотека модулей"

clean:
	@rm -rf _Build Autodoc

.phony: run clean

