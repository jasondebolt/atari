    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with VCS register memory mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare variables starting from memory address $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

JetXPos             byte            ; Player0 x-position
JetYPos             byte            ; Player0 y-position
BomberXPos          byte            ; Player1 x-position
BomberYPos          byte            ; Player1 y-position
JetSpritePtr        word            ; pointer to player0 sprite lookup table
JetColorPtr         word            ; pointer to player0 color lookup table
BomberSpritePtr     word            ; pointer to player1 sprite lookup table
BomberColorPtr      word            ; pointer to player1 color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9                      ; player0 sprite height (# rows in lookup table)
BOMBER_HEIGHT = 9                   ; player1 sprite height (# rows in lookup table)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code at memory address $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000

Reset:
    CLEAN_START                      ; call macro to reset memory and registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialized RAM variables and also TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10
    sta JetYPos                      ; JetYPos = 10
    lda #60
    sta JetXPos                      ; JetXPos = 60
    lda #83
    sta BomberYPos                   ; BomberYPos = 83
    lda #54
    sta BomberXPos                   ; BomberYPos = 54

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialized the pointers to the correct lookup table addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<JetSprite
    sta JetSpritePtr                  ; lo-byte pointer for jet sprite lookup table
    lda #>JetSprite
    sta JetSpritePtr+1                ; hi-byte pointer for jet sprite lookup table

    lda #<JetColor
    sta JetColorPtr                  ; lo-byte pointer for jet color lookup table
    lda #>JetColor
    sta JetColorPtr+1                ; hi-byte pointer for jet color lookup table

    lda #<BomberSprite
    sta BomberSpritePtr              ; lo-byte pointer for bomber sprite lookup table
    lda #>BomberSprite
    sta BomberSpritePtr+1            ; hi-byte pointer for bomber sprite lookup table

    lda #<BomberColor
    sta BomberColorPtr               ; lo-byte pointer for bomber color lookup table
    lda #>BomberColor
    sta BomberColorPtr+1             ; hi-byte pointer for bomber color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the main display loop and frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK                       ; Turn on VBLANK
    sta VSYNC                        ; Turn on VSYNC
    REPEAT 3
        sta WSYNC                    ; Display the 3 recommended lines of VSYNC
    REPEND
    lda #0
    sta VSYNC                        ; Turn off VSYNC
    REPEAT 37
        sta WSYNC                    ; Display the 37 recommended lines of VSYNC
    REPEND
    sta VBLANK                       ; Turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the 96 visible scanlines of our main game (because 2-line kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    lda #$84
    sta COLUBK                       ; Set color background to blue
    lda #$c2
    sta COLUPF                       ; set playfield/gress color to green
    lda #%00000001
    sta CTRLPF                       ; enable playfield reflection
    lda #$F0
    sta PF0                          ; Setting PFO bit pattern
    lda #$FC
    sta PF1                          ; Setting PF1 bit pattern
    lda #0
    sta PF2                          ; Setting PF2 bit pattern
    ldx #96                         ; X counts the number of remaining scanlines
.GameLineLoop:
.AreWeInsideJetSprite:
    txa                             ; transfer X to a
    sec                             ; make sure carry flag is set before subtraction
    sbc JetYPos                     ; subtract sprite Y-coorindate
    cmp JET_HEIGHT                  ; are we inside the sprite height bounds?
    bcc .DrawSpriteP0               ; if result < SpriteHeight, call the draw routine
    lda #0                          ; else, set lookup index to zero
.DrawSpriteP0:
    tay                             ; load Y so we can work with the pointer
    lda (JetSpritePtr),Y            ; load player0 bitmap data from lookup table
    sta WSYNC                       ; wait for scanline
    sta GRP0                        ; set graphics for player0
    lda (JetColorPtr),Y             ; Load player color from lookup table
    sta COLUP0

.AreWeInsideBomberSprite:
    txa                             ; transfer X to a
    sec                             ; make sure carry flag is set before subtraction
    sbc BomberYPos                  ; subtract sprite Y-coorindate
    cmp BOMBER_HEIGHT               ; are we inside the sprite height bounds?
    bcc .DrawSpriteP1               ; if result < SpriteHeight, call the draw routine
    lda #0                          ; else, set lookup index to zero
.DrawSpriteP1:
    tay                             ; load Y so we can work with the pointer

    lda #%00000101
    sta NUSIZ1                      ; stretch player 1 sprite

    lda (BomberSpritePtr),Y         ; load player1 bitmap data from lookup table
    sta WSYNC                       ; wait for scanline
    sta GRP1                        ; set graphics for player1
    lda (BomberColorPtr),Y             ; Load player color from lookup table
    sta COLUP1

    dex
    bne .GameLineLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK                       ; Turn VBLANK on again
    REPEAT 30
        sta WSYNC                    ; Display 30 recommended lines of VBLANK Overscan
    REPEND
    lda #0
    sta VBLANK                       ; Turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop back to start a brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame                     ; Continue to display the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;---Graphics Data from PlayerPal 2600---

JetSprite
        .byte #%00000000;$00
        .byte #%00101000;$32
        .byte #%11111110;$0E
        .byte #%01111100;$0E
        .byte #%00111000;$0E
        .byte #%00111000;$0E
        .byte #%00010000;$AE
        .byte #%00010000;--
        .byte #%00010000;--
JetSpriteTurn
        .byte #%00000000;$00
        .byte #%00101000;$32
        .byte #%01111100;$0E
        .byte #%00111000;$0E
        .byte #%00111000;$0E
        .byte #%00010000;$0E
        .byte #%00010000;$AE
        .byte #%00010000;--
        .byte #%00010000;--
BomberSprite
        .byte #%00000000;$00
        .byte #%00010000;$00
        .byte #%00010000;$40
        .byte #%01010100;$40
        .byte #%01111100;$40
        .byte #%11111110;$40
        .byte #%01010100;$30
        .byte #%00010000;$40
        .byte #%00111000;$40
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

JetColor
        .byte #$00;
        .byte #$32;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$AE;
        .byte #$0E;
        .byte #$0E;
JetColorTurn
        .byte #$00;
        .byte #$32;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$AE;
        .byte #$0E;
        .byte #$0E;
BomberColor
        .byte #$00;
        .byte #$36;
        .byte #$36;
        .byte #$0E;
        .byte #$40;
        .byte #$40;
        .byte #$30;
        .byte #$40;
        .byte #$40;
;---End Color Data---


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC                         ; Move to position $FFFC
    word Reset                        ; Write 2 bytes with the program reset address
    word Reset                        ; Write 2 bytes with the interruption vector
