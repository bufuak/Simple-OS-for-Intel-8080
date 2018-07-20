        ; 8080 assembler code
        .binfile part3.com
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


threadid: ds 10

begin:
	LXI SP,stack 	; always initialize the stack pointer
	MVI C,10
	MVI D,0
createloop:
	MOV H,C
	LXI b, F3
	MVI A,TCreate
	call GTU_OS
	MOV E,B ; Store thread id to E
	LXI b,threadid ; Get threadid array's index
	MOV A,C ; A=startindex
	ADD d ; A=threadid[index]
	MOV C,A ; index is not in C
	MOV A,E ; Thread id is now in A
	STAX B ; Store thread id to threadid array
	MOV C,H
	INR D ; Increase index
	DCR C ; 
	JNZ createloop

	MVI C,10
	MVI D,0
waitloop:	
	MOV H,C ; Store C value to H
	LXI b,threadid	; Get thread id starting index
	MOV A,C	; A= start
	ADD d	; A = start + index
	MOV C,A 
	LDAX B ; A=threadid[index]
	MOV B,A	; B is threadid
	MVI a,TJoin ; Waiting thread which id is B
	call GTU_OS
	MOV C,H ; Get C value from H
	INR D ; Increase Index
	DCR C
	JNZ waitloop
	hlt

F3:
   	mvi c, 100	; init C with 50
	mvi d, 1	; D = 1
	mvi b, 0	; B = 0
	mvi a, 50	; A = 0
f3loop:
	MOV B, A	; B = A
	MVI A, PRINT_B	; store the OS call code to A
	call GTU_OS	; call the OS
	MOV A, B	; A = B
	ADD d		; A = A + D
	CMP c
	JNZ f3loop	; goto loop if C!=0
	MVI a,TExit	; end thread
	MVI b,0
	call GTU_OS	