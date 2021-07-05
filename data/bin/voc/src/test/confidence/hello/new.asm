   1              		.file	"hello.c"
   4              		.text
   5              	.Ltext0:
  49              		.section	.rodata
  50              	.LC0:
  51 0000 68656C6C 		.string	"hello"
  51      6F00
  52              	.LC1:
  53 0006 48656C6C 		.string	"Hello."
  53      6F2E00
  54              		.text
  58              		.globl	main
  60              	main:
  61              		.stabd	46,0,0
   1:hello.c       **** /* voc 2.1.0 [2021/07/05] for gcc LP64 on ubuntu xtpam */
   2:hello.c       **** 
   3:hello.c       **** #define SHORTINT INT8
   4:hello.c       **** #define INTEGER  INT16
   5:hello.c       **** #define LONGINT  INT32
   6:hello.c       **** #define SET      UINT32
   7:hello.c       **** 
   8:hello.c       **** #include "SYSTEM.h"
   9:hello.c       **** #include "Console.h"
  10:hello.c       **** 
  11:hello.c       **** 
  12:hello.c       **** 
  13:hello.c       **** 
  14:hello.c       **** 
  15:hello.c       **** 
  16:hello.c       **** 
  17:hello.c       **** export int main(int argc, char **argv)
  18:hello.c       **** {
  63              	.LM0:
  64              	.LFBB1:
  65              	.LFB7:
  66              		.cfi_startproc
  67 0000 F30F1EFA 		endbr64
  68 0004 55       		pushq	%rbp
  69              		.cfi_def_cfa_offset 16
  70              		.cfi_offset 6, -16
  71 0005 4889E5   		movq	%rsp, %rbp
  72              		.cfi_def_cfa_register 6
  73 0008 4883EC10 		subq	$16, %rsp
  74 000c 897DFC   		movl	%edi, -4(%rbp)
  75 000f 488975F0 		movq	%rsi, -16(%rbp)
  19:hello.c       **** 	__INIT(argc, argv);
  77              	.LM1:
  78 0013 488D55F0 		leaq	-16(%rbp), %rdx
  79 0017 8B45FC   		movl	-4(%rbp), %eax
  80 001a 4889D6   		movq	%rdx, %rsi
  81 001d 89C7     		movl	%eax, %edi
  82 001f E8000000 		call	Modules_Init@PLT
  82      00
  20:hello.c       **** 	__MODULE_IMPORT(Console);
  84              	.LM2:
  85 0024 E8000000 		call	Console__init@PLT
  85      00
  86 0029 4889C7   		movq	%rax, %rdi
  87 002c B8000000 		movl	$0, %eax
  87      00
  88 0031 E8000000 		call	Heap_INCREF@PLT
  88      00
  21:hello.c       **** 	__REGMAIN("hello", 0);
  90              	.LM3:
  91 0036 BE000000 		movl	$0, %esi
  91      00
  92 003b 488D3D00 		leaq	.LC0(%rip), %rdi
  92      000000
  93 0042 B8000000 		movl	$0, %eax
  93      00
  94 0047 E8000000 		call	Heap_REGMOD@PLT
  94      00
  95 004c 48890500 		movq	%rax, m.2038(%rip)
  95      000000
  22:hello.c       **** /* BEGIN */
  23:hello.c       **** 	Console_String((CHAR*)"Hello.", 7);
  97              	.LM4:
  98 0053 BE070000 		movl	$7, %esi
  98      00
  99 0058 488D3D00 		leaq	.LC1(%rip), %rdi
  99      000000
 100 005f E8000000 		call	Console_String@PLT
 100      00
  24:hello.c       **** 	Console_Ln();
 102              	.LM5:
 103 0064 E8000000 		call	Console_Ln@PLT
 103      00
  25:hello.c       **** 	__FINI;
 105              	.LM6:
 106 0069 B8000000 		movl	$0, %eax
 106      00
 107 006e E8000000 		call	Heap_FINALL@PLT
 107      00
 108 0073 B8000000 		movl	$0, %eax
 108      00
  26:hello.c       **** }
 110              	.LM7:
 111 0078 C9       		leave
 112              		.cfi_def_cfa 7, 8
 113 0079 C3       		ret
 114              		.cfi_endproc
 115              	.LFE7:
 120              	.Lscope1:
 122              		.stabd	78,0,0
 123              		.local	m.2038
 124              		.comm	m.2038,8,8
 127              	.Letext0:
 128              		.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
 129              		.section	.note.GNU-stack,"",@progbits
 130              		.section	.note.gnu.property,"a"
 131              		.align 8
 132 0000 04000000 		.long	 1f - 0f
 133 0004 10000000 		.long	 4f - 1f
 134 0008 05000000 		.long	 5
 135              	0:
 136 000c 474E5500 		.string	 "GNU"
 137              	1:
 138              		.align 8
 139 0010 020000C0 		.long	 0xc0000002
 140 0014 04000000 		.long	 3f - 2f
 141              	2:
 142 0018 03000000 		.long	 0x3
 143              	3:
 144 001c 00000000 		.align 8
 145              	4:
