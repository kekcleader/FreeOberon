 206F6620 		.string	" of $"
 20627920 		.string	" by "
 20697320 		.string	" is $"
 20627574 		.string	" but should be $"
 2073686F 
 756C6420 
 62652024 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 897DEC   		movl	%edi, -20(%rbp)
 8975E8   		movl	%esi, -24(%rbp)
 8955E4   		movl	%edx, -28(%rbp)
 894DE0   		movl	%ecx, -32(%rbp)
 4C8945D8 		movq	%r8, -40(%rbp)
 4C894DD0 		movq	%r9, -48(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B4DD0 		movq	-48(%rbp), %rcx
 488B45D0 		movq	-48(%rbp), %rax
 488D5008 		leaq	8(%rax), %rdx
 B8100000 		movl	$16, %eax
 4883E801 		subq	$1, %rax
 4801D0   		addq	%rdx, %rax
 BE100000 		movl	$16, %esi
 BA000000 		movl	$0, %edx
 48F7F6   		divq	%rsi
 486BC010 		imulq	$16, %rax, %rax
 4889C2   		movq	%rax, %rdx
 4881E200 		andq	$-4096, %rdx
 4889E6   		movq	%rsp, %rsi
 4829D6   		subq	%rdx, %rsi
 4889F2   		movq	%rsi, %rdx
 4839D4   		cmpq	%rdx, %rsp
 7412     		je	.L3
 4881EC00 		subq	$4096, %rsp
 48838C24 		orq	$0, 4088(%rsp)
 F80F0000 
 EBE9     		jmp	.L2
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4829D4   		subq	%rdx, %rsp
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4885D2   		testq	%rdx, %rdx
 7410     		je	.L4
 25FF0F00 		andl	$4095, %eax
 4883E808 		subq	$8, %rax
 4801E0   		addq	%rsp, %rax
 48830800 		orq	$0, (%rax)
 4889E0   		movq	%rsp, %rax
 4883C00F 		addq	$15, %rax
 48C1E804 		shrq	$4, %rax
 48C1E004 		salq	$4, %rax
 4889C7   		movq	%rax, %rdi
 488B45D8 		movq	-40(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945D8 		movq	%rax, -40(%rbp)
 8B45E4   		movl	-28(%rbp), %eax
 3B45E0   		cmpl	-32(%rbp), %eax
 0F848C00 		je	.L7
 488B55D0 		movq	-48(%rbp), %rdx
 488B45D8 		movq	-40(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_String@PLT
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45EC   		movl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45E8   		movl	-24(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45E4   		movl	-28(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 BE110000 		movl	$17, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45E0   		movl	-32(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 E8000000 		call	Console_Ln@PLT
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L6
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 4C534800 		.string	"LSH"
 524F5428 		.string	"ROT(1)"
 524F5428 		.string	"ROT(2)"
 524F5428 		.string	"ROT(3)"
 524F5428 		.string	"ROT(4)"
 524F5400 		.string	"ROT"
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 66C745E0 		movw	$0, -32(%rbp)
 C745E801 		movl	$1, -24(%rbp)
 E9C80000 		jmp	.L9
 C745F401 		movl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L10
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L11
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B4DE8   		movl	-24(%rbp), %ecx
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 89C7     		movl	%eax, %edi
 E803FEFF 		call	TestLanguage_TestShiftResult
 C745F401 		movl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L12
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L13
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B4DE8   		movl	-24(%rbp), %ecx
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC5(%rip), %r8
 89C7     		movl	%eax, %edi
 E8A1FDFF 		call	TestLanguage_TestShiftResult
 8B45E8   		movl	-24(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945E8   		movl	%eax, -24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$31, -32(%rbp)
 0F8E2DFF 		jle	.L14
 66C745E0 		movw	$0, -32(%rbp)
 66C745E2 		movw	$1, -30(%rbp)
 E9E30000 		jmp	.L15
 66C745E6 		movw	$1, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L16
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L17
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 668945E6 		movw	%ax, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 663B45E2 		cmpw	-30(%rbp), %ax
 740A     		je	.L18
 BF170000 		movl	$23, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66C745E6 		movw	$1, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7831     		js	.L19
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L20
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 668945E6 		movw	%ax, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 663B45E2 		cmpw	-30(%rbp), %ax
 740A     		je	.L21
 BF180000 		movl	$24, %edi
 E8000000 		call	Modules_AssertFail@PLT
 480FBF45 		movswq	-30(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945E2 		movw	%ax, -30(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$15, -32(%rbp)
 0F8E12FF 		jle	.L22
 66C745E0 		movw	$0, -32(%rbp)
 C645DC01 		movb	$1, -36(%rbp)
 E9DA0000 		jmp	.L23
 C645DE01 		movb	$1, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L24
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L25
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 8845DE   		movb	%al, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 3A45DC   		cmpb	-36(%rbp), %al
 740A     		je	.L26
 BF1E0000 		movl	$30, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C645DE01 		movb	$1, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7831     		js	.L27
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L28
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8845DE   		movb	%al, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 3A45DC   		cmpb	-36(%rbp), %al
 740A     		je	.L29
 BF1F0000 		movl	$31, %edi
 E8000000 		call	Modules_AssertFail@PLT
 480FBE45 		movsbq	-36(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845DC   		movb	%al, -36(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$7, -32(%rbp)
 0F8E1BFF 		jle	.L30
 66C745E0 		movw	$-1, -32(%rbp)
 C745E801 		movl	$1, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 C1E01E   		sall	$30, %eax
 8945E8   		movl	%eax, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945EC   		movl	%eax, -20(%rbp)
 E9A00000 		jmp	.L31
 8B45EC   		movl	-20(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L32
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L33
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 3B45E8   		cmpl	-24(%rbp), %eax
 740A     		je	.L34
 BF270000 		movl	$39, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45EC   		movl	-20(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L35
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L36
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 3B45E8   		cmpl	-24(%rbp), %eax
 740A     		je	.L37
 BF280000 		movl	$40, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DE8   		sarl	-24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-31, -32(%rbp)
 0F8D55FF 		jge	.L38
 66C745E0 		movw	$-1, -32(%rbp)
 66C745E2 		movw	$1, -30(%rbp)
 0FB745E2 		movzwl	-30(%rbp), %eax
 0FB7C0   		movzwl	%ax, %eax
 C1E00E   		sall	$14, %eax
 668945E2 		movw	%ax, -30(%rbp)
 480FBF45 		movswq	-30(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945E4 		movw	%ax, -28(%rbp)
 E9DF0000 		jmp	.L39
 0FB745E4 		movzwl	-28(%rbp), %eax
 668945E6 		movw	%ax, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L40
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L41
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 668945E6 		movw	%ax, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 663B45E2 		cmpw	-30(%rbp), %ax
 740A     		je	.L42
 BF2E0000 		movl	$46, %edi
 E8000000 		call	Modules_AssertFail@PLT
 0FB745E4 		movzwl	-28(%rbp), %eax
 668945E6 		movw	%ax, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7831     		js	.L43
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L44
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 668945E6 		movw	%ax, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 663B45E2 		cmpw	-30(%rbp), %ax
 740A     		je	.L45
 BF2F0000 		movl	$47, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66D17DE2 		sarw	-30(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-15, -32(%rbp)
 0F8D16FF 		jge	.L46
 66C745E0 		movw	$-1, -32(%rbp)
 C645DC01 		movb	$1, -36(%rbp)
 0FB645DC 		movzbl	-36(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E006   		sall	$6, %eax
 8845DC   		movb	%al, -36(%rbp)
 480FBE45 		movsbq	-36(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845DD   		movb	%al, -35(%rbp)
 E9D80000 		jmp	.L47
 0FB645DD 		movzbl	-35(%rbp), %eax
 8845DE   		movb	%al, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L48
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L49
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 8845DE   		movb	%al, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 3A45DC   		cmpb	-36(%rbp), %al
 740A     		je	.L50
 BF350000 		movl	$53, %edi
 E8000000 		call	Modules_AssertFail@PLT
 0FB645DD 		movzbl	-35(%rbp), %eax
 8845DE   		movb	%al, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7831     		js	.L51
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L52
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8845DE   		movb	%al, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 3A45DC   		cmpb	-36(%rbp), %al
 740A     		je	.L53
 BF360000 		movl	$54, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D07DDC   		sarb	-36(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-7, -32(%rbp)
 0F8D1DFF 		jge	.L54
 66C745E0 		movw	$0, -32(%rbp)
 C745E801 		movl	$1, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 C1E01F   		sall	$31, %eax
 8945E8   		movl	%eax, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 8945EC   		movl	%eax, -20(%rbp)
 EB58     		jmp	.L55
 8B45EC   		movl	-20(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7814     		js	.L56
 8B45F4   		movl	-12(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB14     		jmp	.L57
 8B45F4   		movl	-12(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 3B45E8   		cmpl	-24(%rbp), %eax
 740A     		je	.L58
 BF3E0000 		movl	$62, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DE8   		sarl	-24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-31, -32(%rbp)
 7DA1     		jge	.L59
 66C745E0 		movw	$0, -32(%rbp)
 66C745E6 		movw	$1, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7C0   		movzwl	%ax, %eax
 C1E00F   		sall	$15, %eax
 668945E6 		movw	%ax, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 668945E2 		movw	%ax, -30(%rbp)
 EB52     		jmp	.L60
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L61
 480FBF55 		movswq	-26(%rbp), %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB13     		jmp	.L62
 480FBF55 		movswq	-26(%rbp), %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F4   		movl	%eax, -12(%rbp)
 0FBF45E2 		movswl	-30(%rbp), %eax
 3945F4   		cmpl	%eax, -12(%rbp)
 740A     		je	.L63
 BF440000 		movl	$68, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66D17DE2 		sarw	-30(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-15, -32(%rbp)
 7DA7     		jge	.L64
 66C745E0 		movw	$0, -32(%rbp)
 C645DE01 		movb	$1, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E007   		sall	$7, %eax
 8845DE   		movb	%al, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 8845DC   		movb	%al, -36(%rbp)
 EB51     		jmp	.L65
 66837DE0 		cmpw	$0, -32(%rbp)
 7813     		js	.L66
 480FBE55 		movsbq	-34(%rbp), %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB13     		jmp	.L67
 480FBE55 		movsbq	-34(%rbp), %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F4   		movl	%eax, -12(%rbp)
 0FBE45DC 		movsbl	-36(%rbp), %eax
 3945F4   		cmpl	%eax, -12(%rbp)
 740A     		je	.L68
 BF4A0000 		movl	$74, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D07DDC   		sarb	-36(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-7, -32(%rbp)
 7DA8     		jge	.L69
 66C745E0 		movw	$0, -32(%rbp)
 C745E801 		movl	$1, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 C1E01E   		sall	$30, %eax
 8945E8   		movl	%eax, -24(%rbp)
 8B45E8   		movl	-24(%rbp), %eax
 8945EC   		movl	%eax, -20(%rbp)
 EB58     		jmp	.L70
 8B45EC   		movl	-20(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7814     		js	.L71
 8B45F4   		movl	-12(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB14     		jmp	.L72
 8B45F4   		movl	-12(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 3B45E8   		cmpl	-24(%rbp), %eax
 740A     		je	.L73
 BF520000 		movl	$82, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DE8   		sarl	-24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-30, -32(%rbp)
 7DA1     		jge	.L74
 66C745E0 		movw	$1, -32(%rbp)
 C745E801 		movl	$1, -24(%rbp)
 E9D20000 		jmp	.L75
 C745F4FF 		movl	$2147483647, -12(%rbp)
 8345F401 		addl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L76
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L77
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E846F6FF 		call	TestLanguage_TestShiftResult
 C745F4FF 		movl	$2147483647, -12(%rbp)
 8345F401 		addl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L78
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L79
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B4DE8   		movl	-24(%rbp), %ecx
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC6(%rip), %r8
 89C7     		movl	%eax, %edi
 E8E0F5FF 		call	TestLanguage_TestShiftResult
 8B45E8   		movl	-24(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945E8   		movl	%eax, -24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$31, -32(%rbp)
 0F8E23FF 		jle	.L80
 66C745E0 		movw	$1, -32(%rbp)
 66C745E2 		movw	$1, -30(%rbp)
 E91A0100 		jmp	.L81
 66C745E6 		movw	$32767, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E6 		movw	%ax, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7814     		js	.L82
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 EB14     		jmp	.L83
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBF45E6 		movswl	-26(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E847F5FF 		call	TestLanguage_TestShiftResult
 66C745E6 		movw	$32767, -26(%rbp)
 0FB745E6 		movzwl	-26(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E6 		movw	%ax, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7832     		js	.L84
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 EB2C     		jmp	.L85
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 8945F0   		movl	%eax, -16(%rbp)
 0FBF4DE2 		movswl	-30(%rbp), %ecx
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBF45E6 		movswl	-26(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC7(%rip), %r8
 89C7     		movl	%eax, %edi
 E8ABF4FF 		call	TestLanguage_TestShiftResult
 480FBF45 		movswq	-30(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945E2 		movw	%ax, -30(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$15, -32(%rbp)
 0F8EDBFE 		jle	.L86
 66C745E0 		movw	$1, -32(%rbp)
 C645DC01 		movb	$1, -36(%rbp)
 E91B0100 		jmp	.L87
 C645DE7F 		movb	$127, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 83C001   		addl	$1, %eax
 8845DE   		movb	%al, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7816     		js	.L88
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 EB16     		jmp	.L89
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBE45DE 		movsbl	-34(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E812F4FF 		call	TestLanguage_TestShiftResult
 C645DE7F 		movb	$127, -34(%rbp)
 0FB645DE 		movzbl	-34(%rbp), %eax
 83C001   		addl	$1, %eax
 8845DE   		movb	%al, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7834     		js	.L90
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 EB2E     		jmp	.L91
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBE4DDC 		movsbl	-36(%rbp), %ecx
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBE45DE 		movsbl	-34(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC8(%rip), %r8
 89C7     		movl	%eax, %edi
 E875F3FF 		call	TestLanguage_TestShiftResult
 480FBE45 		movsbq	-36(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845DC   		movb	%al, -36(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$7, -32(%rbp)
 0F8EDAFE 		jle	.L92
 66C745E0 		movw	$-1, -32(%rbp)
 C745E8FF 		movl	$2147483647, -24(%rbp)
 8345E801 		addl	$1, -24(%rbp)
 E9C70000 		jmp	.L93
 C745F401 		movl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L94
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L95
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E8ECF2FF 		call	TestLanguage_TestShiftResult
 C745F401 		movl	$1, -12(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 780F     		js	.L96
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L97
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F4   		movl	-12(%rbp), %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 8B4DE8   		movl	-24(%rbp), %ecx
 8B55F0   		movl	-16(%rbp), %edx
 8B45F4   		movl	-12(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E88AF2FF 		call	TestLanguage_TestShiftResult
 8B45E8   		movl	-24(%rbp), %eax
 D1E8     		shrl	%eax
 8945E8   		movl	%eax, -24(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-31, -32(%rbp)
 0F8D2EFF 		jge	.L98
 66C745E0 		movw	$-1, -32(%rbp)
 66C745E2 		movw	$32767, -30(%rbp)
 0FB745E2 		movzwl	-30(%rbp), %eax
 83C001   		addl	$1, %eax
 668945E2 		movw	%ax, -30(%rbp)
 E9030100 		jmp	.L99
 66C745E6 		movw	$1, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7814     		js	.L100
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 EB14     		jmp	.L101
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBF45E6 		movswl	-26(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E8F4F1FF 		call	TestLanguage_TestShiftResult
 66C745E6 		movw	$1, -26(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7832     		js	.L102
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 EB2C     		jmp	.L103
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745E6 		movzwl	-26(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 8945F0   		movl	%eax, -16(%rbp)
 0FBF4DE2 		movswl	-30(%rbp), %ecx
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBF45E6 		movswl	-26(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E863F1FF 		call	TestLanguage_TestShiftResult
 0FB745E2 		movzwl	-30(%rbp), %eax
 66D1E8   		shrw	%ax
 668945E2 		movw	%ax, -30(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-15, -32(%rbp)
 0F8DF2FE 		jge	.L104
 66C745E0 		movw	$-1, -32(%rbp)
 C645DC7F 		movb	$127, -36(%rbp)
 0FB645DC 		movzbl	-36(%rbp), %eax
 83C001   		addl	$1, %eax
 8845DC   		movb	%al, -36(%rbp)
 E9050100 		jmp	.L105
 C645DE01 		movb	$1, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7816     		js	.L106
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 EB16     		jmp	.L107
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBE45DE 		movsbl	-34(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E8CBF0FF 		call	TestLanguage_TestShiftResult
 C645DE01 		movb	$1, -34(%rbp)
 66837DE0 		cmpw	$0, -32(%rbp)
 7834     		js	.L108
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 EB2E     		jmp	.L109
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645DE 		movzbl	-34(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45E0 		movswl	-32(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 8945F0   		movl	%eax, -16(%rbp)
 0FBE4DDC 		movsbl	-36(%rbp), %ecx
 0FBF75E0 		movswl	-32(%rbp), %esi
 0FBE45DE 		movsbl	-34(%rbp), %eax
 8B55F0   		movl	-16(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E838F0FF 		call	TestLanguage_TestShiftResult
 0FB645DC 		movzbl	-36(%rbp), %eax
 D0E8     		shrb	%al
 8845DC   		movb	%al, -36(%rbp)
 0FB745E0 		movzwl	-32(%rbp), %eax
 83E801   		subl	$1, %eax
 668945E0 		movw	%ax, -32(%rbp)
 66837DE0 		cmpw	$-7, -32(%rbp)
 0F8DF0FE 		jge	.L110
 C645DF01 		movb	$1, -33(%rbp)
 0FB645DF 		movzbl	-33(%rbp), %eax
 C1E002   		sall	$2, %eax
 8845DF   		movb	%al, -33(%rbp)
 0FB645DF 		movzbl	-33(%rbp), %eax
 C0E802   		shrb	$2, %al
 89C2     		movl	%eax, %edx
 0FB645DF 		movzbl	-33(%rbp), %eax
 C1E006   		sall	$6, %eax
 09D0     		orl	%edx, %eax
 8845DF   		movb	%al, -33(%rbp)
 807DDF01 		cmpb	$1, -33(%rbp)
 740A     		je	.L111
 BF5D0000 		movl	$93, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C645DB01 		movb	$1, -37(%rbp)
 0FB645DB 		movzbl	-37(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E002   		sall	$2, %eax
 8845DB   		movb	%al, -37(%rbp)
 0FB645DB 		movzbl	-37(%rbp), %eax
 C0E802   		shrb	$2, %al
 89C2     		movl	%eax, %edx
 0FB645DB 		movzbl	-37(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E006   		sall	$6, %eax
 09D0     		orl	%edx, %eax
 8845DB   		movb	%al, -37(%rbp)
 488D45DB 		leaq	-37(%rbp), %rax
 0FB600   		movzbl	(%rax), %eax
 3C01     		cmpb	$1, %al
 740A     		je	.L114
 BF5E0000 		movl	$94, %edi
 E8000000 		call	Modules_AssertFail@PLT
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L113
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 203D2000 		.string	" = "
 2C206578 		.string	", expected "
 70656374 
 65642000 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 897DEC   		movl	%edi, -20(%rbp)
 8975E8   		movl	%esi, -24(%rbp)
 488955E0 		movq	%rdx, -32(%rbp)
 48894DD8 		movq	%rcx, -40(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B4DD8 		movq	-40(%rbp), %rcx
 488B45D8 		movq	-40(%rbp), %rax
 488D5008 		leaq	8(%rax), %rdx
 B8100000 		movl	$16, %eax
 4883E801 		subq	$1, %rax
 4801D0   		addq	%rdx, %rax
 BF100000 		movl	$16, %edi
 BA000000 		movl	$0, %edx
 48F7F7   		divq	%rdi
 486BC010 		imulq	$16, %rax, %rax
 4889C2   		movq	%rax, %rdx
 4881E200 		andq	$-4096, %rdx
 4889E6   		movq	%rsp, %rsi
 4829D6   		subq	%rdx, %rsi
 4889F2   		movq	%rsi, %rdx
 4839D4   		cmpq	%rdx, %rsp
 7412     		je	.L117
 4881EC00 		subq	$4096, %rsp
 48838C24 		orq	$0, 4088(%rsp)
 F80F0000 
 EBE9     		jmp	.L116
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4829D4   		subq	%rdx, %rsp
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4885D2   		testq	%rdx, %rdx
 7410     		je	.L118
 25FF0F00 		andl	$4095, %eax
 4883E808 		subq	$8, %rax
 4801E0   		addq	%rsp, %rax
 48830800 		orq	$0, (%rax)
 4889E0   		movq	%rsp, %rax
 4883C00F 		addq	$15, %rax
 48C1E804 		shrq	$4, %rax
 48C1E004 		salq	$4, %rax
 4889C7   		movq	%rax, %rdi
 488B45E0 		movq	-32(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945E0 		movq	%rax, -32(%rbp)
 8B45EC   		movl	-20(%rbp), %eax
 3B45E8   		cmpl	-24(%rbp), %eax
 745E     		je	.L121
 488B55D8 		movq	-40(%rbp), %rdx
 488B45E0 		movq	-32(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_String@PLT
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC10(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45EC   		movl	-20(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45E8   		movl	-24(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 E8000000 		call	Console_Ln@PLT
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L120
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 89F8     		movl	%edi, %eax
 668945FC 		movw	%ax, -4(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 5D       		popq	%rbp
 C3       		ret
 34204449 		.string	"4 DIV 2"
 56203200 
 73696465 		.string	"side(4) DIV side(2)"
 28342920 
 44495620 
 73696465 
 28322900 
 35204449 		.string	"5 DIV 2"
 56203200 
 73696465 		.string	"side(5) DIV side(2)"
 28352920 
 44495620 
 73696465 
 28322900 
 36204449 		.string	"6 DIV 2"
 56203200 
 73696465 		.string	"side(6) DIV side(2)"
 28362920 
 44495620 
 73696465 
 28322900 
 37204449 		.string	"7 DIV 2"
 56203200 
 73696465 		.string	"side(7) DIV side(2)"
 28372920 
 44495620 
 73696465 
 28322900 
 282D3429 		.string	"(-4) DIV 2"
 20444956 
 73696465 		.string	"side(-4) DIV side(2)"
 282D3429 
 20444956 
 20736964 
 65283229 
 282D3529 		.string	"(-5) DIV 2"
 20444956 
 73696465 		.string	"side(-5) DIV side(2)"
 282D3529 
 20444956 
 20736964 
 65283229 
 282D3629 		.string	"(-6) DIV 2"
 20444956 
 73696465 		.string	"side(-6) DIV side(2)"
 282D3629 
 20444956 
 20736964 
 65283229 
 282D3729 		.string	"(-7) DIV 2"
 20444956 
 73696465 		.string	"side(-7) DIV side(2)"
 282D3729 
 20444956 
 20736964 
 65283229 
 34204449 		.string	"4 DIV (-2)"
 5620282D 
 73696465 		.string	"side(4) DIV side(-2)"
 28342920 
 44495620 
 73696465 
 282D3229 
 35204449 		.string	"5 DIV (-2)"
 5620282D 
 73696465 		.string	"side(5) DIV side(-2)"
 28352920 
 44495620 
 73696465 
 282D3229 
 36204449 		.string	"6 DIV (-2)"
 5620282D 
 73696465 		.string	"side(6) DIV side(-2)"
 28362920 
 44495620 
 73696465 
 282D3229 
 37204449 		.string	"7 DIV (-2)"
 5620282D 
 73696465 		.string	"side(7) DIV side(-2)"
 28372920 
 44495620 
 73696465 
 282D3229 
 282D3429 		.string	"(-4) DIV (-2)"
 20444956 
 20282D32 
 73696465 		.string	"side(-4) DIV side(-2)"
 282D3429 
 20444956 
 20736964 
 65282D32 
 282D3529 		.string	"(-5) DIV (-2)"
 20444956 
 20282D32 
 73696465 		.string	"side(-5) DIV side(-2)"
 282D3529 
 20444956 
 20736964 
 65282D32 
 282D3629 		.string	"(-6) DIV (-2)"
 20444956 
 20282D32 
 73696465 		.string	"side(-6) DIV side(-2)"
 282D3629 
 20444956 
 20736964 
 65282D32 
 282D3729 		.string	"(-7) DIV (-2)"
 20444956 
 20282D32 
 73696465 		.string	"side(-7) DIV side(-2)"
 282D3729 
 20444956 
 20736964 
 65282D32 
 34204D4F 		.string	"4 MOD 3"
 44203300 
 35204D4F 		.string	"5 MOD 3"
 44203300 
 36204D4F 		.string	"6 MOD 3"
 44203300 
 37204D4F 		.string	"7 MOD 3"
 44203300 
 2D34204D 		.string	"-4 MOD 3"
 4F442033 
 2D35204D 		.string	"-5 MOD 3"
 4F442033 
 2D36204D 		.string	"-6 MOD 3"
 4F442033 
 2D37204D 		.string	"-7 MOD 3"
 4F442033 
 34204D4F 		.string	"4 MOD -3"
 44202D33 
 35204D4F 		.string	"5 MOD -3"
 44202D33 
 36204D4F 		.string	"6 MOD -3"
 44202D33 
 37204D4F 		.string	"7 MOD -3"
 44202D33 
 2D34204D 		.string	"-4 MOD -3"
 4F44202D 
 2D35204D 		.string	"-5 MOD -3"
 4F44202D 
 2D36204D 		.string	"-6 MOD -3"
 4F44202D 
 2D37204D 		.string	"-7 MOD -3"
 4F44202D 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 53       		pushq	%rbx
 4883EC18 		subq	$24, %rsp
 66C745EC 		movw	$2, -20(%rbp)
 66C745EE 		movw	$4, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L125
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L125
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L126
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC12(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E843FEFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E880FFFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E871FFFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC13(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E802FEFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$5, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L127
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L127
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L128
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC14(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8B4FDFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8F1FEFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8E2FEFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC15(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E873FDFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$6, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L129
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L129
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L130
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC16(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E825FDFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E862FEFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E853FEFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC17(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8E4FCFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$7, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L131
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L131
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L132
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC18(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E896FCFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8D3FDFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8C4FDFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC19(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E855FCFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-4, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L133
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L133
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L134
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC20(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E807FCFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E844FDFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E835FDFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC21(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E8C6FBFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-5, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L135
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L135
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L136
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC22(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E878FBFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8B5FCFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8A6FCFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC23(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E837FBFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-6, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L137
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L137
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L138
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC24(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8E9FAFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E826FCFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E817FCFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC25(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8A8FAFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-7, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L139
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L139
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L140
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC26(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E85AFAFF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E897FBFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E888FBFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC27(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E819FAFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-2, -20(%rbp)
 66C745EE 		movw	$4, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L141
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L141
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L142
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC28(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E8C5F9FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E802FBFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8F3FAFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC29(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E884F9FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$5, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L143
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L143
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L144
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC30(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E836F9FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E873FAFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E864FAFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC31(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8F5F8FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$6, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L145
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L145
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L146
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC32(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8A7F8FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8E4F9FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8D5F9FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC33(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E866F8FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$7, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L147
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L147
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L148
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC34(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E818F8FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E855F9FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E846F9FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC35(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E8D7F7FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-4, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L149
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L149
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L150
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC36(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E889F7FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8C6F8FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8B7F8FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC37(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E848F7FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-5, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L151
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L151
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L152
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC38(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8FAF6FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E837F8FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E828F8FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC39(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8B9F6FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-6, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L153
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L153
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L154
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC40(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E86BF6FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8A8F7FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E899F7FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC41(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E82AF6FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-7, -18(%rbp)
 66837DEE 		cmpw	$0, -18(%rbp)
 7E14     		jle	.L155
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0D     		jle	.L155
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L156
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC42(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8DCF5FF 		call	TestLanguage_TestValue
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E819F7FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E80AF7FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC43(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E89BF5FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$4, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L157
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L157
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L158
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L159
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L159
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L160
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC44(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E803F5FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$5, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L161
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L161
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L162
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L163
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L163
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L164
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC45(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E86BF4FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$6, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L165
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L165
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L166
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L167
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L167
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L168
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC46(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8D3F3FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$7, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L169
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L169
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L170
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L171
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L171
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L172
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC47(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E83BF3FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-4, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L173
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L173
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L174
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L175
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L175
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L176
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC48(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8A3F2FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-5, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L177
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L177
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L178
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L179
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L179
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L180
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC49(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E80BF2FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-6, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L181
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L181
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L182
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L183
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L183
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L184
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC50(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E873F1FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-7, -18(%rbp)
 66C745EC 		movw	$3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L185
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L185
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L186
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L187
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L187
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L188
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC51(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8DBF0FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$4, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L189
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L189
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L190
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L191
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L191
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L192
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC52(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E843F0FF 		call	TestLanguage_TestValue
 66C745EE 		movw	$5, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L193
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L193
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L194
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L195
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L195
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L196
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC53(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8ABEFFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$6, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L197
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L197
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L198
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L199
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L199
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L200
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC54(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E813EFFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$7, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L201
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L201
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L202
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L203
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L203
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L204
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC55(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E87BEEFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-4, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L205
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L205
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L206
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L207
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L207
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L208
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC56(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8E3EDFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-5, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L209
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L209
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L210
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L211
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L211
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L212
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC57(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E84BEDFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-6, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L213
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L213
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L214
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L215
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L215
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L216
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC58(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8B3ECFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-7, -18(%rbp)
 66C745EC 		movw	$-3, -20(%rbp)
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L217
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L217
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF75EC 		movswl	-20(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L218
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEE 		cmpw	$0, -18(%rbp)
 7E16     		jle	.L219
 66837DEC 		cmpw	$0, -20(%rbp)
 7E0F     		jle	.L219
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FBF4DEC 		movswl	-20(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L220
 480FBF55 		movswq	-20(%rbp), %rdx
 480FBF45 		movswq	-18(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC59(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E81BECFF 		call	TestLanguage_TestValue
 90       		nop
 4883C418 		addq	$24, %rsp
 5B       		popq	%rbx
 5D       		popq	%rbp
 C3       		ret
 41425328 		.string	"ABS(INTEGER 5)"
 494E5445 
 47455220 
 41425328 		.string	"ABS(INTEGER -5)"
 494E5445 
 47455220 
 2D352900 
 41425328 		.string	"ABS(LONGINT 5)"
 4C4F4E47 
 494E5420 
 41425328 		.string	"ABS(LONGINT -5)"
 4C4F4E47 
 494E5420 
 2D352900 
 41425328 		.string	"ABS(SYSTEM.INT64 5)"
 53595354 
 454D2E49 
 4E543634 
 20352900 
 41425328 		.string	"ABS(SYSTEM.INT64 -5)"
 53595354 
 454D2E49 
 4E543634 
 202D3529 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 66C745F2 		movw	$5, -14(%rbp)
 0FB745F2 		movzwl	-14(%rbp), %eax
 66C1F80F 		sarw	$15, %ax
 89C2     		movl	%eax, %edx
 89D0     		movl	%edx, %eax
 663345F2 		xorw	-14(%rbp), %ax
 29D0     		subl	%edx, %eax
 0FB7C0   		movzwl	%ax, %eax
 B90F0000 		movl	$15, %ecx
 488D1500 		leaq	.LC60(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8D4EBFF 		call	TestLanguage_TestValue
 66C745F2 		movw	$-5, -14(%rbp)
 0FB745F2 		movzwl	-14(%rbp), %eax
 66C1F80F 		sarw	$15, %ax
 89C2     		movl	%eax, %edx
 89D0     		movl	%edx, %eax
 663345F2 		xorw	-14(%rbp), %ax
 29D0     		subl	%edx, %eax
 0FB7C0   		movzwl	%ax, %eax
 B9100000 		movl	$16, %ecx
 488D1500 		leaq	.LC61(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8A1EBFF 		call	TestLanguage_TestValue
 C745F405 		movl	$5, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 99       		cltd
 89D0     		movl	%edx, %eax
 3345F4   		xorl	-12(%rbp), %eax
 29D0     		subl	%edx, %eax
 B90F0000 		movl	$15, %ecx
 488D1500 		leaq	.LC62(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E877EBFF 		call	TestLanguage_TestValue
 C745F4FB 		movl	$-5, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 99       		cltd
 89D0     		movl	%edx, %eax
 3345F4   		xorl	-12(%rbp), %eax
 29D0     		subl	%edx, %eax
 B9100000 		movl	$16, %ecx
 488D1500 		leaq	.LC63(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E84DEBFF 		call	TestLanguage_TestValue
 48C745F8 		movq	$5, -8(%rbp)
 05000000 
 48837DF8 		cmpq	$0, -8(%rbp)
 7908     		jns	.L222
 488B45F8 		movq	-8(%rbp), %rax
 F7D8     		negl	%eax
 EB04     		jmp	.L223
 488B45F8 		movq	-8(%rbp), %rax
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC64(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E81AEBFF 		call	TestLanguage_TestValue
 48C745F8 		movq	$-5, -8(%rbp)
 FBFFFFFF 
 48837DF8 		cmpq	$0, -8(%rbp)
 7908     		jns	.L224
 488B45F8 		movq	-8(%rbp), %rax
 F7D8     		negl	%eax
 EB04     		jmp	.L225
 488B45F8 		movq	-8(%rbp), %rax
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC65(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8E7EAFF 		call	TestLanguage_TestValue
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 F20F1005 		movsd	TestLanguage_gz(%rip), %xmm0
 00000000 
 F20F5845 		addsd	-8(%rbp), %xmm0
 5D       		popq	%rbp
 C3       		ret
 454E5449 		.string	"ENTIER(-0.01"
 4552282D 
 302E3031 
 454E5449 		.string	"ENTIER(0.00"
 45522830 
 2E303000 
 454E5449 		.string	"ENTIER(5.00"
 45522835 
 2E303000 
 454E5449 		.string	"ENTIER(5.50"
 45522835 
 2E353000 
 454E5449 		.string	"ENTIER(5.99"
 45522835 
 2E393900 
 454E5449 		.string	"ENTIER(-5.00"
 4552282D 
 352E3030 
 454E5449 		.string	"ENTIER(-5.50"
 4552282D 
 352E3530 
 454E5449 		.string	"ENTIER(-5.99"
 4552282D 
 352E3939 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, TestLanguage_gz(%rip)
 00000000 
 488B0500 		movq	.LC67(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E8BBFFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC68(%rip), %rdx
 BEFFFFFF 		movl	$-1, %esi
 89C7     		movl	%eax, %edi
 E870EAFF 		call	TestLanguage_TestValue
 660FEFC0 		pxor	%xmm0, %xmm0
 E883FFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC69(%rip), %rdx
 BE000000 		movl	$0, %esi
 89C7     		movl	%eax, %edi
 E838EAFF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC70(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E843FFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC71(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8F8E9FF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC72(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E803FFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC73(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8B8E9FF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC74(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E8C3FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC75(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E878E9FF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC76(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E883FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC77(%rip), %rdx
 BEFBFFFF 		movl	$-5, %esi
 89C7     		movl	%eax, %edi
 E838E9FF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC78(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E843FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC79(%rip), %rdx
 BEFAFFFF 		movl	$-6, %esi
 89C7     		movl	%eax, %edi
 E8F8E8FF 		call	TestLanguage_TestValue
 488B0500 		movq	.LC80(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E803FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC81(%rip), %rdx
 BEFAFFFF 		movl	$-6, %esi
 89C7     		movl	%eax, %edi
 E8B8E8FF 		call	TestLanguage_TestValue
 90       		nop
 C9       		leave
 C3       		ret
 4D494E28 		.string	"MIN(SHORTINT)"
 53484F52 
 54494E54 
 4D415828 		.string	"MAX(SHORTINT)"
 53484F52 
 54494E54 
 4D494E28 		.string	"MIN(INTEGER)"
 494E5445 
 47455229 
 4D415828 		.string	"MAX(INTEGER)"
 494E5445 
 47455229 
 4D494E28 		.string	"MIN(LONGINT)"
 4C4F4E47 
 494E5429 
 4D415828 		.string	"MAX(LONGINT)"
 4C4F4E47 
 494E5429 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC82(%rip), %rdx
 BE80FFFF 		movl	$-128, %esi
 BF80FFFF 		movl	$-128, %edi
 E892E8FF 		call	TestLanguage_TestValue
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC83(%rip), %rdx
 BE7F0000 		movl	$127, %esi
 BF7F0000 		movl	$127, %edi
 E877E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC84(%rip), %rdx
 BE0080FF 		movl	$-32768, %esi
 BF0080FF 		movl	$-32768, %edi
 E85CE8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC85(%rip), %rdx
 BEFF7F00 		movl	$32767, %esi
 BFFF7F00 		movl	$32767, %edi
 E841E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC86(%rip), %rdx
 BE000000 		movl	$-2147483648, %esi
 BF000000 		movl	$-2147483648, %edi
 E826E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC87(%rip), %rdx
 BEFFFFFF 		movl	$2147483647, %esi
 BFFFFFFF 		movl	$2147483647, %edi
 E80BE8FF 		call	TestLanguage_TestValue
 90       		nop
 5D       		popq	%rbp
 C3       		ret
 54657374 		.string	"TestLanguage"
 4C616E67 
 75616765 
 4C616E67 		.string	"Language tests successful."
 75616765 
 20746573 
 74732073 
 75636365 
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
 E8000000 		call	Console__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC88(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2168(%rip)
 E8C1D8FF 		call	TestLanguage_Shift
 E807E9FF 		call	TestLanguage_DivMod
 E8F1FEFF 		call	TestLanguage_IntSize
 E88EFBFF 		call	TestLanguage_Abs
 E8D4FCFF 		call	TestLanguage_Entier
 BE1B0000 		movl	$27, %esi
 488D3D00 		leaq	.LC89(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 00000000 		.align 8
 FFFFFF3F 		.long	1073741823
 E17A84BF 		.long	-1081836831
 00000000 		.long	0
 00001440 		.long	1075052544
 00000000 		.long	0
 00001640 		.long	1075183616
 FBFFFF7F 		.long	2147483643
 C2F51740 		.long	1075312066
 00000000 		.long	0
 000014C0 		.long	-1072431104
 00000000 		.long	0
 000016C0 		.long	-1072300032
 FBFFFF7F 		.long	2147483643
 C2F517C0 		.long	-1072171582
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
