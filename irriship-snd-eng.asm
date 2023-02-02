; Irritating Ship - sound engine (Famitone2)
;
; Entry points: snd_eng1, snd_eng2, stop_music, snd_eng4, play_sfx, snd_eng6.
; Variables shared with main: region, sq1_prev, sq2_prev.
;
; See "famitone2.txt" for the original source.

region          equ $10  ; 0=NTSC, 1=PAL, 2=Dendy

ptr1            equ $5e  ; data ptr
ram1            equ $60
ram2            equ $61
ram3            equ $62
ram4            equ $63
out_buffer      equ $64  ; output buffer ("FT_OUT_BUF") (15 bytes)
sq1_prev        equ $74  ; "FT_PULSE1_PREV"
sq2_prev        equ $75  ; "FT_PULSE2_PREV"
ptr2            equ $76  ; data ptr
ram23           equ $78
ram24           equ $79
ram25           equ $7a
ram26           equ $7b
ptr3            equ $7d  ; jump/data ptr
ptr4            equ $7f  ; jump/data ptr
ptr5            equ $83  ; data ptr
ptr6            equ $85  ; data ptr
ram27           equ $87
ram28           equ $88
ram29           equ $89
ram30           equ $8a
ram31           equ $8b
ram32           equ $8c

arr1            equ $0301  ; 2 bytes
arr2            equ $0303  ; 4 bytes
arr3            equ $0307  ; at least 11 bytes

arr4            equ $0500
arr5            equ $0505
ram33           equ $050a
ram34           equ $050b
ram35           equ $050c
ram36           equ $050d
ram37           equ $050e
ram38           equ $050f
ram39           equ $0510
ram40           equ $0511
ram41           equ $0512
ram42           equ $0513
ram43           equ $0514
ram44           equ $0515
ram45           equ $0516
ram46           equ $0517
ram47           equ $0518
ram48           equ $051a
;
arr6            equ $051b
arr7            equ $0520
arr8            equ $0525
arr9            equ $052a
arr10           equ $052f
arr11           equ $0534
arr12           equ $0539
arr13           equ $053e
arr14           equ $0543
arr15           equ $0548
arr16           equ $054d
arr17           equ $0551
arr18           equ $0555
arr19           equ $0559
arr20           equ $055d
;
arr21           equ $0562
;
arr22           equ $0564
arr23           equ $0568
arr24           equ $056c
arr25           equ $0570
arr26           equ $0574
arr27           equ $0578
arr28           equ $057c
arr29           equ $0580
arr30           equ $0584
arr31           equ $0588
arr32           equ $058c
arr33           equ $0590
arr34           equ $0594
arr35           equ $0598
arr36           equ $059c
arr37           equ $05a0
arr38           equ $05a4
arr39           equ $05a8
arr40           equ $05ac
arr41           equ $05b0
arr42           equ $05b4
arr43           equ $05b8
arr44           equ $05bc
arr45           equ $05c0
arr46           equ $05c4
arr47           equ $05c8
arr48           equ $05cc
arr49           equ $05d0
arr50           equ $05d4
arr51           equ $05d8

sq1_vol         equ $4000
sq1_sweep       equ $4001
sq1_lo          equ $4002
sq1_hi          equ $4003
sq2_vol         equ $4004
sq2_sweep       equ $4005
sq2_lo          equ $4006
sq2_hi          equ $4007
tri_linear      equ $4008
tri_unknown     equ $4009
tri_lo          equ $400a
tri_hi          equ $400b
noise_vol       equ $400c
noise_unknown   equ $400d
noise_lo        equ $400e
noise_hi        equ $400f
snd_chn         equ $4015
joypad2         equ $4017

FT_SFX_CH0      equ $00
FT_SFX_CH1      equ $0f
FT_SFX_CH2      equ $1e
FT_SFX_CH3      equ $2d

macro dwbe _word
                db >(_word), <(_word)
endm
macro add _src
                clc
                adc _src
endm
macro sub _src
                sec
                sbc _src
endm
macro copy _src, _dst
                ; for clarity, don't use this if the value of A is read later
                lda _src
                sta _dst
endm
macro stz _dst
                ; for clarity, don't use this if the value of A is read later
                lda #0
                sta _dst
endm

; -----------------------------------------------------------------------------

                base $a4d9

snd_eng1        ; called by nmi
                lda ram2
                ror a
                bcc +
                jsr sub7
                jmp ++
+               lda #$30
                sta out_buffer+0
                sta out_buffer+4
                sta out_buffer+12
                stz out_buffer+8
                ;
++              ldx #FT_SFX_CH0
                jsr sfx_update
                ldx #FT_SFX_CH1
                jsr sfx_update
                ldx #FT_SFX_CH2
                jsr sfx_update
                ldx #FT_SFX_CH3
                jsr sfx_update
                ;
                copy out_buffer+0, sq1_vol
                copy out_buffer+1, sq1_sweep
                copy out_buffer+2, sq1_lo
                lda out_buffer+3
                cmp sq1_prev
                beq +                   ; update pulse1?
                sta sq1_prev
                sta sq1_hi
                ;
+               copy out_buffer+4, sq2_vol
                copy out_buffer+5, sq2_sweep
                copy out_buffer+6, sq2_lo
                lda out_buffer+7
                cmp sq2_prev
                beq +                   ; update pulse2?
                sta sq2_prev
                sta sq2_hi
                ;
+               copy out_buffer+8, tri_linear
                copy out_buffer+9, tri_unknown
                copy out_buffer+10, tri_lo
                copy out_buffer+11, tri_hi
                ;
                copy out_buffer+12, noise_vol
                copy out_buffer+13, noise_unknown
                copy out_buffer+14, noise_lo
                copy out_buffer+15, noise_hi
                ;
                rts

snd_eng2        ; $a561; called by sub48, sub49
                ldx #<idat2
                stx ram3
                ldx #>idat2
                stx ram4
                ldx region
                jsr sub3
                copy #1, ram2
                rts

stop_music      ; $a573; called by icod8, icod9, sub59
                ldx #<idat1
                stx ram3
                ldx #>idat1
                stx ram4
                lda #0
                ldx region
                jsr sub3
                stz ram2
                rts

idat1           hex 0d 00 0d 00 0d 00 0d 00  ; $a587
                hex 00 10 0e b8 0b 0f 00 16
                hex 00 01 40 06 96 00 18 00
                hex 22 00 22 00 22 00 22 00
                hex 22 00 00 3f

                stz ram2                ; $a5ab, unaccessed
                rts                     ; unaccessed

snd_eng4        ; $a5b0
                copy #1, ram2
                rts

                ; unaccessed chunk ($a5b5)
                lda ram2
                eor #%00000001
                sta ram2
                rts

play_sfx        ; play sound effect in A ($a5bc)
                ; ram23 = (ram23+1)&3
                ; X = ram23*15
                ;
                pha
                ;
                ldx ram23
                inx
                txa
                and #%00000011
                sta ram23
                tax
                lda times15,x
                tax
                ;
                pla
                jmp sub2                ; hundreds of lines forward

times15         db 0, 15, 30, 45        ; $a5ce

idat2           ; $a5d2; read by snd_eng2
                hex 3f 01 fb 00 3f 01 3f 01
                hex 00 10 0e b8 0b 07 ff 00
                hex 00

idat3           ; $a5e3; read via ptr4 by sub20, sub21
                ; probably music data
                hex 0f 0f 0f 0f 0f 0f 00 03 ff 00 00 00 13 00 05 00
                hex 00 00 01 00 00 00 00 06 ff 00 00 0c 0a 04 02 01
                hex 00 09 00 00 00 00 00 00 07 07 07 0f 0f 0f 32 ff
                hex 00 00 0c 07 06 06 06 06 06 06 06 06 05 05 05 05
                hex 05 05 05 05 04 04 04 04 04 04 04 03 03 03 03 03
                hex 03 03 03 02 02 02 02 02 02 02 02 01 01 01 01 01
                hex 01 01 01 01 0c 00 00 00 07 07 07 07 10 10 10 10
                hex 17 17 17 17 09 ff 00 00 0c 0a 08 06 05 04 03 02
                hex 01 02 01 00 01 1a 1e 1c ff 00 00 09 0e 0f 0f 0f
                hex 0e 0d 0c 0a 09 08 08 07 07 06 06 05 05 04 04 03
                hex 03 02 02 02 01 01 00 05 04 00 01 19 1a 1b 1c 1e
                hex 09 08 00 01 06 0b 0b 0b 0b 0b 0b 0b 0d 04 03 00
                hex 01 03 05 0d 0b 02 ff 00 00 0c 00 0a ff 00 00 00
                hex 00 00 00 02 02 02 02 02 00 0d ff 00 00 00 00 00
                hex 00 00 00 01 01 01 01 01 01 00

idat4           ; $a6cd; read via ptr3 by sub24
                ; probably music data
                hex 13 01 18 01 19 01 1c 01 1f 01 24 01 29 01 2e 01
                hex 31 01 36 01 39 01 3c 01

idat5           ; $a6e5; read via ptr4 by icod27
                ; probably music data
                hex 03 0d 00 18 00 00 02 32 00 02 75 00 03 28 00 92
                hex 00 03 3f 00 b8 00 03 85 00 c1 00 04 1f 00 03 98
                hex 00 ce 00 02 d6 00 02 dc 00 02 ea 00

idat6           ; $a711; read via ptr3, ptr4 by sub5, sub6
                ; probably music data
                hex 41 01 48 01 0f 40 06 96 00 66 01 70 01 7a 01 84
                hex 01 8e 01 98 01 a2 01 ac 01 b6 01 c0 01 ca 01 d4
                hex 01 de 01 e8 01 f2 01

idat7           ; $a738; read via ptr4 by sub6
                ; probably music data
                hex fc 01 16 02 3b 02 46 02 84 02 86 02 a0 02 d1 02
                hex da 02 84 02 fc 01 16 02 3b 02 dc 07 84 02 08 08
                hex a0 02 d1 02 dc 07 84 02 13 03 30 03 4a 03 64 03
                hex 84 02 99 03 d6 03 df 03 ec 03 84 02 e3 04 18 05
                hex 43 05 4c 05 65 05 6b 05 a8 05 d9 05 e2 05 65 05
                hex 33 06 64 06 43 05 e2 05 65 05 6b 05 a8 05 d9 05
                hex e2 05 65 05 8f 06 18 05 42 04 e2 05 65 05 e9 06
                hex a8 05 a8 04 e2 05 65 05 3a 07 78 07 a9 07 e2 05
                hex 65 05 05 04 28 04 cf 07 84 02 84 02 89 04 9c 04
                hex de 06 84 02 84 02

idat8           ; $a7ce; read via ptr5 by sub8, sub9
                ; probably music data
                hex 00 13 e1 a4 00 f9 27 01 82 00 f9 25 f2 27 f9 23
                hex f2 25 f9 25 84 f2 23 01 7f 22 b2 00 92 00 13 a4
                hex 00 00 02 e1 f2 27 01 25 01 23 01 25 03 e2 a4 01
                hex f2 25 03 b2 10 00 06 b2 00 00 03 b2 01 00 0f e0
                hex 88 96 25 03 2c 03 38 03 33 33 e5 f0 19 03 e4 19
                hex 01 19 01 e5 b2 10 19 03 e4 19 03 e5 b2 00 19 03
                hex e4 19 01 19 01 e5 19 03 e4 19 01 19 01 e5 19 03
                hex e4 19 01 19 01 82 03 e5 19 e4 19 e1 92 f1 13 f2
                hex 00 f4 00 84 9a 11 12 03 00 3f 00 13 e1 a4 00 f9
                hex 27 01 82 00 f9 25 f2 27 f9 23 f2 25 f9 20 84 f2
                hex 23 01 7f 22 b2 00 00 13 a4 00 00 02 e1 f2 27 01
                hex 25 01 23 01 20 03 a4 01 9a 7e f2 25 03 b2 10 00
                hex 02 9a 7c 00 03 b2 00 00 03 9a 7a 00 04 b2 01 00
                hex 02 9a 79 00 07 e0 25 03 2c 03 3a 03 34 33 e5 f1
                hex 19 03 e4 b2 10 19 01 19 01 e5 19 03 e4 19 03 e5
                hex b2 00 19 03 e4 19 01 19 01 e5 19 03 e4 19 01 19
                hex 01 e5 19 03 e4 19 01 19 01 e5 19 03 e4 19 03 e5
                hex 19 0b e6 19 01 19 01 e1 a4 02 b2 01 f7 15 17 a4
                hex 02 b2 01 f7 14 07 a4 02 b2 01 f7 12 17 a4 02 b2
                hex 01 f7 10 07 00 0a e3 a4 01 b2 10 f2 21 08 b2 03
                hex 00 17 e2 a4 01 b2 10 f2 2a 08 b2 03 00 0a e0 2d
                hex 03 34 03 3b 03 39 07 82 03 38 36 38 2a 2d 38 84
                hex 36 07 34 03 33 03 34 03 e5 f8 19 03 e4 19 01 19
                hex 01 e6 19 03 e5 19 07 e6 19 01 19 01 19 03 e4 19
                hex 01 19 01 e5 19 03 e4 19 01 19 01 e6 19 03 e5 19
                hex 07 82 01 e6 19 19 19 19 e4 19 84 19 01 e1 a4 02
                hex b2 01 f7 0f 0f a4 02 b2 01 f7 14 1f b2 00 92 f1
                hex 28 03 82 00 a0 81 00 a0 82 00 a0 82 00 a0 83 00
                hex a0 84 00 a0 85 00 a0 86 00 a0 87 00 a0 88 00 a0
                hex 89 00 a0 8a 00 84 a0 8b 00 00 00 2f e7 b2 00 92
                hex f1 28 0f 82 03 e0 33 27 2c 31 30 31 33 84 34 23
                hex e5 f8 19 03 e4 19 01 19 01 e6 19 03 e5 19 07 e6
                hex 19 01 19 01 19 03 e4 19 23 00 07 b2 01 00 07 e1
                hex a4 00 b2 01 f8 28 17 a4 00 b2 01 f8 2a 07 82 03
                hex e0 a4 01 b2 00 f5 25 2c 38 84 33 03 00 07 e1 a4
                hex 00 f8 20 03 b2 01 00 13 a4 00 b2 01 f8 23 17 a4
                hex 00 b2 01 f8 22 07 7f 04 e9 34 01 7f 00 33 01 31
                hex 01 7f 00 33 01 31 01 7f 00 33 01 ea 31 02 e9 2f
                hex 01 31 02 9c 25 00 02 7f 02 9c 00 33 00 a6 03 34
                hex 01 a6 03 36 01 37 00 9c 00 38 02 34 01 31 02 39
                hex 01 eb 38 02 e9 36 00 37 00 9c 25 38 08 e1 a4 00
                hex b2 01 f8 2c 07 a6 05 a4 02 f8 2d 03 b2 01 00 33
                hex 00 07 a6 03 e1 f8 24 03 b2 01 00 33 9c 00 00 01
                hex 7f 00 e9 3d 01 eb 38 02 e9 36 01 38 02 36 01 34
                hex 02 33 01 31 02 2f 01 2c 07 2a 01 2c 02 2a 01 2d
                hex 02 2c 01 30 02 31 01 2c 00 a6 03 30 01 31 01 33
                hex 00 a6 03 38 01 3c 05 00 09 e1 a2 a4 01 f6 28 01
                hex b2 01 00 0c a2 a4 01 f6 2a 01 b2 01 00 08 b2 01
                hex 00 03 a2 a4 01 f6 2c 01 b2 01 00 0c a2 a4 01 f6
                hex 2d 01 b2 01 00 01 a2 a4 01 f6 2c 04 00 04 e1 a2
                hex a4 01 f6 20 03 b2 01 00 0a a2 a4 01 f6 23 01 b2
                hex 01 00 0c a2 a4 01 f6 22 01 b2 01 00 0c a2 a4 01
                hex f6 24 01 b2 01 00 0b e1 19 0e 1c 0e 1b 0e 20 12
                hex 00 31 82 00 e4 f1 15 a6 03 15 f2 00 15 f4 00 15
                hex a6 03 84 f5 15 01 f6 15 05 00 3a 8c 01 00 04 00
                hex 00 b2 01 9c 55 00 06 b2 00 9c 00 00 01 e1 a2 a4
                hex 01 f8 28 01 b2 01 00 0c a2 a4 01 f8 2a 01 b2 01
                hex 00 0c a2 a4 01 f8 2c 01 b2 01 00 0c a2 a4 01 f8
                hex 2a 01 b2 01 00 02 b2 01 9c 55 00 03 00 04 e1 a2
                hex a4 01 f8 20 03 b2 01 00 0a a2 a4 01 f8 23 01 b2
                hex 01 00 0c a2 a4 01 f8 22 01 b2 01 00 0c a2 a4 01
                hex f8 21 01 b2 01 00 05 a2 a4 01 f8 28 05 e1 19 0e
                hex 1c 0e 1b 0e 1a 12 e8 fa 15 04 e4 f9 15 02 f7 15
                hex 01 f9 15 02 f7 15 01 f9 15 02 e6 fa 15 01 e4 f9
                hex 15 02 f7 15 01 e6 fa 15 02 fa 15 01 e8 fa 15 04
                hex e4 f9 15 02 f7 15 01 f9 15 02 f7 15 01 f9 15 02
                hex e6 fa 15 01 e4 f9 15 02 f7 15 01 e6 fa 15 00 a6
                hex 04 fa 15 01 fa 15 05 00 09 e1 a2 a4 01 f8 28 01
                hex b2 01 00 0c a2 a4 01 f8 2a 01 b2 01 00 0c a2 a4
                hex 01 f8 2c 01 b2 01 00 0c a2 a4 01 f8 2d 01 b2 01
                hex 00 00 a2 a4 01 f8 2c 05 00 04 e1 a2 a4 01 f8 20
                hex 03 b2 01 00 0a a2 a4 01 f8 23 01 b2 01 00 0c a2
                hex a4 01 f8 22 01 b2 01 00 0c a2 a4 01 f8 24 01 b2
                hex 01 00 0b e1 a4 02 f7 0d 03 b2 01 00 05 a2 a4 01
                hex f6 28 01 b2 01 00 02 a4 02 f7 10 09 a2 a4 01 f6
                hex 2a 01 b2 01 00 02 a4 02 f7 0f 03 b2 01 00 05 a2
                hex a4 01 f6 2c 01 b2 01 00 02 a4 02 f7 14 03 b2 01
                hex 00 05 a2 a4 01 f6 2d 01 b2 01 00 01 a2 a4 01 f6
                hex 2c 04 7f 07 e1 20 13 7f 0a 8c 01 00 18 e1 a4 02
                hex b2 01 f7 0d 07 b2 00 9c 00 00 01 a2 a4 01 f8 28
                hex 01 b2 01 00 02 a4 02 b2 01 f7 10 09 a2 a4 01 f8
                hex 2a 01 b2 01 00 02 a4 02 b2 01 f7 0f 09 a2 a4 01
                hex f8 2c 01 b2 01 00 02 a4 02 b2 01 f7 0e 09 a2 a4
                hex 01 f8 2a 01 b2 01 00 02 b2 01 9c 55 00 03 e1 a4
                hex 02 f8 0d 00 b2 01 00 06 b2 00 9c 00 00 01 a2 a4
                hex 01 f8 28 01 b2 01 00 0c a2 a4 01 f8 2a 01 b2 01
                hex 00 0c a2 a4 01 f8 2c 01 b2 01 00 0c a2 a4 01 f8
                hex 2d 01 b2 01 00 02 b2 01 9c 55 00 03 00 04 e1 a2
                hex a4 01 f8 20 03 b2 01 00 0a a2 a4 01 f8 23 01 b2
                hex 01 00 0c a2 a4 01 f8 22 01 b2 01 00 0c a2 a4 01
                hex f8 24 01 b2 01 00 05 a2 a4 01 f8 28 05 e9 3d 03
                hex 9c 25 00 0a e1 1c 0e 88 96 1b 05 88 95 00 03 88
                hex 92 00 04 88 90 14 02 88 88 00 03 88 80 00 03 88
                hex 70 00 07 e1 88 96 19 0f 7f 07 1c 0f 7f 07 1b 0f
                hex 82 01 e4 b2 00 f8 19 19 19 e6 19 84 e5 19 03 19
                hex 13 19 03 e4 19 01 19 01 e5 19 03 e4 19 03 e5 19
                hex 03 e4 19 01 19 01 e5 19 03 e4 19 03 00 13 e1 a4
                hex 00 f9 27 01 82 00 f9 25 f2 27 f9 23 f2 25 f9 20
                hex 84 f2 23 01 7f 1e a4 02 b2 01 f7 14 03

; -----------------------------------------------------------------------------

sfx_region_ptrs ; pointers to sound effect data by region ($adfb);
                ; read via ptr2 by snd_eng6
                dw sfx_ptrs_ntsc, sfx_ptrs_pal, sfx_ptrs_dendy

                ; pointers to sound effect data ($ae01)
sfx_ptrs_ntsc   dw sfx_thrust_ntsc, sfx_blip_ntsc, sfx_crash_ntsc, sfx_warp
                dw sfx_secret_ntsc
sfx_ptrs_pal    dw sfx_thrust_pal, sfx_blip_pal, sfx_crash_pal, sfx_warp
                dw sfx_secret_pal
sfx_ptrs_dendy  dw sfx_thrust_ntsc, sfx_blip_ntsc, sfx_crash_dndy, sfx_warp
                dw sfx_secret_dndy

sfx_thrust_ntsc hex 83 ba 84 df 85 01 89 39 8a 0d 01 84 3a 85 02 89  ; $ae1f
                hex 35 8a 01 01 84 80 89 34 01 84 74 85 04 89 33 01
                hex 84 9d 85 05 89 31 00

sfx_thrust_pal  hex 83 ba 84 bd 85 01 89 39 8a 0d 01 84 11 85 02 89  ; $ae46
                hex 35 8a 01 01 84 52 89 34 01 84 23 85 04 89 33 01
                hex 84 37 85 05 89 31 00

sfx_blip_ntsc   hex 83 b5 84 7e 85 00 89 34 8a 80 01 83 b3 84 3f 01  ; $ae6d
                hex 83 b2 89 32 01 83 b1 89 30 02 00

sfx_blip_pal    hex 83 b5 84 75 85 00 89 34 8a 80 01 83 b3 84 3a 01  ; $ae88
                hex 83 b2 89 32 01 83 b1 89 30 02 00

sfx_warp        hex 89 3f 8a 03 01 89 3e 01 8a 05 01 89 3d 01 8a 07  ; $aea3
                hex 01 89 3c 01 8a 08 01 89 3b 01 8a 0a 01 89 3a 02
                hex 89 39 8a 0c 02 89 38 8a 0b 02 89 37 02 89 36 02
                hex 89 35 01 8a 0c 01 89 34 01 8a 0b 01 89 33 02 89
                hex 32 02 89 31 04 00

sfx_crash_ntsc  hex 80 be 81 eb 82 01 83 38 84 a8 85 06 89 3e 8a 0e  ; $aee9
                hex 01 80 bd 81 2b 82 02 01 81 6b 83 37 8a 09 01 80
                hex bc 81 ab 01 80 bb 81 eb 89 3d 8a 03 01 81 2b 82
                hex 03 83 36 01 80 ba 81 96 01 81 d6 01 80 b9 81 16
                hex 82 04 83 35 89 3c 01 80 b8 81 56 01 81 96 83 34
                hex 01 80 b7 81 d6 01 80 b6 81 16 82 05 89 3b 01 81
                hex 56 83 33 01 80 b5 81 96 01 81 d6 01 80 b4 81 16
                hex 82 06 83 32 89 3a 8a 09 01 80 b3 81 56 01 81 96
                hex 83 31 8a 03 01 80 b2 81 d6 01 80 b1 81 16 82 07
                hex 89 39 01 81 56 01 81 96 01 80 30 83 30 01 89 38
                hex 04 89 37 04 89 36 8a 09 02 8a 03 02 89 35 04 89
                hex 34 04 89 33 04 89 32 04 89 31 04 00

sfx_crash_pal   hex 80 be 81 cc 82 01 83 38 84 2f 85 06 89 3e 8a 0e  ; $afa5
                hex 01 80 bd 81 0c 82 02 01 81 4c 83 37 8a 09 01 80
                hex bc 81 8c 01 80 bb 81 cc 89 3d 8a 03 01 81 59 82
                hex 03 83 36 01 80 ba 81 99 01 81 d9 01 80 b9 81 19
                hex 82 04 83 35 89 3c 01 80 b8 81 59 01 81 99 83 34
                hex 01 80 b7 81 d9 01 80 b6 81 19 82 05 89 3b 01 81
                hex 59 83 33 01 80 b5 81 99 8a 09 01 81 d9 8a 03 01
                hex 80 b4 81 19 82 06 83 32 89 3a 01 80 b3 81 59 01
                hex 81 99 83 31 01 80 b2 81 d9 01 80 b1 81 19 82 07
                hex 89 39 01 81 59 01 81 99 01 80 30 83 30 01 89 38
                hex 03 8a 09 01 89 37 01 8a 03 03 89 36 04 89 35 04
                hex 89 34 04 89 33 03 00

sfx_crash_dndy  hex 80 be 81 eb 82 01 83 38 84 a8 85 06 89 3e 8a 0e  ; $b05c
                hex 01 80 bd 81 2b 82 02 01 81 6b 83 37 8a 09 01 80
                hex bc 81 ab 01 80 bb 81 eb 89 3d 8a 03 01 81 96 82
                hex 03 83 36 01 80 ba 81 d6 01 81 16 82 04 01 80 b9
                hex 81 56 83 35 89 3c 01 80 b8 81 96 01 81 d6 83 34
                hex 01 80 b7 81 16 82 05 01 80 b6 81 56 89 3b 01 81
                hex 96 83 33 01 80 b5 81 d6 8a 09 01 81 16 82 06 8a
                hex 03 01 80 b4 81 56 83 32 89 3a 01 80 b3 81 96 01
                hex 81 d6 83 31 01 80 b2 81 16 82 07 01 80 b1 81 56
                hex 89 39 01 81 96 01 81 d6 01 80 30 83 30 01 89 38
                hex 03 8a 09 01 89 37 01 8a 03 03 89 36 04 89 35 04
                hex 89 34 04 89 33 03 00

sfx_secret_ntsc hex 80 b9 81 d5 82 00 01 80 b8 81 46 01 81 d5 01 80  ; $b113
                hex b7 01 80 b6 01 80 b9 81 8e 01 80 b8 81 2f 01 81
                hex 8e 01 80 b7 01 80 b9 81 6a 01 80 b8 81 23 01 81
                hex 6a 01 80 b7 01 80 b9 81 5e 01 80 b8 81 1f 01 81
                hex 5e 01 80 b7 01 80 b6 02 80 b5 02 80 b4 01 80 b3
                hex 02 80 b2 01 80 b1 00

sfx_secret_pal  hex 80 b9 81 c6 82 00 01 80 b8 81 41 01 81 c6 01 80  ; $b16a
                hex b7 01 80 b9 81 84 01 80 b8 81 2b 01 81 84 01 80
                hex b7 01 80 b9 81 62 01 80 b8 81 20 01 81 62 01 80
                hex b9 81 57 01 80 b8 81 1d 01 81 57 01 80 b7 01 80
                hex b6 02 80 b5 02 80 b4 01 80 b3 02 00

sfx_secret_dndy hex 80 b9 81 d5 82 00 01 80 b8 81 46 01 81 d5 01 80  ; $b1b6
                hex b7 01 80 b9 81 8e 01 80 b8 81 2f 01 81 8e 01 80
                hex b7 01 80 b9 81 6a 01 80 b8 81 23 01 81 6a 01 80
                hex b9 81 5e 01 80 b8 81 1f 01 81 5e 01 80 b7 01 80
                hex b6 02 80 b5 02 80 b4 01 80 b3 02 00

snd_eng6        ; $b202; reads indirectly from sfx_region_ptrs on boot;
                ; called by sub59
                ;
                stx ptr2+0
                sty ptr2+1
                ldy #0
                lda region
                asl a
                tay
                lda (ptr2),y            ; $b20c
                sta arr1+0
                iny
                lda (ptr2),y            ; $b212
                sta arr1+1
                ldx #0
-               jsr sub1
                txa
                add #$0f
                tax
                cpx #$3c
                bne -
                rts

sub1            ; $b226; called by snd_eng6, sub2
                ;
                lda #0
                sta arr2+2,x
                sta arr2,x
                sta arr2+3,x
                sta arr3+6,x
                lda #$30
                sta arr3,x
                sta arr3+3,x
                sta arr3+9,x
                rts

sub2            ; $b240; called by play_sfx; sfx number in A
                ;
                asl a
                tay
                jsr sub1                ; doesn't access Y
                copy arr1+0, ptr2+0     ; sfx_ptrs_ntsc -> ptr2
                copy arr1+1, ptr2+1
                lda (ptr2),y
                sta arr2+1,x            ; e.g. sfx_secret_ntsc
                iny
                lda (ptr2),y
                sta arr2+2,x
                rts

; -----------------------------------------------------------------------------

sfx_update      ; $b25b; "_FT2SfxUpdate"; called by snd_eng1

                lda arr2,x
                beq +
                dec arr2,x
                bne +++
+               lda arr2+2,x
                bne +
                rts
+               sta ptr1+1
                lda arr2+1,x
                sta ptr1+0
                ldy arr2+3,x
                clc
-               lda (ptr1),y
                bmi +
                beq ++
                iny
                sta arr2,x
                tya
                sta arr2+3,x
                jmp +++
+               iny
                stx ram1
                adc ram1
                and #%01111111
                tax
                lda (ptr1),y
                iny
                sta arr3,x
                ldx ram1
                jmp -
                ;
++              sta arr2+2,x
+++             lda out_buffer+0
                and #%00001111
                sta ram1
                lda arr3,x
                and #%00001111
                cmp ram1
                bcc +
                lda arr3,x
                sta out_buffer+0
                lda arr3+1,x
                sta out_buffer+2
                lda arr3+2,x
                sta out_buffer+3
+               lda arr3+3,x
                beq +
                sta out_buffer+4
                lda arr3+4,x
                sta out_buffer+6
                lda arr3+5,x
                sta out_buffer+7
+               lda arr3+6,x
                beq +
                sta out_buffer+8
                lda arr3+7,x
                sta out_buffer+10
                lda arr3+8,x
                sta out_buffer+11
+               lda out_buffer+12
                and #%00001111
                sta ram1
                lda arr3+9,x
                and #%00001111
                cmp ram1
                bcc +
                lda arr3+9,x
                sta out_buffer+12
                lda arr3+10,x
                sta out_buffer+14
+               rts
                jmp sub3
                jmp sub7

sub3            ; $b2fd; called by snd_eng2, stop_music, sfx_update
                ;
                asl a
                jsr sub4
                lda #0
                tax
-               sta out_buffer+0,x
                inx
                cpx #$10
                bne -
                copy #$30, out_buffer+12
                copy #$0f, snd_chn
                lda #8
                sta out_buffer+1
                sta out_buffer+5
                lda #%11000000
                sta joypad2
                lda #%01000000
                sta joypad2
                copy #$ff, arr4+2
                lda #0
                tax
-               sta arr11,x
                sta arr40,x
                sta arr41,x
                sta arr43,x
                sta arr42,x
                sta arr17,x
                sta arr16,x
                inx
                cpx #4
                bne -
                lda arr4+1
                and #%00000010
                beq +
                lda #$30
                ldx #0
-               sta arr45,x
                inx
                cpx #4
                bne -
                lda #0
+               sta arr11+4
                rts

sub4            ; $b35f; called by sub3
                ;
                pha
                copy ram3, ptr4+0
                copy ram4, ptr4+1
                ldy #0
-               clc
                lda (ptr4),y
                adc ram3
                sta arr4-3,y
                iny
                lda (ptr4),y
                adc ram4
                sta arr4-3,y
                iny
                cpy #8
                bne -
                lda (ptr4),y
                sta arr4+1
                iny
                cpx #1
                beq +
                cpx #2
                beq ++                  ; never taken
                ;
                lda (ptr4),y
                iny
                sta ram41
                lda (ptr4),y
                iny
                sta ram42
                lda #<note_freqs1
                sta ptr6+0
                lda #>note_freqs1
                sta ptr6+1
                jmp +++
                ;
+               iny
                iny
                lda (ptr4),y
                iny
                sta ram41
                lda (ptr4),y
                iny
                sta ram42
                lda #<note_freqs2
                sta ptr6+0
                lda #>note_freqs2
                sta ptr6+1
                jmp +++
                ;
++              ; start unaccessed chunk ($b3bd)
                iny
                iny
                lda (ptr4),y
                iny
                sta ram41
                lda (ptr4),y
                iny
                sta ram42
                lda #<note_freqs1
                sta ptr6+0
                lda #>note_freqs1
                sta ptr6+1
                ; end unaccessed chunk ($b3d3)
                ;
+++             pla
                tay
                jsr sub5
                ldx #1
                stx ram33
                dex
-               lda #$7f
                sta arr9,x
                lda #$80
                sta arr13,x
                lda #0
                sta arr47,x
                sta arr50,x
                sta arr40,x
                sta arr20,x
                sta arr14,x
                sta arr44,x
                sta arr8,x
                inx
                cpx #4
                bne -
                ldx #$ff
                inx
                stx ram35
                jsr sub6
                jsr sub12
                lda #0
                sta ram37
                sta ram38
                rts

sub5            ; $b419; called by sub4
                ;
                copy arr4-3, ptr3+0
                copy arr4-2, ptr3+1
                clc
                lda (ptr3),y            ; $b424; read from idat6
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y            ; $b42b; read from idat6
                adc ram4
                sta ptr4+1
                lda #0
                tax
                tay
                clc
                lda (ptr4),y            ; $b436; read from idat6
                adc ram3
                sta arr4+3
                iny
                lda (ptr4),y            ; $b43e; read from idat6
                adc ram4
                sta arr4+4
                iny
-               lda (ptr4),y            ; $b446; read from idat6
                sta arr5,x
                iny
                inx
                cpx #6
                bne -
                rts

sub6            ; $b452; called by sub4, sub7
                ;
                asl a
                add arr4+3
                sta ptr3+0
                lda #0
                tay
                tax
                adc arr4+4
                sta ptr3+1
                clc
                lda (ptr3),y            ; $b463; read from idat6
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y            ; $b46a; read from idat6
                adc ram4
                sta ptr4+1
                ldy #0
                stx ram34
-               clc
                lda (ptr4),y            ; $b476; read from idat7
                adc ram3
                sta arr6,x
                iny
                lda (ptr4),y            ; $b47e; read from idat7
                adc ram4
                sta arr7,x
                iny
                lda #0
                sta arr14,x
                sta arr10,x
                lda #$ff
                sta arr15,x
                inx
                cpx #5
                bne -
                lda #0
                sta ram45
                sta ram46
                lda ram47
                bne +                   ; never taken
                rts
                ;
+               ; start long unaccessed chunk ($b4a6)
                sta ram34
                ldx #0
---             copy ram34, ram25
                lda #0
                sta arr14,x
--              ldy #0
                lda arr6,x
                sta ptr5+0
                lda arr7,x
                sta ptr5+1
-               lda arr14,x
                beq +
                dec arr14,x
                jmp ++
+               lda (ptr5),y
                bmi +++
                lda arr15,x
                cmp #$ff
                bne +
                iny
                lda (ptr5),y
                iny
                sta arr14,x
                jmp ++
+               iny
                sta arr14,x
++              clc
                tya
                adc ptr5+0
                sta arr6,x
                lda #0
                adc ptr5+1
                sta arr7,x
                dec ram25
                bne --
                inx
                cpx #5
                bne ---
                stz ram47
                rts
+++             cmp #$80
                beq ++++
                cmp #$82
                beq ++
                cmp #$84
                beq +++
                pha
                cmp #$8e
                beq +
                cmp #$92
                beq +
                cmp #$a2
                beq +
                and #%11110000
                cmp #$f0
                beq +
                cmp #$e0
                beq +++++
                iny
+               iny
                pla
                jmp -
++              iny
                lda (ptr5),y
                iny
                sta arr15,x
                jmp -
+++             iny
                lda #$ff
                sta arr15,x
                jmp -
++++            iny
                lda (ptr5),y
                iny
                jsr sub24
                jmp -
+++++           iny
                pla
                and #%00001111
                asl a
                jsr sub24
                jmp -
                ; end long unaccessed chunk

sub7            ; $b553; called by snd_eng1, sfx_update
                ;
                lda ram33
                bne +
                rts
+               ldx #0
-               lda arr10,x
                beq +
                sub #1
                sta arr10,x
                bne +
                jsr sub8
                lda arr11,x
                and #%01111111
                sta arr11,x
+               inx
                cpx #5
                bne -
                lda ram38
                bmi +
                ora ram37
                beq +
                jmp cod22
+               lda ram36
                beq +
                stz ram36
                lda ram35
                jsr sub6
+               ldx #0
-               lda arr10,x
                beq +
                lda #0
                sta arr10,x
                jsr sub8
+               jsr sub8
                lda arr11,x
                and #%01111111
                sta arr11,x
                inx
                cpx #5
                bne -
                lda ram45
                beq +
                sub #1
                sta ram35
                copy #1, ram36
                jmp cod21
+               lda ram46
                beq ++
                sub #1
                sta ram47
                inc ram35
                lda ram35
                cmp arr5
                beq +
                copy #1, ram36
                jmp cod21
+               stz ram35
                copy #1, ram36
                jmp cod21
++              inc ram34
                lda ram34
                cmp arr5+1
                bne cod21
                inc ram35
                lda ram35
                cmp arr5
                beq +
                sta ram36
                jmp cod21
+               ldx #0
                stx ram35
                inx
                stx ram36
cod21           jsr sub11
cod22           sec
                lda ram37
                sbc ram39
                sta ram37
                lda ram38
                sbc ram40
                sta ram38
                ldx #0
-               lda arr11,x
                beq +
                ;
                ; start unaccessed chunk ($b634)
                sub #1
                sta arr11,x
                bne +
                sta arr8,x
                sta arr43,x
                sta arr42,x
                sta arr17,x
                sta arr16,x
                ; end unaccessed chunk ($b64b)
                ;
+               inx
                cpx #5
                bne -
                ldx #0
-               jsr sub14
                lda arr8,x
                beq +
                jsr sub20
+               jsr sub15
                inx
                cpx #4
                bne -
                jsr sub26
                rts

sub8            ; $b669; called by sub7
                ;
                ldy arr14,x
                beq +
                dey
                tya
                sta arr14,x
                rts
+               sty ram44
                copy #$0f, ram43
                lda arr6,x
                sta ptr5+0
                lda arr7,x
                sta ptr5+1
                ;
cod23           ; $b686; called from >10 places 100s of lines away
                lda (ptr5),y            ; read from idat8
                bpl +
                jmp cod27
+               beq cod24
                cmp #$7f
                bne +
                jmp cod26
+               cmp #$7e
                bne +
                jmp cod25
+               sta arr8,x
                jsr sub10
                lda arr11,x
                bmi +
                lda #0
                sta arr11,x
+               jsr sub23
                lda #0
                sta arr12,x
                lda ram43
                sta arr32,x
                lda #0
                lda arr33,x
                and #%11110000
                sta arr33,x
                lsr a
                lsr a
                lsr a
                lsr a
                ora arr33,x
                sta arr33,x
                lda arr40,x
                cmp #6
                beq +
                cmp #8
                bne ++
+               lda #0
                sta arr40,x
++              cpx #2
                bcc +
                jmp cod28
+               lda #0
                sta arr21,x
cod24           jmp cod28
                ;
                ; start unaccessed chunk ($b6ee)
cod25           lda arr12,x
                cmp #1
                beq cod24
                lda #1
                sta arr12,x
                jsr sub22
                jmp cod28
                ; end unaccessed chunk ($b700)
                ;
cod26           lda #0
                sta arr8,x
                sta arr32,x
                sta arr43,x
                sta arr42,x
                sta arr17,x
                sta arr16,x
                cpx #2
                bcs +
+               jmp cod28
                ;
--              pla
                asl a
                asl a
                asl a
                and #%01111000
                sta arr9,x
                iny
                jmp cod23
-               pla
                and #%00001111
                asl a
                jsr sub24
                iny
                jmp cod23
cod27           pha
                and #%11110000
                cmp #$f0
                beq --
                cmp #$e0
                beq -
                pla
                and #%01111111
                sty ram24
                tay
                lda jump_tbl1,y
                sta ptr4+0
                iny
                lda jump_tbl1,y
                sta ptr4+1
                ldy ram24
                iny
                jmp (ptr4)
-               sta arr14,x
                jmp cod29
                ;
cod28           lda arr15,x
                cmp #$ff
                bne -
                iny
                lda (ptr5),y            ; $b763; read from idat8
                sta arr14,x
cod29           clc
                iny
                tya
                adc ptr5+0
                sta arr6,x
                lda #0
                adc ptr5+1
                sta arr7,x
                lda ram44
                beq +
                sta arr21,x
                stz ram44
+               rts

sub9            ; $b785; called by many subs between icod1 and icod25
                ;
                lda (ptr5),y            ; read from idat8
                pha
                iny
                pla
                rts

jump_tbl1       ; $b78b; jump table; called by sub8
                ;
                dw icod1                ;  0
                dw icod2                ;  1
                dw icod3                ;  2
                dw icod4                ;  3
                dw icod5                ;  4
                dw icod6                ;  5
                dw icod7                ;  6
                dw icod8                ;  7
                dw icod9                ;  8
                dw icod14               ;  9
                dw icod11               ; 10
                dw icod12               ; 11
                dw icod10               ; 12
                dw icod13               ; 13
                dw icod16               ; 14
                dw icod17               ; 15
                dw icod18               ; 16
                dw icod19               ; 17
                dw icod21               ; 18
                dw icod20               ; 19
                dw icod15               ; 20
                dw icod21               ; 21
                dw icod22               ; 22
                dw icod22               ; 23
                dw icod23               ; 24
                dw icod24               ; 25
                dw icod25               ; 26
                dw icod26               ; 27
                dw icod26               ; 28

icod1           ; unaccessed sub ($b7c5)
                jsr sub9
                jsr sub24
                jmp cod23

icod2           ; $b7ce
                jsr sub9
                sta arr15,x
                jmp cod23

icod3           ; $b7d7
                lda #$ff
                sta arr15,x
                jmp cod23

icod4           ; unaccessed sub ($b7df)
                jsr sub9
                sta arr5+2
                jsr sub12
                jmp cod23

icod5           ; $b7eb
                jsr sub9
                sta arr5+3
                jsr sub12
                jmp cod23

icod6           ; unaccessed sub ($b7f7)
                jsr sub9
                sta ram45
                jmp cod23

icod7           ; $b800
                jsr sub9
                sta ram46
                jmp cod23

icod8           ; unaccessed sub ($b809)
                jsr sub9
                stz ram33
                jmp cod23

icod9           ; unaccessed sub ($b814)
                jsr sub9
                sta ram43
                sta arr32,x
                jmp cod23

icod10          ; unaccessed sub ($b820)
                jsr sub9
                sta arr41,x
                lda #2
                sta arr40,x
                jmp cod23

icod11          ; unaccessed sub ($b82e)
                jsr sub9
                sta arr41,x
                lda #3
                sta arr40,x
                jmp cod23

icod12          ; unaccessed sub ($b83c)
                jsr sub9
                sta arr41,x
                lda #4
                sta arr40,x
                jmp cod23

icod13          ; $b84a
                jsr sub9
                sta arr41,x
                lda #0
                sta arr44,x
                lda #1
                sta arr40,x
                jmp cod23

icod14          ; $b85d
                lda #0
                sta arr41,x
                sta arr40,x
                sta arr43,x
                sta arr42,x
                jmp cod23

icod15          ; unaccessed sub ($b86e)
                jsr sub9
                sta ram44
                jmp cod23

icod16          ; $b877
                jsr sub9
                pha
                lda arr47,x
                bne ++
                lda arr4+1
                and #%00000010
                beq +
                lda #$30
+               sta arr45,x
++              pla
                pha
                and #%11110000
                sta arr46,x
                pla
                and #%00001111
                sta arr47,x
                jmp cod23

icod17          ; unaccessed sub ($b89c)
                jsr sub9
                pha
                and #%11110000
                sta arr49,x
                pla
                and #%00001111
                sta arr50,x
                cmp #0
                beq +
                jmp cod23
+               sta arr48,x
                jmp cod23

icod18          ; $b8b8
                jsr sub9
                sta arr13,x
                jmp cod23

icod19          ; $b8c1
                lda #$80
                sta arr13,x
                jmp cod23

icod20          ; $b8c9
                jsr sub9
                sta arr10,x
                dey
                jmp cod29

icod21          ; $b8d3
                jsr sub9
                sta arr33,x
                clc
                asl a
                asl a
                asl a
                asl a
                ora arr33,x
                sta arr33,x
                jmp cod23

icod22          ; unaccessed sub ($b8e7)
                jsr sub9
                sta arr41,x
                lda #5
                sta arr40,x
                jmp cod23

icod23          ; unaccessed sub ($b8f5)
                jsr sub9
                sta arr41,x
                lda #7
                sta arr40,x
                jmp cod23

icod24          ; $b903
                jsr sub9
                sta arr20,x
                jmp cod23

icod25          ; unaccessed sub ($b90c)
                jsr sub9
                ora #%10000000
                sta arr11,x
                jmp cod23

icod26          ; $b917
                ;
                sub #1
                cpx #3
                beq +
                asl a
                sty ram24
                tay
cod30           lda (ptr6),y
                sta arr17,x
                iny
                lda (ptr6),y
                sta arr16,x
                ldy ram24
                rts
+               and #%00001111
                ora #%00010000
                sta arr17,x
                lda #0
                sta arr16,x
                rts
                ;
sub10           ; $b93d; called by sub8
                ;
                sub #1
                cpx #3
                beq +++
                asl a
                sty ram24
                tay
                lda arr40,x
                cmp #2
                bne ++                  ; always taken
                ;
                ; start unaccessed chunk ($b94f)
                lda (ptr6),y
                sta arr43,x
                iny
                lda (ptr6),y
                sta arr42,x
                ldy ram24
                lda arr17,x
                ora arr16,x
                bne +
                lda arr43,x
                sta arr17,x
                lda arr42,x
                sta arr16,x
+               rts
                ; end unaccessed chunk ($b971)
                ;
++              jmp cod30
                rts
+++             ora #%00010000
                pha
                lda arr40,x
                cmp #2
                bne ++                  ; always taken
                ;
                ; start unaccessed chunk ($b97f)
                pla
                sta arr43,x
                lda #0
                sta arr42,x
                lda arr17,x
                ora arr16,x
                bne +
                lda arr43,x
                sta arr17,x
                lda arr42,x
                sta arr16,x
+               rts
                ; end unaccessed chunk ($b99d)
                ;
++              pla
                sta arr17,x
                lda #0
                sta arr16,x
                rts

sub11           ; $b9a7; called by sub7
                ;
                clc
                lda ram37
                adc ram41
                sta ram37
                lda ram38
                adc ram42
                sta ram38
                rts

sub12           ; $b9bb
                tya
                pha
                copy arr5+3, ram29
                stz ram30
                ldy #3
-               asl ram29
                rol ram30
                dey
                bne -
                copy ram29, ram27
                lda ram30
                tay
                asl ram29
                rol ram30
                clc
                lda ram27
                adc ram29
                sta ram27
                tya
                adc ram30
                sta ram28
                copy arr5+2, ram29
                stz ram30
                jsr sub13
                copy ram27, ram39
                copy ram28, ram40
                pla
                tay
                rts

sub13           ; $b9ff
                stz ram32
                ldy #$10
-               asl ram27
                rol ram28
                rol a
                rol ram32
                pha
                cmp ram29
                lda ram32
                sbc ram30
                bcc +
                sta ram32
                pla
                sbc ram29
                pha
                inc ram27
+               pla
                dey
                bne -
                sta ram31
                rts

sub14           ; $ba24
                lda arr20,x
                beq cod31
                lda arr20,x
                and #%00001111
                sta ram24
                sec
                lda arr9,x
                sbc ram24
                bpl +
                lda #0
+               sta arr9,x
                lda arr20,x
                lsr a
                lsr a
                lsr a
                lsr a
                sta ram24
                clc
                lda arr9,x
                adc ram24
                bpl +
                lda #$7f
+               sta arr9,x
cod31           lda arr40,x
                beq rts17
                cmp #1
                beq +
                ;
                ; start unaccessed chunk ($ba5c)
                cmp #2
                beq ++
                cmp #3
                beq +++
                cmp #6
                beq ++++
                cmp #8
                beq +++++
                cmp #5
                beq ++++++
                cmp #7
                beq ++++++
                jmp cod36
                ; end unaccessed chunk ($ba77)
                ;
+               jmp cod39
++              jmp cod33               ; unaccessed ($ba7a)
+++             jmp cod35               ; unaccessed
++++            jmp cod37               ; unaccessed
+++++           jmp cod38               ; unaccessed
++++++          jmp cod32               ; unaccessed
rts17           rts                     ; $ba89

cod32           ; start unaccessed chunk ($ba8a)
                lda arr17,x
                pha
                lda arr16,x
                pha
                lda arr41,x
                and #%00001111
                sta ram24
                lda arr40,x
                cmp #5
                beq ++
                lda arr8,x
                sub ram24
                bpl +
                lda #1
+               bne +
                lda #1
+               jmp +
++              lda arr8,x
                add ram24
                cmp #$60
                bcc +
                lda #$60
+               sta arr8,x
                jsr icod26
                lda arr17,x
                sta arr43,x
                lda arr16,x
                sta arr42,x
                lda arr41,x
                lsr a
                lsr a
                lsr a
                ora #%00000001
                sta arr41,x
                pla
                sta arr16,x
                pla
                sta arr17,x
                clc
                lda arr40,x
                adc #1
                sta arr40,x
                cpx #3
                bne ++
                cmp #6
                beq +
                lda #6
                sta arr40,x
                jmp cod31
+               lda #8
                sta arr40,x
++              jmp cod31
                ; end unaccessed chunk

sub15           ; $bb03
                lda arr17,x
                sta arr18,x
                lda arr16,x
                sta arr19,x
                lda arr13,x
                cmp #$80
                beq +
                lda arr8,x
                beq +
                clc
                lda arr18,x
                adc #$80
                sta arr18,x
                lda arr19,x
                adc #0
                sta arr19,x
                sec
                lda arr18,x
                sbc arr13,x
                sta arr18,x
                lda arr19,x
                sbc #0
                sta arr19,x
+               jsr sub18
                jsr sub19
                rts

cod33           ; start long unaccessed chunk ($bb45)
                lda arr41,x
                beq cod34
                lda arr43,x
                ora arr42,x
                beq cod34
                lda arr16,x
                cmp arr42,x
                bcc ++
                bne +
                lda arr17,x
                cmp arr43,x
                bcc ++
                bne +
                jmp rts17
+               lda arr41,x
                sta ptr3+0
                stz ptr3+1
                jsr sub17
                cmp arr42,x
                bcc +
                bmi +
                bne cod34
                lda arr17,x
                cmp arr43,x
                bcc +
                jmp rts17
++              lda arr41,x
                sta ptr3+0
                stz ptr3+1
                jsr sub16
                lda arr42,x
                cmp arr16,x
                bcc +
                bne cod34
                lda arr43,x
                cmp arr17,x
                bcc +
                jmp rts17
+               lda arr43,x
                sta arr17,x
                lda arr42,x
                sta arr16,x
cod34           jmp rts17
cod35           lda arr41,x
                sta ptr3+0
                stz ptr3+1
                jsr sub17
                jsr sub25
                jmp rts17
cod36           lda arr41,x
                sta ptr3+0
                stz ptr3+1
                jsr sub16
                jsr sub25
                jmp rts17
sub16           clc
                lda arr17,x
                adc ptr3+0
                sta arr17,x
                lda arr16,x
                adc ptr3+1
                sta arr16,x
                bcc +
                lda #$ff
                sta arr17,x
                sta arr16,x
+               rts
sub17           sec
                lda arr17,x
                sbc ptr3+0
                sta arr17,x
                lda arr16,x
                sbc ptr3+1
                sta arr16,x
                bcs +
                lda #0
                sta arr17,x
                sta arr16,x
+               rts
cod37           sec
                lda arr17,x
                sbc arr41,x
                sta arr17,x
                lda arr16,x
                sbc #0
                sta arr16,x
                bmi +
                cmp arr42,x
                bcc +
                bne ++
                lda arr17,x
                cmp arr43,x
                bcc +
                jmp rts17
cod38           clc
                lda arr17,x
                adc arr41,x
                sta arr17,x
                lda arr16,x
                adc #0
                sta arr16,x
                cmp arr42,x
                bcc ++
                bne +
                lda arr17,x
                cmp arr43,x
                bcs +
                jmp rts17
+               lda arr43,x
                sta arr17,x
                lda arr42,x
                sta arr16,x
                lda #0
                sta arr40,x
                sta arr43,x
                sta arr42,x
++              jmp rts17
                ; end long unaccessed chunk

cod39           ; $bc79; called by sub14
                lda arr44,x
                cmp #1
                beq +
                cmp #2
                beq ++
                lda arr8,x
                jsr icod26
                inc arr44,x
                jmp rts17
+               lda arr41,x
                lsr a
                lsr a
                lsr a
                lsr a
                clc
                adc arr8,x
                jsr icod26
                lda arr41,x
                and #%00001111
                bne +
                sta arr44,x
                jmp rts17
+               inc arr44,x
                jmp rts17
++              lda arr41,x
                and #%00001111
                clc
                adc arr8,x
                jsr icod26
                lda #0
                sta arr44,x
                jmp rts17

sub18           ; $bcc5
                lda arr47,x
                bne +
                rts
+               clc
                adc arr45,x
                and #%00111111
                sta arr45,x
                cmp #$10
                bcc +
                cmp #$20
                bcc ++
                cmp #$30
                bcc +++
                sub #$30
                sta ram24
                sec
                lda #$0f
                sbc ram24
                ora arr46,x
                tay
                lda math_tbl2,y
                jmp ++++
+               ora arr46,x
                tay
                lda math_tbl2,y
                sta ptr3+0
                stz ptr3+1
                jmp +
++              sub #$10
                sta ram24
                sec
                lda #$0f
                sbc ram24
                ora arr46,x
                tay
                lda math_tbl2,y
                sta ptr3+0
                stz ptr3+1
                jmp +
+++             sub #$20
                ora arr46,x
                tay
                lda math_tbl2,y
++++            eor #%11111111
                sta ptr3+0
                copy #$ff, ptr3+1
                clc
                lda ptr3+0
                adc #1
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
+               lda arr4+1
                and #%00000010
                beq +
                ;
                ; start unaccessed chunk ($bd44)
                lda #$0f
                clc
                adc arr46,x
                tay
                clc
                lda math_tbl2,y
                adc #1
                adc ptr3+0
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
                lsr ptr3+1
                ror ptr3+0
                ; end unaccessed chunk ($bd5f)

+               sec
                lda arr18,x
                sbc ptr3+0
                sta arr18,x
                lda arr19,x
                sbc ptr3+1
                sta arr19,x
                rts

                ; unaccessed chunk ($bd71)
                clc
                lda arr18,x
                adc ptr3+0
                sta arr18,x
                lda arr19,x
                adc ptr3+1
                sta arr19,x
                rts
                ; end unaccessed chunk

sub19           ; $bd83
                lda arr50,x
                bne +
                lda #0
                sta arr51,x
                rts
                ;
                ; start unaccessed chunk ($bd8e)
+               clc
                adc arr48,x
                and #%00111111
                sta arr48,x
                lsr a
                cmp #$10
                bcc +
                sub #$10
                sta ram24
                sec
                lda #$0f
                sbc ram24
                ora arr49,x
                tay
                lda math_tbl2,y
                lsr a
                sta ram24
                jmp ++
+               ora arr49,x
                tay
                lda math_tbl2,y
                lsr a
                sta ram24
++              sta arr51,x
                rts
                ; end unaccessed chunk

sub20           ; $bdc1
                ;
                lda arr23,x
                beq +
                sta ptr4+1
                lda arr22,x
                sta ptr4+0
                lda arr34,x
                cmp #$ff
                beq +
                jsr sub21
                sta arr34,x
                lda ram48
                sta arr32,x
+               lda arr25,x
                beq cod41
                sta ptr4+1
                lda arr24,x
                sta ptr4+0
                lda arr35,x
                cmp #$ff
                beq cod40
                jsr sub21
                sta arr35,x
                lda arr8,x
                beq cod41
                ldy #3
                lda (ptr4),y            ; $be00; read from idat3
                beq ++++
                cmp #1
                beq +++                 ; always taken
                ;
                ; start unaccessed chunk ($be08)
                clc
                lda arr8,x
                adc ram48
                cmp #1
                bcc +
                cmp #$5f
                bcc ++
                lda #$5f
                bne ++
+               lda #1
++              sta arr8,x
                jmp +++++
                ; end unaccessed chunk ($be23)
                ;
+++             lda ram48
                add #1
                jmp +++++
++++            clc
                lda arr8,x
                adc ram48
                beq +
                bpl ++
+               lda #1
++              cmp #$60
                bcc +++++
                lda #$60
+++++           jsr icod26
                lda #1
                sta arr39,x
                jmp cod41
cod40           ldy #3
                lda (ptr4),y            ; $be4c; read from idat3
                beq cod41               ; always taken
                ;
                ; start unaccessed chunk ($be50)
                lda arr39,x
                beq cod41
                lda arr8,x
                jsr icod26
                lda #0
                sta arr39,x
                ; end unaccessed chunk ($be60)
                ;
cod41           lda arr27,x
                beq +++
                sta ptr4+1
                lda arr26,x
                sta ptr4+0
                lda arr36,x
                cmp #$ff
                beq +++
                jsr sub21
                sta arr36,x
                clc
                lda ram48
                adc arr17,x
                sta arr17,x
                lda ram48
                bpl +
                lda #$ff
                bmi ++
+               lda #0
++              adc arr16,x
                sta arr16,x
                jsr sub25
+++             lda arr29,x
                beq +++
                ;
                ; start unaccessed chunk ($be9c)
                sta ptr4+1
                lda arr28,x
                sta ptr4+0
                lda arr37,x
                cmp #$ff
                beq +++
                jsr sub21
                sta arr37,x
                lda ram48
                sta ptr3+0
                rol a
                bcc +
                copy #$ff, ptr3+1
                jmp ++
+               stz ptr3+1
++              ldy #4
-               clc
                rol ptr3+0
                rol ptr3+1
                dey
                bne -
                clc
                lda ptr3+0
                adc arr17,x
                sta arr17,x
                lda ptr3+1
                adc arr16,x
                sta arr16,x
                jsr sub25
                ; end unaccessed chunk ($bee1)
                ;
+++             lda arr31,x
                beq +                   ; always taken
                ;
                ; start unaccessed chunk ($bee6)
                sta ptr4+1
                lda arr30,x
                sta ptr4+0
                lda arr38,x
                cmp #$ff
                beq +
                jsr sub21
                sta arr38,x
                lda ram48
                pha
                lda arr33,x
                and #%11110000
                sta arr33,x
                pla
                ora arr33,x
                sta arr33,x
                ; end unaccessed chunk ($bf0d)
                ;
+               rts

sub21           ; $bf0e
                ;
                add #4
                tay
                lda (ptr4),y            ; $bf12; read from idat3
                sta ram48
                dey
                dey
                dey
                tya
                ldy #0
                cmp (ptr4),y            ; $bf1d; read from idat3
                beq +
                ldy #2
                cmp (ptr4),y            ; $bf23; read from idat3
                beq ++                  ; never taken
                rts
+               iny
                lda (ptr4),y            ; $bf29; read from idat3
                cmp #$ff
                bne cod42
                rts
cod42           pha
                lda arr12,x
                bne +
                pla
                rts
                ;
                ; start unaccessed chunk ($bf38)
+               ldy #2
                lda (ptr4),y
                bne +
                pla
                rts
+               pla
                lda #$ff
                rts
++              sta ram24
                lda arr12,x
                bne +
                dey
                lda (ptr4),y
                cmp #$ff
                bne cod42
                lda ram24
                sub #1
                rts
+               lda ram24
                rts
sub22           tya
                pha
                lda arr23,x
                beq +
                sta ptr4+1
                lda arr22,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr34,x
+               lda arr25,x
                beq +
                sta ptr4+1
                lda arr24,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr35,x
+               lda arr27,x
                beq +
                sta ptr4+1
                lda arr26,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr36,x
+               lda arr29,x
                beq +
                sta ptr4+1
                lda arr28,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr37,x
+               lda arr31,x
                beq +
                sta ptr4+1
                lda arr30,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr38,x
+               pla
                tay
                rts
                ; end unaccessed chunk

sub23           ; $bfd8
                lda #0
                sta arr34,x
                sta arr35,x
                sta arr36,x
                sta arr37,x
                sta arr38,x
                rts

sub24           ; $bfea
                ;
                sta ram26
                sty ram24
                ldy #0
                add arr4-1
                sta ptr3+0
                tya
                adc arr4
                sta ptr3+1
                clc
                lda (ptr3),y            ; $bffd; read from idat4
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y            ; $c004; read from idat4
                adc ram4
                sta ptr4+1
                lda dat26,x
                tay
                lda jump_tbl2,y
                sta ptr3+0
                iny
                lda jump_tbl2,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)

jump_tbl2       ; jump table ($c01e); called by sub24
                ;
                dw icod27               ; 0
                dw icod27               ; 1
                dw sub25                ; 2
                dw sub25                ; 3
                dw icod27               ; 4
                dw sub25                ; 5

icod27          ; $c02a
                lda (ptr4),y            ; read from idat5
                sta ram26
                iny
                ror ram26
                bcc ++
                clc
                lda (ptr4),y            ; $c034; read from idat5
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y            ; $c03b; read from idat5
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr22,x
                bne +
                lda ptr3+1
                cmp arr23,x
                bne +
                jmp +++
+               lda ptr3+0
                sta arr22,x
                lda ptr3+1
                sta arr23,x
                lda #0
                sta arr34,x
                jmp +++
++              lda #0
                sta arr22,x
                sta arr23,x
+++             ror ram26
                bcc ++
                clc
                lda (ptr4),y            ; $c072; read from idat5
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y            ; $c079; read from idat5
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr24,x
                bne +
                lda ptr3+1
                cmp arr25,x
                bne +
                jmp +++
+               lda ptr3+0
                sta arr24,x
                lda ptr3+1
                sta arr25,x
                lda #0
                sta arr35,x
                jmp +++
++              lda #0
                sta arr24,x
                sta arr25,x
+++             ror ram26
                bcc ++
                clc
                lda (ptr4),y            ; $c0b0; read from idat5
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y            ; $c0b7; read from idat5
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr26,x
                bne +
                lda ptr3+1
                cmp arr27,x
                bne +
                jmp +++
+               lda ptr3+0
                sta arr26,x
                lda ptr3+1
                sta arr27,x
                lda #0
                sta arr36,x
                jmp +++
++              lda #0
                sta arr26,x
                sta arr27,x
+++             ror ram26
                bcc ++                  ; always taken
                ;
                ; unaccessed chunk start ($c0ed)
                clc
                lda (ptr4),y
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr28,x
                bne +
                lda ptr3+1
                cmp arr29,x
                bne +
                jmp +++
+               lda ptr3+0
                sta arr28,x
                lda ptr3+1
                sta arr29,x
                lda #0
                sta arr37,x
                jmp +++
                ; unaccessed chunk end ($c11f)
                ;
++              lda #0
                sta arr28,x
                sta arr29,x
+++             ror ram26
                bcc ++                  ; always taken
                ;
                ; unaccessed chunk start ($c12b)
                clc
                lda (ptr4),y
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr30,x
                bne +
                lda ptr3+1
                cmp arr31,x
                bne +
                jmp +++
+               lda ptr3+0
                sta arr30,x
                lda ptr3+1
                sta arr31,x
                lda #0
                sta arr38,x
                jmp +++
                ; unaccessed chunk end ($c15d)
                ;
++              lda #0
                sta arr30,x
                sta arr31,x
+++             ldy ram24
                rts

sub25           ; $c168; called by cod33, sub20, jmp_tbl2
                ;
                lda dat26,x
                tay
                lda jump_tbl3,y
                sta ptr3+0
                iny
                lda jump_tbl3,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)

jump_tbl3       ; jump table ($c17c); called by sub25
                dw icod29               ; 0
                dw icod30               ; 1
                dw icod28               ; 2
                dw icod30               ; 3
                dw icod29               ; 4
                dw icod28               ; 5

icod28          ; $c188
                rts

icod29          ; $c189
                lda arr16,x
                bmi ++                  ; never taken
                cmp #8
                bcc +
                lda #7
                sta arr16,x
                lda #$ff
                sta arr17,x
+               rts
                ;
                ; start unaccessed chunk ($c19d)
++              lda #0
                sta arr17,x
                sta arr16,x
                rts
icod30          lda arr16,x
                bmi ++
                cmp #$10
                bcc +
                lda #$0f
                sta arr16,x
                lda #$ff
                sta arr17,x
+               rts
++              lda #0
                sta arr17,x
                sta arr16,x
                rts
                ; end unaccessed chunk

sub26           ; $c1c3
                lda ram33
                bne ++
                stz snd_chn
                rts
                ;
sub27           ; $c1ce
                lda #%11000000
                sta joypad2
                lda #%01000000
                sta joypad2
                rts
                ;
++              lda arr4+2
                and #%00000001
                bne +
                jmp cod44
+               lda arr8
                beq cod43
                lda arr9
                asl a
                beq cod43
                and #%11110000
                sta ram24
                lda arr32
                beq cod43
                ora ram24
                tax
                lda math_tbl1,x
                sub arr51
                bpl +
                lda #0
+               bne +
                lda arr9
                beq +
                lda #1
+               pha
                lda arr33
                and #%00000011
                tax
                pla
                ora dat24,x
                ora #%00110000
                sta out_buffer+0
                lda arr19
                and #%11111000
                beq +
                copy #7, arr19
                copy #$ff, arr18
+               lda arr21
                beq +                   ; always taken
                ;
                ; start unaccessed chunk ($c233)
                and #%10000000
                beq cod44
                lda arr21
                sta out_buffer+1
                and #%01111111
                sta arr21
                jsr sub27
                copy arr18, out_buffer+2
                copy arr19, out_buffer+3
                jmp cod44
                ; end unaccessed chunk ($c251)
                ;
cod43           copy #$30, out_buffer+0
                jmp cod44
+               copy #8, out_buffer+1
                jsr sub27
                copy arr18, out_buffer+2
                copy arr19, out_buffer+3
cod44           lda arr4+2
                and #%00000010
                bne +
                jmp cod46
+               lda arr8+1
                beq cod45
                lda arr9+1
                asl a
                beq cod45
                and #%11110000
                sta ram24
                lda arr32+1
                beq cod45
                ora ram24
                tax
                lda math_tbl1,x
                sub arr51+1
                bpl +
                lda #0
+               bne +
                lda arr9+1
                beq +
                lda #1
+               pha
                lda arr33+1
                and #%00000011
                tax
                pla
                ora dat24,x
                ora #%00110000
                sta out_buffer+4
                lda arr19+1
                and #%11111000
                beq +
                copy #7,   arr19+1
                copy #$ff, arr18+1
+               lda arr21+1
                beq +                   ; always taken
                ;
                ; start unaccessed chunk ($c2c3)
                and #%10000000
                beq cod46
                lda arr21+1
                sta out_buffer+5
                and #%01111111
                sta arr21+1
                jsr sub27
                copy arr18+1, out_buffer+6
                copy arr19+1, out_buffer+7
                jmp cod46
                ; end unaccessed chunk ($c2e1)
                ;
cod45           copy #$30, out_buffer+4
                jmp cod46
                ;
+               copy #8, out_buffer+5
                jsr sub27
                copy arr18+1, out_buffer+6
                copy arr19+1, out_buffer+7
cod46           lda arr4+2
                and #%00000100
                beq +++
                lda arr32+2
                beq ++
                lda arr9+2
                beq ++
                lda arr8+2
                beq ++
                copy #$81, out_buffer+8
                lda arr19+2
                and #%11111000
                beq +
                copy #7, arr19+2
                copy #$ff, arr18+2
+               lda arr18+2
                sta out_buffer+10
                copy arr19+2, out_buffer+11
                jmp +++
++              stz out_buffer+8
+++             lda arr4+2
                and #%00001000
                beq rts18
                lda arr8+3
                beq ++
                lda arr9+3
                asl a
                beq ++
                and #%11110000
                sta ram24
                lda arr32+3
                beq ++
                ora ram24
                tax
                lda math_tbl1,x
                sub arr51+3
                bpl +
                lda #0
+               bne +
                lda arr9+3
                beq +
                lda #$01
+               ora #%00110000
                sta out_buffer+12
                stz out_buffer+13
                lda arr33+3
                ror a
                ror a
                and #%10000000
                sta ram24
                lda arr18+3
                and #%00001111
                eor #%00001111
                ora ram24
                sta out_buffer+14
                lda #0
                sta out_buffer+15
                beq rts18               ; unconditional
                ;
++              copy #$30, out_buffer+12  ; $c389
rts18           rts

dat24           hex 00 40 80 c0         ; $c38e

math_tbl1       ; $c392; some 2D look-up table; 256 bytes; read by sub26
                ;
                db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                db  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2
                db  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3
                db  0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4
                db  0, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5
                db  0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6
                db  0, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7
                db  0, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8
                db  0, 1, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9
                db  0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9,10
                db  0, 1, 1, 2, 2, 3, 4, 5, 5, 6, 7, 8, 8, 9,10,11
                db  0, 1, 1, 2, 3, 4, 4, 5, 6, 7, 8, 8, 9,10,11,12
                db  0, 1, 1, 2, 3, 4, 5, 6, 6, 7, 8, 9,10,11,12,13
                db  0, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
                db  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15

                hex 01 02 03 04 05      ; $c492

dat26           hex 00 00 00 00 00      ; $c497

note_freqs1     ; $c49c; note frequencies (96 values)
                ; 2**(-1/12) = ~0.944; 3228/3419 = ~0.944
                ; read by sub4
                ;
                dw 3419, 3228, 3046, 2875, 2714, 2561
                dw 2418, 2282, 2154, 2033, 1919, 1811
                dw 1709, 1613, 1523, 1437, 1356, 1280
                dw 1208, 1140, 1076, 1016,  959,  905
                dw  854,  806,  761,  718,  678,  640
                dw  604,  570,  538,  507,  479,  452
                dw  427,  403,  380,  359,  338,  319
                dw  301,  284,  268,  253,  239,  225
                dw  213,  201,  189,  179,  169,  159
                dw  150,  142,  134,  126,  119,  112
                dw  106,  100,   94,   89,   84,   79
                dw   75,   70,   66,   63,   59,   56
                dw   52,   49,   47,   44,   41,   39
                dw   37,   35,   33,   31,   29,   27
                dw   26,   24,   23,   21,   20,   19
                dw   18,   17,   16,   15,   14,   13

note_freqs2     ; $c55c; note frequencies (96 values)
                ; 2**(-1/12) = ~0.944; 2998/3176 = ~0.944
                ; read by sub4
                ;
                dw 3176, 2998, 2830, 2671, 2521, 2379
                dw 2246, 2120, 2001, 1888, 1782, 1682
                dw 1588, 1499, 1414, 1335, 1260, 1189
                dw 1122, 1059, 1000,  944,  891,  841
                dw  793,  749,  707,  667,  629,  594
                dw  561,  529,  499,  471,  445,  420
                dw  396,  374,  353,  333,  314,  297
                dw  280,  264,  249,  235,  222,  209
                dw  198,  186,  176,  166,  157,  148
                dw  139,  132,  124,  117,  110,  104
                dw   98,   93,   87,   82,   78,   73
                dw   69,   65,   62,   58,   55,   52
                dw   49,   46,   43,   41,   38,   36
                dw   34,   32,   30,   29,   27,   25
                dw   24,   22,   21,   20,   19,   18
                dw   17,   16,   15,   14,   13,   12

math_tbl2       ; $c61c; some 2D look-up table; 256 bytes
                ; read by sub18, sub19
                ;
                db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0
                db  0, 0, 0, 0, 0, 0, 1, 1, 1, 1,  1,  1,  1,  1,  1,  1
                db  0, 0, 0, 0, 1, 1, 1, 1, 2, 2,  2,  2,  2,  2,  2,  2
                db  0, 0, 0, 1, 1, 1, 2, 2, 2, 3,  3,  3,  3,  3,  3,  3
                db  0, 0, 0, 1, 1, 2, 2, 3, 3, 3,  4,  4,  4,  4,  4,  4
                db  0, 0, 1, 2, 2, 3, 3, 4, 4, 5,  5,  6,  6,  6,  6,  6
                db  0, 0, 1, 2, 3, 4, 5, 6, 7, 7,  8,  8,  9,  9,  9,  9
                db  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,  9, 10, 11, 11, 11, 11
                db  0, 1, 2, 4, 5, 6, 7, 8, 9,10, 11, 12, 12, 13, 13, 13
                db  0, 1, 3, 4, 6, 8, 9,10,12,13, 14, 14, 15, 16, 16, 16
                db  0, 2, 4, 6, 8,10,12,13,15,17, 18, 19, 20, 21, 21, 21
                db  0, 2, 5, 8,11,14,16,19,21,23, 24, 26, 27, 28, 29, 29
                db  0, 4, 8,12,16,20,24,27,31,34, 36, 38, 40, 42, 43, 43
                db  0, 6,12,18,24,30,35,40,45,49, 53, 56, 59, 61, 62, 63
                db  0, 9,18,27,36,45,53,60,67,74, 79, 84, 88, 91, 94, 95
                db  0,12,24,37,48,60,71,81,90,98,106,112,118,122,125,127
