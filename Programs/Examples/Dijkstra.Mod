MODULE Dijkstra;
IMPORT Out;
VAR x, y: INTEGER;
BEGIN
  x := 50; y := 15;
  WHILE x > y DO DEC(x, y)
  ELSIF x < y DO DEC(y, x)
  END;
  Out.Int(x, 0); Out.Ln
END Dijkstra.
