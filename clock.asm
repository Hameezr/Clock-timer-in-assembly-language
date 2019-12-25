; display a tick count on the top right of screen
[org 0x0100]
jmp start

 
hour      :  dw  0
minute    :  dw  0
second    :  dw  0
tick      :  dw  0
message1  :  db 'Hours',0 ; string to be printed
message2  :  db 'minutes',0 ; string to be printed
message3  :  db 'seconds',0; string to be printed
hourflag  :  dw  0
mintflag  :  dw  0
secflag   :  dw  0
check     :  dw  0
terminate :  dw  0
firstval  :  db  0
 


clrscr: 
 push es
 push ax
 push di 
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov di, 0 ; point di to top left column
 nextloc: mov word [es:di], 0x0720 ; clear next char on screen
 add di, 2 ; move to next screen location
 cmp di, 4000 ; has the whole screen cleared
 jne nextloc ; if no clear next position
 pop di
 pop ax
 pop es
 ret 
 
printstr: 
 
 push bp
 mov bp, sp
 push es
 push ax
 push cx
 push si
 push di
 push ds
 pop es ; load ds in es
 mov di, [bp+4] ; point di to string
 mov cx, 0xffff ; load maximum number in cx
 xor al, al ; load a zero in al
 repne scasb ; find zero in the string
 mov ax, 0xffff ; load maximum number in ax
 sub ax, cx ; find change in cx
 dec ax ; exclude null from length
 jz exit ; no printing if string is empty
 mov cx, ax ; load string length in cx
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov al, 80 ; load al with columns per row
 mul byte [bp+8] ; multiply with y position
 add ax, [bp+10] ; add x position
 shl ax, 1 ; turn into byte offset
 mov di,ax ; point di to required location
 mov si, [bp+4] ; point si to string
 mov ah, [bp+6] ; load attribute in ah
 cld ; auto increment mode
nextchar: lodsb ; load next char in al
 stosw ; print char/attribute pair
 loop nextchar ; repeat for the whole string
exit: pop di
 pop si
 pop cx
 pop ax
 pop es
 pop bp
 ret 8


printnum: 
 push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov ax, [bp+6] ; load number in ax
 mov di,[bp+4]
 mov dl,32
 mov dh,7
 mov [es:di],dx
 add di,2 
 mov [es:di],dx 
  
 mov bx, 10 ; use base 10 for division
 mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
 div bx ; divide by 10
 add dl, 0x30 ; convert digit into ascii value
 push dx ; save ascii value on stack
 inc cx ; increment count of values
 cmp ax, 0 ; is the quotient zero
 jnz nextdigit ; if no divide it again
 mov di, 140 ; point di to 70th column
 mov di,[bp+4]
 nextpos: 
 pop dx ; remove a digit from the stack
 mov dh, 0x07 ; use normal attribute
 mov [es:di], dx ; print char on screen
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 pop di
 pop dx
 pop cx
 pop bx
 pop ax 
 pop es
 pop bp
 ret 4

timer: 
push ax
cmp word [cs:tick],18 ;if 18 tick add one second
jb next
 

mov word [cs:tick],0

cmp word [cs:second],60
jb skip
mov word [cs:second],0
inc word [cs:minute]

cmp word [cs:minute],60
jb skip
mov word [cs:minute],0
inc word[cs:hour]
 
cmp word[cs:hour],24
jb skip
mov word[cs:hour],0
 
skip:
inc  word [cs:second]; increment tick count
next:
add word[cs:tick],1
 
 
 
mov ax,[cs:hour]
push ax
mov ax,182
push ax 
call printnum
mov ax,[cs:minute]
push ax
mov ax,202
push ax 
call printnum
mov ax,[cs:second]
 
push ax
mov ax,220
push ax 
call printnum


pop ax 
mov al, 0x20
out 0x20, al ; end of interrupt

iret 

kbisr: 
push bx 
in al, 0x60  ; read a char from keyboard port
    
cmp al ,1

je toend
jmp skipp
	
toend:
mov word [cs:terminate],1
jmp end

skipp:
cmp al ,11 ;0
je val0
jmp skip0
val0:
cmp word [cs:check],0
je next0
jmp secval0
next0:
xor ax,ax
mov al,0
mov bl,10
mul bl
mov byte [cs:firstval],al
inc word [cs:check]
jmp skipcount3
secval0:
add byte [cs:firstval],0
inc word [cs:check]

skip0:
cmp al ,2 ;1 
je val1
jmp skip1
val1:
   	cmp word [cs:check],0
	je next1
	jmp secval1
	next1:
    xor ax,ax
	mov al,1
	mov bl,10
mul bl
mov byte [cs:firstval],al
inc word [cs:check]
jmp skipcount3
secval1:
   add byte [cs:firstval],1
   inc word [cs:check]
   jmp skipcount3 
   skip1:
    cmp al ,3 ;2
   je val2
   jmp skip2
   val2:
 	cmp word  [cs:check],0
	je next2
	jmp secval2
	next2:
    xor ax,ax
	mov al,2
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
   secval2:
   add byte [cs:firstval],2
   inc word [cs:check]
   jmp skipcount3 
   skip2:
    cmp al ,4 ;3
   je val3
   jmp skip3
    val3:
    cmp word  [cs:check],0
	je next3
	jmp secval3
	next3:
    xor ax,ax
	mov al,3
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval3:
   add byte [cs:firstval],3
   inc word [cs:check]
   jmp skipcount3 
   skip3:
    cmp al ,5 ;4
   je val4
   jmp skip4
   val4:
    cmp word  [cs:check],0
	je next4
	jmp secval4
	next4:
    xor ax,ax
	mov al,4
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval4:
   add byte [cs:firstval],4
   inc word [cs:check]
   jmp skipcount3 
   skip4:
    cmp al ,6 ;5
   je val5
   jmp skip5
   val5:
    cmp word  [cs:check],0
	je next5
	jmp secval5
	next5:
    xor ax,ax
	mov al,5
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval5:
   add byte [cs:firstval],5
   inc word [cs:check]
   jmp skipcount3 
   skip5:
    cmp al ,7 ;6
   je val6
   jmp skip6
   val6:
   cmp word  [cs:check],0
	je next6
	jmp secval6
	next6:
    xor ax,ax
	mov al,6
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval6:
   add byte [cs:firstval],6
   inc word [cs:check]
   jmp skipcount3 
   skip6:
    cmp al ,8 ;7
   je val7
   jmp skip7
   val7:
   cmp word  [cs:check],0
	je next7
	jmp secval7
	next7:
    xor ax,ax
	mov al,7
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval7:
   add byte [cs:firstval],7
   inc word [cs:check]
   jmp skipcount3 
   skip7:
    cmp al ,9 ;8
   je val8
   jmp skip8
   val8:
    cmp word  [cs:check],0
	je next8
	jmp secval8
	next8:
    xor ax,ax
	mov al,8
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval8:
   add byte [cs:firstval],8
   inc word [cs:check]
   jmp skipcount3 
   skip8:
    cmp al ,10 ;9
   je val9
   jmp skip9
   val9:
   cmp word  [cs:check],0
	je next9
	jmp secval9
	next9:
    xor ax,ax
	mov al,9
	mov bl,10
	mul bl
 	mov byte [cs:firstval],al
    inc word [cs:check]
    jmp skipcount3
	secval9:
   add byte [cs:firstval],9
   inc word [cs:check]
   jmp skipcount3 
   skip9:
     

   cmp al, 50 ; M
   je gotoM
   jmp skip10
   gotoM:
   inc word [cs:mintflag]
   mov word [cs:hourflag],0
   mov word [cs:secflag] ,0
   jmp skipcount3
   skip10:
   cmp al, 31 ; s
   je gotoS
   jmp skip11
   gotoS:
   inc word  [cs:secflag]
   mov  word [cs:hourflag],0
   mov  word[cs:mintflag],0
   jmp skipcount3

skip11:
cmp al, 35  ; H
je gotoH
jmp skip12
  
gotoH:
inc word [hourflag]
mov word [mintflag],0
mov word [secflag],0
jmp skipcount3
skip12:
 
skipcount3: 

cmp word [cs:check],2
jb end1
 
 

cmp word [hourflag],2
je changehour
jmp skip13

end1:
jmp end

changehour: 
xor bx,bx
mov bl ,[cs:firstval]
mov byte[cs:firstval],0
mov word [cs:hour],bx
mov word [hourflag],0
mov word [cs:check],0
jmp end

skip13:
cmp word [mintflag],2
je changeminute
jmp skip14
changeminute: 
xor bx,bx
mov bl ,[cs:firstval]
mov byte[cs:firstval],0
mov word [cs:minute],bx
mov word [mintflag],0
mov word [cs:check],0
jmp end

skip14:
cmp word [secflag],2
je changesecond
jmp skip15
changesecond: 
xor bx,bx
mov bl ,[cs:firstval]
mov byte[cs:firstval],0
mov word [cs:second],bx
 
mov word [secflag],0
mov word [cs:check],0
jmp end
 
skip15:
 
end:
mov al, 0x20
out 0x20, al ; end of interrupt
pop bx
iret 
 
 
start: 

call clrscr
 
mov ax, 10
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 7 ; blue on black attribute
push ax ; push attribute
mov ax, message1
push ax ; push address of message
call printstr 
  
mov ax, 18
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 7 ; blue on black attribute
push ax ; push attribute
mov ax, message2
push ax ; push address of message
call printstr 

  
mov ax, 28
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 7 ; blue on black attribute
push ax ; push attribute
mov ax, message3
push ax ; push address of message
call printstr 

 
 
xor ax, ax
mov es, ax ; point es to IVT base
cli ; disable interrupts
mov word [es:8*4], timer; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+2
sti ; enable interrupts

 
xor ax, ax
mov es, ax ; point es to IVT base
cli ; disable interrupts
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
sti 

l1: 
cmp word [cs:terminate],1
jne l1


mov ax,4c00h
int 0x21 
 