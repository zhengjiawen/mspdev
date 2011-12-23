//******************************************************************************
//   MSP430x21x2 Demo - Comparator A, Poll input CA0, CA exchange, result in P1.0
//
//   Description: The Voltage at pin CA0 (Vcompare) is compared with reference
//   voltage of 0.5*Vcc. LED is toggled when Vcompare crosses the ref voltage.
//
//
//                 MSP430x21x2
//             -----------------
//         /|\|                 |
//          | |                 |
//          --|RST           CA0|<--Vcompare
//            |                 |
//         <--|CAOUT/P2.6       |
//            |             P1.0|-->LED
//
//  P. Thanigai / K.Venkat
//  Texas Instruments Inc.
//  November 2007
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.42A
//******************************************************************************
#include  <msp430x21x2.h>

void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT

  CACTL1 = CAEX+CAON+CAREF_2+CARSEL;        // Enable comp,
  CACTL2 = P2CA0;                           // Pin to CA0
  P1DIR |= BIT0;                            // P5.1 = output direction
  P2SEL |= BIT6;                            // P2.6 = CAOUT

  while(1)
    if (CAOUT&CACTL2)
      P1OUT |= BIT0;                       // Set LED if result =1
    else
      P1OUT &= ~BIT0;                      // Clear LED if result =0
}
