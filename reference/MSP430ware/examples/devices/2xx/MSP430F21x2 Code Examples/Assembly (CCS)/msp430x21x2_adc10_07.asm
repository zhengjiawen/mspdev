;*******************************************************************************
;   MSP430F21x2 Demo - ADC10, DTC Sample A0 64x, AVcc, Repeat Single, DCO
;
;   Description: Use DTC to sample A0 64 times with reference to AVcc. Software
;   writes to ADC10SC to trigger sample burst. In Mainloop MSP430 waits in LPM0
;   to save power until ADC10 conversion burst complete, ADC10_ISR(DTC) will
;   force exit from LPM0 in Mainloop on reti. ADC10 internal oscillator
;   times sample period (16x) and conversion (13x). DTC transfers conversion
;   code to RAM 200h - 280h. P1.0 set at start of conversion burst, reset on
;   completion.
;
;                MSP430F21x2
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;        >---|P2.0/A0      P1.0|-->LED
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x21x2.h"
;-------------------------------------------------------------------------------
 			.text							;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #025Fh,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupADC10  mov.w   #CONSEQ_2,&ADC10CTL1    ; Repeat single channel
            mov.w   #ADC10SHT_2+MSC+ADC10ON+ADC10IE,&ADC10CTL0 ;
            bis.b   #01h,&ADC10AE0          ; P2.0 ADC option select
            mov.b   #040h,&ADC10DTC1        ; 64 conversions
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 output
                                            ;
Mainloop    bic.w   #ENC,&ADC10CTL0         ;
busy_test   bit     #BUSY,&ADC10CTL1        ; ADC10 core inactive?
            jnz     busy_test               ;
            mov.w   #0200h,&ADC10SA         ; Data buffer start
            bis.b   #001h,&P1OUT            ; P1.0 = 1
            bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Sampling and conversion start
            bis.w   #CPUOFF+GIE,SR          ; LPM0, ADC10_ISR will force exit
            bic.b   #001h,&P1OUT            ; P1.0 = 0
            jmp     Mainloop                ; Again

;-------------------------------------------------------------------------------
ADC10_ISR;  Exit LPM0 on reti
;-------------------------------------------------------------------------------
            bic.w   #CPUOFF,0(SP)           ; Exit LPM0 on reti
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int05"            	; ADC10 Vector
            .short  ADC10_ISR
            .sect	".reset"	            ; POR, ext. Reset
            .short   RESET
            .end
