(*	$Id: Ascii.Mod,v 1.1 1997/02/07 07:45:32 oberon1 Exp $	*)
MODULE oocAscii;  (* Standard short character names for control chars.  *)

CONST
  nul* = 00X;   soh* = 01X;   stx* = 02X;   etx* = 03X;
  eot* = 04X;   enq* = 05X;   ack* = 06X;   bel* = 07X;
  bs * = 08X;   ht * = 09X;   lf * = 0AX;   vt * = 0BX;
  ff * = 0CX;   cr * = 0DX;   so * = 0EX;   si * = 0FX;
  dle* = 01X;   dc1* = 11X;   dc2* = 12X;   dc3* = 13X;
  dc4* = 14X;   nak* = 15X;   syn* = 16X;   etb* = 17X;
  can* = 18X;   em * = 19X;   sub* = 1AX;   esc* = 1BX;
  fs * = 1CX;   gs * = 1DX;   rs * = 1EX;   us * = 1FX;
  del* = 7FX;

CONST  (* often used synonyms *)
  sp *  = " ";
  xon*  = dc1;
  xoff* = dc3;
  
END oocAscii.
