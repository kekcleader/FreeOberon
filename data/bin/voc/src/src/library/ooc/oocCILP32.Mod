(* 	$Id: C.Mod,v 1.9 1999/10/03 11:46:01 ooc-devel Exp $	 *)
MODULE oocC;

(* ILP32 model *)

(*  Basic data types for interfacing to C code.
    Copyright (C) 1997-1998  Michael van Acken

    This module is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License
    as published by the Free Software Foundation; either version 2 of
    the License, or (at your option) any later version.

    This module is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with OOC. If not, write to the Free Software Foundation,
    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*)
 
IMPORT SYSTEM;
  
(*
These types are intended to be equivalent to their C counterparts.
They may vary depending on your system, but as long as you stick to a 32 Bit
Unix they should be fairly safe.
*)  

TYPE
  char*       = CHAR;                        (*  8 bits *)
  signedchar* = SHORTINT;                    (*  8 bits *)
  shortint*   = RECORD a,b: SYSTEM.BYTE END; (* 16 bits *)
  int*        = LONGINT;                     (* 32 bits *)   
  set*        = LONGINT;                     (* 32 bits *)
  longint*    = LONGINT;                     (* 32 bits on ILP32 (64 bits is 'long long') *)
(*longset*    = SET;  n/a *)                 (* 64 bit SET *)
  address*    = LONGINT;                     (* 32 bits *)
  float*      = REAL;                        (* 32 bits *)
  double*     = LONGREAL;                    (* 64 bits *)

  enum1* = int;
  (*
    enum2* = int;
    enum4* = int;
  *)
  
  FILE*  = address;  (* this is acually a replacement for `FILE*', i.e., for a pointer type *)
  sizet* = longint;  (* 32 bits in i686 *)
  uidt*  = int;
  gidt*  = int;


TYPE  (* some commonly used C array types *)
  charPtr1d* = POINTER TO ARRAY OF char;
  charPtr2d* = POINTER TO ARRAY OF charPtr1d;
  intPtr1d*  = POINTER TO ARRAY OF int;

TYPE  (* C string type, assignment compatible with character arrays and
         string constants *)
  string* = POINTER TO ARRAY OF char;
  
TYPE
  Proc* = PROCEDURE;
  
END oocC.
