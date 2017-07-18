/* voc 2.1.0 [2017/07/08] for gcc LP64 on debian xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"
#include "Files.h"
#include "Modules.h"
#include "Platform.h"


static Files_File SignalTest_result;
static Files_Rider SignalTest_rider;


static void SignalTest_Take5 (INT16 i);
static void SignalTest_handle (INT32 signal);
static void SignalTest_wi (INT32 i);
static void SignalTest_wl (void);
static void SignalTest_ws (CHAR *s, ADDRESS s__len);


static void SignalTest_ws (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	__DUP(s, s__len, CHAR);
	i = 0;
	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(i, s__len)]);
		i += 1;
	}
	__DEL(s);
}

static void SignalTest_wl (void)
{
	Files_Write(&SignalTest_rider, Files_Rider__typ, 0x0a);
}

static void SignalTest_wi (INT32 i)
{
	CHAR s[30];
	INT16 j;
	j = 0;
	if (i < 0) {
		s[0] = '-';
		j += 1;
	}
	s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
	j += 1;
	i = __DIV(i, 10);
	while (i > 0) {
		s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
		j += 1;
		i = __DIV(i, 10);
	}
	while (j > 0) {
		j -= 1;
		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(j, 30)]);
	}
}

static void SignalTest_handle (INT32 signal)
{
	Console_Ln();
	Console_String((CHAR*)"Signal: ", 9);
	Console_Int(signal, 1);
	Console_Ln();
	SignalTest_ws((CHAR*)"Signal ", 8);
	SignalTest_wi(signal);
	SignalTest_wl();
}

static void SignalTest_Take5 (INT16 i)
{
	while (i > 0) {
		Console_Int(i, 2);
		Console_Flush();
		Platform_Delay(1000);
		i -= 1;
	}
	Console_Ln();
}

static void EnumPtrs(void (*P)(void*))
{
	P(SignalTest_result);
	__ENUMR(&SignalTest_rider, Files_Rider__typ, 24, 1, P);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(Files);
	__MODULE_IMPORT(Modules);
	__MODULE_IMPORT(Platform);
	__REGMAIN("SignalTest", EnumPtrs);
/* BEGIN */
	SignalTest_result = Files_New((CHAR*)"result", 7);
	Files_Set(&SignalTest_rider, Files_Rider__typ, SignalTest_result, 0);
	if (Modules_ArgCount > 1) {
		Platform_SetInterruptHandler(SignalTest_handle);
		Platform_SetQuitHandler(SignalTest_handle);
	}
	SignalTest_Take5(4);
	Files_Register(SignalTest_result);
	__FINI;
}
