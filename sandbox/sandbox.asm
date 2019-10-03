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
                                      ; c->C on fourth pas  s

    bne Loop2Through8Better

    sta VBLANK            ; Turns on VBLANK
    sta VSYNC             ; Turns on VSYNC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of the VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC             ; first scanline
    sta WSYNC             ; second scanline
    sta WSYNC             ; third scanline

    lda #0
    sta VSYNC             ; turn off VSYNC

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
