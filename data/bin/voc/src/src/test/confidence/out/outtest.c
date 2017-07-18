/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT16
#define INTEGER  INT32
#define LONGINT  INT64
#define SET      UINT64

#include "SYSTEM.h"
#include "Out.h"


static REAL outtest_r;
static LONGREAL outtest_lr;
static INT16 outtest_cw;


static void outtest_wc (CHAR c);
static void outtest_wh (SYSTEM_BYTE *h, ADDRESS h__len);
static void outtest_wi (INT64 i);
static void outtest_wl (void);
static void outtest_ws (CHAR *s, ADDRESS s__len);


static void outtest_wc (CHAR c)
{
	Out_Char(c);
}

static void outtest_ws (CHAR *s, ADDRESS s__len)
{
	__DUP(s, s__len, CHAR);
	Out_String(s, s__len);
	__DEL(s);
}

static void outtest_wi (INT64 i)
{
	Out_Int(i, 1);
}

static void outtest_wl (void)
{
	Out_Ln();
}

static void outtest_wh (SYSTEM_BYTE *h, ADDRESS h__len)
{
	INT32 i;
	INT8 b;
	i = (INT32)h__len;
	while (i > 0) {
		i -= 1;
		b = __VAL(INT8, h[__X(i, h__len)]);
		if (__MASK(__ASHR(b, 4), -16) < 10) {
			outtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 48));
		} else {
			outtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 55));
		}
		if (__MASK(b, -16) < 10) {
			outtest_wc((CHAR)(__MASK(b, -16) + 48));
		} else {
			outtest_wc((CHAR)(__MASK(b, -16) + 55));
		}
	}
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Out);
	__REGMAIN("outtest", 0);
/* BEGIN */
	outtest_ws((CHAR*)"Real number hex representation.", 32);
	outtest_wl();
	outtest_lr = (LONGREAL)1;
	outtest_ws((CHAR*)" 1.0D0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =   1.10000000000000e+000;
	outtest_ws((CHAR*)" 1.1D0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =   2.10000000000000e+000;
	outtest_ws((CHAR*)" 2.1D0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =  -1.10000000000000e+000;
	outtest_ws((CHAR*)"-1.1D0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr = (LONGREAL)1100;
	outtest_ws((CHAR*)" 1.1D3:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =   1.10000000000000e-003;
	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =   1.23456789876543e+003;
	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr =   1.23000000000000e-004;
	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)1 / outtest_lr;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = -((LONGREAL)1 / outtest_lr);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	outtest_wh((void*)&outtest_lr, 8);
	outtest_wl();
	outtest_wl();
	outtest_r = (REAL)1;
	outtest_ws((CHAR*)" 1.0E0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =   1.1000000e+000;
	outtest_ws((CHAR*)" 1.1E0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =   2.0999999e+000;
	outtest_ws((CHAR*)" 2.1E0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =  -1.1000000e+000;
	outtest_ws((CHAR*)"-1.1E0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r = (REAL)1100;
	outtest_ws((CHAR*)" 1.1E3:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =   1.1000000e-003;
	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =   1.2345679e+003;
	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r =   1.2300001e-004;
	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)1 / outtest_r;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = -((REAL)1 / outtest_r);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	outtest_wh((void*)&outtest_r, 4);
	outtest_wl();
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"Out module tests.", 18);
	outtest_wl();
	outtest_ws((CHAR*)"SIZE(INTEGER) = ", 17);
	outtest_wi(4);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"Testing LONGREAL.", 18);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3         4", 64);
	outtest_wl();
	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0D0:                ", 24);
	Out_LongReal((LONGREAL)1, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D0:                ", 24);
	Out_LongReal(  1.10000000000000e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1D0:                ", 24);
	Out_LongReal(  2.10000000000000e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1D0:                ", 24);
	Out_LongReal( -1.10000000000000e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D3:                ", 24);
	Out_LongReal((LONGREAL)1100, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
	Out_LongReal(  1.10000000000000e-003, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
	Out_LongReal(  1.23456789876543e+003, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_LongReal((LONGREAL)0, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
	Out_LongReal(  1.23000000000000e-004, 1);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)1 / outtest_lr;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 1);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = -((LONGREAL)1 / outtest_lr);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 1);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)0 / outtest_lr;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_LongReal(outtest_lr, 1);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3         4", 64);
	outtest_wl();
	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0D0:                ", 24);
	Out_LongReal((LONGREAL)1, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D0:                ", 24);
	Out_LongReal(  1.10000000000000e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1D0:                ", 24);
	Out_LongReal(  2.10000000000000e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1D0:                ", 24);
	Out_LongReal( -1.10000000000000e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D3:                ", 24);
	Out_LongReal((LONGREAL)1100, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
	Out_LongReal(  1.10000000000000e-003, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
	Out_LongReal(  1.23456789876543e+003, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_LongReal((LONGREAL)0, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
	Out_LongReal(  1.23000000000000e-004, 12);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)1 / outtest_lr;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 12);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = -((LONGREAL)1 / outtest_lr);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 12);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)0 / outtest_lr;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_LongReal(outtest_lr, 12);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3         4", 64);
	outtest_wl();
	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0D0:                ", 24);
	Out_LongReal((LONGREAL)1, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D0:                ", 24);
	Out_LongReal(  1.10000000000000e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1D0:                ", 24);
	Out_LongReal(  2.10000000000000e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1D0:                ", 24);
	Out_LongReal( -1.10000000000000e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D3:                ", 24);
	Out_LongReal((LONGREAL)1100, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
	Out_LongReal(  1.10000000000000e-003, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
	Out_LongReal(  1.23456789876543e+003, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_LongReal((LONGREAL)0, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
	Out_LongReal(  1.23000000000000e-004, 40);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)1 / outtest_lr;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 40);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = -((LONGREAL)1 / outtest_lr);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_LongReal(outtest_lr, 40);
	outtest_wl();
	outtest_lr = (LONGREAL)0;
	outtest_lr = (LONGREAL)0 / outtest_lr;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_LongReal(outtest_lr, 40);
	outtest_wl();
	outtest_wl();
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"Testing REAL.", 14);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3         4", 64);
	outtest_wl();
	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0E0:                ", 24);
	Out_Real((REAL)1, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E0:                ", 24);
	Out_Real(  1.1000000e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1E0:                ", 24);
	Out_Real(  2.0999999e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1E0:                ", 24);
	Out_Real( -1.1000000e+000, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E3:                ", 24);
	Out_Real((REAL)1100, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
	Out_Real(  1.1000000e-003, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
	Out_Real(  1.2345679e+003, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_Real((REAL)0, 1);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
	Out_Real(  1.2300001e-004, 1);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)1 / outtest_r;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_Real(outtest_r, 1);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = -((REAL)1 / outtest_r);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_Real(outtest_r, 1);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)0 / outtest_r;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_Real(outtest_r, 1);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3", 54);
	outtest_wl();
	outtest_ws((CHAR*)"                       123456789012345678901234567890", 54);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0E0:                ", 24);
	Out_Real((REAL)1, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E0:                ", 24);
	Out_Real(  1.1000000e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1E0:                ", 24);
	Out_Real(  2.0999999e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1E0:                ", 24);
	Out_Real( -1.1000000e+000, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E3:                ", 24);
	Out_Real((REAL)1100, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
	Out_Real(  1.1000000e-003, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
	Out_Real(  1.2345679e+003, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_Real((REAL)0, 12);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
	Out_Real(  1.2300001e-004, 12);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)1 / outtest_r;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_Real(outtest_r, 12);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = -((REAL)1 / outtest_r);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_Real(outtest_r, 12);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)0 / outtest_r;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_Real(outtest_r, 12);
	outtest_wl();
	outtest_wl();
	outtest_ws((CHAR*)"                                1         2         3         4", 64);
	outtest_wl();
	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
	outtest_wl();
	outtest_ws((CHAR*)" 1.0E0:                ", 24);
	Out_Real((REAL)1, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E0:                ", 24);
	Out_Real(  1.1000000e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 2.1E0:                ", 24);
	Out_Real(  2.0999999e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)"-1.1E0:                ", 24);
	Out_Real( -1.1000000e+000, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E3:                ", 24);
	Out_Real((REAL)1100, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
	Out_Real(  1.1000000e-003, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
	Out_Real(  1.2345679e+003, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 0.0:                  ", 24);
	Out_Real((REAL)0, 40);
	outtest_wl();
	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
	Out_Real(  1.2300001e-004, 40);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)1 / outtest_r;
	outtest_ws((CHAR*)" 1/0.0:                ", 24);
	Out_Real(outtest_r, 40);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = -((REAL)1 / outtest_r);
	outtest_ws((CHAR*)"-1/0.0:                ", 24);
	Out_Real(outtest_r, 40);
	outtest_wl();
	outtest_r = (REAL)0;
	outtest_r = (REAL)0 / outtest_r;
	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
	Out_Real(outtest_r, 40);
	outtest_wl();
	outtest_wl();
	__FINI;
}
