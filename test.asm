        ; 8080 assembler code
        .binfile test.com
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

	;This program reads an integer from keyboard and saves to the memory adress showed by B and C.
	; The number is also printed on the screen.

entername: dw 'Enter your name: ',00AH,00H ; null terminated string
welcome: dw 'Welcome: ',00AH,00H;
enternumber: dw 'Enter how many random numbers you want',00AH,00H;
name: ds 20 ;
number: ds 1;


begin:
	LXI SP,stack 	; always initialize the stack point
	LXI B,entername	; Printing entername
	MVI A, PRINT_STR
	call GTU_OS	; 
	LXI B,name	; Reading name
	MVI A, READ_STR ; store the OS call code to A
	call GTU_OS
	LXI B, welcome  ; Printing welcome massage
	MVI A, PRINT_STR ;
	call GTU_OS
	LXI B, name
	call GTU_OS
	LXI B, enternumber; Printing enternumber
	call GTU_OS
	LXI B, number	;Reading number
	MVI A, READ_MEM	;
	call GTU_OS
	LDA number ;	A=number
	MOV C,A ;	C=A
loop:			; Printing random numbers
	MVI A, GET_RND ; Get random number
	call GTU_OS
	MVI A, PRINT_B	; Print it
	call GTU_OS;
	DCR c	;	C--
	JNZ loop	; if c!= 0 go loop
	hlt		; end program
