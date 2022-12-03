
all: Autodoc

Autodoc: Autodoc.Mod AutodocParser.Mod AutodocHtml.Mod
	fob Autodoc.Mod

run: Autodoc
	clear;./Autodoc -o Test Test/A.Mod -a

clean:
	@rm -rf _Build Autodoc

.phony: run clean

