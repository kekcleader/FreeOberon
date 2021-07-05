MODULE clb;

IMPORT Console;

TYPE OnSomething = PROCEDURE (x, y: INTEGER);

PROCEDURE ProcessEvents(x, y: INTEGER; onsomething: OnSomething);
BEGIN
  IF onsomething # NIL THEN
    onsomething(x, y)
  ELSE
    Console.String("didn't happen"); Console.Ln
  END
END ProcessEvents;


PROCEDURE OnEvent(x, y : INTEGER);
BEGIN
  Console.String("event happened"); Console.Ln
END OnEvent;

PROCEDURE OnEvent2(x, y : INTEGER);
BEGIN
  Console.String("event 2 happened"); Console.Ln
END OnEvent2;

PROCEDURE Something;
  VAR onsmth: OnSomething;
BEGIN
   onsmth := NIL;
   ProcessEvents(0, 0, onsmth);

   onsmth := OnEvent;
   ProcessEvents(0, 0, onsmth);
END Something;

BEGIN
  Something;
  (*
  ProcessEvents(0, 0, NIL);
  ProcessEvents(0, 0, OnEvent);
  ProcessEvents(0, 0, OnEvent2);
  *)
END clb.
