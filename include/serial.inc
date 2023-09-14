; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: serial.inc
; Description: Imports for serial.s
;
; Copyright (c) 2023
; ************************************************************************

; Initializes the UART
;
; Destroys: A
;
.import serial_init

; Sends a single byte in A register to the UART
; Blocks until the UART's fifo is empty.
;
.import serial_send_byte

; Reads a single byte from the UART into the A register
; Does not block, if a character is read then 1 is returned in the Y register
; Otherwise 0 is returned to indicate no character read.
;
.import serial_recv_byte_async

; Receive a byte from the UART into the A register
; Blocks until byte is received.
;
.import serial_recv_byte_sync

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
