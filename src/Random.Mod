MODULE Random;
IMPORT Platform;
CONST modulo* = 2147483647; (* =2^31-1 *)
VAR seed*: INTEGER;

PROCEDURE Time(): INTEGER;
RETURN Platform.Time() END Time;

(* Set random seed value. Any values are allowed, although
   values not in [1..2^31-2] will be mapped into this range. *)
PROCEDURE PutSeed*(newSeed: INTEGER);
BEGIN newSeed := newSeed MOD modulo;
  IF newSeed = 0 THEN seed := 1 ELSE seed := newSeed END
END PutSeed;

PROCEDURE NextRND;
CONST a = 16807;
  q = 127773; (* m div a *)
  r = 2836;   (* m mod a *)
VAR lo, hi, test: INTEGER;
BEGIN hi := seed DIV q; lo := seed MOD q;
  test := a * lo - r * hi;
  IF test > 0 THEN seed := test ELSE seed := test + modulo END
END NextRND;

(* Calculates a new number. range has to be included in
   [1..2^31-2]. Result is a number from 0, 1, ... , range-1. *)
PROCEDURE Int*(range: INTEGER): INTEGER;
BEGIN NextRND
RETURN seed MOD range END Int;

(* Calculates a number x with 0.0 <= x < 1.0. *)
PROCEDURE Uniform*(): REAL;
BEGIN NextRND
RETURN (seed - 1) * (1 / (modulo - 1)) END Uniform;

PROCEDURE Randomize*;
BEGIN PutSeed(Time())
END Randomize;

BEGIN Randomize
END Random.
