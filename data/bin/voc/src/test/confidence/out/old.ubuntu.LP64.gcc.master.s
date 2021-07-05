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
 E9A60000 		jmp	.L10
 836DFC01 		subl	$1, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 483945E0 		cmpq	%rax, -32(%rbp)
 7E07     		jle	.L11
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 EB0F     		jmp	.L12
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
 7F16     		jg	.L13
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E844FEFF 		call	outtest_wc
 EB14     		jmp	.L14
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E82EFEFF 		call	outtest_wc
 0FBE45FB 		movsbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83F809   		cmpl	$9, %eax
 7F16     		jg	.L15
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E80EFEFF 		call	outtest_wc
 EB14     		jmp	.L10
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8F8FDFF 		call	outtest_wc
 837DFC00 		cmpl	$0, -4(%rbp)
 0F8F50FF 		jg	.L16
 90       		nop
 90       		nop
 C9       		leave
 C3       		ret
 6F757474 		.string	"outtest"
 65737400 
 5265616C 		.string	"Real number hex representation."
 206E756D 
 62657220 
 68657820 
 72657072 
 20312E30 		.string	" 1.0D0:                "
 44303A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1D0:                "
 44303A20 
 20202020 
 20202020 
 20202020 
 20322E31 		.string	" 2.1D0:                "
 44303A20 
 20202020 
 20202020 
 20202020 
 2D312E31 		.string	"-1.1D0:                "
 44303A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1D3:                "
 44333A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1D-3:               "
 442D333A 
 20202020 
 20202020 
 20202020 
 20312E32 		.string	" 1.2345678987654321D3: "
 33343536 
 37383938 
 37363534 
 33323144 
 20302E30 		.string	" 0.0:                  "
 3A202020 
 20202020 
 20202020 
 20202020 
 20302E30 		.string	" 0.000123D0:           "
 30303132 
 3344303A 
 20202020 
 20202020 
 20312F30 		.string	" 1/0.0:                "
 2E303A20 
 20202020 
 20202020 
 20202020 
 2D312F30 		.string	"-1/0.0:                "
 2E303A20 
 20202020 
 20202020 
 20202020 
 20312E30 		.string	" 1.0E0:                "
 45303A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1E0:                "
 45303A20 
 20202020 
 20202020 
 20202020 
 20322E31 		.string	" 2.1E0:                "
 45303A20 
 20202020 
 20202020 
 20202020 
 2D312E31 		.string	"-1.1E0:                "
 45303A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1E3:                "
 45333A20 
 20202020 
 20202020 
 20202020 
 20312E31 		.string	" 1.1E-3:               "
 452D333A 
 20202020 
 20202020 
 20202020 
 20312E32 		.string	" 1.2345678987654321E3: "
 33343536 
 37383938 
 37363534 
 33323145 
 20302E30 		.string	" 0.000123E0:           "
 30303132 
 3345303A 
 20202020 
 20202020 
 4F757420 		.string	"Out module tests."
 6D6F6475 
 6C652074 
 65737473 
 53495A45 		.string	"SIZE(INTEGER) = "
 28494E54 
 45474552 
 29203D20 
 54657374 		.string	"Testing LONGREAL."
 696E6720 
 4C4F4E47 
 5245414C 
 000000   		.align 8
 20202020 		.string	"                                1         2         3         4"
 20202020 
 20202020 
 20202020 
 20202020 
 20202020 		.string	"                       1234567890123456789012345678901234567890"
 20202020 
 20202020 
 20202020 
 20202020 
 20302E30 		.string	" 0.0/0.0:              "
 2F302E30 
 3A202020 
 20202020 
 20202020 
 54657374 		.string	"Testing REAL."
 696E6720 
 5245414C 
 0000     		.align 8
 20202020 		.string	"                                1         2         3"
 20202020 
 20202020 
 20202020 
 20202020 
 0000     		.align 8
 20202020 		.string	"                       123456789012345678901234567890"
 20202020 
 20202020 
 20202020 
 20202020 
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
 E8000000 		call	Out__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2080(%rip)
 BE200000 		movl	$32, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8A5FDFF 		call	outtest_ws
 E8B3FEFF 		call	outtest_wl
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E87FFDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E891FEFF 		call	outtest_wh
 E87CFEFF 		call	outtest_wl
 F20F1005 		movsd	.LC4(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E848FDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E85AFEFF 		call	outtest_wh
 E845FEFF 		call	outtest_wl
 F20F1005 		movsd	.LC6(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E811FDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E823FEFF 		call	outtest_wh
 E80EFEFF 		call	outtest_wl
 F20F1005 		movsd	.LC8(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8DAFCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8ECFDFF 		call	outtest_wh
 E8D7FDFF 		call	outtest_wl
 F20F1005 		movsd	.LC10(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8A3FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8B5FDFF 		call	outtest_wh
 E8A0FDFF 		call	outtest_wl
 F20F1005 		movsd	.LC12(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E86CFCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E87EFDFF 		call	outtest_wh
 E869FDFF 		call	outtest_wl
 F20F1005 		movsd	.LC14(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E835FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E847FDFF 		call	outtest_wh
 E832FDFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E802FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E814FDFF 		call	outtest_wh
 E8FFFCFF 		call	outtest_wl
 F20F1005 		movsd	.LC18(%rip), %xmm0
 00000000 
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E8CBFBFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8DDFCFF 		call	outtest_wh
 E8C8FCFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E87CFBFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E88EFCFF 		call	outtest_wh
 E879FCFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F30F7E0D 		movq	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E821FBFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E833FCFF 		call	outtest_wh
 E81EFCFF 		call	outtest_wl
 E819FCFF 		call	outtest_wl
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E8E5FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8F7FBFF 		call	outtest_wh
 E8E2FBFF 		call	outtest_wl
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E8AEFAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8C0FBFF 		call	outtest_wh
 E8ABFBFF 		call	outtest_wl
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E877FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E889FBFF 		call	outtest_wh
 E874FBFF 		call	outtest_wl
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E840FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E852FBFF 		call	outtest_wh
 E83DFBFF 		call	outtest_wl
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E809FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E81BFBFF 		call	outtest_wh
 E806FBFF 		call	outtest_wl
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E8D2F9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8E4FAFF 		call	outtest_wh
 E8CFFAFF 		call	outtest_wl
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E89BF9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8ADFAFF 		call	outtest_wh
 E898FAFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E868F9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E87AFAFF 		call	outtest_wh
 E865FAFF 		call	outtest_wl
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E831F9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E843FAFF 		call	outtest_wh
 E82EFAFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8E2F8FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8F4F9FF 		call	outtest_wh
 E8DFF9FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E888F8FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E89AF9FF 		call	outtest_wh
 E885F9FF 		call	outtest_wl
 E880F9FF 		call	outtest_wl
 E87BF9FF 		call	outtest_wl
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC41(%rip), %rdi
 E857F8FF 		call	outtest_ws
 E865F9FF 		call	outtest_wl
 BE110000 		movl	$17, %esi
 488D3D00 		leaq	.LC42(%rip), %rdi
 E841F8FF 		call	outtest_ws
 BF040000 		movl	$4, %edi
 E826F9FF 		call	outtest_wi
 E845F9FF 		call	outtest_wl
 E840F9FF 		call	outtest_wl
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC43(%rip), %rdi
 E81CF8FF 		call	outtest_ws
 E82AF9FF 		call	outtest_wl
 E825F9FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E801F8FF 		call	outtest_ws
 E80FF9FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E8EBF7FF 		call	outtest_ws
 E8F9F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8D5F7FF 		call	outtest_ws
 488B0500 		movq	.LC2(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8CDF8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E8A9F7FF 		call	outtest_ws
 488B0500 		movq	.LC4(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8A1F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E87DF7FF 		call	outtest_ws
 488B0500 		movq	.LC6(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E875F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E851F7FF 		call	outtest_ws
 488B0500 		movq	.LC8(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E849F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E825F7FF 		call	outtest_ws
 488B0500 		movq	.LC10(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E81DF8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E8F9F6FF 		call	outtest_ws
 488B0500 		movq	.LC12(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8F1F7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E8CDF6FF 		call	outtest_ws
 488B0500 		movq	.LC14(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8C5F7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8A1F6FF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8A1F7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E87DF6FF 		call	outtest_ws
 488B0500 		movq	.LC18(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E875F7FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E829F6FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E821F7FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F30F7E0D 		movq	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E8C9F5FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8C1F6FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E879F5FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E871F6FF 		call	outtest_wl
 E86CF6FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E848F5FF 		call	outtest_ws
 E856F6FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E832F5FF 		call	outtest_ws
 E840F6FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E81CF5FF 		call	outtest_ws
 488B0500 		movq	.LC2(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E814F6FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E8F0F4FF 		call	outtest_ws
 488B0500 		movq	.LC4(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8E8F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E8C4F4FF 		call	outtest_ws
 488B0500 		movq	.LC6(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BCF5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E898F4FF 		call	outtest_ws
 488B0500 		movq	.LC8(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E890F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E86CF4FF 		call	outtest_ws
 488B0500 		movq	.LC10(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E864F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E840F4FF 		call	outtest_ws
 488B0500 		movq	.LC12(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E838F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E814F4FF 		call	outtest_ws
 488B0500 		movq	.LC14(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E80CF5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8E8F3FF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8E8F4FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E8C4F3FF 		call	outtest_ws
 488B0500 		movq	.LC18(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BCF4FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E870F3FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E868F4FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F30F7E0D 		movq	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E810F3FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E808F4FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8C0F2FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8B8F3FF 		call	outtest_wl
 E8B3F3FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E88FF2FF 		call	outtest_ws
 E89DF3FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E879F2FF 		call	outtest_ws
 E887F3FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E863F2FF 		call	outtest_ws
 488B0500 		movq	.LC2(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E85BF3FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E837F2FF 		call	outtest_ws
 488B0500 		movq	.LC4(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E82FF3FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E80BF2FF 		call	outtest_ws
 488B0500 		movq	.LC6(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E803F3FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8DFF1FF 		call	outtest_ws
 488B0500 		movq	.LC8(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8D7F2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8B3F1FF 		call	outtest_ws
 488B0500 		movq	.LC10(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8ABF2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E887F1FF 		call	outtest_ws
 488B0500 		movq	.LC12(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E87FF2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E85BF1FF 		call	outtest_ws
 488B0500 		movq	.LC14(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E853F2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E82FF1FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E82FF2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E80BF1FF 		call	outtest_ws
 488B0500 		movq	.LC18(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E803F2FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8B7F0FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8AFF1FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F30F7E0D 		movq	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E857F0FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E84FF1FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F1105 		movsd	%xmm0, outtest_lr(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E807F0FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8FFF0FF 		call	outtest_wl
 E8FAF0FF 		call	outtest_wl
 E8F5F0FF 		call	outtest_wl
 E8F0F0FF 		call	outtest_wl
 BE0E0000 		movl	$14, %esi
 488D3D00 		leaq	.LC47(%rip), %rdi
 E8CCEFFF 		call	outtest_ws
 E8DAF0FF 		call	outtest_wl
 E8D5F0FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E8B1EFFF 		call	outtest_ws
 E8BFF0FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E89BEFFF 		call	outtest_ws
 E8A9F0FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E885EFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E881F0FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E85DEFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E859F0FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E835EFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E831F0FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E80DEFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E809F0FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E8E5EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8E1EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E8BDEEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8B9EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E895EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E891EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E86DEEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E86DEFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E849EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E845EFFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8F9EDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E8F3EEFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E89CEDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E896EEFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E84EEDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E848EEFF 		call	outtest_wl
 E843EEFF 		call	outtest_wl
 BE360000 		movl	$54, %esi
 488D3D00 		leaq	.LC48(%rip), %rdi
 E81FEDFF 		call	outtest_ws
 E82DEEFF 		call	outtest_wl
 BE360000 		movl	$54, %esi
 488D3D00 		leaq	.LC49(%rip), %rdi
 E809EDFF 		call	outtest_ws
 E817EEFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E8F3ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8EFEDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E8CBECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8C7EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E8A3ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E89FEDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E87BECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E877EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E853ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E84FEDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E82BECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E827EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E803ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8FFECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8DBEBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E8DBECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E8B7EBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8B3ECFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E867EBFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E861ECFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E80AEBFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E804ECFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8BCEAFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E8B6EBFF 		call	outtest_wl
 E8B1EBFF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E88DEAFF 		call	outtest_ws
 E89BEBFF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E877EAFF 		call	outtest_ws
 E885EBFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E861EAFF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E85DEBFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E839EAFF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E835EBFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E811EAFF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E80DEBFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E8E9E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8E5EAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E8C1E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8BDEAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E899E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E895EAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E871E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E86DEAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E849E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E849EAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E825E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E821EAFF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8D5E8FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E8CFE9FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E878E8FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E872E9FF 		call	outtest_wl
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F1105 		movss	%xmm0, outtest_r(%rip)
 00000000 
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E82AE8FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Out_Real@PLT
 E824E9FF 		call	outtest_wl
 E81FE9FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 0000     		.align 8
 00000000 		.long	0
 0000F03F 		.long	1072693248
 9A999999 		.long	2576980378
 9999F13F 		.long	1072798105
 CDCCCCCC 		.long	3435973837
 CCCC0040 		.long	1073794252
 9A999999 		.long	2576980378
 9999F1BF 		.long	-1074685543
 00000000 		.long	0
 00309140 		.long	1083256832
 2F6EA301 		.long	27487791
 BC05523F 		.long	1062340028
 D8034187 		.long	2269184984
 454A9340 		.long	1083394629
 46D26EF4 		.long	4100903494
 311F203F 		.long	1059069745
 00000000 		.long	0
 00000080 		.long	-2147483648
 00000000 		.long	0
 00000000 		.long	0
 0000803F 		.long	1065353216
 CDCC8C3F 		.long	1066192077
 66660640 		.long	1074161254
 CDCC8CBF 		.long	3213675725
 00808944 		.long	1149861888
 E02D903A 		.long	982527456
 2C529A44 		.long	1150964268
 90F90039 		.long	956365200
 00000080 		.long	2147483648
 00000000 		.long	0
 00000000 		.long	0
 00000000 		.long	0
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
