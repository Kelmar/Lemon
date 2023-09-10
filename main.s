; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: main.asm
; Description: Main kernel/boot entry point.
;
; Copyright (c) 2023
; ************************************************************************

.include "header.inc"

; ************************************************************************

start:
    ; Disable interrupts, set binary mode, initialize the stack
    sei
    cld
    ldx #$FF
    txs

_main_loop:
    nop
    jmp _main_loop

; ************************************************************************

irq_service:
    rti

; ************************************************************************

nmi_service:
    nop
    jmp nmi_service

; ************************************************************************
; Vectors for interrupts

.org $1FFA
.word nmi_service
.word start
.word irq_service

; ************************************************************************
