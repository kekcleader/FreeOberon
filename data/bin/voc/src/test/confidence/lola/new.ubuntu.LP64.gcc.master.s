 4C6F6C61 		.string	"Lola"
 000000   		.align 8
 4C6F6C61 		.string	"Lola - compile lola source to verilog source."
 202D2063 
 6F6D7069 
 6C65206C 
 6F6C6120 
 75736167 		.string	"usage:"
 000000   		.align 8
 20206C6F 		.string	"  lola lola-source-file verilog-source-file"
 6C61206C 
 6F6C612D 
 736F7572 
 63652D66 
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
 E8000000 		call	LSB__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	LSC__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	LSV__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Modules__init@PLT
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.2217(%rip)
 488B0500 		movq	Modules_ArgCount@GOTPCREL(%rip), %rax
 0FB700   		movzwl	(%rax), %eax
 6683F802 		cmpw	$2, %ax
 7F53     		jg	.L2
 BE2E0000 		movl	$46, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 E8000000 		call	Console_Ln@PLT
 BE070000 		movl	$7, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 E8000000 		call	Console_Ln@PLT
 BE2C0000 		movl	$44, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Console_String@PLT
 E8000000 		call	Console_Ln@PLT
 E8000000 		call	Console_Ln@PLT
 EB18     		jmp	.L3
 E8000000 		call	LSC_Compile@PLT
 488B0500 		movq	LSB_modname@GOTPCREL(%rip), %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 7405     		je	.L3
 E8000000 		call	LSV_List@PLT
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
