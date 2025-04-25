#!/bin/bash
echo
echo "  This script will install Free Oberon."
echo
echo "Free Oberon dependencies are:"
echo -e " * \e[33mAllegro5\e[0m - for the module Graph and the graphical IDE"
echo -e " * \e[33mGit\e[0m - to download Ofront+"
echo -e " * \e[33mGCC\e[0m - to compile the generated C-code"
echo
echo "You can find the information on how to install the dependencies"
echo "in the README.md file."
echo
echo -e "\e[36mDebian / Ubuntu / Linux Mint\e[0m etc.:"
echo "  sudo apt-get update"
echo "  sudo apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev"
echo "or, if sudo is not installed (on Debian):"
echo "  su"
echo "  apt-get update"
echo "  apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev"
echo
echo -e "\e[36mFedora\e[0m:"
echo "  sudo dnf install -y git gcc glibc-devel allegro5-devel allegro5-addon-image allegro5-addon-audio allegro5-addon-acodec allegro5-devel allegro5-addon-image-devel allegro5-addon-audio-devel allegro5-addon-acodec-devel"
echo
echo -e "\e[36mArch Linux\e[0m:"
echo "  sudo pacman -Sy git gcc pkgconf glibc allegro"
echo
echo -e "\e[36mopenSUSE\e[0m:"
echo "  sudo zypper install -y git gcc glibc-devel liballegro5_2-devel liballegro_audio5_2-devel liballegro_image5_2-devel liballegro_primitives5_2-devel liballegro_dialog5_2-devel liballegro_acodec5_2-devel liballegro_acodec5_2-devel liballegro_font5_2-devel"
echo -e "\e[33m"
read -p "  Are the dependencies installed? [y/n] " -n 1 -r
echo -e "\e[0m"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

  echo -e "\e[33m"
  echo -e "  Downloading Ofront+...\e[35m"
  echo -e "  ~~~~~~~~~~~~~~~~~~~~~~\e[0m"
  if [ ! -f "Data/bin/OfrontPlus/Readme.txt" ]; then
    if [ -d ".git" ]; then
      git submodule update --init
    else
      echo -e "\e[31m"
      echo "  Could not download Ofront+, as this is not a Git repository."
      echo "  Please Download Ofront+ from Git and place it in Data/bin/OfrontPlus"
      echo -e "\e[0m"
    fi
    [ -d ".git" ] && git submodule update --init
  else
    echo -e "\e[32m  Ofront+ already present."
    echo -e "  If there are errors in installation process, delete Data/bin/OfrontPlus\e[0m"
  fi

  echo -e "\e[33m"
  echo -e "  Building Ofront+...\e[35m"
  echo -e "  ~~~~~~~~~~~~~~~~~~~\e[0m"
  cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
  ./build
  cd ../../../../../..

  echo -e "\e[33m"
  echo -e "  Building Free Oberon...\e[35m"
  echo -e "  ~~~~~~~~~~~~~~~~~~~~~~~\e[0m"
  cd src
  ./make.sh
  cd ..

  echo -e "\e[33m"
  echo -e "  Done building Free Oberon\e[35m"
  echo -e "  \e[35m~~~~~~~~~~~~~~~~~~~~~~~~~\e[0m"
  if [ -f "./FreeOberon" ]; then
    echo -e "\e[32m"
    echo -e "  Free Oberon is installed. You can now run: \e[96m./FreeOberon\e[32m"
    echo -e "  Add the following line to \e[96m~/.bashrc\e[32m to use the command \e[96mfob\e[32m:"
    echo -e "\e[96m  export PATH=$PWD:\$PATH\e[32m"
    echo -e "  To run Free Oberon IDE in a specific language, type \e[96m./FreeOberon --lang ru\e[32m"
  else
    echo -e "\e[31m"
    echo "  An error occurred while setting up Free Oberon."
    echo "  Please check your dependencies."
  fi
  echo -e "\e[0m"

fi
