; An unofficial disassembly of "Fukkireta".
; The binary was posted on NESDev Discord server, "showcase" channel, on
; 1 July 2024, by devwizard.
; Disassembled by qalle. Assembles with ASM6.
;
; The program runs for ~5600 frames (~93 seconds) before it starts to loop.
; 64 PRG ROM banks of 8 KiB ($2000 bytes) each.
;
; animation:
;   - animation frame and CHR banks change every 4 frames
;   - pelvis changes sides every 6 animation frames
;   - 1st animation frame after pelvis has changed sides is fuzzy
;
; MMC3 registers:
;     $8000: bank select: CPxx xRRR:
;         P: PRG configuration (always 4*8k):
;             0 = switchable, switchable, fixed to 2nd-to-last bank, fixed to
;                 last bank
;             1 = fixed to 2nd-to-last bank, switchable, switchable, fixed to
;                 last bank
;         C: CHR configuration:
;             0 = 2*2k + 4*1k
;             1 = 4*1k + 2*2k
;         RRR: bank to change on next write to $8001:
;             000 = 1st 2k CHR bank
;             001 = 2nd 2k CHR bank
;             010 = 1st 1k CHR bank
;             011 = 2nd 1k CHR bank
;             100 = 3rd 1k CHR bank
;             101 = 4th 1k CHR bank
;             110 = 8k PRG bank at $8000 or $c000 (depending on PRG config)
;             111 = 8k PRG bank at $a000
;     $8001: bank data: new bank value (see $8000)
;     $a000: mirroring (0=vertical, 1=horizontal)
;     $e000: IRQ disable (any value)
;     $e001: IRQ enable (any value)

; --- RAM and memory-mapped registers -----------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff
; note: unused hardware registers commented out

ram1            equ $00  ; changes every frame
dmc_raw_copy    equ $10  ; changes every frame
ram3            equ $11  ; changes every frame
pointer         equ $12  ; 2 bytes
ram4            equ $14  ; increments by 1 every 85-86 frames, from 0 to 63;
                         ; used as bank number
anim_phase      equ $15  ; phase of animation; increments by 1 every frame,
                         ; from 0 to 47
a_backup        equ $f0  ; backup of A register in NMI routine
x_backup        equ $f1  ; backup of X register in NMI routine

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
ppu_addr        equ $2006
ppu_data        equ $2007
dmc_freq        equ $4010
dmc_raw         equ $4011
joypad2         equ $4017
bank_select     equ $8000  ; MMC3
bank_data       equ $8001  ; MMC3

; --- iNES header -------------------------------------------------------------

                ; see https://www.nesdev.org/wiki/INES
                base $0000
                db "NES", $1a
                db 32, 16                ; 512 KiB PRG ROM, 128 KiB CHR ROM
                db %01000000, %00000000  ; MMC3, horizontal NT mirroring
                pad $0010, $00

; --- PRG ROM banks 0-62 ------------------------------------------------------

                ; CDL info:
                ; - first 2 bytes: unaccessed
                ; - the rest: indirectly accessed as data via CPU bank
                ;             $a000-$bfff
                ;
                ; Does not sound like music if interpreted as 8-bit mono signed
                ; or unsigned raw audio data.

                base $0000
                incbin "fukkireta-prg-bank-0-62.bin"
                pad $7e000, $ff

; --- PRG ROM bank 63 ---------------------------------------------------------

                ; CDL info:
                ; - $0000-$1007: indirectly accessed as data via CPU bank
                ;                $a000-$bfff
                ; - $1008-$1dff: unaccessed
                ; - $1e00-$1fff: accessed as code or data via CPU bank
                ;                $e000-$ffff (details: fukkireta.cdl.txt)

                base $0000
                incbin "fukkireta-prg-bank-63a.bin"
                pad $1e00, $ff

                base $fe00

sub1            ; called directly by reset with X = 0
                ;
                ; PRG configuration:
                ;     $8000-$9fff: 8k, switchable
                ;     $a000-$bfff: 8k, switchable
                ;     $c000-$dfff: 8k, fixed to 2nd-to-last PRG bank
                ;     $e000-$ffff: 8k, fixed to last PRG bank
                ; CHR configuration:
                ;     $0000-$07ff: 2k, switchable
                ;     $0800-$0fff: 2k, switchable
                ;     $1000-$13ff: 1k, switchable
                ;     $1400-$17ff: 1k, switchable
                ;     $1800-$1bff: 1k, switchable
                ;     $1c00-$1fff: 1k, switchable
                ;
                stx bank_select         ; prepare to set PPU bank $0000-$07ff
                stx bank_data           ; use cart CHR bank 0
                lda #%00000001
                sta bank_select         ; prepare to set PPU bank $0800-$0fff
                asl a
                sta bank_data           ; use cart CHR bank 2
                ;
                lda #%00000111
                sta bank_select         ; prepare to set CPU bank $a000-$bfff

                lda #$20                ; $2000 -> PPU address
                sta ppu_addr
                stx ppu_addr
                stx ram1
                ;
nt_loop         ldy nt_zerocnt,x        ; write Y zero bytes
                lda #$00
-               sta ppu_data
                dey
                bne -
                ;
                ldy nt_nonzero_cnt,x    ; write Y preincremented bytes
                beq +
                lda ram1
                clc
-               adc #1
                sta ppu_data
                dey
                bne -
                ;
                sta ram1
                inx
                bne nt_loop

+               lda #$3f                ; set 1st BG subpalette
                ldx #$00
                sta ppu_addr
                stx ppu_addr
-               lda palette,x
                bmi +
                sta ppu_data
                inx
                bne -

+               ldx #$00
                stx ppu_addr
                stx ppu_addr
                stx pointer+0
                lda #$a0
                sta pointer+1           ; $a000 -> pointer
                asl a
                sta dmc_raw_copy        ; $40 -> dmc_raw_copy
                stx ram3                ; 0 -> ram3
                asl a                   ; %10000000
                stx ram4                ; 0 -> ram4
                stx bank_data           ; use PRG bank 0 (for $a000-$bfff)
                ldy #0
                sty anim_phase
                sta ppu_ctrl            ; %10000000 (enable NMI on VBlank)
                lda #%00001010
                sta ppu_mask            ; enable BG rendering
empty_sub       rts

nt_zerocnt      ; how many $00 bytes to write to NT0 ($fe79, 50 bytes)
                db 76,  26, 25, 25, 1, 25,  1, 25
                db 25,  22, 21, 19, 4, 17,  4, 16
                db  3,  16,  3, 16, 3, 17,  3, 18
                db  1,  18, 18,  1, 1, 18,  1, 19
                db  1,   1, 20,  1, 1,  1, 20,  1
                db 21,   1, 22, 23, 1,  1, 24,  1
                db  1, 140

nt_nonzero_cnt  ; how many times to write an incrementing value to NT0
                ; ($feab, 49 bytes + terminator)
                db 6,  6,  7, 5, 1, 5,  1, 7
                db 9, 10, 13, 4, 6, 5,  6, 7
                db 6,  7,  6, 7, 6, 6,  6, 6
                db 7, 14,  7, 2, 3, 3, 10, 2
                db 6,  2,  2, 3, 2, 2,  9, 2
                db 8,  1, 10, 2, 2, 2,  2, 2
                db 2
                db 0                    ; terminator

; note: the sum of the two previous arrays is 1024

palette         ; $fedd; read by sub1
                hex 30 1d 2d 10         ; white, black, dark grey, light grey
                hex ff                  ; terminator

                pad $ff00, $ff          ; unaccessed ($fee2)

nmi             ; direct code
                sta a_backup
                ;
                lda anim_phase          ; counts 0-47
                clc
                adc #1
                cmp #48
                bcc +
                lda #0
+               sta anim_phase
                ;
                stx x_backup
                ;
                ldx #$00
                stx bank_select
                asl a
                and #%01111100
                sta bank_data
                ;
                inx
                stx bank_select
                ora #%00000010
                sta bank_data
                ;
                ldx #$07
                stx bank_select         ; prepare to set CPU bank $a000-$bfff
                ldx x_backup
                ;
                lda ram4
                cmp #$3f                ; how soon animation & music restart
                bcc +
                lda pointer+1
                cmp #$b0
                bcs reset
                ;
+               lda a_backup
                rti

reset           ; direct code ($ff3b)
                cld
                ldx #$00
                stx ppu_ctrl            ; disable NMI on VBlank
                stx ppu_mask
                stx dmc_freq
                dex                     ; X = $ff
                stx joypad2
                txs
                ;
                dex                     ; X = $fe
                lda ppu_status          ; wait for start of VBlank twice
-               lda ppu_status
                bpl -
                inx
                bmi -
                ;
                jsr sub1                ; X = 0
                ;
code1           lda (pointer),y         ; $ff5b
                sta ram3
                ldy #4
                ;
                inc pointer+0           ; increment pointer
                bne +
                inc pointer+1
                ;
+               bit pointer+1
                bvc code2               ; branch if bit 6 was clear
                lda #$a0
                sta pointer+1
                inc ram4
                lda ram4
                sta bank_data
                ;
code2           lda audio_table,x       ; $ff76
                lsr ram3
                bcc ++
                lsr a
                lsr a
                dex
                bpl +
                inx
+               bpl +
++              inx
                inx
                cpx #10
                bcc +
                ldx #9
+               sta ram1
                lda dmc_raw_copy
                lsr ram3
                bcc ++
                sbc ram1
                bpl +
                lda #$00
+               bpl +
++              adc ram1
                bpl +
                lda #$7f
+               sta dmc_raw_copy
                sta dmc_raw
                jsr empty_sub
                nop
                nop
                dey
                bne code2
                beq code1               ; unconditional

audio_table     ; if replaced with other data, music is noisy but partially
                ; intelligible; starts with the Fibonacci sequence ($ffb2)
                db   1,   2,   3,   5,   8,  13,  21,  34
                db  55,  89, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255
                db 255, 255, 255, 255, 255, 255, 255, 255

                ; NMI, reset, IRQ vectors (IRQ unaccessed)
                pad $fffa, $ff
                dw nmi, reset, reset

                pad $10000, $ff

; --- CHR ROM -----------------------------------------------------------------

                ; CHR -> PNG:
                ;     nes_chr_decode.py fukkireta-chr.bin fukkireta-chr.png
                ;     ffffff,000000,555555,aaaaaa
                ; PNG -> CHR:
                ;     nes_chr_encode.py fukkireta-chr.png fukkireta-chr.bin
                ;     ffffff,000000,555555,aaaaaa
                ; get the programs from: https://github.com/qalle2/nes-util
                ;
                ; CDL data:
                ;     $00000-$17fff: all rendered
                ;     $18000-$1ffff: all unaccessed

                base $0000
                incbin "fukkireta-chr.bin"  ; 24*256 tiles = 96 KiB
                pad $18000, $ff
                pad $20000, $ff
