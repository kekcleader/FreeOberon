(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethReals;  (** portable *)

(** Implementation of the non-portable components of IEEE REAL and
LONGREAL manipulation. The routines here are required to do conversion
of reals to strings and back.
Implemented by Bernd Moesli, Seminar for Applied Mathematics,
Swiss Federal Institute of Technology Z…rich.
*)

IMPORT SYSTEM, Modules;

(* Bernd Moesli
  Seminar for Applied Mathematics
  Swiss Federal Institute of Technology Zurich
  Copyright 1993

  Support module for IEEE floating-point numbers

  Please change constant definitions of H, L depending on byte ordering
  Use bm.TestReals.Do for testing the implementation.

  Expo, ExpoL return the shifted binary exponent (0 <= e < 256 (2048 resp.))
  SetExpo, SetExpoL set the shifted binary exponent
  Real, RealL convert hexadecimals to reals
  Int, IntL convert reals to hexadecimals
  Ten returns 10^e (e <= 308, 308 < e delivers NaN)

  1993.4.22  IEEE format only, 32-bits LONGINTs only
  30.8.1993  mh: changed RealX to avoid compiler warnings;
  7.11.1995  jt: dynamic endianess test
  22.01.97  pjm: NaN stuff (using quiet NaNs only to avoid traps)
  05.01.98  prk: NaN with INF support
  17.02.16  dcb: Adapt for 32 bit INTEGER and 64 bit LONGINT.
*)

VAR
  DefaultFCR*: SET;
  tene: ARRAY 23 OF LONGREAL; (* e = 0..22: exact values of 10^e *)
  ten: ARRAY 27 OF LONGREAL;
  eq, gr: ARRAY 20 OF SET;
  H, L: INTEGER;

(** Returns the shifted binary exponent (0 <= e < 256). *)
PROCEDURE Expo* (x: REAL): LONGINT;
BEGIN
  IF SIZE(INTEGER) = 4 THEN
    RETURN SHORT(ASH(SYSTEM.VAL(INTEGER, x), -23)) MOD 256
  ELSIF SIZE(LONGINT) = 4 THEN
    RETURN SHORT(ASH(SYSTEM.VAL(LONGINT, x), -23)) MOD 256
  ELSE Modules.Halt(-15);
  END
END Expo;

(** Returns the shifted binary exponent (0 <= e < 2048). *)
PROCEDURE ExpoL* (x: LONGREAL): LONGINT;
  VAR i: LONGINT;
BEGIN
  IF SIZE(LONGINT) = 8 THEN
    RETURN ASH(SYSTEM.VAL(LONGINT, x), -50) MOD 256
  ELSE
    SYSTEM.GET(SYSTEM.ADR(x) + H, i); RETURN ASH(i, -20) MOD 2048
  END
END ExpoL;

(** Sets the shifted binary exponent. *)
PROCEDURE SetExpo* (e: INTEGER; VAR x: REAL);
  VAR i: INTEGER; l: LONGINT;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x), l);
    l := ASH(ASH(ASH(l, -31), 8) + e MOD 256, 23) + l MOD ASH(1, 23);
    SYSTEM.PUT(SYSTEM.ADR(x), l)
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x), i);
    i := SHORT(ASH(ASH(ASH(i, -31), 8) + e MOD 256, 23) + i MOD ASH(1, 23));
    SYSTEM.PUT(SYSTEM.ADR(x), i)
  ELSE Modules.Halt(-15)
  END
END SetExpo;

(** Sets the shifted binary exponent. *)
PROCEDURE SetExpoL* (e: LONGINT; VAR x: LONGREAL);
  VAR i: INTEGER; l: LONGINT;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x) + H, l);
    l := ASH(ASH(ASH(l, -31), 11) + e MOD 2048, 20) + l MOD ASH(1, 20);
    SYSTEM.PUT(SYSTEM.ADR(x) + H, l)
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x) + H, i);
    i := SHORT(ASH(ASH(ASH(i, -31), 11) + e MOD 2048, 20) + i MOD ASH(1, 20));
    SYSTEM.PUT(SYSTEM.ADR(x) + H, i)
  ELSE Modules.Halt(-15)
  END
END SetExpoL;

(** Convert hexadecimal to REAL. *)
PROCEDURE Real* (h: LONGINT): REAL;
  VAR x: REAL;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(x), h)
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(x), SYSTEM.VAL(INTEGER, h))
  ELSE Modules.Halt(-15)
  END;
  RETURN x
END Real;

(** Convert hexadecimal to LONGREAL. h and l are the high and low parts.*)
PROCEDURE RealL* (h, l: LONGINT): LONGREAL;
  VAR x: LONGREAL;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(x) + H, h);
    SYSTEM.PUT(SYSTEM.ADR(x) + L, l)
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(x) + H, SYSTEM.VAL(INTEGER, h));
    SYSTEM.PUT(SYSTEM.ADR(x) + L, SYSTEM.VAL(INTEGER, l))
  ELSE Modules.Halt(-15)
  END;
  RETURN x
END RealL;

(** Convert REAL to hexadecimal. *)
PROCEDURE Int* (x: REAL): LONGINT;
  VAR i: INTEGER; l: LONGINT;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(l), x); RETURN l
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.PUT(SYSTEM.ADR(i), x); RETURN i
  ELSE Modules.Halt(-15)
  END
END Int;

(** Convert LONGREAL to hexadecimal. h and l are the high and low parts. *)
PROCEDURE IntL* (x: LONGREAL; VAR h, l: LONGINT);
  VAR i: INTEGER;
BEGIN
  IF SIZE(LONGINT) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x) + H, h);
    SYSTEM.GET(SYSTEM.ADR(x) + L, l)
  ELSIF SIZE(INTEGER) = 4 THEN
    SYSTEM.GET(SYSTEM.ADR(x) + H, i); h := i;
    SYSTEM.GET(SYSTEM.ADR(x) + L, i); l := i
  ELSE Modules.Halt(-15)
  END
END IntL;

(** Returns 10^e (e <= 308, 308 < e delivers IEEE-code +INF). *)
PROCEDURE Ten* (e: LONGINT): LONGREAL;
  VAR E: LONGINT; r: LONGREAL;
BEGIN
  IF e < -307 THEN RETURN 0 ELSIF 308 < e THEN RETURN RealL(2146435072, 0) END;
  INC(e, 307); r:= ten[e DIV 23] * tene[e MOD 23];
  IF e MOD 32 IN eq[e DIV 32] THEN RETURN r
  ELSE
    E:= ExpoL(r); SetExpoL(1023+52, r);
    IF e MOD 32 IN gr[e DIV 32] THEN r:= r-1 ELSE r:= r+1 END;
    SetExpoL(E, r); RETURN r
  END
END Ten;

(** Returns the NaN code (0 <= c < 8399608) or -1 if not NaN/Infinite. *)
PROCEDURE NaNCode* (x: REAL): LONGINT;
  VAR e: LONGINT;
BEGIN
  IF Expo(x) = 255 THEN  (* Infinite or NaN *)
    RETURN SYSTEM.VAL(LONGINT, x) MOD 800000H  (* lowest 23 bits *)
  ELSE
    RETURN -1
  END
END NaNCode;

(** Returns the NaN code (0 <= h < 1048576, MIN(LONGINT) <= l <= MAX(LONGINT)) or (-1,-1) if not NaN/Infinite. *)
PROCEDURE NaNCodeL* (x: LONGREAL;  VAR h, l: LONGINT);
BEGIN
  IntL(x, h, l);
  IF ASH(h, -20) MOD 2048 = 2047 THEN  (* Infinite or NaN *)
    h := h MOD 100000H  (* lowest 20 bits *)
  ELSE
    h := -1;  l := -1
  END
END NaNCodeL;

(*
PROCEDURE fcr(): SET;
CODE {SYSTEM.i386, SYSTEM.FPU}
  PUSH 0
  FSTCW [ESP]
  FWAIT
  POP EAX
END fcr;
*) (* commented out -- noch *)
(** Return state of the floating-point control register. *)
(*PROCEDURE FCR*(): SET;
BEGIN
  IF Kernel.copro THEN
    RETURN fcr()
  ELSE
    RETURN DefaultFCR
  END
END FCR;
*)
(*PROCEDURE setfcr(s: SET);
CODE {SYSTEM.i386, SYSTEM.FPU}
  FLDCW s[EBP]
END setfcr;
*)
(** Set state of floating-point control register.  Traps reset this to the default & ENTIER resets the rounding mode. *)
(*PROCEDURE SetFCR*(s: SET);
BEGIN
  IF Kernel.copro THEN setfcr(s) END
END SetFCR;
*)


PROCEDURE RealX (v: HUGEINT; VAR lr: LONGREAL);
BEGIN lr := SYSTEM.VAL(LONGREAL, v)
END RealX;

BEGIN
  RealX(03FF0000000000000H, tene[0]);
  RealX(04024000000000000H, tene[1]);    (*  1 *)
  RealX(04059000000000000H, tene[2]);    (*  2 *)
  RealX(0408F400000000000H, tene[3]);    (*  3 *)
  RealX(040C3880000000000H, tene[4]);    (*  4 *)
  RealX(040F86A0000000000H, tene[5]);    (*  5 *)
  RealX(0412E848000000000H, tene[6]);    (*  6 *)
  RealX(0416312D000000000H, tene[7]);    (*  7 *)
  RealX(04197D78400000000H, tene[8]);    (*  8 *)
  RealX(041CDCD6500000000H, tene[9]);    (*  9 *)
  RealX(04202A05F20000000H, tene[10]);   (* 10 *)
  RealX(042374876E8000000H, tene[11]);   (* 11 *)
  RealX(0426D1A94A2000000H, tene[12]);   (* 12 *)
  RealX(042A2309CE5400000H, tene[13]);   (* 13 *)
  RealX(042D6BCC41E900000H, tene[14]);   (* 14 *)
  RealX(0430C6BF526340000H, tene[15]);   (* 15 *)
  RealX(04341C37937E08000H, tene[16]);   (* 16 *)
  RealX(04376345785D8A000H, tene[17]);   (* 17 *)
  RealX(043ABC16D674EC800H, tene[18]);   (* 18 *)
  RealX(043E158E460913D00H, tene[19]);   (* 19 *)
  RealX(04415AF1D78B58C40H, tene[20]);   (* 20 *)
  RealX(0444B1AE4D6E2EF50H, tene[21]);   (* 21 *)
  RealX(04480F0CF064DD592H, tene[22]);   (* 22 *)

  RealX(00031FA182C40C60DH, ten[0]);    (* -307 *)
  RealX(004F7CAD23DE82D7BH, ten[1]);    (* -284 *)
  RealX(009BF7D228322BAF5H, ten[2]);    (* -261 *)
  RealX(00E84D6695B193BF8H, ten[3]);    (* -238 *)
  RealX(0134B9408EEFEA839H, ten[4]);    (* -215 *)
  RealX(018123FF06EEA847AH, ten[5]);    (* -192 *)
  RealX(01CD8274291C6065BH, ten[6]);    (* -169 *)
  RealX(0219FF779FD329CB9H, ten[7]);    (* -146 *)
  RealX(02665275ED8D8F36CH, ten[8]);    (* -123 *)
  RealX(02B2BFF2EE48E0530H, ten[9]);    (* -100 *)
  RealX(02FF286D80EC190DCH, ten[10]);   (*  -77 *)
  RealX(034B8851A0B548EA4H, ten[11]);   (*  -54 *)
  RealX(0398039D665896880H, ten[12]);   (*  -31 *)
  RealX(03E45798EE2308C3AH, ten[13]);   (*   -8 *)
  RealX(0430C6BF526340000H, ten[14]);   (*   15 *)
  RealX(047D2CED32A16A1B1H, ten[15]);   (*   38 *)
  RealX(04C98E45E1DF3B015H, ten[16]);   (*   61 *)
  RealX(0516078E111C3556DH, ten[17]);   (*   84 *)
  RealX(05625CCFE3D35D80EH, ten[18]);   (*  107 *)
  RealX(05AECDA62055B2D9EH, ten[19]);   (*  130 *)
  RealX(05FB317E5EF3AB327H, ten[20]);   (*  153 *)
  RealX(0647945145230B378H, ten[21]);   (*  176 *)
  RealX(06940B8E0ACAC4EAFH, ten[22]);   (*  199 *)
  RealX(06E0621B1C28AC20CH, ten[23]);   (*  222 *)
  RealX(072CD4A7BEBFA31ABH, ten[24]);   (*  245 *)
  RealX(0779362149CBD3226H, ten[25]);   (*  268 *)
  RealX(07C59A742461887F6H, ten[26]);   (*  291 *)

  eq[0]:= {0, 3, 4, 5, 9, 16, 23, 25, 26, 28, 31};
  eq[1]:= {2, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 29, 30, 31};
  eq[2]:= {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28};
  eq[3]:= {0, 1, 2, 3, 5, 6, 7, 8, 9, 11, 14, 15, 16, 17, 18, 19, 20, 22, 27, 28, 29, 30, 31};
  eq[4]:= {0, 6, 7, 10, 11, 12, 13, 14, 15, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
  eq[5]:= {0, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
  eq[6]:= {0, 1, 4, 5, 7, 8, 10, 14, 15, 16, 18, 20, 21, 23, 24, 25, 26, 28, 29, 30, 31};
  eq[7]:= {0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 23, 24, 26, 28, 29, 30, 31};
  eq[8]:= {0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 14, 16, 17, 18, 19, 20, 21, 24, 25, 26, 29};
  eq[9]:= {1, 2, 4, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
  eq[10]:= {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30};
  eq[11]:= {0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14, 15, 16, 19, 20, 21, 22, 23, 27, 28, 29, 30};
  eq[12]:= {0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 14, 15, 16, 17, 18, 19, 20, 21, 23, 26, 27, 29, 30, 31};
  eq[13]:= {0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16, 17, 18, 20, 21, 23, 24, 27, 28, 29, 30, 31};
  eq[14]:= {0, 1, 2, 3, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
  eq[15]:= {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28};
  eq[16]:= {1, 2, 4, 11, 13, 16, 17, 18, 19, 22, 24, 25, 26, 27, 28, 29, 30, 31};
  eq[17]:= {1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14, 15, 18, 19, 20, 21, 23, 25, 26, 27, 28, 29, 31};
  eq[18]:= {0, 2, 4, 5, 6, 8, 9, 11, 12, 13, 14, 16, 17, 19, 20, 22, 23, 24, 26, 27, 28, 29};
  eq[19]:= {2, 3, 4, 5, 6, 7};

  gr[0]:= {24, 27, 29, 30};
  gr[1]:= {0, 1, 3, 4, 7};
  gr[2]:= {29, 30, 31};
  gr[3]:= {4, 10, 12, 13, 21, 23, 24, 25, 26};
  gr[4]:= {1, 2, 3, 4, 5, 8, 9, 16, 17};
  gr[5]:= {2, 3, 4, 18};
  gr[6]:= {2, 3, 6, 9, 11, 12, 13, 17, 19, 22, 27};
  gr[7]:= {2};
  gr[8]:= {7, 12, 13, 15, 22, 23, 27, 28, 30, 31};
  gr[9]:= {0, 3, 5, 7, 8};
  gr[10]:= {};
  gr[11]:= {};
  gr[12]:= {11, 13, 22, 24, 25, 28};
  gr[13]:= {22, 25, 26};
  gr[14]:= {4, 5};
  gr[15]:= {10, 14, 27, 29, 30, 31};
  gr[16]:= {0, 3, 5, 6, 7, 8, 9, 10, 12, 14, 15, 20, 21, 23};
  gr[17]:= {0, 10, 12, 13, 16, 17, 22, 24, 30};
  gr[18]:= {};
  gr[19]:= {}
END ethReals.
