/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Configuration.h"
#include "Heap.h"
#include "Modules.h"
#include "OPM.h"
#include "Out.h"
#include "Platform.h"
#include "Strings.h"

typedef
	CHAR extTools_CommandString[4096];


static extTools_CommandString extTools_CFLAGS;


export void extTools_Assemble (CHAR *moduleName, ADDRESS moduleName__len);
static void extTools_InitialiseCompilerCommand (CHAR *s, ADDRESS s__len);
export void extTools_LinkMain (CHAR *moduleName, ADDRESS moduleName__len, BOOLEAN statically, CHAR *additionalopts, ADDRESS additionalopts__len);
static void extTools_execute (CHAR *title, ADDRESS title__len, CHAR *cmd, ADDRESS cmd__len);


static void extTools_execute (CHAR *title, ADDRESS title__len, CHAR *cmd, ADDRESS cmd__len)
{
	INT16 r, status, exitcode;
	extTools_CommandString fullcmd;
	__DUP(title, title__len, CHAR);
	__DUP(cmd, cmd__len, CHAR);
	if (__IN(18, OPM_Options, 32)) {
		Out_String((CHAR*)"  ", 3);
		Out_String(cmd, cmd__len);
		Out_Ln();
	}
	__COPY(cmd, fullcmd, 4096);
	Heap_GC(0);
	r = Platform_System(fullcmd, 4096);
	status = __MASK(r, -128);
	exitcode = __ASHR(r, 8);
	if (exitcode > 127) {
		exitcode = exitcode - 256;
	}
	if (r != 0) {
		Out_String(title, title__len);
		Out_String(cmd, cmd__len);
		Out_Ln();
		Out_String((CHAR*)"-- failed: status ", 19);
		Out_Int(status, 1);
		Out_String((CHAR*)", exitcode ", 12);
		Out_Int(exitcode, 1);
		Out_String((CHAR*)".", 2);
		Out_Ln();
		if ((status == 0 && exitcode == 127)) {
			Out_String((CHAR*)"Is the C compiler in the current command path\?", 47);
			Out_Ln();
		}
		if (status != 0) {
			Modules_Halt(status);
		} else {
			Modules_Halt(exitcode);
		}
	}
	__DEL(title);
	__DEL(cmd);
}

static void extTools_InitialiseCompilerCommand (CHAR *s, ADDRESS s__len)
{
	__COPY("gcc -fPIC -g", s, s__len);
	Strings_Append((CHAR*)" -I \"", 6, (void*)s, s__len);
	Strings_Append(OPM_ResourceDir, 1024, (void*)s, s__len);
	Strings_Append((CHAR*)"/include\" ", 11, (void*)s, s__len);
	Platform_GetEnv((CHAR*)"CFLAGS", 7, (void*)extTools_CFLAGS, 4096);
	Strings_Append(extTools_CFLAGS, 4096, (void*)s, s__len);
	Strings_Append((CHAR*)" ", 2, (void*)s, s__len);
}

void extTools_Assemble (CHAR *moduleName, ADDRESS moduleName__len)
{
	extTools_CommandString cmd;
	__DUP(moduleName, moduleName__len, CHAR);
	extTools_InitialiseCompilerCommand((void*)cmd, 4096);
	Strings_Append((CHAR*)"-c ", 4, (void*)cmd, 4096);
	Strings_Append(moduleName, moduleName__len, (void*)cmd, 4096);
	Strings_Append((CHAR*)".c", 3, (void*)cmd, 4096);
	extTools_execute((CHAR*)"C compile: ", 12, cmd, 4096);
	__DEL(moduleName);
}

void extTools_LinkMain (CHAR *moduleName, ADDRESS moduleName__len, BOOLEAN statically, CHAR *additionalopts, ADDRESS additionalopts__len)
{
	extTools_CommandString cmd;
	__DUP(additionalopts, additionalopts__len, CHAR);
	extTools_InitialiseCompilerCommand((void*)cmd, 4096);
	Strings_Append(moduleName, moduleName__len, (void*)cmd, 4096);
	Strings_Append((CHAR*)".c ", 4, (void*)cmd, 4096);
	Strings_Append(additionalopts, additionalopts__len, (void*)cmd, 4096);
	if (statically) {
		Strings_Append((CHAR*)" -static", 9, (void*)cmd, 4096);
	}
	Strings_Append((CHAR*)" -o ", 5, (void*)cmd, 4096);
	Strings_Append(moduleName, moduleName__len, (void*)cmd, 4096);
	if (!statically || 1) {
		Strings_Append((CHAR*)" -L\"", 5, (void*)cmd, 4096);
		Strings_Append(OPM_InstallDir, 1024, (void*)cmd, 4096);
		Strings_Append((CHAR*)"/lib\"", 6, (void*)cmd, 4096);
		Strings_Append((CHAR*)" -lvoc", 7, (void*)cmd, 4096);
		Strings_Append((CHAR*)"-O", 3, (void*)cmd, 4096);
		Strings_Append(OPM_Model, 10, (void*)cmd, 4096);
		Strings_Append((CHAR*)"", 1, (void*)cmd, 4096);
	}
	extTools_execute((CHAR*)"C compile and link: ", 21, cmd, 4096);
	__DEL(additionalopts);
}


export void *extTools__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Configuration);
	__MODULE_IMPORT(Heap);
	__MODULE_IMPORT(Modules);
	__MODULE_IMPORT(OPM);
	__MODULE_IMPORT(Out);
	__MODULE_IMPORT(Platform);
	__MODULE_IMPORT(Strings);
	__REGMOD("extTools", 0);
/* BEGIN */
	__ENDMOD;
}
