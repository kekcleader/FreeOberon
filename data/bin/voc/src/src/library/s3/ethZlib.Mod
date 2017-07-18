(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethZlib;  (** Stefan Walthert  **)

IMPORT
  SYSTEM;

CONST
  (** Result codes for compression/decompression functions **)

  (** regular termination **)
  Ok* = 0;  (** some progress has been made (more input processed or more output produced **)
  StreamEnd* = 1;  (** all input has been consumed and all output has been produced (only when flush is set to Finish) **)
  NeedDict* = 2;
  
  (** errors **)
  StreamError* = -2;  (** stream state was inconsistent (for example stream.in.next or stream.out.next was 0) **)
  DataError* = -3;
  MemError* = -4;
  BufError* = -5;  (** no progress is possible (for example stream.in.avail or stream.out.avail was zero) **)
  
  
  (** Flush values (Flushing may degrade compression for some compression algorithms and so it should be used only 
    when necessary) **)
  NoFlush* = 0;
  PartialFlush* = 1;  (** will be removed, use SyncFlush instead **)
  SyncFlush* = 2;  (** pending output is flushed to the output buffer and the output is aligned on a byte boundary, 
    so that the compressor/decompressor can get all input data available so far. (In particular stream.in.avail 
    is zero after the call if enough output space has been provided before the call.) **)
  FullFlush* = 3;  (** all output is flushed as with SyncFlush, and the compression state is reset so that 
    decompression can restart from this point if previous compressed data has been damaged of if random access 
    is desired. Using FullFlush too often can seriously degrade the compression. **)
  Finish* = 4;  (** pending input is processed, pending output is flushed.
    If Deflate/Inflate returns with StreamEnd, there was enough space.
    If Deflate/Inflate returns with Ok, this function must be called again with Finish and more output space 
    (updated stream.out.avail) but no more input data, until it returns with StreamEnd or an error.
    After Deflate has returned StreamEnd, the only possible operations on the stream are Reset or Close
    Finish can be used immediately after Open if all the compression/decompression is to be done in a single step.
    In case of compression, the out-Buffer (respectively stream.out.avail) must be at least 0.1% larger than the 
    in-Buffer (respectively stream.in.avail) plus 12 bytes. **)

  (** compression levels **)
  DefaultCompression* = -1;
  NoCompression* = 0;
  BestSpeed* = 1;
  BestCompression* = 9;
  
  (** compression strategies; the strategy only affects the compression ratio but not the correctness of the 
  compressed output even if it is not set appropriately **)
  DefaultStrategy* = 0;  (** for normal data **)
  Filtered* = 1;  (** for data produced by a filter (or predictor); filtered data consists mostly of small values with a 
    somewhat random distribution. In this case, the compression algorithm is tuned to compress them better. 
    The effect of Filtered is to force more Huffman coding and less string matching; it is somewhat intermediate 
    between DefaultStrategy and HuffmanOnly. **)
  HuffmanOnly* = 2;  (** to force Huffman encoding only (no string match) **)
  
  (** data type **)
  Binary* = 0;
  Ascii* = 1;
  Unknown* = 2;
  
  DeflateMethod* = 8;

VAR
  CRCTable: ARRAY 256 OF LONGINT;


PROCEDURE Adler32*(adler: LONGINT; VAR buf: ARRAY OF CHAR; offset, len: LONGINT): LONGINT;
CONST
  base = 65521;  (* largest prim smaller than 65536 *)
  nmax = 5552;  (* largest n such that 255n(n + 1) / 2 + (n + 1)(base - 1) <= 2^32 - 1 *)
VAR
  s1, s2, k, offset0, len0: LONGINT;
BEGIN
  offset0 := offset; len0 := len;
  IF len < 0 THEN
    RETURN 1
  ELSE
    s1 := adler MOD 10000H;
    s2 := SYSTEM.LSH(adler, -16) MOD 10000H;
    WHILE len > 0 DO
      IF len < nmax THEN k := len ELSE k := nmax END;
      DEC(len, k);
      REPEAT
        INC(s1, LONG(ORD(buf[offset])));
        INC(s2, s1);
        INC(offset);
        DEC(k)
      UNTIL k = 0;
      s1 := s1 MOD base;
      s2 := s2 MOD base
    END;
    RETURN SYSTEM.LSH(s2, 16) + s1
  END
END Adler32;


(**  Generate a table for a byte-wise 32-bit CRC calculation on the polynomial:
  x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1.
  
  Polynomials over GF(2) are represented in binary, one bit per coefficient,
  with the lowest powers in the most significant bit.  Then adding polynomials
  is just exclusive-or, and multiplying a polynomial by x is a right shift by
  one.  If we call the above polynomial p, and represent a byte as the
  polynomial q, also with the lowest power in the most significant bit (so the
  byte 0xb1 is the polynomial x^7+x^3+x+1), then the CRC is (q*x^32) mod p,
  where a mod b means the remainder after dividing a by b.
  
  This calculation is done using the shift-register method of multiplying and
  taking the remainder.  The register is initialized to zero, and for each
  incoming bit, x^32 is added mod p to the register if the bit is a one (where
  x^32 mod p is p+x^32 = x^26+...+1), and the register is multiplied mod p by
  x (which is shifting right by one and adding x^32 mod p if the bit shifted
  out is a one).  We start with the highest power (least significant bit) of
  q and repeat for all eight bits of q.
  
  The table is simply the CRC of all possible eight bit values.  This is all
  the information needed to generate CRC's on data a byte at a time for all
  combinations of CRC register values and incoming bytes. **)

PROCEDURE InitCRCTable*();
CONST
  poly = 0EDB88320H;
VAR
  n, c, k: LONGINT;
BEGIN
  FOR n := 0 TO 255 DO
    c := n;
    FOR k := 0 TO 7 DO
      IF ODD(c) THEN c := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, poly)/SYSTEM.VAL(SET, SYSTEM.LSH(c, -1)))
      ELSE c := SYSTEM.LSH(c, -1)
      END
    END;
    CRCTable[n] := c
  END
END InitCRCTable;

  
PROCEDURE CRC32*(crc: LONGINT; VAR buf: ARRAY OF CHAR; offset, len: LONGINT): LONGINT;
VAR idx: LONGINT;
BEGIN
  IF offset < 0 THEN
    crc := 0
  ELSE
    crc := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, crc)/{0..31});
    WHILE len > 0 DO
      idx := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, crc)/SYSTEM.VAL(SET, LONG(ORD(buf[offset])))) MOD 100H;
      crc := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, CRCTable[idx])/SYSTEM.VAL(SET, SYSTEM.LSH(crc, -8)));
      DEC(len); INC(offset)
    END;
    crc := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, crc)/{0..31})
  END;
  RETURN crc
END CRC32;


BEGIN
  InitCRCTable();
END ethZlib.
