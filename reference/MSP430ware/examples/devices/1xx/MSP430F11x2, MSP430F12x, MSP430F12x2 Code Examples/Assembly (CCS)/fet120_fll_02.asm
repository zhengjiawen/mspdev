;******************************************************************************
;   MSP-FET430P120 Demo - Basic Clock, Implement Cont. SW FLL with Auto RSEL
;
;   Description: .set DCO clock to (Delta)*(4096) using software FLL. DCO clock
;   is output on P1.4 as SMCLK.  DCO clock, which is the selected SMCLK source
;   for timer_A is integrated over ACLK/8 (4096) continuously. CCR2 captures
;   ACLK/8.  To use this SW FLL, Timer_A must be operating in continous mode
;   with a watch crystal used for ACLK. Delta must be kept in a  range that
;   allows possible DCO speeds.  Minimum Delta must ensure
;   the AdjDCO ISR can complete. Maximum delta  can be calculated by
;   f(DCOx7) / 4096.  f(DCOx7) found in device specific datasheet. To measure
;   SMCLK on P1.4 with the FET, use "Release JTAG on run"
;   in the debugger to have access to the port. Then run the code.
;   ACLK = LFXT1/8 = 32768/8, MCLK = SMCLK = DCO = 4096xDelta
;   //* An external watch crystal on XIN XOUT is required for ACLK *//	
;
;Delta   .equ  977    ; target DCO = Delta*(4096) = 4000000
;Delta   .equ  900    ; target DCO = Delta*(4096) = 3686400
;Delta   .equ  600    ; target DCO = Delta*(4096) = 2457600
;Delta   .equ  256    ; target DCO = Delta*(4096) = 1048576
Delta       .equ    250                 ; target DCO = Delta*(4096) = 1024000
;Delta   .equ  244    ; target DCO = Delta*(4096) = 1000000
;Delta   .equ  78     ; target DCO = Delta*(4096) =  319488
;Delta   .equ    70   ; target DCO = Delta*(4096) =  286720
;
;                MSP430F123(2)
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32k
;          --|RST          XOUT|-
;            |                 |
;            |             P1.4|-->SMCLK
;
;   M. Buccini / M. Raju
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x12x2.h"
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #300h,SP                ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     bis.b   #010h,&P1DIR            ; P1.4 output
            bis.b   #010h,&P1SEL            ; P1.4 SMCLK output
SetupBC     bis.b   #DIVA_3,&BCSCTL1        ; ACLK = LFXT1CLK/8
Setup_CC2   mov.w   #CM_1+CCIS_1+CAP+CCIE,&CCTL2 ; CAP,ACLK, with interrupt
Setup_TA    mov.w   #TASSEL_2+MC_2,&TACTL   ; SMCLK, Continous Mode
                                            ;							
Mainloop    bis.w   #CPUOFF+GIE,SR          ; CPU off, interrupts enabled
            nop                             ; Needed only for debugger
                                            ;
;-----------------------------------------------------------------------------
TA2_ISR
;-----------------------------------------------------------------------------
AdjDCO      push.w  &CCR2                   ;
            sub.w   R15,&CCR2               ;
            cmp.w   #Delta,&CCR2            ; Delta = SMCLK/(32768/8)
            pop.w   R15                     ;
            jlo     IncDCO                  ;
            jeq     DoneDCO                 ;
DecDCO      dec.b   &DCOCTL                 ; Slow DCO with DCO and MOD
            jc      DoneDCO                 ; Slower?
            cmp.b   #XT2OFF+DIVA_3,&BCSCTL1 ; Can RSEL.x be decremented?
            jz      DoneDCO                 ; jump>DCO at slowest setting
            dec.b   &BCSCTL1                ; Decrement RSEL.x
            reti                            ; Return from interrrupt
IncDCO      inc.b   &DCOCTL                 ; Speed DCO with DCO and MOD
            jnc     DoneDCO                 ; Faster?
            cmp.b   #XT2OFF+DIVA_3+07h,&BCSCTL1 ; Can RSEL.x be increased?
            jz      DoneDCO                 ; jump> DCO at fastest settting
            inc.b   &BCSCTL1                ; Increment RSEL.x
DoneDCO     reti                            ; Return from interrrupt
                                            ;
;------------------------------------------------------------------------------
TAX_ISR;    Common ISR for CCR1-4 and overflow
;------------------------------------------------------------------------------
            add.w   &TAIV,PC                ; Add Timer_A offset vector
            reti                            ; CCR0 - no source
            reti                            ; CCR1
            jmp     TA2_ISR                 ; CCR2
;            reti                            ; CCR3
;            reti                            ; CCR4
;            reti                            ; Return from overflow ISR		
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int08"                ; Timer_AX Vector
            .short  TAX_ISR                 ;
            .end