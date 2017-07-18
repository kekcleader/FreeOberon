#!/bin/sh
. ../testenv.sh
$OBECOMP LSS.Mod
$OBECOMP LSB.Mod
$OBECOMP LSC.Mod
$OBECOMP LSV.Mod
$OBECOMP lola.Mod -m
./Lola RISC5.Lola result
. ../testresult.sh
