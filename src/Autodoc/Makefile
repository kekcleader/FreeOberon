
all: Autodoc

Autodoc: Autodoc.Mod AutodocParser.Mod AutodocHtml.Mod
	fob Autodoc.Mod

run: Autodoc
	clear;./Autodoc Test/Apples.Mod

clean:
	@rm -rf _Build Autodoc

.phony: run clean

