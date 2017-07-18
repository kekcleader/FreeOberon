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
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B4DF0 		movq	-16(%rbp), %rcx
 488B55F8 		movq	-8(%rbp), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteString@PLT
 C9       		leave
 C3       		ret
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
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 F20F1145 		movsd	%xmm0, -8(%rbp)
 89F8     		movl	%edi, %eax
 668945F4 		movw	%ax, -12(%rbp)
 0FBF55F4 		movswl	-12(%rbp), %edx
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B4DF8 		movq	-8(%rbp), %rcx
 48894DE8 		movq	%rcx, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_WriteLongReal@PLT
 C9       		leave
 C3       		ret
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
 5D       		popq	%rbp
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 F20F1145 		movsd	%xmm0, -40(%rbp)
 488D4DE0 		leaq	-32(%rbp), %rcx
 488B45D8 		movq	-40(%rbp), %rax
 BA140000 		movl	$20, %edx
 4889CE   		movq	%rcx, %rsi
 BF060000 		movl	$6, %edi
 488945D0 		movq	%rax, -48(%rbp)
 F20F1045 		movsd	-48(%rbp), %xmm0
 E8000000 		call	Reals_ConvertL@PLT
 66C745FE 		movw	$6, -2(%rbp)
 EB38     		jmp	.L7
 0FB745FE 		movzwl	-2(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FE 		movw	%ax, -2(%rbp)
 66837DFE 		cmpw	$19, -2(%rbp)
 7F06     		jg	.L8
 0FBF45FE 		movswl	-2(%rbp), %eax
 EB0F     		jmp	.L9
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 0FB64405 		movzbl	-32(%rbp,%rax), %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E831FEFF 		call	TestLibrary_tc
 66837DFE 		cmpw	$0, -2(%rbp)
 7FC1     		jg	.L10
 E849FFFF 		call	TestLibrary_tn
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC30 		subq	$48, %rsp
 F30F1145 		movss	%xmm0, -36(%rbp)
 488D55E0 		leaq	-32(%rbp), %rdx
 8B45DC   		movl	-36(%rbp), %eax
 BE140000 		movl	$20, %esi
 4889D7   		movq	%rdx, %rdi
 8945D8   		movl	%eax, -40(%rbp)
 F30F1045 		movss	-40(%rbp), %xmm0
 E8000000 		call	Reals_ConvertH@PLT
 C645E800 		movb	$0, -24(%rbp)
 488D45E0 		leaq	-32(%rbp), %rax
 BE140000 		movl	$20, %esi
 4889C7   		movq	%rax, %rdi
 E811FEFF 		call	TestLibrary_ts
 E804FFFF 		call	TestLibrary_tn
 C9       		leave
 C3       		ret
 72203D20 		.string	"r = "
 2C206920 		.string	", i = "
 202D3E20 		.string	" -> r = "
 72203D20 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 89F8     		movl	%edi, %eax
 668945F8 		movw	%ax, -8(%rbp)
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8E6FDFF 		call	TestLibrary_ts
 F30F1045 		movss	-4(%rbp), %xmm0
 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 BF0A0000 		movl	$10, %edi
 E88CFEFF 		call	TestLibrary_tr
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8C2FDFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 F30F1045 		movss	-12(%rbp), %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E829FEFF 		call	TestLibrary_ti
 0FBF55F8 		movswl	-8(%rbp), %edx
 488D45FC 		leaq	-4(%rbp), %rax
 89D6     		movl	%edx, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E882FDFF 		call	TestLibrary_ts
 F30F1045 		movss	-4(%rbp), %xmm0
 F30F5AC0 		cvtss2sd	%xmm0, %xmm0
 BF0A0000 		movl	$10, %edi
 E828FEFF 		call	TestLibrary_tr
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E85EFDFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 8945F4   		movl	%eax, -12(%rbp)
 F30F1045 		movss	-12(%rbp), %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8C5FDFF 		call	TestLibrary_ti
 E834FEFF 		call	TestLibrary_tn
 C9       		leave
 C3       		ret
 2C206578 		.string	", exp = "
 70203D20 
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 F30F1145 		movss	%xmm0, -4(%rbp)
 BE050000 		movl	$5, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E81CFDFF 		call	TestLibrary_ts
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 BF0E0000 		movl	$14, %edi
 E8C6FDFF 		call	TestLibrary_tr
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8FCFCFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 8945F8   		movl	%eax, -8(%rbp)
 F30F1045 		movss	-8(%rbp), %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E863FDFF 		call	TestLibrary_ti
 8B45FC   		movl	-4(%rbp), %eax
 8945F8   		movl	%eax, -8(%rbp)
 F30F1045 		movss	-8(%rbp), %xmm0
 E8000000 		call	oocLowReal_fraction@PLT
 660F7EC0 		movd	%xmm0, %eax
 8945FC   		movl	%eax, -4(%rbp)
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8B7FCFF 		call	TestLibrary_ts
 F30F5A45 		cvtss2sd	-4(%rbp), %xmm0
 BF0E0000 		movl	$14, %edi
 E861FDFF 		call	TestLibrary_tr
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E897FCFF 		call	TestLibrary_ts
 8B45FC   		movl	-4(%rbp), %eax
 8945F8   		movl	%eax, -8(%rbp)
 F30F1045 		movss	-8(%rbp), %xmm0
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8FEFCFF 		call	TestLibrary_ti
 E86DFDFF 		call	TestLibrary_tn
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC40 		subq	$64, %rsp
 F20F1005 		movsd	.LC4(%rip), %xmm0
 00000000 
 E891FDFF 		call	TestLibrary_TestConvert
 48B80000 		movabsq	$4609434218613702656, %rax
 00000000 
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E879FDFF 		call	TestLibrary_TestConvert
 48B80000 		movabsq	$4611686018427387904, %rax
 00000000 
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E861FDFF 		call	TestLibrary_TestConvert
 48B8F9FF 		movabsq	$4613915300264411129, %rax
 FF1F85EB 
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E849FDFF 		call	TestLibrary_TestConvert
 48B80000 		movabsq	$4613937818241073152, %rax
 00000000 
 488945C8 		movq	%rax, -56(%rbp)
 F20F1045 		movsd	-56(%rbp), %xmm0
 E831FDFF 		call	TestLibrary_TestConvert
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E8A2FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC10(%rip), %xmm0
 00000000 
 E895FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E888FDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC12(%rip), %xmm0
 00000000 
 E87BFDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC13(%rip), %xmm0
 00000000 
 E86EFDFF 		call	TestLibrary_TestHex
 F30F1005 		movss	.LC14(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E827FCFF 		call	TestLibrary_ti
 E896FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E808FCFF 		call	TestLibrary_ti
 E877FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8E9FBFF 		call	TestLibrary_ti
 E858FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC13(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8CAFBFF 		call	TestLibrary_ti
 E839FCFF 		call	TestLibrary_tn
 F30F1005 		movss	.LC15(%rip), %xmm0
 00000000 
 E8000000 		call	Reals_Expo@PLT
 98       		cwtl
 BE010000 		movl	$1, %esi
 89C7     		movl	%eax, %edi
 E8ABFBFF 		call	TestLibrary_ti
 E81AFCFF 		call	TestLibrary_tn
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC9(%rip), %xmm0
 00000000 
 E806FDFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC16(%rip), %xmm0
 00000000 
 E8F4FCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC11(%rip), %xmm0
 00000000 
 E8E2FCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC17(%rip), %xmm0
 00000000 
 E8D0FCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC10(%rip), %xmm0
 00000000 
 E8BEFCFF 		call	TestLibrary_TestSetExpo
 BF810000 		movl	$129, %edi
 F30F1005 		movss	.LC18(%rip), %xmm0
 00000000 
 E8ACFCFF 		call	TestLibrary_TestSetExpo
 F30F1005 		movss	.LC19(%rip), %xmm0
 00000000 
 E86FFDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC20(%rip), %xmm0
 00000000 
 E862FDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC21(%rip), %xmm0
 00000000 
 E855FDFF 		call	TestLibrary_TestFractionPart
 F30F1005 		movss	.LC22(%rip), %xmm0
 00000000 
 E848FDFF 		call	TestLibrary_TestFractionPart
 8B050000 		movl	.LC23(%rip), %eax
 8945DC   		movl	%eax, -36(%rbp)
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 740A     		je	.L15
 BF030000 		movl	$3, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 740A     		je	.L16
 BF040000 		movl	$4, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B050000 		movl	.LC23(%rip), %eax
 8945DC   		movl	%eax, -36(%rbp)
 488D45DC 		leaq	-36(%rbp), %rax
 BEFF0000 		movl	$255, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 750A     		jne	.L17
 BF050000 		movl	$5, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 740A     		je	.L18
 BF060000 		movl	$6, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B050000 		movl	.LC24(%rip), %eax
 8945DC   		movl	%eax, -36(%rbp)
 488D45DC 		leaq	-36(%rbp), %rax
 BEFF0000 		movl	$255, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Reals_SetExpo@PLT
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsInfinity@PLT
 84C0     		testb	%al, %al
 740A     		je	.L19
 BF070000 		movl	$7, %edi
 E8000000 		call	Modules_AssertFail@PLT
 8B45DC   		movl	-36(%rbp), %eax
 8945C8   		movl	%eax, -56(%rbp)
 F30F1045 		movss	-56(%rbp), %xmm0
 E8000000 		call	oocLowReal_IsNaN@PLT
 84C0     		testb	%al, %al
 750A     		jne	.L14
 BF080000 		movl	$8, %edi
 E8000000 		call	Modules_AssertFail@PLT
 C9       		leave
 C3       		ret
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
 488D3559 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC25(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2422(%rip)
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	TestLibrary_W(%rip), %rdi
 E8000000 		call	Texts_OpenWriter@PLT
 E83FFCFF 		call	TestLibrary_RealTests
 BE1A0000 		movl	$26, %esi
 488D3D00 		leaq	.LC26(%rip), %rdi
 E8A1F8FF 		call	TestLibrary_ts
 E894F9FF 		call	TestLibrary_tn
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 00000000 		.align 8
 00000000 		.long	0
 0000F03F 		.long	1072693248
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
 00000000 		.long	0
 6DE7FB3D 		.long	1039918957
