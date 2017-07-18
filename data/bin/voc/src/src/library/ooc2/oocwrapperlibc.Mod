MODULE oocwrapperlibc;
IMPORT SYSTEM;
PROCEDURE -includeStdio()
   "#include <stdio.h>";

PROCEDURE -sys(str: ARRAY OF CHAR): INTEGER
   "system(str)";

PROCEDURE system*(cmd : ARRAY OF CHAR);
VAR r : INTEGER;
BEGIN
r := sys(cmd);
END system;
(*
PROCEDURE strtod* (string: C.address;
                   VAR tailptr: C.charPtr1d): C.double;
PROCEDURE strtof* (string: C.address;
                   VAR tailptr: C.charPtr1d): C.float;
PROCEDURE sscanf* (s: C.address; template: ARRAY OF CHAR; ...) : C.int;
*)

PROCEDURE -sprntf(s, t0, t1, t2: ARRAY OF CHAR): INTEGER
   "sprintf(s, t0, t1, t2)";

PROCEDURE sprintf* (VAR s: ARRAY OF CHAR; template0: ARRAY OF CHAR; template1: ARRAY OF CHAR; template2: ARRAY OF CHAR);
VAR r : INTEGER;
BEGIN
   r := sprntf (s, template0, template1, template2);
END sprintf;

BEGIN


END oocwrapperlibc.
