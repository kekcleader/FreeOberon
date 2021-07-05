   1              		.file	"intest.c"
   4              		.text
   5              	.Ltext0:
  49              		.local	intest_ch
  50              		.comm	intest_ch,1,1
  52              		.local	intest_i
  53              		.comm	intest_i,4,4
  55              		.local	intest_s
  56              		.comm	intest_s,100,32
  58              		.section	.rodata
  59              	.LC0:
  60 0000 696E7465 		.string	"intest"
  60      737400
  61              	.LC1:
  62 0007 63686172 		.string	"chars:   "
  62      733A2020 
  62      2000
  63              	.LC2:
  64 0011 696E7465 		.string	"integer: "
  64      6765723A 
  64      2000
  65              	.LC3:
  66 001b 73747269 		.string	"string:  \""
  66      6E673A20 
  66      202200
  67              	.LC4:
  68 0026 2200     		.string	"\""
  69              	.LC5:
  70 0028 6C696E65 		.string	"line:    "
  70      3A202020 
  70      2000
  71              		.text
  75              		.globl	main
  77              	main:
  78              		.stabd	46,0,0
   1:intest.c      **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:intest.c      **** 
   3:intest.c      **** #define SHORTINT INT16
   4:intest.c      **** #define INTEGER  INT32
   5:intest.c      **** #define LONGINT  INT64
   6:intest.c      **** #define SET      UINT32
   7:intest.c      **** 
   8:intest.c      **** #include "SYSTEM.h"
   9:intest.c      **** #include "In.h"
  10:intest.c      **** #include "Out.h"
  11:intest.c      **** 
  12:intest.c      **** 
  13:intest.c      **** static CHAR intest_ch;
  14:intest.c      **** static INT32 intest_i;
  15:intest.c      **** static CHAR intest_s[100];
  16:intest.c      **** 
  17:intest.c      **** 
  18:intest.c      **** 
  19:intest.c      **** 
  20:intest.c      **** 
  21:intest.c      **** export int main(int argc, char **argv)
  22:intest.c      **** {
  80              	.LM0:
  81              	.LFBB1:
  82              	.LFB7:
  83              		.cfi_startproc
  84 0000 F30F1EFA 		endbr64
  85 0004 55       		pushq	%rbp
  86              		.cfi_def_cfa_offset 16
  87              		.cfi_offset 6, -16
  88 0005 4889E5   		movq	%rsp, %rbp
  89              		.cfi_def_cfa_register 6
  90 0008 4883EC10 		subq	$16, %rsp
  91 000c 897DFC   		movl	%edi, -4(%rbp)
  92 000f 488975F0 		movq	%rsi, -16(%rbp)
  23:intest.c      **** 	__INIT(argc, argv);
  94              	.LM1:
  95 0013 488D55F0 		leaq	-16(%rbp), %rdx
  96 0017 8B45FC   		movl	-4(%rbp), %eax
  97 001a 4889D6   		movq	%rdx, %rsi
  98 001d 89C7     		movl	%eax, %edi
  99 001f E8000000 		call	Modules_Init@PLT
  99      00
  24:intest.c      **** 	__MODULE_IMPORT(In);
 101              	.LM2:
 102 0024 E8000000 		call	In__init@PLT
 102      00
 103 0029 4889C7   		movq	%rax, %rdi
 104 002c B8000000 		movl	$0, %eax
 104      00
 105 0031 E8000000 		call	Heap_INCREF@PLT
 105      00
  25:intest.c      **** 	__MODULE_IMPORT(Out);
 107              	.LM3:
 108 0036 E8000000 		call	Out__init@PLT
 108      00
 109 003b 4889C7   		movq	%rax, %rdi
 110 003e B8000000 		movl	$0, %eax
 110      00
 111 0043 E8000000 		call	Heap_INCREF@PLT
 111      00
  26:intest.c      **** 	__REGMAIN("intest", 0);
 113              	.LM4:
 114 0048 BE000000 		movl	$0, %esi
 114      00
 115 004d 488D3D00 		leaq	.LC0(%rip), %rdi
 115      000000
 116 0054 B8000000 		movl	$0, %eax
 116      00
 117 0059 E8000000 		call	Heap_REGMOD@PLT
 117      00
 118 005e 48890500 		movq	%rax, m.2083(%rip)
 118      000000
  27:intest.c      **** /* BEGIN */
  28:intest.c      **** 	In_Char(&intest_ch);
 120              	.LM5:
 121 0065 488D3D00 		leaq	intest_ch(%rip), %rdi
 121      000000
 122 006c E8000000 		call	In_Char@PLT
 122      00
  29:intest.c      **** 	Out_String((CHAR*)"chars:   ", 10);
 124              	.LM6:
 125 0071 BE0A0000 		movl	$10, %esi
 125      00
 126 0076 488D3D00 		leaq	.LC1(%rip), %rdi
 126      000000
 127 007d E8000000 		call	Out_String@PLT
 127      00
  30:intest.c      **** 	while ((In_Done && intest_ch != '.')) {
 129              	.LM7:
 130 0082 EB1D     		jmp	.L2
 131              	.L4:
  31:intest.c      **** 		Out_Char(intest_ch);
 133              	.LM8:
 134 0084 0FB60500 		movzbl	intest_ch(%rip), %eax
 134      000000
 135 008b 0FB6C0   		movzbl	%al, %eax
 136 008e 89C7     		movl	%eax, %edi
 137 0090 E8000000 		call	Out_Char@PLT
 137      00
  32:intest.c      **** 		In_Char(&intest_ch);
 139              	.LM9:
 140 0095 488D3D00 		leaq	intest_ch(%rip), %rdi
 140      000000
 141 009c E8000000 		call	In_Char@PLT
 141      00
 142              	.L2:
  30:intest.c      **** 	while ((In_Done && intest_ch != '.')) {
 144              	.LM10:
 145 00a1 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 145      000000
 146 00a8 0FB600   		movzbl	(%rax), %eax
  30:intest.c      **** 	while ((In_Done && intest_ch != '.')) {
 148              	.LM11:
 149 00ab 84C0     		testb	%al, %al
 150 00ad 740B     		je	.L3
  30:intest.c      **** 	while ((In_Done && intest_ch != '.')) {
 152              	.LM12:
 153 00af 0FB60500 		movzbl	intest_ch(%rip), %eax
 153      000000
  30:intest.c      **** 	while ((In_Done && intest_ch != '.')) {
 155              	.LM13:
 156 00b6 3C2E     		cmpb	$46, %al
 157 00b8 75CA     		jne	.L4
 158              	.L3:
  33:intest.c      **** 	}
  34:intest.c      **** 	Out_Ln();
 160              	.LM14:
 161 00ba E8000000 		call	Out_Ln@PLT
 161      00
  35:intest.c      **** 	In_Int(&intest_i);
 163              	.LM15:
 164 00bf 488D3D00 		leaq	intest_i(%rip), %rdi
 164      000000
 165 00c6 E8000000 		call	In_Int@PLT
 165      00
  36:intest.c      **** 	if (In_Done) {
 167              	.LM16:
 168 00cb 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 168      000000
 169 00d2 0FB600   		movzbl	(%rax), %eax
 171              	.LM17:
 172 00d5 84C0     		testb	%al, %al
 173 00d7 742B     		je	.L5
  37:intest.c      **** 		Out_String((CHAR*)"integer: ", 10);
 175              	.LM18:
 176 00d9 BE0A0000 		movl	$10, %esi
 176      00
 177 00de 488D3D00 		leaq	.LC2(%rip), %rdi
 177      000000
 178 00e5 E8000000 		call	Out_String@PLT
 178      00
  38:intest.c      **** 		Out_Int(intest_i, 1);
 180              	.LM19:
 181 00ea 8B050000 		movl	intest_i(%rip), %eax
 181      0000
 182 00f0 4898     		cltq
 183 00f2 BE010000 		movl	$1, %esi
 183      00
 184 00f7 4889C7   		movq	%rax, %rdi
 185 00fa E8000000 		call	Out_Int@PLT
 185      00
  39:intest.c      **** 		Out_Ln();
 187              	.LM20:
 188 00ff E8000000 		call	Out_Ln@PLT
 188      00
 189              	.L5:
  40:intest.c      **** 	}
  41:intest.c      **** 	In_String((void*)intest_s, 100);
 191              	.LM21:
 192 0104 BE640000 		movl	$100, %esi
 192      00
 193 0109 488D3D00 		leaq	intest_s(%rip), %rdi
 193      000000
 194 0110 E8000000 		call	In_String@PLT
 194      00
  42:intest.c      **** 	if (In_Done) {
 196              	.LM22:
 197 0115 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 197      000000
 198 011c 0FB600   		movzbl	(%rax), %eax
 200              	.LM23:
 201 011f 84C0     		testb	%al, %al
 202 0121 7438     		je	.L6
  43:intest.c      **** 		Out_String((CHAR*)"string:  \"", 11);
 204              	.LM24:
 205 0123 BE0B0000 		movl	$11, %esi
 205      00
 206 0128 488D3D00 		leaq	.LC3(%rip), %rdi
 206      000000
 207 012f E8000000 		call	Out_String@PLT
 207      00
  44:intest.c      **** 		Out_String(intest_s, 100);
 209              	.LM25:
 210 0134 BE640000 		movl	$100, %esi
 210      00
 211 0139 488D3D00 		leaq	intest_s(%rip), %rdi
 211      000000
 212 0140 E8000000 		call	Out_String@PLT
 212      00
  45:intest.c      **** 		Out_String((CHAR*)"\"", 2);
 214              	.LM26:
 215 0145 BE020000 		movl	$2, %esi
 215      00
 216 014a 488D3D00 		leaq	.LC4(%rip), %rdi
 216      000000
 217 0151 E8000000 		call	Out_String@PLT
 217      00
  46:intest.c      **** 		Out_Ln();
 219              	.LM27:
 220 0156 E8000000 		call	Out_Ln@PLT
 220      00
 221              	.L6:
  47:intest.c      **** 	}
  48:intest.c      **** 	In_Line((void*)intest_s, 100);
 223              	.LM28:
 224 015b BE640000 		movl	$100, %esi
 224      00
 225 0160 488D3D00 		leaq	intest_s(%rip), %rdi
 225      000000
 226 0167 E8000000 		call	In_Line@PLT
 226      00
  49:intest.c      **** 	while (In_Done) {
 228              	.LM29:
 229 016c EB38     		jmp	.L7
 230              	.L8:
  50:intest.c      **** 		Out_String((CHAR*)"line:    ", 10);
 232              	.LM30:
 233 016e BE0A0000 		movl	$10, %esi
 233      00
 234 0173 488D3D00 		leaq	.LC5(%rip), %rdi
 234      000000
 235 017a E8000000 		call	Out_String@PLT
 235      00
  51:intest.c      **** 		Out_String(intest_s, 100);
 237              	.LM31:
 238 017f BE640000 		movl	$100, %esi
 238      00
 239 0184 488D3D00 		leaq	intest_s(%rip), %rdi
 239      000000
 240 018b E8000000 		call	Out_String@PLT
 240      00
  52:intest.c      **** 		Out_Ln();
 242              	.LM32:
 243 0190 E8000000 		call	Out_Ln@PLT
 243      00
  53:intest.c      **** 		In_Line((void*)intest_s, 100);
 245              	.LM33:
 246 0195 BE640000 		movl	$100, %esi
 246      00
 247 019a 488D3D00 		leaq	intest_s(%rip), %rdi
 247      000000
 248 01a1 E8000000 		call	In_Line@PLT
 248      00
 249              	.L7:
  49:intest.c      **** 		Out_String((CHAR*)"line:    ", 10);
 251              	.LM34:
 252 01a6 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 252      000000
 253 01ad 0FB600   		movzbl	(%rax), %eax
  49:intest.c      **** 		Out_String((CHAR*)"line:    ", 10);
 255              	.LM35:
 256 01b0 84C0     		testb	%al, %al
 257 01b2 75BA     		jne	.L8
  54:intest.c      **** 	}
  55:intest.c      **** 	__FINI;
 259              	.LM36:
 260 01b4 B8000000 		movl	$0, %eax
 260      00
 261 01b9 E8000000 		call	Heap_FINALL@PLT
 261      00
 262 01be B8000000 		movl	$0, %eax
 262      00
  56:intest.c      **** }
 264              	.LM37:
 265 01c3 C9       		leave
 266              		.cfi_def_cfa 7, 8
 267 01c4 C3       		ret
 268              		.cfi_endproc
 269              	.LFE7:
 274              	.Lscope1:
 276              		.stabd	78,0,0
 277              		.local	m.2083
 278              		.comm	m.2083,8,8
 281              	.Letext0:
 282              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 283              		.section	.note.GNU-stack,"",@progbits
 284              		.section	.note.gnu.property,"a"
 285              		.align 8
 286 0000 04000000 		.long	 1f - 0f
 287 0004 10000000 		.long	 4f - 1f
 288 0008 05000000 		.long	 5
 289              	0:
 290 000c 474E5500 		.string	 "GNU"
 291              	1:
 292              		.align 8
 293 0010 020000C0 		.long	 0xc0000002
 294 0014 04000000 		.long	 3f - 2f
 295              	2:
 296 0018 03000000 		.long	 0x3
 297              	3:
 298 001c 00000000 		.align 8
 299              	4:
