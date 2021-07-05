/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"







export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__REGMAIN("hello", 0);
/* BEGIN */
	Console_String((CHAR*)"Hello.", 7);
	Console_Ln();
	__FINI;
}
