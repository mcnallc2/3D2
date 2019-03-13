AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; Practical 2 makes the 4 LEDs light up to represent a 32 bit number
; Group 24

	EXPORT	start
start
		
;initalising the i/o ports for the board
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0xE0028010

	;r1 now sets direction
	ldr	r1,=IO1DIR
	;select P1.19--P1.16 leds
	ldr	r2,=0x000F0000
	;make the leds outputs
	str	r2,[r1]	
	;r1 now turns leds off
	ldr	r1,=IO1SET
	;turn the LEDs off
	str	r2,[r1]	
	
	;r9 now turns on leds
	ldr	r9,=IO1CLR
	;r3 now reads in signals from buttons
	ldr r3, =IO1PIN
	
	;initialising registers  
    mov r4,  #0
    mov r5,  #0
	mov r6,	 #0
    mov r7,  #0
    mov r8,  #0
	mov r10, #0
	mov r11, #0
	mov r12, #0

	;r5 now represents binary 1 on the leds
	ldr r5, =0x00010000
	
			
;entering main loop
wloop
	
	;turning off all leds
	str	r2,[r1]	
	ldr r7,[r3]				
	and r7, r7 ,#0x00f00000 ; masking buttons
	
	
	cmp r7, #0x00E00000
	beq inc
	cmp r7, #0x00D00000
	beq dec
	cmp r7, #0x00B00000 ; addition
	beq addi
	cmp r7, #0x00700000 ; subtraction
	beq subt
	
	B wloop
	
inc
	BL increment
	B wloop	
dec
	BL decrement
	b wloop	
addi
	BL addition
	B wloop	
subt
	BL subtraction
	B wloop
	
stop	B	stop
	
;subroutine for incrementing the current number
increment
		
	ldr	r8,=1000000 ;delay for debounce
	mov r8, r8
_debounce	 
	subs r8,r8,#1
	bne	_debounce
	
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000 
	cmp r7, #0x00E00000
	bne finish1
	
	add r4, r4, r5
	str r4,[r9]
	
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay 
	subs r8,r8,#1
	bne	_delay
	
finish1
	BX	lr


;subroutine for decrementing the current number
decrement

	ldr	r8,=1000000 ;delay for debounce
	mov r8, r8
_debounce2	 
	subs r8,r8,#1
	bne	_debounce2
	
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000 
	cmp r7, #0x00D00000
	bne finish2
	
	sub r4, r4, r5
	str r4,[r9]
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay2
	subs r8,r8,#1
	bne	_delay2

finish2
	BX	lr


;subroutine for addition
addition

	ldr	r8,=1000000 ;delay for debounce
	mov r8, r8
_debounce3 
	subs r8,r8,#1
	bne	_debounce3
	
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000 
	cmp r7, #0x00B00000
	bne finish3
	
	;delay to check if there was a long press
	ldr	r8,=10000000
	mov r8, r8
_longpress 
	subs r8,r8,#1
	bne	_longpress
	
	;check value of buttons
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000 
	;if button is still pressed it is a long press
	cmp r7, #0x00B00000
	;if its a long press skip over next steps
	beq long_press
	
	add r10, r10, r4
	str r10, [r9]
	mov r12, r10
	mov r4, #0
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay3
	subs r8,r8,#1
	bne	_delay3
	
	B finish3
	
long_press
	ldr r10, =0x000F0000
	str r10, [r9]
	
	ldr	r8,=3000000 ;delay to show the number
	mov r8, r8
_delay3_1
	subs r8,r8,#1
	bne	_delay3_1

	str r10, [r1]
	ldr	r8,=3000000 ;delay to show the number
	mov r8, r8
_delay3_2
	subs r8,r8,#1
	bne	_delay3_2
	
	str r10, [r9]
	ldr	r8,=3000000 ;delay to show the number
	mov r8, r8
_delay3_3
	subs r8,r8,#1
	bne	_delay3_3
	
	mov r10, r12
	mov r4, #0
	
finish3
	BX	lr
	
	
;subroutine for subtration and clearing everything
subtraction

	;delay used for debounce
	ldr	r8,=1000000
	mov r8, r8
_debounce4	 
	subs r8,r8,#1
	bne	_debounce4
	
	;check value of the buttons
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000
	;check if the button is still pressed 
	cmp r7, #0x00700000
	;if not, it was bounce
	bne finish4
	
	;delay to check if there was a long press
	ldr	r8,=10000000
	mov r8, r8
_longpress1	 
	subs r8,r8,#1
	bne	_longpress1
	
	;check value of buttons
	ldr r7,[r3]
	and r7, r7 ,#0x00F00000 
	;if button is still pressed it is a long press
	cmp r7, #0x00700000
	;if its a long press skip over next steps
	beq long_press1

	;if it wasnt a long press 
	;subtract current number from 
	sub r10, r10, r4
	;display the result of the previous calculation
	str r10, [r9]
	mov r4, #0
	ldr	r8,=10000000 ;delay to show the number
	mov r8, r8
_delay4_1
	subs r8,r8,#1
	bne	_delay4_1
	
	B finish4
	
long_press1
	ldr r10, =0x000F0000
	str r10, [r9]
	
	ldr	r8,=10000000 ;delay to show the number
	mov r8, r8
_delay4_2
	subs r8,r8,#1
	bne	_delay4_2
	
	mov r4, #0
	mov r10,#0

finish4
	BX	lr


	END
		
		
		
		
		