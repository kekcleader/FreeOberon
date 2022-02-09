MODULE FreeOberon;
(* Copyright 2017-2022 Arthur Yefimov

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
IMPORT T := TermBox, Files, Args, Utf8,
       OV, Editor, Term, FoStrings, Config, Strings, Int, Out, Kernel;
CONST
  version* = '1.1.0-alpha.4';
  year = 2022;

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

  (* Defaults *)
  defW = 106;
  defH = 25;
  defLang = 'ru';

TYPE
  StrList = POINTER TO StrListDesc;
  StrListDesc = RECORD
    s: ARRAY 256 OF CHAR; (* Module name *)
    fname: ARRAY 256 OF CHAR; (* Filename of module source *)
    next: StrList
  END;
  Fnames = ARRAY 32, 256 OF CHAR;

VAR
  progBuf: ARRAY 16300 OF SHORTCHAR; (* For interacting with a launched program *)
  inputBuf: ARRAY 16300 OF CHAR; (* Saves entered chars before Enter pressed *)
  inputBufLen: INTEGER;
  programFinished: BOOLEAN;
  tempWindowed: BOOLEAN; (* TRUE if editor windowed while program is running *)
  needWindowed: BOOLEAN;
  sysModules: StrList;
  workDir: ARRAY 256 OF CHAR; (* Directory of main file of compiled program *)
  app: OV.App;

  curX, curY: INTEGER; (* Cursor position *)
  curFg, curBg: INTEGER; (* Current foreground and background of proc. Write *)
  terminalNeedRedraw: BOOLEAN; (* Used when a compiled program is running *)
  terminalMouseShown: BOOLEAN; (* Same *)

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
  END ;
RETURN lines END CountLines;

PROCEDURE ShowError(s: ARRAY OF CHAR);
BEGIN Editor.SetMsg(app.windows(Editor.Editor), s)
END ShowError;

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

PROCEDURE FileNew(c: OV.Control);
VAR e: Editor.Editor;
  p, br: OV.Control;
  count: INTEGER;
  tW, tH: INTEGER;
BEGIN e := Editor.NewEditor();
  p := app.windows; br := p; count := 0;
  WHILE p # NIL DO INC(count);
    IF p.next = br THEN p := NIL ELSE p := p.next END
  END;
  IF app.windows # NIL THEN
    e.x := app.windows.x + 1; e.y := app.windows.y + 1;
    e.w := app.windows.w; e.h := app.windows.h;
    T.Size(tW, tH);
    IF e.x + e.w >= tW THEN e.w := tW - e.x END;
    IF e.y + e.h >= tH - 1 THEN e.h := tH - e.y - 1 END;
    IF (e.w < 10) OR (e.h < 3) THEN
      e.x := 0; e.y := 1; e.w := tW; e.h := tH - 2
    END
  END;
  e.caption := 'NONAME??.Mod';
  e.caption[6] := CHR(ORD('0') + count DIV 10 MOD 10);
  e.caption[7] := CHR(ORD('0') + count MOD 10);
  OV.AddWindow(app, e)
END FileNew;

PROCEDURE FnameToCaption(IN fname: ARRAY OF CHAR; VAR caption: ARRAY OF CHAR);
BEGIN
  IF Strings.Pos(Editor.stdPath, fname, 0) = 0 THEN
    Strings.Extract(fname, Strings.Length(Editor.stdPath),
      LEN(caption), caption)
  ELSE caption := fname$
  END
END FnameToCaption;

PROCEDURE DoOpenFile(IN fname: ARRAY OF CHAR);
VAR e: Editor.Editor; newWin: BOOLEAN;
BEGIN
  IF (app.windows # NIL) & (app.windows IS Editor.Editor) THEN
    e := app.windows(Editor.Editor)
  ELSE e := NIL
  END;
  newWin := (e = NIL) OR ~Editor.IsEmpty(e);
  IF newWin THEN e := Editor.NewEditor() END;
  IF e.text.LoadFromFile(fname) THEN
    e.fname := fname$;
    FnameToCaption(fname, e.caption);
    IF newWin THEN OV.AddWindow(app, e) END
  ELSE (*!FIXME*)
  END
END DoOpenFile;

PROCEDURE FocusOrOpenFile(fname: ARRAY OF CHAR);
VAR e, f: Editor.Editor;
BEGIN
  e := app.windows(Editor.Editor); f := e;
  WHILE (e # NIL) & (e.fname # fname) DO
    IF e.next = f THEN e := NIL ELSE e := e.next(Editor.Editor) END
  END;
  IF e = NIL THEN DoOpenFile(fname)
  ELSE app.windows := e; OV.SetFocus(e)
  END;
  OV.DrawApp(app)
END FocusOrOpenFile;

PROCEDURE ReadInt(IN s: ARRAY OF CHAR; VAR i, res: INTEGER);
BEGIN res := 0;
  WHILE ('0' <= s[i]) & (s[i] <= '9') DO
    res := res * 10 + ORD(s[i]) - ORD('0');
    INC(i)
  END
END ReadInt;

PROCEDURE ScrollScreen;
VAR x, y, tW, tH: INTEGER;
  ch: CHAR;
  fg, bg: INTEGER;
BEGIN
  T.Size(tW, tH);
  FOR y := 0 TO tH - 2 DO
    FOR x := 0 TO tW - 1 DO
      T.GetCell(x, y + 1, ch, fg, bg);
      T.SetCell(x, y, ch, fg, bg)
    END
  END;
  FOR x := 0 TO tW - 1 DO
    T.SetCell(x, tH - 1, ' ', curFg, curBg)
  END;
  terminalNeedRedraw := TRUE
END ScrollScreen;

PROCEDURE Ln;
VAR tW, tH: INTEGER;
BEGIN T.Size(tW, tH); curX := 0;
  IF curY >= tH - 1 THEN ScrollScreen; curY := tH - 1
  ELSE INC(curY); terminalNeedRedraw := TRUE
  END;
END Ln;

PROCEDURE Write(ch: CHAR);
VAR tW, tH: INTEGER;
BEGIN
  IF ch = 0AX THEN Ln
  ELSIF ~Config.isWindows OR (ch # 0DX) THEN
    T.SetCell(curX, curY, ch, curFg, curBg);
    T.Size(tW, tH);
    IF curX >= tW - 1 THEN
      curX := 0;
      IF curY >= tH - 1 THEN ScrollScreen; curY := tH - 1 ELSE INC(curY) END
    ELSE INC(curX)
    END;
    terminalNeedRedraw := TRUE
  END;
  T.SetCursor(curX, curY)
END Write;

PROCEDURE WriteString(s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE s[i] # 0X DO Write(s[i]); INC(i) END
END WriteString;

PROCEDURE Backspace;
VAR tW, tH: INTEGER;
BEGIN
  IF curX = 0 THEN T.Size(tW, tH);
    IF curY # 0 THEN curX := tW - 1; DEC(curY) END
  ELSE DEC(curX);
  END;
  T.SetCell(curX, curY, ' ', curFg, curBg);
  T.SetCursor(curX, curY);
  terminalNeedRedraw := TRUE
END Backspace;

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

PROCEDURE PollProgram;
VAR len, i: INTEGER;
    err: INTEGER;
    s, sN: FoStrings.String;

  PROCEDURE WriteProgBuf;
  VAR ch: SHORTCHAR; i: INTEGER;
    z: ARRAY 16300 OF CHAR;
  BEGIN
    IF len < LEN(progBuf) THEN ch := progBuf[len]; progBuf[len] := 0X END;
    Utf8.Decode(progBuf, z);
    i := 0; WHILE z[i] # 0X DO Write(z[i]); INC(i) END;
    IF len < LEN(progBuf) THEN progBuf[len] := ch END
  END WriteProgBuf;

  PROCEDURE Read(tillEnd: BOOLEAN);
  VAR loopLimit: INTEGER;
  BEGIN
    loopLimit := 20;
    REPEAT
      Term.ReadFromProcess(progBuf, len, LEN(progBuf));
      IF len > 0 THEN
        IF inputBufLen > 0 THEN
          FOR i := 0 TO inputBufLen - 1 DO Backspace END;
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
      IF tempWindowed THEN T.SwitchToFS END;
      IF err = 0 THEN s := ' '; FoStrings.Append('pressAnyKeyToReturnToIde', s)
      ELSE s := ' '; FoStrings.Append('runtimeError', s);
        Strings.Append(' ', s); Int.Append(err, s)
      END;
      WriteString(s)
    ELSE
      Read(FALSE) (* Attempt several reads *)
    END
  END
END PollProgram;

PROCEDURE WriteToProcess(s: ARRAY OF CHAR; len: INTEGER);
VAR buf: ARRAY 2048 OF SHORTCHAR;
  q: ARRAY 5 OF SHORTCHAR;
  i, j, L, bufLen: INTEGER;
BEGIN bufLen := 0; i := 0;
  WHILE i < len DO
    Utf8.EncodeChar(s[i], q, L); j := 0;
    WHILE j # L DO buf[bufLen] := q[j]; INC(bufLen); INC(j) END;
    INC(i)
  END;
  Term.WriteToProcess(buf, bufLen)
END WriteToProcess;

PROCEDURE HandleTerminalTextInput(ch: CHAR);
BEGIN
  IF (ch # 0X) & (inputBufLen < LEN(inputBuf)) THEN
    inputBuf[inputBufLen] := ch; INC(inputBufLen); Write(ch)
  END
END HandleTerminalTextInput;

PROCEDURE KillProgram;
BEGIN
  programFinished := TRUE;
  (*!TODO Kill program *)
END KillProgram;

PROCEDURE HandleTerminalKeyDown(VAR E: T.Event; VAR quit: BOOLEAN);
VAR code: INTEGER; ch: CHAR; buf: ARRAY 2 OF SHORTCHAR;
BEGIN
  IF programFinished THEN
    quit := TRUE
  ELSE
    CASE E.key OF
      T.kEnter, T.kEnterPad:
      Ln;
      WriteToProcess(inputBuf, inputBufLen);
      inputBufLen := 0; buf[0] := 0AX;
      Term.WriteToProcess(buf, 1)
    | T.kBackspace:
      IF inputBufLen > 0 THEN
        DEC(inputBufLen); Backspace
      END
    | T.kPause:
      IF T.mCtrl IN E.mod THEN
        KillProgram;
        quit := TRUE
      END
    ELSE
      HandleTerminalTextInput(E.ch)
    END
  END
END HandleTerminalKeyDown;

PROCEDURE RunTerminal;
VAR E: T.Event; quit: BOOLEAN;
BEGIN quit := FALSE;
  T.Clear;
  terminalNeedRedraw := TRUE;
  terminalMouseShown := FALSE; T.HideMouse;
  REPEAT
    PollProgram;
    IF terminalNeedRedraw THEN T.Flush; terminalNeedRedraw := FALSE END;
    T.WaitEvent(E);
    IF E.type = T.timer THEN
    ELSIF E.type = T.key THEN HandleTerminalKeyDown(E, quit)
    ELSIF E.type = T.quit THEN KillProgram
    ELSIF E.type = T.mouse THEN
      IF E.button # 0 THEN T.ShowMouse END
    END;
    IF terminalNeedRedraw THEN T.Flush; terminalNeedRedraw := FALSE END
  UNTIL quit;
  IF ~terminalMouseShown THEN T.ShowMouse END
END RunTerminal;

PROCEDURE IsSysModule(IN name: ARRAY OF CHAR): BOOLEAN;
VAR p: StrList;
BEGIN p := sysModules;
  WHILE (p # NIL) & (p.s # name) DO p := p.next END ;
RETURN p # NIL END IsSysModule;

PROCEDURE ModuleExists(IN fname: ARRAY OF CHAR): BOOLEAN;
VAR F: Files.File;
  exists: BOOLEAN;
BEGIN F := Files.Old(fname); exists := F # NIL;
  IF F # NIL THEN Files.Close(F) END ;
RETURN exists END ModuleExists;

PROCEDURE SetWorkDir(IN fname: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := Strings.Length(fname);
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

PROCEDURE RunCommand(IN fname, mod: ARRAY OF CHAR;
    link, graph, main: BOOLEAN; list: StrList): BOOLEAN;
CONST bufLen = 20480;
VAR buf: ARRAY bufLen OF SHORTCHAR;
  e: Editor.Editor;
  p: StrList;
  len, err, line, col, error: INTEGER;
  command: ARRAY 32 OF CHAR;
  q: ARRAY 1024 OF SHORTCHAR;
  z: ARRAY 1024 OF CHAR;
  cmd: ARRAY 1024 OF CHAR;
  s, sN: ARRAY 80 OF CHAR;
  tW, tH: INTEGER;
  success: BOOLEAN;
BEGIN
  T.Size(tW, tH);
  IF ~link THEN command := 'compile'
  ELSIF graph THEN command := 'link_graph'
  ELSE command := 'link_console'
  END;
  IF Config.isWindows THEN
    IF Term.SearchPath('cmd.exe', q) # 0 THEN
      Utf8.Decode(q, cmd);
      Strings.Insert('"', 0, cmd);
      Strings.Append('" /C Data\bin\', cmd);
      Strings.Append(command, cmd);
      Strings.Append('.bat ', cmd)
    ELSE T.Print(0, tH - 1, -1, 'Could not find cmd.exe', 15, 4) (*!FIXME*)
    END
  ELSE (* Linux *)
    cmd := 'Data/bin/'; Strings.Append(command, cmd);
    Strings.Append('.sh ', cmd)
  END;

  IF Strings.Pos(Editor.stdPath, fname, 0) = 0 THEN
    Strings.Extract(fname, Strings.Length(Editor.stdPath), LEN(s), s)
  ELSE s := fname$
  END;
  Strings.Append(s, cmd);

  IF main THEN Strings.Append(' -m', cmd)
  ELSIF link & (list # NIL) THEN
    p := list;
    WHILE p.next # NIL DO
      IF ModuleExists(p.fname) THEN
        Strings.Append(' ', cmd); Strings.Append(p.s, cmd);
        Strings.Append('.c', cmd)
      END;
      p := p.next
    END
  END;
  Utf8.Encode(cmd, q);
  success := (Term.RunProcess(q, buf, bufLen, len, err) # 0) &
             (err = 0);
  IF ~success THEN
    s := ' Command returned '; Int.Append(err, s);
    Strings.Append(' exit status ', s);
    IF (len > 0) & (len < bufLen) THEN
      IF buf[len - 1] = 0AX THEN buf[len - 1] := 0X
      ELSE buf[len] := 0X
      END;
      Utf8.Decode(buf, z);
      ParseErrors(z, fname, line, col, error);
      FocusOrOpenFile(fname);
      e := app.windows(Editor.Editor);
      IF (col = 1) & (line # 1) THEN
        e.text.MoveToLineCol(line - 1, 256, e.h - 2)
      ELSE e.text.MoveToLineCol(line, col, e.h - 2)
      END;
      Editor.PrintText(app.windows(Editor.Editor))
    ELSIF link THEN FoStrings.GetErrorStr(422, z)
    ELSE FoStrings.GetErrorStr(421, z)
    END;
    IF z[0] = 0X THEN ShowError(s) ELSE ShowError(z) END
  END ;
RETURN success END RunCommand;

PROCEDURE Compile(IN fname, mod: ARRAY OF CHAR; main: BOOLEAN): BOOLEAN;
BEGIN RETURN RunCommand(fname, mod, FALSE, FALSE, main, NIL)
END Compile;

PROCEDURE Link(IN fname, mod: ARRAY OF CHAR;
    graph: BOOLEAN; list: StrList; VAR exename: ARRAY OF CHAR): BOOLEAN;
VAR ok: BOOLEAN;
  s: ARRAY 2048 OF CHAR;
  res: INTEGER;
BEGIN ok := RunCommand(fname, mod, TRUE, graph, FALSE, list);
  IF ok THEN (* Move executable file if workDir is non-standard *)
    s := mod$; IF Config.isWindows THEN Strings.Append('.exe', s) END;
    exename := 'bin/'; Strings.Append(s, exename);
    IF workDir # Editor.stdPath THEN
      Strings.Insert(workDir, 0, s);
      Files.Rename(exename, s, res);
      IF res = 0 THEN exename := s$ END
    END
  END ;
RETURN ok END Link;

PROCEDURE ResetSysModules;

  PROCEDURE Add(s: ARRAY OF CHAR);
  VAR p: StrList;
  BEGIN NEW(p); p.s := s$; p.fname[0] := 0X;
    p.next := sysModules; sysModules := p
  END Add;

BEGIN sysModules := NIL;
  Add('SYSTEM');   Add('Texts');    Add('Files');   Add('Strings');
  Add('In');       Add('Out');      Add('Math');    Add('MathL');
  Add('Modules');  Add('Platform'); Add('Oberon');  Add('Reals');
  Add('VT100');    Add('Graph');    Add('TermBox'); Add('Term');
  Add('Allegro5'); Add('Dir');      Add('Int');     Add('Random')
END ResetSysModules;

PROCEDURE CompileAll(modules: StrList; graph: BOOLEAN;
    VAR exename: ARRAY OF CHAR): BOOLEAN;
VAR p, last: StrList;
  ok: BOOLEAN;
BEGIN exename[0] := 0X;
  IF modules # NIL THEN
    ok := TRUE; p := modules;
    WHILE ok & (p.next # NIL) DO
      IF ModuleExists(p.fname) THEN
        IF ~Compile(p.fname, '', FALSE) THEN ok := FALSE END
      ELSIF ~IsSysModule(p.s) THEN ok := FALSE
      END;
      p := p.next
    END;
    IF ok THEN
      IF ModuleExists(p.fname) THEN
        IF ~Compile(p.fname, '', TRUE) THEN ok := FALSE END
      END;
      ok := ok & Link(p.fname, p.s, graph, modules, exename);
    END
  ELSE ok := FALSE
  END ;
RETURN ok END CompileAll;

PROCEDURE RunProgram(IN prg: ARRAY OF CHAR);
VAR dir, err: ARRAY 256 OF CHAR;
  s, d: ARRAY 2048 OF SHORTCHAR;
  i: INTEGER;
  tW, tH: INTEGER;
BEGIN dir := prg$; curX := 0; curY := 0; curFg := 7; curBg := 0;
  T.SetCursor(0, 0); T.Size(tW, tH);
  i := 0; WHILE dir[i] # 0X DO INC(i) END;
  WHILE (i # -1) & (dir[i] # '/') & (dir[i] # '\') DO DEC(i) END;
  INC(i); dir[i] := 0X; Utf8.Encode(prg, s); Utf8.Encode(dir, d);
  IF Term.StartProcessIn(s, d) THEN programFinished := FALSE; RunTerminal
  ELSE FoStrings.GetErrorStr(423, err); ShowError(err)
  END
END RunProgram;

PROCEDURE OpenFileOkClick(c: OV.Control; fname: ARRAY OF CHAR);
BEGIN DoOpenFile(fname)
END OpenFileOkClick;

PROCEDURE DoSaveFile(c: OV.Control; fname: ARRAY OF CHAR);
VAR w: OV.Window; e: Editor.Editor;
BEGIN
  IF fname[0] # 0X THEN w := c.app.windows;
    IF (w # NIL) & (w IS Editor.Editor) THEN e := w(Editor.Editor);
      IF e.text.SaveToFile(fname) THEN
        e.fname := fname$;
        FnameToCaption(fname, e.caption)
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
    IF e.fname[0] # 0X THEN
      IF e.text.LoadFromFile(e.fname) THEN (*!FIXME*) END
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
    IF e.fname[0] # 0X THEN Editor.FileDialogSetFname(d, e.fname) END
  END;
  OV.AddWindow(app, d)
END FileSaveAs;

PROCEDURE FileSave(c: OV.Control);
VAR w: OV.Window;
BEGIN w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN
    IF w(Editor.Editor).fname[0] = 0X THEN FileSaveAs(c)
    ELSE DoSaveFile(c, w(Editor.Editor).fname)
    END
  END
END FileSave;

PROCEDURE SearchFind(c: OV.Control);
VAR w, e: OV.Window;
BEGIN e := c.app.windows;
  IF (e # NIL) & (e IS Editor.Editor) THEN
    w := Editor.NewSearchDialog(e(Editor.Editor));
    OV.AddWindow(app, w)
  END
END SearchFind;

PROCEDURE SearchAgain(c: OV.Control);
VAR e: OV.Window;
BEGIN e := c.app.windows;
  IF (e # NIL) & (e IS Editor.Editor) THEN
    Editor.SearchNext(e(Editor.Editor))
  END
END SearchAgain;

PROCEDURE OptionsLanguage(c: OV.Control);
VAR w: OV.Window;
BEGIN
END OptionsLanguage;

PROCEDURE SkipComment(VAR R: Files.Rider; VAR ch: CHAR; VAR s: ARRAY OF CHAR);
VAR last: CHAR;
BEGIN last := ch; Files.ReadChar(R, ch);
  WHILE ~R.eof & ((last # '*') OR (ch # ')')) DO
    IF (last = '(') & (ch = '*') THEN SkipComment(R, ch, s) END;
    last := ch; Files.ReadChar(R, ch)
  END;
  IF ~R.eof THEN Files.ReadChar(R, ch) END;
  WHILE ~R.eof & (ch <= ' ') DO Files.ReadChar(R, ch) END
END SkipComment;

PROCEDURE ReadCh(VAR R: Files.Rider; VAR ch: CHAR; VAR line, col: INTEGER);
BEGIN Files.ReadChar(R, ch);
  IF ch = 0AX THEN INC(line); col := 1 ELSE INC(col) END
END ReadCh;

PROCEDURE GetSym(VAR R: Files.Rider; VAR ch: CHAR; VAR s: ARRAY OF CHAR;
    VAR line, col: INTEGER);
VAR i: INTEGER;
BEGIN
  WHILE ~R.eof & (ch <= ' ') DO ReadCh(R, ch, line, col) END;
  i := 0;
  IF ~R.eof THEN
    IF ch = '(' THEN
      ReadCh(R, ch, line, col);
      IF ch = '*' THEN ReadCh(R, ch, line, col); SkipComment(R, ch, s)
      ELSE s[i] := ch; INC(i)
      END
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

(** Returns true if the two module names are equal.
  modname is the identifier that comes after the keyword MODULE.
  filebase is the file name without the extension; on Windows it
  is allowed to be written in different case. *)
PROCEDURE EqualModuleNames(modname, filebase: ARRAY OF CHAR): BOOLEAN;
BEGIN IF Config.isWindows THEN Strings.Cap(modname); Strings.Cap(filebase) END;
RETURN modname = filebase END EqualModuleNames;

PROCEDURE GetImportedModules(IN fname, modname: ARRAY OF CHAR;
    VAR ok: BOOLEAN; VAR line, col: INTEGER): StrList;
VAR F: Files.File;
  R: Files.Rider;
  top, p: StrList;
  ch: CHAR;
  mod, s, fname2: ARRAY 256 OF CHAR;
  exit: BOOLEAN;
BEGIN ok := FALSE; NEW(top); top.next := NIL; p := top;
  F := Files.Old(fname);
  IF F # NIL THEN
    Files.Set(R, F, 0); Files.ReadChar(R, ch);
    line := 1; col := 1; GetSym(R, ch, s, line, col);
    IF s = 'MODULE' THEN GetSym(R, ch, s, line, col);
      IF EqualModuleNames(modname, s) THEN
        GetSym(R, ch, s, line, col);
        IF s = ';' THEN GetSym(R, ch, s, line, col); ok := TRUE;
          IF s = 'IMPORT' THEN GetSym(R, ch, s, line, col); exit := FALSE;
            WHILE ~exit & ('A' <= CAP(s[0])) & (CAP(s[0]) <= 'Z') DO
              mod := s; GetSym(R, ch, s, line, col); fname2[0] := 0X;
              IF s = ':=' THEN GetSym(R, ch, s, line, col);
                mod := s; GetSym(R, ch, s, line, col)
              END;
              IF IsSysModule(mod) OR FindModule(mod, fname2) THEN
                NEW(p.next); p := p.next; p.next := NIL;
                p.s := mod$; p.fname := fname2$
              END;
              IF s = ',' THEN GetSym(R, ch, s, line, col)
              ELSE exit := FALSE
              END
            END
          END
        END
      END
    END
  END ;
RETURN top.next END GetImportedModules;

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

PROCEDURE UsedModuleList(IN modname, fname: ARRAY OF CHAR;
    VAR ok: BOOLEAN; VAR errFname: ARRAY OF CHAR;
    VAR errLine, errCol: INTEGER): StrList;
VAR res, list, list2, p: StrList;
BEGIN res := NIL; ok := TRUE;
  IF ~IsSysModule(modname) THEN
    list := GetImportedModules(fname, modname, ok, errLine, errCol); p := list;
    IF ok THEN
      WHILE ok & (p # NIL) DO
        list2 := UsedModuleList(p.s, p.fname, ok, errFname, errLine, errCol);
        AddUniqueToList(list2, res);
        p := p.next
      END
    ELSE Strings.Copy(fname, errFname)
    END
  END;
  IF ok THEN
    NEW(p); p.s := modname$; p.fname := fname$; p.next := NIL;
    AddUniqueToList(p, res)
  END ;
RETURN res END UsedModuleList;

PROCEDURE ImportsGraph(p: StrList): BOOLEAN;
BEGIN WHILE (p # NIL) & (p.s # 'Graph') DO p := p.next END ;
RETURN p # NIL END ImportsGraph;

(* "Module.Mod" -> "Module" *)
PROCEDURE GetModuleName(IN fname: ARRAY OF CHAR; VAR modname: ARRAY OF CHAR);
VAR i, j: INTEGER;
BEGIN i := 0; j := 0;
  WHILE fname[i] # 0X DO INC(i) END; DEC(i);
  WHILE (i # -1) & (fname[i] # '/') DO DEC(i) END; INC(i);
  WHILE (fname[i] # 0X) & (fname[i] # '.') DO
    modname[j] := fname[i]; INC(i); INC(j)
  END;
  modname[j] := 0X
END GetModuleName;

PROCEDURE OnBuild(c: OV.Control);
VAR w: OV.Window;
  graph, ok: BOOLEAN;
  mainFname, modname, exename, errFname, s: ARRAY 256 OF CHAR;
  errLine, errCol: INTEGER;
  modules: StrList;
  e: Editor.Editor;
BEGIN w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN
    IF Editor.TextChanged(w(Editor.Editor)) THEN FileSave(c) END;
    IF w(Editor.Editor).fname[0] # 0X THEN
      mainFname := w(Editor.Editor).fname$;
      SetWorkDir(mainFname);
      GetModuleName(mainFname, modname);
      modules := UsedModuleList(modname, mainFname, ok,
        errFname, errLine, errCol);
      IF ok THEN
        graph := ImportsGraph(modules);
        needWindowed := graph;
        IF CompileAll(modules, graph, exename) THEN
          tempWindowed := needWindowed & T.IsFS();
          tempWindowed := FALSE; (*!FIXME Test on Linux and then remove tempWindowed alltogeter*)
          IF tempWindowed THEN T.SwitchToWindow END;
          RunProgram(exename)
        END
      ELSE
        FocusOrOpenFile(errFname);
        e := app.windows(Editor.Editor);
        e.text.MoveToLineCol(errLine, errCol, e.h - 2);
        FoStrings.MakeErrorStr(401(*file contains wrong module name*), s);
        ShowError(s)
      END
    END
  END
END OnBuild;

PROCEDURE HelpAbout(c: OV.Control);
CONST W = 37; H = 13;
VAR w: OV.Window; L: OV.Label; b: OV.Button;
  s: FoStrings.String;
  Y: INTEGER;
  tW, tH: INTEGER;
BEGIN w := OV.NewWindow(); w.modal := TRUE;
  FoStrings.Get('titleAbout', w.caption);
  T.Size(tW, tH);
  w.do.resize(w, (tW - W) DIV 2, (tH - H) DIV 2, W, H);
  Y := 2;

  FoStrings.Get('titleFreeOberon', s);
  L := OV.NewLabel(s); L.align := OV.center;
  L.do.resize(L, 1, Y, W - 2, 1); OV.Add(w, L); INC(Y, 2);

  FoStrings.Get('version', s); Strings.Append(' ', s);
  Strings.Append(version, s);
  L := OV.NewLabel(s); L.align := OV.center;
  L.do.resize(L, 1, Y, W - 2, 1); OV.Add(w, L); INC(Y, 2);

  FoStrings.Get('copyright', s); Strings.Append(' 2017-', s);
  Int.Append(year, s); Strings.Append(' ', s);
  FoStrings.Append('copyrightBy', s);
  
  L := OV.NewLabel(s); L.align := OV.center;
  L.do.resize(L, 1, Y, W - 2, 1); OV.Add(w, L); INC(Y, 2);

  FoStrings.Get('authorName', s); Strings.Append(', free.oberon.org', s);
  L := OV.NewLabel(s); L.align := OV.center;
  L.do.resize(L, 1, Y, W - 2, 1); OV.Add(w, L); INC(Y, 2);

  FoStrings.Get('btnOk', s);
  b := OV.NewButton(s); b.default := TRUE;
  b.do.resize(b, (W - 8) DIV 2, Y, 8, 1); OV.Add(w, b); INC(Y, 2);
  b.onClick := OV.CloseCurWindow;

  OV.AddWindow(app, w);
  OV.SetFocus(b)
END HelpAbout;

PROCEDURE TileWindows*(c: OV.Control);
VAR W, E: OV.Control;
  count, cols, rows, i, col, x, y, w, h, w2, h2: INTEGER;
  aw, ah, dw, dh: INTEGER; (* Accumulator, delta *)
  tW, tH: INTEGER;
BEGIN E := app.windows; count := 0;
  T.Size(tW, tH);
  IF E # NIL THEN W := E.next;
    WHILE W # NIL DO
      INC(count);
      IF W = E THEN W := NIL ELSE W := W.next END
    END;
    IF count < 4 THEN rows := 1
    ELSIF count < 9 THEN rows := 2
    ELSE rows := 3
    END;
    cols := count DIV rows; col := 1;

    x := 0; y := 1;
    w := tW DIV cols; w2 := w;
    dw := tW MOD cols;
    h := (tH - 2) DIV rows;
    dh := (tH - 2) MOD rows;
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
          w := tW - x;
          h := (tH - 2) DIV rows;
          dh := (tH - 2) MOD rows;
          IF h < 2 THEN h := 2; dh := 0 END
        END
      END
    END
  END
END TileWindows;

PROCEDURE CascadeWindows*(c: OV.Control);
VAR W, E: OV.Control;
  x, y, w, h: INTEGER;
  tW, tH: INTEGER;
BEGIN E := app.windows;
  T.Size(tW, tH);
  x := 0; y := 1; w := tW; h := tH - 2;
  IF E # NIL THEN W := E.next;
    WHILE W # NIL DO
      OV.WindowResize(W, x, y, w, h);
      INC(x); INC(y); DEC(w); DEC(h);
      IF (w < 10) OR (h < 3) THEN
        x := 0; y := 1; w := tW; h := tH - 2
      END;
      IF W = E THEN W := NIL ELSE W := W.next END
    END
  END
END CascadeWindows;

PROCEDURE InitIDE;
VAR w: OV.Window;
  m, m2: OV.Menu;
  s, q: FoStrings.String;
BEGIN
  app := OV.NewApp();
  FileNew(app.menu);

  FoStrings.Get('menuFile', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuNew', s);
  OV.Add(m, OV.NewMenu(s, 'Shift+F3', OV.hShiftF3, FileNew));
  FoStrings.Get('menuOpen', s);
  OV.Add(m, OV.NewMenu(s, 'F3', OV.hF3, FileOpen));
  FoStrings.Get('menuReload', s);
  OV.Add(m, OV.NewMenu(s, '', 0, FileReload));
  FoStrings.Get('menuSave', s);
  OV.Add(m, OV.NewMenu(s, 'F2', OV.hF2, FileSave));
  FoStrings.Get('menuSaveAs', s);
  OV.Add(m, OV.NewMenu(s, 'Shift+F2', OV.hShiftF2, FileSaveAs));
  (*FoStrings.Get('menuSaveAll', s);*)
  (*OV.Add(m, OV.NewMenu(s, '', 0, NIL));*)
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuExit', s);
  OV.Add(m, OV.NewMenu(s, 'Alt+X', OV.hAltX, OV.QuitApp));
  OV.AddMenu(app, m);
  FoStrings.Get('menuEdit', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuUndo', s);
  FoStrings.Get('actionDelText', q);
  m2 := OV.NewMenu(s, q, OV.hAltBackspace, NIL); m2.status := OV.disabled;
  OV.Add(m, m2);
  FoStrings.Get('menuRedo', s);
  m2 := OV.NewMenu(s, '', 0, NIL); m2.status := OV.disabled;
  OV.Add(m, m2);
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuCut', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+X', OV.hCtrlX, Editor.EditCut));
  FoStrings.Get('menuCopy', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+C', OV.hCtrlC, Editor.EditCopy));
  FoStrings.Get('menuPaste', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+V', OV.hCtrlV, Editor.EditPaste));
  FoStrings.Get('menuClear', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+Del', OV.hCtrlDel, Editor.EditClear));
  FoStrings.Get('menuSelectAll', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+A', OV.hCtrlA, Editor.EditSelectAll));
  FoStrings.Get('menuUnselect', s);
  OV.Add(m, OV.NewMenu(s, '', 0, Editor.EditUnselect));
  OV.AddMenu(app, m);
  FoStrings.Get('menuSearch', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuFind', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+F', OV.hCtrlF, SearchFind));
  FoStrings.Get('menuReplace', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuSearchAgain', s);
  OV.Add(m, OV.NewMenu(s, 'F12', OV.hF12, SearchAgain));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuGoToLineNumber', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuFindProcedure', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  FoStrings.Get('menuRun', s);
  m := OV.NewMenu(s, '', 0, NIL);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+F9', OV.hCtrlF9, OnBuild));
  FoStrings.Get('menuRunDirectory', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuParameters', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  FoStrings.Get('menuCompile', s);
  m := OV.NewMenu(s, '', 0, NIL);
  OV.Add(m, OV.NewMenu(s, 'Alt+F9', OV.hAltF9, OnBuild));
  FoStrings.Get('menuMake', s);
  OV.Add(m, OV.NewMenu(s, 'Shift+F9', OV.hShiftF9, OnBuild));
  FoStrings.Get('menuMakeAndRun', s);
  OV.Add(m, OV.NewMenu(s, 'F9', OV.hF9, OnBuild));
  FoStrings.Get('menuBuild', s);
  OV.Add(m, OV.NewMenu(s, '', 0, OnBuild));
  OV.AddMenu(app, m);
  FoStrings.Get('menuDebug', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuOutput', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  FoStrings.Get('menuTools', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuMessages', s);
  OV.Add(m, OV.NewMenu(s, 'F11', OV.hF11, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuCalculator', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuAsciiTable', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  FoStrings.Get('menuOptions', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuMode', s);
  FoStrings.Get('menuNormalMode', q);
  OV.Add(m, OV.NewMenu(s, q, 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuLanguage', s);
  OV.Add(m, OV.NewMenu(s, '', 0, OptionsLanguage));
  FoStrings.Get('menuCompiler', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuMemorySizes', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuLinker', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuDirectories', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuTools', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuEnvironment', s);
  m2 := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuPreferences', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuEditor', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuCodeComplete', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuCodeTemplates', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuDesktop', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuKeyboardAndMouse', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  FoStrings.Get('menuLearnKeys', s);
  OV.Add(m2, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m2.children.prev.status := OV.disabled;
  OV.Add(m, m2);
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuOpenOptions', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuSaveOptions', s);
  OV.Add(m, OV.NewMenu(s, 'fo.ini', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuSaveOptionsAs', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.AddMenu(app, m);
  FoStrings.Get('menuWindow', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuTile', s);
  OV.Add(m, OV.NewMenu(s, '', 0, TileWindows));
  FoStrings.Get('menuCascade', s);
  OV.Add(m, OV.NewMenu(s, '', 0, CascadeWindows));
  FoStrings.Get('menuCloseAll', s);
  OV.Add(m, OV.NewMenu(s, '', 0, OV.CloseAllWindows));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuSizeMove', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+F5', OV.hCtrlF5, NIL));
  FoStrings.Get('menuZoom', s);
  OV.Add(m, OV.NewMenu(s, 'F5', OV.hF5, OV.ZoomCurWindow));
  FoStrings.Get('menuNextWindow', s);
  OV.Add(m, OV.NewMenu(s, 'F6', OV.hF6, OV.NextWindow));
  FoStrings.Get('menuPreviousWindow', s);
  OV.Add(m, OV.NewMenu(s, 'Shift+F6', OV.hShiftF6, OV.PrevWindow));
  FoStrings.Get('menuCloseWindow', s);
  OV.Add(m, OV.NewMenu(s, 'Alt+F3', OV.hAltF3, OV.CloseCurWindow));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuListWindows', s);
  OV.Add(m, OV.NewMenu(s, 'Alt+0', OV.hAlt0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuRefreshDisplay', s);
  OV.Add(m, OV.NewMenu(s, '', 0, OV.RefreshDisplay));
  OV.AddMenu(app, m);
  FoStrings.Get('menuHelp', s);
  m := OV.NewMenu(s, '', 0, NIL);
  FoStrings.Get('menuContents', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuIndex', s);
  OV.Add(m, OV.NewMenu(s, 'Shift+F1', OV.hShiftF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuTopicSearch', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+F1', OV.hCtrlF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuPreviousTopic', s);
  OV.Add(m, OV.NewMenu(s, 'Alt+F1', OV.hAltF1, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuUsingHelp', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  FoStrings.Get('menuHelpFiles', s);
  OV.Add(m, OV.NewMenu(s, '', 0, NIL));
  (*!TODO*) m.children.prev.status := OV.disabled;
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuAbout', s);
  OV.Add(m, OV.NewMenu(s, '', OV.hF1, HelpAbout));
  OV.AddMenu(app, m);

  FoStrings.Get('btnHelp', s);
  OV.AddStatusbar(app, OV.NewQuickBtn(s, 'F1', 0, HelpAbout));
  FoStrings.Get('btnSave', s);
  OV.AddStatusbar(app, OV.NewQuickBtn(s, 'F2', 0, FileSave));
  FoStrings.Get('btnOpen', s);
  OV.AddStatusbar(app, OV.NewQuickBtn(s, 'F3', 0, FileOpen));
  FoStrings.Get('btnCompileAndRun', s);
  OV.AddStatusbar(app, OV.NewQuickBtn(s, 'F9', 0, OnBuild));
  FoStrings.Get('btnLocalMenu', s);
  OV.AddStatusbar(app, OV.NewQuickBtn(s, 'Alt+F10', 0, NIL))
END InitIDE;

PROCEDURE OpenFiles(VAR fnames: Fnames);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(fnames)) & (fnames[i] # '') DO
    DoOpenFile(fnames[i]); INC(i)
  END;
  IF i # 0 THEN OV.NextWindow(app.windows) END
END OpenFiles;

PROCEDURE ParseFileNameArg(VAR s: ARRAY OF CHAR);
VAR L: INTEGER;
  found: BOOLEAN;
BEGIN
  (* Replace all \ with / and set L to length of s *)
  L := 0; found := FALSE;
  WHILE s[L] # 0X DO
    IF (s[L] = '\') OR (s[L] = '/') THEN s[L] := '/'; found := TRUE END;
    INC(L)
  END;

  IF ~found THEN
    IF (L < 4) OR (Strings.Pos('.Mod', s, L - 4) = -1) THEN
      Strings.Append('.Mod', s)
    END;
    Strings.Insert(Editor.stdPath, 0, s);
  END
END ParseFileNameArg;

PROCEDURE ParseSize(IN s: ARRAY OF CHAR; VAR w, h: INTEGER);
VAR i: INTEGER;
  x: ARRAY 30 OF CHAR;
BEGIN i := 0; w := 0; h := 0;
  WHILE (s[i] # 0X) & (s[i] # 'x') DO INC(i) END;
  Strings.Extract(s, 0, i, x); w := Int.Val(x);
  Strings.Extract(s, i + 1, 30, x); h := Int.Val(x)
END ParseSize;

PROCEDURE ParseArgs(VAR fs, sw: BOOLEAN; VAR w, h: INTEGER;
    VAR lang: ARRAY OF CHAR; VAR fnames: Fnames);
VAR i, nofnames: INTEGER;
  s: ARRAY 2048 OF CHAR;
  q: ARRAY 2048 OF SHORTCHAR;
BEGIN fs := TRUE; sw := FALSE; i := 1; nofnames := 0; w := defW; h := defH;
  lang := defLang;
  WHILE i <= Args.Count DO Args.Get(i, s);
    IF s = '--window' THEN fs := FALSE
    ELSIF s = '--software' THEN sw := TRUE
    ELSIF s = '--size' THEN
      IF i # Args.Count THEN
        INC(i); Args.Get(i, s); ParseSize(s, w, h)
      END
    ELSIF s = '--lang' THEN
      IF i # Args.Count THEN
        INC(i); Args.Get(i, lang);
        IF ~FoStrings.LangExists(lang) THEN Out.String('Language "');
          Out.String(lang); Out.String('" does not exist.'); Out.Ln;
          lang := defLang
        END
      END
    ELSIF nofnames < LEN(fnames) THEN
      ParseFileNameArg(s);
      fnames[nofnames] := s$;
      INC(nofnames)
    ELSE Out.String('Too many files.'); Out.Ln
    END;
    INC(i)
  END;
  IF nofnames < LEN(fnames) THEN fnames[nofnames][0] := 0X END
END ParseArgs;

PROCEDURE Init(): BOOLEAN;
VAR success, fs, sw: BOOLEAN;
  w, h: INTEGER;
  lang: ARRAY 6 OF CHAR;
  s: FoStrings.String;
  fnames: Fnames;
  opt: SET;
BEGIN
  success := FALSE;
  ParseArgs(fs, sw, w, h, lang, fnames);
  opt := {T.resizable, T.center};
  IF fs THEN INCL(opt, T.fullscreen) ELSE INCL(opt, T.window) END;
  T.Settings(w, h, opt);
  FoStrings.SetLang(lang);
  FoStrings.Get('titleFreeOberon', s);
  T.SetTitle(s);
  T.Init;
  IF T.Done THEN
    InitIDE;
    needWindowed := TRUE;
    ResetSysModules;
    OpenFiles(fnames);
    success := TRUE
  ELSE Out.String('Terminal init failed.'); Out.Ln
  END ;
RETURN success END Init;

BEGIN
  IF ~Init() THEN Out.String('Could not initialize.'); Out.Ln
  ELSE OV.RunApp(app)
  END;
  T.Close
END FreeOberon.
