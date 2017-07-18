 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 89F8     		movl	%edi, %eax
 8845FC   		movb	%al, -4(%rbp)
 0FB645FC 		movzbl	-4(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Out_Char@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488975F0 		movq	%rsi, -16(%rbp)
 488B4DF0 		movq	-16(%rbp), %rcx
 488B45F0 		movq	-16(%rbp), %rax
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
 488B45F8 		movq	-8(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945F8 		movq	%rax, -8(%rbp)
 488B55F0 		movq	-16(%rbp), %rdx
 488B45F8 		movq	-8(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_String@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_Int@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 BF0B0000 		movl	$11, %edi
 8945F8   		movl	%eax, -8(%rbp)
 F30F1045 		movss	-8(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 BF150000 		movl	$21, %edi
 488945F0 		movq	%rax, -16(%rbp)
 F20F1045 		movsd	-16(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 E8000000 		call	Out_Ln@PLT
 5D       		popq	%rbp
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488B45E0 		movq	-32(%rbp), %rax
 8945FC   		movl	%eax, -4(%rbp)
 E9A60000 		jmp	.L8
 836DFC01 		subl	$1, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 483B45E0 		cmpq	-32(%rbp), %rax
 7D07     		jge	.L9
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 EB0F     		jmp	.L10
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 488B55E8 		movq	-24(%rbp), %rdx
 4801D0   		addq	%rdx, %rax
 0FB600   		movzbl	(%rax), %eax
 8845FB   		movb	%al, -5(%rbp)
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0F804   		sarb	$4, %al
 480FBEC0 		movsbq	%al, %rax
 83E00F   		andl	$15, %eax
 4883F809 		cmpq	$9, %rax
 7F16     		jg	.L11
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E886FEFF 		call	mathtest_wc
 EB14     		jmp	.L12
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E870FEFF 		call	mathtest_wc
 0FBE45FB 		movsbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83F809   		cmpl	$9, %eax
 7F16     		jg	.L13
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E850FEFF 		call	mathtest_wc
 EB14     		jmp	.L8
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E83AFEFF 		call	mathtest_wc
 837DFC00 		cmpl	$0, -4(%rbp)
 0F8F50FF 		jg	.L14
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 48897DF0 		movq	%rdi, -16(%rbp)
 488975E8 		movq	%rsi, -24(%rbp)
 488B45F0 		movq	-16(%rbp), %rax
 8B802003 		movl	800(%rax), %eax
 83F863   		cmpl	$99, %eax
 7F0C     		jg	.L16
 488B45F0 		movq	-16(%rbp), %rax
 8B802003 		movl	800(%rax), %eax
 EB0F     		jmp	.L17
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 488B55F0 		movq	-16(%rbp), %rdx
 4863C8   		movslq	%eax, %rcx
 488B45F8 		movq	-8(%rbp), %rax
 488904CA 		movq	%rax, (%rdx,%rcx,8)
 488B45F0 		movq	-16(%rbp), %rax
 8B802003 		movl	800(%rax), %eax
 8D5001   		leal	1(%rax), %edx
 488B45F0 		movq	-16(%rbp), %rax
 89902003 		movl	%edx, 800(%rax)
 C9       		leave
 C3       		ret
 3C4D6174 		.string	"<Math(L) error "
 68284C29 
 20657272 
 6F722000 
 4E6F4572 		.string	"NoError"
 726F7200 
 496C6C65 		.string	"IllegalRoot"
 67616C52 
 6F6F7400 
 496C6C65 		.string	"IllegalLog"
 67616C4C 
 4F766572 		.string	"Overflow"
 666C6F77 
 496C6C65 		.string	"IllegalPower"
 67616C50 
 6F776572 
 496C6C65 		.string	"IllegalLogBase"
 67616C4C 
 6F674261 
 496C6C65 		.string	"IllegalTrig"
 67616C54 
 72696700 
 496C6C65 		.string	"IllegalInvTrig"
 67616C49 
 6E765472 
 48797049 		.string	"HypInvTrigClipped"
 6E765472 
 6967436C 
 69707065 
 496C6C65 		.string	"IllegalHypInvTrig"
 67616C48 
 7970496E 
 76547269 
 4C6F7373 		.string	"LossOfAccuracy"
 4F664163 
 63757261 
 556E6465 		.string	"Underflow"
 72666C6F 
 2028756E 		.string	" (unknknown)"
 6B6E6B6E 
 6F776E29 
 3E2000   		.string	"> "
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 BE100000 		movl	$16, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8C5FDFF 		call	mathtest_ws
 837DFC0B 		cmpl	$11, -4(%rbp)
 0F871A01 		ja	.L19
 8B45FC   		movl	-4(%rbp), %eax
 488D1485 		leaq	0(,%rax,4), %rdx
 00000000 
 488D0500 		leaq	.L21(%rip), %rax
 8B0402   		movl	(%rdx,%rax), %eax
 4863D0   		movslq	%eax, %rdx
 488D0500 		leaq	.L21(%rip), %rax
 4801D0   		addq	%rdx, %rax
 FFE0     		jmp	*%rax
 00000000 		.long	.L20-.L21
 00000000 		.long	.L22-.L21
 00000000 		.long	.L23-.L21
 00000000 		.long	.L24-.L21
 00000000 		.long	.L25-.L21
 00000000 		.long	.L26-.L21
 00000000 		.long	.L27-.L21
 00000000 		.long	.L28-.L21
 00000000 		.long	.L29-.L21
 00000000 		.long	.L30-.L21
 00000000 		.long	.L31-.L21
 00000000 		.long	.L32-.L21
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E886FDFF 		call	mathtest_ws
 E9FF0000 		jmp	.L33
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E870FDFF 		call	mathtest_ws
 E9E90000 		jmp	.L33
 BE0B0000 		movl	$11, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E85AFDFF 		call	mathtest_ws
 E9D30000 		jmp	.L33
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC4(%rip), %rdi
 E844FDFF 		call	mathtest_ws
 E9BD0000 		jmp	.L33
 BE0D0000 		movl	$13, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E82EFDFF 		call	mathtest_ws
 E9A70000 		jmp	.L33
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC6(%rip), %rdi
 E818FDFF 		call	mathtest_ws
 E9910000 		jmp	.L33
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E802FDFF 		call	mathtest_ws
 EB7E     		jmp	.L33
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC8(%rip), %rdi
 E8EFFCFF 		call	mathtest_ws
 EB6B     		jmp	.L33
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8DCFCFF 		call	mathtest_ws
 EB58     		jmp	.L33
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC10(%rip), %rdi
 E8C9FCFF 		call	mathtest_ws
 EB45     		jmp	.L33
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8B6FCFF 		call	mathtest_ws
 EB32     		jmp	.L33
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC12(%rip), %rdi
 E8A3FCFF 		call	mathtest_ws
 EB1F     		jmp	.L33
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 4889C7   		movq	%rax, %rdi
 E80AFDFF 		call	mathtest_wi
 BE0D0000 		movl	$13, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E883FCFF 		call	mathtest_ws
 90       		nop
 BE030000 		movl	$3, %esi
 488D3D00 		leaq	.LC14(%rip), %rdi
 E871FCFF 		call	mathtest_ws
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math."
 2800     		.string	"("
 293A2000 		.string	"): "
 2E20204D 		.string	".  MathL."
 6174684C 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC40 		subq	$64, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488955D8 		movq	%rdx, -40(%rbp)
 48894DD0 		movq	%rcx, -48(%rbp)
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
 C745FC00 		movl	$0, -4(%rbp)
 E94A0100 		jmp	.L35
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L36
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L37
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 F20F5AC8 		cvtsd2ss	%xmm0, %xmm1
 F30F114D 		movss	%xmm1, -8(%rbp)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E8BEFBFF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8ABFBFF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E89AFBFF 		call	mathtest_ws
 8B45F8   		movl	-8(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E81FFCFF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E879FBFF 		call	mathtest_ws
 8B55F8   		movl	-8(%rbp), %edx
 488B45D8 		movq	-40(%rbp), %rax
 8955C8   		movl	%edx, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 FFD0     		call	*%rax
 E8F8FBFF 		call	mathtest_wr
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC18(%rip), %rdi
 E852FBFF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E83FFBFF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E82EFBFF 		call	mathtest_ws
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L38
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L39
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E8B8FBFF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8EEFAFF 		call	mathtest_ws
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L40
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L41
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 488B54C5 		movq	16(%rbp,%rax,8), %rdx
 488B45D0 		movq	-48(%rbp), %rax
 488955C8 		movq	%rdx, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 FFD0     		call	*%rax
 E872FBFF 		call	mathtest_wlr
 E893FBFF 		call	mathtest_wl
 8345FC01 		addl	$1, -4(%rbp)
 8B853003 		movl	816(%rbp), %eax
 3B45FC   		cmpl	-4(%rbp), %eax
 0F8FA7FE 		jg	.L42
 E87BFBFF 		call	mathtest_wl
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC40 		subq	$64, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488955D8 		movq	%rdx, -40(%rbp)
 48894DD0 		movq	%rcx, -48(%rbp)
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
 C745FC00 		movl	$0, -4(%rbp)
 E9500100 		jmp	.L44
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L45
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L46
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 F20F5AC8 		cvtsd2ss	%xmm0, %xmm1
 F30F114D 		movss	%xmm1, -8(%rbp)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E8E9F9FF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8D6F9FF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E8C5F9FF 		call	mathtest_ws
 8B45F8   		movl	-8(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E84AFAFF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8A4F9FF 		call	mathtest_ws
 8B55F8   		movl	-8(%rbp), %edx
 488B45D8 		movq	-40(%rbp), %rax
 8955C8   		movl	%edx, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 FFD0     		call	*%rax
 4889C7   		movq	%rax, %rdi
 E801FAFF 		call	mathtest_wi
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC18(%rip), %rdi
 E87AF9FF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E867F9FF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E856F9FF 		call	mathtest_ws
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L47
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L48
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E8E0F9FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E816F9FF 		call	mathtest_ws
 837DFC63 		cmpl	$99, -4(%rbp)
 7E11     		jle	.L49
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L50
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 488B54C5 		movq	16(%rbp,%rax,8), %rdx
 488B45D0 		movq	-48(%rbp), %rax
 488955C8 		movq	%rdx, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 FFD0     		call	*%rax
 4889C7   		movq	%rax, %rdi
 E854F9FF 		call	mathtest_wi
 E8B8F9FF 		call	mathtest_wl
 8345FC01 		addl	$1, -4(%rbp)
 8B853003 		movl	816(%rbp), %eax
 3B45FC   		cmpl	-4(%rbp), %eax
 0F8FA1FE 		jg	.L51
 E8A0F9FF 		call	mathtest_wl
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math.round("
 2E726F75 
 6E642800 
 2E20204D 		.string	".  MathL.round("
 6174684C 
 2E726F75 
 6E642800 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -24(%rbp)
 F20F5A4D 		cvtsd2ss	-24(%rbp), %xmm1
 F30F114D 		movss	%xmm1, -4(%rbp)
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E897F8FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 8945E0   		movl	%eax, -32(%rbp)
 F30F1045 		movss	-32(%rbp), %xmm0
 E81CF9FF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E876F8FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 8945E0   		movl	%eax, -32(%rbp)
 F30F1045 		movss	-32(%rbp), %xmm0
 E8000000 		call	Math_round@PLT
 4889C7   		movq	%rax, %rdi
 E8D4F8FF 		call	mathtest_wi
 BE100000 		movl	$16, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E84DF8FF 		call	mathtest_ws
 488B45E8 		movq	-24(%rbp), %rax
 488945E0 		movq	%rax, -32(%rbp)
 F20F1045 		movsd	-32(%rbp), %xmm0
 E8F4F8FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E82AF8FF 		call	mathtest_ws
 488B45E8 		movq	-24(%rbp), %rax
 488945E0 		movq	%rax, -32(%rbp)
 F20F1045 		movsd	-32(%rbp), %xmm0
 E8000000 		call	MathL_round@PLT
 4889C7   		movq	%rax, %rdi
 E886F8FF 		call	mathtest_wi
 E8EAF8FF 		call	mathtest_wl
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math.sqrt("
 2E737172 
 2E20204D 		.string	".  MathL.sqrt("
 6174684C 
 2E737172 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -24(%rbp)
 F20F5A4D 		cvtsd2ss	-24(%rbp), %xmm1
 F30F114D 		movss	%xmm1, -4(%rbp)
 BE0B0000 		movl	$11, %esi
 488D3D00 		leaq	.LC21(%rip), %rdi
 E8E1F7FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 8945E4   		movl	%eax, -28(%rbp)
 F30F1045 		movss	-28(%rbp), %xmm0
 E866F8FF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8C0F7FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 8945E4   		movl	%eax, -28(%rbp)
 F30F1045 		movss	-28(%rbp), %xmm0
 E8000000 		call	Math_sqrt@PLT
 E840F8FF 		call	mathtest_wr
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E89AF7FF 		call	mathtest_ws
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 E849F8FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E87FF7FF 		call	mathtest_ws
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 E8000000 		call	MathL_sqrt@PLT
 E829F8FF 		call	mathtest_wlr
 E84AF8FF 		call	mathtest_wl
 C9       		leave
 C3       		ret
 01000000 		.quad	1
 00000000 
 01000000 		.quad	1
 00000000 
 00000000 		.quad	0
 00000000 
 00000000 		.quad	0
 00000000 
 00000000 		.quad	0
 00000000 
 56616C75 		.string	"Values"
 00000000 		.zero	17
 00000000 
 00000000 
 00000000 
 00000000 		.quad	0
 00000000 
 00000000 		.zero	120
 00000000 
 00000000 
 00000000 
 00000000 
 00000000 		.quad	0
 00000000 
 28030000 		.quad	808
 00000000 
 F8FFFFFF 		.quad	-8
 FFFFFFFF 
 6D617468 		.string	"mathtest"
 74657374 
 4D617468 		.string	"Math and MathL module tests."
 20616E64 
 204D6174 
 684C206D 
 6F64756C 
 66726163 		.string	"fraction"
 74696F6E 
 726F756E 		.string	"round"
 73717274 		.string	"sqrt"
 6C6E00   		.string	"ln"
 73696E00 		.string	"sin"
 636F7300 		.string	"cos"
 74616E00 		.string	"tan"
 61726373 		.string	"arcsin"
 61726363 		.string	"arccos"
 61726374 		.string	"arctan"
 73696E68 		.string	"sinh"
 636F7368 		.string	"cosh"
 74616E68 		.string	"tanh"
 61726373 		.string	"arcsinh"
 696E6800 
 61726363 		.string	"arccosh"
 6F736800 
 61726374 		.string	"arctanh"
 616E6800 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 488975F0 		movq	%rsi, -16(%rbp)
 488D55F0 		leaq	-16(%rbp), %rdx
 8B45FC   		movl	-4(%rbp), %eax
 4889D6   		movq	%rdx, %rsi
 89C7     		movl	%eax, %edi
 E8000000 		call	Modules_Init@PLT
 E8000000 		call	Math__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	MathL__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Out__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC23(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2163(%rip)
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488D1500 		leaq	200+mathtest_Values__desc(%rip), %rdx
 488910   		movq	%rdx, (%rax)
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 48890500 		movq	%rax, 64+mathtest_Values__desc(%rip)
 488B0500 		movq	m.2163(%rip), %rax
 48890500 		movq	%rax, 32+mathtest_Values__desc(%rip)
 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 483D2803 		cmpq	$808, %rax
 740A     		je	.L55
 BFF1FFFF 		movl	$-15, %edi
 E8000000 		call	Modules_Halt@PLT
 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 4883C027 		addq	$39, %rax
 48C1E805 		shrq	$5, %rax
 48C1E005 		salq	$5, %rax
 48890500 		movq	%rax, 200+mathtest_Values__desc(%rip)
 488D1500 		leaq	16+mathtest_Values__desc(%rip), %rdx
 488B0500 		movq	m.2163(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGTYP@PLT
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_INHERIT@PLT
 BE1D0000 		movl	$29, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E845F6FF 		call	mathtest_ws
 E81FF7FF 		call	mathtest_wl
 E81AF7FF 		call	mathtest_wl
 C7050000 		movl	$0, 800+mathtest_misc(%rip)
 00000000 
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8CDCC 		movabsq	$4606281698874543309, %rax
 CCCCCCCC 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8BDF7FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 F20F1005 		movsd	.LC26(%rip), %xmm0
 00000000 
 E89CF7FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B86666 		movabsq	$4608983858650965606, %rax
 66666666 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E870F7FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$4609434218613702656, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E844F7FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B89A99 		movabsq	$4609884578576439706, %rax
 99999999 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E818F7FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B86666 		movabsq	$4611235658464650854, %rax
 66666666 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8ECF6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$4611686018427387904, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8C0F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B83333 		movabsq	$4612586738352862003, %rax
 33333333 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E894F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$4612811918334230528, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E868F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$4613937818241073152, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E83CF6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$4616189618054758400, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E810F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8CDCC 		movabsq	$-4617090337980232499, %rax
 CCCCCCCC 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8E4F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 F20F1005 		movsd	.LC37(%rip), %xmm0
 00000000 
 E8C3F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B86666 		movabsq	$-4614388178203810202, %rax
 66666666 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E897F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$-4613937818241073152, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E86BF5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B89A99 		movabsq	$-4613487458278336102, %rax
 99999999 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E83FF5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B86666 		movabsq	$-4612136378390124954, %rax
 66666666 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E813F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$-4611686018427387904, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8E7F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B83333 		movabsq	$-4610785298501913805, %rax
 33333333 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8BBF4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$-4610560118520545280, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E88FF4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$-4609434218613702656, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E863F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B80000 		movabsq	$-4607182418800017408, %rax
 00000000 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E837F4FF 		call	mathtest_addvalue
 C7050000 		movl	$0, 800+mathtest_angles(%rip)
 00000000 
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 660FEFC0 		pxor	%xmm0, %xmm0
 E810F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B89A99 		movabsq	$4591870180066957722, %rax
 99999999 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8E4F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B87073 		movabsq	$4607394977673999216, %rax
 2D3852C1 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8B8F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8282D 		movabsq	$4609753056924675368, %rax
 4454FB21 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E88CF3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8112D 		movabsq	$4614256656552045841, %rax
 4454FB21 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E860F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B87073 		movabsq	$-4615977059180776592, %rax
 2D3852C1 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E834F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8282D 		movabsq	$-4613618979930100440, %rax
 4454FB21 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E808F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 48B8112D 		movabsq	$-4609115380302729967, %rax
 4454FB21 
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8DCF2FF 		call	mathtest_addvalue
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_fraction@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_fraction@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC55(%rip), %rdi
 E86AF4FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_round@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_round@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC56(%rip), %rdi
 E8EDF5FF 		call	mathtest_TestRtoLI
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_sqrt@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_sqrt@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC57(%rip), %rdi
 E8C6F3FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_ln@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_ln@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE030000 		movl	$3, %esi
 488D3D00 		leaq	.LC58(%rip), %rdi
 E874F3FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_angles(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_sin@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_sin@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC59(%rip), %rdi
 E822F3FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_angles(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_cos@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_cos@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC60(%rip), %rdi
 E8D0F2FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_angles(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_tan@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_tan@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC61(%rip), %rdi
 E87EF2FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arcsin@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arcsin@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC62(%rip), %rdi
 E82CF2FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arccos@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arccos@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC63(%rip), %rdi
 E8DAF1FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arctan@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arctan@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC64(%rip), %rdi
 E888F1FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_sinh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_sinh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC65(%rip), %rdi
 E836F1FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_cosh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_cosh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC66(%rip), %rdi
 E8E4F0FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_tanh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_tanh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC67(%rip), %rdi
 E892F0FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arcsinh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arcsinh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC68(%rip), %rdi
 E840F0FF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arccosh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arccosh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC69(%rip), %rdi
 E8EEEFFF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 4883EC08 		subq	$8, %rsp
 4881EC28 		subq	$808, %rsp
 4889E0   		movq	%rsp, %rax
 4889C7   		movq	%rax, %rdi
 488D0500 		leaq	mathtest_misc(%rip), %rax
 BA650000 		movl	$101, %edx
 4889C6   		movq	%rax, %rsi
 4889D1   		movq	%rdx, %rcx
 F348A5   		rep movsq
 488B0500 		movq	MathL_arctanh@GOTPCREL(%rip), %rax
 4889C1   		movq	%rax, %rcx
 488B0500 		movq	Math_arctanh@GOTPCREL(%rip), %rax
 4889C2   		movq	%rax, %rdx
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC70(%rip), %rdi
 E89CEFFF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 000000   		.align 8
 00000000 		.long	0
 0000F03F 		.long	1072693248
 00000000 		.long	0
 0000F0BF 		.long	-1074790400
