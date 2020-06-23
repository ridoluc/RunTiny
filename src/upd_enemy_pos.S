; 
; Registers used: R18, R19, R20

#define pos1 R18
#define pos2 R19
#define pos3 R20


#define STEP 3

.global update_enemy_pos

update_enemy_pos:
    lds pos1, enemy_pos
    lds pos2, enemy_pos +1
    lds pos3, enemy_pos +2
    
    ;update position enemy 1
    ; subi pos1, STEP
    ; brpl .+2        ; If enemy 1 position is >0 don't set to 0
    ; ldi pos1, 0x00
    
; Update position Enemy 3
    subi pos3, STEP         ; Move enemy position by STEP
    brpl enemy_generated    ; If position is negative then generate the enemy
    
; Generate enemy  
; Provisional enemy generation
    ldi pos3, 0x00
    cpi pos2, 95  ;if enemy 2 is in x=95
    brpl .+2
    ldi pos3, 120

enemy_generated:
; Update position Enemy 2
    subi pos2, STEP         ; Move enemy position by STEP
    brpl .+4                ; If the position is negative than swap it with Enemy 3 
    mov pos2, pos3
    ldi pos3, 0x00
    
; Update position Enemy 1
    subi pos1, STEP         ; Move enemy position by STEP
    brpl .+6
    mov pos1, pos2
    mov pos2, pos3
    ldi pos3, 0x00

    ; store variables in SRAM
    sts enemy_pos, pos1
    sts enemy_pos +1, pos2
    sts enemy_pos +2, pos3
ret

