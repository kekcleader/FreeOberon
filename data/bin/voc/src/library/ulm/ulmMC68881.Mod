(* Oberon Library      -    SunOS 4.1    -      AFB 8/90 *)
(* (c) University of Ulm, Sektion Informatik, D-7900 Ulm *)

MODULE ulmMC68881;

   (* library interface to MC68881 instructions *)

   IMPORT SYS := SYSTEM, Types := ulmTypes;

   CONST
      available* = FALSE; (* TRUE if MC68881 present *)

      (* rounding modes *)
      toNearest* = 0;
      towardZero* = 1;
      towardMinusInfinity* = 2;
      towardPlusInfinity* = 3;

      (* rounding precision *)
      extended* = 0;
      single* = 1;
      double* = 2;

      (* exceptions *)
      branchOnUnordered* = 0;
      signalingNotANumber* = 1;
      operandError* = 2;
      overflow* = 3;
      underflow* = 4;
      divideByZero* = 5;
      inexactOperation* = 6;
      inexactDecimalInput* = 7;

   CONST
      floatlen* = 4; (* length of a single precision real number *)

   (* monadic operations *)

   PROCEDURE FACOS*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FACOS;

   PROCEDURE FASIN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FASIN;

   PROCEDURE FATAN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FATAN;

   PROCEDURE FATANH*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FATANH;

   PROCEDURE FCOS*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FCOS;

   PROCEDURE FCOSH*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FCOSH;

   PROCEDURE FETOX*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FETOX;

   PROCEDURE FETOXM1*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FETOXM1;

   PROCEDURE FGETEXP*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FGETEXP;

   PROCEDURE FGETMAN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FGETMAN;

   PROCEDURE FLOG10*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FLOG10;

   PROCEDURE FLOG2*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FLOG2;

   PROCEDURE FLOGN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FLOGN;

   PROCEDURE FLOGNP1*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FLOGNP1;

   PROCEDURE FSIN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FSIN;

   PROCEDURE FSINH*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FSINH;

   PROCEDURE FSQRT*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FSQRT;

   PROCEDURE FTAN*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FTAN;

   PROCEDURE FTANH*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FTANH;

   PROCEDURE FTENTOX*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FTENTOX;

   PROCEDURE FTWOTOX*(x: Types.Real64) : Types.Real64;
   BEGIN
      RETURN ABS(x)
   END FTWOTOX;


   PROCEDURE GetExceptionEnable*(VAR exceptions: Types.Set);
   BEGIN
      exceptions := {};
   END GetExceptionEnable;

   PROCEDURE SetExceptionEnable*(exceptions: Types.Set);
   BEGIN
      exceptions := {};
   END SetExceptionEnable;


   PROCEDURE GetRoundingMode*(VAR precision, mode: Types.Int32);
   BEGIN
      precision := 1;
      mode := 2;
   END GetRoundingMode;

   PROCEDURE SetRoundingMode*(precision, mode: Types.Int32);
   BEGIN
      precision := 1;
      mode := 2;
   END SetRoundingMode;


   (* conversions to and from single precision (C's float);
      float must consist of at least floatlen bytes
   *)

   PROCEDURE RealToFloat*(real: Types.Real64; VAR float: ARRAY OF SYS.BYTE);
   BEGIN
      (*SYS.WMOVE(SYS.ADR(real), SYS.ADR(float), floatlen DIV 4);*)
   END RealToFloat;

   PROCEDURE FloatToReal*(float: ARRAY OF SYS.BYTE; VAR real: Types.Real64);
   BEGIN
      (*SYS.WMOVE(SYS.ADR(float), SYS.ADR(real), floatlen DIV 4);*)
   END FloatToReal;

END ulmMC68881.
