MODULE Tetragon;
IMPORT T := TermBox, Out, Random, Kernel;

VAR W, H: INTEGER;

PROCEDURE Draw;
BEGIN
  T.ClearTo(11, 3);
END Draw;

PROCEDURE Run;
VAR e: T.Event;
  done: BOOLEAN;
BEGIN done := FALSE;
  Draw;
  T.Flush;
  REPEAT
    T.WaitEvent(e);
    IF e.type = T.mouse THEN
    ELSIF e.type = T.key THEN
    ELSIF e.type = T.resize THEN T.Size(W, H)
    ELSIF e.type = T.quit THEN done := TRUE
    END
  UNTIL done
END Run;

PROCEDURE InitVars;
BEGIN

END InitVars;

BEGIN
  T.Init;
  T.Size(W, H);
  InitVars;
  Run;
  T.Close
END Tetragon.
