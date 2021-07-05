   1              		.file	"isptest.c"
   4              		.text
   5              	.Ltext0:
  93              		.local	isptest_T
  94              		.comm	isptest_T,8,8
  96              		.local	isptest_R
  97              		.comm	isptest_R,96,32
  99              		.local	isptest_ch
 100              		.comm	isptest_ch,1,1
 102              		.local	isptest_i
 103              		.comm	isptest_i,8,8
 105              		.local	isptest_j
 106              		.comm	isptest_j,8,8
 108              		.local	isptest_k
 109              		.comm	isptest_k,8,8
 114              	EnumPtrs:
 115              		.stabd	46,0,0
   1:isptest.c     **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:isptest.c     **** 
   3:isptest.c     **** #define SHORTINT INT16
   4:isptest.c     **** #define INTEGER  INT32
   5:isptest.c     **** #define LONGINT  INT64
   6:isptest.c     **** #define SET      UINT32
   7:isptest.c     **** 
   8:isptest.c     **** #include "SYSTEM.h"
   9:isptest.c     **** #include "Files.h"
  10:isptest.c     **** #include "Out.h"
  11:isptest.c     **** #include "Platform.h"
  12:isptest.c     **** #include "Texts.h"
  13:isptest.c     **** 
  14:isptest.c     **** 
  15:isptest.c     **** static Texts_Text isptest_T;
  16:isptest.c     **** static Texts_Reader isptest_R;
  17:isptest.c     **** static CHAR isptest_ch;
  18:isptest.c     **** static INT64 isptest_i, isptest_j, isptest_k;
  19:isptest.c     **** 
  20:isptest.c     **** 
  21:isptest.c     **** 
  22:isptest.c     **** 
  23:isptest.c     **** static void EnumPtrs(void (*P)(void*))
  24:isptest.c     **** {
 117              	.LM0:
 118              	.LFBB1:
 119              	.LFB7:
 120              		.cfi_startproc
 121 0000 F30F1EFA 		endbr64
 122 0004 55       		pushq	%rbp
 123              		.cfi_def_cfa_offset 16
 124              		.cfi_offset 6, -16
 125 0005 4889E5   		movq	%rsp, %rbp
 126              		.cfi_def_cfa_register 6
 127 0008 4883EC10 		subq	$16, %rsp
 128 000c 48897DF8 		movq	%rdi, -8(%rbp)
  25:isptest.c     **** 	P(isptest_T);
 130              	.LM1:
 131 0010 488B0500 		movq	isptest_T(%rip), %rax
 131      000000
 132 0017 488B55F8 		movq	-8(%rbp), %rdx
 133 001b 4889C7   		movq	%rax, %rdi
 134 001e FFD2     		call	*%rdx
  26:isptest.c     **** 	__ENUMR(&isptest_R, Texts_Reader__typ, 96, 1, P);
 136              	.LM2:
 137 0020 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 137      000000
 138 0027 488B00   		movq	(%rax), %rax
 139 002a 488B55F8 		movq	-8(%rbp), %rdx
 140 002e 4989D0   		movq	%rdx, %r8
 141 0031 B9010000 		movl	$1, %ecx
 141      00
 142 0036 BA600000 		movl	$96, %edx
 142      00
 143 003b 4889C6   		movq	%rax, %rsi
 144 003e 488D3D00 		leaq	isptest_R(%rip), %rdi
 144      000000
 145 0045 E8000000 		call	SYSTEM_ENUMR@PLT
 145      00
  27:isptest.c     **** }
 147              	.LM3:
 148 004a 90       		nop
 149 004b C9       		leave
 150              		.cfi_def_cfa 7, 8
 151 004c C3       		ret
 152              		.cfi_endproc
 153              	.LFE7:
 155              	.Lscope1:
 157              		.stabd	78,0,0
 158              		.section	.rodata
 159              	.LC0:
 160 0000 69737074 		.string	"isptest"
 160      65737400 
 161              	.LC1:
 162 0008 69737074 		.string	"isptest.mod"
 162      6573742E 
 162      6D6F6400 
 163              	.LC2:
 164 0014 706F733D 		.string	"pos="
 164      00
 165              	.LC3:
 166 0019 20636861 		.string	" char="
 166      723D00
 167              	.LC4:
 168 0020 32313930 		.string	"21906"
 168      3600
 169              		.text
 173              		.globl	main
 175              	main:
 176              		.stabd	46,0,0
  28:isptest.c     **** 
  29:isptest.c     **** 
  30:isptest.c     **** export int main(int argc, char **argv)
  31:isptest.c     **** {
 178              	.LM4:
 179              	.LFBB2:
 180              	.LFB8:
 181              		.cfi_startproc
 182 004d F30F1EFA 		endbr64
 183 0051 55       		pushq	%rbp
 184              		.cfi_def_cfa_offset 16
 185              		.cfi_offset 6, -16
 186 0052 4889E5   		movq	%rsp, %rbp
 187              		.cfi_def_cfa_register 6
 188 0055 4883EC10 		subq	$16, %rsp
 189 0059 897DFC   		movl	%edi, -4(%rbp)
 190 005c 488975F0 		movq	%rsi, -16(%rbp)
  32:isptest.c     **** 	__INIT(argc, argv);
 192              	.LM5:
 193 0060 488D55F0 		leaq	-16(%rbp), %rdx
 194 0064 8B45FC   		movl	-4(%rbp), %eax
 195 0067 4889D6   		movq	%rdx, %rsi
 196 006a 89C7     		movl	%eax, %edi
 197 006c E8000000 		call	Modules_Init@PLT
 197      00
  33:isptest.c     **** 	__MODULE_IMPORT(Files);
 199              	.LM6:
 200 0071 E8000000 		call	Files__init@PLT
 200      00
 201 0076 4889C7   		movq	%rax, %rdi
 202 0079 B8000000 		movl	$0, %eax
 202      00
 203 007e E8000000 		call	Heap_INCREF@PLT
 203      00
  34:isptest.c     **** 	__MODULE_IMPORT(Out);
 205              	.LM7:
 206 0083 E8000000 		call	Out__init@PLT
 206      00
 207 0088 4889C7   		movq	%rax, %rdi
 208 008b B8000000 		movl	$0, %eax
 208      00
 209 0090 E8000000 		call	Heap_INCREF@PLT
 209      00
  35:isptest.c     **** 	__MODULE_IMPORT(Platform);
 211              	.LM8:
 212 0095 E8000000 		call	Platform__init@PLT
 212      00
 213 009a 4889C7   		movq	%rax, %rdi
 214 009d B8000000 		movl	$0, %eax
 214      00
 215 00a2 E8000000 		call	Heap_INCREF@PLT
 215      00
  36:isptest.c     **** 	__MODULE_IMPORT(Texts);
 217              	.LM9:
 218 00a7 E8000000 		call	Texts__init@PLT
 218      00
 219 00ac 4889C7   		movq	%rax, %rdi
 220 00af B8000000 		movl	$0, %eax
 220      00
 221 00b4 E8000000 		call	Heap_INCREF@PLT
 221      00
  37:isptest.c     **** 	__REGMAIN("isptest", EnumPtrs);
 223              	.LM10:
 224 00b9 488D3540 		leaq	EnumPtrs(%rip), %rsi
 224      FFFFFF
 225 00c0 488D3D00 		leaq	.LC0(%rip), %rdi
 225      000000
 226 00c7 B8000000 		movl	$0, %eax
 226      00
 227 00cc E8000000 		call	Heap_REGMOD@PLT
 227      00
 228 00d1 48890500 		movq	%rax, m.2620(%rip)
 228      000000
  38:isptest.c     **** /* BEGIN */
  39:isptest.c     **** 	__NEW(isptest_T, Texts_TextDesc);
 230              	.LM11:
 231 00d8 488B0500 		movq	Texts_TextDesc__typ@GOTPCREL(%rip), %rax
 231      000000
 232 00df 488B00   		movq	(%rax), %rax
 233 00e2 4889C7   		movq	%rax, %rdi
 234 00e5 E8000000 		call	Heap_NEWREC@PLT
 234      00
 235 00ea 48890500 		movq	%rax, isptest_T(%rip)
 235      000000
  40:isptest.c     **** 	if (Files_Old((CHAR*)"isptest.mod", 12) != NIL) {
 237              	.LM12:
 238 00f1 BE0C0000 		movl	$12, %esi
 238      00
 239 00f6 488D3D00 		leaq	.LC1(%rip), %rdi
 239      000000
 240 00fd E8000000 		call	Files_Old@PLT
 240      00
 242              	.LM13:
 243 0102 4885C0   		testq	%rax, %rax
 244 0105 0F842F01 		je	.L3
 244      0000
  41:isptest.c     **** 		Texts_Open(isptest_T, (CHAR*)"isptest.mod", 12);
 246              	.LM14:
 247 010b 488B0500 		movq	isptest_T(%rip), %rax
 247      000000
 248 0112 BA0C0000 		movl	$12, %edx
 248      00
 249 0117 488D3500 		leaq	.LC1(%rip), %rsi
 249      000000
 250 011e 4889C7   		movq	%rax, %rdi
 251 0121 E8000000 		call	Texts_Open@PLT
 251      00
  42:isptest.c     **** 		Texts_OpenReader(&isptest_R, Texts_Reader__typ, isptest_T, 0);
 253              	.LM15:
 254 0126 488B1500 		movq	isptest_T(%rip), %rdx
 254      000000
 255 012d 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 255      000000
 256 0134 488B00   		movq	(%rax), %rax
 257 0137 B9000000 		movl	$0, %ecx
 257      00
 258 013c 4889C6   		movq	%rax, %rsi
 259 013f 488D3D00 		leaq	isptest_R(%rip), %rdi
 259      000000
 260 0146 E8000000 		call	Texts_OpenReader@PLT
 260      00
  43:isptest.c     **** 		Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
 262              	.LM16:
 263 014b 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 263      000000
 264 0152 488B00   		movq	(%rax), %rax
 265 0155 488D1500 		leaq	isptest_ch(%rip), %rdx
 265      000000
 266 015c 4889C6   		movq	%rax, %rsi
 267 015f 488D3D00 		leaq	isptest_R(%rip), %rdi
 267      000000
 268 0166 E8000000 		call	Texts_Read@PLT
 268      00
  44:isptest.c     **** 		while (!isptest_R.eot) {
 270              	.LM17:
 271 016b E9BB0000 		jmp	.L4
 271      00
 272              	.L5:
  45:isptest.c     **** 			Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
 274              	.LM18:
 275 0170 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 275      000000
 276 0177 488B00   		movq	(%rax), %rax
 277 017a 488D1500 		leaq	isptest_ch(%rip), %rdx
 277      000000
 278 0181 4889C6   		movq	%rax, %rsi
 279 0184 488D3D00 		leaq	isptest_R(%rip), %rdi
 279      000000
 280 018b E8000000 		call	Texts_Read@PLT
 280      00
  46:isptest.c     **** 			isptest_i = Texts_Pos(&isptest_R, Texts_Reader__typ);
 282              	.LM19:
 283 0190 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 283      000000
 284 0197 488B00   		movq	(%rax), %rax
 285 019a 4889C6   		movq	%rax, %rsi
 286 019d 488D3D00 		leaq	isptest_R(%rip), %rdi
 286      000000
 287 01a4 E8000000 		call	Texts_Pos@PLT
 287      00
 289              	.LM20:
 290 01a9 48890500 		movq	%rax, isptest_i(%rip)
 290      000000
  47:isptest.c     **** 			Out_String((CHAR*)"pos=", 5);
 292              	.LM21:
 293 01b0 BE050000 		movl	$5, %esi
 293      00
 294 01b5 488D3D00 		leaq	.LC2(%rip), %rdi
 294      000000
 295 01bc E8000000 		call	Out_String@PLT
 295      00
  48:isptest.c     **** 			Out_Int(isptest_i, 0);
 297              	.LM22:
 298 01c1 488B0500 		movq	isptest_i(%rip), %rax
 298      000000
 299 01c8 BE000000 		movl	$0, %esi
 299      00
 300 01cd 4889C7   		movq	%rax, %rdi
 301 01d0 E8000000 		call	Out_Int@PLT
 301      00
  49:isptest.c     **** 			Out_String((CHAR*)" char=", 7);
 303              	.LM23:
 304 01d5 BE070000 		movl	$7, %esi
 304      00
 305 01da 488D3D00 		leaq	.LC3(%rip), %rdi
 305      000000
 306 01e1 E8000000 		call	Out_String@PLT
 306      00
  50:isptest.c     **** 			Out_Char(isptest_ch);
 308              	.LM24:
 309 01e6 0FB60500 		movzbl	isptest_ch(%rip), %eax
 309      000000
 310 01ed 0FB6C0   		movzbl	%al, %eax
 311 01f0 89C7     		movl	%eax, %edi
 312 01f2 E8000000 		call	Out_Char@PLT
 312      00
  51:isptest.c     **** 			Out_Char(0x0a);
 314              	.LM25:
 315 01f7 BF0A0000 		movl	$10, %edi
 315      00
 316 01fc E8000000 		call	Out_Char@PLT
 316      00
  52:isptest.c     **** 			if (isptest_i == 21906) {
 318              	.LM26:
 319 0201 488B0500 		movq	isptest_i(%rip), %rax
 319      000000
 321              	.LM27:
 322 0208 483D9255 		cmpq	$21906, %rax
 322      0000
 323 020e 751B     		jne	.L4
  53:isptest.c     **** 				Out_String((CHAR*)"21906", 6);
 325              	.LM28:
 326 0210 BE060000 		movl	$6, %esi
 326      00
 327 0215 488D3D00 		leaq	.LC4(%rip), %rdi
 327      000000
 328 021c E8000000 		call	Out_String@PLT
 328      00
  54:isptest.c     **** 				Out_Char(0x0a);
 330              	.LM29:
 331 0221 BF0A0000 		movl	$10, %edi
 331      00
 332 0226 E8000000 		call	Out_Char@PLT
 332      00
 333              	.L4:
  44:isptest.c     **** 			Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
 335              	.LM30:
 336 022b 0FB60500 		movzbl	isptest_R(%rip), %eax
 336      000000
  44:isptest.c     **** 			Texts_Read(&isptest_R, Texts_Reader__typ, &isptest_ch);
 338              	.LM31:
 339 0232 84C0     		testb	%al, %al
 340 0234 0F8436FF 		je	.L5
 340      FFFF
 341              	.L3:
  55:isptest.c     **** 			}
  56:isptest.c     **** 		}
  57:isptest.c     **** 	}
  58:isptest.c     **** 	__FINI;
 343              	.LM32:
 344 023a B8000000 		movl	$0, %eax
 344      00
 345 023f E8000000 		call	Heap_FINALL@PLT
 345      00
 346 0244 B8000000 		movl	$0, %eax
 346      00
  59:isptest.c     **** }
 348              	.LM33:
 349 0249 C9       		leave
 350              		.cfi_def_cfa 7, 8
 351 024a C3       		ret
 352              		.cfi_endproc
 353              	.LFE8:
 358              	.Lscope2:
 360              		.stabd	78,0,0
 361              		.local	m.2620
 362              		.comm	m.2620,8,8
 365              	.Letext0:
 366              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 367              		.section	.note.GNU-stack,"",@progbits
 368              		.section	.note.gnu.property,"a"
 369              		.align 8
 370 0000 04000000 		.long	 1f - 0f
 371 0004 10000000 		.long	 4f - 1f
 372 0008 05000000 		.long	 5
 373              	0:
 374 000c 474E5500 		.string	 "GNU"
 375              	1:
 376              		.align 8
 377 0010 020000C0 		.long	 0xc0000002
 378 0014 04000000 		.long	 3f - 2f
 379              	2:
 380 0018 03000000 		.long	 0x3
 381              	3:
 382 001c 00000000 		.align 8
 383              	4:
