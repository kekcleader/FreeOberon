/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"


static CHAR aa_a30[30];
static CHAR aa_a10[10];
static CHAR aa_a20[20];
static CHAR aa_buf[64];





export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__REGMAIN("aa", 0);
/* BEGIN */
	__MOVE("1st 10 ch 2nd 10 ch 3rd 10 ch", aa_a30, 30);
	Console_String((CHAR*)"a30: ", 6);
	Console_String(aa_a30, 30);
	Console_Ln();
	__COPY(aa_a30, aa_a20, 20);
	Console_String((CHAR*)"a20: ", 6);
	Console_String(aa_a20, 20);
	Console_Ln();
	Console_Ln();
	__COPY(aa_a30, aa_a10, 10);
	Console_String((CHAR*)"a10: ", 6);
	Console_String(aa_a10, 10);
	Console_Ln();
	Console_String((CHAR*)"a20: ", 6);
	Console_String(aa_a20, 20);
	Console_Ln();
	Console_Ln();
	Console_String((CHAR*)"Array assignment test complete.", 32);
	Console_Ln();
	__FINI;
}
