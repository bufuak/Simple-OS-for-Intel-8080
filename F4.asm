        ; 8080 assembler code
        .binfile F4.com
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

arraysort: ds 50;
outloopdsort ds 1;
outloopcsort ds 1;


begin:
	LXI SP,stack 	; always initialize the stack point
	MVI C,50 ;	C=50
	MVI H,50 ;
	MVI D,0 ;	D=0
	MVI E,0 ;
	MVI L,0 ;
loopsort:			; Initialing random numbers
	MOV L,C ;	D = C saving index
	MVI A, GET_RND ; Get random number
	call GTU_OS
	MOV E, B ;	E=random number
	LXI B,arraysort ;
	MOV A, C ;	Calculating index of arraysort
	ADD d ;	
	MOV C, A ;	
	MOV A, E ; store random number to A
	STAX B ;	Storing random number to arraysort
	MOV C,L ;	Getting back index
	INR D ;
	DCR c ;
	JNZ loopsort	; if c!= 0 go loop
	
	MOV C,H	;	Getting size from H
	DCR C	;	Outloop's condition is n-1
	MOV A,C	;	Saving C to outloopcsort
	STA outloopcsort
	MVI D,0	;	Starting index is 0
	MOV A,D
	STA outloopdsort	; Saving D to outloopdsort
outloopsort:
	LDA outloopcsort	; Getting size from outloopcsort
	MOV C,A	;	Now C is size
	MVI D,0	;	Setting D=0 for innerloop
innerloopsort:
	MOV L ,C ;	; Saving size to L
	LXI B, arraysort ;	Getting arraysorts memory location
	MOV A , C	; Calculating index
	ADD d
	MOV C, A ;
	LDAX B ;	Getting arraysort content in index A[i]
	MOV E,A ;	Saving it to E for comparison later
	INR c ;	
	LDAX B ;	Getting arraysort content in index A[i+1]
	CMP e ;		Compare them
	JC swapsort ;	If A[i+1]<A[i] go to swap
returnswapsort:
	MOV C,L ;	Get size from L (We saved before)
	INR D ;		Increasing index by 1
	DCR c ;		Decreasing size by 1
	JNZ innerloopsort ;	If C!=0 go back to innerloop

	LDA outloopdsort ; Get outloop's d from memory
	INR a		; Increase index by 1
	STA outloopdsort	; Store it to memory
	LDA outloopcsort	; Get outloop's c from memory
	MOV C,A		; C = A
	DCR C		; Decrease by 1
	MOV A,C		; A = C
	STA outloopcsort	; Store it to memory
	JNZ outloopsort	; If outloop's C is 0 we finished
	JMP startprintsort  ; Jump to startprint

swapsort:
	DCR c ;	Swap their content
	STAX B ; A[i] = A[i+1]
	INR c ;
	MOV A,E
	STAX B ; A[i+1] = A[i]
	JMP returnswapsort; Go to returnswap
	
startprintsort:
	MOV C,H		; Getting size from H
	MVI D,0		; setting index 0
printloopsort:
	MOV E,C ; Store C to E
	LXI B,arraysort ; Calculating arraysort's index
	MOV A,C
	ADD d
	MOV C,A
	LDAX B ; Getting arraysort's content to A
	MOV B,A ; B = A
	MVI A,PRINT_B ; Print B
	call GTU_OS
	MOV C,E ; Get C value from E
	INR D ; inc index
	DCR C ; dec stop condition
	JNZ printloopsort

	hlt		; end program
	