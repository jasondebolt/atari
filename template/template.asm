    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80
P0Height   byte    ; player sprite height
PlayerYPos byte    ; player sprite Y coordinate
    seg code
    org $F000
Reset:
    CLEAN_START    ; macro to clean memory and TIA
    ldx #$00       ; black background color
    stx COLUBK
    lda #180
    sta PlayerYPos ; PlayerYPos = 180
    lda #9
    sta P0Height   ; P0Height = 9

StartFrame:
    lda #2
    sta VBLANK   ; on
    sta VSYNC    ; on

    sta WSYNC    ; strobe
    sta WSYNC    ; strobe
    sta WSYNC    ; strobe

    lda #0
    sta VSYNC     ; off

    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe
    sta WSYNC     ; strobe

    lda #0
    sta VBLANK    ; off

    ldx #192

Scanline:
    txa
    sec            ; make sure carry flag is set. Always set the carry flag before you do a subtraction.
    sbc PlayerYPos ; subtract sprite Y coordinate from the accumulator.
    cmp P0Height  ; are we inside the sprite height bounds?
    bcc LoadBitmap ; if result < SpriteHeight, call subroutine
    lda #0         ; else, set index to 0

LoadBitmap:
    tay
    lda P0Bitmap,Y ; load player bitmap slice of data

    ; Update TIA registers immediately after WSYNC!
    sta WSYNC      ; wait for next scanline
    sta GRP0       ; set graphics for player 0 slice
    lda P0Color,Y  ; load player color from lookup table
    sta COLUP0     ; set color for player 0 slice

    dex
    bne Scanline   ; repeat next scanline until finished


Overscan:
    lda #2
    sta VBLANK        ; on
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe
    sta WSYNC         ; strobe

    dec PlayerYPos
    jmp StartFrame


P0Bitmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000
P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2

    org $FFFC
    .word Reset
    .word Reset
