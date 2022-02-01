MODULE Texts;
IMPORT Files, IntToStr := Int, Platform, SYSTEM;

CONST
  (* Scanner class values *)
  Inval* = 0; Name* = 1; String* = 2; Int* = 3; Real* = 4;
  LongReal* = 5; Char* = 6;

  isWindows = Platform.Windows;

TYPE
  Text* = POINTER TO TextDesc;
  TextDesc* = RECORD
    len*: INTEGER;
    f: Files.File;
    changed: BOOLEAN
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
    len*: INTEGER;
    s*: ARRAY 1900 OF CHAR
  END;

  Buffer* = POINTER TO BufDesc;
  BufDesc* = RECORD
    len*: INTEGER;
    f: Files.File
  END;

  Writer* = RECORD
    buf*: Buffer;
    rider: Files.Rider
  END;

PROCEDURE Open*(T: Text; fname: ARRAY OF CHAR);
BEGIN T.f := Files.Old(fname);
  IF T.f = NIL THEN T.f := Files.New(fname) END;
  T.len := SYSTEM.SHORT(Files.Length(T.f)); T.changed := FALSE
END Open;

PROCEDURE Close*(T: Text);
BEGIN IF (T.f # NIL) & T.changed THEN Files.Register(T.f) END
END Close;

PROCEDURE OpenReader*(VAR R: Reader; T: Text; pos: INTEGER);
BEGIN Files.Set(R.rider, T.f, pos); R.eot := FALSE
END OpenReader;

PROCEDURE Read*(VAR R: Reader; VAR ch: CHAR);
BEGIN Files.ReadChar(R.rider, ch);
  IF R.rider.eof THEN R.eot := TRUE END
END Read;

PROCEDURE Pos*(VAR R: Reader): INTEGER;
RETURN Files.Pos(R.rider) END Pos;

PROCEDURE Next(VAR S: Scanner);
BEGIN Files.ReadChar(S.rider, S.nextCh);
  IF ~S.rider.eof & (S.nextCh = 0AX) THEN INC(S.line) END
END Next;

PROCEDURE OpenScanner*(VAR S: Scanner; T: Text; pos: INTEGER);
BEGIN OpenReader(S, T, pos); S.line := 0; S.nextCh := ' '
END OpenScanner;

PROCEDURE Ten(n: INTEGER): REAL;
VAR t, p: REAL;
BEGIN t := 1.0; p := 10.0; (* Compute 10^n *)
  WHILE n > 0 DO
    IF ODD(n) THEN t := p * t END;
    p := p * p; n := n DIV 2
  END ;
RETURN t END Ten;

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

PROCEDURE OpenBuf*(B: Buffer);
BEGIN B.len := 0; B.f := Files.New('')
END OpenBuf;

PROCEDURE OpenWriter*(VAR W: Writer);
BEGIN NEW(W.buf); OpenBuf(W.buf); Files.Set(W.rider, W.buf.f, 0)
END OpenWriter;

PROCEDURE Write*(VAR W: Writer; ch: CHAR);
VAR t: INTEGER;
BEGIN t := Files.Pos(W.rider);
  Files.WriteChar(W.rider, ch);
  INC(W.buf.len, Files.Pos(W.rider) - t)
END Write;

PROCEDURE WriteLn*(VAR W: Writer);
BEGIN IF isWindows THEN Write(W, 0DX); Write(W, 0AX) ELSE Write(W, 0AX) END
END WriteLn;

PROCEDURE WriteString*(VAR W: Writer; s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE s[i] # 0X DO Write(W, s[i]); INC(i) END
END WriteString;

PROCEDURE WriteInt*(VAR W: Writer; x, n: INTEGER);
VAR i: INTEGER;
  s: ARRAY 30 OF CHAR;
BEGIN IntToStr.Str(x, s);
  i := 0; WHILE s[i] # 0X DO INC(i) END;
  DEC(n, i);
  WHILE n > 0 DO Write(W, ' '); DEC(n) END;
  WriteString(W, s)
END WriteInt;

PROCEDURE WriteHex* (VAR W: Writer; x: INTEGER);
VAR i: INTEGER; y: INTEGER;
  a: ARRAY 10 OF CHAR;
BEGIN i := 0; Write(W, ' ');
  REPEAT y := x MOD 10H;
    IF y < 10 THEN a[i] := CHR(y + 30H) ELSE a[i] := CHR(y + 37H) END;
    x := x DIV 10H; INC(i)
  UNTIL i = 8;
  REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
END WriteHex;

PROCEDURE WriteReal* (VAR W: Writer; x: REAL; n: INTEGER);
VAR e, i, k, m: INTEGER;
  d: ARRAY 16 OF CHAR;
BEGIN e := ASR(SYSTEM.VAL(INTEGER, x), 23) MOD 100H;  (*binary exponent*)
  IF e = 0 THEN
    WriteString(W, '0');
    WHILE n >= 3 DO Write(W, ' '); DEC(n) END
  ELSIF e = 255 THEN WriteString(W, ' NaN ')
  ELSE Write(W, ' ');
    WHILE n >= 15 DO DEC(n); Write(W, ' ') END;
    (* 2 < n < 9 digits to be written*)
    IF x < 0.0 THEN Write(W, '-'); x := -x ELSE Write(W, ' ') END;
    e := (e - 127) * 77 DIV 256 - 6;  (*decimal exponent*)
    IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(-e) * x END;
    m := FLOOR(x + 0.5);
    IF m >= 10000000 THEN INC(e); m := m DIV 10 END;
    i := 0; k := 13-n;
    REPEAT
       IF i = k THEN INC(m, 5) END;    (*rounding*)
     d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i)
    UNTIL m = 0;
    DEC(i); Write(W, d[i]); Write(W, '.');
    IF i < n-7 THEN n := 0 ELSE n := 14 - n END;
    WHILE i > n DO DEC(i); Write(W, d[i]) END;
    Write(W, 'E'); INC(e, 6);
     IF e < 0 THEN Write(W, '-'); e := -e ELSE Write(W, '+') END;
    Write(W, CHR(e DIV 10 + 30H)); Write(W, CHR(e MOD 10 + 30H))
  END
END WriteReal;

PROCEDURE WriteRealFix* (VAR W: Writer; x: REAL; n, k: INTEGER);
VAR i, m: INTEGER; neg: BOOLEAN;
  d: ARRAY 12 OF CHAR;
BEGIN
  IF x = 0.0 THEN WriteString(W, '0')
  ELSE
    IF x < 0.0 THEN x := -x; neg := TRUE ELSE neg := FALSE END;
    IF k > 7 THEN k := 7 END;
    x := Ten(k) * x; m := FLOOR(x + 0.5);
    i := 0;
    REPEAT d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i) UNTIL m = 0;
    Write(W, ' ');
    WHILE n > i + 3 DO  Write(W, ' '); DEC(n) END;
    IF neg THEN Write(W, '-'); DEC(n) ELSE Write(W, ' ') END;
    WHILE i > k DO DEC(i); Write(W, d[i]) END;
    Write(W, '.');
    WHILE k > i DO DEC(k); Write(W, '0') END;
    WHILE i > 0 DO DEC(i); Write(W, d[i]) END
  END
END WriteRealFix;

PROCEDURE Save*(T: Text; beg, end: INTEGER; B: Buffer);
VAR R, W: Files.Rider;
  ch: CHAR;
BEGIN
  IF end > T.len THEN end := T.len END;
  Files.Set(R, T.f, beg); Files.Set(W, B.f, B.len);
  DEC(end, beg); INC(B.len, end);
  WHILE end > 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(end) END
END Save;

PROCEDURE Copy*(SB, DB: Buffer);
VAR R, W: Files.Rider;
  ch: CHAR;
  n: INTEGER;
BEGIN Files.Set(R, SB.f, 0); Files.Set(W, DB.f, DB.len); n := SB.len;
  WHILE n # 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(n) END;
  INC(DB.len, SB.len)
END Copy;

PROCEDURE Insert*(T: Text; pos: INTEGER; B: Buffer);
VAR R, W: Files.Rider;
  ch: CHAR;
  n, q: INTEGER;
  P: Buffer;
BEGIN n := T.len - pos;
  IF n > 0 THEN q := B.len - n;
    IF q > 0 THEN Files.Set(W, T.f, T.len);
      WHILE q # 0 DO Files.WriteChar(W, ' '); DEC(q) END;
      Files.Set(R, T.f, pos);
      WHILE n # 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(n) END
    ELSE NEW(P); OpenBuf(P); Save(T, pos, pos + n, P);
      Files.Set(R, P.f, 0); Files.Set(W, T.f, pos + B.len);
      WHILE n # 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(n) END
    END
  END;
  n := B.len; Files.Set(R, B.f, 0); Files.Set(W, T.f, pos);
  WHILE n # 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(n) END;
  INC(T.len, B.len); T.changed := TRUE; B.len := 0
END Insert;

PROCEDURE Append*(T: Text; B: Buffer);
BEGIN Insert(T, T.len, B)
END Append;

END Texts.
