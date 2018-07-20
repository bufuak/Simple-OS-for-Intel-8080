        ; 8080 assembler code
        .binfile part4.com
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


arraysort: ds 50;
outloopdsort ds 1;
outloopcsort ds 1;


error: dw 'Error',00AH,900H ;
arraysearch: ds 50;
outloopdsearch ds 1;
outloopcsearch ds 1;
binaryhigh ds 1;
binarylow ds 1;
firstindex ds 1;
tenthindex ds 1;
fortithindex ds 1;
first ds 1;
tenth ds 1;
fortith ds 1;
condition ds 1;

begin:
	LXI SP,stack 	; always initialize the stack pointer
	LXI b, F4
	MVI A,TCreate
	call GTU_OS
	MOV E,B ; Store thread id to E
	LXI b, F5
	call GTU_OS
	MVI A,TJoin ; Waiting second thread
	call GTU_OS
	MOV B,E		; Getting first threadid
	call GTU_OS ; Waiting first thread
	hlt




F4:
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
	MVI a,TExit
	MVI b,0
	call GTU_OS
	


F5:
   	MVI C,50 ;	C=50
	MVI H,50 ;
	MVI D,0 ;	D=0
	MVI E,0 ;
	MVI L,0 ;
loopsearch:			; Initialing random numbers
	MOV L,C ;	D = C saving index
	MVI A, GET_RND ; Get random number
	call GTU_OS
	MOV E, B ;	E=random number
	LXI B,arraysearch ;
	MOV A, C ;	Calculating index of arraysearch
	ADD d ;	
	MOV C, A ;	
	MOV A, E ; store random number to A
	STAX B ;	Storing random number to arraysearch
	MOV C,L ;	Getting back index
	INR D ;
	DCR c ;
	JNZ loopsearch	; if c!= 0 go loop
	
	MOV C,H	;	Getting size from H
	DCR C	;	Outloop's condition is n-1
	MOV A,C	;	Saving C to outloopcsearch
	STA outloopcsearch
	MVI D,0	;	Starting index is 0
	MOV A,D
	STA outloopdsearch	; Saving D to outloopdsearch
outloopsearch:
	LDA outloopcsearch	; Getting size from outloopcsearch
	MOV C,A	;	Now C is size
	MVI D,0	;	Setting D=0 for innerloop
innerloopsearch:
	MOV L ,C ;	; Saving size to L
	LXI B, arraysearch ;	Getting arraysearchs memory location
	MOV A , C	; Calculating index
	ADD d
	MOV C, A ;
	LDAX B ;	Getting arraysearch content in index A[i]
	MOV E,A ;	Saving it to E for comparison later
	INR c ;	
	LDAX B ;	Getting arraysearch content in index A[i+1]
	CMP e ;		Compare them
	JC swapsearch ;	If A[i+1]<A[i] go to swap
returnswapsearch:
	MOV C,L ;	Get size from L (We saved before)
	INR D ;		Increasing index by 1
	DCR c ;		Decreasing size by 1
	JNZ innerloopsearch ;	If C!=0 go back to innerloop

	LDA outloopdsearch ; Get outloop's d from memory
	INR a		; Increase index by 1
	STA outloopdsearch	; Store it to memory
	LDA outloopcsearch	; Get outloop's c from memory
	MOV C,A		; C = A
	DCR C		; Decrease by 1
	MOV A,C		; A = C
	STA outloopcsearch	; Store it to memory
	JNZ outloopsearch	; If outloop's C is 0 we finished
	JMP startprintsearch  ; Jump to startprint

swapsearch:
	DCR c ;	Swap their content
	STAX B ; A[i] = A[i+1]
	INR c ;
	MOV A,E
	STAX B ; A[i+1] = A[i]
	JMP returnswapsearch; Go to returnswap

startprintsearch:
	MOV C,H		; Getting size from H
	MVI D,0		; setting index 0
	MVI A,0		;
	STA firstindex	; first = 1st index
	MVI A,9
	STA tenthindex	; tenth = 10th index
	MVI A,39
	STA fortithindex ; fortith = 40th index
	MVI A,0
	STA condition  ; condition = 0
printloopsearch:
	MOV E,C ; Store C to E
	LXI B,arraysearch ; Calculating arraysearch's index
	MOV A,C
	ADD d
	MOV C,A
	LDAX B ; Getting arraysearch's content to A
	MOV B,A ; B = A
	MVI A,PRINT_B ; Print B
	; call GTU_OS
	LDA firstindex
	CMP D
	JZ storefirst
	LDA tenthindex
	CMP D
	JZ storetenth
	LDA fortithindex
	CMP D
	JZ storefortith
keepprintsearch:
	MOV C,E ; Get C value from E
	INR D ; inc index
	DCR C ; dec stop condition
	JNZ printloopsearch
	JMP searchfirst

storefirst:
	MOV A,B
	STA first
	JMP keepprintsearch
storetenth:
	MOV A,B
	STA tenth
	JMP keepprintsearch
storefortith:
	MOV A,B
	STA fortith
	JMP keepprintsearch

searchfirst:
	LDA first
	MOV B,A
	JMP binarysearch

searchtenth:
	LDA tenthindex
	STA condition
	LDA tenth
	MOV B,A
	JMP binarysearch

searchfortith
	LDA fortithindex
	STA condition
	LDA fortith
	MOV B,A
	JMP binarysearch

binarysearch:
	MOV E,B	; Storing number to E
	MOV C,H	; Getting arraysearchs size to C
	DCR C
	MOV A,C
	STA binaryhigh ; Storing size to binaryhigh
	MVI D,0
	MOV A,D
	STA binarylow	; Storing 0 to binarylow
binaryloop:	; Binary loop
	LDA binaryhigh	; Getting high index of arraysearch
	MOV L,A
	LDA binarylow ; Getting low index of arraysearch
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
	LXI B,arraysearch ; Getting arraysearchs memory location
	MOV A,C ; Getting index to A
	ADD D ; Add middle index
	MOV C,A ; Store this index back to C
	LDAX B ; Get A=arraysearch[middle]
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
	LXI B,arraysearch ; Getting arraysearch starting index
	MOV A,C ; Index calculation with middle
	ADD D
	MOV C,A
	LDAX B ; A = arraysearch[middle]
	CMP E ; Compare with our number
	JZ equal ; If they are equal go to equal
	LXI B,error ; Else print error, we cant found number
	MVI A,PRINT_STR 
	call GTU_OS
	LDA firstindex
	MOV B,A
	LDA condition
	CMP B
	JZ searchtenth

	LDA tenthindex
	MOV B,A
	LDA condition
	CMP B
	JZ searchfortith
	MVI a,TExit
	MVI b,0
	call GTU_OS	

;This printing works like that:
;If B=04 C=42 They are hexadecimal numbers
;Our printing indexes will be 04 66 as integer numbers.
equal: ; If they are equal
	MVI A,PRINT_B ; Print b content as "integer"
	call GTU_OS
	MOV B,C ; Print c content as "integer"
	call GTU_OS
	LDA firstindex
	MOV B,A
	LDA condition
	CMP B
	JZ searchtenth

	LDA tenthindex
	MOV B,A
	LDA condition
	CMP B
	JZ searchfortith
	MVI a,TExit
	MVI b,0
	call GTU_OS