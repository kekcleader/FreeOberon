(* Ulm's Oberon Library
  Copyright (C) 1989-1997 by University of Ulm, SAI, D-89069 Ulm, Germany
  ----------------------------------------------------------------------------
  Ulm's Oberon Library is free software; you can redistribute it
  and/or modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either version
  2 of the License, or (at your option) any later version.

  Ulm's Oberon Library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  ----------------------------------------------------------------------------
  E-mail contact: oberon@mathematik.uni-ulm.de
  ----------------------------------------------------------------------------
  $Id: TCrypt.om,v 1.1 1997/04/02 11:54:02 borchert Exp borchert $
  ----------------------------------------------------------------------------
  $Log: TCrypt.om,v $
  Revision 1.1  1997/04/02  11:54:02  borchert
  Initial revision

  ----------------------------------------------------------------------------
*)

MODULE ulmTCrypt; (* Michael Szczuka *)

  (* Trautner's association method for key exchange *)

  IMPORT
    AsymmetricCiphers := ulmAsymmetricCiphers, BlockCiphers := ulmBlockCiphers,
    Ciphers           := ulmCiphers,           Conclusions  := ulmConclusions,
    Events            := ulmEvents,            NetIO        := ulmNetIO,
    PersistentObjects := ulmPersistentObjects, Random       := ulmRandomGenerators,
    RelatedEvents     := ulmRelatedEvents,     Services     := ulmServices,
    Streams           := ulmStreams,           SYS          := SYSTEM,
    Types := ulmTypes;

  CONST
    M = 16; (* size of an element of CC(M) [ring of Circular Convolution] *)
    MaxVar = 8;   (* number of variables of a polynomial *)
    MaxNrExp = 4;  (* maxiumum number of different exponts used during
                initialisaton *)
    Dim = 2;  (* dimension of the linear recursion *)
    Rounds = 16;   (* length of the linear recursion in rounds *)
    LastRounds = 4;   (* use the last LastRounds polynomial vectors as
                  the composed function eta *)
    reg = 1;  sing = 2;  random = 3;
    LIST = TRUE; NOLIST = FALSE;
    MaxTerms = 1000;

  CONST
    writeSetFailed = 0;
    readSetFailed = 1;
    notRegular = 2;
    errorcodes = 3;

  TYPE
    (* an element out of CC(M) *)
    CCMElement = Types.Set;
    Exponent = ARRAY MaxVar OF Types.Int8;

  TYPE
    (* a polynomial with coefficients out of CC(M) *)
    Polynom = POINTER TO PolynomRec;
    PolynomRec = RECORD
      koeff : CCMElement;
      exp : Exponent;
      next : Polynom;
    END;

  TYPE
    VektorCCM = ARRAY Dim OF CCMElement;
    VektorPolynom = ARRAY Dim OF Polynom;
    MatCCM = ARRAY Dim, Dim OF CCMElement;
    MatPolynom = ARRAY Dim, Dim OF Polynom;
    ListCCM = ARRAY Rounds OF CCMElement;
    ListPolynom = ARRAY Rounds OF Polynom;
    ChainCCM = ARRAY Rounds OF VektorCCM;
    ChainPolynom = ARRAY Rounds OF VektorPolynom;
    (* to increase the performance of the algorithm there shouldn't be too
      many different exponents to start with  *)
    ListExp = ARRAY MaxNrExp OF Exponent;

  TYPE
    (* this type is the input of the TCrypt method *)
    TCryptInput = POINTER TO TCryptInputRec;
    TCryptInputRec = RECORD
      arg : ARRAY MaxVar OF CCMElement;
    END;

  TYPE
    (* result type after encryption with the public key *)
    TCryptTmp = POINTER TO TCryptTmpRec;
    TCryptTmpRec = RECORD
      numerator : ChainCCM;
      denominator : ListCCM;
    END;

  TYPE
    (* result type of the algorithm *)
    TCryptRes = POINTER TO TCryptResRec;
    TCryptResRec = RECORD
      arg : ARRAY LastRounds OF VektorCCM;
    END;

  TYPE
    (* this type represents the public function f resp. phi *)
    Phi = POINTER TO PhiRec;
    PhiRec = RECORD
      num :  ChainPolynom;
      denom : ListPolynom;
    END;

  TYPE
    (* the private/secret function g resp. psi consisting of an inital matrix
      and a permutation *)
    Psi = POINTER TO PsiRec;
    PsiRec = RECORD
      (* although the inital matrix consists only of elements out of CC(M)
        this generalization is useful since all other matrces consist of
        polynomials *)
      initialmatrix : MatCCM;
      (* correcting factors *)
      korrNum : ChainCCM;
      korrDenom : ListCCM;
    END;

  (* the public function h resp. eta being the composition of f/phi
    and g/psi *)
  TYPE
    Eta = POINTER TO EtaRec;
    EtaRec = RECORD
      p : ARRAY LastRounds OF VektorPolynom;
    END;

  TYPE
    (* the declaration of a basic type which PublicCipher and PrivateCipher
      are descendents from seems a good idea ... at least to me :)  *)
    Cipher* = POINTER TO CipherRec;
    CipherRec* = RECORD (AsymmetricCiphers.CipherRec) END;
    (* the specific format of a public key for Trautner's technique *)
    PublicCipher = POINTER TO PublicCipherRec;
    PublicCipherRec = RECORD
      (CipherRec)
      phi : Phi;
      eta : Eta;
    END;
    (* the specific format of a key for Trautner's technique *)
    PrivateCipher = POINTER TO PrivateCipherRec;
    PrivateCipherRec = RECORD
      (CipherRec)
      phi : Phi;
      psi : Psi;
      eta : Eta;
    END;

  TYPE
    ErrorEvent = POINTER TO ErrorEventRec;
    ErrorEventRec = RECORD
      (Events.EventRec)
      errorcode : Types.Int8;
    END;

  VAR
    pubType, privType, cipherType : Services.Type;
    pubIf, privIf, cipherIf : PersistentObjects.Interface;
    NullCCM, EinsCCM : CCMElement;   (* the zero and unit of CC(M) *)
    NullExp : Exponent;       (* consists of zero exponents *)
    NullExpList : ListExp;  (* a pseudo list for CreatePolynom *)
    GlobalExpList : ListExp;  (* contains the exponents which should be used
                        when calling CreatePolynom *)
    NullPolynom : Polynom;  (* the zero polynomial *)
    PolFeld : ARRAY MaxTerms OF Polynom;  (* used for sorting purposes *)
    PreEvalArg : ARRAY M OF TCryptInput;  (* precomputed values to speed
        up evaluation of a polynomial *)
    k : Types.Int8;  (* simple counter during initialisation *)
    error : Events.EventType;
    errormsg : ARRAY errorcodes OF Events.Message;


  (* ***** error handling ***** *)

  PROCEDURE InitErrorHandling;
  BEGIN
    Events.Define(error);
    errormsg[writeSetFailed] := "couldn't write set";
    errormsg[readSetFailed] := "couldn't read set";
    errormsg[notRegular] := "element isn't regular";
  END InitErrorHandling;

  PROCEDURE Error(s: Streams.Stream; errorcode: Types.Int8);
    VAR
      event: ErrorEvent;
  BEGIN
    NEW(event);
    event.message := errormsg[errorcode];
    event.type := error;
    event.errorcode := errorcode;
    RelatedEvents.Raise(s, event);
  END Error;

  (* ***** arithmetic functions for elements out of CC(M) ***** *)

  PROCEDURE RegulaerCCM (x: CCMElement) : BOOLEAN;
    (* tests x for regularity [a regular CCMElement contains an odd number of
      set bits]; returns TRUE when x is regular, FALSE otherwise *)
    VAR
      res, i : Types.Int8;
  BEGIN
    i := 0;
    res := 0;
    REPEAT            (* counting the set bits *)
      IF i IN x THEN
        INC(res);
      END;
      INC(i);
    UNTIL i>=M;
    RETURN ((res MOD 2) = 1);
  END RegulaerCCM;

  PROCEDURE EqualCCM (x, y: CCMElement) : BOOLEAN;
    (* compares x and y for equality; if x and y are equal TRUE is returned,
      FALSE otherwise *)
    VAR
      i : Types.Int8;
  BEGIN
    i := 0;
    WHILE i < M DO
      IF ((i IN x) & (~(i IN y))) OR ((~(i IN x)) & (i IN y)) THEN
        RETURN FALSE;
      END;
      INC(i);
    END;
    RETURN TRUE;
  END EqualCCM;

  PROCEDURE AddCCM (x, y: CCMElement; VAR z: CCMElement);
    (* add x and y in CC(M) *)
    VAR
      i : Types.Int8;
  BEGIN
    z := NullCCM;
    i := 0;
    REPEAT
      IF ((i IN x) & (~(i IN y))) OR ((~(i IN x)) & (i IN y)) THEN
        z := z + {i};
      END;
      INC(i);
    UNTIL i>=M;
  END AddCCM;

  PROCEDURE MulCCM (x, y: CCMElement; VAR z: CCMElement);
    (* multiply x and y in CC(M) *)
    VAR
      i, j, diff : Types.Int8;
      tmp : Types.Int32;
  BEGIN
    z := NullCCM;
    i := 0;
    REPEAT
      j := 0;
      tmp := 0;
      REPEAT
        diff := i-j;
        IF diff >= 0 THEN
          IF (j IN x) & (diff IN y) THEN
            INC(tmp);
          END;
        ELSE
          IF (j IN x) & ((M+diff) IN y) THEN
            INC(tmp);
          END;
        END;
        INC(j);
      UNTIL j>=M;
      IF (tmp MOD 2) = 1 THEN
        z := z + {i};
      END;
      INC(i);
    UNTIL i>=M;
  END MulCCM;

  PROCEDURE PowerCCM (x: CCMElement; exp: Types.Int32; VAR z: CCMElement);
    (* raises x to the power exp in CC(M) *)
    VAR
      tmp : CCMElement;
  BEGIN
    (* some special cases first *)
    IF exp >= M THEN
      IF ~RegulaerCCM(x) THEN
      (* x is singular -> result is zero *)
        z := NullCCM;
        RETURN;
      END;
      (* x is regular -> compute the modulus of exp mod M and use this
        instead of exp *)
      exp := exp MOD M;
    END;
    IF exp = 0 THEN
      z := EinsCCM;
      RETURN;
    END;
    IF exp = 1 THEN
      z := x;
      RETURN;
    END;

    (* default case; use a "square and multiply" technique *)
    tmp := x;
    z := EinsCCM;
    REPEAT
      IF exp MOD 2 = 1 THEN
        MulCCM(z, tmp, z);
      END;
      exp := exp DIV 2;
      MulCCM(tmp, tmp, tmp);
    UNTIL exp < 1;
  END PowerCCM;

  PROCEDURE CreateCCM (VAR x: CCMElement; mode: Types.Int8);
    (* creates a random element out of CC(M) depending on mode which
      can be reg, sing or random;
      the result is in any case different from the zero *)
    VAR
      i, SetBits: Types.Int8;
  BEGIN
    x := NullCCM;
    REPEAT
      i := 0;
      SetBits := 0;
      REPEAT
        IF Random.Flip() THEN
          (* set bit *)
          x := x + {i};
          INC(SetBits);
        END;
        INC(i);
      UNTIL i >= (M-1);
    UNTIL SetBits > 0;   (* at least one bit must be set so that the result
                    differs from zero *)

    CASE mode OF
      random:
        IF Random.Flip() THEN
          x := x + {M-1};
        END;
    |  sing:          (* singular element - even # of bits *)
        IF (SetBits MOD 2) = 1 THEN
          x := x + {M-1};
        END;
    |  reg:           (* regular element - odd # of bits *)
        IF ((SetBits + 1) MOD 2) = 1 THEN
          x := x + {M-1};
        END;
    ELSE
    END;
  END CreateCCM;

  (* ***** arithmetic functions for polynomials over CC(M) ***** *)

  PROCEDURE LengthPolynom(p: Polynom) : Types.Int32;
    (* returns the number of terms which make up the polynomial p *)
    VAR
      i : Types.Int32;
  BEGIN
    i := 0;
    WHILE p # NIL DO
      INC(i);
      p := p.next;
    END;
    RETURN i;
  END LengthPolynom;

  PROCEDURE RegulaerPolynom (p: Polynom) : BOOLEAN;
    (* tests the regularity of a polynomial [a polynomial is regular
      iff the # of regular coefficients is odd] *)
    VAR
      regkoeffs : Types.Int8;
  BEGIN
    regkoeffs := 0;
    WHILE p # NIL DO
      IF RegulaerCCM(p.koeff) THEN
      (* count # of reg. coefficients *)
        INC(regkoeffs);
      END;
      p := p.next;
    END;
    RETURN (regkoeffs MOD 2) = 1;
  END RegulaerPolynom;

  PROCEDURE CmpExp (exp1, exp2: Exponent) : Types.Int8;
    (* compares two exponent vectors and returns 0 on equality, a
      positive value if exp1>exp2 and a negative value if exp1<exp2;
      the absolute value can be 1 or 2 : 2 if the sums of the
      vectors differ, 1 otherwise; this distinction isn't used, but
      it could be useful for later versions *)
    VAR
      i : Types.Int8;
      e1, e2: Types.Int32; diff: BOOLEAN; cmp: Types.Int8;
      sum1, sum2 : Types.Int32;
  BEGIN
    i := 0;
    sum1 := 0; sum2 := 0; diff := FALSE; cmp := 0;
    REPEAT
      e1 := exp1[i]; e2 := exp2[i];
      INC(sum1, e1); INC(sum2, e2);
      IF ~diff THEN
        IF e1 < e2 THEN
          cmp := -1; diff := TRUE;
        ELSIF e1 > e2 THEN
          cmp := 1; diff := TRUE;
        END;
      END;
      INC(i);
    UNTIL i >= MaxVar;

    IF sum1 < sum2 THEN
      RETURN -2;
    END;
    IF sum1 > sum2 THEN
      RETURN 2;
    END;

    RETURN cmp
  END CmpExp;

  PROCEDURE ArrangePolynom (VAR p: Polynom);
    (* arrange a polynomial according to the order given by CmpExp *)
    VAR
      r : Polynom;
      cnt : Types.Int32;

    PROCEDURE SortPolynom(left, right: Types.Int32);
      (* sort the global field PolFeld with the quicksort algorithm *)
      VAR
        mid : Types.Int32;

      PROCEDURE Partition(l, r: Types.Int32) : Types.Int32;
        VAR
          koeff : CCMElement;
          exp : Exponent;
          cmp : Exponent;
          i, j : Types.Int32;
      BEGIN
        cmp := PolFeld[(l+r) DIV 2].exp;
        i := l-1;
        j := r+1;
        LOOP
          REPEAT
            DEC(j);
          UNTIL CmpExp(PolFeld[j].exp, cmp) >= 0;
          REPEAT
            INC(i);
          UNTIL CmpExp(PolFeld[i].exp, cmp) <= 0;
          IF i < j THEN
            koeff := PolFeld[i].koeff;
            exp := PolFeld[i].exp;
            PolFeld[i].koeff := PolFeld[j].koeff;
            PolFeld[i].exp := PolFeld[j].exp;
            PolFeld[j].koeff := koeff;
            PolFeld[j].exp := exp;
          ELSE
            RETURN j;
          END;
        END;
      END Partition;

    BEGIN
      IF left < right THEN
        mid := Partition(left, right);
        SortPolynom(left, mid);
        SortPolynom(mid+1, right);
      END;
    END SortPolynom;

  BEGIN (* ArrangePolynom *)
    IF p = NIL THEN
      RETURN;
    END;
    r := p;
    cnt := 0;
    WHILE (p # NIL) & (cnt < MaxTerms) DO
      PolFeld[cnt] := p;
      INC(cnt);
      p := p.next;
    END;
    (* polynomial contains too many terms; this shouldn't happen if all
      parameters are set to reasonable values and MaxTerms is high
      enough *)
    ASSERT(cnt<MaxTerms);
    IF cnt > 1 THEN
      SortPolynom(0, cnt-1);
    END;
    p := r;
  END ArrangePolynom;

  PROCEDURE CopyPolynom (s: Polynom; VAR t: Polynom);
    (* copy the source polynomial s to a new target t *)
    VAR
      troot : Polynom;
  BEGIN
    IF s = NIL THEN
      t := NIL;
      RETURN;
    END;
    NEW(t);
    troot := t;               (* save the root of t *)
    WHILE s # NIL DO
      troot.koeff := s.koeff;
      troot.exp := s.exp;
      s := s.next;
      IF s # NIL THEN
        NEW(troot.next);
        troot := troot.next;
      ELSE
        troot.next := NIL;
      END;
    END;
  END CopyPolynom;

  PROCEDURE AddPolynom (p, q: Polynom; VAR r: Polynom);
    (* add two polynomial; the polynomials must be sorted by the exponents as
      is the result *)
    VAR
      term1, term2 : Polynom;
      last : Polynom;                (* the last term of the result *)
      tmp : Polynom;
      cmpres : Types.Int8;
  BEGIN
    IF (p = NIL) & (q = NIL) THEN
      r := NIL;
      RETURN;
    END;
    NEW(r);
    term1 := p;       (* term1 runs through all terms of p *)
    term2 := q;       (* same with term2 for q *)
    tmp := r; (* save the root of r *)
    last := tmp;
    REPEAT
      IF (term1 = NIL) OR (term2 = NIL) THEN
        IF term2 = NIL THEN
        (* no further terms in q *)
          WHILE term1 # NIL DO
          (* copy the remaining terms of p *)
            tmp.koeff := term1.koeff;
            tmp.exp := term1.exp;
            term1 := term1.next;
            IF ~EqualCCM(tmp.koeff, NullCCM) THEN
              last := tmp;
              NEW(tmp.next);
              tmp := tmp.next;
            END;
          END;
        ELSE   (* no further terms in p *)
          WHILE term2 # NIL DO
            tmp.koeff := term2.koeff;
            tmp.exp := term2.exp;
            term2 := term2.next;
            IF ~EqualCCM(tmp.koeff, NullCCM) THEN
              last := tmp;
              NEW(tmp.next);
              tmp := tmp.next;
            END;
          END;
        END;
      ELSE   (* both p and q still have a term *)
        cmpres := CmpExp(term1.exp, term2.exp);
        IF cmpres = 0 THEN  (* add when exponents are equal *)
          AddCCM(term1.koeff, term2.koeff, tmp.koeff);
          tmp.exp := term1.exp;
          term1 := term1.next;
          term2 := term2.next;
        ELSE
          IF cmpres < 0 THEN       (* exp2 > exp1 *)
            tmp.koeff := term2.koeff;
            tmp.exp := term2.exp;
            term2 := term2.next;
          ELSE                     (* exp1 > exp2 *)
            tmp.koeff := term1.koeff;
            tmp.exp := term1.exp;
            term1 := term1.next;
          END;
        END;
        (* zero coefficients = zero terms shouldn't occur in the result *)
        IF ~EqualCCM(tmp.koeff, NullCCM) THEN
          NEW(tmp.next);
          last := tmp;
          tmp := tmp.next;
        END;
      END;
    UNTIL (term1 = NIL) & (term2 = NIL);

    (* forget last created term *)
    last.next := NIL;
  END AddPolynom;

  PROCEDURE MulTerm (p, term: Polynom; VAR r: Polynom);
    (* multiply a polynomial with a single term; is used by MulPolynom *)
    VAR
      tmp : Polynom;
      last : Polynom;

    (* add two exponent vetors; addition is modulo M *)
    PROCEDURE AddExp (exp1, exp2 : Exponent; VAR res: Exponent);
      VAR
        i : Types.Int8;
    BEGIN
      i := 0;
      WHILE i<MaxVar DO
        res[i] := (exp1[i] + exp2[i]) MOD M;
        INC(i);
      END;
    END AddExp;

  BEGIN (* MulTerm *)
    IF (p = NIL) OR (term = NIL) THEN
      r := NIL;
      RETURN;
    END;
    NEW(r);
    tmp := r;         (* copy root *)
    last := r;
    WHILE p # NIL DO
      (* multiply coefficients *)
      MulCCM(p.koeff, term.koeff, tmp.koeff);
      (* no zero terms allowed *)
      IF ~EqualCCM(tmp.koeff, NullCCM) THEN
        (* add exponents *)
        AddExp(p.exp, term.exp, tmp.exp);
        NEW(tmp.next);
        last := tmp;
        tmp := tmp.next;
      END;
      p := p.next;
    END;
    (* forget last term (is zero anyway) *)
    last.next := NIL;
    (* result must be arranged first before returned *)
    ArrangePolynom(r);
  END MulTerm;

  PROCEDURE MulPolynom (p, q: Polynom; VAR r: Polynom);
    (* multiply two polynomials over CC(M); must be sorted *)
    VAR
      tmp, qterm : Polynom;
  BEGIN
    r := NIL;
    IF (p = NIL) OR (q = NIL) THEN
      RETURN;
    END;
    qterm := q;
    WHILE qterm # NIL DO
      MulTerm(p,qterm,tmp);  (* multiply p with current term of q *)
      AddPolynom(tmp,r,r);   (* add up results *)
      qterm := qterm.next;
    END;
    ArrangePolynom(r);
  END MulPolynom;

  PROCEDURE MulPolynomWithCCM (p: Polynom; c: CCMElement; VAR r: Polynom);
    (* multiplies a polynomial with a single element out of CC(M) *)
    VAR
      tmp : Polynom;
  BEGIN
    IF p = NIL THEN
      r := NIL;
      RETURN;
    END;
    CopyPolynom(p, r);
    tmp := r;
    WHILE tmp # NIL DO
      MulCCM(tmp.koeff, c, tmp.koeff);
      tmp := tmp.next;
    END;
  END MulPolynomWithCCM;

  PROCEDURE InvertPolynom (p: Polynom; VAR res: Polynom);
    (* inverts a regular polynomial; if p is illegal (NIL) or singular the
      result is NIL *)
    VAR
      exp : Types.Int8;
      tmp : Polynom;
  BEGIN
    IF (p = NIL) OR ~RegulaerPolynom(p) THEN
      res := NIL;
      RETURN;
    END;
    CopyPolynom(p, tmp);
    CopyPolynom(NullPolynom, res);
    res.koeff := EinsCCM;
    (* works the same way as PowerCCM ["square-and-multiply"] *)
    exp := M - 1;     (* inverse means "power M-1" *)
    WHILE exp > 0 DO
      IF (exp MOD 2) = 1 THEN
        MulPolynom(res, tmp, res);
      END;
      MulPolynom(tmp, tmp, tmp);
      exp := exp DIV 2;
    END;
  END InvertPolynom;

  PROCEDURE EvalPolynom (p: Polynom; VAR res: CCMElement);
    (* evaluate p; a precomputed list of all the powers of the argument can
      be found in the global variable PreEvalArg *)
    VAR
      i : Types.Int8;
      pow, prod : CCMElement;
  BEGIN
    res := NullCCM;
    IF p = NIL THEN
      RETURN;
    END;
    WHILE p # NIL DO
      prod := PreEvalArg[p.exp[0]].arg[0];
      i := 1;
      REPEAT
        pow := PreEvalArg[p.exp[i]].arg[i];
        MulCCM(prod, pow, prod);
        INC(i);
      UNTIL i >= MaxVar;
      MulCCM(prod, p.koeff, prod);
      AddCCM(res, prod, res);
      p := p.next;
    END;
  END EvalPolynom;

  PROCEDURE CreateExp (VAR exp: Exponent);
    (* creates a random vector of exponents *)
    VAR
      i : Types.Int8;
  BEGIN
    i := 0;
    WHILE i<MaxVar DO
      exp[i] := SHORT(SHORT(Random.Val(0, M-1)));
      INC(i);
    END;
  END CreateExp;

  PROCEDURE CreateExpList (VAR explist : ListExp);
    (* create a list of MaxNrExp different exponents *)
    VAR
      i : Types.Int8;
  BEGIN
    i := 0;
    WHILE i < MaxNrExp DO
      CreateExp(explist[i]);
      INC(i);
    END;
  END CreateExpList;

  PROCEDURE CreatePolynom (VAR p: Polynom; terms: Types.Int8; mode: Types.Int8;
                   UseList: BOOLEAN; explist: ListExp);
    (* creates a random polynomial depending on mode (can be reg,
      sing or random);
      if terms = 0 then the zero polynomial is returnded; if UseList
      is TRUE the exponents of the new polynomial will not be
      created entirely randomly but will be chosen form a list of
      precomputed exponents *)
    VAR
      regkoeffs, i : Types.Int8;
      expindex : Types.Int8;
      proot, tmp : Polynom;
      doubleexp : BOOLEAN;

  BEGIN
    IF terms = 0 THEN
      CopyPolynom(NullPolynom, p);
      RETURN;
    END;

    NEW(p);
    proot := p;               (* save root of p *)
    regkoeffs := 0;   (* # of regular coeff. in p *)
    i := 0;
    WHILE i<terms DO
      p.next := NIL;
      REPEAT
        tmp := proot;
        doubleexp := FALSE;
        IF UseList THEN
          (* use one of the precomputed exponents *)
          expindex := SHORT(SHORT(Random.Val(0, MaxNrExp-1)));
          p.exp := explist[expindex];
        ELSE
          (* choose a exponent randomly *)
          CreateExp(p.exp);
        END;
        (* run through polynomial and search for same exponent as the last
          created *)
        WHILE tmp.next # NIL DO
          IF CmpExp(tmp.exp, p.exp) = 0 THEN
            (* ok, found one; so we have to start again with this
              term *)
            doubleexp := TRUE;
          END;
          tmp := tmp.next;
        END;
      UNTIL ~doubleexp;
      INC(i);

      (* the last term must be created manually so that the result is
        regular/singular (depending on mode) *)
      IF i # terms THEN
        CreateCCM(p.koeff, random);
        IF RegulaerCCM(p.koeff) THEN
          INC(regkoeffs);
        END;
        NEW(p.next);
        p := p.next;
      END;
    END;

    CASE mode OF
      random:
        CreateCCM(p.koeff, random);
     | reg:
        IF (regkoeffs MOD 2) = 1 THEN
          CreateCCM(p.koeff, sing);
        ELSE
          CreateCCM(p.koeff, reg);
        END;
     | sing:
        IF (regkoeffs MOD 2) = 0 THEN
          CreateCCM(p.koeff, sing);
        ELSE
          CreateCCM(p.koeff, reg);
        END;
    ELSE
    END;

    p := proot;
    (* arrange the result at last *)
    ArrangePolynom(p);
  END CreatePolynom;


  (* ***** arithmetic functions for matrices ***** *)

  PROCEDURE DetMatrix(mat: MatPolynom; VAR res: Polynom);
    (* computes the determinant of a matrix *)
    VAR
      mul1, mul2, add : Polynom;
  BEGIN
    (* because of a rather unsatisfying performance, let's try the whole
      thing with 2x2 matrices ... *)
    MulPolynom(mat[0][0], mat[1][1], mul1);
    MulPolynom(mat[0][1], mat[1][0], mul2);
    AddPolynom(mul1, mul2, res);
  END DetMatrix;

  PROCEDURE ChangeCol (mat: MatPolynom; vek: VektorPolynom; col: Types.Int32;
                VAR res: MatPolynom);
    (* replaces the column #col in mat with vek *)
    VAR
      dx, dy : Types.Int32;
  BEGIN
    dx := 0;
    WHILE dx < Dim DO
      dy := 0;
      WHILE dy < Dim DO
        IF dx = col THEN
          CopyPolynom(vek[dy], res[dy][dx]);
        ELSE
          CopyPolynom(mat[dy][dx], res[dy][dx]);
        END;
        INC(dy);
      END;
      INC(dx);
    END;
  END ChangeCol;

  PROCEDURE ChooseInitialMatrix(VAR mat: MatPolynom);
    (* choose an initial matrix for the recursion *)
    VAR
      dx, dy : Types.Int8;
  BEGIN
    (* the starting matrix consists only of regular components *)
    dy := 0;
    WHILE dy < Dim DO
      dx := 0;
      WHILE dx < Dim DO
        CopyPolynom(NullPolynom, mat[dy][dx]);
        CreateCCM(mat[dy][dx].koeff, reg);
        INC(dx);
      END;
      INC(dy);
    END;
    CreateCCM(mat[1][1].koeff, sing);
  END ChooseInitialMatrix;

  PROCEDURE ChooseMatrix (VAR mat: MatPolynom; prev: MatPolynom;
                  vek: VektorPolynom);
    (* chooses a matrix for the next round of the recursion; the components of
      the matrix are polynomials *)
  BEGIN
  (* the pattern of the matrix mat is given by a proposition by Trautner
    [see Trautner's work on TCRYPT II, p. 3.5] *)
  (* former versions used 4x4 matrices; now it's only 2x2 *)
    IF Dim # 2 THEN
      RETURN;
    END;
    CopyPolynom(prev[0][1], mat[0][0]);
    CopyPolynom(prev[1][1], mat[1][0]);
    CopyPolynom(vek[0], mat[0][1]);
    CopyPolynom(vek[1], mat[1][1]);
  END ChooseMatrix;

  PROCEDURE MulMatrix (mat: MatCCM; col: VektorCCM; VAR res: VektorCCM);
    (* multiplies the matrix mat with the vector col *)
    VAR
      x, y : Types.Int8;
      addres, mulres : CCMElement;
  BEGIN
    x := 0;
    WHILE x < Dim DO
      y := 0;
      addres := NullCCM;
      WHILE y < Dim DO
        MulCCM(mat[x][y], col[y], mulres);
        AddCCM(addres, mulres, addres);
        INC(y);
      END;
      res[x] := addres;
      INC(x);
    END;
  END MulMatrix;

  PROCEDURE BuildMatrix (VAR mat: MatCCM; prev: MatCCM; vek: VektorCCM);
    (* build a new matrix for the evaluation recursion *)
  BEGIN
    mat[0][0] := prev[0][1];
    mat[1][0] := prev[1][1];
    mat[0][1] := vek[0];
    mat[1][1] := vek[1];
  END BuildMatrix;


  (* ***** basis functions of the TCRYPT algorithm ***** *)

  PROCEDURE CreateMaps (VAR phi: Phi; VAR psi: Psi;
                 VAR eta: Eta);
    (* create random but suiting maps phi, psi and eta for a pair of
      public and private keys *)
  VAR
    r, d, idx : Types.Int8;
    regindex, singindex : Types.Int8;
    dx, dy : Types.Int8;
    A : ChainPolynom;
    E : ARRAY Rounds OF MatPolynom;
    num : ChainPolynom;
    tmpKorr : CCMElement;
    korrNum : ChainCCM;
    denom : ListPolynom;
    korrDenom : ListCCM;
    mat : MatPolynom;

  BEGIN
    (* choose a sequence of polynomial vectors A(n), n=1,..,Rounds *)
    (* the vectors have to suffice a specific pattern so that the
      matrices during the recursion will be regular *)
    r := 0;
    WHILE r < (Rounds-1) DO
      CreatePolynom(A[r][0], 2, reg, NOLIST, GlobalExpList);
      IF ODD(r) THEN
        CreatePolynom(A[r][1], 2, sing, NOLIST, GlobalExpList);
      ELSE
        CreatePolynom(A[r][1], 2, reg, NOLIST, GlobalExpList);
      END;
      INC(r);
    END;
    (* the last vector can be choosen randomly *)
    d := 0;
    WHILE d < Dim DO
      CreatePolynom(A[Rounds-1][d], 2, random, NOLIST, GlobalExpList);
      INC(d);
    END;

    (* choose a starting matrix for the recrusion *)
    ChooseInitialMatrix(E[0]);

    (* chosse the following matrices E(n) of the recursion *)
    r := 1;
    WHILE r < Rounds DO
      (* choose a matrix E(r) for the next round of the recursion *)
      ChooseMatrix(E[r], E[r-1], A[r-1]);
      INC(r);
    END;

    r := 0;
    (* with the knowledge of E(n) and A(n) the a(n) can be computed
      by using Cramer's rule *)
    (* the elements of the a(n) are multiplied with randomly chosen
      regular constants and the corresponding inverts are stored in
      the private part; this is used for purposes of informtaion hiding
      in the public part *)
    WHILE r < Rounds DO
      (* compute determinant of current matrix = denominator of fraction *)
      DetMatrix(E[r], denom[r]);
      CreateCCM(tmpKorr, reg);
      (* multiply it with a correction factor ... *)
      MulPolynomWithCCM(denom[r], tmpKorr, denom[r]);
      (* ... and store the invert *)
      PowerCCM(tmpKorr, M-1, korrDenom[r]);
      d := 0;
      WHILE d < Dim DO
        (* compute the numerators and apply same technique like above *)
        ChangeCol(E[r], A[r], d, mat);
        DetMatrix(mat, num[r][d]);
        CreateCCM(tmpKorr, reg);
        MulPolynomWithCCM(num[r][d], tmpKorr, num[r][d]);
        PowerCCM(tmpKorr, M-1, korrNum[r][d]);
        INC(d);
      END;
      INC(r);
    END;

    (* a(n), n=1,...,Rounds, := phi *)
    NEW(phi);
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        CopyPolynom(num[r][d], phi.num[r][d]);
        INC(d);
      END;
      CopyPolynom(denom[r], phi.denom[r]);
      INC(r);
    END;

    (* E(n), n=1,...,Rounds, und sigma := psi *)
    NEW(psi);
    dy := 0;
    WHILE dy < Dim DO
      dx := 0;
      WHILE dx < Dim DO
        psi.initialmatrix[dy][dx] := E[0][dy][dx].koeff;
        INC(dx);
      END;
      INC(dy);
    END;
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        psi.korrNum[r][d] := korrNum[r][d];
        INC(d);
      END;
      psi.korrDenom[r] := korrDenom[r];
      INC(r);
    END;

    (* A(Rounds) := eta *)
    NEW(eta);
    r := 0;
    idx := Rounds - LastRounds;
    WHILE idx < Rounds DO
      d := 0;
      WHILE d < Dim DO
        CopyPolynom(A[idx][d], eta.p[r][d]);
        INC(d);
      END;
      INC(r);
      INC(idx);
    END;
  END CreateMaps;

  PROCEDURE PreComputeArgs(arg: TCryptInput);
    (* used for preevaluation of a polynomial argument *)
    VAR
      k, i, kk, ii : Types.Int32;
      tmp : CCMElement;
  BEGIN
    i := 0;
    WHILE i < MaxVar DO
      PreEvalArg[1].arg[i] := arg.arg[i];
      INC(i);
    END;
    i := 0;
    WHILE i < MaxVar DO
      k := 2;
      tmp := arg.arg[i];
      WHILE k < M DO
        MulCCM(tmp, tmp, tmp);
        PreEvalArg[k].arg[i] := tmp;
        INC(k,k);
      END;
      k := 3;
      WHILE k < M DO
        kk := k;
        ii := 1;
        tmp := EinsCCM;
        WHILE kk > 0 DO
          IF (kk MOD 2) = 1 THEN
            MulCCM(tmp, PreEvalArg[ii].arg[i], tmp);
          END;
          INC(ii,ii);
          kk := kk DIV 2;
        END;
        PreEvalArg[k].arg[i] := tmp;
        INC(k);
      END;
      INC(i);
    END;
  END PreComputeArgs;

  PROCEDURE EvaluatePhi (arg: TCryptInput; data: Phi) : TCryptTmp;
    (* evaluate the public function phi (represented by data) with
      argument arg *)
    VAR
      res : TCryptTmp;
      r, d : Types.Int8;
  BEGIN
    NEW(res);
    PreComputeArgs(arg);
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        EvalPolynom(data.num[r][d], res.numerator[r][d]);
        INC(d);
      END;
      EvalPolynom(data.denom[r], res.denominator[r]);
      INC(r);
    END;
    RETURN res;
  END EvaluatePhi;

  PROCEDURE EvaluatePsi (arg: TCryptTmp; data: Psi) : TCryptRes;
    (* evalute the private function psi *)
    VAR
      res : TCryptRes;
      mat, prev : MatCCM;
      num, denom, inv : CCMElement;
      vek : VektorCCM;
      A : ChainCCM;
      r, d : Types.Int8;
  BEGIN
    (* first correct the input with the correlating inverts *)
    MulCCM(arg.denominator[0], data.korrDenom[0], denom);
    PowerCCM(denom, M-1, inv);
    MulCCM(arg.numerator[0][0], data.korrNum[0][0], num);
    MulCCM(num, inv, vek[0]);
    MulCCM(arg.numerator[0][1], data.korrNum[0][1], num);
    MulCCM(num, inv, vek[1]);
    MulMatrix(data.initialmatrix, vek, A[0]);
    prev := data.initialmatrix;
    r := 1;
    WHILE r < Rounds DO
      (* the matrix for the current round of the recursion must be computed
        each round *)
      BuildMatrix(mat, prev, A[r-1]);
      prev := mat;
      MulCCM(arg.denominator[r], data.korrDenom[r], denom);
      PowerCCM(denom, M-1, inv);
      MulCCM(arg.numerator[r][0], data.korrNum[r][0], num);
      MulCCM(num, inv, vek[0]);
      MulCCM(arg.numerator[r][1], data.korrNum[r][1], num);
      MulCCM(num, inv, vek[1]);
      MulMatrix(mat, vek, A[r]);
      INC(r);
    END;
    NEW(res);
    r := 0;
    WHILE r < LastRounds DO
      d := 0;
      WHILE d < Dim DO
        res.arg[r][d] := A[Rounds-LastRounds+r][d];
        INC(d);
      END;
      INC(r);
    END;
    RETURN res;
  END EvaluatePsi;

  PROCEDURE EvaluateEta (arg: TCryptInput; data: Eta) : TCryptRes;
    (* evaluate the public function eta (composition of phi and psi) *)
    VAR
      l, d : Types.Int8;
      res : TCryptRes;
  BEGIN
    NEW(res);
    PreComputeArgs(arg);
    l := 0;
    WHILE l < LastRounds DO
      d := 0;
      WHILE d < Dim DO
        EvalPolynom(data.p[l][d], res.arg[l][d]);
        INC(d);
      END;
      INC(l);
    END;
    RETURN res;
  END EvaluateEta;

  PROCEDURE Eof (s: Streams.Stream) : BOOLEAN;
    (* returns TRUE if no bytes are left to read from stream s *)
    VAR
      b : SYS.BYTE;
  BEGIN
    RETURN ~Streams.ReadByte(s, b) OR ~Streams.Back(s);
  END Eof;

  PROCEDURE Encrypt (msg: Streams.Stream; key: Ciphers.Cipher;
               length: Types.Int32; s: Streams.Stream) : BOOLEAN;
    (* interface procedure for Ciphers.Encrypt *)
    VAR
      i, j : Types.Int8;
      ccmarg : TCryptInput;
      ccmres : TCryptTmp;
      wholeStream : BOOLEAN;
  BEGIN
    (* check if the whole stream msg shall be encrypted or only a certain
      amount of bytes *)
    IF length <= 0 THEN
      wholeStream := TRUE;
    ELSE
      wholeStream := FALSE
    END;
    NEW(ccmarg);
    WHILE ~Eof(msg) & (wholeStream OR (length > 0)) DO
      i := 0;
      WHILE i < MaxVar DO
        IF ~NetIO.ReadSet(msg, ccmarg.arg[i]) THEN
          Error(msg, readSetFailed);
          RETURN FALSE;
        END;
        IF ~RegulaerCCM(ccmarg.arg[i]) THEN
          Error(msg, notRegular);
          RETURN FALSE;
        END;
        INC(i);
      END;
      IF key IS PublicCipher THEN
        ccmres := EvaluatePhi(ccmarg, key(PublicCipher).phi);
      ELSE
        ccmres := EvaluatePhi(ccmarg, key(PrivateCipher).phi);
      END;
      i := 0;
      WHILE i < Rounds DO
        j := 0;
        WHILE j < Dim DO
          IF ~NetIO.WriteSet(s, ccmres.numerator[i][j]) THEN
            Error(s, writeSetFailed);
            RETURN FALSE;
          END;
          INC(j);
        END;
        IF ~NetIO.WriteSet(s, ccmres.denominator[i]) THEN
          Error(s, writeSetFailed);
          RETURN FALSE;
        END;
        INC(i);
      END;
      DEC(length, MaxVar*(M DIV 8));
    END;
    RETURN TRUE;
  END Encrypt;

  PROCEDURE Decrypt (msg: Streams.Stream; key: Ciphers.Cipher;
               length: Types.Int32; s: Streams.Stream) : BOOLEAN;
    (* interface procedure for Ciphers.Decrypt *)
    VAR
      i, j : Types.Int8;
      inNum, inDenom, out : ARRAY (M DIV 8) OF SYS.BYTE;
      ccmarg : TCryptTmp;
      ccmres : TCryptRes;
      wholeStream : BOOLEAN;
  BEGIN
    IF length < 0 THEN
      wholeStream := TRUE;
    ELSE
      wholeStream := FALSE;
    END;
    WITH key:PrivateCipher DO
      NEW(ccmarg);
      WHILE ~Eof(msg) & (wholeStream OR (length > 0)) DO
        i := 0;
        WHILE i < Rounds DO
          j := 0;
          WHILE j < Dim DO
            IF ~NetIO.ReadSet(msg, ccmarg.numerator[i][j]) THEN
              Error(msg, readSetFailed);
              RETURN FALSE;
            END;
            INC(j);
          END;
          IF ~NetIO.ReadSet(msg, ccmarg.denominator[i]) THEN
            Error(msg, readSetFailed);
            RETURN FALSE;
          END;
          INC(i);
        END;
        ccmres := EvaluatePsi(ccmarg, key.psi);
        i := 0;
        WHILE i < LastRounds DO
          j := 0;
          WHILE j < Dim DO
            IF ~NetIO.WriteSet(s, ccmres.arg[i][j]) THEN
              Error(s, writeSetFailed);
              RETURN FALSE;
            END;
            INC(j);
          END;
          INC(i);
        END;
        DEC (length, Rounds*Dim*(M DIV 8));
      END;
    END;
    RETURN TRUE;
  END Decrypt;

  PROCEDURE ComposedEncrypt (msg: Streams.Stream; key: Ciphers.Cipher;
                    length: Types.Int32; s: Streams.Stream) : BOOLEAN;
    (* interface procedure for AsymmetricCiphers.ComposedEncrypt *)
    VAR
      i, j : Types.Int8;
      ccmarg : TCryptInput;
      ccmres : TCryptRes;
      in, out : ARRAY (M DIV 8) OF SYS.BYTE;
      wholeStream : BOOLEAN;
  BEGIN
    IF length < 0 THEN
      wholeStream := TRUE;
    ELSE
      wholeStream := FALSE;
    END;
    NEW(ccmarg);
    WHILE ~Eof(msg) & (wholeStream OR (length > 0)) DO
      i := 0;
      WHILE i < MaxVar DO
        IF ~NetIO.ReadSet(msg, ccmarg.arg[i]) THEN
          Error(msg, readSetFailed);
          RETURN FALSE;
        END;
        INC(i);
      END;
      IF key IS PublicCipher THEN
        ccmres := EvaluateEta(ccmarg, key(PublicCipher).eta);
      ELSE
        ccmres := EvaluateEta(ccmarg, key(PrivateCipher).eta);
      END;
      i := 0;
      WHILE i < LastRounds DO
        j := 0;
        WHILE j < Dim DO
          IF ~NetIO.WriteSet(s, ccmres.arg[i][j]) THEN
            Error(s, writeSetFailed);
            RETURN FALSE;
          END;
          INC(j);
        END;
        INC(i);
      END;
      DEC (length, MaxVar*(M DIV 8));
    END;
    RETURN TRUE;
  END ComposedEncrypt;

  PROCEDURE RandomStream (s: Streams.Stream);
    (* writes some random elements of CC(M) to the stream s which can then
      be used as an input for Trautner's TCRYPT *)
    VAR
      ccm : CCMElement;
      bytes : ARRAY M DIV 8 OF SYS.BYTE;
      i : Types.Int32;
  BEGIN
    i := 0;
    WHILE i < MaxVar DO
      CreateCCM(ccm, reg);
      IF ~NetIO.WriteSet(s, ccm) THEN
        Error(s, writeSetFailed);
      END;
      INC(i);
    END;
  END RandomStream;

  PROCEDURE PublicCipherCreate (VAR obj: PersistentObjects.Object);
    (* constructor for a public cipher *)
    VAR
      pub : PublicCipher;
      if : AsymmetricCiphers.Interface;
      caps : AsymmetricCiphers.CapabilitySet;
  BEGIN
    NEW(pub); NEW(pub.phi); NEW(pub.eta);
    PersistentObjects.Init(pub, pubType);
    NEW(if); if.encrypt := Encrypt; if.decrypt := NIL;
    if.compencrypt := ComposedEncrypt; if.split := NIL;
    if.randomStream := RandomStream;
    caps := {AsymmetricCiphers.composed};
    AsymmetricCiphers.Init(pub, if, caps, M*MaxVar, M*Dim);
    obj := pub;
  END PublicCipherCreate;

  PROCEDURE Split (VAR public: AsymmetricCiphers.Cipher;
              key: AsymmetricCiphers.Cipher);
    (* interface procedure for asymmetric interface *)
    VAR
      pub: PublicCipher;
      obj: PersistentObjects.Object;
  BEGIN
    WITH key:PrivateCipher DO
      PublicCipherCreate(obj); pub := obj(PublicCipher);
      pub.phi := key.phi;
      pub.eta := key.eta;
      public := pub;
    END;
  END Split;

  PROCEDURE CipherCreate (VAR obj: PersistentObjects.Object);
    (* constructor for a private cipher *)
    VAR
      key : PrivateCipher;
      if : AsymmetricCiphers.Interface;
      caps : AsymmetricCiphers.CapabilitySet;
  BEGIN
    NEW(key); NEW(key.phi); NEW(key.psi); NEW(key.eta);
    PersistentObjects.Init(key, privType);
    NEW(if); if.encrypt := Encrypt; if.decrypt := Decrypt;
    if.compencrypt := ComposedEncrypt; if.split := Split;
    if.randomStream := RandomStream;
    caps := {AsymmetricCiphers.composed, AsymmetricCiphers.isPrivateKey};
    AsymmetricCiphers.Init(key, if, caps, M*MaxVar, M*Dim);
    obj := key;
  END CipherCreate;

  PROCEDURE Create* (VAR key: Ciphers.Cipher);
    (* creates a cipher for the use with Trautner's TCRYPT algorithm *)
    VAR
      tmpKey : PrivateCipher;
      obj : PersistentObjects.Object;
      phi : Phi;
      psi : Psi;
      eta : Eta;
  BEGIN
    CipherCreate(obj); tmpKey := obj(PrivateCipher);
    CreateMaps(tmpKey.phi, tmpKey.psi, tmpKey.eta);
    key := tmpKey;
  END Create;

  PROCEDURE WritePolynom (s: Streams.Stream; p: Polynom) : BOOLEAN;
    (* writes the polynomial p onto the stream s *)
    CONST
      index = M DIV 8;
    VAR
      nrOfTerms, i : Types.Int32;
      bytes : ARRAY index OF SYS.BYTE;
  BEGIN
    nrOfTerms := LengthPolynom(p);
    IF ~NetIO.WriteInteger(s, nrOfTerms) THEN
      RETURN FALSE;
    END;
    WHILE nrOfTerms > 0 DO
      IF ~NetIO.WriteSet(s, p.koeff) THEN
        RETURN FALSE;
      END;
      i :=  0;
      WHILE i < MaxVar DO
        IF ~NetIO.WriteShortInt(s, p.exp[i]) THEN
          RETURN FALSE;
        END;
        INC(i);
      END;
      p := p.next;
      DEC(nrOfTerms);
    END;
    RETURN TRUE;
  END WritePolynom;

  PROCEDURE ReadPolynom (s: Streams.Stream; VAR p: Polynom) : BOOLEAN;
    (* reads a polynomial from stream s *)
    CONST
      index = M DIV 8;
    VAR
      nrOfTerms, i : Types.Int32;
      pol : Polynom;
      bytes : ARRAY index OF SYS.BYTE;
  BEGIN
    IF ~NetIO.ReadInteger(s, nrOfTerms) THEN
      RETURN FALSE;
    END;
    NEW(p);
    pol := p;
    WHILE nrOfTerms > 0 DO
      IF ~NetIO.ReadSet(s, pol.koeff) THEN
        RETURN FALSE;
      END;
      i :=  0;
      WHILE i < MaxVar DO
        IF ~NetIO.ReadShortInt(s, pol.exp[i]) THEN
          RETURN FALSE;
        END;
        INC(i);
      END;
      DEC(nrOfTerms);
      IF nrOfTerms > 0 THEN
        NEW(pol.next);
        pol := pol.next;
      END
    END;
    RETURN TRUE;
  END ReadPolynom;

  PROCEDURE PhiWrite (s: Streams.Stream; data: Phi) : BOOLEAN;
    (* writes the data structure for the public function phi onto a stream *)
    VAR
      r, d, k : Types.Int32;
  BEGIN
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~WritePolynom(s, data.num[r][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      IF ~WritePolynom(s, data.denom[r]) THEN
        RETURN FALSE;
      END;
      INC(r);
    END;
    RETURN TRUE;
  END PhiWrite;

  PROCEDURE PhiRead (s: Streams.Stream; VAR data: Phi) : BOOLEAN;
    (* reads the data structure for the public function phi from a stream *)
    VAR
      r, d, k : Types.Int32;
  BEGIN
    NEW(data);
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~ReadPolynom(s, data.num[r][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      IF ~ReadPolynom(s, data.denom[r]) THEN
        RETURN FALSE;
      END;
      INC(r);
    END;
    RETURN TRUE;
  END PhiRead;

  PROCEDURE PsiWrite (s: Streams.Stream; data: Psi) : BOOLEAN;
    (* writes the data structure for the private function psi onto a stream *)
    CONST
      index = M DIV 8;
    VAR
      dx, dy, r, d : Types.Int32;
      bytes : ARRAY index OF SYS.BYTE;
  BEGIN
    dy := 0;
    WHILE dy < Dim DO
      dx := 0;
      WHILE dx < Dim DO
        IF ~NetIO.WriteSet(s, data.initialmatrix[dy][dx]) THEN
          RETURN FALSE;
        END;
        INC(dx);
      END;
      INC(dy);
    END;
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~NetIO.WriteSet(s, data.korrNum[r][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      IF ~NetIO.WriteSet(s, data.korrDenom[r]) THEN
        RETURN FALSE;
      END;
      INC(r);
    END;
    RETURN TRUE;
  END PsiWrite;

  PROCEDURE PsiRead (s: Streams.Stream; VAR data: Psi) : BOOLEAN;
    (* reads the data structure for the private function psi from a stream *)
    CONST
      index = M DIV 8;
    VAR
      dy, dx, r, d : Types.Int32;
      bytes : ARRAY index OF SYS.BYTE;
  BEGIN
    dy := 0;
    WHILE dy < Dim DO
      dx := 0;
      WHILE dx < Dim DO
        IF ~NetIO.ReadSet(s, data.initialmatrix[dy][dx]) THEN
          RETURN FALSE;
        END;
        INC(dx);
      END;
      INC(dy);
    END;
    r := 0;
    WHILE r < Rounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~NetIO.ReadSet(s, data.korrNum[r][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      IF ~NetIO.ReadSet(s, data.korrDenom[r]) THEN
        RETURN FALSE;
      END;
      INC(r);
    END;
    RETURN TRUE;
  END PsiRead;

  PROCEDURE EtaWrite (s: Streams.Stream; data: Eta) : BOOLEAN;
    (* writes the data structure for the public function eta onto a stream *)
    VAR
      l, d : Types.Int32;
  BEGIN
    l := 0;
    WHILE l < LastRounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~WritePolynom(s, data.p[l][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      INC(l);
    END;
    RETURN TRUE;
  END EtaWrite;

  PROCEDURE EtaRead (s: Streams.Stream; VAR data: Eta) : BOOLEAN;
    (* reads the data structure for the public function eta from a stream *)
    VAR
      l, d : Types.Int32;
  BEGIN
    NEW(data);
    l := 0;
    WHILE l < LastRounds DO
      d := 0;
      WHILE d < Dim DO
        IF ~ReadPolynom(s, data.p[l][d]) THEN
          RETURN FALSE;
        END;
        INC(d);
      END;
      INC(l);
    END;
    RETURN TRUE;
  END EtaRead;

  PROCEDURE PubWrite (s: Streams.Stream;
                obj: PersistentObjects.Object) : BOOLEAN;
    (* interface procedure for PersistentObjects *)
  BEGIN
    WITH obj:PublicCipher DO
      RETURN PhiWrite(s, obj.phi) & EtaWrite(s, obj.eta);
    END;
  END PubWrite;

  PROCEDURE CipherWrite (s: Streams.Stream;
                  obj: PersistentObjects.Object) : BOOLEAN;
    (* interface procedure for PersistentObjects *)
  BEGIN
    WITH obj:PrivateCipher DO
      RETURN PhiWrite(s, obj.phi) &
           PsiWrite(s, obj.psi) &
           EtaWrite(s, obj.eta);
    END;
  END CipherWrite;

  PROCEDURE PubRead (s: Streams.Stream;
               obj: PersistentObjects.Object) : BOOLEAN;
    (* interface procedure for PersistentObjects *)
  BEGIN
    WITH obj:PublicCipher DO
      IF ~PhiRead(s, obj.phi) OR ~EtaRead(s, obj.eta) THEN
        RETURN FALSE;
      END;
    END;
    RETURN TRUE;
  END PubRead;

  PROCEDURE CipherRead (s: Streams.Stream;
                 obj: PersistentObjects.Object) : BOOLEAN;
    (* interface procedure for PersistentObjects *)
  BEGIN
    WITH obj:PrivateCipher DO
      IF ~PhiRead(s, obj.phi) OR
        ~PsiRead(s, obj.psi) OR
        ~EtaRead(s, obj.eta) THEN
          RETURN FALSE;
      END;
    END;
    RETURN TRUE;
  END CipherRead;

BEGIN
  (* init of the zero and unit of CC(M) *)
  NullCCM := {};
  EinsCCM := {0};

  (* init of the zero exponent *)
  k := 0;
  WHILE k<MaxVar DO
    NullExp[k] := 0;
    INC(k);
  END;

  (* init of an pseudo list of exponents *)
  k := 0;
  WHILE k<MaxNrExp DO
    NullExpList[k] := NullExp;
    INC(k);
  END;

  k := 0;
  WHILE k < MaxNrExp DO
    CreateExp(GlobalExpList[k]);
    INC(k);
  END;

  (* init of the zero polynomial *)
  NEW(NullPolynom);
  NullPolynom.koeff := NullCCM;        (* Koeffizient = Null *)
  NullPolynom.exp := NullExp;          (* alle Exponenten = Null *)
  NullPolynom.next := NIL;             (* nur ein Term *)

  k := 0;
  WHILE k < M DO
    NEW(PreEvalArg[k]);
    IF k < MaxVar THEN
      PreEvalArg[0].arg[k] := EinsCCM;
    END;
    INC(k);
  END;

  (* no interface needed for cipherType since it serves only as a
    common type for public and private ciphers *)
  PersistentObjects.RegisterType(cipherType, "TCrypt.Cipher",
      "AsymmetricCiphers.Cipher", NIL);

  NEW(pubIf);
  pubIf.create := PublicCipherCreate;
  pubIf.write := PubWrite;
  pubIf.read := PubRead;
  pubIf.createAndRead := NIL;
  PersistentObjects.RegisterType(pubType, "TCrypt.PublicCipher",
      "TCrypt.Cipher", pubIf);

  NEW(privIf);
  privIf.create := CipherCreate;
  privIf.write := CipherWrite;
  privIf.read := CipherRead;
  privIf.createAndRead := NIL;
  PersistentObjects.RegisterType(privType, "TCrypt.PrivateCipher",
      "TCrypt.Cipher", privIf);

  InitErrorHandling;
END ulmTCrypt.
