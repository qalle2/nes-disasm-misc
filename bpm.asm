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
fs_dat_ptr      equ $a2  ; 2 bytes; bank 2; Famistudio data pointer
ptr2            equ $a4  ; 2 bytes; bank 2
prg_bank        equ $a6  ; current PRG bank at CPU $8000-$bfff (0-3)
do_nmi          equ $a7  ; 0 = no, 1 = yes
bg_pal_copy     equ $a8  ; 16 bytes; copy of BG palettes
dnt_plane_buf   equ $b8  ; 8 bytes; Donut plane buffer
dnt_pb8_ctrl    equ $c0  ; Donut pb8 control
dnt_even_odd    equ $c1  ; Donut even_odd
dnt_blk_offs    equ $c2  ; Donut block offset
dnt_plane_def   equ $c3  ; Donut plane_def
dnt_blk_ofs_end equ $c4  ; Donut block offset end
dnt_blk_hdr     equ $c5  ; Donut block header
dnt_is_rotated  equ $c6  ; Donut - is rotated
dnt_stream_ptr  equ $c7  ; 2 bytes; Donut stream pointer
dnt_blk_cnt     equ $c9  ; Donut block count
useless1        equ $f0  ; in sub16
temp            equ $f1  ; in sub16
useless2        equ $ff  ; in init

dnt_blk_buf     equ $0100  ; used by bank 3; 64 bytes; Donut block buffer

; $02xx used by bank 2
fs_env_value    equ $0200  ; famistudio_env_value
fs_env_repeat   equ $020b  ; famistudio_env_repeat
fs_env_addr_lo  equ $0216  ; famistudio_env_addr_lo
fs_env_addr_hi  equ $0221  ; famistudio_env_addr_hi
arr13           equ $022b
fs_env_ptr      equ $022c  ; famistudio_env_ptr
fs_pit_env_va_l equ $0237  ; famistudio_pitch_env_value_lo
fs_pit_env_va_h equ $023a  ; famistudio_pitch_env_value_hi
fs_pit_env_rep  equ $023d  ; famistudio_pitch_env_repeat
fs_pit_env_ad_l equ $0240  ; famistudio_pitch_env_addr_lo
fs_pit_env_ad_h equ $0243  ; famistudio_pitch_env_addr_hi
fs_pit_env_ptr  equ $0246  ; famistudio_pitch_env_ptr
fs_pit_env_fiva equ $0249  ; famistudio_pitch_env_fine_value
arr22           equ $024c
arr23           equ $0250
arr24           equ $0254
arr25           equ $0258
arr26           equ $025d
fs_chn_note     equ $0262  ; famistudio_chn_note
fs_chn_instru   equ $0267  ; famistudio_chn_instrument
fs_song_spd     equ $026b  ; famistudio_song_speed
fs_chn_repeat   equ $026c  ; famistudio_chn_repeat
arr30           equ $0271
arr31           equ $0276
fs_chn_ref_len  equ $027b  ; famistudio_chn_ref_len
arr33           equ $0280
arr34           equ $0285
arr35           equ $028a
arr36           equ $028f
arr37           equ $0294
fs_tem_adv_row  equ $029b  ; famistudio_tempo_advance_row
fs_pal_adj      equ $029c  ; famistudio_pal_adjust
fs_songlist_lo  equ $029d  ; famistudio_song_list_lo
fs_songlist_hi  equ $029e  ; famistudio_song_list_hi
fs_instru_lo    equ $029f  ; famistudio_instrument_lo
fs_instru_hi    equ $02a0  ; famistudio_instrument_hi
fs_dpcm_lo      equ $02a1  ; famistudio_dpcm_list_lo
fs_dpcm_hi      equ $02a2  ; famistudio_dpcm_list_hi
fs_dpcm_effect  equ $02a3  ; famistudio_dpcm_effect
fs_pulse1_prev  equ $02a4  ; famistudio_pulse1_prev
fs_pulse2_prev  equ $02a5  ; famistudio_pulse2_prev
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

; PT data in included files
pt_devil        equ pt_data1+0          ; 1012 bytes
pt_title_dk     equ pt_data2+0
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
pt_tennis       equ pt_data2+$2f68      ; 909 bytes

; NT & AT data in included files
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
nt_title        equ nt_at_data2+ 0*$400  ; title screen
nt_dk           equ nt_at_data2+ 1*$400  ; Donkey Kong

FS_CHN_CNT      equ  5  ; FAMISTUDIO_NUM_CHANNELS
FS_DUTY_CYC_CNT equ  3  ; FAMISTUDIO_NUM_DUTY_CYCLES
FS_SLIDE_CNT    equ  4  ; FAMISTUDIO_NUM_SLIDES
FS_ENV_CNT      equ 11  ; FAMISTUDIO_NUM_ENVELOPES
FS_PIT_ENV_CNT  equ  3  ; FAMISTUDIO_NUM_PITCH_ENVELOPES

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

fs_init         ; "famistudio_init";
                ; download "NES Sound Engine" from https://famistudio.org
                ; and see "famistudio_asm6.asm";
                ; called by: init
                ;
                stx fs_songlist_lo
                sty fs_songlist_hi
                stx fs_dat_ptr+0
                sty fs_dat_ptr+1
                tax
                beq +
                lda #97
+               sta fs_pal_adj
                jsr fs_stop
                ;
                ldy #1
                lda (fs_dat_ptr),y
                sta fs_instru_lo
                iny
                lda (fs_dat_ptr),y
                sta fs_instru_hi
                iny
                lda (fs_dat_ptr),y
                sta fs_dpcm_lo
                iny
                lda (fs_dat_ptr),y
                sta fs_dpcm_hi
                ;
                lda #$80
                sta fs_pulse1_prev
                sta fs_pulse2_prev
                ;
                lda #%00001111
                sta snd_chn
                lda #%10000000
                sta tri_linear
                lda #%00000000
                sta noise_hi
                lda #%00110000
                sta sq1_vol
                sta sq2_vol
                sta noise_vol
                lda #%00001000
                sta sq1_sweep
                sta sq2_sweep
                jmp fs_stop

fs_stop         ; "famistudio_music_stop"
                ; called by: fs_init, fs_play
                ;
                lda #0
                sta fs_song_spd
                sta fs_dpcm_effect
                ;
                ldx #0
set_channels    sta fs_chn_repeat,x
                sta fs_chn_instru,x
                sta fs_chn_note,x
                sta fs_chn_ref_len,x
                sta arr33,x
                sta arr34,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                lda #0
                inx
                cpx #FS_CHN_CNT
                bne set_channels
                ;
                ldx #0
-               sta arr37,x             ; set_duty_cycles
                inx
                cpx #FS_DUTY_CYC_CNT
                bne -
                ;
                ldx #0
-               sta arr22,x             ; set_slides
                inx
                cpx #FS_SLIDE_CNT
                bne -
                ;
                ldx #0
-               lda #<fs_dummy_env      ; set_envelopes
                sta fs_env_addr_lo,x
                lda #>fs_dummy_env
                sta fs_env_addr_hi,x
                lda #0
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                inx
                cpx #FS_ENV_CNT
                bne -
                ;
                ldx #0
-               lda #<fs_dum_pit_env    ; set_pitch_envelopes
                sta fs_pit_env_ad_l,x
                lda #>fs_dum_pit_env
                sta fs_pit_env_ad_h,x
                lda #0
                sta fs_pit_env_rep,x
                sta fs_pit_env_va_l,x
                sta fs_pit_env_va_h,x
                sta fs_pit_env_fiva,x
                lda #1
                sta fs_pit_env_ptr,x
                inx
                cpx #FS_PIT_ENV_CNT
                bne -
                ;
                jmp fs_sample_stop

fs_play         ; "famistudio_music_play"; called by: init
                ;
                ldx fs_songlist_lo
                stx fs_dat_ptr+0
                ldx fs_songlist_hi
                stx fs_dat_ptr+1
                ldy #0
                cmp (fs_dat_ptr),y
                bcc +
                rts                     ; $80ed (unaccessed)
+               asl a
                sta fs_dat_ptr+0
                asl a
                tax
                asl a
                adc fs_dat_ptr+0
                stx fs_dat_ptr+0
                adc fs_dat_ptr+0
                adc #$05
                tay
                lda fs_songlist_lo
                sta fs_dat_ptr+0
                jsr fs_stop
                ;
                ldx #0
-               lda (fs_dat_ptr),y
                sta arr25,x
                iny
                lda (fs_dat_ptr),y
                sta arr26,x
                iny
                lda #0
                sta fs_chn_repeat,x
                sta fs_chn_instru,x
                sta fs_chn_note,x
                sta fs_chn_ref_len,x
                lda #$f0
                sta arr33,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                inx
                cpx #FS_CHN_CNT
                bne -
                ;
                lda fs_pal_adj
                beq +
                iny
                iny
+               lda (fs_dat_ptr),y
                sta arr37+3
                iny
                lda (fs_dat_ptr),y
                sta arr37+4
                copy #$00, arr37+5
                lda #$06
                sta arr37+6
                sta fs_song_spd
                rts

ucod1           ; unaccessed chunk ($8153)
                tax
                beq +
                jsr fs_sample_stop
                lda #0
                sta fs_env_value+0
                sta fs_env_value+3
                sta fs_env_value+6
                sta fs_env_value+8
                lda fs_song_spd
                ora #%10000000
                bne ++
+               lda fs_song_spd
                and #%01111111
++              sta fs_song_spd
                rts
                ; $8177

fs_get_pitch    ; "famistudio_get_note_pitch_macro"
                ; called by: fs_update
                ;
                clc
                lda fs_pit_env_fiva,y
                adc fs_pit_env_va_l,y
                sta ptr2+0
                lda fs_pit_env_fiva,y
                and #%10000000
                beq +
                lda #$ff
+               adc fs_pit_env_va_h,y
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

fs_upd_row      ; "famistudio_update_row"
                ; called by: fs_upd_row_del
                ;
                jsr fs_upd_chan
                bcc +++
                txa
                tay
                ldx dat5,y
                lda fs_chn_instru,y
                cpy #$04
                bcc ++
                lda fs_chn_note+4
                bne +
                jsr fs_sample_stop      ; unaccessed ($81d0)
                ldx #$04                ; unaccessed
                bne +++                 ; unaccessed
+               jsr sub11
                ldx #$04
                jmp +++
++              jsr fs_set_instr
+++             rts

fs_upd_row_del  ; "famistudio_update_row_with_delays"
                ; called by: fs_update
                ;
                lda fs_tem_adv_row
                beq +
                lda arr35,x
                bmi ++
                lda #$ff                ; unaccessed ($81ed)
                sta arr35,x             ; unaccessed
                jsr fs_upd_row          ; unaccessed
                jmp ++                  ; unaccessed
+               lda arr35,x
                bmi +++
                sub #$01
                sta arr35,x
                bpl +++
++              jsr fs_upd_row
+++             lda arr36,x
                bmi +
                sub #$01                ; unaccessed ($820d)
                sta arr36,x             ; unaccessed
                bpl +                   ; unaccessed
                lda #0                  ; unaccessed
                sta fs_chn_note,x       ; unaccessed
+               rts

fs_update       ; "famistudio_update"
                ; called by: nmi
                ;
                lda fs_dat_ptr+0
                pha
                lda fs_dat_ptr+1
                pha
                lda fs_song_spd
                bmi +
                bne ++
+               jmp cod10               ; unaccessed ($8228)
++              lda arr37+6
                cmp fs_song_spd
                ldx #$00
                stx fs_tem_adv_row
                bcc +
                sbc fs_song_spd
                sta arr37+6
                ldx #$01
                stx fs_tem_adv_row
                ;
+               ldx #0
-               jsr fs_upd_row_del
                inx
                cpx #FS_CHN_CNT
                bne -
                ;
                ldx #0
--              lda fs_env_repeat,x
                beq +
                dec fs_env_repeat,x
                bne +++
+               lda fs_env_addr_lo,x
                sta fs_dat_ptr+0
                lda fs_env_addr_hi,x
                sta fs_dat_ptr+1
                ;
                ldy fs_env_ptr,x
-               lda (fs_dat_ptr),y
                bpl +
                add #64
                sta fs_env_value,x
                iny
                bne ++
+               bne +
                iny
                lda (fs_dat_ptr),y
                tay
                jmp -
                ;
+               iny
                sta fs_env_repeat,x
++              tya
                sta fs_env_ptr,x
+++             inx
                cpx #FS_ENV_CNT
                bne --
                ;
                ldx #$00
                jmp cod2

cod1            ; unaccessed chunk ($828e)
                ;
                lda fs_pit_env_rep,x
                sub #$01
                sta fs_pit_env_rep,x
                and #%01111111
                beq cod3
                ;
                lda fs_pit_env_ad_l,x
                sta fs_dat_ptr+0
                lda fs_pit_env_ad_h,x
                sta fs_dat_ptr+1
                ;
                ldy fs_pit_env_ptr,x
                dey
                dey
                lda (fs_dat_ptr),y
                add #$40
                sta ram11
                clc
                adc fs_pit_env_va_l,x
                sta fs_pit_env_va_l,x
                ;
                lda ram11
                bpl +
                lda #$ff
+               adc fs_pit_env_va_h,x
                sta fs_pit_env_va_h,x
                jmp cod7
                ; $82c7

cod2            lda fs_pit_env_rep,x
                cmp #$81
                bcs cod1
                and #%01111111
                beq cod3
                dec fs_pit_env_rep,x
                bne cod7
                ;
cod3            lda fs_pit_env_ad_l,x
                sta fs_dat_ptr+0
                lda fs_pit_env_ad_h,x
                sta fs_dat_ptr+1
                ldy #0
                lda (fs_dat_ptr),y
                sta ram10
                ldy fs_pit_env_ptr,x
cod4            lda (fs_dat_ptr),y
                bpl cod5
                add #$40
                bit ram10
                bmi ucod3
                sta fs_pit_env_va_l,x
                ora #%00000000
                bmi +
                lda #0
                jmp ++
+               lda #$ff
++              sta fs_pit_env_va_h,x
                iny
                jmp cod6

ucod3           ; unaccessed chunk ($830a)
                sta ram11
                clc
                adc fs_pit_env_va_l,x
                sta fs_pit_env_va_l,x
                lda ram11
                and #%10000000
                bpl +
                lda #$ff
+               adc fs_pit_env_va_h,x
                sta fs_pit_env_va_h,x
                iny
                jmp cod6
                ; $8325

cod5            bne +
                iny
                lda (fs_dat_ptr),y
                tay
                jmp cod4
+               iny
                ora ram10
                sta fs_pit_env_rep,x
cod6            tya
                sta fs_pit_env_ptr,x
cod7            inx
                cpx #FS_PIT_ENV_CNT
                bne cod2

                ldx #0                  ; update_slides
fs_slide_proc   lda arr22,x             ; slide_process
                beq fs_slide_next

ucod4           ; unaccessed chunk ($8344)
                clc
                lda arr22,x
                adc arr23,x
                sta arr23,x
                lda arr22,x
                and #%10000000
                beq fs_pos_slide
                lda #$ff                ; negative_slide
                adc arr24,x
                sta arr24,x
                bpl fs_slide_next
                jmp fs_clr_slide
fs_pos_slide    adc arr24,x             ; positive_slide
                sta arr24,x
                bmi fs_slide_next
fs_clr_slide    lda #0                  ; clear_slide
                sta arr22,x
                ; $836f

fs_slide_next   inx
                cpx #FS_SLIDE_CNT
                bne fs_slide_proc

cod10           lda fs_chn_note+0
                bne +
                jmp ++                  ; unaccessed ($8379)
+               add fs_env_value+1
                add fs_pal_adj
                tax
                ldy #$00
                jsr fs_get_pitch
                copy ptr2+0, ram62
                copy ptr2+1, ram63
                lda arr33
                ora fs_env_value+0
                tax
                lda dat12,x
                ;
++              ldx fs_env_value+2
                ora dat11,x
                sta ram61
                lda fs_chn_note+1
                bne +
                jmp ++
+               add fs_env_value+4
                add fs_pal_adj
                tax
                ldy #$01
                jsr fs_get_pitch
                copy ptr2+0, ram65
                copy ptr2+1, ram66
                lda arr33+1
                ora fs_env_value+3
                tax
                lda dat12,x
                ;
++              ldx fs_env_value+5
                ora dat11,x
                sta ram64
                lda fs_chn_note+2
                bne +
                jmp ++
+               add fs_env_value+7
                add fs_pal_adj
                tax
                ldy #$02
                jsr fs_get_pitch
                copy ptr2+0, ram68
                copy ptr2+1, ram69
                lda arr33+2
                ora fs_env_value+6
                tax
                lda dat12,x
                ;
++              ora #%10000000
                sta ram67

                ; "famistudio_update_channel_sound"

                lda fs_chn_note+3
                bne fs_nocut            ; never taken
                jmp fs_set_volume

fs_nocut        ; unaccessed chunk ($8411)
                add fs_env_value+9
                ldy arr22+3
                beq +
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
+               and #%00001111
                eor #%00001111
                sta ram10
                ldx fs_env_value+10
                lda dat11,x
                asl a
                and #%10000000
                ora ram10
                sta ram71
                lda arr33+3
                ora fs_env_value+8
                tax
                lda dat12,x
                ; $845a

fs_set_volume   ldx fs_env_value+10
                ora dat11,x
                ora #%11110000
                sta ram70
                lda fs_song_spd
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
                cmp fs_pulse1_prev
                beq +
                sta fs_pulse1_prev
                sta sq1_hi
+               copy ram64, sq2_vol
                copy ram65, sq2_lo
                lda ram66
                cmp fs_pulse2_prev
                beq +
                sta fs_pulse2_prev
                sta sq2_hi
+               copy ram67, tri_linear
                copy ram68, tri_lo
                copy ram69, tri_hi
                copy ram70, noise_vol
                copy ram71, noise_lo
                pla
                sta fs_dat_ptr+1
                pla
                sta fs_dat_ptr+0
                rts

fs_set_instr    ; "famistudio_set_instrument"
                ; called by: fs_upd_row
                ;
                sty ram11
                asl a
                tay
                lda fs_instru_hi
                adc #$00
                sta fs_dat_ptr+1
                lda fs_instru_lo
                sta fs_dat_ptr+0
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                iny
                sta fs_env_addr_hi,x
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
+               lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                ;
++              lda #$01
                sta arr13,x
                lda #0
                sta fs_env_value+10,x
                sta fs_env_repeat,x
                sta fs_env_ptr,x
                lda ram11
                cmp #$02
                bne +
                iny
                iny
                bne ++                  ; unconditional
                ;
+               inx
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                lda #0
                sta fs_env_repeat,x
                sta fs_env_ptr,x
                stx ram12
                ldx ram11
                lda dat9,x
                tax
                lda arr37,x
                ldx ram12
                sta fs_env_value,x
                ;
++              ldx ram11
                lda arr34,x
                bmi +
                lda dat8,x
                bmi +
                tax
                lda #$01
                sta fs_pit_env_ptr,x
                lda #0
                sta fs_pit_env_rep,x
                sta fs_pit_env_va_l,x
                sta fs_pit_env_va_h,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_l,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_h,x
                ;
+               ldx ram11
                rts

fs_upd_chan     ; "famistudio_update_channel"
                ; called by: fs_upd_row
                ;
                lda fs_chn_repeat,x
                beq +
                dec fs_chn_repeat,x
                clc
                rts
+               copy #$00, ram12
                lda arr25,x
                sta fs_dat_ptr+0
                lda arr26,x
                sta fs_dat_ptr+1
                ldy #0
cod12           lda (fs_dat_ptr),y
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1
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

                ; "jmp_to_opcode"
                and #%00001111
                tax
                lda jump_tbl_lo,x       ; jump to index X in jump table
                sta ptr2+0
                lda jump_tbl_hi,x
                sta ptr2+1
                ldx ram10
                jmp (ptr2)

icode1          stx ram10
                lda dat8,x
                tax
                lda (fs_dat_ptr),y
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($85e3)
+               sta fs_pit_env_fiva,x
                ldx ram10
                jmp cod12

fs_clr_pitch    ; "opcode_clear_pitch_override_flag"
                lda #$7f
                and arr34,x
                sta arr34,x
                jmp cod12

fs_overr_pitch  ; "opcode_override_pitch_envelope"
                lda #$80
                ora arr34,x
                sta arr34,x
                stx ram10
                lda dat8,x
                tax
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_l,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_h,x
                lda #0
                tay
                sta fs_pit_env_rep,x
                lda #$01
                sta fs_pit_env_ptr,x
                ldx ram10
                clc
                lda #$02
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1        ; unaccessed ($8627)
+               jmp cod12

fs_clr_arp      ; "opcode_clear_arpeggio_override_flag" (unaccessed)
                lda #$fe
                and arr34,x
                sta arr34,x
                jmp cod12

fs_overr_arp    ; "opcode_override_arpeggio_envelope" (unaccessed)
                lda #$01
                ora arr34,x
                sta arr34,x
                stx ram10
                lda dat6,x
                tax
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                lda #0
                tay
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                ldx ram10
                clc
                lda #$02
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1
+               jmp cod12

fs_rst_arp      ; "opcode_reset_arpeggio" (unaccessed)
                stx ram10
                lda dat6,x
                tax
                lda #0
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                ldx ram10
                jmp cod12
                ; $8682

icode7          stx ram10
                lda dat9,x
                tax
                lda (fs_dat_ptr),y
                sta arr37,x
                sta ram11
                ldx ram10
                lda dat10,x
                tax
                lda ram11
                sta fs_env_value,x
                ldx ram10
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($86a0)
+               jmp cod12

icode8          lda (fs_dat_ptr),y
                sta arr35,x
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($86ae)
+               jmp cod17

icode9          ; unaccessed chunk ($86b3)
                copy #$40, ram12
                lda (fs_dat_ptr),y
                sta arr36,x
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1
+               jmp cod12

icode10         ; unaccessed chunk
                lda #$80
                ora ram12
                sta ram12
                jmp cod12

                ; "noise_slide" (unaccessed)
-               lda (fs_dat_ptr),y
                iny
                sta arr22+3
                lda (fs_dat_ptr),y
                iny
                sec
                sbc (fs_dat_ptr),y
                sta arr23+3
                bpl +
                lda #$ff
                bmi ++
+               lda #0
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

fs_slide        ; "opcode_slide" (unaccessed)
                cpx #3
                beq -
                stx ram10
                lda dat7,x
                tax
                lda (fs_dat_ptr),y
                iny
                sta arr22,x
                lda (fs_dat_ptr),y
                add fs_pal_adj
                sta ram11
                iny
                lda (fs_dat_ptr),y
                ldy ram11
                adc fs_pal_adj
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
+               lda (fs_dat_ptr),y      ; "slide_done_pos"?
                sta fs_chn_note,x
                clc
                lda #$03
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1
+               ldy #$00
                jmp +
                ; $8754

cod13           sta fs_chn_note,x
                ldy dat7,x
                bmi +
                lda #0
                sta arr22,y
+               bit ram12
                bmi ++
                bvs +
                lda #$ff
                sta arr36,x
+               lda fs_chn_note,x
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
                sta fs_chn_instru,x
                jmp cod12
                ;
--              lda (fs_dat_ptr),y
                sta fs_song_spd
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($8793)
+               jmp cod12
                ;
-               lda (fs_dat_ptr),y
                sta ram10
                iny
                lda (fs_dat_ptr),y
                sta fs_dat_ptr+1
                copy ram10, fs_dat_ptr+0
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
                lda fs_dat_ptr+0
                adc #$03
                sta arr30,x
                lda fs_dat_ptr+1
                adc #$00
                sta arr31,x
                lda (fs_dat_ptr),y
                sta fs_chn_ref_len,x
                iny
                lda (fs_dat_ptr),y
                sta ram10
                iny
                lda (fs_dat_ptr),y
                sta fs_dat_ptr+1
                copy ram10, fs_dat_ptr+0
                ldy #$00
                jmp cod12

ucod8           ; unaccessed chunk ($87de)
                stx ram10
                lda dat5,x
                tax
                lda fs_env_addr_lo,x
                sta ptr2+0
                lda fs_env_addr_hi,x
                sta ptr2+1
                ldy #0
                lda (ptr2),y
                beq +
                sta fs_env_ptr,x
                lda #0
                sta fs_env_repeat,x
+               ldx ram10
                clc
                jmp cod16
                ; $8802

cod15           sta fs_chn_repeat,x
cod16           lda fs_chn_ref_len,x
                beq cod17
                dec fs_chn_ref_len,x
                bne cod17
                lda arr30,x
                sta arr25,x
                lda arr31,x
                sta arr26,x
                rts
cod17           lda fs_dat_ptr+0
                sta arr25,x
                lda fs_dat_ptr+1
                sta arr26,x
                rts

jump_tbl_lo     ; partially unaccessed
                dl $2700
                dl fs_slide
                dl icode10
                dl fs_overr_pitch
                dl fs_clr_pitch
                dl fs_overr_arp
                dl fs_clr_arp
                dl fs_rst_arp
                dl icode1
                dl icode7
                dl icode8
                dl icode9
                dl jump_tbl_lo
                dl jump_tbl_lo
jump_tbl_hi     ; partially unaccessed
                dh $2700
                dh fs_slide
                dh icode10
                dh fs_overr_pitch
                dh fs_clr_pitch
                dh fs_overr_arp
                dh fs_clr_arp
                dh fs_rst_arp
                dh icode1
                dh icode7
                dh icode8
                dh icode9
                dh jump_tbl_lo
                dh jump_tbl_lo
                hex 88

fs_sample_stop  ; "famistudio_sample_stop"
                ; called by: fs_stop, ucod1, fs_upd_row
                copy #%00001111, snd_chn
                rts

                ldx #$01                ; unaccessed ($884a)
                stx fs_dpcm_effect      ; unaccessed

cod18           asl a
                asl a
                add fs_dpcm_lo
                sta fs_dat_ptr+0
                lda #0
                adc fs_dpcm_hi
                sta fs_dat_ptr+1
                copy #%00001111, snd_chn
                ldy #0
                lda (fs_dat_ptr),y
                sta dmc_start
                iny
                lda (fs_dat_ptr),y
                sta dmc_len
                iny
                lda (fs_dat_ptr),y
                sta dmc_freq
                iny
                lda (fs_dat_ptr),y
                sta dmc_raw
                copy #%00011111, snd_chn
                rts

sub11           ; called by: fs_upd_row
                ;
                ldx fs_dpcm_effect
                beq cod18

ucod9           ; unaccessed chunk ($8887)
                tax
                lda snd_chn
                and #%00010000
                beq +
                rts
+               sta fs_dpcm_effect
                txa
                jmp cod18

                ; unaccessed chunk
                stx fs_dat_ptr+0
                sty fs_dat_ptr+1
                ldy #0
                lda fs_pal_adj
                bne +
                iny
                iny
+               lda (fs_dat_ptr),y
                sta ram72
                iny
                lda (fs_dat_ptr),y
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
                lda #0
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
                copy ram72, fs_dat_ptr+0
                copy ram73, fs_dat_ptr+1
                lda (fs_dat_ptr),y
                sta arr39,x
                iny
                lda (fs_dat_ptr),y
                sta arr40,x
                rts
                ; $88f3

sub13           ; called by: fs_update
                ;
                lda arr38,x
                beq +
                dec arr38,x             ; $88f8 (unaccessed)
                bne cod19               ; unaccessed
+               lda arr40,x
                bne ucod10
                rts

ucod10          ; unaccessed chunk ($8903)
                sta fs_dat_ptr+1
                lda arr39,x
                sta fs_dat_ptr+0
                ldy arr41,x
                clc
-               lda (fs_dat_ptr),y
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
                lda (fs_dat_ptr),y
                iny
                bne +
                stx ram11
                ldx ram10
                jsr sub14
                ldx ram11
+               sta fs_pit_env_va_l,x
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
                inc fs_dat_ptr+1
                inc arr40,x
                rts

fs_dummy_env    hex c0 7f 00 00         ; famistudio_dummy_envelope
fs_dum_pit_env  hex 00 c0 7f 00 01      ; famistudio_dummy_pitch_envelope

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

                ; BG PT data for screens except for Devil World
                ; (13045 bytes total)
pt_data2        incbin "bpm-pt2.bin"

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

                ; $c280: partially unaccessed; read indirectly using fs_dat_ptr
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

                ; $c301: read indirectly using fs_dat_ptr
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
                ldx #$80
                ldy #$c2
                lda ptr1+0
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

; -----------------------------------------------------------------------------

dnt_decomp_blk  ; Donut - decompress a variable-size block from dnt_stream_ptr,
                ; output 64 bytes to dnt_blk_buf,x
                ; out: carry = failure, Y = # of bytes read, X += 64
                ; block header bits: L M l m bb B R:
                ;     R: rotate plane bits (135-deg. reflection)
                ;     bbB:
                ;         000 = all planes $00
                ;         010 = L planes $00, M planes pb8
                ;         100 = L planes pb8, M planes $00
                ;         110 = all planes pb8
                ;         001 = in extra byte, for each bit from MSB:
                ;               0 = $00 plane, 1 = pb8 plane
                ;         011 = in extra byte, decode only 1 pb8 plane and
                ;               duplicate for each bit from MSB:
                ;               0 = $00 plane, 1 = duplicated plane
                ;               if extra byte = $00, don't decode pb8 plane
                ;         1x1 = uncompressed block
                ;     m: M planes predict from $ff
                ;     l: L planes predict from $ff
                ;     M: M ^= L
                ;     L: L ^= M
                ; 00101010 = uncompressed 64-byte block (ASCII "*")
                ; called by: dnt_decomp

                ldy #0
                txa
                add #64
                bcs +                   ; error; exit (never taken)
                sta dnt_blk_ofs_end
                lda (dnt_stream_ptr),y
                iny
                sta dnt_blk_hdr
                cmp #$2a
                beq dnt_raw_blk_lp      ; never taken
                cmp #$c0
                bcc dnt_normal_blk      ; always taken
+               rts                     ; unaccessed ($d5e4)

dnt_rd_pl_def   ; "read_plane_def_from_stream"
                ror a
                lda (dnt_stream_ptr),y
                iny
                bne +++                 ; always taken

dnt_raw_blk_lp  ; "raw_block_loop" (unaccessed, $d5eb)
                lda (dnt_stream_ptr),y
                iny
                sta dnt_blk_buf,x
                inx
                cpy #65                 ; size of raw block
                bcc dnt_raw_blk_lp
                bcs exit_sub

dnt_normal_blk  stx dnt_blk_offs        ; do_normal_block
                and #%11011111
                sta dnt_even_odd
                lsr a
                ror dnt_is_rotated
                lsr a
                bcs dnt_rd_pl_def
                ;
                ; "unpack_shorthand_plane_def"
                and #%00000011
                tax
                lda dnt_pln_def_tbl,x
                ;
+++             ror dnt_is_rotated
                sta dnt_plane_def
                sty dnt_pb8_ctrl
                clc
                lda dnt_blk_offs

dnt_plane_loop  adc #8                  ; plane_loop
                sta dnt_blk_offs
                ;
                lda dnt_even_odd
                eor dnt_blk_hdr
                sta dnt_even_odd
                and #%00110000
                beq +                   ; "not predicted from $ff"
                lda #$ff
+               asl dnt_plane_def
                bcc dnt_do_zero_pln
                ;
                ldy dnt_pb8_ctrl        ; do_pb8_plane
                bit dnt_is_rotated
                bpl +                   ; "don't rewind input pointer"
                ldy #2                  ; unaccessed ($d62d)
+               tax
                lda (dnt_stream_ptr),y
                iny
                sta dnt_pb8_ctrl
                txa
                bvs dnt_rot_pb8_pln
                ;
                ; "do_normal_pb8_plane"
                ldx dnt_blk_offs
                rol dnt_pb8_ctrl
dnt_pb8_loop    bcc +
                lda (dnt_stream_ptr),y
                iny
+               dex
                sta dnt_blk_buf,x
                asl dnt_pb8_ctrl
                bne dnt_pb8_loop
                sty dnt_pb8_ctrl
                ;
dnt_end_plane   bit dnt_even_odd
                bpl +
                ;
                ; "XOR M onto L"
                ldy #8
-               dex
                lda dnt_blk_buf,x
                eor dnt_blk_buf+8,x
                sta dnt_blk_buf,x
                dey
                bne -
+               bvc +
                ;
                ; "XOR L onto M"
                ldy #8
-               dex
                lda dnt_blk_buf,x
                eor dnt_blk_buf+8,x
                sta dnt_blk_buf+8,x
                dey
                bne -
                ;
+               lda dnt_blk_offs
                cmp dnt_blk_ofs_end
                bcc dnt_plane_loop

                ldy dnt_pb8_ctrl
exit_sub        clc
                tya
                adc dnt_stream_ptr+0
                sta dnt_stream_ptr+0
                bcc +
                inc dnt_stream_ptr+1
+               ldx dnt_blk_ofs_end
                dec dnt_blk_cnt
                rts

dnt_do_zero_pln ; "do_zero_plane"
                ldx dnt_blk_offs
                ldy #8
-               dex
                sta dnt_blk_buf,x
                dey
                bne -
                beq dnt_end_plane

dnt_rot_pb8_pln ; "do_rotated_pb8_plane"
                ldx #8
-               asl dnt_pb8_ctrl        ; buffered_pb8_loop
                bcc +                   ; use_previous
                lda (dnt_stream_ptr),y
                iny
+               dex
                sta dnt_plane_buf,x
                bne -
                ;
                sty dnt_pb8_ctrl
                ldy #8
                ldx dnt_blk_offs
                ;
dnt_flip_bits   asl dnt_plane_buf+0     ; flip_bits_loop
                ror a
                asl dnt_plane_buf+1
                ror a
                asl dnt_plane_buf+2
                ror a
                asl dnt_plane_buf+3
                ror a
                asl dnt_plane_buf+4
                ror a
                asl dnt_plane_buf+5
                ror a
                asl dnt_plane_buf+6
                ror a
                asl dnt_plane_buf+7
                ror a
                dex
                sta dnt_blk_buf,x
                dey
                bne dnt_flip_bits
                ;
                beq dnt_end_plane       ; unconditional

dnt_pln_def_tbl db %00000000            ; shorthand_plane_def_table
                db %01010101
                db %10101010
                db %11111111

dnt_decomp      ; "decompress X*64 bytes from AAYY to ppu_data; PPU is in
                ; forced blank, ppu_addr already set";
                ; "Donut, NES CHR codec decompressor" by Johnathan Roatch;
                ; see https://www.nesdev.org/wiki/User:Ns43110/donut.s
                ; in: X = block count
                ; called by: sub16
                ;
                sty dnt_stream_ptr+0
                sta dnt_stream_ptr+1
                stx dnt_blk_cnt
                ;
--              ldx #64
                jsr dnt_decomp_blk
                cpx #$80
                bne +                   ; end block upload
                ;
                ldx #64                 ; copy 64 bytes (index $40-$7f) to PPU
-               lda dnt_blk_buf,x
                sta ppu_data
                inx
                bpl -
                ;
                ldx dnt_blk_cnt
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
