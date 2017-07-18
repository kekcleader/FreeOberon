 206F6620 		.string	" of $"
 20627920 		.string	" by "
 20697320 		.string	" is $"
 20627574 		.string	" but should be $"
 2073686F 
 756C6420 
 62652024 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 8975F8   		movl	%esi, -8(%rbp)
 8955F4   		movl	%edx, -12(%rbp)
 894DF0   		movl	%ecx, -16(%rbp)
 4C8945E8 		movq	%r8, -24(%rbp)
 4C894DE0 		movq	%r9, -32(%rbp)
 488B4DE0 		movq	-32(%rbp), %rcx
 488B45E0 		movq	-32(%rbp), %rax
 488D500F 		leaq	15(%rax), %rdx
 B8100000 		movl	$16, %eax
 4883E801 		subq	$1, %rax
 4801D0   		addq	%rdx, %rax
 BE100000 		movl	$16, %esi
 BA000000 		movl	$0, %edx
 48F7F6   		divq	%rsi
 486BC010 		imulq	$16, %rax, %rax
 4829C4   		subq	%rax, %rsp
 4889E0   		movq	%rsp, %rax
 4883C00F 		addq	$15, %rax
 48C1E804 		shrq	$4, %rax
 48C1E004 		salq	$4, %rax
 4889C7   		movq	%rax, %rdi
 488B45E8 		movq	-24(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945E8 		movq	%rax, -24(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 3B45F0   		cmpl	-16(%rbp), %eax
 0F848C00 		je	.L1
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_String@PLT
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45FC   		movl	-4(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45F8   		movl	-8(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45F4   		movl	-12(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 BE110000 		movl	$17, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45F0   		movl	-16(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Console_Hex@PLT
 E8000000 		call	Console_Ln@PLT
 C9       		leave
 C3       		ret
 4C534800 		.string	"LSH"
 524F5428 		.string	"ROT(1)"
 524F5428 		.string	"ROT(2)"
 524F5428 		.string	"ROT(3)"
 524F5428 		.string	"ROT(4)"
 524F5400 		.string	"ROT"
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 66C745FC 		movw	$0, -4(%rbp)
 C745F401 		movl	$1, -12(%rbp)
 E9C80000 		jmp	.L4
 C745F001 		movl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L5
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L6
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B4DF4   		movl	-12(%rbp), %ecx
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 89C7     		movl	%eax, %edi
 E88FFEFF 		call	TestLanguage_TestShiftResult
 C745F001 		movl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L7
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L8
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B4DF4   		movl	-12(%rbp), %ecx
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC5(%rip), %r8
 89C7     		movl	%eax, %edi
 E82DFEFF 		call	TestLanguage_TestShiftResult
 8B45F4   		movl	-12(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945F4   		movl	%eax, -12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$31, -4(%rbp)
 0F8E2DFF 		jle	.L9
 66C745FC 		movw	$0, -4(%rbp)
 66C745FA 		movw	$1, -6(%rbp)
 E9E30000 		jmp	.L10
 66C745EA 		movw	$1, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L11
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L12
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 668945EA 		movw	%ax, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 663B45FA 		cmpw	-6(%rbp), %ax
 740A     		je	.L13
 BF170000 		movl	$23, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66C745EA 		movw	$1, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7831     		js	.L14
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L15
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 668945EA 		movw	%ax, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 663B45FA 		cmpw	-6(%rbp), %ax
 740A     		je	.L16
 BF180000 		movl	$24, %edi
 E8000000 		call	Modules_AssertFail@PLT
 480FBF45 		movswq	-6(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945FA 		movw	%ax, -6(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$15, -4(%rbp)
 0F8E12FF 		jle	.L17
 66C745FC 		movw	$0, -4(%rbp)
 C645FF01 		movb	$1, -1(%rbp)
 E9DA0000 		jmp	.L18
 C645E901 		movb	$1, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L19
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L20
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 8845E9   		movb	%al, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 3A45FF   		cmpb	-1(%rbp), %al
 740A     		je	.L21
 BF1E0000 		movl	$30, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C645E901 		movb	$1, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7831     		js	.L22
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L23
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8845E9   		movb	%al, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 3A45FF   		cmpb	-1(%rbp), %al
 740A     		je	.L24
 BF1F0000 		movl	$31, %edi
 E8000000 		call	Modules_AssertFail@PLT
 480FBE45 		movsbq	-1(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845FF   		movb	%al, -1(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$7, -4(%rbp)
 0F8E1BFF 		jle	.L25
 66C745FC 		movw	$-1, -4(%rbp)
 C745F401 		movl	$1, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 C1E01E   		sall	$30, %eax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945E4   		movl	%eax, -28(%rbp)
 E9A00000 		jmp	.L26
 8B45E4   		movl	-28(%rbp), %eax
 8945F0   		movl	%eax, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L27
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L28
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945F0   		movl	%eax, -16(%rbp)
 8B45F0   		movl	-16(%rbp), %eax
 3B45F4   		cmpl	-12(%rbp), %eax
 740A     		je	.L29
 BF270000 		movl	$39, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45E4   		movl	-28(%rbp), %eax
 8945F0   		movl	%eax, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L30
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L31
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945F0   		movl	%eax, -16(%rbp)
 8B45F0   		movl	-16(%rbp), %eax
 3B45F4   		cmpl	-12(%rbp), %eax
 740A     		je	.L32
 BF280000 		movl	$40, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DF4   		sarl	-12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-31, -4(%rbp)
 0F8D55FF 		jge	.L33
 66C745FC 		movw	$-1, -4(%rbp)
 66C745FA 		movw	$1, -6(%rbp)
 0FB745FA 		movzwl	-6(%rbp), %eax
 0FB7C0   		movzwl	%ax, %eax
 C1E00E   		sall	$14, %eax
 668945FA 		movw	%ax, -6(%rbp)
 480FBF45 		movswq	-6(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945E2 		movw	%ax, -30(%rbp)
 E9DF0000 		jmp	.L34
 0FB745E2 		movzwl	-30(%rbp), %eax
 668945EA 		movw	%ax, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L35
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L36
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 668945EA 		movw	%ax, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 663B45FA 		cmpw	-6(%rbp), %ax
 740A     		je	.L37
 BF2E0000 		movl	$46, %edi
 E8000000 		call	Modules_AssertFail@PLT
 0FB745E2 		movzwl	-30(%rbp), %eax
 668945EA 		movw	%ax, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7831     		js	.L38
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L39
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 668945EA 		movw	%ax, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 663B45FA 		cmpw	-6(%rbp), %ax
 740A     		je	.L40
 BF2F0000 		movl	$47, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66D17DFA 		sarw	-6(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-15, -4(%rbp)
 0F8D16FF 		jge	.L41
 66C745FC 		movw	$-1, -4(%rbp)
 C645FF01 		movb	$1, -1(%rbp)
 0FB645FF 		movzbl	-1(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E006   		sall	$6, %eax
 8845FF   		movb	%al, -1(%rbp)
 480FBE45 		movsbq	-1(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845E1   		movb	%al, -31(%rbp)
 E9D80000 		jmp	.L42
 0FB645E1 		movzbl	-31(%rbp), %eax
 8845E9   		movb	%al, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L43
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB13     		jmp	.L44
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 8845E9   		movb	%al, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 3A45FF   		cmpb	-1(%rbp), %al
 740A     		je	.L45
 BF350000 		movl	$53, %edi
 E8000000 		call	Modules_AssertFail@PLT
 0FB645E1 		movzbl	-31(%rbp), %eax
 8845E9   		movb	%al, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7831     		js	.L46
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 EB2B     		jmp	.L47
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8845E9   		movb	%al, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 3A45FF   		cmpb	-1(%rbp), %al
 740A     		je	.L48
 BF360000 		movl	$54, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D07DFF   		sarb	-1(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-7, -4(%rbp)
 0F8D1DFF 		jge	.L49
 66C745FC 		movw	$0, -4(%rbp)
 C745F401 		movl	$1, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 C1E01F   		sall	$31, %eax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 8945E4   		movl	%eax, -28(%rbp)
 EB58     		jmp	.L50
 8B45E4   		movl	-28(%rbp), %eax
 8945F0   		movl	%eax, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7814     		js	.L51
 8B45F0   		movl	-16(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB14     		jmp	.L52
 8B45F0   		movl	-16(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F0   		movl	%eax, -16(%rbp)
 8B45F0   		movl	-16(%rbp), %eax
 3B45F4   		cmpl	-12(%rbp), %eax
 740A     		je	.L53
 BF3E0000 		movl	$62, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DF4   		sarl	-12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-31, -4(%rbp)
 7DA1     		jge	.L54
 66C745FC 		movw	$0, -4(%rbp)
 66C745EA 		movw	$1, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7C0   		movzwl	%ax, %eax
 C1E00F   		sall	$15, %eax
 668945EA 		movw	%ax, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 668945FA 		movw	%ax, -6(%rbp)
 EB52     		jmp	.L55
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L56
 480FBF55 		movswq	-22(%rbp), %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB13     		jmp	.L57
 480FBF55 		movswq	-22(%rbp), %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F0   		movl	%eax, -16(%rbp)
 0FBF45FA 		movswl	-6(%rbp), %eax
 3B45F0   		cmpl	-16(%rbp), %eax
 740A     		je	.L58
 BF440000 		movl	$68, %edi
 E8000000 		call	Modules_AssertFail@PLT
 66D17DFA 		sarw	-6(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-15, -4(%rbp)
 7DA7     		jge	.L59
 66C745FC 		movw	$0, -4(%rbp)
 C645E901 		movb	$1, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E007   		sall	$7, %eax
 8845E9   		movb	%al, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 8845FF   		movb	%al, -1(%rbp)
 EB51     		jmp	.L60
 66837DFC 		cmpw	$0, -4(%rbp)
 7813     		js	.L61
 480FBE55 		movsbq	-23(%rbp), %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB13     		jmp	.L62
 480FBE55 		movsbq	-23(%rbp), %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F0   		movl	%eax, -16(%rbp)
 0FBE45FF 		movsbl	-1(%rbp), %eax
 3B45F0   		cmpl	-16(%rbp), %eax
 740A     		je	.L63
 BF4A0000 		movl	$74, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D07DFF   		sarb	-1(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-7, -4(%rbp)
 7DA8     		jge	.L64
 66C745FC 		movw	$0, -4(%rbp)
 C745F401 		movl	$1, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 C1E01E   		sall	$30, %eax
 8945F4   		movl	%eax, -12(%rbp)
 8B45F4   		movl	-12(%rbp), %eax
 8945E4   		movl	%eax, -28(%rbp)
 EB58     		jmp	.L65
 8B45E4   		movl	-28(%rbp), %eax
 8945F0   		movl	%eax, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7814     		js	.L66
 8B45F0   		movl	-16(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 48D3E2   		salq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 EB14     		jmp	.L67
 8B45F0   		movl	-16(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 48D3FA   		sarq	%cl, %rdx
 4889D0   		movq	%rdx, %rax
 8945F0   		movl	%eax, -16(%rbp)
 8B45F0   		movl	-16(%rbp), %eax
 3B45F4   		cmpl	-12(%rbp), %eax
 740A     		je	.L68
 BF520000 		movl	$82, %edi
 E8000000 		call	Modules_AssertFail@PLT
 D17DF4   		sarl	-12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-30, -4(%rbp)
 7DA1     		jge	.L69
 66C745FC 		movw	$1, -4(%rbp)
 C745F401 		movl	$1, -12(%rbp)
 E9D20000 		jmp	.L70
 C745F0FF 		movl	$2147483647, -16(%rbp)
 8345F001 		addl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L71
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L72
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E8D2F6FF 		call	TestLanguage_TestShiftResult
 C745F0FF 		movl	$2147483647, -16(%rbp)
 8345F001 		addl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L73
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L74
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B4DF4   		movl	-12(%rbp), %ecx
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC6(%rip), %r8
 89C7     		movl	%eax, %edi
 E86CF6FF 		call	TestLanguage_TestShiftResult
 8B45F4   		movl	-12(%rbp), %eax
 4898     		cltq
 4801C0   		addq	%rax, %rax
 8945F4   		movl	%eax, -12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$31, -4(%rbp)
 0F8E23FF 		jle	.L75
 66C745FC 		movw	$1, -4(%rbp)
 66C745FA 		movw	$1, -6(%rbp)
 E91A0100 		jmp	.L76
 66C745EA 		movw	$32767, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 83C001   		addl	$1, %eax
 668945EA 		movw	%ax, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7814     		js	.L77
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 EB14     		jmp	.L78
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBF45EA 		movswl	-22(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E8D3F5FF 		call	TestLanguage_TestShiftResult
 66C745EA 		movw	$32767, -22(%rbp)
 0FB745EA 		movzwl	-22(%rbp), %eax
 83C001   		addl	$1, %eax
 668945EA 		movw	%ax, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7832     		js	.L79
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 EB2C     		jmp	.L80
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 8945EC   		movl	%eax, -20(%rbp)
 0FBF4DFA 		movswl	-6(%rbp), %ecx
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBF45EA 		movswl	-22(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC7(%rip), %r8
 89C7     		movl	%eax, %edi
 E837F5FF 		call	TestLanguage_TestShiftResult
 480FBF45 		movswq	-6(%rbp), %rax
 4801C0   		addq	%rax, %rax
 668945FA 		movw	%ax, -6(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$15, -4(%rbp)
 0F8EDBFE 		jle	.L81
 66C745FC 		movw	$1, -4(%rbp)
 C645FF01 		movb	$1, -1(%rbp)
 E91B0100 		jmp	.L82
 C645E97F 		movb	$127, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 83C001   		addl	$1, %eax
 8845E9   		movb	%al, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7816     		js	.L83
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 EB16     		jmp	.L84
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBE45E9 		movsbl	-23(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E89EF4FF 		call	TestLanguage_TestShiftResult
 C645E97F 		movb	$127, -23(%rbp)
 0FB645E9 		movzbl	-23(%rbp), %eax
 83C001   		addl	$1, %eax
 8845E9   		movb	%al, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7834     		js	.L85
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 EB2E     		jmp	.L86
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBE4DFF 		movsbl	-1(%rbp), %ecx
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBE45E9 		movsbl	-23(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90700 		movl	$7, %r9d
 4C8D0500 		leaq	.LC8(%rip), %r8
 89C7     		movl	%eax, %edi
 E801F4FF 		call	TestLanguage_TestShiftResult
 480FBE45 		movsbq	-1(%rbp), %rax
 4801C0   		addq	%rax, %rax
 8845FF   		movb	%al, -1(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$7, -4(%rbp)
 0F8EDAFE 		jle	.L87
 66C745FC 		movw	$-1, -4(%rbp)
 C745F4FF 		movl	$2147483647, -12(%rbp)
 8345F401 		addl	$1, -12(%rbp)
 E9C70000 		jmp	.L88
 C745F001 		movl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L89
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 EB0F     		jmp	.L90
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3EA     		shrl	%cl, %edx
 89D0     		movl	%edx, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E878F3FF 		call	TestLanguage_TestShiftResult
 C745F001 		movl	$1, -16(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 780F     		js	.L91
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3C2     		roll	%cl, %edx
 89D0     		movl	%edx, %eax
 EB21     		jmp	.L92
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89D6     		movl	%edx, %esi
 89C1     		movl	%eax, %ecx
 D3EE     		shrl	%cl, %esi
 8B55F0   		movl	-16(%rbp), %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C020   		addl	$32, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 8B4DF4   		movl	-12(%rbp), %ecx
 8B55EC   		movl	-20(%rbp), %edx
 8B45F0   		movl	-16(%rbp), %eax
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E816F3FF 		call	TestLanguage_TestShiftResult
 8B45F4   		movl	-12(%rbp), %eax
 D1E8     		shrl	%eax
 8945F4   		movl	%eax, -12(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-31, -4(%rbp)
 0F8D2EFF 		jge	.L93
 66C745FC 		movw	$-1, -4(%rbp)
 66C745FA 		movw	$32767, -6(%rbp)
 0FB745FA 		movzwl	-6(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FA 		movw	%ax, -6(%rbp)
 E9030100 		jmp	.L94
 66C745EA 		movw	$1, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7814     		js	.L95
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 EB14     		jmp	.L96
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 98       		cwtl
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBF45EA 		movswl	-22(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E880F2FF 		call	TestLanguage_TestShiftResult
 66C745EA 		movw	$1, -22(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7832     		js	.L97
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9100000 		movl	$16, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 EB2C     		jmp	.L98
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB745EA 		movzwl	-22(%rbp), %eax
 0FB7D0   		movzwl	%ax, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C010   		addl	$16, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 98       		cwtl
 8945EC   		movl	%eax, -20(%rbp)
 0FBF4DFA 		movswl	-6(%rbp), %ecx
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBF45EA 		movswl	-22(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E8EFF1FF 		call	TestLanguage_TestShiftResult
 0FB745FA 		movzwl	-6(%rbp), %eax
 66D1E8   		shrw	%ax
 668945FA 		movw	%ax, -6(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-15, -4(%rbp)
 0F8DF2FE 		jge	.L99
 66C745FC 		movw	$-1, -4(%rbp)
 C645FF7F 		movb	$127, -1(%rbp)
 0FB645FF 		movzbl	-1(%rbp), %eax
 83C001   		addl	$1, %eax
 8845FF   		movb	%al, -1(%rbp)
 E9050100 		jmp	.L100
 C645E901 		movb	$1, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7816     		js	.L101
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 EB16     		jmp	.L102
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 0FBEC0   		movsbl	%al, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBE45E9 		movsbl	-23(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC4(%rip), %r8
 B9000000 		movl	$0, %ecx
 89C7     		movl	%eax, %edi
 E857F1FF 		call	TestLanguage_TestShiftResult
 C645E901 		movb	$1, -23(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7834     		js	.L103
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 B9080000 		movl	$8, %ecx
 29C1     		subl	%eax, %ecx
 89C8     		movl	%ecx, %eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 EB2E     		jmp	.L104
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 F7D8     		negl	%eax
 89C1     		movl	%eax, %ecx
 D3FA     		sarl	%cl, %edx
 89D0     		movl	%edx, %eax
 89C6     		movl	%eax, %esi
 0FB645E9 		movzbl	-23(%rbp), %eax
 0FB6D0   		movzbl	%al, %edx
 0FBF45FC 		movswl	-4(%rbp), %eax
 83C008   		addl	$8, %eax
 89C1     		movl	%eax, %ecx
 D3E2     		sall	%cl, %edx
 89D0     		movl	%edx, %eax
 09F0     		orl	%esi, %eax
 0FBEC0   		movsbl	%al, %eax
 8945EC   		movl	%eax, -20(%rbp)
 0FBE4DFF 		movsbl	-1(%rbp), %ecx
 0FBF75FC 		movswl	-4(%rbp), %esi
 0FBE45E9 		movsbl	-23(%rbp), %eax
 8B55EC   		movl	-20(%rbp), %edx
 41B90400 		movl	$4, %r9d
 4C8D0500 		leaq	.LC9(%rip), %r8
 89C7     		movl	%eax, %edi
 E8C4F0FF 		call	TestLanguage_TestShiftResult
 0FB645FF 		movzbl	-1(%rbp), %eax
 D0E8     		shrb	%al
 8845FF   		movb	%al, -1(%rbp)
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$-7, -4(%rbp)
 0F8DF0FE 		jge	.L105
 C645E001 		movb	$1, -32(%rbp)
 0FB645E0 		movzbl	-32(%rbp), %eax
 C1E002   		sall	$2, %eax
 8845E0   		movb	%al, -32(%rbp)
 0FB645E0 		movzbl	-32(%rbp), %eax
 C0E802   		shrb	$2, %al
 89C2     		movl	%eax, %edx
 0FB645E0 		movzbl	-32(%rbp), %eax
 C1E006   		sall	$6, %eax
 09D0     		orl	%edx, %eax
 8845E0   		movb	%al, -32(%rbp)
 807DE001 		cmpb	$1, -32(%rbp)
 740A     		je	.L106
 BF5D0000 		movl	$93, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C645DF01 		movb	$1, -33(%rbp)
 0FB645DF 		movzbl	-33(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E002   		sall	$2, %eax
 8845DF   		movb	%al, -33(%rbp)
 0FB645DF 		movzbl	-33(%rbp), %eax
 C0E802   		shrb	$2, %al
 89C2     		movl	%eax, %edx
 0FB645DF 		movzbl	-33(%rbp), %eax
 0FB6C0   		movzbl	%al, %eax
 C1E006   		sall	$6, %eax
 09D0     		orl	%edx, %eax
 8845DF   		movb	%al, -33(%rbp)
 488D45DF 		leaq	-33(%rbp), %rax
 0FB600   		movzbl	(%rax), %eax
 3C01     		cmpb	$1, %al
 740A     		je	.L3
 BF5E0000 		movl	$94, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C9       		leave
 C3       		ret
 203D2000 		.string	" = "
 2C206578 		.string	", expected "
 70656374 
 65642000 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 8975F8   		movl	%esi, -8(%rbp)
 488955F0 		movq	%rdx, -16(%rbp)
 48894DE8 		movq	%rcx, -24(%rbp)
 488B4DE8 		movq	-24(%rbp), %rcx
 488B45E8 		movq	-24(%rbp), %rax
 488D500F 		leaq	15(%rax), %rdx
 B8100000 		movl	$16, %eax
 4883E801 		subq	$1, %rax
 4801D0   		addq	%rdx, %rax
 BE100000 		movl	$16, %esi
 BA000000 		movl	$0, %edx
 48F7F6   		divq	%rsi
 486BC010 		imulq	$16, %rax, %rax
 4829C4   		subq	%rax, %rsp
 4889E0   		movq	%rsp, %rax
 4883C00F 		addq	$15, %rax
 48C1E804 		shrq	$4, %rax
 48C1E004 		salq	$4, %rax
 4889C7   		movq	%rax, %rdi
 488B45F0 		movq	-16(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945F0 		movq	%rax, -16(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 3B45F8   		cmpl	-8(%rbp), %eax
 745E     		je	.L108
 488B55E8 		movq	-24(%rbp), %rdx
 488B45F0 		movq	-16(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_String@PLT
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC10(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45F8   		movl	-8(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 E8000000 		call	Console_Ln@PLT
 C9       		leave
 C3       		ret
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
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 53       		pushq	%rbx
 4883EC18 		subq	$24, %rsp
 66C745EE 		movw	$2, -18(%rbp)
 66C745EC 		movw	$4, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L113
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L113
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L114
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC12(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8C4FEFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E888FFFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E879FFFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC13(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E883FEFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$5, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L115
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L115
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L116
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC14(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E835FEFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8F9FEFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8EAFEFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC15(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8F4FDFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$6, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L117
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L117
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L118
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC16(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8A6FDFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E86AFEFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E85BFEFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC17(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E865FDFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$7, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L119
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L119
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L120
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC18(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E817FDFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8DBFDFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8CCFDFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC19(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8D6FCFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-4, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L121
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L121
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L122
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC20(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E888FCFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E84CFDFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E83DFDFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC21(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E847FCFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-5, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L123
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L123
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L124
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC22(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8F9FBFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8BDFCFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8AEFCFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC23(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8B8FBFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-6, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L125
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L125
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L126
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC24(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E86AFBFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E82EFCFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E81FFCFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC25(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E829FBFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-7, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L127
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L127
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L128
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC26(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E8DBFAFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E89FFBFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E890FBFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC27(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E89AFAFF 		call	TestLanguage_TestValue
 66C745EE 		movw	$-2, -18(%rbp)
 66C745EC 		movw	$4, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L129
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L129
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L130
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC28(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E846FAFF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E80AFBFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8FBFAFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC29(%rip), %rdx
 BEFEFFFF 		movl	$-2, %esi
 89C7     		movl	%eax, %edi
 E805FAFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$5, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L131
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L131
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L132
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC30(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8B7F9FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E87BFAFF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E86CFAFF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC31(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E876F9FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$6, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L133
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L133
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L134
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC32(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E828F9FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8ECF9FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8DDF9FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC33(%rip), %rdx
 BEFDFFFF 		movl	$-3, %esi
 89C7     		movl	%eax, %edi
 E8E7F8FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$7, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L135
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L135
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L136
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90B0000 		movl	$11, %ecx
 488D1500 		leaq	.LC34(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E899F8FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E85DF9FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E84EF9FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC35(%rip), %rdx
 BEFCFFFF 		movl	$-4, %esi
 89C7     		movl	%eax, %edi
 E858F8FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-4, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L137
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L137
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L138
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC36(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E80AF8FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8CEF8FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8BFF8FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC37(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E8C9F7FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-5, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L139
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L139
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L140
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC38(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E87BF7FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E83FF8FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E830F8FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC39(%rip), %rdx
 BE020000 		movl	$2, %esi
 89C7     		movl	%eax, %edi
 E83AF7FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-6, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L141
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L141
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L142
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC40(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8ECF6FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8B0F7FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8A1F7FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC41(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E8ABF6FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-7, -20(%rbp)
 66837DEC 		cmpw	$0, -20(%rbp)
 7E14     		jle	.L143
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0D     		jle	.L143
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 EB15     		jmp	.L144
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC42(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E85DF6FF 		call	TestLanguage_TestValue
 0FBF45EE 		movswl	-18(%rbp), %eax
 89C7     		movl	%eax, %edi
 E821F7FF 		call	TestLanguage_side
 480FBFD8 		movswq	%ax, %rbx
 0FBF45EC 		movswl	-20(%rbp), %eax
 89C7     		movl	%eax, %edi
 E812F7FF 		call	TestLanguage_side
 480FBFC0 		movswq	%ax, %rax
 4889DE   		movq	%rbx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 B9160000 		movl	$22, %ecx
 488D1500 		leaq	.LC43(%rip), %rdx
 BE030000 		movl	$3, %esi
 89C7     		movl	%eax, %edi
 E81CF6FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$4, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L145
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L145
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L146
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L147
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L147
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L148
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC44(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E884F5FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$5, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L149
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L149
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L150
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L151
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L151
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L152
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC45(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8ECF4FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$6, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L153
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L153
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L154
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L155
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L155
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L156
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC46(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E854F4FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$7, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L157
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L157
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L158
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L159
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L159
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L160
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9080000 		movl	$8, %ecx
 488D1500 		leaq	.LC47(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8BCF3FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-4, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L161
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L161
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L162
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L163
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L163
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L164
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC48(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E824F3FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-5, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L165
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L165
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L166
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L167
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L167
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L168
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC49(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E88CF2FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-6, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L169
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L169
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L170
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L171
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L171
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L172
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC50(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8F4F1FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-7, -20(%rbp)
 66C745EE 		movw	$3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L173
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L173
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L174
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L175
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L175
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L176
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC51(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E85CF1FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$4, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L177
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L177
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L178
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L179
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L179
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L180
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC52(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8C4F0FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$5, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L181
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L181
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L182
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L183
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L183
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L184
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC53(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E82CF0FF 		call	TestLanguage_TestValue
 66C745EC 		movw	$6, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L185
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L185
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L186
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L187
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L187
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L188
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC54(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E894EFFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$7, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L189
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L189
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L190
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L191
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L191
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L192
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B9090000 		movl	$9, %ecx
 488D1500 		leaq	.LC55(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8FCEEFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-4, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L193
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L193
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L194
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L195
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L195
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L196
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC56(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E864EEFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-5, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L197
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L197
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L198
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L199
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L199
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L200
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC57(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E8CCEDFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-6, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L201
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L201
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L202
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L203
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L203
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L204
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC58(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E834EDFF 		call	TestLanguage_TestValue
 66C745EC 		movw	$-7, -20(%rbp)
 66C745EE 		movw	$-3, -18(%rbp)
 0FBF5DEC 		movswl	-20(%rbp), %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L205
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L205
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF75EE 		movswl	-18(%rbp), %esi
 99       		cltd
 F7FE     		idivl	%esi
 89C2     		movl	%eax, %edx
 EB17     		jmp	.L206
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 89C2     		movl	%eax, %edx
 0FBF45EE 		movswl	-18(%rbp), %eax
 0FAFC2   		imull	%edx, %eax
 29C3     		subl	%eax, %ebx
 89D8     		movl	%ebx, %eax
 89C3     		movl	%eax, %ebx
 66837DEC 		cmpw	$0, -20(%rbp)
 7E16     		jle	.L207
 66837DEE 		cmpw	$0, -18(%rbp)
 7E0F     		jle	.L207
 0FBF45EC 		movswl	-20(%rbp), %eax
 0FBF4DEE 		movswl	-18(%rbp), %ecx
 99       		cltd
 F7F9     		idivl	%ecx
 89D0     		movl	%edx, %eax
 EB15     		jmp	.L208
 480FBF55 		movswq	-18(%rbp), %rdx
 480FBF45 		movswq	-20(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 B90A0000 		movl	$10, %ecx
 488D1500 		leaq	.LC59(%rip), %rdx
 89DE     		movl	%ebx, %esi
 89C7     		movl	%eax, %edi
 E89CECFF 		call	TestLanguage_TestValue
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
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 66C745FE 		movw	$5, -2(%rbp)
 0FBF45FE 		movswl	-2(%rbp), %eax
 99       		cltd
 31D0     		xorl	%edx, %eax
 29D0     		subl	%edx, %eax
 B90F0000 		movl	$15, %ecx
 488D1500 		leaq	.LC60(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E866ECFF 		call	TestLanguage_TestValue
 66C745FE 		movw	$-5, -2(%rbp)
 0FBF45FE 		movswl	-2(%rbp), %eax
 99       		cltd
 31D0     		xorl	%edx, %eax
 29D0     		subl	%edx, %eax
 B9100000 		movl	$16, %ecx
 488D1500 		leaq	.LC61(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E83FECFF 		call	TestLanguage_TestValue
 C745F805 		movl	$5, -8(%rbp)
 8B45F8   		movl	-8(%rbp), %eax
 99       		cltd
 89D0     		movl	%edx, %eax
 3345F8   		xorl	-8(%rbp), %eax
 29D0     		subl	%edx, %eax
 B90F0000 		movl	$15, %ecx
 488D1500 		leaq	.LC62(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E815ECFF 		call	TestLanguage_TestValue
 C745F8FB 		movl	$-5, -8(%rbp)
 8B45F8   		movl	-8(%rbp), %eax
 99       		cltd
 89D0     		movl	%edx, %eax
 3345F8   		xorl	-8(%rbp), %eax
 29D0     		subl	%edx, %eax
 B9100000 		movl	$16, %ecx
 488D1500 		leaq	.LC63(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8EBEBFF 		call	TestLanguage_TestValue
 48C745F0 		movq	$5, -16(%rbp)
 05000000 
 48837DF0 		cmpq	$0, -16(%rbp)
 7908     		jns	.L210
 488B45F0 		movq	-16(%rbp), %rax
 F7D8     		negl	%eax
 EB04     		jmp	.L211
 488B45F0 		movq	-16(%rbp), %rax
 B9140000 		movl	$20, %ecx
 488D1500 		leaq	.LC64(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8B8EBFF 		call	TestLanguage_TestValue
 48C745F0 		movq	$-5, -16(%rbp)
 FBFFFFFF 
 48837DF0 		cmpq	$0, -16(%rbp)
 7908     		jns	.L212
 488B45F0 		movq	-16(%rbp), %rax
 F7D8     		negl	%eax
 EB04     		jmp	.L213
 488B45F0 		movq	-16(%rbp), %rax
 B9150000 		movl	$21, %ecx
 488D1500 		leaq	.LC65(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E885EBFF 		call	TestLanguage_TestValue
 C9       		leave
 C3       		ret
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
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, TestLanguage_gz(%rip)
 48B8FFFF 		movabsq	$-4646453807679537153, %rax
 FF3FE17A 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8BCFFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC68(%rip), %rdx
 BEFFFFFF 		movl	$-1, %esi
 89C7     		movl	%eax, %edi
 E80CEBFF 		call	TestLanguage_TestValue
 660FEFC0 		pxor	%xmm0, %xmm0
 E880FFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC69(%rip), %rdx
 BE000000 		movl	$0, %esi
 89C7     		movl	%eax, %edi
 E8D0EAFF 		call	TestLanguage_TestValue
 48B80000 		movabsq	$4617315517961601024, %rax
 00000000 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E835FFFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC71(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E885EAFF 		call	TestLanguage_TestValue
 48B80000 		movabsq	$4617878467915022336, %rax
 00000000 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8EAFEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC73(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E83AEAFF 		call	TestLanguage_TestValue
 48B8FBFF 		movabsq	$4618430158611677179, %rax
 FF7FC2F5 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E89FFEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90C0000 		movl	$12, %ecx
 488D1500 		leaq	.LC75(%rip), %rdx
 BE050000 		movl	$5, %esi
 89C7     		movl	%eax, %edi
 E8EFE9FF 		call	TestLanguage_TestValue
 48B80000 		movabsq	$-4606056518893174784, %rax
 00000000 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E854FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC77(%rip), %rdx
 BEFBFFFF 		movl	$-5, %esi
 89C7     		movl	%eax, %edi
 E8A4E9FF 		call	TestLanguage_TestValue
 48B80000 		movabsq	$-4605493568939753472, %rax
 00000000 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E809FEFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC79(%rip), %rdx
 BEFAFFFF 		movl	$-6, %esi
 89C7     		movl	%eax, %edi
 E859E9FF 		call	TestLanguage_TestValue
 48B8FBFF 		movabsq	$-4604941878243098629, %rax
 FF7FC2F5 
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8BEFDFF 		call	TestLanguage_LR
 66480F7E 		movq	%xmm0, %rax
 488945F8 		movq	%rax, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	SYSTEM_ENTIER@PLT
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC81(%rip), %rdx
 BEFAFFFF 		movl	$-6, %esi
 89C7     		movl	%eax, %edi
 E80EE9FF 		call	TestLanguage_TestValue
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
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC82(%rip), %rdx
 BE80FFFF 		movl	$-128, %esi
 BF80FFFF 		movl	$-128, %edi
 E8EDE8FF 		call	TestLanguage_TestValue
 B90E0000 		movl	$14, %ecx
 488D1500 		leaq	.LC83(%rip), %rdx
 BE7F0000 		movl	$127, %esi
 BF7F0000 		movl	$127, %edi
 E8D2E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC84(%rip), %rdx
 BE0080FF 		movl	$-32768, %esi
 BF0080FF 		movl	$-32768, %edi
 E8B7E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC85(%rip), %rdx
 BEFF7F00 		movl	$32767, %esi
 BFFF7F00 		movl	$32767, %edi
 E89CE8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC86(%rip), %rdx
 BE000000 		movl	$-2147483648, %esi
 BF000000 		movl	$-2147483648, %edi
 E881E8FF 		call	TestLanguage_TestValue
 B90D0000 		movl	$13, %ecx
 488D1500 		leaq	.LC87(%rip), %rdx
 BEFFFFFF 		movl	$2147483647, %esi
 BFFFFFFF 		movl	$2147483647, %edi
 E866E8FF 		call	TestLanguage_TestValue
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
 48890500 		movq	%rax, m.2000(%rip)
 E849D9FF 		call	TestLanguage_Shift
 E8EAE8FF 		call	TestLanguage_DivMod
 E8FAFEFF 		call	TestLanguage_IntSize
 E86CFBFF 		call	TestLanguage_Abs
 E891FCFF 		call	TestLanguage_Entier
 BE1B0000 		movl	$27, %esi
 488D3D00 		leaq	.LC89(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
