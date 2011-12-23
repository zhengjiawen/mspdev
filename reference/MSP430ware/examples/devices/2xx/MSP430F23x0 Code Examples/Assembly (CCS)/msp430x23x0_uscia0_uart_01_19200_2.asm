;*******************************************************************************
;   MSP430F23x0 Demo - USCI_A0, UART 19200 Echo ISR, HF XTAL SMCLK
;
;   Description: This program will echo a received character, RX interrupt
;   service used. XT1 oscillator used in this example.
;   ACLK = MCLK = SMCLK = BRCLK = LFXT1CLK = 8MHz
;   Baud rate divider with 8MHz XTAL @19200 = 8MHz/19200 = ~416.6
;   //* An external 8MHz XTAL on XIN XOUT is required for LFXT1CLK *//
;
;                MSP430F23x0
;             -----------------
;         /|\|              XIN|-
;          | |                 | 8MHz
;          --|RST          XOUT|-
;            |                 |
;            |     P3.4/UCA0TXD|------------>
;            |                 | 19200 - 8N1
;            |     P3.5/UCA0RXD|<------------
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x23x0.h"
;-------------------------------------------------------------------------------
			.text							; Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #450h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupBC     bis.b   #XTS,&BCSCTL1           ; LFXT1 = HF XTAL
            bis.b   #LFXT1S1,&BCSCTL3       ; 3  16MHz crystal or resonator
SetupOsc    bic.b   #OFIFG,&IFG1            ; Clear OSC fault flag
            mov.w   #0FFh,R15               ; R15 = Delay
SetupOsc1   dec.w   R15                     ; Additional delay to ensure start
            jnz     SetupOsc1               ;
            bit.b   #OFIFG,&IFG1            ; OSC fault flag set?
            jnz     SetupOsc                ; OSC Fault, clear flag again
            bis.b   #SELM_3+SELS,&BCSCTL2   ; MCLK = SMCLK = LFXT1 (safe)
SetupP3     bis.b   #030h,&P3SEL            ; P3.4,5 = USCI_A0 TXD/RXD
                                            ;
SetupUSCI0  bis.b   #UCSSEL_2,&UCA0CTL1     ; SMCLK
            mov.b   #160,&UCA0BR0           ; 8MHz/19200 = ~416.6
            mov.b   #1,&UCA0BR1             ;
            mov.b   #UCBRS2+UCBRS1,&UCA0MCTL; Modulation UCBRSx = 6
            bic.b   #UCSWRST,&UCA0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCA0RXIE,&IE2          ; Enable USCI_A0 RX interrupt
                                            ;
Mainloop    bis.b   #CPUOFF+GIE,SR          ; Enter LPM0, interrupts enabled
            nop                             ; Needed only for debugger
                                            ;
;-------------------------------------------------------------------------------
USCI0RX_ISR;  Echo back RXed character, confirm TX buffer is ready first
;-------------------------------------------------------------------------------
TX1         bit.b   #UCA0TXIFG,&IFG2        ; USCI_A0 TX buffer ready?
            jz      TX1                     ; Jump is TX buffer not ready
            mov.b   &UCA0RXBUF,&UCA0TXBUF   ; TX -> RXed character
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int07"        ; USCI A0/B0 Receive
            .short	USCI0RX_ISR
            .sect	".reset"            ; POR, ext. Reset
            .short	RESET
            .end