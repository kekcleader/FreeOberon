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
 488B45E8 		movq	-24(%rbp), %rax
 4889CA   		movq	%rcx, %rdx
 4889C6   		movq	%rax, %rsi
 E8000000 		call	memcpy@PLT
 488945E8 		movq	%rax, -24(%rbp)
 66C745F6 		movw	$0, -10(%rbp)
 EB52     		jmp	.L5
 480FBF45 		movswq	-10(%rbp), %rax
 483945E0 		cmpq	%rax, -32(%rbp)
 7E07     		jle	.L6
 480FBF45 		movswq	-10(%rbp), %rax
 EB0F     		jmp	.L7
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 488B55E8 		movq	-24(%rbp), %rdx
 4801D0   		addq	%rdx, %rax
 0FB600   		movzbl	(%rax), %eax
 0FBED0   		movsbl	%al, %edx
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Write@PLT
 0FB745F6 		movzwl	-10(%rbp), %eax
 83C001   		addl	$1, %eax
 668945F6 		movw	%ax, -10(%rbp)
 480FBF45 		movswq	-10(%rbp), %rax
 483945E0 		cmpq	%rax, -32(%rbp)
 7E33     		jle	.L13
 480FBF45 		movswq	-10(%rbp), %rax
 483945E0 		cmpq	%rax, -32(%rbp)
 7E07     		jle	.L9
 480FBF45 		movswq	-10(%rbp), %rax
 EB0F     		jmp	.L10
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 488B55E8 		movq	-24(%rbp), %rdx
 4801D0   		addq	%rdx, %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 0F8570FF 		jne	.L11
 90       		nop
 488B45F8 		movq	-8(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L12
 E8000000 		call	__stack_chk_fail@PLT
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 BA0A0000 		movl	$10, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Write@PLT
 90       		nop
 5D       		popq	%rbp
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 53       		pushq	%rbx
 4883EC58 		subq	$88, %rsp
 897DAC   		movl	%edi, -84(%rbp)
 64488B04 		movq	%fs:40, %rax
 25280000 
 488945E8 		movq	%rax, -24(%rbp)
 31C0     		xorl	%eax, %eax
 66C745BE 		movw	$0, -66(%rbp)
 837DAC00 		cmpl	$0, -84(%rbp)
 790F     		jns	.L16
 C645C02D 		movb	$45, -64(%rbp)
 0FB745BE 		movzwl	-66(%rbp), %eax
 83C001   		addl	$1, %eax
 668945BE 		movw	%ax, -66(%rbp)
 837DAC00 		cmpl	$0, -84(%rbp)
 7E31     		jle	.L17
 8B4DAC   		movl	-84(%rbp), %ecx
 4863C1   		movslq	%ecx, %rax
 4869C067 		imulq	$1717986919, %rax, %rax
 48C1E820 		shrq	$32, %rax
 89C2     		movl	%eax, %edx
 C1FA02   		sarl	$2, %edx
 89C8     		movl	%ecx, %eax
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 C1E002   		sall	$2, %eax
 01D0     		addl	%edx, %eax
 01C0     		addl	%eax, %eax
 29C1     		subl	%eax, %ecx
 89CA     		movl	%ecx, %edx
 89D0     		movl	%edx, %eax
 8D5830   		leal	48(%rax), %ebx
 EB15     		jmp	.L18
 8B45AC   		movl	-84(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 8D5830   		leal	48(%rax), %ebx
 66837DBE 		cmpw	$29, -66(%rbp)
 7F06     		jg	.L19
 0FBF45BE 		movswl	-66(%rbp), %eax
 EB0F     		jmp	.L20
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 885C05C0 		movb	%bl, -64(%rbp,%rax)
 0FB745BE 		movzwl	-66(%rbp), %eax
 83C001   		addl	$1, %eax
 668945BE 		movw	%ax, -66(%rbp)
 837DAC00 		cmpl	$0, -84(%rbp)
 7E1D     		jle	.L21
 8B45AC   		movl	-84(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 4869D267 		imulq	$1717986919, %rdx, %rdx
 48C1EA20 		shrq	$32, %rdx
 C1FA02   		sarl	$2, %edx
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 EB12     		jmp	.L22
 8B45AC   		movl	-84(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 8945AC   		movl	%eax, -84(%rbp)
 E9B10000 		jmp	.L23
 837DAC00 		cmpl	$0, -84(%rbp)
 7E31     		jle	.L24
 8B4DAC   		movl	-84(%rbp), %ecx
 4863C1   		movslq	%ecx, %rax
 4869C067 		imulq	$1717986919, %rax, %rax
 48C1E820 		shrq	$32, %rax
 89C2     		movl	%eax, %edx
 C1FA02   		sarl	$2, %edx
 89C8     		movl	%ecx, %eax
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 C1E002   		sall	$2, %eax
 01D0     		addl	%edx, %eax
 01C0     		addl	%eax, %eax
 29C1     		subl	%eax, %ecx
 89CA     		movl	%ecx, %edx
 89D0     		movl	%edx, %eax
 8D5830   		leal	48(%rax), %ebx
 EB15     		jmp	.L25
 8B45AC   		movl	-84(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 8D5830   		leal	48(%rax), %ebx
 66837DBE 		cmpw	$29, -66(%rbp)
 7F06     		jg	.L26
 0FBF45BE 		movswl	-66(%rbp), %eax
 EB0F     		jmp	.L27
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 885C05C0 		movb	%bl, -64(%rbp,%rax)
 0FB745BE 		movzwl	-66(%rbp), %eax
 83C001   		addl	$1, %eax
 668945BE 		movw	%ax, -66(%rbp)
 837DAC00 		cmpl	$0, -84(%rbp)
 7E1D     		jle	.L28
 8B45AC   		movl	-84(%rbp), %eax
 4863D0   		movslq	%eax, %rdx
 4869D267 		imulq	$1717986919, %rdx, %rdx
 48C1EA20 		shrq	$32, %rdx
 C1FA02   		sarl	$2, %edx
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 EB12     		jmp	.L29
 8B45AC   		movl	-84(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 8945AC   		movl	%eax, -84(%rbp)
 837DAC00 		cmpl	$0, -84(%rbp)
 0F8F45FF 		jg	.L30
 EB4A     		jmp	.L31
 0FB745BE 		movzwl	-66(%rbp), %eax
 83E801   		subl	$1, %eax
 668945BE 		movw	%ax, -66(%rbp)
 66837DBE 		cmpw	$29, -66(%rbp)
 7F06     		jg	.L32
 0FBF45BE 		movswl	-66(%rbp), %eax
 EB0F     		jmp	.L33
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 0FB64405 		movzbl	-64(%rbp,%rax), %eax
 0FBED0   		movsbl	%al, %edx
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Write@PLT
 66837DBE 		cmpw	$0, -66(%rbp)
 7FAF     		jg	.L34
 90       		nop
 488B45E8 		movq	-24(%rbp), %rax
 64483304 		xorq	%fs:40, %rax
 25280000 
 7405     		je	.L35
 E8000000 		call	__stack_chk_fail@PLT
 4883C458 		addq	$88, %rsp
 5B       		popq	%rbx
 5D       		popq	%rbp
 C3       		ret
 5369676E 		.string	"Signal: "
 616C3A20 
 5369676E 		.string	"Signal "
 616C2000 
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 897DFC   		movl	%edi, -4(%rbp)
 E8000000 		call	Console_Ln@PLT
 BE090000 		movl	$9, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8000000 		call	Console_String@PLT
 8B45FC   		movl	-4(%rbp), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 E8000000 		call	Console_Ln@PLT
 BE080000 		movl	$8, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8FCFBFF 		call	SignalTest_ws
 8B45FC   		movl	-4(%rbp), %eax
 89C7     		movl	%eax, %edi
 E88FFDFF 		call	SignalTest_wi
 E861FDFF 		call	SignalTest_wl
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 89F8     		movl	%edi, %eax
 668945FC 		movw	%ax, -4(%rbp)
 EB2C     		jmp	.L38
 480FBF45 		movswq	-4(%rbp), %rax
 BE020000 		movl	$2, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Console_Int@PLT
 E8000000 		call	Console_Flush@PLT
 BFE80300 		movl	$1000, %edi
 E8000000 		call	Platform_Delay@PLT
 0FB745FC 		movzwl	-4(%rbp), %eax
 83E801   		subl	$1, %eax
 668945FC 		movw	%ax, -4(%rbp)
 66837DFC 		cmpw	$0, -4(%rbp)
 7FCD     		jg	.L39
 E8000000 		call	Console_Ln@PLT
 90       		nop
 C9       		leave
 C3       		ret
 F30F1EFA 		endbr64
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B0500 		movq	SignalTest_result(%rip), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4889C7   		movq	%rax, %rdi
 FFD2     		call	*%rdx
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA180000 		movl	$24, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 90       		nop
 C9       		leave
 C3       		ret
 5369676E 		.string	"SignalTest"
 616C5465 
 72657375 		.string	"result"
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
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Files__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Modules__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Platform__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 488D3554 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2507(%rip)
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Files_New@PLT
 48890500 		movq	%rax, SignalTest_result(%rip)
 488B1500 		movq	SignalTest_result(%rip), %rdx
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 B9000000 		movl	$0, %ecx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Set@PLT
 488B0500 		movq	Modules_ArgCount@GOTPCREL(%rip), %rax
 0FB700   		movzwl	(%rax), %eax
 6683F801 		cmpw	$1, %ax
 7E18     		jle	.L42
 488D3D3F 		leaq	SignalTest_handle(%rip), %rdi
 E8000000 		call	Platform_SetInterruptHandler@PLT
 488D3D33 		leaq	SignalTest_handle(%rip), %rdi
 E8000000 		call	Platform_SetQuitHandler@PLT
 BF040000 		movl	$4, %edi
 E883FEFF 		call	SignalTest_Take5
 488B0500 		movq	SignalTest_result(%rip), %rax
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Files_Register@PLT
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
 04000000 		.long	 1f - 0f
 10000000 		.long	 4f - 1f
 05000000 		.long	 5
 474E5500 		.string	 "GNU"
 020000C0 		.long	 0xc0000002
 04000000 		.long	 3f - 2f
 03000000 		.long	 0x3
 00000000 		.align 8
