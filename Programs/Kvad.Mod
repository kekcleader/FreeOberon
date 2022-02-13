MODULE Kvad;
IMPORT In, Out, Math;

PROCEDURE Do;
VAR a, b, c, D: REAL;
BEGIN
  Out.String('Решаем уравнение ax^2 + bx + c = 0'); Out.Ln;
  Out.String('Введите a: '); In.Real(a);
  Out.String('  Введите b: '); In.Real(b);
  Out.String('    Введите c: '); In.Real(c);
  IF a # 0.0 THEN
    D := b * b - 4.0 * a * c;
    IF D < 0.0 THEN
      Out.String('Нет решений')
    ELSIF D > 0.0 THEN
      D := Math.sqrt(D);
      Out.String('Два решения: ');
      Out.RealFix((- b - D) / (2.0 * a), 0, 6); Out.Ln;
      Out.String('             ');
      Out.RealFix((- b + D) / (2.0 * a), 0, 6); Out.Ln
    ELSE
      Out.String('Единственное решение: ');
      Out.RealFix(-0.5 * b / a, 0, 6)
    END
  ELSE (* a = 0 *)
    IF b # 0.0 THEN
      Out.String('Единственное решение: ');
      Out.RealFix(-c / b, 0, 6)
    ELSE (* a = b = 0 *)
      IF c # 0.0 THEN
        Out.String('Нет решений');
      ELSE
        Out.String('x - любое число')
      END
    END
  END;
  Out.Ln
END Do;

BEGIN
  Do
END Kvad.