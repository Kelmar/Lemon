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

; ************************************************************************
; Serial interrupt service routine
;
.import serial_isr

; ************************************************************************
; Initializes the UART
;
; Destroys: A
;
.import serial_init

; ************************************************************************
; Reads a byte from the serial port's receive buffer without blocking.
; 
; If no byte is available then the carry flag is cleared.
;
; Otherwise the carry flag is set, and the A register will hold the byte.
;
; Byte is returned in A register
;
.import serial_recv_byte

; ************************************************************************
; Serial receive byte but block until we get one.
;
; Byte is returned in A register
;
.import serial_recv_byte_block

; ************************************************************************
; Prints a Pascal string at W0 to the serial terminal
;
; Destroys: W0
;
.import serial_print_str

; ************************************************************************
; Puts byte in A back into the serial buffer.
;
; Sets the carry bit if the byte was added, clear if not (buffer full)
;
.import serial_put_back

; ************************************************************************
; Writes a single byte to the serial buffer.
;
; Method will block until there is free space to write to.
;
.import serial_write_byte

; ************************************************************************
; Writes a buffer at W0 to the serial port.
; Length of the buffer should be in Y register.
; 
; If writing would block, then the function tries to write as many bytes as
; it can and then returns the number of bytes sent in Y.
;
; The carry flag will be set if not all data could be sent.
;
; Destroys: R0
;
.import serial_write_async

; ************************************************************************
; Writes buffer at W0 to the serial port.
; Length of buffer should be in Y register.
;
; Blocks if the send buffer is full.
; 
; Destroys: W0, a, y
;
.import serial_write_block

; ************************************************************************
; Write a single byte in A to serial port.
; Blocks if FIFO is full.
;
; Destroys: X
;
.import serial_write_byte_block

; ************************************************************************
; Prints a Pascal string located at W0 to the serial terminal
;
; TODO: Remove later in favor of a more generalized approach.
;
; Destroys: W0
;
.import serial_print_str

; ************************************************************************
