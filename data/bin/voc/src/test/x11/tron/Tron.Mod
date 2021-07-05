MODULE Tron;

IMPORT In := compatIn, X:=oocXYplane;

(* Programmiert von Peter Brantschen, Version 1.00, 21. April 1996      
 Neue Features: - Tastatursteuerung nur noch links und rechts            
             - Spielstand zaehlen unter dem Logo                         

Verbesserungsvorschlaege an: INDIANA@EZINFO.VMSMAIL.ETHZ.CH 
                oder:   PBRANTSC@G26.ETHZ.CH

Tastatur: 
  Spieler1:
        a  ...  Drehung gegen den Uhrzeigersinn
        s  ...  Drehung mit dem Uhrzeigersinn
        d  ...  Turbo

  Spieler2:
        4  ...  Drehung gegen den Uhrzeigersinn
        5  ...  Drehung mit dem Uhrzeigersinn
        6  ...  Turbo

  p ... Pause
  q ... Quit 

Programmaufruf:

Games.Tron TEMPO

TEMPO ist eine Zahl zwischen 1 und 10

Gespielt wird BEST OF 51 *)

CONST links=10; rechts=350; unten=10; oben=300;
      x1start=100; y1start=100; x2start=260; y2start=100; Limit=51;

VAR SiegeSpieler1, SiegeSpieler2: INTEGER;

PROCEDURE LoescheBildschirm;

BEGIN
X.Clear;
END LoescheBildschirm;

PROCEDURE Linie(x1,x2,h,dicke: INTEGER);

VAR i: INTEGER;

BEGIN
WHILE x1<=x2 DO;
  FOR i:=0 TO (dicke-1) DO;
    X.Dot(x1,h+i,1);
  END;
  INC(x1);
END;
END Linie;

PROCEDURE Zwischenstand;

VAR i: INTEGER;

BEGIN
i:=0;
WHILE i<SiegeSpieler1 DO;
  Linie(60+2*i,60+2*i,330,5);
  INC(i)
END;
i:=0;
WHILE i<SiegeSpieler2  DO;
  Linie(60+2*i,60+2*i,320,5);
  INC(i)
END;
END Zwischenstand;

PROCEDURE Logo;

VAR i: INTEGER;

BEGIN
  (* T *)
  FOR i:=60 TO 110 DO; X.Dot(i,400,1); END;
  FOR i:=350 TO 400 DO; X.Dot(85,i,1); END;
  (* R *)
  FOR i:=350 TO 400 DO; X.Dot(120,i,1); END;
  FOR i:=120 TO 170 DO; X.Dot(i,400,1); END;
  FOR i:=120 TO 170 DO; X.Dot(i,375,1); END;
  FOR i:=375 TO 400 DO; X.Dot(170,i,1); END;
  FOR i:=1 TO 25 DO; X.Dot(145+i,375-i,1); END;
  (* O *)
  FOR i:=350 TO 400 DO; X.Dot(180,i,1); END;
  FOR i:=180 TO 230 DO; X.Dot(i,400,1); END;
  FOR i:=180 TO 230 DO; X.Dot(i,350,1); END;
  FOR i:=350 TO 400 DO; X.Dot(230,i,1); END;
  (* N *)
  FOR i:=350 TO 400 DO; X.Dot(240,i,1); END;
  FOR i:=1 TO 50 DO; X.Dot(240+i,400-i,1); END;
  FOR i:=350 TO 400 DO; X.Dot(290,i,1); END;
  (* unterstrichen *)
  FOR i:=60 TO 290 DO; X.Dot(i,345,1); END;  
  FOR i:=60 TO 290 DO; X.Dot(i,343,1); END;

END Logo;

PROCEDURE Signatur;

BEGIN;
  X.Dot(2,2,1);X.Dot(3,2,1); X.Dot(4,2,1); X.Dot(6,2,1);X.Dot(8,2,1); X.Dot(9,2,1); X.Dot(10,2,1); X.Dot(14,2,1); 
  X.Dot(19,2,1);X.Dot(20,2,1); X.Dot(21,2,1); X.Dot(23,2,1); X.Dot(24,2,1); X.Dot(25,2,1);
  X.Dot(3,3,1);X.Dot(6,3,1); X.Dot(8,3,1); X.Dot(9,3,1);X.Dot(11,3,1); X.Dot(14,3,1); X.Dot(21,3,1); X.Dot(23,3,1); 
  X.Dot(25,3,1);
  X.Dot(3,4,1);X.Dot(6,4,1); X.Dot(7,4,1); X.Dot(8,4,1);X.Dot(9,4,1); X.Dot(11,4,1); X.Dot(14,4,1); 
  X.Dot(19,4,1);X.Dot(20,4,1); X.Dot(21,4,1); X.Dot(23,4,1); X.Dot(24,4,1); X.Dot(25,4,1);
  X.Dot(3,5,1);X.Dot(6,5,1); X.Dot(7,5,1); X.Dot(8,5,1);X.Dot(9,5,1); X.Dot(11,5,1); X.Dot(13,5,1); X.Dot(15,5,1);
  X.Dot(19,5,1);X.Dot(21,5,1); X.Dot(23,5,1); 
  X.Dot(2,6,1);X.Dot(3,6,1); X.Dot(4,6,1); X.Dot(6,6,1);X.Dot(8,6,1); X.Dot(9,6,1); X.Dot(10,6,1); X.Dot(13,6,1); 
  X.Dot(15,6,1); X.Dot(17,6,1); X.Dot(19,6,1);X.Dot(20,6,1); X.Dot(21,6,1); X.Dot(23,6,1); X.Dot(24,6,1); X.Dot(25,6,1);
END Signatur;

PROCEDURE Tron*;

VAR key:CHAR; abbruch, malen,weiter: BOOLEAN;
x1,y1,xweiter1,yweiter1, Anzahl: INTEGER;
x2,y2,xweiter2,yweiter2, i: INTEGER;
imspiel1, imspiel2, pause, Ende: BOOLEAN;
Spieler1, Spieler2, Runde, Tempo1, Tempo2,langsam,schnell: INTEGER;

BEGIN;
X.Open;
Spieler1:=0; Spieler2:=0; Runde:=0; Ende:=FALSE; 
SiegeSpieler1:=0; SiegeSpieler2:=0;
In.Open;
In.Int(i);
IF i<1 THEN i:=1 END;
IF i>10 THEN i:=10 END;
langsam:=1000 DIV i;
schnell:=600 DIV i;
weiter:=TRUE;
WHILE Runde<Limit DO;
  WHILE ~weiter DO;
    IF X.Key()=" " THEN weiter:=TRUE; END;
  END;
  weiter:=FALSE;
  LoescheBildschirm;
  abbruch:=FALSE; x1:=x1start; y1:=y1start;
  Anzahl:=0; xweiter1:=0; yweiter1:=1;
  x2:=x2start; y2:=y2start; xweiter2:=0; yweiter2:=1;
  imspiel1:=TRUE; imspiel2:=TRUE; Tempo1:=langsam; Tempo2:=langsam;
  Linie(links,rechts,unten,1);
  Linie(links,rechts,oben,1);
  FOR i:=unten TO oben DO;
    Linie(links,links,i,1);
    Linie(rechts,rechts,i,1);
  END;
  Signatur;
  Zwischenstand;
  Logo;
  WHILE ~abbruch DO;
    pause:=FALSE;
    key:=X.Key();
    IF key="a" THEN 
      IF (xweiter1=-1) & (yweiter1=0) THEN xweiter1:=0;yweiter1:=-1;
      ELSIF (xweiter1=0) & (yweiter1=-1) THEN xweiter1:=1;yweiter1:=0;
      ELSIF (xweiter1=1) & (yweiter1=0) THEN xweiter1:=0;yweiter1:=1;
      ELSIF (xweiter1=0) & (yweiter1=1) THEN xweiter1:=-1;yweiter1:=0; END;
    END;
    IF key="s" THEN 
      IF (xweiter1=-1) & (yweiter1=0) THEN xweiter1:=0;yweiter1:=1;
      ELSIF (xweiter1=0) & (yweiter1=1) THEN xweiter1:=1;yweiter1:=0;
      ELSIF (xweiter1=1) & (yweiter1=0) THEN xweiter1:=0;yweiter1:=-1;
      ELSIF (xweiter1=0) & (yweiter1=-1) THEN xweiter1:=-1;yweiter1:=0; END;
    END;
    IF key="d" THEN 
      IF Tempo1=schnell THEN Tempo1:=langsam ELSE Tempo1 := schnell; END;
    END;
    IF key="4" THEN 
      IF (xweiter2=-1) & (yweiter2=0) THEN xweiter2:=0;yweiter2:=-1;
      ELSIF (xweiter2=0) & (yweiter2=-1) THEN xweiter2:=1;yweiter2:=0;
      ELSIF (xweiter2=1) & (yweiter2=0) THEN xweiter2:=0;yweiter2:=1;
      ELSIF (xweiter2=0) & (yweiter2=1) THEN xweiter2:=-1;yweiter2:=0; END;
    END;
    IF key="5" THEN 
      IF (xweiter2=-1) & (yweiter2=0) THEN xweiter2:=0;yweiter2:=1;
      ELSIF (xweiter2=0) & (yweiter2=1) THEN xweiter2:=1;yweiter2:=0;
      ELSIF (xweiter2=1) & (yweiter2=0) THEN xweiter2:=0;yweiter2:=-1;
      ELSIF (xweiter2=0) & (yweiter2=-1) THEN xweiter2:=-1;yweiter2:=0; END;
    END;
    IF key="6" THEN 
      IF Tempo2=schnell THEN Tempo2:=langsam ELSE Tempo2 := schnell; END;
    END;
    IF (Anzahl MOD Tempo1) = 0 THEN Linie(x1,x1,y1,1); END;
    IF (Anzahl MOD Tempo2) = 0 THEN Linie(x2,x2,y2,1); END;
    IF (Anzahl MOD Tempo2) = 0 THEN INC(x2,xweiter2); INC(y2,yweiter2); END;
    IF (Anzahl MOD Tempo1) = 0 THEN INC(x1,xweiter1); INC(y1,yweiter1); END;
    IF (Anzahl MOD Tempo1) = 0 THEN 
      IF X.IsDot(x1,y1) THEN 
        abbruch:=TRUE;
        imspiel1:=FALSE;
      END; 
    END;
    IF (Anzahl MOD Tempo2) = 0 THEN 
      IF X.IsDot(x2,y2) THEN 
        abbruch:=TRUE; 
        imspiel2:=FALSE;
      END; 
    END;  
    IF Anzahl=8000 THEN Anzahl:=0; END;
    IF key="q" THEN abbruch:=TRUE;Ende:=TRUE; END;
    IF key="p" THEN 
      WHILE ~pause DO;
        IF X.Key()=" " THEN pause:=TRUE; END;
      END;
    END;
    INC(Anzahl);
  END;
    IF ~imspiel1 THEN
      IF imspiel2 THEN INC(SiegeSpieler2); END;
    END;
    IF imspiel1 THEN
      IF ~imspiel2 THEN INC(SiegeSpieler1);
      END;
    END;
    IF Spieler1>Spieler2 THEN Runde:=Spieler1 ELSE Runde:=Spieler2;END;
    IF Ende THEN Runde:=Limit; END;
    Zwischenstand;
  END; 
END Tron;

BEGIN;
Tron
END Tron.
