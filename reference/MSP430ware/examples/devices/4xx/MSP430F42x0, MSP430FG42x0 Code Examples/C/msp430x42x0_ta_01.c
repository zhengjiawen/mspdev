//******************************************************************************
//   MSP430x42x0 Demo - Timer_A, Toggle P1.0, CCR0 Cont. Mode ISR, DCO SMCLK
//
//   Description: Toggle P1.0 using software and TA_0 ISR. Toggles every
//   50000 SMCLK cycles. SMCLK provides clock source for TACLK.
//   During the TA_0 ISR P1.0 is toggled and 50000 clock cycles are added to
//   CCR0. TA_0 ISR is triggered every 50000 cycles. CPU is normally off and
//   used only during TA_ISR.
//   ACLK = n/a, MCLK = SMCLK = TACLK = default DCO
//
//                MSP430F4270
//             -----------------
//         /|\|              XIN|-
//          | |                 |
//          --|RST          XOUT|-
//            |                 |
//            |             P1.0|-->LED
//
//  L. Westlund / S. Karthikeyan
//  Texas Instruments Inc.
//  June 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.30A
//******************************************************************************
#include  <msp430x42x0.h>

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x01;                            // P1.0 output
  CCTL0 = CCIE;                             // CCR0 interrupt enabled
  CCR0 = 50000;
  TACTL = TASSEL_2 + MC_2;                  // SMCLK, continuous mode
  _BIS_SR(LPM0_bits + GIE);                 // Enter LPM0 w/ interrupt
}

// Timer A0 interrupt service routine
#pragma vector=TIMERA0_VECTOR
__interrupt void Timer_A (void)
{
  P1OUT ^= 0x01;                            // Toggle P1.0
  CCR0 += 50000;                            // Add offset to CCR0
}

