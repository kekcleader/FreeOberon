#!/bin/bash

OUTPATH=/var/www/freeoberon
OUTPATH_ru=$OUTPATH/docs
OUTPATH_en=$OUTPATH/en/docs
MODULES="Args.Mod Dir.Mod Env.Mod Files.Mod Graph.Mod In.Mod Int.Mod Out.Mod \
  OV.Mod Random.Mod Reals.Mod Strings.Mod TermBox.Mod \
  Term.Mod Texts.Mod Time.Mod Utf8.Mod"

cd ..
Autodoc -o $OUTPATH_ru --template $OUTPATH_ru/TEMPLATE.html \
  -t "Фри Оберон" --lang ru -i docs/INTRO.html $MODULES
Autodoc -o $OUTPATH_en --template $OUTPATH_en/TEMPLATE.html \
  -t "Free Oberon" --lang en -i docs/INTRO_en.html $MODULES
cd docs
