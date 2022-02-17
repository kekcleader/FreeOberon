MODULE Reals;

TYPE LONGREAL = REAL; (* REAL64 *) REAL = SHORTREAL; (* REAL32 *)

VAR Done-: BOOLEAN;

PROCEDURE Ten(e: INTEGER): REAL;
VAR r, power: LONGREAL;
BEGIN r := 1.0; power := 10.0;
  WHILE e > 0 DO
    IF ODD(e) THEN r := r * power END;
    power := power * power; e := e DIV 2
  END ;
RETURN SHORT(r) END Ten;

PROCEDURE LongVal*(IN s: ARRAY OF CHAR): LONGREAL;
VAR p, e: INTEGER; y, g: LONGREAL; neg, negE: BOOLEAN;
BEGIN Done := FALSE;
  p := 0;
  WHILE (s[p] # 0X) & (s[p] <= ' ') DO INC(p) END;
  IF s[p] = '-' THEN neg := TRUE; INC(p) ELSE neg := FALSE END;

  IF ('0' <= s[p]) & (s[p] <= '9') THEN
    y := 0;
    REPEAT y := y * 10 + (ORD(s[p]) - ORD('0')); INC(p)
    UNTIL ~(('0' <= s[p]) & (s[p] <= '9'));

    IF s[p] = '.' THEN
      INC(p); g := 1;
      WHILE ('0' <= s[p]) & (s[p] <= '9') DO
        g := g * 0.1; y := y + g * (ORD(s[p]) - ORD('0'));
        INC(p)
      END;

      IF (s[p] = 'D') OR (s[p] = 'E') THEN
        INC(p); e := 0;
        IF s[p] = '-' THEN negE := TRUE; INC(p)
        ELSE negE := FALSE;
          IF s[p] = '+' THEN INC(p) END
        END;
        IF ('0' <= s[p]) & (s[p] <= '9') THEN
          WHILE ('0' <= s[p]) & (s[p] <= '9') DO
            e := e * 10 + ORD(s[p]) - ORD('0');
            INC(p)
          END;
          IF negE THEN y := y / Ten(e) ELSE y := y * Ten(e) END;
        END
      END;
      IF neg THEN y := -y END;
      Done := TRUE
    END
  END ;
RETURN y END LongVal;

PROCEDURE Val*(IN s: ARRAY OF CHAR): REAL;
VAR y: LONGREAL;
BEGIN
  RETURN SHORT(LongVal(s))
END Val;

BEGIN Done := TRUE
END Reals.
