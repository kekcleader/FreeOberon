MODULE AAA;
IMPORT Out;
VAR x: INTEGER;
BEGIN
  IF x > 0 & x < 10 THEN
  Out.String('HELLO');
  x := 6;
  x := x + 1
END AAA.