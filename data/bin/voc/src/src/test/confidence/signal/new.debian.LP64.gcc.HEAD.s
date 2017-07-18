 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC20 		subq	$32, %rsp
 48897DE8 		movq	%rdi, -24(%rbp)
 488975E0 		movq	%rsi, -32(%rbp)
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
 66C745FE 		movw	$0, -2(%rbp)
 EB52     		jmp	.L2
 480FBF45 		movswq	-2(%rbp), %rax
 483B45E0 		cmpq	-32(%rbp), %rax
 7D07     		jge	.L3
 480FBF45 		movswq	-2(%rbp), %rax
 EB0F     		jmp	.L4
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
 0FB745FE 		movzwl	-2(%rbp), %eax
 83C001   		addl	$1, %eax
 668945FE 		movw	%ax, -2(%rbp)
 480FBF45 		movswq	-2(%rbp), %rax
 483B45E0 		cmpq	-32(%rbp), %rax
 7D33     		jge	.L1
 480FBF45 		movswq	-2(%rbp), %rax
 483B45E0 		cmpq	-32(%rbp), %rax
 7D07     		jge	.L6
 480FBF45 		movswq	-2(%rbp), %rax
 EB0F     		jmp	.L7
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 488B55E8 		movq	-24(%rbp), %rdx
 4801D0   		addq	%rdx, %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 0F8570FF 		jne	.L8
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 BA0A0000 		movl	$10, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Write@PLT
 5D       		popq	%rbp
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 53       		pushq	%rbx
 4883EC38 		subq	$56, %rsp
 897DCC   		movl	%edi, -52(%rbp)
 66C745EE 		movw	$0, -18(%rbp)
 837DCC00 		cmpl	$0, -52(%rbp)
 790F     		jns	.L11
 C645D02D 		movb	$45, -48(%rbp)
 0FB745EE 		movzwl	-18(%rbp), %eax
 83C001   		addl	$1, %eax
 668945EE 		movw	%ax, -18(%rbp)
 66837DEE 		cmpw	$29, -18(%rbp)
 7F06     		jg	.L12
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 EB0F     		jmp	.L13
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 BB000000 		movl	$0, %ebx
 837DCC00 		cmpl	$0, -52(%rbp)
 7E2A     		jle	.L14
 8B4DCC   		movl	-52(%rbp), %ecx
 BA676666 		movl	$1717986919, %edx
 89C8     		movl	%ecx, %eax
 F7EA     		imull	%edx
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
 83C030   		addl	$48, %eax
 EB15     		jmp	.L15
 8B45CC   		movl	-52(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 83C030   		addl	$48, %eax
 4863D3   		movslq	%ebx, %rdx
 884415D0 		movb	%al, -48(%rbp,%rdx)
 0FB745EE 		movzwl	-18(%rbp), %eax
 83C001   		addl	$1, %eax
 668945EE 		movw	%ax, -18(%rbp)
 837DCC00 		cmpl	$0, -52(%rbp)
 7E1A     		jle	.L16
 8B4DCC   		movl	-52(%rbp), %ecx
 BA676666 		movl	$1717986919, %edx
 89C8     		movl	%ecx, %eax
 F7EA     		imull	%edx
 C1FA02   		sarl	$2, %edx
 89C8     		movl	%ecx, %eax
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 EB12     		jmp	.L17
 8B45CC   		movl	-52(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 8945CC   		movl	%eax, -52(%rbp)
 E9A80000 		jmp	.L18
 66837DEE 		cmpw	$29, -18(%rbp)
 7F06     		jg	.L19
 0FBF5DEE 		movswl	-18(%rbp), %ebx
 EB0F     		jmp	.L20
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 BB000000 		movl	$0, %ebx
 837DCC00 		cmpl	$0, -52(%rbp)
 7E2A     		jle	.L21
 8B4DCC   		movl	-52(%rbp), %ecx
 BA676666 		movl	$1717986919, %edx
 89C8     		movl	%ecx, %eax
 F7EA     		imull	%edx
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
 83C030   		addl	$48, %eax
 EB15     		jmp	.L22
 8B45CC   		movl	-52(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_MOD@PLT
 83C030   		addl	$48, %eax
 4863D3   		movslq	%ebx, %rdx
 884415D0 		movb	%al, -48(%rbp,%rdx)
 0FB745EE 		movzwl	-18(%rbp), %eax
 83C001   		addl	$1, %eax
 668945EE 		movw	%ax, -18(%rbp)
 837DCC00 		cmpl	$0, -52(%rbp)
 7E1A     		jle	.L23
 8B4DCC   		movl	-52(%rbp), %ecx
 BA676666 		movl	$1717986919, %edx
 89C8     		movl	%ecx, %eax
 F7EA     		imull	%edx
 C1FA02   		sarl	$2, %edx
 89C8     		movl	%ecx, %eax
 C1F81F   		sarl	$31, %eax
 29C2     		subl	%eax, %edx
 89D0     		movl	%edx, %eax
 EB12     		jmp	.L24
 8B45CC   		movl	-52(%rbp), %eax
 4898     		cltq
 BE0A0000 		movl	$10, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	SYSTEM_DIV@PLT
 8945CC   		movl	%eax, -52(%rbp)
 837DCC00 		cmpl	$0, -52(%rbp)
 0F8F4EFF 		jg	.L25
 EB4A     		jmp	.L26
 0FB745EE 		movzwl	-18(%rbp), %eax
 83E801   		subl	$1, %eax
 668945EE 		movw	%ax, -18(%rbp)
 66837DEE 		cmpw	$29, -18(%rbp)
 7F06     		jg	.L27
 0FBF45EE 		movswl	-18(%rbp), %eax
 EB0F     		jmp	.L28
 BFFEFFFF 		movl	$-2, %edi
 E8000000 		call	Modules_Halt@PLT
 B8000000 		movl	$0, %eax
 4898     		cltq
 0FB64405 		movzbl	-48(%rbp,%rax), %eax
 0FBED0   		movsbl	%al, %edx
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	Files_Write@PLT
 66837DEE 		cmpw	$0, -18(%rbp)
 7FAF     		jg	.L29
 4883C438 		addq	$56, %rsp
 5B       		popq	%rbx
 5D       		popq	%rbp
 C3       		ret
 5369676E 		.string	"Signal: "
 616C3A20 
 5369676E 		.string	"Signal "
 616C2000 
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
 E8B8FCFF 		call	SignalTest_ws
 8B45FC   		movl	-4(%rbp), %eax
 89C7     		movl	%eax, %edi
 E8CDFDFF 		call	SignalTest_wi
 E8A4FDFF 		call	SignalTest_wl
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 89F8     		movl	%edi, %eax
 668945FC 		movw	%ax, -4(%rbp)
 EB2C     		jmp	.L32
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
 7FCD     		jg	.L33
 E8000000 		call	Console_Ln@PLT
 C9       		leave
 C3       		ret
 55       		pushq	%rbp
 4889E5   		movq	%rsp, %rbp
 4883EC10 		subq	$16, %rsp
 48897DF8 		movq	%rdi, -8(%rbp)
 488B1500 		movq	SignalTest_result(%rip), %rdx
 488B45F8 		movq	-8(%rbp), %rax
 4889D7   		movq	%rdx, %rdi
 FFD0     		call	*%rax
 488B0500 		movq	Files_Rider__typ@GOTPCREL(%rip), %rax
 488B00   		movq	(%rax), %rax
 488B55F8 		movq	-8(%rbp), %rdx
 4989D0   		movq	%rdx, %r8
 B9010000 		movl	$1, %ecx
 BA180000 		movl	$24, %edx
 4889C6   		movq	%rax, %rsi
 488D3D00 		leaq	SignalTest_rider(%rip), %rdi
 E8000000 		call	SYSTEM_ENUMR@PLT
 C9       		leave
 C3       		ret
 5369676E 		.string	"SignalTest"
 616C5465 
 72657375 		.string	"result"
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
 488D355D 		leaq	EnumPtrs(%rip), %rsi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2325(%rip)
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
 7E18     		jle	.L36
 488D3D52 		leaq	SignalTest_handle(%rip), %rdi
 E8000000 		call	Platform_SetInterruptHandler@PLT
 488D3D46 		leaq	SignalTest_handle(%rip), %rdi
 E8000000 		call	Platform_SetQuitHandler@PLT
 BF040000 		movl	$4, %edi
 E891FEFF 		call	SignalTest_Take5
 488B0500 		movq	SignalTest_result(%rip), %rax
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Files_Register@PLT
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
