# nes-disasm-misc
*Note: This project has been moved to [Codeberg](https://codeberg.org/qalle/nes-misc-disassembled). This version will no longer be updated.*

Others' [NES](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System) homebrew, disassembled by me.

Table of contents:
* [List of files](#list-of-files)
* [How to assemble](#how-to-assemble)
* [Tools used](#tools-used)
* [Irritating Ship hacks](#irritating-ship-hacks)

## List of files
Programs:
* `bpm*`: *[BPM - Nintendo's Beginnings](https://retroadamshow.itch.io/bpm-nintendos-beginnings)* by retroadamshow. Disassembly not finished.
* `dvd*`: *[DVD Screensaver for NES](https://johnybot.itch.io/nes-dvd-screensaver)* by Johnybot.
* `fukkireta*`: binary posted on NESDev Discord server, "showcase" channel, on 1 July 2024, by devwizard. Disassembly not finished.
* `irriship*`: *[Irritating Ship](https://fiskbit.itch.io/irritating-ship)* by Fiskbit, Trirosmos. Disassembly not finished.
* `prox*`: *[Proximity Shift](https://fiskbit.itch.io/proximity-shift)* by Fiskbit, Trirosmos. Disassembly at an early stage.
* `tencom*`: *[The Ten Commandments on NES](https://debiru.itch.io/the-ten-commandments-on-nes)* by Debiru. Disassembly not finished.

Other files:
* `famistudio.txt`: a file from [Famistudio](https://github.com/BleuBleu/FamiStudio) (similar to what's used in BPM)
* `famitone2.txt`: a file from [Famitone2](https://shiru.untergrund.net/code.shtml) (similar to what's used in Irritating Ship)

## How to assemble
The `.asm` files can be assembled with [ASM6](https://www.romhacking.net/utilities/674/).

Run the `.sh` files (under Linux) to assemble and validate the programs.

## Tools used
* [FCEUX](https://fceux.com/web/home.html) (Debugger, Code/Data Logger, etc.)
* [`nes-sprites.lua`](https://forums.nesdev.org/viewtopic.php?f=2&t=13255) for FCEUX by tokumaru
* [my NES disassembler](https://github.com/qalle2/nes-disasm)
* [my cdl-summary](https://github.com/qalle2/cdl-summary)

## Irritating Ship hacks
My hacks for *Irritating Ship*:
* Simple Controls: Pressing the d-pad in any of the eight directions will
instantly turn and accelerate the ship in that direction. Files:
`irriship-simplecontrols.bps.gz`, `irriship-simplecontrols.ips.gz`.
* Straight Tunnel: Replaces the maze with a straight tunnel. Files:
`irriship-tunnel.bps.gz`, `irriship-tunnel.ips.gz`.
* Thin Walls: Makes all walls two pixels thinner on the inside of the maze,
leaving you more room to maneuver. Affects CHR ROM only. Files:
`irriship-thinwalls.bps.gz`, `irriship-thinwalls.ips.gz`.

([RHDN](https://www.romhacking.net) doesn't accept hacks of homebrew games.)
