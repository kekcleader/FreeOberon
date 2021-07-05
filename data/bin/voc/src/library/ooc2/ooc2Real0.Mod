(* 	$Id: Real0.Mod,v 1.3 2002/08/12 18:11:30 mva Exp $	 *)
MODULE ooc2Real0;
(*  Helper functions used by the real conversion modules.
    Copyright (C) 2002  Michael van Acken

    This module is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License
    as published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with OOC. If not, write to the Free Software Foundation,
    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)
   
IMPORT
  CharClass := ooc2CharClass, ConvTypes := ooc2ConvTypes, Strings := ooc2Strings;


TYPE
  ConvResults = ConvTypes.ConvResults;

CONST
  strAllRight=ConvTypes.strAllRight;
  strOutOfRange=ConvTypes.strOutOfRange;
  strWrongFormat=ConvTypes.strWrongFormat;
  strEmpty=ConvTypes.strEmpty;

CONST
  padding=ConvTypes.padding;
  valid=ConvTypes.valid;
  invalid=ConvTypes.invalid;
  terminator=ConvTypes.terminator;

TYPE
  ScanClass = ConvTypes.ScanClass;
  ScanState = ConvTypes.ScanState;

CONST
  expChar* = "E";
  
VAR
  RS-, P-, F-, E-, SE-, WE-, SR-: ScanState;
 

(* internal state machine procedures *)

PROCEDURE IsSign (ch: CHAR): BOOLEAN;
(* Return TRUE for '+' or '-' *)
  BEGIN
    RETURN (ch='+') OR (ch='-')
  END IsSign;  

PROCEDURE RSState(inputCh: CHAR;
                  VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=P
    ELSE
      chClass:=invalid; nextState:=RS
    END
  END RSState;

PROCEDURE PState(inputCh: CHAR;
                 VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=P
    ELSIF inputCh="." THEN
      chClass:=valid; nextState:=F
    ELSIF inputCh=expChar THEN
      chClass:=valid; nextState:=E  
    ELSE
      chClass:=terminator; nextState:=NIL
    END
  END PState;

PROCEDURE FState(inputCh: CHAR;
                 VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=F
    ELSIF inputCh=expChar THEN
      chClass:=valid; nextState:=E  
    ELSE
      chClass:=terminator; nextState:=NIL
    END
  END FState;

PROCEDURE EState(inputCh: CHAR;
                 VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF IsSign(inputCh) THEN
      chClass:=valid; nextState:=SE
    ELSIF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=WE  
    ELSE
      chClass:=invalid; nextState:=E
    END
  END EState;

PROCEDURE SEState(inputCh: CHAR;
                  VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=WE  
    ELSE
      chClass:=invalid; nextState:=SE
    END
  END SEState;

PROCEDURE WEState(inputCh: CHAR;
                  VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=WE  
    ELSE
      chClass:=terminator; nextState:=NIL
    END
  END WEState;

PROCEDURE ScanReal*(inputCh: CHAR;
                    VAR chClass: ScanClass; VAR nextState: ScanState);
  BEGIN
    IF CharClass.IsWhiteSpace(inputCh) THEN
      chClass:=padding; nextState:=SR
    ELSIF IsSign(inputCh) THEN
      chClass:=valid; nextState:=RS
    ELSIF CharClass.IsNumeric(inputCh) THEN
      chClass:=valid; nextState:=P
    ELSE
      chClass:=invalid; nextState:=SR
    END
  END ScanReal;

PROCEDURE FormatReal* (str: ARRAY OF CHAR; maxExp: LONGINT;
                       maxValue: ARRAY OF CHAR): ConvResults;
  VAR
    i: LONGINT;
    ch: CHAR;
    state: ConvTypes.ScanState;
    class: ConvTypes.ScanClass;
    wSigFigs, fLeadingZeros, exp, startOfExp: LONGINT;
    expNegative, allZeroDigit: BOOLEAN;
    
  CONST
    expCutoff = 100000000;
    (* assume overflow if the value of the exponent is larger than this *)

  PROCEDURE NonZeroDigit (): LONGINT;
  (* locate first non-zero digit in str *)
    BEGIN
      i := 0;
      WHILE (i # startOfExp) & ((str[i] < "1") OR (str[i] > "9")) DO
        INC (i);
      END;
      RETURN i;
    END NonZeroDigit;
  
  PROCEDURE LessOrEqual (upperBound: ARRAY OF CHAR): BOOLEAN;
    VAR
      i, j: LONGINT;
    BEGIN
      i := NonZeroDigit();
      IF (i # startOfExp) THEN         (* str[i] is non-zero digit  *)
        j := 0;
        WHILE (i # startOfExp) & (upperBound[j] # 0X) DO
          IF (str[i] < upperBound[j]) THEN
            RETURN TRUE;
          ELSIF (str[i] > upperBound[j]) THEN
            RETURN FALSE;
          ELSE
            INC (j); INC (i);
            IF (str[i] = ".") THEN       (* skip decimal point *)
              INC (i);
            END;
          END;
        END;
        
        IF (upperBound[j] = 0X) THEN
          (* any trailing zeros don't change the outcome: skip them *)
          WHILE (str[i] = "0") OR (str[i] = ".") DO
            INC (i);
          END;
        END;
      END;
      RETURN (i = startOfExp);
    END LessOrEqual;
  
  BEGIN
    (* normalize exponent character *)
    i := 0;
    WHILE (str[i] # 0X) & (str[i] # "e") DO
      INC (i);
    END;
    IF (str[i] = "e") THEN
      str[i] := expChar;
    END;
    
    (* move index `i' over padding characters *)
    i := 0;
    state := SR;
    REPEAT
      ch := str[i];
      state.p(ch, class, state);
      INC (i);
    UNTIL (class # ConvTypes.padding);

    IF (ch = 0X) THEN
      RETURN strEmpty;
    ELSE
      (* scan part before decimal point or exponent *)
      WHILE (class = ConvTypes.valid) & (state # F) & (state # E) &
            ((ch < "1") OR (ch > "9")) DO
        ch := str[i];
        state.p(ch, class, state);
        INC (i);
      END;
      wSigFigs := 0;
      WHILE (class = ConvTypes.valid) & (state # F) & (state # E) DO
        INC (wSigFigs);
        ch := str[i];
        state.p(ch, class, state);
        INC (i);
      END;
      (* here holds: wSigFigs is the number of significant digits in
         the whole number part of the number; 0 means there are only
         zeros before the decimal point *)
      
      (* scan fractional part exponent *)
      fLeadingZeros := 0; allZeroDigit := TRUE;
      WHILE (class = ConvTypes.valid) & (state # E) DO
        ch := str[i];
        IF allZeroDigit THEN
          IF (ch = "0") THEN
            INC (fLeadingZeros);
          ELSIF (ch # ".") THEN
            allZeroDigit := FALSE;
          END;
        END;
        state.p(ch, class, state);
        INC (i);
      END;
      (* here holds: fLeadingZeros holds the number of zeros after
         the decimal point *)
      
      (* scan exponent *)
      startOfExp := i-1; exp := 0; expNegative := FALSE;
      WHILE (class = ConvTypes.valid) DO
        ch := str[i];
        IF (ch = "-") THEN
          expNegative := TRUE;
        ELSIF ("0" <= ch) & (ch <= "9") & (exp < expCutoff) THEN
          exp := exp*10 + (ORD(ch)-ORD("0"));
        END;
        state.p(ch, class, state);
        INC (i);
      END;
      IF expNegative THEN
        exp := -exp;
      END;
      (* here holds: exp holds the value of the exponent; if it's absolute
         value is larger than expCutoff, then there has been an overflow  *)

      IF (class = ConvTypes.invalid) OR (ch # 0X) THEN
        RETURN strWrongFormat;
      ELSE (* (class = ConvTypes.terminator) & (ch = 0X) *)
        (* normalize the number: calculate the exponent if the number would
           start with a non-zero digit, immediately followed by the
           decimal point *)
        IF (wSigFigs > 0) THEN
          exp := exp+wSigFigs-1;
        ELSE
          exp := exp-fLeadingZeros-1;
        END;
        
        IF (exp > maxExp) & (NonZeroDigit() # startOfExp) OR
           (exp = maxExp) & ~LessOrEqual (maxValue) THEN
          RETURN strOutOfRange;
        ELSE
          RETURN strAllRight;
        END;
      END;
    END;
  END FormatReal;
 
PROCEDURE NormalizeFloat* (VAR s: ARRAY OF CHAR);
  VAR
    i, d: INTEGER;
  BEGIN
    (* massage the output of sprintf to match our requirements; note: this
       code should also handle "Inf", "Infinity", "NaN", etc., gracefully
       but this is untested *)
    IF (s[0] = "+") THEN d := 1; ELSE d := 0; END; (* erase "+" sign *)
    i := 1;
    WHILE (s[i] # 0X) DO
      IF (s[i] = ".") & (s[i+1] = expChar) THEN
        INC (d);             (* eliminate "." if no digits follow *)
      ELSIF (s[i] = "0") & (i-d-1 >= 0) & IsSign (s[i-d-1]) THEN
        INC (d);           (* eliminate zeros after exponent sign *)
      ELSE
        s[i-d] := s[i];
      END;
      INC (i);
    END;
    IF (s[i-d-2] = "E") THEN
      s[i-d-2] := 0X;                  (* remove "E+" or "E-" *)
    ELSE
      s[i-d] := 0X;
    END;
  END NormalizeFloat;

PROCEDURE FormatForEng* (VAR s: ARRAY OF CHAR);
  VAR
    i, d, fract, exp, posExp, offset: INTEGER;
  BEGIN
    (* find out how large the exponent is, and how many digits are in the
       fractional part *)
    fract := 0; exp := 0; posExp := 0;
    IF CharClass.IsNumeric (s[1]) THEN   (* skip for NaN, Inf *)
      i := 0; d := 0;
      WHILE (s[i] # "E") DO
        fract := fract + d;
        IF (s[i] = ".") THEN d := 1; END;
        INC (i);
      END;
      INC (i);
      IF (s[i] = "-") THEN d := -1; ELSE d := 1; END;
      posExp := i;
      INC (i);
      WHILE (s[i] # 0X) DO
        exp := exp*10 + d*(ORD (s[i]) - ORD ("0"));
        INC (i);
      END;
    END;
    
    offset := exp MOD 3;
    IF (offset # 0) THEN
      WHILE (fract < offset) DO        (* need more zeros before "E" *)
        Strings.Insert ("0", posExp-1, s); INC (fract); INC (posExp);
      END;
      i := 2;
      WHILE (i < offset+2) DO    (* move "." offset places to right *)
        s[i] := s[i+1]; INC (i);
      END;
      s[i] := ".";

      (* write new exponent *)
      exp := exp-offset;
      IF (exp < 0) THEN
        exp := -exp; s[posExp] := "-";
      ELSE
        s[posExp] := "+";
      END;
      s[posExp+1] := CHR (exp DIV 100 + ORD("0"));
      s[posExp+2] := CHR (exp DIV 10 MOD 10 + ORD("0"));
      s[posExp+3] := CHR (exp MOD 10 + ORD("0"));
      s[posExp+4] := 0X;
    END;
    NormalizeFloat (s);
  END FormatForEng;

PROCEDURE FormatForFixed* (VAR s: ARRAY OF CHAR; place: INTEGER);
  VAR
    i, d, c, fract, point, suffix: INTEGER;

  PROCEDURE NotZero (VAR s: ARRAY OF CHAR; pos: INTEGER): BOOLEAN;
    BEGIN
      WHILE (s[pos] # 0X) DO
        IF (s[pos] # "0") & (s[pos] # ".") THEN
          RETURN TRUE;
        END;
        INC (pos);
      END;
      RETURN FALSE;
    END NotZero;
  
  BEGIN
    IF (place < 0) THEN
      (* locate position of decimal point in string *)
      point := 1;
      WHILE (s[point] # ".") DO INC (point); END;
      
      (* number of digits before point is `point-1'; position in string
         of the first digit that will be converted to zero due to rounding:
         `point+place+1'; rightmost digit that may be incremented because
         of rounding: `point+place' *)
      IF (point+place >= 0) THEN
        suffix := point+place+1; IF (s[suffix] = ".") THEN INC (suffix); END;
        IF (s[suffix] > "5") OR
           (s[suffix] = "5") &
            (NotZero (s, suffix+1) OR
             (point+place # 0) & ODD (ORD (s[point+place]))) THEN
          (* we are rounding up *)
          i := point+place;
          WHILE (s[i] = "9") DO s[i] := "0"; DEC (i); END;
          IF (i = 0) THEN                (* looking at sign *)
            Strings.Insert ("1", 1, s); INC (point);
          ELSE
            s[i] := CHR (ORD (s[i])+1);  (* increment non-"9" digit by one *)
          END;
        END;
        
        (* zero everything after the digit at `place' *)
        i := point+place+1;
        IF (i = 1) THEN                  (* all zero *)
          s[1] := "0"; s[2] := 0X;
        ELSE
          WHILE (s[i] # ".") DO s[i] := "0"; INC (i); END;
        END;
      ELSE                                 (* round to zero *)
        s[1] := "0"; s[2] := 0X;
      END;
      s[point] := 0X;
    END;

    (* correct sign, and add trailing zeros if necessary *)
    IF (s[0] = "+") THEN d := 1; ELSE d := 0; END; (* erase "+" sign *)
    i := 1; fract := 0; c := 0;
    WHILE (s[i] # 0X) DO
      s[i-d] := s[i];
      fract := fract+c;
      IF (s[i] = ".") THEN
        c := 1;
      END;
      INC (i);
    END;
    WHILE (fract < place) DO
      s[i-d] := "0"; INC (fract); INC (i);
    END;
    s[i-d] := 0X;
  END FormatForFixed;

BEGIN
  NEW(RS); RS.p:=RSState; 
  NEW(P);  P.p:=PState; 
  NEW(F);  F.p:=FState; 
  NEW(E);  E.p:=EState;
  NEW(SE); SE.p:=SEState; 
  NEW(WE); WE.p:=WEState; 
  NEW(SR); SR.p:=ScanReal;
END ooc2Real0.
