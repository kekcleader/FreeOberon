(*	$Id: IntStr.Mod,v 1.1 2002/05/12 21:58:14 mva Exp $	*)
MODULE ooc2IntStr;
(*  IntStr - Integer-number/string conversions.       
    Copyright (C) 1995 Michael Griebling
 
    This module is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.
 
    This module is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)
  
IMPORT
  Conv := ooc2ConvTypes, IntConv := ooc2IntConv;
 
TYPE
  ConvResults*= Conv.ConvResults; 
  (**One of @oconst{strAllRight}, @oconst{strOutOfRange},
     @oconst{strWrongFormat}, or @oconst{strEmpty}.  *)

CONST
  strAllRight*=Conv.strAllRight;
  (**The string format is correct for the corresponding conversion.  *)
  strOutOfRange*=Conv.strOutOfRange;
  (**The string is well-formed but the value cannot be represented.  *)
  strWrongFormat*=Conv.strWrongFormat;
  (**The string is in the wrong format for the conversion.  *)
  strEmpty*=Conv.strEmpty;
  (**The given string is empty.  *)
 
 
(* the string form of a signed whole number is
     ["+" | "-"] decimal_digit {decimal_digit}
*)
 
PROCEDURE StrToInt*(str: ARRAY OF CHAR; VAR int: LONGINT; VAR res: ConvResults);
(**Converts string to integer value.  Ignores any leading spaces in
   @oparam{str}.  If the subsequent characters in @oparam{str} are in the
   format of a signed whole number, assigns a corresponding value to
   @oparam{int}.  Assigns a value indicating the format of @oparam{str} to
   @oparam{res}.  *)
BEGIN
  res:=IntConv.FormatInt(str);
  IF (res = strAllRight) THEN
    int:=IntConv.ValueInt(str)
  END
END StrToInt;


PROCEDURE Reverse (VAR str : ARRAY OF CHAR; start, end : INTEGER);
(* Reverses order of characters in the interval [start..end]. *)
VAR
  h : CHAR;
BEGIN
  WHILE start < end DO
    h := str[start]; str[start] := str[end]; str[end] := h;
    INC(start); DEC(end)
  END
END Reverse;


PROCEDURE IntToStr*(int: LONGINT; VAR str: ARRAY OF CHAR);
(**Converts the value of @oparam{int} to string form and copies the possibly
   truncated result to @oparam{str}.  *)
CONST
  maxLength = 11; (* maximum number of digits representing a LONGINT value *)
VAR
  b : ARRAY maxLength+1 OF CHAR;
  s, e: INTEGER;
BEGIN
  (* build representation in string 'b' *)
  IF int = MIN(LONGINT) THEN      (* smallest LONGINT, -int is an overflow *)
    b := "-2147483648";
    e := 11
  ELSE
    IF int < 0 THEN               (* negative sign *)
      b[0] := "-"; int := -int; s := 1
    ELSE  (* no sign *)
      s := 0
    END;
    e := s;                       (* 's' holds starting position of string *)
    REPEAT
      b[e] := CHR(int MOD 10+ORD("0"));
      int := int DIV 10;
      INC(e)
    UNTIL int = 0;
    b[e] := 0X;
    Reverse(b, s, e-1)
  END;
   
  COPY(b, str) (* truncate output if necessary *)
END IntToStr;
 
END ooc2IntStr.

