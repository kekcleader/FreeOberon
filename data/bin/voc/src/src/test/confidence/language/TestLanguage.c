/* voc 2.1.0 [2017/07/17] for mingw ILP32 on windows xtpam */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Console.h"


static LONGREAL TestLanguage_gz;


static void TestLanguage_Abs (void);
static void TestLanguage_DivMod (void);
static void TestLanguage_Entier (void);
static void TestLanguage_IntSize (void);
static LONGREAL TestLanguage_LR (LONGREAL lr);
static void TestLanguage_Shift (void);
static void TestLanguage_TestShiftResult (INT32 of, INT32 by, INT32 actual, INT32 expected, CHAR *msg, ADDRESS msg__len);
static void TestLanguage_TestValue (INT32 v, INT32 e, CHAR *name, ADDRESS name__len);
static INT16 TestLanguage_side (INT16 i);


static void TestLanguage_TestShiftResult (INT32 of, INT32 by, INT32 actual, INT32 expected, CHAR *msg, ADDRESS msg__len)
{
	__DUP(msg, msg__len, CHAR);
	if (actual != expected) {
		Console_String(msg, msg__len);
		Console_String((CHAR*)" of $", 6);
		Console_Hex(of);
		Console_String((CHAR*)" by ", 5);
		Console_Int(by, 1);
		Console_String((CHAR*)" is $", 6);
		Console_Hex(actual);
		Console_String((CHAR*)" but should be $", 17);
		Console_Hex(expected);
		Console_Ln();
	}
	__DEL(msg);
}

static void TestLanguage_Shift (void)
{
	CHAR c;
	SYSTEM_BYTE b;
	INT8 s, t, u;
	INT16 h, i, j, k;
	INT32 l, m, n, r;
	i = 0;
	m = 1;
	while (i < 32) {
		l = 1;
		r = __LSH(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"LSH", 4);
		l = 1;
		r = __ROT(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT(1)", 7);
		m = __ASHL(m, 1);
		i += 1;
	}
	i = 0;
	k = 1;
	while (i < 16) {
		j = 1;
		j = __LSH(j, i, 16);
		__ASSERT(j == k, 23);
		j = 1;
		j = __ROT(j, i, 16);
		__ASSERT(j == k, 24);
		k = __ASHL(k, 1);
		i += 1;
	}
	i = 0;
	t = 1;
	while (i < 8) {
		s = 1;
		s = __LSH(s, i, 8);
		__ASSERT(s == t, 30);
		s = 1;
		s = __ROT(s, i, 8);
		__ASSERT(s == t, 31);
		t = __ASHL(t, 1);
		i += 1;
	}
	i = -1;
	m = 1;
	m = __LSHL(m, 30, 32);
	n = __ASHL(m, 1);
	while (i > -32) {
		l = n;
		l = __LSH(l, i, 32);
		__ASSERT(l == m, 39);
		l = n;
		l = __ROT(l, i, 32);
		__ASSERT(l == m, 40);
		m = __ASHR(m, 1);
		i -= 1;
	}
	i = -1;
	k = 1;
	k = __LSHL(k, 14, 16);
	h = __ASHL(k, 1);
	while (i > -16) {
		j = h;
		j = __LSH(j, i, 16);
		__ASSERT(j == k, 46);
		j = h;
		j = __ROT(j, i, 16);
		__ASSERT(j == k, 47);
		k = __ASHR(k, 1);
		i -= 1;
	}
	i = -1;
	t = 1;
	t = __LSHL(t, 6, 8);
	u = __ASHL(t, 1);
	while (i > -8) {
		s = u;
		s = __LSH(s, i, 8);
		__ASSERT(s == t, 53);
		s = u;
		s = __ROT(s, i, 8);
		__ASSERT(s == t, 54);
		t = __ASHR(t, 1);
		i -= 1;
	}
	i = 0;
	m = 1;
	m = __LSHL(m, 31, 32);
	n = m;
	while (i > -32) {
		l = n;
		l = __ASH(l, i);
		__ASSERT(l == m, 62);
		m = __ASHR(m, 1);
		i -= 1;
	}
	i = 0;
	j = 1;
	j = __LSHL(j, 15, 16);
	k = j;
	while (i > -16) {
		l = __ASH(j, i);
		__ASSERT(l == k, 68);
		k = __ASHR(k, 1);
		i -= 1;
	}
	i = 0;
	s = 1;
	s = __LSHL(s, 7, 8);
	t = s;
	while (i > -8) {
		l = __ASH(s, i);
		__ASSERT(l == ((INT16)t), 74);
		t = __ASHR(t, 1);
		i -= 1;
	}
	i = 0;
	m = 1;
	m = __LSHL(m, 30, 32);
	n = m;
	while (i > -31) {
		l = n;
		l = __ASH(l, i);
		__ASSERT(l == m, 82);
		m = __ASHR(m, 1);
		i -= 1;
	}
	i = 1;
	m = 1;
	while (i < 32) {
		l = 2147483647;
		l += 1;
		r = __LSH(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, 0, (CHAR*)"LSH", 4);
		l = 2147483647;
		l += 1;
		r = __ROT(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT(2)", 7);
		m = __ASHL(m, 1);
		i += 1;
	}
	i = 1;
	k = 1;
	while (i < 16) {
		j = 32767;
		j += 1;
		r = __LSH(j, i, 16);
		TestLanguage_TestShiftResult(j, i, r, 0, (CHAR*)"LSH", 4);
		j = 32767;
		j += 1;
		r = __ROT(j, i, 16);
		TestLanguage_TestShiftResult(j, i, r, k, (CHAR*)"ROT(3)", 7);
		k = __ASHL(k, 1);
		i += 1;
	}
	i = 1;
	t = 1;
	while (i < 8) {
		s = 127;
		s += 1;
		r = __LSH(s, i, 8);
		TestLanguage_TestShiftResult(s, i, r, 0, (CHAR*)"LSH", 4);
		s = 127;
		s += 1;
		r = __ROT(s, i, 8);
		TestLanguage_TestShiftResult(s, i, r, t, (CHAR*)"ROT(4)", 7);
		t = __ASHL(t, 1);
		i += 1;
	}
	i = -1;
	m = 2147483647;
	m += 1;
	while (i > -32) {
		l = 1;
		r = __LSH(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, 0, (CHAR*)"LSH", 4);
		l = 1;
		r = __ROT(l, i, 32);
		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT", 4);
		m = __LSHR(m, 1, 32);
		i -= 1;
	}
	i = -1;
	k = 32767;
	k += 1;
	while (i > -16) {
		j = 1;
		r = __LSH(j, i, 16);
		TestLanguage_TestShiftResult(j, i, r, 0, (CHAR*)"LSH", 4);
		j = 1;
		r = __ROT(j, i, 16);
		TestLanguage_TestShiftResult(j, i, r, k, (CHAR*)"ROT", 4);
		k = __LSHR(k, 1, 16);
		i -= 1;
	}
	i = -1;
	t = 127;
	t += 1;
	while (i > -8) {
		s = 1;
		r = __LSH(s, i, 8);
		TestLanguage_TestShiftResult(s, i, r, 0, (CHAR*)"LSH", 4);
		s = 1;
		r = __ROT(s, i, 8);
		TestLanguage_TestShiftResult(s, i, r, t, (CHAR*)"ROT", 4);
		t = __LSHR(t, 1, 8);
		i -= 1;
	}
	c = 0x01;
	c = __LSHL(c, 2, 8);
	c = __ROTR(c, 2, 8);
	__ASSERT(c == 0x01, 93);
	b = 1;
	b = __LSHL(b, 2, 8);
	b = __ROTR(b, 2, 8);
	__ASSERT(__VAL(CHAR, b) == 0x01, 94);
}

static void TestLanguage_TestValue (INT32 v, INT32 e, CHAR *name, ADDRESS name__len)
{
	__DUP(name, name__len, CHAR);
	if (v != e) {
		Console_String(name, name__len);
		Console_String((CHAR*)" = ", 4);
		Console_Int(v, 1);
		Console_String((CHAR*)", expected ", 12);
		Console_Int(e, 1);
		Console_Ln();
	}
	__DEL(name);
}

static INT16 TestLanguage_side (INT16 i)
{
	return i;
}

static void TestLanguage_DivMod (void)
{
	INT16 i, j;
	j = 2;
	i = 4;
	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"4 DIV 2", 8);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(4) DIV side(2)", 20);
	i = 5;
	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"5 DIV 2", 8);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(5) DIV side(2)", 20);
	i = 6;
	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"6 DIV 2", 8);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(6) DIV side(2)", 20);
	i = 7;
	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"7 DIV 2", 8);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(7) DIV side(2)", 20);
	i = -4;
	TestLanguage_TestValue(__DIV(i, j), -2, (CHAR*)"(-4) DIV 2", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -2, (CHAR*)"side(-4) DIV side(2)", 21);
	i = -5;
	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"(-5) DIV 2", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(-5) DIV side(2)", 21);
	i = -6;
	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"(-6) DIV 2", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(-6) DIV side(2)", 21);
	i = -7;
	TestLanguage_TestValue(__DIV(i, j), -4, (CHAR*)"(-7) DIV 2", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -4, (CHAR*)"side(-7) DIV side(2)", 21);
	j = -2;
	i = 4;
	TestLanguage_TestValue(__DIV(i, j), -2, (CHAR*)"4 DIV (-2)", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -2, (CHAR*)"side(4) DIV side(-2)", 21);
	i = 5;
	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"5 DIV (-2)", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(5) DIV side(-2)", 21);
	i = 6;
	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"6 DIV (-2)", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(6) DIV side(-2)", 21);
	i = 7;
	TestLanguage_TestValue(__DIV(i, j), -4, (CHAR*)"7 DIV (-2)", 11);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -4, (CHAR*)"side(7) DIV side(-2)", 21);
	i = -4;
	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"(-4) DIV (-2)", 14);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(-4) DIV side(-2)", 22);
	i = -5;
	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"(-5) DIV (-2)", 14);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(-5) DIV side(-2)", 22);
	i = -6;
	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"(-6) DIV (-2)", 14);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(-6) DIV side(-2)", 22);
	i = -7;
	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"(-7) DIV (-2)", 14);
	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(-7) DIV side(-2)", 22);
	i = 4;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"4 MOD 3", 8);
	i = 5;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"5 MOD 3", 8);
	i = 6;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"6 MOD 3", 8);
	i = 7;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"7 MOD 3", 8);
	i = -4;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-4 MOD 3", 9);
	i = -5;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-5 MOD 3", 9);
	i = -6;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-6 MOD 3", 9);
	i = -7;
	j = 3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-7 MOD 3", 9);
	i = 4;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"4 MOD -3", 9);
	i = 5;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"5 MOD -3", 9);
	i = 6;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"6 MOD -3", 9);
	i = 7;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"7 MOD -3", 9);
	i = -4;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-4 MOD -3", 10);
	i = -5;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-5 MOD -3", 10);
	i = -6;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-6 MOD -3", 10);
	i = -7;
	j = -3;
	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-7 MOD -3", 10);
}

static void TestLanguage_Abs (void)
{
	INT16 i;
	INT32 l;
	INT64 h;
	i = 5;
	TestLanguage_TestValue(__ABS(i), 5, (CHAR*)"ABS(INTEGER 5)", 15);
	i = -5;
	TestLanguage_TestValue(__ABS(i), 5, (CHAR*)"ABS(INTEGER -5)", 16);
	l = 5;
	TestLanguage_TestValue(__ABS(l), 5, (CHAR*)"ABS(LONGINT 5)", 15);
	l = -5;
	TestLanguage_TestValue(__ABS(l), 5, (CHAR*)"ABS(LONGINT -5)", 16);
	h = 5;
	TestLanguage_TestValue((INT32)__ABS(h), 5, (CHAR*)"ABS(SYSTEM.INT64 5)", 20);
	h = -5;
	TestLanguage_TestValue((INT32)__ABS(h), 5, (CHAR*)"ABS(SYSTEM.INT64 -5)", 21);
}

static LONGREAL TestLanguage_LR (LONGREAL lr)
{
	return lr + TestLanguage_gz;
}

static void TestLanguage_Entier (void)
{
	LONGREAL lr;
	TestLanguage_gz = (LONGREAL)0;
	lr = TestLanguage_LR( -9.99999977648258e-003);
	TestLanguage_TestValue((INT32)__ENTIER(lr), -1, (CHAR*)"ENTIER(-0.01", 13);
	lr = TestLanguage_LR((LONGREAL)0);
	TestLanguage_TestValue((INT32)__ENTIER(lr), 0, (CHAR*)"ENTIER(0.00", 12);
	lr = TestLanguage_LR((LONGREAL)5);
	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.00", 12);
	lr = TestLanguage_LR(  5.50000000000000e+000);
	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.50", 12);
	lr = TestLanguage_LR(  5.98999977111816e+000);
	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.99", 12);
	lr = TestLanguage_LR((LONGREAL)-5);
	TestLanguage_TestValue((INT32)__ENTIER(lr), -5, (CHAR*)"ENTIER(-5.00", 13);
	lr = TestLanguage_LR( -5.50000000000000e+000);
	TestLanguage_TestValue((INT32)__ENTIER(lr), -6, (CHAR*)"ENTIER(-5.50", 13);
	lr = TestLanguage_LR( -5.98999977111816e+000);
	TestLanguage_TestValue((INT32)__ENTIER(lr), -6, (CHAR*)"ENTIER(-5.99", 13);
}

static void TestLanguage_IntSize (void)
{
	INT32 l;
	TestLanguage_TestValue(-128, -128, (CHAR*)"MIN(SHORTINT)", 14);
	TestLanguage_TestValue(127, 127, (CHAR*)"MAX(SHORTINT)", 14);
	TestLanguage_TestValue((-32767-1), (-32767-1), (CHAR*)"MIN(INTEGER)", 13);
	TestLanguage_TestValue(32767, 32767, (CHAR*)"MAX(INTEGER)", 13);
	TestLanguage_TestValue((-2147483647-1), (-2147483647-1), (CHAR*)"MIN(LONGINT)", 13);
	TestLanguage_TestValue(2147483647, 2147483647, (CHAR*)"MAX(LONGINT)", 13);
}


export int main(int argc, char **argv)
{
	__INIT(argc, argv);
	__MODULE_IMPORT(Console);
	__REGMAIN("TestLanguage", 0);
/* BEGIN */
	TestLanguage_Shift();
	TestLanguage_DivMod();
	TestLanguage_IntSize();
	TestLanguage_Abs();
	TestLanguage_Entier();
	Console_String((CHAR*)"Language tests successful.", 27);
	Console_Ln();
	__FINI;
}
