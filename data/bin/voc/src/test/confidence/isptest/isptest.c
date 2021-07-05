/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */

#define SHORTINT INT16
#define INTEGER  INT32
#define LONGINT  INT64
#define SET      UINT32

#include "SYSTEM.h"
#include "Files.h"
#include "Out.h"
#include "Platform.h"
#include "Texts.h"


static Texts_Text isptest_T;
static Texts_Reader isptest_R;
static CHAR isptest_ch;
static INT64 isptest_i, isptest_j, isptest_k;




static void EnumPtrs(void (*P)(void*))
{
	P(isptest_T);
	__ENUMR(&isptest_R, Texts_Reader__typ, 96, 1, P);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Files);
	__MODULE_IMPORT(Out);
	__MODULE_IMPORT(Platform);
	__MODULE_IMPORT(Texts);
	__REGMAIN("isptest", EnumPtrs);
/* BEGIN */
	__NEW(isptest_T, Texts_TextDesc);
	if (Files_Old((CHAR*)"isptest.mod", 12) != NIL) {
		Texts_Open(isptest_T, (CHAR*)"isptest.mod", 12);
		Texts_OpenReader(&isptest_R, Texts_Reader__typ, isptest_T, 0);
		Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
		while (!isptest_R.eot) {
			Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
			isptest_i = Texts_Pos(&isptest_R, Texts_Reader__typ);
			Out_String((CHAR*)"pos=", 5);
			Out_Int(isptest_i, 0);
			Out_String((CHAR*)" char=", 7);
			Out_Char(isptest_ch);
			Out_Char(0x0a);
			if (isptest_i == 21906) {
				Out_String((CHAR*)"21906", 6);
				Out_Char(0x0a);
			}
		}
	}
	__FINI;
}
