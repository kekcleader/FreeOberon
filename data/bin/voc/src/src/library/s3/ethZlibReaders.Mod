(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethZlibReaders;  (** Stefan Walthert  **)

IMPORT
  Files, Zlib := ethZlib, ZlibBuffers := ethZlibBuffers, ZlibInflate := ethZlibInflate;

CONST
  (** result codes **)
  Ok* = ZlibInflate.Ok; StreamEnd* = ZlibInflate.StreamEnd;
  FileError* = -1; StreamError* = ZlibInflate.StreamError; DataError* = ZlibInflate.DataError; BufError* = ZlibInflate.BufError;
  
  BufSize = 4000H;

TYPE
  (** structure for reading from a file with deflated data **)
  Reader* = RECORD
    res-: LONGINT;  (** current stream state **)
    crc32-: LONGINT;  (* crc32 of uncompressed data *)
    wrapper-: BOOLEAN;  (** if set, a zlib header and a checksum are present **) 
    eof: BOOLEAN;  (* set if at end of input file and input buffer empty *)
    r: Files.Rider;
    in: POINTER TO ARRAY BufSize OF CHAR;  (* input buffer space *)
    s: ZlibInflate.Stream;  (* decompression stream *)
  END;


(** open reader on a Rider for input; is wrapper is not set, no zlib header and no checksum are present **)
PROCEDURE Open*(VAR r: Reader; wrapper: BOOLEAN; VAR fr: Files.Rider);
BEGIN
  r.wrapper := wrapper;
  r.eof := fr.eof;
  ZlibInflate.Open(r.s, wrapper);
  IF r.s.res.code = ZlibInflate.Ok THEN
    NEW(r.in); ZlibBuffers.Init(r.s.in, r.in^, 0, BufSize, 0);
    r.crc32 := Zlib.CRC32(0, r.in^, -1, -1);
    r.r := fr;
    r.res := Ok
  ELSE
    r.res := r.s.res.code
  END
END Open;

(** read specified number of bytes into buffer and return number of bytes actually read **)
PROCEDURE ReadBytes*(VAR r: Reader; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; VAR read: LONGINT);
BEGIN
  ASSERT((0 <= offset) & (0 <= len) & (offset + len <= LEN(buf)), 100);
  IF ~r.s.open THEN
    r.res := StreamError; read := 0
  ELSIF (r.res < Ok) OR (r.res = StreamEnd) OR (len <= 0) THEN
    read := 0
  ELSE
    ZlibBuffers.Init(r.s.out, buf, offset, len, len);
    WHILE (r.s.out.avail # 0) & (r.res = Ok) DO
      IF r.s.in.avail = 0 THEN
        Files.ReadBytes(r.r, r.in^, BufSize);
        ZlibBuffers.Rewind(r.s.in, BufSize - r.r.res);
        IF r.s.in.avail = 0 THEN
          r.eof := TRUE;
          IF r.r.res < 0 THEN
            r.res := FileError
          END
        END
      END;
      IF r.res = Ok THEN
        ZlibInflate.Inflate(r.s, ZlibInflate.NoFlush);
        r.res := r.s.res.code
      END
    END;
    r.crc32 := Zlib.CRC32(r.crc32, buf, offset, len - r.s.out.avail);
    read := len - r.s.out.avail
  END
END ReadBytes;

(** read decompressed byte **)
PROCEDURE Read*(VAR r: Reader; VAR ch: CHAR);
VAR
  buf: ARRAY 1 OF CHAR; read: LONGINT;
BEGIN
  ReadBytes(r, buf, 0, 1, read);
  ch := buf[0]
END Read;

(** close reader **)
PROCEDURE Close*(VAR r: Reader);
BEGIN
  ZlibInflate.Close(r.s);
  r.in := NIL;
  IF r.res = StreamEnd THEN
    r.res := Ok
  END
END Close;

(** uncompress deflated data from scr and write them to dst **)
PROCEDURE Uncompress*(VAR src, dst: Files.Rider; VAR crc32: LONGINT; VAR res: LONGINT);
VAR
  r: Reader; buf: ARRAY BufSize OF CHAR; read: LONGINT;
BEGIN
  Open(r, FALSE, src);
  IF r.res = Ok THEN
    REPEAT
      ReadBytes(r, buf, 0, BufSize, read);
      Files.WriteBytes(dst, buf, read)
    UNTIL (r.res # Ok) OR (read = 0);
    crc32 := r.crc32;
    Close(r)
  END;
  res := r.res
END Uncompress;


END ethZlibReaders.
