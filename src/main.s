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
.include "via.inc"
.include "serial.inc"

.import editline
.import ansi_recv

.import via_init

.segment "STARTUP"

; ************************************************************************

.proc start: near
    ; Initialize the stack
    ldx #$FF
    txs

    jsr via_init
    jsr serial_init

    ; Enable interrupts
    cli

    LDW0_fast greeting
    jsr serial_send_str

    ldx #0

@main_loop:
    ;lda #<prompt
    ;sta W0
    ;lda #>prompt
    ;sta W0 + 1

    ;jsr serial_send_str

    ;jsr editline
    jsr ansi_recv

    bcs @special_key

    pha

    lda #<normal
    sta W0
    lda #>normal
    sta W0 + 1

    jsr serial_send_str

    pla

    ; Print the normal character
    jsr serial_send_byte

    bra @done

@special_key:
    pha

    lda #<special
    sta W0
    lda #>special
    sta W0 + 1

    jsr serial_send_str

    pla

    ; Print the special key code number
    jsr serial_print_hex

    bra @done

@done:
    ; Move to next line
    lda #$D
    jsr serial_send_byte

    bra @main_loop

.endproc

; ************************************************************************
; Normal interrupt handler.

irq_service:
    pha
    phx
    phy

    lda #%00010000
    bit VIA_IFR
    beq @not_serial_isr

    ;lda #'.'
    ;jsr serial_send_byte

    ; CB1 is set, which means our serial port has raised the interrupt.
    jsr serial_isr

@not_serial_isr:
    ; Generic clear interrupt function.
    lda VIA_T1CL
    lda VIA_T2CL
    lda VIA_SHIFT
    lda VIA_IFR
    lda VIA_PORT_A
    lda VIA_PORT_B

    ply
    plx
    pla
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

; Greeting also contains reset codes for terminal
greeting: .byte $1B, "c", $1B, "[2jLemon v0.1.2", $D, $0
prompt  : .byte "> ", $0
special : .byte "Special: ", $0
normal  : .byte "Normal : ", $0

; ************************************************************************
