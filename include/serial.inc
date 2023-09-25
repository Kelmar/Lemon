; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: serial.inc
; Description: Imports for serial.s
;
; Copyright (c) 2023
; ************************************************************************

.segment "CODE"

.import serial_isr

; Initializes the UART
;
; Destroys: A
;
.import serial_init

; Sends a single byte in A register to the UART
; Blocks until the UART's fifo is empty.
;
.import serial_send_byte

; Reads a byte from the serial port's receive buffer without blocking.
; 
; If no byte is available then the carry flag is cleared.
;
; Otherwise the carry flag is set, and the A register will hold the byte.
;
; Byte is returned in A register
;
.import serial_recv_byte

; Serial receive byte but block until we get one.
;
; Byte is returned in A register
;
.import serial_recv_byte_block

; Puts byte in A back into the serial buffer.
;
; Sets the carry bit if the byte was added, clear if not (buffer full)
;
.import serial_put_back

; Sends a null terminated string to the UART.
; String is pointed to by the W0 register
; String cannot be longer than 255 bytes.
; Method blocks
;
; Destroys: A, Y, X
;
.import serial_send_str

; Sends a byte buffer to the UART.
; Buffer is pointed to by the W0 register
; Buffer length is in the Y register.
; Method blocks
;
; Destroys: A, Y, X
; 
.import serial_send_buffer

; Sends the A register as a 2-digit hex number
;
; Destroys: W0
.import serial_print_hex

; ************************************************************************
