   1              		.file	"aa.c"
   4              		.text
   5              	.Ltext0:
  49              		.local	aa_a30
  50              		.comm	aa_a30,30,16
  52              		.local	aa_a10
  53              		.comm	aa_a10,10,8
  55              		.local	aa_a20
  56              		.comm	aa_a20,20,16
  58              		.local	aa_buf
  59              		.comm	aa_buf,64,32
  61              		.section	.rodata
  62              	.LC0:
  63 0000 616100   		.string	"aa"
  64              	.LC1:
  65 0003 6133303A 		.string	"a30: "
  65      2000
  66              	.LC2:
  67 0009 6132303A 		.string	"a20: "
  67      2000
  68              	.LC3:
  69 000f 6131303A 		.string	"a10: "
  69      2000
  70 0015 000000   		.align 8
  71              	.LC4:
  72 0018 41727261 		.string	"Array assignment test complete."
  72      79206173 
  72      7369676E 
  72      6D656E74 
  72      20746573 
  73              		.text
  77              		.globl	main
  79              	main:
  80              		.stabd	46,0,0
   1:aa.c          **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:aa.c          **** 
   3:aa.c          **** #define SHORTINT INT8
   4:aa.c          **** #define INTEGER  INT16
   5:aa.c          **** #define LONGINT  INT32
   6:aa.c          **** #define SET      UINT32
   7:aa.c          **** 
   8:aa.c          **** #include "SYSTEM.h"
   9:aa.c          **** #include "Console.h"
  10:aa.c          **** 
  11:aa.c          **** 
  12:aa.c          **** static CHAR aa_a30[30];
  13:aa.c          **** static CHAR aa_a10[10];
  14:aa.c          **** static CHAR aa_a20[20];
  15:aa.c          **** static CHAR aa_buf[64];
  16:aa.c          **** 
  17:aa.c          **** 
  18:aa.c          **** 
  19:aa.c          **** 
  20:aa.c          **** 
  21:aa.c          **** export int main(int argc, char **argv)
  22:aa.c          **** {
  82              	.LM0:
  83              	.LFBB1:
  84              	.LFB7:
  85              		.cfi_startproc
  86 0000 F30F1EFA 		endbr64
  87 0004 55       		pushq	%rbp
  88              		.cfi_def_cfa_offset 16
  89              		.cfi_offset 6, -16
  90 0005 4889E5   		movq	%rsp, %rbp
  91              		.cfi_def_cfa_register 6
  92 0008 4883EC40 		subq	$64, %rsp
  93 000c 897DCC   		movl	%edi, -52(%rbp)
  94 000f 488975C0 		movq	%rsi, -64(%rbp)
  23:aa.c          **** 	__INIT(argc, argv);
  96              	.LM1:
  97 0013 488D55C0 		leaq	-64(%rbp), %rdx
  98 0017 8B45CC   		movl	-52(%rbp), %eax
  99 001a 4889D6   		movq	%rdx, %rsi
 100 001d 89C7     		movl	%eax, %edi
 101 001f E8000000 		call	Modules_Init@PLT
 101      00
  24:aa.c          **** 	__MODULE_IMPORT(Console);
 103              	.LM2:
 104 0024 E8000000 		call	Console__init@PLT
 104      00
 105 0029 4889C7   		movq	%rax, %rdi
 106 002c B8000000 		movl	$0, %eax
 106      00
 107 0031 E8000000 		call	Heap_INCREF@PLT
 107      00
  25:aa.c          **** 	__REGMAIN("aa", 0);
 109              	.LM3:
 110 0036 BE000000 		movl	$0, %esi
 110      00
 111 003b 488D3D00 		leaq	.LC0(%rip), %rdi
 111      000000
 112 0042 B8000000 		movl	$0, %eax
 112      00
 113 0047 E8000000 		call	Heap_REGMOD@PLT
 113      00
 114 004c 48890500 		movq	%rax, m.2042(%rip)
 114      000000
  26:aa.c          **** /* BEGIN */
  27:aa.c          **** 	__MOVE("1st 10 ch 2nd 10 ch 3rd 10 ch", aa_a30, 30);
 116              	.LM4:
 117 0053 48B83173 		movabsq	$7142761996565639985, %rax
 117      74203130 
 117      2063
 118 005d 48BA6820 		movabsq	$3472592403396960360, %rdx
 118      326E6420 
 118      3130
 119 0067 48890500 		movq	%rax, aa_a30(%rip)
 119      000000
 120 006e 48891500 		movq	%rdx, 8+aa_a30(%rip)
 120      000000
 121 0075 48B82063 		movabsq	$2334116070797370144, %rax
 121      68203372 
 121      6420
 122 007f 48890500 		movq	%rax, 16+aa_a30(%rip)
 122      000000
 123 0086 C7050000 		movl	$1663053873, 24+aa_a30(%rip)
 123      00003130 
 123      2063
 124 0090 66C70500 		movw	$104, 28+aa_a30(%rip)
 124      00000068 
 124      00
  28:aa.c          **** 	Console_String((CHAR*)"a30: ", 6);
 126              	.LM5:
 127 0099 BE060000 		movl	$6, %esi
 127      00
 128 009e 488D3D00 		leaq	.LC1(%rip), %rdi
 128      000000
 129 00a5 E8000000 		call	Console_String@PLT
 129      00
  29:aa.c          **** 	Console_String(aa_a30, 30);
 131              	.LM6:
 132 00aa BE1E0000 		movl	$30, %esi
 132      00
 133 00af 488D3D00 		leaq	aa_a30(%rip), %rdi
 133      000000
 134 00b6 E8000000 		call	Console_String@PLT
 134      00
  30:aa.c          **** 	Console_Ln();
 136              	.LM7:
 137 00bb E8000000 		call	Console_Ln@PLT
 137      00
  31:aa.c          **** 	__COPY(aa_a30, aa_a20, 20);
 139              	.LM8:
 140 00c0 488D0500 		leaq	aa_a30(%rip), %rax
 140      000000
 141 00c7 488945E0 		movq	%rax, -32(%rbp)
 142 00cb 488D0500 		leaq	aa_a20(%rip), %rax
 142      000000
 143 00d2 488945E8 		movq	%rax, -24(%rbp)
 144 00d6 C745D000 		movl	$0, -48(%rbp)
 144      000000
 145 00dd C745D813 		movl	$19, -40(%rbp)
 145      000000
 146 00e4 EB04     		jmp	.L2
 147              	.L4:
 149              	.LM9:
 150 00e6 8345D001 		addl	$1, -48(%rbp)
 151              	.L2:
 153              	.LM10:
 154 00ea 8B45D0   		movl	-48(%rbp), %eax
 155 00ed 3B45D8   		cmpl	-40(%rbp), %eax
 156 00f0 7D26     		jge	.L3
 158              	.LM11:
 159 00f2 8B45D0   		movl	-48(%rbp), %eax
 160 00f5 4863D0   		movslq	%eax, %rdx
 161 00f8 488B45E0 		movq	-32(%rbp), %rax
 162 00fc 4801C2   		addq	%rax, %rdx
 163 00ff 8B45D0   		movl	-48(%rbp), %eax
 164 0102 4863C8   		movslq	%eax, %rcx
 165 0105 488B45E8 		movq	-24(%rbp), %rax
 166 0109 4801C8   		addq	%rcx, %rax
 167 010c 0FB612   		movzbl	(%rdx), %edx
 168 010f 8810     		movb	%dl, (%rax)
 169 0111 0FB600   		movzbl	(%rax), %eax
 170 0114 84C0     		testb	%al, %al
 171 0116 75CE     		jne	.L4
 172              	.L3:
 174              	.LM12:
 175 0118 8B45D0   		movl	-48(%rbp), %eax
 176 011b 4863D0   		movslq	%eax, %rdx
 177 011e 488B45E8 		movq	-24(%rbp), %rax
 178 0122 4801D0   		addq	%rdx, %rax
 179 0125 C60000   		movb	$0, (%rax)
  32:aa.c          **** 	Console_String((CHAR*)"a20: ", 6);
 181              	.LM13:
 182 0128 BE060000 		movl	$6, %esi
 182      00
 183 012d 488D3D00 		leaq	.LC2(%rip), %rdi
 183      000000
 184 0134 E8000000 		call	Console_String@PLT
 184      00
  33:aa.c          **** 	Console_String(aa_a20, 20);
 186              	.LM14:
 187 0139 BE140000 		movl	$20, %esi
 187      00
 188 013e 488D3D00 		leaq	aa_a20(%rip), %rdi
 188      000000
 189 0145 E8000000 		call	Console_String@PLT
 189      00
  34:aa.c          **** 	Console_Ln();
 191              	.LM15:
 192 014a E8000000 		call	Console_Ln@PLT
 192      00
  35:aa.c          **** 	Console_Ln();
 194              	.LM16:
 195 014f E8000000 		call	Console_Ln@PLT
 195      00
  36:aa.c          **** 	__COPY(aa_a30, aa_a10, 10);
 197              	.LM17:
 198 0154 488D0500 		leaq	aa_a30(%rip), %rax
 198      000000
 199 015b 488945F0 		movq	%rax, -16(%rbp)
 200 015f 488D0500 		leaq	aa_a10(%rip), %rax
 200      000000
 201 0166 488945F8 		movq	%rax, -8(%rbp)
 202 016a C745D400 		movl	$0, -44(%rbp)
 202      000000
 203 0171 C745DC09 		movl	$9, -36(%rbp)
 203      000000
 204 0178 EB04     		jmp	.L5
 205              	.L7:
 207              	.LM18:
 208 017a 8345D401 		addl	$1, -44(%rbp)
 209              	.L5:
 211              	.LM19:
 212 017e 8B45D4   		movl	-44(%rbp), %eax
 213 0181 3B45DC   		cmpl	-36(%rbp), %eax
 214 0184 7D26     		jge	.L6
 216              	.LM20:
 217 0186 8B45D4   		movl	-44(%rbp), %eax
 218 0189 4863D0   		movslq	%eax, %rdx
 219 018c 488B45F0 		movq	-16(%rbp), %rax
 220 0190 4801C2   		addq	%rax, %rdx
 221 0193 8B45D4   		movl	-44(%rbp), %eax
 222 0196 4863C8   		movslq	%eax, %rcx
 223 0199 488B45F8 		movq	-8(%rbp), %rax
 224 019d 4801C8   		addq	%rcx, %rax
 225 01a0 0FB612   		movzbl	(%rdx), %edx
 226 01a3 8810     		movb	%dl, (%rax)
 227 01a5 0FB600   		movzbl	(%rax), %eax
 228 01a8 84C0     		testb	%al, %al
 229 01aa 75CE     		jne	.L7
 230              	.L6:
 232              	.LM21:
 233 01ac 8B45D4   		movl	-44(%rbp), %eax
 234 01af 4863D0   		movslq	%eax, %rdx
 235 01b2 488B45F8 		movq	-8(%rbp), %rax
 236 01b6 4801D0   		addq	%rdx, %rax
 237 01b9 C60000   		movb	$0, (%rax)
  37:aa.c          **** 	Console_String((CHAR*)"a10: ", 6);
 239              	.LM22:
 240 01bc BE060000 		movl	$6, %esi
 240      00
 241 01c1 488D3D00 		leaq	.LC3(%rip), %rdi
 241      000000
 242 01c8 E8000000 		call	Console_String@PLT
 242      00
  38:aa.c          **** 	Console_String(aa_a10, 10);
 244              	.LM23:
 245 01cd BE0A0000 		movl	$10, %esi
 245      00
 246 01d2 488D3D00 		leaq	aa_a10(%rip), %rdi
 246      000000
 247 01d9 E8000000 		call	Console_String@PLT
 247      00
  39:aa.c          **** 	Console_Ln();
 249              	.LM24:
 250 01de E8000000 		call	Console_Ln@PLT
 250      00
  40:aa.c          **** 	Console_String((CHAR*)"a20: ", 6);
 252              	.LM25:
 253 01e3 BE060000 		movl	$6, %esi
 253      00
 254 01e8 488D3D00 		leaq	.LC2(%rip), %rdi
 254      000000
 255 01ef E8000000 		call	Console_String@PLT
 255      00
  41:aa.c          **** 	Console_String(aa_a20, 20);
 257              	.LM26:
 258 01f4 BE140000 		movl	$20, %esi
 258      00
 259 01f9 488D3D00 		leaq	aa_a20(%rip), %rdi
 259      000000
 260 0200 E8000000 		call	Console_String@PLT
 260      00
  42:aa.c          **** 	Console_Ln();
 262              	.LM27:
 263 0205 E8000000 		call	Console_Ln@PLT
 263      00
  43:aa.c          **** 	Console_Ln();
 265              	.LM28:
 266 020a E8000000 		call	Console_Ln@PLT
 266      00
  44:aa.c          **** 	Console_String((CHAR*)"Array assignment test complete.", 32);
 268              	.LM29:
 269 020f BE200000 		movl	$32, %esi
 269      00
 270 0214 488D3D00 		leaq	.LC4(%rip), %rdi
 270      000000
 271 021b E8000000 		call	Console_String@PLT
 271      00
  45:aa.c          **** 	Console_Ln();
 273              	.LM30:
 274 0220 E8000000 		call	Console_Ln@PLT
 274      00
  46:aa.c          **** 	__FINI;
 276              	.LM31:
 277 0225 B8000000 		movl	$0, %eax
 277      00
 278 022a E8000000 		call	Heap_FINALL@PLT
 278      00
 279 022f B8000000 		movl	$0, %eax
 279      00
  47:aa.c          **** }
 281              	.LM32:
 282 0234 C9       		leave
 283              		.cfi_def_cfa 7, 8
 284 0235 C3       		ret
 285              		.cfi_endproc
 286              	.LFE7:
 291              	.Lscope1:
 293              		.stabd	78,0,0
 294              		.local	m.2042
 295              		.comm	m.2042,8,8
 298              	.Letext0:
 299              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 300              		.section	.note.GNU-stack,"",@progbits
 301              		.section	.note.gnu.property,"a"
 302              		.align 8
 303 0000 04000000 		.long	 1f - 0f
 304 0004 10000000 		.long	 4f - 1f
 305 0008 05000000 		.long	 5
 306              	0:
 307 000c 474E5500 		.string	 "GNU"
 308              	1:
 309              		.align 8
 310 0010 020000C0 		.long	 0xc0000002
 311 0014 04000000 		.long	 3f - 2f
 312              	2:
 313 0018 03000000 		.long	 0x3
 314              	3:
 315 001c 00000000 		.align 8
 316              	4:
