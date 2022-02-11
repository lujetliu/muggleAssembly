
.include "linux.s"
.include "record-def.s"


.section data

# 想写入的常量数据
# 每个数据项以空字节(0) 填充到适当的长度
# 
# .rept 用于填充每一项, .rept 通知汇编程序将 .rept 和 .endr 之间的段重复指定次数
# 在此程序中, 该指令用于将多余的空白字符增加到每个字段末尾以将之填满

record1:
	.ascii "Fredricl\0"
	.rept 31 # 填充到40字节
	.byte 0
	.endr

	.ascii "Bartlett\0"
	.rept 31 # 填充到40字节
	.byte 0
	.endr

	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209 # 填充到240字节
	.byte 0
	.endr
	
	.long 45

record2:
	.ascii "Marilyn\0"
	.rept 32 # 填充到40字节
	.byte 0
	.endr

	.ascii "Taylor\0"
	.rept 33 # 填充到40字节
	.byte 0
	.endr

	.ascii "2224 S Johannan St\nChicago, IL 12345\0"
	.rept 203 # 填充到240字节
	.byte 0
	.endr
	
	.long 29

record3:
	.ascii "Derrick\0"
	.rept 32 # 填充到40字节
	.byte 0
	.endr

	.ascii "McIntire\0"
	.rept 31 # 填充到40字节
	.byte 0
	.endr

	.ascii "500 W Oakland\nSan Diego, CA 54321\0"
	.rept 206 # 填充到240字节
	.byte 0
	.endr
	
	.long 36


.ascii "test.dat\0" # 要写入文件的文件名

.equ ST_FILE_DESCRIPTOR, 4

.global _start
_start:
	movl %esp, %ebp
	subl $4, %esp  # 为文件描述符分配空间
	
	# 打开文件
	movl $SYS_OPEN, %eax
	movl $file_name, %ebx
	movl $0101, %ecx
	movl $0666, %edx
	

	movl %eax, FILE_DESCRIPTOR(%ebp)
	
	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record1
	call write_record
	addl $8, %esp
	

	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record2
	call write_record
	addl $8, %esp

	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record3
	call write_record
	addl $8, %esp

	movl $SYS_CLOSE, %eax
	movl FILE_DESCRIPTOR(%ebp), %ebx
	int $LINUX_SYSCALL

	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL




