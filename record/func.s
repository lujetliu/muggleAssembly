

.include "record-def.s"
.include "linux.s"

# 读函数:
# 目的: 此函数从文件描述符读取一条记录
#
# 输入: 文件描述符和缓冲区
#
# 输出: 本函数将数据写入缓冲区并返回状态码
#

# 栈局部变量
.equ ST_READ_BUFFER, 8
.equ ST_FILEDES, 12 # 文件描述符

.section .text
.global read_record
.type read_record, @function

read_record:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %ebx # TODO: ebx 中存的什么? 为何要入栈
	movl ST_FILEDES(%ebp), %ebx
	movl ST_READ_BUFFER(%ebp), %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	
	int $LINUX_SYSCALL

	popl %ebx # %eax 中含返回值, 将该值传回调用程序

	movl %ebp, %esp
	popl %ebp
	ret
	

# 写函数:
# 目的: 将一条记录写入给定的文件描述符
#
# 输入: 文件描述符和缓冲区
#
# 输出: 本函数产生状态码
#
.global write_record
.type write_record, @function'

write_record:
	pushl %ebp
	pushl %esp, %ebp
	
	pushl %ebx
	
	movl ST_FILEDES(%ebp), %ebx
	movl ST_READ_BUFFER(%ebp), %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_WRITE, %eax
	
	int $LINUX_SYSCALL

	popl %ebx # %eax 中含返回值, 将该值传回调用程序

	movl %ebp, %esp
	popl %ebp
	ret
