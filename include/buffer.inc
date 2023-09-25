; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: buffer.inc
; Description: Macros for working with circular buffers.
;
; Copyright (c) 2023
; ************************************************************************
; Generic circular buffer structure.
;
.struct Buffer
    data .res 256
    read .res 1
    write .res 1
.endstruct

; ************************************************************************
; Initialize a buffer
; 
.macro buffer_init buffer
    stz buffer+Buffer::read
    stz buffer+Buffer::write
.endmacro

; ************************************************************************
; Gets the number of bytes in the buffer ready to be read.
;
; Sets Z flag if no bytes available.
;
.macro buffer_count buffer
    lda buffer+Buffer::write
    sec
    sbc buffer+Buffer::read
.endmacro

; ************************************************************************
; Gets the number of bytes that can still be written to the buffer.
;
; Has the added side effect of setting the Z flag if the buffer is full.
;
.macro buffer_capacity buffer
    buffer_count buffer
    sec
    sbc #255
.endmacro

; ************************************************************************
; Put a byte back at the read pointer so that it is the next character
; read from the buffer.
;
.macro buffer_put_back buffer
    ldx buffer+Buffer::read
    sta buffer+Buffer::data, x
    dec buffer+Buffer::read
.endmacro

; ************************************************************************
; Read a byte from the buffer and advance the read pointer.
;
.macro buffer_read_byte buffer
    ldx buffer+Buffer::read
    lda buffer+Buffer::data, x
    inc buffer+Buffer::read
.endmacro

; ************************************************************************
; Write a byte to the buffer and advance the write pointer.
;
.macro buffer_write buffer
    ldx buffer+Buffer::write
    sta buffer+Buffer::data, x
    inc buffer+Buffer::write
.endmacro

; ************************************************************************
