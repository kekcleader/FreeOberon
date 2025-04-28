#!/bin/bash

WORKDIR=../../macos_pack
FOLDER=$WORKDIR/FreeOberon.app
BAKPOSTFIX=-OLD-$RANDOM$RANDOM
BAKFOLDER=$FOLDER$BAKPOSTFIX
PKGFILE=FreeOberon.pkg

echo This script will create a directory named $FOLDER
echo and copy the required files to form Free Oberon package for macOS.
echo If the above directory exists, the old contents will be renamed
echo by appending this postfix: $BAKPOSTFIX
echo "Then the created (inner) directory FreeOberon will be packaged"
echo and the archive will be in $PKGFILE
echo Before this process, git stash will be called. Then: git stash apply.
echo
read -p "Are you sure you want to continue? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
echo

#git stash

echo ================================
echo      BEGIN PACK MACOS

[ -d "$FOLDER" ] && mv $FOLDER $BAKFOLDER
mkdir -p $FOLDER/Contents/MacOS
mkdir -p $FOLDER/Contents/Resources

cp ../FreeOberon $FOLDER/Contents/MacOS
#cp ../fob $FOLDER/Contents/MacOS
cp Info.plist $FOLDER/Contents

cp -r ../Data $FOLDER/Contents/MacOS
cp -r ../Programs $FOLDER/Contents/MacOS
#cp ../install.sh $FOLDER/Contents/MacOS
cp ../*.{md,sh} $FOLDER/
cp ../LICENSE $FOLDER/

echo      END PACK.
echo ================================

#git stash apply
