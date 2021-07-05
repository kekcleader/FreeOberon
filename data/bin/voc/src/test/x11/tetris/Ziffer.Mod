MODULE Ziffer;

IMPORT X:=oocXYplane, L:=Linie, In := compatIn, Out := Console, RN:=ethRandomNumbers;

PROCEDURE Loesche*(x,y: INTEGER);

VAR i: INTEGER;

BEGIN
  FOR i:=1 TO 9 DO;
    L.LoescheLinie(40+10*x+1,40+10*y+i,40+10*x+9,40+10*y+i);
  END;
END Loesche;

PROCEDURE Eins*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+2);
END Eins;

PROCEDURE Zwei*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+3,40+10*y+2);
END Zwei;

PROCEDURE Drei*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+8,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END Drei;

PROCEDURE Vier*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+5,40+10*y+7,40+10*x+5,40+10*y+2);
END Vier;

PROCEDURE Fuenf*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+6,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+5);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END Fuenf;

PROCEDURE Sechs*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+6,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+6,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+2);
  L.Linie(40+10*x+6,40+10*y+5,40+10*x+6,40+10*y+2);
END Sechs;

PROCEDURE Sieben*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+8);
END Sieben;

PROCEDURE Acht*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+7,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+2);
  L.Linie(40+10*x+7,40+10*y+8,40+10*x+7,40+10*y+2);
END Acht;

PROCEDURE Neun*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+5,40+10*x+7,40+10*y+5);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+5);
  L.Linie(40+10*x+7,40+10*y+8,40+10*x+7,40+10*y+2);
END Neun;

PROCEDURE Null*(x,y: INTEGER);

BEGIN
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+7,40+10*y+8);
  L.Linie(40+10*x+3,40+10*y+2,40+10*x+7,40+10*y+2);
  L.Linie(40+10*x+3,40+10*y+8,40+10*x+3,40+10*y+2);
  L.Linie(40+10*x+7,40+10*y+8,40+10*x+7,40+10*y+2);
END Null ;

PROCEDURE Zeichne*(Laenge, Zahl, x,y: INTEGER);

VAR j,a,i,k: INTEGER;

BEGIN;
  FOR i:=0 TO Laenge-1 DO;
    Loesche(x+i,y); 
    a:=1;
    FOR k:=2 TO Laenge-i DO
      a:=10*a;
    END;
    j:=Zahl DIV a;
    IF j=0 THEN Null(x+i,y);
      ELSIF j=1 THEN Eins(x+i,y);
      ELSIF j=2 THEN Zwei(x+i,y);
      ELSIF j=3 THEN Drei(x+i,y);
      ELSIF j=4 THEN Vier(x+i,y);
      ELSIF j=5 THEN Fuenf(x+i,y);
      ELSIF j=6 THEN Sechs(x+i,y);
      ELSIF j=7 THEN Sieben(x+i,y);
      ELSIF j=8 THEN Acht(x+i,y);
      ELSIF j=9 THEN Neun(x+i,y);
    END;
    Zahl:=Zahl - j*a;
  END;
END Zeichne;

END Ziffer.


