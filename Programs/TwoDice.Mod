MODULE TwoDice;
IMPORT Random, Out;
CONST
  step = 1000;
  eps = 1.0E-6;
TYPE
  Result = ARRAY 13 OF REAL;

PROCEDURE Finish(old, new: Result): BOOLEAN;
VAR i: INTEGER;
BEGIN
  i := 2;
  WHILE (i # 13) & (ABS(old[i] - new[i]) / new[i] <= eps) DO
    INC(i)
  END
RETURN i = 13 END Finish;

PROCEDURE Do;
VAR counter: ARRAY 13 OF INTEGER;
  freq0, freq: Result;
  i, n, a: INTEGER;
  sum: REAL;
BEGIN
  FOR i := 2 TO 12 DO
    counter[i] := 0;
    freq[i] := 0.0
  END;
  n := 0;

  REPEAT
    FOR i := 1 TO step DO
      a := 2 + Random.Int(6) + Random.Int(6);
      INC(counter[a]);
      INC(n)
    END;
    FOR i := 2 TO 12 DO
      freq0[i] := freq[i];
      freq[i] := counter[i] / n
    END
  UNTIL Finish(freq0, freq);

  sum := 0.0;
  FOR i := 2 TO 12 DO
    sum := sum + freq[i];
    Out.Int(i, 2); Out.String(') ');
    Out.RealFix(freq[i], 0, 4); Out.Ln
  END;
  Out.String('Сумма ');
  Out.RealFix(sum, 0, 4); Out.Ln
END Do;

BEGIN
  Do
END TwoDice.