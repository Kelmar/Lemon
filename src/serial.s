; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: serial.s
; Description: Functions for working with 16C550C serial port.
;
; Copyright (c) 2023
; ************************************************************************

.include "zp.inc"
.include "buffer.inc"

; ************************************************************************

.segment "CODE"

.export serial_init

.export serial_recv_byte
.export serial_recv_byte_block
.export serial_put_back

.export serial_isr

.export serial_send_byte
.export serial_send_str
.export serial_send_buffer
.export serial_print_hex

; ************************************************************************

; Base address of the serial port.
.define SERIAL_BASE $8400

; Only when DLAB = 0
.define SERIAL_TRX       SERIAL_BASE + $00

; Only when DLAB = 0
.define SERIAL_INT_CTL   SERIAL_BASE + $01

; Only when DLAB = 1
.define SERIAL_DLA_LSB   SERIAL_BASE + $00

; Only when DLAB = 1
.define SERIAL_DLA_MSB   SERIAL_BASE + $01

; Read only
.define SERIAL_INT_STAT  SERIAL_BASE + $02

; Write only
.define SERIAL_FIFO_CTL  SERIAL_BASE + $02
.define SERIAL_LINE_CTL  SERIAL_BASE + $03
.define SERIAL_MOD_CTL   SERIAL_BASE + $04
.define SERIAL_LINE_STAT SERIAL_BASE + $05
.define SERIAL_MOD_STAT  SERIAL_BASE + $06
.define SERIAL_SCRATCH   SERIAL_BASE + $07

.define SERIAL_DLA_BIT   $80

; TODO: Pass this in as a parameter
; 8 data, 1 stop, odd parity
.define SERIAL_CONTROL_FLAGS %00001011

; ************************************************************************

; High water mark in bytes for setting flow control off.
; (We try to reserve a bit of extra room for calls to put_back)
.define HI_WATER_MARK 224

; Low water mark in bytes for setting flow control on.
.define LO_WATER_MARK 128

; ************************************************************************

.segment "UARTVARS"

; Receive buffer for UART data.
uart_recv: .tag Buffer

; ************************************************************************

.segment "CODE"

; ************************************************************************
; Initializes the UART
;
; Destroys: A

serial_init:
    ; Disable interrupts from 16550
    stz SERIAL_INT_CTL

    ; Clear out all flow control
    stz SERIAL_MOD_CTL

    ; Initialize the receive buffer
    buffer_init uart_recv

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

    ; Allow flow control again
    lda #%00001111
    sta SERIAL_MOD_CTL

    ; Enable receive interrupts
    lda #%00000001
    sta SERIAL_INT_CTL

    rts

; ************************************************************************
; Sends a single byte in A register to the UART
; Blocks until the UART's fifo is empty.

.proc serial_send_byte: near
    pha ; Save the byte

@tx_delay:
    ; Wait for any data in the TX FIFO to clear out.
    lda #$20
    and SERIAL_LINE_STAT
    beq @tx_delay

    pla
    sta SERIAL_TRX

    rts
.endproc

; ************************************************************************
; Reads a byte from the serial port's receive buffer without blocking.
; 
; If no byte is available then the carry flag is cleared.
;
; Otherwise the carry flag is set, and the A register will hold the byte.
;
; Byte is returned in A register
;
serial_recv_byte:
    buffer_count uart_recv
    beq @serial_empty

    cmp #LO_WATER_MARK
    bcs @no_enable_recv

    ; Turn flow on
    lda #%00000010
    ora SERIAL_MOD_CTL
    sta SERIAL_MOD_CTL

@no_enable_recv:
    buffer_read_byte uart_recv
    sec
    rts

@serial_empty:
    ;lda #'X'
    ;jsr serial_send_byte
    clc
    rts

; ************************************************************************
; Serial receive byte but block until we get one.
;
; Byte is returned in A register
;
serial_recv_byte_block:
    jsr serial_recv_byte
    bcs @got_byte

    ; Block until interrupt from serial port
    wai
    bra serial_recv_byte_block ; Retry read

@got_byte:
    rts

; ************************************************************************
; Puts byte in A back into the serial buffer.
;
; Sets the carry bit if the byte was added, clear if not (buffer full)
;

serial_put_back:
    pha
    buffer_capacity uart_recv
    bne @add_to_buffer
    pla
    clc
    rts

@add_to_buffer:
    pla
    buffer_put_back uart_recv
    sec
    rts

; ************************************************************************
; Serial port interrupt service routine.
;

serial_isr:
    lda #%00000001
    bit SERIAL_LINE_STAT
    bne @read_loop

    bra @check_send

@read_loop:
    ;lda #'.'
    ;jsr serial_send_byte

    buffer_capacity uart_recv
    beq @buffer_full

    cmp #HI_WATER_MARK
    bcc @read_byte

    ; Turn flow off
    lda #%11111101
    and SERIAL_MOD_CTL
    sta SERIAL_MOD_CTL

    bra @read_byte

@buffer_full:
    ; TODO: Turn off interrupts?

    bra @check_send
    
@read_byte:
    lda SERIAL_TRX
    buffer_write uart_recv

    lda #%00000001
    bit SERIAL_LINE_STAT
    bne @read_loop  ; Continue until we've read as much as we can.

@check_send:
    ; TODO: Push out send data here if ready to do so.

    rts

; ************************************************************************
; Sends a null terminated string to the UART.
; String is pointed to by the W0 register
; String cannot be longer than 255 bytes.
; Method blocks
;
; Destroys: A, Y, X

.proc serial_send_str: near
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
    rts
.endproc

; ************************************************************************
; Sends a byte buffer to the UART.
; Buffer is pointed to by the W0 register
; Buffer length is in the Y register.
; Method blocks
;
; Destroys: A

.proc serial_send_buffer: near
    phx
    PHR0_fast
    
    ; I'd kill for a nice DMA to do this. :3

    tya
    tax

    beq @tx_exit        ; No data to send

    ldy #0

@tx_delay:
    ; Wait for any data in the TX FIFO to clear out.
    lda #$20
    and SERIAL_LINE_STAT
    beq @tx_delay

    ; Not quite the full size of the FIFO
    lda #15
    sta R0

@tx_loop_send:
    lda (W0),y          ; Load next character
    sta SERIAL_TRX      ; Write character to TRX port.
    iny
    dex
    beq @tx_exit        ; Reached end of buffer, exit.
    dec R0
    beq @tx_delay       ; We've possibly filled the TX buffer, wait for it to empty.
    jmp @tx_loop_send

@tx_exit:

    PLR0
    plx
    rts
.endproc

; ************************************************************************
; Prints the A register as a 2-digit hex number
;
; Destroys: W0

serial_print_hex:
    phx
    phy

    ldx #<hexbytes
    stx W0
    ldx #>hexbytes
    stx W0 + 1

    tax ; Preserve A

    ror
    ror
    ror
    ror
    and #$0F

    tay
    lda (W0), y
    jsr serial_send_byte

    txa
    and #$0F

    tay
    lda (W0), y
    jsr serial_send_byte

    ply
    plx
    rts

; ************************************************************************

.segment "RODATA"

hexbytes:     .byte "0123456789ABCDEF"

; ************************************************************************
