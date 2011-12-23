//******************************************************************************
//  MSP-FET430P120 Demo - Basic Clock, LPM3 Using WDT ISR, 32kHz ACLK
//
//  Description: This program operates MSP430 normally in LPM3, pulsing P1.0
//  at 4 second intervals. WDT ISR used to wake-up system. All I/O configured
//  as low outputs to eliminate floating inputs. Current consumption does
//  increase when LED is powered on P1.0. Demo for measuring LPM3 current.
//  ACLK = LFXT1/4 = 32768/4, MCLK = SMCLK = default DCO
//  //* External watch crystal on XIN XOUT is required for ACLK *//	
//
//           MSP430F123(2)
//         ---------------
//     /|\|            XIN|-
//      | |               | 32kHz
//      --|RST        XOUT|-
//        |               |
//        |           P1.0|-->LED
//
//  M. Buccini
//  Texas Instruments Inc.
//  Feb 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.21A
//******************************************************************************

#include  <msp430x12x2.h>

void main(void)
{
  BCSCTL1 |= DIVA_2;                        // ACLK/4
  WDTCTL = WDT_ADLY_1000;                   // WDT 1s/4 interval timer
  IE1 |= WDTIE;                             // Enable WDT interrupt
  P1DIR = 0xFF;                             // All P1.x outputs
  P1OUT = 0;                                // All P1.x reset
  P2DIR = 0xFF;                             // All P2.x outputs
  P2OUT = 0;                                // All P2.x reset
  P3DIR = 0xFF;                             // All P3.x outputs
  P3OUT = 0;                                // All P3.x reset

  while(1)
  {
    int i;
    _BIS_SR(LPM3_bits + GIE);               // Enter LPM3, enable interrupts
    P1OUT |= 0x01;                          // Set P1.0 LED on
    for (i = 5000; i>0; i--);               // Delay
    P1OUT &= ~0x01;                         // Clear P1.0 LED off
  }
}

#pragma vector=WDT_VECTOR
__interrupt void watchdog_timer (void)
{
    _BIC_SR_IRQ(LPM3_bits);                 // Clear LPM3 bits from 0(SR)
}
