MODULE OV;
(* Copyright 2017-2021 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT G := Graph, T := Terminal, Strings, StrList, Out, SYSTEM;
CONST
  (* ControlDesc.status possible values *)
  normal*   = 0;
  disabled* = 1;
  selected* = 2;
  open*     = 3;
  moving*   = 4;
  resizing* = 5;

  (* Simple Hotkeys *)
  hF1*    = 58;
  hF2*    = 59;
  hF3*    = 60;
  hF4*    = 61;
  hF5*    = 62;
  hF6*    = 63;
  hF7*    = 64;
  hF8*    = 65;
  hF9*    = 66;
  hF10*   = 67;
  hF11*   = 68;
  hF12*   = 69;
  hPause* = 72;

  (* Ctrl Hotkeys *)
  hCtrlA*         = 100H + 4;
  hCtrlB*         = 100H + 5;
  hCtrlC*         = 100H + 6;
  hCtrlD*         = 100H + 7;
  hCtrlE*         = 100H + 8;
  hCtrlF*         = 100H + 9;
  hCtrlG*         = 100H + 10;
  hCtrlH*         = 100H + 11;
  hCtrlI*         = 100H + 12;
  hCtrlJ*         = 100H + 13;
  hCtrlK*         = 100H + 14;
  hCtrlL*         = 100H + 15;
  hCtrlM*         = 100H + 16;
  hCtrlN*         = 100H + 17;
  hCtrlO*         = 100H + 18;
  hCtrlP*         = 100H + 19;
  hCtrlQ*         = 100H + 20;
  hCtrlR*         = 100H + 21;
  hCtrlS*         = 100H + 22;
  hCtrlT*         = 100H + 23;
  hCtrlU*         = 100H + 24;
  hCtrlV*         = 100H + 25;
  hCtrlW*         = 100H + 26;
  hCtrlX*         = 100H + 27;
  hCtrlY*         = 100H + 28;
  hCtrlZ*         = 100H + 29;
  hCtrl1*         = 100H + 30;
  hCtrl2*         = 100H + 31;
  hCtrl3*         = 100H + 32;
  hCtrl4*         = 100H + 33;
  hCtrl5*         = 100H + 34;
  hCtrl6*         = 100H + 35;
  hCtrl7*         = 100H + 36;
  hCtrl8*         = 100H + 37;
  hCtrl9*         = 100H + 38;
  hCtrl0*         = 100H + 39;
  hCtrlF1*        = 100H + 58;
  hCtrlF2*        = 100H + 59;
  hCtrlF3*        = 100H + 60;
  hCtrlF4*        = 100H + 61;
  hCtrlF5*        = 100H + 62;
  hCtrlF6*        = 100H + 63;
  hCtrlF7*        = 100H + 64;
  hCtrlF8*        = 100H + 65;
  hCtrlF9*        = 100H + 66;
  hCtrlF10*       = 100H + 67;
  hCtrlF11*       = 100H + 68;
  hCtrlF12*       = 100H + 69;
  hCtrlEsc*       = 100H + 41;
  hCtrlTilde*     = 100H + 53;
  hCtrlMinus*     = 100H + 45;
  hCtrlEquals*    = 100H + 46;
  hCtrlBackspace* = 100H + 42;
  hCtrlTab*       = 100H + 43;
  hCtrlEnter*     = 100H + 40;
  hCtrlColon*     = 100H + 51;
  hCtrlQuote*     = 100H + 52;
  hCtrlBackslash* = 100H + 49;
  hCtrlComma*     = 100H + 54;
  hCtrlStop*      = 100H + 55;
  hCtrlSlash*     = 100H + 56;
  hCtrlInsert*    = 100H + 73;
  hCtrlDel*       = 100H + 76;
  hCtrlHome*      = 100H + 74;
  hCtrlEnd*       = 100H + 77;
  hCtrlPgUp*      = 100H + 75;
  hCtrlPgDn*      = 100H + 78;
  hCtrlLeft*      = 100H + 80;
  hCtrlRight*     = 100H + 79;
  hCtrlUp*        = 100H + 82;
  hCtrlDown*      = 100H + 81;
  hCtrlPause*     = 100H + 72;

  (* Alt Hotkeys *)
  hAltA*         = 200H + 4;
  hAltB*         = 200H + 5;
  hAltC*         = 200H + 6;
  hAltD*         = 200H + 7;
  hAltE*         = 200H + 8;
  hAltF*         = 200H + 9;
  hAltG*         = 200H + 10;
  hAltH*         = 200H + 11;
  hAltI*         = 200H + 12;
  hAltJ*         = 200H + 13;
  hAltK*         = 200H + 14;
  hAltL*         = 200H + 15;
  hAltM*         = 200H + 16;
  hAltN*         = 200H + 17;
  hAltO*         = 200H + 18;
  hAltP*         = 200H + 19;
  hAltQ*         = 200H + 20;
  hAltR*         = 200H + 21;
  hAltS*         = 200H + 22;
  hAltT*         = 200H + 23;
  hAltU*         = 200H + 24;
  hAltV*         = 200H + 25;
  hAltW*         = 200H + 26;
  hAltX*         = 200H + 27;
  hAltY*         = 200H + 28;
  hAltZ*         = 200H + 29;
  hAlt1*         = 200H + 30;
  hAlt2*         = 200H + 31;
  hAlt3*         = 200H + 32;
  hAlt4*         = 200H + 33;
  hAlt5*         = 200H + 34;
  hAlt6*         = 200H + 35;
  hAlt7*         = 200H + 36;
  hAlt8*         = 200H + 37;
  hAlt9*         = 200H + 38;
  hAlt0*         = 200H + 39;
  hAltF1*        = 200H + 58;
  hAltF2*        = 200H + 59;
  hAltF3*        = 200H + 60;
  hAltF4*        = 200H + 61;
  hAltF5*        = 200H + 62;
  hAltF6*        = 200H + 63;
  hAltF7*        = 200H + 64;
  hAltF8*        = 200H + 65;
  hAltF9*        = 200H + 66;
  hAltF10*       = 200H + 67;
  hAltF11*       = 200H + 68;
  hAltF12*       = 200H + 69;
  hAltEsc*       = 200H + 41;
  hAltTilde*     = 200H + 53;
  hAltMinus*     = 200H + 45;
  hAltEquals*    = 200H + 46;
  hAltBackspace* = 200H + 42;
  hAltTab*       = 200H + 43;
  hAltEnter*     = 200H + 40;
  hAltColon*     = 200H + 51;
  hAltQuote*     = 200H + 52;
  hAltBackslash* = 200H + 49;
  hAltComma*     = 200H + 54;
  hAltStop*      = 200H + 55;
  hAltSlash*     = 200H + 56;
  hAltInsert*    = 200H + 73;
  hAltDel*       = 200H + 76;
  hAltHome*      = 200H + 74;
  hAltEnd*       = 200H + 77;
  hAltPgUp*      = 200H + 75;
  hAltPgDn*      = 200H + 78;
  hAltLeft*      = 200H + 80;
  hAltRight*     = 200H + 79;
  hAltUp*        = 200H + 82;
  hAltDown*      = 200H + 81;
  hAltPause*     = 200H + 72;

  (* Shift Hotkeys *)
  hShiftA*         = 400H + 4;
  hShiftB*         = 400H + 5;
  hShiftC*         = 400H + 6;
  hShiftD*         = 400H + 7;
  hShiftE*         = 400H + 8;
  hShiftF*         = 400H + 9;
  hShiftG*         = 400H + 10;
  hShiftH*         = 400H + 11;
  hShiftI*         = 400H + 12;
  hShiftJ*         = 400H + 13;
  hShiftK*         = 400H + 14;
  hShiftL*         = 400H + 15;
  hShiftM*         = 400H + 16;
  hShiftN*         = 400H + 17;
  hShiftO*         = 400H + 18;
  hShiftP*         = 400H + 19;
  hShiftQ*         = 400H + 20;
  hShiftR*         = 400H + 21;
  hShiftS*         = 400H + 22;
  hShiftT*         = 400H + 23;
  hShiftU*         = 400H + 24;
  hShiftV*         = 400H + 25;
  hShiftW*         = 400H + 26;
  hShiftX*         = 400H + 27;
  hShiftY*         = 400H + 28;
  hShiftZ*         = 400H + 29;
  hShift1*         = 400H + 30;
  hShift2*         = 400H + 31;
  hShift3*         = 400H + 32;
  hShift4*         = 400H + 33;
  hShift5*         = 400H + 34;
  hShift6*         = 400H + 35;
  hShift7*         = 400H + 36;
  hShift8*         = 400H + 37;
  hShift9*         = 400H + 38;
  hShift0*         = 400H + 39;
  hShiftF1*        = 400H + 58;
  hShiftF2*        = 400H + 59;
  hShiftF3*        = 400H + 60;
  hShiftF4*        = 400H + 61;
  hShiftF5*        = 400H + 62;
  hShiftF6*        = 400H + 63;
  hShiftF7*        = 400H + 64;
  hShiftF8*        = 400H + 65;
  hShiftF9*        = 400H + 66;
  hShiftF10*       = 400H + 67;
  hShiftF11*       = 400H + 68;
  hShiftF12*       = 400H + 69;
  hShiftEsc*       = 400H + 41;
  hShiftTilde*     = 400H + 53;
  hShiftMinus*     = 400H + 45;
  hShiftEquals*    = 400H + 46;
  hShiftBackspace* = 400H + 42;
  hShiftTab*       = 400H + 43;
  hShiftEnter*     = 400H + 40;
  hShiftColon*     = 400H + 51;
  hShiftQuote*     = 400H + 52;
  hShiftBackslash* = 400H + 49;
  hShiftComma*     = 400H + 54;
  hShiftStop*      = 400H + 55;
  hShiftSlash*     = 400H + 56;
  hShiftInsert*    = 400H + 73;
  hShiftDel*       = 400H + 76;
  hShiftHome*      = 400H + 74;
  hShiftEnd*       = 400H + 77;
  hShiftPgUp*      = 400H + 75;
  hShiftPgDn*      = 400H + 78;
  hShiftLeft*      = 400H + 80;
  hShiftRight*     = 400H + 79;
  hShiftUp*        = 400H + 82;
  hShiftDown*      = 400H + 81;
  hShiftPause*     = 400H + 72;

  (* Ctrl+Shift Hotkeys *)
  hCtrlShiftA*         = 500H + 4;
  hCtrlShiftB*         = 500H + 5;
  hCtrlShiftC*         = 500H + 6;
  hCtrlShiftD*         = 500H + 7;
  hCtrlShiftE*         = 500H + 8;
  hCtrlShiftF*         = 500H + 9;
  hCtrlShiftG*         = 500H + 10;
  hCtrlShiftH*         = 500H + 11;
  hCtrlShiftI*         = 500H + 12;
  hCtrlShiftJ*         = 500H + 13;
  hCtrlShiftK*         = 500H + 14;
  hCtrlShiftL*         = 500H + 15;
  hCtrlShiftM*         = 500H + 16;
  hCtrlShiftN*         = 500H + 17;
  hCtrlShiftO*         = 500H + 18;
  hCtrlShiftP*         = 500H + 19;
  hCtrlShiftQ*         = 500H + 20;
  hCtrlShiftR*         = 500H + 21;
  hCtrlShiftS*         = 500H + 22;
  hCtrlShiftT*         = 500H + 23;
  hCtrlShiftU*         = 500H + 24;
  hCtrlShiftV*         = 500H + 25;
  hCtrlShiftW*         = 500H + 26;
  hCtrlShiftX*         = 500H + 27;
  hCtrlShiftY*         = 500H + 28;
  hCtrlShiftZ*         = 500H + 29;
  hCtrlShift1*         = 500H + 30;
  hCtrlShift2*         = 500H + 31;
  hCtrlShift3*         = 500H + 32;
  hCtrlShift4*         = 500H + 33;
  hCtrlShift5*         = 500H + 34;
  hCtrlShift6*         = 500H + 35;
  hCtrlShift7*         = 500H + 36;
  hCtrlShift8*         = 500H + 37;
  hCtrlShift9*         = 500H + 38;
  hCtrlShift0*         = 500H + 39;
  hCtrlShiftF1*        = 500H + 58;
  hCtrlShiftF2*        = 500H + 59;
  hCtrlShiftF3*        = 500H + 60;
  hCtrlShiftF4*        = 500H + 61;
  hCtrlShiftF5*        = 500H + 62;
  hCtrlShiftF6*        = 500H + 63;
  hCtrlShiftF7*        = 500H + 64;
  hCtrlShiftF8*        = 500H + 65;
  hCtrlShiftF9*        = 500H + 66;
  hCtrlShiftF10*       = 500H + 67;
  hCtrlShiftF11*       = 500H + 68;
  hCtrlShiftF12*       = 500H + 69;
  hCtrlShiftEsc*       = 500H + 41;
  hCtrlShiftTilde*     = 500H + 53;
  hCtrlShiftMinus*     = 500H + 45;
  hCtrlShiftEquals*    = 500H + 46;
  hCtrlShiftBackspace* = 500H + 42;
  hCtrlShiftTab*       = 500H + 43;
  hCtrlShiftEnter*     = 500H + 40;
  hCtrlShiftColon*     = 500H + 51;
  hCtrlShiftQuote*     = 500H + 52;
  hCtrlShiftBackslash* = 500H + 49;
  hCtrlShiftComma*     = 500H + 54;
  hCtrlShiftStop*      = 500H + 55;
  hCtrlShiftSlash*     = 500H + 56;
  hCtrlShiftInsert*    = 500H + 73;
  hCtrlShiftDel*       = 500H + 76;
  hCtrlShiftHome*      = 500H + 74;
  hCtrlShiftEnd*       = 500H + 77;
  hCtrlShiftPgUp*      = 500H + 75;
  hCtrlShiftPgDn*      = 500H + 78;
  hCtrlShiftLeft*      = 500H + 80;
  hCtrlShiftRight*     = 500H + 79;
  hCtrlShiftUp*        = 500H + 82;
  hCtrlShiftDown*      = 500H + 81;
  hCtrlShiftPause*     = 500H + 72;

  (* Ctrl+Alt Hotkeys *)
  hCtrlAltA*         = 300H + 4;
  hCtrlAltB*         = 300H + 5;
  hCtrlAltC*         = 300H + 6;
  hCtrlAltD*         = 300H + 7;
  hCtrlAltE*         = 300H + 8;
  hCtrlAltF*         = 300H + 9;
  hCtrlAltG*         = 300H + 10;
  hCtrlAltH*         = 300H + 11;
  hCtrlAltI*         = 300H + 12;
  hCtrlAltJ*         = 300H + 13;
  hCtrlAltK*         = 300H + 14;
  hCtrlAltL*         = 300H + 15;
  hCtrlAltM*         = 300H + 16;
  hCtrlAltN*         = 300H + 17;
  hCtrlAltO*         = 300H + 18;
  hCtrlAltP*         = 300H + 19;
  hCtrlAltQ*         = 300H + 20;
  hCtrlAltR*         = 300H + 21;
  hCtrlAltS*         = 300H + 22;
  hCtrlAltT*         = 300H + 23;
  hCtrlAltU*         = 300H + 24;
  hCtrlAltV*         = 300H + 25;
  hCtrlAltW*         = 300H + 26;
  hCtrlAltX*         = 300H + 27;
  hCtrlAltY*         = 300H + 28;
  hCtrlAltZ*         = 300H + 29;
  hCtrlAlt1*         = 300H + 30;
  hCtrlAlt2*         = 300H + 31;
  hCtrlAlt3*         = 300H + 32;
  hCtrlAlt4*         = 300H + 33;
  hCtrlAlt5*         = 300H + 34;
  hCtrlAlt6*         = 300H + 35;
  hCtrlAlt7*         = 300H + 36;
  hCtrlAlt8*         = 300H + 37;
  hCtrlAlt9*         = 300H + 38;
  hCtrlAlt0*         = 300H + 39;
  hCtrlAltF1*        = 300H + 58;
  hCtrlAltF2*        = 300H + 59;
  hCtrlAltF3*        = 300H + 60;
  hCtrlAltF4*        = 300H + 61;
  hCtrlAltF5*        = 300H + 62;
  hCtrlAltF6*        = 300H + 63;
  hCtrlAltF7*        = 300H + 64;
  hCtrlAltF8*        = 300H + 65;
  hCtrlAltF9*        = 300H + 66;
  hCtrlAltF10*       = 300H + 67;
  hCtrlAltF11*       = 300H + 68;
  hCtrlAltF12*       = 300H + 69;
  hCtrlAltEsc*       = 300H + 41;
  hCtrlAltTilde*     = 300H + 53;
  hCtrlAltMinus*     = 300H + 45;
  hCtrlAltEquals*    = 300H + 46;
  hCtrlAltBackspace* = 300H + 42;
  hCtrlAltTab*       = 300H + 43;
  hCtrlAltEnter*     = 300H + 40;
  hCtrlAltColon*     = 300H + 51;
  hCtrlAltQuote*     = 300H + 52;
  hCtrlAltBackslash* = 300H + 49;
  hCtrlAltComma*     = 300H + 54;
  hCtrlAltStop*      = 300H + 55;
  hCtrlAltSlash*     = 300H + 56;
  hCtrlAltInsert*    = 300H + 73;
  hCtrlAltDel*       = 300H + 76;
  hCtrlAltHome*      = 300H + 74;
  hCtrlAltEnd*       = 300H + 77;
  hCtrlAltPgUp*      = 300H + 75;
  hCtrlAltPgDn*      = 300H + 78;
  hCtrlAltLeft*      = 300H + 80;
  hCtrlAltRight*     = 300H + 79;
  hCtrlAltUp*        = 300H + 82;
  hCtrlAltDown*      = 300H + 81;
  hCtrlAltPause*     = 300H + 72;

  (* Alt+Shift Hotkeys *)
  hAltShiftA*         = 600H + 4;
  hAltShiftB*         = 600H + 5;
  hAltShiftC*         = 600H + 6;
  hAltShiftD*         = 600H + 7;
  hAltShiftE*         = 600H + 8;
  hAltShiftF*         = 600H + 9;
  hAltShiftG*         = 600H + 10;
  hAltShiftH*         = 600H + 11;
  hAltShiftI*         = 600H + 12;
  hAltShiftJ*         = 600H + 13;
  hAltShiftK*         = 600H + 14;
  hAltShiftL*         = 600H + 15;
  hAltShiftM*         = 600H + 16;
  hAltShiftN*         = 600H + 17;
  hAltShiftO*         = 600H + 18;
  hAltShiftP*         = 600H + 19;
  hAltShiftQ*         = 600H + 20;
  hAltShiftR*         = 600H + 21;
  hAltShiftS*         = 600H + 22;
  hAltShiftT*         = 600H + 23;
  hAltShiftU*         = 600H + 24;
  hAltShiftV*         = 600H + 25;
  hAltShiftW*         = 600H + 26;
  hAltShiftX*         = 600H + 27;
  hAltShiftY*         = 600H + 28;
  hAltShiftZ*         = 600H + 29;
  hAltShift1*         = 600H + 30;
  hAltShift2*         = 600H + 31;
  hAltShift3*         = 600H + 32;
  hAltShift4*         = 600H + 33;
  hAltShift5*         = 600H + 34;
  hAltShift6*         = 600H + 35;
  hAltShift7*         = 600H + 36;
  hAltShift8*         = 600H + 37;
  hAltShift9*         = 600H + 38;
  hAltShift0*         = 600H + 39;
  hAltShiftF1*        = 600H + 58;
  hAltShiftF2*        = 600H + 59;
  hAltShiftF3*        = 600H + 60;
  hAltShiftF4*        = 600H + 61;
  hAltShiftF5*        = 600H + 62;
  hAltShiftF6*        = 600H + 63;
  hAltShiftF7*        = 600H + 64;
  hAltShiftF8*        = 600H + 65;
  hAltShiftF9*        = 600H + 66;
  hAltShiftF10*       = 600H + 67;
  hAltShiftF11*       = 600H + 68;
  hAltShiftF12*       = 600H + 69;
  hAltShiftEsc*       = 600H + 41;
  hAltShiftTilde*     = 600H + 53;
  hAltShiftMinus*     = 600H + 45;
  hAltShiftEquals*    = 600H + 46;
  hAltShiftBackspace* = 600H + 42;
  hAltShiftTab*       = 600H + 43;
  hAltShiftEnter*     = 600H + 40;
  hAltShiftColon*     = 600H + 51;
  hAltShiftQuote*     = 600H + 52;
  hAltShiftBackslash* = 600H + 49;
  hAltShiftComma*     = 600H + 54;
  hAltShiftStop*      = 600H + 55;
  hAltShiftSlash*     = 600H + 56;
  hAltShiftInsert*    = 600H + 73;
  hAltShiftDel*       = 600H + 76;
  hAltShiftHome*      = 600H + 74;
  hAltShiftEnd*       = 600H + 77;
  hAltShiftPgUp*      = 600H + 75;
  hAltShiftPgDn*      = 600H + 78;
  hAltShiftLeft*      = 600H + 80;
  hAltShiftRight*     = 600H + 79;
  hAltShiftUp*        = 600H + 82;
  hAltShiftDown*      = 600H + 81;
  hAltShiftPause*     = 600H + 72;

  (* Ctrl+Alt+Shift Hotkeys *)
  hCtrlAltShiftA*         = 700H + 4;
  hCtrlAltShiftB*         = 700H + 5;
  hCtrlAltShiftC*         = 700H + 6;
  hCtrlAltShiftD*         = 700H + 7;
  hCtrlAltShiftE*         = 700H + 8;
  hCtrlAltShiftF*         = 700H + 9;
  hCtrlAltShiftG*         = 700H + 10;
  hCtrlAltShiftH*         = 700H + 11;
  hCtrlAltShiftI*         = 700H + 12;
  hCtrlAltShiftJ*         = 700H + 13;
  hCtrlAltShiftK*         = 700H + 14;
  hCtrlAltShiftL*         = 700H + 15;
  hCtrlAltShiftM*         = 700H + 16;
  hCtrlAltShiftN*         = 700H + 17;
  hCtrlAltShiftO*         = 700H + 18;
  hCtrlAltShiftP*         = 700H + 19;
  hCtrlAltShiftQ*         = 700H + 20;
  hCtrlAltShiftR*         = 700H + 21;
  hCtrlAltShiftS*         = 700H + 22;
  hCtrlAltShiftT*         = 700H + 23;
  hCtrlAltShiftU*         = 700H + 24;
  hCtrlAltShiftV*         = 700H + 25;
  hCtrlAltShiftW*         = 700H + 26;
  hCtrlAltShiftX*         = 700H + 27;
  hCtrlAltShiftY*         = 700H + 28;
  hCtrlAltShiftZ*         = 700H + 29;
  hCtrlAltShift1*         = 700H + 30;
  hCtrlAltShift2*         = 700H + 31;
  hCtrlAltShift3*         = 700H + 32;
  hCtrlAltShift4*         = 700H + 33;
  hCtrlAltShift5*         = 700H + 34;
  hCtrlAltShift6*         = 700H + 35;
  hCtrlAltShift7*         = 700H + 36;
  hCtrlAltShift8*         = 700H + 37;
  hCtrlAltShift9*         = 700H + 38;
  hCtrlAltShift0*         = 700H + 39;
  hCtrlAltShiftF1*        = 700H + 58;
  hCtrlAltShiftF2*        = 700H + 59;
  hCtrlAltShiftF3*        = 700H + 60;
  hCtrlAltShiftF4*        = 700H + 61;
  hCtrlAltShiftF5*        = 700H + 62;
  hCtrlAltShiftF6*        = 700H + 63;
  hCtrlAltShiftF7*        = 700H + 64;
  hCtrlAltShiftF8*        = 700H + 65;
  hCtrlAltShiftF9*        = 700H + 66;
  hCtrlAltShiftF10*       = 700H + 67;
  hCtrlAltShiftF11*       = 700H + 68;
  hCtrlAltShiftF12*       = 700H + 69;
  hCtrlAltShiftEsc*       = 700H + 41;
  hCtrlAltShiftTilde*     = 700H + 53;
  hCtrlAltShiftMinus*     = 700H + 45;
  hCtrlAltShiftEquals*    = 700H + 46;
  hCtrlAltShiftBackspace* = 700H + 42;
  hCtrlAltShiftTab*       = 700H + 43;
  hCtrlAltShiftEnter*     = 700H + 40;
  hCtrlAltShiftColon*     = 700H + 51;
  hCtrlAltShiftQuote*     = 700H + 52;
  hCtrlAltShiftBackslash* = 700H + 49;
  hCtrlAltShiftComma*     = 700H + 54;
  hCtrlAltShiftStop*      = 700H + 55;
  hCtrlAltShiftSlash*     = 700H + 56;
  hCtrlAltShiftInsert*    = 700H + 73;
  hCtrlAltShiftDel*       = 700H + 76;
  hCtrlAltShiftHome*      = 700H + 74;
  hCtrlAltShiftEnd*       = 700H + 77;
  hCtrlAltShiftPgUp*      = 700H + 75;
  hCtrlAltShiftPgDn*      = 700H + 78;
  hCtrlAltShiftLeft*      = 700H + 80;
  hCtrlAltShiftRight*     = 700H + 79;
  hCtrlAltShiftUp*        = 700H + 82;
  hCtrlAltShiftDown*      = 700H + 81;
  hCtrlAltShiftPause*     = 700H + 72;

TYPE
  CHAR = SHORTCHAR;

  App* = POINTER TO AppDesc;
  Control* = POINTER TO ControlDesc;
  ControlMethod* = POINTER TO ControlMethodDesc;

  ClickHandler* = PROCEDURE (c: Control);
  
  ControlDesc* = EXTENSIBLE RECORD
    app*: App;
    parent*, children*: Control;
    prev*, next*: Control;
    x*, y*, w*, h*: INTEGER;
    enabled*: BOOLEAN;
    default*: BOOLEAN;
    focused*: BOOLEAN;
    mouseActive*: BOOLEAN; (* FALSE if control does not capture mouse events *)
    status*: INTEGER;
    caption*: ARRAY 256 OF CHAR;
    onClick*: ClickHandler;
    do*: ControlMethod
  END;

  ControlMethodDesc* = EXTENSIBLE RECORD
    added*: PROCEDURE (c, child: Control);
    draw*: PROCEDURE (c: Control; x, y: INTEGER);
    resize*: PROCEDURE (c: Control; x, y, w, h: INTEGER);
    refresh*: PROCEDURE (c: Control);
    click*: PROCEDURE (c: Control);
    keyDown*: PROCEDURE (c: Control; key: G.Key);
    textInput*: PROCEDURE (c: Control; ch: INTEGER);
    getFocus*: PROCEDURE (c: Control);
    lostFocus*: PROCEDURE (c: Control);
    mouseMove*: PROCEDURE (c: Control; x, y: INTEGER; buttons: SET);
    mouseDown*: PROCEDURE (c: Control; x, y, button: INTEGER);
    mouseUp*: PROCEDURE (c: Control; x, y, button: INTEGER)
  END;

  Menu* = POINTER TO MenuDesc;
  MenuDesc* = EXTENSIBLE RECORD(ControlDesc)
    innerW*, innerH*: INTEGER;
    hint*: ARRAY 40 OF CHAR;
    hintW*: INTEGER;
    hotkey*: INTEGER;
    lastSelected*: Control
  END;

  QuickBtn* = POINTER TO QuickBtnDesc;
  QuickBtnDesc* = EXTENSIBLE RECORD(MenuDesc) END;

  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = EXTENSIBLE RECORD(ControlDesc) END;

  WinBtn* = POINTER TO WinBtnDesc;
  WinBtnDesc* = EXTENSIBLE RECORD(ButtonDesc) END;

  Scrollbar* = POINTER TO ScrollbarDesc;
  ScrollbarDesc* = EXTENSIBLE RECORD(ControlDesc)
    max*, cur*, step*: INTEGER; (* cur is runner position in range 0..max *)
    runnerOffset*: INTEGER; (* Current visual position of runner *)
    runnerW*: INTEGER; (* Visual width of runner *)
    onScrollbar*: PROCEDURE (c: Control)
  END;

  Edit* = POINTER TO EditDesc;
  EditDesc* = EXTENSIBLE RECORD(ControlDesc)
    len*: INTEGER; (* Actual amount of characters before 0X *)
    pos*: INTEGER
  END;

  ColumnList* = POINTER TO ColumnListDesc;
  ColumnListDesc* = EXTENSIBLE RECORD(ControlDesc)
    cols*: INTEGER; (* Column count *)
    items*: StrList.List;
    begin*: INTEGER; (* What index list begins with visually *)
    cur*: INTEGER;
    scrollbar: Scrollbar;
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = EXTENSIBLE RECORD(ControlDesc)
    cur*: Control;
    modal*: BOOLEAN;
    resizable*: BOOLEAN;
    closeable*: BOOLEAN;
    closeBtn*, zoomBtn*: WinBtn;
    bg*: INTEGER;
    minW*, minH*: INTEGER;
    mx*, my*, mw*, mh*: INTEGER (* To store x, y, w, h when maximized *)
  END;

  AppDesc* = EXTENSIBLE RECORD
    windows*: Window;
    menu*: Menu;
    statusbar*: Menu;
    statusText*: ARRAY 256 OF CHAR;
    cur*: Control;
    dragged*: Control;
    dragX*, dragY*: INTEGER;
    quit*: BOOLEAN;
    needRedraw*: BOOLEAN
  END;

VAR
  controlMethod-: ControlMethod;
  buttonMethod-: ControlMethod;
  winBtnMethod-: ControlMethod;
  scrollbarMethod-: ControlMethod;
  editMethod-: ControlMethod;
  columnListMethod-: ControlMethod;
  windowMethod-: ControlMethod;
  menuMethod-: ControlMethod;
  quickBtnMethod-: ControlMethod;

PROCEDURE DrawAppWindows*(app: App);
VAR w, br: Control;
BEGIN
  T.CharFill(0, 1, T.charsX, T.charsY - 2, CHR(176), 1, 7);
  IF app.windows # NIL THEN
    w := app.windows.next; br := w;
    REPEAT w.do.draw(w, 0, 0); w := w.next UNTIL w = br
  END
END DrawAppWindows;

PROCEDURE DrawAppStatusbar(app: App);
VAR m, br: Control;
  x: INTEGER;
BEGIN x := 0;
  T.CharFill(0, T.charsY - 1, T.charsX, 1, ' ', 0, 7);
  IF app.statusbar.children # NIL THEN
    m := app.statusbar.children; br := m;
    REPEAT m.do.draw(m, 0, T.charsY - 1); INC(x, m.w); m := m.next
    UNTIL m = br
  END;
  IF app.statusText[0] # 0X THEN
    T.PutChar(x, T.charsY - 1, 0B3X, 0, 7);
    T.PutString(x + 2, T.charsY - 1, app.statusText, 0, 7, 0)
  END
END DrawAppStatusbar;

PROCEDURE DrawAppMenu(app: App);
VAR m, br: Control;
BEGIN
  T.CharFill(0, 0, T.charsX, 1, ' ', 0, 7);
  IF app.menu.children # NIL THEN
    m := app.menu.children; br := m;
    REPEAT m.do.draw(m, 0, 0); m := m.next UNTIL m = br
  END
END DrawAppMenu;

PROCEDURE DrawApp*(app: App);
BEGIN
  DrawAppWindows(app);
  DrawAppStatusbar(app);
  DrawAppMenu(app);
  app.needRedraw := FALSE
END DrawApp;

PROCEDURE NeedRedraw*(app: App);
BEGIN app.needRedraw := TRUE
END NeedRedraw;

(* Set the given element as currently focused, notify it with getFocus,
   notify previously focused element and all its (grand-)parents with
   lostFocus, up to but not including the closest common parent.
   If c is NIL, use main window if it exists. *)
PROCEDURE SetAppFocus*(app: App; c: Control);
VAR p, common: Control;
BEGIN
  p := app.cur;
  IF c = NIL THEN c := app.windows END;
  IF p # c THEN
    IF p # NIL THEN
      REPEAT
        IF c = NIL THEN common := NIL
        ELSE common := c.parent;
          WHILE (common # NIL) & (p # common) DO common := common.parent END
        END;
        IF common = NIL THEN
          IF p.do.lostFocus # NIL THEN p.do.lostFocus(p) END;
          p := p.parent
        END
      UNTIL (p = NIL) OR (p = common)
    END;
    app.cur := c;
    IF c = NIL THEN T.ShowCursor(FALSE)
    ELSIF c.do.getFocus # NIL THEN c.do.getFocus(c)
    END
  END
END SetAppFocus;

PROCEDURE UnsetFocus*(app: App);
BEGIN
  SetAppFocus(app, NIL)
END UnsetFocus;

PROCEDURE SetFocus*(c: Control);
BEGIN
  SetAppFocus(c.app, c)
END SetFocus;

(* Sets c.app for the control and all his children recursively. *)
PROCEDURE SetApp(c: Control; app: App);
VAR p, br: Control;
BEGIN c.app := app; p := c.children;
  IF p # NIL THEN br := p;
    REPEAT SetApp(p, app); p := p.next UNTIL p = br
  END
END SetApp;

(* Common *)

PROCEDURE Cap*(ch: CHAR): CHAR;
BEGIN
  IF ('a' <= ch) & (ch <= 'z') THEN ch := CAP(ch) END ;
RETURN ch END Cap;

PROCEDURE ToCP866*(n: INTEGER): CHAR;
BEGIN
  IF n >= 80H THEN
    IF (410H(*A*) <= n) & (n <= 42FH(*YA*)) THEN n := n - 410H + 80H
    ELSIF (430H(*a*) <= n) & (n <= 44FH(*ya*)) THEN
      IF n <= 43FH(*p*) THEN n := n - 430H + 0A0H (*a..p*)
      ELSE n := n - 440H + 0E0H (*r..ya*)
      END
    ELSIF n = 401H(*YO*) THEN n := 0F0H
    ELSIF n = 451H(*yo*) THEN n := 0F1H
    ELSIF n = 2116H(*No*) THEN n := 0FCH
    ELSE n := 0
    END
  END ;
RETURN CHR(n) END ToCP866;

PROCEDURE Refresh*(c: Control);
BEGIN
  IF c.do.refresh # NIL THEN c.do.refresh(c) END
END Refresh;

(** fg2 is a color of marked letters, that are escaped with '&'. *)
PROCEDURE PutMarkedString*(x, y: INTEGER; s: ARRAY OF CHAR; fg, fg2, bg, limit: INTEGER);
VAR i, c: INTEGER;
  mark: BOOLEAN;
BEGIN
  IF limit = 0 THEN limit := T.charsX END; 
  i := 0; mark := FALSE;
  WHILE (i < LEN(s)) & (s[i] # 0X) & (x <= limit) DO
    IF s[i] = '&' THEN mark := TRUE
    ELSE
      IF mark THEN c := fg2; mark := FALSE ELSE c := fg END;
      T.PutChar(x, y, s[i], c, bg);
      INC(x)
    END;
    INC(i)
  END
END PutMarkedString;

PROCEDURE DrawWindowBorder*(x, y, w, h, fg, bg: INTEGER;
  title: ARRAY OF CHAR; resizable, moving, inactive: BOOLEAN);
VAR i, x2, y2, len: INTEGER; ch: CHAR;
    single: BOOLEAN; (* Sigle border *)
BEGIN single := moving OR inactive;
  IF moving THEN fg := 10
  ELSIF inactive THEN
    IF bg = 7 THEN fg := 8 ELSE fg := 7 END
  END;
  x2 := x + w - 1; y2 := y + h - 1;
  IF single THEN ch := 0C4X(*-*) ELSE ch := 0CDX(*=*) END;
  FOR i := x + 1 TO x2 - 1 DO
    T.PutChar(i, y, ch, fg, bg);
    T.PutChar(i, y2, ch, fg, bg)
  END;
  IF single THEN ch := 0B3X(*|*) ELSE ch := 0BAX(*||*) END;
  FOR i := y + 1 TO y2 - 1 DO T.PutChar(x, i, ch, fg, bg) END;
  IF resizable & ~inactive THEN (* Vertical Scrollbarbar: *)
    FOR i := y + 2 TO y2 - 2 DO T.PutChar(x2, i, 0B1X, bg, 3) END;
    T.PutChar(x2, y + 1, 01EX, bg, 3);
    T.PutChar(x2, y2 - 1, 01FX, bg, 3)
  ELSE
    IF single THEN ch := 0B3X(*|*) ELSE ch := 0BAX(*||*) END;
    FOR i := y + 1 TO y2 - 1 DO T.PutChar(x2, i, ch, fg, bg) END
  END; (* Corners: *)
  IF single THEN T.PutChar(x, y, 0DAX, fg, bg);
    T.PutChar(x2, y, 0BFX, fg, bg); T.PutChar(x, y2, 0C0X, fg, bg)
  ELSE T.PutChar(x, y, 0C9X, fg, bg);
    T.PutChar(x2, y, 0BBX, fg, bg); T.PutChar(x, y2, 0C8X, fg, bg)
  END;
  IF resizable & ~inactive THEN (* Corner: *)
    T.PutChar(x2 - 1, y2, 0C4X, 10, bg);
    T.PutChar(x2, y2, 0D9X, 10, bg); (* Maximize button: *)
    T.PutChar(x2 - 4, y, '[', fg, bg);
    IF (w = T.charsX) & (h = T.charsY - 2) THEN i := 18 ELSE i := 24 END;
    T.PutChar(x2 - 3, y, CHR(i), 10, bg);
    T.PutChar(x2 - 2, y, ']', fg, bg);
  ELSIF single THEN T.PutChar(x2, y2, 0D9X, fg, bg)
  ELSE T.PutChar(x2, y2, 0BCX, fg, bg)
  END; (* Close button: *)
  IF ~inactive THEN
    T.PutChar(x + 2, y, '[', fg, bg);
    T.PutChar(x + 3, y, 0FEX, 10, bg);
    T.PutChar(x + 4, y, ']', fg, bg)
  END;
  IF x2 < T.charsX - 1 THEN (* Right shadow: *)
    FOR i := y + 1 TO y2 DO T.SetCharColor(x2 + 1, i, 8, 0) END;
    IF x2 < T.charsX - 2 THEN (* Most right column: *)
      FOR i := y + 1 TO y2 DO T.SetCharColor(x2 + 2, i, 8, 0) END
    END
  END;
  IF y2 < T.charsY - 2 THEN (* Bottom shadow: *)
    FOR i := x + 2 TO x2 + 2 DO T.SetCharColor(i, y2 + 1, 8, 0) END
  END; (* Title: *)
  IF title[0] # 0X THEN
    len := Strings.Length(title);
    i := x + (w - len) DIV 2;
    IF i < x + 5 THEN i := x + 5 END;
    IF i + len > x2 - 4 THEN len := x2 - i - 4 END;
    IF i # x + 5 THEN T.PutChar(i - 1, y, ' ', fg, bg) END;
    IF i + len # x2 - 4 THEN T.PutChar(i + len, y, ' ', fg, bg) END;
    T.PutString(i, y, title, fg, bg, i + len - 1)
  END
END DrawWindowBorder;

PROCEDURE FindChildAt*(c: Control; x, y: INTEGER): Control;
VAR p, br: Control;
BEGIN
  p := c.children; br := p;
  WHILE (p # NIL) &
    ~(p.mouseActive &
      (p.x <= x) & (x < p.x + p.w) &
      (p.y <= y) & (y < p.y + p.h)) DO
    IF p.next = br THEN p := NIL ELSE p := p.next END
  END ;
RETURN p END FindChildAt;

PROCEDURE PassMouseDown*(c: Control; x, y, button: INTEGER): BOOLEAN;
VAR p: Control;
BEGIN p := FindChildAt(c, x, y);
  IF (p # NIL) & (p.do.mouseDown # NIL) THEN
    p.do.mouseDown(p, x - p.x, y - p.y, button)
  END ;
RETURN p # NIL END PassMouseDown;

PROCEDURE PassMouseMove*(c: Control; x, y: INTEGER; buttons: SET): BOOLEAN;
VAR p: Control;
BEGIN p := FindChildAt(c, x, y);
  IF (p # NIL) & (p.do.mouseMove # NIL) THEN
    p.do.mouseMove(p, x - p.x, y - p.y, buttons)
  END ;
RETURN p # NIL END PassMouseMove;

PROCEDURE SetEnabled*(c: Control; enabled: BOOLEAN);
BEGIN c.enabled := enabled
END SetEnabled;

(* Control *)

PROCEDURE InitControl*(c: Control);
BEGIN
  c.x := 0; c.y := 0; c.w := 0; c.h := 0;
  c.parent := NIL; c.children := NIL; c.prev := NIL; c.next := NIL;
  c.enabled := TRUE; c.default := FALSE; c.focused := FALSE;
  c.mouseActive := TRUE; c.status := 0; c.caption[0] := 0X;
  c.do := controlMethod
END InitControl;

PROCEDURE NewControl*(): Control;
VAR c: Control;
BEGIN NEW(c); InitControl(c); RETURN c
END NewControl;

PROCEDURE Add*(c, child: Control);
BEGIN
  child.parent := c;
  IF c.children = NIL THEN
    c.children := child;
    child.prev := child; child.next := child
  ELSE
    c.children.prev.next := child;
    child.prev := c.children.prev;
    c.children.prev := child;
    child.next := c.children
  END;
  IF c.do.added # NIL THEN c.do.added(c, child) END
END Add;

PROCEDURE Remove*(c: Control);
BEGIN
  IF c.parent # NIL THEN
    IF c.next = c THEN c.parent.children := NIL
    ELSE c.prev.next := c.next;
      c.next.prev := c.prev
    END
  END
END Remove;

PROCEDURE DrawChildren*(c: Control; x, y: INTEGER);
VAR p, br: Control;
BEGIN
  IF c.children # NIL THEN
    INC(x, c.x); INC(y, c.y);
    p := c.children.prev; br := p;
    REPEAT p.do.draw(p, x, y); p := p.prev UNTIL p = br
  END
END DrawChildren;

PROCEDURE SetDragged*(app: App; c: Control);
VAR x, y: INTEGER;
BEGIN
  SetFocus(c);
  app.dragged := c; x := 0; y := 0;
  WHILE c # NIL DO
    INC(x, c.x); INC(y, c.y);
    c := c.parent
  END;
  app.dragX := x; app.dragY := y
END SetDragged;

(* ControlMethod *)

PROCEDURE ControlResize*(c: Control; x, y, w, h: INTEGER);
BEGIN c.x := x; c.y := y; c.w := w; c.h := h
END ControlResize;

PROCEDURE ControlGetFocus*(c: Control);
BEGIN c.focused := TRUE
END ControlGetFocus;

PROCEDURE ControlLostFocus*(c: Control);
BEGIN c.focused := FALSE; G.StopTextInput;
  T.ShowCursor(FALSE); NeedRedraw(c.app)
END ControlLostFocus;

PROCEDURE InitControlMethod*(m: ControlMethod);
BEGIN
  m.added := NIL;
  m.draw := NIL;
  m.resize := ControlResize;
  m.refresh := NIL;
  m.click := NIL;
  m.keyDown := NIL;
  m.getFocus := ControlGetFocus;
  m.lostFocus := ControlLostFocus;
  m.mouseMove := NIL;
  m.mouseDown := NIL;
  m.mouseUp := NIL
END InitControlMethod;

(* Menu *)

PROCEDURE InitMenu*(m: Menu; caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler);
BEGIN InitControl(m);
  m.caption := caption$;
  m.innerW := 0; m.innerH := 0;
  m.hint := hint$; m.hintW := 0;
  m.hotkey := hotkey;
  m.lastSelected := NIL;
  m.onClick := onClick;
  m.do := menuMethod
END InitMenu;

PROCEDURE NewMenu*(caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler): Menu;
VAR m: Menu;
BEGIN NEW(m); InitMenu(m, caption, hint, hotkey, onClick); RETURN m
END NewMenu;

PROCEDURE DrawMenuCaption(m: Control; x, y: INTEGER);
VAR i, w, bg, fg: INTEGER;
  hl: BOOLEAN; (* Highlighted letter *)
BEGIN
  INC(x, m.x); INC(y, m.y); w := m.w - 2;
  IF m.caption = '-' THEN
    T.CharFill(x, y, m.w, 1, 0C4X, 0, 7); (* - *)
    T.PutChar(x - 1, y, 0C3X, 0, 7);
    T.PutChar(x + w + 2, y, 0B4X, 0, 7)
  ELSE
    IF (m.status = selected) OR (m.status = open) THEN bg := 2 
    ELSE bg := 7
    END;
    T.PutChar(x, y, ' ', 0, bg); INC(x);
    i := 0; hl := FALSE;
    WHILE m.caption[i] # 0X DO
      IF (m.caption[i] = '&') & ~hl THEN hl := TRUE
      ELSE
        IF m.status = disabled THEN fg := 8
        ELSIF hl & (m.caption[i] # '&') THEN fg := 4
        ELSE fg := 0
        END;
        T.PutChar(x, y, m.caption[i], fg, bg);
        DEC(w); INC(x); hl := FALSE
      END;
      INC(i)
    END;
    T.PutChar(x, y, ' ', 0, bg); INC(x);
    WHILE w > 0 DO
      T.PutChar(x, y, ' ', 0, bg);
      DEC(w); INC(x)
    END;
    IF m.status = disabled THEN fg := 8 ELSE fg := 0 END;
    IF m(Menu).hint[0] # 0X THEN
      T.PutString(x - m(Menu).hintW - 1, y, m(Menu).hint, fg, bg, 0)
    ELSIF (m.children # NIL) & (m.y # 0) THEN
      T.PutChar(x - 2, y, 10X, fg, bg)
    END
  END
END DrawMenuCaption;

PROCEDURE DrawSubmenuFrame(x, y, w, h: INTEGER);
VAR i: INTEGER;
BEGIN
  T.CharFill(x, y, 1, h, ' ', 0, 7);
  T.CharFill(x + 1, y + 1, 1, h - 2, 0B3X, 0, 7); (* | *)
  T.CharFill(x + w - 2, y + 1, 1, h - 2, 0B3X, 0, 7);
  T.CharFill(x + w - 1, y, 1, h, ' ', 0, 7);
  T.CharFill(x + 2, y, w - 4, h, ' ', 0, 7);
  T.CharFill(x + 2, y, w - 4, 1, 0C4X, 0, 7); (* - *)
  T.CharFill(x + 2, y + h - 1, w - 4, 1, 0C4X, 0, 7);
  T.PutChar(x + 1, y, 0DAX, 0, 7); (* Corners *)
  T.PutChar(x + w - 2, y, 0BFX, 0, 7); (* Corners *)
  T.PutChar(x + w - 2, y + h - 1, 0D9X, 0, 7); (* Corners *)
  T.PutChar(x + 1, y + h - 1, 0C0X, 0, 7); (* Corners *)
  FOR i := y + 1 TO y + h DO
    T.SetCharColor(x + w, i, 8, 0);
    T.SetCharColor(x + w + 1, i, 8, 0)
  END;
  FOR i := x + 2 TO x + w - 1 DO T.SetCharColor(i, y + h, 8, 0) END;
END DrawSubmenuFrame;

PROCEDURE MenuDraw(c: Control; x, y: INTEGER);
VAR p, openMenu: Control;
  w, h: INTEGER;
BEGIN DrawMenuCaption(c, x, y);
  IF c.status = open THEN
    INC(x, c.x); INC(y, c.y);
    IF c.parent # c.app.menu THEN INC(x) END; (* 2nd+-level menus *)
    IF c.children # NIL THEN
      w := c(Menu).innerW; h := c(Menu).innerH;
      IF x + w + 3 > T.charsX THEN x := T.charsX - w - 3 END;
      DrawSubmenuFrame(x - 1, y + 1, w + 4, h + 2);
      p := c.children; openMenu := NIL;
      REPEAT (* Don't draw the submenu until all items are drawn *)
        IF p.status = open THEN openMenu := p; p.status := selected END;
        p.do.draw(p, x, y); p := p.next
      UNTIL p = c.children;
      IF openMenu # NIL THEN
        openMenu.status := open; openMenu.do.draw(openMenu, x, y)
      END
    END
  END
END MenuDraw;

PROCEDURE MenuRefresh(m: Control);
VAR i, w: INTEGER; esc: BOOLEAN;
BEGIN w := 2; i := 0; esc := FALSE;
  WHILE m.caption[i] # 0X DO
    IF (m.caption[i] = '&') & ~esc THEN esc := TRUE
    ELSE INC(w); esc := FALSE
    END;
    INC(i)
  END;
  i := Strings.Length(m(Menu).hint);
  IF i # 0 THEN INC(w, i + 4); m(Menu).hintW := i END;
  m.w := w; m.h := 1
END MenuRefresh;

(* Returns the first child with status = selected,
   or just the first non-disabled child, or NIL. *)
PROCEDURE FindSelectedChild(c: Control): Control;
VAR p: Control;
BEGIN p := c.children;
  WHILE (p # NIL) & (p.status # selected) & (p # c(Menu).lastSelected) DO
    IF p.next = c.children THEN p := NIL ELSE p := p.next END
  END;
  IF (p = NIL) OR (p.status = disabled) THEN
    p := c.children;
    WHILE (p # NIL) & ((p.status = disabled) OR (p.caption = '-')) DO
      IF p.next = c.children THEN p := NIL ELSE p := p.next END
    END
  END;
  IF p # NIL THEN p.status := selected END;
  RETURN p
END FindSelectedChild;

PROCEDURE MenuHotkey*(c: Control; ch: CHAR): BOOLEAN;
VAR i: INTEGER; x: CHAR;
BEGIN i := 0; x := c.caption[0];
  WHILE (x # 0X) &
        ~((x = '&') & (c.caption[i + 1] # '&')) DO
    IF (x = '&') & (c.caption[i + 1] = '&') THEN INC(i, 2) ELSE INC(i) END;
    x := c.caption[i]
  END;
  RETURN (c.caption[i] # 0X) & (CAP(c.caption[i + 1]) = CAP(ch))
END MenuHotkey;

PROCEDURE MenuKeyDown*(c: Control; key: G.Key);
VAR p, p2, br: Control; found: BOOLEAN;
BEGIN
  CASE key.code OF
    G.kUp, G.kDown:
    IF c.parent # c.app.menu THEN
      p := c;
      REPEAT
        IF key.code = G.kUp THEN p := p.prev ELSE p := p.next END
      UNTIL (p = c) OR (p.caption # '-') & (p.status # disabled);
      c.status := normal; p.status := selected; SetFocus(p);
      NeedRedraw(c.app)
    END
  | G.kLeft, G.kRight: p := c;
    WHILE p.parent # p.app.menu DO p := p.parent END;
    IF key.code = G.kLeft THEN p := p.prev ELSE p := p.next END;
    p.status := open;
    p2 := FindSelectedChild(p);
    IF p2 = NIL THEN p2 := p END;
    SetFocus(p2);
    NeedRedraw(c.app)
  | G.kEnter: c.do.click(c)
  | G.kEsc:
    IF c.parent.parent = c.app.menu THEN
      c.parent.status := normal; UnsetFocus(c.app)
    ELSE
      c.parent.status := selected; SetFocus(c.parent)
    END;
    NeedRedraw(c.app)
  ELSE p := c;
    WHILE (p # NIL) & ~MenuHotkey(p, CHR(key.sym)) DO
      IF p.next = c THEN p := NIL ELSE p := p.next END
    END;
    IF p # NIL THEN
      c.status := normal; p.status := selected;
      c.parent(Menu).lastSelected := p; p.do.click(p)
    END
  END
END MenuKeyDown;

PROCEDURE MenuGetFocus*(c: Control);
BEGIN ControlGetFocus(c);
  IF c.status = normal THEN c.status := selected; NeedRedraw(c.app) END;
  IF c.parent # NIL THEN c.parent(Menu).lastSelected := c END;
  T.ShowCursor(FALSE)
END MenuGetFocus;

PROCEDURE MenuLostFocus*(c: Control);
BEGIN ControlLostFocus(c); c.status := normal; NeedRedraw(c.app)
END MenuLostFocus;

PROCEDURE MenuClick*(c: Control);
VAR p: Control;
BEGIN
  IF c.children = NIL THEN
    IF c.status # disabled THEN
      UnsetFocus(c.app);
      IF c.onClick # NIL THEN c.onClick(c) END
    END
  ELSE c.status := open;
    p := FindSelectedChild(c);
    IF p = NIL THEN p := c END;
    SetFocus(p)
  END;
  NeedRedraw(c.app)
END MenuClick;

PROCEDURE GetMenuAt(app: App; x, y: INTEGER): Control;
VAR menu, p, br: Control;
  count: INTEGER;
BEGIN p := NIL;
  IF app.menu.children # NIL THEN
    IF y = 0 THEN p := app.menu.children; br := p;
      WHILE (p # NIL) & (x >= p.x + p.w) DO
        IF p.next = br THEN p := NIL ELSE p := p.next END
      END;
      IF p # NIL THEN DEC(x, p.x) END
    ELSE menu := app.menu;
      REPEAT (* menu := the deepest open menu *)
        p := menu.children; br := p; count := 2;
        WHILE (p # NIL) & (p.status # open) DO
          IF menu = app.menu THEN DEC(x, p.w) ELSE INC(count) END;
          IF p.next = br THEN p := NIL ELSE p := p.next END
        END;
        IF p # NIL THEN
          IF menu # app.menu THEN DEC(y, count); menu.h := count END;
          menu := p
        END
      UNTIL p = NIL;
      IF menu # app.menu THEN
        REPEAT p := menu.children; br := p;
          WHILE (p # NIL) & ~((x >= p.x) & (x < p.x + p.w) & (y = p.y)) DO
            (*Out.String('x=');Out.Int(x,2); Out.String(' y=');Out.Int(x,2);
            Out.String(' p.x=');Out.Int(p.x,2); Out.String(' p.w=');Out.Int(p.w,2);
            Out.String(' p.y=');Out.Int(p.y,2); Out.String(' p.h=');Out.Int(p.h,2); Out.Ln;*)
            IF p.next = br THEN p := NIL ELSE p := p.next END
          END;
          (*IF p # NIL THEN 
            Out.String('x=');Out.Int(x,2); Out.String(' y=');Out.Int(x,2);
            Out.String(' p.x=');Out.Int(p.x,2); Out.String(' p.w=');Out.Int(p.w,2);
            Out.String(' p.y=');Out.Int(p.y,2); Out.String(' p.h=');Out.Int(p.h,2); Out.String(' - FOUND');Out.Ln;
          END;*)
          IF p = NIL THEN menu := menu.parent; INC(y, menu.h) END
        UNTIL (menu = app.menu) OR (p # NIL);
        IF p # NIL THEN DEC(x, p.x); DEC(y, p.y) END
      END
    END
  END;
  RETURN p
END GetMenuAt;

PROCEDURE GetStatusbarAt(app: App; x, y: INTEGER): Control;
VAR p, br: Control;
BEGIN
  IF y = T.charsY - 1 THEN
    p := app.statusbar.children; br := p;
    WHILE (p # NIL) & ~((p.x <= x) & (x < p.x + p.w)) DO
      IF p.next = br THEN p := NIL ELSE p := p.next END
    END
  ELSE p := NIL
  END;
  RETURN p
END GetStatusbarAt;

PROCEDURE MenuMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
VAR p: Control;
BEGIN p := c;
  IF c = c.app.menu THEN c := GetMenuAt(c.app, x, y)
  ELSIF c = c.app.statusbar THEN c := GetStatusbarAt(c.app, x, y)
  END;
  IF (c = NIL) & (p = p.app.statusbar) THEN UnsetFocus(c.app);
  ELSIF (c # NIL) & (buttons = {G.btnLeft}) & (c.status = normal) THEN
    IF c.parent.parent = NIL THEN (* Top level menu *)
      IF c.do.mouseDown # NIL THEN c.do.mouseDown(c, x, y, G.btnLeft) END
    ELSE
      IF (c.app.cur # NIL) & (c.app.cur.status # selected) THEN
        c.app.cur.status := selected;
        NeedRedraw(c.app)
      END;
      SetFocus(c)
    END
  END
END MenuMouseMove;

PROCEDURE MenuMouseDown*(c: Control; x, y, button: INTEGER);
VAR p: Control;
BEGIN
  IF (button = G.btnLeft) & (c.status # disabled) THEN
    SetFocus(c);
    p := c; WHILE p.parent # NIL DO p := p.parent END;
    c.app.dragged := p; c.app.dragX := p.x; c.app.dragY := p.y;
    IF c.children = NIL THEN SetFocus(c)
    ELSE c.status := open; p := FindSelectedChild(c);
      IF p = NIL THEN p := c END;
      SetFocus(p); p.status := normal
    END;
    IF c.parent # c.app.menu THEN
      IF c.app.cur # NIL THEN c.app.cur.status := normal END;
      c.status := selected; SetFocus(c)
    END;
    NeedRedraw(c.app)
  END
END MenuMouseDown;

PROCEDURE MenuMouseUp*(c: Control; x, y, button: INTEGER);
VAR p: Control;
BEGIN
  IF button = G.btnLeft THEN
    IF c = c.app.menu THEN p := GetMenuAt(c.app, x, y)
    ELSIF c = c.app.statusbar THEN p := GetStatusbarAt(c.app, x, y)
    ELSE p := c
    END;
    IF p = NIL THEN UnsetFocus(c.app) ELSE p.do.click(p) END
  END
END MenuMouseUp;

PROCEDURE RefreshMenu*(c: Control);
VAR br, p: Control;
  x, y, w: INTEGER;
BEGIN
  IF c.children # NIL THEN
    w := 0; p := c.children;
    REPEAT p.do.refresh(p);
      IF p.w > w THEN w := p.w END;
      p := p.next
    UNTIL p = c.children;
    y := 2;
    REPEAT p.w := w; p.x := 1; p.y := y; INC(y);
      RefreshMenu(p); p := p.next
    UNTIL p = c.children
  END
END RefreshMenu;

PROCEDURE MenuAdded*(c, child: Control);
BEGIN RefreshMenu(c); INC(c(Menu).innerH);
  IF child.w > c(Menu).innerW THEN c(Menu).innerW := child.w END
END MenuAdded;

(* MenuMethod *)

PROCEDURE InitMenuMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.added := MenuAdded;
  m.draw := MenuDraw;
  m.refresh := MenuRefresh;
  m.click := MenuClick;
  m.keyDown := MenuKeyDown;
  m.getFocus := MenuGetFocus;
  m.lostFocus := MenuLostFocus;
  m.mouseMove := MenuMouseMove;
  m.mouseDown := MenuMouseDown;
  m.mouseUp := MenuMouseUp
END InitMenuMethod;

(* QuickBtn *)

PROCEDURE InitQuickBtn*(c: QuickBtn; caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler);
BEGIN InitMenu(c, caption, hint, hotkey, onClick); c.do := quickBtnMethod
END InitQuickBtn;

PROCEDURE NewQuickBtn*(caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler): QuickBtn;
VAR c: QuickBtn;
BEGIN NEW(c); InitQuickBtn(c, caption, hint, hotkey, onClick); RETURN c
END NewQuickBtn;

PROCEDURE QuickBtnDraw(c: Control; x, y: INTEGER);
VAR i, w, bg, fg: INTEGER;
  hl: BOOLEAN; (* Highlighted letter *)
BEGIN INC(x, c.x); INC(y, c.y);
  IF c.status = normal THEN bg := 7 ELSE bg := 2 END;
  T.PutChar(x, y, ' ', 0, bg); INC(x); i := 0;
  WHILE c(Menu).hint[i] # 0X DO
    T.PutChar(x, y, c(Menu).hint[i], 4, bg);
    INC(x); INC(i)
  END;
  T.PutChar(x, y, ' ', 0, bg); INC(x); i := 0;
  WHILE c.caption[i] # 0X DO
    T.PutChar(x, y, c.caption[i], 0, bg);
    INC(x); INC(i)
  END;
  T.PutChar(x, y, ' ', 0, bg)
END QuickBtnDraw;

PROCEDURE QuickBtnRefresh(m: Control);
VAR i, w: INTEGER; esc: BOOLEAN;
BEGIN
  m.w := Strings.Length(m.caption) + 2;
  i := Strings.Length(m(Menu).hint);
  IF i # 0 THEN INC(m.w, i + 1) END
END QuickBtnRefresh;

(* QuickBtnMethod *)

PROCEDURE InitQuickBtnMethod*(m: ControlMethod);
BEGIN InitMenuMethod(m);
  m.draw := QuickBtnDraw;
  m.refresh := QuickBtnRefresh
END InitQuickBtnMethod;

(* Button *)

PROCEDURE InitButton*(c: Button; caption: ARRAY OF CHAR);
BEGIN InitControl(c);
  c.w := 10; c.h := 1;
  c.caption := caption$;
  c.do := buttonMethod
END InitButton;

PROCEDURE NewButton*(caption: ARRAY OF CHAR): Button;
VAR c: Button;
BEGIN NEW(c); InitButton(c, caption); RETURN c
END NewButton;

(* Button Method *)

PROCEDURE ButtonDraw*(c: Control; x, y: INTEGER);
VAR i, fg, bg: INTEGER;
BEGIN INC(x, c.x); INC(y, c.y);
  IF c.status = selected THEN INC(x) END;
  IF (c.parent # NIL) & (c.parent IS Window) THEN bg := c.parent(Window).bg
  ELSE bg := 7
  END;
  T.CharFill(x, y, c.w, c.h, ' ', 0, 2);
  i := 0; WHILE c.caption[i] # 0X DO INC(i) END;
  IF i > c.w THEN i := c.w END;
  IF c.default THEN fg := 11 ELSE fg := 0 END;
  PutMarkedString(x + (c.w - i) DIV 2, y + c.h DIV 2,
    c.caption, fg, 14, 2, x + c.w - 1);
  IF c.status # selected THEN
    T.PutChar(x + c.w, y, 0DCX, 0, bg);
    T.CharFill(x + c.w, y + 1, 1, c.h - 1, 0DBX, 0, bg);
    T.CharFill(x + 1, y + c.h, c.w, 1, 0DFX, 0, bg)
  END
END ButtonDraw;

PROCEDURE ButtonMouseDown*(c: Control; x, y, button: INTEGER);
BEGIN
  IF (c.parent # NIL) & (c.parent IS Window) THEN
    c.status := selected;
    SetDragged(c.app, c);
    NeedRedraw(c.app)
  END
END ButtonMouseDown;

PROCEDURE ButtonMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
  IF (c.status = selected) & (c.do.click # NIL) THEN c.do.click(c) END;
  c.status := normal;
  NeedRedraw(c.app)
END ButtonMouseUp;

PROCEDURE ButtonMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
VAR status: INTEGER;
BEGIN
  IF (0 <= x) & (x <= c.w) & (0 <= y) & (y < c.h) THEN status := selected
  ELSE status := normal
  END;
  IF c.status # status THEN c.status := status; NeedRedraw(c.app) END
END ButtonMouseMove;

PROCEDURE ButtonClick*(c: Control);
BEGIN
  IF c.onClick # NIL THEN c.onClick(c) END
END ButtonClick;

PROCEDURE InitButtonMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.draw := ButtonDraw;
  m.mouseDown := ButtonMouseDown;
  m.mouseUp := ButtonMouseUp;
  m.mouseMove := ButtonMouseMove;
  m.click := ButtonClick
END InitButtonMethod;

(* WinBtn *)

PROCEDURE InitWinBtn*(c: WinBtn; ch: CHAR);
BEGIN InitButton(c, ''); c.w := 3; c.h := 1;
  c.caption[0] := ch; c.caption[1] := 0X;
  c.do := winBtnMethod
END InitWinBtn;

PROCEDURE NewWinBtn*(ch: CHAR): WinBtn;
VAR c: WinBtn;
BEGIN NEW(c); InitWinBtn(c, ch); RETURN c
END NewWinBtn;

(* WinBtn Method *)

PROCEDURE WinBtnMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
  IF c.status = selected THEN
    T.PutChar(c.app.dragX + 1, c.app.dragY,
      c.caption[0], 10, c.parent(Window).bg);
    IF c.do.click # NIL THEN c.do.click(c) END
  END
END WinBtnMouseUp;

PROCEDURE WinBtnMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
VAR status: INTEGER; ch: CHAR;
BEGIN status := c.status;
  ButtonMouseMove(c, x, y, buttons);
  IF status # c.status THEN
    IF c.status = normal THEN ch := c.caption[0] ELSE ch := 0FX(*star*) END;
    T.PutChar(c.app.dragX + 1, c.app.dragY, ch, 10, c.parent(Window).bg)
  END
END WinBtnMouseMove;

PROCEDURE InitWinBtnMethod*(m: ControlMethod);
BEGIN InitButtonMethod(m);
  m.draw := NIL;
  m.mouseUp := WinBtnMouseUp;
  m.mouseMove := WinBtnMouseMove
END InitWinBtnMethod;

(* Scrollbar *)

PROCEDURE InitScrollbar*(c: Scrollbar);
BEGIN InitControl(c); c.max := 100; c.runnerOffset := 1; c.runnerW := 5;
  c.step := 1; c.w := 30; c.h := 1; c.cur := 0; c.onScrollbar := NIL;
  c.do := scrollbarMethod
END InitScrollbar;

PROCEDURE NewScrollbar*(): Scrollbar;
VAR c: Scrollbar;
BEGIN NEW(c); InitScrollbar(c); RETURN c
END NewScrollbar;

PROCEDURE ScrollbarUpdateCur*(S: Scrollbar; x, y: INTEGER; end: BOOLEAN);
VAR w, oldOff: INTEGER;
BEGIN oldOff := S.runnerOffset; w := S.w - S.runnerW - 2;
  (* Horizontal scrollbar *)
  DEC(x, S.runnerW DIV 2 + 1);
  IF x < 0 THEN x := 0 ELSIF x > w THEN x := w END;
  S.cur := (x * S.max + w DIV 2) DIV w;
  IF end THEN S.runnerOffset := S.cur * w DIV S.max + 1
  ELSE S.runnerOffset := x + 1
  END;
  IF S.runnerOffset # oldOff THEN
    NeedRedraw(S.app);
    IF S.onScrollbar # NIL THEN S.onScrollbar(S) END
  END
END ScrollbarUpdateCur;

PROCEDURE SetScrollbarCur*(S: Scrollbar; cur: INTEGER);
BEGIN
  IF cur < 0 THEN cur := 0 ELSIF cur > S.max THEN cur := S.max END;
  IF S.cur # cur THEN
    S.cur := cur;
    S.runnerOffset := cur * (S.w - S.runnerW - 2) DIV S.max + 1
  END
END SetScrollbarCur;

(* Scrollbar Method *)

PROCEDURE ScrollbarDraw*(c: Control; x, y: INTEGER);
VAR S: Scrollbar;
  w, fg, bg: INTEGER;
  ch: CHAR;
BEGIN S := c(Scrollbar); INC(x, S.x); INC(y, S.y); fg := 3; bg := 1;
  IF S.enabled THEN ch := 0B0X ELSE ch := 0B1X END;
  T.CharFill(x + 1, y, S.w - 1, 1, ch, fg, bg);
  T.PutChar(x, y, 11X, fg, bg);
  T.PutChar(x + S.w - 1, y, 10X, fg, bg);
  IF S.enabled THEN
    T.CharFill(x + S.runnerOffset, y, S.runnerW, 1, 0B1X, fg, bg)
  END
END ScrollbarDraw;

PROCEDURE ScrollbarMouseDown*(c: Control; x, y, button: INTEGER);
VAR S: Scrollbar;
  col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF S.enabled & (button = G.btnLeft) THEN
    SetDragged(S.app, S);
    ScrollbarUpdateCur(S, x, y, FALSE)
  END
END ScrollbarMouseDown;

PROCEDURE ScrollbarMouseUp*(c: Control; x, y, button: INTEGER);
VAR S: Scrollbar;
  col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF S.enabled & (button = G.btnLeft) THEN
    ScrollbarUpdateCur(S, x, y, TRUE)
  END
END ScrollbarMouseUp;

PROCEDURE ScrollbarMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
VAR S: Scrollbar;
  oldCur, col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF buttons = {G.btnLeft} THEN ScrollbarUpdateCur(S, x, y, FALSE) END
END ScrollbarMouseMove;

PROCEDURE InitScrollbarMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.draw := ScrollbarDraw;
  m.mouseDown := ScrollbarMouseDown;
  m.mouseUp := ScrollbarMouseUp;
  m.mouseMove := ScrollbarMouseMove
END InitScrollbarMethod;

(* Edit *)

PROCEDURE InitEdit*(c: Edit);
BEGIN InitControl(c);
  c.w := 10; c.h := 1; c.len := 0; c.pos := 0;
  c.do := editMethod
END InitEdit;

PROCEDURE NewEdit*(): Edit;
VAR c: Edit;
BEGIN NEW(c); InitEdit(c); RETURN c
END NewEdit;

(* Edit Method *)

PROCEDURE EditSetCaption*(c: Edit; s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (s[i] # 0X) & (i < LEN(c.caption) - 1) DO
    c.caption[i] := s[i]; INC(i)
  END;
  c.caption[i] := 0X; c.len := i; c.pos := i
END EditSetCaption;

PROCEDURE InsertChar(ch: CHAR; pos: INTEGER;
  VAR s: ARRAY OF CHAR; VAR len: INTEGER);
VAR i: INTEGER;
BEGIN
  IF len + 1 < LEN(s) THEN
    FOR i := len TO pos + 1 BY -1 DO s[i] := s[i - 1] END;
    s[pos] := ch; INC(len); s[len] := 0X
  END
END InsertChar;

PROCEDURE DeleteChar(VAR s: ARRAY OF CHAR;
  pos: INTEGER; VAR len: INTEGER);
VAR i: INTEGER;
BEGIN
  FOR i := pos TO len - 1 DO s[i] := s[i + 1] END;
  DEC(len); s[len] := 0X
END DeleteChar;

PROCEDURE EditDraw*(c: Control; x, y: INTEGER);
VAR i, j: INTEGER; e: Edit;
BEGIN e := c(Edit); INC(x, e.x); INC(y, e.y);
  T.PutChar(x, y, ' ', 0, 1);
  i := 0; j := x + 1;
  WHILE (e.caption[i] # 0X) & (i < e.w - 1) DO
    T.PutChar(j, y, e.caption[i], 15, 1); INC(i); INC(j)
  END;
  WHILE i < e.w - 1 DO
    T.PutChar(j, y, ' ', 15, 1); INC(i); INC(j)
  END;

  i := e.pos + 1; IF i >= e.w THEN i := e.w - 1 END;
  IF c.app.cur = c THEN T.GoToXY(x + i, y) END
END EditDraw;

PROCEDURE EditMouseDown*(c: Control; x, y, edit: INTEGER);
BEGIN (*!TODO*)
END EditMouseDown;

PROCEDURE EditKeyDown*(c: Control; key: G.Key);
VAR e: Edit; redraw: BOOLEAN;
BEGIN e := c(Edit); redraw := TRUE;
  CASE key.code OF
    G.kLeft: IF e.pos > 0 THEN DEC(e.pos) END
  | G.kRight: IF e.pos < e.len THEN INC(e.pos) END
  | G.kBackspace:
    IF e.pos > 0 THEN DeleteChar(e.caption, e.pos - 1, e.len); DEC(e.pos) END
  | G.kDel: IF e.pos < e.len THEN DeleteChar(e.caption, e.pos, e.len) END
  | G.kHome: e.pos := 0
  | G.kEnd: e.pos := e.len
  ELSE redraw := FALSE
  END;
  IF redraw THEN NeedRedraw(c.app); T.ResetCursorBlink END
END EditKeyDown;

PROCEDURE EditTextInput*(c: Control; ch: INTEGER);
VAR e: Edit;
BEGIN
  IF ch # 0 THEN e := c(Edit);
    InsertChar(ToCP866(ch), e.pos, e.caption, e.len);
    IF e.pos < e.len THEN INC(e.pos) END;
    NeedRedraw(c.app); T.ResetCursorBlink
  END
END EditTextInput;

PROCEDURE EditGetFocus*(c: Control);
BEGIN ControlGetFocus(c); T.ShowCursor(TRUE); G.StartTextInput
END EditGetFocus;

PROCEDURE InitEditMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.draw := EditDraw;
  m.getFocus := EditGetFocus;
  m.mouseDown := EditMouseDown;
  m.keyDown := EditKeyDown;
  m.textInput := EditTextInput
END InitEditMethod;

(* ColumnList *)

PROCEDURE InitColumnList*(c: ColumnList);
BEGIN InitControl(c); c.cols := 2; c.items := StrList.New();
  c.w := 30; c.h := 6; c.cur := 0;
  c.scrollbar := NewScrollbar();
  Add(c, c.scrollbar);
  c.do.resize(c, 0, c.h - 1, c.w, 1);
  c.do := columnListMethod
END InitColumnList;

PROCEDURE NewColumnList*(): ColumnList;
VAR c: ColumnList;
BEGIN NEW(c); InitColumnList(c); RETURN c
END NewColumnList;

(* ColumnList Method *)

PROCEDURE ColumnListDraw*(c: Control; x, y: INTEGER);
VAR i, x2, y2, colw, fg, bg: INTEGER;
  C: ColumnList;
  s: ARRAY 256 OF CHAR;
BEGIN C := c(ColumnList); INC(x, C.x); INC(y, C.y);
  bg := 3; x2 := x + 1; y2 := y;
  colw := (C.w - C.cols + 1) DIV C.cols;
  T.CharFill(x, y, C.w, C.h - 1, ' ', 0, bg);

  (* Column separators *)
  i := x + colw;
  WHILE i < x + C.w - 2 DO
    T.CharFill(i, y, 1, C.h - 1, 0B3X, 1, bg); INC(i, colw + 1)
  END;

  i := C.scrollbar.cur * (C.h - 1);
  StrList.SetPos(C.items, i);
  StrList.Next(C.items, s);
  WHILE ~C.items.eol & (x2 + colw <= x + C.w) DO fg := 0; bg := 3;
    IF i = C.cur THEN
      IF C.focused THEN fg := 15; bg := 2;
        T.CharFill(x2 - 1, y2, colw, 1, ' ', fg, bg)
      ELSE fg := 14
      END
    END;
    T.PutString(x2, y2, s, fg, bg, x2 + colw - 1);
    IF y2 < y + C.h - 2 THEN INC(y2) ELSE y2 := y; INC(x2, colw + 1) END;
    StrList.Next(C.items, s); INC(i)
  END;

  DrawChildren(c, x - C.x, y - C.y)
END ColumnListDraw;

PROCEDURE ColumnListGetFocus*(c: Control);
BEGIN ControlGetFocus(c); G.StartTextInput
END ColumnListGetFocus;

PROCEDURE ColumnListUpdateCur*(C: ColumnList; x, y: INTEGER);
VAR h, oldCur, col, colw, count: INTEGER;
BEGIN h := C.h - 1;
  IF (x < 0) OR (x >= C.w) THEN
    (*!TODO autoscroll*)
    (*IF ... THEN NeedRedraw(C.app) END*)
  ELSIF y # h THEN oldCur := C.cur;
    IF y < 0 THEN (* Scroll to top within column *)
      C.cur := (C.cur DIV h) * h
    ELSIF y >= C.h THEN (* Scroll to bottom within column *)
      C.cur := C.cur DIV h * h + h - 1
    ELSE
      colw := (C.w - C.cols + 1) DIV C.cols;
      col := x DIV (colw + 1);
      C.cur := col * h + y + C.scrollbar.cur * h
    END;
    count := StrList.Count(C.items);
    IF C.cur >= count THEN C.cur := count - 1 END;
    IF C.cur # oldCur THEN NeedRedraw(C.app) END
  END
END ColumnListUpdateCur;

PROCEDURE ColumnListMouseDown*(c: Control; x, y, button: INTEGER);
VAR C: ColumnList;
  col, colw: INTEGER;
BEGIN C := c(ColumnList);
  IF ~PassMouseDown(C, x, y, button) &
      (C.parent # NIL) & (C.parent IS Window) THEN
    C.status := selected;
    SetDragged(C.app, C);
    ColumnListUpdateCur(C, x, y);
    NeedRedraw(C.app)
  END
END ColumnListMouseDown;

PROCEDURE ColumnListMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
  IF (c.status = selected) & (c.do.click # NIL) THEN c.do.click(c) END
END ColumnListMouseUp;

PROCEDURE ColumnListMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
VAR C: ColumnList;
  oldCur, col, colw: INTEGER;
BEGIN C := c(ColumnList);
  IF buttons = {G.btnLeft} THEN ColumnListUpdateCur(C, x, y) END
END ColumnListMouseMove;

PROCEDURE ColumnListSetCur*(C: ColumnList; cur: INTEGER);
VAR sb: Scrollbar;
  h, count, oldCur, sbCur, oldSbCur: INTEGER;
BEGIN sb := C.scrollbar;
  sbCur := sb.cur; oldSbCur := sbCur;
  h := C.h - 1; count := StrList.Count(C.items);
  IF cur < 0 THEN cur := 0 ELSIF cur >= count THEN cur := count - 1 END;
  IF cur < sbCur * h THEN sbCur := cur DIV h
  ELSIF cur >= (sbCur + C.cols - 1) * h THEN sbCur := cur DIV h - C.cols + 1
  END;
  IF sbCur < 0 THEN sbCur := 0 ELSIF sbCur > sb.max THEN sbCur := sb.max END;
  IF sbCur # oldSbCur THEN SetScrollbarCur(sb, sbCur) END;
  IF C.cur # cur THEN C.cur := cur; NeedRedraw(C.app) END
END ColumnListSetCur;

PROCEDURE ColumnListKeyDown*(c: Control; key: G.Key);
VAR C: ColumnList; sb: Scrollbar;
  h, cur: INTEGER;
BEGIN C := c(ColumnList); sb := C.scrollbar; cur := C.cur; h := C.h - 1;
  CASE key.code OF
    G.kLeft: DEC(cur, h)
  | G.kRight: INC(cur, h)
  | G.kUp: DEC(cur)
  | G.kDown: INC(cur)
  | G.kHome: cur := sb.cur * h
  | G.kEnd: cur := (sb.cur + C.cols) * h - 1
  | G.kPgUp: DEC(cur, C.cols * h); DEC(sb.cur, C.cols)
  | G.kPgDn: INC(cur, C.cols * h); INC(sb.cur, C.cols)
  ELSE END;
  ColumnListSetCur(C, cur)
END ColumnListKeyDown;

PROCEDURE ColumnListClick*(c: Control);
BEGIN
  IF c.onClick # NIL THEN c.onClick(c) END
END ColumnListClick;

PROCEDURE ColumnListRefresh*(c: Control);
VAR C: ColumnList;
  cols, w: INTEGER; (* Total amount of columns in the list *)
BEGIN C := c(ColumnList);
  cols := StrList.Count(C.items) DIV (C.h - 1) + 1;
  IF cols > C.cols THEN
    C.scrollbar.max := cols - C.cols;
    w := (C.w - 2) DIV (C.scrollbar.max + 1);
    IF w < 3 THEN w := 3 END;
    C.scrollbar.runnerW := w
  END;
  SetEnabled(C.scrollbar, cols > C.cols)
END ColumnListRefresh;

PROCEDURE ColumnListResize*(c: Control; x, y, w, h: INTEGER);
VAR C: ColumnList;
BEGIN C := c(ColumnList);
  ControlResize(c, x, y, w, h);
  C.scrollbar.do.resize(C.scrollbar, 0, C.h - 1, w, 1);
  C.do.refresh(C)
END ColumnListResize;

PROCEDURE FindFirstLetterInList(L: StrList.List; ch: CHAR): INTEGER;
VAR s: ARRAY 2 OF CHAR; n: INTEGER;
BEGIN StrList.First(L, s); n := 0;
  WHILE ~L.eol & (Cap(s[0]) # ch) DO StrList.Next(L, s); INC(n) END;
  IF L.eol THEN n := -1 END ;
RETURN n END FindFirstLetterInList;

PROCEDURE ColumnListTextInput*(c: Control; ch: INTEGER);
VAR C: ColumnList; n: INTEGER;
BEGIN C := c(ColumnList);
  IF ch # 0 THEN
    n := FindFirstLetterInList(C.items, Cap(ToCP866(ch)));
    IF n # -1 THEN ColumnListSetCur(C, n) END
  END
END ColumnListTextInput;

PROCEDURE InitColumnListMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.draw := ColumnListDraw;
  m.getFocus := ColumnListGetFocus;
  m.mouseDown := ColumnListMouseDown;
  m.mouseUp := ColumnListMouseUp;
  m.mouseMove := ColumnListMouseMove;
  m.keyDown := ColumnListKeyDown;
  m.textInput := ColumnListTextInput;
  m.click := ColumnListClick;
  m.refresh := ColumnListRefresh;
  m.resize := ColumnListResize
END InitColumnListMethod;

(* Standard Click Handlers *)

PROCEDURE QuitApp*(c: Control);
BEGIN c.app.quit := TRUE
END QuitApp;

PROCEDURE NextWindow*(c: Control);
BEGIN
  IF c.app.windows # NIL THEN
    c.app.windows := c.app.windows.next(Window);
    SetFocus(c.app.windows);
    NeedRedraw(c.app)
  END
END NextWindow;

PROCEDURE PrevWindow*(c: Control);
BEGIN
  IF c.app.windows # NIL THEN
    c.app.windows := c.app.windows.prev(Window);
    SetFocus(c.app.windows);
    NeedRedraw(c.app)
  END
END PrevWindow;

PROCEDURE ZoomCurWindow*(c: Control);
VAR w: Window;
BEGIN w := c.app.windows(Window);
  IF w # NIL THEN
    IF (w.x = 0) & (w.w = T.charsX) &
       (w.y = 1) & (w.h = T.charsY - 2) THEN
      w.x := w.mx; w.y := w.my; w.w := w.mw; w.h := w.mh
    ELSE
      w.mx := w.x; w.my := w.y; w.mw := w.w; w.mh := w.h;
      w.x := 0; w.w := T.charsX;
      w.y := 1; w.h := T.charsY - 2
    END;
    NeedRedraw(c.app)
  END
END ZoomCurWindow;

PROCEDURE CloseCurWindow*(c: Control);
BEGIN
  IF c.app.windows # NIL THEN
    IF c.app.windows.next = c.app.windows THEN c.app.windows := NIL
    ELSE
      c.app.windows.prev.next := c.app.windows.next;
      c.app.windows.next.prev := c.app.windows.prev;
      c.app.windows := c.app.windows.prev(Window)
    END;
    SetFocus(c.app.windows);
    NeedRedraw(c.app)
  END
END CloseCurWindow;

PROCEDURE CloseAllWindows*(c: Control);
BEGIN
  WHILE c.app.windows # NIL DO CloseCurWindow(c) END
END CloseAllWindows;

PROCEDURE RefreshDisplay*(c: Control);
BEGIN T.ClearScreen; NeedRedraw(c.app)
END RefreshDisplay;

(* Window *)

PROCEDURE InitWindow*(w: Window);
BEGIN InitControl(w);
  w.cur := NIL;
  w.x := 0; w.y := 1;
  w.w := T.charsX; w.h := T.charsY - 2;
  w.mx := 0; w.my := 1; w.mw := w.w; w.mh := w.h;
  w.modal := FALSE; w.resizable := FALSE; w.closeable := TRUE;
  w.bg := 7; w.minW := 10; w.minH := 3;
  w.closeBtn := NewWinBtn(0FEX); (* Square *)
  w.closeBtn.x := 2; w.closeBtn.w := 3;
  w.closeBtn.parent := w;
  w.closeBtn.onClick := CloseCurWindow;
  w.zoomBtn := NewWinBtn(12X); (* Up-down arrow *)
  w.zoomBtn.w := 3; w.zoomBtn.parent := w;
  w.zoomBtn.onClick := ZoomCurWindow;
  w.do := windowMethod
END InitWindow;

PROCEDURE NewWindow*(): Window;
VAR w: Window;
BEGIN NEW(w); InitWindow(w); RETURN w
END NewWindow;

PROCEDURE HasModalWindow*(app: App): BOOLEAN;
BEGIN
  RETURN (app.windows # NIL) & app.windows.modal
END HasModalWindow;

PROCEDURE CenterWindow*(c: Window);
BEGIN c.x := (T.charsX - c.w) DIV 2; c.y := (T.charsY - c.h - 1) DIV 2;
  IF c.x < 0 THEN c.x := 0 END;
  IF c.y < 1 THEN c.y := 1 END
END CenterWindow;

(* WindowMethod *)

PROCEDURE WindowAdded*(c, child: Control);
BEGIN
  IF c(Window).cur = NIL THEN c(Window).cur := child END
END WindowAdded;

PROCEDURE WindowDraw*(c: Control; x, y: INTEGER);
BEGIN
  T.CharFill(c.x + 1, c.y + 1,
    c.w - 2, c.h - 2, ' ', 15, c(Window).bg);
  DrawWindowBorder(c.x, c.y, c.w, c.h, 15,
    c(Window).bg, c.caption, c(Window).resizable,
    c.status # normal, c # c.app.windows);
  DrawChildren(c, x, y)
END WindowDraw;

PROCEDURE WindowRefresh*(c: Control);
BEGIN
  IF c(Window).zoomBtn # NIL THEN
    IF (c.x = 0) & (c.w = T.charsX) & (c.y = 1) & (c.h = T.charsY - 2) THEN
      c(Window).zoomBtn.caption[0] := 012X
    ELSE c(Window).zoomBtn.caption[0] := 018X
    END
  END
END WindowRefresh;

PROCEDURE WindowResize*(c: Control; x, y, w, h: INTEGER);
BEGIN ControlResize(c, x, y, w, h);
  IF c.do.refresh # NIL THEN c.do.refresh(c) END
END WindowResize;

PROCEDURE WindowCloseMouseDown(c: Control);
BEGIN c.app.dragged := c(Window).closeBtn;
  c(Window).closeBtn.status := selected;
  c.app.dragX := c.x + 2; c.app.dragY := c.y;
  T.PutChar(c.x + 3, c.y, 0FX, 10, c(Window).bg) (* star *)
END WindowCloseMouseDown;

PROCEDURE WindowZoomMouseDown(c: Control);
BEGIN c.app.dragged := c(Window).zoomBtn;
  c(Window).zoomBtn.status := selected;
  c(Window).zoomBtn.x := c.w - 5;
  c.app.dragX := c.x + c.w - 5; c.app.dragY := c.y;
  T.PutChar(c.x + c.w - 4, c.y, 0FX, 10, c(Window).bg) (* star *)
END WindowZoomMouseDown;

PROCEDURE WindowMoveStart(c: Control; x: INTEGER);
BEGIN
  c.app.dragX := c.x; c.app.dragY := c.y;
  c(Window).mx := c.x - x; (* For calculations in move handler *)
  c.status := moving; NeedRedraw(c.app)
END WindowMoveStart;

PROCEDURE WindowResizeStart(c: Control; x: INTEGER);
BEGIN
  c.app.dragX := c.x; c.app.dragY := c.y;
  c(Window).mx := c.w - x; (* For calculations in resize handler *)
  c.status := resizing; NeedRedraw(c.app)
END WindowResizeStart;

PROCEDURE BringToFront*(c: Control);
BEGIN c.prev.next := c.next; c.next.prev := c.prev;
  c.app.windows.next.prev := c; c.next := c.app.windows.next;
  c.app.windows.next := c; c.prev := c.app.windows;
  c.app.windows := c(Window);
  SetFocus(c);
  NeedRedraw(c.app)
END BringToFront;

PROCEDURE WindowMouseDown*(c: Control; x, y, button: INTEGER);
VAR p, br: Control;
BEGIN
  IF button # G.btnRight THEN
    SetFocus(c);
    IF c.app.windows # c THEN BringToFront(c)
    ELSIF y = 0 THEN
      IF c(Window).closeable & (2 <= x) & (x <= 4) THEN
        WindowCloseMouseDown(c)
      ELSIF c(Window).resizable & (c.w - 5 <= x) & (x <= c.w - 3) THEN
        WindowZoomMouseDown(c)
      ELSE WindowMoveStart(c, x)
      END
    ELSIF y = c.h - 1 THEN
      IF c(Window).resizable & (x >= c.w - 2) THEN
        WindowResizeStart(c, x)
      END
    ELSIF x = c.w - 1 THEN
    ELSIF (x # 0) & (c.children # NIL) THEN
      p := FindChildAt(c, x, y);
      IF (p # NIL) & (p.do.mouseDown # NIL) THEN
        p.do.mouseDown(p, x - p.x, y - p.y, button)
      END
    END
  END
END WindowMouseDown;

PROCEDURE WindowMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
  IF c.status # normal THEN c.status := normal; NeedRedraw(c.app) END
END WindowMouseUp;

PROCEDURE WindowMouseMove*(c: Control; x, y: INTEGER; buttons: SET);
BEGIN
  IF c.status = moving THEN
    c.x := x + c(Window).mx; c.y := y + c.app.dragY;
    IF c.y < 1 THEN c.y := 1 END;
    IF c.do.refresh # NIL THEN c.do.refresh(c) END;
    NeedRedraw(c.app)
  ELSIF c.status = resizing THEN
    c.w := x + c(Window).mx; c.h := y + 1;
    IF c.w < c(Window).minW THEN c.w := c(Window).minW
    ELSIF c.w > T.charsX THEN c.w := T.charsX
    END;
    IF c.h < c(Window).minH THEN c.h := c(Window).minH
    ELSIF c.h > T.charsY - 2 THEN c.h := T.charsY - 2
    END;
    IF c.do.refresh # NIL THEN c.do.refresh(c) END;
    NeedRedraw(c.app)
  END
END WindowMouseMove;

PROCEDURE WindowGetFocus*(c: Control);
BEGIN ControlGetFocus(c);
  IF c(Window).cur # NIL THEN SetFocus(c(Window).cur) END
END WindowGetFocus;

PROCEDURE InitWindowMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.added := WindowAdded;
  m.draw := WindowDraw;
  m.refresh := WindowRefresh;
  m.resize := WindowResize;
  m.mouseDown := WindowMouseDown;
  m.mouseUp := WindowMouseUp;
  m.mouseMove := WindowMouseMove;
  m.getFocus := WindowGetFocus
END InitWindowMethod;

(* App *)

PROCEDURE InitApp*(app: App);
BEGIN app.windows := NIL;
  app.menu := NewMenu('ROOT', '', 0, NIL); app.menu.app := app;
  app.statusbar := NewMenu('ROOT', '', 0, NIL); app.statusbar.app := app;
  app.statusText[0] := 0X;
  app.dragged := NIL; app.dragX := 0; app.dragY := 0;
  app.cur := NIL;
  app.quit := FALSE;
  app.needRedraw := TRUE
END InitApp;

PROCEDURE NewApp*(): App;
VAR a: App;
BEGIN NEW(a); InitApp(a); RETURN a
END NewApp;

PROCEDURE RefreshAppMenu*(menu: Menu);
VAR p, br: Control;
  x, y: INTEGER;
BEGIN
  IF menu.children # NIL THEN
    p := menu.children; br := p; x := 0;
    REPEAT p.do.refresh(p); p.y := 0; p.x := x; INC(x, p.w);
      RefreshMenu(p); p := p.next
    UNTIL p = br
  END
END RefreshAppMenu;

PROCEDURE AddWindow*(app: App; w: Window);
BEGIN SetApp(w, app);
  IF w.closeBtn # NIL THEN w.closeBtn.app := app END;
  IF w.zoomBtn # NIL THEN w.zoomBtn.app := app END;
  IF app.windows = NIL THEN
    app.windows := w; w.prev := w; w.next := w
  ELSE
    w.prev := app.windows;
    w.next := app.windows.next;
    app.windows.next.prev := w;
    app.windows.next := w;
    (*w.prev := app.windows.prev;
    w.next := app.windows;
    app.windows.prev.next := w;
    app.windows.prev := w;*)
    app.windows := w
  END;
  SetFocus(w)
END AddWindow;

PROCEDURE AddStatusbar*(app: App; c: Control);
BEGIN SetApp(c, app); Add(app.statusbar, c); RefreshAppMenu(app.statusbar)
END AddStatusbar;

PROCEDURE AddMenu*(app: App; m: Menu);
BEGIN SetApp(m, app); Add(app.menu, m); RefreshAppMenu(app.menu)
END AddMenu;

PROCEDURE SetStatusText*(app: App; text: ARRAY OF CHAR);
BEGIN app.statusText := text$
END SetStatusText;

PROCEDURE CheckMenuOpenKey(app: App; key: G.Key): BOOLEAN;
VAR p, q, br: Control; found: BOOLEAN;
BEGIN found := FALSE;
  IF (ORD('a') <= key.sym) & (key.sym <= ORD('z')) & ~HasModalWindow(app) THEN
    p := app.menu.children.prev; br := p;
    REPEAT p := p.next; found := MenuHotkey(p(Menu), CHR(key.sym))
    UNTIL found OR (p = br); (* !FIXME use loop pattern *)
    IF found THEN UnsetFocus(app); p.do.click(p) END
  END;
  RETURN found
END CheckMenuOpenKey;

PROCEDURE FindMenuWithHotkey(c: Menu; hotkey: INTEGER): Menu;
VAR p, br: Control;
BEGIN
  IF c.hotkey # hotkey THEN
    IF c.children # NIL THEN
      p := c.children.prev; br := p;
      REPEAT p := p.next; c := FindMenuWithHotkey(p(Menu), hotkey)
      UNTIL (p = br) OR (c # NIL)
    ELSE c := NIL
    END
  END;
  RETURN c
END FindMenuWithHotkey;

PROCEDURE CheckHotkey(app: App; key: G.Key): BOOLEAN;
VAR m: Menu;
  hotkey: INTEGER;
  handled: BOOLEAN;
BEGIN handled := FALSE; hotkey := key.code;
  IF (hotkey # 0) & ~HasModalWindow(app) THEN
    IF key.mod * G.mCtrl  # {} THEN INC(hotkey, 100H) END;
    IF key.mod * G.mAlt   # {} THEN INC(hotkey, 200H) END;
    IF key.mod * G.mShift # {} THEN INC(hotkey, 400H) END;
    m := FindMenuWithHotkey(app.menu, hotkey);
    IF m # NIL THEN handled := TRUE;
      IF m.do.click # NIL THEN m.do.click(m) END
    END
  END;
  RETURN handled
END CheckHotkey;

PROCEDURE OnKeyDown(app: App; key: G.Key);
VAR handled: BOOLEAN; p: Control;
BEGIN handled := FALSE; p := app.cur;
  IF (key.mod * (G.mCtrl + G.mAlt + G.mShift) # {}) OR
     (G.kF1 <= key.code) & (key.code <= G.kF12) OR
     (key.code = G.kPause) THEN
    handled := CheckHotkey(app, key);
    IF ~handled & (key.mod * G.mAlt # {}) THEN
      handled := CheckMenuOpenKey(app, key)
    END
  END;
  IF ~handled THEN
    IF (key.code = G.kEnter) & (key.mod * G.mAlt # {}) THEN
      T.ToggleFullscreen
    ELSIF p # NIL THEN
      IF p.do.keyDown # NIL THEN p.do.keyDown(p, key) END;
      IF (p.parent # NIL) & (p.parent IS Window) &
         (p.parent.do.keyDown # NIL) THEN
        p.parent.do.keyDown(p.parent, key)
      END
    END
  END
END OnKeyDown;

PROCEDURE OnTextInput(app: App; ch: INTEGER);
BEGIN
  IF (app.cur # NIL) & (app.cur.do.textInput # NIL) THEN
    app.cur.do.textInput(app.cur, ch)
  END
END OnTextInput;

PROCEDURE GetWindowAt(app: App; x, y: INTEGER): Control;
VAR p, br: Control;
BEGIN
  IF app.windows = NIL THEN p := NIL
  ELSE p := app.windows; br := p;
    WHILE (p # NIL) &
          ~((p.x <= x) & (x < p.x + p.w) &
            (p.y <= y) & (y < p.y + p.h)) DO
      IF p.prev = br THEN p := NIL ELSE p := p.prev END
    END
  END;
  RETURN p
END GetWindowAt;

PROCEDURE GetControlAt*(app: App; x, y: INTEGER): Control;
VAR c: Control;
BEGIN c := GetMenuAt(app, x, y);
  IF c = NIL THEN
    c := GetStatusbarAt(app, x, y);
    IF c = NIL THEN
      c := GetWindowAt(app, x, y)
    END
  END;
  RETURN c
END GetControlAt;

PROCEDURE OnMouseMove(app: App; VAR event: G.Event);
VAR x, y: INTEGER;
  c: Control;
BEGIN x := event.x DIV T.charW; y := event.y DIV T.charH;
  IF (x # T.mouseX) OR (y # T.mouseY) THEN
    T.MouseXY(x, y);
    IF event.buttons # {} THEN
      c := app.dragged;
      IF (c # NIL) & (c.do.mouseMove # NIL) THEN
        c.do.mouseMove(c, x - app.dragX, y - app.dragY, event.buttons)
      END
    END
  END
END OnMouseMove;

PROCEDURE OnMouseDown(app: App; VAR event: G.Event);
VAR x, y: INTEGER;
  c: Control;
BEGIN
  IF app.dragged = NIL THEN
    x := event.x DIV T.charW; y := event.y DIV T.charH;
    c := GetControlAt(app, x, y);
    IF c = NIL THEN UnsetFocus(app)
    ELSIF (c.do.mouseDown # NIL) &
          (~HasModalWindow(app) OR (c = app.windows)) THEN
      SetDragged(app, c);
      c.do.mouseDown(c, x - c.x, y - c.y, event.button)
    END
  END
END OnMouseDown;

PROCEDURE OnMouseUp(app: App; VAR event: G.Event);
VAR x, y: INTEGER;
  c: Control;
BEGIN x := event.x DIV T.charW; y := event.y DIV T.charH;
  IF app.dragged # NIL THEN c := app.dragged
  ELSE c := GetControlAt(app, x, y);
    IF HasModalWindow(app) & (c # app.windows) THEN c := NIL END
  END;
  app.dragged := NIL;
  IF (c # NIL) & (c.do.mouseUp # NIL) THEN
    c.do.mouseUp(c, x - app.dragX, y - app.dragY, event.button)
  END
END OnMouseUp;

PROCEDURE RunApp*(app: App);
VAR
  event: G.Event;
BEGIN
  app.quit := FALSE;
  DrawApp(app);
  REPEAT
    G.WaitEvents(50);
    WHILE G.PollEvent(event) DO
      CASE event.type OF
        G.mouseMove: OnMouseMove(app, event)
      | G.mouseDown: OnMouseDown(app, event)
      | G.mouseUp: OnMouseUp(app, event)
      | G.keyDown: OnKeyDown(app, event.key)
      | G.textInput: OnTextInput(app, event.ch)
      | G.quit: app.quit := TRUE
      ELSE
      END
    END;
    T.Act;
    IF app.needRedraw THEN DrawApp(app) END;
    IF T.Draw() THEN G.Flip ELSE G.RepeatFlip END
  UNTIL app.quit
END RunApp;

BEGIN
  NEW(controlMethod); InitControlMethod(controlMethod);
  NEW(buttonMethod); InitButtonMethod(buttonMethod);
  NEW(winBtnMethod); InitWinBtnMethod(winBtnMethod);
  NEW(scrollbarMethod); InitScrollbarMethod(scrollbarMethod);
  NEW(editMethod); InitEditMethod(editMethod);
  NEW(columnListMethod); InitColumnListMethod(columnListMethod);
  NEW(windowMethod); InitWindowMethod(windowMethod);
  NEW(menuMethod); InitMenuMethod(menuMethod);
  NEW(quickBtnMethod); InitQuickBtnMethod(quickBtnMethod)
END OV.
