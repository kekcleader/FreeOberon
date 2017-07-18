MODULE vbeautify;     

IMPORT Oberon, Out, Strings, Texts;

CONST
  Tab = 09X;   LF = 0DX;
  SK = 0;       (* Section - Keyword *)
  IK = 1;        (* Indent Keyword *)
  IEK = 2;       (* Indent ending Keyword *)
  IBK = 3;       (* Indent breaking Keyword *)
  NK = -1;       (* No keyword -- used when end of text is reached*)
  TwoCharOp = 0; SpcAfterOnly = 1; SpcAllOps = 2;

TYPE
  Keyword = RECORD
    word: ARRAY 10 OF CHAR;
    class: SHORTINT
  END; 

VAR
  w: Texts.Writer;
  b: Texts.Buffer;
  fC, lC: ARRAY 23 OF INTEGER;
  hashT: ARRAY 51 OF Keyword;

PROCEDURE (VAR k: Keyword) Init (s: ARRAY (*10*) OF CHAR; class: SHORTINT); 
BEGIN
  COPY(s, k.word);
  k.class := class
END Init;

PROCEDURE passComments (VAR s: Texts.Reader); 
  VAR cmt: INTEGER; ch: CHAR;
BEGIN
  cmt := 1;
  WHILE ~s.eot & (cmt > 0) DO
    Texts.Read(s, ch);
    WHILE ch = "(" DO Texts.Read(s, ch); IF ch = "*" THEN INC(cmt) END END;   (* Nested comment opening *)
    WHILE ch = "*" DO Texts.Read(s, ch); IF ch = ")" THEN DEC(cmt) END END (* comment closing *)
  END
END passComments;

PROCEDURE passProcHead (VAR s: Texts.Scanner; bText: Texts.Text; VAR noProc: BOOLEAN; VAR procName: ARRAY OF CHAR); 
  VAR ch: CHAR;
BEGIN
  noProc := FALSE;
  Texts.Scan(s);
  (* --- Type-bound procedures can have Receiver *)
  WHILE ~s.eot & (s.class = Texts.Char) & (s.c = Texts.ElemChar) DO Texts.Scan(s) END;
  IF (s.class = Texts.Char) & (s.c = "(") THEN
    REPEAT Texts.Scan(s) UNTIL (s.class = Texts.Char) & (s.c = ")") OR s.eot;
    Texts.Scan(s)
  END;
  WHILE ~s.eot & (s.class = Texts.Char) & (s.c = Texts.ElemChar) DO Texts.Scan(s) END;
  (* --- Check name of procedure *)
  IF s.class # Texts.Name THEN noProc := TRUE; RETURN END;
  COPY(s.s, procName);
  (* --- Formal parameters *)
  Texts.OpenScanner(s, bText, Texts.Pos(s) - 1);
  Texts.Read(s, ch);
  WHILE ~s.eot & (ch # ";") DO
    IF ch = "(" THEN
      WHILE ~s.eot & (ch # ")") DO Texts.Read(s, ch) END
    ELSE
      Texts.Read(s, ch)
    END
  END
END passProcHead;
(*
PROCEDURE MarkedViewer (): TextFrames.Frame; 
  VAR v: Viewers.Viewer;
BEGIN
  v := Oberon.MarkedViewer();
  IF (v # NIL) & (v.dsc # NIL) & (v.dsc.next IS TextFrames.Frame) THEN
    RETURN v.dsc.next(TextFrames.Frame)
  ELSE
    RETURN NIL
  END
END MarkedViewer;
*)
PROCEDURE NoNotify (t: Texts.Text; op: INTEGER; beg, end: LONGINT);  END NoNotify;

PROCEDURE ParseCmdLine (VAR bText: Texts.Text; VAR oldNotifier: Texts.Notifier); 
VAR
  beg, end, time: LONGINT;
  (*f: TextFrames.Frame;*)
  par: Oberon.ParList;
  s: Texts.Scanner;
  t: Texts.Text;
(*
PROCEDURE OpenText (fileName: ARRAY OF CHAR; VAR t: Texts.Text; VAR f: TextFrames.Frame); 
  VAR menuF: TextFrames.Frame; v: Viewers.Viewer; x, y: INTEGER;
BEGIN
  menuF := TextFrames.NewMenu(fileName, "Edit.Store System.Close");
  t := TextFrames.Text(fileName);
  f := TextFrames.NewText(t, 0);
  Oberon.AllocateUserViewer(0, x, y);
  v := MenuViewers.New(menuF, f, TextFrames.menuH, x, y)
END OpenText; 
*)
PROCEDURE OpenText (fileName: ARRAY OF CHAR; VAR t: Texts.Text); 
BEGIN
  NEW(t);
  Texts.Open(t, fileName);

END OpenText; 
BEGIN
  oldNotifier := NIL; par := Oberon.Par;
  Texts.OpenScanner(s, par.text, par.pos);
  Texts.Scan(s);
  IF s.class = Texts.Name THEN                (* Called by filename *)
    (*OpenText(s.s, bText, f)*)
    OpenText(s.s, bText)
  (*
  ELSIF (s.class = Texts.Char) & (s.c = "*") THEN    (* Called by selected viewer *)
    f := MarkedViewer()
  ELSIF (s.class = Texts.Char) & (s.c = "^") THEN    (* Called by selection *)
    Oberon.GetSelection(t, beg, end, time);
    IF time >= 0 THEN                         (* Selection found *)
      Texts.OpenScanner(s, t, beg); Texts.Scan(s);
      IF s.class = Texts.Name THEN
        OpenText(s.s, bText, f)
      END
    END
    *) (* commented out oberon system specific parts. -- noch *)
  END;
  (*IF f # NIL THEN
    bText := f.text;
    oldNotifier := f.text.notify;
    bText.notify := NoNotify
  ELSE
    Out.String("Could not find TextFrames.Frame. Program aborted."); Out.Ln;
    HALT(99)
  END*)
END ParseCmdLine;
(*
PROCEDURE GetFontsFromText (bText: Texts.Text; VAR expNamFnt, cmtFnt: Fonts.Font); 
VAR
  r: Texts.Reader;
  ch: CHAR;
  boldfont, italicfont: ARRAY 32 OF CHAR;
  i: INTEGER;
BEGIN
  (* --- Get the fontname *)
  Texts.OpenReader(r, bText, 0);
  Texts.Read(r, ch);
  COPY(r.fnt.name, boldfont);
  COPY(r.fnt.name, italicfont);

  (* --- Get fonts *)
  i := Strings.Pos(".", boldfont, 0);
  Strings.Insert("b", i, boldfont);
  expNamFnt := Fonts.This(boldfont);
  Strings.Insert("i", i, italicfont);
  cmtFnt := Fonts.This(italicfont)
END GetFontsFromText;
*)
PROCEDURE UpdateText (bText: Texts.Text; oldNotifier: Texts.Notifier); 
BEGIN
  IF oldNotifier # NIL THEN
    bText.notify := oldNotifier;
    bText.notify(bText, Texts.replace, 0, bText.len)
  END
END UpdateText;

PROCEDURE getKeyword (t: Texts.Text; VAR s: Texts.Scanner; section: BOOLEAN): SHORTINT; 
  VAR i, firstC, lastC: INTEGER; pos: LONGINT; noProc: BOOLEAN; dummy: ARRAY 32 OF CHAR;
BEGIN
  WHILE ~s.eot DO
    Texts.Scan(s);
    IF s.class = Texts.Name THEN
      (* --- hash value calculation *)
      firstC := ORD(s.s[0]) - ORD('A');
      lastC := ORD(s.s[s.len - 1]) - ORD('A');
      IF (firstC >= 0) & (firstC < 23) & (lastC < 23) & (lastC >= 0) THEN
        i := (fC[firstC] + 11 * lC[lastC]) MOD 51;
        IF (i # 17) & (i # 35) & (i # 4) & (hashT[i].word = s.s) THEN
          RETURN hashT[i].class
        ELSIF (i = 35) & (s.nextCh = LF) & (s.s = "VAR") THEN
          RETURN IBK
        ELSIF (i = 4) & (s.s = "BEGIN") THEN
          IF section THEN RETURN IBK ELSE RETURN IK END
        ELSIF (i = 17) THEN
          passProcHead(s, t, noProc, dummy);
          IF ~noProc THEN RETURN hashT[i].class END
        END
      END
    ELSIF (s.class = Texts.Char) THEN
      IF (s.c = "|") THEN RETURN IBK END;
      IF (s.c = "(") & (s.nextCh = "*") THEN Texts.Scan(s); passComments(s) END
    END
  END;
  RETURN NK
END getKeyword;

PROCEDURE InsertInd (VAR r: Texts.Reader; VAR s: Texts.Scanner; t: Texts.Text; ind: SHORTINT; decInd: BOOLEAN); 
VAR
  ch, ch2: CHAR;
  lastLF, sPos: LONGINT;
  i: INTEGER;
BEGIN
  FOR i := 1 TO ind DO Texts.Write(w, Tab) END;
  sPos := Texts.Pos(s);
  lastLF := - 1;
  (* --- Trace reader to position of Scanner *)
  WHILE (Texts.Pos(r) + 1 < sPos) & ~r.eot DO
    Texts.Read(r, ch); Texts.Read(r, ch2); IF ~r.eot THEN Texts.OpenReader(r, t, Texts.Pos(r) - 1); END;
    IF (ch = LF) & (ch2 # LF) & (ind > 0) THEN
      lastLF := Texts.Pos(r);
      sPos := sPos + ind;
      Texts.Copy(w.buf, b);
      Texts.Insert(t, lastLF, b);
      Texts.OpenReader(r, t, lastLF + ind)
    END
  END;
  Texts.OpenBuf(w.buf);                     (* Flush buffer *)
  Texts.OpenScanner(s, t, sPos);
  (* --- Check if we have to move the last line one tab position to the left *)
  IF decInd & (lastLF # - 1) THEN
    Texts.Delete(t, lastLF, lastLF + 1);
    Texts.OpenScanner(s, t, Texts.Pos(s) - 1);
    Texts.OpenReader(r, t, Texts.Pos(r) - 1)
  END
END InsertInd;

PROCEDURE IndentCheck (bText: Texts.Text); 
VAR
  r: Texts.Reader; s: Texts.Scanner; ch: CHAR; ind, i: SHORTINT; pos: LONGINT; section: BOOLEAN; leadStart, trailStart: LONGINT;
BEGIN
  (* --- Kill leading and trailing Tabs/Blanks *)
  pos := 0;
  Texts.OpenReader(r, bText, pos);
  Texts.Read(r, ch);
  trailStart := 0;
  WHILE (~r.eot) DO
    IF ch = LF THEN
      leadStart := Texts.Pos(r);
      Texts.Read(r, ch);
      WHILE (ch = " ") OR (ch = Tab) DO Texts.Read(r, ch) END;
      pos := Texts.Pos(r) - 1;
      Texts.Delete(bText, leadStart, pos);
      Texts.OpenReader(r, bText, leadStart + 1)
    ELSE
      WHILE (ch # LF) & ~r.eot DO
        IF (ch = " ") OR (ch = Tab) THEN
          IF trailStart = - 1 THEN trailStart := Texts.Pos(r) - 1 END
        ELSE
          trailStart := - 1
        END;
        Texts.Read(r, ch)
      END;
      IF trailStart > - 1 THEN
        pos := Texts.Pos(r) - 1;
        Texts.Delete(bText, trailStart, pos);
        Texts.OpenReader(r, bText, trailStart + 1);
        trailStart := - 1
      END
    END
  END;

  (* --- Insert correct tabulation *)
  Texts.OpenScanner(s, bText, 0);
  Texts.OpenReader(r, bText, 0);
  Texts.Scan(s);
  section := FALSE;
  ind := 0;
  WHILE ~s.eot & (ind >= 0) DO
    i := getKeyword(bText, s, section);
    IF i = IK THEN
      InsertInd(r, s, bText, ind, FALSE);
      INC(ind)
    ELSIF i = IEK THEN
      InsertInd(r, s, bText, ind, TRUE);
      DEC(ind);
      IF ind = 0 THEN section := FALSE END
    ELSIF i = IBK THEN
      InsertInd(r, s, bText, ind, TRUE)
    ELSIF i = SK THEN
      InsertInd(r, s, bText, ind, section);
      IF ~section THEN INC(ind) END;
      section := TRUE
    END
  END
END IndentCheck;
(*
PROCEDURE ChangeFont (bText: Texts.Text; expNamFnt, cmtFnt: Fonts.Font); 
VAR
  s: Texts.Scanner; ch: CHAR; oPos, pos: LONGINT; exp: BOOLEAN; noExpLine: INTEGER;
BEGIN
  pos := 0; noExpLine := -1;
  exp := TRUE;
  Texts.OpenScanner(s, bText, pos);
  WHILE ~s.eot DO
    Texts.Scan(s);
    oPos := pos;
    pos := Texts.Pos(s);
    IF (s.class = Texts.Char) & (s.c = "(") & (s.nextCh = "*") THEN      (* comment *)
      oPos := pos;
      Texts.Scan(s);
      passComments(s);
      pos := Texts.Pos(s);
      Texts.ChangeLooks(bText, oPos - 2, pos, {0}, cmtFnt, s.col, s.voff);
      Texts.OpenScanner(s, bText, pos)
    ELSIF (s.class = Texts.Char) & ((s.c = "=") OR (s.c = ":")) THEN
      noExpLine := s.line;
    ELSIF (s.class = Texts.Char) & (s.c = ";") THEN 
      noExpLine := -1;
    ELSIF (s.class = Texts.Name) THEN
      IF (s.s = "BEGIN") THEN exp := FALSE
      ELSIF (s.s = "PROCEDURE") THEN exp := TRUE
      ELSIF exp & (noExpLine # s.line) & (s.nextCh = " ") THEN        (* probably spaces between name and '*' *)
        Texts.Read(s, ch);
        WHILE ~s.eot & (ch = " ") DO Texts.Read(s, ch) END;
        IF (ch = "*") OR (ch = "-") THEN
          Texts.Delete(bText, pos - 1, Texts.Pos(s) - 1);
          Texts.ChangeLooks(bText, oPos, pos, {0}, expNamFnt, s.col, s.voff);
          Texts.OpenScanner(s, bText, pos)
        ELSE                         (* rewind *)
          Texts.OpenScanner(s, bText, Texts.Pos(s) - 1)
        END
      ELSIF exp & (noExpLine # s.line) & ((s.nextCh = "*") OR (s.nextCh = "-")) THEN    (* "regular" exported name *)
        Texts.ChangeLooks(bText, oPos - 1, pos, {0}, expNamFnt, s.col, s.voff);
        Texts.OpenScanner(s, bText, pos)
      END
    END
  END
END ChangeFont;
*)
PROCEDURE Format*; 
VAR
  bText: Texts.Text; oldNotifier: Texts.Notifier;(* expNamFnt, cmtFnt: Fonts.Font;*)
BEGIN
  bText := NIL; oldNotifier := NIL;
  ParseCmdLine(bText, oldNotifier);
  IF bText = NIL THEN
    (*Out.String("Usage: Beautifier.Format * | ^ | Filename.Mod"); Out.Ln*)
    Out.String("Usage: vbeautify Filename.Mod"); Out.Ln
  ELSE
    (*GetFontsFromText(bText, expNamFnt, cmtFnt);
    FoldElems.ExpandAll(bText, 0, TRUE);
    ChangeFont(bText, expNamFnt, cmtFnt);*)
    IndentCheck(bText);
    (*FoldElems.CollapseAll(bText, {FoldElems.tempLeft});*)
    UpdateText(bText, oldNotifier)
  END
END Format;


PROCEDURE RemSemicolons (bText: Texts.Text); 
  VAR s: Texts.Scanner; lastSC, pos: LONGINT; eCount: INTEGER; err: BOOLEAN; procName: ARRAY 24 OF CHAR;
  i: INTEGER;
BEGIN
  lastSC := - 1; eCount := 0;
  Texts.OpenScanner(s, bText, 0);
  Texts.Scan(s);
  WHILE ~s.eot DO
    IF (s.class = Texts.Char) THEN
      IF (s.c = ';') THEN
        lastSC := Texts.Pos(s) - 1;
        Texts.Scan(s)
      END
    END;
    IF (s.c = "(") & (s.nextCh = "*") THEN
      Texts.Scan(s);
      passComments(s); Texts.Scan(s)
    END;

    IF (s.class = Texts.Name) THEN
      (* --- delete semicolons *)
      IF (lastSC # - 1) & (eCount > 0) & ((s.s = "END") OR (s.s = "ELSE") OR (s.s = "ELSIF") OR (s.s = "UNTIL")) THEN
        pos := Texts.Pos(s);
        Texts.Delete(bText, lastSC - 1, lastSC);
        Texts.OpenScanner(s, bText, pos - 1)
      END;
      IF (s.s = "IF") OR (s.s = "WHILE") OR (s.s = "FOR") OR (s.s = "RECORD") OR (s.s = "WITH") OR (s.s = "LOOP") OR (s.s = "CASE") THEN
        INC(eCount)
      ELSIF (s.s = "END") THEN
        DEC(eCount)
      END;
      IF (s.s = "PROCEDURE") THEN
        passProcHead(s, bText, err, procName);
        IF ~err THEN INC(eCount) END
      END
    END;
    lastSC := - 1;
    Texts.Scan(s)
  END
END RemSemicolons;

PROCEDURE RemoveSemicolons*; 
  VAR bText: Texts.Text; oldNotifier: Texts.Notifier;
BEGIN
  ParseCmdLine(bText, oldNotifier);
  IF bText = NIL THEN
    Out.String("Usage: Beautifier.RemSemicolons * | ^ | Filename.Mod"); Out.Ln
  ELSE
    (*FoldElems.ExpandAll(bText, 0, TRUE);*)
    RemSemicolons(bText);
    (*FoldElems.CollapseAll(bText, {FoldElems.tempLeft});*)
    UpdateText(bText, oldNotifier)
  END
END RemoveSemicolons;


PROCEDURE FoldProcedures (bText: Texts.Text); 
  VAR s: Texts.Scanner; start, end: LONGINT; procName: ARRAY 24 OF CHAR; err: BOOLEAN; ch: CHAR; (*e: FoldElems.Elem;*) te: Texts.Elem;
BEGIN
  Texts.OpenScanner(s, bText, 0);
  Texts.Scan(s);
  WHILE ~s.eot DO
    IF(s.class = Texts.Name) & (s.s = "PROCEDURE") THEN        (* FoldProcedures *)
      passProcHead(s, bText, err, procName);
      IF ~err THEN
        start := Texts.Pos(s);
        (* --- Read to end of line *)
        Texts.Read(s, ch);
        WHILE (ch # LF) & ((s.elem = NIL)(* OR ~(s.elem IS FoldElems.Elem)*)) DO Texts.Read(s, ch) END;
        te := s.elem;

        (* --- find end of procedure *)
        Texts.OpenScanner(s, bText, start);
        Texts.Scan(s);
        end := - 1;
        WHILE ~s.eot & (end = - 1) DO
          IF (s.class = Texts.Name) & (s.s = "END") THEN Texts.Scan(s);
            IF (s.class = Texts.Name) & (s.s = procName) THEN end := Texts.Pos(s) END
          ELSE
            Texts.Scan(s)
          END
        END;

        (* --- Check, whether Procedure has not yet been folded *)
        (*IF (te = NIL) OR ~(te IS FoldElems.Elem) THEN
          (* --- Insert FoldElems *)
          NEW(e); e.mode := FoldElems.expRight; e.W := FoldElems.elemW; e.H := FoldElems.elemH;
          e.handle := FoldElems.FoldHandler; e.visible := TRUE; Texts.WriteElem(w, e); Texts.Insert(bText, end, w.buf);
          NEW(e); e.mode := FoldElems.expLeft; e.W := FoldElems.elemW; e.H := FoldElems.elemH;
          e.handle := FoldElems.FoldHandler; NEW(e.hidden); Texts.OpenBuf(e.hidden); e.visible := TRUE;
          Texts.WriteElem(w, e); Texts.Insert(bText, start, w.buf);
          Texts.OpenScanner(s, bText, end)
        END*)
      END
    ELSIF (s.class = Texts.Name) & (s.s = "BEGIN") THEN        (* Fold Module-Body *)
      start := Texts.Pos(s) - 1;
      Texts.OpenReader(s, bText, start);
      (* --- Read to end of line *)
      Texts.Read(s, ch);
      WHILE (ch # LF) & ((s.elem = NIL)(* OR ~(s.elem IS FoldElems.Elem)*)) DO Texts.Read(s, ch) END;
      te := s.elem;

      (* --- Find end of Module *)
      WHILE ~s.eot DO
        Texts.Scan(s);
        WHILE ~s.eot & (s.class = Texts.Name) & (s.s = "END") DO
          end := Texts.Pos(s) - 5;
          Texts.Scan(s)
        END
      END;
      (* --- Check, whether Procedure has not yet been folded *)
      (*IF (te = NIL) OR ~(te IS FoldElems.Elem) THEN
        (* --- Insert FoldElems *)
        NEW(e); e.mode := FoldElems.expRight; e.W := FoldElems.elemW; e.H := FoldElems.elemH;
        e.handle := FoldElems.FoldHandler; e.visible := TRUE; Texts.WriteElem(w, e); Texts.Insert(bText, end, w.buf);
        NEW(e); e.mode := FoldElems.expLeft; e.W := FoldElems.elemW; e.H := FoldElems.elemH;
        e.handle := FoldElems.FoldHandler; NEW(e.hidden); Texts.OpenBuf(e.hidden); e.visible := TRUE;
        Texts.WriteElem(w, e); Texts.Insert(bText, start, w.buf);
        Texts.OpenScanner(s, bText, end)
      END*)
    ELSIF (s.class = Texts.Char) & (s.c = "(") & (s.nextCh = "*") THEN
      passComments(s)
    END;
    Texts.Scan(s)
  END
END FoldProcedures;

PROCEDURE FoldProc*; 
  VAR bText: Texts.Text; oldNotifier: Texts.Notifier;
BEGIN
  ParseCmdLine(bText, oldNotifier);
  IF bText = NIL THEN
    Out.String("Usage: Beautifier.FoldProc * | ^ | Filename.Mod"); Out.Ln
  ELSE
    (*FoldElems.ExpandAll(bText, 0, TRUE);*)
    FoldProcedures(bText);
    (*FoldElems.CollapseAll(bText, {FoldElems.tempLeft});*)
    UpdateText(bText, oldNotifier)
  END
END FoldProc; 

PROCEDURE ReadOperator (VAR r: Texts.Reader; VAR buf: ARRAY OF CHAR; VAR opFlags: SET); 
  VAR i, cmt: INTEGER; ch, ech: CHAR; opFound: BOOLEAN;
BEGIN
  opFound := FALSE;
  EXCL(opFlags, TwoCharOp); EXCL(opFlags, SpcAfterOnly);

  Texts.Read(r, ch);
  WHILE ~r.eot & ~opFound DO
    (* --- Move buffer content *)
    FOR i := 0 TO 7 DO buf[i] := buf[i + 1] END;
    buf[8] := ch;

    (* --- Leave out comments *)
    WHILE ~r.eot & (ch = "(") DO
      Texts.Read(r, ch);
      IF (ch = "*") THEN
        passComments(r); Texts.Read(r, ch)
      END
    END;

    (* --- Leave out String and Character constants *)
    IF (ch = "'") OR (ch = '"') THEN
      REPEAT
        Texts.Read(r, ech)
      UNTIL r.eot OR (ch = ech)
    END;

    (* --- Check for spcAllOps & Spacing of parameter lists *)
    IF (buf = "PROCEDURE") THEN
      EXCL(opFlags, SpcAllOps)

    END;
    IF (buf[4] = "B") & (buf[5] = "E") & (buf[6] = "G") & (buf[7] = "I") & (buf[8] = "N") THEN INCL(opFlags, SpcAllOps) END;

    (* --- Check for Operators *)
    IF (ch = "<") OR (ch = ">") OR (ch = ":") THEN
      opFound := TRUE;
      INCL(opFlags, TwoCharOp)
    ELSIF (ch = "+") OR ((SpcAllOps IN opFlags) & ((ch = "-") OR (ch = "*")) ) OR (ch = "/") OR (ch = "=") OR (ch = "#") OR (ch = "&") THEN
      opFound := TRUE
    ELSIF (ch = ";") OR (ch = ",") THEN
      opFound := TRUE;
      INCL(opFlags, SpcAfterOnly)
    END;

    Texts.Read(r, ch)
  END;

  IF opFound THEN
    FOR i := 0 TO 7 DO buf[i] := buf[i + 1] END;
    buf[8] := ch;
    IF (TwoCharOp IN opFlags) & (ch = "=") THEN
      FOR i := 0 TO 7 DO buf[i] := buf[i + 1] END;
      Texts.Read(r, ch); buf[8] := ch
    ELSE
      EXCL(opFlags, TwoCharOp);
      IF buf[7] = ":" THEN INCL(opFlags, SpcAfterOnly) END
    END
  END
END ReadOperator;

PROCEDURE SpaceOperators (bText: Texts.Text); 
  VAR r: Texts.Reader; opFlags: SET; buffer: ARRAY 10 OF CHAR; ch: CHAR; pos: LONGINT;

PROCEDURE InsertSpace (pos: LONGINT); 
BEGIN
  Texts.Write(w, " ");
  Texts.Insert(bText, pos, w.buf);
  Texts.OpenReader(r, bText, pos)
END InsertSpace; 

BEGIN
  Texts.OpenReader(r, bText, 0);
  COPY("         ", buffer);
  ReadOperator(r, buffer, opFlags);
  WHILE ~r.eot DO
    pos := Texts.Pos(r);
    IF TwoCharOp IN opFlags THEN
      IF (buffer[8] # " ") THEN InsertSpace(pos - 1) END;
      IF (buffer[5] # " ") THEN InsertSpace(pos - 3) END
    ELSE
      IF SpcAfterOnly IN opFlags THEN
        IF (buffer[8] # " ") & (buffer[8] # LF) THEN InsertSpace(pos - 1) END
      ELSE
        IF (buffer[8] # " ") THEN InsertSpace(pos - 1) END;
        IF (buffer[6] # " ") THEN InsertSpace(pos - 2) END
      END
    END;
    ReadOperator(r, buffer, opFlags)
  END
END SpaceOperators;

PROCEDURE SpaceFormParms (bText: Texts.Text); 
  VAR s: Texts.Scanner; r: Texts.Reader; ch: CHAR;
BEGIN
  Texts.OpenScanner(s, bText, 0);
  Texts.Scan(s);
  WHILE ~s.eot DO
    IF (s.class = Texts.Name) & (s.s = "PROCEDURE") THEN
      Texts.OpenReader(r, bText, Texts.Pos(s) - 1);
      Texts.Read(r, ch);
      (* --- Search through the Procedure Heading *)
      WHILE ~r.eot & (ch # ";") DO
        IF (ch = "(") THEN
          (* --- Parameterlist found *)
          Texts.OpenReader(r, bText, Texts.Pos(r) - 2);
          Texts.Read(r, ch);
          IF ch # " " THEN
            (* --- Insert space *)
            Texts.Write(w, ' ');
            Texts.Insert(bText, Texts.Pos(r) , w.buf);
            Texts.OpenReader(r, bText, Texts.Pos(r))
          END;
          (* --- Search for end of parameterlist *)
          WHILE ~r.eot & (ch # ")") DO Texts.Read(r, ch) END;
          Texts.OpenScanner(s, bText, Texts.Pos(s))
        END;
        Texts.Read(r, ch)
      END
    END;
    Texts.Scan(s)
  END
END SpaceFormParms;

PROCEDURE RemSpaces (bText: Texts.Text); 
  VAR r: Texts.Reader; linStart: BOOLEAN; ch, ech: CHAR; start, end: LONGINT;
BEGIN
  linStart := TRUE;
  Texts.OpenReader(r, bText, 0);
  Texts.Read(r, ch);
  WHILE ~r.eot DO
    IF ch = LF THEN
      linStart := TRUE
    ELSIF ch # " " THEN
      linStart := FALSE;
      (* --- Pass by comments *)
      WHILE ~r.eot & (ch = "(") DO
        Texts.Read(r, ch);
        IF ch = "*" THEN passComments(r) END
      END;

      (* --- Pass by string & character constants *)
      IF (ch = "'") OR (ch = '"') THEN
        ech := ch;
        REPEAT Texts.Read(r, ch) UNTIL r.eot OR (ch = ech)
      END
    ELSIF ~linStart THEN
      start := Texts.Pos(r);
      REPEAT Texts.Read(r, ch) UNTIL r.eot OR (ch # " ");
      end := Texts.Pos(r);
      IF (end - start) > 1THEN
        Texts.Delete(bText, start, end - 1)
      END;
      Texts.OpenReader(r, bText, start)
    END;
    Texts.Read(r, ch)
  END
END RemSpaces;

PROCEDURE SpaceOps*; 
  VAR bText: Texts.Text; oldNotifier: Texts.Notifier;
BEGIN
  ParseCmdLine(bText, oldNotifier);
  IF bText = NIL THEN
    Out.String("Usage: Beautifier.SpaceOps * | ^ | Filename.Mod"); Out.Ln
  ELSE
    (*FoldElems.ExpandAll(bText, 0, TRUE);*)
    SpaceOperators(bText);
    SpaceFormParms(bText);
    RemSpaces(bText);
    (*FoldElems.CollapseAll(bText, {FoldElems.tempLeft});*)
    UpdateText(bText, oldNotifier)
  END
END SpaceOps; 

PROCEDURE TextToString(VAR T : Texts.Text; VAR string : ARRAY OF CHAR);
   VAR R : Texts.Reader;
   ch : CHAR;
   i : LONGINT;
BEGIN
   COPY("", string);
   Texts.OpenReader(R, T, 0);
   i := 0;
   WHILE Texts.Pos(R) < T.len DO
      Texts.Read(R, ch);
      IF ch # 0DX THEN string[i] := ch ELSE string[i] := 0AX END;
      INC(i);
   END;
   (*string[i] := 0X;*)
END TextToString;

PROCEDURE DumpText(VAR t: Texts.Text);
VAR s : POINTER TO ARRAY OF CHAR;
BEGIN
   NEW(s, t.len + 1);
   COPY("", s^);
   TextToString(t, s^);
   Out.String(s^); Out.Ln;
END DumpText;

PROCEDURE Beautify*; 
  VAR bText: Texts.Text; oldNotifier: Texts.Notifier; (*expNamFnt, cmtFnt: Fonts.Font;*)
BEGIN
  ParseCmdLine(bText, oldNotifier);
  IF bText = NIL THEN
    (*Out.String("Usage: Beautifier.SpaceOps * | ^ | Filename.Mod"); Out.Ln*)
    Out.String("Usage: vbeautify Filename.Mod"); Out.Ln
  ELSE
    (*GetFontsFromText(bText, expNamFnt, cmtFnt);
    FoldElems.ExpandAll(bText, 0, TRUE);
    ChangeFont(bText, expNamFnt, cmtFnt);*)
    IndentCheck(bText);
    RemSemicolons(bText);
    FoldProcedures(bText);
    SpaceOperators(bText);
    SpaceFormParms(bText);
    (*FoldElems.CollapseAll(bText, {FoldElems.tempLeft});*)
    UpdateText(bText, oldNotifier);
    (*Texts.CloseAscii(bText, 'test');*)
    DumpText(bText)
  END
END Beautify; 

PROCEDURE InitHashTable; 
  VAR i: INTEGER;
BEGIN
  (* --- empty the Character Functions *)
  FOR i := 0 TO 22 DO
    fC[i] := 0;
    lC[i] := 0
  END;
  (* --- empty Hash-Table *)
  FOR i := 0 TO 50 DO
    COPY("", hashT[i].word)
  END
  (* --- Set Character Functions *) ;
  fC[1] := 0;   fC[2] := 1;   fC[4] := 2;   fC[5] := 3;   fC[8] := 4;   fC[11] := 5;   fC[15] := 6;   fC[17] := 7;
  fC[20] := 8;   fC[21] := 9;   fC[22] := 10;
  lC[3] := 0;   lC[4] := 1;   lC[5] := 2;   lC[7] := 3;   lC[11] := 4;   lC[13] := 5;   lC[15] := 6;   lC[17] := 7;
  lC[19] := 8;
  (* --- Put Keywords into hashtable *)
  hashT[1].Init("UNTIL", IEK);
  hashT[2].Init("END", IEK);
  hashT[4].Init("BEGIN", IK);                             (* only if ~section , else BEGIN is IBK *)
  hashT[7].Init("RECORD", IK);
  hashT[11].Init("TYPE", SK);
  hashT[12].Init("CASE", IK);
  hashT[13].Init("ELSE", IBK);
  hashT[17].Init("PROCEDURE", SK);                       (* only if not a type definition *)
  hashT[20].Init("LOOP", IK);
  hashT[21].Init("WHILE", IK);
  hashT[24].Init("ELSIF", IBK);
  hashT[26].Init("IF", IK);
  hashT[29].Init("FOR", IK);
  hashT[35].Init("VAR", IBK);                               (* only if nextCh = LF *)
  hashT[38].Init("CONST", SK);
  hashT[41].Init("IMPORT", SK);
  hashT[43].Init("WITH", IK);
  hashT[44].Init("REPEAT", IK)

END InitHashTable;

BEGIN
  Texts.OpenWriter(w);
  NEW(b);
  Texts.OpenBuf(b);
  InitHashTable;
  Beautify
END vbeautify.
