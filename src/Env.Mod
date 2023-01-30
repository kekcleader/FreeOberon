MODULE Env;
(** OS environment variables
%RU Переменные окружения ОС *)
IMPORT CmdArgs, Args, Platform, Utf8, Strings, SYSTEM, Out;
TYPE SHORTCHAR = Utf8.SHORTCHAR;

VAR count: INTEGER;

(** Return the number of environment variables.
     If Count() returns N, then you can call Get(x) with 0 <= x < N.
%RU Возвращает количество переменных окружения.                        
     Если Count() возвращает N, то вы можно вызвать Get(x), где 0 <= x < N. *)
PROCEDURE Count*(): INTEGER;
BEGIN
  IF count = -1 THEN count := CmdArgs.EnvCount() END
RETURN count END Count;

(** Puts in `s` the `n`th environment variable as a string containing a key,
    equal sign and possibly a value (i.e. 'PATH=/usr/bin').
     `n` must be in range 0 <= x < N, where N is the result of Count()
%RU Помещает в `s` `n`-ю переменную окружения в виде строки, содержащей ключ,
    знак равенства и, возможно, значение (например, 'PATH=/usr/bin').
     `n` должно быть в диапазоне 0 <= x < N, где N -- результат Count() *)
PROCEDURE Get*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR q: ARRAY 10240 OF SHORTCHAR;
BEGIN
  IF (0 <= n) & (n < Count()) THEN
    CmdArgs.GetEnvN(n, q); Utf8.Decode(q, s)
  ELSE s := ''
  END
END Get;

(** Puts in `val` the value of the environment variable with the given `name`.
     If there is no such variable, puts an empty string in val.
%RU Помещает в `val` значение переменной окружения с заданным `именем`.
     Если такой переменной нет, помещает в val пустую строку. *)
PROCEDURE GetByName*(name: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
VAR q: ARRAY 10240 OF SHORTCHAR;
  z: ARRAY 1024 OF SHORTCHAR;
BEGIN Utf8.Encode(name, z); CmdArgs.GetEnv(z, q); Utf8.Decode(q, val)
END GetByName;

PROCEDURE SearchPath(arg, path: ARRAY OF CHAR; VAR s: ARRAY OF CHAR): BOOLEAN;
VAR i, j, k: INTEGER;
  p: ARRAY 1000 OF CHAR;
  q: ARRAY 2000 OF SHORTCHAR;
  found: BOOLEAN;
BEGIN
  i := 0; found := FALSE;
  WHILE (path[i] # 0X) & ~found DO
    j := 0; (* Copy PATH segment to p *)
    WHILE (j < LEN(p) - 2) & (path[i] # 0X) & (path[i] # ':') DO
      p[j] := path[i]; INC(i); INC(j)
    END;
    (* Make sure p ends with / *)
    IF (j # 0) & (p[j - 1] # '/') THEN p[j] := '/'; INC(j) END;

    k := 0; (* Append arg to p *)
    WHILE (j < LEN(p) - 1) & (arg[k] # 0X) DO
      p[j] := arg[k]; INC(j); INC(k)
    END;
    p[j] := 0X;

    Utf8.Encode(p, q);
    IF Platform.FileExists(q) THEN found := TRUE END;

    (* Move i to next PATH segment *)
    IF path[i] = ':' THEN INC(i) END
  END;
  IF found THEN
    i := 0;
    WHILE (i < LEN(s) - 1) & (p[i] # 0X) DO s[i] := p[i]; INC(i) END;
    s[i] := 0X
  END
RETURN found END SearchPath;

(** Removes base name (and a slash) in path s.
     Example: 'dir/old/new' -> 'dir/old/'.
%RU Удаляет базовое имя (и косую черту) в пути s.
     Пример: 'dir/old/new' -> 'dir/old/'. *)
PROCEDURE RemoveBaseName(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  (* Find 0X *)
  i := 0; WHILE s[i] # 0X DO INC(i) END;
  (* Go back and find / *)
  WHILE (i # -1) & (s[i] # '/') DO DEC(i) END;
  (* Truncate string at position of / + 1, or clear string *)
  s[i + 1] := 0X
END RemoveBaseName;

(** Removes double, tripple etc. slashes from `s`.
     Example: '///' -> '/'
     DOES NOT WORK
%RU Удаляет двойные, тройные и т. д. литеры дроби из `s`.                       
     Пример: '///' -> '/'
     НЕ РАБОТАЕТ *)
PROCEDURE RemoveDoubleSlashes(VAR s: ARRAY OF CHAR);
BEGIN (*!TODO*)
END RemoveDoubleSlashes;

(** Leaves '/' in the end. Example: './' -> ''.
%RU Оставляет '/' в конце. Пример: './' -> ''. *)
PROCEDURE RemoveDotDirs(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    WHILE (s[i] # 0X) & (s[i] # '.') DO INC(i) END;
    IF s[i] # 0X THEN (* Found a dot *)
      IF (s[i + 1] = '/') & ((i = 0) OR (s[i - 1] = '/')) THEN
        Strings.Delete(s, i, 2)
      ELSE INC(i)
      END
    END
  END;
  IF (i > 1) & (s[i - 2] = '/') & (s[i - 1] = '.') THEN s[i - 1] := 0X END
END RemoveDotDirs;

(** Removes (resolves) backtracking in paths (dobule periods).
     Example: 'dir/..' -> ''.
%RU Устраняет (разрешает) фрагменты обратного пути в строке (две точки).             
     Пример: 'dir/..' -> ''. *)
PROCEDURE RemoveBacktracking(VAR s: ARRAY OF CHAR);
BEGIN (*!TODO*)
END RemoveBacktracking;

PROCEDURE ResolveSymLinks(VAR s: ARRAY OF CHAR);
BEGIN (*!TODO*)
END ResolveSymLinks;

PROCEDURE GetAppDirUnix(VAR s: ARRAY OF CHAR);
VAR q: ARRAY 16384 OF SHORTCHAR;
  path: ARRAY 16384 OF CHAR;
  pwd, arg: ARRAY 1024 OF CHAR;
  i, j: INTEGER;
  argHasSlash: BOOLEAN;
BEGIN
  GetByName('PWD', pwd);
  GetByName('PATH', path);
  CmdArgs.Get(0, q); Utf8.Decode(q, arg);
  (* Remove / from end of pwd *)
  i := 0; WHILE pwd[i] # 0X DO INC(i) END;
  IF i # 0 THEN
    DEC(i);
    IF pwd[i] = '/' THEN pwd[i] := 0X END
  END;

  IF arg[0] = '/' THEN i := 0;
    WHILE (i < LEN(s) - 1) & (arg[i] # 0X) DO s[i] := arg[i]; INC(i) END
  ELSE
    i := 0; WHILE (arg[i] # 0X) & (arg[i] # '/') DO INC(i) END;
    (* IF there is at least one / in arg *)
    IF arg[i] # 0X THEN
      i := 0; (* Copy s to pwd, make i := Length(s) *)
      WHILE (i < LEN(s) - 2) & (pwd[i] # 0X) DO s[i] := pwd[i]; INC(i) END;
      s[i] := '/'; INC(i); (* Append / to s *)
      j := 0; (* Append arg to s *)
      WHILE (i < LEN(s) - 1) & (arg[j] # 0X) DO
        s[i] := arg[j]; INC(i); INC(j)
      END;
      s[i] := 0X
    ELSIF ~SearchPath(arg, path, s) THEN s[0] := 0X (* Error *)
    END
  END;
  IF s[0] # 0X THEN
    RemoveBaseName(s);
    RemoveDoubleSlashes(s);
    RemoveDotDirs(s);
    RemoveBacktracking(s);
    ResolveSymLinks(s);
  END
END GetAppDirUnix;

(** Returns a full path to the application directory. That is the directory
    where the executable file of the currently running program resides.
     The path ends with delimeter / or \ (in the case of Windows).
     It might not be logically possible to determine application directory
    in some cases on Linux/Unix systems
%RU Возвращает полный путь к директории приложения. Это тот каталог, в котором
    находится исполняемый файл текущей запущенной программы.
     Путь заканчивается разделителем / или \ (в случае Windows).
     В некоторых случаях определить каталог приложения может быть оказаться
    логически невозможным в ОС Linux/Unix *)
PROCEDURE GetAppDir*(VAR s: ARRAY OF CHAR);
VAR z: ARRAY 1024 OF SHORTCHAR;
BEGIN
  IF Platform.Windows THEN Platform.GetAppDir(z); Utf8.Decode(z, s)
  ELSE GetAppDirUnix(s)
  END
END GetAppDir;

(** Puts in `s` the language of the user interface (the OS) as a lower case
    2-character string.
     Examples: 'en', 'ru'.
%RU Помещает в `s` язык пользовательского интерфейса (ОС) в виде строки из
    двух литер в нижнем регистре.
     Например: 'en', 'ru'. *)
PROCEDURE GetLang*(VAR s: ARRAY OF CHAR);
VAR z: ARRAY 256 OF SHORTCHAR;
BEGIN Platform.GetLang(z); Utf8.Decode(z, s)
END GetLang;

BEGIN
  count := -1
END Env.
