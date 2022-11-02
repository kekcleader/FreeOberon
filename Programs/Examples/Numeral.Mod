MODULE Numeral;
IMPORT In, Out;

PROCEDURE Digit(c: CHAR; P: INTEGER): INTEGER;
VAR d: INTEGER;
BEGIN
  IF ('0' <= c) & (c <= '9') THEN d := ORD(c) - ORD('0')
  ELSIF ('a' <= c) & (c <= 'z') THEN d := ORD(c) - ORD('a') + 10
  ELSIF ('A' <= c) & (c <= 'Z') THEN d := ORD(c) - ORD('A') + 10
  ELSE d := -1
  END;
  IF d >= P THEN d := -1 END
RETURN d END Digit;

PROCEDURE Convert(s: ARRAY OF CHAR; P: INTEGER; VAR err: INTEGER): INTEGER;
VAR d, x, i: INTEGER;
BEGIN
  err := -1;
  x := 0;
  i := 0;
  WHILE (err = -1) & (s[i] # 0X) DO
    d := Digit(s[i], P);
    IF d = -1 THEN err := i ELSE x := x * P + d END;
    INC(i)
  END
RETURN x END Convert;

PROCEDURE Do;
VAR P, n, err: INTEGER;
  s: ARRAY 50 OF CHAR;
BEGIN
  Out.String('Введите P: '); In.Int(P);
  Out.String('Введите число в '); Out.Int(P, 0);
  Out.String('-ичной системе счисления: '); In.Line(s);
  n := Convert(s, P, err);
  IF err = -1 THEN
    Out.String('Число в десятичной системе: '); Out.Int(n, 0)
  ELSE
    Out.String('Введённое число имет неверный знак в ');
    Out.Int(err + 1, 0); Out.String('-м слева разряде.')
  END;
  Out.Ln
END Do;

BEGIN
  Do
END Numeral.
