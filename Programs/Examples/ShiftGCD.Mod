MODULE ShiftGCD;
IMPORT In, Out;
CONST maxN = 100;
VAR m: ARRAY maxN OF INTEGER;
  N, K: INTEGER;
  Z: INTEGER;

PROCEDURE Show;
VAR i: INTEGER;
  s: ARRAY 10 OF CHAR;
BEGIN
  FOR i := 0 TO N - 1 DO Out.Int(m[i], 3) END; Out.Ln;
  IF Z = 19 THEN Z := 0;
    Out.String('Нажмите клавишу [Ввод] для продолжения. . . ');
    In.Line(s)
  ELSE INC(Z)
  END
END Show;

PROCEDURE Shift;
VAR i, i2, stop, tmp, count: INTEGER;
BEGIN
  Show;
  i := 0; count := 0;
  WHILE count # N DO
    stop := i; tmp := m[i];   (*   0 -> 10 -> 5 -> 0 *)
    i2 := (i + K) MOD N;
    WHILE i2 # stop DO
      m[i] := m[i2]; INC(count);
      i := i2;
      i2 := (i + K) MOD N
    END;
    m[i] := tmp; INC(count);
    INC(i);
    Show
  END
END Shift;

PROCEDURE Do;
VAR i: INTEGER;
BEGIN
  Out.String('Программа циклически сдвигает массив влево на K элементов.'); Out.Ln;
  Out.String('Введите N - длину массива: '); In.Int(N);
  Out.String('Введите K: '); In.Int(K);
  FOR i := 0 TO N - 1 DO m[i] := i END;
  Z := 0;
  Shift
END Do;

BEGIN
  Do
END ShiftGCD.