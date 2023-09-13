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

.import serial_recv_byte_sync
.import serial_send_byte
.import serial_send_str
.import serial_init

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

@main_loop:
    ; Just echo all bytes back to user
    jsr serial_recv_byte_sync
    jsr serial_send_byte

    jmp @main_loop
.endproc

; ************************************************************************
; Return the jump table version number in the A register.
;

.proc get_version: near
    lda #1
    rts
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
; Kernel jump table

.segment "KERNJUMP"

.word get_version

; ************************************************************************
; Vectors for interrupts

.segment "VECTORS"
.word nmi_service
.word start
.word irq_service

; ************************************************************************
; String constants

.segment "RODATA"

greeting: .byte "Lemon v0.1.2", $D, $0

; ************************************************************************
