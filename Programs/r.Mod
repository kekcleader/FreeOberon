MODULE r;
IMPORT In, Out;
VAR a, b, c: INTEGER;
  x, y: REAL;
  s: ARRAY 32 OF CHAR;
BEGIN
  Out.String('Please enter a real number.'); Out.Ln;
  Out.String('x='); In.Real(x);
  Out.String('['); Out.RealFix(x, 0, 10); Out.String(']'); Out.Ln;
  Out.String('Enter string:'); In.Line(s);
  Out.String('{'); Out.String(s); Out.String('}'); Out.Ln;
  Out.String('Bye!'); Out.Ln
END r.
