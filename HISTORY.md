## 1.1.0-alpha.7 - 2023-01-11

* Debug output and "--debug" key
* Unicode support in modules In and Out on Windows
* Automatic linking of external libraries
* OS clipboard integration
* Fix paste of large text
* Fix compilation outside FreeOberon directory on Windows
* Fix parser in project builder

## 1.1.0-alpha.6 - 2022-04-22

* OS UI language is used
* File dialog opens the last used directory
* Enhance video mode on Linux
* Introduce Fob - the Oberon console compiler
* Add Graph.Circle
* Add module Env for environment variable access
* ReadKey works with more special keys
* Fix random compilation and linking errors on Windows

## 1.1.0-alpha.5 - 2022-02-20

* Fix POSIX file creation/rename when temp path was on another partition
* Fix REAL output in modules Out and Reals
* Fix Graph.HLine, Graph.VLine and Graph.GetDesktopResolution, Graph.ReadKey
* Add SetClip, UnsetClip, MakeRGBA, ClearBitmapToColor in module Graph

## 1.1.0-alpha.4 - 2022-02-10

* Allow usage of module Graph on Windows
* Implement Graph.KeyDown, Graph.ReadKey, Graph.Pause
* Add example program TestGraph
* WinAPI: Fix environment variables when running a compiled program
* Implement types Texts.Writer, Texts.Buffer
* Update example program BlitBmp and rename it to Rocket
* Replace SDL2 version of Graph with the Allegro5 version (Graph2)

## 1.1.0-alpha.3 - 2022-01-29

* Implement source code search
* Update supplied MinGW bundle, remove some files
* Allow Free Oberon recompilation on Windows using only the 22 MB archive

## 1.1.0-alpha.2 - 2022-01-27

* Merge branches allegro and master, master renamed to main
* Implement install.sh for easy setup on Linux
* Fix compilation of Free Oberon on Windows

## 1.1.0-alpha.1 - 2022-01-22

* Repleace Oberon-to-C translator Vishap with Ofront+, CHAR supports Unicode
* Switch internally from CP866 to UCS2, leave UTF-8 externally
* Rewrite Graph.Font, add support for Latin-1 and Cyrillic characters
* Implement module Graph2 - new vesrion of Graph, but based on Allegro5, not SDL2
* Implement module TermBox, which runs on top of Graph2
* Refactor Free Oberon to run on top of TermBox
* Replace Makefiles with scripts make.sh and make.bat
* Implement module Dir for directory tree traversal
* Update file open/save dialog, add list of files
* Allow compilation of external programs - in other directories
* Run programs in bin directory, run external programs in their directories
* Internationalize Free Oberon, add language files
* Add English and Russian localization

## 1.0.3 - 2019.06.18

* Allow compilation of project consisting of several modules
* Accept parameters --window and --software, treat other pararmeters as file names
* Implement menu commands Window → Tile and Window → Cascade
* Add examples GEVM and Gui
* WinAPI: Fix Free Oberon crash on a launch of a compiled program
* Update documentation and finish its translation to English

## 1.0.2 - 2019.04.07

* Highlight trailing spaces
* Fix some bugs

## 1.0.1 - 2018.05.18

* Fix seek error position after compilation
* Disable non-working menu items
* Automatically determine whether to link with SDL2

## 1.0.0 - 2017.07.19

* Fix seek error position after compilation
* Use Vishap Oberon-to-C translator and 32-bit MinGW C compiler
* Use CP866 as internal encoding, UTF-8 as external encoding
* Implement module Graph based on SDL2
* Implement module OV (Oberon Vision) - Oberon analogue of Turbo Vision
* Write documentation
