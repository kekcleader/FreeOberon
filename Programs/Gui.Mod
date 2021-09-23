MODULE Gui; (* My GUI Module *)
IMPORT Out, G := Graph;

CONST
  charW = 8; charH = 16;

  (* redrawState *)
  redrawNone* = 0;
  redrawAll*  = 1;
  redrawSome* = 2;

TYPE
  Method* = POINTER TO MethodDesc;
  Component* = POINTER TO ComponentDesc;
  Container* = POINTER TO ContainerDesc;
  Form* = POINTER TO FormDesc;
  Button* = POINTER TO ButtonDesc;
  Edit* = POINTER TO EditDesc;
  Circle* = POINTER TO CircleDesc;

  (* Handler Procedures *)  
  OnDrawHandler = PROCEDURE (c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
  OnMouseDownHandler = PROCEDURE (c: Component; x, y, btn: INTEGER);
  OnKeyDownHandler = PROCEDURE (c: Component; key: INTEGER);

  MethodDesc* = RECORD
    draw*: OnDrawHandler;
    mouseDown*: OnMouseDownHandler;
    keyDown*: OnKeyDownHandler;
    add*: PROCEDURE (c, toAdd: Component);
    updated*: PROCEDURE (c: Component; moved: BOOLEAN);
    redraw*: PROCEDURE (c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
    (* Setters *)
    setX*: PROCEDURE (c: Component; x: INTEGER);
    setY*: PROCEDURE (c: Component; y: INTEGER);
    setW*: PROCEDURE (c: Component; w: INTEGER);
    setH*: PROCEDURE (c: Component; h: INTEGER);
    setBounds*: PROCEDURE (c: Component; x, y, w, h: INTEGER);
    setVisible*: PROCEDURE (c: Component; visible: BOOLEAN);
    (* Event Handler Setters *)
    setOnDraw*: PROCEDURE (c: Component; hn: OnDrawHandler);
    setOnMouseDown*: PROCEDURE (c: Component; hn: OnMouseDownHandler);
    setOnKeyDown*: PROCEDURE (c: Component; hn: OnKeyDownHandler);
  END;
  ComponentDesc* = RECORD
    x*, y*, w*, h*: INTEGER;
    visible*: BOOLEAN;
    redrawState*: INTEGER; (* see constants with prefix 'redraw' *)
    do*: Method;
    onDraw*: OnDrawHandler;
    onMouseDown*: OnMouseDownHandler;
    onKeyDown*: OnKeyDownHandler;
    parent*: Component;
    next*: Component
  END;
  ContainerDesc* = RECORD(ComponentDesc)
    first*: Component
  END;
  FormDesc* = RECORD(ContainerDesc)
    bgColor*: INTEGER
  END;
  ButtonDesc* = RECORD(ComponentDesc)
    caption*: ARRAY 100 OF CHAR
  END;
  EditDesc* = RECORD(ComponentDesc)
    text*: ARRAY 4096 OF CHAR;
    selStart*: INTEGER;
    selLen*: INTEGER
  END;
  CircleDesc* = RECORD(ComponentDesc)
    color*: INTEGER
  END;

VAR
  screen: G.Bitmap;
  font: G.Font;
  needFlip: BOOLEAN;

  (* Methods *)
  method, formMethod, buttonMethod, circleMethod, editMethod: Method;

  form: Form;
  btnHello: Button;
  circle: Circle;
  edit: Edit;

(* Component *)

PROCEDURE InitComponent*(c: Component);
BEGIN
  c.x := 0; c.y := 0; c.w := 0; c.h := 0;
  c.visible := TRUE;
  c.redrawState := redrawNone;
  c.do := method; c.next := NIL; c.parent := NIL;
  c.onDraw := NIL; c.onMouseDown := NIL
END InitComponent;

PROCEDURE UpdatedComponent*(c: Component; moved: BOOLEAN);
BEGIN
  IF c.redrawState # redrawAll THEN
    c.redrawState := redrawAll;
    c := c.parent;
    IF moved & (c # NIL) & (c.redrawState # redrawAll)  THEN
      c.redrawState := redrawAll;
      c := c.parent
    END;
    WHILE (c # NIL) & (c.redrawState = redrawNone) DO
      c.redrawState := redrawSome;
      c := c.parent
    END
  END
END UpdatedComponent;

PROCEDURE RedrawComponent*(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
BEGIN
  IF (c.redrawState = redrawAll) & c.visible THEN
    c.do.draw(c, bmp, x0, y0);
    needFlip := TRUE
  END;
  c.redrawState := redrawNone
END RedrawComponent;

PROCEDURE ComponentSetX(c: Component; x: INTEGER);
BEGIN c.x := x; c.do.updated(c, TRUE)
END ComponentSetX;

PROCEDURE ComponentSetY(c: Component; y: INTEGER);
BEGIN c.y := y; c.do.updated(c, TRUE)
END ComponentSetY;

PROCEDURE ComponentSetW(c: Component; w: INTEGER);
BEGIN c.w := w; c.do.updated(c, TRUE)
END ComponentSetW;

PROCEDURE ComponentSetH(c: Component; h: INTEGER);
BEGIN c.h := h; c.do.updated(c, TRUE)
END ComponentSetH;

PROCEDURE ComponentSetBounds(c: Component; x, y, w, h: INTEGER);
BEGIN c.x := x; c.y := y; c.w := w; c.h := h; c.do.updated(c, TRUE)
END ComponentSetBounds;

PROCEDURE ComponentSetVisible(c: Component; visible: BOOLEAN);
BEGIN
  IF c.visible # visible THEN
    c.visible := visible;
    c.do.updated(c, ~visible)
  END
END ComponentSetVisible;

PROCEDURE ComponentSetOnDraw(c: Component; hn: OnDrawHandler);
BEGIN c.onDraw := hn
END ComponentSetOnDraw;

PROCEDURE ComponentSetOnMouseDown(c: Component; hn: OnMouseDownHandler);
BEGIN c.onMouseDown := hn
END ComponentSetOnMouseDown;

PROCEDURE ComponentSetOnKeyDown(c: Component; hn: OnKeyDownHandler);
BEGIN c.onKeyDown := hn
END ComponentSetOnKeyDown;

(* Container *)

PROCEDURE InitContainer*(c: Container);
BEGIN
  InitComponent(c);
  c.first := NIL
END InitContainer;

PROCEDURE RedrawContainer*(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR x: Component;
BEGIN
  IF c.visible THEN
    IF c.redrawState = redrawAll THEN
      c.do.draw(c, bmp, x0, y0);
      needFlip := TRUE
    ELSIF c.redrawState = redrawSome THEN
      INC(x0, c.x); INC(y0, c.y);
      x := c(Container).first;
      WHILE x # NIL DO
        IF x.redrawState # redrawNone THEN
          x.do.redraw(x, bmp, x0, y0)
        END;
        x := x.next
      END;
      needFlip := TRUE
    END
  END;
  c.redrawState := redrawNone
END RedrawContainer;

PROCEDURE DrawContainerChildren(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR d: Component;
BEGIN
  INC(x0, c.x); INC(y0, c.y);
  d := c(Container).first;
  WHILE d # NIL DO
    IF d.visible THEN d.do.draw(d, bmp, x0, y0) END;
    d.redrawState := redrawNone;
    d := d.next
  END
END DrawContainerChildren;

PROCEDURE MouseDownContainer(c: Component; x, y, btn: INTEGER);
VAR d: Component;
BEGIN
  d := c(Container).first;
  WHILE (d # NIL) &
       ~(d.visible &
         (x >= d.x) & (x < d.x + d.w) &
         (y >= d.y) & (y < d.y + d.h))
  DO d := d.next
  END;
  IF d # NIL THEN d.do.mouseDown(d, x - d.x, y - d.y, btn) END
END MouseDownContainer;

PROCEDURE AddToContainer(c, toAdd: Component);
BEGIN
  toAdd.next := c(Container).first;
  c(Container).first := toAdd;
  toAdd.parent := c;
  toAdd.do.updated(c, TRUE)
END AddToContainer;

(* Form *)

PROCEDURE InitForm*(f: Form);
BEGIN
  InitContainer(f);
  f.do := formMethod;
  f.bgColor := G.MakeCol(180, 180, 180)
END InitForm;

PROCEDURE NewForm*(): Form;
VAR f: Form;
BEGIN
  NEW(f); InitForm(f); RETURN f
END NewForm;

PROCEDURE DrawForm(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR x, y: INTEGER;
BEGIN
  x := x0 + c.x; y := y0 + c.y;
  G.RectFill(bmp, x, y, x + c.w - 1, y + c.h - 1, c(Form).bgColor);
  DrawContainerChildren(c, bmp, x0, y0)
END DrawForm;

(* Button *)

PROCEDURE InitButton*(b: Button; caption: ARRAY OF CHAR);
BEGIN
  InitComponent(b);
  b.do := buttonMethod;
  b.caption := caption
END InitButton;

PROCEDURE NewButton*(caption: ARRAY OF CHAR): Button;
VAR b: Button;
BEGIN
  NEW(b); InitButton(b, caption); RETURN b
END NewButton;

PROCEDURE DrawButton(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR i, len, c1, c2, c3: INTEGER;
BEGIN
  INC(x0, c.x); INC(y0, c.y);
  c1 := G.MakeCol(255, 255, 255);
  c2 := G.MakeCol(160, 160, 160);
  c3 := G.MakeCol(100, 100, 100);
  len := 0; WHILE c(Button).caption[len] # 0X DO INC(len) END;
  G.RectFill(bmp, x0 + 1, y0 + 1, x0 + c.w - 3, y0 + c.h - 3,
             G.MakeCol(200, 200, 200));
  G.HLine(bmp, x0, y0, x0 + c.w - 2, c1);
  G.VLine(bmp, x0, y0, y0 + c.h - 2, c1);
  G.HLine(bmp, x0 + 1, y0 + c.h - 2, x0 + c.w - 3, c2);
  G.VLine(bmp, x0 + c.w - 2, y0 + 1, y0 + c.h - 2, c2);
  G.HLine(bmp, x0, y0 + c.h - 1, x0 + c.w - 1, c3);
  G.VLine(bmp, x0 + c.w - 1, y0, y0 + c.h - 2, c3);
  FOR i := 0 TO len - 1 DO
    G.DrawCharacter(screen, font, x0 + (c.w - charW * len) DIV 2,
                    y0 + (c.h - charH) DIV 2, c(Button).caption[i],
                    G.MakeCol(0, 0, 0));
    INC(x0, charW)
  END
END DrawButton;

PROCEDURE MouseDownButton(c: Component; x, y, btn: INTEGER);
BEGIN
  IF c.onMouseDown # NIL THEN c.onMouseDown(c, x, y, btn) END
END MouseDownButton;

(* Edit *)

PROCEDURE InitEdit*(e: Edit);
BEGIN
  InitComponent(e);
  e.do := editMethod;
  e.text[0] := 0X;
  e.selStart := 0;
  e.selLen := 0
END InitEdit;

PROCEDURE NewEdit*(): Edit;
VAR e: Edit;
BEGIN
  NEW(e); InitEdit(e); RETURN e
END NewEdit;

PROCEDURE DrawEdit(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR i, len, c1, c2, c3: INTEGER;
BEGIN
  INC(x0, c.x); INC(y0, c.y);
  c1 := G.MakeCol(255, 255, 255);
  c2 := G.MakeCol(160, 160, 160);
  c3 := G.MakeCol(100, 100, 100);
  len := 0; WHILE c(Edit).text[len] # 0X DO INC(len) END;
  G.RectFill(bmp, x0 + 1, y0 + 1, x0 + c.w - 3, y0 + c.h - 3,
             G.MakeCol(200, 200, 200));
  G.HLine(bmp, x0, y0, x0 + c.w - 2, c1);
  G.VLine(bmp, x0, y0, y0 + c.h - 2, c1);
  G.HLine(bmp, x0 + 1, y0 + c.h - 2, x0 + c.w - 3, c2);
  G.VLine(bmp, x0 + c.w - 2, y0 + 1, y0 + c.h - 2, c2);
  G.HLine(bmp, x0, y0 + c.h - 1, x0 + c.w - 1, c3);
  G.VLine(bmp, x0 + c.w - 1, y0, y0 + c.h - 2, c3);
  FOR i := 0 TO len - 1 DO
    G.DrawCharacter(screen, font, x0 + (c.w - charW * len) DIV 2,
                    y0 + (c.h - charH) DIV 2, c(Edit).text[i],
                    G.MakeCol(0, 0, 0));
    INC(x0, charW)
  END
END DrawEdit;

PROCEDURE MouseDownEdit(c: Component; x, y, btn: INTEGER);
BEGIN
  IF c.onMouseDown # NIL THEN c.onMouseDown(c, x, y, btn) END
END MouseDownEdit;

PROCEDURE KeyDownEdit(c: Component; key: INTEGER);
BEGIN
  IF c.onKeyDown # NIL THEN c.onKeyDown(c, key) END
END KeyDownEdit;

(* Circle *)

PROCEDURE InitCircle*(c: Circle);
BEGIN
  InitComponent(c);
  c.do := circleMethod;
  c.color := G.MakeCol(0, 0, 0)
END InitCircle;

PROCEDURE NewCircle*(): Circle;
VAR c: Circle;
BEGIN
  NEW(c); InitCircle(c); RETURN c
END NewCircle;

PROCEDURE DrawCircle(c: Component; bmp: G.Bitmap; x0, y0: INTEGER);
VAR r, x, y, err, color: INTEGER;
BEGIN
  INC(x0, c.x); INC(y0, c.y);
  IF c.w <= c.h THEN r := (c.w - 1) DIV 2 ELSE r := (c.h - 1) DIV 2 END;
  IF r > 0 THEN
    INC(x0, c.w DIV 2); INC(y0, c.h DIV 2);
    x := 0; y := r; err := 3 - 2 * r; color := c(Circle).color;
    WHILE y >= x DO
      G.PutPixel(screen, x0 + x, y0 + y, color);
      G.PutPixel(screen, x0 + y, y0 + x, color);
      G.PutPixel(screen, x0 - y, y0 + x, color);
      G.PutPixel(screen, x0 - x, y0 + y, color);
      G.PutPixel(screen, x0 - x, y0 - y, color);
      G.PutPixel(screen, x0 - y, y0 - x, color);
      G.PutPixel(screen, x0 + y, y0 - x, color);
      G.PutPixel(screen, x0 + x, y0 - y, color);
      IF err < 0 THEN INC(err, 4 * x + 6); INC(x, 1)
      ELSE INC(err, 4 * (x - y)); INC(x); DEC(y)
      END
    END
  END
END DrawCircle;

PROCEDURE MouseDownCircle(c: Component; x, y, btn: INTEGER);
BEGIN
  c(Circle).color := G.MakeCol(G.Random(256), G.Random(256), G.Random(256));
  DEC(c.x); DEC(c.w);
  c.do.updated(c, TRUE)
END MouseDownCircle;

(* Other *)

PROCEDURE btnHelloMouseDown(c: Component; x, y, btn: INTEGER);
VAR i: INTEGER;
BEGIN
  c(Button).caption[1] := CHR(33 + (ORD(c(Button).caption[1]) + y * c.w + x) MOD 64);
  i := 0; WHILE c(Button).caption[i] # 0X DO INC(i) END;
  IF i < LEN(c(Button).caption) - 1 THEN
    c(Button).caption[i] := CHR(i+ORD('0')); c(Button).caption[i+1] := 0X
  END;
  IF c.next # NIL THEN c.next.do.setVisible(c.next, ~c.next.visible) END;
  c.do.setX(c, c.x + 1)
END btnHelloMouseDown;

PROCEDURE Act;
BEGIN
  form.do.redraw(form, screen, 0, 0);
  IF needFlip THEN G.Flip; needFlip := FALSE ELSE G.RepeatFlip END
END Act;

PROCEDURE Run;
VAR e: G.Event;
    quit: BOOLEAN;
BEGIN
  quit := FALSE;
  REPEAT
    G.WaitEvents(50);
    WHILE G.PollEvent(e) DO
      IF e.type = G.quit THEN
        quit := TRUE
      ELSIF e.type = G.keyDown THEN
        IF e.key.code = G.kEsc THEN quit := TRUE END
      ELSIF e.type = G.mouseDown THEN
        form.do.mouseDown(form, e.x, e.y, e.button)
      ELSIF e.type = G.mouseMove THEN
        needFlip := TRUE
      END
    END;
    Act
  UNTIL quit
END Run;

PROCEDURE Init;
VAR i: INTEGER;
BEGIN
  form := NewForm();
  form.w := screen.w;
  form.h := screen.h;

  FOR i := 0 TO 4 DO
    btnHello := NewButton('Hello');
    btnHello.x := 10;
    btnHello.y := 1 + i * 21;
    btnHello.w := 70;
    btnHello.h := 20;
    btnHello.onMouseDown := btnHelloMouseDown;
    btnHello.visible := i MOD 2 = 0;
    form.do.add(form, btnHello)
  END;

  FOR i := 1 TO G.Random(10) + 10 DO 
    circle := NewCircle();
    circle.w := 10 + G.Random(100);
    circle.h := circle.w;
    circle.x := 100 + G.Random(screen.w - circle.w - 101);
    circle.y := G.Random(screen.h - 1 - circle.h);
    form.do.add(form, circle)
  END;

  edit := NewEdit();
  edit.do.setBounds(edit, 10, screen.h - 30, 80, 20);
  edit.text := 'World';
  form.do.add(form, edit);

  G.ClearScreen;
  needFlip := TRUE
END Init;

BEGIN
  NEW(method);
  method.draw := NIL;
  method.mouseDown := NIL;
  method.keyDown := NIL;
  method.add := NIL;
  method.updated := UpdatedComponent;
  method.redraw := RedrawComponent;
  method.setX := ComponentSetX;
  method.setY := ComponentSetY;
  method.setW := ComponentSetW;
  method.setH := ComponentSetH;
  method.setBounds := ComponentSetBounds;
  method.setVisible := ComponentSetVisible;
  method.setOnDraw := ComponentSetOnDraw;
  method.setOnMouseDown := ComponentSetOnMouseDown;
  method.setOnKeyDown := ComponentSetOnKeyDown;

  NEW(formMethod);
  formMethod^ := method^;
  formMethod.draw := DrawForm;
  formMethod.mouseDown := MouseDownContainer;
  formMethod.add := AddToContainer;
  formMethod.redraw := RedrawContainer;

  NEW(buttonMethod);
  buttonMethod^ := method^;
  buttonMethod.draw := DrawButton;
  buttonMethod.mouseDown := MouseDownButton;

  NEW (editMethod);
  editMethod^ := method^;
  editMethod.draw := DrawEdit;
  editMethod.mouseDown := MouseDownEdit;
  editMethod.keyDown := KeyDownEdit;

  NEW(circleMethod);
  circleMethod^ := method^;
  circleMethod.draw := DrawCircle;
  circleMethod.mouseDown := MouseDownCircle;
  circleMethod.add := NIL;
  circleMethod.updated := UpdatedComponent;
  circleMethod.redraw := RedrawComponent;

  G.Settings(320, 200, {G.fullscreen, G.spread, G.sharpPixels, G.initMouse});
  (*G.Settings(640, 480, {G.fullscreen, G.spread, G.sharpPixels, G.initMouse});*)
  screen := G.Init();
  IF screen # NIL THEN
    font := G.LoadFont('../data/images/font.bmp', charW, charH);
    IF font # NIL THEN
      Init;
      Run
    ELSE
      Out.String('Could not load font.'); Out.Ln
    END
  ELSE Out.String('Graphics init failed.'); Out.Ln
  END;
  G.Close()
END Gui.
