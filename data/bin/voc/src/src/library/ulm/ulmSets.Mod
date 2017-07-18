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
   $Id: Sets.om,v 1.3 1999/06/06 06:44:56 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Sets.om,v $
   Revision 1.3  1999/06/06  06:44:56  borchert
   bug fix: CharSet was too small

   Revision 1.2  1995/03/16  16:25:33  borchert
   assertions of Assertions replaced by real assertions

   Revision 1.1  1994/02/22  20:10:14  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/89
   ----------------------------------------------------------------------------
*)

MODULE ulmSets;
IMPORT Types := ulmTypes;

   CONST
      setsize* = MAX(Types.Set) + 1;

   TYPE
      CharSet* = ARRAY (ORD(MAX(CHAR)) + 1) DIV setsize OF Types.Set;

   PROCEDURE InitSet*(VAR set: ARRAY OF Types.Set);
      VAR i: Types.Int32;
   BEGIN
      i := 0;
      WHILE i < LEN(set) DO
         set[i] := {}; INC(i);
      END;
   END InitSet;

   PROCEDURE Complement*(VAR set: ARRAY OF Types.Set);
      VAR i: Types.Int32;
   BEGIN
      i := 0;
      WHILE i < LEN(set) DO
         set[i] := - set[i]; INC(i);
      END;
   END Complement;

   PROCEDURE In*(VAR set: ARRAY OF Types.Set; i: Types.Int32) : BOOLEAN;
   BEGIN
      RETURN (i MOD setsize) IN set[i DIV setsize]
   END In;

   PROCEDURE Incl*(VAR set: ARRAY OF Types.Set; i: Types.Int32);
   BEGIN
      INCL(set[i DIV setsize], i MOD setsize);
   END Incl;

   PROCEDURE Excl*(VAR set: ARRAY OF Types.Set; i: Types.Int32);
   BEGIN
      EXCL(set[i DIV setsize], i MOD setsize);
   END Excl;

   PROCEDURE CharIn*(VAR charset: CharSet; ch: CHAR) : BOOLEAN;
   BEGIN
      RETURN (ORD(ch) MOD setsize) IN charset[ORD(ch) DIV setsize]
   END CharIn;

   PROCEDURE InclChar*(VAR charset: CharSet; ch: CHAR);
   BEGIN
      INCL(charset[ORD(ch) DIV setsize], ORD(ch) MOD setsize);
   END InclChar;

   PROCEDURE ExclChar*(VAR charset: CharSet; ch: CHAR);
   BEGIN
      EXCL(charset[ORD(ch) DIV setsize], ORD(ch) MOD setsize);
   END ExclChar;

   PROCEDURE Intersection*(set1, set2: ARRAY OF Types.Set; VAR result: ARRAY OF Types.Set);
      VAR
         index: Types.Int32;
   BEGIN
      ASSERT((LEN(result) = LEN(set1)) & (LEN(result) = LEN(set2)));
      index := 0;
      WHILE index < LEN(result) DO
         result[index] := set1[index] * set2[index];
         INC(index);
      END;
   END Intersection;

   PROCEDURE SymDifference*(set1, set2: ARRAY OF Types.Set; VAR result: ARRAY OF Types.Set);
      VAR
         index: Types.Int32;
   BEGIN
      ASSERT((LEN(result) = LEN(set1)) & (LEN(result) = LEN(set2)));
      index := 0;
      WHILE index < LEN(result) DO
         result[index] := set1[index] / set2[index];
         INC(index);
      END;
   END SymDifference;

   PROCEDURE Union*(set1, set2: ARRAY OF Types.Set; VAR result: ARRAY OF Types.Set);
      VAR
         index: Types.Int32;
   BEGIN
      ASSERT((LEN(result) = LEN(set1)) & (LEN(result) = LEN(set2)));
      index := 0;
      WHILE index < LEN(result) DO
         result[index] := set1[index] + set2[index];
         INC(index);
      END;
   END Union;

   PROCEDURE Difference*(set1, set2: ARRAY OF Types.Set; VAR result: ARRAY OF Types.Set);
      VAR
         index: Types.Int32;
   BEGIN
      ASSERT((LEN(result) = LEN(set1)) & (LEN(result) = LEN(set2)));
      index := 0;
      WHILE index < LEN(result) DO
         result[index] := set1[index] - set2[index];
         INC(index);
      END;
   END Difference;

   PROCEDURE Equal*(set1, set2: ARRAY OF Types.Set) : BOOLEAN;
      VAR
         index: Types.Int32;
   BEGIN
      index := 0;
      WHILE (index < LEN(set1)) & (index < LEN(set2)) DO
         IF set1[index] # set2[index] THEN
            RETURN FALSE
         END;
         INC(index);
      END;
      WHILE index < LEN(set1) DO
         IF set1[index] # {} THEN
            RETURN FALSE
         END;
         INC(index);
      END;
      WHILE index < LEN(set2) DO
         IF set2[index] # {} THEN
            RETURN FALSE
         END;
         INC(index);
      END;
      RETURN TRUE
   END Equal;

   PROCEDURE Subset*(set1, set2: ARRAY OF Types.Set) : BOOLEAN;
      VAR
         index: Types.Int32;
   BEGIN
      index := 0;
      WHILE (index < LEN(set1)) & (index < LEN(set2)) DO
         IF set1[index] - set2[index] # {} THEN
            RETURN FALSE
         END;
         INC(index);
      END;
      WHILE index < LEN(set1) DO
         IF set1[index] # {} THEN
            RETURN FALSE
         END;
         INC(index);
      END;
      RETURN TRUE
   END Subset;

   PROCEDURE Card*(set: ARRAY OF Types.Set) : Types.Int32;
      VAR
         index: Types.Int32;
         i: Types.Int32;
         card: Types.Int32;
   BEGIN
      card := 0;
      index := 0;
      WHILE index < LEN(set) DO
         i := 0;
         WHILE i <= MAX(Types.Set) DO
            IF i IN set[index] THEN
               INC(card);
            END;
            INC(i);
         END;
         INC(index);
      END;
      RETURN card
   END Card;

END ulmSets.
