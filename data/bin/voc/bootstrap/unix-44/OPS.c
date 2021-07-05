/* voc 2.1.0 [2019/11/01]. Bootstrapping compiler for address size 8, alignment 8. xrtspaSF */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "OPM.h"

typedef
	CHAR OPS_Name[256];

typedef
	CHAR OPS_String[256];


export OPS_Name OPS_name;
export OPS_String OPS_str;
export INT16 OPS_numtyp;
export INT64 OPS_intval;
export REAL OPS_realval;
export LONGREAL OPS_lrlval;
static CHAR OPS_ch;


export void OPS_Get (INT8 *sym);
static void OPS_Identifier (INT8 *sym);
export void OPS_Init (void);
static void OPS_Number (void);
static void OPS_Str (INT8 *sym);
static void OPS_err (INT16 n);


static void OPS_err (INT16 n)
{
	OPM_err(n);
}

static void OPS_Str (INT8 *sym)
{
	INT16 i;
	CHAR och;
	i = 0;
	och = OPS_ch;
	for (;;) {
		OPM_Get(&OPS_ch);
		if (OPS_ch == och) {
			break;
		}
		if (OPS_ch < ' ') {
			OPS_err(3);
			break;
		}
		if (i == 255) {
			OPS_err(241);
			break;
		}
		OPS_str[__X(i, 256)] = OPS_ch;
		i += 1;
	}
	OPM_Get(&OPS_ch);
	OPS_str[__X(i, 256)] = 0x00;
	OPS_intval = i + 1;
	if (OPS_intval == 2) {
		*sym = 35;
		OPS_numtyp = 1;
		OPS_intval = (INT16)OPS_str[0];
	} else {
		*sym = 37;
	}
}

static void OPS_Identifier (INT8 *sym)
{
	INT16 i;
	i = 0;
	do {
		OPS_name[__X(i, 256)] = OPS_ch;
		i += 1;
		OPM_Get(&OPS_ch);
	} while (!(((OPS_ch < '0' || ('9' < OPS_ch && __CAP(OPS_ch) < 'A')) || 'Z' < __CAP(OPS_ch)) || i == 256));
	if (i == 256) {
		OPS_err(240);
		i -= 1;
	}
	OPS_name[__X(i, 256)] = 0x00;
	*sym = 38;
}

static struct Number__6 {
	struct Number__6 *lnk;
} *Number__6_s;

static INT16 Ord__7 (CHAR ch, BOOLEAN hex);
static LONGREAL Ten__9 (INT16 e);

static LONGREAL Ten__9 (INT16 e)
{
	LONGREAL x, p;
	x = (LONGREAL)1;
	p = (LONGREAL)10;
	while (e > 0) {
		if (__ODD(e)) {
			x = x * p;
		}
		e = __ASHR(e, 1);
		if (e > 0) {
			p = p * p;
		}
	}
	return x;
}

static INT16 Ord__7 (CHAR ch, BOOLEAN hex)
{
	if (ch <= '9') {
		return (INT16)ch - 48;
	} else if (hex) {
		return ((INT16)ch - 65) + 10;
	} else {
		OPS_err(2);
		return 0;
	}
	__RETCHK;
}

static void OPS_Number (void)
{
	INT16 i, m, n, d, e;
	CHAR dig[24];
	LONGREAL f;
	CHAR expCh;
	BOOLEAN neg;
	struct Number__6 _s;
	_s.lnk = Number__6_s;
	Number__6_s = &_s;
	i = 0;
	m = 0;
	n = 0;
	d = 0;
	for (;;) {
		if (('0' <= OPS_ch && OPS_ch <= '9') || (((d == 0 && 'A' <= OPS_ch)) && OPS_ch <= 'F')) {
			if (m > 0 || OPS_ch != '0') {
				if (n < 24) {
					dig[__X(n, 24)] = OPS_ch;
					n += 1;
				}
				m += 1;
			}
			OPM_Get(&OPS_ch);
			i += 1;
		} else if (OPS_ch == '.') {
			OPM_Get(&OPS_ch);
			if (OPS_ch == '.') {
				OPS_ch = 0x7f;
				break;
			} else if (d == 0) {
				d = i;
			} else {
				OPS_err(2);
			}
		} else {
			break;
		}
	}
	if (d == 0) {
		if (n == m) {
			OPS_intval = 0;
			i = 0;
			if (OPS_ch == 'X') {
				OPM_Get(&OPS_ch);
				OPS_numtyp = 1;
				if (n <= 2) {
					while (i < n) {
						OPS_intval = __ASHL(OPS_intval, 4) + (INT64)Ord__7(dig[__X(i, 24)], 1);
						i += 1;
					}
				} else {
					OPS_err(203);
				}
			} else if (OPS_ch == 'H') {
				OPM_Get(&OPS_ch);
				OPS_numtyp = 2;
				if (n <= 16) {
					if ((n == 16 && dig[0] > '7')) {
						OPS_intval = -1;
					}
					while (i < n) {
						OPS_intval = __ASHL(OPS_intval, 4) + (INT64)Ord__7(dig[__X(i, 24)], 1);
						i += 1;
					}
				} else {
					OPS_err(203);
				}
			} else {
				OPS_numtyp = 2;
				while (i < n) {
					d = Ord__7(dig[__X(i, 24)], 0);
					i += 1;
					if (OPS_intval <= __DIV(9223372036854775807LL - (INT64)d, 10)) {
						OPS_intval = OPS_intval * 10 + (INT64)d;
					} else {
						OPS_err(203);
					}
				}
			}
		} else {
			OPS_err(203);
		}
	} else {
		f = (LONGREAL)0;
		e = 0;
		expCh = 'E';
		while (n > 0) {
			n -= 1;
			f = (Ord__7(dig[__X(n, 24)], 0) + f) / (LONGREAL)(LONGREAL)10;
		}
		if (OPS_ch == 'E' || OPS_ch == 'D') {
			expCh = OPS_ch;
			OPM_Get(&OPS_ch);
			neg = 0;
			if (OPS_ch == '-') {
				neg = 1;
				OPM_Get(&OPS_ch);
			} else if (OPS_ch == '+') {
				OPM_Get(&OPS_ch);
			}
			if (('0' <= OPS_ch && OPS_ch <= '9')) {
				do {
					n = Ord__7(OPS_ch, 0);
					OPM_Get(&OPS_ch);
					if (e <= __DIV(32767 - n, 10)) {
						e = e * 10 + n;
					} else {
						OPS_err(203);
					}
				} while (!(OPS_ch < '0' || '9' < OPS_ch));
				if (neg) {
					e = -e;
				}
			} else {
				OPS_err(2);
			}
		}
		e -= (i - d) - m;
		if (expCh == 'E') {
			OPS_numtyp = 3;
			if ((-37 < e && e <= 38)) {
				if (e < 0) {
					OPS_realval = (f / (LONGREAL)Ten__9(-e));
				} else {
					OPS_realval = (f * Ten__9(e));
				}
			} else {
				OPS_err(203);
			}
		} else {
			OPS_numtyp = 4;
			if ((-307 < e && e <= 308)) {
				if (e < 0) {
					OPS_lrlval = f / (LONGREAL)Ten__9(-e);
				} else {
					OPS_lrlval = f * Ten__9(e);
				}
			} else {
				OPS_err(203);
			}
		}
	}
	Number__6_s = _s.lnk;
}

static struct Get__1 {
	struct Get__1 *lnk;
} *Get__1_s;

static void Comment__2 (void);

static void Comment__2 (void)
{
	OPM_Get(&OPS_ch);
	for (;;) {
		for (;;) {
			while (OPS_ch == '(') {
				OPM_Get(&OPS_ch);
				if (OPS_ch == '*') {
					Comment__2();
				}
			}
			if (OPS_ch == '*') {
				OPM_Get(&OPS_ch);
				break;
			}
			if (OPS_ch == 0x00) {
				break;
			}
			OPM_Get(&OPS_ch);
		}
		if (OPS_ch == ')') {
			OPM_Get(&OPS_ch);
			break;
		}
		if (OPS_ch == 0x00) {
			OPS_err(5);
			break;
		}
	}
}

void OPS_Get (INT8 *sym)
{
	INT8 s;
	struct Get__1 _s;
	_s.lnk = Get__1_s;
	Get__1_s = &_s;
	OPM_errpos = OPM_curpos - 1;
	while (OPS_ch <= ' ') {
		if (OPS_ch == 0x00) {
			*sym = 64;
			Get__1_s = _s.lnk;
			return;
		} else {
			OPM_Get(&OPS_ch);
		}
	}
	switch (OPS_ch) {
		case '"': case '\'': 
			OPS_Str(&s);
			break;
		case '#': 
			s = 10;
			OPM_Get(&OPS_ch);
			break;
		case '&': 
			s = 5;
			OPM_Get(&OPS_ch);
			break;
		case '(': 
			OPM_Get(&OPS_ch);
			if (OPS_ch == '*') {
				Comment__2();
				OPS_Get(&s);
			} else {
				s = 30;
			}
			break;
		case ')': 
			s = 22;
			OPM_Get(&OPS_ch);
			break;
		case '*': 
			s = 1;
			OPM_Get(&OPS_ch);
			break;
		case '+': 
			s = 6;
			OPM_Get(&OPS_ch);
			break;
		case ',': 
			s = 19;
			OPM_Get(&OPS_ch);
			break;
		case '-': 
			s = 7;
			OPM_Get(&OPS_ch);
			break;
		case '.': 
			OPM_Get(&OPS_ch);
			if (OPS_ch == '.') {
				OPM_Get(&OPS_ch);
				s = 21;
			} else {
				s = 18;
			}
			break;
		case '/': 
			s = 2;
			OPM_Get(&OPS_ch);
			break;
		case '0': case '1': case '2': case '3': case '4': 
		case '5': case '6': case '7': case '8': case '9': 
			OPS_Number();
			s = 35;
			break;
		case ':': 
			OPM_Get(&OPS_ch);
			if (OPS_ch == '=') {
				OPM_Get(&OPS_ch);
				s = 34;
			} else {
				s = 20;
			}
			break;
		case ';': 
			s = 39;
			OPM_Get(&OPS_ch);
			break;
		case '<': 
			OPM_Get(&OPS_ch);
			if (OPS_ch == '=') {
				OPM_Get(&OPS_ch);
				s = 12;
			} else {
				s = 11;
			}
			break;
		case '=': 
			s = 9;
			OPM_Get(&OPS_ch);
			break;
		case '>': 
			OPM_Get(&OPS_ch);
			if (OPS_ch == '=') {
				OPM_Get(&OPS_ch);
				s = 14;
			} else {
				s = 13;
			}
			break;
		case 'A': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "ARRAY") == 0) {
				s = 54;
			}
			break;
		case 'B': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "BEGIN") == 0) {
				s = 57;
			} else if (__STRCMP(OPS_name, "BY") == 0) {
				s = 29;
			}
			break;
		case 'C': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "CASE") == 0) {
				s = 46;
			} else if (__STRCMP(OPS_name, "CONST") == 0) {
				s = 58;
			}
			break;
		case 'D': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "DO") == 0) {
				s = 27;
			} else if (__STRCMP(OPS_name, "DIV") == 0) {
				s = 3;
			}
			break;
		case 'E': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "END") == 0) {
				s = 41;
			} else if (__STRCMP(OPS_name, "ELSE") == 0) {
				s = 42;
			} else if (__STRCMP(OPS_name, "ELSIF") == 0) {
				s = 43;
			} else if (__STRCMP(OPS_name, "EXIT") == 0) {
				s = 52;
			}
			break;
		case 'F': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "FOR") == 0) {
				s = 49;
			}
			break;
		case 'I': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "IF") == 0) {
				s = 45;
			} else if (__STRCMP(OPS_name, "IN") == 0) {
				s = 15;
			} else if (__STRCMP(OPS_name, "IS") == 0) {
				s = 16;
			} else if (__STRCMP(OPS_name, "IMPORT") == 0) {
				s = 62;
			}
			break;
		case 'L': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "LOOP") == 0) {
				s = 50;
			}
			break;
		case 'M': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "MOD") == 0) {
				s = 4;
			} else if (__STRCMP(OPS_name, "MODULE") == 0) {
				s = 63;
			}
			break;
		case 'N': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "NIL") == 0) {
				s = 36;
			}
			break;
		case 'O': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "OR") == 0) {
				s = 8;
			} else if (__STRCMP(OPS_name, "OF") == 0) {
				s = 25;
			}
			break;
		case 'P': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "PROCEDURE") == 0) {
				s = 61;
			} else if (__STRCMP(OPS_name, "POINTER") == 0) {
				s = 56;
			}
			break;
		case 'R': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "RECORD") == 0) {
				s = 55;
			} else if (__STRCMP(OPS_name, "REPEAT") == 0) {
				s = 48;
			} else if (__STRCMP(OPS_name, "RETURN") == 0) {
				s = 53;
			}
			break;
		case 'T': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "THEN") == 0) {
				s = 26;
			} else if (__STRCMP(OPS_name, "TO") == 0) {
				s = 28;
			} else if (__STRCMP(OPS_name, "TYPE") == 0) {
				s = 59;
			}
			break;
		case 'U': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "UNTIL") == 0) {
				s = 44;
			}
			break;
		case 'V': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "VAR") == 0) {
				s = 60;
			}
			break;
		case 'W': 
			OPS_Identifier(&s);
			if (__STRCMP(OPS_name, "WHILE") == 0) {
				s = 47;
			} else if (__STRCMP(OPS_name, "WITH") == 0) {
				s = 51;
			}
			break;
		case 'G': case 'H': case 'J': case 'K': case 'Q': 
		case 'S': case 'X': case 'Y': case 'Z': 
			OPS_Identifier(&s);
			break;
		case '[': 
			s = 31;
			OPM_Get(&OPS_ch);
			break;
		case ']': 
			s = 23;
			OPM_Get(&OPS_ch);
			break;
		case '^': 
			s = 17;
			OPM_Get(&OPS_ch);
			break;
		case 'a': case 'b': case 'c': case 'd': case 'e': 
		case 'f': case 'g': case 'h': case 'i': case 'j': 
		case 'k': case 'l': case 'm': case 'n': case 'o': 
		case 'p': case 'q': case 'r': case 's': case 't': 
		case 'u': case 'v': case 'w': case 'x': case 'y': 
		case 'z': 
			OPS_Identifier(&s);
			break;
		case '{': 
			s = 32;
			OPM_Get(&OPS_ch);
			break;
		case '|': 
			s = 40;
			OPM_Get(&OPS_ch);
			break;
		case '}': 
			s = 24;
			OPM_Get(&OPS_ch);
			break;
		case '~': 
			s = 33;
			OPM_Get(&OPS_ch);
			break;
		case 0x7f: 
			s = 21;
			OPM_Get(&OPS_ch);
			break;
		default: 
			s = 0;
			OPM_Get(&OPS_ch);
			break;
	}
	*sym = s;
	Get__1_s = _s.lnk;
}

void OPS_Init (void)
{
	OPS_ch = ' ';
}


export void *OPS__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(OPM);
	__REGMOD("OPS", 0);
	__REGCMD("Init", OPS_Init);
/* BEGIN */
	__ENDMOD;
}
