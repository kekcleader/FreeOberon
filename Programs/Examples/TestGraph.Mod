MODULE TestGraph;
IMPORT G := Graph, Out;
VAR c, f: G.Color;
  X, Y, W, H: INTEGER;
  font: G.Font;
  ZZ: ARRAY 2 OF CHAR;

PROCEDURE Draw;
BEGIN
  G.ClearToColor(c);
  IF X # -1 THEN
    G.Line(0, 0, X, Y, f);
    G.Line(0, H, X, Y, f);
    G.Line(W, H, X, Y, f);
    G.Line(W, 0, X, Y, f)
  END
END Draw;

PROCEDURE Message;
BEGIN
  IF font # NIL THEN
    G.DrawString('Press space to return. X for down, ESC for up.',
      0, 0, font, f);
    G.DrawString(ZZ, 0, 16, font, f)
  END
END Message;

PROCEDURE Animation;
VAR ch: CHAR;
BEGIN ch := 0X;
  REPEAT
    INC(X); IF X > W THEN X := 0 END;
    Draw;
    Message;
    G.Flip;
    G.Delay(1);
    IF G.KeyPressed() THEN
      ch := G.ReadKey();
      IF ch = 'x' THEN INC(Y, 100)
      ELSIF ch = CHR(27) THEN DEC(Y, 100)
      END
    END
  UNTIL ch = ' ';
END Animation;

PROCEDURE ByKey;
VAR ch: CHAR;
BEGIN
  REPEAT
    INC(X, 50); IF X > W THEN X := 0 END;
    Draw;
    Message;
    G.Flip;
    ch := G.ReadKey();
    IF ch = 'x' THEN INC(Y, 100)
    ELSIF ch = CHR(27) THEN DEC(Y, 100)
    ELSE ZZ[0] := ch
    END
  UNTIL ch = ' '
END ByKey;

PROCEDURE Do;
VAR e: G.Event;
  done: BOOLEAN;
BEGIN
  (*G.Settings(320, 200, {G.window});*)
  G.Init;
  G.ShowMouse(FALSE);
  font := G.LoadFont('Data/Fonts/Main');
  IF font = NIL THEN
    Out.String("Could not load font."); Out.Ln;
  ELSE
    G.GetTargetSize(W, H); DEC(W); DEC(H);
    G.MakeCol(c, 20, 30, 80);
    G.MakeCol(f, 0, 180, 255);
    done := FALSE; X := -1; ZZ[0] := 0X; ZZ[1] := 0X;
    REPEAT
      WHILE G.HasEvents() DO
        G.WaitEvent(e);
        IF e.type = G.quit THEN done := TRUE
        ELSIF e.type = G.mouseMove THEN
          X := e.x; Y := e.y
        ELSIF e.type = G.mouseDown THEN
          IF e.button = 1 THEN Animation
          ELSIF e.button = 2 THEN ByKey
          END
        END
      END;
      Draw;
      G.DrawString('Left mouse button - KeyPressed, right - ReadKey test',
        0, 0, font, f);
      G.Flip;
      G.Delay(1)
    UNTIL done
  END;
  G.Close
END Do;

BEGIN
  Do
END TestGraph.
