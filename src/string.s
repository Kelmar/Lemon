; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: string.s
; Description: String manipulation functions
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"

.segment "CODE"

.export byte2dec
.export strcmp
.export memcpy
.export memcpy_down
.export memcpy_up

; ************************************************************************
; Convert a byte in A register to decimal string pointed to in (W0),y
;
; Destroys A, X, Y, R0, R1, R2
;
; Modified from:
; http://6502org.wikidot.com/software-output-decimal
;

byte2dec:
    sty R2

    ldx #1
    stx R0
    inx
    ldy #$40

@top:
    sty R1
    lsr

@check_value:
    rol
    bcs @sub_const
    cmp dec_consts,x
    bcc @adjust_digit

@sub_const:
    sbc dec_consts,x
    sec

@adjust_digit:
    rol R1
    bcc @check_value
    tay
    cpx R0
    lda R1
    bcc @write_digit
    beq @check_end
    stx R0

@write_digit:
    eor #$30
    phy
    ldy R2
    sta (W0),y
    iny
    sty R2
    ply

@check_end:
    tya
    ldy #$10
    dex
    bpl @top

    ; NULL Terminate
    ldy R2
    lda #0
    sta (W0),y

    rts

dec_consts: .byte 128, 160, 200

; ************************************************************************
; Compares two NULL terminated strings W0 with W1.
;
; Sets status bits based on if they are equal or not.
;
; Destroys: A, Y
;
strcmp:
    ldy #0

@cmp_loop:
    lda (W0),y
    cmp (W1),y
    bne @done

    cmp #0 
    beq @done ; Hit NULL, end loop

    iny
    bne @cmp_loop

    inc W0 + 1
    inc W1 + 1

    bra @cmp_loop

@done
    rts

; ************************************************************************
; Copy memory from one location W0 to another W1.  With the number of bytes
; in the W2 parameter.
;
; Destroys: A

memcpy:
    ; Check to see which direction we need to move the data.
    lda W0
    cmp W1
    bcc memcpy_up
    bne memcpy_down

    ; Moving roughly within the same page.
    lda W0 + 1
    cmp W1 + 1
    bcc memcpy_up
    bne memcpy_down

    ; Source and destination are the same, do nothing.
    rts

; ************************************************************************
; Copy memory from one location W0 to another W1.  With the number of bytes
; in the W2 parameter.
;
; Only copies downward.  Use memcpy if the order of the pointers is unknown.
;
; Destroys: A
;
; Modified from:
; http://6502.org/source/general/memory_move.html
;
memcpy_down:
    phy
    phx

    ldy #0
    ldx W2 + 1

    beq @finish_bytes

    ; Copy page
@page_loop:
    lda (W0), y
    sta (W1), y
    iny
    bne @page_loop

    ; Increment to next page
    inc W0 + 1
    inc W1 + 1
    dex
    bne @page_loop

    ; Finish copying remaining bytes.
@finish_bytes:
    ldx W2
    beq @done

@byte_loop:
    lda (W0),y
    sta (W0),y
    iny
    dex
    bne @byte_loop

@done:
    plx
    ply 
    rts

; ************************************************************************
; Copy memory from one location W0 to another W1.  With the number of bytes
; in the W2 parameter.
;
; Only copies upwards.  Use memcpy if the order of the pointers is unknown.
;
; Destroys: A
;
; Modified from:
; http://6502.org/source/general/memory_move.html
;
memcpy_up:
    phy
    phx

    ldx W2 + 1

    ; Calculate ending upper byte of address
    
    clc
    txa
    adc W0 + 1
    sta W0 + 1

    clc
    txa
    adc W1 + 1
    sta W1 + 1

    inx

    ldy W2
    beq @next_page

    ; Move bytes on last page first
    dey
    beq @page_boundary

@page_loop:
    lda (W0),y
    sta (W1),y
    dey
    bne @page_loop

@page_boundary:
    lda (W0),y ; Handle Y = 0 separately
    sta (W1),y

@next_page:
    dey
    dec W0 + 1
    dec W1 + 1
    dex
    bne @page_loop

    plx
    ply
    rts

; ************************************************************************
