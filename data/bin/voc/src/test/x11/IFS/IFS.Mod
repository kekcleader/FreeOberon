(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE  IFS;  (** portable *)
(* Iterated Function System, page 92 *)
IMPORT  RandomNumbers := ethRandomNumbers, (*In,*) Out := Console, XYplane := oocXYplane;

VAR
  a1, b1, c1, d1, e1, f1, p1: REAL;   (* IFS parameters *)
  a2, b2, c2, d2, e2, f2, p2: REAL;   (* IFS parameters *)
  a3, b3, c3, d3, e3, f3, p3: REAL;   (* IFS parameters *)
  a4, b4, c4, d4, e4, f4, p4: REAL;   (* IFS parameters *)
  X, Y: REAL;    (* the position of the pen *)
  x0: INTEGER;  (* Distance of origin fm left edge[pixels] *)
  y0: INTEGER;  (* Distance of origin from bottom edge[pixels] *)
  e: INTEGER;  (* Size of unit interval [pixels] *)
  initialized: BOOLEAN;  (* Are parameters initialized? *)

PROCEDURE  Draw*;  (* command marked for export *)
VAR
  x, y: REAL;         (* new position *)
  xi, eta: INTEGER;     (* pixel coordinates of pen *)
  rn: REAL;
BEGIN
IF initialized THEN
  REPEAT
    rn := RandomNumbers.Uniform();
    IF rn < p1 THEN
      x := a1 * X + b1 * Y + e1;  y := c1 * X + d1 * Y + f1
    ELSIF rn < (p1 + p2) THEN
      x := a2 * X + b2 * Y + e2;  y := c2 * X + d2 * Y + f2
    ELSIF rn < (p1 + p2 + p3) THEN
      x := a3 * X + b3 * Y + e3;  y := c3 * X + d3 * Y + f3
    ELSE
      x := a4 * X + b4 * Y + e4;  y := c4 * X + d4 * Y + f4
    END;
    X := x;  xi := x0 + SHORT(ENTIER(X*e));
    Y := y;  eta := y0 + SHORT(ENTIER(Y*e));
    XYplane.Dot(xi, eta, XYplane.draw)
  UNTIL  "s" = XYplane.Key()
END
END Draw;
(*
PROCEDURE Init*;  (* command marked for export *)
BEGIN
  X := 0;   Y := 0;    (* Initial position of pen *)
  initialized := FALSE;
  In.Open;
  In.Int(x0);    In.Int(y0);    In.Int(e);   
  In.Real(a1);  In.Real(a2);   In.Real(a3);  In.Real(a4);
  In.Real(b1);  In.Real(b2);  In.Real(b3);  In.Real(b4);
  In.Real(c1);  In.Real(c2);  In.Real(c3);  In.Real(c4);
  In.Real(d1);  In.Real(d2);  In.Real(d3);  In.Real(d4);
  In.Real(e1);  In.Real(e2);  In.Real(e3);  In.Real(e4);
  In.Real(f1);  In.Real(f2);  In.Real(f3);  In.Real(f4);
  In.Real(p1);  In.Real(p2);  In.Real(p3);  In.Real(p4);
  IF In.Done THEN XYplane.Open;  initialized := TRUE 
  ELSE Out.String("Parameter error"); Out.Ln
  END
END Init;
*)
PROCEDURE Init*(ix0, iy0, ie : INTEGER; ia1, ia2, ia3, ia4, ib1, ib2, ib3, ib4, ic1, ic2, ic3, ic4, id1, id2, id3, id4, ie1, ie2, ie3, ie4, if1, if2, if3, if4, ip1, ip2, ip3, ip4 : REAL);
BEGIN
x0 := ix0; y0 := iy0; e := ie;
a1 := ia1; a2 := ia2; a3 := ia3; a4 := ia4; 
b1 := ib1; b2 := ib2; b3 := ib3; b4 := ib4;
c1 := ic1; c2 := ic2; c3 := ic3; c4 := ic4;
d1 := id1; d2 := id2; d3 := id3; d4 := id4;
e1 := ie1; e2 := ie2; e3 := ie3; e4 := ie4;
f1 := if1; f2 := if2; f3 := if3; f4 := if4;
p1 := ip1; p2 := ip2; p3 := ip3; p4 := ip4;

XYplane.Open; initialized := TRUE;

END Init;

BEGIN  initialized := FALSE



END IFS.  (* Copyright M. Reiser, 1992 *)

IFS.Init 200 50 40
0.0 0.85 0.2 -0.15
0.0 0.04 -0.26 0.28
0.0 -0.04 0.23 0.26
0.16 0.85 0.22 0.24
0.0 0.0 0.0 0.0 
0.0 1.6 1.6 0.44
0.01 0.85 0.07 0.07 ~

IFS.Draw
