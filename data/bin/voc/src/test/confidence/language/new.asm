   1              		.file	"TestLanguage.c"
   4              		.text
   5              	.Ltext0:
  49              		.local	TestLanguage_gz
  50              		.comm	TestLanguage_gz,8,8
  52              		.section	.rodata
  53              	.LC0:
  54 0000 206F6620 		.string	" of $"
  54      2400
  55              	.LC1:
  56 0006 20627920 		.string	" by "
  56      00
  57              	.LC2:
  58 000b 20697320 		.string	" is $"
  58      2400
  59              	.LC3:
  60 0011 20627574 		.string	" but should be $"
  60      2073686F 
  60      756C6420 
  60      62652024 
  60      00
  61              		.text
  70              	TestLanguage_TestShiftResult:
  71              		.stabd	46,0,0
   1:TestLanguage.c **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:TestLanguage.c **** 
   3:TestLanguage.c **** #define SHORTINT INT8
   4:TestLanguage.c **** #define INTEGER  INT16
   5:TestLanguage.c **** #define LONGINT  INT32
   6:TestLanguage.c **** #define SET      UINT32
   7:TestLanguage.c **** 
   8:TestLanguage.c **** #include "SYSTEM.h"
   9:TestLanguage.c **** #include "Console.h"
  10:TestLanguage.c **** 
  11:TestLanguage.c **** 
  12:TestLanguage.c **** static LONGREAL TestLanguage_gz;
  13:TestLanguage.c **** 
  14:TestLanguage.c **** 
  15:TestLanguage.c **** static void TestLanguage_Abs (void);
  16:TestLanguage.c **** static void TestLanguage_DivMod (void);
  17:TestLanguage.c **** static void TestLanguage_Entier (void);
  18:TestLanguage.c **** static void TestLanguage_IntSize (void);
  19:TestLanguage.c **** static LONGREAL TestLanguage_LR (LONGREAL lr);
  20:TestLanguage.c **** static void TestLanguage_Shift (void);
  21:TestLanguage.c **** static void TestLanguage_TestShiftResult (INT32 of, INT32 by, INT32 actual, INT32 expected, CHAR *m
  22:TestLanguage.c **** static void TestLanguage_TestValue (INT32 v, INT32 e, CHAR *name, ADDRESS name__len);
  23:TestLanguage.c **** static INT16 TestLanguage_side (INT16 i);
  24:TestLanguage.c **** 
  25:TestLanguage.c **** 
  26:TestLanguage.c **** static void TestLanguage_TestShiftResult (INT32 of, INT32 by, INT32 actual, INT32 expected, CHAR *m
  27:TestLanguage.c **** {
  73              	.LM0:
  74              	.LFBB1:
  75              	.LFB7:
  76              		.cfi_startproc
  77 0000 F30F1EFA 		endbr64
  78 0004 55       		pushq	%rbp
  79              		.cfi_def_cfa_offset 16
  80              		.cfi_offset 6, -16
  81 0005 4889E5   		movq	%rsp, %rbp
  82              		.cfi_def_cfa_register 6
  83 0008 4883EC30 		subq	$48, %rsp
  84 000c 897DEC   		movl	%edi, -20(%rbp)
  85 000f 8975E8   		movl	%esi, -24(%rbp)
  86 0012 8955E4   		movl	%edx, -28(%rbp)
  87 0015 894DE0   		movl	%ecx, -32(%rbp)
  88 0018 4C8945D8 		movq	%r8, -40(%rbp)
  89 001c 4C894DD0 		movq	%r9, -48(%rbp)
  91              	.LM1:
  92 0020 64488B04 		movq	%fs:40, %rax
  92      25280000 
  92      00
  93 0029 488945F8 		movq	%rax, -8(%rbp)
  94 002d 31C0     		xorl	%eax, %eax
  28:TestLanguage.c **** 	__DUP(msg, msg__len, CHAR);
  96              	.LM2:
  97 002f 488B4DD0 		movq	-48(%rbp), %rcx
  98 0033 488B45D0 		movq	-48(%rbp), %rax
  99 0037 488D5008 		leaq	8(%rax), %rdx
 100 003b B8100000 		movl	$16, %eax
 100      00
 101 0040 4883E801 		subq	$1, %rax
 102 0044 4801D0   		addq	%rdx, %rax
 103 0047 BE100000 		movl	$16, %esi
 103      00
 104 004c BA000000 		movl	$0, %edx
 104      00
 105 0051 48F7F6   		divq	%rsi
 106 0054 486BC010 		imulq	$16, %rax, %rax
 107 0058 4889C2   		movq	%rax, %rdx
 108 005b 4881E200 		andq	$-4096, %rdx
 108      F0FFFF
 109 0062 4889E6   		movq	%rsp, %rsi
 110 0065 4829D6   		subq	%rdx, %rsi
 111 0068 4889F2   		movq	%rsi, %rdx
 112              	.L2:
 113 006b 4839D4   		cmpq	%rdx, %rsp
 114 006e 7412     		je	.L3
 115 0070 4881EC00 		subq	$4096, %rsp
 115      100000
 116 0077 48838C24 		orq	$0, 4088(%rsp)
 116      F80F0000 
 116      00
 117 0080 EBE9     		jmp	.L2
 118              	.L3:
 119 0082 4889C2   		movq	%rax, %rdx
 120 0085 81E2FF0F 		andl	$4095, %edx
 120      0000
 121 008b 4829D4   		subq	%rdx, %rsp
 122 008e 4889C2   		movq	%rax, %rdx
 123 0091 81E2FF0F 		andl	$4095, %edx
 123      0000
 124 0097 4885D2   		testq	%rdx, %rdx
 125 009a 7410     		je	.L4
 126 009c 25FF0F00 		andl	$4095, %eax
 126      00
 127 00a1 4883E808 		subq	$8, %rax
 128 00a5 4801E0   		addq	%rsp, %rax
 129 00a8 48830800 		orq	$0, (%rax)
 130              	.L4:
 131 00ac 4889E0   		movq	%rsp, %rax
 132 00af 4883C00F 		addq	$15, %rax
 133 00b3 48C1E804 		shrq	$4, %rax
 134 00b7 48C1E004 		salq	$4, %rax
 135 00bb 4889C7   		movq	%rax, %rdi
 136 00be 488B45D8 		movq	-40(%rbp), %rax
 137 00c2 4889CA   		movq	%rcx, %rdx
 138 00c5 4889C6   		movq	%rax, %rsi
 139 00c8 E8000000 		call	memcpy@PLT
 139      00
 140 00cd 488945D8 		movq	%rax, -40(%rbp)
  29:TestLanguage.c **** 	if (actual != expected) {
 142              	.LM3:
 143 00d1 8B45E4   		movl	-28(%rbp), %eax
 144 00d4 3B45E0   		cmpl	-32(%rbp), %eax
 145 00d7 0F848C00 		je	.L7
 145      0000
  30:TestLanguage.c **** 		Console_String(msg, msg__len);
 147              	.LM4:
 148 00dd 488B55D0 		movq	-48(%rbp), %rdx
 149 00e1 488B45D8 		movq	-40(%rbp), %rax
 150 00e5 4889D6   		movq	%rdx, %rsi
 151 00e8 4889C7   		movq	%rax, %rdi
 152 00eb E8000000 		call	Console_String@PLT
 152      00
  31:TestLanguage.c **** 		Console_String((CHAR*)" of $", 6);
 154              	.LM5:
 155 00f0 BE060000 		movl	$6, %esi
 155      00
 156 00f5 488D3D00 		leaq	.LC0(%rip), %rdi
 156      000000
 157 00fc E8000000 		call	Console_String@PLT
 157      00
  32:TestLanguage.c **** 		Console_Hex(of);
 159              	.LM6:
 160 0101 8B45EC   		movl	-20(%rbp), %eax
 161 0104 89C7     		movl	%eax, %edi
 162 0106 E8000000 		call	Console_Hex@PLT
 162      00
  33:TestLanguage.c **** 		Console_String((CHAR*)" by ", 5);
 164              	.LM7:
 165 010b BE050000 		movl	$5, %esi
 165      00
 166 0110 488D3D00 		leaq	.LC1(%rip), %rdi
 166      000000
 167 0117 E8000000 		call	Console_String@PLT
 167      00
  34:TestLanguage.c **** 		Console_Int(by, 1);
 169              	.LM8:
 170 011c 8B45E8   		movl	-24(%rbp), %eax
 171 011f 4898     		cltq
 172 0121 BE010000 		movl	$1, %esi
 172      00
 173 0126 4889C7   		movq	%rax, %rdi
 174 0129 E8000000 		call	Console_Int@PLT
 174      00
  35:TestLanguage.c **** 		Console_String((CHAR*)" is $", 6);
 176              	.LM9:
 177 012e BE060000 		movl	$6, %esi
 177      00
 178 0133 488D3D00 		leaq	.LC2(%rip), %rdi
 178      000000
 179 013a E8000000 		call	Console_String@PLT
 179      00
  36:TestLanguage.c **** 		Console_Hex(actual);
 181              	.LM10:
 182 013f 8B45E4   		movl	-28(%rbp), %eax
 183 0142 89C7     		movl	%eax, %edi
 184 0144 E8000000 		call	Console_Hex@PLT
 184      00
  37:TestLanguage.c **** 		Console_String((CHAR*)" but should be $", 17);
 186              	.LM11:
 187 0149 BE110000 		movl	$17, %esi
 187      00
 188 014e 488D3D00 		leaq	.LC3(%rip), %rdi
 188      000000
 189 0155 E8000000 		call	Console_String@PLT
 189      00
  38:TestLanguage.c **** 		Console_Hex(expected);
 191              	.LM12:
 192 015a 8B45E0   		movl	-32(%rbp), %eax
 193 015d 89C7     		movl	%eax, %edi
 194 015f E8000000 		call	Console_Hex@PLT
 194      00
  39:TestLanguage.c **** 		Console_Ln();
 196              	.LM13:
 197 0164 E8000000 		call	Console_Ln@PLT
 197      00
 198              	.L7:
  40:TestLanguage.c **** 	}
  41:TestLanguage.c **** 	__DEL(msg);
  42:TestLanguage.c **** }
 200              	.LM14:
 201 0169 90       		nop
 202 016a 488B45F8 		movq	-8(%rbp), %rax
 203 016e 64483304 		xorq	%fs:40, %rax
 203      25280000 
 203      00
 204 0177 7405     		je	.L6
 205 0179 E8000000 		call	__stack_chk_fail@PLT
 205      00
 206              	.L6:
 207 017e C9       		leave
 208              		.cfi_def_cfa 7, 8
 209 017f C3       		ret
 210              		.cfi_endproc
 211              	.LFE7:
 213              	.Lscope1:
 215              		.stabd	78,0,0
 216              		.section	.rodata
 217              	.LC4:
 218 0022 4C534800 		.string	"LSH"
 219              	.LC5:
 220 0026 524F5428 		.string	"ROT(1)"
 220      312900
 221              	.LC6:
 222 002d 524F5428 		.string	"ROT(2)"
 222      322900
 223              	.LC7:
 224 0034 524F5428 		.string	"ROT(3)"
 224      332900
 225              	.LC8:
 226 003b 524F5428 		.string	"ROT(4)"
 226      342900
 227              	.LC9:
 228 0042 524F5400 		.string	"ROT"
 229              		.text
 232              	TestLanguage_Shift:
 233              		.stabd	46,0,0
  43:TestLanguage.c **** 
  44:TestLanguage.c **** static void TestLanguage_Shift (void)
  45:TestLanguage.c **** {
 235              	.LM15:
 236              	.LFBB2:
 237              	.LFB8:
 238              		.cfi_startproc
 239 0180 F30F1EFA 		endbr64
 240 0184 55       		pushq	%rbp
 241              		.cfi_def_cfa_offset 16
 242              		.cfi_offset 6, -16
 243 0185 4889E5   		movq	%rsp, %rbp
 244              		.cfi_def_cfa_register 6
 245 0188 4883EC30 		subq	$48, %rsp
 247              	.LM16:
 248 018c 64488B04 		movq	%fs:40, %rax
 248      25280000 
 248      00
 249 0195 488945F8 		movq	%rax, -8(%rbp)
 250 0199 31C0     		xorl	%eax, %eax
  46:TestLanguage.c **** 	CHAR c;
  47:TestLanguage.c **** 	SYSTEM_BYTE b;
  48:TestLanguage.c **** 	INT8 s, t, u;
  49:TestLanguage.c **** 	INT16 h, i, j, k;
  50:TestLanguage.c **** 	INT32 l, m, n, r;
  51:TestLanguage.c **** 	i = 0;
 252              	.LM17:
 253 019b 66C745E0 		movw	$0, -32(%rbp)
 253      0000
  52:TestLanguage.c **** 	m = 1;
 255              	.LM18:
 256 01a1 C745E801 		movl	$1, -24(%rbp)
 256      000000
  53:TestLanguage.c **** 	while (i < 32) {
 258              	.LM19:
 259 01a8 E9C80000 		jmp	.L9
 259      00
 260              	.L14:
  54:TestLanguage.c **** 		l = 1;
 262              	.LM20:
 263 01ad C745F401 		movl	$1, -12(%rbp)
 263      000000
  55:TestLanguage.c **** 		r = __LSH(l, i, 32);
 265              	.LM21:
 266 01b4 66837DE0 		cmpw	$0, -32(%rbp)
 266      00
 267 01b9 780F     		js	.L10
 269              	.LM22:
 270 01bb 8B55F4   		movl	-12(%rbp), %edx
 271 01be 0FBF45E0 		movswl	-32(%rbp), %eax
 272 01c2 89C1     		movl	%eax, %ecx
 273 01c4 D3E2     		sall	%cl, %edx
 274 01c6 89D0     		movl	%edx, %eax
 275 01c8 EB0F     		jmp	.L11
 276              	.L10:
 278              	.LM23:
 279 01ca 8B55F4   		movl	-12(%rbp), %edx
 280 01cd 0FBF45E0 		movswl	-32(%rbp), %eax
 281 01d1 F7D8     		negl	%eax
 282 01d3 89C1     		movl	%eax, %ecx
 283 01d5 D3EA     		shrl	%cl, %edx
 284 01d7 89D0     		movl	%edx, %eax
 285              	.L11:
 287              	.LM24:
 288 01d9 8945F0   		movl	%eax, -16(%rbp)
  56:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"LSH", 4);
 290              	.LM25:
 291 01dc 0FBF75E0 		movswl	-32(%rbp), %esi
 292 01e0 8B4DE8   		movl	-24(%rbp), %ecx
 293 01e3 8B55F0   		movl	-16(%rbp), %edx
 294 01e6 8B45F4   		movl	-12(%rbp), %eax
 295 01e9 41B90400 		movl	$4, %r9d
 295      0000
 296 01ef 4C8D0500 		leaq	.LC4(%rip), %r8
 296      000000
 297 01f6 89C7     		movl	%eax, %edi
 298 01f8 E803FEFF 		call	TestLanguage_TestShiftResult
 298      FF
  57:TestLanguage.c **** 		l = 1;
 300              	.LM26:
 301 01fd C745F401 		movl	$1, -12(%rbp)
 301      000000
  58:TestLanguage.c **** 		r = __ROT(l, i, 32);
 303              	.LM27:
 304 0204 66837DE0 		cmpw	$0, -32(%rbp)
 304      00
 305 0209 780F     		js	.L12
 307              	.LM28:
 308 020b 8B55F4   		movl	-12(%rbp), %edx
 309 020e 0FBF45E0 		movswl	-32(%rbp), %eax
 310 0212 89C1     		movl	%eax, %ecx
 311 0214 D3C2     		roll	%cl, %edx
 312 0216 89D0     		movl	%edx, %eax
 313 0218 EB21     		jmp	.L13
 314              	.L12:
 316              	.LM29:
 317 021a 8B55F4   		movl	-12(%rbp), %edx
 318 021d 0FBF45E0 		movswl	-32(%rbp), %eax
 319 0221 F7D8     		negl	%eax
 320 0223 89D6     		movl	%edx, %esi
 321 0225 89C1     		movl	%eax, %ecx
 322 0227 D3EE     		shrl	%cl, %esi
 323 0229 8B55F4   		movl	-12(%rbp), %edx
 324 022c 0FBF45E0 		movswl	-32(%rbp), %eax
 325 0230 83C020   		addl	$32, %eax
 326 0233 89C1     		movl	%eax, %ecx
 327 0235 D3E2     		sall	%cl, %edx
 328 0237 89D0     		movl	%edx, %eax
 329 0239 09F0     		orl	%esi, %eax
 330              	.L13:
 332              	.LM30:
 333 023b 8945F0   		movl	%eax, -16(%rbp)
  59:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT(1)", 7);
 335              	.LM31:
 336 023e 0FBF75E0 		movswl	-32(%rbp), %esi
 337 0242 8B4DE8   		movl	-24(%rbp), %ecx
 338 0245 8B55F0   		movl	-16(%rbp), %edx
 339 0248 8B45F4   		movl	-12(%rbp), %eax
 340 024b 41B90700 		movl	$7, %r9d
 340      0000
 341 0251 4C8D0500 		leaq	.LC5(%rip), %r8
 341      000000
 342 0258 89C7     		movl	%eax, %edi
 343 025a E8A1FDFF 		call	TestLanguage_TestShiftResult
 343      FF
  60:TestLanguage.c **** 		m = __ASHL(m, 1);
 345              	.LM32:
 346 025f 8B45E8   		movl	-24(%rbp), %eax
 347 0262 4898     		cltq
 348 0264 4801C0   		addq	%rax, %rax
 350              	.LM33:
 351 0267 8945E8   		movl	%eax, -24(%rbp)
  61:TestLanguage.c **** 		i += 1;
 353              	.LM34:
 354 026a 0FB745E0 		movzwl	-32(%rbp), %eax
 355 026e 83C001   		addl	$1, %eax
 356 0271 668945E0 		movw	%ax, -32(%rbp)
 357              	.L9:
  53:TestLanguage.c **** 		l = 1;
 359              	.LM35:
 360 0275 66837DE0 		cmpw	$31, -32(%rbp)
 360      1F
 361 027a 0F8E2DFF 		jle	.L14
 361      FFFF
  62:TestLanguage.c **** 	}
  63:TestLanguage.c **** 	i = 0;
 363              	.LM36:
 364 0280 66C745E0 		movw	$0, -32(%rbp)
 364      0000
  64:TestLanguage.c **** 	k = 1;
 366              	.LM37:
 367 0286 66C745E2 		movw	$1, -30(%rbp)
 367      0100
  65:TestLanguage.c **** 	while (i < 16) {
 369              	.LM38:
 370 028c E9E30000 		jmp	.L15
 370      00
 371              	.L22:
  66:TestLanguage.c **** 		j = 1;
 373              	.LM39:
 374 0291 66C745E6 		movw	$1, -26(%rbp)
 374      0100
  67:TestLanguage.c **** 		j = __LSH(j, i, 16);
 376              	.LM40:
 377 0297 66837DE0 		cmpw	$0, -32(%rbp)
 377      00
 378 029c 7813     		js	.L16
 380              	.LM41:
 381 029e 0FB745E6 		movzwl	-26(%rbp), %eax
 382 02a2 0FB7D0   		movzwl	%ax, %edx
 383 02a5 0FBF45E0 		movswl	-32(%rbp), %eax
 384 02a9 89C1     		movl	%eax, %ecx
 385 02ab D3E2     		sall	%cl, %edx
 386 02ad 89D0     		movl	%edx, %eax
 387 02af EB13     		jmp	.L17
 388              	.L16:
 390              	.LM42:
 391 02b1 0FB745E6 		movzwl	-26(%rbp), %eax
 392 02b5 0FB7D0   		movzwl	%ax, %edx
 393 02b8 0FBF45E0 		movswl	-32(%rbp), %eax
 394 02bc F7D8     		negl	%eax
 395 02be 89C1     		movl	%eax, %ecx
 396 02c0 D3FA     		sarl	%cl, %edx
 397 02c2 89D0     		movl	%edx, %eax
 398              	.L17:
 400              	.LM43:
 401 02c4 668945E6 		movw	%ax, -26(%rbp)
  68:TestLanguage.c **** 		__ASSERT(j == k, 23);
 403              	.LM44:
 404 02c8 0FB745E6 		movzwl	-26(%rbp), %eax
 405 02cc 663B45E2 		cmpw	-30(%rbp), %ax
 406 02d0 740A     		je	.L18
 408              	.LM45:
 409 02d2 BF170000 		movl	$23, %edi
 409      00
 410 02d7 E8000000 		call	Modules_AssertFail@PLT
 410      00
 411              	.L18:
  69:TestLanguage.c **** 		j = 1;
 413              	.LM46:
 414 02dc 66C745E6 		movw	$1, -26(%rbp)
 414      0100
  70:TestLanguage.c **** 		j = __ROT(j, i, 16);
 416              	.LM47:
 417 02e2 66837DE0 		cmpw	$0, -32(%rbp)
 417      00
 418 02e7 7831     		js	.L19
 420              	.LM48:
 421 02e9 0FB745E6 		movzwl	-26(%rbp), %eax
 422 02ed 0FB7D0   		movzwl	%ax, %edx
 423 02f0 0FBF45E0 		movswl	-32(%rbp), %eax
 424 02f4 89C1     		movl	%eax, %ecx
 425 02f6 D3E2     		sall	%cl, %edx
 426 02f8 89D0     		movl	%edx, %eax
 427 02fa 89C6     		movl	%eax, %esi
 428 02fc 0FB745E6 		movzwl	-26(%rbp), %eax
 429 0300 0FB7D0   		movzwl	%ax, %edx
 430 0303 0FBF45E0 		movswl	-32(%rbp), %eax
 431 0307 B9100000 		movl	$16, %ecx
 431      00
 432 030c 29C1     		subl	%eax, %ecx
 433 030e 89C8     		movl	%ecx, %eax
 434 0310 89C1     		movl	%eax, %ecx
 435 0312 D3FA     		sarl	%cl, %edx
 436 0314 89D0     		movl	%edx, %eax
 438              	.LM49:
 439 0316 09F0     		orl	%esi, %eax
 440 0318 EB2B     		jmp	.L20
 441              	.L19:
 443              	.LM50:
 444 031a 0FB745E6 		movzwl	-26(%rbp), %eax
 445 031e 0FB7D0   		movzwl	%ax, %edx
 446 0321 0FBF45E0 		movswl	-32(%rbp), %eax
 447 0325 F7D8     		negl	%eax
 448 0327 89C1     		movl	%eax, %ecx
 449 0329 D3FA     		sarl	%cl, %edx
 450 032b 89D0     		movl	%edx, %eax
 451 032d 89C6     		movl	%eax, %esi
 452 032f 0FB745E6 		movzwl	-26(%rbp), %eax
 453 0333 0FB7D0   		movzwl	%ax, %edx
 454 0336 0FBF45E0 		movswl	-32(%rbp), %eax
 455 033a 83C010   		addl	$16, %eax
 456 033d 89C1     		movl	%eax, %ecx
 457 033f D3E2     		sall	%cl, %edx
 458 0341 89D0     		movl	%edx, %eax
 460              	.LM51:
 461 0343 09F0     		orl	%esi, %eax
 462              	.L20:
 464              	.LM52:
 465 0345 668945E6 		movw	%ax, -26(%rbp)
  71:TestLanguage.c **** 		__ASSERT(j == k, 24);
 467              	.LM53:
 468 0349 0FB745E6 		movzwl	-26(%rbp), %eax
 469 034d 663B45E2 		cmpw	-30(%rbp), %ax
 470 0351 740A     		je	.L21
 472              	.LM54:
 473 0353 BF180000 		movl	$24, %edi
 473      00
 474 0358 E8000000 		call	Modules_AssertFail@PLT
 474      00
 475              	.L21:
  72:TestLanguage.c **** 		k = __ASHL(k, 1);
 477              	.LM55:
 478 035d 480FBF45 		movswq	-30(%rbp), %rax
 478      E2
 479 0362 4801C0   		addq	%rax, %rax
 481              	.LM56:
 482 0365 668945E2 		movw	%ax, -30(%rbp)
  73:TestLanguage.c **** 		i += 1;
 484              	.LM57:
 485 0369 0FB745E0 		movzwl	-32(%rbp), %eax
 486 036d 83C001   		addl	$1, %eax
 487 0370 668945E0 		movw	%ax, -32(%rbp)
 488              	.L15:
  65:TestLanguage.c **** 		j = 1;
 490              	.LM58:
 491 0374 66837DE0 		cmpw	$15, -32(%rbp)
 491      0F
 492 0379 0F8E12FF 		jle	.L22
 492      FFFF
  74:TestLanguage.c **** 	}
  75:TestLanguage.c **** 	i = 0;
 494              	.LM59:
 495 037f 66C745E0 		movw	$0, -32(%rbp)
 495      0000
  76:TestLanguage.c **** 	t = 1;
 497              	.LM60:
 498 0385 C645DC01 		movb	$1, -36(%rbp)
  77:TestLanguage.c **** 	while (i < 8) {
 500              	.LM61:
 501 0389 E9DA0000 		jmp	.L23
 501      00
 502              	.L30:
  78:TestLanguage.c **** 		s = 1;
 504              	.LM62:
 505 038e C645DE01 		movb	$1, -34(%rbp)
  79:TestLanguage.c **** 		s = __LSH(s, i, 8);
 507              	.LM63:
 508 0392 66837DE0 		cmpw	$0, -32(%rbp)
 508      00
 509 0397 7813     		js	.L24
 511              	.LM64:
 512 0399 0FB645DE 		movzbl	-34(%rbp), %eax
 513 039d 0FB6D0   		movzbl	%al, %edx
 514 03a0 0FBF45E0 		movswl	-32(%rbp), %eax
 515 03a4 89C1     		movl	%eax, %ecx
 516 03a6 D3E2     		sall	%cl, %edx
 517 03a8 89D0     		movl	%edx, %eax
 518 03aa EB13     		jmp	.L25
 519              	.L24:
 521              	.LM65:
 522 03ac 0FB645DE 		movzbl	-34(%rbp), %eax
 523 03b0 0FB6D0   		movzbl	%al, %edx
 524 03b3 0FBF45E0 		movswl	-32(%rbp), %eax
 525 03b7 F7D8     		negl	%eax
 526 03b9 89C1     		movl	%eax, %ecx
 527 03bb D3FA     		sarl	%cl, %edx
 528 03bd 89D0     		movl	%edx, %eax
 529              	.L25:
 531              	.LM66:
 532 03bf 8845DE   		movb	%al, -34(%rbp)
  80:TestLanguage.c **** 		__ASSERT(s == t, 30);
 534              	.LM67:
 535 03c2 0FB645DE 		movzbl	-34(%rbp), %eax
 536 03c6 3A45DC   		cmpb	-36(%rbp), %al
 537 03c9 740A     		je	.L26
 539              	.LM68:
 540 03cb BF1E0000 		movl	$30, %edi
 540      00
 541 03d0 E8000000 		call	Modules_AssertFail@PLT
 541      00
 542              	.L26:
  81:TestLanguage.c **** 		s = 1;
 544              	.LM69:
 545 03d5 C645DE01 		movb	$1, -34(%rbp)
  82:TestLanguage.c **** 		s = __ROT(s, i, 8);
 547              	.LM70:
 548 03d9 66837DE0 		cmpw	$0, -32(%rbp)
 548      00
 549 03de 7831     		js	.L27
 551              	.LM71:
 552 03e0 0FB645DE 		movzbl	-34(%rbp), %eax
 553 03e4 0FB6D0   		movzbl	%al, %edx
 554 03e7 0FBF45E0 		movswl	-32(%rbp), %eax
 555 03eb 89C1     		movl	%eax, %ecx
 556 03ed D3E2     		sall	%cl, %edx
 557 03ef 89D0     		movl	%edx, %eax
 558 03f1 89C6     		movl	%eax, %esi
 559 03f3 0FB645DE 		movzbl	-34(%rbp), %eax
 560 03f7 0FB6D0   		movzbl	%al, %edx
 561 03fa 0FBF45E0 		movswl	-32(%rbp), %eax
 562 03fe B9080000 		movl	$8, %ecx
 562      00
 563 0403 29C1     		subl	%eax, %ecx
 564 0405 89C8     		movl	%ecx, %eax
 565 0407 89C1     		movl	%eax, %ecx
 566 0409 D3FA     		sarl	%cl, %edx
 567 040b 89D0     		movl	%edx, %eax
 569              	.LM72:
 570 040d 09F0     		orl	%esi, %eax
 571 040f EB2B     		jmp	.L28
 572              	.L27:
 574              	.LM73:
 575 0411 0FB645DE 		movzbl	-34(%rbp), %eax
 576 0415 0FB6D0   		movzbl	%al, %edx
 577 0418 0FBF45E0 		movswl	-32(%rbp), %eax
 578 041c F7D8     		negl	%eax
 579 041e 89C1     		movl	%eax, %ecx
 580 0420 D3FA     		sarl	%cl, %edx
 581 0422 89D0     		movl	%edx, %eax
 582 0424 89C6     		movl	%eax, %esi
 583 0426 0FB645DE 		movzbl	-34(%rbp), %eax
 584 042a 0FB6D0   		movzbl	%al, %edx
 585 042d 0FBF45E0 		movswl	-32(%rbp), %eax
 586 0431 83C008   		addl	$8, %eax
 587 0434 89C1     		movl	%eax, %ecx
 588 0436 D3E2     		sall	%cl, %edx
 589 0438 89D0     		movl	%edx, %eax
 591              	.LM74:
 592 043a 09F0     		orl	%esi, %eax
 593              	.L28:
 595              	.LM75:
 596 043c 8845DE   		movb	%al, -34(%rbp)
  83:TestLanguage.c **** 		__ASSERT(s == t, 31);
 598              	.LM76:
 599 043f 0FB645DE 		movzbl	-34(%rbp), %eax
 600 0443 3A45DC   		cmpb	-36(%rbp), %al
 601 0446 740A     		je	.L29
 603              	.LM77:
 604 0448 BF1F0000 		movl	$31, %edi
 604      00
 605 044d E8000000 		call	Modules_AssertFail@PLT
 605      00
 606              	.L29:
  84:TestLanguage.c **** 		t = __ASHL(t, 1);
 608              	.LM78:
 609 0452 480FBE45 		movsbq	-36(%rbp), %rax
 609      DC
 610 0457 4801C0   		addq	%rax, %rax
 612              	.LM79:
 613 045a 8845DC   		movb	%al, -36(%rbp)
  85:TestLanguage.c **** 		i += 1;
 615              	.LM80:
 616 045d 0FB745E0 		movzwl	-32(%rbp), %eax
 617 0461 83C001   		addl	$1, %eax
 618 0464 668945E0 		movw	%ax, -32(%rbp)
 619              	.L23:
  77:TestLanguage.c **** 		s = 1;
 621              	.LM81:
 622 0468 66837DE0 		cmpw	$7, -32(%rbp)
 622      07
 623 046d 0F8E1BFF 		jle	.L30
 623      FFFF
  86:TestLanguage.c **** 	}
  87:TestLanguage.c **** 	i = -1;
 625              	.LM82:
 626 0473 66C745E0 		movw	$-1, -32(%rbp)
 626      FFFF
  88:TestLanguage.c **** 	m = 1;
 628              	.LM83:
 629 0479 C745E801 		movl	$1, -24(%rbp)
 629      000000
  89:TestLanguage.c **** 	m = __LSHL(m, 30, 32);
 631              	.LM84:
 632 0480 8B45E8   		movl	-24(%rbp), %eax
 633 0483 C1E01E   		sall	$30, %eax
 635              	.LM85:
 636 0486 8945E8   		movl	%eax, -24(%rbp)
  90:TestLanguage.c **** 	n = __ASHL(m, 1);
 638              	.LM86:
 639 0489 8B45E8   		movl	-24(%rbp), %eax
 640 048c 4898     		cltq
 641 048e 4801C0   		addq	%rax, %rax
 643              	.LM87:
 644 0491 8945EC   		movl	%eax, -20(%rbp)
  91:TestLanguage.c **** 	while (i > -32) {
 646              	.LM88:
 647 0494 E9A00000 		jmp	.L31
 647      00
 648              	.L38:
  92:TestLanguage.c **** 		l = n;
 650              	.LM89:
 651 0499 8B45EC   		movl	-20(%rbp), %eax
 652 049c 8945F4   		movl	%eax, -12(%rbp)
  93:TestLanguage.c **** 		l = __LSH(l, i, 32);
 654              	.LM90:
 655 049f 66837DE0 		cmpw	$0, -32(%rbp)
 655      00
 656 04a4 780F     		js	.L32
 658              	.LM91:
 659 04a6 8B55F4   		movl	-12(%rbp), %edx
 660 04a9 0FBF45E0 		movswl	-32(%rbp), %eax
 661 04ad 89C1     		movl	%eax, %ecx
 662 04af D3E2     		sall	%cl, %edx
 663 04b1 89D0     		movl	%edx, %eax
 664 04b3 EB0F     		jmp	.L33
 665              	.L32:
 667              	.LM92:
 668 04b5 8B55F4   		movl	-12(%rbp), %edx
 669 04b8 0FBF45E0 		movswl	-32(%rbp), %eax
 670 04bc F7D8     		negl	%eax
 671 04be 89C1     		movl	%eax, %ecx
 672 04c0 D3EA     		shrl	%cl, %edx
 673 04c2 89D0     		movl	%edx, %eax
 674              	.L33:
 676              	.LM93:
 677 04c4 8945F4   		movl	%eax, -12(%rbp)
  94:TestLanguage.c **** 		__ASSERT(l == m, 39);
 679              	.LM94:
 680 04c7 8B45F4   		movl	-12(%rbp), %eax
 681 04ca 3B45E8   		cmpl	-24(%rbp), %eax
 682 04cd 740A     		je	.L34
 684              	.LM95:
 685 04cf BF270000 		movl	$39, %edi
 685      00
 686 04d4 E8000000 		call	Modules_AssertFail@PLT
 686      00
 687              	.L34:
  95:TestLanguage.c **** 		l = n;
 689              	.LM96:
 690 04d9 8B45EC   		movl	-20(%rbp), %eax
 691 04dc 8945F4   		movl	%eax, -12(%rbp)
  96:TestLanguage.c **** 		l = __ROT(l, i, 32);
 693              	.LM97:
 694 04df 66837DE0 		cmpw	$0, -32(%rbp)
 694      00
 695 04e4 780F     		js	.L35
 697              	.LM98:
 698 04e6 8B55F4   		movl	-12(%rbp), %edx
 699 04e9 0FBF45E0 		movswl	-32(%rbp), %eax
 700 04ed 89C1     		movl	%eax, %ecx
 701 04ef D3C2     		roll	%cl, %edx
 702 04f1 89D0     		movl	%edx, %eax
 703 04f3 EB21     		jmp	.L36
 704              	.L35:
 706              	.LM99:
 707 04f5 8B55F4   		movl	-12(%rbp), %edx
 708 04f8 0FBF45E0 		movswl	-32(%rbp), %eax
 709 04fc F7D8     		negl	%eax
 710 04fe 89D6     		movl	%edx, %esi
 711 0500 89C1     		movl	%eax, %ecx
 712 0502 D3EE     		shrl	%cl, %esi
 713 0504 8B55F4   		movl	-12(%rbp), %edx
 714 0507 0FBF45E0 		movswl	-32(%rbp), %eax
 715 050b 83C020   		addl	$32, %eax
 716 050e 89C1     		movl	%eax, %ecx
 717 0510 D3E2     		sall	%cl, %edx
 718 0512 89D0     		movl	%edx, %eax
 719 0514 09F0     		orl	%esi, %eax
 720              	.L36:
 722              	.LM100:
 723 0516 8945F4   		movl	%eax, -12(%rbp)
  97:TestLanguage.c **** 		__ASSERT(l == m, 40);
 725              	.LM101:
 726 0519 8B45F4   		movl	-12(%rbp), %eax
 727 051c 3B45E8   		cmpl	-24(%rbp), %eax
 728 051f 740A     		je	.L37
 730              	.LM102:
 731 0521 BF280000 		movl	$40, %edi
 731      00
 732 0526 E8000000 		call	Modules_AssertFail@PLT
 732      00
 733              	.L37:
  98:TestLanguage.c **** 		m = __ASHR(m, 1);
 735              	.LM103:
 736 052b D17DE8   		sarl	-24(%rbp)
  99:TestLanguage.c **** 		i -= 1;
 738              	.LM104:
 739 052e 0FB745E0 		movzwl	-32(%rbp), %eax
 740 0532 83E801   		subl	$1, %eax
 741 0535 668945E0 		movw	%ax, -32(%rbp)
 742              	.L31:
  91:TestLanguage.c **** 		l = n;
 744              	.LM105:
 745 0539 66837DE0 		cmpw	$-31, -32(%rbp)
 745      E1
 746 053e 0F8D55FF 		jge	.L38
 746      FFFF
 100:TestLanguage.c **** 	}
 101:TestLanguage.c **** 	i = -1;
 748              	.LM106:
 749 0544 66C745E0 		movw	$-1, -32(%rbp)
 749      FFFF
 102:TestLanguage.c **** 	k = 1;
 751              	.LM107:
 752 054a 66C745E2 		movw	$1, -30(%rbp)
 752      0100
 103:TestLanguage.c **** 	k = __LSHL(k, 14, 16);
 754              	.LM108:
 755 0550 0FB745E2 		movzwl	-30(%rbp), %eax
 756 0554 0FB7C0   		movzwl	%ax, %eax
 757 0557 C1E00E   		sall	$14, %eax
 759              	.LM109:
 760 055a 668945E2 		movw	%ax, -30(%rbp)
 104:TestLanguage.c **** 	h = __ASHL(k, 1);
 762              	.LM110:
 763 055e 480FBF45 		movswq	-30(%rbp), %rax
 763      E2
 764 0563 4801C0   		addq	%rax, %rax
 766              	.LM111:
 767 0566 668945E4 		movw	%ax, -28(%rbp)
 105:TestLanguage.c **** 	while (i > -16) {
 769              	.LM112:
 770 056a E9DF0000 		jmp	.L39
 770      00
 771              	.L46:
 106:TestLanguage.c **** 		j = h;
 773              	.LM113:
 774 056f 0FB745E4 		movzwl	-28(%rbp), %eax
 775 0573 668945E6 		movw	%ax, -26(%rbp)
 107:TestLanguage.c **** 		j = __LSH(j, i, 16);
 777              	.LM114:
 778 0577 66837DE0 		cmpw	$0, -32(%rbp)
 778      00
 779 057c 7813     		js	.L40
 781              	.LM115:
 782 057e 0FB745E6 		movzwl	-26(%rbp), %eax
 783 0582 0FB7D0   		movzwl	%ax, %edx
 784 0585 0FBF45E0 		movswl	-32(%rbp), %eax
 785 0589 89C1     		movl	%eax, %ecx
 786 058b D3E2     		sall	%cl, %edx
 787 058d 89D0     		movl	%edx, %eax
 788 058f EB13     		jmp	.L41
 789              	.L40:
 791              	.LM116:
 792 0591 0FB745E6 		movzwl	-26(%rbp), %eax
 793 0595 0FB7D0   		movzwl	%ax, %edx
 794 0598 0FBF45E0 		movswl	-32(%rbp), %eax
 795 059c F7D8     		negl	%eax
 796 059e 89C1     		movl	%eax, %ecx
 797 05a0 D3FA     		sarl	%cl, %edx
 798 05a2 89D0     		movl	%edx, %eax
 799              	.L41:
 801              	.LM117:
 802 05a4 668945E6 		movw	%ax, -26(%rbp)
 108:TestLanguage.c **** 		__ASSERT(j == k, 46);
 804              	.LM118:
 805 05a8 0FB745E6 		movzwl	-26(%rbp), %eax
 806 05ac 663B45E2 		cmpw	-30(%rbp), %ax
 807 05b0 740A     		je	.L42
 809              	.LM119:
 810 05b2 BF2E0000 		movl	$46, %edi
 810      00
 811 05b7 E8000000 		call	Modules_AssertFail@PLT
 811      00
 812              	.L42:
 109:TestLanguage.c **** 		j = h;
 814              	.LM120:
 815 05bc 0FB745E4 		movzwl	-28(%rbp), %eax
 816 05c0 668945E6 		movw	%ax, -26(%rbp)
 110:TestLanguage.c **** 		j = __ROT(j, i, 16);
 818              	.LM121:
 819 05c4 66837DE0 		cmpw	$0, -32(%rbp)
 819      00
 820 05c9 7831     		js	.L43
 822              	.LM122:
 823 05cb 0FB745E6 		movzwl	-26(%rbp), %eax
 824 05cf 0FB7D0   		movzwl	%ax, %edx
 825 05d2 0FBF45E0 		movswl	-32(%rbp), %eax
 826 05d6 89C1     		movl	%eax, %ecx
 827 05d8 D3E2     		sall	%cl, %edx
 828 05da 89D0     		movl	%edx, %eax
 829 05dc 89C6     		movl	%eax, %esi
 830 05de 0FB745E6 		movzwl	-26(%rbp), %eax
 831 05e2 0FB7D0   		movzwl	%ax, %edx
 832 05e5 0FBF45E0 		movswl	-32(%rbp), %eax
 833 05e9 B9100000 		movl	$16, %ecx
 833      00
 834 05ee 29C1     		subl	%eax, %ecx
 835 05f0 89C8     		movl	%ecx, %eax
 836 05f2 89C1     		movl	%eax, %ecx
 837 05f4 D3FA     		sarl	%cl, %edx
 838 05f6 89D0     		movl	%edx, %eax
 840              	.LM123:
 841 05f8 09F0     		orl	%esi, %eax
 842 05fa EB2B     		jmp	.L44
 843              	.L43:
 845              	.LM124:
 846 05fc 0FB745E6 		movzwl	-26(%rbp), %eax
 847 0600 0FB7D0   		movzwl	%ax, %edx
 848 0603 0FBF45E0 		movswl	-32(%rbp), %eax
 849 0607 F7D8     		negl	%eax
 850 0609 89C1     		movl	%eax, %ecx
 851 060b D3FA     		sarl	%cl, %edx
 852 060d 89D0     		movl	%edx, %eax
 853 060f 89C6     		movl	%eax, %esi
 854 0611 0FB745E6 		movzwl	-26(%rbp), %eax
 855 0615 0FB7D0   		movzwl	%ax, %edx
 856 0618 0FBF45E0 		movswl	-32(%rbp), %eax
 857 061c 83C010   		addl	$16, %eax
 858 061f 89C1     		movl	%eax, %ecx
 859 0621 D3E2     		sall	%cl, %edx
 860 0623 89D0     		movl	%edx, %eax
 862              	.LM125:
 863 0625 09F0     		orl	%esi, %eax
 864              	.L44:
 866              	.LM126:
 867 0627 668945E6 		movw	%ax, -26(%rbp)
 111:TestLanguage.c **** 		__ASSERT(j == k, 47);
 869              	.LM127:
 870 062b 0FB745E6 		movzwl	-26(%rbp), %eax
 871 062f 663B45E2 		cmpw	-30(%rbp), %ax
 872 0633 740A     		je	.L45
 874              	.LM128:
 875 0635 BF2F0000 		movl	$47, %edi
 875      00
 876 063a E8000000 		call	Modules_AssertFail@PLT
 876      00
 877              	.L45:
 112:TestLanguage.c **** 		k = __ASHR(k, 1);
 879              	.LM129:
 880 063f 66D17DE2 		sarw	-30(%rbp)
 113:TestLanguage.c **** 		i -= 1;
 882              	.LM130:
 883 0643 0FB745E0 		movzwl	-32(%rbp), %eax
 884 0647 83E801   		subl	$1, %eax
 885 064a 668945E0 		movw	%ax, -32(%rbp)
 886              	.L39:
 105:TestLanguage.c **** 		j = h;
 888              	.LM131:
 889 064e 66837DE0 		cmpw	$-15, -32(%rbp)
 889      F1
 890 0653 0F8D16FF 		jge	.L46
 890      FFFF
 114:TestLanguage.c **** 	}
 115:TestLanguage.c **** 	i = -1;
 892              	.LM132:
 893 0659 66C745E0 		movw	$-1, -32(%rbp)
 893      FFFF
 116:TestLanguage.c **** 	t = 1;
 895              	.LM133:
 896 065f C645DC01 		movb	$1, -36(%rbp)
 117:TestLanguage.c **** 	t = __LSHL(t, 6, 8);
 898              	.LM134:
 899 0663 0FB645DC 		movzbl	-36(%rbp), %eax
 900 0667 0FB6C0   		movzbl	%al, %eax
 901 066a C1E006   		sall	$6, %eax
 903              	.LM135:
 904 066d 8845DC   		movb	%al, -36(%rbp)
 118:TestLanguage.c **** 	u = __ASHL(t, 1);
 906              	.LM136:
 907 0670 480FBE45 		movsbq	-36(%rbp), %rax
 907      DC
 908 0675 4801C0   		addq	%rax, %rax
 910              	.LM137:
 911 0678 8845DD   		movb	%al, -35(%rbp)
 119:TestLanguage.c **** 	while (i > -8) {
 913              	.LM138:
 914 067b E9D80000 		jmp	.L47
 914      00
 915              	.L54:
 120:TestLanguage.c **** 		s = u;
 917              	.LM139:
 918 0680 0FB645DD 		movzbl	-35(%rbp), %eax
 919 0684 8845DE   		movb	%al, -34(%rbp)
 121:TestLanguage.c **** 		s = __LSH(s, i, 8);
 921              	.LM140:
 922 0687 66837DE0 		cmpw	$0, -32(%rbp)
 922      00
 923 068c 7813     		js	.L48
 925              	.LM141:
 926 068e 0FB645DE 		movzbl	-34(%rbp), %eax
 927 0692 0FB6D0   		movzbl	%al, %edx
 928 0695 0FBF45E0 		movswl	-32(%rbp), %eax
 929 0699 89C1     		movl	%eax, %ecx
 930 069b D3E2     		sall	%cl, %edx
 931 069d 89D0     		movl	%edx, %eax
 932 069f EB13     		jmp	.L49
 933              	.L48:
 935              	.LM142:
 936 06a1 0FB645DE 		movzbl	-34(%rbp), %eax
 937 06a5 0FB6D0   		movzbl	%al, %edx
 938 06a8 0FBF45E0 		movswl	-32(%rbp), %eax
 939 06ac F7D8     		negl	%eax
 940 06ae 89C1     		movl	%eax, %ecx
 941 06b0 D3FA     		sarl	%cl, %edx
 942 06b2 89D0     		movl	%edx, %eax
 943              	.L49:
 945              	.LM143:
 946 06b4 8845DE   		movb	%al, -34(%rbp)
 122:TestLanguage.c **** 		__ASSERT(s == t, 53);
 948              	.LM144:
 949 06b7 0FB645DE 		movzbl	-34(%rbp), %eax
 950 06bb 3A45DC   		cmpb	-36(%rbp), %al
 951 06be 740A     		je	.L50
 953              	.LM145:
 954 06c0 BF350000 		movl	$53, %edi
 954      00
 955 06c5 E8000000 		call	Modules_AssertFail@PLT
 955      00
 956              	.L50:
 123:TestLanguage.c **** 		s = u;
 958              	.LM146:
 959 06ca 0FB645DD 		movzbl	-35(%rbp), %eax
 960 06ce 8845DE   		movb	%al, -34(%rbp)
 124:TestLanguage.c **** 		s = __ROT(s, i, 8);
 962              	.LM147:
 963 06d1 66837DE0 		cmpw	$0, -32(%rbp)
 963      00
 964 06d6 7831     		js	.L51
 966              	.LM148:
 967 06d8 0FB645DE 		movzbl	-34(%rbp), %eax
 968 06dc 0FB6D0   		movzbl	%al, %edx
 969 06df 0FBF45E0 		movswl	-32(%rbp), %eax
 970 06e3 89C1     		movl	%eax, %ecx
 971 06e5 D3E2     		sall	%cl, %edx
 972 06e7 89D0     		movl	%edx, %eax
 973 06e9 89C6     		movl	%eax, %esi
 974 06eb 0FB645DE 		movzbl	-34(%rbp), %eax
 975 06ef 0FB6D0   		movzbl	%al, %edx
 976 06f2 0FBF45E0 		movswl	-32(%rbp), %eax
 977 06f6 B9080000 		movl	$8, %ecx
 977      00
 978 06fb 29C1     		subl	%eax, %ecx
 979 06fd 89C8     		movl	%ecx, %eax
 980 06ff 89C1     		movl	%eax, %ecx
 981 0701 D3FA     		sarl	%cl, %edx
 982 0703 89D0     		movl	%edx, %eax
 984              	.LM149:
 985 0705 09F0     		orl	%esi, %eax
 986 0707 EB2B     		jmp	.L52
 987              	.L51:
 989              	.LM150:
 990 0709 0FB645DE 		movzbl	-34(%rbp), %eax
 991 070d 0FB6D0   		movzbl	%al, %edx
 992 0710 0FBF45E0 		movswl	-32(%rbp), %eax
 993 0714 F7D8     		negl	%eax
 994 0716 89C1     		movl	%eax, %ecx
 995 0718 D3FA     		sarl	%cl, %edx
 996 071a 89D0     		movl	%edx, %eax
 997 071c 89C6     		movl	%eax, %esi
 998 071e 0FB645DE 		movzbl	-34(%rbp), %eax
 999 0722 0FB6D0   		movzbl	%al, %edx
 1000 0725 0FBF45E0 		movswl	-32(%rbp), %eax
 1001 0729 83C008   		addl	$8, %eax
 1002 072c 89C1     		movl	%eax, %ecx
 1003 072e D3E2     		sall	%cl, %edx
 1004 0730 89D0     		movl	%edx, %eax
 1006              	.LM151:
 1007 0732 09F0     		orl	%esi, %eax
 1008              	.L52:
 1010              	.LM152:
 1011 0734 8845DE   		movb	%al, -34(%rbp)
 125:TestLanguage.c **** 		__ASSERT(s == t, 54);
 1013              	.LM153:
 1014 0737 0FB645DE 		movzbl	-34(%rbp), %eax
 1015 073b 3A45DC   		cmpb	-36(%rbp), %al
 1016 073e 740A     		je	.L53
 1018              	.LM154:
 1019 0740 BF360000 		movl	$54, %edi
 1019      00
 1020 0745 E8000000 		call	Modules_AssertFail@PLT
 1020      00
 1021              	.L53:
 126:TestLanguage.c **** 		t = __ASHR(t, 1);
 1023              	.LM155:
 1024 074a D07DDC   		sarb	-36(%rbp)
 127:TestLanguage.c **** 		i -= 1;
 1026              	.LM156:
 1027 074d 0FB745E0 		movzwl	-32(%rbp), %eax
 1028 0751 83E801   		subl	$1, %eax
 1029 0754 668945E0 		movw	%ax, -32(%rbp)
 1030              	.L47:
 119:TestLanguage.c **** 		s = u;
 1032              	.LM157:
 1033 0758 66837DE0 		cmpw	$-7, -32(%rbp)
 1033      F9
 1034 075d 0F8D1DFF 		jge	.L54
 1034      FFFF
 128:TestLanguage.c **** 	}
 129:TestLanguage.c **** 	i = 0;
 1036              	.LM158:
 1037 0763 66C745E0 		movw	$0, -32(%rbp)
 1037      0000
 130:TestLanguage.c **** 	m = 1;
 1039              	.LM159:
 1040 0769 C745E801 		movl	$1, -24(%rbp)
 1040      000000
 131:TestLanguage.c **** 	m = __LSHL(m, 31, 32);
 1042              	.LM160:
 1043 0770 8B45E8   		movl	-24(%rbp), %eax
 1044 0773 C1E01F   		sall	$31, %eax
 1046              	.LM161:
 1047 0776 8945E8   		movl	%eax, -24(%rbp)
 132:TestLanguage.c **** 	n = m;
 1049              	.LM162:
 1050 0779 8B45E8   		movl	-24(%rbp), %eax
 1051 077c 8945EC   		movl	%eax, -20(%rbp)
 133:TestLanguage.c **** 	while (i > -32) {
 1053              	.LM163:
 1054 077f EB58     		jmp	.L55
 1055              	.L59:
 134:TestLanguage.c **** 		l = n;
 1057              	.LM164:
 1058 0781 8B45EC   		movl	-20(%rbp), %eax
 1059 0784 8945F4   		movl	%eax, -12(%rbp)
 135:TestLanguage.c **** 		l = __ASH(l, i);
 1061              	.LM165:
 1062 0787 66837DE0 		cmpw	$0, -32(%rbp)
 1062      00
 1063 078c 7814     		js	.L56
 1065              	.LM166:
 1066 078e 8B45F4   		movl	-12(%rbp), %eax
 1067 0791 4863D0   		movslq	%eax, %rdx
 1068 0794 0FBF45E0 		movswl	-32(%rbp), %eax
 1069 0798 89C1     		movl	%eax, %ecx
 1070 079a 48D3E2   		salq	%cl, %rdx
 1071 079d 4889D0   		movq	%rdx, %rax
 1072 07a0 EB14     		jmp	.L57
 1073              	.L56:
 1075              	.LM167:
 1076 07a2 8B45F4   		movl	-12(%rbp), %eax
 1077 07a5 4863D0   		movslq	%eax, %rdx
 1078 07a8 0FBF45E0 		movswl	-32(%rbp), %eax
 1079 07ac F7D8     		negl	%eax
 1080 07ae 89C1     		movl	%eax, %ecx
 1081 07b0 48D3FA   		sarq	%cl, %rdx
 1082 07b3 4889D0   		movq	%rdx, %rax
 1083              	.L57:
 1085              	.LM168:
 1086 07b6 8945F4   		movl	%eax, -12(%rbp)
 136:TestLanguage.c **** 		__ASSERT(l == m, 62);
 1088              	.LM169:
 1089 07b9 8B45F4   		movl	-12(%rbp), %eax
 1090 07bc 3B45E8   		cmpl	-24(%rbp), %eax
 1091 07bf 740A     		je	.L58
 1093              	.LM170:
 1094 07c1 BF3E0000 		movl	$62, %edi
 1094      00
 1095 07c6 E8000000 		call	Modules_AssertFail@PLT
 1095      00
 1096              	.L58:
 137:TestLanguage.c **** 		m = __ASHR(m, 1);
 1098              	.LM171:
 1099 07cb D17DE8   		sarl	-24(%rbp)
 138:TestLanguage.c **** 		i -= 1;
 1101              	.LM172:
 1102 07ce 0FB745E0 		movzwl	-32(%rbp), %eax
 1103 07d2 83E801   		subl	$1, %eax
 1104 07d5 668945E0 		movw	%ax, -32(%rbp)
 1105              	.L55:
 133:TestLanguage.c **** 		l = n;
 1107              	.LM173:
 1108 07d9 66837DE0 		cmpw	$-31, -32(%rbp)
 1108      E1
 1109 07de 7DA1     		jge	.L59
 139:TestLanguage.c **** 	}
 140:TestLanguage.c **** 	i = 0;
 1111              	.LM174:
 1112 07e0 66C745E0 		movw	$0, -32(%rbp)
 1112      0000
 141:TestLanguage.c **** 	j = 1;
 1114              	.LM175:
 1115 07e6 66C745E6 		movw	$1, -26(%rbp)
 1115      0100
 142:TestLanguage.c **** 	j = __LSHL(j, 15, 16);
 1117              	.LM176:
 1118 07ec 0FB745E6 		movzwl	-26(%rbp), %eax
 1119 07f0 0FB7C0   		movzwl	%ax, %eax
 1120 07f3 C1E00F   		sall	$15, %eax
 1122              	.LM177:
 1123 07f6 668945E6 		movw	%ax, -26(%rbp)
 143:TestLanguage.c **** 	k = j;
 1125              	.LM178:
 1126 07fa 0FB745E6 		movzwl	-26(%rbp), %eax
 1127 07fe 668945E2 		movw	%ax, -30(%rbp)
 144:TestLanguage.c **** 	while (i > -16) {
 1129              	.LM179:
 1130 0802 EB52     		jmp	.L60
 1131              	.L64:
 145:TestLanguage.c **** 		l = __ASH(j, i);
 1133              	.LM180:
 1134 0804 66837DE0 		cmpw	$0, -32(%rbp)
 1134      00
 1135 0809 7813     		js	.L61
 1137              	.LM181:
 1138 080b 480FBF55 		movswq	-26(%rbp), %rdx
 1138      E6
 1139 0810 0FBF45E0 		movswl	-32(%rbp), %eax
 1140 0814 89C1     		movl	%eax, %ecx
 1141 0816 48D3E2   		salq	%cl, %rdx
 1142 0819 4889D0   		movq	%rdx, %rax
 1143 081c EB13     		jmp	.L62
 1144              	.L61:
 1146              	.LM182:
 1147 081e 480FBF55 		movswq	-26(%rbp), %rdx
 1147      E6
 1148 0823 0FBF45E0 		movswl	-32(%rbp), %eax
 1149 0827 F7D8     		negl	%eax
 1150 0829 89C1     		movl	%eax, %ecx
 1151 082b 48D3FA   		sarq	%cl, %rdx
 1152 082e 4889D0   		movq	%rdx, %rax
 1153              	.L62:
 1155              	.LM183:
 1156 0831 8945F4   		movl	%eax, -12(%rbp)
 146:TestLanguage.c **** 		__ASSERT(l == k, 68);
 1158              	.LM184:
 1159 0834 0FBF45E2 		movswl	-30(%rbp), %eax
 1160 0838 3945F4   		cmpl	%eax, -12(%rbp)
 1161 083b 740A     		je	.L63
 1163              	.LM185:
 1164 083d BF440000 		movl	$68, %edi
 1164      00
 1165 0842 E8000000 		call	Modules_AssertFail@PLT
 1165      00
 1166              	.L63:
 147:TestLanguage.c **** 		k = __ASHR(k, 1);
 1168              	.LM186:
 1169 0847 66D17DE2 		sarw	-30(%rbp)
 148:TestLanguage.c **** 		i -= 1;
 1171              	.LM187:
 1172 084b 0FB745E0 		movzwl	-32(%rbp), %eax
 1173 084f 83E801   		subl	$1, %eax
 1174 0852 668945E0 		movw	%ax, -32(%rbp)
 1175              	.L60:
 144:TestLanguage.c **** 		l = __ASH(j, i);
 1177              	.LM188:
 1178 0856 66837DE0 		cmpw	$-15, -32(%rbp)
 1178      F1
 1179 085b 7DA7     		jge	.L64
 149:TestLanguage.c **** 	}
 150:TestLanguage.c **** 	i = 0;
 1181              	.LM189:
 1182 085d 66C745E0 		movw	$0, -32(%rbp)
 1182      0000
 151:TestLanguage.c **** 	s = 1;
 1184              	.LM190:
 1185 0863 C645DE01 		movb	$1, -34(%rbp)
 152:TestLanguage.c **** 	s = __LSHL(s, 7, 8);
 1187              	.LM191:
 1188 0867 0FB645DE 		movzbl	-34(%rbp), %eax
 1189 086b 0FB6C0   		movzbl	%al, %eax
 1190 086e C1E007   		sall	$7, %eax
 1192              	.LM192:
 1193 0871 8845DE   		movb	%al, -34(%rbp)
 153:TestLanguage.c **** 	t = s;
 1195              	.LM193:
 1196 0874 0FB645DE 		movzbl	-34(%rbp), %eax
 1197 0878 8845DC   		movb	%al, -36(%rbp)
 154:TestLanguage.c **** 	while (i > -8) {
 1199              	.LM194:
 1200 087b EB51     		jmp	.L65
 1201              	.L69:
 155:TestLanguage.c **** 		l = __ASH(s, i);
 1203              	.LM195:
 1204 087d 66837DE0 		cmpw	$0, -32(%rbp)
 1204      00
 1205 0882 7813     		js	.L66
 1207              	.LM196:
 1208 0884 480FBE55 		movsbq	-34(%rbp), %rdx
 1208      DE
 1209 0889 0FBF45E0 		movswl	-32(%rbp), %eax
 1210 088d 89C1     		movl	%eax, %ecx
 1211 088f 48D3E2   		salq	%cl, %rdx
 1212 0892 4889D0   		movq	%rdx, %rax
 1213 0895 EB13     		jmp	.L67
 1214              	.L66:
 1216              	.LM197:
 1217 0897 480FBE55 		movsbq	-34(%rbp), %rdx
 1217      DE
 1218 089c 0FBF45E0 		movswl	-32(%rbp), %eax
 1219 08a0 F7D8     		negl	%eax
 1220 08a2 89C1     		movl	%eax, %ecx
 1221 08a4 48D3FA   		sarq	%cl, %rdx
 1222 08a7 4889D0   		movq	%rdx, %rax
 1223              	.L67:
 1225              	.LM198:
 1226 08aa 8945F4   		movl	%eax, -12(%rbp)
 156:TestLanguage.c **** 		__ASSERT(l == ((INT16)t), 74);
 1228              	.LM199:
 1229 08ad 0FBE45DC 		movsbl	-36(%rbp), %eax
 1230 08b1 3945F4   		cmpl	%eax, -12(%rbp)
 1231 08b4 740A     		je	.L68
 1233              	.LM200:
 1234 08b6 BF4A0000 		movl	$74, %edi
 1234      00
 1235 08bb E8000000 		call	Modules_AssertFail@PLT
 1235      00
 1236              	.L68:
 157:TestLanguage.c **** 		t = __ASHR(t, 1);
 1238              	.LM201:
 1239 08c0 D07DDC   		sarb	-36(%rbp)
 158:TestLanguage.c **** 		i -= 1;
 1241              	.LM202:
 1242 08c3 0FB745E0 		movzwl	-32(%rbp), %eax
 1243 08c7 83E801   		subl	$1, %eax
 1244 08ca 668945E0 		movw	%ax, -32(%rbp)
 1245              	.L65:
 154:TestLanguage.c **** 		l = __ASH(s, i);
 1247              	.LM203:
 1248 08ce 66837DE0 		cmpw	$-7, -32(%rbp)
 1248      F9
 1249 08d3 7DA8     		jge	.L69
 159:TestLanguage.c **** 	}
 160:TestLanguage.c **** 	i = 0;
 1251              	.LM204:
 1252 08d5 66C745E0 		movw	$0, -32(%rbp)
 1252      0000
 161:TestLanguage.c **** 	m = 1;
 1254              	.LM205:
 1255 08db C745E801 		movl	$1, -24(%rbp)
 1255      000000
 162:TestLanguage.c **** 	m = __LSHL(m, 30, 32);
 1257              	.LM206:
 1258 08e2 8B45E8   		movl	-24(%rbp), %eax
 1259 08e5 C1E01E   		sall	$30, %eax
 1261              	.LM207:
 1262 08e8 8945E8   		movl	%eax, -24(%rbp)
 163:TestLanguage.c **** 	n = m;
 1264              	.LM208:
 1265 08eb 8B45E8   		movl	-24(%rbp), %eax
 1266 08ee 8945EC   		movl	%eax, -20(%rbp)
 164:TestLanguage.c **** 	while (i > -31) {
 1268              	.LM209:
 1269 08f1 EB58     		jmp	.L70
 1270              	.L74:
 165:TestLanguage.c **** 		l = n;
 1272              	.LM210:
 1273 08f3 8B45EC   		movl	-20(%rbp), %eax
 1274 08f6 8945F4   		movl	%eax, -12(%rbp)
 166:TestLanguage.c **** 		l = __ASH(l, i);
 1276              	.LM211:
 1277 08f9 66837DE0 		cmpw	$0, -32(%rbp)
 1277      00
 1278 08fe 7814     		js	.L71
 1280              	.LM212:
 1281 0900 8B45F4   		movl	-12(%rbp), %eax
 1282 0903 4863D0   		movslq	%eax, %rdx
 1283 0906 0FBF45E0 		movswl	-32(%rbp), %eax
 1284 090a 89C1     		movl	%eax, %ecx
 1285 090c 48D3E2   		salq	%cl, %rdx
 1286 090f 4889D0   		movq	%rdx, %rax
 1287 0912 EB14     		jmp	.L72
 1288              	.L71:
 1290              	.LM213:
 1291 0914 8B45F4   		movl	-12(%rbp), %eax
 1292 0917 4863D0   		movslq	%eax, %rdx
 1293 091a 0FBF45E0 		movswl	-32(%rbp), %eax
 1294 091e F7D8     		negl	%eax
 1295 0920 89C1     		movl	%eax, %ecx
 1296 0922 48D3FA   		sarq	%cl, %rdx
 1297 0925 4889D0   		movq	%rdx, %rax
 1298              	.L72:
 1300              	.LM214:
 1301 0928 8945F4   		movl	%eax, -12(%rbp)
 167:TestLanguage.c **** 		__ASSERT(l == m, 82);
 1303              	.LM215:
 1304 092b 8B45F4   		movl	-12(%rbp), %eax
 1305 092e 3B45E8   		cmpl	-24(%rbp), %eax
 1306 0931 740A     		je	.L73
 1308              	.LM216:
 1309 0933 BF520000 		movl	$82, %edi
 1309      00
 1310 0938 E8000000 		call	Modules_AssertFail@PLT
 1310      00
 1311              	.L73:
 168:TestLanguage.c **** 		m = __ASHR(m, 1);
 1313              	.LM217:
 1314 093d D17DE8   		sarl	-24(%rbp)
 169:TestLanguage.c **** 		i -= 1;
 1316              	.LM218:
 1317 0940 0FB745E0 		movzwl	-32(%rbp), %eax
 1318 0944 83E801   		subl	$1, %eax
 1319 0947 668945E0 		movw	%ax, -32(%rbp)
 1320              	.L70:
 164:TestLanguage.c **** 		l = n;
 1322              	.LM219:
 1323 094b 66837DE0 		cmpw	$-30, -32(%rbp)
 1323      E2
 1324 0950 7DA1     		jge	.L74
 170:TestLanguage.c **** 	}
 171:TestLanguage.c **** 	i = 1;
 1326              	.LM220:
 1327 0952 66C745E0 		movw	$1, -32(%rbp)
 1327      0100
 172:TestLanguage.c **** 	m = 1;
 1329              	.LM221:
 1330 0958 C745E801 		movl	$1, -24(%rbp)
 1330      000000
 173:TestLanguage.c **** 	while (i < 32) {
 1332              	.LM222:
 1333 095f E9D20000 		jmp	.L75
 1333      00
 1334              	.L80:
 174:TestLanguage.c **** 		l = 2147483647;
 1336              	.LM223:
 1337 0964 C745F4FF 		movl	$2147483647, -12(%rbp)
 1337      FFFF7F
 175:TestLanguage.c **** 		l += 1;
 1339              	.LM224:
 1340 096b 8345F401 		addl	$1, -12(%rbp)
 176:TestLanguage.c **** 		r = __LSH(l, i, 32);
 1342              	.LM225:
 1343 096f 66837DE0 		cmpw	$0, -32(%rbp)
 1343      00
 1344 0974 780F     		js	.L76
 1346              	.LM226:
 1347 0976 8B55F4   		movl	-12(%rbp), %edx
 1348 0979 0FBF45E0 		movswl	-32(%rbp), %eax
 1349 097d 89C1     		movl	%eax, %ecx
 1350 097f D3E2     		sall	%cl, %edx
 1351 0981 89D0     		movl	%edx, %eax
 1352 0983 EB0F     		jmp	.L77
 1353              	.L76:
 1355              	.LM227:
 1356 0985 8B55F4   		movl	-12(%rbp), %edx
 1357 0988 0FBF45E0 		movswl	-32(%rbp), %eax
 1358 098c F7D8     		negl	%eax
 1359 098e 89C1     		movl	%eax, %ecx
 1360 0990 D3EA     		shrl	%cl, %edx
 1361 0992 89D0     		movl	%edx, %eax
 1362              	.L77:
 1364              	.LM228:
 1365 0994 8945F0   		movl	%eax, -16(%rbp)
 177:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, 0, (CHAR*)"LSH", 4);
 1367              	.LM229:
 1368 0997 0FBF75E0 		movswl	-32(%rbp), %esi
 1369 099b 8B55F0   		movl	-16(%rbp), %edx
 1370 099e 8B45F4   		movl	-12(%rbp), %eax
 1371 09a1 41B90400 		movl	$4, %r9d
 1371      0000
 1372 09a7 4C8D0500 		leaq	.LC4(%rip), %r8
 1372      000000
 1373 09ae B9000000 		movl	$0, %ecx
 1373      00
 1374 09b3 89C7     		movl	%eax, %edi
 1375 09b5 E846F6FF 		call	TestLanguage_TestShiftResult
 1375      FF
 178:TestLanguage.c **** 		l = 2147483647;
 1377              	.LM230:
 1378 09ba C745F4FF 		movl	$2147483647, -12(%rbp)
 1378      FFFF7F
 179:TestLanguage.c **** 		l += 1;
 1380              	.LM231:
 1381 09c1 8345F401 		addl	$1, -12(%rbp)
 180:TestLanguage.c **** 		r = __ROT(l, i, 32);
 1383              	.LM232:
 1384 09c5 66837DE0 		cmpw	$0, -32(%rbp)
 1384      00
 1385 09ca 780F     		js	.L78
 1387              	.LM233:
 1388 09cc 8B55F4   		movl	-12(%rbp), %edx
 1389 09cf 0FBF45E0 		movswl	-32(%rbp), %eax
 1390 09d3 89C1     		movl	%eax, %ecx
 1391 09d5 D3C2     		roll	%cl, %edx
 1392 09d7 89D0     		movl	%edx, %eax
 1393 09d9 EB21     		jmp	.L79
 1394              	.L78:
 1396              	.LM234:
 1397 09db 8B55F4   		movl	-12(%rbp), %edx
 1398 09de 0FBF45E0 		movswl	-32(%rbp), %eax
 1399 09e2 F7D8     		negl	%eax
 1400 09e4 89D6     		movl	%edx, %esi
 1401 09e6 89C1     		movl	%eax, %ecx
 1402 09e8 D3EE     		shrl	%cl, %esi
 1403 09ea 8B55F4   		movl	-12(%rbp), %edx
 1404 09ed 0FBF45E0 		movswl	-32(%rbp), %eax
 1405 09f1 83C020   		addl	$32, %eax
 1406 09f4 89C1     		movl	%eax, %ecx
 1407 09f6 D3E2     		sall	%cl, %edx
 1408 09f8 89D0     		movl	%edx, %eax
 1409 09fa 09F0     		orl	%esi, %eax
 1410              	.L79:
 1412              	.LM235:
 1413 09fc 8945F0   		movl	%eax, -16(%rbp)
 181:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT(2)", 7);
 1415              	.LM236:
 1416 09ff 0FBF75E0 		movswl	-32(%rbp), %esi
 1417 0a03 8B4DE8   		movl	-24(%rbp), %ecx
 1418 0a06 8B55F0   		movl	-16(%rbp), %edx
 1419 0a09 8B45F4   		movl	-12(%rbp), %eax
 1420 0a0c 41B90700 		movl	$7, %r9d
 1420      0000
 1421 0a12 4C8D0500 		leaq	.LC6(%rip), %r8
 1421      000000
 1422 0a19 89C7     		movl	%eax, %edi
 1423 0a1b E8E0F5FF 		call	TestLanguage_TestShiftResult
 1423      FF
 182:TestLanguage.c **** 		m = __ASHL(m, 1);
 1425              	.LM237:
 1426 0a20 8B45E8   		movl	-24(%rbp), %eax
 1427 0a23 4898     		cltq
 1428 0a25 4801C0   		addq	%rax, %rax
 1430              	.LM238:
 1431 0a28 8945E8   		movl	%eax, -24(%rbp)
 183:TestLanguage.c **** 		i += 1;
 1433              	.LM239:
 1434 0a2b 0FB745E0 		movzwl	-32(%rbp), %eax
 1435 0a2f 83C001   		addl	$1, %eax
 1436 0a32 668945E0 		movw	%ax, -32(%rbp)
 1437              	.L75:
 173:TestLanguage.c **** 		l = 2147483647;
 1439              	.LM240:
 1440 0a36 66837DE0 		cmpw	$31, -32(%rbp)
 1440      1F
 1441 0a3b 0F8E23FF 		jle	.L80
 1441      FFFF
 184:TestLanguage.c **** 	}
 185:TestLanguage.c **** 	i = 1;
 1443              	.LM241:
 1444 0a41 66C745E0 		movw	$1, -32(%rbp)
 1444      0100
 186:TestLanguage.c **** 	k = 1;
 1446              	.LM242:
 1447 0a47 66C745E2 		movw	$1, -30(%rbp)
 1447      0100
 187:TestLanguage.c **** 	while (i < 16) {
 1449              	.LM243:
 1450 0a4d E91A0100 		jmp	.L81
 1450      00
 1451              	.L86:
 188:TestLanguage.c **** 		j = 32767;
 1453              	.LM244:
 1454 0a52 66C745E6 		movw	$32767, -26(%rbp)
 1454      FF7F
 189:TestLanguage.c **** 		j += 1;
 1456              	.LM245:
 1457 0a58 0FB745E6 		movzwl	-26(%rbp), %eax
 1458 0a5c 83C001   		addl	$1, %eax
 1459 0a5f 668945E6 		movw	%ax, -26(%rbp)
 190:TestLanguage.c **** 		r = __LSH(j, i, 16);
 1461              	.LM246:
 1462 0a63 66837DE0 		cmpw	$0, -32(%rbp)
 1462      00
 1463 0a68 7814     		js	.L82
 1465              	.LM247:
 1466 0a6a 0FB745E6 		movzwl	-26(%rbp), %eax
 1467 0a6e 0FB7D0   		movzwl	%ax, %edx
 1468 0a71 0FBF45E0 		movswl	-32(%rbp), %eax
 1469 0a75 89C1     		movl	%eax, %ecx
 1470 0a77 D3E2     		sall	%cl, %edx
 1471 0a79 89D0     		movl	%edx, %eax
 1472 0a7b 98       		cwtl
 1473 0a7c EB14     		jmp	.L83
 1474              	.L82:
 1476              	.LM248:
 1477 0a7e 0FB745E6 		movzwl	-26(%rbp), %eax
 1478 0a82 0FB7D0   		movzwl	%ax, %edx
 1479 0a85 0FBF45E0 		movswl	-32(%rbp), %eax
 1480 0a89 F7D8     		negl	%eax
 1481 0a8b 89C1     		movl	%eax, %ecx
 1482 0a8d D3FA     		sarl	%cl, %edx
 1483 0a8f 89D0     		movl	%edx, %eax
 1484 0a91 98       		cwtl
 1485              	.L83:
 1487              	.LM249:
 1488 0a92 8945F0   		movl	%eax, -16(%rbp)
 191:TestLanguage.c **** 		TestLanguage_TestShiftResult(j, i, r, 0, (CHAR*)"LSH", 4);
 1490              	.LM250:
 1491 0a95 0FBF75E0 		movswl	-32(%rbp), %esi
 1492 0a99 0FBF45E6 		movswl	-26(%rbp), %eax
 1493 0a9d 8B55F0   		movl	-16(%rbp), %edx
 1494 0aa0 41B90400 		movl	$4, %r9d
 1494      0000
 1495 0aa6 4C8D0500 		leaq	.LC4(%rip), %r8
 1495      000000
 1496 0aad B9000000 		movl	$0, %ecx
 1496      00
 1497 0ab2 89C7     		movl	%eax, %edi
 1498 0ab4 E847F5FF 		call	TestLanguage_TestShiftResult
 1498      FF
 192:TestLanguage.c **** 		j = 32767;
 1500              	.LM251:
 1501 0ab9 66C745E6 		movw	$32767, -26(%rbp)
 1501      FF7F
 193:TestLanguage.c **** 		j += 1;
 1503              	.LM252:
 1504 0abf 0FB745E6 		movzwl	-26(%rbp), %eax
 1505 0ac3 83C001   		addl	$1, %eax
 1506 0ac6 668945E6 		movw	%ax, -26(%rbp)
 194:TestLanguage.c **** 		r = __ROT(j, i, 16);
 1508              	.LM253:
 1509 0aca 66837DE0 		cmpw	$0, -32(%rbp)
 1509      00
 1510 0acf 7832     		js	.L84
 1512              	.LM254:
 1513 0ad1 0FB745E6 		movzwl	-26(%rbp), %eax
 1514 0ad5 0FB7D0   		movzwl	%ax, %edx
 1515 0ad8 0FBF45E0 		movswl	-32(%rbp), %eax
 1516 0adc 89C1     		movl	%eax, %ecx
 1517 0ade D3E2     		sall	%cl, %edx
 1518 0ae0 89D0     		movl	%edx, %eax
 1519 0ae2 89C6     		movl	%eax, %esi
 1520 0ae4 0FB745E6 		movzwl	-26(%rbp), %eax
 1521 0ae8 0FB7D0   		movzwl	%ax, %edx
 1522 0aeb 0FBF45E0 		movswl	-32(%rbp), %eax
 1523 0aef B9100000 		movl	$16, %ecx
 1523      00
 1524 0af4 29C1     		subl	%eax, %ecx
 1525 0af6 89C8     		movl	%ecx, %eax
 1526 0af8 89C1     		movl	%eax, %ecx
 1527 0afa D3FA     		sarl	%cl, %edx
 1528 0afc 89D0     		movl	%edx, %eax
 1529 0afe 09F0     		orl	%esi, %eax
 1530 0b00 98       		cwtl
 1531 0b01 EB2C     		jmp	.L85
 1532              	.L84:
 1534              	.LM255:
 1535 0b03 0FB745E6 		movzwl	-26(%rbp), %eax
 1536 0b07 0FB7D0   		movzwl	%ax, %edx
 1537 0b0a 0FBF45E0 		movswl	-32(%rbp), %eax
 1538 0b0e F7D8     		negl	%eax
 1539 0b10 89C1     		movl	%eax, %ecx
 1540 0b12 D3FA     		sarl	%cl, %edx
 1541 0b14 89D0     		movl	%edx, %eax
 1542 0b16 89C6     		movl	%eax, %esi
 1543 0b18 0FB745E6 		movzwl	-26(%rbp), %eax
 1544 0b1c 0FB7D0   		movzwl	%ax, %edx
 1545 0b1f 0FBF45E0 		movswl	-32(%rbp), %eax
 1546 0b23 83C010   		addl	$16, %eax
 1547 0b26 89C1     		movl	%eax, %ecx
 1548 0b28 D3E2     		sall	%cl, %edx
 1549 0b2a 89D0     		movl	%edx, %eax
 1550 0b2c 09F0     		orl	%esi, %eax
 1551 0b2e 98       		cwtl
 1552              	.L85:
 1554              	.LM256:
 1555 0b2f 8945F0   		movl	%eax, -16(%rbp)
 195:TestLanguage.c **** 		TestLanguage_TestShiftResult(j, i, r, k, (CHAR*)"ROT(3)", 7);
 1557              	.LM257:
 1558 0b32 0FBF4DE2 		movswl	-30(%rbp), %ecx
 1559 0b36 0FBF75E0 		movswl	-32(%rbp), %esi
 1560 0b3a 0FBF45E6 		movswl	-26(%rbp), %eax
 1561 0b3e 8B55F0   		movl	-16(%rbp), %edx
 1562 0b41 41B90700 		movl	$7, %r9d
 1562      0000
 1563 0b47 4C8D0500 		leaq	.LC7(%rip), %r8
 1563      000000
 1564 0b4e 89C7     		movl	%eax, %edi
 1565 0b50 E8ABF4FF 		call	TestLanguage_TestShiftResult
 1565      FF
 196:TestLanguage.c **** 		k = __ASHL(k, 1);
 1567              	.LM258:
 1568 0b55 480FBF45 		movswq	-30(%rbp), %rax
 1568      E2
 1569 0b5a 4801C0   		addq	%rax, %rax
 1571              	.LM259:
 1572 0b5d 668945E2 		movw	%ax, -30(%rbp)
 197:TestLanguage.c **** 		i += 1;
 1574              	.LM260:
 1575 0b61 0FB745E0 		movzwl	-32(%rbp), %eax
 1576 0b65 83C001   		addl	$1, %eax
 1577 0b68 668945E0 		movw	%ax, -32(%rbp)
 1578              	.L81:
 187:TestLanguage.c **** 		j = 32767;
 1580              	.LM261:
 1581 0b6c 66837DE0 		cmpw	$15, -32(%rbp)
 1581      0F
 1582 0b71 0F8EDBFE 		jle	.L86
 1582      FFFF
 198:TestLanguage.c **** 	}
 199:TestLanguage.c **** 	i = 1;
 1584              	.LM262:
 1585 0b77 66C745E0 		movw	$1, -32(%rbp)
 1585      0100
 200:TestLanguage.c **** 	t = 1;
 1587              	.LM263:
 1588 0b7d C645DC01 		movb	$1, -36(%rbp)
 201:TestLanguage.c **** 	while (i < 8) {
 1590              	.LM264:
 1591 0b81 E91B0100 		jmp	.L87
 1591      00
 1592              	.L92:
 202:TestLanguage.c **** 		s = 127;
 1594              	.LM265:
 1595 0b86 C645DE7F 		movb	$127, -34(%rbp)
 203:TestLanguage.c **** 		s += 1;
 1597              	.LM266:
 1598 0b8a 0FB645DE 		movzbl	-34(%rbp), %eax
 1599 0b8e 83C001   		addl	$1, %eax
 1600 0b91 8845DE   		movb	%al, -34(%rbp)
 204:TestLanguage.c **** 		r = __LSH(s, i, 8);
 1602              	.LM267:
 1603 0b94 66837DE0 		cmpw	$0, -32(%rbp)
 1603      00
 1604 0b99 7816     		js	.L88
 1606              	.LM268:
 1607 0b9b 0FB645DE 		movzbl	-34(%rbp), %eax
 1608 0b9f 0FB6D0   		movzbl	%al, %edx
 1609 0ba2 0FBF45E0 		movswl	-32(%rbp), %eax
 1610 0ba6 89C1     		movl	%eax, %ecx
 1611 0ba8 D3E2     		sall	%cl, %edx
 1612 0baa 89D0     		movl	%edx, %eax
 1613 0bac 0FBEC0   		movsbl	%al, %eax
 1614 0baf EB16     		jmp	.L89
 1615              	.L88:
 1617              	.LM269:
 1618 0bb1 0FB645DE 		movzbl	-34(%rbp), %eax
 1619 0bb5 0FB6D0   		movzbl	%al, %edx
 1620 0bb8 0FBF45E0 		movswl	-32(%rbp), %eax
 1621 0bbc F7D8     		negl	%eax
 1622 0bbe 89C1     		movl	%eax, %ecx
 1623 0bc0 D3FA     		sarl	%cl, %edx
 1624 0bc2 89D0     		movl	%edx, %eax
 1625 0bc4 0FBEC0   		movsbl	%al, %eax
 1626              	.L89:
 1628              	.LM270:
 1629 0bc7 8945F0   		movl	%eax, -16(%rbp)
 205:TestLanguage.c **** 		TestLanguage_TestShiftResult(s, i, r, 0, (CHAR*)"LSH", 4);
 1631              	.LM271:
 1632 0bca 0FBF75E0 		movswl	-32(%rbp), %esi
 1633 0bce 0FBE45DE 		movsbl	-34(%rbp), %eax
 1634 0bd2 8B55F0   		movl	-16(%rbp), %edx
 1635 0bd5 41B90400 		movl	$4, %r9d
 1635      0000
 1636 0bdb 4C8D0500 		leaq	.LC4(%rip), %r8
 1636      000000
 1637 0be2 B9000000 		movl	$0, %ecx
 1637      00
 1638 0be7 89C7     		movl	%eax, %edi
 1639 0be9 E812F4FF 		call	TestLanguage_TestShiftResult
 1639      FF
 206:TestLanguage.c **** 		s = 127;
 1641              	.LM272:
 1642 0bee C645DE7F 		movb	$127, -34(%rbp)
 207:TestLanguage.c **** 		s += 1;
 1644              	.LM273:
 1645 0bf2 0FB645DE 		movzbl	-34(%rbp), %eax
 1646 0bf6 83C001   		addl	$1, %eax
 1647 0bf9 8845DE   		movb	%al, -34(%rbp)
 208:TestLanguage.c **** 		r = __ROT(s, i, 8);
 1649              	.LM274:
 1650 0bfc 66837DE0 		cmpw	$0, -32(%rbp)
 1650      00
 1651 0c01 7834     		js	.L90
 1653              	.LM275:
 1654 0c03 0FB645DE 		movzbl	-34(%rbp), %eax
 1655 0c07 0FB6D0   		movzbl	%al, %edx
 1656 0c0a 0FBF45E0 		movswl	-32(%rbp), %eax
 1657 0c0e 89C1     		movl	%eax, %ecx
 1658 0c10 D3E2     		sall	%cl, %edx
 1659 0c12 89D0     		movl	%edx, %eax
 1660 0c14 89C6     		movl	%eax, %esi
 1661 0c16 0FB645DE 		movzbl	-34(%rbp), %eax
 1662 0c1a 0FB6D0   		movzbl	%al, %edx
 1663 0c1d 0FBF45E0 		movswl	-32(%rbp), %eax
 1664 0c21 B9080000 		movl	$8, %ecx
 1664      00
 1665 0c26 29C1     		subl	%eax, %ecx
 1666 0c28 89C8     		movl	%ecx, %eax
 1667 0c2a 89C1     		movl	%eax, %ecx
 1668 0c2c D3FA     		sarl	%cl, %edx
 1669 0c2e 89D0     		movl	%edx, %eax
 1670 0c30 09F0     		orl	%esi, %eax
 1671 0c32 0FBEC0   		movsbl	%al, %eax
 1672 0c35 EB2E     		jmp	.L91
 1673              	.L90:
 1675              	.LM276:
 1676 0c37 0FB645DE 		movzbl	-34(%rbp), %eax
 1677 0c3b 0FB6D0   		movzbl	%al, %edx
 1678 0c3e 0FBF45E0 		movswl	-32(%rbp), %eax
 1679 0c42 F7D8     		negl	%eax
 1680 0c44 89C1     		movl	%eax, %ecx
 1681 0c46 D3FA     		sarl	%cl, %edx
 1682 0c48 89D0     		movl	%edx, %eax
 1683 0c4a 89C6     		movl	%eax, %esi
 1684 0c4c 0FB645DE 		movzbl	-34(%rbp), %eax
 1685 0c50 0FB6D0   		movzbl	%al, %edx
 1686 0c53 0FBF45E0 		movswl	-32(%rbp), %eax
 1687 0c57 83C008   		addl	$8, %eax
 1688 0c5a 89C1     		movl	%eax, %ecx
 1689 0c5c D3E2     		sall	%cl, %edx
 1690 0c5e 89D0     		movl	%edx, %eax
 1691 0c60 09F0     		orl	%esi, %eax
 1692 0c62 0FBEC0   		movsbl	%al, %eax
 1693              	.L91:
 1695              	.LM277:
 1696 0c65 8945F0   		movl	%eax, -16(%rbp)
 209:TestLanguage.c **** 		TestLanguage_TestShiftResult(s, i, r, t, (CHAR*)"ROT(4)", 7);
 1698              	.LM278:
 1699 0c68 0FBE4DDC 		movsbl	-36(%rbp), %ecx
 1700 0c6c 0FBF75E0 		movswl	-32(%rbp), %esi
 1701 0c70 0FBE45DE 		movsbl	-34(%rbp), %eax
 1702 0c74 8B55F0   		movl	-16(%rbp), %edx
 1703 0c77 41B90700 		movl	$7, %r9d
 1703      0000
 1704 0c7d 4C8D0500 		leaq	.LC8(%rip), %r8
 1704      000000
 1705 0c84 89C7     		movl	%eax, %edi
 1706 0c86 E875F3FF 		call	TestLanguage_TestShiftResult
 1706      FF
 210:TestLanguage.c **** 		t = __ASHL(t, 1);
 1708              	.LM279:
 1709 0c8b 480FBE45 		movsbq	-36(%rbp), %rax
 1709      DC
 1710 0c90 4801C0   		addq	%rax, %rax
 1712              	.LM280:
 1713 0c93 8845DC   		movb	%al, -36(%rbp)
 211:TestLanguage.c **** 		i += 1;
 1715              	.LM281:
 1716 0c96 0FB745E0 		movzwl	-32(%rbp), %eax
 1717 0c9a 83C001   		addl	$1, %eax
 1718 0c9d 668945E0 		movw	%ax, -32(%rbp)
 1719              	.L87:
 201:TestLanguage.c **** 		s = 127;
 1721              	.LM282:
 1722 0ca1 66837DE0 		cmpw	$7, -32(%rbp)
 1722      07
 1723 0ca6 0F8EDAFE 		jle	.L92
 1723      FFFF
 212:TestLanguage.c **** 	}
 213:TestLanguage.c **** 	i = -1;
 1725              	.LM283:
 1726 0cac 66C745E0 		movw	$-1, -32(%rbp)
 1726      FFFF
 214:TestLanguage.c **** 	m = 2147483647;
 1728              	.LM284:
 1729 0cb2 C745E8FF 		movl	$2147483647, -24(%rbp)
 1729      FFFF7F
 215:TestLanguage.c **** 	m += 1;
 1731              	.LM285:
 1732 0cb9 8345E801 		addl	$1, -24(%rbp)
 216:TestLanguage.c **** 	while (i > -32) {
 1734              	.LM286:
 1735 0cbd E9C70000 		jmp	.L93
 1735      00
 1736              	.L98:
 217:TestLanguage.c **** 		l = 1;
 1738              	.LM287:
 1739 0cc2 C745F401 		movl	$1, -12(%rbp)
 1739      000000
 218:TestLanguage.c **** 		r = __LSH(l, i, 32);
 1741              	.LM288:
 1742 0cc9 66837DE0 		cmpw	$0, -32(%rbp)
 1742      00
 1743 0cce 780F     		js	.L94
 1745              	.LM289:
 1746 0cd0 8B55F4   		movl	-12(%rbp), %edx
 1747 0cd3 0FBF45E0 		movswl	-32(%rbp), %eax
 1748 0cd7 89C1     		movl	%eax, %ecx
 1749 0cd9 D3E2     		sall	%cl, %edx
 1750 0cdb 89D0     		movl	%edx, %eax
 1751 0cdd EB0F     		jmp	.L95
 1752              	.L94:
 1754              	.LM290:
 1755 0cdf 8B55F4   		movl	-12(%rbp), %edx
 1756 0ce2 0FBF45E0 		movswl	-32(%rbp), %eax
 1757 0ce6 F7D8     		negl	%eax
 1758 0ce8 89C1     		movl	%eax, %ecx
 1759 0cea D3EA     		shrl	%cl, %edx
 1760 0cec 89D0     		movl	%edx, %eax
 1761              	.L95:
 1763              	.LM291:
 1764 0cee 8945F0   		movl	%eax, -16(%rbp)
 219:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, 0, (CHAR*)"LSH", 4);
 1766              	.LM292:
 1767 0cf1 0FBF75E0 		movswl	-32(%rbp), %esi
 1768 0cf5 8B55F0   		movl	-16(%rbp), %edx
 1769 0cf8 8B45F4   		movl	-12(%rbp), %eax
 1770 0cfb 41B90400 		movl	$4, %r9d
 1770      0000
 1771 0d01 4C8D0500 		leaq	.LC4(%rip), %r8
 1771      000000
 1772 0d08 B9000000 		movl	$0, %ecx
 1772      00
 1773 0d0d 89C7     		movl	%eax, %edi
 1774 0d0f E8ECF2FF 		call	TestLanguage_TestShiftResult
 1774      FF
 220:TestLanguage.c **** 		l = 1;
 1776              	.LM293:
 1777 0d14 C745F401 		movl	$1, -12(%rbp)
 1777      000000
 221:TestLanguage.c **** 		r = __ROT(l, i, 32);
 1779              	.LM294:
 1780 0d1b 66837DE0 		cmpw	$0, -32(%rbp)
 1780      00
 1781 0d20 780F     		js	.L96
 1783              	.LM295:
 1784 0d22 8B55F4   		movl	-12(%rbp), %edx
 1785 0d25 0FBF45E0 		movswl	-32(%rbp), %eax
 1786 0d29 89C1     		movl	%eax, %ecx
 1787 0d2b D3C2     		roll	%cl, %edx
 1788 0d2d 89D0     		movl	%edx, %eax
 1789 0d2f EB21     		jmp	.L97
 1790              	.L96:
 1792              	.LM296:
 1793 0d31 8B55F4   		movl	-12(%rbp), %edx
 1794 0d34 0FBF45E0 		movswl	-32(%rbp), %eax
 1795 0d38 F7D8     		negl	%eax
 1796 0d3a 89D6     		movl	%edx, %esi
 1797 0d3c 89C1     		movl	%eax, %ecx
 1798 0d3e D3EE     		shrl	%cl, %esi
 1799 0d40 8B55F4   		movl	-12(%rbp), %edx
 1800 0d43 0FBF45E0 		movswl	-32(%rbp), %eax
 1801 0d47 83C020   		addl	$32, %eax
 1802 0d4a 89C1     		movl	%eax, %ecx
 1803 0d4c D3E2     		sall	%cl, %edx
 1804 0d4e 89D0     		movl	%edx, %eax
 1805 0d50 09F0     		orl	%esi, %eax
 1806              	.L97:
 1808              	.LM297:
 1809 0d52 8945F0   		movl	%eax, -16(%rbp)
 222:TestLanguage.c **** 		TestLanguage_TestShiftResult(l, i, r, m, (CHAR*)"ROT", 4);
 1811              	.LM298:
 1812 0d55 0FBF75E0 		movswl	-32(%rbp), %esi
 1813 0d59 8B4DE8   		movl	-24(%rbp), %ecx
 1814 0d5c 8B55F0   		movl	-16(%rbp), %edx
 1815 0d5f 8B45F4   		movl	-12(%rbp), %eax
 1816 0d62 41B90400 		movl	$4, %r9d
 1816      0000
 1817 0d68 4C8D0500 		leaq	.LC9(%rip), %r8
 1817      000000
 1818 0d6f 89C7     		movl	%eax, %edi
 1819 0d71 E88AF2FF 		call	TestLanguage_TestShiftResult
 1819      FF
 223:TestLanguage.c **** 		m = __LSHR(m, 1, 32);
 1821              	.LM299:
 1822 0d76 8B45E8   		movl	-24(%rbp), %eax
 1823 0d79 D1E8     		shrl	%eax
 1825              	.LM300:
 1826 0d7b 8945E8   		movl	%eax, -24(%rbp)
 224:TestLanguage.c **** 		i -= 1;
 1828              	.LM301:
 1829 0d7e 0FB745E0 		movzwl	-32(%rbp), %eax
 1830 0d82 83E801   		subl	$1, %eax
 1831 0d85 668945E0 		movw	%ax, -32(%rbp)
 1832              	.L93:
 216:TestLanguage.c **** 		l = 1;
 1834              	.LM302:
 1835 0d89 66837DE0 		cmpw	$-31, -32(%rbp)
 1835      E1
 1836 0d8e 0F8D2EFF 		jge	.L98
 1836      FFFF
 225:TestLanguage.c **** 	}
 226:TestLanguage.c **** 	i = -1;
 1838              	.LM303:
 1839 0d94 66C745E0 		movw	$-1, -32(%rbp)
 1839      FFFF
 227:TestLanguage.c **** 	k = 32767;
 1841              	.LM304:
 1842 0d9a 66C745E2 		movw	$32767, -30(%rbp)
 1842      FF7F
 228:TestLanguage.c **** 	k += 1;
 1844              	.LM305:
 1845 0da0 0FB745E2 		movzwl	-30(%rbp), %eax
 1846 0da4 83C001   		addl	$1, %eax
 1847 0da7 668945E2 		movw	%ax, -30(%rbp)
 229:TestLanguage.c **** 	while (i > -16) {
 1849              	.LM306:
 1850 0dab E9030100 		jmp	.L99
 1850      00
 1851              	.L104:
 230:TestLanguage.c **** 		j = 1;
 1853              	.LM307:
 1854 0db0 66C745E6 		movw	$1, -26(%rbp)
 1854      0100
 231:TestLanguage.c **** 		r = __LSH(j, i, 16);
 1856              	.LM308:
 1857 0db6 66837DE0 		cmpw	$0, -32(%rbp)
 1857      00
 1858 0dbb 7814     		js	.L100
 1860              	.LM309:
 1861 0dbd 0FB745E6 		movzwl	-26(%rbp), %eax
 1862 0dc1 0FB7D0   		movzwl	%ax, %edx
 1863 0dc4 0FBF45E0 		movswl	-32(%rbp), %eax
 1864 0dc8 89C1     		movl	%eax, %ecx
 1865 0dca D3E2     		sall	%cl, %edx
 1866 0dcc 89D0     		movl	%edx, %eax
 1867 0dce 98       		cwtl
 1868 0dcf EB14     		jmp	.L101
 1869              	.L100:
 1871              	.LM310:
 1872 0dd1 0FB745E6 		movzwl	-26(%rbp), %eax
 1873 0dd5 0FB7D0   		movzwl	%ax, %edx
 1874 0dd8 0FBF45E0 		movswl	-32(%rbp), %eax
 1875 0ddc F7D8     		negl	%eax
 1876 0dde 89C1     		movl	%eax, %ecx
 1877 0de0 D3FA     		sarl	%cl, %edx
 1878 0de2 89D0     		movl	%edx, %eax
 1879 0de4 98       		cwtl
 1880              	.L101:
 1882              	.LM311:
 1883 0de5 8945F0   		movl	%eax, -16(%rbp)
 232:TestLanguage.c **** 		TestLanguage_TestShiftResult(j, i, r, 0, (CHAR*)"LSH", 4);
 1885              	.LM312:
 1886 0de8 0FBF75E0 		movswl	-32(%rbp), %esi
 1887 0dec 0FBF45E6 		movswl	-26(%rbp), %eax
 1888 0df0 8B55F0   		movl	-16(%rbp), %edx
 1889 0df3 41B90400 		movl	$4, %r9d
 1889      0000
 1890 0df9 4C8D0500 		leaq	.LC4(%rip), %r8
 1890      000000
 1891 0e00 B9000000 		movl	$0, %ecx
 1891      00
 1892 0e05 89C7     		movl	%eax, %edi
 1893 0e07 E8F4F1FF 		call	TestLanguage_TestShiftResult
 1893      FF
 233:TestLanguage.c **** 		j = 1;
 1895              	.LM313:
 1896 0e0c 66C745E6 		movw	$1, -26(%rbp)
 1896      0100
 234:TestLanguage.c **** 		r = __ROT(j, i, 16);
 1898              	.LM314:
 1899 0e12 66837DE0 		cmpw	$0, -32(%rbp)
 1899      00
 1900 0e17 7832     		js	.L102
 1902              	.LM315:
 1903 0e19 0FB745E6 		movzwl	-26(%rbp), %eax
 1904 0e1d 0FB7D0   		movzwl	%ax, %edx
 1905 0e20 0FBF45E0 		movswl	-32(%rbp), %eax
 1906 0e24 89C1     		movl	%eax, %ecx
 1907 0e26 D3E2     		sall	%cl, %edx
 1908 0e28 89D0     		movl	%edx, %eax
 1909 0e2a 89C6     		movl	%eax, %esi
 1910 0e2c 0FB745E6 		movzwl	-26(%rbp), %eax
 1911 0e30 0FB7D0   		movzwl	%ax, %edx
 1912 0e33 0FBF45E0 		movswl	-32(%rbp), %eax
 1913 0e37 B9100000 		movl	$16, %ecx
 1913      00
 1914 0e3c 29C1     		subl	%eax, %ecx
 1915 0e3e 89C8     		movl	%ecx, %eax
 1916 0e40 89C1     		movl	%eax, %ecx
 1917 0e42 D3FA     		sarl	%cl, %edx
 1918 0e44 89D0     		movl	%edx, %eax
 1919 0e46 09F0     		orl	%esi, %eax
 1920 0e48 98       		cwtl
 1921 0e49 EB2C     		jmp	.L103
 1922              	.L102:
 1924              	.LM316:
 1925 0e4b 0FB745E6 		movzwl	-26(%rbp), %eax
 1926 0e4f 0FB7D0   		movzwl	%ax, %edx
 1927 0e52 0FBF45E0 		movswl	-32(%rbp), %eax
 1928 0e56 F7D8     		negl	%eax
 1929 0e58 89C1     		movl	%eax, %ecx
 1930 0e5a D3FA     		sarl	%cl, %edx
 1931 0e5c 89D0     		movl	%edx, %eax
 1932 0e5e 89C6     		movl	%eax, %esi
 1933 0e60 0FB745E6 		movzwl	-26(%rbp), %eax
 1934 0e64 0FB7D0   		movzwl	%ax, %edx
 1935 0e67 0FBF45E0 		movswl	-32(%rbp), %eax
 1936 0e6b 83C010   		addl	$16, %eax
 1937 0e6e 89C1     		movl	%eax, %ecx
 1938 0e70 D3E2     		sall	%cl, %edx
 1939 0e72 89D0     		movl	%edx, %eax
 1940 0e74 09F0     		orl	%esi, %eax
 1941 0e76 98       		cwtl
 1942              	.L103:
 1944              	.LM317:
 1945 0e77 8945F0   		movl	%eax, -16(%rbp)
 235:TestLanguage.c **** 		TestLanguage_TestShiftResult(j, i, r, k, (CHAR*)"ROT", 4);
 1947              	.LM318:
 1948 0e7a 0FBF4DE2 		movswl	-30(%rbp), %ecx
 1949 0e7e 0FBF75E0 		movswl	-32(%rbp), %esi
 1950 0e82 0FBF45E6 		movswl	-26(%rbp), %eax
 1951 0e86 8B55F0   		movl	-16(%rbp), %edx
 1952 0e89 41B90400 		movl	$4, %r9d
 1952      0000
 1953 0e8f 4C8D0500 		leaq	.LC9(%rip), %r8
 1953      000000
 1954 0e96 89C7     		movl	%eax, %edi
 1955 0e98 E863F1FF 		call	TestLanguage_TestShiftResult
 1955      FF
 236:TestLanguage.c **** 		k = __LSHR(k, 1, 16);
 1957              	.LM319:
 1958 0e9d 0FB745E2 		movzwl	-30(%rbp), %eax
 1959 0ea1 66D1E8   		shrw	%ax
 1961              	.LM320:
 1962 0ea4 668945E2 		movw	%ax, -30(%rbp)
 237:TestLanguage.c **** 		i -= 1;
 1964              	.LM321:
 1965 0ea8 0FB745E0 		movzwl	-32(%rbp), %eax
 1966 0eac 83E801   		subl	$1, %eax
 1967 0eaf 668945E0 		movw	%ax, -32(%rbp)
 1968              	.L99:
 229:TestLanguage.c **** 		j = 1;
 1970              	.LM322:
 1971 0eb3 66837DE0 		cmpw	$-15, -32(%rbp)
 1971      F1
 1972 0eb8 0F8DF2FE 		jge	.L104
 1972      FFFF
 238:TestLanguage.c **** 	}
 239:TestLanguage.c **** 	i = -1;
 1974              	.LM323:
 1975 0ebe 66C745E0 		movw	$-1, -32(%rbp)
 1975      FFFF
 240:TestLanguage.c **** 	t = 127;
 1977              	.LM324:
 1978 0ec4 C645DC7F 		movb	$127, -36(%rbp)
 241:TestLanguage.c **** 	t += 1;
 1980              	.LM325:
 1981 0ec8 0FB645DC 		movzbl	-36(%rbp), %eax
 1982 0ecc 83C001   		addl	$1, %eax
 1983 0ecf 8845DC   		movb	%al, -36(%rbp)
 242:TestLanguage.c **** 	while (i > -8) {
 1985              	.LM326:
 1986 0ed2 E9050100 		jmp	.L105
 1986      00
 1987              	.L110:
 243:TestLanguage.c **** 		s = 1;
 1989              	.LM327:
 1990 0ed7 C645DE01 		movb	$1, -34(%rbp)
 244:TestLanguage.c **** 		r = __LSH(s, i, 8);
 1992              	.LM328:
 1993 0edb 66837DE0 		cmpw	$0, -32(%rbp)
 1993      00
 1994 0ee0 7816     		js	.L106
 1996              	.LM329:
 1997 0ee2 0FB645DE 		movzbl	-34(%rbp), %eax
 1998 0ee6 0FB6D0   		movzbl	%al, %edx
 1999 0ee9 0FBF45E0 		movswl	-32(%rbp), %eax
 2000 0eed 89C1     		movl	%eax, %ecx
 2001 0eef D3E2     		sall	%cl, %edx
 2002 0ef1 89D0     		movl	%edx, %eax
 2003 0ef3 0FBEC0   		movsbl	%al, %eax
 2004 0ef6 EB16     		jmp	.L107
 2005              	.L106:
 2007              	.LM330:
 2008 0ef8 0FB645DE 		movzbl	-34(%rbp), %eax
 2009 0efc 0FB6D0   		movzbl	%al, %edx
 2010 0eff 0FBF45E0 		movswl	-32(%rbp), %eax
 2011 0f03 F7D8     		negl	%eax
 2012 0f05 89C1     		movl	%eax, %ecx
 2013 0f07 D3FA     		sarl	%cl, %edx
 2014 0f09 89D0     		movl	%edx, %eax
 2015 0f0b 0FBEC0   		movsbl	%al, %eax
 2016              	.L107:
 2018              	.LM331:
 2019 0f0e 8945F0   		movl	%eax, -16(%rbp)
 245:TestLanguage.c **** 		TestLanguage_TestShiftResult(s, i, r, 0, (CHAR*)"LSH", 4);
 2021              	.LM332:
 2022 0f11 0FBF75E0 		movswl	-32(%rbp), %esi
 2023 0f15 0FBE45DE 		movsbl	-34(%rbp), %eax
 2024 0f19 8B55F0   		movl	-16(%rbp), %edx
 2025 0f1c 41B90400 		movl	$4, %r9d
 2025      0000
 2026 0f22 4C8D0500 		leaq	.LC4(%rip), %r8
 2026      000000
 2027 0f29 B9000000 		movl	$0, %ecx
 2027      00
 2028 0f2e 89C7     		movl	%eax, %edi
 2029 0f30 E8CBF0FF 		call	TestLanguage_TestShiftResult
 2029      FF
 246:TestLanguage.c **** 		s = 1;
 2031              	.LM333:
 2032 0f35 C645DE01 		movb	$1, -34(%rbp)
 247:TestLanguage.c **** 		r = __ROT(s, i, 8);
 2034              	.LM334:
 2035 0f39 66837DE0 		cmpw	$0, -32(%rbp)
 2035      00
 2036 0f3e 7834     		js	.L108
 2038              	.LM335:
 2039 0f40 0FB645DE 		movzbl	-34(%rbp), %eax
 2040 0f44 0FB6D0   		movzbl	%al, %edx
 2041 0f47 0FBF45E0 		movswl	-32(%rbp), %eax
 2042 0f4b 89C1     		movl	%eax, %ecx
 2043 0f4d D3E2     		sall	%cl, %edx
 2044 0f4f 89D0     		movl	%edx, %eax
 2045 0f51 89C6     		movl	%eax, %esi
 2046 0f53 0FB645DE 		movzbl	-34(%rbp), %eax
 2047 0f57 0FB6D0   		movzbl	%al, %edx
 2048 0f5a 0FBF45E0 		movswl	-32(%rbp), %eax
 2049 0f5e B9080000 		movl	$8, %ecx
 2049      00
 2050 0f63 29C1     		subl	%eax, %ecx
 2051 0f65 89C8     		movl	%ecx, %eax
 2052 0f67 89C1     		movl	%eax, %ecx
 2053 0f69 D3FA     		sarl	%cl, %edx
 2054 0f6b 89D0     		movl	%edx, %eax
 2055 0f6d 09F0     		orl	%esi, %eax
 2056 0f6f 0FBEC0   		movsbl	%al, %eax
 2057 0f72 EB2E     		jmp	.L109
 2058              	.L108:
 2060              	.LM336:
 2061 0f74 0FB645DE 		movzbl	-34(%rbp), %eax
 2062 0f78 0FB6D0   		movzbl	%al, %edx
 2063 0f7b 0FBF45E0 		movswl	-32(%rbp), %eax
 2064 0f7f F7D8     		negl	%eax
 2065 0f81 89C1     		movl	%eax, %ecx
 2066 0f83 D3FA     		sarl	%cl, %edx
 2067 0f85 89D0     		movl	%edx, %eax
 2068 0f87 89C6     		movl	%eax, %esi
 2069 0f89 0FB645DE 		movzbl	-34(%rbp), %eax
 2070 0f8d 0FB6D0   		movzbl	%al, %edx
 2071 0f90 0FBF45E0 		movswl	-32(%rbp), %eax
 2072 0f94 83C008   		addl	$8, %eax
 2073 0f97 89C1     		movl	%eax, %ecx
 2074 0f99 D3E2     		sall	%cl, %edx
 2075 0f9b 89D0     		movl	%edx, %eax
 2076 0f9d 09F0     		orl	%esi, %eax
 2077 0f9f 0FBEC0   		movsbl	%al, %eax
 2078              	.L109:
 2080              	.LM337:
 2081 0fa2 8945F0   		movl	%eax, -16(%rbp)
 248:TestLanguage.c **** 		TestLanguage_TestShiftResult(s, i, r, t, (CHAR*)"ROT", 4);
 2083              	.LM338:
 2084 0fa5 0FBE4DDC 		movsbl	-36(%rbp), %ecx
 2085 0fa9 0FBF75E0 		movswl	-32(%rbp), %esi
 2086 0fad 0FBE45DE 		movsbl	-34(%rbp), %eax
 2087 0fb1 8B55F0   		movl	-16(%rbp), %edx
 2088 0fb4 41B90400 		movl	$4, %r9d
 2088      0000
 2089 0fba 4C8D0500 		leaq	.LC9(%rip), %r8
 2089      000000
 2090 0fc1 89C7     		movl	%eax, %edi
 2091 0fc3 E838F0FF 		call	TestLanguage_TestShiftResult
 2091      FF
 249:TestLanguage.c **** 		t = __LSHR(t, 1, 8);
 2093              	.LM339:
 2094 0fc8 0FB645DC 		movzbl	-36(%rbp), %eax
 2095 0fcc D0E8     		shrb	%al
 2097              	.LM340:
 2098 0fce 8845DC   		movb	%al, -36(%rbp)
 250:TestLanguage.c **** 		i -= 1;
 2100              	.LM341:
 2101 0fd1 0FB745E0 		movzwl	-32(%rbp), %eax
 2102 0fd5 83E801   		subl	$1, %eax
 2103 0fd8 668945E0 		movw	%ax, -32(%rbp)
 2104              	.L105:
 242:TestLanguage.c **** 		s = 1;
 2106              	.LM342:
 2107 0fdc 66837DE0 		cmpw	$-7, -32(%rbp)
 2107      F9
 2108 0fe1 0F8DF0FE 		jge	.L110
 2108      FFFF
 251:TestLanguage.c **** 	}
 252:TestLanguage.c **** 	c = 0x01;
 2110              	.LM343:
 2111 0fe7 C645DF01 		movb	$1, -33(%rbp)
 253:TestLanguage.c **** 	c = __LSHL(c, 2, 8);
 2113              	.LM344:
 2114 0feb 0FB645DF 		movzbl	-33(%rbp), %eax
 2115 0fef C1E002   		sall	$2, %eax
 2117              	.LM345:
 2118 0ff2 8845DF   		movb	%al, -33(%rbp)
 254:TestLanguage.c **** 	c = __ROTR(c, 2, 8);
 2120              	.LM346:
 2121 0ff5 0FB645DF 		movzbl	-33(%rbp), %eax
 2122 0ff9 C0E802   		shrb	$2, %al
 2123 0ffc 89C2     		movl	%eax, %edx
 2124 0ffe 0FB645DF 		movzbl	-33(%rbp), %eax
 2125 1002 C1E006   		sall	$6, %eax
 2126 1005 09D0     		orl	%edx, %eax
 2128              	.LM347:
 2129 1007 8845DF   		movb	%al, -33(%rbp)
 255:TestLanguage.c **** 	__ASSERT(c == 0x01, 93);
 2131              	.LM348:
 2132 100a 807DDF01 		cmpb	$1, -33(%rbp)
 2133 100e 740A     		je	.L111
 2135              	.LM349:
 2136 1010 BF5D0000 		movl	$93, %edi
 2136      00
 2137 1015 E8000000 		call	Modules_AssertFail@PLT
 2137      00
 2138              	.L111:
 256:TestLanguage.c **** 	b = 1;
 2140              	.LM350:
 2141 101a C645DB01 		movb	$1, -37(%rbp)
 257:TestLanguage.c **** 	b = __LSHL(b, 2, 8);
 2143              	.LM351:
 2144 101e 0FB645DB 		movzbl	-37(%rbp), %eax
 2145 1022 0FB6C0   		movzbl	%al, %eax
 2146 1025 C1E002   		sall	$2, %eax
 2148              	.LM352:
 2149 1028 8845DB   		movb	%al, -37(%rbp)
 258:TestLanguage.c **** 	b = __ROTR(b, 2, 8);
 2151              	.LM353:
 2152 102b 0FB645DB 		movzbl	-37(%rbp), %eax
 2153 102f C0E802   		shrb	$2, %al
 2154 1032 89C2     		movl	%eax, %edx
 2155 1034 0FB645DB 		movzbl	-37(%rbp), %eax
 2156 1038 0FB6C0   		movzbl	%al, %eax
 2157 103b C1E006   		sall	$6, %eax
 2158 103e 09D0     		orl	%edx, %eax
 2160              	.LM354:
 2161 1040 8845DB   		movb	%al, -37(%rbp)
 259:TestLanguage.c **** 	__ASSERT(__VAL(CHAR, b) == 0x01, 94);
 2163              	.LM355:
 2164 1043 488D45DB 		leaq	-37(%rbp), %rax
 2165 1047 0FB600   		movzbl	(%rax), %eax
 2166 104a 3C01     		cmpb	$1, %al
 2167 104c 740A     		je	.L114
 2169              	.LM356:
 2170 104e BF5E0000 		movl	$94, %edi
 2170      00
 2171 1053 E8000000 		call	Modules_AssertFail@PLT
 2171      00
 2172              	.L114:
 260:TestLanguage.c **** }
 2174              	.LM357:
 2175 1058 90       		nop
 2176 1059 488B45F8 		movq	-8(%rbp), %rax
 2177 105d 64483304 		xorq	%fs:40, %rax
 2177      25280000 
 2177      00
 2178 1066 7405     		je	.L113
 2179 1068 E8000000 		call	__stack_chk_fail@PLT
 2179      00
 2180              	.L113:
 2181 106d C9       		leave
 2182              		.cfi_def_cfa 7, 8
 2183 106e C3       		ret
 2184              		.cfi_endproc
 2185              	.LFE8:
 2202              	.Lscope2:
 2204              		.stabd	78,0,0
 2205              		.section	.rodata
 2206              	.LC10:
 2207 0046 203D2000 		.string	" = "
 2208              	.LC11:
 2209 004a 2C206578 		.string	", expected "
 2209      70656374 
 2209      65642000 
 2210              		.text
 2217              	TestLanguage_TestValue:
 2218              		.stabd	46,0,0
 261:TestLanguage.c **** 
 262:TestLanguage.c **** static void TestLanguage_TestValue (INT32 v, INT32 e, CHAR *name, ADDRESS name__len)
 263:TestLanguage.c **** {
 2220              	.LM358:
 2221              	.LFBB3:
 2222              	.LFB9:
 2223              		.cfi_startproc
 2224 106f F30F1EFA 		endbr64
 2225 1073 55       		pushq	%rbp
 2226              		.cfi_def_cfa_offset 16
 2227              		.cfi_offset 6, -16
 2228 1074 4889E5   		movq	%rsp, %rbp
 2229              		.cfi_def_cfa_register 6
 2230 1077 4883EC30 		subq	$48, %rsp
 2231 107b 897DEC   		movl	%edi, -20(%rbp)
 2232 107e 8975E8   		movl	%esi, -24(%rbp)
 2233 1081 488955E0 		movq	%rdx, -32(%rbp)
 2234 1085 48894DD8 		movq	%rcx, -40(%rbp)
 2236              	.LM359:
 2237 1089 64488B04 		movq	%fs:40, %rax
 2237      25280000 
 2237      00
 2238 1092 488945F8 		movq	%rax, -8(%rbp)
 2239 1096 31C0     		xorl	%eax, %eax
 264:TestLanguage.c **** 	__DUP(name, name__len, CHAR);
 2241              	.LM360:
 2242 1098 488B4DD8 		movq	-40(%rbp), %rcx
 2243 109c 488B45D8 		movq	-40(%rbp), %rax
 2244 10a0 488D5008 		leaq	8(%rax), %rdx
 2245 10a4 B8100000 		movl	$16, %eax
 2245      00
 2246 10a9 4883E801 		subq	$1, %rax
 2247 10ad 4801D0   		addq	%rdx, %rax
 2248 10b0 BF100000 		movl	$16, %edi
 2248      00
 2249 10b5 BA000000 		movl	$0, %edx
 2249      00
 2250 10ba 48F7F7   		divq	%rdi
 2251 10bd 486BC010 		imulq	$16, %rax, %rax
 2252 10c1 4889C2   		movq	%rax, %rdx
 2253 10c4 4881E200 		andq	$-4096, %rdx
 2253      F0FFFF
 2254 10cb 4889E6   		movq	%rsp, %rsi
 2255 10ce 4829D6   		subq	%rdx, %rsi
 2256 10d1 4889F2   		movq	%rsi, %rdx
 2257              	.L116:
 2258 10d4 4839D4   		cmpq	%rdx, %rsp
 2259 10d7 7412     		je	.L117
 2260 10d9 4881EC00 		subq	$4096, %rsp
 2260      100000
 2261 10e0 48838C24 		orq	$0, 4088(%rsp)
 2261      F80F0000 
 2261      00
 2262 10e9 EBE9     		jmp	.L116
 2263              	.L117:
 2264 10eb 4889C2   		movq	%rax, %rdx
 2265 10ee 81E2FF0F 		andl	$4095, %edx
 2265      0000
 2266 10f4 4829D4   		subq	%rdx, %rsp
 2267 10f7 4889C2   		movq	%rax, %rdx
 2268 10fa 81E2FF0F 		andl	$4095, %edx
 2268      0000
 2269 1100 4885D2   		testq	%rdx, %rdx
 2270 1103 7410     		je	.L118
 2271 1105 25FF0F00 		andl	$4095, %eax
 2271      00
 2272 110a 4883E808 		subq	$8, %rax
 2273 110e 4801E0   		addq	%rsp, %rax
 2274 1111 48830800 		orq	$0, (%rax)
 2275              	.L118:
 2276 1115 4889E0   		movq	%rsp, %rax
 2277 1118 4883C00F 		addq	$15, %rax
 2278 111c 48C1E804 		shrq	$4, %rax
 2279 1120 48C1E004 		salq	$4, %rax
 2280 1124 4889C7   		movq	%rax, %rdi
 2281 1127 488B45E0 		movq	-32(%rbp), %rax
 2282 112b 4889CA   		movq	%rcx, %rdx
 2283 112e 4889C6   		movq	%rax, %rsi
 2284 1131 E8000000 		call	memcpy@PLT
 2284      00
 2285 1136 488945E0 		movq	%rax, -32(%rbp)
 265:TestLanguage.c **** 	if (v != e) {
 2287              	.LM361:
 2288 113a 8B45EC   		movl	-20(%rbp), %eax
 2289 113d 3B45E8   		cmpl	-24(%rbp), %eax
 2290 1140 745E     		je	.L121
 266:TestLanguage.c **** 		Console_String(name, name__len);
 2292              	.LM362:
 2293 1142 488B55D8 		movq	-40(%rbp), %rdx
 2294 1146 488B45E0 		movq	-32(%rbp), %rax
 2295 114a 4889D6   		movq	%rdx, %rsi
 2296 114d 4889C7   		movq	%rax, %rdi
 2297 1150 E8000000 		call	Console_String@PLT
 2297      00
 267:TestLanguage.c **** 		Console_String((CHAR*)" = ", 4);
 2299              	.LM363:
 2300 1155 BE040000 		movl	$4, %esi
 2300      00
 2301 115a 488D3D00 		leaq	.LC10(%rip), %rdi
 2301      000000
 2302 1161 E8000000 		call	Console_String@PLT
 2302      00
 268:TestLanguage.c **** 		Console_Int(v, 1);
 2304              	.LM364:
 2305 1166 8B45EC   		movl	-20(%rbp), %eax
 2306 1169 4898     		cltq
 2307 116b BE010000 		movl	$1, %esi
 2307      00
 2308 1170 4889C7   		movq	%rax, %rdi
 2309 1173 E8000000 		call	Console_Int@PLT
 2309      00
 269:TestLanguage.c **** 		Console_String((CHAR*)", expected ", 12);
 2311              	.LM365:
 2312 1178 BE0C0000 		movl	$12, %esi
 2312      00
 2313 117d 488D3D00 		leaq	.LC11(%rip), %rdi
 2313      000000
 2314 1184 E8000000 		call	Console_String@PLT
 2314      00
 270:TestLanguage.c **** 		Console_Int(e, 1);
 2316              	.LM366:
 2317 1189 8B45E8   		movl	-24(%rbp), %eax
 2318 118c 4898     		cltq
 2319 118e BE010000 		movl	$1, %esi
 2319      00
 2320 1193 4889C7   		movq	%rax, %rdi
 2321 1196 E8000000 		call	Console_Int@PLT
 2321      00
 271:TestLanguage.c **** 		Console_Ln();
 2323              	.LM367:
 2324 119b E8000000 		call	Console_Ln@PLT
 2324      00
 2325              	.L121:
 272:TestLanguage.c **** 	}
 273:TestLanguage.c **** 	__DEL(name);
 274:TestLanguage.c **** }
 2327              	.LM368:
 2328 11a0 90       		nop
 2329 11a1 488B45F8 		movq	-8(%rbp), %rax
 2330 11a5 64483304 		xorq	%fs:40, %rax
 2330      25280000 
 2330      00
 2331 11ae 7405     		je	.L120
 2332 11b0 E8000000 		call	__stack_chk_fail@PLT
 2332      00
 2333              	.L120:
 2334 11b5 C9       		leave
 2335              		.cfi_def_cfa 7, 8
 2336 11b6 C3       		ret
 2337              		.cfi_endproc
 2338              	.LFE9:
 2340              	.Lscope3:
 2342              		.stabd	78,0,0
 2346              	TestLanguage_side:
 2347              		.stabd	46,0,0
 275:TestLanguage.c **** 
 276:TestLanguage.c **** static INT16 TestLanguage_side (INT16 i)
 277:TestLanguage.c **** {
 2349              	.LM369:
 2350              	.LFBB4:
 2351              	.LFB10:
 2352              		.cfi_startproc
 2353 11b7 F30F1EFA 		endbr64
 2354 11bb 55       		pushq	%rbp
 2355              		.cfi_def_cfa_offset 16
 2356              		.cfi_offset 6, -16
 2357 11bc 4889E5   		movq	%rsp, %rbp
 2358              		.cfi_def_cfa_register 6
 2359 11bf 89F8     		movl	%edi, %eax
 2360 11c1 668945FC 		movw	%ax, -4(%rbp)
 278:TestLanguage.c **** 	return i;
 2362              	.LM370:
 2363 11c5 0FB745FC 		movzwl	-4(%rbp), %eax
 279:TestLanguage.c **** }
 2365              	.LM371:
 2366 11c9 5D       		popq	%rbp
 2367              		.cfi_def_cfa 7, 8
 2368 11ca C3       		ret
 2369              		.cfi_endproc
 2370              	.LFE10:
 2372              	.Lscope4:
 2374              		.stabd	78,0,0
 2375              		.section	.rodata
 2376              	.LC12:
 2377 0056 34204449 		.string	"4 DIV 2"
 2377      56203200 
 2378              	.LC13:
 2379 005e 73696465 		.string	"side(4) DIV side(2)"
 2379      28342920 
 2379      44495620 
 2379      73696465 
 2379      28322900 
 2380              	.LC14:
 2381 0072 35204449 		.string	"5 DIV 2"
 2381      56203200 
 2382              	.LC15:
 2383 007a 73696465 		.string	"side(5) DIV side(2)"
 2383      28352920 
 2383      44495620 
 2383      73696465 
 2383      28322900 
 2384              	.LC16:
 2385 008e 36204449 		.string	"6 DIV 2"
 2385      56203200 
 2386              	.LC17:
 2387 0096 73696465 		.string	"side(6) DIV side(2)"
 2387      28362920 
 2387      44495620 
 2387      73696465 
 2387      28322900 
 2388              	.LC18:
 2389 00aa 37204449 		.string	"7 DIV 2"
 2389      56203200 
 2390              	.LC19:
 2391 00b2 73696465 		.string	"side(7) DIV side(2)"
 2391      28372920 
 2391      44495620 
 2391      73696465 
 2391      28322900 
 2392              	.LC20:
 2393 00c6 282D3429 		.string	"(-4) DIV 2"
 2393      20444956 
 2393      203200
 2394              	.LC21:
 2395 00d1 73696465 		.string	"side(-4) DIV side(2)"
 2395      282D3429 
 2395      20444956 
 2395      20736964 
 2395      65283229 
 2396              	.LC22:
 2397 00e6 282D3529 		.string	"(-5) DIV 2"
 2397      20444956 
 2397      203200
 2398              	.LC23:
 2399 00f1 73696465 		.string	"side(-5) DIV side(2)"
 2399      282D3529 
 2399      20444956 
 2399      20736964 
 2399      65283229 
 2400              	.LC24:
 2401 0106 282D3629 		.string	"(-6) DIV 2"
 2401      20444956 
 2401      203200
 2402              	.LC25:
 2403 0111 73696465 		.string	"side(-6) DIV side(2)"
 2403      282D3629 
 2403      20444956 
 2403      20736964 
 2403      65283229 
 2404              	.LC26:
 2405 0126 282D3729 		.string	"(-7) DIV 2"
 2405      20444956 
 2405      203200
 2406              	.LC27:
 2407 0131 73696465 		.string	"side(-7) DIV side(2)"
 2407      282D3729 
 2407      20444956 
 2407      20736964 
 2407      65283229 
 2408              	.LC28:
 2409 0146 34204449 		.string	"4 DIV (-2)"
 2409      5620282D 
 2409      322900
 2410              	.LC29:
 2411 0151 73696465 		.string	"side(4) DIV side(-2)"
 2411      28342920 
 2411      44495620 
 2411      73696465 
 2411      282D3229 
 2412              	.LC30:
 2413 0166 35204449 		.string	"5 DIV (-2)"
 2413      5620282D 
 2413      322900
 2414              	.LC31:
 2415 0171 73696465 		.string	"side(5) DIV side(-2)"
 2415      28352920 
 2415      44495620 
 2415      73696465 
 2415      282D3229 
 2416              	.LC32:
 2417 0186 36204449 		.string	"6 DIV (-2)"
 2417      5620282D 
 2417      322900
 2418              	.LC33:
 2419 0191 73696465 		.string	"side(6) DIV side(-2)"
 2419      28362920 
 2419      44495620 
 2419      73696465 
 2419      282D3229 
 2420              	.LC34:
 2421 01a6 37204449 		.string	"7 DIV (-2)"
 2421      5620282D 
 2421      322900
 2422              	.LC35:
 2423 01b1 73696465 		.string	"side(7) DIV side(-2)"
 2423      28372920 
 2423      44495620 
 2423      73696465 
 2423      282D3229 
 2424              	.LC36:
 2425 01c6 282D3429 		.string	"(-4) DIV (-2)"
 2425      20444956 
 2425      20282D32 
 2425      2900
 2426              	.LC37:
 2427 01d4 73696465 		.string	"side(-4) DIV side(-2)"
 2427      282D3429 
 2427      20444956 
 2427      20736964 
 2427      65282D32 
 2428              	.LC38:
 2429 01ea 282D3529 		.string	"(-5) DIV (-2)"
 2429      20444956 
 2429      20282D32 
 2429      2900
 2430              	.LC39:
 2431 01f8 73696465 		.string	"side(-5) DIV side(-2)"
 2431      282D3529 
 2431      20444956 
 2431      20736964 
 2431      65282D32 
 2432              	.LC40:
 2433 020e 282D3629 		.string	"(-6) DIV (-2)"
 2433      20444956 
 2433      20282D32 
 2433      2900
 2434              	.LC41:
 2435 021c 73696465 		.string	"side(-6) DIV side(-2)"
 2435      282D3629 
 2435      20444956 
 2435      20736964 
 2435      65282D32 
 2436              	.LC42:
 2437 0232 282D3729 		.string	"(-7) DIV (-2)"
 2437      20444956 
 2437      20282D32 
 2437      2900
 2438              	.LC43:
 2439 0240 73696465 		.string	"side(-7) DIV side(-2)"
 2439      282D3729 
 2439      20444956 
 2439      20736964 
 2439      65282D32 
 2440              	.LC44:
 2441 0256 34204D4F 		.string	"4 MOD 3"
 2441      44203300 
 2442              	.LC45:
 2443 025e 35204D4F 		.string	"5 MOD 3"
 2443      44203300 
 2444              	.LC46:
 2445 0266 36204D4F 		.string	"6 MOD 3"
 2445      44203300 
 2446              	.LC47:
 2447 026e 37204D4F 		.string	"7 MOD 3"
 2447      44203300 
 2448              	.LC48:
 2449 0276 2D34204D 		.string	"-4 MOD 3"
 2449      4F442033 
 2449      00
 2450              	.LC49:
 2451 027f 2D35204D 		.string	"-5 MOD 3"
 2451      4F442033 
 2451      00
 2452              	.LC50:
 2453 0288 2D36204D 		.string	"-6 MOD 3"
 2453      4F442033 
 2453      00
 2454              	.LC51:
 2455 0291 2D37204D 		.string	"-7 MOD 3"
 2455      4F442033 
 2455      00
 2456              	.LC52:
 2457 029a 34204D4F 		.string	"4 MOD -3"
 2457      44202D33 
 2457      00
 2458              	.LC53:
 2459 02a3 35204D4F 		.string	"5 MOD -3"
 2459      44202D33 
 2459      00
 2460              	.LC54:
 2461 02ac 36204D4F 		.string	"6 MOD -3"
 2461      44202D33 
 2461      00
 2462              	.LC55:
 2463 02b5 37204D4F 		.string	"7 MOD -3"
 2463      44202D33 
 2463      00
 2464              	.LC56:
 2465 02be 2D34204D 		.string	"-4 MOD -3"
 2465      4F44202D 
 2465      3300
 2466              	.LC57:
 2467 02c8 2D35204D 		.string	"-5 MOD -3"
 2467      4F44202D 
 2467      3300
 2468              	.LC58:
 2469 02d2 2D36204D 		.string	"-6 MOD -3"
 2469      4F44202D 
 2469      3300
 2470              	.LC59:
 2471 02dc 2D37204D 		.string	"-7 MOD -3"
 2471      4F44202D 
 2471      3300
 2472              		.text
 2475              	TestLanguage_DivMod:
 2476              		.stabd	46,0,0
 280:TestLanguage.c **** 
 281:TestLanguage.c **** static void TestLanguage_DivMod (void)
 282:TestLanguage.c **** {
 2478              	.LM372:
 2479              	.LFBB5:
 2480              	.LFB11:
 2481              		.cfi_startproc
 2482 11cb F30F1EFA 		endbr64
 2483 11cf 55       		pushq	%rbp
 2484              		.cfi_def_cfa_offset 16
 2485              		.cfi_offset 6, -16
 2486 11d0 4889E5   		movq	%rsp, %rbp
 2487              		.cfi_def_cfa_register 6
 2488 11d3 53       		pushq	%rbx
 2489 11d4 4883EC18 		subq	$24, %rsp
 2490              		.cfi_offset 3, -24
 283:TestLanguage.c **** 	INT16 i, j;
 284:TestLanguage.c **** 	j = 2;
 2492              	.LM373:
 2493 11d8 66C745EC 		movw	$2, -20(%rbp)
 2493      0200
 285:TestLanguage.c **** 	i = 4;
 2495              	.LM374:
 2496 11de 66C745EE 		movw	$4, -18(%rbp)
 2496      0400
 286:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"4 DIV 2", 8);
 2498              	.LM375:
 2499 11e4 66837DEE 		cmpw	$0, -18(%rbp)
 2499      00
 2500 11e9 7E14     		jle	.L125
 2502              	.LM376:
 2503 11eb 66837DEC 		cmpw	$0, -20(%rbp)
 2503      00
 2504 11f0 7E0D     		jle	.L125
 2506              	.LM377:
 2507 11f2 0FBF45EE 		movswl	-18(%rbp), %eax
 2508 11f6 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2510              	.LM378:
 2511 11fa 99       		cltd
 2512 11fb F7F9     		idivl	%ecx
 2513 11fd EB15     		jmp	.L126
 2514              	.L125:
 2516              	.LM379:
 2517 11ff 480FBF55 		movswq	-20(%rbp), %rdx
 2517      EC
 2518 1204 480FBF45 		movswq	-18(%rbp), %rax
 2518      EE
 2519 1209 4889D6   		movq	%rdx, %rsi
 2520 120c 4889C7   		movq	%rax, %rdi
 2521 120f E8000000 		call	SYSTEM_DIV@PLT
 2521      00
 2522              	.L126:
 2524              	.LM380:
 2525 1214 B9080000 		movl	$8, %ecx
 2525      00
 2526 1219 488D1500 		leaq	.LC12(%rip), %rdx
 2526      000000
 2527 1220 BE020000 		movl	$2, %esi
 2527      00
 2528 1225 89C7     		movl	%eax, %edi
 2529 1227 E843FEFF 		call	TestLanguage_TestValue
 2529      FF
 287:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(4)
 2531              	.LM381:
 2532 122c 0FBF45EC 		movswl	-20(%rbp), %eax
 2533 1230 89C7     		movl	%eax, %edi
 2534 1232 E880FFFF 		call	TestLanguage_side
 2534      FF
 2535 1237 480FBFD8 		movswq	%ax, %rbx
 2536 123b 0FBF45EE 		movswl	-18(%rbp), %eax
 2537 123f 89C7     		movl	%eax, %edi
 2538 1241 E871FFFF 		call	TestLanguage_side
 2538      FF
 2539 1246 480FBFC0 		movswq	%ax, %rax
 2540 124a 4889DE   		movq	%rbx, %rsi
 2541 124d 4889C7   		movq	%rax, %rdi
 2542 1250 E8000000 		call	SYSTEM_DIV@PLT
 2542      00
 2544              	.LM382:
 2545 1255 B9140000 		movl	$20, %ecx
 2545      00
 2546 125a 488D1500 		leaq	.LC13(%rip), %rdx
 2546      000000
 2547 1261 BE020000 		movl	$2, %esi
 2547      00
 2548 1266 89C7     		movl	%eax, %edi
 2549 1268 E802FEFF 		call	TestLanguage_TestValue
 2549      FF
 288:TestLanguage.c **** 	i = 5;
 2551              	.LM383:
 2552 126d 66C745EE 		movw	$5, -18(%rbp)
 2552      0500
 289:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"5 DIV 2", 8);
 2554              	.LM384:
 2555 1273 66837DEE 		cmpw	$0, -18(%rbp)
 2555      00
 2556 1278 7E14     		jle	.L127
 2558              	.LM385:
 2559 127a 66837DEC 		cmpw	$0, -20(%rbp)
 2559      00
 2560 127f 7E0D     		jle	.L127
 2562              	.LM386:
 2563 1281 0FBF45EE 		movswl	-18(%rbp), %eax
 2564 1285 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2566              	.LM387:
 2567 1289 99       		cltd
 2568 128a F7F9     		idivl	%ecx
 2569 128c EB15     		jmp	.L128
 2570              	.L127:
 2572              	.LM388:
 2573 128e 480FBF55 		movswq	-20(%rbp), %rdx
 2573      EC
 2574 1293 480FBF45 		movswq	-18(%rbp), %rax
 2574      EE
 2575 1298 4889D6   		movq	%rdx, %rsi
 2576 129b 4889C7   		movq	%rax, %rdi
 2577 129e E8000000 		call	SYSTEM_DIV@PLT
 2577      00
 2578              	.L128:
 2580              	.LM389:
 2581 12a3 B9080000 		movl	$8, %ecx
 2581      00
 2582 12a8 488D1500 		leaq	.LC14(%rip), %rdx
 2582      000000
 2583 12af BE020000 		movl	$2, %esi
 2583      00
 2584 12b4 89C7     		movl	%eax, %edi
 2585 12b6 E8B4FDFF 		call	TestLanguage_TestValue
 2585      FF
 290:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(5)
 2587              	.LM390:
 2588 12bb 0FBF45EC 		movswl	-20(%rbp), %eax
 2589 12bf 89C7     		movl	%eax, %edi
 2590 12c1 E8F1FEFF 		call	TestLanguage_side
 2590      FF
 2591 12c6 480FBFD8 		movswq	%ax, %rbx
 2592 12ca 0FBF45EE 		movswl	-18(%rbp), %eax
 2593 12ce 89C7     		movl	%eax, %edi
 2594 12d0 E8E2FEFF 		call	TestLanguage_side
 2594      FF
 2595 12d5 480FBFC0 		movswq	%ax, %rax
 2596 12d9 4889DE   		movq	%rbx, %rsi
 2597 12dc 4889C7   		movq	%rax, %rdi
 2598 12df E8000000 		call	SYSTEM_DIV@PLT
 2598      00
 2600              	.LM391:
 2601 12e4 B9140000 		movl	$20, %ecx
 2601      00
 2602 12e9 488D1500 		leaq	.LC15(%rip), %rdx
 2602      000000
 2603 12f0 BE020000 		movl	$2, %esi
 2603      00
 2604 12f5 89C7     		movl	%eax, %edi
 2605 12f7 E873FDFF 		call	TestLanguage_TestValue
 2605      FF
 291:TestLanguage.c **** 	i = 6;
 2607              	.LM392:
 2608 12fc 66C745EE 		movw	$6, -18(%rbp)
 2608      0600
 292:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"6 DIV 2", 8);
 2610              	.LM393:
 2611 1302 66837DEE 		cmpw	$0, -18(%rbp)
 2611      00
 2612 1307 7E14     		jle	.L129
 2614              	.LM394:
 2615 1309 66837DEC 		cmpw	$0, -20(%rbp)
 2615      00
 2616 130e 7E0D     		jle	.L129
 2618              	.LM395:
 2619 1310 0FBF45EE 		movswl	-18(%rbp), %eax
 2620 1314 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2622              	.LM396:
 2623 1318 99       		cltd
 2624 1319 F7F9     		idivl	%ecx
 2625 131b EB15     		jmp	.L130
 2626              	.L129:
 2628              	.LM397:
 2629 131d 480FBF55 		movswq	-20(%rbp), %rdx
 2629      EC
 2630 1322 480FBF45 		movswq	-18(%rbp), %rax
 2630      EE
 2631 1327 4889D6   		movq	%rdx, %rsi
 2632 132a 4889C7   		movq	%rax, %rdi
 2633 132d E8000000 		call	SYSTEM_DIV@PLT
 2633      00
 2634              	.L130:
 2636              	.LM398:
 2637 1332 B9080000 		movl	$8, %ecx
 2637      00
 2638 1337 488D1500 		leaq	.LC16(%rip), %rdx
 2638      000000
 2639 133e BE030000 		movl	$3, %esi
 2639      00
 2640 1343 89C7     		movl	%eax, %edi
 2641 1345 E825FDFF 		call	TestLanguage_TestValue
 2641      FF
 293:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(6)
 2643              	.LM399:
 2644 134a 0FBF45EC 		movswl	-20(%rbp), %eax
 2645 134e 89C7     		movl	%eax, %edi
 2646 1350 E862FEFF 		call	TestLanguage_side
 2646      FF
 2647 1355 480FBFD8 		movswq	%ax, %rbx
 2648 1359 0FBF45EE 		movswl	-18(%rbp), %eax
 2649 135d 89C7     		movl	%eax, %edi
 2650 135f E853FEFF 		call	TestLanguage_side
 2650      FF
 2651 1364 480FBFC0 		movswq	%ax, %rax
 2652 1368 4889DE   		movq	%rbx, %rsi
 2653 136b 4889C7   		movq	%rax, %rdi
 2654 136e E8000000 		call	SYSTEM_DIV@PLT
 2654      00
 2656              	.LM400:
 2657 1373 B9140000 		movl	$20, %ecx
 2657      00
 2658 1378 488D1500 		leaq	.LC17(%rip), %rdx
 2658      000000
 2659 137f BE030000 		movl	$3, %esi
 2659      00
 2660 1384 89C7     		movl	%eax, %edi
 2661 1386 E8E4FCFF 		call	TestLanguage_TestValue
 2661      FF
 294:TestLanguage.c **** 	i = 7;
 2663              	.LM401:
 2664 138b 66C745EE 		movw	$7, -18(%rbp)
 2664      0700
 295:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"7 DIV 2", 8);
 2666              	.LM402:
 2667 1391 66837DEE 		cmpw	$0, -18(%rbp)
 2667      00
 2668 1396 7E14     		jle	.L131
 2670              	.LM403:
 2671 1398 66837DEC 		cmpw	$0, -20(%rbp)
 2671      00
 2672 139d 7E0D     		jle	.L131
 2674              	.LM404:
 2675 139f 0FBF45EE 		movswl	-18(%rbp), %eax
 2676 13a3 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2678              	.LM405:
 2679 13a7 99       		cltd
 2680 13a8 F7F9     		idivl	%ecx
 2681 13aa EB15     		jmp	.L132
 2682              	.L131:
 2684              	.LM406:
 2685 13ac 480FBF55 		movswq	-20(%rbp), %rdx
 2685      EC
 2686 13b1 480FBF45 		movswq	-18(%rbp), %rax
 2686      EE
 2687 13b6 4889D6   		movq	%rdx, %rsi
 2688 13b9 4889C7   		movq	%rax, %rdi
 2689 13bc E8000000 		call	SYSTEM_DIV@PLT
 2689      00
 2690              	.L132:
 2692              	.LM407:
 2693 13c1 B9080000 		movl	$8, %ecx
 2693      00
 2694 13c6 488D1500 		leaq	.LC18(%rip), %rdx
 2694      000000
 2695 13cd BE030000 		movl	$3, %esi
 2695      00
 2696 13d2 89C7     		movl	%eax, %edi
 2697 13d4 E896FCFF 		call	TestLanguage_TestValue
 2697      FF
 296:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(7)
 2699              	.LM408:
 2700 13d9 0FBF45EC 		movswl	-20(%rbp), %eax
 2701 13dd 89C7     		movl	%eax, %edi
 2702 13df E8D3FDFF 		call	TestLanguage_side
 2702      FF
 2703 13e4 480FBFD8 		movswq	%ax, %rbx
 2704 13e8 0FBF45EE 		movswl	-18(%rbp), %eax
 2705 13ec 89C7     		movl	%eax, %edi
 2706 13ee E8C4FDFF 		call	TestLanguage_side
 2706      FF
 2707 13f3 480FBFC0 		movswq	%ax, %rax
 2708 13f7 4889DE   		movq	%rbx, %rsi
 2709 13fa 4889C7   		movq	%rax, %rdi
 2710 13fd E8000000 		call	SYSTEM_DIV@PLT
 2710      00
 2712              	.LM409:
 2713 1402 B9140000 		movl	$20, %ecx
 2713      00
 2714 1407 488D1500 		leaq	.LC19(%rip), %rdx
 2714      000000
 2715 140e BE030000 		movl	$3, %esi
 2715      00
 2716 1413 89C7     		movl	%eax, %edi
 2717 1415 E855FCFF 		call	TestLanguage_TestValue
 2717      FF
 297:TestLanguage.c **** 	i = -4;
 2719              	.LM410:
 2720 141a 66C745EE 		movw	$-4, -18(%rbp)
 2720      FCFF
 298:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -2, (CHAR*)"(-4) DIV 2", 11);
 2722              	.LM411:
 2723 1420 66837DEE 		cmpw	$0, -18(%rbp)
 2723      00
 2724 1425 7E14     		jle	.L133
 2726              	.LM412:
 2727 1427 66837DEC 		cmpw	$0, -20(%rbp)
 2727      00
 2728 142c 7E0D     		jle	.L133
 2730              	.LM413:
 2731 142e 0FBF45EE 		movswl	-18(%rbp), %eax
 2732 1432 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2734              	.LM414:
 2735 1436 99       		cltd
 2736 1437 F7F9     		idivl	%ecx
 2737 1439 EB15     		jmp	.L134
 2738              	.L133:
 2740              	.LM415:
 2741 143b 480FBF55 		movswq	-20(%rbp), %rdx
 2741      EC
 2742 1440 480FBF45 		movswq	-18(%rbp), %rax
 2742      EE
 2743 1445 4889D6   		movq	%rdx, %rsi
 2744 1448 4889C7   		movq	%rax, %rdi
 2745 144b E8000000 		call	SYSTEM_DIV@PLT
 2745      00
 2746              	.L134:
 2748              	.LM416:
 2749 1450 B90B0000 		movl	$11, %ecx
 2749      00
 2750 1455 488D1500 		leaq	.LC20(%rip), %rdx
 2750      000000
 2751 145c BEFEFFFF 		movl	$-2, %esi
 2751      FF
 2752 1461 89C7     		movl	%eax, %edi
 2753 1463 E807FCFF 		call	TestLanguage_TestValue
 2753      FF
 299:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -2, (CHAR*)"side(-
 2755              	.LM417:
 2756 1468 0FBF45EC 		movswl	-20(%rbp), %eax
 2757 146c 89C7     		movl	%eax, %edi
 2758 146e E844FDFF 		call	TestLanguage_side
 2758      FF
 2759 1473 480FBFD8 		movswq	%ax, %rbx
 2760 1477 0FBF45EE 		movswl	-18(%rbp), %eax
 2761 147b 89C7     		movl	%eax, %edi
 2762 147d E835FDFF 		call	TestLanguage_side
 2762      FF
 2763 1482 480FBFC0 		movswq	%ax, %rax
 2764 1486 4889DE   		movq	%rbx, %rsi
 2765 1489 4889C7   		movq	%rax, %rdi
 2766 148c E8000000 		call	SYSTEM_DIV@PLT
 2766      00
 2768              	.LM418:
 2769 1491 B9150000 		movl	$21, %ecx
 2769      00
 2770 1496 488D1500 		leaq	.LC21(%rip), %rdx
 2770      000000
 2771 149d BEFEFFFF 		movl	$-2, %esi
 2771      FF
 2772 14a2 89C7     		movl	%eax, %edi
 2773 14a4 E8C6FBFF 		call	TestLanguage_TestValue
 2773      FF
 300:TestLanguage.c **** 	i = -5;
 2775              	.LM419:
 2776 14a9 66C745EE 		movw	$-5, -18(%rbp)
 2776      FBFF
 301:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"(-5) DIV 2", 11);
 2778              	.LM420:
 2779 14af 66837DEE 		cmpw	$0, -18(%rbp)
 2779      00
 2780 14b4 7E14     		jle	.L135
 2782              	.LM421:
 2783 14b6 66837DEC 		cmpw	$0, -20(%rbp)
 2783      00
 2784 14bb 7E0D     		jle	.L135
 2786              	.LM422:
 2787 14bd 0FBF45EE 		movswl	-18(%rbp), %eax
 2788 14c1 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2790              	.LM423:
 2791 14c5 99       		cltd
 2792 14c6 F7F9     		idivl	%ecx
 2793 14c8 EB15     		jmp	.L136
 2794              	.L135:
 2796              	.LM424:
 2797 14ca 480FBF55 		movswq	-20(%rbp), %rdx
 2797      EC
 2798 14cf 480FBF45 		movswq	-18(%rbp), %rax
 2798      EE
 2799 14d4 4889D6   		movq	%rdx, %rsi
 2800 14d7 4889C7   		movq	%rax, %rdi
 2801 14da E8000000 		call	SYSTEM_DIV@PLT
 2801      00
 2802              	.L136:
 2804              	.LM425:
 2805 14df B90B0000 		movl	$11, %ecx
 2805      00
 2806 14e4 488D1500 		leaq	.LC22(%rip), %rdx
 2806      000000
 2807 14eb BEFDFFFF 		movl	$-3, %esi
 2807      FF
 2808 14f0 89C7     		movl	%eax, %edi
 2809 14f2 E878FBFF 		call	TestLanguage_TestValue
 2809      FF
 302:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(-
 2811              	.LM426:
 2812 14f7 0FBF45EC 		movswl	-20(%rbp), %eax
 2813 14fb 89C7     		movl	%eax, %edi
 2814 14fd E8B5FCFF 		call	TestLanguage_side
 2814      FF
 2815 1502 480FBFD8 		movswq	%ax, %rbx
 2816 1506 0FBF45EE 		movswl	-18(%rbp), %eax
 2817 150a 89C7     		movl	%eax, %edi
 2818 150c E8A6FCFF 		call	TestLanguage_side
 2818      FF
 2819 1511 480FBFC0 		movswq	%ax, %rax
 2820 1515 4889DE   		movq	%rbx, %rsi
 2821 1518 4889C7   		movq	%rax, %rdi
 2822 151b E8000000 		call	SYSTEM_DIV@PLT
 2822      00
 2824              	.LM427:
 2825 1520 B9150000 		movl	$21, %ecx
 2825      00
 2826 1525 488D1500 		leaq	.LC23(%rip), %rdx
 2826      000000
 2827 152c BEFDFFFF 		movl	$-3, %esi
 2827      FF
 2828 1531 89C7     		movl	%eax, %edi
 2829 1533 E837FBFF 		call	TestLanguage_TestValue
 2829      FF
 303:TestLanguage.c **** 	i = -6;
 2831              	.LM428:
 2832 1538 66C745EE 		movw	$-6, -18(%rbp)
 2832      FAFF
 304:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"(-6) DIV 2", 11);
 2834              	.LM429:
 2835 153e 66837DEE 		cmpw	$0, -18(%rbp)
 2835      00
 2836 1543 7E14     		jle	.L137
 2838              	.LM430:
 2839 1545 66837DEC 		cmpw	$0, -20(%rbp)
 2839      00
 2840 154a 7E0D     		jle	.L137
 2842              	.LM431:
 2843 154c 0FBF45EE 		movswl	-18(%rbp), %eax
 2844 1550 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2846              	.LM432:
 2847 1554 99       		cltd
 2848 1555 F7F9     		idivl	%ecx
 2849 1557 EB15     		jmp	.L138
 2850              	.L137:
 2852              	.LM433:
 2853 1559 480FBF55 		movswq	-20(%rbp), %rdx
 2853      EC
 2854 155e 480FBF45 		movswq	-18(%rbp), %rax
 2854      EE
 2855 1563 4889D6   		movq	%rdx, %rsi
 2856 1566 4889C7   		movq	%rax, %rdi
 2857 1569 E8000000 		call	SYSTEM_DIV@PLT
 2857      00
 2858              	.L138:
 2860              	.LM434:
 2861 156e B90B0000 		movl	$11, %ecx
 2861      00
 2862 1573 488D1500 		leaq	.LC24(%rip), %rdx
 2862      000000
 2863 157a BEFDFFFF 		movl	$-3, %esi
 2863      FF
 2864 157f 89C7     		movl	%eax, %edi
 2865 1581 E8E9FAFF 		call	TestLanguage_TestValue
 2865      FF
 305:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(-
 2867              	.LM435:
 2868 1586 0FBF45EC 		movswl	-20(%rbp), %eax
 2869 158a 89C7     		movl	%eax, %edi
 2870 158c E826FCFF 		call	TestLanguage_side
 2870      FF
 2871 1591 480FBFD8 		movswq	%ax, %rbx
 2872 1595 0FBF45EE 		movswl	-18(%rbp), %eax
 2873 1599 89C7     		movl	%eax, %edi
 2874 159b E817FCFF 		call	TestLanguage_side
 2874      FF
 2875 15a0 480FBFC0 		movswq	%ax, %rax
 2876 15a4 4889DE   		movq	%rbx, %rsi
 2877 15a7 4889C7   		movq	%rax, %rdi
 2878 15aa E8000000 		call	SYSTEM_DIV@PLT
 2878      00
 2880              	.LM436:
 2881 15af B9150000 		movl	$21, %ecx
 2881      00
 2882 15b4 488D1500 		leaq	.LC25(%rip), %rdx
 2882      000000
 2883 15bb BEFDFFFF 		movl	$-3, %esi
 2883      FF
 2884 15c0 89C7     		movl	%eax, %edi
 2885 15c2 E8A8FAFF 		call	TestLanguage_TestValue
 2885      FF
 306:TestLanguage.c **** 	i = -7;
 2887              	.LM437:
 2888 15c7 66C745EE 		movw	$-7, -18(%rbp)
 2888      F9FF
 307:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -4, (CHAR*)"(-7) DIV 2", 11);
 2890              	.LM438:
 2891 15cd 66837DEE 		cmpw	$0, -18(%rbp)
 2891      00
 2892 15d2 7E14     		jle	.L139
 2894              	.LM439:
 2895 15d4 66837DEC 		cmpw	$0, -20(%rbp)
 2895      00
 2896 15d9 7E0D     		jle	.L139
 2898              	.LM440:
 2899 15db 0FBF45EE 		movswl	-18(%rbp), %eax
 2900 15df 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2902              	.LM441:
 2903 15e3 99       		cltd
 2904 15e4 F7F9     		idivl	%ecx
 2905 15e6 EB15     		jmp	.L140
 2906              	.L139:
 2908              	.LM442:
 2909 15e8 480FBF55 		movswq	-20(%rbp), %rdx
 2909      EC
 2910 15ed 480FBF45 		movswq	-18(%rbp), %rax
 2910      EE
 2911 15f2 4889D6   		movq	%rdx, %rsi
 2912 15f5 4889C7   		movq	%rax, %rdi
 2913 15f8 E8000000 		call	SYSTEM_DIV@PLT
 2913      00
 2914              	.L140:
 2916              	.LM443:
 2917 15fd B90B0000 		movl	$11, %ecx
 2917      00
 2918 1602 488D1500 		leaq	.LC26(%rip), %rdx
 2918      000000
 2919 1609 BEFCFFFF 		movl	$-4, %esi
 2919      FF
 2920 160e 89C7     		movl	%eax, %edi
 2921 1610 E85AFAFF 		call	TestLanguage_TestValue
 2921      FF
 308:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -4, (CHAR*)"side(-
 2923              	.LM444:
 2924 1615 0FBF45EC 		movswl	-20(%rbp), %eax
 2925 1619 89C7     		movl	%eax, %edi
 2926 161b E897FBFF 		call	TestLanguage_side
 2926      FF
 2927 1620 480FBFD8 		movswq	%ax, %rbx
 2928 1624 0FBF45EE 		movswl	-18(%rbp), %eax
 2929 1628 89C7     		movl	%eax, %edi
 2930 162a E888FBFF 		call	TestLanguage_side
 2930      FF
 2931 162f 480FBFC0 		movswq	%ax, %rax
 2932 1633 4889DE   		movq	%rbx, %rsi
 2933 1636 4889C7   		movq	%rax, %rdi
 2934 1639 E8000000 		call	SYSTEM_DIV@PLT
 2934      00
 2936              	.LM445:
 2937 163e B9150000 		movl	$21, %ecx
 2937      00
 2938 1643 488D1500 		leaq	.LC27(%rip), %rdx
 2938      000000
 2939 164a BEFCFFFF 		movl	$-4, %esi
 2939      FF
 2940 164f 89C7     		movl	%eax, %edi
 2941 1651 E819FAFF 		call	TestLanguage_TestValue
 2941      FF
 309:TestLanguage.c **** 	j = -2;
 2943              	.LM446:
 2944 1656 66C745EC 		movw	$-2, -20(%rbp)
 2944      FEFF
 310:TestLanguage.c **** 	i = 4;
 2946              	.LM447:
 2947 165c 66C745EE 		movw	$4, -18(%rbp)
 2947      0400
 311:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -2, (CHAR*)"4 DIV (-2)", 11);
 2949              	.LM448:
 2950 1662 66837DEE 		cmpw	$0, -18(%rbp)
 2950      00
 2951 1667 7E14     		jle	.L141
 2953              	.LM449:
 2954 1669 66837DEC 		cmpw	$0, -20(%rbp)
 2954      00
 2955 166e 7E0D     		jle	.L141
 2957              	.LM450:
 2958 1670 0FBF45EE 		movswl	-18(%rbp), %eax
 2959 1674 0FBF4DEC 		movswl	-20(%rbp), %ecx
 2961              	.LM451:
 2962 1678 99       		cltd
 2963 1679 F7F9     		idivl	%ecx
 2964 167b EB15     		jmp	.L142
 2965              	.L141:
 2967              	.LM452:
 2968 167d 480FBF55 		movswq	-20(%rbp), %rdx
 2968      EC
 2969 1682 480FBF45 		movswq	-18(%rbp), %rax
 2969      EE
 2970 1687 4889D6   		movq	%rdx, %rsi
 2971 168a 4889C7   		movq	%rax, %rdi
 2972 168d E8000000 		call	SYSTEM_DIV@PLT
 2972      00
 2973              	.L142:
 2975              	.LM453:
 2976 1692 B90B0000 		movl	$11, %ecx
 2976      00
 2977 1697 488D1500 		leaq	.LC28(%rip), %rdx
 2977      000000
 2978 169e BEFEFFFF 		movl	$-2, %esi
 2978      FF
 2979 16a3 89C7     		movl	%eax, %edi
 2980 16a5 E8C5F9FF 		call	TestLanguage_TestValue
 2980      FF
 312:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -2, (CHAR*)"side(4
 2982              	.LM454:
 2983 16aa 0FBF45EC 		movswl	-20(%rbp), %eax
 2984 16ae 89C7     		movl	%eax, %edi
 2985 16b0 E802FBFF 		call	TestLanguage_side
 2985      FF
 2986 16b5 480FBFD8 		movswq	%ax, %rbx
 2987 16b9 0FBF45EE 		movswl	-18(%rbp), %eax
 2988 16bd 89C7     		movl	%eax, %edi
 2989 16bf E8F3FAFF 		call	TestLanguage_side
 2989      FF
 2990 16c4 480FBFC0 		movswq	%ax, %rax
 2991 16c8 4889DE   		movq	%rbx, %rsi
 2992 16cb 4889C7   		movq	%rax, %rdi
 2993 16ce E8000000 		call	SYSTEM_DIV@PLT
 2993      00
 2995              	.LM455:
 2996 16d3 B9150000 		movl	$21, %ecx
 2996      00
 2997 16d8 488D1500 		leaq	.LC29(%rip), %rdx
 2997      000000
 2998 16df BEFEFFFF 		movl	$-2, %esi
 2998      FF
 2999 16e4 89C7     		movl	%eax, %edi
 3000 16e6 E884F9FF 		call	TestLanguage_TestValue
 3000      FF
 313:TestLanguage.c **** 	i = 5;
 3002              	.LM456:
 3003 16eb 66C745EE 		movw	$5, -18(%rbp)
 3003      0500
 314:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"5 DIV (-2)", 11);
 3005              	.LM457:
 3006 16f1 66837DEE 		cmpw	$0, -18(%rbp)
 3006      00
 3007 16f6 7E14     		jle	.L143
 3009              	.LM458:
 3010 16f8 66837DEC 		cmpw	$0, -20(%rbp)
 3010      00
 3011 16fd 7E0D     		jle	.L143
 3013              	.LM459:
 3014 16ff 0FBF45EE 		movswl	-18(%rbp), %eax
 3015 1703 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3017              	.LM460:
 3018 1707 99       		cltd
 3019 1708 F7F9     		idivl	%ecx
 3020 170a EB15     		jmp	.L144
 3021              	.L143:
 3023              	.LM461:
 3024 170c 480FBF55 		movswq	-20(%rbp), %rdx
 3024      EC
 3025 1711 480FBF45 		movswq	-18(%rbp), %rax
 3025      EE
 3026 1716 4889D6   		movq	%rdx, %rsi
 3027 1719 4889C7   		movq	%rax, %rdi
 3028 171c E8000000 		call	SYSTEM_DIV@PLT
 3028      00
 3029              	.L144:
 3031              	.LM462:
 3032 1721 B90B0000 		movl	$11, %ecx
 3032      00
 3033 1726 488D1500 		leaq	.LC30(%rip), %rdx
 3033      000000
 3034 172d BEFDFFFF 		movl	$-3, %esi
 3034      FF
 3035 1732 89C7     		movl	%eax, %edi
 3036 1734 E836F9FF 		call	TestLanguage_TestValue
 3036      FF
 315:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(5
 3038              	.LM463:
 3039 1739 0FBF45EC 		movswl	-20(%rbp), %eax
 3040 173d 89C7     		movl	%eax, %edi
 3041 173f E873FAFF 		call	TestLanguage_side
 3041      FF
 3042 1744 480FBFD8 		movswq	%ax, %rbx
 3043 1748 0FBF45EE 		movswl	-18(%rbp), %eax
 3044 174c 89C7     		movl	%eax, %edi
 3045 174e E864FAFF 		call	TestLanguage_side
 3045      FF
 3046 1753 480FBFC0 		movswq	%ax, %rax
 3047 1757 4889DE   		movq	%rbx, %rsi
 3048 175a 4889C7   		movq	%rax, %rdi
 3049 175d E8000000 		call	SYSTEM_DIV@PLT
 3049      00
 3051              	.LM464:
 3052 1762 B9150000 		movl	$21, %ecx
 3052      00
 3053 1767 488D1500 		leaq	.LC31(%rip), %rdx
 3053      000000
 3054 176e BEFDFFFF 		movl	$-3, %esi
 3054      FF
 3055 1773 89C7     		movl	%eax, %edi
 3056 1775 E8F5F8FF 		call	TestLanguage_TestValue
 3056      FF
 316:TestLanguage.c **** 	i = 6;
 3058              	.LM465:
 3059 177a 66C745EE 		movw	$6, -18(%rbp)
 3059      0600
 317:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -3, (CHAR*)"6 DIV (-2)", 11);
 3061              	.LM466:
 3062 1780 66837DEE 		cmpw	$0, -18(%rbp)
 3062      00
 3063 1785 7E14     		jle	.L145
 3065              	.LM467:
 3066 1787 66837DEC 		cmpw	$0, -20(%rbp)
 3066      00
 3067 178c 7E0D     		jle	.L145
 3069              	.LM468:
 3070 178e 0FBF45EE 		movswl	-18(%rbp), %eax
 3071 1792 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3073              	.LM469:
 3074 1796 99       		cltd
 3075 1797 F7F9     		idivl	%ecx
 3076 1799 EB15     		jmp	.L146
 3077              	.L145:
 3079              	.LM470:
 3080 179b 480FBF55 		movswq	-20(%rbp), %rdx
 3080      EC
 3081 17a0 480FBF45 		movswq	-18(%rbp), %rax
 3081      EE
 3082 17a5 4889D6   		movq	%rdx, %rsi
 3083 17a8 4889C7   		movq	%rax, %rdi
 3084 17ab E8000000 		call	SYSTEM_DIV@PLT
 3084      00
 3085              	.L146:
 3087              	.LM471:
 3088 17b0 B90B0000 		movl	$11, %ecx
 3088      00
 3089 17b5 488D1500 		leaq	.LC32(%rip), %rdx
 3089      000000
 3090 17bc BEFDFFFF 		movl	$-3, %esi
 3090      FF
 3091 17c1 89C7     		movl	%eax, %edi
 3092 17c3 E8A7F8FF 		call	TestLanguage_TestValue
 3092      FF
 318:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -3, (CHAR*)"side(6
 3094              	.LM472:
 3095 17c8 0FBF45EC 		movswl	-20(%rbp), %eax
 3096 17cc 89C7     		movl	%eax, %edi
 3097 17ce E8E4F9FF 		call	TestLanguage_side
 3097      FF
 3098 17d3 480FBFD8 		movswq	%ax, %rbx
 3099 17d7 0FBF45EE 		movswl	-18(%rbp), %eax
 3100 17db 89C7     		movl	%eax, %edi
 3101 17dd E8D5F9FF 		call	TestLanguage_side
 3101      FF
 3102 17e2 480FBFC0 		movswq	%ax, %rax
 3103 17e6 4889DE   		movq	%rbx, %rsi
 3104 17e9 4889C7   		movq	%rax, %rdi
 3105 17ec E8000000 		call	SYSTEM_DIV@PLT
 3105      00
 3107              	.LM473:
 3108 17f1 B9150000 		movl	$21, %ecx
 3108      00
 3109 17f6 488D1500 		leaq	.LC33(%rip), %rdx
 3109      000000
 3110 17fd BEFDFFFF 		movl	$-3, %esi
 3110      FF
 3111 1802 89C7     		movl	%eax, %edi
 3112 1804 E866F8FF 		call	TestLanguage_TestValue
 3112      FF
 319:TestLanguage.c **** 	i = 7;
 3114              	.LM474:
 3115 1809 66C745EE 		movw	$7, -18(%rbp)
 3115      0700
 320:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), -4, (CHAR*)"7 DIV (-2)", 11);
 3117              	.LM475:
 3118 180f 66837DEE 		cmpw	$0, -18(%rbp)
 3118      00
 3119 1814 7E14     		jle	.L147
 3121              	.LM476:
 3122 1816 66837DEC 		cmpw	$0, -20(%rbp)
 3122      00
 3123 181b 7E0D     		jle	.L147
 3125              	.LM477:
 3126 181d 0FBF45EE 		movswl	-18(%rbp), %eax
 3127 1821 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3129              	.LM478:
 3130 1825 99       		cltd
 3131 1826 F7F9     		idivl	%ecx
 3132 1828 EB15     		jmp	.L148
 3133              	.L147:
 3135              	.LM479:
 3136 182a 480FBF55 		movswq	-20(%rbp), %rdx
 3136      EC
 3137 182f 480FBF45 		movswq	-18(%rbp), %rax
 3137      EE
 3138 1834 4889D6   		movq	%rdx, %rsi
 3139 1837 4889C7   		movq	%rax, %rdi
 3140 183a E8000000 		call	SYSTEM_DIV@PLT
 3140      00
 3141              	.L148:
 3143              	.LM480:
 3144 183f B90B0000 		movl	$11, %ecx
 3144      00
 3145 1844 488D1500 		leaq	.LC34(%rip), %rdx
 3145      000000
 3146 184b BEFCFFFF 		movl	$-4, %esi
 3146      FF
 3147 1850 89C7     		movl	%eax, %edi
 3148 1852 E818F8FF 		call	TestLanguage_TestValue
 3148      FF
 321:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), -4, (CHAR*)"side(7
 3150              	.LM481:
 3151 1857 0FBF45EC 		movswl	-20(%rbp), %eax
 3152 185b 89C7     		movl	%eax, %edi
 3153 185d E855F9FF 		call	TestLanguage_side
 3153      FF
 3154 1862 480FBFD8 		movswq	%ax, %rbx
 3155 1866 0FBF45EE 		movswl	-18(%rbp), %eax
 3156 186a 89C7     		movl	%eax, %edi
 3157 186c E846F9FF 		call	TestLanguage_side
 3157      FF
 3158 1871 480FBFC0 		movswq	%ax, %rax
 3159 1875 4889DE   		movq	%rbx, %rsi
 3160 1878 4889C7   		movq	%rax, %rdi
 3161 187b E8000000 		call	SYSTEM_DIV@PLT
 3161      00
 3163              	.LM482:
 3164 1880 B9150000 		movl	$21, %ecx
 3164      00
 3165 1885 488D1500 		leaq	.LC35(%rip), %rdx
 3165      000000
 3166 188c BEFCFFFF 		movl	$-4, %esi
 3166      FF
 3167 1891 89C7     		movl	%eax, %edi
 3168 1893 E8D7F7FF 		call	TestLanguage_TestValue
 3168      FF
 322:TestLanguage.c **** 	i = -4;
 3170              	.LM483:
 3171 1898 66C745EE 		movw	$-4, -18(%rbp)
 3171      FCFF
 323:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"(-4) DIV (-2)", 14);
 3173              	.LM484:
 3174 189e 66837DEE 		cmpw	$0, -18(%rbp)
 3174      00
 3175 18a3 7E14     		jle	.L149
 3177              	.LM485:
 3178 18a5 66837DEC 		cmpw	$0, -20(%rbp)
 3178      00
 3179 18aa 7E0D     		jle	.L149
 3181              	.LM486:
 3182 18ac 0FBF45EE 		movswl	-18(%rbp), %eax
 3183 18b0 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3185              	.LM487:
 3186 18b4 99       		cltd
 3187 18b5 F7F9     		idivl	%ecx
 3188 18b7 EB15     		jmp	.L150
 3189              	.L149:
 3191              	.LM488:
 3192 18b9 480FBF55 		movswq	-20(%rbp), %rdx
 3192      EC
 3193 18be 480FBF45 		movswq	-18(%rbp), %rax
 3193      EE
 3194 18c3 4889D6   		movq	%rdx, %rsi
 3195 18c6 4889C7   		movq	%rax, %rdi
 3196 18c9 E8000000 		call	SYSTEM_DIV@PLT
 3196      00
 3197              	.L150:
 3199              	.LM489:
 3200 18ce B90E0000 		movl	$14, %ecx
 3200      00
 3201 18d3 488D1500 		leaq	.LC36(%rip), %rdx
 3201      000000
 3202 18da BE020000 		movl	$2, %esi
 3202      00
 3203 18df 89C7     		movl	%eax, %edi
 3204 18e1 E889F7FF 		call	TestLanguage_TestValue
 3204      FF
 324:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(-4
 3206              	.LM490:
 3207 18e6 0FBF45EC 		movswl	-20(%rbp), %eax
 3208 18ea 89C7     		movl	%eax, %edi
 3209 18ec E8C6F8FF 		call	TestLanguage_side
 3209      FF
 3210 18f1 480FBFD8 		movswq	%ax, %rbx
 3211 18f5 0FBF45EE 		movswl	-18(%rbp), %eax
 3212 18f9 89C7     		movl	%eax, %edi
 3213 18fb E8B7F8FF 		call	TestLanguage_side
 3213      FF
 3214 1900 480FBFC0 		movswq	%ax, %rax
 3215 1904 4889DE   		movq	%rbx, %rsi
 3216 1907 4889C7   		movq	%rax, %rdi
 3217 190a E8000000 		call	SYSTEM_DIV@PLT
 3217      00
 3219              	.LM491:
 3220 190f B9160000 		movl	$22, %ecx
 3220      00
 3221 1914 488D1500 		leaq	.LC37(%rip), %rdx
 3221      000000
 3222 191b BE020000 		movl	$2, %esi
 3222      00
 3223 1920 89C7     		movl	%eax, %edi
 3224 1922 E848F7FF 		call	TestLanguage_TestValue
 3224      FF
 325:TestLanguage.c **** 	i = -5;
 3226              	.LM492:
 3227 1927 66C745EE 		movw	$-5, -18(%rbp)
 3227      FBFF
 326:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 2, (CHAR*)"(-5) DIV (-2)", 14);
 3229              	.LM493:
 3230 192d 66837DEE 		cmpw	$0, -18(%rbp)
 3230      00
 3231 1932 7E14     		jle	.L151
 3233              	.LM494:
 3234 1934 66837DEC 		cmpw	$0, -20(%rbp)
 3234      00
 3235 1939 7E0D     		jle	.L151
 3237              	.LM495:
 3238 193b 0FBF45EE 		movswl	-18(%rbp), %eax
 3239 193f 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3241              	.LM496:
 3242 1943 99       		cltd
 3243 1944 F7F9     		idivl	%ecx
 3244 1946 EB15     		jmp	.L152
 3245              	.L151:
 3247              	.LM497:
 3248 1948 480FBF55 		movswq	-20(%rbp), %rdx
 3248      EC
 3249 194d 480FBF45 		movswq	-18(%rbp), %rax
 3249      EE
 3250 1952 4889D6   		movq	%rdx, %rsi
 3251 1955 4889C7   		movq	%rax, %rdi
 3252 1958 E8000000 		call	SYSTEM_DIV@PLT
 3252      00
 3253              	.L152:
 3255              	.LM498:
 3256 195d B90E0000 		movl	$14, %ecx
 3256      00
 3257 1962 488D1500 		leaq	.LC38(%rip), %rdx
 3257      000000
 3258 1969 BE020000 		movl	$2, %esi
 3258      00
 3259 196e 89C7     		movl	%eax, %edi
 3260 1970 E8FAF6FF 		call	TestLanguage_TestValue
 3260      FF
 327:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 2, (CHAR*)"side(-5
 3262              	.LM499:
 3263 1975 0FBF45EC 		movswl	-20(%rbp), %eax
 3264 1979 89C7     		movl	%eax, %edi
 3265 197b E837F8FF 		call	TestLanguage_side
 3265      FF
 3266 1980 480FBFD8 		movswq	%ax, %rbx
 3267 1984 0FBF45EE 		movswl	-18(%rbp), %eax
 3268 1988 89C7     		movl	%eax, %edi
 3269 198a E828F8FF 		call	TestLanguage_side
 3269      FF
 3270 198f 480FBFC0 		movswq	%ax, %rax
 3271 1993 4889DE   		movq	%rbx, %rsi
 3272 1996 4889C7   		movq	%rax, %rdi
 3273 1999 E8000000 		call	SYSTEM_DIV@PLT
 3273      00
 3275              	.LM500:
 3276 199e B9160000 		movl	$22, %ecx
 3276      00
 3277 19a3 488D1500 		leaq	.LC39(%rip), %rdx
 3277      000000
 3278 19aa BE020000 		movl	$2, %esi
 3278      00
 3279 19af 89C7     		movl	%eax, %edi
 3280 19b1 E8B9F6FF 		call	TestLanguage_TestValue
 3280      FF
 328:TestLanguage.c **** 	i = -6;
 3282              	.LM501:
 3283 19b6 66C745EE 		movw	$-6, -18(%rbp)
 3283      FAFF
 329:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"(-6) DIV (-2)", 14);
 3285              	.LM502:
 3286 19bc 66837DEE 		cmpw	$0, -18(%rbp)
 3286      00
 3287 19c1 7E14     		jle	.L153
 3289              	.LM503:
 3290 19c3 66837DEC 		cmpw	$0, -20(%rbp)
 3290      00
 3291 19c8 7E0D     		jle	.L153
 3293              	.LM504:
 3294 19ca 0FBF45EE 		movswl	-18(%rbp), %eax
 3295 19ce 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3297              	.LM505:
 3298 19d2 99       		cltd
 3299 19d3 F7F9     		idivl	%ecx
 3300 19d5 EB15     		jmp	.L154
 3301              	.L153:
 3303              	.LM506:
 3304 19d7 480FBF55 		movswq	-20(%rbp), %rdx
 3304      EC
 3305 19dc 480FBF45 		movswq	-18(%rbp), %rax
 3305      EE
 3306 19e1 4889D6   		movq	%rdx, %rsi
 3307 19e4 4889C7   		movq	%rax, %rdi
 3308 19e7 E8000000 		call	SYSTEM_DIV@PLT
 3308      00
 3309              	.L154:
 3311              	.LM507:
 3312 19ec B90E0000 		movl	$14, %ecx
 3312      00
 3313 19f1 488D1500 		leaq	.LC40(%rip), %rdx
 3313      000000
 3314 19f8 BE030000 		movl	$3, %esi
 3314      00
 3315 19fd 89C7     		movl	%eax, %edi
 3316 19ff E86BF6FF 		call	TestLanguage_TestValue
 3316      FF
 330:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(-6
 3318              	.LM508:
 3319 1a04 0FBF45EC 		movswl	-20(%rbp), %eax
 3320 1a08 89C7     		movl	%eax, %edi
 3321 1a0a E8A8F7FF 		call	TestLanguage_side
 3321      FF
 3322 1a0f 480FBFD8 		movswq	%ax, %rbx
 3323 1a13 0FBF45EE 		movswl	-18(%rbp), %eax
 3324 1a17 89C7     		movl	%eax, %edi
 3325 1a19 E899F7FF 		call	TestLanguage_side
 3325      FF
 3326 1a1e 480FBFC0 		movswq	%ax, %rax
 3327 1a22 4889DE   		movq	%rbx, %rsi
 3328 1a25 4889C7   		movq	%rax, %rdi
 3329 1a28 E8000000 		call	SYSTEM_DIV@PLT
 3329      00
 3331              	.LM509:
 3332 1a2d B9160000 		movl	$22, %ecx
 3332      00
 3333 1a32 488D1500 		leaq	.LC41(%rip), %rdx
 3333      000000
 3334 1a39 BE030000 		movl	$3, %esi
 3334      00
 3335 1a3e 89C7     		movl	%eax, %edi
 3336 1a40 E82AF6FF 		call	TestLanguage_TestValue
 3336      FF
 331:TestLanguage.c **** 	i = -7;
 3338              	.LM510:
 3339 1a45 66C745EE 		movw	$-7, -18(%rbp)
 3339      F9FF
 332:TestLanguage.c **** 	TestLanguage_TestValue(__DIV(i, j), 3, (CHAR*)"(-7) DIV (-2)", 14);
 3341              	.LM511:
 3342 1a4b 66837DEE 		cmpw	$0, -18(%rbp)
 3342      00
 3343 1a50 7E14     		jle	.L155
 3345              	.LM512:
 3346 1a52 66837DEC 		cmpw	$0, -20(%rbp)
 3346      00
 3347 1a57 7E0D     		jle	.L155
 3349              	.LM513:
 3350 1a59 0FBF45EE 		movswl	-18(%rbp), %eax
 3351 1a5d 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3353              	.LM514:
 3354 1a61 99       		cltd
 3355 1a62 F7F9     		idivl	%ecx
 3356 1a64 EB15     		jmp	.L156
 3357              	.L155:
 3359              	.LM515:
 3360 1a66 480FBF55 		movswq	-20(%rbp), %rdx
 3360      EC
 3361 1a6b 480FBF45 		movswq	-18(%rbp), %rax
 3361      EE
 3362 1a70 4889D6   		movq	%rdx, %rsi
 3363 1a73 4889C7   		movq	%rax, %rdi
 3364 1a76 E8000000 		call	SYSTEM_DIV@PLT
 3364      00
 3365              	.L156:
 3367              	.LM516:
 3368 1a7b B90E0000 		movl	$14, %ecx
 3368      00
 3369 1a80 488D1500 		leaq	.LC42(%rip), %rdx
 3369      000000
 3370 1a87 BE030000 		movl	$3, %esi
 3370      00
 3371 1a8c 89C7     		movl	%eax, %edi
 3372 1a8e E8DCF5FF 		call	TestLanguage_TestValue
 3372      FF
 333:TestLanguage.c **** 	TestLanguage_TestValue((int)__DIVF(TestLanguage_side(i), TestLanguage_side(j)), 3, (CHAR*)"side(-7
 3374              	.LM517:
 3375 1a93 0FBF45EC 		movswl	-20(%rbp), %eax
 3376 1a97 89C7     		movl	%eax, %edi
 3377 1a99 E819F7FF 		call	TestLanguage_side
 3377      FF
 3378 1a9e 480FBFD8 		movswq	%ax, %rbx
 3379 1aa2 0FBF45EE 		movswl	-18(%rbp), %eax
 3380 1aa6 89C7     		movl	%eax, %edi
 3381 1aa8 E80AF7FF 		call	TestLanguage_side
 3381      FF
 3382 1aad 480FBFC0 		movswq	%ax, %rax
 3383 1ab1 4889DE   		movq	%rbx, %rsi
 3384 1ab4 4889C7   		movq	%rax, %rdi
 3385 1ab7 E8000000 		call	SYSTEM_DIV@PLT
 3385      00
 3387              	.LM518:
 3388 1abc B9160000 		movl	$22, %ecx
 3388      00
 3389 1ac1 488D1500 		leaq	.LC43(%rip), %rdx
 3389      000000
 3390 1ac8 BE030000 		movl	$3, %esi
 3390      00
 3391 1acd 89C7     		movl	%eax, %edi
 3392 1acf E89BF5FF 		call	TestLanguage_TestValue
 3392      FF
 334:TestLanguage.c **** 	i = 4;
 3394              	.LM519:
 3395 1ad4 66C745EE 		movw	$4, -18(%rbp)
 3395      0400
 335:TestLanguage.c **** 	j = 3;
 3397              	.LM520:
 3398 1ada 66C745EC 		movw	$3, -20(%rbp)
 3398      0300
 336:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"4 MOD 3", 8);
 3400              	.LM521:
 3401 1ae0 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3402 1ae4 66837DEE 		cmpw	$0, -18(%rbp)
 3402      00
 3403 1ae9 7E16     		jle	.L157
 3405              	.LM522:
 3406 1aeb 66837DEC 		cmpw	$0, -20(%rbp)
 3406      00
 3407 1af0 7E0F     		jle	.L157
 3409              	.LM523:
 3410 1af2 0FBF45EE 		movswl	-18(%rbp), %eax
 3411 1af6 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3412 1afa 99       		cltd
 3413 1afb F7F9     		idivl	%ecx
 3415              	.LM524:
 3416 1afd 89C2     		movl	%eax, %edx
 3417 1aff EB17     		jmp	.L158
 3418              	.L157:
 3420              	.LM525:
 3421 1b01 480FBF55 		movswq	-20(%rbp), %rdx
 3421      EC
 3422 1b06 480FBF45 		movswq	-18(%rbp), %rax
 3422      EE
 3423 1b0b 4889D6   		movq	%rdx, %rsi
 3424 1b0e 4889C7   		movq	%rax, %rdi
 3425 1b11 E8000000 		call	SYSTEM_DIV@PLT
 3425      00
 3427              	.LM526:
 3428 1b16 89C2     		movl	%eax, %edx
 3429              	.L158:
 3431              	.LM527:
 3432 1b18 0FBF45EC 		movswl	-20(%rbp), %eax
 3433 1b1c 0FAFC2   		imull	%edx, %eax
 3434 1b1f 29C3     		subl	%eax, %ebx
 3435 1b21 89D8     		movl	%ebx, %eax
 3437              	.LM528:
 3438 1b23 89C3     		movl	%eax, %ebx
 3439 1b25 66837DEE 		cmpw	$0, -18(%rbp)
 3439      00
 3440 1b2a 7E16     		jle	.L159
 3442              	.LM529:
 3443 1b2c 66837DEC 		cmpw	$0, -20(%rbp)
 3443      00
 3444 1b31 7E0F     		jle	.L159
 3446              	.LM530:
 3447 1b33 0FBF45EE 		movswl	-18(%rbp), %eax
 3448 1b37 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3450              	.LM531:
 3451 1b3b 99       		cltd
 3452 1b3c F7F9     		idivl	%ecx
 3453 1b3e 89D0     		movl	%edx, %eax
 3454 1b40 EB15     		jmp	.L160
 3455              	.L159:
 3457              	.LM532:
 3458 1b42 480FBF55 		movswq	-20(%rbp), %rdx
 3458      EC
 3459 1b47 480FBF45 		movswq	-18(%rbp), %rax
 3459      EE
 3460 1b4c 4889D6   		movq	%rdx, %rsi
 3461 1b4f 4889C7   		movq	%rax, %rdi
 3462 1b52 E8000000 		call	SYSTEM_MOD@PLT
 3462      00
 3463              	.L160:
 3465              	.LM533:
 3466 1b57 B9080000 		movl	$8, %ecx
 3466      00
 3467 1b5c 488D1500 		leaq	.LC44(%rip), %rdx
 3467      000000
 3468 1b63 89DE     		movl	%ebx, %esi
 3469 1b65 89C7     		movl	%eax, %edi
 3470 1b67 E803F5FF 		call	TestLanguage_TestValue
 3470      FF
 337:TestLanguage.c **** 	i = 5;
 3472              	.LM534:
 3473 1b6c 66C745EE 		movw	$5, -18(%rbp)
 3473      0500
 338:TestLanguage.c **** 	j = 3;
 3475              	.LM535:
 3476 1b72 66C745EC 		movw	$3, -20(%rbp)
 3476      0300
 339:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"5 MOD 3", 8);
 3478              	.LM536:
 3479 1b78 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3480 1b7c 66837DEE 		cmpw	$0, -18(%rbp)
 3480      00
 3481 1b81 7E16     		jle	.L161
 3483              	.LM537:
 3484 1b83 66837DEC 		cmpw	$0, -20(%rbp)
 3484      00
 3485 1b88 7E0F     		jle	.L161
 3487              	.LM538:
 3488 1b8a 0FBF45EE 		movswl	-18(%rbp), %eax
 3489 1b8e 0FBF75EC 		movswl	-20(%rbp), %esi
 3490 1b92 99       		cltd
 3491 1b93 F7FE     		idivl	%esi
 3493              	.LM539:
 3494 1b95 89C2     		movl	%eax, %edx
 3495 1b97 EB17     		jmp	.L162
 3496              	.L161:
 3498              	.LM540:
 3499 1b99 480FBF55 		movswq	-20(%rbp), %rdx
 3499      EC
 3500 1b9e 480FBF45 		movswq	-18(%rbp), %rax
 3500      EE
 3501 1ba3 4889D6   		movq	%rdx, %rsi
 3502 1ba6 4889C7   		movq	%rax, %rdi
 3503 1ba9 E8000000 		call	SYSTEM_DIV@PLT
 3503      00
 3505              	.LM541:
 3506 1bae 89C2     		movl	%eax, %edx
 3507              	.L162:
 3509              	.LM542:
 3510 1bb0 0FBF45EC 		movswl	-20(%rbp), %eax
 3511 1bb4 0FAFC2   		imull	%edx, %eax
 3512 1bb7 29C3     		subl	%eax, %ebx
 3513 1bb9 89D8     		movl	%ebx, %eax
 3515              	.LM543:
 3516 1bbb 89C3     		movl	%eax, %ebx
 3517 1bbd 66837DEE 		cmpw	$0, -18(%rbp)
 3517      00
 3518 1bc2 7E16     		jle	.L163
 3520              	.LM544:
 3521 1bc4 66837DEC 		cmpw	$0, -20(%rbp)
 3521      00
 3522 1bc9 7E0F     		jle	.L163
 3524              	.LM545:
 3525 1bcb 0FBF45EE 		movswl	-18(%rbp), %eax
 3526 1bcf 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3528              	.LM546:
 3529 1bd3 99       		cltd
 3530 1bd4 F7F9     		idivl	%ecx
 3531 1bd6 89D0     		movl	%edx, %eax
 3532 1bd8 EB15     		jmp	.L164
 3533              	.L163:
 3535              	.LM547:
 3536 1bda 480FBF55 		movswq	-20(%rbp), %rdx
 3536      EC
 3537 1bdf 480FBF45 		movswq	-18(%rbp), %rax
 3537      EE
 3538 1be4 4889D6   		movq	%rdx, %rsi
 3539 1be7 4889C7   		movq	%rax, %rdi
 3540 1bea E8000000 		call	SYSTEM_MOD@PLT
 3540      00
 3541              	.L164:
 3543              	.LM548:
 3544 1bef B9080000 		movl	$8, %ecx
 3544      00
 3545 1bf4 488D1500 		leaq	.LC45(%rip), %rdx
 3545      000000
 3546 1bfb 89DE     		movl	%ebx, %esi
 3547 1bfd 89C7     		movl	%eax, %edi
 3548 1bff E86BF4FF 		call	TestLanguage_TestValue
 3548      FF
 340:TestLanguage.c **** 	i = 6;
 3550              	.LM549:
 3551 1c04 66C745EE 		movw	$6, -18(%rbp)
 3551      0600
 341:TestLanguage.c **** 	j = 3;
 3553              	.LM550:
 3554 1c0a 66C745EC 		movw	$3, -20(%rbp)
 3554      0300
 342:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"6 MOD 3", 8);
 3556              	.LM551:
 3557 1c10 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3558 1c14 66837DEE 		cmpw	$0, -18(%rbp)
 3558      00
 3559 1c19 7E16     		jle	.L165
 3561              	.LM552:
 3562 1c1b 66837DEC 		cmpw	$0, -20(%rbp)
 3562      00
 3563 1c20 7E0F     		jle	.L165
 3565              	.LM553:
 3566 1c22 0FBF45EE 		movswl	-18(%rbp), %eax
 3567 1c26 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3568 1c2a 99       		cltd
 3569 1c2b F7F9     		idivl	%ecx
 3571              	.LM554:
 3572 1c2d 89C2     		movl	%eax, %edx
 3573 1c2f EB17     		jmp	.L166
 3574              	.L165:
 3576              	.LM555:
 3577 1c31 480FBF55 		movswq	-20(%rbp), %rdx
 3577      EC
 3578 1c36 480FBF45 		movswq	-18(%rbp), %rax
 3578      EE
 3579 1c3b 4889D6   		movq	%rdx, %rsi
 3580 1c3e 4889C7   		movq	%rax, %rdi
 3581 1c41 E8000000 		call	SYSTEM_DIV@PLT
 3581      00
 3583              	.LM556:
 3584 1c46 89C2     		movl	%eax, %edx
 3585              	.L166:
 3587              	.LM557:
 3588 1c48 0FBF45EC 		movswl	-20(%rbp), %eax
 3589 1c4c 0FAFC2   		imull	%edx, %eax
 3590 1c4f 29C3     		subl	%eax, %ebx
 3591 1c51 89D8     		movl	%ebx, %eax
 3593              	.LM558:
 3594 1c53 89C3     		movl	%eax, %ebx
 3595 1c55 66837DEE 		cmpw	$0, -18(%rbp)
 3595      00
 3596 1c5a 7E16     		jle	.L167
 3598              	.LM559:
 3599 1c5c 66837DEC 		cmpw	$0, -20(%rbp)
 3599      00
 3600 1c61 7E0F     		jle	.L167
 3602              	.LM560:
 3603 1c63 0FBF45EE 		movswl	-18(%rbp), %eax
 3604 1c67 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3606              	.LM561:
 3607 1c6b 99       		cltd
 3608 1c6c F7F9     		idivl	%ecx
 3609 1c6e 89D0     		movl	%edx, %eax
 3610 1c70 EB15     		jmp	.L168
 3611              	.L167:
 3613              	.LM562:
 3614 1c72 480FBF55 		movswq	-20(%rbp), %rdx
 3614      EC
 3615 1c77 480FBF45 		movswq	-18(%rbp), %rax
 3615      EE
 3616 1c7c 4889D6   		movq	%rdx, %rsi
 3617 1c7f 4889C7   		movq	%rax, %rdi
 3618 1c82 E8000000 		call	SYSTEM_MOD@PLT
 3618      00
 3619              	.L168:
 3621              	.LM563:
 3622 1c87 B9080000 		movl	$8, %ecx
 3622      00
 3623 1c8c 488D1500 		leaq	.LC46(%rip), %rdx
 3623      000000
 3624 1c93 89DE     		movl	%ebx, %esi
 3625 1c95 89C7     		movl	%eax, %edi
 3626 1c97 E8D3F3FF 		call	TestLanguage_TestValue
 3626      FF
 343:TestLanguage.c **** 	i = 7;
 3628              	.LM564:
 3629 1c9c 66C745EE 		movw	$7, -18(%rbp)
 3629      0700
 344:TestLanguage.c **** 	j = 3;
 3631              	.LM565:
 3632 1ca2 66C745EC 		movw	$3, -20(%rbp)
 3632      0300
 345:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"7 MOD 3", 8);
 3634              	.LM566:
 3635 1ca8 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3636 1cac 66837DEE 		cmpw	$0, -18(%rbp)
 3636      00
 3637 1cb1 7E16     		jle	.L169
 3639              	.LM567:
 3640 1cb3 66837DEC 		cmpw	$0, -20(%rbp)
 3640      00
 3641 1cb8 7E0F     		jle	.L169
 3643              	.LM568:
 3644 1cba 0FBF45EE 		movswl	-18(%rbp), %eax
 3645 1cbe 0FBF75EC 		movswl	-20(%rbp), %esi
 3646 1cc2 99       		cltd
 3647 1cc3 F7FE     		idivl	%esi
 3649              	.LM569:
 3650 1cc5 89C2     		movl	%eax, %edx
 3651 1cc7 EB17     		jmp	.L170
 3652              	.L169:
 3654              	.LM570:
 3655 1cc9 480FBF55 		movswq	-20(%rbp), %rdx
 3655      EC
 3656 1cce 480FBF45 		movswq	-18(%rbp), %rax
 3656      EE
 3657 1cd3 4889D6   		movq	%rdx, %rsi
 3658 1cd6 4889C7   		movq	%rax, %rdi
 3659 1cd9 E8000000 		call	SYSTEM_DIV@PLT
 3659      00
 3661              	.LM571:
 3662 1cde 89C2     		movl	%eax, %edx
 3663              	.L170:
 3665              	.LM572:
 3666 1ce0 0FBF45EC 		movswl	-20(%rbp), %eax
 3667 1ce4 0FAFC2   		imull	%edx, %eax
 3668 1ce7 29C3     		subl	%eax, %ebx
 3669 1ce9 89D8     		movl	%ebx, %eax
 3671              	.LM573:
 3672 1ceb 89C3     		movl	%eax, %ebx
 3673 1ced 66837DEE 		cmpw	$0, -18(%rbp)
 3673      00
 3674 1cf2 7E16     		jle	.L171
 3676              	.LM574:
 3677 1cf4 66837DEC 		cmpw	$0, -20(%rbp)
 3677      00
 3678 1cf9 7E0F     		jle	.L171
 3680              	.LM575:
 3681 1cfb 0FBF45EE 		movswl	-18(%rbp), %eax
 3682 1cff 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3684              	.LM576:
 3685 1d03 99       		cltd
 3686 1d04 F7F9     		idivl	%ecx
 3687 1d06 89D0     		movl	%edx, %eax
 3688 1d08 EB15     		jmp	.L172
 3689              	.L171:
 3691              	.LM577:
 3692 1d0a 480FBF55 		movswq	-20(%rbp), %rdx
 3692      EC
 3693 1d0f 480FBF45 		movswq	-18(%rbp), %rax
 3693      EE
 3694 1d14 4889D6   		movq	%rdx, %rsi
 3695 1d17 4889C7   		movq	%rax, %rdi
 3696 1d1a E8000000 		call	SYSTEM_MOD@PLT
 3696      00
 3697              	.L172:
 3699              	.LM578:
 3700 1d1f B9080000 		movl	$8, %ecx
 3700      00
 3701 1d24 488D1500 		leaq	.LC47(%rip), %rdx
 3701      000000
 3702 1d2b 89DE     		movl	%ebx, %esi
 3703 1d2d 89C7     		movl	%eax, %edi
 3704 1d2f E83BF3FF 		call	TestLanguage_TestValue
 3704      FF
 346:TestLanguage.c **** 	i = -4;
 3706              	.LM579:
 3707 1d34 66C745EE 		movw	$-4, -18(%rbp)
 3707      FCFF
 347:TestLanguage.c **** 	j = 3;
 3709              	.LM580:
 3710 1d3a 66C745EC 		movw	$3, -20(%rbp)
 3710      0300
 348:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-4 MOD 3", 9);
 3712              	.LM581:
 3713 1d40 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3714 1d44 66837DEE 		cmpw	$0, -18(%rbp)
 3714      00
 3715 1d49 7E16     		jle	.L173
 3717              	.LM582:
 3718 1d4b 66837DEC 		cmpw	$0, -20(%rbp)
 3718      00
 3719 1d50 7E0F     		jle	.L173
 3721              	.LM583:
 3722 1d52 0FBF45EE 		movswl	-18(%rbp), %eax
 3723 1d56 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3724 1d5a 99       		cltd
 3725 1d5b F7F9     		idivl	%ecx
 3727              	.LM584:
 3728 1d5d 89C2     		movl	%eax, %edx
 3729 1d5f EB17     		jmp	.L174
 3730              	.L173:
 3732              	.LM585:
 3733 1d61 480FBF55 		movswq	-20(%rbp), %rdx
 3733      EC
 3734 1d66 480FBF45 		movswq	-18(%rbp), %rax
 3734      EE
 3735 1d6b 4889D6   		movq	%rdx, %rsi
 3736 1d6e 4889C7   		movq	%rax, %rdi
 3737 1d71 E8000000 		call	SYSTEM_DIV@PLT
 3737      00
 3739              	.LM586:
 3740 1d76 89C2     		movl	%eax, %edx
 3741              	.L174:
 3743              	.LM587:
 3744 1d78 0FBF45EC 		movswl	-20(%rbp), %eax
 3745 1d7c 0FAFC2   		imull	%edx, %eax
 3746 1d7f 29C3     		subl	%eax, %ebx
 3747 1d81 89D8     		movl	%ebx, %eax
 3749              	.LM588:
 3750 1d83 89C3     		movl	%eax, %ebx
 3751 1d85 66837DEE 		cmpw	$0, -18(%rbp)
 3751      00
 3752 1d8a 7E16     		jle	.L175
 3754              	.LM589:
 3755 1d8c 66837DEC 		cmpw	$0, -20(%rbp)
 3755      00
 3756 1d91 7E0F     		jle	.L175
 3758              	.LM590:
 3759 1d93 0FBF45EE 		movswl	-18(%rbp), %eax
 3760 1d97 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3762              	.LM591:
 3763 1d9b 99       		cltd
 3764 1d9c F7F9     		idivl	%ecx
 3765 1d9e 89D0     		movl	%edx, %eax
 3766 1da0 EB15     		jmp	.L176
 3767              	.L175:
 3769              	.LM592:
 3770 1da2 480FBF55 		movswq	-20(%rbp), %rdx
 3770      EC
 3771 1da7 480FBF45 		movswq	-18(%rbp), %rax
 3771      EE
 3772 1dac 4889D6   		movq	%rdx, %rsi
 3773 1daf 4889C7   		movq	%rax, %rdi
 3774 1db2 E8000000 		call	SYSTEM_MOD@PLT
 3774      00
 3775              	.L176:
 3777              	.LM593:
 3778 1db7 B9090000 		movl	$9, %ecx
 3778      00
 3779 1dbc 488D1500 		leaq	.LC48(%rip), %rdx
 3779      000000
 3780 1dc3 89DE     		movl	%ebx, %esi
 3781 1dc5 89C7     		movl	%eax, %edi
 3782 1dc7 E8A3F2FF 		call	TestLanguage_TestValue
 3782      FF
 349:TestLanguage.c **** 	i = -5;
 3784              	.LM594:
 3785 1dcc 66C745EE 		movw	$-5, -18(%rbp)
 3785      FBFF
 350:TestLanguage.c **** 	j = 3;
 3787              	.LM595:
 3788 1dd2 66C745EC 		movw	$3, -20(%rbp)
 3788      0300
 351:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-5 MOD 3", 9);
 3790              	.LM596:
 3791 1dd8 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3792 1ddc 66837DEE 		cmpw	$0, -18(%rbp)
 3792      00
 3793 1de1 7E16     		jle	.L177
 3795              	.LM597:
 3796 1de3 66837DEC 		cmpw	$0, -20(%rbp)
 3796      00
 3797 1de8 7E0F     		jle	.L177
 3799              	.LM598:
 3800 1dea 0FBF45EE 		movswl	-18(%rbp), %eax
 3801 1dee 0FBF75EC 		movswl	-20(%rbp), %esi
 3802 1df2 99       		cltd
 3803 1df3 F7FE     		idivl	%esi
 3805              	.LM599:
 3806 1df5 89C2     		movl	%eax, %edx
 3807 1df7 EB17     		jmp	.L178
 3808              	.L177:
 3810              	.LM600:
 3811 1df9 480FBF55 		movswq	-20(%rbp), %rdx
 3811      EC
 3812 1dfe 480FBF45 		movswq	-18(%rbp), %rax
 3812      EE
 3813 1e03 4889D6   		movq	%rdx, %rsi
 3814 1e06 4889C7   		movq	%rax, %rdi
 3815 1e09 E8000000 		call	SYSTEM_DIV@PLT
 3815      00
 3817              	.LM601:
 3818 1e0e 89C2     		movl	%eax, %edx
 3819              	.L178:
 3821              	.LM602:
 3822 1e10 0FBF45EC 		movswl	-20(%rbp), %eax
 3823 1e14 0FAFC2   		imull	%edx, %eax
 3824 1e17 29C3     		subl	%eax, %ebx
 3825 1e19 89D8     		movl	%ebx, %eax
 3827              	.LM603:
 3828 1e1b 89C3     		movl	%eax, %ebx
 3829 1e1d 66837DEE 		cmpw	$0, -18(%rbp)
 3829      00
 3830 1e22 7E16     		jle	.L179
 3832              	.LM604:
 3833 1e24 66837DEC 		cmpw	$0, -20(%rbp)
 3833      00
 3834 1e29 7E0F     		jle	.L179
 3836              	.LM605:
 3837 1e2b 0FBF45EE 		movswl	-18(%rbp), %eax
 3838 1e2f 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3840              	.LM606:
 3841 1e33 99       		cltd
 3842 1e34 F7F9     		idivl	%ecx
 3843 1e36 89D0     		movl	%edx, %eax
 3844 1e38 EB15     		jmp	.L180
 3845              	.L179:
 3847              	.LM607:
 3848 1e3a 480FBF55 		movswq	-20(%rbp), %rdx
 3848      EC
 3849 1e3f 480FBF45 		movswq	-18(%rbp), %rax
 3849      EE
 3850 1e44 4889D6   		movq	%rdx, %rsi
 3851 1e47 4889C7   		movq	%rax, %rdi
 3852 1e4a E8000000 		call	SYSTEM_MOD@PLT
 3852      00
 3853              	.L180:
 3855              	.LM608:
 3856 1e4f B9090000 		movl	$9, %ecx
 3856      00
 3857 1e54 488D1500 		leaq	.LC49(%rip), %rdx
 3857      000000
 3858 1e5b 89DE     		movl	%ebx, %esi
 3859 1e5d 89C7     		movl	%eax, %edi
 3860 1e5f E80BF2FF 		call	TestLanguage_TestValue
 3860      FF
 352:TestLanguage.c **** 	i = -6;
 3862              	.LM609:
 3863 1e64 66C745EE 		movw	$-6, -18(%rbp)
 3863      FAFF
 353:TestLanguage.c **** 	j = 3;
 3865              	.LM610:
 3866 1e6a 66C745EC 		movw	$3, -20(%rbp)
 3866      0300
 354:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-6 MOD 3", 9);
 3868              	.LM611:
 3869 1e70 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3870 1e74 66837DEE 		cmpw	$0, -18(%rbp)
 3870      00
 3871 1e79 7E16     		jle	.L181
 3873              	.LM612:
 3874 1e7b 66837DEC 		cmpw	$0, -20(%rbp)
 3874      00
 3875 1e80 7E0F     		jle	.L181
 3877              	.LM613:
 3878 1e82 0FBF45EE 		movswl	-18(%rbp), %eax
 3879 1e86 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3880 1e8a 99       		cltd
 3881 1e8b F7F9     		idivl	%ecx
 3883              	.LM614:
 3884 1e8d 89C2     		movl	%eax, %edx
 3885 1e8f EB17     		jmp	.L182
 3886              	.L181:
 3888              	.LM615:
 3889 1e91 480FBF55 		movswq	-20(%rbp), %rdx
 3889      EC
 3890 1e96 480FBF45 		movswq	-18(%rbp), %rax
 3890      EE
 3891 1e9b 4889D6   		movq	%rdx, %rsi
 3892 1e9e 4889C7   		movq	%rax, %rdi
 3893 1ea1 E8000000 		call	SYSTEM_DIV@PLT
 3893      00
 3895              	.LM616:
 3896 1ea6 89C2     		movl	%eax, %edx
 3897              	.L182:
 3899              	.LM617:
 3900 1ea8 0FBF45EC 		movswl	-20(%rbp), %eax
 3901 1eac 0FAFC2   		imull	%edx, %eax
 3902 1eaf 29C3     		subl	%eax, %ebx
 3903 1eb1 89D8     		movl	%ebx, %eax
 3905              	.LM618:
 3906 1eb3 89C3     		movl	%eax, %ebx
 3907 1eb5 66837DEE 		cmpw	$0, -18(%rbp)
 3907      00
 3908 1eba 7E16     		jle	.L183
 3910              	.LM619:
 3911 1ebc 66837DEC 		cmpw	$0, -20(%rbp)
 3911      00
 3912 1ec1 7E0F     		jle	.L183
 3914              	.LM620:
 3915 1ec3 0FBF45EE 		movswl	-18(%rbp), %eax
 3916 1ec7 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3918              	.LM621:
 3919 1ecb 99       		cltd
 3920 1ecc F7F9     		idivl	%ecx
 3921 1ece 89D0     		movl	%edx, %eax
 3922 1ed0 EB15     		jmp	.L184
 3923              	.L183:
 3925              	.LM622:
 3926 1ed2 480FBF55 		movswq	-20(%rbp), %rdx
 3926      EC
 3927 1ed7 480FBF45 		movswq	-18(%rbp), %rax
 3927      EE
 3928 1edc 4889D6   		movq	%rdx, %rsi
 3929 1edf 4889C7   		movq	%rax, %rdi
 3930 1ee2 E8000000 		call	SYSTEM_MOD@PLT
 3930      00
 3931              	.L184:
 3933              	.LM623:
 3934 1ee7 B9090000 		movl	$9, %ecx
 3934      00
 3935 1eec 488D1500 		leaq	.LC50(%rip), %rdx
 3935      000000
 3936 1ef3 89DE     		movl	%ebx, %esi
 3937 1ef5 89C7     		movl	%eax, %edi
 3938 1ef7 E873F1FF 		call	TestLanguage_TestValue
 3938      FF
 355:TestLanguage.c **** 	i = -7;
 3940              	.LM624:
 3941 1efc 66C745EE 		movw	$-7, -18(%rbp)
 3941      F9FF
 356:TestLanguage.c **** 	j = 3;
 3943              	.LM625:
 3944 1f02 66C745EC 		movw	$3, -20(%rbp)
 3944      0300
 357:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-7 MOD 3", 9);
 3946              	.LM626:
 3947 1f08 0FBF5DEE 		movswl	-18(%rbp), %ebx
 3948 1f0c 66837DEE 		cmpw	$0, -18(%rbp)
 3948      00
 3949 1f11 7E16     		jle	.L185
 3951              	.LM627:
 3952 1f13 66837DEC 		cmpw	$0, -20(%rbp)
 3952      00
 3953 1f18 7E0F     		jle	.L185
 3955              	.LM628:
 3956 1f1a 0FBF45EE 		movswl	-18(%rbp), %eax
 3957 1f1e 0FBF75EC 		movswl	-20(%rbp), %esi
 3958 1f22 99       		cltd
 3959 1f23 F7FE     		idivl	%esi
 3961              	.LM629:
 3962 1f25 89C2     		movl	%eax, %edx
 3963 1f27 EB17     		jmp	.L186
 3964              	.L185:
 3966              	.LM630:
 3967 1f29 480FBF55 		movswq	-20(%rbp), %rdx
 3967      EC
 3968 1f2e 480FBF45 		movswq	-18(%rbp), %rax
 3968      EE
 3969 1f33 4889D6   		movq	%rdx, %rsi
 3970 1f36 4889C7   		movq	%rax, %rdi
 3971 1f39 E8000000 		call	SYSTEM_DIV@PLT
 3971      00
 3973              	.LM631:
 3974 1f3e 89C2     		movl	%eax, %edx
 3975              	.L186:
 3977              	.LM632:
 3978 1f40 0FBF45EC 		movswl	-20(%rbp), %eax
 3979 1f44 0FAFC2   		imull	%edx, %eax
 3980 1f47 29C3     		subl	%eax, %ebx
 3981 1f49 89D8     		movl	%ebx, %eax
 3983              	.LM633:
 3984 1f4b 89C3     		movl	%eax, %ebx
 3985 1f4d 66837DEE 		cmpw	$0, -18(%rbp)
 3985      00
 3986 1f52 7E16     		jle	.L187
 3988              	.LM634:
 3989 1f54 66837DEC 		cmpw	$0, -20(%rbp)
 3989      00
 3990 1f59 7E0F     		jle	.L187
 3992              	.LM635:
 3993 1f5b 0FBF45EE 		movswl	-18(%rbp), %eax
 3994 1f5f 0FBF4DEC 		movswl	-20(%rbp), %ecx
 3996              	.LM636:
 3997 1f63 99       		cltd
 3998 1f64 F7F9     		idivl	%ecx
 3999 1f66 89D0     		movl	%edx, %eax
 4000 1f68 EB15     		jmp	.L188
 4001              	.L187:
 4003              	.LM637:
 4004 1f6a 480FBF55 		movswq	-20(%rbp), %rdx
 4004      EC
 4005 1f6f 480FBF45 		movswq	-18(%rbp), %rax
 4005      EE
 4006 1f74 4889D6   		movq	%rdx, %rsi
 4007 1f77 4889C7   		movq	%rax, %rdi
 4008 1f7a E8000000 		call	SYSTEM_MOD@PLT
 4008      00
 4009              	.L188:
 4011              	.LM638:
 4012 1f7f B9090000 		movl	$9, %ecx
 4012      00
 4013 1f84 488D1500 		leaq	.LC51(%rip), %rdx
 4013      000000
 4014 1f8b 89DE     		movl	%ebx, %esi
 4015 1f8d 89C7     		movl	%eax, %edi
 4016 1f8f E8DBF0FF 		call	TestLanguage_TestValue
 4016      FF
 358:TestLanguage.c **** 	i = 4;
 4018              	.LM639:
 4019 1f94 66C745EE 		movw	$4, -18(%rbp)
 4019      0400
 359:TestLanguage.c **** 	j = -3;
 4021              	.LM640:
 4022 1f9a 66C745EC 		movw	$-3, -20(%rbp)
 4022      FDFF
 360:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"4 MOD -3", 9);
 4024              	.LM641:
 4025 1fa0 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4026 1fa4 66837DEE 		cmpw	$0, -18(%rbp)
 4026      00
 4027 1fa9 7E16     		jle	.L189
 4029              	.LM642:
 4030 1fab 66837DEC 		cmpw	$0, -20(%rbp)
 4030      00
 4031 1fb0 7E0F     		jle	.L189
 4033              	.LM643:
 4034 1fb2 0FBF45EE 		movswl	-18(%rbp), %eax
 4035 1fb6 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4036 1fba 99       		cltd
 4037 1fbb F7F9     		idivl	%ecx
 4039              	.LM644:
 4040 1fbd 89C2     		movl	%eax, %edx
 4041 1fbf EB17     		jmp	.L190
 4042              	.L189:
 4044              	.LM645:
 4045 1fc1 480FBF55 		movswq	-20(%rbp), %rdx
 4045      EC
 4046 1fc6 480FBF45 		movswq	-18(%rbp), %rax
 4046      EE
 4047 1fcb 4889D6   		movq	%rdx, %rsi
 4048 1fce 4889C7   		movq	%rax, %rdi
 4049 1fd1 E8000000 		call	SYSTEM_DIV@PLT
 4049      00
 4051              	.LM646:
 4052 1fd6 89C2     		movl	%eax, %edx
 4053              	.L190:
 4055              	.LM647:
 4056 1fd8 0FBF45EC 		movswl	-20(%rbp), %eax
 4057 1fdc 0FAFC2   		imull	%edx, %eax
 4058 1fdf 29C3     		subl	%eax, %ebx
 4059 1fe1 89D8     		movl	%ebx, %eax
 4061              	.LM648:
 4062 1fe3 89C3     		movl	%eax, %ebx
 4063 1fe5 66837DEE 		cmpw	$0, -18(%rbp)
 4063      00
 4064 1fea 7E16     		jle	.L191
 4066              	.LM649:
 4067 1fec 66837DEC 		cmpw	$0, -20(%rbp)
 4067      00
 4068 1ff1 7E0F     		jle	.L191
 4070              	.LM650:
 4071 1ff3 0FBF45EE 		movswl	-18(%rbp), %eax
 4072 1ff7 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4074              	.LM651:
 4075 1ffb 99       		cltd
 4076 1ffc F7F9     		idivl	%ecx
 4077 1ffe 89D0     		movl	%edx, %eax
 4078 2000 EB15     		jmp	.L192
 4079              	.L191:
 4081              	.LM652:
 4082 2002 480FBF55 		movswq	-20(%rbp), %rdx
 4082      EC
 4083 2007 480FBF45 		movswq	-18(%rbp), %rax
 4083      EE
 4084 200c 4889D6   		movq	%rdx, %rsi
 4085 200f 4889C7   		movq	%rax, %rdi
 4086 2012 E8000000 		call	SYSTEM_MOD@PLT
 4086      00
 4087              	.L192:
 4089              	.LM653:
 4090 2017 B9090000 		movl	$9, %ecx
 4090      00
 4091 201c 488D1500 		leaq	.LC52(%rip), %rdx
 4091      000000
 4092 2023 89DE     		movl	%ebx, %esi
 4093 2025 89C7     		movl	%eax, %edi
 4094 2027 E843F0FF 		call	TestLanguage_TestValue
 4094      FF
 361:TestLanguage.c **** 	i = 5;
 4096              	.LM654:
 4097 202c 66C745EE 		movw	$5, -18(%rbp)
 4097      0500
 362:TestLanguage.c **** 	j = -3;
 4099              	.LM655:
 4100 2032 66C745EC 		movw	$-3, -20(%rbp)
 4100      FDFF
 363:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"5 MOD -3", 9);
 4102              	.LM656:
 4103 2038 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4104 203c 66837DEE 		cmpw	$0, -18(%rbp)
 4104      00
 4105 2041 7E16     		jle	.L193
 4107              	.LM657:
 4108 2043 66837DEC 		cmpw	$0, -20(%rbp)
 4108      00
 4109 2048 7E0F     		jle	.L193
 4111              	.LM658:
 4112 204a 0FBF45EE 		movswl	-18(%rbp), %eax
 4113 204e 0FBF75EC 		movswl	-20(%rbp), %esi
 4114 2052 99       		cltd
 4115 2053 F7FE     		idivl	%esi
 4117              	.LM659:
 4118 2055 89C2     		movl	%eax, %edx
 4119 2057 EB17     		jmp	.L194
 4120              	.L193:
 4122              	.LM660:
 4123 2059 480FBF55 		movswq	-20(%rbp), %rdx
 4123      EC
 4124 205e 480FBF45 		movswq	-18(%rbp), %rax
 4124      EE
 4125 2063 4889D6   		movq	%rdx, %rsi
 4126 2066 4889C7   		movq	%rax, %rdi
 4127 2069 E8000000 		call	SYSTEM_DIV@PLT
 4127      00
 4129              	.LM661:
 4130 206e 89C2     		movl	%eax, %edx
 4131              	.L194:
 4133              	.LM662:
 4134 2070 0FBF45EC 		movswl	-20(%rbp), %eax
 4135 2074 0FAFC2   		imull	%edx, %eax
 4136 2077 29C3     		subl	%eax, %ebx
 4137 2079 89D8     		movl	%ebx, %eax
 4139              	.LM663:
 4140 207b 89C3     		movl	%eax, %ebx
 4141 207d 66837DEE 		cmpw	$0, -18(%rbp)
 4141      00
 4142 2082 7E16     		jle	.L195
 4144              	.LM664:
 4145 2084 66837DEC 		cmpw	$0, -20(%rbp)
 4145      00
 4146 2089 7E0F     		jle	.L195
 4148              	.LM665:
 4149 208b 0FBF45EE 		movswl	-18(%rbp), %eax
 4150 208f 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4152              	.LM666:
 4153 2093 99       		cltd
 4154 2094 F7F9     		idivl	%ecx
 4155 2096 89D0     		movl	%edx, %eax
 4156 2098 EB15     		jmp	.L196
 4157              	.L195:
 4159              	.LM667:
 4160 209a 480FBF55 		movswq	-20(%rbp), %rdx
 4160      EC
 4161 209f 480FBF45 		movswq	-18(%rbp), %rax
 4161      EE
 4162 20a4 4889D6   		movq	%rdx, %rsi
 4163 20a7 4889C7   		movq	%rax, %rdi
 4164 20aa E8000000 		call	SYSTEM_MOD@PLT
 4164      00
 4165              	.L196:
 4167              	.LM668:
 4168 20af B9090000 		movl	$9, %ecx
 4168      00
 4169 20b4 488D1500 		leaq	.LC53(%rip), %rdx
 4169      000000
 4170 20bb 89DE     		movl	%ebx, %esi
 4171 20bd 89C7     		movl	%eax, %edi
 4172 20bf E8ABEFFF 		call	TestLanguage_TestValue
 4172      FF
 364:TestLanguage.c **** 	i = 6;
 4174              	.LM669:
 4175 20c4 66C745EE 		movw	$6, -18(%rbp)
 4175      0600
 365:TestLanguage.c **** 	j = -3;
 4177              	.LM670:
 4178 20ca 66C745EC 		movw	$-3, -20(%rbp)
 4178      FDFF
 366:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"6 MOD -3", 9);
 4180              	.LM671:
 4181 20d0 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4182 20d4 66837DEE 		cmpw	$0, -18(%rbp)
 4182      00
 4183 20d9 7E16     		jle	.L197
 4185              	.LM672:
 4186 20db 66837DEC 		cmpw	$0, -20(%rbp)
 4186      00
 4187 20e0 7E0F     		jle	.L197
 4189              	.LM673:
 4190 20e2 0FBF45EE 		movswl	-18(%rbp), %eax
 4191 20e6 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4192 20ea 99       		cltd
 4193 20eb F7F9     		idivl	%ecx
 4195              	.LM674:
 4196 20ed 89C2     		movl	%eax, %edx
 4197 20ef EB17     		jmp	.L198
 4198              	.L197:
 4200              	.LM675:
 4201 20f1 480FBF55 		movswq	-20(%rbp), %rdx
 4201      EC
 4202 20f6 480FBF45 		movswq	-18(%rbp), %rax
 4202      EE
 4203 20fb 4889D6   		movq	%rdx, %rsi
 4204 20fe 4889C7   		movq	%rax, %rdi
 4205 2101 E8000000 		call	SYSTEM_DIV@PLT
 4205      00
 4207              	.LM676:
 4208 2106 89C2     		movl	%eax, %edx
 4209              	.L198:
 4211              	.LM677:
 4212 2108 0FBF45EC 		movswl	-20(%rbp), %eax
 4213 210c 0FAFC2   		imull	%edx, %eax
 4214 210f 29C3     		subl	%eax, %ebx
 4215 2111 89D8     		movl	%ebx, %eax
 4217              	.LM678:
 4218 2113 89C3     		movl	%eax, %ebx
 4219 2115 66837DEE 		cmpw	$0, -18(%rbp)
 4219      00
 4220 211a 7E16     		jle	.L199
 4222              	.LM679:
 4223 211c 66837DEC 		cmpw	$0, -20(%rbp)
 4223      00
 4224 2121 7E0F     		jle	.L199
 4226              	.LM680:
 4227 2123 0FBF45EE 		movswl	-18(%rbp), %eax
 4228 2127 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4230              	.LM681:
 4231 212b 99       		cltd
 4232 212c F7F9     		idivl	%ecx
 4233 212e 89D0     		movl	%edx, %eax
 4234 2130 EB15     		jmp	.L200
 4235              	.L199:
 4237              	.LM682:
 4238 2132 480FBF55 		movswq	-20(%rbp), %rdx
 4238      EC
 4239 2137 480FBF45 		movswq	-18(%rbp), %rax
 4239      EE
 4240 213c 4889D6   		movq	%rdx, %rsi
 4241 213f 4889C7   		movq	%rax, %rdi
 4242 2142 E8000000 		call	SYSTEM_MOD@PLT
 4242      00
 4243              	.L200:
 4245              	.LM683:
 4246 2147 B9090000 		movl	$9, %ecx
 4246      00
 4247 214c 488D1500 		leaq	.LC54(%rip), %rdx
 4247      000000
 4248 2153 89DE     		movl	%ebx, %esi
 4249 2155 89C7     		movl	%eax, %edi
 4250 2157 E813EFFF 		call	TestLanguage_TestValue
 4250      FF
 367:TestLanguage.c **** 	i = 7;
 4252              	.LM684:
 4253 215c 66C745EE 		movw	$7, -18(%rbp)
 4253      0700
 368:TestLanguage.c **** 	j = -3;
 4255              	.LM685:
 4256 2162 66C745EC 		movw	$-3, -20(%rbp)
 4256      FDFF
 369:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"7 MOD -3", 9);
 4258              	.LM686:
 4259 2168 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4260 216c 66837DEE 		cmpw	$0, -18(%rbp)
 4260      00
 4261 2171 7E16     		jle	.L201
 4263              	.LM687:
 4264 2173 66837DEC 		cmpw	$0, -20(%rbp)
 4264      00
 4265 2178 7E0F     		jle	.L201
 4267              	.LM688:
 4268 217a 0FBF45EE 		movswl	-18(%rbp), %eax
 4269 217e 0FBF75EC 		movswl	-20(%rbp), %esi
 4270 2182 99       		cltd
 4271 2183 F7FE     		idivl	%esi
 4273              	.LM689:
 4274 2185 89C2     		movl	%eax, %edx
 4275 2187 EB17     		jmp	.L202
 4276              	.L201:
 4278              	.LM690:
 4279 2189 480FBF55 		movswq	-20(%rbp), %rdx
 4279      EC
 4280 218e 480FBF45 		movswq	-18(%rbp), %rax
 4280      EE
 4281 2193 4889D6   		movq	%rdx, %rsi
 4282 2196 4889C7   		movq	%rax, %rdi
 4283 2199 E8000000 		call	SYSTEM_DIV@PLT
 4283      00
 4285              	.LM691:
 4286 219e 89C2     		movl	%eax, %edx
 4287              	.L202:
 4289              	.LM692:
 4290 21a0 0FBF45EC 		movswl	-20(%rbp), %eax
 4291 21a4 0FAFC2   		imull	%edx, %eax
 4292 21a7 29C3     		subl	%eax, %ebx
 4293 21a9 89D8     		movl	%ebx, %eax
 4295              	.LM693:
 4296 21ab 89C3     		movl	%eax, %ebx
 4297 21ad 66837DEE 		cmpw	$0, -18(%rbp)
 4297      00
 4298 21b2 7E16     		jle	.L203
 4300              	.LM694:
 4301 21b4 66837DEC 		cmpw	$0, -20(%rbp)
 4301      00
 4302 21b9 7E0F     		jle	.L203
 4304              	.LM695:
 4305 21bb 0FBF45EE 		movswl	-18(%rbp), %eax
 4306 21bf 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4308              	.LM696:
 4309 21c3 99       		cltd
 4310 21c4 F7F9     		idivl	%ecx
 4311 21c6 89D0     		movl	%edx, %eax
 4312 21c8 EB15     		jmp	.L204
 4313              	.L203:
 4315              	.LM697:
 4316 21ca 480FBF55 		movswq	-20(%rbp), %rdx
 4316      EC
 4317 21cf 480FBF45 		movswq	-18(%rbp), %rax
 4317      EE
 4318 21d4 4889D6   		movq	%rdx, %rsi
 4319 21d7 4889C7   		movq	%rax, %rdi
 4320 21da E8000000 		call	SYSTEM_MOD@PLT
 4320      00
 4321              	.L204:
 4323              	.LM698:
 4324 21df B9090000 		movl	$9, %ecx
 4324      00
 4325 21e4 488D1500 		leaq	.LC55(%rip), %rdx
 4325      000000
 4326 21eb 89DE     		movl	%ebx, %esi
 4327 21ed 89C7     		movl	%eax, %edi
 4328 21ef E87BEEFF 		call	TestLanguage_TestValue
 4328      FF
 370:TestLanguage.c **** 	i = -4;
 4330              	.LM699:
 4331 21f4 66C745EE 		movw	$-4, -18(%rbp)
 4331      FCFF
 371:TestLanguage.c **** 	j = -3;
 4333              	.LM700:
 4334 21fa 66C745EC 		movw	$-3, -20(%rbp)
 4334      FDFF
 372:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-4 MOD -3", 10);
 4336              	.LM701:
 4337 2200 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4338 2204 66837DEE 		cmpw	$0, -18(%rbp)
 4338      00
 4339 2209 7E16     		jle	.L205
 4341              	.LM702:
 4342 220b 66837DEC 		cmpw	$0, -20(%rbp)
 4342      00
 4343 2210 7E0F     		jle	.L205
 4345              	.LM703:
 4346 2212 0FBF45EE 		movswl	-18(%rbp), %eax
 4347 2216 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4348 221a 99       		cltd
 4349 221b F7F9     		idivl	%ecx
 4351              	.LM704:
 4352 221d 89C2     		movl	%eax, %edx
 4353 221f EB17     		jmp	.L206
 4354              	.L205:
 4356              	.LM705:
 4357 2221 480FBF55 		movswq	-20(%rbp), %rdx
 4357      EC
 4358 2226 480FBF45 		movswq	-18(%rbp), %rax
 4358      EE
 4359 222b 4889D6   		movq	%rdx, %rsi
 4360 222e 4889C7   		movq	%rax, %rdi
 4361 2231 E8000000 		call	SYSTEM_DIV@PLT
 4361      00
 4363              	.LM706:
 4364 2236 89C2     		movl	%eax, %edx
 4365              	.L206:
 4367              	.LM707:
 4368 2238 0FBF45EC 		movswl	-20(%rbp), %eax
 4369 223c 0FAFC2   		imull	%edx, %eax
 4370 223f 29C3     		subl	%eax, %ebx
 4371 2241 89D8     		movl	%ebx, %eax
 4373              	.LM708:
 4374 2243 89C3     		movl	%eax, %ebx
 4375 2245 66837DEE 		cmpw	$0, -18(%rbp)
 4375      00
 4376 224a 7E16     		jle	.L207
 4378              	.LM709:
 4379 224c 66837DEC 		cmpw	$0, -20(%rbp)
 4379      00
 4380 2251 7E0F     		jle	.L207
 4382              	.LM710:
 4383 2253 0FBF45EE 		movswl	-18(%rbp), %eax
 4384 2257 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4386              	.LM711:
 4387 225b 99       		cltd
 4388 225c F7F9     		idivl	%ecx
 4389 225e 89D0     		movl	%edx, %eax
 4390 2260 EB15     		jmp	.L208
 4391              	.L207:
 4393              	.LM712:
 4394 2262 480FBF55 		movswq	-20(%rbp), %rdx
 4394      EC
 4395 2267 480FBF45 		movswq	-18(%rbp), %rax
 4395      EE
 4396 226c 4889D6   		movq	%rdx, %rsi
 4397 226f 4889C7   		movq	%rax, %rdi
 4398 2272 E8000000 		call	SYSTEM_MOD@PLT
 4398      00
 4399              	.L208:
 4401              	.LM713:
 4402 2277 B90A0000 		movl	$10, %ecx
 4402      00
 4403 227c 488D1500 		leaq	.LC56(%rip), %rdx
 4403      000000
 4404 2283 89DE     		movl	%ebx, %esi
 4405 2285 89C7     		movl	%eax, %edi
 4406 2287 E8E3EDFF 		call	TestLanguage_TestValue
 4406      FF
 373:TestLanguage.c **** 	i = -5;
 4408              	.LM714:
 4409 228c 66C745EE 		movw	$-5, -18(%rbp)
 4409      FBFF
 374:TestLanguage.c **** 	j = -3;
 4411              	.LM715:
 4412 2292 66C745EC 		movw	$-3, -20(%rbp)
 4412      FDFF
 375:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-5 MOD -3", 10);
 4414              	.LM716:
 4415 2298 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4416 229c 66837DEE 		cmpw	$0, -18(%rbp)
 4416      00
 4417 22a1 7E16     		jle	.L209
 4419              	.LM717:
 4420 22a3 66837DEC 		cmpw	$0, -20(%rbp)
 4420      00
 4421 22a8 7E0F     		jle	.L209
 4423              	.LM718:
 4424 22aa 0FBF45EE 		movswl	-18(%rbp), %eax
 4425 22ae 0FBF75EC 		movswl	-20(%rbp), %esi
 4426 22b2 99       		cltd
 4427 22b3 F7FE     		idivl	%esi
 4429              	.LM719:
 4430 22b5 89C2     		movl	%eax, %edx
 4431 22b7 EB17     		jmp	.L210
 4432              	.L209:
 4434              	.LM720:
 4435 22b9 480FBF55 		movswq	-20(%rbp), %rdx
 4435      EC
 4436 22be 480FBF45 		movswq	-18(%rbp), %rax
 4436      EE
 4437 22c3 4889D6   		movq	%rdx, %rsi
 4438 22c6 4889C7   		movq	%rax, %rdi
 4439 22c9 E8000000 		call	SYSTEM_DIV@PLT
 4439      00
 4441              	.LM721:
 4442 22ce 89C2     		movl	%eax, %edx
 4443              	.L210:
 4445              	.LM722:
 4446 22d0 0FBF45EC 		movswl	-20(%rbp), %eax
 4447 22d4 0FAFC2   		imull	%edx, %eax
 4448 22d7 29C3     		subl	%eax, %ebx
 4449 22d9 89D8     		movl	%ebx, %eax
 4451              	.LM723:
 4452 22db 89C3     		movl	%eax, %ebx
 4453 22dd 66837DEE 		cmpw	$0, -18(%rbp)
 4453      00
 4454 22e2 7E16     		jle	.L211
 4456              	.LM724:
 4457 22e4 66837DEC 		cmpw	$0, -20(%rbp)
 4457      00
 4458 22e9 7E0F     		jle	.L211
 4460              	.LM725:
 4461 22eb 0FBF45EE 		movswl	-18(%rbp), %eax
 4462 22ef 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4464              	.LM726:
 4465 22f3 99       		cltd
 4466 22f4 F7F9     		idivl	%ecx
 4467 22f6 89D0     		movl	%edx, %eax
 4468 22f8 EB15     		jmp	.L212
 4469              	.L211:
 4471              	.LM727:
 4472 22fa 480FBF55 		movswq	-20(%rbp), %rdx
 4472      EC
 4473 22ff 480FBF45 		movswq	-18(%rbp), %rax
 4473      EE
 4474 2304 4889D6   		movq	%rdx, %rsi
 4475 2307 4889C7   		movq	%rax, %rdi
 4476 230a E8000000 		call	SYSTEM_MOD@PLT
 4476      00
 4477              	.L212:
 4479              	.LM728:
 4480 230f B90A0000 		movl	$10, %ecx
 4480      00
 4481 2314 488D1500 		leaq	.LC57(%rip), %rdx
 4481      000000
 4482 231b 89DE     		movl	%ebx, %esi
 4483 231d 89C7     		movl	%eax, %edi
 4484 231f E84BEDFF 		call	TestLanguage_TestValue
 4484      FF
 376:TestLanguage.c **** 	i = -6;
 4486              	.LM729:
 4487 2324 66C745EE 		movw	$-6, -18(%rbp)
 4487      FAFF
 377:TestLanguage.c **** 	j = -3;
 4489              	.LM730:
 4490 232a 66C745EC 		movw	$-3, -20(%rbp)
 4490      FDFF
 378:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-6 MOD -3", 10);
 4492              	.LM731:
 4493 2330 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4494 2334 66837DEE 		cmpw	$0, -18(%rbp)
 4494      00
 4495 2339 7E16     		jle	.L213
 4497              	.LM732:
 4498 233b 66837DEC 		cmpw	$0, -20(%rbp)
 4498      00
 4499 2340 7E0F     		jle	.L213
 4501              	.LM733:
 4502 2342 0FBF45EE 		movswl	-18(%rbp), %eax
 4503 2346 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4504 234a 99       		cltd
 4505 234b F7F9     		idivl	%ecx
 4507              	.LM734:
 4508 234d 89C2     		movl	%eax, %edx
 4509 234f EB17     		jmp	.L214
 4510              	.L213:
 4512              	.LM735:
 4513 2351 480FBF55 		movswq	-20(%rbp), %rdx
 4513      EC
 4514 2356 480FBF45 		movswq	-18(%rbp), %rax
 4514      EE
 4515 235b 4889D6   		movq	%rdx, %rsi
 4516 235e 4889C7   		movq	%rax, %rdi
 4517 2361 E8000000 		call	SYSTEM_DIV@PLT
 4517      00
 4519              	.LM736:
 4520 2366 89C2     		movl	%eax, %edx
 4521              	.L214:
 4523              	.LM737:
 4524 2368 0FBF45EC 		movswl	-20(%rbp), %eax
 4525 236c 0FAFC2   		imull	%edx, %eax
 4526 236f 29C3     		subl	%eax, %ebx
 4527 2371 89D8     		movl	%ebx, %eax
 4529              	.LM738:
 4530 2373 89C3     		movl	%eax, %ebx
 4531 2375 66837DEE 		cmpw	$0, -18(%rbp)
 4531      00
 4532 237a 7E16     		jle	.L215
 4534              	.LM739:
 4535 237c 66837DEC 		cmpw	$0, -20(%rbp)
 4535      00
 4536 2381 7E0F     		jle	.L215
 4538              	.LM740:
 4539 2383 0FBF45EE 		movswl	-18(%rbp), %eax
 4540 2387 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4542              	.LM741:
 4543 238b 99       		cltd
 4544 238c F7F9     		idivl	%ecx
 4545 238e 89D0     		movl	%edx, %eax
 4546 2390 EB15     		jmp	.L216
 4547              	.L215:
 4549              	.LM742:
 4550 2392 480FBF55 		movswq	-20(%rbp), %rdx
 4550      EC
 4551 2397 480FBF45 		movswq	-18(%rbp), %rax
 4551      EE
 4552 239c 4889D6   		movq	%rdx, %rsi
 4553 239f 4889C7   		movq	%rax, %rdi
 4554 23a2 E8000000 		call	SYSTEM_MOD@PLT
 4554      00
 4555              	.L216:
 4557              	.LM743:
 4558 23a7 B90A0000 		movl	$10, %ecx
 4558      00
 4559 23ac 488D1500 		leaq	.LC58(%rip), %rdx
 4559      000000
 4560 23b3 89DE     		movl	%ebx, %esi
 4561 23b5 89C7     		movl	%eax, %edi
 4562 23b7 E8B3ECFF 		call	TestLanguage_TestValue
 4562      FF
 379:TestLanguage.c **** 	i = -7;
 4564              	.LM744:
 4565 23bc 66C745EE 		movw	$-7, -18(%rbp)
 4565      F9FF
 380:TestLanguage.c **** 	j = -3;
 4567              	.LM745:
 4568 23c2 66C745EC 		movw	$-3, -20(%rbp)
 4568      FDFF
 381:TestLanguage.c **** 	TestLanguage_TestValue((int)__MOD(i, j), i - __DIV(i, j) * j, (CHAR*)"-7 MOD -3", 10);
 4570              	.LM746:
 4571 23c8 0FBF5DEE 		movswl	-18(%rbp), %ebx
 4572 23cc 66837DEE 		cmpw	$0, -18(%rbp)
 4572      00
 4573 23d1 7E16     		jle	.L217
 4575              	.LM747:
 4576 23d3 66837DEC 		cmpw	$0, -20(%rbp)
 4576      00
 4577 23d8 7E0F     		jle	.L217
 4579              	.LM748:
 4580 23da 0FBF45EE 		movswl	-18(%rbp), %eax
 4581 23de 0FBF75EC 		movswl	-20(%rbp), %esi
 4582 23e2 99       		cltd
 4583 23e3 F7FE     		idivl	%esi
 4585              	.LM749:
 4586 23e5 89C2     		movl	%eax, %edx
 4587 23e7 EB17     		jmp	.L218
 4588              	.L217:
 4590              	.LM750:
 4591 23e9 480FBF55 		movswq	-20(%rbp), %rdx
 4591      EC
 4592 23ee 480FBF45 		movswq	-18(%rbp), %rax
 4592      EE
 4593 23f3 4889D6   		movq	%rdx, %rsi
 4594 23f6 4889C7   		movq	%rax, %rdi
 4595 23f9 E8000000 		call	SYSTEM_DIV@PLT
 4595      00
 4597              	.LM751:
 4598 23fe 89C2     		movl	%eax, %edx
 4599              	.L218:
 4601              	.LM752:
 4602 2400 0FBF45EC 		movswl	-20(%rbp), %eax
 4603 2404 0FAFC2   		imull	%edx, %eax
 4604 2407 29C3     		subl	%eax, %ebx
 4605 2409 89D8     		movl	%ebx, %eax
 4607              	.LM753:
 4608 240b 89C3     		movl	%eax, %ebx
 4609 240d 66837DEE 		cmpw	$0, -18(%rbp)
 4609      00
 4610 2412 7E16     		jle	.L219
 4612              	.LM754:
 4613 2414 66837DEC 		cmpw	$0, -20(%rbp)
 4613      00
 4614 2419 7E0F     		jle	.L219
 4616              	.LM755:
 4617 241b 0FBF45EE 		movswl	-18(%rbp), %eax
 4618 241f 0FBF4DEC 		movswl	-20(%rbp), %ecx
 4620              	.LM756:
 4621 2423 99       		cltd
 4622 2424 F7F9     		idivl	%ecx
 4623 2426 89D0     		movl	%edx, %eax
 4624 2428 EB15     		jmp	.L220
 4625              	.L219:
 4627              	.LM757:
 4628 242a 480FBF55 		movswq	-20(%rbp), %rdx
 4628      EC
 4629 242f 480FBF45 		movswq	-18(%rbp), %rax
 4629      EE
 4630 2434 4889D6   		movq	%rdx, %rsi
 4631 2437 4889C7   		movq	%rax, %rdi
 4632 243a E8000000 		call	SYSTEM_MOD@PLT
 4632      00
 4633              	.L220:
 4635              	.LM758:
 4636 243f B90A0000 		movl	$10, %ecx
 4636      00
 4637 2444 488D1500 		leaq	.LC59(%rip), %rdx
 4637      000000
 4638 244b 89DE     		movl	%ebx, %esi
 4639 244d 89C7     		movl	%eax, %edi
 4640 244f E81BECFF 		call	TestLanguage_TestValue
 4640      FF
 382:TestLanguage.c **** }
 4642              	.LM759:
 4643 2454 90       		nop
 4644 2455 4883C418 		addq	$24, %rsp
 4645 2459 5B       		popq	%rbx
 4646 245a 5D       		popq	%rbp
 4647              		.cfi_def_cfa 7, 8
 4648 245b C3       		ret
 4649              		.cfi_endproc
 4650              	.LFE11:
 4656              	.Lscope5:
 4658              		.stabd	78,0,0
 4659              		.section	.rodata
 4660              	.LC60:
 4661 02e6 41425328 		.string	"ABS(INTEGER 5)"
 4661      494E5445 
 4661      47455220 
 4661      352900
 4662              	.LC61:
 4663 02f5 41425328 		.string	"ABS(INTEGER -5)"
 4663      494E5445 
 4663      47455220 
 4663      2D352900 
 4664              	.LC62:
 4665 0305 41425328 		.string	"ABS(LONGINT 5)"
 4665      4C4F4E47 
 4665      494E5420 
 4665      352900
 4666              	.LC63:
 4667 0314 41425328 		.string	"ABS(LONGINT -5)"
 4667      4C4F4E47 
 4667      494E5420 
 4667      2D352900 
 4668              	.LC64:
 4669 0324 41425328 		.string	"ABS(SYSTEM.INT64 5)"
 4669      53595354 
 4669      454D2E49 
 4669      4E543634 
 4669      20352900 
 4670              	.LC65:
 4671 0338 41425328 		.string	"ABS(SYSTEM.INT64 -5)"
 4671      53595354 
 4671      454D2E49 
 4671      4E543634 
 4671      202D3529 
 4672              		.text
 4675              	TestLanguage_Abs:
 4676              		.stabd	46,0,0
 383:TestLanguage.c **** 
 384:TestLanguage.c **** static void TestLanguage_Abs (void)
 385:TestLanguage.c **** {
 4678              	.LM760:
 4679              	.LFBB6:
 4680              	.LFB12:
 4681              		.cfi_startproc
 4682 245c F30F1EFA 		endbr64
 4683 2460 55       		pushq	%rbp
 4684              		.cfi_def_cfa_offset 16
 4685              		.cfi_offset 6, -16
 4686 2461 4889E5   		movq	%rsp, %rbp
 4687              		.cfi_def_cfa_register 6
 4688 2464 4883EC10 		subq	$16, %rsp
 386:TestLanguage.c **** 	INT16 i;
 387:TestLanguage.c **** 	INT32 l;
 388:TestLanguage.c **** 	INT64 h;
 389:TestLanguage.c **** 	i = 5;
 4690              	.LM761:
 4691 2468 66C745F2 		movw	$5, -14(%rbp)
 4691      0500
 390:TestLanguage.c **** 	TestLanguage_TestValue(__ABS(i), 5, (CHAR*)"ABS(INTEGER 5)", 15);
 4693              	.LM762:
 4694 246e 0FB745F2 		movzwl	-14(%rbp), %eax
 4695 2472 66C1F80F 		sarw	$15, %ax
 4696 2476 89C2     		movl	%eax, %edx
 4697 2478 89D0     		movl	%edx, %eax
 4698 247a 663345F2 		xorw	-14(%rbp), %ax
 4699 247e 29D0     		subl	%edx, %eax
 4701              	.LM763:
 4702 2480 0FB7C0   		movzwl	%ax, %eax
 4703 2483 B90F0000 		movl	$15, %ecx
 4703      00
 4704 2488 488D1500 		leaq	.LC60(%rip), %rdx
 4704      000000
 4705 248f BE050000 		movl	$5, %esi
 4705      00
 4706 2494 89C7     		movl	%eax, %edi
 4707 2496 E8D4EBFF 		call	TestLanguage_TestValue
 4707      FF
 391:TestLanguage.c **** 	i = -5;
 4709              	.LM764:
 4710 249b 66C745F2 		movw	$-5, -14(%rbp)
 4710      FBFF
 392:TestLanguage.c **** 	TestLanguage_TestValue(__ABS(i), 5, (CHAR*)"ABS(INTEGER -5)", 16);
 4712              	.LM765:
 4713 24a1 0FB745F2 		movzwl	-14(%rbp), %eax
 4714 24a5 66C1F80F 		sarw	$15, %ax
 4715 24a9 89C2     		movl	%eax, %edx
 4716 24ab 89D0     		movl	%edx, %eax
 4717 24ad 663345F2 		xorw	-14(%rbp), %ax
 4718 24b1 29D0     		subl	%edx, %eax
 4720              	.LM766:
 4721 24b3 0FB7C0   		movzwl	%ax, %eax
 4722 24b6 B9100000 		movl	$16, %ecx
 4722      00
 4723 24bb 488D1500 		leaq	.LC61(%rip), %rdx
 4723      000000
 4724 24c2 BE050000 		movl	$5, %esi
 4724      00
 4725 24c7 89C7     		movl	%eax, %edi
 4726 24c9 E8A1EBFF 		call	TestLanguage_TestValue
 4726      FF
 393:TestLanguage.c **** 	l = 5;
 4728              	.LM767:
 4729 24ce C745F405 		movl	$5, -12(%rbp)
 4729      000000
 394:TestLanguage.c **** 	TestLanguage_TestValue(__ABS(l), 5, (CHAR*)"ABS(LONGINT 5)", 15);
 4731              	.LM768:
 4732 24d5 8B45F4   		movl	-12(%rbp), %eax
 4733 24d8 99       		cltd
 4734 24d9 89D0     		movl	%edx, %eax
 4735 24db 3345F4   		xorl	-12(%rbp), %eax
 4736 24de 29D0     		subl	%edx, %eax
 4737 24e0 B90F0000 		movl	$15, %ecx
 4737      00
 4738 24e5 488D1500 		leaq	.LC62(%rip), %rdx
 4738      000000
 4739 24ec BE050000 		movl	$5, %esi
 4739      00
 4740 24f1 89C7     		movl	%eax, %edi
 4741 24f3 E877EBFF 		call	TestLanguage_TestValue
 4741      FF
 395:TestLanguage.c **** 	l = -5;
 4743              	.LM769:
 4744 24f8 C745F4FB 		movl	$-5, -12(%rbp)
 4744      FFFFFF
 396:TestLanguage.c **** 	TestLanguage_TestValue(__ABS(l), 5, (CHAR*)"ABS(LONGINT -5)", 16);
 4746              	.LM770:
 4747 24ff 8B45F4   		movl	-12(%rbp), %eax
 4748 2502 99       		cltd
 4749 2503 89D0     		movl	%edx, %eax
 4750 2505 3345F4   		xorl	-12(%rbp), %eax
 4751 2508 29D0     		subl	%edx, %eax
 4752 250a B9100000 		movl	$16, %ecx
 4752      00
 4753 250f 488D1500 		leaq	.LC63(%rip), %rdx
 4753      000000
 4754 2516 BE050000 		movl	$5, %esi
 4754      00
 4755 251b 89C7     		movl	%eax, %edi
 4756 251d E84DEBFF 		call	TestLanguage_TestValue
 4756      FF
 397:TestLanguage.c **** 	h = 5;
 4758              	.LM771:
 4759 2522 48C745F8 		movq	$5, -8(%rbp)
 4759      05000000 
 398:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ABS(h), 5, (CHAR*)"ABS(SYSTEM.INT64 5)", 20);
 4761              	.LM772:
 4762 252a 48837DF8 		cmpq	$0, -8(%rbp)
 4762      00
 4763 252f 7908     		jns	.L222
 4765              	.LM773:
 4766 2531 488B45F8 		movq	-8(%rbp), %rax
 4767 2535 F7D8     		negl	%eax
 4768 2537 EB04     		jmp	.L223
 4769              	.L222:
 4771              	.LM774:
 4772 2539 488B45F8 		movq	-8(%rbp), %rax
 4773              	.L223:
 4775              	.LM775:
 4776 253d B9140000 		movl	$20, %ecx
 4776      00
 4777 2542 488D1500 		leaq	.LC64(%rip), %rdx
 4777      000000
 4778 2549 BE050000 		movl	$5, %esi
 4778      00
 4779 254e 89C7     		movl	%eax, %edi
 4780 2550 E81AEBFF 		call	TestLanguage_TestValue
 4780      FF
 399:TestLanguage.c **** 	h = -5;
 4782              	.LM776:
 4783 2555 48C745F8 		movq	$-5, -8(%rbp)
 4783      FBFFFFFF 
 400:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ABS(h), 5, (CHAR*)"ABS(SYSTEM.INT64 -5)", 21);
 4785              	.LM777:
 4786 255d 48837DF8 		cmpq	$0, -8(%rbp)
 4786      00
 4787 2562 7908     		jns	.L224
 4789              	.LM778:
 4790 2564 488B45F8 		movq	-8(%rbp), %rax
 4791 2568 F7D8     		negl	%eax
 4792 256a EB04     		jmp	.L225
 4793              	.L224:
 4795              	.LM779:
 4796 256c 488B45F8 		movq	-8(%rbp), %rax
 4797              	.L225:
 4799              	.LM780:
 4800 2570 B9150000 		movl	$21, %ecx
 4800      00
 4801 2575 488D1500 		leaq	.LC65(%rip), %rdx
 4801      000000
 4802 257c BE050000 		movl	$5, %esi
 4802      00
 4803 2581 89C7     		movl	%eax, %edi
 4804 2583 E8E7EAFF 		call	TestLanguage_TestValue
 4804      FF
 401:TestLanguage.c **** }
 4806              	.LM781:
 4807 2588 90       		nop
 4808 2589 C9       		leave
 4809              		.cfi_def_cfa 7, 8
 4810 258a C3       		ret
 4811              		.cfi_endproc
 4812              	.LFE12:
 4819              	.Lscope6:
 4821              		.stabd	78,0,0
 4825              	TestLanguage_LR:
 4826              		.stabd	46,0,0
 402:TestLanguage.c **** 
 403:TestLanguage.c **** static LONGREAL TestLanguage_LR (LONGREAL lr)
 404:TestLanguage.c **** {
 4828              	.LM782:
 4829              	.LFBB7:
 4830              	.LFB13:
 4831              		.cfi_startproc
 4832 258b F30F1EFA 		endbr64
 4833 258f 55       		pushq	%rbp
 4834              		.cfi_def_cfa_offset 16
 4835              		.cfi_offset 6, -16
 4836 2590 4889E5   		movq	%rsp, %rbp
 4837              		.cfi_def_cfa_register 6
 4838 2593 F20F1145 		movsd	%xmm0, -8(%rbp)
 4838      F8
 405:TestLanguage.c **** 	return lr + TestLanguage_gz;
 4840              	.LM783:
 4841 2598 F20F1005 		movsd	TestLanguage_gz(%rip), %xmm0
 4841      00000000 
 4842 25a0 F20F5845 		addsd	-8(%rbp), %xmm0
 4842      F8
 406:TestLanguage.c **** }
 4844              	.LM784:
 4845 25a5 5D       		popq	%rbp
 4846              		.cfi_def_cfa 7, 8
 4847 25a6 C3       		ret
 4848              		.cfi_endproc
 4849              	.LFE13:
 4851              	.Lscope7:
 4853              		.stabd	78,0,0
 4854              		.section	.rodata
 4855              	.LC68:
 4856 034d 454E5449 		.string	"ENTIER(-0.01"
 4856      4552282D 
 4856      302E3031 
 4856      00
 4857              	.LC69:
 4858 035a 454E5449 		.string	"ENTIER(0.00"
 4858      45522830 
 4858      2E303000 
 4859              	.LC71:
 4860 0366 454E5449 		.string	"ENTIER(5.00"
 4860      45522835 
 4860      2E303000 
 4861              	.LC73:
 4862 0372 454E5449 		.string	"ENTIER(5.50"
 4862      45522835 
 4862      2E353000 
 4863              	.LC75:
 4864 037e 454E5449 		.string	"ENTIER(5.99"
 4864      45522835 
 4864      2E393900 
 4865              	.LC77:
 4866 038a 454E5449 		.string	"ENTIER(-5.00"
 4866      4552282D 
 4866      352E3030 
 4866      00
 4867              	.LC79:
 4868 0397 454E5449 		.string	"ENTIER(-5.50"
 4868      4552282D 
 4868      352E3530 
 4868      00
 4869              	.LC81:
 4870 03a4 454E5449 		.string	"ENTIER(-5.99"
 4870      4552282D 
 4870      352E3939 
 4870      00
 4871              		.text
 4874              	TestLanguage_Entier:
 4875              		.stabd	46,0,0
 407:TestLanguage.c **** 
 408:TestLanguage.c **** static void TestLanguage_Entier (void)
 409:TestLanguage.c **** {
 4877              	.LM785:
 4878              	.LFBB8:
 4879              	.LFB14:
 4880              		.cfi_startproc
 4881 25a7 F30F1EFA 		endbr64
 4882 25ab 55       		pushq	%rbp
 4883              		.cfi_def_cfa_offset 16
 4884              		.cfi_offset 6, -16
 4885 25ac 4889E5   		movq	%rsp, %rbp
 4886              		.cfi_def_cfa_register 6
 4887 25af 4883EC10 		subq	$16, %rsp
 410:TestLanguage.c **** 	LONGREAL lr;
 411:TestLanguage.c **** 	TestLanguage_gz = (LONGREAL)0;
 4889              	.LM786:
 4890 25b3 660FEFC0 		pxor	%xmm0, %xmm0
 4891 25b7 F20F1105 		movsd	%xmm0, TestLanguage_gz(%rip)
 4891      00000000 
 412:TestLanguage.c **** 	lr = TestLanguage_LR( -9.99999977648258e-003);
 4893              	.LM787:
 4894 25bf 488B0500 		movq	.LC67(%rip), %rax
 4894      000000
 4895 25c6 66480F6E 		movq	%rax, %xmm0
 4895      C0
 4896 25cb E8BBFFFF 		call	TestLanguage_LR
 4896      FF
 4897 25d0 66480F7E 		movq	%xmm0, %rax
 4897      C0
 4898 25d5 488945F8 		movq	%rax, -8(%rbp)
 413:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), -1, (CHAR*)"ENTIER(-0.01", 13);
 4900              	.LM788:
 4901 25d9 488B45F8 		movq	-8(%rbp), %rax
 4902 25dd 66480F6E 		movq	%rax, %xmm0
 4902      C0
 4903 25e2 E8000000 		call	SYSTEM_ENTIER@PLT
 4903      00
 4905              	.LM789:
 4906 25e7 B90D0000 		movl	$13, %ecx
 4906      00
 4907 25ec 488D1500 		leaq	.LC68(%rip), %rdx
 4907      000000
 4908 25f3 BEFFFFFF 		movl	$-1, %esi
 4908      FF
 4909 25f8 89C7     		movl	%eax, %edi
 4910 25fa E870EAFF 		call	TestLanguage_TestValue
 4910      FF
 414:TestLanguage.c **** 	lr = TestLanguage_LR((LONGREAL)0);
 4912              	.LM790:
 4913 25ff 660FEFC0 		pxor	%xmm0, %xmm0
 4914 2603 E883FFFF 		call	TestLanguage_LR
 4914      FF
 4915 2608 66480F7E 		movq	%xmm0, %rax
 4915      C0
 4916 260d 488945F8 		movq	%rax, -8(%rbp)
 415:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), 0, (CHAR*)"ENTIER(0.00", 12);
 4918              	.LM791:
 4919 2611 488B45F8 		movq	-8(%rbp), %rax
 4920 2615 66480F6E 		movq	%rax, %xmm0
 4920      C0
 4921 261a E8000000 		call	SYSTEM_ENTIER@PLT
 4921      00
 4923              	.LM792:
 4924 261f B90C0000 		movl	$12, %ecx
 4924      00
 4925 2624 488D1500 		leaq	.LC69(%rip), %rdx
 4925      000000
 4926 262b BE000000 		movl	$0, %esi
 4926      00
 4927 2630 89C7     		movl	%eax, %edi
 4928 2632 E838EAFF 		call	TestLanguage_TestValue
 4928      FF
 416:TestLanguage.c **** 	lr = TestLanguage_LR((LONGREAL)5);
 4930              	.LM793:
 4931 2637 488B0500 		movq	.LC70(%rip), %rax
 4931      000000
 4932 263e 66480F6E 		movq	%rax, %xmm0
 4932      C0
 4933 2643 E843FFFF 		call	TestLanguage_LR
 4933      FF
 4934 2648 66480F7E 		movq	%xmm0, %rax
 4934      C0
 4935 264d 488945F8 		movq	%rax, -8(%rbp)
 417:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.00", 12);
 4937              	.LM794:
 4938 2651 488B45F8 		movq	-8(%rbp), %rax
 4939 2655 66480F6E 		movq	%rax, %xmm0
 4939      C0
 4940 265a E8000000 		call	SYSTEM_ENTIER@PLT
 4940      00
 4942              	.LM795:
 4943 265f B90C0000 		movl	$12, %ecx
 4943      00
 4944 2664 488D1500 		leaq	.LC71(%rip), %rdx
 4944      000000
 4945 266b BE050000 		movl	$5, %esi
 4945      00
 4946 2670 89C7     		movl	%eax, %edi
 4947 2672 E8F8E9FF 		call	TestLanguage_TestValue
 4947      FF
 418:TestLanguage.c **** 	lr = TestLanguage_LR(  5.50000000000000e+000);
 4949              	.LM796:
 4950 2677 488B0500 		movq	.LC72(%rip), %rax
 4950      000000
 4951 267e 66480F6E 		movq	%rax, %xmm0
 4951      C0
 4952 2683 E803FFFF 		call	TestLanguage_LR
 4952      FF
 4953 2688 66480F7E 		movq	%xmm0, %rax
 4953      C0
 4954 268d 488945F8 		movq	%rax, -8(%rbp)
 419:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.50", 12);
 4956              	.LM797:
 4957 2691 488B45F8 		movq	-8(%rbp), %rax
 4958 2695 66480F6E 		movq	%rax, %xmm0
 4958      C0
 4959 269a E8000000 		call	SYSTEM_ENTIER@PLT
 4959      00
 4961              	.LM798:
 4962 269f B90C0000 		movl	$12, %ecx
 4962      00
 4963 26a4 488D1500 		leaq	.LC73(%rip), %rdx
 4963      000000
 4964 26ab BE050000 		movl	$5, %esi
 4964      00
 4965 26b0 89C7     		movl	%eax, %edi
 4966 26b2 E8B8E9FF 		call	TestLanguage_TestValue
 4966      FF
 420:TestLanguage.c **** 	lr = TestLanguage_LR(  5.98999977111816e+000);
 4968              	.LM799:
 4969 26b7 488B0500 		movq	.LC74(%rip), %rax
 4969      000000
 4970 26be 66480F6E 		movq	%rax, %xmm0
 4970      C0
 4971 26c3 E8C3FEFF 		call	TestLanguage_LR
 4971      FF
 4972 26c8 66480F7E 		movq	%xmm0, %rax
 4972      C0
 4973 26cd 488945F8 		movq	%rax, -8(%rbp)
 421:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), 5, (CHAR*)"ENTIER(5.99", 12);
 4975              	.LM800:
 4976 26d1 488B45F8 		movq	-8(%rbp), %rax
 4977 26d5 66480F6E 		movq	%rax, %xmm0
 4977      C0
 4978 26da E8000000 		call	SYSTEM_ENTIER@PLT
 4978      00
 4980              	.LM801:
 4981 26df B90C0000 		movl	$12, %ecx
 4981      00
 4982 26e4 488D1500 		leaq	.LC75(%rip), %rdx
 4982      000000
 4983 26eb BE050000 		movl	$5, %esi
 4983      00
 4984 26f0 89C7     		movl	%eax, %edi
 4985 26f2 E878E9FF 		call	TestLanguage_TestValue
 4985      FF
 422:TestLanguage.c **** 	lr = TestLanguage_LR((LONGREAL)-5);
 4987              	.LM802:
 4988 26f7 488B0500 		movq	.LC76(%rip), %rax
 4988      000000
 4989 26fe 66480F6E 		movq	%rax, %xmm0
 4989      C0
 4990 2703 E883FEFF 		call	TestLanguage_LR
 4990      FF
 4991 2708 66480F7E 		movq	%xmm0, %rax
 4991      C0
 4992 270d 488945F8 		movq	%rax, -8(%rbp)
 423:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), -5, (CHAR*)"ENTIER(-5.00", 13);
 4994              	.LM803:
 4995 2711 488B45F8 		movq	-8(%rbp), %rax
 4996 2715 66480F6E 		movq	%rax, %xmm0
 4996      C0
 4997 271a E8000000 		call	SYSTEM_ENTIER@PLT
 4997      00
 4999              	.LM804:
 5000 271f B90D0000 		movl	$13, %ecx
 5000      00
 5001 2724 488D1500 		leaq	.LC77(%rip), %rdx
 5001      000000
 5002 272b BEFBFFFF 		movl	$-5, %esi
 5002      FF
 5003 2730 89C7     		movl	%eax, %edi
 5004 2732 E838E9FF 		call	TestLanguage_TestValue
 5004      FF
 424:TestLanguage.c **** 	lr = TestLanguage_LR( -5.50000000000000e+000);
 5006              	.LM805:
 5007 2737 488B0500 		movq	.LC78(%rip), %rax
 5007      000000
 5008 273e 66480F6E 		movq	%rax, %xmm0
 5008      C0
 5009 2743 E843FEFF 		call	TestLanguage_LR
 5009      FF
 5010 2748 66480F7E 		movq	%xmm0, %rax
 5010      C0
 5011 274d 488945F8 		movq	%rax, -8(%rbp)
 425:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), -6, (CHAR*)"ENTIER(-5.50", 13);
 5013              	.LM806:
 5014 2751 488B45F8 		movq	-8(%rbp), %rax
 5015 2755 66480F6E 		movq	%rax, %xmm0
 5015      C0
 5016 275a E8000000 		call	SYSTEM_ENTIER@PLT
 5016      00
 5018              	.LM807:
 5019 275f B90D0000 		movl	$13, %ecx
 5019      00
 5020 2764 488D1500 		leaq	.LC79(%rip), %rdx
 5020      000000
 5021 276b BEFAFFFF 		movl	$-6, %esi
 5021      FF
 5022 2770 89C7     		movl	%eax, %edi
 5023 2772 E8F8E8FF 		call	TestLanguage_TestValue
 5023      FF
 426:TestLanguage.c **** 	lr = TestLanguage_LR( -5.98999977111816e+000);
 5025              	.LM808:
 5026 2777 488B0500 		movq	.LC80(%rip), %rax
 5026      000000
 5027 277e 66480F6E 		movq	%rax, %xmm0
 5027      C0
 5028 2783 E803FEFF 		call	TestLanguage_LR
 5028      FF
 5029 2788 66480F7E 		movq	%xmm0, %rax
 5029      C0
 5030 278d 488945F8 		movq	%rax, -8(%rbp)
 427:TestLanguage.c **** 	TestLanguage_TestValue((INT32)__ENTIER(lr), -6, (CHAR*)"ENTIER(-5.99", 13);
 5032              	.LM809:
 5033 2791 488B45F8 		movq	-8(%rbp), %rax
 5034 2795 66480F6E 		movq	%rax, %xmm0
 5034      C0
 5035 279a E8000000 		call	SYSTEM_ENTIER@PLT
 5035      00
 5037              	.LM810:
 5038 279f B90D0000 		movl	$13, %ecx
 5038      00
 5039 27a4 488D1500 		leaq	.LC81(%rip), %rdx
 5039      000000
 5040 27ab BEFAFFFF 		movl	$-6, %esi
 5040      FF
 5041 27b0 89C7     		movl	%eax, %edi
 5042 27b2 E8B8E8FF 		call	TestLanguage_TestValue
 5042      FF
 428:TestLanguage.c **** }
 5044              	.LM811:
 5045 27b7 90       		nop
 5046 27b8 C9       		leave
 5047              		.cfi_def_cfa 7, 8
 5048 27b9 C3       		ret
 5049              		.cfi_endproc
 5050              	.LFE14:
 5055              	.Lscope8:
 5057              		.stabd	78,0,0
 5058              		.section	.rodata
 5059              	.LC82:
 5060 03b1 4D494E28 		.string	"MIN(SHORTINT)"
 5060      53484F52 
 5060      54494E54 
 5060      2900
 5061              	.LC83:
 5062 03bf 4D415828 		.string	"MAX(SHORTINT)"
 5062      53484F52 
 5062      54494E54 
 5062      2900
 5063              	.LC84:
 5064 03cd 4D494E28 		.string	"MIN(INTEGER)"
 5064      494E5445 
 5064      47455229 
 5064      00
 5065              	.LC85:
 5066 03da 4D415828 		.string	"MAX(INTEGER)"
 5066      494E5445 
 5066      47455229 
 5066      00
 5067              	.LC86:
 5068 03e7 4D494E28 		.string	"MIN(LONGINT)"
 5068      4C4F4E47 
 5068      494E5429 
 5068      00
 5069              	.LC87:
 5070 03f4 4D415828 		.string	"MAX(LONGINT)"
 5070      4C4F4E47 
 5070      494E5429 
 5070      00
 5071              		.text
 5074              	TestLanguage_IntSize:
 5075              		.stabd	46,0,0
 429:TestLanguage.c **** 
 430:TestLanguage.c **** static void TestLanguage_IntSize (void)
 431:TestLanguage.c **** {
 5077              	.LM812:
 5078              	.LFBB9:
 5079              	.LFB15:
 5080              		.cfi_startproc
 5081 27ba F30F1EFA 		endbr64
 5082 27be 55       		pushq	%rbp
 5083              		.cfi_def_cfa_offset 16
 5084              		.cfi_offset 6, -16
 5085 27bf 4889E5   		movq	%rsp, %rbp
 5086              		.cfi_def_cfa_register 6
 432:TestLanguage.c **** 	INT32 l;
 433:TestLanguage.c **** 	TestLanguage_TestValue(-128, -128, (CHAR*)"MIN(SHORTINT)", 14);
 5088              	.LM813:
 5089 27c2 B90E0000 		movl	$14, %ecx
 5089      00
 5090 27c7 488D1500 		leaq	.LC82(%rip), %rdx
 5090      000000
 5091 27ce BE80FFFF 		movl	$-128, %esi
 5091      FF
 5092 27d3 BF80FFFF 		movl	$-128, %edi
 5092      FF
 5093 27d8 E892E8FF 		call	TestLanguage_TestValue
 5093      FF
 434:TestLanguage.c **** 	TestLanguage_TestValue(127, 127, (CHAR*)"MAX(SHORTINT)", 14);
 5095              	.LM814:
 5096 27dd B90E0000 		movl	$14, %ecx
 5096      00
 5097 27e2 488D1500 		leaq	.LC83(%rip), %rdx
 5097      000000
 5098 27e9 BE7F0000 		movl	$127, %esi
 5098      00
 5099 27ee BF7F0000 		movl	$127, %edi
 5099      00
 5100 27f3 E877E8FF 		call	TestLanguage_TestValue
 5100      FF
 435:TestLanguage.c **** 	TestLanguage_TestValue((-32767-1), (-32767-1), (CHAR*)"MIN(INTEGER)", 13);
 5102              	.LM815:
 5103 27f8 B90D0000 		movl	$13, %ecx
 5103      00
 5104 27fd 488D1500 		leaq	.LC84(%rip), %rdx
 5104      000000
 5105 2804 BE0080FF 		movl	$-32768, %esi
 5105      FF
 5106 2809 BF0080FF 		movl	$-32768, %edi
 5106      FF
 5107 280e E85CE8FF 		call	TestLanguage_TestValue
 5107      FF
 436:TestLanguage.c **** 	TestLanguage_TestValue(32767, 32767, (CHAR*)"MAX(INTEGER)", 13);
 5109              	.LM816:
 5110 2813 B90D0000 		movl	$13, %ecx
 5110      00
 5111 2818 488D1500 		leaq	.LC85(%rip), %rdx
 5111      000000
 5112 281f BEFF7F00 		movl	$32767, %esi
 5112      00
 5113 2824 BFFF7F00 		movl	$32767, %edi
 5113      00
 5114 2829 E841E8FF 		call	TestLanguage_TestValue
 5114      FF
 437:TestLanguage.c **** 	TestLanguage_TestValue((-2147483647-1), (-2147483647-1), (CHAR*)"MIN(LONGINT)", 13);
 5116              	.LM817:
 5117 282e B90D0000 		movl	$13, %ecx
 5117      00
 5118 2833 488D1500 		leaq	.LC86(%rip), %rdx
 5118      000000
 5119 283a BE000000 		movl	$-2147483648, %esi
 5119      80
 5120 283f BF000000 		movl	$-2147483648, %edi
 5120      80
 5121 2844 E826E8FF 		call	TestLanguage_TestValue
 5121      FF
 438:TestLanguage.c **** 	TestLanguage_TestValue(2147483647, 2147483647, (CHAR*)"MAX(LONGINT)", 13);
 5123              	.LM818:
 5124 2849 B90D0000 		movl	$13, %ecx
 5124      00
 5125 284e 488D1500 		leaq	.LC87(%rip), %rdx
 5125      000000
 5126 2855 BEFFFFFF 		movl	$2147483647, %esi
 5126      7F
 5127 285a BFFFFFFF 		movl	$2147483647, %edi
 5127      7F
 5128 285f E80BE8FF 		call	TestLanguage_TestValue
 5128      FF
 439:TestLanguage.c **** }
 5130              	.LM819:
 5131 2864 90       		nop
 5132 2865 5D       		popq	%rbp
 5133              		.cfi_def_cfa 7, 8
 5134 2866 C3       		ret
 5135              		.cfi_endproc
 5136              	.LFE15:
 5138              	.Lscope9:
 5140              		.stabd	78,0,0
 5141              		.section	.rodata
 5142              	.LC88:
 5143 0401 54657374 		.string	"TestLanguage"
 5143      4C616E67 
 5143      75616765 
 5143      00
 5144              	.LC89:
 5145 040e 4C616E67 		.string	"Language tests successful."
 5145      75616765 
 5145      20746573 
 5145      74732073 
 5145      75636365 
 5146              		.text
 5150              		.globl	main
 5152              	main:
 5153              		.stabd	46,0,0
 440:TestLanguage.c **** 
 441:TestLanguage.c **** 
 442:TestLanguage.c **** export int main(int argc, char **argv)
 443:TestLanguage.c **** {
 5155              	.LM820:
 5156              	.LFBB10:
 5157              	.LFB16:
 5158              		.cfi_startproc
 5159 2867 F30F1EFA 		endbr64
 5160 286b 55       		pushq	%rbp
 5161              		.cfi_def_cfa_offset 16
 5162              		.cfi_offset 6, -16
 5163 286c 4889E5   		movq	%rsp, %rbp
 5164              		.cfi_def_cfa_register 6
 5165 286f 4883EC10 		subq	$16, %rsp
 5166 2873 897DFC   		movl	%edi, -4(%rbp)
 5167 2876 488975F0 		movq	%rsi, -16(%rbp)
 444:TestLanguage.c **** 	__INIT(argc, argv);
 5169              	.LM821:
 5170 287a 488D55F0 		leaq	-16(%rbp), %rdx
 5171 287e 8B45FC   		movl	-4(%rbp), %eax
 5172 2881 4889D6   		movq	%rdx, %rsi
 5173 2884 89C7     		movl	%eax, %edi
 5174 2886 E8000000 		call	Modules_Init@PLT
 5174      00
 445:TestLanguage.c **** 	__MODULE_IMPORT(Console);
 5176              	.LM822:
 5177 288b E8000000 		call	Console__init@PLT
 5177      00
 5178 2890 4889C7   		movq	%rax, %rdi
 5179 2893 B8000000 		movl	$0, %eax
 5179      00
 5180 2898 E8000000 		call	Heap_INCREF@PLT
 5180      00
 446:TestLanguage.c **** 	__REGMAIN("TestLanguage", 0);
 5182              	.LM823:
 5183 289d BE000000 		movl	$0, %esi
 5183      00
 5184 28a2 488D3D00 		leaq	.LC88(%rip), %rdi
 5184      000000
 5185 28a9 B8000000 		movl	$0, %eax
 5185      00
 5186 28ae E8000000 		call	Heap_REGMOD@PLT
 5186      00
 5187 28b3 48890500 		movq	%rax, m.2168(%rip)
 5187      000000
 447:TestLanguage.c **** /* BEGIN */
 448:TestLanguage.c **** 	TestLanguage_Shift();
 5189              	.LM824:
 5190 28ba E8C1D8FF 		call	TestLanguage_Shift
 5190      FF
 449:TestLanguage.c **** 	TestLanguage_DivMod();
 5192              	.LM825:
 5193 28bf E807E9FF 		call	TestLanguage_DivMod
 5193      FF
 450:TestLanguage.c **** 	TestLanguage_IntSize();
 5195              	.LM826:
 5196 28c4 E8F1FEFF 		call	TestLanguage_IntSize
 5196      FF
 451:TestLanguage.c **** 	TestLanguage_Abs();
 5198              	.LM827:
 5199 28c9 E88EFBFF 		call	TestLanguage_Abs
 5199      FF
 452:TestLanguage.c **** 	TestLanguage_Entier();
 5201              	.LM828:
 5202 28ce E8D4FCFF 		call	TestLanguage_Entier
 5202      FF
 453:TestLanguage.c **** 	Console_String((CHAR*)"Language tests successful.", 27);
 5204              	.LM829:
 5205 28d3 BE1B0000 		movl	$27, %esi
 5205      00
 5206 28d8 488D3D00 		leaq	.LC89(%rip), %rdi
 5206      000000
 5207 28df E8000000 		call	Console_String@PLT
 5207      00
 454:TestLanguage.c **** 	Console_Ln();
 5209              	.LM830:
 5210 28e4 E8000000 		call	Console_Ln@PLT
 5210      00
 455:TestLanguage.c **** 	__FINI;
 5212              	.LM831:
 5213 28e9 B8000000 		movl	$0, %eax
 5213      00
 5214 28ee E8000000 		call	Heap_FINALL@PLT
 5214      00
 5215 28f3 B8000000 		movl	$0, %eax
 5215      00
 456:TestLanguage.c **** }
 5217              	.LM832:
 5218 28f8 C9       		leave
 5219              		.cfi_def_cfa 7, 8
 5220 28f9 C3       		ret
 5221              		.cfi_endproc
 5222              	.LFE16:
 5227              	.Lscope10:
 5229              		.stabd	78,0,0
 5230              		.local	m.2168
 5231              		.comm	m.2168,8,8
 5233              		.section	.rodata
 5234 0429 00000000 		.align 8
 5234      000000
 5235              	.LC67:
 5236 0430 FFFFFF3F 		.long	1073741823
 5237 0434 E17A84BF 		.long	-1081836831
 5238              		.align 8
 5239              	.LC70:
 5240 0438 00000000 		.long	0
 5241 043c 00001440 		.long	1075052544
 5242              		.align 8
 5243              	.LC72:
 5244 0440 00000000 		.long	0
 5245 0444 00001640 		.long	1075183616
 5246              		.align 8
 5247              	.LC74:
 5248 0448 FBFFFF7F 		.long	2147483643
 5249 044c C2F51740 		.long	1075312066
 5250              		.align 8
 5251              	.LC76:
 5252 0450 00000000 		.long	0
 5253 0454 000014C0 		.long	-1072431104
 5254              		.align 8
 5255              	.LC78:
 5256 0458 00000000 		.long	0
 5257 045c 000016C0 		.long	-1072300032
 5258              		.align 8
 5259              	.LC80:
 5260 0460 FBFFFF7F 		.long	2147483643
 5261 0464 C2F517C0 		.long	-1072171582
 5262              		.text
 5264              	.Letext0:
 5265              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 5266              		.section	.note.GNU-stack,"",@progbits
 5267              		.section	.note.gnu.property,"a"
 5268              		.align 8
 5269 0000 04000000 		.long	 1f - 0f
 5270 0004 10000000 		.long	 4f - 1f
 5271 0008 05000000 		.long	 5
 5272              	0:
 5273 000c 474E5500 		.string	 "GNU"
 5274              	1:
 5275              		.align 8
 5276 0010 020000C0 		.long	 0xc0000002
 5277 0014 04000000 		.long	 3f - 2f
 5278              	2:
 5279 0018 03000000 		.long	 0x3
 5280              	3:
 5281 001c 00000000 		.align 8
 5282              	4:
