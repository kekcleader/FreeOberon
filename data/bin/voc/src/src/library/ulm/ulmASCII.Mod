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
   $Id: ASCII.om,v 1.1 1994/02/22 20:01:03 borchert Exp $
   ----------------------------------------------------------------------------
   $Log: ASCII.om,v $
   Revision 1.1  1994/02/22  20:01:03  borchert
   Initial revision

   ----------------------------------------------------------------------------
   AFB 12/90
   ----------------------------------------------------------------------------
*)

MODULE ulmASCII;

   CONST

      (* control characters *)
      nul* = 000X;   soh* = 001X;   stx* = 002X;   etx* = 003X;   eot* = 004X;
      enq* = 005X;   ack* = 006X;   bel* = 007X;   bs*  = 008X;   ht*  = 009X;
      nl*  = 00AX;   vt*  = 00BX;   np*  = 00CX;   cr*  = 00DX;   so*  = 00EX;
      si*  = 00FX;   dle* = 010X;   dc1* = 011X;   dc2* = 012X;   dc3* = 013X;
      dc4* = 014X;   nak* = 015X;   syn* = 016X;   etb* = 017X;   can* = 018X;
      em*  = 019X;   sub* = 01AX;   esc* = 01BX;   fs*  = 01CX;   gs*  = 01DX;
      rs*  = 01EX;   us*  = 01FX;   sp*  = 020X;   del* = 07FX;

      CtrlA* = 01X;  CtrlB* = 02X;  CtrlC* = 03X;  CtrlD* = 04X;  CtrlE* = 05X;
      CtrlF* = 06X;  CtrlG* = 07X;  CtrlH* = 08X;  CtrlI* = 09X;  CtrlJ* = 0AX;
      CtrlK* = 0BX;  CtrlL* = 0CX;  CtrlM* = 0DX;  CtrlN* = 0EX;  CtrlO* = 0FX;
      CtrlP* = 10X;  CtrlQ* = 11X;  CtrlR* = 12X;  CtrlS* = 13X;  CtrlT* = 14X;
      CtrlU* = 15X;  CtrlV* = 16X;  CtrlW* = 17X;  CtrlX* = 18X;  CtrlY* = 19X;
      CtrlZ* = 1AX;

      (* other usual names *)
      EOL* = nl;
      null* = nul;
      bell* = bel;
      tab* = ht;
      lf* = nl;
      ff* = np;
      quote* = 22X;

END ulmASCII.
