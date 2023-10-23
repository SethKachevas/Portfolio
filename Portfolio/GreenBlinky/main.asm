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



UnlockGPIO	bic.w #LOCKLPM5, &PM5CTL0 ;Disable the GPIO power-on default



Mainloop
		bis.w   #TASSEL_2+MC_1+ID_3+TAIE, TA0CTL    ; Start timer
       	bis.w   #TAIDEX_0, TA0EX0
     	mov.w   #62499, TA0CCR0     ; Set timer count for .5s

		bic.w #BIT0, &P1OUT
		; 'S' in Morse Code
        call    #dot
        call    #dot
        call    #dot

        ; Delay between letters
        call    #delay

        ; 'O' in Morse Code
        call    #dash
        call    #dash
        call    #dash

        ; Delay between letters
        call    #delay

        ; 'S' in Morse Code
        call    #dot
        call    #dot
        call    #dot

;--------------------------------------------------------------------
; Subroutines
;--------------------------------------------------------------------
dot
	   ; Dot duration: .5s on
	    bis.w #BIT0, &P1OUT
        call    #delay     ;
      	bic.w #BIT0, &P1OUT
        call    #delay     ;
		ret


dash
		 ; Dash duration: 1.5s on
		bis.w #BIT0, &P1OUT
		call    #delay     ;
		call    #delay     ;
		call    #delay     ;
		bic.w #BIT0, &P1OUT
		call    #delay     ;
		ret

delay
        ; Delay between letters: .5s off
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

