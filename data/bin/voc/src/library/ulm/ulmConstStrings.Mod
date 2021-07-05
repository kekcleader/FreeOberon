(* Ulm's Oberon Library
   Copyright (C) 1989-2004 by University of Ulm, SAI, D-89069 Ulm, Germany
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
   $Id: ConstString.om,v 1.5 2004/05/21 14:22:04 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: ConstString.om,v $
   Revision 1.5  2004/05/21 14:22:04  borchert
   various performance improvements:
   - support of ReadBuf interface procedure of Streams
   - CreateD is no longer based on CloseD
   - Write takes advantage of Streams.WritePart
   (partially based on code and suggestions by Christian Ehrhardt)

   Revision 1.4  1997/04/02 07:34:53  borchert
   ConstStrings are now an extension of Disciplines.Object

   Revision 1.3  1996/01/04  17:03:26  borchert
   - const strings are now an extension of Disciplines.Object
   - domains added

   Revision 1.2  1994/07/18  14:15:42  borchert
   unused variables of Close (buf & offset) removed

   Revision 1.1  1994/02/22  20:06:38  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 10/90
   ----------------------------------------------------------------------------
*)

MODULE ulmConstStrings;

   (* WORM-device for strings *)

   IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, Process := ulmProcess, Services := ulmServices, Streams := ulmStreams, Strings := ulmStrings, Texts := ulmTexts, Types := ulmTypes;

   CONST
      tabsize = 1031;		(* should be a prime number *)
      bufsize = 512;

   TYPE
      Domain* = POINTER TO DomainRec;

   TYPE
      Byte = Types.Byte;
      Buffer = POINTER TO BufferRec;
      BufferRec =
	 RECORD
	    buf: ARRAY bufsize OF CHAR;
	    free: Types.Int32; (* buf[free..bufsize-1] is unused *)
	    next: Buffer;
	 END;

      String* = POINTER TO StringRec;
      StringRec* =
	 RECORD
	    (Disciplines.ObjectRec)
	    (* read-only *)
	    len*: Streams.Count;	(* length of string in bytes *)
	    hashval*: Types.Int32;	(* hash value *)
	    (* private part *)
	    domain: Domain;
	    length: Streams.Count; (* private copy of length *)
	    buf: Buffer;	(* first buffer containing the string *)
	    offset: Types.Int32;	(* offset into buf *)
	    next: String;	(* list of strings with same hash value *)
	 END;

   TYPE
      DomainRec* =
	 RECORD
	    (Disciplines.ObjectRec)
	    bucket: ARRAY tabsize OF String;
	    head, tail: Buffer;
	 END;
   VAR
      std*: Domain; (* default domain *)

   TYPE
      StreamList = POINTER TO StreamListRec;
      StreamListRec =
	 RECORD
	    stream: Streams.Stream;
	    next: StreamList;
	 END;

      ReadStream = POINTER TO ReadStreamRec;
      ReadStreamRec =
	 RECORD
	    (Streams.StreamRec)
	    string: String;
	    buf: Buffer;	(* current buffer *)
	    offset: Types.Int32;	(* index in current buffer *)
	    pos: Streams.Count;	(* current position *)
	 END;

   VAR
      freelist: StreamList;		(* list of unused streams *)
      if: Streams.Interface;
      caps: Streams.CapabilitySet;
      type: Services.Type; (* ReadStream *)

   (* === internal procedures =========================================== *)

   PROCEDURE HashVal(s: Streams.Stream; len: Streams.Count;
		     VAR hashval, orighashval: Types.Int32);
      (* compute the hash value of the first `len' bytes of `s';
	 the hash value is returned in two variants:
	    hashval:      hash value MOD tabsize
	    orighashval:  unmodified hash value
      *)
      CONST
	 shift = 4;
      VAR
	 ordval: Types.Int32;
	 ch: CHAR;
	 index: Streams.Count;

   BEGIN
      Streams.SetPos(s, 0);
      hashval := len;
      index := 0;
      WHILE (index < len) & Streams.ReadByte(s, ch) DO
	 IF ch >= " " THEN
	    ordval := ORD(ch) - ORD(" ");
	 ELSE
	    ordval := ORD(MAX(CHAR)) - ORD(" ") + ORD(ch);
	 END;
	 hashval := ASH(hashval, shift) + ordval;
	 INC(index);
      END;
      (* assert: index = len *)
      orighashval := hashval;
      hashval := hashval MOD tabsize;
   END HashVal;

   PROCEDURE Equal(s: Streams.Stream; len: Streams.Count;
		   string: String) : BOOLEAN;
      (* consider `s' to be a stream providing `len' bytes;
	 return TRUE iff the byte sequence of `s' equals that of `string'
      *)
      VAR
	 ch: CHAR;
	 buf: Buffer; offset: Types.Int32;
	 index: Streams.Count;
   BEGIN
      Streams.SetPos(s, 0);
      IF len # string.length THEN
	 RETURN FALSE
      END;
      index := 0;
      buf := string.buf; offset := string.offset;
      WHILE (index < len) & Streams.ReadByte(s, ch) DO
	 IF ch # buf.buf[offset] THEN
	    RETURN FALSE
	 END;
	 INC(offset);
	 IF offset >= bufsize THEN
	    buf := buf.next; offset := 0;
	 END;
	 INC(index);
      END;
      (* assert: index = len *)
      RETURN TRUE
   END Equal;

   PROCEDURE Allocate(domain: Domain; len: Streams.Count;
		      VAR buf: Buffer; VAR offset: Types.Int32);
      (* allocate space for `len' bytes;
         `buf' and `offset' are returned, designating the
	 begin of the allocated area; note that
	 if the space within `buf' is not sufficient its
	 subsequent buffers are to be used
      *)
      
      PROCEDURE NewBuffer;
	 VAR
	    buf: Buffer;
      BEGIN
	 NEW(buf);
	 buf.free := 0;
	 buf.next := NIL;
	 IF domain.head = NIL THEN
	    domain.head := buf;
	 ELSE
	    domain.tail.next := buf;
	 END;
	 domain.tail := buf;
      END NewBuffer;

   BEGIN (* Allocate *)
      IF (domain.head = NIL) OR (domain.tail.free = bufsize) THEN
	 NewBuffer;
      END;
      buf := domain.tail;
      offset := buf.free;
      WHILE len > 0 DO
	 IF len <= bufsize - domain.tail.free THEN
	    INC(domain.tail.free, len); len := 0;
	 ELSE
	    DEC(len, bufsize - domain.tail.free);
	    domain.tail.free := bufsize;
	    NewBuffer;
	 END;
      END;
   END Allocate;

   PROCEDURE CopyString(s: Streams.Stream; length: Streams.Count;
			buf: Buffer; offset: Types.Int32);
      (* copy `length' bytes from `s' to `buf' at the given offset
	 and its subsequent buffers
      *)
      VAR
	 ok: BOOLEAN;
	 bytes: Streams.Count;
   BEGIN
      Streams.SetPos(s, 0);
      WHILE length > 0 DO
	 bytes := bufsize - offset;
	 IF bytes > length THEN
	    bytes := length;
	 END;
	 IF bytes > bufsize - offset THEN
	    bytes := bufsize - offset;
	 END;
	 ok := Streams.ReadPart(s, buf.buf, offset, bytes); ASSERT(ok);
	 offset := 0;
	 buf := buf.next;
	 DEC(length, bytes);
      END;
   END CopyString;

   PROCEDURE InternalCreateD(s: Streams.Stream;
			     length: Streams.Count;
                             domain: Domain;
			     VAR string: String);
      (* common part of CloseD and CreateD *)
      VAR
	 orighashval, hashval: Types.Int32;
	 str: String;
   BEGIN
      HashVal(s, length, hashval, orighashval);
      IF domain.bucket[hashval] # NIL THEN
	 str := domain.bucket[hashval];
	 WHILE str # NIL DO
	    IF Equal(s, length, str) THEN
	       string := str;
	       RETURN
	    END;
	    str := str.next;
	 END;
      END;
      NEW(str);
      str.domain := domain;
      str.len := length; str.length := length;
      str.hashval := orighashval;
      (* enter new string into the table *)
      Allocate(domain, length, str.buf, str.offset);
      CopyString(s, length, str.buf, str.offset);
      str.next := domain.bucket[hashval];
      domain.bucket[hashval] := str;
      string := str;
   END InternalCreateD;

   (* === exported procedures =========================================== *)

   PROCEDURE CreateDomain*(VAR domain: Domain);
   BEGIN
      NEW(domain); domain.head := NIL; domain.tail := NIL;
   END CreateDomain;

   PROCEDURE Init*(VAR s: Streams.Stream);
      (* open s for writing *)
   BEGIN
      IF freelist # NIL THEN
	 s := freelist.stream;
	 freelist := freelist.next;
	 Streams.SetPos(s, 0);
      ELSE
	 Texts.Open(s);
      END;
   END Init;

   PROCEDURE CloseD*(s: Streams.Stream; domain: Domain; VAR string: String);
      (* must be called instead of Streams.Close to get
	 the resulting string
      *)
      VAR
	 length: Streams.Count;

      PROCEDURE FreeText;
	 VAR
	    free: StreamList;
      BEGIN
	 NEW(free); free.stream := s;
	 free.next := freelist; freelist := free;
      END FreeText;

   BEGIN (* CloseD *)
      Streams.GetPos(s, length);
      InternalCreateD(s, length, domain, string);
      FreeText;
   END CloseD;

   PROCEDURE Close*(s: Streams.Stream; VAR string: String);
   BEGIN
      CloseD(s, std, string);
   END Close;

   PROCEDURE CreateD*(VAR string: String; domain: Domain; s: ARRAY OF CHAR);
      VAR
	 length: Streams.Count;
	 stream: Streams.Stream;
   BEGIN
      length := 0;
      WHILE (length < LEN(s)) & (s[length] # 0X) DO
         INC(length);
      END;
      Strings.Open(stream, s);
      InternalCreateD(stream, length, domain, string);
   END CreateD;

   PROCEDURE Create*(VAR string: String; s: ARRAY OF CHAR);
   BEGIN
      CreateD(string, std, s);
   END Create;

   PROCEDURE Open*(VAR s: Streams.Stream; string: String);
      (* open s for reading *)
      VAR
	 rs: ReadStream;
   BEGIN
      NEW(rs);
      Services.Init(rs, type);
      Streams.Init(rs, if, caps, Streams.nobuf);
      rs.string := string;
      rs.buf := string.buf;
      rs.offset := string.offset;
      rs.pos := 0;
      s := rs;
   END Open;

   PROCEDURE Compare*(string1, string2: String) : Types.Int32;
      (* returns < 0: if string1 < string2
		 = 0: if string1 = string2 (see note above)
		 > 0: if string1 > string2
      *)
      VAR
	 ch1, ch2: CHAR;
	 buf1, buf2: Buffer;
	 offset1, offset2: Types.Int32;
	 len1, len2: Streams.Count;

      PROCEDURE Next(VAR buf: Buffer; VAR offset: Types.Int32; VAR ch: CHAR);
      BEGIN
	 ch := buf.buf[offset];
	 INC(offset);
	 IF offset >= bufsize THEN
	    buf := buf.next;
	    offset := 0;
	 END;
      END Next;

   BEGIN (* Compare *)
      IF string1 = string2 THEN
	 RETURN 0
      END;
      len1 := string1.length; len2 := string2.length;
      buf1 := string1.buf; buf2 := string2.buf;
      offset1 := string1.offset; offset2 := string2.offset;
      WHILE (len1 > 0) & (len2 > 0) DO
	 Next(buf1, offset1, ch1);
	 Next(buf2, offset2, ch2);
	 IF ch1 # ch2 THEN
	    RETURN ORD(ch1) - ORD(ch2)
	 END;
	 DEC(len1); DEC(len2);
      END;
      (* RETURN len1 - len2 does not work because of the return type *)
      IF len1 < len2 THEN
	 RETURN -1
      ELSIF len1 > len2 THEN
	 RETURN 1
      ELSE
	 RETURN 0
      END;
   END Compare;

   PROCEDURE Write*(s: Streams.Stream; string: String);
      (* copy contents of `string' to `s' *)
      VAR
	 len: Streams.Count;
	 buf: Buffer;
	 offset: Types.Int32;
	 count: Streams.Count;
	 bytes: Streams.Count;
   BEGIN
      len := string.length;
      buf := string.buf;
      offset := string.offset;
      count := 0;
      LOOP
	 IF len = 0 THEN EXIT END;
	 bytes := len;
	 IF bytes > bufsize - offset THEN
	    bytes := bufsize - offset;
	 END;
	 IF ~Streams.WritePart(s, buf.buf, offset, bytes) THEN
	    INC(count, s.count);
	    EXIT
	 END;
	 INC(count, bytes); DEC(len, bytes); INC(offset, bytes);
	 IF offset >= bufsize THEN
	    buf := buf.next;
	    offset := 0;
	 END;
      END;
      s.count := count;
   END Write;

   PROCEDURE Extract*(VAR s: ARRAY OF CHAR; string: String);
      (* copy contents of `string' to `s' *)
      VAR
	 len: Streams.Count;
	 buf: Buffer;
	 offset: Types.Int32;
	 index: Streams.Count;
   BEGIN
      len := string.length;
      buf := string.buf;
      offset := string.offset;
      index := 0;
      WHILE (index+1 < LEN(s)) & (len > 0) DO
	 s[index] := buf.buf[offset];
	 INC(index);
	 DEC(len);
	 INC(offset);
	 IF offset >= bufsize THEN
	    buf := buf.next;
	    offset := 0;
	 END;
      END;
      s[index] := 0X;
   END Extract;

   (* ========= interface procedures for ReadStream ===================== *)

   PROCEDURE ReadByte(s: Streams.Stream; VAR byte: Byte) : BOOLEAN;
   BEGIN
      WITH s: ReadStream DO
	 IF s.pos >= s.string.length THEN
	    RETURN FALSE
	 END;
	 byte := s.buf.buf[s.offset];
	 INC(s.offset);
	 IF s.offset >= bufsize THEN
	    s.offset := 0;
	    s.buf := s.buf.next;
	 END;
	 INC(s.pos);
	 RETURN TRUE
      END;
   END ReadByte;

   PROCEDURE ReadBuf(s: Streams.Stream; VAR buf: ARRAY OF Types.Byte;
                     off, cnt: Streams.Count) : Streams.Count;
      VAR
         bytes, max: Streams.Count;
   BEGIN
      WITH s: ReadStream DO
         IF s.pos >= s.string.length THEN
	    RETURN 0
	 END;
         bytes := s.string.length - s.pos;
	 IF bytes > cnt THEN
	    bytes := cnt;
	 END;
	 IF bytes > bufsize - s.offset THEN
	    bytes := bufsize - s.offset;
	 END;
	 max := off + bytes;
	 WHILE off < max DO
	    buf[off] := s.buf.buf[s.offset];
            INC(off); INC(s.offset);
	 END;
	 IF s.offset >= bufsize THEN
	    s.offset := 0;
	    s.buf := s.buf.next;
	 END;
	 INC(s.pos, bytes);
	 RETURN bytes
      END;
   END ReadBuf;

   PROCEDURE Seek(s: Streams.Stream;
		  cnt: Streams.Count; whence: Streams.Whence) : BOOLEAN;
      VAR
	 realpos: Streams.Count;
   BEGIN
      WITH s: ReadStream DO
	 CASE whence OF
	 | Streams.fromStart: realpos := cnt;
	 | Streams.fromPos:   realpos := s.pos + cnt;
	 | Streams.fromEnd:   realpos := s.string.length + cnt;
	 END;
	 IF (realpos < 0) OR (realpos > s.string.length) THEN
	    RETURN FALSE
	 END;
	 IF realpos # s.pos THEN
	    IF realpos < s.pos THEN
	       s.pos := 0; s.offset := s.string.offset; s.buf := s.string.buf;
	    END;
	    WHILE s.pos < realpos DO
	       IF realpos - s.pos < bufsize - s.offset THEN
		  INC(s.offset, realpos - s.pos);
		  s.pos := realpos;
	       ELSE
		  INC(s.pos, bufsize - s.offset);
		  s.offset := 0;
		  s.buf := s.buf.next;
	       END;
	    END;
	 END;
	 RETURN TRUE
      END;
   END Seek;

   PROCEDURE Tell(s: Streams.Stream; VAR cnt: Streams.Count) : BOOLEAN;
   BEGIN
      WITH s: ReadStream DO
	 cnt := s.pos;
	 RETURN TRUE
      END;
   END Tell;

   (* =================================================================== *)

   PROCEDURE FreeHandler(event: Events.Event);
      (* set free list to NIL to return the associated storage
	 to the garbage collector
      *)
   BEGIN
      freelist := NIL;
   END FreeHandler;

BEGIN
   freelist := NIL;
   CreateDomain(std);
   caps := {Streams.read, Streams.seek, Streams.tell, Streams.bufio};
   NEW(if);
   if.read := ReadByte;
   if.bufread := ReadBuf;
   if.seek := Seek;
   if.tell := Tell;
   Events.Handler(Process.startOfGarbageCollection, FreeHandler);
   Services.CreateType(type, "ConstStrings.ReadStream", "Streams.Stream");
END ulmConstStrings.
