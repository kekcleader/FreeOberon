(*	$Id: IntConv.Mod,v 1.6 2002/05/26 12:15:17 mva Exp $	*)
MODULE ooc2IntConv;
(*
    IntConv -  Low-level integer/string conversions.       
    Copyright (C) 2000, 2002 Michael van Acken
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
  Char := ooc2CharClass, Conv := ooc2ConvTypes;
 
TYPE
  ConvResults* = Conv.ConvResults;
  (**One of @oconst{strAllRight}, @oconst{strOutOfRange},
     @oconst{strWrongFormat}, or @oconst{strEmpty}.  *)

CONST
  strAllRight*=Conv.strAllRight;
  (**The string format is correct for the corresponding conversion.  *)
  strOutOfRange*=Conv.strOutOfRange;
  (**The string is well-formed but the value cannot be represented.  *)
  strWrongFormat*=Conv.strWrongFormat;
  (**The string is in the wrong format for the conversion.  *)
  strEmpty*=Conv.strEmpty;
  (**The given string is empty.  *)


VAR
  W, S, SI: Conv.ScanState;
  minInt, maxInt: ARRAY 11 OF CHAR;

CONST
  maxDigits = 10;                        (* length of minInt, maxInt *)

  
(* internal state machine procedures *)

PROCEDURE WState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=W
  ELSE chClass:=Conv.terminator; nextState:=NIL
  END
END WState;
  
 
PROCEDURE SState(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
BEGIN
  IF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=W 
  ELSE chClass:=Conv.invalid; nextState:=S
  END
END SState;

  
PROCEDURE ScanInt*(inputCh: CHAR; VAR chClass: Conv.ScanClass; VAR nextState: Conv.ScanState);
 (**Represents the start state of a finite state scanner for signed whole
    numbers---assigns class of @oparam{inputCh} to @oparam{chClass} and a
    procedure representing the next state to @oparam{nextState}.

    The call of @samp{ScanInt(inputCh,chClass,nextState)} shall assign values
    to @oparam{chClass} and @oparam{nextState} depending upon the value of
    @oparam{inputCh} as shown in the following table.

    @example
    Procedure       inputCh         chClass         nextState (a procedure
                                                    with behaviour of)
    ---------       ---------       --------        ---------
    ScanInt         space           padding         ScanInt
                    sign            valid           SState
                    decimal digit   valid           WState
                    other           invalid         ScanInt
    SState          decimal digit   valid           WState
                    other           invalid         SState
    WState          decimal digit   valid           WState
                    other           terminator      --
    @end example

    NOTE 1 -- The procedure @oproc{ScanInt} corresponds to the start state of a
    finite state machine to scan for a character sequence that forms a signed
    whole number.  It may be used to control the actions of a finite state
    interpreter.  As long as the value of @oparam{chClass} is other than
    @oconst{Conv.terminator} or @oconst{Conv.invalid}, the
    interpreter should call the procedure whose value is assigned to
    @oparam{nextState} by the previous call, supplying the next character from
    the sequence to be scanned.  It may be appropriate for the interpreter to
    ignore characters classified as @oconst{Conv.invalid}, and proceed
    with the scan.  This would be the case, for example, with interactive
    input, if only valid characters are being echoed in order to give
    interactive users an immediate indication of badly-formed data.  If the
    character sequence end before one is classified as a terminator, the
    string-terminator character should be supplied as input to the finite state
    scanner.  If the preceeding character sequence formed a complete number,
    the string-terminator will be classified as @oconst{Conv.terminator},
    otherwise it will be classified as @oconst{Conv.invalid}.  *)
BEGIN
  IF Char.IsWhiteSpace(inputCh) THEN chClass:=Conv.padding; nextState:=SI
  ELSIF (inputCh="+") OR (inputCh="-") THEN chClass:=Conv.valid; nextState:=S
  ELSIF Char.IsNumeric(inputCh) THEN chClass:=Conv.valid; nextState:=W
  ELSE chClass:=Conv.invalid; nextState:=SI
  END
END ScanInt;
 
 
PROCEDURE FormatInt*(str: ARRAY OF CHAR): ConvResults;
(**Returns the format of the string value for conversion to LONGINT.  *)
VAR
  ch: CHAR;
  index, start: INTEGER;
  state: Conv.ScanState;
  positive: BOOLEAN;
  prev, class: Conv.ScanClass;

  PROCEDURE LessOrEqual (VAR high: ARRAY OF CHAR; start, end: INTEGER): BOOLEAN;
  VAR
    i: INTEGER;
  BEGIN  (* pre: index-start = maxDigits *)
    i := 0;
    WHILE (start # end) DO
      IF (str[start] < high[i]) THEN
        RETURN TRUE;
      ELSIF (str[start] > high[i]) THEN
        RETURN FALSE;
      ELSE  (* str[start] = high[i] *)
        INC (start); INC (i);
      END;
    END;
    RETURN TRUE;                       (* full match *)
  END LessOrEqual;

BEGIN
  index:=0; prev:=Conv.padding; state:=SI; positive:=TRUE; start := -1;
  LOOP
    ch:=str[index];
    state.p(ch, class, state);
    CASE class OF
    | Conv.padding: (* nothing to do *)
      
    | Conv.valid:
        IF ch="-" THEN positive:=FALSE
        ELSIF ch="+" THEN positive:=TRUE
        ELSIF (start < 0) & (ch # "0") THEN
          start := index;
        END
      
    | Conv.invalid:
      IF (prev = Conv.padding) & (ch = 0X) THEN
        RETURN strEmpty;
      ELSE
        RETURN strWrongFormat;
      END;
      
    | Conv.terminator:
      IF (ch = 0X) THEN
        IF (index-start < maxDigits) OR
           (index-start = maxDigits) &
            (positive & LessOrEqual (maxInt, start, index) OR
             ~positive & LessOrEqual (minInt, start, index)) THEN
          RETURN strAllRight;
        ELSE
          RETURN strOutOfRange;
        END;
      ELSE
        RETURN strWrongFormat;
      END;
    ELSE (* Ignore unrecognised class *)
    END;
    prev:=class; INC(index)
  END;
END FormatInt;
 
 
PROCEDURE ValueInt*(str: ARRAY OF CHAR): LONGINT;
(**Returns the value corresponding to the signed whole number string value 
   @oparam{str} if @oparam{str} is well-formed.  Otherwise, result is
   undefined.  *)
VAR
  i: INTEGER;
  int: LONGINT;  
  positive: BOOLEAN;
BEGIN
  IF FormatInt(str)=strAllRight THEN
    (* here holds: `str' is a well formed string and its value is in range *)
    
    i:=0; positive:=TRUE;
    WHILE (str[i] < "0") OR (str[i] > "9") DO    (* skip whitespace and sign *)
      IF (str[i] = "-") THEN
        positive := FALSE;
      END;
      INC (i);
    END;

    int := 0;
    IF positive THEN
      WHILE (str[i] # 0X) DO
        int:=int*10 + (ORD(str[i]) - ORD("0"));
        INC (i);
      END;
    ELSE
      WHILE (str[i] # 0X) DO
        int:=int*10 - (ORD(str[i]) - ORD("0"));
        INC (i);
      END;
    END;
    RETURN int;
  ELSE                                   (* result is undefined *)
    RETURN 0;
  END
END ValueInt;


PROCEDURE LengthInt*(int: LONGINT): INTEGER;
(**Returns the number of characters in the string representation of
   @oparam{int}.  This value corresponds to the capacity of an array @samp{str}
   which is of the minimum capacity needed to avoid truncation of the result in
   the call @samp{IntStr.IntToStr(int,str)}.  *)
VAR
  cnt: INTEGER;
BEGIN
  IF int=MIN(LONGINT) THEN
    RETURN maxDigits+1;
  ELSE
    IF int<=0 THEN int:=-int; cnt:=1 
    ELSE cnt:=0 
    END;
    WHILE int>0 DO INC(cnt); int:=int DIV 10 END;
    RETURN cnt;
  END;
END LengthInt; 

BEGIN
  (* kludge necessary because of recursive procedure declaration *)
  NEW(S); NEW(W); NEW(SI);  
  S.p:=SState; W.p:=WState; SI.p:=ScanInt;
  minInt := "2147483648";
  maxInt := "2147483647";
END ooc2IntConv.
