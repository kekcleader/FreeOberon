(* ETH Oberon, Copyright 2001 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE ethBTrees;  (** portable *) (* ejz,  *)
  IMPORT Files;

(** BTrees is a utility module that manages b-trees with string (64 characters) or longint keys. Each key is linked to
    a longint value (org) which normaly is an offset to where the data for that key is stored. *)

  CONST
    Done* = 0; NotFound* = 1; EntryChanged* = 2; (** res codes *)

    Tag = 2425;
    PageSize = 2*1024;
    BoolSize = 1;
    IntSize = 2;
    LIntSize = 4;

    LInt = 0;
    LIntKeySize = LIntSize;
    LIntPageN = (PageSize-BoolSize-LIntSize-IntSize-LIntSize) DIV (2*(LIntKeySize+2*LIntSize));
    LIntPageSize = LIntSize+BoolSize+IntSize+LIntSize+2*LIntPageN*(LIntKeySize+2*LIntSize);

    Str = 1;
    StrKeySize* = 64; (** The maximum length of a string key. *)
    StrPageN = (PageSize-BoolSize-LIntSize-IntSize-LIntSize) DIV (2*(StrKeySize+2*LIntSize));
    StrPageSize = LIntSize+BoolSize+IntSize+LIntSize+2*StrPageN*(StrKeySize+2*LIntSize);

  TYPE
    Page = POINTER TO PageDesc;
    PageDesc = RECORD
      org: LONGINT; (* pos of this page *)
      p0: LONGINT; (* pos of left page *)
      m: INTEGER; (* number of entries *)
      dirty: BOOLEAN; (* page changed *)
      discard: BOOLEAN; (* TRUE: page is deleted *)
      next: Page (* next page in cache *)
    END;
    Tree* = POINTER TO TreeDesc; (** handle to a b-tree index *)
    TreeDesc = RECORD
      F: Files.File; (* index file *)
      cache: Page; (* list of cached pages *)
      org: LONGINT; (* pos of btree header *)
      root: LONGINT; (* pos of root page *)
      free: LONGINT; (* pos of first free page *)
      class: INTEGER; (* 0: LInt, 1: Str *)
      noCache: INTEGER; (* number of pages in cache *)
      maxCache: INTEGER (* max. number of pages in cache *)
    END;

    Entry = RECORD
      org: LONGINT; (* pos of data for key *)
      p: LONGINT (* pos of right page *)
    END;

    LIntEntry = RECORD (Entry)
      key: LONGINT
    END;
    LIntPage = POINTER TO LIntPageDesc;
    LIntPageDesc = RECORD (PageDesc)
      e: ARRAY 2*LIntPageN OF LIntEntry
    END;
    EnumLIntProc* = PROCEDURE (key, org: LONGINT; VAR cont: BOOLEAN); (** enumerator for longin keys *)

    StrEntry = RECORD (Entry)
      key: ARRAY StrKeySize OF CHAR
    END;
    StrPage = POINTER TO StrPageDesc;
    StrPageDesc = RECORD (PageDesc)
      e: ARRAY 2*StrPageN OF StrEntry
    END;
    EnumStrProc* = PROCEDURE (key: ARRAY OF CHAR; org: LONGINT; VAR cont: BOOLEAN); (** enumerator for string keys *)

  VAR
    MINStrKey*, MAXStrKey*: ARRAY StrKeySize OF CHAR; (** first and last string key *)

(* Allocate space for a new page. *)
  PROCEDURE AllocSpace(T: Tree; size: LONGINT): LONGINT;
    VAR
      R: Files.Rider;
      pos: LONGINT;
  BEGIN
    IF T.free > T.org THEN
      pos := T.free; Files.Set(R, T.F, pos);
      Files.ReadLInt(R, T.free) (* next free *)
    ELSE
      pos := Files.Length(T.F); Files.Set(R, T.F, pos);
      WHILE size > 0 DO
        Files.Write(R, 0X); DEC(size)
      END
    END;
    RETURN pos
  END AllocSpace;

  PROCEDURE ToFree(T: Tree; P: Page);
    VAR R: Files.Rider;
  BEGIN
    Files.Set(R, T.F, P.org); Files.WriteLInt(R, T.free);
    Files.Set(R, T.F, T.org);
    Files.WriteInt(R, Tag); Files.WriteInt(R, T.class);
    Files.WriteInt(R, T.maxCache);
    T.free := P.org; Files.WriteLInt(R, T.free)
  END ToFree;

(* Force write back of a page. *)
  PROCEDURE WriteLIntPage(T: Tree; p: LIntPage);
    VAR
      R: Files.Rider;
      i: LONGINT;
  BEGIN
    ASSERT(p.org <= Files.Length(T.F));
    Files.Set(R, T.F, p.org);
    Files.WriteLInt(R, p.org);
    Files.WriteInt(R, p.m);
    Files.WriteBool(R, p.discard);
    Files.WriteLInt(R, p.p0);
    FOR i := 0 TO p.m-1 DO
      Files.WriteLInt(R, p.e[i].key);
      Files.WriteLInt(R, p.e[i].org);
      Files.WriteLInt(R, p.e[i].p)
    END;
    p.dirty := FALSE
  END WriteLIntPage;

(* Allocate a new (memory) page. *)
  PROCEDURE NewLIntPage(T: Tree): LIntPage;
    VAR
      p0, pm, pp: Page;
      p: LIntPage;
  BEGIN
    NEW(p); INC(T.noCache);
    IF T.noCache > T.maxCache THEN
      pp := NIL; pm := NIL; p0 := T.cache;
      WHILE p0 # NIL DO
        pp := pm; pm := p0; p0 := p0.next
      END;
      IF pm.dirty THEN
        WriteLIntPage(T, pm(LIntPage))
      END;
      IF pp # NIL THEN
        pp.next := pm.next
      ELSE
        T.cache := pm.next
      END;
      T.noCache := T.maxCache
    END;
    p.next := T.cache; T.cache := p;
    p.m := 0; p.p0 := -1; p.org := -1;
    p.dirty := TRUE; p.discard := FALSE;
    RETURN p
  END NewLIntPage;

(* Read page at offset org. *)
  PROCEDURE ReadLIntPage(T: Tree; org: LONGINT; VAR p: LIntPage);
    VAR
      R: Files.Rider;
      p0: Page;
      i: LONGINT;
  BEGIN
    IF org < 0 THEN
      p := NIL; RETURN
    END;
    p0 := T.cache;
    WHILE (p0 # NIL) & (p0.org # org) DO
      p0 := p0.next
    END;
    IF p0 = NIL THEN
      p := NewLIntPage(T);
      Files.Set(R, T.F, org);
      Files.ReadLInt(R, p.org); ASSERT(p.org = org);
      Files.ReadInt(R, p.m);
      Files.ReadBool(R, p.discard); ASSERT(~p.discard);
      Files.ReadLInt(R, p.p0);
      FOR i := 0 TO p.m-1 DO
        Files.ReadLInt(R, p.e[i].key);
        Files.ReadLInt(R, p.e[i].org);
        Files.ReadLInt(R, p.e[i].p)
      END;
      p.dirty := FALSE
    ELSE
      p := p0(LIntPage);
      IF (p.next = NIL) & (p # T.cache) THEN
        p0 := T.cache;
        WHILE p0.next # p DO
          p0 := p0.next
        END;
        p0.next := NIL;
        p.next := T.cache; T.cache := p
      END        
    END
  END ReadLIntPage;

(** Search for key in T. If the key could be found res = Done else res = NotFound. *) 
  PROCEDURE SearchLInt*(T: Tree; key: LONGINT; VAR org: LONGINT; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      a: LIntPage;
  BEGIN
    ASSERT(T.class = LInt);
    ReadLIntPage(T, T.root, a);
    LOOP 
      L := 0; R := a.m;
      WHILE L < R DO
        i := (L+R) DIV 2;
        IF key <= a.e[i].key THEN
          R := i
        ELSE
          L := i+1
        END
      END;
      IF (R < a.m) & (a.e[R].key = key) THEN
        res := Done; org := a.e[R].org;
        RETURN
      END;
      IF R = 0 THEN
        ReadLIntPage(T, a.p0, a)
      ELSE
        ReadLIntPage(T, a.e[R-1].p, a)
      END;
      IF a = NIL THEN
        res := NotFound; org := -1;
        RETURN
      END
    END  
  END SearchLInt;

  PROCEDURE insertLInt(T: Tree; key, org: LONGINT; a: LIntPage; VAR h: BOOLEAN; VAR v: LIntEntry; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      b: LIntPage;
      u: LIntEntry;
  BEGIN
    L := 0; R := a.m;
    WHILE L < R DO
      i := (L+R) DIV 2;
      IF key <= a.e[i].key THEN
        R := i
      ELSE
        L := i+1
      END
    END;
    IF (R < a.m) & (a.e[R].key = key) THEN
      res := EntryChanged;
      a.dirty := TRUE; a.e[R].org := org
    ELSE
      IF R = 0 THEN
        ReadLIntPage(T, a.p0, b)
      ELSE
        ReadLIntPage(T, a.e[R-1].p, b)
      END;
      IF b = NIL THEN
        res := Done;
        u.p := -1; h := TRUE;
        u.key := key; u.org := org
      ELSE
        insertLInt(T, key, org, b, h, u, res)
      END;
      IF h THEN
        ReadLIntPage(T, a.org, a); (* ensure a is still cached *)
        a.dirty := TRUE;
        IF a.m < 2*LIntPageN THEN
          h := FALSE; i := a.m;
          WHILE i > R DO
            DEC(i); a.e[i+1] := a.e[i]
          END;
          a.e[R] := u; INC(a.m)
        ELSE
          b := NewLIntPage(T);
          b.dirty := TRUE; b.org := AllocSpace(T, LIntPageSize);
          IF R < LIntPageN THEN
            i := LIntPageN-1; v := a.e[i];
            WHILE i > R DO
              DEC(i); a.e[i+1] := a.e[i]
            END;
            a.e[R] := u;
            i := 0;
            WHILE i < LIntPageN DO
              b.e[i] := a.e[i+LIntPageN]; INC(i)
            END
          ELSE
            DEC(R, LIntPageN);
            i := 0;
            IF R = 0 THEN
              v := u
            ELSE
              v := a.e[LIntPageN];
              WHILE i < R-1 DO
                b.e[i] := a.e[i+LIntPageN+1]; INC(i)
              END;
              b.e[i] := u; INC(i)
            END;
            WHILE i < LIntPageN DO
              b.e[i] := a.e[i+LIntPageN]; INC(i)
            END
          END;
          a.m := LIntPageN; b.m := LIntPageN;
          b.p0 := v.p; v.p := b.org
        END
      END
    END
  END insertLInt;

(** Insert a new key into T. If a new key was inserted, res = Done else res = EntryChanged. *)
  PROCEDURE InsertLInt*(T: Tree; key, org: LONGINT; VAR res: INTEGER);
    VAR
      u: LIntEntry;
      r, q: LIntPage;
      h: BOOLEAN;
  BEGIN
    ASSERT(T.class = LInt);
    h := FALSE; u.p := -1;
    ReadLIntPage(T, T.root, r);
    insertLInt(T, key, org, r, h, u, res);
    IF h THEN
      ReadLIntPage(T, T.root, q);
      q.dirty := TRUE; q.org := AllocSpace(T, LIntPageSize);
      r := NewLIntPage(T);
      r.m := 1; r.dirty := TRUE;
      r.org := T.root; r.p0 := q.org;
      r.e[0] := u
    END
  END InsertLInt;

  PROCEDURE underflowLInt(T: Tree; c, a: LIntPage; s: LONGINT; VAR h: BOOLEAN);
    VAR
      b: LIntPage;
      i, k: LONGINT;
  BEGIN
    IF s < c.m THEN
      ReadLIntPage(T, c.e[s].p, b); k := (b.m-LIntPageN+1) DIV 2;
      ReadLIntPage(T, a.org, a); (* ensure a is still cached *)
      ReadLIntPage(T, c.org, c); (* ensure c is still cached *)
      a.dirty := TRUE; c.dirty := TRUE;
      a.e[LIntPageN-1] := c.e[s]; a.e[LIntPageN-1].p := b.p0;
      IF k > 0 THEN
        i := 0;
        WHILE i < k-1 DO
          a.e[i+LIntPageN] := b.e[i]; INC(i)
        END;
        c.e[s] := b.e[k-1]; b.p0 := c.e[s].p;
        c.e[s].p := b.org; b.m := b.m-SHORT(k);
        b.dirty := TRUE; i := 0;
        WHILE i < b.m DO
          b.e[i] := b.e[i+k]; INC(i)
        END;
        a.m := LIntPageN-1+SHORT(k); h := FALSE
      ELSE
        i := 0;
        WHILE i < LIntPageN DO
          a.e[i+LIntPageN] := b.e[i]; INC(i)
        END;
        i := s; DEC(c.m);
        WHILE i < c.m DO
          c.e[i] := c.e[i+1]; INC(i)
        END;
        a.m := 2*LIntPageN; h := c.m < LIntPageN
      END
    ELSE
      DEC(s);
      IF s = 0 THEN
        ReadLIntPage(T, c.p0, b)
      ELSE
        ReadLIntPage(T, c.e[s-1].p, b)
      END;
      ReadLIntPage(T, a.org, a); (* ensure a is still cached *)
      ReadLIntPage(T, c.org, c); (* ensure c is still cached *)
      k := (b.m-LIntPageN+1) DIV 2; b.dirty := TRUE;
      IF k > 0 THEN
        a.dirty := TRUE; c.dirty := TRUE;
        i := LIntPageN-1;
        WHILE i > 0 DO
          DEC(i); a.e[i+k] := a.e[i]
        END;
        i := k-1; a.e[i] := c.e[s]; a.e[i].p := a.p0;
        b.m := b.m-SHORT(k);
        WHILE i > 0 DO
          DEC(i); a.e[i] := b.e[i+b.m+1]
        END;
        c.e[s] := b.e[b.m]; a.p0 := c.e[s].p;
        c.e[s].p := a.org; a.m := LIntPageN-1+SHORT(k); h := FALSE
      ELSE
        c.dirty := TRUE;
        c.e[s].p := a.p0; b.e[LIntPageN] := c.e[s]; i := 0;
        WHILE i < LIntPageN-1 DO
          b.e[i+LIntPageN+1] := a.e[i]; INC(i)
        END;
        b.m := 2*LIntPageN; DEC(c.m); h := c.m < LIntPageN
      END
    END
  END underflowLInt;
  
  PROCEDURE deleteLInt(T: Tree; key: LONGINT; a: LIntPage; VAR h: BOOLEAN; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      q: LIntPage;
    PROCEDURE del(p: LIntPage; VAR h: BOOLEAN);
      VAR
        k: LONGINT;
        q: LIntPage;
    BEGIN
      k := p.m-1; ReadLIntPage(T, p.e[k].p, q);
      IF q # NIL THEN
        del(q, h);
        IF h THEN underflowLInt(T, p, q, p.m, h) END
      ELSE
        p.dirty := TRUE; a.dirty := TRUE;
        p.e[k].p := a.e[R].p; a.e[R] := p.e[k];
        DEC(p.m); h := p.m < LIntPageN
      END
    END del;
  BEGIN
    L := 0; R := a.m;
    WHILE L < R DO
      i := (L+R) DIV 2;
      IF key <= a.e[i].key THEN
        R := i
      ELSE
        L := i+1
      END
    END ;
    IF R = 0 THEN
      ReadLIntPage(T, a.p0, q)
    ELSE
      ReadLIntPage(T, a.e[R-1].p, q)
    END;
    IF (R < a.m) & (a.e[R].key = key) THEN
      res := Done;
      IF q = NIL THEN
        a.dirty := TRUE;
        DEC(a.m); h := a.m < LIntPageN; i := R;
        WHILE i < a.m DO
          a.e[i] := a.e[i+1]; INC(i)
        END
      ELSE
        del(q, h);
        IF h THEN underflowLInt(T, a, q, R, h) END
      END
    ELSIF q # NIL THEN
      deleteLInt(T, key, q, h, res);
      IF h THEN underflowLInt(T, a, q, R, h) END
    END
  END deleteLInt;

(** Delete key from T. If key was deleted res = Done else res = NotFound. *)
  PROCEDURE DeleteLInt*(T: Tree; key: LONGINT; VAR res: INTEGER);
    VAR
      p: Page;
      r, r0: LIntPage;
      h: BOOLEAN;
  BEGIN
    ASSERT(T.class = LInt); res := NotFound;
    ReadLIntPage(T, T.root, r);
    deleteLInt(T, key, r, h, res);
    IF (res = Done) & h THEN
      ReadLIntPage(T, T.root, r);
      IF r.m = 0 THEN
        IF r.p0 >= 0 THEN
          p := T.cache;
          WHILE p # NIL DO
            IF p.dirty THEN
              WriteLIntPage(T, p(LIntPage))
            END;
            p := p.next
          END;
          ReadLIntPage(T, r.p0, r0);
          r.org := r0.org; r.dirty := TRUE; r.discard := TRUE; r.next := NIL;
          WriteLIntPage(T, r); ToFree(T, r);
          r0.org := T.root; r0.dirty := TRUE; r0.next := NIL;
          T.cache := r0; T.noCache := 1
        END
      END
    END
  END DeleteLInt;

  PROCEDURE enumerateLInt(T: Tree; p: LIntPage; min, max: LONGINT; enum: EnumLIntProc; VAR cont: BOOLEAN);
    VAR
      key, lkey, i: LONGINT;
      q: LIntPage;
  BEGIN
    IF p # NIL THEN
      lkey := MIN(LONGINT); i := 0;
      WHILE (i < p.m) & (lkey < max) DO
        key := p.e[i].key;
        IF key >= min THEN
          IF key > min THEN
            IF i = 0 THEN
              ReadLIntPage(T, p.p0, q)
            ELSE
              ReadLIntPage(T, p.e[i-1].p, q)
            END;
            enumerateLInt(T, q, min, max, enum, cont)
          END;
          IF cont & (key <= max) THEN
            enum(key, p.e[i].org, cont)
          END
        END;
        lkey := key; INC(i)
      END;
      IF cont & (lkey < max) THEN
        ReadLIntPage(T, p.e[p.m-1].p, q);
        enumerateLInt(T, q, min, max, enum, cont)
      END
    END
  END enumerateLInt;

(** Enumerate all keys in T witch range from min upto max (key >= min) & (key <= max). *)
  PROCEDURE EnumLInt*(T: Tree; min, max: LONGINT; enum: EnumLIntProc);
    VAR
      r: LIntPage;
      cont: BOOLEAN;
  BEGIN
    ASSERT(T.class = LInt);
    ReadLIntPage(T, T.root, r);
    IF r.m > 0 THEN
      cont := TRUE;
      enumerateLInt(T, r, min, max, enum, cont)
    END
  END EnumLInt;

  PROCEDURE minLIntKey(T: Tree; p: LIntPage; VAR key: LONGINT);
  BEGIN
    IF p # NIL THEN
      key := p.e[0].key;
      ReadLIntPage(T, p.p0, p);
      minLIntKey(T, p, key)
    END
  END minLIntKey;

(** Searches the smallest key used in T. *)
  PROCEDURE MinLIntKey*(T: Tree; VAR key: LONGINT; VAR res: INTEGER);
    VAR r: LIntPage;
  BEGIN
    ASSERT(T.class = LInt);
    ReadLIntPage(T, T.root, r);
    IF r.m > 0 THEN
      minLIntKey(T, r, key); res := Done
    ELSE
      key := MAX(LONGINT); res := NotFound
    END
  END MinLIntKey;

  PROCEDURE maxLIntKey(T: Tree; p: LIntPage; VAR key: LONGINT);
  BEGIN
    IF (p # NIL) & (p.m > 0) THEN
      key := p.e[p.m-1].key;
      ReadLIntPage(T, p.e[p.m-1].p, p);
      maxLIntKey(T, p, key)
    END
  END maxLIntKey;

(** Searches the biggest key used in T. *)
  PROCEDURE MaxLIntKey*(T: Tree; VAR key: LONGINT; VAR res: INTEGER);
    VAR r: LIntPage;
  BEGIN
    ASSERT(T.class = LInt);
    ReadLIntPage(T, T.root, r);
    IF r.m > 0 THEN
      maxLIntKey(T, r, key); res := Done
    ELSE
      key := MIN(LONGINT); res := NotFound
    END  
  END MaxLIntKey;

(** Create a new b-tree with longint keys. The tree is written to F starting at org.
    cache gives the minumum number of keys which should fit into the page cache. *)
  PROCEDURE NewLInt*(F: Files.File; org: LONGINT; cache: INTEGER): Tree;
    VAR
      T: Tree;
      R: Files.Rider;
  BEGIN
    NEW(T);
    T.maxCache := (cache+2*LIntPageN-1) DIV (2*LIntPageN);
    IF T.maxCache < 4 THEN
      T.maxCache := 4
    END;
    T.F := F; T.org := org;
    Files.Set(R, F, org);
    Files.WriteInt(R, Tag); Files.WriteInt(R, LInt);
    Files.WriteInt(R, T.maxCache);
    T.free := -1; Files.WriteLInt(R, T.free);
    T.root := AllocSpace(T, LIntPageSize);
    T.class := LInt; T.noCache := 0;
    T.cache := NewLIntPage(T);
    T.cache.dirty := TRUE;
    T.cache.org := T.root;
    RETURN T
  END NewLInt;

(* Force write back of a page. *)
  PROCEDURE WriteStrPage(T: Tree; p: StrPage);
    VAR
      R: Files.Rider;
      i: LONGINT;
  BEGIN
    ASSERT(p.org <= Files.Length(T.F));
    Files.Set(R, T.F, p.org);
    Files.WriteLInt(R, p.org);
    Files.WriteInt(R, p.m);
    Files.WriteBool(R, p.discard);
    Files.WriteLInt(R, p.p0);
    FOR i := 0 TO p.m-1 DO
      Files.WriteBytes(R, p.e[i].key, StrKeySize);
      Files.WriteLInt(R, p.e[i].org);
      Files.WriteLInt(R, p.e[i].p)
    END;
    p.dirty := FALSE
  END WriteStrPage;

(* Allocate a new (memory) page. *)
  PROCEDURE NewStrPage(T: Tree): StrPage;
    VAR
      p0, pm, pp: Page;
      p: StrPage;
  BEGIN
    NEW(p); INC(T.noCache);
    IF T.noCache > T.maxCache THEN
      pp := NIL; pm := NIL; p0 := T.cache;
      WHILE p0 # NIL DO
        pp := pm; pm := p0; p0 := p0.next
      END;
      IF pm.dirty THEN
        WriteStrPage(T, pm(StrPage))
      END;
      IF pp # NIL THEN
        pp.next := pm.next
      ELSE
        T.cache := pm.next
      END;
      T.noCache := T.maxCache
    END;
    p.next := T.cache; T.cache := p;
    p.m := 0; p.p0 := -1; p.org := -1;
    p.dirty := TRUE; p.discard := FALSE;
    RETURN p
  END NewStrPage;

(* Read page at offset org. *)
  PROCEDURE ReadStrPage(T: Tree; org: LONGINT; VAR p: StrPage);
    VAR
      R: Files.Rider;
      p0: Page;
      i: LONGINT;
  BEGIN
    IF org < 0 THEN
      p := NIL; RETURN
    END;
    p0 := T.cache;
    WHILE (p0 # NIL) & (p0.org # org) DO
      p0 := p0.next
    END;
    IF p0 = NIL THEN
      p := NewStrPage(T);
      Files.Set(R, T.F, org);
      Files.ReadLInt(R, p.org); ASSERT(p.org = org);
      Files.ReadInt(R, p.m);
      Files.ReadBool(R, p.discard); ASSERT(~p.discard);
      Files.ReadLInt(R, p.p0);
      FOR i := 0 TO p.m-1 DO
        Files.ReadBytes(R, p.e[i].key, StrKeySize);
        Files.ReadLInt(R, p.e[i].org);
        Files.ReadLInt(R, p.e[i].p)
      END;
      p.dirty := FALSE
    ELSE
      p := p0(StrPage);
      IF (p.next = NIL) & (p # T.cache) THEN
        p0 := T.cache;
        WHILE p0.next # p DO
          p0 := p0.next
        END;
        p0.next := NIL;
        p.next := T.cache; T.cache := p
      END
    END
  END ReadStrPage;

(** Search for key in T. If the key could be found res = Done else res = NotFound. *)
  PROCEDURE SearchStr*(T: Tree; key: ARRAY OF CHAR; VAR org: LONGINT; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      a: StrPage;
      sKey: ARRAY StrKeySize OF CHAR;
  BEGIN
    ASSERT(T.class = Str); COPY(key, sKey);
    ReadStrPage(T, T.root, a);
    LOOP 
      L := 0; R := a.m;
      WHILE L < R DO
        i := (L+R) DIV 2;
        IF sKey <= a.e[i].key THEN
          R := i
        ELSE
          L := i+1
        END
      END;
      IF (R < a.m) & (a.e[R].key = sKey) THEN
        res := Done; org := a.e[R].org;
        RETURN
      END;
      IF R = 0 THEN
        ReadStrPage(T, a.p0, a)
      ELSE
        ReadStrPage(T, a.e[R-1].p, a)
      END;
      IF a = NIL THEN
        res := NotFound; org := -1;
        RETURN
      END
    END
  END SearchStr;

  PROCEDURE insertStr(T: Tree; VAR key: ARRAY OF CHAR; org: LONGINT; a: StrPage; VAR h: BOOLEAN; VAR v: StrEntry; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      b: StrPage;
      u: StrEntry;
  BEGIN
    L := 0; R := a.m;
    WHILE L < R DO
      i := (L+R) DIV 2;
      IF key <= a.e[i].key THEN
        R := i
      ELSE
        L := i+1
      END
    END;
    IF (R < a.m) & (a.e[R].key = key) THEN
      res := EntryChanged;
      a.dirty := TRUE; a.e[R].org := org
    ELSE
      IF R = 0 THEN
        ReadStrPage(T, a.p0, b)
      ELSE
        ReadStrPage(T, a.e[R-1].p, b)
      END;
      IF b = NIL THEN
        res := Done;
        u.p := -1; h := TRUE;
        COPY(key, u.key); u.org := org
      ELSE
        insertStr(T, key, org, b, h, u, res)
      END;
      IF h THEN
        ReadStrPage(T, a.org, a); (* ensure a is still cached *)
        a.dirty := TRUE;
        IF a.m < 2*StrPageN THEN
          h := FALSE; i := a.m;
          WHILE i > R DO
            DEC(i); a.e[i+1] := a.e[i]
          END;
          a.e[R] := u; INC(a.m)
        ELSE
          b := NewStrPage(T);
          b.dirty := TRUE; b.org := AllocSpace(T, StrPageSize);
          IF R < StrPageN THEN
            i := StrPageN-1; v := a.e[i];
            WHILE i > R DO
              DEC(i); a.e[i+1] := a.e[i]
            END;
            a.e[R] := u;
            i := 0;
            WHILE i < StrPageN DO
              b.e[i] := a.e[i+StrPageN]; INC(i)
            END
          ELSE
            DEC(R, StrPageN);
            i := 0;
            IF R = 0 THEN
              v := u
            ELSE
              v := a.e[StrPageN];
              WHILE i < R-1 DO
                b.e[i] := a.e[i+StrPageN+1]; INC(i)
              END;
              b.e[i] := u; INC(i)
            END;
            WHILE i < StrPageN DO
              b.e[i] := a.e[i+StrPageN]; INC(i)
            END
          END;
          a.m := StrPageN; b.m := StrPageN;
          b.p0 := v.p; v.p := b.org
        END
      END
    END
  END insertStr;

(** Insert a new key into T. If a new key was inserted, res = Done else res = EntryChanged. *)
  PROCEDURE InsertStr*(T: Tree; key: ARRAY OF CHAR; org: LONGINT; VAR res: INTEGER);
    VAR
      u: StrEntry;
      r, q: StrPage;
      h: BOOLEAN;
      sKey: ARRAY StrKeySize OF CHAR;
  BEGIN
    ASSERT(T.class = Str); COPY(key, sKey);
    h := FALSE; u.p := -1;
    ReadStrPage(T, T.root, r);
    insertStr(T, sKey, org, r, h, u, res);
    IF h THEN
      ReadStrPage(T, T.root, q);
      q.dirty := TRUE; q.org := AllocSpace(T, StrPageSize);
      r := NewStrPage(T);
      r.m := 1; r.dirty := TRUE;
      r.org := T.root; r.p0 := q.org;
      r.e[0] := u
    END
  END InsertStr;

  PROCEDURE underflowStr(T: Tree; c, a: StrPage; s: LONGINT; VAR h: BOOLEAN);
    VAR
      b: StrPage;
      i, k: LONGINT;
  BEGIN
    IF s < c.m THEN
      ReadStrPage(T, c.e[s].p, b); k := (b.m-StrPageN+1) DIV 2;
      ReadStrPage(T, a.org, a); (* ensure a is still cached *)
      ReadStrPage(T, c.org, c); (* ensure c is still cached *)
      a.dirty := TRUE; c.dirty := TRUE;
      a.e[StrPageN-1] := c.e[s]; a.e[StrPageN-1].p := b.p0;
      IF k > 0 THEN
        i := 0;
        WHILE i < k-1 DO
          a.e[i+StrPageN] := b.e[i]; INC(i)
        END;
        c.e[s] := b.e[k-1]; b.p0 := c.e[s].p;
        c.e[s].p := b.org; b.m := b.m-SHORT(k);
        b.dirty := TRUE; i := 0;
        WHILE i < b.m DO
          b.e[i] := b.e[i+k]; INC(i)
        END;
        a.m := StrPageN-1+SHORT(k); h := FALSE
      ELSE
        i := 0;
        WHILE i < StrPageN DO
          a.e[i+StrPageN] := b.e[i]; INC(i)
        END;
        i := s; DEC(c.m);
        WHILE i < c.m DO
          c.e[i] := c.e[i+1]; INC(i)
        END;
        a.m := 2*StrPageN; h := c.m < StrPageN
      END
    ELSE
      DEC(s);
      IF s = 0 THEN
        ReadStrPage(T, c.p0, b)
      ELSE
        ReadStrPage(T, c.e[s-1].p, b)
      END;
      ReadStrPage(T, a.org, a); (* ensure a is still cached *)
      ReadStrPage(T, c.org, c); (* ensure c is still cached *)
      k := (b.m-StrPageN+1) DIV 2; b.dirty := TRUE;
      IF k > 0 THEN
        a.dirty := TRUE; c.dirty := TRUE;
        i := StrPageN-1;
        WHILE i > 0 DO
          DEC(i); a.e[i+k] := a.e[i]
        END;
        i := k-1; a.e[i] := c.e[s]; a.e[i].p := a.p0;
        b.m := b.m-SHORT(k);
        WHILE i > 0 DO
          DEC(i); a.e[i] := b.e[i+b.m+1]
        END;
        c.e[s] := b.e[b.m]; a.p0 := c.e[s].p;
        c.e[s].p := a.org; a.m := StrPageN-1+SHORT(k); h := FALSE
      ELSE
        c.dirty := TRUE;
        c.e[s].p := a.p0; b.e[StrPageN] := c.e[s]; i := 0;
        WHILE i < StrPageN-1 DO
          b.e[i+StrPageN+1] := a.e[i]; INC(i)
        END;
        b.m := 2*StrPageN; DEC(c.m); h := c.m < StrPageN
      END
    END
  END underflowStr;
  
  PROCEDURE deleteStr(T: Tree; VAR key: ARRAY OF CHAR; a: StrPage; VAR h: BOOLEAN; VAR res: INTEGER);
    VAR
      i, L, R: LONGINT;
      q: StrPage;
    PROCEDURE del(p: StrPage; VAR h: BOOLEAN);
      VAR
        k: LONGINT;
        q: StrPage;
    BEGIN
      k := p.m-1; ReadStrPage(T, p.e[k].p, q);
      IF q # NIL THEN
        del(q, h);
        IF h THEN underflowStr(T, p, q, p.m, h) END
      ELSE
        p.dirty := TRUE; a.dirty := TRUE;
        p.e[k].p := a.e[R].p; a.e[R] := p.e[k];
        DEC(p.m); h := p.m < StrPageN
      END
    END del;
  BEGIN
    L := 0; R := a.m;
    WHILE L < R DO
      i := (L+R) DIV 2;
      IF key <= a.e[i].key THEN
        R := i
      ELSE
        L := i+1
      END
    END ;
    IF R = 0 THEN
      ReadStrPage(T, a.p0, q)
    ELSE
      ReadStrPage(T, a.e[R-1].p, q)
    END;
    IF (R < a.m) & (a.e[R].key = key) THEN
      res := Done;
      IF q = NIL THEN
        a.dirty := TRUE;
        DEC(a.m); h := a.m < StrPageN; i := R;
        WHILE i < a.m DO
          a.e[i] := a.e[i+1]; INC(i)
        END
      ELSE
        del(q, h);
        IF h THEN underflowStr(T, a, q, R, h) END
      END
    ELSIF q # NIL THEN
      deleteStr(T, key, q, h, res);
      IF h THEN underflowStr(T, a, q, R, h) END
    END
  END deleteStr;

(** Delete key from T. If key was deleted res = Done else res = NotFound. *)
  PROCEDURE DeleteStr*(T: Tree; key: ARRAY OF CHAR; VAR res: INTEGER);
    VAR
      p: Page;
      r, r0: StrPage;
      sKey: ARRAY StrKeySize OF CHAR;
      h: BOOLEAN;
  BEGIN
    ASSERT(T.class = Str); COPY(key, sKey); res := NotFound;
    ReadStrPage(T, T.root, r);
    deleteStr(T, sKey, r, h, res);
    IF (res = Done) & h THEN
      ReadStrPage(T, T.root, r);
      IF r.m = 0 THEN
        IF r.p0 >= 0 THEN
          p := T.cache;
          WHILE p # NIL DO
            IF p.dirty THEN
              WriteStrPage(T, p(StrPage))
            END;
            p := p.next
          END;
          ReadStrPage(T, r.p0, r0);
          r.org := r0.org; r.dirty := TRUE; r.discard := TRUE; r.next := NIL;
          WriteStrPage(T, r); ToFree(T, r);
          r0.org := T.root; r0.dirty := TRUE; r0.next := NIL;
          T.cache := r0; T.noCache := 1
        END
      END
    END
  END DeleteStr;

  PROCEDURE enumerateStr(T: Tree; p: StrPage; VAR min, max: ARRAY OF CHAR; enum: EnumStrProc; VAR cont: BOOLEAN);
    VAR
      key, lkey: ARRAY StrKeySize OF CHAR;
      q: StrPage;
      i: LONGINT;
  BEGIN
    IF p # NIL THEN
      COPY(MINStrKey, lkey); i := 0;
      WHILE (i < p.m) & (lkey < max) DO
        COPY(p.e[i].key, key);
        IF key >= min THEN
          IF key > min THEN
            IF i = 0 THEN
              ReadStrPage(T, p.p0, q)
            ELSE
              ReadStrPage(T, p.e[i-1].p, q)
            END;
            enumerateStr(T, q, min, max, enum, cont)
          END;
          IF cont & (key <= max) THEN
            enum(key, p.e[i].org, cont)
          END
        END;
        COPY(key, lkey); INC(i)
      END;
      IF cont & (lkey < max) THEN
        ReadStrPage(T, p.e[p.m-1].p, q);
        enumerateStr(T, q, min, max, enum, cont)
      END
    END
  END enumerateStr;

(** Enumerate all keys in T witch range from min upto max (key >= min) & (key <= max). *)
  PROCEDURE EnumStr*(T: Tree; min, max: ARRAY OF CHAR; enum: EnumStrProc);
    VAR
      r: StrPage;
      cont: BOOLEAN;
  BEGIN
    ASSERT(T.class = Str);
    ReadStrPage(T, T.root, r);
    IF r.m > 0 THEN
      cont := TRUE;
      enumerateStr(T, r, min, max, enum, cont)
    END
  END EnumStr;

  PROCEDURE minStrKey(T: Tree; p: StrPage; VAR key: ARRAY OF CHAR);
  BEGIN
    IF p # NIL THEN
      COPY(p.e[0].key, key);
      ReadStrPage(T, p.p0, p);
      minStrKey(T, p, key)
    END
  END minStrKey;

(** Searches the smallest key used in T. *)
  PROCEDURE MinStrKey*(T: Tree; VAR key: ARRAY OF CHAR; VAR res: INTEGER);
    VAR r: StrPage;
  BEGIN
    ASSERT(T.class = Str);
    ReadStrPage(T, T.root, r);
    IF r.m > 0 THEN
      minStrKey(T, r, key); res := Done
    ELSE
      res := NotFound
    END
  END MinStrKey;

  PROCEDURE maxStrKey(T: Tree; p: StrPage; VAR key: ARRAY OF CHAR);
  BEGIN
    IF (p # NIL) & (p.m > 0) THEN
      COPY(p.e[p.m-1].key, key);
      ReadStrPage(T, p.e[p.m-1].p, p);
      maxStrKey(T, p, key)
    END
  END maxStrKey;

(** Searches the biggest key used in T. *)
  PROCEDURE MaxStrKey*(T: Tree; VAR key: ARRAY OF CHAR; VAR res: INTEGER);
    VAR r: StrPage;
  BEGIN
    ASSERT(T.class = Str);
    ReadStrPage(T, T.root, r);
    IF r.m > 0 THEN
      maxStrKey(T, r, key); res := Done
    ELSE
      res := NotFound
    END  
  END MaxStrKey;

(** Create a new b-tree with string keys. The tree is written to F starting at org.
    cache gives the minumum number of keys which should fit into the page cache. *)
  PROCEDURE NewStr*(F: Files.File; org: LONGINT; cache: INTEGER): Tree;
    VAR
      T: Tree;
      R: Files.Rider;
  BEGIN
    NEW(T);
    T.maxCache := (cache+2*StrPageN-1) DIV (2*StrPageN);
    IF T.maxCache < 4 THEN
      T.maxCache := 4
    END;
    T.F := F; T.org := org;
    Files.Set(R, F, org);
    Files.WriteInt(R, Tag); Files.WriteInt(R, Str);
    Files.WriteInt(R, T.maxCache);
    T.free := -1; Files.WriteLInt(R, T.free);
    T.root := AllocSpace(T, StrPageSize);
    T.class := Str; T.noCache := 0;
    T.cache := NewStrPage(T);
    T.cache.dirty := TRUE;
    T.cache.org := T.root;
    RETURN T
  END NewStr;

(** Reopen the b-tree written to F starting at org. *)
  PROCEDURE Old*(F: Files.File; org: LONGINT): Tree;
    VAR
      T: Tree;
      R: Files.Rider;
      tag: INTEGER;
  BEGIN
    NEW(T); T.F := F; T.org := org;
    Files.Set(R, F, org);
    Files.ReadInt(R, tag); ASSERT(tag = Tag); Files.ReadInt(R, T.class);
    Files.ReadInt(R, T.maxCache); Files.ReadLInt(R, T.free);
    IF T.maxCache < 4 THEN T.maxCache := 4 END;
    T.root := Files.Pos(R); T.noCache := 0; T.cache := NIL;    
    RETURN T
  END Old;

(** Flush the page-cache of T to disk. *)
  PROCEDURE Flush*(T: Tree);
    VAR
      R: Files.Rider;
      p: Page;
  BEGIN
    Files.Set(R, T.F, T.org);
    Files.WriteInt(R, Tag); Files.WriteInt(R, T.class);
    Files.WriteInt(R, T.maxCache); Files.WriteLInt(R, T.free);
    p := T.cache;
    WHILE p # NIL DO
      IF p.dirty THEN
        CASE T.class OF
          LInt: WriteLIntPage(T, p(LIntPage))
          |Str: WriteStrPage(T, p(StrPage))
          ELSE
        END
      END;
      p := p.next
    END;
    Files.Close(T.F)
  END Flush;

(** Return the file used by T. *)
  PROCEDURE Base*(T: Tree): Files.File;
  BEGIN
    RETURN T.F
  END Base;

  PROCEDURE Init();
    VAR i: LONGINT;
  BEGIN
    FOR i := 0 TO StrKeySize-2 DO
      MINStrKey[i] := 0X;
      MAXStrKey[i] := 0FFX
    END;
    MINStrKey[StrKeySize-1] := 0X;
    MAXStrKey[StrKeySize-1] := 0X
  END Init;

BEGIN
  Init()
END ethBTrees.
