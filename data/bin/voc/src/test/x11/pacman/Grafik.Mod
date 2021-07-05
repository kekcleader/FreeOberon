MODULE Grafik;
(*enthƒlt verschiedene Grafik-Befehle*)

IMPORT XYplane := oocXYplane,Out := Console;

TYPE sprite*=ARRAY 10,10 OF BOOLEAN;

VAR zahlen*:ARRAY 10 OF sprite;
  buchstaben*:ARRAY 27 OF sprite;
  satzzeichen*:ARRAY 2 OF sprite;

PROCEDURE Linie*(StartX,StartY,EndeX,EndeY:INTEGER);
VAR LaengeX,LaengeY,PunktX,PunktY,hilfe,zaehler:INTEGER;
  Steigung:REAL;
BEGIN
  IF StartX>EndeX THEN
    hilfe:=StartX;
    StartX:=EndeX;
    EndeX:=hilfe;
    hilfe:=StartY;
    StartY:=EndeY;
    EndeY:=hilfe;
  END;
  LaengeX:=EndeX-StartX;
  LaengeY:=EndeY-StartY;
  IF LaengeX=0 THEN
    IF EndeY>StartY THEN
      PunktY:=StartY
    ELSE
      PunktY:=EndeY
    END;
    PunktX:=StartX;
    LaengeY:=ABS(LaengeY);
    FOR zaehler:=1 TO LaengeY DO
      INC(PunktY);
      XYplane.Dot(PunktX,PunktY,XYplane.draw);
    END;
    RETURN;
  END;
  Steigung:=LaengeY/LaengeX;
  FOR zaehler:=1 TO LaengeX DO
    PunktX:=StartX+zaehler;
    hilfe:=SHORT(ENTIER(zaehler*Steigung));
    PunktY:=StartY+hilfe;
    XYplane.Dot(PunktX,PunktY,XYplane.draw);
  END;
END Linie;

PROCEDURE SpriteSetzen*(s:sprite; x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      IF s[i,j] THEN XYplane.Dot(x+i,y+j,XYplane.draw)
      ELSE XYplane.Dot(x+i,y+j,XYplane.erase);
      END;
    END;
  END;
END SpriteSetzen;

PROCEDURE SpriteLoeschen*(x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      XYplane.Dot(x+i,y+j,XYplane.erase)
    END
  END
END SpriteLoeschen;

PROCEDURE SpriteBewegen*(s:sprite; ax,ay,bx,by,bremse:INTEGER);
VAR cx,cy,i,j:INTEGER;
BEGIN
  cx:=ax;
  cy:=ay;
  REPEAT
    FOR i:=1 TO bremse DO j:=i MOD 7 END;
    IF cx>bx THEN
      FOR i:=0 TO 9 DO XYplane.Dot(cx+9,cy+i,XYplane.erase) END;
      DEC(cx);
    ELSIF cx<bx THEN
      FOR i:=0 TO 9 DO XYplane.Dot(cx,cy+i,XYplane.erase) END;
      INC(cx);
    END;
    IF cy>by THEN
      FOR i:=0 TO 9 DO XYplane.Dot(cx+i,cy+9,XYplane.erase) END;
      DEC(cy);
    ELSIF cy<by THEN
      FOR i:=0 TO 9 DO XYplane.Dot(cx+i,cy,XYplane.erase) END;
      INC(cy);
    END;
    SpriteSetzen(s,cx,cy);
  UNTIL (cx=bx) & (cy=by);
END SpriteBewegen;

PROCEDURE SpriteDrehen*(anzahl:INTEGER; VAR s:sprite);
VAR a,i,j:INTEGER;
  t:sprite;
BEGIN
  FOR a:=1 TO anzahl DO
    t:=s;
    FOR j:=0 TO 9 DO
      FOR i:=0 TO 9 DO
        s[j,9-i]:=t[i,j]
      END
    END
  END
END SpriteDrehen;

PROCEDURE SpriteEinfuegen*(s:sprite; x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      IF s[i,j] & (~XYplane.IsDot(x+i,y+j)) THEN XYplane.Dot(x+i,y+j,XYplane.draw) END
    END
  END
END SpriteEinfuegen;

PROCEDURE Schreiben*(ausgabe:ARRAY OF CHAR; laenge,x,y:INTEGER);
VAR i,c:INTEGER;
BEGIN
  FOR i:=0 TO laenge-1 DO
    c:=ORD(ausgabe[i]);
    IF (c>=48) & (c<=57) THEN
      SpriteSetzen(zahlen[c-48],x+10*i,y);
    END;
    IF c=58 THEN
      SpriteSetzen(satzzeichen[c-58],x+10*i,y);
    END;
    IF c=33 THEN
      SpriteSetzen(satzzeichen[c-32],x+10*i,y);
    END;
    IF (c>=65) & (c<=91) THEN
      SpriteSetzen(buchstaben[c+1-65],x+10*i,y);
    END;
    IF c=32 THEN
      SpriteLoeschen(x+10*i,y);
    END;
  END;
END Schreiben;

PROCEDURE ZahlSchreiben*(zahl:LONGINT; x,y:INTEGER);
VAR i,zaehler:INTEGER;
BEGIN
  zaehler:=0;
  WHILE zahl>0 DO
    i:=SHORT(zahl-10*(ENTIER(zahl/10)));
    zahl:=ENTIER(zahl/10);
    SpriteSetzen(zahlen[i],x-10*zaehler,y);
    INC(zaehler);
  END;
END ZahlSchreiben;

PROCEDURE InitZahlen;
VAR i,j:INTEGER;
BEGIN
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      zahlen[1,i,j]:=FALSE;
    END;
  END;
  FOR j:=1 TO 8 DO
    FOR i:=0 TO 1 DO
      zahlen[0,j,i]:=TRUE;
      zahlen[0,j,9-i]:=TRUE;
      zahlen[0,i+1,j]:=TRUE;
      zahlen[0,8-i,j]:=TRUE;
    END;
  END;
  FOR i:=0 TO 9 DO
    zahlen[1,4,i]:=TRUE;
    zahlen[1,5,i]:=TRUE;
  END;
  FOR i:=1 TO 8 DO
    FOR j:=0 TO 1 DO
      zahlen[2,i,j]:=TRUE;
      zahlen[2,i,4+j]:=TRUE;
      zahlen[2,i,9-j]:=TRUE;
    END;
  END;
  zahlen[2,1,2]:=TRUE; zahlen[2,2,2]:=TRUE; zahlen[2,1,3]:=TRUE; zahlen[2,2,3]:=TRUE;
  zahlen[2,7,6]:=TRUE; zahlen[2,8,6]:=TRUE; zahlen[2,7,7]:=TRUE; zahlen[2,8,7]:=TRUE;
  FOR i:=1 TO 8 DO
    FOR j:=0 TO 1 DO
      zahlen[3,i,j]:=TRUE;
      zahlen[3,i,4+j]:=TRUE;
      zahlen[3,i,9-j]:=TRUE;
      zahlen[3,8-j,i]:=TRUE;
    END;
  END;
  FOR i:=0 TO 1 DO
    FOR j:=0 TO 9 DO
      zahlen[4,7+i,j]:=TRUE;
    END;
    FOR j:=1 TO 8 DO
      zahlen[4,j,4+i]:=TRUE;
    END;
    FOR j:=4 TO 9 DO
      zahlen[4,1+i,j]:=TRUE;
    END;
  END;
  FOR i:=1 TO 8 DO
    FOR j:=0 TO 1 DO
      zahlen[5,i,j]:=TRUE;
      zahlen[5,i,4+j]:=TRUE;
      zahlen[5,i,9-j]:=TRUE;
    END;
  END;
  zahlen[5,8,2]:=TRUE; zahlen[5,7,2]:=TRUE; zahlen[5,8,3]:=TRUE; zahlen[5,7,3]:=TRUE;
  zahlen[5,2,6]:=TRUE; zahlen[5,1,6]:=TRUE; zahlen[5,2,7]:=TRUE; zahlen[5,1,7]:=TRUE;
  zahlen[6]:=zahlen[2];
  FOR i:=0 TO 1 DO
    FOR j:=0 TO 1 DO
      zahlen[6,8-i,2+j]:=TRUE;
      zahlen[6,1+i,6+j]:=TRUE;
      zahlen[6,8-i,6+j]:=FALSE;
    END;
  END;
  FOR i:=0 TO 1 DO
    FOR j:=0 TO 9 DO
      zahlen[7,8-i,j]:=TRUE;
    END;
    FOR j:=1 TO 8 DO
      zahlen[7,j,9-i]:=TRUE;
    END;
  END;
  zahlen[8]:=zahlen[6];
  zahlen[8,7,6]:=TRUE; zahlen[8,8,6]:=TRUE; zahlen[8,7,7]:=TRUE; zahlen[8,8,7]:=TRUE;
  zahlen[9]:=zahlen[3];
  zahlen[9,1,6]:=TRUE; zahlen[9,2,6]:=TRUE; zahlen[9,1,7]:=TRUE; zahlen[9,2,7]:=TRUE; 
END InitZahlen;

PROCEDURE InitBuchstaben;
VAR i,j,k:INTEGER;
BEGIN
  FOR k:=0 TO 26 DO
    FOR j:=0 TO 9 DO
      FOR i:=0 TO 9 DO
        buchstaben[k,i,j]:=FALSE;
      END;
    END;
  END;
                                        (* A *)
  FOR i:=0 TO 9 DO
    buchstaben[1,1,i]:=TRUE; buchstaben[1,2,i]:=TRUE;
    buchstaben[1,7,i]:=TRUE; buchstaben[1,8,i]:=TRUE;
  END;
  FOR i:=3 TO 6 DO
    buchstaben[1,i,4]:=TRUE; buchstaben[1,i,5]:=TRUE;
    buchstaben[1,i,8]:=TRUE; buchstaben[1,i,9]:=TRUE;
  END;
                                        (* B *)
  buchstaben[2]:=zahlen[8];
  buchstaben[2,8,0]:=FALSE; buchstaben[2,8,1]:=FALSE;
  buchstaben[2,8,4]:=FALSE; buchstaben[2,8,5]:=FALSE;
  buchstaben[2,8,8]:=FALSE; buchstaben[2,8,9]:=FALSE;
                                        (* C *)
  buchstaben[3]:=zahlen[0];
  FOR i:=2 TO 7 DO
    buchstaben[3,7,i]:=FALSE; buchstaben[3,8,i]:=FALSE;
  END;
                                        (* D *)
  buchstaben[4]:=zahlen[0];
  FOR i:=0 TO 2 DO
    buchstaben[4,8,i]:=FALSE; buchstaben[4,8,9-i]:=FALSE;
  END;
  buchstaben[4,7,0]:=FALSE; buchstaben[4,7,9]:=FALSE;
  buchstaben[4,6,2]:=TRUE; buchstaben[4,6,7]:=TRUE;
                                        (* E *)
  buchstaben[5]:=zahlen[3];
  SpriteDrehen(2,buchstaben[5]);
                                        (* F *)
  FOR i:=0 TO 9 DO
    buchstaben[6,1,i]:=TRUE; buchstaben[6,2,i]:=TRUE;
    IF i<8 THEN
      buchstaben[6,i+1,4]:=TRUE; buchstaben[6,i+1,5]:=TRUE;
      buchstaben[6,i+1,8]:=TRUE; buchstaben[6,i+1,9]:=TRUE;
    END;
  END;
                                        (* G *)
  buchstaben[7]:=zahlen[6];
  buchstaben[7,3,4]:=FALSE; buchstaben[7,4,4]:=FALSE;
  buchstaben[7,3,5]:=FALSE; buchstaben[7,4,5]:=FALSE;
                                        (* H *)
  FOR i:=0 TO 9 DO
    buchstaben[8,1,i]:=TRUE; buchstaben[8,2,i]:=TRUE;
    buchstaben[8,7,i]:=TRUE; buchstaben[8,8,i]:=TRUE;
  END;
  FOR i:=3 TO 6 DO
    buchstaben[8,i,4]:=TRUE; buchstaben[8,i,5]:=TRUE;
  END;
                                        (* I *)
  FOR i:=0 TO 9 DO
    buchstaben[9,4,i]:=TRUE; buchstaben[9,5,i]:=TRUE;
  END;
  buchstaben[10]:=buchstaben[9];
  FOR i:=1 TO 3 DO
    buchstaben[10,i,0]:=TRUE; buchstaben[10,i,1]:=TRUE;
  END;
                                        (* K *)
  FOR i:=0 TO 9 DO
    buchstaben[11,1,i]:=TRUE; buchstaben[11,2,i]:=TRUE;
  END;
  buchstaben[11,3,4]:=TRUE; buchstaben[11,3,5]:=TRUE;
  buchstaben[11,4,3]:=TRUE; buchstaben[11,4,4]:=TRUE;
  buchstaben[11,4,5]:=TRUE; buchstaben[11,4,6]:=TRUE;
  buchstaben[11,5,2]:=TRUE; buchstaben[11,5,3]:=TRUE;
  buchstaben[11,5,6]:=TRUE; buchstaben[11,5,7]:=TRUE;
  buchstaben[11,6,1]:=TRUE; buchstaben[11,6,2]:=TRUE;
  buchstaben[11,6,7]:=TRUE; buchstaben[11,6,8]:=TRUE;
  buchstaben[11,7,0]:=TRUE; buchstaben[11,7,1]:=TRUE;
  buchstaben[11,7,8]:=TRUE; buchstaben[11,7,9]:=TRUE;
  buchstaben[11,8,0]:=TRUE; buchstaben[11,8,9]:=TRUE;
                                        (* L *)
  buchstaben[12]:=zahlen[7];
  SpriteDrehen(2,buchstaben[12]);
                                        (* M *)
  buchstaben[13]:=buchstaben[8];
  buchstaben[13,3,4]:=FALSE; buchstaben[13,3,5]:=FALSE;
  buchstaben[13,3,6]:=TRUE; buchstaben[13,3,7]:=TRUE;
  buchstaben[13,6,4]:=FALSE; buchstaben[13,6,5]:=FALSE;
  buchstaben[13,6,6]:=TRUE; buchstaben[13,6,7]:=TRUE;
                                        (* N *)
  buchstaben[14]:=buchstaben[8];
  buchstaben[14,3,4]:=FALSE; buchstaben[14,3,5]:=FALSE;
  buchstaben[14,3,6]:=TRUE; buchstaben[14,3,7]:=TRUE;
  buchstaben[14,6,2]:=TRUE; buchstaben[14,6,3]:=TRUE;
  buchstaben[14,6,4]:=FALSE; buchstaben[14,6,5]:=FALSE;
                                        (* O *)
  buchstaben[15]:=zahlen[0];
                                        (* P *)
  buchstaben[16]:=buchstaben[6];
  buchstaben[16,7,7]:=TRUE; buchstaben[16,7,6]:=TRUE;
  buchstaben[16,8,7]:=TRUE; buchstaben[16,8,6]:=TRUE;
                                        (* Q *)
  buchstaben[17]:=zahlen[0];
  buchstaben[17,5,0]:=FALSE; buchstaben[17,6,0]:=FALSE;
  buchstaben[17,5,1]:=FALSE; buchstaben[17,6,1]:=FALSE;
  buchstaben[17,5,2]:=TRUE; buchstaben[17,6,2]:=TRUE;
  buchstaben[17,5,3]:=TRUE; buchstaben[17,6,3]:=TRUE;
  buchstaben[17,7,2]:=FALSE; buchstaben[17,8,2]:=FALSE;
  buchstaben[17,7,3]:=FALSE; buchstaben[17,8,3]:=FALSE;
                                        (* R *)
  buchstaben[18]:=buchstaben[16];
  buchstaben[18,4,3]:=TRUE; buchstaben[18,5,3]:=TRUE;
  buchstaben[18,5,2]:=TRUE; buchstaben[18,6,2]:=TRUE;
  buchstaben[18,6,1]:=TRUE; buchstaben[18,7,1]:=TRUE;
  buchstaben[18,7,0]:=TRUE; buchstaben[18,8,0]:=TRUE;
                                        (* S *)
  buchstaben[19]:=zahlen[5];
                                        (* T *)
  FOR i:=0 TO 9 DO
    buchstaben[20,4,i]:=TRUE; buchstaben[20,5,i]:=TRUE;
    IF (i>0) & (i<9) THEN
      buchstaben[20,i,8]:=TRUE; buchstaben[20,i,9]:=TRUE;
    END;
  END;
                                        (* U *)
  buchstaben[21]:=buchstaben[12];
  FOR i:=2 TO 9 DO
    buchstaben[21,7,i]:=TRUE; buchstaben[21,8,i]:=TRUE;
  END;
                                        (* V *)
  FOR i:=5 TO 9 DO
    buchstaben[22,1,i]:=TRUE; buchstaben[22,2,i]:=TRUE;
    buchstaben[22,7,i]:=TRUE; buchstaben[22,8,i]:=TRUE;
  END;
  buchstaben[22,2,3]:=TRUE; buchstaben[22,2,4]:=TRUE;
  buchstaben[22,7,3]:=TRUE; buchstaben[22,7,4]:=TRUE;
  buchstaben[22,3,3]:=TRUE; buchstaben[22,3,4]:=TRUE;
  buchstaben[22,6,3]:=TRUE; buchstaben[22,6,4]:=TRUE;
  buchstaben[22,3,2]:=TRUE; buchstaben[22,4,2]:=TRUE;
  buchstaben[22,5,2]:=TRUE; buchstaben[22,5,2]:=TRUE;
  buchstaben[22,4,1]:=TRUE; buchstaben[22,5,1]:=TRUE;
  buchstaben[22,4,0]:=TRUE; buchstaben[22,5,0]:=TRUE;
                                        (* W *)
  buchstaben[23]:=buchstaben[13];
  SpriteDrehen(2,buchstaben[23]);
                                        (* X *)
  buchstaben[24,1,0]:=TRUE; buchstaben[24,2,0]:=TRUE;
  buchstaben[24,1,1]:=TRUE; buchstaben[24,2,1]:=TRUE;
  buchstaben[24,2,2]:=TRUE; buchstaben[24,3,2]:=TRUE;
  buchstaben[24,3,3]:=TRUE; buchstaben[24,4,3]:=TRUE;
  buchstaben[24,4,4]:=TRUE;
  FOR j:=0 TO 4 DO
    FOR i:=0 TO 4 DO
      buchstaben[24,9-i,j]:=buchstaben[24,i,j];
      buchstaben[24,i,9-j]:=buchstaben[24,i,j];
      buchstaben[24,9-i,9-j]:=buchstaben[24,i,j];
    END;
  END;
                                        (* Y *)
  FOR i:=0 TO 6 DO
    buchstaben[25,4,i]:=TRUE; buchstaben[25,5,i]:=TRUE;
  END;
  buchstaben[25,3,6]:=TRUE; buchstaben[25,6,6]:=TRUE;
  buchstaben[25,2,7]:=TRUE; buchstaben[25,3,7]:=TRUE;
  buchstaben[25,6,7]:=TRUE; buchstaben[25,7,7]:=TRUE;
  buchstaben[25,1,8]:=TRUE; buchstaben[25,2,8]:=TRUE;
  buchstaben[25,7,8]:=TRUE; buchstaben[25,8,8]:=TRUE;
  buchstaben[25,1,9]:=TRUE; buchstaben[25,2,9]:=TRUE;
  buchstaben[25,7,9]:=TRUE; buchstaben[25,8,9]:=TRUE;
                                        (* Z *)
  FOR i:=1 TO 8 DO
    buchstaben[26,i,0]:=TRUE; buchstaben[26,i,1]:=TRUE;
    buchstaben[26,i,8]:=TRUE; buchstaben[26,i,9]:=TRUE;
  END;
  buchstaben[26,2,2]:=TRUE; buchstaben[26,3,2]:=TRUE;
  buchstaben[26,3,3]:=TRUE; buchstaben[26,4,3]:=TRUE;
  buchstaben[26,4,4]:=TRUE; buchstaben[26,5,4]:=TRUE;
  buchstaben[26,4,5]:=TRUE; buchstaben[26,5,5]:=TRUE;
  buchstaben[26,5,6]:=TRUE; buchstaben[26,6,6]:=TRUE;
  buchstaben[26,6,7]:=TRUE; buchstaben[26,7,7]:=TRUE;
END InitBuchstaben;

PROCEDURE InitSatzzeichen;
VAR i,j,k:INTEGER;
BEGIN
  FOR k:=0 TO 0 DO
    FOR j:=0 TO 9 DO
      FOR i:=0 TO 9 DO
        satzzeichen[k,i,j]:=FALSE;
      END;
    END;
  END;
                                        (* : *)
  satzzeichen[0,4,2]:=TRUE; satzzeichen[0,5,2]:=TRUE;
  satzzeichen[0,4,3]:=TRUE; satzzeichen[0,5,3]:=TRUE;
  satzzeichen[0,4,6]:=TRUE; satzzeichen[0,5,6]:=TRUE;
  satzzeichen[0,4,7]:=TRUE; satzzeichen[0,5,7]:=TRUE;
                                        (* ! *)
  satzzeichen[1]:=buchstaben[9];
  satzzeichen[1,4,2]:=FALSE; satzzeichen[1,5,2]:=FALSE;
  satzzeichen[1,4,3]:=FALSE; satzzeichen[1,5,3]:=FALSE;
END InitSatzzeichen;

BEGIN
  InitZahlen;
  InitBuchstaben;
  InitSatzzeichen;
END Grafik.
