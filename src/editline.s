; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: editline.s
; Description: Line editing functions
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"
.include "serial.inc"

.import byte2dec

.segment "EDITVARS"

; Buffer for editor
buffer: .res 160

; Buffer for ANSI escape code generation
ansicode: .res 32

.segment "CODE"

.export editline

; ************************************************************************
; Edits a line of text.
;

editline:
    ldy #0
    ldx #0

    bra @get_next_char

@unknown:
    jsr print_unknown
    
@get_next_char:
    ; Just echo all bytes back to user
    jsr serial_recv_byte_sync

    cmp #1 ; CTRL+A
    beq @home_key

    cmp #4 ; CTRL+D
    beq @delete_key

    cmp #5 ; CTRL+E
    beq @end_key

    cmp #8 ; Backspace
    beq @backspace_key
    
    cmp #$7F ; Alt-backspace
    beq @backspace_key

    cmp #10 ; CR
    bne @check_lf
    jsr serial_send_byte
    rts

@check_lf:
    cmp #13 ; LF
    bne @check_escape
    jsr serial_send_byte
    rts

@check_escape:
    cmp #27
    beq @handle_escape
    
    cmp #$20
    bcc @unknown ; Ignore control characters

    jsr serial_send_byte

    ; TODO: Insert into buffer here.

    ; Echo the byte back to the UART
    iny
    inx
    
    bra @get_next_char

@backspace_key:
    cpy #0
    beq @get_next_char ; At the start of the line, do nothing.

    ; Delete characters to the left of the cursor.
    lda #8
    jsr serial_send_byte

    bra @get_next_char

@delete_key:
    ; Delete characters to the right of the cursor.
    bra @get_next_char

@home_key:
    cpy #0
    beq @get_next_char ; Already at the start of the line.

    tya
    ldy #0
    
    jsr move_left

    bra @get_next_char

@end_key:
    stx TMP_A
    cpy TMP_A
    beq @get_next_char ; Already at the end of the line.

    ; Find out how far to the end we were
    lda TMP_A
    sty TMP_A
    tay
    sec
    sbc TMP_A ; This should be A - old_Y

    ;jsr serial_print_hex
    jsr move_right

    bra @get_next_char

@right_key:
    stx TMP_A
    cpy TMP_A
    bcs @get_next_char ; Already at the end of the line.

    iny

    lda #1
    jsr move_right

    bra @get_next_char

@left_key:
    cpy #0
    beq @get_next_char ; Already at the begining of the line.
    
    dey

    lda #1
    jsr move_left

    bra @get_next_char

@handle_escape:
    jsr serial_recv_byte_sync

    cmp #'['
    jmp @unknown ; Unknown escape sequence, ignore and continue

    jsr serial_recv_byte_sync
    ;cmp #'A'
    ;beq @up_key

    ;cmp #'B'
    ;beq @down_key

    cmp #'C'
    beq @right_key

    cmp #'D'
    beq @left_key

    cmp #'O'
    beq @try_extended_key

    ; Check for digit
    eor #$30
    cmp #10
    bcc @try_number
    eor #$30
    jmp @unknown
    
@try_number:
    ; Pretty sure these are xterm codes, but we'll handle them..... *grumble*

    ; A should have our decoded single digit.
    sta TMP_A
    jsr serial_recv_byte_sync

    cmp #'~'
    jmp @unknown

    lda TMP_A

    cmp #1 ; Home
    beq @home_key

    cmp #4
    beq @end_key

    jmp @unknown

@try_extended_key:
    jsr serial_recv_byte_sync

    ;cmp #'P' ; F1
    ;cmp #'Q' ; F2
    ;cmp #'R' ; F3
    ;cmp #'S' ; F4

    ; MORE Arrow keys!
    ;cmp #'A' ; Up
    ;cmp #'B' ; Down
    cmp #'C'
    beq @right_key

    cmp #'D'
    beq @left_key
    
    ; Unknown escape sequence, ignore and continue.
    jmp @unknown

    rts

; ************************************************************************

print_unknown:
    phx
    phy
    pha

    lda #<unknown_msg
    sta W0
    lda #>unknown_msg
    sta W0 + 1

    jsr serial_send_str

    pla
    ply
    plx

    jsr serial_print_hex

    rts

; ************************************************************************

move_right:
    phx
    phy
    pha

    lda #<escape_begin
    sta W0
    lda #>escape_begin
    sta W0 + 1

    jsr serial_send_str

    ldy #0
    
    lda #<ansicode
    sta W0
    lda #>ansicode
    sta W0 + 1

    pla

    jsr byte2dec
    jsr serial_send_str

    lda #'C'
    jsr serial_send_byte

    ply
    plx
    rts

; ************************************************************************

move_left:
    phx
    phy

    pha

    lda #<escape_begin
    sta W0
    lda #>escape_begin
    sta W0 + 1

    jsr serial_send_str

    ldy #0

    lda #<ansicode
    sta W0
    lda #>ansicode
    sta W0 + 1

    pla

    jsr byte2dec
    jsr serial_send_str

    lda #'D'
    jsr serial_send_byte

    ply
    plx
    rts

; ************************************************************************

.segment "RODATA"

unknown_msg:  .byte $D, "Unknown: ", $0
escape_begin: .byte $1B, "[", $0

; ************************************************************************
