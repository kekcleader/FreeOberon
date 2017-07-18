MODULE MultiArrays;  (** P. Hunziker, Basel,  **)
(**
AIM: To provide a library solution for
a multidimensional array type for numbers of arbitrary dimensions,
with the following features:
  -compatible types for 1,2,3..n dimensions, allowing exchangeable use in procedure headers etc
    -> generic/OO procedures for multidimensional array handling can be implemented
  -arrays can be accessed in multiple ways:
    -a) conventional indexing (though not by using brackets[ ], but using procedure IndexN. )
    -b) in a linear fashion (fast)
    -c) using an "ALL()" procedure without need for index handling by the user (very fast !)
    -d) using array riders movable along arbitrary axis (Module MultiArrayRiders)
    -e) by reading "runs" of data with rider (Module MultiArrayRiders)

A type 'scalar' is also based on the same base type as arrays, to allow mixing of arrays and scalars
in procedure headers, for more generic procedure headers when e.g. defining array operations:
(e.g. PROCEDURE Add(d1, d2: Data): Data;
 can be used for mixed expressions of arrays and numbers).
 This is in the hope that a family of array handling modules similar to the functionality of
 MATLAB or APL will be based on these types in the future.  (Help is welcome !).

  See 'Test', 'Test1', procedures in both modules for insight how to use them.
*)


(** Copyright 1999-2001, Patrick Hunziker

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
(** Version 0.9, 19.1.2001 *)
IMPORT Out := Console, Input := Platform; (* Import only needed for Demo purposes *)

TYPE
    SIntPtr* = POINTER TO ARRAY OF SHORTINT;
    IntPtr* = POINTER TO ARRAY OF INTEGER;
    LIntPtr* = POINTER TO ARRAY OF LONGINT;
(*    HIntPtr* = POINTER TO ARRAY OF HUGEINT; *)
    RealPtr* = POINTER TO ARRAY OF REAL;
    LRealPtr* = POINTER TO ARRAY OF LONGREAL;
    BoolPtr* = POINTER TO ARRAY OF BOOLEAN;
(*    ComplxPtr* = POINTER TO ARRAY OF COMPLEX; *)

    Data* = POINTER TO DataDesc; (** abstract base type, not containing data.
                            This could be an Objects.Object for S3 *)
    DataDesc* = RECORD END;

    Scalar* = POINTER TO ScalarDesc; (** abstract base type, not containing data. *)
    ScalarDesc* = RECORD (DataDesc) END;

    SInt* = POINTER TO SIntDesc;
    SIntDesc* = RECORD (ScalarDesc)
      s*: SHORTINT;
    END;

    Int* = POINTER TO IntDesc;
    IntDesc* = RECORD (ScalarDesc)
      i*: INTEGER;
    END;

    LInt* = POINTER TO LIntDesc;
    LIntDesc* = RECORD (ScalarDesc)
      j*: LONGINT;
    END;

(*    HInt* = POINTER TO HIntDesc;
    HIntDesc* = RECORD (ScalarDesc)
      h*: HUGEINT;
    END;
*)
    Real* = POINTER TO RealDesc;
    RealDesc* = RECORD (ScalarDesc)
      x*: REAL;
    END;

    LReal* = POINTER TO LRealDesc;
    LRealDesc* = RECORD (ScalarDesc)
      y*: LONGREAL;
    END;

    Bool* = POINTER TO BoolDesc;
    BoolDesc* = RECORD (ScalarDesc)
      b*: BOOLEAN;
    END;

    Complex* = POINTER TO ComplexDesc;
    ComplexDesc* = RECORD (ScalarDesc)
      r*, i*: REAL;
    END;

    SizeVector* = POINTER TO SizeVectorDesc;   (* used for description of array size; eventually = CATLIntVector *)
    SizeVectorDesc* = ARRAY OF LONGINT;

    Array* = POINTER TO ArrayDesc;     (** abstract base type, not containing data *)
    ArrayDesc* = RECORD  (DataDesc)
      (*ARRAY of arbitrary dimensionality *)
      dimension: SizeVector; (* dimension vector *)
      len-: LONGINT; (* Overall number of array elements *)
    END;

    SIntArray* = POINTER TO SIntArrayDesc;
    SIntArrayDesc* = RECORD (ArrayDesc)
      s-: SIntPtr;
    END;

    IntArray* = POINTER TO IntArrayDesc;
    IntArrayDesc* = RECORD (ArrayDesc)
      i-: IntPtr;
    END;

    LIntArray* = POINTER TO LIntArrayDesc;
    LIntArrayDesc* = RECORD (ArrayDesc)
      j-: LIntPtr;
    END;

(*    HIntArray* = POINTER TO HIntArrayDesc;
    HIntArrayDesc* = RECORD (ArrayDesc)
      h-: HIntPtr;
    END;
*)
    RealArray* = POINTER TO RealArrayDesc;
    RealArrayDesc* = RECORD (ArrayDesc)
      x-: RealPtr;
    END;

    LRealArray* = POINTER TO LRealArrayDesc;
    LRealArrayDesc* = RECORD (ArrayDesc)
      y-: LRealPtr;
    END;

    BoolArray* = POINTER TO BoolArrayDesc;
    BoolArrayDesc* = RECORD (ArrayDesc)
      b-: BoolPtr;
    END;

    ComplexArray* = POINTER TO ComplexArrayDesc;
    ComplexArrayDesc* = RECORD (ArrayDesc)
      r-, i-: RealPtr;
    END;

    PROCEDURE Order*  (A: Array): LONGINT;
            (** returns Nr of dimensions of array A *)
    BEGIN
      RETURN LEN(A.dimension^)
    END Order;

    PROCEDURE  Size*   (A: Array): SizeVector;
            (** returns dimension vector *)
      VAR i: LONGINT; res: SizeVector;
      BEGIN
        NEW(res,LEN(A.dimension^));
        FOR i := 0 TO LEN(A.dimension^)-1 DO res[i] := A.dimension[i] END;
        RETURN res
      END Size;

    PROCEDURE   Len*   (A: Array;  dim: LONGINT): LONGINT;
            (** returns length of dimension Nr 'dim' *)
      BEGIN
        IF dim >= LEN(A.dimension^) THEN HALT(100)
        ELSE RETURN A.dimension[dim]
        END
      END Len;

    PROCEDURE Index*(pos, dimension: ARRAY OF LONGINT): LONGINT;
      VAR maxI,res,i: LONGINT;
      BEGIN
        maxI := LEN(dimension)-1;
        ASSERT(LEN(pos) = LEN(dimension));
        res := pos[maxI];
        FOR i := 1 TO maxI DO res := res*dimension[maxI-i]+pos[maxI-i] END;
        RETURN res
      END Index;

    PROCEDURE Index1*(A: Array; x: LONGINT): LONGINT;
      BEGIN
        ASSERT(Order(A) = 1);
        ASSERT(x < A.len);
        RETURN x
      END Index1;

    PROCEDURE Index2*(A: Array; x,y: LONGINT): LONGINT;
      BEGIN
        ASSERT(Order(A) = 2);
        ASSERT(x < Len(A,0));
        ASSERT(y < Len(A,1));
        RETURN y*Len(A,0)+x
      END Index2;

    PROCEDURE Index3*(A: Array; x,y,z: LONGINT): LONGINT;
      BEGIN
        ASSERT(Order(A) = 3);
        ASSERT(x < Len(A,0));
        ASSERT(y < Len(A,1));
        ASSERT(z < Len(A,2));
        RETURN (z*Len(A,1)+y)*Len(A,0)+x
      END Index3;

    PROCEDURE Index4*(A: Array; x,y,z,u: LONGINT): LONGINT;
      BEGIN
        ASSERT(Order(A) = 4);
        ASSERT(x < Len(A,0));
        ASSERT(y < Len(A,1));
        ASSERT(z < Len(A,2));
        ASSERT(u < Len(A,3));
        RETURN ((u*Len(A,2)+z)*Len(A,1)+y)*Len(A,0)+x
      END Index4;

    PROCEDURE SizeVector1*(VAR Vec: SizeVector; x: LONGINT);
    BEGIN
      IF (Vec=NIL) OR (LEN(Vec^)#1) THEN NEW(Vec,1) END;
      Vec[0] := x
    END SizeVector1;

    PROCEDURE SizeVector2*(VAR Vec: SizeVector; x,y: LONGINT);
    BEGIN
      IF (Vec=NIL) OR (LEN(Vec^)#2) THEN NEW(Vec,2) END;
      Vec[0] := x; Vec[1] := y
    END SizeVector2;

    PROCEDURE SizeVector3*(VAR Vec: SizeVector; x,y,z: LONGINT);
    BEGIN
      IF (Vec=NIL) OR (LEN(Vec^)#3) THEN NEW(Vec,3) END;
      Vec[0] := x; Vec[1] := y; Vec[2] := z
    END SizeVector3;

    PROCEDURE SizeVector4*(VAR Vec: SizeVector; x,y,z,u: LONGINT);
    BEGIN
      IF (Vec=NIL) OR (LEN(Vec^)#4) THEN NEW(Vec,4) END;
      Vec[0] := x; Vec[1] := y; Vec[2] := z; Vec[3] := u
    END SizeVector4;

    PROCEDURE CalculatePos*(Index: LONGINT; dimension: ARRAY OF LONGINT): SizeVector;
      VAR maxI, n, i: LONGINT;
            res: SizeVector;
      BEGIN
        n := Index;
        maxI := LEN(dimension)-1;
        FOR i := 0 TO maxI-1 DO
          res[maxI-i] := n MOD dimension[maxI-i];
          n := n DIV dimension[maxI-i]
        END;
        RETURN res
      END CalculatePos;

    PROCEDURE  InitSInt*  (VAR A: Array; dimension: SizeVector; data: SIntPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: SIntArray;
      BEGIN
        IF (A=NIL) OR ~(A IS SIntArray) THEN NEW(AA) ELSE IF A IS SIntArray THEN AA := A(SIntArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.s,n); FOR i := 0 TO n-1 DO AA.s[i] := data[i] END;
        ELSE AA.s := data
        END;
        A := AA
      END InitSInt;

    PROCEDURE  InitInt*  (VAR A: Array; dimension: SizeVector; data: IntPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: IntArray;
      BEGIN
        IF (A=NIL) OR ~(A IS IntArray) THEN NEW(AA) ELSE IF A IS IntArray THEN AA := A(IntArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.i,n); FOR i := 0 TO n-1 DO AA.i[i] := data[i] END;
        ELSE AA.i := data
        END;
        A := AA
      END InitInt;

    PROCEDURE  InitLInt* (VAR A: Array; dimension: SizeVector; data: LIntPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: LIntArray;
      BEGIN
        IF (A=NIL) OR ~(A IS LIntArray) THEN NEW(AA) ELSE IF A IS LIntArray THEN AA := A(LIntArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.j,n); FOR i := 0 TO n-1 DO AA.j[i] := data[i] END;
        ELSE AA.j := data
        END;
        A := AA
      END InitLInt;

(*    PROCEDURE  InitHInt* (VAR A: Array; dimension: SizeVector; data: HIntPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: HIntArray;
      BEGIN
        IF (A=NIL) OR ~(A IS HIntArray) THEN NEW(AA) ELSE WITH A: HIntArray DO AA := A END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.h,n); FOR i := 0 TO n-1 DO AA.h[i] := data[i] END;
        ELSE AA.h := data
        END;
        A := AA
      END InitHInt; *)

    PROCEDURE  InitReal* (VAR A: Array; dimension: SizeVector; data: RealPtr; copy: BOOLEAN);
      VAR i, n:LONGINT;
          AA:RealArray;
      BEGIN
        IF (A=NIL) OR ~(A IS RealArray) THEN NEW(AA) ELSE IF A IS RealArray THEN AA := A(RealArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.x,n); FOR i := 0 TO n-1 DO AA.x[i] := data[i] END;
        ELSE AA.x := data
        END;
        A := AA
      END InitReal;

    PROCEDURE  InitLReal* (VAR A: Array; dimension: SizeVector; data: LRealPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: LRealArray;
      BEGIN
        IF (A=NIL) OR ~(A IS LRealArray) THEN NEW(AA) ELSE IF A IS LRealArray THEN AA := A(LRealArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.y,n); FOR i := 0 TO n-1 DO AA.y[i] := data[i] END;
        ELSE AA.y := data
        END;
        A := AA
      END InitLReal;

    PROCEDURE  InitBool* (VAR A: Array; dimension: SizeVector; data: BoolPtr; copy: BOOLEAN);
      VAR i, n: LONGINT;
          AA: BoolArray;
      BEGIN
        IF (A=NIL) OR ~(A IS BoolArray) THEN NEW(AA) ELSE IF A IS BoolArray THEN AA := A(BoolArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        IF data=NIL THEN NEW(data,n); copy := FALSE END;
        ASSERT (LEN(data^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.b,n); FOR i := 0 TO n-1 DO AA.b[i] := data[i] END
        ELSE AA.b := data
        END;
        A := AA
      END InitBool;

    PROCEDURE  InitComplex* (VAR A:Array; dimension: SizeVector;
                    dataR,dataI: RealPtr; copy:BOOLEAN);
      VAR i, n: LONGINT;
          AA: ComplexArray;
      BEGIN
        IF (A=NIL) OR ~(A IS ComplexArray) THEN NEW(AA) ELSE IF A IS ComplexArray THEN AA := A(ComplexArray) END END;
        n := 1;
        FOR i := 0 TO LEN(dimension^)-1 DO n := n*dimension[i] END;
        ASSERT (LEN(dataR^)=n); ASSERT (LEN(dataI^)=n);
        NEW(AA.dimension,LEN(dimension^));
        FOR i := 0 TO LEN(dimension^)-1 DO AA.dimension[i] := dimension[i]; END;
        AA.len := n;
        IF copy
        THEN NEW (AA.r,n); NEW (AA.i,n);
          FOR i := 0 TO n-1 DO AA.r[i] := dataR[i]; AA.i[i] := dataI[i] END
        ELSE AA.r := dataR; AA.i := dataI
        END;
        A := AA
      END InitComplex;

    PROCEDURE  Copy* (From,To:Array);
      BEGIN
        WITH
          From: SIntArray DO  InitSInt(To,From.dimension,From.s,TRUE) ;
          | From: IntArray DO InitInt(To,From.dimension,From.i,TRUE);
          | From: LIntArray DO InitLInt(To,From.dimension,From.j,TRUE);
  (*        | From: HIntArray DO HALT(100)  *)
          | From: RealArray DO InitReal(To,From.dimension,From.x,TRUE);
          | From: LRealArray DO InitLReal(To,From.dimension,From.y,TRUE);
          | From: BoolArray DO InitBool(To,From.dimension,From.b,TRUE);
          | From: ComplexArray DO InitComplex(To,From.dimension,From.r,From.i,TRUE);
        ELSE HALT(100)
        END
      END Copy;

(*    PROCEDURE CopySubArray* (A1,A2:Array; start,dimension:ARRAY OF LONGINT);
      (** Copies subrange of Array A1, beginning at 'start' with 'dimension' to (usually smaller) array A2 *)
    BEGIN
      WITH A1: ...
        ELSE HALT(100)
      END
      END CopySubarray; *)

    PROCEDURE GetSInt* (A: Array; position: SizeVector): SHORTINT;
    BEGIN
      IF A IS SIntArray THEN RETURN A(SIntArray).s[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetSInt;

    PROCEDURE GetInt* (A: Array; position: SizeVector): INTEGER;
    BEGIN
      IF A IS IntArray THEN RETURN A(IntArray).i[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetInt;

    PROCEDURE GetLInt* (A: Array; position: SizeVector): LONGINT;
    BEGIN
      IF A IS LIntArray THEN RETURN A(LIntArray).j[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetLInt;

    (*PROCEDURE GetHInt* (A: Array; position: SizeVector): HUGEINT;
    BEGIN
      IF A IS HIntArray THEN RETURN A(HIntArray).h[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetHInt; *)

    PROCEDURE GetReal* (A: Array; position: SizeVector): REAL;
    BEGIN
      IF A IS RealArray THEN RETURN A(RealArray).x[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetReal;

    PROCEDURE GetLReal* (A: Array; position: SizeVector): LONGREAL;
    BEGIN
      IF A IS LRealArray THEN RETURN A(LRealArray).y[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetLReal;

    PROCEDURE GetBool* (A: Array; position: SizeVector): BOOLEAN;
    BEGIN
      IF A IS BoolArray THEN RETURN A(BoolArray).b[Index(position^,A.dimension^)]
      ELSE HALT (100) END
    END GetBool;

    PROCEDURE GetComplex* (A: Array; position: SizeVector): Complex;
    VAR res: Complex;
    BEGIN
      IF A IS ComplexArray
      THEN
        NEW(res);
        res.r := A(ComplexArray).r[Index(position^,A.dimension^)];
        res.i := A(ComplexArray).i[Index(position^,A.dimension^)];
        RETURN res
      ELSE HALT (100)
      END
    END GetComplex;

(*    PROCEDURE   Store*  (R: Files.Rider; A: Array);
            (* S3 specific ->eliminate from this module, into utility module *)
            (** not yet implemented *)
      BEGIN
        (**)
      END Store;

    PROCEDURE   Load* (R: Files.Rider; VAR A: Array);
            (* S3 specific ->eliminate from this module, into utility module *)
            (** not yet implemented *)
      BEGIN
        (**)
      END Load;
*)
    PROCEDURE AllSInt1* (A: Array;  f: PROCEDURE(s:SHORTINT): SHORTINT);
    VAR n: LONGINT;
    BEGIN
      WITH A: SIntArray DO FOR n := 0 TO A.len-1 DO A.s[n] := f(A.s[n]) END
      ELSE HALT(100)
      END
    END AllSInt1;

    PROCEDURE AllSInt2* (A,B: Array;  f: PROCEDURE(s1,s2:SHORTINT): SHORTINT);
    VAR n: LONGINT;
    BEGIN
      WITH A: SIntArray DO
        WITH B: SIntArray DO
          FOR n := 0 TO A.len-1 DO A.s[n] := f(A.s[n],B.s[n]) END
        ELSE HALT(100)
        END
      ELSE HALT(100)
      END;
    END AllSInt2;

    PROCEDURE AllInt1* (A: Array; f: PROCEDURE(i:INTEGER): INTEGER);
    VAR n: LONGINT;
    BEGIN
      WITH A: IntArray DO FOR n := 0 TO A.len-1 DO A.i[n] := f(A.i[n]) END
      ELSE HALT(100)
      END
    END AllInt1;

    PROCEDURE AllInt2* (A,B: Array; f: PROCEDURE(i1,i2:INTEGER): INTEGER);
    VAR n: LONGINT;
    BEGIN
      WITH A: IntArray DO
        WITH B: IntArray DO
          FOR n := 0 TO A.len-1 DO A.i[n] := f(A.i[n],B.i[n]) END
        ELSE HALT(100)
        END;
      ELSE HALT(100)
      END
    END AllInt2;

    PROCEDURE AllLInt1* (A: Array; f: PROCEDURE(j:LONGINT): LONGINT);
    VAR n: LONGINT;
    BEGIN
      WITH A: LIntArray DO FOR n := 0 TO A.len-1 DO A.j[n] := f(A.j[n]) END
      ELSE HALT(100)
      END
    END AllLInt1;

    PROCEDURE AllLInt2* (A,B: Array; f: PROCEDURE(j1,j2:LONGINT): LONGINT);
    VAR n: LONGINT;
    BEGIN
      WITH A: LIntArray DO
        WITH B: LIntArray DO
          FOR n := 0 TO A.len-1 DO A.j[n] := f(A.j[n],B.j[n]) END
        ELSE HALT(100)
        END;
      ELSE HALT(100)
      END;
    END AllLInt2;

    PROCEDURE AllReal1* (A: Array; f: PROCEDURE(x:REAL): REAL);
    VAR n: LONGINT;
    BEGIN
      WITH A: RealArray DO FOR n := 0 TO A.len-1 DO A.x[n] := f(A.x[n]) END
      ELSE HALT(100)
      END
    END AllReal1;

    PROCEDURE AllReal2* (A,B: Array; f: PROCEDURE(x1,x2:REAL): REAL);
    VAR n: LONGINT;
    BEGIN
      WITH A: RealArray DO
        WITH B: RealArray DO
          FOR n := 0 TO A.len-1 DO A.x[n] := f(A.x[n],B.x[n]) END
        ELSE HALT(100)
        END;
      ELSE HALT(100)
      END
    END AllReal2;

    PROCEDURE AllLReal1* (A: Array; f: PROCEDURE(y:LONGREAL): LONGREAL);
    VAR n: LONGINT;
    BEGIN
      WITH A: LRealArray DO FOR n := 0 TO A.len-1 DO A.y[n] := f(A.y[n]) END
      ELSE HALT(100)
      END
    END AllLReal1;

    PROCEDURE AllLReal2* (A,B: Array; f: PROCEDURE(y1,y2:LONGREAL): LONGREAL);
    VAR n: LONGINT;
    BEGIN
      WITH A: LRealArray DO
        WITH B: LRealArray DO
          FOR n := 0 TO A.len-1 DO A.y[n] := f(A.y[n],B.y[n]) END
        ELSE HALT(100)
        END
      ELSE HALT(100)
      END
    END AllLReal2;

    PROCEDURE InvertSign (s: SHORTINT): SHORTINT; (* Test procedure for unary operations *)
    BEGIN
      RETURN -s
    END InvertSign;

    PROCEDURE Add (s1,s2: SHORTINT): SHORTINT; (* Test procedure for unary operations *)
    BEGIN
      RETURN s1+s2
    END Add;


PROCEDURE Test*;
    (** Compares "Allxxx" procedure with conventional indexing scheme *)
      VAR A1: Array;
          A2: POINTER TO ARRAY OF ARRAY OF ARRAY OF ARRAY OF SHORTINT;
          data: SIntPtr;
          dim1: SizeVector;
          i, starttime, endtime, a, b, c, d: LONGINT;
      BEGIN
        (* ALL ELEMENT OPERATIONS *)
        Out.String("----------------------------------"); Out.Ln;
        NEW(A1);
        SizeVector4(dim1, 64, 32, 32, 32);
        NEW(data, dim1[0]*dim1[1]*dim1[2]*dim1[3]);
        InitSInt(A1, dim1, data, FALSE);

        starttime := Input.Time();
        WITH A1: SIntArray DO
              FOR i := 0 TO A1.len-1 DO A1.s[i] := InvertSign(A1.s[i]); END      (* linear array access *)
            END;
        endtime := Input.Time();
        Out.String("ALL ELEMENT MONADIC OPERATION:"); Out.Ln;
        Out.String("arbitrary array, linear access, invert sign:"); Out.String("  time: ");
        Out.Int(endtime-starttime, 5); Out.String("ms  for "); Out.Int(A1.len, 10);
        Out.String(" elements"); Out.Ln;

        starttime := Input.Time();
        AllSInt1(A1, InvertSign);      (* monadic proc. using "All" procedure *)
        endtime := Input.Time();

        Out.String("arbitrary array 'ALL procedure', invert sign:"); Out.String("  time: ");
        Out.Int(endtime-starttime, 5); Out.String("ms  for "); Out.Int(A1.len, 10);
        Out.String(" elements"); Out.Ln;
        NEW(A2, 64, 32, 32, 32);

        starttime := Input.Time();
        FOR a := 0 TO LEN(A2^, 0)-1 DO      (* monadic proc. using conventional indices *)
          FOR b := 0 TO LEN(A2^, 1)-1 DO
            FOR c := 0 TO LEN(A2^, 2)-1 DO
              FOR d := 0 TO LEN(A2^, 3)-1 DO
                A2[a, b, c, d] := InvertSign(A2[a, b, c, d])
              END
            END
          END
        END;
        endtime := Input.Time();

        Out.String("conventional indexed array invert sign:"); Out.String("  time: ");
        Out.Int(endtime-starttime, 5); Out.String("ms  for "); Out.Int(A1.len, 10);
        Out.String(" elements"); Out.Ln;
        Out.String("**********************************"); Out.Ln;

        starttime := Input.Time();
        AllSInt2(A1, A1, Add);      (* dyadic proc. using "All" procedure *)
        endtime := Input.Time();

        Out.String("ALL ELEMENT DYADIC OPERATION:"); Out.Ln;
        Out.String("arbitrary array ,'ALL procedure, addition:"); Out.String("  time: ");
        Out.Int(endtime-starttime, 5); Out.String("ms  for "); Out.Int(A1.len, 10);
        Out.String(" elements"); Out.Ln;

        starttime := Input.Time();
        FOR a := 0 TO LEN(A2^, 0)-1 DO      (* dyadic proc. using conventional approach *)
          FOR b := 0 TO LEN(A2^, 1)-1 DO
            FOR c := 0 TO LEN(A2^, 2)-1 DO
              FOR d := 0 TO LEN(A2^, 3)-1 DO
                A2[a, b, c, d] := Add(A2[a, b, c, d], A2[a, b, c, d])
              END
            END
          END
        END;
        endtime := Input.Time();

        Out.String("conventional indexed array, addition:"); Out.String("  time: ");
        Out.Int(endtime-starttime, 5); Out.String("ms  for "); Out.Int(A1.len, 10);
        Out.String(" elements"); Out.Ln;
        Out.String("**********************************"); Out.Ln
    END Test;

(*PROCEDURE Test2*;                  (* insufficient registers with Intel *)
VAR A, B: ARRAY 2, 2, 2, 2, 2, 2 OF INTEGER;
  i, j, k, l, m, n, o, p, q, r: INTEGER;
BEGIN
  Out.String('Test2: ... ');
  FOR i := 0 TO 1 DO
    FOR j := 0 TO 1 DO
      FOR k := 0 TO 1 DO
        FOR l := 0 TO 1 DO
          FOR m := 0 TO 1 DO
            FOR n := 0 TO 1 DO
              A[i, j, k, l, m, n] := B[i, j, k, l, m, n]+1
            END
          END
        END
      END
    END
  END
  Out.String('done'); Out.Ln
END Test2;  *)

(*PROCEDURE Test3*;                  (* insufficient registers with Intel *)
VAR A, B: ARRAY 2,2,2,2,2,2,2,2,2,2 OF INTEGER;
  i, j, k, l, m, n, o, p, q, r: INTEGER;
BEGIN
  Out.String('Test3: ... ');
  FOR i := 0 TO 1 DO
    FOR j := 0 TO 1 DO
      FOR k := 0 TO 1 DO
        FOR l := 0 TO 1 DO
          FOR m := 0 TO 1 DO
            FOR n := 0 TO 1 DO
              FOR o := 0 TO 1 DO
                FOR p := 0 TO 1 DO
                  FOR q := 0 TO 1 DO
                    FOR r := 0 TO 1 DO
                      A[i, j, k, l, m, n, o, p, q, r] := B[i, j, k, l, m, n, o, p, q, r]+1
                    END
                  END
                END
              END
            END
          END
        END
      END
    END
  END
  Out.String('done'); Out.Ln
END Test3; *)

BEGIN
END MultiArrays.

MultiArrays.Test
MultiArrays.Test2
MultiArrays.Test3
Compiler.Compile  \xc MultiArrays.Mod  ~
System.Free MultiArrays~
