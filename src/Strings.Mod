(*-------------------------------------------------------------
Strings provides a set of operations on strings (i.e., on string constants and character
arrays, both of which contain the character 0X as a terminator). All positions in
strings start at 0.
Strings.Length(s)
  returns the number of characters in s up to and excluding the first 0X.
Strings.Insert(src, pos, dst)
  inserts the string src into the string dst at position pos (0 <= pos <= Length(dst)).
  If pos >= Length(dst), src is appended to dst. If the size of dst is not large enough
  to hold the result of the operation, the result is truncated so that dst is always
  terminated with a 0X.
Strings.Append(s, dst)
  has the same effect as Insert(s, Length(s), dst).
Strings.Delete(s, pos, n)
  deletes n characters from s starting at position pos (0 <= pos < Length(s)).
  If n > Length(s) - pos, the new length of s is pos.
Strings.Replace(src, pos, dst)
  has the same effect as Delete(dst, pos, Length(src)) followed by an Insert(src, pos, dst).
Strings.Extract(src, pos, n, dst)
  extracts a substring dst with n characters from position pos (0 <= pos < Length(src)) in src.
  If n > Length(src) - pos, dst is only the part of src from pos to Length(src) - 1. If the size of
  dst is not large enough to hold the result of the operation, the result is truncated so that
  dst is always terminated with a 0X.
Strings.Pos(pat, s, pos)
  returns the position of the first occurrence of pat in s after position pos (inclusive).
  If pat is not found, -1 is returned.
Strings.Cap(s)
  replaces each lower case letter in s by its upper case equivalent.
-------------------------------------------------------------*)

MODULE Strings;
IMPORT Reals, SYSTEM;

TYPE
  REAL = SYSTEM.REAL32;
  LONGREAL = SYSTEM.REAL64;

PROCEDURE Length*(IN s: ARRAY OF CHAR): INTEGER;
VAR i: INTEGER;
BEGIN i := 0; WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END ;
RETURN i END Length;

PROCEDURE Append*(IN extra: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR);
VAR n1, n2, i: INTEGER;
BEGIN
  n1 := Length(dest); n2 := Length(extra); i := 0;
  WHILE (i < n2) & (i + n1 < LEN(dest)) DO dest[i + n1] := extra[i]; INC(i) END;
  IF i + n1 < LEN(dest) THEN dest[i + n1] := 0X ELSE dest[LEN(dest) - 1] := 0X END
END Append;

PROCEDURE Insert*(IN source: ARRAY OF CHAR; pos: INTEGER; VAR dest: ARRAY OF CHAR);
VAR n1, n2, len, i, j: INTEGER;
BEGIN
  n1 := Length(dest); n2 := Length(source); len := LEN(dest);
  IF pos < 0 THEN pos := 0 END;
  IF pos > n1 THEN Append(source, dest); RETURN END;
  (*--- make room for source*)
  IF pos + n2 < len THEN
    i := n1; j := i + n2; (*move also 0X if it is there*)
    WHILE i >= pos DO
      IF j < len THEN dest[j] := dest[i] END;
      DEC(i); DEC(j)
    END
  END;
  (*--- copy source to dest*)
  i := 0; j := pos;
  WHILE (i < n2) & (j < len) DO
    dest[j] := source[i];
    INC(i); INC(j)
  END;
  IF j >= len THEN dest[len - 1] := 0X END
END Insert;

PROCEDURE Delete*(VAR s: ARRAY OF CHAR; pos, n: INTEGER);
VAR len, i: INTEGER;
BEGIN
  len := Length(s);
  IF pos < 0 THEN pos := 0 ELSIF pos >= len THEN RETURN END;
  IF pos + n < len THEN
    i := pos + n; WHILE i < len DO s[i - n] := s[i]; INC(i) END;
    IF i - n < LEN(s) THEN s[i - n] := 0X END
  ELSE s[pos] := 0X
  END
END Delete;

PROCEDURE Replace*(IN source: ARRAY OF CHAR; pos: INTEGER; VAR dest: ARRAY OF CHAR);
BEGIN
  Delete(dest, pos, pos + Length(source));
  Insert(source, pos, dest)
END Replace;

PROCEDURE Extract*(IN source: ARRAY OF CHAR; pos, n: INTEGER; VAR dest: ARRAY OF CHAR);
VAR len, destLen, i: INTEGER;
BEGIN
  len := Length(source); destLen := LEN(dest) - 1;
  IF pos < 0 THEN pos := 0 END;
  IF pos >= len THEN dest[0] := 0X; RETURN END;
  i := 0;
  WHILE (pos + i <= LEN(source)) & (source[pos + i] # 0X) & (i < n) DO
    IF i < destLen THEN dest[i] := source[pos + i] END;
    INC(i)
  END;
  dest[i] := 0X
END Extract;

PROCEDURE Pos*(IN pattern, s: ARRAY OF CHAR; pos: INTEGER): INTEGER;
VAR n1, n2, i, j: INTEGER;
BEGIN
  n1 := Length(s); n2 := Length(pattern);
  IF n2 = 0 THEN RETURN 0 END;
  i := pos;
  WHILE i <= n1 - n2 DO
    IF s[i] = pattern[0] THEN
      j := 1; WHILE (j < n2) & (s[i + j] = pattern[j]) DO INC(j) END;
      IF j = n2 THEN RETURN i END
    END;
    INC(i)
  END;
  RETURN -1
END Pos;

PROCEDURE Cap*(VAR s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    IF ('a' <= s[i]) & (s[i] <= 'z') THEN s[i] := CAP(s[i]) END;
    INC(i)
  END
END Cap;

PROCEDURE Match*(IN string, pattern: ARRAY OF CHAR): BOOLEAN;

  PROCEDURE M (IN name, mask: ARRAY OF CHAR; n, m: INTEGER): BOOLEAN;
  BEGIN
    WHILE (n >= 0) & (m >= 0) & (mask[m] # '*') DO
      IF name[n] # mask[m] THEN RETURN FALSE END;
      DEC(n); DEC(m)
    END;
    (* ----- name empty | mask empty | mask ends with '*' *)
    IF m < 0 THEN RETURN n < 0 END;
    (* ----- name empty | mask ends with '*' *)
    WHILE (m >= 0) & (mask[m] = '*') DO DEC(m) END;
    IF m < 0 THEN RETURN TRUE END;
    (* ----- name empty | mask still to be matched *)
    WHILE n >= 0 DO
      IF M(name, mask, n, m) THEN RETURN TRUE END;
      DEC(n)
    END;
    RETURN FALSE
  END M;

BEGIN
  RETURN M(string, pattern, Length(string) - 1, Length(pattern) - 1)
END Match;

PROCEDURE StrToReal*(IN s: ARRAY OF CHAR; VAR r: REAL);
VAR p, e: SHORTINT; y, g: REAL; neg, negE: BOOLEAN;
BEGIN
  p := 0;
  WHILE (s[p] = ' ') OR (s[p] = '0') DO INC(p) END;
  IF s[p] = '-' THEN neg := TRUE; INC(p) ELSE neg := FALSE END;
  WHILE (s[p] = ' ') OR (s[p] = '0') DO INC(p) END;
  
  y := 0;
  WHILE ('0' <= s[p]) & (s[p] <= '9') DO
    y := y * 10 + (ORD(s[p]) - 30H);
    INC(p)
  END;
  IF s[p] = '.' THEN
    INC(p); g := 1; 
    WHILE ('0' <= s[p]) & (s[p] <= '9') DO
      g := g / 10; y := y + g * (ORD(s[p]) - 30H);
      INC(p)
    END
  END;
  IF (s[p] = 'D') OR (s[p] = 'E') THEN
    INC(p); e := 0;
    IF s[p] = '-' THEN negE := TRUE; INC(p) ELSE negE := FALSE END;
    WHILE (s[p] = '0') DO INC(p) END;
    WHILE ('0' <= s[p]) & (s[p] <= '9') DO
      e := SHORT(e * 10 + (ORD(s[p]) - 30H));
      INC(p)
    END;
    IF negE THEN y := y / Reals.Ten(e)
    ELSE y := y * Reals.Ten(e)
    END
  END;
  IF neg THEN y := -y END;
  r := y
END StrToReal;

PROCEDURE StrToLongReal*(IN s: ARRAY OF CHAR; VAR r: LONGREAL);
VAR p, e: INTEGER; y, g: LONGREAL; neg, negE: BOOLEAN;
BEGIN
  p := 0;
  WHILE (s[p] = ' ') OR (s[p] = '0') DO INC(p) END;
  IF s[p] = '-' THEN neg := TRUE; INC(p) ELSE neg := FALSE END;
  WHILE (s[p] = ' ') OR (s[p] = '0') DO INC(p) END;
  y := 0;
  WHILE ('0' <= s[p]) & (s[p] <= '9') DO
    y := y * 10 + (ORD(s[p]) - 30H);
    INC(p)
  END;
  IF s[p] = '.' THEN
    INC(p); g := 1; 
    WHILE ('0' <= s[p]) & (s[p] <= '9') DO
      g := g / 10; y := y + g * (ORD(s[p]) - 30H);
      INC(p)
    END
  END;
  IF (s[p] = 'D') OR (s[p] = 'E') THEN
    INC(p); e := 0;
    IF s[p] = '-' THEN negE := TRUE; INC(p) ELSE negE := FALSE END;
    WHILE (s[p] = '0') DO INC(p) END;
    WHILE ('0' <= s[p]) & (s[p] <= '9') DO
      e := e * 10 + ORD(s[p]) - 30H;
      INC(p)
    END;
    IF negE THEN y := y / LONG(Reals.Ten(SHORT(e)))
    ELSE y := y * LONG(Reals.Ten(SHORT(e)))
    END
  END;
  IF neg THEN y := -y END;
  r := y
END StrToLongReal;

END Strings.
