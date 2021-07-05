(* Copyright 1999-2001, Patrick Hunziker

  This library is free software; you can redistribute it and/or modify it under the terms of the
  GNU Library General Public License as published by the Free Software Foundation;
  either version 2 of the License, or any later version.

  This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Library General Public License for more details.

  You should have received a copy of the GNU Library General Public License along with this library;
  if not, write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Patrick Hunziker,Basel.
email Patrick.Hunziker@unibas.ch
*)

(** Version 1.0, 19.1.2001 *)

MODULE MultiArrayRiders;  (** Patrick Hunziker, Basel,  **)
(** Implements an array rider access mechanism for multidimensional arrays of arbitrary
    dimensions defined in MultiArrays*)
IMPORT MultiArrays, Out := Console, Input := Platform;
CONST (** behaviour of array rider at end of array line;
        not yet completely implemented.
        The seemingly more exotic variants are especially useful in image processing *)
  halt = 0;
  zeropadding = 1;  (* not yet implemented *)
  constant = 2;    (* not yet implemented *)
  circular* = 3;  (** after finishing one line, the same line is restarted *)
  mirror = 4;      (* not yet implemented *)
  incremental* = 5; (** after finishing one line, the next line is started *)

  (** rider has not passed any border of the array *)
  noteol* = MAX(LONGINT);

TYPE
    (** Array riders allow traversal of arbitrary dimensional array using procedures Inc() and Dec(),
        and can be positioned using Set(). *)
    Rider* = RECORD
      array-: MultiArrays.Array; (** points to the array the rider is based on *)
      order-: LONGINT;   (** dimensionality of array *)
      offset- : LONGINT;  (** Rider position in linear array representation *)
      eol*: LONGINT;     (** Rider has gone beyond the border of the
                       line of indicated dimension .
                       if eol=noteol, rider is inside array *)
      eolBehaviour*: INTEGER; (** What to do when reaching eol. Not yet completely satisfactory *)
      dimension,        (* dimensions of Array, in vector notation *)
      pos,              (* position of rider in Array, in vector notation *)
      step:     MultiArrays.SizeVector;  (* unit increment for offset in each dimension, in vector notation *)
      END;

    PROCEDURE CalculatePos (pos, dimension: MultiArrays.SizeVector): LONGINT;
      VAR maxI, res, i: LONGINT;
      BEGIN
        maxI := LEN(dimension^)-1;
        ASSERT(LEN(pos^) = LEN(dimension^));
        res := pos[maxI];
        FOR i := 1 TO maxI DO res := res*dimension[maxI-i]+pos[maxI-i] END;
        RETURN res
      END CalculatePos;

    PROCEDURE InitRider* (VAR R: Rider; A: MultiArrays.Array; pos: MultiArrays.SizeVector);
            (** Sets array rider in position pos in array A *)
      VAR i, step: LONGINT;
      BEGIN
        ASSERT(MultiArrays.Order(A) = LEN(pos^));
        R.array := A;
        R.order := MultiArrays.Order(A);
        NEW(R.pos,R.order);
        NEW(R.step,R.order);
        NEW(R.dimension,R.order);
        step := 1;
        FOR i := 0 TO R.order-1 DO
          ASSERT(pos[i] <= MultiArrays.Len(A,i));
          R.pos[i] := pos[i];
          R.step[i] := step; step := step*MultiArrays.Len(A,i);
          R.dimension[i] := MultiArrays.Len(A,i)
        END;
        R.eol := noteol;
        R.offset := CalculatePos(R.pos,MultiArrays.Size(A));
        R.eolBehaviour := incremental
      END InitRider;

    PROCEDURE SetRider* (VAR R: Rider; pos: MultiArrays.SizeVector);
    VAR i: LONGINT;
    BEGIN
      ASSERT(R.array # NIL);
      ASSERT(LEN(pos^) = R.order);
      FOR i := 0 TO R.order-1 DO ASSERT(pos[i] < R.dimension[i]); R.pos[i] := pos[i] END;
      R.offset := CalculatePos(pos,R.dimension);
      R.eol := noteol
    END SetRider;

    PROCEDURE Inc* (VAR R: Rider; Dim: LONGINT);
            (** array rider advances one element in dimension Dim;
        at end of line, eol is assigned the number of the dimension overflown *)
      BEGIN
        ASSERT(Dim < R.order);
        IF R.pos[Dim] < R.dimension[Dim]-1
        THEN INC(R.pos[Dim]); INC(R.offset, R.step[Dim]);
        ELSE
          R.eol := Dim;
          CASE R.eolBehaviour OF
            halt: HALT(100);
            | zeropadding: HALT(100); (* not yet implemented *)
            | constant:
            | mirror: HALT(100); (* not yet implemented *)
            | incremental:
              R.pos[Dim] := 0;
              IF Dim < R.order-1
              THEN
                INC(R.offset, R.step[Dim]-R.step[Dim+1]);
                Inc(R, R.eol+1)
              ELSE INC(R.offset, R.step[Dim]-R.array.len)
              END
            | circular:
              R.pos[Dim] := 0;
              IF Dim < R.order-1
              THEN INC(R.offset, R.step[Dim]-R.step[Dim+1])
              ELSE INC(R.offset, R.step[Dim]-R.array.len)
              END
            ELSE HALT(100)
          END
        END
      END Inc;

    PROCEDURE Dec* (VAR R: Rider; Dim: LONGINT);
            (** array rider goes back one element in dimension Dim *)
      BEGIN
        ASSERT(Dim < R.order);
        IF R.pos[Dim] > 0
        THEN DEC(R.pos[Dim]); DEC(R.offset, R.step[Dim]);
        ELSE R.eol := Dim;
          CASE R.eolBehaviour OF
            halt: HALT(100);
            | zeropadding: HALT(100); (* not yet implemented *)
            | constant:
            | mirror: HALT(100); (* not yet implemented *)
            | incremental:
              R.pos[Dim] := R.dimension[Dim]-1;
              IF Dim > 0
              THEN
                DEC(R.offset, R.step[Dim]-R.step[Dim+1]);
                Dec(R, R.eol+1)
              ELSE DEC(R.offset, R.step[Dim]-R.array.len)
              END
            | circular:
              R.pos[Dim] := R.dimension[Dim]-1;
              IF Dim > 0
              THEN DEC(R.offset, R.step[Dim]-R.step[Dim+1])
              ELSE DEC(R.offset, R.step[Dim]-R.array.len)
              END
            ELSE HALT(100)
          END
        END
      END Dec;

    PROCEDURE Pos* (R: Rider): MultiArrays.SizeVector;
            (** gives actual position of R in its associated array *)
      VAR i: LONGINT; res: MultiArrays.SizeVector;
      BEGIN
        NEW(res,R.order);
        FOR i := 0 TO R.order-1 DO res[i] := R.pos[i] END;
        RETURN res
      END Pos;

(** elementwise reading from Array Rider, followed by advancing the rider by
one step in direction "dir"; with specific "eolBehaviour" (see above) at border of array *)
    PROCEDURE ReadSInt* (VAR R: Rider; dir: LONGINT; VAR s: SHORTINT);
    BEGIN
      IF R.array IS MultiArrays.SIntArray
      THEN s := R.array(MultiArrays.SIntArray).s[R.offset]; Inc(R, dir)
      ELSE HALT(100)
      END
    END ReadSInt;

    PROCEDURE ReadSIntRun* (VAR R: Rider; dir: LONGINT;
                              VAR srun: ARRAY OF SHORTINT; n: LONGINT);
    VAR i, step, offset, pos, dim: LONGINT; array: MultiArrays.SIntArray;
    BEGIN
      ASSERT(LEN(srun) >= n);
      ASSERT(dir < R.order);
      ASSERT(R.array IS MultiArrays.SIntArray);
      array := R.array(MultiArrays.SIntArray);
      offset := R.offset;
      step := R.step[dir];
      pos := R.pos[dir];
      dim := R.dimension[dir];
      CASE R.eolBehaviour OF
         halt: HALT(100); (* not yet implemented *)
      | incremental:
        IF offset+(n-1)*step < R.array.len
        THEN FOR i := 0 TO n-1 DO srun[i] := array.s[offset]; INC(offset, step) END
        ELSE HALT(100) (* not yet implemented *)
        END
      | circular:
        IF R.pos[dir]+n-1 < dim
        THEN FOR i := 0 TO n-1 DO srun[i] := array.s[offset]; INC(offset, step) END
        ELSE
          FOR i := 0 TO n-1 DO
            srun[i] := array.s[offset+((pos+i) MOD dim)*step] (* can further be optimized *)
          END
        END
      ELSE HALT(100) (* not yet implemented *)
      END
    END ReadSIntRun;

    PROCEDURE ReadInt* (VAR R: Rider; dir: LONGINT; VAR i: INTEGER);
    BEGIN
      IF R.array IS MultiArrays.IntArray
      THEN i := R.array(MultiArrays.IntArray).i[R.offset]; Inc(R, dir);
      ELSE HALT(100)
      END
    END ReadInt;

    PROCEDURE ReadLInt* (VAR R: Rider; dir: LONGINT; VAR j: LONGINT);
    BEGIN
      IF R.array IS MultiArrays.LIntArray
      THEN j := R.array(MultiArrays.LIntArray).j[R.offset]; Inc(R, dir)
      ELSE HALT(100)
      END
    END ReadLInt;

(*    PROCEDURE ReadHInt* (VAR R: Rider; dir: LONGINT; VAR h: HUGEINT);
    BEGIN
      HALT(100) (* yet to implement *)
    END ReadHInt; *)

    PROCEDURE ReadReal* (VAR R: Rider; dir: LONGINT; VAR x: REAL);
    BEGIN
      IF R.array IS MultiArrays.RealArray
      THEN x := R.array(MultiArrays.RealArray).x[R.offset]; Inc(R, dir)
      ELSE HALT(100)
      END;
    END ReadReal;

    PROCEDURE ReadRealRun* (VAR R: Rider; dir: LONGINT;
                              VAR srun: ARRAY OF REAL; n: LONGINT);
    VAR i, step, offset, pos, dim: LONGINT; array: MultiArrays.RealArray;
    BEGIN
      ASSERT(LEN(srun) >= n);
      ASSERT(dir < R.order);
      ASSERT(R.array IS MultiArrays.RealArray);
      array := R.array(MultiArrays.RealArray);
      offset := R.offset;
      step := R.step[dir];
      pos := R.pos[dir];
      dim := R.dimension[dir];
      CASE R.eolBehaviour OF
         halt: HALT(100); (* not yet implemented *)
      | incremental:
        IF offset+(n-1)*step < R.array.len
        THEN FOR i := 0 TO n-1 DO srun[i] := array.x[offset]; INC(offset, step) END
        ELSE HALT(100) (* not yet implemented *)
        END;
      | circular:
        IF R.pos[dir]+n-1 < dim
        THEN FOR i := 0 TO n-1 DO srun[i] := array.x[offset]; INC(offset, step) END
        ELSE
          FOR i := 0 TO n-1 DO
            srun[i] := array.x[offset+((pos+i) MOD dim)*step] (* can further be optimized *)
          END
        END
      ELSE HALT(100) (* not yet implemented *)
      END
    END ReadRealRun;

    PROCEDURE ReadLReal* (VAR R: Rider; dir: LONGINT; VAR y: LONGREAL);
    BEGIN
      IF R.array IS MultiArrays.LRealArray
      THEN y := R.array(MultiArrays.LRealArray).y[R.offset]; Inc(R, dir)
      ELSE HALT(100)
      END
    END ReadLReal;

(*    PROCEDURE ReadBool* (VAR R: Rider; dir: LONGINT; VAR b: BOOLEAN);
    BEGIN
      HALT(100) (* to implement *)
    END ReadBool; *)

(*    PROCEDURE ReadComplex* (VAR R: Rider; dir: LONGINT; VAR z: MultiArrays.Complex);
    BEGIN
      HALT(100) (* yet to implement *)
    END ReadComplex; *)

    PROCEDURE WriteSInt* (VAR R: Rider; dir: LONGINT; s: SHORTINT);
    BEGIN
      IF R.array IS MultiArrays.SIntArray
      THEN R.array(MultiArrays.SIntArray).s[R.offset] := s; Inc(R, dir)
      ELSE HALT(100) END
    END WriteSInt;

    PROCEDURE WriteInt* (VAR R: Rider; dir: LONGINT; i: INTEGER);
    BEGIN
      IF R.array IS MultiArrays.IntArray
      THEN R.array(MultiArrays.IntArray).i[R.offset] := i; Inc(R, dir)
      ELSE HALT(100) END
    END WriteInt;

    PROCEDURE WriteLInt* (VAR R: Rider; dir: LONGINT; j: LONGINT);
    BEGIN
      IF R.array IS MultiArrays.LIntArray
      THEN R.array(MultiArrays.LIntArray).j[R.offset] := j; Inc(R, dir)
      ELSE HALT(100) END
    END WriteLInt;

(*    PROCEDURE WriteHInt* (VAR R: Rider; dir: LONGINT; h: HUGEINT);
    BEGIN
      HALT(100); (* yet to implement *) END
    END WriteHInt; *)

    PROCEDURE WriteReal* (VAR R: Rider; dir: LONGINT; x: REAL);
    BEGIN
      IF R.array IS MultiArrays.RealArray
      THEN R.array(MultiArrays.RealArray).x[R.offset] := x; Inc(R, dir)
      ELSE HALT(100) END
    END WriteReal;

    PROCEDURE WriteRealRun* (VAR R: Rider; dir: LONGINT; srun: ARRAY OF REAL; n: LONGINT);
    VAR i, step, offset, pos, dim: LONGINT; array: MultiArrays.RealArray;
    BEGIN
      ASSERT(LEN(srun) >= n);
      ASSERT(dir < R.order);
      ASSERT(R.array IS MultiArrays.RealArray);
      array := R.array(MultiArrays.RealArray);
      offset := R.offset;
      step := R.step[dir];
      pos := R.pos[dir];
      dim := R.dimension[dir];
      CASE R.eolBehaviour OF
         halt: HALT(100); (* not yet implemented *)
      | incremental:
        IF offset+(n-1)*step < R.array.len
        THEN
          FOR i := 0 TO n-1 DO array.x[offset] := srun[i]; INC(offset, step) END
        ELSE HALT(100) (* not yet implemented *)
        END
      | circular:
        IF R.pos[dir]+n-1 < dim
        THEN
          FOR i := 0 TO n-1 DO array.x[offset] := srun[i]; INC(offset, step) END
        ELSE
          FOR i := 0 TO n-1 DO
            array.x[offset+((pos+i) MOD dim)*step] := srun[i] (* can further be optimized *)
          END
        END
      ELSE HALT(100) (* not yet implemented *)
      END
    END WriteRealRun;

    PROCEDURE WriteLReal* (VAR R: Rider; dir: LONGINT; y: LONGREAL);
    BEGIN
      IF R.array IS MultiArrays.LRealArray
      THEN R.array(MultiArrays.LRealArray).y[R.offset] := y; Inc(R, dir)
      ELSE HALT(100) END
    END WriteLReal;

    PROCEDURE WriteBool* (VAR R: Rider; dir: LONGINT; b: BOOLEAN);
    BEGIN
      IF R.array IS MultiArrays.BoolArray
      THEN R.array(MultiArrays.BoolArray).b[R.offset] := b; Inc(R, dir)
      ELSE HALT(100) END
    END WriteBool;

(*    PROCEDURE WriteComplex* (VAR R: Rider; dir: LONGINT; VAR z: MultiArrays.Complex);
    BEGIN
      HALT(100) (* yet to implement *)
    END WriteComplex; *)

    PROCEDURE InvertSign (s: SHORTINT): SHORTINT; (* Test procedure for unary operations *)
    BEGIN
      RETURN -s
    END InvertSign;

    PROCEDURE Assign (VAR S: SHORTINT;s: SHORTINT); (* Testing *)
    BEGIN
      S := s
    END Assign;


    PROCEDURE Test*; (** Tests if eol mechanism is working correctly *)
      VAR pos, dimension: MultiArrays.SizeVector; A: MultiArrays.Array;
      i, j: LONGINT; R: Rider;
      BEGIN
        MultiArrays.SizeVector4(dimension, 10, 10, 10, 10);
        MultiArrays.SizeVector4(pos, 2, 3, 4, 5);
        NEW(A); MultiArrays.InitInt(A, dimension, NIL, FALSE);
        InitRider(R,A,pos);
        R.eolBehaviour := circular;
        FOR j := 0 TO 3 DO
          FOR i := 1 TO 10 DO
            Inc(R, j); Out.Int(CalculatePos(R.pos,MultiArrays.Size(A)), 5); Out.Ln;
            IF R.eol#noteol THEN
              Out.String("R.eol:"); Out.Int(R.eol, 5); Out.Ln;
              R.eol := noteol
            END
          END;
          Out.String("----"); Out.Ln
        END
      END Test;

      PROCEDURE Test1*;
      VAR A1: MultiArrays.Array;
          SA: ARRAY 256 OF SHORTINT;
          R1: Rider;
          dim0, dim1: MultiArrays.SizeVector;
          starttime, endtime, a, b, c, d, opcount1, opcount2: LONGINT;
          A3: POINTER TO ARRAY OF ARRAY OF ARRAY OF ARRAY OF SHORTINT;
          s: SHORTINT;
      BEGIN
        Out.Ln;
        Out.String("**********************************"); Out.Ln;
        Out.String(" Benchmark:"); Out.Ln;
        Out.String(" Arbitrary arrays with riders vs. ARRAY[x,y,z,...] concept"); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;
        MultiArrays.SizeVector4(dim0, 0, 0, 0, 0);
        MultiArrays.SizeVector4(dim1, 256, 128, 8, 8);
        MultiArrays.InitSInt(A1, dim1, NIL, FALSE);
        InitRider(R1, A1, dim0);
        R1.eolBehaviour := incremental;
        opcount1 := 0;
(* ASSIGN *)
        starttime := Input.Time();
        REPEAT          (* main loop of elementwise rider writing *)
              ReadSInt(R1,0,s);
              INC(opcount1);
            UNTIL R1.eol=R1.order-1;
        endtime := Input.Time();
        Out.String("ASSIGN:");Out.Ln;
        Out.String("Arbitrary multidimensional array: elementwise writing:"); Out.Ln;
        Out.String("  time: "); Out.Int(endtime-starttime,5);
        Out.String("  opcount: "); Out.Int(opcount1, 5); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;
        MultiArrays.SizeVector4(dim0,0,0,0,0);
        MultiArrays.SizeVector4(dim1,256,128,8,8);
        SetRider(R1,dim0); R1.eolBehaviour := circular;
        opcount2 := 0;
        dim0[0] := 0;
        starttime := Input.Time();
            FOR b := 0 TO dim1[1]-1 DO  (* main loop of linewise reading *)
              dim0[1] := b;
              FOR c := 0 TO dim1[2]-1 DO
                dim0[2] := c;
                FOR d := 0 TO dim1[3]-1 DO
                  dim0[3] := d;
                  SetRider(R1,dim0);
                  ReadSIntRun(R1,0,SA,256);
                  INC(opcount2, 256)
                END
              END
            END;
        endtime := Input.Time();
        Out.String(" Arbitrary multidimensional array: line reading with rider"); Out.Ln;
        Out.String("  time:  ");
        Out.Int(endtime-starttime, 5);
        Out.String("  opcount: "); Out.Int(opcount2, 5); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;

        NEW(A3, 256, 128, 8, 8 );
        starttime := Input.Time();
        opcount2 := 0;
        FOR a := 0 TO LEN(A3^,0)-1 DO   (* main loop of conventional array handling *)
              FOR b := 0 TO LEN(A3^,1)-1 DO
                FOR c := 0 TO LEN(A3^,2)-1 DO
                  FOR d := 0 TO LEN(A3^,3)-1 DO
                      SA[a] := A3[a,b,c,d]; INC(opcount2)
                    END
                END
              END
            END;
        endtime := Input.Time();
        Out.String(" conventional multidimensional array: index line reading:"); Out.Ln;
        Out.String("  time:  ");
        Out.Int(endtime-starttime, 5);
        Out.String("  opcount: "); Out.Int(opcount2, 5); Out.Ln;
        Out.String("**********************************"); Out.Ln
  END Test1;

(* Intel may have register problems with the following procedure *)
(*    PROCEDURE Test2*;
      VAR A1, A2: MultiArrays.Array;
          R1: Rider;
          dim0, dim1: MultiArrays.SizeVector;
          i, starttime, endtime, a, b, c, d, e, f, dir, opcount1, opcount2: LONGINT;
          A3: POINTER TO ARRAY OF ARRAY OF ARRAY OF ARRAY OF ARRAY OF ARRAY OF SHORTINT;
          s: SHORTINT;
      BEGIN
        Out.Ln;
        Out.String("**********************************"); Out.Ln;
        Out.String(" Benchmark:"); Out.Ln;
        Out.String(" Arbitrary arrays with riders vs. ARRAY[x,y,z,...] concept"); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;
        NEW(dim0, 6); FOR i := 0 TO 5 DO dim0[i] := 0 END;
        NEW(dim1, 6);
        dim1[0] :=  64; dim1[1] :=  32; dim1[2] :=  16; dim1[3] :=  16;
        dim1[4] :=  2; dim1[5] :=  2;
        MultiArrays.InitSInt(A1, dim1, NIL, FALSE);
        InitRider(R1, A1, dim0);
        R1.eolBehaviour := incremental;
        opcount1 := 0;
(* ASSIGN *)
        starttime := Input.Time();
        REPEAT
          WriteSInt(R1,0,1);
          INC(opcount1);
        UNTIL R1.eol=5;
        endtime := Input.Time();
        Out.String("ASSIGN:");Out.Ln;
        Out.String("arbitrary array rider assignement:"); Out.Ln;
        Out.String("  time: "); Out.Int(endtime-starttime, 5);
        Out.String("  opcount: "); Out.Int(opcount1, 5); Out.Ln;
        Out.String("----------------------------------"); Out.Ln;

        NEW(A3, 64,32,16,16, 2,2);
        starttime := Input.Time();
        opcount2 := 0;
        FOR a := 0 TO LEN(A3^,0)-1 DO
          FOR b := 0 TO LEN(A3^,1)-1 DO
            FOR c := 0 TO LEN(A3^,2)-1 DO
              FOR d := 0 TO LEN(A3^,3)-1 DO
                FOR e := 0 TO LEN(A3^,4)-1 DO
                  FOR f := 0 TO LEN(A3^,5)-1 DO
                    Assign(A3[a,b,c,d,e,f],1); INC(opcount2)
                  END
                END
              END
            END
          END
        END;
        endtime := Input.Time();
        Out.String("multidim index assignement:"); Out.Ln;
        Out.String("  time:  ");
        Out.Int(endtime-starttime, 5);
        Out.String("  opcount: "); Out.Int(opcount2, 5); Out.Ln
END Test2;
*)

BEGIN
END MultiArrayRiders.

MultiArrayRiders.Test1 (4D), MultiArrayRiders.Test2 (6D)

Compares execution times for
                    -arbitrary dimensional approach with riders
                    -conventional ARRAY [x,y,z,...] approach
This is done for elementwise assignements and reading of "runs" of data.

