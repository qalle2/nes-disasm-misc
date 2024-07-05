; An unofficial disassembly of "Fukkireta".
; The binary was posted on NESDev Discord server, "showcase" channel, on
; 1 July 2024, by devwizard.
; Disassembled by qalle. Assembles with ASM6.
;
; program runtime: ~5600 frames (~93 seconds)
; assuming 32 PRG ROM banks of 16 KiB ($4000 bytes) each (looks like it's
;     actually 64*8 KiB)
; cdl_summary.py from https://github.com/qalle2/cdl-summary was used
;
; animation:
;   - animation frame changes every 4 frames
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
;             110 = 8k PRG bank at $8000 or $c000 (depending on PRG configuration)
;             111 = 8k PRG bank at $a000
;     $8001: bank data: new bank value (see $8000)
;     $a000: mirroring (0=vertical, 1=horizontal)
;     $e000: IRQ disable (any value)
;     $e001: IRQ enable (any value)

; --- Address constants at $0000-$7fff ----------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff
; note: unused hardware registers commented out

ram1            equ $00  ; changes every frame
ram2            equ $10  ; changes every frame
ram3            equ $11  ; changes every frame
pointer         equ $12  ; 2 bytes
ram4            equ $14  ; increments by 1 every 85-86 frames, from 0 to 63
frame_cntr      equ $15  ; increments by 1 every frame, from 0 to 47
ram6            equ $f0  ; changes every frame
ram7            equ $f1  ; changes every frame

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
;oam_addr       equ $2003
;oam_data       equ $2004
;ppu_scroll     equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007

;sq1_vol        equ $4000
;sq1_sweep      equ $4001
;sq1_lo         equ $4002
;sq1_hi         equ $4003
;sq2_vol        equ $4004
;sq2_sweep      equ $4005
;sq2_lo         equ $4006
;sq2_hi         equ $4007
;tri_linear     equ $4008
;tri_lo         equ $400a
;tri_hi         equ $400b
;noise_vol      equ $400c
;noise_lo       equ $400e
;noise_hi       equ $400f
dmc_freq        equ $4010
dmc_raw         equ $4011
;dmc_start      equ $4012
;dmc_len        equ $4013
;oam_dma        equ $4014
;snd_chn        equ $4015
joypad2         equ $4017

bank_select     equ $8000
bank_data       equ $8001

; --- iNES header -------------------------------------------------------------

                ; see https://www.nesdev.org/wiki/INES
                base $0000
                db "NES", $1a
                db 32, 16                ; 512 KiB PRG ROM, 128 KiB CHR ROM
                db %01000000, %00000000  ; MMC3, horizontal NT mirroring
                pad $0010, $00

; --- PRG ROM banks 0-30 ------------------------------------------------------

                ; CDL data:
                ; - first 2 bytes unaccessed
                ; - the rest are indirect data, last mapped to CPU $8000-$bfff

                base $0000
                incbin "fukkireta-prg-bank-0-30.bin"
                pad $7c000, $ff

; --- PRG ROM bank 31 ---------------------------------------------------------

                ; CDL data:
                ; Offset in bank, length, description:
                ;     $0000 ($3008): indirect data, mapped to CPU $8000-$bfff
                ;     $3008 ($0df8): unaccessed
                ;
                ;     $3e00 ($0079): direct code,   mapped to CPU $c000-$ffff
                ;     $3e79 ($0069): direct data,   mapped to CPU $c000-$ffff
                ;     $3ee2 ($001e): unaccessed
                ;     $3f00 ($00b2): direct code,   mapped to CPU $c000-$ffff
                ;     $3fb2 ($000a): direct data,   mapped to CPU $c000-$ffff
                ;     $3fbc ($003e): unaccessed
                ;     $3ffa ($0004): direct data,   mapped to CPU $c000-$ffff
                ;     $3ffe ($0002): unaccessed

                base $c000
                incbin "fukkireta-prg-bank-31a.bin"
                pad $fe00, $ff

sub1            ; called directly by reset
                stx bank_select
                stx bank_data
                lda #$01
                sta bank_select
                asl a
                sta bank_data
                lda #$07
                sta bank_select
                lda #$20
                sta ppu_addr
                stx ppu_addr
                stx ram1
--              ldy dirdat1,x
                lda #$00
-               sta ppu_data
                dey
                bne -
                ldy $feab,x
                beq +
                lda ram1
                clc
-               adc #$01
                sta ppu_data
                dey
                bne -
                sta ram1
                inx
                bne --
                ;
+               lda #$3f                ; set 1st BG subpalette
                ldx #$00
                sta ppu_addr
                stx ppu_addr
-               lda palette,x
                bmi +
                sta ppu_data
                inx
                bne -
                ;
+               ldx #$00
                stx ppu_addr
                stx ppu_addr
                stx pointer+0
                lda #$a0
                sta pointer+1       ; $a000 -> pointer
                asl a               ; $40
                sta ram2
                stx ram3            ; 0
                asl a               ; $80
                stx ram4            ; 0
                stx bank_data       ; 0
                ldy #0
                sty frame_cntr
                sta ppu_ctrl        ; %10000000
                lda #%00001010
                sta ppu_mask
empty_sub       rts

dirdat1         ; direct data ($fe79)
                hex 4c 1a 19 19 01 19 01 19
                hex 19 16 15 13 04 11 04 10
                hex 03 10 03 10 03 11 03 12
                hex 01 12 12 01 01 12 01 13
                hex 01 01 14 01 01 01 14 01
                hex 15 01 16 17 01 01 18 01
                hex 01 8c 06 06 07 05 01 05
                hex 01 07 09 0a 0d 04 06 05
                hex 06 07 06 07 06 07 06 06
                hex 06 06 07 0e 07 02 03 03
                hex 0a 02 06 02 02 03 02 02
                hex 09 02 08 01 0a 02 02 02
                hex 02 02 02 00

palette         ; $fedd; read by sub1
                hex 30 1d 2d 10     ; white, black, dark grey, light grey
                hex ff              ; terminator

                ; unaccessed ($fee2)
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff

nmi             ; direct code ($ff00)
                sta ram6
                ;
                lda frame_cntr      ; counts 0-47
                clc
                adc #1
                cmp #48
                bcc +
                lda #0
+               sta frame_cntr
                ;
                stx ram7
                ldx #$00
                stx bank_select
                asl a
                and #%01111100
                sta bank_data
                inx
                stx bank_select
                ora #%00000010
                sta bank_data
                ldx #$07
                stx bank_select
                ldx ram7
                lda ram4
                cmp #$3f
                bcc +
                lda pointer+1
                cmp #$b0
                bcs reset
                ;
+               lda ram6
                rti

reset           ; direct code ($ff3b)
                cld
                ldx #$00
                stx ppu_ctrl
                stx ppu_mask
                stx dmc_freq
                dex                          ; $ff -> X
                stx joypad2
                txs
                ;
                dex                          ; $fe -> X
                lda ppu_status
-               lda ppu_status
                bpl -
                inx
                bmi -
                ;
                jsr sub1
                ;
code1           lda (pointer),y              ; $ff5b
                sta ram3
                ldy #4
                ;
                inc pointer+0               ; increment pointer
                bne +
                inc pointer+1
                ;
+               bit pointer+1
                bvc code2
                lda #$a0
                sta pointer+1
                inc ram4
                lda ram4
                sta bank_data
                ;
code2           lda dirdat3,x               ; $ff76
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
                cpx #$0a
                bcc +
                ldx #$09
+               sta ram1
                lda ram2
                lsr ram3
                bcc ++
                sbc ram1
                bpl +
                lda #$00
+               bpl +
++              adc ram1
                bpl +
                lda #$7f
+               sta ram2
                sta dmc_raw
                jsr empty_sub
                nop
                nop
                dey
                bne code2
                beq code1                    ; unconditional

dirdat3         ; direct data ($ffb2)
                hex 01 02 03 05 08 0d 15 22
                hex 37 59 ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff
                hex ff ff ff ff ff ff ff ff

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
