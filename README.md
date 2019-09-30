# Atari 6502 Projects
MOS 6502 Atari projects

## Links
[NMOS 6502 Opcodes](http://www.6502.org/tutorials/6502opcodes.html)
[DASM Macro Assembler](http://dasm-dillon.sourceforge.net/)
[Stella Emulator](https://stella-emu.github.io/)
[JAVATARI](https://javatari.org)
[8 Bit Workshop](http://8bitworkshop.com)


## DASM Macro Assembler
1) Download DASM for mac (or whatever your OS is)
2) Unzip or untar it
3) Sudo copy dasm to /usr/local/bin

## Creating the cleanmem machine code binary
The `-f3` is the Atari 6507 version.
```
$ dasm cleanmem.asm -f3 -v0 -ocart.bin
$ chmod a+x cart.bin
```

## Running cleanmem in the Stella emulator
1) Open the Stella emulator
2) Select the path to your cart.bin file
3) Double click on cart.bin
4) Enter the backtick (\`) to toggle between debug mode.
