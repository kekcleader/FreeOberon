(* Implementation restrictions
       3  too many nodes in graph (>1500)                         CRG.NewNode
       4  too many sets (ANY-symbols or SYNC symbols)     CRT.NewAnySet, 
                                                                               CRT.ComputeSyncSet
       6  too many symbols (>300)                                   CRT.NewSym
       7  too many character classes (>50)                        CRT.NewClass
       9  too many conditions in generated code (>100)        CRX.NewCondSet
       
   Trace output (ddt settings: ${digit})
    0  Prints states of automaton
    1  Prints start symbols and followers of nonterminals (also option /s)
    2  Prints the internal graph
    3  Trace of start symbol set computation
    4  Trace of follow set computation
    5  suppresses FORWARD declarations in parser (for multipass compilers)
    6  Prints the symbol list
    7  Prints a cross reference list  (also option /x)
    8  Write statistics
==========================================================================*)
MODULE Coco;

IMPORT (*Oberon, TextFrames,*) Texts := CmdlnTexts,(* Viewers,*) CRS, CRP, CRT, Out := Console;

CONST minErrDist = 8;

VAR w: Texts.Writer; lastErrPos: LONGINT;


PROCEDURE Error (n: INTEGER; pos: LONGINT);
  
  PROCEDURE Msg (s: ARRAY OF CHAR);
  BEGIN 
  (*Texts.WriteString(w, s)*)
  Out.String(s);
  END Msg;
  
BEGIN
  INC(CRS.errors);
  IF pos < lastErrPos + minErrDist THEN lastErrPos := pos; RETURN END;
  lastErrPos := pos;
  Texts.WriteInt(w, pos, 3); Texts.WriteString(w, ": ");
  IF n < 200 THEN
    CASE n OF
  |  0: Msg("EOF expected")
  |  1: Msg("ident expected")
  |  2: Msg("string expected")
  |  3: Msg("badString expected")
  |  4: Msg("number expected")
  |  5: Msg("'COMPILER' expected")
  |  6: Msg("'IMPORT' expected")
  |  7: Msg("';' expected")
  |  8: Msg("'PRODUCTIONS' expected")
  |  9: Msg("'=' expected")
  | 10: Msg("'.' expected")
  | 11: Msg("'END' expected")
  | 12: Msg("'CHARACTERS' expected")
  | 13: Msg("'TOKENS' expected")
  | 14: Msg("'PRAGMAS' expected")
  | 15: Msg("'COMMENTS' expected")
  | 16: Msg("'FROM' expected")
  | 17: Msg("'TO' expected")
  | 18: Msg("'NESTED' expected")
  | 19: Msg("'IGNORE' expected")
  | 20: Msg("'CASE' expected")
  | 21: Msg("'+' expected")
  | 22: Msg("'-' expected")
  | 23: Msg("'CHR' expected")
  | 24: Msg("'(' expected")
  | 25: Msg("')' expected")
  | 26: Msg("'ANY' expected")
  | 27: Msg("'|' expected")
  | 28: Msg("'WEAK' expected")
  | 29: Msg("'[' expected")
  | 30: Msg("']' expected")
  | 31: Msg("'{' expected")
  | 32: Msg("'}' expected")
  | 33: Msg("'SYNC' expected")
  | 34: Msg("'CONTEXT' expected")
  | 35: Msg("'<' expected")
  | 36: Msg("'>' expected")
  | 37: Msg("'<.' expected")
  | 38: Msg("'.>' expected")
  | 39: Msg("'(.' expected")
  | 40: Msg("'.)' expected")
  | 41: Msg("??? expected")
  | 42: Msg("invalid TokenFactor")
  | 43: Msg("invalid Factor")
  | 44: Msg("invalid Factor")
  | 45: Msg("invalid Term")
  | 46: Msg("invalid Symbol")
  | 47: Msg("invalid SimSet")
  | 48: Msg("this symbol not expected in TokenDecl")
  | 49: Msg("invalid TokenDecl")
  | 50: Msg("invalid Attribs")
  | 51: Msg("invalid Declaration")
  | 52: Msg("invalid Declaration")
  | 53: Msg("invalid Declaration")
  | 54: Msg("this symbol not expected in CR")
  | 55: Msg("invalid CR")
    ELSE (*Texts.WriteString(w, "error "); Texts.WriteInt(w, n, 0)*)
        Out.String("error "); Out.Int(n, 0)
    END
  ELSE
    CASE n OF
    |  201: Msg("unexpected end of file");
    |  202: Msg("string terminator not on this line");
    |  203: Msg("a literal must not have attributes");
    |  204: Msg("this symbol kind not allowed in production");
    |  205: Msg("symbol declared without attributes");
    |  206: Msg("symbol declared with attributes");
    |  207: Msg("name declared twice");
    |  208: Msg("this type not allowed on left side of production");
    |  209: Msg("symbol earlier referenced without attributes");
    | 210: Msg("symbol earlier referenced with attributes");
    | 211: Msg("missing production for grammar name");
    | 212: Msg("grammar symbol must not have attributes");
    | 213: Msg("a literal must not be declared with a structure")
    | 214: Msg("semantic action not allowed here")
    | 215: Msg("undefined name")
    | 216: Msg("attributes not allowed in token declaration")
    | 217: Msg("name does not match name in heading")
    | 218: Msg("bad string in semantic action")
    | 219: Msg("Missing end of previous semantic action")
    | 220: Msg("token may be empty")
    | 221: Msg("token must not start with an iteration")
    | 222: Msg("only characters allowed in comment declaration")
    | 223: Msg("only terminals may be weak")
    | 224: Msg("tokens must not contain blanks")
    | 225: Msg("comment delimiter must not exceed 2 characters")
    | 226: Msg("character set contains more than one character")
    ELSE (*Texts.WriteString(w, "error "); Texts.WriteInt(w, n, 0)*)
         Out.String("error "); Out.Int(n, 0);
    END
  END;
(*Texts.WriteLn(w); Texts.Append(Oberon.Log, w.buf)*)
Out.Ln
END Error;

PROCEDURE Options(VAR s: Texts.Scanner);
  VAR i: INTEGER;
BEGIN
  IF s.nextCh = "\" THEN Texts.Scan(s); Texts.Scan(s);
    IF s.class = Texts.Name THEN i := 0;
      WHILE s.s[i] # 0X DO
        IF CAP(s.s[i]) = "X" THEN CRT.ddt[7] := TRUE
        ELSIF CAP(s.s[i]) = "S" THEN CRT.ddt[1] := TRUE
        END;
        INC(i)
      END
    END
  END;
END Options;

PROCEDURE Options0(VAR s: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN
  IF s.nextCh = "\" THEN Texts.Scan(s); Texts.Scan(s);
    IF s.class = Texts.Name THEN i := 0;
      WHILE s.s[i] # 0X DO
        IF CAP(s.s[i]) = "X" THEN CRT.ddt[7] := TRUE
        ELSIF CAP(s.s[i]) = "S" THEN CRT.ddt[1] := TRUE
        END;
        INC(i)
      END
    END
  END;
END Options;


PROCEDURE Compile*;
  VAR v: Viewers.Viewer; f: TextFrames.Frame; s: Texts.Scanner; src, t: Texts.Text;
    pos, beg, end, time: LONGINT; i: INTEGER;
BEGIN
  Texts.OpenScanner(s, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(s);
  f := Oberon.Par.frame(TextFrames.Frame);
  src := NIL; pos := 0;
  IF (s.class = Texts.Char) & (s.c = "^") THEN
    Oberon.GetSelection(t, beg, end, time);
    IF time >= 0 THEN Texts.OpenScanner(s, t, beg); Texts.Scan(s) END
  END;
  IF s.class = Texts.Name THEN
    NEW(src); Texts.Open(src, s.s);
  ELSIF (s.class = Texts.Char) & (s.c = "*") THEN
    v := Oberon.MarkedViewer();
    IF (v # NIL) & (v.dsc.next IS TextFrames.Frame) THEN
      src := v.dsc.next(TextFrames.Frame).text;
      Texts.OpenScanner(s, v.dsc(TextFrames.Frame).text, 0); Texts.Scan(s)
    END
  ELSIF (s.class = Texts.Char) & (s.c = "@") THEN
    Oberon.GetSelection(t, beg, end, time);
    IF time >= 0 THEN src := t; pos := beg; s.s := " " END
  END;
  IF src # NIL THEN
    Texts.WriteString (w, "Coco/R - Compiler-Compiler V2.2"); Texts.Append(Oberon.Log, w.buf);
    i := 0; WHILE i < 10 DO CRT.ddt[i] := FALSE; INC(i) END;
    Options(s);
    Texts.WriteLn(w); Texts.WriteString(w, s.s); Texts.Append(Oberon.Log, w.buf);
    CRS.Reset(src, pos, Error); lastErrPos := -10;
    CRP.Parse
  END
END Compile;

BEGIN
  Texts.OpenWriter(w)
END Coco.

