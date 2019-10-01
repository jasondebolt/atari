# Atari 6502 Projects
MOS 6502 Atari projects

## Table Of Contents
* [Links](#links)
* [6502.org](#6502org)
* [Processor Flags](#processor-flags)
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


## 6502.org
* [Assembly In One Step](https://dwheeler.com/6502/oneelkruns/asm1step.html)
* [NMOS 6502 Opcodes](http://www.6502.org/tutorials/6502opcodes.html)
* [6502 Compare Instructions](http://www.6502.org/tutorials/compare_instructions.html)
* [Overflow Flag](http://www.6502.org/tutorials/vflag.html)
* [Beyond 8-bit Unsigned Comparisons](http://www.6502.org/tutorials/compare_beyond.html)


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



## Python Helpers
View binary representation of a number:
```python
def form(exp):
    return '{0:08b}'.format(exp)
    
Example:
>>> form(10 ^ 5)
'00001111'
>>> form(0b1010 ^ 0b0101)
'00001111'
```
