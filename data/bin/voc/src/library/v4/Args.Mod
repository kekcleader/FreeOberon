MODULE Args;  (* jt, 8.12.94 *)

  (* command line argument handling for voc (jet backend) *)


  IMPORT Platform, Modules, SYSTEM;

  TYPE
    ArgPtr = POINTER TO ARRAY 1024 OF CHAR;
    ArgVec = POINTER TO ARRAY 1024 OF ArgPtr;

  VAR
    argc-: INTEGER;
    argv-: SYSTEM.ADDRESS;


PROCEDURE Get*   (n: INTEGER; VAR val: ARRAY OF CHAR); BEGIN Modules.GetArg(n, val)    END Get;
PROCEDURE GetInt*(n: INTEGER; VAR val: LONGINT);       BEGIN Modules.GetIntArg(n, val) END GetInt;
PROCEDURE Pos*   (s: ARRAY OF CHAR): INTEGER;          BEGIN RETURN Modules.ArgPos(s)  END Pos;

PROCEDURE GetEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
BEGIN Platform.GetEnv(var, val) END GetEnv;

PROCEDURE getEnv*(var: ARRAY OF CHAR; VAR val: ARRAY OF CHAR): BOOLEAN;
BEGIN RETURN Platform.getEnv(var, val) END getEnv;


BEGIN
  argc := Modules.ArgCount;
  argv := Modules.ArgVector;
END Args.
