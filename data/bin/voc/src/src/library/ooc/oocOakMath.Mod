(*	$Id: OakMath.Mod,v 1.1 1997/02/07 07:45:32 oberon1 Exp $	*)
MODULE oocOakMath;

IMPORT RealMath := oocRealMath;
  
  
CONST
  pi* = RealMath.pi;
  e* = RealMath.exp1;
  
PROCEDURE sqrt* (x: REAL): REAL;
(* sqrt(x) returns the square root of x, where x must be positive. *)
  BEGIN
    RETURN RealMath.sqrt (x)
  END sqrt;
  
PROCEDURE power* (x, base: REAL): REAL;             
(* power(x, base) returns the x to the power base. *)
  BEGIN
    RETURN RealMath.power (x, base)
  END power;

PROCEDURE exp* (x: REAL): REAL;
(* exp(x) is the exponential of x base e.  x must not be so small that this 
   exponential underflows nor so large that it overflows. *)
  BEGIN
    RETURN RealMath.exp (x)
  END exp;

PROCEDURE ln* (x: REAL): REAL;  
(* ln(x) returns the natural logarithm (base e) of x. *)
  BEGIN
    RETURN RealMath.ln (x)
  END ln;

PROCEDURE log* (x, base: REAL): REAL;
(* log(x,base) is the logarithm of x base b.  All positive arguments are 
   allowed.  The base b must be positive. *)
  BEGIN
    RETURN RealMath.log (x, base)
  END log;
   
PROCEDURE round* (x: REAL): REAL;
(* round(x) if fraction part of x is in range 0.0 to 0.5 then the result is 
   the largest integer not greater than x, otherwise the result is x rounded 
   up to the next highest whole number.  Note that integer values cannot always
   be exactly represented in REAL or REAL format. *)
  BEGIN
    RETURN RealMath.round (x)
  END round;

PROCEDURE sin* (x: REAL): REAL;
  BEGIN
    RETURN RealMath.sin (x)
  END sin;
  
PROCEDURE cos* (x: REAL): REAL;
  BEGIN
    RETURN RealMath.cos (x)
  END cos;

PROCEDURE tan* (x: REAL): REAL;
(* sin, cos, tan(x) returns the sine, cosine or tangent value of x, where x is
   in radians. *)
  BEGIN
    RETURN RealMath.tan (x)
  END tan;

PROCEDURE arcsin* (x: REAL): REAL;
  BEGIN
    RETURN RealMath.arcsin (x)
  END arcsin;
  
PROCEDURE arccos* (x: REAL): REAL;
  BEGIN
    RETURN RealMath.arccos (x)
  END arccos;

PROCEDURE arctan* (x: REAL): REAL;
(* arcsin, arcos, arctan(x) returns the arcsine, arcos, arctan value in radians
   of x, where x is in the sine, cosine or tangent value. *)
  BEGIN
    RETURN RealMath.arctan (x)
  END arctan;

PROCEDURE arctan2* (xn, xd: REAL): REAL;
(* arctan2(xn,xd) is the quadrant-correct arc tangent atan(xn/xd).  If the 
   denominator xd is zero, then the numerator xn must not be zero.  All
   arguments are legal except xn = xd = 0. *)
  BEGIN
    RETURN RealMath.arctan2 (xn, xd)
  END arctan2;


PROCEDURE sinh* (x: REAL): REAL;
(* sinh(x) is the hyperbolic sine of x.  The argument x must not be so large 
   that exp(|x|) overflows. *) 
  BEGIN
    RETURN RealMath.sinh (x)
  END sinh;
  
PROCEDURE cosh* (x: REAL): REAL;
(* cosh(x) is the hyperbolic cosine of x.  The argument x must not be so large
   that exp(|x|) overflows. *)
  BEGIN
    RETURN RealMath.cosh (x)
  END cosh;
   
PROCEDURE tanh* (x: REAL): REAL;
(* tanh(x) is the hyperbolic tangent of x.  All arguments are legal. *)
  BEGIN
    RETURN RealMath.tanh (x)
  END tanh;

PROCEDURE arcsinh* (x: REAL): REAL;
(* arcsinh(x) is the arc hyperbolic sine of x.  All arguments are legal. *)
  BEGIN
    RETURN RealMath.arcsinh (x)
  END arcsinh;

PROCEDURE arccosh* (x: REAL): REAL;
(* arccosh(x) is the arc hyperbolic cosine of x.  All arguments greater than 
   or equal to 1 are legal. *)
  BEGIN
    RETURN RealMath.arccosh (x)
  END arccosh;
   
PROCEDURE arctanh* (x: REAL): REAL;
(* arctanh(x) is the arc hyperbolic tangent of x.  |x| < 1 - sqrt(em), where 
   em is machine epsilon.  Note that |x| must not be so close to 1 that the 
   result is less accurate than half precision. *)
  BEGIN
    RETURN RealMath.arctanh (x)
  END arctanh;


END oocOakMath.
