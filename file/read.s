
# 目的:  本程将输入文件的所有字母转换为大写字母, 然后输出到输出文件
#
# 处理过程: 
#    - 打开输入文件
#    - 打开输出文件
#    - 如果未达到输入文件尾部:
#       - 将部分文件读入内存缓冲区
#       - 读取内存缓冲区的每个字节, 如果该字母为小写字母, 就将其转换为大写字母
#       - 将内存缓冲区写入输出文件
#

.section .data


####### 常数 #######

# 系统调用号
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# 文件打开选项(不同的值参考: /usr/include/asm-generic/fcntl.h)
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# 标准文件描述符
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# 系统调用中断
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0 # 读操作的返回值, 表明到达文件结束处
.equ NUMBER_ARGUENTS, 2 # TODO:?

.section .bss
# 缓冲区,  从文件中将数据加载到这里, 也从这里将输入写入输出文件, 
# 缓冲区大小不应超过 16000 字节(种种原因)
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE


.section .text


# 栈位置



