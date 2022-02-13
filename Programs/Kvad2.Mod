MODULE Kvad2;
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
      Out.Real(D, 30); Out.Ln;
      D := Math.sqrt(D);
      Out.Real(a, 16); Out.Ln;
      Out.Real(b, 16); Out.Ln;
      Out.Real(c, 16); Out.Ln;
      Out.Real(D, 30); Out.Ln;
      Out.String('ЧТО ЗА     : ');
      Out.Real((- 0.0 - D) / (2.0 * 4.0), 30); Out.Ln;
      Out.String('ЧТО ЗА     : ');
      Out.Real((- 0.0 - 8.0) / (2.0 * 4.0), 30); Out.Ln;
      Out.String('Два решения: ');
      Out.Real((- b - D) / (2.0 * a), 16); Out.Ln;
      Out.Int(FLOOR((- b - D) / (2.0 * a)), 0); Out.Ln;
      Out.String('             ');
      Out.Real((- b + D) / (2.0 * a), 16);
      Out.Ln; Out.Int(FLOOR((- b + D) / (2.0 * a)), 0); Out.Ln;
    ELSE
      Out.String('Единственное решение: ');
      Out.Real(-0.5 * b / a, 16)
    END
  ELSE (* a = 0 *)
    IF b # 0.0 THEN
      Out.String('Единственное решение: ');
      Out.Real(-c / b, 16)
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
END Kvad2.