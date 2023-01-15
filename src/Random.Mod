MODULE Random;
(** A simple and fast pseudo-random number generator *)

IMPORT Platform;
CONST modulo* = 2147483647; (* =2^31-1 *)
VAR seed*: INTEGER;

PROCEDURE Time(): INTEGER;
RETURN Platform.Time() END Time;

(** Sets the value of the random seed. Any values are allowed, although
    values that are not in [1..2^31 - 2] range will be mapped into this range.
     The same random seed results in the same sequence of random numbers *)
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

(** Returns a random integer number from 0 to (range - 1).
     For example, Int(6) may return a number from 0 to 5.
     `range` must be in range [1; 2^31 - 2]. *)
PROCEDURE Int*(range: INTEGER): INTEGER;
BEGIN NextRND
RETURN seed MOD range END Int;

(** Returns a random real number x, where 0 <= x < 1. *)
PROCEDURE Uniform*(): REAL;
BEGIN NextRND
RETURN (seed - 1) * (1 / (modulo - 1)) END Uniform;

(** Initializes the randomization process using current time.
    This procedure is called automatically on module initialization *)
PROCEDURE Randomize*;
BEGIN PutSeed(Time())
END Randomize;

BEGIN Randomize
END Random.
