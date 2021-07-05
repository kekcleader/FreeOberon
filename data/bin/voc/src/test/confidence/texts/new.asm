   1              		.file	"testTexts.c"
   4              		.text
   5              	.Ltext0:
  88              		.local	testTexts_W
  89              		.comm	testTexts_W,56,32
  91              		.local	testTexts_T
  92              		.comm	testTexts_T,8,8
  94              		.local	testTexts_R
  95              		.comm	testTexts_R,72,32
  97              		.local	testTexts_ch
  98              		.comm	testTexts_ch,1,1
 100              		.local	testTexts_i
 101              		.comm	testTexts_i,2,2
 103              		.local	testTexts_s
 104              		.comm	testTexts_s,1024,32
 109              	EnumPtrs:
 110              		.stabd	46,0,0
   1:testTexts.c   **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:testTexts.c   **** 
   3:testTexts.c   **** #define SHORTINT INT8
   4:testTexts.c   **** #define INTEGER  INT16
   5:testTexts.c   **** #define LONGINT  INT32
   6:testTexts.c   **** #define SET      UINT32
   7:testTexts.c   **** 
   8:testTexts.c   **** #include "SYSTEM.h"
   9:testTexts.c   **** #include "Console.h"
  10:testTexts.c   **** #include "Texts.h"
  11:testTexts.c   **** 
  12:testTexts.c   **** 
  13:testTexts.c   **** static Texts_Writer testTexts_W;
  14:testTexts.c   **** static Texts_Text testTexts_T;
  15:testTexts.c   **** static Texts_Reader testTexts_R;
  16:testTexts.c   **** static CHAR testTexts_ch;
  17:testTexts.c   **** static INT16 testTexts_i;
  18:testTexts.c   **** static CHAR testTexts_s[1024];
  19:testTexts.c   **** 
  20:testTexts.c   **** 
  21:testTexts.c   **** 
  22:testTexts.c   **** 
  23:testTexts.c   **** static void EnumPtrs(void (*P)(void*))
  24:testTexts.c   **** {
 112              	.LM0:
 113              	.LFBB1:
 114              	.LFB7:
 115              		.cfi_startproc
 116 0000 F30F1EFA 		endbr64
 117 0004 55       		pushq	%rbp
 118              		.cfi_def_cfa_offset 16
 119              		.cfi_offset 6, -16
 120 0005 4889E5   		movq	%rsp, %rbp
 121              		.cfi_def_cfa_register 6
 122 0008 4883EC10 		subq	$16, %rsp
 123 000c 48897DF8 		movq	%rdi, -8(%rbp)
  25:testTexts.c   **** 	__ENUMR(&testTexts_W, Texts_Writer__typ, 56, 1, P);
 125              	.LM1:
 126 0010 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 126      000000
 127 0017 488B00   		movq	(%rax), %rax
 128 001a 488B55F8 		movq	-8(%rbp), %rdx
 129 001e 4989D0   		movq	%rdx, %r8
 130 0021 B9010000 		movl	$1, %ecx
 130      00
 131 0026 BA380000 		movl	$56, %edx
 131      00
 132 002b 4889C6   		movq	%rax, %rsi
 133 002e 488D3D00 		leaq	testTexts_W(%rip), %rdi
 133      000000
 134 0035 E8000000 		call	SYSTEM_ENUMR@PLT
 134      00
  26:testTexts.c   **** 	P(testTexts_T);
 136              	.LM2:
 137 003a 488B0500 		movq	testTexts_T(%rip), %rax
 137      000000
 138 0041 488B55F8 		movq	-8(%rbp), %rdx
 139 0045 4889C7   		movq	%rax, %rdi
 140 0048 FFD2     		call	*%rdx
  27:testTexts.c   **** 	__ENUMR(&testTexts_R, Texts_Reader__typ, 72, 1, P);
 142              	.LM3:
 143 004a 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 143      000000
 144 0051 488B00   		movq	(%rax), %rax
 145 0054 488B55F8 		movq	-8(%rbp), %rdx
 146 0058 4989D0   		movq	%rdx, %r8
 147 005b B9010000 		movl	$1, %ecx
 147      00
 148 0060 BA480000 		movl	$72, %edx
 148      00
 149 0065 4889C6   		movq	%rax, %rsi
 150 0068 488D3D00 		leaq	testTexts_R(%rip), %rdi
 150      000000
 151 006f E8000000 		call	SYSTEM_ENUMR@PLT
 151      00
  28:testTexts.c   **** }
 153              	.LM4:
 154 0074 90       		nop
 155 0075 C9       		leave
 156              		.cfi_def_cfa 7, 8
 157 0076 C3       		ret
 158              		.cfi_endproc
 159              	.LFE7:
 161              	.Lscope1:
 163              		.stabd	78,0,0
 164              		.section	.rodata
 165              	.LC0:
 166 0000 74657374 		.string	"testTexts"
 166      54657874 
 166      7300
 167              	.LC1:
 168 000a 61616100 		.string	"aaa"
 169              	.LC4:
 170 000e 74657374 		.string	"test.txt"
 170      2E747874 
 170      00
 171              		.text
 175              		.globl	main
 177              	main:
 178              		.stabd	46,0,0
  29:testTexts.c   **** 
  30:testTexts.c   **** 
  31:testTexts.c   **** export int main(int argc, char **argv)
  32:testTexts.c   **** {
 180              	.LM5:
 181              	.LFBB2:
 182              	.LFB8:
 183              		.cfi_startproc
 184 0077 F30F1EFA 		endbr64
 185 007b 55       		pushq	%rbp
 186              		.cfi_def_cfa_offset 16
 187              		.cfi_offset 6, -16
 188 007c 4889E5   		movq	%rsp, %rbp
 189              		.cfi_def_cfa_register 6
 190 007f 4883EC10 		subq	$16, %rsp
 191 0083 897DFC   		movl	%edi, -4(%rbp)
 192 0086 488975F0 		movq	%rsi, -16(%rbp)
  33:testTexts.c   **** 	__INIT(argc, argv);
 194              	.LM6:
 195 008a 488D55F0 		leaq	-16(%rbp), %rdx
 196 008e 8B45FC   		movl	-4(%rbp), %eax
 197 0091 4889D6   		movq	%rdx, %rsi
 198 0094 89C7     		movl	%eax, %edi
 199 0096 E8000000 		call	Modules_Init@PLT
 199      00
  34:testTexts.c   **** 	__MODULE_IMPORT(Console);
 201              	.LM7:
 202 009b E8000000 		call	Console__init@PLT
 202      00
 203 00a0 4889C7   		movq	%rax, %rdi
 204 00a3 B8000000 		movl	$0, %eax
 204      00
 205 00a8 E8000000 		call	Heap_INCREF@PLT
 205      00
  35:testTexts.c   **** 	__MODULE_IMPORT(Texts);
 207              	.LM8:
 208 00ad E8000000 		call	Texts__init@PLT
 208      00
 209 00b2 4889C7   		movq	%rax, %rdi
 210 00b5 B8000000 		movl	$0, %eax
 210      00
 211 00ba E8000000 		call	Heap_INCREF@PLT
 211      00
  36:testTexts.c   **** 	__REGMAIN("testTexts", EnumPtrs);
 213              	.LM9:
 214 00bf 488D353A 		leaq	EnumPtrs(%rip), %rsi
 214      FFFFFF
 215 00c6 488D3D00 		leaq	.LC0(%rip), %rdi
 215      000000
 216 00cd B8000000 		movl	$0, %eax
 216      00
 217 00d2 E8000000 		call	Heap_REGMOD@PLT
 217      00
 218 00d7 48890500 		movq	%rax, m.2455(%rip)
 218      000000
  37:testTexts.c   **** /* BEGIN */
  38:testTexts.c   **** 	Texts_OpenWriter(&testTexts_W, Texts_Writer__typ);
 220              	.LM10:
 221 00de 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 221      000000
 222 00e5 488B00   		movq	(%rax), %rax
 223 00e8 4889C6   		movq	%rax, %rsi
 224 00eb 488D3D00 		leaq	testTexts_W(%rip), %rdi
 224      000000
 225 00f2 E8000000 		call	Texts_OpenWriter@PLT
 225      00
  39:testTexts.c   **** 	Texts_WriteString(&testTexts_W, Texts_Writer__typ, (CHAR*)"aaa", 4);
 227              	.LM11:
 228 00f7 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 228      000000
 229 00fe 488B00   		movq	(%rax), %rax
 230 0101 B9040000 		movl	$4, %ecx
 230      00
 231 0106 488D1500 		leaq	.LC1(%rip), %rdx
 231      000000
 232 010d 4889C6   		movq	%rax, %rsi
 233 0110 488D3D00 		leaq	testTexts_W(%rip), %rdi
 233      000000
 234 0117 E8000000 		call	Texts_WriteString@PLT
 234      00
  40:testTexts.c   **** 	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
 236              	.LM12:
 237 011c 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 237      000000
 238 0123 488B00   		movq	(%rax), %rax
 239 0126 4889C6   		movq	%rax, %rsi
 240 0129 488D3D00 		leaq	testTexts_W(%rip), %rdi
 240      000000
 241 0130 E8000000 		call	Texts_WriteLn@PLT
 241      00
  41:testTexts.c   **** 	Texts_WriteReal(&testTexts_W, Texts_Writer__typ,  -3.1114151e+002, 7);
 243              	.LM13:
 244 0135 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 244      000000
 245 013c 488B00   		movq	(%rax), %rax
 246 013f BA070000 		movl	$7, %edx
 246      00
 247 0144 F30F1005 		movss	.LC2(%rip), %xmm0
 247      00000000 
 248 014c 4889C6   		movq	%rax, %rsi
 249 014f 488D3D00 		leaq	testTexts_W(%rip), %rdi
 249      000000
 250 0156 E8000000 		call	Texts_WriteReal@PLT
 250      00
  42:testTexts.c   **** 	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
 252              	.LM14:
 253 015b 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 253      000000
 254 0162 488B00   		movq	(%rax), %rax
 255 0165 4889C6   		movq	%rax, %rsi
 256 0168 488D3D00 		leaq	testTexts_W(%rip), %rdi
 256      000000
 257 016f E8000000 		call	Texts_WriteLn@PLT
 257      00
  43:testTexts.c   **** 	Texts_WriteRealFix(&testTexts_W, Texts_Writer__typ,  -3.1114151e+002, 0, 7);
 259              	.LM15:
 260 0174 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 260      000000
 261 017b 488B00   		movq	(%rax), %rax
 262 017e B9070000 		movl	$7, %ecx
 262      00
 263 0183 BA000000 		movl	$0, %edx
 263      00
 264 0188 F30F1005 		movss	.LC2(%rip), %xmm0
 264      00000000 
 265 0190 4889C6   		movq	%rax, %rsi
 266 0193 488D3D00 		leaq	testTexts_W(%rip), %rdi
 266      000000
 267 019a E8000000 		call	Texts_WriteRealFix@PLT
 267      00
  44:testTexts.c   **** 	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
 269              	.LM16:
 270 019f 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 270      000000
 271 01a6 488B00   		movq	(%rax), %rax
 272 01a9 4889C6   		movq	%rax, %rsi
 273 01ac 488D3D00 		leaq	testTexts_W(%rip), %rdi
 273      000000
 274 01b3 E8000000 		call	Texts_WriteLn@PLT
 274      00
  45:testTexts.c   **** 	Texts_WriteLongReal(&testTexts_W, Texts_Writer__typ,  -3.11141510009766e+002, 7);
 276              	.LM17:
 277 01b8 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 277      000000
 278 01bf 488B00   		movq	(%rax), %rax
 279 01c2 488B0D00 		movq	.LC3(%rip), %rcx
 279      000000
 280 01c9 BA070000 		movl	$7, %edx
 280      00
 281 01ce 66480F6E 		movq	%rcx, %xmm0
 281      C1
 282 01d3 4889C6   		movq	%rax, %rsi
 283 01d6 488D3D00 		leaq	testTexts_W(%rip), %rdi
 283      000000
 284 01dd E8000000 		call	Texts_WriteLongReal@PLT
 284      00
  46:testTexts.c   **** 	Texts_WriteLn(&testTexts_W, Texts_Writer__typ);
 286              	.LM18:
 287 01e2 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 287      000000
 288 01e9 488B00   		movq	(%rax), %rax
 289 01ec 4889C6   		movq	%rax, %rsi
 290 01ef 488D3D00 		leaq	testTexts_W(%rip), %rdi
 290      000000
 291 01f6 E8000000 		call	Texts_WriteLn@PLT
 291      00
  47:testTexts.c   **** 	__NEW(testTexts_T, Texts_TextDesc);
 293              	.LM19:
 294 01fb 488B0500 		movq	Texts_TextDesc__typ@GOTPCREL(%rip), %rax
 294      000000
 295 0202 488B00   		movq	(%rax), %rax
 296 0205 4889C7   		movq	%rax, %rdi
 297 0208 E8000000 		call	Heap_NEWREC@PLT
 297      00
 298 020d 48890500 		movq	%rax, testTexts_T(%rip)
 298      000000
  48:testTexts.c   **** 	Texts_Open(testTexts_T, (CHAR*)"test.txt", 9);
 300              	.LM20:
 301 0214 488B0500 		movq	testTexts_T(%rip), %rax
 301      000000
 302 021b BA090000 		movl	$9, %edx
 302      00
 303 0220 488D3500 		leaq	.LC4(%rip), %rsi
 303      000000
 304 0227 4889C7   		movq	%rax, %rdi
 305 022a E8000000 		call	Texts_Open@PLT
 305      00
  49:testTexts.c   **** 	Texts_Append(testTexts_T, testTexts_W.buf);
 307              	.LM21:
 308 022f 488B1500 		movq	testTexts_W(%rip), %rdx
 308      000000
 309 0236 488B0500 		movq	testTexts_T(%rip), %rax
 309      000000
 310 023d 4889D6   		movq	%rdx, %rsi
 311 0240 4889C7   		movq	%rax, %rdi
 312 0243 E8000000 		call	Texts_Append@PLT
 312      00
  50:testTexts.c   **** 	Texts_OpenReader(&testTexts_R, Texts_Reader__typ, testTexts_T, 0);
 314              	.LM22:
 315 0248 488B1500 		movq	testTexts_T(%rip), %rdx
 315      000000
 316 024f 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 316      000000
 317 0256 488B00   		movq	(%rax), %rax
 318 0259 B9000000 		movl	$0, %ecx
 318      00
 319 025e 4889C6   		movq	%rax, %rsi
 320 0261 488D3D00 		leaq	testTexts_R(%rip), %rdi
 320      000000
 321 0268 E8000000 		call	Texts_OpenReader@PLT
 321      00
  51:testTexts.c   **** 	Texts_Read(&testTexts_R, Texts_Reader__typ, &testTexts_ch);
 323              	.LM23:
 324 026d 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 324      000000
 325 0274 488B00   		movq	(%rax), %rax
 326 0277 488D1500 		leaq	testTexts_ch(%rip), %rdx
 326      000000
 327 027e 4889C6   		movq	%rax, %rsi
 328 0281 488D3D00 		leaq	testTexts_R(%rip), %rdi
 328      000000
 329 0288 E8000000 		call	Texts_Read@PLT
 329      00
  52:testTexts.c   **** 	testTexts_i = 0;
 331              	.LM24:
 332 028d 66C70500 		movw	$0, testTexts_i(%rip)
 332      00000000 
 332      00
  53:testTexts.c   **** 	while (!testTexts_R.eot) {
 334              	.LM25:
 335 0296 E9C90000 		jmp	.L3
 335      00
 336              	.L10:
  54:testTexts.c   **** 		if (testTexts_ch == 0x0d) {
 338              	.LM26:
 339 029b 0FB60500 		movzbl	testTexts_ch(%rip), %eax
 339      000000
 341              	.LM27:
 342 02a2 3C0D     		cmpb	$13, %al
 343 02a4 7554     		jne	.L4
  55:testTexts.c   **** 			testTexts_s[__X(testTexts_i, 1024)] = 0x00;
 345              	.LM28:
 346 02a6 0FB70500 		movzwl	testTexts_i(%rip), %eax
 346      000000
 347 02ad 663DFF03 		cmpw	$1023, %ax
 348 02b1 7F0A     		jg	.L5
 350              	.LM29:
 351 02b3 0FB70500 		movzwl	testTexts_i(%rip), %eax
 351      000000
 352 02ba 98       		cwtl
 353 02bb EB0F     		jmp	.L6
 354              	.L5:
 356              	.LM30:
 357 02bd BFFEFFFF 		movl	$-2, %edi
 357      FF
 358 02c2 E8000000 		call	Modules_Halt@PLT
 358      00
 359 02c7 B8000000 		movl	$0, %eax
 359      00
 360              	.L6:
 362              	.LM31:
 363 02cc 4898     		cltq
 364 02ce 488D1500 		leaq	testTexts_s(%rip), %rdx
 364      000000
 365 02d5 C6041000 		movb	$0, (%rax,%rdx)
  56:testTexts.c   **** 			testTexts_i = 0;
 367              	.LM32:
 368 02d9 66C70500 		movw	$0, testTexts_i(%rip)
 368      00000000 
 368      00
  57:testTexts.c   **** 			Console_String(testTexts_s, 1024);
 370              	.LM33:
 371 02e2 BE000400 		movl	$1024, %esi
 371      00
 372 02e7 488D3D00 		leaq	testTexts_s(%rip), %rdi
 372      000000
 373 02ee E8000000 		call	Console_String@PLT
 373      00
  58:testTexts.c   **** 			Console_Ln();
 375              	.LM34:
 376 02f3 E8000000 		call	Console_Ln@PLT
 376      00
 377 02f8 EB4A     		jmp	.L7
 378              	.L4:
  59:testTexts.c   **** 		} else {
  60:testTexts.c   **** 			testTexts_s[__X(testTexts_i, 1024)] = testTexts_ch;
 380              	.LM35:
 381 02fa 0FB70500 		movzwl	testTexts_i(%rip), %eax
 381      000000
 382 0301 663DFF03 		cmpw	$1023, %ax
 383 0305 7F0A     		jg	.L8
 385              	.LM36:
 386 0307 0FB70500 		movzwl	testTexts_i(%rip), %eax
 386      000000
 387 030e 98       		cwtl
 388 030f EB0F     		jmp	.L9
 389              	.L8:
 391              	.LM37:
 392 0311 BFFEFFFF 		movl	$-2, %edi
 392      FF
 393 0316 E8000000 		call	Modules_Halt@PLT
 393      00
 394 031b B8000000 		movl	$0, %eax
 394      00
 395              	.L9:
 397              	.LM38:
 398 0320 0FB61500 		movzbl	testTexts_ch(%rip), %edx
 398      000000
 399 0327 4898     		cltq
 400 0329 488D0D00 		leaq	testTexts_s(%rip), %rcx
 400      000000
 401 0330 881408   		movb	%dl, (%rax,%rcx)
  61:testTexts.c   **** 			testTexts_i += 1;
 403              	.LM39:
 404 0333 0FB70500 		movzwl	testTexts_i(%rip), %eax
 404      000000
 405 033a 83C001   		addl	$1, %eax
 406 033d 66890500 		movw	%ax, testTexts_i(%rip)
 406      000000
 407              	.L7:
  62:testTexts.c   **** 		}
  63:testTexts.c   **** 		Texts_Read(&testTexts_R, Texts_Reader__typ, &testTexts_ch);
 409              	.LM40:
 410 0344 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 410      000000
 411 034b 488B00   		movq	(%rax), %rax
 412 034e 488D1500 		leaq	testTexts_ch(%rip), %rdx
 412      000000
 413 0355 4889C6   		movq	%rax, %rsi
 414 0358 488D3D00 		leaq	testTexts_R(%rip), %rdi
 414      000000
 415 035f E8000000 		call	Texts_Read@PLT
 415      00
 416              	.L3:
  53:testTexts.c   **** 		if (testTexts_ch == 0x0d) {
 418              	.LM41:
 419 0364 0FB60500 		movzbl	testTexts_R(%rip), %eax
 419      000000
  53:testTexts.c   **** 		if (testTexts_ch == 0x0d) {
 421              	.LM42:
 422 036b 84C0     		testb	%al, %al
 423 036d 0F8428FF 		je	.L10
 423      FFFF
  64:testTexts.c   **** 	}
  65:testTexts.c   **** 	testTexts_s[__X(testTexts_i, 1024)] = 0x00;
 425              	.LM43:
 426 0373 0FB70500 		movzwl	testTexts_i(%rip), %eax
 426      000000
 427 037a 663DFF03 		cmpw	$1023, %ax
 428 037e 7F0A     		jg	.L11
 430              	.LM44:
 431 0380 0FB70500 		movzwl	testTexts_i(%rip), %eax
 431      000000
 432 0387 98       		cwtl
 433 0388 EB0F     		jmp	.L12
 434              	.L11:
 436              	.LM45:
 437 038a BFFEFFFF 		movl	$-2, %edi
 437      FF
 438 038f E8000000 		call	Modules_Halt@PLT
 438      00
 439 0394 B8000000 		movl	$0, %eax
 439      00
 440              	.L12:
 442              	.LM46:
 443 0399 4898     		cltq
 444 039b 488D1500 		leaq	testTexts_s(%rip), %rdx
 444      000000
 445 03a2 C6041000 		movb	$0, (%rax,%rdx)
  66:testTexts.c   **** 	__FINI;
 447              	.LM47:
 448 03a6 B8000000 		movl	$0, %eax
 448      00
 449 03ab E8000000 		call	Heap_FINALL@PLT
 449      00
 450 03b0 B8000000 		movl	$0, %eax
 450      00
  67:testTexts.c   **** }
 452              	.LM48:
 453 03b5 C9       		leave
 454              		.cfi_def_cfa 7, 8
 455 03b6 C3       		ret
 456              		.cfi_endproc
 457              	.LFE8:
 462              	.Lscope2:
 464              		.stabd	78,0,0
 465              		.local	m.2455
 466              		.comm	m.2455,8,8
 468              		.section	.rodata
 469 0017 00       		.align 4
 470              	.LC2:
 471 0018 1D929BC3 		.long	3281752605
 472 001c 00000000 		.align 8
 473              	.LC3:
 474 0020 070000A0 		.long	2684354567
 475 0024 437273C0 		.long	-1066175933
 476              		.text
 478              	.Letext0:
 479              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 480              		.section	.note.GNU-stack,"",@progbits
 481              		.section	.note.gnu.property,"a"
 482              		.align 8
 483 0000 04000000 		.long	 1f - 0f
 484 0004 10000000 		.long	 4f - 1f
 485 0008 05000000 		.long	 5
 486              	0:
 487 000c 474E5500 		.string	 "GNU"
 488              	1:
 489              		.align 8
 490 0010 020000C0 		.long	 0xc0000002
 491 0014 04000000 		.long	 3f - 2f
 492              	2:
 493 0018 03000000 		.long	 0x3
 494              	3:
 495 001c 00000000 		.align 8
 496              	4:
