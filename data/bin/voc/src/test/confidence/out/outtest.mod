MODULE outtest;

IMPORT Out, SYSTEM;

VAR
  r:  REAL;
  lr: LONGREAL;
  cw: SYSTEM.INT16;

PROCEDURE wc(c: CHAR); BEGIN Out.Char(c) END wc;
PROCEDURE ws(s: ARRAY OF CHAR); BEGIN Out.String(s) END ws;
PROCEDURE wi(i: HUGEINT); BEGIN Out.Int(i,1) END wi;
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


(*
PROCEDURE -GetFpcw() '__asm__ __volatile__ ("fnstcw %0" : "=m" (outtest_cw))';
*)



BEGIN
  (*
  ws("Floating point control word: "); GetFpcw; wh(cw); wl;
  wl;
  *)

  ws("Real number hex representation."); wl;
  lr :=  1.0D0;                ws(" 1.0D0:                "); wh(lr); wl;
  lr :=  1.1D0;                ws(" 1.1D0:                "); wh(lr); wl;
  lr :=  2.1D0;                ws(" 2.1D0:                "); wh(lr); wl;
  lr := -1.1D0;                ws("-1.1D0:                "); wh(lr); wl;
  lr :=  1.1D3;                ws(" 1.1D3:                "); wh(lr); wl;
  lr :=  1.1D-3;               ws(" 1.1D-3:               "); wh(lr); wl;
  lr :=  1.2345678987654321D3; ws(" 1.2345678987654321D3: "); wh(lr); wl;
  lr := 0.0;                   ws(" 0.0:                  "); wh(lr); wl;
  lr := 0.000123D0;            ws(" 0.000123D0:           "); wh(lr); wl;
  lr := 0.0; lr :=  1/lr;      ws(" 1/0.0:                "); wh(lr); wl;
  lr := 0.0; lr := -1/lr;      ws("-1/0.0:                "); wh(lr); wl;
(*lr := 0.0; lr :=  0.0D0/lr;  ws(" 0.0/0.0:              "); wh(lr); wl;*)
  wl;
  r  :=  1.0E0;                ws(" 1.0E0:                "); wh(r);  wl;
  r  :=  1.1E0;                ws(" 1.1E0:                "); wh(r);  wl;
  r  :=  2.1E0;                ws(" 2.1E0:                "); wh(r);  wl;
  r  := -1.1E0;                ws("-1.1E0:                "); wh(r);  wl;
  r  :=  1.1E3;                ws(" 1.1E3:                "); wh(r);  wl;
  r  :=  1.1E-3;               ws(" 1.1E-3:               "); wh(r);  wl;
  r  :=  1.2345678987654321E3; ws(" 1.2345678987654321E3: "); wh(r);  wl;
  r  := 0.0;                   ws(" 0.0:                  "); wh(r);  wl;
  r  := 0.000123E0;            ws(" 0.000123E0:           "); wh(r);  wl;
  r  := 0.0; r :=  1/r;        ws(" 1/0.0:                "); wh(r);  wl;
  r  := 0.0; r := -1/r;        ws("-1/0.0:                "); wh(r);  wl;
(*r  := 0.0; r :=  0.0E0/r;    ws(" 0.0/0.0:              "); wh(r);  wl;*)
  wl; wl;

  ws("Out module tests."); wl;
  ws("SIZE(INTEGER) = "); wi(SIZE(INTEGER)); wl; wl;

  ws("Testing LONGREAL."); wl; wl;
  ws("                                1         2         3         4");  wl;
  ws("                       1234567890123456789012345678901234567890");            wl;
  ws(" 1.0D0:                "); Out.LongReal( 1.0D0,                1);  wl;
  ws(" 1.1D0:                "); Out.LongReal( 1.1D0,                1);  wl;
  ws(" 2.1D0:                "); Out.LongReal( 2.1D0,                1);  wl;
  ws("-1.1D0:                "); Out.LongReal(-1.1D0,                1);  wl;
  ws(" 1.1D3:                "); Out.LongReal( 1.1D3,                1);  wl;
  ws(" 1.1D-3:               "); Out.LongReal( 1.1D-3,               1);  wl;
  ws(" 1.2345678987654321D3: "); Out.LongReal( 1.2345678987654321D3, 1);  wl;
  ws(" 0.0:                  "); Out.LongReal(0.0,                   1);  wl;
  ws(" 0.000123D0:           "); Out.LongReal(0.000123D0,            1);  wl;
  lr := 0.0; lr :=  1/lr;
  ws(" 1/0.0:                "); Out.LongReal(lr,                    1);  wl;
  lr := 0.0; lr := -1/lr;
  ws("-1/0.0:                "); Out.LongReal(lr,                    1);  wl;
  lr := 0.0; lr :=  0.0D0/lr;
  ws(" 0.0/0.0:              "); Out.LongReal(lr,                    1);  wl;
  wl;
  ws("                                1         2         3         4");  wl;
  ws("                       1234567890123456789012345678901234567890");            wl;
  ws(" 1.0D0:                "); Out.LongReal( 1.0D0,                12); wl;
  ws(" 1.1D0:                "); Out.LongReal( 1.1D0,                12); wl;
  ws(" 2.1D0:                "); Out.LongReal( 2.1D0,                12); wl;
  ws("-1.1D0:                "); Out.LongReal(-1.1D0,                12); wl;
  ws(" 1.1D3:                "); Out.LongReal( 1.1D3,                12); wl;
  ws(" 1.1D-3:               "); Out.LongReal( 1.1D-3,               12); wl;
  ws(" 1.2345678987654321D3: "); Out.LongReal( 1.2345678987654321D3, 12); wl;
  ws(" 0.0:                  "); Out.LongReal(0.0,                   12); wl;
  ws(" 0.000123D0:           "); Out.LongReal(0.000123D0,            12); wl;
  lr := 0.0; lr :=  1/lr;
  ws(" 1/0.0:                "); Out.LongReal(lr,                    12); wl;
  lr := 0.0; lr := -1/lr;
  ws("-1/0.0:                "); Out.LongReal(lr,                    12); wl;
  lr := 0.0; lr :=  0.0D0/lr;
  ws(" 0.0/0.0:              "); Out.LongReal(lr,                    12); wl;
  wl;
  ws("                                1         2         3         4");  wl;
  ws("                       1234567890123456789012345678901234567890");            wl;
  ws(" 1.0D0:                "); Out.LongReal( 1.0D0,                40); wl;
  ws(" 1.1D0:                "); Out.LongReal( 1.1D0,                40); wl;
  ws(" 2.1D0:                "); Out.LongReal( 2.1D0,                40); wl;
  ws("-1.1D0:                "); Out.LongReal(-1.1D0,                40); wl;
  ws(" 1.1D3:                "); Out.LongReal( 1.1D3,                40); wl;
  ws(" 1.1D-3:               "); Out.LongReal( 1.1D-3,               40); wl;
  ws(" 1.2345678987654321D3: "); Out.LongReal( 1.2345678987654321D3, 40); wl;
  ws(" 0.0:                  "); Out.LongReal(0.0,                   40); wl;
  ws(" 0.000123D0:           "); Out.LongReal(0.000123D0,            40); wl;
  lr := 0.0; lr :=  1/lr;
  ws(" 1/0.0:                "); Out.LongReal(lr,                    40); wl;
  lr := 0.0; lr := -1/lr;
  ws("-1/0.0:                "); Out.LongReal(lr,                    40); wl;
  lr := 0.0; lr :=  0.0D0/lr;
  ws(" 0.0/0.0:              "); Out.LongReal(lr,                    40); wl;
  wl; wl; wl;


  ws("Testing REAL."); wl; wl;
  ws("                                1         2         3         4");  wl;
  ws("                       1234567890123456789012345678901234567890");            wl;
  ws(" 1.0E0:                "); Out.Real( 1.0E0,                    1);  wl;
  ws(" 1.1E0:                "); Out.Real( 1.1E0,                    1);  wl;
  ws(" 2.1E0:                "); Out.Real( 2.1E0,                    1);  wl;
  ws("-1.1E0:                "); Out.Real(-1.1E0,                    1);  wl;
  ws(" 1.1E3:                "); Out.Real( 1.1E3,                    1);  wl;
  ws(" 1.1E-3:               "); Out.Real( 1.1E-3,                   1);  wl;
  ws(" 1.2345678987654321E3: "); Out.Real( 1.2345678987654321E3,     1);  wl;
  ws(" 0.0:                  "); Out.Real(0.0,                       1);  wl;
  ws(" 0.000123E0:           "); Out.Real(0.000123E0,                1);  wl;
  r := 0.0; r :=  1/r;
  ws(" 1/0.0:                "); Out.Real(r,                         1);  wl;
  r := 0.0; r := -1/r;
  ws("-1/0.0:                "); Out.Real(r,                         1);  wl;
  r := 0.0; r :=  0.0E0/r;
  ws(" 0.0/0.0:              "); Out.Real(r,                         1);  wl;
  wl;
  ws("                                1         2         3");        wl;
  ws("                       123456789012345678901234567890");        wl;
  ws(" 1.0E0:                "); Out.Real( 1.0E0,                    12); wl;
  ws(" 1.1E0:                "); Out.Real( 1.1E0,                    12); wl;
  ws(" 2.1E0:                "); Out.Real( 2.1E0,                    12); wl;
  ws("-1.1E0:                "); Out.Real(-1.1E0,                    12); wl;
  ws(" 1.1E3:                "); Out.Real( 1.1E3,                    12); wl;
  ws(" 1.1E-3:               "); Out.Real( 1.1E-3,                   12); wl;
  ws(" 1.2345678987654321E3: "); Out.Real( 1.2345678987654321E3,     12); wl;
  ws(" 0.0:                  "); Out.Real(0.0,                       12); wl;
  ws(" 0.000123E0:           "); Out.Real(0.000123E0,                12); wl;
  r := 0.0; r :=  1/r;
  ws(" 1/0.0:                "); Out.Real(r,                         12); wl;
  r := 0.0; r := -1/r;
  ws("-1/0.0:                "); Out.Real(r,                         12); wl;
  r := 0.0; r :=  0.0E0/r;
  ws(" 0.0/0.0:              "); Out.Real(r,                         12); wl;
  wl;
  ws("                                1         2         3         4");  wl;
  ws("                       1234567890123456789012345678901234567890");            wl;
  ws(" 1.0E0:                "); Out.Real( 1.0E0,                    40); wl;
  ws(" 1.1E0:                "); Out.Real( 1.1E0,                    40); wl;
  ws(" 2.1E0:                "); Out.Real( 2.1E0,                    40); wl;
  ws("-1.1E0:                "); Out.Real(-1.1E0,                    40); wl;
  ws(" 1.1E3:                "); Out.Real( 1.1E3,                    40); wl;
  ws(" 1.1E-3:               "); Out.Real( 1.1E-3,                   40); wl;
  ws(" 1.2345678987654321E3: "); Out.Real( 1.2345678987654321E3,     40); wl;
  ws(" 0.0:                  "); Out.Real(0.0,                       40); wl;
  ws(" 0.000123E0:           "); Out.Real(0.000123E0,                40); wl;
  r := 0.0; r :=  1/r;
  ws(" 1/0.0:                "); Out.Real(r,                         40); wl;
  r := 0.0; r := -1/r;
  ws("-1/0.0:                "); Out.Real(r,                         40); wl;
  r := 0.0; r :=  0.0E0/r;
  ws(" 0.0/0.0:              "); Out.Real(r,                         40); wl;
  wl;

END outtest.
