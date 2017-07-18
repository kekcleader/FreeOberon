(*	$Id: RealStr.Mod,v 1.7 1999/09/02 13:25:39 acken Exp $	*)
MODULE oocRealStr;
(*  RealStr -  REAL/string conversions.       
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
  Low := oocLowReal, Conv := oocConvTypes, RC := oocRealConv, Real := oocLRealMath, 
  Str := oocStrings;
 
CONST
  ZERO=0.0; FIVE=5.0; TEN=10.0;
  
  DEBUG = FALSE;
 
TYPE
  ConvResults*= Conv.ConvResults; 
  (* possible values: strAllRight, strOutOfRange, strWrongFormat, strEmpty *)
  
CONST
  strAllRight*=Conv.strAllRight;
  (* the string format is correct for the corresponding conversion *)
  strOutOfRange*=Conv.strOutOfRange;
  (* the string is well-formed but the value cannot be represented *)
  strWrongFormat*=Conv.strWrongFormat;
  (* the string is in the wrong format for the conversion *)
  strEmpty*=Conv.strEmpty;
  (* the given string is empty *)
 
(* the string form of a signed fixed-point real number is
     ["+" | "-"] decimal_digit {decimal_digit} ["." {decimal_digit}]
*)
 
(* the string form of a signed floating-point real number is
     signed_fixed-point_real_number ("E" | "e") ["+" | "-"] 
                                                  decimal_digit {decimal_digit}
*)
 
PROCEDURE StrToReal*(str: ARRAY OF CHAR; VAR real: REAL; VAR res: ConvResults);
(* Ignores any leading spaces in `str'.  If the subsequent characters in `str'
   are in the format of a signed real number, and shall assign values to 
   `res' and `real' as follows:
  
   strAllRight  
     if the remainder of `str' represents a complete signed real number
     in the range of the type of `real' -- the value of this number shall
     be assigned to `real';
   strOutOfRange
     if the remainder of `str' represents a complete signed real number
     but its value is out of the range of the type of `real' -- the
     maximum or minimum value of the type of `real' shall be assigned to 
     `real' according to the sign of the number;
   strWrongFormat
     if there are remaining characters in `str' but these are not in the
     form of a complete signed real number -- the value of `real' is not
     defined;
   strEmpty
     if there are no remaining characters in `str' -- the value of `real'
     is not defined.  *)
BEGIN
  res:=RC.FormatReal(str);
  IF res IN {strAllRight, strOutOfRange} THEN real:=RC.ValueReal(str) END
END StrToReal;

PROCEDURE AppendDigit(dig: LONGINT; VAR str: ARRAY OF CHAR);
VAR ds: ARRAY 2 OF CHAR;
BEGIN
  ds[0]:=CHR(dig+ORD("0")); ds[1]:=0X; Str.Append(ds, str)
END AppendDigit;

PROCEDURE AppendExponent(exp: INTEGER; VAR str: ARRAY OF CHAR);
BEGIN
  Str.Append("E", str);
  IF exp<0 THEN exp:=-exp; Str.Append("-", str) 
  ELSE Str.Append("+", str) 
  END;
  IF exp>=10 THEN AppendDigit(exp DIV 10, str) END; 
  AppendDigit(exp MOD 10, str)
END AppendExponent;

PROCEDURE NextFraction(VAR real: LONGREAL; dec: INTEGER; VAR str: ARRAY OF CHAR);
VAR dig: LONGINT;
BEGIN
  dig:=ENTIER(real*Real.ipower(TEN, dec)); AppendDigit(dig, str); real:=real-Real.ipower(TEN, -dec)*dig
END NextFraction;

PROCEDURE AppendFraction(real: LONGREAL; sigFigs, exp, place: INTEGER; VAR str: ARRAY OF CHAR);
VAR digs: INTEGER;
BEGIN
  (* write significant digits *)
  FOR digs:=0 TO sigFigs-1 DO 
    IF digs=place THEN Str.Append(".", str) END;  
    NextFraction(real, digs-exp, str)
  END;
  
  (* pad out digits to the decimal position *)
  FOR digs:=sigFigs TO place-1 DO Str.Append("0", str) END 
END AppendFraction;

PROCEDURE RemoveLeadingZeros(VAR str: ARRAY OF CHAR);
VAR len: LONGINT;
BEGIN
  len:=Str.Length(str);
  WHILE (len>1)&(str[0]="0")&(str[1]#".") DO Str.Delete(str, 0, 1); DEC(len) END
END RemoveLeadingZeros;

PROCEDURE ExtractExpScale(VAR real: LONGREAL; VAR exp, expoff: INTEGER);
CONST
  SCALE=1.0D10;
BEGIN
  exp:=Low.exponent10(SHORT(real));
  
  (* adjust number to avoid overflow/underflows *)
  IF exp>20 THEN real:=real/SCALE; DEC(exp, 10); expoff:=10
  ELSIF exp<-20 THEN real:=real*SCALE; INC(exp, 10); expoff:=-10
  ELSE expoff:=0
  END
END ExtractExpScale;

PROCEDURE RealToFloat*(real: REAL; sigFigs: INTEGER; VAR str: ARRAY OF CHAR);
(* The call `RealToFloat(real,sigFigs,str)' shall assign to `str' the possibly
   truncated string corresponding to the value of `real' in floating-point 
   form.  A sign shall be included only for negative values.  One significant 
   digit shall be included in the whole number part.  The signed exponent part
   shall be included only if the exponent value is not 0.  If the value of 
   `sigFigs' is greater than 0, that number of significant digits shall be 
   included, otherwise an implementation-defined number of significant digits 
   shall be included.  The decimal point shall not be included if there are no
   significant digits in the fractional part.
   
   For example:
   
   value:     3923009     39.23009     0.0003923009
   sigFigs
     1        4E+6        4E+1         4E-4 
     2        3.9E+6      3.9E+1       3.9E-4
     5        3.9230E+6   3.9230E+1    3.9230E-4
*)
VAR
  x: LONGREAL; expoff, exp: INTEGER; lstr: ARRAY 32 OF CHAR;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:=""; x:=real;
  IF sigFigs<=0 THEN sigFigs:=RC.SigFigs END;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;
  IF x<ZERO THEN Str.Append("-", lstr); x:=-x END; 
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;
  ExtractExpScale(x, exp, expoff);
    
  (* round the number and extract exponent again (ie. 9.9 => 10.0) *)
  IF real#ZERO THEN
    x:=x+FIVE*Real.ipower(TEN, exp-sigFigs);
    exp:=Low.exponent10(SHORT(x))
  END;  
  
  (* output number like x[.{x}][E+n[n]] *)                       
  AppendFraction(x, sigFigs, exp, 1, lstr);
  IF exp#0 THEN AppendExponent(exp+expoff, lstr) END;
  
  (* possibly truncate the result *)
  COPY(lstr, str) 
END RealToFloat;
 
PROCEDURE RealToEng*(real: REAL; sigFigs: INTEGER; VAR str: ARRAY OF CHAR);
(* Converts the value of `real' to floating-point string form, with `sigFigs'
   significant figures, and copies the possibly truncated result to `str'.  The
   number is scaled with one to three digits in the whole number part and with
   an exponent that is a multiple of three.
    
   For example:
   
   value:     3923009     39.23009   0.0003923009
   sigFigs
     1        4E+6        40         400E-6 
     2        3.9E+6      39         390E-6
     5        3.9230E+6   39.230     392.30E-6     
*)
VAR
  x: LONGREAL; exp, expoff, offset: INTEGER; lstr: ARRAY 32 OF CHAR;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:=""; x:=real;
  IF sigFigs<=0 THEN sigFigs:=RC.SigFigs END;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;
  IF x<ZERO THEN Str.Append("-", lstr); x:=-x END; 
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;    
  ExtractExpScale(x, exp, expoff);  
  
  (* round the number and extract exponent again (ie. 9.9 => 10.0) *)
  IF real#ZERO THEN
    x:=x+FIVE*Real.ipower(TEN, exp-sigFigs);
    exp:=Low.exponent10(SHORT(x))
  END;
  
  (* find the offset to make the exponent a multiple of three *)
  offset:=(exp+expoff) MOD 3;
  
  (* output number like x[x][x][.{x}][E+n[n]] *)                               
  AppendFraction(x, sigFigs, exp, offset+1, lstr);
  exp:=exp-offset+expoff;
  IF exp#0 THEN AppendExponent(exp, lstr) END;
  
  (* possibly truncate the result *)
  COPY(lstr, str)    
END RealToEng;
 
PROCEDURE RealToFixed*(real: REAL; place: INTEGER; VAR str: ARRAY OF CHAR);
(* The call `RealToFixed(real,place,str)' shall assign to `str' the possibly 
   truncated string corresponding to the value of `real' in fixed-point form.
   A sign shall be included only for negative values.  At least one digit shall
   be included in the whole number part.  The value shall be rounded to the 
   given value of `place' relative to the decimal point.  The decimal point 
   shall be suppressed if `place' is less than 0.
   
   For example:
   
   value:     3923009         3.923009   0.0003923009
   sigFigs
    -5        3920000         0          0 
    -2        3923010         0          0
    -1        3923009         4          0 
     0        3923009.        4.         0. 
     1        3923009.0       3.9        0.0
     4        3923009.0000    3.9230     0.0004       
*)
VAR
  x: LONGREAL; exp, expoff: INTEGER; addDecPt: BOOLEAN; lstr: ARRAY 256 OF CHAR;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:=""; addDecPt:=place=0; x:=real;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;
  IF x<ZERO THEN Str.Append("-", lstr); x:=-x END; 
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;    
  ExtractExpScale(x, exp, expoff);   
  
  (* round the number and extract exponent again (ie. 9.9 => 10.0) *)
  IF place<0 THEN INC(place, 2) ELSE INC(place) END;
  IF real#ZERO THEN
    x:=x+FIVE*Real.ipower(TEN, -place);
    exp:=Low.exponent10(SHORT(x))
  END;
  
  (* output number like x[{x}][.{x}] *)
  INC(place, expoff);
  IF exp+expoff<0 THEN
    IF place<=0 THEN Str.Append("0", lstr)
    ELSE AppendFraction(x, place, 0, 1, lstr) 
    END
  ELSE AppendFraction(x, exp+place, exp, exp+expoff+1, lstr);
    RemoveLeadingZeros(lstr)
  END;
  
  (* special formatting ?? *)
  IF addDecPt THEN Str.Append(".", lstr) END;
    
  (* possibly truncate the result *)
  COPY(lstr, str) 
END RealToFixed;
 
PROCEDURE RealToStr*(real: REAL; VAR str: ARRAY OF CHAR);
(* If the sign and magnitude of `real' can be shown within the capacity of 
   `str', the call RealToStr(real,str) shall behave as the call
   `RealToFixed(real,place,str)', with a value of `place' chosen to fill
   exactly the remainder of `str'.  Otherwise, the call shall behave as
   the call `RealToFloat(real,sigFigs,str)', with a value of `sigFigs' of
   at least one, but otherwise limited to the number of significant
   digits that can be included together with the sign and exponent part
   in `str'.  *)
VAR 
  cap, exp, fp, len, pos: INTEGER;
  found: BOOLEAN;
BEGIN
  cap:=SHORT(LEN(str))-1;  (* determine the capacity of the string with space for trailing 0X *)
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;
  IF real<ZERO THEN COPY("-", str); fp:=-1 ELSE COPY("", str); fp:=0 END; 
  IF Low.IsInfinity(ABS(real)) THEN Str.Append("Infinity", str); RETURN END;
  
  (* extract exponent *)
  exp:=Low.exponent10(real);
  
  (* format number *)
  INC(fp, RC.SigFigs-exp-2);
  len:=RC.LengthFixedReal(real, fp);
  IF cap>=len THEN
    RealToFixed(real, fp, str);
    
    (* pad with remaining zeros *)
    IF fp<0 THEN Str.Append(".", str); INC(len) END; (* add decimal point *)
    WHILE len<cap DO Str.Append("0", str); INC(len) END
  ELSE
    fp:=RC.LengthFloatReal(real, RC.SigFigs); (* check actual length *)
    IF fp<=cap THEN
      RealToFloat(real, RC.SigFigs, str);
      
      (* pad with remaining zeros *)
      Str.FindNext("E", str, 2, found, pos);
      WHILE fp<cap DO Str.Insert("0", pos, str); INC(fp) END
    ELSE fp:=RC.SigFigs-fp+cap;
      IF fp<1 THEN fp:=1 END;
      RealToFloat(real, fp, str)      
    END
  END
END RealToStr;

PROCEDURE Test;
CONST n1=3923009.0; n2=39.23009; n3=0.0003923009; n4=3.923009;
VAR str: ARRAY 80 OF CHAR; len: INTEGER;
BEGIN
  RealToFloat(MAX(REAL), 9, str);
  RealToEng(MAX(REAL), 9, str);
  RealToFixed(MAX(REAL), 9, str);
  RealToFloat(MIN(REAL), 9, str);
  RealToFloat(1.0E10, 9, str);
  RealToFloat(0.0, 0, str);
  RealToFloat(n1, 0, str);
  RealToFloat(n2, 0, str);
  RealToFloat(n3, 0, str);
  RealToFloat(n4, 0, str);

  RealToFloat(n1, 1, str); len:=RC.LengthFloatReal(n1, 1);
  RealToFloat(n1, 2, str); len:=RC.LengthFloatReal(n1, 2);
  RealToFloat(n1, 5, str); len:=RC.LengthFloatReal(n1, 5);
  RealToFloat(n2, 1, str); len:=RC.LengthFloatReal(n2, 1);
  RealToFloat(n2, 2, str); len:=RC.LengthFloatReal(n2, 2);
  RealToFloat(n2, 5, str); len:=RC.LengthFloatReal(n2, 5);
  RealToFloat(n3, 1, str); len:=RC.LengthFloatReal(n3, 1);
  RealToFloat(n3, 2, str); len:=RC.LengthFloatReal(n3, 2);
  RealToFloat(n3, 5, str); len:=RC.LengthFloatReal(n3, 5); 
  
  RealToEng(n1, 1, str); len:=RC.LengthEngReal(n1, 1);
  RealToEng(n1, 2, str); len:=RC.LengthEngReal(n1, 2);
  RealToEng(n1, 5, str); len:=RC.LengthEngReal(n1, 5);
  RealToEng(n2, 1, str); len:=RC.LengthEngReal(n2, 1);
  RealToEng(n2, 2, str); len:=RC.LengthEngReal(n2, 2);
  RealToEng(n2, 5, str); len:=RC.LengthEngReal(n2, 5);
  RealToEng(n3, 1, str); len:=RC.LengthEngReal(n3, 1);
  RealToEng(n3, 2, str); len:=RC.LengthEngReal(n3, 2);
  RealToEng(n3, 5, str); len:=RC.LengthEngReal(n3, 5); 
  
  RealToFixed(n1, -5, str); len:=RC.LengthFixedReal(n1, -5);
  RealToFixed(n1, -2, str); len:=RC.LengthFixedReal(n1, -2);
  RealToFixed(n1, -1, str); len:=RC.LengthFixedReal(n1, -1);
  RealToFixed(n1,  0, str); len:=RC.LengthFixedReal(n1,  0);
  RealToFixed(n1,  1, str); len:=RC.LengthFixedReal(n1,  1);
  RealToFixed(n1,  4, str); len:=RC.LengthFixedReal(n1,  4);  
  RealToFixed(n4, -5, str); len:=RC.LengthFixedReal(n4, -5);
  RealToFixed(n4, -2, str); len:=RC.LengthFixedReal(n4, -2);
  RealToFixed(n4, -1, str); len:=RC.LengthFixedReal(n4, -1);
  RealToFixed(n4,  0, str); len:=RC.LengthFixedReal(n4,  0);
  RealToFixed(n4,  1, str); len:=RC.LengthFixedReal(n4,  1);
  RealToFixed(n4,  4, str); len:=RC.LengthFixedReal(n4,  4);  
  RealToFixed(n3, -5, str); len:=RC.LengthFixedReal(n3, -5);
  RealToFixed(n3, -2, str); len:=RC.LengthFixedReal(n3, -2);
  RealToFixed(n3, -1, str); len:=RC.LengthFixedReal(n3, -1);     
  RealToFixed(n3,  0, str); len:=RC.LengthFixedReal(n3,  0);
  RealToFixed(n3,  1, str); len:=RC.LengthFixedReal(n3,  1);
  RealToFixed(n3,  4, str); len:=RC.LengthFixedReal(n3,  4);  
END Test;

BEGIN
  IF DEBUG THEN Test END
END oocRealStr.






