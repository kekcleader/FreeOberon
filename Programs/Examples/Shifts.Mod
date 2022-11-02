MODULE Shifts;
IMPORT Out;
VAR n: INTEGER;
BEGIN
  n := 7;
  n := LSL(n, 31);
  Out.Int(n, 0); Out.Ln
END Shifts.