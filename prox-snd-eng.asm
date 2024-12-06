; Proximity Shift - sound engine (Famitone2)

; --- Constants ---------------------------------------------------------------

region          equ $10  ; shared with main
ptr1            equ $5a
ram1            equ $5c
ram2            equ $5d
ram3            equ $5e
ram4            equ $5f
arr1            equ $60  ; 16 bytes
ram_shared      equ $70  ; shared with main
ram5            equ $71
ptr2            equ $72  ; 2 bytes
ram6            equ $74
ram7            equ $75
ram8            equ $76
ram9            equ $77
ptr3            equ $79  ; 2 bytes
ptr4            equ $7b  ; 2 bytes
ptr5            equ $7f  ; 2 bytes
ptr6            equ $81  ; 2 bytes
ram10           equ $83
ram11           equ $84
ram12           equ $85
ram13           equ $86
ram14           equ $87
ram15           equ $88

arr_shared1     equ $0300  ; shared with main; 256 bytes?

arr2            equ $04ea
ram16           equ $04f0
ram17           equ $04f1
arr3            equ $04f2
ram18           equ $04f7
ram19           equ $04f8
ram20           equ $04f9
ram21           equ $04fa
ram22           equ $04fb
ram23           equ $04fc
ram24           equ $04fd
ram25           equ $04fe
ram26           equ $04ff

arr_shared2     equ $0500  ; shared with main; 256 bytes?

sq1_vol         equ $4000
sq1_sweep       equ $4001
sq1_lo          equ $4002
sq1_hi          equ $4003
sq2_vol         equ $4004
sq2_sweep       equ $4005
sq2_lo          equ $4006
sq2_hi          equ $4007
tri_linear      equ $4008
misc1           equ $4009
tri_lo          equ $400a
tri_hi          equ $400b
noise_vol       equ $400c
misc2           equ $400d
noise_lo        equ $400e
noise_hi        equ $400f
snd_chn         equ $4015
joypad2         equ $4017

; --- Macros ------------------------------------------------------------------

macro add _operand
                ; ADC without carry
                clc
                adc _operand
endm
macro sub _operand
                ; SBC with carry
                sec
                sbc _operand
endm
macro copy _src, _dst
                ; use this only if A is ignored later
                lda _src
                sta _dst
endm

; -----------------------------------------------------------------------------

                base $9d37

sndeng_entry1   ; $9d37; an entry point from main program
                lda ram2
                ror a
                bcc +
                jsr sub8
                jmp ++
+               lda #$30
                sta arr1+0
                sta arr1+4
                sta arr1+12
                copy #0, arr1+8
++              ldx #0
                jsr sub3
                ldx #$0f
                jsr sub3
                ldx #$1e
                jsr sub3
                ldx #$2d
                jsr sub3
                copy arr1+0, sq1_vol
                copy arr1+1, sq1_sweep
                copy arr1+2, sq1_lo
                lda arr1+3
                cmp ram_shared
                beq +
                sta ram_shared
                sta sq1_hi
+               copy arr1+4, sq2_vol
                copy arr1+5, sq2_sweep
                copy arr1+6, sq2_lo
                lda arr1+7
                cmp ram5
                beq +
                sta ram5
                sta sq2_hi
+               copy arr1+8,  tri_linear
                copy arr1+9,  misc1
                copy arr1+10, tri_lo
                copy arr1+11, tri_hi
                copy arr1+12, noise_vol
                copy arr1+13, misc2
                copy arr1+14, noise_lo
                copy arr1+15, noise_hi
                rts

sndeng_entry2   ; $9dbf; an entry point from main program
                ldx #<dat3
                stx ram3
                ldx #>dat3
                stx ram4
                ldx region
                jsr sub4
                copy #1, ram2
                rts

sndeng_entry3   ; $9dd1; an entry point from main program
                ldx #<dat1
                stx ram3
                ldx #>dat1
                stx ram4
                lda #0
                ldx region
                jsr sub4
                copy #0, ram2
                rts

                ; $9de5: partially unaccessed
dat1            hex 0d 00 0d 00 0d 00 0d 00
                hex 00 10 0e b8 0b 0f 00 16
                hex 00 01 40 06 96 00 18 00
                hex 22 00 22 00 22 00 22 00
                hex 22 00 00 3f

                copy #0, ram2                ; 9e09 (unaccessed)
                rts                          ; unaccessed

sndeng_entry4   ; $9e0e; an entry point from main program
                copy #1, ram2
                rts

                lda ram2                     ; 9e13 (unaccessed)
                eor #%00000001               ; unaccessed
                sta ram2                     ; unaccessed
                rts                          ; unaccessed

sndeng_entry5   ; $9e1a; an entry point from main program
                pha
                ldx ram6
                inx
                txa
                and #%00000011
                sta ram6
                tax
                lda dat2,x
                tax
                pla
                jmp sub2

dat2            hex 00 0f 1e 2d              ; 9e2c
dat3            hex 3e 01 f3 00              ; 9e30
                hex 3e 01 3e 01 00 10 0e     ; 9e34
                hex b8 0b                    ; 9e3b (unaccessed)
                hex 02 ff 00 00 0c 00 03 ff  ; 9e3d
                hex 00 01 2a 26 22 03 ff 00  ; 9e45
                hex 01 31 2d 2a              ; 9e4d
                hex 01 ff 00 00 01           ; 9e51 (unaccessed)
                hex 06 ff 00                 ; 9e56
                hex 00                       ; 9e59 (unaccessed)
                hex 0c 0a 04 02 01 00 02 01  ; 9e5a
                hex 00 01 1a 1e 32           ; 9e62
                hex ff                       ; 9e67 (unaccessed)
                hex 00                       ; 9e68
                hex 00                       ; 9e69 (unaccessed)
                hex 0c 07 06 06 06 06 06 06  ; 9e6a
                hex 06                       ; 9e72
                hex 06 05 05 05 05 05 05 05  ; 9e73 (unaccessed)
                hex 05 04 04 04 04 04 04 04  ; 9e7b (unaccessed)
                hex 03 03 03 03 03 03 03 03  ; 9e83 (unaccessed)
                hex 02 02 02 02 02 02 02 02  ; 9e8b (unaccessed)
                hex 01 01 01 01 01 01 01 01  ; 9e93 (unaccessed)
                hex 01                       ; 9e9b (unaccessed)
                hex 09 ff 00                 ; 9e9c
                hex 00                       ; 9e9f (unaccessed)
                hex 0c 0a 08 06 05 04 03 02  ; 9ea0
                hex 01 05 04 00 01 19 1a 1b  ; 9ea8
                hex 1c 1e 09 08 00 01 06 0b  ; 9eb0
                hex 0b 0b 0b 0b 0b 0b 0d     ; 9eb8

                ; 9ebf-9f22: unaccessed data
                hex 29 ff 00 00 0a 0a 0a 0a  ; 9ebf
                hex 0a 0a 09 09 09 09 09 09  ; 9ec7
                hex 09 08 08 08 08 08 07 07  ; 9ecf
                hex 07 07 07 06 06 06 06 05  ; 9ed7
                hex 05 05 05 05 04 04 03 03  ; 9edf
                hex 02 02 01 01 00 09 00 00  ; 9ee7
                hex 00 fb fb fb 00 00 00 02  ; 9eef
                hex 02 02 09 00 00 00 fb fb  ; 9ef7
                hex fb 00 00 00 03 03 03 09  ; 9eff
                hex 00 00 00 03 03 03 07 07  ; 9f07
                hex 07 0e 0e 0e 0c 00 00 00  ; 9f0f
                hex fa fa fa fe fe fe 00 00  ; 9f17
                hex 00 03 03 03              ; 9f1f

                hex 09 01 0a 01 0d 01 10 01  ; 9f23
                hex 13 01 18 01 1d 01        ; 9f2b
                hex 22 01 29 01 30 01 37 01  ; 9f31 (unaccessed)
                hex 00 02 0d 00 02 13 00 02  ; 9f39
                hex 1a 00 03 26 00 30 00 03  ; 9f41
                hex 36 00 79 00 03 6c 00 82  ; 9f49
                hex 00                       ; 9f51
                hex 13 8f 00 bc 00 21 00     ; 9f52 (unaccessed)
                hex 13 8f 00 c9 00 21 00     ; 9f59 (unaccessed)
                hex 13 8f 00 d6 00 21 00     ; 9f60 (unaccessed)
                hex 13 8f 00 e3 00 21 00     ; 9f67 (unaccessed)
                hex 42 01                    ; 9f6e
                hex 49 01                    ; 9f70 (unaccessed)
                hex 50 01 0a 58 05 aa 00 f8  ; 9f72
                hex 0d 02 30 04 96 00        ; 9f7a (unaccessed)
                hex 64 01                    ; 9f80
                hex 6e 01 78 01 82 01 8c 01  ; 9f82
                hex 96 01 a0 01 aa 01 b4 01  ; 9f8a
                hex be 01 c8 01 7f 02 3c 03  ; 9f92
                hex 8d 03 01 04 03 04 ba 04  ; 9f9a
                hex 76 05 ca 05 01 04 c8 01  ; 9fa2
                hex 7f 02 3c 03 8d 03 01 04  ; 9faa
                hex 42 06 ee 06 a5 07 ed 07  ; 9fb2
                hex 01 04 66 08 1d 09 da 09  ; 9fba
                hex 8d 03 01 04 2b 0a e2 0a  ; 9fc2
                hex 9e 0b 8d 03 01 04 66 08  ; 9fca
                hex 1d 09 da 09 8d 03 01 04  ; 9fd2
                hex 2b 0a e2 0a 9e 0b 8d 03  ; 9fda
                hex 01 04 f6 0b 06 0c a6 0c  ; 9fe2
                hex cc 0c 01 04 01 04 1a 0d  ; 9fea
                hex 8f 0d 9f 0d 01 04 82 00  ; 9ff2
                hex e0 a4 02 f5 27 f3 00 f5  ; 9ffa
                hex 24 f3 27 f5 27 f3 24 f5  ; a002
                hex 2b f3 27 f5 30 f3 2b f5  ; a00a
                hex 2b f3 30 f5 27 f3 2b f5  ; a012
                hex 2b f3 27 f5 33 f3 2b f5  ; a01a
                hex 32 f3 33 f5 30 f3 32 f5  ; a022
                hex 2b f3 30 f5 27 f3 2b f5  ; a02a
                hex 26 f3 27 f5 24 f3 26 f5  ; a032
                hex 2b f3 24 f5 2c f3 2b f5  ; a03a
                hex 27 f3 2c f5 2b f3 27 f5  ; a042
                hex 2e f3 2b f5 30 f3 2e f5  ; a04a
                hex 2b f3 30 f5 2c f3 2b f5  ; a052
                hex 2e f3 2c f5 2c f3 2e f5  ; a05a
                hex 2b f3 2c f5 2c f3 2b f5  ; a062
                hex 2e f3 2c f5 30 f3 2e f5  ; a06a
                hex 33 f3 30 f5 32 f3 33 f5  ; a072
                hex 30 f3 32 f5 2e f3 30 f5  ; a07a
                hex 2c f3 2e f5 2b f3 2c f5  ; a082
                hex 2e f3 2b f5 2c f3 2e f5  ; a08a
                hex 2b f3 2c f5 29 f3 2b f5  ; a092
                hex 27 f3 29 f5 26 f3 27 f5  ; a09a
                hex 1f f3 26 f5 2b f3 1f f5  ; a0a2
                hex 2f 84 f3 2b 00 82 00 e0  ; a0aa
                hex a4 00 f2 2b 27 a4 01 1f  ; a0b2
                hex 22 a4 00 f3 2b 27 a4 01  ; a0ba
                hex 1f 22 a4 00 f4 2b 27 a4  ; a0c2
                hex 01 1f 22 a4 00 2b 27 a4  ; a0ca
                hex 02 1f 22 2b 27 a4 01 1f  ; a0d2
                hex 22 a4 00 f3 2b 27 a4 01  ; a0da
                hex 1f 22 a4 00 f2 2b 27 a4  ; a0e2
                hex 01 1f 22 a4 00 2b 27 a4  ; a0ea
                hex 01 1f 22 a4 00 f2 2b 27  ; a0f2
                hex a4 01 1f 22 a4 00 f3 2b  ; a0fa
                hex 27 a4 02 1f 22 2b 27 a4  ; a102
                hex 01 1f 22 a4 00 f2 2c 29  ; a10a
                hex a4 01 20 24 a4 00 f3 2c  ; a112
                hex 29 a4 01 20 24 a4 00 f4  ; a11a
                hex 2c 29 a4 02 20 24 2c 29  ; a122
                hex a4 01 20                 ; a12a
                hex 24 a4 00 f3 2c 29 a4 01  ; a12d
                hex 20 24 a4 00 f2 2c 29 a4  ; a135
                hex 01 20 24 a4 00 2c 29 a4  ; a13d
                hex 01 20 24 a4 00 f2 2c 29  ; a145
                hex a4 01 20 24 a4 00 f3 2c  ; a14d
                hex 29 a4 02 20 24 f4 2c 29  ; a155
                hex a4 01 20 24 a4 00 f2 2c  ; a15d
                hex 29 a4 01 20 84 24 00 e2  ; a165
                hex 18 04 7f 00 18 02 7f 00  ; a16d
                hex 18 01 e3 24 07 9c 55 00  ; a175
                hex 02 7f 00 e2 9c 00 18 04  ; a17d
                hex 7f 00 24 02 7f 00 e1 26  ; a185
                hex 01 e3 27 03 e2 24 03 18  ; a18d
                hex 04 7f 00 18 02 7f 00 18  ; a195
                hex 01 e3 24 07 9c 55 00 02  ; a19d
                hex 7f 00 e2 9c 00 18 04 7f  ; a1a5
                hex 00 e3 24 02 7f 00 e1 26  ; a1ad
                hex 01 e3 27 03 24 01 24 01  ; a1b5
                hex 82 01 e4 fa 1a f5 11 fa  ; a1bd
                hex 1a f5 11 e5 fa 1a e4 f5  ; a1c5
                hex 11 e6 ff 1a e4 f5 11 fa  ; a1cd
                hex 1a f5 11 e5 fa 1a e4 f5  ; a1d5
                hex 11 fa 1a f5 11 fa 1a f5  ; a1dd
                hex 11 e5 fa 1a e4 f5 11 e6  ; a1e5
                hex ff 1a e4 f5 11 e5 fa 1a  ; a1ed
                hex e4 f5 11 fa 1a f5 11 fa  ; a1f5
                hex 1a f5 11 e5 fa 1a e4 f5  ; a1fd
                hex 11 e6 ff 1a e4 f5 11 fa  ; a205
                hex 1a f5 11 e5 fa 1a e4 f5  ; a20d
                hex 11 fa 1a f5 11 fa 1a e6  ; a215
                hex ff 1a e5 fa 1a e4 fa 1a  ; a21d
                hex e6 ff 1a e4 1a e6 ff 1a  ; a225
                hex 84 ff 1a 01 00 57 82 00  ; a22d
                hex e0 a4 02 f5 27 f3 00 f5  ; a235
                hex 24 f3 27 f5 27 f3 24 f5  ; a23d
                hex 2b f3 27 f5 30 f3 2b f5  ; a245
                hex 2b f3 30 f5 30 f3 2b f5  ; a24d
                hex 33 f3 30 f5 37 f3 33 f5  ; a255
                hex 35 f3 37 f5 33 f3 35 f5  ; a25d
                hex 35 f3 33 f5 33 f3 35 f5  ; a265
                hex 32 f3 33 f5 30 f3 32 f5  ; a26d
                hex 2b f3 30 f5 29 f3 2b f5  ; a275
                hex 2b f3 29 f5 30 f3 2b f5  ; a27d
                hex 2e f3 30 f5 30 f3 2e f5  ; a285
                hex 2b f3 30 f5 2c f3 2b f5  ; a28d
                hex 2b f3 2c f5 2c f3 2b f5  ; a295
                hex 30 f3 2c f5 38 f3 30 f5  ; a29d
                hex 33 f3 38 f5 32 f3 33 f5  ; a2a5
                hex 38 f3 32 f5 35 f3 38 f5  ; a2ad
                hex 32 f3 35 f5 30 f3 32 f5  ; a2b5
                hex 32 f3 30 f5 30 f3 32 f5  ; a2bd
                hex 2f f3 30 f5 2b f3 2f f5  ; a2c5
                hex 30 f3 2b f5 2f f3 30 f5  ; a2cd
                hex 26 f3 2f f5 30 f3 26 f5  ; a2d5
                hex 2f f3 30 f5 29 f3 2f f5  ; a2dd
                hex 26 84 f3 29 00 82 00 e0  ; a2e5
                hex a4 00 f2 2b 27 a4 01 1f  ; a2ed
                hex 22 a4 00 f3 2b 27 a4 01  ; a2f5
                hex 1f 22 a4 00 f4 2b 27 a4  ; a2fd
                hex 01 1f 22 a4 00 2b 27 a4  ; a305
                hex 02 1f 22 2b 27 a4 01 1f  ; a30d
                hex 22 a4 00 f3 2b 27 a4 01  ; a315
                hex 1f 22 a4 00 f2 2b 27 a4  ; a31d
                hex 01 1f 22 a4 00 2b 27 a4  ; a325
                hex 01 1f 22 a4 00 f2 2b 27  ; a32d
                hex a4 01 1f 22 a4 00 f3 2b  ; a335
                hex 27 a4 02 1f 22 2b 27 a4  ; a33d
                hex 01 1f 22 a4 00 f2 2c 29  ; a345
                hex a4 01 20 24 a4 00 f3 2c  ; a34d
                hex 29 a4 01 20 24 a4 00 f4  ; a355
                hex 2c 29 a4 02 20 24 2c 29  ; a35d
                hex a4 01 20 24 a4 00 f3 2c  ; a365
                hex 29 a4 01 20 24 a4 00 f2  ; a36d
                hex 2c 29 a4 01 20 24 a4 00  ; a375
                hex 2c 2b a4 01 26 23 a4 00  ; a37d
                hex f2 2c 2b a4 01 26 23 a4  ; a385
                hex 00 f3 2c 2b a4 02 26 23  ; a38d
                hex f4 2c 2b a4 01 26 23 a4  ; a395
                hex 00 27 26 a4 01 23 84 1f  ; a39d
                hex 00 e2 18 04 7f 00 18 02  ; a3a5
                hex 7f 00 18 01 e3 24 07 9c  ; a3ad
                hex 55 00 02 7f 00 e2 9c 00  ; a3b5
                hex 18 01 18 02 7f 00 24 02  ; a3bd
                hex 7f 00 e1 26 01 e3 27 03  ; a3c5
                hex e2 24 03 14 04 7f 00 14  ; a3cd
                hex 02 7f 00 e1 18 01 e3 20  ; a3d5
                hex 07 9c 55 00 02 7f 00 e2  ; a3dd
                hex 9c 00 1f 01 1f 03 1f 01  ; a3e5
                hex e1 2c 01 2e 00 2c 00 e2  ; a3ed
                hex 2b 05 e3 1f 01 82 01 e4  ; a3f5
                hex fa 1a f5 11 fa 1a f5 11  ; a3fd
                hex e5 fa 1a e4 f5 11 e6 ff  ; a405
                hex 1a e4 f5 11 fa 1a f5 11  ; a40d
                hex e5 fa 1a e4 f5 11 fa 1a  ; a415
                hex f5 11 fa 1a f5 11 e5 fa  ; a41d
                hex 1a e4 f5 11 e6 ff 1a e4  ; a425
                hex f5 11 e5 fa 1a e4 f5 11  ; a42d
                hex fa 1a f5 11 fa 1a f5 11  ; a435
                hex e5 fa 1a e4 f5 11 e6 ff  ; a43d
                hex 1a e4 f5 11 fa 1a f5 11  ; a445
                hex e5 fa 1a e4 f5 11 fa 1a  ; a44d
                hex f5 11 fa 1a ff 1a fa 1a  ; a455
                hex 84 fa 1a 00 fa 1a 00 82  ; a45d
                hex 01 e6 ff 1a e4 1a ff 1a  ; a465
                hex 84 e6 ff 1a 01 82 00 e0  ; a46d
                hex a4 02 f5 27 f3 00 f5 24  ; a475
                hex f3 27 f5 27 f3 24 f5 2b  ; a47d
                hex f3 27 f5 30 f3 2b f5 2b  ; a485
                hex f3 30 f5 30 f3 2b f5 33  ; a48d
                hex f3 30 f5 37 f3 33 f5 35  ; a495
                hex f3 37 f5 33 f3 35 f5 35  ; a49d
                hex f3 33 f5 33 f3 35 f5 32  ; a4a5
                hex f3 33 f5 30 f3 32 f5 32  ; a4ad
                hex f3 30 f5 30 f3 32 f5 2e  ; a4b5
                hex f3 30 f5 2b f3 2e f5 27  ; a4bd
                hex f3 2b f5 24 f3 27 f5 27  ; a4c5
                hex f3 24 f5 2c f3 27 f5 2e  ; a4cd
                hex f3 2c f5 30 f3 2e f5 2c  ; a4d5
                hex f3 30 f5 33 f3 2c f5 38  ; a4dd
                hex f3 33 f5 3a f3 38 f5 3c  ; a4e5
                hex f3 3a f5 38 f3 3c f5 2c  ; a4ed
                hex f3 38 f5 33 f3 2c f5 30  ; a4f5
                hex f3 33 f5 2e f3 30 f5 29  ; a4fd
                hex f3 2e f5 2e f3 29 f5 30  ; a505
                hex f3 2e f5 32 f3 30 f5 35  ; a50d
                hex f3 32 84 f5 2c 03 f5 29  ; a515
                hex 03 82 00 e0 a4 00 f2 2b  ; a51d
                hex 27 a4 01 1f 22 a4 00 f3  ; a525
                hex 2b 27 a4 01 1f 22 a4 00  ; a52d
                hex f4 2b 27 a4 01 1f 22 a4  ; a535
                hex 00 2b 27 a4 02 1f 22 2b  ; a53d
                hex 27 a4 01 1f 22 a4 00 f3  ; a545
                hex 2b 27 a4 01 1f 22 a4 00  ; a54d
                hex 2c 29 a4 01 20 24 a4 00  ; a555
                hex 2c 29 a4 01 20 24 a4 00  ; a55d
                hex 2c 29 a4 01 20 24 a4 00  ; a565
                hex 2c 29 a4 02 20 24 2c 29  ; a56d
                hex a4 01 20 24 a4 00 2c 27  ; a575
                hex a4 01 20 24 a4 00 f3 2c  ; a57d
                hex 27 a4 01 20 24 a4 00 f4  ; a585
                hex 2c 27 a4 02 20 24 2c 27  ; a58d
                hex a4 01 20 24 a4 00 f3 2c  ; a595
                hex 27 a4 01 20 24 a4 00 f2  ; a59d
                hex 2c 27 a4 01 20 24 a4 00  ; a5a5
                hex 26 22 a4 01 1d 22 a4 00  ; a5ad
                hex f2 26 22 a4 01 1d 22 a4  ; a5b5
                hex 00 f3 26 22 a4 02 1d 22  ; a5bd
                hex 82 01 f4 26 a4 01 00 a4  ; a5c5
                hex 00 f4 26 84 a4 01 00 01  ; a5cd
                hex e2 18 04 7f 00 18 02 7f  ; a5d5
                hex 00 18 01 e3 24 07 9c 55  ; a5dd
                hex 00 02 7f 00 e2 9c 00 11  ; a5e5
                hex 04 7f 00 29 03 e1 2b 01  ; a5ed
                hex e3 2c 03 e1 29 03 e2 14  ; a5f5
                hex 04 7f 00 14 03 e1 1b 01  ; a5fd
                hex e3 2c 05 96 03 00 05 e2  ; a605
                hex 92 22 05 2e 03 e1 20 00  ; a60d
                hex 22 00 e3 23 03 e2 17 03  ; a615
                hex 82 01 e4 fa 1a f5 11 fa  ; a61d
                hex 1a f5 11 e5 fa 1a e4 f5  ; a625
                hex 11 e6 ff 1a e4 f5 11 fa  ; a62d
                hex 1a f5 11 e5 fa 1a e4 f5  ; a635
                hex 11 fa 1a f5 11 fa 1a f5  ; a63d
                hex 11 e5 fa 1a e4 f5 11 e6  ; a645
                hex ff 1a e4 f5 11 e5 fa 1a  ; a64d
                hex e4 f5 11 fa 1a f5 11 fa  ; a655
                hex 1a f5 11 e5 fa 1a e4 f5  ; a65d
                hex 11 e6 ff 1a e4 f5 11 fa  ; a665
                hex 1a f5 11 e5 fa 1a e4 f5  ; a66d
                hex 11 fa 1a f5 11 fa 1a ff  ; a675
                hex 1a fa 1a 84 fa 1a 00 fa  ; a67d
                hex 1a 00 82 01 e6 ff 1a e4  ; a685
                hex 1a e6 ff 1a 84 e4 ff 1a  ; a68d
                hex 01 82 00 e0 a4 00 f5 21  ; a695
                hex f3 00 f5 1e f3 21 f5 21  ; a69d
                hex f3 1e f5 25 f3 21 f5 2a  ; a6a5
                hex f3 25 f5 25 f3 2a f5 21  ; a6ad
                hex f3 25 f5 25 f3 21 f5 2d  ; a6b5
                hex f3 25 f5 2c f3 2d f5 2a  ; a6bd
                hex f3 2c f5 25 f3 2a f5 21  ; a6c5
                hex f3 25 f5 20 f3 21 f5 1e  ; a6cd
                hex f3 20 f5 25 f3 1e f5 26  ; a6d5
                hex f3 25 f5 21 f3 26 f5 25  ; a6dd
                hex f3 21 f5 28 f3 25 f5 2a  ; a6e5
                hex f3 28 f5 25 f3 2a f5 26  ; a6ed
                hex f3 25 f5 28 f3 26 f5 26  ; a6f5
                hex f3 28 f5 25 f3 26 f5 26  ; a6fd
                hex f3 25 f5 28 f3 26 f5 2a  ; a705
                hex f3 28 f5 2d f3 2a f5 2c  ; a70d
                hex f3 2d f5 2a f3 2c f5 28  ; a715
                hex f3 2a f5 26 f3 28 f5 25  ; a71d
                hex f3 26 f5 28 f3 25 f5 26  ; a725
                hex f3 28 f5 25 f3 26 f5 23  ; a72d
                hex f3 25 f5 21 f3 23 f5 20  ; a735
                hex f3 21 f5 19 f3 20 f5 25  ; a73d
                hex f3 19 f5 29 84 f3 25 00  ; a745
                hex 82 00 e0 a4 00 f2 25 21  ; a74d
                hex a4 01 19 1c a4 00 f3 25  ; a755
                hex 21 a4 01 19 1c a4 00 f4  ; a75d
                hex 25 21 a4 01 19 1c a4 00  ; a765
                hex 25 21 a4 02 19 1c 25 21  ; a76d
                hex a4 01 19 1c a4 00 f3 25  ; a775
                hex 21 a4 01 19 1c a4 00 f2  ; a77d
                hex 25 21 a4 01 19 1c a4 00  ; a785
                hex 25 21 a4 01 19 1c a4 00  ; a78d
                hex f2 25 21 a4 01 19 1c a4  ; a795
                hex 00 f3 25 21 a4 02 19 1c  ; a79d
                hex 25 21 a4 01 19 1c a4 00  ; a7a5
                hex f2 26 23 a4 01 1a 1e a4  ; a7ad
                hex 00 f3 26 23 a4 01 1a 1e  ; a7b5
                hex a4 00 f4 26 23 a4 02 1a  ; a7bd
                hex 1e 26 23 a4 01 1a 1e a4  ; a7c5
                hex 00 f3 26 23 a4 01 1a 1e  ; a7cd
                hex a4 00 f2 26 23 a4 01 1a  ; a7d5
                hex 1e a4 00 26 23 a4 01 1a  ; a7dd
                hex 1e a4 00 f2 26 23 a4 01  ; a7e5
                hex 1a 1e a4 00 f3 26 23 a4  ; a7ed
                hex 02 1a 1e f4 26 23 a4 01  ; a7f5
                hex 1a 1e a4 00 f2 26 23 a4  ; a7fd
                hex 01 1a 84 1e 00 e2 12 04  ; a805
                hex 7f 00 12 02 7f 00 12 01  ; a80d
                hex e3 1e 07 9c 55 00 02 7f  ; a815
                hex 00 e2 9c 00 12 04 7f 00  ; a81d
                hex 1e 02 7f 00 e1 20 01 e3  ; a825
                hex 21 03 e2 1e 03 12 04 7f  ; a82d
                hex 00 12 02 7f 00 12 01 e3  ; a835
                hex 1e 07 9c 55 00 02 7f 00  ; a83d
                hex e2 9c 00 12 04 7f 00 e3  ; a845
                hex 1e 02 7f 00 e1 20 01 e3  ; a84d
                hex 21 03 1e 01 1e 01 82 00  ; a855
                hex e0 a4 00 f5 21 f3 00 f5  ; a85d
                hex 1e f3 21 f5 21 f3 1e f5  ; a865
                hex 25 f3 21 f5 2a f3 25 f5  ; a86d
                hex 25 f3 2a f5 21 f3 25 f5  ; a875
                hex 25 f3 21 f5 2d f3 25 f5  ; a87d
                hex 2c f3 2d f5 2a f3 2c f5  ; a885
                hex 25 f3 2a f5 21 f3 25 f5  ; a88d
                hex 20 f3 21 f5 1e f3 20 f5  ; a895
                hex 25 f3 1e f5 26 f3 25 f5  ; a89d
                hex 21 f3 26 f5 25 f3 21 f5  ; a8a5
                hex 28 f3 25 f5 2a f3 28 f5  ; a8ad
                hex 25 f3 2a f5 27 f3 25 f5  ; a8b5
                hex 2a f3 27 f5 27 f3 2a f5  ; a8bd
                hex 23 f3 27 f5 21 f3 23 f5  ; a8c5
                hex 20 f3 21 f5 1e f3 20 f5  ; a8cd
                hex 1b f3 1e f5 27 f3 1b f5  ; a8d5
                hex 23 f3 27 f5 2f f3 23 f5  ; a8dd
                hex 2a f3 2f f5 26 f3 2a f5  ; a8e5
                hex 28 f3 26 f5 26 f3 28 f5  ; a8ed
                hex 25 f3 26 f5 23 f3 25 f5  ; a8f5
                hex 2f f3 23 f5 2d f3 2f f5  ; a8fd
                hex 2c f3 2d f5 2a f3 2c f5  ; a905
                hex 25 84 f3 2a 00 82 00 e0  ; a90d
                hex a4 00 f2 25 21 a4 01 19  ; a915
                hex 1c a4 00 f3 25 21 a4 01  ; a91d
                hex 19 1c a4 00 f4 25 21 a4  ; a925
                hex 01 19 1c a4 00 25 21 a4  ; a92d
                hex 02 19 1c 25 21 a4 01 19  ; a935
                hex 1c a4 00 f3 25 21 a4 01  ; a93d
                hex 19 1c a4 00 f2 26 23 a4  ; a945
                hex 01 1e 19 a4 00 26 23 a4  ; a94d
                hex 01 1e 19 a4 00 f2 26 23  ; a955
                hex a4 01 1e 19 a4 00 f3 26  ; a95d
                hex 23 a4 02 1e 19 26 23 a4  ; a965
                hex 01 1e 19 a4 00 27 23 a4  ; a96d
                hex 01 1e 1b a4 00 f3 27 23  ; a975
                hex a4 01 1e 1b a4 00 f4 27  ; a97d
                hex 23 a4 02 1e 1b 27 23 a4  ; a985
                hex 01 1e 1b a4 00 f3 27 23  ; a98d
                hex a4 01 1e 1b a4 00 f2 27  ; a995
                hex 23 a4 01 1e 1b a4 00 26  ; a99d
                hex 21 a4 01 1e 1a a4 00 f2  ; a9a5
                hex 26 21 a4 01 1e 1a a4 00  ; a9ad
                hex f3 26 21 a4 02 1e 1a f4  ; a9b5
                hex 29 25 a4 01 20 1d a4 00  ; a9bd
                hex f2 29 25 a4 01 20 84 1d  ; a9c5
                hex 00 e2 12 04 7f 00 12 02  ; a9cd
                hex 7f 00 12 01 e3 1e 07 9c  ; a9d5
                hex 55 96 05 00 02 7f 00 e2  ; a9dd
                hex 9c 00 92 12 04 7f 00 1e  ; a9e5
                hex 02 7f 00 e1 20 01 e3 21  ; a9ed
                hex 03 e2 1e 03 0f 04 7f 00  ; a9f5
                hex 0f 02 7f 00 0f 01 e3 27  ; a9fd
                hex 07 9c 55 96 05 00 02 7f  ; aa05
                hex 00 e2 9c 00 92 98 20 0e  ; aa0d
                hex 03 82 01 26 e3 00 e1 23  ; aa15
                hex 24 84 e3 25 03 19 01 00  ; aa1d
                hex 01 e0 f5 29 07 9c 55 00  ; aa25
                hex 07 b2 01 00 2f 9c 00 00  ; aa2d
                hex 17 82 00 e0 a4 00 f2 29  ; aa35
                hex 25 a4 01 20 23 a4 00 f3  ; aa3d
                hex 29 25 a4 01 1d 23 a4 00  ; aa45
                hex f4 29 25 a4 01 20 23 a4  ; aa4d
                hex 00 29 25 a4 02 1d 23 29  ; aa55
                hex 25 a4 01 20 23 a4 00 f3  ; aa5d
                hex 29 25 a4 01 1d 23 a4 00  ; aa65
                hex f2 29 25 a4 01 20 23 a4  ; aa6d
                hex 00 29 25 a4 01 1d 23 a4  ; aa75
                hex 00 f2 29 25 a4 01 20 23  ; aa7d
                hex a4 00 f3 29 25 a4 02 1d  ; aa85
                hex 23 29 25 a4 01 20 23 a4  ; aa8d
                hex 00 29 25 a4 01 1d 23 a4  ; aa95
                hex 00 f3 29 25 a4 01 20 23  ; aa9d
                hex a4 00 f4 29 25 a4 02 1d  ; aaa5
                hex 23 29 25 a4 01 1d 23 a4  ; aaad
                hex 00 f3 29 25 a4 01 1d 23  ; aab5
                hex a4 00 f2 29 25 a4 01 1d  ; aabd
                hex 23 a4 00 29 f1 25 a4 01  ; aac5
                hex 1d 23 f0 29 25 1d 84 23  ; aacd
                hex 0c e2 0d 04 0d 03 7f 07  ; aad5
                hex 25 03 19 00 7f 10 e3 25  ; aadd
                hex 01 e1 23 03 24 01 e3 31  ; aae5
                hex 02 7f 00 e2 25 01 7f 0b  ; aaed
                hex 19 03 e3 0d 01 7f 10 e4  ; aaf5
                hex fa 1a 02 f7 1a 01 fa 1a  ; aafd
                hex 03 f7 1a 01 fa 1a 03 f7  ; ab05
                hex 1a 01 fa 1a 03 f7 1a 01  ; ab0d
                hex fa 1a 03 f7 1a 01 fa 1a  ; ab15
                hex 03 f7 1a 01 fa 1a 03 e6  ; ab1d
                hex f7 1a 01 e4 fa 1a 03 f7  ; ab25
                hex 1a 01 e6 fa 1a 03 e4 f7  ; ab2d
                hex 1a 01 fa 1a 03 f7 1a 01  ; ab35
                hex fa 1a 03 f7 1a 01 fa 1a  ; ab3d
                hex 03 e6 fa 1a 12 00 1b 82  ; ab45
                hex 00 e0 a4 00 f1 2c 2b a4  ; ab4d
                hex 01 26 23 a4 00 2c 2b a4  ; ab55
                hex 01 26 23 a4 00 2c 2b a4  ; ab5d
                hex 01 26 23 a4 00 2c 2b a4  ; ab65
                hex 02 26 23 27 26 a4 01 23  ; ab6d
                hex 1f a4 00 f3 2c 2b a4 01  ; ab75
                hex 26 23 a4 00              ; ab7d
                hex f2 2c 2b a4 01 26 23 a4  ; ab81
                hex 00 f3 2c 2b a4 01 26 23  ; ab89
                hex a4 00 f4 2c 2b a4 01 26  ; ab91
                hex 23 a4 00 27 26 a4 02 23  ; ab99
                hex 1f 2c 2b a4 01 26 23 a4  ; aba1
                hex 00 f3 2c 2b a4 01 26 23  ; aba9
                hex 2c 2b 26 23 2c 2b 26 23  ; abb1 (unaccessed)
                hex 27 26 23 84 1f 00        ; abb9 (unaccessed)
                hex 00 3f 82 01 e2 23 e0 1f  ; abbf
                hex e3 1a e0 18 17 84 13 0d  ; abc7
                hex e0 b2 00 92 f1 1d 01 b2  ; abcf
                hex 10 00 05 b2 01 00 03 b2  ; abd7
                hex 00 f1 19 0f 9a 03 f1 19  ; abdf
                hex 03 b2 10 00 07 b2 01 00  ; abe7
                hex 07 b2 00 00 07 82 00 92  ; abef
                hex b2 00 f1 1d f0 20 f1 1d  ; abf7
                hex f0 20 f1 1d f0 20 f2 1d  ; abff
                hex f1 20 f2 1d f1 20 f2 1d  ; ac07
                hex f1 20 f3 1d f2 20 f3 1d  ; ac0f
                hex f2 20 f3 1d f2 20 f4 1d  ; ac17
                hex 8c 01 f3 20              ; ac1f

                ; ac23-ad07: unaccessed data
                hex 84 e5 fa 1a 0b fc 0d 06  ; ac23
                hex 0e 10 0e 21 0e 23 0e 5d  ; ac2b
                hex 0e 21 0e 9c 0e 21 0e a8  ; ac33
                hex 0e 5d 0e 21 0e 82 08 e7  ; ac3b
                hex 2e e8 2e e7 2e e8 2e 84  ; ac43
                hex e7 2e 05 e8 2e 05 00 2f  ; ac4b
                hex e2 22 05 e3 1d 02 e2 92  ; ac53
                hex 16 05 e1 98 44 25 02 e3  ; ac5b
                hex 92 2e 02 9c 25 00 05 e2  ; ac63
                hex 9c 00 22 02 e3 00 03 96  ; ac6b
                hex 1f 00 01 e2 00 01 82 00  ; ac73
                hex 7f 92 25 e1 00 00 84 e3  ; ac7b
                hex 24 02 e2 25 00 e1 00 00  ; ac83
                hex 00 00 82 02 e5 ff 11 e4  ; ac8b
                hex f5 14 e6 fa 11 e5 ff 14  ; ac93
                hex e4 f6 11 e5 fa 14 e6 ff  ; ac9b
                hex 11 e4 f5 14 11 e5 ff 14  ; aca3
                hex e6 11 e4 f5 14 e5 ff 11  ; acab
                hex 84 e4 f5 14 00 f3 14 00  ; acb3
                hex f5 14 00 e6 ff 14 02 e4  ; acbb
                hex f5 14 00 f3 14 00 f5 14  ; acc3
                hex 00 e9 27 08 ea 30 08 e9  ; accb
                hex 27 08 ea 30 14 e2 27 03  ; acd3
                hex 96 0f 00 01 e3 92 0f 02  ; acdb
                hex e2 22 05 1e 02 e3 25 03  ; ace3
                hex 9c 55 00 04 e2 9c 00 24  ; aceb
                hex 02 e3 00 01 9c 55 00 03  ; acf3
                hex 82 02 9c 00 7f e2 1d e3  ; acfb
                hex 25 84 e1 24 02           ; ad03

                hex 0e ad                    ; ad08
                hex 18 ad 22 ad 2c ad        ; ad0a (unaccessed)
                hex 7a ad f6 ad              ; ad10

                ; ad14-ad79: unaccessed data
                hex b0 ad 20 b0 53 ad 95 ad  ; ad14
                hex b2 ae b0 ad 77 b0 2c ad  ; ad1c
                hex 7a ad 69 af b0 ad c3 b0  ; ad24
                hex 83 ba 84 df 85 01 89 39  ; ad2c
                hex 8a 0d 01 84 3a 85 02 89  ; ad34
                hex 35 8a 01 01 84 80 89 34  ; ad3c
                hex 01 84 74 85 04 89 33 01  ; ad44
                hex 84 9d 85 05 89 31 00 83  ; ad4c
                hex ba 84 bd 85 01 89 39 8a  ; ad54
                hex 0d 01 84 11 85 02 89 35  ; ad5c
                hex 8a 01 01 84 52 89 34 01  ; ad64
                hex 84 23 85 04 89 33 01 84  ; ad6c
                hex 37 85 05 89 31 00        ; ad74

                hex 83 b5 84 7e 85 00 89 34  ; ad7a
                hex 8a 80 01 83 b3 84 3f 01  ; ad82
                hex 83 b2 89 32 01 83 b1 89  ; ad8a
                hex 30 02 00                 ; ad92

                ; ad95-adf5: unaccessed data
                hex 83 b5 84 75 85 00 89 34  ; ad95
                hex 8a 80 01 83 b3 84 3a 01  ; ad9d
                hex 83 b2 89 32 01 83 b1 89  ; ada5
                hex 30 02 00 89 3f 8a 03 01  ; adad
                hex 89 3e 01 8a 05 01 89 3d  ; adb5
                hex 01 8a 07 01 89 3c 01 8a  ; adbd
                hex 08 01 89 3b 01 8a 0a 01  ; adc5
                hex 89 3a 02 89 39 8a 0c 02  ; adcd
                hex 89 38 8a 0b 02 89 37 02  ; add5
                hex 89 36 02 89 35 01 8a 0c  ; addd
                hex 01 89 34 01 8a 0b 01 89  ; ade5
                hex 33 02 89 32 02 89 31 04  ; aded
                hex 00                       ; adf5

                hex 80 be 81 eb 82 01 83 38  ; adf6
                hex 84 a8                    ; adfe
                hex 85 06 89 3e 8a 0e 01 80  ; ae00
                hex bd 81 2b 82 02 01 81 6b  ; ae08
                hex 83 37 8a 09 01 80 bc 81  ; ae10
                hex ab 01 80 bb 81 eb 89 3d  ; ae18
                hex 8a 03 01 81 2b 82 03 83  ; ae20
                hex 36 01 80 ba 81 96 01 81  ; ae28
                hex d6 01 80 b9 81 16 82 04  ; ae30
                hex 83 35 89 3c 01 80 b8 81  ; ae38
                hex 56 01 81 96 83 34 01 80  ; ae40
                hex b7 81 d6 01 80 b6 81 16  ; ae48
                hex 82 05 89 3b 01 81 56 83  ; ae50
                hex 33 01 80 b5 81 96 01 81  ; ae58
                hex d6 01 80 b4 81 16 82 06  ; ae60
                hex 83 32 89 3a 8a 09 01 80  ; ae68
                hex b3 81 56 01 81 96 83 31  ; ae70
                hex 8a 03 01 80 b2 81 d6 01  ; ae78
                hex 80 b1 81 16 82 07 89 39  ; ae80
                hex 01 81 56 01 81 96 01 80  ; ae88
                hex 30 83 30 01 89 38 04 89  ; ae90
                hex 37 04 89 36 8a 09 02 8a  ; ae98
                hex 03 02 89 35 04 89 34 04  ; aea0
                hex 89 33 04 89 32 04 89 31  ; aea8
                hex 04 00                    ; aeb0

                ; aeb2-b10e: unaccessed data
                hex 80 be 81 cc 82 01 83 38  ; aeb2
                hex 84 2f 85 06 89 3e 8a 0e  ; aeba
                hex 01 80 bd 81 0c 82 02 01  ; aec2
                hex 81 4c 83 37 8a 09 01 80  ; aeca
                hex bc 81 8c 01 80 bb 81 cc  ; aed2
                hex 89 3d 8a 03 01 81 59 82  ; aeda
                hex 03 83 36 01 80 ba 81 99  ; aee2
                hex 01 81 d9 01 80 b9 81 19  ; aeea
                hex 82 04 83 35 89 3c 01 80  ; aef2
                hex b8 81 59 01 81 99 83 34  ; aefa
                hex 01 80 b7 81 d9 01 80 b6  ; af02
                hex 81 19 82 05 89 3b 01 81  ; af0a
                hex 59 83 33 01 80 b5 81 99  ; af12
                hex 8a 09 01 81 d9 8a 03 01  ; af1a
                hex 80 b4 81 19 82 06 83 32  ; af22
                hex 89 3a 01 80 b3 81 59 01  ; af2a
                hex 81 99 83 31 01 80 b2 81  ; af32
                hex d9 01 80 b1 81 19 82 07  ; af3a
                hex 89 39 01 81 59 01 81 99  ; af42
                hex 01 80 30 83 30 01 89 38  ; af4a
                hex 03 8a 09 01 89 37 01 8a  ; af52
                hex 03 03 89 36 04 89 35 04  ; af5a
                hex 89 34 04 89 33 03 00 80  ; af62
                hex be 81 eb 82 01 83 38 84  ; af6a
                hex a8 85 06 89 3e 8a 0e 01  ; af72
                hex 80 bd 81 2b 82 02 01 81  ; af7a
                hex 6b 83 37 8a 09 01 80 bc  ; af82
                hex 81 ab 01 80 bb 81 eb 89  ; af8a
                hex 3d 8a 03 01 81 96 82 03  ; af92
                hex 83 36 01 80 ba 81 d6 01  ; af9a
                hex 81 16 82 04 01 80 b9 81  ; afa2
                hex 56 83 35 89 3c 01 80 b8  ; afaa
                hex 81 96 01 81 d6 83 34 01  ; afb2
                hex 80 b7 81 16 82 05 01 80  ; afba
                hex b6 81 56 89 3b 01 81 96  ; afc2
                hex 83 33 01 80 b5 81 d6 8a  ; afca
                hex 09 01 81 16 82 06 8a 03  ; afd2
                hex 01 80 b4 81 56 83 32 89  ; afda
                hex 3a 01 80 b3 81 96 01 81  ; afe2
                hex d6 83 31 01 80 b2 81 16  ; afea
                hex 82 07 01 80 b1 81 56 89  ; aff2
                hex 39 01 81 96 01 81 d6 01  ; affa
                hex 80 30 83 30 01 89 38 03  ; b002
                hex 8a 09 01 89 37 01 8a 03  ; b00a
                hex 03 89 36 04 89 35 04 89  ; b012
                hex 34 04 89 33 03 00 80 b9  ; b01a
                hex 81 d5 82 00 01 80 b8 81  ; b022
                hex 46 01 81 d5 01 80 b7 01  ; b02a
                hex 80 b6 01 80 b9 81 8e 01  ; b032
                hex 80 b8 81 2f 01 81 8e 01  ; b03a
                hex 80 b7 01 80 b9 81 6a 01  ; b042
                hex 80 b8 81 23 01 81 6a 01  ; b04a
                hex 80 b7 01 80 b9 81 5e 01  ; b052
                hex 80 b8 81 1f 01 81 5e 01  ; b05a
                hex 80 b7 01 80 b6 02 80 b5  ; b062
                hex 02 80 b4 01 80 b3 02 80  ; b06a
                hex b2 01 80 b1 00 80 b9 81  ; b072
                hex c6 82 00 01 80 b8 81 41  ; b07a
                hex 01 81 c6 01 80 b7 01 80  ; b082
                hex b9 81 84 01 80 b8 81 2b  ; b08a
                hex 01 81 84 01 80 b7 01 80  ; b092
                hex b9 81 62 01 80 b8 81 20  ; b09a
                hex 01 81 62 01 80 b9 81 57  ; b0a2
                hex 01 80 b8 81 1d 01 81 57  ; b0aa
                hex 01 80 b7 01 80 b6 02 80  ; b0b2
                hex b5 02 80 b4 01 80 b3 02  ; b0ba
                hex 00 80 b9 81 d5 82 00 01  ; b0c2
                hex 80 b8 81 46 01 81 d5 01  ; b0ca
                hex 80 b7 01 80 b9 81 8e 01  ; b0d2
                hex 80 b8 81 2f 01 81 8e 01  ; b0da
                hex 80 b7 01 80 b9 81 6a 01  ; b0e2
                hex 80 b8 81 23 01 81 6a 01  ; b0ea
                hex 80 b9 81 5e 01 80 b8 81  ; b0f2
                hex 1f 01 81 5e 01 80 b7 01  ; b0fa
                hex 80 b6 02 80 b5 02 80 b4  ; b102
                hex 01 80 b3 02 00           ; b10a

sndeng_entry6   ; $b10f; an entry point from main program
                stx ptr2+0
                sty ptr2+1
                ldy #0
                lda region
                asl a
                tay
                lda (ptr2),y
                sta arr_shared1+1
                iny
                lda (ptr2),y
                sta arr_shared1+2
                ldx #0
                ;
-               jsr sub1
                txa
                add #15
                tax
                cpx #60
                bne -
                rts

sub1            lda #0                       ; b133
                sta arr_shared1+5,x
                sta arr_shared1+3,x
                sta arr_shared1+6,x
                sta arr_shared1+13,x
                lda #$30
                sta arr_shared1+7,x
                sta arr_shared1+10,x
                sta arr_shared1+16,x
                rts

sub2            asl a                        ; b14d
                tay
                jsr sub1
                copy arr_shared1+1, ptr2+0
                copy arr_shared1+2, ptr2+1
                lda (ptr2),y
                sta arr_shared1+4,x
                iny
                lda (ptr2),y
                sta arr_shared1+5,x
                rts

sub3            lda arr_shared1+3,x          ; b168
                beq +
                dec arr_shared1+3,x
                bne cod1
+               lda arr_shared1+5,x
                bne +
                rts
+               sta ptr1+1
                lda arr_shared1+4,x
                sta ptr1+0
                ldy arr_shared1+6,x
                clc
-               lda (ptr1),y
                bmi +
                beq ++
                iny
                sta arr_shared1+3,x
                tya
                sta arr_shared1+6,x
                jmp cod1
+               iny
                stx ram1
                adc ram1
                and #%01111111
                tax
                lda (ptr1),y
                iny
                sta arr_shared1+7,x
                ldx ram1
                jmp -
++              sta arr_shared1+5,x
cod1            lda arr1+0
                and #%00001111
                sta ram1
                lda arr_shared1+7,x
                and #%00001111
                cmp ram1
                bcc +
                lda arr_shared1+7,x
                sta arr1+0
                lda arr_shared1+8,x
                sta arr1+2
                lda arr_shared1+9,x
                sta arr1+3
+               lda arr_shared1+10,x
                beq +
                sta arr1+4
                lda arr_shared1+11,x
                sta arr1+6
                lda arr_shared1+12,x
                sta arr1+7
+               lda arr_shared1+13,x
                beq +

                sta arr1+8                   ; b1de (unaccessed)
                lda arr_shared1+14,x         ; unaccessed
                sta arr1+10                  ; unaccessed
                lda arr_shared1+15,x         ; unaccessed
                sta arr1+11                  ; unaccessed

+               lda arr1+12                  ; b1ea
                and #%00001111
                sta ram1
                lda arr_shared1+16,x
                and #%00001111
                cmp ram1
                bcc +
                lda arr_shared1+16,x
                sta arr1+12
                lda arr_shared1+17,x
                sta arr1+14
+               rts

                jmp sub4                     ; b204 (unaccessed)
                jmp sub8                     ; b207 (unaccessed)

sub4            asl a                        ; b20a
                jsr sub5
                lda #0
                tax
-               sta arr1,x
                inx
                cpx #16
                bne -
                copy #$30, arr1+12
                copy #$0f, snd_chn
                lda #8
                sta arr1+1
                sta arr1+5
                copy #$c0, joypad2
                copy #$40, joypad2
                copy #$ff, arr2+5
                lda #0
                tax
-               sta arr_shared2+33,x
                sta arr_shared2+153,x
                sta arr_shared2+157,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
                sta arr_shared2+62,x
                sta arr_shared2+58,x
                inx
                cpx #4
                bne -
                lda arr2+4
                and #%00000010
                beq +

                lda #$30                     ; b25a (unaccessed)
                ldx #0                       ; unaccessed
-               sta arr_shared2+173,x        ; unaccessed
                inx                          ; unaccessed
                cpx #4                       ; unaccessed
                bne -                        ; unaccessed
                lda #0                       ; unaccessed

+               sta arr_shared2+37           ; b268
                rts

sub5            pha                          ; b26c
                copy ram3, ptr4+0
                copy ram4, ptr4+1
                ldy #0
-               clc
                lda (ptr4),y
                adc ram3
                sta arr2,y
                iny
                lda (ptr4),y
                adc ram4
                sta arr2,y
                iny
                cpy #8
                bne -
                lda (ptr4),y
                sta arr2+4
                iny
                cpx #1
                beq +
                cpx #2
                beq ++
                lda (ptr4),y
                iny
                sta ram26
                lda (ptr4),y
                iny
                sta arr_shared2+0
                copy #<note_freqs1, ptr6+0
                copy #>note_freqs1, ptr6+1
                jmp cod2

                ; b2b1-b2c9: unaccessed code
+               iny                          ; b2b1
                iny
                lda (ptr4),y
                iny
                sta ram26
                lda (ptr4),y
                iny
                sta arr_shared2+0
                copy #<note_freqs2, ptr6+0
                copy #>note_freqs2, ptr6+1
                jmp cod2

                ; b2ca-b2df: unaccessed code
++              iny                          ; b2ca
                iny
                lda (ptr4),y
                iny
                sta ram26
                lda (ptr4),y
                iny
                sta arr_shared2+0
                copy #<note_freqs1, ptr6+0
                copy #>note_freqs1, ptr6+1

cod2            pla                          ; b2e0
                tay
                jsr sub6
                ldx #1
                stx ram18
                dex
-               lda #$7f
                sta arr_shared2+23,x
                lda #$80
                sta arr_shared2+43,x
                lda #0
                sta arr_shared2+181,x
                sta arr_shared2+193,x
                sta arr_shared2+153,x
                sta arr_shared2+74,x
                sta arr_shared2+48,x
                sta arr_shared2+169,x
                sta arr_shared2+18,x
                inx
                cpx #4
                bne -
                ldx #$ff
                inx
                stx ram20
                jsr sub7
                jsr sub14
                lda #0
                sta ram22
                sta ram23
                rts

sub6            copy arr2+0, ptr3+0          ; b326
                copy arr2+1, ptr3+1
                clc
                lda (ptr3),y
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y
                adc ram4
                sta ptr4+1
                lda #0
                tax
                tay
                clc
                lda (ptr4),y
                adc ram3
                sta ram16
                iny
                lda (ptr4),y
                adc ram4
                sta ram17
                iny
-               lda (ptr4),y
                sta arr3,x
                iny
                inx
                cpx #6
                bne -
                rts

sub7            asl a                        ; b35f
                add ram16
                sta ptr3+0
                lda #0
                tay
                tax
                adc ram17
                sta ptr3+1
                clc
                lda (ptr3),y
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y
                adc ram4
                sta ptr4+1
                ldy #0
                stx ram19
-               clc
                lda (ptr4),y
                adc ram3
                sta arr_shared2+8,x
                iny
                lda (ptr4),y
                adc ram4
                sta arr_shared2+13,x
                iny
                lda #0
                sta arr_shared2+48,x
                sta arr_shared2+28,x
                lda #$ff
                sta arr_shared2+53,x
                inx
                cpx #5
                bne -
                lda #0
                sta arr_shared2+3
                sta arr_shared2+4
                lda arr_shared2+5
                bne +
                rts

                ; b3b3-b45f: unaccessed code
+               sta ram19                    ; b3b3
                ldx #0
--              copy ram19, ram8             ; b3b8
                lda #0
                sta arr_shared2+48,x
-               ldy #0                       ; b3c2
                lda arr_shared2+8,x
                sta ptr5+0
                lda arr_shared2+13,x
                sta ptr5+1
                ;
cod3            lda arr_shared2+48,x         ; b3ce
                beq +
                dec arr_shared2+48,x         ; b3d3
                jmp ++
+               lda (ptr5),y                 ; b3d9
                bmi cod4
                lda arr_shared2+53,x         ; b3dd
                cmp #$ff
                bne +
                iny                          ; b3e4
                lda (ptr5),y
                iny
                sta arr_shared2+48,x
                jmp ++
+               iny                          ; b3ee
                sta arr_shared2+48,x
++              clc                          ; b3f2
                tya
                adc ptr5+0
                sta arr_shared2+8,x
                lda #0
                adc ptr5+1
                sta arr_shared2+13,x
                dec ram8
                bne -
                ;
                inx
                cpx #5
                bne --
                ;
                copy #0, arr_shared2+5       ; b409
                rts
cod4            cmp #$80                     ; b40f
                beq cod8
                cmp #$82                     ; b413
                beq cod6
                cmp #$84                     ; b417
                beq cod7
                pha                          ; b41b
                cmp #$8e
                beq cod5
                cmp #$92                     ; b420
                beq cod5
                cmp #$a2                     ; b424
                beq cod5
                and #%11110000               ; b428
                cmp #$f0
                beq cod5
                cmp #$e0                     ; b42e
                beq cod9
                iny                          ; b432
cod5            iny                          ; b433
                pla
                jmp cod3
cod6            iny                          ; b438
                lda (ptr5),y
                iny
                sta arr_shared2+53,x
                jmp cod3
cod7            iny                          ; b442
                lda #$ff
                sta arr_shared2+53,x
                jmp cod3
cod8            iny                          ; b44b
                lda (ptr5),y
                iny
                jsr sub26
                jmp cod3
cod9            iny                          ; b455
                pla
                and #%00001111
                asl a
                jsr sub26
                jmp cod3

sub8            lda ram18                    ; b460
                bne +
                rts                          ; b465 (unaccessed)
+               ldx #0                       ; b466
-               lda arr_shared2+28,x
                beq +

                sub #1                       ; b46d (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                bne +                        ; unaccessed
                jsr sub9                     ; b475 (unaccessed)
                lda arr_shared2+33,x         ; unaccessed
                and #%01111111               ; unaccessed
                sta arr_shared2+33,x         ; unaccessed

+               inx                          ; b480
                cpx #5
                bne -
                lda ram23
                bmi +
                ora ram22
                beq +
                jmp cod11
+               lda ram21
                beq +
                copy #0, ram21
                lda ram20
                jsr sub7
+               ldx #0
-               lda arr_shared2+28,x
                beq +
                lda #0                       ; b4a9 (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                jsr sub9                     ; unaccessed
+               jsr sub9                     ; b4b1
                lda arr_shared2+33,x
                and #%01111111
                sta arr_shared2+33,x
                inx
                cpx #5
                bne -
                lda arr_shared2+3
                beq +

                sub #1                       ; b4c6 (unaccessed)
                sta ram20                    ; unaccessed
                copy #1, ram21               ; unaccessed
                jmp cod10                    ; unaccessed

+               lda arr_shared2+4            ; b4d4
                beq ++
                sub #1
                sta arr_shared2+5
                inc ram20
                lda ram20
                cmp arr3+0
                beq +
                copy #1, ram21               ; b4ea (unaccessed)
                jmp cod10                    ; unaccessed
+               copy #0, ram20               ; b4f2
                copy #1, ram21
                jmp cod10
++              inc ram19                    ; b4ff
                lda ram19
                cmp arr3+1
                bne cod10
                inc ram20
                lda ram20
                cmp arr3+0
                beq +
                sta ram21
                jmp cod10
+               ldx #0                       ; b51b (unaccessed)
                stx ram20                    ; unaccessed
                inx                          ; unaccessed
                stx ram21                    ; unaccessed
cod10           jsr sub13                    ; b524
cod11           sec                          ; b527
                lda ram22
                sbc ram24
                sta ram22
                lda ram23
                sbc ram25
                sta ram23
                ldx #0
-               lda arr_shared2+33,x
                beq +

                sub #1                       ; b541 (unaccessed)
                sta arr_shared2+33,x         ; unaccessed
                bne +                        ; unaccessed
                sta arr_shared2+18,x         ; b549 (unaccessed)
                sta arr_shared2+165,x        ; unaccessed
                sta arr_shared2+161,x        ; unaccessed
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed

+               inx                          ; b558
                cpx #5
                bne -
                ldx #0
-               jsr sub16
                lda arr_shared2+18,x
                beq +
                jsr sub22
+               jsr sub17
                inx
                cpx #4
                bne -
                jsr sub28
                rts

sub9            ldy arr_shared2+48,x         ; b576
                beq +
                dey
                tya
                sta arr_shared2+48,x
                rts
+               sty arr_shared2+2
                copy #$0f, arr_shared2+1
                lda arr_shared2+8,x
                sta ptr5+0
                lda arr_shared2+13,x
                sta ptr5+1
                ;
cod12           lda (ptr5),y                 ; b593
                bpl +
                jmp cod16
+               beq cod13
                cmp #$7f
                bne +
                jmp cod15
+               cmp #$7e
                bne +
                jmp cod14                    ; b5a7 (unaccessed)
+               sta arr_shared2+18,x         ; b5aa
                jsr sub12
                lda arr_shared2+33,x
                bmi +
                lda #0
                sta arr_shared2+33,x
+               jsr sub25
                lda #0
                sta arr_shared2+38,x
                lda arr_shared2+1
                sta arr_shared2+121,x
                lda #0
                lda arr_shared2+125,x
                and #%11110000
                sta arr_shared2+125,x
                lsr a
                lsr a
                lsr a
                lsr a
                ora arr_shared2+125,x
                sta arr_shared2+125,x
                lda arr_shared2+153,x
                cmp #6
                beq +
                cmp #8
                bne ++
+               lda #0                       ; b5e7 (unaccessed)
                sta arr_shared2+153,x        ; unaccessed
++              cpx #2                       ; b5ec
                bcc +
                jmp cod17
+               lda #0
                sta arr_shared2+79,x
cod13           jmp cod17                    ; b5f8

cod14           lda arr_shared2+38,x         ; b5fb (unaccessed)
                cmp #1                       ; unaccessed
                beq cod13                    ; unaccessed
                lda #1                       ; b602 (unaccessed)
                sta arr_shared2+38,x         ; unaccessed
                jsr sub24                    ; unaccessed
                jmp cod17                    ; unaccessed

cod15           lda #0                       ; b60d
                sta arr_shared2+18,x
                sta arr_shared2+121,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
                sta arr_shared2+62,x
                sta arr_shared2+58,x
                cpx #2
                bcs +
+               jmp cod17
-               pla                          ; b628
                asl a
                asl a
                asl a
                and #%01111000
                sta arr_shared2+23,x
                iny
                jmp cod12
--              pla                          ; b635
                and #%00001111
                asl a
                jsr sub26
                iny
                jmp cod12
cod16           pha                          ; b640
                and #%11110000
                cmp #$f0
                beq -
                cmp #$e0
                beq --
                pla
                and #%01111111
                sty ram7
                tay
                lda jump_table1,y
                sta ptr4+0
                iny
                lda jump_table1,y
                sta ptr4+1
                ldy ram7
                iny
                jmp (ptr4)
-               sta arr_shared2+48,x         ; b662
                jmp cod18
cod17           lda arr_shared2+53,x         ; b668
                cmp #$ff
                bne -
                iny
                lda (ptr5),y
                sta arr_shared2+48,x
cod18           clc                          ; b675
                iny
                tya
                adc ptr5+0
                sta arr_shared2+8,x
                lda #0
                adc ptr5+1
                sta arr_shared2+13,x
                lda arr_shared2+2
                beq +
                sta arr_shared2+79,x         ; b689 (unaccessed)
                copy #0, arr_shared2+2       ; unaccessed
+               rts                          ; b691

sub10           lda (ptr5),y                 ; b692
                pha
                iny
                pla
                rts

jump_table1     dw jumptbl1a                 ; b698 (unaccessed)
                dw jumptbl1b                 ; b69a
                dw jumptbl1c                 ; b69c
                dw jumptbl1d                 ; b69e (unaccessed)
                dw jumptbl1e                 ; b6a0 (unaccessed)
                dw jumptbl1f                 ; b6a2 (unaccessed)
                dw jumptbl1g                 ; b6a4
                dw jumptbl1h                 ; b6a6 (unaccessed)
                dw jumptbl1i                 ; b6a8 (unaccessed)
                dw jumptbl1n                 ; b6aa
                dw jumptbl1k                 ; b6ac (unaccessed)
                dw jumptbl1l                 ; b6ae
                dw jumptbl1j                 ; b6b0
                dw jumptbl1m                 ; b6b2
                dw jumptbl1p                 ; b6b4
                dw jumptbl1q                 ; b6b6 (unaccessed)
                dw jumptbl1r                 ; b6b8 (unaccessed)
                dw jumptbl1s                 ; b6ba (unaccessed)
                dw jumptbl1u                 ; b6bc
                dw jumptbl1t                 ; b6be (unaccessed)
                dw jumptbl1o                 ; b6c0 (unaccessed)
                dw jumptbl1u                 ; b6c2 (unaccessed)
                dw jumptbl1v                 ; b6c4 (unaccessed)
                dw jumptbl1v                 ; b6c6 (unaccessed)
                dw jumptbl1x                 ; b6c8 (unaccessed)
                dw jumptbl1y                 ; b6ca
                dw jumptbl1z                 ; b6cc (unaccessed)
                dw sub11                     ; b6ce (unaccessed)
                dw sub11                     ; b6d0 (unaccessed)

jumptbl1a       jsr sub10                    ; b6d2 (unaccessed)
                jsr sub26                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1b       jsr sub10                    ; b6db
                sta arr_shared2+53,x
                jmp cod12

jumptbl1c       lda #$ff                     ; b6e4
                sta arr_shared2+53,x
                jmp cod12

jumptbl1d       jsr sub10                    ; b6ec (unaccessed)
                sta arr3+2                   ; unaccessed
                jsr sub14                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1e       jsr sub10                    ; b6f8 (unaccessed)
                sta arr3+3                   ; unaccessed
                jsr sub14                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1f       jsr sub10                    ; b704 (unaccessed)
                sta arr_shared2+3            ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1g       jsr sub10                    ; b70d
                sta arr_shared2+4
                jmp cod12

jumptbl1h       jsr sub10                    ; b716 (unaccessed)
                copy #0, ram18               ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1i       jsr sub10                    ; b721 (unaccessed)
                sta arr_shared2+1            ; unaccessed
                sta arr_shared2+121,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1j       jsr sub10                    ; b72d
                sta arr_shared2+157,x
                lda #2
                sta arr_shared2+153,x
                jmp cod12

jumptbl1k       jsr sub10                    ; b73b (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #3                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1l       jsr sub10                    ; b749
                sta arr_shared2+157,x
                lda #4
                sta arr_shared2+153,x
                jmp cod12

jumptbl1m       jsr sub10                    ; b757
                sta arr_shared2+157,x
                lda #0
                sta arr_shared2+169,x
                lda #1
                sta arr_shared2+153,x
                jmp cod12

jumptbl1n       lda #0                       ; b76a
                sta arr_shared2+157,x
                sta arr_shared2+153,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
                jmp cod12

jumptbl1o       jsr sub10                    ; b77b (unaccessed)
                sta arr_shared2+2            ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1p       jsr sub10                    ; b784
                pha
                lda arr_shared2+181,x
                bne ++
                lda arr2+4
                and #%00000010
                beq +
                lda #$30                     ; b794 (unaccessed)
+               sta arr_shared2+173,x        ; b796
++              pla                          ; b799
                pha
                and #%11110000
                sta arr_shared2+177,x
                pla
                and #%00001111
                sta arr_shared2+181,x
                jmp cod12

jumptbl1q       jsr sub10                    ; b7a9 (unaccessed)
                pha                          ; unaccessed
                and #%11110000               ; unaccessed
                sta arr_shared2+189,x        ; unaccessed
                pla                          ; unaccessed
                and #%00001111               ; unaccessed
                sta arr_shared2+193,x        ; unaccessed
                cmp #0                       ; unaccessed
                beq +                        ; unaccessed
                jmp cod12                    ; b7bc (unaccessed)
+               sta arr_shared2+185,x        ; b7bf (unaccessed)
                jmp cod12                    ; unaccessed

jumptbl1r       jsr sub10                    ; b7c5 (unaccessed)
                sta arr_shared2+43,x         ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1s       lda #$80                     ; b7ce (unaccessed)
                sta arr_shared2+43,x         ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1t       jsr sub10                    ; b7d6 (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                dey                          ; unaccessed
                jmp cod18                    ; unaccessed

jumptbl1u       jsr sub10                    ; b7e0
                sta arr_shared2+125,x
                clc
                asl a
                asl a
                asl a
                asl a
                ora arr_shared2+125,x
                sta arr_shared2+125,x
                jmp cod12

jumptbl1v       jsr sub10                    ; b7f4 (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #5                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1x       jsr sub10                    ; b802 (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #7                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1y       jsr sub10                    ; b810
                sta arr_shared2+74,x
                jmp cod12

jumptbl1z       jsr sub10                    ; b819 (unaccessed)
                ora #%10000000               ; unaccessed
                sta arr_shared2+33,x         ; unaccessed
                jmp cod12                    ; unaccessed

sub11           sub #1                       ; b824
                cpx #3
                beq +
                asl a
                sty ram7
                tay
cod19           lda (ptr6),y                 ; b82f
                sta arr_shared2+62,x
                iny
                lda (ptr6),y
                sta arr_shared2+58,x
                ldy ram7
                rts
+               and #%00001111               ; b83d
                ora #%00010000
                sta arr_shared2+62,x
                lda #0
                sta arr_shared2+58,x
                rts

sub12           sub #1                       ; b84a
                cpx #3
                beq cod20
                asl a
                sty ram7
                tay
                lda arr_shared2+153,x
                cmp #2
                bne ++
                lda (ptr6),y
                sta arr_shared2+165,x
                iny
                lda (ptr6),y
                sta arr_shared2+161,x
                ldy ram7
                lda arr_shared2+62,x
                ora arr_shared2+58,x
                bne +
                lda arr_shared2+165,x
                sta arr_shared2+62,x
                lda arr_shared2+161,x
                sta arr_shared2+58,x
+               rts
++              jmp cod19                    ; b87e
                rts                          ; b881 (unaccessed)
cod20           ora #%00010000               ; b882
                pha
                lda arr_shared2+153,x
                cmp #2
                bne ++

                pla                          ; b88c (unaccessed)
                sta arr_shared2+165,x        ; unaccessed
                lda #0                       ; unaccessed
                sta arr_shared2+161,x        ; unaccessed
                lda arr_shared2+62,x         ; unaccessed
                ora arr_shared2+58,x         ; unaccessed
                bne +                        ; unaccessed
                lda arr_shared2+165,x        ; b89d (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                lda arr_shared2+161,x        ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; b8a9 (unaccessed)

++              pla                          ; b8aa
                sta arr_shared2+62,x
                lda #0
                sta arr_shared2+58,x
                rts

sub13           clc                          ; b8b4
                lda ram22
                adc ram26
                sta ram22
                lda ram23
                adc arr_shared2+0
                sta ram23
                rts

sub14           tya                          ; b8c8
                pha
                copy arr3+3, ram12
                copy #0,     ram13
                ldy #3
-               asl ram12
                rol ram13
                dey
                bne -
                copy ram12, ram10
                lda ram13
                tay
                asl ram12
                rol ram13
                clc
                lda ram10
                adc ram12
                sta ram10
                tya
                adc ram13
                sta ram11
                copy arr3+2, ram12
                copy #0,     ram13
                jsr sub15
                copy ram10, ram24
                copy ram11, ram25
                pla
                tay
                rts

sub15           lda #0                       ; b90c
                sta ram15
                ldy #$10
-               asl ram10
                rol ram11
                rol a
                rol ram15
                pha
                cmp ram12
                lda ram15
                sbc ram13
                bcc +
                sta ram15
                pla
                sbc ram12
                pha
                inc ram10
+               pla
                dey
                bne -
                sta ram14
                rts

sub16           lda arr_shared2+74,x         ; b931
                beq cod21
                lda arr_shared2+74,x
                and #%00001111
                sta ram7
                sec
                lda arr_shared2+23,x
                sbc ram7
                bpl +
                lda #0
+               sta arr_shared2+23,x
                lda arr_shared2+74,x
                lsr a
                lsr a
                lsr a
                lsr a
                sta ram7
                clc
                lda arr_shared2+23,x
                adc ram7
                bpl +
                lda #$7f                     ; b95b (unaccessed)
+               sta arr_shared2+23,x         ; b95d
cod21           lda arr_shared2+153,x        ; b960
                beq rts1
                cmp #1
                beq cod22
                cmp #2
                beq cod23
                cmp #3
                beq cod24
                cmp #6
                beq cod25
                cmp #8
                beq cod26
                cmp #5
                beq cod27
                cmp #7
                beq cod27
                jmp cod32
cod22           jmp cod35
cod23           jmp cod29                    ; b987
cod24           jmp cod31                    ; b98a (unaccessed)
cod25           jmp cod33                    ; b98d (unaccessed)
cod26           jmp cod34                    ; b990 (unaccessed)
cod27           jmp cod28                    ; b993 (unaccessed)
rts1            rts                          ; b996

                ; b997-ba0f: unaccessed code
cod28           lda arr_shared2+62,x         ; b997
                pha
                lda arr_shared2+58,x
                pha
                lda arr_shared2+157,x
                and #%00001111
                sta ram7
                lda arr_shared2+153,x
                cmp #5
                beq ++
                lda arr_shared2+18,x         ; b9ad
                sub ram7
                bpl +
                lda #1                       ; b9b5
+               bne +                        ; b9b7
                lda #1                       ; b9b9
+               jmp +                        ; b9bb
++              lda arr_shared2+18,x         ; b9be
                add ram7
                cmp #$60
                bcc +
                lda #$60                     ; b9c8
+               sta arr_shared2+18,x         ; b9ca
                jsr sub11
                lda arr_shared2+62,x
                sta arr_shared2+165,x
                lda arr_shared2+58,x
                sta arr_shared2+161,x
                lda arr_shared2+157,x
                lsr a
                lsr a
                lsr a
                ora #%00000001
                sta arr_shared2+157,x
                pla
                sta arr_shared2+58,x
                pla
                sta arr_shared2+62,x
                clc
                lda arr_shared2+153,x
                adc #1
                sta arr_shared2+153,x
                cpx #3
                bne ++
                cmp #6                       ; b9fc
                beq +
                lda #6                       ; ba00
                sta arr_shared2+153,x
                jmp cod21
+               lda #8                       ; ba08
                sta arr_shared2+153,x
++              jmp cod21                    ; ba0d

sub17           lda arr_shared2+62,x         ; ba10
                sta arr_shared2+66,x
                lda arr_shared2+58,x
                sta arr_shared2+70,x
                lda arr_shared2+43,x
                cmp #$80
                beq +

                ; ba23-ba4a: unaccessed code
                lda arr_shared2+18,x         ; ba23
                beq +
                clc                          ; ba28
                lda arr_shared2+66,x
                adc #$80
                sta arr_shared2+66,x
                lda arr_shared2+70,x
                adc #0
                sta arr_shared2+70,x
                sec
                lda arr_shared2+66,x
                sbc arr_shared2+43,x
                sta arr_shared2+66,x
                lda arr_shared2+70,x
                sbc #0
                sta arr_shared2+70,x

+               jsr sub20                    ; ba4b
                jsr sub21
                rts
cod29           lda arr_shared2+157,x        ; ba52
                beq cod30
                lda arr_shared2+165,x
                ora arr_shared2+161,x
                beq cod30
                lda arr_shared2+58,x
                cmp arr_shared2+161,x
                bcc ++
                bne +
                lda arr_shared2+62,x
                cmp arr_shared2+165,x
                bcc ++
                bne +
                jmp rts1
+               lda arr_shared2+157,x
                sta ptr3+0
                copy #0, ptr3+1
                jsr sub19
                cmp arr_shared2+161,x
                bcc +
                bmi +
                bne cod30
                lda arr_shared2+62,x
                cmp arr_shared2+165,x
                bcc +
                jmp rts1
++              lda arr_shared2+157,x        ; ba96
                sta ptr3+0
                copy #0, ptr3+1
                jsr sub18
                lda arr_shared2+161,x
                cmp arr_shared2+58,x
                bcc +
                bne cod30
                lda arr_shared2+165,x
                cmp arr_shared2+62,x
                bcc +
                jmp rts1
+               lda arr_shared2+165,x        ; bab7
                sta arr_shared2+62,x
                lda arr_shared2+161,x
                sta arr_shared2+58,x
cod30           jmp rts1                     ; bac3

cod31           lda arr_shared2+157,x        ; bac6 (unaccessed)
                sta ptr3+0                   ; unaccessed
                copy #0, ptr3+1              ; unaccessed
                jsr sub19                    ; unaccessed
                jsr sub27                    ; unaccessed
                jmp rts1                     ; unaccessed

cod32           lda arr_shared2+157,x        ; bad8
                sta ptr3+0
                copy #0, ptr3+1
                jsr sub18
                jsr sub27
                jmp rts1

sub18           clc                          ; baea
                lda arr_shared2+62,x
                adc ptr3+0
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                adc ptr3+1
                sta arr_shared2+58,x
                bcc +
                lda #$ff                     ; bafd (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; bb05

sub19           sec                          ; bb06
                lda arr_shared2+62,x
                sbc ptr3+0
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                sbc ptr3+1
                sta arr_shared2+58,x
                bcs +
                lda #0                       ; bb19 (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; bb21

                ; bb22-bb85: unaccessed code
cod33           sec                          ; bb22
                lda arr_shared2+62,x
                sbc arr_shared2+157,x
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                sbc #0
                sta arr_shared2+58,x
                bmi +
                cmp arr_shared2+161,x        ; bb36
                bcc +
                bne ++                       ; bb3b
                lda arr_shared2+62,x         ; bb3d
                cmp arr_shared2+165,x
                bcc +
                jmp rts1                     ; bb45
cod34           clc                          ; bb48
                lda arr_shared2+62,x
                adc arr_shared2+157,x
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                adc #0
                sta arr_shared2+58,x
                cmp arr_shared2+161,x
                bcc ++
                bne +                        ; bb5f
                lda arr_shared2+62,x         ; bb61
                cmp arr_shared2+165,x
                bcs +
                jmp rts1                     ; bb69
+               lda arr_shared2+165,x        ; bb6c
                sta arr_shared2+62,x
                lda arr_shared2+161,x
                sta arr_shared2+58,x
                lda #0
                sta arr_shared2+153,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
++              jmp rts1                     ; bb83

cod35           lda arr_shared2+169,x        ; bb86
                cmp #1
                beq +
                cmp #2
                beq ++
                lda arr_shared2+18,x
                jsr sub11
                inc arr_shared2+169,x
                jmp rts1
+               lda arr_shared2+157,x
                lsr a
                lsr a
                lsr a
                lsr a
                clc
                adc arr_shared2+18,x
                jsr sub11
                lda arr_shared2+157,x
                and #%00001111
                bne +
                sta arr_shared2+169,x        ; bbb2 (unaccessed)
                jmp rts1                     ; unaccessed
+               inc arr_shared2+169,x        ; bbb8
                jmp rts1
++              lda arr_shared2+157,x        ; bbbe
                and #%00001111
                clc
                adc arr_shared2+18,x
                jsr sub11
                lda #0
                sta arr_shared2+169,x
                jmp rts1

sub20           lda arr_shared2+181,x        ; bbd2
                bne +
                rts
+               clc
                adc arr_shared2+173,x
                and #%00111111
                sta arr_shared2+173,x
                cmp #$10
                bcc +
                cmp #$20
                bcc ++
                cmp #$30
                bcc cod36
                sub #$30
                sta ram7
                sec
                lda #$0f
                sbc ram7
                ora arr_shared2+177,x
                tay
                lda dat8,y
                jmp cod37
+               ora arr_shared2+177,x
                tay
                lda dat8,y
                sta ptr3+0
                copy #0, ptr3+1
                jmp +
++              sub #$10                     ; bc11
                sta ram7
                sec
                lda #$0f
                sbc ram7
                ora arr_shared2+177,x
                tay
                lda dat8,y
                sta ptr3+0
                copy #0, ptr3+1
                jmp +
cod36           sub #$20                     ; bc2b
                ora arr_shared2+177,x
                tay
                lda dat8,y
cod37           eor #%11111111               ; bc35
                sta ptr3+0
                copy #$ff, ptr3+1
                clc
                lda ptr3+0
                adc #1
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
+               lda arr2+4                   ; bc4a
                and #%00000010
                beq +

                ; bc51-bc6b: unaccessed code
                lda #$0f                     ; bc51
                clc
                adc arr_shared2+177,x
                tay
                clc
                lda dat8,y
                adc #1
                adc ptr3+0
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
                lsr ptr3+1
                ror ptr3+0

+               sec                          ; bc6c
                lda arr_shared2+66,x
                sbc ptr3+0
                sta arr_shared2+66,x
                lda arr_shared2+70,x
                sbc ptr3+1
                sta arr_shared2+70,x
                rts

                clc                          ; bc7e (unaccessed)
                lda arr_shared2+66,x         ; unaccessed
                adc ptr3+0                   ; unaccessed
                sta arr_shared2+66,x         ; unaccessed
                lda arr_shared2+70,x         ; unaccessed
                adc ptr3+1                   ; unaccessed
                sta arr_shared2+70,x         ; unaccessed
                rts                          ; unaccessed

sub21           lda arr_shared2+193,x        ; bc90
                bne +
                lda #0
                sta arr_shared2+197,x
                rts

                ; bc9b-bccd: unaccessed code
+               clc                          ; bc9b
                adc arr_shared2+185,x
                and #%00111111
                sta arr_shared2+185,x
                lsr a
                cmp #$10
                bcc +
                sub #$10                     ; bca9
                sta ram7
                sec
                lda #$0f
                sbc ram7
                ora arr_shared2+189,x
                tay
                lda dat8,y
                lsr a
                sta ram7
                jmp ++
+               ora arr_shared2+189,x        ; bcc0
                tay
                lda dat8,y
                lsr a
                sta ram7
++              sta arr_shared2+197,x        ; bcca
                rts

sub22           lda arr_shared2+85,x         ; bcce
                beq +
                sta ptr4+1
                lda arr_shared2+81,x
                sta ptr4+0
                lda arr_shared2+129,x
                cmp #$ff
                beq +
                jsr sub23
                sta arr_shared2+129,x
                lda arr_shared2+7
                sta arr_shared2+121,x
+               lda arr_shared2+93,x
                beq cod42
                sta ptr4+1
                lda arr_shared2+89,x
                sta ptr4+0
                lda arr_shared2+133,x
                cmp #$ff
                beq cod41
                jsr sub23
                sta arr_shared2+133,x
                lda arr_shared2+18,x
                beq cod42
                ldy #3
                lda (ptr4),y
                beq cod39
                cmp #1
                beq cod38

                ; bd15-bd2f: unaccessed code
                clc                          ; bd15
                lda arr_shared2+18,x
                adc arr_shared2+7
                cmp #1
                bcc +
                cmp #$5f                     ; bd20
                bcc ++
                lda #$5f                     ; bd24
                bne ++
+               lda #1                       ; bd28
++              sta arr_shared2+18,x         ; bd2a
                jmp cod40

cod38           lda arr_shared2+7            ; bd30
                add #1
                jmp cod40
cod39           clc                          ; bd39
                lda arr_shared2+18,x
                adc arr_shared2+7
                beq +
                bpl ++
+               lda #1                       ; bd44 (unaccessed)
++              cmp #$60                     ; bd46
                bcc cod40
                lda #$60                     ; bd4a (unaccessed)
cod40           jsr sub11                    ; bd4c
                lda #1
                sta arr_shared2+149,x
                jmp cod42
cod41           ldy #3                       ; bd57
                lda (ptr4),y
                beq cod42
                lda arr_shared2+149,x
                beq cod42
                lda arr_shared2+18,x
                jsr sub11
                lda #0
                sta arr_shared2+149,x
cod42           lda arr_shared2+101,x        ; bd6d
                beq cod43

                ; bd72-bda3: unaccessed code
                sta ptr4+1                   ; bd72
                lda arr_shared2+97,x
                sta ptr4+0
                lda arr_shared2+137,x
                cmp #$ff
                beq cod43
                jsr sub23                    ; bd80
                sta arr_shared2+137,x
                clc
                lda arr_shared2+7
                adc arr_shared2+62,x
                sta arr_shared2+62,x
                lda arr_shared2+7
                bpl +
                lda #$ff                     ; bd95
                bmi ++
+               lda #0                       ; bd99
++              adc arr_shared2+58,x         ; bd9b
                sta arr_shared2+58,x
                jsr sub27

cod43           lda arr_shared2+109,x        ; bda4
                beq cod44                    ; bda7

                ; bda9-bded: unaccessed code
                sta ptr4+1                   ; bda9
                lda arr_shared2+105,x
                sta ptr4+0
                lda arr_shared2+141,x
                cmp #$ff
                beq cod44
                jsr sub23                    ; bdb7
                sta arr_shared2+141,x
                lda arr_shared2+7
                sta ptr3+0
                rol a
                bcc +
                copy #$ff, ptr3+1            ; bdc5
                jmp ++
+               lda #0                       ; bdcc
                sta ptr3+1
++              ldy #4                       ; bdd0
-               clc
                rol ptr3+0
                rol ptr3+1
                dey
                bne -
                clc
                lda ptr3+0
                adc arr_shared2+62,x
                sta arr_shared2+62,x
                lda ptr3+1
                adc arr_shared2+58,x
                sta arr_shared2+58,x
                jsr sub27

cod44           lda arr_shared2+117,x        ; bdee
                beq +                        ; bdf1

                ; bdf3-be19: unaccessed code
                sta ptr4+1                   ; bdf3
                lda arr_shared2+113,x
                sta ptr4+0
                lda arr_shared2+145,x
                cmp #$ff
                beq +
                jsr sub23                    ; be01
                sta arr_shared2+145,x
                lda arr_shared2+7
                pha
                lda arr_shared2+125,x
                and #%11110000
                sta arr_shared2+125,x
                pla
                ora arr_shared2+125,x
                sta arr_shared2+125,x

+               rts                          ; be1a

sub23           add #4                       ; be1b
                tay
                lda (ptr4),y
                sta arr_shared2+7
                dey
                dey
                dey
                tya
                ldy #0
                cmp (ptr4),y
                beq +
                ldy #2
                cmp (ptr4),y
                beq ++
                rts
+               iny
                lda (ptr4),y
                cmp #$ff
                bne cod45
                rts
cod45           pha                          ; be3d
                lda arr_shared2+38,x
                bne +
                pla
                rts

                ; be45-be67: unaccessed code
+               ldy #2                       ; be45
                lda (ptr4),y
                bne +
                pla                          ; be4b
                rts
+               pla                          ; be4d
                lda #$ff
                rts
++              sta ram7                     ; be51
                lda arr_shared2+38,x
                bne +
                dey                          ; be58
                lda (ptr4),y
                cmp #$ff
                bne cod45
                lda ram7                     ; be5f
                sub #1
                rts
+               lda ram7                     ; be65
                rts

                ; be68-bee4: unaccessed
sub24           tya                          ; be68
                pha
                lda arr_shared2+85,x
                beq +
                sta ptr4+1                   ; be6f
                lda arr_shared2+81,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1                       ; be7c
                sta arr_shared2+129,x
+               lda arr_shared2+93,x         ; be82
                beq +
                sta ptr4+1                   ; be87
                lda arr_shared2+89,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1                       ; be94
                sta arr_shared2+133,x
+               lda arr_shared2+101,x        ; be9a
                beq +
                sta ptr4+1                   ; be9f
                lda arr_shared2+97,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1                       ; beac
                sta arr_shared2+137,x
+               lda arr_shared2+109,x        ; beb2
                beq +
                sta ptr4+1                   ; beb7
                lda arr_shared2+105,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1                       ; bec4
                sta arr_shared2+141,x
+               lda arr_shared2+117,x        ; beca
                beq +
                sta ptr4+1                   ; becf
                lda arr_shared2+113,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1                       ; bedc
                sta arr_shared2+145,x
+               pla                          ; bee2
                tay
                rts

sub25           lda #0                       ; bee5
                sta arr_shared2+129,x
                sta arr_shared2+133,x
                sta arr_shared2+137,x
                sta arr_shared2+141,x
                sta arr_shared2+145,x
                rts

sub26           sta ram9                     ; bef7
                sty ram7
                ldy #0
                add arr2+2
                sta ptr3+0
                tya
                adc arr2+3
                sta ptr3+1
                clc
                lda (ptr3),y
                adc ram3
                sta ptr4+0
                iny
                lda (ptr3),y
                adc ram4
                sta ptr4+1
                lda dat7,x
                tay
                lda dat4,y
                sta ptr3+0
                iny
                lda dat4,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)

dat4            ; $bf2b: partially unaccessed
                hex 37 bf 37 bf 75 c0 75 c0
                hex 37 bf 75 c0

                ; $bf37: indirectly accessed
                lda (ptr4),y
                sta ram9
                iny
                ror ram9
                bcc ++
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
                cmp arr_shared2+81,x
                bne +
                lda ptr3+1
                cmp arr_shared2+85,x
                bne +
                jmp cod46
+               lda ptr3+0
                sta arr_shared2+81,x
                lda ptr3+1
                sta arr_shared2+85,x
                lda #0
                sta arr_shared2+129,x
                jmp cod46
++              lda #0                       ; bf72
                sta arr_shared2+81,x
                sta arr_shared2+85,x
cod46           ror ram9                     ; bf7a
                bcc ++
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
                cmp arr_shared2+89,x
                bne +
                lda ptr3+1
                cmp arr_shared2+93,x
                bne +
                jmp cod47
+               lda ptr3+0
                sta arr_shared2+89,x
                lda ptr3+1
                sta arr_shared2+93,x
                lda #0
                sta arr_shared2+133,x
                jmp cod47
++              lda #0                       ; bfb0
                sta arr_shared2+89,x
                sta arr_shared2+93,x
cod47           ror ram9                     ; bfb8
                bcc ++                       ; bfba

                ; bfbc-bfed: unaccessed code
                clc                          ; bfbc
                lda (ptr4),y
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr_shared2+97,x
                bne +
                lda ptr3+1                   ; bfd2
                cmp arr_shared2+101,x
                bne +
                jmp cod48                    ; bfd9
+               lda ptr3+0                   ; bfdc
                sta arr_shared2+97,x
                lda ptr3+1
                sta arr_shared2+101,x
                lda #0
                sta arr_shared2+137,x
                jmp cod48

++              lda #0                       ; bfee
                sta arr_shared2+97,x
                sta arr_shared2+101,x
cod48           ror ram9                     ; bff6
                bcc ++                       ; bff8

                ; bffa-c02b: unaccessed code
                clc                          ; bffa
                lda (ptr4),y
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr_shared2+105,x
                bne +
                lda ptr3+1                   ; c010
                cmp arr_shared2+109,x
                bne +
                jmp cod49                    ; c017
+               lda ptr3+0                   ; c01a
                sta arr_shared2+105,x
                lda ptr3+1
                sta arr_shared2+109,x
                lda #0
                sta arr_shared2+141,x
                jmp cod49

++              lda #0                       ; c02c
                sta arr_shared2+105,x
                sta arr_shared2+109,x
cod49           ror ram9                     ; c034
                bcc ++

                ; c038-c069: unaccessed code
                clc                          ; c038
                lda (ptr4),y
                adc ram3
                sta ptr3+0
                iny
                lda (ptr4),y
                adc ram4
                sta ptr3+1
                iny
                lda ptr3+0
                cmp arr_shared2+113,x
                bne +
                lda ptr3+1                   ; c04e
                cmp arr_shared2+117,x
                bne +
                jmp cod50                    ; c055
+               lda ptr3+0                   ; c058
                sta arr_shared2+113,x
                lda ptr3+1
                sta arr_shared2+117,x
                lda #0
                sta arr_shared2+145,x
                jmp cod50

++              lda #0                       ; c06a
                sta arr_shared2+113,x
                sta arr_shared2+117,x
cod50           ldy ram7                     ; c072
                rts

sub27           lda dat7,x                   ; c075
                tay
                lda jump_table2,y
                sta ptr3+0
                iny
                lda jump_table2,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)                   ; c086

jump_table2     dw jumptbl2b                 ; c089
                dw jumptbl2c                 ; c08b (unaccessed)
                dw rts2                      ; c08d (unaccessed)
                dw jumptbl2c                 ; c08f (unaccessed)
                dw jumptbl2b                 ; c091 (unaccessed)
                dw rts2                      ; c093 (unaccessed)

rts2            rts                          ; c095 (unaccessed)

jumptbl2b       lda arr_shared2+58,x         ; c096
                bmi ++
                cmp #8
                bcc +
                lda #7                       ; c09f (unaccessed)
                sta arr_shared2+58,x         ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr_shared2+62,x         ; unaccessed
+               rts                          ; c0a9

++              lda #0                       ; c0aa (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
                rts                          ; unaccessed

                ; c0b3-c0cf: unaccessed code
jumptbl2c       lda arr_shared2+58,x         ; c0b3
                bmi ++
                cmp #$10                     ; c0b8
                bcc +
                lda #$0f                     ; c0bc
                sta arr_shared2+58,x
                lda #$ff
                sta arr_shared2+62,x
+               rts                          ; c0c6
++              lda #0                       ; c0c7
                sta arr_shared2+62,x
                sta arr_shared2+58,x
                rts

sub28           lda ram18                    ; c0d0
                bne +
                copy #0, snd_chn             ; c0d5 (unaccessed)
                rts                          ; unaccessed

sub29           copy #$c0, joypad2           ; c0db
                copy #$40, joypad2
                rts
+               lda arr2+5                   ; c0e6
                and #%00000001
                bne +
                jmp cod52                    ; c0ed (unaccessed)
+               lda arr_shared2+18           ; c0f0
                beq cod51
                lda arr_shared2+23
                asl a
                beq cod51
                and #%11110000
                sta ram7
                lda arr_shared2+121
                beq cod51
                ora ram7
                tax
                lda dat6,x
                sub arr_shared2+197
                bpl +
                lda #0                       ; c110 (unaccessed)
+               bne +                        ; c112
                lda arr_shared2+23
                beq +
                lda #1
+               pha                          ; c11b
                lda arr_shared2+125
                and #%00000011
                tax
                pla
                ora dat5,x
                ora #%00110000
                sta arr1+0
                lda arr_shared2+70
                and #%11111000
                beq +
                copy #7,   arr_shared2+70    ; c131 (unaccessed)
                copy #$ff, arr_shared2+66    ; unaccessed
+               lda arr_shared2+79           ; c13b
                beq +

                ; c140-c15d: unaccessed code
                and #%10000000               ; c140
                beq cod52
                lda arr_shared2+79           ; c144
                sta arr1+1
                and #%01111111
                sta arr_shared2+79
                jsr sub29
                copy arr_shared2+66, arr1+2
                copy arr_shared2+70, arr1+3
                jmp cod52

cod51           copy #$30, arr1+0            ; c15e
                jmp cod52
+               copy #8, arr1+1              ; c165
                jsr sub29
                copy arr_shared2+66, arr1+2
                copy arr_shared2+70, arr1+3
cod52           lda arr2+5                   ; c176
                and #%00000010
                bne +
                jmp cod54                    ; c17d (unaccessed)
+               lda arr_shared2+19           ; c180
                beq cod53
                lda arr_shared2+24
                asl a
                beq cod53
                and #%11110000
                sta ram7
                lda arr_shared2+122
                beq cod53
                ora ram7
                tax
                lda dat6,x
                sub arr_shared2+198
                bpl +
                lda #0                       ; c1a0 (unaccessed)
+               bne +                        ; c1a2
                lda arr_shared2+24           ; c1a4 (unaccessed)
                beq +                        ; unaccessed
                lda #1                       ; c1a9 (unaccessed)
+               pha                          ; c1ab
                lda arr_shared2+126
                and #%00000011
                tax
                pla
                ora dat5,x
                ora #%00110000
                sta arr1+4
                lda arr_shared2+71
                and #%11111000
                beq +
                copy #7,   arr_shared2+71    ; c1c1 (unaccessed)
                copy #$ff, arr_shared2+67    ; unaccessed
+               lda arr_shared2+80           ; c1cb
                beq +

                ; c1d0-c1ed: unaccessed code
                and #%10000000               ; c1d0
                beq cod54
                lda arr_shared2+80           ; c1d4
                sta arr1+5
                and #%01111111
                sta arr_shared2+80
                jsr sub29
                copy arr_shared2+67, arr1+6
                copy arr_shared2+71, arr1+7
                jmp cod54

cod53           copy #$30, arr1+4            ; c1ee
                jmp cod54
+               copy #8, arr1+5              ; c1f5
                jsr sub29
                copy arr_shared2+67, arr1+6
                copy arr_shared2+71, arr1+7
cod54           lda arr2+5                   ; c206
                and #%00000100
                beq cod55
                lda arr_shared2+123
                beq ++
                lda arr_shared2+25
                beq ++
                lda arr_shared2+20
                beq ++
                copy #$81, arr1+8
                lda arr_shared2+72
                and #%11111000
                beq +
                copy #7,   arr_shared2+72    ; c227 (unaccessed)
                copy #$ff, arr_shared2+68    ; unaccessed
+               copy arr_shared2+68, arr1+10 ; c231
                copy arr_shared2+72, arr1+11
                jmp cod55
++              copy #0, arr1+8              ; c23e
cod55           lda arr2+5                   ; c242
                and #%00001000
                beq rts3
                lda arr_shared2+21
                beq ++
                lda arr_shared2+26
                asl a
                beq ++
                and #%11110000
                sta ram7
                lda arr_shared2+124
                beq ++
                ora ram7
                tax
                lda dat6,x
                sub arr_shared2+200
                bpl +
                lda #0                       ; c269 (unaccessed)
+               bne +                        ; c26b
                lda arr_shared2+26
                beq +
                lda #1
+               ora #%00110000               ; c274
                sta arr1+12
                copy #0, arr1+13
                lda arr_shared2+128
                ror a
                ror a
                and #%10000000
                sta ram7
                lda arr_shared2+69
                and #%00001111
                eor #%00001111
                ora ram7
                sta arr1+14
                lda #0
                sta arr1+15
                beq rts3                     ; always
++              copy #$30, arr1+12           ; c296
rts3            rts                          ; c29a

dat5            hex 00 40 80 c0              ; c29b (partially unaccessed)

dat6            ; $c29f-$c39e: partially unaccessed
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                db 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2
                db 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3
                db 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4
                db 0, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5
                db 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6
                db 0, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7
                db 0, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8
                db 0, 1, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9
                db 0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9,10
                db 0, 1, 1, 2, 2, 3, 4, 5, 5, 6, 7, 8, 8, 9,10,11
                db 0, 1, 1, 2, 3, 4, 4, 5, 6, 7, 8, 8, 9,10,11,12
                db 0, 1, 1, 2, 3, 4, 5, 6, 6, 7, 8, 9,10,11,12,13
                db 0, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14
                db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15

                ; $c39f: partially unaccessed
                hex 01 02 03 04 05

dat7            ; $c3a4: partially unaccessed
                hex 00 00 00 00 00

note_freqs1     ; $c3a9: note frequencies (96 values); partially unaccessed
                ; 3228/3419 = ~2**(-1/12)
                dw 3419, 3228, 3046, 2875, 2714, 2561, 2418, 2282
                dw 2154, 2033, 1919, 1811, 1709, 1613, 1523, 1437
                dw 1356, 1280, 1208, 1140, 1076, 1016,  959,  905
                dw  854,  806,  761,  718,  678,  640,  604,  570
                dw  538,  507,  479,  452,  427,  403,  380,  359
                dw  338,  319,  301,  284,  268,  253,  239,  225
                dw  213,  201,  189,  179,  169,  159,  150,  142
                dw  134,  126,  119,  112,  106,  100,   94,   89
                dw   84,   79,   75,   70,   66,   63,   59,   56
                dw   52,   49,   47,   44,   41,   39,   37,   35
                dw   33,   31,   29,   27,   26,   24,   23,   21
                dw   20,   19,   18,   17,   16,   15,   14,   13

note_freqs2     ; $c469: note frequencies (96 values); unaccessed
                ; 2998/3176 = ~2**(-1/12)
                dw 3176, 2998, 2830, 2671, 2521, 2379, 2246, 2120
                dw 2001, 1888, 1782, 1682, 1588, 1499, 1414, 1335
                dw 1260, 1189, 1122, 1059, 1000,  944,  891,  841
                dw  793,  749,  707,  667,  629,  594,  561,  529
                dw  499,  471,  445,  420,  396,  374,  353,  333
                dw  314,  297,  280,  264,  249,  235,  222,  209
                dw  198,  186,  176,  166,  157,  148,  139,  132
                dw  124,  117,  110,  104,   98,   93,   87,   82
                dw   78,   73,   69,   65,   62,   58,   55,   52
                dw   49,   46,   43,   41,   38,   36,   34,   32
                dw   30,   29,   27,   25,   24,   22,   21,   20
                dw   19,   18,   17,   16,   15,   14,   13,   12

dat8            ; c529-c628: partially unaccessed data
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0
                db 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,  1,  1,  1,  1,  1,  1
                db 0, 0, 0, 0, 1, 1, 1, 1, 2, 2,  2,  2,  2,  2,  2,  2
                db 0, 0, 0, 1, 1, 1, 2, 2, 2, 3,  3,  3,  3,  3,  3,  3
                db 0, 0, 0, 1, 1, 2, 2, 3, 3, 3,  4,  4,  4,  4,  4,  4
                db 0, 0, 1, 2, 2, 3, 3, 4, 4, 5,  5,  6,  6,  6,  6,  6
                db 0, 0, 1, 2, 3, 4, 5, 6, 7, 7,  8,  8,  9,  9,  9,  9
                db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,  9, 10, 11, 11, 11, 11
                db 0, 1, 2, 4, 5, 6, 7, 8, 9,10, 11, 12, 12, 13, 13, 13
                db 0, 1, 3, 4, 6, 8, 9,10,12,13, 14, 14, 15, 16, 16, 16
                db 0, 2, 4, 6, 8,10,12,13,15,17, 18, 19, 20, 21, 21, 21
                db 0, 2, 5, 8,11,14,16,19,21,23, 24, 26, 27, 28, 29, 29
                db 0, 4, 8,12,16,20,24,27,31,34, 36, 38, 40, 42, 43, 43
                db 0, 6,12,18,24,30,35,40,45,49, 53, 56, 59, 61, 62, 63
                db 0, 9,18,27,36,45,53,60,67,74, 79, 84, 88, 91, 94, 95
                db 0,12,24,37,48,60,71,81,90,98,106,112,118,122,125,127
