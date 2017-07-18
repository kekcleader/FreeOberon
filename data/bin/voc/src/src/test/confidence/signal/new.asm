   1              		.file	"SignalTest.c"
   4              		.text
   5              	.Ltext0:
  71              		.local	SignalTest_result
  72              		.comm	SignalTest_result,8,8
  73              		.local	SignalTest_rider
  74              		.comm	SignalTest_rider,24,16
  79              	SignalTest_ws:
  80              		.stabd	46,0,0
   1:SignalTest.c  **** /* voc 2.1.0 [2017/07/08] for gcc LP64 on debian xtpam */
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
  82              	.LM0:
  83              	.LFBB1:
  84              	.LFB7:
  85              		.cfi_startproc
  86 0000 55       		pushq	%rbp
  87              		.cfi_def_cfa_offset 16
  88              		.cfi_offset 6, -16
  89 0001 4889E5   		movq	%rsp, %rbp
  90              		.cfi_def_cfa_register 6
  91 0004 4883EC20 		subq	$32, %rsp
  92 0008 48897DE8 		movq	%rdi, -24(%rbp)
  93 000c 488975E0 		movq	%rsi, -32(%rbp)
  28:SignalTest.c  **** 	INT16 i;
  29:SignalTest.c  **** 	__DUP(s, s__len, CHAR);
  95              	.LM1:
  96 0010 488B4DE0 		movq	-32(%rbp), %rcx
  97 0014 488B45E0 		movq	-32(%rbp), %rax
  98 0018 488D500F 		leaq	15(%rax), %rdx
  99 001c B8100000 		movl	$16, %eax
  99      00
 100 0021 4883E801 		subq	$1, %rax
 101 0025 4801D0   		addq	%rdx, %rax
 102 0028 BE100000 		movl	$16, %esi
 102      00
 103 002d BA000000 		movl	$0, %edx
 103      00
 104 0032 48F7F6   		divq	%rsi
 105 0035 486BC010 		imulq	$16, %rax, %rax
 106 0039 4829C4   		subq	%rax, %rsp
 107 003c 4889E0   		movq	%rsp, %rax
 108 003f 4883C00F 		addq	$15, %rax
 109 0043 48C1E804 		shrq	$4, %rax
 110 0047 48C1E004 		salq	$4, %rax
 111 004b 4889C7   		movq	%rax, %rdi
 112 004e 488B45E8 		movq	-24(%rbp), %rax
 113 0052 4889CA   		movq	%rcx, %rdx
 114 0055 4889C6   		movq	%rax, %rsi
 115 0058 E8000000 		call	memcpy@PLT
 115      00
 116 005d 488945E8 		movq	%rax, -24(%rbp)
  30:SignalTest.c  **** 	i = 0;
 118              	.LM2:
 119 0061 66C745FE 		movw	$0, -2(%rbp)
 119      0000
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 121              	.LM3:
 122 0067 EB52     		jmp	.L2
 123              	.L8:
  32:SignalTest.c  **** 		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(i, s__len)]);
 125              	.LM4:
 126 0069 480FBF45 		movswq	-2(%rbp), %rax
 126      FE
 127 006e 483B45E0 		cmpq	-32(%rbp), %rax
 128 0072 7D07     		jge	.L3
 130              	.LM5:
 131 0074 480FBF45 		movswq	-2(%rbp), %rax
 131      FE
 132 0079 EB0F     		jmp	.L4
 133              	.L3:
 135              	.LM6:
 136 007b BFFEFFFF 		movl	$-2, %edi
 136      FF
 137 0080 E8000000 		call	Modules_Halt@PLT
 137      00
 138 0085 B8000000 		movl	$0, %eax
 138      00
 139              	.L4:
 141              	.LM7:
 142 008a 488B55E8 		movq	-24(%rbp), %rdx
 143 008e 4801D0   		addq	%rdx, %rax
 144 0091 0FB600   		movzbl	(%rax), %eax
 145 0094 0FBED0   		movsbl	%al, %edx
 146 0097 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 146      000000
 147 009e 488B00   		movq	(%rax), %rax
 148 00a1 4889C6   		movq	%rax, %rsi
 149 00a4 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 149      000000
 150 00ab E8000000 		call	Files_Write@PLT
 150      00
  33:SignalTest.c  **** 		i += 1;
 152              	.LM8:
 153 00b0 0FB745FE 		movzwl	-2(%rbp), %eax
 154 00b4 83C001   		addl	$1, %eax
 155 00b7 668945FE 		movw	%ax, -2(%rbp)
 156              	.L2:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 158              	.LM9:
 159 00bb 480FBF45 		movswq	-2(%rbp), %rax
 159      FE
 160 00c0 483B45E0 		cmpq	-32(%rbp), %rax
 161 00c4 7D33     		jge	.L1
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 163              	.LM10:
 164 00c6 480FBF45 		movswq	-2(%rbp), %rax
 164      FE
 165 00cb 483B45E0 		cmpq	-32(%rbp), %rax
 166 00cf 7D07     		jge	.L6
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 168              	.LM11:
 169 00d1 480FBF45 		movswq	-2(%rbp), %rax
 169      FE
 170 00d6 EB0F     		jmp	.L7
 171              	.L6:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 173              	.LM12:
 174 00d8 BFFEFFFF 		movl	$-2, %edi
 174      FF
 175 00dd E8000000 		call	Modules_Halt@PLT
 175      00
 176 00e2 B8000000 		movl	$0, %eax
 176      00
 177              	.L7:
  31:SignalTest.c  **** 	while ((i < s__len && s[__X(i, s__len)] != 0x00)) {
 179              	.LM13:
 180 00e7 488B55E8 		movq	-24(%rbp), %rdx
 181 00eb 4801D0   		addq	%rdx, %rax
 182 00ee 0FB600   		movzbl	(%rax), %eax
 183 00f1 84C0     		testb	%al, %al
 184 00f3 0F8570FF 		jne	.L8
 184      FFFF
 185              	.L1:
  34:SignalTest.c  **** 	}
  35:SignalTest.c  **** 	__DEL(s);
  36:SignalTest.c  **** }
 187              	.LM14:
 188 00f9 C9       		leave
 189              		.cfi_def_cfa 7, 8
 190 00fa C3       		ret
 191              		.cfi_endproc
 192              	.LFE7:
 197              	.Lscope1:
 199              		.stabd	78,0,0
 202              	SignalTest_wl:
 203              		.stabd	46,0,0
  37:SignalTest.c  **** 
  38:SignalTest.c  **** static void SignalTest_wl (void)
  39:SignalTest.c  **** {
 205              	.LM15:
 206              	.LFBB2:
 207              	.LFB8:
 208              		.cfi_startproc
 209 00fb 55       		pushq	%rbp
 210              		.cfi_def_cfa_offset 16
 211              		.cfi_offset 6, -16
 212 00fc 4889E5   		movq	%rsp, %rbp
 213              		.cfi_def_cfa_register 6
  40:SignalTest.c  **** 	Files_Write(&SignalTest_rider, Files_Rider__typ, 0x0a);
 215              	.LM16:
 216 00ff 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 216      000000
 217 0106 488B00   		movq	(%rax), %rax
 218 0109 BA0A0000 		movl	$10, %edx
 218      00
 219 010e 4889C6   		movq	%rax, %rsi
 220 0111 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 220      000000
 221 0118 E8000000 		call	Files_Write@PLT
 221      00
  41:SignalTest.c  **** }
 223              	.LM17:
 224 011d 5D       		popq	%rbp
 225              		.cfi_def_cfa 7, 8
 226 011e C3       		ret
 227              		.cfi_endproc
 228              	.LFE8:
 230              	.Lscope2:
 232              		.stabd	78,0,0
 236              	SignalTest_wi:
 237              		.stabd	46,0,0
  42:SignalTest.c  **** 
  43:SignalTest.c  **** static void SignalTest_wi (INT32 i)
  44:SignalTest.c  **** {
 239              	.LM18:
 240              	.LFBB3:
 241              	.LFB9:
 242              		.cfi_startproc
 243 011f 55       		pushq	%rbp
 244              		.cfi_def_cfa_offset 16
 245              		.cfi_offset 6, -16
 246 0120 4889E5   		movq	%rsp, %rbp
 247              		.cfi_def_cfa_register 6
 248 0123 53       		pushq	%rbx
 249 0124 4883EC38 		subq	$56, %rsp
 250              		.cfi_offset 3, -24
 251 0128 897DCC   		movl	%edi, -52(%rbp)
  45:SignalTest.c  **** 	CHAR s[30];
  46:SignalTest.c  **** 	INT16 j;
  47:SignalTest.c  **** 	j = 0;
 253              	.LM19:
 254 012b 66C745EE 		movw	$0, -18(%rbp)
 254      0000
  48:SignalTest.c  **** 	if (i < 0) {
 256              	.LM20:
 257 0131 837DCC00 		cmpl	$0, -52(%rbp)
 258 0135 790F     		jns	.L11
  49:SignalTest.c  **** 		s[0] = '-';
 260              	.LM21:
 261 0137 C645D02D 		movb	$45, -48(%rbp)
  50:SignalTest.c  **** 		j += 1;
 263              	.LM22:
 264 013b 0FB745EE 		movzwl	-18(%rbp), %eax
 265 013f 83C001   		addl	$1, %eax
 266 0142 668945EE 		movw	%ax, -18(%rbp)
 267              	.L11:
  51:SignalTest.c  **** 	}
  52:SignalTest.c  **** 	s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 269              	.LM23:
 270 0146 66837DEE 		cmpw	$29, -18(%rbp)
 270      1D
 271 014b 7F06     		jg	.L12
 273              	.LM24:
 274 014d 0FBF5DEE 		movswl	-18(%rbp), %ebx
 275 0151 EB0F     		jmp	.L13
 276              	.L12:
 278              	.LM25:
 279 0153 BFFEFFFF 		movl	$-2, %edi
 279      FF
 280 0158 E8000000 		call	Modules_Halt@PLT
 280      00
 281 015d BB000000 		movl	$0, %ebx
 281      00
 282              	.L13:
 284              	.LM26:
 285 0162 837DCC00 		cmpl	$0, -52(%rbp)
 286 0166 7E2A     		jle	.L14
 288              	.LM27:
 289 0168 8B4DCC   		movl	-52(%rbp), %ecx
 290 016b BA676666 		movl	$1717986919, %edx
 290      66
 291 0170 89C8     		movl	%ecx, %eax
 292 0172 F7EA     		imull	%edx
 293 0174 C1FA02   		sarl	$2, %edx
 294 0177 89C8     		movl	%ecx, %eax
 295 0179 C1F81F   		sarl	$31, %eax
 296 017c 29C2     		subl	%eax, %edx
 297 017e 89D0     		movl	%edx, %eax
 298 0180 C1E002   		sall	$2, %eax
 299 0183 01D0     		addl	%edx, %eax
 300 0185 01C0     		addl	%eax, %eax
 301 0187 29C1     		subl	%eax, %ecx
 302 0189 89CA     		movl	%ecx, %edx
 303 018b 89D0     		movl	%edx, %eax
 304 018d 83C030   		addl	$48, %eax
 305 0190 EB15     		jmp	.L15
 306              	.L14:
 308              	.LM28:
 309 0192 8B45CC   		movl	-52(%rbp), %eax
 310 0195 4898     		cltq
 311 0197 BE0A0000 		movl	$10, %esi
 311      00
 312 019c 4889C7   		movq	%rax, %rdi
 313 019f E8000000 		call	SYSTEM_MOD@PLT
 313      00
 314 01a4 83C030   		addl	$48, %eax
 315              	.L15:
 317              	.LM29:
 318 01a7 4863D3   		movslq	%ebx, %rdx
 319 01aa 884415D0 		movb	%al, -48(%rbp,%rdx)
  53:SignalTest.c  **** 	j += 1;
 321              	.LM30:
 322 01ae 0FB745EE 		movzwl	-18(%rbp), %eax
 323 01b2 83C001   		addl	$1, %eax
 324 01b5 668945EE 		movw	%ax, -18(%rbp)
  54:SignalTest.c  **** 	i = __DIV(i, 10);
 326              	.LM31:
 327 01b9 837DCC00 		cmpl	$0, -52(%rbp)
 328 01bd 7E1A     		jle	.L16
 330              	.LM32:
 331 01bf 8B4DCC   		movl	-52(%rbp), %ecx
 332 01c2 BA676666 		movl	$1717986919, %edx
 332      66
 333 01c7 89C8     		movl	%ecx, %eax
 334 01c9 F7EA     		imull	%edx
 335 01cb C1FA02   		sarl	$2, %edx
 336 01ce 89C8     		movl	%ecx, %eax
 337 01d0 C1F81F   		sarl	$31, %eax
 338 01d3 29C2     		subl	%eax, %edx
 339 01d5 89D0     		movl	%edx, %eax
 340 01d7 EB12     		jmp	.L17
 341              	.L16:
 343              	.LM33:
 344 01d9 8B45CC   		movl	-52(%rbp), %eax
 345 01dc 4898     		cltq
 346 01de BE0A0000 		movl	$10, %esi
 346      00
 347 01e3 4889C7   		movq	%rax, %rdi
 348 01e6 E8000000 		call	SYSTEM_DIV@PLT
 348      00
 349              	.L17:
 351              	.LM34:
 352 01eb 8945CC   		movl	%eax, -52(%rbp)
  55:SignalTest.c  **** 	while (i > 0) {
 354              	.LM35:
 355 01ee E9A80000 		jmp	.L18
 355      00
 356              	.L25:
  56:SignalTest.c  **** 		s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 358              	.LM36:
 359 01f3 66837DEE 		cmpw	$29, -18(%rbp)
 359      1D
 360 01f8 7F06     		jg	.L19
 362              	.LM37:
 363 01fa 0FBF5DEE 		movswl	-18(%rbp), %ebx
 364 01fe EB0F     		jmp	.L20
 365              	.L19:
 367              	.LM38:
 368 0200 BFFEFFFF 		movl	$-2, %edi
 368      FF
 369 0205 E8000000 		call	Modules_Halt@PLT
 369      00
 370 020a BB000000 		movl	$0, %ebx
 370      00
 371              	.L20:
 373              	.LM39:
 374 020f 837DCC00 		cmpl	$0, -52(%rbp)
 375 0213 7E2A     		jle	.L21
 377              	.LM40:
 378 0215 8B4DCC   		movl	-52(%rbp), %ecx
 379 0218 BA676666 		movl	$1717986919, %edx
 379      66
 380 021d 89C8     		movl	%ecx, %eax
 381 021f F7EA     		imull	%edx
 382 0221 C1FA02   		sarl	$2, %edx
 383 0224 89C8     		movl	%ecx, %eax
 384 0226 C1F81F   		sarl	$31, %eax
 385 0229 29C2     		subl	%eax, %edx
 386 022b 89D0     		movl	%edx, %eax
 387 022d C1E002   		sall	$2, %eax
 388 0230 01D0     		addl	%edx, %eax
 389 0232 01C0     		addl	%eax, %eax
 390 0234 29C1     		subl	%eax, %ecx
 391 0236 89CA     		movl	%ecx, %edx
 392 0238 89D0     		movl	%edx, %eax
 393 023a 83C030   		addl	$48, %eax
 394 023d EB15     		jmp	.L22
 395              	.L21:
 397              	.LM41:
 398 023f 8B45CC   		movl	-52(%rbp), %eax
 399 0242 4898     		cltq
 400 0244 BE0A0000 		movl	$10, %esi
 400      00
 401 0249 4889C7   		movq	%rax, %rdi
 402 024c E8000000 		call	SYSTEM_MOD@PLT
 402      00
 403 0251 83C030   		addl	$48, %eax
 404              	.L22:
 406              	.LM42:
 407 0254 4863D3   		movslq	%ebx, %rdx
 408 0257 884415D0 		movb	%al, -48(%rbp,%rdx)
  57:SignalTest.c  **** 		j += 1;
 410              	.LM43:
 411 025b 0FB745EE 		movzwl	-18(%rbp), %eax
 412 025f 83C001   		addl	$1, %eax
 413 0262 668945EE 		movw	%ax, -18(%rbp)
  58:SignalTest.c  **** 		i = __DIV(i, 10);
 415              	.LM44:
 416 0266 837DCC00 		cmpl	$0, -52(%rbp)
 417 026a 7E1A     		jle	.L23
 419              	.LM45:
 420 026c 8B4DCC   		movl	-52(%rbp), %ecx
 421 026f BA676666 		movl	$1717986919, %edx
 421      66
 422 0274 89C8     		movl	%ecx, %eax
 423 0276 F7EA     		imull	%edx
 424 0278 C1FA02   		sarl	$2, %edx
 425 027b 89C8     		movl	%ecx, %eax
 426 027d C1F81F   		sarl	$31, %eax
 427 0280 29C2     		subl	%eax, %edx
 428 0282 89D0     		movl	%edx, %eax
 429 0284 EB12     		jmp	.L24
 430              	.L23:
 432              	.LM46:
 433 0286 8B45CC   		movl	-52(%rbp), %eax
 434 0289 4898     		cltq
 435 028b BE0A0000 		movl	$10, %esi
 435      00
 436 0290 4889C7   		movq	%rax, %rdi
 437 0293 E8000000 		call	SYSTEM_DIV@PLT
 437      00
 438              	.L24:
 440              	.LM47:
 441 0298 8945CC   		movl	%eax, -52(%rbp)
 442              	.L18:
  55:SignalTest.c  **** 		s[__X(j, 30)] = (CHAR)((int)__MOD(i, 10) + 48);
 444              	.LM48:
 445 029b 837DCC00 		cmpl	$0, -52(%rbp)
 446 029f 0F8F4EFF 		jg	.L25
 446      FFFF
  59:SignalTest.c  **** 	}
  60:SignalTest.c  **** 	while (j > 0) {
 448              	.LM49:
 449 02a5 EB4A     		jmp	.L26
 450              	.L29:
  61:SignalTest.c  **** 		j -= 1;
 452              	.LM50:
 453 02a7 0FB745EE 		movzwl	-18(%rbp), %eax
 454 02ab 83E801   		subl	$1, %eax
 455 02ae 668945EE 		movw	%ax, -18(%rbp)
  62:SignalTest.c  **** 		Files_Write(&SignalTest_rider, Files_Rider__typ, s[__X(j, 30)]);
 457              	.LM51:
 458 02b2 66837DEE 		cmpw	$29, -18(%rbp)
 458      1D
 459 02b7 7F06     		jg	.L27
 461              	.LM52:
 462 02b9 0FBF45EE 		movswl	-18(%rbp), %eax
 463 02bd EB0F     		jmp	.L28
 464              	.L27:
 466              	.LM53:
 467 02bf BFFEFFFF 		movl	$-2, %edi
 467      FF
 468 02c4 E8000000 		call	Modules_Halt@PLT
 468      00
 469 02c9 B8000000 		movl	$0, %eax
 469      00
 470              	.L28:
 472              	.LM54:
 473 02ce 4898     		cltq
 474 02d0 0FB64405 		movzbl	-48(%rbp,%rax), %eax
 474      D0
 475 02d5 0FBED0   		movsbl	%al, %edx
 476 02d8 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 476      000000
 477 02df 488B00   		movq	(%rax), %rax
 478 02e2 4889C6   		movq	%rax, %rsi
 479 02e5 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 479      000000
 480 02ec E8000000 		call	Files_Write@PLT
 480      00
 481              	.L26:
  60:SignalTest.c  **** 		j -= 1;
 483              	.LM55:
 484 02f1 66837DEE 		cmpw	$0, -18(%rbp)
 484      00
 485 02f6 7FAF     		jg	.L29
  63:SignalTest.c  **** 	}
  64:SignalTest.c  **** }
 487              	.LM56:
 488 02f8 4883C438 		addq	$56, %rsp
 489 02fc 5B       		popq	%rbx
 490 02fd 5D       		popq	%rbp
 491              		.cfi_def_cfa 7, 8
 492 02fe C3       		ret
 493              		.cfi_endproc
 494              	.LFE9:
 500              	.Lscope3:
 502              		.stabd	78,0,0
 503              		.section	.rodata
 504              	.LC0:
 505 0000 5369676E 		.string	"Signal: "
 505      616C3A20 
 505      00
 506              	.LC1:
 507 0009 5369676E 		.string	"Signal "
 507      616C2000 
 508              		.text
 512              	SignalTest_handle:
 513              		.stabd	46,0,0
  65:SignalTest.c  **** 
  66:SignalTest.c  **** static void SignalTest_handle (INT32 signal)
  67:SignalTest.c  **** {
 515              	.LM57:
 516              	.LFBB4:
 517              	.LFB10:
 518              		.cfi_startproc
 519 02ff 55       		pushq	%rbp
 520              		.cfi_def_cfa_offset 16
 521              		.cfi_offset 6, -16
 522 0300 4889E5   		movq	%rsp, %rbp
 523              		.cfi_def_cfa_register 6
 524 0303 4883EC10 		subq	$16, %rsp
 525 0307 897DFC   		movl	%edi, -4(%rbp)
  68:SignalTest.c  **** 	Console_Ln();
 527              	.LM58:
 528 030a E8000000 		call	Console_Ln@PLT
 528      00
  69:SignalTest.c  **** 	Console_String((CHAR*)"Signal: ", 9);
 530              	.LM59:
 531 030f BE090000 		movl	$9, %esi
 531      00
 532 0314 488D3D00 		leaq	.LC0(%rip), %rdi
 532      000000
 533 031b E8000000 		call	Console_String@PLT
 533      00
  70:SignalTest.c  **** 	Console_Int(signal, 1);
 535              	.LM60:
 536 0320 8B45FC   		movl	-4(%rbp), %eax
 537 0323 4898     		cltq
 538 0325 BE010000 		movl	$1, %esi
 538      00
 539 032a 4889C7   		movq	%rax, %rdi
 540 032d E8000000 		call	Console_Int@PLT
 540      00
  71:SignalTest.c  **** 	Console_Ln();
 542              	.LM61:
 543 0332 E8000000 		call	Console_Ln@PLT
 543      00
  72:SignalTest.c  **** 	SignalTest_ws((CHAR*)"Signal ", 8);
 545              	.LM62:
 546 0337 BE080000 		movl	$8, %esi
 546      00
 547 033c 488D3D00 		leaq	.LC1(%rip), %rdi
 547      000000
 548 0343 E8B8FCFF 		call	SignalTest_ws
 548      FF
  73:SignalTest.c  **** 	SignalTest_wi(signal);
 550              	.LM63:
 551 0348 8B45FC   		movl	-4(%rbp), %eax
 552 034b 89C7     		movl	%eax, %edi
 553 034d E8CDFDFF 		call	SignalTest_wi
 553      FF
  74:SignalTest.c  **** 	SignalTest_wl();
 555              	.LM64:
 556 0352 E8A4FDFF 		call	SignalTest_wl
 556      FF
  75:SignalTest.c  **** }
 558              	.LM65:
 559 0357 C9       		leave
 560              		.cfi_def_cfa 7, 8
 561 0358 C3       		ret
 562              		.cfi_endproc
 563              	.LFE10:
 565              	.Lscope4:
 567              		.stabd	78,0,0
 571              	SignalTest_Take5:
 572              		.stabd	46,0,0
  76:SignalTest.c  **** 
  77:SignalTest.c  **** static void SignalTest_Take5 (INT16 i)
  78:SignalTest.c  **** {
 574              	.LM66:
 575              	.LFBB5:
 576              	.LFB11:
 577              		.cfi_startproc
 578 0359 55       		pushq	%rbp
 579              		.cfi_def_cfa_offset 16
 580              		.cfi_offset 6, -16
 581 035a 4889E5   		movq	%rsp, %rbp
 582              		.cfi_def_cfa_register 6
 583 035d 4883EC10 		subq	$16, %rsp
 584 0361 89F8     		movl	%edi, %eax
 585 0363 668945FC 		movw	%ax, -4(%rbp)
  79:SignalTest.c  **** 	while (i > 0) {
 587              	.LM67:
 588 0367 EB2C     		jmp	.L32
 589              	.L33:
  80:SignalTest.c  **** 		Console_Int(i, 2);
 591              	.LM68:
 592 0369 480FBF45 		movswq	-4(%rbp), %rax
 592      FC
 593 036e BE020000 		movl	$2, %esi
 593      00
 594 0373 4889C7   		movq	%rax, %rdi
 595 0376 E8000000 		call	Console_Int@PLT
 595      00
  81:SignalTest.c  **** 		Console_Flush();
 597              	.LM69:
 598 037b E8000000 		call	Console_Flush@PLT
 598      00
  82:SignalTest.c  **** 		Platform_Delay(1000);
 600              	.LM70:
 601 0380 BFE80300 		movl	$1000, %edi
 601      00
 602 0385 E8000000 		call	Platform_Delay@PLT
 602      00
  83:SignalTest.c  **** 		i -= 1;
 604              	.LM71:
 605 038a 0FB745FC 		movzwl	-4(%rbp), %eax
 606 038e 83E801   		subl	$1, %eax
 607 0391 668945FC 		movw	%ax, -4(%rbp)
 608              	.L32:
  79:SignalTest.c  **** 		Console_Int(i, 2);
 610              	.LM72:
 611 0395 66837DFC 		cmpw	$0, -4(%rbp)
 611      00
 612 039a 7FCD     		jg	.L33
  84:SignalTest.c  **** 	}
  85:SignalTest.c  **** 	Console_Ln();
 614              	.LM73:
 615 039c E8000000 		call	Console_Ln@PLT
 615      00
  86:SignalTest.c  **** }
 617              	.LM74:
 618 03a1 C9       		leave
 619              		.cfi_def_cfa 7, 8
 620 03a2 C3       		ret
 621              		.cfi_endproc
 622              	.LFE11:
 624              	.Lscope5:
 626              		.stabd	78,0,0
 630              	EnumPtrs:
 631              		.stabd	46,0,0
  87:SignalTest.c  **** 
  88:SignalTest.c  **** static void EnumPtrs(void (*P)(void*))
  89:SignalTest.c  **** {
 633              	.LM75:
 634              	.LFBB6:
 635              	.LFB12:
 636              		.cfi_startproc
 637 03a3 55       		pushq	%rbp
 638              		.cfi_def_cfa_offset 16
 639              		.cfi_offset 6, -16
 640 03a4 4889E5   		movq	%rsp, %rbp
 641              		.cfi_def_cfa_register 6
 642 03a7 4883EC10 		subq	$16, %rsp
 643 03ab 48897DF8 		movq	%rdi, -8(%rbp)
  90:SignalTest.c  **** 	P(SignalTest_result);
 645              	.LM76:
 646 03af 488B1500 		movq	SignalTest_result(%rip), %rdx
 646      000000
 647 03b6 488B45F8 		movq	-8(%rbp), %rax
 648 03ba 4889D7   		movq	%rdx, %rdi
 649 03bd FFD0     		call	*%rax
  91:SignalTest.c  **** 	__ENUMR(&SignalTest_rider, Files_Rider__typ, 24, 1, P);
 651              	.LM77:
 652 03bf 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 652      000000
 653 03c6 488B00   		movq	(%rax), %rax
 654 03c9 488B55F8 		movq	-8(%rbp), %rdx
 655 03cd 4989D0   		movq	%rdx, %r8
 656 03d0 B9010000 		movl	$1, %ecx
 656      00
 657 03d5 BA180000 		movl	$24, %edx
 657      00
 658 03da 4889C6   		movq	%rax, %rsi
 659 03dd 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 659      000000
 660 03e4 E8000000 		call	SYSTEM_ENUMR@PLT
 660      00
  92:SignalTest.c  **** }
 662              	.LM78:
 663 03e9 C9       		leave
 664              		.cfi_def_cfa 7, 8
 665 03ea C3       		ret
 666              		.cfi_endproc
 667              	.LFE12:
 669              	.Lscope6:
 671              		.stabd	78,0,0
 672              		.section	.rodata
 673              	.LC2:
 674 0011 5369676E 		.string	"SignalTest"
 674      616C5465 
 674      737400
 675              	.LC3:
 676 001c 72657375 		.string	"result"
 676      6C7400
 677              		.text
 681              		.globl	main
 683              	main:
 684              		.stabd	46,0,0
  93:SignalTest.c  **** 
  94:SignalTest.c  **** 
  95:SignalTest.c  **** export int main(int argc, char **argv)
  96:SignalTest.c  **** {
 686              	.LM79:
 687              	.LFBB7:
 688              	.LFB13:
 689              		.cfi_startproc
 690 03eb 55       		pushq	%rbp
 691              		.cfi_def_cfa_offset 16
 692              		.cfi_offset 6, -16
 693 03ec 4889E5   		movq	%rsp, %rbp
 694              		.cfi_def_cfa_register 6
 695 03ef 4883EC10 		subq	$16, %rsp
 696 03f3 897DFC   		movl	%edi, -4(%rbp)
 697 03f6 488975F0 		movq	%rsi, -16(%rbp)
  97:SignalTest.c  **** 	__INIT(argc, argv);
 699              	.LM80:
 700 03fa 488D55F0 		leaq	-16(%rbp), %rdx
 701 03fe 8B45FC   		movl	-4(%rbp), %eax
 702 0401 4889D6   		movq	%rdx, %rsi
 703 0404 89C7     		movl	%eax, %edi
 704 0406 E8000000 		call	Modules_Init@PLT
 704      00
  98:SignalTest.c  **** 	__MODULE_IMPORT(Console);
 706              	.LM81:
 707 040b E8000000 		call	Console__init@PLT
 707      00
 708 0410 4889C7   		movq	%rax, %rdi
 709 0413 E8000000 		call	Heap_INCREF@PLT
 709      00
  99:SignalTest.c  **** 	__MODULE_IMPORT(Files);
 711              	.LM82:
 712 0418 E8000000 		call	Files__init@PLT
 712      00
 713 041d 4889C7   		movq	%rax, %rdi
 714 0420 E8000000 		call	Heap_INCREF@PLT
 714      00
 100:SignalTest.c  **** 	__MODULE_IMPORT(Modules);
 716              	.LM83:
 717 0425 E8000000 		call	Modules__init@PLT
 717      00
 718 042a 4889C7   		movq	%rax, %rdi
 719 042d E8000000 		call	Heap_INCREF@PLT
 719      00
 101:SignalTest.c  **** 	__MODULE_IMPORT(Platform);
 721              	.LM84:
 722 0432 E8000000 		call	Platform__init@PLT
 722      00
 723 0437 4889C7   		movq	%rax, %rdi
 724 043a E8000000 		call	Heap_INCREF@PLT
 724      00
 102:SignalTest.c  **** 	__REGMAIN("SignalTest", EnumPtrs);
 726              	.LM85:
 727 043f 488D355D 		leaq	EnumPtrs(%rip), %rsi
 727      FFFFFF
 728 0446 488D3D00 		leaq	.LC2(%rip), %rdi
 728      000000
 729 044d E8000000 		call	Heap_REGMOD@PLT
 729      00
 730 0452 48890500 		movq	%rax, m.2325(%rip)
 730      000000
 103:SignalTest.c  **** /* BEGIN */
 104:SignalTest.c  **** 	SignalTest_result = Files_New((CHAR*)"result", 7);
 732              	.LM86:
 733 0459 BE070000 		movl	$7, %esi
 733      00
 734 045e 488D3D00 		leaq	.LC3(%rip), %rdi
 734      000000
 735 0465 E8000000 		call	Files_New@PLT
 735      00
 736 046a 48890500 		movq	%rax, SignalTest_result(%rip)
 736      000000
 105:SignalTest.c  **** 	Files_Set(&SignalTest_rider, Files_Rider__typ, SignalTest_result, 0);
 738              	.LM87:
 739 0471 488B1500 		movq	SignalTest_result(%rip), %rdx
 739      000000
 740 0478 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 740      000000
 741 047f 488B00   		movq	(%rax), %rax
 742 0482 B9000000 		movl	$0, %ecx
 742      00
 743 0487 4889C6   		movq	%rax, %rsi
 744 048a 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 744      000000
 745 0491 E8000000 		call	Files_Set@PLT
 745      00
 106:SignalTest.c  **** 	if (Modules_ArgCount > 1) {
 747              	.LM88:
 748 0496 488B0500 		movq	Modules_ArgCount@GOTPCREL(%rip), %rax
 748      000000
 749 049d 0FB700   		movzwl	(%rax), %eax
 750 04a0 6683F801 		cmpw	$1, %ax
 751 04a4 7E18     		jle	.L36
 107:SignalTest.c  **** 		Platform_SetInterruptHandler(SignalTest_handle);
 753              	.LM89:
 754 04a6 488D3D52 		leaq	SignalTest_handle(%rip), %rdi
 754      FEFFFF
 755 04ad E8000000 		call	Platform_SetInterruptHandler@PLT
 755      00
 108:SignalTest.c  **** 		Platform_SetQuitHandler(SignalTest_handle);
 757              	.LM90:
 758 04b2 488D3D46 		leaq	SignalTest_handle(%rip), %rdi
 758      FEFFFF
 759 04b9 E8000000 		call	Platform_SetQuitHandler@PLT
 759      00
 760              	.L36:
 109:SignalTest.c  **** 	}
 110:SignalTest.c  **** 	SignalTest_Take5(4);
 762              	.LM91:
 763 04be BF040000 		movl	$4, %edi
 763      00
 764 04c3 E891FEFF 		call	SignalTest_Take5
 764      FF
 111:SignalTest.c  **** 	Files_Register(SignalTest_result);
 766              	.LM92:
 767 04c8 488B0500 		movq	SignalTest_result(%rip), %rax
 767      000000
 768 04cf 4889C7   		movq	%rax, %rdi
 769 04d2 E8000000 		call	Files_Register@PLT
 769      00
 112:SignalTest.c  **** 	__FINI;
 771              	.LM93:
 772 04d7 E8000000 		call	Heap_FINALL@PLT
 772      00
 773 04dc B8000000 		movl	$0, %eax
 773      00
 113:SignalTest.c  **** }
 775              	.LM94:
 776 04e1 C9       		leave
 777              		.cfi_def_cfa 7, 8
 778 04e2 C3       		ret
 779              		.cfi_endproc
 780              	.LFE13:
 785              	.Lscope7:
 787              		.stabd	78,0,0
 788              		.local	m.2325
 789              		.comm	m.2325,8,8
 793              	.Letext0:
 794              		.ident	"GCC: (Debian 4.9.2-10) 4.9.2"
 795              		.section	.note.GNU-stack,"",@progbits
