   1              		.file	"SignalTest.c"
   4              		.text
   5              	.Ltext0:
  76              		.local	SignalTest_result
  77              		.comm	SignalTest_result,8,8
  79              		.local	SignalTest_rider
  80              		.comm	SignalTest_rider,24,16
  86              	SignalTest_ws:
  87              		.stabd	46,0,0
   1:SignalTest.c  **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:SignalTest.c  **** 
   3:SignalTest.c  **** #define SHORTINT INT8
   4:SignalTest.c  **** #define INTEGER  INT16
   5:SignalTest.c  **** #define LONGINT  INT32
   6:SignalTest.c  **** #define SET      UINT32
   7:SignalTest.c  **** 
   8:SignalTest.c  **** #include "SYSTEM.h"
   9:SignalTest.c  **** #include "Console.h"
  10:SignalTest.c  **** #include "Files.h"
  11:SignalTest.c  **** #include "Modules.h"
  12:SignalTest.c  **** #include "Platform.h"
  13:SignalTest.c  **** 
  14:SignalTest.c  **** 
  15:SignalTest.c  **** static Files_File SignalTest_result;
  16:SignalTest.c  **** static Files_Rider SignalTest_rider;
  17:SignalTest.c  **** 
  18:SignalTest.c  **** 
  19:SignalTest.c  **** static void SignalTest_Take5 (INT16 i);
  20:SignalTest.c  **** static void SignalTest_handle (INT32 signal);
  21:SignalTest.c  **** static void SignalTest_wi (INT32 i);
  22:SignalTest.c  **** static void SignalTest_wl (void);
  23:SignalTest.c  **** static void SignalTest_ws (CHAR *s, ADDRESS s__len);
  24:SignalTest.c  **** 
  25:SignalTest.c  **** 
  26:SignalTest.c  **** static void SignalTest_ws (CHAR *s, ADDRESS s__len)
  27:SignalTest.c  **** {
  89              	.LM0:
  90              	.LFBB1:
  91              	.LFB7:
  92              		.cfi_startproc
  93 0000 F30F1EFA 		endbr64
  94 0004 55       		pushq	%rbp
  95              		.cfi_def_cfa_offset 16
  96              		.cfi_offset 6, -16
  97 0005 4889E5   		movq	%rsp, %rbp
  98              		.cfi_def_cfa_register 6
  99 0008 4883EC20 		subq	$32, %rsp
 100 000c 48897DE8 		movq	%rdi, -24(%rbp)
 101 0010 488975E0 		movq	%rsi, -32(%rbp)
 103              	.LM1:
 104 0014 64488B04 		movq	%fs:40, %rax
 104      25280000 
 104      00
 105 001d 488945F8 		movq	%rax, -8(%rbp)
 106 0021 31C0     		xorl	%eax, %eax
  28:SignalTest.c  **** 	INT16 i;
  29:SignalTest.c  **** 	__DUP(s, s__len, CHAR);
 108              	.LM2:
 109 0023 488B4DE0 		movq	-32(%rbp), %rcx
 110 0027 488B45E0 		movq	-32(%rbp), %rax
 111 002b 488D5008 		leaq	8(%rax), %rdx
 112 002f B8100000 		movl	$16, %eax
 112      00
 113 0034 4883E801 		subq	$1, %rax
 114 0038 4801D0   		addq	%rdx, %rax
 115 003b BE100000 		movl	$16, %esi
 115      00
 116 0040 BA000000 		movl	$0, %edx
 116      00
 117 0045 48F7F6   		divq	%rsi
 118 0048 486BC010 		imulq	$16, %rax, %rax
 119 004c 4889C2   		movq	%rax, %rdx
 120 004f 4881E200 		andq	$-4096, %rdx
 120      F0FFFF
 121 0056 4889E6   		movq	%rsp, %rsi
 122 0059 4829D6   		subq	%rdx, %rsi
 123 005c 4889F2   		movq	%rsi, %rdx
 124              	.L2:
 125 005f 4839D4   		cmpq	%rdx, %rsp
 126 0062 7412     		je	.L3
 127 0064 4881EC00 		subq	$4096, %rsp
 127      100000
 128 006b 48838C24 		orq	$0, 4088(%rsp)
 128      F80F0000 
 128      00
 129 0074 EBE9     		jmp	.L2
 130              	.L3:
 131 0076 4889C2   		movq	%rax, %rdx
 132 0079 81E2FF0F 		andl	$4095, %edx
 132      0000
 133 007f 4829D4   		subq	%rdx, %rsp
 134 0082 4889C2   		movq	%rax, %rdx
 135 0085 81E2FF0F 		andl	$4095, %edx
 135      0000
 136 008b 4885D2   		testq	%rdx, %rdx
 137 008e 7410     		je	.L4
 138 0090 25FF0F00 		andl	$4095, %eax
 138      00
 139 0095 4883E808 		subq	$8, %rax
 140 0099 4801E0   		addq	%rsp, %rax
 141 009c 48830800 		orq	$0, (%rax)
 142              	.L4:
 143 00a0 4889E0   		movq	%rsp, %rax
 144 00a3 4883C00F 		addq	$15, %rax
 145 00a7 48C1E804 		shrq	$4, %rax
 146 00ab 48C1E004 		salq	$4, %rax
 147 00af 4889C7   		movq	%rax, %rdi
 148 00b2 488B45E8 		movq	-24(%rbp), %rax
 149 00b6 4889CA   		movq	%rcx, %rdx
 150 00b9 4889C6   		movq	%rax, %rsi
 151 00bc E8000000 		call	memcpy@PLT
 151      00
 152 00c1 488945E8 		movq	%rax, -24(%rbp)
  30:SignalTest.c  **** 	i = 0;
 154              	.LM3:
 155 00c5 66C745F6 		movw	$0, -10(%rbp)
 155      0000
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 157              	.LM4:
 158 00cb EB52     		jmp	.L5
 159              	.L11:
  32:SignalTest.c  **** 		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(i, s__len)]);
 161              	.LM5:
 162 00cd 480FBF45 		movswq	-10(%rbp), %rax
 162      F6
 163 00d2 483945E0 		cmpq	%rax, -32(%rbp)
 164 00d6 7E07     		jle	.L6
 166              	.LM6:
 167 00d8 480FBF45 		movswq	-10(%rbp), %rax
 167      F6
 168 00dd EB0F     		jmp	.L7
 169              	.L6:
 171              	.LM7:
 172 00df BFFEFFFF 		movl	$-2, %edi
 172      FF
 173 00e4 E8000000 		call	Modules_Halt@PLT
 173      00
 174 00e9 B8000000 		movl	$0, %eax
 174      00
 175              	.L7:
 177              	.LM8:
 178 00ee 488B55E8 		movq	-24(%rbp), %rdx
 179 00f2 4801D0   		addq	%rdx, %rax
 180 00f5 0FB600   		movzbl	(%rax), %eax
 182              	.LM9:
 183 00f8 0FBED0   		movsbl	%al, %edx
 184 00fb 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 184      000000
 185 0102 488B00   		movq	(%rax), %rax
 186 0105 4889C6   		movq	%rax, %rsi
 187 0108 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 187      000000
 188 010f E8000000 		call	Files_Write@PLT
 188      00
  33:SignalTest.c  **** 		i += 1;
 190              	.LM10:
 191 0114 0FB745F6 		movzwl	-10(%rbp), %eax
 192 0118 83C001   		addl	$1, %eax
 193 011b 668945F6 		movw	%ax, -10(%rbp)
 194              	.L5:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 196              	.LM11:
 197 011f 480FBF45 		movswq	-10(%rbp), %rax
 197      F6
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 199              	.LM12:
 200 0124 483945E0 		cmpq	%rax, -32(%rbp)
 201 0128 7E33     		jle	.L13
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 203              	.LM13:
 204 012a 480FBF45 		movswq	-10(%rbp), %rax
 204      F6
 205 012f 483945E0 		cmpq	%rax, -32(%rbp)
 206 0133 7E07     		jle	.L9
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 208              	.LM14:
 209 0135 480FBF45 		movswq	-10(%rbp), %rax
 209      F6
 210 013a EB0F     		jmp	.L10
 211              	.L9:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 213              	.LM15:
 214 013c BFFEFFFF 		movl	$-2, %edi
 214      FF
 215 0141 E8000000 		call	Modules_Halt@PLT
 215      00
 216 0146 B8000000 		movl	$0, %eax
 216      00
 217              	.L10:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 219              	.LM16:
 220 014b 488B55E8 		movq	-24(%rbp), %rdx
 221 014f 4801D0   		addq	%rdx, %rax
 222 0152 0FB600   		movzbl	(%rax), %eax
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 224              	.LM17:
 225 0155 84C0     		testb	%al, %al
 226 0157 0F8570FF 		jne	.L11
 226      FFFF
 227              	.L13:
  34:SignalTest.c  **** 	}
  35:SignalTest.c  **** 	__DEL(s);
  36:SignalTest.c  **** }
 229              	.LM18:
 230 015d 90       		nop
 231 015e 488B45F8 		movq	-8(%rbp), %rax
 232 0162 64483304 		xorq	%fs:40, %rax
 232      25280000 
 232      00
 233 016b 7405     		je	.L12
 234 016d E8000000 		call	__stack_chk_fail@PLT
 234      00
 235              	.L12:
 236 0172 C9       		leave
 237              		.cfi_def_cfa 7, 8
 238 0173 C3       		ret
 239              		.cfi_endproc
 240              	.LFE7:
 245              	.Lscope1:
 247              		.stabd	78,0,0
 250              	SignalTest_wl:
 251              		.stabd	46,0,0
  37:SignalTest.c  **** 
  38:SignalTest.c  **** static void SignalTest_wl (void)
  39:SignalTest.c  **** {
 253              	.LM19:
 254              	.LFBB2:
 255              	.LFB8:
 256              		.cfi_startproc
 257 0174 F30F1EFA 		endbr64
 258 0178 55       		pushq	%rbp
 259              		.cfi_def_cfa_offset 16
 260              		.cfi_offset 6, -16
 261 0179 4889E5   		movq	%rsp, %rbp
 262              		.cfi_def_cfa_register 6
  40:SignalTest.c  **** 	Files_Write(&SignalTest_rider, Files_Rider__typ, 0x0a);
 264              	.LM20:
 265 017c 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 265      000000
 266 0183 488B00   		movq	(%rax), %rax
 267 0186 BA0A0000 		movl	$10, %edx
 267      00
 268 018b 4889C6   		movq	%rax, %rsi
 269 018e 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 269      000000
 270 0195 E8000000 		call	Files_Write@PLT
 270      00
  41:SignalTest.c  **** }
 272              	.LM21:
 273 019a 90       		nop
 274 019b 5D       		popq	%rbp
 275              		.cfi_def_cfa 7, 8
 276 019c C3       		ret
 277              		.cfi_endproc
 278              	.LFE8:
 280              	.Lscope2:
 282              		.stabd	78,0,0
 286              	SignalTest_wi:
 287              		.stabd	46,0,0
  42:SignalTest.c  **** 
  43:SignalTest.c  **** static void SignalTest_wi (INT32 i)
  44:SignalTest.c  **** {
 289              	.LM22:
 290              	.LFBB3:
 291              	.LFB9:
 292              		.cfi_startproc
 293 019d F30F1EFA 		endbr64
 294 01a1 55       		pushq	%rbp
 295              		.cfi_def_cfa_offset 16
 296              		.cfi_offset 6, -16
 297 01a2 4889E5   		movq	%rsp, %rbp
 298              		.cfi_def_cfa_register 6
 299 01a5 53       		pushq	%rbx
 300 01a6 4883EC58 		subq	$88, %rsp
 301              		.cfi_offset 3, -24
 302 01aa 897DAC   		movl	%edi, -84(%rbp)
 304              	.LM23:
 305 01ad 64488B04 		movq	%fs:40, %rax
 305      25280000 
 305      00
 306 01b6 488945E8 		movq	%rax, -24(%rbp)
 307 01ba 31C0     		xorl	%eax, %eax
  45:SignalTest.c  **** 	CHAR s[30];
  46:SignalTest.c  **** 	INT16 j;
  47:SignalTest.c  **** 	j = 0;
 309              	.LM24:
 310 01bc 66C745BE 		movw	$0, -66(%rbp)
 310      0000
  48:SignalTest.c  **** 	if (i < 0) {
 312              	.LM25:
 313 01c2 837DAC00 		cmpl	$0, -84(%rbp)
 314 01c6 790F     		jns	.L16
  49:SignalTest.c  **** 		s[0] = '-';
 316              	.LM26:
 317 01c8 C645C02D 		movb	$45, -64(%rbp)
  50:SignalTest.c  **** 		j += 1;
 319              	.LM27:
 320 01cc 0FB745BE 		movzwl	-66(%rbp), %eax
 321 01d0 83C001   		addl	$1, %eax
 322 01d3 668945BE 		movw	%ax, -66(%rbp)
 323              	.L16:
  51:SignalTest.c  **** 	}
  52:SignalTest.c  **** 	s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 325              	.LM28:
 326 01d7 837DAC00 		cmpl	$0, -84(%rbp)
 327 01db 7E31     		jle	.L17
 329              	.LM29:
 330 01dd 8B4DAC   		movl	-84(%rbp), %ecx
 331 01e0 4863C1   		movslq	%ecx, %rax
 332 01e3 4869C067 		imulq	$1717986919, %rax, %rax
 332      666666
 333 01ea 48C1E820 		shrq	$32, %rax
 334 01ee 89C2     		movl	%eax, %edx
 335 01f0 C1FA02   		sarl	$2, %edx
 336 01f3 89C8     		movl	%ecx, %eax
 337 01f5 C1F81F   		sarl	$31, %eax
 338 01f8 29C2     		subl	%eax, %edx
 339 01fa 89D0     		movl	%edx, %eax
 340 01fc C1E002   		sall	$2, %eax
 341 01ff 01D0     		addl	%edx, %eax
 342 0201 01C0     		addl	%eax, %eax
 343 0203 29C1     		subl	%eax, %ecx
 344 0205 89CA     		movl	%ecx, %edx
 346              	.LM30:
 347 0207 89D0     		movl	%edx, %eax
 349              	.LM31:
 350 0209 8D5830   		leal	48(%rax), %ebx
 351 020c EB15     		jmp	.L18
 352              	.L17:
 354              	.LM32:
 355 020e 8B45AC   		movl	-84(%rbp), %eax
 356 0211 4898     		cltq
 357 0213 BE0A0000 		movl	$10, %esi
 357      00
 358 0218 4889C7   		movq	%rax, %rdi
 359 021b E8000000 		call	SYSTEM_MOD@PLT
 359      00
 361              	.LM33:
 362 0220 8D5830   		leal	48(%rax), %ebx
 363              	.L18:
 365              	.LM34:
 366 0223 66837DBE 		cmpw	$29, -66(%rbp)
 366      1D
 367 0228 7F06     		jg	.L19
 369              	.LM35:
 370 022a 0FBF45BE 		movswl	-66(%rbp), %eax
 371 022e EB0F     		jmp	.L20
 372              	.L19:
 374              	.LM36:
 375 0230 BFFEFFFF 		movl	$-2, %edi
 375      FF
 376 0235 E8000000 		call	Modules_Halt@PLT
 376      00
 377 023a B8000000 		movl	$0, %eax
 377      00
 378              	.L20:
 380              	.LM37:
 381 023f 4898     		cltq
 382 0241 885C05C0 		movb	%bl, -64(%rbp,%rax)
  53:SignalTest.c  **** 	j += 1;
 384              	.LM38:
 385 0245 0FB745BE 		movzwl	-66(%rbp), %eax
 386 0249 83C001   		addl	$1, %eax
 387 024c 668945BE 		movw	%ax, -66(%rbp)
  54:SignalTest.c  **** 	i = __DIV(i, 10);
 389              	.LM39:
 390 0250 837DAC00 		cmpl	$0, -84(%rbp)
 391 0254 7E1D     		jle	.L21
 393              	.LM40:
 394 0256 8B45AC   		movl	-84(%rbp), %eax
 395 0259 4863D0   		movslq	%eax, %rdx
 396 025c 4869D267 		imulq	$1717986919, %rdx, %rdx
 396      666666
 397 0263 48C1EA20 		shrq	$32, %rdx
 398 0267 C1FA02   		sarl	$2, %edx
 399 026a C1F81F   		sarl	$31, %eax
 400 026d 29C2     		subl	%eax, %edx
 401 026f 89D0     		movl	%edx, %eax
 402 0271 EB12     		jmp	.L22
 403              	.L21:
 405              	.LM41:
 406 0273 8B45AC   		movl	-84(%rbp), %eax
 407 0276 4898     		cltq
 408 0278 BE0A0000 		movl	$10, %esi
 408      00
 409 027d 4889C7   		movq	%rax, %rdi
 410 0280 E8000000 		call	SYSTEM_DIV@PLT
 410      00
 411              	.L22:
 413              	.LM42:
 414 0285 8945AC   		movl	%eax, -84(%rbp)
  55:SignalTest.c  **** 	while (i > 0) {
 416              	.LM43:
 417 0288 E9B10000 		jmp	.L23
 417      00
 418              	.L30:
  56:SignalTest.c  **** 		s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 420              	.LM44:
 421 028d 837DAC00 		cmpl	$0, -84(%rbp)
 422 0291 7E31     		jle	.L24
 424              	.LM45:
 425 0293 8B4DAC   		movl	-84(%rbp), %ecx
 426 0296 4863C1   		movslq	%ecx, %rax
 427 0299 4869C067 		imulq	$1717986919, %rax, %rax
 427      666666
 428 02a0 48C1E820 		shrq	$32, %rax
 429 02a4 89C2     		movl	%eax, %edx
 430 02a6 C1FA02   		sarl	$2, %edx
 431 02a9 89C8     		movl	%ecx, %eax
 432 02ab C1F81F   		sarl	$31, %eax
 433 02ae 29C2     		subl	%eax, %edx
 434 02b0 89D0     		movl	%edx, %eax
 435 02b2 C1E002   		sall	$2, %eax
 436 02b5 01D0     		addl	%edx, %eax
 437 02b7 01C0     		addl	%eax, %eax
 438 02b9 29C1     		subl	%eax, %ecx
 439 02bb 89CA     		movl	%ecx, %edx
 441              	.LM46:
 442 02bd 89D0     		movl	%edx, %eax
 444              	.LM47:
 445 02bf 8D5830   		leal	48(%rax), %ebx
 446 02c2 EB15     		jmp	.L25
 447              	.L24:
 449              	.LM48:
 450 02c4 8B45AC   		movl	-84(%rbp), %eax
 451 02c7 4898     		cltq
 452 02c9 BE0A0000 		movl	$10, %esi
 452      00
 453 02ce 4889C7   		movq	%rax, %rdi
 454 02d1 E8000000 		call	SYSTEM_MOD@PLT
 454      00
 456              	.LM49:
 457 02d6 8D5830   		leal	48(%rax), %ebx
 458              	.L25:
 460              	.LM50:
 461 02d9 66837DBE 		cmpw	$29, -66(%rbp)
 461      1D
 462 02de 7F06     		jg	.L26
 464              	.LM51:
 465 02e0 0FBF45BE 		movswl	-66(%rbp), %eax
 466 02e4 EB0F     		jmp	.L27
 467              	.L26:
 469              	.LM52:
 470 02e6 BFFEFFFF 		movl	$-2, %edi
 470      FF
 471 02eb E8000000 		call	Modules_Halt@PLT
 471      00
 472 02f0 B8000000 		movl	$0, %eax
 472      00
 473              	.L27:
 475              	.LM53:
 476 02f5 4898     		cltq
 477 02f7 885C05C0 		movb	%bl, -64(%rbp,%rax)
  57:SignalTest.c  **** 		j += 1;
 479              	.LM54:
 480 02fb 0FB745BE 		movzwl	-66(%rbp), %eax
 481 02ff 83C001   		addl	$1, %eax
 482 0302 668945BE 		movw	%ax, -66(%rbp)
  58:SignalTest.c  **** 		i = __DIV(i, 10);
 484              	.LM55:
 485 0306 837DAC00 		cmpl	$0, -84(%rbp)
 486 030a 7E1D     		jle	.L28
 488              	.LM56:
 489 030c 8B45AC   		movl	-84(%rbp), %eax
 490 030f 4863D0   		movslq	%eax, %rdx
 491 0312 4869D267 		imulq	$1717986919, %rdx, %rdx
 491      666666
 492 0319 48C1EA20 		shrq	$32, %rdx
 493 031d C1FA02   		sarl	$2, %edx
 494 0320 C1F81F   		sarl	$31, %eax
 495 0323 29C2     		subl	%eax, %edx
 496 0325 89D0     		movl	%edx, %eax
 497 0327 EB12     		jmp	.L29
 498              	.L28:
 500              	.LM57:
 501 0329 8B45AC   		movl	-84(%rbp), %eax
 502 032c 4898     		cltq
 503 032e BE0A0000 		movl	$10, %esi
 503      00
 504 0333 4889C7   		movq	%rax, %rdi
 505 0336 E8000000 		call	SYSTEM_DIV@PLT
 505      00
 506              	.L29:
 508              	.LM58:
 509 033b 8945AC   		movl	%eax, -84(%rbp)
 510              	.L23:
  55:SignalTest.c  **** 		s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 512              	.LM59:
 513 033e 837DAC00 		cmpl	$0, -84(%rbp)
 514 0342 0F8F45FF 		jg	.L30
 514      FFFF
  59:SignalTest.c  **** 	}
  60:SignalTest.c  **** 	while (j > 0) {
 516              	.LM60:
 517 0348 EB4A     		jmp	.L31
 518              	.L34:
  61:SignalTest.c  **** 		j -= 1;
 520              	.LM61:
 521 034a 0FB745BE 		movzwl	-66(%rbp), %eax
 522 034e 83E801   		subl	$1, %eax
 523 0351 668945BE 		movw	%ax, -66(%rbp)
  62:SignalTest.c  **** 		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(j, 30)]);
 525              	.LM62:
 526 0355 66837DBE 		cmpw	$29, -66(%rbp)
 526      1D
 527 035a 7F06     		jg	.L32
 529              	.LM63:
 530 035c 0FBF45BE 		movswl	-66(%rbp), %eax
 531 0360 EB0F     		jmp	.L33
 532              	.L32:
 534              	.LM64:
 535 0362 BFFEFFFF 		movl	$-2, %edi
 535      FF
 536 0367 E8000000 		call	Modules_Halt@PLT
 536      00
 537 036c B8000000 		movl	$0, %eax
 537      00
 538              	.L33:
 540              	.LM65:
 541 0371 4898     		cltq
 542 0373 0FB64405 		movzbl	-64(%rbp,%rax), %eax
 542      C0
 544              	.LM66:
 545 0378 0FBED0   		movsbl	%al, %edx
 546 037b 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 546      000000
 547 0382 488B00   		movq	(%rax), %rax
 548 0385 4889C6   		movq	%rax, %rsi
 549 0388 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 549      000000
 550 038f E8000000 		call	Files_Write@PLT
 550      00
 551              	.L31:
  60:SignalTest.c  **** 		j -= 1;
 553              	.LM67:
 554 0394 66837DBE 		cmpw	$0, -66(%rbp)
 554      00
 555 0399 7FAF     		jg	.L34
  63:SignalTest.c  **** 	}
  64:SignalTest.c  **** }
 557              	.LM68:
 558 039b 90       		nop
 559 039c 488B45E8 		movq	-24(%rbp), %rax
 560 03a0 64483304 		xorq	%fs:40, %rax
 560      25280000 
 560      00
 561 03a9 7405     		je	.L35
 562 03ab E8000000 		call	__stack_chk_fail@PLT
 562      00
 563              	.L35:
 564 03b0 4883C458 		addq	$88, %rsp
 565 03b4 5B       		popq	%rbx
 566 03b5 5D       		popq	%rbp
 567              		.cfi_def_cfa 7, 8
 568 03b6 C3       		ret
 569              		.cfi_endproc
 570              	.LFE9:
 576              	.Lscope3:
 578              		.stabd	78,0,0
 579              		.section	.rodata
 580              	.LC0:
 581 0000 5369676E 		.string	"Signal: "
 581      616C3A20 
 581      00
 582              	.LC1:
 583 0009 5369676E 		.string	"Signal "
 583      616C2000 
 584              		.text
 588              	SignalTest_handle:
 589              		.stabd	46,0,0
  65:SignalTest.c  **** 
  66:SignalTest.c  **** static void SignalTest_handle (INT32 signal)
  67:SignalTest.c  **** {
 591              	.LM69:
 592              	.LFBB4:
 593              	.LFB10:
 594              		.cfi_startproc
 595 03b7 F30F1EFA 		endbr64
 596 03bb 55       		pushq	%rbp
 597              		.cfi_def_cfa_offset 16
 598              		.cfi_offset 6, -16
 599 03bc 4889E5   		movq	%rsp, %rbp
 600              		.cfi_def_cfa_register 6
 601 03bf 4883EC10 		subq	$16, %rsp
 602 03c3 897DFC   		movl	%edi, -4(%rbp)
  68:SignalTest.c  **** 	Console_Ln();
 604              	.LM70:
 605 03c6 E8000000 		call	Console_Ln@PLT
 605      00
  69:SignalTest.c  **** 	Console_String((CHAR*)"Signal: ", 9);
 607              	.LM71:
 608 03cb BE090000 		movl	$9, %esi
 608      00
 609 03d0 488D3D00 		leaq	.LC0(%rip), %rdi
 609      000000
 610 03d7 E8000000 		call	Console_String@PLT
 610      00
  70:SignalTest.c  **** 	Console_Int(signal, 1);
 612              	.LM72:
 613 03dc 8B45FC   		movl	-4(%rbp), %eax
 614 03df 4898     		cltq
 615 03e1 BE010000 		movl	$1, %esi
 615      00
 616 03e6 4889C7   		movq	%rax, %rdi
 617 03e9 E8000000 		call	Console_Int@PLT
 617      00
  71:SignalTest.c  **** 	Console_Ln();
 619              	.LM73:
 620 03ee E8000000 		call	Console_Ln@PLT
 620      00
  72:SignalTest.c  **** 	SignalTest_ws((CHAR*)"Signal ", 8);
 622              	.LM74:
 623 03f3 BE080000 		movl	$8, %esi
 623      00
 624 03f8 488D3D00 		leaq	.LC1(%rip), %rdi
 624      000000
 625 03ff E8FCFBFF 		call	SignalTest_ws
 625      FF
  73:SignalTest.c  **** 	SignalTest_wi(signal);
 627              	.LM75:
 628 0404 8B45FC   		movl	-4(%rbp), %eax
 629 0407 89C7     		movl	%eax, %edi
 630 0409 E88FFDFF 		call	SignalTest_wi
 630      FF
  74:SignalTest.c  **** 	SignalTest_wl();
 632              	.LM76:
 633 040e E861FDFF 		call	SignalTest_wl
 633      FF
  75:SignalTest.c  **** }
 635              	.LM77:
 636 0413 90       		nop
 637 0414 C9       		leave
 638              		.cfi_def_cfa 7, 8
 639 0415 C3       		ret
 640              		.cfi_endproc
 641              	.LFE10:
 643              	.Lscope4:
 645              		.stabd	78,0,0
 649              	SignalTest_Take5:
 650              		.stabd	46,0,0
  76:SignalTest.c  **** 
  77:SignalTest.c  **** static void SignalTest_Take5 (INT16 i)
  78:SignalTest.c  **** {
 652              	.LM78:
 653              	.LFBB5:
 654              	.LFB11:
 655              		.cfi_startproc
 656 0416 F30F1EFA 		endbr64
 657 041a 55       		pushq	%rbp
 658              		.cfi_def_cfa_offset 16
 659              		.cfi_offset 6, -16
 660 041b 4889E5   		movq	%rsp, %rbp
 661              		.cfi_def_cfa_register 6
 662 041e 4883EC10 		subq	$16, %rsp
 663 0422 89F8     		movl	%edi, %eax
 664 0424 668945FC 		movw	%ax, -4(%rbp)
  79:SignalTest.c  **** 	while (i > 0) {
 666              	.LM79:
 667 0428 EB2C     		jmp	.L38
 668              	.L39:
  80:SignalTest.c  **** 		Console_Int(i, 2);
 670              	.LM80:
 671 042a 480FBF45 		movswq	-4(%rbp), %rax
 671      FC
 672 042f BE020000 		movl	$2, %esi
 672      00
 673 0434 4889C7   		movq	%rax, %rdi
 674 0437 E8000000 		call	Console_Int@PLT
 674      00
  81:SignalTest.c  **** 		Console_Flush();
 676              	.LM81:
 677 043c E8000000 		call	Console_Flush@PLT
 677      00
  82:SignalTest.c  **** 		Platform_Delay(1000);
 679              	.LM82:
 680 0441 BFE80300 		movl	$1000, %edi
 680      00
 681 0446 E8000000 		call	Platform_Delay@PLT
 681      00
  83:SignalTest.c  **** 		i -= 1;
 683              	.LM83:
 684 044b 0FB745FC 		movzwl	-4(%rbp), %eax
 685 044f 83E801   		subl	$1, %eax
 686 0452 668945FC 		movw	%ax, -4(%rbp)
 687              	.L38:
  79:SignalTest.c  **** 		Console_Int(i, 2);
 689              	.LM84:
 690 0456 66837DFC 		cmpw	$0, -4(%rbp)
 690      00
 691 045b 7FCD     		jg	.L39
  84:SignalTest.c  **** 	}
  85:SignalTest.c  **** 	Console_Ln();
 693              	.LM85:
 694 045d E8000000 		call	Console_Ln@PLT
 694      00
  86:SignalTest.c  **** }
 696              	.LM86:
 697 0462 90       		nop
 698 0463 C9       		leave
 699              		.cfi_def_cfa 7, 8
 700 0464 C3       		ret
 701              		.cfi_endproc
 702              	.LFE11:
 704              	.Lscope5:
 706              		.stabd	78,0,0
 710              	EnumPtrs:
 711              		.stabd	46,0,0
  87:SignalTest.c  **** 
  88:SignalTest.c  **** static void EnumPtrs(void (*P)(void*))
  89:SignalTest.c  **** {
 713              	.LM87:
 714              	.LFBB6:
 715              	.LFB12:
 716              		.cfi_startproc
 717 0465 F30F1EFA 		endbr64
 718 0469 55       		pushq	%rbp
 719              		.cfi_def_cfa_offset 16
 720              		.cfi_offset 6, -16
 721 046a 4889E5   		movq	%rsp, %rbp
 722              		.cfi_def_cfa_register 6
 723 046d 4883EC10 		subq	$16, %rsp
 724 0471 48897DF8 		movq	%rdi, -8(%rbp)
  90:SignalTest.c  **** 	P(SignalTest_result);
 726              	.LM88:
 727 0475 488B0500 		movq	SignalTest_result(%rip), %rax
 727      000000
 728 047c 488B55F8 		movq	-8(%rbp), %rdx
 729 0480 4889C7   		movq	%rax, %rdi
 730 0483 FFD2     		call	*%rdx
  91:SignalTest.c  **** 	__ENUMR(&SignalTest_rider, Files_Rider__typ, 24, 1, P);
 732              	.LM89:
 733 0485 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 733      000000
 734 048c 488B00   		movq	(%rax), %rax
 735 048f 488B55F8 		movq	-8(%rbp), %rdx
 736 0493 4989D0   		movq	%rdx, %r8
 737 0496 B9010000 		movl	$1, %ecx
 737      00
 738 049b BA180000 		movl	$24, %edx
 738      00
 739 04a0 4889C6   		movq	%rax, %rsi
 740 04a3 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 740      000000
 741 04aa E8000000 		call	SYSTEM_ENUMR@PLT
 741      00
  92:SignalTest.c  **** }
 743              	.LM90:
 744 04af 90       		nop
 745 04b0 C9       		leave
 746              		.cfi_def_cfa 7, 8
 747 04b1 C3       		ret
 748              		.cfi_endproc
 749              	.LFE12:
 751              	.Lscope6:
 753              		.stabd	78,0,0
 754              		.section	.rodata
 755              	.LC2:
 756 0011 5369676E 		.string	"SignalTest"
 756      616C5465 
 756      737400
 757              	.LC3:
 758 001c 72657375 		.string	"result"
 758      6C7400
 759              		.text
 763              		.globl	main
 765              	main:
 766              		.stabd	46,0,0
  93:SignalTest.c  **** 
  94:SignalTest.c  **** 
  95:SignalTest.c  **** export int main(int argc, char **argv)
  96:SignalTest.c  **** {
 768              	.LM91:
 769              	.LFBB7:
 770              	.LFB13:
 771              		.cfi_startproc
 772 04b2 F30F1EFA 		endbr64
 773 04b6 55       		pushq	%rbp
 774              		.cfi_def_cfa_offset 16
 775              		.cfi_offset 6, -16
 776 04b7 4889E5   		movq	%rsp, %rbp
 777              		.cfi_def_cfa_register 6
 778 04ba 4883EC10 		subq	$16, %rsp
 779 04be 897DFC   		movl	%edi, -4(%rbp)
 780 04c1 488975F0 		movq	%rsi, -16(%rbp)
  97:SignalTest.c  **** 	__INIT(argc, argv);
 782              	.LM92:
 783 04c5 488D55F0 		leaq	-16(%rbp), %rdx
 784 04c9 8B45FC   		movl	-4(%rbp), %eax
 785 04cc 4889D6   		movq	%rdx, %rsi
 786 04cf 89C7     		movl	%eax, %edi
 787 04d1 E8000000 		call	Modules_Init@PLT
 787      00
  98:SignalTest.c  **** 	__MODULE_IMPORT(Console);
 789              	.LM93:
 790 04d6 E8000000 		call	Console__init@PLT
 790      00
 791 04db 4889C7   		movq	%rax, %rdi
 792 04de E8000000 		call	Heap_INCREF@PLT
 792      00
  99:SignalTest.c  **** 	__MODULE_IMPORT(Files);
 794              	.LM94:
 795 04e3 E8000000 		call	Files__init@PLT
 795      00
 796 04e8 4889C7   		movq	%rax, %rdi
 797 04eb E8000000 		call	Heap_INCREF@PLT
 797      00
 100:SignalTest.c  **** 	__MODULE_IMPORT(Modules);
 799              	.LM95:
 800 04f0 E8000000 		call	Modules__init@PLT
 800      00
 801 04f5 4889C7   		movq	%rax, %rdi
 802 04f8 E8000000 		call	Heap_INCREF@PLT
 802      00
 101:SignalTest.c  **** 	__MODULE_IMPORT(Platform);
 804              	.LM96:
 805 04fd E8000000 		call	Platform__init@PLT
 805      00
 806 0502 4889C7   		movq	%rax, %rdi
 807 0505 E8000000 		call	Heap_INCREF@PLT
 807      00
 102:SignalTest.c  **** 	__REGMAIN("SignalTest", EnumPtrs);
 809              	.LM97:
 810 050a 488D3554 		leaq	EnumPtrs(%rip), %rsi
 810      FFFFFF
 811 0511 488D3D00 		leaq	.LC2(%rip), %rdi
 811      000000
 812 0518 E8000000 		call	Heap_REGMOD@PLT
 812      00
 813 051d 48890500 		movq	%rax, m.2507(%rip)
 813      000000
 103:SignalTest.c  **** /* BEGIN */
 104:SignalTest.c  **** 	SignalTest_result = Files_New((CHAR*)"result", 7);
 815              	.LM98:
 816 0524 BE070000 		movl	$7, %esi
 816      00
 817 0529 488D3D00 		leaq	.LC3(%rip), %rdi
 817      000000
 818 0530 E8000000 		call	Files_New@PLT
 818      00
 820              	.LM99:
 821 0535 48890500 		movq	%rax, SignalTest_result(%rip)
 821      000000
 105:SignalTest.c  **** 	Files_Set(&SignalTest_rider, Files_Rider__typ, SignalTest_result, 0);
 823              	.LM100:
 824 053c 488B1500 		movq	SignalTest_result(%rip), %rdx
 824      000000
 825 0543 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 825      000000
 826 054a 488B00   		movq	(%rax), %rax
 827 054d B9000000 		movl	$0, %ecx
 827      00
 828 0552 4889C6   		movq	%rax, %rsi
 829 0555 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 829      000000
 830 055c E8000000 		call	Files_Set@PLT
 830      00
 106:SignalTest.c  **** 	if (Modules_ArgCount > 1) {
 832              	.LM101:
 833 0561 488B0500 		movq	Modules_ArgCount@GOTPCREL(%rip), %rax
 833      000000
 834 0568 0FB700   		movzwl	(%rax), %eax
 836              	.LM102:
 837 056b 6683F801 		cmpw	$1, %ax
 838 056f 7E18     		jle	.L42
 107:SignalTest.c  **** 		Platform_SetInterruptHandler(SignalTest_handle);
 840              	.LM103:
 841 0571 488D3D3F 		leaq	SignalTest_handle(%rip), %rdi
 841      FEFFFF
 842 0578 E8000000 		call	Platform_SetInterruptHandler@PLT
 842      00
 108:SignalTest.c  **** 		Platform_SetQuitHandler(SignalTest_handle);
 844              	.LM104:
 845 057d 488D3D33 		leaq	SignalTest_handle(%rip), %rdi
 845      FEFFFF
 846 0584 E8000000 		call	Platform_SetQuitHandler@PLT
 846      00
 847              	.L42:
 109:SignalTest.c  **** 	}
 110:SignalTest.c  **** 	SignalTest_Take5(4);
 849              	.LM105:
 850 0589 BF040000 		movl	$4, %edi
 850      00
 851 058e E883FEFF 		call	SignalTest_Take5
 851      FF
 111:SignalTest.c  **** 	Files_Register(SignalTest_result);
 853              	.LM106:
 854 0593 488B0500 		movq	SignalTest_result(%rip), %rax
 854      000000
 855 059a 4889C7   		movq	%rax, %rdi
 856 059d E8000000 		call	Files_Register@PLT
 856      00
 112:SignalTest.c  **** 	__FINI;
 858              	.LM107:
 859 05a2 E8000000 		call	Heap_FINALL@PLT
 859      00
 860 05a7 B8000000 		movl	$0, %eax
 860      00
 113:SignalTest.c  **** }
 862              	.LM108:
 863 05ac C9       		leave
 864              		.cfi_def_cfa 7, 8
 865 05ad C3       		ret
 866              		.cfi_endproc
 867              	.LFE13:
 872              	.Lscope7:
 874              		.stabd	78,0,0
 875              		.local	m.2507
 876              		.comm	m.2507,8,8
 879              	.Letext0:
 880              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 881              		.section	.note.GNU-stack,"",@progbits
 882              		.section	.note.gnu.property,"a"
 883              		.align 8
 884 0000 04000000 		.long	 1f - 0f
 885 0004 10000000 		.long	 4f - 1f
 886 0008 05000000 		.long	 5
 887              	0:
 888 000c 474E5500 		.string	 "GNU"
 889              	1:
 890              		.align 8
 891 0010 020000C0 		.long	 0xc0000002
 892 0014 04000000 		.long	 3f - 2f
 893              	2:
 894 0018 03000000 		.long	 0x3
 895              	3:
 896 001c 00000000 		.align 8
 897              	4:
