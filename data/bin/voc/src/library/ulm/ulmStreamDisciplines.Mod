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
  $Id: StreamDisci.om,v 1.2 1994/07/04 14:53:25 borchert Exp $
  ----------------------------------------------------------------------------
  $Log: StreamDisci.om,v $
  Revision 1.2  1994/07/04  14:53:25  borchert
  parameter for indentation width added

  Revision 1.1  1994/02/22  20:10:34  borchert
  Initial revision

  ----------------------------------------------------------------------------
  AFB 10/91
  ----------------------------------------------------------------------------
*)

MODULE ulmStreamDisciplines;

  (* definition of general-purpose disciplines for streams *)

  IMPORT ASCII := ulmASCII, Disciplines := ulmIndirectDisciplines, Events := ulmEvents, Sets := ulmSets, Streams := ulmStreams, SYSTEM, Types := ulmTypes;

  TYPE
    LineTerminator* = ARRAY 4 OF CHAR;
  VAR
    badfieldsepset*: Events.EventType;

  TYPE
    StreamDiscipline = POINTER TO StreamDisciplineRec;
    StreamDisciplineRec =
      RECORD
        (Disciplines.DisciplineRec)
        lineterm: LineTerminator;
        fieldseps: Sets.CharSet;
        fieldsep: CHAR; (* one of them *)
        whitespace: Sets.CharSet;
        indentwidth: Types.Int32;
      END;

  VAR
    id: Disciplines.Identifier;
    (* default values *)
    defaultFieldSeps: Sets.CharSet;
    defaultFieldSep: CHAR;
    defaultLineTerm: LineTerminator;
    defaultWhiteSpace: Sets.CharSet;
    defaultIndentWidth: Types.Int32;

  PROCEDURE InitDiscipline(VAR disc: Disciplines.Discipline);
    VAR
      sdisc: StreamDiscipline;
  BEGIN
    NEW(sdisc); sdisc.id := id;
    sdisc.fieldseps := defaultFieldSeps;
    sdisc.fieldsep := defaultFieldSep;
    sdisc.lineterm := defaultLineTerm;
    sdisc.whitespace := defaultWhiteSpace;
    sdisc.indentwidth := defaultIndentWidth;
    disc := sdisc
  END InitDiscipline;

  PROCEDURE SetLineTerm*(s: Streams.Stream; lineterm: LineTerminator);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF ~Disciplines.Seek(s, id, disc) THEN
      InitDiscipline(disc);
    END;
    disc(StreamDiscipline).lineterm := lineterm;
    Disciplines.Add(s, disc);
  END SetLineTerm;

  PROCEDURE GetLineTerm*(s: Streams.Stream; VAR lineterm: LineTerminator);
    (* default line terminator is ASCII.nl *)
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      lineterm := disc(StreamDiscipline).lineterm;
    ELSE
      lineterm := defaultLineTerm;
    END;
  END GetLineTerm;

  PROCEDURE SetFieldSepSet*(s: Streams.Stream; fieldsepset: Sets.CharSet);
    (* cardinality of fieldsepset must be >= 1 *)
    VAR
      disc: Disciplines.Discipline;
      ch: CHAR; found: BOOLEAN;
      fieldsep: CHAR;
      event: Events.Event;
  BEGIN
    ch := 0X;
    LOOP (* seek for the first element inside fieldsepset *)
      IF Sets.CharIn(fieldsepset, ch) THEN
        found := TRUE; fieldsep := ch; EXIT
      END;
      IF ch = MAX(CHAR) THEN
        found := FALSE; EXIT
      END;
      ch := CHR(ORD(ch) + 1);
    END;
    IF ~found THEN
      NEW(event);
      event.message := "StreamDisciplines.SetFieldSepSet: empty fieldsepset";
      event.type := badfieldsepset;
      Events.Raise(event);
      RETURN
    END;
    IF ~Disciplines.Seek(s, id, disc) THEN
      InitDiscipline(disc);
    END;
    disc(StreamDiscipline).fieldseps := fieldsepset;
    disc(StreamDiscipline).fieldsep := fieldsep;
    Disciplines.Add(s, disc);
  END SetFieldSepSet;

  PROCEDURE GetFieldSepSet*(s: Streams.Stream; VAR fieldsepset: Sets.CharSet);
    (* default field separators are ASCII.tab and ASCII.sp *)
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      fieldsepset := disc(StreamDiscipline).fieldseps;
    ELSE
      fieldsepset := defaultFieldSeps;
    END;
  END GetFieldSepSet;

  PROCEDURE SetFieldSep*(s: Streams.Stream; fieldsep: CHAR);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF ~Disciplines.Seek(s, id, disc) THEN
      InitDiscipline(disc);
    END;
    Sets.InclChar(disc(StreamDiscipline).fieldseps, fieldsep);
    disc(StreamDiscipline).fieldsep := fieldsep;
    Disciplines.Add(s, disc);
  END SetFieldSep;

  PROCEDURE GetFieldSep*(s: Streams.Stream; VAR fieldsep: CHAR);
    (* default field separator is ASCII.tab;
      if a set of field separators has been given via SetFieldSepSet,
      one of them is returned
    *)
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      fieldsep := disc(StreamDiscipline).fieldsep;
    ELSE
      fieldsep := defaultFieldSep;
    END;
  END GetFieldSep;

  PROCEDURE GetWhiteSpace*(s: Streams.Stream; VAR whitespace: Sets.CharSet);
    (* default: ASCII.tab, ASCII.sp, ASCII.np and ASCII.nl *)
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      whitespace := disc(StreamDiscipline).whitespace;
    ELSE
      whitespace := defaultWhiteSpace;
    END;
  END GetWhiteSpace;

  PROCEDURE SetWhiteSpace*(s: Streams.Stream; whitespace: Sets.CharSet);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF ~Disciplines.Seek(s, id, disc) THEN
      InitDiscipline(disc);
    END;
    disc(StreamDiscipline).whitespace := whitespace;
    Disciplines.Add(s, disc);
  END SetWhiteSpace;

  PROCEDURE SetIndentationWidth*(s: Streams.Stream; indentwidth: Types.Int32);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF indentwidth >= 0 THEN
      IF ~Disciplines.Seek(s, id, disc) THEN
        InitDiscipline(disc);
      END;
      disc(StreamDiscipline).indentwidth := indentwidth;
      Disciplines.Add(s, disc);
    END;
  END SetIndentationWidth;

  PROCEDURE GetIndentationWidth*(s: Streams.Stream; VAR indentwidth: Types.Int32);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF Disciplines.Seek(s, id, disc) THEN
      indentwidth := disc(StreamDiscipline).indentwidth;
    ELSE
      indentwidth := defaultIndentWidth;
    END;
  END GetIndentationWidth;

  PROCEDURE IncrIndentationWidth*(s: Streams.Stream; incr: Types.Int32);
    VAR
      disc: Disciplines.Discipline;
  BEGIN
    IF ~Disciplines.Seek(s, id, disc) THEN
      InitDiscipline(disc);
    END;
    IF disc(StreamDiscipline).indentwidth + incr >= 0 THEN
      INC(disc(StreamDiscipline).indentwidth, incr);;
    END;
    Disciplines.Add(s, disc);
  END IncrIndentationWidth;

BEGIN
  Events.Define(badfieldsepset);

  id := Disciplines.Unique();
  Sets.InitSet(defaultFieldSeps);
  Sets.InclChar(defaultFieldSeps, ASCII.tab);
  Sets.InclChar(defaultFieldSeps, ASCII.sp);
  defaultFieldSep := ASCII.tab;
  defaultLineTerm[0] := ASCII.nl; defaultLineTerm[1] := 0X;
  Sets.InitSet(defaultWhiteSpace);
  Sets.InclChar(defaultWhiteSpace, ASCII.tab);
  Sets.InclChar(defaultWhiteSpace, ASCII.sp);
  Sets.InclChar(defaultWhiteSpace, ASCII.np);
  Sets.InclChar(defaultWhiteSpace, ASCII.nl);
  defaultIndentWidth := 0;
END ulmStreamDisciplines.
