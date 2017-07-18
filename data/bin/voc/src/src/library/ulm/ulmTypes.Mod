(* Ulm's Oberon Library
   Copyright (C) 1989-2000 by University of Ulm, SAI, D-89069 Ulm, Germany
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
   $Id: Types.om,v 1.5 2000/12/13 10:03:00 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: Types.om,v $
   Revision 1.5  2000/12/13  10:03:00  borchert
   SetInt type used in msb constant

   Revision 1.4  2000/12/13  09:51:57  borchert
   constants and types for the relationship of Types.Int32 and Types.Set added

   Revision 1.3  1998/09/25 15:23:09  borchert
   Real32..Real128 added

   Revision 1.2  1994/07/01  11:08:04  borchert
   IntAddress, Int8/16/32, ToInt8/16/32 and bit/little endian stuff added

   Revision 1.1  1994/02/22  20:12:14  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 9/93
   ----------------------------------------------------------------------------
*)

MODULE ulmTypes;

   (* compiler-dependent type definitions;
      this version works for Ulm's Oberon Compilers on
      following architectures: m68k and sparc
   *)

   IMPORT SYS := SYSTEM;

   TYPE
      Address* = SYS.ADDRESS;
      UntracedAddress* = POINTER[1] TO UntracedAddressDesc;
	  UntracedAddressDesc* = RECORD[1] END;

      Count* = SYS.INT32;
      Size* = Count;
      Byte* = SYS.BYTE;
      IntAddress* = SYS.INT32;
      Int8* = SYS.INT8;
      Int16* = SYS.INT16;
      Int32* = SYS.INT32;
      Real32* = LONGREAL;
      Real64* = LONGREAL;
	  Set*   = SYS.SET32;

   CONST
      bigEndian* = 0;    (* SPARC, M68K etc *)
      littleEndian* = 1; (* Intel 80x86, VAX etc *)
      byteorder* = littleEndian; (* machine-dependent constant *)
   TYPE
      ByteOrder* = SYS.INT8; (* bigEndian or littleEndian *)

   (* following constants and type definitions try to make
      conversions from Types.Int32 to Types.Set and vice versa more portable
      to allow for bit operations on Types.Int32 values
   *)
   TYPE
      SetInt* = SYS.INT32; (* Types.Int32 type that corresponds to Types.Set *)
   VAR
      msb*: SYS.SET32;
	  msbIsMax*, msbIs0*: SYS.INT8;
	  msbindex*, lsbindex*, nofbits*: SYS.INT32;

   PROCEDURE ToInt8*(int: Int32) : Int8;
   BEGIN
      RETURN SHORT(SHORT(int))
   END ToInt8;

   PROCEDURE ToInt16*(int: Int32) : Int16;
   BEGIN
      RETURN SYS.VAL(Int16, int)
   END ToInt16;

   PROCEDURE ToInt32*(int: Int32) : Int32;
   BEGIN
      RETURN int
   END ToInt32;

   PROCEDURE ToReal32*(real: Real64) : Real32;
   BEGIN
      RETURN SHORT(real)
   END ToReal32;

   PROCEDURE ToReal64*(real: Real64) : Real64;
   BEGIN
      RETURN SHORT(real)
   END ToReal64;

BEGIN

     msb := SYS.VAL(SYS.SET32, MIN(SetInt));
	 (* most significant bit, converted to a Types.Set *)
      (* we expect msbIsMax XOR msbIs0 to be 1;
	 this is checked for by an assertion
      *)
      msbIsMax := SYS.VAL(SYS.INT8, (msb = {MAX(Set)}));
	 (* is 1, if msb equals {MAX(Set)} *)
      msbIs0 := SYS.VAL(SYS.INT8, (msb = {0}));
	 (* is 0, if msb equals {0} *)
      msbindex := msbIsMax * MAX(Set);
	 (* set element that corresponds to the most-significant-bit *)
      lsbindex := MAX(Set) - msbindex;
	 (* set element that corresponds to the lowest-significant-bit *)
      nofbits := MAX(Set) + 1;
	 (* number of elements in Sets *)

   ASSERT((msbIs0 = 1) & (msbIsMax = 0) OR (msbIs0 = 0) & (msbIsMax = 1));
END ulmTypes.
