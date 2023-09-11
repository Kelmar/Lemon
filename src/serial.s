; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: serial.s
; Description: Functions for working with 16550C serial port.
;
; Copyright (c) 2023
; ************************************************************************

.include "header.inc"
.include "zp.inc"

.section "serial" free

; ************************************************************************

; Base address of the serial port.
.def SERIAL_BASE $8400

; Only when DLAB = 0
.def SERIAL_TRX       SERIAL_BASE + $00

; Only when DLAB = 0
.def SERIAL_INT_CTL   SERIAL_BASE + $01

; Only when DLAB = 1
.def SERIAL_DLA_LSB   SERIAL_BASE + $00

; Only when DLAB = 1
.def SERIAL_DLA_MSB   SERIAL_BASE + $01

; Read only
.def SERIAL_INT_STAT  SERIAL_BASE + $02

; Write only
.def SERIAL_FIFO_CTL  SERIAL_BASE + $02
.def SERIAL_LINE_CTL  SERIAL_BASE + $03
.def SERIAL_MOD_CTL   SERIAL_BASE + $04
.def SERIAL_LINE_STAT SERIAL_BASE + $05
.def SERIAL_MOD_STAT  SERIAL_BASE + $06
.def SERIAL_SCRATCH   SERIAL_BASE + $07

.def SERIAL_DLA_BIT   $80

; TODO: Pass this in as a parameter
.def SERIAL_CONTROL_FLAGS %00001011

; ************************************************************************
; Initializes the UART

serial_init:
    pha

    ; Disable interrupts from 16550
    stz SERIAL_INT_CTL

    ; Enable and reset FIFO
    lda #%00000111
    sta SERIAL_FIFO_CTL

    ; Setup bit pattern, and enable writing to divisor latches
    ; Set 8-bits, one stop bit, odd parity
    lda #(SERIAL_CONTROL_FLAGS | SERIAL_DLA_BIT)
    sta SERIAL_LINE_CTL

    ; TODO: Pass this in as a parameter
    ; Setup for 19200 buad
    stz SERIAL_DLA_MSB
    lda #6
    sta SERIAL_DLA_LSB

    ; Clear DLA bit so we can read/write data
    lda #SERIAL_CONTROL_FLAGS
    sta SERIAL_LINE_CTL

    pla
    rts

; ************************************************************************
; Sends a single byte in A register to the UART
; Blocks until the UART's fifo is empty.

serial_send_byte:
    pha ; Save the byte

@tx_delay:
    ; Wait for any data in the TX FIFO to clear out.
    lda #$20
    and SERIAL_LINE_STAT
    beq @tx_delay

    pla
    sta SERIAL_TRX

    rts

; ************************************************************************
; Reads a single byte from the UART into the A register
; Does not block, if a character is read then 1 is returned in the Y register
; Other wise 0 is returned to indicate no character read.

serial_recv_byte_async:
    lda #$01
    and SERIAL_LINE_STAT
    beq @no_char

    lda SERIAL_TRX
    ldy #1

    jmp @done

@no_char:
    lda #0
    ldy #0

@done:
    rts

; ************************************************************************
; Receive a byte from the UART into the A register
; Blocks until byte is received.

serial_recv_byte_sync:
    lda #$01
    and SERIAL_LINE_STAT
    beq serial_recv_byte_sync ; Loop until we have byte

    lda SERIAL_TRX  ; Read byte and return
    rts

; ************************************************************************
; Sends a null terminated string to the UART.
; String is pointed to by the W0 register
; String cannot be longer than 255 bytes.
; Method blocks

serial_send_str:
    pha
    phy
    phx

    ldy #0

@tx_delay:
    ; Wait for any data in the TX FIFO to clear out.
    lda #$20
    and SERIAL_LINE_STAT
    beq @tx_delay

    ; Not quite the full size of the FIFO
    ldx #15

@tx_loop_send:
    lda (W0),y          ; Load next character
    beq @tx_exit        ; Exit if we've hit the NULL character
    sta SERIAL_TRX      ; Write character to TRX port.
    iny
    dex
    beq @tx_delay       ; We've possibly filled the TX buffer, wait for it to empty.
    jmp @tx_loop_send

@tx_exit:

    plx
    ply
    pla
    rts

; ************************************************************************
; Sends a byte buffer to the UART.
; Buffer is pointed to by the W0 register
; Buffer length is in the Y register.
; Method blocks

serial_send_buffer:
    pha
    phy
    phx

    PHR0
    sty R0

    beq @tx_exit        ; No data to send

    ldy #0

@tx_delay:
    ; Wait for any data in the TX FIFO to clear out.
    lda #$20
    and SERIAL_LINE_STAT
    beq @tx_delay

    ; Not quite the full size of the FIFO
    ldx #15

@tx_loop_send:
    lda (W0),y          ; Load next character
    sta SERIAL_TRX      ; Write character to TRX port.
    iny
    dec R0
    beq @tx_exit        ; Reached end of buffer, exit.
    dex
    beq @tx_delay       ; We've possibly filled the TX buffer, wait for it to empty.
    jmp @tx_loop_send

@tx_exit:

    PLR0

    plx
    ply
    pla
    rts

; ************************************************************************

.ends

; ************************************************************************
