MODULE Utf8;

TYPE
  CHAR8 = SHORTCHAR;
  SHORTCHAR* = CHAR8;

VAR
  Done-: BOOLEAN;

PROCEDURE Decode*(IN in: ARRAY OF SHORTCHAR; OUT out: ARRAY OF CHAR);
VAR i, j, val, lim: INTEGER; c: SHORTCHAR;
BEGIN Done := TRUE; c := in[0]; i := 1; j := 0; lim := LEN(out) - 1;
  WHILE Done & (i < LEN(in)) & (c # 0X) & (j < lim) DO
    IF c < 80X THEN out[j] := c; INC(j)
    ELSIF (c < 0E0X) & (i < LEN(in) - 2) THEN val := ORD(c) - 192;
      IF val < 0 THEN out := in$; Done := FALSE END;
      c := in[i]; INC(i); val := val * 64 + ORD(c) - 128;
      IF (c < 80X) OR (c >= 0E0X) THEN out := in$; Done := FALSE END;
      out[j] := CHR(val); INC(j)
    ELSIF (c < 0F0X) & (i < LEN(in) - 3) THEN val := ORD(c) - 224;
      c := in[i]; INC(i); val := val * 64 + ORD(c) - 128;
      IF (c < 80X) OR (c >= 0E0X) THEN out := in$; Done := FALSE END;
      c := in[i]; INC(i); val := val * 64 + ORD(c) - 128;
      IF (c < 80X) OR (c >= 0E0X) THEN out := in$; Done := FALSE END;
      out[j] := CHR(val); INC(j)
    ELSE out := in$; Done := FALSE
    END;
    c := in[i]; INC(i)
  END;
  out[j] := 0X;
  IF c # 0X THEN Done := FALSE END
END Decode;

PROCEDURE EncodeEx*(IN in: ARRAY OF CHAR; inLen: INTEGER;
    OUT out: ARRAY OF SHORTCHAR; OUT outLen: INTEGER);
VAR i, j, val, lim: INTEGER;
BEGIN Done := TRUE; i := 0; j := 0; lim := LEN(out) - 1;
  IF inLen < 0 THEN inLen := LEN(in) END;
  WHILE Done & (i # inLen) & (in[i] # 0X) & (j < lim) DO
    val := ORD(in[i]); INC(i);
    IF val < 128 THEN
      out[j] := SHORT(CHR(val)); INC(j)
    ELSIF (val < 2048) & (j < lim - 1) THEN
      out[j] := SHORT(CHR(val DIV 64 + 192)); INC(j);
      out[j] := SHORT(CHR(val MOD 64 + 128)); INC(j)
    ELSIF j < lim - 2 THEN
      out[j] := SHORT(CHR(val DIV 4096 + 224)); INC(j); 
      out[j] := SHORT(CHR(val DIV 64 MOD 64 + 128)); INC(j);
      out[j] := SHORT(CHR(val MOD 64 + 128)); INC(j)
    ELSE Done := FALSE
    END
  END;
  out[j] := 0X; outLen := j;
  IF (i # inLen) & (in[i] # 0X) THEN Done := FALSE END
END EncodeEx;

PROCEDURE Encode*(IN in: ARRAY OF CHAR; OUT out: ARRAY OF SHORTCHAR);
VAR n: INTEGER;
BEGIN EncodeEx(in, -1, out, n)
END Encode;

PROCEDURE DecodeChar*(IN s: ARRAY OF (*!FIXME SHORT?*)CHAR): CHAR;
VAR i, x, c: INTEGER;
BEGIN c := ORD(s[0]);
  IF c > 80H THEN x := ORD(s[1]) MOD 64; (* Not 1 byte *)
    IF c DIV 32 = 6 THEN (* 2 bytes *)
      c := c MOD 32 * 64 + x
    ELSIF c DIV 16 = 14 THEN (* 3 bytes *)
      c := (c MOD 16 * 64 + x) * 64 + ORD(s[2]) MOD 64
    ELSIF c DIV 8 = 30 THEN (* 4 bytes *)
      c := ((c MOD 8 * 64 + x) * 64 + ORD(s[2]) MOD 64) * 64 + ORD(s[3]) MOD 64
    ELSE c := 0
    END
  END ;
RETURN CHR(c) END DecodeChar;

PROCEDURE EncodeChar*(c: CHAR; OUT s: ARRAY OF SHORTCHAR; OUT len: INTEGER);
VAR q: ARRAY 1 OF CHAR;
BEGIN q[0] := c; EncodeEx(q, 1, s, len)
END EncodeChar;

END Utf8.
