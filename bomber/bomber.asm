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
Score               byte            ; 2-digit score stored as BCD
Timer               byte            ; 2-digit timer stored as BCD. Placing the timer right after the score allows us to reference it easier
Temp                byte            ; auxillary variable to store temp score values.
OnesDigitOffset     word            ; Lookup table offset for the score 1's digit.
TensDigitOffset     word            ; Lookup table offset for the score 10's digit.
JetSpritePtr        word            ; pointer to player0 sprite lookup table
JetColorPtr         word            ; pointer to player0 color lookup table
BomberSpritePtr     word            ; pointer to player1 sprite lookup table
BomberColorPtr      word            ; pointer to player1 color lookup table
JetAnimationOffset  byte            ; player0 sprite frame offset for animation
Random              byte            ; random number generated to set enemy position
ScoreSprite         byte            ; store the sprite bit pattern for the score
TimerSprite         byte            ; store the sprite bit pattern for the timer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9                      ; player0 sprite height (# rows in lookup table)
BOMBER_HEIGHT = 9                   ; player1 sprite height (# rows in lookup table)
DIGITS_HEIGHT = 5                   ; scoreboard to generate random bomber x-position

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
    lda #68
    sta JetXPos                      ; JetYPos = 10
    lda #10
    sta JetYPos                      ; JetXPos = 60
    lda #62
    sta BomberXPos                   ; BomberYPos = 83
    lda #83
    sta BomberYPos                   ; BomberYPos = 54
    lda #%11010100
    sta Random                       ; Random = $D4 (This is a seed value)
    lda #0
    sta Score
    sta Timer                        ; Score = Timer = 0

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
;; Calculations and tasks performed in the pre-VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda JetXPos
    ldy #0
    jsr SetObjectXPos                ; set player0 horizontal position

    lda BomberXPos
    ldy #1
    jsr SetObjectXPos               ; set player1 horizontal position

    jsr CalculateDigitOffset        ; Calculates scoreboard digits lookup table offset. Whenever you jump, it's going to load variables.

    sta WSYNC
    sta HMOVE                       ; apply the horizontal offset previously set

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the scoreboard lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0                          ; clear the TIA registers before each new frame
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    lda #$1c                        ; Sets playfield/scoreboard color to white
    sta COLUPF
    lda #%00000000
    sta CTRLPF                      ; Disables playfield reflection

    ldx #DIGITS_HEIGHT              ; start x counter with 5 (height of digits)

.ScoreDigitLoop:
    ldy TensDigitOffset             ; get the tens digit offset for the Score
    lda Digits,Y                    ; Load the bit pattern from lookup table
    and #$F0                        ; Mask/remove the graphics for the ones digit
    sta ScoreSprite                 ; Save the

    ldy OnesDigitOffset             ; Get the ones digit offset from the score
    lda Digits,Y                    ; Load the digit bit pattern from the lookup table
    and #$0F                        ; Mask/remove the graphics for the tens digit

    ora ScoreSprite                 ; Merge it with the saved tens digit sprite
    sta ScoreSprite                 ; And save it.

    sta WSYNC                       ; Wait for the end of scanline
    sta PF1                         ; Update the playfield to display the Score sprite

    ldy TensDigitOffset+1           ; Get the left digit offset for the Timer
    lda Digits,Y                    ; Load the digit pattern from the lookup table
    and #$F0                        ; Mask/remove the graphics for the ones digit
    sta TimerSprite                 ; Save the timer tens digit pattern into a variable

    ldy OnesDigitOffset+1           ; Get the ones digit offset for the Timer
    lda Digits,Y                    ; Load the digit pattern from the lookup table
    and #$0F                        ; Mask/remove the graphics for the tens digit
    ora TimerSprite                 ; Merge with the saved tens  digit graphics
    sta TimerSprite

    jsr Sleep12Cycles               ; Wastes some cycles

    sta PF1                         ; update playfield for Timer display
    ldy ScoreSprite                 ; Preload for the next scanline
    sta WSYNC

    sty PF1                         ; update playfield for the ScoreDisplay
    inc TensDigitOffset
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1           ; Increment all for the next line of digit data
    jsr Sleep12Cycles               ; Waste some cycles again

    dex                             ; X--
    sta PF1                         ; Update the playfield for the Timer display
    bne .ScoreDigitLoop             ; if dex !=0, then branch to ScoreDigitLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the remaining visible scanlines of our main game (2-line kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    lda #$84
    sta COLUBK               ; set background/river color to blue
    lda #$C2
    sta COLUPF               ; set playfield/grass color to green
    lda #%00000001
    sta CTRLPF               ; enable playfield reflection
    lda #$F0
    sta PF0                  ; setting PF0 bit pattern
    lda #$FC
    sta PF1                  ; setting PF1 bit pattern
    lda #0
    sta PF2                  ; setting PF2 bit pattern

    ldx #84                  ; X counts the number of remaining scanlines
.GameLineLoop:
.AreWeInsideJetSprite:
    txa                      ; transfer X to A
    sec                      ; make sure carry flag is set before subtraction
    sbc JetYPos              ; subtract sprite Y-coordinate
    cmp JET_HEIGHT           ; are we inside the sprite height bounds?
    bcc .DrawSpriteP0        ; if result < SpriteHeight, call the draw routine
    lda #0                   ; else, set lookup index to zero
.DrawSpriteP0:
    clc                      ; clear carry flag before addition
    adc JetAnimationOffset        ; jump to correct sprite frame address in memory
    tay                      ; load Y so we can work with the pointer
    lda (JetSpritePtr),Y     ; load player0 bitmap data from lookup table
    sta WSYNC                ; wait for scanline
    sta GRP0                 ; set graphics for player0
    lda (JetColorPtr),Y      ; load player color from lookup table
    sta COLUP0               ; set color of player 0


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

    lda #0
    sta JetAnimationOffset

    sta WSYNC                ; wait for a scanline

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
;; Process joystick input for player 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000                   ; player 0 joystick up
    bit SWCHA
    bne CheckP0Down                  ; if bit pattern doesn't match, bypass Up block
    inc JetYPos

CheckP0Down:
    lda #%00100000                   ; player 0 joystick up
    bit SWCHA
    bne CheckP0Left                  ; if bit pattern doesn't match, bypass Down block
    dec JetYPos

CheckP0Left:
    lda #%01000000                   ; player 0 joystick up
    bit SWCHA
    bne CheckP0Right                 ; if bit pattern doesn't match, bypass Left block
    dec JetXPos
    lda JET_HEIGHT                   ; 9
    sta JetAnimationOffset           ; set animation offset to the second frame

CheckP0Right:
    lda #%10000000                   ; player 0 joystick up
    bit SWCHA
    bne EndInputCheck                ; if bit pattern doesn't match, bypass Right block
    inc JetXPos
    lda JET_HEIGHT                   ; 9
    sta JetAnimationOffset           ; set animation offset to the second frame

EndInputCheck:                       ; fallback when no input was performed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations to update position for next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateBomberPosition:
    lda BomberYPos
    clc
    cmp #0                            ; compare bomber y-position with 0
    bmi .ResetBomberPosition          ; if it is < 0, then reset y-position for next frame
    dec BomberYPos                    ; else, decrement enemy y-position for next frame
    jmp EndPositionUpdate
.ResetBomberPosition
    jsr GetRandomBomberPosition       ; Calls subroutine for random x-position
    inc Score                         ; after each new enemy respawns, increment Score
    inc Timer                         ; after each new enemy respawns, increment Timer

EndPositionUpdate:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for object collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckCollisionP0P1:
    lda #%10000000           ; CXPPMM bit 7 detects P0 and P1 collision
    bit CXPPMM               ; check CXPPMM bit 7 with the above pattern
    bne .CollisionP0P1       ; if collision between P0 and P1 happened, branch
    jmp CheckCollisionP0PF   ; else, skip to next check
.CollisionP0P1:
    jsr GameOver             ; call GameOver subroutine

CheckCollisionP0PF:
    lda #%10000000           ; CXP0FB bit 7 detects P0 and PF collision
    bit CXP0FB               ; check CXP0FB bit 7 with the above pattern
    bne .CollisionP0PF       ; if collision P0 and PF happened, branch
    jmp EndCollisionCheck    ; else, skip to next check
.CollisionP0PF:
    jsr GameOver             ; call GameOver subroutine

EndCollisionCheck:           ; fallback
    sta CXCLR                ; clear all collision flags before the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop back to start a brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame                     ; Continue to display the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle object horizontal position with fine offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A is the target x-coorindate position in pixels of our object
;; Y is the object type (0:player0, 1:player1, 2:missle0, 3:missle1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetObjectXPos subroutine
    sta WSYNC                          ; Starts a fresh new scanline
    sec                                ; Makes sure carry-flag is set before subtraction
.Div15Loop
    sbc #15                            ; Subtracts 15 from accumulator
    bcs .Div15Loop                     ; Loops until carry-flag is clear
    eor #7                             ; Handles offset range -8 to 7 (hmm, does this just do a NOT? Applying a XOR with 1111... is just a NOT.)
    asl
    asl
    asl
    asl                                ; four shift lefts to get only the top 4 bits
    sta HMP0,Y                         ; store the fine offset to the correct HMxx
    sta RESP0,Y                        ; fix object position in 15-step increment
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game Over subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameOver subroutine
    lda #$30
    sta COLUBK                         ; Sets background color to red on game over

    lda #0
    sta Score                          ; Score =  0  on Game Over

    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to generate a Linear-Feedback Shift Register random number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate a LFSR random number
;; Divide the random value by 4 to limit the size of the result to match river.
;; Add 30 to compensate for the left green playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomBomberPosition subroutine
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random                         ; Performs a series of shifts and bit operations

    lsr
    lsr                                ; Divides the value by 4 with 2 right shifts
    sta BomberXPos                     ; save it to the variable BomberXPos
    lda #30
    adc BomberXPos                     ; Adds 30 + BomberXPos to compensate for left PF
    sta BomberXPos                     ; And sets the new value to the bomber x-position

    lda #96
    sta BomberYPos                     ; SEts the y-position to the top of the screen

    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;---Graphics Data from PlayerPal 2600---

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle scoreboard digits to be displayed on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert the high and low nibbles of the variable Score and Timer
;; into the offsets of digits lookup table so that values can be displayed.
;; Each digit has a height of 5 bytes in the lookup table.
;;
;; For the low nibble we need to multiply by 5
;;   - we  can use left shifts to perform multiplication by 2
;;   - for any number N, the value of N*5 = (N*2*2) * N
;;
;; For the upper nibble, since it's already times 16 (since it's already in base 16),
;; we need to divide it and then multiple by 5:
;;   - We can use right shifts to perform division by 2
;;   - for any number N, the value of (N/16)*5 = (N/2/2)+(N/2/2/2/2)
;;       - N/4 + N/16 = 4N/16 + N/16 = 5N/16 = 5(N/16)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CalculateDigitOffset subroutine
    ldx #1                   ; X register is the loop counter
.PrepareScoreLoop            ; this will loop twice, first X=1, and then X=0.

    lda Score,X              ; Load A with the Timer (X=1) or Score (X=0)
    and #$0F                 ; Removes the tens digit by masking 4 bits 00001111
    sta Temp                 ; Saves the value of A into Temp
    asl                      ; Shift left (it is now N*2)
    asl                      ; Shift left (it is now N*4)
    adc Temp                 ; Add the value saved in Temp (+N)
    sta OnesDigitOffset,X    ; Save A in OnesDigitOffset+1 or OnesDigitOffset+0
                             ; In first loop pass, save the timer; in second pass, save the score.
                             ; .. See the variables second near the top.
    lda Score,X              ; Load A with Timer (X=1) or Score (x=0)
    and #$F0                 ; remove the ones digit by masking 4 bits 11110000
    lsr                      ; shift right (it is now N/2)
    lsr                      ; shift right (it is now N/4)
    sta Temp                 ; save the value of A into Temp
    lsr                      ; shift right (it is now N/8)
    lsr                      ; shift right (it is now N/16)
    adc Temp                 ; add the value saved in Temp (N/16+N/4)
    sta TensDigitOffset,X    ; Store A in TensDigitOffset+1 or TensDigitOffset+0

    dex                      ; X--
    bpl .PrepareScoreLoop    ; While X >=  0, loop to pass a second time.
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine that waits for 12 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jsr takes 6 cycles
;; rts takes 6 cycles
Sleep12Cycles subroutine
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Digits:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #

DigitsHex:
    .byte $22,$22,$22,$22,$22
    .byte $EE,$22,$EE,$88,$EE
    .byte $EE,$22,$66,$22,$EE
    .byte $AA,$AA,$EE,$22,$22
    .byte $EE,$88,$EE,$22,$EE
    .byte $EE,$88,$EE,$AA,$EE
    .byte $EE,$22,$22,$22,$22
    .byte $EE,$AA,$EE,$AA,$EE
    .byte $EE,$AA,$EE,$22,$EE

JetSprite:
        .byte #%00000000;$00
        .byte #%00101000;$32
        .byte #%11111110;$0E
        .byte #%01111100;$0E
        .byte #%00111000;$0E
        .byte #%00111000;$0E
        .byte #%00010000;$AE
        .byte #%00010000;--
        .byte #%00010000;--

JetSpriteTurn:
        .byte #%00000000;$00
        .byte #%00101000;$32
        .byte #%01111100;$0E
        .byte #%00111000;$0E
        .byte #%00111000;$0E
        .byte #%00010000;$0E
        .byte #%00010000;$AE
        .byte #%00010000;--
        .byte #%00010000;--

BomberSprite:
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

JetColor:
        .byte #$00;
        .byte #$32;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$AE;
        .byte #$0E;
        .byte #$0E;

JetColorTurn:
        .byte #$00;
        .byte #$32;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$AE;
        .byte #$0E;
        .byte #$0E;

BomberColor:
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
