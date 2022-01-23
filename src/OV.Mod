MODULE OV;
(* Copyright 2017-2022 Arthur Yefimov

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
IMPORT T := TermBox, Strings, StrList, Out, SYSTEM, Kernel;
CONST
  minInt = -70000000H-1;
  maxInt = 7FFFFFFFH;

  dblClickDelay* = 500;

  (* ControlDesc.status possible values *)
  normal*   = 0;
  disabled* = 1;
  selected* = 2;
  open*     = 3;
  moving*   = 4;
  resizing* = 5;

  (* Align constants *)
  left*   = 0;
  center* = 1;
  right*  = 2;

  (* Simple Hotkeys *)
  hF1*    = 47;
  hF2*    = 48;
  hF3*    = 49;
  hF4*    = 50;
  hF5*    = 51;
  hF6*    = 52;
  hF7*    = 53;
  hF8*    = 54;
  hF9*    = 55;
  hF10*   = 56;
  hF11*   = 57;
  hF12*   = 58;
  hPause* = 93;

  (* Ctrl Hotkeys *)
  hCtrlA*         = 100H + T.kA;
  hCtrlB*         = 100H + T.kB;
  hCtrlC*         = 100H + T.kC;
  hCtrlD*         = 100H + T.kD;
  hCtrlE*         = 100H + T.kE;
  hCtrlF*         = 100H + T.kF;
  hCtrlG*         = 100H + T.kG;
  hCtrlH*         = 100H + T.kH;
  hCtrlI*         = 100H + T.kI;
  hCtrlJ*         = 100H + T.kJ;
  hCtrlK*         = 100H + T.kK;
  hCtrlL*         = 100H + T.kL;
  hCtrlM*         = 100H + T.kM;
  hCtrlN*         = 100H + T.kN;
  hCtrlO*         = 100H + T.kO;
  hCtrlP*         = 100H + T.kP;
  hCtrlQ*         = 100H + T.kQ;
  hCtrlR*         = 100H + T.kR;
  hCtrlS*         = 100H + T.kS;
  hCtrlT*         = 100H + T.kT;
  hCtrlU*         = 100H + T.kU;
  hCtrlV*         = 100H + T.kV;
  hCtrlW*         = 100H + T.kW;
  hCtrlX*         = 100H + T.kX;
  hCtrlY*         = 100H + T.kY;
  hCtrlZ*         = 100H + T.kZ;
  hCtrl0*         = 100H + T.k0;
  hCtrl1*         = 100H + T.k1;
  hCtrl2*         = 100H + T.k2;
  hCtrl3*         = 100H + T.k3;
  hCtrl4*         = 100H + T.k4;
  hCtrl5*         = 100H + T.k5;
  hCtrl6*         = 100H + T.k6;
  hCtrl7*         = 100H + T.k7;
  hCtrl8*         = 100H + T.k8;
  hCtrl9*         = 100H + T.k9;
  hCtrlF1*        = 100H + T.kF1;
  hCtrlF2*        = 100H + T.kF2;
  hCtrlF3*        = 100H + T.kF3;
  hCtrlF4*        = 100H + T.kF4;
  hCtrlF5*        = 100H + T.kF5;
  hCtrlF6*        = 100H + T.kF6;
  hCtrlF7*        = 100H + T.kF7;
  hCtrlF8*        = 100H + T.kF8;
  hCtrlF9*        = 100H + T.kF9;
  hCtrlF10*       = 100H + T.kF10;
  hCtrlF11*       = 100H + T.kF11;
  hCtrlF12*       = 100H + T.kF12;
  hCtrlEsc*       = 100H + T.kEsc;
  hCtrlTilde*     = 100H + T.kTilde;
  hCtrlMinus*     = 100H + T.kMinus;
  hCtrlEquals*    = 100H + T.kEquals;
  hCtrlBackspace* = 100H + T.kBackspace;
  hCtrlTab*       = 100H + T.kTab;
  hCtrlEnter*     = 100H + T.kEnter;
  hCtrlColon*     = 100H + T.kColon;
  hCtrlQuote*     = 100H + T.kQuote;
  hCtrlBackslash* = 100H + T.kBackslash;
  hCtrlComma*     = 100H + T.kComma;
  hCtrlStop*      = 100H + T.kStop;
  hCtrlSlash*     = 100H + T.kSlash;
  hCtrlInsert*    = 100H + T.kInsert;
  hCtrlDel*       = 100H + T.kDel;
  hCtrlHome*      = 100H + T.kHome;
  hCtrlEnd*       = 100H + T.kEnd;
  hCtrlPgUp*      = 100H + T.kPgUp;
  hCtrlPgDn*      = 100H + T.kPgDn;
  hCtrlLeft*      = 100H + T.kLeft;
  hCtrlRight*     = 100H + T.kRight;
  hCtrlUp*        = 100H + T.kUp;
  hCtrlDown*      = 100H + T.kDown;
  hCtrlPause*     = 100H + T.kPause;

  (* Alt Hotkeys 200H *)
  hAltA*         = 200H + T.kA;
  hAltB*         = 200H + T.kB;
  hAltC*         = 200H + T.kC;
  hAltD*         = 200H + T.kD;
  hAltE*         = 200H + T.kE;
  hAltF*         = 200H + T.kF;
  hAltG*         = 200H + T.kG;
  hAltH*         = 200H + T.kH;
  hAltI*         = 200H + T.kI;
  hAltJ*         = 200H + T.kJ;
  hAltK*         = 200H + T.kK;
  hAltL*         = 200H + T.kL;
  hAltM*         = 200H + T.kM;
  hAltN*         = 200H + T.kN;
  hAltO*         = 200H + T.kO;
  hAltP*         = 200H + T.kP;
  hAltQ*         = 200H + T.kQ;
  hAltR*         = 200H + T.kR;
  hAltS*         = 200H + T.kS;
  hAltT*         = 200H + T.kT;
  hAltU*         = 200H + T.kU;
  hAltV*         = 200H + T.kV;
  hAltW*         = 200H + T.kW;
  hAltX*         = 200H + T.kX;
  hAltY*         = 200H + T.kY;
  hAltZ*         = 200H + T.kZ;
  hAlt0*         = 200H + T.k0;
  hAlt1*         = 200H + T.k1;
  hAlt2*         = 200H + T.k2;
  hAlt3*         = 200H + T.k3;
  hAlt4*         = 200H + T.k4;
  hAlt5*         = 200H + T.k5;
  hAlt6*         = 200H + T.k6;
  hAlt7*         = 200H + T.k7;
  hAlt8*         = 200H + T.k8;
  hAlt9*         = 200H + T.k9;
  hAltF1*        = 200H + T.kF1;
  hAltF2*        = 200H + T.kF2;
  hAltF3*        = 200H + T.kF3;
  hAltF4*        = 200H + T.kF4;
  hAltF5*        = 200H + T.kF5;
  hAltF6*        = 200H + T.kF6;
  hAltF7*        = 200H + T.kF7;
  hAltF8*        = 200H + T.kF8;
  hAltF9*        = 200H + T.kF9;
  hAltF10*       = 200H + T.kF10;
  hAltF11*       = 200H + T.kF11;
  hAltF12*       = 200H + T.kF12;
  hAltEsc*       = 200H + T.kEsc;
  hAltTilde*     = 200H + T.kTilde;
  hAltMinus*     = 200H + T.kMinus;
  hAltEquals*    = 200H + T.kEquals;
  hAltBackspace* = 200H + T.kBackspace;
  hAltTab*       = 200H + T.kTab;
  hAltEnter*     = 200H + T.kEnter;
  hAltColon*     = 200H + T.kColon;
  hAltQuote*     = 200H + T.kQuote;
  hAltBackslash* = 200H + T.kBackslash;
  hAltComma*     = 200H + T.kComma;
  hAltStop*      = 200H + T.kStop;
  hAltSlash*     = 200H + T.kSlash;
  hAltInsert*    = 200H + T.kInsert;
  hAltDel*       = 200H + T.kDel;
  hAltHome*      = 200H + T.kHome;
  hAltEnd*       = 200H + T.kEnd;
  hAltPgUp*      = 200H + T.kPgUp;
  hAltPgDn*      = 200H + T.kPgDn;
  hAltLeft*      = 200H + T.kLeft;
  hAltRight*     = 200H + T.kRight;
  hAltUp*        = 200H + T.kUp;
  hAltDown*      = 200H + T.kDown;
  hAltPause*     = 200H + T.kPause;

  (* Shift Hotkeys 400H *)
  hShiftA*         = 400H + T.kA;
  hShiftB*         = 400H + T.kB;
  hShiftC*         = 400H + T.kC;
  hShiftD*         = 400H + T.kD;
  hShiftE*         = 400H + T.kE;
  hShiftF*         = 400H + T.kF;
  hShiftG*         = 400H + T.kG;
  hShiftH*         = 400H + T.kH;
  hShiftI*         = 400H + T.kI;
  hShiftJ*         = 400H + T.kJ;
  hShiftK*         = 400H + T.kK;
  hShiftL*         = 400H + T.kL;
  hShiftM*         = 400H + T.kM;
  hShiftN*         = 400H + T.kN;
  hShiftO*         = 400H + T.kO;
  hShiftP*         = 400H + T.kP;
  hShiftQ*         = 400H + T.kQ;
  hShiftR*         = 400H + T.kR;
  hShiftS*         = 400H + T.kS;
  hShiftT*         = 400H + T.kT;
  hShiftU*         = 400H + T.kU;
  hShiftV*         = 400H + T.kV;
  hShiftW*         = 400H + T.kW;
  hShiftX*         = 400H + T.kX;
  hShiftY*         = 400H + T.kY;
  hShiftZ*         = 400H + T.kZ;
  hShift0*         = 400H + T.k0;
  hShift1*         = 400H + T.k1;
  hShift2*         = 400H + T.k2;
  hShift3*         = 400H + T.k3;
  hShift4*         = 400H + T.k4;
  hShift5*         = 400H + T.k5;
  hShift6*         = 400H + T.k6;
  hShift7*         = 400H + T.k7;
  hShift8*         = 400H + T.k8;
  hShift9*         = 400H + T.k9;
  hShiftF1*        = 400H + T.kF1;
  hShiftF2*        = 400H + T.kF2;
  hShiftF3*        = 400H + T.kF3;
  hShiftF4*        = 400H + T.kF4;
  hShiftF5*        = 400H + T.kF5;
  hShiftF6*        = 400H + T.kF6;
  hShiftF7*        = 400H + T.kF7;
  hShiftF8*        = 400H + T.kF8;
  hShiftF9*        = 400H + T.kF9;
  hShiftF10*       = 400H + T.kF10;
  hShiftF11*       = 400H + T.kF11;
  hShiftF12*       = 400H + T.kF12;
  hShiftEsc*       = 400H + T.kEsc;
  hShiftTilde*     = 400H + T.kTilde;
  hShiftMinus*     = 400H + T.kMinus;
  hShiftEquals*    = 400H + T.kEquals;
  hShiftBackspace* = 400H + T.kBackspace;
  hShiftTab*       = 400H + T.kTab;
  hShiftEnter*     = 400H + T.kEnter;
  hShiftColon*     = 400H + T.kColon;
  hShiftQuote*     = 400H + T.kQuote;
  hShiftBackslash* = 400H + T.kBackslash;
  hShiftComma*     = 400H + T.kComma;
  hShiftStop*      = 400H + T.kStop;
  hShiftSlash*     = 400H + T.kSlash;
  hShiftInsert*    = 400H + T.kInsert;
  hShiftDel*       = 400H + T.kDel;
  hShiftHome*      = 400H + T.kHome;
  hShiftEnd*       = 400H + T.kEnd;
  hShiftPgUp*      = 400H + T.kPgUp;
  hShiftPgDn*      = 400H + T.kPgDn;
  hShiftLeft*      = 400H + T.kLeft;
  hShiftRight*     = 400H + T.kRight;
  hShiftUp*        = 400H + T.kUp;
  hShiftDown*      = 400H + T.kDown;
  hShiftPause*     = 400H + T.kPause;

  (* Ctrl+Shift Hotkeys 500H *)
  hCtrlShiftA*         = 500H + T.kA;
  hCtrlShiftB*         = 500H + T.kB;
  hCtrlShiftC*         = 500H + T.kC;
  hCtrlShiftD*         = 500H + T.kD;
  hCtrlShiftE*         = 500H + T.kE;
  hCtrlShiftF*         = 500H + T.kF;
  hCtrlShiftG*         = 500H + T.kG;
  hCtrlShiftH*         = 500H + T.kH;
  hCtrlShiftI*         = 500H + T.kI;
  hCtrlShiftJ*         = 500H + T.kJ;
  hCtrlShiftK*         = 500H + T.kK;
  hCtrlShiftL*         = 500H + T.kL;
  hCtrlShiftM*         = 500H + T.kM;
  hCtrlShiftN*         = 500H + T.kN;
  hCtrlShiftO*         = 500H + T.kO;
  hCtrlShiftP*         = 500H + T.kP;
  hCtrlShiftQ*         = 500H + T.kQ;
  hCtrlShiftR*         = 500H + T.kR;
  hCtrlShiftS*         = 500H + T.kS;
  hCtrlShiftT*         = 500H + T.kT;
  hCtrlShiftU*         = 500H + T.kU;
  hCtrlShiftV*         = 500H + T.kV;
  hCtrlShiftW*         = 500H + T.kW;
  hCtrlShiftX*         = 500H + T.kX;
  hCtrlShiftY*         = 500H + T.kY;
  hCtrlShiftZ*         = 500H + T.kZ;
  hCtrlShift0*         = 500H + T.k0;
  hCtrlShift1*         = 500H + T.k1;
  hCtrlShift2*         = 500H + T.k2;
  hCtrlShift3*         = 500H + T.k3;
  hCtrlShift4*         = 500H + T.k4;
  hCtrlShift5*         = 500H + T.k5;
  hCtrlShift6*         = 500H + T.k6;
  hCtrlShift7*         = 500H + T.k7;
  hCtrlShift8*         = 500H + T.k8;
  hCtrlShift9*         = 500H + T.k9;
  hCtrlShiftF1*        = 500H + T.kF1;
  hCtrlShiftF2*        = 500H + T.kF2;
  hCtrlShiftF3*        = 500H + T.kF3;
  hCtrlShiftF4*        = 500H + T.kF4;
  hCtrlShiftF5*        = 500H + T.kF5;
  hCtrlShiftF6*        = 500H + T.kF6;
  hCtrlShiftF7*        = 500H + T.kF7;
  hCtrlShiftF8*        = 500H + T.kF8;
  hCtrlShiftF9*        = 500H + T.kF9;
  hCtrlShiftF10*       = 500H + T.kF10;
  hCtrlShiftF11*       = 500H + T.kF11;
  hCtrlShiftF12*       = 500H + T.kF12;
  hCtrlShiftEsc*       = 500H + T.kEsc;
  hCtrlShiftTilde*     = 500H + T.kTilde;
  hCtrlShiftMinus*     = 500H + T.kMinus;
  hCtrlShiftEquals*    = 500H + T.kEquals;
  hCtrlShiftBackspace* = 500H + T.kBackspace;
  hCtrlShiftTab*       = 500H + T.kTab;
  hCtrlShiftEnter*     = 500H + T.kEnter;
  hCtrlShiftColon*     = 500H + T.kColon;
  hCtrlShiftQuote*     = 500H + T.kQuote;
  hCtrlShiftBackslash* = 500H + T.kBackslash;
  hCtrlShiftComma*     = 500H + T.kComma;
  hCtrlShiftStop*      = 500H + T.kStop;
  hCtrlShiftSlash*     = 500H + T.kSlash;
  hCtrlShiftInsert*    = 500H + T.kInsert;
  hCtrlShiftDel*       = 500H + T.kDel;
  hCtrlShiftHome*      = 500H + T.kHome;
  hCtrlShiftEnd*       = 500H + T.kEnd;
  hCtrlShiftPgUp*      = 500H + T.kPgUp;
  hCtrlShiftPgDn*      = 500H + T.kPgDn;
  hCtrlShiftLeft*      = 500H + T.kLeft;
  hCtrlShiftRight*     = 500H + T.kRight;
  hCtrlShiftUp*        = 500H + T.kUp;
  hCtrlShiftDown*      = 500H + T.kDown;
  hCtrlShiftPause*     = 500H + T.kPause;

  (* Ctrl+Alt Hotkeys 300H *)
  hCtrlAltA*         = 300H + T.kA;
  hCtrlAltB*         = 300H + T.kB;
  hCtrlAltC*         = 300H + T.kC;
  hCtrlAltD*         = 300H + T.kD;
  hCtrlAltE*         = 300H + T.kE;
  hCtrlAltF*         = 300H + T.kF;
  hCtrlAltG*         = 300H + T.kG;
  hCtrlAltH*         = 300H + T.kH;
  hCtrlAltI*         = 300H + T.kI;
  hCtrlAltJ*         = 300H + T.kJ;
  hCtrlAltK*         = 300H + T.kK;
  hCtrlAltL*         = 300H + T.kL;
  hCtrlAltM*         = 300H + T.kM;
  hCtrlAltN*         = 300H + T.kN;
  hCtrlAltO*         = 300H + T.kO;
  hCtrlAltP*         = 300H + T.kP;
  hCtrlAltQ*         = 300H + T.kQ;
  hCtrlAltR*         = 300H + T.kR;
  hCtrlAltS*         = 300H + T.kS;
  hCtrlAltT*         = 300H + T.kT;
  hCtrlAltU*         = 300H + T.kU;
  hCtrlAltV*         = 300H + T.kV;
  hCtrlAltW*         = 300H + T.kW;
  hCtrlAltX*         = 300H + T.kX;
  hCtrlAltY*         = 300H + T.kY;
  hCtrlAltZ*         = 300H + T.kZ;
  hCtrlAlt0*         = 300H + T.k0;
  hCtrlAlt1*         = 300H + T.k1;
  hCtrlAlt2*         = 300H + T.k2;
  hCtrlAlt3*         = 300H + T.k3;
  hCtrlAlt4*         = 300H + T.k4;
  hCtrlAlt5*         = 300H + T.k5;
  hCtrlAlt6*         = 300H + T.k6;
  hCtrlAlt7*         = 300H + T.k7;
  hCtrlAlt8*         = 300H + T.k8;
  hCtrlAlt9*         = 300H + T.k9;
  hCtrlAltF1*        = 300H + T.kF1;
  hCtrlAltF2*        = 300H + T.kF2;
  hCtrlAltF3*        = 300H + T.kF3;
  hCtrlAltF4*        = 300H + T.kF4;
  hCtrlAltF5*        = 300H + T.kF5;
  hCtrlAltF6*        = 300H + T.kF6;
  hCtrlAltF7*        = 300H + T.kF7;
  hCtrlAltF8*        = 300H + T.kF8;
  hCtrlAltF9*        = 300H + T.kF9;
  hCtrlAltF10*       = 300H + T.kF10;
  hCtrlAltF11*       = 300H + T.kF11;
  hCtrlAltF12*       = 300H + T.kF12;
  hCtrlAltEsc*       = 300H + T.kEsc;
  hCtrlAltTilde*     = 300H + T.kTilde;
  hCtrlAltMinus*     = 300H + T.kMinus;
  hCtrlAltEquals*    = 300H + T.kEquals;
  hCtrlAltBackspace* = 300H + T.kBackspace;
  hCtrlAltTab*       = 300H + T.kTab;
  hCtrlAltEnter*     = 300H + T.kEnter;
  hCtrlAltColon*     = 300H + T.kColon;
  hCtrlAltQuote*     = 300H + T.kQuote;
  hCtrlAltBackslash* = 300H + T.kBackslash;
  hCtrlAltComma*     = 300H + T.kComma;
  hCtrlAltStop*      = 300H + T.kStop;
  hCtrlAltSlash*     = 300H + T.kSlash;
  hCtrlAltInsert*    = 300H + T.kInsert;
  hCtrlAltDel*       = 300H + T.kDel;
  hCtrlAltHome*      = 300H + T.kHome;
  hCtrlAltEnd*       = 300H + T.kEnd;
  hCtrlAltPgUp*      = 300H + T.kPgUp;
  hCtrlAltPgDn*      = 300H + T.kPgDn;
  hCtrlAltLeft*      = 300H + T.kLeft;
  hCtrlAltRight*     = 300H + T.kRight;
  hCtrlAltUp*        = 300H + T.kUp;
  hCtrlAltDown*      = 300H + T.kDown;
  hCtrlAltPause*     = 300H + T.kPause;

  (* Alt+Shift Hotkeys 600H *)
  hAltShiftA*         = 600H + T.kA;
  hAltShiftB*         = 600H + T.kB;
  hAltShiftC*         = 600H + T.kC;
  hAltShiftD*         = 600H + T.kD;
  hAltShiftE*         = 600H + T.kE;
  hAltShiftF*         = 600H + T.kF;
  hAltShiftG*         = 600H + T.kG;
  hAltShiftH*         = 600H + T.kH;
  hAltShiftI*         = 600H + T.kI;
  hAltShiftJ*         = 600H + T.kJ;
  hAltShiftK*         = 600H + T.kK;
  hAltShiftL*         = 600H + T.kL;
  hAltShiftM*         = 600H + T.kM;
  hAltShiftN*         = 600H + T.kN;
  hAltShiftO*         = 600H + T.kO;
  hAltShiftP*         = 600H + T.kP;
  hAltShiftQ*         = 600H + T.kQ;
  hAltShiftR*         = 600H + T.kR;
  hAltShiftS*         = 600H + T.kS;
  hAltShiftT*         = 600H + T.kT;
  hAltShiftU*         = 600H + T.kU;
  hAltShiftV*         = 600H + T.kV;
  hAltShiftW*         = 600H + T.kW;
  hAltShiftX*         = 600H + T.kX;
  hAltShiftY*         = 600H + T.kY;
  hAltShiftZ*         = 600H + T.kZ;
  hAltShift0*         = 600H + T.k0;
  hAltShift1*         = 600H + T.k1;
  hAltShift2*         = 600H + T.k2;
  hAltShift3*         = 600H + T.k3;
  hAltShift4*         = 600H + T.k4;
  hAltShift5*         = 600H + T.k5;
  hAltShift6*         = 600H + T.k6;
  hAltShift7*         = 600H + T.k7;
  hAltShift8*         = 600H + T.k8;
  hAltShift9*         = 600H + T.k9;
  hAltShiftF1*        = 600H + T.kF1;
  hAltShiftF2*        = 600H + T.kF2;
  hAltShiftF3*        = 600H + T.kF3;
  hAltShiftF4*        = 600H + T.kF4;
  hAltShiftF5*        = 600H + T.kF5;
  hAltShiftF6*        = 600H + T.kF6;
  hAltShiftF7*        = 600H + T.kF7;
  hAltShiftF8*        = 600H + T.kF8;
  hAltShiftF9*        = 600H + T.kF9;
  hAltShiftF10*       = 600H + T.kF10;
  hAltShiftF11*       = 600H + T.kF11;
  hAltShiftF12*       = 600H + T.kF12;
  hAltShiftEsc*       = 600H + T.kEsc;
  hAltShiftTilde*     = 600H + T.kTilde;
  hAltShiftMinus*     = 600H + T.kMinus;
  hAltShiftEquals*    = 600H + T.kEquals;
  hAltShiftBackspace* = 600H + T.kBackspace;
  hAltShiftTab*       = 600H + T.kTab;
  hAltShiftEnter*     = 600H + T.kEnter;
  hAltShiftColon*     = 600H + T.kColon;
  hAltShiftQuote*     = 600H + T.kQuote;
  hAltShiftBackslash* = 600H + T.kBackslash;
  hAltShiftComma*     = 600H + T.kComma;
  hAltShiftStop*      = 600H + T.kStop;
  hAltShiftSlash*     = 600H + T.kSlash;
  hAltShiftInsert*    = 600H + T.kInsert;
  hAltShiftDel*       = 600H + T.kDel;
  hAltShiftHome*      = 600H + T.kHome;
  hAltShiftEnd*       = 600H + T.kEnd;
  hAltShiftPgUp*      = 600H + T.kPgUp;
  hAltShiftPgDn*      = 600H + T.kPgDn;
  hAltShiftLeft*      = 600H + T.kLeft;
  hAltShiftRight*     = 600H + T.kRight;
  hAltShiftUp*        = 600H + T.kUp;
  hAltShiftDown*      = 600H + T.kDown;
  hAltShiftPause*     = 600H + T.kPause;

  (* Ctrl+Alt+Shift Hotkeys 700H *)
  hCtrlAltShiftA*         = 700H + T.kA;
  hCtrlAltShiftB*         = 700H + T.kB;
  hCtrlAltShiftC*         = 700H + T.kC;
  hCtrlAltShiftD*         = 700H + T.kD;
  hCtrlAltShiftE*         = 700H + T.kE;
  hCtrlAltShiftF*         = 700H + T.kF;
  hCtrlAltShiftG*         = 700H + T.kG;
  hCtrlAltShiftH*         = 700H + T.kH;
  hCtrlAltShiftI*         = 700H + T.kI;
  hCtrlAltShiftJ*         = 700H + T.kJ;
  hCtrlAltShiftK*         = 700H + T.kK;
  hCtrlAltShiftL*         = 700H + T.kL;
  hCtrlAltShiftM*         = 700H + T.kM;
  hCtrlAltShiftN*         = 700H + T.kN;
  hCtrlAltShiftO*         = 700H + T.kO;
  hCtrlAltShiftP*         = 700H + T.kP;
  hCtrlAltShiftQ*         = 700H + T.kQ;
  hCtrlAltShiftR*         = 700H + T.kR;
  hCtrlAltShiftS*         = 700H + T.kS;
  hCtrlAltShiftT*         = 700H + T.kT;
  hCtrlAltShiftU*         = 700H + T.kU;
  hCtrlAltShiftV*         = 700H + T.kV;
  hCtrlAltShiftW*         = 700H + T.kW;
  hCtrlAltShiftX*         = 700H + T.kX;
  hCtrlAltShiftY*         = 700H + T.kY;
  hCtrlAltShiftZ*         = 700H + T.kZ;
  hCtrlAltShift0*         = 700H + T.k0;
  hCtrlAltShift1*         = 700H + T.k1;
  hCtrlAltShift2*         = 700H + T.k2;
  hCtrlAltShift3*         = 700H + T.k3;
  hCtrlAltShift4*         = 700H + T.k4;
  hCtrlAltShift5*         = 700H + T.k5;
  hCtrlAltShift6*         = 700H + T.k6;
  hCtrlAltShift7*         = 700H + T.k7;
  hCtrlAltShift8*         = 700H + T.k8;
  hCtrlAltShift9*         = 700H + T.k9;
  hCtrlAltShiftF1*        = 700H + T.kF1;
  hCtrlAltShiftF2*        = 700H + T.kF2;
  hCtrlAltShiftF3*        = 700H + T.kF3;
  hCtrlAltShiftF4*        = 700H + T.kF4;
  hCtrlAltShiftF5*        = 700H + T.kF5;
  hCtrlAltShiftF6*        = 700H + T.kF6;
  hCtrlAltShiftF7*        = 700H + T.kF7;
  hCtrlAltShiftF8*        = 700H + T.kF8;
  hCtrlAltShiftF9*        = 700H + T.kF9;
  hCtrlAltShiftF10*       = 700H + T.kF10;
  hCtrlAltShiftF11*       = 700H + T.kF11;
  hCtrlAltShiftF12*       = 700H + T.kF12;
  hCtrlAltShiftEsc*       = 700H + T.kEsc;
  hCtrlAltShiftTilde*     = 700H + T.kTilde;
  hCtrlAltShiftMinus*     = 700H + T.kMinus;
  hCtrlAltShiftEquals*    = 700H + T.kEquals;
  hCtrlAltShiftBackspace* = 700H + T.kBackspace;
  hCtrlAltShiftTab*       = 700H + T.kTab;
  hCtrlAltShiftEnter*     = 700H + T.kEnter;
  hCtrlAltShiftColon*     = 700H + T.kColon;
  hCtrlAltShiftQuote*     = 700H + T.kQuote;
  hCtrlAltShiftBackslash* = 700H + T.kBackslash;
  hCtrlAltShiftComma*     = 700H + T.kComma;
  hCtrlAltShiftStop*      = 700H + T.kStop;
  hCtrlAltShiftSlash*     = 700H + T.kSlash;
  hCtrlAltShiftInsert*    = 700H + T.kInsert;
  hCtrlAltShiftDel*       = 700H + T.kDel;
  hCtrlAltShiftHome*      = 700H + T.kHome;
  hCtrlAltShiftEnd*       = 700H + T.kEnd;
  hCtrlAltShiftPgUp*      = 700H + T.kPgUp;
  hCtrlAltShiftPgDn*      = 700H + T.kPgDn;
  hCtrlAltShiftLeft*      = 700H + T.kLeft;
  hCtrlAltShiftRight*     = 700H + T.kRight;
  hCtrlAltShiftUp*        = 700H + T.kUp;
  hCtrlAltShiftDown*      = 700H + T.kDown;
  hCtrlAltShiftPause*     = 700H + T.kPause;

TYPE
  App* = POINTER TO AppDesc;
  Control* = POINTER TO ControlDesc;
  ControlMethod* = POINTER TO ControlMethodDesc;

  ClickHandler* = PROCEDURE (c: Control);
  ChangeHandler* = ClickHandler;

  ControlDesc* = RECORD
    app*: App;
    parent*, children*: Control;
    prev*, next*: Control;
    x*, y*, w*, h*: INTEGER;
    tabIndex*: INTEGER;
    enabled*: BOOLEAN;
    default*: BOOLEAN;
    focused*: BOOLEAN;
    mouseActive*: BOOLEAN; (* FALSE if control does not capture mouse events *)
    status*: INTEGER;
    caption*: ARRAY 256 OF CHAR;
    onClick*: ClickHandler;
    onDblClick*: ClickHandler;
    onChange*: ChangeHandler;
    do*: ControlMethod
  END;

  ControlMethodDesc* = RECORD
    added*: PROCEDURE (c, child: Control);
    draw*: PROCEDURE (c: Control; x, y: INTEGER);
    resize*: PROCEDURE (c: Control; x, y, w, h: INTEGER);
    refresh*: PROCEDURE (c: Control);
    click*: PROCEDURE (c: Control);
    dblClick*: PROCEDURE (c: Control);
    keyDown*: PROCEDURE (c: Control; VAR E: T.Event);
    textInput*: PROCEDURE (c: Control; ch: CHAR);
    getFocus*: PROCEDURE (c: Control);
    lostFocus*: PROCEDURE (c: Control);
    mouseMove*: PROCEDURE (c: Control; x, y: INTEGER; button: INTEGER);
    mouseDown*: PROCEDURE (c: Control; x, y, button: INTEGER);
    mouseUp*: PROCEDURE (c: Control; x, y, button: INTEGER);
    close*: PROCEDURE (c: Control; VAR cancel: BOOLEAN)
  END;

  Menu* = POINTER TO MenuDesc;
  MenuDesc* = RECORD(ControlDesc)
    innerW*, innerH*: INTEGER;
    hint*: ARRAY 40 OF CHAR;
    hintW*: INTEGER;
    hotkey*: INTEGER;
    lastSelected*: Control
  END;

  Label* = POINTER TO LabelDesc;
  LabelDesc* = RECORD(ControlDesc)
    len*: INTEGER;
    align*: INTEGER (* See constants above *)
  END;

  QuickBtn* = POINTER TO QuickBtnDesc;
  QuickBtnDesc* = RECORD(MenuDesc) END;

  Button* = POINTER TO ButtonDesc;
  ButtonDesc* = RECORD(ControlDesc) END;

  WinBtn* = POINTER TO WinBtnDesc;
  WinBtnDesc* = RECORD(ButtonDesc) END;

  Scrollbar* = POINTER TO ScrollbarDesc;
  ScrollbarDesc* = RECORD(ControlDesc)
    max*, cur*: INTEGER; (* cur is runner position in range 0..max *)
    runnerOffset*: INTEGER; (* Current visual position of runner *)
    runnerW*: INTEGER; (* Visual width of runner *)
    onScrollbar*: PROCEDURE (c: Control)
  END;

  Edit* = POINTER TO EditDesc;
  EditDesc* = RECORD(ControlDesc)
    len*: INTEGER; (* Actual amount of characters before 0X *)
    pos*: INTEGER
  END;

  ColumnList* = POINTER TO ColumnListDesc;
  ColumnListDesc* = RECORD(ControlDesc)
    cols*: INTEGER; (* Column count *)
    items*: StrList.List;
    begin*: INTEGER; (* What index list begins with visually *)
    cur*: INTEGER;
    lastMouseDownItem*: INTEGER;
    scrollbar: Scrollbar;
  END;

  Window* = POINTER TO WindowDesc;
  WindowDesc* = RECORD(ControlDesc)
    cur*: Control;
    modal*: BOOLEAN;
    resizable*: BOOLEAN;
    closeable*: BOOLEAN;
    closeOnEsc*: BOOLEAN;
    closeBtn*, zoomBtn*: WinBtn;
    bg*: INTEGER;
    minW*, minH*: INTEGER;
    mx*, my*, mw*, mh*: INTEGER (* To store x, y, w, h when maximized *)
  END;

  AppDesc* = RECORD
    windows*: Window;
    menu*: Menu;
    statusbar*: Menu;
    statusText*: ARRAY 256 OF CHAR;
    cur*: Control;
    dragged*: Control;
    dragX*, dragY*: INTEGER;
    lastMouseDownTime*: INTEGER;
    quit*: BOOLEAN;
    needRedraw*: BOOLEAN;
    sync*: BOOLEAN;
    mouseBtn*: INTEGER
  END;

VAR
  controlMethod*: ControlMethod;
  labelMethod*: ControlMethod;
  quickBtnMethod*: ControlMethod;
  buttonMethod*: ControlMethod;
  winBtnMethod*: ControlMethod;
  scrollbarMethod*: ControlMethod;
  editMethod*: ControlMethod;
  columnListMethod*: ControlMethod;
  windowMethod*: ControlMethod;
  menuMethod*: ControlMethod;

  ticks: INTEGER;

PROCEDURE DrawAppWindows*(app: App);
VAR w, br: Control;
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  T.Fill(0, 1, tW, tH - 2, T.lightShade, 1, 7);
  IF app.windows # NIL THEN
    w := app.windows.next; br := w;
    REPEAT w.do.draw(w, 0, 0); w := w.next UNTIL w = br
  END
END DrawAppWindows;

PROCEDURE DrawAppStatusbar(app: App);
VAR m, br: Control;
  x: INTEGER;
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH); x := 0;
  T.Fill(0, tH - 1, tW, 1, ' ', 0, 7);
  IF app.statusbar.children # NIL THEN
    m := app.statusbar.children; br := m;
    REPEAT m.do.draw(m, 0, tH - 1); INC(x, m.w); m := m.next
    UNTIL m = br
  END;
  IF app.statusText[0] # 0X THEN
    T.SetCell(x, tH - 1, T.lineVert, 0, 7);
    T.Print(x + 2, tH - 1, -1, app.statusText, 0, 7)
  END
END DrawAppStatusbar;

PROCEDURE DrawAppMenu(app: App);
VAR m, br: Control;
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  T.Fill(0, 0, tW, 1, ' ', 0, 7);
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
BEGIN IF app # NIL THEN app.needRedraw := TRUE END
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
    IF c = NIL THEN T.HideCursor
    ELSIF c.do.getFocus # NIL THEN c.do.getFocus(c)
    END
  END
END SetAppFocus;

PROCEDURE UnsetFocus*(app: App);
BEGIN SetAppFocus(app, NIL)
END UnsetFocus;

PROCEDURE SetFocus*(c: Control);
BEGIN IF (c # NIL) & (c.app # NIL) THEN SetAppFocus(c.app, c) END
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

PROCEDURE Cap(c: CHAR): CHAR;
BEGIN
  IF ('a' <= c) & (c <= 'z') THEN c := CHR(ORD('Q') - ORD('q') + ORD(c))
  ELSIF ('а' <= c) & (c <= 'я') THEN  c := CHR(ORD('Б') - ORD('б') + ORD(c))
  ELSIF c = 'ё' THEN c := 'Ё'
  END ;
RETURN c END Cap;

PROCEDURE Refresh*(c: Control);
BEGIN
  IF c.do.refresh # NIL THEN c.do.refresh(c) END
END Refresh;

(** fg2 is a color of marked letters, that are escaped with '&'. *)
PROCEDURE PutMarkedString*(x, y: INTEGER; s: ARRAY OF CHAR; fg, fg2, bg, limit: INTEGER);
VAR i, c, tW, tH: INTEGER;
  mark: BOOLEAN;
BEGIN T.Size(tW, tH);
  IF limit = 0 THEN limit := tW END;
  i := 0; mark := FALSE;
  WHILE (i < LEN(s)) & (s[i] # 0X) & (x <= limit) DO
    IF s[i] = '&' THEN mark := TRUE
    ELSE
      IF mark THEN c := fg2; mark := FALSE ELSE c := fg END;
      T.SetCell(x, y, s[i], c, bg);
      INC(x)
    END;
    INC(i)
  END
END PutMarkedString;

PROCEDURE SetCharColor(x, y, fg, bg: INTEGER);
BEGIN T.SetFg(x, y, fg); T.SetBg(x, y, bg)
END SetCharColor;


PROCEDURE DrawWindowBorder*(x, y, w, h, fg, bg: INTEGER;
  title: ARRAY OF CHAR; resizable, moving, inactive: BOOLEAN);
VAR i, x2, y2, len, tW, tH: INTEGER; ch: CHAR;
    single: BOOLEAN; (* Sigle border *)
BEGIN single := moving OR inactive;
  T.Size(tW, tH);
  IF moving THEN fg := 10
  ELSIF inactive THEN
    IF bg = 7 THEN fg := 8 ELSE fg := 7 END
  END;
  x2 := x + w - 1; y2 := y + h - 1;
  IF single THEN ch := T.lineHor ELSE ch := T.doubleHor END;
  FOR i := x + 1 TO x2 - 1 DO
    T.SetCell(i, y, ch, fg, bg);
    T.SetCell(i, y2, ch, fg, bg)
  END;
  IF single THEN ch := T.lineVert ELSE ch := T.doubleVert END;
  FOR i := y + 1 TO y2 - 1 DO T.SetCell(x, i, ch, fg, bg) END;
  IF resizable & ~inactive THEN (* Vertical Scrollbarbar: *)
    FOR i := y + 2 TO y2 - 2 DO T.SetCell(x2, i, T.mediumShade, bg, 3) END;
    T.SetCell(x2, y + 1, T.triangleUp, bg, 3);
    T.SetCell(x2, y2 - 1, T.triangleDown, bg, 3)
  ELSE
    IF single THEN ch := T.lineVert ELSE ch := T.doubleVert END;
    FOR i := y + 1 TO y2 - 1 DO T.SetCell(x2, i, ch, fg, bg) END
  END; (* Corners: *)
  IF single THEN
    T.SetCell(x, y, T.lineDownRight, fg, bg);
    T.SetCell(x2, y, T.lineDownLeft, fg, bg);
    T.SetCell(x, y2, T.lineUpRight, fg, bg)
  ELSE
    T.SetCell(x, y, T.doubleDownRight, fg, bg);
    T.SetCell(x2, y, T.doubleDownLeft, fg, bg);
    T.SetCell(x, y2, T.doubleUpRight, fg, bg)
  END;
  IF resizable & ~inactive THEN (* Corner: *)
    T.SetCell(x2 - 1, y2, T.lineHor, 10, bg);
    T.SetCell(x2, y2, T.lineUpLeft, 10, bg);
    T.SetCell(x2 - 4, y, '[', fg, bg); (* Maximize button *)
    IF (w = tW) & (h = tH - 2) THEN ch := T.arrowUpDown
    ELSE ch := T.arrowUp
    END;
    T.SetCell(x2 - 3, y, ch, 10, bg);
    T.SetCell(x2 - 2, y, ']', fg, bg);
  ELSIF single THEN T.SetCell(x2, y2, T.lineUpLeft, fg, bg)
  ELSE T.SetCell(x2, y2, T.doubleUpLeft, fg, bg)
  END; (* Close button: *)
  IF ~inactive THEN
    T.SetCell(x + 2, y, '[', fg, bg);
    T.SetCell(x + 3, y, T.blackSquare, 10, bg);
    T.SetCell(x + 4, y, ']', fg, bg)
  END;
  IF x2 < tW - 1 THEN (* Right shadow: *)
    FOR i := y + 1 TO y2 DO SetCharColor(x2 + 1, i, 8, 0) END;
    IF x2 < tW - 2 THEN (* Most right column: *)
      FOR i := y + 1 TO y2 DO SetCharColor(x2 + 2, i, 8, 0) END
    END
  END;
  IF y2 < tH - 2 THEN (* Bottom shadow: *)
    FOR i := x + 2 TO x2 + 2 DO SetCharColor(i, y2 + 1, 8, 0) END
  END; (* Title: *)
  IF title[0] # 0X THEN
    len := Strings.Length(title);
    i := x + (w - len) DIV 2;
    IF i < x + 5 THEN i := x + 5 END;
    IF i + len > x2 - 4 THEN len := x2 - i - 4 END;
    IF i # x + 5 THEN T.SetCell(i - 1, y, ' ', fg, bg) END;
    IF i + len # x2 - 4 THEN T.SetCell(i + len, y, ' ', fg, bg) END;
    T.Print(i, y, i + len - 1, title, fg, bg)
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
  END
RETURN p END FindChildAt;

PROCEDURE PassMouseDown*(c: Control; x, y, button: INTEGER): BOOLEAN;
VAR p: Control;
BEGIN p := FindChildAt(c, x, y);
  IF (p # NIL) & (p.do.mouseDown # NIL) THEN
    p.do.mouseDown(p, x - p.x, y - p.y, button)
  END
RETURN p # NIL END PassMouseDown;

PROCEDURE PassMouseMove*(c: Control; x, y: INTEGER; button: INTEGER): BOOLEAN;
VAR p: Control;
BEGIN p := FindChildAt(c, x, y);
  IF (p # NIL) & (p.do.mouseMove # NIL) THEN
    p.do.mouseMove(p, x - p.x, y - p.y, button)
  END
RETURN p # NIL END PassMouseMove;

PROCEDURE SetEnabled*(c: Control; enabled: BOOLEAN);
BEGIN c.enabled := enabled
END SetEnabled;

(* Control *)

PROCEDURE InitControl*(c: Control);
BEGIN c.x := 0; c.y := 0; c.w := 0; c.h := 0; c.tabIndex := 0;
  c.parent := NIL; c.children := NIL; c.prev := NIL; c.next := NIL;
  c.enabled := TRUE; c.default := FALSE; c.focused := FALSE;
  c.mouseActive := TRUE; c.status := 0; c.caption[0] := 0X;
  c.onClick := NIL; c.onDblClick := NIL; c.onChange := NIL;
  c.do := controlMethod
END InitControl;

PROCEDURE NewControl*(): Control;
VAR c: Control;
BEGIN NEW(c); InitControl(c) ;
RETURN c END NewControl;

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
BEGIN c.focused := FALSE;
  T.HideCursor; NeedRedraw(c.app)
END ControlLostFocus;

PROCEDURE ControlClick*(c: Control);
BEGIN IF c.onClick # NIL THEN c.onClick(c) END
END ControlClick;

PROCEDURE ControlDblClick*(c: Control);
BEGIN IF c.onDblClick # NIL THEN c.onDblClick(c) END
END ControlDblClick;

PROCEDURE ControlMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
BEGIN
END ControlMouseMove;

PROCEDURE ControlMouseDown*(c: Control; x, y, button: INTEGER);
VAR n: INTEGER;
BEGIN n := ticks;
  IF n - c.app.lastMouseDownTime <= dblClickDelay THEN
    IF c.do.dblClick # NIL THEN c.do.dblClick(c) END;
    c.app.lastMouseDownTime := 0
  ELSE c.app.lastMouseDownTime := n
  END
END ControlMouseDown;

PROCEDURE ControlMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
END ControlMouseUp;

PROCEDURE InitControlMethod*(m: ControlMethod);
BEGIN
  m.added := NIL;
  m.draw := NIL;
  m.resize := ControlResize;
  m.refresh := NIL;
  m.click := ControlClick;
  m.dblClick := ControlDblClick;
  m.keyDown := NIL;
  m.getFocus := ControlGetFocus;
  m.lostFocus := ControlLostFocus;
  m.mouseMove := ControlMouseMove;
  m.mouseDown := ControlMouseDown;
  m.mouseUp := ControlMouseUp;
  m.close := NIL
END InitControlMethod;

(* Menu *)

PROCEDURE InitMenu*(m: Menu; caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler);
BEGIN InitControl(m);
  m.caption := caption;
  m.innerW := 0; m.innerH := 0;
  m.hint := hint; m.hintW := 0;
  m.hotkey := hotkey;
  m.lastSelected := NIL;
  m.onClick := onClick;
  m.do := menuMethod
END InitMenu;

PROCEDURE NewMenu*(caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler): Menu;
VAR m: Menu;
BEGIN NEW(m); InitMenu(m, caption, hint, hotkey, onClick) ;
RETURN m END NewMenu;

PROCEDURE DrawMenuCaption(m: Control; x, y: INTEGER);
VAR i, w, bg, fg: INTEGER;
  hl: BOOLEAN; (* Highlighted letter *)
BEGIN
  INC(x, m.x); INC(y, m.y); w := m.w - 2;
  IF m.caption = '-' THEN
    T.Fill(x, y, m.w, 1, T.lineHor, 0, 7); (* - *)
    T.SetCell(x - 1, y, T.lineVertRight, 0, 7);
    T.SetCell(x + w + 2, y, T.lineVertLeft, 0, 7)
  ELSE
    IF (m.status = selected) OR (m.status = open) THEN bg := 2
    ELSE bg := 7
    END;
    T.SetCell(x, y, ' ', 0, bg); INC(x);
    i := 0; hl := FALSE;
    WHILE m.caption[i] # 0X DO
      IF (m.caption[i] = '&') & ~hl THEN hl := TRUE
      ELSE
        IF m.status = disabled THEN fg := 8
        ELSIF hl & (m.caption[i] # '&') THEN fg := 4
        ELSE fg := 0
        END;
        T.SetCell(x, y, m.caption[i], fg, bg);
        DEC(w); INC(x); hl := FALSE
      END;
      INC(i)
    END;
    T.SetCell(x, y, ' ', 0, bg); INC(x);
    WHILE w > 0 DO
      T.SetCell(x, y, ' ', 0, bg);
      DEC(w); INC(x)
    END;
    IF m.status = disabled THEN fg := 8 ELSE fg := 0 END;
    IF m(Menu).hint[0] # 0X THEN
      T.Print(x - m(Menu).hintW - 1, y, -1, m(Menu).hint, fg, bg)
    ELSIF (m.children # NIL) & (m.y # 0) THEN
      T.SetCell(x - 2, y, T.triangleRight, fg, bg)
    END
  END
END DrawMenuCaption;

PROCEDURE DrawSubmenuFrame(x, y, w, h: INTEGER);
VAR i: INTEGER;
BEGIN
  T.Fill(x, y, 1, h, ' ', 0, 7);
  T.Fill(x + 1, y + 1, 1, h - 2, T.lineVert, 0, 7); (* | *)
  T.Fill(x + w - 2, y + 1, 1, h - 2, T.lineVert, 0, 7);
  T.Fill(x + w - 1, y, 1, h, ' ', 0, 7);
  T.Fill(x + 2, y, w - 4, h, ' ', 0, 7);
  T.Fill(x + 2, y, w - 4, 1, T.lineHor, 0, 7); (* - *)
  T.Fill(x + 2, y + h - 1, w - 4, 1, T.lineHor, 0, 7);
  T.SetCell(x + 1, y, T.lineDownRight, 0, 7); (* Corners *)
  T.SetCell(x + w - 2, y, T.lineDownLeft, 0, 7); (* Corners *)
  T.SetCell(x + w - 2, y + h - 1, T.lineUpLeft, 0, 7); (* Corners *)
  T.SetCell(x + 1, y + h - 1, T.lineUpRight, 0, 7); (* Corners *)
  FOR i := y + 1 TO y + h DO
    SetCharColor(x + w, i, 8, 0);
    SetCharColor(x + w + 1, i, 8, 0)
  END;
  FOR i := x + 2 TO x + w - 1 DO SetCharColor(i, y + h, 8, 0) END;
END DrawSubmenuFrame;

PROCEDURE MenuDraw(c: Control; x, y: INTEGER);
VAR p, openMenu: Control;
  w, h, tW, tH: INTEGER;
BEGIN T.Size(tW, tH); DrawMenuCaption(c, x, y);
  IF c.status = open THEN
    INC(x, c.x); INC(y, c.y);
    IF c.parent # c.app.menu THEN INC(x) END; (* 2nd+-level menus *)
    IF c.children # NIL THEN
      w := c(Menu).innerW; h := c(Menu).innerH;
      IF x + w + 3 > tW THEN x := tW - w - 3 END;
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
  IF p # NIL THEN p.status := selected END
RETURN p END FindSelectedChild;

PROCEDURE MenuHotkey*(c: Control; ch: CHAR): BOOLEAN;
VAR i: INTEGER; x: CHAR;
BEGIN i := 0; x := c.caption[0];
  WHILE (x # 0X) & ~((x = '&') & (c.caption[i + 1] # '&')) DO
    IF (x = '&') & (c.caption[i + 1] = '&') THEN INC(i, 2) ELSE INC(i) END;
    x := c.caption[i]
  END
RETURN (c.caption[i] # 0X) & (Cap(c.caption[i + 1]) = Cap(ch)) END MenuHotkey;

PROCEDURE MenuKeyDown*(c: Control; VAR E: T.Event);
VAR p, p2, br: Control; found: BOOLEAN;
BEGIN
  IF (E.key = T.kUp) OR (E.key = T.kDown) THEN
    IF c.parent # c.app.menu THEN p := c;
      REPEAT
        IF E.key = T.kUp THEN p := p.prev ELSE p := p.next END
      UNTIL (p = c) OR (p.caption # '-') & (p.status # disabled);
      c.status := normal; p.status := selected; SetFocus(p);
      NeedRedraw(c.app)
    END
  ELSIF (E.key = T.kLeft) OR (E.key = T.kRight) THEN p := c;
    WHILE p.parent # p.app.menu DO p := p.parent END;
    IF E.key = T.kLeft THEN p := p.prev ELSE p := p.next END;
    p.status := open;
    p2 := FindSelectedChild(p);
    IF p2 = NIL THEN p2 := p END;
    SetFocus(p2);
    NeedRedraw(c.app)
  ELSIF E.key = T.kEnter THEN c.do.click(c)
  ELSIF E.key = T.kEsc THEN
    IF (c.parent.parent = NIL) OR (c.parent.parent.parent = NIL) THEN
      c.parent.status := normal; UnsetFocus(c.app)
    ELSE c.parent.status := selected; SetFocus(c.parent)
    END;
    NeedRedraw(c.app)
  ELSE p := c;
    WHILE (p # NIL) & ~MenuHotkey(p, E.ch) DO
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
  T.HideCursor
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
            IF p.next = br THEN p := NIL ELSE p := p.next END
          END;
          IF p = NIL THEN menu := menu.parent; INC(y, menu.h) END
        UNTIL (menu = app.menu) OR (p # NIL);
        IF p # NIL THEN DEC(x, p.x); DEC(y, p.y) END
      END
    END
  END
RETURN p END GetMenuAt;

PROCEDURE GetStatusbarAt(app: App; x, y: INTEGER): Control;
VAR p, br: Control;
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  IF y = tH - 1 THEN
    p := app.statusbar.children; br := p;
    WHILE (p # NIL) & ~((p.x <= x) & (x < p.x + p.w)) DO
      IF p.next = br THEN p := NIL ELSE p := p.next END
    END
  ELSE p := NIL
  END
RETURN p END GetStatusbarAt;

PROCEDURE MenuMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
VAR p: Control;
BEGIN p := c;
  IF c = c.app.menu THEN c := GetMenuAt(c.app, x, y)
  ELSIF c = c.app.statusbar THEN c := GetStatusbarAt(c.app, x, y)
  END;
  IF (c = NIL) & (p = p.app.statusbar) THEN UnsetFocus(p.app)
  ELSIF (c # NIL) & (button = 1(*!FIXME LEFT BTN*)) & (c.status = normal) THEN
    IF c.parent.parent = NIL THEN (* Top level menu *)
      IF c.do.mouseDown # NIL THEN c.do.mouseDown(c, x, y, 1(*!FIXME LEFT*)) END
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
  IF (button = 1(*!FIXME LEFT BTN*)) & (c.status # disabled) THEN
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
  IF button = 1 THEN
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

(* Label *)

PROCEDURE InitLabel*(c: Label; caption: ARRAY OF CHAR);
BEGIN InitControl(c); c.do := labelMethod;
  c.caption := caption; c.len := Strings.Length(caption);
  c.align := left
END InitLabel;

PROCEDURE NewLabel*(caption: ARRAY OF CHAR): Label;
VAR c: Label;
BEGIN NEW(c); InitLabel(c, caption);
RETURN c END NewLabel;

PROCEDURE LabelDraw(c: Control; x, y: INTEGER);
VAR L: Label; X: INTEGER;
BEGIN L := c(Label); INC(x, c.x); INC(y, c.y); X := x;
  IF L.align = right THEN INC(X, c.w - L.len)
  ELSIF L.align = center THEN INC(X, (c.w - L.len) DIV 2)
  END;
  T.Print(X, y, x + c.w - 1, c.caption, 0, 7)
END LabelDraw;

(* LabelMethod *)

PROCEDURE InitLabelMethod*(m: ControlMethod);
BEGIN InitControlMethod(m);
  m.draw := LabelDraw
END InitLabelMethod;

(* QuickBtn *)

PROCEDURE InitQuickBtn*(c: QuickBtn; caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler);
BEGIN InitMenu(c, caption, hint, hotkey, onClick); c.do := quickBtnMethod
END InitQuickBtn;

PROCEDURE NewQuickBtn*(caption, hint: ARRAY OF CHAR;
    hotkey: INTEGER; onClick: ClickHandler): QuickBtn;
VAR c: QuickBtn;
BEGIN NEW(c); InitQuickBtn(c, caption, hint, hotkey, onClick) ;
RETURN c END NewQuickBtn;

PROCEDURE QuickBtnDraw(c: Control; x, y: INTEGER);
VAR i, w, bg, fg: INTEGER;
  hl: BOOLEAN; (* Highlighted letter *)
BEGIN INC(x, c.x); INC(y, c.y);
  IF c.status = normal THEN bg := 7 ELSE bg := 2 END;
  T.SetCell(x, y, ' ', 0, bg); INC(x); i := 0;
  WHILE c(Menu).hint[i] # 0X DO
    T.SetCell(x, y, c(Menu).hint[i], 4, bg);
    INC(x); INC(i)
  END;
  T.SetCell(x, y, ' ', 0, bg); INC(x); i := 0;
  WHILE c.caption[i] # 0X DO
    T.SetCell(x, y, c.caption[i], 0, bg);
    INC(x); INC(i)
  END;
  T.SetCell(x, y, ' ', 0, bg)
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
  c.caption := caption;
  c.do := buttonMethod
END InitButton;

PROCEDURE NewButton*(caption: ARRAY OF CHAR): Button;
VAR c: Button;
BEGIN NEW(c); InitButton(c, caption) ;
RETURN c END NewButton;

(* Button Method *)

PROCEDURE ButtonDraw*(c: Control; x, y: INTEGER);
VAR i, n, fg, bg: INTEGER;
BEGIN INC(x, c.x); INC(y, c.y);
  IF c.status = selected THEN INC(x) END;
  IF (c.parent # NIL) & (c.parent IS Window) THEN bg := c.parent(Window).bg
  ELSE bg := 7
  END;
  T.Fill(x, y, c.w, c.h, ' ', 0, 2);
  i := 0; n := 0;
  WHILE c.caption[i] # 0X DO IF c.caption[i] # '&' THEN INC(n) END; INC(i) END;
  IF n > c.w THEN n := c.w END;
  IF c.focused THEN fg := 15 ELSIF c.default THEN fg := 11 ELSE fg := 0 END;
  PutMarkedString(x + (c.w - n) DIV 2, y + c.h DIV 2,
    c.caption, fg, 14, 2, x + c.w - 1);
  IF c.status # selected THEN
    T.SetCell(x + c.w, y, T.lowerHalfBlock, 0, bg);
    T.Fill(x + c.w, y + 1, 1, c.h - 1, T.fullBlock, 0, bg);
    T.Fill(x + 1, y + c.h, c.w, 1, T.upperHalfBlock, 0, bg)
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

PROCEDURE ButtonMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
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
BEGIN NEW(c); InitWinBtn(c, ch) ;
RETURN c END NewWinBtn;

(* WinBtn Method *)

PROCEDURE WinBtnMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN
  IF c.status = selected THEN
    T.SetCell(c.app.dragX + 1, c.app.dragY,
      c.caption[0], 10, c.parent(Window).bg);
    IF c.do.click # NIL THEN c.do.click(c) END
  END
END WinBtnMouseUp;

PROCEDURE WinBtnMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
VAR status: INTEGER; ch: CHAR;
BEGIN status := c.status;
  ButtonMouseMove(c, x, y, button);
  IF status # c.status THEN
    IF c.status = normal THEN ch := c.caption[0] ELSE ch := 0FX(*star*) END;
    T.SetCell(c.app.dragX + 1, c.app.dragY, ch, 10, c.parent(Window).bg)
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
  c.w := 30; c.h := 1; c.cur := 0; c.onScrollbar := NIL;
  c.do := scrollbarMethod
END InitScrollbar;

PROCEDURE NewScrollbar*(): Scrollbar;
VAR c: Scrollbar;
BEGIN NEW(c); InitScrollbar(c) ;
RETURN c END NewScrollbar;

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
  IF S.enabled THEN ch := T.lightShade ELSE ch := T.mediumShade END;
  T.Fill(x + 1, y, S.w - 1, 1, ch, fg, bg);
  T.SetCell(x, y, T.triangleLeft, fg, bg);
  T.SetCell(x + S.w - 1, y, T.triangleRight, fg, bg);
  IF S.enabled THEN
    T.Fill(x + S.runnerOffset, y, S.runnerW, 1, T.mediumShade, fg, bg)
  END
END ScrollbarDraw;

PROCEDURE ScrollbarMouseDown*(c: Control; x, y, button: INTEGER);
VAR S: Scrollbar;
  col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF S.enabled & (button = 1(*!FIXME BTN LEFT*)) THEN
    SetDragged(S.app, S);
    ScrollbarUpdateCur(S, x, y, FALSE)
  END
END ScrollbarMouseDown;

PROCEDURE ScrollbarMouseUp*(c: Control; x, y, button: INTEGER);
VAR S: Scrollbar;
  col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF S.enabled & (button = 1(*!FIXME BTN LEFT*)) THEN
    ScrollbarUpdateCur(S, x, y, TRUE);
    SetFocus(S.parent)
  END
END ScrollbarMouseUp;

PROCEDURE ScrollbarMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
VAR S: Scrollbar;
  oldCur, col, colw: INTEGER;
BEGIN S := c(Scrollbar);
  IF button = 1 (*!FIXME BTN LEFT*) THEN ScrollbarUpdateCur(S, x, y, FALSE) END
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
BEGIN NEW(c); InitEdit(c) ;
RETURN c END NewEdit;

(* Edit Method *)

PROCEDURE EditSetCaption*(c: Edit; s: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN i := 0;
  WHILE (s[i] # 0X) & (i < LEN(c.caption) - 1) DO
    c.caption[i] := s[i]; INC(i)
  END;
  c.caption[i] := 0X; c.len := i; c.pos := i;
  NeedRedraw(c.app)
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
  T.SetCell(x, y, ' ', 0, 1);
  i := 0; j := x + 1;
  WHILE (e.caption[i] # 0X) & (i < e.w - 1) DO
    T.SetCell(j, y, e.caption[i], 15, 1); INC(i); INC(j)
  END;
  WHILE i < e.w - 1 DO
    T.SetCell(j, y, ' ', 15, 1); INC(i); INC(j)
  END;

  i := e.pos + 1; IF i >= e.w THEN i := e.w - 1 END;
  IF c.app.cur = c THEN T.SetCursor(x + i, y) END
END EditDraw;

PROCEDURE EditMouseDown*(c: Control; x, y, edit: INTEGER);
BEGIN (*!TODO*)
END EditMouseDown;

PROCEDURE EditKeyDown*(c: Control; VAR E: T.Event);
VAR e: Edit; redraw: BOOLEAN;
BEGIN e := c(Edit); redraw := TRUE;
  IF E.key = T.kLeft THEN
    IF e.pos > 0 THEN DEC(e.pos) END
  ELSIF E.key = T.kRight THEN
    IF e.pos < e.len THEN INC(e.pos) END
  ELSIF E.key = T.kBackspace THEN
    IF e.pos > 0 THEN DeleteChar(e.caption, e.pos - 1, e.len); DEC(e.pos) END
  ELSIF E.key = T.kDel THEN
    IF e.pos < e.len THEN DeleteChar(e.caption, e.pos, e.len) END
  ELSIF E.key = T.kHome THEN e.pos := 0
  ELSIF E.key = T.kEnd THEN e.pos := e.len
  ELSE redraw := FALSE
  END;
  IF redraw THEN NeedRedraw(c.app) END
END EditKeyDown;

PROCEDURE EditTextInput*(c: Control; ch: CHAR);
VAR e: Edit;
BEGIN
  IF ch # 0X THEN e := c(Edit);
    InsertChar(ch, e.pos, e.caption, e.len);
    IF e.pos < e.len THEN INC(e.pos) END;
    NeedRedraw(c.app)
  END
END EditTextInput;

PROCEDURE EditGetFocus*(c: Control);
BEGIN ControlGetFocus(c); T.SetCursor(c.x, c.y) (*!FIXME c.x, c.y correct???*)
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
  c.w := 30; c.h := 6; c.cur := 0; c.lastMouseDownItem := -1;
  c.scrollbar := NewScrollbar();
  Add(c, c.scrollbar);
  c.do.resize(c, 0, c.h - 1, c.w, 1);
  c.do := columnListMethod
END InitColumnList;

PROCEDURE NewColumnList*(): ColumnList;
VAR c: ColumnList;
BEGIN NEW(c); InitColumnList(c) ;
RETURN c END NewColumnList;

(* ColumnList Method *)

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
  IF C.cur # cur THEN C.cur := cur;
    IF C.onChange # NIL THEN C.onChange(C) END;
    NeedRedraw(C.app)
  END
END ColumnListSetCur;

PROCEDURE ColumnListDraw*(c: Control; x, y: INTEGER);
VAR i, x2, y2, colw, fg, bg: INTEGER;
  C: ColumnList;
  s: ARRAY 256 OF CHAR;
BEGIN C := c(ColumnList); INC(x, C.x); INC(y, C.y);
  bg := 3; x2 := x + 1; y2 := y;
  colw := (C.w - C.cols + 1) DIV C.cols;
  T.Fill(x, y, C.w, C.h - 1, ' ', 0, bg);

  (* Column separators *)
  i := x + colw;
  WHILE i < x + C.w - 2 DO
    T.Fill(i, y, 1, C.h - 1, T.lineVert, 1, bg); INC(i, colw + 1)
  END;

  i := C.scrollbar.cur * (C.h - 1);
  StrList.SetPos(C.items, i);
  StrList.Next(C.items, s);
  WHILE ~C.items.eol & (x2 + colw <= x + C.w) DO fg := 0; bg := 3;
    IF i = C.cur THEN
      IF C.focused THEN fg := 15; bg := 2;
        T.Fill(x2 - 1, y2, colw, 1, ' ', fg, bg)
      ELSE fg := 14
      END
    END;
    T.Print(x2, y2, x2 + colw - 1, s, fg, bg);
    IF y2 < y + C.h - 2 THEN INC(y2) ELSE y2 := y; INC(x2, colw + 1) END;
    StrList.Next(C.items, s); INC(i)
  END;

  DrawChildren(c, x - C.x, y - C.y)
END ColumnListDraw;

PROCEDURE ColumnListGetFocus*(c: Control);
BEGIN ControlGetFocus(c)
END ColumnListGetFocus;

PROCEDURE ColumnListUpdateCur*(C: ColumnList; x, y: INTEGER);
VAR h, cur, col, colw, count: INTEGER;
BEGIN h := C.h - 1;
  IF (x < 0) OR (x >= C.w) THEN
    (*!TODO autoscroll*)
    (*IF ... THEN NeedRedraw(C.app) END*)
  ELSIF y # h THEN cur := C.cur;
    IF y < 0 THEN (* Scroll to top within column *)
      cur := (cur DIV h) * h
    ELSIF y >= C.h THEN (* Scroll to bottom within column *)
      cur := cur DIV h * h + h - 1
    ELSE
      colw := (C.w - C.cols + 1) DIV C.cols;
      col := x DIV (colw + 1);
      cur := col * h + y + C.scrollbar.cur * h
    END;
    count := StrList.Count(C.items);
    IF cur >= count THEN cur := count - 1 END;
    ColumnListSetCur(C, cur)
  END
END ColumnListUpdateCur;

PROCEDURE ColumnListMouseDown*(c: Control; x, y, button: INTEGER);
VAR C: ColumnList;
  col, colw, n: INTEGER;
BEGIN C := c(ColumnList);
  IF ~PassMouseDown(C, x, y, button) &
      (C.parent # NIL) & (C.parent IS Window) THEN
    C.status := selected;
    SetDragged(C.app, C);
    ColumnListUpdateCur(C, x, y);

    n := ticks;
    IF (n - C.app.lastMouseDownTime <= dblClickDelay) &
       (C.lastMouseDownItem = C.cur)
    THEN
      IF C.do.dblClick # NIL THEN C.do.dblClick(C) END;
      C.app.lastMouseDownTime := 0
    ELSE C.app.lastMouseDownTime := n;
      C.lastMouseDownItem := C.cur;
      NeedRedraw(C.app)
    END

  END
END ColumnListMouseDown;

PROCEDURE ColumnListMouseUp*(c: Control; x, y, button: INTEGER);
BEGIN ControlMouseUp(c, x, y, button);
  IF (c.status = selected) & (c.do.click # NIL) THEN c.do.click(c) END
END ColumnListMouseUp;

PROCEDURE ColumnListMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
VAR C: ColumnList;
  oldCur, col, colw: INTEGER;
BEGIN ControlMouseMove(c, x, y, button); C := c(ColumnList);
  IF button = 1 THEN ColumnListUpdateCur(C, x, y) END
END ColumnListMouseMove;

PROCEDURE ColumnListKeyDown*(c: Control; VAR E: T.Event);
VAR C: ColumnList; sb: Scrollbar;
  h, cur: INTEGER;
BEGIN C := c(ColumnList); sb := C.scrollbar; cur := C.cur; h := C.h - 1;
  IF E.key = T.kLeft THEN DEC(cur, h)
  ELSIF E.key = T.kRight THEN INC(cur, h)
  ELSIF E.key = T.kUp THEN DEC(cur)
  ELSIF E.key = T.kDown THEN INC(cur)
  ELSIF E.key = T.kHome THEN cur := sb.cur * h
  ELSIF E.key = T.kEnd THEN cur := (sb.cur + C.cols) * h - 1
  ELSIF E.key = T.kPgUp THEN DEC(cur, C.cols * h); DEC(sb.cur, C.cols)
  ELSIF E.key = T.kPgDn THEN INC(cur, C.cols * h); INC(sb.cur, C.cols)
  END;
  ColumnListSetCur(C, cur)
END ColumnListKeyDown;

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
VAR s: ARRAY 3 OF CHAR; n: INTEGER;
BEGIN StrList.First(L, s); n := 0;
  WHILE ~L.eol & ~((Cap(s[0]) = ch) OR (s[0] = '[') & (Cap(s[1]) = ch)) DO
    StrList.Next(L, s); INC(n)
  END;
  IF L.eol THEN n := -1 END
RETURN n END FindFirstLetterInList;

PROCEDURE ColumnListTextInput*(c: Control; ch: CHAR);
VAR C: ColumnList; n: INTEGER;
BEGIN C := c(ColumnList);
  IF ch # 0X THEN
    n := FindFirstLetterInList(C.items, Cap(ch));
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
  tW, tH: INTEGER;
BEGIN T.Size(tW, tH); w := c.app.windows(Window);
  IF w # NIL THEN
    IF (w.x = 0) & (w.w = tW) &
       (w.y = 1) & (w.h = tH - 2) THEN
      w.x := w.mx; w.y := w.my; w.w := w.mw; w.h := w.mh
    ELSE
      w.mx := w.x; w.my := w.y; w.mw := w.w; w.mh := w.h;
      w.x := 0; w.w := tW;
      w.y := 1; w.h := tH - 2
    END;
    NeedRedraw(c.app)
  END
END ZoomCurWindow;

PROCEDURE CloseCurWindowEx*(c: Control; VAR cancel: BOOLEAN);
VAR w: Window;
BEGIN w := c.app.windows; cancel := FALSE;
  IF w # NIL THEN
    IF w.do.close # NIL THEN w.do.close(w, cancel) END;
    IF ~cancel THEN
      IF w.next = w THEN c.app.windows := NIL
      ELSE
        w.prev.next := w.next;
        w.next.prev := w.prev;
        c.app.windows := w.prev(Window)
      END;
      SetAppFocus(c.app, c.app.windows);
      NeedRedraw(c.app)
    END
  END
END CloseCurWindowEx;

PROCEDURE CloseCurWindow*(c: Control);
VAR cancel: BOOLEAN;
BEGIN CloseCurWindowEx(c, cancel)
END CloseCurWindow;

PROCEDURE CloseAllWindows*(c: Control);
VAR cancel: BOOLEAN;
BEGIN cancel := FALSE;
  WHILE ~cancel & (c.app.windows # NIL) DO CloseCurWindowEx(c, cancel) END
END CloseAllWindows;

PROCEDURE RefreshDisplay*(c: Control);
BEGIN T.ClearTo(0, 7); NeedRedraw(c.app); c.app.sync := TRUE
END RefreshDisplay;

(* Window *)

PROCEDURE InitWindow*(w: Window);
VAR tW, tH: INTEGER;
BEGIN InitControl(w); T.Size(tW, tH);
  w.cur := NIL;
  w.x := 0; w.y := 1;
  w.w := tW; w.h := tH - 2;
  w.mx := 0; w.my := 1; w.mw := w.w; w.mh := w.h;
  w.modal := FALSE; w.resizable := FALSE;
  w.closeable := TRUE; w.closeOnEsc := TRUE;
  w.bg := 7; w.minW := 10; w.minH := 3;
  w.closeBtn := NewWinBtn(T.blackSquare); (* Square *)
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
VAR tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  c.x := (tW - c.w) DIV 2; c.y := (tH - c.h - 1) DIV 2;
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
  T.Fill(c.x + 1, c.y + 1,
    c.w - 2, c.h - 2, ' ', 15, c(Window).bg);
  DrawWindowBorder(c.x, c.y, c.w, c.h, 15,
    c(Window).bg, c.caption, c(Window).resizable,
    c.status # normal, c # c.app.windows);
  DrawChildren(c, x, y)
END WindowDraw;

PROCEDURE WindowRefresh*(c: Control);
VAR tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  IF c(Window).zoomBtn # NIL THEN
    IF (c.x = 0) & (c.w = tW) & (c.y = 1) & (c.h = tH - 2) THEN
      c(Window).zoomBtn.caption[0] := 12X
    ELSE c(Window).zoomBtn.caption[0] := 18X
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
  T.SetCell(c.x + 3, c.y, 0FX, 10, c(Window).bg) (* star *)
END WindowCloseMouseDown;

PROCEDURE WindowZoomMouseDown(c: Control);
BEGIN c.app.dragged := c(Window).zoomBtn;
  c(Window).zoomBtn.status := selected;
  c(Window).zoomBtn.x := c.w - 5;
  c.app.dragX := c.x + c.w - 5; c.app.dragY := c.y;
  T.SetCell(c.x + c.w - 4, c.y, 0FX, 10, c(Window).bg) (* star *)
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
  IF button # 2 THEN
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

PROCEDURE WindowMouseMove*(c: Control; x, y: INTEGER; button: INTEGER);
VAR tW, tH: INTEGER;
BEGIN T.Size(tW, tH);
  IF c.status = moving THEN
    c.x := x + c(Window).mx; c.y := y + c.app.dragY;
    IF c.y < 1 THEN c.y := 1 END;
    IF c.do.refresh # NIL THEN c.do.refresh(c) END;
    NeedRedraw(c.app)
  ELSIF c.status = resizing THEN
    c.w := x + c(Window).mx; c.h := y + 1;
    IF c.w < c(Window).minW THEN c.w := c(Window).minW
    ELSIF c.w > tW THEN c.w := tW
    END;
    IF c.h < c(Window).minH THEN c.h := c(Window).minH
    ELSIF c.h > tH - 2 THEN c.h := tH - 2
    END;
    IF c.do.refresh # NIL THEN c.do.refresh(c) END;
    NeedRedraw(c.app)
  END
END WindowMouseMove;

PROCEDURE FindDefaultControl(c: Control): Control;
VAR p, br: Control;
BEGIN p := c.children;
  IF p # NIL THEN br := p;
    REPEAT p := p.next UNTIL (p = br) OR p.default;
    IF ~p.default THEN p := NIL END
  END
RETURN p END FindDefaultControl;

PROCEDURE WindowKeyDown*(c: Control; VAR E: T.Event);
VAR d: Control;
BEGIN
  IF E.key = T.kEsc THEN
    IF c(Window).closeOnEsc THEN CloseCurWindow(c) END
  ELSIF E.key = T.kEnter THEN
    d := FindDefaultControl(c);
    IF (d # NIL) & (d.do.click # NIL) THEN d.do.click(d) END
  END
END WindowKeyDown;

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
  m.keyDown := WindowKeyDown;
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
  app.lastMouseDownTime := 0;
  app.quit := FALSE;
  app.needRedraw := TRUE;
  app.sync := TRUE;
  app.mouseBtn := 0
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
BEGIN Strings.Extract(text, 0, LEN(app.statusText), app.statusText)
END SetStatusText;

PROCEDURE CheckMenuOpenKey(app: App; VAR E: T.Event): BOOLEAN;
VAR p, q, br: Control; found: BOOLEAN;
BEGIN found := FALSE;
  IF ('a' <= E.ch) & (E.ch <= 'z') & ~HasModalWindow(app) THEN
    p := app.menu.children.prev; br := p;
    REPEAT p := p.next; found := MenuHotkey(p(Menu), E.ch)
    UNTIL found OR (p = br);
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

PROCEDURE CheckHotkey(app: App; VAR E: T.Event): BOOLEAN;
VAR m: Menu;
  hotkey: INTEGER;
  handled: BOOLEAN;
BEGIN handled := FALSE; hotkey := E.key;
  IF (hotkey # 0) & ~HasModalWindow(app) THEN
    IF T.mCtrl IN E.mod THEN INC(hotkey, 100H) END;
    IF E.mod * {T.mMenu, T.mAlt, T.mAltGr} # {} THEN INC(hotkey, 200H) END;
    IF T.mShift IN E.mod THEN INC(hotkey, 400H) END;
    m := FindMenuWithHotkey(app.menu, hotkey);
    IF m # NIL THEN handled := TRUE;
      IF m.do.click # NIL THEN m.do.click(m) END
    END
  END;
  RETURN handled
END CheckHotkey;

PROCEDURE FindNextTabControl(p: Control; back: BOOLEAN): Control;
VAR br, next: Control;
  t, nextT: INTEGER;
BEGIN t := p.tabIndex; next := NIL;
  IF back THEN nextT := minInt ELSE nextT := maxInt END;
  br := p; p := p.next;
  WHILE p # br DO
    IF ~back & (p.tabIndex >= t) & (p.tabIndex < nextT) OR
        back & (p.tabIndex <= t) & (p.tabIndex > nextT)
    THEN next := p; nextT := p.tabIndex
    END;
    p := p.next
  END;
  IF next = NIL THEN
    IF back THEN
      nextT := minInt;
      REPEAT
        IF p.tabIndex > nextT THEN next := p; nextT := p.tabIndex END;
        p := p.next
      UNTIL p = br
    ELSE
      nextT := maxInt;
      REPEAT
        IF p.tabIndex < nextT THEN next := p; nextT := p.tabIndex END;
        p := p.next
      UNTIL p = br
    END
  END
RETURN next END FindNextTabControl;

PROCEDURE OnTabPress(app: App; back: BOOLEAN): BOOLEAN;
VAR p: Control;
  worked: BOOLEAN;
BEGIN worked := FALSE; p := app.cur;
  IF p # NIL THEN p := FindNextTabControl(p, back);
    IF (p # NIL) & (p # app.cur) & ~(p IS Window) THEN
      SetAppFocus(app, p);
      worked := TRUE
    END
  END
RETURN worked END OnTabPress;

PROCEDURE OnKey(app: App; VAR E: T.Event);
VAR handled: BOOLEAN; p: Control;
BEGIN handled := FALSE; p := app.cur;
  IF (E.mod * {T.mCtrl, T.mShift, T.mAlt, T.mAltGr, T.mMenu} # {}) OR
     (T.kF1 <= E.key) & (E.key <= T.kF12) OR (E.key = T.kPause)
  THEN handled := CheckHotkey(app, E);
    IF ~handled & (E.mod * {T.mAlt, T.mAltGr, T.mMenu} # {}) THEN
      handled := CheckMenuOpenKey(app, E)
    END
  END;
  IF ~handled & (p # NIL) &
     ((E.key # T.kTab) OR ~OnTabPress(app, T.mShift IN E.mod))
  THEN
    IF p.do.keyDown # NIL THEN p.do.keyDown(p, E) END;
    IF (p.parent # NIL) & (p.parent IS Window) &
       (p.parent.do.keyDown # NIL) THEN
      p.parent.do.keyDown(p.parent, E)
    END
  END;
  IF ~handled & (E.ch >= 20X) & (E.ch # 07FX) THEN
    IF p.do.textInput # NIL THEN p.do.textInput(p, E.ch) END
  END
END OnKey;

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

PROCEDURE OnMouse(app: App; VAR E: T.Event);
VAR c: Control;
  btn: INTEGER;
BEGIN
  IF E.button = 0 THEN (* Release mouse *)
    btn := app.mouseBtn; app.mouseBtn := 0;
    IF app.dragged # NIL THEN c := app.dragged
    ELSE c := GetControlAt(app, E.x, E.y);
      IF HasModalWindow(app) & (c # app.windows) THEN c := NIL END
    END;
    app.dragged := NIL;
    IF (c # NIL) & (c.do.mouseUp # NIL) THEN
      c.do.mouseUp(c, E.x - app.dragX, E.y - app.dragY, btn)
    END
  ELSIF app.mouseBtn = 0 THEN (* Mouse down event *)
    app.mouseBtn := E.button;
    IF app.dragged = NIL THEN
      c := GetControlAt(app, E.x, E.y);
      IF c = NIL THEN UnsetFocus(app)
      ELSIF (c.do.mouseDown # NIL) &
            (~HasModalWindow(app) OR (c = app.windows)) THEN
        SetDragged(app, c);
        c.do.mouseDown(c, E.x - c.x, E.y - c.y, E.button)
      END
    END
  ELSE (* Drag *)
    c := app.dragged;
    IF (c # NIL) & (c.do.mouseMove # NIL) THEN
      c.do.mouseMove(c, E.x - app.dragX, E.y - app.dragY, E.button)
    END
  END
END OnMouse;

PROCEDURE OnResize(app: App; E: T.Event);
BEGIN
  app.needRedraw := TRUE
END OnResize;

PROCEDURE RunApp*(app: App);
VAR E: T.Event;
  break: BOOLEAN;
BEGIN
  ticks := 0;
  T.StartTimer(1/4);
  app.quit := FALSE;
  DrawApp(app); T.Flush;
  REPEAT
    break := FALSE;
    REPEAT
      T.WaitEvent(E);
      IF E.type = T.mouse THEN OnMouse(app, E)
      ELSIF E.type = T.timer THEN INC(ticks); break := TRUE
      ELSIF E.type = T.key THEN OnKey(app, E)
      ELSIF E.type = T.resize THEN OnResize(app, E)
      ELSIF E.type = T.quit THEN app.quit := TRUE
      END
    UNTIL break OR ~T.HasEvents();
    IF app.needRedraw THEN
      DrawApp(app);
      IF app.sync THEN T.Sync; app.sync := FALSE ELSE T.Flush END
    END
  UNTIL app.quit
END RunApp;

BEGIN
  NEW(controlMethod); InitControlMethod(controlMethod);
  NEW(labelMethod); InitLabelMethod(labelMethod);
  NEW(quickBtnMethod); InitQuickBtnMethod(quickBtnMethod);
  NEW(buttonMethod); InitButtonMethod(buttonMethod);
  NEW(winBtnMethod); InitWinBtnMethod(winBtnMethod);
  NEW(scrollbarMethod); InitScrollbarMethod(scrollbarMethod);
  NEW(editMethod); InitEditMethod(editMethod);
  NEW(columnListMethod); InitColumnListMethod(columnListMethod);
  NEW(windowMethod); InitWindowMethod(windowMethod);
  NEW(menuMethod); InitMenuMethod(menuMethod)
END OV.
