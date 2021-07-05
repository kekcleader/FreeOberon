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
   $Id: Texts.om,v 1.3 1995/03/17 19:37:52 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Texts.om,v $
   Revision 1.3  1995/03/17 19:37:52  borchert
   - error events added
   - some fixes because streams are now an extension of Services.Object

   Revision 1.2  1994/07/18  14:21:13  borchert
   buggy free buffer handling removed

   Revision 1.1  1994/02/22  20:11:07  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 8/89
   ----------------------------------------------------------------------------
*)

MODULE ulmTexts;

   (* management of texts (dynamic strings) *)

   IMPORT Events := ulmEvents, Priorities := ulmPriorities, RelatedEvents := ulmRelatedEvents, Services := ulmServices, Streams := ulmStreams;

   CONST
      bufsize = 512;

   TYPE
      Count = Streams.Count;
      Address = Streams.Address;
      Byte = Streams.Byte;
      Stream = Streams.Stream;
      Whence = Streams.Whence;

      BufferLink = POINTER TO Buffer;
      Buffer =
	 RECORD
	    cont: ARRAY bufsize OF Byte;
	    next: BufferLink;
	 END;
      Text* = POINTER TO TextRec;
      TextRec* =
	 RECORD
	    (Streams.StreamRec)
	    pos: Count;			(* current position *)
	    len: Count;			(* total length in bytes *)
	    cnt: Count;			(* number of buffers *)
	    head, tail: BufferLink;	(* list of buffers *)
	 END;

   VAR
      if: Streams.Interface;		(* parameters of Streams.Init *)
      caps: Streams.CapabilitySet;
      type: Services.Type; (* Texts.Text *)

   (* === error handling =============================================== *)

   CONST
      posBeyondCurrentLength* = 0;
      invalidTruncPos* = 1;
      errors* = 2;
   TYPE
      ErrorEvent* = POINTER TO ErrorEventRec;
      ErrorEventRec* =
	 RECORD
	    (Events.EventRec)
	    errorcode*: SHORTINT;
	 END;
   VAR
      errormsg*: ARRAY errors OF Events.Message;
      error*: Events.EventType;

   PROCEDURE InitErrorHandling;
   BEGIN
      Events.Define(error);
      Events.SetPriority(error, Priorities.liberrors);
      errormsg[posBeyondCurrentLength] :=
	 "desired position is beyond the current length";
      errormsg[invalidTruncPos] := "invalid trunc position";
   END InitErrorHandling;

   PROCEDURE Error(s: Streams.Stream; code: SHORTINT);
      VAR
	 event: ErrorEvent;
   BEGIN
      NEW(event);
      event.type := error;
      event.message := errormsg[code];
      event.errorcode := code;
      RelatedEvents.Raise(s, event);
   END Error;

   (* === buffer management ============================================ *)

   PROCEDURE Access(t: Text; VAR buffer: BufferLink);
      VAR i: Count;
   BEGIN
      IF t.pos >= bufsize * t.cnt THEN
	 NEW(buffer);
	 buffer.next := NIL;
	 IF t.tail = NIL THEN
	    t.head := buffer;
	 ELSE
	    t.tail.next := buffer;
	 END;
	 t.tail := buffer;
	 INC(t.cnt);
      ELSE
	 buffer := t.head;
	 i := 0;
	 WHILE i < t.pos DIV bufsize DO
	    buffer := buffer.next;
	    INC(i);
	 END;
      END;
   END Access;

   (* === interface procedures ========================================= *)

   PROCEDURE BufRead(s: Stream; VAR buf: ARRAY OF Byte;
		     off, cnt: Count) : Count;
      VAR
	 buffer: BufferLink;
	 index: Count;
	 i, count: Count;
   BEGIN
      WITH s: Text DO
	 count := cnt;
	 IF count > s.len - s.pos THEN
	    count := s.len - s.pos;
	 END;
	 IF count > 0 THEN
	    Access(s, buffer); index := s.pos MOD bufsize;
	    i := off;
	    WHILE i < off + count DO
	       buf[i] := buffer.cont[index];
	       INC(i); INC(index); INC(s.pos);
	       IF index MOD bufsize = 0 THEN
		  Access(s, buffer); index := 0;
	       END;
	    END;
	 END;
      END;
      RETURN count
   END BufRead;

   PROCEDURE BufWrite(s: Stream; VAR buf: ARRAY OF Byte;
		      off, cnt: Count) : Count;
      VAR
	 buffer: BufferLink;
	 index: Count;
	 i: Count;
   BEGIN
      WITH s: Text DO
	 IF cnt > 0 THEN
	    Access(s, buffer); index := s.pos MOD bufsize;
	    i := off;
	    WHILE i < off + cnt DO
	       buffer.cont[index] := buf[i];
	       INC(i); INC(index); INC(s.pos);
	       IF s.pos > s.len THEN
		  s.len := s.pos;
	       END;
	       IF index MOD bufsize = 0 THEN
		  Access(s, buffer); index := 0;
	       END;
	    END;
	 END;
      END;
      RETURN cnt
   END BufWrite;

   PROCEDURE Read(s: Stream; VAR byte: Byte) : BOOLEAN;
      VAR
	 buffer: BufferLink;
   BEGIN
      WITH s: Text DO
	 IF s.pos < s.len THEN
	    Access(s, buffer);
	    byte := buffer.cont[s.pos MOD bufsize];
	    INC(s.pos);
	    RETURN TRUE
	 ELSE
	    RETURN FALSE
	 END;
      END;
   END Read;

   PROCEDURE Write(s: Stream; byte: Byte) : BOOLEAN;
      VAR
	 buffer: BufferLink;
   BEGIN
      WITH s: Text DO
	 Access(s, buffer);
	 buffer.cont[s.pos MOD bufsize] := byte;
	 INC(s.pos);
	 IF s.pos > s.len THEN
	    s.len := s.pos;
	 END;
	 RETURN TRUE
      END;
   END Write;

   PROCEDURE Seek(s: Stream; count: Count; whence: Whence) : BOOLEAN;
      VAR
	 pos: Count;
   BEGIN
      WITH s: Text DO
	 CASE whence OF
	 | Streams.fromStart: pos := count;
	 | Streams.fromPos:   pos := count + s.pos;
	 | Streams.fromEnd:   pos := count + s.len;
    ELSE
	 END;
	 IF (pos >= 0) & (pos <= s.len) THEN
	    s.pos := pos;
	    RETURN TRUE
	 ELSE
	    Error(s, posBeyondCurrentLength);
	    RETURN FALSE (* holes are not permitted *)
	 END;
      END;
   END Seek;

   PROCEDURE Tell(s: Stream; VAR count: Count) : BOOLEAN;
   BEGIN
      count := s(Text).pos;
      RETURN TRUE
   END Tell;

   PROCEDURE Close(s: Stream) : BOOLEAN;
   BEGIN
      WITH s: Text DO
	 s.pos := 0; s.len := 0;
	 IF s.cnt > 0 THEN
	    s.cnt := 0;
	    s.head := NIL; s.tail := NIL;
	 END;
      END;
      RETURN TRUE
   END Close;

   PROCEDURE Trunc(s: Stream; length: Count) : BOOLEAN;
      VAR
	 i: Count;
	 buffer: BufferLink;
   BEGIN
      WITH s: Text DO
	 IF (length >= 0) & (length <= s.len) & (s.pos <= length) THEN
	    IF length DIV bufsize < s.len DIV bufsize THEN
	       (* release truncated buffers *)
	       i := 0; buffer := s.head;
	       WHILE i < length DIV bufsize DO
		  buffer := buffer.next; INC(i);
	       END;
	       s.tail := buffer; s.tail.next := NIL;
	       s.cnt := i;
	    END;
	    s.len := length;
	    RETURN TRUE
	 ELSE
	    Error(s, invalidTruncPos);
	    RETURN FALSE
	 END;
      END;
   END Trunc;

   PROCEDURE Open*(VAR text: Streams.Stream);
      (* for reading and writing *)
      VAR
	 newtext: Text;
   BEGIN
      NEW(newtext);
      Services.Init(newtext, type);
      Streams.Init(newtext, if, caps, Streams.nobuf);
      RelatedEvents.QueueEvents(newtext);
      newtext.pos := 0; newtext.len := 0;
      newtext.cnt := 0; newtext.head := NIL; newtext.tail := NIL;
      text := newtext;
   END Open;

BEGIN
   NEW(if);
   if.bufread := BufRead; if.bufwrite := BufWrite;
   if.read := Read; if.write := Write;
   if.seek := Seek; if.tell := Tell;
   if.trunc := Trunc; if.close := Close;
   caps := {Streams.read, Streams.write, Streams.bufio,
	    Streams.seek, Streams.tell, Streams.trunc, Streams.close};
   Services.CreateType(type, "Texts.Text", "Streams.Stream");
   InitErrorHandling;
END ulmTexts.
