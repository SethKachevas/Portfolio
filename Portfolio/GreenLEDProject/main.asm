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
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

        MOV #0x1234, R12    ; Move R1234 into R12
        MOV #0x5678, R13    ; Move R5678 into R13

        MOV.B #0x01, &P1DIR ; Set P1.0 as output
        MOV.B #0x01, &P1OUT ; Set P1.0 high

        MOV #5, R15         ; Set loop counter to 5

loop:   XOR.B #0x01, &P1OUT ; Toggle P1.0
        CALL #delay         ; Call the delay subroutine
        DEC R15             ; Decrement loop counter
        JNZ loop            ; Jump to loop label if not zero

        MOV.B #0x01, &P1OUT ; Turn on the LED

end:    JMP end             ; Infinite loop

delay:  MOV #50000, R14    ; Set delay counter

delay_loop:
        DEC R14             ; Decrement delay counter
        JNZ delay_loop      ; Jump to delay_loop label if not zero
        RET                 ; Return from subroutine
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
