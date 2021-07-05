(*	$Id: LowLReal.Mod,v 1.6 1999/09/02 13:15:35 acken Exp $	*)
MODULE oocLowLReal;

(* ToDo. support 64 bit builds *)

(*
    LowLReal -  Gives access to the underlying properties of the type LONGREAL
    for IEEE double-precision numbers.
    Copyright (C) 1996 Michael Griebling

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


IMPORT Low := oocLowReal, S := SYSTEM;

(*

   Real number properties are defined as follows:

   radix--The whole number value of the radix used to represent the
          corresponding read number values.

   places--The whole number value of the number of radix places used
           to store values of the corresponding real number type.

   expoMin--The whole number value of the exponent minimum.

   expoMax--The whole number value of the exponent maximum.

   large--The largest value of the corresponding real number type.

   small--The smallest positive value of the corresponding real number
          type, represented to maximal precision.

   IEC559--A Boolean value that is TRUE if and only if the implementation
           of the corresponding real number type conforms to IEC 559:1989
           (IEEE 754:1987) in all regards.

           NOTES
           6 -- If `IEC559' is TRUE, the value of `radix' is 2.
           7 -- If LowReal.IEC559 is TRUE, the 32-bit format of IEC 559:1989
                is used for the type REAL.
           7 -- If LowLong.IEC559 is TRUE, the 64-bit format of IEC 559:1989
                is used for the type REAL.

   LIA1--A Boolean value that is TRUE if and only if the implementation of
         the corresponding real number type conforms to ISO/IEC 10967-1:199x
         (LIA-1) in all regards: parameters, arithmetic, exceptions, and
         notification.

   rounds--A Boolean value that is TRUE if and only if each operation produces
           a result that is one of the values of the corresponding real number
           type nearest to the mathematical result.

   gUnderflow--A Boolean value that is TRUE if and only if there are values of
               the corresponding real number type between 0.0 and `small'.

   exception--A Boolean value that is TRUE if and only if every operation that
              attempts to produce a real value out of range raises an exception.

   extend--A Boolean value that is TRUE if and only if expressions of the
           corresponding real number type are computed to higher precision than
           the stored values.

   nModes--The whole number value giving the number of bit positions needed for
           the status flags for mode control.

*)

CONST
  radix*=      2;
  places*=     53;
  expoMax*=    1023;
  expoMin*=    1-expoMax;
  large*=      MAX(LONGREAL); (*1.7976931348623157D+308;*)  (* MAX(LONGREAL) *)
  (*small*=      2.2250738585072014D-308;*)
  small*=      2.2250738585072014/9.9999999999999981D307(*/10^308)*);
  IEC559*=     TRUE;
  LIA1*=       FALSE;
  rounds*=     FALSE;
  gUnderflow*= TRUE;   (* there are IEEE numbers smaller than `small' *)
  exception*=  FALSE;  (* at least in the default implementation *)
  extend*=     FALSE;
  nModes*=     0;
  ONE=1.0D0;           (* some commonly-used constants *)
  ZERO=0.0D0;
  TEN=1.0D1;

  DEBUG = TRUE;

  expOffset=expoMax;
  hiBit=19;
  expBit=hiBit+1;
  nMask={0..hiBit,31};  (* number mask *)
  expMask={expBit..30}; (* exponent mask *)

TYPE
  Modes*= SET;
  LongInt=ARRAY 2 OF LONGINT;
  LongSet=ARRAY 2 OF SET;

VAR
  (*sml* : LONGREAL; tmp: LONGREAL;*) (* this was a test to get small as a variable at runtime. obviously, compile time preferred; -- noch *)
  isBigEndian-: BOOLEAN; (* set when target is big endian *)
 (*
  PROCEDURE power0(i, j : INTEGER) : LONGREAL; (* used to calculate sml at runtime; -- noch *)
  VAR k : INTEGER;
      p : LONGREAL;
  BEGIN
     k := 1;
     p := i;
     REPEAT
        p := p * i;
        INC(k);
     UNTIL k=j;
     RETURN p;
  END power0;
*)

(* Errors are handled through the LowReal module *)

PROCEDURE err*(): INTEGER;
BEGIN
  RETURN Low.err
END err;

PROCEDURE ClearError*;
BEGIN
  Low.ClearError
END ClearError;

PROCEDURE ErrorHandler*(err: INTEGER);
BEGIN
  Low.ErrorHandler(err)
END ErrorHandler;

(* type-casting utilities *)

PROCEDURE Move (VAR x: LONGREAL; VAR ra: ARRAY OF LONGINT);
(* typecast a LONGREAL to an array of LONGINTs *)
  VAR t: LONGINT;
BEGIN
  S.MOVE(S.ADR(x),S.ADR(ra),SIZE(LONGREAL));
  IF ~isBigEndian THEN t:=ra[0]; ra[0]:=ra[1]; ra[1]:=t END
END Move;

PROCEDURE MoveSet (VAR x: LONGREAL; VAR ra: ARRAY OF SET);
(* typecast a LONGREAL to an array of LONGINTs *)
  VAR t: SET;
BEGIN
  S.MOVE(S.ADR(x),S.ADR(ra),SIZE(LONGREAL));
  IF ~isBigEndian THEN t:=ra[0]; ra[0]:=ra[1]; ra[1]:=t END
END MoveSet;

(* Note: The below should be done with a type cast --
   once the compiler supports such things. *)
(*<* PUSH; Warnings := FALSE *>*)
PROCEDURE Real * (ra: ARRAY OF LONGINT): LONGREAL;
(* typecast an array of big endian LONGINTs to a LONGREAL *)
  VAR t: LONGINT; x: LONGREAL;
BEGIN
  IF ~isBigEndian THEN t:=ra[0]; ra[0]:=ra[1]; ra[1]:=t END;
  S.MOVE(S.ADR(ra),S.ADR(x),SIZE(LONGREAL));
  RETURN x
END Real;

PROCEDURE ToReal (ra: ARRAY OF SET): LONGREAL;
(* typecast an array of LONGINTs to a LONGREAL *)
  VAR t: SET; x: LONGREAL;
BEGIN
  IF ~isBigEndian THEN t:=ra[0]; ra[0]:=ra[1]; ra[1]:=t END;
  S.MOVE(S.ADR(ra),S.ADR(x),SIZE(LONGREAL));
  RETURN x
END ToReal;
(*<* POP *> *)

PROCEDURE exponent*(x: LONGREAL): INTEGER;
(*
   The value of the call exponent(x) shall be the exponent value of `x'
   that lies between `expoMin' and `expoMax'.  An exception shall occur
   and may be raised if `x' is equal to 0.0.
 *)
  VAR ra: LongInt;
BEGIN
  (* NOTE: x=0.0 should raise exception *)
  IF x=ZERO THEN RETURN 0
  ELSE Move(x, ra);
    RETURN SHORT(S.LSH(ra[0],-expBit) MOD 2048)-expOffset
  END
END exponent;

PROCEDURE exponent10*(x: LONGREAL): INTEGER;
(*
   The value of the call exponent10(x) shall be the base 10 exponent
   value of `x'.  An exception shall occur and may be raised if `x' is
   equal to 0.0.
 *)
VAR exp: INTEGER;
BEGIN
  IF x=ZERO THEN RETURN 0 END;                 (* exception could be raised here *)
  exp:=0; x:=ABS(x);
  WHILE x>=TEN DO x:=x/TEN; INC(exp) END;
  WHILE x<1 DO x:=x*TEN; DEC(exp) END;
  RETURN exp
END exponent10;

PROCEDURE fraction*(x: LONGREAL): LONGREAL;
(*
   The value of the call fraction(x) shall be the significand (or
   significant) part of `x'.  Hence the following relationship shall
   hold: x = scale(fraction(x), exponent(x)).
*)
  CONST eZero={(hiBit+2)..29};
  VAR ra: LongInt;
BEGIN
  IF x=ZERO THEN RETURN ZERO
  ELSE Move(x, ra);
    ra[0]:=S.VAL(LONGINT, S.VAL(SET,ra[0])*nMask+eZero);
    RETURN Real(ra)*2.0D0
  END
END fraction;

PROCEDURE IsInfinity * (real: LONGREAL) : BOOLEAN;
  CONST signMask={0..30};
  VAR ra: LongSet;
BEGIN
  MoveSet(real, ra);
  RETURN (ra[0]*signMask=expMask) & (ra[1]={})
END IsInfinity;

PROCEDURE IsNaN * (real: LONGREAL) : BOOLEAN;
  CONST fracMask={0..hiBit};
  VAR ra: LongSet;
BEGIN
  MoveSet(real, ra);
  RETURN (ra[0]*expMask=expMask) & ((ra[1]#{}) OR (ra[0]*fracMask#{}))
END IsNaN;

PROCEDURE sign*(x: LONGREAL): LONGREAL;
(*
   The value of the call sign(x) shall be 1.0 if `x' is greater than 0.0,
   or shall be -1.0 if `x' is less than 0.0, or shall be either 1.0 or
   -1.0 if `x' is equal to 0.0.
*)
BEGIN
  IF x<ZERO THEN RETURN -ONE ELSE RETURN ONE END
END sign;

PROCEDURE scale*(x: LONGREAL; n: INTEGER): LONGREAL;
(*
  The value of the call scale(x,n) shall be the value x*radix^n if such
  a value exists; otherwise an exception shall occur and may be raised.
*)
  VAR exp: LONGINT; lexp: SET; ra: LongInt;
BEGIN
  IF x=ZERO THEN RETURN ZERO END;                     (* can't scale zero *)
  exp:= exponent(x)+n;                                (* new exponent *)
  IF exp>expoMax THEN RETURN large*sign(x)            (* exception raised here *)
  ELSIF exp<expoMin THEN RETURN small*sign(x)         (* exception here as well *)
  END;
  lexp:=S.VAL(SET,S.LSH(exp+expOffset,expBit));       (* shifted exponent bits *)
  Move(x, ra);
  ra[0]:=S.VAL(LONGINT, S.VAL(SET,ra[0])*nMask+lexp); (* insert new exponent *)
  RETURN Real(ra)
END scale;

PROCEDURE ulp*(x: LONGREAL): LONGREAL;
(*
   The value of the call ulp(x) shall be the value of the corresponding
   real number type equal to a unit in the last place of `x', if such a
   value exists; otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN scale(ONE, exponent(x)-places+1)
END ulp;

PROCEDURE succ*(x: LONGREAL): LONGREAL;
(*
   The value of the call succ(x) shall be the next value of the
   corresponding real number type greater than `x', if such a type
   exists; otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN x+ulp(x)*sign(x)
END succ;

PROCEDURE pred*(x: LONGREAL): LONGREAL;
(*
   The value of the call pred(x) shall be the next value of the
   corresponding real number type less than `x', if such a type exists;
   otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN x-ulp(x)*sign(x)
END pred;

PROCEDURE MaskReal(x: LONGREAL; lo: INTEGER): LONGREAL;
VAR ra: LongSet;
BEGIN
  MoveSet(x, ra);                            (* type-cast into sets for masking *)
  IF lo<32 THEN ra[1]:=ra[1]*{lo..31}        (* just need to mask lower word *)
  ELSE ra[0]:=ra[0]*{lo-32..31}; ra[1]:={}   (* mask upper word & clear lower word *)
  END;
  RETURN ToReal(ra)
END MaskReal;

PROCEDURE intpart*(x: LONGREAL): LONGREAL;
(*
   The value of the call intpart(x) shall be the integral part of `x'.
   For negative values, this shall be -intpart(abs(x)).
*)
  VAR lo, hi: INTEGER;
BEGIN hi:=hiBit+32;                          (* account for low 32-bits as well *)
  lo:=(hi+1)-exponent(x);
  IF lo<=0 THEN RETURN x                     (* no fractional part *)
  ELSIF lo<=hi+1 THEN RETURN MaskReal(x, lo) (* integer part is extracted *)
  ELSE RETURN 0                              (* no whole part *)
  END
END intpart;

PROCEDURE fractpart*(x: LONGREAL): LONGREAL;
(*
   The value of the call fractpart(x) shall be the fractional part of
   `x'.  This satifies the relationship fractpart(x)+intpart(x)=x.
*)
BEGIN
  RETURN x-intpart(x)
END fractpart;

PROCEDURE trunc*(x: LONGREAL; n: INTEGER): LONGREAL;
(*
   The value of the call trunc(x,n) shall be the value of the most
   significant `n' places of `x'.  An exception shall occur and may be
   raised if `n' is less than or equal to zero.
*)
  VAR loBit: INTEGER;
BEGIN loBit:=places-n;
  IF n<=0 THEN RETURN ZERO                   (* exception should be raised *)
  ELSIF loBit<=0 THEN RETURN x               (* nothing was truncated *)
  ELSE RETURN MaskReal(x, loBit)             (* clear all lower bits *)
  END
END trunc;

PROCEDURE In (bit: INTEGER; x: LONGREAL): BOOLEAN;
VAR ra: LongSet;
BEGIN
  MoveSet(x, ra);                            (* type-cast into sets for masking *)
  IF bit<32 THEN RETURN bit IN ra[1]         (* check bit in lower word *)
  ELSE RETURN bit-32 IN ra[0]                (* check bit in upper word *)
  END
END In;

PROCEDURE round*(x: LONGREAL; n: INTEGER): LONGREAL;
(*
   The value of the call round(x,n) shall be the value of `x' rounded to
   the most significant `n' places.  An exception shall occur and may be
   raised if such a value does not exist, or if `n' is less than or equal
   to zero.
*)
  VAR loBit: INTEGER; t, r: LONGREAL;
BEGIN loBit:=places-n;
  IF n<=0 THEN RETURN ZERO                   (* exception should be raised *)
  ELSIF loBit<=0 THEN RETURN x               (* nothing was rounded *)
  ELSE t:=MaskReal(x, loBit);                (* truncated result *)
    IF In(loBit-1, x) THEN                   (* check if result should be rounded *)
      r:=scale(ONE,exponent(x)-n+1);         (* rounding fraction *)
      IF In(31+32, x) THEN RETURN t-r        (* negative rounding toward -infinity *)
      ELSE RETURN t+r                        (* positive rounding toward +infinity *)
      END
    ELSE RETURN t                            (* return truncated result *)
    END
  END
END round;

PROCEDURE synthesize*(expart: INTEGER; frapart: LONGREAL): LONGREAL;
(*
   The value of the call synthesize(expart,frapart) shall be a value of
   the corresponding real number type contructed from the value of
   `expart' and `frapart'.  This value shall satisfy the relationship
   synthesize(exponent(x),fraction(x)) = x.
*)
BEGIN
  RETURN scale(frapart, expart)
END synthesize;

PROCEDURE setMode*(m: Modes);
(*
   The call setMode(m) shall set status flags from the value of `m',
   appropriate to the underlying implementation of the corresponding real
   number type.

   NOTES
   3 -- Many implementations of floating point provide options for
   setting flags within the system which control details of the handling
   of the type.  Although two procedures are provided, one for each real
   number type, the effect may be the same.  Typical effects that can be
   obtained by this means are:
     a) Ensuring that overflow will raise an exception;
     b) Allowing underflow to raise an exception;
     c) Controlling the rounding;
     d) Allowing special values to be produced (e.g. NaNs in
        implementations conforming to IEC 559:1989 (IEEE 754:1987));
     e) Ensuring that special valu access will raise an exception;
   Since these effects are so varied, the values of type `Modes' that may
   be used are not specified by this International Standard.
   4 -- The effects of `setMode' on operation on values of the
   corresponding real number type in coroutines other than the calling
   coroutine is not defined.  Implementations are not require to preserve
   the status flags (if any) with the coroutine state.
*)
BEGIN
  (* hardware dependent mode setting of coprocessor *)
END setMode;

PROCEDURE currentMode*(): Modes;
(*
   The value of the call currentMode() shall be the current status flags
   (in the form set by `setMode'), or the default status flags (if
   `setMode' is not used).

   NOTE 5 -- The value of the call currentMode() is not necessarily the
   value of set by `setMode', since a call of `setMode' might attempt to
   set flags that cannot be set by the program.
*)
BEGIN
  RETURN {}
END currentMode;

PROCEDURE IsLowException*(): BOOLEAN;
  (* Returns TRUE if the current coroutine is in the exceptional execution state
     because of the raising of the LowReal exception; otherwise returns FALSE.
  *)
BEGIN
  RETURN FALSE
END IsLowException;

PROCEDURE InitEndian;
  VAR endianTest: INTEGER; c: CHAR;
BEGIN
  endianTest:=1;
  S.GET(S.ADR(endianTest), c);
  isBigEndian:=c#1X
END InitEndian;

PROCEDURE Test;
  CONST n1=1.234D39; n2=-1.23343D-20; n3=123.456;
  VAR n: LONGREAL; exp: INTEGER;
BEGIN
  exp:=exponent(n1); exp:=exponent(n2);
  n:=fraction(n1); n:=fraction(n2);
  n:=scale(ONE, -8); n:=scale(ONE, 8);
  n:=succ(10);
  n:=intpart(n3);
  n:=trunc(n3, 5);  (* n=120 *)
  n:=trunc(n3, 7);  (* n=123 *)
  n:=trunc(n3, 12); (* n=123.4375 *)
  n:=round(n3, 5);  (* n=124 *)
  n:=round(n3, 7);  (* n=123 *)
  n:=round(n3, 12); (* n=123.46875 *)
END Test;

BEGIN
  InitEndian;   (* check whether target is big endian *)
(*
    tmp := power0(10,308); (* this is test to calculate small as a variable at runtime; -- noch *)
    sml := 2.2250738585072014/tmp;
      sml := 2.2250738585072014/power0(10, 308);
  *)


  IF DEBUG THEN Test END
END oocLowLReal.
