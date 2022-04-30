
.include "linux.s"
.include "record-def.s"

# 写函数:
# 目的: 将一条记录写入给定的文件描述符
#
# 输入: 文件描述符和缓冲区
#
# 输出: 本函数产生状态码
#
.equ ST_WRITE_BUFFER, 8 # TODO: ?
.equ ST_FILEDES, 12
.section .text
.globl write_record
.type write_record, @function
write_record:
	pushl %ebp
	movl %esp, %ebp

	pushl %ebx
	movl $SYS_WRITE, %eax
	movl ST_FILEDES(%ebp), %ebx
	movl ST_WRITE_BUFFER(%ebp), %ecx
	movl $RECORD_SIZE, %edx
	int $LINUX_SYSCALL

	popl %ebx 

	movl %ebp, %esp
	popl %ebp
	ret

#NOTE - %eax has the return value, which we will
#
#.equ ST_WRITE_BUFFER, 8 # TODO: ?
#.equ ST_FILEDES, 12 # 文件描述符
#.section .text
#.global write_record
#.type write_record, @function
#write_record:
#	pushl %ebp
#	movl %esp, %ebp 
#	pushl %ebx
#	
#	# write 系统调用
#	# %eax 4, %ebx 文件描述符, %ecx 缓冲区开始地址, %edx 缓冲区大小(整数)
#	movl $SYS_WRITE, %eax
#	movl ST_FILEDES(%ebp), %ebx
#	movl ST_WRITE_BUFFER(%ebp), %ecx
#	movl $RECORD_SIZE, %edx
#	
#	int $LINUX_SYSCALL
#
#	popl %ebx # %eax 中含返回值, 将该值传回调用程序
#
#	movl %ebp, %esp
#	popl %ebp
#	ret
