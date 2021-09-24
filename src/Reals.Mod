MODULE Reals;

VAR Done-: BOOLEAN;

PROCEDURE Ten(e: INTEGER): SHORTREAL;
VAR r, power: REAL;
BEGIN r := 1.0; power := 10.0;
  WHILE e > 0 DO
    IF ODD(e) THEN r := r * power END;
    power := power * power; e := e DIV 2
  END ;
RETURN SHORT(r) END Ten;

PROCEDURE Val*(IN s: ARRAY OF CHAR): SHORTREAL;
VAR p, e: SHORTINT; y, g: SHORTREAL; neg, negE: BOOLEAN;
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
    IF negE THEN y := y / Ten(e)
    ELSE y := y * Ten(e)
    END
  END;
  IF neg THEN y := -y END;
  Done := TRUE ; (*!FIXME*)
RETURN y END Val;

PROCEDURE LongVal*(IN s: ARRAY OF CHAR): REAL;
VAR p, e: INTEGER; y, g: REAL; neg, negE: BOOLEAN;
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
    IF negE THEN y := y / Ten(e)
    ELSE y := y * Ten(e)
    END
  END;
  IF neg THEN y := -y END;
  Done := TRUE ; (*!FIXME*)
RETURN y END LongVal;

BEGIN Done := TRUE
END Reals.
