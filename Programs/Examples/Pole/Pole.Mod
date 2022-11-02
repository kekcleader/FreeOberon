MODULE Pole;
IMPORT Visual, Words;
VAR word: Words.Word;
  done: BOOLEAN;

PROCEDURE GameTurn;
VAR L: CHAR;
  guess: BOOLEAN;
BEGIN
  Visual.ShowWord(word);
  Visual.AskLetter(L);
  Words.ApplyLetter(word, L, guess);
  IF guess THEN Visual.Guessed(L) ELSE Visual.Failed END;
  IF Words.IsOpen(word) THEN done := TRUE END
END GameTurn;

PROCEDURE GameRound;
BEGIN
  Words.RandomWord(word);
  done := FALSE;
  REPEAT GameTurn UNTIL done;
  Visual.ShowWord(word);
  Visual.GameOver
END GameRound;

PROCEDURE Run;
VAR repeat: BOOLEAN;
BEGIN
  REPEAT
    GameRound;
    Visual.AskRepeat(repeat)
  UNTIL ~repeat
END Run;

BEGIN
  Visual.Intro;
  IF ~Words.loaded THEN Visual.ShowWordsError END;
  Run
END Pole.