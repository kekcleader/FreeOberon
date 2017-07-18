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
  $Id: Scales.om,v 1.3 2004/09/03 09:31:53 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Scales.om,v $
  Revision 1.3  2004/09/03 09:31:53  borchert
  bug fixes: Services.Init added in CreateOperand
          Scales.Measure changed to Measure

  Revision 1.2  1995/01/16  21:40:39  borchert
  - assertions of Assertions converted into real assertions
  - fixes due to changed if of PersistentObjects

  Revision 1.1  1994/02/22  20:10:03  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 12/91
  ----------------------------------------------------------------------------
*)

MODULE ulmScales;

  IMPORT Disciplines := ulmDisciplines, Events := ulmEvents, Objects := ulmObjects, Operations := ulmOperations, PersistentObjects := ulmPersistentObjects,
    RelatedEvents := ulmRelatedEvents, Services := ulmServices, SYS := SYSTEM, Types := ulmTypes;

  TYPE
    Scale* = POINTER TO ScaleRec;
    Family* = POINTER TO FamilyRec;
    FamilyRec* =
      RECORD
        (Disciplines.ObjectRec)
        (* private components *)
        reference: Scale;
      END;

  TYPE
    Unit* = POINTER TO UnitRec;
    UnitList = POINTER TO UnitListRec;
    UnitListRec =
      RECORD
        unit: Unit;
        next: UnitList;
      END;
    Interface* = POINTER TO InterfaceRec;
    ScaleRec* =
      RECORD
        (Disciplines.ObjectRec)
        (* private components *)
        if: Interface;
        family: Family;
        head, tail: UnitList;
        nextUnit: UnitList;
      END;

  CONST
    unitNameLength* = 32;
  TYPE
    UnitName* = ARRAY unitNameLength OF CHAR;
    UnitRec* = RECORD
      (Disciplines.ObjectRec)
      name: UnitName;
      scale: Scale;
    END;

  CONST
    undefined = 0; absolute* = 1; relative* = 2;
  TYPE
    Measure* = POINTER TO MeasureRec;
    MeasureRec* =
      RECORD
        (Operations.OperandRec)
        scale: Scale;
        type: Types.Int8; (* absolute or relative? *)
      END;
  VAR
    measureType: Services.Type;

  TYPE
    Value* = Types.Int32;

  CONST
    add* = Operations.add; sub* = Operations.sub;
  TYPE
    Operation* = Types.Int8; (* add or sub *)
  TYPE
    CreateProc* = PROCEDURE (scale: Scale; VAR measure: Measure; abs: BOOLEAN);
    GetValueProc* = PROCEDURE (measure: Measure; unit: Unit; VAR value: Value);
    SetValueProc* = PROCEDURE (measure: Measure; unit: Unit; value: Value);
    AssignProc* = PROCEDURE (target: Measure; source: Measure);
    OperatorProc* = PROCEDURE (op: Operation; op1, op2, result: Measure);
    CompareProc* = PROCEDURE (op1, op2: Measure) : Types.Int32;
    ConvertProc* = PROCEDURE (from, to: Measure);

    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        create*: CreateProc;
        getvalue*: GetValueProc;
        setvalue*: SetValueProc;
        assign*: AssignProc;
        op*: OperatorProc;
        compare*: CompareProc;
        (* the conversion routines are only to be provided
          if the scaling system belongs to a family
        *)
        scaleToReference*: ConvertProc;
        referenceToScale*: ConvertProc;
      END;

  VAR
    invalidOperation*: Events.EventType;
      (* operation cannot be performed for the given combination
        of types (absolute or relative)
      *)
    incompatibleScales*: Events.EventType;
      (* the scales of the operands do not belong to the same family *)
    badCombination*: Events.EventType;
      (* SetValue or GetValue:
        given measure and unit do not belong to the same scaling system
      *)

    (* our interface to Operations *)
    opif: Operations.Interface;
    opcaps: Operations.CapabilitySet;

  (* ======= private procedures ===================================== *)

  PROCEDURE DummyConversion(from, to: Measure);
  BEGIN
    from.scale.if.assign(to, from);
  END DummyConversion;

  (* ======== exported procedures ==================================== *)

  PROCEDURE InitFamily*(family: Family; reference: Scale);
  BEGIN
    family.reference := reference;
    (* the reference scale becomes now a member of the family *)
    reference.family := family;
    reference.if.scaleToReference := DummyConversion;
    reference.if.referenceToScale := DummyConversion;
  END InitFamily;

  PROCEDURE Init*(scale: Scale; family: Family; if: Interface);
    (* reference scales are to be initialized with family = NIL *)
  BEGIN
    scale.if := if;
    scale.family := family;
    scale.head := NIL; scale.tail := NIL;
    scale.nextUnit := NIL;
  END Init;

  PROCEDURE InitUnit*(scale: Scale; unit: Unit; name: UnitName);
    VAR
      listp: UnitList;
  BEGIN
    unit.name := name;
    unit.scale := scale;
    NEW(listp); listp.unit := unit; listp.next := NIL;
    IF scale.head # NIL THEN
      scale.tail.next := listp;
    ELSE
      scale.head := listp;
    END;
    scale.tail := listp;
  END InitUnit;

  PROCEDURE CreateMeasure*(scale: Scale; VAR measure: Measure; type: Types.Int8);
  BEGIN
    scale.if.create(scale, measure, type = absolute);
    Operations.Init(measure, opif, opcaps);
    measure.scale := scale;
    measure.type := type;
  END CreateMeasure;

  PROCEDURE CreateAbsMeasure*(scale: Scale; VAR measure: Measure);
    (* init measure to the origin of the given system *)
  BEGIN
    CreateMeasure(scale, measure, absolute);
  END CreateAbsMeasure;

  PROCEDURE CreateRelMeasure*(scale: Scale; VAR measure: Measure);
    (* init relative measure to 0 *)
  BEGIN
    CreateMeasure(scale, measure, relative);
  END CreateRelMeasure;

  PROCEDURE ConvertMeasure*(scale: Scale; VAR measure: Measure);
    (* convert measure to the given scale which must belong
      to the same family as the original scale of measure
    *)
    VAR
      newMeasure: Measure;
      refMeasure: Measure;
      reference: Scale;
  BEGIN
    IF scale = measure.scale THEN
      (* trivial case -- nothing is to be done *)
      RETURN
    END;
    (* check that both scales belong to the same family *)
    ASSERT((scale.family # NIL) & (scale.family = measure.scale.family));
    CreateMeasure(scale, newMeasure, measure.type);
    reference := scale.family.reference;
    CreateMeasure(reference, refMeasure, measure.type);
    measure.scale.if.scaleToReference(measure, refMeasure);
    scale.if.referenceToScale(refMeasure, newMeasure);
    measure := newMeasure;
  END ConvertMeasure;

  PROCEDURE GetReference*(family: Family; VAR reference: Scale);
  BEGIN
    reference := family.reference;
  END GetReference;

  PROCEDURE GetFamily*(scale: Scale; VAR family: Family);
  BEGIN
    family := scale.family;
  END GetFamily;

  PROCEDURE GetScaleOfUnit*(unit: Unit; VAR scale: Scale);
  BEGIN
    scale := unit.scale;
  END GetScaleOfUnit;

  PROCEDURE GetScale*(measure: Measure; VAR scale: Scale);
  BEGIN
    scale := measure.scale;
  END GetScale;

  PROCEDURE TraverseUnits*(scale: Scale);
  BEGIN
    scale.nextUnit := scale.head;
  END TraverseUnits;

  PROCEDURE NextUnit*(scale: Scale; VAR unit: Unit) : BOOLEAN;
  BEGIN
    IF scale.nextUnit # NIL THEN
      unit := scale.nextUnit.unit;
      scale.nextUnit := scale.nextUnit.next;
      RETURN TRUE
    ELSE
      RETURN FALSE
    END;
  END NextUnit;

  PROCEDURE GetName*(unit: Unit; VAR name: UnitName);
  BEGIN
    name := unit.name;
  END GetName;

  PROCEDURE GetValue*(measure: Measure; unit: Unit; VAR value: Value);
    VAR
      scale: Scale;
  BEGIN
    scale := measure.scale;
    ASSERT(unit.scale = scale);
    scale.if.getvalue(measure, unit, value);
  END GetValue;

  PROCEDURE SetValue*(measure: Measure; unit: Unit; value: Value);
    VAR
      scale: Scale;
  BEGIN
    scale := measure.scale;
    ASSERT(unit.scale = scale);
    scale.if.setvalue(measure, unit, value);
  END SetValue;

  PROCEDURE IsAbsolute*(measure: Measure) : BOOLEAN;
  BEGIN
    RETURN measure.type = absolute
  END IsAbsolute;

  PROCEDURE IsRelative*(measure: Measure) : BOOLEAN;
  BEGIN
    RETURN measure.type = relative
  END IsRelative;

  PROCEDURE MeasureType*(measure: Measure) : Types.Int8;
  BEGIN
    RETURN measure.type
  END MeasureType;

  (* ======== interface procedures for Operations ================= *)

  PROCEDURE CreateOperand(VAR op: Operations.Operand);
    (* at this time we don't know anything about the
      associated scale -- so we've have to delay this decision
    *)
    VAR
      measure: Measure;
  BEGIN
    NEW(measure);
    measure.type := undefined;
    measure.scale := NIL;
    Services.Init(measure, measureType);
    op := measure;
    Operations.Init(op, opif, {Operations.add..Operations.cmp});
  END CreateOperand;

  PROCEDURE Assign(VAR target: Operations.Operand; source: Operations.Operand);
  BEGIN
    (*WITH source: Measure DO WITH target: Measure DO*)
    WITH source: Measure DO IF target IS Measure THEN   (* WITH is replaced by IS -- noch *)
      (* target is already initialized but possibly to a dummy operand
        by CreateOperand
      *)
      IF target(Measure).type = undefined THEN   (* type guard introduced *)
        (* init target with the scale of source *)
        CreateMeasure(source.scale, SYS.VAL(Measure, target), source.type); (* need to cast *)
      END;
      IF target(Measure).scale # source.scale THEN
        (* adapt scale type from source --
          this could lead to a type guard failure if
          target is not of the appropiate type
        *)
        CreateMeasure(source.scale, SYS.VAL(Measure, target), source.type);
      END;
      IF target(Measure).type # source.type THEN
        (* adapt measure type from source *)
        CreateMeasure(target(Measure).scale, SYS.VAL(Measure, target), source.type);
      END;
      source.scale.if.assign(SYS.VAL(Measure, target), source);
    END; END;
  END Assign;

  PROCEDURE CheckCompatibility(op1, op2: Operations.Operand;
                      VAR m1, m2: Measure);
    (* is needed by Op and Compare:
      both operands are checked to be members of the same family;
      if they have different scales of the same family a
      conversion is done;
    *)
    VAR
      scale1, scale2: Scale;
  BEGIN
    WITH op1: Measure DO WITH op2: Measure DO
      scale1 := op1.scale; scale2 := op2.scale;
      IF scale1 # scale2 THEN
        ASSERT((scale1.family # NIL) & (scale1.family = scale2.family));
        (* convert both operands to the reference scale *)
        CreateMeasure(scale1.family.reference, m1, op1.type);
        scale1.if.scaleToReference(op1, m1);
        CreateMeasure(scale2.family.reference, m2, op2.type);
        scale2.if.scaleToReference(op2, m2);
      ELSE
        m1 := op1;
        m2 := op2;
      END;
    END; END;
  END CheckCompatibility;

  PROCEDURE Op(op: Operations.Operation; op1, op2: Operations.Operand;
           VAR result: Operations.Operand);
    VAR
      restype: Types.Int8; (* type of result -- set by CheckTypes *)
      m1, m2: Measure;

    PROCEDURE CheckTypes(VAR restype: Types.Int8);
      (* check operands for correct typing;
        sets restype to the correct result type;
      *)
      VAR ok: BOOLEAN;
    BEGIN
      (*WITH op1: Measure DO WITH op2: Measure DO*)
      IF op1 IS Measure THEN IF op2 IS Measure THEN
        CASE op OF
        | Operations.add: (* only abs + abs is invalid *)
                    ok := (op1(Measure).type = relative) OR
                        (op2(Measure).type = relative);
                    IF op1(Measure).type = op2(Measure).type THEN
                      (* both are relative *)
                      restype := relative;
                    ELSE
                      (* exactly one absolute type is involved *)
                      restype := absolute;
                    END;
        | Operations.sub: (* only rel - abs is invalid *)
                    ok := op1(Measure).type <= op2(Measure).type;
                    IF op1(Measure).type # op2(Measure).type THEN
                      (* abs - rel *)
                      restype := absolute;
                    ELSE
                      (* abs - abs  or  rel - rel *)
                      restype := relative;
                    END;
     ELSE
        END;
        ASSERT(ok); (* invalid operation *)
      END; END;
    END CheckTypes;

  BEGIN (* Op *)
    (* result is already of type Measure; this is guaranteed by Operations *)
    IF result IS Measure THEN
      CheckTypes(restype);
      CheckCompatibility(op1, op2, m1, m2);
      CreateMeasure(m1.scale, SYS.VAL(Measure, result), restype);
      m1.scale.if.op(op, m1, m2, SYS.VAL(Measure, result));
    END;
  END Op;

  PROCEDURE Compare(op1, op2: Operations.Operand) : Types.Int32;
    VAR
      m1, m2: Measure;
  BEGIN
    CheckCompatibility(op1, op2, m1, m2);
    ASSERT(m1.type = m2.type);
    CheckCompatibility(op1, op2, m1, m2);
    RETURN m1.scale.if.compare(m1, m2)
  END Compare;

  PROCEDURE InitInterface;
  BEGIN
    NEW(opif);
    opif.create := CreateOperand;
    opif.assign := Assign;
    opif.op := Op;
    opif.compare := Compare;
    opcaps := {Operations.add, Operations.sub, Operations.cmp};
  END InitInterface;

BEGIN
  InitInterface;
  PersistentObjects.RegisterType(measureType,
              "Scales.Measure", "Operations.Operand", NIL);
END ulmScales.
