
# 目的: 退出并向 linux 内核返回一个状态码的简单程序

# 输入: 无
#

# 输出: 返回一个状态码, 在运行程序后可通过输入 echo $? 来读取状态码
#

# 变量: 
# %eax 保存系统调用号
# %ebx 保存返回状态
#

.section .data
.section .text
.global _start
_start:

movl $1, %eax # 用于退出程序的 linux 内核命令(系统调用)
movl $1, %ebx # 将返回给操作系统的状态码, 改变这个数字, 则返回到 echo $? 的值不同

int $0x80 # 将唤醒内核, 以运行退出命令


					
			
