(* Ulm's Oberon Library
   Copyright (C) 1989-1994 by University of Ulm, SAI, D-89069 Ulm, Germany
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
   $Id: Reals.om,v 1.2 2004/03/09 21:38:50 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Reals.om,v $
   Revision 1.2  2004/03/09 21:38:50  borchert
   maxlongexp, minlongexp, and maxlongdignum adapted to SPARC architecture

   Revision 1.1  1994/02/23  07:45:40  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 6/89
   ----------------------------------------------------------------------------
*)

MODULE ulmReals;

   IMPORT IEEE := ulmIEEE, MC68881 := ulmMC68881, Types := ulmTypes;

   CONST
      (* for Types.Real32 *)
      maxexp* = 309;
      minexp* = -323;
      maxdignum* = 16;
      (* for Types.Real64 *)
      (*
      maxlongexp = 4932;
      minlongexp = -4951;
      maxlongdignum = 19;
      *)
      maxlongexp* = 309;
      minlongexp* = -323;
      maxlongdignum* = 16;

      powers = 6;
      maxbase = 16;
   TYPE
      PowerRec =
	 RECORD
	    p10: Types.Real64;
	    n: Types.Int32;
	 END;
   VAR
      powtab: ARRAY powers OF PowerRec;
      sigdigits: ARRAY maxbase+1 OF Types.Int32; (* valid range: [2..maxbase] *)

   PROCEDURE ExpAndMan*(r: Types.Real64; long: BOOLEAN; base: Types.Int32;
		       VAR exponent: Types.Int32; VAR mantissa: Types.Real64);
      (* get exponent and mantissa from `r':

	 (1.0 >= ABS(mantissa)) & (ABS(mantissa) < base)

	 r = mantissa * base^exponent

	 long should be false if a Types.Real32-value is passed to `r'
	 valid values of base: 2, 8, 10, and 16
      *)
      VAR
	 neg: BOOLEAN;
	 index: Types.Int32;
	 roundoff: Types.Real64;
	 i: Types.Int32;
	 ndigits: Types.Int32;
   BEGIN
      IF r = 0.0 THEN
	 exponent := 0; mantissa := 0; RETURN
      ELSIF r = IEEE.plusInfinity THEN
	 IF long THEN
	    exponent := 9999;
	 ELSE
	    exponent := 999;
	 END;
	 mantissa := 1;
	 RETURN
      ELSIF r = IEEE.minusInfinity THEN
	 IF long THEN
	    exponent := 9999;
	 ELSE
	    exponent := 999;
	 END;
	 mantissa := -1;
	 RETURN
      ELSIF IEEE.NotANumber(r) THEN
	 exponent := 0;
	 mantissa := 0;
	 RETURN
      END;
      neg := r < 0.0;
      IF neg THEN
	 r := ABS(r);
      END;
      exponent := 0; mantissa := r;
      IF base = 10 THEN
	 IF MC68881.available THEN
	    exponent := SHORT(ENTIER(MC68881.FLOG10(r)));
	    mantissa := r / MC68881.FTENTOX(exponent);
	 ELSE
	    (* use powtab *)
	    index := 0;
	    WHILE mantissa < 1.0 DO
	       WHILE mantissa * powtab[index].p10 < 10 DO
		  DEC(exponent, powtab[index].n);
		  mantissa := mantissa * powtab[index].p10;
	       END;
	       INC(index);
	    END;
	    WHILE mantissa >= 10 DO
	       WHILE mantissa >= powtab[index].p10 DO
		  INC(exponent, powtab[index].n);
		  mantissa := mantissa / powtab[index].p10;
	       END;
	       INC(index);
	    END;
	 END;
      ELSE (* general case *)
	 WHILE mantissa < 1.0 DO
	    DEC(exponent); mantissa := mantissa * base;
	 END;
	 WHILE mantissa >= base DO
	    INC(exponent); mantissa := mantissa / base;
	 END;
      END;
      IF ~(base IN {2, 4, 16}) THEN
	 (* roundoff *)
	 roundoff := base/2;
	 IF ~long & (base = 10) THEN
	    ndigits := maxdignum;
	 ELSE
	    ndigits := sigdigits[base];
	 END;
	 i := 0;
	 WHILE i < ndigits DO
	    roundoff := roundoff/base; INC(i);
	 END;
	 mantissa := mantissa + roundoff;
	 IF mantissa >= base THEN
	    mantissa := mantissa / base;
	    INC(exponent);
	 ELSIF mantissa < 1 THEN
	    mantissa := mantissa * base;
	    DEC(exponent);
	 END;
      END;
      IF neg THEN
	 mantissa := -mantissa;
      END;
   END ExpAndMan;

   PROCEDURE Power*(base: Types.Real64; exp: Types.Int32) : Types.Real64;
      (* efficient calculation of base^exp *)
      VAR
	 r, res: Types.Real64;
	 neg: BOOLEAN; (* negative exponent? *)
   BEGIN 
      IF MC68881.available & (base = 10) THEN
	 RETURN MC68881.FTENTOX(exp)
      ELSIF MC68881.available & (base = 2) THEN
	 RETURN MC68881.FTWOTOX(exp)
      ELSE
	 res := 1.0;
	 r := base;
	 neg := exp < 0;
	 exp := ABS(exp);
	 LOOP 
	    IF ODD(exp) THEN 
	       res := res * r;
	    END;
	    exp := exp DIV 2;
	    IF exp = 0 THEN 
	       EXIT 
	    END;
	    r := r * r;
	 END;
	 IF neg THEN
	    RETURN 1 / res
	 ELSE
	    RETURN res 
	 END;
      END;
   END Power;

   PROCEDURE Digits*(mantissa: Types.Real64; base: Types.Int32;
		    VAR buf: ARRAY OF CHAR;
		    VAR neg: BOOLEAN;
		    force: BOOLEAN; VAR ndigits: Types.Int32);
      (* PRE:
	    mantissa holds the post-condition of ExpAndMan;
	    valid values for base are 2, 8, 10, and 16
	    ndigits > 0: maximal number of digits
	 POST:
	    the mantissa is converted into digits 0-9 and A-F (if base = 16);
	    buf consists of ndigits digits and
	    is guaranteed to be 0X-terminated;
	    neg is set to TRUE if mantissa < 0
	    force = FALSE:
	       there are no leading zeroes except on mantissa = 0;
	    force = TRUE
	       ndigits is unchanged
      *)
      VAR
	 index: Types.Int32; (* of buf *)
	 i: Types.Int32; roundoff: Types.Real64;
	 lastnz: Types.Int32; (* last index with buf[index] # "0" *)
	 ch: CHAR;
	 digit: Types.Int32;
	 maxdig: CHAR; (* base-1 converted *)

   BEGIN
      index := 0;
      IF (ndigits <= 0) OR (ndigits+1 >= LEN(buf)) THEN
	 ndigits := SHORT(LEN(buf) - 1);
      END;
      IF ~force & (ndigits > sigdigits[base]) THEN
	 ndigits := sigdigits[base];
      END;
      neg := mantissa < 0;
      mantissa := ABS(mantissa);
      IF mantissa = 0 THEN
	 buf[index] := "0"; INC(index);
      ELSE
	 (* roundoff *)
	 roundoff := base/2;
	 i := 0;
	 WHILE i < ndigits DO
	    roundoff := roundoff/base; INC(i);
	 END;
	 IF mantissa + roundoff < base THEN
	    mantissa := mantissa + roundoff;
	 END;

	 (* conversion *)
	 lastnz := 0;
	 WHILE (index < ndigits) & (mantissa # 0) DO
	    digit := ENTIER(mantissa);
	    (* digit in [0..base-1] *)
	    IF digit <= 9 THEN
	       ch := CHR(digit + ORD("0"));
	    ELSIF digit <= 16 THEN
	       ch := CHR(digit - 10 + ORD("A"));
	    ELSE
	       ch := "?";
	    END;
	    buf[index] := ch; INC(index);
	    mantissa := (mantissa - digit) * base;
	    IF ch # "0" THEN
	       lastnz := index;
	    END;
	 END;
	 index := lastnz;
      END;
      buf[index] := 0X; ndigits := index;
   END Digits;

   PROCEDURE Convert*(digits: ARRAY OF CHAR; base: Types.Int32; neg: BOOLEAN;
		     VAR mantissa: Types.Real64);
      (* convert normalized `digits' (decimal point after 1st digit)
	 into `mantissa'
      *)
      VAR
	 index: Types.Int32;
	 factor: Types.Real64;
   BEGIN
      IF digits = "0" THEN
	 mantissa := 0;
      ELSE
	 mantissa := ORD(digits[0]) - ORD("0");
	 factor := 1 / base;
	 index := 1;
	 WHILE (index < LEN(digits)) & (index < sigdigits[base]) &
	       (digits[index] # 0X) & (factor > 0) DO
	    mantissa := mantissa + (ORD(digits[index]) - ORD("0")) * factor;
	    factor := factor / base;
	    INC(index);
	 END;
	 IF neg THEN
	    mantissa := -mantissa;
	 END;
      END;
   END Convert;

BEGIN
   powtab[0].p10 := 1.0D32; powtab[0].n := 32;
   powtab[1].p10 := 1.0D16; powtab[1].n := 16;
   powtab[2].p10 :=  1.0D8; powtab[2].n :=  8;
   powtab[3].p10 :=  1.0D4; powtab[3].n :=  4;
   powtab[4].p10 :=  1.0D2; powtab[4].n :=  2;
   powtab[5].p10 :=  1.0D1; powtab[5].n :=  1;

   (* for Types.Real64 *)
   sigdigits[2] := 64;  sigdigits[3] := 40;  sigdigits[4] := 32;
   sigdigits[5] := 27;  sigdigits[6] := 24;  sigdigits[7] := 22;
   sigdigits[8] := 21;  sigdigits[9] := 20;  sigdigits[10] := 19;
   sigdigits[11] := 18; sigdigits[12] := 17; sigdigits[13] := 17;
   sigdigits[14] := 16; sigdigits[15] := 16; sigdigits[16] := 16;
END ulmReals.
