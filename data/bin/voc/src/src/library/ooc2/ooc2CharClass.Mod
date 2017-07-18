(*	$Id: CharClass.Mod,v 1.1 2002/04/15 22:42:48 mva Exp $	*)
MODULE ooc2CharClass;  
(*  Classification of values of the type CHAR.
    Copyright (C) 1997-1998, 2002  Michael van Acken

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

IMPORT
  Ascii := ooc2Ascii;

CONST
  eol* = Ascii.lf;
  (**The implementation-defined character used to represent end of line
     internally for OOC.  *)

VAR
  systemEol-: ARRAY 3 OF CHAR;
  (**End of line marker used by the target system for text files.  The string
     defined here can contain more than one character.  For one character eol
     markers, @ovar{systemEol} must not necessarily equal @oconst{eol}.  Note
     that the string cannot contain the termination character @code{0X}.  *)


PROCEDURE IsNumeric* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} is classified as a numeric
   character.  *)
  BEGIN
    RETURN ("0" <= ch) & (ch <= "9")
  END IsNumeric;
  
PROCEDURE IsLetter* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} is classified as a letter.  *)
  BEGIN
    RETURN ("a" <= ch) & (ch <= "z") OR ("A" <= ch) & (ch <= "Z")
  END IsLetter;
  
PROCEDURE IsUpper* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} is classified as an upper
   case letter.  *)
  BEGIN
    RETURN ("A" <= ch) & (ch <= "Z")
  END IsUpper;
  
PROCEDURE IsLower* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} is classified as a lower case
   letter.  *)
  BEGIN
    RETURN ("a" <= ch) & (ch <= "z")
  END IsLower;
  
PROCEDURE IsControl* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} represents a control
   function.  *)
  BEGIN
    RETURN (ch < Ascii.sp)
  END IsControl;
  
PROCEDURE IsWhiteSpace* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} represents a space character
   or a format effector.  *)
  BEGIN
    RETURN (ch = Ascii.sp) OR (ch = Ascii.ff) OR (ch = Ascii.lf) OR
           (ch = Ascii.cr) OR (ch = Ascii.ht) OR (ch = Ascii.vt)
  END IsWhiteSpace;

  
PROCEDURE IsEol* (ch: CHAR): BOOLEAN;
(**Returns @code{TRUE} if and only if @oparam{ch} is the implementation-defined
   character used to represent end of line internally for OOC.  *) 
  BEGIN
    RETURN (ch = eol)
  END IsEol;

BEGIN
  systemEol[0] := Ascii.lf; systemEol[1] := 0X
END ooc2CharClass.
