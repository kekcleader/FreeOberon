MODULE Visual;
IMPORT Words, In, Out;

PROCEDURE Intro*;
BEGIN Out.Ln; Out.Ln;
  Out.String('        Добро пожаловать в игру'); Out.Ln; Out.Ln;
  Out.String('        " П О Л Е   Ч У Д Е С "'); Out.Ln; Out.Ln
END Intro;

PROCEDURE ShowWord*(VAR word: Words.Word);
VAR i: INTEGER;
BEGIN Out.Ln;
  FOR i := 0 TO 40 DO Out.Char('-') END; Out.Ln; Out.Ln;
  Out.String('        ');
  FOR i := 0 TO word.len - 1 DO
    Out.String(' [');
    IF word.open[i] THEN Out.Char(word.L[i]) ELSE Out.Char('_') END;
    Out.Char(']')
  END;
  Out.Ln; Out.Ln
END ShowWord;

PROCEDURE AskLetter*(VAR L: CHAR);
VAR s: ARRAY 2 OF CHAR;
BEGIN
  Out.String('  Буква: '); In.Line(s); L := s[0];
  WHILE ~(('А' <= L) & (L <= 'Я') OR
          ('а' <= L) & (L <= 'я') OR
          (L = 'Ё') OR (L = 'ё')) DO
    Out.String('  Какая? '); In.Line(s); L := s[0]
  END;
  IF ('а' <= L) & (L <= 'я') THEN
    L := CHR(ORD(L) - ORD('а') + ORD('А'))
  ELSIF (L = 'Ё') OR (L = 'ё') THEN L := 'Е'
  END
END AskLetter;

PROCEDURE AskRepeat*(VAR repeat: BOOLEAN);
VAR s: ARRAY 2 OF CHAR;
  c: CHAR;
BEGIN
  REPEAT Out.String('  Повторить игру? [д/н] '); In.Line(s); c := s[0]
  UNTIL (c = 'Д') OR (c = 'д') OR (c = 'Н') OR (c = 'н') OR
        (c = 'y') OR (c = 'n');
  repeat := (c = 'Д') OR (c = 'д') OR (c = 'y')
END AskRepeat;

PROCEDURE Guessed*(L: CHAR);
BEGIN Out.String('  Есть такая буква! Откройте букву "');
  Out.Char(L); Out.String('".'); Out.Ln
END Guessed;

PROCEDURE Failed*;
BEGIN Out.String('  Нет! Такой буквы здесь нет!'); Out.Ln
END Failed;

PROCEDURE GameOver*;
BEGIN Out.String('  Игра окончена!'); Out.Ln
END GameOver;

PROCEDURE ShowWordsError*;
BEGIN Out.String('Не найден файл со словами "words.dat".'); Out.Ln
END ShowWordsError;

END Visual.