	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; Practical 2 makes the 4 LEDs light up to represent a 32 bit number
; Group 24

	EXPORT	start
start
		;loading in number to process
           LDR R1, =INSTR
		   LDR R0, [R1]
		   ;look up table for powers of 10
           LDR R1, =LUT
		   ;initialising registers
           MOV R2, #0
           MOV R3, #0
           MOV R4, #0
           MOV R5, #0
           MOV R12, #0
           MOV R11, #10
           CMP R0, #0
           BPL pos
          
		  ;if number is negative negate it and set to flag to 11
           ;negating the value of R1 and changing the sign
           NEG R0, R0
           MOV R11, #11
		   
		   ;load first of LUT  and shift to next 
pos    LDR R2, [R1], #4

while
		;set flags
		;subtract until number goes negative
		;and increment counter
           MOV R0, R0
           SUBS R0, R0, R2
           BMI next_check
           ADD R4, #1
           B while      
next_check
		;add back one number
		;compare with zero and skip if equal to zero
           ADD R0, R0, R2
           MOV R4, R4
           CMP R4, #0
           BEQ skip_1
           MOV R5, #1
skip_1
		;compare flag with 0 and skip if equal 
		;when first non zero number is processed this flag will be 1
           MOV R5, R5
           CMP R5 ,#0
           BEQ skip_2
		   ;store the counter in the stack and increment the 'stack pointer'
		   ;subtract 4 from 'stack counter'
           STR R4, [R13], #4
		   ADD R12, R12, #-4
skip_2
		;reset counter to zero
		;if we are a the end of LUT exit loop
		;otherwise load next LUT value and increment the LUT
           MOV R4, #0
           MOV R2, R2
           CMP R2, #1
           BEQ finish_check
           LDR R2, [R1], #4
           B while     

finish_check

	;initalising the outputs to the board
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
	
; r1 points to the SET register
; r2 points to the CLEAR register

	;set the registers that represent each LED
	ldr	r3,=0x00010000	; start with P1.16.
	mov r8,r3, lsl #1  ;r10 is for P1.17
	mov r9,r3, lsl #2  ;r10 is for P1.18
	mov r10,r3, lsl #3  ;r10 is for P1.19

;entering main loop
loop_
	;reseting the 'stack counter'
	MOV r7, r12
	str	r3,[r1]	   	; clear the bit -> turn off the LEDs
	str r8,[r1]
	str r9,[r1]
	str r10,[r1]

;delay for about 2 seconds
	ldr	r4,=40000000
	mov r4, r4
dloop	subs	r4,r4,#1
	bne	dloop

;check the sign flag
;if positive set leds to 1010 otherwise 1011
	CMP r11, #10
	BEQ positive
	
	str	r3,[r2]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r2]	;turn off P1.19
	B skip_pos
	
positive
	str	r3,[r2]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r1]	;turn on P1.19
	
skip_pos

	ldr	r4,=20000000 ;delay to show the sign
	mov r4, r4
sign_delay	
	subs r4,r4,#1
	bne	sign_delay

	;shift 'stack pointer' to the top of the stack initially using 'stack counter'
	;load number from the stack
	;add 4 to 'stack counter'
next_num
	ldr r5, [r13, r7]
	BL check_num
	ADD r7, #4
	
	
	ldr	r4,=20000000 ;delay to show the number
	mov r4, r4
num_delay	 
	subs r4,r4,#1
	bne	num_delay
	
	;check if we have went through the whole stack
	;loop to next number otherwise loop to start again
	CMP r7, #0
	BEQ last_num
	B next_num
	
last_num
	
	;loop again
	B loop_
	
INSTR DCD 1049
LUT DCD 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
		
stop	B	stop

;subroutine that sets the leds to their corresponing number
check_num
	CMP r5, #9
	BEQ nine
	CMP r5, #8
	BEQ eight
	CMP r5, #7
	BEQ seven
	CMP r5, #6
	BEQ six
	CMP r5, #5
	BEQ five
	CMP r5, #4
	BEQ four
	CMP r5, #3
	BEQ three
	CMP r5, #2
	BEQ two
	CMP r5, #1
	BEQ one
	CMP r5, #0
	BEQ zero

nine 
	str	r3,[r2]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r1]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r

eight 
	str	r3,[r2]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r1]		;turn on P1.18
	str r10,[r1]	;turn on P1.19
	B end_sub_r
	
seven 
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r2]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r

six
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r2]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r1]	;turn on P1.19
	B end_sub_r

five
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r2]		;turn off P1.17
	str r9,[r1]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r
	
four
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r2]		;turn off P1.17
	str r9,[r1]		;turn on P1.18
	str r10,[r1]	;turn on P1.19
	B end_sub_r

three
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r

two 
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r1]	;turn on P1.19
	B end_sub_r

one
	str	r3,[r1]	   	;turn on P1.16 LED (+) 
	str r8,[r1]		;turn off P1.17
	str r9,[r1]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r

zero 
	str	r3,[r2]	   	;turn on P1.16 LED (+) 
	str r8,[r2]		;turn off P1.17
	str r9,[r2]		;turn on P1.18
	str r10,[r2]	;turn on P1.19
	B end_sub_r
	
	
end_sub_r
	BX	lr
	
	END