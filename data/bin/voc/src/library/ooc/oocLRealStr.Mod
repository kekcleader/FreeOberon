(*	$Id: LRealStr.Mod,v 1.8 2001/07/15 14:59:29 ooc-devel Exp $	*)
MODULE oocLRealStr;
 
 (*
    LRealStr -  LONGREAL/string conversions.       
    Copyright (C) 1996, 2001 Michael Griebling
 
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
  Low := oocLowLReal, Conv := oocConvTypes, RC := oocLRealConv, Str := oocStrings,
  LInt := oocLongInts;
 
CONST
  ZERO=0.0D0; B=8000H;
 
TYPE
  ConvResults*= Conv.ConvResults; (* strAllRight, strOutOfRange, strWrongFormat, strEmpty *)

CONST
  strAllRight*=Conv.strAllRight;       (* the string format is correct for the corresponding conversion *)
  strOutOfRange*=Conv.strOutOfRange;   (* the string is well-formed but the value cannot be represented *)
  strWrongFormat*=Conv.strWrongFormat; (* the string is in the wrong format for the conversion *)
  strEmpty*=Conv.strEmpty;             (* the given string is empty *)
 
 
(* the string form of a signed fixed-point real number is
     ["+" | "-"], decimal digit, {decimal digit}, [".", {decimal digit}]
*)
 
(* the string form of a signed floating-point real number is
     signed fixed-point real number, "E"|"e", ["+" | "-"], decimal digit, {decimal digit}
*)
 
PROCEDURE StrToReal*(str: ARRAY OF CHAR; VAR real: LONGREAL; VAR res: ConvResults);
 (* 
    Ignores any leading spaces in str. If the subsequent characters in str 
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
      is not defined.    
  *)
BEGIN
  res:=RC.FormatReal(str);
  IF res IN {strAllRight, strOutOfRange} THEN real:=RC.ValueReal(str) END 
END StrToReal;

PROCEDURE AppendChar(ch: CHAR; VAR str: ARRAY OF CHAR);
VAR ds: ARRAY 2 OF CHAR;
BEGIN
  ds[0]:=ch; ds[1]:=0X; Str.Append(ds, str)
END AppendChar;

PROCEDURE AppendDigit(dig: LONGINT; VAR str: ARRAY OF CHAR);
BEGIN
  AppendChar(CHR(dig+ORD("0")), str)
END AppendDigit;

PROCEDURE AppendExponent(exp: INTEGER; VAR str: ARRAY OF CHAR);
BEGIN
  Str.Append("E", str);
  IF exp<0 THEN exp:=-exp; Str.Append("-", str) 
  ELSE Str.Append("+", str) 
  END;
  IF exp>=100 THEN AppendDigit(exp DIV 100, str) END;
  IF exp>=10 THEN AppendDigit((exp DIV 10) MOD 10, str) END;
  AppendDigit(exp MOD 10, str)
END AppendExponent;

PROCEDURE AppendFraction(VAR n: LInt.LongInt; sigFigs, place: INTEGER; VAR str: ARRAY OF CHAR);
VAR digs, end: INTEGER; d: LONGINT; lstr: ARRAY 64 OF CHAR;
BEGIN      
  (* write significant digits *)
  lstr:="";
  FOR digs:=1 TO sigFigs DO
    LInt.DivDigit(n, 10, d); AppendDigit(d, lstr);
  END;
  
  (* reverse the real digits and append to str *)
  end:=sigFigs-1;
  FOR digs:=0 TO sigFigs-1 DO
    IF digs=place THEN Str.Append(".", str) END;  
    AppendChar(lstr[end], str); DEC(end)
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



PROCEDURE MaxDigit (VAR n: LInt.LongInt) : LONGINT;

VAR

	i, max : LONGINT;

BEGIN

	(* return the maximum digit in the specified LongInt number *)

  FOR i:=0 TO LEN(n)-1 DO

  	 IF n[i] # 0 THEN

		max := n[i];

		WHILE max>=10 DO max:=max DIV 10 END;

      	RETURN max;

    END;       
  END;  

  RETURN 0;

END MaxDigit;

PROCEDURE Scale (x: LONGREAL; VAR n: LInt.LongInt; sigFigs: INTEGER; exp: INTEGER; VAR overflow : BOOLEAN);
CONST
  MaxDigits=4; LOG2B=15;
VAR
  i, m, ln, d: LONGINT; e1, e2: INTEGER;

  max: LONGINT;
BEGIN
  (* extract fraction & exponent *)
  m:=0; overflow := FALSE;
  WHILE Low.exponent(x)=Low.expoMin DO        (* scale up subnormal numbers *)
    x:=x*2.0D0; DEC(m)
  END;
  m:=m+Low.exponent(x); x:=Low.fraction(x);
  x:=Low.scale(x, SHORT(m MOD LOG2B));        (* scale up the number *)   
  m:=m DIV LOG2B;                             (* base B exponent *)

    
  (* convert to an extended integer MOD B *)
  ln:=LEN(n)-1;
  FOR i:=ln-MaxDigits TO ln DO 
    n[i]:=SHORT(ENTIER(x));                   (* convert/store the number *)  
    x:=(x-n[i])*B 
  END;
  FOR i:=0 TO ln-MaxDigits-1 DO n[i]:=0 END;  (* zero the other digits *)
  
  (* scale to get the number of significant digits *)
  e1:=SHORT(m)-MaxDigits; e2:= sigFigs-exp-1;
  IF e1>=0 THEN
    LInt.BPower(n, e1+1); LInt.TenPower(n, e2);

  	max := MaxDigit(n);    (* remember the original digit so we can check for round-up *)	    
    LInt.AddDigit(n, B DIV 2); LInt.DivDigit(n, B, d) (* round *)
  ELSIF e2>0 THEN
    LInt.TenPower(n, e2);
    IF e1>0 THEN LInt.BPower(n, e1-1) ELSE LInt.BPower(n, e1+1) END;

  	max := MaxDigit(n);    (* remember the original digit so we can check for round-up *)	       
    LInt.AddDigit(n, B DIV 2); LInt.DivDigit(n, B, d) (* round *)    
  ELSE (* e1<=0, e2<=0 *)
    LInt.TenPower(n, e2); LInt.BPower(n, e1+1);

  	max := MaxDigit(n);    (* remember the original digit so we can check for round-up *)	        
    LInt.AddDigit(n, B DIV 2); LInt.DivDigit(n, B, d) (* round *)     
  END;

  

  (* check if the upper digit was changed by rounding up *)

  IF (max = 9) & (max # MaxDigit(n)) THEN

	 overflow := TRUE;

  END
END Scale;

PROCEDURE RealToFloat*(real: LONGREAL; sigFigs: INTEGER; VAR str: ARRAY OF CHAR);
 (*   
    The call RealToFloat(real,sigFigs,str) shall assign to `str' the
    possibly truncated string corresponding to the value of `real' in
    floating-point form.  A sign shall be included only for negative
    values.  One significant digit shall be included in the whole number
    part.  The signed exponent part shall be included only if the exponent
    value is not 0.  If the value of `sigFigs' is greater than 0, that
    number of significant digits shall be included, otherwise an
    implementation-defined number of significant digits shall be
    included.  The decimal point shall not be included if there are no
    significant digits in the fractional part.
    
    For example:
    
    value:     3923009     39.23009     0.0003923009
    sigFigs
      1        4E+6        4E+1         4E-4 
      2        3.9E+6      3.9E+1       3.9E-4
      5        3.9230E+6   3.9230E+1    3.9230E-4
 *)
VAR
  exp: INTEGER; in: LInt.LongInt; 

  lstr: ARRAY 64 OF CHAR;

  overflow: BOOLEAN;

  d: LONGINT;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:="";
  IF sigFigs<=0 THEN sigFigs:=RC.SigFigs END;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;
  IF real<ZERO THEN Str.Append("-", lstr); real:=-real END;   
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;   
  exp:=Low.exponent10(real); 
  
  (* round the number and extract exponent again *)
  Scale(real, in, sigFigs, exp, overflow);

  IF overflow THEN

  	 IF exp>=0 THEN INC(exp) ELSE DEC(exp) END;

  	 LInt.DivDigit(in, 10, d)    

  END;
  
  (* output number like x[.{x}][E+n[n]] *)                               
  AppendFraction(in, sigFigs, 1, lstr);
  IF exp#0 THEN AppendExponent(exp, lstr) END;
  
  (* possibly truncate the result *)
  COPY(lstr, str) 
END RealToFloat;
 
PROCEDURE RealToEng*(real: LONGREAL; sigFigs: INTEGER; VAR str: ARRAY OF CHAR);
 (* 
    Converts the value of real to floating-point string form, with 
    sigFigs significant figures, and copies the possibly truncated 
    result to str. The number is scaled with one to three digits in 
    the whole number part and with an exponent that is a multiple of 
    three.
     
    For example:
    
    value:     3923009     39.23009   0.0003923009
    sigFigs
      1        4E+6        40         400E-6 
      2        3.9E+6      39         390E-6
      5        3.9230E+6   39.230     392.30E-6     
  *)
VAR
  in: LInt.LongInt; exp, offset: INTEGER; 

  lstr: ARRAY 64 OF CHAR;

  d: LONGINT;

  overflow: BOOLEAN;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:="";
  IF sigFigs<=0 THEN sigFigs:=RC.SigFigs END;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;  
  IF real<ZERO THEN Str.Append("-", lstr); real:=-real END;
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;   
  exp:=Low.exponent10(real); 
  
  (* round the number and extract exponent again (ie. 9.9 => 10.0) *)
  Scale(real, in, sigFigs, exp, overflow);
  IF overflow THEN

  	 IF exp>=0 THEN INC(exp) ELSE DEC(exp) END;

  	 LInt.DivDigit(in, 10, d)    

  END;

    
  (* find the offset to make the exponent a multiple of three *)
  offset:=exp MOD 3;
  
  (* output number like x[x][x][.{x}][E+n[n]] *)                               
  AppendFraction(in, sigFigs, offset+1, lstr);
  exp:=exp-offset;
  IF exp#0 THEN AppendExponent(exp, lstr) END;
  
  (* possibly truncate the result *)
  COPY(lstr, str)       
END RealToEng;
 
PROCEDURE RealToFixed*(real: LONGREAL; place: INTEGER; VAR str: ARRAY OF CHAR);
 (* 
    The call RealToFixed(real,place,str) shall assign to `str' the
    possibly truncated string corresponding to the value of `real' in
    fixed-point form.  A sign shall be included only for negative values.
    At least one digit shall be included in the whole number part.  The
    value shall be rounded to the given value of `place' relative to the
    decimal point.  The decimal point shall be suppressed if `place' is
    less than 0.
    
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
  in: LInt.LongInt; exp, digs: INTEGER; 

  overflow, addDecPt: BOOLEAN; 

  lstr: ARRAY 256 OF CHAR;
BEGIN 
  (* set significant digits, extract sign & exponent *)
  lstr:=""; addDecPt:=place=0;
  
  (* check for illegal numbers *)
  IF Low.IsNaN(real) THEN COPY("NaN", str); RETURN END;  
  IF real<ZERO THEN Str.Append("-", lstr); real:=-real END;
  IF Low.IsInfinity(real) THEN Str.Append("Infinity", lstr); COPY(lstr, str); RETURN END;  
  exp:=Low.exponent10(real);  
  IF place<0 THEN digs:=place+exp+2 ELSE digs:=place+exp+1 END; 

   
  (* round the number and extract exponent again (ie. 9.9 => 10.0) *)
  Scale(real, in, digs, exp, overflow);

  IF overflow THEN

	 INC(digs); INC(exp);

	 addDecPt := place=0;

  END;
  
  (* output number like x[{x}][.{x}] *)
  IF exp<0 THEN
    IF place<0 THEN AppendFraction(in, 1, 1, lstr)
    ELSE AppendFraction(in, place+1, 1, lstr)
    END
  ELSE AppendFraction(in, digs, exp+1, lstr);
    RemoveLeadingZeros(lstr)
  END;
  
  (* special formatting *)
  IF addDecPt THEN Str.Append(".", lstr) END;
    
  (* possibly truncate the result *)
  COPY(lstr, str) 
END RealToFixed;
 
PROCEDURE RealToStr*(real: LONGREAL; VAR str: ARRAY OF CHAR);
 (* 
    If the sign and magnitude of `real' can be shown within the capacity
    of `str', the call RealToStr(real,str) shall behave as the call
    RealToFixed(real,place,str), with a value of `place' chosen to fill
    exactly the remainder of `str'.  Otherwise, the call shall behave as
    the call RealToFloat(real,sigFigs,str), with a value of `sigFigs' of
    at least one, but otherwise limited to the number of significant
    digits that can be included together with the sign and exponent part
    in `str'.
 *)
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

END oocLRealStr.




