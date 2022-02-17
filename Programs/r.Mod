MODULE r;
IMPORT In, Out;
VAR a, b, c: INTEGER;
  x, y: REAL;
  s: ARRAY 10 OF CHAR;
  i, j: INTEGER;

PROCEDURE R(x: REAL; n: INTEGER);
BEGIN
  Out.String(' Out.Real(x, ');
  Out.Int(n, 0); Out.String(') = "');
  Out.Real(x, n); Out.Char('"'); Out.Ln
END R;

PROCEDURE RF(x: REAL; n, k: INTEGER);
BEGIN
  Out.String(' Out.RealFix(x, ');
  Out.Int(n, 0); Out.String(', '); Out.Int(k, 0);
  Out.String(') = "'); Out.RealFix(x, n, k); Out.Char('"'); Out.Ln
END RF;

BEGIN
  Out.String('Please enter a real number: '); In.Real(x);
  FOR i := 0 TO 15 DO
    R(x, i)
  END;
  FOR i := 0 TO 18 BY 6 DO
    FOR j := 0 TO 3 DO
      RF(x, i, j)
    END;
    RF(x, i, 6)
  END

  (*
  Out.String('Enter string:'); In.Line(s);
  Out.String('{'); Out.String(s); Out.String('}'); Out.Ln;
  i := 0;
  WHILE (i < LEN(s)) & (ORD(s[i]) # 0) DO
    Out.Int(ORD(s[i]), 5); INC(i)
  END; Out.Ln;
  Out.String('Bye!'); Out.Ln
  *)
END r.
