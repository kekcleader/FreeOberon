   1              		.file	"TestLibrary.c"
   4              		.text
   5              	.Ltext0:
  93              		.local	TestLibrary_W
  94              		.comm	TestLibrary_W,56,32
  99              	TestLibrary_tc:
 100              		.stabd	46,0,0
   1:TestLibrary.c **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:TestLibrary.c **** 
   3:TestLibrary.c **** #define SHORTINT INT8
   4:TestLibrary.c **** #define INTEGER  INT16
   5:TestLibrary.c **** #define LONGINT  INT32
   6:TestLibrary.c **** #define SET      UINT32
   7:TestLibrary.c **** 
   8:TestLibrary.c **** #include "SYSTEM.h"
   9:TestLibrary.c **** #include "Oberon.h"
  10:TestLibrary.c **** #include "Reals.h"
  11:TestLibrary.c **** #include "Texts.h"
  12:TestLibrary.c **** #include "oocLowReal.h"
  13:TestLibrary.c **** 
  14:TestLibrary.c **** 
  15:TestLibrary.c **** static Texts_Writer TestLibrary_W;
  16:TestLibrary.c **** 
  17:TestLibrary.c **** 
  18:TestLibrary.c **** static void TestLibrary_RealTests (void);
  19:TestLibrary.c **** static void TestLibrary_TestConvert (LONGREAL lr);
  20:TestLibrary.c **** static void TestLibrary_TestFractionPart (REAL r);
  21:TestLibrary.c **** static void TestLibrary_TestHex (REAL r);
  22:TestLibrary.c **** static void TestLibrary_TestSetExpo (REAL r, INT16 i);
  23:TestLibrary.c **** static void TestLibrary_tc (CHAR c);
  24:TestLibrary.c **** static void TestLibrary_ti (INT32 i, INT32 n);
  25:TestLibrary.c **** static void TestLibrary_tn (void);
  26:TestLibrary.c **** static void TestLibrary_tr (LONGREAL r, INT16 n);
  27:TestLibrary.c **** static void TestLibrary_ts (CHAR *s, ADDRESS s__len);
  28:TestLibrary.c **** 
  29:TestLibrary.c **** 
  30:TestLibrary.c **** static void TestLibrary_tc (CHAR c)
  31:TestLibrary.c **** {
 102              	.LM0:
 103              	.LFBB1:
 104              	.LFB7:
 105              		.cfi_startproc
 106 0000 F30F1EFA 		endbr64
 107 0004 55       		pushq	%rbp
 108              		.cfi_def_cfa_offset 16
 109              		.cfi_offset 6, -16
 110 0005 4889E5   		movq	%rsp, %rbp
 111              		.cfi_def_cfa_register 6
 112 0008 4883EC10 		subq	$16, %rsp
 113 000c 89F8     		movl	%edi, %eax
 114 000e 8845FC   		movb	%al, -4(%rbp)
  32:TestLibrary.c **** 	Texts_Write(&TestLibrary_W, Texts_Writer__typ, c);
 116              	.LM1:
 117 0011 0FB655FC 		movzbl	-4(%rbp), %edx
 118 0015 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 118      000000
 119 001c 488B00   		movq	(%rax), %rax
 120 001f 4889C6   		movq	%rax, %rsi
 121 0022 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 121      000000
 122 0029 E8000000 		call	Texts_Write@PLT
 122      00
  33:TestLibrary.c **** }
 124              	.LM2:
 125 002e 90       		nop
 126 002f C9       		leave
 127              		.cfi_def_cfa 7, 8
 128 0030 C3       		ret
 129              		.cfi_endproc
 130              	.LFE7:
 132              	.Lscope1:
 134              		.stabd	78,0,0
 139              	TestLibrary_ts:
 140              		.stabd	46,0,0
  34:TestLibrary.c **** 
  35:TestLibrary.c **** static void TestLibrary_ts (CHAR *s, ADDRESS s__len)
  36:TestLibrary.c **** {
 142              	.LM3:
 143              	.LFBB2:
 144              	.LFB8:
 145              		.cfi_startproc
 146 0031 F30F1EFA 		endbr64
 147 0035 55       		pushq	%rbp
 148              		.cfi_def_cfa_offset 16
 149              		.cfi_offset 6, -16
 150 0036 4889E5   		movq	%rsp, %rbp
 151              		.cfi_def_cfa_register 6
 152 0039 4883EC20 		subq	$32, %rsp
 153 003d 48897DE8 		movq	%rdi, -24(%rbp)
 154 0041 488975E0 		movq	%rsi, -32(%rbp)
 156              	.LM4:
 157 0045 64488B04 		movq	%fs:40, %rax
 157      25280000 
 157      00
 158 004e 488945F8 		movq	%rax, -8(%rbp)
 159 0052 31C0     		xorl	%eax, %eax
  37:TestLibrary.c **** 	__DUP(s, s__len, CHAR);
 161              	.LM5:
 162 0054 488B4DE0 		movq	-32(%rbp), %rcx
 163 0058 488B45E0 		movq	-32(%rbp), %rax
 164 005c 488D5008 		leaq	8(%rax), %rdx
 165 0060 B8100000 		movl	$16, %eax
 165      00
 166 0065 4883E801 		subq	$1, %rax
 167 0069 4801D0   		addq	%rdx, %rax
 168 006c BF100000 		movl	$16, %edi
 168      00
 169 0071 BA000000 		movl	$0, %edx
 169      00
 170 0076 48F7F7   		divq	%rdi
 171 0079 486BC010 		imulq	$16, %rax, %rax
 172 007d 4889C2   		movq	%rax, %rdx
 173 0080 4881E200 		andq	$-4096, %rdx
 173      F0FFFF
 174 0087 4889E6   		movq	%rsp, %rsi
 175 008a 4829D6   		subq	%rdx, %rsi
 176 008d 4889F2   		movq	%rsi, %rdx
 177              	.L3:
 178 0090 4839D4   		cmpq	%rdx, %rsp
 179 0093 7412     		je	.L4
 180 0095 4881EC00 		subq	$4096, %rsp
 180      100000
 181 009c 48838C24 		orq	$0, 4088(%rsp)
 181      F80F0000 
 181      00
 182 00a5 EBE9     		jmp	.L3
 183              	.L4:
 184 00a7 4889C2   		movq	%rax, %rdx
 185 00aa 81E2FF0F 		andl	$4095, %edx
 185      0000
 186 00b0 4829D4   		subq	%rdx, %rsp
 187 00b3 4889C2   		movq	%rax, %rdx
 188 00b6 81E2FF0F 		andl	$4095, %edx
 188      0000
 189 00bc 4885D2   		testq	%rdx, %rdx
 190 00bf 7410     		je	.L5
 191 00c1 25FF0F00 		andl	$4095, %eax
 191      00
 192 00c6 4883E808 		subq	$8, %rax
 193 00ca 4801E0   		addq	%rsp, %rax
 194 00cd 48830800 		orq	$0, (%rax)
 195              	.L5:
 196 00d1 4889E0   		movq	%rsp, %rax
 197 00d4 4883C00F 		addq	$15, %rax
 198 00d8 48C1E804 		shrq	$4, %rax
 199 00dc 48C1E004 		salq	$4, %rax
 200 00e0 4889C7   		movq	%rax, %rdi
 201 00e3 488B45E8 		movq	-24(%rbp), %rax
 202 00e7 4889CA   		movq	%rcx, %rdx
 203 00ea 4889C6   		movq	%rax, %rsi
 204 00ed E8000000 		call	memcpy@PLT
 204      00
 205 00f2 488945E8 		movq	%rax, -24(%rbp)
  38:TestLibrary.c **** 	Texts_WriteString(&TestLibrary_W, Texts_Writer__typ, s, s__len);
 207              	.LM6:
 208 00f6 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 208      000000
 209 00fd 488B00   		movq	(%rax), %rax
 210 0100 488B4DE0 		movq	-32(%rbp), %rcx
 211 0104 488B55E8 		movq	-24(%rbp), %rdx
 212 0108 4889C6   		movq	%rax, %rsi
 213 010b 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 213      000000
 214 0112 E8000000 		call	Texts_WriteString@PLT
 214      00
  39:TestLibrary.c **** 	__DEL(s);
  40:TestLibrary.c **** }
 216              	.LM7:
 217 0117 90       		nop
 218 0118 488B45F8 		movq	-8(%rbp), %rax
 219 011c 64483304 		xorq	%fs:40, %rax
 219      25280000 
 219      00
 220 0125 7405     		je	.L6
 221 0127 E8000000 		call	__stack_chk_fail@PLT
 221      00
 222              	.L6:
 223 012c C9       		leave
 224              		.cfi_def_cfa 7, 8
 225 012d C3       		ret
 226              		.cfi_endproc
 227              	.LFE8:
 229              	.Lscope2:
 231              		.stabd	78,0,0
 236              	TestLibrary_ti:
 237              		.stabd	46,0,0
  41:TestLibrary.c **** 
  42:TestLibrary.c **** static void TestLibrary_ti (INT32 i, INT32 n)
  43:TestLibrary.c **** {
 239              	.LM8:
 240              	.LFBB3:
 241              	.LFB9:
 242              		.cfi_startproc
 243 012e F30F1EFA 		endbr64
 244 0132 55       		pushq	%rbp
 245              		.cfi_def_cfa_offset 16
 246              		.cfi_offset 6, -16
 247 0133 4889E5   		movq	%rsp, %rbp
 248              		.cfi_def_cfa_register 6
 249 0136 4883EC10 		subq	$16, %rsp
 250 013a 897DFC   		movl	%edi, -4(%rbp)
 251 013d 8975F8   		movl	%esi, -8(%rbp)
  44:TestLibrary.c **** 	Texts_WriteInt(&TestLibrary_W, Texts_Writer__typ, i, n);
 253              	.LM9:
 254 0140 8B45F8   		movl	-8(%rbp), %eax
 255 0143 4863C8   		movslq	%eax, %rcx
 256 0146 8B45FC   		movl	-4(%rbp), %eax
 257 0149 4863D0   		movslq	%eax, %rdx
 258 014c 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 258      000000
 259 0153 488B00   		movq	(%rax), %rax
 260 0156 4889C6   		movq	%rax, %rsi
 261 0159 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 261      000000
 262 0160 E8000000 		call	Texts_WriteInt@PLT
 262      00
  45:TestLibrary.c **** }
 264              	.LM10:
 265 0165 90       		nop
 266 0166 C9       		leave
 267              		.cfi_def_cfa 7, 8
 268 0167 C3       		ret
 269              		.cfi_endproc
 270              	.LFE9:
 272              	.Lscope3:
 274              		.stabd	78,0,0
 279              	TestLibrary_tr:
 280              		.stabd	46,0,0
  46:TestLibrary.c **** 
  47:TestLibrary.c **** static void TestLibrary_tr (LONGREAL r, INT16 n)
  48:TestLibrary.c **** {
 282              	.LM11:
 283              	.LFBB4:
 284              	.LFB10:
 285              		.cfi_startproc
 286 0168 F30F1EFA 		endbr64
 287 016c 55       		pushq	%rbp
 288              		.cfi_def_cfa_offset 16
 289              		.cfi_offset 6, -16
 290 016d 4889E5   		movq	%rsp, %rbp
 291              		.cfi_def_cfa_register 6
 292 0170 4883EC10 		subq	$16, %rsp
 293 0174 F20F1145 		movsd	%xmm0, -8(%rbp)
 293      F8
 294 0179 89F8     		movl	%edi, %eax
 295 017b 668945F4 		movw	%ax, -12(%rbp)
  49:TestLibrary.c **** 	Texts_WriteLongReal(&TestLibrary_W, Texts_Writer__typ, r, n);
 297              	.LM12:
 298 017f 0FBF55F4 		movswl	-12(%rbp), %edx
 299 0183 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 299      000000
 300 018a 488B00   		movq	(%rax), %rax
 301 018d 488B4DF8 		movq	-8(%rbp), %rcx
 302 0191 66480F6E 		movq	%rcx, %xmm0
 302      C1
 303 0196 4889C6   		movq	%rax, %rsi
 304 0199 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 304      000000
 305 01a0 E8000000 		call	Texts_WriteLongReal@PLT
 305      00
  50:TestLibrary.c **** }
 307              	.LM13:
 308 01a5 90       		nop
 309 01a6 C9       		leave
 310              		.cfi_def_cfa 7, 8
 311 01a7 C3       		ret
 312              		.cfi_endproc
 313              	.LFE10:
 315              	.Lscope4:
 317              		.stabd	78,0,0
 320              	TestLibrary_tn:
 321              		.stabd	46,0,0
  51:TestLibrary.c **** 
  52:TestLibrary.c **** static void TestLibrary_tn (void)
  53:TestLibrary.c **** {
 323              	.LM14:
 324              	.LFBB5:
 325              	.LFB11:
 326              		.cfi_startproc
 327 01a8 F30F1EFA 		endbr64
 328 01ac 55       		pushq	%rbp
 329              		.cfi_def_cfa_offset 16
 330              		.cfi_offset 6, -16
 331 01ad 4889E5   		movq	%rsp, %rbp
 332              		.cfi_def_cfa_register 6
  54:TestLibrary.c **** 	Texts_WriteLn(&TestLibrary_W, Texts_Writer__typ);
 334              	.LM15:
 335 01b0 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 335      000000
 336 01b7 488B00   		movq	(%rax), %rax
 337 01ba 4889C6   		movq	%rax, %rsi
 338 01bd 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 338      000000
 339 01c4 E8000000 		call	Texts_WriteLn@PLT
 339      00
  55:TestLibrary.c **** 	Texts_Append(Oberon_Log, TestLibrary_W.buf);
 341              	.LM16:
 342 01c9 488B1500 		movq	TestLibrary_W(%rip), %rdx
 342      000000
 343 01d0 488B0500 		movq	Oberon_Log@GOTPCREL(%rip), %rax
 343      000000
 344 01d7 488B00   		movq	(%rax), %rax
 345 01da 4889D6   		movq	%rdx, %rsi
 346 01dd 4889C7   		movq	%rax, %rdi
 347 01e0 E8000000 		call	Texts_Append@PLT
 347      00
  56:TestLibrary.c **** }
 349              	.LM17:
 350 01e5 90       		nop
 351 01e6 5D       		popq	%rbp
 352              		.cfi_def_cfa 7, 8
 353 01e7 C3       		ret
 354              		.cfi_endproc
 355              	.LFE11:
 357              	.Lscope5:
 359              		.stabd	78,0,0
 363              	TestLibrary_TestConvert:
 364              		.stabd	46,0,0
  57:TestLibrary.c **** 
  58:TestLibrary.c **** static void TestLibrary_TestConvert (LONGREAL lr)
  59:TestLibrary.c **** {
 366              	.LM18:
 367              	.LFBB6:
 368              	.LFB12:
 369              		.cfi_startproc
 370 01e8 F30F1EFA 		endbr64
 371 01ec 55       		pushq	%rbp
 372              		.cfi_def_cfa_offset 16
 373              		.cfi_offset 6, -16
 374 01ed 4889E5   		movq	%rsp, %rbp
 375              		.cfi_def_cfa_register 6
 376 01f0 4883EC40 		subq	$64, %rsp
 377 01f4 F20F1145 		movsd	%xmm0, -56(%rbp)
 377      C8
 379              	.LM19:
 380 01f9 64488B04 		movq	%fs:40, %rax
 380      25280000 
 380      00
 381 0202 488945F8 		movq	%rax, -8(%rbp)
 382 0206 31C0     		xorl	%eax, %eax
  60:TestLibrary.c **** 	CHAR str[20];
  61:TestLibrary.c **** 	INT16 i;
  62:TestLibrary.c **** 	Reals_ConvertL(lr, 6, (void*)str, 20);
 384              	.LM20:
 385 0208 488D4DE0 		leaq	-32(%rbp), %rcx
 386 020c 488B45C8 		movq	-56(%rbp), %rax
 387 0210 BA140000 		movl	$20, %edx
 387      00
 388 0215 4889CE   		movq	%rcx, %rsi
 389 0218 BF060000 		movl	$6, %edi
 389      00
 390 021d 66480F6E 		movq	%rax, %xmm0
 390      C0
 391 0222 E8000000 		call	Reals_ConvertL@PLT
 391      00
  63:TestLibrary.c **** 	i = 6;
 393              	.LM21:
 394 0227 66C745DE 		movw	$6, -34(%rbp)
 394      0600
  64:TestLibrary.c **** 	while (i > 0) {
 396              	.LM22:
 397 022d EB38     		jmp	.L11
 398              	.L14:
  65:TestLibrary.c **** 		i -= 1;
 400              	.LM23:
 401 022f 0FB745DE 		movzwl	-34(%rbp), %eax
 402 0233 83E801   		subl	$1, %eax
 403 0236 668945DE 		movw	%ax, -34(%rbp)
  66:TestLibrary.c **** 		TestLibrary_tc(str[__X(i, 20)]);
 405              	.LM24:
 406 023a 66837DDE 		cmpw	$19, -34(%rbp)
 406      13
 407 023f 7F06     		jg	.L12
 409              	.LM25:
 410 0241 0FBF45DE 		movswl	-34(%rbp), %eax
 411 0245 EB0F     		jmp	.L13
 412              	.L12:
 414              	.LM26:
 415 0247 BFFEFFFF 		movl	$-2, %edi
 415      FF
 416 024c E8000000 		call	Modules_Halt@PLT
 416      00
 417 0251 B8000000 		movl	$0, %eax
 417      00
 418              	.L13:
 420              	.LM27:
 421 0256 4898     		cltq
 422 0258 0FB64405 		movzbl	-32(%rbp,%rax), %eax
 422      E0
 424              	.LM28:
 425 025d 0FB6C0   		movzbl	%al, %eax
 426 0260 89C7     		movl	%eax, %edi
 427 0262 E899FDFF 		call	TestLibrary_tc
 427      FF
 428              	.L11:
  64:TestLibrary.c **** 	while (i > 0) {
 430              	.LM29:
 431 0267 66837DDE 		cmpw	$0, -34(%rbp)
 431      00
 432 026c 7FC1     		jg	.L14
  67:TestLibrary.c **** 	}
  68:TestLibrary.c **** 	TestLibrary_tn();
 434              	.LM30:
 435 026e E835FFFF 		call	TestLibrary_tn
 435      FF
  69:TestLibrary.c **** }
 437              	.LM31:
 438 0273 90       		nop
 439 0274 488B45F8 		movq	-8(%rbp), %rax
 440 0278 64483304 		xorq	%fs:40, %rax
 440      25280000 
 440      00
 441 0281 7405     		je	.L15
 442 0283 E8000000 		call	__stack_chk_fail@PLT
 442      00
 443              	.L15:
 444 0288 C9       		leave
 445              		.cfi_def_cfa 7, 8
 446 0289 C3       		ret
 447              		.cfi_endproc
 448              	.LFE12:
 454              	.Lscope6:
 456              		.stabd	78,0,0
 460              	TestLibrary_TestHex:
 461              		.stabd	46,0,0
  70:TestLibrary.c **** 
  71:TestLibrary.c **** static void TestLibrary_TestHex (REAL r)
  72:TestLibrary.c **** {
 463              	.LM32:
 464              	.LFBB7:
 465              	.LFB13:
 466              		.cfi_startproc
 467 028a F30F1EFA 		endbr64
 468 028e 55       		pushq	%rbp
 469              		.cfi_def_cfa_offset 16
 470              		.cfi_offset 6, -16
 471 028f 4889E5   		movq	%rsp, %rbp
 472              		.cfi_def_cfa_register 6
 473 0292 4883EC30 		subq	$48, %rsp
 474 0296 F30F1145 		movss	%xmm0, -36(%rbp)
 474      DC
 476              	.LM33:
 477 029b 64488B04 		movq	%fs:40, %rax
 477      25280000 
 477      00
 478 02a4 488945F8 		movq	%rax, -8(%rbp)
 479 02a8 31C0     		xorl	%eax, %eax
  73:TestLibrary.c **** 	CHAR str[20];
  74:TestLibrary.c **** 	Reals_ConvertH(r, (void*)str, 20);
 481              	.LM34:
 482 02aa 488D55E0 		leaq	-32(%rbp), %rdx
 483 02ae 8B45DC   		movl	-36(%rbp), %eax
 484 02b1 BE140000 		movl	$20, %esi
 484      00
 485 02b6 4889D7   		movq	%rdx, %rdi
 486 02b9 660F6EC0 		movd	%eax, %xmm0
 487 02bd E8000000 		call	Reals_ConvertH@PLT
 487      00
  75:TestLibrary.c **** 	str[8] = 0x00;
 489              	.LM35:
 490 02c2 C645E800 		movb	$0, -24(%rbp)
  76:TestLibrary.c **** 	TestLibrary_ts(str, 20);
 492              	.LM36:
 493 02c6 488D45E0 		leaq	-32(%rbp), %rax
 494 02ca BE140000 		movl	$20, %esi
 494      00
 495 02cf 4889C7   		movq	%rax, %rdi
 496 02d2 E85AFDFF 		call	TestLibrary_ts
 496      FF
  77:TestLibrary.c **** 	TestLibrary_tn();
 498              	.LM37:
 499 02d7 E8CCFEFF 		call	TestLibrary_tn
 499      FF
  78:TestLibrary.c **** }
 501              	.LM38:
 502 02dc 90       		nop
 503 02dd 488B45F8 		movq	-8(%rbp), %rax
 504 02e1 64483304 		xorq	%fs:40, %rax
 504      25280000 
 504      00
 505 02ea 7405     		je	.L17
 506 02ec E8000000 		call	__stack_chk_fail@PLT
 506      00
 507              	.L17:
 508 02f1 C9       		leave
 509              		.cfi_def_cfa 7, 8
 510 02f2 C3       		ret
 511              		.cfi_endproc
 512              	.LFE13:
 517              	.Lscope7:
 519              		.stabd	78,0,0
 520              		.section	.rodata
 521              	.LC0:
 522 0000 72203D20 		.string	"r = "
 522      00
 523              	.LC1:
 524 0005 2C206920 		.string	", i = "
 524      3D2000
 525              	.LC2:
 526 000c 202D3E20 		.string	" -> r = "
 526      72203D20 
 526      00
 527              		.text
 532              	TestLibrary_TestSetExpo:
 533              		.stabd	46,0,0
  79:TestLibrary.c **** 
  80:TestLibrary.c **** static void TestLibrary_TestSetExpo (REAL r, INT16 i)
  81:TestLibrary.c **** {
 535              	.LM39:
 536              	.LFBB8:
 537              	.LFB14:
 538              		.cfi_startproc
 539 02f3 F30F1EFA 		endbr64
 540 02f7 55       		pushq	%rbp
 541              		.cfi_def_cfa_offset 16
 542              		.cfi_offset 6, -16
 543 02f8 4889E5   		movq	%rsp, %rbp
 544              		.cfi_def_cfa_register 6
 545 02fb 4883EC10 		subq	$16, %rsp
 546 02ff F30F1145 		movss	%xmm0, -4(%rbp)
 546      FC
 547 0304 89F8     		movl	%edi, %eax
 548 0306 668945F8 		movw	%ax, -8(%rbp)
  82:TestLibrary.c **** 	TestLibrary_ts((CHAR*)"r = ", 5);
 550              	.LM40:
 551 030a BE050000 		movl	$5, %esi
 551      00
 552 030f 488D3D00 		leaq	.LC0(%rip), %rdi
 552      000000
 553 0316 E816FDFF 		call	TestLibrary_ts
 553      FF
  83:TestLibrary.c **** 	TestLibrary_tr(r, 10);
 555              	.LM41:
 556 031b F30F1045 		movss	-4(%rbp), %xmm0
 556      FC
 557 0320 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 558 0324 BF0A0000 		movl	$10, %edi
 558      00
 559 0329 E83AFEFF 		call	TestLibrary_tr
 559      FF
  84:TestLibrary.c **** 	TestLibrary_ts((CHAR*)", i = ", 7);
 561              	.LM42:
 562 032e BE070000 		movl	$7, %esi
 562      00
 563 0333 488D3D00 		leaq	.LC1(%rip), %rdi
 563      000000
 564 033a E8F2FCFF 		call	TestLibrary_ts
 564      FF
  85:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo(r), 1);
 566              	.LM43:
 567 033f 8B45FC   		movl	-4(%rbp), %eax
 568 0342 660F6EC0 		movd	%eax, %xmm0
 569 0346 E8000000 		call	Reals_Expo@PLT
 569      00
 571              	.LM44:
 572 034b 98       		cwtl
 573 034c BE010000 		movl	$1, %esi
 573      00
 574 0351 89C7     		movl	%eax, %edi
 575 0353 E8D6FDFF 		call	TestLibrary_ti
 575      FF
  86:TestLibrary.c **** 	Reals_SetExpo(&r, i);
 577              	.LM45:
 578 0358 0FBF55F8 		movswl	-8(%rbp), %edx
 579 035c 488D45FC 		leaq	-4(%rbp), %rax
 580 0360 89D6     		movl	%edx, %esi
 581 0362 4889C7   		movq	%rax, %rdi
 582 0365 E8000000 		call	Reals_SetExpo@PLT
 582      00
  87:TestLibrary.c **** 	TestLibrary_ts((CHAR*)" -> r = ", 9);
 584              	.LM46:
 585 036a BE090000 		movl	$9, %esi
 585      00
 586 036f 488D3D00 		leaq	.LC2(%rip), %rdi
 586      000000
 587 0376 E8B6FCFF 		call	TestLibrary_ts
 587      FF
  88:TestLibrary.c **** 	TestLibrary_tr(r, 10);
 589              	.LM47:
 590 037b F30F1045 		movss	-4(%rbp), %xmm0
 590      FC
 591 0380 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 592 0384 BF0A0000 		movl	$10, %edi
 592      00
 593 0389 E8DAFDFF 		call	TestLibrary_tr
 593      FF
  89:TestLibrary.c **** 	TestLibrary_ts((CHAR*)", i = ", 7);
 595              	.LM48:
 596 038e BE070000 		movl	$7, %esi
 596      00
 597 0393 488D3D00 		leaq	.LC1(%rip), %rdi
 597      000000
 598 039a E892FCFF 		call	TestLibrary_ts
 598      FF
  90:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo(r), 1);
 600              	.LM49:
 601 039f 8B45FC   		movl	-4(%rbp), %eax
 602 03a2 660F6EC0 		movd	%eax, %xmm0
 603 03a6 E8000000 		call	Reals_Expo@PLT
 603      00
 605              	.LM50:
 606 03ab 98       		cwtl
 607 03ac BE010000 		movl	$1, %esi
 607      00
 608 03b1 89C7     		movl	%eax, %edi
 609 03b3 E876FDFF 		call	TestLibrary_ti
 609      FF
  91:TestLibrary.c **** 	TestLibrary_tn();
 611              	.LM51:
 612 03b8 E8EBFDFF 		call	TestLibrary_tn
 612      FF
  92:TestLibrary.c **** }
 614              	.LM52:
 615 03bd 90       		nop
 616 03be C9       		leave
 617              		.cfi_def_cfa 7, 8
 618 03bf C3       		ret
 619              		.cfi_endproc
 620              	.LFE14:
 622              	.Lscope8:
 624              		.stabd	78,0,0
 625              		.section	.rodata
 626              	.LC3:
 627 0015 2C206578 		.string	", exp = "
 627      70203D20 
 627      00
 628              		.text
 632              	TestLibrary_TestFractionPart:
 633              		.stabd	46,0,0
  93:TestLibrary.c **** 
  94:TestLibrary.c **** static void TestLibrary_TestFractionPart (REAL r)
  95:TestLibrary.c **** {
 635              	.LM53:
 636              	.LFBB9:
 637              	.LFB15:
 638              		.cfi_startproc
 639 03c0 F30F1EFA 		endbr64
 640 03c4 55       		pushq	%rbp
 641              		.cfi_def_cfa_offset 16
 642              		.cfi_offset 6, -16
 643 03c5 4889E5   		movq	%rsp, %rbp
 644              		.cfi_def_cfa_register 6
 645 03c8 4883EC10 		subq	$16, %rsp
 646 03cc F30F1145 		movss	%xmm0, -4(%rbp)
 646      FC
  96:TestLibrary.c **** 	TestLibrary_ts((CHAR*)"r = ", 5);
 648              	.LM54:
 649 03d1 BE050000 		movl	$5, %esi
 649      00
 650 03d6 488D3D00 		leaq	.LC0(%rip), %rdi
 650      000000
 651 03dd E84FFCFF 		call	TestLibrary_ts
 651      FF
  97:TestLibrary.c **** 	TestLibrary_tr(r, 14);
 653              	.LM55:
 654 03e2 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 654      FC
 655 03e7 BF0E0000 		movl	$14, %edi
 655      00
 656 03ec E877FDFF 		call	TestLibrary_tr
 656      FF
  98:TestLibrary.c **** 	TestLibrary_ts((CHAR*)", exp = ", 9);
 658              	.LM56:
 659 03f1 BE090000 		movl	$9, %esi
 659      00
 660 03f6 488D3D00 		leaq	.LC3(%rip), %rdi
 660      000000
 661 03fd E82FFCFF 		call	TestLibrary_ts
 661      FF
  99:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo(r), 1);
 663              	.LM57:
 664 0402 8B45FC   		movl	-4(%rbp), %eax
 665 0405 660F6EC0 		movd	%eax, %xmm0
 666 0409 E8000000 		call	Reals_Expo@PLT
 666      00
 668              	.LM58:
 669 040e 98       		cwtl
 670 040f BE010000 		movl	$1, %esi
 670      00
 671 0414 89C7     		movl	%eax, %edi
 672 0416 E813FDFF 		call	TestLibrary_ti
 672      FF
 100:TestLibrary.c **** 	r = oocLowReal_fraction(r);
 674              	.LM59:
 675 041b 8B45FC   		movl	-4(%rbp), %eax
 676 041e 660F6EC0 		movd	%eax, %xmm0
 677 0422 E8000000 		call	oocLowReal_fraction@PLT
 677      00
 678 0427 660F7EC0 		movd	%xmm0, %eax
 679 042b 8945FC   		movl	%eax, -4(%rbp)
 101:TestLibrary.c **** 	TestLibrary_ts((CHAR*)" -> r = ", 9);
 681              	.LM60:
 682 042e BE090000 		movl	$9, %esi
 682      00
 683 0433 488D3D00 		leaq	.LC2(%rip), %rdi
 683      000000
 684 043a E8F2FBFF 		call	TestLibrary_ts
 684      FF
 102:TestLibrary.c **** 	TestLibrary_tr(r, 14);
 686              	.LM61:
 687 043f F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 687      FC
 688 0444 BF0E0000 		movl	$14, %edi
 688      00
 689 0449 E81AFDFF 		call	TestLibrary_tr
 689      FF
 103:TestLibrary.c **** 	TestLibrary_ts((CHAR*)", exp = ", 9);
 691              	.LM62:
 692 044e BE090000 		movl	$9, %esi
 692      00
 693 0453 488D3D00 		leaq	.LC3(%rip), %rdi
 693      000000
 694 045a E8D2FBFF 		call	TestLibrary_ts
 694      FF
 104:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo(r), 1);
 696              	.LM63:
 697 045f 8B45FC   		movl	-4(%rbp), %eax
 698 0462 660F6EC0 		movd	%eax, %xmm0
 699 0466 E8000000 		call	Reals_Expo@PLT
 699      00
 701              	.LM64:
 702 046b 98       		cwtl
 703 046c BE010000 		movl	$1, %esi
 703      00
 704 0471 89C7     		movl	%eax, %edi
 705 0473 E8B6FCFF 		call	TestLibrary_ti
 705      FF
 105:TestLibrary.c **** 	TestLibrary_tn();
 707              	.LM65:
 708 0478 E82BFDFF 		call	TestLibrary_tn
 708      FF
 106:TestLibrary.c **** }
 710              	.LM66:
 711 047d 90       		nop
 712 047e C9       		leave
 713              		.cfi_def_cfa 7, 8
 714 047f C3       		ret
 715              		.cfi_endproc
 716              	.LFE15:
 718              	.Lscope9:
 720              		.stabd	78,0,0
 723              	TestLibrary_RealTests:
 724              		.stabd	46,0,0
 107:TestLibrary.c **** 
 108:TestLibrary.c **** static void TestLibrary_RealTests (void)
 109:TestLibrary.c **** {
 726              	.LM67:
 727              	.LFBB10:
 728              	.LFB16:
 729              		.cfi_startproc
 730 0480 F30F1EFA 		endbr64
 731 0484 55       		pushq	%rbp
 732              		.cfi_def_cfa_offset 16
 733              		.cfi_offset 6, -16
 734 0485 4889E5   		movq	%rsp, %rbp
 735              		.cfi_def_cfa_register 6
 736 0488 4883EC30 		subq	$48, %rsp
 738              	.LM68:
 739 048c 64488B04 		movq	%fs:40, %rax
 739      25280000 
 739      00
 740 0495 488945F8 		movq	%rax, -8(%rbp)
 741 0499 31C0     		xorl	%eax, %eax
 110:TestLibrary.c **** 	CHAR str[20];
 111:TestLibrary.c **** 	REAL r;
 112:TestLibrary.c **** 	TestLibrary_TestConvert((LONGREAL)1);
 743              	.LM69:
 744 049b 488B0500 		movq	.LC4(%rip), %rax
 744      000000
 745 04a2 66480F6E 		movq	%rax, %xmm0
 745      C0
 746 04a7 E83CFDFF 		call	TestLibrary_TestConvert
 746      FF
 113:TestLibrary.c **** 	TestLibrary_TestConvert(  1.50000000000000e+000);
 748              	.LM70:
 749 04ac 488B0500 		movq	.LC5(%rip), %rax
 749      000000
 750 04b3 66480F6E 		movq	%rax, %xmm0
 750      C0
 751 04b8 E82BFDFF 		call	TestLibrary_TestConvert
 751      FF
 114:TestLibrary.c **** 	TestLibrary_TestConvert((LONGREAL)2);
 753              	.LM71:
 754 04bd 488B0500 		movq	.LC6(%rip), %rax
 754      000000
 755 04c4 66480F6E 		movq	%rax, %xmm0
 755      C0
 756 04c9 E81AFDFF 		call	TestLibrary_TestConvert
 756      FF
 115:TestLibrary.c **** 	TestLibrary_TestConvert(  2.99000000953674e+000);
 758              	.LM72:
 759 04ce 488B0500 		movq	.LC7(%rip), %rax
 759      000000
 760 04d5 66480F6E 		movq	%rax, %xmm0
 760      C0
 761 04da E809FDFF 		call	TestLibrary_TestConvert
 761      FF
 116:TestLibrary.c **** 	TestLibrary_TestConvert((LONGREAL)3);
 763              	.LM73:
 764 04df 488B0500 		movq	.LC8(%rip), %rax
 764      000000
 765 04e6 66480F6E 		movq	%rax, %xmm0
 765      C0
 766 04eb E8F8FCFF 		call	TestLibrary_TestConvert
 766      FF
 117:TestLibrary.c **** 	TestLibrary_TestHex((REAL)1);
 768              	.LM74:
 769 04f0 F30F1005 		movss	.LC9(%rip), %xmm0
 769      00000000 
 770 04f8 E88DFDFF 		call	TestLibrary_TestHex
 770      FF
 118:TestLibrary.c **** 	TestLibrary_TestHex(  1.5000000e+000);
 772              	.LM75:
 773 04fd F30F1005 		movss	.LC10(%rip), %xmm0
 773      00000000 
 774 0505 E880FDFF 		call	TestLibrary_TestHex
 774      FF
 119:TestLibrary.c **** 	TestLibrary_TestHex((REAL)2);
 776              	.LM76:
 777 050a F30F1005 		movss	.LC11(%rip), %xmm0
 777      00000000 
 778 0512 E873FDFF 		call	TestLibrary_TestHex
 778      FF
 120:TestLibrary.c **** 	TestLibrary_TestHex(  2.9900000e+000);
 780              	.LM77:
 781 0517 F30F1005 		movss	.LC12(%rip), %xmm0
 781      00000000 
 782 051f E866FDFF 		call	TestLibrary_TestHex
 782      FF
 121:TestLibrary.c **** 	TestLibrary_TestHex((REAL)3);
 784              	.LM78:
 785 0524 F30F1005 		movss	.LC13(%rip), %xmm0
 785      00000000 
 786 052c E859FDFF 		call	TestLibrary_TestHex
 786      FF
 122:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo(  5.0000000e-001), 1);
 788              	.LM79:
 789 0531 F30F1005 		movss	.LC14(%rip), %xmm0
 789      00000000 
 790 0539 E8000000 		call	Reals_Expo@PLT
 790      00
 792              	.LM80:
 793 053e 98       		cwtl
 794 053f BE010000 		movl	$1, %esi
 794      00
 795 0544 89C7     		movl	%eax, %edi
 796 0546 E8E3FBFF 		call	TestLibrary_ti
 796      FF
 123:TestLibrary.c **** 	TestLibrary_tn();
 798              	.LM81:
 799 054b E858FCFF 		call	TestLibrary_tn
 799      FF
 124:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo((REAL)1), 1);
 801              	.LM82:
 802 0550 F30F1005 		movss	.LC9(%rip), %xmm0
 802      00000000 
 803 0558 E8000000 		call	Reals_Expo@PLT
 803      00
 805              	.LM83:
 806 055d 98       		cwtl
 807 055e BE010000 		movl	$1, %esi
 807      00
 808 0563 89C7     		movl	%eax, %edi
 809 0565 E8C4FBFF 		call	TestLibrary_ti
 809      FF
 125:TestLibrary.c **** 	TestLibrary_tn();
 811              	.LM84:
 812 056a E839FCFF 		call	TestLibrary_tn
 812      FF
 126:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo((REAL)2), 1);
 814              	.LM85:
 815 056f F30F1005 		movss	.LC11(%rip), %xmm0
 815      00000000 
 816 0577 E8000000 		call	Reals_Expo@PLT
 816      00
 818              	.LM86:
 819 057c 98       		cwtl
 820 057d BE010000 		movl	$1, %esi
 820      00
 821 0582 89C7     		movl	%eax, %edi
 822 0584 E8A5FBFF 		call	TestLibrary_ti
 822      FF
 127:TestLibrary.c **** 	TestLibrary_tn();
 824              	.LM87:
 825 0589 E81AFCFF 		call	TestLibrary_tn
 825      FF
 128:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo((REAL)3), 1);
 827              	.LM88:
 828 058e F30F1005 		movss	.LC13(%rip), %xmm0
 828      00000000 
 829 0596 E8000000 		call	Reals_Expo@PLT
 829      00
 831              	.LM89:
 832 059b 98       		cwtl
 833 059c BE010000 		movl	$1, %esi
 833      00
 834 05a1 89C7     		movl	%eax, %edi
 835 05a3 E886FBFF 		call	TestLibrary_ti
 835      FF
 129:TestLibrary.c **** 	TestLibrary_tn();
 837              	.LM90:
 838 05a8 E8FBFBFF 		call	TestLibrary_tn
 838      FF
 130:TestLibrary.c **** 	TestLibrary_ti(Reals_Expo((REAL)4), 1);
 840              	.LM91:
 841 05ad F30F1005 		movss	.LC15(%rip), %xmm0
 841      00000000 
 842 05b5 E8000000 		call	Reals_Expo@PLT
 842      00
 844              	.LM92:
 845 05ba 98       		cwtl
 846 05bb BE010000 		movl	$1, %esi
 846      00
 847 05c0 89C7     		movl	%eax, %edi
 848 05c2 E867FBFF 		call	TestLibrary_ti
 848      FF
 131:TestLibrary.c **** 	TestLibrary_tn();
 850              	.LM93:
 851 05c7 E8DCFBFF 		call	TestLibrary_tn
 851      FF
 132:TestLibrary.c **** 	TestLibrary_TestSetExpo((REAL)1, 129);
 853              	.LM94:
 854 05cc BF810000 		movl	$129, %edi
 854      00
 855 05d1 F30F1005 		movss	.LC9(%rip), %xmm0
 855      00000000 
 856 05d9 E815FDFF 		call	TestLibrary_TestSetExpo
 856      FF
 133:TestLibrary.c **** 	TestLibrary_TestSetExpo((REAL)-1, 129);
 858              	.LM95:
 859 05de BF810000 		movl	$129, %edi
 859      00
 860 05e3 F30F1005 		movss	.LC16(%rip), %xmm0
 860      00000000 
 861 05eb E803FDFF 		call	TestLibrary_TestSetExpo
 861      FF
 134:TestLibrary.c **** 	TestLibrary_TestSetExpo((REAL)2, 129);
 863              	.LM96:
 864 05f0 BF810000 		movl	$129, %edi
 864      00
 865 05f5 F30F1005 		movss	.LC11(%rip), %xmm0
 865      00000000 
 866 05fd E8F1FCFF 		call	TestLibrary_TestSetExpo
 866      FF
 135:TestLibrary.c **** 	TestLibrary_TestSetExpo((REAL)-4, 129);
 868              	.LM97:
 869 0602 BF810000 		movl	$129, %edi
 869      00
 870 0607 F30F1005 		movss	.LC17(%rip), %xmm0
 870      00000000 
 871 060f E8DFFCFF 		call	TestLibrary_TestSetExpo
 871      FF
 136:TestLibrary.c **** 	TestLibrary_TestSetExpo(  1.5000000e+000, 129);
 873              	.LM98:
 874 0614 BF810000 		movl	$129, %edi
 874      00
 875 0619 F30F1005 		movss	.LC10(%rip), %xmm0
 875      00000000 
 876 0621 E8CDFCFF 		call	TestLibrary_TestSetExpo
 876      FF
 137:TestLibrary.c **** 	TestLibrary_TestSetExpo( -1.5000000e+000, 129);
 878              	.LM99:
 879 0626 BF810000 		movl	$129, %edi
 879      00
 880 062b F30F1005 		movss	.LC18(%rip), %xmm0
 880      00000000 
 881 0633 E8BBFCFF 		call	TestLibrary_TestSetExpo
 881      FF
 138:TestLibrary.c **** 	TestLibrary_TestFractionPart(  1.2340000e+000);
 883              	.LM100:
 884 0638 F30F1005 		movss	.LC19(%rip), %xmm0
 884      00000000 
 885 0640 E87BFDFF 		call	TestLibrary_TestFractionPart
 885      FF
 139:TestLibrary.c **** 	TestLibrary_TestFractionPart( -1.2340000e+000);
 887              	.LM101:
 888 0645 F30F1005 		movss	.LC20(%rip), %xmm0
 888      00000000 
 889 064d E86EFDFF 		call	TestLibrary_TestFractionPart
 889      FF
 140:TestLibrary.c **** 	TestLibrary_TestFractionPart(  3.2678001e+001);
 891              	.LM102:
 892 0652 F30F1005 		movss	.LC21(%rip), %xmm0
 892      00000000 
 893 065a E861FDFF 		call	TestLibrary_TestFractionPart
 893      FF
 141:TestLibrary.c **** 	TestLibrary_TestFractionPart( -3.2678001e+001);
 895              	.LM103:
 896 065f F30F1005 		movss	.LC22(%rip), %xmm0
 896      00000000 
 897 0667 E854FDFF 		call	TestLibrary_TestFractionPart
 897      FF
 142:TestLibrary.c **** 	r = (REAL)0;
 899              	.LM104:
 900 066c 660FEFC0 		pxor	%xmm0, %xmm0
 901 0670 F30F1145 		movss	%xmm0, -36(%rbp)
 901      DC
 143:TestLibrary.c **** 	__ASSERT(!oocLowReal_IsInfinity(r), 3);
 903              	.LM105:
 904 0675 8B45DC   		movl	-36(%rbp), %eax
 905 0678 660F6EC0 		movd	%eax, %xmm0
 906 067c E8000000 		call	oocLowReal_IsInfinity@PLT
 906      00
 907 0681 84C0     		testb	%al, %al
 908 0683 740A     		je	.L21
 910              	.LM106:
 911 0685 BF030000 		movl	$3, %edi
 911      00
 912 068a E8000000 		call	Modules_AssertFail@PLT
 912      00
 913              	.L21:
 144:TestLibrary.c **** 	__ASSERT(!oocLowReal_IsNaN(r), 4);
 915              	.LM107:
 916 068f 8B45DC   		movl	-36(%rbp), %eax
 917 0692 660F6EC0 		movd	%eax, %xmm0
 918 0696 E8000000 		call	oocLowReal_IsNaN@PLT
 918      00
 919 069b 84C0     		testb	%al, %al
 920 069d 740A     		je	.L22
 922              	.LM108:
 923 069f BF040000 		movl	$4, %edi
 923      00
 924 06a4 E8000000 		call	Modules_AssertFail@PLT
 924      00
 925              	.L22:
 145:TestLibrary.c **** 	r = (REAL)0;
 927              	.LM109:
 928 06a9 660FEFC0 		pxor	%xmm0, %xmm0
 929 06ad F30F1145 		movss	%xmm0, -36(%rbp)
 929      DC
 146:TestLibrary.c **** 	Reals_SetExpo(&r, 255);
 931              	.LM110:
 932 06b2 488D45DC 		leaq	-36(%rbp), %rax
 933 06b6 BEFF0000 		movl	$255, %esi
 933      00
 934 06bb 4889C7   		movq	%rax, %rdi
 935 06be E8000000 		call	Reals_SetExpo@PLT
 935      00
 147:TestLibrary.c **** 	__ASSERT(oocLowReal_IsInfinity(r), 5);
 937              	.LM111:
 938 06c3 8B45DC   		movl	-36(%rbp), %eax
 939 06c6 660F6EC0 		movd	%eax, %xmm0
 940 06ca E8000000 		call	oocLowReal_IsInfinity@PLT
 940      00
 941 06cf 84C0     		testb	%al, %al
 942 06d1 750A     		jne	.L23
 944              	.LM112:
 945 06d3 BF050000 		movl	$5, %edi
 945      00
 946 06d8 E8000000 		call	Modules_AssertFail@PLT
 946      00
 947              	.L23:
 148:TestLibrary.c **** 	__ASSERT(!oocLowReal_IsNaN(r), 6);
 949              	.LM113:
 950 06dd 8B45DC   		movl	-36(%rbp), %eax
 951 06e0 660F6EC0 		movd	%eax, %xmm0
 952 06e4 E8000000 		call	oocLowReal_IsNaN@PLT
 952      00
 953 06e9 84C0     		testb	%al, %al
 954 06eb 740A     		je	.L24
 956              	.LM114:
 957 06ed BF060000 		movl	$6, %edi
 957      00
 958 06f2 E8000000 		call	Modules_AssertFail@PLT
 958      00
 959              	.L24:
 149:TestLibrary.c **** 	r =   1.2300000e-001;
 961              	.LM115:
 962 06f7 F30F1005 		movss	.LC24(%rip), %xmm0
 962      00000000 
 963 06ff F30F1145 		movss	%xmm0, -36(%rbp)
 963      DC
 150:TestLibrary.c **** 	Reals_SetExpo(&r, 255);
 965              	.LM116:
 966 0704 488D45DC 		leaq	-36(%rbp), %rax
 967 0708 BEFF0000 		movl	$255, %esi
 967      00
 968 070d 4889C7   		movq	%rax, %rdi
 969 0710 E8000000 		call	Reals_SetExpo@PLT
 969      00
 151:TestLibrary.c **** 	__ASSERT(!oocLowReal_IsInfinity(r), 7);
 971              	.LM117:
 972 0715 8B45DC   		movl	-36(%rbp), %eax
 973 0718 660F6EC0 		movd	%eax, %xmm0
 974 071c E8000000 		call	oocLowReal_IsInfinity@PLT
 974      00
 975 0721 84C0     		testb	%al, %al
 976 0723 740A     		je	.L25
 978              	.LM118:
 979 0725 BF070000 		movl	$7, %edi
 979      00
 980 072a E8000000 		call	Modules_AssertFail@PLT
 980      00
 981              	.L25:
 152:TestLibrary.c **** 	__ASSERT(oocLowReal_IsNaN(r), 8);
 983              	.LM119:
 984 072f 8B45DC   		movl	-36(%rbp), %eax
 985 0732 660F6EC0 		movd	%eax, %xmm0
 986 0736 E8000000 		call	oocLowReal_IsNaN@PLT
 986      00
 987 073b 84C0     		testb	%al, %al
 988 073d 750A     		jne	.L28
 990              	.LM120:
 991 073f BF080000 		movl	$8, %edi
 991      00
 992 0744 E8000000 		call	Modules_AssertFail@PLT
 992      00
 993              	.L28:
 153:TestLibrary.c **** }
 995              	.LM121:
 996 0749 90       		nop
 997 074a 488B45F8 		movq	-8(%rbp), %rax
 998 074e 64483304 		xorq	%fs:40, %rax
 998      25280000 
 998      00
 999 0757 7405     		je	.L27
 1000 0759 E8000000 		call	__stack_chk_fail@PLT
 1000      00
 1001              	.L27:
 1002 075e C9       		leave
 1003              		.cfi_def_cfa 7, 8
 1004 075f C3       		ret
 1005              		.cfi_endproc
 1006              	.LFE16:
 1012              	.Lscope10:
 1014              		.stabd	78,0,0
 1018              	EnumPtrs:
 1019              		.stabd	46,0,0
 154:TestLibrary.c **** 
 155:TestLibrary.c **** static void EnumPtrs(void (*P)(void*))
 156:TestLibrary.c **** {
 1021              	.LM122:
 1022              	.LFBB11:
 1023              	.LFB17:
 1024              		.cfi_startproc
 1025 0760 F30F1EFA 		endbr64
 1026 0764 55       		pushq	%rbp
 1027              		.cfi_def_cfa_offset 16
 1028              		.cfi_offset 6, -16
 1029 0765 4889E5   		movq	%rsp, %rbp
 1030              		.cfi_def_cfa_register 6
 1031 0768 4883EC10 		subq	$16, %rsp
 1032 076c 48897DF8 		movq	%rdi, -8(%rbp)
 157:TestLibrary.c **** 	__ENUMR(&TestLibrary_W, Texts_Writer__typ, 56, 1, P);
 1034              	.LM123:
 1035 0770 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 1035      000000
 1036 0777 488B00   		movq	(%rax), %rax
 1037 077a 488B55F8 		movq	-8(%rbp), %rdx
 1038 077e 4989D0   		movq	%rdx, %r8
 1039 0781 B9010000 		movl	$1, %ecx
 1039      00
 1040 0786 BA380000 		movl	$56, %edx
 1040      00
 1041 078b 4889C6   		movq	%rax, %rsi
 1042 078e 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 1042      000000
 1043 0795 E8000000 		call	SYSTEM_ENUMR@PLT
 1043      00
 158:TestLibrary.c **** }
 1045              	.LM124:
 1046 079a 90       		nop
 1047 079b C9       		leave
 1048              		.cfi_def_cfa 7, 8
 1049 079c C3       		ret
 1050              		.cfi_endproc
 1051              	.LFE17:
 1053              	.Lscope11:
 1055              		.stabd	78,0,0
 1056              		.section	.rodata
 1057              	.LC25:
 1058 001e 54657374 		.string	"TestLibrary"
 1058      4C696272 
 1058      61727900 
 1059              	.LC26:
 1060 002a 4C696272 		.string	"Library tests successful."
 1060      61727920 
 1060      74657374 
 1060      73207375 
 1060      63636573 
 1061              		.text
 1065              		.globl	main
 1067              	main:
 1068              		.stabd	46,0,0
 159:TestLibrary.c **** 
 160:TestLibrary.c **** 
 161:TestLibrary.c **** export int main(int argc, char **argv)
 162:TestLibrary.c **** {
 1070              	.LM125:
 1071              	.LFBB12:
 1072              	.LFB18:
 1073              		.cfi_startproc
 1074 079d F30F1EFA 		endbr64
 1075 07a1 55       		pushq	%rbp
 1076              		.cfi_def_cfa_offset 16
 1077              		.cfi_offset 6, -16
 1078 07a2 4889E5   		movq	%rsp, %rbp
 1079              		.cfi_def_cfa_register 6
 1080 07a5 4883EC10 		subq	$16, %rsp
 1081 07a9 897DFC   		movl	%edi, -4(%rbp)
 1082 07ac 488975F0 		movq	%rsi, -16(%rbp)
 163:TestLibrary.c **** 	__INIT(argc, argv);
 1084              	.LM126:
 1085 07b0 488D55F0 		leaq	-16(%rbp), %rdx
 1086 07b4 8B45FC   		movl	-4(%rbp), %eax
 1087 07b7 4889D6   		movq	%rdx, %rsi
 1088 07ba 89C7     		movl	%eax, %edi
 1089 07bc E8000000 		call	Modules_Init@PLT
 1089      00
 164:TestLibrary.c **** 	__MODULE_IMPORT(Oberon);
 1091              	.LM127:
 1092 07c1 E8000000 		call	Oberon__init@PLT
 1092      00
 1093 07c6 4889C7   		movq	%rax, %rdi
 1094 07c9 B8000000 		movl	$0, %eax
 1094      00
 1095 07ce E8000000 		call	Heap_INCREF@PLT
 1095      00
 165:TestLibrary.c **** 	__MODULE_IMPORT(Reals);
 1097              	.LM128:
 1098 07d3 E8000000 		call	Reals__init@PLT
 1098      00
 1099 07d8 4889C7   		movq	%rax, %rdi
 1100 07db B8000000 		movl	$0, %eax
 1100      00
 1101 07e0 E8000000 		call	Heap_INCREF@PLT
 1101      00
 166:TestLibrary.c **** 	__MODULE_IMPORT(Texts);
 1103              	.LM129:
 1104 07e5 E8000000 		call	Texts__init@PLT
 1104      00
 1105 07ea 4889C7   		movq	%rax, %rdi
 1106 07ed B8000000 		movl	$0, %eax
 1106      00
 1107 07f2 E8000000 		call	Heap_INCREF@PLT
 1107      00
 167:TestLibrary.c **** 	__MODULE_IMPORT(oocLowReal);
 1109              	.LM130:
 1110 07f7 E8000000 		call	oocLowReal__init@PLT
 1110      00
 1111 07fc 4889C7   		movq	%rax, %rdi
 1112 07ff B8000000 		movl	$0, %eax
 1112      00
 1113 0804 E8000000 		call	Heap_INCREF@PLT
 1113      00
 168:TestLibrary.c **** 	__REGMAIN("TestLibrary", EnumPtrs);
 1115              	.LM131:
 1116 0809 488D3550 		leaq	EnumPtrs(%rip), %rsi
 1116      FFFFFF
 1117 0810 488D3D00 		leaq	.LC25(%rip), %rdi
 1117      000000
 1118 0817 B8000000 		movl	$0, %eax
 1118      00
 1119 081c E8000000 		call	Heap_REGMOD@PLT
 1119      00
 1120 0821 48890500 		movq	%rax, m.2592(%rip)
 1120      000000
 169:TestLibrary.c **** /* BEGIN */
 170:TestLibrary.c **** 	Texts_OpenWriter(&TestLibrary_W, Texts_Writer__typ);
 1122              	.LM132:
 1123 0828 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 1123      000000
 1124 082f 488B00   		movq	(%rax), %rax
 1125 0832 4889C6   		movq	%rax, %rsi
 1126 0835 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 1126      000000
 1127 083c E8000000 		call	Texts_OpenWriter@PLT
 1127      00
 171:TestLibrary.c **** 	TestLibrary_RealTests();
 1129              	.LM133:
 1130 0841 E83AFCFF 		call	TestLibrary_RealTests
 1130      FF
 172:TestLibrary.c **** 	TestLibrary_ts((CHAR*)"Library tests successful.", 26);
 1132              	.LM134:
 1133 0846 BE1A0000 		movl	$26, %esi
 1133      00
 1134 084b 488D3D00 		leaq	.LC26(%rip), %rdi
 1134      000000
 1135 0852 E8DAF7FF 		call	TestLibrary_ts
 1135      FF
 173:TestLibrary.c **** 	TestLibrary_tn();
 1137              	.LM135:
 1138 0857 E84CF9FF 		call	TestLibrary_tn
 1138      FF
 174:TestLibrary.c **** 	__FINI;
 1140              	.LM136:
 1141 085c B8000000 		movl	$0, %eax
 1141      00
 1142 0861 E8000000 		call	Heap_FINALL@PLT
 1142      00
 1143 0866 B8000000 		movl	$0, %eax
 1143      00
 175:TestLibrary.c **** }
 1145              	.LM137:
 1146 086b C9       		leave
 1147              		.cfi_def_cfa 7, 8
 1148 086c C3       		ret
 1149              		.cfi_endproc
 1150              	.LFE18:
 1155              	.Lscope12:
 1157              		.stabd	78,0,0
 1158              		.local	m.2592
 1159              		.comm	m.2592,8,8
 1161              		.section	.rodata
 1162 0044 00000000 		.align 8
 1163              	.LC4:
 1164 0048 00000000 		.long	0
 1165 004c 0000F03F 		.long	1072693248
 1166              		.align 8
 1167              	.LC5:
 1168 0050 00000000 		.long	0
 1169 0054 0000F83F 		.long	1073217536
 1170              		.align 8
 1171              	.LC6:
 1172 0058 00000000 		.long	0
 1173 005c 00000040 		.long	1073741824
 1174              		.align 8
 1175              	.LC7:
 1176 0060 F9FFFF1F 		.long	536870905
 1177 0064 85EB0740 		.long	1074260869
 1178              		.align 8
 1179              	.LC8:
 1180 0068 00000000 		.long	0
 1181 006c 00000840 		.long	1074266112
 1182              		.align 4
 1183              	.LC9:
 1184 0070 0000803F 		.long	1065353216
 1185              		.align 4
 1186              	.LC10:
 1187 0074 0000C03F 		.long	1069547520
 1188              		.align 4
 1189              	.LC11:
 1190 0078 00000040 		.long	1073741824
 1191              		.align 4
 1192              	.LC12:
 1193 007c 295C3F40 		.long	1077894185
 1194              		.align 4
 1195              	.LC13:
 1196 0080 00004040 		.long	1077936128
 1197              		.align 4
 1198              	.LC14:
 1199 0084 0000003F 		.long	1056964608
 1200              		.align 4
 1201              	.LC15:
 1202 0088 00008040 		.long	1082130432
 1203              		.align 4
 1204              	.LC16:
 1205 008c 000080BF 		.long	3212836864
 1206              		.align 4
 1207              	.LC17:
 1208 0090 000080C0 		.long	3229614080
 1209              		.align 4
 1210              	.LC18:
 1211 0094 0000C0BF 		.long	3217031168
 1212              		.align 4
 1213              	.LC19:
 1214 0098 B6F39D3F 		.long	1067316150
 1215              		.align 4
 1216              	.LC20:
 1217 009c B6F39DBF 		.long	3214799798
 1218              		.align 4
 1219              	.LC21:
 1220 00a0 46B60242 		.long	1107473990
 1221              		.align 4
 1222              	.LC22:
 1223 00a4 46B602C2 		.long	3254957638
 1224              		.align 4
 1225              	.LC24:
 1226 00a8 6DE7FB3D 		.long	1039918957
 1227              		.text
 1229              	.Letext0:
 1230              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 1231              		.section	.note.GNU-stack,"",@progbits
 1232              		.section	.note.gnu.property,"a"
 1233              		.align 8
 1234 0000 04000000 		.long	 1f - 0f
 1235 0004 10000000 		.long	 4f - 1f
 1236 0008 05000000 		.long	 5
 1237              	0:
 1238 000c 474E5500 		.string	 "GNU"
 1239              	1:
 1240              		.align 8
 1241 0010 020000C0 		.long	 0xc0000002
 1242 0014 04000000 		.long	 3f - 2f
 1243              	2:
 1244 0018 03000000 		.long	 0x3
 1245              	3:
 1246 001c 00000000 		.align 8
 1247              	4:
