MODULE Debug;
(** Module for Free Oberon's debug output. The output goes to console.
     The procedures only output text if Config.debug is TRUE. *)
IMPORT Out, Config;

(** Output a string. Does not output a new line. *)
PROCEDURE String*(s: ARRAY OF CHAR);
BEGIN
  IF Config.debug THEN Out.String(s) END
END String;

(** Output an integer. Does not output a new line. *)
PROCEDURE Int*(n: INTEGER);
BEGIN
  IF Config.debug THEN Out.Int(n, 0) END
END Int;

(** Output a new line character. *)
PROCEDURE Ln*;
BEGIN
  IF Config.debug THEN Out.Ln END
END Ln;

(** Outputs the two given strings. The second string is enclosed in double
    quotes when output.
     Example:
     label = 'Text: ', val = 'ABC'.
     Output:
      Text: ABC *)
PROCEDURE StrVal*(label, val: ARRAY OF CHAR);
BEGIN
  IF Config.debug THEN
    Out.String(label); Out.Char('"'); Out.String(val); Out.Char('"'); Out.Ln
  END
END StrVal;

(** Same as StrVal, but `val` is an integer. *)
PROCEDURE IntVal*(label: ARRAY OF CHAR; val: INTEGER);
BEGIN
  IF Config.debug THEN Out.String(label); Out.Int(val, 0); Out.Ln END
END IntVal;

END Debug.
