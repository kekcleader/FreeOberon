MODULE ATest;
IMPORT In, Out;
VAR i, j, n: INTEGER;
BEGIN
  Out.String('Введите число: ');
  In.Int(n);
  FOR i := 1 TO n MOD 20 + 5 DO
    FOR j := 1 TO 1 + i MOD 40 DO Out.Int(i, 5) END;
    Out.Ln
  END;
  Out.String('конец.'); Out.Ln
END ATest.