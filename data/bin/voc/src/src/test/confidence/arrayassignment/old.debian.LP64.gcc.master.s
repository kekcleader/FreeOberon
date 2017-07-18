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
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC50 		subq	$80, %rsp
 897DBC   		movl	%edi, -68(%rbp)
 488975B0 		movq	%rsi, -80(%rbp)
 488D55B0 		leaq	-80(%rbp), %rdx
 8B45BC   		movl	-68(%rbp), %eax
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
 48890500 		movq	%rax, m.1874(%rip)
 48B83173 		movabsq	$7142761996565639985, %rax
 74203130 
 48890500 		movq	%rax, aa_a30(%rip)
 48B86820 		movabsq	$3472592403396960360, %rax
 326E6420 
 48890500 		movq	%rax, 8+aa_a30(%rip)
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
 488945F0 		movq	%rax, -16(%rbp)
 488D0500 		leaq	aa_a20(%rip), %rax
 488945E8 		movq	%rax, -24(%rbp)
 C745FC00 		movl	$0, -4(%rbp)
 C745E413 		movl	$19, -28(%rbp)
 EB04     		jmp	.L2
 8345FC01 		addl	$1, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 3B45E4   		cmpl	-28(%rbp), %eax
 7D26     		jge	.L3
 8B45FC   		movl	-4(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4801D0   		addq	%rdx, %rax
 8B55FC   		movl	-4(%rbp), %edx
 4863CA   		movslq	%edx, %rcx
 488B55F0 		movq	-16(%rbp), %rdx
 4801CA   		addq	%rcx, %rdx
 0FB612   		movzbl	(%rdx), %edx
 8810     		movb	%dl, (%rax)
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 75CE     		jne	.L4
 8B45FC   		movl	-4(%rbp), %eax
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
 488945D8 		movq	%rax, -40(%rbp)
 488D0500 		leaq	aa_a10(%rip), %rax
 488945D0 		movq	%rax, -48(%rbp)
 C745F800 		movl	$0, -8(%rbp)
 C745CC09 		movl	$9, -52(%rbp)
 EB04     		jmp	.L5
 8345F801 		addl	$1, -8(%rbp)
 8B45F8   		movl	-8(%rbp), %eax
 3B45CC   		cmpl	-52(%rbp), %eax
 7D26     		jge	.L6
 8B45F8   		movl	-8(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45D0 		movq	-48(%rbp), %rax
 4801D0   		addq	%rdx, %rax
 8B55F8   		movl	-8(%rbp), %edx
 4863CA   		movslq	%edx, %rcx
 488B55D8 		movq	-40(%rbp), %rdx
 4801CA   		addq	%rcx, %rdx
 0FB612   		movzbl	(%rdx), %edx
 8810     		movb	%dl, (%rax)
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 75CE     		jne	.L7
 8B45F8   		movl	-8(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B45D0 		movq	-48(%rbp), %rax
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
