MODULE Time;
IMPORT Platform, Int;

TYPE Time* = INTEGER;

PROCEDURE Timestamp*(): Time;
RETURN Platform.Time() END Timestamp;

PROCEDURE GetClock*(VAR time, date: INTEGER);
BEGIN
  Platform.GetClock(time, date)
END GetClock;

PROCEDURE GetDateTime*(VAR Y, M, D, h, m, s: INTEGER);
VAR t, d: INTEGER;
BEGIN
  GetClock(t, d);
  Y := ASR(d, 9) MOD 100;
  M := (ASR(d, 5) - 1) MOD 12 + 1;
  D := d MOD 20H;

  h := ASR(t, 12) MOD 10H;
  m := ASR(t, 6) MOD 40H;
  s := t MOD 40H
END GetDateTime;

PROCEDURE GetDate*(VAR Y, M, D: INTEGER);
VAR h, m, s: INTEGER;
BEGIN GetDateTime(Y, M, D, h, m, s); INC(Y, 2000)
END GetDate;

PROCEDURE GetTime*(VAR h, m, s: INTEGER);
VAR Y, M, D: INTEGER;
BEGIN GetDateTime(Y, M, D, h, m, s)
END GetTime;

PROCEDURE GetDateStr*(VAR s: ARRAY OF CHAR);
VAR Y, M, D, i, n: INTEGER;
  m: ARRAY 16 OF CHAR;
BEGIN
  IF LEN(s) < 11 THEN s[0] := 0X
  ELSE
    GetDate(Y, M, D);
    Int.Str(Y, s); s[4] := '-';
    s[5] := CHR(ORD('0') + M DIV 10);
    s[6] := CHR(ORD('0') + M MOD 10);
    s[7] := '-';
    s[8] := CHR(ORD('0') + D DIV 10);
    s[9] := CHR(ORD('0') + D MOD 10);
    s[10] := 0X
  END
END GetDateStr;

END Time.
