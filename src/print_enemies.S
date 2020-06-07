#include <avr/io.h>

sprite_obstacle:
.byte 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff

#define x_pos       R16
#define col_cnt     R17
#define sprite_w    R18

.section .data
.org 0x00
enemy_pos: .byte 100

.section .text
.global print_enemies

print_enemies:
    ldi col_cnt, 0
    lds x_pos, enemy_pos; here load position
loop_comlumns:
    cp  col_cnt, x_pos  ; compare enemy position with current column draw
    brne blank_col
    ldi ZL, lo8(sprite_obstacle+0x4000)
    ldi ZH, hi8(sprite_obstacle+0x4000)
    ldi sprite_w, 8
print_sprite:
    ld R24, Z+
    rcall Tx
    inc col_cnt
    dec sprite_w
    brpl print_sprite
blank_col:
    ldi R24, 0x00
    rcall Tx    
    inc col_cnt
    cpi col_cnt, 128
    brne loop_comlumns
    ret