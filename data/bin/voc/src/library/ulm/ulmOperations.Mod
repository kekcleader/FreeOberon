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
  $Id: Operations.om,v 1.4 2004/09/16 18:31:54 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: Operations.om,v $
  Revision 1.4  2004/09/16 18:31:54  borchert
  optimization for Assign added in case of a non-NIL target
  and identical types for target and source

  Revision 1.3  1997/02/05  16:27:45  borchert
  Init asserts now that Services.Init hat been called previously
  for ``op''

  Revision 1.2  1995/01/16  21:39:50  borchert
  - assertions of Assertions have been converted into real assertions
  - some fixes due to changes of PersistentObjects

  Revision 1.1  1994/02/22  20:09:03  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 12/91
  ----------------------------------------------------------------------------
*)

MODULE ulmOperations;

  (* generic support of arithmetic operations *)

  IMPORT Events := ulmEvents, Objects := ulmObjects, PersistentDisciplines := ulmPersistentDisciplines, PersistentObjects := ulmPersistentObjects, Services := ulmServices, Types := ulmTypes;

  CONST
    add* = 0; sub* = 1; mul* = 2; div* = 3; cmp* = 4;
  TYPE
    Operation* = Types.Int8; (* add..cmp *)
    Operand* = POINTER TO OperandRec;

  TYPE
    CapabilitySet* = Types.Set; (* Types.Set OF [add..cmp] *)
    CreateProc* = PROCEDURE (VAR op: Operand);
      (* should call Operations.Init for op *)
    OperatorProc* = PROCEDURE (op: Operation; op1, op2: Operand;
                      VAR result: Operand);
    AssignProc* = PROCEDURE (VAR target: Operand; source: Operand);
    CompareProc* = PROCEDURE (op1, op2: Operand) : Types.Int32;
    Interface* = POINTER TO InterfaceRec;
    InterfaceRec* =
      RECORD
        (Objects.ObjectRec)
        create*: CreateProc;
        assign*: AssignProc;
        op*: OperatorProc;
        compare*: CompareProc;
      END;

  TYPE
    OperandRec* =
      RECORD
        (PersistentDisciplines.ObjectRec)
        if: Interface;
        caps: CapabilitySet;
      END;
  VAR
    operandType: Services.Type;

  PROCEDURE Init*(op: Operand; if: Interface; caps: CapabilitySet);
    VAR
      type: Services.Type;
  BEGIN
    Services.GetType(op, type); ASSERT(type # NIL);
    op.if := if; op.caps := caps;
  END Init;

  PROCEDURE Capabilities*(op: Operand) : CapabilitySet;
  BEGIN
    RETURN op.caps
  END Capabilities;

  PROCEDURE Compatible*(op1, op2: Operand) : BOOLEAN;
    (* return TRUE if both operands have the same interface *)
  BEGIN
    RETURN op1.if = op2.if
  END Compatible;

  (* the interface of the first operand must match the interface
    of all other operands;
    the result parameter must be either NIL or already initialized
    with the same interface
  *)

  PROCEDURE Op(op: Operation; op1, op2: Operand; VAR result: Operand);

    VAR
      tmpresult: Operand;
  BEGIN
    ASSERT(op1.if = op2.if);
    ASSERT(op IN op1.caps);
    (* we are very defensive here because the type of tmpresult
      is perhaps not identical to result or an extension of it;
      op1.if.create(result) will not work in all cases
      because of type guard failures
    *)
    op1.if.create(tmpresult);
    op1.if.op(op, op1, op2, tmpresult);
    result := tmpresult;
  END Op;

  PROCEDURE Add*(op1, op2: Operand) : Operand;
    VAR result: Operand;
  BEGIN
    result := NIL;
    Op(add, op1, op2, result);
    RETURN result
  END Add;

  PROCEDURE Add2*(VAR op1: Operand; op2: Operand);
  BEGIN
    Op(add, op1, op2, op1);
  END Add2;

  PROCEDURE Add3*(VAR result: Operand; op1, op2: Operand);
  BEGIN
    Op(add, op1, op2, result);
  END Add3;

  PROCEDURE Sub*(op1, op2: Operand) : Operand;
    VAR result: Operand;
  BEGIN
    result := NIL;
    Op(sub, op1, op2, result);
    RETURN result
  END Sub;

  PROCEDURE Sub2*(VAR op1: Operand; op2: Operand);
  BEGIN
    Op(sub, op1, op2, op1);
  END Sub2;

  PROCEDURE Sub3*(VAR result: Operand; op1, op2: Operand);
  BEGIN
    Op(sub, op1, op2, result);
  END Sub3;

  PROCEDURE Mul*(op1, op2: Operand) : Operand;
    VAR result: Operand;
  BEGIN
    result := NIL;
    Op(mul, op1, op2, result);
    RETURN result
  END Mul;

  PROCEDURE Mul2*(VAR op1: Operand; op2: Operand);
  BEGIN
    Op(mul, op1, op2, op1);
  END Mul2;

  PROCEDURE Mul3*(VAR result: Operand; op1, op2: Operand);
  BEGIN
    Op(mul, op1, op2, result);
  END Mul3;

  PROCEDURE Div*(op1, op2: Operand) : Operand;
    VAR result: Operand;
  BEGIN
    result := NIL;
    Op(div, op1, op2, result);
    RETURN result
  END Div;

  PROCEDURE Div2*(VAR op1: Operand; op2: Operand);
  BEGIN
    Op(div, op1, op2, op1);
  END Div2;

  PROCEDURE Div3*(VAR result: Operand; op1, op2: Operand);
  BEGIN
    Op(div, op1, op2, result);
  END Div3;

  PROCEDURE Compare*(op1, op2: Operand) : Types.Int32;
  BEGIN
    ASSERT(op1.if = op2.if);
    ASSERT(cmp IN op1.caps);
    RETURN op1.if.compare(op1, op2)
  END Compare;

  PROCEDURE Assign*(VAR target: Operand; source: Operand);
    VAR
      tmpTarget: Operand;
      typesIdentical: BOOLEAN;
      targetType, sourceType: Services.Type;
  BEGIN
    IF (target # NIL) & (target.if = source.if) THEN
      Services.GetType(target, targetType);
      Services.GetType(source, sourceType);
      typesIdentical := targetType = sourceType;
    ELSE
      typesIdentical := FALSE;
    END;
    IF typesIdentical THEN
      source.if.assign(target, source);
    ELSE
      source.if.create(tmpTarget);
      source.if.assign(tmpTarget, source);
      target := tmpTarget;
    END;
  END Assign;

  PROCEDURE Copy*(source, target: Operand);
  BEGIN
    source.if.assign(target, source);
  END Copy;

BEGIN
  PersistentObjects.RegisterType(operandType,
    "Operations.Operand", "PersistentDisciplines.Object", NIL);
END ulmOperations.
