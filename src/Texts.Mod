MODULE Texts;
IMPORT Files, SYSTEM;

CONST
  (* Scanner class values *)
  Inval* = 0; Name* = 1; String* = 2; Int* = 3; Real* = 4;
  LongReal* = 5; Char* = 6;

TYPE
  LONGINT* = SYSTEM.INT64;

  Text* = POINTER TO TextDesc;
  TextDesc* = RECORD
    len*: LONGINT;
    F: Files.File
  END;

  Reader* = RECORD
    eot*: BOOLEAN;
    rider: Files.Rider
  END;

  Scanner* = RECORD(Reader)
    nextCh*: CHAR;
    c*: CHAR;
    line*, class*: INTEGER;
    i*: INTEGER;
    x*: REAL;
    (*y*: LONGREAL;*)
    len*: LONGINT;
    s*: ARRAY 1900 OF CHAR
  END;

PROCEDURE Open*(T: Text; fname: ARRAY OF CHAR);
BEGIN T.F := Files.Old(fname);
  IF T.F = NIL THEN T.F := Files.New(fname) END;
  T.len := Files.Length(T.F)
END Open;

PROCEDURE Close*(T: Text);
BEGIN IF T.F # NIL THEN Files.Register(T.F) END
END Close;

PROCEDURE OpenReader*(VAR R: Reader; T: Text; pos: LONGINT);
BEGIN Files.Set(R.rider, T.F, pos); R.eot := FALSE
END OpenReader;

PROCEDURE Read*(VAR R: Reader; VAR ch: CHAR);
BEGIN Files.ReadChar(R.rider, ch);
  IF R.rider.eof THEN R.eot := TRUE END
END Read;

PROCEDURE Next(VAR S: Scanner);
BEGIN Files.ReadChar(S.rider, S.nextCh);
  IF ~S.rider.eof & (S.nextCh = 0AX) THEN INC(S.line) END
END Next;

PROCEDURE OpenScanner*(VAR S: Scanner; T: Text; pos: LONGINT);
BEGIN OpenReader(S, T, pos); S.line := 1; Next(S)
END OpenScanner;

PROCEDURE Scan*(VAR S: Scanner);
VAR i, n: INTEGER;
  quot: CHAR;
BEGIN
  WHILE ~S.rider.eof & (S.nextCh <= ' ') DO Next(S) END;
  IF S.rider.eof THEN S.class := Inval; S.eot := TRUE
  ELSIF ('0' <= S.nextCh) & (S.nextCh <= '9') THEN
    n := 0;
    REPEAT (*!FIXME Add HEX *)
      n := n * 10 + ORD(S.nextCh) - ORD('0');
      Next(S)
    UNTIL S.rider.eof OR ~(('0' <= S.nextCh) & (S.nextCh <= '9'));
    S.class := Int;
    S.i := n
  ELSIF (S.nextCh = '"') OR (S.nextCh = "'") THEN
    quot := S.nextCh; Next(S); i := 0;
    WHILE ~S.rider.eof & (S.nextCh # quot) DO
      IF i < LEN(S.s) - 1 THEN S.s[i] := S.nextCh; INC(i) END;
      Next(S)
    END;
    S.s[i] := 0X; S.len := i;
    IF ~S.rider.eof THEN Next(S); S.class := String
    ELSE S.class := Inval
    END
  ELSIF ('a' <= S.nextCh) & (S.nextCh <= 'z') OR
        ('A' <= S.nextCh) & (S.nextCh <= 'Z') THEN
    S.class := Name; i := 0;
    REPEAT
      IF i < LEN(S.s) - 1 THEN S.s[i] := S.nextCh; INC(i) END;
      Next(S)
    UNTIL S.rider.eof OR
          ~(('a' <= S.nextCh) & (S.nextCh <= 'z') OR
            ('A' <= S.nextCh) & (S.nextCh <= 'Z') OR
            ('0' <= S.nextCh) & (S.nextCh <= '9'));
    S.s[i] := 0X; S.len := i
  ELSE
    S.class := Char;
    S.c := S.nextCh;
    Next(S)
  END
END Scan;

END Texts.

(*
VAR T: Texts.Text;
  S: Texts.Scanner;
BEGIN
  NEW(T);
  Texts.Open(T, s);
  Texts.OpenScanner(S, T, 0);
  S.eot: BOOLEAN
  Texts.Scan(S);
  S.class = Texts.Int
  S.i: INTEGER
*)
