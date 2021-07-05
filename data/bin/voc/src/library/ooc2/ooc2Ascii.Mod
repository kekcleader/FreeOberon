(*	$Id: Ascii.Mod,v 1.2 2003/01/04 10:19:19 mva Exp $	*)
MODULE ooc2Ascii;
(*  Standard short character names for control chars.
    Copyright (C) 2002  Michael van Acken

    This module is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License
    as published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with OOC. If not, write to the Free Software Foundation,
    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)

CONST
  nul* = 00X;   soh* = 01X;   stx* = 02X;   etx* = 03X;
  eot* = 04X;   enq* = 05X;   ack* = 06X;   bel* = 07X;
  bs * = 08X;   ht * = 09X;   lf * = 0AX;   vt * = 0BX;
  ff * = 0CX;   cr * = 0DX;   so * = 0EX;   si * = 0FX;
  dle* = 10X;   dc1* = 11X;   dc2* = 12X;   dc3* = 13X;
  dc4* = 14X;   nak* = 15X;   syn* = 16X;   etb* = 17X;
  can* = 18X;   em * = 19X;   sub* = 1AX;   esc* = 1BX;
  fs * = 1CX;   gs * = 1DX;   rs * = 1EX;   us * = 1FX;
  del* = 7FX;

CONST  (* often used synonyms *)
  sp *  = " ";
  xon*  = dc1;
  xoff* = dc3;
  
END ooc2Ascii.
