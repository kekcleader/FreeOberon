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
 E9A60000 		jmp	.L6
 836DFC01 		subl	$1, -4(%rbp)
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 483B45E0 		cmpq	-32(%rbp), %rax
 7D07     		jge	.L7
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 EB0F     		jmp	.L8
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
 7F16     		jg	.L9
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8D0FEFF 		call	outtest_wc
 EB14     		jmp	.L10
 0FB645FB 		movzbl	-5(%rbp), %eax
 C0E804   		shrb	$4, %al
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8BAFEFF 		call	outtest_wc
 0FBE45FB 		movsbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83F809   		cmpl	$9, %eax
 7F16     		jg	.L11
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C030   		addl	$48, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E89AFEFF 		call	outtest_wc
 EB14     		jmp	.L6
 0FB645FB 		movzbl	-5(%rbp), %eax
 83E00F   		andl	$15, %eax
 83C037   		addl	$55, %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E884FEFF 		call	outtest_wc
 837DFC00 		cmpl	$0, -4(%rbp)
 0F8F50FF 		jg	.L12
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
 E8000000 		call	Out__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.1912(%rip)
 BE200000 		movl	$32, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E832FEFF 		call	outtest_ws
 E8C2FEFF 		call	outtest_wl
 48B80000 		movabsq	$4607182418800017408, %rax
 00000000 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E80BFEFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E89AFEFF 		call	outtest_wh
 E88AFEFF 		call	outtest_wl
 48B89A99 		movabsq	$4607632778762754458, %rax
 99999999 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E8D3FDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E862FEFF 		call	outtest_wh
 E852FEFF 		call	outtest_wl
 48B8CDCC 		movabsq	$4611911198408756429, %rax
 CCCCCCCC 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E89BFDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E82AFEFF 		call	outtest_wh
 E81AFEFF 		call	outtest_wl
 48B89A99 		movabsq	$-4615739258092021350, %rax
 99999999 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E863FDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8F2FDFF 		call	outtest_wh
 E8E2FDFF 		call	outtest_wl
 48B80000 		movabsq	$4652552666608566272, %rax
 00000030 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E82BFDFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8BAFDFF 		call	outtest_wh
 E8AAFDFF 		call	outtest_wl
 48B82F6E 		movabsq	$4562715677519212079, %rax
 A301BC05 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E8F3FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E882FDFF 		call	outtest_wh
 E872FDFF 		call	outtest_wl
 48B8D803 		movabsq	$4653144502486238168, %rax
 4187454A 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E8BBFCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E84AFDFF 		call	outtest_wh
 E83AFDFF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E888FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E817FDFF 		call	outtest_wh
 E807FDFF 		call	outtest_wl
 48B846D2 		movabsq	$4548669923058963014, %rax
 6EF4311F 
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E850FCFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E8DFFCFF 		call	outtest_wh
 E8CFFCFF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8FDFBFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E88CFCFF 		call	outtest_wh
 E87CFCFF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F100D 		movsd	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E89EFBFF 		call	outtest_ws
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	outtest_lr(%rip), %rdi
 E82DFCFF 		call	outtest_wh
 E81DFCFF 		call	outtest_wl
 E818FCFF 		call	outtest_wl
 8B050000 		movl	.LC23(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E866FBFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8F5FBFF 		call	outtest_wh
 E8E5FBFF 		call	outtest_wl
 8B050000 		movl	.LC25(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E833FBFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8C2FBFF 		call	outtest_wh
 E8B2FBFF 		call	outtest_wl
 8B050000 		movl	.LC27(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E800FBFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E88FFBFF 		call	outtest_wh
 E87FFBFF 		call	outtest_wl
 8B050000 		movl	.LC29(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E8CDFAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E85CFBFF 		call	outtest_wh
 E84CFBFF 		call	outtest_wl
 8B050000 		movl	.LC31(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E89AFAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E829FBFF 		call	outtest_wh
 E819FBFF 		call	outtest_wl
 8B050000 		movl	.LC33(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E867FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8F6FAFF 		call	outtest_wh
 E8E6FAFF 		call	outtest_wl
 8B050000 		movl	.LC35(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E834FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8C3FAFF 		call	outtest_wh
 E8B3FAFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E801FAFF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E890FAFF 		call	outtest_wh
 E880FAFF 		call	outtest_wl
 8B050000 		movl	.LC38(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E8CEF9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E85DFAFF 		call	outtest_wh
 E84DFAFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E87DF9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E80CFAFF 		call	outtest_wh
 E8FCF9FF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E821F9FF 		call	outtest_ws
 BE040000 		movl	$4, %esi
 488D3D00 		leaq	outtest_r(%rip), %rdi
 E8B0F9FF 		call	outtest_wh
 E8A0F9FF 		call	outtest_wl
 E89BF9FF 		call	outtest_wl
 E896F9FF 		call	outtest_wl
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC41(%rip), %rdi
 E8F0F8FF 		call	outtest_ws
 E880F9FF 		call	outtest_wl
 BE110000 		movl	$17, %esi
 488D3D00 		leaq	.LC42(%rip), %rdi
 E8DAF8FF 		call	outtest_ws
 BF040000 		movl	$4, %edi
 E846F9FF 		call	outtest_wi
 E860F9FF 		call	outtest_wl
 E85BF9FF 		call	outtest_wl
 BE120000 		movl	$18, %esi
 488D3D00 		leaq	.LC43(%rip), %rdi
 E8B5F8FF 		call	outtest_ws
 E845F9FF 		call	outtest_wl
 E840F9FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E89AF8FF 		call	outtest_ws
 E82AF9FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E884F8FF 		call	outtest_ws
 E814F9FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E86EF8FF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 E8000000 		call	Out_LongReal@PLT
 E8ECF8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E846F8FF 		call	outtest_ws
 48B89A99 		movabsq	$4607632778762754458, %rax
 99999999 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8B9F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E813F8FF 		call	outtest_ws
 48B8CDCC 		movabsq	$4611911198408756429, %rax
 CCCCCCCC 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E886F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8E0F7FF 		call	outtest_ws
 48B89A99 		movabsq	$-4615739258092021350, %rax
 99999999 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E853F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8ADF7FF 		call	outtest_ws
 48B80000 		movabsq	$4652552666608566272, %rax
 00000030 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E820F8FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E87AF7FF 		call	outtest_ws
 48B82F6E 		movabsq	$4562715677519212079, %rax
 A301BC05 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8EDF7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E847F7FF 		call	outtest_ws
 48B8D803 		movabsq	$4653144502486238168, %rax
 4187454A 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BAF7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E814F7FF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E896F7FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E8F0F6FF 		call	outtest_ws
 48B846D2 		movabsq	$4548669923058963014, %rax
 6EF4311F 
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E863F7FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E891F6FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E807F7FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F100D 		movsd	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E829F6FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E89FF6FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8D1F5FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF010000 		movl	$1, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E847F6FF 		call	outtest_wl
 E842F6FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E89CF5FF 		call	outtest_ws
 E82CF6FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E886F5FF 		call	outtest_ws
 E816F6FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E870F5FF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 E8000000 		call	Out_LongReal@PLT
 E8EEF5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E848F5FF 		call	outtest_ws
 48B89A99 		movabsq	$4607632778762754458, %rax
 99999999 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BBF5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E815F5FF 		call	outtest_ws
 48B8CDCC 		movabsq	$4611911198408756429, %rax
 CCCCCCCC 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E888F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8E2F4FF 		call	outtest_ws
 48B89A99 		movabsq	$-4615739258092021350, %rax
 99999999 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E855F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8AFF4FF 		call	outtest_ws
 48B80000 		movabsq	$4652552666608566272, %rax
 00000030 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E822F5FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E87CF4FF 		call	outtest_ws
 48B82F6E 		movabsq	$4562715677519212079, %rax
 A301BC05 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8EFF4FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E849F4FF 		call	outtest_ws
 48B8D803 		movabsq	$4653144502486238168, %rax
 4187454A 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BCF4FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E816F4FF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E898F4FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E8F2F3FF 		call	outtest_ws
 48B846D2 		movabsq	$4548669923058963014, %rax
 6EF4311F 
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E865F4FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E893F3FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E809F4FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F100D 		movsd	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E82BF3FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8A1F3FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8D3F2FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF0C0000 		movl	$12, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E849F3FF 		call	outtest_wl
 E844F3FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E89EF2FF 		call	outtest_ws
 E82EF3FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E888F2FF 		call	outtest_ws
 E818F3FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E872F2FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 E8000000 		call	Out_LongReal@PLT
 E8F0F2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E84AF2FF 		call	outtest_ws
 48B89A99 		movabsq	$4607632778762754458, %rax
 99999999 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BDF2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC7(%rip), %rdi
 E817F2FF 		call	outtest_ws
 48B8CDCC 		movabsq	$4611911198408756429, %rax
 CCCCCCCC 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E88AF2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC9(%rip), %rdi
 E8E4F1FF 		call	outtest_ws
 48B89A99 		movabsq	$-4615739258092021350, %rax
 99999999 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E857F2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC11(%rip), %rdi
 E8B1F1FF 		call	outtest_ws
 48B80000 		movabsq	$4652552666608566272, %rax
 00000030 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E824F2FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC13(%rip), %rdi
 E87EF1FF 		call	outtest_ws
 48B82F6E 		movabsq	$4562715677519212079, %rax
 A301BC05 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8F1F1FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC15(%rip), %rdi
 E84BF1FF 		call	outtest_ws
 48B8D803 		movabsq	$4653144502486238168, %rax
 4187454A 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8BEF1FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E818F1FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_LongReal@PLT
 E89AF1FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC19(%rip), %rdi
 E8F4F0FF 		call	outtest_ws
 48B846D2 		movabsq	$4548669923058963014, %rax
 6EF4311F 
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E867F1FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E895F0FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E80BF1FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 F20F1005 		movsd	.LC2(%rip), %xmm0
 00000000 
 F20F5EC1 		divsd	%xmm1, %xmm0
 F20F100D 		movsd	.LC21(%rip), %xmm1
 00000000 
 660F57C1 		xorpd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E82DF0FF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E8A3F0FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 48890500 		movq	%rax, outtest_lr(%rip)
 F20F100D 		movsd	outtest_lr(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F20F5EC1 		divsd	%xmm1, %xmm0
 66480F7E 		movq	%xmm0, %rax
 48890500 		movq	%rax, outtest_lr(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8D5EFFF 		call	outtest_ws
 488B0500 		movq	outtest_lr(%rip), %rax
 BF280000 		movl	$40, %edi
 488945E8 		movq	%rax, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 E8000000 		call	Out_LongReal@PLT
 E84BF0FF 		call	outtest_wl
 E846F0FF 		call	outtest_wl
 E841F0FF 		call	outtest_wl
 E83CF0FF 		call	outtest_wl
 BE0E0000 		movl	$14, %esi
 488D3D00 		leaq	.LC47(%rip), %rdi
 E896EFFF 		call	outtest_ws
 E826F0FF 		call	outtest_wl
 E821F0FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E87BEFFF 		call	outtest_ws
 E80BF0FF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E865EFFF 		call	outtest_ws
 E8F5EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E84FEFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8CDEFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E827EFFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8A5EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E8FFEEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E87DEFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E8D7EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E855EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E8AFEEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E82DEFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E887EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E805EFFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E85FEEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8DDEEFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E837EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E8B9EEFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E813EEFF 		call	outtest_ws
 BF010000 		movl	$1, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E891EEFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E8C1EDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E839EEFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E85EEDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E8D6EDFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E80AEDFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF010000 		movl	$1, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E882EDFF 		call	outtest_wl
 E87DEDFF 		call	outtest_wl
 BE360000 		movl	$54, %esi
 488D3D00 		leaq	.LC48(%rip), %rdi
 E8D7ECFF 		call	outtest_ws
 E867EDFF 		call	outtest_wl
 BE360000 		movl	$54, %esi
 488D3D00 		leaq	.LC49(%rip), %rdi
 E8C1ECFF 		call	outtest_ws
 E851EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E8ABECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E829EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E883ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E801EDFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E85BECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8D9ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E833ECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8B1ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E80BECFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E889ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E8E3EBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E861ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E8BBEBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E839ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E893EBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E815ECFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E86FEBFF 		call	outtest_ws
 BF0C0000 		movl	$12, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8EDEBFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E81DEBFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E895EBFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E8BAEAFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E832EBFF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E866EAFF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF0C0000 		movl	$12, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E8DEEAFF 		call	outtest_wl
 E8D9EAFF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC44(%rip), %rdi
 E833EAFF 		call	outtest_ws
 E8C3EAFF 		call	outtest_wl
 BE400000 		movl	$64, %esi
 488D3D00 		leaq	.LC45(%rip), %rdi
 E81DEAFF 		call	outtest_ws
 E8ADEAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC24(%rip), %rdi
 E807EAFF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E885EAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E8DFE9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC25(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E85DEAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC28(%rip), %rdi
 E8B7E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC27(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E835EAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC30(%rip), %rdi
 E88FE9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC29(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E80DEAFF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC32(%rip), %rdi
 E867E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC31(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8E5E9FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC34(%rip), %rdi
 E83FE9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC33(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E8BDE9FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC36(%rip), %rdi
 E817E9FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC35(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E895E9FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC17(%rip), %rdi
 E8EFE8FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 660FEFC0 		pxor	%xmm0, %xmm0
 E8000000 		call	Out_Real@PLT
 E871E9FF 		call	outtest_wl
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC39(%rip), %rdi
 E8CBE8FF 		call	outtest_ws
 BF280000 		movl	$40, %edi
 F30F1005 		movss	.LC38(%rip), %xmm0
 00000000 
 E8000000 		call	Out_Real@PLT
 E849E9FF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC20(%rip), %rdi
 E879E8FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E8F1E8FF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 F30F1005 		movss	.LC23(%rip), %xmm0
 00000000 
 F30F5EC1 		divss	%xmm1, %xmm0
 F30F100D 		movss	.LC40(%rip), %xmm1
 00000000 
 0F57C1   		xorps	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC22(%rip), %rdi
 E816E8FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E88EE8FF 		call	outtest_wl
 8B050000 		movl	.LC37(%rip), %eax
 89050000 		movl	%eax, outtest_r(%rip)
 F30F100D 		movss	outtest_r(%rip), %xmm1
 00000000 
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F5EC1 		divss	%xmm1, %xmm0
 660F7EC0 		movd	%xmm0, %eax
 89050000 		movl	%eax, outtest_r(%rip)
 BE180000 		movl	$24, %esi
 488D3D00 		leaq	.LC46(%rip), %rdi
 E8C2E7FF 		call	outtest_ws
 8B050000 		movl	outtest_r(%rip), %eax
 BF280000 		movl	$40, %edi
 8945E8   		movl	%eax, -24(%rbp)
 F30F1045 		movss	-24(%rbp), %xmm0
 E8000000 		call	Out_Real@PLT
 E83AE8FF 		call	outtest_wl
 E835E8FF 		call	outtest_wl
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 0000     		.align 8
 00000000 		.long	0
 0000F03F 		.long	1072693248
 00000000 		.align 16
 00000000 
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
 00000000 		.long	0
 90F90039 		.long	956365200
 00000000 		.align 16
 00000000 
 00000000 
 00000080 		.long	2147483648
 00000000 		.long	0
 00000000 		.long	0
 00000000 		.long	0
