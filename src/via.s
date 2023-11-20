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
.export via_timer_isr
.export delay

; ************************************************************************

; Set for one 1ms with a 1MHz clock
.define TIMER_COUNT $03E8

; ************************************************************************

via_init:
    ; Disable all interrupts
    lda #%01111111
    sta VIA_IER

    ; Set pin 6 as input on port B, all other pins are output.
    lda #%10111111
    sta VIA_DDR_B

    ; Set port A to output
    lda #$FF
    sta VIA_DDR_A

    ; Make all outputs low
    stz VIA_PORT_A
    stz VIA_PORT_B

    ; Interrupt every 1ms
    lda #<TIMER_COUNT
    sta VIA_T2CL
    lda #>TIMER_COUNT
    sta VIA_T2CH

    ; Setup pulse counting on Timer 2 from PB6
    lda #%00100000
    sta VIA_ACR

    ; Enable interrupts from serial port.
    ; (Later we'll put the serial port on a PLD independent of the VIA)

    ; Tell VIA to trigger interrupt on high edge of CB1
    lda #%00010000
    sta VIA_PCR

    ; Turn on interrupts from VIA on CB1 & Timer2
    lda #%10110000
    sta VIA_IER

    rts

; ************************************************************************
; Handle timer ISR
via_timer_isr:
    lda VIA_IFR

    inc SYS_TICKS
    bcc @inc_done
    inc SYS_TICKS + 1
    bcc @inc_done
    inc SYS_TICKS + 2
    bcc @inc_done
    inc SYS_TICKS + 3

@inc_done:
    ; TODO: Load T2 count here to find out how much we've drifted.

    ; Interrupt every 1ms
    lda #<TIMER_COUNT
    sta VIA_T2CL
    lda #>TIMER_COUNT
    sta VIA_T2CH
    rts

; ************************************************************************
; Delay's for the given number of miliseconds in A
;
delay:
    PHR0

    php
    clc
    adc SYS_TICKS 
    sta R0 ; Store target value into R0

    ; Make sure global interrupts are enabled
    cli

@delay_loop:
    wai ; Wait for an interrupt

    lda SYS_TICKS
    cmp R0
    bne @delay_loop

    plp

    PLR0

    rts

; ************************************************************************
