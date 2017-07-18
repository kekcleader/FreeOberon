(*	$Id: LowReal.Mod,v 1.5 1999/09/02 13:17:38 acken Exp $	*)
MODULE oocLowReal;

(*
    LowReal -  Gives access to the underlying properties of the type REAL
    for IEEE single-precision numbers.
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


IMPORT S := SYSTEM, Console, Reals;

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
  places*=     24;
  expoMax*=    127;
  expoMin*=    1-expoMax;
  large*=      MAX(REAL);(*3.40282347E+38;*) (* MAX(REAL) *)
  (*small*=      1.17549435E-38; (* 2^(-126) *)*)
  small* =         1/8.50705917E37; (* don't know better way; -- noch *)
  IEC559*=     TRUE;
  LIA1*=       FALSE;
  rounds*=     FALSE;
  gUnderflow*= TRUE;   (* there are IEEE numbers smaller than `small' *)
  exception*=  FALSE;  (* at least in the default implementation *)
  extend*=     FALSE;
  nModes*=     0;

  TEN=10.0;             (* some commonly-used constants *)
  ONE=1.0;
  ZERO=0.0;

  expOffset=expoMax;
  hiBit=22;
  expBit=hiBit+1;
  nMask={0..hiBit,31};  (* number mask *)
  expMask={expBit..30}; (* exponent mask *)

TYPE
  Modes*= SET;

VAR
  (*small* : REAL; tmp: REAL;*) (* this was a test to get small as a variable at runtime. obviously, compile time preferred; -- noch *)
  ErrorHandler*: PROCEDURE (errno : INTEGER);
  err-: INTEGER;

(* Error handler default stub which can be replaced *)

PROCEDURE DefaultHandler (errno : INTEGER);
BEGIN
  err:=errno
END DefaultHandler;

PROCEDURE ClearError*;
BEGIN
  err:=0
END ClearError;


PROCEDURE exponent*(x: REAL): INTEGER;
(*
   The value of the call exponent(x) shall be the exponent value of `x'
   that lies between `expoMin' and `expoMax'.  An exception shall occur
   and may be raised if `x' is equal to 0.0.
 *)
BEGIN
  (* NOTE: x=0.0 should raise exception *)
  IF x=ZERO THEN RETURN 0
  ELSE RETURN Reals.Expo(x) - expOffset
  END
END exponent;

PROCEDURE exponent10*(x: REAL): INTEGER;
(*
   The value of the call exponent10(x) shall be the base 10 exponent
   value of `x'.  An exception shall occur and may be raised if `x' is
   equal to 0.0.
 *)
VAR exp: INTEGER;
BEGIN
  exp:=0; x:=ABS(x);
  IF x=ZERO THEN RETURN exp END;  (* exception could be raised here *)
  WHILE x>=TEN DO x:=x/TEN; INC(exp) END;
  WHILE (x>ZERO) & (x<1.0) DO x:=x*TEN; DEC(exp) END;
  RETURN exp
END exponent10;

(* TYPE REAL: 1/sign, 8/exponent, 23/significand *)

PROCEDURE fraction*(x: REAL): REAL;
(*
   The value of the call fraction(x) shall be the significand (or
   significant) part of `x'.  Hence the following relationship shall
   hold: x = scale(fraction(x), exponent(x)).
*)
VAR c: CHAR;
BEGIN
  IF x=ZERO THEN RETURN ZERO
  ELSE
    (* Set top 7 bits of exponent to 0111111 *)
    S.GET(S.ADR(x)+3, c);
    c := CHR(((ORD(c) DIV 128) * 128) + 63); (* Set X0111111 (X unchanged) *)
    S.PUT(S.ADR(x)+3, c);
    (* Set bottom bit of exponent to 0 *)
    S.GET(S.ADR(x)+2, c);
    c := CHR(ORD(c) MOD 128); (* Set 0XXXXXXX (X unchanged) *)
    S.PUT(S.ADR(x)+2, c);
    RETURN x * 2.0;
  END
(*
  CONST eZero={(hiBit+2)..29};
BEGIN
  IF x=ZERO THEN RETURN ZERO
  ELSE RETURN S.VAL(REAL,(S.VAL(SET,x)*nMask)+eZero)*2.0  (* set the mantissa's exponent to zero *)
  END
*)
END fraction;

PROCEDURE IsInfinity * (real: REAL) : BOOLEAN;
  VAR c0, c1, c2, c3: CHAR;
BEGIN
  S.GET(S.ADR(real)+0, c3);
  S.GET(S.ADR(real)+1, c2);
  S.GET(S.ADR(real)+2, c1);
  S.GET(S.ADR(real)+3, c0);
  RETURN (ORD(c0) MOD 128 = 127) & (ORD(c1) = 128) & (ORD(c2) = 0) & (ORD(c3) = 0)
END IsInfinity;

PROCEDURE IsNaN * (real: REAL) : BOOLEAN;
  VAR c0, c1, c2, c3: CHAR;
BEGIN
  S.GET(S.ADR(real)+0, c3);
  S.GET(S.ADR(real)+1, c2);
  S.GET(S.ADR(real)+2, c1);
  S.GET(S.ADR(real)+3, c0);
  RETURN (ORD(c0) MOD 128 = 127)
       & (ORD(c1) DIV 128 = 1)
       & ((ORD(c1) MOD 128 # 0) OR (ORD(c2) # 0) OR (ORD(c3) # 0))
END IsNaN;

PROCEDURE sign*(x: REAL): REAL;
(*
   The value of the call sign(x) shall be 1.0 if `x' is greater than 0.0,
   or shall be -1.0 if `x' is less than 0.0, or shall be either 1.0 or
   -1.0 if `x' is equal to 0.0.
*)
BEGIN
  IF x<ZERO THEN RETURN -ONE ELSE RETURN ONE END
END sign;


PROCEDURE scale*(x: REAL; n: INTEGER): REAL;
(*
  The value of the call scale(x,n) shall be the value x*radix^n if such
  a value exists; otherwise an execption shall occur and may be raised.
*)
  VAR exp: LONGINT; lexp: SET;
BEGIN
  IF x=ZERO THEN RETURN ZERO END;
  exp:= exponent(x)+n;                          (* new exponent *)
  IF exp>expoMax THEN RETURN large*sign(x)      (* exception raised here *)
  ELSIF exp<expoMin THEN RETURN small*sign(x)   (* exception here as well *)
  END;
  lexp:=S.VAL(SET,S.LSH(exp+expOffset,expBit)); (* shifted exponent bits *)
  RETURN S.VAL(REAL,(S.VAL(SET,x)*nMask)+lexp)  (* insert new exponent *)
END scale;

PROCEDURE ulp*(x: REAL): REAL;
(*
   The value of the call ulp(x) shall be the value of the corresponding
   real number type equal to a unit in the last place of `x', if such a
   value exists; otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN scale(ONE, exponent(x)-places+1)
END ulp;

PROCEDURE succ*(x: REAL): REAL;
(*
   The value of the call succ(x) shall be the next value of the
   corresponding real number type greater than `x', if such a type
   exists; otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN x+ulp(x)*sign(x)
END succ;

PROCEDURE pred*(x: REAL): REAL;
(*
   The value of the call pred(x) shall be the next value of the
   corresponding real number type less than `x', if such a type exists;
   otherwise an exception shall occur and may be raised.
*)
BEGIN
  RETURN x-ulp(x)*sign(x)
END pred;

PROCEDURE intpart*(x: REAL): REAL;
(*
   The value of the call intpart(x) shall be the integral part of `x'.
   For negative values, this shall be -intpart(abs(x)).
*)
  VAR loBit: INTEGER;
BEGIN
  loBit:=(hiBit+1)-exponent(x);
  IF loBit<=0 THEN RETURN x                     (* no fractional part *)
  ELSIF loBit<=hiBit+1 THEN
    RETURN S.VAL(REAL,S.VAL(SET,x)*{loBit..31}) (* integer part is extracted *)
  ELSE RETURN ZERO                              (* no whole part *)
  END
END intpart;

PROCEDURE fractpart*(x: REAL): REAL;
(*
   The value of the call fractpart(x) shall be the fractional part of
   `x'.  This satifies the relationship fractpart(x)+intpart(x)=x.
*)
BEGIN
  RETURN x-intpart(x)
END fractpart;

PROCEDURE trunc*(x: REAL; n: INTEGER): REAL;
(*
   The value of the call trunc(x,n) shall be the value of the most
   significant `n' places of `x'.  An exception shall occur and may be
   raised if `n' is less than or equal to zero.
*)
  VAR loBit: INTEGER; mask: SET;
BEGIN loBit:=places-n;
  IF n<=0 THEN RETURN ZERO                   (* exception should be raised *)
  ELSIF loBit<=0 THEN RETURN x               (* nothing was truncated *)
  ELSE mask:={loBit..31};                    (* truncation bit mask *)
    RETURN S.VAL(REAL,S.VAL(SET,x)*mask)
  END
END trunc;

PROCEDURE round*(x: REAL; n: INTEGER): REAL;
(*
   The value of the call round(x,n) shall be the value of `x' rounded to
   the most significant `n' places.  An exception shall occur and may be
   raised if such a value does not exist, or if `n' is less than or equal
   to zero.
*)
  VAR loBit: INTEGER; num, mask: SET; r: REAL;
BEGIN loBit:=places-n;
  IF n<=0 THEN RETURN ZERO                   (* exception should be raised *)
  ELSIF loBit<=0 THEN RETURN x               (* nothing was rounded *)
  ELSE mask:={loBit..31}; num:=S.VAL(SET,x); (* truncation bit mask and number as SET *)
    x:=S.VAL(REAL,num*mask);                 (* truncated result *)
    IF loBit-1 IN num THEN                   (* check if result should be rounded *)
      r:=scale(ONE,exponent(x)-n+1);         (* rounding fraction *)
      IF 31 IN num THEN RETURN x-r           (* negative rounding toward -infinity *)
      ELSE RETURN x+r                        (* positive rounding toward +infinity *)
      END
    ELSE RETURN x                            (* return truncated result *)
    END
  END
END round;

PROCEDURE synthesize*(expart: INTEGER; frapart: REAL): REAL;
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
(*
   Returns TRUE if the current coroutine is in the exceptional execution state
   because of the raising of the LowReal exception; otherwise returns FALSE.
*)
BEGIN
  RETURN FALSE
END IsLowException;

BEGIN
  (* install the default error handler -- just sets err variable *)
  ErrorHandler:=DefaultHandler;
(*  tmp := power0(2,126); (* this is test to calculate small as a variable at runtime; -- noch *)
  small := sml;
  small := 1/power0(2,126);
  *)
END oocLowReal.


