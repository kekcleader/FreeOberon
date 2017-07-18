(* Copyright 1996 by Michael Klein aka duke *)


(* Tastaturbelegung:


      Spiel starten:    Vier.HitMe {maximale Punktzahl} ~





      Spieler1:  q.....Zeiger links


              w....Zeiger rechts


              a.....Kreuz setzen





      Spieler2:  o.....Zeiger links


              p.....Zeiger rechts


              l.......Feld ausmalen  





      nach jedem Durchgang muss wieder neu mit ..."SPACE"... gestartet werden, bis die eingegebene


      Punktzahl von einem der beiden Spieler erreicht wird!





      unsanfter Abbruch mit ..."h"...    *)





(* Verbesserungsvorschlaege sind jederzeit herzlich willkommen:    mklein@g26.ethz.ch          

                bzw.    kleinm@ezinfo.vmsmail.ethz.ch *)





(* die 1-Player Version gegen die Maschine ist zur Zeit noch in Arbeit *)





    


MODULE Vier;





IMPORT 


  X:=oocXYplane, A:=Ausgabe, In := compatIn, O:=Console;





CONST


  breite = 30;


  square = 10;


  slide = 240;


  start = 60;


  beg = 50;


  m = 7;


  n = 6;





TYPE


  Array = ARRAY 7,6 OF INTEGER;





VAR


  a : Array;


  



PROCEDURE Signature(x,y,breite, field:INTEGER);
(* Schriftzug "Vier gewinnt" *)




VAR


  free,leer,h,k,char, space,high,s: INTEGER;





BEGIN


  char:=11;


  high := 24;


  space := 20;


  s := 3;


  leer:=char-2;


  free:=(field*breite-space-leer*s) DIV char;


  h:=y+high;


  (* V *)


  A.Line(x,h, x+(free DIV 2), y, 1);


  x:=x+(free DIV 2);


  A.Line(x,y, x+(free DIV 2),h,1);


  x:=x+free+s;


  (* I *)


  A.Line(x, y, x, h,1);


  x:=x+(free DIV 2)+s;


  (* E *)


  A.Line(x,y, x,h,1);


  A.Line(x,y, x+free, y,1);


  A.Line(x, h, x+free,  y+high, 1);


  A.Line(x,y+(high DIV 2), x+free, y+(high DIV 2),1);


  x:=x+free+s;


  (* R *)


  A.Line(x, y, x, h, 1);


  A.Line(x, h, x+free, h,1);


  A.Line(x+free, h, x+free, y+(high DIV 2), 1);


  A.Line(x+free, y+(high DIV 2), x, y+(high DIV 2),1 );


  A.Line(x, y+(high DIV 2), x+free, y, 1);


  x:=x+free+s+space;


  (* G *)


  A.Line(x, y, x, h,1);


  A.Line(x, h, x+free, h,1);


  A.Line(x,y, x+free, y,1);


  A.Line(x+free, y, x+free, y+(high DIV 2),1 );


  A.Line(x+free, y+(high DIV 2), x+(free DIV 2), y+(high DIV 2),1 );


  x:=x+free+s;


  (* E *)


  A.Line(x,y, x,h,1);


  A.Line(x,y, x+free, y,1);


  A.Line(x, h, x+free,  y+high, 1);


  A.Line(x,y+(high DIV 2), x+free, y+(high DIV 2),1);


  x:=x+free+s;


  (* W *)


  k:=(free+12) DIV 4;


  A.Line(x, h, x+k, y,1);


  A.Line(x+k, y, x+2*k, y+(high DIV 2),1 );


  A.Line(x+2*k, y+(high DIV 2), x+3*k, y, 1);


  A.Line(x+3*k, y, x+4*k, h,1);


  x:=x+4*k+s;


  (* I *)


  A.Line(x, y, x, h,1);


  x:=x+(free DIV 2)+s;


  (* N *)


  A.Line(x, y, x, h,1);


  A.Line(x, h, x+free, y,1);


  A.Line(x+free, y, x+free, h,1);


  x:= x+free+s;


  (* N *)


  A.Line(x, y, x, h,1);


  A.Line(x, h, x+free, y,1);


  A.Line(x+free, y, x+free, h,1);


  x:= x+free+s;


  (* T *)


  A.Line(x+(free DIV 2), y , x+(free DIV 2), h,1);


  A.Line(x, h, x+free,h,1);


  


END Signature;





(* ------------------------------------------------------- *)





PROCEDURE ArrayInit;





VAR


  i, j:INTEGER;





BEGIN


  FOR i:=0 TO m-1 BY 1 DO


    FOR j:=0 TO n-1 BY 1 DO


      a[i,j]:=0;


    END;


  END;


END ArrayInit;


  


(* ------------------------------------------------------- *)





PROCEDURE Spielfeld;





VAR


  i, j, h, b:INTEGER;





BEGIN


  b := m*breite+beg;


  h := n*breite+beg;  


  FOR i:= beg TO b BY breite DO


    A.Line(i, beg, i, h, 1);


  END;


  FOR j := beg TO h BY breite DO


    A.Line(beg, j, b, j, 1);


  END;


END Spielfeld;





(* ------------------------------------------------------- *)





PROCEDURE Cross(x, y:INTEGER);





BEGIN


  A.Line(x, y, x+breite, y+breite, 1);


  A.Line(x, y+breite, x+breite, y,1);


END Cross;





(* ------------------------------------------------------- *)





PROCEDURE Fill(x,y:INTEGER);





VAR


  i : INTEGER;





BEGIN


  FOR i:=x TO x+breite BY 1 DO


    A.Line(i, y, i, y+breite,1);


  END;


END Fill;





(* ------------------------------------------------------- *)





PROCEDURE SetSquare(x,y:INTEGER);





VAR


  i : INTEGER;





BEGIN


  FOR i:=x TO x+square BY 1 DO


    A.Line(i, y, i, y+square,1);


  END;


END SetSquare;





(* ------------------------------------------------------- *)





PROCEDURE RemoveSquare(x,y:INTEGER);





VAR


  i : INTEGER;


BEGIN


  FOR i:=x TO x+square BY 1 DO


    A.Line(i, y, i, y+square,0);


  END;


END RemoveSquare;





(* ------------------------------------------------------- *)





PROCEDURE FindField(x:INTEGER):INTEGER;





VAR


  h, fault : INTEGER;





BEGIN


  fault:=8;


  h:=5;


  WHILE h>=0 DO


    IF a[x,h]#0 THEN


      DEC(h);


    ELSE RETURN h;


    END;


  END;


  RETURN fault;


END FindField;  





(* ------------------------------------------------------- *)





PROCEDURE Mi(x,y:INTEGER):INTEGER;





BEGIN


  IF x>y THEN 


    RETURN y;


  ELSE 


    RETURN x;


  END;


END Mi;





(* ------------------------------------------------------- *)





PROCEDURE Ma(x,y:INTEGER):INTEGER;





BEGIN


  IF x>y THEN 


    RETURN x;


  ELSE 


    RETURN y;


  END;


END Ma;





(* ------------------------------------------------------- *)





PROCEDURE EndPointR(VAR k,l:INTEGER);





BEGIN


  WHILE (k<m-1) & (l>0) DO


    INC(k);  DEC(l);


  END;


END EndPointR;





(* ------------------------------------------------------- *)





PROCEDURE IsTerminated(x,y,p:INTEGER):BOOLEAN;





VAR


  i,j,k,l,min,max:INTEGER;


  term : BOOLEAN;





BEGIN


  term := FALSE;


  min:=Mi(x,y);


  max:=Ma(x,y);


  (* horizontal *)


  FOR i := 0 TO m-4 DO


    IF (a[i,y]=p) & (a[i+1,y]=p) & (a[i+2,y]=p) & (a[i+3,y]=p) THEN


      term := TRUE;


    END;


  END;


  (* vertikal *)


  FOR j := 0 TO n-4 DO


    IF (a[x,j]=p) & (a[x,j+1]=p) & (a[x,j+2]=p) & (a[x,j+3]=p) THEN


      term := TRUE;


    END;


  END;


  (* links oben --->  rechts unten *)


  k:=x-min;  l:=y-min;


  WHILE (k+3<m) & (l+3<n) DO


    IF (a[k,l]=p) & (a[k+1,l+1]=p) & (a[k+2,l+2]=p) & (a[k+3,l+3]=p) THEN


      term := TRUE;


    END;


  INC(k);  INC(l);


  END;


  (* rechts oben ---> links unten *)


  k:=x;  l:=y; 


  EndPointR(k,l);


  WHILE (k-3 >= 0) & (l+3 < n) & (l >= 0) & (k <=m-1 ) DO


    IF (a[k,l]=p) & (a[k-1,l+1]=p) & (a[k-2,l+2]=p) & (a[k-3,l+3]=p) THEN


      term := TRUE;


    END;


  DEC(k);  INC(l);


  END;


  RETURN term;


END IsTerminated;





(* ------------------------------------------------------- *)





PROCEDURE ChangePlayer(VAR player1, player2:BOOLEAN);





BEGIN


  IF player1 THEN


    player1 := FALSE;


    player2 := TRUE;


  ELSE player1:= TRUE;


    player2:= FALSE;


  END;


END ChangePlayer;





(* ------------------------------------------------------- *)





PROCEDURE HitMe*;





VAR


  abbruch ,spieler1, spieler2, cross, fill: BOOLEAN;


  key:CHAR;


  sl, st,lauf,w,v, point1, point2,outof:INTEGER;





BEGIN  


  In.Open;


  In.Int(outof);


  O.String("Vier gewinnt for Oberon V1.0 by Michael Klein aka duke...");  O.Ln;  O.Ln;


  O.String("Punktestand:");  O.Ln;  O.Ln;


  point1 := 0;  point2 := 0;


  spieler1 := TRUE;  spieler2 := FALSE;


  WHILE (point1<outof) & (point2<outof) DO 


    X.Clear;


    abbruch:=FALSE;


    ArrayInit;


    Spielfeld;  


    Signature(50, 260, 30, 7);


    sl:=slide;  st:=start;  lauf:=0;


    SetSquare(st, sl);


    cross := FALSE;  fill := FALSE;


    WHILE ~abbruch DO


      key:=X.Key();


      IF (spieler1 & (key = "w")) OR (spieler2 & (key = "p")) THEN


        RemoveSquare(st, sl);


        IF st = beg+6*breite+10 THEN


          st:=start;


          lauf:=0;


        ELSE st:=st+breite;


          INC(lauf);


        END;


        SetSquare(st, sl);


      END;


      IF (spieler1 & (key = "q"))  OR (spieler2 & (key = "o")) THEN


        RemoveSquare(st, sl);


        IF st = start THEN


          st:=beg+6*breite+10;


          lauf:=6;


        ELSE st:=st-breite;


          DEC(lauf);


        END;


        SetSquare(st, sl);


      END;


      IF (spieler1 & (key="a")) THEN


        w:=FindField(lauf);


        IF (w>=0) & (w<=5) THEN


          Cross(st-10, (5-w)*breite+beg);


          a[lauf,w]:=1;


          cross:= TRUE;


        abbruch:=IsTerminated(lauf,w,1);


        END;


        IF abbruch  THEN


          INC(point1);


        END;


      END;


      IF (spieler2 & (key="l")) THEN


        v:=FindField(lauf);


        IF (v>=0) & (v<=5) THEN


          Fill(st-10, (5-v)*breite+beg);


          a[lauf,v]:=2;


          fill := TRUE;


          abbruch:=IsTerminated(lauf,v,2);


        END;


        IF abbruch  THEN


          INC(point2);


        END;


      END;


      IF key="h" THEN


        HALT(35);


      END;


      IF cross OR fill THEN


        ChangePlayer(spieler1, spieler2);


      END;


      cross := FALSE;  fill := FALSE;


    END;


    RemoveSquare(st,sl);


    O.String("Spieler1: ");  O.Int(point1,3);  O.Ln;


    O.String("Spieler2: ");  O.Int(point2,3);  O.Ln;  O.Ln;


    REPEAT


    UNTIL X.Key() = " ";


  END;


END HitMe;





(* ------------------------------------------------------- *)





BEGIN


  X.Open;


  (*O.Open;*)
   HitMe

END Vier.


    









