
all: Autodoc

Autodoc: Autodoc.Mod AutodocParser.Mod
	fob Autodoc.Mod

run: Autodoc
	clear;./Autodoc Test/Apples.Mod

clean:
	@rm -rf _Build Autodoc

.phony: run clean

