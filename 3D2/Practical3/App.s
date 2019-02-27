	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; Practical 2 makes the 4 LEDs light up to represent a 32 bit number
; Group 24

	EXPORT	start
start
		
	;initalising the outputs to the board
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0xE0028010

	ldr	r1,=IO1DIR
	ldr	r2,=0x000F0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
	
	ldr r3, =IO1PIN
	
; r1 points to the SET register
; r2 points to the CLEAR register
	
	ldr r8,=0x00100000  ; r4 is now button P1.20
	ldr r9, =0x00200000  ; r4 is now button P1.21
	ldr r10, =0x00400000  ; r4 is now button P1.22
	ldr r11, =0x00800000  ; r4 is now button P1.23
	
	

;entering main loop
loop
	
	ldr r6, [r5]
	and r6, r6, r4 
	cmp r6, #0
	bne skip
	
	str r3, [r2]
	
	ldr	r7,=10000000 ;delay to show the number
	mov r7, r7
num_delay	 
	subs r7,r7,#1
	bne	num_delay
	
	str r3, [r1]
	
skip
	B loop	
	
	
	
stop	B	stop
	
	END