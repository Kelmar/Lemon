; ************************************************************************
; Project: Lemon - Simple 6502 Monitor
; Author: Bryce Simonds
; License: BSD 3-Clause
; File: header.inc
; Description: Memory map and basic system layout.
;
; Copyright (c) 2023
; ************************************************************************

.memorymap
    DEFAULTSLOT 4

    ; Lower 32KByte is RAM
    SLOTSIZE $8000
    SLOT 0 $0000

    ; The upper 32KBytes are divided in to 8Kbyte regions.
    SLOTSIZE $2000
    ; VIA and devices memory map
    SLOT 1 $8000
    ; Empty bank
    SLOT 2 $A000
    ; Empty bank
    SLOT 3 $C000
    ; Start of ROM
    SLOT 4 $E000
.endme

.rombankmap
    BANKSTOTAL 1
    BANKSIZE $2000
    banks 1
.endro

; Just map all ASCII characters to their normal values.
; This doesn't really DO anything, but it makes the assembler stop copmlaining.
.asciitable
MAP 'A' = 65
.enda

; Fill empty space with with no op instructions
.emptyfill $EA

.bank 0 SLOT 4
.org 0

; ************************************************************************
