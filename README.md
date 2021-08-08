# Free Oberon programming environment

Oberon is a general-purpose programming language–the simplest of them all, yet fully powerful. It is the improved (and perfect) Pascal.

Free Oberon is a cross-platform integrated development environment for programming in Oberon, made in the classical pseudo-graphic style (the famous blue Pascal screen).

![Free Oberon screenshot](http://free.oberon.org/images/screenshot.png)

*See English text below.*

# Среда программирования Free Oberon

Оберон — самый простой, и при этом всецело мощный, язык программирования общего назначения. Это развитый и доведённый до совершенства Паскаль.

Free Oberon представляет собой кроссплатформенную интегрированную среду разработки на языке программирования Оберон, выполненную в классическом псевдографическом стиле — знаменитого синего экрана Паскаля).

* Версия 1.0.3
* Рига, 1 июля 2021 г.
* Сайт: [free.oberon.org](https://free.oberon.org)

# Установка

## Установка под Линукс

1. Скачайте исходные коды Free Oberon в виде архива tar.gz с сайта [free.oberon.org](https://free.oberon.org) или с репозитория на GitHub. Архив с версией для ОС Windows тоже подойдёт, потому что он содержит исходные коды. Распакуйте архив в свой домашний каталог или в другое место на диске. (Ниже предполагается, что архив распакован в домашний каталог.)
2. Используя терминал или каким-либо иным образом, установите следующие пакеты программного обеспечения:
  * libsdl2-dev
  * libsdl2-image-dev
  * binutils
  * gcc
  * make

  Названия пакетов даны в соответствии с их наименованием в ОС Дебиан. Они подойдут для пользователей Убунту и т. п.
  Для их установки, выполните команду:
  ```
  apt-get install -y libsdl2-dev libsdl2-image-dev binutils gcc make
  ```
  (Эту команду необходимо выполнить с правами суперпользователя, т. е. предварительно необходимо запустить `su` и ввести пароль.)
  На ОС Fedora, Red Hat, CentOS и других, команда и названия пакетов будут отличаться (возможно, также необходимо установить один из двух пакетов: glibc-static или glibc-devel-static):
  ```
  sudo yum install SDL2-devel SDL2_image-devel binutils gcc make       (не проверено!)
  ```
3. Войдите в подкаталог `src` и запустите компиляцию:
  ```
  cd ~/FreeOberon/src
  make -f Makefile_linux
  ```
4. (по желанию) Допишите в конец файла `~/.bashrc` строчку:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  чтобы Free Oberon можно было запускать командой `fo`.

## Установка под Windows

Скачайте установщик в формате EXE с сайта [free.oberon.org](https://free.oberon.org), запустите его и следуйте инструкциям.

Кроме того, можно скачать версию Free Oberon для Windows в ZIP-архиве (с [free.oberon.org](http://free.oberon.org)) и распаковать его в любое место на диске, после чего (по желанию) создать ярлык на рабочем столе.

Примечание. Если вы хотите самостоятельно собрать версию Free Oberon под ОС Windows из исходных кодов, обратитесь к приложению A [документации Free Oberon на free.oberon.org](http://free.oberon.org/files/FreeOberon_v1.0.3_ru.pdf).


# Использование

Запустите Free Oberon и наберите текст программного модуля на языке Оберон (или же откройте файл с примером программы, например `Book.Mod`) и нажмите `F9`, чтобы скомпилировать и запустить программу.
Файлы с исходными кодами модулей сохраняются в подкаталоге `Programs`, а скомпилированные исполняемые файлы сохраняются в `bin`. `data/bin/compile.sh` и `data\bin\compile.bat` используются соответственно на Линуксе и Windows'е для компиляции и могут при необходимости быть отредактированы.

Начиная с версии 1.0.3 есть возможность компилировать и запускать программы, состоящие из нескольких модулей. Поместите все модули в каталог `Programs`, откройте главный модуль и нажмите `F9`.
Если в одном из модулей программы будет найдена ошибка, соответствующий файл откроется и будет указано на место ошибки. Чтобы перекомпилировать, снова перейдите к окну главного модуля и нажмите `F9`.
Если в программе используется модуль Graph, к программе будет автоматически прикомпонована библиотека SDL2 (будет использован сценарий `data/bin/link_graph.sh (или .bat)`.

___________________________________


*ENGLISH*

* Version 1.0.3
* Riga, July 1, 2021
* Website: [free.oberon.org](https://free.oberon.org/en)


# Installation

## Installation under OS GNU/Linux.

1. Download Free Oberon source code from [free.oberon.org](https://free.oberon.org) in tar.gz format or from the GitHub repo. Note that the archive with the version for Windows is also suitable, because it contains the source code. Extract the archive to your home directory or to another location on the disk. (This tutorial will assume the files are extracted to the home directory.)
2. Using terminal or in any other way, install the following packages:
  * libsdl2-dev
  * libsdl2-image-dev
  * binutils
  * gcc
  * make

  The names of the packages are given in accordance with their names in the Debian GNU/Linux operating system. They are also suitable for Ubuntu, Linux Mint, Raspbian and other.
  To install them, run the following command:
  ```
  apt-get install -y libsdl2-dev libsdl2-image-dev binutils gcc make
  ```
  (This command must be executed with superuser privileges, that is, you must first run `su` and enter the password.)
  On OS Fedora, Red Hat, CentOS and others, the command and package names will differ (one the packages glibc-static or glibc-devel-static might also be required):
  ```
  sudo yum install SDL2-devel SDL2_image-devel binutils gcc make       (not tested!)
  ```
3. Go to the `src` subdirectory and start the compilation:
  ```
  cd ~/FreeOberon/src
  make -f Makefile_linux
  ```
4. (optional) Append the following line to the end of file `~/.bashrc`:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  This will allow you to launch Free Oberon using the `fo` command.

## Installation under Windows.

Download the setup porgram in EXE format from [free.oberon.org](https://free.oberon.org), run it and follow the instructions.

Alternatively, you can download a version of Free Oberon in a ZIP-archive (from [free.oberon.org](http://free.oberon.org)), extract it to any place on the disk and (optionally) create a desktop shortcut.

Note. If you want to recompile Free Oberon under Windows from the source code yourself, refer to Appendix A of the [Free Oberon documentation on free.oberon.org](http://free.oberon.org/files/FreeOberon_v1.0.3_en.pdf).

# Usage

Run Free Oberon and type in an Oberon program (or open an example program like `Book.Mod`) and press `F9` to compile and run the program.
The module source code files are saved in subdirectory `Programs` and the compiled executable files are saved in `bin`. `data/bin/compile.sh` and `data\bin\compile.bat` are used to compile a program on GNU/Linux and Windows accordingly and can be edited if required.
Since version 1.0.3, it is also possible to compile and run programs that consist of several modules. Put all modules into `Programs` directory, open the main module and press `F9`. If there is an error in one of the modules of your program, the corresponding file will open up and the error will be highlighted. To recompile, focus the main module window again and press `F9`.
If module Graph is used, SDL2 library will be automatically linked to your program (`data/bin/link_graph.sh (or .bat)` script will be used).
