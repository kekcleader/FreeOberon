MODULE oocwrapperlibc;
IMPORT SYSTEM, Platform;


PROCEDURE -includeStdio()  "#include <stdio.h>";

PROCEDURE system*(cmd : ARRAY OF CHAR); 
VAR r: INTEGER;
BEGIN 
  r := Platform.System(cmd) 
END system;


PROCEDURE -sprntf(s, t0, t1, t2: ARRAY OF CHAR): INTEGER
   "sprintf((char*)s, (char*)t0, (char*)t1, (char*)t2)";

PROCEDURE sprintf*(VAR s: ARRAY OF CHAR; template0: ARRAY OF CHAR; template1: ARRAY OF CHAR; template2: ARRAY OF CHAR);
VAR r : INTEGER;
BEGIN
  r := sprntf(s, template0, template1, template2);
END sprintf;

END oocwrapperlibc.
