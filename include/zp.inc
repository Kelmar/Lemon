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
; Parameter registers.

; 8-bit parameter
.define R0 $02

; 8-bit parameter
.define R1 $03

; 8-bit parameter
.define R2 $04

; 8-bit parameter
.define R3 $05

; 16-bit parameter
.define W0 $06

; 16-bit parameter
.define W1 $08

; 16-bit parameter
.define W2 $0A

; 32-bit parameter
.define Q0 $0C

; Scratch space for saving the A register.
.importzp TMP_A

; Scratch space for preserving Y register
.importzp TMP_Y

; Scratch space for preserving X register
.importzp TMP_X

; ************************************************************************

.macro LDW0_fast ptr
    lda #<ptr
    sta W0
    lda #>ptr
    sta W0 + 1
.endmacro

.macro LDW0 ptr
    pha
    LDW0_fast ptr
    pla
.endmacro

; ************************************************************************

.macro PHR0
    stx TMP_X
    sta TMP_A
    phx
    tsx
    lda R0
    sta $0100,x
    lda TMP_A
    ldx TMP_X
.endmacro

.macro PHR0_fast
    phx
    tsx
    lda R0
    sta $0100,x
.endmacro

.macro PLR0
    sta TMP_A
    pla
    sta R0
    lda TMP_A
.endmacro

; ************************************************************************
