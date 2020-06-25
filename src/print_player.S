
    ; 0x4000 instead of lpm
    


; #define PORTB 0x18
; #define DDRB 0x17

#define page1  R18
#define page2  R19
#define page3  R25
#define page4  R21
#define _h     R22
#define _col   R23

.global print_player

print_player:
	mov R26, R24 ; store the player height
    rcall start
    ldi R24, 0x78
    rcall Tx
    ldi R24, 0x40
    rcall Tx
    ldi _col, 8 ;same as the sprite width 
    ldi ZL, lo8(player_sprite+0x4000) 
    ldi ZH, hi8(player_sprite+0x4000) 
loop_columns:
    ldi page1, 0x00
    ldi page2, 0x00
    ld page3, Z+        ; Upper half of the sprite
    ld page4, Z+        ; Lower half of the sprite
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
    rcall stop
ret


player_sprite: 
.byte 0x00, 0x0e
.byte 0x00, 0x18
.byte 0x00, 0xfc
.byte 0x00, 0x3f
.byte 0xc0, 0xff
.byte 0xa0, 0x0f
.byte 0xe0, 0x02
.byte 0xc0, 0x00