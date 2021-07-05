MODULE Minesweeper;

IMPORT X:=oocXYplane, L:=Linie, In := compatIn, Out := Console, RN:=ethRandomNumbers;

VAR
  Feld: ARRAY 41, 41 OF INTEGER;
  Spielfeld: ARRAY 41, 41 OF INTEGER;
  Bombenfeld: ARRAY 41, 41 OF BOOLEAN;
  Anzahl: ARRAY 42, 42 OF INTEGER;
  Test: ARRAY 42, 42 OF BOOLEAN;
  Nummer,Bomben : INTEGER;
  Feldgroesse,Schritte: INTEGER;

PROCEDURE FuelleKaestchen(x,y: INTEGER);

VAR i: INTEGER;

BEGIN
  FOR i:=0 TO 8 DO;
    IF i MOD 2=0 THEN
      L.Linie(40+10*x+9-i,40+10*y+1,40+10*x+1,40+10*y+9-i);
      L.Linie(40+10*x+9, 40+10*y+1+i,40+10*x+1+i,40+10*y+9);
    END;  
  END;
END FuelleKaestchen;

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

PROCEDURE MaleFeld;

VAR i,j: INTEGER;

BEGIN
  X.Open;
  Signatur;
  Schritte:=0;
  FOR i:=1 TO Feldgroesse DO; FOR j:=1 TO Feldgroesse DO; Feld[i,j]:=0; END; END;
  FOR i:=1 TO Feldgroesse DO; FOR j:=1 TO Feldgroesse DO; Spielfeld[i,j]:=11; END; END;
  FOR i:=1 TO Feldgroesse DO; FOR j:=1 TO Feldgroesse DO; Bombenfeld[i,j]:=FALSE; END; END;
  FOR i:=0 TO Feldgroesse+1 DO; FOR j:=0 TO Feldgroesse+1 DO; Test[i,j]:=FALSE; END; END;
  FOR i:=0 TO Feldgroesse+1 DO; FOR j:=0 TO Feldgroesse+1 DO; Anzahl[i,j]:=0; END; END; 
  FOR i:=0 TO Feldgroesse+1 DO;  Test[i,0]:=TRUE; END;
  FOR i:=0 TO Feldgroesse+1 DO;  Test[i,Feldgroesse+1]:=TRUE; END;
  FOR i:=0 TO Feldgroesse+1 DO;  Test[0,i]:=TRUE; END;
  FOR i:=0 TO Feldgroesse+1 DO;  Test[Feldgroesse+1,i]:=TRUE; END;
  FOR i:=0 TO 10*Feldgroesse DO;
    IF i MOD 10 = 0 THEN
      L.Linie(50,50+i,50+10*Feldgroesse,50+i);
      L.Linie(50+i,50,50+i,50+10*Feldgroesse);
    END;
  END;
  FOR i:=0 TO Feldgroesse-1 DO;
    FOR j:=0 TO Feldgroesse-1 DO;
      FuelleKaestchen(1+i,1+j);
      Feld[i+1,j+1]:=11;
    END;
  END;
    
END MaleFeld;

PROCEDURE MarkKaestchen(x,y: INTEGER);

VAR i: INTEGER;

BEGIN
  L.Linie(40+10*x+1,40+10*y+1,40+10*x+9,40+10*y+1);
  L.Linie(40+10*x+9,40+10*y+1,40+10*x+9,40+10*y+9);
  L.Linie(40+10*x+9,40+10*y+9,40+10*x+1,40+10*y+9);
  L.Linie(40+10*x+1,40+10*y+9,40+10*x+1,40+10*y+1);
END MarkKaestchen;

PROCEDURE LoescheKaestchen(x,y: INTEGER);

VAR i: INTEGER;

BEGIN
  FOR i:=1 TO 9 DO;
    L.LoescheLinie(40+10*x+1,40+10*y+i,40+10*x+9,40+10*y+i);
  END;
END LoescheKaestchen;

PROCEDURE KreuzeKaestchen(x,y: INTEGER);

VAR i: INTEGER;

BEGIN
  FOR i:=1 TO 9 DO;
    L.Linie(40+10*x+i,40+10*y+i,40+10*x+10-i,40+10*y+10-i);
    L.Linie(40+10*x+10-i,40+10*y+i,40+10*x+i,40+10*y+10-i)
  END;
END KreuzeKaestchen;

PROCEDURE EinsKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+2);
END EinsKaestchen;

PROCEDURE ZweiKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+3,40+10*y+2);
END ZweiKaestchen;

PROCEDURE DreiKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END DreiKaestchen;

PROCEDURE VierKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+5,40+10*y+7,40+10*x+5,40+10*y+2);
END VierKaestchen;

PROCEDURE FuenfKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+5);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END FuenfKaestchen;

PROCEDURE SechsKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END SechsKaestchen;

PROCEDURE SiebenKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+8);
END SiebenKaestchen;

PROCEDURE AchtKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+7,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+2);
  L.Linie(40+10*x+7,40+10*y+8,40+10*x+7,40+10*y+2);
END AchtKaestchen;

PROCEDURE BombeKaestchen(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+6,40+10*x+7,40+10*y+6);
  L.Linie(40+10*x+2,40+10*y+5,40+10*x+8,40+10*y+5);
  L.Linie(40+10*x+2,40+10*y+4,40+10*x+8,40+10*y+4);
  L.Linie(40+10*x+3,40+10*y+3,40+10*x+7,40+10*y+3);
  L.Linie(40+10*x+5,40+10*y+8,40+10*x+5,40+10*y+3);
END BombeKaestchen;

PROCEDURE Zufall(a: INTEGER);

VAR z: LONGINT; i,j,k,l:INTEGER; fertig: BOOLEAN; 
    gesetzt: ARRAY 41,41 OF BOOLEAN;

BEGIN
  Nummer:=0;
  RN.InitSeed(a);
  FOR i:=1 TO Feldgroesse DO; FOR j:=1 TO Feldgroesse DO; gesetzt[i,j]:=FALSE; END; END;
  WHILE ~fertig DO;
    z:= ENTIER(Feldgroesse*Feldgroesse*RN.Uniform());
    FOR i:=1 TO Feldgroesse DO
      FOR j:=1 TO Feldgroesse DO
        IF  z=0 THEN 
          IF ~gesetzt[i,j] THEN 
            Bombenfeld[i,j]:=TRUE;;
            FOR k:=1 TO 3 DO;
              FOR l:=1 TO 3 DO;
                INC(Anzahl[i-2+k,j-2+l]);
              END;
            END;
            gesetzt[i,j]:=TRUE;
            INC(Nummer);
            IF Nummer=Bomben THEN fertig:=TRUE END;
          END;
        END;
        DEC(z);
      END;
    END;
  END;
END Zufall;


PROCEDURE Kontrolle(x,y: INTEGER);

BEGIN
  LoescheKaestchen(x,y);
  INC(Schritte);
  IF Feld[x,y]=1 THEN KreuzeKaestchen(x,y); END;
  IF Feld[x,y]=2 THEN EinsKaestchen(x,y); END;
  IF Feld[x,y]=3 THEN ZweiKaestchen(x,y); END;
  IF Feld[x,y]=4 THEN DreiKaestchen(x,y); END;
  IF Feld[x,y]=5 THEN VierKaestchen(x,y); END;
  IF Feld[x,y]=6 THEN FuenfKaestchen(x,y); END;
  IF Feld[x,y]=7 THEN SechsKaestchen(x,y); END;
  IF Feld[x,y]=8 THEN SiebenKaestchen(x,y); END;
  IF Feld[x,y]=9 THEN AchtKaestchen(x,y); END;
  IF Feld[x,y]=10 THEN BombeKaestchen(x,y); END;  
  IF Feld[x,y]=11 THEN FuelleKaestchen(x,y); END;
END Kontrolle;

PROCEDURE AnzahlBomben(x,y: INTEGER);

BEGIN;
  IF ~(((x<1)OR(x>Feldgroesse))OR((y<1)OR(y>Feldgroesse))) THEN
    IF Anzahl[x,y]=1 THEN 
      IF Feld[x,y]=11 THEN EinsKaestchen(x,y); Feld[x,y]:=2; Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=2 THEN 
      IF Feld[x,y]=11 THEN ZweiKaestchen(x,y); Feld[x,y]:=3; Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=3 THEN
      IF Feld[x,y]=11 THEN DreiKaestchen(x,y);  Feld[x,y]:=4; Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=4 THEN
      IF Feld[x,y]=11 THEN  VierKaestchen(x,y); Feld[x,y]:=5;Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=5 THEN 
      IF Feld[x,y]=11 THEN FuenfKaestchen(x,y); Feld[x,y]:=6;Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=6 THEN
      IF Feld[x,y]=11 THEN  SechsKaestchen(x,y); Feld[x,y]:=7;Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=7 THEN 
      IF Feld[x,y]=11 THEN  SiebenKaestchen(x,y); Feld[x,y]:=8;Test[x,y]:=TRUE;END;
    ELSIF Anzahl[x,y]=8 THEN  
      IF Feld[x,y]=11 THEN AchtKaestchen(x,y);Feld[x,y]:=9;Test[x,y]:=TRUE; END;
    END;
  END;
END AnzahlBomben;

PROCEDURE OeffneFreieKaestchen(x,y: INTEGER);

VAR i,j: INTEGER;

BEGIN
FOR i:=0 TO 2 DO
  FOR j:=0 TO 2 DO
    IF ~Test[x-1+i,y-1+j] THEN
      IF ~(((x-1+i<1) OR (y-1+j<1)) OR ((x-1+i>Feldgroesse) OR (y-1+j>Feldgroesse))) THEN
        Test[x-1+i,y-1+j]:=TRUE;
        IF Feld[x-1+i,y-1+j]=11 THEN
          LoescheKaestchen(x-1+i,y-1+j); 
          IF Anzahl[x-1+i,y-1+j]>0 THEN 
            AnzahlBomben(x-1+i,y-1+j);
          ELSE
            Feld[x-1+i,y-1+j]:=0; 
            OeffneFreieKaestchen(x-1+i,y-1+j);
          END;
        END;
      END;
    END;
  END;
END;  
    
END OeffneFreieKaestchen;        

PROCEDURE Start*;

VAR x,y,i,j, Zaehler,VermuteteBomben: INTEGER; key: CHAR; geloest,abbruch,wechsel: BOOLEAN;
  
BEGIN
  In.Open; x:=234;
  In.Int(x);
  Feldgroesse:=10;
  In.Int(Feldgroesse);
  Bomben:=15; 
  In.Int(Bomben); 
  Out.Ln;
  MaleFeld;
  Zufall(x);
  x:=1; y:=1; Zaehler:=0; abbruch:=FALSE; wechsel:=FALSE;
  VermuteteBomben:=0;
  WHILE ~abbruch DO;
    key:=X.Key();
    IF Bomben+5>Feldgroesse*Feldgroesse THEN Out.String("Weniger Bomben !"); key:="q";END;
    IF key="8" THEN
      Kontrolle(x,y);
      INC(y); 
      IF y>Feldgroesse THEN y:=Feldgroesse; END; END;
    IF key="2" THEN       
      Kontrolle(x,y);
      DEC(y); 
      IF y<1 THEN y:=1;END; END;
    IF key="6" THEN 
      Kontrolle(x,y);
      INC(x); 
      IF x>Feldgroesse THEN x:=Feldgroesse; END; END;
    IF key="4" THEN 
      Kontrolle(x,y);
      DEC(x); 
      IF x<1 THEN x:=1;END; END;
    IF key="5" THEN
      IF Feld[x,y]=11 THEN Feld[x,y]:=1; Spielfeld[x,y]:=1; INC(VermuteteBomben);
      ELSIF Feld[x,y]=1 THEN Feld[x,y]:=11; Spielfeld[x,y]:=11; DEC(VermuteteBomben); END;
      wechsel:=TRUE;
      Out.String("VermuteteBomben: ");Out.Int(VermuteteBomben,3);
      Out.Char("/"); Out.Int(Bomben,3); Out.Ln;
      IF VermuteteBomben=Bomben THEN
        geloest:=TRUE;
        FOR i:=1 TO Feldgroesse DO;
          FOR j:=1 TO Feldgroesse DO;
            IF Bombenfeld[i,j] THEN
              IF Feld[i,j]#1 THEN geloest:=FALSE; Out.Char("."); END;
            END;
          END;
        END;
        IF geloest THEN Out.String("Bravo, du hast alle Bomben entdeckt."); Out.Ln; key:="q";
        Out.String("Koeffizient: "); Out.Int(100*Feldgroesse DIV Bomben * Schritte,3); Out.Ln; END;
      END;
    END;
    IF key=" " THEN
      IF ~Bombenfeld[x,y] THEN
        IF Spielfeld[x,y]=11 THEN 
          IF Anzahl[x,y]>=1 THEN LoescheKaestchen(x,y);
            AnzahlBomben(x,y); MarkKaestchen(x,y);
            ELSE 
            LoescheKaestchen(x,y);
            Feld[x,y]:=0;
            MarkKaestchen(x,y);
            Test[x,y]:=TRUE;
            OeffneFreieKaestchen(x,y);
          END;
        END;
      ELSE
        IF Spielfeld[x,y]=11 THEN
          Out.String("Treffer, Spiel leider fertig !"); Out.Ln;
          FOR i:=1 TO Feldgroesse DO; FOR j:=1 TO Feldgroesse DO;
            IF Bombenfeld[i,j] THEN 
              LoescheKaestchen(i,j);
              BombeKaestchen(i,j); 
              IF Feld[i,j]=1 THEN MarkKaestchen(i,j);END;
            END;
          END; END;
        key:="q";    
        END;
      END;
    END;
    IF wechsel THEN 
      LoescheKaestchen(x,y); 
      wechsel:=FALSE;
    END;
    IF Feld[x,y]=1 THEN MarkKaestchen(x,y); KreuzeKaestchen(x,y); 
      ELSIF Feld[x,y]=2 THEN MarkKaestchen(x,y); EinsKaestchen(x,y); 
      ELSIF Feld[x,y]=3 THEN MarkKaestchen(x,y); ZweiKaestchen(x,y); 
      ELSIF Feld[x,y]=4 THEN MarkKaestchen(x,y); DreiKaestchen(x,y); 
      ELSIF Feld[x,y]=5 THEN MarkKaestchen(x,y); VierKaestchen(x,y); 
      ELSIF Feld[x,y]=6 THEN MarkKaestchen(x,y); FuenfKaestchen(x,y); 
      ELSIF Feld[x,y]=7 THEN MarkKaestchen(x,y); SechsKaestchen(x,y); 
      ELSIF Feld[x,y]=8 THEN MarkKaestchen(x,y); SiebenKaestchen(x,y); 
      ELSIF Feld[x,y]=9 THEN MarkKaestchen(x,y); AchtKaestchen(x,y);
      ELSIF Feld[x,y]=10 THEN MarkKaestchen(x,y); BombeKaestchen(x,y);
      ELSIF Feld[x,y]=11 THEN MarkKaestchen(x,y); FuelleKaestchen(x,y);
      ELSE
      MarkKaestchen(x,y); 
    END;
    IF key="q" THEN abbruch:=TRUE; END;
  END;
END Start;

PROCEDURE Anleitung*;

BEGIN
  Out.String("Minesweeper Version Beta 1"); Out.Ln; 
  Out.String("8 = nach oben ; ");
  Out.String("2 = nach unten");Out.Ln;
  Out.String("4 = nach links; ");
  Out.String("6 = nach rechts");Out.Ln;
  Out.String("5 = Bombe markieren");Out.Ln;
  Out.String("(SPACE) = oeffnen");Out.Ln;
  Out.String("q = abbrechen");Out.Ln;
  Out.String("Minesweeper.Start Level Feldgroesse AnzahlBomben"); Out.Ln; 
  Out.String("Level = LONGINT Zahl"); Out.Ln;
  Out.String("Feldgroesse = 3 - 40"); Out.Ln;
  Out.String("AnzahlBomben = 1-(Feldgroesse^2-5)"); Out.Ln;
  Out.String("z.B. Minesweeper.Start 13546 10 18");Out.Ln;
END Anleitung;

BEGIN
Start
END Minesweeper.
