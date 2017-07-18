(*	$Id: RealConv.Mod,v 1.6 1999/09/02 13:18:59 acken Exp $	*)
MODULE oocRealConv;
 
 (*
    RealConv -  Low-level REAL/string conversions.       
    Copyright (C) 1995 Michael Griebling
 
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
  Char := oocCharClass, Low := oocLowReal, Str := oocStrings, Conv := oocConvTypes;

CONST
  ZERO=0.0; 
  TEN=10.0;
  ExpCh="E";
  SigFigs*=7;  (* accuracy of REALs *)
  
  DEBUG = FALSE;
 
TYPE
  ConvResults*= Conv.ConvResults; (* strAllRight, strOutOfRange, strWrongFormat, strEmpty *)

CONST
  strAllRight*=Conv.strAllRight;       (* the string format is correct for the corresponding conversion *)
  strOutOfRange*=Conv.strOutOfRange;   (* the string is well-formed but the value cannot be represented *)
  strWrongFormat*=Conv.strWrongFormat; (* the string is in the wrong format for the conversion *)
  strEmpty*=Conv.strEmpty;             (* the given string is empty *)


VAR
  RS, P, F, E, SE, WE, SR: Conv.ScanState;
 
  
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
  ELSIF inputCh=ExpCh THEN chClass:=Conv.valid; nextState:=E  
  ELSE chClass:=Conv.terminator; nextState:=NIL
  END
END PState;
  
PROCEDURE FState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=F
  ELSIF inputCh=ExpCh THEN chClass:=Conv.valid; nextState:=E  
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
                    "E"             valid           EState
                    other           terminator      --
    FState          decimal digit   valid           FState
                    "E"             valid           EState
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
  (* Returns the format of the string value for conversion to REAL. *)
VAR
  ch: CHAR;
  rn: LONGREAL;
  len, index, digit, nexp, exp: INTEGER;
  state: Conv.ScanState;
  inExp, posExp, decExp: BOOLEAN;
  prev, class: Conv.ScanClass;
BEGIN
  len:=Str.Length(str); index:=0;
  class:=Conv.padding; prev:=class;
  state:=SR; rn:=0.0; exp:=0; nexp:= 0;
  inExp:=FALSE; posExp:=TRUE; decExp:=FALSE;
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
        ELSIF CAP(ch)=ExpCh THEN inExp:=TRUE
        ELSIF ch="." THEN decExp:=TRUE
        ELSE (* must be a digit *)
          rn:=rn*TEN+(ORD(ch)-ORD("0"));
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
    INC(exp, nexp);
    IF rn#ZERO THEN
      WHILE exp>0 DO
        IF (-3.4028235677973366D+38 < rn) &
           ((rn>=3.4028235677973366D+38) OR 
            (SHORT(rn)>Low.large/TEN)) THEN RETURN strOutOfRange
        ELSE rn:=rn*TEN
        END;
        DEC(exp) 
      END;
      WHILE exp<0 DO
        IF (rn < 3.4028235677973366D+38) &
           ((rn<=-3.4028235677973366D+38) OR 
            (SHORT(rn)<Low.small*TEN)) THEN RETURN strOutOfRange
        ELSE rn:=rn/TEN
        END;
        INC(exp) 
      END
    END;
    RETURN strAllRight
  END
END FormatReal;

PROCEDURE ValueReal*(str: ARRAY OF CHAR): REAL;
  (* 
     Returns the value corresponding to the real number string value str 
     if str is well-formed; otherwise raises the RealConv exception.
  *)
VAR
  ch: CHAR;
  x: REAL;
  rn: LONGREAL;
  len, index, digit, nexp, exp: INTEGER;
  state: Conv.ScanState;
  positive, inExp, posExp, decExp: BOOLEAN;
  prev, class: Conv.ScanClass;
BEGIN
  len:=Str.Length(str); index:=0;
  class:=Conv.padding; prev:=class;
  state:=SR; rn:=0.0; exp:=0; nexp:= 0;
  positive:=TRUE; inExp:=FALSE; posExp:=TRUE; decExp:=FALSE;
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
        ELSIF CAP(ch)=ExpCh THEN inExp:=TRUE
        ELSIF IsSign(ch) THEN positive:=ch="+"
        ELSIF ch="." THEN decExp:=TRUE
        ELSE (* must be a digit *)
          rn:=rn*TEN+(ORD(ch)-ORD("0"));
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
    INC(exp, nexp);
    IF rn#ZERO THEN
      WHILE exp>0 DO rn:=rn*TEN; DEC(exp) END;
      WHILE exp<0 DO rn:=rn/TEN; INC(exp) END
    END;
    x:=SHORT(rn)
  END;
  IF ~positive THEN x:=-x END;
  RETURN x
END ValueReal;

PROCEDURE LengthFloatReal*(real: REAL; sigFigs: INTEGER): INTEGER;
 (* 
    Returns the number of characters in the floating-point string 
    representation of real with sigFigs significant figures.    
    This value corresponds to the capacity of an array `str' which 
    is of the minimum capacity needed to avoid truncation of the
    result in the call RealStr.RealToFloat(real,sigFigs,str).
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
 
PROCEDURE LengthEngReal*(real: REAL; sigFigs: INTEGER): INTEGER;
 (* 
    Returns the number of characters in the floating-point engineering 
    string representation of real with sigFigs significant figures.
    This value corresponds to the capacity of an array `str' which is 
    of the minimum capacity needed to avoid truncation of the result in 
    the call RealStr.RealToEng(real,sigFigs,str).     
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
 
PROCEDURE LengthFixedReal*(real: REAL; place: INTEGER): INTEGER;
 (* 
    Returns the number of characters in the fixed-point string 
    representation of real rounded to the given place relative 
    to the decimal point.
    This value corresponds to the capacity of an array `str' which 
    is of the minimum capacity needed to avoid truncation of the
    result in the call RealStr.RealToFixed(real,sigFigs,str).     
  *)
VAR
  len, exp: INTEGER; addDecPt: BOOLEAN;
BEGIN
  IF Low.IsNaN(real) THEN RETURN 3
  ELSIF Low.IsInfinity(real) THEN 
    IF real<0 THEN RETURN 9 ELSE RETURN 8 END
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
  (* 
     Returns TRUE if the current coroutine is in the exceptional 
     execution state because of the raising of the RealConv exception; 
     otherwise returns FALSE.
  *)
BEGIN
  RETURN FALSE
END IsRConvException;

PROCEDURE Test;
VAR f: REAL; res: INTEGER;
BEGIN
  f:=MAX(REAL);
  f:=ValueReal("3.40282347E+38");

  res:=LengthFixedReal(100, 0);
  res:=LengthEngReal(100, 0);
  res:=LengthFloatReal(100, 0);
  
  res:=LengthFixedReal(-100.123, 0);
  res:=LengthEngReal(-100.123, 0);
  res:=LengthFloatReal(-100.123, 0);

  res:=LengthFixedReal(-1.0E20, 0);
  res:=LengthEngReal(-1.0E20, 0);
  res:=LengthFloatReal(-1.0E20, 0);  
END Test;

BEGIN
  NEW(RS); NEW(P); NEW(F); NEW(E); NEW(SE); NEW(WE); NEW(SR);
  RS.p:=RSState; P.p:=PState; F.p:=FState; E.p:=EState;
  SE.p:=SEState; WE.p:=WEState; SR.p:=ScanReal;
  IF DEBUG THEN Test END
END oocRealConv.
