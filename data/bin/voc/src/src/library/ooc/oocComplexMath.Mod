(*	$Id: ComplexMath.Mod,v 1.5 1999/09/02 13:05:36 acken Exp $	*)
MODULE oocComplexMath;
 
 (*
    ComplexMath - Mathematical functions for the type COMPLEX.   
    
    Copyright (C) 1995-1996 Michael Griebling
 
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
  
IMPORT m := oocRealMath;
  
TYPE
  COMPLEX * = POINTER TO COMPLEXDesc;
  COMPLEXDesc = RECORD
    r, i : REAL
  END;
  
CONST
  ZERO=0.0; HALF=0.5; ONE=1.0; TWO=2.0;
  
VAR
  i-, one-, zero- : COMPLEX;
  
PROCEDURE CMPLX * (r, i: REAL): COMPLEX;
VAR c: COMPLEX;
BEGIN
  NEW(c); c.r:=r; c.i:=i;
  RETURN c
END CMPLX;

(* 
   NOTE: This function provides the only way
   of reliably assigning COMPLEX numbers.  DO 
   NOT use ` a := b' where a, b are COMPLEX!
 *)
PROCEDURE Copy * (z: COMPLEX): COMPLEX;
BEGIN
  RETURN CMPLX(z.r, z.i)
END Copy;

PROCEDURE RealPart * (z: COMPLEX): REAL;
BEGIN
  RETURN z.r
END RealPart;

PROCEDURE ImagPart * (z: COMPLEX): REAL;
BEGIN
  RETURN z.i
END ImagPart;

PROCEDURE add * (z1, z2: COMPLEX): COMPLEX;
BEGIN
  RETURN CMPLX(z1.r+z2.r, z1.i+z2.i)
END add;

PROCEDURE sub * (z1, z2: COMPLEX): COMPLEX;
BEGIN
  RETURN CMPLX(z1.r-z2.r, z1.i-z2.i)
END sub;

PROCEDURE mul * (z1, z2: COMPLEX): COMPLEX;
BEGIN
  RETURN CMPLX(z1.r*z2.r-z1.i*z2.i, z1.r*z2.i+z1.i*z2.r)
END mul;
  
PROCEDURE div * (z1, z2: COMPLEX): COMPLEX;
  VAR d, h: REAL;
BEGIN
  (* Note: this algorith avoids overflow by avoiding
     multiplications and using divisions instead so that:
     
     Re(z1/z2) = (z1.r*z2.r+z1.i*z2.i)/(z2.r^2+z2.i^2)
               = (z1.r+z1.i*z2.i/z2.r)/(z2.r+z2.i^2/z2.r)
               = (z1.r+h*z1.i)/(z2.r+h*z2.i)
     Im(z1/z2) = (z1.i*z2.r-z1.r*z2.i)/(z2.r^2+z2.i^2)
               = (z1.i-z1.r*z2.i/z2.r)/(z2.r+z2.i^2/z2.r)
               = (z1.i-h*z1.r)/(z2.r+h*z2.i)
               
     where h=z2.i/z2.r, provided z2.i<=z2.r and similarly 
     for z2.i>z2.r we have:
     
     Re(z1/z2) = (h*z1.r+z1.i)/(h*z2.r+z2.i)
     Im(z1/z2) = (h*z1.i-z1.r)/(h*z2.r+z2.i) 
     
     where h=z2.r/z2.i *)
     
  (* we always guarantee h<=1 *)
  IF ABS(z2.r)>ABS(z2.i) THEN 
    h:=z2.i/z2.r; d:=z2.r+h*z2.i;
    RETURN CMPLX((z1.r+h*z1.i)/d, (z1.i-h*z1.r)/d)
  ELSE
    h:=z2.r/z2.i; d:=h*z2.r+z2.i;
    RETURN CMPLX((h*z1.r+z1.i)/d, (h*z1.i-z1.r)/d)
  END
END div;
  
PROCEDURE abs * (z: COMPLEX): REAL;
  (* Returns the length of z *)
VAR
  r, i, h: REAL;
BEGIN
  (* Note: this algorithm avoids overflow by avoiding
     multiplications and using divisions instead so that:
           
     abs(z) =  sqrt(z.r*z.r+z.i*z.i)
            =  sqrt(z.r^2*(1+(z.i/z.r)^2))
            =  z.r*sqrt(1+(z.i/z.r)^2)
           
     where z.i/z.r <= 1.0 by swapping z.r & z.i so that
     for z.r>z.i we have z.r*sqrt(1+(z.i/z.r)^2) and
     otherwise we have z.i*sqrt(1+(z.r/z.i)^2) *)
  r:=ABS(z.r); i:=ABS(z.i);
  IF i>r THEN h:=i; i:=r; r:=h END; (* guarantees i<=r *)
  IF i=ZERO THEN RETURN r END;      (* i=0, so sqrt(0+r^2)=r *)
  h:=i/r;
  RETURN r*m.sqrt(ONE+h*h)          (* r*sqrt(1+(i/r)^2) *)
END abs;
 
PROCEDURE arg * (z: COMPLEX): REAL;
  (* Returns the angle that z subtends to the positive real axis, in the range [-pi, pi] *)
BEGIN
  RETURN m.arctan2(z.i, z.r)
END arg;
  
PROCEDURE conj * (z: COMPLEX): COMPLEX;
  (* Returns the complex conjugate of z *)
BEGIN
  RETURN CMPLX(z.r, -z.i)
END conj;
  
PROCEDURE power * (base: COMPLEX; exponent: REAL): COMPLEX;
  (* Returns the value of the number base raised to the power exponent *)
VAR c, s, r: REAL;
BEGIN
  m.sincos(arg(base)*exponent, s, c); r:=m.power(abs(base), exponent);
  RETURN CMPLX(c*r, s*r)
END power;
 
PROCEDURE sqrt * (z: COMPLEX): COMPLEX;
  (* Returns the principal square root of z, with arg in the range [-pi/2, pi/2] *)
VAR u, v: REAL;
BEGIN
  (* Note: the following algorithm is more efficient since
     it doesn't require a sincos or arctan evaluation:
     
     Re(sqrt(z)) = sqrt((abs(z)+z.r)/2), Im(sqrt(z)) = +/-sqrt((abs(z)-z.r)/2)
                 = u                                 = +/-v
       
     where z.r >= 0 and z.i = 2*u*v and unknown sign is sign of z.i *)
     
  (* initially force z.r >= 0 to calculate u, v *)
  u:=m.sqrt((abs(z)+ABS(z.r))*HALF); 
  IF z.i#ZERO THEN v:=(HALF*z.i)/u ELSE v:=ZERO END; (* slight optimization *)
  
  (* adjust u, v for the signs of z.r and z.i *)
  IF z.r>=ZERO THEN RETURN CMPLX(u, v)    (* no change *)
  ELSIF z.i>=ZERO THEN RETURN CMPLX(v, u) (* z.r<0 so swap u, v *)
  ELSE RETURN CMPLX(-v, -u)               (* z.r<0, z.i<0 *)
  END
END sqrt;
 
PROCEDURE exp * (z: COMPLEX): COMPLEX;
  (* Returns the complex exponential of z *)
VAR c, s, e: REAL; 
BEGIN
  m.sincos(z.i, s, c); e:=m.exp(z.r);
  RETURN CMPLX(e*c, e*s)
END exp;
 
PROCEDURE ln * (z: COMPLEX): COMPLEX;
  (* Returns the principal value of the natural logarithm of z *)
BEGIN
  RETURN CMPLX(m.ln(abs(z)), arg(z))
END ln;
 
PROCEDURE sin * (z: COMPLEX): COMPLEX;
  (* Returns the sine of z *)
  VAR s, c: REAL;
BEGIN
  m.sincos(z.r, s, c);
  RETURN CMPLX(s*m.cosh(z.i), c*m.sinh(z.i))
END sin;
 
PROCEDURE cos * (z: COMPLEX): COMPLEX;
  (* Returns the cosine of z *)
  VAR s, c: REAL;
BEGIN
  m.sincos(z.r, s, c);
  RETURN CMPLX(c*m.cosh(z.i), -s*m.sinh(z.i))
END cos;
 
PROCEDURE tan * (z: COMPLEX): COMPLEX;
  (* Returns the tangent of z *)
  VAR s, c, y, d: REAL;
BEGIN
  m.sincos(TWO*z.r, s, c); 
  y:=TWO*z.i; d:=c+m.cosh(y);
  RETURN CMPLX(s/d, m.sinh(y)/d)
END tan;

PROCEDURE CalcAlphaBeta(z: COMPLEX; VAR a, b: REAL);
  VAR x, x2, y, r, t: REAL;
BEGIN x:=z.r+ONE; x:=x*x; y:=z.i*z.i;
  x2:=z.r-ONE; x2:=x2*x2;
  r:=m.sqrt(x+y); t:=m.sqrt(x2+y);
  a:=HALF*(r+t); b:=HALF*(r-t);
END CalcAlphaBeta;
 
PROCEDURE arcsin * (z: COMPLEX): COMPLEX;
  (* Returns the arcsine of z *)
  VAR a, b: REAL;
BEGIN
  CalcAlphaBeta(z, a, b);
  RETURN CMPLX(m.arcsin(b), m.ln(a+m.sqrt(a*a-1)))
END arcsin;
 
PROCEDURE arccos * (z: COMPLEX): COMPLEX;
  (* Returns the arccosine of z *)
  VAR a, b: REAL;
BEGIN
  CalcAlphaBeta(z, a, b);
  RETURN CMPLX(m.arccos(b), -m.ln(a+m.sqrt(a*a-1)))
END arccos;
 
PROCEDURE arctan * (z: COMPLEX): COMPLEX;
  (* Returns the arctangent of z *)
  VAR x, y, yp, x2, y2: REAL;
BEGIN
  x:=TWO*z.r; y:=z.i+ONE; y:=y*y;
  yp:=z.i-ONE; yp:=yp*yp;
  x2:=z.r*z.r; y2:=z.i*z.i;
  RETURN CMPLX(HALF*m.arctan(x/(ONE-x2-y2)), 0.25*m.ln((x2+y)/(x2+yp)))
END arctan;
 
PROCEDURE polarToComplex * (abs, arg: REAL): COMPLEX;
  (* Returns the complex number with the specified polar coordinates *)
BEGIN
  RETURN CMPLX(abs*m.cos(arg), abs*m.sin(arg))
END polarToComplex;
 
PROCEDURE scalarMult * (scalar: REAL; z: COMPLEX): COMPLEX;
  (* Returns the scalar product of scalar with z *)
BEGIN
  RETURN CMPLX(z.r*scalar, z.i*scalar)
END scalarMult;
 
PROCEDURE IsCMathException * (): BOOLEAN;
  (* Returns TRUE if the current coroutine is in the exceptional execution state
     because of the ComplexMath exception; otherwise returns FALSE.
  *)
BEGIN
  RETURN FALSE
END IsCMathException;

BEGIN
  i:=CMPLX (ZERO, ONE);
  one:=CMPLX (ONE, ZERO);
  zero:=CMPLX (ZERO, ZERO)
END oocComplexMath.
