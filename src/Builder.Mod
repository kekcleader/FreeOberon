MODULE Builder;
(* Copyright 2017-2023 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Free Oberon.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT Term, FoStrings, Files, Utf8, Config, Func, Strings,
  Int, Out, Debug, Env, Dir, Kernel;
(** Free Oberon builder and compiler runner. Builder finds files of the
    compiled program, interrelates them, puts them in order, compiles every
    one of them and links the program. Part of Free Oberon IDE internal code *)
TYPE
  Module* = POINTER TO ModuleDesc;
  ModuleDesc* = RECORD
    s*: ARRAY 64 OF CHAR; (* Module name *)
    fname*: ARRAY 256 OF CHAR; (* Filename of module source *)
    libs*: ARRAY 4096 OF CHAR; (* String from speical comments *)
    foreign*: BOOLEAN; (* TRUE for bindings that do not produce a C-file *)
    system*: BOOLEAN;
    next*: Module
  END;

  ErrorHandler* = PROCEDURE (IN fname: ARRAY OF CHAR;
    col, line, error: INTEGER; IN msg: ARRAY OF CHAR);

VAR
  sysModules: Module;
  target: ARRAY 64 OF CHAR; (* 'LINUX' or 'WIN32' *)
  wrongLinkTarget: BOOLEAN; (* TRUE if target was given and does not match *)
  findLinkInfo: Module; (* If not NIL, "%LINK" comments will be saved here *)
  workDir*: ARRAY 1024 OF CHAR; (* Directory of main file of compiled program *)

PROCEDURE IsSysModule(IN name: ARRAY OF CHAR): BOOLEAN;
VAR p: Module;
BEGIN p := sysModules;
  WHILE (p # NIL) & (p.s # name) DO p := p.next END ;
RETURN p # NIL END IsSysModule;

PROCEDURE GetSysLibs(IN name: ARRAY OF CHAR; OUT libs: ARRAY OF CHAR);
VAR p: Module;
BEGIN p := sysModules;
  WHILE (p # NIL) & (p.s # name) DO p := p.next END ;
  IF p # NIL THEN libs := p.libs$ ELSE libs[0] := 0X END
END GetSysLibs;

PROCEDURE ModuleExists(IN fname: ARRAY OF CHAR): BOOLEAN;
VAR F: Files.File;
  exists: BOOLEAN;
BEGIN F := Files.Old(fname); exists := F # NIL;
  IF exists THEN Files.Close(F) END ;
RETURN exists END ModuleExists;

PROCEDURE SetWorkDir*(IN fname: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := Strings.Length(fname) - 1;
  WHILE (i # -1) & (fname[i] # '/') & (fname[i] # '\') DO DEC(i) END;
  IF i # -1 THEN Strings.Extract(fname, 0, i + 1, workDir)
  ELSE workDir[0] := 0X
  END
END SetWorkDir;

PROCEDURE SplitModName(IN s: ARRAY OF CHAR;
    VAR m1, m2: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER;
BEGIN i := 1;
  WHILE (s[i] # 0X) & ~(('A' <= s[i]) & (s[i] <= 'Z') &
                        ~(('A' <= s[i - 1]) & (s[i - 1] <= 'Z')))
  DO INC(i)
  END;
  IF s[i] # 0X THEN
    Strings.Extract(s, 0, i, m1);
    Strings.Extract(s, i, LEN(m2), m2)
  END ;
RETURN s[i] # 0X END SplitModName;

PROCEDURE FindModule(IN mod: ARRAY OF CHAR; VAR fname: ARRAY OF CHAR): BOOLEAN;
VAR ok: BOOLEAN;
  s, m1, m2: ARRAY 256 OF CHAR;
BEGIN ok := FALSE; (* Try 'Programs/A/GuiButtons.Mod' *)
  s := workDir$; Strings.Append(mod, s); Strings.Append('.Mod', s);
  IF ModuleExists(s) THEN fname := s$; ok := TRUE
  ELSIF SplitModName(mod, m1, m2) THEN (* Try 'Programs/A/Gui/Buttons.Mod' *)
    s := workDir$; Strings.Append(m1, s); Strings.Append('/', s);
    Strings.Append(m2, s); Strings.Append('.Mod', s);
    IF ModuleExists(s) THEN fname := s$; ok := TRUE END
  END ;
RETURN ok END FindModule;

(* !TODO move out, rewrite *)
PROCEDURE StringsFindNext*(what, where: ARRAY OF CHAR;
    begin: INTEGER; VAR found: BOOLEAN; VAR resultPos: INTEGER);
VAR i: INTEGER;
BEGIN
  IF begin < Strings.Length(where) THEN i := 0;
    LOOP
      IF what[i] = 0X THEN
        (* reached end of what *)
        found := TRUE; resultPos := begin - i;
        EXIT
      ELSIF where[begin] = 0X THEN
        (* end of string (but not of what) *)
        found := FALSE;
        EXIT
      ELSIF where[begin] = what[i] THEN
        (* characters identic, compare next one *)
        INC(begin); INC(i)
      ELSE
        (* difference found: reset indices and restart *)
        DEC(begin, i - 1); i := 0
      END
    END
  ELSE found := FALSE
  END
END StringsFindNext;

PROCEDURE ReadInt(IN s: ARRAY OF CHAR; VAR i, res: INTEGER);
BEGIN res := 0;
  WHILE ('0' <= s[i]) & (s[i] <= '9') DO
    res := res * 10 + ORD(s[i]) - ORD('0');
    INC(i)
  END
END ReadInt;

PROCEDURE ParseErrors(VAR s: ARRAY OF CHAR; fname: ARRAY OF CHAR;
    VAR line, col, error: INTEGER);
VAR i, j, st, len, skip: INTEGER; found: BOOLEAN;
BEGIN fname[0] := 0X; line := 1; col := 1;
  StringsFindNext(' translating ', s, 0, found, i);
  IF found THEN INC(i, 13); j := 0; (* Read module name *)
    WHILE (j < LEN(fname) - 1) & (s[i] > ' ') DO
      fname[j] := s[i]; INC(i); INC(j)
    END;
    fname[j] := 0X;
    (* Remove everything up to the following line *)
    WHILE (s[i] # 0X) & (s[i] # 0AX) DO INC(i) END;
    Strings.Delete(s, 0, i + 1); i := 0;
    (* Read line and column numbers, i.e. '10:23' *)
    WHILE (s[i] # 0X) & (s[i] <= ' ') DO INC(i) END;
    IF ('0' <= s[i]) & (s[i] <= '9') THEN
      ReadInt(s, i, line);
      IF s[i] = ':' THEN INC(i) END;
      IF ('0' <= s[i]) & (s[i] <= '9') THEN
        ReadInt(s, i, col)
      END;
      WHILE (s[i] # 0X) & (s[i] # 'e') DO INC(i) END;
      IF (s[i + 1] = 'r') & (s[i + 2] = 'r') & (s[i + 3] = ' ') THEN
        INC(i, 4); ReadInt(s, i, error)
      ELSE error := 0
      END;
      FoStrings.MakeErrorStr(error, s)
    END
  ELSE StringsFindNext('): ', s, 0, found, i); (* In case of gcc error *)
    IF found THEN Strings.Delete(s, 0, i + 3) END;
    i := 0; WHILE (s[i] # 0X) & (s[i] # 0AX) & (s[i] # 0DX) DO INC(i) END;
    s[i] := 0X
  END
END ParseErrors;

(* "Module.Mod" -> "Module" *)
PROCEDURE GetModuleName*(IN fname: ARRAY OF CHAR; VAR modname: ARRAY OF CHAR);
VAR i, j: INTEGER;
BEGIN i := 0; j := 0;
  WHILE fname[i] # 0X DO INC(i) END; DEC(i);
  WHILE (i # -1) & (fname[i] # '/') & (fname[i] # '\') DO DEC(i) END; INC(i);
  WHILE (fname[i] # 0X) & (fname[i] # '.') DO
    modname[j] := fname[i]; INC(i); INC(j)
  END;
  modname[j] := 0X
END GetModuleName;

(* Appends relative or full path of 'Data/bin/' or 'Data\bin\' to s *)
PROCEDURE AppendDataBin(VAR s: ARRAY OF CHAR);
VAR dir: ARRAY 1024 OF CHAR;
BEGIN
  Env.GetAppDir(s);
  IF Config.isWindows THEN Strings.Append('Data\bin\', s)
  ELSE Strings.Append('Data/bin/', s)
  END
END AppendDataBin;

PROCEDURE AppendArgument(IN arg: ARRAY OF CHAR; VAR s: ARRAY OF CHAR);
BEGIN Strings.Append(arg, s)
END AppendArgument;

(*PROCEDURE AppendArgument(IN arg: ARRAY OF CHAR; VAR s: ARRAY OF CHAR);
VAR i, j: INTEGER;
BEGIN
  j := 0; WHILE s[j] # 0X DO INC(j) END;
  i := 0;
  WHILE arg[i] # 0X DO
    IF arg[i] = ',' THEN s[j] := '^'; INC(j); s[j] := ','
    ELSE s[j] := arg[i]
    END;
    INC(i); INC(j)
  END;
  s[j] := 0X
END AppendArgument;*)

PROCEDURE RunCommand(IN fname, mod: ARRAY OF CHAR; link, main: BOOLEAN;
    list: Module; onError: ErrorHandler): BOOLEAN;
CONST bufLen = 20480;
VAR buf: ARRAY bufLen OF SHORTCHAR;
  p: Module;
  len, err, line, col, error: INTEGER;
  command: ARRAY 32 OF CHAR;
  q: ARRAY 1024 OF SHORTCHAR;
  z: ARRAY 1024 OF CHAR;
  cmd: ARRAY 1024 OF CHAR;
  s, sN: ARRAY 80 OF CHAR;
  success, ok: BOOLEAN;
BEGIN ok := TRUE;
  IF ~link THEN command := 'compile' ELSE command := 'link' END;
  IF Config.isWindows THEN
    IF Term.SearchPath('cmd.exe', q) # 0 THEN
      Utf8.Decode(q, cmd); Strings.Insert('"', 0, cmd);
      Strings.Append('" /C ', cmd); AppendDataBin(cmd);
      Strings.Append(command, cmd); Strings.Append('.bat ', cmd)
    ELSE ok := FALSE; onError('', -1, -1, -1, 'Could not find cmd.exe')
    END
  ELSE (* Linux *)
    cmd := ''; AppendDataBin(cmd);
    Strings.Append(command, cmd);
    Strings.Append('.sh ', cmd)
  END;

  IF ok THEN
    s := fname$; Func.FixFname(s); Strings.Append(s, cmd);

    IF main THEN Strings.Append(' -m', cmd)
    ELSIF link & (list # NIL) THEN
      p := list;
      WHILE p.next # NIL DO
        IF ~p.foreign & ModuleExists(p.fname) THEN
          Strings.Append(' ', cmd); Strings.Append(p.s, cmd);
          Strings.Append('.c', cmd)
        END;
        p := p.next
      END;
      Strings.Append(' --linker-libs', cmd);
      p := list;
      WHILE p.next # NIL DO
        IF p.libs[0] # 0X THEN
          Strings.Append(' ', cmd); AppendArgument(p.libs, cmd)
        END;
        p := p.next
      END
    END;
    IF Config.debug THEN
      Out.String('Running command "'); Out.String(cmd); Out.Char('"'); Out.Ln
    END;
    Utf8.Encode(cmd, q);

    success := (Term.RunProcess(q, buf, bufLen, len, err) # 0) & (err = 0);
    IF ~success & (onError # NIL) THEN
      z := ''; line := 0; col := 0;
      IF (len > 0) & (len < bufLen) THEN
        IF buf[len - 1] = 0AX THEN buf[len - 1] := 0X ELSE buf[len] := 0X END;
        Utf8.Decode(buf, z);
        ParseErrors(z, fname, line, col, error)
      ELSIF link THEN FoStrings.GetErrorStr(422, z)
      ELSE FoStrings.GetErrorStr(421, z)
      END;
      IF z = '' THEN
        s := ' Command returned '; Int.Append(err, s);
        Strings.Append(' exit status ', s);
        onError('', -1, -1, -1, s)
      ELSE onError(fname, col, line, error, z)
      END
    END
  END ;
RETURN success END RunCommand;

PROCEDURE Compile(IN fname, mod: ARRAY OF CHAR; main: BOOLEAN;
  onError: ErrorHandler): BOOLEAN;
BEGIN RETURN RunCommand(fname, mod, FALSE, main, NIL, onError)
END Compile;

PROCEDURE Link(IN fname, mod: ARRAY OF CHAR;
    list: Module; VAR exename: ARRAY OF CHAR;
    onError: ErrorHandler; moveToCwd: BOOLEAN): BOOLEAN;
VAR ok: BOOLEAN;
  s: ARRAY 2048 OF CHAR;
  res: INTEGER;
BEGIN ok := RunCommand(fname, mod, TRUE, FALSE, list, onError);
  IF ok THEN (* Move executable file if workDir is non-standard *)
    s := mod$; IF Config.isWindows THEN Strings.Append('.exe', s) END;
    exename := '_Build/'; Strings.Append(s, exename);
    IF moveToCwd THEN
      Files.Rename(exename, s, res);
      IF res = 0 THEN exename := s$ END
    ELSIF workDir # Config.stdPath THEN
      Strings.Insert(workDir, 0, s);
      Files.Rename(exename, s, res);
      IF res = 0 THEN exename := s$ END
    END
  END ;
RETURN ok END Link;

PROCEDURE ResetSysModules*;

  PROCEDURE Add(s: ARRAY OF CHAR);
  VAR p: Module;
  BEGIN NEW(p); p.s := s$; p.fname[0] := 0X;
    p.next := sysModules; sysModules := p
  END Add;

  PROCEDURE AddGraph;
  VAR p: Module;
  BEGIN
    Add('Graph'); p := sysModules;
    IF Config.isWindows THEN
      p.libs := '-lallegro -lallegro_primitives -lallegro_image';
      Strings.Append(' -lallegro_audio -lallegro_acodec', p.libs);
      Strings.Append(' "-Wl,-subsystem,windows"', p.libs)
    ELSE
      p.libs := '$(pkg-config allegro_primitives-5 allegro_image-5';
      Strings.Append(' allegro_audio-5 allegro_acodec-5', p.libs);
      Strings.Append(' allegro_font-5 allegro_dialog-5', p.libs);
      Strings.Append(' allegro_main-5 allegro-5 --libs --cflags)', p.libs)
    END
  END AddGraph;

BEGIN sysModules := NIL;
  Add('SYSTEM');   Add('Texts');     Add('Files');   Add('Strings');
  Add('In');       Add('Out');       Add('Math');    Add('MathL');
  Add('Modules');  Add('Platform');  Add('Oberon');  Add('Reals');
  Add('VT100');    AddGraph;         Add('Sound');   Add('TermBox');
  Add('Term');     Add('Allegro5');  Add('Dir');     Add('Int');
  Add('Random')
END ResetSysModules;

PROCEDURE GetWord(IN s: ARRAY OF CHAR; VAR i: INTEGER; OUT w: ARRAY OF CHAR);
VAR j: INTEGER;
  c: CHAR;
BEGIN j := 0;
  WHILE (s[i] <= ' ') & (s[i] # 0X) DO INC(i) END;
  c := s[i]; INC(i);
  IF ('A' <= c) & (c <= 'Z') OR ('a' <= c) & (c <= 'z') THEN
    WHILE ('A' <= c) & (c <= 'Z') OR ('a' <= c) & (c <= 'z') OR
          ('0' <= c) & (c <= '9') OR (c = '_')
    DO
      IF ('a' <= c) & (c <= 'z') THEN
        c := CHR(ORD('A') - ORD('a') + ORD(c))
      END;
      w[j] := c;
      INC(j); c := s[i]; INC(i)
    END;
    DEC(i)
  ELSE w[j] := c; INC(j)
  END;
  w[j] := 0X
END GetWord;

PROCEDURE ReadLinkTarget(IN s: ARRAY OF CHAR; VAR i: INTEGER);
VAR w: ARRAY 256 OF CHAR;
BEGIN
  wrongLinkTarget := TRUE;
  GetWord(s, i, w);
  IF w = 'LIBS' THEN
    wrongLinkTarget := FALSE;
    GetWord(s, i, w);
    IF w = '(' THEN
      GetWord(s, i, w);
      IF w # target THEN wrongLinkTarget := TRUE END;
      GetWord(s, i, w);
      IF w = ')' THEN GetWord(s, i, w) ELSE wrongLinkTarget := TRUE END
    END;
    IF w # ':' THEN wrongLinkTarget := TRUE END
  END
END ReadLinkTarget;

PROCEDURE ReadLinkString(IN s: ARRAY OF CHAR; VAR i: INTEGER);
VAR j: INTEGER;
  c: CHAR;
BEGIN
  IF ~wrongLinkTarget THEN j := 0;
    WHILE (s[i] # 0X) & (s[i] <= ' ') DO INC(i) END;
    WHILE (s[i] # 0X) & (j < LEN(findLinkInfo.libs) - 1) DO
      IF s[i] < ' ' THEN c := ' ' ELSE c := s[i] END;
      findLinkInfo.libs[j] := c;
      INC(i); INC(j);
      IF c <= ' ' THEN
        WHILE (s[i] # 0X) & (s[i] <= ' ') DO INC(i) END
      END
    END;
    WHILE (j # 0) & (findLinkInfo.libs[j] <= ' ') DO DEC(j) END;
    findLinkInfo.libs[j + 1] := 0X
  END
END ReadLinkString;

PROCEDURE ReadCh(VAR R: Files.Rider; VAR ch: CHAR; VAR line, col: INTEGER);
BEGIN Files.ReadChar(R, ch);
  IF ch = 0AX THEN INC(line); col := 1 ELSE INC(col) END
END ReadCh;

PROCEDURE ReadLinkInfo(VAR R: Files.Rider; VAR ch: CHAR;
    VAR line, col: INTEGER);
VAR s: ARRAY 40960 OF CHAR;
  last: CHAR;
  i: INTEGER;
BEGIN
  IF ch = 'L' THEN ReadCh(R, ch, line, col);
    IF ch = 'I' THEN ReadCh(R, ch, line, col);
      IF ch = 'B' THEN ReadCh(R, ch, line, col);
        IF ch = 'S' THEN ReadCh(R, ch, line, col);
          s := 'LIBS'; i := 4; last := 'S';
          WHILE ~R.eof & (ch # '%') & ~((last = '*') & (ch = ')')) DO
            IF i < LEN(s) - 1 THEN s[i] := ch; INC(i) END;
            last := ch; ReadCh(R, ch, line, col)
          END;
          IF (i # 0) & (s[i - 1] = '*') THEN DEC(i) END;
          s[i] := 0X; i := 0;
          ReadLinkTarget(s, i);
          ReadLinkString(s, i)
        END
      END
    END
  END
END ReadLinkInfo;

PROCEDURE SkipComment(VAR R: Files.Rider; VAR ch: CHAR;
    VAR line, col: INTEGER);
VAR last: CHAR;
BEGIN
  last := ch; ReadCh(R, ch, line, col);
  WHILE ~R.eof & ~((last = '*') & (ch = ')')) DO
    IF (last = '(') & (ch = '*') THEN SkipComment(R, ch, line, col)
    ELSIF (ch = '%') & (findLinkInfo # NIL) THEN
      ReadCh(R, ch, line, col); ReadLinkInfo(R, ch, line, col)
    ELSE last := ch; ReadCh(R, ch, line, col)
    END
  END;
  IF ~R.eof THEN ReadCh(R, ch, line, col) END;
  WHILE ~R.eof & (ch <= ' ') DO ReadCh(R, ch, line, col) END
END SkipComment;

PROCEDURE GetSym(VAR R: Files.Rider; VAR ch: CHAR; VAR s: ARRAY OF CHAR;
    VAR line, col: INTEGER);
VAR i: INTEGER;
BEGIN
  WHILE ~R.eof & (ch <= ' ') DO ReadCh(R, ch, line, col) END;
  i := 0;
  IF ~R.eof THEN
    WHILE ch = '(' DO
      ReadCh(R, ch, line, col);
      IF ch = '*' THEN ReadCh(R, ch, line, col); SkipComment(R, ch, line, col)
      ELSE s[i] := ch; INC(i)
      END;
      WHILE ~R.eof & (ch <= ' ') DO ReadCh(R, ch, line, col) END
    END;
    IF ('A' <= CAP(ch)) & (CAP(ch) <= 'Z') OR (ch = '_') THEN
      WHILE ~R.eof &
            (('A' <= CAP(ch)) & (CAP(ch) <= 'Z') OR
             ('0' <= ch) & (ch <= '9') OR (ch = '_')) DO
        IF i < LEN(s) - 1 THEN s[i] := ch; INC(i) END;
        ReadCh(R, ch, line, col)
      END
    ELSE
      WHILE ~R.eof & (ch > ' ') &
            ~(('A' <= CAP(ch)) & (CAP(ch) <= 'Z') OR
              ('0' <= ch) & (ch <= '9') OR (ch = '_')) DO
        IF i < LEN(s) - 1 THEN s[i] := ch; INC(i) END;
        ReadCh(R, ch, line, col)
      END
    END
  END;
  s[i] := 0X
END GetSym;

PROCEDURE CompileAll*(modules: Module;
    VAR exename: ARRAY OF CHAR; moveToCwd: BOOLEAN;
    onError: ErrorHandler): BOOLEAN;
VAR p, last: Module;
  ok: BOOLEAN;
BEGIN exename[0] := 0X;
  IF modules # NIL THEN
    ok := TRUE; p := modules;
    WHILE ok & (p.next # NIL) DO
      IF ModuleExists(p.fname) THEN
        IF ~Compile(p.fname, '', FALSE, onError) THEN ok := FALSE END
      ELSIF ~IsSysModule(p.s) THEN ok := FALSE
      END;
      p := p.next
    END;
    IF ok THEN
      IF ~ModuleExists(p.fname) OR ~Compile(p.fname, '', TRUE, onError) THEN
        ok := FALSE
      END;
      ok := ok & Link(p.fname, p.s, modules, exename, onError, moveToCwd)
    END
  ELSE ok := FALSE
  END ;
RETURN ok END CompileAll;

(** Returns true if the two module names are equal.
  modname is the identifier that comes after the keyword MODULE.
  filebase is the file name without the extension; on Windows it
  is allowed to be written in different case. *)
PROCEDURE EqualModuleNames(modname, filebase: ARRAY OF CHAR): BOOLEAN;
BEGIN IF Config.isWindows THEN Strings.Cap(modname); Strings.Cap(filebase) END;
RETURN modname = filebase END EqualModuleNames;

(** Gets import list of a module and its linker libs and flags.
    Returns as Module record. Checks if module name equals the file name. *)
PROCEDURE GetModuleInfo(VAR mod: Module; VAR line, col: INTEGER;
    VAR res: INTEGER): Module;
VAR F: Files.File;
  R: Files.Rider;
  top, p: Module;
  ch: CHAR;
  m, s, fname2: ARRAY 256 OF CHAR;
  exit: BOOLEAN;
BEGIN mod.foreign := FALSE; res := 401; NEW(top); top.next := NIL; p := top;
  F := Files.Old(mod.fname);
  IF F = NIL THEN res := 400
  ELSE Files.Set(R, F, 0); Files.ReadChar(R, ch);
    line := 1; col := 1; GetSym(R, ch, s, line, col);
    IF s = 'MODULE' THEN GetSym(R, ch, s, line, col);
      IF s = '[' THEN
        GetSym(R, ch, s, line, col);
        IF s = 'foreign' THEN mod.foreign := TRUE END;
        REPEAT GetSym(R, ch, s, line, col) UNTIL R.eof OR (s = ']');
        IF ~R.eof THEN GetSym(R, ch, s, line, col) END
      END;
      IF EqualModuleNames(mod.s, s) THEN
        res := 0; findLinkInfo := mod; GetSym(R, ch, s, line, col);
        IF s = ';' THEN
          GetSym(R, ch, s, line, col); res := 0; findLinkInfo := NIL;
          IF s = 'IMPORT' THEN GetSym(R, ch, s, line, col); exit := FALSE;
            WHILE ~exit & ('A' <= CAP(s[0])) & (CAP(s[0]) <= 'Z') DO
              m := s; GetSym(R, ch, s, line, col); fname2[0] := 0X;
              IF s = ':=' THEN GetSym(R, ch, s, line, col);
                m := s; GetSym(R, ch, s, line, col)
              END;
              IF IsSysModule(m) OR FindModule(m, fname2) THEN
                NEW(p.next); p := p.next; p.next := NIL; p.s := m$;
                p.fname := fname2$; p.foreign := FALSE; GetSysLibs(m, p.libs)
              END;
              IF s = ',' THEN GetSym(R, ch, s, line, col)
              ELSE exit := FALSE
              END
            END
          END
        END;
        findLinkInfo := NIL
      ELSE Debug.StrVal('Read name is: ', s);
        Debug.StrVal('Mod name is: ', mod.s)
      END
    ELSE Debug.StrVal('GetImportedModules: First symbol is: ', s)
    END
  END ;
RETURN top.next END GetModuleInfo;

PROCEDURE Includes*(p: Module; modname: ARRAY OF CHAR): BOOLEAN;
BEGIN WHILE (p # NIL) & (p.s # modname) DO p := p.next END ;
RETURN p # NIL END Includes;

PROCEDURE AddUniqueToList(what: Module; VAR where: Module);
VAR p, q, nextP: Module;
BEGIN
  IF where = NIL THEN where := what
  ELSE
    p := what;
    WHILE p # NIL DO
      nextP := p.next;
      IF where.s # p.s THEN
        q := where;
        WHILE (q.next # NIL) & (q.next.s # p.s) DO q := q.next END;
        IF q.next = NIL THEN q.next := p; p.next := NIL END
      END;
      p := nextP
    END
  END
END AddUniqueToList;

PROCEDURE UsedModuleList*(IN modname, fname: ARRAY OF CHAR;
    VAR errFname: ARRAY OF CHAR; VAR errLine, errCol: INTEGER;
    VAR foreign: BOOLEAN; VAR res: INTEGER): Module;
VAR L, list, list2, p, mod: Module;
BEGIN L := NIL; res := 0(*OK*); foreign := FALSE;
  NEW(mod); mod.s := modname$; mod.fname := fname$;
  mod.foreign := FALSE; mod.next := NIL;
  IF IsSysModule(modname) THEN
    NEW(p); p.next := NIL;
    IF (modname = 'TermBox') OR (modname = 'Sound') THEN p.s := 'Graph'
    ELSE p.s := modname$
    END;
    p.fname[0] := 0X;
    p.foreign := FALSE; p.system := TRUE; GetSysLibs(p.s, p.libs);
    AddUniqueToList(p, L)
  ELSE
    list := GetModuleInfo(mod, errLine, errCol, res);
    p := list;
    IF res = 0 THEN
      WHILE (res = 0) & (p # NIL) DO
        IF ~Includes(L, p.s) THEN
          list2 := UsedModuleList(p.s, p.fname, errFname, errLine, errCol,
            p.foreign, res);
          AddUniqueToList(list2, L)
        END;
        p := p.next
      END
    ELSE Strings.Copy(fname, errFname)
    END
  END;
  IF res = 0 THEN AddUniqueToList(mod, L); foreign := mod.foreign END ;
  Debug.String('UsedModuleList modname="'); Debug.String(modname);
  Debug.String('", fname="'); Debug.String(fname);
  Debug.String('", res = '); Debug.Int(res); Debug.Ln ;
RETURN L END UsedModuleList;

BEGIN
  ResetSysModules;
  IF Config.isWindows THEN target := 'WIN32' ELSE target := 'LINUX' END
END Builder.
