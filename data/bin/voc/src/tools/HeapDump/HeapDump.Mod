MODULE HeapDump;

IMPORT SYSTEM, Heap, Console;

  PROCEDURE -wc(c: CHAR);          BEGIN Console.Char(c)               END wc;
  PROCEDURE -ws(s: ARRAY OF CHAR); BEGIN Console.String(s)             END ws;
  PROCEDURE -wi(i: LONGINT);       BEGIN Console.Int(i, 1)             END wi;
  PROCEDURE -wl;                   BEGIN Console.Ln(); Console_Flush() END wl;

  PROCEDURE th(h: LONGINT);
  VAR i, d: INTEGER; s: ARRAY 20 OF CHAR;
  BEGIN
    IF h = 0 THEN ws("0H"); RETURN END;
    i := 0; 
    WHILE (h # 0) DO 
      d := SHORT(h MOD 16);  h := SYSTEM.LSH(h, -4);
      IF d < 10 THEN s[i] := CHR(d + ORD("0")) ELSE s[i] := CHR(d - 10 + ORD("a")) END;
      INC(i)
    END;
    WHILE i > 0 DO DEC(i); wc(s[i]) END;
    wc("H");
  END th;

  PROCEDURE DumpType(type: LONGINT);
  TYPE
    typename = POINTER TO ARRAY 24 OF CHAR;
    pointers = POINTER TO ARRAY 10000 OF LONGINT;
  VAR 
    tag, next, level, blksz, m: LONGINT;
    module: Module;
    name:   typename;
    ptr:    pointers;
    i:      INTEGER;
  BEGIN
    SYSTEM.GET(type -   SZL, tag);
    SYSTEM.GET(type,         next);
    SYSTEM.GET(type +   SZL, level);
    SYSTEM.GET(type + 2*SZL, m);      module := SYSTEM.VAL(Module, m);
    name := SYSTEM.VAL(typename, type + 3*SZL);
    SYSTEM.GET(type + 20*SZL + 24, blksz);
    ptr := SYSTEM.VAL(pointers, type + 21*SZL + 24);
    ws("tag ");     th(tag); 
    ws(", level "); wi(level,1);
    ws(", blksz "); th(blksz);
    ws(", name ");  ws(module.name); wc("."); ws(name^);
    ws(", pointers: ");
    i := 0; WHILE ptr[i] >= 0 DO wi(ptr[i],1); wc(" "); INC(i) END;
    wi(ptr[i],1);
  END DumpType;

  PROCEDURE DumpTypes(types: LONGINT);
  BEGIN
    WHILE types # 0 DO
      ws("    TYPE at: "); th(types); ws(": "); DumpType(types); wl;
      SYSTEM.GET(types, types);
    END
  END DumpTypes;

  PROCEDURE DumpModules;
    VAR m: Module; t: LONGINT;
  BEGIN
    m := SYSTEM.VAL(Module, modules);
    WHILE m # NIL DO
      ws("  Module "); ws(m.name); ws(", refcnt "); wi(m.refcnt,1); wl;
      DumpTypes(m.types);
      m := m.next;
    END
  END DumpModules;


  PROCEDURE DumpChunks;
  VAR  
    chunk, nextchunk, chunkend: LONGINT;
    block, blocktag, blocksize, blocksizeviatag, blocksentinel, blocknext: LONGINT;
    type: LONGINT;
    reserved, ptr: LONGINT;
  BEGIN
    chunk := heap;
    WHILE chunk # 0 DO
      SYSTEM.GET(chunk + nextChnkOff, nextchunk);
      SYSTEM.GET(chunk + endOff,      chunkend);
      ws("  Chunk at ");   th(chunk); 
      ws(", chunk end ");  th(chunkend); 
      ws(", next chunk "); th(nextchunk);
      wl;
      block := chunk + blkOff;
      WHILE block < chunkend DO
        SYSTEM.GET(block+tagOff,  blocktag);
        SYSTEM.GET(block+sizeOff, blocksize);
        SYSTEM.GET(block+sntlOff, blocksentinel);
        SYSTEM.GET(block+nextOff, blocknext);
        ws("    Block at ");   th(block); 
        
        ws(", tag ");          th(blocktag);
        IF (ODD(blocktag)) THEN ws(" (marked)"); DEC(blocktag) END;
        SYSTEM.GET(blocktag,       blocksizeviatag);
        SYSTEM.GET(blocktag - SZL, reserved);
        SYSTEM.GET(blocktag + SZL, ptr);
           
      (*ws(", size ");         th(blocksize);        *)
        ws(", size via tag "); th(blocksizeviatag);
      (*ws(", sentinel ");     th(blocksentinel);    *)
      (*ws(", next block ");   th(blocknext);        *)

        ws(", .reserved ");  th(reserved);
        ws(", .ptr[0] ");    th(ptr);

        (* The following test attempts to distinguish between blocks 
           allocated by NEW (whose tag points to a full type descriptor)
           and those allocated by SYSTEM.NEW (whose tag points only to a
           size and a dummy ptr list sentinel).
           It is a safe test in that only full type descriptors have a 
           non-empty ptr list, but it means we will fail to report the
           type of RECORDs that contain no pointers.
        *)
        IF ptr >= 0 THEN 
          type := blocktag - (20*SZL + 24);
          ws(", type at "); th(type); wl;
          ws("    TYPE: "); DumpType(type);
        END;

        wl;

        INC(block, blocksizeviatag);
      END;
      chunk := nextchunk
    END
  END DumpChunks;


  PROCEDURE Dump*;
  BEGIN
    Heap.Lock;
    ws("Module and type dump."); wl;      DumpModules; wl; wl;
    ws("Heap chunk and block dump."); wl; DumpChunks; wl;
    Heap.Unlock;
  END Dump;

END HeapDump.
