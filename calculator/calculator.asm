; 数据段
DATA SEGMENT
divisors DW 10000, 1000, 100, 10, 1  ; DW：Double Word
results DB 0,0,0,0,0,"$"             ; 存放五位数ASCII。DB：Double Byte
DATA ENDS

; 栈
STACK SEGMENT
STACK ENDS

; 代码段
CODE SEGMENT
ASSUME CS:CODE

; MAIN主程序开始
MAIN PROC FAR
MOV AX,DATA   ; 把数据段的地址写到AX寄存器
MOV DS,AX     ; 把AX寄存器的指拷贝到DS寄存器

; NOW标签，供JMP等指令跳转使用
NOW:
MOV AX, 0     ; 把AX寄存器的值设置为0
CALL INPUT    ; 调用INPUT函数，用于用户在终端输入字符

PUSH BX       ; 把BX寄存器中的值压入到栈上
; 如果AL中存储的是'+'则跳转到处理加法的分支
CMP AL,'+'
JZ PLUS
; 如果是'-'则跳转到处理减法的分支
CMP AL,'-'
JZ MINUS
; 如果是'*'则跳转到处理乘法的分支
CMP AL,'*'
JZ BY
; 如果是'/'则跳转到处理除法的分支
CMP AL,'/'
JZ DIVD

; 加法
PLUS:
CALL INPUT    ; 继续调用INPUT获取用户输入
POP AX        ; 上一次输入的数据被压到栈上，所以现在将栈上的数据弹到AX寄存器中
ADD AX,BX     ; 这次获取的用户输入存在BX上，所以计算AX+BX即得到结果
JMP NEXT      ; 跳转到NEXT标签

; 减法
MINUS:
CALL INPUT
POP AX
CMP AX,BX
JL LESS
SUB AX,BX
JMP NEXT
LESS:
SUB AX,BX
NEG AX
PUSH AX
MOV DL,'-'
MOV AH,02H
INT 21H
POP AX
JMP NEXT

; 乘法
BY:
CALL INPUT
POP AX
MUL BX
JMP NEXT

; 除法
DIVD:
CALL INPUT
POP AX
CMP AX,BX
JL LESS2
DIV BX
JMP NEXT
LESS2:
PUSH AX
MOV DL,30H
MOV AH,02H
INT 21H
MOV DL,'~'
MOV AH,02H
INT 21H
POP AX
JMP NEXT

; NEXT标签
NEXT:
CALL OUTPUT       ; 调用OUTPUT，把结果（AX）输出
JMP NOW           ; 继续跳转到NOW标签
MOV AH,4CH
INT 21H
RET
MAIN ENDP
; MAIN主程序结束

; INPUT函数
INPUT PROC NEAR
MOV BX,0
NUM:
MOV AH,1
INT 21H
CMP AL,'C'
JZ CLEAR
CMP AL,'+'
JZ EXIT
CMP AL,'-'
JZ EXIT
CMP AL,'*'
JZ EXIT
CMP AL,'/'
JZ EXIT

SUB AL,30H
JL EXIT
CMP AL,9
JG EXIT
CBW
XCHG AX,BX
MOV CX,10
MUL CX
XCHG AX,BX
ADD BX,AX
JMP NUM

CLEAR:
MOV DL,0DH
MOV AH,2
INT 21H
MOV DL,0AH
MOV AH,2
INT 21H
MOV AX,0
MOV BX,0
JMP NUM
EXIT:RET
INPUT ENDP
; INPUT 函数结束

; 定义OUTPUT函数
OUTPUT PROC NEAR
mov si, offset divisors
mov di, offset results
mov cx,5
CAL:
mov dx,0
div word ptr [si]
add al,30H
mov byte ptr [di],al
inc di
add si,2
mov ax,dx
LOOP CAL
mov cx,4
mov di, offset results
NZ:
cmp byte ptr [di],'0'
jne print
inc di
loop NZ
print:
mov dx,di
MOV AH,9
INT 21H
RET
OUTPUT ENDP
; OUTPUT函数结束 

CODE ENDS
END MAIN
