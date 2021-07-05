/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"
#include "LSB.h"
#include "LSC.h"
#include "LSV.h"
#include "Modules.h"







export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__MODULE_IMPORT(LSB);
	__MODULE_IMPORT(LSC);
	__MODULE_IMPORT(LSV);
	__MODULE_IMPORT(Modules);
	__REGMAIN("Lola", 0);
/* BEGIN */
	if (Modules_ArgCount < 3) {
		Console_String((CHAR*)"Lola - compile lola source to verilog source.", 46);
		Console_Ln();
		Console_Ln();
		Console_String((CHAR*)"usage:", 7);
		Console_Ln();
		Console_Ln();
		Console_String((CHAR*)"  lola lola-source-file verilog-source-file", 44);
		Console_Ln();
		Console_Ln();
	} else {
		LSC_Compile();
		if (LSB_modname[0] != 0x00) {
			LSV_List();
		}
	}
	__FINI;
}
