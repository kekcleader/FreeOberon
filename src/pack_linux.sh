#!/bin/bash

WORKDIR=../../Linux_pack
FOLDER=$WORKDIR/FreeOberon
BAKPOSTFIX=-OLD-$RANDOM$RANDOM
BAKFOLDER=$FOLDER$BAKPOSTFIX
TARGZFILE=FreeOberon_pack.tar.gz

echo This script will create a directory named $FOLDER
echo and copy the required files to form Free Oberon package for Linux.
echo If the above directory exists, the old contents will be renamed
echo by appending this postfix: $BAKPOSTFIX
echo "Then the created (inner) directory FreeOberon will be tar-gz-ipped"
echo and the archive will be in $TARGZFILE
echo Before this process, git stash will be called. Then: git stash apply.
echo
read -p "Are you sure you want to continue? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
echo

git stash

echo ================================
echo      BEGIN PACK

[ -d "$FOLDER" ] && mv $FOLDER $BAKFOLDER
mkdir -p $FOLDER/_Build

cp ../*.{md,sh} $FOLDER/
cp ../LICENSE $FOLDER/

mkdir $FOLDER/Data
cp -r ../Data/Examples $FOLDER/Data/
cp -r ../Data/Fonts $FOLDER/Data/
cp -r ../Data/Images $FOLDER/Data/
cp -r ../Data/Texts $FOLDER/Data/
cp -r ../Programs $FOLDER/

mkdir $FOLDER/Data/bin
cp ../Data/bin/*.sh $FOLDER/Data/bin

mkdir $FOLDER/Data/bin/OfrontPlus
cp -r ../Data/bin/OfrontPlus/*.txt $FOLDER/Data/bin/OfrontPlus/
mkdir $FOLDER/Data/bin/OfrontPlus/Mod
cp    ../Data/bin/OfrontPlus/Mod/*.{cp,ob2,ob3} $FOLDER/Data/bin/OfrontPlus/Mod/
cp -r ../Data/bin/OfrontPlus/Mod/Lib $FOLDER/Data/bin/OfrontPlus/Mod/

mkdir -p $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Bin
cp    ../Data/bin/OfrontPlus/Target/Linux_amd64/Bin/{build,cc,o2c} $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Bin/
mkdir -p $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Bin
cp    ../Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Bin/{build,cc,o2c} $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Bin/
mkdir $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Obj
mkdir $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Lib/Sym
mkdir $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Obj
mkdir $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/Sym
cp    ../Data/bin/OfrontPlus/Target/Linux_amd64/{ofront+,README.txt} $FOLDER/Data/bin/OfrontPlus/Target/Linux_amd64/

mkdir $FOLDER/src
cp    *.{sh,Mod} $FOLDER/src/
cp -r term $FOLDER/src/

CURDIR=$PWD
cd $FOLDER/..
tar czf $TARGZFILE FreeOberon
cd $CURDIR

echo      END PACK.
echo ================================

git stash apply
