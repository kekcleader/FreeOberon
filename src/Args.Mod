MODULE Args;
IMPORT CmdArgs, Int, Utf8;

TYPE SHORTCHAR = Utf8.SHORTCHAR;
VAR Count*: INTEGER;

PROCEDURE Get*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR q: ARRAY 4096 OF SHORTCHAR;
BEGIN CmdArgs.Get(n, q); Utf8.Decode(q, s)
END Get;

PROCEDURE GetInt*(n: INTEGER; VAR i: INTEGER);
VAR s: ARRAY 30 OF CHAR;
  ok: BOOLEAN;
BEGIN Get(n, s); i := Int.ValEx(s, ok);
  IF ~ok THEN i := 0 END
END GetInt;

BEGIN Count := CmdArgs.Count
END Args.
