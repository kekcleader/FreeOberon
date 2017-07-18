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
   $Id: Write.om,v 1.2 1994/07/05 12:52:27 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Write.om,v $
   Revision 1.2  1994/07/05  12:52:27  borchert
   Indent/IndentS added

   Revision 1.1  1994/02/23  07:47:04  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 7/89
   ----------------------------------------------------------------------------
*)

MODULE ulmWrite;

   IMPORT ASCII := ulmASCII, Print := ulmPrint, StreamDisciplines := ulmStreamDisciplines, Streams := ulmStreams, SYSTEM, SYS := ulmSYSTEM, Types := ulmTypes;
  (* 
      TYPE barr = ARRAY SIZE(Types.Int32) OF SYSTEM.BYTE; (* need this because voc does not convert implicitly Types.Int32 to ARRAY OF BYTE; -- noch *)
          pbarr = POINTER TO barr;
      TYPE lrarr = ARRAY SIZE(Types.Real64) OF SYSTEM.BYTE; (* need this because voc does not convert implicitly Types.Int32 to ARRAY OF BYTE; -- noch *)
          plrarr = POINTER TO barr;
	      
   PROCEDURE LongToByteArr ( l : Types.Int32; VAR bar : barr); (* noch *)
   VAR b : SYSTEM.BYTE;
       p : pbarr;
       i : Types.Int32;
   BEGIN
      p := SYSTEM.VAL(pbarr, SYSTEM.ADR(l));
      FOR i := 0 TO SIZE(Types.Int32) -1 DO
         b := p^[i]; bar[i] := b;
      END
   END LongToByteArr;

   PROCEDURE LRealToByteArr ( l : Types.Real64; VAR lar : lrarr); (* noch *)
   VAR b : SYSTEM.BYTE;
       p : plrarr;
       i : Types.Int32;
   BEGIN
      p := SYSTEM.VAL(plrarr, SYSTEM.ADR(l));
      FOR i := 0 TO SIZE(Types.Real64) -1 DO
         b := p^[i]; lar[i] := b;
      END
   END LRealToByteArr;


*)

   PROCEDURE IntS*(s: Streams.Stream; int: Types.Int32; width: Types.Int32);
   VAR b, b0 : SYS.bytearray; 
   BEGIN
      SYS.LongToByteArr(int, b);
      SYS.LongToByteArr(width, b0);
      Print.S2(s, "%*d", b0, b);
   END IntS;

   PROCEDURE RealS*(s: Streams.Stream; real: Types.Real64; width: Types.Int32);
   VAR b : SYS.bytearray; lr : SYS.longrealarray;
   BEGIN
      SYS.LRealToByteArr(real, lr);
      SYS.LongToByteArr(width,  b);
      Print.S2(s, "%*e", b, lr);
   END RealS;

   PROCEDURE CharS*(s: Streams.Stream; ch: CHAR);
   BEGIN
      IF ~Streams.WriteByte(s, ch) THEN END;
   END CharS;

   PROCEDURE ByteS*(s: Streams.Stream; byte: SYSTEM.BYTE);
   BEGIN
      IF ~Streams.WriteByte(s, byte) THEN END;
   END ByteS;

   PROCEDURE LineS*(s: Streams.Stream; str: ARRAY OF CHAR);
      VAR
	 count: Types.Int32;
	 nlOK: BOOLEAN;
	 cnt: Types.Int32;
	 lineterm: StreamDisciplines.LineTerminator;
	 len: Types.Int32; i: Types.Int32;
   BEGIN
      cnt := 0;
      WHILE (cnt < LEN(str)) & (str[cnt] # 0X) DO
	 INC(cnt);
      END;

      StreamDisciplines.GetLineTerm(s, lineterm);
      (* determine length of line terminator *)
      len := 1;
      WHILE (len < LEN(lineterm)) & (lineterm[len] # 0X) DO
	 INC(len);
      END;

      (* append line terminator to str (if possible) for
	 reasons of efficiency
      *)
      IF cnt+len < LEN(str) THEN
	 i := 0;
	 WHILE i < len DO
	    str[cnt] := lineterm[i]; INC(cnt); INC(i);
	 END;
	 nlOK := TRUE;
      ELSE
	 nlOK := FALSE;
      END;

      count := 0;
      IF cnt > 0 THEN
	 IF ~Streams.WritePart(s, str, 0, cnt) THEN
	    RETURN
	 END;
	 count := s.count;
      END;
      IF ~nlOK THEN
	 IF ~Streams.WritePart(s, lineterm, 0, len) THEN END;
	 INC(count, s.count);
      END;
      s.count := count;
   END LineS;

   PROCEDURE LnS*(s: Streams.Stream);
      VAR
	 lineterm: StreamDisciplines.LineTerminator;
	 len: Types.Int32;
   BEGIN
      StreamDisciplines.GetLineTerm(s, lineterm);
      IF lineterm[1] = 0X THEN
	 IF ~Streams.WriteByte(s, lineterm[0]) THEN END;
      ELSE
	 len := 1;
	 WHILE (len < LEN(lineterm)) & (lineterm[len] # 0X) DO
	    INC(len);
	 END;
	 IF ~Streams.WritePart(s, lineterm, 0, len) THEN END;
      END;
   END LnS;

   PROCEDURE StringS*(s: Streams.Stream; str: ARRAY OF CHAR);
      VAR
	 cnt: Types.Int32;
   BEGIN
      cnt := 0;
      WHILE (cnt < LEN(str)) & (str[cnt] # 0X) DO
	 INC(cnt);
      END;
      IF (cnt > 0) & ~Streams.WritePart(s, str, 0, cnt) THEN END;
   END StringS;

   PROCEDURE IndentS*(s: Streams.Stream);
      VAR
	 indentwidth: Types.Int32;
   BEGIN
      StreamDisciplines.GetIndentationWidth(s, indentwidth);
      WHILE (indentwidth > 0) & Streams.WriteByte(s, " ") DO
	 DEC(indentwidth);
      END;
   END IndentS;



   (* procedures writing to Streams.stdout *)

   PROCEDURE Int*(int: Types.Int32; width: Types.Int32);
   BEGIN
      IntS(Streams.stdout, int, width);
   END Int;

   PROCEDURE Real*(real: Types.Real64; width: Types.Int32);
      (* write real in exponential format *)
   BEGIN
      RealS(Streams.stdout, real, width);
   END Real;

   PROCEDURE Char*(ch: CHAR);
   BEGIN
      CharS(Streams.stdout, ch);
   END Char;

   PROCEDURE Byte*(byte: SYSTEM.BYTE);
   BEGIN
      ByteS(Streams.stdout, byte);
   END Byte;

   PROCEDURE Line*(s: ARRAY OF CHAR);
   BEGIN
      LineS(Streams.stdout, s);
   END Line;

   PROCEDURE Ln*;
   BEGIN
      LnS(Streams.stdout);
   END Ln;

   PROCEDURE String*(s: ARRAY OF CHAR);
   BEGIN
      StringS(Streams.stdout, s);
   END String;

   PROCEDURE Indent*;
   BEGIN
      IndentS(Streams.stdout);
   END Indent;

END ulmWrite.
