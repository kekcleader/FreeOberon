 696E7465 		.string	"intest"
 63686172 		.string	"chars:   "
 733A2020 
 696E7465 		.string	"integer: "
 6765723A 
 73747269 		.string	"string:  \""
 6E673A20 
 2200     		.string	"\""
 6C696E65 		.string	"line:    "
 3A202020 
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
 E8000000 		call	In__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 E8000000 		call	Out__init@PLT
 4889C7   		movq	%rax, %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_INCREF@PLT
 BE000000 		movl	$0, %esi
 488D3D00 		leaq	.LC0(%rip), %rdi
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_REGMOD@PLT
 48890500 		movq	%rax, m.1915(%rip)
 488D3D00 		leaq	intest_ch(%rip), %rdi
 E8000000 		call	In_Char@PLT
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC1(%rip), %rdi
 E8000000 		call	Out_String@PLT
 EB1D     		jmp	.L2
 0FB60500 		movzbl	intest_ch(%rip), %eax
 0FB6C0   		movzbl	%al, %eax
 89C7     		movl	%eax, %edi
 E8000000 		call	Out_Char@PLT
 488D3D00 		leaq	intest_ch(%rip), %rdi
 E8000000 		call	In_Char@PLT
 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 740B     		je	.L3
 0FB60500 		movzbl	intest_ch(%rip), %eax
 3C2E     		cmpb	$46, %al
 75CA     		jne	.L4
 E8000000 		call	Out_Ln@PLT
 488D3D00 		leaq	intest_i(%rip), %rdi
 E8000000 		call	In_Int@PLT
 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 742B     		je	.L5
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC2(%rip), %rdi
 E8000000 		call	Out_String@PLT
 8B050000 		movl	intest_i(%rip), %eax
 4898     		cltq
 BE010000 		movl	$1, %esi
 4889C7   		movq	%rax, %rdi
 E8000000 		call	Out_Int@PLT
 E8000000 		call	Out_Ln@PLT
 BE640000 		movl	$100, %esi
 488D3D00 		leaq	intest_s(%rip), %rdi
 E8000000 		call	In_String@PLT
 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 7438     		je	.L6
 BE0B0000 		movl	$11, %esi
 488D3D00 		leaq	.LC3(%rip), %rdi
 E8000000 		call	Out_String@PLT
 BE640000 		movl	$100, %esi
 488D3D00 		leaq	intest_s(%rip), %rdi
 E8000000 		call	Out_String@PLT
 BE020000 		movl	$2, %esi
 488D3D00 		leaq	.LC4(%rip), %rdi
 E8000000 		call	Out_String@PLT
 E8000000 		call	Out_Ln@PLT
 BE640000 		movl	$100, %esi
 488D3D00 		leaq	intest_s(%rip), %rdi
 E8000000 		call	In_Line@PLT
 EB38     		jmp	.L7
 BE0A0000 		movl	$10, %esi
 488D3D00 		leaq	.LC5(%rip), %rdi
 E8000000 		call	Out_String@PLT
 BE640000 		movl	$100, %esi
 488D3D00 		leaq	intest_s(%rip), %rdi
 E8000000 		call	Out_String@PLT
 E8000000 		call	Out_Ln@PLT
 BE640000 		movl	$100, %esi
 488D3D00 		leaq	intest_s(%rip), %rdi
 E8000000 		call	In_Line@PLT
 488B0500 		movq	In_Done@GOTPCREL(%rip), %rax
 0FB600   		movzbl	(%rax), %eax
 84C0     		testb	%al, %al
 75BA     		jne	.L8
 B8000000 		movl	$0, %eax
 E8000000 		call	Heap_FINALL@PLT
 B8000000 		movl	$0, %eax
 C9       		leave
 C3       		ret
