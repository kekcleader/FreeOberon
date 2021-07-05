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
  $Id: NetIO.om,v 1.4 2004/05/21 15:19:03 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: NetIO.om,v $
  Revision 1.4  2004/05/21 15:19:03  borchert
  performance improvements:
  - ReadConstStringD prefers Streams.ReadPart and ConstStrings.CreateD,
    if possible
    (based on code by Christian Ehrhardt)
  - WriteConstString uses Streams.Copy instead of a loop that uses
    Streams.ReadByte and Streams.WriteByte

  Revision 1.3  1995/03/17 16:28:20  borchert
  - SizeOf stuff removed
  - support of const strings added
  - support of Forwarders added

  Revision 1.2  1994/07/18  14:18:37  borchert
  unused variables of WriteString (ch + index) removed

  Revision 1.1  1994/02/22  20:08:43  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 6/93
  ----------------------------------------------------------------------------
*)

MODULE ulmNetIO;

  (* abstraction for the exchange of Oberon base types which
    are components of persistent data structures
  *)

  IMPORT ConstStrings := ulmConstStrings, Disciplines := ulmDisciplines, Forwarders := ulmForwarders, Streams := ulmStreams, Strings := ulmStrings,
    SYS := SYSTEM, Types := ulmTypes;

  TYPE
    Byte* = Types.Byte;

  TYPE
    ReadByteProc* =
      PROCEDURE (s: Streams.Stream; VAR byte: Byte) : BOOLEAN;
    ReadCharProc* =
      PROCEDURE (s: Streams.Stream; VAR char: CHAR) : BOOLEAN;
    ReadBooleanProc* =
      PROCEDURE (s: Streams.Stream; VAR boolean: BOOLEAN) : BOOLEAN;
    ReadShortIntProc* =
      PROCEDURE (s: Streams.Stream; VAR shortint: Types.Int8) : BOOLEAN;
    ReadIntegerProc* =
      PROCEDURE (s: Streams.Stream; VAR integer: Types.Int32) : BOOLEAN;
    ReadLongIntProc* =
      PROCEDURE (s: Streams.Stream; VAR longint: Types.Int32) : BOOLEAN;
    ReadRealProc* =
      PROCEDURE (s: Streams.Stream; VAR real: Types.Real32) : BOOLEAN;
    ReadLongRealProc* =
      PROCEDURE (s: Streams.Stream; VAR longreal: Types.Real64) : BOOLEAN;
    ReadSetProc* =
      PROCEDURE (s: Streams.Stream; VAR set: Types.Set) : BOOLEAN;
    ReadStringProc* =
      PROCEDURE (s: Streams.Stream; VAR string: ARRAY OF CHAR) : BOOLEAN;
    ReadConstStringProc* =
      PROCEDURE (s: Streams.Stream; domain: ConstStrings.Domain;
              VAR string: ConstStrings.String) : BOOLEAN;

    WriteByteProc* =
      PROCEDURE (s: Streams.Stream; byte: Byte) : BOOLEAN;
    WriteCharProc* =
      PROCEDURE (s: Streams.Stream; char: CHAR) : BOOLEAN;
    WriteBooleanProc* =
      PROCEDURE (s: Streams.Stream; boolean: BOOLEAN) : BOOLEAN;
    WriteShortIntProc* =
      PROCEDURE (s: Streams.Stream; shortint: Types.Int8) : BOOLEAN;
    WriteIntegerProc* =
      PROCEDURE (s: Streams.Stream; integer: Types.Int32) : BOOLEAN;
    WriteLongIntProc* =
      PROCEDURE (s: Streams.Stream; longint: Types.Int32) : BOOLEAN;
    WriteRealProc* =
      PROCEDURE (s: Streams.Stream; real: Types.Real32) : BOOLEAN;
    WriteLongRealProc* =
      PROCEDURE (s: Streams.Stream; longreal: Types.Real64) : BOOLEAN;
    WriteSetProc* =
      PROCEDURE (s: Streams.Stream; set: Types.Set) : BOOLEAN;
    WriteStringProc* =
      PROCEDURE (s: Streams.Stream; string: ARRAY OF CHAR) : BOOLEAN;
    WriteConstStringProc* =
      PROCEDURE (s: Streams.Stream;
              string: ConstStrings.String) : BOOLEAN;

    Interface* = POINTER TO InterfaceRec;
    InterfaceRec* =
      RECORD
        readByte*: ReadByteProc;
        readChar*: ReadCharProc;
        readBoolean*: ReadBooleanProc;
        readShortInt*: ReadShortIntProc;
        readInteger*: ReadIntegerProc;
        readLongInt*: ReadLongIntProc;
        readReal*: ReadRealProc;
        readLongReal*: ReadLongRealProc;
        readSet*: ReadSetProc;
        readString*: ReadStringProc;
        readConstString*: ReadConstStringProc;

        writeByte*: WriteByteProc;
        writeChar*: WriteCharProc;
        writeBoolean*: WriteBooleanProc;
        writeShortInt*: WriteShortIntProc;
        writeInteger*: WriteIntegerProc;
        writeLongInt*: WriteLongIntProc;
        writeReal*: WriteRealProc;
        writeLongReal*: WriteLongRealProc;
        writeSet*: WriteSetProc;
        writeString*: WriteStringProc;
        writeConstString*: WriteConstStringProc;
      END;

  (* private data structures *)
  TYPE
    Discipline = POINTER TO DisciplineRec;
    DisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        if: Interface;
      END;
  VAR
    discID: Disciplines.Identifier;

  PROCEDURE Seek(s: Streams.Stream; id: Disciplines.Identifier; disc: Discipline): BOOLEAN;
    VAR d: Disciplines.Discipline; result: BOOLEAN;
  BEGIN
    result := Disciplines.Seek(s, id, d);
    IF result THEN disc := d(Discipline) ELSE disc := NIL END;
    RETURN result
  END Seek;

  PROCEDURE Swap (VAR a : ARRAY OF SYS.BYTE);
    VAR
      i,j : Types.Int32;
      tmp : SYS.BYTE;
  BEGIN
    i := 0; j := LEN (a) - 1;
    WHILE i < j DO
      tmp := a[i]; a[i] := a[j]; a[j] := tmp;
      INC (i); DEC (j);
    END;
  END Swap;

  PROCEDURE BitSwap (VAR a : ARRAY OF SYS.BYTE);
    VAR
      i,old, bit : Types.Int32;
      new : Types.Int32;

  BEGIN
    i := 0;
    WHILE i < LEN (a) DO
      old := ORD (SYS.VAL (CHAR, a[i]));
      new := 0; bit := 080H;
      WHILE old # 0 DO
        IF ODD (old) THEN
          INC (new, bit);
        END;
        bit := ASH (bit, -1);;
        old := ASH (old, -1);
      END;
      a[i] := SYS.VAL (SYS.BYTE, new);
      INC (i);
    END;
  END BitSwap;

  PROCEDURE ^ Forward(from, to: Forwarders.Object);

  PROCEDURE AttachInterface*(s: Streams.Stream; if: Interface);
    VAR
      disc: Discipline;
  BEGIN
    IF if # NIL THEN
      NEW(disc); disc.id := discID; disc.if := if;
      Disciplines.Add(s, disc);
    ELSE
      Disciplines.Remove(s, discID);
    END;
    Forwarders.Update(s, Forward);
  END AttachInterface;

  PROCEDURE GetInterface(s: Streams.Stream; VAR if: Interface);
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      if := disc.if;
    ELSE
      if := NIL;
    END;
  END GetInterface;

  PROCEDURE CopyInterface*(from, to: Streams.Stream);
    VAR
      if: Interface;
  BEGIN
    GetInterface(from, if);
    AttachInterface(to, if);
  END CopyInterface;

  PROCEDURE Forward(from, to: Forwarders.Object);
  BEGIN
    (* this check is necessary because of Forwarders.Update *)
    IF ~(from IS Streams.Stream) OR ~(to IS Streams.Stream) THEN
      RETURN
    END;

    WITH from: Streams.Stream DO WITH to: Streams.Stream DO
      (* be careful here, from & to must be reversed *)
      CopyInterface(to, from);
    END; END;
  END Forward;

  PROCEDURE ReadByte*(s: Streams.Stream; VAR byte: Byte) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readByte(s, byte)
    ELSE
      RETURN Streams.ReadByte(s, byte)
    END;
  END ReadByte;

  PROCEDURE ReadChar*(s: Streams.Stream; VAR char: CHAR) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readChar(s, char)
    ELSE
      RETURN Streams.ReadByte(s, char)
    END;
  END ReadChar;

  PROCEDURE ReadBoolean*(s: Streams.Stream; VAR boolean: BOOLEAN) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readBoolean(s, boolean)
    ELSE
      RETURN Streams.Read(s, boolean)
    END;
  END ReadBoolean;

  PROCEDURE ReadShortInt*(s: Streams.Stream; VAR shortint: Types.Int8) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readShortInt(s, shortint)
    ELSE
      RETURN Streams.ReadByte(s, shortint)
    END;
  END ReadShortInt;

  PROCEDURE ReadInteger*(s: Streams.Stream; VAR integer: Types.Int32) : BOOLEAN;
    VAR
      disc: Discipline;
      ret : BOOLEAN;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readInteger(s, integer)
    ELSE
      ret := Streams.Read(s, integer);
      IF Types.byteorder = Types.littleEndian THEN
        Swap (integer);
      END;
      RETURN ret;
    END;
  END ReadInteger;

  PROCEDURE ReadLongInt*(s: Streams.Stream; VAR longint: Types.Int32) : BOOLEAN;
    VAR
      disc: Discipline;
      ret : BOOLEAN;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readLongInt(s, longint)
    ELSE
      ret := Streams.Read(s, longint);
      IF Types.byteorder = Types.littleEndian THEN
        Swap (longint);
      END;
      RETURN ret;
    END;
  END ReadLongInt;

  PROCEDURE ReadReal*(s: Streams.Stream; VAR real: Types.Real32) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readReal(s, real)
    ELSE
      RETURN Streams.Read(s, real)
    END;
  END ReadReal;

  PROCEDURE ReadLongReal*(s: Streams.Stream; VAR longreal: Types.Real64) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readLongReal(s, longreal)
    ELSE
      RETURN Streams.Read(s, longreal)
    END;
  END ReadLongReal;

  PROCEDURE ReadSet*(s: Streams.Stream; VAR set: Types.Set) : BOOLEAN;
    VAR
      disc: Discipline;
      ret : BOOLEAN;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readSet(s, set)
    ELSE
      ret := Streams.Read(s, set);
      IF Types.byteorder = Types.littleEndian THEN
        BitSwap (set);
      END;
      RETURN ret;
    END;
  END ReadSet;

  PROCEDURE ReadString*(s: Streams.Stream; VAR string: ARRAY OF CHAR) : BOOLEAN;
    VAR
      disc: Discipline;
      ch: CHAR; index: Types.Int32;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readString(s, string)
    ELSE
      index := 0;
      WHILE Streams.ReadByte(s, ch) & (ch # 0X) DO
        IF index + 1 < LEN(string) THEN
          string[index] := ch; INC(index);
        END;
      END;
      string[index] := 0X;
      RETURN ~s.error
    END;
  END ReadString;

  PROCEDURE ReadConstStringD*(s: Streams.Stream;
                    domain: ConstStrings.Domain;
                    VAR string: ConstStrings.String) : BOOLEAN;
    CONST
      bufsize = 512;
    VAR
      length: Types.Int32;
      buf: Streams.Stream;
      ch: CHAR;
      disc: Discipline;
      stringbuf: ARRAY bufsize OF CHAR;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.readConstString(s, domain, string)
    ELSE
      IF ReadLongInt(s, length) THEN
        IF length >= bufsize THEN
          ConstStrings.Init(buf);
          IF ~Streams.Copy(s, buf, length) THEN
            RETURN FALSE
          END;
          ConstStrings.CloseD(buf, domain, string);
          RETURN length = s.count;
        ELSE
          IF ~Streams.ReadPart(s, stringbuf, 0, length) THEN
            RETURN FALSE
          END;
          stringbuf[length] := 0X;
          ConstStrings.CreateD(string, domain, stringbuf);
          RETURN TRUE
        END;
      ELSE
        RETURN FALSE
      END;
    END;
  END ReadConstStringD;

  PROCEDURE ReadConstString*(s: Streams.Stream;
                    VAR string: ConstStrings.String) : BOOLEAN;
  BEGIN
    RETURN ReadConstStringD(s, ConstStrings.std, string)
  END ReadConstString;

  PROCEDURE WriteByte*(s: Streams.Stream; byte: Byte) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeByte(s, byte)
    ELSE
      RETURN Streams.WriteByte(s, byte)
    END;
  END WriteByte;

  PROCEDURE WriteChar*(s: Streams.Stream; char: CHAR) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeChar(s, char)
    ELSE
      RETURN Streams.WriteByte(s, char)
    END;
  END WriteChar;

  PROCEDURE WriteBoolean*(s: Streams.Stream; boolean: BOOLEAN) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeBoolean(s, boolean)
    ELSE
      RETURN Streams.Write(s, boolean)
    END;
  END WriteBoolean;

  PROCEDURE WriteShortInt*(s: Streams.Stream; shortint: Types.Int8) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeShortInt(s, shortint)
    ELSE
      RETURN Streams.WriteByte(s, shortint)
    END;
  END WriteShortInt;

  PROCEDURE WriteInteger*(s: Streams.Stream; integer: Types.Int32) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeInteger(s, integer)
    ELSE
      IF Types.byteorder = Types.littleEndian THEN
        Swap (integer);
      END;
      RETURN Streams.Write(s, integer);
    END;
  END WriteInteger;

  PROCEDURE WriteLongInt*(s: Streams.Stream; longint: Types.Int32) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeLongInt(s, longint)
    ELSE
      IF Types.byteorder = Types.littleEndian THEN
        Swap (longint);
      END;
      RETURN Streams.Write(s, longint);
    END;
  END WriteLongInt;

  PROCEDURE WriteReal*(s: Streams.Stream; real: Types.Real32) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeReal(s, real)
    ELSE
      RETURN Streams.Write(s, real)
    END;
  END WriteReal;

  PROCEDURE WriteLongReal*(s: Streams.Stream; longreal: Types.Real64) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeLongReal(s, longreal)
    ELSE
      RETURN Streams.Write(s, longreal)
    END;
  END WriteLongReal;

  PROCEDURE WriteSet*(s: Streams.Stream; set: Types.Set) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeSet(s, set)
    ELSE
      IF Types.byteorder = Types.littleEndian THEN
        BitSwap (set);
      END;
      RETURN Streams.Write(s, set)
    END;
  END WriteSet;

  PROCEDURE WriteString*(s: Streams.Stream; string: ARRAY OF CHAR) : BOOLEAN;
    VAR
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeString(s, string)
    ELSE
      RETURN Streams.WritePart(s, string, 0, Strings.Len(string)) &
           Streams.WriteByte(s, 0X)
    END;
  END WriteString;

  PROCEDURE WriteConstString*(s: Streams.Stream;
                    string: ConstStrings.String) : BOOLEAN;
    VAR
      ch: CHAR;
      buf: Streams.Stream;
      disc: Discipline;
  BEGIN
    IF Seek(s, discID, disc) THEN
      RETURN disc.if.writeConstString(s, string)
    ELSE
      IF WriteLongInt(s, string.len) THEN
        ConstStrings.Open(buf, string);
        RETURN Streams.Copy(buf, s, string.len)
      ELSE
        RETURN FALSE
      END;
    END;
  END WriteConstString;

BEGIN
  discID := Disciplines.Unique();
  Forwarders.Register("Streams.Stream", Forward);
END ulmNetIO.
