    processor 6502

    seg code
    org $F000      ; Defines the code origin at $F000

Start:
    sei            ; Disables the interrupts
    cld            ; Clears the decimal mode (disable the decimal map mode)
    ldx #$FF       ; Loads the X register with #$FF
    txs            ; Transfers X register to stack S(tack) register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear the Zero Page Region ($00 to $FF)
;; Meaning the entire TIA register space and also RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0         ; A = 0
                   ; Loads value of 0 into accumulator A register.
    ldx #$FF       ; X = #$FF
    sta $FF        ; Make sure $FF is zeroed before the loop starts

MemLoop:
    dex            ; x--  (starts loop at FE to ensure the last memory location $0 is set to #0)
                   ; This will eventually set the z-flag.
    sta $0,X       ; Stores zero at address $0 + X --> $0 means the value we have inside A.
                   ; Stores the value of accumulator A into memory address 0+X.
                   ; The comma probably implies a range as is 'start,end'
                   ; FE=0, FD=0, FC=0 ... 02=0, 01=0, 00=0
    bne MemLoop    ; Loops until X==0 (Meaning z-flag set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC      ; Force code to start at position FFFC
                   ; Whenever the Atari system is reset, it will come to this position $FFFC.
                   ; It will look for the start instruction and it will find $F000
    .word Start    ; 'Reset' vector at $FFFC (where program starts).
                   ; Occupies bytes $FFFC and $FFFD
                   ; '.word' adds 2 bytes.
    .word Start    ; 'Interrupt' vector at $FFFE (unused in VCS)
                   ; '.word' adds 2 bytes.
                   ; Occupies bytes $FFFE and $FFFF
                   ; We used 2 bytes because labels like 'Start' require 16 bits (2 bytes)
