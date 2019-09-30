    processor 6502

    seg code
    org $F000      ; Defines the code origin at $F000

Start:
    sei            ; Disables the interrupts
    cld            ; Clears the decimal mode (disable the decimal map mode)
    ldx #$FF       ; Loads the X register with #$FF
    txs            ; Transfers X register to stack S(tack) register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Zero Page Region ($00 to $FF)
; Meaning the entire TIA register space and also RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0         ; A = 0
                   ; Loads value of 0 into accumulator A register.
    ldx #$FF       ; X = #$FF

MemLoop:
    sta $0,X       ; Stores zero at address $0 + X --> $0 means the value we have inside A.
                   ; Stores the value of accumulator A into memory address 0+X.
                   ; The comma probably implies a range as is 'start,end'
                   ; FF=0, FE=0, FD=0, FC=0 ... 02=0, 01=0, 00=0
    dex            ; x--
                   ; This will eventually set the z-flag.
    bne MemLoop    ; Loops until X==0 (Meaning z-flag set)
