


; REGISTERS USAGE
; R16:  Player Height
; R17:  Jump speed
; R18:  First enemy position
; R19:  Temporary, set_draw_region
; R20:  Tx


#include <avr/io.h>

#define OLED_ADDR       0x78
#define OLED_COMMANDS   0x00
#define OLED_DATA       0x40
#define JUMP_SPEED      4
#define H_MAX           19


#define H           R16
#define jump        R17
#define enemy_x     R18
#define tmp         R19


.section .rodata

display_init:
.byte   0xAE        ; Display OFF
.byte   0xA8, 0x1F  ; set multiplex (HEIGHT-1): 0x1F for 128x32, 0x3F for 128x64
.byte   0xD3, 0x00  ; Display offset to 0
.byte   0x40        ; Set display start line to 0
.byte   0x20, 0x01  ; Memory addressing mode 0x00 Horizontal 0x01 Vertical
.byte   0xDA, 0x02  ; Set COM Pins hardware configuration to sequential
.byte   0x81, 0x80  ; Set contrast
.byte   0xD9, 0xF1  ; Set pre-charge period
.byte   0xDB, 0x40  ; Set vcom detect

.byte   0x22, 0x00, 0x03 ; Page min to max
.byte   0x21, 0x00, 0x7F ; Column min to max

.byte   0x8D, 0x14  ; Charge pump enabled

.byte   0xAF        ; Display on
.byte   0x00

.section .data
.global enemy_pos
enemy_pos:
    .byte 90
    .byte 121
    .byte 0



.section .text
.global main
; .global __do_copy_data
.global INT0_vect


INT0_vect:
    ldi jump, JUMP_SPEED    ; Set the vertical jump speed to +4
    reti

main:
; System initialization
    ldi	    tmp, 0x03	; Set pin PB0 and PB1 as output for SDA abd SCL
    out	    DDRB, tmp	
    ldi	    tmp, 0x04	; Set pull-up on Button Pin PB4
    out	    PUEB, tmp	

; Button interrupt
    sei                     ; Enable interrupts
    sbi     EIMSK, INT0     ; Enable External Interrupt Request 0
    sbi     EICRA, ISC01    ; Interrupt activated on falling edge of PB2 (INT0)

; Sleep mode
    ldi     tmp, 0x05       ; Enable sleep mode and select power down
    out     SMCR, tmp       ; 

reset_game:

; Delay of 50ms before OLED initialization
    ldi     R24, 0xD3
    ldi     R25, 0x30
    rcall   _delay


; OLED Display Initialization
    ldi     ZL, lo8(display_init)
    ldi     ZH, hi8(display_init)
    ldi     tmp, 25     ; Loop over the 26 bytes of initialization commands
    rcall   start               ; Start OLED Communication
    ldi     R24, OLED_ADDR
    rcall   Tx
    ldi     R24, OLED_COMMANDS
    rcall   Tx
    ; Send Init Commands
    ld      R24, Z+
    rcall   Tx
    dec     tmp
    brne    .-8
    rcall   stop                ; Stop Communication

; Clear Display
    rcall	start    	
    ldi	    R24, OLED_ADDR	    ; OLED Address
    rcall	Tx    	
    ldi	    R24, OLED_DATA	    ; OLED Data
    rcall	Tx    	
    ldi	    tmp, 0x00	        ; Variable goes from 0, 255, 254, ... 2, 1 = 256 iterations
    ; Loop 256 times to clear the whole display
    ldi	    R24, 0x00	
    rcall	Tx    	
    ldi	    R24, 0x00	
    rcall	Tx    	
    subi	tmp, 0x01
    brne	.-12     	
    rcall	stop   	

; Reset Score
    ldi     tmp, 0x00
    sts     score_digit_1, tmp
    sts     score_digit_2, tmp
    sts     score_digit_3, tmp

; Reset player position 
    ldi     H, 0x00
    sts     enemy_pos+2, tmp
    ldi     tmp, 120
    sts     enemy_pos+1, tmp
    ldi     tmp, 90
    sts     enemy_pos, tmp
infinite_loop:

; Delay of 50ms to set frame rate
    ldi     R24, 0xD3
    ldi     R25, 0x30
    rcall _delay

; Move the player
    add     H, jump     ; Change height by jump direction
    cpi     H, H_MAX    ; Check if H_MAX is reached
    brlo    .+4
    ldi     jump, -JUMP_SPEED     ; Start falling
    rjmp    .+6
    tst     H           ; Check if heigh is 0
    brne    .+2
    ldi     jump, 0x00  ; If ground reached speed is 0

; Print the score
    ldi	    r22, 0x00	; 0 - Page
    ldi	    r23, 0x00	; 0 - Page
    ldi	    r24, 0x64	; 100 - Column
    ldi	    r25, 0x75	; 117 - Column
    rcall	set_draw_region    	
    rcall	print_score   

; Update and print the enemies
    rcall   update_enemy_pos
    ldi	    r22, 0x03	; 3 - Page
    ldi	    r23, 0x03	; 3 - Page
    ldi	    r24, 0x00	; 0 - Column
    ldi	    r25, 0x7F	; 127 - Column
    rcall	set_draw_region  
    rcall   print_enemies

; Print the player
    ldi	    r22, 0x00	; 0 - Page
    ldi	    r23, 0x03	; 3 - Page
    ldi	    r24, 0x0A	; 10 - Column
    ldi	    r25, 0x11	; 17 - Column
    rcall   set_draw_region

    mov     R24, H
    rcall   print_player

 	
; Check if GAME OVER
    lds     enemy_x, enemy_pos 
    cpi     enemy_x, 16     ; Enemy position higher than player position. Don't care player height
    brsh    infinite_loop
    cpi     enemy_x, 10     ; Enemy has passed. Don't care player height
    brlo    infinite_loop
    cpi     H, 8            ; Otherwise check if player is above enemy
    brsh    infinite_loop

; GAME OVER
 	ldi     tmp, 4
    ldi     R18, 0xA6    
game_over: 
    rcall   invert_display
; Delay
    ldi     R24, 0xFF
    ldi     R25, 0xFF
    rcall   _delay
    dec     tmp
    brne    game_over

; Display Off
    rcall	start    	
    ldi	    R24, OLED_ADDR	    ; OLED Address
    rcall	Tx    	
    ldi	    R24, OLED_COMMANDS	; OLED Commands
    rcall	Tx
    ldi     R24, 0x8D
    rcall	Tx    
    ldi     R24, 0x10
    rcall	Tx    
    ldi     R24, 0xAE
    rcall	Tx     
    rcall	stop  

    sleep

    rjmp    reset_game






; Delay routine 
; Input:    Number of iterations: 16-bit in R24 and R25
;           Each iteration takes 4us (0.004ms)
;           Return takes 4us
;           100ms = (25000-1)*0.004 ms
_delay: 
    subi	R24, 0x01	; 1
    sbci	R25, 0x00	; 0
    brne	.-6
ret

invert_display:
    rcall	start    	
    ldi	    R24, OLED_ADDR	    ; OLED Address
    rcall	Tx    	
    ldi	    R24, OLED_COMMANDS	; OLED Commands
    rcall	Tx
    ldi     R24, 0x01
    eor     R18, R24
    mov     R24, R18
    rcall	Tx     
    ldi     R24, 0x00
    rcall	Tx  
    ldi     R24, 0x00
    rcall	Tx     
    rcall	stop  
ret