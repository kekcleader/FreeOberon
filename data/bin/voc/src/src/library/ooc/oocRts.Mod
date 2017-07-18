MODULE oocRts;  (* module is written from scratch by noch to wrap around Unix.Mod and Args.Mod and provide compatibility for some ooc libraries *)
IMPORT Args, Platform, Files, Strings := oocStrings(*, Console*);
CONST
  pathSeperator* = "/";

VAR 
  i:    INTEGER;
  b:    BOOLEAN;
  str0: ARRAY 128 OF CHAR;

PROCEDURE System* (command : ARRAY OF CHAR) : INTEGER;
(* Executes `command' as a shell command.  Result is the value returned by 
   the libc `system' function. *)
BEGIN RETURN Platform.System(command) END System;

PROCEDURE GetEnv* (VAR var: ARRAY OF CHAR; name: ARRAY OF CHAR): BOOLEAN;
(* If an environment variable `name' exists, copy its value into `var' and
   return TRUE.  Otherwise return FALSE.  *)
BEGIN RETURN Platform.getEnv(name, var) END GetEnv;


PROCEDURE GetUserHome* (VAR home: ARRAY OF CHAR; user: ARRAY OF CHAR);
(* Get the user's home directory path (stored in /etc/passwd)
   or the current user's home directory if user="". *)
VAR 
  f : Files.File;
  r : Files.Rider;
  str, str1 : ARRAY 1024 OF CHAR;
  found, found1 : BOOLEAN;
  p, p1, p2 : INTEGER;
BEGIN
  f := Files.Old("/etc/passwd");
  Files.Set(r, f, 0);

  REPEAT
    Files.ReadLine(r, str);
    (* Console.String(str); Console.Ln;*)
    Strings.Extract(str, 0, SHORT(LEN(user)-1), str1);
    (* Console.String(str1); Console.Ln;*)
    found := Strings.Equal(user, str1)
  UNTIL found OR r.eof;

  IF found THEN
    found1 := FALSE;
    Strings.FindNext(":", str, SHORT(LEN(user)), found1, p); p2 := p + 1;
    Strings.FindNext(":", str, p2, found1, p); p2 := p + 1;
    Strings.FindNext(":", str, p2, found1, p); p2 := p + 1;
    Strings.FindNext(":", str, p2, found1, p); p2 := p + 1;
    Strings.FindNext(":", str, p2, found1, p1);
    Strings.Extract(str,p+1,p1-p-1, home);
    (*Console.String(home); Console.Ln;*)
  ELSE
    (* current user's home *)
    found1 := GetEnv(home, "HOME");
    (*Console.String("not found"); Console.Ln; Console.String (home); Console.Ln;*)
  END
END GetUserHome;

BEGIN
  (* test *)
  (* 
    i := System("ls");
    b := GetEnv(str0, "HOME");
    IF b THEN Console.String(str0); Console.Ln END;
    GetUserHome(str0, "noch");
  *)
END oocRts.
