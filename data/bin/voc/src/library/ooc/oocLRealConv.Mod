(*	$Id: LRealConv.Mod,v 1.7 1999/10/12 07:17:54 ooc-devel Exp $	*)
MODULE oocLRealConv;
 
 (*
    LRealConv -  Low-level LONGREAL/string conversions.       
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
 
IMPORT
  Char := oocCharClass, Low := oocLowLReal, Str := oocStrings, Conv := oocConvTypes,
  LInt := oocLongInts, SYSTEM;

CONST
  ZERO=0.0D0;
  SigFigs*=15;  (* accuracy of LONGREALs *)
  
  DEBUG = FALSE;
 
TYPE
  ConvResults*= Conv.ConvResults; (* strAllRight, strOutOfRange, strWrongFormat, strEmpty *)
  LongInt=LInt.LongInt; 

CONST
  strAllRight*=Conv.strAllRight;       (* the string format is correct for the corresponding conversion *)
  strOutOfRange*=Conv.strOutOfRange;   (* the string is well-formed but the value cannot be represented *)
  strWrongFormat*=Conv.strWrongFormat; (* the string is in the wrong format for the conversion *)
  strEmpty*=Conv.strEmpty;             (* the given string is empty *)

VAR
  RS, P, F, E, SE, WE, SR: Conv.ScanState;
  

PROCEDURE IsExponent (ch: CHAR) : BOOLEAN;
BEGIN
  RETURN (ch="E") OR (ch="D")
END IsExponent;

PROCEDURE IsSign (ch: CHAR): BOOLEAN;
(* Return TRUE for '+' or '-' *)
BEGIN
  RETURN (ch='+')OR(ch='-')
END IsSign;  


(* internal state machine procedures *)

PROCEDURE RSState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=P
  ELSE chClass:=Conv.invalid; nextState:=RS
  END
END RSState;
  
PROCEDURE PState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=P
  ELSIF inputCh="." THEN chClass:=Conv.valid; nextState:=F
  ELSIF IsExponent(inputCh) THEN chClass:=Conv.valid; nextState:=E  
  ELSE chClass:=Conv.terminator; nextState:=NIL
  END
END PState;
  
PROCEDURE FState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=F
  ELSIF IsExponent(inputCh) THEN chClass:=Conv.valid; nextState:=E  
  ELSE chClass:=Conv.terminator; nextState:=NIL
  END
END FState;
 
PROCEDURE EState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF IsSign(inputCh) THEN chClass:=Conv.valid; nextState:=SE
  ELSIF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=WE  
  ELSE chClass:=Conv.invalid; nextState:=E
  END
END EState;

PROCEDURE SEState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=WE  
  ELSE chClass:=Conv.invalid; nextState:=SE
  END
END SEState;

PROCEDURE WEState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=WE  
  ELSE chClass:=Conv.terminator; nextState:=NIL
  END
END WEState;

PROCEDURE Real (VAR x: LongInt; exp, digits: LONGINT; VAR outOfRange: BOOLEAN): LONGREAL;
CONST BR=LInt.B+ZERO; InvLOGB=0.221461873;      (* real version *)
VAR cnt, len, scale, Bscale, start, bexp, max: LONGINT; r: LONGREAL;
BEGIN
  (* scale by the exponent *)
  scale:=exp+digits;
  IF scale>=ABS(digits) THEN 
    Bscale:=0; LInt.TenPower(x, SHORT(scale))
  ELSE 
    Bscale:=ENTIER(-scale*InvLOGB)+6; 
    LInt.BPower(x, SHORT(Bscale));       (* x*B^Bscale *)
    LInt.TenPower(x, SHORT(scale));      (* x*B^BScale*10^scale *)
  END;
  
  (* prescale to left-justify the number *)
  start:=LInt.MinDigit(x); bexp:=0;      (* find starting digit *) 
  IF (start=LEN(x)-1)&(x[start]=0) THEN  (* exit here for zero *)
    outOfRange:=FALSE; RETURN ZERO
  END;
  WHILE x[start]<LInt.B DIV 2 DO            
    LInt.MultDigit(x, 2, 0); INC(bexp)   (* normalize *)
  END;

  (* convert to a LONGREAL *)
  r:=ZERO; len:=LEN(x)-1; max:=start+3;
  IF max>len THEN max:=len END;
  FOR cnt:=start TO max DO r:=r*BR+x[cnt] END;
    
  (* post scaling *)
  INC(bexp, (Bscale-len+max)*15);
  
  (* quick check for overflow *)
  max:=Low.exponent(r)-SHORT(bexp);
  IF (max>Low.expoMax) OR (max<Low.expoMin) THEN 
    outOfRange:=TRUE;
    RETURN ZERO
  ELSE 
    outOfRange:=FALSE;
    RETURN Low.scale(r, -SHORT(bexp))
  END
END Real;
     
PROCEDURE ScanReal*(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
 (* 
    Represents the start state of a finite state scanner for real numbers - assigns
    class of inputCh to chClass and a procedure representing the next state to
    nextState.
    
    The call of ScanReal(inputCh,chClass,nextState) shall assign values to
    `chClass' and `nextState' depending upon the value of `inputCh' as
    shown in the following table.
    
    Procedure       inputCh         chClass         nextState (a procedure
                                                    with behaviour of)
    ---------       ---------       --------        ---------
    ScanReal        space           padding         ScanReal
                    sign            valid           RSState
                    decimal digit   valid           PState
                    other           invalid         ScanReal
    RSState         decimal digit   valid           PState
                    other           invalid         RSState
    PState          decimal digit   valid           PState
                    "."             valid           FState
                    "E", "D"        valid           EState
                    other           terminator      --
    FState          decimal digit   valid           FState
                    "E", "D"        valid           EState
                    other           terminator      --
    EState          sign            valid           SEState
                    decimal digit   valid           WEState
                    other           invalid         EState
    SEState         decimal digit   valid           WEState
                    other           invalid         SEState
    WEState         decimal digit   valid           WEState
                    other           terminator      --
   
    For examples of how to use ScanReal, refer to FormatReal and
    ValueReal below.     
  *)
BEGIN
  IF Char.IsWhiteSpace(inputCh) THEN chClass:=Conv.padding; nextState:=SR
  ELSIF IsSign(inputCh) THEN chClass:=Conv.valid; nextState:=RS
  ELSIF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=P
  ELSE chClass:=Conv.invalid; nextState:=SR
  END
END ScanReal;
 
PROCEDURE FormatReal*(str: ARRAY OF CHAR): ConvResults;
  (* Returns the format of the string value for conversion to LONGREAL. *)
VAR
  ch: CHAR;
  rn: LONGREAL;
  len, index, digit, nexp, exp: INTEGER;
  state: Conv.ScanState;
  inExp, posExp, decExp, outOfRange: BOOLEAN;
  prev, class: Conv.ScanClass;
  int: LongInt;  
BEGIN
  state:=SR; rn:=0.0; exp:=0; nexp:= 0;
  class:=Conv.padding; prev:=class;
  inExp:=FALSE; posExp:=TRUE; decExp:=FALSE;
  (*FOR len:=0 TO SHORT(LEN(int))-1 DO int[len]:=0 END;*)
  FOR len:=0 TO (LEN(int))-1 DO int[len]:=0 END; (* I don't understand why to SHORT it. LEN(int) will return 170 (defined in LongInts as ARRAY 170 OF INTEGER) both with voc and oo2c the same way; -- noch *)
  len:=Str.Length(str); index:=0;  
  LOOP
    IF index=len THEN EXIT END;
    ch:=str[index];
    state.p(ch, class, state);
    CASE class OF
    | Conv.padding: (* nothing to do *)
    | Conv.valid:
        IF inExp THEN
          IF IsSign(ch) THEN posExp:=ch="+"
          ELSE (* must be digits *)
            digit:=ORD(ch)-ORD("0");
            IF posExp THEN exp:=exp*10+digit
            ELSE exp:=exp*10-digit
            END          
          END
        ELSIF IsExponent(ch) THEN inExp:=TRUE
        ELSIF ch="." THEN decExp:=TRUE
        ELSE (* must be a digit *)
          LInt.MultDigit(int, 10, ORD(ch)-ORD("0")); 
          IF decExp THEN DEC(nexp) END;
        END
    | Conv.invalid, Conv.terminator: EXIT
    ELSE (* Ignore unrecognised class *)
    END;
    prev:=class; INC(index)
  END;
  IF class IN {Conv.invalid, Conv.terminator} THEN 
    RETURN strWrongFormat
  ELSIF prev=Conv.padding THEN 
    RETURN strEmpty
  ELSE
    rn:=Real(int, exp, nexp, outOfRange);
    IF outOfRange THEN RETURN strOutOfRange
    ELSE RETURN strAllRight
    END
  END
END FormatReal;
 
PROCEDURE ValueReal*(str: ARRAY OF CHAR): LONGREAL;
VAR
  ch: CHAR;
  rn: LONGREAL;
  len, index, digit, nexp, exp: INTEGER;
  state: Conv.ScanState;
  inExp, positive, posExp, decExp, outOfRange: BOOLEAN;
  prev, class: Conv.ScanClass;
  int: LongInt;  
BEGIN
  state:=SR; rn:=0.0; exp:=0; nexp:= 0;
  class:=Conv.padding; prev:=class;
  positive:=TRUE; inExp:=FALSE; posExp:=TRUE; decExp:=FALSE;
  (*FOR len:=0 TO SHORT(LEN(int))-1 DO int[len]:=0 END;*)
  FOR len:=0 TO (LEN(int))-1 DO int[len]:=0 END; (* I don't understand why to SHORT it; -- noch *)
  len:=Str.Length(str); index:=0;  
  LOOP
    IF index=len THEN EXIT END;
    ch:=str[index];
    state.p(ch, class, state);
    CASE class OF
    | Conv.padding: (* nothing to do *)
    | Conv.valid:
        IF inExp THEN
          IF IsSign(ch) THEN posExp:=ch="+"
          ELSE (* must be digits *)
            digit:=ORD(ch)-ORD("0");
            IF posExp THEN exp:=exp*10+digit
            ELSE exp:=exp*10-digit
            END          
          END
        ELSIF IsExponent(ch) THEN inExp:=TRUE
        ELSIF IsSign(ch) THEN positive:=ch="+"
        ELSIF ch="." THEN decExp:=TRUE
        ELSE (* must be a digit *)
          LInt.MultDigit(int, 10, ORD(ch)-ORD("0")); 
          IF decExp THEN DEC(nexp) END;
        END
    | Conv.invalid, Conv.terminator: EXIT
    ELSE (* Ignore unrecognised class *)
    END;
    prev:=class; INC(index)
  END;
  IF class IN {Conv.invalid, Conv.terminator} THEN 
    RETURN ZERO
  ELSIF prev=Conv.padding THEN 
    RETURN ZERO
  ELSE
    rn:=Real(int, exp, nexp, outOfRange);
    IF outOfRange THEN RETURN Low.large END
  END;
  IF ~positive THEN rn:=-rn END;
  RETURN rn
END ValueReal;

PROCEDURE LengthFloatReal*(real: LONGREAL; sigFigs: INTEGER): INTEGER;
 (* 
    Returns the number of characters in the floating-point string 
    representation of real with sigFigs significant figures.
    This value corresponds to the capacity of an array `str' which 
    is of the minimum capacity needed to avoid truncation of the
    result in the call LongStr.RealToFloat(real,sigFigs,str).
 *)
VAR
  len, exp: INTEGER;
BEGIN
  IF Low.IsNaN(real) THEN RETURN 3
  ELSIF Low.IsInfinity(real) THEN 
    IF real<ZERO THEN RETURN 9 ELSE RETURN 8 END
  END;
  IF sigFigs=0 THEN sigFigs:=SigFigs END; len:=sigFigs; (* default digits -- if none given *)
  IF real<ZERO THEN INC(len); real:=-real END;          (* account for the sign *)
  exp:=Low.exponent10(real);
  IF sigFigs>1 THEN INC(len) END;                       (* account for the decimal point *)
  IF exp>10 THEN INC(len, 4)                            (* account for the exponent *) 
  ELSIF exp#0 THEN INC(len, 3)
  END;
  RETURN len
END LengthFloatReal;
 
PROCEDURE LengthEngReal*(real: LONGREAL; sigFigs: INTEGER): INTEGER;
 (* 
    Returns the number of characters in the floating-point engineering 
    string representation of real with sigFigs significant figures.
    This value corresponds to the capacity of an array `str' which is 
    of the minimum capacity needed to avoid truncation of the result in 
    the call LongStr.RealToEng(real,sigFigs,str).
  *)
VAR
  len, exp, off: INTEGER;
BEGIN
  IF Low.IsNaN(real) THEN RETURN 3
  ELSIF Low.IsInfinity(real) THEN 
    IF real<ZERO THEN RETURN 9 ELSE RETURN 8 END
  END;
  IF sigFigs=0 THEN sigFigs:=SigFigs END; len:=sigFigs;  (* default digits -- if none given *)
  IF real<ZERO THEN INC(len); real:=-real END;           (* account for the sign *)
  exp:=Low.exponent10(real); off:=exp MOD 3;             (* account for the exponent *)
  IF exp-off>10 THEN INC(len, 4) 
  ELSIF exp-off#0 THEN INC(len, 3)
  END;  
  IF sigFigs>off+1 THEN INC(len) END;                    (* account for the decimal point *)           
  IF off+1-sigFigs>0 THEN INC(len, off+1-sigFigs) END;   (* account for extra padding digits *)
  RETURN len
END LengthEngReal;
 
PROCEDURE LengthFixedReal*(real: LONGREAL; place: INTEGER): INTEGER;
 (* Returns the number of characters in the fixed-point string 
    representation of real rounded to the given place relative 
    to the decimal point.
    This value corresponds to the capacity of an array `str' which 
    is of the minimum capacity needed to avoid truncation of the
    result in the call LongStr.RealToFixed(real,sigFigs,str).      
  *)
VAR
  len, exp: INTEGER; addDecPt: BOOLEAN;
BEGIN
  IF Low.IsNaN(real) THEN RETURN 3
  ELSIF Low.IsInfinity(real) THEN 
    IF real<ZERO THEN RETURN 9 ELSE RETURN 8 END
  END;
  exp:=Low.exponent10(real); addDecPt:=place>=0;
  IF place<0 THEN INC(place, 2) ELSE INC(place) END;
  IF exp<0 THEN                                          (* account for digits *)
    IF place<=0 THEN len:=1 ELSE len:=place END
  ELSE len:=exp+place;                                
    IF 1-place>0 THEN INC(len, 1-place) END
  END;
  IF real<ZERO THEN INC(len) END;                        (* account for the sign *)
  IF addDecPt THEN INC(len) END;                         (* account for decimal point *)
  RETURN len
END LengthFixedReal;
 
PROCEDURE IsRConvException*(): BOOLEAN;
  (* Returns TRUE if the current coroutine is in the exceptional execution state because
     of the raising of the RealConv exception; otherwise returns FALSE.
  *)
BEGIN
  RETURN FALSE
END IsRConvException;

PROCEDURE Test;
VAR res: INTEGER; f: LONGREAL;
BEGIN
  f:=ValueReal("-1.8770465240919248E+246");
  f:=ValueReal("5.1059259362558051E-111");
  f:=ValueReal("2.4312432637500083E-88");

  res:=LengthFixedReal(100, 0);
  res:=LengthEngReal(100, 0);
  res:=LengthFloatReal(100, 0);
  
  res:=LengthFixedReal(-100.123, 0);
  res:=LengthEngReal(-100.123, 0);
  res:=LengthFloatReal(-100.123, 0);

  res:=LengthFixedReal(-1.0D20, 0);
  res:=LengthEngReal(-1.0D20, 0);
  res:=LengthFloatReal(-1.0D20, 0)
END Test;

BEGIN
  NEW(RS); NEW(P); NEW(F); NEW(E); NEW(SE); NEW(WE); NEW(SR);
  RS.p:=RSState; P.p:=PState; F.p:=FState; E.p:=EState;
  SE.p:=SEState; WE.p:=WEState; SR.p:=ScanReal;
  IF DEBUG THEN Test END
END oocLRealConv.
