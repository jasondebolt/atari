    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

Start:
    CLEAN_START          ; Macro to safely clean memory and TIA address space

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    ldy #3                           ; Affects Flags: N Z
Loop3ToZero:
    dey                              ; y -= 1 (z->Z on third pass)
    bne Loop3ToZero                  ; y == 0?

    ldy #0
LoopZeroToThree:
    iny                               ; y += 1 (Z->z on first pass, N->n on second and third passes)
    cpy #03                           ; y >= 3? (Affects Flags: N Z C)
                                      ; (n->N on first and second pass, C->c on first pass)
                                      ; (z->Z on third pass, c->C on third pass)

    bne LoopZeroToThree               ; cpy == 0?

    lda #1                            ; (Z->z)
Loop2Through8:
    asl                               ; a << 1
                                      ; (C->c on first pass)
                                      ; (N->n on second pass)
                                      ; (N->n on third pass)

    cmp #8                            ; a >= 8? (Affects Flags: N Z C)
                                      ; (n->N on first pass)
                                      ; (n->N on second pass)
                                      ; (z->Z on third pass)
                                      ; (z->Z on third pass)
                                      ; (c->C on third pass)
    bne Loop2Through8

    lda #0
Loop2Through8Better:                  ; A = 0, A = 2, A = 4, A = 6, A = 8
    clc                               ; clears carry flag before addition (C->c)

    adc #2                            ; a += 2  (Affects Flags: N V Z C)
                                      ; Z->z on first   pass
                                      ; N->n on second pass
                                      ; N->n on third pass
                                      ; N->n on fourth pass

    cmp #8                            ; a >= 8? (Affects Flags: N Z C)
                                      ; n->N on first pass
                                      ; n->N on second pass
                                      ; n->N on third pass
                                      ; z->Z on fourth pass
                                      ; c->C on fourth pass
                                      ; Value is 'n' on fourth pass

    bne Loop2Through8Better


    lda #$FF                          ; Loads the constant FF (NOT from memory)
                                      ; n->N
                                      ; Z->z

TestROR:
    lda #$03                                              ; $03   00000011  C
    sec                              ; set carry flag
    ror                              ; rotate right       ; $81   10000001  C
    ror                              ; rotate right       ; $81   11000000  C
    ror                              ; rotate right       ; $81   11100000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of the VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC             ; first scanline
    sta WSYNC             ; second scanline
    sta WSYNC             ; third scanline

    lda #0
    sta VSYNC             ; turn off VSYNC

TestStack:
    lda #$45              ; Stack pointer is at $FF
    pha                   ; Push $45 constant onto stack (usually at memory location $FF)
    lda #$44
    pha                   ; Push $45 constant onto stack (usually at memory location $FE)
    lda #$43
    pha                   ; Push $45 constant onto stack (usually at memory location $FE)
    lda #$00
    pla                   ; A is now set to $43, sp (stack pointer) is now at $fd
    pla                   ; A is now set to $44, sp is now at $fe
    pla                   ; A is now set to $45, sp is now at $ff
                          ; Note that when you pull bytes from the stack, the bytes actually remain on the stack.
                          ; Only the stack pointer is incremented when you pull stuff off the stack.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 scanlines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37               ; X = 37 (to count 37 scanlines)
LoopVBlank:
    sta WSYNC             ; hit WSYNC and wait for the next scanline
    dex                   ; X--
    bne LoopVBlank        ; loop while X != 0

    lda #0
    sta VBLANK            ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192              ; counter for 192 visible scanlines
LoopVisible:
    stx COLUBK            ; set the background color
    sta WSYNC             ; wait for the next scanline
    dex                   ; X--
    bne LoopVisible       ; loop while X != 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK lines (overscan) to complete out frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2                ; hit and turn on VBLANK again
    sta VBLANK
    ldx #30               ; counter for 30 scanlines
LoopOverscan:
    sta WSYNC             ; wait for the next scanline
    dex                   ; X--
    bne LoopOverscan      ; loop while X != 0

    jmp NextFrame         ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete my ROM size to 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start
