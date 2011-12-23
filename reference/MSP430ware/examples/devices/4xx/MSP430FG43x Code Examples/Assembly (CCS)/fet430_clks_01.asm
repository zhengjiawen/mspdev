;******************************************************************************
;   MSP-FET430P430 Demo - FLL+, Output MCLK, SMCLK, ACLK Using 32kHz XTAL
;
;   Description: Output the system MCLK and ACLK.
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO = 32 x ACLK = 1048576Hz
;   ;* An external watch crystal between XIN & XOUT is required for ACLK *//	
;
;                MSP430FG439
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |                 |
;            |        P1.1/MCLK|-->MCLK  = 1048576 Hz
;            |       P1.4/SMCLK|-->SMCLK = 1048576 Hz
;            |        P1.5/ACLK|-->ACLK  = 32kHz
;
;   M. Buccini / M. Mitchell
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430xG43x.h"
;------------------------------------------------------------------------------
            .text                  ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps
SetupP1     bis.b   #032h,&P1DIR            ; P1.1,4,5 output direction
            bis.b   #032h,&P1SEL            ; P1.1,4,5 option select
                                            ;			
Mainloop    jmp     Mainloop                ;
                                            ;
;-----------------------------------------------------------------------------
;           Interrupt Vectors
;-----------------------------------------------------------------------------
            .sect   ".reset"                ; RESET Vector
            .short  RESET                   ;
            .end
