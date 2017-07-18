MODULE aa;
IMPORT Console;

CONST teststring = "1st 10 ch 2nd 10 ch 3rd 10 ch";

VAR
  a30: ARRAY 30 OF CHAR;

  a10: ARRAY 10 OF CHAR;
  a20: ARRAY 20 OF CHAR;

  buf: ARRAY 64 OF CHAR;


BEGIN
  a30 := teststring; Console.String("a30: "); Console.String(a30); Console.Ln;
  COPY(a30, a20);    Console.String("a20: "); Console.String(a20); Console.Ln;
  Console.Ln;
  COPY(a30, a10);    Console.String("a10: "); Console.String(a10); Console.Ln;
                     Console.String("a20: "); Console.String(a20); Console.Ln;
  Console.Ln;
  Console.String("Array assignment test complete."); Console.Ln;
END aa.
