MODULE Neiro;
(** This program generates quasi-realistic Russian text
    based on letter-pair statistics gathered from a file. *)
IMPORT Files, Out, Random;
CONST
  N = 35; (* 'А'..'Я', ' ', '.' *)
  inputFname = 'rus.txt';
  eps = 0.0001;
  genLen = 3000;
TYPE
  Stat = ARRAY N, N OF REAL;
VAR
  abc: ARRAY N + 1 OF CHAR; (* abc[N] is not used *)
  m: Stat;
  R: Files.Rider;

PROCEDURE ShowStat;
VAR i, j: INTEGER;
BEGIN
  Out.String('   ');
  FOR i := 0 TO N - 1 DO
    Out.String('   ');
    Out.Char(abc[i])
  END;
  Out.Ln;

  Out.String('  .');
  FOR i := 0 TO N - 1 DO Out.String('----') END;
  Out.Ln;

  FOR i := 0 TO N - 1 DO
    Out.Char(abc[i]);
    Out.String(' |');
    FOR j := 0 TO N - 1 DO
      Out.Int(FLOOR(m[i, j] * 1000.0 + 0.5), 4)
    END;
    Out.Ln
  END;
  Out.Ln
END ShowStat;

PROCEDURE CalcProb;
VAR i, j: INTEGER;
  sum: REAL;
BEGIN
  FOR i := 0 TO N - 1 DO
    sum := 0.0;
    FOR j := 0 TO N - 1 DO
      sum := sum + m[i, j]
    END;
    FOR j := 0 TO N - 1 DO
      IF (-eps < sum) & (sum < eps) THEN
        m[i, j] := 0.0
      ELSE
        m[i, j] := m[i, j] / sum
      END
    END
  END
END CalcProb;

PROCEDURE ClearStat;
VAR i, j: INTEGER;
BEGIN
  FOR i := 0 TO N - 1 DO
    FOR j := 0 TO N - 1 DO
      m[i, j] := 0.0
    END
  END
END ClearStat;

PROCEDURE OpenFile(): BOOLEAN;
VAR F: Files.File;
BEGIN
  F := Files.Old(inputFname);
  IF F = NIL THEN
    Out.String('Could not open file "');
    Out.String(inputFname); Out.String('".'); Out.Ln;
    Out.String('Please create this UTF-8 text file with some Russian text.'); Out.Ln
  ELSE
    Files.Set(R, F, 0)
  END
RETURN F # NIL END OpenFile;

PROCEDURE IndexOf(c: CHAR): INTEGER;
VAR index: INTEGER;
BEGIN
  IF ('А' <= c) & (c <= 'Е') THEN
    index := ORD(c) - ORD('А')
  ELSIF ('Ж' <= c) & (c <= 'Я') THEN
    index := ORD(c) - (ORD('А') - 1)
  ELSIF ('а' <= c) & (c <= 'е') THEN
    index := ORD(c) - ORD('а')
  ELSIF ('ж' <= c) & (c <= 'я') THEN
    index := ORD(c) - (ORD('а') - 1)
  ELSIF (c = 'Ё') OR (c = 'ё') THEN index := 6
  ELSIF c = ' ' THEN index := 33
  ELSIF c = '.' THEN index := 34
  ELSE index := -1
  END
RETURN index END IndexOf;

PROCEDURE RegisterPair(a, b: INTEGER);
BEGIN
  IF (a # -1) & (b # -1) THEN
    m[a, b] := m[a, b] + 1.0
  END
END RegisterPair;

PROCEDURE ReadFile;
VAR ch: CHAR;
  index, lastIndex: INTEGER;
  ZZ: INTEGER;
BEGIN
  ;;ZZ := 0;;
  lastIndex := -1;
  Files.ReadChar(R, ch);
  WHILE ~R.eof & (ZZ # -100) DO
    index := IndexOf(ch);
    RegisterPair(lastIndex, index);
    lastIndex := index;
    Files.ReadChar(R, ch)
    ;;;INC(ZZ);;
  END
END ReadFile;

PROCEDURE MakeStat(): BOOLEAN;
VAR ok: BOOLEAN;
BEGIN
  ok := FALSE;
  ClearStat;
  IF OpenFile() THEN
    ReadFile;
    CalcProb;
    ok := TRUE
  END
RETURN ok END MakeStat;

PROCEDURE CharAt(index: INTEGER; VAR newSent: BOOLEAN): CHAR;
VAR c: CHAR;
BEGIN
  c := abc[index];
  IF c = '.' THEN
    newSent := TRUE
  ELSIF newSent THEN
    IF c # ' ' THEN newSent := FALSE END
  ELSIF ('А' <= c) & (c <= 'Я') THEN
    c := CHR(ORD(c) - ORD('А') + ORD('а'))
  ELSIF c = 'Ё' THEN
    c := 'ё'
  END
RETURN c END CharAt;

PROCEDURE GenerateFirst(): INTEGER;
VAR index: INTEGER;
BEGIN
  index := Random.Int(N - 2)
RETURN index END GenerateFirst;

PROCEDURE GenerateNext(index: INTEGER): INTEGER;
VAR p: REAL;
  i: INTEGER;
BEGIN
  p := Random.Uniform();
  i := 0;
  WHILE (i # N) & (p > m[index, i] ) DO
    p := p - m[index, i];
    INC(i)
  END
RETURN i END GenerateNext;

PROCEDURE Generate(len: INTEGER);
VAR index: INTEGER;
  newSent: BOOLEAN;
BEGIN
  newSent := TRUE;
  index := GenerateFirst();
  WHILE len > 0 DO
    Out.Char(CharAt(index, newSent));
    index := GenerateNext(index);
    DEC(len)
  END;
  Out.Ln; Out.Ln
END Generate;

PROCEDURE Do*;
BEGIN
  IF ~MakeStat() THEN
    Out.String('Failed to gather statistics.'); Out.Ln
  ELSE
    ShowStat;
    Generate(genLen)
  END
END Do;

PROCEDURE InitAbc;
CONST s  = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ .';
BEGIN
  abc := s
END InitAbc;

BEGIN
  InitAbc;
  Do
END Neiro.
