
# 目的: 展示函数如何工作的程序(栈)
# 本程序将计算:
#		2^3 + 5^2
#

# 主程序中的所有内容都存储在寄存器中,
# 因此数据段不保存任何内容
.code32
.section .data

.section .text

.global _start
_start:
	pushl $3  # 第二个参数入栈
	pushl $2  # 第一个参数入栈
	call power # 调用函数
	addl $8, %esp  
	pushl %eax
	
	pushl $2  # 第二个参数入栈
	pushl $5  # 第一个参数入栈
	call power
	addl $8, %esp

	popl %ebx
	addl %eax, %ebx
	
	movl $1, %eax 
	int $0x80

# 目的: 本函数用于计算一个树的幂
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

.type power, @function
power:
	pushl %ebp
	movl %esp, %ebp
	subl $4, %esp
	movl 8(%ebp), %ebx
	movl 12(%ebp), %ecx


	movl %ebx, -4(%ebp)

power_loop_start:
	cmpl $1, %ecx
	je end_power
	movl -4(%ebp), %eax
	imull %ebx, %eax
	movl %eax, -4(%ebp)
	
	decl %ecx
	jmp power_loop_start

end_power:
	movl -4(%ebp), %eax
	movl %ebp, %esp
	popl %ebp
	ret

