MODULE MathL;

(*  MathL - Oakwood LONGREAL Mathematics.
    Adapted from OOC LowLReal.Mod and LRealMath.Mod

    Target independent mathematical functions for LONGREAL
    (IEEE double-precision) numbers.

    Numerical approximations are taken from "Software Manual for the
    Elementary Functions" by Cody & Waite and "Computer Approximations"
    by Hart et al.

    Copyright (C) 1996-1998 Michael Griebling

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

IMPORT Math, SYSTEM;

CONST
  pi* = 3.1415926535897932384626433832795028841972D0;
  e*  = 2.7182818284590452353602874713526624977572D0;

  places*   = 53;
  large*    = MAX(LONGREAL); (*1.7976931348623157D+308;*)  (* MAX(LONGREAL) *)
(*small*    = 2.2250738585072014D-308; *)
  small*    = 2.2250738585072014/9.9999999999999981D307(*/10^308)*);
  expoMax*  = 1023;
  expoMin*  = 1-expoMax;
  expOffset = expoMax;

  ZERO      = 0.0D0;
  ONE       = 1.0D0;
  HALF      = 0.5D0;
  TWO       = 2.0D0;
  miny      = ONE/large;                 (* Smallest number this package accepts *)
  sqrtHalf  = 0.70710678118654752440D0;
  Limit     = 1.0536712D-8;              (* 2**(-MantBits/2) *)
  eps       = 5.5511151D-17;             (* 2**(-MantBits-1) *)
  piInv     = 0.31830988618379067154D0;  (* 1/pi *)
  piByTwo   = 1.57079632679489661923D0;
  lnv       = 0.6931610107421875D0;      (* should be exact *)
  vbytwo    = 0.13830277879601902638D-4; (* used in sinh/cosh *)
  ln2Inv    = 1.44269504088896340735992468100189213D0;

VAR
  a1:           ARRAY 18 OF LONGREAL; (* lookup table for power function *)
  a2:           ARRAY 9 OF LONGREAL;  (* lookup table for power function *)
  em:           LONGREAL;             (* largest number such that 1 + epsilon > 1.0 *)
  LnInfinity:   LONGREAL;             (* natural log of infinity *)
  LnSmall:      LONGREAL;             (* natural log of very small number *)
  SqrtInfinity: LONGREAL;             (* square root of infinity *)
  TanhMax:      LONGREAL;             (* maximum Tanh value *)
  NumberMask:   SYSTEM.SET64;         (* Sign and significand, {0..51, 63} *)
  ExponentMask: SYSTEM.SET64;         (* Exponent part, {53..62} *)
  ZeroExponent: SYSTEM.SET64;         (* Zero valued exponent {54..61} *)
  t:            LONGREAL;             (* internal variables *)
  i:            INTEGER;              (* For initialisation loops in module body. *)




(* TYPE LONGREAL: 1/sign, 11/exponent, 52/significand *)

PROCEDURE fraction*(x: LONGREAL): LONGREAL;
(*
   The value of the call fraction(x) shall be the significand (or
   significant) part of `x'.  Hence the following relationship shall
   hold: x = scale(fraction(x), exponent(x)).
*)
  VAR s: SYSTEM.SET64;
BEGIN
  IF x = ZERO THEN RETURN ZERO
  ELSE
    s := SYSTEM.VAL(SYSTEM.SET64, x) * NumberMask + ZeroExponent;
    RETURN SYSTEM.VAL(LONGREAL, s) * 2.0;
  END
END fraction;

PROCEDURE exponent*(x: LONGREAL): INTEGER;
(*
   The value of the call exponent(x) shall be the exponent value of `x'
   that lies between `expoMin' and `expoMax'.  An exception shall occur
   and may be raised if `x' is equal to 0.0.
*)
  VAR i: SYSTEM.INT64;
BEGIN
  IF x = ZERO THEN RETURN 0 (* NOTE: x=0.0 should raise exception *)
  ELSE
    i := SYSTEM.LSH(SYSTEM.VAL(SYSTEM.INT64, x), -52) MOD 2048;
    RETURN SYSTEM.VAL(INTEGER, i) - 1023
  END
END exponent;

PROCEDURE sign*(x: LONGREAL): LONGREAL;
(*
   The value of the call sign(x) shall be 1.0 if `x' is greater than 0.0,
   or shall be -1.0 if `x' is less than 0.0, or shall be either 1.0 or
   -1.0 if `x' is equal to 0.0.
*)
BEGIN
  IF x < ZERO THEN RETURN -ONE ELSE RETURN ONE END
END sign;

PROCEDURE scale*(x: LONGREAL; n: INTEGER): LONGREAL;
(*
  The value of the call scale(x,n) shall be the value x*radix^n if such
  a value exists; otherwise an execption shall occur and may be raised.
*)
  VAR exp: HUGEINT; lexp: SYSTEM.SET64;
BEGIN
  IF x = ZERO THEN RETURN ZERO END;
  exp := exponent(x) + n;                           (* new exponent *)
  IF    exp > expoMax THEN RETURN large * sign(x)   (* exception raised here *)
  ELSIF exp < expoMin THEN RETURN small * sign(x)   (* exception here as well *)
  END;
  lexp := SYSTEM.VAL(SYSTEM.SET64, x) * NumberMask  (* sign and significand *)
        + SYSTEM.VAL(SYSTEM.SET64, SYSTEM.LSH(exp + expOffset, 52));  (* shifted exponent bits *)
  RETURN SYSTEM.VAL(LONGREAL, lexp)
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


PROCEDURE SinCos (x, y, sign: LONGREAL): LONGREAL;
  CONST
    ymax = 210828714;    (* ENTIER(pi*2**(MantBits/2)) *)
    c1 = 3.1416015625D0;
    c2 = -8.908910206761537356617D-6;
    r1 = -0.16666666666666665052D+0;
    r2 =  0.83333333333331650314D-2;
    r3 = -0.19841269841201840457D-3;
    r4 =  0.27557319210152756119D-5;
    r5 = -0.25052106798274584544D-7;
    r6 =  0.16058936490371589114D-9;
    r7 = -0.76429178068910467734D-12;
    r8 =  0.27204790957888846175D-14;
  VAR
    n: LONGINT; xn, f, x1, g: LONGREAL;
BEGIN
  IF y >= ymax THEN Math.ErrorHandler(Math.LossOfAccuracy); RETURN ZERO END;

  (* determine the reduced number *)
  n := ENTIER(y*piInv + HALF); xn := n;
  IF ODD(n) THEN sign := -sign END;
  x := ABS(x);
  IF x # y THEN xn := xn-HALF END;

  (* fractional part of reduced number *)
  x1 := ENTIER(x);
  f := ((x1-xn*c1) + (x-x1))-xn*c2;

  (* Pre: |f| <= pi/2 *)
  IF ABS(f) < Limit THEN RETURN sign*f END;

  (* evaluate polynomial approximation of sin *)
  g := f*f; g := (((((((r8*g + r7)*g + r6)*g + r5)*g + r4)*g + r3)*g + r2)*g + r1)*g;
  g := f + f*g;  (* don't use less accurate f(1 + g) *)
  RETURN sign*g
END SinCos;

PROCEDURE div (x, y : LONGINT) : LONGINT;
(* corrected MOD function *)
BEGIN
  IF x < 0 THEN RETURN -ABS(x) DIV y ELSE RETURN x DIV y END
END div;


(* forward declarations *)
PROCEDURE^ arctan2* (xn, xd: LONGREAL): LONGREAL;
PROCEDURE^ sincos* (x: LONGREAL; VAR Sin, Cos: LONGREAL);

PROCEDURE sqrt*(x: LONGREAL): LONGREAL;
  (* Returns the positive square root of x where x >= 0 *)
  CONST
    P0=0.41731; P1=0.59016;
  VAR
    xMant, yEst, z: LONGREAL; xExp: INTEGER;
BEGIN
  (* optimize zeros and check for illegal negative roots *)
  IF x=ZERO THEN RETURN ZERO END;
  IF x < ZERO THEN Math.ErrorHandler(Math.IllegalRoot); x := -x END;

  (* reduce the input number to the range 0.5 <= x <= 1.0 *)
  xMant := fraction(x)*HALF; xExp := exponent(x) + 1;

  (* initial estimate of the square root *)
  yEst := P0 + P1*xMant;

  (* perform three newtonian iterations *)
  z := (yEst + xMant/yEst); yEst := 0.25*z + xMant/z;
  yEst := HALF*(yEst + xMant/yEst);

  (* adjust for odd exponents *)
  IF ODD(xExp) THEN yEst := yEst*sqrtHalf; INC(xExp) END;

  (* single Newtonian iteration to produce real number accuracy *)
  RETURN scale(yEst, xExp DIV 2)
END sqrt;

PROCEDURE exp*(x: LONGREAL): LONGREAL;
  (* Returns the exponential of x for x < Ln(MAX(REAL) *)
  CONST
    c1 =  0.693359375D0;
    c2 = -2.1219444005469058277D-4;
    P0 =  0.249999999999999993D+0;
    P1 =  0.694360001511792852D-2;
    P2 =  0.165203300268279130D-4;
    Q1 =  0.555538666969001188D-1;
    Q2 =  0.495862884905441294D-3;
  VAR xn, g, p, q, z: LONGREAL; n: INTEGER;
BEGIN
  (* Ensure we detect overflows and return 0 for underflows *)
  IF x > LnInfinity THEN Math.ErrorHandler(Math.Overflow); RETURN large
  ELSIF x < LnSmall THEN RETURN ZERO
  ELSIF ABS(x) < eps THEN RETURN ONE
  END;

  (* Decompose and scale the number *)
  IF x >= ZERO THEN n := SHORT(ENTIER(ln2Inv*x + HALF))
  ELSE n := SHORT(ENTIER(ln2Inv*x-HALF))
  END;
  xn := n; g := (x-xn*c1)-xn*c2;

  (* Calculate exp(g)/2 from "Software Manual for the Elementary Functions" *)
  z := g*g; p := ((P2*z + P1)*z + P0)*g; q := (Q2*z + Q1)*z + HALF;
  RETURN scale(HALF + p/(q-p), n + 1)
END exp;

PROCEDURE ln*(x: LONGREAL): LONGREAL;
  (* Returns the natural logarithm of x for x > 0 *)
  CONST
    c1=355.0D0/512.0D0; c2=-2.121944400546905827679D-4;
    P0=-0.64124943423745581147D+2; P1=0.16383943563021534222D+2; P2=-0.78956112887491257267D+0;
    Q0=-0.76949932108494879777D+3; Q1=0.31203222091924532844D+3; Q2=-0.35667977739034646171D+2;
  VAR f, zn, zd, r, z, w, p, q, xn: LONGREAL; n: INTEGER;
BEGIN
  (* ensure illegal inputs are trapped and handled *)
  IF x <= ZERO THEN Math.ErrorHandler(Math.IllegalLog); RETURN -large END;

  (* reduce the range of the input *)
  f := fraction(x)*HALF; n := exponent(x) + 1;
  IF f > sqrtHalf THEN zn := (f-HALF)-HALF; zd := f*HALF + HALF
  ELSE zn := f-HALF; zd := zn*HALF + HALF; DEC(n)
  END;

  (* evaluate rational approximation from "Software Manual for the Elementary Functions" *)
  z := zn/zd; w := z*z; q := ((w + Q2)*w + Q1)*w + Q0; p := w*((P2*w + P1)*w + P0); r := z + z*(p/q);

  (* scale the output *)
  xn := n;
  RETURN (xn*c2 + r) + xn*c1
END ln;


(* The angle in all trigonometric functions is measured in radians *)

PROCEDURE sin* (x: LONGREAL): LONGREAL;
BEGIN
  IF x < ZERO THEN RETURN SinCos(x, -x, -ONE)
  ELSE RETURN SinCos(x, x, ONE)
  END
END sin;

PROCEDURE cos* (x: LONGREAL): LONGREAL;
BEGIN
  RETURN SinCos(x, ABS(x) + piByTwo, ONE)
END cos;

PROCEDURE tan*(x: LONGREAL): LONGREAL;
  (* Returns the tangent of x where x cannot be an odd multiple of pi/2 *)
  VAR Sin, Cos: LONGREAL;
BEGIN
  sincos(x, Sin, Cos);
  IF ABS(Cos) < miny THEN Math.ErrorHandler(Math.IllegalTrig); RETURN large
  ELSE RETURN Sin/Cos
  END
END tan;

PROCEDURE arcsin*(x: LONGREAL): LONGREAL;
  (* Returns the arcsine of x, in the range [-pi/2, pi/2] where -1 <= x <= 1 *)
BEGIN
  IF ABS(x) > ONE THEN Math.ErrorHandler(Math.IllegalInvTrig); RETURN large
  ELSE RETURN arctan2(x, sqrt(ONE-x*x))
  END
END arcsin;

PROCEDURE arccos*(x: LONGREAL): LONGREAL;
  (* Returns the arccosine of x, in the range [0, pi] where -1 <= x <= 1 *)
BEGIN
  IF ABS(x) > ONE THEN Math.ErrorHandler(Math.IllegalInvTrig); RETURN large
  ELSE RETURN arctan2(sqrt(ONE-x*x), x)
  END
END arccos;

PROCEDURE arctan*(x: LONGREAL): LONGREAL;
  (* Returns the arctangent of x, in the range [-pi/2, pi/2] for all x *)
BEGIN
  RETURN arctan2(x, ONE)
END arctan;

PROCEDURE power*(base, exp: LONGREAL): LONGREAL;
  (* Returns the value of the number base raised to the power exponent
     for base > 0 *)
  CONST
    P1=0.83333333333333211405D-1; P2=0.12500000000503799174D-1;
    P3=0.22321421285924258967D-2; P4=0.43445775672163119635D-3;
    K=0.44269504088896340736D0;
    Q1=0.69314718055994529629D+0; Q2=0.24022650695909537056D+0;
    Q3=0.55504108664085595326D-1; Q4=0.96181290595172416964D-2;
    Q5=0.13333541313585784703D-2; Q6=0.15400290440989764601D-3;
    Q7=0.14928852680595608186D-4;
    OneOver16 = 0.0625D0;
    XMAX = 16*expoMax - 1; (*XMIN=16*l.expoMin + 1;*)
    XMIN = -16351; (* noch *)
  VAR z, g, R, v, u2, u1, w1, w2, y1, y2, w: LONGREAL; m, p, i: INTEGER; mp, pp, iw1: LONGINT;
BEGIN
  (* handle all possible error conditions *)
  IF ABS(exp) < miny THEN RETURN ONE (* base**0 = 1 *)
  ELSIF base < ZERO THEN Math.ErrorHandler(Math.IllegalPower); RETURN -large
  ELSIF ABS(base) < miny THEN
    IF exp > ZERO THEN RETURN ZERO ELSE Math.ErrorHandler(Math.Overflow); RETURN -large END
  END;

  (* extract the exponent of base to m and clear exponent of base in g *)
  g := fraction(base)*HALF; m := exponent(base) + 1;

  (* determine p table offset with an unrolled binary search *)
  p := 1;
  IF g <= a1[9] THEN p := 9 END;
  IF g <= a1[p + 4] THEN INC(p, 4) END;
  IF g <= a1[p + 2] THEN INC(p, 2) END;

  (* compute scaled z so that |z| <= 0.044 *)
  z := ((g-a1[p + 1])-a2[(p + 1) DIV 2])/(g + a1[p + 1]); z := z + z;

  (* approximation for log2(z) from "Software Manual for the Elementary Functions" *)
  v := z*z; R := (((P4*v + P3)*v + P2)*v + P1)*v*z; R := R + K*R; u2 := (R + z*K) + z; u1 := (m*16-p)*OneOver16;

  (* generate w with extra precision calculations *)
  y1 := ENTIER(16*exp)*OneOver16; y2 := exp-y1; w := u2*exp + u1*y2;
  w1 := ENTIER(16*w)*OneOver16; w2 := w-w1; w := w1 + u1*y1;
  w1 := ENTIER(16*w)*OneOver16; w2 := w2 + (w-w1); w := ENTIER(16*w2)*OneOver16;
  iw1 := ENTIER(16*(w + w1)); w2 := w2-w;

  (* check for overflow/underflow *)
  IF iw1 > XMAX THEN Math.ErrorHandler(Math.Overflow); RETURN large
  ELSIF iw1 < XMIN THEN RETURN ZERO (* underflow *)
  END;

  (* final approximation 2**w2-1 where -0.0625 <= w2 <= 0 *)
  IF w2 > ZERO THEN INC(iw1); w2 := w2-OneOver16 END; IF iw1 < 0 THEN i := 0 ELSE i := 1 END;
  mp := div(iw1, 16) + i; pp := 16*mp-iw1;
  z := ((((((Q7*w2 + Q6)*w2 + Q5)*w2 + Q4)*w2 + Q3)*w2 + Q2)*w2 + Q1)*w2; z := a1[pp + 1] + a1[pp + 1]*z;
  RETURN scale(z, SHORT(mp))
END power;

PROCEDURE round*(x: LONGREAL): LONGINT;
  (* Returns the value of x rounded to the nearest integer *)
BEGIN
  IF x < ZERO THEN RETURN -ENTIER(HALF-x)
  ELSE RETURN ENTIER(x + HALF)
  END
END round;

PROCEDURE IsRMathException*(): BOOLEAN;
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

PROCEDURE log* (x, base: LONGREAL): LONGREAL;
(* log(x,base) is the logarithm of x base b.  All positive arguments are
   allowed but base > 0 and base # 1. *)
BEGIN
  (* log(x, base) = log2(x) / log2(base) *)
  IF base <= ZERO THEN Math.ErrorHandler(Math.IllegalLogBase); RETURN -large
  ELSE RETURN ln(x)/ln(base)
  END
END log;

PROCEDURE ipower* (x: LONGREAL; base: INTEGER): LONGREAL;
(* ipower(x, base) returns the x to the integer power base where base*Log2(x) < Log2(Max) *)
  VAR y: LONGREAL; neg: BOOLEAN; Exp: LONGINT;

  PROCEDURE Adjust(xadj: LONGREAL): LONGREAL;
  BEGIN
    IF (x < ZERO)&ODD(base) THEN RETURN -xadj ELSE RETURN xadj END
  END Adjust;

BEGIN
  (* handle all possible error conditions *)
  IF base=0 THEN RETURN ONE (* x**0 = 1 *)
  ELSIF ABS(x) < miny THEN
    IF base > 0 THEN RETURN ZERO ELSE Math.ErrorHandler(Math.Overflow); RETURN Adjust(large) END
  END;

  (* trap potential overflows and underflows *)
  Exp := (exponent(x) + 1)*base; y := LnInfinity*ln2Inv;
  IF Exp > y THEN Math.ErrorHandler(Math.Overflow); RETURN Adjust(large)
  ELSIF Exp < -y THEN RETURN ZERO
  END;

  (* compute x**base using an optimised algorithm from Knuth, slightly
     altered : p442, The Art Of Computer Programming, Vol 2 *)
  y := ONE; IF base < 0 THEN neg := TRUE; base := -base ELSE neg:= FALSE END;
  LOOP
    IF ODD(base) THEN y := y*x END;
    base := base DIV 2; IF base=0 THEN EXIT END;
    x := x*x;
  END;
  IF neg THEN RETURN ONE/y ELSE RETURN y END
END ipower;

PROCEDURE sincos* (x: LONGREAL; VAR Sin, Cos: LONGREAL);
(* More efficient sin/cos implementation if both values are needed. *)
BEGIN
  Sin := sin(x); Cos := sqrt(ONE-Sin*Sin)
END sincos;

PROCEDURE arctan2* (xn, xd: LONGREAL): LONGREAL;
(* arctan2(xn,xd) is the quadrant-correct arc tangent atan(xn/xd).  If the
   denominator xd is zero, then the numerator xn must not be zero.  All
   arguments are legal except xn = xd = 0. *)
  CONST
    P0=0.216062307897242551884D+3;  P1=0.3226620700132512059245D+3;
    P2=0.13270239816397674701D+3;   P3=0.1288838303415727934D+2;
    Q0=0.2160623078972426128957D+3; Q1=0.3946828393122829592162D+3;
    Q2=0.221050883028417680623D+3;  Q3=0.3850148650835119501D+2;
    PiOver2=pi/2; Sqrt3=1.7320508075688772935D0;
  VAR atan, z, z2, p, q: LONGREAL; xnExp, xdExp: INTEGER; Quadrant: SHORTINT;
BEGIN
  IF ABS(xd) < miny THEN
    IF ABS(xn) < miny THEN Math.ErrorHandler(Math.IllegalInvTrig); atan := ZERO
    ELSE Math.ErrorHandler(Math.Overflow); atan := PiOver2
    END
  ELSE xnExp := exponent(xn); xdExp := exponent(xd);
    IF xnExp-xdExp >= expoMax-3 THEN Math.ErrorHandler(Math.Overflow); atan := PiOver2
    ELSIF xnExp-xdExp < expoMin + 3 THEN atan := ZERO
    ELSE
      (* ensure division of xn/xd always produces a number < 1 & resolve quadrant *)
      IF ABS(xn) > ABS(xd) THEN z := ABS(xd/xn); Quadrant := 2
      ELSE z := ABS(xn/xd); Quadrant := 0
      END;

      (* further reduce range to within 0 to 2-sqrt(3) *)
      IF z > TWO-Sqrt3 THEN z := (z*Sqrt3-ONE)/(Sqrt3 + z); INC(Quadrant) END;

      (* approximation from "Computer Approximations" table ARCTN 5075 *)
      IF ABS(z) < Limit THEN atan := z (* for small values of z2, return this value *)
      ELSE z2 := z*z; p := (((P3*z2 + P2)*z2 + P1)*z2 + P0)*z; q := (((z2 + Q3)*z2 + Q2)*z2 + Q1)*z2 + Q0; atan := p/q;
      END;

      (* adjust for z's quadrant *)
      IF Quadrant > 1 THEN atan := -atan END;
      CASE Quadrant OF
        1: atan := atan + pi/6
      | 2: atan := atan + PiOver2
      | 3: atan := atan + pi/3
      | ELSE (* angle is correct *)
      END
    END;

    (* map negative xds into the correct quadrant *)
    IF xd < ZERO THEN atan := pi-atan END
  END;

  (* map negative xns into the correct quadrant *)
  IF xn < ZERO THEN atan := -atan END;
  RETURN atan
END arctan2;

PROCEDURE sinh* (x: LONGREAL): LONGREAL;
(* sinh(x) is the hyperbolic sine of x.  The argument x must not be so large
   that exp(|x|) overflows. *)
  CONST
    P0=-0.35181283430177117881D+6; P1=-0.11563521196851768270D+5;
    P2=-0.16375798202630751372D+3; P3=-0.78966127417357099479D+0;
    Q0=-0.21108770058106271242D+7; Q1= 0.36162723109421836460D+5;
    Q2=-0.27773523119650701667D+3;
  VAR y, f, p, q: LONGREAL;
BEGIN y := ABS(x);
  IF y <= ONE THEN (* handle small arguments *)
    IF y < Limit THEN RETURN x END;

    (* use approximation from "Software Manual for the Elementary Functions" *)
    f := y*y; p := ((P3*f + P2)*f + P1)*f + P0; q := ((f + Q2)*f + Q1)*f + Q0; y := f*(p/q); RETURN x + x*y
  ELSIF y > LnInfinity THEN (* handle exp overflows *)
    y := y-lnv;
    IF y > LnInfinity-lnv + 0.69 THEN Math.ErrorHandler(Math.Overflow);
      IF x > ZERO THEN RETURN large ELSE RETURN -large END
    ELSE f := exp(y); f := f + f*vbytwo (* don't change to f(1 + vbytwo) *)
    END
  ELSE f := exp(y); f := (f-ONE/f)*HALF
  END;

  (* reach here when 1 < ABS(x) < LnInfinity-lnv + 0.69 *)
  IF x > ZERO THEN RETURN f ELSE RETURN -f END
END sinh;

PROCEDURE cosh* (x: LONGREAL): LONGREAL;
(* cosh(x) is the hyperbolic cosine of x.  The argument x must not be so large
   that exp(|x|) overflows. *)
  VAR y, f: LONGREAL;
BEGIN y := ABS(x);
  IF y > LnInfinity THEN (* handle exp overflows *)
    y := y-lnv;
    IF y > LnInfinity-lnv + 0.69 THEN Math.ErrorHandler(Math.Overflow);
      IF x > ZERO THEN RETURN large ELSE RETURN -large END
    ELSE f := exp(y); RETURN f + f*vbytwo (* don't change to f(1 + vbytwo) *)
    END
  ELSE f := exp(y); RETURN (f + ONE/f)*HALF
  END
END cosh;

PROCEDURE tanh* (x: LONGREAL): LONGREAL;
(* tanh(x) is the hyperbolic tangent of x.  All arguments are legal. *)
  CONST
    P0=-0.16134119023996228053D+4; P1=-0.99225929672236083313D+2; P2=-0.96437492777225469787D+0;
    Q0= 0.48402357071988688686D+4; Q1= 0.22337720718962312926D+4; Q2= 0.11274474380534949335D+3;
    ln3over2=0.54930614433405484570D0;
    BIG=19.06154747D0; (* (ln(2) + (t + 1)*ln(B))/2 where t=mantissa bits, B=base *)
  VAR f, t: LONGREAL;
BEGIN f := ABS(x);
  IF f > BIG THEN t := ONE
  ELSIF f > ln3over2 THEN t := ONE-TWO/(exp(TWO*f) + ONE)
  ELSIF f < Limit THEN t := f
  ELSE (* approximation from "Software Manual for the Elementary Functions" *)
    t := f*f; t := t*(((P2*t + P1)*t + P0)/(((t + Q2)*t + Q1)*t + Q0)); t := f + f*t
  END;
  IF x < ZERO THEN RETURN -t ELSE RETURN t END
END tanh;

PROCEDURE arcsinh* (x: LONGREAL): LONGREAL;
(* arcsinh(x) is the arc hyperbolic sine of x.  All arguments are legal. *)
BEGIN
  IF ABS(x) > SqrtInfinity*HALF THEN Math.ErrorHandler(Math.HypInvTrigClipped);
    IF x > ZERO THEN RETURN ln(SqrtInfinity) ELSE RETURN -ln(SqrtInfinity) END;
  ELSIF x < ZERO THEN RETURN -ln(-x + sqrt(x*x + ONE))
  ELSE RETURN ln(x + sqrt(x*x + ONE))
  END
END arcsinh;

PROCEDURE arccosh* (x: LONGREAL): LONGREAL;
(* arccosh(x) is the arc hyperbolic cosine of x.  All arguments greater than
   or equal to 1 are legal. *)
BEGIN
  IF x < ONE THEN Math.ErrorHandler(Math.IllegalHypInvTrig); RETURN ZERO
  ELSIF x > SqrtInfinity*HALF THEN Math.ErrorHandler(Math.HypInvTrigClipped); RETURN ln(SqrtInfinity)
  ELSE RETURN ln(x + sqrt(x*x-ONE))
  END
END arccosh;

PROCEDURE arctanh* (x: LONGREAL): LONGREAL;
(* arctanh(x) is the arc hyperbolic tangent of x.  |x| < 1 - sqrt(em), where
   em is machine epsilon.  Note that |x| must not be so close to 1 that the
   result is less accurate than half precision. *)
  CONST TanhLimit=0.999984991D0;  (* Tanh(5.9) *)
  VAR t: LONGREAL;
BEGIN t := ABS(x);
  IF (t >= ONE) OR (t > (ONE-TWO*em)) THEN Math.ErrorHandler(Math.IllegalHypInvTrig);
    IF x < ZERO THEN RETURN -TanhMax ELSE RETURN TanhMax END
  ELSIF t > TanhLimit THEN Math.ErrorHandler(Math.LossOfAccuracy)
  END;
  RETURN arcsinh(x/sqrt(ONE-x*x))
END arctanh;

PROCEDURE ToLONGREAL(h: HUGEINT): LONGREAL;
BEGIN RETURN SYSTEM.VAL(LONGREAL, h)
END ToLONGREAL;

BEGIN
  (* Initialise masks.  *)
  NumberMask := {}; INCL(NumberMask, 63);
  FOR i := 0 TO 51 DO INCL(NumberMask, i) END;
  ExponentMask := -NumberMask;
  ZeroExponent := {};
  FOR i := 53 TO 61 DO INCL(ZeroExponent, i) END;

  (* determine some fundamental constants used by hyperbolic trig functions *)
  em           := ulp(ONE);
  LnInfinity   := ln(large);
  LnSmall      := ln(miny);
  SqrtInfinity := sqrt(large);
  t            := pred(ONE)/sqrt(em);
  TanhMax      := ln(t + sqrt(t*t + ONE));

  (* initialize some tables for the power() function a1[i]=2**((1-i)/16) *)
  (* disable compiler warnings about 32-bit negative integers *)
  (* < * PUSH; Warnings := FALSE * > *)
  a1[ 1] := ONE;
  a1[ 2] := ToLONGREAL(3FEEA4AFA2A490DAH);
  a1[ 3] := ToLONGREAL(3FED5818DCFBA487H);
  a1[ 4] := ToLONGREAL(3FEC199BDD85529CH);
  a1[ 5] := ToLONGREAL(3FEAE89F995AD3ADH);
  a1[ 6] := ToLONGREAL(3FE9C49182A3F090H);
  a1[ 7] := ToLONGREAL(3FE8ACE5422AA0DBH);
  a1[ 8] := ToLONGREAL(3FE7A11473EB0186H);
  a1[ 9] := ToLONGREAL(3FE6A09E667F3BCCH);
  a1[10] := ToLONGREAL(3FE5AB07DD485429H);
  a1[11] := ToLONGREAL(3FE4BFDAD5362A27H);
  a1[12] := ToLONGREAL(3FE3DEA64C123422H);
  a1[13] := ToLONGREAL(3FE306FE0A31B715H);
  a1[14] := ToLONGREAL(3FE2387A6E756238H);
  a1[15] := ToLONGREAL(3FE172B83C7D517AH);
  a1[16] := ToLONGREAL(3FE0B5586CF9890FH);
  a1[17] := HALF;

  (* a2[i]=2**[(1-2i)/16] - a1[2i]; delta resolution *)
  a2[1] := ToLONGREAL(3C90B1EE74320000H);
  a2[2] := ToLONGREAL(3C71106589500000H);
  a2[3] := ToLONGREAL(3C6C7C46B0700000H);
  a2[4] := ToLONGREAL(3C9AFAA2047F0000H);
  a2[5] := ToLONGREAL(3C86324C05460000H);
  a2[6] := ToLONGREAL(3C7ADA0911F00000H);
  a2[7] := ToLONGREAL(3C89B07EB6C80000H);
  a2[8] := ToLONGREAL(3C88A62E4ADC0000H);

  (* reenable compiler warnings *)
  (* < * POP * > *)
END MathL.

