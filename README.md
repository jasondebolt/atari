# Atari 6502 Projects
MOS 6502 Atari projects

## Table Of Contents
* [Links](#links)
* [Memory Map](#memory-map)
* [Development](#development)
  * [Online Development](#online-development)
  * [Offline Development](#offline-development)
    * [DASM Macro Assembler](#dasm-macro-assembler)
    * [Creating the cleanmem machine code binary](#creating-the-cleanmem-machine-code-binary)
    * [Running cleanmem in the Stella emulator](#running-cleanmem-in-the-stella-emulator)

## Links
* [8 Bit Workshop Browser IDE](https://8bitworkshop.com)
* [NMOS 6502 Opcodes](http://www.6502.org/tutorials/6502opcodes.html)
* [DASM Macro Assembler](http://dasm-dillon.sourceforge.net/)
* [Stella Emulator](https://stella-emu.github.io/)
* [JAVATARI](https://javatari.org)
* [8 Bit Workshop](http://8bitworkshop.com)
* [macro.h and vcs.h files](https://github.com/munsie/dasm/tree/master/machines/atari2600)
* [Atari Color Palette](https://en.wikipedia.org/wiki/List_of_video_game_console_palettes#Atari_2600)

## Memory Map
<img src="memory_map.png" height="200px"/>

## Development
You can develop Atari 6502 assembly offline or online (in the browser).

### Online Development

Use the [8 Bit Workshop IDE](https://8bitworkshop.com/) with the built in [Javatari](https://javatari.org) emulator. This solution is very easy to get started.
<p>
<img src="8bitworkshop.png" height="350px"/>

### Offline Development
Use the DASM Macro Assembler](http://dasm-dillon.sourceforge.net/) and the [Stella Emulator](https://stella-emu.github.io/) for local development. It's more powerful than browser development using the 8 Bit Workshop IDE with the Javatari IDE.

#### DASM Macro Assembler
1) Download DASM for mac (or whatever your OS is)
2) Unzip or untar it
3) Sudo copy dasm to /usr/local/bin

#### Creating the cleanmem machine code binary
The `-f3` is the Atari 6507 version.
```
$ dasm cleanmem.asm -f3 -v0 -ocart.bin
$ chmod a+x cart.bin
```

#### Running cleanmem in the Stella emulator
```
$ alias stella="/Applications/Stella.app/Contents/MacOS/Stella"
$ cd colorbg
$ make
$ stella cart.bin
```
OR
1) Open the Stella emulator
2) Select the path to your cart.bin file
3) Double click on cart.bin
4) Enter the backtick (\`) to toggle between debug mode.
