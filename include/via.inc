; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: via.inc
; Description: Include for primary VIA
;
; Copyright (c) 2023
; ************************************************************************

.define VIA_BASE $8000

.define VIA_PORT_B VIA_BASE + $0
.define VIA_PORT_A VIA_BASE + $1
.define VIA_DDR_B  VIA_BASE + $2
.define VIA_DDR_A  VIA_BASE + $3

.define VIA_T1CL   VIA_BASE + $4
.define VIA_T1CH   VIA_BASE + $5
.define VIA_T1LL   VIA_BASE + $6
.define VIA_T1LH   VIA_BASE + $7

.define VIA_T2CL   VIA_BASE + $8
.define VIA_T2CH   VIA_BASE + $9

.define VIA_SHIFT  VIA_BASE + $A

.define VIA_ACR    VIA_BASE + $B
.define VIA_PCR    VIA_BASE + $C
.define VIA_IFR    VIA_BASE + $D
.define VIA_IER    VIA_BASE + $E

; ************************************************************************
