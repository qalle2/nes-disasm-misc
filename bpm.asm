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

sq1_vol         equ $4000
sq1_sweep       equ $4001
sq1_lo          equ $4002
sq1_hi          equ $4003
sq2_vol         equ $4004
sq2_sweep       equ $4005
sq2_lo          equ $4006
sq2_hi          equ $4007
tri_linear      equ $4008
tri_lo          equ $400a
tri_hi          equ $400b
noise_vol       equ $400c
noise_lo        equ $400e
noise_hi        equ $400f
dmc_freq        equ $4010
dmc_raw         equ $4011
dmc_start       equ $4012
dmc_len         equ $4013
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
ram10           equ $9f  ; bank 2
ram11           equ $a0  ; bank 2
ram12           equ $a1  ; bank 2
read_ptr2       equ $a2  ; 2 bytes; bank 2
ptr2            equ $a4  ; 2 bytes; bank 2
prg_bank        equ $a6  ; current PRG bank at CPU $8000-$bfff (0-3)
do_nmi          equ $a7  ; 0 = no, 1 = yes
bg_pal_copy     equ $a8  ; 16 bytes; copy of BG palettes
some_array      equ $b8  ; decomp_pt_data2: 8 bytes
index_var       equ $c0  ; decomp_pt_data2: some index
bitop_var1      equ $c1  ; decomp_pt_data2: some bitops
pt_dat_out_len  equ $c2  ; decomp_pt_data2: length of decompressed PT data
bitop_var2      equ $c3  ; decomp_pt_data2: some bitops
pt_out_len_trg  equ $c4  ; decomp_pt_data2: target of pt_dat_out_len
xor_mask        equ $c5  ; decomp_pt_data2
bitop_var3      equ $c6  ; decomp_pt_data2: some bitops
pt_data_ptr     equ $c7  ; 2 bytes
deco_dat_left   equ $c9  ; PT data left to decompress (unit = 4 tiles?)
useless1        equ $f0  ; in sub16
temp            equ $f1  ; in sub16
useless2        equ $ff  ; in init

stack           equ $0100  ; used by bank 3

; $02xx used by bank 2
arr10           equ $0200
addr_tbl_lo     equ $0216
addr_tbl_hi     equ $0221
arr13           equ $022b
arr14           equ $022c
arr15           equ $0237
arr16           equ $023a
arr17           equ $023d
arr18           equ $0240
arr19           equ $0243
arr20           equ $0246
arr21           equ $0249
arr22           equ $024c
arr23           equ $0250
arr24           equ $0254
arr25           equ $0258
arr26           equ $025d
arr27           equ $0262
arr28           equ $0267
arr29           equ $026c
arr30           equ $0271
arr31           equ $0276
arr32           equ $027b
arr33           equ $0280
arr34           equ $0285
arr35           equ $028a
arr36           equ $028f
arr37           equ $0294  ; values for read_ptr2
ram60           equ $02a5
ram61           equ $02a6
ram62           equ $02a7
ram63           equ $02a8
ram64           equ $02a9
ram65           equ $02aa
ram66           equ $02ab
ram67           equ $02ac
ram68           equ $02ad
ram69           equ $02ae
ram70           equ $02af
ram71           equ $02b0
ram72           equ $02b1
ram73           equ $02b2
arr38           equ $02b3
arr39           equ $02b4
arr40           equ $02b5
arr41           equ $02b6
arr42           equ $02b7
arr43           equ $02b8
arr44           equ $02b9
arr45           equ $02ba
arr46           equ $02bb
arr47           equ $02bc
arr48           equ $02bd
arr49           equ $02be
arr50           equ $02bf
arr51           equ $02c0
arr52           equ $02c1

sprite_data     equ $0700  ; OAM page (used by bank 3)

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

pt_devil        ; BG PT data for Devil World
                hex 48 e0 3f 7f ff 1f 01 03 07 0f 1f fc 18 30 60 c0
                hex 80 00 ff b3 66 cc 98 31 63 c6 8c 49 ff fd fb f6
                hex ed db b6 6c d9 81 ff fe 7b 78 fc 96 92 f2 60 77
                hex 0c 9e 92 d2 7e 3c 49 3a 80 84 fe 80 5f fe 30 78
                hex ec c6 82 c1 fb fe ff d2 fb ff fb f8 48 c7 fe ff
                hex 83 f9 c1 ff 66 33 19 8c c6 63 31 18 f8 0c 06 03
                hex 01 00 3f 80 c0 e0 f0 f8 fc 93 7f 01 7f f8 0f 3f
                hex 7f 6f 4f 80 02 87 4f 6f 7f 3f 80 02 80 4f 80 02
                hex 49 7e 38 7c c6 82 92 f2 51 fe 12 02 3c 80 ec 6c
                hex 00 7d 30 38 2c 26 fe 20 49 73 6c fe 92 fe 6c 5e
                hex fe 1c 38 70 fe 5e fe 1c 38 1c fe 7b 38 7c c6 82
                hex c6 44 49 52 fe 10 fe 5e fe 70 38 70 fe 53 fe 22
                hex 3e 1c 73 7c fe 82 fe 7c 49 28 66 00 14 c0 00 73
                hex 7e fe 80 fe 7e 53 fe 92 fe 6c 48 ff 3e 63 03 3e
                hex 60 66 3c 00 83 0c 3f 00 b7 63 7f 63 36 1c 00 f9
                hex 08 1c 3e 77 63 00 43 af 28 fe 80 2a 82 fe 82 01
                hex 01 06 01 03 e0 0d 01 00 d8 0f 03 01 00 42 a2 d0
                hex 30 18 00 1f 25 26 74 24 00 fb 67 6e 7c 67 63 7e
                hex 00 43 af 51 fe 92 82 57 fe 82 c6 7c 38 77 fc 03
                hex 00 80 60 10 81 ff 7f 90 7c bc 80 fc 43 ea 07 08
                hex 1c 3c 3a c0 f0 f8 fc 60 80 e3 d8 ff f8 fe 3e a7
                hex 3b fa ff fe fb 48 a7 80 ff 9e c3 e3 96 3f 01 07
                hex 3c e8 21 a1 a7 87 a7 3c ff e0 ff 3f 68 e7 c7 e7
                hex ff 1f 8f c8 06 60 2f 07 20 3e 3f 07 00 ff 00 49
                hex 80 91 ff cc 98 31 63 c6 8c 18 30 f0 60 c0 80 00
                hex bf 91 31 63 c6 8c 18 30 a2 e7 81 07 ff 80 05 81
                hex 00 0f 87 05 3b c7 df c0 1f 3f 1c 30 3c 3f a2 bd
                hex 81 00 f8 81 f0 ff 80 d0 c0 fc fe 01 80 87 d0 ee
                hex f1 fc 4c e6 50 20 00 ff 00 08 ff ae 55 00 c0 3f
                hex 00 18 c0 ff be 7e 40 7f 00 ff 00 08 ff 06 ff 00
                hex 08 ff 4d a7 54 b4 f4 14 f4 80 0f c3 f4 34 f4 54
                hex 80 0f b0 74 f4 d4 80 0f ac f4 14 f4 74 80 0f 4d
                hex b9 14 f4 14 34 54 80 0f b1 14 f4 d4 f4 80 0f c1
                hex f4 74 f4 80 0f f8 54 b4 f4 74 34 80 0f 4d 81 f4
                hex 74 80 0f e5 34 94 54 14 f4 80 0f 81 f4 e8 81 0f
                hex 1f e0 34 74 f4 80 0f a2 fe 02 00 60 ff 00 80 fe
                hex 82 80 00 d0 3f 7f ff de ee de be 7e fe fd ae fe
                hex fc f8 e0 00 52 f5 e2 fd 03 ff 00 02 00 88 45 44
                hex 80 fe d7 3e be 02 06 fc 1c d3 fc ff f8 ff f8 02
                hex f5 07 20 50 47 a8 24 ff 00 07 52 55 75 a8 f8 ff
                hex 00 a1 21 27 a7 a7 03 7f 07 03 01 02 7f ef a7 e7
                hex ff 7f 63 79 7c 06 66 55 a8 79 ff 00 e0 11 51 d1
                hex e0 2e 6e ee 80 44 80 ba 02 eb 88 44 45 88 ba bb
                hex 7f 9f f0 67 60 64 71 5f 79 7f 40 64 24 26 f0 40
                hex c0 80 00 0b ff 7f 3e 02 fb f0 66 40 7f 00 0a ff
                hex fc 61 ff 99 e0 01 1f 6d be a2 eb c9 7f f0 90 68
                hex 0f 00 eb 0f 03 00 ff 31 21 02 7b 0b ff 83 03 77
                hex f7 1c 18 19 4c 4e 01 01 66 1f 11 10 24 b0 48 f9
                hex 00 a9 07 00 ff 7f 02 ef b0 24 3b 00 e9 c0 80 00
                hex ff f0 7b 7f 4c 4d cd cc cf 7f fc 64 a6 a3 20 64
                hex 7f 01 80 b0 49 79 00 09 ff 3f 02 d9 c0 20 00 e9
                hex c0 80 00 ff 21 7f 01 03 07 0f 1f 3f 7f 66 e0 20
                hex a0 20 80 ff 4c b0 20 e0 00 f8 20 21 e3 07 ff bc
                hex 11 51 d1 91 11 80 3f 80 11 80 3f 87 45 44 45 44
                hex 80 fe 52 fe d9 45 44 45 44 45 80 fe 87 d1 91 51
                hex d1 80 3f ff 91 51 d1 91 11 51 d1 91 80 3f 86 40
                hex 41 42 52 df 80 45 80 fe 80 3f 1e 3f c0 3f ff 06
                hex c0 00 1f ff 00 fe fd fb 04 00 63 ae ff f6 ed db
                hex b6 6c d9 b3 66 07 fe fd fb e0 15 16 17 80 f8 e0
                hex fd fe ff 63 bc ff b3 d9 6c b6 db ed f6 fb 81 17
                hex 0b 81 f8 fc 80 17 80 f8 42 fc 8e 01 81 41 a1 82
                hex ff 7f 80 7e 80 fe 80 d1 80 3f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00

nt_devil        ; NT & AT data for Devil World
                pad nt_devil+2*32, $2e
                hex 2e 2e 2e 2e 2e 2e 2e 2e 2e 2e 31 30 27 29 28 2e
                hex 1d 1f 2f 28 31 2e 2e 2e 2e 2e 2e 2e 2e 2e 2e 2e
                pad nt_devil+4*32, $2e
                hex 2e 2e 2e 2e 2e 2e 34 33 5c 5c 5c 5c 5c 5c 5c 5c
                hex 5c 5c 5c 5c 5c 5c 5c 5c 60 5f 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 32 4d 4c 4f 4e 51 50 53 52
                hex 55 54 57 56 59 58 5b 5a 5e 5d 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 61 65 64 69 68 38 37 3c 3b
                hex 3e 3d 0b 0a 0c 0f 01 00 96 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 88 63 62 67 66 36 35 3a 39
                hex 93 93 93 10 0f 0e 02 01 6a 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 6c 70 6f 74 73 78 77 7c 7b
                hex 80 7f 10 0f 0e 0d 03 02 82 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 6b 6e 6d 72 71 76 75 7a 79
                hex 7e 7d 0f 0e 0d 90 04 03 81 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 84 40 40 40 40 40 40 40 40
                hex 43 42 0e 0d 90 8f 05 04 86 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 83 3f 3f 3f 3f 3f 3f 3f 3f
                hex 8c 41 0d 90 8f 93 93 05 85 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 88 93 93 93 93 93 93 93 93
                hex 8d 8c 90 8f 93 93 93 93 96 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 89 87 8a 92 92 92 92 92 92 92
                hex 92 8b 8e 92 92 92 92 91 94 95 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 47 46 7f 7f 7f 7f 7f 7f 7f 7f
                hex 7f 7f 7f 7f 7f 7f 7f 7f 4b 4a 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 45 44 7f 7f 7f 7f 7f 7f 7f 7f
                hex 7f 7f 7f 7f 7f 7f 7f 7f 49 48 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2e 2e 2e 2e 2a 11 13 13 13 13 13 13 13
                hex 13 13 13 13 13 13 13 12 2b 2e 2e 2e 2e 2e 2e 2e
                pad nt_devil+18*32, $2e
                hex 2e 2e 2e 31 21 1f 21 2f 21 20 2e 1f 1b 25 1f 23
                hex 30 2f 2e 17 2d 2c 08 07 18 17 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 24 1e 30 1b 24 20 2e 08 06 09 23 2e 1e
                hex 2f 14 2e 16 2e 2e 18 09 23 2e 1b 1c 2f 2e 2e 2e
                pad nt_devil+21*32, $2e
                hex 2e 2e 2e 25 1c 30 2e 28 26 24 25 2e 1e 22 28 24
                hex 30 2e 28 29 19 30 2e 14 26 1a 30 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2f 30 28 30 26 24 30 31 2e 15 1f 2f 2e
                hex 25 1c 30 2e 15 26 1a 29 1b 1f 1a 21 2e 2e 2e 2e
                pad nt_devil+24*32, $2e
                hex 2e 2e 2e 2f 30 14 26 2f 31 30 31 2e 26 24 2e 23
                hex 30 29 19 14 2e 26 2e 2e 2e 2e 2e 2e 2e 2e 2e 2e
                hex 2e 2e 2e 2f 26 25 1c 30 2f 2e 22 19 22 24 22 26
                hex 28 2e 25 29 25 28 30 21 2e 2e 2e 2e 2e 2e 2e 2e
                pad nt_devil+30*32, $2e
                ;
                hex 00 00 00 00 00 00 00 00
                hex 00 40 a4 55 55 55 11 00
                hex 00 44 5a 5a 56 55 11 00
                hex 00 04 05 05 05 05 01 00
                pad nt_devil+30*32+8*8, $00

nt_gomoku       ; NT & AT data for Gomokunarabe
                pad nt_gomoku+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 01 02 03 02 04 05 06
                hex 07 08 07 09 0a 00 00 00 00 00 00 00 00 00 00 00
                pad nt_gomoku+4*32, $00
                hex 00 00 00 00 00 00 0b 0c 0d 0d 0d 0d 0d 0d 0d 0d
                hex 0d 0d 0d 0d 0d 0d 0d 0d 0e 0f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 11 12 13 14 15 16 17 18 19
                hex 1a 1b 1c 1d 1e 1f 20 21 22 23 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 24 25 26 27 28 29 2a 2b 2c
                hex 2d 2e 2f 30 31 32 33 34 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 38 39 3a 3b 3c 3d 3e 3f
                hex 40 40 40 41 32 42 43 33 44 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 45 46 47 48 49 4a 4b 4c 4d
                hex 4e 40 41 32 42 4f 50 43 51 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 52 53 54 55 56 57 58 59 5a
                hex 00 5b 32 42 4f 5c 5d 50 5e 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 5f 60 60 60 60 60 60 60 60
                hex 61 62 42 4f 5c 63 64 5d 65 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 66 67 67 67 67 67 67 67 67
                hex 68 69 4f 5c 63 40 40 64 6a 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 40 40 40 40 40 40 40 40
                hex 6b 68 5c 63 40 40 40 40 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 6c 6d 6e 6e 6e 6e 6e 6e 6e
                hex 6e 6f 70 6e 6e 6e 6e 71 72 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 73 74 75 75 75 75 75 75 75 75
                hex 75 75 75 75 75 75 75 75 76 77 00 00 00 00 00 00
                hex 00 00 00 00 00 00 78 79 75 75 75 75 75 75 75 75
                hex 75 75 75 75 75 75 75 75 7a 7b 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 7c 7d 7e 7e 7e 7e 7e 7e 7e
                hex 7e 7e 7e 7e 7e 7e 7e 7f 80 00 00 00 00 00 00 00
                pad nt_gomoku+18*32, $00
                hex 00 00 00 81 82 02 82 08 82 83 00 07 05 01 05 84
                hex 85 00 86 87 88 89 8a 8b 8c 8d 00 00 00 00 00 00
                hex 00 00 00 84 8e 0a 8f 84 83 00 8a 90 04 09 00 8e
                hex 08 01 00 91 00 00 8c 04 09 00 8f 92 08 00 00 00
                pad nt_gomoku+21*32, $00
                hex 00 00 00 85 92 0a 00 93 94 08 84 85 00 8e 02 08
                hex 85 00 02 93 00 07 00 06 02 06 95 00 00 00 00 00
                hex 00 00 00 07 08 8f 07 81 0a 00 01 07 03 0a 82 00
                hex 8e 96 07 97 0a 08 84 00 85 07 04 0a 00 00 00 00
                hex 00 00 00 85 05 08 06 84 00 85 08 97 94 06 01 00
                hex 85 02 00 93 02 08 03 00 07 00 00 00 00 00 00 00
                hex 00 00 00 96 94 06 0a 00 02 93 00 93 94 98 0a 00
                hex 09 96 07 8f 04 00 02 08 00 00 00 00 00 00 00 00
                hex 00 00 00 99 92 94 85 0a 00 84 85 02 06 0a 84 89
                hex 00 99 92 94 96 0a 00 07 96 84 02 00 00 00 00 00
                hex 00 00 00 85 08 97 94 06 01 00 85 02 00 02 05 85
                hex 99 94 85 00 85 92 0a 94 08 00 00 00 00 00 00 00
                hex 00 00 00 08 0a 84 8e 0a 8f 85 94 98 0a 00 02 8e
                hex 8e 02 06 0a 06 85 82 00 00 00 00 00 00 00 00 00
                pad nt_gomoku+30*32, $00
                ;
                pad nt_gomoku+30*32+8*8, $00

nt_mahjong      ; NT & AT data for Mah-jong
                pad nt_mahjong+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 01 02 03 04 05
                hex 06 07 08 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_mahjong+4*32, $00
                hex 00 00 00 00 00 00 09 0a 0b 0b 0b 0b 0b 0b 0b 0b
                hex 0b 0b 0b 0b 0b 0b 0b 0b 0c 0d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 0f 10 11 12 13 14 15 16 17
                hex 18 19 1a 1b 1c 1d 1e 1f 20 21 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 22 23 24 25 26 27 28 29 2a
                hex 2b 2c 2d 2e 2f 30 31 32 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 36 37 36 38 39 36 36 36
                hex 36 36 36 3a 30 3b 3c 31 3d 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 3e 3f 40 41 42 43 44 45 46
                hex 47 36 3a 30 3b 48 49 3c 4a 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 4b 4c 4d 4e 4f 50 51 52 53
                hex 54 55 30 3b 48 56 57 49 58 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 59 5a 5a 5a 5a 5a 5a 5a 5a
                hex 5b 5c 3b 48 56 5d 5e 57 5f 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 60 61 61 61 61 61 61 61 61
                hex 62 63 48 56 5d 36 36 5e 64 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 36 36 36 36 36 36 36 36
                hex 65 62 56 5d 36 36 36 36 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 66 67 68 68 68 68 68 68 68
                hex 68 69 6a 68 68 68 68 6b 6c 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6d 6e 6f 6f 6f 6f 6f 6f 6f 6f
                hex 6f 6f 6f 6f 6f 6f 6f 6f 70 71 00 00 00 00 00 00
                hex 00 00 00 00 00 00 72 73 6f 6f 6f 6f 6f 6f 6f 6f
                hex 6f 6f 6f 6f 6f 6f 6f 6f 74 75 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 76 77 78 78 78 78 78 78 78
                hex 78 78 78 78 78 78 78 79 7a 00 00 00 00 00 00 00
                pad nt_mahjong+18*32, $00
                hex 00 00 00 7b 7c 06 7c 7d 7c 7e 00 02 7f 08 7f 80
                hex 81 00 82 83 84 85 86 87 88 89 00 00 00 00 00 00
                hex 00 00 00 80 8a 8b 8c 80 7e 00 86 8d 8e 8f 00 8a
                hex 7d 08 00 90 00 00 88 8e 8f 00 8c 03 7d 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 97 97 97 97 00 00
                hex 00 00 97 97 97 97 97 97 97 97 00 00 00 00 00 00
                hex 00 00 00 02 97 8a 06 7d 81 97 06 91 97 81 03 8b
                hex 97 8a 06 8a 7f 93 02 7d 97 97 97 97 00 00 00 00
                hex 00 00 97 81 92 93 8b 04 8f 02 80 8b 7b 97 08 02
                hex 01 8b 97 7b 8b 95 8b 93 06 8a 8b 7b 97 00 00 00
                hex 00 00 97 92 07 97 86 87 84 97 8c 8b 07 81 7f 7d
                hex 94 97 8c 03 92 07 02 7c 97 97 97 97 97 00 00 00
                hex 00 00 97 97 97 97 97 97 97 97 97 97 97 97 97 97
                hex 97 97 97 97 97 97 97 97 97 00 00 00 00 00 00 00
                hex 00 00 97 81 03 92 80 97 08 02 01 8b 97 07 8b 8b
                hex 7b 80 97 02 97 93 06 81 97 06 91 00 00 00 00 00
                hex 00 00 00 8a 7d 02 8c 81 92 8c 8b 97 81 06 97 01
                hex 02 80 81 8b 7d 7c 97 97 97 97 97 00 00 00 00 00
                hex 97 97 97 97 97 97 97 97 97 97 97 97 97 97 97 97
                hex 97 97 97 97 97 97 97 97 97 97 97 97 00 00 00 00
                hex 00 00 00 00 00 97 97 97 97 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_mahjong+30*32, $00
                ;
                pad nt_mahjong+30*32+8*8, $00

nt_mario        ; NT & AT data for Mario Bros.
                pad nt_mario+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 01 02 03 04 05 00
                hex 06 03 05 07 08 00 00 00 00 00 00 00 00 00 00 00
                pad nt_mario+4*32, $00
                hex 00 00 00 00 00 00 09 0a 0b 0b 0b 0b 0b 0b 0b 0b
                hex 0b 0b 0b 0b 0b 0b 0b 0b 0c 0d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 0f 10 11 12 13 14 15 16 17
                hex 18 19 1a 1b 1c 1d 1e 1f 20 21 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 22 23 24 25 26 27 28 29 2a
                hex 2b 2c 2d 2e 2f 30 31 32 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 36 37 38 39 3a 3b 3c 3d
                hex 3e 3e 3e 3f 30 40 41 31 42 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 43 44 45 46 47 48 49 4a 4b
                hex 4c 3e 3f 30 40 4d 4e 41 4f 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 50 51 52 53 54 55 56 57 58
                hex 59 5a 30 40 4d 5b 5c 4e 5d 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 5e 5f 5f 5f 5f 5f 5f 5f 5f
                hex 60 61 40 4d 5b 62 63 5c 64 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 65 66 66 66 66 66 66 66 66
                hex 67 68 4d 5b 62 3e 3e 63 69 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 3e 3e 3e 3e 3e 3e 3e 3e
                hex 6a 67 5b 62 3e 3e 3e 3e 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 6b 6c 6d 6d 6d 6d 6d 6d 6d
                hex 6d 6e 6f 6d 6d 6d 6d 70 71 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 72 73 74 74 74 74 74 74 74 74
                hex 74 74 74 74 74 74 74 74 75 76 00 00 00 00 00 00
                hex 00 00 00 00 00 00 77 78 74 74 74 74 74 74 74 74
                hex 74 74 74 74 74 74 74 74 79 7a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 7b 7c 7d 7d 7d 7d 7d 7d 7d
                hex 7d 7d 7d 7d 7d 7d 7d 7e 7f 00 00 00 00 00 00 00
                pad nt_mario+18*32, $00
                hex 00 00 00 80 08 05 08 03 08 81 00 07 82 83 84 82
                hex 01 06 82 03 00 85 86 87 88 85 89 8a 00 00 00 00
                hex 00 00 00 07 83 82 8b 07 81 00 88 8c 8d 06 00 83
                hex 03 8e 00 8f 00 00 89 8d 06 00 8b 90 03 00 00 00
                pad nt_mario+21*32, $00
                hex 00 00 00 02 00 83 05 03 84 00 05 91 00 92 04 92
                hex 84 82 92 80 05 93 07 00 90 04 84 00 00 00 00 00
                hex 00 00 00 02 03 8b 02 80 82 00 8e 02 01 82 00 91
                hex 03 05 01 00 88 85 89 8a 08 00 00 00 00 00 00 00
                hex 00 00 00 84 90 04 07 00 8e 02 01 82 00 04 07 00
                hex 84 90 82 00 91 04 03 07 84 00 84 05 00 00 00 00
                hex 00 00 00 94 84 04 95 04 96 82 00 84 90 82 00 07
                hex 03 05 01 00 06 05 02 03 80 87 00 02 07 00 00 00
                hex 00 00 00 97 82 95 95 00 02 07 00 07 90 05 97 04
                hex 92 8e 00 92 04 92 84 82 92 80 05 93 07 00 00 00
                hex 00 00 00 01 02 03 04 05 00 02 92 80 00 95 94 04
                hex 8e 04 00 04 92 00 02 00 01 05 03 82 00 00 00 00
                hex 00 00 00 8b 94 03 03 82 92 84 00 07 84 98 95 82
                hex 08 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_mario+30*32, $00
                ;
                pad nt_mario+30*32+8*8, $00

nt_baseball     ; NT & AT data for Baseball
                pad nt_baseball+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 01 02 03 04
                hex 01 02 05 05 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_baseball+4*32, $00
                hex 00 00 00 00 00 00 06 07 08 08 08 08 08 08 08 08
                hex 08 08 08 08 08 08 08 08 09 0a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 0c 0d 0e 0f 10 11 12 13 14
                hex 15 16 17 18 19 1a 1b 1c 1d 1e 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 1f 20 21 22 23 24 25 26 27
                hex 28 29 2a 2b 2c 2d 2e 2f 30 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 32 33 34 35 36 37 38 39 3a
                hex 3b 3b 3b 3c 2d 3d 3e 2e 3f 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 40 41 42 43 44 45 46 47 48
                hex 49 3b 3c 2d 3d 4a 4b 3e 4c 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 4d 4e 4f 50 51 52 53 54 55
                hex 55 56 2d 3d 4a 57 58 4b 59 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 5a 5b 5b 5b 5b 5b 5b 5b 5b
                hex 5c 5d 3d 4a 57 5e 5f 58 60 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 61 62 62 62 62 62 62 62 62
                hex 63 64 4a 57 5e 3b 3b 5f 65 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 32 3b 3b 3b 3b 3b 3b 3b 3b
                hex 66 63 57 5e 3b 3b 3b 3b 30 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 67 68 69 69 69 69 69 69 69
                hex 69 6a 6b 69 69 69 69 6c 6d 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6e 6f 70 70 70 70 70 70 70 70
                hex 70 70 70 70 70 70 70 70 71 72 00 00 00 00 00 00
                hex 00 00 00 00 00 00 73 74 70 70 70 70 70 70 70 70
                hex 70 70 70 70 70 70 70 70 75 76 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 77 78 79 79 79 79 79 79 79
                hex 79 79 79 79 79 79 79 7a 7b 00 00 00 00 00 00 00
                pad nt_baseball+18*32, $00
                hex 00 00 00 7c 7d 7e 7d 7f 7d 80 00 7c 04 81 04 82
                hex 01 04 7f 00 83 84 85 86 87 88 89 00 00 00 00 00
                hex 00 00 00 03 8a 04 81 03 80 00 86 8b 8c 01 00 8a
                hex 7f 8d 00 8e 00 00 88 8c 01 00 81 8f 7f 00 00 00
                pad nt_baseball+21*32, $00
                hex 00 00 00 90 8f 04 00 91 92 7f 03 90 00 03 8a 7e
                hex 7f 90 03 00 8d 02 82 04 00 00 00 00 00 00 00 00
                hex 00 00 00 7f 04 05 04 02 03 04 7c 00 91 7e 7f 00
                hex 90 8f 04 00 91 02 82 92 81 7e 82 7d 00 00 00 00
                hex 00 00 00 02 03 00 91 7e 7f 00 90 8f 04 00 8d 02
                hex 82 04 00 92 90 03 04 05 91 00 00 00 00 00 00 00
                hex 00 00 00 7d 7d 7d 00 93 04 05 05 85 00 92 90 94
                hex 03 00 01 02 03 04 01 02 05 05 7d 00 00 00 00 00
                pad nt_baseball+30*32, $00
                ;
                pad nt_baseball+30*32+8*8, $00

nt_dk3          ; NT & AT data for Donkey Kong 3
                pad nt_dk3+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 01 02 03 04 05 06 00
                hex 04 02 03 07 00 08 00 00 00 00 00 00 00 00 00 00
                pad nt_dk3+4*32, $00
                hex 00 00 00 00 00 00 09 0a 0b 0b 0b 0b 0b 0b 0b 0b
                hex 0b 0b 0b 0b 0b 0b 0b 0b 0c 0d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 0f 10 11 12 13 14 15 16 17
                hex 18 19 1a 1b 1c 1d 1e 1f 20 21 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 22 23 24 25 26 27 28 29 2a
                hex 2b 2c 2d 2e 2f 30 31 32 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 36 37 38 39 3a 3b 3c 3d
                hex 3e 3f 3f 40 30 41 42 31 43 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 44 45 46 47 48 49 4a 4b 4c
                hex 4d 3f 40 30 41 4e 4f 42 50 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 51 52 53 54 55 56 57 58 59
                hex 5a 5b 30 41 4e 5c 5d 4f 5e 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 5f 60 60 60 60 60 60 60 60
                hex 61 62 41 4e 5c 63 64 5d 65 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 66 67 67 67 67 67 67 67 67
                hex 68 69 4e 5c 63 3f 3f 64 6a 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 35 3f 3f 3f 3f 3f 3f 3f 3f
                hex 6b 68 5c 63 3f 3f 3f 3f 33 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0e 6c 6d 6e 6e 6e 6e 6e 6e 6e
                hex 6e 6f 70 6e 6e 6e 6e 71 72 34 00 00 00 00 00 00
                hex 00 00 00 00 00 00 73 74 75 75 75 75 75 75 75 75
                hex 75 75 75 75 75 75 75 75 76 77 00 00 00 00 00 00
                hex 00 00 00 00 00 00 78 79 75 75 75 75 75 75 75 75
                hex 75 75 75 75 75 75 75 75 7a 7b 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 7c 7d 7e 7e 7e 7e 7e 7e 7e
                hex 7e 7e 7e 7e 7e 7e 7e 7f 80 00 00 00 00 00 00 00
                pad nt_dk3+18*32, $00
                hex 00 00 00 01 81 02 81 82 81 83 00 84 85 86 06 00
                hex 87 88 89 87 8a 8b 8c 00 00 00 00 00 00 00 00 00
                hex 00 00 00 8d 8e 05 8f 8d 83 00 87 90 04 91 00 8e
                hex 82 07 00 92 00 00 8b 04 91 00 8f 93 82 00 00 00
                pad nt_dk3+21*32, $00
                hex 00 00 00 94 93 05 00 94 93 95 82 01 00 96 8d 00
                hex 97 05 86 86 00 96 8d 00 98 95 03 96 86 00 00 00
                hex 00 00 00 07 96 99 05 00 95 03 00 94 93 05 00 01
                hex 02 03 04 05 06 00 04 02 03 07 00 00 00 00 00 00
                hex 00 00 00 8d 05 82 95 05 8d 81 00 94 93 95 8d 00
                hex 94 95 94 86 05 00 96 86 8d 02 00 00 00 00 00 00
                hex 00 00 00 98 05 96 94 85 82 05 8d 00 02 03 05 9a
                hex 93 95 94 00 97 02 03 01 05 82 00 00 00 00 00 00
                hex 00 00 00 8d 94 96 03 86 05 06 00 94 93 05 00 91
                hex 85 07 99 96 03 81 00 00 00 00 00 00 00 00 00 00
                pad nt_dk3+30*32, $00
                ;
                pad nt_dk3+30*32+8*8, $00

nt_dkjrmath     ; NT & AT data for Donkey Kong Jr. Math
                pad nt_dkjrmath+2*32, $00
                hex 00 00 00 00 00 00 01 02 03 04 05 06 00 04 02 03
                hex 07 00 08 09 0a 00 0b 0c 0d 0e 00 00 00 00 00 00
                pad nt_dkjrmath+4*32, $00
                hex 00 00 00 00 00 00 0f 10 11 11 11 11 11 11 11 11
                hex 11 11 11 11 11 11 11 11 12 13 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 15 16 17 18 19 1a 1b 1c 1d
                hex 1e 1f 20 21 22 23 24 25 26 27 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 28 29 2a 2b 2c 2d 2e 2f 30
                hex 31 32 33 34 35 36 37 38 39 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 3b 3c 3d 3e 3f 40 41 42 42
                hex 42 42 42 43 36 44 45 37 46 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 47 48 49 48 4a 4b 4c 48 48
                hex 4d 42 43 36 44 4e 4f 45 50 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 51 52 53 54 55 56 57 52 52
                hex 52 58 36 44 4e 59 5a 4f 5b 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 5c 5d 5d 5d 5d 5d 5d 5d 5d
                hex 5e 5f 44 4e 59 60 61 5a 62 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 63 64 64 64 64 64 64 64 64
                hex 65 66 4e 59 60 42 42 61 67 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 3b 42 42 42 42 42 42 42 42
                hex 68 65 59 60 42 42 42 42 39 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 14 69 6a 6b 6b 6b 6b 6b 6b 6b
                hex 6b 6c 6d 6b 6b 6b 6b 6e 6f 3a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 70 71 72 72 72 72 72 72 72 72
                hex 72 72 72 72 72 72 72 72 73 74 00 00 00 00 00 00
                hex 00 00 00 00 00 00 75 76 72 72 72 72 72 72 72 72
                hex 72 72 72 72 72 72 72 72 77 78 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 79 7a 7b 7b 7b 7b 7b 7b 7b
                hex 7b 7b 7b 7b 7b 7b 7b 7c 7d 00 00 00 00 00 00 00
                pad nt_dkjrmath+18*32, $00
                hex 00 00 00 01 0a 02 0a 09 0a 7e 00 01 05 7f 05 0b
                hex 80 05 09 00 81 82 83 84 81 85 86 87 00 00 00 00
                hex 00 00 00 88 89 05 7f 88 7e 00 81 8a 04 80 00 89
                hex 09 07 00 8b 00 00 86 04 80 00 7f 0e 09 00 00 00
                pad nt_dkjrmath+21*32, $00
                hex 00 00 00 0d 0e 05 00 88 05 7f 02 03 01 00 05 01
                hex 8c 0d 0c 8d 03 0b 05 03 0d 00 00 00 00 00 00 00
                hex 00 00 00 0d 8d 0d 8e 05 00 8d 03 00 03 8d 03 0d
                hex 05 03 01 02 8f 88 00 05 0c 09 8e 06 00 00 00 00
                hex 00 00 00 8e 8d 03 05 8c 89 0a 00 0e 02 90 05 91
                hex 05 09 84 00 0d 0e 8d 88 00 07 0c 0b 05 00 00 00
                hex 00 00 00 0b 0c 04 05 88 00 8c 88 05 00 02 92 00
                hex 0c 03 00 02 92 92 8d 7f 8d 0c 8e 00 00 00 00 00
                hex 00 00 00 8d 89 84 00 8c 03 8e 8d 04 05 00 89 02
                hex 89 05 06 05 00 05 03 07 8e 8d 88 0e 0a 00 00 00
                pad nt_dkjrmath+30*32, $00
                ;
                pad nt_dkjrmath+30*32+8*8, $00

nt_golf         ; NT & AT data for Golf
                pad nt_golf+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 01 02 03
                hex 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_golf+4*32, $00
                hex 00 00 00 00 00 00 05 06 07 07 07 07 07 07 07 07
                hex 07 07 07 07 07 07 07 07 08 09 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 0b 0c 0d 0e 0f 10 11 12 13
                hex 14 15 16 17 18 19 1a 1b 1c 1d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 1e 1f 20 21 22 23 24 25 26
                hex 27 28 29 2a 2b 2c 2d 2e 2f 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 31 32 33 34 35 36 37 32 32
                hex 32 32 32 38 2c 39 3a 2d 3b 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 3c 3d 3e 3f 40 41 42 3d 3d
                hex 43 32 38 2c 39 44 45 3a 46 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 47 48 48 49 4a 4b 4c 48 48
                hex 48 4d 2c 39 44 4e 4f 45 50 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 51 52 52 52 52 52 52 52 52
                hex 53 54 39 44 4e 55 56 4f 57 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 58 59 59 59 59 59 59 59 59
                hex 5a 5b 44 4e 55 32 32 56 5c 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 31 32 32 32 32 32 32 32 32
                hex 5d 5a 4e 55 32 32 32 32 2f 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 5e 5f 60 60 60 60 60 60 60
                hex 60 61 62 60 60 60 60 63 64 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 65 66 67 67 67 67 67 67 67 67
                hex 67 67 67 67 67 67 67 67 68 69 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6a 6b 67 67 67 67 67 67 67 67
                hex 67 67 67 67 67 67 67 67 6c 6d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 6e 6f 70 70 70 70 70 70 70
                hex 70 70 70 70 70 70 70 71 72 00 00 00 00 00 00 00
                pad nt_golf+18*32, $00
                hex 00 00 00 73 74 02 74 75 74 76 00 77 78 79 00 7a
                hex 7b 7c 7a 7d 7e 7f 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 80 81 82 83 80 76 00 7a 84 85 86 00 81
                hex 75 01 00 87 00 00 7e 85 86 00 83 88 75 00 00 00
                pad nt_golf+21*32, $00
                hex 00 00 00 89 88 82 00 89 88 8a 75 73 00 80 81 02
                hex 75 89 80 00 01 78 77 82 00 00 00 00 00 00 00 00
                hex 00 00 00 75 82 03 82 78 80 82 73 00 04 02 75 00
                hex 89 88 82 00 04 78 77 8a 83 02 77 74 00 00 00 00
                hex 00 00 00 78 80 00 04 02 75 00 89 88 82 00 01 78
                hex 77 82 00 8a 89 80 82 03 04 00 00 00 00 00 00 00
                hex 00 00 00 74 74 74 00 8b 82 03 03 7c 00 8a 89 8c
                hex 80 00 01 02 03 04 74 00 00 00 00 00 00 00 00 00
                hex 00 00 00 8a 89 00 78 03 80 02 00 88 78 80 00 8b
                hex 88 78 89 00 03 02 02 85 80 00 00 00 00 00 00 00
                hex 00 00 00 03 8a 85 82 00 86 78 75 8d 82 79 00 01
                hex 8e 77 86 03 82 7c 00 80 02 74 74 74 00 00 00 00
                hex 00 00 00 74 74 74 00 89 88 78 89 8c 80 00 83 02
                hex 02 03 74 74 74 00 00 00 00 00 00 00 00 00 00 00
                pad nt_golf+30*32, $00
                ;
                pad nt_golf+30*32+8*8, $00

nt_pinball      ; NT & AT data for Pinball
                pad nt_pinball+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 01 02 03 04
                hex 05 06 06 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_pinball+4*32, $00
                hex 00 00 00 00 00 00 07 08 09 09 09 09 09 09 09 09
                hex 09 09 09 09 09 09 09 09 0a 0b 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 0d 0e 0f 10 11 12 13 14 15
                hex 16 17 18 19 1a 1b 1c 1d 1e 1f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 20 21 22 23 24 25 26 27 28
                hex 29 2a 2b 2c 2d 2e 2f 30 31 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 33 34 35 36 37 38 39 3a 3b
                hex 3c 3c 3c 3d 2e 3e 3f 2f 40 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 41 42 43 44 45 46 47 48 49
                hex 4a 3c 3d 2e 3e 4b 4c 3f 4d 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 4e 4f 50 51 52 53 54 55 55
                hex 55 56 2e 3e 4b 57 58 4c 59 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 5a 5b 5b 5b 5b 5b 5b 5b 5b
                hex 5c 5d 3e 4b 57 5e 5f 58 60 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 61 62 62 62 62 62 62 62 62
                hex 63 64 4b 57 5e 3c 3c 5f 65 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 33 3c 3c 3c 3c 3c 3c 3c 3c
                hex 66 63 57 5e 3c 3c 3c 3c 31 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0c 67 68 69 69 69 69 69 69 69
                hex 69 6a 6b 69 69 69 69 6c 6d 32 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6e 6f 3c 3c 3c 3c 3c 3c 3c 3c
                hex 3c 3c 3c 3c 3c 3c 3c 3c 70 71 00 00 00 00 00 00
                hex 00 00 00 00 00 00 72 73 3c 3c 3c 3c 3c 3c 3c 3c
                hex 3c 3c 3c 3c 3c 3c 3c 3c 74 75 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 76 77 78 78 78 78 78 78 78
                hex 78 78 78 78 78 78 78 79 7a 00 00 00 00 00 00 00
                pad nt_pinball+18*32, $00
                hex 00 00 00 7b 7c 7d 7c 7e 7c 7f 00 80 81 04 7e 82
                hex 05 7e 83 00 84 85 86 87 88 89 8a 00 00 00 00 00
                hex 00 00 00 8b 01 81 8c 8b 7f 00 87 8d 8e 04 00 01
                hex 7e 8f 00 90 00 00 89 8e 04 00 8c 91 7e 00 00 00
                pad nt_pinball+21*32, $00
                hex 00 00 00 05 00 8c 7d 03 8c 81 01 92 82 05 06 00
                hex 92 05 8e 81 00 7d 03 00 92 91 81 00 00 00 00 00
                hex 00 00 00 01 93 03 04 05 06 06 00 81 94 01 81 7e
                hex 93 81 03 8c 81 7c 00 95 91 93 06 81 00 00 00 00
                hex 00 00 00 96 05 03 83 00 8c 06 05 93 96 00 92 91
                hex 81 00 8f 05 96 81 97 8b 00 00 00 00 00 00 00 00
                hex 00 00 00 96 81 8c 91 05 03 93 8c 8b 00 05 7e 81
                hex 00 93 03 05 8c 8c 82 7e 05 92 81 00 00 00 00 00
                hex 00 00 00 92 7d 00 92 91 7d 8b 81 00 7d 80 00 7e
                hex 81 05 06 00 92 05 04 06 81 8b 86 00 00 00 00 00
                hex 00 00 00 93 92 97 8b 00 05 00 03 81 05 92 00 92
                hex 05 8e 81 86 00 06 93 8e 81 00 00 00 00 00 00 00
                hex 00 00 00 98 93 7b 81 7d 00 01 93 03 04 05 06 06
                hex 00 7d 03 00 92 91 81 00 84 8d 99 99 7c 00 00 00
                pad nt_pinball+30*32, $00
                ;
                pad nt_pinball+30*32+8*8, $00

nt_popeye       ; NT & AT data for Popeye
                pad nt_popeye+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 01 02 01 03
                hex 04 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_popeye+4*32, $00
                hex 00 00 00 00 00 00 05 06 07 07 07 07 07 07 07 07
                hex 07 07 07 07 07 07 07 07 08 09 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 0b 0c 0d 0e 0f 10 11 12 13
                hex 14 15 16 17 18 19 1a 1b 1c 1d 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 1e 1f 20 21 22 23 24 25 26
                hex 27 28 29 2a 2b 2c 2d 2e 2f 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 31 32 33 34 35 36 36 36 36
                hex 36 36 36 37 2c 38 39 2d 3a 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 3b 3c 3d 3e 3f 40 41 42 42
                hex 43 36 37 2c 38 44 45 39 46 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 47 48 49 4a 4b 4c 4d 4e 4e
                hex 4e 4f 2c 38 44 50 51 45 52 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 53 54 54 54 54 54 54 54 54
                hex 55 56 38 44 50 57 58 51 59 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 5a 5b 5b 5b 5b 5b 5b 5b 5b
                hex 5c 5d 44 50 57 36 36 58 5e 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 31 36 36 36 36 36 36 36 36
                hex 5f 5c 50 57 36 36 36 36 2f 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0a 60 61 62 62 62 62 62 62 62
                hex 62 63 64 62 62 62 62 65 66 30 00 00 00 00 00 00
                hex 00 00 00 00 00 00 67 68 69 69 69 69 69 69 69 69
                hex 69 69 69 69 69 69 69 69 6a 6b 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6c 6d 69 69 69 69 69 69 69 69
                hex 69 69 69 69 69 69 69 69 6e 6f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 70 71 72 72 72 72 72 72 72
                hex 72 72 72 72 72 72 72 73 74 00 00 00 00 00 00 00
                pad nt_popeye+18*32, $00
                hex 00 00 00 75 76 02 76 77 76 78 00 79 7a 7b 04 00
                hex 7c 7d 7e 7f 7c 80 81 82 00 00 00 00 00 00 00 00
                hex 00 00 00 83 01 03 84 83 78 00 7c 85 86 87 00 01
                hex 77 88 00 89 00 00 81 86 87 00 84 8a 77 00 00 00
                pad nt_popeye+21*32, $00
                hex 00 00 00 8b 00 01 02 77 8c 00 02 8d 00 8e 8f 8e
                hex 8c 03 8e 75 02 90 83 00 00 00 00 00 00 00 00 00
                hex 00 00 00 8b 77 84 8b 75 03 00 88 8b 91 03 00 8d
                hex 77 02 91 00 7c 80 81 92 76 00 00 00 00 00 00 00
                hex 00 00 00 8f 8c 00 8f 83 00 8c 8a 03 00 03 8b 77
                hex 7b 8f 03 83 8c 00 8d 8f 77 83 8c 00 00 00 00 00
                hex 00 00 00 01 8b 77 8c 04 00 8c 8f 8c 7b 03 00 8c
                hex 02 00 8d 03 8b 8c 7a 77 03 00 8b 8e 00 00 00 00
                hex 00 00 00 8f 01 00 8e 8f 8e 8c 03 8e 75 02 00 75
                hex 02 03 83 8e 90 8c 00 02 93 8e 76 00 00 00 00 00
                pad nt_popeye+30*32, $00
                ;
                pad nt_popeye+30*32+8*8, $00

nt_popeyeen     ; NT & AT data for Popeye English
                pad nt_popeyeen+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 01 02 01 03 04 03 00
                hex 03 05 06 07 08 09 0a 00 00 00 00 00 00 00 00 00
                pad nt_popeyeen+4*32, $00
                hex 00 00 00 00 00 00 0b 0c 0d 0d 0d 0d 0d 0d 0d 0d
                hex 0d 0d 0d 0d 0d 0d 0d 0d 0e 0f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 11 12 13 14 15 16 17 18 19
                hex 1a 1b 1c 1d 1e 1f 20 21 22 23 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 24 25 26 27 28 29 2a 2b 2c
                hex 2d 2e 2f 30 31 32 33 34 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 38 39 3a 3b 3c 3d 3e 3f
                hex 3f 3f 3f 40 32 41 42 33 43 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 44 45 46 47 48 49 4a 4b 4c
                hex 4d 3f 40 32 41 4e 4f 42 50 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 51 52 53 54 55 56 57 58 58
                hex 58 59 32 41 4e 5a 5b 4f 5c 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 5d 5e 5e 5e 5e 5e 5e 5e 5e
                hex 5f 60 41 4e 5a 61 62 5b 63 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 64 65 65 65 65 65 65 65 65
                hex 66 67 4e 5a 61 3f 3f 62 68 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 3f 3f 3f 3f 3f 3f 3f 3f
                hex 69 66 5a 61 3f 3f 3f 3f 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 6a 6b 6c 6c 6c 6c 6c 6c 6c
                hex 6c 6d 6e 6c 6c 6c 6c 6f 70 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 71 72 73 73 73 73 73 73 73 73
                hex 73 73 73 73 73 73 73 73 74 75 00 00 00 00 00 00
                hex 00 00 00 00 00 00 76 77 73 73 73 73 73 73 73 73
                hex 73 73 73 73 73 73 73 73 78 79 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 7a 7b 7c 7c 7c 7c 7c 7c 7c
                hex 7c 7c 7c 7c 7c 7c 7c 7d 7e 00 00 00 00 00 00 00
                pad nt_popeyeen+18*32, $00
                hex 00 00 00 7f 80 02 80 81 80 82 00 05 02 83 03 84
                hex 85 03 81 00 86 86 87 88 89 8a 8b 8c 00 00 00 00
                hex 00 00 00 09 01 03 8d 09 82 00 89 8e 8f 85 00 01
                hex 81 06 00 90 00 00 8b 8f 85 00 8d 0a 81 00 00 00
                pad nt_popeyeen+21*32, $00
                hex 00 00 00 91 0a 03 00 92 08 81 09 91 00 03 7f 93
                hex 91 94 08 05 84 03 05 91 00 06 94 84 03 00 00 00
                hex 00 00 00 94 09 00 95 03 07 07 00 94 09 00 91 0a
                hex 03 00 92 08 81 09 91 00 00 00 00 00 00 00 00 00
                hex 00 00 00 09 01 08 05 02 92 92 00 91 08 91 07 03
                hex 00 02 92 92 08 8d 08 94 07 07 04 00 00 00 00 00
                hex 00 00 00 81 03 07 03 94 09 03 7f 80 00 02 05 03
                hex 00 02 92 00 91 0a 03 00 84 02 81 03 00 00 00 00
                hex 00 00 00 02 85 09 8d 93 81 03 00 06 94 84 03 09
                hex 00 08 05 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 05 08 05 91 03 05 7f 02 96 09 00 03 94
                hex 81 07 04 00 07 08 05 03 93 01 80 00 00 00 00 00
                pad nt_popeyeen+30*32, $00
                ;
                pad nt_popeyeen+30*32+8*8, $00

nt_tennis       ; NT & AT data for Tennis
                pad nt_tennis+2*32, $00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 01 02 03
                hex 03 04 05 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_tennis+4*32, $00
                hex 00 00 00 00 00 00 06 07 08 08 08 08 08 08 08 08
                hex 08 08 08 08 08 08 08 08 09 0a 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 0c 0d 0e 0f 10 11 12 13 14
                hex 15 16 17 18 19 1a 1b 1c 1d 1e 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 1f 20 21 22 23 24 25 26 27
                hex 28 29 2a 2b 2c 2d 2e 2f 30 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 32 33 34 35 36 37 38 39 39
                hex 39 39 39 3a 2d 3b 3c 2e 3d 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 3e 3f 40 41 42 43 44 45 46
                hex 47 39 3a 2d 3b 48 49 3c 4a 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 4b 4c 4d 4e 4f 50 51 51 51
                hex 51 52 2d 3b 48 53 54 49 55 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 56 57 57 57 57 57 57 57 57
                hex 58 59 3b 48 53 5a 5b 54 5c 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 5d 5e 5e 5e 5e 5e 5e 5e 5e
                hex 5f 60 48 53 5a 39 39 5b 61 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 32 39 39 39 39 39 39 39 39
                hex 62 5f 53 5a 39 39 39 39 30 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 0b 63 64 65 65 65 65 65 65 65
                hex 65 66 67 65 65 65 65 68 69 31 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6a 6b 6c 6c 6c 6c 6c 6c 6c 6c
                hex 6c 6c 6c 6c 6c 6c 6c 6c 6d 6e 00 00 00 00 00 00
                hex 00 00 00 00 00 00 6f 70 6c 6c 6c 6c 6c 6c 6c 6c
                hex 6c 6c 6c 6c 6c 6c 6c 6c 71 72 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 73 74 75 75 75 75 75 75 75
                hex 75 75 75 75 75 75 75 76 77 00 00 00 00 00 00 00
                pad nt_tennis+18*32, $00
                hex 00 00 00 78 79 7a 79 7b 79 7c 00 7d 7e 03 7f 7e
                hex 7b 80 00 81 82 83 84 81 85 86 82 00 00 00 00 00
                hex 00 00 00 05 87 02 88 05 7c 00 81 89 8a 8b 00 87
                hex 7b 8c 00 8d 00 00 86 8a 8b 00 88 8e 7b 00 00 00
                pad nt_tennis+21*32, $00
                hex 00 00 00 01 8e 02 00 05 02 88 7a 03 78 00 05 87
                hex 7a 7b 01 05 00 8c 7e 8f 02 00 00 00 00 00 00 00
                hex 00 00 00 7b 02 90 02 7e 05 02 78 00 91 7a 7b 00
                hex 01 8e 02 00 91 7e 8f 04 88 7a 8f 79 00 00 00 00
                hex 00 00 00 7e 05 00 91 7a 7b 00 01 8e 02 00 8c 7e
                hex 8f 02 00 04 01 05 02 90 91 00 00 00 00 00 00 00
                hex 00 00 00 79 79 79 00 92 02 90 90 84 00 04 01 93
                hex 05 00 01 02 03 03 04 05 79 00 00 00 00 00 00 00
                pad nt_tennis+30*32, $00
                ;
                pad nt_tennis+30*32+8*8, $00

nt_dkjr         ; NT & AT data for Donkey Kong Jr.
                pad nt_dkjr+2*32, $00
                hex 00 00 00 00 00 00 00 00 01 02 03 04 05 06 00 04
                hex 02 03 07 00 08 09 0a 00 00 00 00 00 00 00 00 00
                pad nt_dkjr+4*32, $00
                hex 00 00 00 00 00 00 0b 0c 0d 0d 0d 0d 0d 0d 0d 0d
                hex 0d 0d 0d 0d 0d 0d 0d 0d 0e 0f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 11 12 13 14 15 16 17 18 19
                hex 1a 1b 1c 1d 1e 1f 20 21 22 23 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 24 25 26 27 28 29 2a 2b 2c
                hex 2d 2e 2f 30 31 32 33 34 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 38 39 3a 3b 3c 3d 3e 3f
                hex 40 41 42 43 32 44 45 33 46 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 47 48 49 4a 4b 4c 4d 4e 4f
                hex 50 51 43 32 44 52 53 45 54 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 55 56 57 58 59 5a 5b 5c 5d
                hex 5e 5f 32 44 52 60 61 53 62 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 63 64 64 64 64 64 64 64 64
                hex 65 66 44 52 60 67 68 61 69 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 6a 6b 6b 6b 6b 6b 6b 6b 6b
                hex 6c 6d 52 60 67 42 42 68 6e 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 37 42 42 42 42 42 42 42 42
                hex 6f 6c 60 67 42 42 42 42 35 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 10 70 71 72 72 72 72 72 72 72
                hex 72 73 74 72 72 72 72 75 76 36 00 00 00 00 00 00
                hex 00 00 00 00 00 00 77 78 79 79 79 79 79 79 79 79
                hex 79 79 79 79 79 79 79 79 7a 7b 00 00 00 00 00 00
                hex 00 00 00 00 00 00 7c 7d 79 79 79 79 79 79 79 79
                hex 79 79 79 79 79 79 79 79 7e 7f 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 80 81 82 82 82 82 82 82 82
                hex 82 82 82 82 82 82 82 83 84 00 00 00 00 00 00 00
                pad nt_dkjr+18*32, $00
                hex 00 00 00 01 0a 02 0a 09 0a 85 00 08 86 87 06 00
                hex 88 89 8a 8b 88 8c 8d 8e 00 00 00 00 00 00 00 00
                hex 00 00 00 8f 90 05 91 8f 85 00 88 94 04 92 00 90
                hex 09 07 00 93 00 9f 8d 04 92 00 91 95 09 00 00 00
                pad nt_dkjr+21*32, $00
                hex 00 00 00 96 00 90 02 09 97 00 02 98 00 03 99 03
                hex 97 05 03 01 02 9a 8f 00 95 99 97 00 00 00 00 00
                hex 00 00 00 96 09 91 96 01 05 00 07 96 9b 05 00 98
                hex 09 02 9b 00 88 8c 8d 9c 0a 00 00 00 00 00 00 00
                hex 00 00 00 86 03 87 99 04 05 00 99 97 8f 00 90 09
                hex 05 01 05 91 05 8f 8f 02 09 8b 00 00 00 00 00 00
                hex 00 00 00 97 95 99 8f 00 97 99 97 87 05 00 9b 96
                hex 04 05 8f 00 86 8f 05 00 02 98 00 00 00 00 00 00
                hex 00 00 00 97 95 05 00 95 09 02 9b 00 92 02 96 09
                hex 01 8b 09 96 97 95 05 09 00 97 95 96 03 00 00 00
                hex 00 00 00 97 95 05 00 9b 02 09 05 00 9d 05 87 87
                hex 9e 04 03 02 9d 03 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 03 09 02 9b 9e 88 9c 8d 0a 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                pad nt_dkjr+30*32, $00
                ;
                pad nt_dkjr+30*32+8*8, $00

                pad $c000, $00

; --- Bank 2 ------------------------------------------------------------------

                base $8000

sub1            ; audio stuff; called by: init
                ;
                stx arr37+9
                sty arr37+10
                stx read_ptr2+0
                sty read_ptr2+1
                tax
                beq +
                lda #$61
+               sta arr37+8
                jsr sub2
                ;
                ldy #1
                lda (read_ptr2),y
                sta arr37+11
                iny
                lda (read_ptr2),y
                sta arr37+12
                iny
                lda (read_ptr2),y
                sta arr37+13
                iny
                lda (read_ptr2),y
                sta arr37+14
                ;
                lda #$80
                sta arr37+16
                sta ram60
                copy #%00001111, snd_chn
                copy #%10000000, tri_linear
                copy #%00000000, noise_hi
                lda #%00110000
                sta sq1_vol
                sta sq2_vol
                sta noise_vol
                lda #%00001000
                sta sq1_sweep
                sta sq2_sweep
                jmp sub2

sub2            ; array stuff; called by: sub1, sub3
                ;
                lda #$00
                sta arr28+4
                sta arr37+15
                ;
                ldx #0
-               sta arr29,x
                sta arr28,x
                sta arr27,x
                sta arr32,x
                sta arr33,x
                sta arr34,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                lda #$00
                inx
                cpx #5
                bne -
                ;
                ldx #0
-               sta arr37,x
                inx
                cpx #3
                bne -
                ;
                ldx #0
-               sta arr22,x
                inx
                cpx #4
                bne -
                ;
                ldx #0
-               lda #<dat2
                sta addr_tbl_lo,x
                lda #>dat2
                sta addr_tbl_hi,x
                lda #$00
                sta arr10+11,x
                sta arr10,x
                sta arr14,x
                inx
                cpx #11
                bne -
                ;
                ldx #0
-               lda #$c7
                sta arr18,x
                lda #$89
                sta arr19,x
                lda #$00
                sta arr17,x
                sta arr15,x
                sta arr16,x
                sta arr21,x
                lda #$01
                sta arr20,x
                inx
                cpx #3
                bne -
                ;
                jmp sub10

sub3            ; array stuff; called by: init
                ;
                ldx arr37+9
                stx read_ptr2+0
                ldx arr37+10
                stx read_ptr2+1
                ldy #0
                cmp (read_ptr2),y
                bcc +
                rts                     ; $80ed (unaccessed)
+               asl a
                sta read_ptr2+0
                asl a
                tax
                asl a
                adc read_ptr2+0
                stx read_ptr2+0
                adc read_ptr2+0
                adc #$05
                tay
                copy arr37+9, read_ptr2+0
                jsr sub2
                ;
                ldx #0
-               lda (read_ptr2),y
                sta arr25,x
                iny
                lda (read_ptr2),y
                sta arr26,x
                iny
                lda #$00
                sta arr29,x
                sta arr28,x
                sta arr27,x
                sta arr32,x
                lda #$f0
                sta arr33,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                inx
                cpx #5
                bne -
                ;
                lda arr37+8
                beq +
                iny
                iny
+               lda (read_ptr2),y
                sta arr37+3
                iny
                lda (read_ptr2),y
                sta arr37+4
                copy #$00, arr37+5
                lda #$06
                sta arr37+6
                sta arr28+4
                rts

ucod1           ; unaccessed chunk ($8153)
                tax
                beq +
                jsr sub10
                lda #$00
                sta arr10+0
                sta arr10+3
                sta arr10+6
                sta arr10+8
                lda arr28+4
                ora #%10000000
                bne ++
+               lda arr28+4
                and #%01111111
++              sta arr28+4
                rts
                ; $8177

; -----------------------------------------------------------------------------

sub4            ; called by: sub7
                ;
                clc
                lda arr21,y
                adc arr15,y
                sta ptr2+0
                lda arr21,y
                and #%10000000
                beq +
                lda #$ff
+               adc arr16,y
                sta ptr2+1
                lda arr22,y
                beq +

ucod2           ; unaccessed chunk ($8193)
                lda arr24,y
                cmp #$80
                ror a
                sta ram10
                lda arr23,y
                ror a
                add ptr2+0
                sta ptr2+0
                lda ram10
                adc ptr2+1
                sta ptr2+1
                ; $81aa

+               clc
                lda dat3,x
                adc ptr2+0
                sta ptr2+0
                lda dat4,x
                adc ptr2+1
                sta ptr2+1
                rts

sub5            ; called by: sub6
                ;
                jsr sub9
                bcc +++
                txa
                tay
                ldx dat5,y
                lda arr28,y
                cpy #$04
                bcc ++
                lda arr27+4
                bne +
                jsr sub10               ; unaccessed ($81d0)
                ldx #$04                ; unaccessed
                bne +++                 ; unaccessed
+               jsr sub11
                ldx #$04
                jmp +++
++              jsr sub8
+++             rts

sub6            ; called by: sub7
                ;
                lda arr37+7
                beq +
                lda arr35,x
                bmi ++
                lda #$ff                ; unaccessed ($81ed)
                sta arr35,x             ; unaccessed
                jsr sub5                ; unaccessed
                jmp ++                  ; unaccessed
+               lda arr35,x
                bmi +++
                sub #$01
                sta arr35,x
                bpl +++
++              jsr sub5
+++             lda arr36,x
                bmi +
                sub #$01                ; unaccessed ($820d)
                sta arr36,x             ; unaccessed
                bpl +                   ; unaccessed
                lda #$00                ; unaccessed
                sta arr27,x             ; unaccessed
+               rts

sub7            ; called by: nmi
                ;
                lda read_ptr2+0
                pha
                lda read_ptr2+1
                pha
                lda arr28+4
                bmi +
                bne ++
+               jmp cod10               ; unaccessed ($8228)
++              lda arr37+6
                cmp arr28+4
                ldx #$00
                stx arr37+7
                bcc +
                sbc arr28+4
                sta arr37+6
                ldx #$01
                stx arr37+7
                ;
+               ldx #0
-               jsr sub6
                inx
                cpx #5
                bne -
                ;
                ldx #0
--              lda arr10+11,x
                beq +
                dec arr10+11,x
                bne +++
+               lda addr_tbl_lo,x
                sta read_ptr2+0
                lda addr_tbl_hi,x
                sta read_ptr2+1
                ;
                ldy arr14,x
-               lda (read_ptr2),y
                bpl +
                add #$40
                sta arr10,x
                iny
                bne ++
+               bne +
                iny
                lda (read_ptr2),y
                tay
                jmp -
                ;
+               iny
                sta arr10+11,x
++              tya
                sta arr14,x
+++             inx
                cpx #11
                bne --
                ;
                ldx #$00
                jmp cod2

cod1            ; unaccessed chunk ($828e)
                ;
                lda arr17,x
                sub #$01
                sta arr17,x
                and #%01111111
                beq cod3
                ;
                lda arr18,x
                sta read_ptr2+0
                lda arr19,x
                sta read_ptr2+1
                ;
                ldy arr20,x
                dey
                dey
                lda (read_ptr2),y
                add #$40
                sta ram11
                clc
                adc arr15,x
                sta arr15,x
                ;
                lda ram11
                bpl +
                lda #$ff
+               adc arr16,x
                sta arr16,x
                jmp cod7
                ; $82c7

cod2            lda arr17,x
                cmp #$81
                bcs cod1
                and #%01111111
                beq cod3
                dec arr17,x
                bne cod7
                ;
cod3            lda arr18,x
                sta read_ptr2+0
                lda arr19,x
                sta read_ptr2+1
                ldy #0
                lda (read_ptr2),y
                sta ram10
                ldy arr20,x
cod4            lda (read_ptr2),y
                bpl cod5
                add #$40
                bit ram10
                bmi ucod3
                sta arr15,x
                ora #%00000000
                bmi +
                lda #$00
                jmp ++
+               lda #$ff
++              sta arr16,x
                iny
                jmp cod6

ucod3           ; unaccessed chunk ($830a)
                sta ram11
                clc
                adc arr15,x
                sta arr15,x
                lda ram11
                and #%10000000
                bpl +
                lda #$ff
+               adc arr16,x
                sta arr16,x
                iny
                jmp cod6
                ; $8325

cod5            bne +
                iny
                lda (read_ptr2),y
                tay
                jmp cod4
+               iny
                ora ram10
                sta arr17,x
cod6            tya
                sta arr20,x
cod7            inx
                cpx #3
                bne cod2
                ldx #$00
cod8            lda arr22,x
                beq cod9

ucod4           ; unaccessed chunk ($8344)
                clc
                lda arr22,x
                adc arr23,x
                sta arr23,x
                lda arr22,x
                and #%10000000
                beq +
                lda #$ff
                adc arr24,x
                sta arr24,x
                bpl cod9
                jmp ++
+               adc arr24,x
                sta arr24,x
                bmi cod9
++              lda #$00
                sta arr22,x
                ; $836f

cod9            inx
                cpx #4
                bne cod8
cod10           lda arr27
                bne +
                jmp ++                  ; unaccessed ($8379)
+               add arr10+1
                add arr37+8
                tax
                ldy #$00
                jsr sub4
                copy ptr2+0, ram62
                copy ptr2+1, ram63
                lda arr33
                ora arr10+0
                tax
                lda dat12,x
                ;
++              ldx arr10+2
                ora dat11,x
                sta ram61
                lda arr27+1
                bne +
                jmp ++
+               add arr10+4
                add arr37+8
                tax
                ldy #$01
                jsr sub4
                copy ptr2+0, ram65
                copy ptr2+1, ram66
                lda arr33+1
                ora arr10+3
                tax
                lda dat12,x
                ;
++              ldx arr10+5
                ora dat11,x
                sta ram64
                lda arr27+2
                bne +
                jmp ++
+               add arr10+7
                add arr37+8
                tax
                ldy #$02
                jsr sub4
                copy ptr2+0, ram68
                copy ptr2+1, ram69
                lda arr33+2
                ora arr10+6
                tax
                lda dat12,x
                ;
++              ora #%10000000
                sta ram67
                lda arr27+3
                bne ucod5
                jmp cod11

ucod5           ; unaccessed chunk ($8411)
                ;
                add arr10+9
                ldy arr22+3
                beq +
                ;
                sta ram10
                copy arr23+3, ptr2+0
                lda arr24+3
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                lda ptr2+0
                ror a
                add ram10
                ;
+               and #%00001111
                eor #%00001111
                sta ram10
                ldx arr10+10
                lda dat11,x
                asl a
                and #%10000000
                ora ram10
                sta ram71
                lda arr33+3
                ora arr10+8
                tax
                lda dat12,x
                ; $845a

cod11           ldx arr10+10
                ora dat11,x
                ora #%11110000
                sta ram70
                lda arr28+4
                bmi +
                clc
                lda arr37+5
                adc arr37+3
                sta arr37+5
                lda arr37+6
                adc arr37+4
                sta arr37+6
                ;
+               ldx #$00
                jsr sub13
                ldx #$0f
                jsr sub13
                copy ram61, sq1_vol
                copy ram62, sq1_lo
                lda ram63
                cmp arr37+16
                beq +
                sta arr37+16
                sta sq1_hi
+               copy ram64, sq2_vol
                copy ram65, sq2_lo
                lda ram66
                cmp ram60
                beq +
                sta ram60
                sta sq2_hi
+               copy ram67, tri_linear
                copy ram68, tri_lo
                copy ram69, tri_hi
                copy ram70, noise_vol
                copy ram71, noise_lo
                pla
                sta read_ptr2+1
                pla
                sta read_ptr2+0
                rts

sub8            ; called by: sub5
                ;
                sty ram11
                asl a
                tay
                lda arr37+12
                adc #$00
                sta read_ptr2+1
                copy arr37+11, read_ptr2+0
                lda (read_ptr2),y
                sta addr_tbl_lo,x
                iny
                lda (read_ptr2),y
                iny
                sta addr_tbl_hi,x
                inx
                stx ram12
                ldx ram11
                lda arr34,x
                lsr a
                ldx ram12
                bcc +
                iny                     ; unaccessed ($8509)
                jmp ++                  ; unaccessed
                ;
+               lda (read_ptr2),y
                sta addr_tbl_lo,x
                iny
                lda (read_ptr2),y
                sta addr_tbl_hi,x
                ;
++              lda #$01
                sta arr13,x
                lda #$00
                sta arr10+10,x
                sta arr10+11,x
                sta arr14,x
                lda ram11
                cmp #$02
                bne +
                iny
                iny
                bne ++                  ; unconditional
                ;
+               inx
                iny
                lda (read_ptr2),y
                sta addr_tbl_lo,x
                iny
                lda (read_ptr2),y
                sta addr_tbl_hi,x
                lda #$00
                sta arr10+11,x
                sta arr14,x
                stx ram12
                ldx ram11
                lda dat9,x
                tax
                lda arr37,x
                ldx ram12
                sta arr10,x
                ;
++              ldx ram11
                lda arr34,x
                bmi +
                lda dat8,x
                bmi +
                tax
                lda #$01
                sta arr20,x
                lda #$00
                sta arr17,x
                sta arr15,x
                sta arr16,x
                iny
                lda (read_ptr2),y
                sta arr18,x
                iny
                lda (read_ptr2),y
                sta arr19,x
                ;
+               ldx ram11
                rts

sub9            ; called by: sub5
                ;
                lda arr29,x
                beq +
                dec arr29,x
                clc
                rts
+               copy #$00, ram12
                lda arr25,x
                sta read_ptr2+0
                lda arr26,x
                sta read_ptr2+1
                ldy #0
cod12           lda (read_ptr2),y
                inc read_ptr2+0
                bne +
                inc read_ptr2+1
+               cmp #$61
                bcs +
                jmp cod13
+               ora #%00000000
                bpl +
                jmp cod14
+               cmp #$70
                bcc +
                and #%00001111
                asl a
                asl a
                asl a
                asl a
                sta arr33,x
                jmp cod12
+               stx ram10
                and #%00001111
                tax
                ;
                lda jump_tbl_lo,x       ; jump to index X in jump table
                sta ptr2+0
                lda jump_tbl_hi,x
                sta ptr2+1
                ldx ram10
                jmp (ptr2)

icode1          stx ram10
                lda dat8,x
                tax
                lda (read_ptr2),y
                inc read_ptr2+0
                bne +
                inc read_ptr2+1         ; unaccessed ($85e3)
+               sta arr21,x
                ldx ram10
                jmp cod12

icode2          lda #$7f
                and arr34,x
                sta arr34,x
                jmp cod12

icode3          lda #$80
                ora arr34,x
                sta arr34,x
                stx ram10
                lda dat8,x
                tax
                lda (read_ptr2),y
                sta arr18,x
                iny
                lda (read_ptr2),y
                sta arr19,x
                lda #$00
                tay
                sta arr17,x
                lda #$01
                sta arr20,x
                ldx ram10
                clc
                lda #$02
                adc read_ptr2+0
                sta read_ptr2+0
                bcc +
                inc read_ptr2+1         ; unaccessed ($8627)
+               jmp cod12

icode4          ; unaccessed chunk ($862c)
                lda #$fe
                and arr34,x
                sta arr34,x
                jmp cod12

icode5          ; unaccessed chunk
                lda #$01
                ora arr34,x
                sta arr34,x
                stx ram10
                lda dat6,x
                tax
                lda (read_ptr2),y
                sta addr_tbl_lo,x
                iny
                lda (read_ptr2),y
                sta addr_tbl_hi,x
                lda #$00
                tay
                sta arr10+11,x
                sta arr10,x
                sta arr14,x
                ldx ram10
                clc
                lda #$02
                adc read_ptr2+0
                sta read_ptr2+0
                bcc +
                inc read_ptr2+1
+               jmp cod12

icode6          ; unaccessed chunk
                stx ram10
                lda dat6,x
                tax
                lda #$00
                sta arr10+11,x
                sta arr10,x
                sta arr14,x
                ldx ram10
                jmp cod12
                ; $8682

icode7          stx ram10
                lda dat9,x
                tax
                lda (read_ptr2),y
                sta arr37,x
                sta ram11
                ldx ram10
                lda dat10,x
                tax
                lda ram11
                sta arr10,x
                ldx ram10
                inc read_ptr2+0
                bne +
                inc read_ptr2+1         ; unaccessed ($86a0)
+               jmp cod12

icode8          lda (read_ptr2),y
                sta arr35,x
                inc read_ptr2+0
                bne +
                inc read_ptr2+1         ; unaccessed ($86ae)
+               jmp cod17

icode9          ; unaccessed chunk ($86b3)
                copy #$40, ram12
                lda (read_ptr2),y
                sta arr36,x
                inc read_ptr2+0
                bne +
                inc read_ptr2+1
+               jmp cod12

icode10         ; unaccessed chunk
                lda #$80
                ora ram12
                sta ram12
                jmp cod12
                ;
-               lda (read_ptr2),y
                iny
                sta arr22+3
                lda (read_ptr2),y
                iny
                sec
                sbc (read_ptr2),y
                sta arr23+3
                bpl +
                lda #$ff
                bmi ++
+               lda #$00
++              asl arr23+3
                rol a
                asl arr23+3
                rol a
                asl arr23+3
                rol a
                asl arr23+3
                rol a
                sta arr24+3
                jmp +

icode11         ; unaccessed chunk
                cpx #3
                beq -
                ;
                stx ram10
                lda dat7,x
                tax
                lda (read_ptr2),y
                iny
                sta arr22,x
                lda (read_ptr2),y
                add arr37+8
                sta ram11
                iny
                lda (read_ptr2),y
                ldy ram11
                adc arr37+8
                stx ram11
                tax
                sec
                lda dat3,y
                sbc dat3,x
                sta ptr2+1
                lda dat4,y
                sbc dat4,x
                ldx ram11
                sta arr24,x
                lda ptr2+1
                asl a
                sta arr23,x
                rol arr24,x
                ldx ram10
                ldy #$02
+               lda (read_ptr2),y
                sta arr27,x
                clc
                lda #$03
                adc read_ptr2+0
                sta read_ptr2+0
                bcc +
                inc read_ptr2+1
+               ldy #$00
                jmp +
                ; $8754

cod13           sta arr27,x
                ldy dat7,x
                bmi +
                lda #$00
                sta arr22,y
+               bit ram12
                bmi ++
                bvs +
                lda #$ff
                sta arr36,x
+               lda arr27,x
                beq ++
-               sec
                jmp cod16
++              cpx #4                  ; unaccessed ($8775)
                beq -                   ; unaccessed
                clc                     ; unaccessed
                jmp cod16               ; unaccessed
cod14           and #%01111111
                lsr a
                bcs ++
                asl a
                asl a
                sta arr28,x
                jmp cod12
                ;
--              lda (read_ptr2),y
                sta arr28+4
                inc read_ptr2+0
                bne +
                inc read_ptr2+1         ; unaccessed ($8793)
+               jmp cod12
                ;
-               lda (read_ptr2),y
                sta ram10
                iny
                lda (read_ptr2),y
                sta read_ptr2+1
                copy ram10, read_ptr2+0
                dey
                jmp cod12
++              cmp #$3d
                beq --
                ;
                cmp #$3c
                beq ucod8
                bcc cod15
                cmp #$3e
                beq -
                ;
                clc
                lda read_ptr2+0
                adc #$03
                sta arr30,x
                lda read_ptr2+1
                adc #$00
                sta arr31,x
                lda (read_ptr2),y
                sta arr32,x
                iny
                lda (read_ptr2),y
                sta ram10
                iny
                lda (read_ptr2),y
                sta read_ptr2+1
                copy ram10, read_ptr2+0
                ldy #$00
                jmp cod12

ucod8           ; unaccessed chunk ($87de)
                stx ram10
                lda dat5,x
                tax
                lda addr_tbl_lo,x
                sta ptr2+0
                lda addr_tbl_hi,x
                sta ptr2+1
                ldy #0
                lda (ptr2),y
                beq +
                sta arr14,x
                lda #$00
                sta arr10+11,x
+               ldx ram10
                clc
                jmp cod16
                ; $8802

cod15           sta arr29,x
cod16           lda arr32,x
                beq cod17
                dec arr32,x
                bne cod17
                lda arr30,x
                sta arr25,x
                lda arr31,x
                sta arr26,x
                rts
cod17           lda read_ptr2+0
                sta arr25,x
                lda read_ptr2+1
                sta arr26,x
                rts

jump_tbl_lo     ; $8827; partially unaccessed
                dl $2700,       icode11,    icode10, icode3
                dl icode2,      icode5,     icode4,  icode6
                dl icode1,      icode7,     icode8,  icode9
                dl jump_tbl_lo, jump_tbl_lo

jump_tbl_hi     ; $8835; partially unaccessed
                dh $2700,       icode11,    icode10, icode3
                dh icode2,      icode5,     icode4,  icode6
                dh icode1,      icode7,     icode8,  icode9
                dh jump_tbl_lo, jump_tbl_lo
                hex 88

sub10           ; called by: sub2, ucod1, sub5
                copy #%00001111, snd_chn
                rts

                ldx #$01                ; unaccessed ($884a)
                stx arr37+15            ; unaccessed

cod18           asl a
                asl a
                add arr37+13
                sta read_ptr2+0
                lda #$00
                adc arr37+14
                sta read_ptr2+1
                copy #%00001111, snd_chn
                ldy #0
                lda (read_ptr2),y
                sta dmc_start
                iny
                lda (read_ptr2),y
                sta dmc_len
                iny
                lda (read_ptr2),y
                sta dmc_freq
                iny
                lda (read_ptr2),y
                sta dmc_raw
                copy #%00011111, snd_chn
                rts

sub11           ; called by: sub5
                ;
                ldx arr37+15
                beq cod18

ucod9           ; unaccessed chunk ($8887)
                tax
                lda snd_chn
                and #%00010000
                beq +
                rts
+               sta arr37+15
                txa
                jmp cod18

                ; unaccessed chunk
                stx read_ptr2+0
                sty read_ptr2+1
                ldy #0
                lda arr37+8
                bne +
                iny
                iny
+               lda (read_ptr2),y
                sta ram72
                iny
                lda (read_ptr2),y
                sta ram73
                ;
                ldx #0
-               jsr sub12
                txa
                add #15
                tax
                cpx #30
                bne -
                ;
                rts

sub12           ; unaccessed chunk
                ; called by: sub11, sub12b
                lda #$00
                sta arr40,x
                sta arr38,x
                sta arr41,x
                sta arr48,x
                lda #$30
                sta arr42,x
                sta arr45,x
                sta arr51,x
                rts

sub12b          ; unaccessed chunk
                asl a
                tay
                jsr sub12
                copy ram72, read_ptr2+0
                copy ram73, read_ptr2+1
                lda (read_ptr2),y
                sta arr39,x
                iny
                lda (read_ptr2),y
                sta arr40,x
                rts
                ; $88f3

sub13           ; called by: sub7
                ;
                lda arr38,x
                beq +
                dec arr38,x             ; $88f8 (unaccessed)
                bne cod19               ; unaccessed
+               lda arr40,x
                bne ucod10
                rts

ucod10          ; unaccessed chunk ($8903)
                sta read_ptr2+1
                lda arr39,x
                sta read_ptr2+0
                ldy arr41,x
                clc
-               lda (read_ptr2),y
                bmi ++
                beq +++
                iny
                bne +
                jsr sub14
+               sta arr38,x
                tya
                sta arr41,x
                jmp cod19
++              iny
                bne +
                jsr sub14
+               stx ram10
                adc ram10
                tax
                lda (read_ptr2),y
                iny
                bne +
                stx ram11
                ldx ram10
                jsr sub14
                ldx ram11
+               sta arr15,x
                ldx ram10
                jmp -

                ; unaccessed chunk
+++             sta arr40,x
cod19           lda ram61
                and #%00001111
                sta ram10
                lda arr42,x
                and #%00001111
                cmp ram10
                bcc +
                lda arr42,x
                sta ram61
                lda arr43,x
                sta ram62
                lda arr44,x
                sta ram63
+               lda ram64
                and #%00001111
                sta ram10
                lda arr45,x
                and #%00001111
                cmp ram10
                bcc +
                lda arr45,x
                sta ram64
                lda arr46,x
                sta ram65
                lda arr47,x
                sta ram66
+               lda arr48,x
                beq +
                sta ram67
                lda arr49,x
                sta ram68
                lda arr50,x
                sta ram69
+               lda ram70
                and #%00001111
                sta ram10
                lda arr51,x
                and #%00001111
                cmp ram10
                bcc +
                lda arr51,x
                sta ram70
                lda arr52,x
                sta ram71
+               rts
                ; $89bd

sub14           ; called by: ucod10
                inc read_ptr2+1
                inc arr40,x
                rts

dat2            hex c0 7f 00 00 00 c0 7f 00
                hex 01

dat3            ; partially unaccessed ($89cc)
                hex 00 68 b6 0e 6f d9 4b c6 48 d1 60 f6 92 34 db 86
                hex 37 ec a5 62 23 e8 b0 7b 49 19 ed c3 9b 75 52 31
                hex 11 f3 d7 bd a4 8c 76 61 4d 3a 29 18 08 f9 eb de
                hex d1 c6 ba b0 a6 9d 94 8b 84 7c 75 6e 68 62 5d 57
                hex 52 4e 49 45 41 3e 3a 37 34 31 2e 2b 29 26 24 22
                hex 20 1e 1d 1b 19 18 16 15 14 13 12 11 10 0f 0e 0d
                hex 0c 00 5b 9c e6 3b 9a 01 72 ea 6a f1 7f 13 ad 4d
                hex f3 9d 4c 00 b8 74 34 f8 bf 89 56 26 f9 ce a6 80
                hex 5c 3a 1a fb df c4 ab 93 7c 67 52 3f 2d 1c 0c fd
                hex ef e1 d5 c9 bd b3 a9 9f 96 8e 86 7e 77 70 6a 64
                hex 5e 59 54

udat1           ; unaccessed chunk ($8a6f)
                hex 4f 4b 46 42 3f 3b 38 34 31 2f 2c 29 27 25 23 21
                hex 1f 1d 1b 1a 18 17 15 14 13 12 11 10 0f 0e 0d

dat4            ; partially unaccessed ($8a8e)
                hex 00 0c 0b 0b 0a 09 09 08
                hex 08 07 07 06 06 06 05 05
                hex 05 04 04 04 04 03 03 03
                hex 03 03 02 02 02 02 02 02
                hex 02 01 01 01 01 01 01 01
                hex 01 01 01 01 01 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 0d 0c 0b 0b 0a 0a
                hex 09 08 08 07 07 07 06 06
                hex 05 05 05 05 04 04 04 03
                hex 03 03 03 03 02 02 02 02
                hex 02 02 02 01 01 01 01 01
                hex 01 01 01 01 01 01 01 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00

udat2           ; unaccessed chunk ($8b31)
                pad $8b50, $00

                ; these are partially unaccessed
dat5            hex 00 03 06 08 ff
dat6            hex 01 04 07 09 ff
dat7            hex 00 01 02 03 ff
dat8            hex 00 01 02 ff ff
dat9            hex 00 01 ff 02 ff
dat10           hex 02 05 ff 0a ff
dat11           hex 30 70 b0 f0

dat12           ; partially unaccessed ($8b72)
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 00 01 01 01 01 01 01 01 01 01 01 01 02 02 02 02
                hex 00 01 01 01 01 01 01 01 02 02 02 02 02 03 03 03
                hex 00 01 01 01 01 01 02 02 02 02 03 03 03 03 04 04
                hex 00 01 01 01 01 02 02 02 03 03 03 04 04 04 05 05
                hex 00 01 01 01 02 02 02 03 03 04 04 04 05 05 06 06
                hex 00 01 01 01 02 02 03 03 04 04 05 05 06 06 07 07
                hex 00 01 01 02 02 03 03 04 04 05 05 06 06 07 07 08

                ; unaccessed chunk ($8c02)
                hex 00 01 01 02 02 03 04 04 05 05 06 07 07 08 08 09
                hex 00 01 01 02 03 03 04 05 05 06 07 07 08 09 09 0a
                hex 00 01 01 02 03 04 04 05 06 07 07 08 09 0a 0a 0b
                hex 00 01 02 02 03 04 05 06 06 07 08 09 0a 0a 0b 0c
                hex 00 01 02 03 03 04 05 06 07 08 09 0a 0a 0b 0c 0d
                hex 00 01 02 03 04 05 06 07 07 08 09 0a 0b 0c 0d 0e

                ; partially unaccessed ($8c62); read by LDA (ptr1),y
                hex 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f

pt_title_dk     ; BG PT data for title screen & Donkey Kong
                hex 62 a9 ff 9c 39 73 e7 cf 9f 3f 7f ff 49 93 26 4c
                hex 99 33 67 ce bf 00 01 02 04 09 12 24 e0 c0 80 00
                hex 24 1f 01 03 07 0f 1f fc 18 30 60 c0 80 00 ff b3
                hex 66 cc 98 31 63 c6 8c ff cc 98 31 63 c6 8c 18 30
                hex 23 5d f0 60 c0 80 00 bf 91 31 63 c6 8c 18 30 80
                hex 17 87 ef ee ed eb ff f6 ed db b6 6c d9 b3 66 22
                hex 51 87 ff fe fd fb 7f 01 03 07 0f 1f 3f 7f 78 01
                hex 03 07 ff 22 5b ff fd fb f6 ed db b6 6c d9 81 ff
                hex fe 9f 00 88 00 22 00 88 ff 0f 07 03 89 00 22 00
                hex 88 f8 0f 07 03 01 00 82 f6 7f 20 00 88 00 22 00
                hex 88 f8 0f 07 03 01 00 1f 08 00 22 00 88 fc f8 f0
                hex e0 c0 80 00 83 ff fe fc 7f 22 00 88 00 22 00 88
                hex 82 f5 7f 02 00 08 00 22 00 88 fc f8 f0 e0 c0 80
                hex 00 01 80 87 ff 7f 3f 1f da 30 18 00 18 00 1f 25
                hex 26 74 24 00 49 3c 80 e0 60 00 9f 80 be 84 88 90
                hex be 80 80 e6 80 a4 aa 92 80 92 75 f8 0f 07 03 01
                hex 00 19 88 00 88 f8 0f 07 03 01 00 ff 9c ce e7 f3
                hex f9 fc fe ff 07 7f 3f 1f 62 a5 ff 00 80 40 20 90
                hex 48 24 92 ff c9 64 32 99 cc e6 73 39 07 80 00 7e
                hex 06 9f 03 24 c7 fe ff 83 f9 c1 ff 66 33 19 8c c6
                hex 63 31 18 f8 0c 06 03 01 00 3f 80 c0 e0 f0 f8 fc
                hex 63 6a 01 80 f0 e0 c0 80 00 87 fe fc f8 f0 80 fe
                hex 82 6f 81 ff fc 19 88 00 88 19 08 00 88 fc f8 f0
                hex e0 c0 80 00 e0 ff bf 3f e0 2e 6e ee 52 ef 80 d1
                hex 3c bf 3f 7f ff 80 d1 80 d1 87 3f 7f bf 3f 80 d1
                hex ff 7f bf 3f 7f ff bf 3f 7f 52 fe 8e 01 81 41 a1
                hex 02 7f 80 7e 80 fe 80 d1 80 3f da 45 42 41 40 20
                hex 52 fe e2 1f e0 ff 00 02 00 3e 01 03 07 03 00 ae
                hex 3f 1f 0f 03 00 80 45 88 fe ff 80 45 52 fe 80 45
                hex 08 fe 80 45 87 fe ff fe ff 80 45 d9 fe ff fe ff
                hex fe 86 40 41 42 02 db 80 45 80 bb 80 3f ff ff 55
                hex ff 55 ff 55 ff 55 fe bf 50 a0 20 c0 40 80 ea 1f
                hex 10 20 40 80 83 6b b2 ff c0 df dc ff aa 44 aa 11
                hex aa 44 aa 11 ff aa 44 aa 15 aa 44 aa 15 07 80 40
                hex a8 8f 80 c0 30 0c 03 68 32 03 fb 3b c1 3e 63 00
                hex e7 1c 32 63 26 1c 00 ff 7f 70 3c 1e 07 63 3e 00
                hex 83 59 c8 df bf 7f ee ff fc fb f7 ef df cc ee ff
                hex ee ff a6 3b fb 03 ff 82 66 80 df ff ff dd ff 55
                hex ff dd ff 55 a6 dc df c0 ff ff ff dd ff 77 ff dd
                hex ff 77 6c 0e 00 ff 00 e0 af df ff 1e 3f c0 3f 00
                hex a0 aa ff 0e 00 ff 00 b8 81 bf 80 ff 0e 00 ff 00
                hex e0 aa 9a ff 0d 80 f4 a7 5b bb fb 1b fb 80 f4 c3
                hex fb 3b fb 5b 80 f4 b0 7b fb db 80 f4 ac fb 1b fb
                hex 7b 0d 80 f4 b9 1b fb 1b 3b 5b 80 f4 b1 1b fb db
                hex fb 80 f4 c1 fb 7b fb 80 f4 f8 5b bb fb 7b 3b 0d
                hex 80 f4 81 fb 7b 80 f4 e5 3b 9b 5b 1b fb 81 f4 e8
                hex 81 fb f7 80 f4 e0 3b 7b fb 03 ea 80 bc 80 40 ff
                hex aa dd aa 77 aa dd aa 77 ff aa dd aa 7f aa dd aa
                hex 7f ff aa 55 aa 55 aa 55 aa 55 82 9f ff ee 55 aa
                hex 55 ee 55 bb 55 80 fb 78 3f 70 60 ff 03 ff 00 78
                hex fe 07 03 ff 03 ff 00 43 ea 80 4d 80 4f bb df ef
                hex f7 fb fc ff 89 7f bf df 77 0c 9e 92 d2 7e 3c 63
                hex b5 c8 fb fd fe 80 17 e0 fa f9 f8 e0 02 01 00 ff
                hex 4c 26 93 49 24 12 09 04 49 fe 80 be 84 88 90 be
                hex 80 ad 80 a2 be a2 80 ab aa a2 80 be 84 b5 82 be
                hex 82 80 be 49 ec a2 9c 80 9c a2 f6 88 90 be 80 be
                hex a2 b0 aa 92 80 db 9c 80 86 80 a4 aa 49 ea 80 be
                hex aa a2 80 b3 80 be aa 9c 80 eb a2 be a2 80 be 84
                hex dd 9c a2 aa ba 80 a2 49 eb 90 be 80 a2 be a2 f7
                hex 88 90 be 80 be 84 88 b7 80 9c a2 aa ba 80 df a2
                hex 80 be 84 88 90 be 49 80 ad f8 49 93 a6 ac ad 80
                hex df fc 9c 39 73 e7 cf df 68 31 07 e3 07 64 7f bf
                hex df 80 ef c0 fe ff 69 07 f8 c7 bf 0c 00 ff 12 80
                hex de c0 7f ff 68 64 7e bd db 88 ef f7 93 df bf 7f
                hex ff 01 fe 43 ab bb fb f7 ef df 3f ff 89 fe fd fb
                hex 53 fe 92 fe 6c a0 0b 17 a0 fc f8 43 fa 81 17 0b
                hex 81 f8 fc 80 17 80 f8 73 4e ce 8a fa 70 7e 38 7c
                hex c6 82 92 f2 49 28 fe 80 7b 78 fc 96 92 f2 60 7b
                hex 60 e0 80 82 fe 7e 7f 40 c2 92 9a 9e f6 62 49 7b
                hex 38 7c c6 82 c6 44 3a 80 84 fe 80 73 6c fe 92 fe
                hex 6c 51 fe 12 02 49 5e fe 1c 38 1c fe 80 fb 87 ff
                hex 1f e3 fd ac b6 80 c1 ff 62 a9 6d c0 c7 c0 c7 c0
                hex 61 18 88 c1 61 8c 88 c1 06 9f d0 34 07 20 3e 3f
                hex 66 3f df 9f ff f8 5f 1f 5f ff 00 fb fb db 31 ff
                hex 00 f0 38 62 a8 01 7f 93 db bd 7e ff be bf cf f7
                hex fb fc ff 49 5e fe 70 38 70 fe 53 fe 22 3e 1c 5f
                hex fe 30 78 ec c6 82 57 fe 82 c6 7c 38 49 52 fe 10
                hex fe 3b 0e 1e f0 1e 0e 5e fe 1c 38 70 fe 2a 82 fe
                hex 82 49 77 4c de 92 96 f4 60 28 66 00 14 c0 00 2a
                hex 02 fe 02 48 fb 67 6e 7c 67 63 7e 00 ff 26 4c 99
                hex 33 67 ce 9c 39 ff 01 02 04 09 12 24 49 93 f9 08
                hex 1c 3e 77 63 00 42 fa 01 01 03 03 07 0b 80 00 c0
                hex 0b 80 e0 f0 0d 60 30 00 b7 63 7f 63 36 1c 00 83
                hex 46 51 fe 92 82 73 7c fe 82 fe 7c ff aa 44 aa 00
                hex aa 44 aa 00 82 a5 7f 22 00 aa 00 22 00 aa 7f 22
                hex aa 00 aa 00 aa 00 fe 73 e7 cf 9f 3f 7f ff ff 26
                hex 4c 99 33 e7 ce 1c f9 62 af 0f fe fc f8 f0 f0 f3
                hex e7 0f ff 82 7e fe 80 fe de d1 a1 41 81 01 02 d0
                hex 3f 7f ff 22 b5 ae fe fc f8 e0 00 e2 fd 03 ff 00
                hex e0 02 fc 00 fa 83 f1 d9 0d bf ff fa 9d 91 87 9b
                hex 9d ff 34 0f 00 20 50 47 0f 00 52 55 75 70 01 00
                hex ff fa 07 00 0f 03 cf ff 34 0f 7f 63 79 7c 0f 00
                hex 65 55 56 f8 87 f2 b0 1b ff d8 01 f9 01 ff 34 07
                hex 06 ff c5 07 9e c3 e3 18 0f ff fa c7 63 33 83 99
                hex ff 24 87 ff e0 ff 3f 87 ff 1f 8f c8 72 92 52 56
                hex 5a 60 71 4a 24 fb 5a 52 92 00 ff 1f 83 bb 4a 71
                hex 00 ff 9f 9d 61 90 10 28 77 97 94 a4 c4 c7 a4 24
                hex b8 28 a8 00 ff fb a4 94 97 00 ff e7 07 72 24 a5
                hex ad b5 75 93 94 a4 c4 a4 25 ff cd 0c ec 8c 0e ef
                hex 0f cf ff ec 0c 8c 6c 0c cc 2c 2f 80 fa 80 91 a2
                hex e7 81 07 ff 80 05 81 00 0f 87 05 3b c7 df c0 1f
                hex 3f 1c 30 3c 3f a2 bd 81 00 f8 81 f0 ff 80 d0 c0
                hex fc fe 01 80 87 d0 ee f1 fc

pt_dkjr         ; BG PT data for Donkey Kong Jr.
                hex 03 2a 57 fe 82 c6 7c 38 73 7c fe 82 fe 7c 5e fe
                hex 1c 38 70 fe 09 5f fe 30 78 ec c6 82 51 fe 92 82
                hex 3b 0e 1e f0 1e 0e 7e 38 7c c6 82 92 f2 83 ab 7b
                hex 60 e0 80 82 fe 7e 5f fe 22 62 f2 de 9c 14 c0 00
                hex 3a c0 f0 f8 fc 07 08 1c 3c 43 fd 90 80 40 80 fc
                hex 80 40 80 fc 83 40 80 00 80 fc 97 fc f8 f0 c0 00
                hex a2 9f 80 3f da 44 42 41 40 20 a0 aa ff 0e c0 3f
                hex 00 e0 af df ff 06 ff 00 ad 1f 3f ff 3f bf 3f 80
                hex 04 40 0f e1 04 f4 d4 14 80 0f c3 f4 34 f4 54 80
                hex 0f a7 54 b4 f4 14 f4 4d ac fb 1b fb 7b 80 0f b0
                hex 7b fb db 80 0f b1 1b fb db fb 80 0f b9 1b fb 1b
                hex 3b 5b 80 0f 4d f8 5b bb fb 7b 3b 80 0f c1 fb 7b
                hex fb 80 0f e5 3b 9b 5b 1b fb 80 0f 80 fb 81 0f 8f
                hex 5d 80 fb e0 cf 8f 0f 81 fb f7 81 0f 1f fb f7 ef
                hex 9f 7f ff fc 03 e0 1f 7f ff c0 fc 00 01 00 3c 80
                hex bb 88 45 44 07 ad aa 8a 08 00 07 df af b8 08 00
                hex 07 da aa e9 08 00 62 ea 07 e3 f9 fc 08 80 07 9e
                hex c3 e3 07 06 ff c5 07 1f 8f c8 68 07 e0 ff 3f 07
                hex 20 3e 3f 06 60 2f 06 60 fc 62 b5 07 7f ff 81 07
                hex 83 f9 c1 c0 01 00 bf ff 7f 3f 1f 0f 07 03 9f ff
                hex fe fc f8 f0 e0 22 7f e0 3f 7f ff 80 ee 80 d1 80
                hex 80 80 7e 80 bb 80 45 68 fa 9d 91 87 9b 9d ff fa
                hex 83 f1 d9 0d bf ff fa 07 00 0f 03 cf ff 70 01 00
                hex ff 48 d8 01 f9 01 ff f8 87 f2 b0 1b ff fa c7 63
                hex 33 83 99 ff b8 f3 ff 0f ff 63 a1 5a 03 ff 03 33
                hex f0 33 03 c7 ff 01 80 72 5f f8 f3 f9 fc fe ff fc
                hex e7 cf 9f 3f 7f ff 80 ee 60 bf 3f 80 bb 08 fe 8c
                hex b8 b5 8e ff 00 0b ff 9f 9d f8 a5 ad 6d ff 00 0b
                hex ff 1f 83 f8 5b 6b 68 ff 00 0b ff e7 07 b8 d7 57
                hex ff 00 08 ff ac f8 5b 6b 6c ff 00 0a ff 01 f8 4a
                hex 5a db ff 00 0b ff 0f 87 78 df 3f ff 00 0b ff 0f
                hex c7 b8 ad a3 ff 00 0b ff f8 f0 62 e5 03 33 13 f8
                hex ff fe fc f8 00 02 93 ff 99 cc e6 73 39 9c ce e7
                hex ff 4c 99 33 67 ce 9c 39 73 a2 5a 80 11 80 44 60
                hex 8e b5 72 6d ad a9 a5 28 77 68 6b 5b 3b 38 5b 61
                hex 6f ef d7 75 6c 6b 5b 3b 5b 72 db 5a 52 4a 22 a9
                hex 66 3e dd 9f ff 63 6d ad a3 ad 50 3f ff 7f 01 03
                hex 07 0f 1f 3f 7f 72 5f ff 20 90 48 24 92 c9 64 32
                hex ff 02 04 09 12 24 49 93 26 80 ee 3c bf 3f 7f ff
                hex 80 bb d9 fe ff fe ff fe 25 80 91 bf 91 31 63 c6
                hex 8c 18 30 f0 60 c0 80 00 e0 fd fe ff 63 7d 01 01
                hex 19 00 ff 00 e0 4c 99 ff 66 00 ff 00 ff 81 ff 05
                hex 80 05 32 5d ff f6 ed db b6 6c d9 b3 66 ff cc 98
                hex 31 63 c6 8c 18 30 80 ee 87 d1 91 51 d1 07 fe fd
                hex fb 73 bf 63 00 ff fc fb a0 f7 ef a0 fc f8 80 ef
                hex 80 f8 80 ef 87 f8 f9 fa fc 4d 80 ef e0 fa f9 f8
                hex 81 ef f7 81 f8 fc f1 f7 fb fc ff 00 c0 fc ff 2a
                hex 1f 0f 07 30 7f ff 72 8b 87 05 3b c7 df 87 d0 ee
                hex f1 fc 81 00 80 c0 fc fe 02 7d 01 0f 80 05 81 02
                hex fa 80 d0 81 20 2f 01 f8 0d 07 01 03 02 01 01 80
                hex 02 f8 0d 3d 7d 6d 4d 80 02 80 4d 80 02 87 4d 6d
                hex 7d 3d 02 ea 03 e0 30 0b 80 00 c0 55 30 00 30 00
                hex c1 3e 63 00 c1 3f 30 00 08 c7 3f 0c 1c 0c 00 ef
                hex 3e 63 03 7e 60 7e 00 1f 25 26 74 24 00 d0 30 18
                hex 00 09 77 0c 9e 92 d2 7e 3c 73 6c fe 92 fe 6c 7f
                hex 40 c2 92 9a 9e f6 62 77 4c de 92 96 f4 60 09 53
                hex fe 22 3e 1c 7b 38 7c c6 82 c6 44 53 fe 92 fe 6c
                hex 3c 80 ec 6c 00 09 7b 78 fc 96 92 f2 60 52 fe 10
                hex fe 7f f8 fc 26 22 26 fc f8 2a 02 fe 02 09 51 fe
                hex 12 02 2a 82 fe 82 78 08 0e 06 00 5e fe 1c 38 1c
                hex fe 03 a8 7f c4 e6 f2 b2 ba 9e 8c 5e fe 70 38 70
                hex fe 41 10 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00

pt_baseball     ; BG PT data for Baseball
                hex 03 2a 53 fe 92 fe 6c 7f f8 fc 26 22 26 fc f8 77
                hex 4c de 92 96 f4 60 83 af 51 fe 92 82 28 fe 80 07
                hex 08 1c 3c 3a c0 f0 f8 fc 90 7c bc 80 fc 03 f7 80
                hex 40 80 fc 83 40 80 00 80 fc 97 fc f8 f0 c0 00 20
                hex ff 20 ff b2 bf da 45 42 41 40 20 1e 3f c0 3f 00
                hex a0 aa ff 0e 00 ff 00 e0 af df ff 0e 00 ff 00 e0
                hex aa 9d ff 9d 80 f4 61 0f 2f ef 80 f4 c3 0f cf 0f
                hex af 80 f4 a7 af 4f 0f ef 0f 80 f4 ac 0f ef 0f 8f
                hex 4d b0 7b fb db 80 f4 b1 1b fb db fb 80 f4 b9 1b
                hex fb 1b 3b 5b 80 f4 f8 5b bb fb 7b 3b 80 f4 4d c1
                hex fb 7b fb 80 f4 e5 3b 9b 5b 1b fb 80 f4 81 fb 7b
                hex 80 f4 e0 3b 7b fb 80 f4 2c 0e fe 01 ff 18 01 ff
                hex de ee de be 7e fe fd d0 3f 7f ff 82 80 00 80 fe
                hex 88 bb ba 88 fe ff a4 0f ff ad aa 8a cf 40 00 ff
                hex df af b8 cf 07 00 ff 9a aa 98 cf f0 00 80 9c 86
                hex 83 a4 e7 30 78 00 61 3c 1c 07 f9 00 3a a7 1e 00
                hex e0 70 37 07 1f 00 c0 a4 07 df c1 c0 06 9f d0 06
                hex 9f 03 07 80 00 7e 58 c7 fe ff 83 f9 c1 3f 80 c0
                hex e0 f0 f8 fc 1f 01 03 07 0f 1f e0 3f 7f ff a2 fd
                hex 80 d1 80 3f 80 7e 80 fe 80 45 80 fe 7f 21 73 33
                hex 3f 1e 0c 09 59 f0 0c 3e 7f c7 8f c7 ff fe 7c 1c
                hex fd 0c 80 00 3c 7f ff 18 ef 08 c8 00 c8 08 38 ff
                hex a2 54 12 ff 00 f7 33 37 36 96 9e 1a 1e 90 80 00
                hex b2 57 c0 01 00 f8 f3 f9 fc fe ff fc e7 cf 9f 3f
                hex 7f ff 80 d1 60 bf 3f b2 d5 80 45 08 fe f8 a5 b9
                hex 83 ff 00 fb 4a 32 87 ff 00 40 c0 fb 95 65 0c ff
                hex 00 02 07 58 fb f5 14 f7 00 ff e7 e2 fb ab 6c c7
                hex 00 ff cf 49 f8 54 d4 9c 00 ff bb 28 38 00 ff fd
                hex cc 58 09 ff 7f 78 01 03 07 ff ff 66 33 19 8c c6
                hex 63 31 18 ff b3 66 cc 98 31 63 c6 8c b2 a5 80 d1
                hex 80 45 73 83 b9 a5 b9 a5 67 03 4a 4b 7a 4a 58 7b
                hex f3 9a 6a ea 9a 7a 7b f7 14 f5 85 f4 15 73 cf 6b
                hex ab 68 ab 78 df 50 57 54 52 8a 78 bf a1 af 28 7f
                hex 01 03 07 0f 1f 3f 7f ff df 6f b7 db 6d 36 9b cd
                hex b3 7d ff 02 04 09 12 24 49 93 26 39 00 ff 00 ff
                hex e0 e7 cf ff e7 00 ff 00 ff 00 ff 01 6e 80 6e a4
                hex ff 33 e7 ce 1c f9 f3 e7 0f f0 9f 3f 7f ff 03 80
                hex 40 01 01 b3 f5 39 00 ff 00 ff e0 4c 99 ff e7 00
                hex ff 00 ff 00 ff 01 05 80 05 ff 09 12 24 49 93 26
                hex 4c 99 b2 76 ff 33 67 ce 9c 39 73 e7 cf 80 d1 87
                hex 3f 7f bf 3f 87 00 01 02 04 86 40 41 42 4d a0 f7
                hex ef a0 0b 17 80 ef 80 17 87 ef ee ed eb 80 17 e0
                hex ed ee ef 80 17 12 fe 9c ff 01 fe ff 06 01 00 8e
                hex fe 7e be de 02 7f 1c 30 3c 3f c0 1f 3f 87 05 3b
                hex c7 df 12 ad 80 ff 87 d0 ee f1 fc 01 80 c0 fc fe
                hex 81 00 0f 42 f7 80 05 81 02 fa 80 d0 81 20 2f 01
                hex f8 03 03 06 01 01 4d 80 02 f8 0d 3d 7d 6d 4d 80
                hex 02 80 4d 80 02 87 4d 6d 7d 3d b8 02 03 01 00 e0
                hex 0d 01 00 09 57 fe 82 c6 7c 38 14 c0 00 73 7c fe
                hex 82 fe 7c 5f fe 22 62 f2 de 9c 09 28 66 00 7b 38
                hex 7c c6 82 c6 44 5e fe 1c 38 1c fe 5f 06 e2 f2 1a
                hex 0e 06 08 1f 25 26 74 24 00 d0 30 18 00 c7 3f 0c
                hex 1c 0c 00 fb 3c 06 03 3f 63 3e 00 09 73 6c fe 92
                hex fe 6c 7f 40 c2 92 9a 9e f6 62 53 fe 22 3e 1c 7b
                hex 78 fc 96 92 f2 60 09 5f fe 30 78 ec c6 82 7e 38
                hex 7c c6 82 92 f2 3c 80 ec 6c 00 52 fe 10 fe 09 2a
                hex 02 fe 02 51 fe 12 02 2a 82 fe 82 5e fe 70 38 70
                hex fe 02 80 0d 60 30 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00

pt_dk3          ; BG PT data for Donkey Kong 3
                hex 03 2a 57 fe 82 c6 7c 38 73 7c fe 82 fe 7c 5e fe
                hex 1c 38 70 fe 09 5f fe 30 78 ec c6 82 51 fe 92 82
                hex 3b 0e 1e f0 1e 0e 7e 38 7c c6 82 92 f2 83 bf 7f
                hex 40 c2 92 9a 9e f6 62 07 08 1c 3c 3a c0 f0 f8 fc
                hex 90 7c bc 80 fc 80 bc 80 fc 12 de e0 02 fc 00 02
                hex 00 ae fe fc f8 e0 00 80 3f 80 3f da ba bd be bf
                hex df ac 1e 3f c0 3f 00 a0 aa ff 0e 00 ff 00 e0 af
                hex df ff 0e 00 ff 00 e0 ad 98 ff 0e 00 ff 00 b8 81
                hex bf 80 ff 4d c3 fb 3b fb 5b 80 f4 a7 5b bb fb 1b
                hex fb 80 f4 ac fb 1b fb 7b 80 f4 b0 7b fb db 80 f4
                hex 4d b1 1b fb db fb 80 f4 b9 1b fb 1b 3b 5b 80 f4
                hex f8 5b bb fb 7b 3b 80 f4 c1 fb 7b fb 80 f4 4d e5
                hex 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4 e0 3b 7b fb
                hex 80 f4 81 fb f7 81 f4 e8 a2 fd de d1 a1 41 81 01
                hex 02 d0 3f 7f ff 82 7e fe 80 fe 80 45 88 fe ff 0f
                hex ff ad aa 8a a4 0f ff df af b8 0e ff 9d ad 0f 80
                hex 9c 86 83 07 61 3c 1c a4 07 f9 00 3a 07 e0 70 37
                hex 07 1f 00 c0 07 df c1 c0 a4 06 9f d0 06 9f 03 07
                hex 80 00 7e c7 01 00 7c 06 3e 52 ab 3f 80 c0 e0 f0
                hex f8 fc 1f 01 03 07 0f 1f e0 3f 7f ff 80 ee 80 d1
                hex 52 fa 80 80 80 7e 80 bb 80 45 fa 9d 91 87 9b 9d
                hex ff fa 83 f1 d9 0d bf ff a4 fa f8 ff f0 fc 30 00
                hex 70 fe ff 00 d8 fe 06 fe 00 f8 78 0d 4f e4 00 a2
                hex 54 fa 38 9c cc 7c 66 00 1f f0 06 07 03 00 d7 18
                hex f8 18 f8 f0 00 b2 57 c0 01 00 f8 f3 f9 fc fe ff
                hex fc e7 cf 9f 3f 7f ff 80 d1 60 bf 3f b2 d5 80 45
                hex 08 fe bb b5 8e ff 00 60 62 fb a5 ad 6d ff 00 e0
                hex 7c fb 5b 6b 68 ff 00 18 f8 58 b8 28 a8 00 ff fa
                hex a4 94 93 00 ff 01 fb b5 a5 24 00 ff 0f 87 fb 06
                hex 27 c3 00 ff 0f c7 59 9f 6f ef cf 0c 08 09 9f 09
                hex 08 0c 1f 3f 7f ff 18 8c c6 63 31 98 cc 66 ff b3
                hex 66 cc 98 31 63 c6 8c b2 a5 80 d1 80 45 60 8e b5
                hex 72 6d ad a9 a5 58 77 97 94 a4 c4 c7 a4 61 90 10
                hex 28 75 93 94 a4 c4 a4 72 24 a5 ad b5 52 a2 7e c3
                hex 27 26 20 60 00 75 f0 f8 18 f8 18 7f 01 03 07 0f
                hex 1f 3f 7f b2 5f ff 20 90 48 24 92 c9 64 32 ff 02
                hex 04 09 12 24 49 93 26 80 d1 3c bf 3f 7f ff 80 45
                hex d9 fe ff fe ff fe 59 80 91 bf 91 31 63 c6 8c 18
                hex 30 f0 60 c0 80 00 e0 fd fe ff a3 7d 01 01 39 00
                hex ff 00 ff e0 4c 99 ff e7 00 ff 00 ff 00 ff 81 ff
                hex 05 80 05 a2 5d ff 09 12 24 49 93 26 4c 99 ff 33
                hex 67 ce 9c 39 73 e7 cf 80 d1 87 3f 7f bf 3f 07 01
                hex 02 04 93 bf 63 ff 00 03 04 a0 0b 17 a0 fc f8 80
                hex 17 80 f8 80 17 87 f8 f9 fa fc 8d 80 17 e0 fa f9
                hex f8 81 17 0b 81 f8 fc f1 0b 04 03 00 ff c0 fc ff
                hex 3a 60 e0 f0 f8 30 7f ff 32 8b 87 05 3b c7 df 87
                hex d0 ee f1 fc 81 00 80 c0 fc fe 02 7d 01 0f 80 05
                hex 81 07 ff 80 d0 81 f0 ff 01 f8 4d 07 01 03 02 01
                hex 01 80 02 f8 0d 3d 7d 6d 4d 80 02 80 4d 80 02 87
                hex 4d 6d 7d 3d 83 ea e0 0d 01 00 d8 0f 03 01 00 14
                hex c0 00 5f fe 22 62 f2 de 9c 28 66 00 08 d3 3e 63
                hex 03 0f 00 c1 3e 63 00 c1 3f 30 00 c7 3f 0c 1c 0c
                hex 00 08 1f 62 12 67 32 00 d0 30 18 00 fb 3c 06 03
                hex 3f 63 3e 00 db 3e 63 3e 63 3e 00 09 7d 30 38 2c
                hex 26 fe 20 77 4c de 92 96 f4 60 53 fe 22 3e 1c 7b
                hex 38 7c c6 82 c6 44 09 7b 78 fc 96 92 f2 60 53 fe
                hex 92 fe 6c 3c 80 ec 6c 00 52 fe 10 fe 09 2a 02 fe
                hex 02 2a 82 fe 82 7f f8 fc 26 22 26 fc f8 5e fe 70
                hex 38 70 fe 03 a8 51 fe 12 02 5e fe 1c 38 1c fe 41
                hex 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00

pt_dkjrmath     ; BG PT data for Donkey Kong Jr. Math
                hex 03 2a 57 fe 82 c6 7c 38 73 7c fe 82 fe 7c 5e fe
                hex 1c 38 70 fe 09 5f fe 30 78 ec c6 82 51 fe 92 82
                hex 3b 0e 1e f0 1e 0e 7e 38 7c c6 82 92 f2 09 7b 60
                hex e0 80 82 fe 7e 5f fe 22 62 f2 de 9c 14 c0 00 5e
                hex fe 1c 38 1c fe 83 ab 7f f8 fc 26 22 26 fc f8 2a
                hex 02 fe 02 52 fe 10 fe 07 08 1c 3c 3a c0 f0 f8 fc
                hex 03 fd 90 80 40 80 fc 80 40 80 fc 83 40 80 00 80
                hex fc 97 fc f8 f0 c0 00 92 6f 80 3f da 45 42 41 40
                hex 20 9e ff 3f c0 3f 00 a0 aa ff 8e ff 00 ff 00 e0
                hex af df ff 9d 80 f4 7f 7f bf 7f ff 7f bf 7f 80 f4
                hex 61 0f 2f ef 80 f4 c3 0f cf 0f af 80 f4 a7 af 4f
                hex 0f ef 0f 4d ac fb 1b fb 7b 80 f4 b0 7b fb db 80
                hex f4 b1 1b fb db fb 80 f4 b9 1b fb 1b 3b 5b 80 f4
                hex 4d f8 5b bb fb 7b 3b 80 f4 c1 fb 7b fb 80 f4 e5
                hex 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4 9d 80 f4 e0
                hex cf 8f 0f 81 f4 e8 81 0f 1f fb e8 90 60 80 00 03
                hex fc e0 1f 7f ff c1 03 ff 00 01 00 a2 d5 80 45 88
                hex fe ff 0f ff ad aa 8a 0f ff df af b8 0f ff da aa
                hex b8 a4 0f 80 9c 86 83 07 61 3c 1c 07 f9 00 3a 07
                hex e0 70 37 a4 07 1f 00 c0 07 df c1 c0 06 9f d0 06
                hex 9f 03 58 87 ff 7f ff 81 c7 fe ff 83 f9 c1 3f 80
                hex c0 e0 f0 f8 fc 1f 01 03 07 0f 1f 52 bf e0 3f 7f
                hex ff 80 ee 80 d1 80 80 80 7e 80 bb 80 45 58 f0 a7
                hex 9f 9e ff f0 e5 9e e4 ff f0 a2 60 b3 ff fc 1a f8
                hex fa d5 f8 ff a2 51 fc 7b 73 2c 7f f8 00 fc d4 d0
                hex 6a fe d0 00 c0 01 00 b2 5f f8 f3 f9 fc fe ff fc
                hex e7 cf 9f 3f 7f ff 80 d1 60 bf 3f 80 45 08 fe 58
                hex 08 ff e8 12 1e 00 ff eb 13 1c 00 ff fa f0 fb 20
                hex e1 01 00 ff ae 14 58 5b 80 00 ff 13 23 78 01 03
                hex 07 ff ff 66 33 19 8c c6 63 31 18 ff b3 66 cc 98
                hex 31 63 c6 8c b2 a1 80 d1 80 45 3d e1 ed 8c bf 8c
                hex 58 0d bf a0 bf 3d 1c 13 d3 48 d3 7d 01 e1 20 2f
                hex 48 2f 5d 80 00 f0 10 f0 b2 57 7f fe fc f8 f0 e0
                hex c0 80 ff 20 90 48 24 92 c9 64 32 ff 02 04 09 12
                hex 24 49 93 26 80 d1 3c bf 3f 7f ff b3 d5 e7 00 ff
                hex 00 ff 00 ff 01 6e 80 6e bf 6e ce 9c 39 73 e7 cf
                hex f0 9f 3f 7f ff a2 5f 03 80 40 01 01 80 d1 ff 7f
                hex bf 3f 7f ff bf 3f 7f 80 45 87 fe ff fe ff a2 57
                hex 07 ff 00 ff ff 09 12 24 49 93 26 4c 99 ff 33 67
                hex ce 9c 39 73 e7 cf 80 d1 87 3f 7f bf 3f b3 6f 87
                hex 00 01 02 04 e3 00 ff 00 03 04 a0 0b 17 a0 fc f8
                hex 80 17 80 f8 8d 80 17 87 f8 f9 fa fc 80 17 e0 fa
                hex f9 f8 81 17 0b 81 f8 fc f1 0b 04 03 00 ff c0 fc
                hex ff 32 e2 9c 00 30 3c 3f c0 1f 3f 87 05 3b c7 df
                hex 87 d0 ee f1 fc 02 df 01 80 c0 fc fe 01 0f 80 05
                hex 81 07 ff 80 d0 81 f0 ff 43 7f 84 01 00 07 01 03
                hex 02 01 01 80 02 f8 0d 3d 7d 6d 4d 80 02 80 4d 02
                hex fa 03 ff 00 78 fe 07 03 ff 03 e0 30 0b 80 e0 f0
                hex 55 30 00 30 00 e7 1e 33 60 33 1e 00 09 53 fe 92
                hex fe 6c 3a 80 84 fe 80 7f c4 e6 f2 b2 ba 9e 8c 7f
                hex 04 1e 04 00 1e 08 10 09 3c 80 e0 60 00 77 0c 9e
                hex 92 d2 7e 3c 73 6c fe 92 fe 6c 7f 40 c2 92 9a 9e
                hex f6 62 09 77 4c de 92 96 f4 60 53 fe 22 3e 1c 7b
                hex 78 fc 96 92 f2 60 3c 80 ec 6c 00 08 c1 3e 63 00
                hex c3 3f 0c 3f 00 c1 3f 30 00 0d 60 30 00 03 a8 5e
                hex fe 70 38 70 fe 7f 1e 3e 70 e0 70 3e 1e 51 fe 12
                hex 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00

pt_golf         ; BG PT data for Golf
                hex 03 2a 7e 38 7c c6 82 92 f2 73 7c fe 82 fe 7c 28
                hex fe 80 83 bf 51 fe 12 02 07 08 1c 3c 3a c0 f0 f8
                hex fc 90 7c bc 80 fc 80 bc 80 fc 12 de e0 02 fc 00
                hex 02 00 ae fe fc f8 e0 00 80 3f 80 3f da ba bd be
                hex bf df 9d a0 e8 f4 7f 3f ff 3f ff 3f ff 3f 80 f4
                hex 78 7f bf 7f ff 80 f4 6e 7f bf ff 3f bf 80 f4 61
                hex 0f 2f ef 4d c3 fb 3b fb 5b 80 f4 a7 5b bb fb 1b
                hex fb 80 f4 ac fb 1b fb 7b 80 f4 b0 7b fb db 80 f4
                hex 4d b1 1b fb db fb 80 f4 b9 1b fb 1b 3b 5b 80 f4
                hex f8 5b bb fb 7b 3b 80 f4 c1 fb 7b fb 80 f4 4d e5
                hex 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4 e0 3b 7b fb
                hex 80 f4 81 fb f7 81 f4 e8 a2 fd de d1 a1 41 81 01
                hex 02 d0 3f 7f ff 82 7e fe 80 fe 80 45 88 fe ff 0f
                hex ff ad aa 8a a4 0f ff df af b8 0f ff cb ab b9 0f
                hex 80 9c 86 83 07 61 3c 1c a4 07 f9 00 3a 07 e0 70
                hex 37 07 1f 00 c0 07 df c1 c0 a4 06 9f d0 06 9f 03
                hex 07 80 00 7e c7 01 00 7c 06 3e 52 ab 3f 80 c0 e0
                hex f0 f8 fc 1f 01 03 07 0f 1f e0 3f 7f ff 80 ee 80
                hex d1 a2 f1 80 7e 80 fe 80 45 80 fe c9 1f 00 0f 00
                hex 58 cb 07 c7 07 0f d7 91 c8 e4 ec ad 0f 8f bf fe
                hex ff f4 c1 e1 f8 fc 00 b2 57 c0 01 00 f8 f3 f9 fc
                hex fe ff fc e7 cf 9f 3f 7f ff 80 d1 60 bf 3f b2 d5
                hex 80 45 08 fe 08 00 0b 00 0f 1f fa 4a 32 87 ff 00
                hex f8 59 ff 6f af ac 6e cf 0c ec 2c e7 ec 0e 0f ef
                hex 2f af fa af ac ec 0c 0e 0f 87 0f 1f 3f 7f b2 5a
                hex ff 99 cc e6 73 39 9c ce e7 ff 4c 99 33 67 ce 9c
                hex 39 73 80 d1 80 45 52 2a 76 78 cd b5 a5 bd 70 f3
                hex 9a 6a 79 f7 15 f5 85 84 58 03 e0 20 7f 01 03 07
                hex 0f 1f 3f 7f ff df 6f b7 db 6d 36 9b cd ff fd fb
                hex f6 ed db b6 6c d9 b3 f5 39 00 ff 00 ff e0 e7 cf
                hex ff e7 00 ff 00 ff 00 ff 01 6e 80 6e bf 6e ce 9c
                hex 39 73 e7 cf a3 57 f0 9f 3f 7f ff e0 02 01 00 01
                hex 01 39 00 ff 00 ff e0 4c 99 ff a2 d5 80 45 87 fe
                hex ff fe ff 07 ff 00 ff ff 09 12 24 49 93 26 4c 99
                hex ff 33 67 ce 9c 39 73 e7 cf b2 db 80 d1 87 3f 7f
                hex bf 3f 87 00 01 02 04 86 40 41 42 9e 00 3f c0 3f
                hex ff 06 c0 00 4d 80 ef 80 17 87 ef ee ed eb 80 17
                hex e0 ed ee ef 80 17 81 ef f7 81 17 0b 32 f8 8e fe
                hex 7e be de 02 7f 9c 00 30 3c 3f c0 1f 3f 87 05 3b
                hex c7 df 12 b7 87 d0 ee f1 fc 01 80 c0 fc fe 81 00
                hex 0f 80 05 81 07 ff 02 df 80 d0 81 f0 ff 01 f8 03
                hex 03 06 03 03 07 03 ff 00 78 3f 70 60 ff 03 fe 80
                hex 02 80 4f 80 02 87 4f 6f 7f 3f b8 02 03 01 00 d8
                hex 0f 03 01 00 57 fe 82 c6 7c 38 09 14 c0 00 5f fe
                hex 22 62 f2 de 9c 28 66 00 5e fe 1c 38 1c fe 08 b7
                hex 63 7f 63 36 1c 00 99 0c 1e 33 00 c7 3f 0c 1c 0c
                hex 00 1f 62 12 67 32 00 09 3c 80 e0 60 00 77 0c 9e
                hex 92 d2 7e 3c 73 6c fe 92 fe 6c 7d 30 38 2c 26 fe
                hex 20 09 77 4c de 92 96 f4 60 53 fe 22 3e 1c 51 fe
                hex 92 82 7b 38 7c c6 82 c6 44 09 7b 78 fc 96 92 f2
                hex 60 5f fe 30 78 ec c6 82 53 fe 92 fe 6c 3c 80 ec
                hex 6c 00 09 52 fe 10 fe 2a 02 fe 02 2a 82 fe 82 5e
                hex fe 70 38 70 fe 02 a8 0d 60 30 00 ff 63 67 6f 7f
                hex 7b 73 63 00 c1 3e 63 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00

pt_gomoku       ; BG PT data for Gomoku
                hex 03 2a 7e 38 7c c6 82 92 f2 73 7c fe 82 fe 7c 5e
                hex fe 1c 38 1c fe 09 5f fe 30 78 ec c6 82 73 7e fe
                hex 80 fe 7e 5e fe 1c 38 70 fe 7f f8 fc 26 22 26 fc
                hex f8 83 ab 5f fe 22 62 f2 de 9c 53 fe 92 fe 6c 51
                hex fe 92 82 07 08 1c 3c 3a c0 f0 f8 fc 03 fd 90 80
                hex 40 80 fc 80 40 80 fc 83 40 80 00 80 fc 97 fc f8
                hex f0 c0 00 82 7f 80 3f da 44 42 41 40 20 c0 fe ff
                hex ae 55 00 c0 3f 00 18 c0 ff e6 50 20 00 ff 00 08
                hex ff 0d ef 0b 8b 4b 0b 8b 4b 8b 80 0f e1 0b fb db
                hex 1b 80 0f c3 fb 3b fb 5b 80 0f a7 5b bb fb 1b fb
                hex 80 0f 0d ac fb 1b fb 7b 80 0f b0 7b fb db 80 0f
                hex b1 1b fb db fb 80 0f b9 1b fb 1b 3b 5b 80 0f 0d
                hex f8 5b bb fb 7b 3b 80 0f c1 fb 7b fb 80 0f e5 3b
                hex 9b 5b 1b fb 80 0f 81 fb 7b 80 0f 1d e0 3b 7b fb
                hex 80 0f 81 fb f7 81 0f 1f fb f7 ef 9f 7f ff fc 03
                hex e0 1f 7f ff c0 fc 00 01 00 22 ea 88 bb ba 80 fe
                hex 0f 00 52 55 75 0f 00 20 50 47 0f 00 32 55 45 28
                hex 0f 7f 63 79 7c 07 9e c3 e3 07 06 ff c5 07 1f 8f
                hex c8 28 07 e0 ff 3f 07 20 3e 3f 06 60 2f 06 60 fc
                hex 08 87 ff 7f ff 81 c7 fe ff 83 f9 c1 3f 80 c0 e0
                hex f0 f8 fc 1f 01 03 07 0f 1f 02 bf e0 3f 7f ff 80
                hex ee 80 3f 80 80 80 fe 80 bb 80 fe 08 fa 80 ed 81
                hex e7 80 ff f2 b9 81 b9 81 ff fe 43 06 b6 02 13 df
                hex ff fe 03 70 00 46 1f 0f ff 09 fc e7 c7 8f 17 33
                hex ff 6f fe 16 4e 5e 02 7e ff 0e 7e fe 86 ae b6 de
                hex 02 f0 b6 fe 00 ff 23 2a 01 7f 8f 00 80 c0 60 30
                hex fc 18 30 60 c0 80 00 02 fa e0 2e 6e ee 80 3f 88
                hex ba bb 80 fe f9 42 4a 31 00 ff 80 f9 5b 51 91 00
                hex ff 81 08 b9 4a 32 00 ff e7 d9 92 52 00 ff 0f f8
                hex d4 94 93 00 ff bb a5 38 00 ff 00 7f 09 bd 2d cd
                hex 0d ed 2d cd f4 0d ed 2c 2f 0f 87 0f 1f 3f 7f ff
                hex 18 8c c6 63 31 98 cc 66 02 be ff b3 66 cc 98 31
                hex 63 c6 8c 80 2e 80 3f 80 ba 80 fe 66 31 4a 5a 42
                hex 08 72 91 51 55 5b 65 32 4a 4b 4a 75 4c 52 92 12
                hex 92 53 94 b4 d7 d4 08 43 a5 b9 a5 63 2e 29 ee 29
                hex 63 78 40 70 40 7f 01 03 07 0f 1f 3f 7f 02 af ff
                hex df 6f b7 db 6d 36 9b cd ff fd fb f6 ed db b6 6c
                hex d9 bc 2e 6e ee ae 2e 80 3f d9 bb ba bb ba bb 80
                hex fe 09 80 91 bf 91 31 63 c6 8c 18 30 f0 60 c0 80
                hex 00 e0 fd fe ff 23 be 01 fe f9 b3 66 ff 00 ff 00
                hex 20 ff 67 00 ff 00 ff fa 81 ff 00 80 fa 22 ae ff
                hex f6 ed db b6 6c d9 b3 66 ff cc 98 31 63 c6 8c 18
                hex 30 87 ee ae 6e ee 80 3f 07 fe fd fb 33 bf 63 00
                hex ff fc fb a0 f7 ef a0 fc f8 80 ef 80 f8 87 ef ee
                hex ed eb 80 f8 0d e0 ed ee ef 80 f8 81 ef f7 81 f8
                hex fc f1 f7 fb fc ff 00 c0 fc ff 2a 1f 0f 07 30 7f
                hex ff 32 8b 87 05 3b c7 df 87 d0 ee f1 fc 81 00 80
                hex c0 fc fe 02 7d 01 0f 80 05 81 07 ff 80 d0 81 f0
                hex ff 01 f8 4d 07 01 03 02 01 01 80 02 f8 0d 3d 7d
                hex 6d 4d 80 02 80 4d 80 02 87 4d 6d 7d 3d 83 ea e0
                hex 0d 01 00 d8 0f 03 01 00 57 fe 82 c6 7c 38 14 c0
                hex 00 28 66 00 09 77 4c de 92 96 f4 60 2a 02 fe 02
                hex 7f c4 e6 f2 b2 ba 9e 8c 5f 06 e2 f2 1a 0e 06 08
                hex 1f 25 26 74 24 00 d0 30 18 00 c7 3f 0c 1c 0c 00
                hex fb 3c 06 03 3f 63 3e 00 09 73 6c fe 92 fe 6c 7f
                hex 40 c2 92 9a 9e f6 62 53 fe 22 3e 1c 7b 38 7c c6
                hex 82 c6 44 09 3c 80 ec 6c 00 7b 78 fc 96 92 f2 60
                hex 52 fe 10 fe 51 fe 12 02 09 2a 82 fe 82 41 10 00
                hex 28 fe 80 3b 0e 1e f0 1e 0e 02 a0 f9 08 1c 3e 77
                hex 63 00 ed 63 77 7f 6b 63 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00

pt_mahjong      ; BG PT data for Mah-jong
                hex 03 2a 5e fe 1c 38 1c fe 7f f8 fc 26 22 26 fc f8
                hex 52 fe 10 fe 09 41 10 00 7b 60 e0 80 82 fe 7e 73
                hex 7c fe 82 fe 7c 5e fe 1c 38 70 fe 83 bf 7e 38 7c
                hex c6 82 92 f2 07 08 1c 3c 3a c0 f0 f8 fc 90 7c bc
                hex 80 fc 80 bc 80 fc 12 de e0 02 fc 00 02 00 ae fe
                hex fc f8 e0 00 80 3f 80 3f da ba bd be bf df 9d a0
                hex e8 f4 7f 3f ff 3f ff 3f ff 3f 80 f4 78 7f bf 7f
                hex ff 80 f4 79 3f 7f 3f ff 3f 80 f4 61 0f 2f ef 4d
                hex c3 fb 3b fb 5b 80 f4 a7 5b bb fb 1b fb 80 f4 ac
                hex fb 1b fb 7b 80 f4 b0 7b fb db 80 f4 4d b1 1b fb
                hex db fb 80 f4 b9 1b fb 1b 3b 5b 80 f4 f8 5b bb fb
                hex 7b 3b 80 f4 c1 fb 7b fb 80 f4 4d e5 3b 9b 5b 1b
                hex fb 80 f4 81 fb 7b 80 f4 e0 3b 7b fb 80 f4 81 fb
                hex f7 81 f4 e8 a2 fd de d1 a1 41 81 01 02 d0 3f 7f
                hex ff 82 7e fe 80 fe 80 45 88 fe ff 0f ff ad aa 8a
                hex 58 6f e7 ff 00 20 50 47 8f ff 00 52 55 51 ef e5
                hex fe ff 7f 63 79 7c c7 bf ff 9e c3 e3 a4 07 f9 00
                hex 3a 07 e0 70 37 07 1f 00 c0 07 df c1 c0 a4 06 9f
                hex d0 06 9f 03 07 80 00 7e c7 01 00 7c 06 3e 52 ab
                hex 3f 80 c0 e0 f0 f8 fc 1f 01 03 07 0f 1f e0 3f 7f
                hex ff 80 ee 80 d1 a2 f1 80 7e 80 fe 80 45 80 fe ef
                hex df fe d6 df 7f de 77 a5 1f 3d ff fa 7f ff f0 fe
                hex 49 09 00 01 80 8f ff 7f 3f 9f cf b2 7d fc e7 cf
                hex 9f 3f 7f ff 80 d1 60 bf 3f 80 45 08 fe e8 fc fe
                hex ff 00 58 fa 39 ad e7 00 ff 69 f8 5a 66 3c 00 ff
                hex ba b4 fc 00 ff e0 0a ff 1f 58 f8 2a 2b 39 00 ff
                hex f8 d5 35 e7 00 ff f8 ab ac e7 00 ff f8 40 c1 83
                hex 07 ff b2 5a ff 99 cc e6 73 39 9c ce e7 ff 4c 99
                hex 33 67 ce 9c 39 73 80 d1 80 45 58 7f 70 58 6c 36
                hex 1b 0d 06 6f e7 a5 b5 9d ad b5 63 7e 5a 42 5a 67
                hex fc b4 b5 85 b5 58 27 01 fd 04 fc 76 f1 9b 6a ea
                hex 2a 72 e7 35 d5 d4 7e e7 ac ab 2b 2a ab 59 e0 63
                hex 3f 00 7f 01 03 07 0f 1f 3f 7f ff b3 d9 6c b6 db
                hex ed f6 fb ff fd fb f6 ed db b6 6c d9 b3 f5 39 00
                hex ff 00 ff e0 e7 cf ff e7 00 ff 00 ff 00 ff 01 6e
                hex 80 6e bf 6e ce 9c 39 73 e7 cf a3 57 f0 9f 3f 7f
                hex ff e0 02 01 00 01 01 39 00 ff 00 ff e0 4c 99 ff
                hex a2 d5 80 45 87 fe ff fe ff 07 ff 00 ff ff 09 12
                hex 24 49 93 26 4c 99 ff 33 67 ce 9c 39 73 e7 cf b2
                hex db 80 d1 87 3f 7f bf 3f 87 00 01 02 04 86 40 41
                hex 42 9e 00 3f c0 3f ff 06 c0 00 4d 80 ef 80 17 87
                hex ef ee ed eb 80 17 e0 ed ee ef 80 17 81 ef f7 81
                hex 17 0b 32 f8 8e fe 7e be de 02 7f 9c 00 30 3c 3f
                hex c0 1f 3f 87 05 3b c7 df 12 b7 87 d0 ee f1 fc 01
                hex 80 c0 fc fe 81 00 0f 80 05 81 07 ff 02 df 80 d0
                hex 81 f0 ff 01 f8 03 03 06 03 03 07 03 ff 00 78 3f
                hex 70 60 ff 03 fe 80 02 80 4f 80 02 87 4f 6f 7f 3f
                hex b8 02 03 01 00 d8 0f 03 01 00 57 fe 82 c6 7c 38
                hex 09 14 c0 00 5f fe 22 62 f2 de 9c 28 66 00 73 7e
                hex fe 80 fe 7e 09 77 4c de 92 96 f4 60 2a 02 fe 02
                hex 7f c4 e6 f2 b2 ba 9e 8c 5f 06 e2 f2 1a 0e 06 08
                hex 1f 25 26 74 24 00 d0 30 18 00 c7 3f 0c 1c 0c 00
                hex fb 3c 06 03 3f 63 3e 00 09 73 6c fe 92 fe 6c 7f
                hex 40 c2 92 9a 9e f6 62 53 fe 22 3e 1c 51 fe 92 82
                hex 09 7b 38 7c c6 82 c6 44 7b 78 fc 96 92 f2 60 5f
                hex fe 30 78 ec c6 82 53 fe 92 fe 6c 09 3c 80 ec 6c
                hex 00 51 fe 12 02 2a 82 fe 82 28 fe 80 02 a8 99 0c
                hex 1e 33 00 f9 08 1c 3e 77 63 00 ed 63 77 7f 6b 63
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00

pt_mario        ; BG PT data for Mario Bros.
                hex 03 2a 5e fe 1c 38 1c fe 7f f8 fc 26 22 26 fc f8
                hex 5f fe 22 62 f2 de 9c 09 2a 82 fe 82 73 7c fe 82
                hex fe 7c 53 fe 92 fe 6c 77 4c de 92 96 f4 60 83 bf
                hex 14 c0 00 07 08 1c 3c 3a c0 f0 f8 fc 90 7c bc 80
                hex fc 80 bc 80 fc 12 de e0 02 fc 00 02 00 ae fe fc
                hex f8 e0 00 80 3f 80 3f da ba bd be bf df ac 1e 3f
                hex c0 3f 00 a0 aa ff 0e 00 ff 00 e0 af df ff 0e 00
                hex ff 00 e0 8a ad ff 0e 00 ff 00 b8 81 bf 80 ff 4d
                hex c3 fb 3b fb 5b 80 f4 a7 5b bb fb 1b fb 80 f4 ac
                hex fb 1b fb 7b 80 f4 b0 7b fb db 80 f4 4d b1 1b fb
                hex db fb 80 f4 b9 1b fb 1b 3b 5b 80 f4 f8 5b bb fb
                hex 7b 3b 80 f4 c1 fb 7b fb 80 f4 4d e5 3b 9b 5b 1b
                hex fb 80 f4 81 fb 7b 80 f4 e0 3b 7b fb 80 f4 81 fb
                hex f7 81 f4 e8 a2 fd de d1 a1 41 81 01 02 d0 3f 7f
                hex ff 82 7e fe 80 fe 80 45 88 fe ff 0f ff ad aa 8a
                hex a4 0f ff df af b8 0d ff aa a8 0f 80 9c 86 83 07
                hex 61 3c 1c a4 07 f9 00 3a 07 e0 70 37 07 1f 00 c0
                hex 07 df c1 c0 a4 06 9f d0 06 9f 03 07 80 00 7e c7
                hex 01 00 7c 06 3e 52 ab 3f 80 c0 e0 f0 f8 fc 1f 01
                hex 03 07 0f 1f e0 3f 7f ff 80 ee 80 d1 52 fa 80 80
                hex 80 7e 80 bb 80 45 f4 e3 c1 fd 80 ff ec f3 bb ba
                hex bb ff 58 ec 0f 8f 03 ef ff b4 f3 f9 01 ff fc f3
                hex 03 02 06 07 ff fc 2f 2c 00 27 6f ff a3 51 87 60
                hex 00 18 98 b8 f8 88 08 00 01 80 b2 5f f8 f3 f9 fc
                hex fe ff fc e7 cf 9f 3f 7f ff 80 d1 60 bf 3f 80 45
                hex 08 fe 58 eb 03 01 00 ff f3 e3 fb 39 ad e7 00 ff
                hex 87 82 fb 55 6d 39 00 ff ef 2f fb 55 35 e7 00 ff
                hex 8f c7 58 fb 54 6c 38 00 ff 8f 87 fb 55 4d 79 00
                hex ff 9f 8f fb 55 36 e3 00 ff fd f8 fb 55 db 8e 00
                hex ff df 8f b2 56 78 fe fc f8 00 ff 99 cc e6 73 39
                hex 9c ce e7 ff 4c 99 33 67 ce 9c 39 73 80 d1 b2 95
                hex 80 45 7f 8f a7 93 c9 e4 f2 f9 6f 18 5a 4a 62 52
                hex 4a 63 82 aa ba aa 58 63 f7 55 35 55 70 38 6c 54
                hex 73 79 4d 55 4d 55 73 f3 56 55 35 55 58 7f 8e db
                hex 55 5d 4d 5b 57 78 70 50 70 00 7f 01 03 07 0f 1f
                hex 3f 7f ff df 6f b7 db 6d 36 9b cd b3 7d ff 02 04
                hex 09 12 24 49 93 26 39 00 ff 00 ff e0 e7 cf ff e7
                hex 00 ff 00 ff 00 ff 01 6e 80 6e a4 ff 33 e7 ce 1c
                hex f9 f3 e7 0f f0 9f 3f 7f ff 03 80 40 01 01 b3 f5
                hex 39 00 ff 00 ff e0 4c 99 ff e7 00 ff 00 ff 00 ff
                hex 01 05 80 05 ff 09 12 24 49 93 26 4c 99 b2 76 ff
                hex 33 67 ce 9c 39 73 e7 cf 80 d1 87 3f 7f bf 3f 87
                hex 00 01 02 04 86 40 41 42 4d a0 f7 ef a0 0b 17 80
                hex ef 80 17 87 ef ee ed eb 80 17 e0 ed ee ef 80 17
                hex 12 fe 9c ff 01 fe ff 06 01 00 8e fe 7e be de 02
                hex 7f 1c 30 3c 3f c0 1f 3f 87 05 3b c7 df 12 ad 80
                hex ff 87 d0 ee f1 fc 01 80 c0 fc fe 81 00 0f 42 f7
                hex 80 05 81 02 fa 80 d0 81 20 2f 01 f8 03 03 06 01
                hex 01 4d 80 02 f8 0d 3d 7d 6d 4d 80 02 80 4d 80 02
                hex 87 4d 6d 7d 3d b8 02 03 01 00 e0 0d 01 00 09 57
                hex fe 82 c6 7c 38 28 66 00 51 fe 92 82 53 fe 22 3e
                hex 1c 08 83 0c 3f 00 fb 3c 06 03 3f 63 3e 00 1f 25
                hex 26 74 24 00 d0 30 18 00 09 3a 80 84 fe 80 73 6c
                hex fe 92 fe 6c 7f 40 c2 92 9a 9e f6 62 7b 38 7c c6
                hex 82 c6 44 09 7b 78 fc 96 92 f2 60 5f fe 30 78 ec
                hex c6 82 7e 38 7c c6 82 92 f2 3c 80 ec 6c 00 09 52
                hex fe 10 fe 51 fe 12 02 5e fe 1c 38 70 fe 78 08 0e
                hex 06 00 09 73 7e fe 80 fe 7e 28 fe 80 7f c2 e2 f2
                hex ba 9e 8e 86 5e fe 70 38 70 fe 02 80 99 0c 1e 33
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00

pt_pinball      ; BG PT data for Pinball
                hex 03 2a 53 fe 22 3e 1c 54 82 fe 82 5e fe 1c 38 70
                hex fe 83 ab 53 fe 92 fe 6c 7f f8 fc 26 22 26 fc f8
                hex 28 fe 80 07 08 1c 3c 3a c0 f0 f8 fc 03 fd 90 80
                hex 40 80 fc 80 40 80 fc 83 40 80 00 80 fc 97 fc f8
                hex f0 c0 00 82 7f 80 3f da 47 43 41 40 20 d0 fc fe
                hex ff a6 aa ff 3f 00 0c c0 ff e2 af df ff 00 04 ff
                hex 8c e2 aa 98 ff 00 04 ff 86 80 ff 00 dc 7c 7e 40
                hex 7f ff 06 ff 00 f8 e3 82 83 fe ff 06 ff 00 f8 c5
                hex 3d c5 3d ff 9d 80 04 2c 0f ff 3f 80 04 b0 3f ff
                hex ef 80 04 b1 0f ff ef ff 80 04 b9 0f ff 0f 9f af
                hex 9d 80 04 fa af df ff bf 9f 1f 80 04 41 3f ff 80
                hex 04 e5 9f cf 2f 0f ff 81 04 84 01 7f 13 eb 80 fb
                hex e0 3f 7f ff 81 fb f7 fb f7 ef 9f 7f ff fc 03 c0
                hex fc 00 01 00 3c 80 bb 08 fc c7 fc ff ad aa 8a c8
                hex fc ff 00 c7 f9 ff df af b8 c8 f9 ff 00 05 ba 9a
                hex 08 00 62 ea c3 fe ff e3 f9 08 80 c3 57 ff 9e c3
                hex 03 06 ff 03 1f 8f 68 03 e0 ff 03 20 3e 03 60 2f
                hex 03 60 fc 62 b5 03 7f ff 03 83 f9 c0 01 00 bf ff
                hex 7f 3f 1f 0f 07 03 9f ff fe fc f8 f0 e0 32 6e e0
                hex 3f 7f ff 80 ee 80 80 80 fe 80 bb 48 80 fc cf 01
                hex ff 03 07 c7 f9 ff 81 e0 f8 fc ef cf 87 8f e9 e6
                hex e2 72 20 7e 68 fd 67 47 4f 4c 04 07 7f 14 00 ff
                hex f0 98 88 89 c9 bc 3f 1f 9f bf ff 33 15 01 7f 8f
                hex 00 80 c0 60 30 fc 18 30 60 c0 80 00 0c 80 ee e0
                hex 3f 7f ff 80 bb 88 fc ff f1 4a 7a 02 ff fe 09 ff
                hex fe f1 ad a9 20 ff 01 09 ff 01 8c f8 52 5c 41 ff
                hex 00 0b ff 9f 87 f8 a5 99 c3 ff 00 0b ff fe e6 b8
                hex 5e 1e ff 00 0b ff 7f 67 b8 bf 3f ff 00 08 ff 72
                hex d5 03 b9 98 08 00 08 00 78 fe fc f8 00 ff 99 cc
                hex e6 73 39 9c ce e7 22 7e ff b3 66 cc 98 31 63 c6
                hex 8c 80 ee 80 1f 80 bb 80 fc 63 1e 5e 42 7a 28 72
                hex 20 a9 ab ad 73 41 5c 52 5c 52 63 81 a5 bd a5 78
                hex 02 7a 42 5e 22 85 78 07 f7 87 bf 7f 01 03 07 0f
                hex 1f 3f 7f ff df 6f b7 db 6d 36 9b cd 33 7d ff fd
                hex fb f6 ed db b6 6c d9 19 00 ff 00 f0 18 30 60 ff
                hex 66 00 ff 00 ff 02 91 80 91 34 ff cc 18 31 e3 06
                hex 0c 18 f0 f0 60 c0 80 00 03 7f bf 01 fe 33 f5 19
                hex 00 ff 00 f0 b3 66 cc ff 66 00 ff 00 ff 02 fa 80
                hex fa ff f6 ed db b6 6c d9 b3 66 32 76 ff cc 98 31
                hex 63 c6 8c 18 30 80 ee 0f df bf 7f df 07 fe fd fb
                hex 86 bf be bd 13 af a0 f7 ef 80 ef 80 ef 07 fe fd
                hex fb 80 ef e0 fd fe ff 12 ae 9c ff 01 fe ff 8e fe
                hex 7e be de 1c 30 3c 3f c0 1f 3f 87 05 3b c7 df 12
                hex b7 87 d0 ee f1 fc 01 80 c0 fc fe 81 00 0f 80 05
                hex 81 07 ff 02 df 80 d0 81 f0 ff 01 f8 03 03 06 03
                hex 03 07 03 ff 00 78 3f 70 60 ff 03 fe 80 02 80 4f
                hex 80 02 87 4f 6f 7f 3f b8 02 03 01 00 d8 0f 03 01
                hex 00 57 fe 82 c6 7c 38 09 14 c0 00 73 7c fe 82 fe
                hex 7c 5f fe 22 62 f2 de 9c 28 66 00 09 51 fe 12 02
                hex 51 fe 92 82 73 7e fe 80 fe 7e 3b 0e 1e f0 1e 0e
                hex 08 ff 7f 70 3c 1e 07 63 3e 00 1f 53 55 63 41 00
                hex d0 30 18 00 c7 3f 0c 1c 0c 00 09 77 0c 9e 92 d2
                hex 7e 3c 73 6c fe 92 fe 6c 7d 30 38 2c 26 fe 20 77
                hex 4c de 92 96 f4 60 09 7b 38 7c c6 82 c6 44 7b 78
                hex fc 96 92 f2 60 5f fe 30 78 ec c6 82 7e 38 7c c6
                hex 82 92 f2 09 3c 80 ec 6c 00 52 fe 10 fe 2a 02 fe
                hex 02 2a 82 fe 82 09 7f c6 ee 7c 38 7c ee c6 5e fe
                hex 70 38 70 fe 5e fe 1c 38 1c fe 78 08 0e 06 00 02
                hex a0 f9 08 1c 3e 77 63 00 e7 1c 32 63 26 1c 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00

pt_popeye       ; BG PT data for Popeye
                hex 03 2a 53 fe 22 3e 1c 73 7c fe 82 fe 7c 51 fe 92
                hex 82 83 bf 3b 0e 1e f0 1e 0e 07 08 1c 3c 3a c0 f0
                hex f8 fc 90 7c bc 80 fc 80 bc 80 fc 12 de e0 02 fc
                hex 00 02 00 ae fe fc f8 e0 00 80 3f 80 3f da ba bd
                hex be bf df ac 1e 3f c0 3f 00 a0 aa ff 0e 00 ff 00
                hex e0 af df ff 0e 00 ff 00 e0 aa 99 ff 0e 00 ff 00
                hex b8 81 bf 80 ff 4d c3 fb 3b fb 5b 80 f4 a7 5b bb
                hex fb 1b fb 80 f4 ac fb 1b fb 7b 80 f4 b0 7b fb db
                hex 80 f4 4d b1 1b fb db fb 80 f4 b9 1b fb 1b 3b 5b
                hex 80 f4 f8 5b bb fb 7b 3b 80 f4 c1 fb 7b fb 80 f4
                hex 4d e5 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4 e0 3b
                hex 7b fb 80 f4 81 fb f7 81 f4 e8 a2 fd de d1 a1 41
                hex 81 01 02 d0 3f 7f ff 82 7e fe 80 fe 80 45 88 fe
                hex ff bf 0b 02 00 ff ad aa 8a a4 cf 0d 00 ff df af
                hex b8 cd 80 00 ff bb 99 df 38 10 00 80 9c 86 83 07
                hex 61 3c 1c a4 07 f9 00 3a 07 e0 70 37 07 1f 00 c0
                hex 07 df c1 c0 a4 06 9f d0 06 9f 03 07 80 00 7e c7
                hex 01 00 7c 06 3e 52 ab 3f 80 c0 e0 f0 f8 fc 1f 01
                hex 03 07 0f 1f e0 3f 7f ff 80 ee 80 d1 52 fa 80 80
                hex 80 7e 80 bb 80 45 bc 84 81 c1 e7 80 a0 e7 f2 a2
                hex 51 bc c0 80 81 83 80 8a 60 e0 70 c0 01 00 b2 5f
                hex f8 f3 f9 fc fe ff fc e7 cf 9f 3f 7f ff 80 d1 60
                hex bf 3f 80 45 08 fe 58 fb 5a 42 7e 00 ff e7 b4 fa
                hex b5 85 fd 00 ff e7 fa 6a 0a fb 00 ff 3f fa f5 15
                hex f7 00 ff 9f 58 f8 55 54 77 00 ff f8 e0 20 e0 00
                hex ff 08 ff 78 01 03 07 ff b2 5a ff 99 cc e6 73 39
                hex 9c ce e7 ff 4c 99 33 67 ce 9c 39 73 80 d1 80 45
                hex 58 63 70 50 5e 42 70 fd 85 b5 63 c3 42 7a 0a 7f
                hex f1 11 f1 81 83 f6 15 53 a2 ff 43 7d 06 03 00 7f
                hex 40 5e b0 52 73 00 7f 01 03 07 0f 1f 3f 7f b2 5f
                hex ff 20 90 48 24 92 c9 64 32 ff 02 04 09 12 24 49
                hex 93 26 80 d1 3c bf 3f 7f ff 80 45 d9 fe ff fe ff
                hex fe 59 80 91 bf 91 31 63 c6 8c 18 30 f0 60 c0 80
                hex 00 e0 fd fe ff a3 7d 01 01 39 00 ff 00 ff e0 4c
                hex 99 ff e7 00 ff 00 ff 00 ff 81 ff 05 80 05 a2 5d
                hex ff 09 12 24 49 93 26 4c 99 ff 33 67 ce 9c 39 73
                hex e7 cf 80 d1 87 3f 7f bf 3f 07 01 02 04 93 bf 63
                hex ff 00 03 04 a0 0b 17 a0 fc f8 80 17 80 f8 80 17
                hex 87 f8 f9 fa fc 8d 80 17 e0 fa f9 f8 81 17 0b 81
                hex f8 fc f1 0b 04 03 00 ff c0 fc ff 3a 60 e0 f0 f8
                hex 30 7f ff 32 8b 87 05 3b c7 df 87 d0 ee f1 fc 81
                hex 00 80 c0 fc fe 02 7d 01 0f 80 05 81 07 ff 80 d0
                hex 81 f0 ff 01 f8 4d 07 01 03 02 01 01 80 02 f8 0d
                hex 3d 7d 6d 4d 80 02 80 4d 80 02 87 4d 6d 7d 3d 02
                hex ea 03 e0 30 0b 80 e0 f0 e7 7c 66 63 66 7c 00 a0
                hex 18 00 fb 67 6e 7c 67 63 7e 00 08 55 30 00 30 00
                hex d3 3e 63 03 0f 00 c1 3e 63 00 c1 3f 30 00 08 c7
                hex 3f 0c 1c 0c 00 ef 3e 63 03 7e 60 7e 00 1f 25 26
                hex 74 24 00 d0 30 18 00 09 77 0c 9e 92 d2 7e 3c 73
                hex 6c fe 92 fe 6c 7f 40 c2 92 9a 9e f6 62 77 4c de
                hex 92 96 f4 60 09 7b 38 7c c6 82 c6 44 7b 78 fc 96
                hex 92 f2 60 5f fe 30 78 ec c6 82 53 fe 92 fe 6c 09
                hex 7e 38 7c c6 82 92 f2 3c 80 ec 6c 00 52 fe 10 fe
                hex 7f f8 fc 26 22 26 fc f8 09 2a 02 fe 02 51 fe 12
                hex 02 5e fe 1c 38 70 fe 2a 82 fe 82 09 78 08 0e 06
                hex 00 5e fe 1c 38 1c fe 7f c4 e6 f2 b2 ba 9e 8c 5e
                hex fe 70 38 70 fe 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

pt_popeyeen     ; BG PT data for Popeye English
                hex 03 2a 53 fe 22 3e 1c 73 7c fe 82 fe 7c 51 fe 92
                hex 82 09 3b 0e 1e f0 1e 0e 5e fe 1c 38 70 fe 7e 38
                hex 7c c6 82 92 f2 28 fe 80 83 ab 2a 82 fe 82 77 4c
                hex de 92 96 f4 60 52 fe 10 fe 07 08 1c 3c 3a c0 f0
                hex f8 fc 03 fd 90 80 40 80 fc 80 40 80 fc 83 40 80
                hex 00 80 fc 97 fc f8 f0 c0 00 92 6f 80 3f da 45 42
                hex 41 40 20 9e ff 3f c0 3f 00 a0 aa ff 8e ff 00 ff
                hex 00 e0 af df ff 9d 80 f4 6f 3f bf ff 3f bf 3f 80
                hex f4 61 0f 2f ef 80 f4 c3 0f cf 0f af 80 f4 a7 af
                hex 4f 0f ef 0f 4d ac fb 1b fb 7b 80 f4 b0 7b fb db
                hex 80 f4 b1 1b fb db fb 80 f4 b9 1b fb 1b 3b 5b 80
                hex f4 4d f8 5b bb fb 7b 3b 80 f4 c1 fb 7b fb 80 f4
                hex e5 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4 9d 80 f4
                hex e0 cf 8f 0f 81 f4 e8 81 0f 1f fb e8 90 60 80 00
                hex 03 fc e0 1f 7f ff c1 03 ff 00 01 00 a2 d5 80 45
                hex 88 fe ff 0f ff ad aa 8a 0f ff df af b8 cf 07 00
                hex ff 8a ba 9a 58 cf 08 ff 7f 63 79 7c c7 0d ff 9e
                hex c3 e3 c7 02 ff 06 ff c5 c7 4f ff 1f 8f c8 a4 07
                hex 1f 00 c0 07 df c1 c0 06 9f d0 06 9f 03 58 87 ff
                hex 7f ff 81 c7 fe ff 83 f9 c1 3f 80 c0 e0 f0 f8 fc
                hex 1f 01 03 07 0f 1f 52 bf e0 3f 7f ff 80 ee 80 d1
                hex 80 80 80 7e 80 bb 80 45 a4 4a 7b 79 00 7e 89 bd
                hex 99 9c 8c 00 f4 07 ef a7 e7 07 ff f7 f0 f6 f2 f3
                hex c6 f7 f2 a2 54 ff d3 73 71 73 f7 70 e3 73 ff fd
                hex ed 9d fd ed 7c f8 fd fe b0 38 10 18 9c 1e fc b2
                hex 57 c0 01 00 f8 f3 f9 fc fe ff fc e7 cf 9f 3f 7f
                hex ff 80 d1 60 bf 3f b2 d5 80 45 08 fe f8 a1 bd 81
                hex ff 00 f8 6a 4a 03 ff 00 fb 95 65 0c ff 00 06 07
                hex 58 bb 85 87 00 ff 98 08 fb 5a 66 3c 00 ff 1d 0c
                hex ba b4 fc 00 ff 03 0a ff 1f 58 08 ff 78 01 03 07
                hex ff ff 66 33 19 8c c6 63 31 18 ff b3 66 cc 98 31
                hex 63 c6 8c b2 a5 80 d1 80 45 7b 81 bd a1 af a1 bd
                hex 72 03 4a 5a 6a 58 76 f3 9a 6a 4a 7a 78 f7 15 f5
                hex 85 7f 3c 66 5a 7a 3a 66 5e 63 fc b4 84 b4 52 2a
                hex 7f 01 03 07 0f 1f 3f 7f ff df 6f b7 db 6d 36 9b
                hex cd ff fd fb f6 ed db b6 6c d9 b3 f5 39 00 ff 00
                hex ff e0 e7 cf ff e7 00 ff 00 ff 00 ff 01 6e 80 6e
                hex bf 6e ce 9c 39 73 e7 cf a3 57 f0 9f 3f 7f ff e0
                hex 02 01 00 01 01 39 00 ff 00 ff e0 4c 99 ff a2 d5
                hex 80 45 87 fe ff fe ff 07 ff 00 ff ff 09 12 24 49
                hex 93 26 4c 99 ff 33 67 ce 9c 39 73 e7 cf b2 db 80
                hex d1 87 3f 7f bf 3f 87 00 01 02 04 86 40 41 42 9e
                hex 00 3f c0 3f ff 06 c0 00 4d 80 ef 80 17 87 ef ee
                hex ed eb 80 17 e0 ed ee ef 80 17 81 ef f7 81 17 0b
                hex 32 f8 8e fe 7e be de 02 7f 9c 00 30 3c 3f c0 1f
                hex 3f 87 05 3b c7 df 12 b7 87 d0 ee f1 fc 01 80 c0
                hex fc fe 81 00 0f 80 05 81 07 ff 02 df 80 d0 81 f0
                hex ff 01 f8 03 03 06 03 03 07 03 ff 00 78 3f 70 60
                hex ff 03 fe 80 02 80 4f 80 02 87 4f 6f 7f 3f b8 02
                hex 03 01 00 d8 0f 03 01 00 57 fe 82 c6 7c 38 09 14
                hex c0 00 5f fe 22 62 f2 de 9c 28 66 00 7f 1e 3e 70
                hex e0 70 3e 1e 09 5e fe 1c 38 1c fe 53 fe 92 fe 6c
                hex 7f c4 e6 f2 b2 ba 9e 8c 7f 1e 04 18 00 08 14 1e
                hex 09 3c 80 e0 60 00 3a 80 84 fe 80 77 0c 9e 92 d2
                hex 7e 3c 73 6c fe 92 fe 6c 09 7f 40 c2 92 9a 9e f6
                hex 62 7b 38 7c c6 82 c6 44 7b 78 fc 96 92 f2 60 5f
                hex fe 30 78 ec c6 82 09 3c 80 ec 6c 00 2a 02 fe 02
                hex 51 fe 12 02 73 7e fe 80 fe 7e 02 a8 b7 63 7f 63
                hex 36 1c 00 ed 63 77 7f 6b 63 00 0d 60 30 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00

pt_tennis       ; BG PT data for Tennis
                hex 03 2a 2a 02 fe 02 51 fe 92 82 5e fe 1c 38 70 fe
                hex 83 af 2a 82 fe 82 77 4c de 92 96 f4 60 07 08 1c
                hex 3c 3a c0 f0 f8 fc 90 7c bc 80 fc 03 f7 80 40 80
                hex fc 83 40 80 00 80 fc 97 fc f8 f0 c0 00 20 ff 20
                hex ff b2 bf da 45 42 41 40 20 1e 3f c0 3f 00 a0 aa
                hex ff 0e 00 ff 00 e0 af df ff 0e 00 ff 00 e0 db 88
                hex ff 9d 80 f4 61 0f 2f ef 80 f4 c3 0f cf 0f af 80
                hex f4 a7 af 4f 0f ef 0f 80 f4 ac 0f ef 0f 8f 4d b0
                hex 7b fb db 80 f4 b1 1b fb db fb 80 f4 b9 1b fb 1b
                hex 3b 5b 80 f4 f8 5b bb fb 7b 3b 80 f4 4d c1 fb 7b
                hex fb 80 f4 e5 3b 9b 5b 1b fb 80 f4 81 fb 7b 80 f4
                hex e0 3b 7b fb 80 f4 2c 0e fe 01 ff 18 01 ff de ee
                hex de be 7e fe fd d0 3f 7f ff 82 80 00 80 fe 88 bb
                hex ba 88 fe ff 58 af e0 ff 00 52 55 75 af 3f ff 00
                hex 20 50 47 cf f8 ff 00 27 24 26 cf 07 ff 7f 63 79
                hex 7c a4 a7 01 00 61 3c 1c a7 fc 00 f9 00 3a 07 e0
                hex 70 37 07 1f 00 c0 a4 07 df c1 c0 06 9f d0 06 9f
                hex 03 07 80 00 7e 58 c7 fe ff 83 f9 c1 3f 80 c0 e0
                hex f0 f8 fc 1f 01 03 07 0f 1f e0 3f 7f ff 52 fe 80
                hex ee 80 d1 80 80 80 7e 80 bb 80 45 ca f1 f8 80 ff
                hex a5 90 0c 00 0c c0 c1 86 c1 c0 00 01 81 a2 45 fd
                hex ef fe 7c 38 18 0c fc c0 01 00 f8 f3 f9 fc fe ff
                hex b2 7d fc e7 cf 9f 3f 7f ff 80 d1 60 bf 3f 80 45
                hex 08 fe fb 88 be 80 ff 00 18 1c 58 f8 5e 42 7e 00
                hex ff f8 95 b5 fd 00 ff f8 2a 6a fb 00 ff fa ad b3
                hex 9e 00 ff fc 58 0a ff 7c 0a ff 7f 08 ff 78 01 03
                hex 07 ff b2 5a ff 99 cc e6 73 39 9c ce e7 ff 4c 99
                hex 33 67 ce 9c 39 73 80 d1 80 45 58 60 1c 14 7b 7e
                hex 42 5e 50 5e 42 72 fd b5 a5 95 72 fb 6a 4a 2a 52
                hex 8a 7f 9e b3 ad bd 9d b3 af 7f 01 03 07 0f 1f 3f
                hex 7f ff df 6f b7 db 6d 36 9b cd b3 7d ff 02 04 09
                hex 12 24 49 93 26 39 00 ff 00 ff e0 e7 cf ff e7 00
                hex ff 00 ff 00 ff 01 6e 80 6e a4 ff 33 e7 ce 1c f9
                hex f3 e7 0f f0 9f 3f 7f ff 03 80 40 01 01 b3 f5 39
                hex 00 ff 00 ff e0 4c 99 ff e7 00 ff 00 ff 00 ff 01
                hex 05 80 05 ff 09 12 24 49 93 26 4c 99 b2 76 ff 33
                hex 67 ce 9c 39 73 e7 cf 80 d1 87 3f 7f bf 3f 87 00
                hex 01 02 04 86 40 41 42 4d a0 f7 ef a0 0b 17 80 ef
                hex 80 17 87 ef ee ed eb 80 17 e0 ed ee ef 80 17 12
                hex fe 9c ff 01 fe ff 06 01 00 8e fe 7e be de 02 7f
                hex 1c 30 3c 3f c0 1f 3f 87 05 3b c7 df 12 ad 80 ff
                hex 87 d0 ee f1 fc 01 80 c0 fc fe 81 00 0f 42 f7 80
                hex 05 81 02 fa 80 d0 81 20 2f 01 f8 03 03 06 01 01
                hex 4d 80 02 f8 0d 3d 7d 6d 4d 80 02 80 4d 80 02 87
                hex 4d 6d 7d 3d b8 02 03 01 00 e0 0d 01 00 09 57 fe
                hex 82 c6 7c 38 14 c0 00 73 7c fe 82 fe 7c 5f fe 22
                hex 62 f2 de 9c 08 55 30 00 30 00 d3 3e 63 03 0f 00
                hex b7 63 7f 63 36 1c 00 c1 3e 63 00 08 99 0c 1e 33
                hex 00 c7 3f 0c 1c 0c 00 bf 06 7f 66 36 1e 0e 00 1f
                hex 25 26 74 24 00 09 3c 80 e0 60 00 77 0c 9e 92 d2
                hex 7e 3c 73 6c fe 92 fe 6c 53 fe 22 3e 1c 09 7b 38
                hex 7c c6 82 c6 44 7b 78 fc 96 92 f2 60 5f fe 30 78
                hex ec c6 82 53 fe 92 fe 6c 09 7e 38 7c c6 82 92 f2
                hex 3c 80 ec 6c 00 52 fe 10 fe 5e fe 1c 38 1c fe 09
                hex 28 fe 80 51 fe 12 02 5e fe 70 38 70 fe 78 08 0e
                hex 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00

                pad $c000, $00          ; $bf67

; --- Bank 3 ------------------------------------------------------------------

                base $c000

udat6           ; unaccessed chunk
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

                ; $c280: partially unaccessed; read indirectly using read_ptr2
                ; ($c280-$c292 read in init only)
                hex 01 93 c2 8f c2 14 c3 bf c3 3f c4 2a c5 3d c5 33
                hex 01 00 01 db c2 d7 c2 fd c2 f8 c2 00 c3 d7 c2 fd
                hex c2 f8 c2 00 04 4d 40 00 00 00 40 02 07 4d 40 00
                hex 00 00 40 00 00 00 40 02 07 4e 40 00 00 00 40 04
                hex 16 4e 40 00 00 00 40 00 00 00 40 02 07 4f 40 00
                hex 00 00 40 04 16 4f 40 c0 7f 00 00 00 c1 c4 c8 cd
                hex ce cf cf ce cd cd cc cb ca ca c9 c8 c7 c7 c6 c5
                hex c4 c4 c3 c2 c2 c1 00 1a 00 c0 7f 00 01 7f 00 00
                hex 00

                ; $c301: read indirectly using read_ptr2
                hex c0 02 cf 00 03 00 c0 be bd bd be bf c1 c2 c3 c3
                hex c2 00 01 fb 12 78 69 01 80 11 81 15 81 21 81 22
                hex 81 11 81 1d 81 11 81 1f 81 1d 81 11 81 18 81 15
                hex 81 11 81 16 81 15 81 11 81 ff 1c 1a c3 11 81 15
                hex 81 69 01 ff 20 1a c3 ff 1c 1a c3 11 81 15 81 69
                hex 01 ff 20 1a c3 ff 1c 1a c3 11 81 15 81 69 01 ff
                hex 20 1a c3 ff 1c 1a c3 11 81 15 81 69 01 11 81 16
                hex 81 19 81 20 81 0c 81 11 81 15 81 1d 81 0f 81 13
                hex 81 16 81 22 81 0a 81 0f 81 11 81 16 81 ff 20 6e
                hex c3 69 01 ff 20 1a c3 ff 1c 1a c3 11 81 15 81 69
                hex 01 ff 20 1a c3 ff 1c 1a c3 11 81 15 81 69 01 ff
                hex 20 1a c3 ff 1c 1a c3 11 81 15 81 fd 16 c3 81 74
                hex 68 fd 69 03 ff 20 19 c3 ff 1c 1a c3 11 81 15 81
                hex 68 fd 69 03 ff 20 1a c3 ff 1c 1a c3 11 81 15 81
                hex 68 fd 69 03 ff 20 1a c3 ff 1c 1a c3 11 81 15 81
                hex 68 fd 69 03 ff 20 1a c3 ff 1c 1a c3 11 81 15 81
                hex 68 fd 69 03 ff 20 6e c3 ff 20 6e c3 68 fd 69 03
                hex ff 20 1a c3 ff 1c 1a c3 11 81 15 81 68 fd 69 03
                hex ff 20 1a c3 ff 1c 1a c3 11 81 15 81 68 fd 69 03
                hex ff 20 1a c3 ff 1c 1a c3 11 81 15 fd bf c3 70 f7
                hex 87 f7 87 7f 63 f8 c2 64 82 35 81 63 06 c3 8b 63
                hex f8 c2 64 37 81 63 06 c3 8b 63 f8 c2 64 3f 81 63
                hex 06 c3 87 63 f8 c2 64 3e 3d 3c 81 63 06 c3 8b 63
                hex f8 c2 64 41 81 63 06 c3 8b 63 f8 c2 64 3c 81 63
                hex 06 c3 87 63 f8 c2 64 3d 3e 3f 81 63 06 c3 8b 63
                hex f8 c2 64 41 81 63 06 c3 8b 63 f8 c2 64 ff 1c 4a
                hex c4 63 f8 c2 64 41 81 63 06 c3 87 63 f8 c2 64 3c
                hex 81 63 f8 c2 64 3c 81 63 06 c3 85 3b 81 63 f8 c2
                hex 64 3a 63 f8 c2 64 3a 81 63 06 c3 87 63 f8 c2 64
                hex 35 81 63 06 c3 37 81 63 f8 c2 64 38 81 63 06 c3
                hex 37 81 63 f8 c2 64 3c 81 ff 16 a2 c4 63 f8 c2 64
                hex 33 81 63 f8 c2 64 ff 1c 4a c4 29 24 29 24 29 24
                hex 29 24 29 24 29 24 29 24 29 24 29 22 29 22 29 22
                hex 29 22 29 1f 29 1f 29 1f 29 1f ff 20 fb c4 ff 20
                hex fb c4 ff 20 fb c4 fd 3f c4 f7 87 f7 87 f7 87 f7
                hex 87 f7 87 f7 87 f7 87 f7 87 fd 2a c5 6a 02 05 8d
                hex 6a 02 0c 8d 6a 02 0a 8d 6a 02 07 8d 6a 02 11 8d
                hex 6a 02 0c 8d 6a 02 0a 8d 6a 02 07 8d ff 10 3d c5
                hex ff 10 3d c5 ff 10 3d c5 6a 02 05 8d 6a 02 0c 8d
                hex 6a 02 0f 8d 6a 02 0a 8d 6a 02 11 8d 6a 02 0c 8d
                hex 6a 02 0f 8d 6a 02 0a 8d ff 10 3d c5 ff 10 3d c5
                hex ff 10 3d c5 fd 3d c5

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
                jsr sub7
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
                lda #$00
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
                ldx #$80
                ldy #$c2
                lda ptr1+0
                jsr sub1
                ;
                copy #$01, do_nmi
                lda #$00
                sta ram9
                sta ram3
                sta game_screen
                sta ram1
                sta ram2
                jsr sub3
                jsr sub16
                ;
                copy #$20,    ptr1+0       ; copy 768 bytes from nt_dk to NT0
                copy #$00,    ptr1+1
                copy #<nt_dk, read_ptr1+0
                copy #>nt_dk, read_ptr1+1
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
                jsr decomp_pt_data1
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

nt_title        ; NT & AT data for title screen
                hex 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52
                hex 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52
                hex 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57
                hex 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57
                hex 57 57 57 57 57 56 a9 a9 a9 a9 a9 a9 a9 a9 a9 a9
                hex a9 a9 a9 a9 a9 a9 a9 a9 a9 a9 53 57 57 57 57 57
                hex 55 55 55 55 55 54 b7 b7 b7 b7 b7 b7 b7 b7 b7 b7
                hex b7 b7 b7 b7 b7 b7 b7 b7 b7 b7 6d 55 55 55 55 55
                hex 46 46 46 46 46 54 b7 b7 b7 b6 74 99 98 b7 b6 74
                hex 99 98 b7 b6 74 99 98 b7 b7 b7 6d 46 46 46 46 46
                hex 6a 6a 6a 6a 6a 54 b7 b7 aa b4 b7 b7 97 b5 b4 b7
                hex b7 97 b5 b4 b7 b7 97 96 b7 b7 6d 6a 6a 6a 6a 6a
                hex 6a 6a 6a 6a 6a 54 b7 b7 91 b7 ac ab b7 95 b7 92
                hex 8c b7 95 b7 ae ad b7 8e b7 b7 6d 6a 6a 6a 6a 6a
                hex 69 69 69 69 69 54 b7 b7 90 93 b7 b7 8f 94 93 b7
                hex b7 8f 94 93 b7 b7 8f 8d b7 b7 6d 69 69 69 69 69
                hex 6c 6c 6c 6c 6c 54 b7 b7 b7 51 50 72 71 b7 51 50
                hex 72 71 b7 51 50 72 71 b7 b7 b7 6d 6c 6c 6c 6c 6c
                hex 6b 6b 6b 6b 6b 54 b7 b7 b7 b7 b7 b7 b7 b7 b7 b7
                hex b7 b7 b7 b7 b7 b7 b7 b7 b7 b7 6d 6b 6b 6b 6b 6b
                hex 6b 6b 6b 6b 6b 48 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a
                hex 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 4c 6b 6b 6b 6b 6b
                hex 4a 4a 4a 4a 4a 47 1e 1d 79 78 7b 7a 7d 7c 7f 7e
                hex 81 80 83 82 85 84 87 86 1f 1e 4b 4a 4a 4a 4a 4a
                hex 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a
                hex 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a 4a
                hex 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49
                hex 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49
                hex cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf
                hex cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf
                hex cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf
                hex cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf cf
                hex d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1
                hex d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1 d1
                hex d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0
                hex d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0 d0
                hex 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
                hex 17 17 17 17 17 17 17 14 18 17 17 17 17 17 17 17
                hex 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12
                hex 12 12 12 12 12 12 13 19 16 15 12 12 12 12 12 12
                hex 31 31 31 31 31 31 31 31 31 31 31 31 31 31 31 31
                hex 31 31 31 31 31 21 19 22 00 16 32 31 31 31 31 31
                hex 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f 2f
                hex 2f 2f 2e 2d 20 23 22 25 01 00 30 2f 2f 2f 2f 2f
                hex 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a 8a
                hex 8a 8a d5 d4 23 22 25 24 02 01 8b 8a 8a 8a 8a 8a
                hex 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88
                hex 88 88 d3 d2 22 25 24 cd cd 02 89 88 88 88 88 88
                hex cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd
                hex cd cd c6 c5 25 24 cd cd cd cd cd cd cd cd cd cd
                ; "  ART BY RETRONIKA ??           "
                ; "  CODE BY KASUMI                "
                ; "  MUSIC BY PERSUNE  NESDEV2022  "
                hex cd cd cb c4 c3 cd 9a bd cd c4 cc c3 c4 ce be bf
                hex ba cb cd c6 24 cd cd cd cd cd cd cd cd cd cd cd
                hex cd cd a4 ce bb cc cd 9a bd cd ba cb c0 4d a8 bf
                hex cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd
                hex cd cd a8 4d c0 bf a4 cd 9a bd cd b9 cc c4 c0 4d
                hex be cc cd cd be cc c0 bb cc c7 4f 4e 4f 4f cd cd
                pad nt_title+30*32, $cd
                ;
                pad nt_title+30*32+6*8, $00
                hex 00 00 00 00 00 50 10 00
                pad nt_title+30*32+8*8, $00

nt_dk           ; NT & AT data for Donkey Kong
                pad nt_dk+2*32, $cd
                hex cd cd cd cd cd cd cd cd cd cd bb ce be ba cc bd
                hex cd ba ce be 9f cd cd cd cd cd cd cd cd cd cd cd
                pad nt_dk+4*32, $cd
                hex cd cd cd cd cd cd 3d 3c 68 68 68 68 68 68 68 68
                hex 68 68 68 68 68 68 68 68 d9 d8 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 3b 59 58 5b 5a 5d 5c 5f 5e
                hex 61 60 63 62 65 64 67 66 d7 d6 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 3e dd dc e1 e0 e5 e4 e9 e8
                hex b0 af 27 26 28 2b 04 03 3a 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 44 db da df de e3 e2 e7 e6
                hex b7 b7 b7 2c 2b 2a 05 04 33 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 40 ed ec f1 f0 f5 f4 b3 b2
                hex 0f b7 2c 2b 2a 29 06 05 35 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 3f eb ea ef ee f3 f2 b1 b7
                hex 0e 0d 2b 2a 29 77 10 06 34 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 42 f7 f7 f7 f7 f7 f7 f7 f7
                hex 09 08 2a 29 77 76 11 10 37 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 41 f6 f6 f6 f6 f6 f6 f6 f6
                hex 0b 07 29 77 76 b7 b7 11 36 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 44 b7 b7 b7 b7 b7 b7 b7 b7
                hex 0c 0b 77 76 b7 b7 b7 b7 3a 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd 45 43 9b 9d 9d 9d 9d 9d 9d 9d
                hex 9d 0a 75 9d 9d 9d 9d 9c 38 39 cd cd cd cd cd cd
                hex cd cd cd cd cd cd fb fa b7 b7 b7 b7 b7 b7 b7 b7
                hex b7 b7 b7 b7 b7 b7 b7 b7 ff fe cd cd cd cd cd cd
                hex cd cd cd cd cd cd f9 f8 b7 b7 b7 b7 b7 b7 b7 b7
                hex b7 b7 b7 b7 b7 b7 b7 b7 fd fc cd cd cd cd cd cd
                hex cd cd cd cd cd cd cd c8 6e 70 70 70 70 70 70 70
                hex 70 70 70 70 70 70 70 6f c9 cd cd cd cd cd cd cd
                pad nt_dk+18*32, $cd
                hex cd cd cd bb c2 ce c2 c4 c2 c1 cd a2 4d a0 bd cd
                hex a5 9e 1b 1c a5 73 a6 a3 cd cd cd cd cd cd cd cd
                hex cd cd cd c0 b9 cc a4 c0 c1 cd a5 a1 ba 9a cd b9
                hex c4 9f cd 1a cd cd a6 ba 9a cd a4 bc c4 cd cd cd
                pad nt_dk+21*32, $cd
                hex cd cd cd cb cd b9 ce c4 c3 cd ce a7 cd be bf be
                hex c3 cc be bb ce ca c0 cd bc bf c3 cd cd cd cd cd
                hex cd cd cd cb c4 a4 cb bb cc cd 9f cb a8 cc cd a7
                hex c4 ce a8 cd a5 73 a6 a5 c2 cd cd cd cd cd cd cd
                hex cd cd cd c3 bc cc cd c3 c4 cb be c0 bf c3 bf ce
                hex be cd a7 c4 ce a8 cd a4 cb 9a cd cd cd cd cd cd
                hex cd cd cd c3 ce cd a4 ce be c0 ce a0 cc cd b8 cb
                hex c0 cd a0 cb c4 9f cc a0 bd cd cd cd cd cd cd cd
                hex cd cd cd c0 cc cb a8 a0 cc c0 c0 1c cd a8 cb ba
                hex bf be 9f cd bf c3 cd c3 bc cc cd cd cd cd cd cd
                hex cd cd cd 9a cc c0 c3 cd cb c4 a4 cb bb cc cd b9
                hex ce c4 c3 cd cb c3 cd c3 bc cc cd cd cd cd cd cd
                hex cd cd cd c3 bf a8 cc c2 cd cd cd cd cd cd cd cd
                hex cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd cd
                pad nt_dk+30*32, $cd
                ;
                pad nt_dk+30*32+2*8, $00
                hex 00 00 00 08 00 00 00 00
                hex 00 00 50 50 50 50 00 00
                pad nt_dk+30*32+8*8, $00

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
                lda #$00
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
                lda #$00
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
                lda #$00
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

; -----------------------------------------------------------------------------

decomp_pt_data2 ; in: X = $40, pt_data_ptr
                ; out: X = usually $80
                ; decrements deco_dat_left
                ; called by: decomp_pt_data1
                ;
                ldy #0
                txa
                add #$40
                bcs +                   ; never taken
                sta pt_out_len_trg
                lda (pt_data_ptr),y
                iny
                sta xor_mask
                cmp #$2a
                beq cod20               ; never taken
                cmp #$c0
                bcc ++                  ; always taken
+               rts                     ; unaccessed ($d5e4)
                ;
-               ror a
                lda (pt_data_ptr),y
                iny
                bne +++                 ; always taken
cod20           lda (pt_data_ptr),y     ; unaccessed ($d5eb)
                iny                     ; unaccessed
                sta stack,x             ; unaccessed
                inx                     ; unaccessed
                cpy #$41                ; unaccessed
                bcc cod20               ; unaccessed
                bcs exit_sub            ; unaccessed
                ;
++              stx pt_dat_out_len      ; $d5f8
                and #%11011111
                sta bitop_var1
                lsr a
                ror bitop_var3
                lsr a
                bcs -
                ;
                and #%00000011
                tax
                lda bit_patterns,x
                ;
+++             ror bitop_var3
                sta bitop_var2
                sty index_var
                clc
                lda pt_dat_out_len
                ;
cod21           adc #8
                sta pt_dat_out_len
                ;
                lda bitop_var1
                eor xor_mask
                sta bitop_var1
                and #%00110000
                beq +
                lda #$ff
+               asl bitop_var2
                bcc ++++
                ldy index_var
                bit bitop_var3
                bpl +
                ldy #2                  ; unaccessed ($d62d)
+               tax
                lda (pt_data_ptr),y
                iny
                sta index_var
                txa
                bvs +++++
                ldx pt_dat_out_len
                rol index_var
                ;
-               bcc +
                lda (pt_data_ptr),y
                iny
+               dex
                sta stack,x
                asl index_var
                bne -
                ;
                sty index_var
cod22           bit bitop_var1
                bpl +
                ;
                ldy #8
-               dex
                lda stack,x
                eor stack+8,x
                sta stack,x
                dey
                bne -
+               bvc +
                ;
                ldy #8
-               dex
                lda stack,x
                eor stack+8,x
                sta stack+8,x
                dey
                bne -
                ;
+               lda pt_dat_out_len
                cmp pt_out_len_trg
                bcc cod21
                ldy index_var
exit_sub        clc
                tya
                adc pt_data_ptr+0
                sta pt_data_ptr+0
                bcc +
                inc pt_data_ptr+1
+               ldx pt_out_len_trg
                dec deco_dat_left
                rts

++++            ldx pt_dat_out_len
                ldy #8
-               dex
                sta stack,x
                dey
                bne -
                beq cod22

+++++           ldx #8
-               asl index_var
                bcc +
                lda (pt_data_ptr),y
                iny
+               dex
                sta some_array,x
                bne -
                sty index_var
                ;
                ldy #8
                ldx pt_dat_out_len
-               asl some_array+0
                ror a
                asl some_array+1
                ror a
                asl some_array+2
                ror a
                asl some_array+3
                ror a
                asl some_array+4
                ror a
                asl some_array+5
                ror a
                asl some_array+6
                ror a
                asl some_array+7
                ror a
                dex
                sta stack,x
                dey
                bne -
                ;
                beq cod22               ; unconditional

bit_patterns    db %00000000
                db %01010101
                db %10101010
                db %11111111

decomp_pt_data1 ; decompress pattern table data
                ; in: Y/A = address low/high of compressed PT data,
                ; X = how much to decompress (64 = 256 tiles)
                ; called by: sub16
                ;
                sty pt_data_ptr+0
                sta pt_data_ptr+1
                stx deco_dat_left
                ;
--              ldx #$40
                jsr decomp_pt_data2
                cpx #$80
                bne +
                ;
                ldx #$40                ; copy 64 bytes (index $40-$7f) to PPU
-               lda stack,x
                sta ppu_data
                inx
                bpl -
                ;
                ldx deco_dat_left
                bne --
                ;
+               rts

; -----------------------------------------------------------------------------

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
