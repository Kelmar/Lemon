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
.def RAMBANK $00

; Address of ROM bank register
.def ROMBANK $01

; ************************************************************************
; Kernel scratch registers.

; 8-bit register
.def R0 $02

; 8-bit register
.def R1 $03

; 8-bit reigster
.def R2 $04

; 8-bit reigster
.def R3 $05

; 16-bit reigster
.def W0 $06

; 16-bit reigster
.def W1 $08

; 32-bit reigster
.def Q0 $0A

; A save space for stack manipulation
.def ASAV $0E

; ************************************************************************
; Push pull macros for scratch registers.

.MACRO PH8 ARGS reg
    sta ASAV
    lda reg
    pha
    lda ASAV
.ENDM

.MACRO PH16 ARGS reg
    sta ASAV
    lda reg
    pha
    lda reg + 1
    pha
    lda ASAV
.ENDM

; Push R0
.MACRO PHR0
    PH8 R0
.ENDM

; Push R1
.MACRO PHR1
    PH8 R1
.ENDM

; Push R2
.MACRO PHR2
    PH8 R2
.ENDM

; Push R3
.MACRO PHR3
    PH8 R4
.ENDM

; Push W0
.MACRO PHW0
    PH16 W0
.ENDM

; Push W1
.MACRO PHW1
    PH16 W1
.ENDM

; Push Q0
.MACRO PHQ0
    sta ASAV
    lda Q0
    pha
    lda Q0 + 1
    pha
    lda Q0 + 2
    pha
    lda Q0 + 3
    pha
    lda ASAV
.ENDM

.MACRO PL8 ARGS reg
    sta ASAV
    pla
    sta reg
    lda ASAV
.ENDM

.MACRO PL16 ARGS reg
    sta ASAV
    pla
    sta reg + 1
    pla
    sta reg
    lda ASAV
.ENDM

; Pull R0
.MACRO PLR0
    PL8 R0
.ENDM

; Pull R1
.MACRO PLR1
    PL8 R1
.ENDM

; Pull R2
.MACRO PLR2
    PL8 R2
.ENDM

; Pull R3
.MACRO PLR3
    PL8 R3
.ENDM

; Pull W0
.MACRO PLW0
    PL16 W0
.ENDM

; Pull W1
.MACRO PLW1
    PL16 W1
.ENDM

; Pull Q0
.MACRO PLQ0
    sta ASAV
    pla
    sta Q0 + 3
    pla
    sta Q0 + 2
    pla
    sta Q0 + 1
    pla
    sta Q0
    lda ASAV
.ENDM

; ************************************************************************
; Macros for manpulating word registers

; Load W0
.MACRO LDW0 ARGS addr
    sta ASAV
    lda #<addr
    sta W0
    lda #>addr
    sta W0 + 1
    lda ASAV
.ENDM

; Load W1
.MACRO LDW1 ARGS addr
    sta ASAV
    lda #<addr
    sta W1
    lda #>addr
    sta W1 + 1
    lda ASAV
.ENDM

; Store W0
.MACRO STW0 ARGS addr
    sta ASAV
    lda W0
    sta (addr)
    lda W0 + 1
    sta (addr + 1)
    lda ASAV
.ENDM

; Store W1
.MACRO STW1 ARGS addr
    sta ASAV
    lda W1
    sta (addr)
    lda W1 + 1
    sta (addr + 1)
    lda ASAV
.ENDM

; ************************************************************************
