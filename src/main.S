; REGISTERS USAGE
; R16:  Player Height
; R17:  Jump speed
; R18:  First enemy position
; R19:  Temporary, set_draw_region
; R20:  Tx
; 
; 


#include <avr/io.h>

#define OLED_ADDR       0x78
#define OLED_COMMANDS   0x00
#define OLED_DATA       0x40


#define H       R16
#define tmp     R19


.section .rodata

display_init: 
.byte   0xAE        ; Display OFF
.byte   0xA8, 0x1F  ; set multiplex (HEIGHT-1): 0x1F for 128x32, 0x3F for 128x64
.byte   0xD3, 0x00  ; Display offset to 0
.byte   0x40        ; Set display start line to 0
.byte   0x8D, 0x14  ; Charge pump enabled
.byte   0x20, 0x01  ; Memory addressing mode 0x00 Horizontal 0x01 Vertical
.byte   0xDA, 0x02  ; Set COM Pins hardware configuration to sequential
.byte   0x81, 0x80  ; Set contrast
.byte   0xD9, 0xF1  ; Set pre-charge period
.byte   0xDB, 0x40  ; Set vcom detect

.byte   0x22, 0x00, 0x03 ; Page min to max
.byte   0x21, 0x00, 0x7F ; Column min to max

.byte   0xAF        ; Display on
.byte   0x00

.section .data
.global enemy_pos
enemy_pos:
.word 0x3214
.byte 0x5a

.section .text
.global main
.global __do_copy_data

main:
; System initialization
    ldi	    tmp, 0x03	; Set pin PB0 and PB1 as output for SDA abd SCL
    out	    DDRB, tmp	
    ldi	    tmp, 0x04	; Set pull-up on Button Pin PB4
    out	    PUEB, tmp	

    ; ldi     tmp, 0x00
    ; sts     score_digit_3, tmp
    ; lds tmp, enemy_pos

; Delay of 50ms before OLED initialization
    ldi     R24, 0xD3
    ldi     R25, 0x30
    rcall _delay

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


infinite_loop:

; Delay of 100ms to set frame rate
    ldi     R24, 0xA7
    ldi     R25, 0x61
    rcall _delay

    ldi	    r22, 0x00	; 0
    ldi	    r23, 0x00	; 0
    ldi	    r24, 0x64	; 100
    ldi	    r25, 0x75	; 117
    rcall	set_draw_region    	
    rcall	print_score   

    rcall   update_enemy_pos
    ldi	    r22, 0x03	; 3
    ldi	    r23, 0x03	; 3
    ldi	    r24, 0x00	; 0
    ldi	    r25, 0x7F	; 127
    rcall	set_draw_region  
    rcall   print_enemies



    ldi	    r22, 0x00	; 0
    ldi	    r23, 0x03	; 3
    ldi	    r24, 0x0A	; 10
    ldi	    r25, 0x10	; 16
    rcall   set_draw_region

    ldi     R24, 0x00
    rcall   print_player

 	

    rjmp    infinite_loop






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

