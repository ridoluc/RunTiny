; 
; Registers used: R23, R24, R25, R19


#define W 5

#define tmp R19


.global score_digit_1
.global score_digit_2
.global score_digit_3

.section .data
score_digit_1: .byte 0x00   ; Units
score_digit_2: .byte 0x00   ; Tens
score_digit_3: .byte 0x00   ; Hundreds

.section .text
.global print_score

print_score:
    lds     R23, score_digit_1      ; Load units position from memory
    subi    R23, (-W)               ; Increase position by font width 
    cpi     R23, (W *10)            ; Check if the end is reached
    brlo    store+2                 ; If not, stor the updated variable
    ldi     R23, 0                  ; If 9 has passed restart from 0
    lds     R24, score_digit_2      ; Load tens position from memory
    subi    R24, (-W)               ; Increase tens by width
    cpi     R24, (W *10)            ; Check if the end is reached
    brlo    store                   ; If not, stor the updated variable
    ldi     R24, 0                  ; If 9 has passed restart from 0 
    lds     R25, score_digit_3      ; Increase hundreds by font width
    subi    R25, (-W)               ; Increase hundreds by font width
    sts     score_digit_3, R25      ; Store hundreds position into memory
store:
    sts     score_digit_2, R24      ; Store tens position into memory
    sts     score_digit_1, R23      ; Store units position into memory

; Print Digits
    ; TWI Start
    rcall   start
    ldi     R24, 0x78
    rcall   Tx
    ldi     R24, 0x40
    rcall   Tx

    lds     R24, score_digit_3
    rcall   print_digit
    lds     R24, score_digit_2
    rcall   print_digit
    lds     R24, score_digit_1
    rcall   print_digit
    
    ; TWI Stop
    rcall stop



print_digit:
    ldi     R25, 0x00
    ldi     ZH, hi8(font_digit) ; Load memory pointer     
    ldi     ZL, lo8(font_digit) 
    add     ZL, R24             ; Increase pointer by digit position
    adc     ZH, R25
    ldi     tmp, W-1            ; Loop through the digit width
    ld      R24, Z+             ; Load and increase pointer position
    rcall   Tx
    dec     tmp                 ; Decrease counter
    brpl    .-8                 ; Loop
    ldi     R24, 0              ; Print blank column beteen each digit
    rcall   Tx
ret




.section .rodata

font_digit: 
    .byte 0x7c,0x82,0x82,0x82,0x7c ;0
    .byte 0x00,0x84,0xfe,0x80,0x00 ;1
    .byte 0x84,0xc2,0xa2,0x92,0x8c ;2
    .byte 0x44,0x82,0x92,0x92,0x6c ;3
    .byte 0x30,0x28,0x24,0xfe,0x20 ;4
    .byte 0x9e,0x92,0x92,0x92,0x60 ;5
    .byte 0x7c,0x92,0x92,0x92,0x60 ;6
    .byte 0x02,0xe2,0x12,0x0a,0x06 ;7
    .byte 0x6c,0x92,0x92,0x92,0x6c ;8
    .byte 0x0c,0x92,0x92,0x92,0x7c ;9




