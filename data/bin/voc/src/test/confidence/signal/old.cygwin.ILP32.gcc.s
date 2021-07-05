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
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
53       		pushl	%ebx
83EC24   		subl	$36, %esp
8B5D0C   		movl	12(%ebp), %ebx
8B450C   		movl	12(%ebp), %eax
890424   		movl	%eax, (%esp)
E8000000 		call	_Platform_OSAllocate
89C2     		movl	%eax, %edx
895C2408 		movl	%ebx, 8(%esp)
8B4508   		movl	8(%ebp), %eax
89442404 		movl	%eax, 4(%esp)
891424   		movl	%edx, (%esp)
E8000000 		call	_memcpy
894508   		movl	%eax, 8(%ebp)
66C745F6 		movw	$0, -10(%ebp)
EB51     		jmp	L6
0FBF55F6 		movswl	-10(%ebp), %edx
8B450C   		movl	12(%ebp), %eax
39C2     		cmpl	%eax, %edx
7306     		jnb	L7
0FBF45F6 		movswl	-10(%ebp), %eax
EB11     		jmp	L8
C70424FE 		movl	$-2, (%esp)
E8000000 		call	_Platform_Halt
B8000000 		movl	$0, %eax
8B5508   		movl	8(%ebp), %edx
01D0     		addl	%edx, %eax
0FB600   		movzbl	(%eax), %eax
0FB6D0   		movzbl	%al, %edx
A1000000 		movl	_Files_Rider__typ, %eax
89542408 		movl	%edx, 8(%esp)
89442404 		movl	%eax, 4(%esp)
C7042404 		movl	$_SignalTest_rider, (%esp)
E8000000 		call	_Files_Write
0FB745F6 		movzwl	-10(%ebp), %eax
83C001   		addl	$1, %eax
668945F6 		movw	%ax, -10(%ebp)
0FBF45F6 		movswl	-10(%ebp), %eax
3B450C   		cmpl	12(%ebp), %eax
7D32     		jge	L9
0FBF55F6 		movswl	-10(%ebp), %edx
8B450C   		movl	12(%ebp), %eax
39C2     		cmpl	%eax, %edx
7306     		jnb	L10
0FBF45F6 		movswl	-10(%ebp), %eax
EB11     		jmp	L11
C70424FE 		movl	$-2, (%esp)
E8000000 		call	_Platform_Halt
B8000000 		movl	$0, %eax
8B5508   		movl	8(%ebp), %edx
01D0     		addl	%edx, %eax
0FB600   		movzbl	(%eax), %eax
84C0     		testb	%al, %al
0F8574FF 		jne	L12
8B4508   		movl	8(%ebp), %eax
890424   		movl	%eax, (%esp)
E8000000 		call	_Platform_OSFree
90       		nop
83C424   		addl	$36, %esp
5B       		popl	%ebx
5D       		popl	%ebp
C3       		ret
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83EC18   		subl	$24, %esp
A1000000 		movl	_Files_Rider__typ, %eax
C7442408 		movl	$10, 8(%esp)
0A000000 
89442404 		movl	%eax, 4(%esp)
C7042404 		movl	$_SignalTest_rider, (%esp)
E8000000 		call	_Files_Write
90       		nop
C9       		leave
C3       		ret
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
53       		pushl	%ebx
83EC34   		subl	$52, %esp
66C745F6 		movw	$0, -10(%ebp)
837D0800 		cmpl	$0, 8(%ebp)
790F     		jns	L15
C645D82D 		movb	$45, -40(%ebp)
0FB745F6 		movzwl	-10(%ebp), %eax
83C001   		addl	$1, %eax
668945F6 		movw	%ax, -10(%ebp)
0FB745F6 		movzwl	-10(%ebp), %eax
6683F81D 		cmpw	$29, %ax
7706     		ja	L16
0FBF5DF6 		movswl	-10(%ebp), %ebx
EB11     		jmp	L17
C70424FE 		movl	$-2, (%esp)
E8000000 		call	_Platform_Halt
BB000000 		movl	$0, %ebx
837D0800 		cmpl	$0, 8(%ebp)
782A     		js	L18
8B4D08   		movl	8(%ebp), %ecx
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
EB16     		jmp	L19
8B4508   		movl	8(%ebp), %eax
C7442404 		movl	$10, 4(%esp)
0A000000 
890424   		movl	%eax, (%esp)
E8000000 		call	_SYSTEM_MOD
83C030   		addl	$48, %eax
88441DD8 		movb	%al, -40(%ebp,%ebx)
0FB745F6 		movzwl	-10(%ebp), %eax
83C001   		addl	$1, %eax
668945F6 		movw	%ax, -10(%ebp)
837D0800 		cmpl	$0, 8(%ebp)
781A     		js	L20
8B4D08   		movl	8(%ebp), %ecx
BA676666 		movl	$1717986919, %edx
89C8     		movl	%ecx, %eax
F7EA     		imull	%edx
C1FA02   		sarl	$2, %edx
89C8     		movl	%ecx, %eax
C1F81F   		sarl	$31, %eax
29C2     		subl	%eax, %edx
89D0     		movl	%edx, %eax
EB21     		jmp	L21
B8090000 		movl	$9, %eax
2B4508   		subl	8(%ebp), %eax
89C1     		movl	%eax, %ecx
BA676666 		movl	$1717986919, %edx
89C8     		movl	%ecx, %eax
F7EA     		imull	%edx
C1FA02   		sarl	$2, %edx
89C8     		movl	%ecx, %eax
C1F81F   		sarl	$31, %eax
29C2     		subl	%eax, %edx
89D0     		movl	%edx, %eax
F7D8     		negl	%eax
894508   		movl	%eax, 8(%ebp)
E9BA0000 		jmp	L22
0FB745F6 		movzwl	-10(%ebp), %eax
6683F81D 		cmpw	$29, %ax
7706     		ja	L23
0FBF5DF6 		movswl	-10(%ebp), %ebx
EB11     		jmp	L24
C70424FE 		movl	$-2, (%esp)
E8000000 		call	_Platform_Halt
BB000000 		movl	$0, %ebx
837D0800 		cmpl	$0, 8(%ebp)
782A     		js	L25
8B4D08   		movl	8(%ebp), %ecx
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
EB16     		jmp	L26
8B4508   		movl	8(%ebp), %eax
C7442404 		movl	$10, 4(%esp)
0A000000 
890424   		movl	%eax, (%esp)
E8000000 		call	_SYSTEM_MOD
83C030   		addl	$48, %eax
88441DD8 		movb	%al, -40(%ebp,%ebx)
0FB745F6 		movzwl	-10(%ebp), %eax
83C001   		addl	$1, %eax
668945F6 		movw	%ax, -10(%ebp)
837D0800 		cmpl	$0, 8(%ebp)
781A     		js	L27
8B4D08   		movl	8(%ebp), %ecx
BA676666 		movl	$1717986919, %edx
89C8     		movl	%ecx, %eax
F7EA     		imull	%edx
C1FA02   		sarl	$2, %edx
89C8     		movl	%ecx, %eax
C1F81F   		sarl	$31, %eax
29C2     		subl	%eax, %edx
89D0     		movl	%edx, %eax
EB21     		jmp	L28
B8090000 		movl	$9, %eax
2B4508   		subl	8(%ebp), %eax
89C1     		movl	%eax, %ecx
BA676666 		movl	$1717986919, %edx
89C8     		movl	%ecx, %eax
F7EA     		imull	%edx
C1FA02   		sarl	$2, %edx
89C8     		movl	%ecx, %eax
C1F81F   		sarl	$31, %eax
29C2     		subl	%eax, %edx
89D0     		movl	%edx, %eax
F7D8     		negl	%eax
894508   		movl	%eax, 8(%ebp)
837D0800 		cmpl	$0, 8(%ebp)
0F8F3CFF 		jg	L29
EB4D     		jmp	L30
0FB745F6 		movzwl	-10(%ebp), %eax
83E801   		subl	$1, %eax
668945F6 		movw	%ax, -10(%ebp)
0FB745F6 		movzwl	-10(%ebp), %eax
6683F81D 		cmpw	$29, %ax
7706     		ja	L31
0FBF45F6 		movswl	-10(%ebp), %eax
EB11     		jmp	L32
C70424FE 		movl	$-2, (%esp)
E8000000 		call	_Platform_Halt
B8000000 		movl	$0, %eax
0FB64405 		movzbl	-40(%ebp,%eax), %eax
0FB6D0   		movzbl	%al, %edx
A1000000 		movl	_Files_Rider__typ, %eax
89542408 		movl	%edx, 8(%esp)
89442404 		movl	%eax, 4(%esp)
C7042404 		movl	$_SignalTest_rider, (%esp)
E8000000 		call	_Files_Write
66837DF6 		cmpw	$0, -10(%ebp)
7FAC     		jg	L33
90       		nop
83C434   		addl	$52, %esp
5B       		popl	%ebx
5D       		popl	%ebp
C3       		ret
5369676E 		.ascii "Signal: \0"
616C3A20 
5369676E 		.ascii "Signal \0"
616C2000 
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83EC28   		subl	$40, %esp
8B4508   		movl	8(%ebp), %eax
668945F4 		movw	%ax, -12(%ebp)
E8000000 		call	_Console_Ln
C7442404 		movl	$9, 4(%esp)
09000000 
C7042400 		movl	$LC0, (%esp)
E8000000 		call	_Console_String
0FBF45F4 		movswl	-12(%ebp), %eax
C7442404 		movl	$1, 4(%esp)
01000000 
890424   		movl	%eax, (%esp)
E8000000 		call	_Console_Int
E8000000 		call	_Console_Ln
C7442404 		movl	$8, 4(%esp)
08000000 
C7042409 		movl	$LC1, (%esp)
E8B2FCFF 		call	_SignalTest_ws
0FBF45F4 		movswl	-12(%ebp), %eax
890424   		movl	%eax, (%esp)
E89FFDFF 		call	_SignalTest_wi
E874FDFF 		call	_SignalTest_wl
90       		nop
C9       		leave
C3       		ret
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83EC28   		subl	$40, %esp
8B4508   		movl	8(%ebp), %eax
668945F4 		movw	%ax, -12(%ebp)
EB30     		jmp	L36
0FBF45F4 		movswl	-12(%ebp), %eax
C7442404 		movl	$2, 4(%esp)
02000000 
890424   		movl	%eax, (%esp)
E8000000 		call	_Console_Int
E8000000 		call	_Console_Flush
C70424E8 		movl	$1000, (%esp)
E8000000 		call	_Platform_Delay
0FB745F4 		movzwl	-12(%ebp), %eax
83E801   		subl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7FC9     		jg	L37
E8000000 		call	_Console_Ln
90       		nop
C9       		leave
C3       		ret
55       		pushl	%ebp
89E5     		movl	%esp, %ebp
83EC28   		subl	$40, %esp
A1000000 		movl	_SignalTest_result, %eax
890424   		movl	%eax, (%esp)
8B4508   		movl	8(%ebp), %eax
FFD0     		call	*%eax
A1000000 		movl	_Files_Rider__typ, %eax
8B5508   		movl	8(%ebp), %edx
89542410 		movl	%edx, 16(%esp)
C744240C 		movl	$1, 12(%esp)
01000000 
C7442408 		movl	$20, 8(%esp)
14000000 
89442404 		movl	%eax, 4(%esp)
C7042404 		movl	$_SignalTest_rider, (%esp)
E8000000 		call	_SYSTEM_ENUMR
90       		nop
C9       		leave
C3       		ret
5369676E 		.ascii "SignalTest\0"
616C5465 
72657375 		.ascii "result\0"
00       		.text
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
E8000000 		call	_Files__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
E8000000 		call	_Platform__init
890424   		movl	%eax, (%esp)
E8000000 		call	_Heap_INCREF
C7442404 		movl	$_EnumPtrs, 4(%esp)
02040000 
C7042411 		movl	$LC2, (%esp)
E8000000 		call	_Heap_REGMOD
A3180000 		movl	%eax, _m.1984
C7442404 		movl	$7, 4(%esp)
07000000 
C704241C 		movl	$LC3, (%esp)
E8000000 		call	_Files_New
A3000000 		movl	%eax, _SignalTest_result
8B150000 		movl	_SignalTest_result, %edx
A1000000 		movl	_Files_Rider__typ, %eax
C744240C 		movl	$0, 12(%esp)
00000000 
89542408 		movl	%edx, 8(%esp)
89442404 		movl	%eax, 4(%esp)
C7042404 		movl	$_SignalTest_rider, (%esp)
E8000000 		call	_Files_Set
0FB70500 		movzwl	_Platform_ArgCount, %eax
6683F801 		cmpw	$1, %ax
7E18     		jle	L40
C704244D 		movl	$_SignalTest_handle, (%esp)
E8000000 		call	_Platform_SetInterruptHandler
C704244D 		movl	$_SignalTest_handle, (%esp)
E8000000 		call	_Platform_SetQuitHandler
C7042404 		movl	$4, (%esp)
E89EFEFF 		call	_SignalTest_Take5
A1000000 		movl	_SignalTest_result, %eax
890424   		movl	%eax, (%esp)
E8000000 		call	_Files_Register
E8000000 		call	_Heap_FINALL
B8000000 		movl	$0, %eax
C9       		leave
C3       		ret
