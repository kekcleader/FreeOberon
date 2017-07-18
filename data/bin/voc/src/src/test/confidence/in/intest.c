/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT16
#define INTEGER  INT32
#define LONGINT  INT64
#define SET      UINT64

#include "SYSTEM.h"
#include "In.h"
#include "Out.h"


static CHAR intest_ch;
static INT32 intest_i;
static CHAR intest_s[100];





export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(In);
	__MODULE_IMPORT(Out);
	__REGMAIN("intest", 0);
/* BEGIN */
	In_Char(&intest_ch);
	Out_String((CHAR*)"chars:   ", 10);
	while ((In_Done && intest_ch != '.')) {
		Out_Char(intest_ch);
		In_Char(&intest_ch);
	}
	Out_Ln();
	In_Int(&intest_i);
	if (In_Done) {
		Out_String((CHAR*)"integer: ", 10);
		Out_Int(intest_i, 1);
		Out_Ln();
	}
	In_String((void*)intest_s, 100);
	if (In_Done) {
		Out_String((CHAR*)"string:  \"", 11);
		Out_String(intest_s, 100);
		Out_String((CHAR*)"\"", 2);
		Out_Ln();
	}
	In_Line((void*)intest_s, 100);
	while (In_Done) {
		Out_String((CHAR*)"line:    ", 10);
		Out_String(intest_s, 100);
		Out_Ln();
		In_Line((void*)intest_s, 100);
	}
	__FINI;
}
