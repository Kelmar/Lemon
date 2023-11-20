; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: zp.inc
; Description: Definitions for shared zero page registers.
;
; Copyright (c) 2023
; ************************************************************************

; The following register are defined at fixed locations for other programs 
; to be able to use as well.

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

; 16-bit parameter
.define W3 $0C

; 32-bit parameter
.define Q0 $0E

; 32-bit parameter
.define Q1 $12

; 32-bit - System tick counter.
.define SYS_TICKS $16

; ************************************************************************

; We let the assembler decide where these are, these are used as scratch
; space for various operations.

; Scratch space for saving the A register.
.importzp TMP_A

; Scratch space for preserving Y register
.importzp TMP_Y

; Scratch space for preserving X register
.importzp TMP_X

; ************************************************************************

.macro LD_word_fast wd, ptr
    lda #<ptr
    sta wd
    lda #>ptr
    sta wd + 1
.endmacro

.macro PH_word_fast wd
    lda wd
    pha
    lda wd + 1
    pha
.endmacro

.macro PL_word_fast wd
    pla
    sta wd + 1
    pla
    sta wd
.endmacro

; ************************************************************************

.macro LDW0_fast ptr
    LD_word_fast W0, ptr
.endmacro

.macro LDW0 ptr
    sta TMP_A
    LD_word_fast W0, ptr
    lda TMP_A
.endmacro

.macro PHW0_fast
    PH_word_fast W0
.endmacro

.macro PLW0_fast
    PL_word_fast W0
.endmacro

.macro LDW1_fast ptr
    LD_word_fast W1, ptr
.endmacro

.macro LDW1 ptr
    sta TMP_A
    LD_word_fast W1, ptr
    lda TMP_A
.endmacro

.macro PHW1_fast
    PH_word_fast W1
.endmacro

.macro PLW1_fast
    PL_word_fast W1
.endmacro

; ************************************************************************

.macro PH_byte_fast breg
    lda breg
    pha
.endmacro

.macro PH_byte breg
    sta TMP_A
    PH_byte_fast breg
    lda TMP_A
.endmacro

.macro PL_byte_fast breg
    pla
    sta breg
.endmacro

.macro PL_byte breg
    sta TMP_A
    PL_byte_fast breg
    lda TMP_A
.endmacro

; ************************************************************************

.macro PHR0_fast
    PH_byte_fast R0
.endmacro

.macro PHR0
    PH_byte R0
.endmacro

.macro PLR0
    PL_byte R0
.endmacro

.macro PLR0_fast
    PL_byte_fast R0
.endmacro

.macro PHR1_fast
    PH_byte_fast R1
.endmacro

.macro PLR1_fast
    PH_byte_fast R1
.endmacro

; ************************************************************************
