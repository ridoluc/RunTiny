; 
; Registers used: R20, R24

#include <avr/io.h>

#define SDA PB0
#define SCL PB1

#define tmp R20

.global start
.global stop
.global Tx

start:
    sbi	PORTB, SDA	; SDA On
    nop 
    sbi	PORTB, SCL	; SCL On
    nop
    cbi	PORTB, SDA	; SDA Off
    nop
    cbi	PORTB, SCL	; SCL Off
ret

stop:
    cbi	PORTB, SDA	; SDA Off
    nop
    sbi	PORTB, SCL	; SCL On
    nop
    sbi	PORTB, SDA	; SDA On
ret


Tx:
    ldi	    tmp, 0x08	; Counter = 8
; Tx_loop:    
    sbrs    r24, 7      ; If data bit 1 SDA ON
    rjmp	.+4      	; Else SDA OFF
    sbi	    PORTB, SDA	; SDA On
    rjmp	.+2      	
    cbi	    PORTB, SDA	; SDA Off
    lsl	    r24    
    nop
    sbi	    PORTB, SCL	; SCL On
    nop
    cbi	    PORTB, SCL	; SCL Off
    nop
    dec	    tmp	        ; Counter -1
    brne	Tx+2     	
    sbi	    PORTB, SDA	; SDA On
    sbi	    PORTB, SCL	; SCL On
    nop
    ; in	  r24, PINB ; This for ack bit not used
    cbi	    PORTB, SCL	; SCL Off
    ; com	  r24       ; This for ack bit not used
    ; andi    r24, 0x01	; This for ack bit not used
ret