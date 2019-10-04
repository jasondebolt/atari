    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80
P0Height             byte         ; player sprite height
P1Height             byte         ; player sprite height
Player0YPos          byte         ; player sprite Y coordinate
Player1YPos          byte         ; player sprite Y coordinate
Player0XPos          byte         ; sprite X coordinate
Random               byte         ; random number generated to set enemy positions

    seg code
    org $F000
Reset:             ; Only gets called once.
    CLEAN_START    ; macro to clean memory and TIA
    ldx #$00       ; black background color
    stx COLUBK

    ; Apple
    lda #180
    sta Player0YPos ; Player0YPos = 180
    lda #9
    sta P0Height   ; P0Height = 9
    lda #50
    sta Player0XPos

    ; Banana
    lda #90
    sta Player1YPos
    lda #9
    sta P1Height

StartFrame:        ; Called 60 times per second
    lda #2
    sta VBLANK   ; on
    sta VSYNC    ; on

    sta WSYNC    ; strobe
    sta WSYNC    ; strobe
    sta WSYNC    ; strobe

    lda #0
    sta VSYNC     ; off


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations and tasks performed pre-VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda Player0XPos
    ldy #0
    jsr SetObjectXPos       ; set player0 horizontal position (1 WSYNC)

    sta WSYNC                ; wait until the WSYNC from the TIA
    sta HMOVE                ; apply horizontal offsets previously set

    REPEAT 35  ; Use 35 instead of 37 here b/c we used up 2 WYSNC's already
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK    ; off

    ldx #192

Scanline:          ; Called 192 times per frame, calls WSYNC 192 times
    txa
    sec            ; make sure carry flag is set. Always set the carry flag before you do a subtraction.
    sbc Player0YPos ; subtract sprite Y coordinate from the accumulator.
    cmp P0Height  ; are we inside the sprite height bounds?
    bcc LoadBitmap ; if result < SpriteHeight, call subroutine
    lda #0         ; else, set index to 0

LoadBitmap:        ; Called 192 times per frame (falls through and renders #%00000000 if Y positions do not match)
    tay
    lda P0Bitmap,Y ; load player bitmap slice of data

    ; Update TIA registers immediately after WSYNC!
    sta GRP0       ; set graphics for player 0 slice
    lda P0Color,Y  ; load player color from lookup table
    sta COLUP0     ; set color for player 0 slice

Scanline2:          ; Called 192 times per frame, calls WSYNC 192 times
    txa
    sec            ; make sure carry flag is set. Always set the carry flag before you do a subtraction.
    sbc Player1YPos ; subtract sprite Y coordinate from the accumulator.
    cmp P1Height  ; are we inside the sprite height bounds?
    bcc LoadBitmap2 ; if result < SpriteHeight, call subroutine
    lda #0         ; else, set index to 0

LoadBitmap2:        ; Called 192 times per frame (falls through and renders #%00000000 if Y positions do not match)
    tay
    lda P1Bitmap,Y ; load player bitmap slice of data

    ; Update TIA registers immediately after WSYNC!
    sta GRP1       ; set graphics for player 0 slice
    lda P1Color,Y  ; load player color from lookup table
    sta COLUP1     ; set color for player 0 slice

    sta WSYNC      ; wait for next scanline
    dex            ; This gets called on every ScanLine call.
    bne Scanline   ; repeat next scanline until finished



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK               ; turn VBLANK on
    REPEAT 30
       sta WSYNC             ; display 30 lines of VBLANK Overscan
    REPEND
    lda #0
    sta VBLANK               ; turn off VBLANK


    dec Player0YPos
    dec Player1YPos
    dec Player1YPos


    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle object horizontal position with fine offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A is the target x-coordinate position in pixels of our object
;; Y is the object type (0:player0, 1:player1, 2:missile0, 3:missile1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetObjectXPos subroutine
    sta WSYNC                ; start a fresh new scanline
    sec                      ; make sure carry-flag is set before subtracion
.Div15Loop
    sbc #15                  ; subtract 15 from accumulator
    bcs .Div15Loop           ; loop until carry-flag is clear
    eor #7                   ; handle offset range from -8 to 7
    asl
    asl
    asl
    asl                      ; four shift lefts to get only the top 4 bits
    sta HMP0,Y               ; store the fine offset to the correct HMxx
    sta RESP0,Y              ; fix object position in 15-step increment
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to generate a Linear-Feedback Shift Register random number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The new horizontal x-position is generated using a random number generator.
;; The algorithm uses a Fibonacci Linear-Feedback Shift Register, combining
;; shift and bit operations to generate a new 8-bit number.
;; To get a sane value for the x-position, we also perform the following:
;;   - divide the random number by 4 to cap the upper limit of the values.
;;   - add 30 to compensate for the pixels we have for the left playfield.
;; The new vertical y-position is set to the top of the screen.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomPlayer0Pos subroutine
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random               ; performs a series of shifts and bit operations

    lsr
    lsr                      ; divide random number by 4 with two right shifts
    sta Player0XPos           ; and save it in the variable Player0Pos
    lda #30
    adc Player0XPos           ; adds 30 + Player0Pos to compensate for left PF
    sta Player0XPos           ; and sets the new value to the enemy x-position

    lda #96
    sta Player0YPos           ; set the y-position to the top of the screen

    rts


P0Bitmap
    .byte #%00000000
    .byte #%00101000
    .byte #%01110100
    .byte #%11111010
    .byte #%11111010
    .byte #%11111010
    .byte #%11111110
    .byte #%01101100
    .byte #%00110000
P0Color
    .byte #$00
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$42
    .byte #$42
    .byte #$44
    .byte #$D2
P1Bitmap
    .byte #%00000000;$00
    .byte #%00000110;$1A
    .byte #%00001100;$1E
    .byte #%00011100;$1E
    .byte #%00111000;$1E
    .byte #%00111000;$1E
    .byte #%00111000;$1E
    .byte #%00011100;$1E
    .byte #%00001000;$F8
P1Color
    .byte #$00;
    .byte #$1A;
    .byte #$1E;
    .byte #$1E;
    .byte #$1E;
    .byte #$1E;
    .byte #$1E;
    .byte #$1E;
    .byte #$F8;

    org $FFFC
    .word Reset
    .word Reset
