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
	
;---------------------------------------------------------------------------------

;entering main loop
wloop
	
	;turning off all leds
	str	r2,[r1]	
	;loading in the current value of the buttons
	ldr r7,[r3]	
	;masking the buttons as we are looking for a low signal for a pressed button
	and r7, r7 ,#0x00F00000
	
	;if P1.20 is pressed branch to increment
	cmp r7, #0x00E00000
	beq inc
	;if P1.21 is pressed branch to decrement
	cmp r7, #0x00D00000
	beq dec
	;if P1.22 is pressed branch to addition
	cmp r7, #0x00B00000
	beq addi
	;if P1.23 is pressed branch to subtraction
	cmp r7, #0x00700000
	beq subt
	
	;if nothing is pressed simply continue to loop
	B wloop
	
;if inc call the increment subroutine and return to start
inc
	BL increment
	B wloop	
	
;if dec call the decrement subroutineand and return to start
dec
	BL decrement
	B wloop

;if addi call the addition subroutineand and return to start
addi
	BL addition
	B wloop	
	
;if subt call the subtraction subroutineand and return to start
subt
	BL subtraction
	B wloop
	
;stop end of main loop; this can never be reached!!
stop	B	stop
	
;-------------------------------------------------------------------

;subroutine for incrementing the current number
increment
	
	;delay usede to debounce button
	ldr	r8,=1000000
	mov r8, r8
_debounce	 
	subs r8,r8,#1
	bne	_debounce
	
	;load in value of button
	ldr r7,[r3]
	;mask the value
	and r7, r7 ,#0x00F00000 
	;if the button is still pressed its not bounce
	cmp r7, #0x00E00000
	;if there is bounce skip increment
	bne finish1
	
	;add 1 to r4 (current number) 
	add r4, r4, r5
	;display current number on the leds
	str r4,[r9]
	
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay 
	subs r8,r8,#1
	bne	_delay
	
finish1
	;link back to the main loop
	BX	lr

;---------------------------------------------------------------------

;subroutine for decrementing the current number
decrement

	;delay usede to debounce button
	ldr	r8,=1000000
	mov r8, r8
_debounce2	 
	subs r8,r8,#1
	bne	_debounce2
	
	;load in the current value of button
	ldr r7,[r3]
	;mask the value
	and r7, r7 ,#0x00F00000
	;if button is still pressed there was no bounce
	cmp r7, #0x00D00000
	;if there was bounce dont decrement
	bne finish2
	
	;subtract 1 from the current number
	sub r4, r4, r5
	str r4,[r9]
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay2
	subs r8,r8,#1
	bne	_delay2

finish2
	;branch back to main loop
	BX	lr
	
;-----------------------------------------------------------------------

;subroutine for addition and clearing last operation
addition

	;delay used to debounce button
	ldr	r8,=1000000
	mov r8, r8
_debounce3 
	subs r8,r8,#1
	bne	_debounce3
	
	;load current value of buttons
	ldr r7,[r3]
	;mask the buttons
	and r7, r7 ,#0x00F00000 
	;check if button is still pressed
	cmp r7, #0x00B00000
	;if ther was bounce do nothing and skip to end of subroutine
	bne finish3
	
	;delay to check if there was a long press
	ldr	r8,=10000000
	mov r8, r8
_longpress 
	subs r8,r8,#1
	bne	_longpress
	
	;check value of buttons
	ldr r7,[r3]
	;mask buttons
	and r7, r7 ,#0x00F00000 
	;if button is still pressed it is a long press
	cmp r7, #0x00B00000
	;if its a long press skip over next steps
	beq long_press
	
	;if it is not a long press we add
	;display previous calculation
	str r12, [r9]
	;add current number (r4) to previous stored value (r10) 
	mov r12, r10
	add r10, r10, r4
	mov r4, #0
	
	;delay to show the number for split second
	ldr	r8,=10000000
	mov r8, r8
_delay3
	subs r8,r8,#1
	bne	_delay3
	
	;branch past the long press code
	B finish3

;if it is a long press
long_press
	
	;flash all leds to indicate long press
	ldr r10, =0x000F0000
	str r10, [r9]
	
	;delay to flash the number for split second
	ldr	r8,=3000000
	mov r8, r8
_delay3_1
	subs r8,r8,#1
	bne	_delay3_1

	;delay to turn off leds for split second
	str r10, [r1]
	ldr	r8,=3000000
	mov r8, r8
_delay3_2
	subs r8,r8,#1
	bne	_delay3_2
	
	;delay to flash leds again
	str r10, [r9]
	ldr	r8,=3000000
	mov r8, r8
_delay3_3
	subs r8,r8,#1
	bne	_delay3_3
	
	;mov the previous -> previous stored value into r10 
	mov r10, r12
	;set current number (r4) to zero
	mov r4, #0
	
finish3
	;branch back to main loop
	BX	lr

;----------------------------------------------------------------------
	
;subroutine for subtration and clear all
subtraction

	;delay used for debounce
	ldr	r8,=1000000
	mov r8, r8
_debounce4	 
	subs r8,r8,#1
	bne	_debounce4
	
	;check value of the buttons
	ldr r7,[r3]
	;mask buttons
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
	;mask buttons
	and r7, r7 ,#0x00F00000 
	;if button is still pressed it is a long press
	cmp r7, #0x00700000
	;if its a long press skip over next steps
	beq long_press1

	;if it wasnt a long press 
	;display the result of the previous calculation
	str r12, [r9]
	;subtract current number from previous stored value 
	mov r12, r10
	sub r10, r10, r4
	mov r4, #0
	
	;delay to show the number for a split second
	ldr	r8,=10000000
	mov r8, r8
_delay4_1
	subs r8,r8,#1
	bne	_delay4_1
	
	;branch past the long press code
	B finish4

;if there was a long press
long_press1

	;flash all the leds once
	ldr r10, =0x000F0000
	str r10, [r9]
	
	;delay to show the flash
	ldr	r8,=10000000
	mov r8, r8
_delay4_2
	subs r8,r8,#1
	bne	_delay4_2
	
	;then reset all numbers to zero
	mov r4, #0
	mov r10,#0
	mov r12,#0

finish4
	BX	lr


	END
		
		
		
		
		