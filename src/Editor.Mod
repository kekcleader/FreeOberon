MODULE Editor;
(* Copyright 2017-2025 Arthur Yefimov

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
IMPORT OV, T := TermBox, Text := EditorText, Config, Debug,
  Int, Strings, FoStrings, StrList, Dir, Out, Env;
(** Free Oberon IDE Editor. Part of Free Oberon IDE internal code *)
CONST
  dotChar = 0B7X; (** To higlight spaces *)

  (** Direction of Selection **)
  dirLeft  = 0;
  dirRight = 1;
  dirUp    = 2;
  dirDown  = 3;

  (** Character Classes **)
  charOther       = 0;
  charAlpha       = 1;
  charDigit       = 2;
  charMinusPlus   = 3;
  charQuote       = 4;
  charOpenBracket = 5;

  (** Token Classes **)
  tokenOther   = 0;
  tokenKeyword = 1;
  tokenNumber  = 2;
  tokenString  = 3;
  tokenComment = 4;

  (** FileDialog type **)
  primaryModule* = 1;
  open* = 2;
  save* = 3;

TYPE
  FileDialog* = POINTER TO FileDialogDesc;
  FileDialogDesc* = RECORD(OV.WindowDesc)
    type*: INTEGER; (** See constants above: primaryModule, open and save *)
    edtFilename*: OV.Edit;
    btnOk*, btnCancel*: OV.Button;
    path*: ARRAY 1024 OF CHAR; (** full path to current chosen dir *)
    home*: ARRAY 1024 OF CHAR; (** i.e. 'C:/FreeOberon/Programs/' *)
    addStdPath*: BOOLEAN; (** TRUE if 'Programs/' has been added to home *)
    colFiles*: OV.ColumnList;
    onFileOk*: PROCEDURE (c: OV.Control; fname: ARRAY OF CHAR)
  END;

  Editor* = POINTER TO EditorDesc;
  EditorDesc* = RECORD(OV.WindowDesc)
    text*: Text.Text;
    fname*: ARRAY 1000 OF CHAR;
    search*: ARRAY 256 OF CHAR; (** Search string *)
    msgShown*: INTEGER; (** 0 - hidden, 1 - top, 2 - bottom *)
    msg*: ARRAY 256 OF CHAR
  END;

  SearchDialog* = POINTER TO SearchDialogDesc;
  SearchDialogDesc = RECORD(OV.WindowDesc)
    editor*: Editor;
    edtText*: OV.Edit;
    btnOk*, btnCancel*, btnHelp*: OV.Button
  END;

VAR
  clipboard: ARRAY 50000 OF CHAR;
  editorMethod-: OV.ControlMethod;
  fileDialogMethod-: OV.ControlMethod;
  searchDialogMethod-: OV.ControlMethod;

(** FileDialog **)

PROCEDURE FileNamesCmp(IN a, b: ARRAY OF CHAR): INTEGER;
VAR r: INTEGER;
BEGIN
  IF (a[0] = '[') & (b[0] # '[') OR (a = '[..]') THEN r := -1
  ELSIF (a[0] # '[') & (b[0] = '[') OR (b = '[..]') THEN r := 1
  ELSIF a < b THEN r := -1
  ELSIF a = b THEN r := 0
  ELSE r := 1
  END ;
RETURN r END FileNamesCmp;

PROCEDURE FileDialogUpdateFileList*(c: FileDialog);
VAR L: StrList.List;
  r: Dir.Rec;
  s: ARRAY 512 OF CHAR;
  n: INTEGER;
BEGIN L := c.colFiles.items;
  StrList.Clear(L);
  Dir.First(r, c.path);
  IF r.res = 0 THEN
    WHILE ~r.eod DO
      IF r.name # '.' THEN s := r.name$;
        IF r.isDir THEN
          Strings.Insert('[', 0, s); Strings.Append(']', s)
        END;
        StrList.Append(L, s)
      END;
      Dir.Next(r)
    END;
    Dir.Close(r);
    StrList.Sort(L, FileNamesCmp)
  ELSE
    Debug.StrVal('FileDialogUpdateFileList: Could not read directory ', c.path)
  END;
  StrList.First(L, s);
  IF L.eol THEN s := ''
  ELSIF s[0] = '[' THEN Strings.Delete(s, 0, 1);
    s[Strings.Length(s) - 1] := '/'
  END;
  OV.EditSetCaption(c.edtFilename, s);

  OV.ColumnListSetCur(c.colFiles, 0);
  OV.Refresh(c.colFiles);
  OV.NeedRedraw(c.app)
END FileDialogUpdateFileList;

PROCEDURE FileDialogApplyDir*(c: FileDialog; s: ARRAY OF CHAR);
VAR i: INTEGER;
  path: ARRAY 1024 OF CHAR;
BEGIN
  IF (s[0] = '/') OR (* Absolute path *)
     ('A' <= CAP(s[0])) & (CAP(s[0]) <= 'Z') & (s[1] = ':')
  THEN path := s$
  ELSE path := c.path$;
    WHILE (s[0] = '.') & (s[1] = '.') & (s[2] = '/') &
          ~((path[1] = ':') & (path[2] = '/') & (path[3] = 0X))
    DO Strings.Delete(s, 0, 3); i := Strings.Length(path) - 2;
      WHILE (i >= 0) & (path[i] # '/') DO DEC(i) END;
      IF i >= 0 THEN path[i + 1] := 0X ELSE path := '' END
    END;
    IF ~((s[0] = '.') & (s[1] = '.') & (s[2] = '/')) THEN
      Strings.Append(s, path)
    END
  END;
  IF Dir.IsDir(path) THEN c.path := path$ END
END FileDialogApplyDir;

PROCEDURE Match(IN what, where: ARRAY OF CHAR; off: INTEGER): BOOLEAN;
VAR i, j: INTEGER;
BEGIN i := 0; j := off;
  WHILE (i < LEN(what)) & (what[i] # 0X) &
        (j < LEN(where)) & (where[j] # 0X) &
        (what[i] = where[j])
  DO INC(i); INC(j)
  END ;
RETURN (i < LEN(what)) & (j < LEN(where)) & (what[i] = 0X) END Match;

PROCEDURE FileDialogOkClick*(c: OV.Control);
VAR w: FileDialog;
  s, full: ARRAY 256 OF CHAR;
  i, L: INTEGER;
  ok: BOOLEAN;
BEGIN ok := FALSE; w := c.parent(FileDialog); s := w.edtFilename.caption$;
  (* Replace all \ with / and set L to length of s *)
  L := 0; WHILE s[L] # 0X DO IF s[L] = '\' THEN s[L] := '/' END; INC(L) END;
  Debug.StrVal('FileDialogOkClick: s = ', s);
  IF L = 0 THEN
    IF w.colFiles.onChange # NIL THEN w.colFiles.onChange(w.colFiles) END
  ELSE
    IF (s[L - 1] = '/') OR (s[0] = '/') THEN
      IF s[L - 1] # '/' THEN s[L] := '/'; INC(L); s[L] := 0X END;
      FileDialogApplyDir(w, s); FileDialogUpdateFileList(w)
    ELSIF (('A' <= s[0]) & (s[0] <= 'Z') OR ('a' <= s[0]) & (s[0] <= 'z')) &
    	  (s[1] = ':') & (s[2] = '/')
    THEN full := s$; ok := TRUE
    ELSE full := w.path$;
      Debug.StrVal('FileDialogOkClick: full (1) = ', full);
      WHILE (s[0] = '.') & (s[1] = '.') & (s[2] = '/') &
            ~((full[1] = ':') & (full[2] = '/') & (full[3] = 0X))
      DO Strings.Delete(s, 0, 3); i := Strings.Length(full) - 2;
        IF i < 0 THEN i := -1 END;
        WHILE (i # -1) & (full[i] # '/') DO DEC(i) END;
        full[i + 1] := 0X
      END;
      Debug.StrVal('full (2) = ', full);
      IF ~((s[0] = '.') & (s[1] = '.') & (s[2] = '/')) THEN
        Strings.Append(s, full);
        IF Match(w.home, full, 0) THEN
          Strings.Delete(full, 0, Strings.Length(w.home));
          Debug.StrVal('Match home. full (3) = ', full);
          IF w.addStdPath THEN Strings.Insert(Config.stdPath, 0, full) END;
          Debug.StrVal('full (4) = ', full);
        END;
        ok := TRUE
      END
    END
  END;
  IF ok THEN
    OV.CloseCurWindow(c);
    IF w.onFileOk # NIL THEN w.onFileOk(c, full) END
  END
END FileDialogOkClick;

PROCEDURE FileDialogSetFname*(F: FileDialog; fname: ARRAY OF CHAR);
VAR s, path: ARRAY 256 OF CHAR;
  L, last: INTEGER;
BEGIN s := fname$; path[0] := 0X;
  L := 0; last := -1; (* Position of the last / or \ *)
  WHILE s[L] # 0X DO (* Change all \ to /, set L to length of s, set last *)
    IF (s[L] = '\') OR (s[L] = '/') THEN s[L] := '/'; last := L END;
    INC(L)
  END;

  IF last # -1 THEN (* Split path and fname (s) if there was / or \ *)
    Strings.Extract(s, 0, last + 1, path);
    Strings.Delete(s, 0, last + 1)
  END;

  F.path := path$;
  FileDialogUpdateFileList(F);
  OV.EditSetCaption(F.edtFilename, s)
END FileDialogSetFname;

PROCEDURE FileDialogListChange*(c: OV.Control);
VAR C: OV.ColumnList; w: FileDialog;
  s: ARRAY 256 OF CHAR;
BEGIN C := c(OV.ColumnList); w := C.parent(FileDialog);
  StrList.SetPos(C.items, C.cur); StrList.Next(C.items, s);
  IF s[0] = '[' THEN Strings.Delete(s, 0, 1);
    s[Strings.Length(s) - 1] := '/'
  END;
  OV.EditSetCaption(w.edtFilename, s)
END FileDialogListChange;

PROCEDURE SetHome(c: FileDialog);
VAR L: INTEGER;
BEGIN
  c.addStdPath := FALSE;
  Dir.GetCwd(c.home); L := 0;
  Debug.StrVal('FileDialog: CWD is ', c.home);
  WHILE c.home[L] # 0X DO (* Replace \ with /, set L to length of c.home *)
    IF c.home[L] = '\' THEN c.home[L] := '/' END; INC(L)
  END; (* L = length of c.home; append / if it is not in the end *)
  IF L # 0 THEN
    IF c.home[L - 1] # '/' THEN c.home[L] := '/'; INC(L); c.home[L] := 0X END;
    Strings.Append(Config.stdPath, c.home);
    IF ~Dir.IsDir(c.home) THEN
      Debug.StrVal('This is not a dir (1): ', c.home);
      c.home[L] := 0X
    ELSE c.addStdPath := TRUE
    END
  END;
  IF ~Dir.IsDir(c.home) THEN
    Debug.StrVal('This is not a dir (2): ', c.home);
    Env.GetAppDir(c.home);
    IF ~Dir.IsDir(c.home) THEN
      Debug.StrVal('This is not a dir (3): ', c.home);
      c.home := './'
    END
  END;
  Debug.StrVal('FileDialog: Home is ', c.home)
END SetHome;

PROCEDURE InitFileDialog*(c: FileDialog; type: INTEGER; IN dir: ARRAY OF CHAR);
VAR s: FoStrings.String;
BEGIN OV.InitWindow(c); c.do := fileDialogMethod; c.type := type;
  IF type = primaryModule THEN FoStrings.Get('titlePrimaryModule', c.caption)
  ELSIF type = open THEN FoStrings.Get('titleOpenAFile', c.caption)
  ELSE FoStrings.Get('titleSaveFileAs', c.caption)
  END;
  c.modal := TRUE; c.w := 70; c.h := 20; OV.CenterWindow(c);

  (* File Name Edit *)
  c.edtFilename := OV.NewEdit();
  c.edtFilename.do.resize(c.edtFilename, 3, 3, c.w - 18, 1);
  OV.Add(c, c.edtFilename);

  (* Open/Ok button (Ok for save and primaryModule types) *)
  IF type = open THEN FoStrings.Get('btnOpen', s)
  ELSE FoStrings.Get('btnOk', s)
  END;
  c.btnOk := OV.NewButton(s);
  c.btnOk.default := TRUE;
  c.btnOk.tabIndex := 2;
  c.btnOk.onClick := FileDialogOkClick;
  c.btnOk.do.resize(c.btnOk, c.w - 13, 3, 9, 1);
  OV.Add(c, c.btnOk);

  (* Cancel button *)
  FoStrings.Get('btnCancel', s);
  c.btnCancel := OV.NewButton(s);
  c.btnCancel.tabIndex := 3;
  c.btnCancel.onClick := OV.CloseCurWindow;
  c.btnCancel.do.resize(c.btnCancel, c.w - 13, 11, 9, 1);
  OV.Add(c, c.btnCancel);

  SetHome(c);
  IF dir[0] = 0X THEN c.path := c.home$ ELSE c.path := dir$ END; 

  (* ColumnList *)
  c.colFiles := OV.NewColumnList();
  c.colFiles.tabIndex := 1;
  c.colFiles.onChange := FileDialogListChange;
  c.colFiles.onDblClick := FileDialogOkClick;
  c.colFiles.do.resize(c.colFiles, 3, 6, c.w - 18, c.h - 8);
  FileDialogUpdateFileList(c);
  OV.EditSetCaption(c.edtFilename, '');
  OV.Refresh(c.colFiles);
  OV.Add(c, c.colFiles)
END InitFileDialog;

PROCEDURE NewFileDialog*(type: INTEGER; IN dir: ARRAY OF CHAR): FileDialog;
VAR c: FileDialog;
BEGIN NEW(c); InitFileDialog(c, type, dir) ;
RETURN c END NewFileDialog;

(** FileDialog Method **)

PROCEDURE FileDialogDraw*(c: OV.Control; x, y: INTEGER);
VAR f: FileDialog;
  s: FoStrings.String;
BEGIN f := c(FileDialog);
  OV.WindowDraw(c, x, y); INC(x, c.x); INC(y, c.y);
  IF f.type = primaryModule THEN FoStrings.Get('labelPrimaryModuleFile', s)
  ELSIF f.type = open THEN FoStrings.Get('labelName', s)
  ELSE FoStrings.Get('labelSaveFileAs', s)
  END;
  OV.PutMarkedString(x + 3, y + 2, s, 15, 14, 7, 0);
  FoStrings.Get('labelFiles', s);
  OV.PutMarkedString(x + 3, y + 5, s, 0, 14, 7, 0)
END FileDialogDraw;

PROCEDURE FileDialogGetFocus(c: OV.Control);
BEGIN OV.WindowGetFocus(c)
END FileDialogGetFocus;

PROCEDURE InitFileDialogMethod*(m: OV.ControlMethod);
BEGIN OV.InitWindowMethod(m);
  m.draw := FileDialogDraw;
  m.getFocus := FileDialogGetFocus
END InitFileDialogMethod;

(** Editor **)

PROCEDURE IsEmpty*(e: Editor): BOOLEAN;
BEGIN
  RETURN (e.fname[0] = 0X) & (e.text.first = e.text.last) &
         (e.text.first.len = 0)
END IsEmpty;

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
    IF neg & (i < LEN(s) - 1) THEN s[i] := '-'; INC(i) END;
  END;
  s[i] := 0X; j := 0; DEC(i);
  WHILE j < i DO
    tmp := s[j]; s[j] := s[i]; s[i] := tmp;
    INC(j); DEC(i)
  END
END IntToStr;

PROCEDURE StringsFindPrev* (pattern, stringToSearch: ARRAY OF CHAR; startPos: INTEGER;
                     VAR patternFound: BOOLEAN; VAR posOfPattern: INTEGER); (* !TODO move out *)
VAR patternPos, stringLength, patternLength: INTEGER;
BEGIN
  (* correct `startPos' if it is larger than the possible searching range *)
  stringLength := Strings.Length (stringToSearch);
  patternLength := Strings.Length (pattern);
  IF (startPos > stringLength-patternLength) THEN
    startPos := stringLength-patternLength
  END;

  IF (startPos >= 0) THEN
    patternPos := 0;
    LOOP
      IF (pattern[patternPos] = 0X) THEN
        (* reached end of pattern *)
        patternFound := TRUE;
        posOfPattern := startPos-patternPos;
        EXIT
      ELSIF (stringToSearch[startPos] # pattern[patternPos]) THEN
        (* characters differ: reset indices and restart *)
        IF (startPos > patternPos) THEN
          startPos := startPos-patternPos-1;
          patternPos := 0
        ELSE
          (* reached beginning of `stringToSearch' without finding a match *)
          patternFound := FALSE;
          EXIT
        END
      ELSE  (* characters identic, compare next one *)
        INC (startPos);
        INC (patternPos)
      END
    END
  ELSE
    patternFound := FALSE
  END
END StringsFindPrev;

PROCEDURE GetCharClass(ch: CHAR): INTEGER;
VAR class: INTEGER;
BEGIN
  IF ('a' <= ch) & (ch <= 'z') OR ('A' <= ch) & (ch <= 'Z') OR
     ('а' <= ch) & (ch <= 'я') OR ('А' <= ch) & (ch <= 'Я') OR
     (ch = 'ё') OR (ch = 'Ё')
  THEN class := charAlpha
  ELSIF ('0' <= ch) & (ch <= '9') THEN class := charDigit
  ELSIF (ch = '-') & (ch = '+') THEN class := charMinusPlus
  ELSIF (ch = '"') OR (ch = "'") THEN class := charQuote
  ELSIF ch = '(' THEN class := charOpenBracket
  ELSE class := charOther
  END ;
RETURN class END GetCharClass;

PROCEDURE IsHexDigit(ch: CHAR): BOOLEAN;
VAR result: BOOLEAN;
BEGIN
  CASE ch OF
    'A'..'F': result := TRUE
  ELSE result := FALSE END ;
RETURN result END IsHexDigit;

PROCEDURE IsKeywordInString(s: ARRAY OF CHAR; x, len: INTEGER): BOOLEAN;
VAR part: ARRAY 32 OF CHAR; result: BOOLEAN;
  PROCEDURE KW(keyword: ARRAY OF CHAR): BOOLEAN;
  BEGIN RETURN keyword = part
  END KW;
BEGIN
  IF (s[x] >= 'A') & (s[x] <= 'Z') OR (s[x] >= 'А') & (s[x] <= 'Я') THEN
    Strings.Extract(s, x, len, part);
    result := KW('ABS') OR KW('ASH') OR KW('BOOLEAN') OR KW('CAP') OR
      KW('CHAR') OR KW('CHR') OR KW('COPY') OR KW('DEC') OR KW('ENTIER') OR
      KW('EXCL') OR KW('FALSE') OR KW('HALT') OR KW('INC') OR KW('INCL') OR
      KW('INTEGER') OR KW('LEN') OR KW('LONG') OR KW('LONGINT') OR
      KW('LONGREAL') OR KW('MAX') OR KW('MIN') OR KW('NEW') OR KW('ODD') OR
      KW('ORD') OR KW('REAL') OR KW('SET') OR KW('SHORT') OR
      KW('SHORTINT') OR KW('SIZE') OR KW('TRUE') OR KW('ARRAY') OR
      KW('BEGIN') OR KW('BY') OR KW('CASE') OR KW('DIV') OR KW('DO') OR
      KW('ELSIF') OR KW('END') OR KW('EXIT') OR KW('FOR') OR KW('IF') OR
      KW('IMPORT') OR KW('IN') OR KW('IS') OR KW('LOOP') OR
      KW('MODULE') OR KW('NIL') OR KW('OR') OR KW('POINTER') OR
      KW('PROCEDURE') OR KW('RECORD') OR KW('REPEAT') OR KW('RETURN') OR
      KW('THEN') OR KW('TO') OR KW('TYPE') OR KW('VAR') OR KW('WHILE') OR
      KW('ELSE') OR KW('OF') OR KW('WITH') OR KW('LONGSET') OR
      KW('UNTIL') OR KW('CONST') OR KW('MOD') OR KW('FLOOR') OR KW('LSL') OR
      KW('ASR') OR KW('ROR') OR KW('ASSERT') OR KW('BYTE') OR
      KW('SHORTCHAR') OR KW('SYSTEM') OR KW('FLT')
      OR KW('МОДУЛЬ') OR KW('ИМПОРТ') OR KW('ПЕРЕМЕННЫЕ') OR KW('МАССИВ') OR
      KW('ИЗ') OR KW('ЛИТЕРА') OR KW('ЦЕЛОЕ') OR KW('НАЧАЛО') OR KW('НОВЫЙ') OR
      KW('ЕСЛИ') OR KW('ТОГДА') OR KW('ИНАЧЕ') OR KW('АЕСЛИ') OR KW('КОНЕЦ')
  ELSE result := FALSE
  END ;
RETURN result END IsKeywordInString;

PROCEDURE GetToken(s: ARRAY OF CHAR; x: INTEGER;
  VAR class, len, comLevel: INTEGER);

VAR i, chClass: INTEGER;

  PROCEDURE TryNumber;
  VAR ok, hex, hexEnding, point, scale,
      scaleSign, scaleNum, finish: BOOLEAN;
  BEGIN
    IF (x = 0) OR
       (~(GetCharClass(s[x - 1]) IN {charDigit, charAlpha}) &
        (s[x - 1] # '.')) THEN
      ok := TRUE; finish := FALSE; point := FALSE;
      hex := FALSE; hexEnding := FALSE;
      scale := FALSE; scaleSign := FALSE; scaleNum := FALSE;
      REPEAT
        CASE s[i] OF
          '0'..'9': IF scale THEN scaleNum := TRUE END
        | 'D', 'E':
          IF point THEN
            IF scale THEN ok := FALSE
            ELSE scale := TRUE END
          ELSE hex := TRUE END
        | 'A', 'B', 'C', 'F':
          IF point THEN ok := FALSE ELSE hex := TRUE END
        | 'H', 'X':
          IF point OR hexEnding THEN ok := FALSE
          ELSE hexEnding := TRUE END
        | '.': IF point OR hex THEN ok := FALSE ELSE point := TRUE END
        | '-', '+':
          IF hexEnding OR ~scale OR scaleNum THEN finish := TRUE
          ELSE scaleSign := TRUE END
        ELSE
          IF point & scale & ~scaleNum THEN ok := FALSE
          ELSE finish := TRUE END
        END;
        INC(i)
      UNTIL ~ok OR finish;
      IF ok & (~hex OR hexEnding) THEN
        IF GetCharClass(s[i - 1]) # charAlpha THEN
          len := i - x - 1;
          class := tokenNumber
        END
      END
    END
  END TryNumber;

  PROCEDURE TryString;
  VAR quote: CHAR;
  BEGIN
    quote := s[x];
    WHILE (s[i] # 0X) & (s[i] # quote) DO INC(i) END;
    IF s[i] # 0X THEN
      len := i - x + 1;
      class := tokenString
    END
  END TryString;

  PROCEDURE TryComment;
  BEGIN
    IF (i > 0) & (s[i] = '*') THEN INC(i); INC(comLevel) END;
    IF comLevel > 0 THEN
      REPEAT
        WHILE (s[i] # 0X) & (s[i] # '*') DO INC(i) END;
        IF s[i] = '*' THEN
          IF (i > 0) & (s[i - 1] = '(') THEN INC(comLevel)
          ELSIF s[i + 1] = ')' THEN DEC(comLevel) END;
          INC(i)
        END
      UNTIL (s[i] = 0X) OR (comLevel <= 0);
      len := i - x + 1;
      class := tokenComment
    END
  END TryComment;

BEGIN
  class := tokenOther; len := 0;
  IF s[x] # 0X THEN
    IF (x = 0) & (comLevel > 0) THEN i := 0; TryComment END;
    IF (s[x] # 0X) & (class # tokenComment) THEN
      i := x + 1;
      chClass := GetCharClass(s[x]);
      CASE chClass OF
        charAlpha:
        IF (x = 0) OR (GetCharClass(s[x - 1]) # charDigit) THEN
          WHILE GetCharClass(s[i]) = charAlpha DO INC(i) END;
          len := i - x;
          IF IsKeywordInString(s, x, len) THEN class := tokenKeyword END
        END
      | charDigit: TryNumber
      | charQuote: TryString
      | charOpenBracket: TryComment
      ELSE len := 1 END
    END
  END
END GetToken;

PROCEDURE GetTokenColor(class: INTEGER): INTEGER;
VAR color: INTEGER;
BEGIN
  CASE class OF
    tokenKeyword: color := 15
  | tokenNumber:  color := 3
  | tokenString:  color := 11
  | tokenComment: color := 7
  ELSE color := 14 END ;
RETURN color END GetTokenColor;

(** Like T.PutString, but highlighted *)
PROCEDURE PutStringH*(x, y: INTEGER; s: ARRAY OF CHAR;
  bg, limit: INTEGER; VAR comLevel: INTEGER);
VAR i, fg, class, len, tW, tH: INTEGER;
BEGIN
  T.Size(tW, tH);
  IF limit = 0 THEN limit := tW END;
  GetToken(s, 0, class, len, comLevel);
  fg := GetTokenColor(class); i := 0;
  WHILE (s[i] # 0X) & (x < limit) DO
    T.SetCell(x, y, s[i], fg, bg);
    INC(i); INC(x); DEC(len);
    IF len <= 0 THEN
      GetToken(s, i, class, len, comLevel);
      fg := GetTokenColor(class)
    END
  END;
  DEC(i);
  WHILE (i >= 0) & (s[i] = ' ') DO
    DEC(x);
    T.SetCell(x, y, dotChar, 3, bg);
    DEC(i)
  END
END PutStringH;

(** Put selected string (highlighted) *)
PROCEDURE PutSelStringH*(x, y: INTEGER; s: ARRAY OF CHAR;
  bg, limit: INTEGER; VAR comLevel: INTEGER;
  fgSel, bgSel: INTEGER; x0, x1: INTEGER);
VAR i, fg, class, len: INTEGER; sel: BOOLEAN;
BEGIN
  sel := FALSE;
  GetToken(s, 0, class, len, comLevel);
  fg := GetTokenColor(class); i := 0;
  WHILE (s[i] # 0X) & (x < limit) DO
    IF i = x1 + 1 THEN sel := FALSE
    ELSIF i = x0 THEN sel := TRUE END;
    IF sel THEN T.SetCell(x, y, s[i], fgSel, bgSel)
    ELSE T.SetCell(x, y, s[i], fg, bg) END;
    INC(i); INC(x); DEC(len);
    IF len <= 0 THEN
      GetToken(s, i, class, len, comLevel);
      fg := GetTokenColor(class)
    END
  END
END PutSelStringH;

PROCEDURE TextChanged*(c: Editor): BOOLEAN;
BEGIN RETURN c.text.changed
END TextChanged;

PROCEDURE CharFill(x, y, w, h: INTEGER; ch: CHAR; fg, bg: INTEGER);
VAR X, Y: INTEGER;
BEGIN
  FOR Y := y TO y + h - 1 DO
    FOR X := x TO x + w - 1 DO
      T.SetCell(X, Y, ch, fg, bg)
    END
  END
END CharFill;

PROCEDURE PrintText*(c: Editor);
VAR L: Text.Line; scrY: INTEGER;
  textY, x0, x1, minX, maxX, maxY, comLevel: INTEGER;
  cursorHandled: BOOLEAN;
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  CharFill(c.x + 1, c.y + 1, c.w - 2, c.h - 2, ' ', 15, c.bg);
  L := c.text.scrFirst; scrY := c.y + 1; textY := c.text.scrY;
  minX := c.x + 1; maxX := c.x + c.w - 1;
  maxY := c.y + c.h - 1; comLevel := L.comLevel;
  cursorHandled := FALSE;
  WHILE (L # NIL) & (scrY < maxY) DO
    IF c.text.selected & (c.text.selT <= textY) & (textY <= c.text.selB) THEN
      IF textY = c.text.selT THEN x0 := c.text.selL ELSE x0 := 0 END;
      IF textY = c.text.selB THEN x1 := c.text.selR - 1 ELSE x1 := L.len END;
      PutSelStringH(minX, scrY, L.s, c.bg, maxX, comLevel, 1, 7, x0, x1)
    ELSE PutStringH(minX, scrY, L.s, c.bg, maxX, comLevel)
    END;
    IF (L = c.text.cur) & (c.text.x + 1 < tW) & ~OV.HasModalWindow(c.app) THEN
      x0 := minX + c.text.x;
      IF c.focused & (x0 <= maxX) THEN
        T.SetCursor(x0, scrY);
        cursorHandled := TRUE
      END
    END;
    L := L.next; INC(scrY); INC(textY);
    IF L # NIL THEN L.comLevel := comLevel END
  END;
  IF c.focused & ~cursorHandled THEN T.HideCursor END;
  OV.NeedRedraw(c.app)
END PrintText;

PROCEDURE StartSelection(c: Editor);
BEGIN c.text.selected := TRUE;
  c.text.selL := c.text.x; c.text.selR := c.text.x;
  c.text.selT := c.text.y; c.text.selB := c.text.y
END StartSelection;

PROCEDURE CheckSelBorders(c: Editor; VAR onLeft, onRight: BOOLEAN);
BEGIN
  onLeft := (c.text.x = c.text.selL) & (c.text.y = c.text.selT);
  onRight := (c.text.x = c.text.selR) & (c.text.y = c.text.selB)
END CheckSelBorders;

PROCEDURE Swap(VAR a, b: INTEGER);
VAR tmp: INTEGER;
BEGIN
  tmp := a; a := b; b := tmp
END Swap;

PROCEDURE Order(VAR a, b: INTEGER);
VAR tmp: INTEGER;
BEGIN
  IF a > b THEN tmp := a; a := b; b := tmp END
END Order;

(** Starts, removes, upgrades selection if Shift held.
    dir is one of Direction of Selection constants. *)
PROCEDURE HandleSelection(c: Editor; dir: INTEGER;
    viaHoriz, shiftPressed: BOOLEAN);
VAR mod: SET; onLeft, onRight: BOOLEAN;
BEGIN
  IF ~shiftPressed THEN c.text.selected := FALSE
  ELSE CheckSelBorders(c, onLeft, onRight);
    IF ~c.text.selected OR (~onLeft & ~onRight) THEN
      StartSelection(c); (* Reset/new selection *)
      CheckSelBorders(c, onLeft, onRight)
    END;
    CASE dir OF
      dirRight:
      IF onRight THEN INC(c.text.selR)
      ELSIF onLeft THEN INC(c.text.selL) END
    | dirLeft:
      IF onLeft THEN DEC(c.text.selL)
      ELSIF onRight THEN DEC(c.text.selR) END
    | dirUp:
      IF onLeft THEN
        DEC(c.text.selT);
        IF viaHoriz THEN c.text.selL := c.text.cur.prev.len
        ELSIF c.text.selL > c.text.cur.prev.len
        THEN c.text.selL := c.text.cur.prev.len END
      ELSIF viaHoriz THEN
        DEC(c.text.selB); c.text.selR := c.text.cur.prev.len
      ELSIF (c.text.selB > c.text.selT + 1) OR
         ((c.text.selB = c.text.selT + 1) &
          (c.text.selR >= c.text.selL)) THEN
        DEC(c.text.selB);
        IF c.text.selR > c.text.cur.prev.len
        THEN c.text.selR := c.text.cur.prev.len END
      ELSIF c.text.selT = c.text.selB THEN
        DEC(c.text.selT); Order(c.text.selR, c.text.selL);
        IF c.text.selL > c.text.cur.prev.len
        THEN c.text.selL := c.text.cur.prev.len END
      ELSE
        DEC(c.text.selB); Order(c.text.selL, c.text.selR);
        IF c.text.selR > c.text.cur.prev.len
        THEN c.text.selR := c.text.cur.prev.len END
      END
    | dirDown:
      IF onRight THEN
        INC(c.text.selB);
        IF viaHoriz THEN c.text.selR := 0
        ELSIF c.text.selR > c.text.cur.next.len
        THEN c.text.selR := c.text.cur.next.len END
      ELSIF viaHoriz THEN
        INC(c.text.selT); c.text.selL := 0
      ELSIF (c.text.selB > c.text.selT + 1) OR
         ((c.text.selB = c.text.selT + 1) &
          (c.text.selR >= c.text.selL)) THEN
        INC(c.text.selT);
        IF c.text.selL > c.text.cur.next.len
        THEN c.text.selL := c.text.cur.next.len END
      ELSIF c.text.selT = c.text.selB THEN
        INC(c.text.selB); Swap(c.text.selL, c.text.selR);
        IF c.text.selR > c.text.cur.next.len
        THEN c.text.selR := c.text.cur.next.len END
      ELSE
        INC(c.text.selT); Swap(c.text.selL, c.text.selR);
        IF c.text.selL > c.text.cur.next.len
        THEN c.text.selL := c.text.cur.next.len END
      END
    ELSE END;
    IF (c.text.selT = c.text.selB) & (c.text.selL >= c.text.selR) OR
       (c.text.selT > c.text.selB)
    THEN c.text.selected := FALSE
    END
  END
END HandleSelection;

PROCEDURE MoveScreenByLine(c: Editor; down: BOOLEAN);
BEGIN
  IF down THEN
    ASSERT(c.text.scrFirst.next # NIL, 98);
    c.text.scrFirst := c.text.scrFirst.next; INC(c.text.scrY)
  ELSE (* Up *)
    ASSERT(c.text.scrFirst.prev # NIL, 98); ASSERT(c.text.scrY > 0, 99);
    c.text.scrFirst := c.text.scrFirst.prev; DEC(c.text.scrY)
  END
END MoveScreenByLine;

PROCEDURE MoveScreen(c: Editor; delta: INTEGER);
BEGIN
  IF delta > 0 THEN
    WHILE (delta > 0) & (c.text.scrFirst.next # NIL) DO
      MoveScreenByLine(c, TRUE); DEC(delta)
    END
  ELSE (* Up *)
    WHILE (delta < 0) & (c.text.scrFirst.prev # NIL) DO
      MoveScreenByLine(c, FALSE); INC(delta)
    END
  END
END MoveScreen;

(** Moves input cursor up and down *)
PROCEDURE MoveByLine(c: Editor; down, viaHoriz, shiftPressed: BOOLEAN);
VAR moved: BOOLEAN;
BEGIN c.text.MaybeRemoveIndent; moved := FALSE;
  IF down THEN
    IF c.text.cur.next # NIL THEN
      HandleSelection(c, dirDown, viaHoriz, shiftPressed);
      moved := TRUE;
      c.text.cur := c.text.cur.next; INC(c.text.y);
      IF c.text.y >= c.text.scrY + c.h - 2 THEN MoveScreenByLine(c, TRUE) END
    END
  ELSE (* Up *)
    IF c.text.cur.prev # NIL THEN
      HandleSelection(c, dirUp, viaHoriz, shiftPressed);
      moved := TRUE;
      IF c.text.scrFirst = c.text.cur THEN MoveScreenByLine(c, FALSE) END;
      c.text.cur := c.text.cur.prev; DEC(c.text.y)
    END
  END;
  IF moved THEN
    IF c.text.x > c.text.cur.len THEN c.text.x := c.text.cur.len END;
    PrintText(c)
  END
END MoveByLine;

(** Moves input cursor up and down by page *)
PROCEDURE MoveByPage(c: Editor; down, shiftPressed: BOOLEAN);
VAR i: INTEGER;
BEGIN c.text.MaybeRemoveIndent; i := c.h - 3;
  IF down THEN
    WHILE (i > 0) & (c.text.cur.next # NIL) DO
      c.text.scrFirst := c.text.scrFirst.next; INC(c.text.scrY);
      MoveByLine(c, TRUE, FALSE, shiftPressed);
      DEC(i)
    END
  ELSE (* Up *)
    WHILE (i > 0) & (c.text.cur.prev # NIL) DO
      IF c.text.scrY > 0 THEN
        c.text.scrFirst := c.text.scrFirst.prev; DEC(c.text.scrY)
      END;
      MoveByLine(c, FALSE, FALSE, shiftPressed);
      DEC(i)
    END
  END
END MoveByPage;

(** Moves input cursor up and down to the edge of the whole file *)
PROCEDURE MoveToFileEdge(c: Editor; down, shiftPressed: BOOLEAN);
BEGIN c.text.MaybeRemoveIndent;
  IF down THEN
    WHILE c.text.cur.next # NIL DO
      c.text.scrFirst := c.text.scrFirst.next; INC(c.text.scrY);
      MoveByLine(c, TRUE, FALSE, shiftPressed)
    END;
    c.text.x := c.text.cur.len
  ELSE (* Up *)
    c.text.x := 0;
    WHILE c.text.cur.prev # NIL DO
      IF c.text.scrY > 0 THEN
        c.text.scrFirst := c.text.scrFirst.prev; DEC(c.text.scrY)
      END;
      MoveByLine(c, FALSE, FALSE, shiftPressed)
    END
  END
END MoveToFileEdge;

(** Moves input cursor left and right by one char *)
PROCEDURE MoveByChar(c: Editor; right, shiftPressed: BOOLEAN);
BEGIN
  IF right THEN c.text.MaybeRemoveIndent;
    IF c.text.x < c.text.cur.len THEN
      HandleSelection(c, dirRight, FALSE, shiftPressed); INC(c.text.x)
    ELSIF c.text.cur.next # NIL THEN
      MoveByLine(c, TRUE, TRUE, shiftPressed);
      c.text.x := 0;
    END
  ELSE (* Left *) c.text.newLineCreated := FALSE;
    IF c.text.x > 0 THEN
      HandleSelection(c, dirLeft, FALSE, shiftPressed); DEC(c.text.x)
    ELSIF c.text.cur.prev # NIL THEN
      MoveByLine(c, FALSE, TRUE, shiftPressed);
      c.text.x := c.text.cur.len;
    END
  END
END MoveByChar;

(** Moves input cursor left and right by one word *)
PROCEDURE MoveByWord(c: Editor; right, shiftPressed: BOOLEAN);
VAR kind: INTEGER;
BEGIN
  IF ~right THEN
    REPEAT MoveByChar(c, FALSE, shiftPressed)
    UNTIL c.text.IsEdge() OR (c.text.CurCharKind() # Text.whitespace)
  END;
  kind := c.text.CurCharKind();
  REPEAT MoveByChar(c, right, shiftPressed)
  UNTIL c.text.IsEdge() OR (c.text.CurCharKind() # kind);
  IF right THEN
    WHILE ~c.text.IsEdge() & (c.text.CurCharKind() = Text.whitespace) DO
      MoveByChar(c, TRUE, shiftPressed)
    END
  ELSIF ~c.text.IsEdge() THEN MoveByChar(c, TRUE, shiftPressed)
  END
END MoveByWord;

(** Moves input cursor to start and to end *)
PROCEDURE MoveToLineEdge(c: Editor; end, shiftPressed: BOOLEAN);
VAR onLeft, onRight: BOOLEAN;
BEGIN
  IF shiftPressed THEN
    IF ~c.text.selected THEN StartSelection(c)
    ELSE
      CheckSelBorders(c, onLeft, onRight);
      IF ~onLeft & ~onRight THEN StartSelection(c) END
    END;
    CheckSelBorders(c, onLeft, onRight);
    IF end THEN
      IF onRight THEN c.text.selR := c.text.cur.len
      ELSE c.text.selL := c.text.cur.len END
    ELSE (* Home *)
      IF onRight THEN c.text.selR := 0
      ELSE c.text.selL := 0 END
    END;
    IF c.text.selT = c.text.selB THEN Order(c.text.selL, c.text.selR) END
  ELSE c.text.selected := FALSE
  END;
  IF end THEN
    IF c.text.x < c.text.cur.len THEN c.text.x := c.text.cur.len END
  ELSE (* Home *)
    IF c.text.x > 0 THEN c.text.x := 0 END
  END;
  PrintText(c)
END MoveToLineEdge;

PROCEDURE HandleBackspace(c: Editor);
BEGIN
  c.text.HandleBackspace;
  PrintText(c)
END HandleBackspace;

PROCEDURE HandleDelete(c: Editor);
BEGIN
  c.text.HandleDelete;
  PrintText(c)
END HandleDelete;

PROCEDURE HandleTab(e: Editor; shift: BOOLEAN);
BEGIN
  IF shift THEN e.text.RemoveIndent
  ELSIF e.text.WholeLineSelected() THEN e.text.AddIndent
  ELSE
    IF e.text.selected THEN e.text.DeleteSelection END;
    e.text.InsertChar(' ');
    IF ODD(e.text.x MOD 2) THEN e.text.InsertChar(' ') END
  END;
  PrintText(e)
END HandleTab;

PROCEDURE HandleEnter(c: Editor);
BEGIN
  c.text.HandleEnter(TRUE);
  IF c.text.y >= c.text.scrY + c.h - 2 THEN MoveScreenByLine(c, TRUE) END;
  PrintText(c)
END HandleEnter;

PROCEDURE InitEditor*(c: Editor);
BEGIN OV.InitWindow(c); c.closeOnEsc := FALSE;
  c.fname[0] := 0X; c.bg := 1; c.resizable := TRUE; c.caption := 'NONAME';
  c.text := Text.NewText(); c.search[0] := 0X; c.msgShown := 0; c.msg[0] := 0X;
  c.do := editorMethod
END InitEditor;

PROCEDURE NewEditor*(): Editor;
VAR w: Editor;
BEGIN NEW(w); InitEditor(w) ;
RETURN w END NewEditor;

PROCEDURE SetMsg*(c: OV.Control; IN s: ARRAY OF CHAR);
VAR e: Editor; n: INTEGER;
BEGIN e := c(Editor);
  IF e.text.scrFirst = e.text.cur THEN n := 2 ELSE n := 1 END;
  e.msgShown := n; Strings.Copy(s, e.msg)
END SetMsg;

PROCEDURE HideMsg*(c: OV.Control);
BEGIN c(Editor).msgShown := 0
END HideMsg;

(** Standard Menu Hanlders **)

PROCEDURE EditCut*(c: OV.Control);
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor) THEN
    c.app.windows(Editor).text.CopySelection(clipboard);
    c.app.windows(Editor).text.DeleteSelection
  END
END EditCut;

PROCEDURE EditCopy*(c: OV.Control);
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor) THEN
    c.app.windows(Editor).text.CopySelection(clipboard);
    PrintText(c.app.windows(Editor))
  END
END EditCopy;

PROCEDURE EditClear*(c: OV.Control);
VAR e: OV.Control;
BEGIN e := c.app.windows;
  IF (e # NIL) & (e IS Editor) THEN
    e(Editor).text.DeleteSelection;
    PrintText(e(Editor))
  END
END EditClear;

PROCEDURE PasteText*(app: OV.App; s: ARRAY OF CHAR);
VAR e: Editor;
BEGIN
  IF (app.windows # NIL) & (app.windows IS Editor) & (s[0] # 0X) THEN
    e := app.windows(Editor);
    e.text.DeleteSelection;
    e.text.Insert(s, FALSE);
    IF e.text.y >= e.text.scrY + e.h - 2 THEN
      MoveScreen(e, e.text.y - e.h + 3 - e.text.scrY)
    END;
    PrintText(e)
  END
END PasteText;

PROCEDURE EditPaste*(c: OV.Control);
BEGIN PasteText(c.app, clipboard) 
END EditPaste;

PROCEDURE EditSelectAll*(c: OV.Control);
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor) THEN
    c.app.windows(Editor).text.SelectAll;
    PrintText(c.app.windows(Editor))
  END
END EditSelectAll;

PROCEDURE EditUnselect*(c: OV.Control);
BEGIN
  IF (c.app.windows # NIL) & (c.app.windows IS Editor) THEN
    c.app.windows(Editor).text.selected := FALSE;
    PrintText(c.app.cur(Editor))
  END
END EditUnselect;

PROCEDURE SearchNext*(e: Editor);
VAR ok: BOOLEAN;
BEGIN Text.FindNext(e.text, e.search, e.text.x, e.text.y, e.h - 2, ok);
  IF ~ok THEN Text.FindNext(e.text, e.search, 0, 0, e.h - 2, ok) END
END SearchNext;

(* EditorMethod *)

PROCEDURE PrintMsg(c: Editor);
VAR y: INTEGER;
BEGIN
  IF c.msgShown = 1 THEN y := c.y + 1 ELSE y := c.y + c.h - 2 END;
  T.Fill(c.x + 1, y, c.w - 2, 1, ' ', 14, 4);
  T.Print(c.x + 2, y, c.w - 3, c.msg, 14, 4)
END PrintMsg;

PROCEDURE DrawEditorMarks(c: Editor);
VAR x, y: INTEGER;
  s: ARRAY 30 OF CHAR;
BEGIN y := c.y + c.h - 1;
  IF c.text.changed THEN T.SetChar(c.x + 2, y, 0FX) END;
  Int.Str(c.text.y + 1, s); x := 8 - Strings.Length(s);
  Strings.Append(':', s); Int.Append(c.text.x + 1, s);
  Strings.Insert(' ', 0, s); Strings.Append(' ', s);
  T.Print(c.x + x, y, c.w - x, s, 15, 1)
END DrawEditorMarks;

PROCEDURE EditorDraw*(c: OV.Control; x, y: INTEGER);
BEGIN OV.WindowDraw(c, x, y); DrawEditorMarks(c(Editor));
  PrintText(c(Editor));
  IF c(Editor).msgShown # 0 THEN PrintMsg(c(Editor)) END
END EditorDraw;

PROCEDURE EditorMouseDown*(c: OV.Control; x, y, button: INTEGER);
VAR t: Text.Text; L: Text.Line; i: INTEGER;
BEGIN OV.WindowMouseDown(c, x, y, button); HideMsg(c);
  IF (x > 0) & (x < c.w - 1) & (y > 0) & (y < c.h - 1) THEN
    DEC(x); DEC(y); t := c(Editor).text;
    t.selected := FALSE; L := t.scrFirst; i := y;
    WHILE (i > 0) & (L # NIL) DO DEC(i); L := L.next END;
    IF L # NIL THEN
      t.cur := L; t.y := y + t.scrY;
      IF x > L.len THEN x := L.len END;
      t.x := x;
      T.SetCursor(c.x + x + 1, c.y + y + 1)
    END;
    PrintText(c(Editor))
  END
END EditorMouseDown;

PROCEDURE EditorMouseUp*(c: OV.Control; x, y, button: INTEGER);
BEGIN OV.WindowMouseUp(c, x, y, button)
END EditorMouseUp;

PROCEDURE EditorMouseMove*(c: OV.Control; x, y: INTEGER; button: INTEGER);
BEGIN OV.WindowMouseMove(c, x, y, button)
END EditorMouseMove;

PROCEDURE EditorTextInput(c: OV.Control; ch: CHAR);
BEGIN
  IF c(Editor).text.selected THEN c(Editor).text.DeleteSelection END;
  IF ch # 0X THEN c(Editor).text.InsertChar(ch);
    c(Editor).text.selected := FALSE; PrintText(c(Editor))
  END
END EditorTextInput;

PROCEDURE EditorClose*(c: OV.Control; VAR cancel: BOOLEAN);
VAR E: Editor;
BEGIN E := c(Editor);
  (*IF E.text.changed THEN cancel := TRUE END*) (*!TODO Ask*)
END EditorClose;

PROCEDURE EditorKeyDown*(c: OV.Control; VAR E: T.Event);
VAR shiftPressed: BOOLEAN;
BEGIN OV.WindowKeyDown(c, E); HideMsg(c);
  shiftPressed := T.mShift IN E.mod;
  CASE E.key OF
    T.kLeft:
    IF T.mCtrl IN E.mod THEN MoveByWord(c(Editor), FALSE, shiftPressed)
    ELSE MoveByChar(c(Editor), FALSE, shiftPressed)
    END;
    PrintText(c(Editor))
  | T.kRight:
    IF T.mCtrl IN E.mod THEN MoveByWord(c(Editor), TRUE, shiftPressed)
    ELSE MoveByChar(c(Editor), TRUE, shiftPressed)
    END;
    PrintText(c(Editor))
  | T.kUp:        MoveByLine(c(Editor), FALSE, FALSE, shiftPressed)
  | T.kDown:      MoveByLine(c(Editor), TRUE, FALSE, shiftPressed)
  | T.kHome:
    IF T.mCtrl IN E.mod THEN MoveToFileEdge(c(Editor), FALSE, shiftPressed)
    ELSE MoveToLineEdge(c(Editor), FALSE, shiftPressed)
    END
  | T.kEnd:
    IF T.mCtrl IN E.mod THEN MoveToFileEdge(c(Editor), TRUE, shiftPressed)
    ELSE MoveToLineEdge(c(Editor), TRUE, shiftPressed)
    END
  | T.kPgUp:
    IF T.mCtrl IN E.mod THEN MoveToLineEdge(c(Editor), FALSE, shiftPressed)
    ELSE MoveByPage(c(Editor), FALSE, shiftPressed)
    END
  | T.kPgDn:
    IF T.mCtrl IN E.mod THEN MoveToLineEdge(c(Editor), TRUE, shiftPressed)
    ELSE MoveByPage(c(Editor), TRUE, shiftPressed)
    END
  | T.kBackspace: HandleBackspace(c(Editor))
  | T.kDel, T.kDelPad:     HandleDelete(c(Editor))
  | T.kEnter, T.kEnterPad: HandleEnter(c(Editor))
  | T.kTab:                HandleTab(c(Editor), shiftPressed)
  ELSE END
END EditorKeyDown;

PROCEDURE EditorGetFocus*(c: OV.Control);
BEGIN
  IF OV.windowMethod.getFocus # NIL THEN OV.windowMethod.getFocus(c) END;
  T.SetCursor(c.x, c.y) (*!FIXME correct?*)
END EditorGetFocus;

PROCEDURE EditorRefresh(c: OV.Control);
BEGIN OV.WindowRefresh(c)
END EditorRefresh;

PROCEDURE InitEditorMethod*(m: OV.ControlMethod);
BEGIN OV.InitWindowMethod(m);
  m.getFocus := EditorGetFocus;
  m.refresh := EditorRefresh;
  m.draw := EditorDraw;
  m.mouseDown := EditorMouseDown;
  m.mouseUp := EditorMouseUp;
  m.mouseMove := EditorMouseMove;
  m.keyDown := EditorKeyDown;
  m.textInput := EditorTextInput;
  m.close := EditorClose
END InitEditorMethod;

(** Search Dialog **)

PROCEDURE SearchDialogOkClick*(c: OV.Control);
VAR w: SearchDialog;
BEGIN w := c.parent(SearchDialog);
  Strings.Copy(w.edtText.caption, w.editor.search);
  OV.CloseCurWindow(c);
  IF w.editor.search[0] # 0X THEN
    (*w.editor.text.MoveToLineCol(1, 1, w.editor.h);*)
    SearchNext(w.editor)
  END
END SearchDialogOkClick;

PROCEDURE InitSearchDialog*(c: SearchDialog; editor: Editor);
VAR s: FoStrings.String;
BEGIN OV.InitWindow(c); c.do := searchDialogMethod; c.editor := editor;
  FoStrings.Get('titleFind', c.caption);
  c.modal := TRUE; c.w := 55; c.h := 9(*16*); OV.CenterWindow(c);

  (* Text To Find Edit *)
  c.edtText := OV.NewEdit();
  c.edtText.do.resize(c.edtText, 3, 3, c.w - 6, 1);
  (*OV.EditSetCaption(c.edtText, editor.search);*)
  OV.Add(c, c.edtText);

  (* OK button *)
  FoStrings.Get('btnOk', s);
  c.btnOk := OV.NewButton(s);
  c.btnOk.default := TRUE;
  c.btnOk.onClick := SearchDialogOkClick;
  c.btnOk.do.resize(c.btnOk, c.w - 37, c.h - 3, 8, 1);
  OV.Add(c, c.btnOk);

  (* Cancel button *)
  FoStrings.Get('btnCancel', s);
  c.btnCancel := OV.NewButton(s);
  c.btnCancel.onClick := OV.CloseCurWindow;
  c.btnCancel.do.resize(c.btnCancel, c.w - 26, c.h - 3, 8, 1);
  OV.Add(c, c.btnCancel);

  (* Help button *)
  (* FoStrings.Get('btnHelp', s);
  c.btnHelp := OV.NewButton(s);
  c.btnHelp.do.resize(c.btnHelp, c.w - 15, c.h - 3, 11, 1);
  OV.Add(c, c.btnHelp) *)
END InitSearchDialog;

PROCEDURE NewSearchDialog*(editor: Editor): SearchDialog;
VAR c: SearchDialog;
BEGIN NEW(c); InitSearchDialog(c, editor) ;
RETURN c END NewSearchDialog;

(** SearchDialog Method **)

PROCEDURE SearchDialogDraw*(c: OV.Control; x, y: INTEGER);
VAR f: SearchDialog;
  s: FoStrings.String;
BEGIN f := c(SearchDialog);
  OV.WindowDraw(c, x, y); INC(x, c.x); INC(y, c.y);
  FoStrings.Get('labelTextToFind', s);
  OV.PutMarkedString(x + 3, y + 2, s, 15, 14, 7, 0)
END SearchDialogDraw;

PROCEDURE SearchDialogGetFocus(c: OV.Control);
BEGIN OV.WindowGetFocus(c)
END SearchDialogGetFocus;

PROCEDURE InitSearchDialogMethod*(m: OV.ControlMethod);
BEGIN OV.InitWindowMethod(m);
  m.draw := SearchDialogDraw;
  m.getFocus := SearchDialogGetFocus
END InitSearchDialogMethod;

BEGIN
  NEW(editorMethod); InitEditorMethod(editorMethod);
  NEW(fileDialogMethod); InitFileDialogMethod(fileDialogMethod);
  NEW(searchDialogMethod); InitSearchDialogMethod(searchDialogMethod)
END Editor.
