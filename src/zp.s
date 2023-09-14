; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: zp.s
; Description: Zero page declarations
;
; Copyright (c) 2023
; ************************************************************************

.export TMP_A
.export TMP_Y
.export TMP_X

.segment "ZEROPAGE"

; Scratch space for preserving A register
TMP_A: .res 1

; Scratch space for preserving Y register
TMP_Y: .res 1

; Scratch space for preserving X register
TMP_X: .res 1

; ************************************************************************
