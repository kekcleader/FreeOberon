(* Ulm's Oberon Library
  Copyright (C) 1989-2001 by University of Ulm, SAI, D-89069 Ulm, Germany
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
  $Id: Streams.om,v 1.13 2005/02/14 23:36:35 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Streams.om,v $
  Revision 1.13  2005/02/14 23:36:35  borchert
  bug fix: WritePart called InternalFlush without considering
        that s.pos may be implicitly changed
        (this assumption was wrong since revision 1.11)

  Revision 1.12  2004/05/20 09:52:43  borchert
  performance improvements:
  - WritePart and Write take now the buffer by reference
  - ReadByteFromBuf replaced by ReadBytesFromBuf
  (contributed by Christian Ehrhardt)

  Revision 1.11  2001/05/03 15:17:58  borchert
  InternalFlush adapted for unidirectional pipelines to avoid
  unintentional flushes due to buffer boundaries

  Revision 1.10  2000/04/25 21:41:47  borchert
  Streams.ReadPart loops now for unbuffered streams to collect input
  until cnt is reached

  Revision 1.9  1998/03/31  11:13:05  borchert
  bug fix: NotificationHandler just reacted on Resources.unreferenced
        but not on Resources.terminated

  Revision 1.8  1998/03/24  22:58:28  borchert
  bug fix in Copy: left was computed incorrectly in case of
              copies with fixed length (# -1)

  Revision 1.7  1997/04/02  07:50:05  borchert
  Copy replaced by a slightly more efficient variant

  Revision 1.6  1996/09/18  07:43:51  borchert
  qualified references to own module (i.e. Streams.XXX) removed

  Revision 1.5  1996/01/04  16:43:57  borchert
  some bug fixes in the updates of read and write regions

  Revision 1.4  1995/10/11  09:46:41  borchert
  - closeEvent re-introduced (because it gets raised *before*
    the actual close)
  - bug fix: s.write was diminished in ReadPart but the write region
    not properly adjusted
  - bug fix: InternalSeek was setting s.left to negative values in
    a special case

  Revision 1.3  1995/04/18  12:17:12  borchert
  - Streams.Stream is now an extension of Services.Object
  - Library variant of assertions replaced by ASSERT
  - support of Resources added
  - EnableClose, PreventClose & closeEvent removed

  Revision 1.2  1994/07/05  12:45:57  borchert
  some minor bug fixes & enhancements:
  - ReadPacket added
  - streams which don't require cleanup are now subject to the GC
    even if Close will never be called for them
  - line buffered streams w/o bufio/addrio capability fill now buffer
    up to the next line terminator only instead of trying to fill the
    whole buffer
  - ReadPart didn't set count correctly in all cases
  - Touch calls now the flush interface procedure

  Revision 1.1  1994/02/22  20:10:45  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 6/89
  Major Revision: AFB 1/92: bufpool
  ----------------------------------------------------------------------------
*)

MODULE ulmStreams;

  IMPORT Events := ulmEvents, Objects := ulmObjects, Priorities := ulmPriorities, Process := ulmProcess, RelatedEvents := ulmRelatedEvents, Resources := ulmResources,
    Services := ulmServices, SYS := ulmSYSTEM, SYSTEM, Types := ulmTypes;

  CONST
    (* 3rd parameter of Seek *)
    (* Whence = (fromStart, fromPos, fromEnd); *)
    fromStart* = 0; fromPos* = 1; fromEnd* = 2;

    (* capabilities of a stream *)
    (* Capability = (read, write, addrio, bufio, seek, tell, trunc, close,
                holes, handler);
    *)
    read* = 0; write* = 1; addrio* = 2; bufio* = 3; seek* = 4; tell* = 5;
    trunc* = 6; flush* = 7; close* = 8; holes* = 9; handler* = 10;

    (* BufMode = (nobuf, linebuf, onebuf, bufpool); *)
    nobuf* = 0; linebuf* = 1; onebuf* = 2; bufpool* = 3;

    (* ErrorCode = (NoHandlerDefined, CannotRead, CannotSeek, CloseFailed,
               NotLineBuffered, SeekFailed, TellFailed, BadWhence,
               CannotTell, WriteFailed, CannotWrite, ReadFailed,
               Unbuffered, BadParameters, CannotTrunc, TruncFailed,
               NestedCall, FlushFailed);
    *)
    NoHandlerDefined* = 0;    (* no handler defined *)
    CannotRead* = 1;          (* stream is write only *)
    CannotSeek* = 2;          (* stream is not capable of seeking *)
    CloseFailed* = 3;         (* Flush or Close failed *)
    NotLineBuffered* = 4;     (* LineTerm must not be called *)
    SeekFailed* = 5;          (* seek operation failed *)
    TellFailed* = 6;          (* tell operation failed *)
    BadWhence* = 7;           (* whence value out of [fromStart..fromEnd] *)
    CannotTell* = 8;          (* stream does not have a current position *)
    WriteFailed* = 9;         (* write error *)
    CannotWrite* = 10;                (* stream is read only *)
    ReadFailed* = 11;         (* read error *)
    Unbuffered* = 12;         (* operation isn't valid for unbuff'd streams *)
    BadParameters* = 13;      (* e.g. wrong count or offset values *)
    CannotTrunc* = 14;                (* stream is not capable of truncating *)
    TruncFailed* = 15;                (* trunc operation failed *)
    NestedCall* = 16;         (* nested stream operation *)
    FlushFailed* = 17;         (* flush operation failed *)
    errorcodes* = 18;         (* number of error codes *)

    (* === private constants ======================================= *)
    bufsize = 8192;   (* should be the file system block size *)
    defaulttermch = 0AX; (* default line terminator (for linebuf) *)

  TYPE
    Address* = Types.Address;
    Count* = Types.Count;
    Byte* = Types.Byte;
    Whence* = Types.Int8; (* Whence = (fromStart, fromPos, fromEnd); *)
    CapabilitySet* = Types.Set; (* OF Capability; *)
    BufMode* = Types.Int8;
    ErrorCode* = Types.Int8;
    Stream* = POINTER TO StreamRec;
    Message* = RECORD (Objects.ObjectRec) END;

    (* the buffering system:

      buffers are always on bufsize-boundaries

      ok:            the other components are defined
      pos:           file position of cont[0] (pos MOD bufsize = 0)
      cont:          valid data: cont[rbegin]..cont[rend-1]  (read-region)
                written data: cont[wbegin]..cont[wend-1]  (write-region)

      both regions are maintained (even for non-rw streams)
    *)
    Buffer = POINTER TO BufferRec;
    BufferRec =
      RECORD
        ok: BOOLEAN; (* TRUE if other components are valid *)
        pos: Count;  (* file position which corresponds to cont[0] *)
        rbegin: Count;  (* read-region: starting index *)
        rend: Count;  (* read-region: ending index *)
        wbegin: Count; (* write-region: starting index of dirty region *)
        wend: Count; (* write-region: ending index *)
        cont: ARRAY bufsize OF Byte; (* buffer contents *)
        nextfree: Buffer; (* only needed for released buffers *)
        (* components for buffers which are members of a buffer pool *)
        prevh, nexth: Buffer; (* next buffer with same the hash value *)
        preva, nexta: Buffer; (* sorted list of buffers (access time) *)
      END;

  CONST
    hashtabsize = 128; (* size of bucket table *)
  TYPE
    BucketTable = ARRAY hashtabsize OF Buffer;
    BufferPool = POINTER TO BufferPoolRec;
    BufferPoolRec =
      RECORD
        maxbuf: Types.Int32; (* maximal number of buffers to be used *)
        nbuf: Types.Int32; (* number of buffers in use *)
        bucket: BucketTable;
        (* list of all buffers sorted after the last access time;
          tail points to the buffer most recently accessed
        *)
        head, tail: Buffer;
      END;

  TYPE
    AddrIOProc* = PROCEDURE (s: Stream; ptr: Address; cnt: Count) : Count;
    BufIOProc* = PROCEDURE (s: Stream; VAR buf: ARRAY OF Byte;
                    off, cnt: Count) : Count;
    SeekProc* = PROCEDURE (s: Stream; cnt: Count; whence: Whence) : BOOLEAN;
    TellProc* = PROCEDURE (s: Stream; VAR cnt: Count) : BOOLEAN;
    ReadProc* = PROCEDURE (s: Stream; VAR byte: Byte) : BOOLEAN;
    WriteProc* = PROCEDURE (s: Stream; byte: Byte) : BOOLEAN;
    TruncProc* = PROCEDURE (s: Stream; cnt: Count) : BOOLEAN;
    FlushProc* = PROCEDURE (s: Stream) : BOOLEAN;
    CloseProc* = PROCEDURE (s: Stream) : BOOLEAN;
    HandlerProc* = PROCEDURE (s: Stream; VAR msg: Message);

    Interface* = POINTER TO InterfaceRec;
    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        addrread*: AddrIOProc;      (* read, addrio *)
        addrwrite*: AddrIOProc;     (* write, addrio *)
        bufread*: BufIOProc;                (* read, bufio *)
        bufwrite*: BufIOProc;       (* write, bufio *)
        read*: ReadProc;            (* read *)
        write*: WriteProc;          (* write *)
        seek*: SeekProc;            (* seek *)
        tell*: TellProc;            (* tell *)
        trunc*: TruncProc;          (* trunc *)
        flush*: FlushProc;           (* flush *)
        close*: CloseProc;          (* close *)
        handler*: HandlerProc;       (* handler *)
      END;

    StreamRec* =
      RECORD
        (Services.ObjectRec)
        (* following components are set after i/o-operations *)
        count*: Count; (* resulting count of last operation *)
        errors*: Types.Int32; (* incremented for each error; may be set to 0 *)
        error*: BOOLEAN; (* last operation successful? *)
        lasterror*: ErrorCode; (* error code of last error *)
        eof*: BOOLEAN; (* last read-operation with count=0 returned *)
        (* === private part ============================================ *)
        prev, next: Stream; (* list of open streams *)
        if: Interface; caps: CapabilitySet;
        bufmode: BufMode; (* buffering mode *)
        bidirect: BOOLEAN; (* bidirectional buffering? *)
        termch: Byte; (* flush on termch (linebuf only) *)
        inlist: BOOLEAN; (* member of the list of opened streams? *)
        tiedStream: Stream; (* to be flushed before read operations *)
        buf: Buffer; (* current buffer; = NIL for unbuffered streams *)
        wbuf: Buffer; (* buffer for writing (only if bidirect = TRUE) *)
        bufpool: BufferPool; (* only if bufmode = bufpool *)
        validpos: BOOLEAN; (* pos valid? *)
        pos: Count; (* current position in stream *)
        maxpos: Count; (* maximal position until now (only if buf # NIL) *)
        left: Count; (* number of bytes left in buf (after pos) *)
        write: Count; (* number of bytes which can be written in buf *)
        rpos: Count; (* current position of if.tell *)
        wextensible: BOOLEAN; (* write region extensible? *)
        eofFound: BOOLEAN; (* eof seen yet? temporary use only *)
        lock: BOOLEAN; (* avoid recursive operations *)
        flushEvent: Events.EventType; (* valid if # NIL *)
        closeEvent: Events.EventType; (* valid if # NIL *)
      END;
  VAR
    type: Services.Type;

  TYPE
    (* each error causes an event;
      the error number is stored in event.errorcode;
      the associated text can be taken from event.message
    *)
    Event* = POINTER TO EventRec;
    EventRec* =
      RECORD
        (Events.EventRec)
        stream*: Stream;
        errorcode*: ErrorCode;
      END;

  VAR
    null*: Stream; (* accepts any output; does not return input *)
    (* these streams are set by other modules;
      after initialization of Streams they equal `null';
      so, connections with the standard UNIX streams must be
      done by other modules
    *)
    stdin*, stdout*, stderr*: Stream;
    errormsg*: ARRAY errorcodes OF Events.Message;
    error*: Events.EventType;

    (* === private variables ========================================== *)

    opened: Stream; (* list of opened streams *)
      (* this list has been reduced to the set of streams which
        need to be cleaned up explicitly;
        all other streams are subject to the garbage collection
        even if Close has never been called for them
      *)
    freelist: Buffer; (* list of free buffers *)
    nullif: Interface; (* interface of null-devices *)

  (* === private procedures ========================================= *)

  PROCEDURE NewStream(s: Stream);
  BEGIN
    IF s.inlist THEN
      s.prev := NIL;
      s.next := opened;
      IF opened # NIL THEN
        opened.prev := s;
      END;
      opened := s;
    END;
  END NewStream;

  PROCEDURE OldStream(s: Stream);
  BEGIN
    IF s.inlist THEN
      IF s.prev # NIL THEN
        s.prev.next := s.next;
      ELSE
        opened := s.next;
      END;
      IF s.next # NIL THEN
        s.next.prev := s.prev;
      END;
    END;
  END OldStream;

  PROCEDURE NewBuffer(VAR b: Buffer);
  BEGIN
    IF freelist # NIL THEN
      b := freelist;
      freelist := freelist.nextfree;
    ELSE
      NEW(b);
    END;
    b.nextfree := NIL;
    b.ok := FALSE;
  END NewBuffer;

  PROCEDURE OldBuffer(VAR b: Buffer);
  BEGIN
    b.nextfree := freelist;
    freelist := b;
    b := NIL;
  END OldBuffer;

  PROCEDURE Error(s: Stream; code: ErrorCode);
    VAR
      event: Event;
  BEGIN
    IF s # NIL THEN
      INC(s.errors);
      s.error := TRUE;
      s.lasterror := code;

      (* generate error event *)
      NEW(event);
      event.type := error;
      event.message := errormsg[code];
      event.stream := s;
      event.errorcode := code;
      RelatedEvents.Raise(s, event);
    END;
  END Error;

  PROCEDURE ^ InternalFlush(s: Stream) : BOOLEAN;

  (* ===== management of buffer pool ================================== *)

  PROCEDURE InitBufPool(s: Stream);
    VAR
      index: Types.Int32;
  BEGIN
    s.bufpool.maxbuf := 16; (* default size *)
    s.bufpool.nbuf := 0; (* currently, no buffers are allocated *)
    s.bufpool.head := NIL; s.bufpool.tail := NIL;
    index := 0;
    WHILE index < hashtabsize DO
      s.bufpool.bucket[index] := NIL;
      INC(index);
    END;
  END InitBufPool;

  PROCEDURE HashValue(pos: Count) : Types.Int32;
    (* HashValue returns a hash value for pos *)
  BEGIN
    RETURN SHORT(pos DIV bufsize) MOD hashtabsize
  END HashValue;

  PROCEDURE FindBuffer(s: Stream; pos: Count; VAR buf: Buffer) : BOOLEAN;
    VAR
      index: Types.Int32;
      bp: Buffer;
  BEGIN
    index := HashValue(pos);
    bp := s.bufpool.bucket[index];
    WHILE bp # NIL DO
      IF bp.pos = pos THEN
        buf := bp; RETURN TRUE
      END;
      bp := bp.nexth; (* next buffer with same hash value *)
    END;
    buf := NIL;
    RETURN FALSE
  END FindBuffer;

  PROCEDURE GetBuffer(s: Stream);
    (* look for buffer for s.pos and make it to the current buffer;
      set s.left and s.write in dependance of s.pos
    *)
    VAR
      buf: Buffer;
      pos: Count; (* buffer boundary for s.pos *)
      posindex: Count; (* buf[posindex] corresponds to s.pos *)
      index: Types.Int32; (* index into bucket table of the buffer pool *)

    PROCEDURE InitBuf(buf: Buffer);
      VAR
        index: Types.Int32; (* of bucket table *)
    BEGIN
      buf.ok := TRUE;
      buf.pos := pos;
      buf.rbegin := posindex; buf.rend := posindex; s.left := 0;
      buf.wbegin := posindex; buf.wend := posindex;
      s.write := bufsize - posindex;
      buf.nextfree := NIL;

      (* insert buf into hash list *)
      index := HashValue(pos);
      buf.prevh := NIL;
      buf.nexth := s.bufpool.bucket[index];
      IF buf.nexth # NIL THEN
        buf.nexth.prevh := buf;
      END;
      s.bufpool.bucket[index] := buf;

      (* buf is already at the end of the sorted list if we
        re-use an old buffer
      *)
      IF s.bufpool.tail # buf THEN
        (* append buf to the sorted list *)
        buf.nexta := NIL;
        IF s.bufpool.tail = NIL THEN
          s.bufpool.head := buf;
          buf.preva := NIL;
        ELSE
          s.bufpool.tail.nexta := buf;
          buf.preva := s.bufpool.tail;
        END;
        s.bufpool.tail := buf;
      END;
    END InitBuf;

    PROCEDURE UseBuffer(s: Stream; buf: Buffer);
      (* make buf to the current buffer of s *)
    BEGIN
      IF s.buf # buf THEN
        (* remove buf from sorted list *)
        IF buf.preva # NIL THEN
          buf.preva.nexta := buf.nexta;
        ELSE
          s.bufpool.head := buf.nexta;
        END;
        IF buf.nexta # NIL THEN
          buf.nexta.preva := buf.preva;
        ELSE
          s.bufpool.tail := buf.preva;
        END;

        (* append buf to sorted list *)
        buf.nexta := NIL;
        IF s.bufpool.tail = NIL THEN
          s.bufpool.head := buf;
          buf.preva := NIL;
        ELSE
          s.bufpool.tail.nexta := buf;
          buf.preva := s.bufpool.tail;
        END;
        s.bufpool.tail := buf;

        (* set current buf of s to buf *)
        s.buf := buf;

        (* update s.left and s.write *)
        IF buf.rbegin = buf.rend THEN
          buf.rbegin := posindex; buf.rend := posindex; s.left := 0;
        ELSIF (posindex >= buf.rbegin) & (posindex < buf.rend) THEN
          s.left := buf.rend - posindex;
        ELSE
          s.left := 0;
        END;
        IF buf.wbegin = buf.wend THEN
          buf.wbegin := posindex; buf.wend := posindex;
          s.write := bufsize - posindex;
        ELSIF (posindex >= buf.wbegin) & (posindex < buf.wend) THEN
          s.write := bufsize - posindex;
        ELSE
          s.write := 0;
        END;
      END;
    END UseBuffer;

  BEGIN (* GetBuffer *)
    posindex := s.pos MOD bufsize;
    pos := s.pos - posindex;

    IF ~s.buf.ok THEN
      (* init first allocated buffer which has not been used until now *)
      InitBuf(s.buf);
      INC(s.bufpool.nbuf);
    ELSIF s.buf.pos # pos THEN
      IF FindBuffer(s, pos, buf) THEN
        UseBuffer(s, buf);
      ELSE
        IF s.bufpool.nbuf >= s.bufpool.maxbuf THEN
          (* re-use already allocated buffer *)
          buf := s.bufpool.head;
          UseBuffer(s, buf);
          IF buf.wbegin # buf.wend THEN
            IF ~InternalFlush(s) THEN END;
          END;

          (* remove buf from hash list *)
          IF buf.prevh # NIL THEN
            buf.prevh.nexth := buf.nexth;
          ELSE
            index := HashValue(buf.pos);
            s.bufpool.bucket[index] := buf.nexth;
          END;
          IF buf.nexth # NIL THEN
            buf.nexth.prevh := buf.prevh;
          END;

          InitBuf(buf);
        ELSE
          (* allocate and initialize new buffer *)
          NewBuffer(buf);
          InitBuf(buf);
          INC(s.bufpool.nbuf);
        END;
        s.buf := buf;
      END;
    END;
  END GetBuffer;

  PROCEDURE FlushBufPool(s: Stream) : BOOLEAN;
    VAR
      buf: Buffer;
      ok: BOOLEAN;
  BEGIN
    ok := TRUE;
    IF s.bufpool.nbuf > 0 THEN
      buf := s.bufpool.head;
      WHILE buf # NIL DO
        s.buf := buf;
        ok := InternalFlush(s) & ok;
        buf := buf.nexta;
      END;
    END;
    RETURN ok
  END FlushBufPool;

  PROCEDURE ReleaseBufPool(s: Stream);
    (* precondition: all buffers are flushed *)
    VAR
      buf: Buffer;
  BEGIN
    IF s.bufpool.nbuf > 0 THEN
      buf := s.bufpool.head;
      WHILE buf # NIL DO
        s.buf := buf;
        OldBuffer(s.buf);
        buf := buf.nexta;
      END;
    END;
    NewBuffer(s.buf);
    InitBufPool(s);
  END ReleaseBufPool;

  (* ================================================================== *)

  PROCEDURE GetBufMode*(s: Stream) : BufMode;
  BEGIN
    RETURN s.bufmode
  END GetBufMode;

  PROCEDURE LineTerm*(s: Stream; termch: Byte);
    (* set line terminator of `s' (linebuf) to `termch' *)
  BEGIN
    s.error := FALSE;
    IF s.bufmode = linebuf THEN
      s.termch := termch;
    ELSE
      Error(s, NotLineBuffered);
    END;
  END LineTerm;

  PROCEDURE Tie*(in, out: Stream);
    (* PRE: `in' is an line buffered input stream,
          `out' an output stream,
          and `in' # `out';
      causes `out' to be flushed before reading from `in';
      `out' may be NIL to undo the effect
    *)
  BEGIN
    in.error := FALSE;
    IF in.bufmode # linebuf THEN
      Error(in, NotLineBuffered); RETURN
    END;
    IF (in = out) OR ~(read IN in.caps) OR
        (out # NIL) & ~(write IN out.caps) THEN
      Error(in, BadParameters); RETURN
    END;
    in.tiedStream := out;
  END Tie;

  PROCEDURE SetBufferPoolSize*(s: Stream; nbuf: Types.Int32);
  BEGIN
    s.error := FALSE;
    IF SYS.TAS(s.lock) THEN
      Error(s, NestedCall); RETURN
    END;
    IF (s.bufmode = bufpool) & (nbuf >= 1) THEN
      s.bufpool.maxbuf := nbuf;
    END;
    s.lock := FALSE;
  END SetBufferPoolSize;

  PROCEDURE GetBufferPoolSize*(s: Stream; VAR nbuf: Types.Int32);
  BEGIN
    s.error := FALSE;
    CASE s.bufmode OF
    | nobuf:    nbuf := 0;
    | linebuf:  nbuf := 1;
    | onebuf:   nbuf := 1;
    | bufpool:  nbuf := s.bufpool.maxbuf;
    ELSE (* Explicitly ignore unhandled values of s.bufmode  *)
    END;
  END GetBufferPoolSize;

  PROCEDURE Capabilities*(s: Stream) : CapabilitySet;
  BEGIN
    s.error := FALSE;
    RETURN s.caps
  END Capabilities;

  PROCEDURE GetFlushEvent*(s: Stream; VAR type: Events.EventType);
    (* `type' will be raised BEFORE every flush operation *)
  BEGIN
    s.error := FALSE;
    IF s.flushEvent = NIL THEN
      Events.Define(s.flushEvent);
    END;
    type := s.flushEvent;
  END GetFlushEvent;

  PROCEDURE GetCloseEvent*(s: Stream; VAR type: Events.EventType);
    (* `type' will be raised BEFORE the stream gets closed;
      that means write operations etc. are legal
    *)
  BEGIN
    s.error := FALSE;
    IF s.closeEvent = NIL THEN
      Events.Define(s.closeEvent);
    END;
    type := s.closeEvent;
  END GetCloseEvent;

  PROCEDURE Close*(s: Stream) : BOOLEAN;
    VAR
      event: Event;
      type: Events.EventType;
      otherStream: Stream;
  BEGIN
    s.error := FALSE;

    IF (s.closeEvent # NIL) & ~SYS.TAS(s.lock) THEN
      type := s.closeEvent; s.closeEvent := NIL;
      s.lock := FALSE;
      Events.SetPriority(type, Events.GetPriority() + 1);
      NEW(event);
      event.type := type;
      event.message := "close event of Streams";
      event.stream := s;
      Events.Raise(event);
    END;

    IF ~SYS.TAS(s.lock) THEN
      IF write IN s.caps THEN
        IF s.bufmode = bufpool THEN
          IF ~FlushBufPool(s) THEN END;
        ELSE
          IF ~InternalFlush(s) THEN END;
        END;
      END;
      IF close IN s.caps THEN
        IF ~s.if.close(s) THEN
          Error(s, CloseFailed);
        END;
      END;
      IF s.buf # NIL THEN
        IF s.bufmode = bufpool THEN
          ReleaseBufPool(s);
        END;
        OldBuffer(s.buf);
      END;
      OldStream(s);

      (* check if this stream has been tied to another stream *)
      otherStream := opened;
      WHILE otherStream # NIL DO
        IF otherStream.tiedStream = s THEN
          otherStream.tiedStream := NIL; (* undo tie operation *)
        END;
        otherStream := otherStream.next;
      END;
      (* s.lock remains TRUE to prevent further operations *)
      Resources.Notify(s, Resources.terminated);
      RETURN ~s.error
    ELSE
      Error(s, NestedCall);
      RETURN FALSE
    END;
  END Close;

  PROCEDURE Release*(s: Stream);
  BEGIN
    IF ~Close(s) THEN END;
  END Release;

  PROCEDURE CloseAll*;
  BEGIN
    WHILE opened # NIL DO
      (* that's no endless loop; see Close/OldStream *)
      Release(opened);
    END;
  END CloseAll;

  PROCEDURE NotificationHandler(event: Events.Event);
    VAR
      s: Stream;
  BEGIN
    IF ~(event IS Resources.Event) THEN RETURN END;
    WITH event: Resources.Event DO
      IF ~(event.resource IS Stream) THEN RETURN END;
      s := event.resource(Stream);
      IF event.change IN {Resources.unreferenced, Resources.terminated} THEN
        IF ~s.lock THEN
          Release(s);
        END;
      END;
    END;
  END NotificationHandler;

  PROCEDURE Init*(s: Stream; if: Interface; caps: CapabilitySet;
            bufmode: BufMode);

    VAR
      eventType: Events.EventType;
      type: Services.Type;

    PROCEDURE InitBidirectionalBuffering(s: Stream);
    BEGIN
      s.validpos := TRUE;
      s.pos := 0;
      NewBuffer(s.wbuf);
      s.buf.ok := TRUE; s.buf.rbegin := 0; s.buf.rend := 0; s.buf.pos := 0;
      s.wbuf.ok := TRUE; s.wbuf.wbegin := 0; s.wbuf.wend := 0;
      s.wbuf.pos := 0;
      s.left := 0; s.write := bufsize;
    END InitBidirectionalBuffering;

  BEGIN
    ASSERT((s # NIL) & (if # NIL) & ({read, write} * caps # {}));
    Services.GetType(s, type); ASSERT(type # NIL);
    s.inlist := (close IN caps) OR (bufmode # nobuf) & (write IN caps);
    NewStream(s);
    (* initialize public part *)
    s.count := 0;
    s.errors := 0;
    s.error := FALSE;
    s.lasterror := 0;
    s.eof := FALSE;
    (* private part *)
    s.if := if; s.caps := caps;
    s.bufmode := bufmode;
    s.validpos := FALSE;
    s.left := 0; s.write := 0;
    s.tiedStream := NIL;
    IF bufmode IN {linebuf, onebuf, bufpool} THEN
      NewBuffer(s.buf);
      IF (bufmode = bufpool) & ~(seek IN caps) THEN
        bufmode := onebuf;
      END;
      CASE bufmode OF
      | linebuf:  s.termch := defaulttermch;
      | bufpool:  NEW(s.bufpool); InitBufPool(s);
      ELSE
      END;
      s.maxpos := 0;
      s.wextensible := {read, write, seek, tell, holes} * caps =
                  {read, write, seek, tell};
      s.bidirect := {read, write, seek, tell, trunc} * caps = {read, write};
      IF s.bidirect THEN
        InitBidirectionalBuffering(s);
      ELSE
        s.wbuf := NIL;
      END;
    ELSE
      s.buf := NIL;
      s.wbuf := NIL;
      s.wextensible := FALSE;
      s.bidirect := FALSE;
    END;
    s.flushEvent := NIL;
    s.closeEvent := NIL;
    Resources.TakeInterest(s, eventType);
    Events.Handler(eventType, NotificationHandler);
    s.lock := FALSE;
  END Init;

  PROCEDURE Send*(s: Stream; VAR message: Message);
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      IF handler IN s.caps THEN
        s.if.handler(s, message);
      ELSE
        Error(s, NoHandlerDefined);
      END;
      s.lock := FALSE;
    ELSE
      Error(s, NestedCall);
    END;
  END Send;

  (* === private i/o procedures ================================= *)

  PROCEDURE ValidPos(s: Stream);
  BEGIN
    IF ~s.validpos THEN
      IF tell IN s.caps THEN
        IF ~s.if.tell(s, s.pos) OR (s.pos < 0) THEN
          Error(s, TellFailed);
          s.pos := 0;
        END;
      ELSE
        s.pos := 0;
      END;
      s.rpos := s.pos;
      s.validpos := TRUE;
      s.left := 0;
      s.write := 0;
    END;
  END ValidPos;

  PROCEDURE InitBuf(s: Stream);
  BEGIN
    IF s.bufmode = bufpool THEN
      GetBuffer(s);
    ELSE
      s.buf.pos := s.pos - s.pos MOD bufsize;
      s.buf.wbegin := s.pos MOD bufsize;
      s.write := bufsize - s.buf.wbegin;
      s.buf.wend := s.buf.wbegin;
      s.buf.rbegin := s.buf.wbegin;
      s.buf.rend := s.buf.wbegin;
      s.left := 0;
      s.buf.ok := TRUE;
    END;
  END InitBuf;

  PROCEDURE FillBuf(s: Stream) : BOOLEAN;
    (* return FALSE on EOF or errors *)
    VAR
      offset, count: Count;
      posindex: Count; (* s.pos MOD bufsize *)

    PROCEDURE Fill(s: Stream; VAR offset, count: Count) : BOOLEAN;
      (* try to fill  buf.cont[offset]..buf.cont[offset+count-1];
        return FALSE on EOF;
        Fill always extends a read region:
        s.buf.rend is set to offset + the number of bytes read
      *)
      VAR
        linetermseen: BOOLEAN;
        byte: Byte;
    BEGIN
      IF s.eofFound THEN
        RETURN FALSE
      END;
      IF addrio IN s.caps THEN
        s.buf.rend := s.if.addrread(s, SYSTEM.ADR(s.buf.cont[offset]), count) +
                 offset;
      ELSIF bufio IN s.caps THEN
        s.buf.rend := s.if.bufread(s, s.buf.cont, offset, count) + offset;
      ELSIF s.bufmode = linebuf THEN
        s.buf.rend := offset; linetermseen := FALSE;
        WHILE ~linetermseen & (s.buf.rend < offset+count) &
            s.if.read(s, byte) DO
          s.buf.cont[s.buf.rend] := byte; INC(s.buf.rend);
          linetermseen := byte = s.termch;
        END;
        s.eofFound := ~linetermseen &
                  (s.buf.rend < offset+count); (* s.if.read failed? *)
      ELSE
        s.buf.rend := offset;
        WHILE (s.buf.rend < offset+count) &
            s.if.read(s, s.buf.cont[s.buf.rend]) DO
          INC(s.buf.rend);
        END;
        s.eofFound := s.buf.rend < offset+count; (* s.if.read failed? *)
      END;
      (* negative counts of addrread or bufread indicate read errors *)
      IF s.buf.rend < offset THEN
        (* note error and recover s.buf.rend *)
        Error(s, ReadFailed);
        s.buf.rend := offset;
      END;
      INC(s.rpos, s.buf.rend - offset);
      IF s.buf.rend > offset THEN
        DEC(count, s.buf.rend - offset);
        offset := s.buf.rend;
        RETURN TRUE
      ELSE
        s.eofFound := TRUE;
        RETURN FALSE
      END;
    END Fill;

  BEGIN (* FillBuf *)
    ValidPos(s);
    posindex := s.pos MOD bufsize;
    s.eofFound := FALSE;

    (* flush associated output streams (line buffered streams only) *)
    IF s.bufmode = linebuf THEN
      IF write IN s.caps THEN
        IF ~InternalFlush(s) THEN END;
      END;
      IF (s.tiedStream # NIL) & ~SYS.TAS(s.tiedStream.lock) THEN
        IF ~InternalFlush(s.tiedStream) THEN END;
        s.tiedStream.lock := FALSE;
      END;
    END;

    (* get a valid buffer and set
      offset and count to the buffer range which is to be filled;
      on default, we want to fill the whole buffer
    *)
    offset := 0; count := bufsize; (* default *)
    IF ~s.buf.ok THEN
      InitBuf(s);
    ELSIF s.bidirect THEN
      s.buf.rbegin := 0; s.buf.rend := 0; s.pos := 0; posindex := 0;
    ELSE
      IF s.bufmode = bufpool THEN
        GetBuffer(s);
        IF s.left > 0 THEN
          (* buffer is already filled *)
          s.eof := FALSE; RETURN TRUE
        END;
      ELSIF s.buf.pos # s.pos - posindex THEN
        (* reuse filled buffer *)
        IF write IN s.caps THEN
          IF ~InternalFlush(s) THEN END;
        END;
        InitBuf(s);
      END;
      IF s.buf.rbegin # s.buf.rend THEN
        IF (write IN s.caps) &
            (s.buf.wbegin <= posindex) & (s.buf.wend > posindex) THEN
          (* set read region to write region *)
          s.buf.rbegin := s.buf.wbegin; s.buf.rend := s.buf.wend;
          s.left := s.buf.wend - posindex;
          s.eof := FALSE; RETURN TRUE
        ELSIF s.buf.rend = posindex THEN
          (* stream position equals end of read region *)
          offset := s.buf.rend; count := bufsize - offset;
        END;
      END;

      (* take care of the write region by limiting count;
        note that s.pos does *not* point into the write region;
        this is guaranteed by WritePart and other operations
        which would have extended the read region in such a case
      *)
      IF (write IN s.caps) & (s.buf.wbegin # s.buf.wend) THEN
        IF s.buf.wbegin >= offset THEN
          IF s.buf.wbegin > posindex THEN
            (* write-region behind current position *)
            count := s.buf.wbegin - offset;
          ELSE
            (* write-region before current position *)
            offset := s.buf.wend; count := bufsize - offset;
          END;
        END;
        IF (s.buf.pos + s.buf.wbegin = s.rpos) & ~(seek IN s.caps) THEN
          (* flush if the start of write region corresponds to real
            file position and we are not able to change the position
          *)
          IF ~InternalFlush(s) THEN END;
        END;
      END;
    END;

    (* set the real position to the position we want to read from *)
    IF ~s.bidirect & (s.buf.pos + offset # s.rpos) THEN
      IF (seek IN s.caps) & s.if.seek(s, s.buf.pos+offset, fromStart) THEN
        s.rpos := s.buf.pos + offset;
      ELSIF s.pos = s.rpos THEN
        DEC(count, posindex - offset);
        offset := posindex;
      ELSIF seek IN s.caps THEN
        Error(s, SeekFailed); RETURN FALSE
      ELSE
        Error(s, CannotSeek); RETURN FALSE
      END;
    END;

    (* try to fill buf[offset..offset+count-1];
      and set s.buf.rbegin & s.buf.rend to the new read region
    *)
    IF s.buf.rend # offset THEN
      (* forget old read region if we cannot extend it *)
      s.buf.rbegin := offset; s.buf.rend := offset;
    END;
    WHILE Fill(s, offset, count) & (posindex >= s.buf.rend) DO END;

    IF posindex >= s.buf.rend THEN
      (* read operation failed *)
      IF (s.pos > s.rpos) &
          (seek IN s.caps) & s.if.seek(s, s.pos, fromStart) THEN
        s.rpos := s.pos;
        (* second try: we were not able to fill the whole buffer
          but perhaps we are able to read what we were requested for
        *)
        DEC(count, posindex - offset);
        offset := posindex;
        s.buf.rbegin := offset; s.buf.rend := offset;
        s.eofFound := FALSE; (* retry it *)
        s.eof := ~Fill(s, offset, count);
      ELSE
        s.eof := TRUE;
      END;
    ELSE
      s.eof := FALSE;
    END;

    IF s.eof THEN
      s.left := 0;
    ELSE
      s.left := s.buf.rend - posindex;
    END;

    RETURN ~s.eof
  END FillBuf;


  (* ==== i/o operations ============================================== *)

  PROCEDURE ReadPart*(s: Stream; VAR buf: ARRAY OF Byte;
               off, cnt: Count) : BOOLEAN;
    (* fill buf[off..off+cnt-1] *)

    VAR
      pos: Count;
      partcnt: Count;

    PROCEDURE ReadBytesFromBuf(s: Stream;
                      VAR to: ARRAY OF Byte;
                      off, cnt: Count) : BOOLEAN;
      VAR
        bytes, max, spos: Count;
    BEGIN
      IF s.left = 0 THEN
        IF s.eofFound OR ~FillBuf(s) THEN RETURN FALSE END;
      END;
      spos := s.pos MOD bufsize;
      max := s.left;
      IF max > cnt THEN
        max := cnt;
      END;
      bytes := 0;
      WHILE bytes < max DO
        to[off] := s.buf.cont[spos];
        INC(off); INC(spos); INC(bytes);
      END;
      INC(s.pos, bytes); DEC(s.left, bytes); INC(s.count, bytes);
      IF ~s.bidirect THEN
        IF s.write >= bytes THEN
          DEC(s.write, bytes);
        ELSE
          s.write := 0;
        END;
      END;
      RETURN TRUE
    END ReadBytesFromBuf;

  BEGIN (* ReadPart *)
    IF SYS.TAS(s.lock) THEN
      Error(s, NestedCall);
      RETURN FALSE
    END;
    s.error := FALSE; s.count := 0;
    IF ~(read IN s.caps) THEN
      s.lock := FALSE; Error(s, CannotRead); RETURN FALSE
    ELSIF (off < 0) OR (off+cnt > LEN(buf)) OR (cnt < 0) THEN
      s.lock := FALSE; Error(s, BadParameters); RETURN FALSE
    END;
    IF cnt = 0 THEN s.lock := FALSE; RETURN TRUE END;
    IF s.buf # NIL THEN
      s.eofFound := FALSE;
      WHILE (s.count < cnt) &
          ReadBytesFromBuf(s, buf, s.count + off, cnt - s.count) DO
        (* s.count is already incremented by ReadBytesFromBuf *)
      END;
      (* extend write region, if necessary *)
      IF ~s.bidirect THEN
        pos := s.pos MOD bufsize;
        IF (s.write > 0) & (s.buf.wend < pos) THEN
          IF s.buf.wbegin = s.buf.wend THEN
            s.buf.wbegin := pos;
          END;
          s.buf.wend := pos;
        END;
      END;
    ELSE
      IF addrio IN s.caps THEN
        s.count := s.if.addrread(s, SYSTEM.ADR(buf[off]), cnt);
        IF (s.count > 0) & (s.count < cnt) THEN
          LOOP
            partcnt := s.if.addrread(s,
              SYSTEM.ADR(buf[off + s.count]), cnt - s.count);
            IF (partcnt < 0) OR (partcnt = 0) THEN EXIT END;
            ASSERT(partcnt <= cnt - s.count);
            INC(s.count, partcnt);
            IF s.count = cnt THEN EXIT END;
          END;
        END;
      ELSIF bufio IN s.caps THEN
        s.count := s.if.bufread(s, buf, off, cnt);
        IF (s.count > 0) & (s.count < cnt) THEN
          LOOP
            partcnt := s.if.bufread(s, buf, off + s.count, cnt - s.count);
            IF (partcnt < 0) OR (partcnt = 0) THEN EXIT END;
            ASSERT(partcnt <= cnt - s.count);
            INC(s.count, partcnt);
            IF s.count = cnt THEN EXIT END;
          END;
        END;
      ELSE
        s.count := 0;
        WHILE (s.count < cnt) & s.if.read(s, buf[s.count+off]) DO
          INC(s.count);
        END;
      END;
      IF s.count < 0 THEN
        s.count := 0;
        Error(s, ReadFailed);
      ELSE
        s.eof := s.count = 0;
      END;
    END;
    s.lock := FALSE;
    RETURN s.count = cnt
  END ReadPart;

  PROCEDURE Read*(s: Stream; VAR buf: ARRAY OF Byte) : BOOLEAN;
  BEGIN
    RETURN ReadPart(s, buf, 0, LEN(buf))
  END Read;

  PROCEDURE ReadByte*(s: Stream; VAR byte: Byte) : BOOLEAN;
    VAR
      ok: BOOLEAN;
      pos: Count;
  BEGIN
    IF SYS.TAS(s.lock) THEN
      Error(s, NestedCall); RETURN FALSE
    END;
    s.error := FALSE;
    IF s.left = 0 THEN
      IF ~(read IN s.caps) THEN
        s.lock := FALSE; Error(s, CannotRead); s.count := 0; RETURN FALSE
      END;
      IF s.buf # NIL THEN
        IF ~FillBuf(s) THEN
          (* FillBuf sets s.eof *)
          s.lock := FALSE;
          s.count := 0;
          RETURN FALSE
        END;
      ELSE
        ok := s.if.read(s, byte);
        IF ok THEN
          s.count := 1;
        ELSE
          s.count := 0;
        END;
        s.eof := ~ok;
        s.lock := FALSE;
        RETURN ok
      END;
    END;
    (* s.left > 0 *)
    s.count := 1;
    byte := s.buf.cont[s.pos MOD bufsize];
    INC(s.pos); DEC(s.left);
    IF ~s.bidirect & (s.write # 0) THEN
      DEC(s.write);
      pos := s.pos MOD bufsize;
      IF s.buf.wend < pos THEN
        IF s.buf.wbegin = s.buf.wend THEN
          s.buf.wbegin := pos;
        END;
        s.buf.wend := pos;
      END;
    END;
    (* s.eof has been set by FillBuf *)
    s.lock := FALSE;
    RETURN TRUE
  END ReadByte;

  PROCEDURE ReadPacket*(s: Stream; VAR buf: ARRAY OF Byte;
                off, maxcnt: Count) : Count;
    (* fill buf[off..] with next packet *)
  BEGIN
    IF s.left > 0 THEN
      IF maxcnt > s.left THEN
        maxcnt := s.left;
      END;
      IF ReadPart(s, buf, off, maxcnt) THEN END;
      RETURN s.count
    END;

    IF SYS.TAS(s.lock) THEN
      Error(s, NestedCall);
      s.count := 0;
      RETURN 0
    END;
    s.error := FALSE; s.count := 0;
    IF ~(read IN s.caps) THEN
      s.lock := FALSE; Error(s, CannotRead); s.count := 0; RETURN 0
    ELSIF (off < 0) OR (off+maxcnt > LEN(buf)) OR (maxcnt < 0) THEN
      s.lock := FALSE; Error(s, BadParameters); s.count := 0; RETURN 0
    END;
    IF maxcnt = 0 THEN s.lock := FALSE; RETURN 0 END;

    IF s.buf # NIL THEN
      (* s.left = 0 *)
      IF ~FillBuf(s) THEN
        (* FillBuf sets s.eof *)
        s.lock := FALSE;
        RETURN 0
      END;
      s.lock := FALSE;
      IF maxcnt > s.left THEN
        maxcnt := s.left;
      END;
      IF ReadPart(s, buf, off, maxcnt) THEN END;
      RETURN s.count
    END;

    (* s.buf = NIL *)
    IF addrio IN s.caps THEN
      s.count := s.if.addrread(s, SYSTEM.ADR(buf[off]), maxcnt);
    ELSIF bufio IN s.caps THEN
      s.count := s.if.bufread(s, buf, off, maxcnt);
    ELSE
      s.count := 0;
      WHILE (s.count < maxcnt) & s.if.read(s, buf[s.count+off]) DO
        INC(s.count);
      END;
    END;
    IF s.count < 0 THEN
      s.count := 0;
      Error(s, ReadFailed);
    ELSE
      s.eof := s.count = 0;
    END;
    s.lock := FALSE;
    RETURN s.count
  END ReadPacket;

  PROCEDURE WritePart*(s: Stream;
                (* read-only *) VAR buf: ARRAY OF Byte;
                off, cnt: Count) : BOOLEAN;
    (* write buf[off..off+cnt-1] to s *)
    VAR
      posindex: Count;

    PROCEDURE NewBuffer(s: Stream) : BOOLEAN;
      (* flush and get new buffer *)
    BEGIN
      IF s.pos - posindex # s.buf.pos THEN
        IF s.bufmode # bufpool THEN
          IF ~InternalFlush(s) THEN RETURN FALSE END;
        END;
        InitBuf(s);
        IF s.write # 0 THEN RETURN TRUE END;
      END;
      IF s.buf.wbegin = s.buf.wend THEN
        (* nothing written into this buffer until now *)
        s.buf.wbegin := posindex; s.buf.wend := posindex;
        s.write := bufsize - posindex;
      ELSIF s.wextensible & (s.buf.rbegin # s.buf.rend) THEN
        (* check if the write region may be extended
          over parts of the read region
        *)
        IF s.buf.wend < posindex THEN
          (* write region before current position *)
          IF (s.buf.rbegin <= s.buf.wend) & (s.buf.rend >= posindex) THEN
            s.buf.wend := posindex;
            s.write := bufsize - posindex;
          END;
        ELSE (* s.wbegin > posindex *)
          (* write region after current position *)
          IF (s.buf.rbegin <= posindex) & (s.buf.rend >= s.buf.wbegin) THEN
            s.buf.wbegin := posindex;
            s.write := bufsize - posindex;
          END;
        END;
      END;
      IF (* still *) s.write = 0 THEN
        (* Flush necessary *)
        IF ~InternalFlush(s) THEN RETURN FALSE END;
        s.buf.wbegin := posindex; s.buf.wend := posindex;
        s.write := bufsize - posindex;
      END;
      RETURN TRUE
    END NewBuffer;

    PROCEDURE UpdateReadRegion(s: Stream);
    BEGIN
      (* update s.left and extend read region, if possible *)
      IF s.buf.rbegin = s.buf.rend THEN
        (* set read region to write region *)
        s.buf.rbegin := s.buf.wbegin; s.buf.rend := s.buf.wend;
        s.left := s.buf.rend - posindex;
      ELSIF (s.buf.rbegin < s.buf.wbegin) & (s.buf.rend >= s.buf.wbegin) THEN
        (* forward extension of read region possible *)
        IF s.buf.rend < s.buf.wend THEN
          s.buf.rend := s.buf.wend;
        END;
        s.left := s.buf.rend - posindex;
      ELSIF (s.buf.rbegin <= s.buf.wend) & (s.buf.rend > s.buf.wend) THEN
        (* backward extension of read region possible *)
        IF s.buf.rbegin > s.buf.wbegin THEN
          s.buf.rbegin := s.buf.wend;
        END;
        s.left := s.buf.rend - posindex;
      ELSE
        (* posindex does not fall into [s.buf.rbegin..s.buf.rend-1] *)
        s.left := 0;
      END;
      IF s.pos = s.buf.pos + bufsize THEN
        s.left := 0;
      END;
    END UpdateReadRegion;

  BEGIN
    IF SYS.TAS(s.lock) THEN
      Error(s, NestedCall); RETURN FALSE
    END;
    s.error := FALSE; s.count := 0;
    IF ~(write IN s.caps) THEN
      s.lock := FALSE; Error(s, CannotWrite); RETURN FALSE
    ELSIF (off < 0) OR (off+cnt > LEN(buf)) OR (cnt < 0) THEN
      s.lock := FALSE; Error(s, BadParameters); RETURN FALSE
    ELSIF cnt = 0 THEN
      s.lock := FALSE; RETURN TRUE
    END;

    IF s.buf # NIL THEN
      IF s.bidirect THEN
        WHILE s.count < cnt DO
          IF (s.write = 0) & ~InternalFlush(s) THEN
            s.lock := FALSE; RETURN FALSE
          END;
          s.wbuf.cont[s.wbuf.wend] := buf[off + s.count];
          INC(s.wbuf.wend); INC(s.count); DEC(s.write);
          IF (s.bufmode = linebuf) &
              (buf[s.count+off-1] = s.termch) THEN
            IF ~InternalFlush(s) THEN
              s.lock := FALSE; RETURN FALSE
            END;
          END;
        END;
      ELSE
        ValidPos(s);
        posindex := s.pos MOD bufsize;
        IF ~s.buf.ok THEN
          InitBuf(s);
        END;

        (* copy from buf to s.buf *)
        WHILE s.count < cnt DO
          IF s.write = 0 THEN
            posindex := s.pos MOD bufsize;
            IF s.count > 0 THEN
              UpdateReadRegion(s);
            END;
            IF ~NewBuffer(s) THEN
              s.lock := FALSE; RETURN FALSE
            END;
          END;
          s.buf.cont[posindex] := buf[off + s.count];
          IF s.buf.wend = posindex THEN
            INC(s.buf.wend);
          END;
          INC(s.count); INC(s.pos); DEC(s.write); INC(posindex);
          IF (s.bufmode = linebuf) &
              (buf[s.count+off-1] = s.termch) THEN
            UpdateReadRegion(s);
            IF ~InternalFlush(s) THEN
              s.lock := FALSE; RETURN FALSE
            END;
            (* s.pos can be changed by InternalFlush *)
            posindex := s.pos MOD bufsize;
          END;
        END;
        UpdateReadRegion(s);
      END;
    ELSE (* unbuffered stream *)
      IF addrio IN s.caps THEN
        s.count := s.if.addrwrite(s, SYSTEM.ADR(buf[off]), cnt);
      ELSIF bufio IN s.caps THEN
        s.count := s.if.bufwrite(s, buf, off, cnt);
      ELSE
        s.count := 0;
        WHILE (s.count < cnt) & s.if.write(s, buf[off+s.count]) DO
          INC(s.count);
        END;
      END;
      IF s.count # cnt THEN
        Error(s, WriteFailed);
      END;
    END;
    s.lock := FALSE;
    RETURN s.count = cnt
  END WritePart;

  PROCEDURE Write*(s: Stream;
             (* read-only *) VAR buf: ARRAY OF Byte) : BOOLEAN;
  BEGIN
    RETURN WritePart(s, buf, 0, LEN(buf))
  END Write;

  PROCEDURE WritePartC*(s: Stream; buf: ARRAY OF Byte;
                off, cnt: Count) : BOOLEAN;
    (* write buf[off..off+cnt-1] to s *)
  BEGIN
    RETURN WritePart(s, buf, off, cnt)
  END WritePartC;

  PROCEDURE WriteC*(s: Stream; buf: ARRAY OF Byte) : BOOLEAN;
  BEGIN
    RETURN WritePart(s, buf, 0, LEN(buf))
  END WriteC;

  PROCEDURE WriteByte*(s: Stream; byte: Byte) : BOOLEAN;
    VAR
      posindex: Count;
  BEGIN
    IF (s.write > 0) & ~SYS.TAS(s.lock) THEN
      s.error := FALSE; s.count := 1;

      IF s.bidirect THEN
        s.wbuf.cont[s.wbuf.wend] := byte; INC(s.wbuf.wend); DEC(s.write);
      ELSE
        (* put byte into s.buf *)
        posindex := s.pos MOD bufsize;
        s.buf.cont[posindex] := byte;
        IF s.buf.wend = posindex THEN
          INC(s.buf.wend);
        END;
        DEC(s.write);

        (* update s.buf.rend and s.left, if necessary *)
        IF s.buf.rend = posindex THEN
          INC(s.buf.rend);
        END;
        IF s.left # 0 THEN
          DEC(s.left);
        ELSIF s.buf.rbegin = s.buf.rend THEN
          (* set read-region to write-region *)
          s.buf.rbegin := s.buf.wbegin; s.buf.rend := s.buf.wend;
          s.left := s.buf.wend - posindex;
        END;

        INC(s.pos);
      END;

      IF (s.bufmode = linebuf) & (byte = s.termch) THEN
        IF ~InternalFlush(s) THEN
          s.lock := FALSE; RETURN FALSE
        END;
        IF ~s.bidirect THEN
          s.buf.wbegin := s.pos MOD bufsize;
        END;
      END;

      s.lock := FALSE; RETURN TRUE
    ELSE
      RETURN WritePart(s, byte, 0, 1)
    END;
  END WriteByte;

  PROCEDURE InternalSeek(s: Stream; offset: Count; whence: Whence) : BOOLEAN;
    VAR
      oldpos: Count; pos: Count;
  BEGIN
    s.error := FALSE;
    IF s.bidirect THEN
      Error(s, CannotSeek); RETURN FALSE
    ELSIF s.buf = NIL THEN
      IF ~(seek IN s.caps) THEN
        Error(s, CannotSeek); RETURN FALSE
      ELSIF ~s.if.seek(s, offset, whence) THEN
        Error(s, SeekFailed); RETURN FALSE
      END;
    ELSE
      IF ~s.validpos & (seek IN s.caps) THEN
        IF (write IN s.caps) & ~InternalFlush(s) THEN END;
        IF ~s.if.seek(s, offset, whence) THEN
          Error(s, SeekFailed); RETURN FALSE
        END;
        IF whence = fromStart THEN
          s.validpos := TRUE;
          s.pos := offset; s.rpos := offset;
        END;
      ELSE
        ValidPos(s); oldpos := s.pos;
        IF s.pos > s.maxpos THEN
          s.maxpos := s.pos;
        END;
        CASE whence OF
        | fromStart:   IF offset < 0 THEN
                    Error(s, SeekFailed); RETURN FALSE
                  END;
                  s.pos := offset;
        | fromPos:     IF s.pos + offset < 0 THEN
                    Error(s, SeekFailed); RETURN FALSE
                  END;
                  INC(s.pos, offset);
        | fromEnd:     IF (write IN s.caps) & ~InternalFlush(s) THEN END;
                  IF ~(seek IN s.caps) OR
                    ~s.if.seek(s, offset, whence) THEN
                    Error(s, SeekFailed); RETURN FALSE
                  END;
                  s.validpos := FALSE; ValidPos(s);
        ELSE
          Error(s, BadWhence); RETURN FALSE
        END;
        IF ~(holes IN s.caps) & (s.pos > s.maxpos) THEN
          (* if holes are not permitted
            we need to check the new position
          *)
          IF ~(seek IN s.caps) THEN
            Error(s, CannotSeek); RETURN FALSE
          ELSIF s.if.seek(s, s.pos, fromStart) THEN
            s.rpos := s.pos; s.maxpos := s.pos;
          ELSE
            Error(s, SeekFailed); RETURN FALSE
          END;
        END;
        IF s.buf.ok & (s.pos # oldpos) THEN
          (* set s.left and s.write *)
          IF (s.pos < s.buf.pos) OR (s.pos >= s.buf.pos + bufsize) THEN
            s.left := 0; s.write := 0;
          ELSE
            pos := s.pos MOD bufsize;
            IF s.buf.rbegin = s.buf.rend THEN
              s.buf.rbegin := pos; s.buf.rend := pos;
            END;
            IF s.buf.wbegin = s.buf.wend THEN
              s.buf.wbegin := pos; s.buf.wend := pos;
            END;
            IF s.pos > oldpos THEN
              IF (pos >= s.buf.rbegin) & (pos < s.buf.rend) THEN
                s.left := s.buf.rend - pos;
              ELSE
                s.left := 0;
              END;
              IF (pos >= s.buf.wbegin) & (pos <= s.buf.wend) THEN
                s.write := bufsize - pos;
              ELSE
                s.write := 0;
              END;
              IF s.wextensible &
                  (s.write < s.left) & (s.buf.wbegin # s.buf.wend) THEN
                (* s.write = 0 (else s.write >= s.left);
                  try to extend write-region to avoid
                  an unnecessary flush operation
                *)
                IF (s.buf.wbegin < pos) &
                    (s.buf.wend >= s.buf.rbegin) THEN
                  (* write-region is followed by read-region *)
                  s.buf.wend := pos; s.write := bufsize - pos;
                ELSIF (pos < s.buf.wbegin) &
                    (s.buf.wbegin >= s.buf.rend) THEN
                  (* read-region is followed by write-region *)
                  s.buf.wbegin := pos; s.write := bufsize - pos;
                END;
              END;
            ELSE (* s.pos < oldpos *)
              IF (pos < s.buf.rbegin) OR (pos > s.buf.rend) THEN
                s.left := 0;
              ELSE
                s.left := s.buf.rend - pos;
              END;
              IF (pos < s.buf.wbegin) OR (pos > s.buf.wend) THEN
                s.write := 0;
              ELSE
                s.write := bufsize - pos;
              END;
            END;
          END;
        END;
      END;
    END;
    IF s.left > 0 THEN
      s.eof := FALSE;
    END;
    RETURN TRUE
  END InternalSeek;

  PROCEDURE Seek*(s: Stream; offset: Count; whence: Whence) : BOOLEAN;
    VAR
      rval: BOOLEAN;
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      rval := InternalSeek(s, offset, whence);
      s.lock := FALSE;
      RETURN rval
    ELSE
      Error(s, NestedCall);
      RETURN FALSE
    END;
  END Seek;

  PROCEDURE Tell*(s: Stream; VAR offset: Count) : BOOLEAN;
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      s.error := FALSE;
      IF tell IN s.caps THEN
        IF s.buf # NIL THEN
          IF s.validpos THEN
            offset := s.pos;
          ELSIF s.if.tell(s, s.rpos) THEN
            s.validpos := TRUE;
            s.pos := s.rpos;
            offset := s.pos;
          ELSE
            s.lock := FALSE;
            Error(s, TellFailed);
          END;
        ELSIF ~s.if.tell(s, offset) THEN
          s.lock := FALSE;
          Error(s, TellFailed);
        END;
      ELSE
        s.lock := FALSE;
        Error(s, CannotTell);
      END;
      s.lock := FALSE;
    ELSE
      Error(s, NestedCall);
    END;
    RETURN ~s.error
  END Tell;

  PROCEDURE GetPos*(s: Stream; VAR offset: Count);
    (* IF ~Tell(s, offset) THEN offset := internal position END; *)
  BEGIN
    IF ~Tell(s, offset) THEN
      IF SYS.TAS(s.lock) THEN
        Error(s, NestedCall);
      ELSE
        ValidPos(s);
        offset := s.pos;
        s.lock := FALSE;
      END;
    END;
  END GetPos;

  PROCEDURE SetPos*(s: Stream; offset: Count);
    (* IF ~Seek(s, offset, fromStart) THEN END; *)
  BEGIN
    IF ~Seek(s, offset, fromStart) THEN END;
  END SetPos;

  PROCEDURE ^ Touch*(s: Stream);

  PROCEDURE Trunc*(s: Stream; length: Count) : BOOLEAN;
    (* truncate `s' to a total length of `length';
      following holds if holes are permitted:
        (1) the current position remains unchanged
        (2) the contents between `length' and
           the current position is undefined
      this call fails if holes are not permitted and the
      current position is beyond `length'
    *)
    VAR
      ok: BOOLEAN;
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      IF (trunc IN s.caps) & (length >= 0) THEN
        s.error := FALSE; ok := TRUE;
        IF s.buf # NIL THEN
          ValidPos(s);
          IF ~(holes IN s.caps) & (s.pos > length) THEN
            ok := FALSE;
          ELSIF (s.bufmode = bufpool) OR s.buf.ok &
              (s.buf.pos DIV bufsize >= length DIV bufsize) THEN
            Touch(s);
          END;
        END;
        IF ~ok OR ~s.if.trunc(s, length) THEN
          s.lock := FALSE; Error(s, TruncFailed);
        END;
      ELSE
        s.lock := FALSE; Error(s, CannotTrunc);
      END;
      s.lock := FALSE;
    ELSE
      Error(s, NestedCall);
    END;
    RETURN ~s.error
  END Trunc;

  PROCEDURE Back*(s: Stream) : BOOLEAN;
    (* undo last read operation (one byte);
      because of the delayed buffer filling
      Back is always successful for buffered streams
      immediately after read-operations
    *)
    VAR
      rval: BOOLEAN;
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      s.error := FALSE;
      IF read IN s.caps THEN
        IF seek IN s.caps THEN
          (* fails if s.pos = 0 *)
          rval := InternalSeek(s, -1, 1)
        ELSIF s.bidirect & s.buf.ok THEN
          IF s.pos > 0 THEN
            DEC(s.pos); INC(s.left);
            rval := TRUE;
          ELSE
            rval := FALSE;
          END;
        ELSIF (s.buf # NIL) & s.buf.ok THEN
          rval := InternalSeek(s, -1, 1) & (s.left > 0)
        ELSE
          rval := FALSE
        END;
      ELSE
        s.lock := FALSE; Error(s, CannotRead);
        rval := FALSE
      END;
      s.lock := FALSE;
      RETURN rval
    ELSE
      Error(s, NestedCall);
      RETURN FALSE
    END;
  END Back;

  PROCEDURE Insert*(s: Stream; byte: Byte) : BOOLEAN;
    (* return `byte' on next read-operation *)
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      s.error := FALSE;
      IF read IN s.caps THEN
        IF s.buf # NIL THEN
          (* seek in buffer possible? *)
          IF s.bidirect THEN
            IF s.pos > 0 THEN
              DEC(s.pos); s.buf.cont[s.pos] := byte;
              RETURN TRUE
            ELSE
              RETURN FALSE
            END;
          ELSIF s.buf.ok &
            (s.pos > s.buf.pos+s.buf.rbegin) &
            (s.pos < s.buf.pos+s.buf.rend) &
            InternalSeek(s, -1, 1) THEN
            s.buf.cont[s.pos MOD bufsize] := byte;
            s.lock := FALSE;
            RETURN TRUE
          ELSE
            s.lock := FALSE;
            RETURN FALSE
          END;
        ELSE
          s.lock := FALSE; Error(s, Unbuffered); RETURN FALSE
        END;
      ELSE
        s.lock := FALSE; Error(s, CannotRead); RETURN FALSE
      END;
    ELSE
      Error(s, NestedCall);
      RETURN FALSE
    END;
  END Insert;

  PROCEDURE InternalFlush(s: Stream) : BOOLEAN;

    PROCEDURE Write(s: Stream; buf: Buffer) : BOOLEAN;

      VAR
        count: Count;
    BEGIN
      IF addrio IN s.caps THEN
        count := s.if.addrwrite(s, SYSTEM.ADR(buf.cont[buf.wbegin]),
                        buf.wend-buf.wbegin);
      ELSIF bufio IN s.caps THEN
        count := s.if.bufwrite(s, buf.cont,
                        buf.wbegin, buf.wend-buf.wbegin);
      ELSIF s.if.write(s, buf.cont[buf.wbegin]) THEN
        count := 1;
      ELSE
        count := 0;
      END;
      IF count < 0 THEN
        count := 0;
      END;
      INC(buf.wbegin, count); INC(s.rpos, count);
      RETURN count > 0
    END Write;

    PROCEDURE FlushEvent;
      VAR
        event: Event;
    BEGIN
      IF s.flushEvent # NIL THEN
        NEW(event);
        event.type := s.flushEvent;
        event.message := "flush event of Streams";
        event.stream := s;
        Events.Raise(event);
      END;
    END FlushEvent;

  BEGIN
    s.error := FALSE;
    IF (write IN s.caps) & (s.buf # NIL) & s.buf.ok THEN
      IF s.bidirect & (s.wbuf.wend > s.wbuf.wbegin) THEN
        FlushEvent;
        WHILE (s.wbuf.wend > s.wbuf.wbegin) & Write(s, s.wbuf) DO END;
        IF s.wbuf.wend > s.wbuf.wbegin THEN
          s.wbuf.wbegin := 0; s.wbuf.wend := 0; s.write := bufsize;
          Error(s, WriteFailed); RETURN FALSE
        END;
        s.wbuf.wbegin := 0; s.wbuf.wend := 0; s.write := bufsize;
      ELSIF ~s.bidirect & (s.buf.wend > s.buf.wbegin) THEN
        FlushEvent;
        ValidPos(s);
        IF s.buf.pos + s.buf.wbegin # s.rpos THEN
          IF ~(seek IN s.caps) THEN
            Error(s, CannotSeek);
            (* write in this case at the current position
              else there is no easy way to write anyhow
            *)
          ELSIF ~s.if.seek(s, s.buf.pos + s.buf.wbegin, fromStart) THEN
            s.buf.wend := s.buf.wbegin; s.write := 0;
            Error(s, SeekFailed); RETURN FALSE
          END;
          s.rpos := s.buf.pos + s.buf.wbegin;
        END;
        WHILE (s.buf.wend > s.buf.wbegin) & Write(s, s.buf) DO END;
        IF s.buf.wend > s.buf.wbegin THEN
          s.buf.wend := s.buf.wbegin; s.write := bufsize - s.buf.wbegin;
          Error(s, WriteFailed); RETURN FALSE
        END;
        IF {seek, tell, trunc} * s.caps = {} THEN
          (* unidirectional pipeline; reset s.pos to avoid
            unintentional flushes due to buffer boundaries
          *)
          s.pos := 0; s.rpos := 0; s.buf.pos := 0;
          s.buf.wbegin := 0; s.buf.wend := 0; s.write := bufsize;
        ELSE
          IF (s.pos >= s.buf.pos) & (s.pos < s.buf.pos + bufsize) THEN
            s.buf.wbegin := s.pos MOD bufsize;
            s.buf.wend := s.buf.wbegin;
            s.write := bufsize - s.buf.wbegin;
          ELSE
            s.write := 0;
          END;
        END;
      END;
    END;
    RETURN TRUE
  END InternalFlush;

  PROCEDURE Flush*(s: Stream) : BOOLEAN;
    VAR
      ok: BOOLEAN;
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      IF s.bufmode = bufpool THEN
        ok := FlushBufPool(s);
      ELSE
        ok := InternalFlush(s);
      END;
      IF ok & (flush IN s.caps) THEN
        ok := s.if.flush(s);
        IF ~ok THEN
          Error(s, FlushFailed);
        END;
      END;
      s.lock := FALSE;
      RETURN ok
    ELSE
      Error(s, NestedCall);
      RETURN FALSE
    END;
  END Flush;

  PROCEDURE InputInBuffer*(s: Stream) : BOOLEAN;
    (* returns TRUE if the next byte to be read is buffered *)
    VAR
      buf: Buffer;
      pos: Count;
  BEGIN
    IF s.bufmode = bufpool THEN
      IF ~s.buf.ok THEN RETURN FALSE END;
      pos := s.pos - s.pos MOD bufsize;
      IF s.buf.pos # pos THEN
        IF ~FindBuffer(s, pos, buf) THEN
          RETURN FALSE
        END;
        pos := s.pos - buf.pos;
        RETURN (pos >= buf.rbegin) & (pos < buf.rend)
      END;
    ELSIF s.bidirect THEN
      RETURN s.left > 0
    END;
    pos := s.pos MOD bufsize;
    RETURN (read IN s.caps) & (s.buf # NIL) & s.buf.ok &
         ((s.left > 0) OR
          (write IN s.caps) & (s.buf.wbegin <= pos) & (s.buf.wend > pos))
  END InputInBuffer;

  PROCEDURE OutputInBuffer*(s: Stream) : BOOLEAN;
    (* returns TRUE if Flush would lead to a write-operation *)
    VAR
      buf: Buffer;
  BEGIN
    IF s.bufmode = bufpool THEN
      buf := s.bufpool.head;
      WHILE buf # NIL DO
        IF buf.wbegin # buf.wend THEN RETURN TRUE END;
        buf := buf.nexta;
      END;
      RETURN FALSE
    ELSIF s.bidirect THEN
      RETURN s.wbuf.wend > s.wbuf.wbegin
    ELSE
      RETURN (write IN s.caps) & (s.buf # NIL) & s.buf.ok &
           (s.buf.wend > s.buf.wbegin)
    END;
  END OutputInBuffer;

  PROCEDURE OutputWillBeBuffered*(s: Stream) : BOOLEAN;
    (* returns TRUE if the next written byte will be buffered *)
    VAR
      buf: Buffer;
      pos: Count;
  BEGIN
    IF s.bufmode = bufpool THEN
      IF s.bufpool.nbuf < s.bufpool.maxbuf THEN RETURN TRUE END;
      pos := s.pos - s.pos MOD bufsize;
      IF s.buf.pos # pos THEN
        IF ~FindBuffer(s, pos, buf) THEN RETURN FALSE END;
        IF s.buf.wbegin = s.buf.wend THEN RETURN TRUE END;
        pos := s.pos - buf.pos;
        RETURN (pos >= buf.wbegin) & (pos <= buf.wend) OR
             (buf.wbegin > 0) & (pos + 1 = buf.wbegin)
      END;
    ELSIF s.bidirect THEN
      RETURN s.write > 0
    END;
    RETURN (write IN s.caps) & (s.buf # NIL) &
         ((s.write > 0) OR ~s.buf.ok)
  END OutputWillBeBuffered;

  PROCEDURE Touch*(s: Stream);
    (* forget any buffer contents *)
  BEGIN
    IF ~SYS.TAS(s.lock) THEN
      s.error := FALSE;
      IF write IN s.caps THEN
        IF s.bufmode = bufpool THEN
          IF ~FlushBufPool(s) THEN END;
          ReleaseBufPool(s);
        ELSE
          IF ~InternalFlush(s) THEN END;
        END;
      END;
      IF flush IN s.caps THEN
        IF ~s.if.flush(s) THEN
          Error(s, FlushFailed);
        END;
      END;
      IF s.bidirect THEN
        s.buf.rbegin := 0; s.buf.rend := 0; s.left := 0;
      ELSE
        s.validpos := FALSE;
        IF s.buf # NIL THEN
          s.buf.ok := FALSE;
          s.left := 0;
          s.write := 0;
          s.eofFound := FALSE;
        END;
      END;
      s.lock := FALSE;
    ELSE
      Error(s, NestedCall);
    END;
  END Touch;

  PROCEDURE Copy*(source, dest: Stream; maxcnt: Count) : BOOLEAN;
    (* more efficient variants are possible *)
    VAR
      left, count, copied, read, written: Count;
      buffer: ARRAY bufsize OF Byte;
      ok: BOOLEAN;
  BEGIN
    IF maxcnt >= 0 THEN
      read := 0; written := 0; ok := TRUE;
      left := maxcnt;
      LOOP
        IF left = 0 THEN
          EXIT
        END;
        ASSERT(left > 0);
        IF left > bufsize THEN
          count := bufsize;
        ELSE
          count := left;
        END;

        ok := ReadPacket(source, buffer, 0, count) > 0;
        ASSERT(source.count <= count);
        INC(read, source.count);
        IF ~ok THEN EXIT END;

        ok := WritePart(dest, buffer, 0, source.count);
        ASSERT(dest.count <= source.count);
        INC(written, dest.count);
        IF ~ok THEN EXIT END;

        DEC(left, dest.count);
      END;
      source.count := read; dest.count := written;
      RETURN ok
    ELSE
      copied := 0;
      WHILE (ReadPacket(source, buffer, 0, bufsize) > 0) &
          WritePart(dest, buffer, 0, source.count) DO
        INC(copied, source.count);
      END;
      source.count := copied; dest.count := copied;
      RETURN ~source.error & ~dest.error
    END;
  END Copy;

  (* === nulldev procedures ========================================== *)

  PROCEDURE NulldevRead(s: Stream; VAR byte: Byte) : BOOLEAN;
  BEGIN
    byte := 0X;
    RETURN FALSE
  END NulldevRead;

  PROCEDURE NulldevWrite(s: Stream; byte: Byte) : BOOLEAN;
  BEGIN
    RETURN TRUE
  END NulldevWrite;

  PROCEDURE InitNullIf(VAR nullif: Interface);
  BEGIN
    NEW(nullif);
    nullif.read := NulldevRead;
    nullif.write := NulldevWrite;
  END InitNullIf;

  PROCEDURE OpenNulldev(VAR s: Stream);
  BEGIN
    NEW(s);
    Services.Init(s, type);
    Init(s, nullif, {read, write}, nobuf);
  END OpenNulldev;

  PROCEDURE ExitHandler(event: Events.Event);
    (* flush all streams on exit;
      we do not close them to allow output by other exit event handlers
    *)
    VAR s: Stream;
  BEGIN
    s := opened;
    WHILE s # NIL DO
      IF (s.bufmode # nobuf) & (write IN s.caps) THEN
        IF ~Flush(s) THEN END;
      END;
      s := s.next;
    END;
  END ExitHandler;

  PROCEDURE FreeHandler(event: Events.Event);
    (* set all free lists to NIL to return the associated storage
      to the garbage collector
    *)
  BEGIN
    freelist := NIL;
  END FreeHandler;

BEGIN
  Services.CreateType(type, "Streams.Stream", "");

  errormsg[NoHandlerDefined] := "no handler defined";
  errormsg[CannotRead] := "not opened for reading";
  errormsg[CannotSeek] := "not capable of seeking";
  errormsg[CloseFailed] := "close operation failed";
  errormsg[NotLineBuffered] := "stream is not line buffered";
  errormsg[SeekFailed] := "seek operation failed";
  errormsg[TellFailed] := "tell operation failed";
  errormsg[BadWhence] := "bad value of whence parameter";
  errormsg[CannotTell] := "not capable of telling current position";
  errormsg[WriteFailed] := "write operation failed";
  errormsg[CannotWrite] := "not opened for writing";
  errormsg[ReadFailed] := "read operation failed";
  errormsg[Unbuffered] := "operation is not valid for unbuffered streams";
  errormsg[BadParameters] := "bad parameter values";
  errormsg[CannotTrunc] := "not capable of truncating";
  errormsg[TruncFailed] := "trunc operation failed";
  errormsg[NestedCall] := "nested stream operation";
  errormsg[FlushFailed] := "flush operation failed";

  Events.Define(error); Events.SetPriority(error, Priorities.liberrors);
  Events.Ignore(error);

  opened := NIL;
  InitNullIf(nullif);
  OpenNulldev(null); stdin := null; stdout := null; stderr := null;

  Events.Handler(Process.termination, ExitHandler);
  Events.Handler(Process.startOfGarbageCollection, FreeHandler);
END ulmStreams.
