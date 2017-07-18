MODULE CRT; (* Cocol-R Tables *)

IMPORT Texts := CmdlnTexts, Out := Console, (*Oberon,*) Sets := Sets0;

CONST
  maxSymbols* = 300;  (*max nr of t, nt, and pragmas*)
  maxTerminals* = 256;  (*max nr of terminals*)
  maxNt* = 128;  (*max nr of nonterminals*)
  maxNodes* = 1500;  (*max nr of graph nodes*)
  normTrans* = 0; contextTrans* = 1;  (*transition codes*)
  maxSetNr = 128;  (* max. number of symbol sets *)
  maxClasses = 50;  (* max. number of character classes *)

  (* node types *)
  t* = 1; pr* = 2; nt* = 3; class* = 4; char* = 5; wt* =  6; any* = 7; eps* = 8; sync* = 9; sem* = 10; 
  alt* = 11; iter* = 12; opt* = 13;
  
  noSym* = -1;
  eofSy* = 0;
  
  (* token kinds *)
  classToken* = 0;  (*token class*)
  litToken* = 1;  (*literal (e.g. keyword) not recognized by DFA*)
  classLitToken* = 2;  (*token class that can also match a literal*)

TYPE
  Name* = ARRAY 16 OF CHAR;  (*symbol name*)
  Position*   = RECORD     (*position of stretch of source text*)
    beg*: LONGINT;  (*start relative to beginning of file*)
    len*: LONGINT;  (*length*)
    col*: INTEGER;  (*column number of start position*)
  END;
  
  SymbolNode* = RECORD
    typ*: INTEGER;        (*nt, t, pr, unknown*)
    name*: Name;          (*symbol name*)
    struct*: INTEGER;      (*typ = nt: index of 1st node of syntax graph*)
                        (*typ = t: token kind: literal, class, ...*)
    deletable*: BOOLEAN;  (*typ = nt: TRUE, if nonterminal is deletable*)
    attrPos*: Position;     (*position of attributes in source text*)
    semPos*: Position;    (*typ = pr: pos of sem action in source text*)
                        (*typ = nt: pos of local decls in source text *)
    line*: INTEGER;       (*source text line number of item in this node*)
  END;
  
  Set* = ARRAY maxTerminals DIV Sets.size OF SET;
  
  GraphNode* = RECORD
    typ* : INTEGER;    (* nt,sts,wts,char,class,any,eps,sem,sync,alt,iter,opt*)
    next*: INTEGER;    (* index of successor node                        *)
                    (* next < 0: to successor in enclosing structure  *)
    p1*: INTEGER;     (* typ IN {nt, t, wt}: index to symbol list       *)
                    (* typ = any: index to anyset                     *) 
                    (* typ = sync: index to syncset                   *)
                    (* typ = alt: index of 1st node of 1st alternative*)
                    (* typ IN {iter, opt}: 1st node in subexpression  *)
                    (* typ = char: ordinal character value            *)
                    (* typ = class: index of character class          *)
    p2*: INTEGER;      (* typ = alt: index of 1st node of 2nd alternative*)
                    (* typ IN {char, class}: transition code          *)
    pos*: Position;    (* typ IN {nt, t, wt}: pos of actual attribs      *)
                    (* typ = sem: pos of sem action in source text.   *)
    line*: INTEGER;      (* source text line number of item in this node   *)
  END;
  
  MarkList* = ARRAY maxNodes DIV Sets.size OF SET;

  FirstSets = ARRAY maxNt OF RECORD
    ts: Set; (*terminal symbols*)
    ready: BOOLEAN; (*TRUE = ts is complete*)
  END;
  FollowSets = ARRAY maxNt OF RECORD
    ts: Set; (*terminal symbols*)
    nts: Set; (*nts whose start set is to be included*)
  END;
  CharClass = RECORD
    name: Name; (*class name*)
    set:  INTEGER (* ptr to set representing the class*)
  END;
  SymbolTable = ARRAY maxSymbols OF SymbolNode;
  ClassTable = ARRAY maxClasses OF CharClass;
  GraphList = ARRAY maxNodes OF GraphNode;

VAR
  maxSet*:  INTEGER; (* index of last set                                  *)
  maxT*:    INTEGER; (* terminals stored from 0 .. maxT                    *)
  maxP*:    INTEGER; (* pragmas stored from maxT+1 .. maxP                 *)
  firstNt*: INTEGER; (* index of first nt: available after CompSymbolSets  *)
  lastNt*:  INTEGER; (* index of last nt: available after CompSymbolSets   *)
  maxC*:    INTEGER; (* index of last character class                      *)
  semDeclPos*:  Position;  (*position of global semantic declarations*)
  importPos*: Position; (*position of imported identifiers*)
  ignored*: Set;       (* characters ignored by the scanner            *)
  ignoreCase*:  BOOLEAN;   (* TRUE: scanner treats lower case as upper case*)
  ddt*: ARRAY 10 OF BOOLEAN; (* debug and test switches    *)
  nNodes*: INTEGER;   (* index of last graph node          *)
  root*: INTEGER;   (* index of root node, filled by ATG *)

  w: Texts.Writer;
  st: SymbolTable;
  gn: GraphList;
  first: FirstSets;  (*first[i]  = first symbols of st[i+firstNt]*)
  follow: FollowSets; (*follow[i] = followers of st[i+firstNt]*)
  chClass: ClassTable; (*character classes*)
  set: ARRAY 128 OF Set;  (*set[0] reserved for union of all synchronisation sets*)
  dummyName: INTEGER; (*for unnamed character classes*)

PROCEDURE ^MovePragmas;
PROCEDURE ^DelNode*(gn: GraphNode): BOOLEAN;

PROCEDURE Str(s: ARRAY OF CHAR);
BEGIN 
(*Texts.WriteString(w, s)*)
Out.String(s)
END Str;

PROCEDURE NL;
BEGIN 
Out.Ln(*Texts.WriteLn(w)*)
END NL;

PROCEDURE Length(s: ARRAY OF CHAR): INTEGER;
  VAR i: INTEGER;
BEGIN
  i:=0; WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END;
  RETURN i
END Length;

PROCEDURE Restriction(n: INTEGER);
BEGIN
  NL; Str("Restriction "); 
  Out.Int(n, 0); NL; (*Texts.Append(Oberon.Log, w.buf);*)
  HALT(99)
END Restriction;
      
PROCEDURE ClearMarkList*(VAR m: MarkList);
  VAR i: INTEGER;
BEGIN
  i := 0; WHILE i < maxNodes DIV Sets.size DO m[i] := {}; INC(i) END;
END ClearMarkList;

PROCEDURE GetNode*(gp: INTEGER; VAR n: GraphNode);
BEGIN
  n := gn[gp]
END GetNode;

PROCEDURE PutNode*(gp: INTEGER; n: GraphNode);
BEGIN gn[gp] := n
END PutNode;

PROCEDURE DelGraph*(gp: INTEGER): BOOLEAN;
  VAR gn: GraphNode;
BEGIN
  IF gp = 0 THEN RETURN TRUE END; (*end of graph found*)
  GetNode(gp, gn);
  RETURN DelNode(gn) & DelGraph(ABS(gn.next));
END DelGraph;

PROCEDURE NewSym*(typ: INTEGER; name: Name; line: INTEGER): INTEGER;
  VAR i: INTEGER;
BEGIN
  IF maxT + 1 = firstNt THEN Restriction(6)
  ELSE
    CASE typ OF
    | t:  INC(maxT); i := maxT
    | pr: DEC(maxP); DEC(firstNt); DEC(lastNt); i := maxP
    | nt: DEC(firstNt); i := firstNt
    END;
    IF maxT >= maxTerminals THEN Restriction(6) END;
    st[i].typ := typ; st[i].name := name;
    st[i].struct := 0;  st[i].deletable := FALSE;
    st[i].attrPos.beg := -1;
    st[i].semPos.beg  := -1;
    st[i].line := line
  END;
  RETURN i
END NewSym;

PROCEDURE GetSym*(sp: INTEGER; VAR sn: SymbolNode);
BEGIN sn := st[sp]
END GetSym;

PROCEDURE PutSym*(sp: INTEGER; sn: SymbolNode);
BEGIN st[sp] := sn
END PutSym;

PROCEDURE FindSym*(name: Name): INTEGER;
  VAR i: INTEGER;
BEGIN
  i := 0;  (*search in terminal list*)
  WHILE (i <= maxT) & (st[i].name # name) DO INC(i) END;
  IF i <= maxT THEN RETURN i END;
  i := firstNt;  (*search in nonterminal/pragma list*)
  WHILE (i < maxSymbols) & (st[i].name # name) DO INC(i) END;
  IF i < maxSymbols THEN RETURN i ELSE RETURN noSym END
END FindSym;

PROCEDURE NewSet*(s: Set): INTEGER;
BEGIN
  INC(maxSet); IF maxSet > maxSetNr THEN Restriction(4) END;
  set[maxSet] := s;
  RETURN maxSet
END NewSet;

PROCEDURE PrintSet(s: ARRAY OF SET; indent: INTEGER);
  CONST maxLineLen = 80;
  VAR   col, i, len: INTEGER; empty: BOOLEAN; sn: SymbolNode;
BEGIN
  i := 0; col := indent; empty := TRUE;
  WHILE i <= maxT DO
    IF Sets.In(s, i) THEN
      empty := FALSE; GetSym(i, sn); len := Length(sn.name);
      IF col + len + 2 > maxLineLen THEN
        NL; col := 1;
        WHILE col < indent DO Texts.Write(w, " "); INC(col) END
      END;
      Str(sn.name); Str("  ");
      INC(col, len + 2)
    END;
    INC(i)
  END;
  IF empty THEN Str("-- empty set --") END;
  NL; (*Texts.Append(Oberon.Log, w.buf)*)
END PrintSet;

PROCEDURE CompFirstSet*(gp: INTEGER; VAR fs: Set);
  VAR visited: MarkList;

  PROCEDURE CompFirst(gp: INTEGER; VAR fs: Set);
    VAR s: Set; gn: GraphNode; sn: SymbolNode;
  BEGIN
    Sets.Clear(fs);
    WHILE (gp # 0) & ~ Sets.In(visited, gp) DO
      GetNode(gp, gn); Sets.Incl(visited, gp);
      CASE gn.typ OF
      | nt:
          IF first[gn.p1 - firstNt].ready THEN 
            Sets.Unite(fs, first[gn.p1 - firstNt].ts);
          ELSE
            GetSym(gn.p1, sn); CompFirst(sn.struct, s); Sets.Unite(fs, s);
          END;
      | t, wt: Sets.Incl(fs, gn.p1);
      | any: Sets.Unite(fs, set[gn.p1])
      | alt, iter, opt:
          CompFirst(gn.p1, s); Sets.Unite(fs, s);
          IF gn.typ = alt THEN CompFirst(gn.p2, s); Sets.Unite(fs, s) END
      ELSE (* eps, sem, sync: nothing *)
      END;
      IF ~ DelNode(gn) THEN RETURN END;
      gp := ABS(gn.next)
     END
  END CompFirst;

BEGIN (* ComputeFirstSet *)
  ClearMarkList(visited);
  CompFirst(gp, fs);
  IF ddt[3] THEN
    NL; Str("ComputeFirstSet: gp = "); Texts.WriteInt(w, gp, 0); NL;
    PrintSet(fs, 0);
  END;
END CompFirstSet;

PROCEDURE CompFirstSets;
  VAR i: INTEGER; sn: SymbolNode;
BEGIN
  i := firstNt; WHILE i <= lastNt DO first[i-firstNt].ready := FALSE; INC(i) END;
  i := firstNt;
  WHILE i <= lastNt DO (* for all nonterminals *)
    GetSym(i, sn); CompFirstSet(sn.struct, first[i - firstNt].ts);
    first[i - firstNt].ready := TRUE; 
    INC(i)
  END;
END CompFirstSets;

PROCEDURE CompExpected*(gp, sp: INTEGER; VAR exp: Set);
BEGIN
  CompFirstSet(gp, exp);
  IF DelGraph(gp) THEN Sets.Unite(exp, follow[sp - firstNt].ts) END
END CompExpected;

PROCEDURE CompFollowSets;
  VAR sn: SymbolNode; gn: GraphNode; curSy, i, size: INTEGER; visited: MarkList;

  PROCEDURE CompFol(gp: INTEGER);
    VAR s: Set; gn: GraphNode;
  BEGIN
    WHILE (gp > 0) & ~ Sets.In(visited, gp) DO
      GetNode(gp, gn); Sets.Incl(visited, gp);
      IF gn.typ = nt THEN
        CompFirstSet(ABS(gn.next), s); Sets.Unite(follow[gn.p1 - firstNt].ts, s);
        IF DelGraph(ABS(gn.next)) THEN 
          Sets.Incl(follow[gn.p1 - firstNt].nts, curSy - firstNt) 
        END
      ELSIF gn.typ IN {opt, iter} THEN CompFol(gn.p1)
      ELSIF gn.typ = alt THEN CompFol(gn.p1); CompFol(gn.p2)
      END;
      gp := gn.next
    END
  END CompFol;

  PROCEDURE Complete(i: INTEGER);
    VAR j: INTEGER;
  BEGIN
    IF Sets.In(visited, i) THEN RETURN END;
    Sets.Incl(visited, i);
    j := 0;
    WHILE j <= lastNt - firstNt DO (* for all nonterminals *)
      IF Sets.In(follow[i].nts, j) THEN
        Complete(j); Sets.Unite(follow[i].ts, follow[j].ts);
        IF i = curSy THEN Sets.Excl(follow[i].nts, j) END
      END;
      INC(j)
    END
  END Complete;

BEGIN (* CompFollowSets *)
  curSy := firstNt; size := (lastNt - firstNt + 2) DIV Sets.size;
  WHILE curSy <= lastNt + 1 DO  (* also for dummy root nt*)
    Sets.Clear(follow[curSy - firstNt].ts);
    i := 0; WHILE i <= size DO follow[curSy - firstNt].nts[i] := {}; INC(i) END;
    INC(curSy)
  END;

  curSy := firstNt;                (*get direct successors of nonterminals*)
  WHILE curSy <= lastNt DO
    GetSym(curSy, sn); ClearMarkList(visited); CompFol(sn.struct);
    INC(curSy)
  END;
  CompFol(root); (*curSy=lastNt+1*)

  curSy := 0;                  (*add indirect successors to follow.ts*)
  WHILE curSy <= lastNt - firstNt DO
    ClearMarkList(visited); Complete(curSy);
    INC(curSy);
  END;
END CompFollowSets;


PROCEDURE CompAnySets;
  VAR curSy, i: INTEGER; sn: SymbolNode;
  
  PROCEDURE LeadingAny(gp: INTEGER; VAR a: GraphNode): BOOLEAN;
    VAR gn: GraphNode;
  BEGIN
    IF gp <= 0 THEN RETURN FALSE END;
    GetNode(gp, gn);
    IF (gn.typ = any) THEN a := gn; RETURN TRUE
    ELSE RETURN (gn.typ = alt) & (LeadingAny(gn.p1, a) OR LeadingAny(gn.p2, a))
             OR (gn.typ IN {opt, iter}) & LeadingAny(gn.p1, a)
             OR DelNode(gn) & LeadingAny(gn.next, a)
    END
  END LeadingAny;
  
  PROCEDURE FindAS(gp: INTEGER);
    VAR gn, gn2, a: GraphNode; s1, s2: Set; p: INTEGER;
  BEGIN
    WHILE gp > 0 DO
      GetNode(gp, gn);
      IF gn.typ IN {opt, iter} THEN
        FindAS(gn.p1);
        IF LeadingAny(gn.p1, a) THEN
          CompFirstSet(ABS(gn.next), s1); Sets.Differ(set[a.p1], s1)
        END
      ELSIF gn.typ = alt THEN
        p := gp; Sets.Clear(s1);
        WHILE p # 0 DO
          GetNode(p, gn2); FindAS(gn2.p1);
          IF LeadingAny(gn2.p1, a) THEN
            CompFirstSet(gn2.p2, s2); Sets.Unite(s2, s1); Sets.Differ(set[a.p1], s2)
          ELSE
            CompFirstSet(gn2.p1, s2); Sets.Unite(s1, s2)
          END;
          p := gn2.p2
        END
      END;
      gp := gn.next
    END
  END FindAS;
  
BEGIN
  curSy := firstNt;
  WHILE curSy <= lastNt DO (* for all nonterminals *)
    GetSym(curSy, sn); FindAS(sn.struct);
    INC(curSy)
  END
END CompAnySets;


PROCEDURE CompSyncSets;
  VAR curSy, i: INTEGER; sn: SymbolNode; visited: MarkList;

  PROCEDURE CompSync(gp: INTEGER);
    VAR s: Set; gn: GraphNode; 
  BEGIN
    WHILE (gp > 0) & ~ Sets.In(visited, gp) DO
      GetNode(gp, gn); Sets.Incl(visited, gp);
      IF gn.typ = sync THEN
        CompExpected(ABS(gn.next), curSy, s); 
        Sets.Incl(s, eofSy); Sets.Unite(set[0], s);
        gn.p1 := NewSet(s); PutNode(gp, gn)
      ELSIF gn.typ = alt THEN CompSync(gn.p1); CompSync(gn.p2)
      ELSIF gn.typ IN {iter, opt} THEN CompSync(gn.p1)
      END;
      gp := gn.next
    END
  END CompSync;

BEGIN
  curSy := firstNt; ClearMarkList(visited);
  WHILE curSy <= lastNt DO
    GetSym(curSy, sn); CompSync(sn.struct);
    INC(curSy);
  END
END CompSyncSets;


PROCEDURE CompDeletableSymbols*;
  VAR changed, del: BOOLEAN; i: INTEGER; sn: SymbolNode;
BEGIN
  del := FALSE;
  REPEAT
    changed := FALSE;
    i := firstNt;
    WHILE i <= lastNt DO  (*for all nonterminals*)
      GetSym(i, sn);
      IF ~sn.deletable & DelGraph(sn.struct) THEN
        sn.deletable := TRUE; PutSym(i, sn); changed := TRUE; del := TRUE
      END;
      INC(i)
    END;
  UNTIL ~changed;
  
  i := firstNt; IF del THEN NL END;
  WHILE i <= lastNt DO
    GetSym(i, sn);
    IF sn.deletable THEN Str("  "); Str(sn.name); Str(" deletable"); NL END;
    INC(i);
  END;
  (*Texts.Append(Oberon.Log, w.buf)*)
END CompDeletableSymbols;


PROCEDURE CompSymbolSets*;
  VAR i: INTEGER; sn: SymbolNode;
BEGIN
  i := NewSym(t, "???", 0); (*unknown symbols get code maxT*)
  MovePragmas;
  CompDeletableSymbols;
  CompFirstSets;
  CompFollowSets;
  CompAnySets;
  CompSyncSets;
  IF ddt[1] THEN
    i := firstNt; Str("First & follow symbols:"); NL;
    WHILE i <= lastNt DO (* for all nonterminals *)
      GetSym(i, sn); Str(sn.name); NL;
      Str("first:   "); PrintSet(first[i - firstNt].ts, 10);
      Str("follow:  "); PrintSet(follow[i - firstNt].ts, 10); 
      NL;
      INC(i);
    END;
    
    IF maxSet >= 0 THEN NL; NL; Str("List of sets (ANY, SYNC): "); NL END;
    i := 0; 
    WHILE i <= maxSet DO
      Str("     set["); Texts.WriteInt (w, i, 2); Str("] = "); PrintSet(set[i], 16);
      INC (i)
    END;
    NL; NL; (*Texts.Append(Oberon.Log, w.buf)*)
  END;
END CompSymbolSets;


PROCEDURE GetFirstSet(sp: INTEGER; VAR s: Set);
BEGIN s := first[sp - firstNt].ts
END GetFirstSet;

PROCEDURE GetFollowSet(sp: INTEGER; VAR s: Set);
BEGIN s := follow[sp - firstNt].ts
END GetFollowSet;

PROCEDURE GetSet*(nr: INTEGER; VAR s: Set);
BEGIN s := set[nr]
END GetSet;

PROCEDURE MovePragmas;
  VAR i: INTEGER;
BEGIN
  IF maxP > firstNt THEN
    i := maxSymbols - 1; maxP := maxT;
    WHILE i > lastNt DO 
      INC(maxP); IF maxP >= firstNt THEN Restriction(6) END;
      st[maxP] := st[i]; DEC(i) 
    END;
  END
END MovePragmas;

PROCEDURE PrintSymbolTable*;
  VAR i, j: INTEGER;

  PROCEDURE WriteTyp(typ: INTEGER);
  BEGIN
    CASE typ OF
    | t    : Str(" t      ");
    | pr   : Str(" pr     ");
    | nt   : Str(" nt     ");
    END;
  END WriteTyp;

BEGIN (* PrintSymbolTable *)
  Str("Symbol Table:"); NL; NL;
  Str("nr    name     typ      hasAttribs struct  del  line"); NL; NL;

  i := 0;
  WHILE i < maxSymbols DO
    Texts.WriteInt(w, i, 3); Str("   ");
    j := 0; WHILE (j < 8) & (st[i].name[j] # 0X) DO Texts.Write(w, st[i].name[j]); INC(j) END;
    WHILE j < 8 DO Texts.Write(w, " "); INC(j) END;
    WriteTyp(st[i].typ); 
    IF st[i].attrPos.beg >= 0 THEN Str("  TRUE ") ELSE Str(" FALSE") END; 
    Texts.WriteInt(w, st[i].struct, 10); 
    IF st[i].deletable THEN Str("  TRUE ") ELSE Str(" FALSE") END;
    Texts.WriteInt(w, st[i].line, 6); NL;
    IF i = maxT THEN i := firstNt ELSE INC(i) END
  END;
  NL; NL; (*Texts.Append(Oberon.Log, w.buf)*)
END PrintSymbolTable;

PROCEDURE NewClass*(name: Name; set: Set): INTEGER;
BEGIN
  INC(maxC); IF maxC >= maxClasses THEN Restriction(7) END;
  IF name[0] = "#" THEN name[1] := CHR(ORD("A") + dummyName); INC(dummyName) END;
  chClass[maxC].name := name; chClass[maxC].set := NewSet(set);
  RETURN maxC
END NewClass;

PROCEDURE ClassWithName*(name: Name): INTEGER;
  VAR i: INTEGER;
BEGIN
  i := maxC; WHILE (i >= 0) & (chClass[i].name # name) DO DEC(i) END;
  RETURN i
END ClassWithName;

PROCEDURE ClassWithSet*(s: Set): INTEGER;
  VAR i: INTEGER;
BEGIN
  i := maxC; WHILE (i >= 0) & ~ Sets.Equal(set[chClass[i].set], s) DO DEC(i) END;
  RETURN i
END ClassWithSet;

PROCEDURE GetClass*(n: INTEGER; VAR s: Set);
BEGIN
  GetSet(chClass[n].set, s)
END GetClass;

PROCEDURE GetClassName*(n: INTEGER; VAR name: Name);
BEGIN
  name := chClass[n].name
END GetClassName;

PROCEDURE XRef*;
  CONST maxLineLen = 80;
  TYPE  ListPtr  = POINTER TO ListNode;
        ListNode = RECORD 
          next: ListPtr;
          line: INTEGER;
        END;
        ListHdr  = RECORD
          name: Name;
          lptr: ListPtr;
        END;
  VAR   gn: GraphNode; col, i, j: INTEGER; l, p, q: ListPtr; 
        sn: SymbolNode;  
        xList: ARRAY maxSymbols OF ListHdr;

BEGIN (* XRef *)
  IF maxT <= 0 THEN RETURN END;
  MovePragmas;
  (* initialise cross reference list *)
  i := 0;
  WHILE i <= lastNt DO (* for all symbols *)
    GetSym(i, sn); xList[i].name := sn.name; xList[i].lptr := NIL; 
    IF i = maxP THEN i := firstNt ELSE INC(i) END
  END;
  
  (* search lines where symbol has been referenced *)
  i := 1;
  WHILE i <= nNodes DO (* for all graph nodes *)
    GetNode(i, gn);
    IF gn.typ IN {t, wt, nt} THEN
      NEW(l); l^.next := xList[gn.p1].lptr; l^.line := gn.line; 
      xList[gn.p1].lptr := l
    END;
    INC(i);
  END;
  
  (* search lines where symbol has been defined and insert in order *)
  i := 1;
  WHILE i <= lastNt DO  (*for all symbols*)
    GetSym(i, sn); p := xList[i].lptr; q := NIL; 
    WHILE (p # NIL) & (p^.line > sn.line) DO q := p; p := p^.next END;
    NEW(l); l^.next := p; 
    l^.line := -sn.line;
    IF q # NIL THEN q^.next := l ELSE xList[i].lptr := l END;
    IF i = maxP THEN i := firstNt ELSE INC(i) END
  END;
  
  (* print cross reference listing *)
  NL; Str("Cross reference list:"); NL; NL; Str("Terminals:"); NL; Str("  0  EOF"); NL;
  i := 1;
  WHILE i <= lastNt DO  (*for all symbols*)
    Texts.WriteInt(w, i, 3); Str("  ");
    j := 0; WHILE (j < 15) & (xList[i].name[j] # 0X) DO Texts.Write(w, xList[i].name[j]); INC(j) END;
    l := xList[i].lptr; col := 25;
    WHILE l # NIL DO
      IF col + 5 > maxLineLen THEN
        NL; col := 0; WHILE col < 25 DO Texts.Write(w, " "); INC(col) END
      END;
      IF l^.line = 0 THEN Str("undef") ELSE Texts.WriteInt(w, l^.line, 5) END;
      INC(col, 5);
      l := l^.next
    END;
    NL;
    IF i = maxT THEN NL; Str("Pragmas:"); NL END;
    IF i = maxP THEN NL; Str("Nonterminals:"); NL; i := firstNt ELSE INC(i) END
  END;
  NL; NL; (*Texts.Append(Oberon.Log, w.buf)*)
END XRef;


PROCEDURE NewNode*(typ, p1, line: INTEGER): INTEGER;
BEGIN
  INC(nNodes); IF nNodes > maxNodes THEN Restriction(3) END;
  gn[nNodes].typ := typ; gn[nNodes].next := 0; 
  gn[nNodes].p1 := p1; gn[nNodes].p2 := 0;
  gn[nNodes].pos.beg := -1; gn[nNodes].line := line;
  RETURN nNodes;
END NewNode;

PROCEDURE CompleteGraph*(gp: INTEGER);
  VAR p: INTEGER;
BEGIN
  WHILE gp # 0 DO
    p := gn[gp].next; gn[gp].next := 0; gp := p
  END
END CompleteGraph;

PROCEDURE ConcatAlt*(VAR gL1, gR1: INTEGER; gL2, gR2: INTEGER);
  VAR p: INTEGER;
BEGIN
  gL2 := NewNode(alt, gL2, 0);
  p := gL1; WHILE gn[p].p2 # 0 DO p := gn[p].p2 END; gn[p].p2 := gL2;
  p := gR1; WHILE gn[p].next # 0 DO p := gn[p].next END; gn[p].next := gR2
END ConcatAlt;

PROCEDURE ConcatSeq*(VAR gL1, gR1: INTEGER; gL2, gR2: INTEGER);
  VAR p, q: INTEGER;
BEGIN
  p := gn[gR1].next; gn[gR1].next := gL2; (*head node*)
  WHILE p # 0 DO (*substructure*)
    q := gn[p].next; gn[p].next := -gL2; p := q
  END;
  gR1 := gR2
END ConcatSeq;

PROCEDURE MakeFirstAlt*(VAR gL, gR: INTEGER);
BEGIN
  gL := NewNode(alt, gL, 0); gn[gL].next := gR; gR := gL
END MakeFirstAlt;

PROCEDURE MakeIteration*(VAR gL, gR: INTEGER);
  VAR p, q: INTEGER;
BEGIN
  gL := NewNode(iter, gL, 0); p := gR; gR := gL;
  WHILE p # 0 DO
    q := gn[p].next; gn[p].next := - gL; p := q
  END
END MakeIteration;

PROCEDURE MakeOption*(VAR gL, gR: INTEGER);
BEGIN
  gL := NewNode(opt, gL, 0); gn[gL].next := gR; gR := gL
END MakeOption;

PROCEDURE StrToGraph*(str: ARRAY OF CHAR; VAR gL, gR: INTEGER);
  VAR len, i: INTEGER;
BEGIN
  gR := 0; i := 1; len := Length(str) - 1;
  WHILE i < len DO
    gn[gR].next := NewNode(char, ORD(str[i]), 0); gR := gn[gR].next;
    INC(i)
  END;
  gL := gn[0].next; gn[0].next := 0
END StrToGraph;

PROCEDURE DelNode*(gn: GraphNode): BOOLEAN;
  VAR sn: SymbolNode;
  
  PROCEDURE DelAlt(gp: INTEGER): BOOLEAN;
    VAR gn: GraphNode;
  BEGIN
    IF gp <= 0 THEN RETURN TRUE END; (*end of graph found*)
    GetNode(gp, gn);
    RETURN DelNode(gn) & DelAlt(gn.next);
  END DelAlt;
  
BEGIN
  IF gn.typ = nt THEN GetSym(gn.p1, sn); RETURN sn.deletable
  ELSIF gn.typ = alt THEN RETURN DelAlt(gn.p1) OR (gn.p2 # 0) & DelAlt(gn.p2)
  ELSE RETURN gn.typ IN {eps, iter, opt, sem, sync}
  END
END DelNode;

PROCEDURE PrintGraph*;
  VAR i: INTEGER;

  PROCEDURE WriteTyp(typ: INTEGER);
  BEGIN
    CASE typ OF
    | nt  : Str("nt  ")
    | t   : Str("t   ")
    | wt  : Str("wt  ")
    | any : Str("any ")
    | eps : Str("eps ")
    | sem : Str("sem ")
    | sync: Str("sync")
    | alt : Str("alt ")
    | iter: Str("iter")
    | opt : Str("opt ")
    ELSE Str("--- ")
    END;
  END WriteTyp;

BEGIN (* PrintGraph *)
  Str("GraphList:"); NL; NL;
  Str(" nr   typ    next     p1     p2   line"); NL; NL;

  i := 0;
  WHILE i <= nNodes DO
    Texts.WriteInt(w, i, 3); Str("   ");
    WriteTyp(gn[i].typ); Texts.WriteInt(w, gn[i].next, 7);
    Texts.WriteInt(w, gn[i].p1, 7);
    Texts.WriteInt(w, gn[i].p2, 7);
    Texts.WriteInt(w, gn[i].line, 7);
    NL;
    INC(i);
  END;
  NL; NL; (*Texts.Append(Oberon.Log, w.buf)*)
END PrintGraph;

PROCEDURE FindCircularProductions* (VAR ok: BOOLEAN);
  CONST maxList = 150;
  TYPE  ListEntry = RECORD
          left   : INTEGER;
          right  : INTEGER;
          deleted: BOOLEAN;
        END;
  VAR   changed, onLeftSide, onRightSide: BOOLEAN; i, j, listLength: INTEGER; 
        list: ARRAY maxList OF ListEntry;
        singles: MarkList;
        sn: SymbolNode;

  PROCEDURE GetSingles (gp: INTEGER; VAR singles: MarkList);
    VAR gn: GraphNode;
  BEGIN
    IF gp <= 0 THEN RETURN END; (* end of graph found *)
    GetNode (gp, gn);
    IF gn.typ = nt THEN
      IF DelGraph(ABS(gn.next)) THEN Sets.Incl(singles, gn.p1) END
    ELSIF gn.typ IN {alt, iter, opt} THEN
      IF DelGraph(ABS(gn.next)) THEN
        GetSingles(gn.p1, singles);
        IF gn.typ = alt THEN GetSingles(gn.p2, singles) END
      END
    END;
    IF DelNode(gn) THEN GetSingles(gn.next, singles) END
  END GetSingles;

BEGIN (* FindCircularProductions *)
  i := firstNt; listLength := 0;
  WHILE i <= lastNt DO (* for all nonterminals i *)
    ClearMarkList (singles); GetSym (i, sn);
    GetSingles (sn.struct, singles); (* get nt's j such that i-->j *)
    j := firstNt;
    WHILE j <= lastNt DO (* for all nonterminals j *)
      IF Sets.In(singles, j) THEN
        list[listLength].left := i; list[listLength].right := j; 
        list[listLength].deleted := FALSE;
        INC (listLength)
      END;
      INC(j)
    END;
    INC(i)
  END;
  
  REPEAT
    i := 0; changed := FALSE;
    WHILE i < listLength DO
      IF ~ list[i].deleted THEN
        j := 0; onLeftSide := FALSE; onRightSide := FALSE;
        WHILE j < listLength DO
          IF ~ list[j].deleted THEN
            IF list[i].left = list[j].right THEN onRightSide := TRUE END;
            IF list[j].left = list[i].right THEN onLeftSide := TRUE END 
          END;
          INC(j)
        END;
        IF ~ onRightSide OR ~ onLeftSide THEN 
          list[i].deleted := TRUE; changed := TRUE 
        END
      END;
      INC(i)
    END
  UNTIL ~ changed;

  i := 0; ok := TRUE;
  WHILE i < listLength DO
    IF ~ list[i].deleted THEN
      ok := FALSE;
      GetSym(list[i].left, sn); NL; Str("  "); Str(sn.name); Str(" --> ");
      GetSym(list[i].right, sn); Str(sn.name)
    END;
    INC(i)
  END;
  (*Texts.Append(Oberon.Log, w.buf)*)
END FindCircularProductions;


PROCEDURE LL1Test* (VAR ll1: BOOLEAN);
  VAR sn: SymbolNode; curSy: INTEGER;
  
  PROCEDURE LL1Error (cond, ts: INTEGER);
    VAR sn: SymbolNode;
  BEGIN
    ll1 := FALSE;
    GetSym (curSy, sn); Str("  LL1 error in "); Str(sn.name); Str(": ");
    IF ts > 0 THEN GetSym (ts, sn); Str(sn.name); Str(" is ") END;
    CASE cond OF
      1: Str(" start of several alternatives.")
    | 2: Str(" start & successor of deletable structure")
    | 3: Str(" an ANY node that matchs no symbol")
    END;
    NL; (*Texts.Append(Oberon.Log, w.buf)*)
  END LL1Error;

  PROCEDURE Check (cond: INTEGER; VAR s1, s2: Set);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i <= maxT DO
      IF Sets.In(s1, i) & Sets.In(s2, i) THEN LL1Error(cond, i) END;
      INC(i)
    END
  END Check;

  PROCEDURE CheckAlternatives (gp: INTEGER);
    VAR gn, gn1: GraphNode; s1, s2: Set; p: INTEGER;
  BEGIN
    WHILE gp > 0 DO
      GetNode(gp, gn);
      IF gn.typ = alt THEN
        p := gp; Sets.Clear(s1);
        WHILE p # 0 DO  (*for all alternatives*)
          GetNode(p, gn1); CompExpected(gn1.p1, curSy, s2);
          Check(1, s1, s2); Sets.Unite(s1, s2);
          CheckAlternatives(gn1.p1);
          p := gn1.p2
        END
      ELSIF gn.typ IN {opt, iter} THEN
        CompExpected(gn.p1, curSy, s1); 
        CompExpected(ABS(gn.next), curSy, s2);
        Check(2, s1, s2);
        CheckAlternatives(gn.p1)
      ELSIF gn.typ = any THEN
        GetSet(gn.p1, s1);
        IF Sets.Empty(s1) THEN LL1Error(3, 0) END  (*e.g. {ANY} ANY or [ANY] ANY*)
      END;
      gp := gn.next
    END
  END CheckAlternatives;

BEGIN (* LL1Test *)
  curSy := firstNt; ll1 := TRUE;
  WHILE curSy <= lastNt DO  (*for all nonterminals*)
    GetSym(curSy, sn); CheckAlternatives (sn.struct);
    INC (curSy)
  END;
END LL1Test;


PROCEDURE TestCompleteness* (VAR ok: BOOLEAN);
  VAR sp: INTEGER; sn: SymbolNode; 
BEGIN
  sp := firstNt; ok := TRUE;
  WHILE sp <= lastNt DO  (*for all nonterminals*)
    GetSym (sp, sn);
    IF sn.struct = 0 THEN
      ok := FALSE; NL; Str("  No production for "); Str(sn.name); (*Texts.Append(Oberon.Log, w.buf)*)
    END;
    INC(sp)
  END
END TestCompleteness;


PROCEDURE TestIfAllNtReached* (VAR ok: BOOLEAN);
  VAR gn: GraphNode; sp: INTEGER; reached: MarkList; sn: SymbolNode;
      
  PROCEDURE MarkReachedNts (gp: INTEGER);
    VAR gn: GraphNode; sn: SymbolNode;
  BEGIN
    WHILE gp > 0 DO
      GetNode(gp, gn);
      IF gn.typ = nt THEN
        IF ~ Sets.In(reached, gn.p1) THEN  (*new nt reached*)
          Sets.Incl(reached, gn.p1); 
          GetSym(gn.p1, sn); MarkReachedNts(sn.struct)
        END
      ELSIF gn.typ IN {alt, iter, opt} THEN
        MarkReachedNts(gn.p1);
        IF gn.typ = alt THEN MarkReachedNts(gn.p2) END
      END;
      gp := gn.next
    END
  END MarkReachedNts;

BEGIN (* TestIfAllNtReached *)
  ClearMarkList(reached);
  GetNode(root, gn); Sets.Incl(reached, gn.p1);
  GetSym(gn.p1, sn); MarkReachedNts(sn.struct);

  sp := firstNt; ok := TRUE;
  WHILE sp <= lastNt DO  (*for all nonterminals*)
    IF ~ Sets.In(reached, sp) THEN
      ok := FALSE; GetSym(sp, sn); NL; Str("  "); Str(sn.name); Str(" cannot be reached")
    END;
    INC(sp)
  END;
  (*Texts.Append(Oberon.Log, w.buf)*)
END TestIfAllNtReached;


PROCEDURE TestIfNtToTerm* (VAR ok: BOOLEAN);
  VAR changed: BOOLEAN; gn: GraphNode; sp: INTEGER; 
      sn: SymbolNode; 
      termList: MarkList;

  PROCEDURE IsTerm (gp: INTEGER): BOOLEAN;
    VAR gn: GraphNode;
  BEGIN
    WHILE gp > 0 DO
      GetNode(gp, gn);
      IF (gn.typ = nt) & ~ Sets.In(termList, gn.p1) THEN RETURN FALSE END;
      IF (gn.typ = alt) & ~ IsTerm(gn.p1) & ((gn.p2 = 0) OR ~IsTerm(gn.p2)) THEN RETURN FALSE END;
      gp := gn.next
    END;
    RETURN TRUE
  END IsTerm;

BEGIN (* TestIfNtToTerm *)
  ClearMarkList(termList);
  REPEAT
    sp := firstNt; changed := FALSE;
    WHILE sp <= lastNt DO
      IF ~ Sets.In(termList, sp) THEN
        GetSym(sp, sn);
        IF IsTerm(sn.struct) THEN Sets.Incl(termList, sp); changed := TRUE END
      END;
      INC(sp)
    END
  UNTIL ~changed; 

  sp := firstNt; ok := TRUE;
  WHILE sp <= lastNt DO
    IF ~ Sets.In(termList, sp) THEN
      ok := FALSE; GetSym(sp, sn); NL; Str("  "); Str(sn.name); Str(" cannot be derived to terminals")
    END;
    INC(sp)
  END;
  (*Texts.Append(Oberon.Log, w.buf)*)
END TestIfNtToTerm;

PROCEDURE Init*;
BEGIN
  maxSet := 0; Sets.Clear(set[0]); Sets.Incl(set[0], eofSy);
  firstNt := maxSymbols; maxP := maxSymbols; maxT := -1; maxC := -1;
  lastNt := maxP - 1;
  dummyName := 0;
  nNodes := 0 
END Init;

BEGIN (* CRT *)
  (* The dummy node gn[0] ensures that none of the procedures
     above have to check for 0 indices. *)
  nNodes := 0; 
  gn[0].typ := -1; gn[0].p1 := 0; gn[0].p2 := 0; gn[0].next := 0; gn[0].line := 0;
  Texts.OpenWriter(w)
END CRT.

