MODULE newt;

IMPORT SYSTEM;

CONST

NEWTvCOLORSETvROOT *=			2;
NEWTvCOLORSETvBORDER *=			3;
NEWTvCOLORSETvWINDOW*=			4;
NEWTvCOLORSETvSHADOW*=			5;
NEWTvCOLORSETvTITLE*=			6;
NEWTvCOLORSETvBUTTON*=			7;
NEWTvCOLORSETvACTBUTTON*=		8;
NEWTvCOLORSETvCHECKBOX*=		9;
NEWTvCOLORSETvACTCHECKBOX*=		10;
NEWTvCOLORSETvENTRY*=			11;
NEWTvCOLORSETvLABEL*=			12;
NEWTvCOLORSETvLISTBOX*=			13;
NEWTvCOLORSETvACTLISTBOX*=		14;
NEWTvCOLORSETvTEXTBOX*=			15;
NEWTvCOLORSETvACTTEXTBOX*=		16;
NEWTvCOLORSETvHELPLINE*=		17;
NEWTvCOLORSETvROOTTEXT*=		18;
NEWTvCOLORSETvEMPTYSCALE*=		19;
NEWTvCOLORSETvFULLSCALE*=		20;
NEWTvCOLORSETvDISENTRY*=		21;
NEWTvCOLORSETvCOMPACTBUTTON*=		22;
NEWTvCOLORSETvACTSELLISTBOX*=		23;
NEWTvCOLORSETvSELLISTBOX*=		24;

NEWTvARGvLAST*=				-100000;
NEWTvARGvAPPEND*=			-1;


TYPE Int32* = INTEGER;
     Int64* = LONGINT;

     ComponentStruct* = RECORD
        height*, width*,
	top*, left*,
	takesFocus*,
	isMapped*: Int32
     END;

     Component* = POINTER TO ComponentStruct;

     ExitStruct* = RECORD
        reason*: Int32;
	watch*, key*: Int32;
	co* : Component;
     END;

PROCEDURE -newtInit(): Int32
   "newtInit()";

PROCEDURE Init*(): Int32;
BEGIN
   RETURN newtInit();
END Init;

PROCEDURE -newtCls()
   "newtCls()";

PROCEDURE Cls*();
BEGIN
   newtCls
END Cls;

PROCEDURE -newtFinished() : Int32
   "newtFinished()";

PROCEDURE Finished*(): Int32;
BEGIN
   RETURN newtFinished();
END Finished;

PROCEDURE -newtResizeScreen(redraw: Int32)
   "newtResizeScreen(redraw)";

PROCEDURE ResizeScreen*(redraw : Int32);
BEGIN
   newtResizeScreen(redraw);
END ResizeScreen;

PROCEDURE -newtRefresh()
   "newtRefresh()";

PROCEDURE Refresh*();
BEGIN
   newtRefresh();
END Refresh;

PROCEDURE -newtWaitForKey()
   "newtWaitForKey()";

PROCEDURE WaitForKey*();
BEGIN
   newtWaitForKey
END WaitForKey;

PROCEDURE -newtGetKey(): Int32
   "newtGetKey()";

PROCEDURE GetKey*(): CHAR;
VAR i : Int32;
BEGIN
   i:= newtGetKey();
   RETURN CHR(SHORT(i));
END GetKey;

PROCEDURE -newtClearKeyBuffer()
   "newtClearKeyBuffer()";

PROCEDURE ClearKeyBuffer*();
BEGIN
   newtClearKeyBuffer
END ClearKeyBuffer;

PROCEDURE -newtDelay(i : Int32)
   "newtDelay(i)";

PROCEDURE Delay*(i : Int32);
BEGIN
   newtDelay(i)
END Delay;

PROCEDURE -newtDrawRootText(left, top: Int32; VAR text: ARRAY OF CHAR)
   "newtDrawRootText(left, top, text)";

PROCEDURE DrawRootText*(left, top: Int32; text: ARRAY OF CHAR);
BEGIN
   newtDrawRootText(left, top, text)
END DrawRootText;

PROCEDURE -newtPushHelpLine(VAR text: ARRAY OF CHAR)
   "newtPushHelpLine(text)";

PROCEDURE PushHelpLine*(text : ARRAY OF CHAR);
BEGIN
   newtPushHelpLine(text)
END PushHelpLine;

PROCEDURE -newtPopHelpLine()
   "newtPopHelpLine()";

PROCEDURE PopHelpLine*();
BEGIN
   newtPopHelpLine();
END PopHelpLine;

PROCEDURE -newtSuspend()
   "newtSuspend()";

PROCEDURE Suspend*();
BEGIN
   newtSuspend()
END Suspend;

PROCEDURE -newtResume()
   "newtResume()";

PROCEDURE Resume*;
BEGIN
   newtResume()
END Resume;

PROCEDURE -newtBell()
   "newtBell()";

PROCEDURE Bell*();
BEGIN newtBell() END Bell;

PROCEDURE -newtGetScreenSize(VAR cols, rows: Int32)
   "newtGetScreenSize(cols, rows)";

PROCEDURE GetScreenSize*(VAR cols, rows: Int32);
BEGIN 
newtGetScreenSize(cols, rows)
END GetScreenSize;

PROCEDURE -newtCenteredWindow(width, height: Int32; title: ARRAY OF CHAR): Int32
   "newtCenteredWindow(width, height, title)";

PROCEDURE CenteredWindow*(width, height: Int32; title: ARRAY OF CHAR): Int32;
BEGIN
   RETURN newtCenteredWindow(width, height, title)
END CenteredWindow;

PROCEDURE -newtOpenWindow(left, top, width, height: Int32; title: ARRAY OF CHAR): Int32
   "newtOpenWindow(left, top, width, height, title)";

PROCEDURE OpenWindow*(left, top, width, height: Int32; title: ARRAY OF CHAR): Int32;
BEGIN
   RETURN newtOpenWindow(left, top, width, height, title)
END OpenWindow;

PROCEDURE -newtPopWindow()
   "newtPopWindow()";

PROCEDURE PopWindow*();
BEGIN
   newtPopWindow
END PopWindow;

PROCEDURE -newtForm(vertBar: Component; help: ARRAY OF CHAR; flags: Int32): Component
   "newtForm(vertBar, help, flags)";

PROCEDURE Form*(vertBar: Component; help: ARRAY OF CHAR; flags: Int32): Component;
BEGIN
   RETURN newtForm(vertBar, help, flags);
END Form;

PROCEDURE -newtFormAddComponent(form, co: Component)
   "newtFormAddComponent(form, co)";

PROCEDURE FormAddComponent*(form, co: Component);
BEGIN
   newtFormAddComponent(form, co);
END FormAddComponent;

PROCEDURE -newtRunForm(form: Component): Component
   "newtRunForm(form)";

PROCEDURE RunForm*(form: Component): Component; (* obsolete *)
BEGIN
   RETURN newtRunForm(form)
END RunForm;

PROCEDURE -newtFormRun(co: Component; VAR es: ExitStruct)
   "newtFormRun(co, es)";

PROCEDURE FormRun*(co: Component; VAR es: ExitStruct);
BEGIN
   newtFormRun(co, es)
END FormRun;

PROCEDURE -newtFormDestroy(form: Component)
   "newtFormDestroy(form)";

PROCEDURE FormDestroy*(form: Component);
BEGIN
   newtFormDestroy(form)
END FormDestroy;

PROCEDURE -newtButton(left, top: Int32; text: ARRAY OF CHAR): Component
   "newtButton(left, top, text)";

PROCEDURE Button*(left, top: Int32; text: ARRAY OF CHAR): Component;
BEGIN
   RETURN newtButton(left, top, text)
END Button;

PROCEDURE -newtCompactButton(left, top: Int32; text: ARRAY OF CHAR): Component
   "newtCompactButton(left, top, text)";

PROCEDURE CompactButton*(left, top: Int32; text: ARRAY OF CHAR): Component;
BEGIN
   RETURN newtCompactButton(left, top, text);
END CompactButton;

BEGIN




END newt.
