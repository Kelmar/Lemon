; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: main.s
; Description: Main kernel/boot entry point.
;
; Copyright (c) 2023
; ************************************************************************

.include "header.inc"
.include "zp.inc"

; ************************************************************************

start:
    ; Disable interrupts, set binary mode, initialize the stack
    sei
    cld
    ldx #$FF
    txs

    jsr serial_init

    LDW0 greeting
    jsr serial_send_str

@main_loop:
    nop
    jmp @main_loop

; ************************************************************************
; Stub function for kernel jump table.
; This is a safety function for if a rogue program jumps to a bad table entry.

stub:
    rts

; ************************************************************************
; Return the jump table version number in the A register.
;

get_version:
    lda #1
    rts

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
; String constants
greeting: .ascstr "Lemon v0.1\n", $0

; ************************************************************************
; Kernel jump table
.org $1F00
vectors:
.word get_version

; Fill the remainder of the jump table with our stub function.
.dsw 63, stub

; ************************************************************************
; Vectors for interrupts

.org $1FFA
.word nmi_service
.word start
.word irq_service

; ************************************************************************
