/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"
#include "Texts.h"


static Texts_Writer testTexts_W;
static Texts_Text testTexts_T;
static Texts_Reader testTexts_R;
static CHAR testTexts_ch;
static INT16 testTexts_i;
static CHAR testTexts_s[1024];




static void EnumPtrs(void (*P)(void*))
{
	__ENUMR(&testTexts_W, Texts_Writer__typ, 36, 1, P);
	P(testTexts_T);
	__ENUMR(&testTexts_R, Texts_Reader__typ, 48, 1, P);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(Texts);
	__REGMAIN("testTexts", EnumPtrs);
/* BEGIN */
	Texts_OpenWriter(&testTexts_W, Texts_Writer__typ);
	Texts_WriteString(&testTexts_W, Texts_Writer__typ, (CHAR*)"aaa", 4);
	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
	Texts_WriteReal(&testTexts_W, Texts_Writer__typ,  -3.1114151e+002, 7);
	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
	Texts_WriteRealFix(&testTexts_W, Texts_Writer__typ,  -3.1114151e+002, 0, 7);
	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
	Texts_WriteLongReal(&testTexts_W, Texts_Writer__typ,  -3.11141510009766e+002, 7);
	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
	__NEW(testTexts_T, Texts_TextDesc);
	Texts_Open(testTexts_T, (CHAR*)"test.txt", 9);
	Texts_Append(testTexts_T, testTexts_W.buf);
	Texts_OpenReader(&testTexts_R, Texts_Reader__typ, testTexts_T, 0);
	Texts_Read(&testTexts_R, Texts_Reader__typ, &testTexts_ch);
	testTexts_i = 0;
	while (!testTexts_R.eot) {
		if (testTexts_ch == 0x0d) {
			testTexts_s[__X(testTexts_i, 1024)] = 0x00;
			testTexts_i = 0;
			Console_String(testTexts_s, 1024);
			Console_Ln();
		} else {
			testTexts_s[__X(testTexts_i, 1024)] = testTexts_ch;
			testTexts_i += 1;
		}
		Texts_Read(&testTexts_R, Texts_Reader__typ, &testTexts_ch);
	}
	testTexts_s[__X(testTexts_i, 1024)] = 0x00;
	__FINI;
}
