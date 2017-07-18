## Compiling

An Oberon command line program is built from one or more modules. One module must be designated a main module.

### Files generated

From each non-main module the following files are generated in the current directory:

| Filename         | Purpose                                                                    |
| ----------       | ---------------------------------------------------------------------      |
| ```module.sym``` | Oberon symbols required to ```IMPORT``` this module in another compilation.|
| ```module.c```   | C source code for compilation by gcc, clang or msc.                        |
| ```module.h```   | C header files required by C compiler when importing this module.          |

Note that the filename of the .sym, .c and .h files is the name of the module from the ```MODULE``` statement at the start of the source file. It is not the name of the .mod file.

If the compilation is successful, the Oberon compiler will automatically invoke the C compiler. The compiler option ```-V``` will cause the compiler to display the C compiler command used.

### Successful compilation report

For a successful compilation, the compiler displays a single line comprising

  * The name of the file being compiled
  * The name of the module from the ```MODULE``` statment
  * Compiler configuration (only if the ```-V``` verbose option is selected)
  * A possible symbol update status message
  * The number of characters compiled
  
If a symbols file already exists, the compiler will check whether the new compilation changes the symbols, and if so whether the change is just an extension, or a more serious compatability threatening modification. If there is a change the compiler displays either ```Extended symbol file``` or ```New symbol file```.

For example:

```
$ voc test.mod
test.mod  Compiling test.  New symbol file.  364 chars.
```
  
### Symbol file changes
  
By default the compiler will refuse to compile a module if its symbols are different from those in the .sym file present from a previous compilation. To allow the compiler to change the symbols, one of the following options must be used.

| Compiler option | Use                         |
| :-------------: | --------------------------- | 
| ```-e```        | Allow extension of symbols. Do not allow changes to existing symbols. |
| ```-s```        | Allow changes to and extensions of symbols. |
| ```-F```        | Force generation of new symbol file.* |

\* A new symbol file may be forced to guarantee that a symbol file is generated for a module that has the same name as an installed library module.

### Main module

The main module should be the last module compiled as it imports all other modules.

The program logic should be started from the main module's initialisation code.

The following options designate the main module:

| Compiler option | Use                                                                                  |
| :-------------: | ---------------------------                                                          | 
| ```-m```        | Generate loadable binary using dynamic library loading (on systems that support it). |
| ```-M```        | Generate loadable binary with all library references statically linked.              |

For a main module, no .sym or .h files are generated, and the C compiler is called with additional parameters to generate the execututable binary, linking the object files needed for imported modules.

### Separate compilation

Each module may be compiled by a separate command line, although the imports of a module must be compiled before the module is compiled. All three generated files (.sym, .c and .h) must be retained at least until all modules dependent on this module have been compiled.

Multiple modules may be compiled on a single compiler command line. 

Options on the command line that preceed all module file names will be used as  global settings: each module will be compiled with these settings except as overriden on a per file basis.

Options on the command line that follow a module file name are specific to that module.

For example:

```
  voc -s alpha.mod beta.mod main.mod -m
```
 
Will apply the ```-s``` option to all modules (allow changes to and extension of symbols), and will apply the ```-m``` option (main program) only to ```main.mod```.

