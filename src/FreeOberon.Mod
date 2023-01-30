MODULE FreeOberon;
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
IMPORT T := TermBox, Files, Args, Utf8, Builder, Env, Debug, Graph,
       OV, Editor, Term, FoStrings, Config, Strings, Int, Out, Kernel;
(** Free Oberon IDE and Compiler. Part of Free Oberon IDE internal code *)
CONST
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
  defLang = 'en';

TYPE
  Fnames = ARRAY 32, 256 OF CHAR;

  LanguageDialog* = POINTER TO LanguageDialogDesc;
  LanguageDialogDesc = RECORD(OV.WindowDesc)
    btnRu*, btnEn*: OV.Button
  END;

VAR
  progBuf: ARRAY 16300 OF SHORTCHAR; (* For interaction with running program *)
  inputBuf: ARRAY 16300 OF CHAR; (* Holds entered chars before Enter pressed *)
  inputBufLen: INTEGER;
  programFinished: BOOLEAN;
  lastFileDialogDir: ARRAY 256 OF CHAR; (* Directory path for file dialog *)
  app: OV.App;

  curX, curY: INTEGER; (* Text cursor position *)
  curFg, curBg: INTEGER; (* Current foreground and background of proc. Write *)
  terminalNeedRedraw: BOOLEAN; (* Used when a compiled program is running *)
  terminalMouseShown: BOOLEAN; (* Same *)

  lastW, lastH: INTEGER; (* Last screen size *)

(* Language Dialog *)

PROCEDURE LanguageButtonClick*(c: OV.Control);
VAR lang: ARRAY 10 OF CHAR;
BEGIN
  IF c.caption = 'English' THEN lang := 'en' ELSE lang := 'ru' END;
  IF lang # FoStrings.lang THEN FoStrings.SetLang(lang) END;
  OV.CloseCurWindow(c)
END LanguageButtonClick;

PROCEDURE InitLanguageDialog*(c: LanguageDialog);
VAR lbl: OV.Label;
  s: FoStrings.String;
BEGIN OV.InitWindow(c);
  c.modal := TRUE; c.w := 37; c.h := 8; OV.CenterWindow(c);

  FoStrings.Get('labelChooseLanguage', s);
  lbl := OV.NewLabel(s);
  lbl.align := OV.center;
  lbl.do.resize(lbl, 1, 2, c.w - 2, 1);
  OV.Add(c, lbl);

  (* Ru button *)
  c.btnRu := OV.NewButton('Русский');
  c.btnRu.onClick := LanguageButtonClick;
  c.btnRu.do.resize(c.btnRu, 5, 4, 11, 1);
  OV.Add(c, c.btnRu);

  (* En button *)
  c.btnEn := OV.NewButton('English');
  c.btnEn.onClick := LanguageButtonClick;
  c.btnEn.do.resize(c.btnEn, 20, 4, 11, 1);
  OV.Add(c, c.btnEn)
END InitLanguageDialog;

PROCEDURE NewLanguageDialog*(): LanguageDialog;
VAR c: LanguageDialog;
BEGIN NEW(c); InitLanguageDialog(c) ;
RETURN c END NewLanguageDialog;

(* General *)

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
  IF Strings.Pos(Config.stdPath, fname, 0) = 0 THEN
    Strings.Extract(fname, Strings.Length(Config.stdPath),
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
  IF e = NIL THEN DoOpenFile(fname) ELSE app.windows := e; OV.SetFocus(e) END;
  OV.DrawApp(app)
END FocusOrOpenFile;

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

(** Puts in dir part of string s, before the last '/'.
    If there is no '/', dir is ''. *)
PROCEDURE DirName(IN s: ARRAY OF CHAR; OUT dir: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0; WHILE s[i] # 0X DO INC(i) END;
  WHILE (i >= 0) & (s[i] # '/') DO DEC(i) END;
  dir[i + 1] := 0X;
  WHILE i >= 0 DO dir[i] := s[i]; DEC(i) END
END DirName;

PROCEDURE OpenFileOkClick(c: OV.Control; fname: ARRAY OF CHAR);
BEGIN
  DirName(fname, lastFileDialogDir);
  DoOpenFile(fname)
END OpenFileOkClick;

PROCEDURE DoSaveFile(c: OV.Control; fname: ARRAY OF CHAR);
VAR w: OV.Window; e: Editor.Editor;
BEGIN
  Debug.StrVal('DoSaveFile fname = ', fname);
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
  w := Editor.NewFileDialog(Editor.open, lastFileDialogDir);
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
BEGIN d := Editor.NewFileDialog(Editor.save, lastFileDialogDir);
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
  w := NewLanguageDialog();
  OV.AddWindow(app, w)
END OptionsLanguage;

PROCEDURE BuildErrorCallback(IN fname: ARRAY OF CHAR;
    col, line, error: INTEGER; IN msg: ARRAY OF CHAR);
VAR e: Editor.Editor;
BEGIN
  IF fname[0] # 0X THEN
    FocusOrOpenFile(fname);
    e := app.windows(Editor.Editor);
    IF (col >= 1) & (line >= 1) THEN
      IF (col = 1) & (line # 1) THEN
        e.text.MoveToLineCol(line - 1, 256, e.h - 2)
      ELSE e.text.MoveToLineCol(line, col, e.h - 2)
      END
    END;
    Editor.PrintText(app.windows(Editor.Editor))
  END;
  ShowError(msg)
END BuildErrorCallback;

PROCEDURE OnBuild(c: OV.Control);
VAR w: OV.Window;
  foreign: BOOLEAN;
  mainFname, modname, exename, errFname, s: ARRAY 256 OF CHAR;
  errLine, errCol, res: INTEGER;
  modules: Builder.Module;
  e: Editor.Editor;
BEGIN w := c.app.windows;
  IF (w # NIL) & (w IS Editor.Editor) THEN
    IF Editor.TextChanged(w(Editor.Editor)) THEN FileSave(c) END;
    IF w(Editor.Editor).fname[0] # 0X THEN
      mainFname := w(Editor.Editor).fname$;
      Debug.StrVal('File name of main module: ', mainFname);
      Builder.SetWorkDir(mainFname);
      Debug.StrVal('Work directory: ', Builder.workDir);
      Builder.GetModuleName(mainFname, modname);
      Debug.StrVal('Module name: ', modname);
      modules := Builder.UsedModuleList(modname, mainFname,
        errFname, errLine, errCol, foreign, res);
      IF foreign THEN res := 402 END;
      Debug.IntVal('Result of UserModuleList: ', res);
      IF res = 0 THEN
        IF Builder.CompileAll(modules, exename, FALSE, BuildErrorCallback)
        THEN RunProgram(exename)
        END
      ELSE
        FocusOrOpenFile(errFname);
        e := app.windows(Editor.Editor);
        e.text.MoveToLineCol(errLine, errCol, e.h - 2);
        FoStrings.MakeErrorStr(res, s);
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
  Strings.Append(Config.version, s);
  L := OV.NewLabel(s); L.align := OV.center;
  L.do.resize(L, 1, Y, W - 2, 1); OV.Add(w, L); INC(Y, 2);

  FoStrings.Get('copyright', s); Strings.Append(' 2017-', s);
  Int.Append(Config.year, s); Strings.Append(' ', s);
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

PROCEDURE FixClipboardText(VAR s: ARRAY OF CHAR);
CONST CR = 0DX; LF = 0AX;
VAR i, j: INTEGER;
BEGIN
  i := 0; WHILE (i # LEN(s)) & (s[i] # 0X) & (s[i] # CR) DO INC(i) END;
  j := i;
  WHILE (i # LEN(s)) & (s[i] # 0X) DO
    IF s[i] = CR THEN INC(i);
      IF i # LEN(s) THEN
        IF s[i] # LF THEN s[j] := LF; INC(j) END
      END
    ELSE s[j] := s[i]; INC(i); INC(j)
    END
  END;
  s[j] := 0X
END FixClipboardText;

PROCEDURE EditPasteClipboard*(c: OV.Control);
VAR e: Editor.Editor;
  s: ARRAY 50000 OF CHAR;
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor.Editor) THEN
    Graph.GetClipboardText(T.GetWindow(), s);
    FixClipboardText(s);
    Editor.PasteText(app, s)
  END
END EditPasteClipboard;

PROCEDURE EditCopyClipboard*(c: OV.Control);
VAR s: ARRAY 50000 OF CHAR;
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor.Editor) THEN
    c.app.windows(Editor.Editor).text.CopySelection(s);
    Graph.SetClipboardText(T.GetWindow(), s)
  END
END EditCopyClipboard;

PROCEDURE EditCutClipboard*(c: OV.Control);
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor.Editor) THEN
    EditCopyClipboard(c);
    Editor.EditClear(c.app.windows(Editor.Editor))
  END
END EditCutClipboard;

PROCEDURE OnResize(w, h: INTEGER);
VAR o, br: OV.Window;
BEGIN
  o := app.windows; br := o;
  REPEAT
    IF (o.w = lastW) & (o.h = lastH - 2) & (o.x = 0) & (o.y = 1) THEN
      o.x := 0; o.y := 1; o.w := w; o.h := h - 2
    END;
    o := o.next(OV.Window)
  UNTIL o = br;
  lastW := w; lastH := h
END OnResize;

PROCEDURE InitIDE;
VAR w: OV.Window;
  m, m2: OV.Menu;
  s, q: FoStrings.String;
BEGIN
  app := OV.NewApp();
  T.Size(lastW, lastH);
  OV.SetOnResize(app, OnResize);
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
  OV.Add(m, OV.NewMenu(s, 'Ctrl+X', OV.hCtrlX, EditCutClipboard));
  FoStrings.Get('menuCopy', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+C', OV.hCtrlC, EditCopyClipboard));
  FoStrings.Get('menuPaste', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+V', OV.hCtrlV, EditPasteClipboard));
  FoStrings.Get('menuClear', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+Del', OV.hCtrlDel, Editor.EditClear));
  FoStrings.Get('menuSelectAll', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+A', OV.hCtrlA, Editor.EditSelectAll));
  FoStrings.Get('menuUnselect', s);
  OV.Add(m, OV.NewMenu(s, '', 0, Editor.EditUnselect));
  OV.Add(m, OV.NewMenu('-', '', 0, NIL));
  FoStrings.Get('menuCutInternal', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+Shift+X', OV.hCtrlShiftX, Editor.EditCut));
  FoStrings.Get('menuCopyInternal', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+Shift+C', OV.hCtrlShiftC, Editor.EditCopy));
  FoStrings.Get('menuPasteInternal', s);
  OV.Add(m, OV.NewMenu(s, 'Ctrl+Shift+V', OV.hCtrlShiftV, Editor.EditPaste));
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
  FoStrings.Get('menuRunRun', s);
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
  (*!TODO*) m.children.prev.status := OV.disabled;
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
  (*!TODO*) m.children.prev.status := OV.disabled;
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
    Strings.Insert(Config.stdPath, 0, s);
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

PROCEDURE IdentifyLanguage(VAR lang: ARRAY OF CHAR);
BEGIN
  Env.GetLang(lang); lang[2] := 0X;
  IF ~FoStrings.LangExists(lang) THEN lang := defLang END
END IdentifyLanguage;

PROCEDURE ParseArgs(VAR fs, sw: BOOLEAN; VAR w, h: INTEGER;
    VAR lang: ARRAY OF CHAR; VAR fnames: Fnames);
VAR i, nofnames, count: INTEGER;
  s: ARRAY 2048 OF CHAR;
BEGIN fs := Config.startInFullscreen; sw := FALSE; i := 1;
  nofnames := 0; w := defW; h := defH; lang := ''; count := Args.Count();
  WHILE i <= count DO Args.Get(i, s);
    IF s = '--window' THEN fs := FALSE
    ELSIF s = '--fullscreen' THEN fs := TRUE
    ELSIF s = '--software' THEN sw := TRUE
    ELSIF s = '--debug' THEN Config.SetDebug(TRUE)
    ELSIF s = '--size' THEN
      IF i # count THEN INC(i); Args.Get(i, s); ParseSize(s, w, h) END
    ELSIF s = '--lang' THEN
      IF i # count THEN
        INC(i); Args.Get(i, lang);
        IF ~FoStrings.LangExists(lang) THEN Out.String('Language "');
          Out.String(lang); Out.String('" does not exist.'); Out.Ln;
          lang := ''
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
  IF nofnames < LEN(fnames) THEN fnames[nofnames][0] := 0X END;
  IF lang = '' THEN IdentifyLanguage(lang) END
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
  lastFileDialogDir[0] := 0X;
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
