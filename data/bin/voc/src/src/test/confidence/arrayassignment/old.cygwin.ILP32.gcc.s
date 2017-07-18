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
616100   		.ascii "aa\0"
6133303A 		.ascii "a30: \0"
6132303A 		.ascii "a20: \0"
6131303A 		.ascii "a10: \0"
000000   		.align 4
41727261 		.ascii "Array assignment test complete.\0"
79206173 
7369676E 
6D656E74 
20746573 
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83E4F0   		andl	$-16, %esp
83EC40   		subl	$64, %esp
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
A3800000 		movl	%eax, _m.1612
C7050000 		movl	$544502577, _aa_a30
00003173 
C7050400 		movl	$1663053873, _aa_a30+4
00003130 
C7050800 		movl	$1848778856, _aa_a30+8
00006820 
C7050C00 		movl	$808525924, _aa_a30+12
00006420 
C7051000 		movl	$543712032, _aa_a30+16
00002063 
C7051400 		movl	$543453747, _aa_a30+20
00003372 
C7051800 		movl	$1663053873, _aa_a30+24
00003130 
66C7051C 		movw	$104, _aa_a30+28
00000068 
C7442404 		movl	$6, 4(%esp)
06000000 
C7042403 		movl	$LC1, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$30, 4(%esp)
1E000000 
C7042400 		movl	$_aa_a30, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
C7442430 		movl	$_aa_a30, 48(%esp)
00000000 
C744242C 		movl	$_aa_a20, 44(%esp)
2C000000 
C744243C 		movl	$0, 60(%esp)
00000000 
C7442428 		movl	$19, 40(%esp)
13000000 
EB05     		jmp	L6
8344243C 		addl	$1, 60(%esp)
8B44243C 		movl	60(%esp), %eax
3B442428 		cmpl	40(%esp), %eax
7D20     		jge	L7
8B54243C 		movl	60(%esp), %edx
8B44242C 		movl	44(%esp), %eax
01D0     		addl	%edx, %eax
8B4C243C 		movl	60(%esp), %ecx
8B542430 		movl	48(%esp), %edx
01CA     		addl	%ecx, %edx
0FB612   		movzbl	(%edx), %edx
8810     		movb	%dl, (%eax)
0FB600   		movzbl	(%eax), %eax
84C0     		testb	%al, %al
75D1     		jne	L8
8B54243C 		movl	60(%esp), %edx
8B44242C 		movl	44(%esp), %eax
01D0     		addl	%edx, %eax
C60000   		movb	$0, (%eax)
C7442404 		movl	$6, 4(%esp)
06000000 
C7042409 		movl	$LC2, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$20, 4(%esp)
14000000 
C704242C 		movl	$_aa_a20, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
C7442424 		movl	$_aa_a30, 36(%esp)
00000000 
C7442420 		movl	$_aa_a10, 32(%esp)
20000000 
C7442438 		movl	$0, 56(%esp)
00000000 
C744241C 		movl	$9, 28(%esp)
09000000 
EB05     		jmp	L9
83442438 		addl	$1, 56(%esp)
8B442438 		movl	56(%esp), %eax
3B44241C 		cmpl	28(%esp), %eax
7D20     		jge	L10
8B542438 		movl	56(%esp), %edx
8B442420 		movl	32(%esp), %eax
01D0     		addl	%edx, %eax
8B4C2438 		movl	56(%esp), %ecx
8B542424 		movl	36(%esp), %edx
01CA     		addl	%ecx, %edx
0FB612   		movzbl	(%edx), %edx
8810     		movb	%dl, (%eax)
0FB600   		movzbl	(%eax), %eax
84C0     		testb	%al, %al
75D1     		jne	L11
8B542438 		movl	56(%esp), %edx
8B442420 		movl	32(%esp), %eax
01D0     		addl	%edx, %eax
C60000   		movb	$0, (%eax)
C7442404 		movl	$6, 4(%esp)
06000000 
C704240F 		movl	$LC3, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$10, 4(%esp)
0A000000 
C7042420 		movl	$_aa_a10, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
C7442404 		movl	$6, 4(%esp)
06000000 
C7042409 		movl	$LC2, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$20, 4(%esp)
14000000 
C704242C 		movl	$_aa_a20, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
C7442418 		movl	$_aa_a30, 24(%esp)
00000000 
C7442414 		movl	$_aa_a10, 20(%esp)
20000000 
C7442434 		movl	$0, 52(%esp)
00000000 
C7442410 		movl	$9, 16(%esp)
09000000 
EB05     		jmp	L12
83442434 		addl	$1, 52(%esp)
8B442434 		movl	52(%esp), %eax
3B442410 		cmpl	16(%esp), %eax
7D20     		jge	L13
8B542434 		movl	52(%esp), %edx
8B442414 		movl	20(%esp), %eax
01D0     		addl	%edx, %eax
8B4C2434 		movl	52(%esp), %ecx
8B542418 		movl	24(%esp), %edx
01CA     		addl	%ecx, %edx
0FB612   		movzbl	(%edx), %edx
8810     		movb	%dl, (%eax)
0FB600   		movzbl	(%eax), %eax
84C0     		testb	%al, %al
75D1     		jne	L14
8B542434 		movl	52(%esp), %edx
8B442414 		movl	20(%esp), %eax
01D0     		addl	%edx, %eax
C60000   		movb	$0, (%eax)
C7442404 		movl	$6, 4(%esp)
06000000 
C704240F 		movl	$LC3, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$10, 4(%esp)
0A000000 
C7042420 		movl	$_aa_a10, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
C7442404 		movl	$6, 4(%esp)
06000000 
C7042409 		movl	$LC2, (%esp)
E8000000 		call	_Console_String
C7442404 		movl	$20, 4(%esp)
14000000 
C704242C 		movl	$_aa_a20, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Console_Ln
C7442404 		movl	$32, 4(%esp)
20000000 
C7042418 		movl	$LC4, (%esp)
E8000000 		call	_Console_String
E8000000 		call	_Console_Ln
E8000000 		call	_Heap_FINALL
B8000000 		movl	$0, %eax
C9       		leave
C3       		ret
