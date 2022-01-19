
# 目的: 给定一个数字, 本程序将计算阶乘


# 本程序展示了如何递归调用一个函数
# 本程序无全局数据

.section .data # 丢失 data 前的 . , 编译和链接成功, 但执行时会报错
			   # cannot execute binary file: Exec format error

.section .text

.global _start
.global factorial # 除非希望和其他程序共享此函数, 否则无需此项


_start:
	pushl $4  # 参数入栈(计算4的阶乘)
	call factorial # 运行阶乘函数
	addl $4, %esp  # 弹出入栈的参数 (TODO:为何不用 popl ?)
	movl %eax, %ebx # 阶乘函数将答案移入 %eax 中, 这里移入 %ebx 作为退出状态


	movl $1, %eax # 调用内核退出函数 
	int $0x80


.type factorial, @function
factorial:
	pushl %ebp # 旧基址地址入栈, 必须在函数返回前恢复 %ebp 到其之前的状态
	movl %esp, %ebp # 使用 ebp, 避免更改栈指针
	
	movl 8(%ebp), %eax # 参数移入 %eax 中
	cmpl $1, %eax
	je end_factorial
	decl %eax
	pushl %eax
	call factorial
	movl 8(%ebp), %ebx

	imull %ebx, %eax


end_factorial:
	movl %ebp, %esp	
	popl %ebp
	ret
ld -o factorial factorial.o -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L/lib/i386-linux-gnu
