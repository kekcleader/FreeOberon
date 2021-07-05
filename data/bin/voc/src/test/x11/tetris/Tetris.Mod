MODULE Tetris;

(* Peter Brantschen, 15.April 96 , Version 1.1*)
(* neuste Version vom 12. Dezember 1996, Version 1.2 *)
(* Neuerungen: Spielparameter sind ueber Konstantendeklariert, Zweispielermodus 
  bricht bei Limit-Linien ab, Pause-Funktion wurde eingefuehrt *)

IMPORT X:=oocXYplane, L:=Linie, In := compatIn, Out := Console, RN:=ethRandomNumbers, Ziffer, Oberon;

CONST 

(* Spielwerte : *)

  Schrittweite=10;
  Limit=20;
  ende="q";
  pause="p";
  endepause=" ";

(* Werte fuer Verzoegerung:

    Pentium 100: 1 Spieler Modus 25000
    Pentium 100: 2 Spieler Modus 20000
*)

  Verzoegerung=2000;

(* Steuerung Spieler 1: *)

  links1="y";
  rechts1="x";
  runter1="-";
  drehunglinks1=".";
  drehungrechts1=",";


(* Steuerung Spieler 2: *)

  links2="4";
  rechts2="6";
  runter2="5";
  drehunglinks2="9";
  drehungrechts2="7";


VAR Feld: ARRAY 32,22 OF BOOLEAN;
  geaendert1,geaendert2: ARRAY 21 OF BOOLEAN;
  AnzahlGeaenderteLinien1, AnzahlGeaenderteLinien2: INTEGER;
  Spielende, fertig1,fertig2, wechsel, Spieler2: BOOLEAN;
  Punkte1,Punkte2,x1,y1,a1,lage1,x2,y2,a2,lage2,tempo1,tempo2: INTEGER;
  altkey: CHAR;
  Linien1, Linien2: INTEGER;
  level1, level2: INTEGER;
  Straflinien1, Straflinien2: INTEGER;

PROCEDURE Spielfeldzeichnen;

CONST Bildschirmbreite=800; Bildschirmhoehe=600;

VAR x,y,i: INTEGER;

BEGIN;
  X.Open; 
  L.Linie(50,50,150,50); L.Linie(50,30,50,250); L.Linie(150,30,150,250);
  L.Linie(50,30,150,30); L.Linie(50,40,150,40);
  L.Linie(180,180,180,220); L.Linie(180,220,220,220);L.Linie(220,220,220,180); L.Linie(220,180,180,180);
  IF Spieler2 THEN L.Linie(250,50,350,50); L.Linie(250,30,250,250); L.Linie(350,30,350,250);
    L.Linie(250,30,350,30); L.Linie(250,40,350,40); END;
  FOR x:=1 TO 31 DO;
    FOR y:=1 TO 21 DO;
      Feld[x,y]:=FALSE;
    END;
  END;
  FOR i:=0 TO 21 DO;
    Feld[0,i]:=TRUE;
    Feld[11,i]:=TRUE;
    Feld[20,i]:=TRUE;
    Feld[31,i]:=TRUE;
  END;
  FOR i:=1 TO 31 DO;
    Feld[i,0]:=TRUE;
  END;
  FOR i:=0 TO 20 DO;
    geaendert1[i]:=FALSE;
    geaendert2[i]:=FALSE;
  END;
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

END Spielfeldzeichnen;

PROCEDURE FuelleFeld(i,j: INTEGER);

VAR x,y: INTEGER;

BEGIN
  FOR x:=1 TO 9 DO;
    L.Linie(40+10*i+x,41+10*j,40+10*i+x,49+10*j);
  END;
END FuelleFeld;

PROCEDURE LoescheFeld(i,j: INTEGER);

VAR x,y: INTEGER;

BEGIN
  FOR x:=1 TO 9 DO;
    L.LoescheLinie(40+10*i+x,41+10*j,40+10*i+x,49+10*j);
  END;
END LoescheFeld;

PROCEDURE IstFeld(i,j: INTEGER):BOOLEAN;

BEGIN;
  RETURN X.IsDot(45+10*i,45+10*j);
END IstFeld;

PROCEDURE MaleVorschau;

VAR i,j: INTEGER;

BEGIN;
  FOR i:=13 TO 18 DO;
    FOR j:=13 TO 18 DO;
      IF Feld[i,j] THEN
        IF ~IstFeld(i,j) THEN FuelleFeld(i,j); END;
      ELSE
        IF IstFeld(i,j) THEN LoescheFeld(i,j); END;
      END;
    END;
  END;
END MaleVorschau;


PROCEDURE Malen1;

VAR i,j: INTEGER;

BEGIN;
  FOR i:=1 TO 10 DO;
    FOR j:=1 TO 20 DO;
      IF Feld[i,j] THEN
        IF ~IstFeld(i,j) THEN FuelleFeld(i,j); END;
      ELSE
        IF IstFeld(i,j) THEN LoescheFeld(i,j); END;
      END;
    END;
  END;
END Malen1;

PROCEDURE Malen2;

VAR i,j: INTEGER;

BEGIN;
  FOR i:=21 TO 30 DO;
    FOR j:=1 TO 20 DO;
      IF Feld[i,j] THEN
        IF ~IstFeld(i,j) THEN FuelleFeld(i,j); END;
      ELSE
        IF IstFeld(i,j) THEN LoescheFeld(i,j); END;
      END;
    END;
  END;
END Malen2;

PROCEDURE LoescheLinien1;

VAR i,j,h,k,Zaehler: INTEGER;

BEGIN;
INC(Linien1,AnzahlGeaenderteLinien1);
level1:=(Linien1 + Schrittweite) DIV Schrittweite;
Punkte1:=Punkte1+level1*AnzahlGeaenderteLinien1*AnzahlGeaenderteLinien1*50;
FOR i:=1 TO AnzahlGeaenderteLinien1 DO
  j:=1;
  WHILE j<19 DO
    WHILE ~geaendert1[j] DO INC(j); END;
    IF geaendert1[j] THEN 
      FOR h:=j TO 19 DO
        FOR k:=1 TO 10 DO;
          Feld[k,h]:=Feld[k,h+1];
        END;
        geaendert1[h]:=geaendert1[h+1];
      END;
      Malen1;
      j:=22;
    END;
  END;
END;
END LoescheLinien1;

PROCEDURE LoescheLinien2;

VAR i,j,h,k,Zaehler: INTEGER;

BEGIN;
INC(Linien2,AnzahlGeaenderteLinien2);
level2:=(Linien2 + Schrittweite) DIV Schrittweite;
Punkte2:=Punkte2+level2*AnzahlGeaenderteLinien2*AnzahlGeaenderteLinien2*50;
FOR i:=1 TO AnzahlGeaenderteLinien2 DO
  j:=1;
  WHILE j<19 DO
    WHILE ~geaendert2[j] DO INC(j); END;
    IF geaendert2[j] THEN 
      FOR h:=j TO 19 DO
        FOR k:=21 TO 30 DO;
          Feld[k,h]:=Feld[k,h+1];
        END;
        geaendert2[h]:=geaendert2[h+1];
      END;
      Malen2;
      j:=22;
    END;
  END;
END;
END LoescheLinien2;

PROCEDURE Kontrolle;

VAR i,j:  INTEGER; Zustand1, Zustand2:BOOLEAN;

BEGIN;

AnzahlGeaenderteLinien1:=0;AnzahlGeaenderteLinien2:=0;
FOR i:=1 TO 20 DO
  Zustand1:=TRUE; Zustand2:=TRUE;
  FOR j:=1 TO 10 DO
    Zustand1:=Zustand1&Feld[j,i]
  END;
  IF Zustand1 THEN INC(AnzahlGeaenderteLinien1);geaendert1[i]:=TRUE; ELSE geaendert1[i]:=FALSE;END;
  FOR j:=21 TO 30 DO
    Zustand2:=Zustand2&Feld[j,i]
  END;
  IF Zustand2 THEN INC(AnzahlGeaenderteLinien2);geaendert2[i]:=TRUE; ELSE geaendert2[i]:=FALSE;END;
END;
IF Spieler2 THEN
  IF AnzahlGeaenderteLinien1 > 1 THEN
    IF AnzahlGeaenderteLinien1=2 THEN Straflinien2:=1; 
    ELSIF AnzahlGeaenderteLinien1=3 THEN Straflinien2:=2; 
    ELSIF AnzahlGeaenderteLinien1=4 THEN Straflinien2:=4;
    END;
  END;
  IF AnzahlGeaenderteLinien2 > 1 THEN
    IF AnzahlGeaenderteLinien2=2 THEN Straflinien1:=1; 
    ELSIF AnzahlGeaenderteLinien2=3 THEN Straflinien1:=2; 
    ELSIF AnzahlGeaenderteLinien2=4 THEN Straflinien1:=4;
    END;
  END;
END;

END Kontrolle;

PROCEDURE LoescheTeil(a,lage: INTEGER; VAR x,y: INTEGER);

VAR i,j: INTEGER;

BEGIN
IF a=1 THEN
  FOR i:=0 TO 1 DO;
    FOR j:=0 TO 1 DO;
      Feld[x+i,y+j]:=FALSE
    END;
  END;
ELSIF a=2 THEN
  IF (lage=1)OR(lage=3) THEN
    FOR i:=0 TO 3 DO;
      Feld[x-1+i,y]:=FALSE;
    END;
  ELSE 
    FOR i:=0 TO 3 DO;
      Feld[x,y-1+i]:=FALSE;
    END;
  END;
ELSIF a=3 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x,y+1]:=FALSE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x,y+1]:=FALSE;
  ELSIF lage=3 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x-1,y]:=FALSE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x,y+1]:=FALSE;Feld[x-1,y]:=FALSE;
  END;
ELSIF a=4 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x+1,y+1]:=FALSE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y-1]:=FALSE;Feld[x,y+1]:=FALSE;
  ELSIF lage=3 THEN
    Feld[x-1,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x-1,y]:=FALSE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x,y+1]:=FALSE;Feld[x-1,y+1]:=FALSE;
  END;
ELSIF a=5 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x-1,y+1]:=FALSE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y+1]:=FALSE;Feld[x,y+1]:=FALSE;
  ELSIF lage=3 THEN
    Feld[x+1,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x-1,y]:=FALSE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=FALSE;Feld[x,y]:=FALSE; Feld[x,y+1]:=FALSE;Feld[x-1,y-1]:=FALSE;
  END;
ELSIF a=6 THEN
  IF (lage=1) OR (lage=3)  THEN
    Feld[x-1,y]:=FALSE;Feld[x,y]:=FALSE; Feld[x,y+1]:=FALSE;Feld[x+1,y+1]:=FALSE;
  ELSIF (lage=2) OR (lage= 4 )THEN
    Feld[x+1,y]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y-1]:=FALSE; Feld[x,y+1]:=FALSE;
  END;
ELSIF a=7 THEN
  IF (lage=1) OR (lage=3) THEN
    Feld[x,y+1]:=FALSE;Feld[x,y]:=FALSE; Feld[x+1,y]:=FALSE;Feld[x-1,y+1]:=FALSE;
  ELSIF (lage=2) OR (lage=4) THEN
    Feld[x,y+1]:=FALSE;Feld[x,y]:=FALSE; Feld[x-1,y-1]:=FALSE;Feld[x-1,y]:=FALSE;
  END;

END;
END LoescheTeil;

PROCEDURE ZeichneTeil(a,lage: INTEGER; VAR x,y: INTEGER);

VAR i,j: INTEGER;

BEGIN;
IF a=1 THEN
  FOR i:=0 TO 1 DO;
    FOR j:=0 TO 1 DO;
      Feld[x+i,y+j]:=TRUE
    END;
  END;
ELSIF a=2 THEN
  IF (lage=1)OR(lage=3) THEN
    FOR i:=0 TO 3 DO;
      Feld[x-1+i,y]:=TRUE;
    END;
  ELSE 
    FOR i:=0 TO 3 DO;
      Feld[x,y-1+i]:=TRUE;
    END;
  END;
ELSIF a=3 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x,y+1]:=TRUE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x,y+1]:=TRUE;
  ELSIF lage=3 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x-1,y]:=TRUE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x,y+1]:=TRUE;Feld[x-1,y]:=TRUE;
  END;
ELSIF a=4 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x+1,y+1]:=TRUE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y-1]:=TRUE; Feld[x,y+1]:=TRUE;
  ELSIF lage=3 THEN
    Feld[x-1,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x-1,y]:=TRUE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x,y+1]:=TRUE;Feld[x-1,y+1]:=TRUE;
  END;
ELSIF a=5 THEN
  IF lage=1 THEN
    Feld[x-1,y]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x-1,y+1]:=TRUE;
  ELSIF lage=2 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y+1]:=TRUE;Feld[x,y+1]:=TRUE;
  ELSIF lage=3 THEN
    Feld[x+1,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x-1,y]:=TRUE;
  ELSIF lage=4 THEN
    Feld[x,y-1]:=TRUE;Feld[x,y]:=TRUE; Feld[x,y+1]:=TRUE;Feld[x-1,y-1]:=TRUE;
  END;
ELSIF a=6 THEN
  IF (lage=1) OR (lage=3)  THEN
    Feld[x-1,y]:=TRUE;Feld[x,y]:=TRUE; Feld[x,y+1]:=TRUE;Feld[x+1,y+1]:=TRUE;
  ELSIF (lage=2) OR (lage= 4 )THEN
    Feld[x+1,y]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y-1]:=TRUE; Feld[x,y+1]:=TRUE;
  END;
ELSIF a=7 THEN
  IF (lage=1) OR (lage=3) THEN
    Feld[x,y+1]:=TRUE;Feld[x,y]:=TRUE; Feld[x+1,y]:=TRUE;Feld[x-1,y+1]:=TRUE;
  ELSIF (lage=2) OR (lage=4) THEN
    Feld[x,y+1]:=TRUE;Feld[x,y]:=TRUE; Feld[x-1,y-1]:=TRUE;Feld[x-1,y]:=TRUE;
  END;
END;
END ZeichneTeil;

PROCEDURE HilfeLinks;

BEGIN
  wechsel:=TRUE; altkey:=",";
END HilfeLinks;

PROCEDURE KontrolleLinks(a,lage: INTEGER; VAR x,y: INTEGER);

VAR hilfe1, hilfe2: BOOLEAN;

BEGIN
  IF a=1 THEN
    IF (~Feld[x-1,y])&(~Feld[x-1,y+1]) THEN DEC(x); 
    ELSIF ~(x<2) THEN HilfeLinks;END;
  ELSIF a=2 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x-2,y]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSE
      hilfe1:=(~Feld[x-1,y-1])&(~Feld[x-1,y]); hilfe2:=(~Feld[x-1,y+1])&(~Feld[x-1,y+2]);
      IF hilfe1&hilfe2 THEN DEC(x);
      ELSIF ~(x<2) THEN HilfeLinks; END;
    END;
  ELSIF a=3 THEN
    IF lage=1 THEN
      IF (~Feld[x-2,y]&~Feld[x-1,y+1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x-1,y]&~Feld[x-1,y+1]);
      IF hilfe1 & ~Feld[x-1,y-1] THEN DEC(x);
      ELSIF ~(x<2) THEN HilfeLinks; END;
    ELSIF lage=3 THEN
      IF (~Feld[x-2,y]&~Feld[x-1,y-1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x-2,y]&~Feld[x-1,y+1]);
      IF hilfe1 & ~Feld[x-1,y-1] THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    END;
  ELSIF a=4 THEN
    IF lage=1 THEN
      IF (~Feld[x-2,y]&~Feld[x,y+1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x-1,y]&~Feld[x-1,y+1]);
      IF hilfe1 & ~Feld[x-1,y-1] THEN DEC(x);
      ELSIF ~(x<2) THEN HilfeLinks; END;
    ELSIF lage=3 THEN
      IF (~Feld[x-2,y]&~Feld[x-2,y-1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x-2,y+1]&~Feld[x-1,y]);
      IF hilfe1 & ~Feld[x-1,y-1] THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    END;
  ELSIF a=5 THEN
    IF lage=1 THEN
      IF (~Feld[x-2,y]&~Feld[x-2,y+1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x-1,y]&~Feld[x-1,y+1]);
      IF hilfe1 & ~Feld[x-1,y-1] THEN DEC(x);
      ELSIF ~(x<2) THEN HilfeLinks; END;
    ELSIF lage=3 THEN
      IF (~Feld[x-2,y]&~Feld[x,y-1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x-1,y+1]&~Feld[x-1,y]);
      IF hilfe1 & ~Feld[x-2,y-1] THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    END;
  ELSIF a=6 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x-2,y])&(~Feld[x-1,y+1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSE
      hilfe1:=(~Feld[x,y-1])&(~Feld[x-1,y]); hilfe2:=(~Feld[x-1,y+1]);
      IF hilfe1&hilfe2 THEN DEC(x);
      ELSIF ~(x<2) THEN HilfeLinks; END;
    END;
  ELSIF a=7 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x-1,y])&(~Feld[x-2,y+1]) THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    ELSE
      hilfe1:=(~Feld[x-2,y-1])&(~Feld[x-2,y]); hilfe2:=(~Feld[x-1,y+1]);
      IF hilfe1&hilfe2 THEN DEC(x);
      ELSIF ~(x<3) THEN HilfeLinks; END;
    END;
  END;
END KontrolleLinks;

PROCEDURE HilfeRechts;

BEGIN
  wechsel:=TRUE; altkey:=".";
END HilfeRechts;

PROCEDURE KontrolleRechts(a,lage: INTEGER; VAR x,y: INTEGER);

VAR hilfe1, hilfe2: BOOLEAN;

BEGIN
  IF a=1 THEN
    IF (~Feld[x+2,y])&(~Feld[x+2,y+1])THEN INC(x); 
    ELSIF~(x>8) THEN HilfeRechts; END;
  ELSIF a=2 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x+3,y]) THEN INC(x);
      ELSIF ~(x>7) THEN HilfeRechts; END;
    ELSE
      hilfe1:=(~Feld[x+1,y-1])&(~Feld[x+1,y]); hilfe2:=(~Feld[x+1,y+1])&(~Feld[x+1,y+2]);
      IF hilfe1&hilfe2 THEN INC(x);
      ELSIF ~(x>9) THEN HilfeRechts; END;
    END;
  ELSIF a=3 THEN
    IF lage=1 THEN
      IF (~Feld[x+2,y]&~Feld[x+1,y+1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x+2,y]&~Feld[x+1,y+1]);
      IF hilfe1 & ~Feld[x+1,y-1] THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=3 THEN
      IF (~Feld[x+2,y]&~Feld[x+1,y-1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x+1,y]&~Feld[x+1,y+1]);
      IF hilfe1 & ~Feld[x+1,y-1] THEN INC(x);
      ELSIF ~(x>9) THEN HilfeRechts; END;
    END;
  ELSIF a=4 THEN
    IF lage=1 THEN
      IF (~Feld[x+2,y]&~Feld[x+2,y+1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x+1,y]&~Feld[x+1,y+1]);
      IF hilfe1 & ~Feld[x+2,y-1] THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=3 THEN
      IF (~Feld[x+2,y]&~Feld[x,y-1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x+1,y]&~Feld[x+1,y+1]);
      IF hilfe1 & ~Feld[x+1,y-1] THEN INC(x);
      ELSIF ~(x>9) THEN HilfeRechts; END;
    END;
  ELSIF a=5 THEN
    IF lage=1 THEN
      IF (~Feld[x+2,y]&~Feld[x,y+1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=2 THEN
      hilfe1:=(~Feld[x+1,y]&~Feld[x+2,y+1]);
      IF hilfe1 & ~Feld[x+1,y-1] THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=3 THEN
      IF (~Feld[x+2,y]&~Feld[x+2,y-1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSIF lage=4 THEN
      hilfe1:=(~Feld[x+1,y]&~Feld[x+1,y+1]);
      IF hilfe1 & ~Feld[x+1,y-1] THEN INC(x);
      ELSIF ~(x>9) THEN HilfeRechts; END;
    END;
  ELSIF a=6 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x+1,y])&(~Feld[x+2,y+1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSE
      hilfe1:=(~Feld[x+2,y-1])&(~Feld[x+2,y]); hilfe2:=(~Feld[x+1,y+1]);
      IF hilfe1&hilfe2 THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    END;
  ELSIF a=7 THEN
    IF (lage=1) OR (lage=3) THEN
      IF (~Feld[x+2,y])&(~Feld[x+1,y+1]) THEN INC(x);
      ELSIF ~(x>8) THEN HilfeRechts; END;
    ELSE
      hilfe1:=(~Feld[x,y-1])&(~Feld[x+1,y]); hilfe2:=(~Feld[x+1,y+1]);
      IF hilfe1&hilfe2 THEN INC(x);
      ELSIF ~(x>9) THEN HilfeRechts; END;
    END;
  END;
END KontrolleRechts;

PROCEDURE HilfeUnten(x,y: INTEGER);

BEGIN;
  IF y=19 THEN Spielende:=TRUE END;
  IF x<11 THEN fertig1:=TRUE; ELSE fertig2:=TRUE END;
END HilfeUnten;

PROCEDURE KontrolleUnten(a,lage,x,y: INTEGER);

VAR hilfe1, hilfe2: BOOLEAN;

BEGIN
  IF y>1 THEN
  IF a=1 THEN
    IF Feld[x,y-1] OR Feld[x+1,y-1] THEN HilfeUnten(x,y) END;
  ELSIF a=2 THEN
    IF (lage=1) OR (lage=3) THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1] OR Feld[x+2,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSE
      IF Feld[x,y-2] THEN HilfeUnten(x,y) END;
    END;
  ELSIF a=3 THEN
    IF lage=1 THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=2 THEN
      IF Feld[x,y-2] OR Feld[x+1,y-1] THEN HilfeUnten(x,y) END;
    ELSIF lage=3 THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-2]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=4 THEN
      IF Feld[x,y-2] OR Feld[x-1,y-1] THEN HilfeUnten(x,y) END;
    END;
  ELSIF a=4 THEN
    IF lage=1 THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=2 THEN
      IF Feld[x,y-2] OR Feld[x+1,y-2] THEN HilfeUnten(x,y) END;
    ELSIF lage=3 THEN
      hilfe1:=Feld[x-1,y-2] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=4 THEN
      IF Feld[x,y-2] OR Feld[x-1,y] THEN HilfeUnten(x,y) END;
    END;
  ELSIF a=5 THEN
    IF lage=1 THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=2 THEN
      IF Feld[x,y-2] OR Feld[x+1,y] THEN HilfeUnten(x,y) END;
    ELSIF lage=3 THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-2];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSIF lage=4 THEN
      IF Feld[x,y-2] OR Feld[x-1,y-2] THEN HilfeUnten(x,y) END;
    END;
  ELSIF a=6 THEN
    IF (lage=1) OR (lage=3) THEN
      hilfe1:=Feld[x-1,y-1] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSE
      IF Feld[x,y-1] OR Feld[x+1,y-2] THEN HilfeUnten(x,y) END;
    END;
  ELSIF a=7 THEN
    IF (lage=1) OR (lage=3) THEN
      hilfe1:=Feld[x-1,y] OR Feld[x,y-1]; hilfe2:=Feld[x+1,y-1];
      IF  hilfe1 OR hilfe2 THEN HilfeUnten(x,y) END;
    ELSE
      IF Feld[x,y-1] OR Feld[x-1,y-2] THEN HilfeUnten(x,y) END;
    END;
  END;
  ELSE HilfeUnten(x,y); END;
END KontrolleUnten;

PROCEDURE DrehungLinks(VAR a,lage,x,y: INTEGER):BOOLEAN;

VAR hilfe1: BOOLEAN;

BEGIN;
  IF a=2 THEN
    IF lage DIV 2 # 0 THEN
      hilfe1:=~Feld[x-1,y]&~Feld[x+1,y];
      RETURN ~Feld[x+2,y]&hilfe1 ;
    ELSE
      hilfe1:=~Feld[x,y-1]&~Feld[x,y+1];
      RETURN ~Feld[x,y+2]&hilfe1 ;
    END;
  ELSIF a=3 THEN
    IF lage=1 THEN RETURN ~Feld[x,y-1];
    ELSIF lage=2 THEN RETURN ~Feld[x-1,y];
    ELSIF lage=3 THEN RETURN ~Feld[x,y+1];
    ELSIF lage=4 THEN RETURN ~Feld[x+1,y];
    END;
  ELSIF a=4 THEN
    IF lage=1 THEN 
      hilfe1:=~Feld[x+1,y-1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1]; 
    ELSIF lage=2 THEN 
      hilfe1:=~Feld[x+1,y]&~Feld[x-1,y-1];
      RETURN hilfe1&~Feld[x-1,y];
    ELSIF lage=3 THEN
      hilfe1:=~Feld[x-1,y+1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1];
    ELSIF lage=4 THEN
      hilfe1:=~Feld[x+1,y]&~Feld[x+1,y+1];
      RETURN hilfe1&~Feld[x-1,y];
    END;
  ELSIF a=5 THEN
    IF lage=1 THEN 
      hilfe1:=~Feld[x+1,y+1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1]; 
    ELSIF lage=2 THEN 
      hilfe1:=~Feld[x+1,y]&~Feld[x+1,y-1];
      RETURN hilfe1&~Feld[x-1,y];
    ELSIF lage=3 THEN
      hilfe1:=~Feld[x-1,y-1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1];
    ELSIF lage=4 THEN
      hilfe1:=~Feld[x+1,y]&~Feld[x-1,y+1];
      RETURN hilfe1&~Feld[x-1,y];
    END;
  END;
  RETURN TRUE;
END DrehungLinks;

PROCEDURE DrehungRechts(VAR a,lage,x,y: INTEGER):BOOLEAN;

VAR hilfe1: BOOLEAN;

BEGIN
  IF a=2 THEN
    IF lage DIV 2 # 0 THEN
      hilfe1:=~Feld[x-1,y]&~Feld[x+1,y];
      RETURN ~Feld[x+2,y]&hilfe1 ;
    ELSE
      hilfe1:=~Feld[x,y-1]&~Feld[x,y+1];
      RETURN ~Feld[x,y+2]&hilfe1 ;
    END;
  ELSIF a=3 THEN
    IF lage=3 THEN RETURN ~Feld[x,y-1];
    ELSIF lage=2 THEN RETURN ~Feld[x-1,y];
    ELSIF lage=1 THEN RETURN ~Feld[x,y+1];
    ELSIF lage=4 THEN RETURN ~Feld[x+1,y];
    END;
  ELSIF a=4 THEN
    IF lage=3 THEN 
      hilfe1:=~Feld[x+1,y-1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1]; 
    ELSIF lage=4 THEN 
      hilfe1:=~Feld[x+1,y]&~Feld[x-1,y-1];
      RETURN hilfe1&~Feld[x-1,y];
    ELSIF lage=1 THEN
      hilfe1:=~Feld[x-1,y+1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1];
    ELSIF lage=2 THEN
      hilfe1:=~Feld[x+1,y]&~Feld[x+1,y+1];
      RETURN hilfe1&~Feld[x-1,y];
    END;
  ELSIF a=5 THEN
    IF lage=3 THEN 
      hilfe1:=~Feld[x+1,y+1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1]; 
    ELSIF lage=4 THEN 
      hilfe1:=~Feld[x+1,y]&~Feld[x+1,y-1];
      RETURN hilfe1&~Feld[x-1,y];
    ELSIF lage=1 THEN
      hilfe1:=~Feld[x-1,y-1]&~Feld[x,y-1];
      RETURN hilfe1&~Feld[x,y+1];
    ELSIF lage=2 THEN
      hilfe1:=~Feld[x+1,y]&~Feld[x-1,y+1];
      RETURN hilfe1&~Feld[x-1,y];
    END;
  ELSIF a=6 THEN
    IF (lage=1) OR (lage=3) THEN
      RETURN ~Feld[x+1,y-1]&~Feld[x+1,y]; 
    ELSE
      RETURN ~Feld[x+1,y+1]&~Feld[x-1,y];
    END;
  ELSIF a=7 THEN
    IF (lage=1) OR (lage=3) THEN
      RETURN ~Feld[x-1,y-1]&~Feld[x-1,y]; 
    ELSE
      RETURN ~Feld[x-1,y+1]&~Feld[x+1,y];
    END;
  END;
  RETURN TRUE;
END DrehungRechts;

PROCEDURE Strafen1;

VAR Hoehe,i,j,freiesFeld: INTEGER;

BEGIN
  IF Straflinien1#0 THEN
    Hoehe:=20-Straflinien1;
    WHILE Hoehe>=1 DO
      FOR i:=1 TO 10 DO;
        Feld[i,Hoehe+Straflinien1]:=Feld[i,Hoehe];
      END;
      DEC(Hoehe);
    END; 
    FOR i:=1 TO Straflinien1 DO;
      FOR j:=1 TO 10 DO;
        Feld[j,i]:=TRUE;
      END;
      freiesFeld:=0;
      WHILE freiesFeld=0 DO freiesFeld:=SHORT(ENTIER(10*RN.Uniform())); END;
      Feld[freiesFeld,i]:=FALSE;
    END;
  Straflinien1:=0;
  END;
END Strafen1;

PROCEDURE Strafen2;

VAR Hoehe,i,j,freiesFeld: INTEGER;

BEGIN
  IF Straflinien2#0 THEN
    Hoehe:=20-Straflinien2;
    WHILE Hoehe>=1 DO
      FOR i:=21 TO 30 DO;
        Feld[i,Hoehe+Straflinien2]:=Feld[i,Hoehe];
      END;
      DEC(Hoehe);
    END; 
    FOR i:=1 TO Straflinien2 DO;
      FOR j:=21 TO 30 DO;
        Feld[j,i]:=TRUE;
      END;
      freiesFeld:=0;
      WHILE freiesFeld=0 DO freiesFeld:=SHORT(ENTIER(10*RN.Uniform())); END;
      Feld[20+freiesFeld,i]:=FALSE;
    END;
  Straflinien2:=0;
  END;
END Strafen2;

PROCEDURE Spiel;

VAR i,j,k,Zaehler: INTEGER; key: CHAR; hilfe1,hilfe2: BOOLEAN;next,altnext,OrtX, OrtY: INTEGER;

BEGIN;
  WHILE ~Spielende DO
  IF y1=0 THEN 
    IF y2=0 THEN
      x2:=25; y2:=19;lage2:=1;fertig2:=FALSE; tempo2:=1; a2:=0;
      a2:=next; 
    END;
    x1:=5; y1:=19;lage1:=1; fertig1:=FALSE; tempo1:=1;a1:=0;
    a1:=next; 
  ELSE
    x2:=25; y2:=19;lage2:=1;fertig2:=FALSE; tempo2:=1; a2:=0;
    IF next=0 THEN a2:=a1; ELSE a2:=next; END;
  END;
  next:=0;
  WHILE next=0 DO next:=SHORT(ENTIER(7*RN.Uniform()+0.5)); END;
  OrtX:=15; OrtY:=15;
  LoescheTeil(altnext,1,OrtX,OrtY);
  ZeichneTeil(next,1,OrtX, OrtY);
  MaleVorschau;
  altnext:=next;
  wechsel:=FALSE; 
  Ziffer.Zeichne(3,level1,1,0); Ziffer.Zeichne(4,Linien1,7,0);Ziffer.Zeichne(8,Punkte1,3,-1);
  IF Spieler2 THEN Ziffer.Zeichne(3,level2,21,0); Ziffer.Zeichne(4,Linien2,27,0); 
    Ziffer.Zeichne(8,Punkte2,23,-1); END;
  WHILE (y1>0) & (y2>0) DO;
    IF ~Spieler2 THEN  y2:=7; END;
    INC(Zaehler);
    key:=X.Key(); 
    (* IF wechsel THEN key:=altkey; END; *);
    IF key=links1 THEN
      LoescheTeil(a1,lage1,x1,y1);
      KontrolleLinks(a1,lage1,x1,y1);
    END;
    IF key=rechts1 THEN
      LoescheTeil(a1,lage1,x1,y1);
      KontrolleRechts(a1,lage1,x1,y1);
    END;
    IF Spieler2 THEN
      IF key=links2 THEN
        LoescheTeil(a2,lage2,x2,y2);
        KontrolleLinks(a2,lage2,x2,y2);
      END;
      IF key=rechts2 THEN
        LoescheTeil(a2,lage2,x2,y2);
        KontrolleRechts(a2,lage2,x2,y2);
    END; END;
    hilfe1:=(x1>1)&(x1<10);
    IF Spieler2 THEN hilfe2:=(x2>21)&(x2<30); END;
    IF key=drehunglinks1 THEN 
      IF  hilfe1 & DrehungLinks(a1,lage1,x1,y1) THEN INC(lage1); IF lage1>4 THEN lage1:=1 END; END; END;
    IF key=drehungrechts1 THEN
      IF hilfe1 & DrehungRechts(a1,lage1,x1,y1) THEN DEC(lage1); IF lage1<1 THEN lage1:=4 END; END; END;
    IF Spieler2 THEN
      IF key=drehunglinks2 THEN 
        IF  hilfe2 & DrehungLinks(a2,lage2,x2,y2) THEN INC(lage2); IF lage2>4 THEN lage2:=1 END; END; END;
      IF key=drehungrechts2 THEN
        IF hilfe2 & DrehungRechts(a2,lage2,x2,y2) THEN DEC(lage2); IF lage2<1 THEN lage2:=4 END; END; END;
    END;
    IF key=ende THEN Spielende:=TRUE; END;
    IF key=runter1 THEN 
      IF tempo1=8(*Verzoegerung DIV level1*) THEN tempo1:=1 
        ELSE tempo1:=8(*Verzoegerung DIV level1*); Punkte1:=Punkte1 + level1*y1; END;
    END;
    IF Spieler2 THEN IF key=runter2 THEN 
      IF tempo2=8(*Verzoegerung DIV level2*) THEN tempo2:=1 
        ELSE tempo2:=8(*Verzoegerung DIV level2*); Punkte2:=Punkte2 + level2*y2;END;
    END; END;
    IF Zaehler MOD (Verzoegerung DIV level1 DIV tempo1) = 0 THEN
      KontrolleUnten(a1,lage1,x1,y1);
      ZeichneTeil(a1,lage1,x1,y1);
      Malen1;
      IF fertig1 THEN Kontrolle; LoescheLinien1; Malen1; Strafen1;  END;
      IF ~fertig1 THEN
        LoescheTeil(a1,lage1,x1,y1);
      END;
      IF fertig1 THEN y1:=0 ELSE DEC(y1); END;
    END;
    IF Spieler2 THEN
    IF Zaehler MOD (Verzoegerung DIV level2 DIV tempo2) = 0 THEN
      KontrolleUnten(a2,lage2,x2,y2);
      ZeichneTeil(a2,lage2,x2,y2);
      Malen2;
      IF fertig2 THEN Kontrolle; LoescheLinien2; Malen2; Strafen2; END;
      IF ~fertig2 THEN
        LoescheTeil(a2,lage2,x2,y2);
      END;
      IF fertig2 THEN y2:=0 ELSE DEC(y2); END;
    END; 
    END;
    IF Spieler2 THEN
      IF (Linien1>=Limit) OR (Linien2>=Limit) THEN
        IF Linien2<Limit THEN Out.String("Spieler1 hat gewonnen!"); Spielende:=TRUE;
        ELSIF Linien1<Limit THEN Out.String("Spieler2 hat gewonnen!"); Spielende:=TRUE;
        ELSE Out.String("Beide haben gewonnen!"); Spielende:=TRUE;
        END
      END;
    END;
    IF key=pause THEN
      REPEAT key:=X.Key() UNTIL key=endepause;
    END;
    IF Zaehler=Verzoegerung THEN Zaehler:=0; END;
  END;
END;
END Spiel;

PROCEDURE Start*;

VAR p: INTEGER;

BEGIN
  In.Open;
  In.Int(p);
  IF p=2 THEN Spieler2:=TRUE; ELSE Spieler2:=FALSE; END;
  Spielfeldzeichnen;
  RN.InitSeed(Oberon.Time());
  Spielende:=FALSE; 
  IF Spieler2 THEN x2:=26; y2:=19;lage2:=1;fertig2:=FALSE; tempo2:=1; a2:=0;
  WHILE a2=0 DO a2:=SHORT(ENTIER(7*RN.Uniform()+0.5)); END ; END;
  x1:=5; y1:=19;lage1:=1; fertig1:=FALSE; tempo1:=1;a1:=0;
  WHILE a1=0 DO a1:=SHORT(ENTIER(7*RN.Uniform()+0.5)); END;
  wechsel:=FALSE; 
  Linien1:=0; Linien2:=0; level1:=1; level2:=1; Punkte1:=0; Punkte2:=0;
  Straflinien1:=0; Straflinien2:=0;
  Spiel;
END Start;

BEGIN
Start

END Tetris.

