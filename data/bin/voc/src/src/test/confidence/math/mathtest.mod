MODULE mathtest;
IMPORT Math, MathL, Out, SYSTEM;

TYPE
  RtoR   = PROCEDURE(x: REAL): REAL;
  LRtoLR = PROCEDURE(x: LONGREAL): LONGREAL;
  RtoLI  = PROCEDURE(x: REAL): LONGINT;
  LRtoLI = PROCEDURE(x: LONGREAL): LONGINT;

  Values = RECORD
    v: ARRAY 100 OF LONGREAL;
    n: INTEGER
  END;

VAR
  r:      REAL;
  lr:     LONGREAL;
  misc:   Values;
  angles: Values;


PROCEDURE wc(c: CHAR); BEGIN Out.Char(c) END wc;
PROCEDURE ws(s: ARRAY OF CHAR); BEGIN Out.String(s) END ws;
PROCEDURE wi(i: HUGEINT); BEGIN Out.Int(i,1) END wi;
PROCEDURE wr(r: REAL); BEGIN Out.Real(r,11) END wr;
PROCEDURE wlr(lr: LONGREAL); BEGIN Out.LongReal(lr,21) END wlr;
PROCEDURE wl; BEGIN Out.Ln END wl;

PROCEDURE wh(VAR h: ARRAY OF SYSTEM.BYTE);
  VAR i: INTEGER; b: SYSTEM.INT8;
BEGIN
  i := SHORT(LEN(h));
  WHILE i > 0 DO
    DEC(i); b := SYSTEM.VAL(SYSTEM.INT8, h[i]);
    IF b DIV 16 MOD 16 < 10 THEN wc(CHR(b DIV 16 MOD 16 + 48)) ELSE wc(CHR(b DIV 16 MOD 16 + 55)) END;
    IF b MOD 16 < 10 THEN wc(CHR(b MOD 16 + 48)) ELSE wc(CHR(b MOD 16 + 55)) END;
  END
END wh;

PROCEDURE addvalue(lr: LONGREAL; VAR val: Values);
BEGIN val.v[val.n] := lr; INC(val.n)
END addvalue;

PROCEDURE MathErrorHandler(error: INTEGER);
BEGIN
  ws("<Math(L) error ");
  CASE error OF
  |Math.NoError:           ws("NoError")
  |Math.IllegalRoot:       ws("IllegalRoot")
  |Math.IllegalLog:        ws("IllegalLog")
  |Math.Overflow:          ws("Overflow")
  |Math.IllegalPower:      ws("IllegalPower")
  |Math.IllegalLogBase:    ws("IllegalLogBase")
  |Math.IllegalTrig:       ws("IllegalTrig")
  |Math.IllegalInvTrig:    ws("IllegalInvTrig")
  |Math.HypInvTrigClipped: ws("HypInvTrigClipped")
  |Math.IllegalHypInvTrig: ws("IllegalHypInvTrig")
  |Math.LossOfAccuracy:    ws("LossOfAccuracy")
  |Math.Underflow:         ws("Underflow")
  ELSE wi(error); ws(" (unknknown)")
  END;
  ws("> ")
END MathErrorHandler;

PROCEDURE TestRtoR(s: ARRAY OF CHAR; p: RtoR; lp: LRtoLR; val: Values);
  VAR i: INTEGER; r: REAL;
BEGIN
  i := 0;
  WHILE i < val.n DO
    r := SHORT(val.v[i]);
    ws("Math."); ws(s); ws("("); wr(r); ws("): "); wr(p(r));
    ws(".  MathL."); ws(s); ws("("); wlr(val.v[i]); ws("): "); wlr(lp(val.v[i])); wl;
    INC(i)
  END;
  wl;
END TestRtoR;

PROCEDURE TestRtoLI(s: ARRAY OF CHAR; p: RtoLI; lp: LRtoLI; val: Values);
  VAR i: INTEGER; r: REAL;
BEGIN
  i := 0;
  WHILE i < val.n DO
    r := SHORT(val.v[i]);
    ws("Math."); ws(s); ws("("); wr(r); ws("): "); wi(p(r));
    ws(".  MathL."); ws(s); ws("("); wlr(val.v[i]); ws("): "); wi(lp(val.v[i])); wl;
    INC(i)
  END;
  wl;
END TestRtoLI;

PROCEDURE round(lr: LONGREAL);
  VAR r: REAL;
BEGIN
  r := SHORT(lr);
  ws("Math.round("); wr(r); ws("): "); wi(Math.round(r));
  ws(".  MathL.round("); wlr(lr); ws("): "); wi(MathL.round(lr)); wl
END round;

PROCEDURE sqrt(lr: LONGREAL);
  VAR r: REAL;
BEGIN
  r := SHORT(lr);
  ws("Math.sqrt("); wr(r); ws("): "); wr(Math.sqrt(r));
  ws(".  MathL.sqrt("); wlr(r); ws("): "); wlr(MathL.sqrt(r)); wl
END sqrt;


BEGIN
  ws("Math and MathL module tests."); wl; wl;

  misc.n := 0;
  addvalue(0.9D0, misc);  addvalue(1.0D0, misc); addvalue(1.4D0, misc);  addvalue(1.5D0, misc);  addvalue(1.6D0, misc);  addvalue(1.9D0, misc);
  addvalue(2.0D0, misc);  addvalue(2.4D0, misc); addvalue(2.5D0, misc);
  addvalue(3.0D0, misc);  addvalue(4.0D0, misc);

  addvalue(-0.9D0, misc); addvalue(-1.0D0, misc); addvalue(-1.4D0, misc); addvalue(-1.5D0, misc); addvalue(-1.6D0, misc); addvalue(-1.9D0, misc);
  addvalue(-2.0D0, misc); addvalue(-2.4D0, misc); addvalue(-2.5D0, misc);
  addvalue(-3.0D0, misc); addvalue(-4.0D0, misc);

  angles.n:= 0;
  addvalue(0.0D0, angles);  addvalue(0.1D0, angles);
  addvalue(MathL.pi/3.0D0, angles); addvalue(MathL.pi/2.0D0, angles); addvalue(MathL.pi, angles);
  addvalue(-MathL.pi/3.0D0, angles); addvalue(-MathL.pi/2.0D0, angles); addvalue(-MathL.pi, angles);

  TestRtoR("fraction", Math.fraction, MathL.fraction, misc);
  TestRtoLI("round",   Math.round,    MathL.round,    misc);
  TestRtoR("sqrt",     Math.sqrt,     MathL.sqrt,     misc);
(*TestRtoR("exp",      Math.exp,      MathL.exp,      misc);*)  (* bypass exp test as MathL result differs between x86 and x64. *)
  TestRtoR("ln",       Math.ln,       MathL.ln,       misc);
  TestRtoR("sin",      Math.sin,      MathL.sin,      angles);
  TestRtoR("cos",      Math.cos,      MathL.cos,      angles);
  TestRtoR("tan",      Math.tan,      MathL.tan,      angles);
  TestRtoR("arcsin",   Math.arcsin,   MathL.arcsin,   misc);
  TestRtoR("arccos",   Math.arccos,   MathL.arccos,   misc);
  TestRtoR("arctan",   Math.arctan,   MathL.arctan,   misc);
  TestRtoR("sinh",     Math.sinh,     MathL.sinh,     misc);
  TestRtoR("cosh",     Math.cosh,     MathL.cosh,     misc);
  TestRtoR("tanh",     Math.tanh,     MathL.tanh,     misc);
  TestRtoR("arcsinh",  Math.arcsinh,  MathL.arcsinh,  misc);
  TestRtoR("arccosh",  Math.arccosh,  MathL.arccosh,  misc);
  TestRtoR("arctanh",  Math.arctanh,  MathL.arctanh,  misc);

  (* todo power, log, ipower, sincos, arctan2 *)

END mathtest.
