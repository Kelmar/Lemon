; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: via.s
; Description: Driver for primary VIA
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"
.include "via.inc"

.segment "CODE"
.export via_init

; ************************************************************************

via_init:
    ; Disable all interrupts
    lda #%01111111
    sta VIA_IER

    ; Set all port bits to output
    lda #$FF
    sta VIA_DDR_B
    sta VIA_DDR_A

    ; Make all outputs low
    stz VIA_PORT_A
    stz VIA_PORT_B

    ; Enable interrupts from serial port.
    ; (Later we'll put the serial port on a PLD independent of the VIA)

    ; Tell VIA to trigger interrupt on high edge of CB1
    lda #%00010000
    sta VIA_PCR

    ; Turn on interrupts from VIA on CB1
    lda #%10010000
    sta VIA_IER

    rts

; ************************************************************************
