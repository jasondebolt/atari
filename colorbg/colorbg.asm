    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000          ; Defines the origin of the ROM at $F000

START:
    ;CLEAN_START        ; Macro to safely clear the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set background luminosity color to yellow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$1E           ; Loads color into A (#$1E is NTSC Yellow)
    sta COLUBK         ; Stores A into BackgroundColor Address $09

    jmp START          ; Repeat from START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC           ; Defines origin to $FFFC
    .word START         ; Reset vector at $FFFC (where program starts)
    .word START         ; Interrupt vector at $FFFE (unused in the VCS, but we still do it)
