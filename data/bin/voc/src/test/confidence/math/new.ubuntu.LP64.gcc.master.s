 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 89F8     		movl	%edi, %eax
 8845FC   		movb	%al, -4(%rbp)
 0FB645FC 		movzbl	-4(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Out_Char@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B4DE0 		movq	-32(%rbp), %rcx
 488B45E0 		movq	-32(%rbp), %rax
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
 7412     		je	.L4
 4881EC00 		subq	$4096, %rsp
 48838C24 		orq	$0, 4088(%rsp)
 F80F0000 
 EBE9     		jmp	.L3
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4829D4   		subq	%rdx, %rsp
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4885D2   		testq	%rdx, %rdx
 7410     		je	.L5
 25FF0F00 		andl	$4095, %eax
 4883E808 		subq	$8, %rax
 4801E0   		addq	%rsp, %rax
 48830800 		orq	$0, (%rax)
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
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_String@PLT
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L6
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_Int@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 BF0B0000 		movl	$11, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 488B45F8 		movq	-8(%rbp), %rax
 BF150000 		movl	$21, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 E8000000 		call	Out_Ln@PLT
 90       		nop
 5D       		popq	%rbp
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488B45E0 		movq	-32(%rbp), %rax
 8945FC   		movl	%eax, -4(%rbp)
 E9A60000 		jmp	.L12
 836DFC01 		subl	$1, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 483945E0 		cmpq	%rax, -32(%rbp)
 7E07     		jle	.L13
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 EB0F     		jmp	.L14
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
 7F16     		jg	.L15
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8F8FDFF 		call	mathtest_wc
 EB14     		jmp	.L16
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8E2FDFF 		call	mathtest_wc
 0FBE45FB 		movsbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83F809   		cmpl	$9, %eax
 7F16     		jg	.L17
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8C2FDFF 		call	mathtest_wc
 EB14     		jmp	.L12
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8ACFDFF 		call	mathtest_wc
 837DFC00 		cmpl	$0, -4(%rbp)
 0F8F50FF 		jg	.L18
 90       		nop
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 48897DF0 		movq	%rdi, -16(%rbp)
 488975E8 		movq	%rsi, -24(%rbp)
 488B45F0 		movq	-16(%rbp), %rax
 8B802003 		movl	800(%rax), %eax
 83F863   		cmpl	$99, %eax
 7F0C     		jg	.L20
 488B45F0 		movq	-16(%rbp), %rax
 8B902003 		movl	800(%rax), %edx
 EB0F     		jmp	.L21
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 BA000000 		movl	$0, %edx
 488B45F0 		movq	-16(%rbp), %rax
 4863D2   		movslq	%edx, %rdx
 F20F1045 		movsd	-8(%rbp), %xmm0
 F20F1104 		movsd	%xmm0, (%rax,%rdx,8)
 488B45F0 		movq	-16(%rbp), %rax
 8B802003 		movl	800(%rax), %eax
 8D5001   		leal	1(%rax), %edx
 488B45F0 		movq	-16(%rbp), %rax
 89902003 		movl	%edx, 800(%rax)
 90       		nop
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
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 BE100000 		movl	$16, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E82FFDFF 		call	mathtest_ws
 837DFC0B 		cmpl	$11, -4(%rbp)
 0F871A01 		ja	.L23
 8B45FC   		movl	-4(%rbp), %eax
 488D1485 		leaq	0(,%rax,4), %rdx
 00000000 
 488D0500 		leaq	.L25(%rip), %rax
 8B0402   		movl	(%rdx,%rax), %eax
 4898     		cltq
 488D1500 		leaq	.L25(%rip), %rdx
 4801D0   		addq	%rdx, %rax
 3EFFE0   		notrack jmp	*%rax
 00000000 		.long	.L36-.L25
 00000000 		.long	.L35-.L25
 00000000 		.long	.L34-.L25
 00000000 		.long	.L33-.L25
 00000000 		.long	.L32-.L25
 00000000 		.long	.L31-.L25
 00000000 		.long	.L30-.L25
 00000000 		.long	.L29-.L25
 00000000 		.long	.L28-.L25
 00000000 		.long	.L27-.L25
 00000000 		.long	.L26-.L25
 00000000 		.long	.L24-.L25
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8F0FCFF 		call	mathtest_ws
 E9FF0000 		jmp	.L37
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8DAFCFF 		call	mathtest_ws
 E9E90000 		jmp	.L37
 BE0B0000 		movl	$11, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8C4FCFF 		call	mathtest_ws
 E9D30000 		jmp	.L37
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC4(%rip), %rdi
 E8AEFCFF 		call	mathtest_ws
 E9BD0000 		jmp	.L37
 BE0D0000 		movl	$13, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E898FCFF 		call	mathtest_ws
 E9A70000 		jmp	.L37
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC6(%rip), %rdi
 E882FCFF 		call	mathtest_ws
 E9910000 		jmp	.L37
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E86CFCFF 		call	mathtest_ws
 EB7E     		jmp	.L37
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC8(%rip), %rdi
 E859FCFF 		call	mathtest_ws
 EB6B     		jmp	.L37
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E846FCFF 		call	mathtest_ws
 EB58     		jmp	.L37
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC10(%rip), %rdi
 E833FCFF 		call	mathtest_ws
 EB45     		jmp	.L37
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E820FCFF 		call	mathtest_ws
 EB32     		jmp	.L37
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC12(%rip), %rdi
 E80DFCFF 		call	mathtest_ws
 EB1F     		jmp	.L37
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 4889C7   		movq	%rax, %rdi
 E8EDFCFF 		call	mathtest_wi
 BE0D0000 		movl	$13, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E8EDFBFF 		call	mathtest_ws
 90       		nop
 BE030000 		movl	$3, %esi
 488D3D00 		leaq	.LC14(%rip), %rdi
 E8DBFBFF 		call	mathtest_ws
 90       		nop
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math."
 2800     		.string	"("
 293A2000 		.string	"): "
 2E20204D 		.string	".  MathL."
 6174684C 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488955D8 		movq	%rdx, -40(%rbp)
 48894DD0 		movq	%rcx, -48(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B4DE0 		movq	-32(%rbp), %rcx
 488B45E0 		movq	-32(%rbp), %rax
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
 7412     		je	.L40
 4881EC00 		subq	$4096, %rsp
 48838C24 		orq	$0, 4088(%rsp)
 F80F0000 
 EBE9     		jmp	.L39
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4829D4   		subq	%rdx, %rsp
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4885D2   		testq	%rdx, %rdx
 7410     		je	.L41
 25FF0F00 		andl	$4095, %eax
 4883E808 		subq	$8, %rax
 4801E0   		addq	%rsp, %rax
 48830800 		orq	$0, (%rax)
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
 C745F000 		movl	$0, -16(%rbp)
 E93A0100 		jmp	.L42
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L43
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L44
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 F20F5AC0 		cvtsd2ss	%xmm0, %xmm0
 F30F1145 		movss	%xmm0, -12(%rbp)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E8C3FAFF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8B0FAFF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E89FFAFF 		call	mathtest_ws
 8B45F4   		movl	-12(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8A6FBFF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E882FAFF 		call	mathtest_ws
 8B45F4   		movl	-12(%rbp), %eax
 488B55D8 		movq	-40(%rbp), %rdx
 660F6EC0 		movd	%eax, %xmm0
 FFD2     		call	*%rdx
 E883FBFF 		call	mathtest_wr
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC18(%rip), %rdi
 E85FFAFF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E84CFAFF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E83BFAFF 		call	mathtest_ws
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L45
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L46
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 66480F6E 		movq	%rax, %xmm0
 E848FBFF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8FFF9FF 		call	mathtest_ws
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L47
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L48
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 488B55D0 		movq	-48(%rbp), %rdx
 66480F6E 		movq	%rax, %xmm0
 FFD2     		call	*%rdx
 E806FBFF 		call	mathtest_wlr
 E828FBFF 		call	mathtest_wl
 8345F001 		addl	$1, -16(%rbp)
 8B853003 		movl	816(%rbp), %eax
 3945F0   		cmpl	%eax, -16(%rbp)
 0F8CB7FE 		jl	.L49
 E810FBFF 		call	mathtest_wl
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L50
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
 488955D8 		movq	%rdx, -40(%rbp)
 48894DD0 		movq	%rcx, -48(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B4DE0 		movq	-32(%rbp), %rcx
 488B45E0 		movq	-32(%rbp), %rax
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
 7412     		je	.L53
 4881EC00 		subq	$4096, %rsp
 48838C24 		orq	$0, 4088(%rsp)
 F80F0000 
 EBE9     		jmp	.L52
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4829D4   		subq	%rdx, %rsp
 4889C2   		movq	%rax, %rdx
 81E2FF0F 		andl	$4095, %edx
 4885D2   		testq	%rdx, %rdx
 7410     		je	.L54
 25FF0F00 		andl	$4095, %eax
 4883E808 		subq	$8, %rax
 4801E0   		addq	%rsp, %rax
 48830800 		orq	$0, (%rax)
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
 C745F000 		movl	$0, -16(%rbp)
 E9400100 		jmp	.L55
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L56
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L57
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 F20F1044 		movsd	16(%rbp,%rax,8), %xmm0
 F20F5AC0 		cvtsd2ss	%xmm0, %xmm0
 F30F1145 		movss	%xmm0, -12(%rbp)
 BE060000 		movl	$6, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E885F8FF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E872F8FF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E861F8FF 		call	mathtest_ws
 8B45F4   		movl	-12(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E868F9FF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E844F8FF 		call	mathtest_ws
 8B45F4   		movl	-12(%rbp), %eax
 488B55D8 		movq	-40(%rbp), %rdx
 660F6EC0 		movd	%eax, %xmm0
 FFD2     		call	*%rdx
 4889C7   		movq	%rax, %rdi
 E81EF9FF 		call	mathtest_wi
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC18(%rip), %rdi
 E81EF8FF 		call	mathtest_ws
 488B55E0 		movq	-32(%rbp), %rdx
 488B45E8 		movq	-24(%rbp), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E80BF8FF 		call	mathtest_ws
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC16(%rip), %rdi
 E8FAF7FF 		call	mathtest_ws
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L58
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L59
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 66480F6E 		movq	%rax, %xmm0
 E807F9FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8BEF7FF 		call	mathtest_ws
 837DF063 		cmpl	$99, -16(%rbp)
 7E11     		jle	.L60
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 EB03     		jmp	.L61
 8B45F0   		movl	-16(%rbp), %eax
 4898     		cltq
 488B44C5 		movq	16(%rbp,%rax,8), %rax
 488B55D0 		movq	-48(%rbp), %rdx
 66480F6E 		movq	%rax, %xmm0
 FFD2     		call	*%rdx
 4889C7   		movq	%rax, %rdi
 E879F8FF 		call	mathtest_wi
 E8E4F8FF 		call	mathtest_wl
 8345F001 		addl	$1, -16(%rbp)
 8B853003 		movl	816(%rbp), %eax
 3945F0   		cmpl	%eax, -16(%rbp)
 0F8CB1FE 		jl	.L62
 E8CCF8FF 		call	mathtest_wl
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L63
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math.round("
 2E726F75 
 6E642800 
 2E20204D 		.string	".  MathL.round("
 6174684C 
 2E726F75 
 6E642800 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -24(%rbp)
 F20F5A45 		cvtsd2ss	-24(%rbp), %xmm0
 F30F1145 		movss	%xmm0, -4(%rbp)
 BE0C0000 		movl	$12, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E82AF7FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E831F8FF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E80DF7FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Math_round@PLT
 4889C7   		movq	%rax, %rdi
 E8E8F7FF 		call	mathtest_wi
 BE100000 		movl	$16, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8E8F6FF 		call	mathtest_ws
 488B45E8 		movq	-24(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E812F8FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8C9F6FF 		call	mathtest_ws
 488B45E8 		movq	-24(%rbp), %rax
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	MathL_round@PLT
 4889C7   		movq	%rax, %rdi
 E8A2F7FF 		call	mathtest_wi
 E80DF8FF 		call	mathtest_wl
 90       		nop
 C9       		leave
 C3       		ret
 4D617468 		.string	"Math.sqrt("
 2E737172 
 2E20204D 		.string	".  MathL.sqrt("
 6174684C 
 2E737172 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -24(%rbp)
 F20F5A45 		cvtsd2ss	-24(%rbp), %xmm0
 F30F1145 		movss	%xmm0, -4(%rbp)
 BE0B0000 		movl	$11, %esi
 488D3D00 		leaq	.LC21(%rip), %rdi
 E87FF6FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E886F7FF 		call	mathtest_wr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E862F6FF 		call	mathtest_ws
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Math_sqrt@PLT
 E864F7FF 		call	mathtest_wr
 BE0F0000 		movl	$15, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E840F6FF 		call	mathtest_ws
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 E86EF7FF 		call	mathtest_wlr
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E825F6FF 		call	mathtest_ws
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 E8000000 		call	MathL_sqrt@PLT
 E84EF7FF 		call	mathtest_wlr
 E870F7FF 		call	mathtest_wl
 90       		nop
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
 48890500 		movq	%rax, m.2342(%rip)
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488D1500 		leaq	200+mathtest_Values__desc(%rip), %rdx
 488910   		movq	%rdx, (%rax)
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 48890500 		movq	%rax, 64+mathtest_Values__desc(%rip)
 488B0500 		movq	m.2342(%rip), %rax
 48890500 		movq	%rax, 32+mathtest_Values__desc(%rip)
 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 483D2803 		cmpq	$808, %rax
 740A     		je	.L67
 BFF1FFFF 		movl	$-15, %edi
 E8000000 		call	Modules_Halt@PLT
 488B0500 		movq	200+mathtest_Values__desc(%rip), %rax
 4883C027 		addq	$39, %rax
 4883E0E0 		andq	$-32, %rax
 48890500 		movq	%rax, 200+mathtest_Values__desc(%rip)
 488D1500 		leaq	16+mathtest_Values__desc(%rip), %rdx
 488B0500 		movq	m.2342(%rip), %rax
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
 E8EAF4FF 		call	mathtest_ws
 E844F6FF 		call	mathtest_wl
 E83FF6FF 		call	mathtest_wl
 C7050000 		movl	$0, 800+mathtest_misc(%rip)
 00000000 
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC25(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8F4F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC26(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8CFF6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC27(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8AAF6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC28(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E885F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC29(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E860F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC30(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E83BF6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC31(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E816F6FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC32(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8F1F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC33(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8CCF5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC34(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8A7F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC35(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E882F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC36(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E85DF5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC37(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E838F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC38(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E813F5FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC39(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8EEF4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC40(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8C9F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC41(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8A4F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC42(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E87FF4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC43(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E85AF4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC44(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E835F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC45(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E810F4FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC46(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_misc(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8EBF3FF 		call	mathtest_addvalue
 C7050000 		movl	$0, 800+mathtest_angles(%rip)
 00000000 
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8C4F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC48(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E89FF3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC49(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E87AF3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC50(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E855F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC51(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E830F3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC52(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E80BF3FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC53(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8E6F2FF 		call	mathtest_addvalue
 488B0500 		movq	mathtest_Values__typ@GOTPCREL(%rip), %rax
 488B10   		movq	(%rax), %rdx
 488B0500 		movq	.LC54(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 488D3D00 		leaq	mathtest_angles(%rip), %rdi
 66480F6E 		movq	%rax, %xmm0
 E8C1F2FF 		call	mathtest_addvalue
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
 E85BF4FF 		call	mathtest_TestRtoR
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
 E847F6FF 		call	mathtest_TestRtoLI
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
 E8B7F3FF 		call	mathtest_TestRtoR
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
 E865F3FF 		call	mathtest_TestRtoR
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
 E813F3FF 		call	mathtest_TestRtoR
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
 E8C1F2FF 		call	mathtest_TestRtoR
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
 E86FF2FF 		call	mathtest_TestRtoR
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
 E81DF2FF 		call	mathtest_TestRtoR
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
 E8CBF1FF 		call	mathtest_TestRtoR
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
 E879F1FF 		call	mathtest_TestRtoR
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
 E827F1FF 		call	mathtest_TestRtoR
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
 E8D5F0FF 		call	mathtest_TestRtoR
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
 E883F0FF 		call	mathtest_TestRtoR
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
 E831F0FF 		call	mathtest_TestRtoR
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
 E8DFEFFF 		call	mathtest_TestRtoR
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
 E88DEFFF 		call	mathtest_TestRtoR
 4881C430 		addq	$816, %rsp
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 000000   		.align 8
 CDCCCCCC 		.long	3435973837
 CCCCEC3F 		.long	1072483532
 00000000 		.long	0
 0000F03F 		.long	1072693248
 66666666 		.long	1717986918
 6666F63F 		.long	1073112678
 00000000 		.long	0
 0000F83F 		.long	1073217536
 9A999999 		.long	2576980378
 9999F93F 		.long	1073322393
 66666666 		.long	1717986918
 6666FE3F 		.long	1073636966
 00000000 		.long	0
 00000040 		.long	1073741824
 33333333 		.long	858993459
 33330340 		.long	1073951539
 00000000 		.long	0
 00000440 		.long	1074003968
 00000000 		.long	0
 00000840 		.long	1074266112
 00000000 		.long	0
 00001040 		.long	1074790400
 CDCCCCCC 		.long	3435973837
 CCCCECBF 		.long	-1075000116
 00000000 		.long	0
 0000F0BF 		.long	-1074790400
 66666666 		.long	1717986918
 6666F6BF 		.long	-1074370970
 00000000 		.long	0
 0000F8BF 		.long	-1074266112
 9A999999 		.long	2576980378
 9999F9BF 		.long	-1074161255
 66666666 		.long	1717986918
 6666FEBF 		.long	-1073846682
 00000000 		.long	0
 000000C0 		.long	-1073741824
 33333333 		.long	858993459
 333303C0 		.long	-1073532109
 00000000 		.long	0
 000004C0 		.long	-1073479680
 00000000 		.long	0
 000008C0 		.long	-1073217536
 00000000 		.long	0
 000010C0 		.long	-1072693248
 9A999999 		.long	2576980378
 9999B93F 		.long	1069128089
 70732D38 		.long	942502768
 52C1F03F 		.long	1072742738
 282D4454 		.long	1413754152
 FB21F93F 		.long	1073291771
 112D4454 		.long	1413754129
 FB210940 		.long	1074340347
 70732D38 		.long	942502768
 52C1F0BF 		.long	-1074740910
 282D4454 		.long	1413754152
 FB21F9BF 		.long	-1074191877
 112D4454 		.long	1413754129
 FB2109C0 		.long	-1073143301
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
