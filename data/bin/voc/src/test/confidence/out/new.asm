   1              		.file	"outtest.c"
   4              		.text
   5              	.Ltext0:
  49              		.local	outtest_r
  50              		.comm	outtest_r,4,4
  52              		.local	outtest_lr
  53              		.comm	outtest_lr,8,8
  55              		.local	outtest_cw
  56              		.comm	outtest_cw,2,2
  61              	outtest_wc:
  62              		.stabd	46,0,0
   1:outtest.c     **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:outtest.c     **** 
   3:outtest.c     **** #define SHORTINT INT16
   4:outtest.c     **** #define INTEGER  INT32
   5:outtest.c     **** #define LONGINT  INT64
   6:outtest.c     **** #define SET      UINT32
   7:outtest.c     **** 
   8:outtest.c     **** #include "SYSTEM.h"
   9:outtest.c     **** #include "Out.h"
  10:outtest.c     **** 
  11:outtest.c     **** 
  12:outtest.c     **** static REAL outtest_r;
  13:outtest.c     **** static LONGREAL outtest_lr;
  14:outtest.c     **** static INT16 outtest_cw;
  15:outtest.c     **** 
  16:outtest.c     **** 
  17:outtest.c     **** static void outtest_wc (CHAR c);
  18:outtest.c     **** static void outtest_wh (SYSTEM_BYTE *h, ADDRESS h__len);
  19:outtest.c     **** static void outtest_wi (INT64 i);
  20:outtest.c     **** static void outtest_wl (void);
  21:outtest.c     **** static void outtest_ws (CHAR *s, ADDRESS s__len);
  22:outtest.c     **** 
  23:outtest.c     **** 
  24:outtest.c     **** static void outtest_wc (CHAR c)
  25:outtest.c     **** {
  64              	.LM0:
  65              	.LFBB1:
  66              	.LFB7:
  67              		.cfi_startproc
  68 0000 F30F1EFA 		endbr64
  69 0004 55       		pushq	%rbp
  70              		.cfi_def_cfa_offset 16
  71              		.cfi_offset 6, -16
  72 0005 4889E5   		movq	%rsp, %rbp
  73              		.cfi_def_cfa_register 6
  74 0008 4883EC10 		subq	$16, %rsp
  75 000c 89F8     		movl	%edi, %eax
  76 000e 8845FC   		movb	%al, -4(%rbp)
  26:outtest.c     **** 	Out_Char(c);
  78              	.LM1:
  79 0011 0FB645FC 		movzbl	-4(%rbp), %eax
  80 0015 89C7     		movl	%eax, %edi
  81 0017 E8000000 		call	Out_Char@PLT
  81      00
  27:outtest.c     **** }
  83              	.LM2:
  84 001c 90       		nop
  85 001d C9       		leave
  86              		.cfi_def_cfa 7, 8
  87 001e C3       		ret
  88              		.cfi_endproc
  89              	.LFE7:
  91              	.Lscope1:
  93              		.stabd	78,0,0
  98              	outtest_ws:
  99              		.stabd	46,0,0
  28:outtest.c     **** 
  29:outtest.c     **** static void outtest_ws (CHAR *s, ADDRESS s__len)
  30:outtest.c     **** {
 101              	.LM3:
 102              	.LFBB2:
 103              	.LFB8:
 104              		.cfi_startproc
 105 001f F30F1EFA 		endbr64
 106 0023 55       		pushq	%rbp
 107              		.cfi_def_cfa_offset 16
 108              		.cfi_offset 6, -16
 109 0024 4889E5   		movq	%rsp, %rbp
 110              		.cfi_def_cfa_register 6
 111 0027 4883EC20 		subq	$32, %rsp
 112 002b 48897DE8 		movq	%rdi, -24(%rbp)
 113 002f 488975E0 		movq	%rsi, -32(%rbp)
 115              	.LM4:
 116 0033 64488B04 		movq	%fs:40, %rax
 116      25280000 
 116      00
 117 003c 488945F8 		movq	%rax, -8(%rbp)
 118 0040 31C0     		xorl	%eax, %eax
  31:outtest.c     **** 	__DUP(s, s__len, CHAR);
 120              	.LM5:
 121 0042 488B4DE0 		movq	-32(%rbp), %rcx
 122 0046 488B45E0 		movq	-32(%rbp), %rax
 123 004a 488D5008 		leaq	8(%rax), %rdx
 124 004e B8100000 		movl	$16, %eax
 124      00
 125 0053 4883E801 		subq	$1, %rax
 126 0057 4801D0   		addq	%rdx, %rax
 127 005a BF100000 		movl	$16, %edi
 127      00
 128 005f BA000000 		movl	$0, %edx
 128      00
 129 0064 48F7F7   		divq	%rdi
 130 0067 486BC010 		imulq	$16, %rax, %rax
 131 006b 4889C2   		movq	%rax, %rdx
 132 006e 4881E200 		andq	$-4096, %rdx
 132      F0FFFF
 133 0075 4889E6   		movq	%rsp, %rsi
 134 0078 4829D6   		subq	%rdx, %rsi
 135 007b 4889F2   		movq	%rsi, %rdx
 136              	.L3:
 137 007e 4839D4   		cmpq	%rdx, %rsp
 138 0081 7412     		je	.L4
 139 0083 4881EC00 		subq	$4096, %rsp
 139      100000
 140 008a 48838C24 		orq	$0, 4088(%rsp)
 140      F80F0000 
 140      00
 141 0093 EBE9     		jmp	.L3
 142              	.L4:
 143 0095 4889C2   		movq	%rax, %rdx
 144 0098 81E2FF0F 		andl	$4095, %edx
 144      0000
 145 009e 4829D4   		subq	%rdx, %rsp
 146 00a1 4889C2   		movq	%rax, %rdx
 147 00a4 81E2FF0F 		andl	$4095, %edx
 147      0000
 148 00aa 4885D2   		testq	%rdx, %rdx
 149 00ad 7410     		je	.L5
 150 00af 25FF0F00 		andl	$4095, %eax
 150      00
 151 00b4 4883E808 		subq	$8, %rax
 152 00b8 4801E0   		addq	%rsp, %rax
 153 00bb 48830800 		orq	$0, (%rax)
 154              	.L5:
 155 00bf 4889E0   		movq	%rsp, %rax
 156 00c2 4883C00F 		addq	$15, %rax
 157 00c6 48C1E804 		shrq	$4, %rax
 158 00ca 48C1E004 		salq	$4, %rax
 159 00ce 4889C7   		movq	%rax, %rdi
 160 00d1 488B45E8 		movq	-24(%rbp), %rax
 161 00d5 4889CA   		movq	%rcx, %rdx
 162 00d8 4889C6   		movq	%rax, %rsi
 163 00db E8000000 		call	memcpy@PLT
 163      00
 164 00e0 488945E8 		movq	%rax, -24(%rbp)
  32:outtest.c     **** 	Out_String(s, s__len);
 166              	.LM6:
 167 00e4 488B55E0 		movq	-32(%rbp), %rdx
 168 00e8 488B45E8 		movq	-24(%rbp), %rax
 169 00ec 4889D6   		movq	%rdx, %rsi
 170 00ef 4889C7   		movq	%rax, %rdi
 171 00f2 E8000000 		call	Out_String@PLT
 171      00
  33:outtest.c     **** 	__DEL(s);
  34:outtest.c     **** }
 173              	.LM7:
 174 00f7 90       		nop
 175 00f8 488B45F8 		movq	-8(%rbp), %rax
 176 00fc 64483304 		xorq	%fs:40, %rax
 176      25280000 
 176      00
 177 0105 7405     		je	.L6
 178 0107 E8000000 		call	__stack_chk_fail@PLT
 178      00
 179              	.L6:
 180 010c C9       		leave
 181              		.cfi_def_cfa 7, 8
 182 010d C3       		ret
 183              		.cfi_endproc
 184              	.LFE8:
 186              	.Lscope2:
 188              		.stabd	78,0,0
 192              	outtest_wi:
 193              		.stabd	46,0,0
  35:outtest.c     **** 
  36:outtest.c     **** static void outtest_wi (INT64 i)
  37:outtest.c     **** {
 195              	.LM8:
 196              	.LFBB3:
 197              	.LFB9:
 198              		.cfi_startproc
 199 010e F30F1EFA 		endbr64
 200 0112 55       		pushq	%rbp
 201              		.cfi_def_cfa_offset 16
 202              		.cfi_offset 6, -16
 203 0113 4889E5   		movq	%rsp, %rbp
 204              		.cfi_def_cfa_register 6
 205 0116 4883EC10 		subq	$16, %rsp
 206 011a 48897DF8 		movq	%rdi, -8(%rbp)
  38:outtest.c     **** 	Out_Int(i, 1);
 208              	.LM9:
 209 011e 488B45F8 		movq	-8(%rbp), %rax
 210 0122 BE010000 		movl	$1, %esi
 210      00
 211 0127 4889C7   		movq	%rax, %rdi
 212 012a E8000000 		call	Out_Int@PLT
 212      00
  39:outtest.c     **** }
 214              	.LM10:
 215 012f 90       		nop
 216 0130 C9       		leave
 217              		.cfi_def_cfa 7, 8
 218 0131 C3       		ret
 219              		.cfi_endproc
 220              	.LFE9:
 222              	.Lscope3:
 224              		.stabd	78,0,0
 227              	outtest_wl:
 228              		.stabd	46,0,0
  40:outtest.c     **** 
  41:outtest.c     **** static void outtest_wl (void)
  42:outtest.c     **** {
 230              	.LM11:
 231              	.LFBB4:
 232              	.LFB10:
 233              		.cfi_startproc
 234 0132 F30F1EFA 		endbr64
 235 0136 55       		pushq	%rbp
 236              		.cfi_def_cfa_offset 16
 237              		.cfi_offset 6, -16
 238 0137 4889E5   		movq	%rsp, %rbp
 239              		.cfi_def_cfa_register 6
  43:outtest.c     **** 	Out_Ln();
 241              	.LM12:
 242 013a E8000000 		call	Out_Ln@PLT
 242      00
  44:outtest.c     **** }
 244              	.LM13:
 245 013f 90       		nop
 246 0140 5D       		popq	%rbp
 247              		.cfi_def_cfa 7, 8
 248 0141 C3       		ret
 249              		.cfi_endproc
 250              	.LFE10:
 252              	.Lscope4:
 254              		.stabd	78,0,0
 259              	outtest_wh:
 260              		.stabd	46,0,0
  45:outtest.c     **** 
  46:outtest.c     **** static void outtest_wh (SYSTEM_BYTE *h, ADDRESS h__len)
  47:outtest.c     **** {
 262              	.LM14:
 263              	.LFBB5:
 264              	.LFB11:
 265              		.cfi_startproc
 266 0142 F30F1EFA 		endbr64
 267 0146 55       		pushq	%rbp
 268              		.cfi_def_cfa_offset 16
 269              		.cfi_offset 6, -16
 270 0147 4889E5   		movq	%rsp, %rbp
 271              		.cfi_def_cfa_register 6
 272 014a 4883EC20 		subq	$32, %rsp
 273 014e 48897DE8 		movq	%rdi, -24(%rbp)
 274 0152 488975E0 		movq	%rsi, -32(%rbp)
  48:outtest.c     **** 	INT32 i;
  49:outtest.c     **** 	INT8 b;
  50:outtest.c     **** 	i = (INT32)h__len;
 276              	.LM15:
 277 0156 488B45E0 		movq	-32(%rbp), %rax
 278 015a 8945FC   		movl	%eax, -4(%rbp)
  51:outtest.c     **** 	while (i > 0) {
 280              	.LM16:
 281 015d E9A60000 		jmp	.L10
 281      00
 282              	.L16:
  52:outtest.c     **** 		i -= 1;
 284              	.LM17:
 285 0162 836DFC01 		subl	$1, -4(%rbp)
  53:outtest.c     **** 		b = __VAL(INT8, h[__X(i, h__len)]);
 287              	.LM18:
 288 0166 8B45FC   		movl	-4(%rbp), %eax
 289 0169 4898     		cltq
 290 016b 483945E0 		cmpq	%rax, -32(%rbp)
 291 016f 7E07     		jle	.L11
 293              	.LM19:
 294 0171 8B45FC   		movl	-4(%rbp), %eax
 295 0174 4898     		cltq
 296 0176 EB0F     		jmp	.L12
 297              	.L11:
 299              	.LM20:
 300 0178 BFFEFFFF 		movl	$-2, %edi
 300      FF
 301 017d E8000000 		call	Modules_Halt@PLT
 301      00
 302 0182 B8000000 		movl	$0, %eax
 302      00
 303              	.L12:
 305              	.LM21:
 306 0187 488B55E8 		movq	-24(%rbp), %rdx
 307 018b 4801D0   		addq	%rdx, %rax
 309              	.LM22:
 310 018e 0FB600   		movzbl	(%rax), %eax
 311 0191 8845FB   		movb	%al, -5(%rbp)
  54:outtest.c     **** 		if (__MASK(__ASHR(b, 4), -16) < 10) {
 313              	.LM23:
 314 0194 0FB645FB 		movzbl	-5(%rbp), %eax
 315 0198 C0F804   		sarb	$4, %al
 316 019b 480FBEC0 		movsbq	%al, %rax
 317 019f 83E00F   		andl	$15, %eax
 319              	.LM24:
 320 01a2 4883F809 		cmpq	$9, %rax
 321 01a6 7F16     		jg	.L13
  55:outtest.c     **** 			outtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 48));
 323              	.LM25:
 324 01a8 0FB645FB 		movzbl	-5(%rbp), %eax
 325 01ac C0E804   		shrb	$4, %al
 327              	.LM26:
 328 01af 83C030   		addl	$48, %eax
 330              	.LM27:
 331 01b2 0FB6C0   		movzbl	%al, %eax
 332 01b5 89C7     		movl	%eax, %edi
 333 01b7 E844FEFF 		call	outtest_wc
 333      FF
 334 01bc EB14     		jmp	.L14
 335              	.L13:
  56:outtest.c     **** 		} else {
  57:outtest.c     **** 			outtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 55));
 337              	.LM28:
 338 01be 0FB645FB 		movzbl	-5(%rbp), %eax
 339 01c2 C0E804   		shrb	$4, %al
 341              	.LM29:
 342 01c5 83C037   		addl	$55, %eax
 344              	.LM30:
 345 01c8 0FB6C0   		movzbl	%al, %eax
 346 01cb 89C7     		movl	%eax, %edi
 347 01cd E82EFEFF 		call	outtest_wc
 347      FF
 348              	.L14:
  58:outtest.c     **** 		}
  59:outtest.c     **** 		if (__MASK(b, -16) < 10) {
 350              	.LM31:
 351 01d2 0FBE45FB 		movsbl	-5(%rbp), %eax
 352 01d6 83E00F   		andl	$15, %eax
 354              	.LM32:
 355 01d9 83F809   		cmpl	$9, %eax
 356 01dc 7F16     		jg	.L15
  60:outtest.c     **** 			outtest_wc((CHAR)(__MASK(b, -16) + 48));
 358              	.LM33:
 359 01de 0FB645FB 		movzbl	-5(%rbp), %eax
 360 01e2 83E00F   		andl	$15, %eax
 362              	.LM34:
 363 01e5 83C030   		addl	$48, %eax
 365              	.LM35:
 366 01e8 0FB6C0   		movzbl	%al, %eax
 367 01eb 89C7     		movl	%eax, %edi
 368 01ed E80EFEFF 		call	outtest_wc
 368      FF
 369 01f2 EB14     		jmp	.L10
 370              	.L15:
  61:outtest.c     **** 		} else {
  62:outtest.c     **** 			outtest_wc((CHAR)(__MASK(b, -16) + 55));
 372              	.LM36:
 373 01f4 0FB645FB 		movzbl	-5(%rbp), %eax
 374 01f8 83E00F   		andl	$15, %eax
 376              	.LM37:
 377 01fb 83C037   		addl	$55, %eax
 379              	.LM38:
 380 01fe 0FB6C0   		movzbl	%al, %eax
 381 0201 89C7     		movl	%eax, %edi
 382 0203 E8F8FDFF 		call	outtest_wc
 382      FF
 383              	.L10:
  51:outtest.c     **** 		i -= 1;
 385              	.LM39:
 386 0208 837DFC00 		cmpl	$0, -4(%rbp)
 387 020c 0F8F50FF 		jg	.L16
 387      FFFF
  63:outtest.c     **** 		}
  64:outtest.c     **** 	}
  65:outtest.c     **** }
 389              	.LM40:
 390 0212 90       		nop
 391 0213 90       		nop
 392 0214 C9       		leave
 393              		.cfi_def_cfa 7, 8
 394 0215 C3       		ret
 395              		.cfi_endproc
 396              	.LFE11:
 402              	.Lscope5:
 404              		.stabd	78,0,0
 405              		.section	.rodata
 406              	.LC0:
 407 0000 6F757474 		.string	"outtest"
 407      65737400 
 408              		.align 8
 409              	.LC1:
 410 0008 5265616C 		.string	"Real number hex representation."
 410      206E756D 
 410      62657220 
 410      68657820 
 410      72657072 
 411              	.LC3:
 412 0028 20312E30 		.string	" 1.0D0:                "
 412      44303A20 
 412      20202020 
 412      20202020 
 412      20202020 
 413              	.LC5:
 414 0040 20312E31 		.string	" 1.1D0:                "
 414      44303A20 
 414      20202020 
 414      20202020 
 414      20202020 
 415              	.LC7:
 416 0058 20322E31 		.string	" 2.1D0:                "
 416      44303A20 
 416      20202020 
 416      20202020 
 416      20202020 
 417              	.LC9:
 418 0070 2D312E31 		.string	"-1.1D0:                "
 418      44303A20 
 418      20202020 
 418      20202020 
 418      20202020 
 419              	.LC11:
 420 0088 20312E31 		.string	" 1.1D3:                "
 420      44333A20 
 420      20202020 
 420      20202020 
 420      20202020 
 421              	.LC13:
 422 00a0 20312E31 		.string	" 1.1D-3:               "
 422      442D333A 
 422      20202020 
 422      20202020 
 422      20202020 
 423              	.LC15:
 424 00b8 20312E32 		.string	" 1.2345678987654321D3: "
 424      33343536 
 424      37383938 
 424      37363534 
 424      33323144 
 425              	.LC17:
 426 00d0 20302E30 		.string	" 0.0:                  "
 426      3A202020 
 426      20202020 
 426      20202020 
 426      20202020 
 427              	.LC19:
 428 00e8 20302E30 		.string	" 0.000123D0:           "
 428      30303132 
 428      3344303A 
 428      20202020 
 428      20202020 
 429              	.LC20:
 430 0100 20312F30 		.string	" 1/0.0:                "
 430      2E303A20 
 430      20202020 
 430      20202020 
 430      20202020 
 431              	.LC22:
 432 0118 2D312F30 		.string	"-1/0.0:                "
 432      2E303A20 
 432      20202020 
 432      20202020 
 432      20202020 
 433              	.LC24:
 434 0130 20312E30 		.string	" 1.0E0:                "
 434      45303A20 
 434      20202020 
 434      20202020 
 434      20202020 
 435              	.LC26:
 436 0148 20312E31 		.string	" 1.1E0:                "
 436      45303A20 
 436      20202020 
 436      20202020 
 436      20202020 
 437              	.LC28:
 438 0160 20322E31 		.string	" 2.1E0:                "
 438      45303A20 
 438      20202020 
 438      20202020 
 438      20202020 
 439              	.LC30:
 440 0178 2D312E31 		.string	"-1.1E0:                "
 440      45303A20 
 440      20202020 
 440      20202020 
 440      20202020 
 441              	.LC32:
 442 0190 20312E31 		.string	" 1.1E3:                "
 442      45333A20 
 442      20202020 
 442      20202020 
 442      20202020 
 443              	.LC34:
 444 01a8 20312E31 		.string	" 1.1E-3:               "
 444      452D333A 
 444      20202020 
 444      20202020 
 444      20202020 
 445              	.LC36:
 446 01c0 20312E32 		.string	" 1.2345678987654321E3: "
 446      33343536 
 446      37383938 
 446      37363534 
 446      33323145 
 447              	.LC39:
 448 01d8 20302E30 		.string	" 0.000123E0:           "
 448      30303132 
 448      3345303A 
 448      20202020 
 448      20202020 
 449              	.LC41:
 450 01f0 4F757420 		.string	"Out module tests."
 450      6D6F6475 
 450      6C652074 
 450      65737473 
 450      2E00
 451              	.LC42:
 452 0202 53495A45 		.string	"SIZE(INTEGER) = "
 452      28494E54 
 452      45474552 
 452      29203D20 
 452      00
 453              	.LC43:
 454 0213 54657374 		.string	"Testing LONGREAL."
 454      696E6720 
 454      4C4F4E47 
 454      5245414C 
 454      2E00
 455 0225 000000   		.align 8
 456              	.LC44:
 457 0228 20202020 		.string	"                                1         2         3         4"
 457      20202020 
 457      20202020 
 457      20202020 
 457      20202020 
 458              		.align 8
 459              	.LC45:
 460 0268 20202020 		.string	"                       1234567890123456789012345678901234567890"
 460      20202020 
 460      20202020 
 460      20202020 
 460      20202020 
 461              	.LC46:
 462 02a8 20302E30 		.string	" 0.0/0.0:              "
 462      2F302E30 
 462      3A202020 
 462      20202020 
 462      20202020 
 463              	.LC47:
 464 02c0 54657374 		.string	"Testing REAL."
 464      696E6720 
 464      5245414C 
 464      2E00
 465 02ce 0000     		.align 8
 466              	.LC48:
 467 02d0 20202020 		.string	"                                1         2         3"
 467      20202020 
 467      20202020 
 467      20202020 
 467      20202020 
 468 0306 0000     		.align 8
 469              	.LC49:
 470 0308 20202020 		.string	"                       123456789012345678901234567890"
 470      20202020 
 470      20202020 
 470      20202020 
 470      20202020 
 471              		.text
 475              		.globl	main
 477              	main:
 478              		.stabd	46,0,0
  66:outtest.c     **** 
  67:outtest.c     **** 
  68:outtest.c     **** export int main(int argc, char **argv)
  69:outtest.c     **** {
 480              	.LM41:
 481              	.LFBB6:
 482              	.LFB12:
 483              		.cfi_startproc
 484 0216 F30F1EFA 		endbr64
 485 021a 55       		pushq	%rbp
 486              		.cfi_def_cfa_offset 16
 487              		.cfi_offset 6, -16
 488 021b 4889E5   		movq	%rsp, %rbp
 489              		.cfi_def_cfa_register 6
 490 021e 4883EC10 		subq	$16, %rsp
 491 0222 897DFC   		movl	%edi, -4(%rbp)
 492 0225 488975F0 		movq	%rsi, -16(%rbp)
  70:outtest.c     **** 	__INIT(argc, argv);
 494              	.LM42:
 495 0229 488D55F0 		leaq	-16(%rbp), %rdx
 496 022d 8B45FC   		movl	-4(%rbp), %eax
 497 0230 4889D6   		movq	%rdx, %rsi
 498 0233 89C7     		movl	%eax, %edi
 499 0235 E8000000 		call	Modules_Init@PLT
 499      00
  71:outtest.c     **** 	__MODULE_IMPORT(Out);
 501              	.LM43:
 502 023a E8000000 		call	Out__init@PLT
 502      00
 503 023f 4889C7   		movq	%rax, %rdi
 504 0242 B8000000 		movl	$0, %eax
 504      00
 505 0247 E8000000 		call	Heap_INCREF@PLT
 505      00
  72:outtest.c     **** 	__REGMAIN("outtest", 0);
 507              	.LM44:
 508 024c BE000000 		movl	$0, %esi
 508      00
 509 0251 488D3D00 		leaq	.LC0(%rip), %rdi
 509      000000
 510 0258 B8000000 		movl	$0, %eax
 510      00
 511 025d E8000000 		call	Heap_REGMOD@PLT
 511      00
 512 0262 48890500 		movq	%rax, m.2091(%rip)
 512      000000
  73:outtest.c     **** /* BEGIN */
  74:outtest.c     **** 	outtest_ws((CHAR*)"Real number hex representation.", 32);
 514              	.LM45:
 515 0269 BE200000 		movl	$32, %esi
 515      00
 516 026e 488D3D00 		leaq	.LC1(%rip), %rdi
 516      000000
 517 0275 E8A5FDFF 		call	outtest_ws
 517      FF
  75:outtest.c     **** 	outtest_wl();
 519              	.LM46:
 520 027a E8B3FEFF 		call	outtest_wl
 520      FF
  76:outtest.c     **** 	outtest_lr = (LONGREAL)1;
 522              	.LM47:
 523 027f F20F1005 		movsd	.LC2(%rip), %xmm0
 523      00000000 
 524 0287 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 524      00000000 
  77:outtest.c     **** 	outtest_ws((CHAR*)" 1.0D0:                ", 24);
 526              	.LM48:
 527 028f BE180000 		movl	$24, %esi
 527      00
 528 0294 488D3D00 		leaq	.LC3(%rip), %rdi
 528      000000
 529 029b E87FFDFF 		call	outtest_ws
 529      FF
  78:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 531              	.LM49:
 532 02a0 BE080000 		movl	$8, %esi
 532      00
 533 02a5 488D3D00 		leaq	outtest_lr(%rip), %rdi
 533      000000
 534 02ac E891FEFF 		call	outtest_wh
 534      FF
  79:outtest.c     **** 	outtest_wl();
 536              	.LM50:
 537 02b1 E87CFEFF 		call	outtest_wl
 537      FF
  80:outtest.c     **** 	outtest_lr =   1.10000000000000e+000;
 539              	.LM51:
 540 02b6 F20F1005 		movsd	.LC4(%rip), %xmm0
 540      00000000 
 541 02be F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 541      00000000 
  81:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D0:                ", 24);
 543              	.LM52:
 544 02c6 BE180000 		movl	$24, %esi
 544      00
 545 02cb 488D3D00 		leaq	.LC5(%rip), %rdi
 545      000000
 546 02d2 E848FDFF 		call	outtest_ws
 546      FF
  82:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 548              	.LM53:
 549 02d7 BE080000 		movl	$8, %esi
 549      00
 550 02dc 488D3D00 		leaq	outtest_lr(%rip), %rdi
 550      000000
 551 02e3 E85AFEFF 		call	outtest_wh
 551      FF
  83:outtest.c     **** 	outtest_wl();
 553              	.LM54:
 554 02e8 E845FEFF 		call	outtest_wl
 554      FF
  84:outtest.c     **** 	outtest_lr =   2.10000000000000e+000;
 556              	.LM55:
 557 02ed F20F1005 		movsd	.LC6(%rip), %xmm0
 557      00000000 
 558 02f5 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 558      00000000 
  85:outtest.c     **** 	outtest_ws((CHAR*)" 2.1D0:                ", 24);
 560              	.LM56:
 561 02fd BE180000 		movl	$24, %esi
 561      00
 562 0302 488D3D00 		leaq	.LC7(%rip), %rdi
 562      000000
 563 0309 E811FDFF 		call	outtest_ws
 563      FF
  86:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 565              	.LM57:
 566 030e BE080000 		movl	$8, %esi
 566      00
 567 0313 488D3D00 		leaq	outtest_lr(%rip), %rdi
 567      000000
 568 031a E823FEFF 		call	outtest_wh
 568      FF
  87:outtest.c     **** 	outtest_wl();
 570              	.LM58:
 571 031f E80EFEFF 		call	outtest_wl
 571      FF
  88:outtest.c     **** 	outtest_lr =  -1.10000000000000e+000;
 573              	.LM59:
 574 0324 F20F1005 		movsd	.LC8(%rip), %xmm0
 574      00000000 
 575 032c F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 575      00000000 
  89:outtest.c     **** 	outtest_ws((CHAR*)"-1.1D0:                ", 24);
 577              	.LM60:
 578 0334 BE180000 		movl	$24, %esi
 578      00
 579 0339 488D3D00 		leaq	.LC9(%rip), %rdi
 579      000000
 580 0340 E8DAFCFF 		call	outtest_ws
 580      FF
  90:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 582              	.LM61:
 583 0345 BE080000 		movl	$8, %esi
 583      00
 584 034a 488D3D00 		leaq	outtest_lr(%rip), %rdi
 584      000000
 585 0351 E8ECFDFF 		call	outtest_wh
 585      FF
  91:outtest.c     **** 	outtest_wl();
 587              	.LM62:
 588 0356 E8D7FDFF 		call	outtest_wl
 588      FF
  92:outtest.c     **** 	outtest_lr =   1.10000000000000e+003;
 590              	.LM63:
 591 035b F20F1005 		movsd	.LC10(%rip), %xmm0
 591      00000000 
 592 0363 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 592      00000000 
  93:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D3:                ", 24);
 594              	.LM64:
 595 036b BE180000 		movl	$24, %esi
 595      00
 596 0370 488D3D00 		leaq	.LC11(%rip), %rdi
 596      000000
 597 0377 E8A3FCFF 		call	outtest_ws
 597      FF
  94:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 599              	.LM65:
 600 037c BE080000 		movl	$8, %esi
 600      00
 601 0381 488D3D00 		leaq	outtest_lr(%rip), %rdi
 601      000000
 602 0388 E8B5FDFF 		call	outtest_wh
 602      FF
  95:outtest.c     **** 	outtest_wl();
 604              	.LM66:
 605 038d E8A0FDFF 		call	outtest_wl
 605      FF
  96:outtest.c     **** 	outtest_lr =   1.10000000000000e-003;
 607              	.LM67:
 608 0392 F20F1005 		movsd	.LC12(%rip), %xmm0
 608      00000000 
 609 039a F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 609      00000000 
  97:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
 611              	.LM68:
 612 03a2 BE180000 		movl	$24, %esi
 612      00
 613 03a7 488D3D00 		leaq	.LC13(%rip), %rdi
 613      000000
 614 03ae E86CFCFF 		call	outtest_ws
 614      FF
  98:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 616              	.LM69:
 617 03b3 BE080000 		movl	$8, %esi
 617      00
 618 03b8 488D3D00 		leaq	outtest_lr(%rip), %rdi
 618      000000
 619 03bf E87EFDFF 		call	outtest_wh
 619      FF
  99:outtest.c     **** 	outtest_wl();
 621              	.LM70:
 622 03c4 E869FDFF 		call	outtest_wl
 622      FF
 100:outtest.c     **** 	outtest_lr =   1.23456789876543e+003;
 624              	.LM71:
 625 03c9 F20F1005 		movsd	.LC14(%rip), %xmm0
 625      00000000 
 626 03d1 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 626      00000000 
 101:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
 628              	.LM72:
 629 03d9 BE180000 		movl	$24, %esi
 629      00
 630 03de 488D3D00 		leaq	.LC15(%rip), %rdi
 630      000000
 631 03e5 E835FCFF 		call	outtest_ws
 631      FF
 102:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 633              	.LM73:
 634 03ea BE080000 		movl	$8, %esi
 634      00
 635 03ef 488D3D00 		leaq	outtest_lr(%rip), %rdi
 635      000000
 636 03f6 E847FDFF 		call	outtest_wh
 636      FF
 103:outtest.c     **** 	outtest_wl();
 638              	.LM74:
 639 03fb E832FDFF 		call	outtest_wl
 639      FF
 104:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 641              	.LM75:
 642 0400 660FEFC0 		pxor	%xmm0, %xmm0
 643 0404 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 643      00000000 
 105:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 645              	.LM76:
 646 040c BE180000 		movl	$24, %esi
 646      00
 647 0411 488D3D00 		leaq	.LC17(%rip), %rdi
 647      000000
 648 0418 E802FCFF 		call	outtest_ws
 648      FF
 106:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 650              	.LM77:
 651 041d BE080000 		movl	$8, %esi
 651      00
 652 0422 488D3D00 		leaq	outtest_lr(%rip), %rdi
 652      000000
 653 0429 E814FDFF 		call	outtest_wh
 653      FF
 107:outtest.c     **** 	outtest_wl();
 655              	.LM78:
 656 042e E8FFFCFF 		call	outtest_wl
 656      FF
 108:outtest.c     **** 	outtest_lr =   1.23000000000000e-004;
 658              	.LM79:
 659 0433 F20F1005 		movsd	.LC18(%rip), %xmm0
 659      00000000 
 660 043b F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 660      00000000 
 109:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
 662              	.LM80:
 663 0443 BE180000 		movl	$24, %esi
 663      00
 664 0448 488D3D00 		leaq	.LC19(%rip), %rdi
 664      000000
 665 044f E8CBFBFF 		call	outtest_ws
 665      FF
 110:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 667              	.LM81:
 668 0454 BE080000 		movl	$8, %esi
 668      00
 669 0459 488D3D00 		leaq	outtest_lr(%rip), %rdi
 669      000000
 670 0460 E8DDFCFF 		call	outtest_wh
 670      FF
 111:outtest.c     **** 	outtest_wl();
 672              	.LM82:
 673 0465 E8C8FCFF 		call	outtest_wl
 673      FF
 112:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 675              	.LM83:
 676 046a 660FEFC0 		pxor	%xmm0, %xmm0
 677 046e F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 677      00000000 
 113:outtest.c     **** 	outtest_lr = (LONGREAL)1 / outtest_lr;
 679              	.LM84:
 680 0476 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 680      00000000 
 681 047e F20F1005 		movsd	.LC2(%rip), %xmm0
 681      00000000 
 682 0486 F20F5EC1 		divsd	%xmm1, %xmm0
 684              	.LM85:
 685 048a F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 685      00000000 
 114:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 687              	.LM86:
 688 0492 BE180000 		movl	$24, %esi
 688      00
 689 0497 488D3D00 		leaq	.LC20(%rip), %rdi
 689      000000
 690 049e E87CFBFF 		call	outtest_ws
 690      FF
 115:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 692              	.LM87:
 693 04a3 BE080000 		movl	$8, %esi
 693      00
 694 04a8 488D3D00 		leaq	outtest_lr(%rip), %rdi
 694      000000
 695 04af E88EFCFF 		call	outtest_wh
 695      FF
 116:outtest.c     **** 	outtest_wl();
 697              	.LM88:
 698 04b4 E879FCFF 		call	outtest_wl
 698      FF
 117:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 700              	.LM89:
 701 04b9 660FEFC0 		pxor	%xmm0, %xmm0
 702 04bd F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 702      00000000 
 118:outtest.c     **** 	outtest_lr = -((LONGREAL)1 / outtest_lr);
 704              	.LM90:
 705 04c5 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 705      00000000 
 706 04cd F20F1005 		movsd	.LC2(%rip), %xmm0
 706      00000000 
 707 04d5 F20F5EC1 		divsd	%xmm1, %xmm0
 709              	.LM91:
 710 04d9 F30F7E0D 		movq	.LC21(%rip), %xmm1
 710      00000000 
 711 04e1 660F57C1 		xorpd	%xmm1, %xmm0
 713              	.LM92:
 714 04e5 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 714      00000000 
 119:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 716              	.LM93:
 717 04ed BE180000 		movl	$24, %esi
 717      00
 718 04f2 488D3D00 		leaq	.LC22(%rip), %rdi
 718      000000
 719 04f9 E821FBFF 		call	outtest_ws
 719      FF
 120:outtest.c     **** 	outtest_wh((void*)&outtest_lr, 8);
 721              	.LM94:
 722 04fe BE080000 		movl	$8, %esi
 722      00
 723 0503 488D3D00 		leaq	outtest_lr(%rip), %rdi
 723      000000
 724 050a E833FCFF 		call	outtest_wh
 724      FF
 121:outtest.c     **** 	outtest_wl();
 726              	.LM95:
 727 050f E81EFCFF 		call	outtest_wl
 727      FF
 122:outtest.c     **** 	outtest_wl();
 729              	.LM96:
 730 0514 E819FCFF 		call	outtest_wl
 730      FF
 123:outtest.c     **** 	outtest_r = (REAL)1;
 732              	.LM97:
 733 0519 F30F1005 		movss	.LC23(%rip), %xmm0
 733      00000000 
 734 0521 F30F1105 		movss	%xmm0, outtest_r(%rip)
 734      00000000 
 124:outtest.c     **** 	outtest_ws((CHAR*)" 1.0E0:                ", 24);
 736              	.LM98:
 737 0529 BE180000 		movl	$24, %esi
 737      00
 738 052e 488D3D00 		leaq	.LC24(%rip), %rdi
 738      000000
 739 0535 E8E5FAFF 		call	outtest_ws
 739      FF
 125:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 741              	.LM99:
 742 053a BE040000 		movl	$4, %esi
 742      00
 743 053f 488D3D00 		leaq	outtest_r(%rip), %rdi
 743      000000
 744 0546 E8F7FBFF 		call	outtest_wh
 744      FF
 126:outtest.c     **** 	outtest_wl();
 746              	.LM100:
 747 054b E8E2FBFF 		call	outtest_wl
 747      FF
 127:outtest.c     **** 	outtest_r =   1.1000000e+000;
 749              	.LM101:
 750 0550 F30F1005 		movss	.LC25(%rip), %xmm0
 750      00000000 
 751 0558 F30F1105 		movss	%xmm0, outtest_r(%rip)
 751      00000000 
 128:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E0:                ", 24);
 753              	.LM102:
 754 0560 BE180000 		movl	$24, %esi
 754      00
 755 0565 488D3D00 		leaq	.LC26(%rip), %rdi
 755      000000
 756 056c E8AEFAFF 		call	outtest_ws
 756      FF
 129:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 758              	.LM103:
 759 0571 BE040000 		movl	$4, %esi
 759      00
 760 0576 488D3D00 		leaq	outtest_r(%rip), %rdi
 760      000000
 761 057d E8C0FBFF 		call	outtest_wh
 761      FF
 130:outtest.c     **** 	outtest_wl();
 763              	.LM104:
 764 0582 E8ABFBFF 		call	outtest_wl
 764      FF
 131:outtest.c     **** 	outtest_r =   2.0999999e+000;
 766              	.LM105:
 767 0587 F30F1005 		movss	.LC27(%rip), %xmm0
 767      00000000 
 768 058f F30F1105 		movss	%xmm0, outtest_r(%rip)
 768      00000000 
 132:outtest.c     **** 	outtest_ws((CHAR*)" 2.1E0:                ", 24);
 770              	.LM106:
 771 0597 BE180000 		movl	$24, %esi
 771      00
 772 059c 488D3D00 		leaq	.LC28(%rip), %rdi
 772      000000
 773 05a3 E877FAFF 		call	outtest_ws
 773      FF
 133:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 775              	.LM107:
 776 05a8 BE040000 		movl	$4, %esi
 776      00
 777 05ad 488D3D00 		leaq	outtest_r(%rip), %rdi
 777      000000
 778 05b4 E889FBFF 		call	outtest_wh
 778      FF
 134:outtest.c     **** 	outtest_wl();
 780              	.LM108:
 781 05b9 E874FBFF 		call	outtest_wl
 781      FF
 135:outtest.c     **** 	outtest_r =  -1.1000000e+000;
 783              	.LM109:
 784 05be F30F1005 		movss	.LC29(%rip), %xmm0
 784      00000000 
 785 05c6 F30F1105 		movss	%xmm0, outtest_r(%rip)
 785      00000000 
 136:outtest.c     **** 	outtest_ws((CHAR*)"-1.1E0:                ", 24);
 787              	.LM110:
 788 05ce BE180000 		movl	$24, %esi
 788      00
 789 05d3 488D3D00 		leaq	.LC30(%rip), %rdi
 789      000000
 790 05da E840FAFF 		call	outtest_ws
 790      FF
 137:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 792              	.LM111:
 793 05df BE040000 		movl	$4, %esi
 793      00
 794 05e4 488D3D00 		leaq	outtest_r(%rip), %rdi
 794      000000
 795 05eb E852FBFF 		call	outtest_wh
 795      FF
 138:outtest.c     **** 	outtest_wl();
 797              	.LM112:
 798 05f0 E83DFBFF 		call	outtest_wl
 798      FF
 139:outtest.c     **** 	outtest_r = (REAL)1100;
 800              	.LM113:
 801 05f5 F30F1005 		movss	.LC31(%rip), %xmm0
 801      00000000 
 802 05fd F30F1105 		movss	%xmm0, outtest_r(%rip)
 802      00000000 
 140:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E3:                ", 24);
 804              	.LM114:
 805 0605 BE180000 		movl	$24, %esi
 805      00
 806 060a 488D3D00 		leaq	.LC32(%rip), %rdi
 806      000000
 807 0611 E809FAFF 		call	outtest_ws
 807      FF
 141:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 809              	.LM115:
 810 0616 BE040000 		movl	$4, %esi
 810      00
 811 061b 488D3D00 		leaq	outtest_r(%rip), %rdi
 811      000000
 812 0622 E81BFBFF 		call	outtest_wh
 812      FF
 142:outtest.c     **** 	outtest_wl();
 814              	.LM116:
 815 0627 E806FBFF 		call	outtest_wl
 815      FF
 143:outtest.c     **** 	outtest_r =   1.1000000e-003;
 817              	.LM117:
 818 062c F30F1005 		movss	.LC33(%rip), %xmm0
 818      00000000 
 819 0634 F30F1105 		movss	%xmm0, outtest_r(%rip)
 819      00000000 
 144:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
 821              	.LM118:
 822 063c BE180000 		movl	$24, %esi
 822      00
 823 0641 488D3D00 		leaq	.LC34(%rip), %rdi
 823      000000
 824 0648 E8D2F9FF 		call	outtest_ws
 824      FF
 145:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 826              	.LM119:
 827 064d BE040000 		movl	$4, %esi
 827      00
 828 0652 488D3D00 		leaq	outtest_r(%rip), %rdi
 828      000000
 829 0659 E8E4FAFF 		call	outtest_wh
 829      FF
 146:outtest.c     **** 	outtest_wl();
 831              	.LM120:
 832 065e E8CFFAFF 		call	outtest_wl
 832      FF
 147:outtest.c     **** 	outtest_r =   1.2345679e+003;
 834              	.LM121:
 835 0663 F30F1005 		movss	.LC35(%rip), %xmm0
 835      00000000 
 836 066b F30F1105 		movss	%xmm0, outtest_r(%rip)
 836      00000000 
 148:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
 838              	.LM122:
 839 0673 BE180000 		movl	$24, %esi
 839      00
 840 0678 488D3D00 		leaq	.LC36(%rip), %rdi
 840      000000
 841 067f E89BF9FF 		call	outtest_ws
 841      FF
 149:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 843              	.LM123:
 844 0684 BE040000 		movl	$4, %esi
 844      00
 845 0689 488D3D00 		leaq	outtest_r(%rip), %rdi
 845      000000
 846 0690 E8ADFAFF 		call	outtest_wh
 846      FF
 150:outtest.c     **** 	outtest_wl();
 848              	.LM124:
 849 0695 E898FAFF 		call	outtest_wl
 849      FF
 151:outtest.c     **** 	outtest_r = (REAL)0;
 851              	.LM125:
 852 069a 660FEFC0 		pxor	%xmm0, %xmm0
 853 069e F30F1105 		movss	%xmm0, outtest_r(%rip)
 853      00000000 
 152:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 855              	.LM126:
 856 06a6 BE180000 		movl	$24, %esi
 856      00
 857 06ab 488D3D00 		leaq	.LC17(%rip), %rdi
 857      000000
 858 06b2 E868F9FF 		call	outtest_ws
 858      FF
 153:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 860              	.LM127:
 861 06b7 BE040000 		movl	$4, %esi
 861      00
 862 06bc 488D3D00 		leaq	outtest_r(%rip), %rdi
 862      000000
 863 06c3 E87AFAFF 		call	outtest_wh
 863      FF
 154:outtest.c     **** 	outtest_wl();
 865              	.LM128:
 866 06c8 E865FAFF 		call	outtest_wl
 866      FF
 155:outtest.c     **** 	outtest_r =   1.2300001e-004;
 868              	.LM129:
 869 06cd F30F1005 		movss	.LC38(%rip), %xmm0
 869      00000000 
 870 06d5 F30F1105 		movss	%xmm0, outtest_r(%rip)
 870      00000000 
 156:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
 872              	.LM130:
 873 06dd BE180000 		movl	$24, %esi
 873      00
 874 06e2 488D3D00 		leaq	.LC39(%rip), %rdi
 874      000000
 875 06e9 E831F9FF 		call	outtest_ws
 875      FF
 157:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 877              	.LM131:
 878 06ee BE040000 		movl	$4, %esi
 878      00
 879 06f3 488D3D00 		leaq	outtest_r(%rip), %rdi
 879      000000
 880 06fa E843FAFF 		call	outtest_wh
 880      FF
 158:outtest.c     **** 	outtest_wl();
 882              	.LM132:
 883 06ff E82EFAFF 		call	outtest_wl
 883      FF
 159:outtest.c     **** 	outtest_r = (REAL)0;
 885              	.LM133:
 886 0704 660FEFC0 		pxor	%xmm0, %xmm0
 887 0708 F30F1105 		movss	%xmm0, outtest_r(%rip)
 887      00000000 
 160:outtest.c     **** 	outtest_r = (REAL)1 / outtest_r;
 889              	.LM134:
 890 0710 F30F100D 		movss	outtest_r(%rip), %xmm1
 890      00000000 
 891 0718 F30F1005 		movss	.LC23(%rip), %xmm0
 891      00000000 
 892 0720 F30F5EC1 		divss	%xmm1, %xmm0
 894              	.LM135:
 895 0724 F30F1105 		movss	%xmm0, outtest_r(%rip)
 895      00000000 
 161:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 897              	.LM136:
 898 072c BE180000 		movl	$24, %esi
 898      00
 899 0731 488D3D00 		leaq	.LC20(%rip), %rdi
 899      000000
 900 0738 E8E2F8FF 		call	outtest_ws
 900      FF
 162:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 902              	.LM137:
 903 073d BE040000 		movl	$4, %esi
 903      00
 904 0742 488D3D00 		leaq	outtest_r(%rip), %rdi
 904      000000
 905 0749 E8F4F9FF 		call	outtest_wh
 905      FF
 163:outtest.c     **** 	outtest_wl();
 907              	.LM138:
 908 074e E8DFF9FF 		call	outtest_wl
 908      FF
 164:outtest.c     **** 	outtest_r = (REAL)0;
 910              	.LM139:
 911 0753 660FEFC0 		pxor	%xmm0, %xmm0
 912 0757 F30F1105 		movss	%xmm0, outtest_r(%rip)
 912      00000000 
 165:outtest.c     **** 	outtest_r = -((REAL)1 / outtest_r);
 914              	.LM140:
 915 075f F30F100D 		movss	outtest_r(%rip), %xmm1
 915      00000000 
 916 0767 F30F1005 		movss	.LC23(%rip), %xmm0
 916      00000000 
 917 076f F30F5EC1 		divss	%xmm1, %xmm0
 919              	.LM141:
 920 0773 F30F100D 		movss	.LC40(%rip), %xmm1
 920      00000000 
 921 077b 0F57C1   		xorps	%xmm1, %xmm0
 923              	.LM142:
 924 077e F30F1105 		movss	%xmm0, outtest_r(%rip)
 924      00000000 
 166:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 926              	.LM143:
 927 0786 BE180000 		movl	$24, %esi
 927      00
 928 078b 488D3D00 		leaq	.LC22(%rip), %rdi
 928      000000
 929 0792 E888F8FF 		call	outtest_ws
 929      FF
 167:outtest.c     **** 	outtest_wh((void*)&outtest_r, 4);
 931              	.LM144:
 932 0797 BE040000 		movl	$4, %esi
 932      00
 933 079c 488D3D00 		leaq	outtest_r(%rip), %rdi
 933      000000
 934 07a3 E89AF9FF 		call	outtest_wh
 934      FF
 168:outtest.c     **** 	outtest_wl();
 936              	.LM145:
 937 07a8 E885F9FF 		call	outtest_wl
 937      FF
 169:outtest.c     **** 	outtest_wl();
 939              	.LM146:
 940 07ad E880F9FF 		call	outtest_wl
 940      FF
 170:outtest.c     **** 	outtest_wl();
 942              	.LM147:
 943 07b2 E87BF9FF 		call	outtest_wl
 943      FF
 171:outtest.c     **** 	outtest_ws((CHAR*)"Out module tests.", 18);
 945              	.LM148:
 946 07b7 BE120000 		movl	$18, %esi
 946      00
 947 07bc 488D3D00 		leaq	.LC41(%rip), %rdi
 947      000000
 948 07c3 E857F8FF 		call	outtest_ws
 948      FF
 172:outtest.c     **** 	outtest_wl();
 950              	.LM149:
 951 07c8 E865F9FF 		call	outtest_wl
 951      FF
 173:outtest.c     **** 	outtest_ws((CHAR*)"SIZE(INTEGER) = ", 17);
 953              	.LM150:
 954 07cd BE110000 		movl	$17, %esi
 954      00
 955 07d2 488D3D00 		leaq	.LC42(%rip), %rdi
 955      000000
 956 07d9 E841F8FF 		call	outtest_ws
 956      FF
 174:outtest.c     **** 	outtest_wi(4);
 958              	.LM151:
 959 07de BF040000 		movl	$4, %edi
 959      00
 960 07e3 E826F9FF 		call	outtest_wi
 960      FF
 175:outtest.c     **** 	outtest_wl();
 962              	.LM152:
 963 07e8 E845F9FF 		call	outtest_wl
 963      FF
 176:outtest.c     **** 	outtest_wl();
 965              	.LM153:
 966 07ed E840F9FF 		call	outtest_wl
 966      FF
 177:outtest.c     **** 	outtest_ws((CHAR*)"Testing LONGREAL.", 18);
 968              	.LM154:
 969 07f2 BE120000 		movl	$18, %esi
 969      00
 970 07f7 488D3D00 		leaq	.LC43(%rip), %rdi
 970      000000
 971 07fe E81CF8FF 		call	outtest_ws
 971      FF
 178:outtest.c     **** 	outtest_wl();
 973              	.LM155:
 974 0803 E82AF9FF 		call	outtest_wl
 974      FF
 179:outtest.c     **** 	outtest_wl();
 976              	.LM156:
 977 0808 E825F9FF 		call	outtest_wl
 977      FF
 180:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3         4", 64);
 979              	.LM157:
 980 080d BE400000 		movl	$64, %esi
 980      00
 981 0812 488D3D00 		leaq	.LC44(%rip), %rdi
 981      000000
 982 0819 E801F8FF 		call	outtest_ws
 982      FF
 181:outtest.c     **** 	outtest_wl();
 984              	.LM158:
 985 081e E80FF9FF 		call	outtest_wl
 985      FF
 182:outtest.c     **** 	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
 987              	.LM159:
 988 0823 BE400000 		movl	$64, %esi
 988      00
 989 0828 488D3D00 		leaq	.LC45(%rip), %rdi
 989      000000
 990 082f E8EBF7FF 		call	outtest_ws
 990      FF
 183:outtest.c     **** 	outtest_wl();
 992              	.LM160:
 993 0834 E8F9F8FF 		call	outtest_wl
 993      FF
 184:outtest.c     **** 	outtest_ws((CHAR*)" 1.0D0:                ", 24);
 995              	.LM161:
 996 0839 BE180000 		movl	$24, %esi
 996      00
 997 083e 488D3D00 		leaq	.LC3(%rip), %rdi
 997      000000
 998 0845 E8D5F7FF 		call	outtest_ws
 998      FF
 185:outtest.c     **** 	Out_LongReal((LONGREAL)1, 1);
 1000              	.LM162:
 1001 084a 488B0500 		movq	.LC2(%rip), %rax
 1001      000000
 1002 0851 BF010000 		movl	$1, %edi
 1002      00
 1003 0856 66480F6E 		movq	%rax, %xmm0
 1003      C0
 1004 085b E8000000 		call	Out_LongReal@PLT
 1004      00
 186:outtest.c     **** 	outtest_wl();
 1006              	.LM163:
 1007 0860 E8CDF8FF 		call	outtest_wl
 1007      FF
 187:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D0:                ", 24);
 1009              	.LM164:
 1010 0865 BE180000 		movl	$24, %esi
 1010      00
 1011 086a 488D3D00 		leaq	.LC5(%rip), %rdi
 1011      000000
 1012 0871 E8A9F7FF 		call	outtest_ws
 1012      FF
 188:outtest.c     **** 	Out_LongReal(  1.10000000000000e+000, 1);
 1014              	.LM165:
 1015 0876 488B0500 		movq	.LC4(%rip), %rax
 1015      000000
 1016 087d BF010000 		movl	$1, %edi
 1016      00
 1017 0882 66480F6E 		movq	%rax, %xmm0
 1017      C0
 1018 0887 E8000000 		call	Out_LongReal@PLT
 1018      00
 189:outtest.c     **** 	outtest_wl();
 1020              	.LM166:
 1021 088c E8A1F8FF 		call	outtest_wl
 1021      FF
 190:outtest.c     **** 	outtest_ws((CHAR*)" 2.1D0:                ", 24);
 1023              	.LM167:
 1024 0891 BE180000 		movl	$24, %esi
 1024      00
 1025 0896 488D3D00 		leaq	.LC7(%rip), %rdi
 1025      000000
 1026 089d E87DF7FF 		call	outtest_ws
 1026      FF
 191:outtest.c     **** 	Out_LongReal(  2.10000000000000e+000, 1);
 1028              	.LM168:
 1029 08a2 488B0500 		movq	.LC6(%rip), %rax
 1029      000000
 1030 08a9 BF010000 		movl	$1, %edi
 1030      00
 1031 08ae 66480F6E 		movq	%rax, %xmm0
 1031      C0
 1032 08b3 E8000000 		call	Out_LongReal@PLT
 1032      00
 192:outtest.c     **** 	outtest_wl();
 1034              	.LM169:
 1035 08b8 E875F8FF 		call	outtest_wl
 1035      FF
 193:outtest.c     **** 	outtest_ws((CHAR*)"-1.1D0:                ", 24);
 1037              	.LM170:
 1038 08bd BE180000 		movl	$24, %esi
 1038      00
 1039 08c2 488D3D00 		leaq	.LC9(%rip), %rdi
 1039      000000
 1040 08c9 E851F7FF 		call	outtest_ws
 1040      FF
 194:outtest.c     **** 	Out_LongReal( -1.10000000000000e+000, 1);
 1042              	.LM171:
 1043 08ce 488B0500 		movq	.LC8(%rip), %rax
 1043      000000
 1044 08d5 BF010000 		movl	$1, %edi
 1044      00
 1045 08da 66480F6E 		movq	%rax, %xmm0
 1045      C0
 1046 08df E8000000 		call	Out_LongReal@PLT
 1046      00
 195:outtest.c     **** 	outtest_wl();
 1048              	.LM172:
 1049 08e4 E849F8FF 		call	outtest_wl
 1049      FF
 196:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D3:                ", 24);
 1051              	.LM173:
 1052 08e9 BE180000 		movl	$24, %esi
 1052      00
 1053 08ee 488D3D00 		leaq	.LC11(%rip), %rdi
 1053      000000
 1054 08f5 E825F7FF 		call	outtest_ws
 1054      FF
 197:outtest.c     **** 	Out_LongReal(  1.10000000000000e+003, 1);
 1056              	.LM174:
 1057 08fa 488B0500 		movq	.LC10(%rip), %rax
 1057      000000
 1058 0901 BF010000 		movl	$1, %edi
 1058      00
 1059 0906 66480F6E 		movq	%rax, %xmm0
 1059      C0
 1060 090b E8000000 		call	Out_LongReal@PLT
 1060      00
 198:outtest.c     **** 	outtest_wl();
 1062              	.LM175:
 1063 0910 E81DF8FF 		call	outtest_wl
 1063      FF
 199:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
 1065              	.LM176:
 1066 0915 BE180000 		movl	$24, %esi
 1066      00
 1067 091a 488D3D00 		leaq	.LC13(%rip), %rdi
 1067      000000
 1068 0921 E8F9F6FF 		call	outtest_ws
 1068      FF
 200:outtest.c     **** 	Out_LongReal(  1.10000000000000e-003, 1);
 1070              	.LM177:
 1071 0926 488B0500 		movq	.LC12(%rip), %rax
 1071      000000
 1072 092d BF010000 		movl	$1, %edi
 1072      00
 1073 0932 66480F6E 		movq	%rax, %xmm0
 1073      C0
 1074 0937 E8000000 		call	Out_LongReal@PLT
 1074      00
 201:outtest.c     **** 	outtest_wl();
 1076              	.LM178:
 1077 093c E8F1F7FF 		call	outtest_wl
 1077      FF
 202:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
 1079              	.LM179:
 1080 0941 BE180000 		movl	$24, %esi
 1080      00
 1081 0946 488D3D00 		leaq	.LC15(%rip), %rdi
 1081      000000
 1082 094d E8CDF6FF 		call	outtest_ws
 1082      FF
 203:outtest.c     **** 	Out_LongReal(  1.23456789876543e+003, 1);
 1084              	.LM180:
 1085 0952 488B0500 		movq	.LC14(%rip), %rax
 1085      000000
 1086 0959 BF010000 		movl	$1, %edi
 1086      00
 1087 095e 66480F6E 		movq	%rax, %xmm0
 1087      C0
 1088 0963 E8000000 		call	Out_LongReal@PLT
 1088      00
 204:outtest.c     **** 	outtest_wl();
 1090              	.LM181:
 1091 0968 E8C5F7FF 		call	outtest_wl
 1091      FF
 205:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 1093              	.LM182:
 1094 096d BE180000 		movl	$24, %esi
 1094      00
 1095 0972 488D3D00 		leaq	.LC17(%rip), %rdi
 1095      000000
 1096 0979 E8A1F6FF 		call	outtest_ws
 1096      FF
 206:outtest.c     **** 	Out_LongReal((LONGREAL)0, 1);
 1098              	.LM183:
 1099 097e BF010000 		movl	$1, %edi
 1099      00
 1100 0983 660FEFC0 		pxor	%xmm0, %xmm0
 1101 0987 E8000000 		call	Out_LongReal@PLT
 1101      00
 207:outtest.c     **** 	outtest_wl();
 1103              	.LM184:
 1104 098c E8A1F7FF 		call	outtest_wl
 1104      FF
 208:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
 1106              	.LM185:
 1107 0991 BE180000 		movl	$24, %esi
 1107      00
 1108 0996 488D3D00 		leaq	.LC19(%rip), %rdi
 1108      000000
 1109 099d E87DF6FF 		call	outtest_ws
 1109      FF
 209:outtest.c     **** 	Out_LongReal(  1.23000000000000e-004, 1);
 1111              	.LM186:
 1112 09a2 488B0500 		movq	.LC18(%rip), %rax
 1112      000000
 1113 09a9 BF010000 		movl	$1, %edi
 1113      00
 1114 09ae 66480F6E 		movq	%rax, %xmm0
 1114      C0
 1115 09b3 E8000000 		call	Out_LongReal@PLT
 1115      00
 210:outtest.c     **** 	outtest_wl();
 1117              	.LM187:
 1118 09b8 E875F7FF 		call	outtest_wl
 1118      FF
 211:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1120              	.LM188:
 1121 09bd 660FEFC0 		pxor	%xmm0, %xmm0
 1122 09c1 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1122      00000000 
 212:outtest.c     **** 	outtest_lr = (LONGREAL)1 / outtest_lr;
 1124              	.LM189:
 1125 09c9 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1125      00000000 
 1126 09d1 F20F1005 		movsd	.LC2(%rip), %xmm0
 1126      00000000 
 1127 09d9 F20F5EC1 		divsd	%xmm1, %xmm0
 1129              	.LM190:
 1130 09dd F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1130      00000000 
 213:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 1132              	.LM191:
 1133 09e5 BE180000 		movl	$24, %esi
 1133      00
 1134 09ea 488D3D00 		leaq	.LC20(%rip), %rdi
 1134      000000
 1135 09f1 E829F6FF 		call	outtest_ws
 1135      FF
 214:outtest.c     **** 	Out_LongReal(outtest_lr, 1);
 1137              	.LM192:
 1138 09f6 488B0500 		movq	outtest_lr(%rip), %rax
 1138      000000
 1139 09fd BF010000 		movl	$1, %edi
 1139      00
 1140 0a02 66480F6E 		movq	%rax, %xmm0
 1140      C0
 1141 0a07 E8000000 		call	Out_LongReal@PLT
 1141      00
 215:outtest.c     **** 	outtest_wl();
 1143              	.LM193:
 1144 0a0c E821F7FF 		call	outtest_wl
 1144      FF
 216:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1146              	.LM194:
 1147 0a11 660FEFC0 		pxor	%xmm0, %xmm0
 1148 0a15 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1148      00000000 
 217:outtest.c     **** 	outtest_lr = -((LONGREAL)1 / outtest_lr);
 1150              	.LM195:
 1151 0a1d F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1151      00000000 
 1152 0a25 F20F1005 		movsd	.LC2(%rip), %xmm0
 1152      00000000 
 1153 0a2d F20F5EC1 		divsd	%xmm1, %xmm0
 1155              	.LM196:
 1156 0a31 F30F7E0D 		movq	.LC21(%rip), %xmm1
 1156      00000000 
 1157 0a39 660F57C1 		xorpd	%xmm1, %xmm0
 1159              	.LM197:
 1160 0a3d F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1160      00000000 
 218:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 1162              	.LM198:
 1163 0a45 BE180000 		movl	$24, %esi
 1163      00
 1164 0a4a 488D3D00 		leaq	.LC22(%rip), %rdi
 1164      000000
 1165 0a51 E8C9F5FF 		call	outtest_ws
 1165      FF
 219:outtest.c     **** 	Out_LongReal(outtest_lr, 1);
 1167              	.LM199:
 1168 0a56 488B0500 		movq	outtest_lr(%rip), %rax
 1168      000000
 1169 0a5d BF010000 		movl	$1, %edi
 1169      00
 1170 0a62 66480F6E 		movq	%rax, %xmm0
 1170      C0
 1171 0a67 E8000000 		call	Out_LongReal@PLT
 1171      00
 220:outtest.c     **** 	outtest_wl();
 1173              	.LM200:
 1174 0a6c E8C1F6FF 		call	outtest_wl
 1174      FF
 221:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1176              	.LM201:
 1177 0a71 660FEFC0 		pxor	%xmm0, %xmm0
 1178 0a75 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1178      00000000 
 222:outtest.c     **** 	outtest_lr = (LONGREAL)0 / outtest_lr;
 1180              	.LM202:
 1181 0a7d F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1181      00000000 
 1182 0a85 660FEFC0 		pxor	%xmm0, %xmm0
 1183 0a89 F20F5EC1 		divsd	%xmm1, %xmm0
 1185              	.LM203:
 1186 0a8d F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1186      00000000 
 223:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 1188              	.LM204:
 1189 0a95 BE180000 		movl	$24, %esi
 1189      00
 1190 0a9a 488D3D00 		leaq	.LC46(%rip), %rdi
 1190      000000
 1191 0aa1 E879F5FF 		call	outtest_ws
 1191      FF
 224:outtest.c     **** 	Out_LongReal(outtest_lr, 1);
 1193              	.LM205:
 1194 0aa6 488B0500 		movq	outtest_lr(%rip), %rax
 1194      000000
 1195 0aad BF010000 		movl	$1, %edi
 1195      00
 1196 0ab2 66480F6E 		movq	%rax, %xmm0
 1196      C0
 1197 0ab7 E8000000 		call	Out_LongReal@PLT
 1197      00
 225:outtest.c     **** 	outtest_wl();
 1199              	.LM206:
 1200 0abc E871F6FF 		call	outtest_wl
 1200      FF
 226:outtest.c     **** 	outtest_wl();
 1202              	.LM207:
 1203 0ac1 E86CF6FF 		call	outtest_wl
 1203      FF
 227:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3         4", 64);
 1205              	.LM208:
 1206 0ac6 BE400000 		movl	$64, %esi
 1206      00
 1207 0acb 488D3D00 		leaq	.LC44(%rip), %rdi
 1207      000000
 1208 0ad2 E848F5FF 		call	outtest_ws
 1208      FF
 228:outtest.c     **** 	outtest_wl();
 1210              	.LM209:
 1211 0ad7 E856F6FF 		call	outtest_wl
 1211      FF
 229:outtest.c     **** 	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
 1213              	.LM210:
 1214 0adc BE400000 		movl	$64, %esi
 1214      00
 1215 0ae1 488D3D00 		leaq	.LC45(%rip), %rdi
 1215      000000
 1216 0ae8 E832F5FF 		call	outtest_ws
 1216      FF
 230:outtest.c     **** 	outtest_wl();
 1218              	.LM211:
 1219 0aed E840F6FF 		call	outtest_wl
 1219      FF
 231:outtest.c     **** 	outtest_ws((CHAR*)" 1.0D0:                ", 24);
 1221              	.LM212:
 1222 0af2 BE180000 		movl	$24, %esi
 1222      00
 1223 0af7 488D3D00 		leaq	.LC3(%rip), %rdi
 1223      000000
 1224 0afe E81CF5FF 		call	outtest_ws
 1224      FF
 232:outtest.c     **** 	Out_LongReal((LONGREAL)1, 12);
 1226              	.LM213:
 1227 0b03 488B0500 		movq	.LC2(%rip), %rax
 1227      000000
 1228 0b0a BF0C0000 		movl	$12, %edi
 1228      00
 1229 0b0f 66480F6E 		movq	%rax, %xmm0
 1229      C0
 1230 0b14 E8000000 		call	Out_LongReal@PLT
 1230      00
 233:outtest.c     **** 	outtest_wl();
 1232              	.LM214:
 1233 0b19 E814F6FF 		call	outtest_wl
 1233      FF
 234:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D0:                ", 24);
 1235              	.LM215:
 1236 0b1e BE180000 		movl	$24, %esi
 1236      00
 1237 0b23 488D3D00 		leaq	.LC5(%rip), %rdi
 1237      000000
 1238 0b2a E8F0F4FF 		call	outtest_ws
 1238      FF
 235:outtest.c     **** 	Out_LongReal(  1.10000000000000e+000, 12);
 1240              	.LM216:
 1241 0b2f 488B0500 		movq	.LC4(%rip), %rax
 1241      000000
 1242 0b36 BF0C0000 		movl	$12, %edi
 1242      00
 1243 0b3b 66480F6E 		movq	%rax, %xmm0
 1243      C0
 1244 0b40 E8000000 		call	Out_LongReal@PLT
 1244      00
 236:outtest.c     **** 	outtest_wl();
 1246              	.LM217:
 1247 0b45 E8E8F5FF 		call	outtest_wl
 1247      FF
 237:outtest.c     **** 	outtest_ws((CHAR*)" 2.1D0:                ", 24);
 1249              	.LM218:
 1250 0b4a BE180000 		movl	$24, %esi
 1250      00
 1251 0b4f 488D3D00 		leaq	.LC7(%rip), %rdi
 1251      000000
 1252 0b56 E8C4F4FF 		call	outtest_ws
 1252      FF
 238:outtest.c     **** 	Out_LongReal(  2.10000000000000e+000, 12);
 1254              	.LM219:
 1255 0b5b 488B0500 		movq	.LC6(%rip), %rax
 1255      000000
 1256 0b62 BF0C0000 		movl	$12, %edi
 1256      00
 1257 0b67 66480F6E 		movq	%rax, %xmm0
 1257      C0
 1258 0b6c E8000000 		call	Out_LongReal@PLT
 1258      00
 239:outtest.c     **** 	outtest_wl();
 1260              	.LM220:
 1261 0b71 E8BCF5FF 		call	outtest_wl
 1261      FF
 240:outtest.c     **** 	outtest_ws((CHAR*)"-1.1D0:                ", 24);
 1263              	.LM221:
 1264 0b76 BE180000 		movl	$24, %esi
 1264      00
 1265 0b7b 488D3D00 		leaq	.LC9(%rip), %rdi
 1265      000000
 1266 0b82 E898F4FF 		call	outtest_ws
 1266      FF
 241:outtest.c     **** 	Out_LongReal( -1.10000000000000e+000, 12);
 1268              	.LM222:
 1269 0b87 488B0500 		movq	.LC8(%rip), %rax
 1269      000000
 1270 0b8e BF0C0000 		movl	$12, %edi
 1270      00
 1271 0b93 66480F6E 		movq	%rax, %xmm0
 1271      C0
 1272 0b98 E8000000 		call	Out_LongReal@PLT
 1272      00
 242:outtest.c     **** 	outtest_wl();
 1274              	.LM223:
 1275 0b9d E890F5FF 		call	outtest_wl
 1275      FF
 243:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D3:                ", 24);
 1277              	.LM224:
 1278 0ba2 BE180000 		movl	$24, %esi
 1278      00
 1279 0ba7 488D3D00 		leaq	.LC11(%rip), %rdi
 1279      000000
 1280 0bae E86CF4FF 		call	outtest_ws
 1280      FF
 244:outtest.c     **** 	Out_LongReal(  1.10000000000000e+003, 12);
 1282              	.LM225:
 1283 0bb3 488B0500 		movq	.LC10(%rip), %rax
 1283      000000
 1284 0bba BF0C0000 		movl	$12, %edi
 1284      00
 1285 0bbf 66480F6E 		movq	%rax, %xmm0
 1285      C0
 1286 0bc4 E8000000 		call	Out_LongReal@PLT
 1286      00
 245:outtest.c     **** 	outtest_wl();
 1288              	.LM226:
 1289 0bc9 E864F5FF 		call	outtest_wl
 1289      FF
 246:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
 1291              	.LM227:
 1292 0bce BE180000 		movl	$24, %esi
 1292      00
 1293 0bd3 488D3D00 		leaq	.LC13(%rip), %rdi
 1293      000000
 1294 0bda E840F4FF 		call	outtest_ws
 1294      FF
 247:outtest.c     **** 	Out_LongReal(  1.10000000000000e-003, 12);
 1296              	.LM228:
 1297 0bdf 488B0500 		movq	.LC12(%rip), %rax
 1297      000000
 1298 0be6 BF0C0000 		movl	$12, %edi
 1298      00
 1299 0beb 66480F6E 		movq	%rax, %xmm0
 1299      C0
 1300 0bf0 E8000000 		call	Out_LongReal@PLT
 1300      00
 248:outtest.c     **** 	outtest_wl();
 1302              	.LM229:
 1303 0bf5 E838F5FF 		call	outtest_wl
 1303      FF
 249:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
 1305              	.LM230:
 1306 0bfa BE180000 		movl	$24, %esi
 1306      00
 1307 0bff 488D3D00 		leaq	.LC15(%rip), %rdi
 1307      000000
 1308 0c06 E814F4FF 		call	outtest_ws
 1308      FF
 250:outtest.c     **** 	Out_LongReal(  1.23456789876543e+003, 12);
 1310              	.LM231:
 1311 0c0b 488B0500 		movq	.LC14(%rip), %rax
 1311      000000
 1312 0c12 BF0C0000 		movl	$12, %edi
 1312      00
 1313 0c17 66480F6E 		movq	%rax, %xmm0
 1313      C0
 1314 0c1c E8000000 		call	Out_LongReal@PLT
 1314      00
 251:outtest.c     **** 	outtest_wl();
 1316              	.LM232:
 1317 0c21 E80CF5FF 		call	outtest_wl
 1317      FF
 252:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 1319              	.LM233:
 1320 0c26 BE180000 		movl	$24, %esi
 1320      00
 1321 0c2b 488D3D00 		leaq	.LC17(%rip), %rdi
 1321      000000
 1322 0c32 E8E8F3FF 		call	outtest_ws
 1322      FF
 253:outtest.c     **** 	Out_LongReal((LONGREAL)0, 12);
 1324              	.LM234:
 1325 0c37 BF0C0000 		movl	$12, %edi
 1325      00
 1326 0c3c 660FEFC0 		pxor	%xmm0, %xmm0
 1327 0c40 E8000000 		call	Out_LongReal@PLT
 1327      00
 254:outtest.c     **** 	outtest_wl();
 1329              	.LM235:
 1330 0c45 E8E8F4FF 		call	outtest_wl
 1330      FF
 255:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
 1332              	.LM236:
 1333 0c4a BE180000 		movl	$24, %esi
 1333      00
 1334 0c4f 488D3D00 		leaq	.LC19(%rip), %rdi
 1334      000000
 1335 0c56 E8C4F3FF 		call	outtest_ws
 1335      FF
 256:outtest.c     **** 	Out_LongReal(  1.23000000000000e-004, 12);
 1337              	.LM237:
 1338 0c5b 488B0500 		movq	.LC18(%rip), %rax
 1338      000000
 1339 0c62 BF0C0000 		movl	$12, %edi
 1339      00
 1340 0c67 66480F6E 		movq	%rax, %xmm0
 1340      C0
 1341 0c6c E8000000 		call	Out_LongReal@PLT
 1341      00
 257:outtest.c     **** 	outtest_wl();
 1343              	.LM238:
 1344 0c71 E8BCF4FF 		call	outtest_wl
 1344      FF
 258:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1346              	.LM239:
 1347 0c76 660FEFC0 		pxor	%xmm0, %xmm0
 1348 0c7a F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1348      00000000 
 259:outtest.c     **** 	outtest_lr = (LONGREAL)1 / outtest_lr;
 1350              	.LM240:
 1351 0c82 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1351      00000000 
 1352 0c8a F20F1005 		movsd	.LC2(%rip), %xmm0
 1352      00000000 
 1353 0c92 F20F5EC1 		divsd	%xmm1, %xmm0
 1355              	.LM241:
 1356 0c96 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1356      00000000 
 260:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 1358              	.LM242:
 1359 0c9e BE180000 		movl	$24, %esi
 1359      00
 1360 0ca3 488D3D00 		leaq	.LC20(%rip), %rdi
 1360      000000
 1361 0caa E870F3FF 		call	outtest_ws
 1361      FF
 261:outtest.c     **** 	Out_LongReal(outtest_lr, 12);
 1363              	.LM243:
 1364 0caf 488B0500 		movq	outtest_lr(%rip), %rax
 1364      000000
 1365 0cb6 BF0C0000 		movl	$12, %edi
 1365      00
 1366 0cbb 66480F6E 		movq	%rax, %xmm0
 1366      C0
 1367 0cc0 E8000000 		call	Out_LongReal@PLT
 1367      00
 262:outtest.c     **** 	outtest_wl();
 1369              	.LM244:
 1370 0cc5 E868F4FF 		call	outtest_wl
 1370      FF
 263:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1372              	.LM245:
 1373 0cca 660FEFC0 		pxor	%xmm0, %xmm0
 1374 0cce F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1374      00000000 
 264:outtest.c     **** 	outtest_lr = -((LONGREAL)1 / outtest_lr);
 1376              	.LM246:
 1377 0cd6 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1377      00000000 
 1378 0cde F20F1005 		movsd	.LC2(%rip), %xmm0
 1378      00000000 
 1379 0ce6 F20F5EC1 		divsd	%xmm1, %xmm0
 1381              	.LM247:
 1382 0cea F30F7E0D 		movq	.LC21(%rip), %xmm1
 1382      00000000 
 1383 0cf2 660F57C1 		xorpd	%xmm1, %xmm0
 1385              	.LM248:
 1386 0cf6 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1386      00000000 
 265:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 1388              	.LM249:
 1389 0cfe BE180000 		movl	$24, %esi
 1389      00
 1390 0d03 488D3D00 		leaq	.LC22(%rip), %rdi
 1390      000000
 1391 0d0a E810F3FF 		call	outtest_ws
 1391      FF
 266:outtest.c     **** 	Out_LongReal(outtest_lr, 12);
 1393              	.LM250:
 1394 0d0f 488B0500 		movq	outtest_lr(%rip), %rax
 1394      000000
 1395 0d16 BF0C0000 		movl	$12, %edi
 1395      00
 1396 0d1b 66480F6E 		movq	%rax, %xmm0
 1396      C0
 1397 0d20 E8000000 		call	Out_LongReal@PLT
 1397      00
 267:outtest.c     **** 	outtest_wl();
 1399              	.LM251:
 1400 0d25 E808F4FF 		call	outtest_wl
 1400      FF
 268:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1402              	.LM252:
 1403 0d2a 660FEFC0 		pxor	%xmm0, %xmm0
 1404 0d2e F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1404      00000000 
 269:outtest.c     **** 	outtest_lr = (LONGREAL)0 / outtest_lr;
 1406              	.LM253:
 1407 0d36 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1407      00000000 
 1408 0d3e 660FEFC0 		pxor	%xmm0, %xmm0
 1409 0d42 F20F5EC1 		divsd	%xmm1, %xmm0
 1411              	.LM254:
 1412 0d46 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1412      00000000 
 270:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 1414              	.LM255:
 1415 0d4e BE180000 		movl	$24, %esi
 1415      00
 1416 0d53 488D3D00 		leaq	.LC46(%rip), %rdi
 1416      000000
 1417 0d5a E8C0F2FF 		call	outtest_ws
 1417      FF
 271:outtest.c     **** 	Out_LongReal(outtest_lr, 12);
 1419              	.LM256:
 1420 0d5f 488B0500 		movq	outtest_lr(%rip), %rax
 1420      000000
 1421 0d66 BF0C0000 		movl	$12, %edi
 1421      00
 1422 0d6b 66480F6E 		movq	%rax, %xmm0
 1422      C0
 1423 0d70 E8000000 		call	Out_LongReal@PLT
 1423      00
 272:outtest.c     **** 	outtest_wl();
 1425              	.LM257:
 1426 0d75 E8B8F3FF 		call	outtest_wl
 1426      FF
 273:outtest.c     **** 	outtest_wl();
 1428              	.LM258:
 1429 0d7a E8B3F3FF 		call	outtest_wl
 1429      FF
 274:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3         4", 64);
 1431              	.LM259:
 1432 0d7f BE400000 		movl	$64, %esi
 1432      00
 1433 0d84 488D3D00 		leaq	.LC44(%rip), %rdi
 1433      000000
 1434 0d8b E88FF2FF 		call	outtest_ws
 1434      FF
 275:outtest.c     **** 	outtest_wl();
 1436              	.LM260:
 1437 0d90 E89DF3FF 		call	outtest_wl
 1437      FF
 276:outtest.c     **** 	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
 1439              	.LM261:
 1440 0d95 BE400000 		movl	$64, %esi
 1440      00
 1441 0d9a 488D3D00 		leaq	.LC45(%rip), %rdi
 1441      000000
 1442 0da1 E879F2FF 		call	outtest_ws
 1442      FF
 277:outtest.c     **** 	outtest_wl();
 1444              	.LM262:
 1445 0da6 E887F3FF 		call	outtest_wl
 1445      FF
 278:outtest.c     **** 	outtest_ws((CHAR*)" 1.0D0:                ", 24);
 1447              	.LM263:
 1448 0dab BE180000 		movl	$24, %esi
 1448      00
 1449 0db0 488D3D00 		leaq	.LC3(%rip), %rdi
 1449      000000
 1450 0db7 E863F2FF 		call	outtest_ws
 1450      FF
 279:outtest.c     **** 	Out_LongReal((LONGREAL)1, 40);
 1452              	.LM264:
 1453 0dbc 488B0500 		movq	.LC2(%rip), %rax
 1453      000000
 1454 0dc3 BF280000 		movl	$40, %edi
 1454      00
 1455 0dc8 66480F6E 		movq	%rax, %xmm0
 1455      C0
 1456 0dcd E8000000 		call	Out_LongReal@PLT
 1456      00
 280:outtest.c     **** 	outtest_wl();
 1458              	.LM265:
 1459 0dd2 E85BF3FF 		call	outtest_wl
 1459      FF
 281:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D0:                ", 24);
 1461              	.LM266:
 1462 0dd7 BE180000 		movl	$24, %esi
 1462      00
 1463 0ddc 488D3D00 		leaq	.LC5(%rip), %rdi
 1463      000000
 1464 0de3 E837F2FF 		call	outtest_ws
 1464      FF
 282:outtest.c     **** 	Out_LongReal(  1.10000000000000e+000, 40);
 1466              	.LM267:
 1467 0de8 488B0500 		movq	.LC4(%rip), %rax
 1467      000000
 1468 0def BF280000 		movl	$40, %edi
 1468      00
 1469 0df4 66480F6E 		movq	%rax, %xmm0
 1469      C0
 1470 0df9 E8000000 		call	Out_LongReal@PLT
 1470      00
 283:outtest.c     **** 	outtest_wl();
 1472              	.LM268:
 1473 0dfe E82FF3FF 		call	outtest_wl
 1473      FF
 284:outtest.c     **** 	outtest_ws((CHAR*)" 2.1D0:                ", 24);
 1475              	.LM269:
 1476 0e03 BE180000 		movl	$24, %esi
 1476      00
 1477 0e08 488D3D00 		leaq	.LC7(%rip), %rdi
 1477      000000
 1478 0e0f E80BF2FF 		call	outtest_ws
 1478      FF
 285:outtest.c     **** 	Out_LongReal(  2.10000000000000e+000, 40);
 1480              	.LM270:
 1481 0e14 488B0500 		movq	.LC6(%rip), %rax
 1481      000000
 1482 0e1b BF280000 		movl	$40, %edi
 1482      00
 1483 0e20 66480F6E 		movq	%rax, %xmm0
 1483      C0
 1484 0e25 E8000000 		call	Out_LongReal@PLT
 1484      00
 286:outtest.c     **** 	outtest_wl();
 1486              	.LM271:
 1487 0e2a E803F3FF 		call	outtest_wl
 1487      FF
 287:outtest.c     **** 	outtest_ws((CHAR*)"-1.1D0:                ", 24);
 1489              	.LM272:
 1490 0e2f BE180000 		movl	$24, %esi
 1490      00
 1491 0e34 488D3D00 		leaq	.LC9(%rip), %rdi
 1491      000000
 1492 0e3b E8DFF1FF 		call	outtest_ws
 1492      FF
 288:outtest.c     **** 	Out_LongReal( -1.10000000000000e+000, 40);
 1494              	.LM273:
 1495 0e40 488B0500 		movq	.LC8(%rip), %rax
 1495      000000
 1496 0e47 BF280000 		movl	$40, %edi
 1496      00
 1497 0e4c 66480F6E 		movq	%rax, %xmm0
 1497      C0
 1498 0e51 E8000000 		call	Out_LongReal@PLT
 1498      00
 289:outtest.c     **** 	outtest_wl();
 1500              	.LM274:
 1501 0e56 E8D7F2FF 		call	outtest_wl
 1501      FF
 290:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D3:                ", 24);
 1503              	.LM275:
 1504 0e5b BE180000 		movl	$24, %esi
 1504      00
 1505 0e60 488D3D00 		leaq	.LC11(%rip), %rdi
 1505      000000
 1506 0e67 E8B3F1FF 		call	outtest_ws
 1506      FF
 291:outtest.c     **** 	Out_LongReal(  1.10000000000000e+003, 40);
 1508              	.LM276:
 1509 0e6c 488B0500 		movq	.LC10(%rip), %rax
 1509      000000
 1510 0e73 BF280000 		movl	$40, %edi
 1510      00
 1511 0e78 66480F6E 		movq	%rax, %xmm0
 1511      C0
 1512 0e7d E8000000 		call	Out_LongReal@PLT
 1512      00
 292:outtest.c     **** 	outtest_wl();
 1514              	.LM277:
 1515 0e82 E8ABF2FF 		call	outtest_wl
 1515      FF
 293:outtest.c     **** 	outtest_ws((CHAR*)" 1.1D-3:               ", 24);
 1517              	.LM278:
 1518 0e87 BE180000 		movl	$24, %esi
 1518      00
 1519 0e8c 488D3D00 		leaq	.LC13(%rip), %rdi
 1519      000000
 1520 0e93 E887F1FF 		call	outtest_ws
 1520      FF
 294:outtest.c     **** 	Out_LongReal(  1.10000000000000e-003, 40);
 1522              	.LM279:
 1523 0e98 488B0500 		movq	.LC12(%rip), %rax
 1523      000000
 1524 0e9f BF280000 		movl	$40, %edi
 1524      00
 1525 0ea4 66480F6E 		movq	%rax, %xmm0
 1525      C0
 1526 0ea9 E8000000 		call	Out_LongReal@PLT
 1526      00
 295:outtest.c     **** 	outtest_wl();
 1528              	.LM280:
 1529 0eae E87FF2FF 		call	outtest_wl
 1529      FF
 296:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321D3: ", 24);
 1531              	.LM281:
 1532 0eb3 BE180000 		movl	$24, %esi
 1532      00
 1533 0eb8 488D3D00 		leaq	.LC15(%rip), %rdi
 1533      000000
 1534 0ebf E85BF1FF 		call	outtest_ws
 1534      FF
 297:outtest.c     **** 	Out_LongReal(  1.23456789876543e+003, 40);
 1536              	.LM282:
 1537 0ec4 488B0500 		movq	.LC14(%rip), %rax
 1537      000000
 1538 0ecb BF280000 		movl	$40, %edi
 1538      00
 1539 0ed0 66480F6E 		movq	%rax, %xmm0
 1539      C0
 1540 0ed5 E8000000 		call	Out_LongReal@PLT
 1540      00
 298:outtest.c     **** 	outtest_wl();
 1542              	.LM283:
 1543 0eda E853F2FF 		call	outtest_wl
 1543      FF
 299:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 1545              	.LM284:
 1546 0edf BE180000 		movl	$24, %esi
 1546      00
 1547 0ee4 488D3D00 		leaq	.LC17(%rip), %rdi
 1547      000000
 1548 0eeb E82FF1FF 		call	outtest_ws
 1548      FF
 300:outtest.c     **** 	Out_LongReal((LONGREAL)0, 40);
 1550              	.LM285:
 1551 0ef0 BF280000 		movl	$40, %edi
 1551      00
 1552 0ef5 660FEFC0 		pxor	%xmm0, %xmm0
 1553 0ef9 E8000000 		call	Out_LongReal@PLT
 1553      00
 301:outtest.c     **** 	outtest_wl();
 1555              	.LM286:
 1556 0efe E82FF2FF 		call	outtest_wl
 1556      FF
 302:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123D0:           ", 24);
 1558              	.LM287:
 1559 0f03 BE180000 		movl	$24, %esi
 1559      00
 1560 0f08 488D3D00 		leaq	.LC19(%rip), %rdi
 1560      000000
 1561 0f0f E80BF1FF 		call	outtest_ws
 1561      FF
 303:outtest.c     **** 	Out_LongReal(  1.23000000000000e-004, 40);
 1563              	.LM288:
 1564 0f14 488B0500 		movq	.LC18(%rip), %rax
 1564      000000
 1565 0f1b BF280000 		movl	$40, %edi
 1565      00
 1566 0f20 66480F6E 		movq	%rax, %xmm0
 1566      C0
 1567 0f25 E8000000 		call	Out_LongReal@PLT
 1567      00
 304:outtest.c     **** 	outtest_wl();
 1569              	.LM289:
 1570 0f2a E803F2FF 		call	outtest_wl
 1570      FF
 305:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1572              	.LM290:
 1573 0f2f 660FEFC0 		pxor	%xmm0, %xmm0
 1574 0f33 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1574      00000000 
 306:outtest.c     **** 	outtest_lr = (LONGREAL)1 / outtest_lr;
 1576              	.LM291:
 1577 0f3b F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1577      00000000 
 1578 0f43 F20F1005 		movsd	.LC2(%rip), %xmm0
 1578      00000000 
 1579 0f4b F20F5EC1 		divsd	%xmm1, %xmm0
 1581              	.LM292:
 1582 0f4f F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1582      00000000 
 307:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 1584              	.LM293:
 1585 0f57 BE180000 		movl	$24, %esi
 1585      00
 1586 0f5c 488D3D00 		leaq	.LC20(%rip), %rdi
 1586      000000
 1587 0f63 E8B7F0FF 		call	outtest_ws
 1587      FF
 308:outtest.c     **** 	Out_LongReal(outtest_lr, 40);
 1589              	.LM294:
 1590 0f68 488B0500 		movq	outtest_lr(%rip), %rax
 1590      000000
 1591 0f6f BF280000 		movl	$40, %edi
 1591      00
 1592 0f74 66480F6E 		movq	%rax, %xmm0
 1592      C0
 1593 0f79 E8000000 		call	Out_LongReal@PLT
 1593      00
 309:outtest.c     **** 	outtest_wl();
 1595              	.LM295:
 1596 0f7e E8AFF1FF 		call	outtest_wl
 1596      FF
 310:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1598              	.LM296:
 1599 0f83 660FEFC0 		pxor	%xmm0, %xmm0
 1600 0f87 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1600      00000000 
 311:outtest.c     **** 	outtest_lr = -((LONGREAL)1 / outtest_lr);
 1602              	.LM297:
 1603 0f8f F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1603      00000000 
 1604 0f97 F20F1005 		movsd	.LC2(%rip), %xmm0
 1604      00000000 
 1605 0f9f F20F5EC1 		divsd	%xmm1, %xmm0
 1607              	.LM298:
 1608 0fa3 F30F7E0D 		movq	.LC21(%rip), %xmm1
 1608      00000000 
 1609 0fab 660F57C1 		xorpd	%xmm1, %xmm0
 1611              	.LM299:
 1612 0faf F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1612      00000000 
 312:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 1614              	.LM300:
 1615 0fb7 BE180000 		movl	$24, %esi
 1615      00
 1616 0fbc 488D3D00 		leaq	.LC22(%rip), %rdi
 1616      000000
 1617 0fc3 E857F0FF 		call	outtest_ws
 1617      FF
 313:outtest.c     **** 	Out_LongReal(outtest_lr, 40);
 1619              	.LM301:
 1620 0fc8 488B0500 		movq	outtest_lr(%rip), %rax
 1620      000000
 1621 0fcf BF280000 		movl	$40, %edi
 1621      00
 1622 0fd4 66480F6E 		movq	%rax, %xmm0
 1622      C0
 1623 0fd9 E8000000 		call	Out_LongReal@PLT
 1623      00
 314:outtest.c     **** 	outtest_wl();
 1625              	.LM302:
 1626 0fde E84FF1FF 		call	outtest_wl
 1626      FF
 315:outtest.c     **** 	outtest_lr = (LONGREAL)0;
 1628              	.LM303:
 1629 0fe3 660FEFC0 		pxor	%xmm0, %xmm0
 1630 0fe7 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1630      00000000 
 316:outtest.c     **** 	outtest_lr = (LONGREAL)0 / outtest_lr;
 1632              	.LM304:
 1633 0fef F20F100D 		movsd	outtest_lr(%rip), %xmm1
 1633      00000000 
 1634 0ff7 660FEFC0 		pxor	%xmm0, %xmm0
 1635 0ffb F20F5EC1 		divsd	%xmm1, %xmm0
 1637              	.LM305:
 1638 0fff F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 1638      00000000 
 317:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 1640              	.LM306:
 1641 1007 BE180000 		movl	$24, %esi
 1641      00
 1642 100c 488D3D00 		leaq	.LC46(%rip), %rdi
 1642      000000
 1643 1013 E807F0FF 		call	outtest_ws
 1643      FF
 318:outtest.c     **** 	Out_LongReal(outtest_lr, 40);
 1645              	.LM307:
 1646 1018 488B0500 		movq	outtest_lr(%rip), %rax
 1646      000000
 1647 101f BF280000 		movl	$40, %edi
 1647      00
 1648 1024 66480F6E 		movq	%rax, %xmm0
 1648      C0
 1649 1029 E8000000 		call	Out_LongReal@PLT
 1649      00
 319:outtest.c     **** 	outtest_wl();
 1651              	.LM308:
 1652 102e E8FFF0FF 		call	outtest_wl
 1652      FF
 320:outtest.c     **** 	outtest_wl();
 1654              	.LM309:
 1655 1033 E8FAF0FF 		call	outtest_wl
 1655      FF
 321:outtest.c     **** 	outtest_wl();
 1657              	.LM310:
 1658 1038 E8F5F0FF 		call	outtest_wl
 1658      FF
 322:outtest.c     **** 	outtest_wl();
 1660              	.LM311:
 1661 103d E8F0F0FF 		call	outtest_wl
 1661      FF
 323:outtest.c     **** 	outtest_ws((CHAR*)"Testing REAL.", 14);
 1663              	.LM312:
 1664 1042 BE0E0000 		movl	$14, %esi
 1664      00
 1665 1047 488D3D00 		leaq	.LC47(%rip), %rdi
 1665      000000
 1666 104e E8CCEFFF 		call	outtest_ws
 1666      FF
 324:outtest.c     **** 	outtest_wl();
 1668              	.LM313:
 1669 1053 E8DAF0FF 		call	outtest_wl
 1669      FF
 325:outtest.c     **** 	outtest_wl();
 1671              	.LM314:
 1672 1058 E8D5F0FF 		call	outtest_wl
 1672      FF
 326:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3         4", 64);
 1674              	.LM315:
 1675 105d BE400000 		movl	$64, %esi
 1675      00
 1676 1062 488D3D00 		leaq	.LC44(%rip), %rdi
 1676      000000
 1677 1069 E8B1EFFF 		call	outtest_ws
 1677      FF
 327:outtest.c     **** 	outtest_wl();
 1679              	.LM316:
 1680 106e E8BFF0FF 		call	outtest_wl
 1680      FF
 328:outtest.c     **** 	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
 1682              	.LM317:
 1683 1073 BE400000 		movl	$64, %esi
 1683      00
 1684 1078 488D3D00 		leaq	.LC45(%rip), %rdi
 1684      000000
 1685 107f E89BEFFF 		call	outtest_ws
 1685      FF
 329:outtest.c     **** 	outtest_wl();
 1687              	.LM318:
 1688 1084 E8A9F0FF 		call	outtest_wl
 1688      FF
 330:outtest.c     **** 	outtest_ws((CHAR*)" 1.0E0:                ", 24);
 1690              	.LM319:
 1691 1089 BE180000 		movl	$24, %esi
 1691      00
 1692 108e 488D3D00 		leaq	.LC24(%rip), %rdi
 1692      000000
 1693 1095 E885EFFF 		call	outtest_ws
 1693      FF
 331:outtest.c     **** 	Out_Real((REAL)1, 1);
 1695              	.LM320:
 1696 109a BF010000 		movl	$1, %edi
 1696      00
 1697 109f F30F1005 		movss	.LC23(%rip), %xmm0
 1697      00000000 
 1698 10a7 E8000000 		call	Out_Real@PLT
 1698      00
 332:outtest.c     **** 	outtest_wl();
 1700              	.LM321:
 1701 10ac E881F0FF 		call	outtest_wl
 1701      FF
 333:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E0:                ", 24);
 1703              	.LM322:
 1704 10b1 BE180000 		movl	$24, %esi
 1704      00
 1705 10b6 488D3D00 		leaq	.LC26(%rip), %rdi
 1705      000000
 1706 10bd E85DEFFF 		call	outtest_ws
 1706      FF
 334:outtest.c     **** 	Out_Real(  1.1000000e+000, 1);
 1708              	.LM323:
 1709 10c2 BF010000 		movl	$1, %edi
 1709      00
 1710 10c7 F30F1005 		movss	.LC25(%rip), %xmm0
 1710      00000000 
 1711 10cf E8000000 		call	Out_Real@PLT
 1711      00
 335:outtest.c     **** 	outtest_wl();
 1713              	.LM324:
 1714 10d4 E859F0FF 		call	outtest_wl
 1714      FF
 336:outtest.c     **** 	outtest_ws((CHAR*)" 2.1E0:                ", 24);
 1716              	.LM325:
 1717 10d9 BE180000 		movl	$24, %esi
 1717      00
 1718 10de 488D3D00 		leaq	.LC28(%rip), %rdi
 1718      000000
 1719 10e5 E835EFFF 		call	outtest_ws
 1719      FF
 337:outtest.c     **** 	Out_Real(  2.0999999e+000, 1);
 1721              	.LM326:
 1722 10ea BF010000 		movl	$1, %edi
 1722      00
 1723 10ef F30F1005 		movss	.LC27(%rip), %xmm0
 1723      00000000 
 1724 10f7 E8000000 		call	Out_Real@PLT
 1724      00
 338:outtest.c     **** 	outtest_wl();
 1726              	.LM327:
 1727 10fc E831F0FF 		call	outtest_wl
 1727      FF
 339:outtest.c     **** 	outtest_ws((CHAR*)"-1.1E0:                ", 24);
 1729              	.LM328:
 1730 1101 BE180000 		movl	$24, %esi
 1730      00
 1731 1106 488D3D00 		leaq	.LC30(%rip), %rdi
 1731      000000
 1732 110d E80DEFFF 		call	outtest_ws
 1732      FF
 340:outtest.c     **** 	Out_Real( -1.1000000e+000, 1);
 1734              	.LM329:
 1735 1112 BF010000 		movl	$1, %edi
 1735      00
 1736 1117 F30F1005 		movss	.LC29(%rip), %xmm0
 1736      00000000 
 1737 111f E8000000 		call	Out_Real@PLT
 1737      00
 341:outtest.c     **** 	outtest_wl();
 1739              	.LM330:
 1740 1124 E809F0FF 		call	outtest_wl
 1740      FF
 342:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E3:                ", 24);
 1742              	.LM331:
 1743 1129 BE180000 		movl	$24, %esi
 1743      00
 1744 112e 488D3D00 		leaq	.LC32(%rip), %rdi
 1744      000000
 1745 1135 E8E5EEFF 		call	outtest_ws
 1745      FF
 343:outtest.c     **** 	Out_Real((REAL)1100, 1);
 1747              	.LM332:
 1748 113a BF010000 		movl	$1, %edi
 1748      00
 1749 113f F30F1005 		movss	.LC31(%rip), %xmm0
 1749      00000000 
 1750 1147 E8000000 		call	Out_Real@PLT
 1750      00
 344:outtest.c     **** 	outtest_wl();
 1752              	.LM333:
 1753 114c E8E1EFFF 		call	outtest_wl
 1753      FF
 345:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
 1755              	.LM334:
 1756 1151 BE180000 		movl	$24, %esi
 1756      00
 1757 1156 488D3D00 		leaq	.LC34(%rip), %rdi
 1757      000000
 1758 115d E8BDEEFF 		call	outtest_ws
 1758      FF
 346:outtest.c     **** 	Out_Real(  1.1000000e-003, 1);
 1760              	.LM335:
 1761 1162 BF010000 		movl	$1, %edi
 1761      00
 1762 1167 F30F1005 		movss	.LC33(%rip), %xmm0
 1762      00000000 
 1763 116f E8000000 		call	Out_Real@PLT
 1763      00
 347:outtest.c     **** 	outtest_wl();
 1765              	.LM336:
 1766 1174 E8B9EFFF 		call	outtest_wl
 1766      FF
 348:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
 1768              	.LM337:
 1769 1179 BE180000 		movl	$24, %esi
 1769      00
 1770 117e 488D3D00 		leaq	.LC36(%rip), %rdi
 1770      000000
 1771 1185 E895EEFF 		call	outtest_ws
 1771      FF
 349:outtest.c     **** 	Out_Real(  1.2345679e+003, 1);
 1773              	.LM338:
 1774 118a BF010000 		movl	$1, %edi
 1774      00
 1775 118f F30F1005 		movss	.LC35(%rip), %xmm0
 1775      00000000 
 1776 1197 E8000000 		call	Out_Real@PLT
 1776      00
 350:outtest.c     **** 	outtest_wl();
 1778              	.LM339:
 1779 119c E891EFFF 		call	outtest_wl
 1779      FF
 351:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 1781              	.LM340:
 1782 11a1 BE180000 		movl	$24, %esi
 1782      00
 1783 11a6 488D3D00 		leaq	.LC17(%rip), %rdi
 1783      000000
 1784 11ad E86DEEFF 		call	outtest_ws
 1784      FF
 352:outtest.c     **** 	Out_Real((REAL)0, 1);
 1786              	.LM341:
 1787 11b2 BF010000 		movl	$1, %edi
 1787      00
 1788 11b7 660FEFC0 		pxor	%xmm0, %xmm0
 1789 11bb E8000000 		call	Out_Real@PLT
 1789      00
 353:outtest.c     **** 	outtest_wl();
 1791              	.LM342:
 1792 11c0 E86DEFFF 		call	outtest_wl
 1792      FF
 354:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
 1794              	.LM343:
 1795 11c5 BE180000 		movl	$24, %esi
 1795      00
 1796 11ca 488D3D00 		leaq	.LC39(%rip), %rdi
 1796      000000
 1797 11d1 E849EEFF 		call	outtest_ws
 1797      FF
 355:outtest.c     **** 	Out_Real(  1.2300001e-004, 1);
 1799              	.LM344:
 1800 11d6 BF010000 		movl	$1, %edi
 1800      00
 1801 11db F30F1005 		movss	.LC38(%rip), %xmm0
 1801      00000000 
 1802 11e3 E8000000 		call	Out_Real@PLT
 1802      00
 356:outtest.c     **** 	outtest_wl();
 1804              	.LM345:
 1805 11e8 E845EFFF 		call	outtest_wl
 1805      FF
 357:outtest.c     **** 	outtest_r = (REAL)0;
 1807              	.LM346:
 1808 11ed 660FEFC0 		pxor	%xmm0, %xmm0
 1809 11f1 F30F1105 		movss	%xmm0, outtest_r(%rip)
 1809      00000000 
 358:outtest.c     **** 	outtest_r = (REAL)1 / outtest_r;
 1811              	.LM347:
 1812 11f9 F30F100D 		movss	outtest_r(%rip), %xmm1
 1812      00000000 
 1813 1201 F30F1005 		movss	.LC23(%rip), %xmm0
 1813      00000000 
 1814 1209 F30F5EC1 		divss	%xmm1, %xmm0
 1816              	.LM348:
 1817 120d F30F1105 		movss	%xmm0, outtest_r(%rip)
 1817      00000000 
 359:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 1819              	.LM349:
 1820 1215 BE180000 		movl	$24, %esi
 1820      00
 1821 121a 488D3D00 		leaq	.LC20(%rip), %rdi
 1821      000000
 1822 1221 E8F9EDFF 		call	outtest_ws
 1822      FF
 360:outtest.c     **** 	Out_Real(outtest_r, 1);
 1824              	.LM350:
 1825 1226 8B050000 		movl	outtest_r(%rip), %eax
 1825      0000
 1826 122c BF010000 		movl	$1, %edi
 1826      00
 1827 1231 660F6EC0 		movd	%eax, %xmm0
 1828 1235 E8000000 		call	Out_Real@PLT
 1828      00
 361:outtest.c     **** 	outtest_wl();
 1830              	.LM351:
 1831 123a E8F3EEFF 		call	outtest_wl
 1831      FF
 362:outtest.c     **** 	outtest_r = (REAL)0;
 1833              	.LM352:
 1834 123f 660FEFC0 		pxor	%xmm0, %xmm0
 1835 1243 F30F1105 		movss	%xmm0, outtest_r(%rip)
 1835      00000000 
 363:outtest.c     **** 	outtest_r = -((REAL)1 / outtest_r);
 1837              	.LM353:
 1838 124b F30F100D 		movss	outtest_r(%rip), %xmm1
 1838      00000000 
 1839 1253 F30F1005 		movss	.LC23(%rip), %xmm0
 1839      00000000 
 1840 125b F30F5EC1 		divss	%xmm1, %xmm0
 1842              	.LM354:
 1843 125f F30F100D 		movss	.LC40(%rip), %xmm1
 1843      00000000 
 1844 1267 0F57C1   		xorps	%xmm1, %xmm0
 1846              	.LM355:
 1847 126a F30F1105 		movss	%xmm0, outtest_r(%rip)
 1847      00000000 
 364:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 1849              	.LM356:
 1850 1272 BE180000 		movl	$24, %esi
 1850      00
 1851 1277 488D3D00 		leaq	.LC22(%rip), %rdi
 1851      000000
 1852 127e E89CEDFF 		call	outtest_ws
 1852      FF
 365:outtest.c     **** 	Out_Real(outtest_r, 1);
 1854              	.LM357:
 1855 1283 8B050000 		movl	outtest_r(%rip), %eax
 1855      0000
 1856 1289 BF010000 		movl	$1, %edi
 1856      00
 1857 128e 660F6EC0 		movd	%eax, %xmm0
 1858 1292 E8000000 		call	Out_Real@PLT
 1858      00
 366:outtest.c     **** 	outtest_wl();
 1860              	.LM358:
 1861 1297 E896EEFF 		call	outtest_wl
 1861      FF
 367:outtest.c     **** 	outtest_r = (REAL)0;
 1863              	.LM359:
 1864 129c 660FEFC0 		pxor	%xmm0, %xmm0
 1865 12a0 F30F1105 		movss	%xmm0, outtest_r(%rip)
 1865      00000000 
 368:outtest.c     **** 	outtest_r = (REAL)0 / outtest_r;
 1867              	.LM360:
 1868 12a8 F30F100D 		movss	outtest_r(%rip), %xmm1
 1868      00000000 
 1869 12b0 660FEFC0 		pxor	%xmm0, %xmm0
 1870 12b4 F30F5EC1 		divss	%xmm1, %xmm0
 1872              	.LM361:
 1873 12b8 F30F1105 		movss	%xmm0, outtest_r(%rip)
 1873      00000000 
 369:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 1875              	.LM362:
 1876 12c0 BE180000 		movl	$24, %esi
 1876      00
 1877 12c5 488D3D00 		leaq	.LC46(%rip), %rdi
 1877      000000
 1878 12cc E84EEDFF 		call	outtest_ws
 1878      FF
 370:outtest.c     **** 	Out_Real(outtest_r, 1);
 1880              	.LM363:
 1881 12d1 8B050000 		movl	outtest_r(%rip), %eax
 1881      0000
 1882 12d7 BF010000 		movl	$1, %edi
 1882      00
 1883 12dc 660F6EC0 		movd	%eax, %xmm0
 1884 12e0 E8000000 		call	Out_Real@PLT
 1884      00
 371:outtest.c     **** 	outtest_wl();
 1886              	.LM364:
 1887 12e5 E848EEFF 		call	outtest_wl
 1887      FF
 372:outtest.c     **** 	outtest_wl();
 1889              	.LM365:
 1890 12ea E843EEFF 		call	outtest_wl
 1890      FF
 373:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3", 54);
 1892              	.LM366:
 1893 12ef BE360000 		movl	$54, %esi
 1893      00
 1894 12f4 488D3D00 		leaq	.LC48(%rip), %rdi
 1894      000000
 1895 12fb E81FEDFF 		call	outtest_ws
 1895      FF
 374:outtest.c     **** 	outtest_wl();
 1897              	.LM367:
 1898 1300 E82DEEFF 		call	outtest_wl
 1898      FF
 375:outtest.c     **** 	outtest_ws((CHAR*)"                       123456789012345678901234567890", 54);
 1900              	.LM368:
 1901 1305 BE360000 		movl	$54, %esi
 1901      00
 1902 130a 488D3D00 		leaq	.LC49(%rip), %rdi
 1902      000000
 1903 1311 E809EDFF 		call	outtest_ws
 1903      FF
 376:outtest.c     **** 	outtest_wl();
 1905              	.LM369:
 1906 1316 E817EEFF 		call	outtest_wl
 1906      FF
 377:outtest.c     **** 	outtest_ws((CHAR*)" 1.0E0:                ", 24);
 1908              	.LM370:
 1909 131b BE180000 		movl	$24, %esi
 1909      00
 1910 1320 488D3D00 		leaq	.LC24(%rip), %rdi
 1910      000000
 1911 1327 E8F3ECFF 		call	outtest_ws
 1911      FF
 378:outtest.c     **** 	Out_Real((REAL)1, 12);
 1913              	.LM371:
 1914 132c BF0C0000 		movl	$12, %edi
 1914      00
 1915 1331 F30F1005 		movss	.LC23(%rip), %xmm0
 1915      00000000 
 1916 1339 E8000000 		call	Out_Real@PLT
 1916      00
 379:outtest.c     **** 	outtest_wl();
 1918              	.LM372:
 1919 133e E8EFEDFF 		call	outtest_wl
 1919      FF
 380:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E0:                ", 24);
 1921              	.LM373:
 1922 1343 BE180000 		movl	$24, %esi
 1922      00
 1923 1348 488D3D00 		leaq	.LC26(%rip), %rdi
 1923      000000
 1924 134f E8CBECFF 		call	outtest_ws
 1924      FF
 381:outtest.c     **** 	Out_Real(  1.1000000e+000, 12);
 1926              	.LM374:
 1927 1354 BF0C0000 		movl	$12, %edi
 1927      00
 1928 1359 F30F1005 		movss	.LC25(%rip), %xmm0
 1928      00000000 
 1929 1361 E8000000 		call	Out_Real@PLT
 1929      00
 382:outtest.c     **** 	outtest_wl();
 1931              	.LM375:
 1932 1366 E8C7EDFF 		call	outtest_wl
 1932      FF
 383:outtest.c     **** 	outtest_ws((CHAR*)" 2.1E0:                ", 24);
 1934              	.LM376:
 1935 136b BE180000 		movl	$24, %esi
 1935      00
 1936 1370 488D3D00 		leaq	.LC28(%rip), %rdi
 1936      000000
 1937 1377 E8A3ECFF 		call	outtest_ws
 1937      FF
 384:outtest.c     **** 	Out_Real(  2.0999999e+000, 12);
 1939              	.LM377:
 1940 137c BF0C0000 		movl	$12, %edi
 1940      00
 1941 1381 F30F1005 		movss	.LC27(%rip), %xmm0
 1941      00000000 
 1942 1389 E8000000 		call	Out_Real@PLT
 1942      00
 385:outtest.c     **** 	outtest_wl();
 1944              	.LM378:
 1945 138e E89FEDFF 		call	outtest_wl
 1945      FF
 386:outtest.c     **** 	outtest_ws((CHAR*)"-1.1E0:                ", 24);
 1947              	.LM379:
 1948 1393 BE180000 		movl	$24, %esi
 1948      00
 1949 1398 488D3D00 		leaq	.LC30(%rip), %rdi
 1949      000000
 1950 139f E87BECFF 		call	outtest_ws
 1950      FF
 387:outtest.c     **** 	Out_Real( -1.1000000e+000, 12);
 1952              	.LM380:
 1953 13a4 BF0C0000 		movl	$12, %edi
 1953      00
 1954 13a9 F30F1005 		movss	.LC29(%rip), %xmm0
 1954      00000000 
 1955 13b1 E8000000 		call	Out_Real@PLT
 1955      00
 388:outtest.c     **** 	outtest_wl();
 1957              	.LM381:
 1958 13b6 E877EDFF 		call	outtest_wl
 1958      FF
 389:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E3:                ", 24);
 1960              	.LM382:
 1961 13bb BE180000 		movl	$24, %esi
 1961      00
 1962 13c0 488D3D00 		leaq	.LC32(%rip), %rdi
 1962      000000
 1963 13c7 E853ECFF 		call	outtest_ws
 1963      FF
 390:outtest.c     **** 	Out_Real((REAL)1100, 12);
 1965              	.LM383:
 1966 13cc BF0C0000 		movl	$12, %edi
 1966      00
 1967 13d1 F30F1005 		movss	.LC31(%rip), %xmm0
 1967      00000000 
 1968 13d9 E8000000 		call	Out_Real@PLT
 1968      00
 391:outtest.c     **** 	outtest_wl();
 1970              	.LM384:
 1971 13de E84FEDFF 		call	outtest_wl
 1971      FF
 392:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
 1973              	.LM385:
 1974 13e3 BE180000 		movl	$24, %esi
 1974      00
 1975 13e8 488D3D00 		leaq	.LC34(%rip), %rdi
 1975      000000
 1976 13ef E82BECFF 		call	outtest_ws
 1976      FF
 393:outtest.c     **** 	Out_Real(  1.1000000e-003, 12);
 1978              	.LM386:
 1979 13f4 BF0C0000 		movl	$12, %edi
 1979      00
 1980 13f9 F30F1005 		movss	.LC33(%rip), %xmm0
 1980      00000000 
 1981 1401 E8000000 		call	Out_Real@PLT
 1981      00
 394:outtest.c     **** 	outtest_wl();
 1983              	.LM387:
 1984 1406 E827EDFF 		call	outtest_wl
 1984      FF
 395:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
 1986              	.LM388:
 1987 140b BE180000 		movl	$24, %esi
 1987      00
 1988 1410 488D3D00 		leaq	.LC36(%rip), %rdi
 1988      000000
 1989 1417 E803ECFF 		call	outtest_ws
 1989      FF
 396:outtest.c     **** 	Out_Real(  1.2345679e+003, 12);
 1991              	.LM389:
 1992 141c BF0C0000 		movl	$12, %edi
 1992      00
 1993 1421 F30F1005 		movss	.LC35(%rip), %xmm0
 1993      00000000 
 1994 1429 E8000000 		call	Out_Real@PLT
 1994      00
 397:outtest.c     **** 	outtest_wl();
 1996              	.LM390:
 1997 142e E8FFECFF 		call	outtest_wl
 1997      FF
 398:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 1999              	.LM391:
 2000 1433 BE180000 		movl	$24, %esi
 2000      00
 2001 1438 488D3D00 		leaq	.LC17(%rip), %rdi
 2001      000000
 2002 143f E8DBEBFF 		call	outtest_ws
 2002      FF
 399:outtest.c     **** 	Out_Real((REAL)0, 12);
 2004              	.LM392:
 2005 1444 BF0C0000 		movl	$12, %edi
 2005      00
 2006 1449 660FEFC0 		pxor	%xmm0, %xmm0
 2007 144d E8000000 		call	Out_Real@PLT
 2007      00
 400:outtest.c     **** 	outtest_wl();
 2009              	.LM393:
 2010 1452 E8DBECFF 		call	outtest_wl
 2010      FF
 401:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
 2012              	.LM394:
 2013 1457 BE180000 		movl	$24, %esi
 2013      00
 2014 145c 488D3D00 		leaq	.LC39(%rip), %rdi
 2014      000000
 2015 1463 E8B7EBFF 		call	outtest_ws
 2015      FF
 402:outtest.c     **** 	Out_Real(  1.2300001e-004, 12);
 2017              	.LM395:
 2018 1468 BF0C0000 		movl	$12, %edi
 2018      00
 2019 146d F30F1005 		movss	.LC38(%rip), %xmm0
 2019      00000000 
 2020 1475 E8000000 		call	Out_Real@PLT
 2020      00
 403:outtest.c     **** 	outtest_wl();
 2022              	.LM396:
 2023 147a E8B3ECFF 		call	outtest_wl
 2023      FF
 404:outtest.c     **** 	outtest_r = (REAL)0;
 2025              	.LM397:
 2026 147f 660FEFC0 		pxor	%xmm0, %xmm0
 2027 1483 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2027      00000000 
 405:outtest.c     **** 	outtest_r = (REAL)1 / outtest_r;
 2029              	.LM398:
 2030 148b F30F100D 		movss	outtest_r(%rip), %xmm1
 2030      00000000 
 2031 1493 F30F1005 		movss	.LC23(%rip), %xmm0
 2031      00000000 
 2032 149b F30F5EC1 		divss	%xmm1, %xmm0
 2034              	.LM399:
 2035 149f F30F1105 		movss	%xmm0, outtest_r(%rip)
 2035      00000000 
 406:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 2037              	.LM400:
 2038 14a7 BE180000 		movl	$24, %esi
 2038      00
 2039 14ac 488D3D00 		leaq	.LC20(%rip), %rdi
 2039      000000
 2040 14b3 E867EBFF 		call	outtest_ws
 2040      FF
 407:outtest.c     **** 	Out_Real(outtest_r, 12);
 2042              	.LM401:
 2043 14b8 8B050000 		movl	outtest_r(%rip), %eax
 2043      0000
 2044 14be BF0C0000 		movl	$12, %edi
 2044      00
 2045 14c3 660F6EC0 		movd	%eax, %xmm0
 2046 14c7 E8000000 		call	Out_Real@PLT
 2046      00
 408:outtest.c     **** 	outtest_wl();
 2048              	.LM402:
 2049 14cc E861ECFF 		call	outtest_wl
 2049      FF
 409:outtest.c     **** 	outtest_r = (REAL)0;
 2051              	.LM403:
 2052 14d1 660FEFC0 		pxor	%xmm0, %xmm0
 2053 14d5 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2053      00000000 
 410:outtest.c     **** 	outtest_r = -((REAL)1 / outtest_r);
 2055              	.LM404:
 2056 14dd F30F100D 		movss	outtest_r(%rip), %xmm1
 2056      00000000 
 2057 14e5 F30F1005 		movss	.LC23(%rip), %xmm0
 2057      00000000 
 2058 14ed F30F5EC1 		divss	%xmm1, %xmm0
 2060              	.LM405:
 2061 14f1 F30F100D 		movss	.LC40(%rip), %xmm1
 2061      00000000 
 2062 14f9 0F57C1   		xorps	%xmm1, %xmm0
 2064              	.LM406:
 2065 14fc F30F1105 		movss	%xmm0, outtest_r(%rip)
 2065      00000000 
 411:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 2067              	.LM407:
 2068 1504 BE180000 		movl	$24, %esi
 2068      00
 2069 1509 488D3D00 		leaq	.LC22(%rip), %rdi
 2069      000000
 2070 1510 E80AEBFF 		call	outtest_ws
 2070      FF
 412:outtest.c     **** 	Out_Real(outtest_r, 12);
 2072              	.LM408:
 2073 1515 8B050000 		movl	outtest_r(%rip), %eax
 2073      0000
 2074 151b BF0C0000 		movl	$12, %edi
 2074      00
 2075 1520 660F6EC0 		movd	%eax, %xmm0
 2076 1524 E8000000 		call	Out_Real@PLT
 2076      00
 413:outtest.c     **** 	outtest_wl();
 2078              	.LM409:
 2079 1529 E804ECFF 		call	outtest_wl
 2079      FF
 414:outtest.c     **** 	outtest_r = (REAL)0;
 2081              	.LM410:
 2082 152e 660FEFC0 		pxor	%xmm0, %xmm0
 2083 1532 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2083      00000000 
 415:outtest.c     **** 	outtest_r = (REAL)0 / outtest_r;
 2085              	.LM411:
 2086 153a F30F100D 		movss	outtest_r(%rip), %xmm1
 2086      00000000 
 2087 1542 660FEFC0 		pxor	%xmm0, %xmm0
 2088 1546 F30F5EC1 		divss	%xmm1, %xmm0
 2090              	.LM412:
 2091 154a F30F1105 		movss	%xmm0, outtest_r(%rip)
 2091      00000000 
 416:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 2093              	.LM413:
 2094 1552 BE180000 		movl	$24, %esi
 2094      00
 2095 1557 488D3D00 		leaq	.LC46(%rip), %rdi
 2095      000000
 2096 155e E8BCEAFF 		call	outtest_ws
 2096      FF
 417:outtest.c     **** 	Out_Real(outtest_r, 12);
 2098              	.LM414:
 2099 1563 8B050000 		movl	outtest_r(%rip), %eax
 2099      0000
 2100 1569 BF0C0000 		movl	$12, %edi
 2100      00
 2101 156e 660F6EC0 		movd	%eax, %xmm0
 2102 1572 E8000000 		call	Out_Real@PLT
 2102      00
 418:outtest.c     **** 	outtest_wl();
 2104              	.LM415:
 2105 1577 E8B6EBFF 		call	outtest_wl
 2105      FF
 419:outtest.c     **** 	outtest_wl();
 2107              	.LM416:
 2108 157c E8B1EBFF 		call	outtest_wl
 2108      FF
 420:outtest.c     **** 	outtest_ws((CHAR*)"                                1         2         3         4", 64);
 2110              	.LM417:
 2111 1581 BE400000 		movl	$64, %esi
 2111      00
 2112 1586 488D3D00 		leaq	.LC44(%rip), %rdi
 2112      000000
 2113 158d E88DEAFF 		call	outtest_ws
 2113      FF
 421:outtest.c     **** 	outtest_wl();
 2115              	.LM418:
 2116 1592 E89BEBFF 		call	outtest_wl
 2116      FF
 422:outtest.c     **** 	outtest_ws((CHAR*)"                       1234567890123456789012345678901234567890", 64);
 2118              	.LM419:
 2119 1597 BE400000 		movl	$64, %esi
 2119      00
 2120 159c 488D3D00 		leaq	.LC45(%rip), %rdi
 2120      000000
 2121 15a3 E877EAFF 		call	outtest_ws
 2121      FF
 423:outtest.c     **** 	outtest_wl();
 2123              	.LM420:
 2124 15a8 E885EBFF 		call	outtest_wl
 2124      FF
 424:outtest.c     **** 	outtest_ws((CHAR*)" 1.0E0:                ", 24);
 2126              	.LM421:
 2127 15ad BE180000 		movl	$24, %esi
 2127      00
 2128 15b2 488D3D00 		leaq	.LC24(%rip), %rdi
 2128      000000
 2129 15b9 E861EAFF 		call	outtest_ws
 2129      FF
 425:outtest.c     **** 	Out_Real((REAL)1, 40);
 2131              	.LM422:
 2132 15be BF280000 		movl	$40, %edi
 2132      00
 2133 15c3 F30F1005 		movss	.LC23(%rip), %xmm0
 2133      00000000 
 2134 15cb E8000000 		call	Out_Real@PLT
 2134      00
 426:outtest.c     **** 	outtest_wl();
 2136              	.LM423:
 2137 15d0 E85DEBFF 		call	outtest_wl
 2137      FF
 427:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E0:                ", 24);
 2139              	.LM424:
 2140 15d5 BE180000 		movl	$24, %esi
 2140      00
 2141 15da 488D3D00 		leaq	.LC26(%rip), %rdi
 2141      000000
 2142 15e1 E839EAFF 		call	outtest_ws
 2142      FF
 428:outtest.c     **** 	Out_Real(  1.1000000e+000, 40);
 2144              	.LM425:
 2145 15e6 BF280000 		movl	$40, %edi
 2145      00
 2146 15eb F30F1005 		movss	.LC25(%rip), %xmm0
 2146      00000000 
 2147 15f3 E8000000 		call	Out_Real@PLT
 2147      00
 429:outtest.c     **** 	outtest_wl();
 2149              	.LM426:
 2150 15f8 E835EBFF 		call	outtest_wl
 2150      FF
 430:outtest.c     **** 	outtest_ws((CHAR*)" 2.1E0:                ", 24);
 2152              	.LM427:
 2153 15fd BE180000 		movl	$24, %esi
 2153      00
 2154 1602 488D3D00 		leaq	.LC28(%rip), %rdi
 2154      000000
 2155 1609 E811EAFF 		call	outtest_ws
 2155      FF
 431:outtest.c     **** 	Out_Real(  2.0999999e+000, 40);
 2157              	.LM428:
 2158 160e BF280000 		movl	$40, %edi
 2158      00
 2159 1613 F30F1005 		movss	.LC27(%rip), %xmm0
 2159      00000000 
 2160 161b E8000000 		call	Out_Real@PLT
 2160      00
 432:outtest.c     **** 	outtest_wl();
 2162              	.LM429:
 2163 1620 E80DEBFF 		call	outtest_wl
 2163      FF
 433:outtest.c     **** 	outtest_ws((CHAR*)"-1.1E0:                ", 24);
 2165              	.LM430:
 2166 1625 BE180000 		movl	$24, %esi
 2166      00
 2167 162a 488D3D00 		leaq	.LC30(%rip), %rdi
 2167      000000
 2168 1631 E8E9E9FF 		call	outtest_ws
 2168      FF
 434:outtest.c     **** 	Out_Real( -1.1000000e+000, 40);
 2170              	.LM431:
 2171 1636 BF280000 		movl	$40, %edi
 2171      00
 2172 163b F30F1005 		movss	.LC29(%rip), %xmm0
 2172      00000000 
 2173 1643 E8000000 		call	Out_Real@PLT
 2173      00
 435:outtest.c     **** 	outtest_wl();
 2175              	.LM432:
 2176 1648 E8E5EAFF 		call	outtest_wl
 2176      FF
 436:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E3:                ", 24);
 2178              	.LM433:
 2179 164d BE180000 		movl	$24, %esi
 2179      00
 2180 1652 488D3D00 		leaq	.LC32(%rip), %rdi
 2180      000000
 2181 1659 E8C1E9FF 		call	outtest_ws
 2181      FF
 437:outtest.c     **** 	Out_Real((REAL)1100, 40);
 2183              	.LM434:
 2184 165e BF280000 		movl	$40, %edi
 2184      00
 2185 1663 F30F1005 		movss	.LC31(%rip), %xmm0
 2185      00000000 
 2186 166b E8000000 		call	Out_Real@PLT
 2186      00
 438:outtest.c     **** 	outtest_wl();
 2188              	.LM435:
 2189 1670 E8BDEAFF 		call	outtest_wl
 2189      FF
 439:outtest.c     **** 	outtest_ws((CHAR*)" 1.1E-3:               ", 24);
 2191              	.LM436:
 2192 1675 BE180000 		movl	$24, %esi
 2192      00
 2193 167a 488D3D00 		leaq	.LC34(%rip), %rdi
 2193      000000
 2194 1681 E899E9FF 		call	outtest_ws
 2194      FF
 440:outtest.c     **** 	Out_Real(  1.1000000e-003, 40);
 2196              	.LM437:
 2197 1686 BF280000 		movl	$40, %edi
 2197      00
 2198 168b F30F1005 		movss	.LC33(%rip), %xmm0
 2198      00000000 
 2199 1693 E8000000 		call	Out_Real@PLT
 2199      00
 441:outtest.c     **** 	outtest_wl();
 2201              	.LM438:
 2202 1698 E895EAFF 		call	outtest_wl
 2202      FF
 442:outtest.c     **** 	outtest_ws((CHAR*)" 1.2345678987654321E3: ", 24);
 2204              	.LM439:
 2205 169d BE180000 		movl	$24, %esi
 2205      00
 2206 16a2 488D3D00 		leaq	.LC36(%rip), %rdi
 2206      000000
 2207 16a9 E871E9FF 		call	outtest_ws
 2207      FF
 443:outtest.c     **** 	Out_Real(  1.2345679e+003, 40);
 2209              	.LM440:
 2210 16ae BF280000 		movl	$40, %edi
 2210      00
 2211 16b3 F30F1005 		movss	.LC35(%rip), %xmm0
 2211      00000000 
 2212 16bb E8000000 		call	Out_Real@PLT
 2212      00
 444:outtest.c     **** 	outtest_wl();
 2214              	.LM441:
 2215 16c0 E86DEAFF 		call	outtest_wl
 2215      FF
 445:outtest.c     **** 	outtest_ws((CHAR*)" 0.0:                  ", 24);
 2217              	.LM442:
 2218 16c5 BE180000 		movl	$24, %esi
 2218      00
 2219 16ca 488D3D00 		leaq	.LC17(%rip), %rdi
 2219      000000
 2220 16d1 E849E9FF 		call	outtest_ws
 2220      FF
 446:outtest.c     **** 	Out_Real((REAL)0, 40);
 2222              	.LM443:
 2223 16d6 BF280000 		movl	$40, %edi
 2223      00
 2224 16db 660FEFC0 		pxor	%xmm0, %xmm0
 2225 16df E8000000 		call	Out_Real@PLT
 2225      00
 447:outtest.c     **** 	outtest_wl();
 2227              	.LM444:
 2228 16e4 E849EAFF 		call	outtest_wl
 2228      FF
 448:outtest.c     **** 	outtest_ws((CHAR*)" 0.000123E0:           ", 24);
 2230              	.LM445:
 2231 16e9 BE180000 		movl	$24, %esi
 2231      00
 2232 16ee 488D3D00 		leaq	.LC39(%rip), %rdi
 2232      000000
 2233 16f5 E825E9FF 		call	outtest_ws
 2233      FF
 449:outtest.c     **** 	Out_Real(  1.2300001e-004, 40);
 2235              	.LM446:
 2236 16fa BF280000 		movl	$40, %edi
 2236      00
 2237 16ff F30F1005 		movss	.LC38(%rip), %xmm0
 2237      00000000 
 2238 1707 E8000000 		call	Out_Real@PLT
 2238      00
 450:outtest.c     **** 	outtest_wl();
 2240              	.LM447:
 2241 170c E821EAFF 		call	outtest_wl
 2241      FF
 451:outtest.c     **** 	outtest_r = (REAL)0;
 2243              	.LM448:
 2244 1711 660FEFC0 		pxor	%xmm0, %xmm0
 2245 1715 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2245      00000000 
 452:outtest.c     **** 	outtest_r = (REAL)1 / outtest_r;
 2247              	.LM449:
 2248 171d F30F100D 		movss	outtest_r(%rip), %xmm1
 2248      00000000 
 2249 1725 F30F1005 		movss	.LC23(%rip), %xmm0
 2249      00000000 
 2250 172d F30F5EC1 		divss	%xmm1, %xmm0
 2252              	.LM450:
 2253 1731 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2253      00000000 
 453:outtest.c     **** 	outtest_ws((CHAR*)" 1/0.0:                ", 24);
 2255              	.LM451:
 2256 1739 BE180000 		movl	$24, %esi
 2256      00
 2257 173e 488D3D00 		leaq	.LC20(%rip), %rdi
 2257      000000
 2258 1745 E8D5E8FF 		call	outtest_ws
 2258      FF
 454:outtest.c     **** 	Out_Real(outtest_r, 40);
 2260              	.LM452:
 2261 174a 8B050000 		movl	outtest_r(%rip), %eax
 2261      0000
 2262 1750 BF280000 		movl	$40, %edi
 2262      00
 2263 1755 660F6EC0 		movd	%eax, %xmm0
 2264 1759 E8000000 		call	Out_Real@PLT
 2264      00
 455:outtest.c     **** 	outtest_wl();
 2266              	.LM453:
 2267 175e E8CFE9FF 		call	outtest_wl
 2267      FF
 456:outtest.c     **** 	outtest_r = (REAL)0;
 2269              	.LM454:
 2270 1763 660FEFC0 		pxor	%xmm0, %xmm0
 2271 1767 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2271      00000000 
 457:outtest.c     **** 	outtest_r = -((REAL)1 / outtest_r);
 2273              	.LM455:
 2274 176f F30F100D 		movss	outtest_r(%rip), %xmm1
 2274      00000000 
 2275 1777 F30F1005 		movss	.LC23(%rip), %xmm0
 2275      00000000 
 2276 177f F30F5EC1 		divss	%xmm1, %xmm0
 2278              	.LM456:
 2279 1783 F30F100D 		movss	.LC40(%rip), %xmm1
 2279      00000000 
 2280 178b 0F57C1   		xorps	%xmm1, %xmm0
 2282              	.LM457:
 2283 178e F30F1105 		movss	%xmm0, outtest_r(%rip)
 2283      00000000 
 458:outtest.c     **** 	outtest_ws((CHAR*)"-1/0.0:                ", 24);
 2285              	.LM458:
 2286 1796 BE180000 		movl	$24, %esi
 2286      00
 2287 179b 488D3D00 		leaq	.LC22(%rip), %rdi
 2287      000000
 2288 17a2 E878E8FF 		call	outtest_ws
 2288      FF
 459:outtest.c     **** 	Out_Real(outtest_r, 40);
 2290              	.LM459:
 2291 17a7 8B050000 		movl	outtest_r(%rip), %eax
 2291      0000
 2292 17ad BF280000 		movl	$40, %edi
 2292      00
 2293 17b2 660F6EC0 		movd	%eax, %xmm0
 2294 17b6 E8000000 		call	Out_Real@PLT
 2294      00
 460:outtest.c     **** 	outtest_wl();
 2296              	.LM460:
 2297 17bb E872E9FF 		call	outtest_wl
 2297      FF
 461:outtest.c     **** 	outtest_r = (REAL)0;
 2299              	.LM461:
 2300 17c0 660FEFC0 		pxor	%xmm0, %xmm0
 2301 17c4 F30F1105 		movss	%xmm0, outtest_r(%rip)
 2301      00000000 
 462:outtest.c     **** 	outtest_r = (REAL)0 / outtest_r;
 2303              	.LM462:
 2304 17cc F30F100D 		movss	outtest_r(%rip), %xmm1
 2304      00000000 
 2305 17d4 660FEFC0 		pxor	%xmm0, %xmm0
 2306 17d8 F30F5EC1 		divss	%xmm1, %xmm0
 2308              	.LM463:
 2309 17dc F30F1105 		movss	%xmm0, outtest_r(%rip)
 2309      00000000 
 463:outtest.c     **** 	outtest_ws((CHAR*)" 0.0/0.0:              ", 24);
 2311              	.LM464:
 2312 17e4 BE180000 		movl	$24, %esi
 2312      00
 2313 17e9 488D3D00 		leaq	.LC46(%rip), %rdi
 2313      000000
 2314 17f0 E82AE8FF 		call	outtest_ws
 2314      FF
 464:outtest.c     **** 	Out_Real(outtest_r, 40);
 2316              	.LM465:
 2317 17f5 8B050000 		movl	outtest_r(%rip), %eax
 2317      0000
 2318 17fb BF280000 		movl	$40, %edi
 2318      00
 2319 1800 660F6EC0 		movd	%eax, %xmm0
 2320 1804 E8000000 		call	Out_Real@PLT
 2320      00
 465:outtest.c     **** 	outtest_wl();
 2322              	.LM466:
 2323 1809 E824E9FF 		call	outtest_wl
 2323      FF
 466:outtest.c     **** 	outtest_wl();
 2325              	.LM467:
 2326 180e E81FE9FF 		call	outtest_wl
 2326      FF
 467:outtest.c     **** 	__FINI;
 2328              	.LM468:
 2329 1813 B8000000 		movl	$0, %eax
 2329      00
 2330 1818 E8000000 		call	Heap_FINALL@PLT
 2330      00
 2331 181d B8000000 		movl	$0, %eax
 2331      00
 468:outtest.c     **** }
 2333              	.LM469:
 2334 1822 C9       		leave
 2335              		.cfi_def_cfa 7, 8
 2336 1823 C3       		ret
 2337              		.cfi_endproc
 2338              	.LFE12:
 2343              	.Lscope6:
 2345              		.stabd	78,0,0
 2346              		.local	m.2091
 2347              		.comm	m.2091,8,8
 2349              		.section	.rodata
 2350 033e 0000     		.align 8
 2351              	.LC2:
 2352 0340 00000000 		.long	0
 2353 0344 0000F03F 		.long	1072693248
 2354              		.align 8
 2355              	.LC4:
 2356 0348 9A999999 		.long	2576980378
 2357 034c 9999F13F 		.long	1072798105
 2358              		.align 8
 2359              	.LC6:
 2360 0350 CDCCCCCC 		.long	3435973837
 2361 0354 CCCC0040 		.long	1073794252
 2362              		.align 8
 2363              	.LC8:
 2364 0358 9A999999 		.long	2576980378
 2365 035c 9999F1BF 		.long	-1074685543
 2366              		.align 8
 2367              	.LC10:
 2368 0360 00000000 		.long	0
 2369 0364 00309140 		.long	1083256832
 2370              		.align 8
 2371              	.LC12:
 2372 0368 2F6EA301 		.long	27487791
 2373 036c BC05523F 		.long	1062340028
 2374              		.align 8
 2375              	.LC14:
 2376 0370 D8034187 		.long	2269184984
 2377 0374 454A9340 		.long	1083394629
 2378              		.align 8
 2379              	.LC18:
 2380 0378 46D26EF4 		.long	4100903494
 2381 037c 311F203F 		.long	1059069745
 2382              		.align 16
 2383              	.LC21:
 2384 0380 00000000 		.long	0
 2385 0384 00000080 		.long	-2147483648
 2386 0388 00000000 		.long	0
 2387 038c 00000000 		.long	0
 2388              		.align 4
 2389              	.LC23:
 2390 0390 0000803F 		.long	1065353216
 2391              		.align 4
 2392              	.LC25:
 2393 0394 CDCC8C3F 		.long	1066192077
 2394              		.align 4
 2395              	.LC27:
 2396 0398 66660640 		.long	1074161254
 2397              		.align 4
 2398              	.LC29:
 2399 039c CDCC8CBF 		.long	3213675725
 2400              		.align 4
 2401              	.LC31:
 2402 03a0 00808944 		.long	1149861888
 2403              		.align 4
 2404              	.LC33:
 2405 03a4 E02D903A 		.long	982527456
 2406              		.align 4
 2407              	.LC35:
 2408 03a8 2C529A44 		.long	1150964268
 2409              		.align 4
 2410              	.LC38:
 2411 03ac 90F90039 		.long	956365200
 2412              		.align 16
 2413              	.LC40:
 2414 03b0 00000080 		.long	2147483648
 2415 03b4 00000000 		.long	0
 2416 03b8 00000000 		.long	0
 2417 03bc 00000000 		.long	0
 2418              		.text
 2420              	.Letext0:
 2421              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 2422              		.section	.note.GNU-stack,"",@progbits
 2423              		.section	.note.gnu.property,"a"
 2424              		.align 8
 2425 0000 04000000 		.long	 1f - 0f
 2426 0004 10000000 		.long	 4f - 1f
 2427 0008 05000000 		.long	 5
 2428              	0:
 2429 000c 474E5500 		.string	 "GNU"
 2430              	1:
 2431              		.align 8
 2432 0010 020000C0 		.long	 0xc0000002
 2433 0014 04000000 		.long	 3f - 2f
 2434              	2:
 2435 0018 03000000 		.long	 0x3
 2436              	3:
 2437 001c 00000000 		.align 8
 2438              	4:
