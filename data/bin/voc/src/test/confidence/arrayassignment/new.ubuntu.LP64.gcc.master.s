 616100   		.string	"aa"
 6133303A 		.string	"a30: "
 6132303A 		.string	"a20: "
 6131303A 		.string	"a10: "
 000000   		.align 8
 41727261 		.string	"Array assignment test complete."
 79206173 
 7369676E 
 6D656E74 
 20746573 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC40 		subq	$64, %rsp
 897DCC   		movl	%edi, -52(%rbp)
 488975C0 		movq	%rsi, -64(%rbp)
 488D55C0 		leaq	-64(%rbp), %rdx
 8B45CC   		movl	-52(%rbp), %eax
 4889D6   		movq	%rdx, %rsi
 89C7     		movl	%eax, %edi
 E8000000 		call	Modules_Init@PLT
 E8000000 		call	Console__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2042(%rip)
 48B83173 		movabsq	$7142761996565639985, %rax
 74203130 
 48BA6820 		movabsq	$3472592403396960360, %rdx
 326E6420 
 48890500 		movq	%rax, aa_a30(%rip)
 48891500 		movq	%rdx, 8+aa_a30(%rip)
 48B82063 		movabsq	$2334116070797370144, %rax
 68203372 
 48890500 		movq	%rax, 16+aa_a30(%rip)
 C7050000 		movl	$1663053873, 24+aa_a30(%rip)
 00003130 
 66C70500 		movw	$104, 28+aa_a30(%rip)
 00000068 
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Console_String@PLT
 BE1E0000 		movl	$30, %esi
 488D3D00 		leaq	aa_a30(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 488D0500 		leaq	aa_a30(%rip), %rax
 488945E0 		movq	%rax, -32(%rbp)
 488D0500 		leaq	aa_a20(%rip), %rax
 488945E8 		movq	%rax, -24(%rbp)
 C745D000 		movl	$0, -48(%rbp)
 C745D813 		movl	$19, -40(%rbp)
 EB04     		jmp	.L2
 8345D001 		addl	$1, -48(%rbp)
 8B45D0   		movl	-48(%rbp), %eax
 3B45D8   		cmpl	-40(%rbp), %eax
 7D26     		jge	.L3
 8B45D0   		movl	-48(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45E0 		movq	-32(%rbp), %rax
 4801C2   		addq	%rax, %rdx
 8B45D0   		movl	-48(%rbp), %eax
 4863C8   		movslq	%eax, %rcx
 488B45E8 		movq	-24(%rbp), %rax
 4801C8   		addq	%rcx, %rax
 0FB612   		movzbl	(%rdx), %edx
 8810     		movb	%dl, (%rax)
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 75CE     		jne	.L4
 8B45D0   		movl	-48(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4801D0   		addq	%rdx, %rax
 C60000   		movb	$0, (%rax)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Console_String@PLT
 BE140000 		movl	$20, %esi
 488D3D00 		leaq	aa_a20(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 E8000000 		call	Console_Ln@PLT
 488D0500 		leaq	aa_a30(%rip), %rax
 488945F0 		movq	%rax, -16(%rbp)
 488D0500 		leaq	aa_a10(%rip), %rax
 488945F8 		movq	%rax, -8(%rbp)
 C745D400 		movl	$0, -44(%rbp)
 C745DC09 		movl	$9, -36(%rbp)
 EB04     		jmp	.L5
 8345D401 		addl	$1, -44(%rbp)
 8B45D4   		movl	-44(%rbp), %eax
 3B45DC   		cmpl	-36(%rbp), %eax
 7D26     		jge	.L6
 8B45D4   		movl	-44(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45F0 		movq	-16(%rbp), %rax
 4801C2   		addq	%rax, %rdx
 8B45D4   		movl	-44(%rbp), %eax
 4863C8   		movslq	%eax, %rcx
 488B45F8 		movq	-8(%rbp), %rax
 4801C8   		addq	%rcx, %rax
 0FB612   		movzbl	(%rdx), %edx
 8810     		movb	%dl, (%rax)
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 75CE     		jne	.L7
 8B45D4   		movl	-44(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45F8 		movq	-8(%rbp), %rax
 4801D0   		addq	%rdx, %rax
 C60000   		movb	$0, (%rax)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Console_String@PLT
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	aa_a10(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Console_String@PLT
 BE140000 		movl	$20, %esi
 488D3D00 		leaq	aa_a20(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 E8000000 		call	Console_Ln@PLT
 BE200000 		movl	$32, %esi
 488D3D00 		leaq	.LC4(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
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
