MODULE PacMan;

(* (C) Copyright 1996 by Roland Brand, Aarau *)

IMPORT XYplane := oocXYplane ,Out := Console ,Grafik,RandomNumbers := ethRandomNumbers;

TYPE figur=RECORD
      PosX,PosY,Richtung,Blick:INTEGER;
    END;

CONST stop=0;
      links=1;
      rechts=2;
      hoch=3;
      runter=4;
      Bremse=100;

VAR Feld:ARRAY 39,25 OF INTEGER;
  pcman,geistli,punkt,linie,kreuzung,ecke:Grafik.sprite;
  pcm:figur;
  geist: ARRAY 4 OF figur;
  score:LONGINT;
  AnzPunkte:INTEGER;

PROCEDURE Initialisieren;
VAR i,j:INTEGER;
BEGIN
  XYplane.Clear;
  score:=0;
  FOR j:=0 TO 24 DO
    FOR i:=0 TO 38 DO
      Feld[i,j]:=0;
    END;
  END;
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      pcman[i,j]:=FALSE;
      punkt[i,j]:=FALSE;
      linie[i,j]:=FALSE;
      kreuzung[i,j]:=FALSE;
      ecke[i,j]:=FALSE;
    END;
  END;
  pcman[4,0]:=TRUE; pcman[5,0]:=TRUE;
  FOR i:=3 TO 7 DO pcman[i,1]:=TRUE END;
  FOR i:=2 TO 9 DO pcman[i,2]:=TRUE END;
  FOR i:=1 TO 7 DO pcman[i,3]:=TRUE END;
  FOR i:=0 TO 6 DO pcman[i,4]:=TRUE END;
  FOR i:=0 TO 6 DO pcman[i,5]:=TRUE END;
  FOR i:=1 TO 7 DO pcman[i,6]:=TRUE END;
  FOR i:=2 TO 9 DO pcman[i,7]:=TRUE END;
  FOR i:=3 TO 7 DO pcman[i,8]:=TRUE END;
  pcman[4,9]:=TRUE; pcman[5,9]:=TRUE;
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 9 DO
      geistli[i,j]:=TRUE;
    END;
  END;
  FOR i:=0 TO 3 DO
    geistli[i,9]:=FALSE;
    geistli[9-i,9]:=FALSE;
  END;
  geistli[0,8]:=FALSE; geistli[1,8]:=FALSE; geistli[8,8]:=FALSE; geistli[9,8]:=FALSE;
  geistli[0,7]:=FALSE; geistli[9,7]:=FALSE;
  geistli[3,6]:=FALSE; geistli[6,6]:=FALSE;
  geistli[2,1]:=FALSE; geistli[6,1]:=FALSE;
  FOR i:=1 TO 3 DO
    geistli[i,0]:=FALSE;
    geistli[9-i,0]:=FALSE;
  END;
  Feld[1,1]:=1;
  punkt[4,4]:=TRUE; punkt[5,4]:=TRUE; punkt[4,5]:=TRUE; punkt[5,5]:=TRUE;
  FOR i:=0 TO 9 DO
    linie[i,4]:=TRUE;
    linie[i,5]:=TRUE;
    kreuzung[i,4]:=TRUE;
    kreuzung[i,5]:=TRUE;
    kreuzung[4,i]:=TRUE;
    kreuzung[5,i]:=TRUE;
  END;
  FOR i:=0 TO 5 DO
    ecke[4,i]:=TRUE;
    ecke[5,i]:=TRUE;
    ecke[9-i,4]:=TRUE;
    ecke[9-i,5]:=TRUE;
  END;
  pcm.Blick:=rechts;
END Initialisieren;

PROCEDURE Bitmuster(a,b:INTEGER):BOOLEAN;
(* prueft ob das b. Bit in a gesetzt ist und gibt in dem Fall true zurueck *)
VAR c:INTEGER;
BEGIN
  IF b<0 THEN
    Out.String("Fehler im Programm: Procedure Bitmuster");
    HALT(35);
  END;
  IF a<ASH(1,b) THEN RETURN FALSE END;
  c:=a;
  REPEAT
    IF c<ASH(1,b) THEN RETURN FALSE END;
    IF (c>=ASH(1,b)) & (c<ASH(1,b+1)) THEN RETURN TRUE END;
    c:=c-SHORT(ASH(1,b+1));
  UNTIL c<0; 
  RETURN FALSE;
END Bitmuster;

PROCEDURE Zeichnen;
VAR i,j,x,y:INTEGER;
BEGIN
  FOR j:=0 TO 24 DO
    y:=400-j*10;
    FOR i:=0 TO 38 DO
      x:=10+i*10;
      IF Bitmuster(Feld[i,j],7) THEN
        IF Bitmuster(Feld[i,j],6) THEN Grafik.SpriteSetzen(kreuzung,x,y)
        ELSE Grafik.SpriteSetzen(linie,x,y)
        END;
      ELSIF Bitmuster(Feld[i,j],6) THEN
        Grafik.SpriteDrehen(1,linie);
        Grafik.SpriteSetzen(linie,x,y);
        Grafik.SpriteDrehen(1,linie);
      ELSIF Bitmuster(Feld[i,j],5) THEN
        IF i=0 THEN
          IF j=0 THEN Grafik.SpriteSetzen(ecke,x,y)
          ELSIF ~Bitmuster(Feld[i,j-1],6) THEN Grafik.SpriteSetzen(ecke,x,y)
          ELSE
            Grafik.SpriteDrehen(3,ecke);
            Grafik.SpriteSetzen(ecke,x,y);
            Grafik.SpriteDrehen(1,ecke);
          END;
        ELSE
          IF j=0 THEN
            IF ~Bitmuster(Feld[i-1,j],7) THEN Grafik.SpriteSetzen(ecke,x,y)
            ELSE
              Grafik.SpriteDrehen(1,ecke);
              Grafik.SpriteSetzen(ecke,x,y);
              Grafik.SpriteDrehen(3,ecke);
            END;
          ELSIF Bitmuster(Feld[i,j+1],6) THEN
            IF Bitmuster(Feld[i-1,j],7) THEN
              Grafik.SpriteDrehen(1,ecke);
              Grafik.SpriteSetzen(ecke,x,y);
              Grafik.SpriteDrehen(3,ecke);
            ELSE Grafik.SpriteSetzen(ecke,x,y)
            END;
          ELSE
            Grafik.SpriteDrehen(2,ecke);
            Grafik.SpriteSetzen(ecke,x,y);
            Grafik.SpriteDrehen(2,ecke);
          END;
        END;
      ELSIF Bitmuster(Feld[i,j],3) THEN Grafik.SpriteSetzen(punkt,x,y);
      END;
    END;
  END;
END Zeichnen;

PROCEDURE Level1;
VAR i,j:INTEGER;
BEGIN
  RandomNumbers.InitSeed(93247856);
  Initialisieren;
  Feld[0,0]:=32;
  FOR i:=1 TO 37 DO 
    Feld[i,0]:=128;
    Feld[i,2]:=128;
    Feld[i,4]:=128;
    Feld[i,6]:=128;
    Feld[i,16]:=128;
    Feld[i,20]:=128;
    Feld[i,22]:=128;
    Feld[i,24]:=128;
  END;
  Feld[18,0]:=32; Feld[19,0]:=0; Feld[20,0]:=32; Feld[38,0]:=32;
  FOR i:=1 TO 5 DO
    Feld[0,i]:=64;
    Feld[38,i]:=64;
  END;
  Feld[18,1]:=64; Feld[20,1]:=64;
  Feld[1,2]:=0; Feld[9,2]:=0; Feld[17,2]:=0; Feld[18,2]:=192; Feld[20,2]:=192;
  Feld[21,2]:=0; Feld[29,2]:=0; Feld[37,2]:=0;
  Feld[1,4]:=0; Feld[9,4]:=0; Feld[10,4]:=32; Feld[12,4]:=32; Feld[13,4]:=0;
  Feld[19,4]:=192; Feld[25,4]:=0; Feld[26,4]:=192; Feld[28,4]:=192; Feld[29,4]:=0;
  Feld[37,4]:=0;
  FOR i:=5 TO 9 DO
    Feld[10,i]:=64;
    Feld[28,i]:=64;
  END;
  Feld[12,5]:=64; Feld[19,5]:=64; Feld[26,5]:=64;
  Feld[0,6]:=32; Feld[8,6]:=32; Feld[9,6]:=0; Feld[10,6]:=64; Feld[11,6]:=0;
  Feld[12,6]:=192; Feld[17,6]:=192; Feld[18,6]:=0; Feld[19,6]:=64;Feld[20,6]:=0;
  Feld[21,6]:=192; Feld[26,6]:=192; Feld[27,6]:=0; Feld[28,6]:=64; Feld[29,6]:=0;
  Feld[30,6]:=192; Feld[38,6]:=192;
  FOR i:=7 TO 9 DO
    Feld[8,i]:=64;
    Feld[12,i]:=64;
    Feld[26,i]:=64;
    Feld[30,i]:=64;
  END;
  Feld[12,7]:=192; Feld[13,7]:=128; Feld[14,7]:=128; Feld[15,7]:=128; Feld[16,7]:=128;
  Feld[17,7]:=192; Feld[19,7]:=64; Feld[21,7]:=192; Feld[22,7]:=128; Feld[23,7]:=128;
  Feld[24,7]:=128; Feld[25,7]:=128; Feld[26,7]:=192;
  Feld[14,9]:=192; 
  FOR i:=15 TO 23 DO Feld[i,9]:=128 END;
  Feld[19,9]:=0; Feld[24,9]:=192;
  FOR i:=0 TO 7 DO
    Feld[i,10]:=128;
    Feld[i+31,10]:=128;
  END;
  Feld[8,10]:=192; Feld[10,10]:=192; Feld[11,10]:=128; Feld[12,10]:=192;
  Feld[14,10]:=64; Feld[24,10]:=64; Feld[26,10]:=192; Feld[27,10]:=128;
  Feld[28,10]:=192; Feld[30,10]:=192;
  Feld[14,11]:=64; Feld[24,11]:=64;
  FOR i:=0 TO 38 DO
    Feld[i,12]:=Feld[i,10];
    Feld[i,13]:=Feld[i,9];
    Feld[i,14]:=Feld[i,8];
    Feld[i,15]:=Feld[i,9];
    Feld[i,18]:=Feld[i,2];
  END;
  Feld[19,13]:=128;
  Feld[19,15]:=128;
  Feld[0,16]:=192; Feld[8,16]:=192; Feld[9,16]:=0; Feld[10,16]:=192; Feld[12,16]:=192;
  Feld[13,16]:=0; Feld[14,16]:=192; Feld[18,16]:=192; Feld[19,16]:=0; Feld[20,16]:=192;
  Feld[24,16]:=192; Feld[25,16]:=0; Feld[26,16]:=192; Feld[28,16]:=192;
  Feld[29,16]:=0; Feld[30,16]:=192; Feld[38,16]:=192;
  Feld[0,17]:=64; Feld[18,17]:=64; Feld[20,17]:=64; Feld[38,17]:=64;
  Feld[5,18]:=192; Feld[8,18]:=192; Feld[30,18]:=192; Feld[33,18]:=192;
  Feld[0,19]:=64; Feld[5,19]:=64; Feld[8,19]:=64; Feld[30,19]:=64; Feld[33,19]:=64;
  Feld[38,19]:=64;
  Feld[0,20]:=192; Feld[4,20]:=0; Feld[5,20]:=192; Feld[8,20]:=192; Feld[9,20]:=0;
  Feld[10,20]:=192; Feld[13,20]:=192; Feld[14,20]:=0; Feld[18,20]:=192;
  Feld[20,20]:=192; Feld[24,20]:=0; Feld[25,20]:=192; Feld[28,20]:=192;
  Feld[29,20]:=0; Feld[30,20]:=192; Feld[33,20]:=192; Feld[34,20]:=0; Feld[38,20]:=192;
  Feld[0,21]:=64; Feld[10,21]:=64; Feld[13,21]:=64; Feld[18,21]:=64; Feld[20,21]:=64;
  Feld[25,21]:=64; Feld[28,21]:=64; Feld[38,21]:=64;
  Feld[0,22]:=64; Feld[1,22]:=0; Feld[10,22]:=192; Feld[13,22]:=192; Feld[17,22]:=0;
  Feld[18,22]:=192; Feld[20,22]:=192; Feld[21,22]:=0; Feld[25,22]:=192;
  Feld[28,22]:=192; Feld[37,22]:=0; Feld[38,22]:=64;
  Feld[0,23]:=64; Feld[38,23]:=64;
  Feld[0,24]:=192; Feld[38,24]:=192;
  FOR j:=0 TO 24 DO
    FOR i:=0 TO 38 DO
      IF Feld[i,j]=0 THEN
        Feld[i,j]:=8;
      END
    END
  END;
  Feld[19,0]:=0; Feld[19,1]:=0;
  FOR j:=7 TO 9 DO
    FOR i:=0 TO 7 DO
      Feld[i,j]:=0;
      Feld[38-i,j]:=0;
      Feld[i,j+6]:=0;
      Feld[38-i,j+6]:=0;
    END;
  END;
  FOR i:=5 TO 9  DO
    Feld[11,i]:=0;
    Feld[27,i]:=0;
  END;
  Feld[11,13]:=0; Feld[11,14]:=0; Feld[11,15]:=0; Feld[27,13]:=0; Feld[27,14]:=0; Feld[27,15]:=0;
  Feld[6,19]:=0; Feld[7,19]:=0; Feld[19,21]:=0; Feld[11,21]:=0; Feld[12,21]:=0; Feld[26,21]:=0;
  Feld[27,21]:=0; Feld[31,19]:=0; Feld[32,19]:=0; Feld[19,16]:=0; Feld[19,17]:=0;
  FOR j:=10 TO 12 DO
    FOR i:=15 TO 23 DO
      Feld[i,j]:=0;
    END;
  END;
  Zeichnen;
  pcm.PosX:=19; pcm.PosY:=19;
  Feld[pcm.PosX,pcm.PosY]:=1;
  Grafik.SpriteSetzen(pcman,10+pcm.PosX*10,400-pcm.PosY*10);
  geist[0].PosX:=15; geist[0].PosY:=8; geist[0].Richtung:=rechts; geist[0].Blick:=rechts;
  geist[1].PosX:=1; geist[1].PosY:=1; geist[1].Richtung:=rechts; geist[1].Blick:=rechts;
  geist[2].PosX:=37; geist[2].PosY:=1; geist[2].Richtung:=links; geist[2].Blick:=links;
  geist[3].PosX:=19; geist[3].PosY:=12; geist[3].Richtung:=hoch; geist[3].Blick:=hoch;
  FOR i:=0 TO 3 DO
    Feld[geist[i].PosX,geist[i].PosY]:=10;
    Grafik.SpriteSetzen(geistli,10+geist[i].PosX*10,400-geist[i].PosY*10);
  END;
  Feld[geist[3].PosX,geist[3].PosY]:=2;
  AnzPunkte:=344;
END Level1;

PROCEDURE RichtungAnpassen(VAR s:Grafik.sprite; VAR f:figur);
BEGIN
  IF (f.Richtung#f.Blick) & (f.Richtung#stop) THEN
    IF f.Blick=rechts THEN
      IF f.Richtung=runter THEN Grafik.SpriteDrehen(1,s)
      ELSIF f.Richtung=links THEN Grafik.SpriteDrehen(2,s)
      ELSIF f.Richtung=hoch THEN Grafik.SpriteDrehen(3,s)
      END
    ELSIF f.Blick=runter THEN
      IF f.Richtung=rechts THEN Grafik.SpriteDrehen(3,s)
      ELSIF f.Richtung=links THEN Grafik.SpriteDrehen(1,s)
      ELSIF f.Richtung=hoch THEN Grafik.SpriteDrehen(2,s)
      END
    ELSIF f.Blick=links THEN
      IF f.Richtung=rechts THEN Grafik.SpriteDrehen(2,s)
      ELSIF f.Richtung=runter THEN Grafik.SpriteDrehen(3,s)
      ELSIF f.Richtung=hoch THEN Grafik.SpriteDrehen(1,s)
      END
    ELSIF f.Blick=hoch THEN
      IF f.Richtung=rechts THEN Grafik.SpriteDrehen(1,s)
      ELSIF f.Richtung=runter THEN Grafik.SpriteDrehen(2,s)
      ELSIF f.Richtung=links THEN Grafik.SpriteDrehen(3,s)
      END
    END;
    f.Blick:=f.Richtung;
  END;
END RichtungAnpassen;

PROCEDURE RandHuepfen(s:Grafik.sprite; VAR f:figur; kennung:INTEGER):BOOLEAN;
VAR x,y:INTEGER;
  resultat:BOOLEAN;
BEGIN
  resultat:=FALSE;
  x:=10+f.PosX*10;
  y:=400-f.PosY*10;
  IF f.Richtung=links THEN
    IF f.PosX=0 THEN
      IF (Feld[38,f.PosY]=0) OR (Feld[38,f.PosY]=8) THEN
        Grafik.SpriteLoeschen(x,y);
        f.PosX:=38;
        x:=10+f.PosX*10;
        y:=400-f.PosY*10;
        Grafik.SpriteSetzen(s,x,y);
        Feld[f.PosX,f.PosY]:=kennung;
        resultat:=TRUE;
      ELSE 
        f.Richtung:=stop;
      END
    END
  ELSIF f.Richtung=rechts THEN
    IF f.PosX=38 THEN
      IF (Feld[0,f.PosY]=0) OR (Feld[0,f.PosY]=8) THEN
        Grafik.SpriteLoeschen(x,y);
        f.PosX:=0;
        x:=10+f.PosX*10;
        y:=400-f.PosY*10;
        Grafik.SpriteSetzen(s,x,y);
        Feld[f.PosX,f.PosY]:=kennung;
        resultat:=TRUE;
      ELSE f.Richtung:=stop
      END
    END
  ELSIF f.Richtung=hoch THEN
    IF f.PosY=0 THEN
      IF (Feld[f.PosX,24]=0) OR (Feld[f.PosX,24]=8) THEN
        Grafik.SpriteLoeschen(x,y);
        f.PosY:=24;
        x:=10+f.PosX*10;
        y:=400-f.PosY*10;
        Grafik.SpriteSetzen(s,x,y);
        Feld[f.PosX,f.PosY]:=kennung;
        resultat:=TRUE;
      ELSE f.Richtung:=stop
      END
    END
  ELSIF f.Richtung=runter THEN
    IF f.PosY=24 THEN
      IF (Feld[f.PosX,0]=0) OR (Feld[f.PosX,0]=8) THEN
        Grafik.SpriteLoeschen(x,y);
        f.PosY:=0;
        x:=10+f.PosX*10;
        y:=400-f.PosY*10;
        Grafik.SpriteSetzen(s,x,y);
        Feld[f.PosX,f.PosY]:=kennung;
        resultat:=TRUE;
      ELSE f.Richtung:=stop
      END
    END
  END;
  RETURN resultat;
END RandHuepfen;

PROCEDURE NeuePosition(VAR f:figur);
BEGIN
  IF f.Richtung=links THEN
    IF  ~((Bitmuster(Feld[f.PosX-1,f.PosY],7) OR Bitmuster(Feld[f.PosX-1,f.PosY],6)) OR
      Bitmuster(Feld[f.PosX-1,f.PosY],5)) THEN DEC(f.PosX)
    ELSE f.Richtung:=stop
    END
  ELSIF f.Richtung=rechts THEN
    IF  ~((Bitmuster(Feld[f.PosX+1,f.PosY],7) OR Bitmuster(Feld[f.PosX+1,f.PosY],6)) OR
      (Bitmuster(Feld[f.PosX+1,f.PosY],5))) THEN INC(f.PosX)
    ELSE f.Richtung:=stop
    END
  ELSIF f.Richtung=hoch THEN
    IF ~((Bitmuster(Feld[f.PosX,f.PosY-1],7) OR Bitmuster(Feld[f.PosX,f.PosY-1],6)) OR
      Bitmuster(Feld[f.PosX,f.PosY-1],5)) THEN DEC(f.PosY)
    ELSE f.Richtung:=stop
    END
  ELSIF f.Richtung=runter THEN
    IF ~((Bitmuster(Feld[f.PosX,f.PosY+1],7) OR Bitmuster(Feld[f.PosX,f.PosY+1],6)) OR
      Bitmuster(Feld[f.PosX,f.PosY+1],5)) THEN INC(f.PosY)
    ELSE f.Richtung:=stop
    END
  END;
END NeuePosition;

PROCEDURE GeistliRichtung(VAR f:figur; VAR erwischt:BOOLEAN);
VAR zufall:INTEGER;
  fertig:BOOLEAN;
BEGIN
  fertig:=FALSE;
  DEC(Feld[f.PosX,f.PosY],2);
  zufall:=SHORT(ENTIER(10*RandomNumbers.Uniform()));
  IF (zufall<9) & (f.Richtung#stop) THEN
    IF RandHuepfen(geistli,f,2) THEN
      f.Richtung:=stop;
      RETURN;
    END;
    NeuePosition(f);
    erwischt:=Bitmuster(Feld[f.PosX,f.PosY],0);
    IF f.Richtung#stop THEN
      INC(Feld[f.PosX,f.PosY],2);
      fertig:=TRUE;
    END;
  END;
  IF ~fertig THEN
    REPEAT
      REPEAT
        zufall:=SHORT(ENTIER(10*RandomNumbers.Uniform()))
      UNTIL zufall<=4;
      f.Richtung:=zufall;
      IF RandHuepfen(geistli,f,2) THEN
        f.Richtung:=stop;
        RETURN;
       END;
      NeuePosition(f);
      erwischt:=Bitmuster(Feld[f.PosX,f.PosY],0);
    UNTIL f.Richtung#stop;
    INC(Feld[f.PosX,f.PosY],2);
  END;
END GeistliRichtung;

PROCEDURE Bewegen(VAR erwischt:BOOLEAN);
VAR ax,ay,bx,by,richtung:ARRAY 5 OF INTEGER;
  i,j:INTEGER;
  alt:ARRAY 5 OF figur;
BEGIN
  alt[0]:=pcm;
  ax[0]:=10+pcm.PosX*10;
  ay[0]:=400-pcm.PosY*10;
  richtung[0]:=pcm.Richtung;
  DEC(Feld[pcm.PosX,pcm.PosY]);
  RichtungAnpassen(pcman,pcm);
  IF RandHuepfen(pcman,pcm,1) THEN RETURN END;
  NeuePosition(pcm);
  erwischt:=Bitmuster(Feld[pcm.PosX,pcm.PosY],1);
  IF erwischt THEN RETURN END;
  INC(Feld[pcm.PosX,pcm.PosY]);
  IF Bitmuster(Feld[pcm.PosX,pcm.PosY],3) THEN
    DEC(Feld[pcm.PosX,pcm.PosY],8); 
    INC(score,10);
    DEC(AnzPunkte);
  END;
  FOR i:=1 TO 4 DO 
    richtung[i]:=stop;
    ax[i]:=0;
    ay[i]:=0;
    ax[i]:=10+geist[i-1].PosX*10;
    ay[i]:=400-geist[i-1].PosY*10;
    alt[i]:=geist[i-1];
    GeistliRichtung(geist[i-1],erwischt);
    IF erwischt THEN RETURN END;
    richtung[i]:=geist[i-1].Richtung;
  END;
  FOR j:=0 TO 9 DO
    FOR i:=0 TO 4 DO
      bx[i]:=ax[i];
      by[i]:=ay[i];
      IF richtung[i]=links THEN DEC(bx[i])
      ELSIF richtung[i]=rechts THEN INC(bx[i])
      ELSIF richtung[i]=hoch THEN INC(by[i])
      ELSIF richtung[i]=runter THEN DEC(by[i])
      END;
      IF (i=0) & (richtung[0]#stop) THEN 
        IF ~((alt[0].PosX=pcm.PosX) & (alt[0].PosY=pcm.PosY)) THEN
          Grafik.SpriteBewegen(pcman,ax[0],ay[0],bx[0],by[0],Bremse)
        END;
      ELSE
        IF richtung[i]#stop THEN
          Grafik.SpriteBewegen(geistli,ax[i],ay[i],bx[i],by[i],Bremse);
          IF Bitmuster(Feld[alt[i].PosX,alt[i].PosY],3) THEN
            Grafik.SpriteEinfuegen(punkt,10+alt[i].PosX*10,400-alt[i].PosY*10);
          END;
        END;
      END;
      ax[i]:=bx[i];
      ay[i]:=by[i];
    END;
  END;
END Bewegen;

PROCEDURE SpielStart;
VAR c:CHAR;
  abbruch:BOOLEAN;
BEGIN
  REPEAT
    c:=XYplane.Key();
  UNTIL c#CHR(0);
  IF c="4" THEN pcm.Richtung:=links;
  ELSIF c="6" THEN pcm.Richtung:=rechts;
  ELSIF c="8" THEN pcm.Richtung:=hoch;
  ELSIF c="2" THEN pcm.Richtung:=runter;
  ELSIF c=" " THEN pcm.Richtung:=stop;
  END;
  Grafik.Schreiben('PUNKTE:',7,250,420);
  Grafik.ZahlSchreiben(score,390,420);
  abbruch:=FALSE;
  REPEAT
    Bewegen(abbruch);
    IF abbruch THEN Grafik.Schreiben('ERWISCHT!',9,160,290) END;
    Grafik.ZahlSchreiben(score,390,420);
    IF AnzPunkte=99 THEN Grafik.SpriteSetzen(Grafik.buchstaben[0],10,420) END;
    IF AnzPunkte=9 THEN Grafik.SpriteSetzen(Grafik.buchstaben[0],20,420) END;
    Grafik.ZahlSchreiben(AnzPunkte,30,420);
    IF AnzPunkte<1 THEN
      abbruch:=TRUE;
      Grafik.Schreiben('!YOU WIN!',9,160,290);
    END;
    c:=XYplane.Key();
    IF c="4" THEN pcm.Richtung:=links;
    ELSIF c="6" THEN pcm.Richtung:=rechts;
    ELSIF c="8" THEN pcm.Richtung:=hoch;
    ELSIF c="2" THEN pcm.Richtung:=runter;
    ELSIF c=" " THEN pcm.Richtung:=stop;
    ELSIF c="q" THEN
      abbruch:=TRUE;
      Grafik.Schreiben('GAME OVER',9,160,290);
    END;
  UNTIL abbruch;
END SpielStart;

PROCEDURE Spielen*;
BEGIN
  XYplane.Open;
  Level1;
  SpielStart;
END Spielen;

BEGIN
   Spielen
END PacMan.
