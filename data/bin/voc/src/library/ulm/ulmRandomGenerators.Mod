(* Ulm's Oberon Library
  Copyright (C) 1989-1994 by University of Ulm, SAI, D-89069 Ulm, Germany
  ----------------------------------------------------------------------------
  Ulm's Oberon Library is free software; you can redistribute it
  and/or modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either version
  2 of the License, or (at your option) any later version.

  Ulm's Oberon Library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  ----------------------------------------------------------------------------
  E-mail contact: oberon@mathematik.uni-ulm.de
  ----------------------------------------------------------------------------
  $Id: RandomGener.om,v 1.9 2004/03/09 21:44:12 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: RandomGener.om,v $
  Revision 1.9  2004/03/09 21:44:12  borchert
  unpredictable added to the standard set of PRNGs

  Revision 1.8  2004/03/06 07:22:09  borchert
  Init asserts that the sequence has been registered at Services

  Revision 1.7  1998/02/14  22:04:09  martin
  Missing calls of Services.Init and Services.CreateType added.

  Revision 1.6  1997/10/11  21:22:03  martin
  assertion in ValS added, obsolete variable removed

  Revision 1.5  1997/10/10  16:26:49  martin
  RestartSequence added, range conversions improved,
  default implementation replaced.

  Revision 1.4  1997/04/01  16:33:41  borchert
  major revision of Random:
  - module renamed to RandomGenerators
  - abstraction instead of simple implementation (work by Frank Fischer)

  Revision 1.3  1994/09/01  18:15:41  borchert
  bug fix: avoid arithmetic overflow in ValS

  Revision 1.2  1994/08/30  09:48:00  borchert
  sequences added

  Revision 1.1  1994/02/23  07:25:30  borchert
  Initial revision

  ----------------------------------------------------------------------------
  original implementation by AFB 2/90
  conversion to abstraction by Frank B.J. Fischer 3/97
  ----------------------------------------------------------------------------
*)

MODULE ulmRandomGenerators;

  (*    Anyone who considers arithmetical
      methods of producing random digits
      is, of course, in a state of sin.
            - John von Neumann (1951)
  *)

  IMPORT
    Clocks  := ulmClocks,  Disciplines := ulmDisciplines,
    Objects := ulmObjects, Operations  := ulmOperations,
    Process := ulmProcess, Services    := ulmServices,
    Times   := ulmTimes,   Types       := ulmTypes;

  TYPE
    Sequence* = POINTER TO SequenceRec;

    Int32ValSProc* = PROCEDURE (sequence: Sequence): Types.Int32;
    LongRealValSProc* = PROCEDURE (sequence: Sequence): Types.Real64;
    RewindSequenceProc* = PROCEDURE (sequence: Sequence);
    RestartSequenceProc* = PROCEDURE (sequence, seed: Sequence);
    SetValSProc* = PROCEDURE (sequence: Sequence; value: Operations.Operand);

  CONST
    int32ValS* = 0; longRealValS* = 1; rewindSequence* = 2; restartSequence* = 3;

  TYPE
    CapabilitySet* = Types.Set;             (* of [int32ValS..restartSequence] *)
    Interface* = POINTER TO InterfaceRec;
    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        int32ValS*      : Int32ValSProc;    (* at least one of ... *)
        longRealValS*   : LongRealValSProc; (* ... these required  *)
        rewindSequence* : RewindSequenceProc;       (* optional *)
        restartSequence*: RestartSequenceProc;      (* optional *)
      END;

    SequenceRec* =
      RECORD
        (Services.ObjectRec)
        (* private components *)
        if  : Interface;
        caps: CapabilitySet;
      END;

  VAR
    std* : Sequence;                          (* default sequence *)
    seed*: Sequence;                          (* sequence of seed values *)
    unpredictable*: Sequence;
      (* reasonably fast sequence of unpredictable values;
        is initially NIL
      *)

  (* ----- private definitions ----- *)

  CONST
    modulus1   = 2147483647;                  (* a Mersenne prime *)
    factor1    = 48271;                       (* passes spectral test *)
    quotient1  = modulus1 DIV factor1;        (* 44488 *)
    remainder1 = modulus1 MOD factor1;        (* 3399; must be < quotient1 *)
    modulus2   = 2147483399;                  (* a non-Mersenne prime *)
    factor2    = 40692;                       (* also passes spectral test *)
    quotient2  = modulus2 DIV factor2;        (* 52774 *)
    remainder2 = modulus2 MOD factor2;        (* 3791; must be < quotient2 *)

  TYPE
    DefaultSequence = POINTER TO DefaultSequenceRec;
    DefaultSequenceRec =
      RECORD
        (SequenceRec)
        seed1, seed2: Types.Int32;
        value1, value2: Types.Int32;
      END;

    ServiceDiscipline = POINTER TO ServiceDisciplineRec;
    ServiceDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        setValS: SetValSProc;
      END;

  VAR
    service      : Services.Service;
    serviceDiscID: Disciplines.Identifier;
    sequenceType,
    defaultSequenceType: Services.Type;

  (* ----- bug workaround ----- *)

  PROCEDURE Entier(value: Types.Real64): Types.Int32;
    VAR
      result: Types.Int32;
  BEGIN
    result := ENTIER(value);
    IF result > value THEN
      DEC(result);
    END;
    RETURN result
  END Entier;

  (* ----- exported procedures ----- *)

  PROCEDURE Init*(sequence: Sequence; if: Interface; caps: CapabilitySet);
    (* initialize sequence *)
    VAR
      type: Services.Type;
  BEGIN
    ASSERT((if.int32ValS # NIL) OR (if.longRealValS # NIL));
    ASSERT(~(int32ValS IN caps) OR (if.int32ValS # NIL));
    ASSERT(~(longRealValS IN caps) OR (if.longRealValS # NIL));
    ASSERT(~(rewindSequence IN caps) OR (if.rewindSequence # NIL));
    Services.GetType(sequence, type); ASSERT(type # NIL);
    sequence.if := if;
    sequence.caps := caps;
  END Init;

  PROCEDURE Capabilities*(sequence: Sequence): CapabilitySet;
    (* tell which procedures are implemented *)
  BEGIN
    RETURN sequence.caps
  END Capabilities;

  PROCEDURE RewindSequence*(sequence: Sequence);
    (* re-examine sequence *)
  BEGIN
    ASSERT(rewindSequence IN sequence.caps);
    sequence.if.rewindSequence(sequence);
  END RewindSequence;

  PROCEDURE RestartSequence*(sequence, seed: Sequence);
    (* restart sequence with new seed values *)
  BEGIN
    ASSERT(restartSequence IN sequence.caps);
    sequence.if.restartSequence(sequence, seed);
  END RestartSequence;

  PROCEDURE ^ LongRealValS*(sequence: Sequence): Types.Real64;

  PROCEDURE Int32ValS*(sequence: Sequence): Types.Int32;
    (* get random 32-bit value from sequence *)
    VAR
      real: Types.Real64;
  BEGIN
    IF int32ValS IN sequence.caps THEN
      RETURN sequence.if.int32ValS(sequence)
    ELSE
      real := LongRealValS(sequence);
      RETURN SHORT(Entier( (1. - real - real) * MIN(Types.Int32) ))
    END;
  END Int32ValS;

  PROCEDURE Int32Val*(): Types.Int32;
    (* get random 32-bit value from std sequence *)
  BEGIN
    RETURN Int32ValS(std);
  END Int32Val;

  PROCEDURE LongRealValS*(sequence: Sequence): Types.Real64;
    (* get a uniformly distributed longreal value in [0..1) *)
  BEGIN
    IF longRealValS IN sequence.caps THEN
      RETURN sequence.if.longRealValS(sequence)
    ELSE
      RETURN 0.5 +
        Int32ValS(sequence) / (0. - MIN(Types.Int32) - MIN(Types.Int32))
    END;
  END LongRealValS;

  PROCEDURE LongRealVal*(): Types.Real64;
    (* get a uniformly distributed longreal value in [0..1) *)
  BEGIN
    RETURN LongRealValS(std)
  END LongRealVal;

  PROCEDURE RealValS*(sequence: Sequence): Types.Real32;
    (* get a uniformly distributed real value in [0..1) *)
  BEGIN
    RETURN SHORT(LongRealValS(sequence))
  END RealValS;

  PROCEDURE RealVal*(): Types.Real32;
    (* get a uniformly distributed real value in [0..1) *)
  BEGIN
    RETURN SHORT(LongRealValS(std))
  END RealVal;

  PROCEDURE ValS*(sequence: Sequence; low, high: Types.Int32): Types.Int32;
    (* get a uniformly distributed integer in [low..high] *)
  BEGIN
    ASSERT(low <= high);
    RETURN Entier( low + LongRealValS(sequence) * (1. + high - low) )
  END ValS;

  PROCEDURE Val*(low, high: Types.Int32): Types.Int32;
    (* get a uniformly distributed integer in [low..high] *)
  BEGIN
    RETURN ValS(std, low, high)
  END Val;

  PROCEDURE FlipS*(sequence: Sequence): BOOLEAN;
    (* return TRUE or FALSE *)
  BEGIN
    IF int32ValS IN sequence.caps THEN
      RETURN sequence.if.int32ValS(sequence) >= 0
    ELSE
      RETURN sequence.if.longRealValS(sequence) >= 0.5
    END;
  END FlipS;

  PROCEDURE Flip*(): BOOLEAN;
    (* return TRUE or FALSE *)
  BEGIN
    RETURN FlipS(std)
  END Flip;

  PROCEDURE Support*(type: Services.Type; setValS: SetValSProc);
    (* support service for type *)
    VAR
      serviceDisc: ServiceDiscipline;
  BEGIN
    NEW(serviceDisc);
    serviceDisc.id := serviceDiscID;
    serviceDisc.setValS := setValS;
    Disciplines.Add(type, serviceDisc);
    Services.Define(type, service, NIL);
  END Support;

  PROCEDURE SetValS*(sequence: Sequence; value: Operations.Operand);
    (* store random value from sequence into already initialized value *)
    VAR
      baseType   : Services.Type;
      serviceDisc: Disciplines.Discipline; (* ServiceDiscipline *)
      ok         : BOOLEAN;
  BEGIN
    Services.GetSupportedBaseType(value, service, baseType);
    ok := Disciplines.Seek(baseType, serviceDiscID, serviceDisc);
    ASSERT(ok);
    serviceDisc(ServiceDiscipline).setValS(sequence, value);
  END SetValS;

  PROCEDURE SetVal*(value: Operations.Operand);
    (* store random value from std sequence into already initialized value *)
  BEGIN
    SetValS(std, value);
  END SetVal;

  (* ----- DefaultSequence ----- *)

  PROCEDURE CongruentialStep(VAR value1, value2: Types.Int32);
  BEGIN
    value1 :=
      factor1 * (value1 MOD quotient1) - remainder1 * (value1 DIV quotient1);
    IF value1 < 0 THEN
      INC(value1, modulus1);
    END;
    value2 :=
      factor2 * (value2 MOD quotient2) - remainder2 * (value2 DIV quotient2);
    IF value2 < 0 THEN
      INC(value2, modulus2);
    END;
  END CongruentialStep;

  PROCEDURE DefaultSequenceValue(sequence: Sequence): Types.Real64;
    VAR
      value: Types.Int32;
  BEGIN
    WITH sequence: DefaultSequence DO
      CongruentialStep(sequence.value1, sequence.value2);
      value := sequence.value1 - sequence.value2;
      IF value <= 0 THEN
        INC(value, modulus1);
      END;
      RETURN (value - 1.) / (modulus1 - 1.)
    END;
  END DefaultSequenceValue;

  PROCEDURE DefaultSequenceRewind(sequence: Sequence);
  BEGIN
    WITH sequence: DefaultSequence DO
      sequence.value1 := sequence.seed1;
      sequence.value2 := sequence.seed2;
    END;
  END DefaultSequenceRewind;

  PROCEDURE DefaultSequenceRestart(sequence, seed: Sequence);
  BEGIN
    WITH sequence: DefaultSequence DO
      sequence.seed1 := ValS(seed, 1, modulus1-1);
      sequence.seed2 := ValS(seed, 1, modulus2-1);
      sequence.value1 := sequence.seed1;
      sequence.value2 := sequence.seed2;
    END;
  END DefaultSequenceRestart;

  PROCEDURE CreateDefaultSequences;
    VAR
      mySeed, myStd: DefaultSequence;
      if: Interface;
      daytime: Times.Time;
      timeval: Times.TimeValueRec;
      count: Types.Int32;

    PROCEDURE Hash(str: ARRAY OF CHAR): Types.Int32;
      VAR
        index,
        val: Types.Int32;
    BEGIN
      val := 27567352;
      index := 0;
      WHILE str[index] # 0X DO
        val := (val MOD 16777216) * 128 +
          (val DIV 16777216 + ORD(str[index])) MOD 128;
        INC(index);
      END; (*WHILE*)
      RETURN val
    END Hash;

  BEGIN
    (* define interface for all default sequences *)
    NEW(if);
    if.longRealValS := DefaultSequenceValue;
    if.rewindSequence := DefaultSequenceRewind;
    if.restartSequence := DefaultSequenceRestart;

    (* fake initial randomness using some portably accessible sources *)
    NEW(mySeed);
    Services.Init(mySeed, defaultSequenceType);
    Init(mySeed, if, {longRealValS});
    Clocks.GetTime(Clocks.system, daytime);
    Times.GetValue(daytime, timeval);
    (* extract those 31 bits from daytime that are most likely to vary *)
    mySeed.value1 := timeval.usec * 2048 + timeval.second MOD 65536 + 1;
    (* generate 31 more bits from the process name *)
    mySeed.value2 := Hash(Process.name) MOD (modulus2 - 1) + 1;
    (* scramble these values *)
    count := 0;
    WHILE count < 4 DO
      CongruentialStep(mySeed.value1, mySeed.value2);
      INC(count);
    END;
    (* mix them together *)
    DefaultSequenceRestart(mySeed, mySeed);
    seed := mySeed;

    (* now use our seed to initialize std sequence *)
    NEW(myStd);
    Services.Init(myStd, defaultSequenceType);
    Init(myStd, if, {longRealValS, rewindSequence, restartSequence});
    DefaultSequenceRestart(myStd, mySeed);
    std := myStd;

    unpredictable := NIL;
  END CreateDefaultSequences;

BEGIN
  serviceDiscID := Disciplines.Unique();
  Services.Create(service, "RandomGenerators");
  Services.CreateType(sequenceType, "RandomGenerators.Sequence", "");
  Services.CreateType(defaultSequenceType, "RandomGenerators.DefaultSequence",
     "RandomGenerators.Sequence");
  CreateDefaultSequences;
END ulmRandomGenerators.
