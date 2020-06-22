; 
; Registers used: R19, R24

#define tmp R19

.global set_draw_region

set_draw_region:
    mov tmp, R24
    rcall start
    ldi R24, 0x78
    rcall Tx
    ldi R24, 0x00
    rcall Tx
    ldi R24, 0x21 ; Columns command
    rcall Tx
    mov R24, tmp
    rcall Tx
    mov R24, R25
    rcall Tx
    ldi R24, 0x22 ; Page command
    rcall Tx
    mov R24, R22
    rcall Tx
    mov R24, R23
    rcall Tx
    rcall stop
ret

; .global clear_display

; clear_display:
;     rcall	start    	; 0x3e <start>
;     ldi	    r24, 0x78	; OLED Address
;     rcall	Tx    	; 0x5e <Tx>
;     ldi	    r24, 0x40	; OLED Data
;     rcall	Tx    	; 0x5e <Tx>
;     ldi	    r28, 0x	; 0
;     ldi	    r24, 0x00	; 0
;     rcall	Tx    	; 0x5e <Tx>
;     ldi	    r24, 0x00	; 0
;     rcall	Tx    	; 0x5e <Tx>
;     subi	r28, 0x01
;     ; cpi	    r28, 0xFF	; 255
;     brne	.-12     	; 0x21e <main+0x3e>
;     rcall	stop   	; 0x50 <stop>
; ret