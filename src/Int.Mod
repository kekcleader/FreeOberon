MODULE Int;
IMPORT Strings;

PROCEDURE Str*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR i, j: INTEGER; tmp: CHAR; neg: BOOLEAN;
BEGIN
  IF n = 0 THEN s := '0'
  ELSIF n = MIN(LONGINT) THEN s := '-2147483648'
  ELSE i := 0;
    IF n < 0 THEN neg := TRUE; n := -n ELSE neg := FALSE END;
    WHILE (n # 0) & (i # LEN(s) - 1) DO
      s[i] := CHR(ORD('0') + n MOD 10);
      n := n DIV 10; INC(i)
    END;
    IF neg & (i # LEN(s) - 1) THEN s[i] := '-'; INC(i) END;
    s[i] := 0X; j := 0; DEC(i);
    WHILE j < i DO
      tmp := s[j]; s[j] := s[i]; s[i] := tmp;
      INC(j); DEC(i)
    END
  END
END Str;

PROCEDURE Val*(IN s: ARRAY OF CHAR): INTEGER;
VAR i, n: INTEGER;
  c: CHAR;
  neg: BOOLEAN;
BEGIN n := 0; c := s[0];
  IF c = '-' THEN neg := TRUE; i := 1; c := s[1]
  ELSE neg := FALSE
  END;
  WHILE ('0' <= c) & (c <= '9') DO
    n := n * 10 + ORD(c) - ORD('0');
    INC(i); c := s[i]
  END;
  IF neg THEN n := -n END ;
RETURN n END Val;

PROCEDURE Insert*(n: INTEGER; pos: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN Str(n, sn); Strings.Insert(sn, pos, s)
END Insert;

PROCEDURE Append*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN Str(n, sn); Strings.Append(sn, s)
END Append;

END Int.
