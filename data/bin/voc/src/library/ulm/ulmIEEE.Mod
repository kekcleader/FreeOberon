(* Ulm's Oberon Library
   Copyright (C) 1989-2005 by University of Ulm, SAI, D-89069 Ulm, Germany
   ----------------------------------------------------------------------------
   Ulm's Oberon Library is free software; you can redistribute it
   and/or modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either version
   2 of the License, or (at your option) any later version.

   Ulm's Oberon Library is distributed in the hope that it will be
   useful, but WITHOUT ANY WARRANTY; without even the implied warranty
   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   ----------------------------------------------------------------------------
   E-mail contact: oberon@mathematik.uni-ulm.de
   ----------------------------------------------------------------------------
   $Id: IEEE.om,v 1.1 1994/02/23 07:45:22 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: IEEE.om,v $
   Revision 1.1  1994/02/23  07:45:22  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 7/89
   ----------------------------------------------------------------------------
*)

MODULE ulmIEEE;

   (* this module is portable as far as a IEEE floating point processor
      is present

      implementation for the I386 architecture

      assumptions:

      {0} is the most significant bit
      MAX(SET) = 31

      double precision binary real format (REAL):

	  0 1..11 12    ..     63
	 +-+-----+---------------+
	 |S| exp | fraction      |
	 +-+-----+---------------+

      normalized numbers:   min < exp < max
      denormalized numbers: exp = 0 and nonzero mantissa
      zero:                 exp = 0 and mantissa = 0
      infinity:             exp = max and mantissa = 0
      not-a-number:         exp = max and mantissa # 0
   *)

   IMPORT SYS := SYSTEM;

   CONST
      (*patternlen = SYS.SIZE(LONGREAL) DIV SYS.SIZE(SET);*)
      patternlen = SIZE(LONGREAL) DIV SIZE(SET) + 23; (* in ulm Oberon system, size of longreal is 12, size of set is 4, so this will be 3
                                                    in voc 32 bit we have it as 8 DIV 4
						    in voc 64 bit we have it as 8 DIV 8
						    may be it worth just to add some number to the result of division -- noch
						   *)

   VAR
      plusInfinity*: REAL;
      minusInfinity*: REAL;
      nan*: REAL;		(* Not-A-Number *)
      snan*: REAL;		(* Signaling Not-A-Number *)

   (*PROCEDURE Convert(VAR from, to: ARRAY OF BYTE);*)
   PROCEDURE Convert(VAR from, to: ARRAY OF SYS.BYTE);
      VAR i: INTEGER;
   BEGIN
      i := 0;
      WHILE i < LEN(to) DO
	 to[i] := from[i]; INC(i);
      END;
   END Convert;

   PROCEDURE Normalized*(real: LONGREAL) : BOOLEAN;
      VAR pattern: ARRAY patternlen OF SET;
   BEGIN
      Convert(real, pattern);
      pattern[1] := pattern[1] * {20..30};
      RETURN (pattern[1] # {}) & (pattern[1] # {20..30})
   END Normalized;

   PROCEDURE Valid*(real: LONGREAL) : BOOLEAN;
      (* returns TRUE if real is normalized or denormalized
	     but FALSE for infinity and Not-A-Numbers
      *)
      VAR pattern: ARRAY patternlen OF SET;
   BEGIN
      Convert(real, pattern);
      pattern[1] := pattern[1] * {20..30};
      RETURN pattern[1] # {20..30}
   END Valid;

   PROCEDURE NotANumber*(real: LONGREAL) : BOOLEAN;
      (* returns TRUE if real is a (signaling) Not-A-Number *)
      VAR pattern: ARRAY patternlen OF SET;
   BEGIN
      Convert(real, pattern);
      RETURN (pattern[1] * {20..30} = {20..30}) &
	     ((pattern[0] * {0..MAX(SET)} # {}) OR
	      (pattern[1] * {0..19} # {}))
   END NotANumber;

   PROCEDURE SetReal(VAR real: REAL;
		     sign: BOOLEAN; expbits: BOOLEAN;
		     msb: BOOLEAN; otherbits: BOOLEAN);
      VAR
	 pattern: ARRAY 2 OF SET;

   BEGIN
      pattern[0] := {}; pattern[1] := {};
      IF sign THEN
	 INCL(pattern[1], 31);
      END;
      IF expbits THEN
	 pattern[1] := pattern[1] + {20..30};
      END;
      IF msb THEN
	 INCL(pattern[1], 19);
      END;
      IF otherbits THEN
	 pattern[1] := pattern[1] + {0..18};
	 pattern[0] := {0..MAX(SET)};
      END;
      Convert(pattern, real);
   END SetReal;

BEGIN
   (*                     sign   exp    msb    mantissa *)
   SetReal(plusInfinity,  FALSE, TRUE,  FALSE, FALSE);
   SetReal(minusInfinity, TRUE,  TRUE,  FALSE, FALSE);
   SetReal(nan,           FALSE, TRUE,  TRUE,  TRUE);
   SetReal(snan,          FALSE, TRUE,  FALSE, TRUE);
END ulmIEEE.
