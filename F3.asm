        ; 8080 assembler code
        .binfile F3.com
        ; try "hex" for downloading in hex format
        .download bin  
        .objcopy gobjcopy
        .postbuild echo "OK!"
        ;.nodump

	; OS call list
PRINT_B		equ 1
PRINT_MEM	equ 2
READ_B		equ 3
READ_MEM	equ 4
PRINT_STR	equ 5
READ_STR	equ 6
GET_RND		equ 7
TExit		equ 8
TJoin		equ 9
TYield		equ 10
TCreate		equ 11

	; Position for stack pointer
stack   equ 0F000h

	org 000H
	jmp begin

	; Start of our Operating System
GTU_OS:	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop d
	pop D
	ret
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program prints integers from 0 to 50 by steps of 2 on the screen. Each number will be printed on a new line.

begin:
	LXI SP,stack 	; always initialize the stack pointer
    mvi c, 50	; init C with 50
	mvi d, 1	; D = 1
	mvi b, 0	; B = 0
	mvi a, 50	; A = 0
loop:
	MOV B, A	; B = A
	MVI A, PRINT_B	; store the OS call code to A
	call GTU_OS	; call the OS
	MOV A, B	; A = B
	ADD d		; A = A + D
	DCR c		; --C
	INR d ;
	JNZ loop	; goto loop if C!=0
	hlt		; end program
