MODULE Int;
IMPORT Strings;

PROCEDURE Str*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR i, j: INTEGER; tmp: CHAR; neg: BOOLEAN;
BEGIN
  IF n = 0 THEN
    s[0] := '0'; i := 1
  ELSE i := 0; neg := n < 0; 
    IF neg THEN n := -n END;
    WHILE (n > 0) & (i < LEN(s) - 1) DO
      s[i] := CHR(ORD('0') + n MOD 10);
      n := n DIV 10; INC(i)
    END;
    IF neg & (i < LEN(s) - 1) THEN s[i] := '-'; INC(i) END
  END;
  s[i] := 0X; j := 0; DEC(i);
  WHILE j < i DO
    tmp := s[j]; s[j] := s[i]; s[i] := tmp;
    INC(j); DEC(i)
  END
END Str;

PROCEDURE Val*(int: LONGINT; VAR str: ARRAY OF CHAR);
CONST maxLength = 11;
VAR
  b: ARRAY maxLength + 1 OF CHAR;
  s, e: INTEGER;
  h: CHAR;
BEGIN
  IF int = MIN(LONGINT) THEN b := '-2147483648'; e := 11
  ELSE
    IF int < 0 THEN b[0] := '-'; int := -int; s := 1 ELSE s := 0 END;
    e := s; (* 's' holds starting position of string *)
    REPEAT
      b[e] := CHR(int MOD 10 + ORD('0'));
      int := int DIV 10;
      INC(e)
    UNTIL int = 0;
    b[e] := 0X;

    DEC(e);
    WHILE s < e DO
      h := str[s]; str[s] := str[e]; str[e] := h;
      INC(s); DEC(e)
    END
  END;
  COPY(b, str)
END Val;

PROCEDURE Append*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR sn: ARRAY 30 OF CHAR;
BEGIN
  Str(n, sn); Strings.Append(sn, s)
END Append;

END Int.
