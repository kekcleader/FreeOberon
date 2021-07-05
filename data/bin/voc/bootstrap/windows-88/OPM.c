/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Configuration.h"
#include "Files.h"
#include "Modules.h"
#include "Out.h"
#include "Platform.h"
#include "Strings.h"
#include "Texts.h"
#include "VT100.h"

typedef
	CHAR OPM_FileName[32];


static CHAR OPM_SourceFileName[256];
static CHAR OPM_GlobalModel[10];
export CHAR OPM_Model[10];
static INT16 OPM_GlobalAddressSize;
export INT16 OPM_AddressSize;
static INT16 OPM_GlobalAlignment;
export INT16 OPM_Alignment;
export UINT32 OPM_GlobalOptions, OPM_Options;
export INT16 OPM_ShortintSize, OPM_IntegerSize, OPM_LongintSize;
export INT64 OPM_MaxIndex;
export LONGREAL OPM_MinReal, OPM_MaxReal, OPM_MinLReal, OPM_MaxLReal;
export BOOLEAN OPM_noerr;
export INT32 OPM_curpos, OPM_errpos, OPM_breakpc;
export INT16 OPM_currFile, OPM_level, OPM_pc, OPM_entno;
export CHAR OPM_modName[32];
export CHAR OPM_objname[64];
static INT32 OPM_ErrorLineStartPos, OPM_ErrorLineLimitPos, OPM_ErrorLineNumber, OPM_lasterrpos;
static Texts_Reader OPM_inR;
static Texts_Text OPM_Log, OPM_Errors;
static Files_Rider OPM_oldSF, OPM_newSF;
static Files_Rider OPM_R[3];
static Files_File OPM_oldSFile, OPM_newSFile, OPM_HFile, OPM_BFile, OPM_HIFile;
static INT16 OPM_S;
export CHAR OPM_InstallDir[1024];
export CHAR OPM_ResourceDir[1024];


static void OPM_Append (Files_Rider *R, ADDRESS *R__typ, Files_File F);
export void OPM_CloseFiles (void);
export void OPM_CloseOldSym (void);
export void OPM_DeleteObj (CHAR *modulename, ADDRESS modulename__len);
export void OPM_DeleteSym (CHAR *modulename, ADDRESS modulename__len);
export void OPM_FPrint (INT32 *fp, INT64 val);
export void OPM_FPrintLReal (INT32 *fp, LONGREAL val);
export void OPM_FPrintReal (INT32 *fp, REAL val);
export void OPM_FPrintSet (INT32 *fp, UINT64 val);
static void OPM_FindInstallDir (void);
static void OPM_FindLine (Files_File f, Files_Rider *r, ADDRESS *r__typ, INT64 pos);
static void OPM_FingerprintBytes (INT32 *fp, SYSTEM_BYTE *bytes, ADDRESS bytes__len);
export void OPM_Get (CHAR *ch);
export void OPM_Init (BOOLEAN *done);
export void OPM_InitOptions (void);
export INT16 OPM_Integer (INT64 n);
static BOOLEAN OPM_IsProbablyInstallDir (CHAR *s, ADDRESS s__len);
export void OPM_LogCompiling (CHAR *modname, ADDRESS modname__len);
static void OPM_LogErrMsg (INT16 n);
export void OPM_LogVT100 (CHAR *vt100code, ADDRESS vt100code__len);
export void OPM_LogW (CHAR ch);
export void OPM_LogWLn (void);
export void OPM_LogWNum (INT64 i, INT64 len);
export void OPM_LogWStr (CHAR *s, ADDRESS s__len);
export INT32 OPM_Longint (INT64 n);
static void OPM_MakeFileName (CHAR *name, ADDRESS name__len, CHAR *FName, ADDRESS FName__len, CHAR *ext, ADDRESS ext__len);
export void OPM_Mark (INT16 n, INT32 pos);
export void OPM_NewSym (CHAR *modName, ADDRESS modName__len);
export void OPM_OldSym (CHAR *modName, ADDRESS modName__len, BOOLEAN *done);
export void OPM_OpenFiles (CHAR *moduleName, ADDRESS moduleName__len);
export BOOLEAN OPM_OpenPar (void);
export void OPM_RegisterNewSym (void);
static void OPM_ScanOptions (CHAR *s, ADDRESS s__len);
static void OPM_ShowLine (INT64 pos);
export INT64 OPM_SignedMaximum (INT32 bytecount);
export INT64 OPM_SignedMinimum (INT32 bytecount);
export void OPM_SymRCh (CHAR *ch);
export INT32 OPM_SymRInt (void);
export INT64 OPM_SymRInt64 (void);
export void OPM_SymRLReal (LONGREAL *lr);
export void OPM_SymRReal (REAL *r);
export void OPM_SymRSet (UINT64 *s);
export void OPM_SymWCh (CHAR ch);
export void OPM_SymWInt (INT64 i);
export void OPM_SymWLReal (LONGREAL lr);
export void OPM_SymWReal (REAL r);
export void OPM_SymWSet (UINT64 s);
export void OPM_Write (CHAR ch);
export void OPM_WriteHex (INT64 i);
export void OPM_WriteInt (INT64 i);
export void OPM_WriteLn (void);
export void OPM_WriteReal (LONGREAL r, CHAR suffx);
export void OPM_WriteString (CHAR *s, ADDRESS s__len);
export void OPM_WriteStringVar (CHAR *s, ADDRESS s__len);
export BOOLEAN OPM_eofSF (void);
export void OPM_err (INT16 n);

#define OPM_GetAlignment(a)	struct {char c; long long l;} _s; *a = (char*)&_s.l - (char*)&_s

void OPM_LogW (CHAR ch)
{
	Out_Char(ch);
}

void OPM_LogWStr (CHAR *s, ADDRESS s__len)
{
	__DUP(s, s__len, CHAR);
	Out_String(s, s__len);
	__DEL(s);
}

void OPM_LogWNum (INT64 i, INT64 len)
{
	Out_Int(i, len);
}

void OPM_LogWLn (void)
{
	Out_Ln();
}

void OPM_LogVT100 (CHAR *vt100code, ADDRESS vt100code__len)
{
	__DUP(vt100code, vt100code__len, CHAR);
	if ((Out_IsConsole && !__IN(16, OPM_Options, 32))) {
		VT100_SetAttr(vt100code, vt100code__len);
	}
	__DEL(vt100code);
}

void OPM_LogCompiling (CHAR *modname, ADDRESS modname__len)
{
	__DUP(modname, modname__len, CHAR);
	OPM_LogWStr((CHAR*)"Compiling ", 11);
	OPM_LogWStr(modname, modname__len);
	if (__IN(18, OPM_Options, 32)) {
		OPM_LogWStr((CHAR*)", s:", 5);
		OPM_LogWNum(__ASHL(OPM_ShortintSize, 3), 1);
		OPM_LogWStr((CHAR*)" i:", 4);
		OPM_LogWNum(__ASHL(OPM_IntegerSize, 3), 1);
		OPM_LogWStr((CHAR*)" l:", 4);
		OPM_LogWNum(__ASHL(OPM_LongintSize, 3), 1);
		OPM_LogWStr((CHAR*)" adr:", 6);
		OPM_LogWNum(__ASHL(OPM_AddressSize, 3), 1);
		OPM_LogWStr((CHAR*)" algn:", 7);
		OPM_LogWNum(__ASHL(OPM_Alignment, 3), 1);
	}
	OPM_LogW('.');
	__DEL(modname);
}

INT64 OPM_SignedMaximum (INT32 bytecount)
{
	INT64 result;
	result = 1;
	result = __LSH(result, __ASHL(bytecount, 3) - 1, 64);
	return result - 1;
}

INT64 OPM_SignedMinimum (INT32 bytecount)
{
	return -OPM_SignedMaximum(bytecount) - 1;
}

INT32 OPM_Longint (INT64 n)
{
	return __VAL(INT32, n);
}

INT16 OPM_Integer (INT64 n)
{
	return __VAL(INT16, n);
}

static void OPM_ScanOptions (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	__DUP(s, s__len, CHAR);
	i = 1;
	while (s[__X(i, s__len)] != 0x00) {
		switch (s[__X(i, s__len)]) {
			case 'p': 
				OPM_Options = OPM_Options ^ 0x20;
				break;
			case 'a': 
				OPM_Options = OPM_Options ^ 0x80;
				break;
			case 'r': 
				OPM_Options = OPM_Options ^ 0x04;
				break;
			case 't': 
				OPM_Options = OPM_Options ^ 0x08;
				break;
			case 'x': 
				OPM_Options = OPM_Options ^ 0x01;
				break;
			case 'e': 
				OPM_Options = OPM_Options ^ 0x0200;
				break;
			case 's': 
				OPM_Options = OPM_Options ^ 0x10;
				break;
			case 'F': 
				OPM_Options = OPM_Options ^ 0x020000;
				break;
			case 'm': 
				OPM_Options = OPM_Options ^ 0x0400;
				break;
			case 'M': 
				OPM_Options = OPM_Options ^ 0x8000;
				break;
			case 'S': 
				OPM_Options = OPM_Options ^ 0x2000;
				break;
			case 'c': 
				OPM_Options = OPM_Options ^ 0x4000;
				break;
			case 'f': 
				OPM_Options = OPM_Options ^ 0x010000;
				break;
			case 'V': 
				OPM_Options = OPM_Options ^ 0x040000;
				break;
			case 'O': 
				if (i + 1 >= Strings_Length(s, s__len)) {
					OPM_LogWStr((CHAR*)"-O option requires following size model character.", 51);
					OPM_LogWLn();
				} else {
					OPM_Model[0] = s[__X(i + 1, s__len)];
					OPM_Model[1] = 0x00;
					if ((((OPM_Model[0] != '2' && OPM_Model[0] != 'C')) && OPM_Model[0] != 'V')) {
						OPM_LogWStr((CHAR*)"Unrecognised size model character following -O.", 48);
						OPM_LogWLn();
					}
					i += 1;
				}
				break;
			case 'A': 
				if (i + 2 >= Strings_Length(s, s__len)) {
					OPM_LogWStr((CHAR*)"-M option requires two following digits.", 41);
					OPM_LogWLn();
				} else {
					OPM_AddressSize = (INT16)s[__X(i + 1, s__len)] - 48;
					OPM_Alignment = (INT16)s[__X(i + 2, s__len)] - 48;
					i += 2;
				}
				break;
			default: 
				OPM_LogWStr((CHAR*)"  warning: option ", 19);
				OPM_LogW('-');
				OPM_LogW(s[__X(i, s__len)]);
				OPM_LogWStr((CHAR*)" ignored", 9);
				OPM_LogWLn();
				break;
		}
		i += 1;
	}
	__DEL(s);
}

BOOLEAN OPM_OpenPar (void)
{
	CHAR s[256];
	if (Modules_ArgCount == 1) {
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Oberon-2 compiler v", 20);
		OPM_LogWStr(Configuration_versionLong, 76);
		OPM_LogW('.');
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Based on Ofront by J. Templ and Software Templ OEG.", 52);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Further development by Norayr Chilingarian, David Brown and others.", 68);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Loaded from ", 13);
		OPM_LogWStr(Modules_BinaryDir, 1024);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Usage:", 7);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  ", 3);
		OPM_LogWStr((CHAR*)"voc", 4);
		OPM_LogWStr((CHAR*)" options {files {options}}.", 28);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Options:", 9);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  Run time safety", 18);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -p   Initialise pointers to NIL. On by default.", 52);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -a   Halt on assertion failures. On by default.", 52);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -r   Halt on range check failures.", 39);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -t   Halt on type guard failure. On by default.", 52);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -x   Halt on index out of range. On by default.", 52);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  Symbol file management", 25);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -e   Allow extension of old symbol file.", 45);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -s   Allow generation of new symbol file.", 46);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -F   Force generation of new symbol file.", 46);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  C compiler and linker control", 32);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -m   This module is main. Link dynamically.", 48);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -M   This module is main. Link statically.", 47);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -S   Don't call C compiler", 31);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -c   Don't link.", 21);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  Miscellaneous", 16);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -f   Disable VT100 control characters in status output.", 60);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -V   Display compiler debugging messages.", 46);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  Size model for elementary types (default O2)", 47);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -O2   Original Oberon / Oberon-2:  8 bit SHORTINT, 16 bit INTEGER, 32 bit LONGINT and SET.", 95);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -OC   Component Pascal:           16 bit SHORTINT, 32 bit INTEGER, 64 bit LONGINT and SET.", 95);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -OV   Alternate large model:       8 bit SHORTINT, 32 bit INTEGER, 64 bit LONGINT and SET.", 95);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"  Target machine address size and alignment (default is that of the running compiler binary)", 93);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -A44   32 bit addresses, 32 bit alignment (e.g. Unix/linux 32 bit on x86).", 79);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -A48   32 bit addresses, 64 bit alignment (e.g. Windows 32 bit on x86, linux 32 bit on arm).", 97);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"    -A88   64 bit addresses, 64 bit alignment (e.g. 64 bit platforms).", 71);
		OPM_LogWLn();
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"All options are off by default, except where noted above.", 58);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Initial options specify defaults for all files.", 48);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Options following a filename are specific to that file.", 56);
		OPM_LogWLn();
		OPM_LogWStr((CHAR*)"Repeating an option toggles its value.", 39);
		OPM_LogWLn();
		return 0;
	} else {
		OPM_AddressSize = 8;
		OPM_GetAlignment(&OPM_Alignment);
		__MOVE("2", OPM_Model, 2);
		OPM_Options = 0xa9;
		OPM_S = 1;
		s[0] = 0x00;
		Modules_GetArg(OPM_S, (void*)s, 256);
		while (s[0] == '-') {
			OPM_ScanOptions(s, 256);
			OPM_S += 1;
			s[0] = 0x00;
			Modules_GetArg(OPM_S, (void*)s, 256);
		}
		OPM_GlobalAddressSize = OPM_AddressSize;
		OPM_GlobalAlignment = OPM_Alignment;
		__MOVE(OPM_Model, OPM_GlobalModel, 10);
		OPM_GlobalOptions = OPM_Options;
		return 1;
	}
	__RETCHK;
}

void OPM_InitOptions (void)
{
	CHAR s[256];
	CHAR searchpath[1024], modules[1024];
	CHAR MODULES[1024];
	OPM_Options = OPM_GlobalOptions;
	__MOVE(OPM_GlobalModel, OPM_Model, 10);
	OPM_Alignment = OPM_GlobalAlignment;
	OPM_AddressSize = OPM_GlobalAddressSize;
	s[0] = 0x00;
	Modules_GetArg(OPM_S, (void*)s, 256);
	while (s[0] == '-') {
		OPM_ScanOptions(s, 256);
		OPM_S += 1;
		s[0] = 0x00;
		Modules_GetArg(OPM_S, (void*)s, 256);
	}
	if (__IN(15, OPM_Options, 32)) {
		OPM_Options |= __SETOF(10,32);
	}
	OPM_MaxIndex = OPM_SignedMaximum(OPM_AddressSize);
	switch (OPM_Model[0]) {
		case '2': 
			OPM_ShortintSize = 1;
			OPM_IntegerSize = 2;
			OPM_LongintSize = 4;
			break;
		case 'C': 
			OPM_ShortintSize = 2;
			OPM_IntegerSize = 4;
			OPM_LongintSize = 8;
			break;
		case 'V': 
			OPM_ShortintSize = 1;
			OPM_IntegerSize = 4;
			OPM_LongintSize = 8;
			break;
		default: 
			OPM_ShortintSize = 1;
			OPM_IntegerSize = 2;
			OPM_LongintSize = 4;
			break;
	}
	__MOVE(OPM_InstallDir, OPM_ResourceDir, 1024);
	if (OPM_ResourceDir[0] != 0x00) {
		Strings_Append((CHAR*)"/", 2, (void*)OPM_ResourceDir, 1024);
		Strings_Append(OPM_Model, 10, (void*)OPM_ResourceDir, 1024);
	}
	modules[0] = 0x00;
	Platform_GetEnv((CHAR*)"MODULES", 8, (void*)modules, 1024);
	__MOVE(".", searchpath, 2);
	Platform_GetEnv((CHAR*)"OBERON", 7, (void*)searchpath, 1024);
	Strings_Append((CHAR*)";.;", 4, (void*)searchpath, 1024);
	Strings_Append(modules, 1024, (void*)searchpath, 1024);
	Strings_Append((CHAR*)";", 2, (void*)searchpath, 1024);
	Strings_Append(OPM_ResourceDir, 1024, (void*)searchpath, 1024);
	Strings_Append((CHAR*)"/sym;", 6, (void*)searchpath, 1024);
	Files_SetSearchPath(searchpath, 1024);
}

void OPM_Init (BOOLEAN *done)
{
	Texts_Text T = NIL;
	INT32 beg, end, time;
	CHAR s[256];
	*done = 0;
	OPM_curpos = 0;
	if (OPM_S >= Modules_ArgCount) {
		return;
	}
	s[0] = 0x00;
	Modules_GetArg(OPM_S, (void*)s, 256);
	__NEW(T, Texts_TextDesc);
	Texts_Open(T, s, 256);
	OPM_LogWStr(s, 256);
	OPM_LogWStr((CHAR*)"  ", 3);
	__COPY(s, OPM_SourceFileName, 256);
	if (T->len == 0) {
		OPM_LogWStr(s, 256);
		OPM_LogWStr((CHAR*)" not found.", 12);
		OPM_LogWLn();
	} else {
		Texts_OpenReader(&OPM_inR, Texts_Reader__typ, T, 0);
		*done = 1;
	}
	OPM_S += 1;
	OPM_level = 0;
	OPM_noerr = 1;
	OPM_errpos = OPM_curpos;
	OPM_lasterrpos = OPM_curpos - 10;
	OPM_ErrorLineStartPos = 0;
	OPM_ErrorLineLimitPos = 0;
	OPM_ErrorLineNumber = 0;
}

void OPM_Get (CHAR *ch)
{
	OPM_curpos = Texts_Pos(&OPM_inR, Texts_Reader__typ);
	Texts_Read(&OPM_inR, Texts_Reader__typ, &*ch);
	if ((*ch < 0x09 && !OPM_inR.eot)) {
		*ch = ' ';
	}
}

static void OPM_MakeFileName (CHAR *name, ADDRESS name__len, CHAR *FName, ADDRESS FName__len, CHAR *ext, ADDRESS ext__len)
{
	INT16 i, j;
	CHAR ch;
	__DUP(ext, ext__len, CHAR);
	i = 0;
	for (;;) {
		ch = name[__X(i, name__len)];
		if (ch == 0x00) {
			break;
		}
		FName[__X(i, FName__len)] = ch;
		i += 1;
	}
	j = 0;
	do {
		ch = ext[__X(j, ext__len)];
		FName[__X(i, FName__len)] = ch;
		i += 1;
		j += 1;
	} while (!(ch == 0x00));
	__DEL(ext);
}

static void OPM_LogErrMsg (INT16 n)
{
	INT16 l;
	Texts_Scanner S;
	CHAR c;
	if (n >= 0) {
		OPM_LogVT100((CHAR*)"31m", 4);
		OPM_LogWStr((CHAR*)"  err ", 7);
		OPM_LogVT100((CHAR*)"0m", 3);
	} else {
		OPM_LogVT100((CHAR*)"35m", 4);
		OPM_LogWStr((CHAR*)"  warning ", 11);
		n = -n;
		OPM_LogVT100((CHAR*)"0m", 3);
	}
	OPM_LogWNum(n, 1);
	OPM_LogWStr((CHAR*)"  ", 3);
	if (OPM_Errors == NIL) {
		__NEW(OPM_Errors, Texts_TextDesc);
		Texts_Open(OPM_Errors, (CHAR*)"Errors.Txt", 11);
	}
	Texts_OpenScanner(&S, Texts_Scanner__typ, OPM_Errors, 0);
	do {
		l = S.line;
		Texts_Scan(&S, Texts_Scanner__typ);
	} while (!((((l != S.line && S.class == 3)) && S.i == n) || S.eot));
	if (!S.eot) {
		Texts_Read((void*)&S, Texts_Scanner__typ, &c);
		while ((!S.eot && c >= ' ')) {
			Out_Char(c);
			Texts_Read((void*)&S, Texts_Scanner__typ, &c);
		}
	}
}

static void OPM_FindLine (Files_File f, Files_Rider *r, ADDRESS *r__typ, INT64 pos)
{
	CHAR ch, cheol;
	if (pos < (INT64)OPM_ErrorLineStartPos) {
		OPM_ErrorLineStartPos = 0;
		OPM_ErrorLineLimitPos = 0;
		OPM_ErrorLineNumber = 0;
	}
	if (pos < (INT64)OPM_ErrorLineLimitPos) {
		Files_Set(&*r, r__typ, f, OPM_ErrorLineStartPos);
		return;
	}
	Files_Set(&*r, r__typ, f, OPM_ErrorLineLimitPos);
	Files_Read(&*r, r__typ, (void*)&ch);
	while (((INT64)OPM_ErrorLineLimitPos < pos && !(*r).eof)) {
		OPM_ErrorLineStartPos = OPM_ErrorLineLimitPos;
		OPM_ErrorLineNumber += 1;
		while ((((ch != 0x00 && ch != 0x0d)) && ch != 0x0a)) {
			Files_Read(&*r, r__typ, (void*)&ch);
			OPM_ErrorLineLimitPos += 1;
		}
		cheol = ch;
		Files_Read(&*r, r__typ, (void*)&ch);
		OPM_ErrorLineLimitPos += 1;
		if ((cheol == 0x0d && ch == 0x0a)) {
			OPM_ErrorLineLimitPos += 1;
			Files_Read(&*r, r__typ, (void*)&ch);
		}
	}
	Files_Set(&*r, r__typ, f, OPM_ErrorLineStartPos);
}

static void OPM_ShowLine (INT64 pos)
{
	Files_File f = NIL;
	Files_Rider r;
	CHAR line[1023];
	INT16 i;
	CHAR ch;
	f = Files_Old(OPM_SourceFileName, 256);
	OPM_FindLine(f, &r, Files_Rider__typ, pos);
	i = 0;
	Files_Read(&r, Files_Rider__typ, (void*)&ch);
	while ((((((ch != 0x00 && ch != 0x0d)) && ch != 0x0a)) && i < 1022)) {
		line[__X(i, 1023)] = ch;
		i += 1;
		Files_Read(&r, Files_Rider__typ, (void*)&ch);
	}
	line[__X(i, 1023)] = 0x00;
	OPM_LogWLn();
	OPM_LogWLn();
	OPM_LogWNum(OPM_ErrorLineNumber, 4);
	OPM_LogWStr((CHAR*)": ", 3);
	OPM_LogWStr(line, 1023);
	OPM_LogWLn();
	OPM_LogWStr((CHAR*)"      ", 7);
	if (pos >= (INT64)OPM_ErrorLineLimitPos) {
		pos = OPM_ErrorLineLimitPos - 1;
	}
	i = __SHORTF(OPM_Longint(pos - (INT64)OPM_ErrorLineStartPos), 32768);
	while (i > 0) {
		OPM_LogW(' ');
		i -= 1;
	}
	OPM_LogVT100((CHAR*)"32m", 4);
	OPM_LogW('^');
	OPM_LogVT100((CHAR*)"0m", 3);
}

void OPM_Mark (INT16 n, INT32 pos)
{
	if (pos == -1) {
		pos = 0;
	}
	if (n >= 0) {
		OPM_noerr = 0;
		if (pos < OPM_lasterrpos || OPM_lasterrpos + 9 < pos) {
			OPM_lasterrpos = pos;
			OPM_ShowLine(pos);
			OPM_LogWLn();
			OPM_LogWStr((CHAR*)"  ", 3);
			if (n < 249) {
				OPM_LogWStr((CHAR*)"  pos", 6);
				OPM_LogWNum(pos, 6);
				OPM_LogErrMsg(n);
			} else if (n == 255) {
				OPM_LogWStr((CHAR*)"pos", 4);
				OPM_LogWNum(pos, 6);
				OPM_LogWStr((CHAR*)"  pc ", 6);
				OPM_LogWNum(OPM_breakpc, 1);
			} else if (n == 254) {
				OPM_LogWStr((CHAR*)"pc not found", 13);
			} else {
				OPM_LogWStr(OPM_objname, 64);
				if (n == 253) {
					OPM_LogWStr((CHAR*)" is new, compile with option e", 31);
				} else if (n == 252) {
					OPM_LogWStr((CHAR*)" is redefined, compile with option s", 37);
				} else if (n == 251) {
					OPM_LogWStr((CHAR*)" is redefined (private part only), compile with option s", 57);
				} else if (n == 250) {
					OPM_LogWStr((CHAR*)" is no longer visible, compile with option s", 45);
				} else if (n == 249) {
					OPM_LogWStr((CHAR*)" is not consistently imported, recompile imports", 49);
				}
			}
		}
	} else {
		if (pos >= 0) {
			OPM_ShowLine(pos);
			OPM_LogWLn();
			OPM_LogWStr((CHAR*)"  pos", 6);
			OPM_LogWNum(pos, 6);
		}
		OPM_LogErrMsg(n);
		if (pos < 0) {
			OPM_LogWLn();
		}
	}
}

void OPM_err (INT16 n)
{
	OPM_Mark(n, OPM_errpos);
}

static void OPM_FingerprintBytes (INT32 *fp, SYSTEM_BYTE *bytes, ADDRESS bytes__len)
{
	INT16 i;
	INT32 l;
	__ASSERT(__MASK(bytes__len, -4) == 0, 0);
	i = 0;
	while (i < bytes__len) {
		__GET((ADDRESS)&bytes[__X(i, bytes__len)], l, INT32);
		*fp = __ROTL((INT32)((UINT32)*fp ^ (UINT32)l), 1, 32);
		i += 4;
	}
}

void OPM_FPrint (INT32 *fp, INT64 val)
{
	OPM_FingerprintBytes(&*fp, (void*)&val, 8);
}

void OPM_FPrintSet (INT32 *fp, UINT64 val)
{
	OPM_FingerprintBytes(&*fp, (void*)&val, 8);
}

void OPM_FPrintReal (INT32 *fp, REAL val)
{
	OPM_FingerprintBytes(&*fp, (void*)&val, 4);
}

void OPM_FPrintLReal (INT32 *fp, LONGREAL val)
{
	OPM_FingerprintBytes(&*fp, (void*)&val, 8);
}

void OPM_SymRCh (CHAR *ch)
{
	Files_Read(&OPM_oldSF, Files_Rider__typ, (void*)&*ch);
}

INT32 OPM_SymRInt (void)
{
	INT32 k;
	Files_ReadNum(&OPM_oldSF, Files_Rider__typ, (void*)&k, 4);
	return k;
}

INT64 OPM_SymRInt64 (void)
{
	INT64 k;
	Files_ReadNum(&OPM_oldSF, Files_Rider__typ, (void*)&k, 8);
	return k;
}

void OPM_SymRSet (UINT64 *s)
{
	Files_ReadNum(&OPM_oldSF, Files_Rider__typ, (void*)&*s, 8);
}

void OPM_SymRReal (REAL *r)
{
	Files_ReadReal(&OPM_oldSF, Files_Rider__typ, &*r);
}

void OPM_SymRLReal (LONGREAL *lr)
{
	Files_ReadLReal(&OPM_oldSF, Files_Rider__typ, &*lr);
}

void OPM_CloseOldSym (void)
{
	Files_Close(Files_Base(&OPM_oldSF, Files_Rider__typ));
}

void OPM_OldSym (CHAR *modName, ADDRESS modName__len, BOOLEAN *done)
{
	CHAR tag, ver;
	OPM_FileName fileName;
	INT16 res;
	OPM_oldSFile = NIL;
	*done = 0;
	OPM_MakeFileName((void*)modName, modName__len, (void*)fileName, 32, (CHAR*)".sym", 5);
	OPM_oldSFile = Files_Old(fileName, 32);
	*done = OPM_oldSFile != NIL;
	if (*done) {
		Files_Set(&OPM_oldSF, Files_Rider__typ, OPM_oldSFile, 0);
		Files_Read(&OPM_oldSF, Files_Rider__typ, (void*)&tag);
		Files_Read(&OPM_oldSF, Files_Rider__typ, (void*)&ver);
		if (tag != 0xf7 || ver != 0x83) {
			if (!__IN(4, OPM_Options, 32)) {
				OPM_err(-306);
			}
			OPM_CloseOldSym();
			*done = 0;
		}
	}
}

BOOLEAN OPM_eofSF (void)
{
	return OPM_oldSF.eof;
}

void OPM_SymWCh (CHAR ch)
{
	Files_Write(&OPM_newSF, Files_Rider__typ, ch);
}

void OPM_SymWInt (INT64 i)
{
	Files_WriteNum(&OPM_newSF, Files_Rider__typ, i);
}

void OPM_SymWSet (UINT64 s)
{
	Files_WriteNum(&OPM_newSF, Files_Rider__typ, (INT64)s);
}

void OPM_SymWReal (REAL r)
{
	Files_WriteReal(&OPM_newSF, Files_Rider__typ, r);
}

void OPM_SymWLReal (LONGREAL lr)
{
	Files_WriteLReal(&OPM_newSF, Files_Rider__typ, lr);
}

void OPM_RegisterNewSym (void)
{
	if (__STRCMP(OPM_modName, "SYSTEM") != 0 || __IN(10, OPM_Options, 32)) {
		Files_Register(OPM_newSFile);
	}
}

void OPM_DeleteSym (CHAR *modulename, ADDRESS modulename__len)
{
	OPM_FileName fn;
	INT16 res;
	OPM_MakeFileName((void*)modulename, modulename__len, (void*)fn, 32, (CHAR*)".sym", 5);
	Files_Delete(fn, 32, &res);
}

void OPM_DeleteObj (CHAR *modulename, ADDRESS modulename__len)
{
	OPM_FileName fn;
	INT16 res;
	OPM_MakeFileName((void*)modulename, modulename__len, (void*)fn, 32, (CHAR*)".o", 3);
	Files_Delete(fn, 32, &res);
}

void OPM_NewSym (CHAR *modName, ADDRESS modName__len)
{
	OPM_FileName fileName;
	OPM_MakeFileName((void*)modName, modName__len, (void*)fileName, 32, (CHAR*)".sym", 5);
	OPM_newSFile = Files_New(fileName, 32);
	if (OPM_newSFile != NIL) {
		Files_Set(&OPM_newSF, Files_Rider__typ, OPM_newSFile, 0);
		Files_Write(&OPM_newSF, Files_Rider__typ, 0xf7);
		Files_Write(&OPM_newSF, Files_Rider__typ, 0x83);
	} else {
		OPM_err(153);
	}
}

void OPM_Write (CHAR ch)
{
	Files_Write(&OPM_R[__X(OPM_currFile, 3)], Files_Rider__typ, ch);
}

void OPM_WriteString (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	i = 0;
	while (s[__X(i, s__len)] != 0x00) {
		i += 1;
	}
	Files_WriteBytes(&OPM_R[__X(OPM_currFile, 3)], Files_Rider__typ, (void*)s, s__len * 1, i);
}

void OPM_WriteStringVar (CHAR *s, ADDRESS s__len)
{
	INT16 i;
	i = 0;
	while (s[__X(i, s__len)] != 0x00) {
		i += 1;
	}
	Files_WriteBytes(&OPM_R[__X(OPM_currFile, 3)], Files_Rider__typ, (void*)s, s__len * 1, i);
}

void OPM_WriteHex (INT64 i)
{
	CHAR s[3];
	INT32 digit;
	digit = __ASHR(__SHORT(i, 2147483648LL), 4);
	if (digit < 10) {
		s[0] = __CHR(48 + digit);
	} else {
		s[0] = __CHR(87 + digit);
	}
	digit = __MASK(__SHORT(i, 2147483648LL), -16);
	if (digit < 10) {
		s[1] = __CHR(48 + digit);
	} else {
		s[1] = __CHR(87 + digit);
	}
	s[2] = 0x00;
	OPM_WriteString(s, 3);
}

void OPM_WriteInt (INT64 i)
{
	CHAR s[26];
	INT64 i1, k;
	if ((i == OPM_SignedMinimum(2) || i == OPM_SignedMinimum(4)) || i == OPM_SignedMinimum(8)) {
		OPM_Write('(');
		OPM_WriteInt(i + 1);
		OPM_WriteString((CHAR*)"-1)", 4);
	} else {
		i1 = __ABS(i);
		if (i1 <= 2147483647) {
			k = 0;
		} else {
			__MOVE("LL", s, 3);
			k = 2;
		}
		s[__X(k, 26)] = __CHR(__MOD(i1, 10) + 48);
		i1 = __DIV(i1, 10);
		k += 1;
		while (i1 > 0) {
			s[__X(k, 26)] = __CHR(__MOD(i1, 10) + 48);
			i1 = __DIV(i1, 10);
			k += 1;
		}
		if (i < 0) {
			s[__X(k, 26)] = '-';
			k += 1;
		}
		while (k > 0) {
			k -= 1;
			OPM_Write(s[__X(k, 26)]);
		}
	}
}

void OPM_WriteReal (LONGREAL r, CHAR suffx)
{
	Texts_Writer W;
	Texts_Text T = NIL;
	Texts_Reader R;
	CHAR s[32];
	CHAR ch;
	INT16 i;
	if ((((r < OPM_SignedMaximum(OPM_LongintSize) && r > OPM_SignedMinimum(OPM_LongintSize))) && r == (__SHORT(__ENTIER(r), 2147483648LL)))) {
		if (suffx == 'f') {
			OPM_WriteString((CHAR*)"(REAL)", 7);
		} else {
			OPM_WriteString((CHAR*)"(LONGREAL)", 11);
		}
		OPM_WriteInt(__SHORT(__ENTIER(r), 2147483648LL));
	} else {
		Texts_OpenWriter(&W, Texts_Writer__typ);
		if (suffx == 'f') {
			Texts_WriteLongReal(&W, Texts_Writer__typ, r, 16);
		} else {
			Texts_WriteLongReal(&W, Texts_Writer__typ, r, 23);
		}
		__NEW(T, Texts_TextDesc);
		Texts_Open(T, (CHAR*)"", 1);
		Texts_Append(T, W.buf);
		Texts_OpenReader(&R, Texts_Reader__typ, T, 0);
		i = 0;
		Texts_Read(&R, Texts_Reader__typ, &ch);
		while (ch != 0x00) {
			s[__X(i, 32)] = ch;
			i += 1;
			Texts_Read(&R, Texts_Reader__typ, &ch);
		}
		s[__X(i, 32)] = 0x00;
		i = 0;
		ch = s[0];
		while ((ch != 'D' && ch != 0x00)) {
			i += 1;
			ch = s[__X(i, 32)];
		}
		if (ch == 'D') {
			s[__X(i, 32)] = 'e';
		}
		OPM_WriteString(s, 32);
	}
}

void OPM_WriteLn (void)
{
	Files_Write(&OPM_R[__X(OPM_currFile, 3)], Files_Rider__typ, 0x0a);
}

static void OPM_Append (Files_Rider *R, ADDRESS *R__typ, Files_File F)
{
	Files_Rider R1;
	CHAR buffer[4096];
	if (F != NIL) {
		Files_Set(&R1, Files_Rider__typ, F, 0);
		Files_ReadBytes(&R1, Files_Rider__typ, (void*)buffer, 4096, 4096);
		while (4096 - R1.res > 0) {
			Files_WriteBytes(&*R, R__typ, (void*)buffer, 4096, 4096 - R1.res);
			Files_ReadBytes(&R1, Files_Rider__typ, (void*)buffer, 4096, 4096);
		}
	}
}

void OPM_OpenFiles (CHAR *moduleName, ADDRESS moduleName__len)
{
	OPM_FileName FName;
	__COPY(moduleName, OPM_modName, 32);
	OPM_HFile = Files_New((CHAR*)"", 1);
	if (OPM_HFile != NIL) {
		Files_Set(&OPM_R[0], Files_Rider__typ, OPM_HFile, 0);
	} else {
		OPM_err(153);
	}
	OPM_MakeFileName((void*)moduleName, moduleName__len, (void*)FName, 32, (CHAR*)".c", 3);
	OPM_BFile = Files_New(FName, 32);
	if (OPM_BFile != NIL) {
		Files_Set(&OPM_R[1], Files_Rider__typ, OPM_BFile, 0);
	} else {
		OPM_err(153);
	}
	OPM_MakeFileName((void*)moduleName, moduleName__len, (void*)FName, 32, (CHAR*)".h", 3);
	OPM_HIFile = Files_New(FName, 32);
	if (OPM_HIFile != NIL) {
		Files_Set(&OPM_R[2], Files_Rider__typ, OPM_HIFile, 0);
	} else {
		OPM_err(153);
	}
}

void OPM_CloseFiles (void)
{
	OPM_FileName FName;
	INT16 res;
	if (OPM_noerr) {
		OPM_LogWStr((CHAR*)"  ", 3);
		OPM_LogWNum(Files_Pos(&OPM_R[1], Files_Rider__typ), 0);
		OPM_LogWStr((CHAR*)" chars.", 8);
	}
	if (OPM_noerr) {
		if (__STRCMP(OPM_modName, "SYSTEM") == 0) {
			if (!__IN(10, OPM_Options, 32)) {
				Files_Register(OPM_BFile);
			}
		} else if (!__IN(10, OPM_Options, 32)) {
			OPM_Append(&OPM_R[2], Files_Rider__typ, OPM_HFile);
			Files_Register(OPM_HIFile);
			Files_Register(OPM_BFile);
		} else {
			OPM_MakeFileName((void*)OPM_modName, 32, (void*)FName, 32, (CHAR*)".h", 3);
			Files_Delete(FName, 32, &res);
			OPM_MakeFileName((void*)OPM_modName, 32, (void*)FName, 32, (CHAR*)".sym", 5);
			Files_Delete(FName, 32, &res);
			Files_Register(OPM_BFile);
		}
	}
	OPM_HFile = NIL;
	OPM_BFile = NIL;
	OPM_HIFile = NIL;
	OPM_newSFile = NIL;
	OPM_oldSFile = NIL;
	Files_Set(&OPM_R[0], Files_Rider__typ, NIL, 0);
	Files_Set(&OPM_R[1], Files_Rider__typ, NIL, 0);
	Files_Set(&OPM_R[2], Files_Rider__typ, NIL, 0);
	Files_Set(&OPM_newSF, Files_Rider__typ, NIL, 0);
	Files_Set(&OPM_oldSF, Files_Rider__typ, NIL, 0);
}

static BOOLEAN OPM_IsProbablyInstallDir (CHAR *s, ADDRESS s__len)
{
	CHAR testpath[4096];
	Platform_FileIdentity identity;
	__DUP(s, s__len, CHAR);
	__COPY(OPM_InstallDir, testpath, 4096);
	Strings_Append((CHAR*)"/lib/lib", 9, (void*)testpath, 4096);
	Strings_Append((CHAR*)"voc", 4, (void*)testpath, 4096);
	Strings_Append((CHAR*)"-O2.a", 6, (void*)testpath, 4096);
	if (Platform_IdentifyByName(testpath, 4096, &identity, Platform_FileIdentity__typ) != 0) {
		__DEL(s);
		return 0;
	}
	__COPY(OPM_InstallDir, testpath, 4096);
	Strings_Append((CHAR*)"/2/include/Oberon.h", 20, (void*)testpath, 4096);
	if (Platform_IdentifyByName(testpath, 4096, &identity, Platform_FileIdentity__typ) != 0) {
		__DEL(s);
		return 0;
	}
	__COPY(OPM_InstallDir, testpath, 4096);
	Strings_Append((CHAR*)"/2/sym/Files.sym", 17, (void*)testpath, 4096);
	if (Platform_IdentifyByName(testpath, 4096, &identity, Platform_FileIdentity__typ) != 0) {
		__DEL(s);
		return 0;
	}
	__DEL(s);
	return 1;
}

static void OPM_FindInstallDir (void)
{
	INT16 i;
	__COPY(Modules_BinaryDir, OPM_InstallDir, 1024);
	Strings_Append((CHAR*)"/", 2, (void*)OPM_InstallDir, 1024);
	Strings_Append((CHAR*)"voc", 4, (void*)OPM_InstallDir, 1024);
	Strings_Append((CHAR*)".d", 3, (void*)OPM_InstallDir, 1024);
	if (OPM_IsProbablyInstallDir(OPM_InstallDir, 1024)) {
		return;
	}
	__COPY(Modules_BinaryDir, OPM_InstallDir, 1024);
	i = Strings_Length(OPM_InstallDir, 1024);
	while ((i > 0 && OPM_InstallDir[__X(i - 1, 1024)] != '/')) {
		i -= 1;
	}
	if ((i > 0 && OPM_InstallDir[__X(i - 1, 1024)] == '/')) {
		OPM_InstallDir[__X(i - 1, 1024)] = 0x00;
		if (OPM_IsProbablyInstallDir(OPM_InstallDir, 1024)) {
			return;
		}
	}
	__COPY("", OPM_InstallDir, 1024);
}

static void EnumPtrs(void (*P)(void*))
{
	__ENUMR(&OPM_inR, Texts_Reader__typ, 72, 1, P);
	P(OPM_Log);
	P(OPM_Errors);
	__ENUMR(&OPM_oldSF, Files_Rider__typ, 24, 1, P);
	__ENUMR(&OPM_newSF, Files_Rider__typ, 24, 1, P);
	__ENUMR(OPM_R, Files_Rider__typ, 24, 3, P);
	P(OPM_oldSFile);
	P(OPM_newSFile);
	P(OPM_HFile);
	P(OPM_BFile);
	P(OPM_HIFile);
}


export void *OPM__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Configuration);
	__MODULE_IMPORT(Files);
	__MODULE_IMPORT(Modules);
	__MODULE_IMPORT(Out);
	__MODULE_IMPORT(Platform);
	__MODULE_IMPORT(Strings);
	__MODULE_IMPORT(Texts);
	__MODULE_IMPORT(VT100);
	__REGMOD("OPM", EnumPtrs);
	__REGCMD("CloseFiles", OPM_CloseFiles);
	__REGCMD("CloseOldSym", OPM_CloseOldSym);
	__REGCMD("InitOptions", OPM_InitOptions);
	__REGCMD("LogWLn", OPM_LogWLn);
	__REGCMD("RegisterNewSym", OPM_RegisterNewSym);
	__REGCMD("WriteLn", OPM_WriteLn);
/* BEGIN */
	OPM_MaxReal =   3.40282346000000e+038;
	OPM_MaxLReal =   1.79769296342094e+308;
	OPM_MinReal = -OPM_MaxReal;
	OPM_MinLReal = -OPM_MaxLReal;
	OPM_FindInstallDir();
	__ENDMOD;
}
