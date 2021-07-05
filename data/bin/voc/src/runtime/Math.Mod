MODULE Math;

IMPORT SYSTEM;

(*  Math - Oakwood REAL Mathematics.
    Adapted from OOC LowReal.Mod and RealMath.Mod

    Target independent mathematical functions for REAL
    (IEEE single - precision) numbers.

    Numerical approximations are taken from "Software Manual for the
    Elementary Functions" by Cody & Waite and "Computer Approximations"
    by Hart et al.

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
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111 - 1307  USA
*)

(*
   Real number properties are defined as follows:

   radix - -The whole number value of the radix used to represent the
          corresponding read number values.

   places - -The whole number value of the number of radix places used
           to store values of the corresponding real number type.

   expoMin - -The whole number value of the exponent minimum.

   expoMax - -The whole number value of the exponent maximum.

   large - -The largest value of the corresponding real number type.

   small - -The smallest positive value of the corresponding real number
          type, represented to maximal precision.

   IEC559 - -A Boolean value that is TRUE if and only if the implementation
           of the corresponding real number type conforms to IEC 559:1989
           (IEEE 754:1987) in all regards.

           NOTES
           6 -- If `IEC559' is TRUE, the value of `radix' is 2.
           7 -- If LowReal.IEC559 is TRUE, the 32 - bit format of IEC 559:1989
                is used for the type REAL.
           7 -- If LowLong.IEC559 is TRUE, the 64 - bit format of IEC 559:1989
                is used for the type REAL.

   LIA1 - -A Boolean value that is TRUE if and only if the implementation of
         the corresponding real number type conforms to ISO/IEC 10967 - 1:199x
         (LIA - 1) in all regards: parameters, arithmetic, exceptions, and
         notification.

   rounds - -A Boolean value that is TRUE if and only if each operation produces
           a result that is one of the values of the corresponding real number
           type nearest to the mathematical result.

   gUnderflow - -A Boolean value that is TRUE if and only if there are values of
               the corresponding real number type between 0.0 and `small'.

   exception - -A Boolean value that is TRUE if and only if every operation that
              attempts to produce a real value out of range raises an exception.

   extend - -A Boolean value that is TRUE if and only if expressions of the
           corresponding real number type are computed to higher precision than
           the stored values.

   nModes - -The whole number value giving the number of bit positions needed for
           the status flags for mode control.
 *)

CONST
  pi* = 3.1415926535897932384626433832795028841972;
  e*  = 2.7182818284590452353602874713526624977572;

  places*   = 24;
  large*    = MAX(REAL);          (* 3.40282347E+38. Largest number this package accepts *)
(*small*    = 1.17549435E-38;  *) (* 2^(-126) *)
  small*    = 1/8.50705917E37;    (* don't know better way; -- noch *)
  expoMax*  = 127;
  expoMin*  = 1-expoMax;
  expOffset = expoMax;
  nMask     = {0..22,31};  (* number mask: Sign and mantissa *)
  expMask   = {23..30};    (* exponent mask: exponent value + 127 *)

  ZERO      = 0.0;
  HALF      = 0.5;
  ONE       = 1.0;
  TWO       = 2.0;
  TEN       = 10.0;
  miny      = ONE/large;                  (* Smallest number this package accepts *)
  sqrtHalf  = 0.70710678118654752440;
  Limit     = 2.4414062E-4;               (* 2 * *( - MantBits/2) *)
  eps       = 2.9802322E-8;               (* 2 * *( - MantBits - 1) *)
  piInv     = 0.31830988618379067154;     (* 1/pi *)
  piByTwo   = 1.57079632679489661923132;
  piByFour  = 0.78539816339744830962;
  lnv       = 0.6931610107421875;         (* should be exact *)
  vbytwo    = 0.13830277879601902638E-4;  (* used in sinh/cosh *)
  ln2Inv    = 1.44269504088896340735992468100189213;

  (* error/exception codes *)
  NoError*           = 0; IllegalRoot*       = 1; IllegalLog*     = 2;  Overflow*       = 3;
  IllegalPower*      = 4; IllegalLogBase*    = 5; IllegalTrig*    = 6;  IllegalInvTrig* = 7;
  HypInvTrigClipped* = 8; IllegalHypInvTrig* = 9; LossOfAccuracy* = 10; Underflow*      = 11;

VAR
  ErrorHandler*: PROCEDURE (errno : INTEGER);
  err-: INTEGER;

  a1: ARRAY 18 OF REAL; (* lookup table for power function *)
  a2: ARRAY 9 OF REAL;  (* lookup table for power function *)
  em: REAL;             (* largest number such that 1 + epsilon > 1.0 *)
  LnInfinity: REAL;     (* natural log of infinity *)
  LnSmall: REAL;        (* natural log of very small number *)
  SqrtInfinity: REAL;   (* square root of infinity *)
  TanhMax: REAL;        (* maximum Tanh value *)
  t: REAL;              (* internal variables *)


PROCEDURE DefaultErrorHandler(errno : INTEGER);
BEGIN err:=errno END DefaultErrorHandler;

PROCEDURE ClearError*;
BEGIN err:=0 END ClearError;


(* TYPE REAL: 1/sign, 8/exponent, 23/significand *)

PROCEDURE fraction*(x: REAL): REAL;
(*
   The value of the call fraction(x) shall be the significand (or
   significant) part of `x'.  Hence the following relationship shall
   hold: x = scale(fraction(x), exponent(x)).
*)
  VAR s: SET;
BEGIN
  IF x = ZERO THEN RETURN ZERO
  ELSE
    s := SYSTEM.VAL(SYSTEM.SET32, x) * nMask + {24..29};
    RETURN SYSTEM.VAL(REAL, s) * 2.0;
  END
END fraction;

PROCEDURE exponent*(x: REAL): INTEGER;
(*
   The value of the call exponent(x) shall be the exponent value of `x'
   that lies between `expoMin' and `expoMax'.  An exception shall occur
   and may be raised if `x' is equal to 0.0.
 *)
BEGIN
  IF x = ZERO THEN RETURN 0 (* NOTE: x=0.0 should raise exception *)
  ELSE
    RETURN SHORT(SYSTEM.LSH(SYSTEM.VAL(SYSTEM.INT32, x), -23) MOD 256) - 127
  END
END exponent;

PROCEDURE sign*(x: REAL): REAL;
(*
   The value of the call sign(x) shall be 1.0 if `x' is greater than 0.0,
   or shall be -1.0 if `x' is less than 0.0, or shall be either 1.0 or
   -1.0 if `x' is equal to 0.0.
*)
BEGIN
  IF x < ZERO THEN RETURN -ONE ELSE RETURN ONE END
END sign;

PROCEDURE scale*(x: REAL; n: INTEGER): REAL;
(*
  The value of the call scale(x,n) shall be the value x*radix^n if such
  a value exists; otherwise an execption shall occur and may be raised.
*)
  VAR exp: LONGINT; lexp: SET;
BEGIN
  IF x = ZERO THEN RETURN ZERO END;
  exp := exponent(x) + n;                           (* new exponent *)
  IF    exp > expoMax THEN RETURN large * sign(x)   (* exception raised here *)
  ELSIF exp < expoMin THEN RETURN small * sign(x)   (* exception here as well *)
  END;
  lexp := SYSTEM.VAL(SYSTEM.SET32, x) * nMask       (* sign and significand *)
        + SYSTEM.VAL(SYSTEM.SET32, SYSTEM.LSH(exp+expOffset, 23));   (* shifted exponent bits *)
  RETURN SYSTEM.VAL(REAL, lexp)
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


PROCEDURE SinCos (x, y, sign: REAL): REAL;
  CONST
    ymax = 9099;           (* ENTIER(pi * 2* * (MantBits/2)) *)
    r1   = -0.1666665668E+0;
    r2   =  0.8333025139E-2;
    r3   = -0.1980741872E-3;
    r4   =  0.2601903036E-5;
  VAR
    n: LONGINT; xn, f, g: REAL;
BEGIN
  IF y >= ymax THEN ErrorHandler(LossOfAccuracy); RETURN ZERO END;

  (* determine the reduced number *)
  n := ENTIER(y * piInv + HALF); xn := n;
  IF ODD(n) THEN sign := -sign END;
  x := ABS(x);
  IF x # y THEN xn := xn - HALF END;

  (* fractional part of reduced number *)
  f := SHORT(ABS(LONG(x)) - LONG(xn) * pi);

  (* Pre: |f| <= pi/2 *)
  IF ABS(f) < Limit THEN RETURN sign * f END;

  (* evaluate polynomial approximation of sin *)
  g := f * f; g := (((r4 * g + r3) * g + r2) * g + r1) * g;
  g := f + f * g;  (* don't use less accurate f(1 + g) *)
  RETURN sign * g
END SinCos;

PROCEDURE div (x, y : LONGINT) : LONGINT;
(* corrected MOD function *)
BEGIN
  IF x < 0 THEN
    (*ASSERT((x DIV y) = ( - ABS(x) DIV y));*) (* x DIV y should already be correct *)
    RETURN -ABS(x) DIV y
  ELSE
    RETURN x DIV y
  END
END div;


(* forward declarations *)
PROCEDURE^ arctan2* (xn, xd: REAL): REAL;
PROCEDURE^ sincos* (x: REAL; VAR Sin, Cos: REAL);

PROCEDURE round* (x: REAL): LONGINT;
  (* Returns the value of x rounded to the nearest integer *)
BEGIN
  IF x < ZERO THEN RETURN -ENTIER(HALF - x)
  ELSE RETURN ENTIER(x + HALF)
  END
END round;

PROCEDURE sqrt* (x: REAL): REAL;
  (* Returns the positive square root of x where x >= 0 *)
  CONST
    P0 = 0.41731; P1 = 0.59016;
  VAR
    xMant, yEst, z: REAL; xExp: INTEGER;
BEGIN
  (* optimize zeros and check for illegal negative roots *)
  IF x = ZERO THEN RETURN ZERO END;
  IF x < ZERO THEN ErrorHandler(IllegalRoot); x := -x END;

  (* reduce the input number to the range 0.5 <= x <= 1.0 *)
  xMant := fraction(x) * HALF; xExp := exponent(x) + 1;

  (* initial estimate of the square root *)
  yEst := P0 + P1 * xMant;

  (* perform two newtonian iterations *)
  z := (yEst + xMant/yEst); yEst := 0.25 * z + xMant/z;

  (* adjust for odd exponents *)
  IF ODD(xExp) THEN yEst := yEst * sqrtHalf; INC(xExp) END;

  (* single Newtonian iteration to produce real number accuracy *)
  RETURN scale(yEst, xExp DIV 2)
END sqrt;

PROCEDURE exp* (x: REAL): REAL;
  (* Returns the exponential of x for x < Ln(MAX(REAL)) *)
  CONST
    ln2 = 0.6931471805599453094172321D0;
    P0 = 0.24999999950E+0; P1 = 0.41602886268E-2; Q1 = 0.49987178778E-1;
  VAR xn, g, p, q, z: REAL; n: LONGINT;
BEGIN
  (* Ensure we detect overflows and return 0 for underflows *)
  IF x >= LnInfinity THEN ErrorHandler(Overflow); RETURN large
  ELSIF x < LnSmall THEN ErrorHandler(Underflow); RETURN ZERO
  ELSIF ABS(x) < eps THEN RETURN ONE
  END;

  (* Decompose and scale the number *)
  n := round(ln2Inv * x);
  xn := n; g := SHORT(LONG(x) - LONG(xn) * ln2);

  (* Calculate exp(g)/2 from "Software Manual for the Elementary Functions" *)
  z := g * g; p := (P1 * z + P0) * g; q := Q1 * z + HALF;
  RETURN scale(HALF + p/(q - p), SHORT(n + 1))
END exp;

PROCEDURE ln* (x: REAL): REAL;
  (* Returns the natural logarithm of x for x > 0 *)
  CONST
    c1 = 355.0/512.0; c2 = -2.121944400546905827679E-4;
    A0 = -0.5527074855E+0; B0 = -0.6632718214E+1;
  VAR f, zn, zd, r, z, w, xn: REAL; n: INTEGER;
BEGIN
  (* ensure illegal inputs are trapped and handled *)
  IF x <= ZERO THEN ErrorHandler(IllegalLog); RETURN -large END;

  (* reduce the range of the input *)
  f := fraction(x) * HALF; n := exponent(x) + 1;
  IF f > sqrtHalf THEN zn := (f - HALF) - HALF; zd := f * HALF + HALF
  ELSE zn := f - HALF; zd := zn * HALF + HALF; DEC(n)
  END;

  (* evaluate rational approximation from "Software Manual for the Elementary Functions" *)
  z := zn/zd; w := z * z; r := z + z * (w * A0/(w + B0));

  (* scale the output *)
  xn := n;
  RETURN (xn * c2 + r) + xn * c1
END ln;

(* The angle in all trigonometric functions is measured in radians *)

PROCEDURE sin* (x: REAL): REAL;
  (* Returns the sine of x for all x *)
BEGIN
  IF x < ZERO THEN RETURN SinCos(x, -x, -ONE)
  ELSE RETURN SinCos(x, x, ONE)
  END
END sin;

PROCEDURE cos* (x: REAL): REAL;
  (* Returns the cosine of x for all x *)
BEGIN
  RETURN SinCos(x, ABS(x) + piByTwo, ONE)
END cos;

PROCEDURE tan* (x: REAL): REAL;
  (* Returns the tangent of x where x cannot be an odd multiple of pi/2 *)
CONST
  ymax = 6434;  (* ENTIER(2 * *(MantBits/2) * pi/2) *)
  twoByPi = 0.63661977236758134308;
  P1 = -0.958017723E-1; Q1 = -0.429135777E+0; Q2 = 0.971685835E-2;
VAR
  n: LONGINT;
  y, xn, f, xnum, xden, g: REAL;
BEGIN
  (* check for error limits *)
  y := ABS(x);
  IF y > ymax THEN ErrorHandler(LossOfAccuracy); RETURN ZERO END;

  (* determine n and the fraction f *)
  n := round(x * twoByPi); xn := n;
  f := SHORT(LONG(x) - LONG(xn) * piByTwo);

  (* check for underflow *)
  IF ABS(f) < Limit THEN xnum := f; xden := ONE
  ELSE g := f * f; xnum := P1 * g*f + f; xden := (Q2 * g + Q1) * g + HALF + HALF
  END;

  (* find the final result *)
  IF ODD(n) THEN RETURN xden/( - xnum)
  ELSE RETURN xnum/xden
  END
END tan;

PROCEDURE asincos (x: REAL; flag: LONGINT; VAR i: LONGINT; VAR res: REAL);
CONST
  P1 = 0.933935835E+0; P2 = -0.504400557E+0;
  Q0 = 0.560363004E+1; Q1 = -0.554846723E+1;
VAR
  y, g, r: REAL;
BEGIN
  y := ABS(x);
  IF y > HALF THEN
    i := 1 - flag;
    IF y > ONE THEN ErrorHandler(IllegalInvTrig); res := large; RETURN END;

    (* reduce the input argument *)
    g := (ONE-y) * HALF; r := -sqrt(g); y := r + r;

    (* compute approximation *)
    r := ((P2 * g + P1) * g)/((g + Q1) * g + Q0);
    res := y + (y * r)
  ELSE
    i := flag;
    IF y < Limit THEN res := y
    ELSE
      g := y * y;

      (* compute approximation *)
      g := ((P2 * g + P1) * g)/((g + Q1) * g + Q0);
      res := y + y * g
    END
  END
END asincos;

PROCEDURE arcsin* (x: REAL): REAL;
  (* Returns the arcsine of x, in the range [ - pi/2, pi/2] where -1 <= x <= 1 *)
VAR
  res: REAL; i: LONGINT;
BEGIN
  asincos(x, 0, i, res);
  IF err # 0 THEN RETURN res END;

  (* adjust result for the correct quadrant *)
  IF i = 1 THEN res := piByFour + (piByFour + res) END;
  IF x < 0 THEN res := -res END;
  RETURN res
END arcsin;

PROCEDURE arccos* (x: REAL): REAL;
  (* Returns the arccosine of x, in the range [0, pi] where -1 <= x <= 1 *)
VAR
  res: REAL; i: LONGINT;
BEGIN
  asincos(x, 1, i, res);
  IF err # 0 THEN RETURN res END;

  (* adjust result for the correct quadrant *)
  IF x < 0 THEN
    IF i = 0 THEN res := piByTwo + (piByTwo + res)
    ELSE res := piByFour + (piByFour + res)
    END
  ELSE
    IF i = 1 THEN res := piByFour + (piByFour - res)
    ELSE res := -res
    END;
  END;
  RETURN res
END arccos;

PROCEDURE atan(f: REAL): REAL;
(* internal arctan algorithm *)
CONST
  rt32 = 0.26794919243112270647;
  rt3 = 1.73205080756887729353;
  a = rt3 - ONE;
  P0 = -0.4708325141E+0; P1 = -0.5090958253E-1; Q0 = 0.1412500740E+1;
  piByThree = 1.04719755119659774615;
  piBySix = 0.52359877559829887308;
VAR
  n: LONGINT; res, g: REAL;
BEGIN
  IF f > ONE THEN f := ONE/f; n := 2
  ELSE n := 0
  END;

  (* check if f should be scaled *)
  IF f > rt32 THEN f := (((a * f - HALF) - HALF) + f)/(rt3 + f); INC(n) END;

  (* check for underflow *)
  IF ABS(f) < Limit THEN res := f
  ELSE
    g := f * f; res := (P1 * g + P0) * g/(g + Q0); res := f + f * res
  END;
  IF n > 1 THEN res := -res END;
  CASE n OF
  | 1: res := res + piBySix
  | 2: res := res + piByTwo
  | 3: res := res + piByThree
  | ELSE (* do nothing *)
  END;
  RETURN res
END atan;

PROCEDURE arctan* (x: REAL): REAL;
  (* Returns the arctangent of x, in the range [ - pi/2, pi/2] for all x *)
BEGIN
  IF x < 0 THEN RETURN -atan( - x)
  ELSE RETURN atan(x)
  END
END arctan;

PROCEDURE power* (base, exp: REAL): REAL;
  (* Returns the value of the number base raised to the power exponent
     for base > 0 *)
  CONST P1 = 0.83357541E-1; K = 0.4426950409;
    Q1 = 0.69314675; Q2 = 0.24018510; Q3 = 0.54360383E-1;
    OneOver16 = 0.0625;
    XMAX = 16 * (expoMax + 1) - 1;
    (* XMIN = 16 * expoMin; *) XMIN = -2016; (* to make it easier for voc; -- noch *)
  VAR z, g, R, v, u2, u1, w1, w2: REAL; w: LONGREAL;
    m, p, i: INTEGER; mp, pp, iw1: LONGINT;
BEGIN
  (* handle all possible error conditions *)
  IF base <= ZERO THEN
    IF base # ZERO THEN ErrorHandler(IllegalPower); base := -base
    ELSIF exp > ZERO THEN RETURN ZERO
    ELSE ErrorHandler(IllegalPower); RETURN large
    END
  END;

  (* extract the exponent of base to m and clear exponent of base in g *)
  g := fraction(base) * HALF;
  m := exponent(base) + 1;

  (* determine p table offset with an unrolled binary search *)
  p := 1;
  IF g <= a1[9] THEN p := 9 END;
  IF g <= a1[p + 4] THEN INC(p, 4) END;
  IF g <= a1[p + 2] THEN INC(p, 2) END;

  (* compute scaled z so that |z| <= 0.044 *)
  z := ((g - a1[p + 1]) - a2[(p + 1) DIV 2])/(g + a1[p + 1]); z := z + z;

  (* approximation for log2(z) from "Software Manual for the Elementary Functions" *)
  v := z * z; R := P1 * v*z; R := R + K * R; u2 := (R + z * K) + z;
  u1 := (m * 16 - p) * OneOver16; w := LONG(exp) * (LONG(u1) + LONG(u2)); (* need extra precision *)

  (* calculations below were modified to work properly -- incorrect in cited reference? *)
  iw1 := ENTIER(16 * w); w1 := iw1 * OneOver16; w2 := SHORT(w - w1);

  (* check for overflow/underflow *)
  IF iw1 > XMAX THEN ErrorHandler(Overflow); RETURN large
  ELSIF iw1 < XMIN THEN ErrorHandler(Underflow); RETURN ZERO
  END;

  (* final approximation 2 * *w2 - 1 where -0.0625 <= w2 <= 0 *)
  IF w2 > ZERO THEN INC(iw1); w2 := w2 - OneOver16 END;
  IF iw1 < 0 THEN i := 0 ELSE i := 1 END;
  mp := div(iw1, 16) + i; pp := 16 * mp - iw1;
  z := ((Q3 * w2 + Q2) * w2 + Q1) * w2;
  z := a1[pp + 1] + a1[pp + 1] * z;
  RETURN scale(z, SHORT(mp))
END power;

PROCEDURE IsRMathException* (): BOOLEAN;
  (* Returns TRUE if the current coroutine is in the exceptional execution state
     because of the raising of the RealMath exception; otherwise returns FALSE.
  *)
BEGIN
  RETURN FALSE
END IsRMathException;


(*
   Following routines are provided as extensions to the ISO standard.
   They are either used as the basis of other functions or provide
   useful functions which are not part of the ISO standard.
 *)

PROCEDURE log* (x, base: REAL): REAL;
(* log(x,base) is the logarithm of x base 'base'.  All positive arguments are
   allowed but base > 0 and base # 1 *)
BEGIN
  (* log(x, base) = ln(x) / ln(base) *)
  IF base <= ZERO THEN ErrorHandler(IllegalLogBase); RETURN -large
  ELSE RETURN ln(x)/ln(base)
  END
END log;

PROCEDURE ipower* (x: REAL; base: INTEGER): REAL;
(* ipower(x, base) returns the x to the integer power base where Log2(x) < expoMax *)
  VAR Exp: INTEGER; y: REAL; neg: BOOLEAN;

  PROCEDURE Adjust(xadj: REAL): REAL;
  BEGIN
    IF (x < ZERO)&ODD(base) THEN RETURN -xadj ELSE RETURN xadj END
  END Adjust;

BEGIN
  (* handle all possible error conditions *)
  IF base = 0 THEN RETURN ONE (* x * *0 = 1 *)
  ELSIF ABS(x) < miny THEN
    IF base > 0 THEN RETURN ZERO ELSE ErrorHandler(Overflow); RETURN Adjust(large) END
  END;

  (* trap potential overflows and underflows *)
  Exp := (exponent(x) + 1) * base; y := LnInfinity * ln2Inv;
  IF Exp > y THEN ErrorHandler(Overflow); RETURN Adjust(large)
  ELSIF Exp< - y THEN RETURN ZERO
  END;

  (* compute x * *base using an optimised algorithm from Knuth, slightly
     altered : p442, The Art Of Computer Programming, Vol 2 *)
  y := ONE; IF base < 0 THEN neg := TRUE; base := -base ELSE neg:= FALSE END;
  LOOP
    IF ODD(base) THEN y := y * x END;
    base := base DIV 2; IF base = 0 THEN EXIT END;
    x := x * x;
  END;
  IF neg THEN RETURN ONE/y ELSE RETURN y END
END ipower;

PROCEDURE sincos* (x: REAL; VAR Sin, Cos: REAL);
(* More efficient sin/cos implementation if both values are needed. *)
BEGIN
  Sin := sin(x); Cos := sqrt(ONE-Sin * Sin)
END sincos;

PROCEDURE arctan2* (xn, xd: REAL): REAL;
(* arctan2(xn,xd) is the quadrant - correct arc tangent atan(xn/xd).  If the
   denominator xd is zero, then the numerator xn must not be zero.  All
   arguments are legal except xn = xd = 0. *)
VAR
  res: REAL; xpdiff: LONGINT;
BEGIN
  (* check for error conditions *)
  IF xd = ZERO THEN
    IF xn = ZERO THEN ErrorHandler(IllegalTrig); RETURN ZERO
    ELSIF xn < 0 THEN RETURN -piByTwo
    ELSE RETURN piByTwo
    END;
  ELSE
    xpdiff := exponent(xn) - exponent(xd);
    IF ABS(xpdiff) >= expoMax - 3 THEN
      (* overflow detected *)
      IF xn < 0 THEN RETURN -piByTwo
      ELSE RETURN piByTwo
      END
    ELSE
      res := ABS(xn/xd);
      IF res # ZERO THEN res := atan(res) END;
      IF xd < ZERO THEN res := pi - res END;
      IF xn < ZERO THEN RETURN -res
      ELSE RETURN res
      END
    END
  END
END arctan2;

PROCEDURE sinh* (x: REAL): REAL;
(* sinh(x) is the hyperbolic sine of x.  The argument x must not be so large
   that exp(|x|) overflows. *)
  CONST P0 = -7.13793159; P1 = -0.190333399; Q0 = -42.8277109;
  VAR y, f: REAL;
BEGIN y := ABS(x);
  IF y <= ONE THEN (* handle small arguments *)
    IF y < Limit THEN RETURN x END;

    (* use approximation from "Software Manual for the Elementary Functions" *)
    f := y * y; y := f * ((f * P1 + P0)/(f + Q0)); RETURN x + x * y
  ELSIF y > LnInfinity THEN (* handle exp overflows *)
    y := y - lnv;
    IF y > LnInfinity - lnv + 0.69 THEN ErrorHandler(Overflow);
      IF x > ZERO THEN RETURN large ELSE RETURN -large END
    ELSE f := exp(y); f := f + f * vbytwo (* don't change to f(1 + vbytwo) *)
    END
  ELSE f := exp(y); f := (f - ONE/f) * HALF
  END;

  (* reach here when 1 < ABS(x) < LnInfinity - lnv + 0.69 *)
  IF x > ZERO THEN RETURN f ELSE RETURN -f END
END sinh;

PROCEDURE cosh* (x: REAL): REAL;
(* cosh(x) is the hyperbolic cosine of x.  The argument x must not be so large
   that exp(|x|) overflows. *)
  VAR y, f: REAL;
BEGIN y := ABS(x);
  IF y > LnInfinity THEN (* handle exp overflows *)
    y := y - lnv;
    IF y > LnInfinity - lnv + 0.69 THEN ErrorHandler(Overflow);
      IF x > ZERO THEN RETURN large ELSE RETURN -large END
    ELSE f := exp(y); RETURN f + f * vbytwo (* don't change to f(1 + vbytwo) *)
    END
  ELSE f := exp(y); RETURN (f + ONE/f) * HALF
  END
END cosh;

PROCEDURE tanh* (x: REAL): REAL;
(* tanh(x) is the hyperbolic tangent of x.  All arguments are legal. *)
  CONST P0 = -0.8237728127; P1 = -0.3831010665E-2; Q0 = 2.471319654; ln3over2 = 0.5493061443;
    BIG = 9.010913347; (* (ln(2) + (t + 1) * ln(B))/2 where t = mantissa bits, B = base *)
  VAR f, t: REAL;
BEGIN f := ABS(x);
  IF f > BIG THEN t := ONE
  ELSIF f > ln3over2 THEN t := ONE - TWO/(exp(TWO * f) + ONE)
  ELSIF f < Limit THEN t := f
  ELSE (* approximation from "Software Manual for the Elementary Functions" *)
    t := f * f; t := t * (P1 * t + P0)/(t + Q0); t := f + f * t
  END;
  IF x < ZERO THEN RETURN -t ELSE RETURN t END
END tanh;

PROCEDURE arcsinh* (x: REAL): REAL;
(* arcsinh(x) is the arc hyperbolic sine of x.  All arguments are legal. *)
BEGIN
  IF ABS(x) > SqrtInfinity * HALF THEN ErrorHandler(HypInvTrigClipped);
    IF x > ZERO THEN RETURN ln(SqrtInfinity) ELSE RETURN -ln(SqrtInfinity) END;
  ELSIF x < ZERO THEN RETURN -ln( - x + sqrt(x * x + ONE))
  ELSE RETURN ln(x + sqrt(x * x + ONE))
  END
END arcsinh;

PROCEDURE arccosh* (x: REAL): REAL;
(* arccosh(x) is the arc hyperbolic cosine of x.  All arguments greater than
   or equal to 1 are legal. *)
BEGIN
  IF x < ONE THEN ErrorHandler(IllegalHypInvTrig); RETURN ZERO
  ELSIF x > SqrtInfinity * HALF THEN ErrorHandler(HypInvTrigClipped); RETURN ln(SqrtInfinity)
  ELSE RETURN ln(x + sqrt(x * x - ONE))
  END
END arccosh;

PROCEDURE arctanh* (x: REAL): REAL;
(* arctanh(x) is the arc hyperbolic tangent of x.  |x| < 1 - sqrt(em), where
   em is machine epsilon.  Note that |x| must not be so close to 1 that the
   result is less accurate than half precision. *)
  CONST TanhLimit = 0.999984991;  (* Tanh(5.9) *)
  VAR t: REAL;
BEGIN t := ABS(x);
  IF (t >= ONE) OR (t > (ONE - TWO * em)) THEN ErrorHandler(IllegalHypInvTrig);
    IF x < ZERO THEN RETURN -TanhMax ELSE RETURN TanhMax END
  ELSIF t > TanhLimit THEN ErrorHandler(LossOfAccuracy)
  END;
  RETURN arcsinh(x/sqrt(ONE - x * x))
END arctanh;

PROCEDURE ToREAL(h: HUGEINT): REAL;
BEGIN RETURN SYSTEM.VAL(REAL, h)
END ToREAL;

BEGIN
  ErrorHandler := DefaultErrorHandler;

  (* determine fundamental constants used by hyperbolic trig functions *)
  em           := ulp(ONE);
  LnInfinity   := ln(large);
  LnSmall      := ln(miny);
  SqrtInfinity := sqrt(large);
  t            := pred(ONE)/sqrt(em);
  TanhMax      := ln(t + sqrt(t * t + ONE));

  (* initialize tables for the power() function a1[i] = 2 * *((1 - i)/16) *)
  a1[1]  := ONE;
  a1[2]  := ToREAL(3F75257DH);
  a1[3]  := ToREAL(3F6AC0C7H);
  a1[4]  := ToREAL(3F60CCDFH);
  a1[5]  := ToREAL(3F5744FDH);
  a1[6]  := ToREAL(3F4E248CH);
  a1[7]  := ToREAL(3F45672AH);
  a1[8]  := ToREAL(3F3D08A4H);
  a1[9]  := ToREAL(3F3504F3H);
  a1[10] := ToREAL(3F2D583FH);
  a1[11] := ToREAL(3F25FED7H);
  a1[12] := ToREAL(3F1EF532H);
  a1[13] := ToREAL(3F1837F0H);
  a1[14] := ToREAL(3F11C3D3H);
  a1[15] := ToREAL(3F0B95C2H);
  a1[16] := ToREAL(3F05AAC3H);
  a1[17] := HALF;

  (* a2[i] = 2 * *[(1 - 2i)/16] - a1[2i]; delta resolution *)
  a2[1] := ToREAL(31A92436H);
  a2[2] := ToREAL(336C2A95H);
  a2[3] := ToREAL(31A8FC24H);
  a2[4] := ToREAL(331F580CH);
  a2[5] := ToREAL(336A42A1H);
  a2[6] := ToREAL(32C12342H);
  a2[7] := ToREAL(32E75624H);
  a2[8] := ToREAL(32CF9890H)
END Math.
