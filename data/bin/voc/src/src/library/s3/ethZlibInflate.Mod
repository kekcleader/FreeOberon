(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethZlibInflate;  (** eos  **)

  (**
    Decompression of deflated byte streams
  **)
  
  (*
    01.04.2001 - fixed bug in InflateBlock.Stored (didn't calculate t (or wavail?) correctly 
              -> Trap 100 in ZlibBuffers.ReadBytes (offset + len > LEN(buf)))
    11.12.2000 - Constants are imported from Zlib
    18.10.2000 - use Zlib.Adler32(..) instead of Adler32(..) -> import Zlib
    17.10.2000 - fixed bug in InflateBlocks.BlkLens (didn't calculate 1's complement of LEN correctly)
    04.01.2000 - fixed bug in InflateBlocks.BlkCodes (didn't reset s.res.code from StreamEnd to Ok)
    05.01.2000 - fixed bug in InflateCodes.CodeWash (didn't adjust s.buf when decreasing s.bits)
  *)
  
  IMPORT
    SYSTEM, Zlib := ethZlib, ZlibBuffers := ethZlibBuffers;
  
  CONST
    (** result codes **)
    Ok* = Zlib.Ok; StreamEnd* = Zlib.StreamEnd; NeedDict* = Zlib.NeedDict;
    StreamError* = Zlib.StreamError; DataError* = Zlib.DataError; MemError* = Zlib.MemError; BufError* = Zlib.BufError;
    
    (** inflate operation codes **)
    NoFlush* = Zlib.NoFlush; SyncFlush* = Zlib.SyncFlush; FullFlush* = Zlib.FullFlush; Finish* = Zlib.Finish;
    
    (* Huffman codes *)
    MaxNodes = 1440;  (* maximum number of nodes in dynamic literal/length and distance trees *)
    MaxFixedNodes = 544;  (* number of nodes in fixed trees *)
    MaxLitLenCodes = 288;  (* 256 bytes + end of block + 31 length codes *)
    MaxNonSimpleCodes = MaxLitLenCodes - 256 - 1;  (* maximal number of non-simple codes *)
    MaxDistCodes = 31;
    OpBase = -128; OpSpecial = 64; OpInvalid = 128; OpEndBlock = 32; OpExtra = 16;  (* operations *)
    
    WindowBits = 15; WindowSize = ASH(1, WindowBits);  (* always use 32k buffer *)
    
    (* decode state *)
    CodeStart = 0; CodeLen = 1; CodeLenExt = 2; CodeDist = 3; CodeDistExt = 4; CodeCopy = 5; CodeLit = 6;
    CodeWash = 7; CodeEnd = 8; CodeBad = 9;
    
    (* block state *)
    BlkType = 0; BlkLens = 1; BlkStored = 2; BlkTable = 3; BlkBTree = 4; BlkDTree = 5; BlkCodes = 6;
    BlkDry = 7; BlkDone = 8; BlkBad = 9;
    
    DeflateMethod* = 8;  (** only supported compression method **)
    PresetDict = 20H;  (* inflate flag indicating use of a preset dictionary *)
    
    (* inflate stream state *)
    InfMethod = 0; InfFlag = 1; InfDict4 = 2; InfDict3 = 3; InfDict2 = 4; InfDict1 = 5; InfDict0 = 6;
    InfBlocks = 7; InfCheck4 = 8; InfCheck3 = 9; InfCheck2 = 10; InfCheck1 = 11; InfDone = 12; InfBad = 13;
    
  
  TYPE
    
    (** result codes **)
    Result* = RECORD
      code-: LONGINT;  (** result code including special conditions and errors **)
      msg-: POINTER TO ARRAY OF CHAR;  (** detailed error description if available **)
    END;
    
    (* code parameters *)
    Lengths = ARRAY OF SHORTINT;
    Code = RECORD
      bits: INTEGER;  (* number of lookup bits *)
      offset: INTEGER;  (* offset in length array *)
      size: INTEGER;  (* number of codes *)
      simple: INTEGER;  (* number of simple codes *)
      extra: ARRAY MaxNonSimpleCodes OF SHORTINT;  (* number of extra bits for non-simple codes *)
      base: ARRAY MaxNonSimpleCodes OF INTEGER;  (* base length/distance for non-simple codes *)
    END;
    
    (* tree nodes for decoding Huffman trees *)
    Node = RECORD
      base: INTEGER;  (* literal, length base, distance base, or table offset *)
      exop: SHORTINT;  (* number of extra bits or operation *)
      bits: SHORTINT;  (* number of bits in this code or subcode *)
    END;
    Nodes = POINTER TO ARRAY OF Node;
    
    TreeNodes = RECORD
      node: Nodes;  (* available nodes *)
      next: LONGINT;  (* index of next available node *)
    END;
    
    Tree = RECORD
      node: Nodes;  (* nodes where tree is stored *)
      base: LONGINT;  (* index of root table *)
      bits: INTEGER;  (* number of lookup bits *)
    END;
    
    (* memory containing last WindowSize bytes of output *)
    Window = ARRAY WindowSize OF CHAR;
    
    (* check function *)
    CheckFunc = PROCEDURE (old: LONGINT; VAR buf: ARRAY OF CHAR; idx, len: LONGINT): LONGINT;
    
    (** inflate stream **)
    Stream* = RECORD
      in*, out*: ZlibBuffers.Buffer;  (** input and output buffers (initialized by client) **)
      (* totalIn-, totalOut-: LONGINT;  (** number of bytes processed **)  *)
      res-: Result;  (** result of last operation **)
      wrapper-: BOOLEAN;  (** if set, the stream has a zlib header and a checksum **)
      open-: BOOLEAN;  (** if set, stream is initialized **)
      
      (* window and lookahead buffer *)
      window: POINTER TO Window;  (* memory for the decompression window *)
      read, write: LONGINT;  (* window read and write index *)
      checkFn: CheckFunc;  (* function calculating checksum over output bytes *)
      check: LONGINT;  (* current output checksum *)
      buf: LONGINT;  (* bit buffer containing up to 32 lookup bits *)
      bits: LONGINT;  (* number of bits in lookup buffer = position of next bit *)
      
      (* inflate state machine *)
      inf: RECORD
        state: INTEGER;  (* current state of stream *)
        method: INTEGER;  (* method byte for state InfFlag *)
        marker: INTEGER;  (* marker bytes for state InfBad *)
        check: RECORD
          calc: LONGINT;  (* calculated sum *)
          stored: LONGINT;  (* stored sum *)
        END
      END;
      
      (* block state machine *)
      block: RECORD
        state: SHORTINT;  (* current block state *)
        last: BOOLEAN;  (* set for last block *)
        left: LONGINT;  (* bytes left to copy for non-compressed blocks *)
        nlit: INTEGER;  (* number of literal/length codes *)
        ndist: SHORTINT;  (* number of distance codes *)
        nclen: SHORTINT;  (* number of code lengths *)
        clen: ARRAY MaxLitLenCodes + MaxDistCodes OF SHORTINT;  (* code lengths of bit, lit/len, or distance code *)
        index: INTEGER;  (* index of next code length *)
        nodes: Nodes;  (* memory for Huffman trees *)
        btree: Tree;  (* bit decoding tree *)
      END;
      
      (* code state machine *)
      decode: RECORD
        state: SHORTINT;  (* current decode state *)
        lltree, dtree: Tree;  (* literal/length and distance tree *)
        tree: Tree;  (* current decoding table *)
        lit: INTEGER;  (* decoded literal *)
        extra: INTEGER;  (* extra bits to get *)
        len: INTEGER;  (* decoded length *)
        dist: INTEGER;  (* distance back to copy from *)
      END;
    END;
    
  
  VAR
    FixedBuilt: BOOLEAN;  (* set if fixed Huffman tables have been built *)
    FixedLitLenTree, FixedDistTree: Tree;  (* nodes for fixed literal/length and distance tree *)
    Order: ARRAY 19 OF SHORTINT;  (* order of code bit lengths *)


  (*--- Results ---*)
  
  (* set error message *)
  PROCEDURE SetMsg (VAR res: Result; msg: ARRAY OF CHAR);
    VAR l: LONGINT;
  BEGIN
    l := 0; WHILE msg[l] # 0X DO INC(l) END;
    NEW(res.msg, l+1); COPY(msg, res.msg^)
  END SetMsg;
  
  
  (*--- Huffman Decoding Tables ---*)
  
  PROCEDURE MakeLitLenCode (VAR code: Code; bits, offset, size, simple: INTEGER);
  BEGIN
    code.bits := bits; code.offset := offset; code.size := size; code.simple := simple;
    IF simple < size THEN
      code.extra[0] := 0; code.extra[1] := 0; code.extra[2] := 0; code.extra[3] := 0;
      code.extra[4] := 0; code.extra[5] := 0; code.extra[6] := 0; code.extra[7] := 0;
      code.extra[8] := 1; code.extra[9] := 1; code.extra[10] := 1; code.extra[11] := 1;
      code.extra[12] := 2; code.extra[13] := 2; code.extra[14] := 2; code.extra[15] := 2;
      code.extra[16] := 3; code.extra[17] := 3; code.extra[18] := 3; code.extra[19] := 3;
      code.extra[20] := 4; code.extra[21] := 4; code.extra[22] := 4; code.extra[23] := 4;
      code.extra[24] := 5; code.extra[25] := 5; code.extra[26] := 5; code.extra[27] := 5;
      code.extra[28] := 0; code.extra[29] := 112; code.extra[30] := 112;
      code.base[0] := 3; code.base[1] := 4; code.base[2] := 5; code.base[3] := 6;
      code.base[4] := 7; code.base[5] := 8; code.base[6] := 9; code.base[7] := 10;
      code.base[8] := 11; code.base[9] := 13; code.base[10] := 15; code.base[11] := 17;
      code.base[12] := 19; code.base[13] := 23; code.base[14] := 27; code.base[15] := 31;
      code.base[16] := 35; code.base[17] := 43; code.base[18] := 51; code.base[19] := 59;
      code.base[20] := 67; code.base[21] := 83; code.base[22] := 99; code.base[23] := 115;
      code.base[24] := 131; code.base[25] := 163; code.base[26] := 195; code.base[27] := 227;
      code.base[28] := 258; code.base[29] := 0; code.base[30] := 0
    END
  END MakeLitLenCode;
  
  PROCEDURE MakeDistCode (VAR code: Code; bits, offset, size, simple: INTEGER);
  BEGIN
    code.bits := bits; code.offset := offset; code.size := size; code.simple := simple;
    IF simple < size THEN
      code.extra[0] := 0; code.extra[1] := 0; code.extra[2] := 0; code.extra[3] := 0;
      code.extra[4] := 1; code.extra[5] := 1; code.extra[6] := 2; code.extra[7] := 2;
      code.extra[8] := 3; code.extra[9] := 3; code.extra[10] := 4; code.extra[11] := 4;
      code.extra[12] := 5; code.extra[13] := 5; code.extra[14] := 6; code.extra[15] := 6;
      code.extra[16] := 7; code.extra[17] := 7; code.extra[18] := 8; code.extra[19] := 8;
      code.extra[20] := 9; code.extra[21] := 9; code.extra[22] := 10; code.extra[23] := 10;
      code.extra[24] := 11; code.extra[25] := 11; code.extra[26] := 12; code.extra[27] := 12;
      code.extra[28] := 13; code.extra[29] := 13;
      code.base[0] := 1; code.base[1] := 2; code.base[2] := 3; code.base[3] := 4;
      code.base[4] := 5; code.base[5] := 7; code.base[6] := 9; code.base[7] := 13;
      code.base[8] := 17; code.base[9] := 25; code.base[10] := 33; code.base[11] := 49;
      code.base[12] := 65; code.base[13] := 97; code.base[14] := 129; code.base[15] := 193;
      code.base[16] := 257; code.base[17] := 385; code.base[18] := 513; code.base[19] := 769;
      code.base[20] := 1025; code.base[21] := 1537; code.base[22] := 2049; code.base[23] := 3073;
      code.base[24] := 4097; code.base[25] := 6145; code.base[26] := 8193; code.base[27] := 12289;
      code.base[28] := 16385; code.base[29] := 24577
    END
  END MakeDistCode;
  
  PROCEDURE MakeFixedLitLenCode (VAR len: Lengths; VAR code: Code);
    VAR i: LONGINT;
  BEGIN
    ASSERT(LEN(len) >= 288, 100);
    FOR i := 0 TO 143 DO len[i] := 8 END;
    FOR i := 144 TO 255 DO len[i] := 9 END;
    FOR i := 256 TO 279 DO len[i] := 7 END;
    FOR i := 280 TO 287 DO len[i] := 8 END;
    MakeLitLenCode(code, 9, 0, 288, 257)
  END MakeFixedLitLenCode;
  
  PROCEDURE MakeFixedDistCode (VAR len: Lengths; VAR code: Code);
    VAR i: LONGINT;
  BEGIN
    ASSERT(LEN(len) >= 30, 100);
    FOR i := 0 TO 29 DO len[i] := 5 END;
    MakeDistCode(code, 5, 0, 30, 0)
  END MakeFixedDistCode;
  
  (* build huffman tree for given code *)
  PROCEDURE BuildTree (VAR clen: Lengths; VAR code: Code; VAR tn: TreeNodes; VAR tree: Tree; VAR res: LONGINT);
    CONST
      maxLen = 15;  (* maximum bit length of any code *)
    VAR
      l, lbits, min, max, dbits, len, bits, b: LONGINT;  (* bit lengths *)
      c, idx: LONGINT;  (* code index *)
      codes: ARRAY maxLen+1 OF INTEGER;  (* number of codes of each length *)
      unused, size, count, entries: LONGINT;  (* code counts *)
      offset: ARRAY maxLen+1 OF INTEGER;  (* offset into index table for each length *)
      off: INTEGER;
      index: ARRAY MaxLitLenCodes OF INTEGER;  (* symbol numbers ordered by code length *)
      backup: ARRAY maxLen OF LONGINT;  (* projection of current pattern to each level *)
      pat, p, inc: LONGINT;  (* current code pattern *)
      tab, t: LONGINT;  (* pointers into Huffman nodes *)
      level: LONGINT;  (* current table level *)
      table: ARRAY maxLen OF LONGINT;  (* current table index for each open level *)
      node: Node;
  BEGIN
    (* compute number of codes for each bit length *)
    FOR l := 0 TO maxLen DO
      codes[l] := 0
    END;
    FOR c := 0 TO code.size - 1 DO
      INC(codes[clen[code.offset + c]])
    END;
    IF codes[0] = code.size THEN  (* all codes have len = 0 *)
      tree.node := NIL; tree.base := 0; tree.bits := 0; res := Ok;
      RETURN
    END;
    
    lbits := code.bits;  (* number of lookup bits *)
    l := 1; WHILE (l <= maxLen) & (codes[l] = 0) DO INC(l) END;
    min := l; IF lbits < min THEN lbits := SHORT(min) END;
    l := maxLen; WHILE (l > 0) & (codes[l] = 0) DO DEC(l) END;
    max := l; IF lbits > max THEN lbits := SHORT(max) END;
    tree.bits := SHORT(lbits);  (* adjusted number of lookup bits *)
    
    (* add number of unused codes to last code length count *)
    l := min; unused := ASH(1, min);
    LOOP
      DEC(unused, LONG(codes[l]));
      IF unused < 0 THEN res := DataError; RETURN END;  (* more codes for length requested than available *)
      IF l = max THEN EXIT END;
      INC(l); unused := 2*unused  (* can append either 0 or 1 to yet unused codes *)
    END;
    INC(codes[max], SHORT(unused));
    
    (* generate starting offsets into index table for each length *)
    l := 1; offset[1] := 0; off := 0;
    WHILE l < max DO
      INC(off, codes[l]); INC(l); offset[l] := off
    END;
    
    (* create index to code symbol ordered by code length *)
    FOR c := 0 TO code.size-1 DO
      l := clen[code.offset + c];
      IF l # 0 THEN
        index[offset[l]] := SHORT(c); INC(offset[l])
      END
    END;
    size := offset[max];  (* effective number of codes *)
    
    (* generate Huffman codes and tables for each level *)
    backup[0] := 0; pat := 0; idx := 0;
    dbits := -lbits; level := -1;  (* dbits = lookupBits * level (number of decoded bits) *)
    FOR len := min TO max DO
      count := codes[len];
      WHILE count > 0 DO
        WHILE len > dbits + lbits DO  (* code length too long to fit in current table *)
          INC(level); INC(dbits, lbits);  (* previous table had size tbits *)
          
          (* compute minimum size <= lookup bits for next table *)
          bits := max - dbits;
          IF bits > lbits THEN bits := lbits END;  (* limit number of bits for table *)
          b := len - dbits; entries := ASH(1, b);  (* try table with size len-dbits *)
          IF entries > count THEN
            (*
              codes of length len do not use all slots in table of length b. however, these unused slots
              will be used by longer codes having the same prefix.
            *)
            DEC(entries, count);
            IF b < bits THEN
              l := len;
              LOOP
                INC(b); IF b = bits THEN EXIT END;  (* mustn't make table any larger *)
                entries := 2*entries; INC(l);
                IF entries <= codes[l] THEN EXIT END;  (* enough codes to use up b bits *)
                DEC(entries, LONG(codes[l]))
              END
            END
          END;
          
          (* allocate table from available Huffman nodes *)
          entries := ASH(1, b);
          IF tn.next + entries > LEN(tn.node^) THEN
            res := MemError; RETURN
          END;
          tab := tn.next; table[level] := tab; INC(tn.next, entries);
          
          (* connect to previous table *)
          IF level > 0 THEN
            backup[level] := pat;  (* save pattern for backing up *)
            node.bits := SHORT(SHORT(lbits));  (* bits to dump before this table *)
            node.exop := OpBase + SHORT(SHORT(b));  (* bits in this table *)
            t := ASH(pat, -(dbits - lbits));  (* offset of pattern within previous table *)
            node.base := SHORT(tab - table[level-1] - t);  (* offset to this table *)
            tn.node[table[level-1] + t] := node  (* link previous table entry to this table *)
          ELSE
            tree.node := tn.node; tree.base := tab
          END
        END;
        
        (* set up table entry *)
        node.bits := SHORT(SHORT(len - dbits));
        IF idx >= size THEN
          node.exop := OpBase + OpSpecial + OpInvalid  (* out of codes *)
        ELSIF index[idx] < code.simple THEN  (* simple code *)
          IF index[idx] < 256 THEN node.exop := OpBase ELSE node.exop := OpBase + OpSpecial + OpEndBlock END;
          node.base := index[idx];  (* simple code is just the value *)
          INC(idx)
        ELSE  (* non-simple => lookup in extra/base tables *)
          node.exop := OpBase + OpSpecial + OpExtra + code.extra[index[idx] - code.simple];
          node.base := code.base[index[idx] - code.simple];
          INC(idx)
        END;
        
        (* fill all table entries having common relevant code bits *)
        p := ASH(pat, -dbits); inc := ASH(1, len - dbits); 
        WHILE p < entries DO
          tn.node[tab + p] := node; INC(p, inc)
        END;
        
        (* increment the code pattern (in reverse bit order) *)
        l := len-1;
        WHILE ODD(ASH(pat, -l)) DO  (* generates carry *)
          DEC(pat, ASH(1, l));  (* equivalent to xor since pat.l is set *)
          DEC(l)
        END;
        INC(pat, ASH(1, l));  (* equivalent to xor since pat.l is clear *)
        
        (* backup over finished tables *)
        WHILE pat MOD ASH(1, dbits) # backup[level] DO  (* entry in previous table no longer compatible with this table *)
          DEC(level); DEC(dbits, lbits)
        END;
        
        DEC(count)
      END
    END;
    
    IF (unused # 0) & (max # 1) THEN res := BufError  (* incomplete table *)
    ELSE res := Ok
    END
  END BuildTree;
  
  
  (*--- Auxiliary Routines ---*)
  
  (* copy as much as possible from sliding window to output buffer *)
  PROCEDURE Flush (VAR s: Stream);
    VAR n: LONGINT;
  BEGIN
    (* get number of bytes to copy *)
    IF s.read <= s.write THEN n := s.write - s.read
    ELSE n := WindowSize - s.read  (* first copy only up to end of window *)
    END;
    IF n > s.out.avail THEN n := s.out.avail END;
    IF n > 0 THEN
      IF s.res.code = BufError THEN s.res.code := Ok END;
      IF s.checkFn # NIL THEN  (* update output check sum *)
        s.check := s.checkFn(s.check, s.window^, s.read, n)
      END;
      
      (* copy from window to output buffer *)
      ZlibBuffers.WriteBytes(s.out, s.window^, s.read, n);
      INC(s.read, n)
    END;
    
    IF s.read = WindowSize THEN  (* wrap read/write index and continue at start of window *)
      s.read := 0;
      IF s.write = WindowSize THEN s.write := 0 END;
      
      (* get number of bytes to copy *)
      n := s.write - s.read;
      IF n > s.out.avail THEN n := s.out.avail END;
      IF n > 0 THEN
        IF s.res.code = BufError THEN s.res.code := Ok END;
        IF s.checkFn # NIL THEN  (* update output check sum *)
          s.check := s.checkFn(s.check, s.window^, s.read, n)
        END;
        
        (* copy from window to output buffer *)
        ZlibBuffers.WriteBytes(s.out, s.window^, s.read, n);
        INC(s.read, n)
      END
    END
  END Flush;
  
  (* transfer bits from input buffer to bit buffer and return if successful *)
  PROCEDURE Need (VAR s: Stream; bits: LONGINT): BOOLEAN;
    VAR byte: CHAR;
  BEGIN
    WHILE s.bits < bits DO
      IF s.in.avail = 0 THEN
        Flush(s);
        RETURN FALSE
      END;
      ZlibBuffers.Read(s.in, byte);
      INC(s.buf, ASH(ORD(byte), s.bits)); INC(s.bits, 8)  (* one byte more in buffer now *)
    END;
    RETURN TRUE
  END Need;
  
  PROCEDURE Dump (VAR s: Stream; bits: LONGINT);
  BEGIN
    s.buf := SYSTEM.LSH(s.buf, -bits); DEC(s.bits, bits)
  END Dump;
  
  PROCEDURE NeedOut (VAR s: Stream; VAR wavail: LONGINT): BOOLEAN;
  BEGIN
    IF wavail = 0 THEN
      IF (s.write = WindowSize) & (s.read # 0) THEN
        s.write := 0; wavail := s.read-1
      END;
      IF wavail = 0 THEN
        Flush(s);
        IF (s.write = WindowSize) & (s.read # 0) THEN
          s.write := 0; wavail := s.read-1;
        END;
        IF wavail = 0 THEN
          RETURN FALSE
        END
      END
    END;
    RETURN TRUE
  END NeedOut;
  
  
  (*--- Codes ---*)
  
  PROCEDURE NewCodes (VAR s: Stream; VAR lltree, dtree: Tree);
  BEGIN
    s.decode.lltree := lltree; s.decode.dtree := dtree;
    s.decode.state := CodeStart
  END NewCodes;
  
  PROCEDURE FreeCodes (VAR s: Stream);
  BEGIN
    s.decode.lltree.node := NIL; s.decode.dtree.node := NIL; s.decode.tree.node := NIL
  END FreeCodes;
  
  (* Called with number of bytes left to write in window (wavail) at least 258 (the maximum 
    string length) and number of input bytes available (s.in.avail) at least ten.  The ten bytes 
    are six bytes for the longest length/distance pair plus four bytes for overloading the bit buffer. *)
  PROCEDURE InflateFast (VAR s: Stream; VAR wavail: LONGINT);
    VAR inavail, base, len, dist, index: LONGINT; byte: CHAR; node: Node; exop: INTEGER;
  BEGIN
    inavail := s.in.avail;
    REPEAT
      WHILE s.bits < 20 DO  (* maximal bits for lit/len code, including extra bits *)
        ZlibBuffers.Read(s.in, byte);
        INC(s.buf, ASH(ORD(byte), s.bits)); INC(s.bits, 8)
      END;
      base := s.decode.lltree.base; node.base := 0; exop := s.decode.lltree.bits;
      REPEAT
        base := base + node.base + s.buf MOD ASH(1, exop);
        node := s.decode.lltree.node[base];
        Dump(s, node.bits);
        exop := LONG(node.exop) - OpBase
      UNTIL (exop = 0) OR ODD(exop DIV OpSpecial);
      IF exop = 0 THEN  (* literal *)
        s.window[s.write] := CHR(node.base); INC(s.write); DEC(wavail)
      ELSIF ODD(exop DIV OpExtra) THEN  (* length code *)
        exop := exop MOD OpExtra;
        len := node.base + s.buf MOD ASH(1, exop);
        Dump(s, exop);
        WHILE s.bits < 15 DO  (* maximal bits for distance code *)
          ZlibBuffers.Read(s.in, byte);
          INC(s.buf, ASH(ORD(byte), s.bits)); INC(s.bits, 8)
        END;
        base := s.decode.dtree.base; node.base := 0; exop := s.decode.dtree.bits;
        REPEAT
          base := base + node.base + s.buf MOD ASH(1, exop);
          node := s.decode.dtree.node[base];
          Dump(s, node.bits);
          exop := LONG(node.exop) - OpBase
        UNTIL ODD(exop DIV OpSpecial);
        IF ODD(exop DIV OpExtra) THEN  (* distance code *)
          exop := exop MOD OpExtra;
          WHILE s.bits < exop DO  (* need up to 13 extra bits *)
            ZlibBuffers.Read(s.in, byte);
            INC(s.buf, ASH(ORD(byte), s.bits)); INC(s.bits, 8)
          END;
          dist := node.base + s.buf MOD ASH(1, exop);
          Dump(s, exop);
          DEC(wavail, len);
          index := s.write - dist;
          IF index < 0 THEN
            IF -index < len THEN  (* crosses window bounds *)
              INC(len, index);
              IF s.write - index <= WindowSize + index THEN  (* no overlap *)
                SYSTEM.MOVE(SYSTEM.ADR(s.window[WindowSize + index]), SYSTEM.ADR(s.window[s.write]), -index);
                DEC(s.write, index)
              ELSE  (* be safe *)
                index := WindowSize + index;
                REPEAT
                  s.window[s.write] := s.window[index]; INC(s.write); INC(index)
                UNTIL index = WindowSize
              END;
              index := 0
            ELSE
              INC(index, WindowSize)
            END
          END;
          IF len > 0 THEN
            IF index + len <= s.write THEN  (* no overlap *)
              SYSTEM.MOVE(SYSTEM.ADR(s.window[index]), SYSTEM.ADR(s.window[s.write]), len);
              INC(s.write, len);
            ELSE
              REPEAT
                s.window[s.write] := s.window[index]; INC(s.write); INC(index);
                DEC(len)
              UNTIL len = 0
            END
          END
        ELSE
          SetMsg(s.res, "invalid distance code"); s.res.code := DataError;
          len := inavail - s.in.avail;
          IF s.bits DIV 8 < len THEN len := s.bits DIV 8 END;
          ZlibBuffers.Reread(s.in, len); DEC(s.bits, 8*len); s.buf := s.buf MOD ASH(1, s.bits);
          RETURN
        END
      ELSE
        len := inavail - s.in.avail;
        IF s.bits DIV 8 < len THEN len := s.bits DIV 8 END;
        ZlibBuffers.Reread(s.in, len); DEC(s.bits, 8*len); s.buf := s.buf MOD ASH(1, s.bits);
        IF ODD(exop DIV OpEndBlock) THEN s.res.code := StreamEnd
        ELSE SetMsg(s.res, "invalid literal/length code"); s.res.code := DataError
        END;
        RETURN
      END
    UNTIL (wavail < 258) OR (s.in.avail < 10);
    
    (* can no longer guarantee enough space *)
    len := inavail - s.in.avail;
    IF s.bits DIV 8 < len THEN len := s.bits DIV 8 END;
    ZlibBuffers.Reread(s.in, len); DEC(s.bits, 8*len); s.buf := s.buf MOD ASH(1, s.bits);
    s.res.code := Ok
  END InflateFast;
  
  PROCEDURE InflateCodes (VAR s: Stream);
    VAR wavail, base, index: LONGINT; node: Node; exop: INTEGER;
  BEGIN
    IF s.write < s.read THEN wavail := s.read - s.write - 1
    ELSE wavail := WindowSize - s.write
    END;
    LOOP
      CASE s.decode.state OF
      | CodeStart:  (* try fast inflation while enough space available *)
        IF (wavail >= 258) & (s.in.avail >= 10) THEN
          InflateFast(s, wavail);
          IF s.res.code # Ok THEN
            IF s.res.code = StreamEnd THEN s.decode.state := CodeWash
            ELSE s.decode.state := CodeBad
            END;
            EXIT
          END
        END;
        s.decode.tree := s.decode.lltree;
        s.decode.state := CodeLen
      
      | CodeLen:  (* get literal/length code *)
        IF ~Need(s, s.decode.tree.bits) THEN EXIT END;
        base := s.decode.tree.base + s.buf MOD ASH(1, s.decode.tree.bits);
        node := s.decode.tree.node[base];
        Dump(s, node.bits);
        exop := LONG(node.exop) - OpBase;
        IF exop = 0 THEN  (* literal *)
          s.decode.lit := node.base;
          s.decode.state := CodeLit
        ELSIF ODD(exop DIV OpExtra) THEN  (* need extra bits *)
          s.decode.extra := exop MOD OpExtra;
          s.decode.len := node.base;
          s.decode.state := CodeLenExt
        ELSIF ~ODD(exop DIV OpSpecial) THEN  (* hop to next table *)
          s.decode.tree.bits := exop;
          s.decode.tree.base := base + node.base
        ELSIF ODD(exop DIV OpEndBlock) THEN  (* end of block *)
          s.decode.state := CodeWash
        ELSE  (* invalid code *)
          SetMsg(s.res, "invalid literal/length code");
          s.res.code := DataError; s.decode.state := CodeBad;
          Flush(s);
          EXIT
        END
      
      | CodeLenExt:  (* get extra bits for length codes *)
        IF ~Need(s, s.decode.extra) THEN EXIT END;
        INC(s.decode.len, SHORT(s.buf MOD ASH(1, s.decode.extra)));
        Dump(s, s.decode.extra);
        s.decode.tree := s.decode.dtree;
        s.decode.state := CodeDist
      
      | CodeDist:  (* get distance code *)
        IF ~Need(s, s.decode.tree.bits) THEN EXIT END;
        base := s.decode.tree.base + s.buf MOD ASH(1, s.decode.tree.bits);
        node := s.decode.tree.node[base];
        Dump(s, node.bits);
        exop := LONG(node.exop) - OpBase;
        IF ODD(exop DIV OpExtra) THEN  (* need extra bits *)
          s.decode.extra := exop MOD OpExtra;
          s.decode.dist := node.base;
          s.decode.state := CodeDistExt
        ELSIF ~ODD(exop DIV OpSpecial) THEN  (* need more bits *)
          s.decode.tree.bits := exop;
          s.decode.tree.base := base + node.base
        ELSE  (* invalid code *)
          SetMsg(s.res, "invalid distance code");
          s.res.code := DataError; s.decode.state := CodeBad;
          Flush(s);
          EXIT
        END
      
      | CodeDistExt:  (* get extra bits for distance *)
        IF ~Need(s, s.decode.extra) THEN EXIT END;
        INC(s.decode.dist, SHORT(s.buf MOD ASH(1, s.decode.extra)));
        Dump(s, s.decode.extra);
        s.decode.state := CodeCopy
      
      | CodeCopy:  (* copy within window *)
        index := (s.write - s.decode.dist) MOD WindowSize;  (* position of string to copy *)
        WHILE s.decode.len # 0 DO
          IF ~NeedOut(s, wavail) THEN EXIT END;
          s.window[s.write] := s.window[index]; INC(s.write); DEC(wavail);
          index := (index+1) MOD WindowSize;
          DEC(s.decode.len)
        END;
        s.decode.state := CodeStart
      
      | CodeLit:  (* append literal to window *)
        IF ~NeedOut(s, wavail) THEN EXIT END;
        s.window[s.write] := CHR(s.decode.lit); INC(s.write); DEC(wavail);
        s.decode.state := CodeStart
      
      | CodeWash:  (* block finished but window may not be empty *)
        IF s.bits > 7 THEN  (* return unused byte, if any *)
          ASSERT(s.bits < 16, 110);  (* otherwise InflateCodes grabbed too many bytes *)
          DEC(s.bits, 8); s.buf := s.buf MOD ASH(1, s.bits);
          ZlibBuffers.Reread(s.in, 1)
        END;
        Flush(s);
        IF s.read # s.write THEN EXIT
        ELSE s.decode.state := CodeEnd
        END
      
      | CodeEnd:
        s.res.code := StreamEnd;
        EXIT
      
      | CodeBad:
        s.res.code := DataError;
        EXIT
      
      ELSE
        s.res.code := StreamError;
        EXIT
      END
    END
  END InflateCodes;
  
  
  (*--- Block Handling ---*)
  
  PROCEDURE ResetBlocks (VAR s: Stream; VAR check: LONGINT);
    VAR buf: ARRAY 1 OF CHAR;
  BEGIN
    check := s.check;
    s.block.state := BlkType; s.buf := 0; s.bits := 0;
    s.read := 0; s.write := 0;
    IF s.checkFn # NIL THEN
      s.check := s.checkFn(0, buf, 0, -1)
    END
  END ResetBlocks;
  
  PROCEDURE NewBlocks (VAR s: Stream; checkFn: CheckFunc);
  BEGIN
    NEW(s.block.nodes, MaxNodes); NEW(s.window);
    IF (s.block.nodes = NIL) OR (s.window = NIL) THEN
      s.block.nodes := NIL; s.window := NIL;
      s.res.code := MemError
    ELSE
      s.checkFn := checkFn;
      ResetBlocks(s, s.check);
      s.res.code := Ok
    END
  END NewBlocks;
  
  PROCEDURE FreeBlocks (VAR s: Stream);
  BEGIN
    ResetBlocks(s, s.check);
    s.block.nodes := NIL; s.window := NIL
  END FreeBlocks;
  
  PROCEDURE InflateBlocks (VAR s: Stream);
    VAR
      wavail, t, cnt, len: LONGINT; tn: TreeNodes; clen: ARRAY MaxLitLenCodes OF SHORTINT; code: Code; res: LONGINT;
      node: Node; lltree, dtree: Tree;
  BEGIN
    IF s.write < s.read THEN wavail := s.read - s.write - 1
    ELSE wavail := WindowSize - s.write
    END;
    LOOP
      CASE s.block.state OF
      | BlkType:  (* begin of block, determine if last and compression method *)
        IF ~Need(s, 3) THEN EXIT END;
        t := s.buf MOD 8; s.block.last := ODD(t);
        Dump(s, 3);
        CASE t DIV 2 OF
        | 0: (* no compression *)
          Dump(s, s.bits MOD 8);  (* go to byte boundary *)
          s.block.state := BlkLens
        | 1: (* compressed with fixed Huffman codes *)
          IF ~FixedBuilt THEN
            NEW(tn.node, MaxFixedNodes); tn.next := 0;
            MakeFixedLitLenCode(clen, code);
            BuildTree(clen, code, tn, FixedLitLenTree, res);
            ASSERT(res = Ok, 110);
            MakeFixedDistCode(clen, code);
            BuildTree(clen, code, tn, FixedDistTree, res);
            ASSERT((res = Ok) OR (res = BufError), 111);  (* allow incomplete code *)
            FixedBuilt := TRUE
          END;
          NewCodes(s, FixedLitLenTree, FixedDistTree);
          s.block.state := BlkCodes
        | 2: (* compressed with dynamic codes *)
          s.block.state := BlkTable
        | 3: (* illegal *)
          SetMsg(s.res, "invalid block type");
          s.block.state := BlkBad; s.res.code := DataError;
          Flush(s);
          EXIT
        ELSE
        END
      
      | BlkLens:  (* read length of uncompressed block *)
        IF ~Need(s, 32) THEN EXIT END;
        IF ASH(-(s.buf+1), -16) MOD 10000H # s.buf MOD 10000H THEN
          SetMsg(s.res, "invalid stored block lengths");
          s.block.state := BlkBad; s.res.code := DataError;
          Flush(s);
          EXIT
        END;
        s.block.left := s.buf MOD 10000H;
        s.buf := 0; s.bits := 0;  (* dump all bits *)
        IF s.block.left # 0 THEN s.block.state := BlkStored;
        ELSIF s.block.last THEN s.block.state := BlkDry
        ELSE s.block.state := BlkType
        END
      
      | BlkStored:  (* copy uncompressed bytes from input buffer to window *)
        IF s.in.avail = 0 THEN
          Flush(s);
          EXIT
        END;
        IF ~NeedOut(s, wavail) THEN EXIT END;
        t := s.block.left;
        IF t > s.in.avail THEN t := s.in.avail END;
        IF t > wavail THEN t := wavail END;
        IF s.write + t > WindowSize THEN t := WindowSize - s.write END;  (* new, not in original ZLIB source code *)
        IF t > 0 THEN
          ZlibBuffers.ReadBytes(s.in, s.window^, s.write, t)
        ELSE  (* new, not in original ZLIB source code *)
          Flush(s);
          EXIT
        END;
        INC(s.write, t); DEC(wavail, t);
        DEC(s.block.left, t);
        IF s.block.left = 0 THEN
          IF s.block.last THEN s.block.state := BlkDry
          ELSE s.block.state := BlkType
          END
        END
      
      | BlkTable:  (* get number of code lengths for each tree *)
        IF ~Need(s, 14) THEN EXIT END;  (* 5 (#lit/len-257) + 5 (#dist-1) + 4 (#codelen-4) *)
        t := s.buf MOD 4000H;
        s.block.nlit := SHORT(257 + t MOD 20H); t := t DIV 20H;
        s.block.ndist := SHORT(SHORT(1 + t MOD 20H)); t := t DIV 20H;
        s.block.nclen := SHORT(SHORT(4 + t));
        IF (s.block.nlit > 286) OR (s.block.ndist > 30) THEN
          SetMsg(s.res, "too many length or distance symbols");
          s.block.state := BlkBad; s.res.code := DataError;
          Flush(s);
          EXIT
        END;
        Dump(s, 14);
        s.block.index := 0;
        s.block.state := BlkBTree  (* ready to read code lengths *)
      
      | BlkBTree:  (* get code lengths for code length tree *)
        WHILE s.block.index < s.block.nclen DO  (* get bit lengths of code *)
          IF ~Need(s, 3) THEN EXIT END;
          s.block.clen[Order[s.block.index]] := SHORT(SHORT(s.buf MOD 8));
          INC(s.block.index);
          Dump(s, 3)
        END;
        WHILE s.block.index < 19 DO
          s.block.clen[Order[s.block.index]] := 0;
          INC(s.block.index)
        END;
        tn.node := s.block.nodes; tn.next := 0;
        code.bits := 7; code.offset := 0; code.size := 19; code.simple := 19;
        BuildTree(s.block.clen, code, tn, s.block.btree, res);
        IF res = DataError THEN
          SetMsg(s.res, "oversubscribed dynamic bit lengths tree");
          s.block.state := BlkBad
        ELSIF (res = BufError) OR (s.block.btree.bits = 0) THEN
          SetMsg(s.res, "incomplete dynamic bit lengths tree");
          res := DataError; s.block.state := BlkBad
        END;
        IF res # Ok THEN
          s.res.code := res;
          Flush(s);
          EXIT
        END;
        s.block.index := 0;
        s.block.state := BlkDTree  (* can now decode lit/len and distance code lengths *)
      
      | BlkDTree:  (* get code lengths for literal/length and distance trees *)
        WHILE s.block.index < s.block.nlit + s.block.ndist DO
          IF ~Need(s, s.block.btree.bits) THEN EXIT END;
          t := s.block.btree.base + s.buf MOD ASH(1, s.block.btree.bits);
          node := s.block.btree.node[t];
          IF node.base < 16 THEN  (* code length *)
            Dump(s, node.bits);
            s.block.clen[s.block.index] := SHORT(node.base);
            INC(s.block.index)
          ELSE
            CASE node.base OF
            | 16:  (* repeat previous length 3-6 times, using another 2 bits *)
              IF ~Need(s, node.bits+2) THEN EXIT END;
              Dump(s, node.bits); cnt := 3 + s.buf MOD 4; Dump(s, 2);
              IF s.block.index = 0 THEN
                SetMsg(s.res, "invalid bit length repeat (no previous code length)");
                s.res.code := DataError; s.block.state := BlkBad;
                Flush(s);
                EXIT
              END;
              len := s.block.clen[s.block.index-1]
            | 17:  (* repeat code length 0 for 3-10 times, using another 3 bits *)
              IF ~Need(s, node.bits+3) THEN EXIT END;
              Dump(s, node.bits); cnt := 3 + s.buf MOD 8; Dump(s, 3); len := 0
            | 18:  (* repeat code length 0 for 11-138 times, using another 7 bits *)
              IF ~Need(s, node.bits+7) THEN EXIT END;
              Dump(s, node.bits); cnt := 11 + s.buf MOD 128; Dump(s, 7); len := 0
            ELSE
            END;
            IF s.block.index + cnt > s.block.nlit + s.block.ndist THEN
              SetMsg(s.res, "invalid bit length repeat");
              s.res.code := DataError; s.block.state := BlkBad;
              Flush(s);
              EXIT
            END;
            REPEAT
              s.block.clen[s.block.index] := SHORT(SHORT(len));
              INC(s.block.index); DEC(cnt)
            UNTIL cnt = 0
          END
        END;
        
        (* build dynamic trees for literal/length and distance codes *)
        tn.node := s.block.nodes; tn.next := 0;
        MakeLitLenCode(code, 9, 0, s.block.nlit, 257);
        BuildTree(s.block.clen, code, tn, lltree, res);
        IF (res # Ok) OR (lltree.bits = 0) THEN
          IF res = DataError THEN
            SetMsg(s.res, "oversubscribed literal/length tree")
          ELSIF res # MemError THEN
            SetMsg(s.res, "incomplete literal/length tree"); res := DataError
          END
        ELSE
          MakeDistCode(code, 6, s.block.nlit, s.block.ndist, 0);
          BuildTree(s.block.clen, code, tn, dtree, res);
          IF (res # Ok) OR (dtree.bits = 0) & (s.block.nlit > 257) THEN
            IF res = DataError THEN
              SetMsg(s.res, "oversubscribed distance tree")
            ELSIF res = BufError THEN
              SetMsg(s.res, "incomplete distance tree"); res := DataError
            ELSIF res # MemError THEN
              SetMsg(s.res, "empty distance tree with lengths"); res := DataError
            END
          END
        END;
        IF res # Ok THEN
          IF res = DataError THEN s.block.state := BlkBad END;
          s.res.code := res;
          Flush(s);
          EXIT
        END;
        NewCodes(s, lltree, dtree);
        s.block.state := BlkCodes
      
      | BlkCodes:  (* decompress input bits using current codes *)
        InflateCodes(s);
        IF s.res.code # StreamEnd THEN
          Flush(s);
          EXIT
        END;
        s.res.code := Ok;
        FreeCodes(s);
        IF s.block.last THEN s.block.state := BlkDry
        ELSE s.block.state := BlkType
        END
      
      | BlkDry:  (* run out of input, waiting for output buffer to become empty *)
        Flush(s);
        IF s.read # s.write THEN EXIT END;
        s.block.state := BlkDone
      
      | BlkDone:  (* nothing more to do *)
        s.res.code := StreamEnd;
        EXIT
      
      | BlkBad:  (* error in data *)
        s.res.code := DataError;
        EXIT
      
      ELSE  (* programming error *)
        s.res.code := StreamError;
        EXIT
      END
    END
  END InflateBlocks;
  
  PROCEDURE SetBlockDict (VAR s: Stream; VAR dict: ARRAY OF CHAR; offset, len: LONGINT);
  BEGIN
    ASSERT((len <= WindowSize) & (offset + len <= LEN(dict)), 100);
    SYSTEM.MOVE(SYSTEM.ADR(dict[0]), SYSTEM.ADR(s.window[0]), len);
    s.read := len; s.write := len
  END SetBlockDict;
  
  PROCEDURE BlockSyncPoint (VAR s: Stream): BOOLEAN;
  BEGIN
    RETURN s.block.state = BlkLens
  END BlockSyncPoint;
  
  
  (*--- Inflate Streams ---*)
  
  PROCEDURE Reset0(VAR stream: Stream);
      VAR check: LONGINT;
  BEGIN
    IF stream.open THEN
      stream.res.msg := NIL;
      IF stream.wrapper THEN stream.inf.state := InfMethod ELSE stream.inf.state := InfBlocks END;
      ResetBlocks(stream, check);
      stream.res.code := Ok
    ELSE
      stream.res.code := StreamError
    END
  END Reset0;
  
  (** reset an opened inflate stream (equivalent to closing and reopening) **)
  PROCEDURE Reset* (VAR stream: Stream);
  BEGIN
    Reset0(stream);
    IF stream.open THEN
      ZlibBuffers.Reset(stream.in); ZlibBuffers.Reset(stream.out);
    END
  END Reset;
  
  (** initialize inflate stream; if 'wrapper' is not set, the stream has no zlib header and no checksum **)
  PROCEDURE Open* (VAR stream: Stream; wrapper: BOOLEAN);
    VAR checkFn: CheckFunc;
  BEGIN
    stream.res.msg := NIL;
    stream.wrapper := wrapper; stream.open := TRUE;
    IF wrapper THEN checkFn := Zlib.Adler32 ELSE checkFn := NIL END;
    NewBlocks(stream, checkFn);
    IF stream.res.code = Ok THEN
      Reset(stream)
    END
  END Open;
  
  (** close inflate stream **)
  PROCEDURE Close* (VAR stream: Stream);
  BEGIN
    FreeBlocks(stream);
    stream.res.code := Ok
  END Close;
  
  (** inflate until either input or output buffer runs out; if op is 'Finish', Inflate returns with either 'StreamEnd' or an error **)
  PROCEDURE Inflate* (VAR stream: Stream; flush: SHORTINT);
    VAR res: LONGINT; byte: CHAR; (* inxt, onxt: LONGINT; *)
  BEGIN
    IF ~stream.open THEN
      stream.res.code := StreamError
    ELSE
      IF flush = Finish THEN res := BufError  (* must never run out of buffer space *)
      ELSE res := Ok  (* can return anytime if some progress has been made *)
      END;
      stream.res.code := BufError;  (* set result code for case that no progress can be done *)
      LOOP
        IF stream.inf.state IN {InfMethod, InfFlag, InfDict4..InfDict1, InfCheck4..InfCheck1} THEN  (* need byte *)
          IF stream.in.avail = 0 THEN EXIT END;
          stream.res.code := res;
          ZlibBuffers.Read(stream.in, byte);
        END;
        CASE stream.inf.state OF
        | InfMethod:  (* get compression method and number of window bits *)
          stream.inf.method := ORD(byte);
          IF stream.inf.method MOD 10H # DeflateMethod THEN
            stream.inf.state := InfBad; stream.inf.marker := 5;  (* can't sync *)
            SetMsg(stream.res, "unknown compression method")
          ELSIF stream.inf.method DIV 10H + 8 > WindowBits THEN
            stream.inf.state := InfBad; stream.inf.marker := 5;  (* can't sync *)
            SetMsg(stream.res, "invalid window size")
          ELSE
            stream.inf.state := InfFlag
          END
        | InfFlag:  (* get flag byte *)
          IF (ASH(stream.inf.method, 8) + ORD(byte)) MOD 31 # 0 THEN
            stream.inf.state := InfBad; stream.inf.marker := 5;  (* can't sync *)
            SetMsg(stream.res, "incorrect header check")
          ELSIF ODD(ORD(byte) DIV PresetDict) THEN
            stream.inf.state := InfDict4
          ELSE
            stream.inf.state := InfBlocks
          END
        
        | InfDict4:  (* getting first byte of dictionary checksum *)
          stream.inf.check.stored := ASH(ORD(byte), 24);
          stream.inf.state := InfDict3
        | InfDict3:  (* getting second byte of dictionary checksum *)
          INC(stream.inf.check.stored, ASH(ORD(byte), 16));
          stream.inf.state := InfDict2
        | InfDict2:  (* getting third byte of dictionary checksum *)
          INC(stream.inf.check.stored, ASH(ORD(byte), 8));
          stream.inf.state := InfDict1
        | InfDict1:  (* getting final byte of dictionary checksum *)
          INC(stream.inf.check.stored, LONG(ORD(byte)));
          stream.inf.state := InfDict0;
          stream.res.code := NeedDict;
          EXIT
        | InfDict0:  (* client didn't provide dictionary as requested *)
          stream.inf.state := InfBad; stream.inf.marker := 0;  (* can try sync *)
          SetMsg(stream.res, "need dictionary");
          stream.res.code := StreamError;
          EXIT
        
        | InfBlocks:  (* decoding blocks *)
          (* inxt := stream.in.next; onxt := stream.out.next; *)
          InflateBlocks(stream);
          (* INC(stream.totalIn, stream.in.next - inxt); INC(stream.totalOut, stream.out.next - onxt); *)
          IF stream.res.code = DataError THEN
            stream.inf.state := InfBad; stream.inf.marker := 0  (* can try sync *)
          ELSIF stream.res.code = StreamEnd THEN
            stream.res.code := res;
            ResetBlocks(stream, stream.inf.check.calc);
            IF stream.wrapper THEN stream.inf.state := InfCheck4
            ELSE stream.inf.state := InfDone
            END
          ELSE
            IF stream.res.code = Ok THEN stream.res.code := res END;
            EXIT
          END
        
        | InfCheck4:  (* get first byte of checksum *)
          stream.inf.check.stored := ASH(ORD(byte), 24);
          stream.inf.state := InfCheck3
        | InfCheck3:  (* get second byte of checksum *)
          INC(stream.inf.check.stored, ASH(ORD(byte), 16));
          stream.inf.state := InfCheck2
        | InfCheck2:  (* get third byte of checksum *)
          INC(stream.inf.check.stored, ASH(ORD(byte), 8));
          stream.inf.state := InfCheck1
        | InfCheck1:  (* get final byte of checksum *)
          INC(stream.inf.check.stored, LONG(ORD(byte)));
          IF stream.inf.check.stored # stream.inf.check.calc THEN
            stream.inf.state := InfBad; stream.inf.marker := 5;  (* can't sync *)
            SetMsg(stream.res, "incorrect data check")
          ELSE
            stream.inf.state := InfDone
          END
        
        | InfDone:  (* nothing more to do *)
          stream.res.code := StreamEnd;
          EXIT
        | InfBad:  (* error in stream *)
          stream.res.code := DataError;
          EXIT
        ELSE
        END
      END
    END
  END Inflate;
  
  (** set dictionary if inflate returned 'NeedDict' **)
  PROCEDURE SetDictionary* (VAR stream: Stream; VAR dict: ARRAY OF CHAR; dictLen: LONGINT);
    VAR len, idx: LONGINT;
  BEGIN
    IF stream.open & (stream.inf.state = InfDict0) THEN
      IF Zlib.Adler32(1, dict, 0, dictLen) = stream.inf.check.stored THEN
        len := dictLen; idx := 0;
        IF len >= WindowSize THEN
          len := WindowSize-1;
          idx := dictLen - len
        END;
        SetBlockDict(stream, dict, idx, len);
        stream.inf.state := InfBlocks;
        stream.res.code := Ok
      ELSE
        stream.res.code := DataError;
      END
    ELSE
      stream.res.code := StreamError
    END
  END SetDictionary;
  
  (** try to synchronize stream to end of block generated with 'SyncFlush' or 'FullFlush' **)
  PROCEDURE Sync* (VAR stream: Stream);
    VAR m: LONGINT; mark: ARRAY 4 OF CHAR; byte: CHAR;
  BEGIN
    IF ~stream.open THEN
      stream.res.code := StreamError
    ELSE
      IF stream.inf.state # InfBad THEN
        stream.inf.state := InfBad; stream.inf.marker := 0
      END;
      IF stream.in.avail = 0 THEN
        stream.res.code := BufError
      ELSE
        mark[0] := 0X; mark[1] := 0X; mark[2] := 0FFX; mark[3] := 0FFX;
        m := stream.inf.marker;
        WHILE (stream.in.avail > 0) & (m < 4) DO
          ZlibBuffers.Read(stream.in, byte);
          IF byte = mark[m] THEN INC(m)
          ELSIF byte = 0X THEN m := 0
          ELSE m := 4-m
          END;
        END;
        stream.inf.marker := SHORT(m);
        
        IF m # 4 THEN  (* need more characters in order to decide *)
          stream.res.code := DataError
        ELSE
          Reset0(stream);
          stream.inf.state := InfBlocks;
          stream.res.code := Ok
        END
      END
    END
  END Sync;
  
  (** return if inflate is currently at end of block generated with 'SyncFlush' or 'FullFlush' **)
  PROCEDURE SyncPoint* (VAR stream: Stream): BOOLEAN;
  BEGIN
    IF stream.open THEN
      RETURN BlockSyncPoint(stream)
    ELSE
      stream.res.code := StreamError;
      RETURN FALSE
    END
  END SyncPoint;
  
  (** uncompress complete stream and return output length in len **)
  PROCEDURE Uncompress* (VAR src, dst: ARRAY OF CHAR; srcoffset, srclen, dstoffset, dstlen: LONGINT; VAR len: LONGINT; VAR res: Result);
    VAR s: Stream;
  BEGIN
    ZlibBuffers.Init(s.in, src, srcoffset, srclen, srclen);
    ZlibBuffers.Init(s.out, dst, dstoffset, dstlen, dstlen);
    Open(s, TRUE);
    IF s.res.code = Ok THEN
      Inflate(s, Finish);
      IF s.res.code = StreamEnd THEN
        len := s.out.totalOut;
        Close(s);
        res := s.res
      ELSE
        res := s.res;
        IF res.code = Ok THEN res.code := BufError END;
        Close(s)
      END
    ELSE
      res := s.res
    END
  END Uncompress;
  

BEGIN
  FixedBuilt := FALSE;
  Order[0] := 16; Order[1] := 17; Order[2] := 18; Order[3] := 0; Order[4] := 8; Order[5] := 7; Order[6] := 9;
  Order[7] := 6; Order[8] := 10; Order[9] := 5; Order[10] := 11; Order[11] := 4; Order[12] := 12; Order[13] := 3;
  Order[14] := 13; Order[15] := 2; Order[16] := 14; Order[17] := 1; Order[18] := 15
END ethZlibInflate.
