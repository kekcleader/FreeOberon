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
  IF T.F # NIL THEN
    T.len := Files.Length(T.F)
  ELSE T.len := 0
  END
END Open;

PROCEDURE Read*(VAR R: Reader; VAR ch: CHAR);
BEGIN
  Files.ReadChar(R.rider, S.nextCh)
END Next;

PROCEDURE OpenScanner*(VAR S: Scanner; T: Text; pos: LONGINT);
BEGIN
  Files.Set(S.rider, T.F, pos);
  Next(S)
END OpenScanner;

PROCEDURE Scan*(VAR S: Scanner);
VAR n: INTEGER;
BEGIN
  WHILE ~S.rider.eof & (S.nextCh <= ' ') DO Next(S) END;
  IF ('0' <= S.nextCh) & (S.nextCh <= '9') THEN
    n := 0;
    REPEAT
      n := n * 10 + ORD(S.nextCh) - ORD('0');
      Next(S)
    UNTIL S.rider.eof OR ~(('0' <= S.nextCh) & (S.nextCh <= '9'));
    S.class := Int;
    S.i := n
  ELSE
    S.class := Char;
    S.c := S.nextCh;
    Next(S)
  END;
  S.eot := S.rider.eof
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
