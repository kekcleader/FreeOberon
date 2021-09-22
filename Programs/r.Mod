MODULE r;
IMPORT In, Out;
VAR a, b, c: INTEGER;
  x, y: REAL;
  s: ARRAY 10 OF CHAR;
  i: INTEGER;
BEGIN
  s := 'Привет!';
  s[2] := 'ы';
  Out.String(s);
  Out.Char('Ж');
  Out.Ln;

  Out.String('Please enter a real number.'); Out.Ln;
  Out.String('x='); In.Real(x);
  Out.String('['); Out.RealFix(x, 8, 3); Out.String(']'); Out.Ln;
  Out.String('Enter string:'); In.Line(s);
  Out.String('{'); Out.String(s); Out.String('}'); Out.Ln;
  i := 0;
  WHILE (i < LEN(s)) & (ORD(s[i]) # 0) DO
    Out.Int(ORD(s[i]), 5); INC(i)
  END; Out.Ln;
  Out.String('Bye!'); Out.Ln
END r.
