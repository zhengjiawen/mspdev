;*******************************************************************************
;   MSP430x24x Demo - USCI_A0, Ultra-Low Pwr UART 9600 String, 32kHz ACLK
;
;   Description: This program demonstrates a full-duplex 9600-baud UART using
;   USCI_A0 and a 32kHz crystal.  The program will wait in LPM3, and will
;   respond to a received 'u' character using 8N1 protocol. The response will
;   be the string 'Hello World'.
;   ACLK = BRCLK = LFXT1 = 32768, MCLK = SMCLK = DCO ~1.045MHz
;   Baud rate divider with 32768Hz XTAL @9600 = 32768Hz/9600 = 3.41
;   //* An external watch crystal is required on XIN XOUT for ACLK *//
;
;                MSP430F249
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |     P3.4/UCA0TXD|------------>
;            |                 | 9600 - 8N1
;            |     P3.5/UCA0RXD|<------------
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x24x.h"
;-------------------------------------------------------------------------------
;   CPU registers used
Pointer 	.equ	R4
;-------------------------------------------------------------------------------
LF          .equ    0ah                     ; ASCII Line Feed
CR          .equ    0dh                     ; ASCII Carriage Return
;-------------------------------------------------------------------------------
			.text							;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0500h,SP         		; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     mov.b   #0FFh,&P1DIR            ; All P1.x outputs
            clr.b   &P1OUT                  ; All P1.x reset
SetupP2     mov.b   #0FFh,&P2DIR            ; All P2.x outputs
            clr.b   &P2OUT                  ; All P2.x reset
SetupP3     bis.b   #030h,&P3SEL            ; P3.4,5 = USCI_A0 TXD/RXD
            mov.b   #0FFh,&P3DIR            ; All P3.x outputs
            clr.b   &P3OUT                  ; All P3.x reset
SetupP4     mov.b   #0FFh,&P4DIR            ; All P4.x outputs
            clr.b   &P4OUT                  ; All P4.x reset
SetupUSCI0  bis.b   #UCSSEL_1,&UCA0CTL1     ; CLK = ACLK
            mov.b   #03h,&UCA0BR0           ; 32kHz/9600 = 3.41
            mov.b   #00h,&UCA0BR1           ;
            mov.b   #UCBRS1+UCBRS0,&UCA0MCTL; Modulation UCBRSx = 3
            bic.b   #UCSWRST,&UCA0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCA0RXIE,&IE2          ; Enable USCI_A0 RX interrupt
                                            ;
Mainloop    bis.w   #LPM3+GIE,SR            ; Enter LPM3 w/ int until Byte RXed
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
USCI0TX_ISR;
;-------------------------------------------------------------------------------
            cmp.w   #String1+13,Pointer     ;
            jeq     Done                    ;
            mov.b   @Pointer+,&UCA0TXBUF    ;
            reti                            ;
Done        bic.b   #UCA0TXIE,&IE2          ; Disable USCI_A0 TX interrupt
            reti                            ;
;-------------------------------------------------------------------------------
USCI0RX_ISR;
;-------------------------------------------------------------------------------
            cmp.b   #'u',&UCA0RXBUF         ;
            jne     UART_Done               ;
            bis.b   #UCA0TXIE,&IE2          ; Enable USCI_A0 TX interrupt
            mov.w   #String1,Pointer        ;
            mov.b   @Pointer+,&UCA0TXBUF    ;
UART_Done   reti                            ;
                                            ;
String1     .byte      "Hello World",CR,LF
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int23"
            .short  USCI0RX_ISR
            .sect   ".int22"
            .short  USCI0TX_ISR
            .sect   ".reset"
            .short  RESET
            .end
