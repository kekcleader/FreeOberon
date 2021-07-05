 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B0500 		movq	isptest_T(%rip), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4889C7   		movq	%rax, %rdi
 FFD2     		call	*%rdx
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA600000 		movl	$96, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	isptest_R(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 90       		nop
 C9       		leave
 C3       		ret
 69737074 		.string	"isptest"
 65737400 
 69737074 		.string	"isptest.mod"
 6573742E 
 6D6F6400 
 706F733D 		.string	"pos="
 20636861 		.string	" char="
 32313930 		.string	"21906"
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 488975F0 		movq	%rsi, -16(%rbp)
 488D55F0 		leaq	-16(%rbp), %rdx
 8B45FC   		movl	-4(%rbp), %eax
 4889D6   		movq	%rdx, %rsi
 89C7     		movl	%eax, %edi
 E8000000 		call	Modules_Init@PLT
 E8000000 		call	Files__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Out__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Platform__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Texts__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 488D3540 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2620(%rip)
 488B0500 		movq	Texts_TextDesc__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_NEWREC@PLT
 48890500 		movq	%rax, isptest_T(%rip)
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Files_Old@PLT
 4885C0   		testq	%rax, %rax
 0F842F01 		je	.L3
 488B0500 		movq	isptest_T(%rip), %rax
 BA0C0000 		movl	$12, %edx
 488D3500 		leaq	.LC1(%rip), %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Texts_Open@PLT
 488B1500 		movq	isptest_T(%rip), %rdx
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 B9000000 		movl	$0, %ecx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	isptest_R(%rip), %rdi
 E8000000 		call	Texts_OpenReader@PLT
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488D1500 		leaq	isptest_ch(%rip), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	isptest_R(%rip), %rdi
 E8000000 		call	Texts_Read@PLT
 E9BB0000 		jmp	.L4
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488D1500 		leaq	isptest_ch(%rip), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	isptest_R(%rip), %rdi
 E8000000 		call	Texts_Read@PLT
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	isptest_R(%rip), %rdi
 E8000000 		call	Texts_Pos@PLT
 48890500 		movq	%rax, isptest_i(%rip)
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Out_String@PLT
 488B0500 		movq	isptest_i(%rip), %rax
 BE000000 		movl	$0, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_Int@PLT
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Out_String@PLT
 0FB60500 		movzbl	isptest_ch(%rip), %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Out_Char@PLT
 BF0A0000 		movl	$10, %edi
 E8000000 		call	Out_Char@PLT
 488B0500 		movq	isptest_i(%rip), %rax
 483D9255 		cmpq	$21906, %rax
 751B     		jne	.L4
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC4(%rip), %rdi
 E8000000 		call	Out_String@PLT
 BF0A0000 		movl	$10, %edi
 E8000000 		call	Out_Char@PLT
 0FB60500 		movzbl	isptest_R(%rip), %eax
 84C0     		testb	%al, %al
 0F8436FF 		je	.L5
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
