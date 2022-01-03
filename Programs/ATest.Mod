MODULE ATest;
IMPORT In, Out;
VAR i, j, n: INTEGER;
BEGIN
  Out.String('CCCP'); Out.Ln;
  In.Int(n);
  FOR i := 1 TO n DO
    FOR j := 1 TO 1 + i MOD 40 DO Out.Int(i, 5) END;
    Out.Ln
  END;
  Out.Char('.'); Out.Ln;
END ATest.