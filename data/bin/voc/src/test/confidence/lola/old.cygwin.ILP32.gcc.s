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
4C6F6C61 		.ascii "Lola\0"
000000   		.align 4
4C6F6C61 		.ascii "Lola - compile lola source to verilog source.\0"
202D2063 
6F6D7069 
6C65206C 
6F6C6120 
75736167 		.ascii "usage:\0"
000000   		.align 4
20206C6F 		.ascii "  lola lola-source-file verilog-source-file\0"
6C61206C 
6F6C612D 
736F7572 
63652D66 
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
E8000000 		call	_LSB__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
E8000000 		call	_LSC__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
E8000000 		call	_LSV__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
E8000000 		call	_Platform__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
C7442404 		movl	$0, 4(%esp)
00000000 
C7042400 		movl	$LC0, (%esp)
E8000000 		call	_Heap_REGMOD
A3000000 		movl	%eax, _m.1843
0FB70500 		movzwl	_Platform_ArgCount, %eax
6683F802 		cmpw	$2, %ax
7F5C     		jg	L6
C7442404 		movl	$46, 4(%esp)
2E000000 
C7042408 		movl	$LC1, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
C7442404 		movl	$7, 4(%esp)
07000000 
C7042436 		movl	$LC2, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
C7442404 		movl	$44, 4(%esp)
2C000000 
C7042440 		movl	$LC3, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
EB15     		jmp	L7
E8000000 		call	_LSC_Compile
0FB60500 		movzbl	_LSB_modname, %eax
84C0     		testb	%al, %al
7405     		je	L7
E8000000 		call	_LSV_List
E8000000 		call	_Heap_FINALL
B8000000 		movl	$0, %eax
C9       		leave
C3       		ret
