/* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */

#define SHORTINT INT16
#define INTEGER  INT32
#define LONGINT  INT64
#define SET      UINT32

#include "SYSTEM.h"
#include "Math.h"
#include "MathL.h"
#include "Out.h"

typedef
	INT64 (*mathtest_LRtoLI)(LONGREAL);

typedef
	LONGREAL (*mathtest_LRtoLR)(LONGREAL);

typedef
	INT64 (*mathtest_RtoLI)(REAL);

typedef
	REAL (*mathtest_RtoR)(REAL);

typedef
	struct mathtest_Values {
		LONGREAL v[100];
		INT32 n;
	} mathtest_Values;


static REAL mathtest_r;
static LONGREAL mathtest_lr;
static mathtest_Values mathtest_misc, mathtest_angles;

export ADDRESS *mathtest_Values__typ;

static void mathtest_MathErrorHandler (INT32 error);
static void mathtest_TestRtoLI (CHAR *s, ADDRESS s__len, mathtest_RtoLI p, mathtest_LRtoLI lp, mathtest_Values val);
static void mathtest_TestRtoR (CHAR *s, ADDRESS s__len, mathtest_RtoR p, mathtest_LRtoLR lp, mathtest_Values val);
static void mathtest_addvalue (LONGREAL lr, mathtest_Values *val, ADDRESS *val__typ);
static void mathtest_round (LONGREAL lr);
static void mathtest_sqrt (LONGREAL lr);
static void mathtest_wc (CHAR c);
static void mathtest_wh (SYSTEM_BYTE *h, ADDRESS h__len);
static void mathtest_wi (INT64 i);
static void mathtest_wl (void);
static void mathtest_wlr (LONGREAL lr);
static void mathtest_wr (REAL r);
static void mathtest_ws (CHAR *s, ADDRESS s__len);


static void mathtest_wc (CHAR c)
{
	Out_Char(c);
}

static void mathtest_ws (CHAR *s, ADDRESS s__len)
{
	__DUP(s, s__len, CHAR);
	Out_String(s, s__len);
	__DEL(s);
}

static void mathtest_wi (INT64 i)
{
	Out_Int(i, 1);
}

static void mathtest_wr (REAL r)
{
	Out_Real(r, 11);
}

static void mathtest_wlr (LONGREAL lr)
{
	Out_LongReal(lr, 21);
}

static void mathtest_wl (void)
{
	Out_Ln();
}

static void mathtest_wh (SYSTEM_BYTE *h, ADDRESS h__len)
{
	INT32 i;
	INT8 b;
	i = (INT32)h__len;
	while (i > 0) {
		i -= 1;
		b = __VAL(INT8, h[__X(i, h__len)]);
		if (__MASK(__ASHR(b, 4), -16) < 10) {
			mathtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 48));
		} else {
			mathtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 55));
		}
		if (__MASK(b, -16) < 10) {
			mathtest_wc((CHAR)(__MASK(b, -16) + 48));
		} else {
			mathtest_wc((CHAR)(__MASK(b, -16) + 55));
		}
	}
}

static void mathtest_addvalue (LONGREAL lr, mathtest_Values *val, ADDRESS *val__typ)
{
	(*val).v[__X((*val).n, 100)] = lr;
	(*val).n += 1;
}

static void mathtest_MathErrorHandler (INT32 error)
{
	mathtest_ws((CHAR*)"<Math(L) error ", 16);
	switch (error) {
		case 0: 
			mathtest_ws((CHAR*)"NoError", 8);
			break;
		case 1: 
			mathtest_ws((CHAR*)"IllegalRoot", 12);
			break;
		case 2: 
			mathtest_ws((CHAR*)"IllegalLog", 11);
			break;
		case 3: 
			mathtest_ws((CHAR*)"Overflow", 9);
			break;
		case 4: 
			mathtest_ws((CHAR*)"IllegalPower", 13);
			break;
		case 5: 
			mathtest_ws((CHAR*)"IllegalLogBase", 15);
			break;
		case 6: 
			mathtest_ws((CHAR*)"IllegalTrig", 12);
			break;
		case 7: 
			mathtest_ws((CHAR*)"IllegalInvTrig", 15);
			break;
		case 8: 
			mathtest_ws((CHAR*)"HypInvTrigClipped", 18);
			break;
		case 9: 
			mathtest_ws((CHAR*)"IllegalHypInvTrig", 18);
			break;
		case 10: 
			mathtest_ws((CHAR*)"LossOfAccuracy", 15);
			break;
		case 11: 
			mathtest_ws((CHAR*)"Underflow", 10);
			break;
		default: 
			mathtest_wi(error);
			mathtest_ws((CHAR*)" (unknknown)", 13);
			break;
	}
	mathtest_ws((CHAR*)"> ", 3);
}

static void mathtest_TestRtoR (CHAR *s, ADDRESS s__len, mathtest_RtoR p, mathtest_LRtoLR lp, mathtest_Values val)
{
	INT32 i;
	REAL r;
	__DUP(s, s__len, CHAR);
	i = 0;
	while (i < val.n) {
		r = val.v[__X(i, 100)];
		mathtest_ws((CHAR*)"Math.", 6);
		mathtest_ws(s, s__len);
		mathtest_ws((CHAR*)"(", 2);
		mathtest_wr(r);
		mathtest_ws((CHAR*)"): ", 4);
		mathtest_wr((*p)(r));
		mathtest_ws((CHAR*)".  MathL.", 10);
		mathtest_ws(s, s__len);
		mathtest_ws((CHAR*)"(", 2);
		mathtest_wlr(val.v[__X(i, 100)]);
		mathtest_ws((CHAR*)"): ", 4);
		mathtest_wlr((*lp)(val.v[__X(i, 100)]));
		mathtest_wl();
		i += 1;
	}
	mathtest_wl();
	__DEL(s);
}

static void mathtest_TestRtoLI (CHAR *s, ADDRESS s__len, mathtest_RtoLI p, mathtest_LRtoLI lp, mathtest_Values val)
{
	INT32 i;
	REAL r;
	__DUP(s, s__len, CHAR);
	i = 0;
	while (i < val.n) {
		r = val.v[__X(i, 100)];
		mathtest_ws((CHAR*)"Math.", 6);
		mathtest_ws(s, s__len);
		mathtest_ws((CHAR*)"(", 2);
		mathtest_wr(r);
		mathtest_ws((CHAR*)"): ", 4);
		mathtest_wi((*p)(r));
		mathtest_ws((CHAR*)".  MathL.", 10);
		mathtest_ws(s, s__len);
		mathtest_ws((CHAR*)"(", 2);
		mathtest_wlr(val.v[__X(i, 100)]);
		mathtest_ws((CHAR*)"): ", 4);
		mathtest_wi((*lp)(val.v[__X(i, 100)]));
		mathtest_wl();
		i += 1;
	}
	mathtest_wl();
	__DEL(s);
}

static void mathtest_round (LONGREAL lr)
{
	REAL r;
	r = lr;
	mathtest_ws((CHAR*)"Math.round(", 12);
	mathtest_wr(r);
	mathtest_ws((CHAR*)"): ", 4);
	mathtest_wi(Math_round(r));
	mathtest_ws((CHAR*)".  MathL.round(", 16);
	mathtest_wlr(lr);
	mathtest_ws((CHAR*)"): ", 4);
	mathtest_wi(MathL_round(lr));
	mathtest_wl();
}

static void mathtest_sqrt (LONGREAL lr)
{
	REAL r;
	r = lr;
	mathtest_ws((CHAR*)"Math.sqrt(", 11);
	mathtest_wr(r);
	mathtest_ws((CHAR*)"): ", 4);
	mathtest_wr(Math_sqrt(r));
	mathtest_ws((CHAR*)".  MathL.sqrt(", 15);
	mathtest_wlr(r);
	mathtest_ws((CHAR*)"): ", 4);
	mathtest_wlr(MathL_sqrt(r));
	mathtest_wl();
}

__TDESC(mathtest_Values, 1, 0) = {__TDFLDS("Values", 808), {-8}};

export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Math);
	__MODULE_IMPORT(MathL);
	__MODULE_IMPORT(Out);
	__REGMAIN("mathtest", 0);
	__INITYP(mathtest_Values, mathtest_Values, 0);
/* BEGIN */
	mathtest_ws((CHAR*)"Math and MathL module tests.", 29);
	mathtest_wl();
	mathtest_wl();
	mathtest_misc.n = 0;
	mathtest_addvalue(  9.00000000000000e-001, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)1, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  1.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  1.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  1.60000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  1.90000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)2, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  2.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue(  2.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)3, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)4, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -9.00000000000000e-001, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)-1, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -1.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -1.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -1.60000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -1.90000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)-2, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -2.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue( -2.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)-3, &mathtest_misc, mathtest_Values__typ);
	mathtest_addvalue((LONGREAL)-4, &mathtest_misc, mathtest_Values__typ);
	mathtest_angles.n = 0;
	mathtest_addvalue((LONGREAL)0, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue(  1.00000000000000e-001, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue(  1.04719755119660e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue(  1.57079632679490e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue(  3.14159265358979e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue( -1.04719755119660e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue( -1.57079632679490e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_addvalue( -3.14159265358979e+000, &mathtest_angles, mathtest_Values__typ);
	mathtest_TestRtoR((CHAR*)"fraction", 9, Math_fraction, MathL_fraction, mathtest_misc);
	mathtest_TestRtoLI((CHAR*)"round", 6, Math_round, MathL_round, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"sqrt", 5, Math_sqrt, MathL_sqrt, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"ln", 3, Math_ln, MathL_ln, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"sin", 4, Math_sin, MathL_sin, mathtest_angles);
	mathtest_TestRtoR((CHAR*)"cos", 4, Math_cos, MathL_cos, mathtest_angles);
	mathtest_TestRtoR((CHAR*)"tan", 4, Math_tan, MathL_tan, mathtest_angles);
	mathtest_TestRtoR((CHAR*)"arcsin", 7, Math_arcsin, MathL_arcsin, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"arccos", 7, Math_arccos, MathL_arccos, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"arctan", 7, Math_arctan, MathL_arctan, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"sinh", 5, Math_sinh, MathL_sinh, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"cosh", 5, Math_cosh, MathL_cosh, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"tanh", 5, Math_tanh, MathL_tanh, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"arcsinh", 8, Math_arcsinh, MathL_arcsinh, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"arccosh", 8, Math_arccosh, MathL_arccosh, mathtest_misc);
	mathtest_TestRtoR((CHAR*)"arctanh", 8, Math_arctanh, MathL_arctanh, mathtest_misc);
	__FINI;
}
