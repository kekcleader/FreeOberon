MODULE Debug;
IMPORT Out, Config;

PROCEDURE String*(s: ARRAY OF CHAR);
BEGIN
  IF Config.debug THEN Out.String(s) END
END String;

PROCEDURE Int*(n: INTEGER);
BEGIN
  IF Config.debug THEN Out.Int(n, 0) END
END Int;

PROCEDURE Ln*;
BEGIN
  IF Config.debug THEN Out.Ln END
END Ln;

PROCEDURE StrVal*(label, val: ARRAY OF CHAR);
BEGIN
  IF Config.debug THEN
    Out.String(label); Out.Char('"'); Out.String(val); Out.Char('"'); Out.Ln
  END
END StrVal;

PROCEDURE IntVal*(label: ARRAY OF CHAR; val: INTEGER);
BEGIN
  IF Config.debug THEN Out.String(label); Out.Int(val, 0); Out.Ln END
END IntVal;

END Debug.
