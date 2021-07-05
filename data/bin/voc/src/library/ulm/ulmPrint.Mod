(* Ulm's Oberon Library
   Copyright (C) 1989-1994 by University of Ulm, SAI, D-89069 Ulm, Germany
   ----------------------------------------------------------------------------
   Ulm's Oberon Library is free software; you can redistribute it
   and/or modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either version
   2 of the License, or (at your option) any later version.

   Ulm's Oberon Library is distributed in the hope that it will be
   useful, but WITHOUT ANY WARRANTY; without even the implied warranty
   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   ----------------------------------------------------------------------------
   E-mail contact: oberon@mathematik.uni-ulm.de
   ----------------------------------------------------------------------------
   $Id: Print.om,v 1.3 2004/05/21 12:08:43 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Print.om,v $
   Revision 1.3  2004/05/21 12:08:43  borchert
   bug fix: NaNs and other invalid floating point numbers weren't
            checked for

   Revision 1.2  1996/09/18 07:47:41  borchert
   support of SYSTEM.INT16 added

   Revision 1.1  1994/02/23  07:46:28  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 6/89
   ----------------------------------------------------------------------------
*)

MODULE ulmPrint;

   (* formatted printing;
      Print.F[0-9] prints to Streams.stdout

      formats are close to those of printf(3)
   *)

   IMPORT Events := ulmEvents, IEEE := ulmIEEE, Priorities := ulmPriorities, Reals := ulmReals, RelatedEvents := ulmRelatedEvents, StreamDisciplines := ulmStreamDisciplines,
      Streams := ulmStreams, SYS := SYSTEM, Types := ulmTypes;

   CONST
      tooManyArgs* = 0; (* too many arguments given *)
      tooFewArgs* = 1; (* too few arguments given *)
      badFormat* = 2; (* syntax error in format string *)
      badArgumentSize* = 3; (* bad size of argument *)
      errors* = 4;
   TYPE
      FormatString* = ARRAY 128 OF CHAR;
      ErrorCode* = Types.Int8;
      ErrorEvent* = POINTER TO ErrorEventRec;
      ErrorEventRec* =
	 RECORD
	    (Events.EventRec)
	    errorcode*: ErrorCode;
	    format*: FormatString;
	    errpos*: Types.Int32;
	    nargs*: Types.Int32;
	 END;
   VAR
      error*: Events.EventType;
      errormsg*: ARRAY errors OF Events.Message;

   (* === private part ============================================= *)

   PROCEDURE InitErrorHandling;
   BEGIN
      Events.Define(error); Events.SetPriority(error, Priorities.liberrors);
      errormsg[tooManyArgs] := "too many arguments given";
      errormsg[tooFewArgs] := "too few arguments given";
      errormsg[badFormat] := "syntax error in format string";
      errormsg[badArgumentSize] :=
	 "size of argument doesn't conform to the corresponding format element";
   END InitErrorHandling;

   PROCEDURE Out(out: Streams.Stream; VAR fmt: ARRAY OF CHAR; nargs: Types.Int32;
		 VAR p1,p2,p3,p4,p5,p6,p7,p8,p9: ARRAY OF SYS.BYTE;
		 errors: RelatedEvents.Object);
      CONST
	 maxargs = 9;	(* maximal number of arguments *)
	 maxargsize = SIZE(Types.Real64); (* maximal arg size (except strings) *)
	 fmtcmd = "%";
	 escape = "\";
      VAR
	 arglen: ARRAY maxargs OF Types.Int32;
	 nextarg: Types.Int32;
	 fmtindex: Types.Int32;
	 fmtchar: CHAR;
	 hexcharval: Types.Int32;

      PROCEDURE Error(errorcode: ErrorCode);
	 VAR
	    event: ErrorEvent;
      BEGIN
	 NEW(event);
	 event.type := error;
	 event.message := errormsg[errorcode];
	 event.errorcode := errorcode;
	 COPY(fmt, event.format);
	 event.errpos := fmtindex;
	 event.nargs := nargs;
	 RelatedEvents.Raise(errors, event);
      END Error;

      PROCEDURE Next() : BOOLEAN;
      BEGIN
	 IF fmtindex < LEN(fmt) THEN
	    fmtchar := fmt[fmtindex]; INC(fmtindex);
	    IF fmtchar = 0X THEN
	       fmtindex := LEN(fmt);
	       RETURN FALSE
	    ELSE
	       RETURN TRUE
	    END;
	 ELSE
	    RETURN FALSE
	 END;
      END Next;

      PROCEDURE Unget;
      BEGIN
	 IF (fmtindex > 0) & (fmtindex < LEN(fmt)) THEN
	    DEC(fmtindex); fmtchar := fmt[fmtindex];
	 ELSE
	    fmtchar := 0X;
	 END;
      END Unget;

      PROCEDURE Write(byte: SYS.BYTE);
      BEGIN
	 IF Streams.WriteByte(out, byte) THEN
	    INC(out.count);
	 END;
      END Write;

      PROCEDURE WriteLn;
	 VAR
	    lineterm: StreamDisciplines.LineTerminator;
	    i: Types.Int32;
      BEGIN
	 StreamDisciplines.GetLineTerm(out, lineterm);
	 Write(lineterm[0]);
	 i := 1;
	 WHILE (i < LEN(lineterm)) & (lineterm[i] # 0X) DO
	    Write(lineterm[i]); INC(i);
	 END;
      END WriteLn;

      PROCEDURE Int(VAR int: Types.Int32; base: Types.Int32) : BOOLEAN;

	 PROCEDURE ValidDigit(ch: CHAR) : BOOLEAN;
	 BEGIN
	    RETURN (ch >= "0") & (ch <= "9") OR
		   (base = 16) & (CAP(ch) >= "A") & (CAP(ch) <= "F")
	 END ValidDigit;

      BEGIN
	 int := 0;
	 REPEAT
	    int := int * base;
	    IF (fmtchar >= "0") & (fmtchar <= "9") THEN
	       INC(int, ORD(fmtchar) - ORD("0"));
	    ELSIF (base = 16) &
		  (CAP(fmtchar) >= "A") & (CAP(fmtchar) <= "F") THEN
	       INC(int, 10 + ORD(CAP(fmtchar)) - ORD("A"));
	    ELSE
	       RETURN FALSE
	    END;
	 UNTIL ~Next() OR ~ValidDigit(fmtchar);
	 RETURN TRUE
      END Int;

      PROCEDURE SetSize;
	 VAR
	    index: Types.Int32;
      BEGIN
	 index := 0;
	 WHILE index < nargs DO
	    CASE index OF
	    | 0: arglen[index] := LEN(p1);
	    | 1: arglen[index] := LEN(p2);
	    | 2: arglen[index] := LEN(p3);
	    | 3: arglen[index] := LEN(p4);
	    | 4: arglen[index] := LEN(p5);
	    | 5: arglen[index] := LEN(p6);
	    | 6: arglen[index] := LEN(p7);
	    | 7: arglen[index] := LEN(p8);
	    | 8: arglen[index] := LEN(p9);
		ELSE
	    END;
	    INC(index);
	 END;
      END SetSize;

      PROCEDURE Access(par: Types.Int32; at: Types.Int32) : SYS.BYTE;
      BEGIN
	 CASE par OF
	 | 0: RETURN p1[at]
	 | 1: RETURN p2[at]
	 | 2: RETURN p3[at]
	 | 3: RETURN p4[at]
	 | 4: RETURN p5[at]
	 | 5: RETURN p6[at]
	 | 6: RETURN p7[at]
	 | 7: RETURN p8[at]
	 | 8: RETURN p9[at]
	 ELSE
	 END;
      END Access;

      PROCEDURE Convert(from: Types.Int32; VAR to: ARRAY OF SYS.BYTE);
	 VAR i: Types.Int32;
      BEGIN
	 i := 0;
	 WHILE i < arglen[from] DO
	    to[i] := Access(from, i); INC(i);
	 END;
      END Convert;

      PROCEDURE GetInt(index: Types.Int32; VAR long: Types.Int32) : BOOLEAN;
	 (* access index-th parameter (counted from 0);
	    fails if arglen[index] > SYS.SIZE(Types.Int32)
	 *)
	 VAR
	    short: Types.Int8;
	    int16: SYS.INT16;
	    int: Types.Int32;
	 
      BEGIN
	 IF arglen[index] = SIZE(Types.Int8) THEN
	    Convert(index, short); long := short;
	 ELSIF arglen[index] = SIZE(SYS.INT16) THEN
	    Convert(index, int16); long := int16;
	 ELSIF arglen[index] = SIZE(Types.Int32) THEN
	    Convert(index, int); long := int;
	 ELSIF arglen[index] = SIZE(Types.Int32) THEN
	    Convert(index, long);
	 ELSE
	    Error(badArgumentSize);
	    RETURN FALSE
	 END;
	 RETURN TRUE
      END GetInt;

      PROCEDURE Format() : BOOLEAN;

	 VAR
	    fillch: CHAR;		(* filling character *)
	    insert: BOOLEAN;		(* insert between sign and 1st digit *)
	    sign: BOOLEAN;		(* sign even positive values *)
	    leftaligned: BOOLEAN;	(* output left aligned *)
	    width, scale: Types.Int32;

	 PROCEDURE NextArg(VAR index: Types.Int32) : BOOLEAN;
	 BEGIN
	    IF nextarg < nargs THEN
	       index := nextarg; INC(nextarg); RETURN TRUE
	    ELSE
	       RETURN FALSE
	    END;
	 END NextArg;

	 PROCEDURE Flags() : BOOLEAN;
	 BEGIN
	    fillch := " "; insert := FALSE; sign := FALSE;
	    leftaligned := FALSE;
	    REPEAT
	       CASE fmtchar OF
	       | "+":   sign := TRUE;
	       | "0":   fillch := "0"; insert := TRUE;
	       | "-":   leftaligned := TRUE;
	       | "^":   insert := TRUE;
	       | "\":   IF ~Next() THEN RETURN FALSE END; fillch := fmtchar;
	       ELSE
		  RETURN TRUE
	       END;
	    UNTIL ~Next();
	    Error(badFormat);
	    RETURN FALSE (* unexpected end *)
	 END Flags;

	 PROCEDURE FetchInt(VAR int: Types.Int32) : BOOLEAN;
	    VAR
	       index: Types.Int32;
	 BEGIN
	    RETURN (fmtchar = "*") & Next() &
		   NextArg(index) & GetInt(index, int) OR
		   Int(int, 10) & (int >= 0)
	 END FetchInt;

	 PROCEDURE Width() : BOOLEAN;
	 BEGIN
	    IF (fmtchar >= "0") & (fmtchar <= "9") OR (fmtchar = "*") THEN
	       IF FetchInt(width) THEN
		  RETURN TRUE
	       END;
	       Error(badFormat); RETURN FALSE
	    ELSE
	       width := 0;
	       RETURN TRUE
	    END;
	 END Width;

	 PROCEDURE Scale() : BOOLEAN;
	 BEGIN
	    IF fmtchar = "." THEN
	       IF Next() & FetchInt(scale) THEN
		  RETURN TRUE
	       ELSE
		  Error(badFormat); RETURN FALSE
	       END;
	    ELSE
	       scale := -1; RETURN TRUE
	    END;
	 END Scale;

	 PROCEDURE Conversion() : BOOLEAN;

	    PROCEDURE Fill(cnt: Types.Int32);
	       (* cnt: space used by normal output *)
	       VAR i: Types.Int32;
	    BEGIN
	       IF cnt < width THEN
		  i := width - cnt;
		  WHILE i > 0 DO
		     Write(fillch);
		     DEC(i);
		  END;
	       END;
	    END Fill;

	    PROCEDURE FillLeft(cnt: Types.Int32);
	    BEGIN
	       IF ~leftaligned THEN
		  Fill(cnt);
	       END;
	    END FillLeft;

	    PROCEDURE FillRight(cnt: Types.Int32);
	    BEGIN
	       IF leftaligned THEN
		  Fill(cnt);
	       END;
	    END FillRight;

	    PROCEDURE WriteBool(true, false: ARRAY OF CHAR) : BOOLEAN;
	       VAR index: Types.Int32; val: Types.Int32;

	       PROCEDURE WriteString(VAR s: ARRAY OF CHAR);
		  VAR i, len: Types.Int32;
	       BEGIN
		  len := 0;
		  WHILE (len < LEN(s)) & (s[len] # 0X) DO
		     INC(len);
		  END;
		  FillLeft(len);
		  i := 0;
		  WHILE i < len DO
		     Write(s[i]); INC(i);
		  END;
		  FillRight(len);
	       END WriteString;

	    BEGIN
	       IF NextArg(index) & GetInt(index, val) THEN
		  IF val = 0 THEN
		     WriteString(false); RETURN TRUE
		  ELSIF val = 1 THEN
		     WriteString(true); RETURN TRUE
		  END;
	       END;
	       RETURN FALSE
	    END WriteBool;

	    PROCEDURE WriteChar() : BOOLEAN;
	       VAR
		  val: Types.Int32;
		  index: Types.Int32;
	    BEGIN
	       IF NextArg(index) & GetInt(index, val) &
		  (val >= 0) & (val <= ORD(MAX(CHAR))) THEN
		  FillLeft(1);
		  Write(CHR(val));
		  FillRight(1);
		  RETURN TRUE
	       END;
	       RETURN FALSE
	    END WriteChar;

	    PROCEDURE WriteInt(base: Types.Int32) : BOOLEAN;
	       VAR
		  index: Types.Int32;
		  val: Types.Int32;
		  neg: BOOLEAN; (* set by Convert *)
		  buf: ARRAY 12 OF CHAR; (* filled by Convert *)
		  i: Types.Int32;
		  len: Types.Int32; (* space needed for val *)
		  signcnt: Types.Int32; (* =1 if sign printed; else 0 *)
		  signch: CHAR;

	       PROCEDURE Convert;
		  VAR
		     index: Types.Int32;
		     digit: Types.Int32;
	       BEGIN
		  neg := val < 0;
		  index := 0;
		  REPEAT
		     digit := val MOD base;
		     val := val DIV base;
		     IF neg & (digit > 0) THEN
			digit := base - digit;
			INC(val);
		     END;
		     IF digit < 10 THEN
			buf[index] := CHR(ORD("0") + digit);
		     ELSE
			buf[index] := CHR(ORD("A") + digit - 10);
		     END;
		     INC(index);
		  UNTIL val = 0;
		  len := index;
	       END Convert;

	    BEGIN (* WriteInt *)
	       IF NextArg(index) & GetInt(index, val) THEN
		  Convert;
		  IF sign OR neg THEN
		     signcnt := 1;
		     IF neg THEN
			signch := "-";
		     ELSE
			signch := "+";
		     END;
		  ELSE
		     signcnt := 0;
		  END;
		  IF insert & (signcnt = 1) THEN
		     Write(signch);
		  END;
		  FillLeft(len+signcnt);
		  IF ~insert & (signcnt = 1) THEN
		     Write(signch);
		  END;
		  i := len;
		  WHILE i > 0 DO
		     DEC(i); Write(buf[i]);
		  END;
		  FillRight(len+signcnt);
		  RETURN TRUE
	       END;
	       RETURN FALSE
	    END WriteInt;

	    PROCEDURE WriteReal(format: CHAR) : BOOLEAN;
	       (* format either "f", "e", or "g" *)
	       CONST
		  defaultscale = 6;
	       VAR
		  index: Types.Int32;
		  lr: Types.Real64;
		  r: Types.Real32;
		  shortint: Types.Int8; int: Types.Int32; longint: Types.Int32;
		  int16: SYS.INT16;
		  long: BOOLEAN;
		  exponent: Types.Int32;
		  mantissa: Types.Real64;
		  digits: ARRAY Reals.maxlongdignum OF CHAR;
		  neg: BOOLEAN;
		  ndigits: Types.Int32;
		  decpt: Types.Int32;

	       PROCEDURE Print(decpt: Types.Int32; withexp: BOOLEAN; exp: Types.Int32);
		  (* decpt: position of decimal point
			    = 0: just before the digits
			    > 0: after decpt digits
			    < 0: ABS(decpt) zeroes before digits needed
		  *)
		  VAR
		     needed: Types.Int32; (* space needed *)
		     index: Types.Int32;
		     count: Types.Int32;

		  PROCEDURE WriteExp(exp: Types.Int32);
		     CONST
			base = 10;
		     VAR
			power: Types.Int32;
			digit: Types.Int32;
		  BEGIN
		     IF long THEN
			Write("D");
		     ELSE
			Write("E");
		     END;
		     IF exp < 0 THEN
			Write("-"); exp := - exp;
		     ELSE
			Write("+");
		     END;
		     IF long THEN
			power := 1000;
		     ELSE
			power := 100;
		     END;
		     WHILE power > 0 DO
			digit := (exp DIV power) MOD base;
			Write(CHR(digit+ORD("0")));
			power := power DIV base;
		     END;
		  END WriteExp;

	       BEGIN (* Print *)
		  (* leading digits *)
		  IF decpt > 0 THEN
		     needed := decpt;
		  ELSE
		     needed := 1;
		  END;
		  IF neg OR sign THEN
		     INC(needed);
		  END;
		  IF withexp OR (scale # 0) THEN
		     INC(needed); (* decimal point *)
		  END;
		  IF withexp THEN
		     INC(needed, 2); (* E[+-] *)
		     IF long THEN
			INC(needed, 4);
		     ELSE
			INC(needed, 3);
		     END;
		  END;
		  INC(needed, scale);

		  FillLeft(needed);
		  IF neg THEN
		     Write("-");
		  ELSIF sign THEN
		     Write("+");
		  END;
		  IF decpt <= 0 THEN
		     Write("0");
		  ELSE
		     index := 0;
		     WHILE index < decpt DO
			IF index < ndigits THEN
			   Write(digits[index]);
			ELSE
			   Write("0");
			END;
			INC(index);
		     END;
		  END;
		  IF withexp OR (scale > 0) THEN
		     Write(".");
		  END;
		  IF scale > 0 THEN
		     count := scale;
		     index := decpt;
		     WHILE (index < 0) & (count > 0) DO
			Write("0"); INC(index); DEC(count);
		     END;
		     WHILE (index < ndigits) & (count > 0) DO
			Write(digits[index]); INC(index); DEC(count);
		     END;
		     WHILE count > 0 DO
			Write("0"); DEC(count);
		     END;
		  END;
		  IF withexp THEN
		     WriteExp(exp);
		  END;
		  FillRight(needed);
	       END Print;

	    BEGIN (* WriteReal *)
	       IF NextArg(index) THEN
		  IF arglen[index] = SIZE(Types.Real64) THEN
		     long := TRUE;
		     Convert(index, lr);
		  ELSIF arglen[index] = SIZE(Types.Real32) THEN
		     long := FALSE;
		     Convert(index, r);
		     lr := r;
		  ELSIF arglen[index] = SIZE(Types.Int32) THEN
		     long := FALSE;
		     Convert(index, longint);
		     lr := longint;
		  ELSIF arglen[index] = SIZE(Types.Int32) THEN
		     long := FALSE;
		     Convert(index, int);
		     lr := int;
		  ELSIF arglen[index] = SIZE(SYS.INT16) THEN
		     long := FALSE;
		     Convert(index, int16);
		     lr := int16;
		  ELSIF arglen[index] = SIZE(Types.Int8) THEN
		     long := FALSE;
		     Convert(index, shortint);
		     lr := shortint;
		  ELSE
		     Error(badArgumentSize); RETURN FALSE
		  END;
		  IF scale = -1 THEN
		     scale := defaultscale;
		  END;
		  (* check for NaNs and other invalid numbers *)
		  IF ~IEEE.Valid(lr) THEN
		     IF IEEE.NotANumber(lr) THEN
			Write("N"); Write("a"); Write("N");
			RETURN TRUE
		     ELSE
			IF lr < 0 THEN
			   Write("-");
			ELSE
			   Write("+");
			END;
			Write("i"); Write("n"); Write("f");
		     END;
		     RETURN TRUE
		  END;
		  (* real value in `lr' *)
		  Reals.ExpAndMan(lr, long, 10, exponent, mantissa);
		  CASE format OF
		  | "e":   ndigits := SHORT(scale)+1;
		  | "f":   ndigits := SHORT(scale)+exponent+1;
			   IF ndigits <= 0 THEN
			      ndigits := 1;
			   END;
		  | "g":   ndigits := SHORT(scale);
		  ELSE
		  END;
		  Reals.Digits(mantissa, 10, digits, neg,
			       (* force = *) format # "g", ndigits);
		  decpt := 1;
		  CASE format OF
		  | "e":   Print(decpt, (* withexp = *) TRUE, exponent);
		  | "f":   INC(decpt, exponent);
		           Print(decpt, (* withexp = *) FALSE, 0);
		  | "g":   IF (exponent < -4) OR (exponent > scale) THEN
			      scale := ndigits-1;
			      Print(decpt, (* withexp = *) TRUE, exponent);
			   ELSE
			      INC(decpt, exponent);
			      scale := ndigits-1;
			      DEC(scale, exponent);
			      IF scale < 0 THEN
				 scale := 0;
			      END;
			      Print(decpt, (* withexp = *) FALSE, 0);
			   END;
		  ELSE
		  END;
		  RETURN TRUE
	       ELSE
		  RETURN FALSE
	       END;
	    END WriteReal;

	    PROCEDURE WriteString() : BOOLEAN;
	       VAR
		  index: Types.Int32;
		  i: Types.Int32;
		  byte: SYS.BYTE;
		  len: Types.Int32;
	    BEGIN
	       IF NextArg(index) THEN
		  len := 0;
		  WHILE (len < arglen[index]) &
			((scale = -1) OR (len < scale)) &
		        ((*CHR*)SYS.VAL(CHAR, Access(index, len)) # 0X) DO
		     INC(len);
		  END;
		  FillLeft(len);
		  i := 0;
		  WHILE i < len DO
		     byte := Access(index, i);
		     Write(byte);
		     INC(i);
		  END;
		  FillRight(len);
		  RETURN TRUE
	       END;
	       RETURN FALSE
	    END WriteString;

	 BEGIN (* Conversion *)
	    CASE fmtchar OF
	    | "b": RETURN WriteBool("TRUE", "FALSE")
	    | "c": RETURN WriteChar()
	    | "d": RETURN WriteInt(10)
	    | "e",
	      "f",
	      "g": RETURN WriteReal(fmtchar)
	    | "j": RETURN WriteBool("ja", "nein")
	    | "o": RETURN WriteInt(8)
	    | "s": RETURN WriteString()
	    | "x": RETURN WriteInt(16)
	    | "y": RETURN WriteBool("yes", "no")
	    ELSE
	       Error(badFormat); RETURN FALSE
	    END;
	 END Conversion;

      BEGIN
	 IF ~Next() THEN RETURN FALSE END;
	 IF fmtchar = fmtcmd THEN Write(fmtcmd); RETURN TRUE END;
	 RETURN Flags() & Width() & Scale() & Conversion()
      END Format;
	 
   BEGIN
      out.count := 0; out.error := FALSE;
      SetSize;
      nextarg := 0;
      fmtindex := 0;
      WHILE Next() DO
	 IF fmtchar = fmtcmd THEN
	    IF ~Format() THEN
	       RETURN
	    END;
	 ELSIF (fmtchar = "\") & Next() THEN
	    CASE fmtchar OF
	    | "0".."9", "A".."F":
		   IF ~Int(hexcharval, 16) THEN
		      (* Error(s, BadFormat); *) RETURN
		   END;
		   Unget;
		   Write(CHR(hexcharval));
	    | "b": Write(08X);  (* back space *)
	    | "e": Write(1BX);  (* escape *)
	    | "f": Write(0CX);  (* form feed *)
	    | "n": WriteLn;
	    | "q": Write("'");
	    | "Q": Write(22X);  (* double quote: " *)
	    | "r": Write(0DX);  (* carriage return *)
	    | "t": Write(09X);  (* horizontal tab *)
	    | "&": Write(07X);  (* bell *)
	    ELSE
	       Write(fmtchar);
	    END;
	 ELSE
	    Write(fmtchar);
	 END;
      END;
      IF nextarg < nargs THEN
	 Error(tooManyArgs);
      ELSIF nextarg > nargs THEN
	 Error(tooFewArgs);
      END;
   END Out;

   (* === public part ============================================== *)

   PROCEDURE F*(fmt: ARRAY OF CHAR);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 0,  x,x,x,x,x,x,x,x,x, NIL);
   END F;

   PROCEDURE F1*(fmt: ARRAY OF CHAR; p1: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 1, p1, x,x,x,x,x,x,x,x, NIL);
   END F1;

   PROCEDURE F2*(fmt: ARRAY OF CHAR; p1, p2: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 2, p1,p2, x,x,x,x,x,x,x, NIL);
   END F2;

   PROCEDURE F3*(fmt: ARRAY OF CHAR; p1, p2, p3: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 3, p1,p2,p3, x,x,x,x,x,x, NIL);
   END F3;

   PROCEDURE F4*(fmt: ARRAY OF CHAR; p1, p2, p3, p4: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 4, p1,p2,p3,p4, x,x,x,x,x, NIL);
   END F4;

   PROCEDURE F5*(fmt: ARRAY OF CHAR; p1, p2, p3, p4, p5: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 5, p1,p2,p3,p4,p5, x,x,x,x, NIL);
   END F5;

   PROCEDURE F6*(fmt: ARRAY OF CHAR; p1, p2, p3, p4, p5, p6: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 6, p1,p2,p3,p4,p5,p6, x,x,x, NIL);
   END F6;

   PROCEDURE F7*(fmt: ARRAY OF CHAR; p1, p2, p3, p4, p5, p6, p7: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 7, p1,p2,p3,p4,p5,p6,p7, x,x, NIL);
   END F7;

   PROCEDURE F8*(fmt: ARRAY OF CHAR;
		p1, p2, p3, p4, p5, p6, p7, p8: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(Streams.stdout, fmt, 8, p1,p2,p3,p4,p5,p6,p7,p8, x, NIL);
   END F8;

   PROCEDURE F9*(fmt: ARRAY OF CHAR;
		p1, p2, p3, p4, p5, p6, p7, p8, p9: ARRAY OF SYS.BYTE);
   BEGIN
      Out(Streams.stdout, fmt, 9, p1,p2,p3,p4,p5,p6,p7,p8,p9, NIL);
   END F9;


   PROCEDURE S*(out: Streams.Stream; fmt: ARRAY OF CHAR);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 0, x,x,x,x,x,x,x,x,x, NIL);
   END S;

   PROCEDURE S1*(out: Streams.Stream; fmt: ARRAY OF CHAR; p1: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 1, p1, x,x,x,x,x,x,x,x, NIL);
   END S1;

   PROCEDURE S2*(out: Streams.Stream; fmt: ARRAY OF CHAR; p1, p2: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 2, p1,p2, x,x,x,x,x,x,x, NIL);
   END S2;

   PROCEDURE S3*(out: Streams.Stream; fmt: ARRAY OF CHAR; p1, p2, p3: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 3, p1,p2,p3, x,x,x,x,x,x, NIL);
   END S3;

   PROCEDURE S4*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 4, p1,p2,p3,p4, x,x,x,x,x, NIL);
   END S4;

   PROCEDURE S5*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 5, p1,p2,p3,p4,p5, x,x,x,x, NIL);
   END S5;

   PROCEDURE S6*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 6, p1,p2,p3,p4,p5,p6, x,x,x, NIL);
   END S6;

   PROCEDURE S7*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 7, p1,p2,p3,p4,p5,p6,p7, x,x, NIL);
   END S7;

   PROCEDURE S8*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7, p8: ARRAY OF SYS.BYTE);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 8, p1,p2,p3,p4,p5,p6,p7,p8, x, NIL);
   END S8;

   PROCEDURE S9*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7, p8, p9: ARRAY OF SYS.BYTE);
   BEGIN
      Out(out, fmt, 9, p1,p2,p3,p4,p5,p6,p7,p8,p9, NIL);
   END S9;


   PROCEDURE SE*(out: Streams.Stream; fmt: ARRAY OF CHAR;
	        errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 0, x,x,x,x,x,x,x,x,x, NIL);
   END SE;

   PROCEDURE SE1*(out: Streams.Stream; fmt: ARRAY OF CHAR; p1: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 1, p1, x,x,x,x,x,x,x,x, errors);
   END SE1;

   PROCEDURE SE2*(out: Streams.Stream; fmt: ARRAY OF CHAR; p1, p2: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 2, p1,p2, x,x,x,x,x,x,x, errors);
   END SE2;

   PROCEDURE SE3*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 3, p1,p2,p3, x,x,x,x,x,x, errors);
   END SE3;

   PROCEDURE SE4*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 4, p1,p2,p3,p4, x,x,x,x,x, errors);
   END SE4;

   PROCEDURE SE5*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 5, p1,p2,p3,p4,p5, x,x,x,x, errors);
   END SE5;

   PROCEDURE SE6*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 6, p1,p2,p3,p4,p5,p6, x,x,x, errors);
   END SE6;

   PROCEDURE SE7*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 7, p1,p2,p3,p4,p5,p6,p7, x,x, errors);
   END SE7;

   PROCEDURE SE8*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7, p8: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
      VAR x: Types.Int32;
   BEGIN
      Out(out, fmt, 8, p1,p2,p3,p4,p5,p6,p7,p8, x, errors);
   END SE8;

   PROCEDURE SE9*(out: Streams.Stream; fmt: ARRAY OF CHAR;
		 p1, p2, p3, p4, p5, p6, p7, p8, p9: ARRAY OF SYS.BYTE;
                 errors: RelatedEvents.Object);
   BEGIN
      Out(out, fmt, 9, p1,p2,p3,p4,p5,p6,p7,p8,p9, errors);
   END SE9;

BEGIN
   InitErrorHandling;
END ulmPrint.
