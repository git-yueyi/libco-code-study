/*
* Tencent is pleased to support the open source community by making Libco available.

* Copyright (C) 2014 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*	http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
/*
   https://en.wikibooks.org/wiki/X86_Assembly/GAS_Syntax
   esp ESPΪջָ�룬����ָ��ջ��ջ������һ��ѹ��ջ�Ļ��¼�Ķ����� ��һ�������ڳ��ֺ������õ�ʱ�򣬻�����������Ļ������и���esp��ֵ����Ϊ���ں���������ζ�����µĻ��¼��ѹջ

   eax EAX ��"�ۼ���"(accumulator), ���Ǻܶ�ӷ��˷�ָ���ȱʡ�Ĵ�����
   ebx EBX ��"����ַ"(base)�Ĵ���, ���ڴ�Ѱַʱ��Ż���ַ��
   ecx ECX �Ǽ�����(counter), ���ظ�(REP)ǰ׺ָ���LOOPָ����ڶ���������
   edx EDX �����Ǳ���������������������������
   esi/edi ESI/EDI�ֱ����"Դ/Ŀ�������Ĵ���"(source/destination index),��Ϊ�ںܶ��ַ�������ָ����, DS:ESIָ��Դ��,��ES:EDIָ��Ŀ�괮.
   ebp EBP��"��ַָ��"(BASE POINTER), ������������߼����Ժ������õ�"���ָ��"(frame pointer). ���ƽ��ʱ��,�������Կ���һ����׼�ĺ�����ʼ����:


   coctx_swap�������Ǳ��浱ǰroutine��ִ�л������ṹ��coctx_t ��Ȼ��CPU����������ΪĿ��routine��������

*/

.globl coctx_swap
#if !defined( __APPLE__ )
.type  coctx_swap, @function
#endif
coctx_swap:

#if defined(__i386__)
	leal 4(%esp), %eax //sp   R[eax]=R[esp]+4 R[eax]��ֵӦ��Ϊcoctx_swap�ĵ�һ��������ջ�еĵ�ַ
	movl 4(%esp), %esp  //    R[esp]=Mem[R[esp]+4] ��espָ�� &(curr->ctx) ��ǰroutine �����ĵ��ڴ��ַ
	leal 32(%esp), %esp //parm a : &regs[7] + sizeof(void*)   R[esp]=R[esp]+32 �л�ջ��ָ�뵽��ǰroutine�������ı�����ջ�еĵ�ַ
    //����Ĵ���ֵ��ջ�У�ʵ�ʶ�Ӧcoctx_t->regs ������ջ�е�λ�ã��μ�coctx.h ��coctx_t�Ķ��壩
	pushl %eax //esp ->parm a

	pushl %ebp
	pushl %esi
	pushl %edi
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl -4(%eax) //���������ص�ַѹջ����coctx_swap ֮���ָ���ַ�����淵�ص�ַ,���浽coctx_t->regs[0]

    //�ָ�����Ŀ��routineʱ�Ļ����������Ĵ�����ֵ��ջ״̬��
	movl 4(%eax), %esp //parm b -> &regs[0] //�л�esp��Ŀ�� routine  ctx��ջ�е���ʼ��ַ,�����ַ���ö�Ӧregs[0]

	popl %eax  //ret func addr regs[0] �ݴ淵�ص�ַ�� EAX
	//�ָ���ʱ�ļĴ���״̬
	popl %ebx  // regs[1]
	popl %ecx  // regs[2]
	popl %edx  // regs[3]
	popl %edi  // regs[4]
	popl %esi  // regs[5]
	popl %ebp  // regs[6]
	popl %esp  // regs[7]
	//�����ص�ַѹջ
	pushl %eax //set ret func addr
    //�� eax����
	xorl %eax, %eax
	//���أ����ﷵ��֮����л���Ŀ��routine�ˣ�C++�����е���coctx_swap�ĵط�֮��Ĵ��뽫�ò�������ִ��
	ret

#elif defined(__x86_64__)
	leaq 8(%rsp),%rax
	leaq 112(%rdi),%rsp
	pushq %rax
	pushq %rbx
	pushq %rcx
	pushq %rdx

	pushq -8(%rax) //ret func addr

	pushq %rsi
	pushq %rdi
	pushq %rbp
	pushq %r8
	pushq %r9
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	movq %rsi, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %r9
	popq %r8
	popq %rbp
	popq %rdi
	popq %rsi
	popq %rax //ret func addr
	popq %rdx
	popq %rcx
	popq %rbx
	popq %rsp
	pushq %rax

	xorl %eax, %eax
	ret
#endif