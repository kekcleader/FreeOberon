(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethRandomNumbers;  (** portable *)
(* Random Number Generator, page 12 *)
IMPORT Math := oocOakMath, Oberon := Platform, SYSTEM;

VAR Z, t, d: LONGINT;

(** Return a uniform random number r, with 0 < r < 1. *)

PROCEDURE Uniform*(): REAL;
CONST
a = 16807;  m = 2147483647; 
q = m DIV a;  r = m MOD a;
VAR g: LONGINT;
BEGIN
  g := a*(Z MOD q) - r*(Z DIV q);
  IF g > 0 THEN Z := g ELSE Z := g + m END;
  RETURN SHORT(Z*1.0D0/m)  (* must compute this in double precision, e.g. (m-1)/m *)
END Uniform;

(** Return an exponentially distributed random number r. *)

PROCEDURE Exp*(mu: REAL): REAL;
BEGIN
  RETURN -Math.ln(Uniform())/mu
END Exp;

(** Initialize the random number seed. *)

PROCEDURE InitSeed*(seed: LONGINT);
BEGIN
  Z := seed
END InitSeed;

BEGIN
  Oberon.GetClock(t, d);
  Z := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, t) / SYSTEM.VAL(SET, d))
END ethRandomNumbers.  (* Copyright M. Reiser, 1992 *)
