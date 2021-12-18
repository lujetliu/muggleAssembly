
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

data_items:
	.long 3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0 


.section .text # 存放指令的文本段

.globl _start
_start:
movl $0, %edi
movl data_items(, %edi, 4), %eax # 加载数据的第一个字节
movl %eax, %ebx

start_loop:
cmpl $0, %eax #开始循环
je loop_exit 

incl %edi
movl data_items(, %edi, 4), %eax 
cmpl  %ebx, %eax
jle start_loop

movl %eax, %ebx

jmp start_loop

loop_exit:
movl $1, %eax
int $0x80


