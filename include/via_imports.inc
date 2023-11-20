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

; ************************************************************************
; Initializes the VIA for our use.
; 
; Port A - All output
; Port B - All (except PB6 see below) output
;
; This sets up a periodic timer triggered from the PB6 pin.
; Interrupts from CB1 which come in from the 16C550C.
;
.import via_init

; ************************************************************************
; Handles timer ISR
;
.import via_timer_isr

; ************************************************************************
; Delay's for the given number of miliseconds in A
;
.import delay

; ************************************************************************
