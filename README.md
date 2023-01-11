# Free Oberon programming environment

Oberon is a general-purpose programming language–the direct descendant of Pascal and Modula-2. It is both simpler and much more powerful than Pascal and Modula.

Free Oberon is a cross-platform integrated development environment for the Oberon programming language, designed in the classic pseudo-graphic style–the famous blue screen of Pascal.

Fob is a convenient console-based Oberon compiler.

![Free Oberon screenshot](http://free.oberon.org/images/screenshot.png)

![Game of Life animation in Oberon](http://free.oberon.org/images/life.gif)

*See English text below.*

# Среда программирования Free Oberon

Оберон — язык программирования общего назначения, прямой наследник Паскаля и Модулы-2. Он одновременно и проще, и намного мощнее, чем Паскаль и Модула.

Free Oberon представляет собой кроссплатформенную интегрированную среду разработки на языке программирования Оберон, выполненную в классическом псевдографическом стиле — знаменитого синего экрана Паскаля.

Fob — это консольный компилятор языка Оберон.

* Версия 1.1.0-alpha.7
* Рига, 11 января 2023 г.
* Сайт: [free.oberon.org](https://free.oberon.org)

# Установка

## Установка на Линукс

1. Скачайте Free Oberon в виде архива tar.gz с сайта
   [free.oberon.org](https://free.oberon.org/download)
   и распакуйте его в домашнем каталоге (или в любом другом месте).

   Вариант (новейшая сборка):

   На сайте https://github.com/kekcleader/FreeOberon.git
   нажмите зелёную кнопку «Code» и «Download ZIP»,
   распакуйте архив в домашнем каталоге.
   Переименуйте каталог `FreeOberon-main` в `FreeOberon`.

2. Находясь в распакованном каталоге, запустите `install.sh` с правами администратора.
  ```
  sudo ./install.sh
  ```
  или
  ```
  su
  ./install.sh
  ```

3. (по желанию) Допишите в конец файла `~/.bashrc` строчку:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  Это позволит запускать Free Oberon командой `fo`.

  Для запуска Free Oberon на конкретном языке, укажите язык (en или ru):
  ```
  ./FreeOberon --lang ru
  ```
  или
  ```
  fo --lang ru
  ```


## Установка на Windows

Скачайте архив с сайта [free.oberon.org](https://free.oberon.org), распакуйте его в по такому пути, в котором нет не-латинских букв, и запустите `FreeOberon.exe`.

Примечание. Если вы хотите самостоятельно собрать версию Free Oberon под ОС Windows из исходных кодов, обратитесь к приложению A [документации Free Oberon на free.oberon.org](http://free.oberon.org/files/FreeOberon_v1.0.3_ru.pdf).


# Использование

Запустите Free Oberon и наберите текст программного модуля на языке Оберон (или откройте файл с примером программы, например `Life.Mod`). Нажмите `F9`, чтобы скомпилировать и запустить программу.
Файлы с исходным кодом ваших программ сохраняются в подкаталоге `Programs`, а скомпилированные исполняемые файлы сохраняются в подкаталоге `bin`. Сценарий `Data/bin/compile.sh` (`Data\bin\compile.bat`) используется на Линуксе (Виндоусе) в ходе компиляции. Вы можете править эти сценарии.

Можно писать программы, состоящие из нескольких модулей. Откройте главный модуль и нажмите `F9`. Free Oberon автоматически скомпилирует и скомпонует их в правильном порядке.

Если вы компилируете программу, файл главного модуля которой не находится непосредственно в подкаталоге `Programs`, то скомпилированный исполнимый файл будет находится рядом с ним, а не в подкаталоге `_Build`.

Если в одном из модулей программы будет найдена ошибка, соответствующий файл откроется, место и характер ошибки будут указаны. Чтобы перекомпилировать, снова перейдите к окну главного модуля и нажмите `F9`.

[История версий](HISTORY.md)

______


*ENGLISH*

* Version 1.1.0-alpha.7
* Riga, January 11, 2023
* Website: [free.oberon.org](https://free.oberon.org/en)

# Install

## Install on Linux

1. Download Free Oberon in tar.gz format from
   [free.oberon.org](https://free.oberon.org/en/download)
   and unpack it inside home directory (or in any other place).

   Option (edge build):

   Go to https://github.com/kekcleader/FreeOberon.git and
   click the green button labeled "Code" and then click "Download ZIP",
   unpack the archive inside your home directory.
   Rename directory `FreeOberon-main` to `FreeOberon`.

2. Inside the unpacked directory, run `install.sh` with root privileges.
  ```
  sudo ./install.sh
  ```
  or
  ```
  su
  ./install.sh
  ```

3. (optional) Append the following line to the end of file `~/.bashrc`:
  ```
  alias fo='cd ~/FreeOberon;./FreeOberon'
  ```
  This will allow you to launch Free Oberon using the `fo` command.

  To run Free Oberon in a specific language, specify it (en or ru):
  ```
  ./FreeOberon --lang ru
  ```
  or
  ```
  fo --lang ru
  ```


## Install on Windows

Download Free Oberon in a ZIP archive (from [free.oberon.org](https://free.oberon.org/en)), extract it to a path on the disk that does not have any non-latin characters in it, and lauch `FreeOberon.exe`.

Note. If you want to recompile Free Oberon under Windows from the source code, refer to Appendix A of the [Free Oberon documentation on free.oberon.org](https://free.oberon.org/files/FreeOberon_v1.0.3_en.pdf).


# Usage

Run Free Oberon and type the text of an Oberon module (or open a sample program such as `Life.Mod`) and press `F9` to compile and run the program.
The source code files of your programs are saved in the `Programs` subdirectory, and the compiled executables are saved in the `bin` subdirectory. The script `Data/bin/compile.sh` (`Data\bin\compile.bat`) is used on Linux (Windows) for compilation. You can edit these scripts.

You can write programs consisting of several modules. Open the main module and press `F9`. Free Oberon automatically compiles and links them in the correct order.

If you compile a program whose main module file is not directly in the `Programs` subdirectory, the compiled executable will be located next to it and not in the `_Build` subdirectory.

If an error occurres during the compilation of one of the modules, the corresponding file will be open and error position and message will be indicated. To recompile, go to the main module window again and press `F9`.

[Version history](HISTORY.md)
