   1              		.file	"mathtest.c"
   4              		.text
   5              	.Ltext0:
  56              		.local	mathtest_r
  57              		.comm	mathtest_r,4,4
  59              		.local	mathtest_lr
  60              		.comm	mathtest_lr,8,8
  62              		.local	mathtest_misc
  63              		.comm	mathtest_misc,808,32
  65              		.local	mathtest_angles
  66              		.comm	mathtest_angles,808,32
  68              		.comm	mathtest_Values__typ,8,8
  73              	mathtest_wc:
  74              		.stabd	46,0,0
   1:mathtest.c    **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:mathtest.c    **** 
   3:mathtest.c    **** #define SHORTINT INT16
   4:mathtest.c    **** #define INTEGER  INT32
   5:mathtest.c    **** #define LONGINT  INT64
   6:mathtest.c    **** #define SET      UINT32
   7:mathtest.c    **** 
   8:mathtest.c    **** #include "SYSTEM.h"
   9:mathtest.c    **** #include "Math.h"
  10:mathtest.c    **** #include "MathL.h"
  11:mathtest.c    **** #include "Out.h"
  12:mathtest.c    **** 
  13:mathtest.c    **** typedef
  14:mathtest.c    **** 	INT64 (*mathtest_LRtoLI)(LONGREAL);
  15:mathtest.c    **** 
  16:mathtest.c    **** typedef
  17:mathtest.c    **** 	LONGREAL (*mathtest_LRtoLR)(LONGREAL);
  18:mathtest.c    **** 
  19:mathtest.c    **** typedef
  20:mathtest.c    **** 	INT64 (*mathtest_RtoLI)(REAL);
  21:mathtest.c    **** 
  22:mathtest.c    **** typedef
  23:mathtest.c    **** 	REAL (*mathtest_RtoR)(REAL);
  24:mathtest.c    **** 
  25:mathtest.c    **** typedef
  26:mathtest.c    **** 	struct mathtest_Values {
  27:mathtest.c    **** 		LONGREAL v[100];
  28:mathtest.c    **** 		INT32 n;
  29:mathtest.c    **** 	} mathtest_Values;
  30:mathtest.c    **** 
  31:mathtest.c    **** 
  32:mathtest.c    **** static REAL mathtest_r;
  33:mathtest.c    **** static LONGREAL mathtest_lr;
  34:mathtest.c    **** static mathtest_Values mathtest_misc, mathtest_angles;
  35:mathtest.c    **** 
  36:mathtest.c    **** export ADDRESS *mathtest_Values__typ;
  37:mathtest.c    **** 
  38:mathtest.c    **** static void mathtest_MathErrorHandler (INT32 error);
  39:mathtest.c    **** static void mathtest_TestRtoLI (CHAR *s, ADDRESS s__len, mathtest_RtoLI p, mathtest_LRtoLI lp, math
  40:mathtest.c    **** static void mathtest_TestRtoR (CHAR *s, ADDRESS s__len, mathtest_RtoR p, mathtest_LRtoLR lp, mathte
  41:mathtest.c    **** static void mathtest_addvalue (LONGREAL lr, mathtest_Values *val, ADDRESS *val__typ);
  42:mathtest.c    **** static void mathtest_round (LONGREAL lr);
  43:mathtest.c    **** static void mathtest_sqrt (LONGREAL lr);
  44:mathtest.c    **** static void mathtest_wc (CHAR c);
  45:mathtest.c    **** static void mathtest_wh (SYSTEM_BYTE *h, ADDRESS h__len);
  46:mathtest.c    **** static void mathtest_wi (INT64 i);
  47:mathtest.c    **** static void mathtest_wl (void);
  48:mathtest.c    **** static void mathtest_wlr (LONGREAL lr);
  49:mathtest.c    **** static void mathtest_wr (REAL r);
  50:mathtest.c    **** static void mathtest_ws (CHAR *s, ADDRESS s__len);
  51:mathtest.c    **** 
  52:mathtest.c    **** 
  53:mathtest.c    **** static void mathtest_wc (CHAR c)
  54:mathtest.c    **** {
  76              	.LM0:
  77              	.LFBB1:
  78              	.LFB7:
  79              		.cfi_startproc
  80 0000 F30F1EFA 		endbr64
  81 0004 55       		pushq	%rbp
  82              		.cfi_def_cfa_offset 16
  83              		.cfi_offset 6, -16
  84 0005 4889E5   		movq	%rsp, %rbp
  85              		.cfi_def_cfa_register 6
  86 0008 4883EC10 		subq	$16, %rsp
  87 000c 89F8     		movl	%edi, %eax
  88 000e 8845FC   		movb	%al, -4(%rbp)
  55:mathtest.c    **** 	Out_Char(c);
  90              	.LM1:
  91 0011 0FB645FC 		movzbl	-4(%rbp), %eax
  92 0015 89C7     		movl	%eax, %edi
  93 0017 E8000000 		call	Out_Char@PLT
  93      00
  56:mathtest.c    **** }
  95              	.LM2:
  96 001c 90       		nop
  97 001d C9       		leave
  98              		.cfi_def_cfa 7, 8
  99 001e C3       		ret
 100              		.cfi_endproc
 101              	.LFE7:
 103              	.Lscope1:
 105              		.stabd	78,0,0
 110              	mathtest_ws:
 111              		.stabd	46,0,0
  57:mathtest.c    **** 
  58:mathtest.c    **** static void mathtest_ws (CHAR *s, ADDRESS s__len)
  59:mathtest.c    **** {
 113              	.LM3:
 114              	.LFBB2:
 115              	.LFB8:
 116              		.cfi_startproc
 117 001f F30F1EFA 		endbr64
 118 0023 55       		pushq	%rbp
 119              		.cfi_def_cfa_offset 16
 120              		.cfi_offset 6, -16
 121 0024 4889E5   		movq	%rsp, %rbp
 122              		.cfi_def_cfa_register 6
 123 0027 4883EC20 		subq	$32, %rsp
 124 002b 48897DE8 		movq	%rdi, -24(%rbp)
 125 002f 488975E0 		movq	%rsi, -32(%rbp)
 127              	.LM4:
 128 0033 64488B04 		movq	%fs:40, %rax
 128      25280000 
 128      00
 129 003c 488945F8 		movq	%rax, -8(%rbp)
 130 0040 31C0     		xorl	%eax, %eax
  60:mathtest.c    **** 	__DUP(s, s__len, CHAR);
 132              	.LM5:
 133 0042 488B4DE0 		movq	-32(%rbp), %rcx
 134 0046 488B45E0 		movq	-32(%rbp), %rax
 135 004a 488D5008 		leaq	8(%rax), %rdx
 136 004e B8100000 		movl	$16, %eax
 136      00
 137 0053 4883E801 		subq	$1, %rax
 138 0057 4801D0   		addq	%rdx, %rax
 139 005a BF100000 		movl	$16, %edi
 139      00
 140 005f BA000000 		movl	$0, %edx
 140      00
 141 0064 48F7F7   		divq	%rdi
 142 0067 486BC010 		imulq	$16, %rax, %rax
 143 006b 4889C2   		movq	%rax, %rdx
 144 006e 4881E200 		andq	$-4096, %rdx
 144      F0FFFF
 145 0075 4889E6   		movq	%rsp, %rsi
 146 0078 4829D6   		subq	%rdx, %rsi
 147 007b 4889F2   		movq	%rsi, %rdx
 148              	.L3:
 149 007e 4839D4   		cmpq	%rdx, %rsp
 150 0081 7412     		je	.L4
 151 0083 4881EC00 		subq	$4096, %rsp
 151      100000
 152 008a 48838C24 		orq	$0, 4088(%rsp)
 152      F80F0000 
 152      00
 153 0093 EBE9     		jmp	.L3
 154              	.L4:
 155 0095 4889C2   		movq	%rax, %rdx
 156 0098 81E2FF0F 		andl	$4095, %edx
 156      0000
 157 009e 4829D4   		subq	%rdx, %rsp
 158 00a1 4889C2   		movq	%rax, %rdx
 159 00a4 81E2FF0F 		andl	$4095, %edx
 159      0000
 160 00aa 4885D2   		testq	%rdx, %rdx
 161 00ad 7410     		je	.L5
 162 00af 25FF0F00 		andl	$4095, %eax
 162      00
 163 00b4 4883E808 		subq	$8, %rax
 164 00b8 4801E0   		addq	%rsp, %rax
 165 00bb 48830800 		orq	$0, (%rax)
 166              	.L5:
 167 00bf 4889E0   		movq	%rsp, %rax
 168 00c2 4883C00F 		addq	$15, %rax
 169 00c6 48C1E804 		shrq	$4, %rax
 170 00ca 48C1E004 		salq	$4, %rax
 171 00ce 4889C7   		movq	%rax, %rdi
 172 00d1 488B45E8 		movq	-24(%rbp), %rax
 173 00d5 4889CA   		movq	%rcx, %rdx
 174 00d8 4889C6   		movq	%rax, %rsi
 175 00db E8000000 		call	memcpy@PLT
 175      00
 176 00e0 488945E8 		movq	%rax, -24(%rbp)
  61:mathtest.c    **** 	Out_String(s, s__len);
 178              	.LM6:
 179 00e4 488B55E0 		movq	-32(%rbp), %rdx
 180 00e8 488B45E8 		movq	-24(%rbp), %rax
 181 00ec 4889D6   		movq	%rdx, %rsi
 182 00ef 4889C7   		movq	%rax, %rdi
 183 00f2 E8000000 		call	Out_String@PLT
 183      00
  62:mathtest.c    **** 	__DEL(s);
  63:mathtest.c    **** }
 185              	.LM7:
 186 00f7 90       		nop
 187 00f8 488B45F8 		movq	-8(%rbp), %rax
 188 00fc 64483304 		xorq	%fs:40, %rax
 188      25280000 
 188      00
 189 0105 7405     		je	.L6
 190 0107 E8000000 		call	__stack_chk_fail@PLT
 190      00
 191              	.L6:
 192 010c C9       		leave
 193              		.cfi_def_cfa 7, 8
 194 010d C3       		ret
 195              		.cfi_endproc
 196              	.LFE8:
 198              	.Lscope2:
 200              		.stabd	78,0,0
 204              	mathtest_wi:
 205              		.stabd	46,0,0
  64:mathtest.c    **** 
  65:mathtest.c    **** static void mathtest_wi (INT64 i)
  66:mathtest.c    **** {
 207              	.LM8:
 208              	.LFBB3:
 209              	.LFB9:
 210              		.cfi_startproc
 211 010e F30F1EFA 		endbr64
 212 0112 55       		pushq	%rbp
 213              		.cfi_def_cfa_offset 16
 214              		.cfi_offset 6, -16
 215 0113 4889E5   		movq	%rsp, %rbp
 216              		.cfi_def_cfa_register 6
 217 0116 4883EC10 		subq	$16, %rsp
 218 011a 48897DF8 		movq	%rdi, -8(%rbp)
  67:mathtest.c    **** 	Out_Int(i, 1);
 220              	.LM9:
 221 011e 488B45F8 		movq	-8(%rbp), %rax
 222 0122 BE010000 		movl	$1, %esi
 222      00
 223 0127 4889C7   		movq	%rax, %rdi
 224 012a E8000000 		call	Out_Int@PLT
 224      00
  68:mathtest.c    **** }
 226              	.LM10:
 227 012f 90       		nop
 228 0130 C9       		leave
 229              		.cfi_def_cfa 7, 8
 230 0131 C3       		ret
 231              		.cfi_endproc
 232              	.LFE9:
 234              	.Lscope3:
 236              		.stabd	78,0,0
 240              	mathtest_wr:
 241              		.stabd	46,0,0
  69:mathtest.c    **** 
  70:mathtest.c    **** static void mathtest_wr (REAL r)
  71:mathtest.c    **** {
 243              	.LM11:
 244              	.LFBB4:
 245              	.LFB10:
 246              		.cfi_startproc
 247 0132 F30F1EFA 		endbr64
 248 0136 55       		pushq	%rbp
 249              		.cfi_def_cfa_offset 16
 250              		.cfi_offset 6, -16
 251 0137 4889E5   		movq	%rsp, %rbp
 252              		.cfi_def_cfa_register 6
 253 013a 4883EC10 		subq	$16, %rsp
 254 013e F30F1145 		movss	%xmm0, -4(%rbp)
 254      FC
  72:mathtest.c    **** 	Out_Real(r, 11);
 256              	.LM12:
 257 0143 8B45FC   		movl	-4(%rbp), %eax
 258 0146 BF0B0000 		movl	$11, %edi
 258      00
 259 014b 660F6EC0 		movd	%eax, %xmm0
 260 014f E8000000 		call	Out_Real@PLT
 260      00
  73:mathtest.c    **** }
 262              	.LM13:
 263 0154 90       		nop
 264 0155 C9       		leave
 265              		.cfi_def_cfa 7, 8
 266 0156 C3       		ret
 267              		.cfi_endproc
 268              	.LFE10:
 270              	.Lscope4:
 272              		.stabd	78,0,0
 276              	mathtest_wlr:
 277              		.stabd	46,0,0
  74:mathtest.c    **** 
  75:mathtest.c    **** static void mathtest_wlr (LONGREAL lr)
  76:mathtest.c    **** {
 279              	.LM14:
 280              	.LFBB5:
 281              	.LFB11:
 282              		.cfi_startproc
 283 0157 F30F1EFA 		endbr64
 284 015b 55       		pushq	%rbp
 285              		.cfi_def_cfa_offset 16
 286              		.cfi_offset 6, -16
 287 015c 4889E5   		movq	%rsp, %rbp
 288              		.cfi_def_cfa_register 6
 289 015f 4883EC10 		subq	$16, %rsp
 290 0163 F20F1145 		movsd	%xmm0, -8(%rbp)
 290      F8
  77:mathtest.c    **** 	Out_LongReal(lr, 21);
 292              	.LM15:
 293 0168 488B45F8 		movq	-8(%rbp), %rax
 294 016c BF150000 		movl	$21, %edi
 294      00
 295 0171 66480F6E 		movq	%rax, %xmm0
 295      C0
 296 0176 E8000000 		call	Out_LongReal@PLT
 296      00
  78:mathtest.c    **** }
 298              	.LM16:
 299 017b 90       		nop
 300 017c C9       		leave
 301              		.cfi_def_cfa 7, 8
 302 017d C3       		ret
 303              		.cfi_endproc
 304              	.LFE11:
 306              	.Lscope5:
 308              		.stabd	78,0,0
 311              	mathtest_wl:
 312              		.stabd	46,0,0
  79:mathtest.c    **** 
  80:mathtest.c    **** static void mathtest_wl (void)
  81:mathtest.c    **** {
 314              	.LM17:
 315              	.LFBB6:
 316              	.LFB12:
 317              		.cfi_startproc
 318 017e F30F1EFA 		endbr64
 319 0182 55       		pushq	%rbp
 320              		.cfi_def_cfa_offset 16
 321              		.cfi_offset 6, -16
 322 0183 4889E5   		movq	%rsp, %rbp
 323              		.cfi_def_cfa_register 6
  82:mathtest.c    **** 	Out_Ln();
 325              	.LM18:
 326 0186 E8000000 		call	Out_Ln@PLT
 326      00
  83:mathtest.c    **** }
 328              	.LM19:
 329 018b 90       		nop
 330 018c 5D       		popq	%rbp
 331              		.cfi_def_cfa 7, 8
 332 018d C3       		ret
 333              		.cfi_endproc
 334              	.LFE12:
 336              	.Lscope6:
 338              		.stabd	78,0,0
 343              	mathtest_wh:
 344              		.stabd	46,0,0
  84:mathtest.c    **** 
  85:mathtest.c    **** static void mathtest_wh (SYSTEM_BYTE *h, ADDRESS h__len)
  86:mathtest.c    **** {
 346              	.LM20:
 347              	.LFBB7:
 348              	.LFB13:
 349              		.cfi_startproc
 350 018e F30F1EFA 		endbr64
 351 0192 55       		pushq	%rbp
 352              		.cfi_def_cfa_offset 16
 353              		.cfi_offset 6, -16
 354 0193 4889E5   		movq	%rsp, %rbp
 355              		.cfi_def_cfa_register 6
 356 0196 4883EC20 		subq	$32, %rsp
 357 019a 48897DE8 		movq	%rdi, -24(%rbp)
 358 019e 488975E0 		movq	%rsi, -32(%rbp)
  87:mathtest.c    **** 	INT32 i;
  88:mathtest.c    **** 	INT8 b;
  89:mathtest.c    **** 	i = (INT32)h__len;
 360              	.LM21:
 361 01a2 488B45E0 		movq	-32(%rbp), %rax
 362 01a6 8945FC   		movl	%eax, -4(%rbp)
  90:mathtest.c    **** 	while (i > 0) {
 364              	.LM22:
 365 01a9 E9A60000 		jmp	.L12
 365      00
 366              	.L18:
  91:mathtest.c    **** 		i -= 1;
 368              	.LM23:
 369 01ae 836DFC01 		subl	$1, -4(%rbp)
  92:mathtest.c    **** 		b = __VAL(INT8, h[__X(i, h__len)]);
 371              	.LM24:
 372 01b2 8B45FC   		movl	-4(%rbp), %eax
 373 01b5 4898     		cltq
 374 01b7 483945E0 		cmpq	%rax, -32(%rbp)
 375 01bb 7E07     		jle	.L13
 377              	.LM25:
 378 01bd 8B45FC   		movl	-4(%rbp), %eax
 379 01c0 4898     		cltq
 380 01c2 EB0F     		jmp	.L14
 381              	.L13:
 383              	.LM26:
 384 01c4 BFFEFFFF 		movl	$-2, %edi
 384      FF
 385 01c9 E8000000 		call	Modules_Halt@PLT
 385      00
 386 01ce B8000000 		movl	$0, %eax
 386      00
 387              	.L14:
 389              	.LM27:
 390 01d3 488B55E8 		movq	-24(%rbp), %rdx
 391 01d7 4801D0   		addq	%rdx, %rax
 393              	.LM28:
 394 01da 0FB600   		movzbl	(%rax), %eax
 395 01dd 8845FB   		movb	%al, -5(%rbp)
  93:mathtest.c    **** 		if (__MASK(__ASHR(b, 4), -16) < 10) {
 397              	.LM29:
 398 01e0 0FB645FB 		movzbl	-5(%rbp), %eax
 399 01e4 C0F804   		sarb	$4, %al
 400 01e7 480FBEC0 		movsbq	%al, %rax
 401 01eb 83E00F   		andl	$15, %eax
 403              	.LM30:
 404 01ee 4883F809 		cmpq	$9, %rax
 405 01f2 7F16     		jg	.L15
  94:mathtest.c    **** 			mathtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 48));
 407              	.LM31:
 408 01f4 0FB645FB 		movzbl	-5(%rbp), %eax
 409 01f8 C0E804   		shrb	$4, %al
 411              	.LM32:
 412 01fb 83C030   		addl	$48, %eax
 414              	.LM33:
 415 01fe 0FB6C0   		movzbl	%al, %eax
 416 0201 89C7     		movl	%eax, %edi
 417 0203 E8F8FDFF 		call	mathtest_wc
 417      FF
 418 0208 EB14     		jmp	.L16
 419              	.L15:
  95:mathtest.c    **** 		} else {
  96:mathtest.c    **** 			mathtest_wc((CHAR)(__MASK(__ASHR(b, 4), -16) + 55));
 421              	.LM34:
 422 020a 0FB645FB 		movzbl	-5(%rbp), %eax
 423 020e C0E804   		shrb	$4, %al
 425              	.LM35:
 426 0211 83C037   		addl	$55, %eax
 428              	.LM36:
 429 0214 0FB6C0   		movzbl	%al, %eax
 430 0217 89C7     		movl	%eax, %edi
 431 0219 E8E2FDFF 		call	mathtest_wc
 431      FF
 432              	.L16:
  97:mathtest.c    **** 		}
  98:mathtest.c    **** 		if (__MASK(b, -16) < 10) {
 434              	.LM37:
 435 021e 0FBE45FB 		movsbl	-5(%rbp), %eax
 436 0222 83E00F   		andl	$15, %eax
 438              	.LM38:
 439 0225 83F809   		cmpl	$9, %eax
 440 0228 7F16     		jg	.L17
  99:mathtest.c    **** 			mathtest_wc((CHAR)(__MASK(b, -16) + 48));
 442              	.LM39:
 443 022a 0FB645FB 		movzbl	-5(%rbp), %eax
 444 022e 83E00F   		andl	$15, %eax
 446              	.LM40:
 447 0231 83C030   		addl	$48, %eax
 449              	.LM41:
 450 0234 0FB6C0   		movzbl	%al, %eax
 451 0237 89C7     		movl	%eax, %edi
 452 0239 E8C2FDFF 		call	mathtest_wc
 452      FF
 453 023e EB14     		jmp	.L12
 454              	.L17:
 100:mathtest.c    **** 		} else {
 101:mathtest.c    **** 			mathtest_wc((CHAR)(__MASK(b, -16) + 55));
 456              	.LM42:
 457 0240 0FB645FB 		movzbl	-5(%rbp), %eax
 458 0244 83E00F   		andl	$15, %eax
 460              	.LM43:
 461 0247 83C037   		addl	$55, %eax
 463              	.LM44:
 464 024a 0FB6C0   		movzbl	%al, %eax
 465 024d 89C7     		movl	%eax, %edi
 466 024f E8ACFDFF 		call	mathtest_wc
 466      FF
 467              	.L12:
  90:mathtest.c    **** 		i -= 1;
 469              	.LM45:
 470 0254 837DFC00 		cmpl	$0, -4(%rbp)
 471 0258 0F8F50FF 		jg	.L18
 471      FFFF
 102:mathtest.c    **** 		}
 103:mathtest.c    **** 	}
 104:mathtest.c    **** }
 473              	.LM46:
 474 025e 90       		nop
 475 025f 90       		nop
 476 0260 C9       		leave
 477              		.cfi_def_cfa 7, 8
 478 0261 C3       		ret
 479              		.cfi_endproc
 480              	.LFE13:
 486              	.Lscope7:
 488              		.stabd	78,0,0
 494              	mathtest_addvalue:
 495              		.stabd	46,0,0
 105:mathtest.c    **** 
 106:mathtest.c    **** static void mathtest_addvalue (LONGREAL lr, mathtest_Values *val, ADDRESS *val__typ)
 107:mathtest.c    **** {
 497              	.LM47:
 498              	.LFBB8:
 499              	.LFB14:
 500              		.cfi_startproc
 501 0262 F30F1EFA 		endbr64
 502 0266 55       		pushq	%rbp
 503              		.cfi_def_cfa_offset 16
 504              		.cfi_offset 6, -16
 505 0267 4889E5   		movq	%rsp, %rbp
 506              		.cfi_def_cfa_register 6
 507 026a 4883EC20 		subq	$32, %rsp
 508 026e F20F1145 		movsd	%xmm0, -8(%rbp)
 508      F8
 509 0273 48897DF0 		movq	%rdi, -16(%rbp)
 510 0277 488975E8 		movq	%rsi, -24(%rbp)
 108:mathtest.c    **** 	(*val).v[__X((*val).n, 100)] = lr;
 512              	.LM48:
 513 027b 488B45F0 		movq	-16(%rbp), %rax
 514 027f 8B802003 		movl	800(%rax), %eax
 514      0000
 515 0285 83F863   		cmpl	$99, %eax
 516 0288 7F0C     		jg	.L20
 518              	.LM49:
 519 028a 488B45F0 		movq	-16(%rbp), %rax
 520 028e 8B902003 		movl	800(%rax), %edx
 520      0000
 521 0294 EB0F     		jmp	.L21
 522              	.L20:
 524              	.LM50:
 525 0296 BFFEFFFF 		movl	$-2, %edi
 525      FF
 526 029b E8000000 		call	Modules_Halt@PLT
 526      00
 527 02a0 BA000000 		movl	$0, %edx
 527      00
 528              	.L21:
 530              	.LM51:
 531 02a5 488B45F0 		movq	-16(%rbp), %rax
 532 02a9 4863D2   		movslq	%edx, %rdx
 533 02ac F20F1045 		movsd	-8(%rbp), %xmm0
 533      F8
 534 02b1 F20F1104 		movsd	%xmm0, (%rax,%rdx,8)
 534      D0
 109:mathtest.c    **** 	(*val).n += 1;
 536              	.LM52:
 537 02b6 488B45F0 		movq	-16(%rbp), %rax
 538 02ba 8B802003 		movl	800(%rax), %eax
 538      0000
 539 02c0 8D5001   		leal	1(%rax), %edx
 540 02c3 488B45F0 		movq	-16(%rbp), %rax
 541 02c7 89902003 		movl	%edx, 800(%rax)
 541      0000
 110:mathtest.c    **** }
 543              	.LM53:
 544 02cd 90       		nop
 545 02ce C9       		leave
 546              		.cfi_def_cfa 7, 8
 547 02cf C3       		ret
 548              		.cfi_endproc
 549              	.LFE14:
 551              	.Lscope8:
 553              		.stabd	78,0,0
 554              		.section	.rodata
 555              	.LC0:
 556 0000 3C4D6174 		.string	"<Math(L) error "
 556      68284C29 
 556      20657272 
 556      6F722000 
 557              	.LC1:
 558 0010 4E6F4572 		.string	"NoError"
 558      726F7200 
 559              	.LC2:
 560 0018 496C6C65 		.string	"IllegalRoot"
 560      67616C52 
 560      6F6F7400 
 561              	.LC3:
 562 0024 496C6C65 		.string	"IllegalLog"
 562      67616C4C 
 562      6F6700
 563              	.LC4:
 564 002f 4F766572 		.string	"Overflow"
 564      666C6F77 
 564      00
 565              	.LC5:
 566 0038 496C6C65 		.string	"IllegalPower"
 566      67616C50 
 566      6F776572 
 566      00
 567              	.LC6:
 568 0045 496C6C65 		.string	"IllegalLogBase"
 568      67616C4C 
 568      6F674261 
 568      736500
 569              	.LC7:
 570 0054 496C6C65 		.string	"IllegalTrig"
 570      67616C54 
 570      72696700 
 571              	.LC8:
 572 0060 496C6C65 		.string	"IllegalInvTrig"
 572      67616C49 
 572      6E765472 
 572      696700
 573              	.LC9:
 574 006f 48797049 		.string	"HypInvTrigClipped"
 574      6E765472 
 574      6967436C 
 574      69707065 
 574      6400
 575              	.LC10:
 576 0081 496C6C65 		.string	"IllegalHypInvTrig"
 576      67616C48 
 576      7970496E 
 576      76547269 
 576      6700
 577              	.LC11:
 578 0093 4C6F7373 		.string	"LossOfAccuracy"
 578      4F664163 
 578      63757261 
 578      637900
 579              	.LC12:
 580 00a2 556E6465 		.string	"Underflow"
 580      72666C6F 
 580      7700
 581              	.LC13:
 582 00ac 2028756E 		.string	" (unknknown)"
 582      6B6E6B6E 
 582      6F776E29 
 582      00
 583              	.LC14:
 584 00b9 3E2000   		.string	"> "
 585              		.text
 589              	mathtest_MathErrorHandler:
 590              		.stabd	46,0,0
 111:mathtest.c    **** 
 112:mathtest.c    **** static void mathtest_MathErrorHandler (INT32 error)
 113:mathtest.c    **** {
 592              	.LM54:
 593              	.LFBB9:
 594              	.LFB15:
 595              		.cfi_startproc
 596 02d0 F30F1EFA 		endbr64
 597 02d4 55       		pushq	%rbp
 598              		.cfi_def_cfa_offset 16
 599              		.cfi_offset 6, -16
 600 02d5 4889E5   		movq	%rsp, %rbp
 601              		.cfi_def_cfa_register 6
 602 02d8 4883EC10 		subq	$16, %rsp
 603 02dc 897DFC   		movl	%edi, -4(%rbp)
 114:mathtest.c    **** 	mathtest_ws((CHAR*)"<Math(L) error ", 16);
 605              	.LM55:
 606 02df BE100000 		movl	$16, %esi
 606      00
 607 02e4 488D3D00 		leaq	.LC0(%rip), %rdi
 607      000000
 608 02eb E82FFDFF 		call	mathtest_ws
 608      FF
 609 02f0 837DFC0B 		cmpl	$11, -4(%rbp)
 610 02f4 0F871A01 		ja	.L23
 610      0000
 611 02fa 8B45FC   		movl	-4(%rbp), %eax
 612 02fd 488D1485 		leaq	0(,%rax,4), %rdx
 612      00000000 
 613 0305 488D0500 		leaq	.L25(%rip), %rax
 613      000000
 614 030c 8B0402   		movl	(%rdx,%rax), %eax
 615 030f 4898     		cltq
 616 0311 488D1500 		leaq	.L25(%rip), %rdx
 616      000000
 617 0318 4801D0   		addq	%rdx, %rax
 618 031b 3EFFE0   		notrack jmp	*%rax
 619              		.section	.rodata
 620              		.align 4
 621              		.align 4
 622              	.L25:
 623 00bc 00000000 		.long	.L36-.L25
 624 00c0 00000000 		.long	.L35-.L25
 625 00c4 00000000 		.long	.L34-.L25
 626 00c8 00000000 		.long	.L33-.L25
 627 00cc 00000000 		.long	.L32-.L25
 628 00d0 00000000 		.long	.L31-.L25
 629 00d4 00000000 		.long	.L30-.L25
 630 00d8 00000000 		.long	.L29-.L25
 631 00dc 00000000 		.long	.L28-.L25
 632 00e0 00000000 		.long	.L27-.L25
 633 00e4 00000000 		.long	.L26-.L25
 634 00e8 00000000 		.long	.L24-.L25
 635              		.text
 636              	.L36:
 115:mathtest.c    **** 	switch (error) {
 116:mathtest.c    **** 		case 0: 
 117:mathtest.c    **** 			mathtest_ws((CHAR*)"NoError", 8);
 638              	.LM56:
 639 031e BE080000 		movl	$8, %esi
 639      00
 640 0323 488D3D00 		leaq	.LC1(%rip), %rdi
 640      000000
 641 032a E8F0FCFF 		call	mathtest_ws
 641      FF
 118:mathtest.c    **** 			break;
 643              	.LM57:
 644 032f E9FF0000 		jmp	.L37
 644      00
 645              	.L35:
 119:mathtest.c    **** 		case 1: 
 120:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalRoot", 12);
 647              	.LM58:
 648 0334 BE0C0000 		movl	$12, %esi
 648      00
 649 0339 488D3D00 		leaq	.LC2(%rip), %rdi
 649      000000
 650 0340 E8DAFCFF 		call	mathtest_ws
 650      FF
 121:mathtest.c    **** 			break;
 652              	.LM59:
 653 0345 E9E90000 		jmp	.L37
 653      00
 654              	.L34:
 122:mathtest.c    **** 		case 2: 
 123:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalLog", 11);
 656              	.LM60:
 657 034a BE0B0000 		movl	$11, %esi
 657      00
 658 034f 488D3D00 		leaq	.LC3(%rip), %rdi
 658      000000
 659 0356 E8C4FCFF 		call	mathtest_ws
 659      FF
 124:mathtest.c    **** 			break;
 661              	.LM61:
 662 035b E9D30000 		jmp	.L37
 662      00
 663              	.L33:
 125:mathtest.c    **** 		case 3: 
 126:mathtest.c    **** 			mathtest_ws((CHAR*)"Overflow", 9);
 665              	.LM62:
 666 0360 BE090000 		movl	$9, %esi
 666      00
 667 0365 488D3D00 		leaq	.LC4(%rip), %rdi
 667      000000
 668 036c E8AEFCFF 		call	mathtest_ws
 668      FF
 127:mathtest.c    **** 			break;
 670              	.LM63:
 671 0371 E9BD0000 		jmp	.L37
 671      00
 672              	.L32:
 128:mathtest.c    **** 		case 4: 
 129:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalPower", 13);
 674              	.LM64:
 675 0376 BE0D0000 		movl	$13, %esi
 675      00
 676 037b 488D3D00 		leaq	.LC5(%rip), %rdi
 676      000000
 677 0382 E898FCFF 		call	mathtest_ws
 677      FF
 130:mathtest.c    **** 			break;
 679              	.LM65:
 680 0387 E9A70000 		jmp	.L37
 680      00
 681              	.L31:
 131:mathtest.c    **** 		case 5: 
 132:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalLogBase", 15);
 683              	.LM66:
 684 038c BE0F0000 		movl	$15, %esi
 684      00
 685 0391 488D3D00 		leaq	.LC6(%rip), %rdi
 685      000000
 686 0398 E882FCFF 		call	mathtest_ws
 686      FF
 133:mathtest.c    **** 			break;
 688              	.LM67:
 689 039d E9910000 		jmp	.L37
 689      00
 690              	.L30:
 134:mathtest.c    **** 		case 6: 
 135:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalTrig", 12);
 692              	.LM68:
 693 03a2 BE0C0000 		movl	$12, %esi
 693      00
 694 03a7 488D3D00 		leaq	.LC7(%rip), %rdi
 694      000000
 695 03ae E86CFCFF 		call	mathtest_ws
 695      FF
 136:mathtest.c    **** 			break;
 697              	.LM69:
 698 03b3 EB7E     		jmp	.L37
 699              	.L29:
 137:mathtest.c    **** 		case 7: 
 138:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalInvTrig", 15);
 701              	.LM70:
 702 03b5 BE0F0000 		movl	$15, %esi
 702      00
 703 03ba 488D3D00 		leaq	.LC8(%rip), %rdi
 703      000000
 704 03c1 E859FCFF 		call	mathtest_ws
 704      FF
 139:mathtest.c    **** 			break;
 706              	.LM71:
 707 03c6 EB6B     		jmp	.L37
 708              	.L28:
 140:mathtest.c    **** 		case 8: 
 141:mathtest.c    **** 			mathtest_ws((CHAR*)"HypInvTrigClipped", 18);
 710              	.LM72:
 711 03c8 BE120000 		movl	$18, %esi
 711      00
 712 03cd 488D3D00 		leaq	.LC9(%rip), %rdi
 712      000000
 713 03d4 E846FCFF 		call	mathtest_ws
 713      FF
 142:mathtest.c    **** 			break;
 715              	.LM73:
 716 03d9 EB58     		jmp	.L37
 717              	.L27:
 143:mathtest.c    **** 		case 9: 
 144:mathtest.c    **** 			mathtest_ws((CHAR*)"IllegalHypInvTrig", 18);
 719              	.LM74:
 720 03db BE120000 		movl	$18, %esi
 720      00
 721 03e0 488D3D00 		leaq	.LC10(%rip), %rdi
 721      000000
 722 03e7 E833FCFF 		call	mathtest_ws
 722      FF
 145:mathtest.c    **** 			break;
 724              	.LM75:
 725 03ec EB45     		jmp	.L37
 726              	.L26:
 146:mathtest.c    **** 		case 10: 
 147:mathtest.c    **** 			mathtest_ws((CHAR*)"LossOfAccuracy", 15);
 728              	.LM76:
 729 03ee BE0F0000 		movl	$15, %esi
 729      00
 730 03f3 488D3D00 		leaq	.LC11(%rip), %rdi
 730      000000
 731 03fa E820FCFF 		call	mathtest_ws
 731      FF
 148:mathtest.c    **** 			break;
 733              	.LM77:
 734 03ff EB32     		jmp	.L37
 735              	.L24:
 149:mathtest.c    **** 		case 11: 
 150:mathtest.c    **** 			mathtest_ws((CHAR*)"Underflow", 10);
 737              	.LM78:
 738 0401 BE0A0000 		movl	$10, %esi
 738      00
 739 0406 488D3D00 		leaq	.LC12(%rip), %rdi
 739      000000
 740 040d E80DFCFF 		call	mathtest_ws
 740      FF
 151:mathtest.c    **** 			break;
 742              	.LM79:
 743 0412 EB1F     		jmp	.L37
 744              	.L23:
 152:mathtest.c    **** 		default: 
 153:mathtest.c    **** 			mathtest_wi(error);
 746              	.LM80:
 747 0414 8B45FC   		movl	-4(%rbp), %eax
 748 0417 4898     		cltq
 749 0419 4889C7   		movq	%rax, %rdi
 750 041c E8EDFCFF 		call	mathtest_wi
 750      FF
 154:mathtest.c    **** 			mathtest_ws((CHAR*)" (unknknown)", 13);
 752              	.LM81:
 753 0421 BE0D0000 		movl	$13, %esi
 753      00
 754 0426 488D3D00 		leaq	.LC13(%rip), %rdi
 754      000000
 755 042d E8EDFBFF 		call	mathtest_ws
 755      FF
 155:mathtest.c    **** 			break;
 757              	.LM82:
 758 0432 90       		nop
 759              	.L37:
 156:mathtest.c    **** 	}
 157:mathtest.c    **** 	mathtest_ws((CHAR*)"> ", 3);
 761              	.LM83:
 762 0433 BE030000 		movl	$3, %esi
 762      00
 763 0438 488D3D00 		leaq	.LC14(%rip), %rdi
 763      000000
 764 043f E8DBFBFF 		call	mathtest_ws
 764      FF
 158:mathtest.c    **** }
 766              	.LM84:
 767 0444 90       		nop
 768 0445 C9       		leave
 769              		.cfi_def_cfa 7, 8
 770 0446 C3       		ret
 771              		.cfi_endproc
 772              	.LFE15:
 774              	.Lscope9:
 776              		.stabd	78,0,0
 777              		.section	.rodata
 778              	.LC15:
 779 00ec 4D617468 		.string	"Math."
 779      2E00
 780              	.LC16:
 781 00f2 2800     		.string	"("
 782              	.LC17:
 783 00f4 293A2000 		.string	"): "
 784              	.LC18:
 785 00f8 2E20204D 		.string	".  MathL."
 785      6174684C 
 785      2E00
 786              		.text
 794              	mathtest_TestRtoR:
 795              		.stabd	46,0,0
 159:mathtest.c    **** 
 160:mathtest.c    **** static void mathtest_TestRtoR (CHAR *s, ADDRESS s__len, mathtest_RtoR p, mathtest_LRtoLR lp, mathte
 161:mathtest.c    **** {
 797              	.LM85:
 798              	.LFBB10:
 799              	.LFB16:
 800              		.cfi_startproc
 801 0447 F30F1EFA 		endbr64
 802 044b 55       		pushq	%rbp
 803              		.cfi_def_cfa_offset 16
 804              		.cfi_offset 6, -16
 805 044c 4889E5   		movq	%rsp, %rbp
 806              		.cfi_def_cfa_register 6
 807 044f 4883EC30 		subq	$48, %rsp
 808 0453 48897DE8 		movq	%rdi, -24(%rbp)
 809 0457 488975E0 		movq	%rsi, -32(%rbp)
 810 045b 488955D8 		movq	%rdx, -40(%rbp)
 811 045f 48894DD0 		movq	%rcx, -48(%rbp)
 813              	.LM86:
 814 0463 64488B04 		movq	%fs:40, %rax
 814      25280000 
 814      00
 815 046c 488945F8 		movq	%rax, -8(%rbp)
 816 0470 31C0     		xorl	%eax, %eax
 162:mathtest.c    **** 	INT32 i;
 163:mathtest.c    **** 	REAL r;
 164:mathtest.c    **** 	__DUP(s, s__len, CHAR);
 818              	.LM87:
 819 0472 488B4DE0 		movq	-32(%rbp), %rcx
 820 0476 488B45E0 		movq	-32(%rbp), %rax
 821 047a 488D5008 		leaq	8(%rax), %rdx
 822 047e B8100000 		movl	$16, %eax
 822      00
 823 0483 4883E801 		subq	$1, %rax
 824 0487 4801D0   		addq	%rdx, %rax
 825 048a BE100000 		movl	$16, %esi
 825      00
 826 048f BA000000 		movl	$0, %edx
 826      00
 827 0494 48F7F6   		divq	%rsi
 828 0497 486BC010 		imulq	$16, %rax, %rax
 829 049b 4889C2   		movq	%rax, %rdx
 830 049e 4881E200 		andq	$-4096, %rdx
 830      F0FFFF
 831 04a5 4889E6   		movq	%rsp, %rsi
 832 04a8 4829D6   		subq	%rdx, %rsi
 833 04ab 4889F2   		movq	%rsi, %rdx
 834              	.L39:
 835 04ae 4839D4   		cmpq	%rdx, %rsp
 836 04b1 7412     		je	.L40
 837 04b3 4881EC00 		subq	$4096, %rsp
 837      100000
 838 04ba 48838C24 		orq	$0, 4088(%rsp)
 838      F80F0000 
 838      00
 839 04c3 EBE9     		jmp	.L39
 840              	.L40:
 841 04c5 4889C2   		movq	%rax, %rdx
 842 04c8 81E2FF0F 		andl	$4095, %edx
 842      0000
 843 04ce 4829D4   		subq	%rdx, %rsp
 844 04d1 4889C2   		movq	%rax, %rdx
 845 04d4 81E2FF0F 		andl	$4095, %edx
 845      0000
 846 04da 4885D2   		testq	%rdx, %rdx
 847 04dd 7410     		je	.L41
 848 04df 25FF0F00 		andl	$4095, %eax
 848      00
 849 04e4 4883E808 		subq	$8, %rax
 850 04e8 4801E0   		addq	%rsp, %rax
 851 04eb 48830800 		orq	$0, (%rax)
 852              	.L41:
 853 04ef 4889E0   		movq	%rsp, %rax
 854 04f2 4883C00F 		addq	$15, %rax
 855 04f6 48C1E804 		shrq	$4, %rax
 856 04fa 48C1E004 		salq	$4, %rax
 857 04fe 4889C7   		movq	%rax, %rdi
 858 0501 488B45E8 		movq	-24(%rbp), %rax
 859 0505 4889CA   		movq	%rcx, %rdx
 860 0508 4889C6   		movq	%rax, %rsi
 861 050b E8000000 		call	memcpy@PLT
 861      00
 862 0510 488945E8 		movq	%rax, -24(%rbp)
 165:mathtest.c    **** 	i = 0;
 864              	.LM88:
 865 0514 C745F000 		movl	$0, -16(%rbp)
 865      000000
 166:mathtest.c    **** 	while (i < val.n) {
 867              	.LM89:
 868 051b E93A0100 		jmp	.L42
 868      00
 869              	.L49:
 167:mathtest.c    **** 		r = val.v[__X(i, 100)];
 871              	.LM90:
 872 0520 837DF063 		cmpl	$99, -16(%rbp)
 873 0524 7E11     		jle	.L43
 875              	.LM91:
 876 0526 BFFEFFFF 		movl	$-2, %edi
 876      FF
 877 052b E8000000 		call	Modules_Halt@PLT
 877      00
 878 0530 B8000000 		movl	$0, %eax
 878      00
 879 0535 EB03     		jmp	.L44
 880              	.L43:
 882              	.LM92:
 883 0537 8B45F0   		movl	-16(%rbp), %eax
 884              	.L44:
 886              	.LM93:
 887 053a 4898     		cltq
 888 053c F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 888      C510
 890              	.LM94:
 891 0542 F20F5AC0 		cvtsd2ss	%xmm0, %xmm0
 892 0546 F30F1145 		movss	%xmm0, -12(%rbp)
 892      F4
 168:mathtest.c    **** 		mathtest_ws((CHAR*)"Math.", 6);
 894              	.LM95:
 895 054b BE060000 		movl	$6, %esi
 895      00
 896 0550 488D3D00 		leaq	.LC15(%rip), %rdi
 896      000000
 897 0557 E8C3FAFF 		call	mathtest_ws
 897      FF
 169:mathtest.c    **** 		mathtest_ws(s, s__len);
 899              	.LM96:
 900 055c 488B55E0 		movq	-32(%rbp), %rdx
 901 0560 488B45E8 		movq	-24(%rbp), %rax
 902 0564 4889D6   		movq	%rdx, %rsi
 903 0567 4889C7   		movq	%rax, %rdi
 904 056a E8B0FAFF 		call	mathtest_ws
 904      FF
 170:mathtest.c    **** 		mathtest_ws((CHAR*)"(", 2);
 906              	.LM97:
 907 056f BE020000 		movl	$2, %esi
 907      00
 908 0574 488D3D00 		leaq	.LC16(%rip), %rdi
 908      000000
 909 057b E89FFAFF 		call	mathtest_ws
 909      FF
 171:mathtest.c    **** 		mathtest_wr(r);
 911              	.LM98:
 912 0580 8B45F4   		movl	-12(%rbp), %eax
 913 0583 660F6EC0 		movd	%eax, %xmm0
 914 0587 E8A6FBFF 		call	mathtest_wr
 914      FF
 172:mathtest.c    **** 		mathtest_ws((CHAR*)"): ", 4);
 916              	.LM99:
 917 058c BE040000 		movl	$4, %esi
 917      00
 918 0591 488D3D00 		leaq	.LC17(%rip), %rdi
 918      000000
 919 0598 E882FAFF 		call	mathtest_ws
 919      FF
 173:mathtest.c    **** 		mathtest_wr((*p)(r));
 921              	.LM100:
 922 059d 8B45F4   		movl	-12(%rbp), %eax
 923 05a0 488B55D8 		movq	-40(%rbp), %rdx
 924 05a4 660F6EC0 		movd	%eax, %xmm0
 925 05a8 FFD2     		call	*%rdx
 926 05aa E883FBFF 		call	mathtest_wr
 926      FF
 174:mathtest.c    **** 		mathtest_ws((CHAR*)".  MathL.", 10);
 928              	.LM101:
 929 05af BE0A0000 		movl	$10, %esi
 929      00
 930 05b4 488D3D00 		leaq	.LC18(%rip), %rdi
 930      000000
 931 05bb E85FFAFF 		call	mathtest_ws
 931      FF
 175:mathtest.c    **** 		mathtest_ws(s, s__len);
 933              	.LM102:
 934 05c0 488B55E0 		movq	-32(%rbp), %rdx
 935 05c4 488B45E8 		movq	-24(%rbp), %rax
 936 05c8 4889D6   		movq	%rdx, %rsi
 937 05cb 4889C7   		movq	%rax, %rdi
 938 05ce E84CFAFF 		call	mathtest_ws
 938      FF
 176:mathtest.c    **** 		mathtest_ws((CHAR*)"(", 2);
 940              	.LM103:
 941 05d3 BE020000 		movl	$2, %esi
 941      00
 942 05d8 488D3D00 		leaq	.LC16(%rip), %rdi
 942      000000
 943 05df E83BFAFF 		call	mathtest_ws
 943      FF
 177:mathtest.c    **** 		mathtest_wlr(val.v[__X(i, 100)]);
 945              	.LM104:
 946 05e4 837DF063 		cmpl	$99, -16(%rbp)
 947 05e8 7E11     		jle	.L45
 949              	.LM105:
 950 05ea BFFEFFFF 		movl	$-2, %edi
 950      FF
 951 05ef E8000000 		call	Modules_Halt@PLT
 951      00
 952 05f4 B8000000 		movl	$0, %eax
 952      00
 953 05f9 EB03     		jmp	.L46
 954              	.L45:
 956              	.LM106:
 957 05fb 8B45F0   		movl	-16(%rbp), %eax
 958              	.L46:
 960              	.LM107:
 961 05fe 4898     		cltq
 962 0600 488B44C5 		movq	16(%rbp,%rax,8), %rax
 962      10
 963 0605 66480F6E 		movq	%rax, %xmm0
 963      C0
 964 060a E848FBFF 		call	mathtest_wlr
 964      FF
 178:mathtest.c    **** 		mathtest_ws((CHAR*)"): ", 4);
 966              	.LM108:
 967 060f BE040000 		movl	$4, %esi
 967      00
 968 0614 488D3D00 		leaq	.LC17(%rip), %rdi
 968      000000
 969 061b E8FFF9FF 		call	mathtest_ws
 969      FF
 179:mathtest.c    **** 		mathtest_wlr((*lp)(val.v[__X(i, 100)]));
 971              	.LM109:
 972 0620 837DF063 		cmpl	$99, -16(%rbp)
 973 0624 7E11     		jle	.L47
 975              	.LM110:
 976 0626 BFFEFFFF 		movl	$-2, %edi
 976      FF
 977 062b E8000000 		call	Modules_Halt@PLT
 977      00
 978 0630 B8000000 		movl	$0, %eax
 978      00
 979 0635 EB03     		jmp	.L48
 980              	.L47:
 982              	.LM111:
 983 0637 8B45F0   		movl	-16(%rbp), %eax
 984              	.L48:
 986              	.LM112:
 987 063a 4898     		cltq
 988 063c 488B44C5 		movq	16(%rbp,%rax,8), %rax
 988      10
 989 0641 488B55D0 		movq	-48(%rbp), %rdx
 990 0645 66480F6E 		movq	%rax, %xmm0
 990      C0
 991 064a FFD2     		call	*%rdx
 992 064c E806FBFF 		call	mathtest_wlr
 992      FF
 180:mathtest.c    **** 		mathtest_wl();
 994              	.LM113:
 995 0651 E828FBFF 		call	mathtest_wl
 995      FF
 181:mathtest.c    **** 		i += 1;
 997              	.LM114:
 998 0656 8345F001 		addl	$1, -16(%rbp)
 999              	.L42:
 166:mathtest.c    **** 		r = val.v[__X(i, 100)];
 1001              	.LM115:
 1002 065a 8B853003 		movl	816(%rbp), %eax
 1002      0000
 166:mathtest.c    **** 		r = val.v[__X(i, 100)];
 1004              	.LM116:
 1005 0660 3945F0   		cmpl	%eax, -16(%rbp)
 1006 0663 0F8CB7FE 		jl	.L49
 1006      FFFF
 182:mathtest.c    **** 	}
 183:mathtest.c    **** 	mathtest_wl();
 1008              	.LM117:
 1009 0669 E810FBFF 		call	mathtest_wl
 1009      FF
 184:mathtest.c    **** 	__DEL(s);
 185:mathtest.c    **** }
 1011              	.LM118:
 1012 066e 90       		nop
 1013 066f 488B45F8 		movq	-8(%rbp), %rax
 1014 0673 64483304 		xorq	%fs:40, %rax
 1014      25280000 
 1014      00
 1015 067c 7405     		je	.L50
 1016 067e E8000000 		call	__stack_chk_fail@PLT
 1016      00
 1017              	.L50:
 1018 0683 C9       		leave
 1019              		.cfi_def_cfa 7, 8
 1020 0684 C3       		ret
 1021              		.cfi_endproc
 1022              	.LFE16:
 1028              	.Lscope10:
 1030              		.stabd	78,0,0
 1038              	mathtest_TestRtoLI:
 1039              		.stabd	46,0,0
 186:mathtest.c    **** 
 187:mathtest.c    **** static void mathtest_TestRtoLI (CHAR *s, ADDRESS s__len, mathtest_RtoLI p, mathtest_LRtoLI lp, math
 188:mathtest.c    **** {
 1041              	.LM119:
 1042              	.LFBB11:
 1043              	.LFB17:
 1044              		.cfi_startproc
 1045 0685 F30F1EFA 		endbr64
 1046 0689 55       		pushq	%rbp
 1047              		.cfi_def_cfa_offset 16
 1048              		.cfi_offset 6, -16
 1049 068a 4889E5   		movq	%rsp, %rbp
 1050              		.cfi_def_cfa_register 6
 1051 068d 4883EC30 		subq	$48, %rsp
 1052 0691 48897DE8 		movq	%rdi, -24(%rbp)
 1053 0695 488975E0 		movq	%rsi, -32(%rbp)
 1054 0699 488955D8 		movq	%rdx, -40(%rbp)
 1055 069d 48894DD0 		movq	%rcx, -48(%rbp)
 1057              	.LM120:
 1058 06a1 64488B04 		movq	%fs:40, %rax
 1058      25280000 
 1058      00
 1059 06aa 488945F8 		movq	%rax, -8(%rbp)
 1060 06ae 31C0     		xorl	%eax, %eax
 189:mathtest.c    **** 	INT32 i;
 190:mathtest.c    **** 	REAL r;
 191:mathtest.c    **** 	__DUP(s, s__len, CHAR);
 1062              	.LM121:
 1063 06b0 488B4DE0 		movq	-32(%rbp), %rcx
 1064 06b4 488B45E0 		movq	-32(%rbp), %rax
 1065 06b8 488D5008 		leaq	8(%rax), %rdx
 1066 06bc B8100000 		movl	$16, %eax
 1066      00
 1067 06c1 4883E801 		subq	$1, %rax
 1068 06c5 4801D0   		addq	%rdx, %rax
 1069 06c8 BE100000 		movl	$16, %esi
 1069      00
 1070 06cd BA000000 		movl	$0, %edx
 1070      00
 1071 06d2 48F7F6   		divq	%rsi
 1072 06d5 486BC010 		imulq	$16, %rax, %rax
 1073 06d9 4889C2   		movq	%rax, %rdx
 1074 06dc 4881E200 		andq	$-4096, %rdx
 1074      F0FFFF
 1075 06e3 4889E6   		movq	%rsp, %rsi
 1076 06e6 4829D6   		subq	%rdx, %rsi
 1077 06e9 4889F2   		movq	%rsi, %rdx
 1078              	.L52:
 1079 06ec 4839D4   		cmpq	%rdx, %rsp
 1080 06ef 7412     		je	.L53
 1081 06f1 4881EC00 		subq	$4096, %rsp
 1081      100000
 1082 06f8 48838C24 		orq	$0, 4088(%rsp)
 1082      F80F0000 
 1082      00
 1083 0701 EBE9     		jmp	.L52
 1084              	.L53:
 1085 0703 4889C2   		movq	%rax, %rdx
 1086 0706 81E2FF0F 		andl	$4095, %edx
 1086      0000
 1087 070c 4829D4   		subq	%rdx, %rsp
 1088 070f 4889C2   		movq	%rax, %rdx
 1089 0712 81E2FF0F 		andl	$4095, %edx
 1089      0000
 1090 0718 4885D2   		testq	%rdx, %rdx
 1091 071b 7410     		je	.L54
 1092 071d 25FF0F00 		andl	$4095, %eax
 1092      00
 1093 0722 4883E808 		subq	$8, %rax
 1094 0726 4801E0   		addq	%rsp, %rax
 1095 0729 48830800 		orq	$0, (%rax)
 1096              	.L54:
 1097 072d 4889E0   		movq	%rsp, %rax
 1098 0730 4883C00F 		addq	$15, %rax
 1099 0734 48C1E804 		shrq	$4, %rax
 1100 0738 48C1E004 		salq	$4, %rax
 1101 073c 4889C7   		movq	%rax, %rdi
 1102 073f 488B45E8 		movq	-24(%rbp), %rax
 1103 0743 4889CA   		movq	%rcx, %rdx
 1104 0746 4889C6   		movq	%rax, %rsi
 1105 0749 E8000000 		call	memcpy@PLT
 1105      00
 1106 074e 488945E8 		movq	%rax, -24(%rbp)
 192:mathtest.c    **** 	i = 0;
 1108              	.LM122:
 1109 0752 C745F000 		movl	$0, -16(%rbp)
 1109      000000
 193:mathtest.c    **** 	while (i < val.n) {
 1111              	.LM123:
 1112 0759 E9400100 		jmp	.L55
 1112      00
 1113              	.L62:
 194:mathtest.c    **** 		r = val.v[__X(i, 100)];
 1115              	.LM124:
 1116 075e 837DF063 		cmpl	$99, -16(%rbp)
 1117 0762 7E11     		jle	.L56
 1119              	.LM125:
 1120 0764 BFFEFFFF 		movl	$-2, %edi
 1120      FF
 1121 0769 E8000000 		call	Modules_Halt@PLT
 1121      00
 1122 076e B8000000 		movl	$0, %eax
 1122      00
 1123 0773 EB03     		jmp	.L57
 1124              	.L56:
 1126              	.LM126:
 1127 0775 8B45F0   		movl	-16(%rbp), %eax
 1128              	.L57:
 1130              	.LM127:
 1131 0778 4898     		cltq
 1132 077a F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 1132      C510
 1134              	.LM128:
 1135 0780 F20F5AC0 		cvtsd2ss	%xmm0, %xmm0
 1136 0784 F30F1145 		movss	%xmm0, -12(%rbp)
 1136      F4
 195:mathtest.c    **** 		mathtest_ws((CHAR*)"Math.", 6);
 1138              	.LM129:
 1139 0789 BE060000 		movl	$6, %esi
 1139      00
 1140 078e 488D3D00 		leaq	.LC15(%rip), %rdi
 1140      000000
 1141 0795 E885F8FF 		call	mathtest_ws
 1141      FF
 196:mathtest.c    **** 		mathtest_ws(s, s__len);
 1143              	.LM130:
 1144 079a 488B55E0 		movq	-32(%rbp), %rdx
 1145 079e 488B45E8 		movq	-24(%rbp), %rax
 1146 07a2 4889D6   		movq	%rdx, %rsi
 1147 07a5 4889C7   		movq	%rax, %rdi
 1148 07a8 E872F8FF 		call	mathtest_ws
 1148      FF
 197:mathtest.c    **** 		mathtest_ws((CHAR*)"(", 2);
 1150              	.LM131:
 1151 07ad BE020000 		movl	$2, %esi
 1151      00
 1152 07b2 488D3D00 		leaq	.LC16(%rip), %rdi
 1152      000000
 1153 07b9 E861F8FF 		call	mathtest_ws
 1153      FF
 198:mathtest.c    **** 		mathtest_wr(r);
 1155              	.LM132:
 1156 07be 8B45F4   		movl	-12(%rbp), %eax
 1157 07c1 660F6EC0 		movd	%eax, %xmm0
 1158 07c5 E868F9FF 		call	mathtest_wr
 1158      FF
 199:mathtest.c    **** 		mathtest_ws((CHAR*)"): ", 4);
 1160              	.LM133:
 1161 07ca BE040000 		movl	$4, %esi
 1161      00
 1162 07cf 488D3D00 		leaq	.LC17(%rip), %rdi
 1162      000000
 1163 07d6 E844F8FF 		call	mathtest_ws
 1163      FF
 200:mathtest.c    **** 		mathtest_wi((*p)(r));
 1165              	.LM134:
 1166 07db 8B45F4   		movl	-12(%rbp), %eax
 1167 07de 488B55D8 		movq	-40(%rbp), %rdx
 1168 07e2 660F6EC0 		movd	%eax, %xmm0
 1169 07e6 FFD2     		call	*%rdx
 1170 07e8 4889C7   		movq	%rax, %rdi
 1171 07eb E81EF9FF 		call	mathtest_wi
 1171      FF
 201:mathtest.c    **** 		mathtest_ws((CHAR*)".  MathL.", 10);
 1173              	.LM135:
 1174 07f0 BE0A0000 		movl	$10, %esi
 1174      00
 1175 07f5 488D3D00 		leaq	.LC18(%rip), %rdi
 1175      000000
 1176 07fc E81EF8FF 		call	mathtest_ws
 1176      FF
 202:mathtest.c    **** 		mathtest_ws(s, s__len);
 1178              	.LM136:
 1179 0801 488B55E0 		movq	-32(%rbp), %rdx
 1180 0805 488B45E8 		movq	-24(%rbp), %rax
 1181 0809 4889D6   		movq	%rdx, %rsi
 1182 080c 4889C7   		movq	%rax, %rdi
 1183 080f E80BF8FF 		call	mathtest_ws
 1183      FF
 203:mathtest.c    **** 		mathtest_ws((CHAR*)"(", 2);
 1185              	.LM137:
 1186 0814 BE020000 		movl	$2, %esi
 1186      00
 1187 0819 488D3D00 		leaq	.LC16(%rip), %rdi
 1187      000000
 1188 0820 E8FAF7FF 		call	mathtest_ws
 1188      FF
 204:mathtest.c    **** 		mathtest_wlr(val.v[__X(i, 100)]);
 1190              	.LM138:
 1191 0825 837DF063 		cmpl	$99, -16(%rbp)
 1192 0829 7E11     		jle	.L58
 1194              	.LM139:
 1195 082b BFFEFFFF 		movl	$-2, %edi
 1195      FF
 1196 0830 E8000000 		call	Modules_Halt@PLT
 1196      00
 1197 0835 B8000000 		movl	$0, %eax
 1197      00
 1198 083a EB03     		jmp	.L59
 1199              	.L58:
 1201              	.LM140:
 1202 083c 8B45F0   		movl	-16(%rbp), %eax
 1203              	.L59:
 1205              	.LM141:
 1206 083f 4898     		cltq
 1207 0841 488B44C5 		movq	16(%rbp,%rax,8), %rax
 1207      10
 1208 0846 66480F6E 		movq	%rax, %xmm0
 1208      C0
 1209 084b E807F9FF 		call	mathtest_wlr
 1209      FF
 205:mathtest.c    **** 		mathtest_ws((CHAR*)"): ", 4);
 1211              	.LM142:
 1212 0850 BE040000 		movl	$4, %esi
 1212      00
 1213 0855 488D3D00 		leaq	.LC17(%rip), %rdi
 1213      000000
 1214 085c E8BEF7FF 		call	mathtest_ws
 1214      FF
 206:mathtest.c    **** 		mathtest_wi((*lp)(val.v[__X(i, 100)]));
 1216              	.LM143:
 1217 0861 837DF063 		cmpl	$99, -16(%rbp)
 1218 0865 7E11     		jle	.L60
 1220              	.LM144:
 1221 0867 BFFEFFFF 		movl	$-2, %edi
 1221      FF
 1222 086c E8000000 		call	Modules_Halt@PLT
 1222      00
 1223 0871 B8000000 		movl	$0, %eax
 1223      00
 1224 0876 EB03     		jmp	.L61
 1225              	.L60:
 1227              	.LM145:
 1228 0878 8B45F0   		movl	-16(%rbp), %eax
 1229              	.L61:
 1231              	.LM146:
 1232 087b 4898     		cltq
 1233 087d 488B44C5 		movq	16(%rbp,%rax,8), %rax
 1233      10
 1234 0882 488B55D0 		movq	-48(%rbp), %rdx
 1235 0886 66480F6E 		movq	%rax, %xmm0
 1235      C0
 1236 088b FFD2     		call	*%rdx
 1237 088d 4889C7   		movq	%rax, %rdi
 1238 0890 E879F8FF 		call	mathtest_wi
 1238      FF
 207:mathtest.c    **** 		mathtest_wl();
 1240              	.LM147:
 1241 0895 E8E4F8FF 		call	mathtest_wl
 1241      FF
 208:mathtest.c    **** 		i += 1;
 1243              	.LM148:
 1244 089a 8345F001 		addl	$1, -16(%rbp)
 1245              	.L55:
 193:mathtest.c    **** 		r = val.v[__X(i, 100)];
 1247              	.LM149:
 1248 089e 8B853003 		movl	816(%rbp), %eax
 1248      0000
 193:mathtest.c    **** 		r = val.v[__X(i, 100)];
 1250              	.LM150:
 1251 08a4 3945F0   		cmpl	%eax, -16(%rbp)
 1252 08a7 0F8CB1FE 		jl	.L62
 1252      FFFF
 209:mathtest.c    **** 	}
 210:mathtest.c    **** 	mathtest_wl();
 1254              	.LM151:
 1255 08ad E8CCF8FF 		call	mathtest_wl
 1255      FF
 211:mathtest.c    **** 	__DEL(s);
 212:mathtest.c    **** }
 1257              	.LM152:
 1258 08b2 90       		nop
 1259 08b3 488B45F8 		movq	-8(%rbp), %rax
 1260 08b7 64483304 		xorq	%fs:40, %rax
 1260      25280000 
 1260      00
 1261 08c0 7405     		je	.L63
 1262 08c2 E8000000 		call	__stack_chk_fail@PLT
 1262      00
 1263              	.L63:
 1264 08c7 C9       		leave
 1265              		.cfi_def_cfa 7, 8
 1266 08c8 C3       		ret
 1267              		.cfi_endproc
 1268              	.LFE17:
 1274              	.Lscope11:
 1276              		.stabd	78,0,0
 1277              		.section	.rodata
 1278              	.LC19:
 1279 0102 4D617468 		.string	"Math.round("
 1279      2E726F75 
 1279      6E642800 
 1280              	.LC20:
 1281 010e 2E20204D 		.string	".  MathL.round("
 1281      6174684C 
 1281      2E726F75 
 1281      6E642800 
 1282              		.text
 1286              	mathtest_round:
 1287              		.stabd	46,0,0
 213:mathtest.c    **** 
 214:mathtest.c    **** static void mathtest_round (LONGREAL lr)
 215:mathtest.c    **** {
 1289              	.LM153:
 1290              	.LFBB12:
 1291              	.LFB18:
 1292              		.cfi_startproc
 1293 08c9 F30F1EFA 		endbr64
 1294 08cd 55       		pushq	%rbp
 1295              		.cfi_def_cfa_offset 16
 1296              		.cfi_offset 6, -16
 1297 08ce 4889E5   		movq	%rsp, %rbp
 1298              		.cfi_def_cfa_register 6
 1299 08d1 4883EC20 		subq	$32, %rsp
 1300 08d5 F20F1145 		movsd	%xmm0, -24(%rbp)
 1300      E8
 216:mathtest.c    **** 	REAL r;
 217:mathtest.c    **** 	r = lr;
 1302              	.LM154:
 1303 08da F20F5A45 		cvtsd2ss	-24(%rbp), %xmm0
 1303      E8
 1304 08df F30F1145 		movss	%xmm0, -4(%rbp)
 1304      FC
 218:mathtest.c    **** 	mathtest_ws((CHAR*)"Math.round(", 12);
 1306              	.LM155:
 1307 08e4 BE0C0000 		movl	$12, %esi
 1307      00
 1308 08e9 488D3D00 		leaq	.LC19(%rip), %rdi
 1308      000000
 1309 08f0 E82AF7FF 		call	mathtest_ws
 1309      FF
 219:mathtest.c    **** 	mathtest_wr(r);
 1311              	.LM156:
 1312 08f5 8B45FC   		movl	-4(%rbp), %eax
 1313 08f8 660F6EC0 		movd	%eax, %xmm0
 1314 08fc E831F8FF 		call	mathtest_wr
 1314      FF
 220:mathtest.c    **** 	mathtest_ws((CHAR*)"): ", 4);
 1316              	.LM157:
 1317 0901 BE040000 		movl	$4, %esi
 1317      00
 1318 0906 488D3D00 		leaq	.LC17(%rip), %rdi
 1318      000000
 1319 090d E80DF7FF 		call	mathtest_ws
 1319      FF
 221:mathtest.c    **** 	mathtest_wi(Math_round(r));
 1321              	.LM158:
 1322 0912 8B45FC   		movl	-4(%rbp), %eax
 1323 0915 660F6EC0 		movd	%eax, %xmm0
 1324 0919 E8000000 		call	Math_round@PLT
 1324      00
 1325 091e 4889C7   		movq	%rax, %rdi
 1326 0921 E8E8F7FF 		call	mathtest_wi
 1326      FF
 222:mathtest.c    **** 	mathtest_ws((CHAR*)".  MathL.round(", 16);
 1328              	.LM159:
 1329 0926 BE100000 		movl	$16, %esi
 1329      00
 1330 092b 488D3D00 		leaq	.LC20(%rip), %rdi
 1330      000000
 1331 0932 E8E8F6FF 		call	mathtest_ws
 1331      FF
 223:mathtest.c    **** 	mathtest_wlr(lr);
 1333              	.LM160:
 1334 0937 488B45E8 		movq	-24(%rbp), %rax
 1335 093b 66480F6E 		movq	%rax, %xmm0
 1335      C0
 1336 0940 E812F8FF 		call	mathtest_wlr
 1336      FF
 224:mathtest.c    **** 	mathtest_ws((CHAR*)"): ", 4);
 1338              	.LM161:
 1339 0945 BE040000 		movl	$4, %esi
 1339      00
 1340 094a 488D3D00 		leaq	.LC17(%rip), %rdi
 1340      000000
 1341 0951 E8C9F6FF 		call	mathtest_ws
 1341      FF
 225:mathtest.c    **** 	mathtest_wi(MathL_round(lr));
 1343              	.LM162:
 1344 0956 488B45E8 		movq	-24(%rbp), %rax
 1345 095a 66480F6E 		movq	%rax, %xmm0
 1345      C0
 1346 095f E8000000 		call	MathL_round@PLT
 1346      00
 1347 0964 4889C7   		movq	%rax, %rdi
 1348 0967 E8A2F7FF 		call	mathtest_wi
 1348      FF
 226:mathtest.c    **** 	mathtest_wl();
 1350              	.LM163:
 1351 096c E80DF8FF 		call	mathtest_wl
 1351      FF
 227:mathtest.c    **** }
 1353              	.LM164:
 1354 0971 90       		nop
 1355 0972 C9       		leave
 1356              		.cfi_def_cfa 7, 8
 1357 0973 C3       		ret
 1358              		.cfi_endproc
 1359              	.LFE18:
 1364              	.Lscope12:
 1366              		.stabd	78,0,0
 1367              		.section	.rodata
 1368              	.LC21:
 1369 011e 4D617468 		.string	"Math.sqrt("
 1369      2E737172 
 1369      742800
 1370              	.LC22:
 1371 0129 2E20204D 		.string	".  MathL.sqrt("
 1371      6174684C 
 1371      2E737172 
 1371      742800
 1372              		.text
 1376              	mathtest_sqrt:
 1377              		.stabd	46,0,0
 228:mathtest.c    **** 
 229:mathtest.c    **** static void mathtest_sqrt (LONGREAL lr)
 230:mathtest.c    **** {
 1379              	.LM165:
 1380              	.LFBB13:
 1381              	.LFB19:
 1382              		.cfi_startproc
 1383 0974 F30F1EFA 		endbr64
 1384 0978 55       		pushq	%rbp
 1385              		.cfi_def_cfa_offset 16
 1386              		.cfi_offset 6, -16
 1387 0979 4889E5   		movq	%rsp, %rbp
 1388              		.cfi_def_cfa_register 6
 1389 097c 4883EC20 		subq	$32, %rsp
 1390 0980 F20F1145 		movsd	%xmm0, -24(%rbp)
 1390      E8
 231:mathtest.c    **** 	REAL r;
 232:mathtest.c    **** 	r = lr;
 1392              	.LM166:
 1393 0985 F20F5A45 		cvtsd2ss	-24(%rbp), %xmm0
 1393      E8
 1394 098a F30F1145 		movss	%xmm0, -4(%rbp)
 1394      FC
 233:mathtest.c    **** 	mathtest_ws((CHAR*)"Math.sqrt(", 11);
 1396              	.LM167:
 1397 098f BE0B0000 		movl	$11, %esi
 1397      00
 1398 0994 488D3D00 		leaq	.LC21(%rip), %rdi
 1398      000000
 1399 099b E87FF6FF 		call	mathtest_ws
 1399      FF
 234:mathtest.c    **** 	mathtest_wr(r);
 1401              	.LM168:
 1402 09a0 8B45FC   		movl	-4(%rbp), %eax
 1403 09a3 660F6EC0 		movd	%eax, %xmm0
 1404 09a7 E886F7FF 		call	mathtest_wr
 1404      FF
 235:mathtest.c    **** 	mathtest_ws((CHAR*)"): ", 4);
 1406              	.LM169:
 1407 09ac BE040000 		movl	$4, %esi
 1407      00
 1408 09b1 488D3D00 		leaq	.LC17(%rip), %rdi
 1408      000000
 1409 09b8 E862F6FF 		call	mathtest_ws
 1409      FF
 236:mathtest.c    **** 	mathtest_wr(Math_sqrt(r));
 1411              	.LM170:
 1412 09bd 8B45FC   		movl	-4(%rbp), %eax
 1413 09c0 660F6EC0 		movd	%eax, %xmm0
 1414 09c4 E8000000 		call	Math_sqrt@PLT
 1414      00
 1415 09c9 E864F7FF 		call	mathtest_wr
 1415      FF
 237:mathtest.c    **** 	mathtest_ws((CHAR*)".  MathL.sqrt(", 15);
 1417              	.LM171:
 1418 09ce BE0F0000 		movl	$15, %esi
 1418      00
 1419 09d3 488D3D00 		leaq	.LC22(%rip), %rdi
 1419      000000
 1420 09da E840F6FF 		call	mathtest_ws
 1420      FF
 238:mathtest.c    **** 	mathtest_wlr(r);
 1422              	.LM172:
 1423 09df F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 1423      FC
 1424 09e4 E86EF7FF 		call	mathtest_wlr
 1424      FF
 239:mathtest.c    **** 	mathtest_ws((CHAR*)"): ", 4);
 1426              	.LM173:
 1427 09e9 BE040000 		movl	$4, %esi
 1427      00
 1428 09ee 488D3D00 		leaq	.LC17(%rip), %rdi
 1428      000000
 1429 09f5 E825F6FF 		call	mathtest_ws
 1429      FF
 240:mathtest.c    **** 	mathtest_wlr(MathL_sqrt(r));
 1431              	.LM174:
 1432 09fa F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 1432      FC
 1433 09ff E8000000 		call	MathL_sqrt@PLT
 1433      00
 1434 0a04 E84EF7FF 		call	mathtest_wlr
 1434      FF
 241:mathtest.c    **** 	mathtest_wl();
 1436              	.LM175:
 1437 0a09 E870F7FF 		call	mathtest_wl
 1437      FF
 242:mathtest.c    **** }
 1439              	.LM176:
 1440 0a0e 90       		nop
 1441 0a0f C9       		leave
 1442              		.cfi_def_cfa 7, 8
 1443 0a10 C3       		ret
 1444              		.cfi_endproc
 1445              	.LFE19:
 1450              	.Lscope13:
 1452              		.stabd	78,0,0
 1453              		.data
 1454              		.align 32
 1457              	mathtest_Values__desc:
 1458 0000 01000000 		.quad	1
 1458      00000000 
 1459 0008 01000000 		.quad	1
 1459      00000000 
 1460 0010 00000000 		.quad	0
 1460      00000000 
 1461 0018 00000000 		.quad	0
 1461      00000000 
 1462 0020 00000000 		.quad	0
 1462      00000000 
 1463 0028 56616C75 		.string	"Values"
 1463      657300
 1464 002f 00000000 		.zero	17
 1464      00000000 
 1464      00000000 
 1464      00000000 
 1464      00
 1465 0040 00000000 		.quad	0
 1465      00000000 
 1466 0048 00000000 		.zero	120
 1466      00000000 
 1466      00000000 
 1466      00000000 
 1466      00000000 
 1467 00c0 00000000 		.quad	0
 1467      00000000 
 1468 00c8 28030000 		.quad	808
 1468      00000000 
 1469 00d0 F8FFFFFF 		.quad	-8
 1469      FFFFFFFF 
 1471              		.section	.rodata
 1472              	.LC23:
 1473 0138 6D617468 		.string	"mathtest"
 1473      74657374 
 1473      00
 1474              	.LC24:
 1475 0141 4D617468 		.string	"Math and MathL module tests."
 1475      20616E64 
 1475      204D6174 
 1475      684C206D 
 1475      6F64756C 
 1476              	.LC55:
 1477 015e 66726163 		.string	"fraction"
 1477      74696F6E 
 1477      00
 1478              	.LC56:
 1479 0167 726F756E 		.string	"round"
 1479      6400
 1480              	.LC57:
 1481 016d 73717274 		.string	"sqrt"
 1481      00
 1482              	.LC58:
 1483 0172 6C6E00   		.string	"ln"
 1484              	.LC59:
 1485 0175 73696E00 		.string	"sin"
 1486              	.LC60:
 1487 0179 636F7300 		.string	"cos"
 1488              	.LC61:
 1489 017d 74616E00 		.string	"tan"
 1490              	.LC62:
 1491 0181 61726373 		.string	"arcsin"
 1491      696E00
 1492              	.LC63:
 1493 0188 61726363 		.string	"arccos"
 1493      6F7300
 1494              	.LC64:
 1495 018f 61726374 		.string	"arctan"
 1495      616E00
 1496              	.LC65:
 1497 0196 73696E68 		.string	"sinh"
 1497      00
 1498              	.LC66:
 1499 019b 636F7368 		.string	"cosh"
 1499      00
 1500              	.LC67:
 1501 01a0 74616E68 		.string	"tanh"
 1501      00
 1502              	.LC68:
 1503 01a5 61726373 		.string	"arcsinh"
 1503      696E6800 
 1504              	.LC69:
 1505 01ad 61726363 		.string	"arccosh"
 1505      6F736800 
 1506              	.LC70:
 1507 01b5 61726374 		.string	"arctanh"
 1507      616E6800 
 1508              		.text
 1512              		.globl	main
 1514              	main:
 1515              		.stabd	46,0,0
 243:mathtest.c    **** 
 244:mathtest.c    **** __TDESC(mathtest_Values, 1, 0) = {__TDFLDS("Values", 808), {-8}};
 245:mathtest.c    **** 
 246:mathtest.c    **** export int main(int argc, char **argv)
 247:mathtest.c    **** {
 1517              	.LM177:
 1518              	.LFBB14:
 1519              	.LFB20:
 1520              		.cfi_startproc
 1521 0a11 F30F1EFA 		endbr64
 1522 0a15 55       		pushq	%rbp
 1523              		.cfi_def_cfa_offset 16
 1524              		.cfi_offset 6, -16
 1525 0a16 4889E5   		movq	%rsp, %rbp
 1526              		.cfi_def_cfa_register 6
 1527 0a19 4883EC10 		subq	$16, %rsp
 1528 0a1d 897DFC   		movl	%edi, -4(%rbp)
 1529 0a20 488975F0 		movq	%rsi, -16(%rbp)
 248:mathtest.c    **** 	__INIT(argc, argv);
 1531              	.LM178:
 1532 0a24 488D55F0 		leaq	-16(%rbp), %rdx
 1533 0a28 8B45FC   		movl	-4(%rbp), %eax
 1534 0a2b 4889D6   		movq	%rdx, %rsi
 1535 0a2e 89C7     		movl	%eax, %edi
 1536 0a30 E8000000 		call	Modules_Init@PLT
 1536      00
 249:mathtest.c    **** 	__MODULE_IMPORT(Math);
 1538              	.LM179:
 1539 0a35 E8000000 		call	Math__init@PLT
 1539      00
 1540 0a3a 4889C7   		movq	%rax, %rdi
 1541 0a3d B8000000 		movl	$0, %eax
 1541      00
 1542 0a42 E8000000 		call	Heap_INCREF@PLT
 1542      00
 250:mathtest.c    **** 	__MODULE_IMPORT(MathL);
 1544              	.LM180:
 1545 0a47 E8000000 		call	MathL__init@PLT
 1545      00
 1546 0a4c 4889C7   		movq	%rax, %rdi
 1547 0a4f B8000000 		movl	$0, %eax
 1547      00
 1548 0a54 E8000000 		call	Heap_INCREF@PLT
 1548      00
 251:mathtest.c    **** 	__MODULE_IMPORT(Out);
 1550              	.LM181:
 1551 0a59 E8000000 		call	Out__init@PLT
 1551      00
 1552 0a5e 4889C7   		movq	%rax, %rdi
 1553 0a61 B8000000 		movl	$0, %eax
 1553      00
 1554 0a66 E8000000 		call	Heap_INCREF@PLT
 1554      00
 252:mathtest.c    **** 	__REGMAIN("mathtest", 0);
 1556              	.LM182:
 1557 0a6b BE000000 		movl	$0, %esi
 1557      00
 1558 0a70 488D3D00 		leaq	.LC23(%rip), %rdi
 1558      000000
 1559 0a77 B8000000 		movl	$0, %eax
 1559      00
 1560 0a7c E8000000 		call	Heap_REGMOD@PLT
 1560      00
 1561 0a81 48890500 		movq	%rax, m.2342(%rip)
 1561      000000
 253:mathtest.c    **** 	__INITYP(mathtest_Values, mathtest_Values, 0);
 1563              	.LM183:
 1564 0a88 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1564      000000
 1565 0a8f 488D1500 		leaq	200+mathtest_Values__desc(%rip), %rdx
 1565      000000
 1566 0a96 488910   		movq	%rdx, (%rax)
 1567 0a99 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1567      000000
 1568 0aa0 488B00   		movq	(%rax), %rax
 1569 0aa3 48890500 		movq	%rax, 64+mathtest_Values__desc(%rip)
 1569      000000
 1570 0aaa 488B0500 		movq	m.2342(%rip), %rax
 1570      000000
 1571 0ab1 48890500 		movq	%rax, 32+mathtest_Values__desc(%rip)
 1571      000000
 1572 0ab8 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 1572      000000
 1573 0abf 483D2803 		cmpq	$808, %rax
 1573      0000
 1574 0ac5 740A     		je	.L67
 1576              	.LM184:
 1577 0ac7 BFF1FFFF 		movl	$-15, %edi
 1577      FF
 1578 0acc E8000000 		call	Modules_Halt@PLT
 1578      00
 1579              	.L67:
 1581              	.LM185:
 1582 0ad1 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 1582      000000
 1583 0ad8 4883C027 		addq	$39, %rax
 1584 0adc 4883E0E0 		andq	$-32, %rax
 1585 0ae0 48890500 		movq	%rax, 200+mathtest_Values__desc(%rip)
 1585      000000
 1586 0ae7 488D1500 		leaq	16+mathtest_Values__desc(%rip), %rdx
 1586      000000
 1587 0aee 488B0500 		movq	m.2342(%rip), %rax
 1587      000000
 1588 0af5 4889D6   		movq	%rdx, %rsi
 1589 0af8 4889C7   		movq	%rax, %rdi
 1590 0afb B8000000 		movl	$0, %eax
 1590      00
 1591 0b00 E8000000 		call	Heap_REGTYP@PLT
 1591      00
 1592 0b05 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1592      000000
 1593 0b0c 488B10   		movq	(%rax), %rdx
 1594 0b0f 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1594      000000
 1595 0b16 488B00   		movq	(%rax), %rax
 1596 0b19 4889D6   		movq	%rdx, %rsi
 1597 0b1c 4889C7   		movq	%rax, %rdi
 1598 0b1f E8000000 		call	SYSTEM_INHERIT@PLT
 1598      00
 254:mathtest.c    **** /* BEGIN */
 255:mathtest.c    **** 	mathtest_ws((CHAR*)"Math and MathL module tests.", 29);
 1600              	.LM186:
 1601 0b24 BE1D0000 		movl	$29, %esi
 1601      00
 1602 0b29 488D3D00 		leaq	.LC24(%rip), %rdi
 1602      000000
 1603 0b30 E8EAF4FF 		call	mathtest_ws
 1603      FF
 256:mathtest.c    **** 	mathtest_wl();
 1605              	.LM187:
 1606 0b35 E844F6FF 		call	mathtest_wl
 1606      FF
 257:mathtest.c    **** 	mathtest_wl();
 1608              	.LM188:
 1609 0b3a E83FF6FF 		call	mathtest_wl
 1609      FF
 258:mathtest.c    **** 	mathtest_misc.n = 0;
 1611              	.LM189:
 1612 0b3f C7050000 		movl	$0, 800+mathtest_misc(%rip)
 1612      00000000 
 1612      0000
 259:mathtest.c    **** 	mathtest_addvalue(  9.00000000000000e-001, &mathtest_misc, mathtest_Values__typ);
 1614              	.LM190:
 1615 0b49 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1615      000000
 1616 0b50 488B10   		movq	(%rax), %rdx
 1617 0b53 488B0500 		movq	.LC25(%rip), %rax
 1617      000000
 1618 0b5a 4889D6   		movq	%rdx, %rsi
 1619 0b5d 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1619      000000
 1620 0b64 66480F6E 		movq	%rax, %xmm0
 1620      C0
 1621 0b69 E8F4F6FF 		call	mathtest_addvalue
 1621      FF
 260:mathtest.c    **** 	mathtest_addvalue((LONGREAL)1, &mathtest_misc, mathtest_Values__typ);
 1623              	.LM191:
 1624 0b6e 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1624      000000
 1625 0b75 488B10   		movq	(%rax), %rdx
 1626 0b78 488B0500 		movq	.LC26(%rip), %rax
 1626      000000
 1627 0b7f 4889D6   		movq	%rdx, %rsi
 1628 0b82 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1628      000000
 1629 0b89 66480F6E 		movq	%rax, %xmm0
 1629      C0
 1630 0b8e E8CFF6FF 		call	mathtest_addvalue
 1630      FF
 261:mathtest.c    **** 	mathtest_addvalue(  1.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1632              	.LM192:
 1633 0b93 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1633      000000
 1634 0b9a 488B10   		movq	(%rax), %rdx
 1635 0b9d 488B0500 		movq	.LC27(%rip), %rax
 1635      000000
 1636 0ba4 4889D6   		movq	%rdx, %rsi
 1637 0ba7 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1637      000000
 1638 0bae 66480F6E 		movq	%rax, %xmm0
 1638      C0
 1639 0bb3 E8AAF6FF 		call	mathtest_addvalue
 1639      FF
 262:mathtest.c    **** 	mathtest_addvalue(  1.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1641              	.LM193:
 1642 0bb8 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1642      000000
 1643 0bbf 488B10   		movq	(%rax), %rdx
 1644 0bc2 488B0500 		movq	.LC28(%rip), %rax
 1644      000000
 1645 0bc9 4889D6   		movq	%rdx, %rsi
 1646 0bcc 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1646      000000
 1647 0bd3 66480F6E 		movq	%rax, %xmm0
 1647      C0
 1648 0bd8 E885F6FF 		call	mathtest_addvalue
 1648      FF
 263:mathtest.c    **** 	mathtest_addvalue(  1.60000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1650              	.LM194:
 1651 0bdd 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1651      000000
 1652 0be4 488B10   		movq	(%rax), %rdx
 1653 0be7 488B0500 		movq	.LC29(%rip), %rax
 1653      000000
 1654 0bee 4889D6   		movq	%rdx, %rsi
 1655 0bf1 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1655      000000
 1656 0bf8 66480F6E 		movq	%rax, %xmm0
 1656      C0
 1657 0bfd E860F6FF 		call	mathtest_addvalue
 1657      FF
 264:mathtest.c    **** 	mathtest_addvalue(  1.90000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1659              	.LM195:
 1660 0c02 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1660      000000
 1661 0c09 488B10   		movq	(%rax), %rdx
 1662 0c0c 488B0500 		movq	.LC30(%rip), %rax
 1662      000000
 1663 0c13 4889D6   		movq	%rdx, %rsi
 1664 0c16 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1664      000000
 1665 0c1d 66480F6E 		movq	%rax, %xmm0
 1665      C0
 1666 0c22 E83BF6FF 		call	mathtest_addvalue
 1666      FF
 265:mathtest.c    **** 	mathtest_addvalue((LONGREAL)2, &mathtest_misc, mathtest_Values__typ);
 1668              	.LM196:
 1669 0c27 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1669      000000
 1670 0c2e 488B10   		movq	(%rax), %rdx
 1671 0c31 488B0500 		movq	.LC31(%rip), %rax
 1671      000000
 1672 0c38 4889D6   		movq	%rdx, %rsi
 1673 0c3b 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1673      000000
 1674 0c42 66480F6E 		movq	%rax, %xmm0
 1674      C0
 1675 0c47 E816F6FF 		call	mathtest_addvalue
 1675      FF
 266:mathtest.c    **** 	mathtest_addvalue(  2.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1677              	.LM197:
 1678 0c4c 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1678      000000
 1679 0c53 488B10   		movq	(%rax), %rdx
 1680 0c56 488B0500 		movq	.LC32(%rip), %rax
 1680      000000
 1681 0c5d 4889D6   		movq	%rdx, %rsi
 1682 0c60 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1682      000000
 1683 0c67 66480F6E 		movq	%rax, %xmm0
 1683      C0
 1684 0c6c E8F1F5FF 		call	mathtest_addvalue
 1684      FF
 267:mathtest.c    **** 	mathtest_addvalue(  2.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1686              	.LM198:
 1687 0c71 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1687      000000
 1688 0c78 488B10   		movq	(%rax), %rdx
 1689 0c7b 488B0500 		movq	.LC33(%rip), %rax
 1689      000000
 1690 0c82 4889D6   		movq	%rdx, %rsi
 1691 0c85 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1691      000000
 1692 0c8c 66480F6E 		movq	%rax, %xmm0
 1692      C0
 1693 0c91 E8CCF5FF 		call	mathtest_addvalue
 1693      FF
 268:mathtest.c    **** 	mathtest_addvalue((LONGREAL)3, &mathtest_misc, mathtest_Values__typ);
 1695              	.LM199:
 1696 0c96 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1696      000000
 1697 0c9d 488B10   		movq	(%rax), %rdx
 1698 0ca0 488B0500 		movq	.LC34(%rip), %rax
 1698      000000
 1699 0ca7 4889D6   		movq	%rdx, %rsi
 1700 0caa 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1700      000000
 1701 0cb1 66480F6E 		movq	%rax, %xmm0
 1701      C0
 1702 0cb6 E8A7F5FF 		call	mathtest_addvalue
 1702      FF
 269:mathtest.c    **** 	mathtest_addvalue((LONGREAL)4, &mathtest_misc, mathtest_Values__typ);
 1704              	.LM200:
 1705 0cbb 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1705      000000
 1706 0cc2 488B10   		movq	(%rax), %rdx
 1707 0cc5 488B0500 		movq	.LC35(%rip), %rax
 1707      000000
 1708 0ccc 4889D6   		movq	%rdx, %rsi
 1709 0ccf 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1709      000000
 1710 0cd6 66480F6E 		movq	%rax, %xmm0
 1710      C0
 1711 0cdb E882F5FF 		call	mathtest_addvalue
 1711      FF
 270:mathtest.c    **** 	mathtest_addvalue( -9.00000000000000e-001, &mathtest_misc, mathtest_Values__typ);
 1713              	.LM201:
 1714 0ce0 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1714      000000
 1715 0ce7 488B10   		movq	(%rax), %rdx
 1716 0cea 488B0500 		movq	.LC36(%rip), %rax
 1716      000000
 1717 0cf1 4889D6   		movq	%rdx, %rsi
 1718 0cf4 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1718      000000
 1719 0cfb 66480F6E 		movq	%rax, %xmm0
 1719      C0
 1720 0d00 E85DF5FF 		call	mathtest_addvalue
 1720      FF
 271:mathtest.c    **** 	mathtest_addvalue((LONGREAL)-1, &mathtest_misc, mathtest_Values__typ);
 1722              	.LM202:
 1723 0d05 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1723      000000
 1724 0d0c 488B10   		movq	(%rax), %rdx
 1725 0d0f 488B0500 		movq	.LC37(%rip), %rax
 1725      000000
 1726 0d16 4889D6   		movq	%rdx, %rsi
 1727 0d19 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1727      000000
 1728 0d20 66480F6E 		movq	%rax, %xmm0
 1728      C0
 1729 0d25 E838F5FF 		call	mathtest_addvalue
 1729      FF
 272:mathtest.c    **** 	mathtest_addvalue( -1.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1731              	.LM203:
 1732 0d2a 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1732      000000
 1733 0d31 488B10   		movq	(%rax), %rdx
 1734 0d34 488B0500 		movq	.LC38(%rip), %rax
 1734      000000
 1735 0d3b 4889D6   		movq	%rdx, %rsi
 1736 0d3e 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1736      000000
 1737 0d45 66480F6E 		movq	%rax, %xmm0
 1737      C0
 1738 0d4a E813F5FF 		call	mathtest_addvalue
 1738      FF
 273:mathtest.c    **** 	mathtest_addvalue( -1.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1740              	.LM204:
 1741 0d4f 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1741      000000
 1742 0d56 488B10   		movq	(%rax), %rdx
 1743 0d59 488B0500 		movq	.LC39(%rip), %rax
 1743      000000
 1744 0d60 4889D6   		movq	%rdx, %rsi
 1745 0d63 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1745      000000
 1746 0d6a 66480F6E 		movq	%rax, %xmm0
 1746      C0
 1747 0d6f E8EEF4FF 		call	mathtest_addvalue
 1747      FF
 274:mathtest.c    **** 	mathtest_addvalue( -1.60000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1749              	.LM205:
 1750 0d74 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1750      000000
 1751 0d7b 488B10   		movq	(%rax), %rdx
 1752 0d7e 488B0500 		movq	.LC40(%rip), %rax
 1752      000000
 1753 0d85 4889D6   		movq	%rdx, %rsi
 1754 0d88 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1754      000000
 1755 0d8f 66480F6E 		movq	%rax, %xmm0
 1755      C0
 1756 0d94 E8C9F4FF 		call	mathtest_addvalue
 1756      FF
 275:mathtest.c    **** 	mathtest_addvalue( -1.90000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1758              	.LM206:
 1759 0d99 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1759      000000
 1760 0da0 488B10   		movq	(%rax), %rdx
 1761 0da3 488B0500 		movq	.LC41(%rip), %rax
 1761      000000
 1762 0daa 4889D6   		movq	%rdx, %rsi
 1763 0dad 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1763      000000
 1764 0db4 66480F6E 		movq	%rax, %xmm0
 1764      C0
 1765 0db9 E8A4F4FF 		call	mathtest_addvalue
 1765      FF
 276:mathtest.c    **** 	mathtest_addvalue((LONGREAL)-2, &mathtest_misc, mathtest_Values__typ);
 1767              	.LM207:
 1768 0dbe 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1768      000000
 1769 0dc5 488B10   		movq	(%rax), %rdx
 1770 0dc8 488B0500 		movq	.LC42(%rip), %rax
 1770      000000
 1771 0dcf 4889D6   		movq	%rdx, %rsi
 1772 0dd2 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1772      000000
 1773 0dd9 66480F6E 		movq	%rax, %xmm0
 1773      C0
 1774 0dde E87FF4FF 		call	mathtest_addvalue
 1774      FF
 277:mathtest.c    **** 	mathtest_addvalue( -2.40000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1776              	.LM208:
 1777 0de3 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1777      000000
 1778 0dea 488B10   		movq	(%rax), %rdx
 1779 0ded 488B0500 		movq	.LC43(%rip), %rax
 1779      000000
 1780 0df4 4889D6   		movq	%rdx, %rsi
 1781 0df7 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1781      000000
 1782 0dfe 66480F6E 		movq	%rax, %xmm0
 1782      C0
 1783 0e03 E85AF4FF 		call	mathtest_addvalue
 1783      FF
 278:mathtest.c    **** 	mathtest_addvalue( -2.50000000000000e+000, &mathtest_misc, mathtest_Values__typ);
 1785              	.LM209:
 1786 0e08 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1786      000000
 1787 0e0f 488B10   		movq	(%rax), %rdx
 1788 0e12 488B0500 		movq	.LC44(%rip), %rax
 1788      000000
 1789 0e19 4889D6   		movq	%rdx, %rsi
 1790 0e1c 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1790      000000
 1791 0e23 66480F6E 		movq	%rax, %xmm0
 1791      C0
 1792 0e28 E835F4FF 		call	mathtest_addvalue
 1792      FF
 279:mathtest.c    **** 	mathtest_addvalue((LONGREAL)-3, &mathtest_misc, mathtest_Values__typ);
 1794              	.LM210:
 1795 0e2d 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1795      000000
 1796 0e34 488B10   		movq	(%rax), %rdx
 1797 0e37 488B0500 		movq	.LC45(%rip), %rax
 1797      000000
 1798 0e3e 4889D6   		movq	%rdx, %rsi
 1799 0e41 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1799      000000
 1800 0e48 66480F6E 		movq	%rax, %xmm0
 1800      C0
 1801 0e4d E810F4FF 		call	mathtest_addvalue
 1801      FF
 280:mathtest.c    **** 	mathtest_addvalue((LONGREAL)-4, &mathtest_misc, mathtest_Values__typ);
 1803              	.LM211:
 1804 0e52 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1804      000000
 1805 0e59 488B10   		movq	(%rax), %rdx
 1806 0e5c 488B0500 		movq	.LC46(%rip), %rax
 1806      000000
 1807 0e63 4889D6   		movq	%rdx, %rsi
 1808 0e66 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 1808      000000
 1809 0e6d 66480F6E 		movq	%rax, %xmm0
 1809      C0
 1810 0e72 E8EBF3FF 		call	mathtest_addvalue
 1810      FF
 281:mathtest.c    **** 	mathtest_angles.n = 0;
 1812              	.LM212:
 1813 0e77 C7050000 		movl	$0, 800+mathtest_angles(%rip)
 1813      00000000 
 1813      0000
 282:mathtest.c    **** 	mathtest_addvalue((LONGREAL)0, &mathtest_angles, mathtest_Values__typ);
 1815              	.LM213:
 1816 0e81 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1816      000000
 1817 0e88 488B00   		movq	(%rax), %rax
 1818 0e8b 4889C6   		movq	%rax, %rsi
 1819 0e8e 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1819      000000
 1820 0e95 660FEFC0 		pxor	%xmm0, %xmm0
 1821 0e99 E8C4F3FF 		call	mathtest_addvalue
 1821      FF
 283:mathtest.c    **** 	mathtest_addvalue(  1.00000000000000e-001, &mathtest_angles, mathtest_Values__typ);
 1823              	.LM214:
 1824 0e9e 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1824      000000
 1825 0ea5 488B10   		movq	(%rax), %rdx
 1826 0ea8 488B0500 		movq	.LC48(%rip), %rax
 1826      000000
 1827 0eaf 4889D6   		movq	%rdx, %rsi
 1828 0eb2 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1828      000000
 1829 0eb9 66480F6E 		movq	%rax, %xmm0
 1829      C0
 1830 0ebe E89FF3FF 		call	mathtest_addvalue
 1830      FF
 284:mathtest.c    **** 	mathtest_addvalue(  1.04719755119660e+000, &mathtest_angles, mathtest_Values__typ);
 1832              	.LM215:
 1833 0ec3 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1833      000000
 1834 0eca 488B10   		movq	(%rax), %rdx
 1835 0ecd 488B0500 		movq	.LC49(%rip), %rax
 1835      000000
 1836 0ed4 4889D6   		movq	%rdx, %rsi
 1837 0ed7 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1837      000000
 1838 0ede 66480F6E 		movq	%rax, %xmm0
 1838      C0
 1839 0ee3 E87AF3FF 		call	mathtest_addvalue
 1839      FF
 285:mathtest.c    **** 	mathtest_addvalue(  1.57079632679490e+000, &mathtest_angles, mathtest_Values__typ);
 1841              	.LM216:
 1842 0ee8 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1842      000000
 1843 0eef 488B10   		movq	(%rax), %rdx
 1844 0ef2 488B0500 		movq	.LC50(%rip), %rax
 1844      000000
 1845 0ef9 4889D6   		movq	%rdx, %rsi
 1846 0efc 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1846      000000
 1847 0f03 66480F6E 		movq	%rax, %xmm0
 1847      C0
 1848 0f08 E855F3FF 		call	mathtest_addvalue
 1848      FF
 286:mathtest.c    **** 	mathtest_addvalue(  3.14159265358979e+000, &mathtest_angles, mathtest_Values__typ);
 1850              	.LM217:
 1851 0f0d 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1851      000000
 1852 0f14 488B10   		movq	(%rax), %rdx
 1853 0f17 488B0500 		movq	.LC51(%rip), %rax
 1853      000000
 1854 0f1e 4889D6   		movq	%rdx, %rsi
 1855 0f21 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1855      000000
 1856 0f28 66480F6E 		movq	%rax, %xmm0
 1856      C0
 1857 0f2d E830F3FF 		call	mathtest_addvalue
 1857      FF
 287:mathtest.c    **** 	mathtest_addvalue( -1.04719755119660e+000, &mathtest_angles, mathtest_Values__typ);
 1859              	.LM218:
 1860 0f32 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1860      000000
 1861 0f39 488B10   		movq	(%rax), %rdx
 1862 0f3c 488B0500 		movq	.LC52(%rip), %rax
 1862      000000
 1863 0f43 4889D6   		movq	%rdx, %rsi
 1864 0f46 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1864      000000
 1865 0f4d 66480F6E 		movq	%rax, %xmm0
 1865      C0
 1866 0f52 E80BF3FF 		call	mathtest_addvalue
 1866      FF
 288:mathtest.c    **** 	mathtest_addvalue( -1.57079632679490e+000, &mathtest_angles, mathtest_Values__typ);
 1868              	.LM219:
 1869 0f57 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1869      000000
 1870 0f5e 488B10   		movq	(%rax), %rdx
 1871 0f61 488B0500 		movq	.LC53(%rip), %rax
 1871      000000
 1872 0f68 4889D6   		movq	%rdx, %rsi
 1873 0f6b 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1873      000000
 1874 0f72 66480F6E 		movq	%rax, %xmm0
 1874      C0
 1875 0f77 E8E6F2FF 		call	mathtest_addvalue
 1875      FF
 289:mathtest.c    **** 	mathtest_addvalue( -3.14159265358979e+000, &mathtest_angles, mathtest_Values__typ);
 1877              	.LM220:
 1878 0f7c 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 1878      000000
 1879 0f83 488B10   		movq	(%rax), %rdx
 1880 0f86 488B0500 		movq	.LC54(%rip), %rax
 1880      000000
 1881 0f8d 4889D6   		movq	%rdx, %rsi
 1882 0f90 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 1882      000000
 1883 0f97 66480F6E 		movq	%rax, %xmm0
 1883      C0
 1884 0f9c E8C1F2FF 		call	mathtest_addvalue
 1884      FF
 290:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"fraction", 9, Math_fraction, MathL_fraction, mathtest_misc);
 1886              	.LM221:
 1887 0fa1 4883EC08 		subq	$8, %rsp
 1888 0fa5 4881EC28 		subq	$808, %rsp
 1888      030000
 1889 0fac 4889E0   		movq	%rsp, %rax
 1890 0faf 4889C7   		movq	%rax, %rdi
 1891 0fb2 488D0500 		leaq	mathtest_misc(%rip), %rax
 1891      000000
 1892 0fb9 BA650000 		movl	$101, %edx
 1892      00
 1893 0fbe 4889C6   		movq	%rax, %rsi
 1894 0fc1 4889D1   		movq	%rdx, %rcx
 1895 0fc4 F348A5   		rep movsq
 1896 0fc7 488B0500 		movq	MathL_fraction@GOTPCREL(%rip), %rax
 1896      000000
 1897 0fce 4889C1   		movq	%rax, %rcx
 1898 0fd1 488B0500 		movq	Math_fraction@GOTPCREL(%rip), %rax
 1898      000000
 1899 0fd8 4889C2   		movq	%rax, %rdx
 1900 0fdb BE090000 		movl	$9, %esi
 1900      00
 1901 0fe0 488D3D00 		leaq	.LC55(%rip), %rdi
 1901      000000
 1902 0fe7 E85BF4FF 		call	mathtest_TestRtoR
 1902      FF
 1903 0fec 4881C430 		addq	$816, %rsp
 1903      030000
 291:mathtest.c    **** 	mathtest_TestRtoLI((CHAR*)"round", 6, Math_round, MathL_round, mathtest_misc);
 1905              	.LM222:
 1906 0ff3 4883EC08 		subq	$8, %rsp
 1907 0ff7 4881EC28 		subq	$808, %rsp
 1907      030000
 1908 0ffe 4889E0   		movq	%rsp, %rax
 1909 1001 4889C7   		movq	%rax, %rdi
 1910 1004 488D0500 		leaq	mathtest_misc(%rip), %rax
 1910      000000
 1911 100b BA650000 		movl	$101, %edx
 1911      00
 1912 1010 4889C6   		movq	%rax, %rsi
 1913 1013 4889D1   		movq	%rdx, %rcx
 1914 1016 F348A5   		rep movsq
 1915 1019 488B0500 		movq	MathL_round@GOTPCREL(%rip), %rax
 1915      000000
 1916 1020 4889C1   		movq	%rax, %rcx
 1917 1023 488B0500 		movq	Math_round@GOTPCREL(%rip), %rax
 1917      000000
 1918 102a 4889C2   		movq	%rax, %rdx
 1919 102d BE060000 		movl	$6, %esi
 1919      00
 1920 1032 488D3D00 		leaq	.LC56(%rip), %rdi
 1920      000000
 1921 1039 E847F6FF 		call	mathtest_TestRtoLI
 1921      FF
 1922 103e 4881C430 		addq	$816, %rsp
 1922      030000
 292:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"sqrt", 5, Math_sqrt, MathL_sqrt, mathtest_misc);
 1924              	.LM223:
 1925 1045 4883EC08 		subq	$8, %rsp
 1926 1049 4881EC28 		subq	$808, %rsp
 1926      030000
 1927 1050 4889E0   		movq	%rsp, %rax
 1928 1053 4889C7   		movq	%rax, %rdi
 1929 1056 488D0500 		leaq	mathtest_misc(%rip), %rax
 1929      000000
 1930 105d BA650000 		movl	$101, %edx
 1930      00
 1931 1062 4889C6   		movq	%rax, %rsi
 1932 1065 4889D1   		movq	%rdx, %rcx
 1933 1068 F348A5   		rep movsq
 1934 106b 488B0500 		movq	MathL_sqrt@GOTPCREL(%rip), %rax
 1934      000000
 1935 1072 4889C1   		movq	%rax, %rcx
 1936 1075 488B0500 		movq	Math_sqrt@GOTPCREL(%rip), %rax
 1936      000000
 1937 107c 4889C2   		movq	%rax, %rdx
 1938 107f BE050000 		movl	$5, %esi
 1938      00
 1939 1084 488D3D00 		leaq	.LC57(%rip), %rdi
 1939      000000
 1940 108b E8B7F3FF 		call	mathtest_TestRtoR
 1940      FF
 1941 1090 4881C430 		addq	$816, %rsp
 1941      030000
 293:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"ln", 3, Math_ln, MathL_ln, mathtest_misc);
 1943              	.LM224:
 1944 1097 4883EC08 		subq	$8, %rsp
 1945 109b 4881EC28 		subq	$808, %rsp
 1945      030000
 1946 10a2 4889E0   		movq	%rsp, %rax
 1947 10a5 4889C7   		movq	%rax, %rdi
 1948 10a8 488D0500 		leaq	mathtest_misc(%rip), %rax
 1948      000000
 1949 10af BA650000 		movl	$101, %edx
 1949      00
 1950 10b4 4889C6   		movq	%rax, %rsi
 1951 10b7 4889D1   		movq	%rdx, %rcx
 1952 10ba F348A5   		rep movsq
 1953 10bd 488B0500 		movq	MathL_ln@GOTPCREL(%rip), %rax
 1953      000000
 1954 10c4 4889C1   		movq	%rax, %rcx
 1955 10c7 488B0500 		movq	Math_ln@GOTPCREL(%rip), %rax
 1955      000000
 1956 10ce 4889C2   		movq	%rax, %rdx
 1957 10d1 BE030000 		movl	$3, %esi
 1957      00
 1958 10d6 488D3D00 		leaq	.LC58(%rip), %rdi
 1958      000000
 1959 10dd E865F3FF 		call	mathtest_TestRtoR
 1959      FF
 1960 10e2 4881C430 		addq	$816, %rsp
 1960      030000
 294:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"sin", 4, Math_sin, MathL_sin, mathtest_angles);
 1962              	.LM225:
 1963 10e9 4883EC08 		subq	$8, %rsp
 1964 10ed 4881EC28 		subq	$808, %rsp
 1964      030000
 1965 10f4 4889E0   		movq	%rsp, %rax
 1966 10f7 4889C7   		movq	%rax, %rdi
 1967 10fa 488D0500 		leaq	mathtest_angles(%rip), %rax
 1967      000000
 1968 1101 BA650000 		movl	$101, %edx
 1968      00
 1969 1106 4889C6   		movq	%rax, %rsi
 1970 1109 4889D1   		movq	%rdx, %rcx
 1971 110c F348A5   		rep movsq
 1972 110f 488B0500 		movq	MathL_sin@GOTPCREL(%rip), %rax
 1972      000000
 1973 1116 4889C1   		movq	%rax, %rcx
 1974 1119 488B0500 		movq	Math_sin@GOTPCREL(%rip), %rax
 1974      000000
 1975 1120 4889C2   		movq	%rax, %rdx
 1976 1123 BE040000 		movl	$4, %esi
 1976      00
 1977 1128 488D3D00 		leaq	.LC59(%rip), %rdi
 1977      000000
 1978 112f E813F3FF 		call	mathtest_TestRtoR
 1978      FF
 1979 1134 4881C430 		addq	$816, %rsp
 1979      030000
 295:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"cos", 4, Math_cos, MathL_cos, mathtest_angles);
 1981              	.LM226:
 1982 113b 4883EC08 		subq	$8, %rsp
 1983 113f 4881EC28 		subq	$808, %rsp
 1983      030000
 1984 1146 4889E0   		movq	%rsp, %rax
 1985 1149 4889C7   		movq	%rax, %rdi
 1986 114c 488D0500 		leaq	mathtest_angles(%rip), %rax
 1986      000000
 1987 1153 BA650000 		movl	$101, %edx
 1987      00
 1988 1158 4889C6   		movq	%rax, %rsi
 1989 115b 4889D1   		movq	%rdx, %rcx
 1990 115e F348A5   		rep movsq
 1991 1161 488B0500 		movq	MathL_cos@GOTPCREL(%rip), %rax
 1991      000000
 1992 1168 4889C1   		movq	%rax, %rcx
 1993 116b 488B0500 		movq	Math_cos@GOTPCREL(%rip), %rax
 1993      000000
 1994 1172 4889C2   		movq	%rax, %rdx
 1995 1175 BE040000 		movl	$4, %esi
 1995      00
 1996 117a 488D3D00 		leaq	.LC60(%rip), %rdi
 1996      000000
 1997 1181 E8C1F2FF 		call	mathtest_TestRtoR
 1997      FF
 1998 1186 4881C430 		addq	$816, %rsp
 1998      030000
 296:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"tan", 4, Math_tan, MathL_tan, mathtest_angles);
 2000              	.LM227:
 2001 118d 4883EC08 		subq	$8, %rsp
 2002 1191 4881EC28 		subq	$808, %rsp
 2002      030000
 2003 1198 4889E0   		movq	%rsp, %rax
 2004 119b 4889C7   		movq	%rax, %rdi
 2005 119e 488D0500 		leaq	mathtest_angles(%rip), %rax
 2005      000000
 2006 11a5 BA650000 		movl	$101, %edx
 2006      00
 2007 11aa 4889C6   		movq	%rax, %rsi
 2008 11ad 4889D1   		movq	%rdx, %rcx
 2009 11b0 F348A5   		rep movsq
 2010 11b3 488B0500 		movq	MathL_tan@GOTPCREL(%rip), %rax
 2010      000000
 2011 11ba 4889C1   		movq	%rax, %rcx
 2012 11bd 488B0500 		movq	Math_tan@GOTPCREL(%rip), %rax
 2012      000000
 2013 11c4 4889C2   		movq	%rax, %rdx
 2014 11c7 BE040000 		movl	$4, %esi
 2014      00
 2015 11cc 488D3D00 		leaq	.LC61(%rip), %rdi
 2015      000000
 2016 11d3 E86FF2FF 		call	mathtest_TestRtoR
 2016      FF
 2017 11d8 4881C430 		addq	$816, %rsp
 2017      030000
 297:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arcsin", 7, Math_arcsin, MathL_arcsin, mathtest_misc);
 2019              	.LM228:
 2020 11df 4883EC08 		subq	$8, %rsp
 2021 11e3 4881EC28 		subq	$808, %rsp
 2021      030000
 2022 11ea 4889E0   		movq	%rsp, %rax
 2023 11ed 4889C7   		movq	%rax, %rdi
 2024 11f0 488D0500 		leaq	mathtest_misc(%rip), %rax
 2024      000000
 2025 11f7 BA650000 		movl	$101, %edx
 2025      00
 2026 11fc 4889C6   		movq	%rax, %rsi
 2027 11ff 4889D1   		movq	%rdx, %rcx
 2028 1202 F348A5   		rep movsq
 2029 1205 488B0500 		movq	MathL_arcsin@GOTPCREL(%rip), %rax
 2029      000000
 2030 120c 4889C1   		movq	%rax, %rcx
 2031 120f 488B0500 		movq	Math_arcsin@GOTPCREL(%rip), %rax
 2031      000000
 2032 1216 4889C2   		movq	%rax, %rdx
 2033 1219 BE070000 		movl	$7, %esi
 2033      00
 2034 121e 488D3D00 		leaq	.LC62(%rip), %rdi
 2034      000000
 2035 1225 E81DF2FF 		call	mathtest_TestRtoR
 2035      FF
 2036 122a 4881C430 		addq	$816, %rsp
 2036      030000
 298:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arccos", 7, Math_arccos, MathL_arccos, mathtest_misc);
 2038              	.LM229:
 2039 1231 4883EC08 		subq	$8, %rsp
 2040 1235 4881EC28 		subq	$808, %rsp
 2040      030000
 2041 123c 4889E0   		movq	%rsp, %rax
 2042 123f 4889C7   		movq	%rax, %rdi
 2043 1242 488D0500 		leaq	mathtest_misc(%rip), %rax
 2043      000000
 2044 1249 BA650000 		movl	$101, %edx
 2044      00
 2045 124e 4889C6   		movq	%rax, %rsi
 2046 1251 4889D1   		movq	%rdx, %rcx
 2047 1254 F348A5   		rep movsq
 2048 1257 488B0500 		movq	MathL_arccos@GOTPCREL(%rip), %rax
 2048      000000
 2049 125e 4889C1   		movq	%rax, %rcx
 2050 1261 488B0500 		movq	Math_arccos@GOTPCREL(%rip), %rax
 2050      000000
 2051 1268 4889C2   		movq	%rax, %rdx
 2052 126b BE070000 		movl	$7, %esi
 2052      00
 2053 1270 488D3D00 		leaq	.LC63(%rip), %rdi
 2053      000000
 2054 1277 E8CBF1FF 		call	mathtest_TestRtoR
 2054      FF
 2055 127c 4881C430 		addq	$816, %rsp
 2055      030000
 299:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arctan", 7, Math_arctan, MathL_arctan, mathtest_misc);
 2057              	.LM230:
 2058 1283 4883EC08 		subq	$8, %rsp
 2059 1287 4881EC28 		subq	$808, %rsp
 2059      030000
 2060 128e 4889E0   		movq	%rsp, %rax
 2061 1291 4889C7   		movq	%rax, %rdi
 2062 1294 488D0500 		leaq	mathtest_misc(%rip), %rax
 2062      000000
 2063 129b BA650000 		movl	$101, %edx
 2063      00
 2064 12a0 4889C6   		movq	%rax, %rsi
 2065 12a3 4889D1   		movq	%rdx, %rcx
 2066 12a6 F348A5   		rep movsq
 2067 12a9 488B0500 		movq	MathL_arctan@GOTPCREL(%rip), %rax
 2067      000000
 2068 12b0 4889C1   		movq	%rax, %rcx
 2069 12b3 488B0500 		movq	Math_arctan@GOTPCREL(%rip), %rax
 2069      000000
 2070 12ba 4889C2   		movq	%rax, %rdx
 2071 12bd BE070000 		movl	$7, %esi
 2071      00
 2072 12c2 488D3D00 		leaq	.LC64(%rip), %rdi
 2072      000000
 2073 12c9 E879F1FF 		call	mathtest_TestRtoR
 2073      FF
 2074 12ce 4881C430 		addq	$816, %rsp
 2074      030000
 300:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"sinh", 5, Math_sinh, MathL_sinh, mathtest_misc);
 2076              	.LM231:
 2077 12d5 4883EC08 		subq	$8, %rsp
 2078 12d9 4881EC28 		subq	$808, %rsp
 2078      030000
 2079 12e0 4889E0   		movq	%rsp, %rax
 2080 12e3 4889C7   		movq	%rax, %rdi
 2081 12e6 488D0500 		leaq	mathtest_misc(%rip), %rax
 2081      000000
 2082 12ed BA650000 		movl	$101, %edx
 2082      00
 2083 12f2 4889C6   		movq	%rax, %rsi
 2084 12f5 4889D1   		movq	%rdx, %rcx
 2085 12f8 F348A5   		rep movsq
 2086 12fb 488B0500 		movq	MathL_sinh@GOTPCREL(%rip), %rax
 2086      000000
 2087 1302 4889C1   		movq	%rax, %rcx
 2088 1305 488B0500 		movq	Math_sinh@GOTPCREL(%rip), %rax
 2088      000000
 2089 130c 4889C2   		movq	%rax, %rdx
 2090 130f BE050000 		movl	$5, %esi
 2090      00
 2091 1314 488D3D00 		leaq	.LC65(%rip), %rdi
 2091      000000
 2092 131b E827F1FF 		call	mathtest_TestRtoR
 2092      FF
 2093 1320 4881C430 		addq	$816, %rsp
 2093      030000
 301:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"cosh", 5, Math_cosh, MathL_cosh, mathtest_misc);
 2095              	.LM232:
 2096 1327 4883EC08 		subq	$8, %rsp
 2097 132b 4881EC28 		subq	$808, %rsp
 2097      030000
 2098 1332 4889E0   		movq	%rsp, %rax
 2099 1335 4889C7   		movq	%rax, %rdi
 2100 1338 488D0500 		leaq	mathtest_misc(%rip), %rax
 2100      000000
 2101 133f BA650000 		movl	$101, %edx
 2101      00
 2102 1344 4889C6   		movq	%rax, %rsi
 2103 1347 4889D1   		movq	%rdx, %rcx
 2104 134a F348A5   		rep movsq
 2105 134d 488B0500 		movq	MathL_cosh@GOTPCREL(%rip), %rax
 2105      000000
 2106 1354 4889C1   		movq	%rax, %rcx
 2107 1357 488B0500 		movq	Math_cosh@GOTPCREL(%rip), %rax
 2107      000000
 2108 135e 4889C2   		movq	%rax, %rdx
 2109 1361 BE050000 		movl	$5, %esi
 2109      00
 2110 1366 488D3D00 		leaq	.LC66(%rip), %rdi
 2110      000000
 2111 136d E8D5F0FF 		call	mathtest_TestRtoR
 2111      FF
 2112 1372 4881C430 		addq	$816, %rsp
 2112      030000
 302:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"tanh", 5, Math_tanh, MathL_tanh, mathtest_misc);
 2114              	.LM233:
 2115 1379 4883EC08 		subq	$8, %rsp
 2116 137d 4881EC28 		subq	$808, %rsp
 2116      030000
 2117 1384 4889E0   		movq	%rsp, %rax
 2118 1387 4889C7   		movq	%rax, %rdi
 2119 138a 488D0500 		leaq	mathtest_misc(%rip), %rax
 2119      000000
 2120 1391 BA650000 		movl	$101, %edx
 2120      00
 2121 1396 4889C6   		movq	%rax, %rsi
 2122 1399 4889D1   		movq	%rdx, %rcx
 2123 139c F348A5   		rep movsq
 2124 139f 488B0500 		movq	MathL_tanh@GOTPCREL(%rip), %rax
 2124      000000
 2125 13a6 4889C1   		movq	%rax, %rcx
 2126 13a9 488B0500 		movq	Math_tanh@GOTPCREL(%rip), %rax
 2126      000000
 2127 13b0 4889C2   		movq	%rax, %rdx
 2128 13b3 BE050000 		movl	$5, %esi
 2128      00
 2129 13b8 488D3D00 		leaq	.LC67(%rip), %rdi
 2129      000000
 2130 13bf E883F0FF 		call	mathtest_TestRtoR
 2130      FF
 2131 13c4 4881C430 		addq	$816, %rsp
 2131      030000
 303:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arcsinh", 8, Math_arcsinh, MathL_arcsinh, mathtest_misc);
 2133              	.LM234:
 2134 13cb 4883EC08 		subq	$8, %rsp
 2135 13cf 4881EC28 		subq	$808, %rsp
 2135      030000
 2136 13d6 4889E0   		movq	%rsp, %rax
 2137 13d9 4889C7   		movq	%rax, %rdi
 2138 13dc 488D0500 		leaq	mathtest_misc(%rip), %rax
 2138      000000
 2139 13e3 BA650000 		movl	$101, %edx
 2139      00
 2140 13e8 4889C6   		movq	%rax, %rsi
 2141 13eb 4889D1   		movq	%rdx, %rcx
 2142 13ee F348A5   		rep movsq
 2143 13f1 488B0500 		movq	MathL_arcsinh@GOTPCREL(%rip), %rax
 2143      000000
 2144 13f8 4889C1   		movq	%rax, %rcx
 2145 13fb 488B0500 		movq	Math_arcsinh@GOTPCREL(%rip), %rax
 2145      000000
 2146 1402 4889C2   		movq	%rax, %rdx
 2147 1405 BE080000 		movl	$8, %esi
 2147      00
 2148 140a 488D3D00 		leaq	.LC68(%rip), %rdi
 2148      000000
 2149 1411 E831F0FF 		call	mathtest_TestRtoR
 2149      FF
 2150 1416 4881C430 		addq	$816, %rsp
 2150      030000
 304:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arccosh", 8, Math_arccosh, MathL_arccosh, mathtest_misc);
 2152              	.LM235:
 2153 141d 4883EC08 		subq	$8, %rsp
 2154 1421 4881EC28 		subq	$808, %rsp
 2154      030000
 2155 1428 4889E0   		movq	%rsp, %rax
 2156 142b 4889C7   		movq	%rax, %rdi
 2157 142e 488D0500 		leaq	mathtest_misc(%rip), %rax
 2157      000000
 2158 1435 BA650000 		movl	$101, %edx
 2158      00
 2159 143a 4889C6   		movq	%rax, %rsi
 2160 143d 4889D1   		movq	%rdx, %rcx
 2161 1440 F348A5   		rep movsq
 2162 1443 488B0500 		movq	MathL_arccosh@GOTPCREL(%rip), %rax
 2162      000000
 2163 144a 4889C1   		movq	%rax, %rcx
 2164 144d 488B0500 		movq	Math_arccosh@GOTPCREL(%rip), %rax
 2164      000000
 2165 1454 4889C2   		movq	%rax, %rdx
 2166 1457 BE080000 		movl	$8, %esi
 2166      00
 2167 145c 488D3D00 		leaq	.LC69(%rip), %rdi
 2167      000000
 2168 1463 E8DFEFFF 		call	mathtest_TestRtoR
 2168      FF
 2169 1468 4881C430 		addq	$816, %rsp
 2169      030000
 305:mathtest.c    **** 	mathtest_TestRtoR((CHAR*)"arctanh", 8, Math_arctanh, MathL_arctanh, mathtest_misc);
 2171              	.LM236:
 2172 146f 4883EC08 		subq	$8, %rsp
 2173 1473 4881EC28 		subq	$808, %rsp
 2173      030000
 2174 147a 4889E0   		movq	%rsp, %rax
 2175 147d 4889C7   		movq	%rax, %rdi
 2176 1480 488D0500 		leaq	mathtest_misc(%rip), %rax
 2176      000000
 2177 1487 BA650000 		movl	$101, %edx
 2177      00
 2178 148c 4889C6   		movq	%rax, %rsi
 2179 148f 4889D1   		movq	%rdx, %rcx
 2180 1492 F348A5   		rep movsq
 2181 1495 488B0500 		movq	MathL_arctanh@GOTPCREL(%rip), %rax
 2181      000000
 2182 149c 4889C1   		movq	%rax, %rcx
 2183 149f 488B0500 		movq	Math_arctanh@GOTPCREL(%rip), %rax
 2183      000000
 2184 14a6 4889C2   		movq	%rax, %rdx
 2185 14a9 BE080000 		movl	$8, %esi
 2185      00
 2186 14ae 488D3D00 		leaq	.LC70(%rip), %rdi
 2186      000000
 2187 14b5 E88DEFFF 		call	mathtest_TestRtoR
 2187      FF
 2188 14ba 4881C430 		addq	$816, %rsp
 2188      030000
 306:mathtest.c    **** 	__FINI;
 2190              	.LM237:
 2191 14c1 B8000000 		movl	$0, %eax
 2191      00
 2192 14c6 E8000000 		call	Heap_FINALL@PLT
 2192      00
 2193 14cb B8000000 		movl	$0, %eax
 2193      00
 307:mathtest.c    **** }
 2195              	.LM238:
 2196 14d0 C9       		leave
 2197              		.cfi_def_cfa 7, 8
 2198 14d1 C3       		ret
 2199              		.cfi_endproc
 2200              	.LFE20:
 2205              	.Lscope14:
 2207              		.stabd	78,0,0
 2208              		.local	m.2342
 2209              		.comm	m.2342,8,8
 2211              		.section	.rodata
 2212 01bd 000000   		.align 8
 2213              	.LC25:
 2214 01c0 CDCCCCCC 		.long	3435973837
 2215 01c4 CCCCEC3F 		.long	1072483532
 2216              		.align 8
 2217              	.LC26:
 2218 01c8 00000000 		.long	0
 2219 01cc 0000F03F 		.long	1072693248
 2220              		.align 8
 2221              	.LC27:
 2222 01d0 66666666 		.long	1717986918
 2223 01d4 6666F63F 		.long	1073112678
 2224              		.align 8
 2225              	.LC28:
 2226 01d8 00000000 		.long	0
 2227 01dc 0000F83F 		.long	1073217536
 2228              		.align 8
 2229              	.LC29:
 2230 01e0 9A999999 		.long	2576980378
 2231 01e4 9999F93F 		.long	1073322393
 2232              		.align 8
 2233              	.LC30:
 2234 01e8 66666666 		.long	1717986918
 2235 01ec 6666FE3F 		.long	1073636966
 2236              		.align 8
 2237              	.LC31:
 2238 01f0 00000000 		.long	0
 2239 01f4 00000040 		.long	1073741824
 2240              		.align 8
 2241              	.LC32:
 2242 01f8 33333333 		.long	858993459
 2243 01fc 33330340 		.long	1073951539
 2244              		.align 8
 2245              	.LC33:
 2246 0200 00000000 		.long	0
 2247 0204 00000440 		.long	1074003968
 2248              		.align 8
 2249              	.LC34:
 2250 0208 00000000 		.long	0
 2251 020c 00000840 		.long	1074266112
 2252              		.align 8
 2253              	.LC35:
 2254 0210 00000000 		.long	0
 2255 0214 00001040 		.long	1074790400
 2256              		.align 8
 2257              	.LC36:
 2258 0218 CDCCCCCC 		.long	3435973837
 2259 021c CCCCECBF 		.long	-1075000116
 2260              		.align 8
 2261              	.LC37:
 2262 0220 00000000 		.long	0
 2263 0224 0000F0BF 		.long	-1074790400
 2264              		.align 8
 2265              	.LC38:
 2266 0228 66666666 		.long	1717986918
 2267 022c 6666F6BF 		.long	-1074370970
 2268              		.align 8
 2269              	.LC39:
 2270 0230 00000000 		.long	0
 2271 0234 0000F8BF 		.long	-1074266112
 2272              		.align 8
 2273              	.LC40:
 2274 0238 9A999999 		.long	2576980378
 2275 023c 9999F9BF 		.long	-1074161255
 2276              		.align 8
 2277              	.LC41:
 2278 0240 66666666 		.long	1717986918
 2279 0244 6666FEBF 		.long	-1073846682
 2280              		.align 8
 2281              	.LC42:
 2282 0248 00000000 		.long	0
 2283 024c 000000C0 		.long	-1073741824
 2284              		.align 8
 2285              	.LC43:
 2286 0250 33333333 		.long	858993459
 2287 0254 333303C0 		.long	-1073532109
 2288              		.align 8
 2289              	.LC44:
 2290 0258 00000000 		.long	0
 2291 025c 000004C0 		.long	-1073479680
 2292              		.align 8
 2293              	.LC45:
 2294 0260 00000000 		.long	0
 2295 0264 000008C0 		.long	-1073217536
 2296              		.align 8
 2297              	.LC46:
 2298 0268 00000000 		.long	0
 2299 026c 000010C0 		.long	-1072693248
 2300              		.align 8
 2301              	.LC48:
 2302 0270 9A999999 		.long	2576980378
 2303 0274 9999B93F 		.long	1069128089
 2304              		.align 8
 2305              	.LC49:
 2306 0278 70732D38 		.long	942502768
 2307 027c 52C1F03F 		.long	1072742738
 2308              		.align 8
 2309              	.LC50:
 2310 0280 282D4454 		.long	1413754152
 2311 0284 FB21F93F 		.long	1073291771
 2312              		.align 8
 2313              	.LC51:
 2314 0288 112D4454 		.long	1413754129
 2315 028c FB210940 		.long	1074340347
 2316              		.align 8
 2317              	.LC52:
 2318 0290 70732D38 		.long	942502768
 2319 0294 52C1F0BF 		.long	-1074740910
 2320              		.align 8
 2321              	.LC53:
 2322 0298 282D4454 		.long	1413754152
 2323 029c FB21F9BF 		.long	-1074191877
 2324              		.align 8
 2325              	.LC54:
 2326 02a0 112D4454 		.long	1413754129
 2327 02a4 FB2109C0 		.long	-1073143301
 2328              		.text
 2330              	.Letext0:
 2331              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 2332              		.section	.note.GNU-stack,"",@progbits
 2333              		.section	.note.gnu.property,"a"
 2334              		.align 8
 2335 0000 04000000 		.long	 1f - 0f
 2336 0004 10000000 		.long	 4f - 1f
 2337 0008 05000000 		.long	 5
 2338              	0:
 2339 000c 474E5500 		.string	 "GNU"
 2340              	1:
 2341              		.align 8
 2342 0010 020000C0 		.long	 0xc0000002
 2343 0014 04000000 		.long	 3f - 2f
 2344              	2:
 2345 0018 03000000 		.long	 0x3
 2346              	3:
 2347 001c 00000000 		.align 8
 2348              	4:
