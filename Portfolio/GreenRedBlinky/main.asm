;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .global _main
            .global __STACK_END
            .sect   .stack                  ; Make stack linker segment ?known?

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

_main
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w #WDTPW+WDTCNTCL+WDTTMSEL+WDTIS_5+WDTSSEL__ACLK,&WDTCTL ; Interval mode with ACLK and interval 4 gives 1s period
			bis.w #WDTIE, &SFRIE1                                       ; enable interrupts for the watchdog

SetupP1     bic.b   #BIT0,&P1OUT            ; Clear P1.0 output latch for a defined power-on state
            bis.b   #BIT0,&P1DIR            ; Set P1.0 to output direction
 			bic.b   #BIT7,&P9OUT            ; Clear P1.0 output latch for a defined power-on state
            bis.b   #BIT7,&P9DIR            ; Set P1.0 to output direction

SetupGPIO
            bic.b   #BIT1, &P1DIR      ; Set P1.1 to input direction (Push Button)
			bis.b   #BIT1, &P1REN      ; **ENABLE RESISTORS ON BUTTONS
			bis.b   #BIT1, &P1OUT      ; **SET TO BE PULLUP

			bic.b   #BIT2, &P1DIR      ; Set P1.1 to input direction (Push Button)
			bis.b   #BIT2, &P1REN      ; **ENABLE RESISTORS ON BUTTONS
			bis.b   #BIT2, &P1OUT      ; **SET TO BE PULLUP


UnlockGPIO  bic.w   #LOCKLPM5,&PM5CTL0      ; Disable the GPIO power-on default
                                            ; high-impedance mode to activate
                                            ; previously configured port settings
            mov.w   #CCIE,&TA0CCTL0         ; TACCR0 interrupt enabled
            mov.w   #62499,&TA0CCR0
            mov.w   #TASSEL__SMCLK+MC__CONTINOUS+ID_3,&TA0CTL  ; SMCLK, continuous mode
			nop
			; enable all interrupts
			bis.w   #GIE,SR            ; Enter LPM0 w/ interrupt
			nop

Mainloop
			bit.b   #BIT1+BIT2,&P1IN
			jz PAUSE
			jmp Mainloop
PAUSE
			mov.w #50000, R15
delay
			dec.w R15
			jnz delay

			bic.w #MC__CONTINUOUS,&TA0CTL
			mov.w #WDTPW+WDTHOLD+WDTCNTCL+WDTTMSEL+WDTIS_5+WDTSSEL__ACLK,&WDTCTL
L1

			bit.b   #BIT1,&P1IN
			jz START
			bit.b   #BIT2,&P1IN
			jz START
			jmp L1
START
			mov.w   #TASSEL__SMCLK+MC__CONTINOUS+ID_3,&TA0CTL  ; SMCLK, continuous mode
			mov.w #WDTPW+WDTCNTCL+WDTTMSEL+WDTIS_5+WDTSSEL__ACLK,&WDTCTL
			jmp     Mainloop                ; Again

;-------------------------------------------------------------------------------
WDT_ISR;    WDT Interrupt Service Routine
;-------------------------------------------------------------------------------
            xor.b   #BIT0,&P1OUT            ; Toggle P1.0
            bit.b   #BIT1,&P1IN
            jz LEDOFF
            reti
LEDOFF
			bic.b	#BIT0,&P1OUT
            reti
                                            ;
;-------------------------------------------------------------------------------
TIMER0_A0_ISR;    Timer0_A3 CC0 Interrupt Service Routine
;-------------------------------------------------------------------------------
            add.w   #62499,&TA0CCR0         ; Add offset to TA0CCR0
            bit.b	#BIT2, &P1IN
            jz LEDON
            bic.b 	#BIT7, &P9OUT
            reti
LEDON
            xor.b   #BIT7,&P9OUT            ; Toggle LED
            reti
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   WDT_VECTOR              ; Watchdog Timer
            .short  WDT_ISR
            .sect   TIMER0_A0_VECTOR        ; Timer0_A3 CC0 Interrupt Vector
            .short  TIMER0_A0_ISR
            .end
