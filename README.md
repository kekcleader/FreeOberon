# Free Oberon programming environment

Oberon is a general-purpose programming language–the simplest of them all, yet fully powerful. It is Pascal, developed and perfected.

Free Oberon is a cross-platform integrated development environment for programming in Oberon, made in the classical pseudo-graphic style (the famous blue Pascal screen).

![Free Oberon screenshot](http://free.oberon.org/images/screenshot.png)

![Game of Life animation in Oberon](http://free.oberon.org/images/life.gif)

*See English text below.*

# Среда программирования Free Oberon

Оберон — самый простой, и при этом всецело мощный, язык программирования общего назначения. Это развитый и доведённый до совершенства Паскаль.

Free Oberon представляет собой кроссплатформенную интегрированную среду разработки на языке программирования Оберон, выполненную в классическом псевдографическом стиле — знаменитого синего экрана Паскаля).

* Версия 1.1.0-alpha.4
* Рига, 7 февраля 2022 г.
* Сайт: [free.oberon.org](https://free.oberon.org)

# Установка

## Установка под Линукс

1. На сайте https://github.com/kekcleader/FreeOberon.git
   нажмите зелёную кнопку «Code» и «Download ZIP»,
   распакуйте архив в домашнем каталоге.
   Вы можете переименовать каталог `FreeOberon-main` в `FreeOberon`.

2. Находясь в распакованном каталоге, запустите `install.sh` с правами администратора.
```
su
./install.sh
```

Альтернативный вариант — [собрать Free Oberon вручную](README_build_rus.md).

3. (по желанию) Допишите в конец файла `~/.bashrc` строчку:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  Это позволит запускать Free Oberon командой `fo`.


## Установка под Windows

Скачайте установщик в формате EXE с сайта [free.oberon.org](https://free.oberon.org), запустите его и следуйте инструкциям.

Кроме того, можно скачать версию Free Oberon для Windows в ZIP-архиве (с [free.oberon.org](https://free.oberon.org)) и распаковать его в любое место на диске, при желании создав ярлык на рабочем столе.

Примечание. Если вы хотите самостоятельно собрать версию Free Oberon под ОС Windows из исходных кодов, обратитесь к приложению A [документации Free Oberon на free.oberon.org](http://free.oberon.org/files/FreeOberon_v1.0.3_ru.pdf).


# Использование

Запустите Free Oberon и наберите текст программного модуля на языке Оберон (или откройте файл с примером программы, например `ReadText.Mod`). Нажмите `F9`, чтобы скомпилировать и запустить программу.
Файлы с исходным кодом ваших программ сохраняются в подкаталоге `Programs`, а скомпилированные исполняемые файлы сохраняются в подкаталоге `bin`. Сценарий `Data/bin/compile.sh` (`Data\bin\compile.bat`) используется на Линуксе (Виндоусе) для компиляции программ на Обероне. Вы можете править эти сценарии.

Можно писать программы, состоящие из нескольких модулей. Откройте главный модуль и нажмите `F9`. Free Oberon автоматически компилирует их в правильном порядке.

Если вы компилируете программу, файл главного модуля которой не находится непосредственно в подкаталоге `Programs`, то скомпилированный исполнимый файл будет находится рядом с ним, а не в подкаталоге `bin`.

Если в одном из модулей программы будет найдена ошибка, соответствующий файл откроется, место и характер ошибки будут указаны. Чтобы перекомпилировать, снова перейдите к окну главного модуля и нажмите `F9`.
Если в программе используется модуль Graph, к ней будет автоматически прикомпонована библиотека Allegro5 — будет использован сценарий `Data/bin/link_graph.sh` (`.bat`) вместо `Data/bin/link_console.sh`.

______


*ENGLISH*

* Version 1.1.0-alpha.4
* Riga, February 7, 2022
* Website: [free.oberon.org](https://free.oberon.org/en)

# Install

## Install on Linux

1. On the https://github.com/kekcleader/FreeOberon.git website
   click the green button labeled «Code» and then click «Download ZIP»,
   unpack the archive inside your home directory.
   You can rename directory `FreeOberon-main` to `FreeOberon`.

2. Inside the unpacked directory, run `install.sh` with root privileges.
```
su
./install.sh
```

Alternatively, you can [build Free Oberon manually](README_build_eng.md).

3. (optional) Append the following line to the end of file `~/.bashrc`:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  This will allow you to launch Free Oberon using the `fo` command.


## Install on Windows

Download the setup porgram in EXE format from [free.oberon.org](https://free.oberon.org/en), run it and follow the instructions.

Alternatively, you can download a version of Free Oberon in a ZIP-archive (from [free.oberon.org](https://free.oberon.org/en)), extract it to any place on the disk and (optionally) create a desktop shortcut.

Note. If you want to recompile Free Oberon under Windows from the source code, refer to Appendix A of the [Free Oberon documentation on free.oberon.org](https://free.oberon.org/files/FreeOberon_v1.0.3_en.pdf).


# Usage

Run Free Oberon and type the text of an Oberon module (or open a sample program such as `ReadText.Mod`) and press `F9` to compile and run the program.
The source code files of your programs are saved in the `Programs` subdirectory, and the compiled executables are saved in the `bin` subdirectory. The script `Data/bin/compile.sh` (`Data\bin\compile.bat`) is used on Linux (Windows) to compile an Oberon program. You can edit these scripts.

You can write programs consisting of several modules. Open the main module and press `F9`. Free Oberon automatically compiles them in the correct order.

If you compile a program whose main module file is not directly in the `Programs` subdirectory, the compiled executable will be located next to it and not in the `bin` subdirectory.

If an error occurres during the compilation of one of the modules, the corresponding file will be open and error position and message will be indicated. To recompile, go to the main module window again and press `F9`.
Если в программе используется модуль Graph, к ней будет автоматически прикомпонована библиотека Allegro5 (будет использован сценарий `Data/bin/link_graph.sh` (`.bat`) вместо `Data/bin/link_console.sh` (`.bat`).
If module Graph is used in the program, Allegro5 will be automatically linked to it – `Data/bin/link_graph.sh` (`.bat`) will be used instead of `Data/bin/link_console.sh`.

