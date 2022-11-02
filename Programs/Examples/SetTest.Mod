MODULE SetTest;
IMPORT In, Out, SYSTEM;

PROCEDURE BITS(n: INTEGER): SET;
RETURN SYSTEM.VAL(SET, n) END BITS;

PROCEDURE Do;
VAR n: INTEGER;
  s, q: SET;
BEGIN
  Out.String('Введите число: '); In.Int(n);
  s := BITS(n);
  q := BITS(n - 1);
  IF s - (s - q) = {} THEN
    Out.String('Степень двойки.')
  ELSE
    Out.String('Не степень двойки.')
  END;
  Out.Ln
END Do;

BEGIN
  Do
END SetTest.