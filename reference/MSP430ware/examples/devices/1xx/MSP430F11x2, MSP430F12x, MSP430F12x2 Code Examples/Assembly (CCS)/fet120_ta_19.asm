;******************************************************************************
;   MSP-FET430P120 Demo - Timer_A, PWM TA1-2, Up/Down Mode, DCO SMCLK
;
;   Description: This program generates two PWM outputs on P1.2,3 using
;   Timer_A configured for up/down mode. The value in CCR0, 128, defines the
;   PWM period/2 and the values in CCR1 and CCR2 the PWM duty cycles. Using
;   ~800kHz SMCLK as TACLK, the timer period is ~320us with a 75% duty cycle
;   on P1.2 and 25% on P1.3.
;   SMCLK = MCLK = TACLK = default DCO ~800kHz
;
;                MSP430F123(2)
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |         P1.2/TA1|--> CCR1 - 75% PWM
;            |         P1.3/TA2|--> CCR2 - 25% PWM
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
SetupP1     bis.b   #00Ch,&P1DIR            ; P1.2 and P1.3 output
            bis.b   #00Ch,&P1SEL            ; P1.2 and P1.3 TA1/2 otions
SetupC0     mov.w   #128,&CCR0              ; PWM Period/2
SetupC1     mov.w   #OUTMOD_6,&CCTL1        ; CCR1 toggle/set
            mov.w   #32,&CCR1               ; CCR1 PWM Duty Cycle	
SetupC2     mov.w   #OUTMOD_6,&CCTL2        ; CCR2 toggle/set
            mov.w   #96,&CCR2               ; CCR2 PWM duty cycle	
SetupTA     mov.w   #TASSEL_2+MC_3,&TACTL   ; SMCLK, updown mode
                                            ;					
Mainloop    bis.w   #CPUOFF,SR              ; CPU off
            nop                             ; Required only for debugger
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .end