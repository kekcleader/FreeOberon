(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethGZReaders;  (** Stefan Walthert  **)

  (**
    Reading from .gz files
  **)
  
  IMPORT
    Files, ZlibReaders := ethZlibReaders;
    
  
  CONST
    (** result codes **)
    Ok* = ZlibReaders.Ok; StreamEnd* = ZlibReaders.StreamEnd;
    StreamError* = ZlibReaders.StreamError; DataError* = ZlibReaders.DataError; BufError* = ZlibReaders.BufError; FileError* = ZlibReaders.FileError;
    
    BufSize = 4000H;
    
    DeflateMethod = 8;
    
  
  TYPE
    (** structure for reading from a .gz file **)
    Reader* = RECORD
      file-: Files.File;  (** underlying Oberon file **)
      res-: LONGINT;  (** current stream state **)
      transparent: BOOLEAN;  (* set if not a .gz file *)
      pos: LONGINT;  (* logical position in decompressed output stream *)
      zr: ZlibReaders.Reader;
    END;

    
  (* check .gz header; input buffer must be empty or just have been refilled (in case magic id is missing) *)
  PROCEDURE CheckHeader (VAR r: Reader; VAR fr: Files.Rider);
    CONST
      headCRC = 2; extraField = 4; origName = 8; comment = 10H; reserved = 20H;
    VAR
      ch, method, flags: CHAR; len: INTEGER;
  BEGIN
    Files.Read(fr, ch);
    IF fr.eof THEN
      r.res := StreamEnd
    ELSIF ch # 1FX THEN
      r.transparent := TRUE; r.res := Ok
    ELSE  (* first byte of magic id ok *)
      Files.Read(fr, ch);
      IF fr.eof OR (ch # 8BX)THEN
        r.transparent := TRUE; r.res := Ok
      ELSE  (* second byte of magic id ok *)
        Files.Read(fr, method); Files.Read(fr, flags);
        IF fr.eof OR (ORD(method) # DeflateMethod) OR (ORD(flags) >= reserved) THEN
          r.res := DataError
        ELSE
          FOR len := 1 TO 6 DO Files.Read(fr, ch) END;  (* skip time, xflags and OS code *)
          IF ODD(ORD(flags) DIV extraField) THEN  (* skip extra field *)
            Files.Read(fr, ch); len := ORD(ch);
            Files.Read(fr, ch); len := len + 100H*ORD(ch);
            WHILE ~fr.eof & (len # 0) DO
              Files.Read(fr, ch); DEC(len)
            END
          END;
          IF ODD(ORD(flags) DIV origName) THEN  (* skip original file name *)
            REPEAT Files.Read(fr, ch) UNTIL fr.eof OR (ch = 0X)
          END;
          IF ODD(ORD(flags) DIV comment) THEN  (* skip the .gz file comment *)
            REPEAT Files.Read(fr, ch) UNTIL fr.eof OR (ch = 0X)
          END;
          IF ODD(ORD(flags) DIV headCRC) THEN  (* skip header crc *)
            Files.Read(fr, ch); Files.Read(fr, ch)
          END;
          IF fr.eof THEN r.res := DataError
          ELSE r.res := Ok
          END
        END
      END
    END
  END CheckHeader;
  
  (** open reader on existing file for input **)
  PROCEDURE Open* (VAR r: Reader; file: Files.File);
  VAR
    fr: Files.Rider;
  BEGIN
    r.transparent := FALSE;
    IF file # NIL THEN
      r.file := file; Files.Set(fr, file, 0);
      CheckHeader(r, fr);
      ZlibReaders.Open(r.zr, FALSE, fr);
      r.pos := 0
    ELSE
      r.res := StreamError
    END
  END Open;
  
  (** close reader **)
  PROCEDURE Close* (VAR r: Reader);
  VAR
    fr: Files.Rider;
    crc32: LONGINT;
  BEGIN
    IF r.transparent THEN
      r.res := Ok
    ELSE
      ZlibReaders.Close(r.zr);
      IF r.zr.res = ZlibReaders.Ok THEN
        Files.Set(fr, r.file, Files.Length(r.file) - 8);
        Files.ReadLInt(fr, crc32);
        IF crc32 # r.zr.crc32 THEN
          r.res := DataError
        ELSE
          r.res := Ok
        END
      ELSE
        r.res := r.zr.res
      END
    END
  END Close;
  
  (** read specified number of bytes into buffer and return number of bytes actually read **)
  PROCEDURE ReadBytes* (VAR r: Reader; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; VAR read: LONGINT);
    VAR i: LONGINT; fr: Files.Rider; bufp: POINTER TO ARRAY OF CHAR;
  BEGIN
    IF r.file = NIL THEN
      r.res := StreamError; read := 0
    ELSIF r.res < Ok THEN
      read := 0
    ELSIF r.res = StreamEnd THEN
      read := 0
    ELSIF r.transparent THEN  (* uncompressed input *)
      Files.Set(fr, r.file, r.pos);
      IF offset = 0 THEN
        Files.ReadBytes(fr, buf, len)
      ELSE
        NEW(bufp, len);
        Files.ReadBytes(fr, bufp^, len);
        FOR i := 0 TO len - 1 DO
          buf[offset + i] := bufp[i]
        END
      END;
      read := len - fr.res
    ELSE
      ZlibReaders.ReadBytes(r.zr, buf, offset, len, read)
    END;
    INC(r.pos, read)
  END ReadBytes;
  
  (** read decompressed byte **)
  PROCEDURE Read* (VAR r: Reader; VAR ch: CHAR);
  BEGIN
    ZlibReaders.Read(r.zr, ch)
  END Read;
  
  (** get position of reader within uncompressed output stream **)
  PROCEDURE Pos* (VAR r: Reader): LONGINT;
    VAR pos: LONGINT;
  BEGIN
    IF r.file = NIL THEN
      r.res := StreamError; pos := 0
    ELSIF r.res < Ok THEN
      pos := 0
    ELSE
      pos := r.pos
    END;
    RETURN pos
  END Pos;
  
END ethGZReaders.
