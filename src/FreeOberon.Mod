MODULE FreeOberon;
(* Copyright 2017-2019 Arthur Yefimov

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
IMPORT G := Graph, T := Terminal, Files, Modules,
       OV, Editor, Term, Config, Strings, Out;
CONST
  version* = '1.0.3';

  (* Direction of Selection *)
  dirLeft  = 0;
  dirRight = 1;
  dirUp    = 2;
  dirDown  = 3;
  
  (* States *)
  stateEditor   = 0;
  stateTerminal = 1;

  (* Character Classes *)
  charOther       = 0; (*!FIXME Remove these constants *)
  charAlpha       = 1;
  charDigit       = 2;
  charMinusPlus   = 3;
  charQuote       = 4;
  charOpenBracket = 5;

  (* Token Classes *)
  tokenOther   = 0;
  tokenKeyword = 1;
  tokenNumber  = 2;
  tokenString  = 3;
  tokenComment = 4;

TYPE
  StrList = POINTER TO StrListDesc;
  StrListDesc = RECORD
    s: ARRAY 256 OF CHAR;
    next: StrList
  END;
  Fnames = ARRAY 32, 256 OF CHAR;

VAR
  progBuf: ARRAY 16300 OF CHAR; (* For interacting with a launched program *)
  inputBuf: ARRAY 16300 OF CHAR; (* Saves entered characters before Enter is pressed *)
  inputBufLen: INTEGER;
  programFinished: BOOLEAN;
  tempWindowed: BOOLEAN; (* True if editor is in windowed mode while program is running *)
  needWindowed: BOOLEAN;
  blockToggle: BOOLEAN; (* If true, ALT+ENTER will not toggle fullscreen *)
  sysModules: StrList;

  app: OV.App;

PROCEDURE IntToStr*(n: INTEGER; VAR s: ARRAY OF CHAR); (* !TODO move out *)
(* LEN(s) > 1 *)
VAR i, j: INTEGER; tmp: CHAR; neg: BOOLEAN;
BEGIN
  IF n = 0 THEN
    s[0] := '0'; i := 1
  ELSE i := 0; neg := n < 0; 
    IF neg THEN n := -n END;
    WHILE (n > 0) & (i < LEN(s) - 1) DO
      s[i] := CHR(ORD('0') + n MOD 10);
      n := n DIV 10; INC(i)
    END;
    IF neg & (i < LEN(s) - 1) THEN s[i] := '-'; INC(i) END
  END;
  s[i] := 0X; j := 0; DEC(i);
  WHILE j < i DO
    tmp := s[j]; s[j] := s[i]; s[i] := tmp;
    INC(j); DEC(i)
  END
END IntToStr;

PROCEDURE CountLines(s: ARRAY OF CHAR; width: INTEGER): INTEGER;
VAR i, x, lines: INTEGER;
BEGIN
  i := 0; x:= 0; lines := 1;
  WHILE s[i] # 0X DO
    IF s[i] = 0AX THEN
      INC(lines); x := 0
    ELSIF s[i] # 0DX THEN
      IF x = width - 1 THEN INC(lines); x := 0
      ELSE INC(x)
      END
    END;
    INC(i)
  END;
  RETURN lines
END CountLines;

PROCEDURE ShowErrors(s: ARRAY OF CHAR);
VAR lines, width, x0, x, y, i: INTEGER;
BEGIN
  width := T.charsX - 2;
  lines := CountLines(s, width);
  IF lines > 10 THEN lines := 10 END;
  i := 0; x0 := 1; x := x0;
  y := T.charsY - 2 - lines;
  WHILE (s[i] # 0X) & (y < T.charsY - 2) DO
    IF s[i] = 0AX THEN
      WHILE x < x0 + width DO (* Till end of line *)
        T.PutChar(x, y, ' ', 0, 3); INC(x)
      END;
      x := x0; INC(y)
    ELSIF s[i] # 0DX THEN
      T.PutChar(x, y, s[i], 0, 3);
      IF x = x0 + width - 1 THEN INC(y); x := x0
      ELSE INC(x)
      END
    END;
    INC(i)
  END;
  IF x > x0 THEN
    WHILE x < x0 + width DO
      T.PutChar(x, y, ' ', 0, 3); INC(x)
    END
  END;
  IF T.Draw() THEN G.Flip; G.Pause END (*!FIXME*)
END ShowErrors;

PROCEDURE StringsFindNext* (pattern, stringToSearch: ARRAY OF CHAR; startPos: INTEGER;
  VAR patternFound: BOOLEAN; VAR posOfPattern: INTEGER); (* !TODO move out *)
VAR patternPos: INTEGER;
BEGIN
  IF (startPos < Strings.Length (stringToSearch)) THEN
    patternPos := 0;
    LOOP
      IF (pattern[patternPos] = 0X) THEN     
        (* reached end of pattern *)
        patternFound := TRUE;
        posOfPattern := startPos - patternPos;
        EXIT
      ELSIF (stringToSearch[startPos] = 0X) THEN 
        (* end of string (but not of pattern) *)
        patternFound := FALSE;
        EXIT
      ELSIF (stringToSearch[startPos] = pattern[patternPos]) THEN  
        (* characters identic, compare next one *)
        INC (startPos); 
        INC (patternPos)
      ELSE                               
        (* difference found: reset indices and restart *)
        DEC(startPos, patternPos - 1);
        patternPos := 0
      END
    END
  ELSE patternFound := FALSE
  END
END StringsFindNext;

PROCEDURE FileNew(c: OV.Control);
VAR e: Editor.Editor;
  p, br: OV.Control;
  count: INTEGER;
BEGIN e := Editor.NewEditor(); 
  p := app.windows; br := p; count := 0;
  WHILE p # NIL DO INC(count);
    IF p.next = br THEN p := NIL ELSE p := p.next END
  END;
  IF app.windows # NIL THEN
    e.x := app.windows.x + 1; e.y := app.windows.y + 1;
    e.w := app.windows.w; e.h := app.windows.h;
    IF e.x + e.w >= T.charsX THEN e.w := T.charsX - e.x END;
    IF e.y + e.h >= T.charsY - 1 THEN e.h := T.charsY - e.y - 1 END;
    IF (e.w < 10) OR (e.h < 3) THEN
      e.x := 0; e.y := 1; e.w := T.charsX; e.h := T.charsY - 2
    END
  END;
  e.caption := 'NONAME??.Mod';
  e.caption[6] := CHR(ORD('0') + count DIV 10 MOD 10);
  e.caption[7] := CHR(ORD('0') + count MOD 10);
  OV.AddWindow(app, e)
END FileNew;

PROCEDURE DoOpenFile(filename: ARRAY OF CHAR);
VAR e: Editor.Editor; newWin: BOOLEAN;
BEGIN
  IF (app.windows # NIL) & (app.windows IS Editor.Editor) THEN
    e := app.windows(Editor.Editor)
  ELSE e := NIL
  END;
  newWin := (e = NIL) OR ~Editor.IsEmpty(e);
  IF newWin THEN e := Editor.NewEditor() END;
  IF e.text.LoadFromFile(filename) THEN
    e.caption := filename; e.filename := filename;
    IF newWin THEN OV.AddWindow(app, e) END
  END
END DoOpenFile;

PROCEDURE FocusOrOpenFile(filename: ARRAY OF CHAR);
VAR e, f: Editor.Editor;
BEGIN
  e := app.windows(Editor.Editor); f := e;
  WHILE (e # NIL) & (e.filename # filename) DO
    IF e.next = f THEN e := NIL ELSE e := e.next(Editor.Editor) END
  END;
  IF e = NIL THEN DoOpenFile(filename)
  ELSE app.windows := e; OV.SetFocus(app, e)
  END;
  OV.DrawApp(app)
END FocusOrOpenFile;

PROCEDURE ParseErrors(VAR s: ARRAY OF CHAR; filename: ARRAY OF CHAR);
VAR i, j, pos, st, len, skip: INTEGER; found: BOOLEAN;
BEGIN
  StringsFindNext(' pos ', s, 0, found, i);
  IF found THEN (* Read the position *)
    WHILE (s[i] # 0X) & ((s[i] < '0') OR (s[i] > '9')) DO INC(i) END;
    IF (s[i] >= '0') & (s[i] <= '9') THEN
      pos := 0;
      REPEAT pos := pos * 10 + ORD(s[i]) - ORD('0'); INC(i)
      UNTIL (s[i] < '0') OR (s[i] > '9');
      (* Skip spaces before 'err' *)
      WHILE s[i] = ' ' DO INC(i) END;
      IF s[i] = 'e' THEN (* Assume 'err' reached *)
        skip := 3; (* Skip 3 characters *)
        WHILE (skip > 0) & (s[i] # 0X) DO INC(i); DEC(skip) END;
        WHILE s[i] = ' ' DO INC(i) END; (* Skip spaces *)
        WHILE (s[i] >= '0') & (s[i] <= '9') DO INC(i) END; (* Skip numbers *)
        WHILE s[i] = ' ' DO INC(i) END; (* Skip spaces *)
        s[0] := ' '; j := 1;
        WHILE s[i] >= ' ' DO s[j] := s[i]; INC(i); INC(j) END;
        (* Remove trailing spaces *)
        WHILE (j > 0) & (s[j - 1] = ' ') DO DEC(j) END;
        s[j] := '.'; INC(j); s[j] := 0X;
        (* Capitalize first letter (0th is a space). *)
        IF (s[1] >= 'a') & (s[1] <= 'z') THEN s[1] := CAP(s[1]) END;
        FocusOrOpenFile(filename);
        app.windows(Editor.Editor).text.MoveToPos(pos);
        Editor.PrintText(app.windows(Editor.Editor));
        T.ResetCursorBlink (* !FIXME *)
      END
    END
  END
END ParseErrors;

PROCEDURE HandleMouseMotion;
VAR x, y, newX, newY: INTEGER;
BEGIN
  G.GetMousePos(x, y);
  newX := x DIV T.charW;  newY := y DIV T.charH;
  IF (newX # T.mouseX) OR (newY # T.mouseY) THEN T.MouseXY(newX, newY) END
END HandleMouseMotion;

PROCEDURE PollProgram;
VAR len, i: INTEGER;
    err: INTEGER;
    s, sN: ARRAY 120 OF CHAR;

  PROCEDURE WriteProgBuf;
  VAR ch: CHAR; i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < len DO
      ch := progBuf[i];
      IF ch = 0D0X THEN
        INC(i); ch := progBuf[i];
        IF ch = 081X THEN ch := CHR(240) (* Big Yo *)
        ELSE ch := CHR(ORD(ch) - 16)
        END
      ELSIF ch = 0D1X THEN
        INC(i); ch := CHR(ORD(progBuf[i]) + 96)
      ELSIF ch >= 080X THEN ch := '?'
      END;
      T.Write(ch); INC(i)
    END
  END WriteProgBuf;

  PROCEDURE Read(tillEnd: BOOLEAN);
  VAR loopLimit: INTEGER;
  BEGIN
    loopLimit := 5;
    REPEAT
      Term.ReadFromProcess(progBuf, len, LEN(progBuf));
      IF len > 0 THEN
        IF inputBufLen > 0 THEN
          FOR i := 0 TO inputBufLen - 1 DO T.Backspace END;
          inputBufLen := 0
        END;
        WriteProgBuf
      END;
      DEC(loopLimit)
    UNTIL (len <= 0) OR (loopLimit <= 0) & ~tillEnd
  END Read;
BEGIN
  IF ~programFinished THEN
    IF Term.ProcessFinished(err) THEN
      Read(TRUE); (* Read everything until pipe is empty *)
      programFinished := TRUE;
      IF tempWindowed THEN G.SwitchToFullscreen END;
      IF err = 0 THEN
        T.WriteString(' Press any key to return to IDE')
      ELSE
        s := ' Runtime error ';
        IntToStr(err, sN); Strings.Append(sN, s);
        T.WriteString(s)
      END
    ELSE
      Read(FALSE) (* Attempt several reads *)
    END
  END
END PollProgram;

PROCEDURE WriteToProcess(s: ARRAY OF CHAR; len: INTEGER);
VAR buf: ARRAY 2048 OF CHAR; i, bufLen: INTEGER; ch: CHAR;
BEGIN
  bufLen := 0; i := 0;
  WHILE i < len DO
    ch := s[i];
    IF ch < 80X THEN
      buf[bufLen] := ch; INC(bufLen)
    ELSIF ORD(ch) = 240 THEN (* Big cyrillic Yo *)
      buf[bufLen] := 0D0X; buf[bufLen + 1] := 81X;
      INC(bufLen, 2)
    ELSIF ORD(ch) < 224 THEN (* Before small cyrillic R *)
      buf[bufLen] := 0D0X;
      buf[bufLen + 1] := CHR(ORD(ch) - 128 + 090H);
      INC(bufLen, 2)
    ELSE
      buf[bufLen] := 0D1X;
      buf[bufLen + 1] := CHR(ORD(ch) - 224 + 080H);
      INC(bufLen, 2)
    END;
    INC(i)
  END;
  Term.WriteToProcess(buf, bufLen)
END WriteToProcess;

PROCEDURE HandleTerminalKeyDown(key: G.Key; VAR quit: BOOLEAN);
VAR code: INTEGER; ch: CHAR; buf: ARRAY 2 OF CHAR;
BEGIN
  IF programFinished THEN
    IF (key.code = G.kEnter) & (key.mod * G.mAlt # {}) THEN
      T.ToggleFullscreen
    ELSIF (key.code # G.kAlt) & (key.code # G.kAltGr) THEN quit := TRUE
    END
  ELSE
    CASE key.code OF
      G.kEnter, G.kEnterPad:
      IF key.mod * G.mAlt # {} THEN
        IF blockToggle THEN blockToggle := FALSE
        ELSE T.ToggleFullscreen; blockToggle := TRUE
        END
      ELSE T.Ln;
        WriteToProcess(inputBuf, inputBufLen);
        inputBufLen := 0; buf[0] := 0AX;
        Term.WriteToProcess(buf, 1)
      END
    | G.kBackspace:
      IF inputBufLen > 0 THEN
        DEC(inputBufLen); T.Backspace
      END
    | G.kPause:
      IF G.CtrlPressed() THEN
        programFinished := TRUE;
        quit := TRUE (* !FIXME Kill the process *)
      END
    ELSE
    END
  END
END HandleTerminalKeyDown;

PROCEDURE HandleTerminalTextInput(s: ARRAY OF CHAR; sym: INTEGER);
BEGIN
  IF (sym # 0) & (inputBufLen < LEN(inputBuf)) THEN
    inputBuf[inputBufLen] := CHR(sym); INC(inputBufLen);
    T.Write(CHR(sym))
  END
END HandleTerminalTextInput;

PROCEDURE RunTerminal;
VAR event: G.Event; quit: BOOLEAN;
BEGIN quit := FALSE;
  T.ClearScreen; T.GoToXY(0, 0);
  REPEAT
    G.WaitEvents(50);
    WHILE G.PollEvent(event) DO
      CASE event.type OF
        G.mouseMove: HandleMouseMotion
      | G.keyDown: HandleTerminalKeyDown(event.key, quit)
      | G.textInput: HandleTerminalTextInput(event.s, event.key.sym)
      ELSE
      END
    END;
    PollProgram;
    T.Act;
    IF T.Draw() THEN G.Flip ELSE G.RepeatFlip END
  UNTIL quit
END RunTerminal;

PROCEDURE IsSysModule(name: ARRAY OF CHAR): BOOLEAN;
VAR p: StrList;
BEGIN p := sysModules;
  WHILE (p # NIL) & (p.s # name) DO p := p.next END;
  RETURN p # NIL
END IsSysModule;

PROCEDURE ModuleExists(s: ARRAY OF CHAR): BOOLEAN;
VAR fname: ARRAY 120 OF CHAR;
  F: Files.File;
  exists: BOOLEAN;
BEGIN
  fname := 'Programs/'; Strings.Append(s, fname);
  Strings.Append('.Mod', fname);
  F := Files.Old(fname);
  exists := F # NIL;
  IF F # NIL THEN Files.Close(F) END;
RETURN exists END ModuleExists;

PROCEDURE RunCommand(filename: ARRAY OF CHAR;
    link, graph, main: BOOLEAN; list: StrList): BOOLEAN;
CONST bufLen = 20480;
VAR buf: ARRAY bufLen OF CHAR;
    p: StrList;
    len, err: INTEGER;
    command: ARRAY 32 OF CHAR;
    cmd: ARRAY 1024 OF CHAR;
    s, sN: ARRAY 80 OF CHAR;
    success: BOOLEAN;
BEGIN
  IF ~link THEN command := 'compile'
  ELSIF graph THEN command := 'link_graph'
  ELSE command := 'link_console'
  END;
  IF Config.isWindows THEN
    IF Term.SearchPath('cmd.exe', cmd) # 0 THEN
      Strings.Insert('"', 0, cmd);
      Strings.Append('" /C data\bin\', cmd);
      Strings.Append(command, cmd);
      Strings.Append('.bat ', cmd)
    ELSE T.PutString(0, T.charsY - 1, 'Could not find cmd.exe', 15, 4, 0)
    END
  ELSE (* Linux *)
    COPY('data/bin/', cmd); Strings.Append(command, cmd);
    Strings.Append('.sh ', cmd)
  END;
  Strings.Append(filename, cmd);
  IF main THEN Strings.Append(' -m', cmd)
  ELSIF link & (list # NIL) THEN
    p := list;
    WHILE p.next # NIL DO
      IF ModuleExists(p.s) THEN
        Strings.Append(' ', cmd); Strings.Append(p.s, cmd);
        Strings.Append('.o', cmd)
      END;
      p := p.next
    END
  END;
  success := (Term.RunProcess(cmd, buf, bufLen, len, err) # 0) &
             (err = 0);
  IF ~success THEN
    s := ' Command returned ';
    IntToStr(err, sN); Strings.Append(sN, s);
    Strings.Append(' exit status ', s);
    IF (len > 0) & (len < bufLen) THEN
      IF buf[len - 1] = 0AX THEN buf[len - 1] := 0X
      ELSE buf[len] := 0X
      END;
      ParseErrors(buf, filename)
    ELSIF link THEN buf := 'Linking failed.'
    ELSE buf := 'Compilation failed.'
    END;
    IF buf[0] = 0X THEN ShowErrors(s)
    ELSE ShowErrors(buf)
    END
  END;
  RETURN success
END RunCommand;

PROCEDURE Compile(filename: ARRAY OF CHAR; main: BOOLEAN): BOOLEAN;
BEGIN RETURN RunCommand(filename, FALSE, FALSE, main, NIL)
END Compile;

PROCEDURE Link(filename: ARRAY OF CHAR;
    graph: BOOLEAN; list: StrList): BOOLEAN;
BEGIN RETURN RunCommand(filename, TRUE, graph, FALSE, list)
END Link;

PROCEDURE ResetSysModules;
  PROCEDURE Add(s: ARRAY OF CHAR);
  VAR p: StrList;
  BEGIN NEW(p); p.s := s; p.next := sysModules; sysModules := p
  END Add;
BEGIN sysModules := NIL;
  Add('SYSTEM');  Add('Texts');    Add('Files');  Add('Strings');
  Add('In');      Add('Out');      Add('Math');   Add('MathL');
  Add('Modules'); Add('Platform'); Add('Oberon'); Add('Reals');
  Add('VT100');   Add('Graph');    Add('SDL2');   Add('Term')
END ResetSysModules;

PROCEDURE CompileAll(modules: StrList): BOOLEAN;
VAR s: ARRAY 256 OF CHAR;
  p, last: StrList;
  ok, graph: BOOLEAN;
BEGIN
  IF modules # NIL THEN
    ok := TRUE; p := modules; graph := FALSE;
    WHILE ok & (p.next # NIL) DO
      IF ModuleExists(p.s) THEN
        s := p.s; Strings.Append('.Mod', s);
        IF ~Compile(s, FALSE) THEN ok := FALSE END
      ELSIF IsSysModule(p.s) THEN
        IF p.s = 'Graph' THEN graph := TRUE END
      ELSE ok := FALSE
      END;
      p := p.next
    END;
    IF ok THEN
      IF ModuleExists(p.s) THEN
        s := p.s; Strings.Append('.Mod', s);
        IF ~Compile(s, TRUE) THEN ok := FALSE END
      END;
      IF ~Link(p.s, graph, modules) THEN ok := FALSE END
    END
  ELSE ok := FALSE
  END;
RETURN ok END CompileAll;

PROCEDURE RunProgram(prg: ARRAY OF CHAR);
VAR cmd: ARRAY 128 OF CHAR;
    x: INTEGER;
BEGIN
  (* Extract 'Prg' from 'Prg.Mod' or 'dir/Prg.Mod' *)
  x := Strings.Length(prg);
  WHILE (x > 0) & (prg[x] # '.') DO DEC(x) END;
  IF prg[x] = '.' THEN prg[x] := 0X END;
  WHILE (x >= 0) & (prg[x] # '/') DO DEC(x) END;
  IF x >= 0 THEN Strings.Delete(prg, 0, x + 1) END;

  (* Construct 'bin/MyProg' or 'bin\MyProg' *)
  IF Config.isWindows THEN COPY('bin\', cmd) ELSE COPY('bin/', cmd) END;
  Strings.Append(prg, cmd);

  IF ~Term.StartProcess(cmd) THEN
    T.PutString(0, T.charsY - 1, ' Program execution failed ', 15, 4, 0);
    IF T.Draw() THEN G.Flip; G.Pause END
  ELSE
    programFinished := FALSE;
    RunTerminal
  END
END RunProgram;

PROCEDURE OpenFileOkClick(c: OV.Control; filename: ARRAY OF CHAR);
BEGIN DoOpenFile(filename)
END OpenFileOkClick;

PROCEDURE DoSaveFile(c: OV.Control; filename: ARRAY OF CHAR);
VAR w: OV.Window; e: Editor.Editor;
BEGIN
  IF filename[0] # 0X THEN w := c.app.windows;
    IF (w # NIL) & (w IS Editor.Editor) THEN e := w(Editor.Editor);
      IF e.text.SaveToFile(filename) THEN
        COPY(filename, e.caption); e.filename := filename
      END
    END
  END
END DoSaveFile;

PROCEDURE FileOpen(c: OV.Control);
VAR w: Editor.FileDialog;
BEGIN
  w := Editor.NewFileDialog(Editor.open);
  w.onFileOk := OpenFileOkClick;
  OV.AddWindow(app, w)
END FileOpen;

PROCEDURE FileReload(c: OV.Control);
VAR e: Editor.Editor;
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor.Editor) THEN
    e := c.app.windows(Editor.Editor);
    IF e.filename[0] # 0X THEN
      IF e.text.LoadFromFile(e.filename) THEN (*!FIXME*) END
    END
  END
END FileReload;

PROCEDURE FileSaveAs(c: OV.Control);
VAR d: Editor.FileDialog;
  w: OV.Window; e: Editor.Editor;
BEGIN d := Editor.NewFileDialog(Editor.save);
  d.onFileOk := DoSaveFile;
  w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN e := w(Editor.Editor);
    IF e.filename[0] # 0X THEN
      OV.EditSetCaption(d.edtFilename, e.filename)
    END
  END;
  OV.AddWindow(app, d)
END FileSaveAs;

PROCEDURE FileSave(c: OV.Control);
VAR w: OV.Window;
BEGIN w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN
    IF w(Editor.Editor).filename[0] = 0X THEN FileSaveAs(c)
    ELSE DoSaveFile(c, w(Editor.Editor).filename)
    END
  END
END FileSave;

PROCEDURE SkipComment(VAR R: Files.Rider; VAR ch: CHAR; VAR s: ARRAY OF CHAR);
VAR last: CHAR;
BEGIN last := ch; Files.Read(R, ch);
  WHILE ~R.eof & ((last # '*') OR (ch # ')')) DO
    IF (last = '(') & (ch = '*') THEN SkipComment(R, ch, s) END;
    last := ch; Files.Read(R, ch)
  END;
  IF ~R.eof THEN Files.Read(R, ch) END;
  WHILE ~R.eof & (ch <= ' ') DO Files.Read(R, ch) END
END SkipComment;

PROCEDURE GetSym(VAR R: Files.Rider; VAR ch: CHAR; VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  WHILE ~R.eof & (ch <= ' ') DO Files.Read(R, ch) END;
  i := 0;
  IF ~R.eof THEN
    IF ch = '(' THEN
      Files.Read(R, ch);
      IF ch = '*' THEN Files.Read(R, ch); SkipComment(R, ch, s)
      ELSE s[i] := ch; INC(i)
      END
    END;
    IF ('A' <= CAP(ch)) & (CAP(ch) <= 'Z') THEN
      WHILE ~R.eof &
            (('A' <= CAP(ch)) & (CAP(ch) <= 'Z') OR
             ('0' <= ch) & (ch <= '9')) DO
        IF i < LEN(s) - 1 THEN s[i] := ch; INC(i) END;
        Files.Read(R, ch)
      END
    ELSE
      WHILE ~R.eof & (ch > ' ') &
            ~(('A' <= CAP(ch)) & (CAP(ch) <= 'Z') OR
              ('0' <= ch) & (ch <= '9')) DO
        IF i < LEN(s) - 1 THEN s[i] := ch; INC(i) END;
        Files.Read(R, ch)
      END
    END
  END;
  s[i] := 0X
END GetSym;

PROCEDURE GetImportedModules(modname: ARRAY OF CHAR): StrList;
VAR F: Files.File;
  R: Files.Rider;
  top, p: StrList;
  ch: CHAR;
  mod, s: ARRAY 256 OF CHAR;
  ok: BOOLEAN;
BEGIN NEW(top); top.next := NIL; p := top;
  s := 'Programs/'; Strings.Append(modname, s); Strings.Append('.Mod', s);
  F := Files.Old(s);
  IF F # NIL THEN
    Files.Set(R, F, 0); Files.Read(R, ch); GetSym(R, ch, s);
    ok := s = 'MODULE'; GetSym(R, ch, s); GetSym(R, ch, s); (*!FIXME check module name*)
    IF ok THEN
      ok := s = ';'; GetSym(R, ch, s);
      IF ok THEN
        ok := s = 'IMPORT'; GetSym(R, ch, s);
        WHILE ok & ('A' <= CAP(s[0])) & (CAP(s[0]) <= 'Z') DO
          mod := s;
          GetSym(R, ch, s);
          IF s = ':=' THEN GetSym(R, ch, s); mod := s; GetSym(R, ch, s) END;
          IF IsSysModule(mod) OR ModuleExists(mod) THEN
            NEW(p.next); p := p.next; p.next := NIL; p.s := mod
          END;
          IF s = ',' THEN GetSym(R, ch, s) ELSE ok := FALSE END
        END
      END
    END
  END;
RETURN top.next END GetImportedModules;

PROCEDURE DebugStrList(p: StrList);
BEGIN
  WHILE p # NIL DO
    Out.Char("'"); Out.String(p.s); Out.Char("'"); Out.Ln;
    p := p.next
  END
END DebugStrList;

PROCEDURE AddUniqueToList(what: StrList; VAR where: StrList);
VAR p, q, nextP: StrList;
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

PROCEDURE UsedModuleList(modname: ARRAY OF CHAR): StrList;
VAR res, list, list2, p: StrList;
BEGIN res := NIL;
  list := GetImportedModules(modname);
  p := list;
  WHILE p # NIL DO
    list2 := UsedModuleList(p.s);
    AddUniqueToList(list2, res);
    p := p.next
  END;
  NEW(p); p.s := modname; p.next := NIL; AddUniqueToList(p, res);
RETURN res END UsedModuleList;

PROCEDURE ImportsGraph(p: StrList): BOOLEAN;
BEGIN 
  WHILE (p # NIL) & (p.s # 'Graph') DO p := p.next END;
RETURN p # NIL END ImportsGraph;

(* "Module.Mod" -> "Module" *)
PROCEDURE GetModuleName(filename: ARRAY OF CHAR; VAR modname: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (filename[i] # 0X) & (filename[i] # '.') DO
    modname[i] := filename[i]; INC(i)
  END;
  modname[i] := 0X
END GetModuleName;

PROCEDURE OnBuild(c: OV.Control);
VAR w: OV.Window; graph: BOOLEAN;
  primaryFile, modname: ARRAY 256 OF CHAR;
  modules: StrList;
BEGIN w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN
    IF Editor.TextChanged(w(Editor.Editor)) THEN FileSave(c) END;
    IF w(Editor.Editor).filename[0] # 0X THEN
      COPY(w(Editor.Editor).filename, primaryFile);
      GetModuleName(primaryFile, modname);
      modules := UsedModuleList(modname);
      (*DebugStrList(modules);*)
      graph := ImportsGraph(modules);
      needWindowed := graph;
      IF CompileAll(modules) THEN
        tempWindowed := needWindowed & T.isFullscreen;
        IF tempWindowed THEN G.SwitchToWindowed END;
        RunProgram(w(Editor.Editor).filename)
      END
    END
  END
END OnBuild;

PROCEDURE HelpAbout(c: OV.Control);
BEGIN
  IF app.statusText[0] # 0X THEN OV.SetStatusText(app, '')
  ELSE OV.SetStatusText(app, 'Visit freeoberon.su')
  END
END HelpAbout;

PROCEDURE TileWindows*(c: OV.Control);
VAR W, E: OV.Control;
  count, cols, rows, i, col, x, y, w, h, w2, h2: INTEGER;
  aw, ah, dw, dh: INTEGER; (* Accumulator, delta *)
BEGIN E := app.windows; count := 0;
  IF E # NIL THEN W := E.next;
    WHILE W # NIL DO
      INC(count);
      IF W = E THEN W := NIL ELSE W := W.next END
    END;
    IF count < 4 THEN cols := 1
    ELSIF count < 9 THEN cols := 2
    ELSE cols := 3
    END;
    rows := count DIV cols; col := 1;
    x := 0; y := 1;
    w := T.charsX DIV cols; w2 := w;
    dw := T.charsX MOD cols;
    h := (T.charsY - 2) DIV rows;
    dh := (T.charsY - 2) MOD rows;
    IF h < 2 THEN h := 2; dh := 0 END;
    aw := dw; ah := 0;
    W := E.next; i := 0;
    WHILE W # NIL DO
      INC(ah, dh);
      IF ah < rows THEN h2 := h ELSE h2 := h + 1; DEC(ah, rows) END;
      OV.WindowResize(W, x, y, w2, h2);
      IF W = E THEN W := NIL ELSE W := W.next END;
      INC(y, h2); INC(i);
      IF (i = rows) & (col < cols) THEN (* New column *)
        i := 0; INC(col); INC(x, w2); y := 1; ah := 0;
        INC(aw, dw);
        IF aw < cols THEN w2 := w ELSE w2 := w + 1; DEC(aw, cols) END;
        IF col = cols THEN (* Last column *)
          rows := count - rows * (cols - 1);
          w := T.charsX - x;
          h := (T.charsY - 2) DIV rows;
          dh := (T.charsY - 2) MOD rows;
          IF h < 2 THEN h := 2; dh := 0 END
        END
      END
    END
  END
END TileWindows;

PROCEDURE CascadeWindows*(c: OV.Control);
VAR W, E: OV.Control;
  x, y, w, h: INTEGER;
BEGIN E := app.windows;
  x := 0; y := 1; w := T.charsX; h := T.charsY - 2;
  IF E # NIL THEN W := E.next;
    WHILE W # NIL DO
      OV.WindowResize(W, x, y, w, h);
      INC(x); INC(y); DEC(w); DEC(h);
      IF (w < 10) OR (h < 3) THEN
        x := 0; y := 1; w := T.charsX; h := T.charsY - 2
      END;
      IF W = E THEN W := NIL ELSE W := W.next END
    END
  END
END CascadeWindows;

PROCEDURE InitIDE;
VAR w: OV.Window;
    m, m2: OV.Menu;
BEGIN
  app := OV.NewApp();
  FileNew(app.menu);

  m := OV.NewMenu('&File', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&New', 'Shift+F3', OV.hShiftF3, FileNew));
  OV.Add(m, OV.NewMenu('&Open', 'F3', OV.hF3, FileOpen));
  OV.Add(m, OV.NewMenu('&Reload', '', 0, FileReload));
  OV.Add(m, OV.NewMenu('&Save', 'F2', OV.hF2, FileSave));
  OV.Add(m, OV.NewMenu('Save &as...', 'Shift+F2', OV.hShiftF2, FileSaveAs));
  (*OV.Add(m, OV.NewMenu('Save a&ll', '', 0, NIL));*)
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('E&xit', 'Alt+X', OV.hAltX, OV.QuitApp));
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Edit', '', 0, NIL);
  m2 := OV.NewMenu('&Undo', 'DelText', OV.hAltBackspace, NIL); m2.status := OV.disabled;
  OV.Add(m, m2);
  m2 := OV.NewMenu('&Redo', '', 0, NIL); m2.status := OV.disabled;
  OV.Add(m, m2);
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('Cu&t', 'Ctrl+X', OV.hCtrlX, Editor.EditCut));
  OV.Add(m, OV.NewMenu('&Copy', 'Ctrl+C', OV.hCtrlC, Editor.EditCopy));
  OV.Add(m, OV.NewMenu('&Paste', 'Ctrl+V', OV.hCtrlV, Editor.EditPaste));
  OV.Add(m, OV.NewMenu('C&lear', 'Ctrl+Del', OV.hCtrlDel, Editor.EditClear));
  OV.Add(m, OV.NewMenu('Select &All', 'Ctrl+A', OV.hCtrlA, Editor.EditSelectAll));
  OV.Add(m, OV.NewMenu('U&nselect', '', 0, Editor.EditUnselect));
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Search', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Find...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Replace...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Search again', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&Go to line number...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Find procedure...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Run', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Run', 'Ctrl+F9', OV.hCtrlF9, OnBuild));
  OV.Add(m, OV.NewMenu('Run &Directory...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('P&arameters...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Compile', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Compile', 'Alt+F9', OV.hAltF9, OnBuild));
  OV.Add(m, OV.NewMenu('&Make', 'Shift+F9', OV.hShiftF9, OnBuild));
  OV.Add(m, OV.NewMenu('Make && &Run', 'F9', OV.hF9, OnBuild));
  OV.Add(m, OV.NewMenu('&Build', '', 0, OnBuild));
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Debug', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Output', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Tools', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Messages', 'F11', OV.hF11, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&Calculator', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('Ascii &table', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Options', '', 0, NIL);
  OV.Add(m, OV.NewMenu('Mode&...', 'Normal', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Compiler...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Memory sizes...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Linker...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Directories...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Tools...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  m2 := OV.NewMenu('&Environment', '', 0, NIL);
  OV.Add(m2, OV.NewMenu('&Preferences...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('&Editor...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('Code&Complete...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('Code&Templates...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('&Desktop...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('Keyboard && &mouse...', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m2, OV.NewMenu('Learn &Keys', '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m, m2);
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&Open...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Save', 'fo.ini', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('Save &as...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Window', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Tile', '', 0, TileWindows));
  OV.Add(m, OV.NewMenu('C&ascade', '', 0, CascadeWindows));
  OV.Add(m, OV.NewMenu('Cl&ose all', '', 0, OV.CloseAllWindows));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&Size/Move', 'Ctrl+F5', OV.hCtrlF5, NIL));
  OV.Add(m, OV.NewMenu('&Zoom', 'F5', OV.hF5, OV.ZoomCurWindow));
  OV.Add(m, OV.NewMenu('&Next', 'F6', OV.hF6, OV.NextWindow));
  OV.Add(m, OV.NewMenu('&Previous', 'Shift+F6', OV.hShiftF6, OV.PrevWindow));
  OV.Add(m, OV.NewMenu('&Close', 'Alt+F3', OV.hAltF3, OV.CloseCurWindow));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&List...', 'Alt+0', OV.hAlt0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Refresh display', '', 0, OV.RefreshDisplay));
  OV.AddMenu(app, m);
  m := OV.NewMenu('&Help', '', 0, NIL);
  OV.Add(m, OV.NewMenu('&Contents', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Index', 'Shift+F1', OV.hShiftF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Topic search', 'Ctrl+F1', OV.hCtrlF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Previous topic', 'Alt+F1', OV.hAltF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Using help', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('&Files...', '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  OV.Add(m, OV.NewMenu('&About...', '', OV.hF1, HelpAbout));
  OV.AddMenu(app, m);

  OV.AddStatusbar(app, OV.NewQuickBtn('Help', 'F1', 0, HelpAbout));
  OV.AddStatusbar(app, OV.NewQuickBtn('Save', 'F2', 0, FileSave));
  OV.AddStatusbar(app, OV.NewQuickBtn('Open', 'F3', 0, FileOpen));
  OV.AddStatusbar(app, OV.NewQuickBtn('Compile & Run', 'F9', 0, OnBuild));
  OV.AddStatusbar(app, OV.NewQuickBtn('Local menu', 'Alt+F10', 0, NIL))
END InitIDE;

PROCEDURE OpenFiles(VAR fnames: Fnames);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(fnames)) & (fnames[i] # '') DO
    DoOpenFile(fnames[i]); INC(i)
  END;
  IF i # 0 THEN OV.NextWindow(app.windows) END
END OpenFiles;

PROCEDURE ParseArgs(VAR fs, sw: BOOLEAN;
    VAR fnames: Fnames);
VAR i, nofnames: INTEGER;
  s: ARRAY 256 OF CHAR;
BEGIN fs := TRUE; sw := FALSE; i := 0; nofnames := 0;
  WHILE i # Modules.ArgCount DO
    Modules.GetArg(i, s);
    IF s = '--window' THEN fs := FALSE
    ELSIF s = '--software' THEN sw := TRUE
    ELSIF nofnames < LEN(fnames) THEN
      COPY(s, fnames[nofnames]); INC(nofnames)
    END;
    INC(i)
  END;
  IF nofnames < LEN(fnames) THEN fnames[nofnames][0] := 0X END
END ParseArgs;

PROCEDURE Init(): BOOLEAN;
VAR success, fs, sw: BOOLEAN;
  fnames: Fnames;
BEGIN
  success := FALSE;
  ParseArgs(fs, sw, fnames);
  IF T.Init(fs, sw) THEN
    InitIDE;
    needWindowed := TRUE;
    blockToggle := FALSE;
    ResetSysModules;
    OpenFiles(fnames);
    success := TRUE
  ELSE Out.String('Terminal init failed.'); Out.Ln
  END;
  RETURN success
END Init;

BEGIN
  IF ~Init() THEN Out.String('Could not initialize.'); Out.Ln
  ELSE OV.RunApp(app)
  END;
  G.Close
END FreeOberon.
