MODULE Words;
IMPORT Files, Random;
CONST maxLetters = 33;
  maxWords = 1000;
TYPE
  Word* = RECORD
    len*: INTEGER;
    L*: ARRAY maxLetters OF CHAR;
    open*: ARRAY maxLetters OF BOOLEAN
  END;

VAR loaded*: BOOLEAN;
  error: BOOLEAN;
  words: ARRAY maxWords, maxLetters OF CHAR;
  lengths: ARRAY maxWords OF INTEGER;
  nofwords: INTEGER;

PROCEDURE RandomWord*(VAR word: Word);
VAR i, n: INTEGER;
BEGIN
  n := Random.Int(nofwords);
  word.len := lengths[n];
  FOR i := 0 TO word.len - 1 DO
    word.L[i] := words[n][i];
    word.open[i] := FALSE
  END
END RandomWord;

(** Returns TRUE if all letters in word are open. *)
PROCEDURE IsOpen*(VAR word: Word): BOOLEAN;
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i # word.len) & word.open[i] DO INC(i) END
RETURN i = word.len END IsOpen;

PROCEDURE ApplyLetter*(VAR word: Word; L: CHAR; VAR applied: BOOLEAN);
VAR i: INTEGER;
BEGIN applied := FALSE;
  FOR i := 0 TO word.len - 1 DO
    IF ~word.open[i] & (word.L[i] = L) THEN
      word.open[i] := TRUE;
      applied := TRUE
    END
  END
END ApplyLetter;

PROCEDURE FallbackWords;
BEGIN
  loaded := FALSE;
  nofwords := 2;
  words[0] := 'РЫБАЛКА'; lengths[0] := 7;
  words[1] := 'ЯКУБОВИЧ'; lengths[1] := 8
END FallbackWords;

PROCEDURE LoadWord*(VAR r: Files.Rider);
VAR c: CHAR;
  i: INTEGER;
BEGIN i := 0;
  Files.ReadChar(r, c);
  WHILE ~r.eof & (c > ' ') DO
    IF (i # maxLetters) & ('А' <= c) & (c <= 'Я') THEN
      words[nofwords][i] := c;
      INC(i)
    ELSE error := TRUE
    END;
    Files.ReadChar(r, c)
  END;
  lengths[nofwords] := i;
  INC(nofwords)
END LoadWord;

PROCEDURE LoadWords;
VAR F: Files.File;
  r: Files.Rider;
BEGIN
  F := Files.Old('words.dat');
  IF F = NIL THEN FallbackWords
  ELSE Files.Set(r, F, 0);
    nofwords := 0; error := FALSE;
    WHILE ~r.eof & ~error & (nofwords # maxWords) DO LoadWord(r) END;
    loaded := ~error
  END
END LoadWords;

BEGIN
  LoadWords
END Words.