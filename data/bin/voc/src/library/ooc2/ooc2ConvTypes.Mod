(*	$Id: ConvTypes.Mod,v 1.1 2002/05/10 22:25:18 mva Exp $	*)
MODULE ooc2ConvTypes;
(**Common types used in the string conversion modules.  *)
 
TYPE
  ConvResults*= SHORTINT;
  (**Values of this type are used to express the format of a string.  *)

CONST
  strAllRight*=0;
  (**The string format is correct for the corresponding conversion.  *)
  strOutOfRange*=1;
  (**The string is well-formed but the value cannot be represented.  *)
  strWrongFormat*=2;
  (**The string is in the wrong format for the conversion.  *)
  strEmpty*=3;
  (**The given string is empty.  *)


TYPE
  ScanClass*= SHORTINT;
  (**Values of this type are used to classify input to finite state scanners.  *)
  
CONST
  padding*=0;
  (**A leading or padding character at this point in the scan---ignore it. *)
  valid*=1;
  (**A valid character at this point in the scan---accept it.  *)
  invalid*=2;
  (*An invalid character at this point in the scan---reject it *)
  terminator*=3;
  (**A terminating character at this point in the scan (not part of token).  *)


TYPE
  ScanState*=POINTER TO ScanDesc; 
  ScanDesc*=RECORD
    (**The type of lexical scanning control procedures.  *)
    p*: PROCEDURE (ch: CHAR; VAR cl: ScanClass; VAR st: ScanState);
    (**A procedure that produces the next state corresponding to the
       character @var{ch}.  The class of the character is returned
       in @var{cl}, the next state in @var{st}.  *)
  END;
 
END ooc2ConvTypes.
