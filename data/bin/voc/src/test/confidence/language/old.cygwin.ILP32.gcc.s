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
83EC34   		subl	$52, %esp
66C745F4 		movw	$0, -12(%ebp)
C745EC01 		movl	$1, -20(%ebp)
E9BE0000 		jmp	L6
C745E801 		movl	$1, -24(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
780F     		js	L7
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB0F     		jmp	L8
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3EA     		shrl	%cl, %edx
89D0     		movl	%edx, %eax
8945E8   		movl	%eax, -24(%ebp)
8B45E8   		movl	-24(%ebp), %eax
3B45EC   		cmpl	-20(%ebp), %eax
740C     		je	L9
C7042410 		movl	$16, (%esp)
E8000000 		call	_Platform_AssertFail
C745E801 		movl	$1, -24(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7827     		js	L10
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89D3     		movl	%edx, %ebx
89C1     		movl	%eax, %ecx
D3E3     		sall	%cl, %ebx
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9200000 		movl	$32, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3EA     		shrl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB21     		jmp	L11
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89D3     		movl	%edx, %ebx
89C1     		movl	%eax, %ecx
D3EB     		shrl	%cl, %ebx
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C020   		addl	$32, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
8945E8   		movl	%eax, -24(%ebp)
8B45E8   		movl	-24(%ebp), %eax
3B45EC   		cmpl	-20(%ebp), %eax
740C     		je	L12
C7042411 		movl	$17, (%esp)
E8000000 		call	_Platform_AssertFail
D165EC   		sall	-20(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83C001   		addl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$31, -12(%ebp)
0F8E37FF 		jle	L13
66C745F4 		movw	$0, -12(%ebp)
66C745F2 		movw	$1, -14(%ebp)
E9E50000 		jmp	L14
66C745E6 		movw	$1, -26(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7813     		js	L15
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB13     		jmp	L16
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
668945E6 		movw	%ax, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
663B45F2 		cmpw	-14(%ebp), %ax
740C     		je	L17
C7042417 		movl	$23, (%esp)
E8000000 		call	_Platform_AssertFail
66C745E6 		movw	$1, -26(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7831     		js	L18
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9100000 		movl	$16, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB2B     		jmp	L19
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C010   		addl	$16, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
668945E6 		movw	%ax, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
663B45F2 		cmpw	-14(%ebp), %ax
740C     		je	L20
C7042418 		movl	$24, (%esp)
E8000000 		call	_Platform_AssertFail
0FBF45F2 		movswl	-14(%ebp), %eax
01C0     		addl	%eax, %eax
668945F2 		movw	%ax, -14(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83C001   		addl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$15, -12(%ebp)
0F8E10FF 		jle	L21
66C745F4 		movw	$0, -12(%ebp)
C645F701 		movb	$1, -9(%ebp)
E9DC0000 		jmp	L22
C645E501 		movb	$1, -27(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7813     		js	L23
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB13     		jmp	L24
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
8845E5   		movb	%al, -27(%ebp)
0FB645E5 		movzbl	-27(%ebp), %eax
3A45F7   		cmpb	-9(%ebp), %al
740C     		je	L25
C704241E 		movl	$30, (%esp)
E8000000 		call	_Platform_AssertFail
C645E501 		movb	$1, -27(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7831     		js	L26
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9080000 		movl	$8, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB2B     		jmp	L27
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C008   		addl	$8, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
8845E5   		movb	%al, -27(%ebp)
0FB645E5 		movzbl	-27(%ebp), %eax
3A45F7   		cmpb	-9(%ebp), %al
740C     		je	L28
C704241F 		movl	$31, (%esp)
E8000000 		call	_Platform_AssertFail
0FBE45F7 		movsbl	-9(%ebp), %eax
01C0     		addl	%eax, %eax
8845F7   		movb	%al, -9(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83C001   		addl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$7, -12(%ebp)
0F8E19FF 		jle	L29
66C745F4 		movw	$-1, -12(%ebp)
C745EC01 		movl	$1, -20(%ebp)
8B45EC   		movl	-20(%ebp), %eax
C1E01E   		sall	$30, %eax
8945EC   		movl	%eax, -20(%ebp)
8B45EC   		movl	-20(%ebp), %eax
01C0     		addl	%eax, %eax
8945E0   		movl	%eax, -32(%ebp)
E9BC0000 		jmp	L30
8B45E0   		movl	-32(%ebp), %eax
8945E8   		movl	%eax, -24(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
780F     		js	L31
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB0F     		jmp	L32
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3EA     		shrl	%cl, %edx
89D0     		movl	%edx, %eax
8945E8   		movl	%eax, -24(%ebp)
8B45E8   		movl	-24(%ebp), %eax
3B45EC   		cmpl	-20(%ebp), %eax
740C     		je	L33
C7042427 		movl	$39, (%esp)
E8000000 		call	_Platform_AssertFail
8B45E0   		movl	-32(%ebp), %eax
8945E8   		movl	%eax, -24(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7827     		js	L34
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89D3     		movl	%edx, %ebx
89C1     		movl	%eax, %ecx
D3E3     		sall	%cl, %ebx
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9200000 		movl	$32, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3EA     		shrl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB21     		jmp	L35
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89D3     		movl	%edx, %ebx
89C1     		movl	%eax, %ecx
D3EB     		shrl	%cl, %ebx
8B55E8   		movl	-24(%ebp), %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C020   		addl	$32, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
8945E8   		movl	%eax, -24(%ebp)
8B45E8   		movl	-24(%ebp), %eax
3B45EC   		cmpl	-20(%ebp), %eax
740C     		je	L36
C7042428 		movl	$40, (%esp)
E8000000 		call	_Platform_AssertFail
D17DEC   		sarl	-20(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83E801   		subl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$-31, -12(%ebp)
0F8D39FF 		jge	L37
66C745F4 		movw	$-1, -12(%ebp)
66C745F2 		movw	$1, -14(%ebp)
0FB745F2 		movzwl	-14(%ebp), %eax
0FB7C0   		movzwl	%ax, %eax
C1E00E   		sall	$14, %eax
668945F2 		movw	%ax, -14(%ebp)
0FBF45F2 		movswl	-14(%ebp), %eax
01C0     		addl	%eax, %eax
668945DE 		movw	%ax, -34(%ebp)
E9E30000 		jmp	L38
0FB745DE 		movzwl	-34(%ebp), %eax
668945E6 		movw	%ax, -26(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7813     		js	L39
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB13     		jmp	L40
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
668945E6 		movw	%ax, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
663B45F2 		cmpw	-14(%ebp), %ax
740C     		je	L41
C704242E 		movl	$46, (%esp)
E8000000 		call	_Platform_AssertFail
0FB745DE 		movzwl	-34(%ebp), %eax
668945E6 		movw	%ax, -26(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7831     		js	L42
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9100000 		movl	$16, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB2B     		jmp	L43
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7D0   		movzwl	%ax, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C010   		addl	$16, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
668945E6 		movw	%ax, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
663B45F2 		cmpw	-14(%ebp), %ax
740C     		je	L44
C704242F 		movl	$47, (%esp)
E8000000 		call	_Platform_AssertFail
66D17DF2 		sarw	-14(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83E801   		subl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$-15, -12(%ebp)
0F8D12FF 		jge	L45
66C745F4 		movw	$-1, -12(%ebp)
C645F701 		movb	$1, -9(%ebp)
0FB645F7 		movzbl	-9(%ebp), %eax
0FB6C0   		movzbl	%al, %eax
C1E006   		sall	$6, %eax
8845F7   		movb	%al, -9(%ebp)
0FBE45F7 		movsbl	-9(%ebp), %eax
01C0     		addl	%eax, %eax
8845DD   		movb	%al, -35(%ebp)
E9DC0000 		jmp	L46
0FB645DD 		movzbl	-35(%ebp), %eax
8845E5   		movb	%al, -27(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7813     		js	L47
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB13     		jmp	L48
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
8845E5   		movb	%al, -27(%ebp)
0FB645E5 		movzbl	-27(%ebp), %eax
3A45F7   		cmpb	-9(%ebp), %al
740C     		je	L49
C7042435 		movl	$53, (%esp)
E8000000 		call	_Platform_AssertFail
0FB645DD 		movzbl	-35(%ebp), %eax
8845E5   		movb	%al, -27(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
7831     		js	L50
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
B9080000 		movl	$8, %ecx
29C1     		subl	%eax, %ecx
89C8     		movl	%ecx, %eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
EB2B     		jmp	L51
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
89C3     		movl	%eax, %ebx
0FB645E5 		movzbl	-27(%ebp), %eax
0FB6D0   		movzbl	%al, %edx
0FBF45F4 		movswl	-12(%ebp), %eax
83C008   		addl	$8, %eax
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
09D8     		orl	%ebx, %eax
8845E5   		movb	%al, -27(%ebp)
0FB645E5 		movzbl	-27(%ebp), %eax
3A45F7   		cmpb	-9(%ebp), %al
740C     		je	L52
C7042436 		movl	$54, (%esp)
E8000000 		call	_Platform_AssertFail
D07DF7   		sarb	-9(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83E801   		subl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$-7, -12(%ebp)
0F8D19FF 		jge	L53
66C745F4 		movw	$0, -12(%ebp)
C745EC01 		movl	$1, -20(%ebp)
8B45EC   		movl	-20(%ebp), %eax
C1E01F   		sall	$31, %eax
8945EC   		movl	%eax, -20(%ebp)
8B45EC   		movl	-20(%ebp), %eax
8945E0   		movl	%eax, -32(%ebp)
EB50     		jmp	L54
8B45E0   		movl	-32(%ebp), %eax
8945E8   		movl	%eax, -24(%ebp)
66837DF4 		cmpw	$0, -12(%ebp)
780F     		js	L55
0FBF45F4 		movswl	-12(%ebp), %eax
8B55E8   		movl	-24(%ebp), %edx
89C1     		movl	%eax, %ecx
D3E2     		sall	%cl, %edx
89D0     		movl	%edx, %eax
EB0F     		jmp	L56
0FBF45F4 		movswl	-12(%ebp), %eax
F7D8     		negl	%eax
8B55E8   		movl	-24(%ebp), %edx
89C1     		movl	%eax, %ecx
D3FA     		sarl	%cl, %edx
89D0     		movl	%edx, %eax
8945E8   		movl	%eax, -24(%ebp)
8B45E8   		movl	-24(%ebp), %eax
3B45EC   		cmpl	-20(%ebp), %eax
740C     		je	L57
C704243E 		movl	$62, (%esp)
E8000000 		call	_Platform_AssertFail
D17DEC   		sarl	-20(%ebp)
0FB745F4 		movzwl	-12(%ebp), %eax
83E801   		subl	$1, %eax
668945F4 		movw	%ax, -12(%ebp)
66837DF4 		cmpw	$-31, -12(%ebp)
7DA9     		jge	L58
66C745F4 		movw	$0, -12(%ebp)
66C745E6 		movw	$1, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
0FB7C0   		movzwl	%ax, %eax
C1E00F   		sall	$15, %eax
668945E6 		movw	%ax, -26(%ebp)
0FB745E6 		movzwl	-26(%ebp), %eax
668945F2 		movw	%ax, -14(%ebp)
