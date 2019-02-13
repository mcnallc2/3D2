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
	MOV R13, #10
	CMP R0, #0
	BPL pos
	
	;negating the value of R1 and changing the sign
	NEG R0, R0
	MOV R13, #11
	
pos	LDR R2, [R1]

while
	SUB R0, R0, R2
	BMI next_check
	;need to add to a register, then add this to a stack 
	
	
next_check
	ADD R0, R0, R2
	CMP R2, #1
	BEQ finish_check
	LDR R2, [R1, #4]
	B while
	
finish_check

INSTR DCD 1049

LUT DCD 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1


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

	;ldr	r5,=0x00100000	; end when the mask reaches this value
;wloop	ldr	r3,=0x00010000	; start with P1.16.
;floop	str	r3,[r2]	   	; clear the bit -> turn on the LED

;;delay for about a half second
	;ldr	r4,=1000000
;dloop	subs	r4,r4,#1
	;bne	dloop

	;str	r3,[r1]		;set the bit -> turn off the LED
	;mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	;cmp	r3,r5
	;bne	floop
	;b	wloop
stop	B	stop

	END