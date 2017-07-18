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
  $Id: Times.om,v 1.3 2001/04/30 14:54:44 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Times.om,v $
  Revision 1.3  2001/04/30 14:54:44  borchert
  bug fix: base type is TimeRec instead of Times.TimeRec
        (invalid self-reference)

  Revision 1.2  1995/04/07 13:25:07  borchert
  fixes due to changed if of PersistentObjects

  Revision 1.1  1994/02/22  20:12:02  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 12/91
  ----------------------------------------------------------------------------
*)

MODULE ulmTimes;

  IMPORT NetIO := ulmNetIO, Objects := ulmObjects, Operations := ulmOperations, PersistentObjects := ulmPersistentObjects, Scales := ulmScales,
    Services := ulmServices, Streams := ulmStreams, Types := ulmTypes;

  CONST
    relative* = Scales.relative;
    absolute* = Scales.absolute;
  TYPE
    (* the common base type of all time measures *)
    Time* = POINTER TO TimeRec;
    TimeRec* = RECORD (Scales.MeasureRec) END;

  CONST
    usecsPerSec = 1000000; (* 10^6 *)
  TYPE
    (* units of the reference implementation:
      epoch, second and usec
    *)
    TimeValueRec* =
      RECORD
        (Objects.ObjectRec)
        (* epoch 0: Jan. 1, 1970;
          each epoch has a length of MAX(Scales.Value) + 1 seconds;
          epoch may be negative:
          -1 is the epoch just before 1970
        *)
        epoch*: Scales.Value;
        (* seconds and ... *)
        second*: Scales.Value;
        (* ... microseconds since the beginning of the epoch *)
        usec*: Scales.Value;
      END;

  (* ==== private datatypes for the reference scale *)
  TYPE
    ReferenceTime = POINTER TO ReferenceTimeRec;
    ReferenceTimeRec =
      RECORD
        (TimeRec)
        timeval: TimeValueRec;
      END;
  VAR
    absType, relType: Services.Type;
  CONST
    epochUnit = 0; secondUnit = 1; usecUnit = 2;
  TYPE
    Unit = POINTER TO UnitRec;
    UnitRec =
      RECORD
        (Scales.UnitRec)
        index: Types.Int8; (* epochUnit..usecUnit *)
      END;

  VAR
    scale*: Scales.Scale; (* reference scale *)
    family*: Scales.Family; (* family of time scales *)
    if: Scales.Interface;

  PROCEDURE Create*(VAR time: Time; type: Types.Int8);
    (* type = absolute or relative *)
    VAR
      m: Scales.Measure;
  BEGIN
    Scales.CreateMeasure(scale, m, type);
    time := m(Time);
  END Create;

  PROCEDURE Normalize(VAR timeval: TimeValueRec);
    (* make sure that second and usec >= 0 *)
    VAR
      toomanysecs: Scales.Value;
      secs: Scales.Value;
  BEGIN
    IF timeval.second < 0 THEN
      INC(timeval.second, 1);
      INC(timeval.second, MAX(Scales.Value));
      DEC(timeval.epoch);
    END;
    IF timeval.usec < 0 THEN
      toomanysecs := timeval.usec DIV usecsPerSec;
      IF toomanysecs > timeval.second THEN
        timeval.second := - toomanysecs + MAX(Scales.Value) + 1 +
                    timeval.second;
        DEC(timeval.epoch);
      ELSE
        DEC(timeval.second, toomanysecs);
      END;
      timeval.usec := timeval.usec MOD usecsPerSec;
    ELSIF timeval.usec >= usecsPerSec THEN
      secs := timeval.usec DIV usecsPerSec;
      IF MAX(Scales.Value) - timeval.second <= secs THEN
        INC(timeval.second, secs);
      ELSE
        timeval.second := secs - (MAX(Scales.Value) - timeval.second);
        INC(timeval.epoch);
      END;
      timeval.usec := timeval.usec MOD usecsPerSec;
    END;
  END Normalize;

  PROCEDURE SetValue*(time: Time; value: TimeValueRec);
    VAR
      refTime:     Time;
      measure:     Scales.Measure;
      scaleOfTime: Scales.Scale;
  BEGIN
    Normalize(value);
    IF time IS ReferenceTime THEN
      WITH time: ReferenceTime DO
        time.timeval := value;
      END;
    ELSE
      Create(refTime, Scales.MeasureType(time));
      refTime(ReferenceTime).timeval := value;
      Scales.GetScale(time, scaleOfTime);
      measure := refTime;
      Scales.ConvertMeasure(scaleOfTime, measure);
      Operations.Copy(measure, time);
    END;
  END SetValue;

  PROCEDURE CreateAndSet*(VAR time: Time; type: Types.Int8;
                  epoch, second, usec: Scales.Value);
    VAR
      timeval: TimeValueRec;
  BEGIN
    Create(time, type);
    timeval.epoch := epoch; timeval.second := second; timeval.usec := usec;
    SetValue(time, timeval);
  END CreateAndSet;

  PROCEDURE GetValue*(time: Time; VAR value: TimeValueRec);
    VAR mtime: Scales.Measure;
  BEGIN
    IF ~(time IS ReferenceTime) THEN
      Scales.ConvertMeasure(scale, mtime); time := mtime(Time)
    END;
    value := time(ReferenceTime).timeval;
  END GetValue;

  (* ===== interface procedures =================================== *)

  PROCEDURE InternalCreate(scale: Scales.Scale;
                   VAR measure: Scales.Measure; abs: BOOLEAN);
    VAR
      time: ReferenceTime;
  BEGIN
    NEW(time);
    time.timeval.epoch := 0;
    time.timeval.second := 0;
    time.timeval.usec := 0;
    IF abs THEN
      PersistentObjects.Init(time, absType);
    ELSE
      PersistentObjects.Init(time, relType);
    END;
    measure := time;
  END InternalCreate;

  PROCEDURE InternalGetValue(measure: Scales.Measure; unit: Scales.Unit;
                    VAR value: Scales.Value);
  BEGIN
    WITH measure: ReferenceTime DO WITH unit: Unit DO
      CASE unit.index OF
      | epochUnit:  value := measure.timeval.epoch;
      | secondUnit:  value := measure.timeval.second;
      | usecUnit:    value := measure.timeval.usec;
   ELSE
      END;
    END; END;
  END InternalGetValue;

  PROCEDURE InternalSetValue(measure: Scales.Measure; unit: Scales.Unit;
                    value: Scales.Value);
  BEGIN
    WITH measure: ReferenceTime DO WITH unit: Unit DO
      CASE unit.index OF
      | epochUnit:   measure.timeval.epoch := value;
      | secondUnit:  measure.timeval.second := value;
      | usecUnit:    measure.timeval.usec := value;
   ELSE
      END;
      Normalize(measure.timeval);
    END; END;
  END InternalSetValue;

  PROCEDURE Assign(target: Scales.Measure; source: Scales.Measure);
  BEGIN
    WITH target: ReferenceTime DO WITH source: ReferenceTime DO
      target.timeval := source.timeval;
    END; END;
  END Assign;

  PROCEDURE Op(op: Scales.Operation; op1, op2, result: Scales.Measure);

    PROCEDURE Add(op1, op2: TimeValueRec; VAR result: TimeValueRec);
    BEGIN
      result.epoch := op1.epoch + op2.epoch;
      IF op1.second > MAX(Scales.Value) - op2.second THEN
        INC(result.epoch);
        result.second := op1.second - MAX(Scales.Value) - 1 +
                    op2.second;
      ELSE
        result.second := op1.second + op2.second;
      END;
      result.usec := op1.usec + op2.usec;
      IF result.usec > usecsPerSec THEN
        DEC(result.usec, usecsPerSec);
        IF result.second = MAX(Scales.Value) THEN
          result.second := 0; INC(result.epoch);
        ELSE
          INC(result.second);
        END;
      END;
    END Add;

    PROCEDURE Sub(op1, op2: TimeValueRec; VAR result: TimeValueRec);
    BEGIN
      result.epoch := op1.epoch - op2.epoch;
      IF op1.second >= op2.second THEN
        result.second := op1.second - op2.second;
      ELSE
        DEC(result.epoch);
        result.second := - op2.second + MAX(Scales.Value) + 1 + op1.second;
      END;
      result.usec := op1.usec - op2.usec;
      IF result.usec < 0 THEN
        INC(result.usec, usecsPerSec);
        IF result.second = 0 THEN
          result.second := MAX(Scales.Value);
          DEC(result.epoch);
        ELSE
          DEC(result.second);
        END;
      END;
    END Sub;

  BEGIN
    WITH op1: ReferenceTime DO WITH op2: ReferenceTime DO
      WITH result: ReferenceTime DO
        CASE op OF
        | Scales.add:  Add(op1.timeval, op2.timeval, result.timeval);
        | Scales.sub:  Sub(op1.timeval, op2.timeval, result.timeval);
     ELSE
        END;
      END;
    END; END;
  END Op;

  PROCEDURE Compare(op1, op2: Scales.Measure) : Types.Int32;

    PROCEDURE ReturnVal(val1, val2: Scales.Value) : Types.Int32;
    BEGIN
          IF val1 < val2 THEN
            RETURN -1
          ELSIF val1 > val2 THEN
            RETURN 1
          ELSE
            RETURN 0
          END;
    END ReturnVal;

  BEGIN
    WITH op1: ReferenceTime DO
      WITH op2: ReferenceTime DO
            IF op1.timeval.epoch # op2.timeval.epoch THEN
              RETURN ReturnVal(op1.timeval.epoch, op2.timeval.epoch)
            ELSIF op1.timeval.second # op2.timeval.second THEN
              RETURN ReturnVal(op1.timeval.second, op2.timeval.second)
            ELSE
              RETURN ReturnVal(op1.timeval.usec, op2.timeval.usec)
            END;
      END;
    END;
    RETURN 0;
  END Compare;

  (* ========= initialization procedures ========================== *)

  PROCEDURE InitInterface;
    VAR
      timeType: Services.Type;
  BEGIN
    NEW(if);
    if.create := InternalCreate;
    if.getvalue := InternalGetValue; if.setvalue := InternalSetValue;
    if.assign := Assign; if.op := Op; if.compare := Compare;
    (* conversion procedures are not necessary *)

    PersistentObjects.RegisterType(timeType, "Times.Time", "Scales.Measure",
                         NIL);
  END InitInterface;

  PROCEDURE CreateAbs(VAR object: PersistentObjects.Object);
    VAR
      measure: Scales.Measure;
  BEGIN
    Scales.CreateAbsMeasure(scale, measure);
    object := measure;
  END CreateAbs;

  PROCEDURE CreateRel(VAR object: PersistentObjects.Object);
    VAR
      measure: Scales.Measure;
  BEGIN
    Scales.CreateRelMeasure(scale, measure);
    object := measure;
  END CreateRel;

  PROCEDURE Write(s: Streams.Stream;
             object: PersistentObjects.Object) : BOOLEAN;
  BEGIN
    WITH object: ReferenceTime DO
      RETURN NetIO.WriteLongInt(s, object.timeval.epoch) &
           NetIO.WriteLongInt(s, object.timeval.second) &
           NetIO.WriteLongInt(s, object.timeval.usec)
    END;
  END Write;

  PROCEDURE Read(s: Streams.Stream;
            object: PersistentObjects.Object) : BOOLEAN;
  BEGIN
    WITH object: ReferenceTime DO
      RETURN NetIO.ReadLongInt(s, object.timeval.epoch) &
           NetIO.ReadLongInt(s, object.timeval.second) &
           NetIO.ReadLongInt(s, object.timeval.usec)
    END;
  END Read;

  PROCEDURE InitRefScale;

    VAR
      poif: PersistentObjects.Interface;

    PROCEDURE InitUnit(unitIndex: Types.Int8; name: Scales.UnitName);
      VAR
        unit: Unit;
    BEGIN
      NEW(unit); unit.index := unitIndex;
      Scales.InitUnit(scale, unit, name);
    END InitUnit;

  BEGIN
    NEW(scale); Scales.Init(scale, NIL, if);
    InitUnit(epochUnit, "epoch");
    InitUnit(secondUnit, "second");
    InitUnit(usecUnit, "usec");

    NEW(poif); poif.read := Read; poif.write := Write;
    poif.create := CreateAbs; poif.createAndRead := NIL;
    PersistentObjects.RegisterType(absType,
            "Times.AbsReferenceTime", "Times.Time", poif);
    NEW(poif); poif.read := Read; poif.write := Write;
    poif.create := CreateRel; poif.createAndRead := NIL;
    PersistentObjects.RegisterType(relType,
            "Times.RelReferenceTime", "Times.Time", poif);
  END InitRefScale;

BEGIN
  InitInterface;
  InitRefScale;
  NEW(family); Scales.InitFamily(family, scale);
END ulmTimes.
