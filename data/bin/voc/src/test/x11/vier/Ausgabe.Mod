MODULE Ausgabe;





  IMPORT Out := Console, XYplane := oocXYplane;





  PROCEDURE RealFix*(x: REAL; n, m: INTEGER);


    VAR mul: LONGINT;


  BEGIN


    IF x < 0 THEN Out.Char("-"); x := -x END;


    IF m > 0 THEN


      mul := 1;


      REPEAT mul := mul*10; DEC(m) UNTIL m = 0;


      Out.Int(ENTIER(x+(0.5/mul)), n);


      Out.Char(".");


      IF ENTIER(mul*x+0.5) MOD mul = 0 THEN


        REPEAT mul := mul DIV 10; Out.Char("0") UNTIL mul = 1


      ELSE Out.Int(ENTIER(mul*x+0.5) MOD mul, 0)


      END


    ELSE Out.Int(ENTIER(x+0.5), n)


    END


  END RealFix;





  PROCEDURE Line*(X0, Y0, X1, Y1, mode: INTEGER);


  (* Draws a line from (X0, Y0) to (X1, Y1) inclusive. For all line points (x, y) the following holds


    always: (min(X0, X1) <= x) & (x <= max(X0, X1) & (min(Y0, Y0) <= y) & (y <= max(Y0, Y1). *)


    VAR x, y, dx, dy, d, inc, L, B, R, T, Xmin, Xmax, Ymin, Ymax: INTEGER;


  BEGIN


    L := XYplane.X; B := XYplane.Y; R := XYplane.X + XYplane.W; T := XYplane.Y + XYplane.H;


    IF X0 < X1 THEN Xmin := X0; Xmax := X1 ELSE Xmin := X1; Xmax := X0 END;


    IF Y0 < Y1 THEN Ymin := Y0; Ymax := Y1 ELSE Ymin := Y1; Ymax := Y0 END;


    IF (L <= Xmax) & (Xmin < R) & (B <= Ymax) & (Ymin < T) THEN (* line may be visible *)


      IF Xmin = Xmax THEN FOR y := Ymin TO Ymax DO XYplane.Dot(Xmin, y, mode) END


      ELSIF Ymin = Ymax THEN FOR x := Xmin TO Xmax DO XYplane.Dot(x, Ymin, mode) END


      ELSE


        IF (Y1-Y0) < (X0-X1) THEN x := X0; X0 := X1; X1 := x; y := Y0; Y0 := Y1; Y1 := y END;


        dx := 2*(X1-X0); dy := 2*(Y1-Y0); x := X0; y := Y0; inc := 1;


        IF (L <= Xmin) & (Xmax < R) & (B <= Ymin) & (Ymax < T) THEN (* no clipping *)


          IF dy > dx THEN d := dy DIV 2;


            IF dx < 0 THEN inc := -1; dx := -dx END;


            WHILE y <= Y1 DO


              XYplane.Dot(x, y, mode);


              INC(y); DEC(d, dx);


              IF d < 0 THEN INC(d, dy); INC(x, inc) END


            END


          ELSE d := dx DIV 2;


            IF dy < 0 THEN inc := -1; dy := -dy END;


            WHILE x <= X1 DO


              XYplane.Dot(x, y, mode);


              INC(x); DEC(d, dy);


              IF d < 0 THEN INC(d, dx); INC(y, inc) END


            END


          END


        ELSE  (* dot-wise clipping *)


          IF dy > dx THEN d := dy DIV 2;


            IF dx < 0 THEN inc := -1; dx := -dx END;


            WHILE y <= Y1 DO


              IF (L <= x) & (x < R) & (B <= y) & (y < T) THEN XYplane.Dot(x, y, mode) END;


              INC(y); DEC(d, dx);


              IF d < 0 THEN INC(d, dy); INC(x, inc) END


            END


          ELSE d := dx DIV 2;


            IF dy < 0 THEN inc := -1; dy := -dy END;


            WHILE x <= X1 DO


              IF (L <= x) & (x < R) & (B <= y) & (y < T) THEN XYplane.Dot(x, y, mode) END;


              INC(x); DEC(d, dy);


              IF d < 0 THEN INC(d, dx); INC(y, inc) END


            END


          END


        END


      END


    END


  END Line;





END Ausgabe.
