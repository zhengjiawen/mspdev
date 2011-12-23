//******************************************************************************
//  MSP430F21x2 Demo - Timer0_A3, PWM TA0_1-TA0_2, Up Mode, DCO SMCLK
//
//  Description: This program generates two PWM outputs on P1.2,3 using
//  Timer0_A3 configured for up mode. The value in TA0CCR0, 512-1, defines the PWM
//  period and the values in TA0CCR1 and TA0CCR2 the PWM duty cycles.
//  Using ~1.2MHz SMCLK as TACLK, the timer period is ~425us with
//  a 75% duty cycle on P1.2 and 25% on P1.3.
//  ACLK = n/a, SMCLK = MCLK = TA0CLK = default DCO ~1.2MHz
//
//               MSP430F21x2
//            -----------------
//        /|\|              XIN|-
//         | |                 |
//         --|RST          XOUT|-
//           |                 |
//           |       P1.2/TA0_1|--> TA0CCR1 - 75% PWM
//           |       P1.3/TA0_2|--> TA0CCR2 - 25% PWM
//
//  A. Dannenberg
//  Texas Instruments Inc.
//  January 2008
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.41A
//******************************************************************************
#include "msp430x21x2.h"

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x0C;                            // P1.2 and P1.3 output
  P1SEL |= 0x0C;                            // P1.2 and P1.3 TA1/2 otions
  TA0CCR0 = 512 - 1;                         // PWM Period
  TA0CCTL1 = OUTMOD_7;                       // TA0CCR1 reset/set
  TA0CCR1 = 384;                             // TA0CCR1 PWM duty cycle
  TA0CCTL2 = OUTMOD_7;                       // TA0CCR2 reset/set
  TA0CCR2 = 128;                             // TA0CCR2 PWM duty cycle
  TA0CTL = TASSEL_2 + MC_1;                  // SMCLK, up mode

  __bis_SR_register(CPUOFF);                // Enter LPM0
}

