(* The following check seems to be unnecessary. It reported an error if a symbol + context
          was a prefix of another symbol, e.g.:
            s1 = "a" "b" "c".
            s2 = "a" CONTEXT("b").
          But this is ok
        IF t.state.endOf # CRT.noSym THEN
          PutS("$Ambiguous CONTEXT clause.$"); correct := FALSE
        END*)
MODULE CRA;  (* handles the DFA *) 

IMPORT Out := Console, (*Oberon,*) Texts := CmdlnTexts, Sets := Sets0, CRS, CRT;

CONST
  maxStates = 300;
  EOL = 0DX;
  
TYPE
  State = POINTER TO StateNode;
  Action = POINTER TO ActionNode;
  Target = POINTER TO TargetNode;

  StateNode = RECORD         (*state of finite automaton*)
    nr: INTEGER;  (*state number*)
    firstAction: Action;   (*to first action of this state*)
    endOf: INTEGER;  (*nr. of recognized token if state is final*)
    ctx: BOOLEAN;  (*TRUE: state reached by contextTrans*)
    next: State
  END;
  ActionNode = RECORD    (*action of finite automaton*)
    typ: INTEGER;       (*type of action symbol: char, class*)
    sym: INTEGER;       (*action symbol*)
    tc: INTEGER;       (*transition code: normTrans, contextTrans*)
    target: Target;        (*states after transition with input symbol*)
    next: Action;
  END;
  TargetNode = RECORD    (*state after transition with input symbol*)
    state:  State;       (*target state*)
    next:   Target;
  END;

  


  Comment    = POINTER TO CommentNode;
  CommentNode = RECORD   (* info about a comment syntax *)
    start,stop: ARRAY 2 OF CHAR;
    nested:     BOOLEAN;
    next:       Comment;
  END;

  Melted     = POINTER TO MeltedNode;
  MeltedNode = RECORD    (* info about melted states *)
    set:   CRT.Set;      (* set of old states *)
    state: State;      (* new state *)
    next:  Melted;
  END;

VAR
  firstState: State;
  lastState:    State;      (* last allocated state  *)
  rootState:    State;      (* start state of DFA    *)
  lastSimState: INTEGER;      (* last non melted state *)
  stateNr: INTEGER;  (*number of last allocated state*)
  firstMelted:  Melted;       (* list of melted states *)
  firstComment: Comment;      (* list of comments      *)
  dirtyDFA: BOOLEAN;  (* DFA may be nondeterministic *)
  out: Texts.Writer;  (* current output *)
  fram: Texts.Reader;  (* scanner frame input *)

PROCEDURE SemErr(nr: INTEGER);
BEGIN CRS.Error(200+nr, CRS.pos)
END SemErr;

PROCEDURE Put(ch: CHAR);
BEGIN 
   (*Texts.Write(out, ch)*)
   Out.Char(ch)
END Put;

PROCEDURE PutS(s: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO
    IF s[i] = "$" THEN 
       (*Texts.WriteLn(out)*)
       Out.Ln
    ELSE
       (*Texts.Write(out, s[i])*)
       Out.Char(s[i])
    END;
    INC(i)
  END
END PutS;

PROCEDURE PutI(i: INTEGER);
BEGIN
   (*Texts.WriteInt(out, i, 0)*)
   Out.Int(i, 0)
END PutI;

PROCEDURE PutI2(i, n: INTEGER);
BEGIN 
(*Texts.WriteInt(out, i, n) *)
Out.Int(i, n) 
END PutI2;

PROCEDURE PutC(ch: CHAR);
BEGIN
  IF (ch < " ") OR (ORD(ch) = 34) THEN PutS("CHR("); PutI(ORD(ch)); Put(")")
  ELSE Put(CHR(34)); Put(ch); Put(CHR(34))
  END
END PutC;

PROCEDURE PutRange(s: CRT.Set);
  VAR lo, hi: ARRAY 32 OF CHAR; top, i: INTEGER; s1: CRT.Set;
BEGIN
  (*----- fill lo and hi *)
  top := -1; i := 0;
  WHILE i < 128 DO
    IF Sets.In(s, i) THEN
      INC(top); lo[top] := CHR(i); INC(i);
      WHILE (i < 128) & Sets.In(s, i) DO INC(i) END;
      hi[top] := CHR(i - 1)
    ELSE INC(i)
    END
  END;
  (*----- print ranges *)
  IF (top = 1) & (lo[0] = 0X) & (hi[1] = 7FX) & (CHR(ORD(hi[0]) + 2) = lo[1]) THEN
    Sets.Fill(s1); Sets.Differ(s1, s); PutS("~ "); PutRange(s1)
  ELSE
    PutS("(");
    i := 0;
    WHILE i <= top DO
      IF hi[i] = lo[i] THEN   PutS("(ch="); PutC(lo[i])
      ELSIF lo[i] = 0X THEN   PutS("(ch<="); PutC(hi[i])
      ELSIF hi[i] = 7FX THEN PutS("(ch>="); PutC(lo[i])
      ELSE PutS("(ch>="); PutC(lo[i]); PutS(") & (ch<="); PutC(hi[i])
      END;
      Put(")");
      IF i < top THEN PutS(" OR ") END;
      INC(i)
    END;
    PutS(")");
  END
END PutRange;

PROCEDURE PutChCond(ch: CHAR);
BEGIN
  PutS("(ch ="); PutC(ch); Put(")")
END PutChCond;

PROCEDURE Length*(s: ARRAY OF CHAR): INTEGER;
  VAR i: INTEGER;
BEGIN
  i:=0; WHILE (i < LEN(s)) & (s[i] # 0X) DO INC(i) END;
  RETURN i
END Length;


PROCEDURE AddAction(act:Action; VAR head:Action);
VAR a,lasta: Action;
BEGIN
  a := head; lasta := NIL;
  LOOP
    IF (a = NIL)                (*collecting classes at the front gives better*)
    OR (act^.typ < a^.typ) THEN (*performance*)
      act^.next := a;
      IF lasta = NIL THEN head := act ELSE lasta^.next := act END;
      EXIT;
    END;
    lasta := a; a := a^.next;
  END;
END AddAction;


PROCEDURE DetachAction(a:Action; VAR L:Action);
BEGIN
  IF L = a THEN L := a^.next ELSIF L # NIL THEN DetachAction(a, L^.next) END
END DetachAction;


PROCEDURE TheAction (state: State; ch: CHAR): Action;
  VAR a: Action; set: CRT.Set;
BEGIN
  a := state.firstAction;
  WHILE a # NIL DO
    IF a.typ = CRT.char THEN
      IF ORD(ch) = a.sym THEN RETURN a END
    ELSIF a.typ = CRT.class THEN
      CRT.GetClass(a^.sym, set);
      IF Sets.In(set, ORD(ch)) THEN RETURN a END
    END;
    a := a.next
  END;
  RETURN NIL
END TheAction;


PROCEDURE AddTargetList(VAR lista, listb: Target);
VAR p,t: Target;

  PROCEDURE AddTarget(t: Target; VAR list:Target);
  VAR p,lastp: Target;
  BEGIN
    p:=list; lastp:=NIL;
    LOOP
      IF (p = NIL) OR (t^.state.nr < p^.state.nr) THEN EXIT END;
      IF p^.state = t^.state THEN RETURN END;
      lastp := p; p := p^.next
    END;
    t^.next:=p;
    IF lastp=NIL THEN list:=t ELSE lastp^.next:=t END
  END AddTarget;
    
BEGIN
  p := lista;
  WHILE p # NIL DO
    NEW(t); t^.state:=p^.state; AddTarget(t, listb);
    p := p^.next
  END
END AddTargetList;


PROCEDURE NewMelted(set: CRT.Set; state: State): Melted;
VAR melt: Melted;
BEGIN
  NEW(melt); melt^.set := set; melt^.state := state;
  melt^.next := firstMelted; firstMelted := melt;
  RETURN melt
END NewMelted;


PROCEDURE NewState(): State;
  VAR state: State;
BEGIN
  NEW(state); INC(stateNr); state.nr := stateNr;
  state.firstAction := NIL; state.endOf := CRT.noSym; state.ctx := FALSE; state.next := NIL;
  IF firstState = NIL THEN firstState := state ELSE lastState.next := state END;
  lastState := state;
  RETURN state
END NewState;


PROCEDURE NewTransition(from, to: State; typ, sym, tc: INTEGER);
  VAR a: Action; t: Target;
BEGIN
  IF to = firstState THEN SemErr(21) END;
  NEW(t); t^.state := to; t^.next := NIL;
  NEW(a); a^.typ := typ; a^.sym := sym; a^.tc := tc; a^.target := t;
  AddAction(a, from.firstAction)
END NewTransition;


PROCEDURE NewComment*(from, to: INTEGER; nested: BOOLEAN);
  VAR com: Comment;
  
  PROCEDURE MakeStr(gp: INTEGER; VAR s: ARRAY OF CHAR);
    VAR i, n: INTEGER; gn: CRT.GraphNode; set: CRT.Set;
  BEGIN
    i := 0;
    WHILE gp # 0 DO
      CRT.GetNode(gp, gn);
      IF gn.typ = CRT.char THEN 
        IF i < 2 THEN s[i] := CHR(gn.p1) END; INC(i)
      ELSIF gn.typ = CRT.class THEN
        CRT.GetClass(gn.p1, set);
        IF Sets.Elements(set, n) # 1 THEN SemErr(26) END;
        IF i < 2 THEN s[i] := CHR(n) END; INC(i)
      ELSE SemErr(22) 
      END;
      gp := gn.next
    END;
    IF i > 2 THEN SemErr(25) ELSIF i < 2 THEN s[i] := 0X END
  END MakeStr;
  
BEGIN
  NEW(com);
  MakeStr(from, com^.start); MakeStr(to, com^.stop);
  com^.nested := nested;
  com^.next := firstComment; firstComment := com
END NewComment;


PROCEDURE MakeSet(p: Action; VAR set: CRT.Set);
BEGIN
  IF p^.typ = CRT.class THEN CRT.GetClass(p^.sym, set)
  ELSE Sets.Clear(set); Sets.Incl(set, p^.sym)
  END
END MakeSet;


PROCEDURE ChangeAction(a: Action; set: CRT.Set);
VAR nr: INTEGER;
BEGIN
  IF Sets.Elements(set, nr) = 1 THEN a^.typ := CRT.char; a^.sym := nr
  ELSE
    nr := CRT.ClassWithSet(set);
    IF nr < 0 THEN nr := CRT.NewClass("#0", set) END; (*class with dummy name*)
    a^.typ := CRT.class; a^.sym := nr
  END
END ChangeAction;
  

PROCEDURE CombineShifts;
  VAR state: State; n: INTEGER; a, b, c: Action; seta, setb: CRT.Set;
BEGIN
  state := firstState;
  WHILE state # NIL DO
    a := state.firstAction;
    WHILE a # NIL DO
      b := a^.next;
      WHILE b # NIL DO
        IF (a^.target^.state = b^.target^.state) & (a^.tc = b^.tc) THEN
          MakeSet(a, seta); MakeSet(b, setb); Sets.Unite(seta, setb);
          ChangeAction(a, seta);
          c := b; b := b^.next; DetachAction(c, a)
        ELSE b := b^.next
        END
      END;
      a := a^.next
    END;
    state := state.next
  END
END CombineShifts;


PROCEDURE DeleteRedundantStates;
VAR
  action: Action;
  state, s1, s2: State;
  used: CRT.Set;
  newState: ARRAY maxStates OF State;
  
  PROCEDURE FindUsedStates(state: State);
  VAR action: Action;
  BEGIN
    IF Sets.In(used, state.nr) THEN RETURN END;
    Sets.Incl(used, state.nr);
    action := state.firstAction;
    WHILE action # NIL DO
      FindUsedStates(action^.target^.state);
      action:=action^.next
    END
  END FindUsedStates;
  
  PROCEDURE DelUnused;
    VAR state: State;
  BEGIN
    state := firstState.next; lastState := firstState; stateNr := 0; (*firstState has number 0*)
    WHILE state # NIL DO
      IF Sets.In(used, state.nr) THEN INC(stateNr); state.nr := stateNr; lastState := state
      ELSE lastState.next := state.next
      END;
      state := state.next
    END
  END DelUnused;
    
BEGIN
  Sets.Clear(used); FindUsedStates(firstState);
  (*---------- combine equal final states ------------*)
  s1 := firstState.next;  (*first state cannot be final*)
  WHILE s1 # NIL DO
    IF Sets.In(used, s1.nr) & (s1.endOf # CRT.noSym) &  (s1.firstAction = NIL) & ~ s1.ctx THEN
      s2 := s1.next;
      WHILE s2 # NIL DO
        IF Sets.In(used, s2.nr) & (s1.endOf = s2.endOf) & (s2.firstAction = NIL) & ~ s2.ctx THEN
          Sets.Excl(used, s2.nr); newState[s2.nr] := s1
        END;
        s2 := s2.next
      END
    END;
    s1 := s1.next
  END;
  state := firstState;  (*> state := firstState.next*)
  WHILE state # NIL DO
    IF Sets.In(used, state.nr) THEN
      action := state.firstAction;
      WHILE action # NIL DO
        IF ~ Sets.In(used, action.target.state.nr) THEN
          action^.target^.state := newState[action.target.state.nr]
        END;
        action := action^.next
      END
    END;
    state := state.next
  END;
  DelUnused
END DeleteRedundantStates;

PROCEDURE ConvertToStates*(gp0, sp: INTEGER);
(*note: gn.line is abused as a state number!*)
  VAR n: INTEGER; S: ARRAY maxStates OF State; visited: CRT.MarkList;

  PROCEDURE NumberNodes (gp: INTEGER; state: State);
    VAR gn: CRT.GraphNode;
  BEGIN
    IF gp = 0 THEN RETURN END; (*end of graph*)
    CRT.GetNode(gp, gn);
    IF gn.line # 0 THEN RETURN END; (*already visited*)
    IF state = NIL THEN state := NewState() END;
    INC(n); S[n] := state; gn.line := n; CRT.PutNode(gp, gn);
    IF CRT.DelGraph(gp) THEN state.endOf := sp END; (*state is final state*)
    CASE gn.typ OF
      CRT.class, CRT.char: NumberNodes(ABS(gn.next), NIL)
    |  CRT.opt: NumberNodes(ABS(gn.next), NIL); NumberNodes(gn.p1, state)
    |  CRT.iter: NumberNodes(ABS(gn.next), state); NumberNodes(gn.p1, state)
    |  CRT.alt: NumberNodes(gn.p1, state); NumberNodes(gn.p2, state)
    END
  END NumberNodes;
  
  PROCEDURE TheState(gp: INTEGER): State;
    VAR state: State; gn: CRT.GraphNode;
  BEGIN
    IF gp = 0 THEN state := NewState(); state.endOf := sp; RETURN state
    ELSE CRT.GetNode(gp, gn); RETURN S[gn.line]
    END
  END TheState;
  
  PROCEDURE Step(from: State; gp: INTEGER);
    VAR gn: CRT.GraphNode;
  BEGIN
    IF gp = 0 THEN RETURN END;
    CRT.GetNode(gp, gn);
    CASE gn.typ OF
      CRT.class, CRT.char: NewTransition(from, TheState(ABS(gn.next)), gn.typ, gn.p1, gn.p2)
    | CRT.alt: Step(from, gn.p1); Step(from, gn.p2)
    | CRT.opt, CRT.iter: Step(from, ABS(gn.next)); Step(from, gn.p1)
    END
  END Step;

  PROCEDURE FindTrans (gp: INTEGER; start: BOOLEAN);
    VAR gn: CRT.GraphNode;
  BEGIN
    IF (gp = 0) OR Sets.In(visited, gp) THEN RETURN END;
    Sets.Incl(visited, gp); CRT.GetNode(gp, gn);
    IF start THEN Step(S[gn.line], gp) END; (*start of group of equally numbered nodes*)
    CASE gn.typ OF
      CRT.class, CRT.char: FindTrans(ABS(gn.next), TRUE)
    |  CRT.opt: FindTrans(ABS(gn.next), TRUE); FindTrans(gn.p1, FALSE)
    |  CRT.iter: FindTrans(ABS(gn.next), FALSE); FindTrans(gn.p1, FALSE)
    |  CRT.alt: FindTrans(gn.p1, FALSE); FindTrans(gn.p2, FALSE)
    END
  END FindTrans;
  
BEGIN
  IF CRT.DelGraph(gp0) THEN SemErr(20) END;
  n := 0; NumberNodes(gp0, firstState);
  CRT.ClearMarkList(visited); FindTrans(gp0, TRUE)
END ConvertToStates;


PROCEDURE MatchDFA* (s: ARRAY OF CHAR; sp: INTEGER; VAR matchedSp: INTEGER);
  VAR state, to: State; a: Action; i, len: INTEGER; weakMatch: BOOLEAN;
BEGIN (*s with quotes*)
  state := firstState; i := 1; len := Length(s) - 1; weakMatch := FALSE;
  LOOP (*try to match s against existing DFA*)
    IF i = len THEN EXIT END;
    a := TheAction(state, s[i]);
    IF a = NIL THEN EXIT END;
    IF a^.typ = CRT.class THEN weakMatch := TRUE END;
    state := a.target.state; INC(i)
  END;
  IF weakMatch & (i < len) THEN state := firstState; i := 1; dirtyDFA := TRUE END;
  WHILE i < len DO (*make new DFA for s[i..len-1]*)
    to := NewState();
    NewTransition(state, to, CRT.char, ORD(s[i]), CRT.normTrans);
    state := to; INC(i)
  END;
  matchedSp := state.endOf;
  IF state.endOf = CRT.noSym THEN state.endOf := sp END
END MatchDFA;


PROCEDURE SplitActions(a, b: Action);
VAR c: Action; seta, setb, setc: CRT.Set;
  
  PROCEDURE CombineTransCodes(t1, t2: INTEGER; VAR result:INTEGER);
  BEGIN
    IF t1 = CRT.contextTrans THEN result := t1 ELSE result := t2 END
  END CombineTransCodes;
    
BEGIN
  MakeSet(a, seta); MakeSet(b, setb);
  IF Sets.Equal(seta, setb) THEN
    AddTargetList(b^.target, a^.target);
    CombineTransCodes(a^.tc, b^.tc, a^.tc);
    DetachAction(b, a)
  ELSIF Sets.Includes(seta, setb) THEN
    setc := seta; Sets.Differ(setc, setb);
    AddTargetList(a^.target, b^.target);
    CombineTransCodes(a^.tc, b^.tc, b^.tc);
    ChangeAction(a, setc)
  ELSIF Sets.Includes(setb, seta) THEN
    setc := setb; Sets.Differ(setc, seta);
    AddTargetList(b^.target, a^.target);
    CombineTransCodes(a^.tc, b^.tc, a^.tc);
    ChangeAction(b, setc)
  ELSE
    Sets.Intersect(seta, setb, setc);
    Sets.Differ(seta, setc);
    Sets.Differ(setb, setc);
    ChangeAction(a, seta);
    ChangeAction(b, setb);
    NEW(c); c^.target:=NIL;
    CombineTransCodes(a^.tc, b^.tc, c^.tc);
    AddTargetList(a^.target, c^.target);
    AddTargetList(b^.target, c^.target);
    ChangeAction(c, setc);
    AddAction(c, a)
  END
END SplitActions;


PROCEDURE MakeUnique(state: State; VAR changed:BOOLEAN);
VAR a, b: Action; 

  PROCEDURE Overlap(a, b: Action): BOOLEAN;
    VAR seta, setb: CRT.Set;
  BEGIN
    IF a^.typ = CRT.char THEN
      IF b^.typ = CRT.char THEN RETURN a^.sym = b^.sym
      ELSE CRT.GetClass(b^.sym, setb); RETURN Sets.In(setb, a^.sym)
      END
    ELSE
      CRT.GetClass(a^.sym, seta);
      IF b^.typ = CRT.char THEN RETURN Sets.In(seta, b^.sym)
      ELSE CRT.GetClass(b^.sym, setb); RETURN ~ Sets.Different(seta, setb)
      END
    END
  END Overlap;
  
BEGIN
  a := state.firstAction; changed := FALSE;
  WHILE a # NIL DO
    b := a^.next;
    WHILE b # NIL DO
      IF Overlap(a, b) THEN SplitActions(a, b); changed:=TRUE END;
      b := b^.next;
    END;
    a:=a^.next
  END
END MakeUnique;


PROCEDURE MeltStates(state: State; VAR correct:BOOLEAN);
VAR
  action:  Action;
  ctx:     BOOLEAN;
  endOf:   INTEGER;
  melt:    Melted;
  set:     CRT.Set;
  s:      State;
  changed: BOOLEAN;
  
  PROCEDURE AddMeltedSet(nr: INTEGER; VAR set: CRT.Set);
  VAR m: Melted;
  BEGIN
    m := firstMelted;
    WHILE (m # NIL) & (m^.state.nr # nr) DO m := m^.next END;
    IF m = NIL THEN HALT(98) END;
    Sets.Unite(set, m^.set);
  END AddMeltedSet;

  PROCEDURE GetStateSet(t: Target; VAR set: CRT.Set; VAR endOf: INTEGER; VAR ctx:BOOLEAN);
  VAR statenr: INTEGER; (*lastS: State;*)
  BEGIN
    Sets.Clear(set); endOf := CRT.noSym; ctx := FALSE; (*lastS := NIL;*)
    WHILE t # NIL DO
      statenr := t.state.nr;
      IF statenr <= lastSimState THEN Sets.Incl(set, statenr)
      ELSE AddMeltedSet(statenr, set)
      END;
      IF t^.state^.endOf # CRT.noSym THEN
        IF (endOf = CRT.noSym) OR (endOf = t^.state^.endOf)
        (*OR (lastS^.firstAction # NIL) & (t^.state^.firstAction = NIL)*) THEN
          endOf := t^.state.endOf; (*lastS := t^.state*)
        ELSE
          PutS("$Tokens "); PutI(endOf); PutS(" and "); PutI(t^.state.endOf);
          PutS(" cannot be distinguished.$");
          correct:=FALSE
        END
      END;
      IF t^.state.ctx THEN ctx := TRUE;  END;
      t := t^.next
    END
  END GetStateSet;
    
  PROCEDURE FillWithActions(state: State; targ: Target);
  VAR action,a: Action;
  BEGIN
    WHILE targ # NIL DO
      action := targ^.state.firstAction;
      WHILE action # NIL DO
        NEW(a); a^ := action^; a^.target := NIL; 
        AddTargetList(action^.target, a^.target);
        AddAction(a, state.firstAction);
        action:=action^.next
      END;
      targ:=targ^.next
    END;
  END FillWithActions;

  PROCEDURE KnownMelted(set:CRT.Set; VAR melt: Melted): BOOLEAN;
  BEGIN
    melt := firstMelted;
    WHILE melt # NIL DO
      IF Sets.Equal(set, melt^.set) THEN RETURN TRUE END;
      melt := melt^.next
    END;
    RETURN FALSE
  END KnownMelted;

BEGIN
  action := state.firstAction;
  WHILE action # NIL DO
    IF action^.target^.next # NIL THEN (*more than one target state*)
      GetStateSet(action^.target, set, endOf, ctx);
      IF ~ KnownMelted(set, melt) THEN
        s := NewState(); s.endOf := endOf; s.ctx := ctx;
        FillWithActions(s, action^.target);
        REPEAT MakeUnique(s, changed) UNTIL ~ changed;
        melt := NewMelted(set, s);
      END;
      action^.target^.next:=NIL;
      action^.target^.state := melt^.state
    END;
    action := action^.next
  END;
  (*Texts.Append(Oberon.Log, out.buf)*)
END MeltStates;

PROCEDURE MakeDeterministic*(VAR correct: BOOLEAN);
  VAR state: State; changed: BOOLEAN;

  PROCEDURE FindCtxStates; (*find states reached by a context transition*)
  VAR a: Action; state: State;
  BEGIN
    state := firstState;
    WHILE state # NIL DO
      a := state.firstAction;
      WHILE a # NIL DO
        IF a^.tc = CRT.contextTrans THEN a^.target^.state.ctx := TRUE END;
        a := a^.next
      END;
      state := state.next
    END;
  END FindCtxStates;

BEGIN
  IF lastState = NIL THEN lastSimState := 0 ELSE lastSimState := lastState.nr END;
  FindCtxStates;
  state := firstState;
  WHILE state # NIL DO
    REPEAT MakeUnique(state, changed) UNTIL ~ changed;
    state := state.next 
  END;
  correct := TRUE;
  state := firstState;
  WHILE state # NIL DO MeltStates(state, correct); state := state.next END;
  DeleteRedundantStates;
  CombineShifts
END MakeDeterministic;


PROCEDURE PrintSymbol(typ, val, width: INTEGER);
VAR name: CRT.Name; len: INTEGER;
BEGIN
  IF typ = CRT.class THEN
    CRT.GetClassName(val, name); PutS(name); len := Length(name)
  ELSIF (val >= ORD(" ")) & (val < 127) & (val # 34) THEN
    Put(CHR(34)); Put(CHR(val)); Put(CHR(34)); len:=3
  ELSE
    PutS("CHR("); PutI2(val, 2); Put(")"); len:=7
  END;
  WHILE len < width DO Put(" "); INC(len) END
END PrintSymbol;


PROCEDURE PrintStates*;
VAR action: Action; first: BOOLEAN; state: State; i: INTEGER; targ: Target; set: CRT.Set; name: CRT.Name;
BEGIN
  PutS("$-------- states ---------$");
  state := firstState;
  WHILE state # NIL DO
    action := state.firstAction; first:=TRUE;
    IF state.endOf = CRT.noSym THEN PutS("     ") 
    ELSE PutS("E("); PutI2(state.endOf, 2); Put(")")
    END;
    PutI2(state.nr, 3); Put(":"); IF action = NIL THEN PutS(" $") END;
    WHILE action # NIL DO
      IF first THEN Put(" "); first:=FALSE ELSE PutS("          ") END;
      PrintSymbol(action^.typ, action^.sym, 0); Put(" ");
      targ := action^.target;
      WHILE targ # NIL DO
        PutI(targ^.state.nr); Put(" "); targ := targ^.next;
      END;
      IF action^.tc = CRT.contextTrans THEN PutS(" context$") ELSE PutS(" $") END;
      action := action^.next
    END;
    state := state.next
  END;
  PutS("$-------- character classes ---------$");
  i := 0;
  WHILE i <= CRT.maxC DO
    CRT.GetClass(i, set); CRT.GetClassName(i, name); PutS(name); PutS(": ");
    (*Sets.Print(out, set, 80, 13); Texts.WriteLn(out);*)
    Sets.Write(set, 80, 13); Out.Ln;
    INC(i)
  END;
  (*Texts.Append(Oberon.Log, out.buf)*)
END PrintStates;


PROCEDURE GenComment(com:Comment; i: INTEGER);

  PROCEDURE GenBody;
  BEGIN
    PutS("    LOOP$");
    PutS("      IF "); PutChCond(com^.stop[0]); PutS(" THEN$");
    IF Length(com^.stop) = 1 THEN
      PutS("        DEC(level);$");
      PutS("        IF level = 0 THEN oldEols := chLine - startLine; NextCh; RETURN TRUE END;$");
      PutS("        NextCh;$");
    ELSE
      PutS("        NextCh;$");
      PutS("        IF "); PutChCond(com^.stop[1]); PutS(" THEN$");
      PutS("          DEC(level);$");
      PutS("          IF level=0 THEN oldEols := chLine - startLine; NextCh; RETURN TRUE END;$");
      PutS("          NextCh;$");
      PutS("        END;$");
    END;
    IF com^.nested THEN
      PutS("      ELSIF "); PutChCond(com^.start[0]); PutS(" THEN$");
      IF Length(com^.start) = 1 THEN
        PutS("        INC(level); NextCh;$");
      ELSE
        PutS("        NextCh;$");
        PutS("        IF "); PutChCond(com^.start[1]); PutS(" THEN$");
        PutS("          INC(level); NextCh;$");
        PutS("        END;$");
      END;
      END;
    PutS("      ELSIF ch = EOF THEN RETURN FALSE$");
    PutS("      ELSE NextCh END;$");
    PutS("    END;$");
    END GenBody;
    
BEGIN
  PutS("PROCEDURE Comment"); PutI(i); PutS("(): BOOLEAN;$");
  PutS("  VAR level, startLine: INTEGER; oldLineStart: LONGINT;$");
  PutS("BEGIN$");
  PutS("  level := 1; startLine := chLine; oldLineStart := lineStart;$");
  IF Length(com^.start) = 1 THEN
    PutS("  NextCh;$");
    GenBody;
  ELSE
    PutS("  NextCh;$");
    PutS("  IF "); PutChCond(com^.start[1]); PutS(" THEN$");
    PutS("    NextCh;$");
    GenBody;
    PutS("  ELSE$");
    PutS("    IF ch = EOL THEN DEC(chLine); lineStart := oldLineStart END;$");
    PutS("    DEC(chPos, 2); Texts.OpenReader(r, src, chPos+1); NextCh; RETURN FALSE$");
    PutS("  END$");
  END;
  PutS("END Comment"); PutI(i); PutS(";$$$")
END GenComment;


PROCEDURE CopyFramePart (stopStr: ARRAY OF CHAR); (*Copy from file <fram> to file <out> until <stopStr>*)
  VAR ch, startCh: CHAR; i, j, high: INTEGER;
BEGIN
  startCh := stopStr[0]; high := Length(stopStr) - 1; Texts.Read (fram, ch);
  WHILE ch # 0X DO
    IF ch = startCh THEN (* check if stopString occurs *)
      i := 0;
      REPEAT
        IF i = high THEN RETURN END;  (*stopStr[0..i] found; no unrecognized character*)
        Texts.Read (fram, ch); INC(i);
      UNTIL ch # stopStr[i];
      (*stopStr[0..i-1] found; 1 unrecognized character*)
      j := 0;
      WHILE j < i DO 
         (*Texts.Write(out, stopStr[j]);*)
         Out.Char(stopStr[j]);
	 INC(j)
      END
    ELSE
       (*Texts.Write (out, ch);*)
       Out.Char (ch);
       Texts.Read(fram, ch)
    END
  END
END CopyFramePart;

PROCEDURE GenLiterals;
  VAR 
    i, j, k, l: INTEGER; 
    key: ARRAY 128 OF CRT.Name; 
    knr: ARRAY 128 OF INTEGER;
    ch: CHAR;
    sn: CRT.SymbolNode;
BEGIN
  (*-- sort literal list*)
  i := 0; k := 0;
  WHILE i <= CRT.maxT DO
    CRT.GetSym(i, sn);
    IF sn.struct = CRT.litToken THEN
      j := k-1; WHILE (j >= 0) & (sn.name < key[j]) DO key[j+1] := key[j]; knr[j+1] := knr[j]; DEC(j) END;
      key[j+1] := sn.name; knr[j+1] := i; INC(k)
    END;
    INC(i)
  END;
  (*-- print case statement*)
  IF k > 0 THEN
    PutS("    IF (lexeme[0] >= "); PutC(key[0, 1]); PutS(") & (lexeme[0] <= "); PutC(key[k-1, 1]); PutS(") THEN$");
    PutS("      CASE lexeme[0] OF$");
    i := 0;
    WHILE i < k DO
      ch := key[i, 1];  (*key[i, 0] = quote*)
      PutS("      | "); PutC(ch); j := i;
      REPEAT
        IF i = j THEN PutS(": IF lexeme = ") ELSE PutS("        ELSIF lexeme = ") END;
        PutS(key[i]); PutS(" THEN sym := "); PutI(knr[i]); Put(CHR(13));
        INC(i)
      UNTIL (i = k) OR (key[i, 1] # ch);
      PutS("        END$");
    END;
    PutS("      ELSE$      END$    END;$")
  END
END GenLiterals;


PROCEDURE WriteState(state: State);
  VAR action: Action; first, ctxEnd: BOOLEAN; sn: CRT.SymbolNode; endOf: INTEGER;
    set: CRT.Set;
BEGIN
  endOf := state.endOf;
  IF (endOf > CRT.maxT) & (endOf # CRT.noSym) THEN (*pragmas have been moved*)
    endOf := CRT.maxT + CRT.maxSymbols - endOf 
  END;
  PutS("    | "); PutI2(state.nr, 2); PutS(": ");
  first:=TRUE; ctxEnd := state.ctx;
  action := state.firstAction;
  WHILE action # NIL DO
    IF first THEN PutS("IF "); first:=FALSE ELSE PutS("          ELSIF ") END;
    IF action^.typ = CRT.char THEN PutChCond(CHR(action^.sym))
    ELSE CRT.GetClass(action^.sym, set); PutRange(set)
    END;
    PutS(" THEN");
    IF action.target.state.nr # state.nr THEN
      PutS(" state := "); PutI(action.target.state.nr); Put(";")
    END;
    IF action^.tc = CRT.contextTrans THEN PutS(" INC(apx)"); ctxEnd := FALSE 
    ELSIF state.ctx THEN PutS(" apx := 0") 
    END;
    PutS(" $");
    action := action^.next
  END;
  IF state.firstAction # NIL THEN PutS("          ELSE ") END;
  IF endOf = CRT.noSym THEN PutS("sym := noSym; ")
  ELSE (*final state*)
    CRT.GetSym(endOf, sn);
    IF ctxEnd THEN (*final context state: cut appendix*)
      PutS("chPos := chPos - apx - 1; Texts.OpenReader(r, src, chPos+1); NextCh; ")
    END;
    PutS("sym := "); PutI(endOf); PutS("; ");
    IF sn.struct = CRT.classLitToken THEN PutS("CheckLiteral; ") END
  END;
  PutS("RETURN$");
  IF state.firstAction # NIL THEN PutS("          END;$") END
END WriteState;

PROCEDURE *Show (t: Texts.Text; op: INTEGER; beg, end: LONGINT);
END Show;
  

PROCEDURE WriteScanner* (VAR ok: BOOLEAN);
VAR
  scanner: ARRAY 32 OF CHAR;
  name:     ARRAY 64 OF CHAR;
  startTab: ARRAY 128 OF INTEGER;
  com:      Comment;
  i, j, l:  INTEGER;
  gn:       CRT.GraphNode;
  sn:       CRT.SymbolNode;
  state: State;
  t: Texts.Text;
  
  PROCEDURE FillStartTab;
    VAR action: Action; i, targetState: INTEGER; class: CRT.Set;
  BEGIN
    startTab[0] := stateNr + 1; (*eof*)
    i := 1; WHILE i < 128 DO startTab[i] := 0; INC(i) END;
    action := firstState.firstAction;
    WHILE action # NIL DO
      targetState := action.target.state.nr;
      IF action^.typ = CRT.char THEN 
        startTab[action^.sym] := targetState
      ELSE
        CRT.GetClass(action^.sym, class); i := 0;
        WHILE i < 128 DO
          IF Sets.In(class, i) THEN startTab[i] := targetState END;
          INC(i)
        END
      END;
      action := action^.next
    END
  END FillStartTab;
    
BEGIN
  IF dirtyDFA THEN MakeDeterministic(ok) END;
  FillStartTab;
  CRT.GetNode(CRT.root, gn); CRT.GetSym(gn.p1, sn);
  COPY(sn.name, scanner); l := Length(scanner); scanner[l] := "S"; scanner[l+1] := 0X;
  NEW(t); Texts.Open(t, "Scanner.FRM"); Texts.OpenReader(fram, t, 0);
  IF t.len = 0 THEN
    (*Texts.WriteString(out, "Scanner.FRM not found"); Texts.WriteLn(out);*)
    Out.String("Scanner.FRM not found"); Out.Ln;
    (*Texts.Append(Oberon.Log, out.buf);*) HALT(99)
  END;
  (*Texts.Append(Oberon.Log, out.buf);*)
  
  (*------- *S.MOD -------*)
  CopyFramePart("-->modulename"); PutS(scanner);
  CopyFramePart("-->declarations"); PutS("  noSym = "); PutI(CRT.maxT); Put(";");
  CopyFramePart("-->comment");
  com := firstComment; i := 0;
  WHILE com # NIL DO GenComment(com, i); com := com^.next; INC(i) END;
  CopyFramePart("-->literals"); GenLiterals;
  
  CopyFramePart("-->GetSy1");
  PutS("  WHILE (ch=20X)"); IF ~ Sets.Empty(CRT.ignored) THEN PutS(" OR ") END;
  PutRange(CRT.ignored); PutS(" DO NextCh END;");
  IF firstComment # NIL THEN
    PutS("$    IF "); com := firstComment; i := 0;
    WHILE com # NIL DO
      PutChCond(com^.start[0]);
      PutS(" & Comment"); PutI(i); PutS("() ");
      IF com^.next # NIL THEN PutS(" OR ") END;
      com := com^.next; INC(i)
    END;
    PutS(" THEN Get(sym); RETURN END;")
  END;
  CopyFramePart("-->GetSy2");
  state := firstState.next;
  WHILE state # NIL DO WriteState(state); state := state.next END;
  PutS("    | "); PutI2(stateNr + 1, 2); PutS(": sym := 0; ch := 0X; RETURN$");
  
  CopyFramePart("-->initialization");
  i := 0;
  WHILE i < 32 DO
    j := 0; PutS("  ");
    WHILE j < 4 DO
      PutS("start["); PutI(4*i+j); PutS("]:="); PutI(startTab[4*i+j]); PutS("; ");
      INC(j)
    END;
    (*Texts.WriteLn(out); *)
    Out.Ln; 
    INC(i)
  END;
  
  CopyFramePart("-->modulename"); PutS(scanner); Put(".");
  NEW(t); (*t.notify := Show;*) Texts.Open(t, ""); Texts.Append(t, out.buf);
  l := Length(scanner); scanner[l] := "."; scanner[l+1] := "M"; scanner[l+2] := "o"; scanner[l+3] := "d"; scanner[l+4] := 0X;
  Texts.Close(t, scanner)
END WriteScanner;


PROCEDURE Init*;
BEGIN
  firstState := NIL; lastState := NIL; stateNr := -1;
  rootState := NewState();
  firstMelted := NIL; firstComment := NIL;
  dirtyDFA := FALSE
END Init;

BEGIN
  Texts.OpenWriter(out)
END CRA.

