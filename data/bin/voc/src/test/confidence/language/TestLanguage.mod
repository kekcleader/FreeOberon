MODULE TestLanguage;

IMPORT SYSTEM, Console;

  VAR gz: LONGREAL;

PROCEDURE TestShiftResult(of, by, actual, expected: LONGINT; msg: ARRAY OF CHAR);
BEGIN
  IF actual # expected THEN
    Console.String(msg);
    Console.String(" of $"); Console.Hex(of);
    Console.String(" by ");  Console.Int(by,1);
    Console.String(" is $"); Console.Hex(actual);
    Console.String(" but should be $"); Console.Hex(expected);
    Console.Ln;
  END
END TestShiftResult;

PROCEDURE Shift;
VAR c: CHAR; b: SYSTEM.BYTE; s,t,u: SHORTINT; h,i,j,k: INTEGER; l,m,n,r: LONGINT;
(*
  Aritmetic shift always returns type LONGINT. Defined as x * 2**n.
  LSH and ROT produces results of the same type as the value being shifted.
*)
BEGIN
  (* Positive LSH shifts and ROTs without overflow *)

  i := 0; m := 1;
  WHILE i < SIZE(LONGINT)*8 DO
    l := 1; r := SYSTEM.LSH(l,i); TestShiftResult(l, i, r, m, "LSH");
    l := 1; r := SYSTEM.ROT(l,i); TestShiftResult(l, i, r, m, "ROT(1)");
    m := m * 2; INC(i);
  END;

  i := 0; k := 1;
  WHILE i < SIZE(INTEGER)*8 DO
    j := 1; j := SYSTEM.LSH(j,i); ASSERT(j = k, 23);
    j := 1; j := SYSTEM.ROT(j,i); ASSERT(j = k, 24);
    k := k * 2; INC(i);
  END;

  i := 0; t := 1;
  WHILE i < SIZE(SHORTINT)*8 DO
    s := 1; s := SYSTEM.LSH(s,i); ASSERT(s = t, 30);
    s := 1; s := SYSTEM.ROT(s,i); ASSERT(s = t, 31);
    t := t * 2; INC(i);
  END;

  (* Negative LSH shifts and ROTs without overflow *)

  i := -1; m := 1; m := SYSTEM.LSH(m, SIZE(LONGINT)*8 - 2); n := m*2;
  WHILE i > -SIZE(LONGINT)*8 DO
    l := n; l := SYSTEM.LSH(l,i); ASSERT(l = m, 39);
    l := n; l := SYSTEM.ROT(l,i); ASSERT(l = m, 40);
    m := m DIV 2; DEC(i);
  END;

  i := -1; k := 1; k := SYSTEM.LSH(k, SIZE(INTEGER)*8 - 2); h := k*2;
  WHILE i > -SIZE(INTEGER)*8 DO
    j := h; j := SYSTEM.LSH(j,i); ASSERT(j = k, 46);
    j := h; j := SYSTEM.ROT(j,i); ASSERT(j = k, 47);
    k := k DIV 2; DEC(i);
  END;

  i := -1; t := 1; t := SYSTEM.LSH(t, SIZE(SHORTINT)*8 - 2); u := t*2;
  WHILE i > -SIZE(SHORTINT)*8 DO
    s := u; s := SYSTEM.LSH(s,i); ASSERT(s = t, 53);
    s := u; s := SYSTEM.ROT(s,i); ASSERT(s = t, 54);
    t := t DIV 2; DEC(i);
  END;

  (* Positive ASHs of a negative number *)

  i := 0; m := 1; m := SYSTEM.LSH(m, SIZE(LONGINT)*8 - 1); n := m;
  WHILE i > -SIZE(LONGINT)*8 DO
    l := n; l := ASH(l,i); ASSERT(l = m, 62);
    m := m DIV 2; DEC(i);
  END;

  i := 0; j := 1; j := SYSTEM.LSH(j, SIZE(INTEGER)*8 - 1); k := j;
  WHILE i > -SIZE(INTEGER)*8 DO
    l := ASH(j,i); ASSERT(l = LONG(k), 68);
    k := k DIV 2; DEC(i);
  END;

  i := 0; s := 1; s := SYSTEM.LSH(s, SIZE(SHORTINT)*8 - 1); t := s;
  WHILE i > -SIZE(SHORTINT)*8 DO
    l := ASH(s,i); ASSERT(l = LONG(LONG(t)), 74);
    t := t DIV 2; DEC(i);
  END;

  (* Positive ASHs of a positive number *)

  i := 0; m := 1; m := SYSTEM.LSH(m, SIZE(LONGINT)*8 - 2); n := m;
  WHILE i > 1-SIZE(LONGINT)*8 DO
    l := n; l := ASH(l,i); ASSERT(l = m, 82);
    m := m DIV 2; DEC(i);
  END;


  (* Positive LSH shifts and ROTs with overflow *)

  i := 1; m := 1;
  WHILE i < SIZE(LONGINT)*8 DO
    l := MAX(LONGINT); INC(l); r := SYSTEM.LSH(l,i); TestShiftResult(l, i, r, 0, "LSH");
    l := MAX(LONGINT); INC(l); r := SYSTEM.ROT(l,i); TestShiftResult(l, i, r, m, "ROT(2)");
    m := m * 2; INC(i);
  END;

  i := 1; k := 1;
  WHILE i < SIZE(INTEGER)*8 DO
    j := MAX(INTEGER); INC(j); r := SYSTEM.LSH(j,i); TestShiftResult(j, i, r, 0, "LSH");
    j := MAX(INTEGER); INC(j); r := SYSTEM.ROT(j,i); TestShiftResult(j, i, r, k, "ROT(3)");
    k := k * 2; INC(i);
  END;

  i := 1; t := 1;
  WHILE i < SIZE(SHORTINT)*8 DO
    s := MAX(SHORTINT); INC(s); r := SYSTEM.LSH(s,i); TestShiftResult(s, i, r, 0, "LSH");
    s := MAX(SHORTINT); INC(s); r := SYSTEM.ROT(s,i); TestShiftResult(s, i, r, t, "ROT(4)");
    t := t * 2; INC(i);
  END;

  (* Negative LSH shifts and ROTs without overflow *)

  i := -1; m := MAX(LONGINT); INC(m);
  WHILE i > -SIZE(LONGINT)*8 DO
    l := 1; r := SYSTEM.LSH(l,i); TestShiftResult(l, i, r, 0, "LSH");
    l := 1; r := SYSTEM.ROT(l,i); TestShiftResult(l, i, r, m, "ROT");
    m := SYSTEM.LSH(m,-1); (* m := m DIV 2; *)
    DEC(i);
  END;

  i := -1; k := MAX(INTEGER); INC(k);
  WHILE i > -SIZE(INTEGER)*8 DO
    j := 1; r := SYSTEM.LSH(j,i); TestShiftResult(j, i, r, 0, "LSH");
    j := 1; r := SYSTEM.ROT(j,i); TestShiftResult(j, i, r, k, "ROT");
    k := SYSTEM.LSH(k,-1); (* k := k DIV 2; *)
    DEC(i);
  END;

  i := -1; t := MAX(SHORTINT); INC(t);
  WHILE i > -SIZE(SHORTINT)*8 DO
    s := 1; r := SYSTEM.LSH(s,i); TestShiftResult(s, i, r, 0, "LSH");
    s := 1; r := SYSTEM.ROT(s,i); TestShiftResult(s, i, r, t, "ROT");
    t := SYSTEM.LSH(t,-1); (* t := t DIV 2; *)
    DEC(i);
  END;


  (* Also need full tests for CHAR, and poossibly SYSTEM.BYTE. Here's a simple one *)

  c := 1X; c := SYSTEM.LSH(c,2); c := SYSTEM.ROT(c,-2); ASSERT(c=1X, 93);
  b := 1;  b := SYSTEM.LSH(b,2); b := SYSTEM.ROT(b,-2); ASSERT(SYSTEM.VAL(CHAR,b)=1X, 94);

END Shift;


PROCEDURE TestValue(v,e: LONGINT; name: ARRAY OF CHAR);
BEGIN
  IF v # e THEN
    Console.String(name);
    Console.String(" = ");
    Console.Int(v,1);
    Console.String(", expected ");
    Console.Int(e,1);
    Console.Ln;
  END
END TestValue;


PROCEDURE side(i: INTEGER): INTEGER; BEGIN RETURN i END side;

PROCEDURE DivMod;
  VAR i,j: INTEGER;
BEGIN
  j := 2;
  i :=  4;  TestValue(i DIV j, 2, "4 DIV 2");       TestValue(side(i) DIV side(j),  2, "side(4) DIV side(2)");
  i :=  5;  TestValue(i DIV j, 2, "5 DIV 2");       TestValue(side(i) DIV side(j),  2, "side(5) DIV side(2)");
  i :=  6;  TestValue(i DIV j, 3, "6 DIV 2");       TestValue(side(i) DIV side(j),  3, "side(6) DIV side(2)");
  i :=  7;  TestValue(i DIV j, 3, "7 DIV 2");       TestValue(side(i) DIV side(j),  3, "side(7) DIV side(2)");
  i := -4;  TestValue(i DIV j, -2, "(-4) DIV 2");   TestValue(side(i) DIV side(j), -2, "side(-4) DIV side(2)");
  i := -5;  TestValue(i DIV j, -3, "(-5) DIV 2");   TestValue(side(i) DIV side(j), -3, "side(-5) DIV side(2)");
  i := -6;  TestValue(i DIV j, -3, "(-6) DIV 2");   TestValue(side(i) DIV side(j), -3, "side(-6) DIV side(2)");
  i := -7;  TestValue(i DIV j, -4, "(-7) DIV 2");   TestValue(side(i) DIV side(j), -4, "side(-7) DIV side(2)");

  j := -2;
  i :=  4;  TestValue(i DIV j, -2, "4 DIV (-2)");   TestValue(side(i) DIV side(j), -2, "side(4) DIV side(-2)");
  i :=  5;  TestValue(i DIV j, -3, "5 DIV (-2)");   TestValue(side(i) DIV side(j), -3, "side(5) DIV side(-2)");
  i :=  6;  TestValue(i DIV j, -3, "6 DIV (-2)");   TestValue(side(i) DIV side(j), -3, "side(6) DIV side(-2)");
  i :=  7;  TestValue(i DIV j, -4, "7 DIV (-2)");   TestValue(side(i) DIV side(j), -4, "side(7) DIV side(-2)");
  i := -4;  TestValue(i DIV j, 2, "(-4) DIV (-2)"); TestValue(side(i) DIV side(j),  2, "side(-4) DIV side(-2)");
  i := -5;  TestValue(i DIV j, 2, "(-5) DIV (-2)"); TestValue(side(i) DIV side(j),  2, "side(-5) DIV side(-2)");
  i := -6;  TestValue(i DIV j, 3, "(-6) DIV (-2)"); TestValue(side(i) DIV side(j),  3, "side(-6) DIV side(-2)");
  i := -7;  TestValue(i DIV j, 3, "(-7) DIV (-2)"); TestValue(side(i) DIV side(j),  3, "side(-7) DIV side(-2)");

  (*     x = (x DIV y) * y + (x MOD y)
     =>  x MOd y = x - ((x DIV y) * y)
  *)

  i :=  4; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "4 MOD 3");
  i :=  5; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "5 MOD 3");
  i :=  6; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "6 MOD 3");
  i :=  7; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "7 MOD 3");

  i := -4; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "-4 MOD 3");
  i := -5; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "-5 MOD 3");
  i := -6; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "-6 MOD 3");
  i := -7; j :=  3; TestValue(i MOD j, i - ((i DIV j) * j), "-7 MOD 3");

  i :=  4; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "4 MOD -3");
  i :=  5; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "5 MOD -3");
  i :=  6; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "6 MOD -3");
  i :=  7; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "7 MOD -3");

  i := -4; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "-4 MOD -3");
  i := -5; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "-5 MOD -3");
  i := -6; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "-6 MOD -3");
  i := -7; j := -3; TestValue(i MOD j, i - ((i DIV j) * j), "-7 MOD -3");
END DivMod;




PROCEDURE Abs;
  VAR
    i: INTEGER;
    l: LONGINT;
    h: SYSTEM.INT64;
BEGIN
  i := 5;  TestValue(ABS(i), 5, "ABS(INTEGER 5)");
  i := -5; TestValue(ABS(i), 5, "ABS(INTEGER -5)");
  l := 5;  TestValue(ABS(l), 5, "ABS(LONGINT 5)");
  l := -5; TestValue(ABS(l), 5, "ABS(LONGINT -5)");
  h := 5;  TestValue(SYSTEM.VAL(LONGINT,ABS(h)), 5, "ABS(SYSTEM.INT64 5)");
  h := -5; TestValue(SYSTEM.VAL(LONGINT,ABS(h)), 5, "ABS(SYSTEM.INT64 -5)");
END Abs;



(* LR does nothing numerically, but is enough to stop the C compiler
   optimizing away the LR assignment and ENTIER implementation. *)
PROCEDURE LR(lr: LONGREAL): LONGREAL; BEGIN RETURN lr + gz; END LR;

PROCEDURE Entier;
  VAR lr: LONGREAL;
BEGIN
  gz := 0.0;
  lr := LR(-0.01); TestValue(ENTIER(lr), -1, "ENTIER(-0.01");
  lr := LR( 0.00); TestValue(ENTIER(lr),  0, "ENTIER(0.00");
  lr := LR( 5.00); TestValue(ENTIER(lr),  5, "ENTIER(5.00");
  lr := LR( 5.50); TestValue(ENTIER(lr),  5, "ENTIER(5.50");
  lr := LR( 5.99); TestValue(ENTIER(lr),  5, "ENTIER(5.99");
  lr := LR(-5.00); TestValue(ENTIER(lr), -5, "ENTIER(-5.00");
  lr := LR(-5.50); TestValue(ENTIER(lr), -6, "ENTIER(-5.50");
  lr := LR(-5.99); TestValue(ENTIER(lr), -6, "ENTIER(-5.99");
END Entier;




PROCEDURE IntSize;
  VAR l: LONGINT;
BEGIN
  TestValue(MIN(SHORTINT), -80H, "MIN(SHORTINT)");
  TestValue(MAX(SHORTINT),  7FH, "MAX(SHORTINT)");
  IF SIZE(INTEGER) = 2 THEN (* 32 bit machine *)
    TestValue(MIN(INTEGER),      -7FFFH - 1, "MIN(INTEGER)");
    TestValue(MAX(INTEGER),       7FFFH,     "MAX(INTEGER)");
    TestValue(MIN(LONGINT),  -7FFFFFFFH - 1, "MIN(LONGINT)");
    TestValue(MAX(LONGINT),   7FFFFFFFH,     "MAX(LONGINT)");
  ELSIF SIZE(INTEGER) = 4 THEN (* 64 bit machine *)
    TestValue(MIN(INTEGER),          -7FFFFFFFH - 1, "MIN(INTEGER)");
    TestValue(MAX(INTEGER),           7FFFFFFFH,     "MAX(INTEGER)");
    (* Since we need to be compilable on 32 bit machines we cannot use
       a 64 bit constant, so use arithmetic. *)
    l := 1; l := SYSTEM.LSH(l, 63); l := l-1;  (* Generate l = 7FFFFFFFFFFFFFFFH *)
    TestValue(MIN(LONGINT),  -l - 1, "MIN(LONGINT)");
    TestValue(MAX(LONGINT),   l,     "MAX(LONGINT)");
  ELSE
    Console.String("SIZE(INTEGER) = ");
    Console.Int(SIZE(INTEGER),1);
    Console.String(", expected 2 or 4.");
    Console.Ln;
  END;
END IntSize;




BEGIN
  Shift;
  DivMod;
  IntSize;
  Abs;
  Entier;
  Console.String("Language tests successful."); Console.Ln;
END TestLanguage.
