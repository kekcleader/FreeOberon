MODULE types;

IMPORT SYSTEM;

TYPE
  (* Int32* = ARRAY 4 OF SYSTEM.BYTE; *)
  Int16* = ARRAY 2 OF SYSTEM.BYTE;
     
  PROCEDURE IntegerToInt16*(int: INTEGER; VAR int16: Int16);
  TYPE PInt16 = POINTER TO Int16;
  VAR p: PInt16;
  BEGIN
    (* Note: We take the least significant 16 bits of int, which 
       is correct on supported (i.e. little-endian) architectures. *)
    p := SYSTEM.VAL(PInt16, SYSTEM.ADR(int)); 
    int16 := p^;
  END IntegerToInt16;

  PROCEDURE htons*(in: Int16; VAR out : Int16);
  BEGIN
    out[0] := in[1];
    out[1] := in[0];
  END htons;

END types.
