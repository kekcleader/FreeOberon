MODULE Printer;  (*UNIX version: JT 11.5.90, RC 2.7.93,  JS 29.4.94, JT 14.4.95 *)

  IMPORT SYSTEM, Files, Platform;

  CONST
    N = 20;
    maxFonts = 64;
    headerFileName = "Oberon.Header.ps";
    printFileName = "Oberon.Printfile.ps";

  TYPE
    Name = ARRAY 32 OF CHAR;
    FontDesc = RECORD
      name: Name;
      used: ARRAY 8 OF SET;
    END;
    RealVector = ARRAY N OF REAL;
    Poly = RECORD a, b, c, d, t: REAL END ;
    PolyVector = ARRAY N OF Poly;

  VAR
    res*: INTEGER; (*0 = done, 1 = not done*)
    PageWidth*, PageHeight*: INTEGER;
    fontTable: ARRAY maxFonts OF FontDesc;
    fontIndex, curFont: INTEGER;
    PrinterName, listFont: Name;
    headerF, bodyF: Files.File;
    bodyR: Files.Rider;
    pno, ppos: LONGINT;
    hexArray: ARRAY 17 OF CHAR;
    curR, curG, curB: INTEGER;
    PrintMode: ARRAY 3 OF CHAR;  (* may be empty, 1: or 2: *)
    PrintCopies: INTEGER;  (* saved nofcopies for printing last page *)


  (* -- Output procedures -- *)

  PROCEDURE Ch (VAR R: Files.Rider; ch: CHAR);
  BEGIN
    Files.Write(R, ch)
  END Ch;

  PROCEDURE Str (VAR R: Files.Rider; s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE s[i] # 0X DO Ch(R, s[i]); INC(i) END;
  END Str;

  PROCEDURE Int (VAR R: Files.Rider; i: LONGINT);
    VAR j: LONGINT;
  BEGIN
    IF i = 0 THEN Ch(R, "0") ELSIF i < 0 THEN i := -i; Ch(R, "-") END;
    j := 1;
    WHILE (i DIV j) # 0 DO j := j * 10 END;
    WHILE j >= 10 DO j := j DIV 10; Ch(R, CHR(ORD("0") + (i DIV j) MOD 10)) END;
  END Int;

  PROCEDURE Hex(VAR R: Files.Rider; i: INTEGER);
  BEGIN
    IF i < 10 THEN Ch(R, CHR(i+ORD("0")))
    ELSE Ch(R, CHR(i+(ORD("a")-10)))
    END
  END Hex;

  PROCEDURE Hex2(VAR R: Files.Rider; ch: CHAR);
  BEGIN
    Ch(R, hexArray[ORD(ch) DIV 16]);
    Ch(R, hexArray[ORD(ch) MOD 16]);
  END Hex2;

  PROCEDURE Ln(VAR R: Files.Rider);
  BEGIN
    Ch(R, 0AX);
  END Ln;

  (* -- Error handling -- *)

  PROCEDURE Error(s0, s1: ARRAY OF CHAR);
    VAR error, f: ARRAY 32 OF CHAR;
  BEGIN COPY(s0, error); COPY(s1, f); HALT(99)
  END Error;

  (* -- Font Mapping -- *)

  PROCEDURE SetMappedFont(VAR fontR: Files.Rider; fname: ARRAY OF CHAR);
    VAR family: ARRAY 7 OF CHAR;
  BEGIN
    COPY(fname, family);
    Ch(fontR, "/"); Str(fontR, fname);
    IF family = "Syntax" THEN Str(fontR, " DefineSMapFont") ELSE Str(fontR, " DefineMapFont") END;
    Ln(fontR); Ln(fontR);
  END SetMappedFont;

  PROCEDURE SetBitmapFont(VAR fontR, R: Files.Rider; fd: FontDesc; pRes: INTEGER);
    CONST fontFileId = 0DBX;
    TYPE
      RunRec = RECORD beg, end: INTEGER END;
      Metrics = RECORD dx, x, y, w, h: INTEGER END;

    VAR
      ch: CHAR;
      pixmapDX, n, b: LONGINT;
      k, m: INTEGER;
      height, minX, maxX, minY, maxY: INTEGER;
      nOfBoxes, nOfRuns: INTEGER;
      run: ARRAY 16 OF RunRec;
      metrics: ARRAY 256 OF Metrics;

    PROCEDURE Flip(ch: CHAR): CHAR;
      VAR i, s, d: INTEGER;
    BEGIN
      i := 0; s := ORD(ch); d := 0;
      WHILE i < 8 DO
        IF s MOD 2 = 1 THEN d := d * 2 + 1 ELSE d := d * 2 END;
        s := s DIV 2;
        INC(i)
      END;
      RETURN CHR(d);
    END Flip;

    PROCEDURE Name(m: INTEGER);
    BEGIN
      CASE m OF
      | 9: Str(fontR, "tab")
      | 32: Str(fontR, "space")
      | 33: Str(fontR, "exclam")
      | 34: Str(fontR, "quotedbl")
      | 35: Str(fontR, "numbersign")
      | 36: Str(fontR, "dollar")
      | 37: Str(fontR, "percent")
      | 38: Str(fontR, "ampersand")
      | 39: Str(fontR, "quotesingle")
      | 40: Str(fontR, "parenleft")
      | 41: Str(fontR, "parenright")
      | 42: Str(fontR, "asterisk")
      | 43: Str(fontR, "plus")
      | 44: Str(fontR, "comma")
      | 45: Str(fontR, "minus")
      | 46: Str(fontR, "period")
      | 47: Str(fontR, "slash")
      | 48: Str(fontR, "zero")
      | 49: Str(fontR, "one")
      | 50: Str(fontR, "two")
      | 51: Str(fontR, "three")
      | 52: Str(fontR, "four")
      | 53: Str(fontR, "five")
      | 54: Str(fontR, "six")
      | 55: Str(fontR, "seven")
      | 56: Str(fontR, "eight")
      | 57: Str(fontR, "nine")
      | 58: Str(fontR, "colon")
      | 59: Str(fontR, "semicolon")
      | 60: Str(fontR, "less")
      | 61: Str(fontR, "equal")
      | 62: Str(fontR, "greater")
      | 63: Str(fontR, "question")
      | 64: Str(fontR, "at")
      | 65..90: Ch(fontR, CHR(m))
      | 91: Str(fontR, "bracketleft")
      | 92:  Str(fontR, "backslash")
      | 93: Str(fontR, "bracketright")
      | 94: Str(fontR, "arrowup")
      | 95: Str(fontR, "underscore")
      | 96: Str(fontR, "grave")
      | 97..122: Ch(fontR, CHR(m))
      | 123: Str(fontR, "braceleft")
      | 124: Str(fontR, "bar")
      | 125: Str(fontR, "braceright")
      | 126: Str(fontR, "tilde")
      | 128: Str(fontR, "Adieresis")
      | 129: Str(fontR, "Odieresis")
      | 130: Str(fontR, "Udieresis")
      | 131: Str(fontR, "adieresis")
      | 132: Str(fontR, "odieresis")
      | 133: Str(fontR, "udieresis")
      | 134: Str(fontR, "acircumflex")
      | 135: Str(fontR, "ecircumflex")
      | 136: Str(fontR, "icircumflex")
      | 137: Str(fontR, "oicircumflex")
      | 138: Str(fontR, "uicircumflex")
      | 139: Str(fontR, "agrave")
      | 140: Str(fontR, "egrave")
      | 141: Str(fontR, "igrave")
      | 142: Str(fontR, "ograve")
      | 143: Str(fontR, "ugrave")
      | 144: Str(fontR, "eacute")
      | 145: Str(fontR, "edieresis")
      | 146: Str(fontR, "idieresis")
      | 147: Str(fontR, "ccedilla")
      | 148: Str(fontR, "aacute")
      | 149: Str(fontR, "ntilde")
      | 155: Str(fontR, "endash")
      | 159: Str(fontR, "hyphen")
      | 171: Str(fontR, "germandbls")
      ELSE
        Str(fontR, "ascii");
        Ch(fontR, CHR(ORD("0") + (m DIV 100) MOD 10));
        Ch(fontR, CHR(ORD("0") + (m DIV 10) MOD 10));
        Ch(fontR, CHR(ORD("0") + m MOD 10))
      END
    END Name;

  BEGIN
    Str(fontR, "% Conversion of the Oberon font "); Str(fontR, fd.name); Ln(fontR);
    Files.Read(R, ch);
    IF ch = fontFileId THEN
      Files.Read(R, ch); Str(fontR, "% abstraction: "); Int(fontR, ORD(ch));
      Files.Read(R, ch); Str(fontR, ", family: "); Ch(fontR, ch);
      Files.Read(R, ch); Str(fontR, ", variant: "); Int(fontR, ORD(ch)); Ln(fontR);
      Files.ReadInt(R, height); Str(fontR, "% height: "); Int(fontR, height); Ln(fontR); Ln(fontR);
      Files.ReadInt(R, minX); Files.ReadInt(R, maxX);
      Files.ReadInt(R, minY); Files.ReadInt(R, maxY);
      Files.ReadInt(R, nOfRuns);
      nOfBoxes := 0; k := 0;
      WHILE k # nOfRuns DO
        Files.ReadInt(R, run[k].beg); Files.ReadInt(R, run[k].end);
        INC(nOfBoxes, run[k].end - run[k].beg);
        INC(k)
      END;
      Str(fontR, "9 dict begin"); Ln(fontR); Ln(fontR);
      Str(fontR, "/FontType 3 def"); Ln(fontR);
      Str(fontR, "/FontMatrix [ 72 "); Int(fontR, pRes); Str(fontR, " div "); Str(fontR, " .24 div 0 0 ");
      Str(fontR, "72 "); Int(fontR, pRes); Str(fontR, " div "); Str(fontR, " .24 div 0 0");
      Str(fontR, "] def"); Ln(fontR);
      Str(fontR, "/FontBBox [");
      Int(fontR, minX); Ch(fontR, " ");
      Int(fontR, minY); Ch(fontR, " ");
      Int(fontR, maxX); Ch(fontR, " ");
      Int(fontR, maxY);
      Str(fontR, "] def"); Ln(fontR); Ln(fontR);
      Str(fontR, "/Encoding 256 array def"); Ln(fontR);
      Str(fontR, "0 1 255 {Encoding exch /.notdef put} for"); Ln(fontR);
      Str(fontR, "Encoding OberonEncoding /Encoding exch def"); Ln(fontR);
      Ln(fontR);
      Str(fontR, "/CharData "); Int(fontR, nOfBoxes+1);
      Str(fontR, " dict def"); Ln(fontR);
      Str(fontR, "CharData begin"); Ln(fontR);
      k := 0; m := 0;
      WHILE k < nOfRuns DO
        m := run[k].beg;
        WHILE m < run[k].end DO
          Files.ReadInt(R, metrics[m].dx);
          Files.ReadInt(R, metrics[m].x); Files.ReadInt(R, metrics[m].y);
          Files.ReadInt(R, metrics[m].w); Files.ReadInt(R, metrics[m].h);
          INC(m);
        END;
        INC(k)
      END;
      Str(fontR, "/.notdef"); Str(fontR, " [");
      Int(fontR, metrics[32].w); Str(fontR, " 0 0 0 0 1 1 0 0"); Ln(fontR);
      Str(fontR, "<>] bdef"); Ln(fontR);
      k := 0; m := 0;
      WHILE k < nOfRuns DO
        m := run[k].beg;
        WHILE m < run[k].end DO
          IF m MOD 32 IN fd.used[m DIV 32] THEN
            Str(fontR, "/"); Name(m); Str(fontR, " [");
IF m = ORD(" ") THEN
(* jt, 13.10.95:
  ugly special case, but some printers (e.g the HP Laser Jet) crash(!) when rotating the coordinate
  system with the old implementation and there is a blank character beeing downloded*)
  Str(fontR, "11 0 0 1 1 1 1 0 0 <00");
ELSE
            Int(fontR, metrics[m].dx); Str(fontR, " ");
            Int(fontR, metrics[m].x); Str(fontR, " "); Int(fontR, metrics[m].y); Str(fontR, " ");
            Int(fontR, metrics[m].x + metrics[m].w); Str(fontR, " ");
            Int(fontR, metrics[m].y + metrics[m].h); Str(fontR, " ");
            IF metrics[m].w > 0 THEN Int(fontR, metrics[m].w); ELSE Int(fontR, 1) END; Str(fontR, " ");
            IF metrics[m].h > 0 THEN Int(fontR, metrics[m].h); ELSE Int(fontR, 1) END; Str(fontR, " ");
            Int(fontR, -metrics[m].x); Str(fontR, " "); Int(fontR, -metrics[m].y); Ln(fontR);
            Str(fontR, "<");
            pixmapDX := (metrics[m].w + 7) DIV 8;
            n := pixmapDX * metrics[m].h;
            b := 0;
            WHILE b < n DO
              Files.Read(R, ch); Hex2(fontR, Flip(ch));
              INC(b);
              IF b MOD 32 = 0 THEN Ln(fontR); Str(fontR, " ") END
            END;
END;
            Str(fontR, ">] bdef"); Ln(fontR);
          ELSE
            n := (metrics[m].w + 7) DIV 8 * metrics[m].h;
            b := 0; WHILE b < n DO Files.Read(R, ch); INC(b) END;
          END;
          INC(m);
        END;
        INC(k)
      END;
      Str(fontR, "  end"); Ln(fontR); Ln(fontR);
      Str(fontR, "/BuildGlyph {GlobalBuildGlyph} bdef"); Ln(fontR);
      Str(fontR, "/BuildChar {GlobalBuildChar} bdef"); Ln(fontR); Ln(fontR);
      Str(fontR, "/imageMaskMatrix [1 0 0 1 0 0] bdef"); Ln(fontR); Ln(fontR);
      Str(fontR, "currentdict"); Ln(fontR); Ln(fontR);
      Str(fontR, "end"); Ln(fontR); Ln(fontR);
      Ch(fontR, "/"); Str(fontR, fd.name);
      Str(fontR, " exch definefont pop"); Ln(fontR); Ln(fontR);
    END;
  END SetBitmapFont;

  PROCEDURE DefineFont(VAR fontR: Files.Rider; fd: FontDesc);
    VAR name: ARRAY 32 OF CHAR; i, size: INTEGER; VAR f: Files.File; R: Files.Rider;
  BEGIN
    COPY(fd.name, name); i := 0; size := 0;
    WHILE (name[i] # 0X) & (name[i] # ".") & ((name[i] < "0") OR (name[i] > "9")) DO INC(i) END;
    WHILE (name[i] >= "0") & (name[i] <= "9") DO size := size * 10 + ORD(name[i]) - ORD("0"); INC(i) END;
    WHILE (name[i] # 0X) & (name[i] # ".") DO INC(i) END;
    IF (name[i] # ".") OR (name[i+1] # "S") OR (name[i+2] # "c") OR (name[i+3] # "n") THEN
      SetMappedFont (fontR, fd.name);
    ELSE
      name[i+1] := "P"; name[i+2] := "r";  name[i+3] := "3";
      f := Files.Old(name);
      IF f = NIL THEN
        SetMappedFont (fontR, fd.name);
      ELSE
        Files.Set(R, f, 0); SetBitmapFont(fontR, R, fd, 300)
      END;
    END;
  END DefineFont;

  (* -- Exported Procedures -- *)

  PROCEDURE Open*(VAR name, user: ARRAY OF CHAR; password: LONGINT);
    VAR i: INTEGER;
  BEGIN
    curR := 0; curG := 0; curB := 0; res := 1;
    COPY(name, PrinterName);
    COPY(name, PrintMode); (* shortens implicitly *)
    IF PrintMode[1] = ":" THEN i := 2;
      REPEAT PrinterName[i-2] := PrinterName[i]; INC(i) UNTIL PrinterName[i-1] = 0X
    END ;
    headerF := Files.Old(headerFileName);
    IF headerF # NIL THEN
      bodyF := Files.New(""); Files.Set(bodyR, bodyF, 0);
      fontIndex := -1; curFont := -1; listFont := ""; ppos := 0; pno := 1;
      res := 0
    ELSE
      Error("file not found", headerFileName)
    END
  END Open;

  PROCEDURE UseListFont*(VAR name: ARRAY OF CHAR);
  BEGIN
    COPY(name, listFont); curFont := -1
  END UseListFont;

  PROCEDURE ReplConst*(x, y, w, h: INTEGER);
  BEGIN
    IF (w > 0) & (h > 0) THEN
      Int(bodyR, x); Ch(bodyR, " ");
      Int(bodyR, y);  Ch(bodyR, " ");
      Int(bodyR, w); Ch(bodyR, " ");
      Int(bodyR, h); Str(bodyR, " l"); Ln(bodyR);
    END
  END ReplConst;

  PROCEDURE ContString*(VAR s, fname: ARRAY OF CHAR);
    VAR fNo, i, n: INTEGER; ch: CHAR; family: ARRAY 7 OF CHAR;
      fontname: ARRAY 32 OF CHAR;

    PROCEDURE Use(ch: CHAR);
    BEGIN
      INCL(fontTable[curFont].used[ORD(ch) DIV 32], ORD(ch) MOD 32);
    END Use;

  BEGIN
    IF fname = listFont THEN fontname := "Courier8.Scn.Fnt" ELSE COPY(fname, fontname) END ;
    IF (curFont < 0) OR (fontTable[curFont].name # fontname) THEN
      COPY(fontname, fontTable[fontIndex+1].name);
      i := 0; WHILE i < 8 DO fontTable[fontIndex+1].used[i] := {}; INC(i) END;
      fNo := 0;
      WHILE fontTable[fNo].name # fontname DO INC(fNo) END;
      IF fNo > fontIndex THEN (* DefineFont(fontname); *) fontIndex := fNo END;
      curFont := fNo; Ch(bodyR, "(");
      Str(bodyR, fontTable[curFont].name);
      Str(bodyR, ") f ")
    END;
    Ch(bodyR, "(");
    i := 0; ch := s[0];
    WHILE ch # 0X DO
      CASE ch OF
      | "(", ")", "\": Ch(bodyR, "\"); Ch(bodyR, ch); Use(ch);
      | 9X: Str(bodyR, "  "); Use(" ")  (* or Str("\tab") *)
      | 80X..95X, 0ABX:
        Str(bodyR, "\2"); n := ORD(ch)-128;
        Ch(bodyR, CHR(n DIV 8 + 48)); Ch(bodyR, CHR(n MOD 8 + 48)); Use(ch)
      | 9FX: COPY(fontTable[curFont].name, family);
        IF family = "Courie" THEN Ch(bodyR, " ") ELSE Str(bodyR, "  ") END; Use(" ");
      ELSE
        Ch(bodyR, ch); Use(ch);
      END ;
      INC(i); ch := s[i];
    END;
    Str(bodyR, ") s"); Ln(bodyR)
  END ContString;

  PROCEDURE String*(x, y: INTEGER; VAR s, fname: ARRAY OF CHAR);
  BEGIN
    Int(bodyR, x); Ch(bodyR, " ");
    Int(bodyR, y); Str(bodyR, " m "); ContString(s, fname)
  END String;

  PROCEDURE ReplPattern*(x, y, w, h, col: INTEGER);
  BEGIN
    Int(bodyR, x); Ch(bodyR, " ");
    Int(bodyR, y); Ch(bodyR, " ");
    Int(bodyR, w); Ch(bodyR, " ");
    Int(bodyR, h); Ch(bodyR, " ");
    Int(bodyR, col); Str(bodyR, " b"); Ln(bodyR);
  END ReplPattern;

  PROCEDURE Picture*(x, y, w, h, mode: INTEGER; adr: SYSTEM.ADDRESS);
    VAR n, i, v: INTEGER; ch: CHAR;
  BEGIN
    Int(bodyR, x); Ch(bodyR, " ");
    Int(bodyR, y); Ch(bodyR, " ");
    Int(bodyR, w); Ch(bodyR, " ");
    Int(bodyR, h); Ch(bodyR, " ");
    Int(bodyR,mode); Str(bodyR, " i");
    n := (w + 7) DIV 8 * h; i := 0;
    WHILE i < n DO
      SYSTEM.GET(adr+i, ch);
      IF i MOD 40 = 0 THEN Ln(bodyR); END ;
      v := (-ORD(ch)-1) MOD 256;
      Hex(bodyR, v DIV 16); Hex(bodyR, v MOD 16);
      INC(i)
    END ;
    Ln(bodyR);
  END Picture;

  PROCEDURE Circle*(x0, y0, r: INTEGER);
  BEGIN
    Int(bodyR, x0); Ch(bodyR, " ");
    Int(bodyR, y0); Ch(bodyR, " ");
    Int(bodyR, r); Ch(bodyR, " ");
    Int(bodyR, r); Str(bodyR, " c");
    Ln(bodyR);
  END Circle;

  PROCEDURE Ellipse*(x0, y0, a, b: INTEGER);
  BEGIN
    Int(bodyR, x0); Ch(bodyR, " ");
    Int(bodyR, y0); Ch(bodyR, " ");
    Int(bodyR, a); Ch(bodyR, " ");
    Int(bodyR, b); Str(bodyR, " c");
    Ln(bodyR);
  END Ellipse;

  PROCEDURE Line*(x0, y0, x1, y1: INTEGER);
  BEGIN
    Int(bodyR, x0); Ch(bodyR, " ");
    Int(bodyR, y0); Ch(bodyR, " ");
    Int(bodyR, x1-x0); Ch(bodyR, " ");
    Int(bodyR, y1-y0); Str(bodyR, " x");
    Ln(bodyR);
  END Line;

  PROCEDURE UseColor*(red, green, blue: INTEGER);
  BEGIN
    IF (red # curR) OR (green # curG) OR (blue # curB) THEN
      curR := red; curG := green; curB := blue;
      Int(bodyR, curR); Str(bodyR, " 255 div ");
      Int(bodyR, curG); Str(bodyR, " 255 div ");
      Int(bodyR, curB); Str(bodyR, " 255 div u");
      Ln(bodyR);
    END;
  END UseColor;

  (* -- Spline computation -- *)

  PROCEDURE SolveTriDiag(VAR a, b, c, y: RealVector; n: INTEGER);
    VAR i: INTEGER;
  BEGIN (*a, b, c of tri-diag matrix T; solve Ty' = y for y', assign y' to y*)
    i := 1;
    WHILE i < n DO y[i] := y[i] - c[i-1]*y[i-1]; INC(i) END ;
    i := n-1; y[i] := y[i]/a[i];
    WHILE i > 0 DO DEC(i); y[i] := (y[i] - b[i]*y[i+1])/a[i] END
  END SolveTriDiag;

  PROCEDURE OpenSpline(VAR x, y, d: RealVector; n: INTEGER);
    VAR i: INTEGER; d1, d2: REAL;
      a, b, c: RealVector;
  BEGIN (*from x, y compute d = y'*)
    b[0] := 1.0/(x[1] - x[0]); a[0] := 2.0*b[0]; c[0] := b[0];
    d1 := (y[1] - y[0])*3.0*b[0]*b[0]; d[0] := d1; i := 1;
    WHILE i < n-1 DO
      b[i] := 1.0/(x[i+1] - x[i]);
      a[i] := 2.0*(c[i-1] + b[i]);
      c[i] := b[i];
      d2 := (y[i+1] - y[i])*3.0*b[i]*b[i];
      d[i] := d1 + d2; d1 := d2; INC(i)
    END ;
    a[i] := 2.0*b[i-1]; d[i] := d1; i := 0;
    WHILE i < n-1 DO c[i] := c[i]/a[i]; a[i+1] := a[i+1] - c[i]*b[i]; INC(i) END ;
    SolveTriDiag(a, b, c, d, n)
  END OpenSpline;

  PROCEDURE ClosedSpline(VAR x, y, d: RealVector; n: INTEGER);
    VAR i: INTEGER; d1, d2, hn, dn: REAL;
      a, b, c, w: RealVector;
  BEGIN (*from x, y compute d = y'*)
    hn := 1.0/(x[n-1] - x[n-2]);
    dn := (y[n-1] - y[n-2])*3.0*hn*hn;
    b[0] := 1.0/(x[1] - x[0]);
    a[0] := 2.0*b[0] + hn;
    c[0] := b[0];
    d1 := (y[1] - y[0])*3.0*b[0]*b[0]; d[0] := dn + d1;
    w[0] := 1.0; i := 1;
    WHILE i < n-2 DO
      b[i] := 1.0/(x[i+1] - x[i]);
      a[i] := 2.0*(c[i-1] + b[i]);
      c[i] := b[i];
      d2 := (y[i+1] - y[i])*3.0*b[i]*b[i]; d[i] := d1 + d2; d1 := d2;
      w[i] := 0; INC(i)
    END ;
    a[i] := 2.0*b[i-1] + hn; d[i] := d1 + dn;
    w[i] := 1.0; i := 0;
    WHILE i < n-2 DO c[i] := c[i]/a[i]; a[i+1] := a[i+1] - c[i]*b[i]; INC(i) END ;
    SolveTriDiag(a, b, c, d, n-1); SolveTriDiag(a, b, c, w, n-1);
    d1 := (d[0] + d[i])/(w[0] + w[i] + x[i+1] - x[i]); i := 0;
    WHILE i < n-1 DO d[i] := d[i] - d1*w[i]; INC(i) END ;
    d[i] := d[0]
  END ClosedSpline;

  PROCEDURE PrintPoly(VAR p, q: Poly; lim: REAL);
    VAR x0, y0, x1, y1, x2, y2, x3, y3: REAL;
  BEGIN
    x0 := p.d;
    y0 := q.d;
    x1 := x0 + p.c*lim/3.0;
    y1 := y0 + q.c*lim/3.0;
    x2 := x1 + (p.c + p.b*lim)*lim/3.0;
    y2 := y1 + (q.c + q.b*lim)*lim/3.0;
    x3 := x0 + (p.c + (p.b + p.a*lim)*lim)*lim;
    y3 := y0 + (q.c + (q.b + q.a*lim)*lim)*lim;
    Int(bodyR, ENTIER(x1)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(y1)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(x2)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(y2)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(x3)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(y3)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(x0)); Ch(bodyR, " ");
    Int(bodyR, ENTIER(y0)); Str(bodyR, " z");
    Ln(bodyR);
  END PrintPoly;

  PROCEDURE Spline*(x0, y0, n, open: INTEGER; VAR X, Y: ARRAY OF INTEGER);
    VAR i: INTEGER; dx, dy, ds: REAL;
      x, xd, y, yd, s: RealVector;
      p, q: PolyVector;
  BEGIN (*from u, v compute x, y, s*)
    x[0] := X[0] + x0; y[0] := Y[0] + y0; s[0] := 0; i := 1;
    WHILE i < n DO
      x[i] := X[i] + x0; dx := x[i] - x[i-1];
      y[i] := Y[i] + y0; dy := y[i] - y[i-1];
      s[i] := ABS(dx) + ABS(dy) + s[i-1]; INC(i)
    END ;
    IF open = 1 THEN OpenSpline(s, x, xd, n); OpenSpline(s, y, yd, n)
    ELSE ClosedSpline(s, x, xd, n); ClosedSpline(s, y, yd, n)
    END ;
    (*compute coefficients from x, y, xd, yd, s*)  i := 0;
    WHILE i < n-1 DO
      ds := 1.0/(s[i+1] - s[i]);
      dx := (x[i+1] - x[i])*ds;
      p[i].a := ds*ds*(xd[i] + xd[i+1] - 2.0*dx);
      p[i].b := ds*(3.0*dx - 2.0*xd[i] -xd[i+1]);
      p[i].c := xd[i];
      p[i].d := x[i];
      p[i].t := s[i];
      dy := ds*(y[i+1] - y[i]);
      q[i].a := ds*ds*(yd[i] + yd[i+1] - 2.0*dy);
      q[i].b := ds*(3.0*dy - 2.0*yd[i] - yd[i+1]);
      q[i].c := yd[i];
      q[i].d := y[i];
      q[i].t := s[i]; INC(i)
    END ;
    p[i].t := s[i]; q[i].t := s[i];
    (*print polynomials*)
    i := 0;
    WHILE i < n-1 DO PrintPoly(p[i], q[i], p[i+1].t - p[i].t); INC(i) END
  END Spline;

  PROCEDURE Page*(nofcopies: INTEGER);
  BEGIN
    curR := 0; curG := 0; curB := 0; curFont := -1;
    INC(pno); ppos := Files.Pos(bodyR); PrintCopies := nofcopies;
    IF PrintMode[1] # ":" THEN
      Int(bodyR, nofcopies); Str(bodyR, " p"); Ln(bodyR);
      Str(bodyR, "%%Page: 0 "); Int(bodyR, pno); Ln(bodyR)
    ELSIF ODD(pno) THEN
      Int(bodyR, nofcopies); Str(bodyR, " p"); Ln(bodyR);
      Str(bodyR, "%%Page: 0 "); Int(bodyR, pno DIV 2 + 1); Ln(bodyR);
      IF PrintMode = "1:" THEN
        Str(bodyR, "2480 0 translate"); Ln(bodyR)
      END
    ELSIF PrintMode = "1:" THEN (* start second A5 page such that the order is 4:1*)
      Str(bodyR, "-2480 0 translate"); Ln(bodyR)
    ELSE (* start second A5 page such that the order is 2:3 *)
      Str(bodyR, "2480 0 translate"); Ln(bodyR)
    END
  END Page;

  PROCEDURE Append(VAR s1: ARRAY OF CHAR; s2: ARRAY OF CHAR);
    VAR i, j: INTEGER; ch: CHAR;
  BEGIN i := 0; j := 0;
    WHILE s1[i] # 0X DO INC(i) END ;
    REPEAT ch := s2[j]; s1[i] := ch; INC(i); INC(j) UNTIL ch = 0X
  END Append;

  PROCEDURE Close*;
    CONST bufSize = 4*1024;
    VAR
      cmd: ARRAY 256 OF CHAR; i: INTEGER;
      printF: Files.File; printR, srcR: Files.Rider; ch: CHAR; buffer: ARRAY bufSize OF SYSTEM.BYTE;
  BEGIN
    Files.Set(bodyR, bodyF, ppos);  (*overwrite last %%Page line*)
    Int(bodyR, PrintCopies); Str(bodyR, " p"); Ln(bodyR);
    Str(bodyR, "%%Trailer         "); Ln(bodyR);
    printF := Files.New(printFileName); Files.Set(printR, printF, 0);
    IF PrinterName # "none" THEN Files.Write(printR, 4X) (*force reset postscript*) END ;
    Files.Set(srcR, headerF, 0);
    REPEAT Files.ReadBytes(srcR, buffer, bufSize); Files.WriteBytes(printR, buffer, bufSize-srcR.res) UNTIL srcR.eof;
    i := 0;
    WHILE i <= fontIndex DO DefineFont(printR, fontTable[i]); INC(i) END;
    Ln(printR);
    IF PrintMode[1] # ":" THEN
      Str(printR, "OberonInit"); Ln(printR); Ln(printR)
    ELSE Str(printR, "OberonInit2"); Ln(printR); Ln(printR)
    END ;
    Str(printR, "%%EndProlog"); Ln(printR);
    Str(printR, "%%Page: 0 1"); Ln(printR);
    Str(printR, "save"); Ln(printR); Ln(printR);
    IF PrintMode = "1:" THEN
      Str(printR, "2480 0 translate"); Ln(printR)
    END ;
    Files.Set(srcR, bodyF, 0);
    REPEAT Files.ReadBytes(srcR, buffer, bufSize); Files.WriteBytes(printR, buffer, bufSize-srcR.res) UNTIL srcR.eof;
    IF PrinterName # "none" THEN Files.Write(printR, 4X) (*force reset postscript*) END ;
    Files.Register(printF);
    IF PrinterName # "none" THEN
      cmd := "lp -c -s ";
      IF PrinterName # "Pluto" THEN Append(cmd, "-d "); Append(cmd, PrinterName) END ;
      Append(cmd, " "); Append(cmd, printFileName);
      i := Platform.System(cmd);
      Files.Delete(printFileName, res);
    END;
    Files.Set(bodyR, NIL, 0);
    headerF := NIL; bodyF := NIL; printF := NIL
  END Close;

BEGIN
  hexArray := "0123456789ABCDEF";
  PageWidth := 2336; PageHeight := 3425
END Printer.
