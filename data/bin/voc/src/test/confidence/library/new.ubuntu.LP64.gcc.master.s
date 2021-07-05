 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 89F8     		movl	%edi, %eax
 8845FC   		movb	%al, -4(%rbp)
 0FB655FC 		movzbl	-4(%rbp), %edx
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_Write@PLT
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
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B4DE0 		movq	-32(%rbp), %rcx
 488B55E8 		movq	-24(%rbp), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteString@PLT
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
 897DFC   		movl	%edi, -4(%rbp)
 8975F8   		movl	%esi, -8(%rbp)
 8B45F8   		movl	-8(%rbp), %eax
 4863C8   		movslq	%eax, %rcx
 8B45FC   		movl	-4(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteInt@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 89F8     		movl	%edi, %eax
 668945F4 		movw	%ax, -12(%rbp)
 0FBF55F4 		movswl	-12(%rbp), %edx
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B4DF8 		movq	-8(%rbp), %rcx
 66480F6E 		movq	%rcx, %xmm0
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteLongReal@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteLn@PLT
 488B1500 		movq	TestLibrary_W(%rip), %rdx
 488B0500 		movq	Oberon_Log@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Texts_Append@PLT
 90       		nop
 5D       		popq	%rbp
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC40 		subq	$64, %rsp
 F20F1145 		movsd	%xmm0, -56(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488D4DE0 		leaq	-32(%rbp), %rcx
 488B45C8 		movq	-56(%rbp), %rax
 BA140000 		movl	$20, %edx
 4889CE   		movq	%rcx, %rsi
 BF060000 		movl	$6, %edi
 66480F6E 		movq	%rax, %xmm0
 E8000000 		call	Reals_ConvertL@PLT
 66C745DE 		movw	$6, -34(%rbp)
 EB38     		jmp	.L11
 0FB745DE 		movzwl	-34(%rbp), %eax
 83E801   		subl	$1, %eax
 668945DE 		movw	%ax, -34(%rbp)
 66837DDE 		cmpw	$19, -34(%rbp)
 7F06     		jg	.L12
 0FBF45DE 		movswl	-34(%rbp), %eax
 EB0F     		jmp	.L13
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 0FB64405 		movzbl	-32(%rbp,%rax), %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E899FDFF 		call	TestLibrary_tc
 66837DDE 		cmpw	$0, -34(%rbp)
 7FC1     		jg	.L14
 E835FFFF 		call	TestLibrary_tn
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L15
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 F30F1145 		movss	%xmm0, -36(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488D55E0 		leaq	-32(%rbp), %rdx
 8B45DC   		movl	-36(%rbp), %eax
 BE140000 		movl	$20, %esi
 4889D7   		movq	%rdx, %rdi
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Reals_ConvertH@PLT
 C645E800 		movb	$0, -24(%rbp)
 488D45E0 		leaq	-32(%rbp), %rax
 BE140000 		movl	$20, %esi
 4889C7   		movq	%rax, %rdi
 E85AFDFF 		call	TestLibrary_ts
 E8CCFEFF 		call	TestLibrary_tn
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L17
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 72203D20 		.string	"r = "
 2C206920 		.string	", i = "
 202D3E20 		.string	" -> r = "
 72203D20 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 89F8     		movl	%edi, %eax
 668945F8 		movw	%ax, -8(%rbp)
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E816FDFF 		call	TestLibrary_ts
 F30F1045 		movss	-4(%rbp), %xmm0
 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 BF0A0000 		movl	$10, %edi
 E83AFEFF 		call	TestLibrary_tr
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8F2FCFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8D6FDFF 		call	TestLibrary_ti
 0FBF55F8 		movswl	-8(%rbp), %edx
 488D45FC 		leaq	-4(%rbp), %rax
 89D6     		movl	%edx, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8B6FCFF 		call	TestLibrary_ts
 F30F1045 		movss	-4(%rbp), %xmm0
 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 BF0A0000 		movl	$10, %edi
 E8DAFDFF 		call	TestLibrary_tr
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E892FCFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E876FDFF 		call	TestLibrary_ti
 E8EBFDFF 		call	TestLibrary_tn
 90       		nop
 C9       		leave
 C3       		ret
 2C206578 		.string	", exp = "
 70203D20 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E84FFCFF 		call	TestLibrary_ts
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 BF0E0000 		movl	$14, %edi
 E877FDFF 		call	TestLibrary_tr
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E82FFCFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E813FDFF 		call	TestLibrary_ti
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_fraction@PLT
 660F7EC0 		movd	%xmm0, %eax
 8945FC   		movl	%eax, -4(%rbp)
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8F2FBFF 		call	TestLibrary_ts
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 BF0E0000 		movl	$14, %edi
 E81AFDFF 		call	TestLibrary_tr
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8D2FBFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8B6FCFF 		call	TestLibrary_ti
 E82BFDFF 		call	TestLibrary_tn
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945F8 		movq	%rax, -8(%rbp)
 31C0     		xorl	%eax, %eax
 488B0500 		movq	.LC4(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E83CFDFF 		call	TestLibrary_TestConvert
 488B0500 		movq	.LC5(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E82BFDFF 		call	TestLibrary_TestConvert
 488B0500 		movq	.LC6(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E81AFDFF 		call	TestLibrary_TestConvert
 488B0500 		movq	.LC7(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E809FDFF 		call	TestLibrary_TestConvert
 488B0500 		movq	.LC8(%rip), %rax
 66480F6E 		movq	%rax, %xmm0
 E8F8FCFF 		call	TestLibrary_TestConvert
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E88DFDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC10(%rip), %xmm0
 00000000 
 E880FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E873FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC12(%rip), %xmm0
 00000000 
 E866FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC13(%rip), %xmm0
 00000000 
 E859FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC14(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8E3FBFF 		call	TestLibrary_ti
 E858FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8C4FBFF 		call	TestLibrary_ti
 E839FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8A5FBFF 		call	TestLibrary_ti
 E81AFCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC13(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E886FBFF 		call	TestLibrary_ti
 E8FBFBFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC15(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E867FBFF 		call	TestLibrary_ti
 E8DCFBFF 		call	TestLibrary_tn
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E815FDFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC16(%rip), %xmm0
 00000000 
 E803FDFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E8F1FCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC17(%rip), %xmm0
 00000000 
 E8DFFCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC10(%rip), %xmm0
 00000000 
 E8CDFCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC18(%rip), %xmm0
 00000000 
 E8BBFCFF 		call	TestLibrary_TestSetExpo
 F30F1005 		movss	.LC19(%rip), %xmm0
 00000000 
 E87BFDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC20(%rip), %xmm0
 00000000 
 E86EFDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC21(%rip), %xmm0
 00000000 
 E861FDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC22(%rip), %xmm0
 00000000 
 E854FDFF 		call	TestLibrary_TestFractionPart
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1145 		movss	%xmm0, -36(%rbp)
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 740A     		je	.L21
 BF030000 		movl	$3, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 740A     		je	.L22
 BF040000 		movl	$4, %edi
 E8000000 		call	Modules_AssertFail@PLT
 660FEFC0 		pxor	%xmm0, %xmm0
 F30F1145 		movss	%xmm0, -36(%rbp)
 488D45DC 		leaq	-36(%rbp), %rax
 BEFF0000 		movl	$255, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 750A     		jne	.L23
 BF050000 		movl	$5, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 740A     		je	.L24
 BF060000 		movl	$6, %edi
 E8000000 		call	Modules_AssertFail@PLT
 F30F1005 		movss	.LC24(%rip), %xmm0
 00000000 
 F30F1145 		movss	%xmm0, -36(%rbp)
 488D45DC 		leaq	-36(%rbp), %rax
 BEFF0000 		movl	$255, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 740A     		je	.L25
 BF070000 		movl	$7, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 660F6EC0 		movd	%eax, %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 750A     		jne	.L28
 BF080000 		movl	$8, %edi
 E8000000 		call	Modules_AssertFail@PLT
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L27
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA380000 		movl	$56, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 90       		nop
 C9       		leave
 C3       		ret
 54657374 		.string	"TestLibrary"
 4C696272 
 61727900 
 4C696272 		.string	"Library tests successful."
 61727920 
 74657374 
 73207375 
 63636573 
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
 E8000000 		call	Oberon__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Reals__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Texts__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	oocLowReal__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 488D3550 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC25(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2592(%rip)
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_OpenWriter@PLT
 E83AFCFF 		call	TestLibrary_RealTests
 BE1A0000 		movl	$26, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E8DAF7FF 		call	TestLibrary_ts
 E84CF9FF 		call	TestLibrary_tn
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 00000000 		.align 8
 00000000 		.long	0
 0000F03F 		.long	1072693248
 00000000 		.long	0
 0000F83F 		.long	1073217536
 00000000 		.long	0
 00000040 		.long	1073741824
 F9FFFF1F 		.long	536870905
 85EB0740 		.long	1074260869
 00000000 		.long	0
 00000840 		.long	1074266112
 0000803F 		.long	1065353216
 0000C03F 		.long	1069547520
 00000040 		.long	1073741824
 295C3F40 		.long	1077894185
 00004040 		.long	1077936128
 0000003F 		.long	1056964608
 00008040 		.long	1082130432
 000080BF 		.long	3212836864
 000080C0 		.long	3229614080
 0000C0BF 		.long	3217031168
 B6F39D3F 		.long	1067316150
 B6F39DBF 		.long	3214799798
 46B60242 		.long	1107473990
 46B602C2 		.long	3254957638
 6DE7FB3D 		.long	1039918957
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
