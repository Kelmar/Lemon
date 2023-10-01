; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: util.inc
; Description: Utility macros
;
; Copyright (c) 2023
; ************************************************************************

; Quickly multiplies value in A with ten.
; Does not preserve any registers.
;
.macro mul10_fast
    shl
    sta R0
    shl
    shl
    add R0
.endmacro

; ************************************************************************
