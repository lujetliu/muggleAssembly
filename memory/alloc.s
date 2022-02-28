

# 目的: 用于管理内存使用的程序--按需分配和释放内存
#
# #AVAILABLE标记#内存大小#实际内存位置#
#
#
# 为了方便调用程序, 返回的指针仅仅指向所请求的实际内存位置,
# 因此无需更改调用程序即可更改结构 

.section .data
## 全局变量 ##


# 此处指向管理的内存之后的一个内存位置
heap_begin:
	.long 0


## 结构信息 ##
# 内存区头空间大小
.equ HEADER_SIXE, 0
# 头中 AVAILABLE标志的位置
.equ HDR_AVAIL_OFFSET, 0
# 内存区头中大小字段的位置
.equ HDR_SIZE_OFFSET, 4


## 常量 ##
.equ UNAVAILABLE, 0 # 标记已分配空间的数字
.equ AVAILABLE, 1 # 标记已回收空间的数字, 此类空间可用于再分配
.equ SYS_BRK,45 # 用于中断系统调用的系统调用号

.equ LINUX_SYSCALL, 0x80 # 系统调用

## 函数 ##
## allocate_init ##
# 目的: 调用此函数来初始化函数(此函数设置 heap_begin 和 current_break),
#         此函数无参数和返回值
.global allocate_init
.type allocate_init, @function
allocate_init:
	pushl %ebp   # 标准函数处理
	movl %esp, %ebp  

	# 如果发起 brk 系统调用时, %ebx 内容为0, 该调用将返回最后一个有效可用地址
	movl $SYS_BRK, %eax # 确定中断点
	movl $0, %ebx
	int $LINUX_SYSCALL


	incl %eax # %eax 现为最后有效可用地址, 需要此地址之后的内存位置

	movl %eax, current_break # 保存当前中断
	
	movl %eax, heap_begin # 将当前中断保存为首地址, 这会使分配函数在其首次运行
						 # 时从 linux 获取更多内存

	movl %ebp, %esp # 退出函数
	popl %ebp 
	ret
## 函数结束 ##


## allocate ##
# 目的: 此函数用于获取一段内存, 它查看内存是否存在自由内存块,
#			如不存在, 则向 linux 请求
#
# 参数: 要求的内存块大小
# 
# 返回值:
#		此函数将所分配内存的地址返回到 %eax 中, 如果已无可用内存,
#		则返回0到%eax中
#
## 处理 ##
# 用到的变量
# 
# %ecx - 保存所请求内存的大小(唯一的参数)
# %eax - 检测到的当前内存区
# %ebx - 当前中断位置
# %edx - 当前内存区大小
# 
# 检测每个以 heap_begin 开始的内存区, 查看每一个的大小以及是否以及分配,
# 如果某个内存区大于等于所请求的大小, 且可用, 该函数就获取此内存区
# 如果无法找到足够大的内存区, 就向 linux 请求更多内存, 这种情况下此函数
# 会向前移动 current_break
.equ ST_MEM_SIZE, 8 # 用于分配内存大小的栈位置(存变量?)

.global allocate
.type allocate, @function
allocate:
	pushl %ebp # 标准函数处理
	movl %esp, %ebp

	movl ST_MEM_SIZE(%ebp), %ecx # %ecx 将保存我们需要的大小(参数)

	movl heap_begin, %eax # %eax 将保持当前搜索位置

	movl current_break, %ebx # %ebx 保存当前中断

alloc_loop_begin:  # 此处开始循环搜索每个内存区
	cmpl %ebx, %eax # 如果两者相等, 就表明需要更多内存
	je move_break
	
	# 获得此内存区的大小
	movl HDR_SIZE_OFFSET(%eax), %edx
	# 如果无可用空间, 则继续搜索下一块内存区
	cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
	je next_location


	cmpl %edx, %ecx # 如果内存区可用, 就将之与所需大小进行比较
	jle allocate_here # 如果足够大, 就跳转至 allocate_here
	
next_location:
	addl $HEADER_SIXE, %eax # 内存区总大小为所需大小(当前%edx中存储的值)
	addl %edx, %eax # + 内存头8字节
                    # (AVAILABLE/UNAVAILABLE标志4字节+内存区大小4字节)
					# 因此将%edx与$8相加, 结果存于%eax中
				    # 即可获得下一个可用内存区
	jmp alloc_loop_begin  # 查看下一个位置

allocate_here: # 如果执行此处代码, 表明要分配的内存区头在%eax中
	#将空间标识为不可用
	movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) 
	addl $HEADER_SIXE, %eax # 将可用内存区头的下一个位置移入%eax中(要返回的内容)
	

	movl %ebp, %esp # 从函数中返回
	popl %ebp
	ret

move_break:								# 如果执行到此， 表明已经耗尽所有可
										# 寻址内存, 需要请求更多内存
										# %ebx 保存当前数据结束处位置
										# %ecx 保存数据大小

	addl $HEADER_SIXE, %ebx # 需要增加%ebx的值, 使其为申请内存结束的地方
						    # 因此需要将其与内存区域头结构的大小相加
	addl %ecx, %ebx			# 将中断与所请求数据的大小相加
	

							# 接着向 linux 请求更多内存

	pushl %eax # 保存所需寄存器
	pushl %ecx
	pushl %ebx

	movl $SYS_BRK, %eax	# 重置中断(%ebx含所请求的中断点)
	int $LINUX_SYSCALL   # 正常情况下, 应返回新中断到%eax中, 
						 # 如失败, 返回值为0, 否则新中断应大于等于请求的内存;
						 # 在本程序中, 并不关心实际中断设置在何处, 
					     # 只要%eax内容不为0, 并不关心其实际值

	cmpl $0, %eax  # 检测到错误情况
	je error
	

	
	pushl %ebx # 恢复保存的寄存器
	pushl %ecx
	pushl %eax

	# 需要分配该内存, 设置该内存为不可用
	movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
	# 设置该内存的大小
	movl %ecx, HDR_SIZE_OFFSET(%eax)

	# 将%eax移至可用内存的实际起始处, %eax现保存着返回值
	addl $HEADER_SIXE, %eax
	
	movl %ebx, current_break # 保存新中断
	
	movl %ebp, %esp 
	popl %ebp
	ret

error:
	movl $0, %eax	# 如果出错, 返回0
	movl %ebp, %esp
	popl %ebp
	ret

## deallocate ##
# 目的: 此函数的目的是使用内存区域后将之返回到内存池中
# 
# 参数:	唯一的参数是需要返回到内存池的内存地址
#
#
# 返回值: 无
#

.global deallocate
.type deallocate, @function
deallocate:
	movl ST_MEM_SIZE(%esp), %eax
	
	# 获得指向内存实际起始处的指针
	subl $HEADER_SIXE, %eax

	# 标识该内存区为可用
	movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

	# 返回
	ret
