; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: ansi.s
; Description: Ansi receive function
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"
.include "serial.inc"
.include "hotkey.inc"

.segment "CODE"

.export ansi_recv

.import byte2dec

; ************************************************************************
; Read's one or more bytes from the UART and tries to process an escape
; sequence into something that is hopefully rational.
;
; If a normal character is read, then the carry flag is cleared and the
; ACSII value is returned in A.
;
; If an escape sequence is read, then the carry flag is set, and a condensed 
; code for the escape sequence is returned in A.
;

ansi_recv:
    ;bra @get_next_char

@unknown:
    ;jsr print_unknown

@get_next_char:
    jsr serial_recv_byte_sync

    cmp #27
    beq @state_esc

    clc
    rts

@state_esc:
    jsr serial_recv_byte_sync
    cmp #'['
    beq @state_esc_bracket

    eor #$30
    cmp #10
    bcs @vt100_escape ; Not digit, try VT-100 escape
    jmp @xterm_state

@vt100_escape:
    eor #$30 ; Convert back to ASCII value

    cmp #'O'
    beq @state_escape_O

    sec
    sbc #'A'
    bcc @unknown ; Less than 'A' ?

    cmp #9
    bcs @unknown ; Greater than 'H'?

    bra @unknown

@state_escape_O:
    jsr serial_recv_byte_sync

    sec
    sbc #'A'
    bcc @unknown ; Less than 'A' ?

    cmp #9
    bcs @unknown ; Greater than 'H'?

    tay
    lda edit_keys, y
    sec
    rts

@check_num_state:
    clc
    adc #'A'

    ; Check for numeric key
    sec
    sbc #'q'
    cmp #10
    bcs @state_not_digit

    ; Character is numeric keypad item, convert to ansi number and return
    eor #$30
    clc
    rts

@state_not_digit:
    adc #'q'
    cmp #'m'
    bne @state_not_minus
    lda #'-'
    clc
    rts

@state_not_minus:
    cmp #'l'
    bne @state_not_comma
    lda #','
    clc
    rts
    
@state_not_comma:
    cmp #'n'
    bne @state_not_period
    lda #'.'
    clc
    rts

@state_not_period:
    cmp #'M'
    bne @state_not_enter
    lda #13
    clc
    rts

@state_not_enter:
    bra @unknown

@state_esc_bracket:
    jsr serial_recv_byte_sync

    eor #$30
    cmp #10
    bcc @xterm_state ; X-Term edit key

    eor #$30

    sec
    sbc #'A'
    bcs @check_over_h
    jmp @unknown ; Less than 'A' ?

@check_over_h:
    cmp #9
    bcc @xlate_edit_key
    jmp @unknown ; Greater than 'H'

@xlate_edit_key:

    tay
    lda edit_keys, y
    sec
    rts

@xterm_state:
    tay ; Save digit

    ; Verify we get the expected tilde
    jsr serial_recv_byte_sync
    cmp #'~'
    beq @xterm_key_detected
    jmp @unknown

@xterm_key_detected:
    lda xterm_keys, y

    sec
    rts

; ************************************************************************

print_unknown:
    pha
    lda #<unknown_msg
    sta W0
    lda #>unknown_msg
    sta W0 + 1

    jsr serial_send_str
    pla

    jsr serial_send_byte

    pha
    lda #' '
    jsr serial_send_byte
    pla
    
    jsr serial_print_hex

    rts

; ************************************************************************

.segment "RODATA"

; Translation table for xterm keys to our keys
;                 0  1         2           3           4        5       6       7         8        9
xterm_keys: .byte 0, KEY_HOME, KEY_INSERT, KEY_DELETE, KEY_END, KEY_PU, KEY_PD, KEY_HOME, KEY_END, 0

; Translation table for other escape keys
;                 A       B         C          D         E  F        G  H
edit_keys:  .byte KEY_UP, KEY_DOWN, KEY_RIGHT, KEY_LEFT, 0, KEY_END, 0, KEY_HOME

unknown_msg: .byte "Unknown: ", $0

; ************************************************************************
