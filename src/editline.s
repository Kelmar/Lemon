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
.include "hotkey.inc"

.import byte2dec
.import ansi_recv

.segment "EDITVARS"

.define BUFFER_SIZE 160

; Gap buffer for line editor
buffer: .res BUFFER_SIZE

; Buffer for ANSI escape code generation
ansicode: .res 16

; Start of gap in buffer
gap_start: .res 1

; End of gap in buffer
gap_end: .res 1

.segment "CODE"

.export editline

; ************************************************************************
; Edits a line of text.
;

editline:
    ldy #0
    ldx #0

    ; Clear out the buffer
    stz buffer
    stz gap_start
    stz gap_end

@get_next_char:
    jsr ansi_recv

    bcs @state_special_key

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
    beq @enter_key

    cmp #13 ; LF
    beq @enter_key

    cmp #$20
    bcc @get_next_char ; Ignore any other control characters

    ; TODO: Insert into buffer here.
    iny
    inx

    ; Echo the character back to the user
    jsr serial_send_byte

@state_special_key:
    cmp KEY_LEFT
    beq @left_key

    cmp KEY_RIGHT
    beq @right_key

    cmp KEY_HOME
    beq @home_key

    cmp KEY_END
    beq @end_key

    ; Ignore any other special keys and continue.
    bra @get_next_char

@enter_key:
    ; TODO: Finalize buffer and return it to the caller.
    jsr serial_send_byte
    rts

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

    ;bra @get_next_char
    jmp @get_next_char

    rts

; ************************************************************************

print_line_data:
    phy

    ; Send the first part of the buffer
    ldy gap_start

    lda #<buffer
    sta W0
    lda #>buffer
    sta W0 + 1

    jsr serial_send_buffer

    lda gap_end
    adc W0 + 1
    sta W0 + 1

    ; Send until NULL character
    jsr serial_send_str

    ply
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

escape_begin: .byte $1B, "[", $0

; ************************************************************************
