MODULE Env;
IMPORT CmdArgs, Platform, Utf8;
TYPE SHORTCHAR = Utf8.SHORTCHAR;

VAR count: INTEGER;

PROCEDURE Count*(): INTEGER;
BEGIN
  IF count = -1 THEN count := CmdArgs.GetEnvCount() END
RETURN count END Count;

PROCEDURE Get*(n: INTEGER; VAR s: ARRAY OF CHAR);
VAR q: ARRAY 10240 OF SHORTCHAR;
BEGIN
  IF (0 <= n) & (n < Count()) THEN
    CmdArgs.GetEnvN(n, q); Utf8.Decode(q, s)
  ELSE s := ''
  END
END Get;

PROCEDURE GetByName*(name: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
VAR q: ARRAY 10240 OF SHORTCHAR;
  z: ARRAY 1024 OF SHORTCHAR;
BEGIN Utf8.Encode(name, z); CmdArgs.GetEnv(z, q); Utf8.Decode(q, val)
END GetByName;

PROCEDURE GetAppDir*(VAR s: ARRAY OF CHAR);
VAR c, delim: CHAR;
  i: INTEGER;
BEGIN
  GetByName('_', s);
  s[LEN(s) - 1] := 0X;

  i := 0; WHILE s[i] # 0X DO INC(i) END;

  IF Platform.Windows THEN delim := '\' ELSE delim := '/' END;

  c := s[0]; s[0] := delim;
  REPEAT DEC(i) UNTIL s[i] = delim;
  s[0] := c;

  s[i + 1] := 0X
END GetAppDir;

BEGIN
  count := -1
END Env.
