MODULE Texts; (*JG 21.11.90 / NW 11.7.90 / 24.12.95 / 22.11.10 / 18.11.2014 / 10.1.2019 / AE 05.02.2022*)
IMPORT Files, IntToStr := Int, Platform, SYSTEM;

CONST
  (* Scanner class values *)
  Inval*  = 0; (* Invalid symbol *)
  Name*   = 1; (* Name (identifier) s (length len) *)
  String* = 2; (* Literal string s (length len) *)
  Int*    = 3; (* Integer i (decimal or hexadecimal) *)
  Real*   = 4; (* Real number x *)
  Char*   = 6; (* Special character c *)

  replace* = 0; insert* = 1; delete* = 2; unmark* = 3; (* Op-codes *)

  CR = 0DX; LF = 0AX;
  isWindows = Platform.Windows;

TYPE
  Piece = POINTER TO PieceDesc;
  PieceDesc = RECORD
    f: Files.File;
    off, len: INTEGER;
    col: INTEGER; (* Color !FIXME CURRENTLY NOT USED *)
    prev, next: Piece
  END;

  Text* = POINTER TO TextDesc;
  TextDesc* = RECORD
    len*: INTEGER;
    changed*: BOOLEAN;
    trailer: Piece;
    pce: Piece;  (* Cache *)
    org: INTEGER (* Cache *)
  END;

  Reader* = RECORD
    eot*: BOOLEAN;
    col*: INTEGER;
    ref: Piece;
    org: INTEGER;
    off: INTEGER;
    rider: Files.Rider
  END;

  Scanner* = RECORD(Reader)
    nextCh*: CHAR;
    line*, class*: INTEGER;
    i*: INTEGER;
    x*: REAL;
    c*: CHAR;
    len*: INTEGER;
    s*: ARRAY 1900 OF CHAR
  END;

  Buffer* = POINTER TO BufDesc;
  BufDesc* = RECORD
    len*: INTEGER;
    header, last: Piece
  END;

  Writer* = RECORD
    buf*: Buffer;
    col: INTEGER; (* Color !FIXME CURRENTLY NOT USED *)
    rider: Files.Rider
  END;

VAR TrailerFile: Files.File;

(* -------------------- Filing ------------------------*)

PROCEDURE Trailer(): Piece;
VAR Q: Piece;
BEGIN NEW(Q); Q.f := TrailerFile; Q.off := -1; Q.len := 1; Q.col := -1
RETURN Q END Trailer;

PROCEDURE Load*(VAR R: Files.Rider; T: Text);
VAR Q, q: Piece;
  f: Files.File;
BEGIN f := Files.Base(R); Q := Trailer();
  NEW(q); q.col := 0;
  q.len := Files.Length(f);
  q.f := f; q.off := 0;
  Q.next := q; q.prev := Q;
  q.next := Q; Q.prev := q;
  T.trailer := Q; T.len := q.len
END Load;

PROCEDURE Open*(T: Text; name: ARRAY OF CHAR);
VAR f: Files.File; R: Files.Rider; Q, q: Piece;
  len: INTEGER;
BEGIN f := Files.Old(name);
  IF f # NIL THEN
    Files.Set(R, f, 0);
    Load(R, T);
    len := Files.Length(f); Q := Trailer();
    NEW(q); q.col := 0; q.f := f; q.off := 0; q.len := len;
    Q.next := q; q.prev := Q; q.next := Q; Q.prev := q; T.trailer := Q; T.len := len
  ELSE (* Create new text *)
    Q := Trailer(); Q.next := Q; Q.prev := Q; T.trailer := Q; T.len := 0
  END;
  T.changed := FALSE; T.org := -1; T.pce := T.trailer (* Init cache *)
END Open;

PROCEDURE Store*(VAR W: Files.Rider; T: Text);
VAR p: Piece;
  R: Files.Rider;
  rlen: INTEGER;
  ch: CHAR;
BEGIN p := T.trailer.next;
  WHILE p # T.trailer DO
    rlen := p.len; Files.Set(R, p.f, p.off);
    WHILE rlen > 0 DO Files.ReadChar(R, ch); Files.WriteChar(W, ch); DEC(rlen) END;
    p := p.next
  END;
  T.changed := FALSE
END Store;

PROCEDURE Close*(T: Text; name: ARRAY OF CHAR);
VAR f: Files.File; w: Files.Rider;
BEGIN f := Files.New(name); Files.Set(w, f, 0);
  Store(w, T); Files.Register(f)
END Close;

(* -------------------- Editing ----------------------- *)

PROCEDURE OpenBuf*(B: Buffer);
BEGIN NEW(B.header); (* Null piece *)
  B.last := B.header; B.len := 0
  ;B.header.col := -1
END OpenBuf;

PROCEDURE FindPiece(T: Text; pos: INTEGER; VAR org: INTEGER; VAR pce: Piece);
VAR p: Piece; porg: INTEGER;
BEGIN p := T.pce; porg := T.org;
  IF pos >= porg THEN
    WHILE pos >= porg + p.len DO INC(porg, p.len); p := p.next END
  ELSE p := p.prev; DEC(porg, p.len);
    WHILE pos < porg DO p := p.prev; DEC(porg, p.len) END
  END;
  T.pce := p; T.org := porg; (* Update cache *)
  pce := p; org := porg
END FindPiece;

PROCEDURE SplitPiece(p: Piece; off: INTEGER; VAR pr: Piece);
VAR q: Piece;
BEGIN
  IF off > 0 THEN NEW(q);
    q.col := p.col;
    q.len := p.len - off;
    q.f := p.f; q.off := p.off + off;
    p.len := off;
    q.next := p.next; p.next := q;
    q.prev := p; q.next.prev := q;
    pr := q
  ELSE pr := p
  END
END SplitPiece;

PROCEDURE Save*(T: Text; beg, end: INTEGER; B: Buffer);
VAR p, q, qb, qe: Piece; org: INTEGER;
BEGIN
  IF end > T.len THEN end := T.len END;
  FindPiece(T, beg, org, p);
  NEW(qb); qb^ := p^;
  qb.len := qb.len - (beg - org);
  qb.off := qb.off + (beg - org);
  qe := qb;
  WHILE end > org + p.len DO 
    org := org + p.len; p := p.next;
    NEW(q); q^ := p^; qe.next := q; q.prev := qe; qe := q
  END;
  qe.next := NIL; qe.len := qe.len - (org + p.len - end);
  B.last.next := qb; qb.prev := B.last; B.last := qe;
  B.len := B.len + (end - beg)
END Save;

PROCEDURE Copy*(SB, DB: Buffer);
VAR Q, q, p: Piece;
BEGIN p := SB.header; Q := DB.last;
  WHILE p # SB.last DO p := p.next;
    NEW(q); q^ := p^; Q.next := q; q.prev := Q; Q := q
  END;
  DB.last := Q; DB.len := DB.len + SB.len
END Copy;

PROCEDURE Insert*(T: Text; pos: INTEGER; B: Buffer);
VAR pl, pr, p, qb, qe: Piece; org, end: INTEGER;
BEGIN
  FindPiece(T, pos, org, p); SplitPiece(p, pos - org, pr);
  IF T.org >= org THEN T.org := org - p.prev.len; T.pce := p.prev END;
  pl := pr.prev; qb := B.header.next;
  IF (qb # NIL) & (qb.f = pl.f) & (qb.off = pl.off + pl.len) &
     (qb.col = pl.col)
  THEN INC(pl.len, qb.len); qb := qb.next
  END;
  IF qb # NIL THEN qe := B.last;
    qb.prev := pl; pl.next := qb; qe.next := pr; pr.prev := qe
  END;
  INC(T.len, B.len); end := pos + B.len;
  B.last := B.header; B.last.next := NIL; B.len := 0;
  T.changed := TRUE
END Insert;

PROCEDURE Append*(T: Text; B: Buffer);
BEGIN Insert(T, T.len, B)
END Append;

PROCEDURE Delete*(T: Text; beg, end: INTEGER; B: Buffer);
VAR pb, pe, pbr, per: Piece; orgb, orge: INTEGER;
BEGIN
  IF end > T.len THEN end := T.len END;
  FindPiece(T, beg, orgb, pb); SplitPiece(pb, beg - orgb, pbr);
  FindPiece(T, end, orge, pe);
  SplitPiece(pe, end - orge, per);
  IF T.org >= orgb THEN (* Adjust cache *)
    T.org := orgb - pb.prev.len; T.pce := pb.prev
  END;
  B.header.next := pbr; B.last := per.prev;
  B.last.next := NIL; B.len := end - beg;
  per.prev := pbr.prev; pbr.prev.next := per;
  T.len := T.len - B.len;
  T.changed := TRUE
END Delete;

PROCEDURE ChangeColor*(T: Text; beg, end: INTEGER; col: INTEGER); (*!FIXME does nothing*)
VAR pb, pe, p: Piece; org: INTEGER;
BEGIN
  IF end > T.len THEN end := T.len END;
  FindPiece(T, beg, org, p); SplitPiece(p, beg - org, pb);
  FindPiece(T, end, org, p); SplitPiece(p, end - org, pe);
  p := pb; REPEAT p.col := col; p := p.next UNTIL p = pe;
  T.changed := TRUE
END ChangeColor;

PROCEDURE GetColor*(T: Text; pos: INTEGER; VAR col: INTEGER);
VAR p: Piece; org: INTEGER;
BEGIN FindPiece(T, pos, org, p); col := p.col
END GetColor;

(* ------------------ Access: Readers ------------------------- *)

PROCEDURE OpenReader*(VAR R: Reader; T: Text; pos: INTEGER);
VAR p: Piece; org: INTEGER;
BEGIN FindPiece(T, pos, org, p);
  R.ref := p; R.org := org; R.off := pos - org;
  Files.Set(R.rider, p.f, p.off + R.off); R.eot := FALSE
END OpenReader;

PROCEDURE Read*(VAR R: Reader; VAR ch: CHAR);
BEGIN Files.ReadChar(R.rider, ch);
  R.col := R.ref.col;
  INC(R.off);
  IF R.off = R.ref.len THEN
    IF R.ref.f = TrailerFile THEN R.eot := TRUE END;
    R.ref := R.ref.next; R.org := R.org + R.off; R.off := 0;
    Files.Set(R.rider, R.ref.f, R.ref.off)
  END
END Read;

PROCEDURE Pos*(VAR R: Reader): INTEGER;
RETURN R.org + R.off END Pos;  

(* ------------------ Access: Scanners (NW) ------------------------- *)

PROCEDURE OpenScanner*(VAR S: Scanner; T: Text; pos: INTEGER);
BEGIN OpenReader(S, T, pos); S.line := 0; S.nextCh := ' '
END OpenScanner;

(* Floating point formats:
   x = 1.m * 2^(e-127)   bit 0: sign, bits 1- 8: e, bits  9-31: m
   x = 1.m * 2^(e-1023)  bit 0: sign, bits 1-11: e, bits 12-63: m *)

PROCEDURE Ten(n: INTEGER): REAL;
VAR t, p: REAL;
BEGIN t := 1.0; p := 10.0; (* Compute 10^n *)
  WHILE n > 0 DO
    IF ODD(n) THEN t := p * t END;
    p := p * p; n := n DIV 2
  END
RETURN t END Ten;

PROCEDURE Scan*(VAR S: Scanner);
CONST maxExp = 38; maxM = 16777216; (* 2^24 *)
VAR ch, quot: CHAR;
  neg, negE, hex: BOOLEAN;
  i, j, h, d, e, n, s: INTEGER;
  x: REAL;
BEGIN ch := S.nextCh; i := 0;
  WHILE (ch # 0X) & (ch <= ' ') DO
    IF ch = LF THEN INC(S.line) END;
    Read(S, ch)
  END;

  IF ('A' <= ch) & (ch <= 'Z') OR ('a' <= ch) & (ch <= 'z') THEN (* Name *)
    REPEAT S.s[i] := ch; INC(i); Read(S, ch)
    UNTIL ((ch < '0') & (ch # '.') OR
           ('9' < ch) & (ch < 'A') OR
           ('Z' < ch) & (ch < 'a') OR
           ('z' < ch)) OR (i = LEN(S.s) - 1);
    S.s[i] := 0X; S.len := i; S.class := Name
  ELSIF (ch = "'") OR (ch = '"') THEN (* String *)
    quot := ch; Read(S, ch);
    WHILE (ch # quot) & (ch >= ' ') & (i # LEN(S.s) - 1) DO
      S.s[i] := ch; INC(i); Read(S, ch)
    END;
    S.s[i] := 0X; S.len := i + 1(*!FIXME why +1?*); Read(S, ch); S.class := String
  ELSE hex := FALSE;
    IF ch = '-' THEN neg := TRUE; Read(S, ch) ELSE neg := FALSE END;
    IF ('0' <= ch) & (ch <= '9') THEN (* Number *)
      n := ORD(ch) - ORD('0'); h := n; Read(S, ch);
      WHILE ('0' <= ch) & (ch <= '9') OR ('A' <= ch) & (ch <= 'F') DO
        IF ch <= '9' THEN d := ORD(ch) - ORD('0')
        ELSE d := ORD(ch) + (10 - ORD('A')); hex := TRUE
        END;
        n := 10 * n + d; h := 10H * h + d; Read(S, ch)
      END;
      IF ch = 'H' THEN (* Hex integer *)
        Read(S, ch); S.i := h; S.class := Int (*neg?*)
      ELSIF ch = '.' THEN (* Real number *)
        Read(S, ch); x := 0.0; e := 0; j := 0;
        WHILE ('0' <= ch) & (ch <= '9') DO (* Fraction *)
          h := 10 * n + ORD(ch) - ORD('0');
          IF h < maxM THEN n := h; INC(j) END;
          Read(S, ch)
        END;
        IF ch = 'E' THEN (* Scale factor *)
          s := 0; Read(S, ch);
          IF ch = '-' THEN negE := TRUE; Read(S, ch)
          ELSE negE := FALSE;
            IF ch = '+' THEN Read(S, ch) END
          END;
          WHILE ('0' <= ch) & (ch <= '9') DO
            s := s * 10 + ORD(ch) - ORD('0'); Read(S, ch)
          END;
          IF negE THEN DEC(e, s) ELSE INC(e, s) END;
        END;
        x := FLT(n); DEC(e, j);
        IF e < 0 THEN
          IF e >= -maxExp THEN x := x / Ten(-e) ELSE x := 0.0 END
        ELSIF e > 0 THEN
          IF e <= maxExp THEN x := Ten(e) * x ELSE x := 0.0 END
        END;
        IF neg THEN S.x := -x ELSE S.x := x END;
        IF hex THEN S.class := 0 ELSE S.class := Real END
      ELSE (* Decimal integer *)
        IF neg THEN S.i := -n ELSE S.i := n END;
        IF hex THEN S.class := Inval ELSE S.class := Int END
      END
    ELSIF ch = 0X THEN
      S.eot := TRUE; S.class := Inval
    ELSE (* Special character *) S.class := Char;
      IF neg THEN S.c := '-' ELSE S.c := ch; Read(S, ch) END
    END
  END;
  S.nextCh := ch
END Scan;

(* --------------- Access: Writers (NW) ------------------ *)

PROCEDURE OpenWriter*(VAR W: Writer);
BEGIN NEW(W.buf); OpenBuf(W.buf); W.col := 0;
  Files.Set(W.rider, Files.New(''), 0)
END OpenWriter;

PROCEDURE SetColor*(VAR W: Writer; col: INTEGER);
BEGIN W.col := col
END SetColor;

PROCEDURE Write*(VAR W: Writer; ch: CHAR);
VAR p: Piece;
BEGIN
  IF W.buf.last.col # W.col THEN
    NEW(p); p.f := Files.Base(W.rider);
    p.off := Files.Pos(W.rider); p.len := 0;
    p.col := W.col;
    p.next := NIL; W.buf.last.next := p;
    p.prev := W.buf.last; W.buf.last := p
  END;
  Files.WriteChar(W.rider, ch);
  INC(W.buf.last.len); INC(W.buf.len)
END Write;

PROCEDURE WriteLn*(VAR W: Writer);
BEGIN IF isWindows THEN Write(W, CR) END; Write(W, LF)
END WriteLn;

PROCEDURE WriteString*(VAR W: Writer; s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE s[i] # 0X DO Write(W, s[i]); INC(i) END
END WriteString;

PROCEDURE WriteInt*(VAR W: Writer; x, n: INTEGER);
VAR i: INTEGER; x0: INTEGER;
  a: ARRAY 10 OF CHAR;
BEGIN
  IF ROR(x, 31) = 1 THEN WriteString(W, ' -2147483648')
  ELSE i := 0;
    IF x < 0 THEN DEC(n); x0 := -x ELSE x0 := x END;
    REPEAT a[i] := CHR(x0 MOD 10 + ORD('0')); x0 := x0 DIV 10; INC(i)
    UNTIL x0 = 0;
    WHILE n > i DO Write(W, ' '); DEC(n) END;
    IF x < 0 THEN Write(W, '-') END;
    REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
  END
END WriteInt;

PROCEDURE WriteHex*(VAR W: Writer; x: INTEGER);
VAR i: INTEGER; y: INTEGER;
  a: ARRAY 10 OF CHAR;
BEGIN i := 0; Write(W, ' ');
  REPEAT y := x MOD 10H;
    IF y < 10 THEN a[i] := CHR(y + ORD('0')) ELSE a[i] := CHR(y + (ORD('A') - 10)) END;
    x := x DIV 10H; INC(i)
  UNTIL i = 8;
  REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
END WriteHex;

PROCEDURE WriteReal*(VAR W: Writer; x: REAL; n: INTEGER);
VAR e, i, k, m: INTEGER;
  d: ARRAY 16 OF CHAR;
BEGIN e := ASR(SYSTEM.VAL(INTEGER, x), 23) MOD 100H; (* Binary exponent *)
  IF e = 0 THEN
    WriteString(W, '  0 ');
    WHILE n >= 3 DO Write(W, ' '); DEC(n) END
  ELSIF e = 255 THEN WriteString(W, ' NaN ')
  ELSE Write(W, ' ');
    WHILE n >= 15 DO DEC(n); Write(W, ' ') END;
    (* 2 < n < 9 digits to be written *)
    IF x < 0.0 THEN Write(W, '-'); x := -x ELSE Write(W, ' ') END;
    e := (e - 127) * 77 DIV 256 - 6;  (* Decimal exponent *)
    IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(-e) * x END;
    m := FLOOR(x + 0.5);
    IF m >= 10000000 THEN INC(e); m := m DIV 10 END;
    i := 0; k := 13 - n;
    REPEAT
       IF i = k THEN INC(m, 5) END;  (* Rounding *)
     d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i)
    UNTIL m = 0;
    DEC(i); Write(W, d[i]); Write(W, '.');
    IF i < n - 7 THEN n := 0 ELSE n := 14 - n END;
    WHILE i > n DO DEC(i); Write(W, d[i]) END;
    Write(W, 'E'); INC(e, 6);
     IF e < 0 THEN Write(W, '-'); e := -e ELSE Write(W, '+') END;
    Write(W, CHR(e DIV 10 + 30H)); Write(W, CHR(e MOD 10 + 30H))
  END
END WriteReal;

PROCEDURE WriteRealFix*(VAR W: Writer; x: REAL; n, k: INTEGER);
VAR i, m: INTEGER; neg: BOOLEAN;
  d: ARRAY 12 OF CHAR;
BEGIN
  IF x = 0.0 THEN WriteString(W, '  0')
  ELSE
    IF x < 0.0 THEN x := -x; neg := TRUE ELSE neg := FALSE END;
    IF k > 7 THEN k := 7 END;
    x := Ten(k) * x; m := FLOOR(x + 0.5);
    i := 0;
    REPEAT d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i) UNTIL m = 0;
    Write(W, ' ');
    WHILE n > i + 3 DO  Write(W, ' '); DEC(n) END;
    IF neg THEN Write(W, '-'); DEC(n) ELSE Write(W, ' ') END;
    WHILE i > k DO DEC(i); Write(W, d[i]) END;
    Write(W, '.');
    WHILE k > i DO DEC(k); Write(W, '0') END;
    WHILE i > 0 DO DEC(i); Write(W, d[i]) END
  END
END WriteRealFix;

BEGIN TrailerFile := Files.New('')
END Texts.
