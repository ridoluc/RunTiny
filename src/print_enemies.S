#include <avr/io.h>

sprite_obstacle:
.byte 0x18,0x20,0xfe,0xfc,0x30,0x1e

#define x_pos       R16
#define col_cnt     R17
#define sprite_w    R18




; .section .data
; enemy_pos: .space 3

.section .text
.global print_enemies

print_enemies:
    ; TWI Start
    rcall start
    ldi R24, 0x78
    rcall Tx
    ldi R24, 0x40
    rcall Tx
    
    ; Init print enemies
    ldi col_cnt, 0
    ; ldi R24,70
    ; sts enemy_pos, R24
    ldi YL, lo8(enemy_pos)
    ldi YH, hi8(enemy_pos)
    ld x_pos, Y+; here load position
    ; ldi x_pos, 50
    rjmp blank_col
loop_comlumns:
    cp  col_cnt, x_pos  ; compare enemy position with current column drawn
    brne blank_col
    ldi ZL, lo8(sprite_obstacle+0x4000)
    ldi ZH, hi8(sprite_obstacle+0x4000)
    ldi sprite_w, 5 ; Sprite width -1
print_sprite:
    ld R24, Z+
    rcall Tx
    inc col_cnt
    dec sprite_w
    brpl print_sprite
    ld x_pos, Y+    ; <--- here you get an overflow after the third enemy
blank_col:
    ldi R24, 0x80
    rcall Tx    
    inc col_cnt
    cpi col_cnt, 128
    brne loop_comlumns
    
    ; TWI Stop
    rcall stop

ret


#define STEP 2

.global update_enemy_pos


update_enemy_pos:
    lds R16, enemy_pos
    lds R17, enemy_pos +1
    lds R18, enemy_pos +2
    
    ;update position enemy 1
    ; subi R16, STEP
    ; brpl .+2        ; If enemy 1 position is >0 don't set to 0
    ; ldi R16, 0x00
    
    ;update position enemy 3
    subi R18, STEP
    brpl enemy_generated
    
    ;generate enemy
    
    ; provisional enemy generation
    ldi R18, 0x00
    cpi R17, 95  ;if enemy 2 is in x=95
    brpl .+2
    ldi R18, 120

enemy_generated:
    ;update position enemy 2
    subi R17, STEP
    brpl .+4
    mov R17, R18
    ldi R18, 0x00
    
    ;update position enemy 1
    subi R16, STEP
    brpl .+6
    mov R16, R17
    mov R17, R18
    ldi R18, 0x00

    ; store variables in SRAM
    sts enemy_pos, R16
    sts enemy_pos +1, R17
    sts enemy_pos +2, R18
ret

