	        ; 8080 assembler code
        .binfile BinarySearch.com
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


enternumber: dw 'Enter number you want to find: ',00AH,00H ; null terminated string
error: dw 'Error',00AH,900H ;
array: ds 50;
outloopd ds 1;
outloopc ds 1;
binaryhigh ds 1;
binarylow ds 1;
memoryb ds 1;
memoryc ds 1;

begin:
	LXI SP,stack 	; always initialize the stack point
	MVI C,50 ;	C=50
	MVI H,50 ;
	MVI D,0 ;	D=0
	MVI E,0 ;
	MVI L,0 ;
loop:			; Initialing random numbers
	MOV L,C ;	D = C saving index
	MVI A, GET_RND ; Get random number
	call GTU_OS
	MOV E, B ;	E=random number
	LXI B,array ;
	MOV A, C ;	Calculating index of array
	ADD d ;	
	MOV C, A ;	
	MOV A, E ; store random number to A
	STAX B ;	Storing random number to array
	MOV C,L ;	Getting back index
	INR D ;
	DCR c ;
	JNZ loop	; if c!= 0 go loop
	
	MOV C,H	;	Getting size from H
	DCR C	;	Outloop's condition is n-1
	MOV A,C	;	Saving C to outloopc
	STA outloopc
	MVI D,0	;	Starting index is 0
	MOV A,D
	STA outloopd	; Saving D to outloopd
outloop:
	LDA outloopc	; Getting size from outloopc
	MOV C,A	;	Now C is size
	MVI D,0	;	Setting D=0 for innerloop
innerloop:
	MOV L ,C ;	; Saving size to L
	LXI B, array ;	Getting arrays memory location
	MOV A , C	; Calculating index
	ADD d
	MOV C, A ;
	LDAX B ;	Getting array content in index A[i]
	MOV E,A ;	Saving it to E for comparison later
	INR c ;	
	LDAX B ;	Getting array content in index A[i+1]
	CMP e ;		Compare them
	JC swap ;	If A[i+1]<A[i] go to swap
returnswap:
	MOV C,L ;	Get size from L (We saved before)
	INR D ;		Increasing index by 1
	DCR c ;		Decreasing size by 1
	JNZ innerloop ;	If C!=0 go back to innerloop

	LDA outloopd ; Get outloop's d from memory
	INR a		; Increase index by 1
	STA outloopd	; Store it to memory
	LDA outloopc	; Get outloop's c from memory
	MOV C,A		; C = A
	DCR C		; Decrease by 1
	MOV A,C		; A = C
	STA outloopc	; Store it to memory
	JNZ outloop	; If outloop's C is 0 we finished
	JMP startprint  ; Jump to startprint

swap:
	DCR c ;	Swap their content
	STAX B ; A[i] = A[i+1]
	INR c ;
	MOV A,E
	STAX B ; A[i+1] = A[i]
	JMP returnswap; Go to returnswap

startprint:
	MOV C,H		; Getting size from H
	MVI D,0		; setting index 0
printloop:
	MOV E,C ; Store C to E
	LXI B,array ; Calculating array's index
	MOV A,C
	ADD d
	MOV C,A
	LDAX B ; Getting array's content to A
	MOV B,A ; B = A
	MVI A,PRINT_B ; Print B
	call GTU_OS
	MOV C,E ; Get C value from E
	INR D ; inc index
	DCR C ; dec stop condition
	JNZ printloop

binarysearch:
	MVI A,PRINT_STR	; Printing enternumber
	LXI B,enternumber
	call GTU_OS
	MVI A,READ_B	; Reading number from user
	call GTU_OS
	MOV E,B	; Storing number to E
	MOV C,H	; Getting arrays size to C
	DCR C
	MOV A,C
	STA binaryhigh ; Storing size to binaryhigh
	MVI D,0
	MOV A,D
	STA binarylow	; Storing 0 to binarylow
binaryloop:	; Binary loop
	LDA binaryhigh	; Getting high index of array
	MOV L,A
	LDA binarylow ; Getting low index of array
	MOV D,A ; Storing low index to D
	MOV A,L
	CMP D
	JZ finish ; if high=low jump finish
	JC finish ; if high<low jump finish
findindex: ; Finding middle
	DCR A ; Decrease A by 1
	INR D ; Increase D by 1
	CMP D ; Compare them
	JZ indexequal ; If A==D jump indexequal
	JC indexequal ; If D>A jump indexother
	JMP findindex

indexequal: ;If A==D
	LXI B,array ; Getting arrays memory location
	MOV A,C ; Getting index to A
	ADD D ; Add middle index
	MOV C,A ; Store this index back to C
	LDAX B ; Get A=array[middle]
	CMP E ; Compare with our number
	JZ equal ; If they are equal we found it go to equal
	JNC smaller ; If smaller we must search low to mid
			;then bigger
	INR D ; Look for if middle+1 = high so we can end
	LDA binaryhigh ; Getting high
	CMP D ; Compare it
	JZ finish ; If middle+1 = high go to finish
	MOV A,D ; Store it to low, now our low will be middle
	STA binarylow
	JMP binaryloop ; Go back to binaryloop

smaller: ;If our number is smaller
	DCR D
	LDA binarylow ; Getting low index
	CMP D ; Compare it with middle
	JZ finish ; If middle-1 = low we go to finish
	INR D ; Else D = middle
	MOV A,D ; Store it to High
	STA binaryhigh ; Now our low will be low high=middle
	JMP binaryloop ; Go back to binaryloop

finish: ; Our finish 
	LXI B,array ; Getting array starting index
	MOV A,C ; Index calculation with middle
	ADD D
	MOV C,A
	LDAX B ; A = array[middle]
	CMP E ; Compare with our number
	JZ equal ; If they are equal go to equal
	LXI B,error ; Else print error, we cant found number
	MVI A,PRINT_STR 
	call GTU_OS
	hlt

;This printing works like that:
;If B=04 C=42 They are hexadecimal numbers
;Our printing indexes will be 04 66 as integer numbers.
equal: ; If they are equal
	MVI A,PRINT_B ; Print b content as "integer"
	call GTU_OS
	MOV B,C ; Print c content as "integer"
	call GTU_OS
	hlt
		