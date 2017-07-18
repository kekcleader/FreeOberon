/* voc 2.1.0 [2017/06/21]. Bootstrapping compiler for address size 8, alignment 8. xtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"




static void Reals_BytesToHex (SYSTEM_BYTE *b, ADDRESS b__len, SYSTEM_BYTE *d, ADDRESS d__len);
export void Reals_Convert (REAL x, INT16 n, CHAR *d, ADDRESS d__len);
export void Reals_ConvertH (REAL y, CHAR *d, ADDRESS d__len);
export void Reals_ConvertHL (LONGREAL x, CHAR *d, ADDRESS d__len);
export void Reals_ConvertL (LONGREAL x, INT16 n, CHAR *d, ADDRESS d__len);
export INT16 Reals_Expo (REAL x);
export INT16 Reals_ExpoL (LONGREAL x);
export void Reals_SetExpo (REAL *x, INT16 ex);
export REAL Reals_Ten (INT16 e);
export LONGREAL Reals_TenL (INT16 e);
static CHAR Reals_ToHex (INT16 i);


REAL Reals_Ten (INT16 e)
{
	LONGREAL r, power;
	r = (LONGREAL)1;
	power = (LONGREAL)10;
	while (e > 0) {
		if (__ODD(e)) {
			r = r * power;
		}
		power = power * power;
		e = __ASHR(e, 1);
	}
	return r;
}

LONGREAL Reals_TenL (INT16 e)
{
	LONGREAL r, power;
	r = (LONGREAL)1;
	power = (LONGREAL)10;
	for (;;) {
		if (__ODD(e)) {
			r = r * power;
		}
		e = __ASHR(e, 1);
		if (e <= 0) {
			return r;
		}
		power = power * power;
	}
	__RETCHK;
}

INT16 Reals_Expo (REAL x)
{
	INT16 i;
	__GET((ADDRESS)&x + 2, i, INT16);
	return __MASK(__ASHR(i, 7), -256);
}

void Reals_SetExpo (REAL *x, INT16 ex)
{
	CHAR c;
	__GET((ADDRESS)x + 3, c, CHAR);
	__PUT((ADDRESS)x + 3, (CHAR)(__ASHL(__ASHR((INT16)c, 7), 7) + __MASK(__ASHR(ex, 1), -128)), CHAR);
	__GET((ADDRESS)x + 2, c, CHAR);
	__PUT((ADDRESS)x + 2, (CHAR)(__MASK((INT16)c, -128) + __ASHL(__MASK(ex, -2), 7)), CHAR);
}

INT16 Reals_ExpoL (LONGREAL x)
{
	INT16 i;
	__GET((ADDRESS)&x + 6, i, INT16);
	return __MASK(__ASHR(i, 4), -2048);
}

void Reals_ConvertL (LONGREAL x, INT16 n, CHAR *d, ADDRESS d__len)
{
	INT32 i, j, k;
	if (x < (LONGREAL)0) {
		x = -x;
	}
	k = 0;
	if (n > 9) {
		i = (INT32)__ENTIER(x / (LONGREAL)(LONGREAL)1000000000);
		j = (INT32)__ENTIER(x - i * (LONGREAL)1000000000);
		if (j < 0) {
			j = 0;
		}
		while (k < 9) {
			d[__X(k, d__len)] = (CHAR)((int)__MOD(j, 10) + 48);
			j = __DIV(j, 10);
			k += 1;
		}
	} else {
		i = (INT32)__ENTIER(x);
	}
	while (k < n) {
		d[__X(k, d__len)] = (CHAR)((int)__MOD(i, 10) + 48);
		i = __DIV(i, 10);
		k += 1;
	}
}

void Reals_Convert (REAL x, INT16 n, CHAR *d, ADDRESS d__len)
{
	Reals_ConvertL(x, n, (void*)d, d__len);
}

static CHAR Reals_ToHex (INT16 i)
{
	if (i < 10) {
		return (CHAR)(i + 48);
	} else {
		return (CHAR)(i + 55);
	}
	__RETCHK;
}

static void Reals_BytesToHex (SYSTEM_BYTE *b, ADDRESS b__len, SYSTEM_BYTE *d, ADDRESS d__len)
{
	INT16 i;
	INT32 l;
	CHAR by;
	i = 0;
	l = b__len;
	while (i < l) {
		by = __VAL(CHAR, b[__X(i, b__len)]);
		d[__X(__ASHL(i, 1), d__len)] = Reals_ToHex(__ASHR((INT16)by, 4));
		d[__X(__ASHL(i, 1) + 1, d__len)] = Reals_ToHex(__MASK((INT16)by, -16));
		i += 1;
	}
}

void Reals_ConvertH (REAL y, CHAR *d, ADDRESS d__len)
{
	Reals_BytesToHex((void*)&y, 4, (void*)d, d__len * 1);
}

void Reals_ConvertHL (LONGREAL x, CHAR *d, ADDRESS d__len)
{
	Reals_BytesToHex((void*)&x, 8, (void*)d, d__len * 1);
}


export void *Reals__init(void)
{
	__DEFMOD;
	__REGMOD("Reals", 0);
/* BEGIN */
	__ENDMOD;
}
