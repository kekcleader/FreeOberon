#!/bin/bash

echo "This script will install Free Oberon."

echo "Free Oberon dependencies are:"
echo " * Allegro5 - for the module Graph and the graphical IDE"
echo " * Git - to download Ofront+"
echo " * GCC - for Ofront+ to compile the generated C-code"
echo
echo "You can find the information on how to install the dependencies in the"
echo "README.md file."
echo
echo "On OS Debian / Ubuntu / Linux Mint and so on:"
echo "  sudo apt-get update"
echo "  sudo apt-get install -y git gcc libc-dev liballegro5-dev"
echo "or:"
echo "  su"
echo "  apt-get update"
echo "  apt-get install -y git gcc libc-dev liballegro5-dev"
echo
echo "On OS Fedora:"
echo "  sudo dnf install -y git gcc glibc-devel allegro5-devel allegro5-addon-image allegro5-addon-audio allegro5-addon-acodec allegro5-addon-dialog allegro5-devel allegro5-addon-image-devel allegro5-addon-audio-devel allegro5-addon-acodec-devel allegro5-addon-dialog-devel argro5-addon-dialog-devel"
echo
echo "On Arch Linux:"
echo "  sudo pacman -Sy git gcc pkgconf glibc allegro"
echo
echo "On openSUSE:"
echo "  sudo zypper install -y git gcc glibc-devel liballegro5_2-devel liballegro_audio5_2-devel liballegro_image5_2-devel liballegro_primitives5_2-devel liballegro_dialog5_2-devel liballegro_acodec5_2-devel liballegro_acodec5_2-devel liballegro_font5_2-devel"
echo
read -p "Are the dependencies installed? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

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

  if [ -f "./FreeOberon" ]; then
    echo "Free Oberon is installed. You can now run: ./FreeOberon"
    echo "Add the following line to ~/.bashrc to use the command 'fob':"
    echo "export PATH=$PWD:\$PATH"
  else
    echo "An error occurred while setting up Free Oberon."
    echo "Please check your dependencies."
  fi

fi
