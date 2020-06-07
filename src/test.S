
    ; 0x4000 instead of lpm
    


; #define PORTB 0x18
; #define DDRB 0x17

#define page1  R18
#define page2  R19
#define page3  R25
#define page4  R21
#define _h     R22
#define _col   R23

.global print

print:
    ldi _col, 7 ;same as the sprite width 
    ldi ZL, lo8(sprite_test+0x4000) 
    ldi ZH, hi8(sprite_test+0x4000) 
	mov R26, R24
loop_columns:
    ldi page1, 0x00
    ldi page2, 0x00
    ldi page3, 0x00
    ld page4, Z+
	mov _h, R26
    rjmp dec_h
loop_h:
    lsr page4
    ror page3
    ror page2
    ror page1
dec_h:
    dec _h
    brpl loop_h
    
    ; send data to display
    mov R24, page1
    rcall Tx
    mov R24, page2
    rcall Tx
    mov R24, page3
    rcall Tx
    mov R24, page4
    rcall Tx
    dec _col
    brne loop_columns
ret


sprite_test: 
.byte 0x1c
.byte 0xf8
.byte 0x38
.byte 0xfe
.byte 0x1f
.byte 0x07
.byte 0x02

; 	out DDRB,r16
; 	out PORTB,r16
; Start:
; 	rjmp Start