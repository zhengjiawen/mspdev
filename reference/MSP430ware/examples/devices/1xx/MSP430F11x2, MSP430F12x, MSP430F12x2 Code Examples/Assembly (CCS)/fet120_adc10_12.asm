;******************************************************************************
;   MSP-FET430P120 Demo - ADC10, Sample A7, 1.5V, TA1 Trig, Ultra-Low Pwr
;
;   Description: A7 is sampled 1024/second (32xACLK) with reference to 1.5V.
;   All activity is interrupt driven with proper usage of MSP430 low-power
;   modes, ADC10 and Vref demonstrated. Timer_A with both TA1/TA0 used in
;   upmode to drive ADC10 conversion (continuous mode can also be used).
;   Inside of TA0_ISR software will enable ADC10 and internal reference and
;   allow > 30us delay for Vref to stabilize prior to sample start. Sample
;   start is automatically triggered by TA1 every 32 ACLK cycles. ADC10_ISR
;   will disable ADC10 and Vref and compare ADC10 conversion code. Internal
;   oscillator times sample (16x) and conversion (13x). If A7 > 0.2Vcc,
;   P1.0 is set, else reset. Normal Mode is LPM3.
;   //* An external watch crystal on XIN XOUT is required for ACLK *//	
;   //* MSP430F1232 or MSP430F1132 Device Required *//
;
;                     +-----(0.9766us)---------\\------------------>+
;     TA0_ISR        TA1      ADC10_ISR             TA0_ISR        TA1
;   -----+------------+------------+-----------\\------+------------+----->
;    Enable ADC    Trigger ADC  Disable ADC
;    and Vref                   Compare
;        +-( >30us--->+
;
;
;                MSP430F1232
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;        >---|A7          P1.0 |--> LED
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
RESET       mov.w   #0300h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupADC10  mov.w   #INCH_7+SHS_1,&ADC10CTL1; P3.7, TA1 trigger sample start
            bis.b   #080h,&ADC10AE          ; P3.7 ADC10 option select
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 output
SetupC0     mov.w   #CCIE,&CCTL0            ; Enable interrupt
            mov.w   #32-1,&CCR0             ; PWM Period
SetupC1     mov.w   #OUTMOD_3,&CCTL1        ; CCR1 set/reset
            mov.w   #2,&CCR1                ; CCR1 PWM Duty Cycle	
SetupTA     mov.w   #TASSEL_1+MC_1,TACTL    ; ACLK, up mode
                                            ;
Mainloop    bis.w   #LPM3+GIE,SR            ; Enter LPM3
            nop                             ; Required only for debugger
                                            ;
;------------------------------------------------------------------------------
ADC10_ISR;
;------------------------------------------------------------------------------
            bic.w   #ENC,&ADC10CTL0         ; ADC10 disabled
            clr.w   &ADC10CTL0              ; ADC10, Vref disabled completely
            bic.b   #01h,&P1OUT             ; P1.0 = 0
            cmp.w   #088h,&ADC10MEM         ; ADC10MEM = A0 > 0.2V?
            jlo     ADC10_Exit              ; Again
            bis.b   #01h,&P1OUT             ; P1.0 = 1
ADC10_Exit  reti                            ;		
                                            ;
;------------------------------------------------------------------------------
TA0_ISR;    ISR for CCR0
;------------------------------------------------------------------------------
            mov.w   #SREF_1+ADC10SHT_2+REFON+ADC10ON+ADC10IE,&ADC10CTL0;
            bis.w   #ENC,&ADC10CTL0         ; ADC10 enable .set
            reti                            ;		
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int05"                ; ADC10 Vector
            .short  ADC10_ISR               ;
            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;
            .end
