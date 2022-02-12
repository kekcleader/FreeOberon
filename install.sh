#!/bin/bash

echo "This script will install Free Oberon."

echo "Installing Allegro5, Git and GCC..."
sudo apt-get update
sudo apt-get install -y git gcc libc-dev liballegro5-dev

echo "======================="
echo "Downloading Ofront+ if not exists..."
# Only run git command if dot-git subdirectory exists
[ -d ".git" ] && git submodule update --init

echo "======================="
echo "Building Ofront+..."
cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
./build
cd ../../../../../..

echo "======================="
echo "Building Free Oberon..."
cd src
./make.sh
cd ..

echo "======================="
echo "Done."
echo "If everything went ok, you can now run: ./FreeOberon"
