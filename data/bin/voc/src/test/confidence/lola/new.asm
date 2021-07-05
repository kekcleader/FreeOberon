   1              		.file	"Lola.c"
   4              		.text
   5              	.Ltext0:
  81              		.section	.rodata
  82              	.LC0:
  83 0000 4C6F6C61 		.string	"Lola"
  83      00
  84 0005 000000   		.align 8
  85              	.LC1:
  86 0008 4C6F6C61 		.string	"Lola - compile lola source to verilog source."
  86      202D2063 
  86      6F6D7069 
  86      6C65206C 
  86      6F6C6120 
  87              	.LC2:
  88 0036 75736167 		.string	"usage:"
  88      653A00
  89 003d 000000   		.align 8
  90              	.LC3:
  91 0040 20206C6F 		.string	"  lola lola-source-file verilog-source-file"
  91      6C61206C 
  91      6F6C612D 
  91      736F7572 
  91      63652D66 
  92              		.text
  96              		.globl	main
  98              	main:
  99              		.stabd	46,0,0
   1:Lola.c        **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:Lola.c        **** 
   3:Lola.c        **** #define SHORTINT INT8
   4:Lola.c        **** #define INTEGER  INT16
   5:Lola.c        **** #define LONGINT  INT32
   6:Lola.c        **** #define SET      UINT32
   7:Lola.c        **** 
   8:Lola.c        **** #include "SYSTEM.h"
   9:Lola.c        **** #include "Console.h"
  10:Lola.c        **** #include "LSB.h"
  11:Lola.c        **** #include "LSC.h"
  12:Lola.c        **** #include "LSV.h"
  13:Lola.c        **** #include "Modules.h"
  14:Lola.c        **** 
  15:Lola.c        **** 
  16:Lola.c        **** 
  17:Lola.c        **** 
  18:Lola.c        **** 
  19:Lola.c        **** 
  20:Lola.c        **** 
  21:Lola.c        **** export int main(int argc, char **argv)
  22:Lola.c        **** {
 101              	.LM0:
 102              	.LFBB1:
 103              	.LFB7:
 104              		.cfi_startproc
 105 0000 F30F1EFA 		endbr64
 106 0004 55       		pushq	%rbp
 107              		.cfi_def_cfa_offset 16
 108              		.cfi_offset 6, -16
 109 0005 4889E5   		movq	%rsp, %rbp
 110              		.cfi_def_cfa_register 6
 111 0008 4883EC10 		subq	$16, %rsp
 112 000c 897DFC   		movl	%edi, -4(%rbp)
 113 000f 488975F0 		movq	%rsi, -16(%rbp)
  23:Lola.c        **** 	__INIT(argc, argv);
 115              	.LM1:
 116 0013 488D55F0 		leaq	-16(%rbp), %rdx
 117 0017 8B45FC   		movl	-4(%rbp), %eax
 118 001a 4889D6   		movq	%rdx, %rsi
 119 001d 89C7     		movl	%eax, %edi
 120 001f E8000000 		call	Modules_Init@PLT
 120      00
  24:Lola.c        **** 	__MODULE_IMPORT(Console);
 122              	.LM2:
 123 0024 E8000000 		call	Console__init@PLT
 123      00
 124 0029 4889C7   		movq	%rax, %rdi
 125 002c E8000000 		call	Heap_INCREF@PLT
 125      00
  25:Lola.c        **** 	__MODULE_IMPORT(LSB);
 127              	.LM3:
 128 0031 E8000000 		call	LSB__init@PLT
 128      00
 129 0036 4889C7   		movq	%rax, %rdi
 130 0039 E8000000 		call	Heap_INCREF@PLT
 130      00
  26:Lola.c        **** 	__MODULE_IMPORT(LSC);
 132              	.LM4:
 133 003e E8000000 		call	LSC__init@PLT
 133      00
 134 0043 4889C7   		movq	%rax, %rdi
 135 0046 E8000000 		call	Heap_INCREF@PLT
 135      00
  27:Lola.c        **** 	__MODULE_IMPORT(LSV);
 137              	.LM5:
 138 004b E8000000 		call	LSV__init@PLT
 138      00
 139 0050 4889C7   		movq	%rax, %rdi
 140 0053 E8000000 		call	Heap_INCREF@PLT
 140      00
  28:Lola.c        **** 	__MODULE_IMPORT(Modules);
 142              	.LM6:
 143 0058 E8000000 		call	Modules__init@PLT
 143      00
 144 005d 4889C7   		movq	%rax, %rdi
 145 0060 E8000000 		call	Heap_INCREF@PLT
 145      00
  29:Lola.c        **** 	__REGMAIN("Lola", 0);
 147              	.LM7:
 148 0065 BE000000 		movl	$0, %esi
 148      00
 149 006a 488D3D00 		leaq	.LC0(%rip), %rdi
 149      000000
 150 0071 E8000000 		call	Heap_REGMOD@PLT
 150      00
 151 0076 48890500 		movq	%rax, m.2217(%rip)
 151      000000
  30:Lola.c        **** /* BEGIN */
  31:Lola.c        **** 	if (Modules_ArgCount < 3) {
 153              	.LM8:
 154 007d 488B0500 		movq	Modules_ArgCount@GOTPCREL(%rip), %rax
 154      000000
 155 0084 0FB700   		movzwl	(%rax), %eax
 157              	.LM9:
 158 0087 6683F802 		cmpw	$2, %ax
 159 008b 7F53     		jg	.L2
  32:Lola.c        **** 		Console_String((CHAR*)"Lola - compile lola source to verilog source.", 46);
 161              	.LM10:
 162 008d BE2E0000 		movl	$46, %esi
 162      00
 163 0092 488D3D00 		leaq	.LC1(%rip), %rdi
 163      000000
 164 0099 E8000000 		call	Console_String@PLT
 164      00
  33:Lola.c        **** 		Console_Ln();
 166              	.LM11:
 167 009e E8000000 		call	Console_Ln@PLT
 167      00
  34:Lola.c        **** 		Console_Ln();
 169              	.LM12:
 170 00a3 E8000000 		call	Console_Ln@PLT
 170      00
  35:Lola.c        **** 		Console_String((CHAR*)"usage:", 7);
 172              	.LM13:
 173 00a8 BE070000 		movl	$7, %esi
 173      00
 174 00ad 488D3D00 		leaq	.LC2(%rip), %rdi
 174      000000
 175 00b4 E8000000 		call	Console_String@PLT
 175      00
  36:Lola.c        **** 		Console_Ln();
 177              	.LM14:
 178 00b9 E8000000 		call	Console_Ln@PLT
 178      00
  37:Lola.c        **** 		Console_Ln();
 180              	.LM15:
 181 00be E8000000 		call	Console_Ln@PLT
 181      00
  38:Lola.c        **** 		Console_String((CHAR*)"  lola lola-source-file verilog-source-file", 44);
 183              	.LM16:
 184 00c3 BE2C0000 		movl	$44, %esi
 184      00
 185 00c8 488D3D00 		leaq	.LC3(%rip), %rdi
 185      000000
 186 00cf E8000000 		call	Console_String@PLT
 186      00
  39:Lola.c        **** 		Console_Ln();
 188              	.LM17:
 189 00d4 E8000000 		call	Console_Ln@PLT
 189      00
  40:Lola.c        **** 		Console_Ln();
 191              	.LM18:
 192 00d9 E8000000 		call	Console_Ln@PLT
 192      00
 193 00de EB18     		jmp	.L3
 194              	.L2:
  41:Lola.c        **** 	} else {
  42:Lola.c        **** 		LSC_Compile();
 196              	.LM19:
 197 00e0 E8000000 		call	LSC_Compile@PLT
 197      00
  43:Lola.c        **** 		if (LSB_modname[0] != 0x00) {
 199              	.LM20:
 200 00e5 488B0500 		movq	LSB_modname@GOTPCREL(%rip), %rax
 200      000000
 201 00ec 0FB600   		movzbl	(%rax), %eax
 203              	.LM21:
 204 00ef 84C0     		testb	%al, %al
 205 00f1 7405     		je	.L3
  44:Lola.c        **** 			LSV_List();
 207              	.LM22:
 208 00f3 E8000000 		call	LSV_List@PLT
 208      00
 209              	.L3:
  45:Lola.c        **** 		}
  46:Lola.c        **** 	}
  47:Lola.c        **** 	__FINI;
 211              	.LM23:
 212 00f8 E8000000 		call	Heap_FINALL@PLT
 212      00
 213 00fd B8000000 		movl	$0, %eax
 213      00
  48:Lola.c        **** }
 215              	.LM24:
 216 0102 C9       		leave
 217              		.cfi_def_cfa 7, 8
 218 0103 C3       		ret
 219              		.cfi_endproc
 220              	.LFE7:
 225              	.Lscope1:
 227              		.stabd	78,0,0
 228              		.local	m.2217
 229              		.comm	m.2217,8,8
 232              	.Letext0:
 233              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 234              		.section	.note.GNU-stack,"",@progbits
 235              		.section	.note.gnu.property,"a"
 236              		.align 8
 237 0000 04000000 		.long	 1f - 0f
 238 0004 10000000 		.long	 4f - 1f
 239 0008 05000000 		.long	 5
 240              	0:
 241 000c 474E5500 		.string	 "GNU"
 242              	1:
 243              		.align 8
 244 0010 020000C0 		.long	 0xc0000002
 245 0014 04000000 		.long	 3f - 2f
 246              	2:
 247 0018 03000000 		.long	 0x3
 248              	3:
 249 001c 00000000 		.align 8
 250              	4:
