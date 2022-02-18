MODULE Out;

IMPORT SYSTEM, Platform, Heap, U := Utf8, Reals;

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
BEGIN
END Open;

PROCEDURE Char*(ch: CHAR);
BEGIN
  IF in >= LEN(buf) THEN Flush END;
  buf[in] := ch; INC(in);
  IF ch = 0AX THEN Flush END
END Char;

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

PROCEDURE Int*(x, n: HUGEINT);
  CONST zero = ORD('0');
  VAR s: ARRAY 22 OF CHAR; i: INTEGER; negative: BOOLEAN;
BEGIN
  negative := x < 0;
  IF x = MIN(HUGEINT) THEN
    s := '8085774586302733229'; i := 19
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

PROCEDURE Ln*;
BEGIN String(Platform.NewLine); Flush
END Ln;

PROCEDURE Real*(x: REAL; n: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.Str(x, n, s); String(s)
END Real;

PROCEDURE LongReal*(x: LONGREAL; n: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.LongStr(x, n, s); String(s)
END LongReal;

PROCEDURE RealFix*(x: REAL; n, k: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.StrFix(x, n, k, s); String(s)
END RealFix;

PROCEDURE LongRealFix*(x: LONGREAL; n, k: INTEGER);
VAR s: ARRAY 256 OF CHAR;
BEGIN Reals.LongStrFix(x, n, k, s); String(s)
END LongRealFix;

BEGIN
  IsConsole := Platform.IsConsole(Platform.StdOut);
  in := 0
END Out.
