(*	$Id: LongInts.Mod,v 1.3 1999/09/02 13:14:52 acken Exp $	*)
MODULE oocLongInts;
 
 (*
    LongInts - Simple extended integer implementation.       
    Copyright (C) 1996 Michael Griebling
 
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
CONST
  B*=8000H;
 
TYPE
  LongInt*=ARRAY 170 OF INTEGER;  


PROCEDURE MinDigit * (VAR w: LongInt) : LONGINT;
VAR min, l: LONGINT;
BEGIN
  min:=1; l:=LEN(w)-1;
  WHILE (min<l) & (w[min]=0) DO INC(min) END;
  RETURN min
END MinDigit;

PROCEDURE MultDigit * (VAR w: LongInt; digit, k: LONGINT);
VAR i, t, min: LONGINT;
BEGIN
  i:=LEN(w)-1; min:=MinDigit(w)-2;
  REPEAT                            
    t:=w[i]*digit+k;                  (* multiply *)
    w[i]:=SHORT(t MOD B); k:=t DIV B; (* generate result & carry *)
    DEC(i)
  UNTIL i=min
END MultDigit;

PROCEDURE AddDigit * (VAR w: LongInt; k: LONGINT);
VAR i, t, min: LONGINT;
BEGIN
  i:=LEN(w)-1; min:=MinDigit(w)-2;
  REPEAT                            
    t:=w[i]+k;                        (* add *)
    w[i]:=SHORT(t MOD B); k:=t DIV B; (* generate result & carry *)
    DEC(i)
  UNTIL i=min
END AddDigit;

PROCEDURE DivDigit * (VAR w: LongInt; digit: LONGINT; VAR r: LONGINT);
VAR j, t, m: LONGINT;
BEGIN
  j:=MinDigit(w)-1; r:=0; m:=LEN(w)-1;
  REPEAT                            
    t:=r*B+w[j];
    w[j]:=SHORT(t DIV digit); r:=t MOD digit; (* generate result & remainder *)
    INC(j)
  UNTIL j>m
END DivDigit;

PROCEDURE TenPower * (VAR x: LongInt; power: INTEGER);
VAR exp, i: INTEGER; d: LONGINT;
BEGIN
  IF power>0 THEN
    exp:=power DIV 4; power:=power MOD 4;
    FOR i:=1 TO exp DO MultDigit(x, 10000, 0) END;  
    FOR i:=1 TO power DO MultDigit(x, 10, 0) END  
  ELSIF power<0 THEN
    power:=-power;
    exp:=power DIV 4; power:=power MOD 4;
    FOR i:=1 TO exp DO DivDigit(x, 10000, d) END;  
    FOR i:=1 TO power DO DivDigit(x, 10, d) END
  END
END TenPower;

PROCEDURE BPower * (VAR x: LongInt; power: INTEGER);
VAR i, lx: LONGINT;
BEGIN
  lx:=LEN(x);
  IF power>0 THEN 
    FOR i:=1 TO lx-1-power DO x[i]:=x[i+power] END;
    FOR i:=lx-power TO lx-1 DO x[i]:=0 END 
  ELSIF power<0 THEN
    power:=-power;
    FOR i:=lx-1-power TO 1 BY -1 DO x[i+power]:=x[i] END;
    FOR i:=1 TO power DO x[i]:=0 END
  END
END BPower;


END oocLongInts.
