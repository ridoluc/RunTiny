; 
; Registers used: R18, R19, R20

#define pos1 R18
#define pos2 R19
#define pos3 R20
#define tmp1 R24



#define STEP 3

.section .data
rand: .byte 103     // RNG Seed


.section .text
.global update_enemy_pos

update_enemy_pos:
    lds     pos1, enemy_pos
    lds     pos2, enemy_pos +1
    lds     pos3, enemy_pos +2
    
; Update position Enemy 3
    subi    pos3, STEP         ; Move enemy position by STEP
    brpl    enemy_generated    ; If position is <=0 then generate the enemy
    
; Generate enemy  
    ldi     pos3, 0x00
    cpi     pos2, 105       ; If enemy 2 position>105 no new enemy(min distance between two enemies is 15)
    brpl    enemy_generated
    cpi     pos2, 70        ; Generate enemy 3 if enemy 2 is in x<90 (max distance between two enemies is 30)
    brmi    new_enemy
; Xorshift RNG (kind of...)
    lds     tmp1, rand      ; Load previous random number
    mov     pos3, tmp1      ; Copy it in a variable
    lsl     pos3            ; Shift left by 1 position
    eor     tmp1, pos3      ; XOR the two numbers
    eor     tmp1, R16       ; XOR with player height that is quite random
    sts     rand, tmp1      ; Store the new random number
    ldi     pos3, 0x00      
    cpi     tmp1, 190       ; If the random number is greater than 190 generate a new one
    brlo    enemy_generated
new_enemy:    
    ldi     pos3, 120       ; A new enemy is generated

enemy_generated:
; Update position Enemy 2
    subi    pos2, STEP         ; Move enemy position by STEP
    brpl    .+4                ; If the position is negative than swap it with Enemy 3 
    mov     pos2, pos3
    ldi     pos3, 0x00
    
; Update position Enemy 1
    subi    pos1, STEP         ; Move enemy position by STEP
    brpl    .+6
    mov     pos1, pos2
    mov     pos2, pos3
    ldi     pos3, 0x00

    ; store variables in SRAM
    sts     enemy_pos, pos1
    sts     enemy_pos +1, pos2
    sts     enemy_pos +2, pos3
ret

