	processor 6502
	include "vcs.h"
	include "macro.h"

	org  $f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; We're going to mess with the playfield registers, PF0, PF1 and PF2.
; Between them, they represent 20 bits of bitmap information
; which are replicated over 40 wide pixels for each scanline.
; By changing the registers before each scanline, we can draw bitmaps.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Counter	equ $81

Start	CLEAN_START

NextFrame
; This macro efficiently gives us 1 + 3 lines of VSYNC
	VERTICAL_SYNC

; 36 lines of VBLANK
	ldx #36
LVBlank	sta WSYNC
	dex
	bne LVBlank
; Disable VBLANK
        stx VBLANK
; Set foreground color
	lda #$82
        sta COLUPF
; Draw the 192 scanlines
	ldx #192
	lda #0		; changes every scanline
        ;lda Counter    ; uncomment to scroll!

    ldy #2
ScanLoop
	sta WSYNC	; wait for next scanline

    lda PlayfieldP0,Y

	sta PF0		; set the PF1 playfield pattern register
    lda PlayfieldP1
	sta PF1		; set the PF1 playfield pattern register
    lda PlayfieldP2
	sta PF2		; set the PF2 playfield pattern register
	stx COLUBK	; set the background color
    lda #%00000001
    sta CTRLPF
	bne ScanLoop

; Reenable VBLANK for bottom (and top of next frame)
	lda #2
        sta VBLANK
; 30 lines of overscan
	ldx #30
LVOver	sta WSYNC
	dex
	bne LVOver

; Go back and do another frame
	inc Counter
	jmp NextFrame

ResetY subroutine
    ldy #0
    rts


PlayfieldP0
    .byte #%10000000
    .byte #%01000000
    .byte #%00100000
PlayfieldP1
    .byte #%00000000
PlayfieldP2
    .byte #%00000000

	org $fffc
	.word Start
	.word Start
