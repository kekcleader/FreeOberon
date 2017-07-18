(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethZlibWriters;  (** Stefan Walthert  **)

IMPORT
  Files, Zlib := ethZlib, ZlibBuffers := ethZlibBuffers, ZlibDeflate := ethZlibDeflate;

CONST
  (** result codes **)
  Ok* = ZlibDeflate.Ok; StreamEnd* = ZlibDeflate.StreamEnd;
  StreamError* = ZlibDeflate.StreamError; DataError* = ZlibDeflate.DataError; BufError* = ZlibDeflate.BufError;

  (** flush values **)
  NoFlush* = ZlibDeflate.NoFlush;
  SyncFlush* = ZlibDeflate.SyncFlush;
  FullFlush* = ZlibDeflate.FullFlush;

  (** compression levels **)
  DefaultCompression* = ZlibDeflate.DefaultCompression; NoCompression* = ZlibDeflate.NoCompression; 
  BestSpeed* = ZlibDeflate.BestSpeed; BestCompression* = ZlibDeflate.BestCompression;
  
  (** compression strategies **)
  DefaultStrategy* = ZlibDeflate.DefaultStrategy; Filtered* = ZlibDeflate.Filtered; HuffmanOnly* = ZlibDeflate.HuffmanOnly;
  
  BufSize = 10000H;

TYPE
  (** structure for writing deflated data in a file **)
  Writer* = RECORD
    res-: LONGINT;  (** current stream state **)
    flush-: SHORTINT;  (** flush strategy **)
    wrapper-: BOOLEAN;  (** if set, zlib header and checksum are generated **)
    r: Files.Rider;  (* file rider *)
    pos: LONGINT;  (* logical position in uncompressed input stream *)
    crc32-: LONGINT;  (** crc32 of uncompressed data **)
    out: POINTER TO ARRAY BufSize OF CHAR;  (* output buffer space *)
    s: ZlibDeflate.Stream  (* compression stream *)
  END;


(** change deflate parameters within the writer **)
PROCEDURE SetParams*(VAR w: Writer; level, strategy, flush: SHORTINT);
BEGIN
  IF flush IN {NoFlush, SyncFlush, FullFlush} THEN
    ZlibDeflate.SetParams(w.s, level, strategy);
    w.flush := flush;
    w.res := w.s.res
  ELSE
    w.res := StreamError
  END
END SetParams;

(** open writer on a Files.Rider **)
PROCEDURE Open*(VAR w: Writer; level, strategy, flush: SHORTINT; wrapper: BOOLEAN; r: Files.Rider);
BEGIN
  IF flush IN {NoFlush, SyncFlush, FullFlush} THEN
    w.flush := flush;
    w.wrapper := wrapper;
    ZlibDeflate.Open(w.s, level, strategy, FALSE);
    IF w.s.res = Ok THEN
      NEW(w.out); ZlibBuffers.Init(w.s.out, w.out^, 0, BufSize, BufSize);
      w.crc32 := Zlib.CRC32(0, w.out^, -1, -1);
      w.r := r;
      w.res := Ok
    ELSE
      w.res := w.s.res
    END
  ELSE
    w.res := StreamError
  END
END Open;

(** write specified number of bytes from buffer into and return number of bytes actually written **)
PROCEDURE WriteBytes*(VAR w: Writer; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; VAR written: LONGINT);
BEGIN
  ASSERT((0 <= offset) & (0 <= len) & (len <= LEN(buf)), 110);
  IF ~w.s.open THEN
    w.res := StreamError; written := 0
  ELSIF (w.res < Ok) OR (len <= 0) THEN
    written := 0
  ELSE
    ZlibBuffers.Init(w.s.in, buf, offset, len, len);
    WHILE (w.res = Ok) & (w.s.in.avail # 0) DO
      IF (w.s.out.avail = 0) THEN
        Files.WriteBytes(w.r, w.out^, BufSize);
        ZlibBuffers.Rewrite(w.s.out)
      END;
      IF w.res = Ok THEN
        ZlibDeflate.Deflate(w.s, w.flush);
        w.res := w.s.res
      END
    END;
    w.crc32 := Zlib.CRC32(w.crc32, buf, offset, len - w.s.in.avail);
    written := len - w.s.in.avail
  END;
END WriteBytes;

(** write byte **)
PROCEDURE Write*(VAR w: Writer; ch: CHAR);
VAR
  buf: ARRAY 1 OF CHAR;
  written: LONGINT;
BEGIN
  buf[0] := ch;
  WriteBytes(w, buf, 0, 1, written)
END Write;

(** close writer **)
PROCEDURE Close*(VAR w: Writer);
VAR
  done: BOOLEAN;
  len: LONGINT;
BEGIN
  ASSERT(w.s.in.avail = 0, 110);
  done := FALSE;
  LOOP
    len := BufSize - w.s.out.avail;
    IF len # 0 THEN
      Files.WriteBytes(w.r, w.out^, len);
      ZlibBuffers.Rewrite(w.s.out)
    END;
    IF done THEN EXIT END;
    ZlibDeflate.Deflate(w.s, ZlibDeflate.Finish);
    IF (len = 0) & (w.s.res = BufError) THEN
      w.res := Ok
    ELSE
      w.res := w.s.res
    END;
    done := (w.s.out.avail # 0) OR (w.res = StreamEnd);
    IF (w.res # Ok) & (w.res # StreamEnd) THEN EXIT END
  END;
  ZlibDeflate.Close(w.s);
  w.res := w.s.res
END Close;

(** compress srclen bytes from src to dst with specified level and strategy. dstlen returns how many bytes have been written. **)
PROCEDURE Compress*(VAR src, dst: Files.Rider; srclen: LONGINT; VAR dstlen: LONGINT; level, strategy: SHORTINT; VAR crc32: LONGINT; VAR res: LONGINT);
VAR
  w: Writer; buf: ARRAY BufSize OF CHAR; totWritten, written, read: LONGINT;
BEGIN
  Open(w, level, strategy, NoFlush, FALSE, dst);
  IF w.res = Ok THEN
    totWritten := 0;
    REPEAT
      IF (srclen - totWritten) >= BufSize THEN read := BufSize
      ELSE read := srclen - totWritten
      END;
      Files.ReadBytes(src, buf, read);
      WriteBytes(w, buf, 0, read - src.res, written);
      INC(totWritten, written)
    UNTIL (w.res # Ok) OR (totWritten >= srclen);
    Close(w);
    crc32 := w.crc32;
    dstlen := Files.Pos(w.r) - Files.Pos(dst);
  END;
  res := w.res
END Compress;
  

END ethZlibWriters.
