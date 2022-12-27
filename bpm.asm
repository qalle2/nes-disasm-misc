; An unofficial disassembly of "BPM - Nintendo's Beginnings" (BPM-1.1.nes)
; by retroadamshow, https://retroadamshow.itch.io/bpm-nintendos-beginnings
; Disassembled by qalle. Assembles with ASM6.

; Note: this disassembly is under construction.

; Bank summary:
;   0: empty
;   1: data
;   2: code, data
;   3: code, data

; First, title screen shown. After A/start pressed, scroll down to 1st game
; screen. Then left/right to scroll horizontally between 14 game screens.

; Title screen layout:
; - BPM logo   : lines  2-11
; - EKG line   : lines 18-25
; - bottom text: lines 25-27
; Game screen layout:
; - title      : line   2
; - cartridge  : lines  4-16
; - DOR   text : line  18
; - specs text : line  19
; - description: lines 21-27

; Pattern tables and palettes:
; - Background (PT0): different for each game (but title screen shares data
;   with Donkey Kong screen).
; - Sprites (PT1): do not change.

; Title screen background (hex/char):
;
; 4d 4e 4f 9a 9f a0 a2 a4 a7 a8 b8 b9 ba bb bc bd be bf
; U  0  2  B  G  L  J  C  F  M  W  P  K  D  H  Y  N  I
;
; c0 c3 c4 c7 ca cb cc cd ce
; S  T  R  V  '  A  E  _  O

; BG PT data for Golf (143 = $8f tiles):
;   Compressed:
;     03 2a 7e 38 7c c6 82 92 f2 73 7c fe 82 fe 7c 28
;     fe 80 83 bf 51 fe 12 02 07 08 1c 3c 3a c0 f0 f8
;     ...
;   Decompressed:
;     00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
;     00 1f 30 60 67 63 33 1f  00 00 00 00 00 00 00 00
;     00 3e 63 63 63 63 63 3e  00 00 00 00 00 00 00 00
;     ...
; Except for Devil World, compressed data always starts with $03 $2a.

; --- Constants ---------------------------------------------------------------

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
oam_addr        equ $2003
ppu_scroll      equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007
dmc_freq        equ $4010
oam_dma         equ $4014
snd_chn         equ $4015
joypad1         equ $4016
joypad2         equ $4017

; $00xx used by bank 3 except where noted
ram_clr_ptr     equ $00  ; 2 bytes; overlaps
some_flag       equ $00  ; in nmi, wait_flag_chg, sub34
joypad1a        equ $02  ; in read_joypads
joypad1_prev    equ $03  ; in read_joypads
joypad1b        equ $04  ; in read_joypads, init
joypad2a        equ $05  ; in read_joypads
joypad2_prev    equ $06  ; in read_joypads
joypad2b        equ $07  ; in read_joypads
read_ptr1       equ $08  ; 2 bytes; in init, sub16, copy_nt
ptr1            equ $0e  ; 2 bytes; in init, copy_nt, sub23, sub24; overlaps
joypad1c        equ $0e  ; in read_joypads
joypad2c        equ $0f  ; in read_joypads
ram1            equ $3f  ; in nmi, init, sub20, sub23, sub24, sprite1a/b/c
ram2            equ $53  ; in nmi, init, sub19
ram3            equ $59  ; in nmi, init, sub23, sub24
ppu_ctrl_copy   equ $73
game_screen     equ $75  ; which game screen shown (0-13)
ram4            equ $76  ; in       sub19, sub20, sub21
ram5            equ $77  ; in init, sub19, sub20, sub21
ram6            equ $78  ; in       sub19, sub20, sub21, sub30
ram7            equ $79  ; in       sub19, sub20, sub21, sub30
ram8            equ $7a  ; in init, shift_left
nt_fill_column  equ $7b  ; in nmi, init, sub23, sub24, set_palette
nt_fill_byte    equ $7c  ; in nmi, sub16
nt_copy_column  equ $7d  ; in nmi, init, sub23, sub24, set_palette
nt_copy_array   equ $7e  ; 30 bytes; in nmi, sub23, sub24
ram9            equ $9e  ; in nmi, init, sub20, sub23, sub24
prg_bank        equ $a6  ; current PRG bank at CPU $8000-$bfff (0-3)
do_nmi          equ $a7  ; 0 = no, 1 = yes
bg_pal_copy     equ $a8  ; 16 bytes; copy of BG palettes
useless1        equ $f0  ; in sub16
temp            equ $f1  ; in sub16
useless2        equ $ff  ; in init

sprite_data     equ $0700  ; OAM page (used by bank 3)

; addresses in included binaries (assembled code or PT/NT/AT data)
pt_devil        equ pt_data1+$0000
nt_devil        equ nt_at_data1+ 0*$400  ; Devil World
nt_gomoku       equ nt_at_data1+ 1*$400  ; Gomokunarabe
nt_mahjong      equ nt_at_data1+ 2*$400  ; Mah-jong
nt_mario        equ nt_at_data1+ 3*$400  ; Mario Bros.
nt_baseball     equ nt_at_data1+ 4*$400  ; Baseball
nt_dk3          equ nt_at_data1+ 5*$400  ; Donkey Kong 3
nt_dkjrmath     equ nt_at_data1+ 6*$400  ; Donkey Kong Jr. Math
nt_golf         equ nt_at_data1+ 7*$400  ; Golf
nt_pinball      equ nt_at_data1+ 8*$400  ; Pinball
nt_popeye       equ nt_at_data1+ 9*$400  ; Popeye
nt_popeyeen     equ nt_at_data1+10*$400  ; Popeye English
nt_tennis       equ nt_at_data1+11*$400  ; Tennis
nt_dkjr         equ nt_at_data1+12*$400  ; Donkey Kong Jr.
fs_init         equ famistudio+$0000
fs_play         equ famistudio+$00dd
fs_update       equ famistudio+$021b
pt_title_dk     equ pt_data2+$0000
pt_dkjr         equ pt_data2+$0669
pt_baseball     equ pt_data2+$0a55
pt_dk3          equ pt_data2+$0e06
pt_dkjrmath     equ pt_data2+$11d1
pt_golf         equ pt_data2+$156d
pt_gomoku       equ pt_data2+$18e1
pt_mahjong      equ pt_data2+$1cb3
pt_mario        equ pt_data2+$206e
pt_pinball      equ pt_data2+$2438
pt_popeye       equ pt_data2+$2800
pt_popeyeen     equ pt_data2+$2ba0
pt_tennis       equ pt_data2+$2f68
nt_title        equ nt_at_data2+0*$400  ; title screen
nt_dk           equ nt_at_data2+1*$400  ; Donkey Kong
dnt_decomp      equ donut+$00ff

; --- Macros ------------------------------------------------------------------

macro add _src
                clc
                adc _src
endm

macro sub _src
                sec
                sbc _src
endm

macro copy _src, _dst
                ; for clarity, don't use this if A is read later
                lda _src
                sta _dst
endm

; --- iNES header -------------------------------------------------------------

                base $0000
                db "NES", $1a
                db 4, 0                  ; 64 KiB PRG ROM, 8 KiB CHR RAM
                db %00100010, %00000000  ; mapper 2 (UxROM), horiz. mirroring,
                pad $0010, $00           ; has extra RAM

; --- Bank 0 ------------------------------------------------------------------

                base $8000
                pad $c000, $00

; --- Bank 1 ------------------------------------------------------------------

                base $8000

                ; BG PT data for Devil World (1012 bytes)
pt_data1        incbin "bpm-pt1.bin"

                ; uncompressed NT & AT data for all screens except for title
                ; screen and Donkey Kong (13 screens, 1024 bytes each)
nt_at_data1     incbin "bpm-nt-at1.bin"

                pad $c000, $00

; --- Bank 2 ------------------------------------------------------------------

                base $8000

famistudio      incbin "bpm-fs.bin"     ; Famistudio

                ; BG PT data for screens except for Devil World
                ; ($8c72; 13045 bytes total)
pt_data2        incbin "bpm-pt2.bin"

                pad $c000, $00          ; $bf67

; --- Bank 3 ------------------------------------------------------------------

                base $c000

udat6           ; unaccessed chunk; 640 bytes; 26 distinct bytes:
                ;     00 02 0a 0b 2b 2d 40 50 55 56 5a 5b 60
                ;     6a 6b 6d a0 ab ad b4 b5 b6 d4 d5 d6 da
                ;
                hex d6 5a 6b b5 d6 5a ab b5 d6 5a ad b5 d6 6a ad b5
                hex 5a 6b ad d5 5a 6b ad d6 5a 6b b5 d6 5a ab b5 d6
                hex 0a 00 00 00 6b ad b5 5a 6b ad d5 5a 6b ad d6 5a
                hex ab b5 d6 5a ad b5 d6 6a ad b5 56 6b ad b5 5a 6b
                hex ad 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex b6 d6 5a 6b 6b ad b5 d6 d6 5a 6b ad ad b5 d6 5a
                hex 5b 6b ad b5 b6 d6 5a 6b 6d ad b5 d6 02 00 00 a0
                hex ad b5 d6 5a 5b 6b ad b5 b6 d6 5a 6b 6d ad b5 d6
                hex da 5a 6b ad b5 b5 d6 5a 6b 6b ad b5 b6 d6 5a 6b
                hex 6d ad b5 d6 da 5a 6b ad b5 b5 d6 5a 6b 6b ad b5
                hex d6 d6 5a 6b 2d 00 00 00 da 5a 6b ad b5 b5 d6 5a
                hex 6b 6b ad b5 d6 d6 5a 6b ad ad b5 d6 5a 5b 6b ad
                hex b5 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex b6 b6 d6 d6 d6 da da 5a 5b 5b 6b 6b 6b 6d 6d ad
                hex ad ad b5 b5 b5 b6 b6 d6 d6 02 00 00 50 5b 5b 6b
                hex 6b 6b 6d 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6 da
                hex da 5a 5b 5b 6b 6b 6b 6d 6d ad ad ad b5 b5 b5 b6
                hex b6 d6 d6 d6 da da 5a 5b 5b 6b 6b 2b 00 00 00 ad
                hex ad b5 b5 b5 b6 b6 d6 d6 da da 5a 5b 5b 6b 6b 6b
                hex 6d 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6 da da 5a
                hex 5b 5b 6b 6b 6b 6d 6d ad ad ad b5 b5 b5 b6 00 00
                hex 00 d4 da da 5a 5b 5b 6b 6b 6b 6d 6d ad ad ad b5
                hex b5 b5 b6 b6 d6 d6 d6 da da 5a 5b 5b 6b 6b 6b 6d
                hex 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6 da da 5a 5b
                hex 0b 00 00 40 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6
                hex da da 5a 5b 5b 6b 6b 6b 6d 6d ad ad ad b5 b5 b5
                hex b6 b6 d6 d6 d6 da da 5a 5b 5b 6b 6b 6b 6d 6d ad
                hex ad ad b5 00 00 00 b4 d6 d6 d6 da da 5a 5b 5b 6b
                hex 6b 6b 6d 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6 da
                hex da 5a 5b 5b 6b 6b 6b 6d ad ad ad b5 b5 b5 b6 b6
                hex d6 d6 d6 da da 02 00 00 60 6b 6b 6d 6d ad ad ad
                hex b5 b5 b5 b6 b6 d6 d6 d6 da da 5a 5b 5b 6b 6b 6b
                hex 6d 6d ad ad ad b5 b5 b5 b6 b6 d6 d6 d6 da da 5a
                hex 5b 5b 6b 6b 6b 6d 6d 2d 00 00 00 b5 b5 b6 b6 d6
                hex d6 d6 da da 5a 5b 5b 6b 6b 6b 6d 6d ad ad ad b5
                hex b5 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55
                hex 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55 55

music_data      ; $c280; indirectly read by Famistudio
                incbin "bpm-mus.bin"

nmi             inc some_flag           ; $c598
                pha                     ; push A, Y, X
                tya
                pha
                txa
                pha
                ;
                lda do_nmi              ; skip all if flag clear
                beq +++
                ;
                lda prg_bank            ; store current PRG bank
                pha
                lda ram3
                bpl ++
                ;
                copy #%00011000, ppu_mask  ; show sprites & BG
                lda ppu_ctrl_copy
                ora #%00000100          ; autoincrement by 32 bytes
                sta ppu_ctrl
                ;
                ldy nt_fill_column      ; fill nt_fill_column (0-31) in NT0
                cpy #32                 ; with nt_fill_byte
                bcs +
                copy #$20, ppu_addr
                sty ppu_addr
                ldy #29
                lda nt_fill_byte
-               sta ppu_data
                dey
                bpl -
                ;
+               ldy nt_copy_column      ; copy nt_copy_array to nt_copy_column
                cpy #32                 ; (0-31) in NT0
                bcs +
                copy #$20,           ppu_addr
                copy nt_copy_column, ppu_addr
                ldy #0
-               lda nt_copy_array,y
                sta ppu_data
                iny
                cpy #30
                bne -
                ;
+               jsr set_palette
                ;
                copy #$00,          oam_addr  ; do OAM DMA
                copy #>sprite_data, oam_dma
                copy ppu_ctrl_copy, ppu_ctrl
                copy ram1,          ppu_scroll
                copy ram2,          ppu_scroll
                ;
++              lda #2                  ; run a sub in bank 2
                jsr bankswitch
                jsr fs_update
                ;
                pla                     ; restore original PRG bank
                sta prg_bank
                jsr bankswitch
                ;
+++             pla                     ; pull X, Y, A
                tax
                pla
                tay
                pla
                rti

irq             rti                     ; unaccessed

udat7           ; unaccessed chunk
                hex 0f 01 02 04 08 10 20 40  ; $c61c
                hex 80 00 10 20 30 40 50 60
                hex 70 80 90 a0 b0 c0 d0 e0
                hex f0

read_joypads    ; of the variables written, only joypad1b is actually used
                ; called by: init
                ;
                copy joypad1a, joypad1_prev
                copy joypad2a, joypad2_prev
                ;
                lda #$01
                sta joypad1a
                sta joypad1c
                sta joypad2a
                sta joypad2c
                sta joypad1
                lsr a
                sta joypad1
                ;
-               lda joypad1             ; 8 buttons -> joypad1a, joypad2a
                and #%00000011
                cmp #$01
                rol joypad1a
                lda joypad2
                and #%00000011
                cmp #$01
                rol joypad2a
                bcc -
                ;
                lda #$01
                sta joypad1
                lsr a
                sta joypad1
                ;
-               lda joypad1             ; 8 buttons -> joypad1c, joypad2c
                and #%00000011
                cmp #$01
                rol joypad1c
                lda joypad2
                and #%00000011
                cmp #$01
                rol joypad2c
                bcc -
                ;
                lda joypad1c
                cmp joypad1a
                beq +
                copy joypad1_prev, joypad1a  ; $c685 (unaccessed)
+               lda joypad2c
                cmp joypad2a
                beq +
                copy joypad2_prev, joypad2a  ; $c68f (unaccessed)
                ;
+               lda joypad1a
                and #%00000011
                cmp #%00000011
                bne +
                eor joypad1a            ; $c69b (unaccessed)
                sta joypad1a            ; unaccessed
                ;
+               lda joypad1a
                and #%00001100
                cmp #%00001100
                bne +
                eor joypad1a            ; unaccessed ($c6a7)
                sta joypad1a            ; unaccessed
                ;
+               lda joypad2a
                and #%00000011
                cmp #%00000011
                bne +
                eor joypad2a            ; unaccessed ($c6b3)
                sta joypad2a            ; unaccessed
                ;
+               lda joypad2a
                and #%00001100
                cmp #%00001100
                bne +
                eor joypad2a            ; unaccessed ($c6bf)
                sta joypad2a            ; unaccessed
                ;
+               lda joypad1a
                ora joypad1_prev
                eor joypad1_prev
                sta joypad1b
                ;
                lda joypad2a
                ora joypad2_prev
                eor joypad2_prev
                sta joypad2b
                rts

init            ; initialization and main loop
                ;
                sei
                ldx #%00000000
                stx ppu_ctrl
                stx ppu_mask
                cld
                copy #%01000000, joypad2
                stx dmc_freq
                stx snd_chn
                ;
                bit ppu_status
-               bit ppu_status
                bpl -
                ;
                txa
                ldy #$07
                sty ram_clr_ptr+1
                tay
                sta ram_clr_ptr+0
                ;
-               sta (ram_clr_ptr),y
                iny
                bne -
                dec ram_clr_ptr+1
                bpl -
                ;
                sta ram_clr_ptr+1
                ldx #$f0
                txs
                ;
-               bit ppu_status
                bpl -
                ;
                lda #$21
                sta nt_fill_column
                sta nt_copy_column
                copy #$cf, ram8
                ;
                lda #0
                sta ram3
                sta do_nmi
                ldy #%10001000          ; enable NMI, PT1 for sprites
                sty ppu_ctrl_copy
                sty ppu_ctrl
                jsr sub34
                tay
                lda dat26,y
                sta ptr1+0
                sta useless2
                ;
                lda #2
                jsr bankswitch
                ;
                ldx #<music_data        ; music data
                ldy #>music_data
                lda ptr1+0              ; platform
                jsr fs_init
                ;
                copy #$01, do_nmi
                lda #0
                sta ram9
                sta ram3
                sta game_screen
                sta ram1
                sta ram2
                jsr fs_play
                jsr sub16
                ;
                ; copy 768 bytes from nt_dk to NT0
                ; (note: the label nt_dk must be in parentheses)
                copy #$20, ptr1+0
                copy #$00, ptr1+1
                copy #<(nt_dk), read_ptr1+0
                copy #>(nt_dk), read_ptr1+1
                ldy game_screen
                lda nt_data_banks,y
                jsr bankswitch
                jsr copy_nt
                ;
                jsr wait_flag_chg
                ;
                copy #$3f, ppu_addr     ; copy 16 bytes from pal_title_dk
                copy #$00, ppu_addr     ; to BG subpalettes
                copy #<pal_title_dk, read_ptr1+0
                copy #>pal_title_dk, read_ptr1+1
                ldy #0
-               lda (read_ptr1),y
                sta bg_pal_copy,y
                iny
                cpy #16
                bcc -
                ;
                copy #$3f, ppu_addr     ; set sprite palette
                copy #$11, ppu_addr
                copy #$00, ppu_data
                copy #$10, ppu_data
                copy #$20, ppu_data
                ;
                copy #$10, ppu_addr     ; copy sprite PT data to PT1
                copy #$00, ppu_addr     ; ($70 bytes or 7 tiles)
                ldy #0
                sty ram3
-               lda spr_pt_data,y
                sta ppu_data
                iny
                cpy #$70
                bcc -
                ;
                copy #<$0028, ptr1+0
                copy #>$0028, ptr1+1
                copy #<nt_title, read_ptr1+0
                copy #>nt_title, read_ptr1+1
                jsr copy_nt             ; copy 768 bytes to PPU
                ;
                lda ppu_ctrl_copy       ; use NT2
                and #%11111100
                ora #%00000010
                sta ppu_ctrl_copy
                sta ppu_ctrl
                ;
                lda #0
                sta ppu_scroll
                sta ppu_scroll
                ;
                copy #$a5, ram5
                jsr hide_sprites
                copy #$ff, ram3
                ;
-               jsr wait_flag_chg
                jsr shift_left
                copy #$00, ram3
                jsr sub19
                copy #$ff, ram3
                jsr read_joypads
                lda joypad1b
                and #%10010000          ; A/start
                beq -
                ;
-               jsr wait_flag_chg
                copy #$00, ram3
                lda ram2
                add #$04
                cmp #$f0
                bcs +
                sta ram2
                jsr sub19
                lda #$ff
                sta ram3
                bne -                   ; unconditional
                ;
+               jsr hide_sprites
                jsr sub21
                copy #$00, ram2
                lda ppu_ctrl_copy       ; use NT0
                and #%11111100
                sta ppu_ctrl_copy
                ;
-               jsr wait_flag_chg
                jsr shift_left
                copy #$00, ram9
                jsr read_joypads
                copy #$00, ram3
                jsr sub20
                jsr sprite1a
                lda joypad1b
                and #%00000011          ; left/right
                beq ++
                and #%00000010          ; left
                bne +
                jsr sub23
                jmp ++
+               jsr sub24
++              copy #$ff, ram3
                jmp -

sub16           ; called by: init, sub23, sub24
                ;
                copy #$00, ppu_mask
                jsr wait_flag_chg
                ldy game_screen
                lda nt_fill_bytes,y
                sta nt_fill_byte
                tya
                asl a
                tay
                ;
                lda pal_data_ptrs,y     ; copy 16 bytes to PPU
                sta read_ptr1+0
                lda pal_data_ptrs+1,y
                sta read_ptr1+1
                ldy #0
-               lda (read_ptr1),y
                sta bg_pal_copy,y
                iny
                cpy #16
                bcc -
                ;
                copy #$00, ppu_addr
                copy #$00, ppu_addr
                ;
                ldy game_screen
                lda pt_data_banks,y
                jsr bankswitch
                ;
                lda game_screen
                asl a
                tax
                lda pt_data_ptrs+0,x
                sta temp
                lda pt_data_ptrs+1,x
                sta useless1
                lda useless1
                ldy temp
                ldx #$40
                jsr dnt_decomp
                ;
                copy #$20, ppu_addr     ; fill NT0 with byte
                copy #$00, ppu_addr
                ldy #0
                ldx #4
                lda nt_fill_byte
-               sta ppu_data
                dey
                bne -
                dex
                bne -
                ;
                ldy game_screen
                lda nt_data_banks,y
                jsr bankswitch
                ;
                copy #$23, ppu_addr     ; copy AT data from array specified
                copy #$c0, ppu_addr     ; by game_screen to AT0
                lda game_screen
                asl a
                tay
                lda nt_data_ptrs+0,y
                add #<$03c0
                sta read_ptr1+0
                lda nt_data_ptrs+1,y
                adc #>$03c0
                sta read_ptr1+1
                ldy #0
-               lda (read_ptr1),y
                sta ppu_data
                iny
                cpy #64
                bcc -
                ;
                copy ppu_ctrl_copy, ppu_ctrl
                lda #0
                sta ppu_scroll
                sta ppu_scroll
                rts

; -----------------------------------------------------------------------------

                ; These arrays are read using game_screen. Values:
                ;  0: Donkey Kong
                ;  1: Donkey Kong Jr.
                ;  2: Popeye
                ;  3: Gomokunarabe
                ;  4: Mah-jong
                ;  5: Mario Bros.
                ;  6: Popeye English
                ;  7: Baseball
                ;  8: Donkey Kong Jr. Math
                ;  9: Tennis
                ; 10: Pinball
                ; 11: Golf
                ; 12: Donkey Kong 3
                ; 13: Devil World

nt_fill_bytes   hex cd 00 00 00
                hex 00 00 00 00
                hex 00 00 00 00
                hex 00 97

pt_data_banks   db 2, 2, 2, 2
                db 2, 2, 2, 2
                db 2, 2, 2, 2
                db 2, 1

nt_data_banks   db 1, 1, 1, 1
                db 1, 1, 1, 1
                db 1, 1, 1, 1
                db 1, 1

pt_data_ptrs    ; pointers to BG PT data
                dw pt_title_dk, pt_dkjr,   pt_popeye,   pt_gomoku
                dw pt_mahjong,  pt_mario,  pt_popeyeen, pt_baseball
                dw pt_dkjrmath, pt_tennis, pt_pinball,  pt_golf
                dw pt_dk3,      pt_devil

nt_data_ptrs    dw nt_dk,       nt_dkjr,   nt_popeye,   nt_gomoku
                dw nt_mahjong,  nt_mario,  nt_popeyeen, nt_baseball
                dw nt_dkjrmath, nt_tennis, nt_pinball,  nt_golf
                dw nt_dk3,      nt_devil

pal_data_ptrs   dw pal_title_dk, pal_dkjr,   pal_popeye,   pal_gomoku
                dw pal_mahjong,  pal_mario,  pal_popeyeen, pal_baseball
                dw pal_dkjrmath, pal_tennis, pal_pinball,  pal_golf
                dw pal_dk3,      pal_devil

; -----------------------------------------------------------------------------

copy_nt         ; copy 768 bytes from read_ptr1 to PPU ptr1; called by: init
                ;
                bit ppu_status
                copy ptr1+0, ppu_addr
                copy ptr1+1, ppu_addr
                ;
                ldx #3
                ldy #0
-               lda (read_ptr1),y
                sta ppu_data
                iny
                bne -
                inc read_ptr1+1
                dex
                bpl -
                ;
                rts

                ; uncompressed NT & AT data for 2 screens, 1024 bytes each
                ; (title screen and Donkey Kong)
nt_at_data2     incbin "bpm-nt-at2.bin"

                ; palette data ($d1ad; 16 bytes each)
                ; shades of gray      : 00 0f 10 20 2d 30
                ; dark colors         :    03 04 06          0b 0c
                ; medium-dark colors  : 12    14 16 17    1a 1b 1c
                ; medium-bright colors: 22 23    26 27 28 2a    2c
                ; bright colors       :             37 38       3c
                ;
pal_baseball    hex  0f 30 03 23  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_title_dk    hex  0f 16 26 20  0f 20 16 26  0f 20 26 16  0f 16 20 26
pal_dk3         hex  0f 30 06 16  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_dkjr        hex  0f 30 10 22  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_dkjrmath    hex  0f 30 12 22  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_golf        hex  0f 30 2c 3c  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_gomoku      hex  0f 30 2d 00  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_mahjong     hex  0f 30 0b 1b  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_mario       hex  0f 30 17 27  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_pinball     hex  0f 30 28 38  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_popeye      hex  0f 30 1a 2a  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_popeyeen    hex  0f 30 27 37  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_tennis      hex  0f 30 04 14  0f 0f 0f 0f  0f 0f 0f 0f  0f 0f 0f 0f
pal_devil       hex  0f 0c 1c 20  0f 0c 1c 26  0f 20 26 0f  0f 0f 0f 0f

spr_pt_data     ; sprite PT data ($70 bytes or 7 tiles)
                hex  00 00 00 18 18 00 00 00  00 00 00 18 18 00 00 00
                hex  00 00 10 38 10 00 00 00  00 10 10 7c 10 10 00 00
                hex  80 04 10 38 10 40 02 00  00 40 38 38 38 04 00 00
                hex  10 00 38 38 38 00 10 00  00 10 10 7c 10 10 00 00
                hex  02 40 10 38 10 04 80 00  00 04 38 38 38 40 00 00
                hex  00 00 38 ba 38 00 00 00  00 10 10 7c 10 10 00 00
                hex  cc aa 00 00 00 00 00 00  cc aa 00 00 00 00 00 00

; -----------------------------------------------------------------------------

hide_sprites    ; hide all sprites; called by: init
                ;
                ldy #0
                lda #$ff
-               sta sprite_data,y
                iny
                iny
                iny
                iny
                bne -
                rts

sub19           ; sprite stuff; called by: init
                ;
                lda ram4
                add #1
                cmp #$86
                bcc ++
                lda ram6
                cmp #$01
                beq +
                copy #$01, ram6
                copy #$00, ram7
                jmp +++
+               ldy ram7
                iny
                sty ram7
                cpy #$0a
                bcc +++
                copy #$ff, ram5
                cpy #$40
                bcc +++
                lda #0
                sta ram6
                sta ram7
                sta ram4
                copy #$a5, ram5
                jmp +++
                ;
++              sta ram4
                jsr sub30
+++             copy ram4, sprite_data+3
                lda ram5
                cmp #$f0
                bcs +
                sub ram2
                bcs +
                lda #$ff
+               sta sprite_data+0
                copy ram6, sprite_data+1
                copy #$00, sprite_data+2
                rts

sub20           ; called by: init, sub23, sub24
                ;
                lda ram9
                beq +
                lda ram6
                cmp #$06
                bcs +
                copy #$06, ram6
                copy #$00, ram7
+               lda ram7
                add #$01
                sta ram7
                cmp #$06
                bcc ++
                copy #$00, ram7
                lda ram6
                add #1
                cmp #$07
                bcc +
                copy #$ff, ram5
                jsr shift_left
                cmp #$40
                bcs ++
                jsr shift_left
                lda ram9
                bne ++
                jsr sub21
                jmp ++
+               sta ram6
++              lda ram4
                add #$39
                sub ram1
                bcc ++
                sta sprite_data+3
                lda ram5
                cmp #$ff
                beq +
                add #$23
+               sta sprite_data+0
                ldy ram6
                lda dat23,y
                sta sprite_data+1
                copy #%00000000, sprite_data+2
                rts
++              copy #$ff, sprite_data+0
                rts

sub21           ; called by: init, sub20
                ;
                lda #0
                sta ram7
                sta ram6
                ;
                jsr shift_left
                ;
-               cmp #$90                ; A modulo $90 -> ram4
                bcc +
                sbc #$90
                jmp -
+               sta ram4
                ;
                jsr shift_left
                ;
-               cmp #$4c                ; A modulo $4c -> ram5
                bcc +
                sbc #$4c
                jmp -
+               sta ram5
                ;
                rts

dat23           hex 00 01 02 03 04 05 01

shift_left      ; shift ram8 left; if carry, XOR with %11001111
                ; called by: init, sub20, sub21
                ;
                lda ram8
                asl a
                bcc +
                eor #%11001111
+               sta ram8
                rts

macro copy_nt_column
                ; copy 30 bytes to nt_copy_array; source:
                ; - array  specified by game_screen
                ; - offset specified by Y (nt_copy_column)
                ; - step size 32
                ; called by: sub23, sub24
                ;
                lda game_screen         ; load ptr1 with array specified
                asl a                   ; by game_screen
                tax
                lda nt_data_ptrs+0,x
                sta ptr1+0
                lda nt_data_ptrs+1,x
                sta ptr1+1
                ;
                ldx #0                  ; starting from (ptr1),y
-               lda (ptr1),y            ; copy 30 bytes in increments of 32
                sta nt_copy_array,x     ; to nt_copy_array
                lda ptr1+0
                add #32
                sta ptr1+0
                lda ptr1+1
                adc #0
                sta ptr1+1
                inx
                cpx #30
                bcc -
endm

sub23           ; called by: init
                ;
                copy #$01, ram9
                copy #$00, ram1
                ;
-               jsr wait_flag_chg
                copy #$00, ram3
                lda ram1
                add #$08
                sta ram1
                beq +
                sub #$08
                lsr a
                lsr a
                lsr a
                sta nt_fill_column
                jsr sub20
                jsr sprite1b
                copy #$ff, ram3
                jmp -
                ;
+               copy #$00, ram1
                ldy game_screen
                iny
                cpy #14
                bcc +
                ldy #0
+               sty game_screen
                jsr sub16
                copy #$00, ram1
                lda #$ff
                sta ram3
                sta nt_copy_column
                sta nt_fill_column
                ;
--              jsr wait_flag_chg
                copy #$00, ram3
                lda ram1
                add #8
                sta ram1
                beq +
                sub #8
                ;
                lsr a
                lsr a
                lsr a
                sta nt_copy_column
                tay
                ;
                copy_nt_column          ; to nt_copy_array (macro)
                ;
                jsr sprite1c
                copy #$ff, ram3
                jmp --
                ;
+               jsr sprite1a
                copy #$00, ram9
                rts

sub24           ; called by: init
                ;
                copy #$01, ram9
                copy #$00, ram1
                ;
-               jsr wait_flag_chg
                copy #$00, ram3
                lda ram1
                sub #8
                sta ram1
                beq +
                lsr a
                lsr a
                lsr a
                sta nt_fill_column
                jsr sub20
                jsr sprite1c
                copy #$ff, ram3
                jmp -
                ;
+               copy #$00, ram1
                ldy game_screen
                dey
                bpl +
                ldy #13
+               sty game_screen
                jsr sub16
                copy #$00, ram1
                lda #$ff
                sta ram3
                sta nt_copy_column
                sta nt_fill_column
                ;
--              jsr wait_flag_chg
                copy #$00, ram3
                lda ram1
                sub #8
                sta ram1
                beq +
                ;
                lsr a
                lsr a
                lsr a
                sta nt_copy_column
                tay
                ;
                copy_nt_column          ; to nt_copy_array (macro)
                ;
                jsr sprite1b
                copy #$ff, ram3
                jmp --
                ;
+               jsr sprite1a
                copy #$00, ram9
                rts

bankswitch      ; map PRG bank specified by A (0-3) to CPU $8000-$bfff
                ; called by: nmi, init, sub16
                ;
                tay
                sta prg_bank
                sta id_table,y
                rts

id_table        hex 00 01 02 03

sprite1a        ; do something to sprite 1
                ; sprite1a/b/c called by: init, sub23, sub24
                ;
                lda game_screen
                cmp #13
                bne +
                copy #$2d,       sprite_data+4+0
                copy #$06,       sprite_data+4+1
                copy #%00000000, sprite_data+4+2
                lda #$51
                sub ram1
                sta sprite_data+4+3
                rts
                ;
sprite1b        lda ram1
                cmp #$58
                bcs +
                jmp sprite1a
                ;
sprite1c        lda ram1
                cmp #$50
                bcc +
                jmp sprite1a
                ;
+               copy #$ff, sprite_data+4+0
                rts

wait_flag_chg   ; wait until some_flag changes
                ; called by: init, sub16, sub23, sub24
                ;
                lda some_flag
-               cmp some_flag
                beq -
                rts

sub30           ; called by: sub19
                ;
                lda ram7
                add #1
                cmp #10
                bcc ++
                lda ram6
                add #1
                cmp #6
                bcc +
                lda #$02
+               sta ram6
                lda #0
++              sta ram7
                rts

set_palette     ; called by: nmi
                ;
                lda nt_fill_column      ; exit if there are NT columns to
                cmp #32                 ; fill/copy
                bcc +
                lda nt_copy_column
                cmp #32
                bcc +
                ;
                lda ppu_ctrl_copy       ; autoincrement by 1 byte
                and #%11111011
                sta ppu_ctrl
                ;
                copy #$3f, ppu_addr     ; copy bg_pal_copy to BG palettes
                copy #$00, ppu_addr
                ldy #0
-               lda bg_pal_copy,y
                sta ppu_data
                iny
                cpy #16
                bcc -
                ;
+               rts

donut           incbin "bpm-dnt.bin"    ; Donut ($d5cd)
                pad $ffd0, $00

sub34           ; called by: init
                ;
                ldx #0
                ldy #0
                lda some_flag
-               cmp some_flag
                beq -
                lda some_flag
-               inx
                bne +
                iny
+               cmp some_flag
                beq -
                tya
                sub #10
                cmp #3
                bcc +
                lda #3                  ; $ffec (unaccessed)
+               rts

dat26           hex ff

                pad $fffa, $00
                dw nmi, init, irq       ; IRQ unaccessed
