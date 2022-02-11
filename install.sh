#!/bin/bash

echo "This script will install Free Oberon."

echo "Installing Allegro5, Git and GCC..."
sudo apt-get update
sudo apt-get install -y liballegro5-dev git gcc build-essential

echo "Installing Ofront+ as Git submodule..."
git submodule update --init

echo "Building Ofront+..."
cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
./build
cd ../../../../../..

echo "Building Free Oberon..."
cd src
./make.sh
cd ..

echo "Done."
echo "If everything went ok, you can now run: ./FreeOberon"
