#!/bin/bash
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
TEAL="\033[36m"
CYAN="\033[96m"
RESET="\033[0m"
echo
echo "  This script will install Free Oberon."
echo
echo "Free Oberon dependencies are:"
echo -e " * ${YELLOW}Allegro5${RESET} - for the module Graph and the graphical IDE"
echo -e " * ${YELLOW}Git${RESET} - to download Ofront+"
echo -e " * ${YELLOW}GCC${RESET} - to compile the generated C-code"
echo
echo "You can find the information on how to install the dependencies"
echo "in the README.md file."
echo
echo -e "${TEAL}Debian / Ubuntu / Linux Mint${RESET} etc.:"
echo "  sudo apt-get update"
echo "  sudo apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev"
echo "or, if sudo is not installed (on Debian):"
echo "  su"
echo "  apt-get update"
echo "  apt-get install -y git gcc libc-dev liballegro5-dev liballegro-image5-dev liballegro-audio5-dev liballegro-acodec5-dev"
echo
echo -e "${TEAL}Fedora${RESET}:"
echo "  sudo dnf install -y git gcc glibc-devel allegro5-devel allegro5-addon-image allegro5-addon-audio allegro5-addon-acodec allegro5-devel allegro5-addon-image-devel allegro5-addon-audio-devel allegro5-addon-acodec-devel"
echo
echo -e "${TEAL}Arch Linux${RESET}:"
echo "  sudo pacman -Sy git gcc pkgconf glibc allegro"
echo
echo -e "${TEAL}openSUSE${RESET}:"
echo "  sudo zypper install -y git gcc glibc-devel liballegro5_2-devel liballegro_audio5_2-devel liballegro_image5_2-devel liballegro_primitives5_2-devel liballegro_dialog5_2-devel liballegro_acodec5_2-devel liballegro_acodec5_2-devel liballegro_font5_2-devel"
echo -e "${YELLOW}"
read -p "  Are the dependencies installed? [y/n] " -n 1 -r
echo -e "${RESET}"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

  echo -e "${YELLOW}"
  echo -e "  Downloading Ofront+...${MAGENTA}"
  echo -e "  ~~~~~~~~~~~~~~~~~~~~~~${RESET}"
  if [ ! -f "Data/bin/OfrontPlus/Readme.txt" ]; then
    if [ -d ".git" ]; then
      git submodule update --init
    else
      echo -e "${RED}"
      echo "  Could not download Ofront+, as this is not a Git repository."
      echo "  Please Download Ofront+ from Git and place it in Data/bin/OfrontPlus"
      echo -e "${RESET}"
    fi
    [ -d ".git" ] && git submodule update --init
  else
    echo -e "${GREEN}  Ofront+ already present."
    echo -e "  If there are errors in installation process, delete Data/bin/OfrontPlus${RESET}"
  fi

  echo -e "${YELLOW}"
  echo -e "  Building Ofront+...${MAGENTA}"
  echo -e "  ~~~~~~~~~~~~~~~~~~~${RESET}"
  cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
  ./build
  cd ../../../../../..

  echo -e "${YELLOW}"
  echo -e "  Building Free Oberon...${MAGENTA}"
  echo -e "  ~~~~~~~~~~~~~~~~~~~~~~~${RESET}"
  cd src
  ./make.sh
  cd ..

  echo -e "${YELLOW}"
  echo -e "  Done building Free Oberon${MAGENTA}"
  echo -e "  ${MAGENTA}~~~~~~~~~~~~~~~~~~~~~~~~~${RESET}"
  if [ -f "./FreeOberon" ]; then
    echo -e "${GREEN}"
    echo -e "  Free Oberon is installed. You can now run: ${CYAN}./FreeOberon${GREEN}"
    echo -e "  Add the following line to ${CYAN}~/.bashrc${GREEN} to use the command ${CYAN}fob${GREEN}:"
    echo -e "${CYAN}  export PATH=$PWD:\$PATH${GREEN}"
    echo -e "  To run Free Oberon IDE in a specific language, type ${CYAN}./FreeOberon --lang ru${GREEN}"
  else
    echo -e "${RED}"
    echo "  An error occurred while setting up Free Oberon."
    echo "  Please check your dependencies."
  fi
  echo -e "${RESET}"

fi
