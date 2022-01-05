MODULE Dir; (*This is Oberon-07 style file*)
IMPORT C := arC, arCString, SYSTEM, Platform, Out, Utf8;

TYPE
  DIR = SYSTEM.ADRINT;
  DIRENT = SYSTEM.ADRINT;
  SHORTCHAR = SYSTEM.CHAR8;

  Rec* = RECORD
    eod*: BOOLEAN; (* End of directory *)
    isDir*: BOOLEAN; (* TRUE if current entry is a directory *)
    res*: INTEGER; (* 0 means no error *)
    name*: ARRAY 512 OF CHAR;
    path: ARRAY 1024 OF CHAR;
    pathlen: INTEGER;
    dir: DIR
  END;

PROCEDURE -AAincludeDirent "#include <dirent.h>";

PROCEDURE -opendir(name: ARRAY OF SHORTCHAR): DIR "(SYSTEM_ADRINT) opendir((const char *)name)";
PROCEDURE -closedir(dir: DIR) "closedir((DIR*) dir)";
PROCEDURE -readdir(dir: DIR): DIRENT "(SYSTEM_ADRINT) readdir((DIR*) dir)";
PROCEDURE -rewinddir(dir: DIR) "rewinddir((DIR*) dir)";
PROCEDURE -getdirname(ent: DIRENT): C.string "(CHAR *)(((struct dirent *) ent) -> d_name)";
PROCEDURE -getdirtype(ent: DIRENT): C.int "(int)((struct dirent *) ent) -> d_type)";
PROCEDURE -typeDir "DT_DIR";
PROCEDURE -typeReg "DT_REG";
PROCEDURE -typeLink "DT_LNK";

PROCEDURE Close*(VAR r: Rec);
(* Stop enumerating files. MUST BE CALLED to avoid leaking C directory streams *)
BEGIN
  IF r.dir # 0 THEN closedir(r.dir); r.dir := 0 END
  (*!TODO add this to finalization *)
END Close;

PROCEDURE Next*(VAR r: Rec);
VAR ent: DIRENT;
  i, j: INTEGER;
  s: ARRAY 2048 OF SYSTEM.CHAR8;
BEGIN
  IF r.dir # 0 THEN
    r.res := 0;
    ent := readdir(r.dir);
    IF ent # 0 THEN
      arCString.CopyToArray(getdirname(ent), s);
      Utf8.Decode(s, r.name);

      (* To set the value of r.isDir, we (maybe) append '/' and name to path,
         pass it to DirExists and then restore the original value of path. *)

      i := 0; j := r.pathlen;
      IF r.path[j] # Platform.PathDelimiter THEN
        r.path[j] := Platform.PathDelimiter; INC(j)
      END;
      WHILE (j < LEN(r.path) - 1) & (r.name[i] # 0X) DO
        r.path[j] := r.name[i]; INC(i); INC(j)
      END;
      IF j < LEN(r.path) - 1 THEN
        r.path[j] := 0X;
        Utf8.Encode(r.path, s);
        r.isDir := Platform.DirExists(s)
      ELSE r.isDir := FALSE; r.res := 3; r.eod := TRUE
      END;
      r.path[r.pathlen] := 0X

    ELSE r.eod := TRUE
    END
  ELSE r.res := 4; r.eod := TRUE
  END
END Next;

PROCEDURE First*(VAR r: Rec; path: ARRAY OF CHAR);
VAR i: INTEGER;
  s: ARRAY 2048 OF SHORTCHAR;
BEGIN r.isDir := FALSE; r.name[0] := 0X;
  i := 0; WHILE path[i] # 0X DO INC(i) END;
  IF i < LEN(r.path) - 13 THEN
    IF path[0] = 0X THEN r.dir := opendir('.'); r.path := './'; r.pathlen := 2
    ELSE Utf8.Encode(path, s); r.dir := opendir(s); r.path := path; r.pathlen := i
    END;
    IF r.dir # 0 THEN r.eod := FALSE; Next(r)
    ELSE r.res := 1; r.eod := TRUE; r.path[0] := 0X
    END
  ELSE r.res := 2; r.eod := TRUE; r.path[0] := 0X
  END
END First;

PROCEDURE Rewind*(VAR r: Rec);
BEGIN
  IF r.dir # 0 THEN rewinddir(r.dir); r.res := 0; r.eod := FALSE; Next(r)
  ELSE First(r, r.path)
  END
END Rewind;

PROCEDURE FileExists*(name: ARRAY OF CHAR): BOOLEAN;
VAR s: ARRAY 2048 OF SYSTEM.CHAR8;
BEGIN Utf8.Encode(name, s)
RETURN Platform.FileExists(s) END FileExists;

PROCEDURE IsDir*(name: ARRAY OF CHAR): BOOLEAN;
VAR s: ARRAY 2048 OF SYSTEM.CHAR8;
BEGIN Utf8.Encode(name, s)
RETURN (name[0] = 0X) OR Platform.DirExists(s) END IsDir;

PROCEDURE GetCwd*(VAR dir: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (Platform.CWD[i] # 0X) & (i < LEN(dir) - 1) DO
    dir[i] := Platform.CWD[i]; INC(i)
  END;
  dir[i] := 0X
END GetCwd;

END Dir.
