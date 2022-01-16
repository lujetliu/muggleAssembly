
# 目的: 展示函数如何工作的程序(栈)
# 本程序将计算:
#		2^3 + 5^2
#

# 主程序中的所有内容都存储在寄存器中,
# 因此数据段不保存任何内容
.section .data

.section .text

.global _start
_start:					# 可以理解为程序的入口
	pushl $3			# 第二个参数入栈
	pushl $2			# 第一个参数入栈
	call power			# 调用函数(将下一条指令的地址即返回地址压入栈中, 然后
						# 修改指令指针(%eip)以指向函数起始处, 将程序的控制权
			            # 转移到 power 处
	addl $8, %esp       # 将栈指针向后移动, 将栈恢复到调用函数时的状态
	pushl %eax          # 因为 %eax 会被覆盖, 所以将第一次调用的结果入栈
	
	pushl $2			# 第二个参数入栈
	pushl $5			# 第一个参数入栈
	call power			# 调用函数(将下一条指令的地址即返回地址压入栈中, 然后
						# 修改指令指针(%eip)以指向函数起始处, 将程序的控制权
			            # 转移到 power 处
	addl $8, %esp       # 将栈指针向后移动, 将栈恢复到调用函数时的状态
	popl %ebx           # 第二此调用函数的结果已经在 %eax 中, 此时栈顶保存上次
						# 调用函数的结果, 出栈并保存到 %ebx 中

	addl %eax, %ebx     # 两个结果相加存到 %ebx 中 
	
	movl $1, %eax 
	int $0x80

# 目的: 本函数用于计算一个数的幂
#
#
# 输入: 第一个参数- 底数
#       第二个参数- 底数的指数
#
# 输出: 以返回值的形式给出结果
#
# 注意: 指数必须大于等于1
#
# 变量:
#            %ebx  - 保存底数
#            %ecx  - 保存指数
#            
#           
#            -4%ebp  - 保存当前结果
#
#            %eax 用于暂时存储

.type power, @function		# 通知链接器将 power 作为函数处理
power:						# 将符号 power 定义为下一条指令的起始地址(pushl %ebp)
	pushl %ebp              # 旧基址地址入栈 (访问函数的参数和局部变量) TODO: 深入理解 
	movl %esp, %ebp         # 基址地址设为栈指针
	subl $4, %esp           # 为本地存储保留空间(局部变量)
	movl 8(%ebp), %ebx      # 第一个参数存入 %ebx
	movl 12(%ebp), %ecx     # 第二个参数存入 %ecx, 指数

	movl %ebx, -4(%ebp)     # 将当前结果存入保留空间中

power_loop_start:           # TODO: 为何会接上句执行?
	cmpl $1, %ecx           # 比较
	je end_power            # 如果相等则跳到 end_power 执行
	movl -4(%ebp), %eax     # 将当前结果移入 %eax
	imull %ebx, %eax        # 当前结果与底数相乘
	movl %eax, -4(%ebp)     # 将最新的相乘结果存入保留空间中
	
	decl %ecx               # 指数递减
	jmp power_loop_start    # 为递减后的指数进行幂运算

end_power:
	movl -4(%ebp), %eax     # 返回值移入 %eax
	movl %ebp, %esp         # 恢复栈指针至调用代码处
	popl %ebp               # 恢复地址指针
	ret                     # 将控制权交还给调用它的程序, 该指令将栈顶的值弹出(
							# 函数的返回地址, call power 指令的地址), 并将指令
							# 指针寄存器 %eip 设置为该弹出值 
							
# ubuntu 环境编译 32 位汇编程序 
# as --32 power.s -o power.o
# ld -o power power.o -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L/lib/i386-linux-gnu

