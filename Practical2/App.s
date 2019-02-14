	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; Practical 2 makes the 4 LEDs light up to represent a 32 bit number
; Group 24

	EXPORT	start
start

	LDR R0, =INSTR
	LDR R1, =LUT
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	LDR R12, =0xA0000400
	MOV R11, #10
	CMP R0, #0
	BPL pos
	
	;negating the value of R1 and changing the sign
	NEG R0, R0
	MOV R11, #11
	
pos	LDR R2, [R1]

while
	SUB R0, R0, R2
	BMI next_check
	ADD R4, #1
	B while
	
next_check
	ADD R0, R0, R2
	STR R4, [R12], #4
	CMP R2, #1
	BEQ finish_check
	LDR R2, [R1, #4]
	B while
	
finish_check


	;LDR R12, =0xA0000400
	
;IO1DIR	EQU	0xE0028018
;IO1SET	EQU	0xE0028014
;IO1CLR	EQU	0xE002801C

	;ldr	r1,=IO1DIR
	;ldr	r2,=0x000f0000	;select P1.19--P1.16
	;str	r2,[r1]		;make them outputs
	;ldr	r1,=IO1SET
	;str	r2,[r1]		;set them to turn the LEDs off
	;ldr	r2,=IO1CLR
	
;; r1 points to the SET register
;; r2 points to the CLEAR register

	;ldr	r3,=0x00010000	; start with P1.16.
	;mov r8,r3, lsl #1  ;r10 is for P1.17
	;mov r9,r3, lsl #2  ;r10 is for P1.18
	;mov r10,r3, lsl #3  ;r10 is for P1.19
		
	;str	r3,[r1]	   	; clear the bit -> turn on the LED
	;str r8,[r1]
	;str r9,[r1]
	;str r10,[r1]
		
;loop_

;;delay for about a second
	;ldr	r4,=2000000
;dloop	subs	r4,r4,#1
	;bne	dloop


	;CMP r11, #10
	;BNE nega
	
	;str	r3,[r2]	   	;turn on P1.16 LED (+) 
	;str r8,[r1]		;turn off P1.17
	;str r9,[r2]		;turn on P1.18
	;str r10,[r1]	;turn off P1.19
	
;nega
	;str	r3,[r2]	   	;turn on P1.16 LED (+) 
	;str r8,[r1]		;turn off P1.17
	;str r9,[r2]		;turn on P1.18
	;str r10,[r2]	;turn on P1.19
	
	;ldr	r4,=2000000 ;delay to show the sign
;sign_delay	
	;subs r4,r4,#1
	;bne	sign_delay

	;ldr r5, [r12], #4
	;BL check_num
	
	;ldr	r4,=2000000 ;delay to show the sign
;num_delay	
	;subs r4,r4,#1
	;bne	num_delay
	;B loop_
	
INSTR DCD 1049
LUT DCD 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
		
stop	B	stop


check_num
	CMP r11, #9
	BEQ nine
	CMP r11, #9
	BEQ eight
	CMP r11, #9
	BEQ seven
	CMP r11, #9
	BEQ six
	CMP r11, #9
	BEQ five
	CMP r11, #9
	BEQ four
	CMP r11, #9
	BEQ three
	CMP r11, #9
	BEQ two
	CMP r11, #9
	BEQ one
	CMP r11, #9
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