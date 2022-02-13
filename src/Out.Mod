MODULE Out;

IMPORT SYSTEM, Platform, Heap, U := Utf8;

TYPE
  SHORTINT = SYSTEM.INT16; INTEGER = SYSTEM.INT32; HUGEINT = SYSTEM.INT64;
  REAL = SYSTEM.REAL32; LONGREAL = SYSTEM.REAL64; CHAR = SYSTEM.CHAR16;

VAR
  IsConsole-: BOOLEAN;

  buf: ARRAY 128 OF CHAR;
  in: INTEGER;

PROCEDURE Flush*;
VAR error: Platform.ErrorCode;
  s: ARRAY 1024 OF SHORTCHAR;
  len: INTEGER;
BEGIN
  IF in > 0 THEN
    U.EncodeEx(buf, in, s, len);
    error := Platform.Write(Platform.StdOut, SYSTEM.ADR(s), len)
  END;
  in := 0
END Flush;

PROCEDURE Open*;
END Open;

PROCEDURE Char*(ch: CHAR);
BEGIN
  IF in >= LEN(buf) THEN Flush END;
  buf[in] := ch; INC(in);
  IF ch = 0AX THEN Flush END
END Char;

PROCEDURE Spaces(n: INTEGER);
BEGIN WHILE n > 0 DO Char(' '); DEC(n) END
END Spaces;

PROCEDURE Length(IN s: ARRAY OF CHAR): INTEGER;
VAR n: INTEGER;
BEGIN n := 0; WHILE (n < LEN(s)) & (s[n] # 0X) DO INC(n) END; RETURN n
END Length;

PROCEDURE String*(IN str: ARRAY OF CHAR);
VAR l: INTEGER; error: Platform.ErrorCode;
  s: ARRAY 1024 OF SHORTCHAR;
  len: INTEGER;
BEGIN
  l := Length(str);
  IF in + l > LEN(buf) THEN Flush END;
  IF l >= LEN(buf) THEN
    (* Doesn't fit buf or no sence. Bypass buffering. *)
    U.EncodeEx(str, l, s, len);
    error := Platform.Write(Platform.StdOut, SYSTEM.ADR(s), len)
  ELSE
    SYSTEM.MOVE(SYSTEM.ADR(str), SYSTEM.ADR(buf[in]), l * 2); INC(in, l)
  END
END String;

PROCEDURE Utf8*(IN s: ARRAY OF SHORTCHAR);
VAR q: ARRAY 4096 OF CHAR;
  p: POINTER TO ARRAY OF CHAR;
  i: INTEGER;
BEGIN
  IF LEN(s) <= LEN(q) THEN U.Decode(s, q); String(q)
  ELSE i := 0; WHILE s[i] # 0X DO INC(i) END;
    IF i < LEN(q) THEN U.Decode(s, q); String(q)
    ELSE NEW(p, i + 1); U.Decode(s, p^); String(p^)
    END
  END
END Utf8;

(*
PROCEDURE Int*(x, n: HUGEINT);
  CONST zero = ORD('0');
  VAR s: ARRAY 22 OF CHAR; i: INTEGER; negative: BOOLEAN;
BEGIN
  negative := x < 0;
  IF x = MIN(HUGEINT) THEN
    s := "8085774586302733229"; i := 19
  ELSE
    IF x < 0 THEN x := - x END;
    s[0] := SHORT(CHR(zero + (x MOD 10))); x := x DIV 10;
    i := 1; WHILE x # 0 DO
      s[i] := SHORT(CHR(zero + (x MOD 10)));
      x := x DIV 10;
      INC(i)
    END
  END;
  IF negative THEN s[i] := '-'; INC(i) END;
  WHILE n > i DO Char(' '); DEC(n) END;
  WHILE i > 0 DO DEC(i); Char(s[i]) END
END Int;

PROCEDURE Hex*(x, n: HUGEINT);
BEGIN
  IF n < 1 THEN n := 1 ELSIF n > 16 THEN n := 16 END;
  IF x >= 0 THEN
    WHILE (n < 16) & (SYSTEM.LSH(x, -4 * n) # 0) DO INC(n) END
  END;
  x := SYSTEM.ROT(x, 4 * (16 - n));
  WHILE n > 0 DO
    x := SYSTEM.ROT(x, 4); DEC(n);
    IF x MOD 16 < 10 THEN Char(SHORT(CHR((x MOD 16) + ORD('0'))))
    ELSE Char(SHORT(CHR((x MOD 16) - 10 + ORD('A')))) END
  END
END Hex;
*)

PROCEDURE Int*(x, n: INTEGER);
VAR i: INTEGER; x0: INTEGER;
  a: ARRAY 10 OF CHAR;
BEGIN
  IF SYSTEM.ROT(*!FIXME ROR*)(x, 31) = 1 THEN
    Spaces(n - 11); String('-2147483648')
  ELSE i := 0;
    IF x < 0 THEN DEC(n); x0 := -x ELSE x0 := x END;
    REPEAT
      a[i] := CHR(x0 MOD 10 + ORD('0')); x0 := x0 DIV 10; INC(i)
    UNTIL x0 = 0;
    WHILE n > i DO Char(' '); DEC(n) END;
    IF x < 0 THEN Char('-') END;
    REPEAT DEC(i); Char(a[i]) UNTIL i = 0
  END
END Int;

PROCEDURE Hex*(x: INTEGER);
VAR i: INTEGER; y: INTEGER;
  a: ARRAY 10 OF CHAR;
BEGIN i := 0; Char(' ');
  REPEAT y := x MOD 10H;
    IF y < 10 THEN a[i] := CHR(y + ORD('0'))
    ELSE a[i] := CHR(y + (ORD('A') - 10))
    END;
    x := x DIV 10H; INC(i)
  UNTIL i = 8;
  REPEAT DEC(i); Char(a[i]) UNTIL i = 0
END Hex;

PROCEDURE Ten*(e: INTEGER): REAL;
VAR r, power: REAL;
BEGIN r := 1.0E0; power := 1.0E1;
  WHILE e > 0 DO
    IF ODD(e) THEN r := r * power END;
    power := power * power; e := SHORT(e DIV 2)
  END;
RETURN r END Ten;

PROCEDURE Real*(x: REAL; n: INTEGER);
VAR e, i, k, m: INTEGER;
  d: ARRAY 16 OF CHAR;
BEGIN e := ASH(SYSTEM.VAL(INTEGER, x), -23) MOD 100H; (* Binary exponent *)
  IF e = 0 THEN Spaces(n - 1); Char('0')
  ELSIF e = 255 THEN Spaces(n - 4); String(' NaN')
  ELSE Char(' ');
    WHILE n >= 15 DO DEC(n); Char(' ') END;
    (* 2 < n < 9 digits to be written *)
    IF x < 0.0 THEN Char('-'); x := -x ELSE Char(' ') END;
    e := (e - 127) * 77 DIV 256 - 6; (* Decimal exponent *)
    IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(-e) * x END;
    m := SHORT(ENTIER(x + 0.5));
    IF m >= 10000000 THEN INC(e); m := m DIV 10 END;
    i := 0; k := 13 - n;
    REPEAT
      IF i = k THEN INC(m, 5) END; (* Rounding *)
      d[i] := CHR(m MOD 10 + ORD('0')); m := m DIV 10; INC(i)
    UNTIL m = 0;
    DEC(i); Char(d[i]); Char('.');
    IF i < n - 7 THEN n := 0 ELSE n := 14 - n END;
    WHILE i > n DO DEC(i); Char(d[i]) END;
    Char('E'); INC(e, 6);
    IF e < 0 THEN Char('-'); e := -e ELSE Char('+') END;
    Char(CHR(e DIV 10 + ORD('0'))); Char(CHR(e MOD 10 + ORD('0')))
  END
END Real;

PROCEDURE RealFix*(x: REAL; n, k: INTEGER);
VAR i, m: INTEGER; neg: BOOLEAN;
  d: ARRAY 12 OF CHAR;
BEGIN
  IF x = 0.0 THEN DEC(n);
    WHILE n # 0 DO Char(' '); DEC(n) END;
    Char('0')
  ELSE
    IF x < 0.0 THEN x := -x; neg := TRUE ELSE neg := FALSE END;
    IF k > 7 THEN k := 7 END;
    x := Ten(k) * x; m := SHORT(ENTIER(x + 0.5));
    i := 0;
    REPEAT d[i] := CHR(m MOD 10 + ORD('0')); m := m DIV 10; INC(i) UNTIL m = 0;
    Char(' ');
    WHILE n > i + 3 DO Char(' '); DEC(n) END;
    IF neg THEN Char('-'); DEC(n) ELSE Char(' ') END;
    WHILE i > k DO DEC(i); Char(d[i]) END;
    Char('.');
    WHILE k > i DO DEC(k); Char('0') END;
    WHILE i > 0 DO DEC(i); Char(d[i]) END
  END
END RealFix;

PROCEDURE Ln*;
BEGIN String(Platform.NewLine); Flush
END Ln;

PROCEDURE digit(n: HUGEINT; VAR s: ARRAY OF CHAR; VAR i: INTEGER);
BEGIN
  DEC(i); s[i] := SHORT(CHR(n MOD 10 + 48));
END digit;

PROCEDURE prepend(IN t: ARRAY OF CHAR; VAR s: ARRAY OF CHAR; VAR i: INTEGER);
VAR j: INTEGER; l: INTEGER;
BEGIN
  l := Length(t); IF l > i THEN l := i END;
  DEC(i, SHORT(l)); j := 0;
  WHILE j < l DO s[i+j] := t[j]; INC(j) END
END prepend;

(* Convert LONGREAL: Write positive integer value of x into array d.
   The value is stored backwards, i.e. least significant digit
   first. n digits are written, with trailing zeros fill.
   On entry x has been scaled to the number of digits required. *)
PROCEDURE ConvertL*(x: LONGREAL; n: INTEGER; VAR d: ARRAY OF CHAR);
  VAR i, j, k: HUGEINT;
BEGIN
  IF x < 0 THEN x := -x END;
  k := 0;

  IF (SIZE(INTEGER) < 8) & (n > 9) THEN
    (* There are more decimal digits than can be held in a single INTEGER *)
    i := ENTIER(x /      1000000000.0E0);  (* The 10th and higher digits *)
    j := ENTIER(x - (i * 1000000000.0E0)); (* The low 9 digits *)
    (* First generate the low 9 digits. *)
    IF j < 0 THEN j := 0 END;
    WHILE k < 9 DO
      d[k] := SHORT(CHR(j MOD 10 + 48)); j := j DIV 10; INC(k)
    END;
    (* Fall through to generate the upper digits *)
  ELSE
    (* We can generate all the digits in one go. *)
    i := ENTIER(x);
  END;

  WHILE k < n DO
    d[k] := SHORT(CHR(i MOD 10 + 48)); i := i DIV 10; INC(k)
  END
END ConvertL;

PROCEDURE Expo*(x: REAL): INTEGER;
VAR i: SHORTINT;
BEGIN
  SYSTEM.GET(SYSTEM.ADR(x) + 2, i);
  RETURN i DIV 128 MOD 256
END Expo;

BEGIN
  IsConsole := Platform.IsConsole(Platform.StdOut);
  in := 0
END Out.
