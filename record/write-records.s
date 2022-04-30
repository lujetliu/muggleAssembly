
.include "linux.s"
.include "record-def.s"
# include 声明使指定文件被粘贴到当前位置, 无需在函数中使用此声明, 
# 因为链接器能将导出函数与 .global 指令相结合


.section data

# 想写入的常量数据
# 每个数据项以空字节(0) 填充到适当的长度
# 
# .rept 用于填充每一项, .rept 通知汇编程序将 .rept 和 .endr 之间的段重复指定次数
# 在此程序中, 该指令用于将多余的空白字符增加到每个字段末尾以将之填满
# 通常使用该指令填充 .data 段中的值

record1:
	.ascii "Fredrick\0"
	.rept 31 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "Bartlett\0"
	.rept 31 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209 #Padding to 240 bytes
	.byte 0
	.endr
	.long 45

record2:
	.ascii "Marilyn\0"
	.rept 32 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "Taylor\0"
	.rept 33 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "2224 S Johannan St\nChicago, IL 12345\0"
	.rept 203 #Padding to 240 bytes
	.byte 0
	.endr
	.long 45
record3:
	.ascii "Derrick\0"
	.rept 32 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "McIntire\0"
	.rept 31 #Padding to 40 bytes
	.byte 0
	.endr
	.ascii "500 W Oakland\nSan Diego, CA 54321\0"
	.rept 206 #Padding to 240 bytes
	.byte 0
	.endr
	.long 36


file_name:
.ascii "test.dat\0" # 要写入文件的文件名

.equ FILE_DESCRIPTOR, -4

.global _start
_start:
	movl %esp, %ebp # 复制栈指针到 %ebp
	subl $4, %esp  # 为文件描述符分配空间
	
	# open 系统调用
	# %eax 5, %ebx 以空字符结束的文件名, %ecx 选项列表, %edx 许可模式
	# 作用: 打开给定文件, 返回该文件的描述符或错误号
	movl $SYS_OPEN, %eax
	movl $file_name, %ebx # file_name 在何处定义的?
	movl $0101, %ecx # 如文件不存在则创建,  并打开文件用于写入
	movl $0666, %edx # 权限
	int $LINUX_SYSCALL

	# %eax 存储了文件描述符
	movl %eax, FILE_DESCRIPTOR(%ebp)
	
	# 写第一条记录
	pushl FILE_DESCRIPTOR(%ebp) # 文件描述符入栈
	pushl $record1  # 结构数据入栈
	call write_record
	addl $8, %esp # TODO: 为何是 8
	
	# 写第二条记录
	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record2
	call write_record
	addl $8, %esp

	# 写第三条记录
	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record3 
	call write_record
	addl $8, %esp

	# close 系统调用
	# %eax 6, $ebx  文件描述符
	# 关闭给定的文件描述符
	movl $SYS_CLOSE, %eax
	movl FILE_DESCRIPTOR(%ebp), %ebx
	int $LINUX_SYSCALL

	# 退出程序
	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL


