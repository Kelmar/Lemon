; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: via_imports.inc
; Description: Imports for VIA functions
;
; Copyright (c) 2023
; ************************************************************************

.segment "CODE"

.import via_init
.import via_timer_isr
.import delay

; ************************************************************************
