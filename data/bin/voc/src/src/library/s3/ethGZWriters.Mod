(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethGZWriters;  (** Stefan Walthert  **)

IMPORT
  Files,  ZlibWriters := ethZlibWriters;

CONST
  (** result codes **)
  Ok* = ZlibWriters.Ok; StreamEnd* = ZlibWriters.StreamEnd;
  FileError* = -1; StreamError* = ZlibWriters.StreamError; DataError* = ZlibWriters.DataError; BufError* = ZlibWriters.BufError;
  
  (** compression levels **)
  DefaultCompression* = ZlibWriters.DefaultCompression; NoCompression* = ZlibWriters.NoCompression; 
  BestSpeed* = ZlibWriters.BestSpeed; BestCompression* = ZlibWriters.BestCompression;
  
  (** compression strategies **)
  DefaultStrategy* = ZlibWriters.DefaultStrategy; Filtered* = ZlibWriters.Filtered; HuffmanOnly* = ZlibWriters.HuffmanOnly;
    
  DeflateMethod = 8;

TYPE
  (** structure for writing to a .gz file **)
  Writer* = RECORD
    file-: Files.File;  (** underlying Oberon file **)
    res-: LONGINT;  (** current stream state **)
    start: LONGINT;  (* start of compressed data in file (after header) *)
    pos: LONGINT;  (* logical position in uncompressed input stream *)
    zw: ZlibWriters.Writer;
  END;


PROCEDURE WriteHeader(VAR w: Writer; VAR r: Files.Rider);
VAR
  i: INTEGER;
BEGIN
  Files.Write(r, 1FX); INC(w.start);  (* ID1 *)
  Files.Write(r, 8BX); INC(w.start);  (* ID2 *)
  Files.Write(r, CHR(DeflateMethod));  (* CM (Compression Method) *)
  FOR i := 0 TO 6 DO Files.Write(r, 0X); INC(w.start) END;
END WriteHeader;

(** change deflate parameters within the writer **)
PROCEDURE SetParams*(VAR w: Writer; level, strategy: SHORTINT);
BEGIN
  ZlibWriters.SetParams(w.zw, level, strategy, ZlibWriters.NoFlush);
  w.res := w.zw.res;
END SetParams;

(** open writer on .gz-file **)
PROCEDURE Open*(VAR w: Writer; level, strategy: SHORTINT; file: Files.File);
VAR
  r: Files.Rider;
BEGIN
  w.start := 0;
  IF file# NIL THEN
    w.file := file; Files.Set(r, w.file, 0);
    WriteHeader(w, r);
    ZlibWriters.Open(w.zw, level, strategy, ZlibWriters.NoFlush, FALSE, r);
    w.res := w.zw.res
  ELSE
    w.res := FileError
  END
END Open;

(** write specified number of bytes from buffer into .gz-file and return number of bytes actually written **)
PROCEDURE WriteBytes*(VAR w: Writer; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; VAR written: LONGINT);
BEGIN
  ZlibWriters.WriteBytes(w.zw, buf, offset, len, written);
  INC(w.pos, written);
  w.res := w.zw.res
END WriteBytes;

(** write byte **)
PROCEDURE Write*(VAR w: Writer; ch: CHAR);
BEGIN
  ZlibWriters.Write(w.zw, ch);
  w.res := w.zw.res
END Write;

(** close writer **)
PROCEDURE Close*(VAR w: Writer);
VAR
  r: Files.Rider;
BEGIN
  ZlibWriters.Close(w.zw);
  w.res := w.zw.res;
  IF w.res = ZlibWriters.Ok THEN
    Files.Close(w.file);
    Files.Set(r, w.file, Files.Length(w.file));
    Files.WriteLInt(r, w.zw.crc32);  (* CRC32 *)
    Files.WriteLInt(r, w.pos);  (* ISIZE: Input Size *)
    Files.Close(w.file)
  END
END Close;

(** get position of reader within uncompressed output stream **)
PROCEDURE Pos* (VAR w: Writer): LONGINT;
  VAR pos: LONGINT;
BEGIN
  IF (w.file = NIL) THEN
    w.res := StreamError; pos := 0
  ELSIF w.res < Ok THEN
    pos := 0
  ELSE
    pos := w.pos
  END;
  RETURN pos
END Pos;


END ethGZWriters.
