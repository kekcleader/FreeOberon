MODULE Time;
IMPORT Platform;

PROCEDURE GetClock*(VAR time, date: INTEGER);
BEGIN
  Platform.GetClock(time, date)
END GetClock;

END Time.
