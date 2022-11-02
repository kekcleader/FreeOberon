MODULE TestReal;
IMPORT In, Out, Reals;
TYPE LONGREAL = Reals.LONGREAL;
VAR a, b, c: INTEGER;
  x, y: LONGREAL;
  s: ARRAY 10 OF CHAR;
  i, j: INTEGER;

PROCEDURE R(x: LONGREAL; n: INTEGER);
BEGIN
  Out.String(' Out.LongReal(x, ');
  Out.Int(n, 2); Out.String(') = "');
  Out.LongReal(x, n); Out.Char('"'); Out.Ln
END R;

PROCEDURE RF(x: LONGREAL; n, k: INTEGER);
BEGIN
  Out.String(' Out.LongRealFix(x, ');
  Out.Int(n, 2); Out.String(', '); Out.Int(k, 2);
  Out.String(') = "'); Out.LongRealFix(x, n, k); Out.Char('"'); Out.Ln
END RF;

BEGIN
  x := 0.9999999;
  Out.String('Please enter a real number: '); In.LongReal(x);
  FOR i := 0 TO 35 DO
    R(x, i)
  END;
  FOR i := 0 TO 18 BY 6 DO
    FOR j := 0 TO 3 DO
      RF(x, i, j)
    END;
    RF(x, i, 20)
  END
END TestReal.
