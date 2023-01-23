MODULE Time;
IMPORT Platform;

PROCEDURE GetClock*(VAR time, date: INTEGER);
BEGIN
  Platform.GetClock(time, date)
END GetClock;

PROCEDURE GetTime*(VAR Y, M, D, h, m, s: INTEGER);
VAR t, d: INTEGER;
BEGIN
  GetClock(t, d);
  Y := ASR(d, 9) MOD 100;
  M := (ASR(d, 5) - 1) MOD 12 + 1;
  D := d MOD 20H;

  h := ASR(t, 12) MOD 10H;
  m := ASR(t, 6) MOD 40H;
  s := t MOD 40H
END GetTime;

END Time.
