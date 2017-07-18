(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethZlibDeflate;  (** Stefan Walthert  **)

  (**
    Compression of byte streams with deflate algorithm
  **)
  
  (*
    01.04.2001 - fixed bug in Deflate (condition before 4th RETURN statement: 
              .. & (flush # BufError) THEN .. instead of .. & (flush # Finish) THEN .. 
  *)
  
IMPORT
  SYSTEM, Zlib := ethZlib, ZlibBuffers := ethZlibBuffers;

CONST
  (** Result codes for compression/decompression functions **)
  Ok* = Zlib.Ok; StreamEnd* = Zlib.StreamEnd; (** regular termination **)
  StreamError* = Zlib.StreamError;DataError* = Zlib.DataError; MemError* = Zlib.MemError; BufError* = Zlib.BufError; (** errors **)
  
  (** Flush values **)
  NoFlush* = Zlib.NoFlush; PartialFlush = Zlib.PartialFlush; SyncFlush* = Zlib.SyncFlush; FullFlush* = Zlib.FullFlush; Finish* = Zlib.Finish;

  (** compression levels **)
  DefaultCompression* = Zlib.DefaultCompression; NoCompression* = Zlib.NoCompression; 
  BestSpeed* = Zlib.BestSpeed; BestCompression* = Zlib.BestCompression;
  
  (** compression strategies **)
  DefaultStrategy* = Zlib.DefaultStrategy; Filtered* = Zlib.Filtered; HuffmanOnly* = Zlib.HuffmanOnly;
  
  (** data type **)
  Binary* = Zlib.Binary; Ascii* = Zlib.Ascii; Unknown* = Zlib.Unknown;
  
  (* stream states *)
  InitState = 1; BusyState = 2; FinishState = 3;
  
  (* block state *)
  NeedMore = 1; BlockDone = 2; FinishStarted = 3; FinishDone = 4;
  
  StoredBlock = 0; StaticTrees = 1; DynamicTrees = 2;  (* block types *)
  Deflated = 8;  (* compression method (by coincidence the only one supported..) *)
  PresetDict = 20H;  (* flag indicating use of a preset dictionary *)
  
  (* Huffman trees *)
  LengthCodes = 29; Literals = 256; LitLenCodes = Literals + 1 + LengthCodes; DistCodes = 30; BitCodes = 19;
  HeapSize = 2 * LitLenCodes + 1; MaxBits = 15; MaxBitLenBits = 7; DistCodeLen = 512; EndBlock = 256; BitBufSize = 16;
  Rep3To6 = 16; RepZero3To10 = 17; RepZero11To138 = 18;
  
  (* window and matches *)
  WindowBits = 15; WindowSize = ASH(1, WindowBits);  (* always use 32k buffer *)
  MinMatch = 3; MaxMatch = 258;
  MinLookAhead = MinMatch + MaxMatch + 1; MaxDist = WindowSize - MinLookAhead;
  TooFar = 4096;  (* matches of length MinMatch are discarded if their distance exceeds this *)
  MemLevel = 8;  (* constant memory level *)
  HashBits = MemLevel + 7; HashSize = ASH(1, HashBits);  (* implies constant number of hash bits *)
  HashShift = (HashBits + (MinMatch - 1)) DIV MinMatch;  (* MinMatch bytes should have effect on hash code *)
  LitBufSize = ASH(1, MemLevel + 6);  (* number of elements in literal/distance buffers *)
  PendingBufSize = ASH(LitBufSize, 2);  (* use 64k pending buffer *)
  
TYPE
  (* Huffman trees *)
  Node = RECORD
    freqOrCode: INTEGER;  (* frequency count / bit string *)
    dadOrLen: INTEGER  (* father node on Huffman tree / length of bit string *)
  END;
  Nodes = POINTER TO ARRAY OF Node;
  
  Bits = POINTER TO ARRAY OF INTEGER;
  
  StaticTree = RECORD
    node: Nodes;
    bits: Bits;  (* extra bits for each code *)
    base: INTEGER;  (* base index for Bits *)
    elems: INTEGER;  (* max number of elements in the tree *)
    maxLength: INTEGER  (* max bit length for the codes *)
  END;
  
  Tree = RECORD
    node: Nodes;  (* dynamic tree *)
    maxCode: INTEGER;  (* largest code with non-zero frequency *)
    static: StaticTree  (* corresponding static tree *)
  END;
  
  Window = ARRAY 2 * WindowSize OF CHAR;  (* double size to keep full dictionary at all times; input is read into upper half *)
  
  PendingBuffer = RECORD
    buf: POINTER TO ARRAY PendingBufSize OF CHAR;    (* memory for pending buffer *)
    beg: LONGINT;    (* next pending byte to write to output buffer *)
    end: LONGINT    (* next pending byte in pending buffer *)
  END;
  
  (** deflate stream **)
  Stream* = RECORD
    in*, out*: ZlibBuffers.Buffer;
    res-: LONGINT;    (** result of last operation **)
    level-: SHORTINT;  (** compression level **)
    strategy-: SHORTINT;  (**compression strategy **)
    dataType-: SHORTINT;  (** Unknown, Binary or Ascii **)
    wrapper-: BOOLEAN;  (** if set, zlib header and checksum are generated **)
    open-: BOOLEAN;    (** if set, stream is initialized **)
    trailerDone: BOOLEAN;  (* if set, the zlib trailer has already been generated *)
    lastFlush: SHORTINT;  (* flush operation of the previous deflate call *)
    status: SHORTINT;    (* current stream state *)
    adler: LONGINT;    (* Adler32 checksum *)
    
    window: POINTER TO Window;  (* memory for sliding window *)
    block: LONGINT;  (* position in window where current block starts (negative if window moved) *)
    hash: LONGINT;  (* hash index of string to insert *)
    prev: POINTER TO ARRAY WindowSize OF LONGINT;  (* link to older string with same hash code (for last 32k strings) *)
    head: POINTER TO ARRAY HashSize OF LONGINT;  (* heads of hash chains for every window position *)
    string: LONGINT;  (* start of string to insert *)
    lookAhead: LONGINT;  (* number of valid bytes ahead in window *)
    match: LONGINT;  (* start of match string *)
    matchLen: LONGINT;  (* length of best match *)
    prevMatch: LONGINT;  (* start of previous match *)
    prevLen: LONGINT;  (* length of best match at previous step *)
    prevAvail: BOOLEAN;  (* set if previous match exists *)
    pend: PendingBuffer;
    
    (* trees *)
    ltree, dtree, btree: Tree;  (* trees for literals/lengths, distances and bit lengths *)
    lnode, dnode, bnode: Nodes;  (* corresponding nodes *)
    bitLenCount: ARRAY MaxBits + 1 OF INTEGER;  (* number of codes at each bit length for optimal tree *)
    heap: ARRAY HeapSize OF INTEGER;  (* heap used to build Huffman tree *)
    heapLen: INTEGER;  (* number of elements in the heap *)
    heapMax: INTEGER;  (* heap element of largest frequency *)
    depth: ARRAY HeapSize OF INTEGER;  (* depth of each subtree for deciding between trees of equal frequency *)
    lbuf: POINTER TO ARRAY LitBufSize OF CHAR;  (* buffer for literals/lengths *)
    dbuf: POINTER TO ARRAY LitBufSize OF INTEGER;  (* buffer for distances *)
    lastLit: LONGINT;  (* running index in lbuf *)
    buf: LONGINT;  (* bit buffer *)
    bits: INTEGER;  (* number of valid bits in bit buffer *)
    lastEobLen: INTEGER;  (* bit length of End Of Block code for last block *)
    optLen: LONGINT;  (* bit length of current block with optimal trees *)
    staticLen: LONGINT;  (* bit length of current block with static trees *)
  END;
    
  Compressor = PROCEDURE (VAR s: Stream; flush: SHORTINT): SHORTINT;
  
VAR
  ExtraLenBits, ExtraDistBits, ExtraBitBits: Bits;
  LTree, DTree, BTree: StaticTree;
  BaseLength: ARRAY LengthCodes OF INTEGER;
  BaseDist: ARRAY DistCodes OF INTEGER;
  LengthCode: ARRAY MaxMatch - MinMatch + 1 OF CHAR;
  DistCode: ARRAY DistCodeLen OF CHAR;
  BitOrder: ARRAY BitCodes OF SHORTINT;
  ConfigTable: ARRAY 10 OF RECORD
    GoodLen: INTEGER;  (* reduce lazy search above this match length *)
    MaxLazy: INTEGER;  (* do not perform lazy search above this match length *)
    NiceLen: INTEGER;  (* quit search above this match length *)
    MaxChain: INTEGER;  (* maximal number of hash entries considered *)
    Compress: Compressor;  (* block compress procedure *)
  END;


(* Put a byte c in the pending buffer *)
PROCEDURE PutChar(VAR pend: PendingBuffer; c: CHAR);
BEGIN
  pend.buf[pend.end] := c;
  INC(pend.end)
END PutChar;

(* Put the 16 LSB of b in LSB order in the pending buffer *)
PROCEDURE Put16BitsLSB(VAR pend: PendingBuffer; b: LONGINT);
BEGIN
  PutChar(pend, CHR(b MOD 100H));
  PutChar(pend, CHR((b DIV 100H) MOD 100H))
END Put16BitsLSB;

(* Put the 16 LSB of b in MSB order in the pending buffer *)
PROCEDURE Put16BitsMSB(VAR pend: PendingBuffer; b: LONGINT);
BEGIN
  PutChar(pend, CHR((b DIV 100H) MOD 100H));
  PutChar(pend, CHR(b MOD 100H))
END Put16BitsMSB;

(* Put the 32 LSB of b in MSB order in the pending buffer *)
PROCEDURE Put32BitsMSB(VAR pend: PendingBuffer; b: LONGINT);
BEGIN
  Put16BitsMSB(pend, (b DIV 10000H) MOD 10000H);
  Put16BitsMSB(pend, b MOD 10000H)
END Put32BitsMSB;

(* Reverse the first len bits of a code, using straightforward code *)
PROCEDURE ReverseBits(code, len: INTEGER): INTEGER;
VAR
  res: INTEGER;
BEGIN
  res := 0;
  REPEAT
    res := res * 2; INC(res, code MOD 2);
    code := code DIV 2; DEC(len)
  UNTIL len = 0;
  RETURN res
END ReverseBits;

(* Send a value on a given number of bits *)
PROCEDURE SendBits(VAR stream: Stream; val: LONGINT; len: INTEGER);
BEGIN
  INC(stream.buf, ASH(val, stream.bits)); INC(stream.bits, len);
  IF stream.bits > BitBufSize THEN
    Put16BitsLSB(stream.pend, stream.buf);
    stream.buf := SYSTEM.LSH(stream.buf, -BitBufSize); DEC(stream.bits, BitBufSize)
  END
END SendBits;

(* Send a code of the given node. c and node must not have side effects *)
PROCEDURE SendCode(VAR stream: Stream; VAR node: Node);
BEGIN
  SendBits(stream, node.freqOrCode, node.dadOrLen)
END SendCode;

(* Flush the bit buffer, keeping at most 7 bits in it *)
PROCEDURE FlushBits(VAR stream: Stream);
BEGIN
  IF stream.bits = BitBufSize THEN
    Put16BitsLSB(stream.pend, stream.buf);
    stream.buf := 0; stream.bits := 0
  ELSIF stream.bits >= 8 THEN
    PutChar(stream.pend, CHR(stream.buf));
    stream.buf := SYSTEM.LSH(stream.buf, -8); DEC(stream.bits, 8)
  END
END FlushBits;

(* Flush as much pending output as possible. *)
PROCEDURE FlushPending(VAR pend: PendingBuffer; VAR out: ZlibBuffers.Buffer);
VAR
  len: LONGINT;
BEGIN
  len := pend.end - pend.beg;
  IF len > out.avail THEN len := out.avail END;
  IF len > 0 THEN
    ZlibBuffers.WriteBytes(out, pend.buf^, pend.beg, len);
    INC(pend.beg, len);
    IF pend.beg = pend.end THEN
      pend.beg := 0; pend.end := 0
    END
  END
END FlushPending;

(* Flush the bit buffer and align the output on a byte boundary *)
PROCEDURE WindupBits(VAR stream: Stream);
BEGIN
  IF stream.bits > 8 THEN
    Put16BitsLSB(stream.pend, stream.buf)
  ELSIF stream.bits > 0 THEN
    PutChar(stream.pend, CHR(stream.buf))
  END;
  stream.buf := 0; stream.bits := 0
END WindupBits;

(* Set data type to ASCII or Binary, using a crude heuristic: Binary if more than 20% of the bytes are <= 6 or >= 128, ASCII otherwise *)
PROCEDURE SetDataType(VAR stream: Stream);
VAR
  n, ascii, bin: LONGINT;
BEGIN
  n := 0; ascii := 0; bin := 0;
  WHILE n < 7 DO INC(bin, LONG(stream.lnode[n].freqOrCode)); INC(n) END;
  WHILE n < 128 DO INC(ascii, LONG(stream.lnode[n].freqOrCode)); INC(n) END;
  WHILE n < Literals DO INC(bin, LONG(stream.lnode[n].freqOrCode)); INC(n) END;
  IF (4 * bin) > ascii THEN stream.dataType := Binary ELSE stream.dataType := Ascii END
END SetDataType;

(* Generate the codes for a given tree and bit counts (which need not to be optimal) *)
PROCEDURE GenCodes(VAR node: Nodes; maxCode: INTEGER; VAR count: ARRAY OF INTEGER);
VAR
  nextCode: ARRAY MaxBits + 1 OF INTEGER;  (* next code value for each bit length *)
  code, bits, n, len : INTEGER;
BEGIN
  code := 0;
  FOR bits := 1 TO MaxBits DO
    code := SHORT(ASH(code + count[bits - 1], 1));
    nextCode[bits] := code
  END;
  ASSERT(code + count[MaxBits] - 1 = ASH(1, MaxBits) - 1, 110);  (* inconsistent bit counts *)
  FOR n := 0 TO maxCode DO
    len := node[n].dadOrLen;
    IF len # 0 THEN
      node[n].freqOrCode := ReverseBits(nextCode[len], len); INC(nextCode[len])
    END
  END
END GenCodes;

(* Compute optimal bit lengths for a tree and update the total bit length for the current block *)
PROCEDURE GenBitLen(VAR stream: Stream; VAR tree: Tree);
VAR
  node: Nodes;
  stree: StaticTree;
  bits, h, n, m, overflow, xbits : INTEGER;
  freq: LONGINT;
BEGIN
  node := tree.node;
  stree := tree.static;
  overflow := 0;
  FOR bits := 0 TO MaxBits DO stream.bitLenCount[bits] := 0 END;
  (* compute optimal bit lengths *)
  node[stream.heap[stream.heapMax]].dadOrLen := 0;  (* root of heap *)
  FOR h := stream.heapMax + 1 TO HeapSize - 1 DO
    n := stream.heap[h];
    bits := node[node[n].dadOrLen].dadOrLen + 1;
    IF bits > stree.maxLength THEN
      bits := stree.maxLength; INC(overflow)
    END;
    node[n].dadOrLen := bits;  (* replace dad with len information *)
    IF n <= tree.maxCode THEN  (* leaf node *)
      INC(stream.bitLenCount[bits]);
      IF n >= stree.base THEN xbits := stree.bits[n - stree.base] ELSE xbits := 0 END;
      freq := node[n].freqOrCode;
      INC(stream.optLen, freq * (bits + xbits));
      IF stree.node # NIL THEN INC(stream.staticLen, freq * (stree.node[n].dadOrLen + xbits)) END
    END
  END;
  
  IF overflow # 0 THEN
    (* find first bit length which could increase *)
    REPEAT
      bits := stree.maxLength - 1;
      WHILE stream.bitLenCount[bits] = 0 DO DEC(bits) END;
      DEC(stream.bitLenCount[bits]);  (* move one leaf down the tree *)
      INC(stream.bitLenCount[bits + 1], 2);  (* move one overflow item as its brother *)
      DEC(stream.bitLenCount[stree.maxLength]); DEC(overflow, 2)
    UNTIL overflow <= 0;
    
    (* recompute all bit lengths, scanning in increasing frequency *)
    bits := stree.maxLength;
    WHILE bits > 0 DO
      n := stream.bitLenCount[bits];
      WHILE n # 0 DO
        DEC(h); m := stream.heap[h];
        IF m <= tree.maxCode THEN
          IF node[m].dadOrLen # bits THEN
            INC(stream.optLen, (bits - node[m].dadOrLen) * LONG(node[m].freqOrCode));
            node[m].dadOrLen := bits
          END;
          DEC(n)
        END
      END;
      DEC(bits)
    END
  END
END GenBitLen;

(* Restore heap property by moving down the tree starting at node k, exchanging a node with smallest child if necessary,
  stopping when heap property is re-established (each father smaller than its two children *)
PROCEDURE Sift(VAR stream: Stream; VAR node: Nodes; k: INTEGER);
VAR
  v, i: INTEGER;

  (* Compare subtrees, using tree depth as tie breaker when subtrees have equal frequency -> minimizes worst case length *)
  PROCEDURE Smaller(n, m: INTEGER): BOOLEAN;
  BEGIN
    RETURN (node[n].freqOrCode < node[m].freqOrCode) OR 
      ((node[n].freqOrCode = node[m].freqOrCode) & (stream.depth[n] <= stream.depth[m]))
  END Smaller;
  
BEGIN
  v := stream.heap[k];
  i := k * 2;  (* left child of k *)
  WHILE (i <= stream.heapLen)  DO
    IF (i < stream.heapLen) & Smaller(stream.heap[i + 1], stream.heap[i]) THEN INC(i) END;  (* i: smallest child *)
    IF Smaller(v, stream.heap[i]) THEN
      stream.heap[k] := v; RETURN
    ELSE
      stream.heap[k] := stream.heap[i]; k := i;  (* exchange v with smallest child *)
      i := i * 2  (* set j to the left child of k *)
    END
  END;
  stream.heap[k] := v
END Sift;

(* Construct one Huffman tree and assign the code bit strings and lengths. Update the total bit length for the current block.
  IN assertion: field freqOrCode is set for all tree elements
  OUT assertions: the fields dadOrLen and freqOrCode are set to the optimal bit length and corresponding code.
    The stream.optLen is updated; stream.staticLen is also updated if snode is not null. The field maxCode is set. *)
PROCEDURE BuildTree(VAR stream: Stream; VAR tree: Tree);
VAR
  node: Nodes;
  stree: StaticTree;
  n, m, maxCode, next: INTEGER;
BEGIN
  node := tree.node; stree := tree.static; maxCode := -1;

  (* construct initial heap *)
  stream.heapLen := 0; stream.heapMax := HeapSize;
  FOR n := 0 TO stree.elems - 1 DO
    IF node[n].freqOrCode # 0 THEN
      maxCode := n;
      INC(stream.heapLen); stream.heap[stream.heapLen] := n;
      stream.depth[n] := 0
    ELSE
      node[n].dadOrLen := 0
    END
  END;
  
  (* force at least two codes of non zero frequency in order to be compliant with pkzip format *)
  WHILE stream.heapLen < 2 DO
    INC(stream.heapLen);
    IF maxCode < 2 THEN INC(maxCode); n := maxCode ELSE n := 0 END;
    stream.heap[stream.heapLen] := n;
    node[n].freqOrCode := 1;
    stream.depth[n] := 0;
    DEC(stream.optLen);
    IF stree.node # NIL THEN DEC(stream.staticLen, LONG(stree.node[n].dadOrLen)) END;  (* n IN {0, 1}, thus no extra bits *)
  END;
  tree.maxCode := maxCode;
  
  (* build heap *)
  FOR n := stream.heapLen DIV 2 TO 1 BY -1 DO
    Sift(stream, node, n)
  END;
  
  (* construct Huffman tree by repeatedly combining the least two frequent nodes *)
  next := stree.elems;
  REPEAT
    n := stream.heap[1];
    stream.heap[1] := stream.heap[stream.heapLen];
    DEC(stream.heapLen);
    Sift(stream, node, 1);
    m := stream.heap[1];  (* n: node of least frequency; m: node of next least frequency *)
    DEC(stream.heapMax); stream.heap[stream.heapMax] := n;  (* keep the nodes sorted by frequency *)
    DEC(stream.heapMax); stream.heap[stream.heapMax] := m;
    node[next].freqOrCode := node[n].freqOrCode + node[m].freqOrCode;  (* create a new father of n and m *)
    IF stream.depth[n] > stream.depth[m] THEN stream.depth[next] := stream.depth[n] + 1
    ELSE stream.depth[next] := stream.depth[m] + 1
    END;
    node[n].dadOrLen := next; node[m].dadOrLen := next;
    (* and insert the new node in the heap *)
    stream.heap[1] := next; INC(next);
    Sift(stream, node, 1);
  UNTIL stream.heapLen < 2;
  DEC(stream.heapMax); stream.heap[stream.heapMax] := stream.heap[1];
  (* field freqOrCode and dadOrLen are set -> generate bit lengths *)
  GenBitLen(stream, tree);
  (* field dadOrLen is set -> generate bit codes *)
  GenCodes(node, maxCode, stream.bitLenCount)
END BuildTree;

(* Scan a literal or distance tree to determine the frequencies of the codes in the bit length tree. *)
PROCEDURE ScanTree(VAR stream: Stream; node: Nodes; max: INTEGER);
VAR
  n, prevLen, curLen, nextLen, count, maxCount, minCount: INTEGER;
BEGIN
  prevLen := -1; nextLen := node[0].dadOrLen; count := 0;
  IF nextLen = 0 THEN maxCount := 138; minCount := 3
  ELSE maxCount := 7; minCount := 4
  END;
  node[max + 1].dadOrLen := MAX(INTEGER);  (* sentinel *)
  FOR n := 0 TO max DO
    curLen := nextLen; nextLen := node[n + 1].dadOrLen;
    INC(count);
    IF (count >= maxCount) OR (curLen # nextLen) THEN
      IF count < minCount THEN
        INC(stream.bnode[curLen].freqOrCode, count);
      ELSIF curLen # 0 THEN
        IF curLen # prevLen THEN INC(stream.bnode[curLen].freqOrCode) END;
        INC(stream.bnode[Rep3To6].freqOrCode)
      ELSIF count <= 10 THEN
        INC(stream.bnode[RepZero3To10].freqOrCode)
      ELSE
        INC(stream.bnode[RepZero11To138].freqOrCode)
      END;
      count := 0; prevLen := curLen;
      IF nextLen = 0 THEN maxCount := 138; minCount := 3
      ELSIF curLen = nextLen THEN maxCount := 6; minCount := 3
      ELSE maxCount := 7; minCount := 4
      END
    END
  END
END ScanTree;

(* Construct the Huffman tree for the bit lengths and return the index in BitOrder of the last bit length code to send. *)
PROCEDURE BuildBitLenTree(VAR stream: Stream): INTEGER;
VAR
  max: INTEGER;  (* index of last bit length code of non zero frequency *)
BEGIN
  (* determine the bit length frequencies for literal and distance trees *)
  ScanTree(stream, stream.ltree.node, stream.ltree.maxCode);
  ScanTree(stream, stream.dtree.node, stream.dtree.maxCode);
  BuildTree(stream, stream.btree);  (* build bit length tree *)
  (* stream.optLen now includes the length of the tree representations, except the lengths of the bit lengths codes
    and the 5 + 5 + 4 bits for the count *)
  (* determine the number of bit length codes to send; the pkzip format requires that at least 4 bit length codes to be sent *)
  max := BitCodes - 1;
  WHILE (max >= 3) & (stream.bnode[BitOrder[max]].dadOrLen = 0) DO DEC(max) END;
  (* update stream.optLen to include the bit length tree and counts *)
  INC(stream.optLen, LONG(3 * (max + 1) + 5 + 5 + 4));
  RETURN max
END BuildBitLenTree;

(* Send a literal or distance tree in compressed form, using the codes in stream.bnode.
  tree: the tree to be scanned; max: its largest code of non zero frequency *)
PROCEDURE SendTree(VAR stream: Stream; node: Nodes; max: INTEGER);
VAR
  n, prevLen, curLen, nextLen, count, maxCount, minCount: INTEGER;
BEGIN
  prevLen := -1; nextLen := node[0].dadOrLen; count := 0;
  IF nextLen = 0 THEN maxCount := 138; minCount := 3
  ELSE maxCount := 7; minCount := 4 END;
  node[max + 1].dadOrLen := MAX(INTEGER);  (* sentinel *)
  FOR n := 0 TO max DO
    curLen := nextLen; nextLen := node[n + 1].dadOrLen;
    INC(count);
    IF (count >= maxCount) OR (curLen # nextLen) THEN
      IF count < minCount THEN
        REPEAT
          SendCode(stream, stream.bnode[curLen]);
          DEC(count)
        UNTIL count = 0
      ELSIF curLen # 0 THEN
        IF curLen # prevLen THEN
          SendCode(stream, stream.bnode[curLen]); DEC(count)
        END;
        ASSERT((3 <= count) & (count <= 6), 110);
        SendCode(stream, stream.bnode[Rep3To6]); SendBits(stream, count - 3, 2)
      ELSIF count <= 10 THEN
        SendCode(stream, stream.bnode[RepZero3To10]); SendBits(stream, count - 3, 3)
      ELSE
        SendCode(stream, stream.bnode[RepZero11To138]); SendBits(stream, count - 11, 7)
      END;
      count := 0; prevLen := curLen;
      IF nextLen = 0 THEN maxCount := 138; minCount := 3
      ELSIF curLen = nextLen THEN maxCount := 6; minCount := 3
      ELSE maxCount := 7; minCount := 4
      END
    END
  END
END SendTree;

(* Send the header for a block using dynamic Huffman trees: the counts, the lengths of the bit length codes, the literal tree
  and the distance tree.
  lcodes, dcodes, blcodes: number of codes for each tree *)
PROCEDURE SendAllTrees(VAR stream: Stream; lcodes, dcodes, blcodes: INTEGER);
VAR
  rank: INTEGER;  (* index in BitOrder *)
BEGIN
  ASSERT((lcodes >= 257) & (dcodes >= 1) & (blcodes >= 4), 100);  (* not enough codes *)
  ASSERT((lcodes <= LitLenCodes) & (dcodes <= DistCodes) & (blcodes <= BitCodes), 101);  (* too many codes *)
  SendBits(stream, lcodes - 257, 5); SendBits(stream, dcodes - 1, 5); SendBits(stream, blcodes - 4, 4);
  FOR rank := 0 TO blcodes - 1 DO
    SendBits(stream, stream.bnode[BitOrder[rank]].dadOrLen, 3)
  END;
  SendTree(stream, stream.lnode, lcodes - 1);  (* literal tree *)
  SendTree(stream, stream.dnode, dcodes - 1)  (* distance tree *)
END SendAllTrees;

(* Initialize the various constant tables *)
PROCEDURE InitStaticTrees();
VAR
  n, code: LONGINT;
  length, dist: INTEGER;
  count: ARRAY MaxBits + 1 OF INTEGER;  (* number of codes at each bit length for an optimal tree *)
BEGIN
  NEW(ExtraLenBits, LengthCodes);
  FOR n := 0 TO 3 DO ExtraLenBits[n] := 0 END;
  FOR n := 4 TO LengthCodes - 2 DO ExtraLenBits[n] := SHORT((n - 4) DIV 4) END;
  ExtraLenBits[LengthCodes - 1] := 0;
  
  NEW(ExtraDistBits, DistCodes);
  FOR n := 0 TO 1 DO ExtraDistBits[n] := 0 END;
  FOR n := 2 TO DistCodes - 1 DO ExtraDistBits[n] := SHORT((n - 2) DIV 2) END;
  
  NEW(ExtraBitBits, BitCodes);
  FOR n := 0 TO BitCodes - 4 DO ExtraBitBits[n] := 0 END;
  ExtraBitBits[BitCodes - 3] := 2; ExtraBitBits[BitCodes - 2] := 3; ExtraBitBits[BitCodes - 1] := 7;
  
  BitOrder[0] := 16; BitOrder[1] := 17; BitOrder[2] := 18; BitOrder[3] := 0; BitOrder[4] := 8; BitOrder[5] := 7; BitOrder[6] := 9;
  BitOrder[7] := 6; BitOrder[8] := 10; BitOrder[9] := 5; BitOrder[10] := 11; BitOrder[11] := 4; BitOrder[12] := 12; BitOrder[13] := 3;
  BitOrder[14] := 13; BitOrder[15] := 2; BitOrder[16] := 14; BitOrder[17] := 1; BitOrder[18] := 15;
  
  (* initialize the mapping length (0..255) -> length code (0..28) *)
  length := 0;
  FOR code := 0 TO LengthCodes - 2 DO
    BaseLength[code] := length;
    FOR n := 0 TO ASH(1, ExtraLenBits[code]) - 1 DO
      LengthCode[length] := CHR(code); INC(length)
    END
  END;
  ASSERT(length = 256, 110);
  (* Note that length code 255 (match length 258) can be represented in two different ways: code 284 + 5 bits or code 285,
    so we overwrite LengthCode[255] to use the best encoding: *)
  LengthCode[length - 1] := CHR(code);
  
  (* initialize the mapping dist (0..32K) -> dist code (0..29) *)
  dist := 0;
  FOR code := 0 TO 15 DO
    BaseDist[code] := dist;
    FOR n := 0 TO ASH(1, ExtraDistBits[code]) - 1 DO
      DistCode[dist] := CHR(code); INC(dist)
    END
  END;
  ASSERT(dist = 256, 111);
  
  dist := SHORT(ASH(dist, -7));  (* from now on, all distances are divided by 128 *)
  FOR code := 16 TO DistCodes - 1 DO
    BaseDist[code] := SHORT(ASH(dist, 7));
    FOR n := 0 TO ASH(1, ExtraDistBits[code] - 7) - 1 DO
      DistCode[256 + dist] := CHR(code); INC(dist)
    END
  END;
  ASSERT(dist = 256, 112);
  
  (* construct the codes of the static literal tree *)
  NEW(LTree.node, LitLenCodes + 2);
  LTree.bits := ExtraLenBits; LTree.base := Literals + 1; LTree.elems := LitLenCodes; LTree.maxLength := MaxBits;
  FOR n := 0 TO MaxBits DO count[n] := 0 END;
  FOR n := 0 TO 143 DO LTree.node[n].dadOrLen := 8 END; INC(count[8], 143 - (-1));
  FOR n := 144 TO 255 DO LTree.node[n].dadOrLen := 9 END; INC(count[9], 255 - 143);
  FOR n := 256 TO 279 DO LTree.node[n].dadOrLen := 7 END; INC(count[7], 279 - 255);
  FOR n := 280 TO 287 DO LTree.node[n].dadOrLen := 8 END; INC(count[8], 287 - 279);
  (* codes 286 and 287 do not exist, but we must include them in the tree construction to get a canonical Huffman tree 
    (longest code all ones) *)
  GenCodes(LTree.node, LitLenCodes + 1, count);
  
  (* construct the codes of the static distance tree (trivial) *)
  NEW(DTree.node, DistCodes);
  DTree.bits := ExtraDistBits; DTree.base := 0; DTree.elems := DistCodes; DTree.maxLength := MaxBits;
  FOR n := 0 TO DistCodes - 1 DO
    DTree.node[n].dadOrLen := 5;
    DTree.node[n].freqOrCode := ReverseBits(SHORT(n), 5)
  END;
  
  BTree.node := NIL;
  BTree.bits := ExtraBitBits; BTree.base := 0; BTree.elems := BitCodes; BTree.maxLength := MaxBitLenBits;
END InitStaticTrees;

(* Initialize a new block *)
PROCEDURE InitBlock(VAR stream: Stream);
VAR
  n: LONGINT;  (* iterates over tree elements *)
BEGIN
  FOR n := 0 TO LitLenCodes - 1 DO stream.lnode[n].freqOrCode := 0 END;
  FOR n := 0 TO DistCodes - 1 DO stream.dnode[n].freqOrCode := 0 END;
  FOR n := 0 TO BitCodes - 1 DO stream.bnode[n].freqOrCode := 0 END;
  stream.lnode[EndBlock].freqOrCode := 1;
  stream.optLen := 0; stream.staticLen := 0;
  stream.lastLit := 0
END InitBlock;

(* Initialize the tree data structures for a new zlib stream *)
PROCEDURE InitTrees(VAR stream: Stream);
BEGIN
  NEW(stream.lnode, HeapSize); NEW(stream.dnode, 2 * DistCodes + 1); NEW(stream.bnode, 2 * BitCodes + 1);
  stream.ltree.node := stream.lnode; stream.dtree.node := stream.dnode; stream.btree.node := stream.bnode;
  stream.ltree.static := LTree; stream.dtree.static := DTree; stream.btree.static := BTree;
  stream.buf := 0; stream.bits := 0; stream.lastEobLen := 8;  (* enough lookahead for inflate *)
  InitBlock(stream)
END InitTrees;

PROCEDURE FreeTrees(VAR stream: Stream);
BEGIN
  stream.lnode := NIL; stream.dnode := NIL; stream.bnode := NIL
END FreeTrees;

(* Send one empty static block to give enough lookahead for inflate. This takes 10 bits, of which 7 may remain in the bit buffer.
  The current inflate code requires 9 bits of lookahead. If the last two codes for the previous block (real code plus end of block)
  were coded on 5 bits or less, inflate may have only 5 + 3 bits of lookahead to decode the las real code.
  In this case we send two empty static blocks instead of one. (There are no problems if the previous block is stored or fixed.)
  To simplify the code, we assume the worst case of last real code encoded on one bit only *)
PROCEDURE AlignTrees(VAR stream: Stream);
BEGIN
  SendBits(stream, SHORT(ASH(StaticTrees, 1)), 3);
  SendCode(stream, LTree.node[EndBlock]);
  FlushBits(stream);
  (* Of the 10 bits for the empty block, we have already sent (10 - stream.bits) bits. The lookahead for the last real code
    (before end of block of the previous block) was thus at least one plus the length of the end of block what we have
    just sent of the empty static block. *)
  IF (1 + stream.lastEobLen + 10 - stream.bits) < 9 THEN
    SendBits(stream, SHORT(ASH(StaticTrees, 1)), 3);
    SendCode(stream, LTree.node[EndBlock]);
    FlushBits(stream)
  END;
  stream.lastEobLen := 7
END AlignTrees;

(* Copy a stored block, storing first the length and its one's complement if requested *)
PROCEDURE CopyBlock(VAR stream: Stream; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; header: BOOLEAN);
VAR
BEGIN
  WindupBits(stream);  (* align on byte boundary *)
  stream.lastEobLen := 8;  (* enough lookahead for inflate *)
  IF header THEN
    Put16BitsLSB(stream.pend, len);  (* LEN *)
    Put16BitsLSB(stream.pend, -(len + 1));  (* NLEN (1's complement of LEN) *)
  END;
  WHILE len > 0 DO
    PutChar(stream.pend, buf[offset]);
    INC(offset); DEC(len)
  END
END CopyBlock;

(* Send a stored block *)
PROCEDURE StoreBlock(VAR stream: Stream; VAR buf: ARRAY OF CHAR; offset, len: LONGINT; eof: BOOLEAN);
VAR
  value: LONGINT;
BEGIN
  value := ASH(StoredBlock, 1);
  IF eof THEN INC(value) END;
  SendBits(stream, value, 3);  (* send block type *)
  CopyBlock(stream, buf, offset, len, TRUE);  (* with header *)
END StoreBlock;

(* Send the block data compressed using the given Huffman trees *)
PROCEDURE CompressBlock(VAR stream: Stream; lnode, dnode: Nodes);
VAR
  dist: INTEGER;  (* distance of matched string *)
  lc: INTEGER;  (* match length or unmatched char (if dist = 0) *)
  code: INTEGER;  (* the code to send *)
  extra: INTEGER;  (* number of extra bits to send *)
  lx: LONGINT;  (* running index in lbuf and dbuf *)
BEGIN
  IF stream.lastLit # 0 THEN
    lx := 0;
    REPEAT
      dist := stream.dbuf[lx];
      lc := ORD(stream.lbuf[lx]);
      INC(lx);
      IF dist = 0 THEN
        SendCode(stream, lnode[lc]);  (* send a literal byte *)
      ELSE  (* lc is (match length - MinMatch) *)
        code := ORD(LengthCode[lc]);
        SendCode(stream, lnode[code + Literals + 1]);  (* send length code *)
        extra := ExtraLenBits[code];
        IF extra # 0 THEN
          DEC(lc, BaseLength[code]);
          SendBits(stream, lc, extra)
        END;
        DEC(dist);  (* dist is now (match distance - 1) *)
        IF dist < 256 THEN code := ORD(DistCode[dist]);
        ELSE code := ORD(DistCode[256 + ASH(dist, -7)])
        END;
        ASSERT(code < DistCodes, 110);  (* bad DistCode *)
        SendCode(stream, dnode[code]);
        extra := ExtraDistBits[code];
        IF extra # 0 THEN
          DEC(dist, BaseDist[code]);
          SendBits(stream, dist, extra)  (* send extra distance bits *)
        END
      END  (* literal or match pair? *)
      (* no need to check for overlay consistency since we don't overlay *)
    UNTIL lx = stream.lastLit
  END;
  SendCode(stream, lnode[EndBlock]);
  stream.lastEobLen := lnode[EndBlock].dadOrLen
END CompressBlock;

(* Flush the current block, with given end-of-file flag, determine the best encoding for the current block:
  dynamic trees, static trees or store, and output the encoded block to the zip file.
  buf: input block, or NULL if too old;
  pos, len: position in and length of input block;
  eof: true if this is the last block for a file;
  IN assertion: stream.string is set to the end of the current match *)
PROCEDURE FlushBlock(VAR stream: Stream; VAR buf: ARRAY OF CHAR; pos, len: LONGINT; eof: BOOLEAN);
VAR
  max: INTEGER;  (* index of last bit length code of non zero freqency *)
  optLen, staticLen: LONGINT;  (* optLen and staticLen in bytes *)
  value: LONGINT;
BEGIN
  IF stream.level > 0 THEN  (* build a Huffman tree unless a stored block is forced *)
    IF stream.dataType = Unknown THEN SetDataType(stream) END;  (* check if the file is ascii or binary *)
    BuildTree(stream, stream.ltree);  (* construct the literal .. *)
    BuildTree(stream, stream.dtree);  (* .. and the distance tree *)
    (* at this point, stream.optLen and stream.staticLen are the total bit lengths of the compressed block data, 
      excluding tree representations *)
    max := BuildBitLenTree(stream);  (* build bit length tree for the above tow trees, get the index of the last bit length code *)
    optLen := (stream.optLen + 3 + 7) DIV 8;
    staticLen := (stream.staticLen + 3 + 7) DIV 8;
    IF staticLen < optLen THEN optLen := staticLen END;
  ELSE
    ASSERT(pos >= 0, 110);  (* lost buf *)
    optLen := len + 5;
    staticLen := optLen
  END;
  IF len + 4 <= optLen THEN  (* 4: two words for the lengths *)
    ASSERT(pos >= 0, 111);  (* see explanation in trees.c, LitBufSize <= WindowSize avoids lost block *)
    StoreBlock(stream, buf, pos, len, eof);
  ELSIF staticLen = optLen THEN
    value := ASH(StaticTrees, 1);
    IF eof THEN INC(value) END;
    SendBits(stream, value, 3);
    CompressBlock(stream, LTree.node, DTree.node)
  ELSE
    value := ASH(DynamicTrees, 1);
    IF eof THEN INC(value) END;
    SendBits(stream, value, 3);
    SendAllTrees(stream, stream.ltree.maxCode + 1, stream.dtree.maxCode + 1, max + 1);
    CompressBlock(stream, stream.lnode, stream.dnode);
  END;
  InitBlock(stream);
  IF eof THEN
    WindupBits(stream)
  END
END FlushBlock;

(* Put a literal in the literal buffer (stream.lbuf) *)
PROCEDURE TallyLit(VAR stream: Stream; ch: CHAR): BOOLEAN;
BEGIN
  stream.lbuf[stream.lastLit] := ch;
  stream.dbuf[stream.lastLit] := 0;
  INC(stream.lastLit);
  INC(stream.lnode[ORD(ch)].freqOrCode);
  RETURN (stream.lastLit = LitBufSize - 1)
END TallyLit;

(* Put a distance/length pair in the distance and the length buffer (stream.dbuf, stream.lbuf) *)
PROCEDURE TallyDistLen(VAR stream: Stream; dist, len: INTEGER): BOOLEAN;
BEGIN
  ASSERT(len < 256, 99);
  stream.lbuf[stream.lastLit] := CHR(len);
  stream.dbuf[stream.lastLit] := dist;
  INC(stream.lastLit);
  DEC(dist);
  INC(stream.lnode[ORD(LengthCode[len]) + Literals + 1].freqOrCode);
  IF dist < 256 THEN dist := ORD(DistCode[dist])
  ELSE dist := ORD(DistCode[256 + ASH(dist, -7)])
  END;
  INC(stream.dnode[dist].freqOrCode);
  RETURN (stream.lastLit = LitBufSize - 1)
END TallyDistLen;

(*---Matches---*)

PROCEDURE ClearHash(VAR stream: Stream);
VAR
  i: LONGINT;
BEGIN
  FOR i := 0 TO HashSize - 1 DO
    stream.head[i] := 0
  END
END ClearHash;

(* Update a hash value with the given input byte
  IN assertion: all calls are made with consecutive input characters, so that a running hash key can be computed
  from the previous key instead of complete recalculation each time *)
PROCEDURE UpdateHash(VAR h: LONGINT; ch: CHAR);
BEGIN
  h := SYSTEM.VAL(LONGINT, SYSTEM.VAL(SET, ASH(h, HashShift)) / SYSTEM.VAL(SET, LONG(ORD(ch)))) MOD HashSize
END UpdateHash;

(* Insert string starting at position pos in the dictionary and set head to the previous head of the hash chain 
  (the most recent string with the same hash key). Return the previous length of the hash chain.
  IN assertion: all calls are made with consecutive input characters and the first MinMatch bytes at pos are valid
  (except for the last MinMatch - 1 bytes of the input file *)
PROCEDURE InsertString(VAR stream: Stream; pos: LONGINT; VAR head: LONGINT);
BEGIN
  UpdateHash(stream.hash, stream.window[pos + MinMatch - 1]);
  head := stream.head[stream.hash];
  stream.prev[pos MOD WindowSize] := head;
  stream.head[stream.hash] := pos
END InsertString;

(* initialize the "longes match" routines for a new zlib stream *)
PROCEDURE InitMatches(VAR stream: Stream);
BEGIN
  ClearHash(stream);
  stream.string := 0; stream.block := 0; stream.lookAhead := 0;
  stream.matchLen := MinMatch - 1; stream.prevLen := MinMatch - 1;
  stream.prevAvail := FALSE; stream.hash := 0;
END InitMatches;

(* Set stream.match to the longest match starting at the given string and return its length.
  Matches shorter or equal to stream.prevLen are discarded, in which case the result is equal to stream.prevLen
  and stream.match is garbage.
  IN assertion: cur is the head of the hash chain for the current string (stream.string) and its distance is <= MaxDist,
    and stream.prevLen >= 1.
  OUT assertion: the match length is not greater than stream.lookAhead. *)
PROCEDURE LongestMatch(VAR stream: Stream; cur: LONGINT): LONGINT;
VAR
  chainLen: LONGINT;  (* max hash chain length *)
  scan: LONGINT;  (* current string *)
  match: LONGINT;  (* matched string *)
  len: LONGINT;  (* length of current match *)
  bestLen: LONGINT;  (* best match so far *)
  niceLen: LONGINT;  (* stop if match long enough *)
  limit: LONGINT;  (* stop when cur becomes <= limit *)
  strend: LONGINT;
  scanEnd1, scanEnd: CHAR;
BEGIN
  bestLen := stream.prevLen;
  IF bestLen >= ConfigTable[stream.level].GoodLen THEN
    chainLen := ConfigTable[stream.level].MaxChain DIV 4  (* do not waste too much time if match is already good enough *)
  ELSE
    chainLen := ConfigTable[stream.level].MaxChain;
  END;
  IF ConfigTable[stream.level].NiceLen > stream.lookAhead THEN  (* do not look for matches beyond the end of the input *)
    niceLen := stream.lookAhead
  ELSE
    niceLen := ConfigTable[stream.level].NiceLen
  END;
  scan := stream.string;
  IF scan > MaxDist THEN limit := scan - MaxDist ELSE limit := 0 END;
  strend := scan + MaxMatch;
  scanEnd1 := stream.window[scan + bestLen - 1];
  scanEnd := stream.window[scan + bestLen];
  ASSERT(scan <= 2 * WindowSize - MinLookAhead, 110);  (* need lookahead *)
  len := -1;
  REPEAT
    ASSERT(cur < stream.string, 111);  (* no future *)
    match := cur;
    
    (* skip to next match if match length cannot increase or match lengtch < 2 *)
    IF (stream.window[match + bestLen] = scanEnd) & (stream.window[match + bestLen - 1] = scanEnd1) &
      (stream.window[match] = stream.window[scan]) & (stream.window[match + 1] = stream.window[scan + 1]) THEN
    (* The check at match + bestLen - 1 can be removed because it will be made again later (this heuristic is not always a win).
      It is not necessary to compare match + 2 and scan + 2 since they are always equal when the other bytes match,
      given that the hash keys are equal and that HashBits >= 8 *)
      INC(scan, 2); INC(match, 2);
      ASSERT(stream.window[match] = stream.window[scan], 112);  (* must be equal as well because hash values coincide *)
      REPEAT
        INC(match); INC(scan)
      UNTIL (stream.window[match] # stream.window[scan]) OR (scan >= strend);
      ASSERT(scan <= 2 * WindowSize - 1, 113);  (* wild scan *)
      len := MaxMatch - (strend - scan);
      scan := strend - MaxMatch;
      IF len > bestLen THEN
        stream.match := cur;
        bestLen := len;
        scanEnd1 := stream.window[scan + bestLen - 1];
        scanEnd := stream.window[scan + bestLen]
      END
    END;
    cur := stream.prev[cur MOD WindowSize];
    DEC(chainLen)
  UNTIL (len >= niceLen) OR (cur <= limit) OR (chainLen = 0);
  IF bestLen > MaxMatch THEN bestLen := MaxMatch END;  (* neu *)
  IF bestLen <= stream.lookAhead THEN
    RETURN bestLen
  ELSE
    RETURN stream.lookAhead
  END
END LongestMatch;

(* Check that the match at stream.match is indeed a match *)
PROCEDURE CheckMatch(VAR stream: Stream; start, match, len: LONGINT);
BEGIN
  WHILE len # 0 DO
    ASSERT(stream.window[match] = stream.window[start]);
    INC(match); INC(start); DEC(len)
  END
END CheckMatch;

(* Fill window when lookahead becomes insufficient.
  Updates stream.string and stream.lookAhead *)
PROCEDURE FillWindow(VAR stream: Stream);
VAR
  n, len: LONGINT;
  more: LONGINT;  (* amount of free space at the end of the window *)
BEGIN
  more := 2 * WindowSize - (stream.lookAhead + stream.string);
  REPEAT
    IF stream.string >= WindowSize + MaxDist THEN
      (* lower half is no longer available for matches -> slide window *)
      SYSTEM.MOVE(SYSTEM.ADR(stream.window[WindowSize]), SYSTEM.ADR(stream.window[0]), WindowSize);
      DEC(stream.match, WindowSize); DEC(stream.string, WindowSize); DEC(stream.block, WindowSize);
      (* slide hash table *)
      n := HashSize;
      REPEAT
        DEC(n);
        IF stream.head[n] >= WindowSize THEN
          DEC(stream.head[n], WindowSize)
        ELSE
          stream.head[n] := 0
        END
      UNTIL n = 0;
      n := WindowSize;
      REPEAT
        DEC(n);
        IF stream.prev[n] >= WindowSize THEN
          DEC(stream.prev[n], WindowSize)
        ELSE
          stream.prev[n] := 0
        END
      UNTIL n = 0;
      INC(more, WindowSize)
    END;
    len := stream.in.avail;
    IF len = 0 THEN RETURN END;
    ASSERT(more >= 2, 110);
    IF len > more THEN len := more END;
    ZlibBuffers.ReadBytes(stream.in, stream.window^, stream.string + stream.lookAhead, len);
    IF stream.wrapper THEN
      stream.adler := Zlib.Adler32(stream.adler, stream.window^, stream.string + stream.lookAhead, len);
    END;
    INC(stream.lookAhead, len); DEC(more, len);
    (* initialize hash value now there is some input *)
    IF stream.lookAhead >= MinMatch THEN
      stream.hash := LONG(stream.window[stream.string]);
      UpdateHash(stream.hash, stream.window[stream.string + 1]);
    END
    (* if the whole input has less than MinMatch bytes, stream.hash is garbage,
      but this is not important since only literal bytes will be emitted *)
  UNTIL (stream.lookAhead >= MinLookAhead) OR (stream.in.avail = 0)
END FillWindow;
  
(*---Compressor Methods---*)

(* store without compression as much as possible from the input stream, return the current block state.
  This function does not insert new strings in the dictionary since uncompressible data is probably not useful. *)
PROCEDURE CompressStored(VAR stream: Stream; flush: SHORTINT): SHORTINT;
CONST
  MaxBlockSize = PendingBufSize - 5; (* header for stored block takes 5 bytes *)
BEGIN
  (* MaxBlockSize is the minimum of the maximal block size of 0FFFFH and the size of the pending buffer minus 5 bytes for
    the block header. For MemLevel <= 8, PendingBufSize - 5 < 0FFFFH! *)
  ASSERT(PendingBufSize - 5 < 0FFFFH, 110);
  LOOP
    (* fill the window as much as possible *)
    IF stream.lookAhead <= 1 THEN
      ASSERT((stream.string < (WindowSize + MaxDist)) OR (stream.block >= WindowSize), 111); (* slide too late *)
      FillWindow(stream);
      IF stream.lookAhead = 0 THEN
        IF flush = NoFlush THEN RETURN NeedMore
        ELSE EXIT    (* flush the current block *)
        END
      END
    END;
    ASSERT(stream.block >= 0, 112); (* block gone *)
    INC(stream.string, stream.lookAhead);
    stream.lookAhead := 0;

    (* zlib flushes the block if the pending buffer will be full. With MemLevel = 8 and WindowBits = 15 this is impossible
      since MaxBlockSize is almost twice the window size *)
    ASSERT(stream.string < stream.block + MaxBlockSize, 113);
    
    (* flush if we may have to slide, otherwise stream.block may become negative and the data will be lost *)
    IF (stream.string - stream.block) >= MaxDist THEN
      FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, FALSE);
      stream.block := stream.string;
      FlushPending(stream.pend, stream.out);
      IF stream.out.avail = 0 THEN RETURN NeedMore
      END
    END
  END;
  FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, flush = Finish);
  stream.block := stream.string;
  FlushPending(stream.pend, stream.out);
  IF (stream.out.avail = 0) & (flush = Finish) THEN RETURN FinishStarted
  ELSIF stream.out.avail = 0 THEN RETURN NeedMore
  ELSIF flush = Finish THEN RETURN  FinishDone
  ELSE RETURN BlockDone
  END
END CompressStored;

(* Compress without lazy matches.
  This function inserts new strings in the dictionary only for unmatched strings or for short matches. *)
PROCEDURE CompressFast(VAR stream: Stream; flush: SHORTINT): SHORTINT;
VAR
  head: LONGINT; (* head of the hash chain *)
  mustFlush: BOOLEAN; (* set if current block must be flushed *)
BEGIN
  head := 0;
  LOOP
    (* make sure that we always have enough lookahead, except at the end of the input file.
      We need MaxMatch bytes for the next match, plus MinMatch bytes to insert the string following the next match *)
    IF stream.lookAhead < MinLookAhead THEN
      FillWindow(stream);
      IF (stream.lookAhead < MinLookAhead) & (flush = NoFlush) THEN RETURN NeedMore
      ELSIF stream.lookAhead = 0 THEN EXIT    (* flush the current block *)
      END
    END;
    (* Insert the string window[stream.string .. stream.string + 2] in the dictionary, 
      and set stream.hash to the head of the hash chain *)
    IF stream.lookAhead >= MinMatch THEN
      InsertString(stream, stream.string, head)
    END;
    (* Find the longest match, discarding those <= prevLen. At this point we have always matchLen < MinMatch *)
    IF (head # 0) & ((stream.string - head) <= MaxDist) THEN
      IF stream.strategy # HuffmanOnly THEN  (* avoid matches with string at index 0, in particular with itself *)
        stream.matchLen := LongestMatch(stream, head)  (* LongestMatch sets match *)
      END
    END;
    IF stream.matchLen >= MinMatch THEN
      CheckMatch(stream, stream.string, stream.match, stream.matchLen);
      mustFlush := TallyDistLen(stream, SHORT(stream.string - stream.match), SHORT(stream.matchLen - MinMatch));
      DEC(stream.lookAhead, stream.matchLen);
      (* Insert new strings in the hash table only if the match length is not too large. 
        This saves time but degrades compression *)
      IF (stream.matchLen <= ConfigTable[stream.level].MaxLazy) & (stream.lookAhead >= MinMatch) THEN
        DEC(stream.matchLen);  (* string at stream.string is already in hash table *)
        REPEAT
          INC(stream.string);
          InsertString(stream, stream.string, head);
          (* stream.string never exceeds WindowSize - MaxMatch, so there are always MinMatch bytes ahead *)
          DEC(stream.matchLen)
        UNTIL stream.matchLen = 0;
        INC(stream.string);
      ELSE
        INC(stream.string, stream.matchLen);
        stream.matchLen := 0;
        stream.hash := ORD(stream.window[stream.string]);
        UpdateHash(stream.hash, stream.window[stream.string + 1])
        (* If stream.lookAhead < MinMatch, stream.hash is garbage, 
          but it does not matter since it will recomputed at next Deflate call *)
      END
    ELSE  (* no match, output a literal byte *)
      mustFlush := TallyLit(stream, stream.window[stream.string]);
      DEC(stream.lookAhead);
      INC(stream.string)
    END;
    IF mustFlush THEN
      FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, FALSE);
      stream.block := stream.string;
      FlushPending(stream.pend, stream.out);
      IF stream.out.avail = 0 THEN RETURN NeedMore
      END
    END
  END;
  FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, flush = Finish);
  stream.block := stream.string;
  FlushPending(stream.pend, stream.out);
  IF (stream.out.avail = 0) & (flush = Finish) THEN RETURN FinishStarted
  ELSIF stream.out.avail = 0 THEN RETURN NeedMore
  ELSIF flush = Finish THEN RETURN FinishDone
  ELSE RETURN BlockDone
  END
END CompressFast;

(* Same as above, but achieves a better compression. We use lazy evaluation for matches:
  a match is finally adopted only if there is no better match at the next window position *)
PROCEDURE CompressSlow(VAR stream: Stream; flush: SHORTINT): SHORTINT;
VAR
  head: LONGINT; (* head of the hash chain *)
  maxIns: LONGINT;
  mustFlush: BOOLEAN; (* set if current block must be flushed *)
BEGIN
  head := 0;
  LOOP
    (* make sure that we always have enough lookahead, except at the end of the input file.
      We need MaxMatch bytes for the next match, plus MinMatch bytes to insert the string following the next match *)
    IF stream.lookAhead < MinLookAhead THEN
      FillWindow(stream);
      IF (stream.lookAhead < MinLookAhead) & (flush = NoFlush) THEN RETURN NeedMore
      ELSIF stream.lookAhead = 0 THEN EXIT
      END
    END;
    (* Insert the string window[stream.string .. stream.string + 2] in the dictionary, 
      and set stream.hash to the head of the hash chain *)
    IF stream.lookAhead >= MinMatch THEN
      InsertString(stream, stream.string, head);
    END;
    (* Find the longest match, discarding those <= stream.prevLen *)
    stream.prevLen := stream.matchLen;
    stream.prevMatch := stream.match;
    stream.matchLen := MinMatch - 1;
    IF (head # 0) & (stream.prevLen < ConfigTable[stream.level].MaxLazy) & (stream.string - head <= MaxDist) THEN
      (* avoid matches with string at index 0, in particular with itself *)
      IF stream.strategy # HuffmanOnly THEN
        stream.matchLen := LongestMatch(stream, head);  (* LongestMatch sets stream.match *)
      END;
      IF (stream.matchLen <= 5) & 
        ((stream.strategy = Filtered) OR ((stream.matchLen = MinMatch) & ((stream.string - stream.match) > TooFar))) THEN
        (* If stream.prevMatch is also MinMatch, stream.match is garbage but we will ignore the current match anyway *)
        stream.matchLen := MinMatch - 1
      END
    END;

    (* If there was a match at the previous step and the current match is not better, output the previous match: *)
    IF (stream.prevLen >= MinMatch) & (stream.matchLen <= stream.prevLen) THEN
      maxIns := stream.string + stream.lookAhead - MinMatch;  (* do not insert strings in hash table beyond this *)
      CheckMatch(stream, stream.string - 1, stream.prevMatch, stream.prevLen);
      mustFlush := TallyDistLen(stream, SHORT(stream.string - 1 - stream.prevMatch), SHORT(stream.prevLen - MinMatch));

      (* Insert in hash table all strings up to the end of the match. stream.string - 1 and stream.string are already inserted.
        If there is not enough stream.lookAhead, the last two strings are not inserted in the hash table. *)
      DEC(stream.lookAhead, stream.prevLen - 1);
      DEC(stream.prevLen, 2);
      REPEAT
        INC(stream.string);
        IF stream.string <= maxIns THEN
          InsertString(stream, stream.string, head)
        END;
        DEC(stream.prevLen);
      UNTIL stream.prevLen = 0;
      stream.prevAvail := FALSE;
      stream.matchLen := MinMatch - 1;
      INC(stream.string);
      IF mustFlush THEN
        FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, FALSE);
        stream.block := stream.string;
        FlushPending(stream.pend, stream.out);
        IF stream.out.avail = 0 THEN RETURN NeedMore
        END
      END
    ELSIF stream.prevAvail THEN
      (* If there was no match at the previous position, output a single literal. If there was a match but the current 
        match is longer, truncate the previous match to a single literal. *)
      mustFlush := TallyLit(stream, stream.window[stream.string - 1]);
      IF mustFlush THEN
        FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, FALSE);
        stream.block := stream.string;
        FlushPending(stream.pend, stream.out)
      END;
      INC(stream.string);
      DEC(stream.lookAhead);
      IF stream.out.avail = 0 THEN RETURN NeedMore
      END
    ELSE
      (* There is no previous match to compare with, wait for the next step to decide *)
      stream.prevAvail := TRUE;
      INC(stream.string);
      DEC(stream.lookAhead)
    END
  END;
  ASSERT(flush # NoFlush, 110);
  IF stream.prevAvail THEN
    mustFlush := TallyLit(stream, stream.window[stream.string - 1]);
    stream.prevAvail := FALSE
  END;
  FlushBlock(stream, stream.window^, stream.block, stream.string - stream.block, flush = Finish);
  stream.block := stream.string;
  FlushPending(stream.pend, stream.out);
  IF (stream.out.avail = 0) & (flush = Finish) THEN RETURN FinishStarted
  ELSIF stream.out.avail = 0 THEN RETURN NeedMore
  ELSIF flush = Finish THEN RETURN FinishDone
  ELSE RETURN BlockDone
  END
END CompressSlow;

(**---Streams---**)

(** reset stream **)
PROCEDURE Reset*(VAR stream: Stream);
BEGIN
  IF ~stream.open THEN
    stream.res := StreamError;
  ELSE
    ZlibBuffers.Reset(stream.in); ZlibBuffers.Reset(stream.out);
    stream.dataType := Unknown;
    stream.pend.beg := 0; stream.pend.end := 0;
    stream.trailerDone := FALSE;
    IF stream.wrapper THEN
      stream.status := InitState
    ELSE
      stream.status := BusyState
    END;
    stream.adler := 1;
    stream.lastFlush := NoFlush;
    InitTrees(stream);
    InitMatches(stream);
    stream.res := Ok;
  END
END Reset;

(** close deflate stream **)
PROCEDURE Close*(VAR stream: Stream);
BEGIN
  IF stream.open THEN
    stream.window := NIL; stream.prev := NIL; stream.head := NIL;
    stream.pend.buf := NIL; stream.lbuf := NIL; stream.dbuf := NIL;
    FreeTrees(stream);
    stream.open := FALSE; stream.res := Ok
  ELSE
    stream.res := StreamError
  END
END Close;

(** initialize deflate stream with compression level and strategy; if wrapper is not set, no header and checksum are generated **)
PROCEDURE Open*(VAR stream: Stream; level, strategy: SHORTINT; wrapper: BOOLEAN);
BEGIN
  IF level = DefaultCompression THEN level := 6 END;
  IF (0 <= level) & (level <= 9) & (DefaultStrategy <= strategy) & (strategy <= HuffmanOnly) THEN
    NEW(stream.window); NEW(stream.prev); NEW(stream.head);
    (* zlib overlays pend.buf, lbuf and dbuf. Since memory usage should not be a very big problem and dbuf stores integers 
      instead of bytes they are allocated as seperate memory chunks here *)
    NEW(stream.pend.buf); NEW(stream.lbuf); NEW(stream.dbuf);
    IF (stream.window # NIL) & (stream.prev # NIL) & (stream.head # NIL) 
      & (stream.pend.buf # NIL) & (stream.lbuf # NIL) & (stream.dbuf # NIL) THEN
      stream.level := level; stream.strategy := strategy; stream.wrapper := wrapper; stream.open := TRUE;
      Reset(stream)
    ELSE
      stream.open := FALSE;
      Close(stream);
      stream.res := MemError
    END
  ELSE
    stream.open := FALSE;
    stream.res := StreamError
  END
END Open;

(** initializes the compression dictionary from the given byte sequence without producing any compressed output.
  Must be called immediately after Open or Reset before any call of Deflate **)
PROCEDURE SetDictionary*(VAR stream: Stream; VAR dict: ARRAY OF CHAR; len: LONGINT);
VAR
  offset, i, head: LONGINT;
BEGIN
  IF ~stream.open OR (stream.status # InitState) THEN
    stream.res := StreamError;
    RETURN
  END;
  stream.adler := Zlib.Adler32(stream.adler, dict, 0, len);
  IF len >= MinMatch THEN
    IF len > MaxDist THEN
      offset := len - MaxDist;    (* use the tail of the dictionary *)
      len := MaxDist
    ELSE
      offset := 0
    END;
    SYSTEM.MOVE(SYSTEM.ADR(dict[offset]), SYSTEM.ADR(stream.window[0]), len);
    stream.string := len; stream.block := len;
    (* insert all strings in the hash table (except for the last two bytes). stream.lookAhead stays zero, 
      so stream.hash will be recomputed at the next call of FillWindow *)
    stream.hash := ORD(stream.window[0]);
    UpdateHash(stream.hash, stream.window[1]);
    FOR i := 0 TO (len - MinMatch) DO
      InsertString(stream, i, head)
    END
  END;
  stream.res := Ok
END SetDictionary;
  

(** Deflate compresses as much data as possible, and stops when the input buffer becomes empty or the output buffer becomes full;
  the flush parameter decides if and how blocks are terminated **)
PROCEDURE Deflate*(VAR stream: Stream; flush: SHORTINT);
VAR
  lastFlush, bstate: SHORTINT;
  header: LONGINT;
  buf: ARRAY 1 OF CHAR;
BEGIN
  IF ~stream.open OR (flush < NoFlush) OR (flush > Finish) OR ((stream.status = FinishState) & (flush # Finish)) THEN
    stream.res := StreamError;
    RETURN
  END;
  IF stream.out.avail = 0 THEN
    stream.res := BufError;
    RETURN
  END;
  lastFlush := stream.lastFlush; stream.lastFlush := flush;
  
  (* write zlib header *)
  IF stream.status = InitState THEN
    header := (((WindowBits - 8) * 10H) + Deflated) * 100H;  (* CMF: 7 - 4: CINFO (compression info (=window size - 8)), 3 - 0: CM (compression method) *)
    (* FLG: flags *)  (* FLG.FLEVEL: compression level *)
    IF stream.level >= 7 THEN INC(header, 0C0H)  (* maximum compression, slowest algorithm *)
    ELSIF stream.level >= 5 THEN INC(header, 80H)  (* default algorithm *)
    ELSIF stream.level >= 3 THEN INC(header, 40H)  (* fast algorithm *)
    END;                                    (* ELSE fastest algorithm *)
    IF stream.string # 0 THEN
      INC(header, PresetDict)      (* FLG.FDICT: preset dictionary *)
    END;
    INC(header, 31 - (header MOD 31));    (* FLG.FCHECK: check bits for CMF and FLG *)
    stream.status := BusyState;
    Put16BitsMSB(stream.pend, header);
    IF stream.string # 0 THEN    (* DICT: the adler32 checksum of the preset dictionary *)
      Put32BitsMSB(stream.pend, stream.adler)
    END;
    stream.adler := 1;
  END;
  
  (* flush as much pending output as possible *)
  IF stream.pend.end # 0 THEN
    FlushPending(stream.pend, stream.out);
    IF stream.out.avail = 0 THEN
        (* Since stream.out.avail is 0, Deflate will be called again with more output space, 
          but possibly with both stream.pend.end and stream.in.avail equal to zero. There won't be anything to do,
          but this is not an error situation so make sure we return Ok instead of BufError at next call of Deflate *)
      stream.lastFlush := -1;
      stream.res := Ok;
      RETURN
    END

  (* make sure there is something to do and avoid duplicate consecutive flushes. For repeated and useless calls with Finish,
    we keep returning StreamEnd instead of BufError *)
  ELSIF (stream.in.avail = 0) & (flush <= lastFlush) & (flush # Finish) THEN
    stream.res := BufError;
    RETURN
  END;
  
  (* user must not provide more input after the first Finish *)
  IF (stream.status = Finish) & (stream.in.avail # 0) THEN
    stream.res := BufError;
    RETURN
  END;
  
  (* start a new block or continue the current one *)
  IF (stream.in.avail # 0) OR (stream.lookAhead # 0) OR ((flush # NoFlush) & (stream.status # FinishState)) THEN
    bstate := ConfigTable[stream.level].Compress(stream, flush);
    IF bstate IN {FinishStarted, FinishDone} THEN
      stream.status := FinishState
    END;
    IF bstate IN {NeedMore, FinishStarted} THEN
      IF stream.out.avail = 0 THEN
        stream.lastFlush := -1
      END;
      stream.res := Ok;    (* avoid BufError in next call, see above *)
      RETURN
      (* if (flush # NoFlush) & (out.avail = 0), the next call of Deflate should use the same flush parameter 
        to make sure that the flush is complete. So we dont't have to output an empty block here, this will be done at next call.
        This also ensures that for a very small output buffer, we emit at most one empty block. *)
    ELSIF bstate = BlockDone THEN
      IF flush = PartialFlush THEN
        AlignTrees(stream)
      ELSE  (* FullFlush or SyncFlush *)
        StoreBlock(stream, buf, 0, 0, FALSE);  (* for a full flush, this empty block will be recognized as a special marker by Inflate.Sync *)
        IF flush = FullFlush THEN
          ClearHash(stream)    (* forget about all hash chains *)
        END
      END;
      FlushPending(stream.pend, stream.out);
      IF stream.out.avail = 0 THEN
        stream.lastFlush := -1;    (* avoid BufError at next call, see above *)
        stream.res := Ok;
        RETURN
      END
    END
  END;
  ASSERT(stream.out.avail > 0, 111);
  
  IF flush # Finish THEN
    stream.res := Ok
  ELSIF ~stream.wrapper OR stream.trailerDone THEN
    stream.res := StreamEnd
  ELSE    (* write the zlib trailer (adler32) *)
    Put32BitsMSB(stream.pend, stream.adler);
    FlushPending(stream.pend, stream.out);  (* if stream.out.avail is zero, the application will call deflate again *)
    stream.trailerDone := TRUE;  (* write the trailer only once *)
    IF stream.pend.end = 0 THEN  (* flushed everything left *)
      stream.res := StreamEnd
    ELSE
      stream.res := Ok
    END
  END
END Deflate;


(** change deflate parameters within the stream. If the compression level is changed, the input available so far 
  is compressed with the old level (and may be flushed); the new level will take effect only at the next call of Deflate **)
PROCEDURE SetParams*(VAR stream: Stream; level, strategy: SHORTINT);
BEGIN
  IF level = DefaultCompression THEN
    level := 6
  END;
  IF ~stream.open OR (level < 0) OR (9 < level) OR (strategy < DefaultStrategy) OR (HuffmanOnly < strategy) THEN
    stream.res := StreamError
  ELSE
    IF (ConfigTable[level].Compress # ConfigTable[stream.level].Compress) & (stream.in.totalIn # 0) THEN
      Deflate(stream, PartialFlush)
    END;
    stream.level := level;
    stream.strategy := strategy
  END
END SetParams;
  
(** compress complete stream and return output length in len **)
PROCEDURE Compress* (VAR src, dst: ARRAY OF CHAR; srcoffset, srclen, dstoffset, dstlen: LONGINT; level, strategy: SHORTINT; VAR len: LONGINT; VAR res: LONGINT);
  VAR s: Stream;
BEGIN
  ZlibBuffers.Init(s.in, src, srcoffset, srclen, srclen);
  ZlibBuffers.Init(s.out, dst, dstoffset, dstlen, dstlen);
  Open(s, level, strategy, TRUE);
  IF s.res = Ok THEN
    Deflate(s, Finish);
    IF s.res = StreamEnd THEN
      len := s.out.totalOut;
      Close(s);
      res := s.res
    ELSE
      res := s.res;
      IF res = Ok THEN res := BufError END;
      Close(s)
    END
  ELSE
    res := s.res
  END
END Compress;


BEGIN
  InitStaticTrees();
  ConfigTable[0].GoodLen := 0; ConfigTable[0].MaxLazy := 0; ConfigTable[0].NiceLen := 0; 
    ConfigTable[0].MaxChain := 0; ConfigTable[0].Compress := CompressStored;              (* store only *)
  ConfigTable[1].GoodLen := 4; ConfigTable[1].MaxLazy := 4; ConfigTable[1].NiceLen := 8; 
    ConfigTable[1].MaxChain := 4; ConfigTable[1].Compress := CompressFast;                (*maximum speed, no lazy matches *)
  ConfigTable[2].GoodLen := 4; ConfigTable[2].MaxLazy := 5; ConfigTable[2].NiceLen := 16; 
    ConfigTable[2].MaxChain := 8; ConfigTable[2].Compress :=  CompressFast;
  ConfigTable[3].GoodLen := 4; ConfigTable[3].MaxLazy := 6; ConfigTable[3].NiceLen := 32; 
    ConfigTable[3].MaxChain := 32; ConfigTable[3].Compress := CompressFast;
  ConfigTable[4].GoodLen := 4; ConfigTable[4].MaxLazy := 4; ConfigTable[4].NiceLen := 16;
    ConfigTable[4].MaxChain := 16; ConfigTable[4].Compress :=  CompressSlow;              (* lazy matches *)
  ConfigTable[5].GoodLen := 8; ConfigTable[5].MaxLazy := 16; ConfigTable[5].NiceLen := 32; 
    ConfigTable[5].MaxChain := 32; ConfigTable[5].Compress :=  CompressSlow;
  ConfigTable[6].GoodLen := 8; ConfigTable[6].MaxLazy := 16; ConfigTable[6].NiceLen := 128; 
    ConfigTable[6].MaxChain := 128; ConfigTable[6].Compress :=  CompressSlow;
  ConfigTable[7].GoodLen := 8; ConfigTable[7].MaxLazy := 32; ConfigTable[7].NiceLen := 128; 
    ConfigTable[7].MaxChain := 256; ConfigTable[7].Compress :=  CompressSlow;
  ConfigTable[8].GoodLen := 32; ConfigTable[8].MaxLazy := 128; ConfigTable[8].NiceLen := 258; 
    ConfigTable[8].MaxChain := 1024; ConfigTable[8].Compress :=  CompressSlow;
  ConfigTable[9].GoodLen := 32; ConfigTable[9].MaxLazy := 128; ConfigTable[9].NiceLen := 258; 
    ConfigTable[9].MaxChain := 4096; ConfigTable[9].Compress :=  CompressSlow;            (* maximum compression *)
END ethZlibDeflate.
