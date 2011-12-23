;******************************************************************************
;   MSP430x42x0 Demo - SD16_A, Single Conversion on Single Channel Polling IFG
;
;   Description: This program uses the SD16_A module to perform a single
;   conversion on a single channel. The SD16_A interrupt flag for CH0 is polled
;   to determine when a conversion has completed. Test by applying a voltage
;   to CH0 (A0+, A0-) and setting a breakpoint at the line indicated
;   below. Run program until it reaches the breakpoint, then use the
;   debugger's register window to view the conversion results. The conversion
;   result for CH0 is stored in R12.
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO = 32 x ACLK = 1048576Hz
;   //* An external watch crystal between XIN & XOUT is required for ACLK *//	
;   //* Minimum Vcc is required for SD16_A module - see datasheet        *//
;   //* 100nF cap btw Vref and AVss is recommended when using 1.2V ref *//
;
;                 MSP430F4270
;              -----------------
;          /|\|              XIN|-
;           | |                 | 32kHz
;           --|RST          XOUT|-
;             |                 |
;     Vin+ -->|A0+              |
;     Vin- -->|A0-              |
;             |                 |
;             |            VREF |---+
;             |                 |   |
;             |                 |  -+- 100nF
;             |                 |  -+-
;             |                 |   |
;             |            AVss |---+
;             |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x42x0.h"

;-----------CPU Registers Used-------------------------------------------------
RESULTS		.equ R12
                                            ; R12 - Store conversion result
                                            ; from SD16MEM2
;           R15 - Temporary working register
;------------------------------------------------------------------------------
            .text                 ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #300h,SP                ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps
            mov.w   #10000,R15              ;
Xtal_Wait   dec.w   R15                     ; Delay for 32 kHz crystal to
            jnz     Xtal_Wait		    ; stabilize
SetupSD16   mov.w   #SD16REFON+SD16SSEL0,&SD16CTL ; 1.2V ref, SMCLK
            bis.w   #SD16SNGL,&SD16CCTL0    ; Single conversion
            mov.w   #03600h,R15             ; Delay needed for 1.2V ref startup
L$1         dec.w   R15                     ;
            jnz     L$1                     ;
Mainloop    bis.w   #SD16SC,&SD16CCTL0      ; Start conversion
testIFG     bit.w   #SD16IFG,&SD16CCTL0     ; Is conversion done?
            jz      testIFG                 ; No, test again
            mov.w   &SD16MEM0,RESULTS       ; Yes, save conversion result
                                            ; (automatically clears SD16IFG)
            jmp     Mainloop                ; SET BREAKPOINT HERE
                                            ;

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect	".reset"                  ; RESET Vector
            .short  RESET 
            .end

