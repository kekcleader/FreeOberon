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
   $Id: Strings.om,v 1.3 1995/01/04 16:44:31 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Strings.om,v $
   Revision 1.3  1995/01/04  16:44:31  borchert
   some fixes because streams are now an extension of Services.Object

   Revision 1.2  1994/07/05  08:27:25  borchert
   Flush operation added to stream interface to support Streams.Touch

   Revision 1.1  1994/02/22  20:10:56  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/89
   ----------------------------------------------------------------------------
*)

MODULE ulmStrings;

   IMPORT Events := ulmEvents, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Services := ulmServices, Streams := ulmStreams,
      SYS := SYSTEM, Types := ulmTypes;

   TYPE
      Address = Types.Address;
      Count = Types.Count;
      Byte = Types.Byte;
      Stream* = POINTER TO StreamRec;
      StreamRec* =
	 RECORD
	    (Streams.StreamRec)
	    (* private part *)
	    addr: Address;	(* SYS.ADR(string[0]) *)
	    len: Count;		(* LEN(string) *)
	    termindex: Count;	(* position of 0X *)
	    pos: Count;		(* 0 <= pos <= termindex < len *)
	 END;
   VAR
      type: Services.Type; (* Strings.Stream *)

   CONST
      (* error codes *)
      endOfStringReached* = 0;	(* write failure: end of string reached *)
      outOfRange* = 1;           (* seek failure: position out of range *)
      badParameter* = 2;		(* illegal parameter value (eg whence) *)
      posOutside* = 3;		(* trunc failure: position beyond trunc pos *)
      errorcodes* = 4;
   TYPE
      ErrorCode* = Types.Int8;
      Event* = POINTER TO EventRec;
      EventRec* =
	 RECORD
	    (Events.EventRec)
	    stream*: Streams.Stream;
	    errorcode*: ErrorCode;
	 END;
   VAR
      errormsg*: ARRAY errorcodes OF Events.Message;
      error*: Events.EventType;
	 (* raised on errorneous stream operations;
	    ignored by default
	 *)
   VAR
      if: Streams.Interface;
      caps: Streams.CapabilitySet;

   (* 1st parameter: destination
      2nd parameter: source

      resulting strings are guaranteed to be 0X-terminated
   *)

   (* ======= string to stream operations =========================== *)

   PROCEDURE WritePart*(stream: Streams.Stream; string: ARRAY OF CHAR;
		       sourceIndex: Types.Int32);
      (* seek to position 0 of `stream' and
	 copy string[sourceIndex..] to it;
	 the file pointer of `stream' is left on position 0
      *)
      VAR
	 index: Types.Int32;
   BEGIN
      IF ~Streams.Seek(stream, 0, Streams.fromStart) OR
	 ~Streams.Trunc(stream, 0) THEN
	 RETURN
      END;
      index := sourceIndex;
      WHILE (index < LEN(string)) & (string[index] # 0X) DO
	 INC(index);
      END;
      IF ~Streams.WritePart(stream, string, sourceIndex, index-sourceIndex) OR
	 ~Streams.Seek(stream, 0, Streams.fromStart) THEN
      END;
   END WritePart;

   PROCEDURE Write*(stream: Streams.Stream; string: ARRAY OF CHAR);
      (* seek to position 0 of `stream' and
	 copy 0X-terminated string to `stream'
      *)
   BEGIN
      WritePart(stream, string, 0);
   END Write;

   (* ======= stream to string operations =========================== *)

   PROCEDURE ReadPart*(VAR string: ARRAY OF CHAR; destIndex: Types.Int32;
		      stream: Streams.Stream);
      (* like `Read' but fill string[destIndex..] *)
      VAR
	 len: Types.Int32;
	 endIndex: Types.Int32;
   BEGIN
      len := LEN(string);
      IF Streams.Seek(stream, 0, Streams.fromStart) & (destIndex < len) THEN
	 IF ~Streams.ReadPart(stream, string, destIndex, len-destIndex) THEN
	    (* ReadPart fails if less than len-destIndex can be read *)
	 END;
	 endIndex := destIndex + stream.count;
	 IF endIndex >= len THEN
	    endIndex := len-1;
	 END;
	 IF ~Streams.Seek(stream, 0, Streams.fromStart) THEN
	 END;
      ELSE
	 endIndex := 0;
      END;
      string[endIndex] := 0X;
   END ReadPart;

   PROCEDURE Read*(VAR string: ARRAY OF CHAR; stream: Streams.Stream);
      (* copy contents of `stream' from position 0 until end of file;
	 `string' is guaranteed to be 0X-terminated;
	 the file pointer of `stream' is left on position 0
      *)
   BEGIN
      ReadPart(string, 0, stream);
   END Read;

   (* ======= string to string operations =========================== *)

   PROCEDURE Copy*(VAR destination: ARRAY OF CHAR;
		  source: ARRAY OF CHAR);
      VAR
	 index: Types.Int32;
	 minlen: Types.Int32;
   BEGIN
      minlen := LEN(destination);
      IF minlen > LEN(source) THEN
	 minlen := LEN(source);
      END;
      (* minlen is guaranteed to be positive here
	 because "ARRAY 0 OF CHAR" is not a legal type
      *)
      DEC(minlen);

      index := 0;
      WHILE (index < minlen) & (source[index] # 0X) DO
	 destination[index] := source[index];
	 INC(index);
      END;
      destination[index] := 0X;
   END Copy;

   PROCEDURE PartCopy*(VAR destination: ARRAY OF CHAR; destIndex: Types.Int32;
		      source: ARRAY OF CHAR; sourceIndex: Types.Int32);
      (* copy source[sourceIndex..] to destination[destIndex..] *)
   BEGIN
      WHILE (destIndex+1 < LEN(destination)) &
	    (sourceIndex < LEN(source)) &
	    (source[sourceIndex] # 0X) DO
	 destination[destIndex] := source[sourceIndex];
	 INC(destIndex); INC(sourceIndex);
      END;
      IF destIndex < LEN(destination) THEN
	 destination[destIndex] := 0X;
      END;
   END PartCopy;

   PROCEDURE Len*(string: ARRAY OF CHAR) : Types.Int32;
      (* returns the number of characters (without terminating 0X) *)
      VAR
	 len: Types.Int32;
   BEGIN
      len := 0;
      WHILE (len < LEN(string)) & (string[len] # 0X) DO
	 INC(len);
      END;
      RETURN len
   END Len;

   PROCEDURE Concatenate*(VAR destination: ARRAY OF CHAR;
			 source: ARRAY OF CHAR);
      (* append source to destination;
	 PartCopy(destination, Len(destination), source, 0);
      *)
   BEGIN
      PartCopy(destination, Len(destination), source, 0);
   END Concatenate;

   (* ======= strings as streams ==================================== *)

   PROCEDURE Error(stream: Streams.Stream; code: ErrorCode);
      VAR
	 event: Event;
   BEGIN
      NEW(event);
      event.type := error;
      event.message := errormsg[code];
      event.stream := stream;
      event.errorcode := code;
      RelatedEvents.Raise(stream, event);
   END Error;

   PROCEDURE ReadByte(stream: Streams.Stream; VAR byte: Byte) : BOOLEAN;
   BEGIN
      WITH stream: Stream DO
	 IF stream.pos < stream.termindex THEN
	    SYS.GET(stream.addr + stream.pos, byte);
	    INC(stream.pos);
	    RETURN TRUE
	 ELSE
	    RETURN FALSE
	 END;
      END;
   END ReadByte;

   PROCEDURE WriteByte(stream: Streams.Stream; byte: Byte) : BOOLEAN;
   BEGIN
      WITH stream: Stream DO
	 IF ORD(SYS.VAL(CHAR, byte)) = 0 THEN RETURN FALSE END;
	 IF stream.pos < stream.termindex THEN
	    SYS.PUT(stream.addr + stream.pos, byte);
	    INC(stream.pos);
	 ELSIF (stream.pos = stream.termindex) &
	       (stream.termindex+1 < stream.len) THEN
	    SYS.PUT(stream.addr + stream.pos, byte);
	    INC(stream.pos);
	    INC(stream.termindex);
	    SYS.PUT(stream.addr + stream.termindex, 0X);
	 ELSE
	    Error(stream, endOfStringReached);
	    RETURN FALSE
	 END;
	 RETURN TRUE
      END;
   END WriteByte;

   PROCEDURE Seek(stream: Streams.Stream;
		  offset: Streams.Count; whence: Streams.Whence) : BOOLEAN;
      VAR
	 newpos: Streams.Count;
   BEGIN
      WITH stream: Stream DO
	 CASE whence OF
	 | Streams.fromStart: newpos := offset;
	 | Streams.fromPos:   newpos := stream.pos + offset;
	 | Streams.fromEnd:   newpos := stream.termindex + offset;
	 ELSE
	    Error(stream, badParameter);
	    RETURN FALSE
	 END;
	 IF (newpos < 0) OR (newpos > stream.termindex) THEN
	    Error(stream, outOfRange);
	    RETURN FALSE
	 END;
	 stream.pos := newpos;
	 RETURN TRUE
      END;
   END Seek;

   PROCEDURE Tell(stream: Streams.Stream; VAR pos: Streams.Count) : BOOLEAN;
   BEGIN
      WITH stream: Stream DO
	 pos := stream.pos;
	 RETURN TRUE
      END;
   END Tell;

   PROCEDURE Trunc(stream: Streams.Stream; length: Streams.Count) : BOOLEAN;
   BEGIN
      WITH stream: Stream DO
	 IF (length >= 0) & (length <= stream.termindex) &
	       (stream.pos <= length) THEN
	    stream.termindex := length;
	    SYS.PUT(stream.addr + stream.termindex, 0X);
	    RETURN TRUE
	 ELSE
	    IF (length >= 0) & (length <= stream.termindex) THEN
	       Error(stream, outOfRange);
	    ELSE
	       Error(stream, posOutside);
	    END;
	    RETURN FALSE
	 END;
      END;
   END Trunc;

   PROCEDURE Flush(s: Streams.Stream) : BOOLEAN;
      VAR
	 len: Types.Int32;
	 ch: CHAR;
   BEGIN
      WITH s: Stream DO
	 len := 0;
	 LOOP
	    IF len = s.len THEN EXIT END;
	    SYS.GET(s.addr + len, ch);
	    IF ch = 0X THEN EXIT END;
	    INC(len);
	 END;
	 s.termindex := len;
	 IF s.termindex = s.len THEN
	    (* enforce 0X-termination *)
	    DEC(s.termindex);
	    SYS.PUT(s.addr + s.termindex, 0X);
	 END;
	 IF s.pos > s.termindex THEN
	    s.pos := s.termindex;
	 END;
      END;
      RETURN TRUE
   END Flush;

   PROCEDURE Open*(VAR stream: Streams.Stream; VAR string: ARRAY OF CHAR);
      (* opens string for reading and writing; seek & tell are permitted;
	 0X-termination of string is guaranteed;
      *)
      VAR
	 newstream: Stream;
   BEGIN
      NEW(newstream);
      Services.Init(newstream, type);
      Streams.Init(newstream, if, caps, Streams.nobuf);
      newstream.addr := SYS.ADR(string);
      newstream.len := LEN(string);
      newstream.termindex := Len(string);
      IF newstream.termindex = LEN(string) THEN
	 (* enforce 0X-termination *)
	 DEC(newstream.termindex);
	 string[newstream.termindex] := 0X;
      END;
      newstream.pos := 0;
      RelatedEvents.QueueEvents(newstream);
      stream := newstream;
   END Open;

BEGIN
   NEW(if);
   if.read := ReadByte; if.write := WriteByte;
   if.seek := Seek; if.tell := Tell; if.trunc := Trunc; if.flush := Flush;
   caps := {Streams.read, Streams.write, Streams.seek, Streams.tell,
		  Streams.trunc, Streams.flush};
   Services.CreateType(type, "Strings.Stream", "Streams.Stream");

   errormsg[endOfStringReached] := "end of string reached";
   errormsg[outOfRange] := "position out of range";
   errormsg[badParameter] := "illegal parameter value";
   errormsg[posOutside] := "current position beyond intended trunc position";

   Events.Define(error);
   Events.SetPriority(error, Priorities.liberrors);
   Events.Ignore(error);
END ulmStrings.
