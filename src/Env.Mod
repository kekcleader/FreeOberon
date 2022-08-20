MODULE Env;
IMPORT CmdArgs, Args, Platform, Utf8, SYSTEM;
TYPE SHORTCHAR = Utf8.SHORTCHAR;

VAR count: INTEGER;

PROCEDURE Count*(): INTEGER;
BEGIN
  IF count = -1 THEN count := CmdArgs.EnvCount() END
RETURN count END Count;

PROCEDURE Get*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR q: ARRAY 10240 OF SHORTCHAR;
BEGIN
  IF (0 <= n) & (n < Count()) THEN
    CmdArgs.GetEnvN(n, q); Utf8.Decode(q, s)
  ELSE s := ''
  END
END Get;

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
    Example: 'dir/old/new' -> 'dir/old/'. *)
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

(** Example: '///' -> '/'. *)
PROCEDURE RemoveDoubleSlashes(VAR s: ARRAY OF CHAR);
BEGIN (*!TODO*)
END RemoveDoubleSlashes;

(** Example: './' -> ''. *)
PROCEDURE RemoveDotDirs(VAR s: ARRAY OF CHAR);
BEGIN (*!TODO*)
END RemoveDotDirs;

(** Example: 'dir/..' -> ''. *)
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

PROCEDURE GetAppDir*(VAR s: ARRAY OF CHAR);
VAR z: ARRAY 1024 OF SHORTCHAR;
BEGIN
  IF Platform.Windows THEN Platform.GetAppDir(z); Utf8.Decode(z, s)
  ELSE GetAppDirUnix(s)
  END
END GetAppDir;

PROCEDURE GetLang*(VAR s: ARRAY OF CHAR);
VAR z: ARRAY 256 OF SHORTCHAR;
BEGIN Platform.GetLang(z); Utf8.Decode(z, s)
END GetLang;

BEGIN
  count := -1
END Env.
