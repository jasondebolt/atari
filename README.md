# Atari 6502 Projects
MOS 6502 Atari projects

## Table Of Contents
* [Links](#links)
* [6502.org](#6502org)
* [Atari Age Atari 2600 Programming Forum](atari-age-atari-programming-forum)
* [Eater.net](#eaternet)
* [Random Terrain](#random-terrain-atari-tutorials)
* [Processor Flags](#processor-flags)
* [Shift Operations](#shift-operations)
* [Atari Memory Map](#atari-memory-map)
* [Development](#development)
  * [Online Development](#online-development)
  * [Offline Development](#offline-development)
    * [DASM Macro Assembler](#dasm-macro-assembler)
    * [Creating the cleanmem machine code binary](#creating-the-cleanmem-machine-code-binary)
    * [Running cleanmem in the Stella emulator](#running-cleanmem-in-the-stella-emulator)
* [Python Helpers](#python-helpers)

## Links
* [Gustavo Pezzi's online "Programming Games for the Atari 2600" course](https://www.udemy.com/course/programming-games-for-the-atari-2600)
* [Stevent Hugg's "Making Games for the Atari 2600" book](https://www.amazon.com/Making-Games-Atari-2600-Steven/dp/1541021304)
* [8 Bit Workshop Browser IDE](https://8bitworkshop.com)
* [DASM Macro Assembler](http://dasm-dillon.sourceforge.net/)
* [Stella Emulator](https://stella-emu.github.io/)
* [JAVATARI](https://javatari.org)
* [8 Bit Workshop](http://8bitworkshop.com)
* [macro.h and vcs.h files](https://github.com/munsie/dasm/tree/master/machines/atari2600)
* [Atari Color Palette](https://en.wikipedia.org/wiki/List_of_video_game_console_palettes#Atari_2600)
* [PlayerPal Online Sprite Creator](https://alienbill.com/2600/playerpalnext.html)
* [Stella Programmers Guide](https://alienbill.com/2600/101/docs/stella.html)

## Eater.net
* [Ben Eater's 6502 electronics kits](https://eater.net/)

## Random Terrain (Atari Tutorials)
* [Guide to Cycle Counting on the Atari 2600](https://www.randomterrain.com/atari-2600-memories-guide-to-cycle-counting.html)
* [How to Draw a Playfield](https://www.randomterrain.com/atari-2600-memories-how-to-draw-a-playfield.html)
* [Assembly Language Programming](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-01.html)
    * [Lesson 1: Bits!](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-01.html)
    * [Lesson 2: Enumeration](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-02.html)
    * [Lesson 3: Codes](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-03.html)
    * [Lesson 4: Binary Counting](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-04.html)
    * [Lesson 5: Binary Math](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-05.html)
    * [Lesson 6: Binary Logic](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-06.html)
    * [Lesson 7: State Machines](https://www.randomterrain.com/atari-2600-memories-tutorial-robert-m-07.html)
* [Let's make a game](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-00.html)
     * [Introduction](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-00.html)
     * [Step 1: Generate a stable Display](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-01.html)
     * [Step 2: Timers](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-02.html)
     * [Step 3: Score and Timer Display](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-03.html)
     * [Step 4: Line Kernel](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-04.html)
     * [Step 5: Automate Vertical Delay](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-05.html)
     * [Step 6: Spec Change](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-06.html)
     * [Step 7: Draw the Playfield](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-07.html)
     * [Step 8: Select and Reset Support](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-08.html)
     * [Step 9: Game Variations](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-09.html)
     * [Step 10: Random Numbers](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-10.html)
     * [Step 11: Add the Ball Object](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-11.html)
     * [Step 12: Add the Missle Objects](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-12.html)
     * [Step 13: Add Sound Effects](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-13.html)
     * [Step 14: Add Animation](https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-14.html)
* [Atari 2600 programming for newbies](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-01.html)
    * [Session 1: Start Here](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-01.html)
    * [Session 2: Televsion and Display Basics](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-02.html)
    * [Session 3: The TIA and the 6502](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-03.html)
    * [Session 4: The TIA](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-04.html)
    * [Session 5: Memory Architecture](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-05.html)
    * [Session 7: The TV and our Kernel](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-07.html)
    * [Session 8: Our first kernel](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-08.html)
    * [Session 9: 6502 and DASM - Assembling the Basics](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-09.html)
    * [Session 10: Orgasm](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-10.html)
    * [Session 11: Colorful Colors](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-11.html)
    * [Session 12: Initialization](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-12.html)
    * [Session 13: Playfield Basics](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-13.html)
    * [Session 14: Playfield Weirdness](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-14.html)
    * [Session 15: Playfield Continued](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-15.html)
    * [Session 16: Letting the Assembler do the Work](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-16.html)
    * [Session 17: Asymmetrical Playfields \(Parts 1 & 2\)](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-17.html)
    * [Session 19: Addressing Modes](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-19.html)
    * [Session 20: Asymmetrical Playfields \(Part 3\)](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-20.html)
    * [Session 21: Sprites](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-21.html)
    * [Session 22: Sprites, Horizontal Positioning (Part 1)](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-22.html)
    * [Session 23: Moving Sprites Vertically](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-23.html)
    * [Session 24: Some Nice Code](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-24.html)
    * [Session 25: Advanced Timeslicing](https://www.randomterrain.com/atari-2600-memories-tutorial-andrew-davie-25.html)


## 6502.org
* [Assembly In One Step](https://dwheeler.com/6502/oneelkruns/asm1step.html)
* [NMOS 6502 Opcodes](http://www.6502.org/tutorials/6502opcodes.html)
* [6502 Compare Instructions](http://www.6502.org/tutorials/compare_instructions.html)
* [Overflow Flag](http://www.6502.org/tutorials/vflag.html)
* [Beyond 8-bit Unsigned Comparisons](http://www.6502.org/tutorials/compare_beyond.html)

# Atari Age Atari 2600 Programming Forum
* [Atari Age Atari 2600 Programming Forum](https://atariage.com/forums/forum/50-atari-2600-programming/)

## Processor Flags
```
   Processor Status
   ----------------
   
   The processor status register is not directly accessible by any 6502 
   instruction.  Instead, there exist numerous instructions that test the 
   bits of the processor status register.  The flags within the register 
   are:
   
   
       bit ->   7                           0
              +---+---+---+---+---+---+---+---+
              | N | V |   | B | D | I | Z | C |  <-- flag, 0/1 = reset/set
              +---+---+---+---+---+---+---+---+
              
              
       N  =  NEGATIVE. Set if bit 7 of the accumulator is set.
       
       V  =  OVERFLOW. Set if the addition of two like-signed numbers or the
             subtraction of two unlike-signed numbers produces a result
             greater than +127 or less than -128.
             
       B  =  BRK COMMAND. Set if an interrupt caused by a BRK, reset if
             caused by an external interrupt.
             
       D  =  DECIMAL MODE. Set if decimal mode active.
       
       I  =  IRQ DISABLE.  Set if maskable interrupts are disabled.
             
       Z  =  ZERO.  Set if the result of the last operation (load/inc/dec/
             add/sub) was zero.
             
       C  =  CARRY. Set if the add produced a carry, or if the subtraction
             produced a borrow.  Also holds bits after a logical shift.
             
 ```            
### Processor Flags Table
| Flag | Name | Description
----|-------|----------------|
| Z | Zero | Set when the result is zero |
| N | Negative/Sign | Set when the result is negative (high bit set) |
| C | Carry | Set when an arithmetic operation <b>wraps</b> and carries the high bit |
| V | Overflow | Set when an arithmetic operation <b>overflows</b>; i.e if the sign of the result changes due to overview |
 

## Shift Operations
|Operation|Name|Description|
----------|-----|----------|
|ASL|Shift Left|Shift left 1 bit (multiply by 2), bit 7 --> Carry|
|LSR|Shift Right|Shift right 1 bit (divide by 2), bit 0 --> Carry|
|ROL|Rotate Left|Same as ASL except Carry --> bit 0|
|ROR|Rotate Right|Same as LSR except Carry --> bit 7|


## Atari Memory Map
<img src="memory_map.png" height="150px"/>

## Sprites
Use the [PlayerPal Online Sprite Creator](https://alienbill.com/2600/playerpalnext.html).
<p>
<img src="sprites.png" height="350"></img>

## Development
You can develop Atari 6502 assembly offline or online (in the browser).

### Online Development

Use the [8 Bit Workshop IDE](https://8bitworkshop.com/) with the built in [Javatari](https://javatari.org) emulator. This solution is very easy to get started.
<p>
<img src="8bitworkshop.png" height="350px"/>

### Offline Development
Use the [DASM Macro Assembler](http://dasm-dillon.sourceforge.net/) and the [Stella Emulator](https://stella-emu.github.io/) for local development. It's more powerful than browser development using the 8 Bit Workshop IDE with the Javatari IDE.

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
