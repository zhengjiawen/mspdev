;******************************************************************************
;   MSP-FET430P120 Demo - USART0, SPI Interface to HC165/164 Shift Registers
;
;   Description: Demonstrate USART0 in two-way SPI mode. Data are read from
;   an HC165, and same data written back to the HC164.
;   ACLK = n/a  MCLK = SMCLK = DCO ~ 800k, UCLK0 = DCO/2
;   //**SWRST** please see MSP430x1xx Users Guide for complete description //
;   //* USART0 interrupt flags may be in different SFR's from other MSP430's *//
;
;                         MSP430F123(2)
;                       -----------------
;                   /|\|              XIN|-
;                    | |                 |     ^      HC164
;          HC165     --|RST          XOUT|-    |  -------------
;        ----------    |                 |     |-|/CLR,B       |  8
;    8  |      /LD|<---|P3.0   SIMO0/P3.1|------>|A          Qx|--\->
;   -\->|A-H   CLK|<---|P3.3/UCLK0 - P3.3|------>|CLK          |
;     |-|INH    QH|--->|P3.2/SOMI        |       |             |
;     |-|SER      |    |                 |       |             |
;     - |         |    |                 |       |             |
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
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupP3     bis.b   #0Eh,&P3SEL             ; P3.1-3 SPI option select
            bis.b   #01h,&P3DIR             ; P3.0 output direction
SetupSPI    bis.b   #USPIE0,&ME2            ; Enable USART0 SPI
            bis.b   #CKPH+SSEL1+SSEL0+STC,&UTCTL0 ; SMCLK, 3-pin mode
            bis.b   #CHAR+SYNC+MM,&UCTL0    ; 8-bit SPI Master
            mov.b   #02h,&UBR00             ; SMCLK/2 for baud rate
            clr.b   &UBR10                  ;
            clr.b   &UMCTL0                 ; Clear modulation
            bic.b   #SWRST,&UCTL0           ; **Initialize USART state machine**
                                            ;
Mainloop    call    #RXTX_HC16x             ; Exchange data
                                            ;
Delay       push.w  #0                      ; Software delay
D1          dec.w   0(SP)                   ;
            jnz     D1                      ;
            incd.w  SP                      ;
            jmp     Mainloop                ; Repeat
                                            ;
;------------------------------------------------------------------------------
RXTX_HC16x;   HC165--> URXBUF0  UTXBUF0 --> HC164
;------------------------------------------------------------------------------
TX0         bit.b   #UTXIFG0,&IFG2          ; USART0 TX buffer ready?
            jz      TX0                     ; Jump --> TX buffer not ready
            bic.b   #01h,&P3OUT             ; Latch data into 'HC165
            bis.b   #01h,&P3OUT             ;
            mov.b   &RXBUF0,&TXBUF0         ; Previous data to TX, RX next
            ret                             ; Return from subroutine
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .end

