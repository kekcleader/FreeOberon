MODULE compatIn;
(* module created to compile Make utility from Trianus v4 system with less changes in original file ; -- noch *)
IMPORT Args, IntStr := oocIntStr;

VAR Done* : BOOLEAN;
    argnum : INTEGER;

PROCEDURE Open*;
BEGIN
   argnum := 0;
   Done := FALSE;
END Open;

PROCEDURE Name*(VAR name : ARRAY OF CHAR);
BEGIN
INC(argnum);

IF argnum < Args.argc THEN 
   Args.Get(argnum, name);
   Done := TRUE
ELSE
   Done := FALSE
END
END Name;

PROCEDURE Int*(VAR i : INTEGER);
VAR l : LONGINT;
    r : IntStr.ConvResults;
    name : ARRAY 32 OF CHAR;
BEGIN
INC(argnum);

IF argnum < Args.argc THEN
   Args.Get(argnum, name);
   IntStr.StrToInt(name, l, r);
   IF r = IntStr.strAllRight THEN
      i := SHORT(l);
      Done := TRUE
   ELSE
      Done := FALSE
   END
ELSE
   Done := FALSE;
END   
END Int;


BEGIN
   Open();
END compatIn.
