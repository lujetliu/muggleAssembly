
# 结构化数据各字段偏移量
# - 姓: 40 字节
# - 名: 40 字节
# - 地址: 240 字节
# - 年龄: 4 字节
.equ RECORD_FIRSTNAME, 0
.equ RECORD_LASTNAME, 40
.equ RECORD_ADDRESS, 80
.equ RECORD_AGE, 320

.equ RECORD_SIZE, 324



