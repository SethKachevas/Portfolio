;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .global _main
            .global __STACK_END

            .sect   .stack

            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
_main
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

SetupP1	    bis.b #BIT0, &P1OUT ;
			bis.b #BIT0, &P1DIR ;
			bis.b #BIT7, &P9OUT ;
			bis.b #BIT7, &P9DIR ;

			bic.b #BIT1, &P1DIR ; Set P1.1 to input direction (Push Button)
			bis.b #BIT1, &P1REN ; **ENABLE RESISTORS ON BUTTONS
			bis.b #BIT1, &P1OUT ; **SET TO BE PULLUP
			bic.b #BIT2, &P1DIR ; Set P1.2 to input direction (Push Button)
			bis.b #BIT2, &P1REN ; **ENABLE RESISTORS ON BUTTONS
			bis.b #BIT2, &P1OUT ; **SET TO BE PULLUP




UnlockGPIO	bic.w #LOCKLPM5, &PM5CTL0 ;Disable the GPIO power-on default

		bis.w   #TASSEL_2+MC_1+ID_3+TAIE, TA0CTL    ; Start timer
       	bis.w   #TAIDEX_0, TA0EX0
     	mov.w   #62499, TA0CCR0     ; Set timer count for .5s


Mainloop

		bic.w #BIT0, &P1OUT
		call #redBlink

		jmp Mainloop

;--------------------------------------------------------------------
; Subroutines
;--------------------------------------------------------------------
redBlink
	   ; Dot duration: .5s on
	    bis.w #BIT0, &P1OUT
        call    #redDelay     ;
      	bic.w #BIT0, &P1OUT
        call    #redDelay     ;
		ret


greenBlink
		 ; Dash duration: 1.5s on
		bis.w #BIT7, &P9OUT
		call    #greenDelay     ;
		bic.w #BIT7, &P9OUT
		call    #greenDelay     ;
		ret

redDelay
        ; Delay between blinks: .25s off
		bis.w #TACLR, TA0CTL

greenDelay
        ; Delay between blinks: .33s off
		bis.w #TACLR, TA0CTL

TestFlag
		bit.w #TAIFG, TA0CTL
		jz TestFlag
		bic.w #TAIFG, TA0CTL
		ret

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET


            .end

