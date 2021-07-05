MODULE TestLibrary;

IMPORT SYSTEM, Oberon, Texts, Reals, oocLowReal;

VAR W: Texts.Writer;

PROCEDURE tc(c: CHAR);                 BEGIN Texts.Write(W, c) END tc;
PROCEDURE ts(s: ARRAY OF CHAR);        BEGIN Texts.WriteString(W, s) END ts;
PROCEDURE ti(i, n: LONGINT);           BEGIN Texts.WriteInt(W, i, n) END ti;
PROCEDURE tr(r: LONGREAL; n: INTEGER); BEGIN Texts.WriteLongReal(W, r, n) END tr;
PROCEDURE tn;                          BEGIN Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf) END tn;


PROCEDURE TestConvert(lr: LONGREAL);
  VAR str: ARRAY 20 OF CHAR; i: INTEGER;
BEGIN
  Reals.ConvertL(lr, 6, str);
  i := 6; WHILE i > 0 DO DEC(i); tc(str[i]) END;
  tn;
END TestConvert;

PROCEDURE TestHex(r: REAL);
  VAR str: ARRAY 20 OF CHAR;
BEGIN
  Reals.ConvertH(r, str); str[8] := 0X; ts(str); tn;
END TestHex;

PROCEDURE TestSetExpo(r: REAL; i: INTEGER);
BEGIN
  ts("r = ");   tr(r,10);
  ts(", i = "); ti(Reals.Expo(r),1);
  Reals.SetExpo(r, i);
  ts(" -> r = "); tr(r,10);
  ts(", i = ");   ti(Reals.Expo(r),1); tn;
END TestSetExpo;

PROCEDURE TestFractionPart(r: REAL);
BEGIN
  ts("r = ");     tr(r,14);
  ts(", exp = "); ti(Reals.Expo(r),1);
  r := oocLowReal.fraction(r);
  ts(" -> r = "); tr(r,14);
  ts(", exp = "); ti(Reals.Expo(r),1); tn;
END TestFractionPart;

PROCEDURE RealTests;
  VAR
    str: ARRAY 20 OF CHAR;
    r:   REAL;
(*
    lr:  LONGREAL;
*)
BEGIN
  TestConvert(1.0);
  TestConvert(1.5);
  TestConvert(2.0);
  TestConvert(2.99);
  TestConvert(3.0);

  TestHex(1.0);
  TestHex(1.5);
  TestHex(2.0);
  TestHex(2.99);
  TestHex(3.0);

  ti(Reals.Expo(0.5),1); tn; (* 126 *)
  ti(Reals.Expo(1.0),1); tn; (* 127 *)
  ti(Reals.Expo(2.0),1); tn; (* 128 *)
  ti(Reals.Expo(3.0),1); tn; (* 128 *)
  ti(Reals.Expo(4.0),1); tn; (* 129 *)

  TestSetExpo(1.0,  129);
  TestSetExpo(-1.0, 129);
  TestSetExpo(2.0,  129);
  TestSetExpo(-4.0, 129);
  TestSetExpo(1.5, 129);
  TestSetExpo(-1.5, 129);

  TestFractionPart(1.234);
  TestFractionPart(-1.234);
  TestFractionPart(32.678);
  TestFractionPart(-32.678);

  r := 0.0;
  ASSERT(~oocLowReal.IsInfinity(r), 3); ASSERT(~oocLowReal.IsNaN(r), 4);

  r := 0.0; Reals.SetExpo(r, 255);
  ASSERT(oocLowReal.IsInfinity(r), 5); ASSERT(~oocLowReal.IsNaN(r), 6);

  r := 0.123; Reals.SetExpo(r, 255);
  ASSERT(~oocLowReal.IsInfinity(r), 7); ASSERT(oocLowReal.IsNaN(r), 8);
END RealTests;


BEGIN
  Texts.OpenWriter(W);
  RealTests;
  ts("Library tests successful."); tn
END TestLibrary.