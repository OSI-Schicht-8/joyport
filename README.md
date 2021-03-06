# joyport.library (V34)
Amiga joyport.library for Kickstart 1.3+

## getjoyport function
`getjoyport` returns the state of the selected port.

### Synopsis
`portState [D0] = getjoyport(portNumber [D0]);`  

`ULONG getjoyport(ULONG);`

### Input
`portNumber` - selected gameport (0 or 1)

### Return value
`portState` - bit map that identifies the device and the current state of that device.  
The output is compatible with the portState of the [ReadJoyPort](http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_3._guide/node0468.html) function from the lowlevel.library (V40).

## Description of the files

+ joyport.library - shared library including the getjoyport function.
+ joyport.library.asm - sourcecode in assembly language
+ joyport.lib - static linker library with stubs and LVO (Library Vector Offsets)
+ joyport_lvos.asm - sourcecode of LVO part
+ joyport_stubs.asm - sourcecode of stubs part
+ joyporttest.c - C example showing the usage of the joyport.library

## Building

joyport.library was cross compiled with vasm under Windows 10:
```shell
vasmm68k_mot -kick1hunks -Fhunkexe -o joyport.library -nosym joyport.library.asm
```
For an instruction how to build vasm on Windows look here: http://eab.abime.net/showthread.php?t=94442


joyporttest can be compiled using vbcc under AmigaOS:
```shell
vc +kick13 -llibrary -o joyporttest joyporttest.c
```
"vbcc_bin_amigaos68k.lha" AmigaOS 2.x/3.x 68020+ binaries and "vbcc_target_m68k-kick13.lha" compiler target Amiga Kickstart 1.2/1.3 M680x0 are needed. Both can be obtained here: http://sun.hasenbraten.de/vbcc/index.php?view=main
