(*<* O2EXTENSIONS + *>
<* IOVERFLOW - *>*)
MODULE MersenneTwister;

  IMPORT
    SYS:=SYSTEM,(*Win:=Windows*) SysClock := oocSysClock, MathL := oocLRealMath;

  CONST
    (* Period parameter *)
    MT19937N*=624;

    (* Period parameters *)
    MT19937M=397;
    (*MT19937MATRIXA  =SYS.VAL(SET,-1727483681(*9908b0dfH*)); (* -- constant vector a*)
    MT19937UPPERMASK=SYS.VAL(SET,80000000H); (* -- most significant w-r bits*)
    MT19937LOWERMASK=SYS.VAL(SET,7fffffffH); (* -- least significant r bits*)

    (* Tempering parameters *)
    TEMPERINGMASKB=SYS.VAL(SET,9d2c5680H);
    TEMPERINGMASKC=SYS.VAL(SET,0efc60000H);
*)
    Seed0=4357;
  TYPE
    tMT19937StateArray=ARRAY MT19937N OF SET; (*-- the array for the state vector*)

  VAR
    Seed-:LONGINT;

    MT19937MATRIXA, MT19937UPPERMASK, MT19937LOWERMASK : SET;
    TEMPERINGMASKB, TEMPERINGMASKC : SET;
    mt : tMT19937StateArray;
    mti: LONGINT; (*-- mti=MT19937N+1 means mt[] is not initialized*)

    GaussRandomBuf:LONGREAL;
    GaussRandomBufFilled:BOOLEAN;

  (* Initializing the array with a seed *)
  PROCEDURE SetSeed*(seed:LONGINT);(* sgenrand_MT19937 *)
    (*CONST
      HighBits=SYS.VAL(SET, 0ffff0000H);*)
    VAR
      HighBits : SET;
      i:LONGINT;
    BEGIN
      HighBits := SYS.VAL(SET, -65536(*0ffff0000H*));
      Seed:=seed;
      FOR i:=0 TO MT19937N-1 DO
        mt[i]:=SYS.VAL(SET,seed) * HighBits;
        seed:=69069*seed+1;
        (*mt[i]:=mt[i] + (SYS.SHIFT(SYS.VAL(SET,seed) * HighBits,-16));*)
        mt[i]:=mt[i] + SYS.VAL(SET, (SYS.LSH(seed * SYS.VAL(LONGINT, HighBits),-16)));
        seed:=69069*seed+1;
      END;
      mti := MT19937N;
    END SetSeed;

  (* Initialization by array of seeds *)
  PROCEDURE SetSeeds*(seedarray:tMT19937StateArray); (* lsgenrand_MT19937 *)
    VAR
      i:LONGINT;
    BEGIN
      FOR i:=0 TO MT19937N-1 DO
        mt[i]:=seedarray[i];
      END;
      mti:=MT19937N;
    END SetSeeds;

  (* random longint (full range) *)
  PROCEDURE Int*():LONGINT; (* genrand_MT19937 *)
    TYPE
      ar=ARRAY 2 OF SET;
    VAR
      mag01:ARRAY 2 OF SET;
      y:SET;
      kk:LONGINT;
    BEGIN
      mag01[0]:={};
      mag01[1]:=MT19937MATRIXA;

      IF mti>=MT19937N THEN (* generate MT19937N longints at one time *)
        IF mti=(MT19937N+1) THEN  (*-- if sgenrand_MT19937() has not been called,*)
          SetSeed(Seed0);   (*-- default initial seed is used*)
        END;
        FOR kk:=0 TO MT19937N-MT19937M-1 DO
           y:=(mt[kk] * MT19937UPPERMASK) + (mt[kk+1] * MT19937LOWERMASK);
           (*mt[kk]:=mt[kk+MT19937M]/SYS.SHIFT(y,-1)/mag01[SYS.VAL(LONGINT,y * {0})];*)
           
	   (*mt[kk]:=mt[kk+MT19937M]/SYS.LSH(y,-1)/mag01[SYS.VAL(LONGINT,y * {0})];*)
	   mt[kk]:=mt[kk+MT19937M]/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-1))/mag01[SYS.VAL(LONGINT,y * {0})];

	   (*mt[kk] := mt[kk+MT19937M];
	   mt[kk] := mt[kk]/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-1));
	   mt[kk] := mt[kk] / mag01[SYS.VAL(LONGINT,y * {0})];*)
        END;
        FOR kk:=MT19937N-MT19937M TO MT19937N-2 DO
          y:=(mt[kk] * MT19937UPPERMASK) + (mt[kk+1] * MT19937LOWERMASK);
          (*mt[kk]:=mt[kk+(MT19937M-MT19937N)]/SYS.LSH(y,-1)/mag01[SYS.VAL(LONGINT,y * {0})];*)
          mt[kk]:=mt[kk+(MT19937M-MT19937N)]/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-1))/mag01[SYS.VAL(LONGINT,y * {0})];
        END;
        y:=(mt[MT19937N-1] * MT19937UPPERMASK) + (mt[0] * MT19937LOWERMASK);
        (*mt[MT19937N-1]:=mt[MT19937M-1]/SYS.LSH(y,-1)/mag01[SYS.VAL(LONGINT,y* {0})];*)
        mt[MT19937N-1]:=mt[MT19937M-1]/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-1))/mag01[SYS.VAL(LONGINT,y* {0})];
        mti:=0;
      END;
      y:=mt[mti]; INC(mti);
      y:=y/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-11));
      y:=y/(SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),7)) * TEMPERINGMASKB);
      y:=y/(SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),15)) * TEMPERINGMASKC);
      y:=y/SYS.VAL(SET, SYS.LSH(SYS.VAL(LONGINT, y),-18));
      RETURN SYS.VAL(LONGINT,y);
    END Int;

  (*randomization*)
  PROCEDURE Randomize*(); (* Randomize_MT19937 *)
    VAR sec, usec, l : LONGINT;
      (*ST:Win.SYSTEMTIME;*)
    BEGIN
      (*Win.GetSYS.emTime(ST);
      SetSeed(((SYS.VAL(LONGINT,ST.wHour)*60+ST.wMinute)*60+ST.wSecond)*1000+S
T.wMilliseconds);*)
    l := SysClock.GetTimeOfDay(sec, usec);
    IF l = 0 THEN SetSeed(sec*usec) ELSE HALT(1) END
    (*IF l = 0 THEN SetSeed(sec*1000 + usec / 1000) ELSE HALT(1) END*) (* this way it'll repeat every 24 days; -- noch *)
    (*IF l = 0 THEN SetSeed(sec*100 + usec / 100) ELSE HALT(1) END*) (* this way it'll repeat every 248 days; -- noch *)
    END Randomize;

  (*integer RANDOM with positive range*)
  (*-- bug fixed 21.6.2000.*)
  PROCEDURE IntRange*(Range:LONGINT):LONGINT; (* RandInt_MT19937 *)
    TYPE
    VAR
      (*X:SYS.CARD64;*)
      X:LONGINT;
    BEGIN
      X:=Range;
      (*X:=X * SYS.VAL(SYS.CARD64,Int());*)
      X:=X * Int();
      SYS.MOVE(SYS.ADR(X)+SIZE(INTEGER)(*4*),SYS.ADR(Range),SIZE(INTEGER)(*4*));
      RETURN Range;
    END IntRange;

  (*float RANDOM on 0..1 interval*)
  PROCEDURE Real*():LONGREAL; (* RandFloat_MT19937 *)
    VAR l : LONGINT;
    BEGIN
      (*RETURN SYS.VAL(SYS.CARD32,Int())/(1.0*MAX(SYS.CARD32)+1)*)
      l := Int();
      RETURN l/(1.0*MAX(LONGINT)+1)
    END Real;

  PROCEDURE Gauss*(mean,std:LONGREAL):LONGREAL;
    VAR
      r1,r2,s,result:LONGREAL;
    BEGIN
      IF GaussRandomBufFilled THEN
        result:=GaussRandomBuf*std+mean
      ELSE
        REPEAT
          r1:=2*Real()-1;
          r2:=2*Real()-1;
          s:=r1*r1+r2*r2;
        UNTIL s<1;
        s:=MathL.sqrt((-2*MathL.ln(s))/s);
        result:=r1*s*std+mean;
        GaussRandomBuf:=r2*s;
      END;
      (*GaussRandomBufFilled:=NOT GaussRandomBufFilled;*)
      GaussRandomBufFilled := ~GaussRandomBufFilled;
      RETURN result
    END Gauss;

BEGIN
  MT19937MATRIXA := SYS.VAL(SET,-1727483681)(*9908b0dfH*); (* -- constant vector a*)
  MT19937UPPERMASK := SYS.VAL(SET,80000000H); (* -- most significant w-r bits*)
  MT19937LOWERMASK := SYS.VAL(SET, 2147483647 (* 7fffffffH*)); (* -- least significant r bits*)

  (* Tempering parameters *)
  TEMPERINGMASKB := SYS.VAL(SET, -1658038656  (*9d2c5680H*));
  TEMPERINGMASKC := SYS.VAL(SET, -272236544 (*0efc60000H*));
  Seed:=Seed0;
  mti:=MT19937N+1;
  GaussRandomBufFilled:=FALSE;
END MersenneTwister.

(*----------------------------------------------------------------------
   Mersenne Twister: A 623-Dimensionally Equidistributed Uniform
   Pseudo-Random Number Generator.

   What is Mersenne Twister?
   Mersenne Twister(MT) is a pseudorandom number generator developped by
   Makoto Matsumoto and Takuji Nishimura (alphabetical order) during
   1996-1997. MT has the following merits:
   It is designed with consideration on the flaws of various existing
   generators.
   Far longer period and far higher order of equidistribution than any
   other implemented generators. (It is proved that the period is 2^19937-1,
   and 623-dimensional equidistribution property is assured.)
   Fast generation. (Although it depends on the system, it is reported that
   MT is sometimes faster than the standard ANSI-C library in a system
   with pipeline and cache memory.)
   Efficient use of the memory. (The implemented C-code mt19937.c
   consumes only 624 words of working area.)

   home page
     http://www.math.keio.ac.jp/~matumoto/emt.html
   original c source
     http://www.math.keio.ac.jp/~nisimura/random/int/mt19937int.c

   Coded by Takuji Nishimura, considering the suggestions by
   Topher Cooper and Marc Rieffel in July-Aug. 1997.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later
   version.
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
   See the GNU Library General Public License for more details.
   You should have received a copy of the GNU Library General
   Public License along with this library; if not, write to the
   Free Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307  USA

   Copyright (C) 1997, 1999 Makoto Matsumoto and Takuji Nishimura.
   When you use this, send an email to: matumoto@math.keio.ac.jp
   with an appropriate reference to your work.

   REFERENCE
   M. Matsumoto and T. Nishimura,
   "Mersenne Twister: A 623-Dimensionally Equidistributed Uniform
   Pseudo-Random Number Generator",
   ACM Transactions on Modeling and Computer Simulation,
   Vol. 8, No. 1, January 1998, pp 3--30.


  Translated to OP and Delphi interface added by Roman Krejci (6.12.1999)

  http://www.rksolution.cz/delphi/tips.htm

  Revised 21.6.2000: Bug in the function RandInt_MT19937 fixed
----------------------------------------------------------------------*)
