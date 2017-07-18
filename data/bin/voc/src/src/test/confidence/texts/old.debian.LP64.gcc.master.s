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
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 488B1500 		movq	testTexts_T(%rip), %rdx
 488B45F8 		movq	-8(%rbp), %rax
 4889D7   		movq	%rdx, %rdi
 FFD0     		call	*%rax
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA480000 		movl	$72, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_R(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 C9       		leave
 C3       		ret
 74657374 		.string	"testTexts"
 54657874 
 61616100 		.string	"aaa"
 74657374 		.string	"test.txt"
 2E747874 
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
 E8000000 		call	Console__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Texts__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 488D3543 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2285(%rip)
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_OpenWriter@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 B9040000 		movl	$4, %ecx
 488D1500 		leaq	.LC1(%rip), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteString@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteLn@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 BA070000 		movl	$7, %edx
 F30F1005 		movss	.LC2(%rip), %xmm0
 00000000 
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteReal@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteLn@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 B9070000 		movl	$7, %ecx
 BA000000 		movl	$0, %edx
 F30F1005 		movss	.LC2(%rip), %xmm0
 00000000 
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteRealFix@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteLn@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 48B90700 		movabsq	$-4579190761332932601, %rcx
 00A04372 
 BA070000 		movl	$7, %edx
 48894DE8 		movq	%rcx, -24(%rbp)
 F20F1045 		movsd	-24(%rbp), %xmm0
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteLongReal@PLT
 488B0500 		movq	Texts_Writer__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	Texts_WriteLn@PLT
 488B0500 		movq	Texts_TextDesc__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_NEWREC@PLT
 48890500 		movq	%rax, testTexts_T(%rip)
 488B0500 		movq	testTexts_T(%rip), %rax
 BA090000 		movl	$9, %edx
 488D3500 		leaq	.LC4(%rip), %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Texts_Open@PLT
 488B1500 		movq	testTexts_W(%rip), %rdx
 488B0500 		movq	testTexts_T(%rip), %rax
 4889D6   		movq	%rdx, %rsi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Texts_Append@PLT
 488B1500 		movq	testTexts_T(%rip), %rdx
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 B9000000 		movl	$0, %ecx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_R(%rip), %rdi
 E8000000 		call	Texts_OpenReader@PLT
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488D1500 		leaq	testTexts_ch(%rip), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_R(%rip), %rdi
 E8000000 		call	Texts_Read@PLT
 66C70500 		movw	$0, testTexts_i(%rip)
 00000000 
 E9CB0000 		jmp	.L3
 0FB60500 		movzbl	testTexts_ch(%rip), %eax
 3C0D     		cmpb	$13, %al
 7555     		jne	.L4
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L5
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L6
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4863D0   		movslq	%eax, %rdx
 488D0500 		leaq	testTexts_s(%rip), %rax
 C6040200 		movb	$0, (%rdx,%rax)
 66C70500 		movw	$0, testTexts_i(%rip)
 00000000 
 BE000400 		movl	$1024, %esi
 488D3D00 		leaq	testTexts_s(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 EB4B     		jmp	.L7
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L8
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L9
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 0FB60D00 		movzbl	testTexts_ch(%rip), %ecx
 4863D0   		movslq	%eax, %rdx
 488D0500 		leaq	testTexts_s(%rip), %rax
 880C02   		movb	%cl, (%rdx,%rax)
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 83C001   		addl	$1, %eax
 66890500 		movw	%ax, testTexts_i(%rip)
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488D1500 		leaq	testTexts_ch(%rip), %rdx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_R(%rip), %rdi
 E8000000 		call	Texts_Read@PLT
 0FB60500 		movzbl	testTexts_R(%rip), %eax
 84C0     		testb	%al, %al
 0F8426FF 		je	.L10
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L11
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L12
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4863D0   		movslq	%eax, %rdx
 488D0500 		leaq	testTexts_s(%rip), %rax
 C6040200 		movb	$0, (%rdx,%rax)
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 00       		.align 4
 1D929BC3 		.long	3281752605
