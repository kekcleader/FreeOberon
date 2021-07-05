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
 488D3D00 		leaq	testTexts_W(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 488B0500 		movq	testTexts_T(%rip), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4889C7   		movq	%rax, %rdi
 FFD2     		call	*%rdx
 488B0500 		movq	Texts_Reader__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA480000 		movl	$72, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	testTexts_R(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 90       		nop
 C9       		leave
 C3       		ret
 74657374 		.string	"testTexts"
 54657874 
 61616100 		.string	"aaa"
 74657374 		.string	"test.txt"
 2E747874 
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
 E8000000 		call	Texts__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 488D353A 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2455(%rip)
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
 488B0D00 		movq	.LC3(%rip), %rcx
 BA070000 		movl	$7, %edx
 66480F6E 		movq	%rcx, %xmm0
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
 E9C90000 		jmp	.L3
 0FB60500 		movzbl	testTexts_ch(%rip), %eax
 3C0D     		cmpb	$13, %al
 7554     		jne	.L4
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L5
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L6
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 488D1500 		leaq	testTexts_s(%rip), %rdx
 C6041000 		movb	$0, (%rax,%rdx)
 66C70500 		movw	$0, testTexts_i(%rip)
 00000000 
 BE000400 		movl	$1024, %esi
 488D3D00 		leaq	testTexts_s(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 EB4A     		jmp	.L7
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L8
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L9
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 0FB61500 		movzbl	testTexts_ch(%rip), %edx
 4898     		cltq
 488D0D00 		leaq	testTexts_s(%rip), %rcx
 881408   		movb	%dl, (%rax,%rcx)
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
 0F8428FF 		je	.L10
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 663DFF03 		cmpw	$1023, %ax
 7F0A     		jg	.L11
 0FB70500 		movzwl	testTexts_i(%rip), %eax
 98       		cwtl
 EB0F     		jmp	.L12
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 488D1500 		leaq	testTexts_s(%rip), %rdx
 C6041000 		movb	$0, (%rax,%rdx)
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 00       		.align 4
 1D929BC3 		.long	3281752605
 00000000 		.align 8
 070000A0 		.long	2684354567
 437273C0 		.long	-1066175933
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
