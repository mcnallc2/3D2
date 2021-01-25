; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014 -- 2019.

	EXPORT	start
start
; initialisation code

IO1DIR	EQU	0xE0028008
IO1SET	EQU	0xE0028004
IO1CLR	EQU	0xE002800C
	
	;r1 now sets direction
	ldr	r2,=IO1DIR
	;select P0.16 leds
	ldr r3, =0x00260000
	;make the led outputs
	str	r3, [r2]
	
	;r1 now turns leds off
	ldr	r2,=IO1SET
	str	r3,[r2]	


; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program

	ldr r5, =LUT
	ldr r6,=IO1SET
	ldr r7,=IO1CLR
	ldr r8, =0
	ldr r12, =200
	
loop1
	ldr r11, =COUNT
	ldr r4, [r11]
	cmp r4, r12
	bne loop1
	add r12, #200

	;now turn all leds off
	str r3,[r6]	
	;load in next led mask
	ldr r9, [r5, r8]
	;turn on this led
	str r9, [r7]
	
	subs r10, r8, #8
	bne increment
	mov r8, r10
	b no_increment

increment
	add r8, r8, #4	
no_increment

	b loop1
	
LUT DCD 0x00200000, 0x00020000, 0x00040000

wloop	b	wloop  		; branch always
;main program execution will never drop below the statement above.

	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler
;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts


	ldr r0, =COUNT
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]


;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR
	
	AREA	Counter, DATA, READWRITE	
		
COUNT DCD 0

	END