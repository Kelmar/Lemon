; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: main.s
; Description: Main kernel/boot entry point.
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"
.include "serial.inc"

.import editline

.segment "STARTUP"

; ************************************************************************

.proc start: near
    ; Disable interrupts, set binary mode, initialize the stack
    sei
    cld
    ldx #$FF
    txs

    jsr serial_init

    lda #<greeting
    sta W0
    lda #>greeting
    sta W0 + 1

    jsr serial_send_str

    ldx #0

@main_loop:
    lda #<prompt
    sta W0
    lda #>prompt
    sta W0 + 1

    jsr serial_send_str

    jsr editline

    jmp @main_loop

.endproc

; ************************************************************************
; Normal interrupt handler.

irq_service:
    ; For now we do nothing and return.
    rti

; ************************************************************************
; NMI handler

nmi_service:
    ; For now we do nothing, but in the future we should start the debugger.
    nop
    jmp nmi_service

; ************************************************************************
; Vectors for interrupts

.segment "VECTORS"
.word nmi_service
.word start
.word irq_service

; ************************************************************************
; String constants

.segment "RODATA"

greeting: .byte $1B, "c", $1B, "[2jLemon v0.1.2", $D, $0
prompt  : .byte "> ", $0

; ************************************************************************
