

.global set_draw_region

set_draw_region:
    mov R16, R24
    rcall start
    ldi R24, 0x78
    rcall Tx
    ldi R24, 0x00
    rcall Tx
    ldi R24, 0x21 ; Columns command
    rcall Tx
    mov R24, R16
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


