;  MSP430FR69x Timer A Demo - Toggle Red LED with a delay controlled by Watchdog Timer
;
;  Description: Red LED is toggled, timing is controlled by the watchdog timer.
;  Using ACLK at 32kHz, the timer triggers an interrupt every 1 second.
;
;           MSP430FR6989
;         ---------------
;     /|\|               |
;      | |               |
;      --|RST            |
;        |               |
;        |           P1.0|-->LED
;
;   D. Tarter
;   Texas Tech University
;   March 2023
;   Built with Code Composer Studio V12.2.0
;******************************************************************************
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

SEGA        .set    BIT0 ; P2.0
SEGB        .set    BIT1 ; P2.1
SEGC        .set    BIT2 ; P2.2
SEGD        .set    BIT3 ; P2.3
SEGE        .set    BIT4 ; P2.4
SEGF        .set    BIT5 ; P2.5
SEGG        .set    BIT6 ; P2.6
SEGDP       .set    BIT7 ; P2.7

DIG1        .set    BIT0 ; P3.0
DIG2        .set    BIT1 ; P3.1
DIG3        .set    BIT2 ; P3.2
DIG4        .set    BIT3 ; P3.3
DIGCOL      .set    BIT7 ; P3.7

BTN1		.set	BIT7 ; P4.7
BTN2		.set	BIT3 ; P1.3
BTN3		.set    BIT5 ; P1.5

digit       .set    R4   ; Set of flags for state machine
display     .set    R5   ; Display digits
tdisplay    .set    R6   ; Temporary Display digits
seconds     .set    R7
minutes     .set    R8
state       .set    R9
pb_sr       .set    R10
index		.set 	R11

_main
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w #WDTPW+WDTCNTCL+WDTTMSEL+7+WDTSSEL__ACLK,&WDTCTL ; Interval mode with ACLK
			bis.w #WDTIE, &SFRIE1                                       ; enable interrupts for the watchdog

SetupSeg    bic.b   #SEGA+SEGB+SEGC+SEGD+SEGE+SEGF+SEGG+SEGDP,&P2OUT
            bic.b   #DIG1+DIG2+DIG3+DIG4+DIGCOL,&P3OUT
            bis.b   #SEGA+SEGB+SEGC+SEGD+SEGE+SEGF+SEGG+SEGDP,&P2DIR
            bis.b   #DIG1+DIG2+DIG3+DIG4+DIGCOL,&P3DIR
            bic.b   #SEGA+SEGB+SEGC+SEGD+SEGE+SEGF+SEGG+SEGDP,&P2OUT
            bic.b   #DIG1+DIG2+DIG3+DIG4+DIGCOL,&P3OUT

SetupPB		bic.b   #BTN1, &P4DIR
			bic.b   #BTN3+BTN2, &P1DIR
			bis.b   #BTN1, &P4REN
			bis.b   #BTN3+BTN2, &P1REN
			bis.b   #BTN1, &P4OUT
			bis.b   #BTN3+BTN2, &P1OUT
			bis.b   #BTN1, &P4IES
			bis.b   #BTN3+BTN2, &P1IES
			bis.b   #BTN1, &P4IE
			bis.b   #BTN3+BTN2, &P1IE

EditClock   mov.b   #CSKEY_H,&CSCTL0_H      ; Unlock CS registers
            mov.w   #DCOFSEL_3,&CSCTL1      ; Set DCO setting for 4MHz
            mov.w   #DIVA__1+DIVS__1+DIVM__1,&CSCTL3 ; MCLK = SMCLK = DCO = 4MHz
            clr.b   &CSCTL0_H               ; Lock CS registers

TimerSetup  mov.w   #CCIE,&TA0CCTL0                            ; TACCR0 interrupt enabled
            mov.w   #62499,&TA0CCR0                             ; Delay by 1 second
            mov.w   #TASSEL__SMCLK+MC__STOP+ID_3,&TA0CTL  ; SMCLK, continuous mode, Div 8
            mov.w   #BIT1,&TA0EX0  ; Div 8

			; Debounce Timer ISR
            mov.w   #CCIE,&TB0CCTL0
            mov.w   #7999,&TB0CCR0
            mov.w   #TASSEL__SMCLK+MC__CONTINUOUS,&TB0CTL


SetupADC12  bis.w   #ADC12SHP+ADC12SSEL_3+ADC12CONSEQ_2,&ADC12CTL1    ; Make ADC in consecutive mode
			bis.w   #ADC12RES_2,&ADC12CTL2  ; 12-bit conversion results
            bis.w   #ADC12INCH_10,&ADC12MCTL0; A10 ADC input select; Vref=AVCC
            bis.w   #ADC12IE0,&ADC12IER0    ; Enable ADC conv complete interrupt
			mov.w   #ADC12SHT0_2+ADC12ON+ADC12MSC+ADC12SC+ADC12ENC, &ADC12CTL0 ; Start conversions

UnlockGPIO  bic.w   #LOCKLPM5,&PM5CTL0      ; Disable the GPIO power-on default
                                            ; high-impedance mode to activate
                                            ; previously configured port settings

			bic.b   #BTN2+BTN3, &P1IFG      ; Reset interrupts here,
			bic.b   #BTN1, &P4IFG           ; unlocking the GPIO tends to trigger an interrupt

			mov.w 	#0, state
			mov.w   #0x0000, display
			mov.w   #1, digit
			mov.w   #0x0000, index

			nop
			bis.b   #GIE, SR                ; enable all interrupts
			nop

Mainloop    jmp     Mainloop                ; Again

;-------------------------------------------------------------------------------
; Look Up Tables
;-------------------------------------------------------------------------------
BCD         .byte   SEGA+SEGB+SEGC+SEGD+SEGE+SEGF      ; 0
            .byte        SEGB+SEGC                     ; 1
            .byte   SEGA+SEGB+     SEGD+SEGE+     SEGG ; 2
            .byte   SEGA+SEGB+SEGC+SEGD+          SEGG ; 3
            .byte        SEGB+SEGC+          SEGF+SEGG ; 4
            .byte   SEGA+     SEGC+SEGD+     SEGF+SEGG ; 5/S
            .byte   SEGA+     SEGC+SEGD+SEGE+SEGF+SEGG ; 6
            .byte   SEGA+SEGB+SEGC                     ; 7
            .byte   SEGA+SEGB+SEGC+SEGD+SEGE+SEGF+SEGG ; 8
            .byte   SEGA+SEGB+SEGC+SEGD+     SEGF+SEGG ; 9
            .byte   							  SEGG ; -
            .byte             SEGC+SEGD+SEGE+SEGF+SEGG ; b
            .byte   SEGA+          SEGD+SEGE+SEGF      ; C
            .byte   SEGA+              +SEGE+SEGF      ; R
            .byte   SEGA+          SEGD+SEGE+SEGF+SEGG ; E
            .byte   0								   ; F

sDIG        .byte   0
			.byte   DIG4
			.byte   DIG3
			.byte   DIG2
			.byte   DIG1

text        .byte   0xC		;C
			.byte   0x5		;S
			.byte   0xA		;-
			.byte   0x3		;3
			.byte   0x3		;3
			.byte   0x5		;5
			.byte   0x0		;0
			.byte   0xD		;r
			.byte   0x1		;1
			.byte   0x1		;1
			.byte   0x6		;6
			.byte   0x0		;0
			.byte   0x7		;7
			.byte   0x2		;2
			.byte   0x2		;2
			.byte   0x6		;6
			.byte   0xF		;NULL
			.byte   0xF		;NULL
			.byte   0xF		;NULL
			.byte   0xC		;C
			.byte   0x5		;S
			.byte   0xA		;-





;-------------------------------------------------------------------------------
TIMER0_B0_ISR;    Timer0_B3 CC0 Interrupt Service Routine
;-------------------------------------------------------------------------------

TB0_END     reti


;-------------------------------------------------------------------------------
WDT_ISR;    WDT Interrupt Service Routine
;-------------------------------------------------------------------------------

			mov.w index, R12
LoadDisp
			mov.b text(R12), display
			rla display
			rla display
			rla display
			rla display
			inc R12
			bis.b text(R12), display
			rla display
			rla display
			rla display
			rla display
			inc R12
			mov.b text(R12), R13
			bis.w R13, display
			rla display
			rla display
			rla display
			rla display
			inc R12
			mov.b text(R12), R13
			bis.w R13, display


Ghosting    bic.b #DIG1+DIG2+DIG3+DIG4+DIGCOL, &P3OUT
			bic.b #SEGA+SEGB+SEGC+SEGD+SEGE+SEGF+SEGG+SEGDP,&P2OUT

            dec   digit
            jnz   UpdateDig
            jmp   WriteCol

UpdateDig   mov.w display, tdisplay
            bis.b   sDIG(digit), &P3OUT
            mov.w   digit, R15

RotateDis   dec     R15
            jz      WriteSeg
            rra     tdisplay
            rra     tdisplay
            rra     tdisplay
            rra     tdisplay
            jmp     RotateDis
WriteSeg    and.w   #0x000F, tdisplay
			bis.b   BCD(tdisplay), &P2OUT
            reti

WriteCol    mov     #5, digit
            bis.b   #DIGCOL, &P3OUT
            bis.b   #0, &P2OUT
            reti
;-------------------------------------------------------------------------------
TIMER0_A0_ISR;    Timer0_A3 CC0 Interrupt Service Routine
;-------------------------------------------------------------------------------
            add.w   #32249,&TA0CCR0         ; Add offset to TA0CCR0
			inc		index
			cmp.w	#19, index
			jne		ti_end
			mov.w	#0x0000, index
ti_end      reti
;-------------------------------------------------------------------------------
PORT1_ISR;    Timer0_A3 CC0 Interrupt Service Routine
;-------------------------------------------------------------------------------
			mov.w   #TASSEL__SMCLK+MC__STOP+BIT6+BIT7,&TA0CTL  ; SMCLK, continuous mode, Div 8
			mov.w	#0, state
			bit.b	#BTN3, &P1IFG
			jz		endp1isr
			mov.w	#1, state

endp1isr    bic.b   #BTN3+BTN2,&P1IFG

            reti
;-------------------------------------------------------------------------------
PORT4_ISR;    Timer0_A3 CC0 Interrupt Service Routine
;-------------------------------------------------------------------------------
			mov.w   #TASSEL__SMCLK+MC__CONTINOUS+BIT6+BIT7,&TA0CTL  ; SMCLK, continuous mode, Div 8
			bit.b   #BTN1, &P4IN
			jnz		p4_end
			mov.w	#0, state

p4_end      bic.b   #BTN1, &P4IFG
			reti

;-------------------------------------------------------------------------------
ADC12_ISR;  ADC12 interrupt service routine
;-------------------------------------------------------------------------------
            add.w   &ADC12IV,PC             ; add offset to PC
            reti                            ; Vector  0:  No interrupt
            reti                            ; Vector  2:  ADC12MEMx Overflow
            reti                            ; Vector  4:  Conversion time overflow
            reti                            ; Vector  6:  ADC12HI
            reti                            ; Vector  8:  ADC12LO
            reti                            ; Vector 10:  ADC12IN
            jmp     MEM0                    ; Vector 12:  ADC12MEM0 Interrupt
            reti                            ; Vector 14:  ADC12MEM1
            reti                            ; Vector 16:  ADC12MEM2
            reti                            ; Vector 18:  ADC12MEM3
            reti                            ; Vector 20:  ADC12MEM4
            reti                            ; Vector 22:  ADC12MEM5
            reti                            ; Vector 24:  ADC12MEM6
            reti                            ; Vector 26:  ADC12MEM7
            reti                            ; Vector 28:  ADC12MEM8
            reti                            ; Vector 30:  ADC12MEM9
            reti                            ; Vector 32:  ADC12MEM10
            reti                            ; Vector 34:  ADC12MEM11
            reti                            ; Vector 36:  ADC12MEM12
            reti                            ; Vector 38:  ADC12MEM13
            reti                            ; Vector 40:  ADC12MEM14
            reti                            ; Vector 42:  ADC12MEM15
            reti                            ; Vector 44:  ADC12MEM16
            reti                            ; Vector 46:  ADC12MEM17
            reti                            ; Vector 48:  ADC12MEM18
            reti                            ; Vector 50:  ADC12MEM19
            reti                            ; Vector 52:  ADC12MEM20
            reti                            ; Vector 54:  ADC12MEM21
            reti                            ; Vector 56:  ADC12MEM22
            reti                            ; Vector 58:  ADC12MEM23
            reti                            ; Vector 60:  ADC12MEM24
            reti                            ; Vector 62:  ADC12MEM25
            reti                            ; Vector 64:  ADC12MEM26
            reti                            ; Vector 66:  ADC12MEM27
            reti                            ; Vector 68:  ADC12MEM28
            reti                            ; Vector 70:  ADC12MEM29
            reti                            ; Vector 72:  ADC12MEM30
            reti                            ; Vector 74:  ADC12MEM31
            reti                            ; Vector 76:  ADC12RDY
MEM0      	mov.w   &ADC12MEM0, R15    ; if you dont move this it will never clear the interrupt!
			rra  R15
			rra  R15
			rra  R15
			rra  R15
			rra  R15
			rra  R15
			rra  R15
			rra  R15
			cmp.b #1, state
			jne ADC_end
			mov.w   R15, index

ADC_end		reti

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect   TIMER0_B0_VECTOR        ; Timer0_A3 CC0 Interrupt Vector
            .short  TIMER0_B0_ISR
            .sect   WDT_VECTOR              ; Watchdog Timer
            .short  WDT_ISR
            .sect   TIMER0_A0_VECTOR        ; Timer0_A3 CC0 Interrupt Vector
            .short  TIMER0_A0_ISR
            .sect   ADC12_VECTOR            ; ADC12 Vector
            .short  ADC12_ISR               ;
            .sect   PORT1_VECTOR        ; BTN3 Interrupt Vector
            .short  PORT1_ISR
            .sect   PORT4_VECTOR        ; BTN1 Interrupt Vector
            .short  PORT4_ISR
            .end
