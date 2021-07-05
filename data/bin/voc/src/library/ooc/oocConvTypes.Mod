(*	$Id: ConvTypes.Mod,v 1.1 1997/02/07 07:45:32 oberon1 Exp $	*)
MODULE oocConvTypes;
 
  (* Common types used in the string conversion modules *)
 
TYPE
  ConvResults*= SHORTINT;    (* Values of this type are used to express the format of a string *)

CONST
  strAllRight*=0;    (* the string format is correct for the corresponding conversion *)
  strOutOfRange*=1;  (* the string is well-formed but the value cannot be represented *)
  strWrongFormat*=2; (* the string is in the wrong format for the conversion *)
  strEmpty*=3;       (* the given string is empty *)


TYPE
  ScanClass*= SHORTINT; (* Values of this type are used to classify input to finite state scanners *)
  
CONST
    padding*=0;    (* a leading or padding character at this point in the scan - ignore it *)
    valid*=1;      (* a valid character at this point in the scan - accept it *)
    invalid*=2;    (* an invalid character at this point in the scan - reject it *)
    terminator*=3; (* a terminating character at this point in the scan (not part of token) *)


TYPE
  ScanState*=POINTER TO ScanDesc; 
  ScanDesc*=  (* The type of lexical scanning control procedures *)
    RECORD
      p*: PROCEDURE (ch: CHAR; VAR cl: ScanClass; VAR st: ScanState);
    END;
 
END oocConvTypes.
