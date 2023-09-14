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

.segment "EDITVARS"

; 32 Character ANSI parsing buffer
ansibuf: .res 32

; ************************************************************************

.segment "CODE"

; ************************************************************************
; Read's one or more bytes from the UART and tries to process an escape
; sequence into something that is hopefully rational.
;

ansi_recv:
    phy
    ldy #0

    bra @get_next_char

@unknown:
    jsr print_unknown

@get_next_char:
    jsr serial_recv_byte_sync

    cmp #27
    bne @done

    jsr serial_recv_byte_sync
    cmp #'['
    bne @unknown

    

@done:
    ply
    rts


; ************************************************************************

