;*******************************************************************************
;  MSP430F(G)47x Demo - DAC12_0, Output 0.6V on DAC0
;
;  Description: Using DAC12_0 and 1.2V ADC12REF reference with a gain of 1,
;  output 0.6V on DAC0. Output accuracy is specified by that of the SD16REF.
;  ACLK = n/a, MCLK = SMCLK = default DCO
;
;               MSP430F(G)47x
;            -----------------
;        /|\|              XIN|-
;         | |                 |
;         --|RST          XOUT|-
;           |                 |
;           |        P1.6/DAC0|--> 0.6V
;           |                 |
;
;   P.Thanigai
;   Texas Instruments Inc.
;   September 2008
;   Built with Code Composer Essentials Version: 3.0
;******************************************************************************
 .cdecls C,LIST, "msp430xG47x.h" 

;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupSD16  mov.w   #SD16REFON,&SD16CTL     ; Internal 1.2V ref on
SetupDAC120 mov.w   #DAC12IR + DAC12AMP_5 + DAC12ENC + DAC12SREF_3 + DAC12CALON + DAC12OPS,&DAC12_0CTL
            mov.w   #07FFh,&DAC12_0DAT      ; 0.6V
Mainloop    bis.w   #CPUOFF,SR              ; Enter LPM0
            nop                             ; Required only for debugger
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;  
            .end
