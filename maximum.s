
# 目的: 本程序寻找一组数据项中的最大值


# 变量: 
# %edi 保存正在检测的数据项索引
# %ebx 当前已经找到的最大值
# %eax 当前数据项
#

# 使用以下内存位置:
#
# data_items 包含数据项
#          0 表示数据结束


.section .data # 数据段

data_items: # 指第一个数字的位置, data_items  是标签, 在程序中需要引用这个地址
			# 时, 就可以使用 data_items 符号; 汇编程序会在汇编时以数字起始处
		    # 的地址取代 data_items

	# 注意: .long 属于指令
	.long 3, 67, 34, 222, 45, 75, 120, 34, 44, 33, 22, 11, 66, 0 
	# 汇编程序保留14个 .long 型位置, 以此连续排放; 使用 data_items 引用列表
    # 首个元素的地址
	
	# 常见的类型指令
	# .byte 8bits, 0-255
	# .int, 16bits, 0-65535
    # .long, 长整型, 32bits, 与寄存器使用的空间相同, 0-4294967295
    # .ascii, 8bits, 该指令用于将字符输入内存, 每个字符占用一个存储位置(字符在内部转换成字节), 如 .ascii "hello, wordl\0"



.section .text # 存放指令的文本段(代码段)

.globl _start

	_start:
	movl $0, %edi
	movl data_items(, %edi, 4), %eax # 加载数据的第一个字节, 4 可以看做比例因子
	# movl 起始地址(, %索引寄存器, 字长)
	movl %eax, %ebx # movl 中的"l"代表移动长整型

	start_loop: # 标记循环的起始位置
	cmpl $0, %eax # 将数字 0 和存储在 %eax 中的数字进行比较, 比较结果存储在状态寄存器 %eflags 中(TODO)
	je loop_exit  # je (e 为 equal) 为流控制指令, 使用状态寄存器保存的结果, 如果相等, 则跳转到 loop_exit 位置

	incl %edi # incl 将 %edi 的值递增1
	movl data_items(, %edi, 4), %eax 
	cmpl  %ebx, %eax 
	jle start_loop # 取出的值小于或等于当前的最大值, 无需处理, 开始下一次循环
	movl %eax, %ebx  # 否则,把当前值移动到存储最大值的 %ebx 中, 继续循环
	jmp start_loop

	loop_exit: # 调用 linux 内核并退出
	# 退出调用需要将退出状态存储在 %ebx 中, 由于将最大值置于 %ebx 中(该寄存器
    # 中已经有退出状态了, 因此只要将数字1加载到 %eax 调用内核退出即可.
	movl $1, %eax 
	int $0x80 // 唤醒内核

	# 即 loop_exit 位置的流程是: 使用 int 唤醒内核, 然后数字1存储到 %eax 中
    # 调用系统的退出程序linux内核命令, 退出时返回 %ebx 中存储的状态码(整数)


#
# 流控制指令常见的跳转语句:(大于: Greater, 小于: Less, 等于: Equal)
# je  - 若值相等则跳转
# jg  - 若第二个值大于第一个值则跳转
# jge - 若第二个值大于等于第一个值则跳转
# jl  - 若第二个值小于第一个值则跳转
# jle - 若第二个值小于等于第一个值则跳转
# jmp - 无条件跳转, 该指令无需跟在比较指令之后


#> as maximum.s -o maximum.o (汇编)
#> ld maximum.o -o maximum (链接)


