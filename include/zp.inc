; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: zp.inc
; Description: Definitions for shared zero page registers.
;
; Copyright (c) 2023
; ************************************************************************

; RAM and ROM banks not yet implemented.

; Address of RAM bank register
.define RAMBANK $00

; Address of ROM bank register
.define ROMBANK $01

; ************************************************************************
; Kernel scratch registers.

; 8-bit register
.define R0 $02

; 8-bit register
.define R1 $03

; 8-bit reigster
.define R2 $04

; 8-bit reigster
.define R3 $05

; 16-bit reigster
.define W0 $06

; 16-bit reigster
.define W1 $08

; 32-bit reigster
.define Q0 $0A

; A save space for stack manipulation
.define ASAV $0E

; ************************************************************************
