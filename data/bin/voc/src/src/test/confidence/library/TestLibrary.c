/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Oberon.h"
#include "Reals.h"
#include "Texts.h"
#include "oocLowReal.h"


static Texts_Writer TestLibrary_W;


static void TestLibrary_RealTests (void);
static void TestLibrary_TestConvert (LONGREAL lr);
static void TestLibrary_TestFractionPart (REAL r);
static void TestLibrary_TestHex (REAL r);
static void TestLibrary_TestSetExpo (REAL r, INT16 i);
static void TestLibrary_tc (CHAR c);
static void TestLibrary_ti (INT32 i, INT32 n);
static void TestLibrary_tn (void);
static void TestLibrary_tr (LONGREAL r, INT16 n);
static void TestLibrary_ts (CHAR *s, ADDRESS s__len);


static void TestLibrary_tc (CHAR c)
{
	Texts_Write(&TestLibrary_W, Texts_Writer__typ, c);
}

static void TestLibrary_ts (CHAR *s, ADDRESS s__len)
{
	__DUP(s, s__len, CHAR);
	Texts_WriteString(&TestLibrary_W, Texts_Writer__typ, s, s__len);
	__DEL(s);
}

static void TestLibrary_ti (INT32 i, INT32 n)
{
	Texts_WriteInt(&TestLibrary_W, Texts_Writer__typ, i, n);
}

static void TestLibrary_tr (LONGREAL r, INT16 n)
{
	Texts_WriteLongReal(&TestLibrary_W, Texts_Writer__typ, r, n);
}

static void TestLibrary_tn (void)
{
	Texts_WriteLn(&TestLibrary_W, Texts_Writer__typ);
	Texts_Append(Oberon_Log, TestLibrary_W.buf);
}

static void TestLibrary_TestConvert (LONGREAL lr)
{
	CHAR str[20];
	INT16 i;
	Reals_ConvertL(lr, 6, (void*)str, 20);
	i = 6;
	while (i > 0) {
		i -= 1;
		TestLibrary_tc(str[__X(i, 20)]);
	}
	TestLibrary_tn();
}

static void TestLibrary_TestHex (REAL r)
{
	CHAR str[20];
	Reals_ConvertH(r, (void*)str, 20);
	str[8] = 0x00;
	TestLibrary_ts(str, 20);
	TestLibrary_tn();
}

static void TestLibrary_TestSetExpo (REAL r, INT16 i)
{
	TestLibrary_ts((CHAR*)"r = ", 5);
	TestLibrary_tr(r, 10);
	TestLibrary_ts((CHAR*)", i = ", 7);
	TestLibrary_ti(Reals_Expo(r), 1);
	Reals_SetExpo(&r, i);
	TestLibrary_ts((CHAR*)" -> r = ", 9);
	TestLibrary_tr(r, 10);
	TestLibrary_ts((CHAR*)", i = ", 7);
	TestLibrary_ti(Reals_Expo(r), 1);
	TestLibrary_tn();
}

static void TestLibrary_TestFractionPart (REAL r)
{
	TestLibrary_ts((CHAR*)"r = ", 5);
	TestLibrary_tr(r, 14);
	TestLibrary_ts((CHAR*)", exp = ", 9);
	TestLibrary_ti(Reals_Expo(r), 1);
	r = oocLowReal_fraction(r);
	TestLibrary_ts((CHAR*)" -> r = ", 9);
	TestLibrary_tr(r, 14);
	TestLibrary_ts((CHAR*)", exp = ", 9);
	TestLibrary_ti(Reals_Expo(r), 1);
	TestLibrary_tn();
}

static void TestLibrary_RealTests (void)
{
	CHAR str[20];
	REAL r;
	TestLibrary_TestConvert((LONGREAL)1);
	TestLibrary_TestConvert(  1.50000000000000e+000);
	TestLibrary_TestConvert((LONGREAL)2);
	TestLibrary_TestConvert(  2.99000000953674e+000);
	TestLibrary_TestConvert((LONGREAL)3);
	TestLibrary_TestHex((REAL)1);
	TestLibrary_TestHex(  1.5000000e+000);
	TestLibrary_TestHex((REAL)2);
	TestLibrary_TestHex(  2.9900000e+000);
	TestLibrary_TestHex((REAL)3);
	TestLibrary_ti(Reals_Expo(  5.0000000e-001), 1);
	TestLibrary_tn();
	TestLibrary_ti(Reals_Expo((REAL)1), 1);
	TestLibrary_tn();
	TestLibrary_ti(Reals_Expo((REAL)2), 1);
	TestLibrary_tn();
	TestLibrary_ti(Reals_Expo((REAL)3), 1);
	TestLibrary_tn();
	TestLibrary_ti(Reals_Expo((REAL)4), 1);
	TestLibrary_tn();
	TestLibrary_TestSetExpo((REAL)1, 129);
	TestLibrary_TestSetExpo((REAL)-1, 129);
	TestLibrary_TestSetExpo((REAL)2, 129);
	TestLibrary_TestSetExpo((REAL)-4, 129);
	TestLibrary_TestSetExpo(  1.5000000e+000, 129);
	TestLibrary_TestSetExpo( -1.5000000e+000, 129);
	TestLibrary_TestFractionPart(  1.2340000e+000);
	TestLibrary_TestFractionPart( -1.2340000e+000);
	TestLibrary_TestFractionPart(  3.2678001e+001);
	TestLibrary_TestFractionPart( -3.2678001e+001);
	r = (REAL)0;
	__ASSERT(!oocLowReal_IsInfinity(r), 3);
	__ASSERT(!oocLowReal_IsNaN(r), 4);
	r = (REAL)0;
	Reals_SetExpo(&r, 255);
	__ASSERT(oocLowReal_IsInfinity(r), 5);
	__ASSERT(!oocLowReal_IsNaN(r), 6);
	r =   1.2300000e-001;
	Reals_SetExpo(&r, 255);
	__ASSERT(!oocLowReal_IsInfinity(r), 7);
	__ASSERT(oocLowReal_IsNaN(r), 8);
}

static void EnumPtrs(void (*P)(void*))
{
	__ENUMR(&TestLibrary_W, Texts_Writer__typ, 36, 1, P);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Oberon);
	__MODULE_IMPORT(Reals);
	__MODULE_IMPORT(Texts);
	__MODULE_IMPORT(oocLowReal);
	__REGMAIN("TestLibrary", EnumPtrs);
/* BEGIN */
	Texts_OpenWriter(&TestLibrary_W, Texts_Writer__typ);
	TestLibrary_RealTests();
	TestLibrary_ts((CHAR*)"Library tests successful.", 26);
	TestLibrary_tn();
	__FINI;
}
