55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83EC10   		subl	$16, %esp
C745FC00 		movl	$0, -4(%ebp)
8B55FC   		movl	-4(%ebp), %edx
8B4508   		movl	8(%ebp), %eax
01D0     		addl	%edx, %eax
0FB600   		movzbl	(%eax), %eax
8845FB   		movb	%al, -5(%ebp)
8B55FC   		movl	-4(%ebp), %edx
8B450C   		movl	12(%ebp), %eax
01D0     		addl	%edx, %eax
0FB600   		movzbl	(%eax), %eax
8845FA   		movb	%al, -6(%ebp)
8345FC01 		addl	$1, -4(%ebp)
807DFB00 		cmpb	$0, -5(%ebp)
7508     		jne	L2
0FB645FA 		movzbl	-6(%ebp), %eax
F7D8     		negl	%eax
EB15     		jmp	L3
0FB645FB 		movzbl	-5(%ebp), %eax
3A45FA   		cmpb	-6(%ebp), %al
74C9     		je	L4
0FB655FB 		movzbl	-5(%ebp), %edx
0FB645FA 		movzbl	-6(%ebp), %eax
29C2     		subl	%eax, %edx
89D0     		movl	%edx, %eax
C9       		leave
C3       		ret
68656C6C 		.ascii "hello\0"
48656C6C 		.ascii "Hello.\0"
000000   		.text
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83E4F0   		andl	$-16, %esp
83EC10   		subl	$16, %esp
E8000000 		call	___main
8D550C   		leal	12(%ebp), %edx
8B4508   		movl	8(%ebp), %eax
98       		cwtl
89542404 		movl	%edx, 4(%esp)
890424   		movl	%eax, (%esp)
E8000000 		call	_Platform_Init
E8000000 		call	_Console__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
C7442404 		movl	$0, 4(%esp)
00000000 
C7042400 		movl	$LC0, (%esp)
E8000000 		call	_Heap_REGMOD
A3000000 		movl	%eax, _m.1608
C7442404 		movl	$7, 4(%esp)
07000000 
C7042406 		movl	$LC1, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Heap_FINALL
B8000000 		movl	$0, %eax
C9       		leave
C3       		ret
