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

dat1            ; $9de5; partially unaccessed
                hex 0d 00 0d 00 0d 00 0d 00
                hex 00 10 0e b8 0b 0f 00 16
                hex 00 01 40 06 96 00 18 00
                hex 22 00 22 00 22 00 22 00
                hex 22 00 00 3f

                copy #0, ram2                ; $9e09 (unaccessed)
                rts                          ; unaccessed

sndeng_entry4   ; $9e0e; an entry point from main program
                copy #1, ram2
                rts

                lda ram2                     ; $9e13 (unaccessed)
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

dat2            hex 00 0f 1e 2d              ; $9e2c
dat3            ; $9e30; partially unaccessed
                hex 3e 01 f3 00 3e 01 3e 01 00 10 0e b8 0b 02 ff 00
                hex 00 0c 00 03 ff 00 01 2a 26 22 03 ff 00 01 31 2d
                hex 2a 01 ff 00 00 01 06 ff 00 00 0c 0a 04 02 01 00
                hex 02 01 00 01 1a 1e 32 ff 00 00 0c 07 06 06 06 06
                hex 06 06 06 06 05 05 05 05 05 05 05 05 04 04 04 04
                hex 04 04 04 03 03 03 03 03 03 03 03 02 02 02 02 02
                hex 02 02 02 01 01 01 01 01 01 01 01 01 09 ff 00 00
                hex 0c 0a 08 06 05 04 03 02 01 05 04 00 01 19 1a 1b
                hex 1c 1e 09 08 00 01 06 0b 0b 0b 0b 0b 0b 0b 0d 29
                hex ff 00 00 0a 0a 0a 0a 0a 0a 09 09 09 09 09 09 09
                hex 08 08 08 08 08 07 07 07 07 07 06 06 06 06 05 05
                hex 05 05 05 04 04 03 03 02 02 01 01 00 09 00 00 00
                hex fb fb fb 00 00 00 02 02 02 09 00 00 00 fb fb fb
                hex 00 00 00 03 03 03 09 00 00 00 03 03 03 07 07 07
                hex 0e 0e 0e 0c 00 00 00 fa fa fa fe fe fe 00 00 00
                hex 03 03 03 09 01 0a 01 0d 01 10 01 13 01 18 01 1d
                hex 01 22 01 29 01 30 01 37 01 00 02 0d 00 02 13 00
                hex 02 1a 00 03 26 00 30 00 03 36 00 79 00 03 6c 00
                hex 82 00 13 8f 00 bc 00 21 00 13 8f 00 c9 00 21 00
                hex 13 8f 00 d6 00 21 00 13 8f 00 e3 00 21 00 42 01
                hex 49 01 50 01 0a 58 05 aa 00 f8 0d 02 30 04 96 00
                hex 64 01 6e 01 78 01 82 01 8c 01 96 01 a0 01 aa 01
                hex b4 01 be 01 c8 01 7f 02 3c 03 8d 03 01 04 03 04
                hex ba 04 76 05 ca 05 01 04 c8 01 7f 02 3c 03 8d 03
                hex 01 04 42 06 ee 06 a5 07 ed 07 01 04 66 08 1d 09
                hex da 09 8d 03 01 04 2b 0a e2 0a 9e 0b 8d 03 01 04
                hex 66 08 1d 09 da 09 8d 03 01 04 2b 0a e2 0a 9e 0b
                hex 8d 03 01 04 f6 0b 06 0c a6 0c cc 0c 01 04 01 04
                hex 1a 0d 8f 0d 9f 0d 01 04 82 00 e0 a4 02 f5 27 f3
                hex 00 f5 24 f3 27 f5 27 f3 24 f5 2b f3 27 f5 30 f3
                hex 2b f5 2b f3 30 f5 27 f3 2b f5 2b f3 27 f5 33 f3
                hex 2b f5 32 f3 33 f5 30 f3 32 f5 2b f3 30 f5 27 f3
                hex 2b f5 26 f3 27 f5 24 f3 26 f5 2b f3 24 f5 2c f3
                hex 2b f5 27 f3 2c f5 2b f3 27 f5 2e f3 2b f5 30 f3
                hex 2e f5 2b f3 30 f5 2c f3 2b f5 2e f3 2c f5 2c f3
                hex 2e f5 2b f3 2c f5 2c f3 2b f5 2e f3 2c f5 30 f3
                hex 2e f5 33 f3 30 f5 32 f3 33 f5 30 f3 32 f5 2e f3
                hex 30 f5 2c f3 2e f5 2b f3 2c f5 2e f3 2b f5 2c f3
                hex 2e f5 2b f3 2c f5 29 f3 2b f5 27 f3 29 f5 26 f3
                hex 27 f5 1f f3 26 f5 2b f3 1f f5 2f 84 f3 2b 00 82
                hex 00 e0 a4 00 f2 2b 27 a4 01 1f 22 a4 00 f3 2b 27
                hex a4 01 1f 22 a4 00 f4 2b 27 a4 01 1f 22 a4 00 2b
                hex 27 a4 02 1f 22 2b 27 a4 01 1f 22 a4 00 f3 2b 27
                hex a4 01 1f 22 a4 00 f2 2b 27 a4 01 1f 22 a4 00 2b
                hex 27 a4 01 1f 22 a4 00 f2 2b 27 a4 01 1f 22 a4 00
                hex f3 2b 27 a4 02 1f 22 2b 27 a4 01 1f 22 a4 00 f2
                hex 2c 29 a4 01 20 24 a4 00 f3 2c 29 a4 01 20 24 a4
                hex 00 f4 2c 29 a4 02 20 24 2c 29 a4 01 20 24 a4 00
                hex f3 2c 29 a4 01 20 24 a4 00 f2 2c 29 a4 01 20 24
                hex a4 00 2c 29 a4 01 20 24 a4 00 f2 2c 29 a4 01 20
                hex 24 a4 00 f3 2c 29 a4 02 20 24 f4 2c 29 a4 01 20
                hex 24 a4 00 f2 2c 29 a4 01 20 84 24 00 e2 18 04 7f
                hex 00 18 02 7f 00 18 01 e3 24 07 9c 55 00 02 7f 00
                hex e2 9c 00 18 04 7f 00 24 02 7f 00 e1 26 01 e3 27
                hex 03 e2 24 03 18 04 7f 00 18 02 7f 00 18 01 e3 24
                hex 07 9c 55 00 02 7f 00 e2 9c 00 18 04 7f 00 e3 24
                hex 02 7f 00 e1 26 01 e3 27 03 24 01 24 01 82 01 e4
                hex fa 1a f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 e6 ff
                hex 1a e4 f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 fa 1a
                hex f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 e6 ff 1a e4
                hex f5 11 e5 fa 1a e4 f5 11 fa 1a f5 11 fa 1a f5 11
                hex e5 fa 1a e4 f5 11 e6 ff 1a e4 f5 11 fa 1a f5 11
                hex e5 fa 1a e4 f5 11 fa 1a f5 11 fa 1a e6 ff 1a e5
                hex fa 1a e4 fa 1a e6 ff 1a e4 1a e6 ff 1a 84 ff 1a
                hex 01 00 57 82 00 e0 a4 02 f5 27 f3 00 f5 24 f3 27
                hex f5 27 f3 24 f5 2b f3 27 f5 30 f3 2b f5 2b f3 30
                hex f5 30 f3 2b f5 33 f3 30 f5 37 f3 33 f5 35 f3 37
                hex f5 33 f3 35 f5 35 f3 33 f5 33 f3 35 f5 32 f3 33
                hex f5 30 f3 32 f5 2b f3 30 f5 29 f3 2b f5 2b f3 29
                hex f5 30 f3 2b f5 2e f3 30 f5 30 f3 2e f5 2b f3 30
                hex f5 2c f3 2b f5 2b f3 2c f5 2c f3 2b f5 30 f3 2c
                hex f5 38 f3 30 f5 33 f3 38 f5 32 f3 33 f5 38 f3 32
                hex f5 35 f3 38 f5 32 f3 35 f5 30 f3 32 f5 32 f3 30
                hex f5 30 f3 32 f5 2f f3 30 f5 2b f3 2f f5 30 f3 2b
                hex f5 2f f3 30 f5 26 f3 2f f5 30 f3 26 f5 2f f3 30
                hex f5 29 f3 2f f5 26 84 f3 29 00 82 00 e0 a4 00 f2
                hex 2b 27 a4 01 1f 22 a4 00 f3 2b 27 a4 01 1f 22 a4
                hex 00 f4 2b 27 a4 01 1f 22 a4 00 2b 27 a4 02 1f 22
                hex 2b 27 a4 01 1f 22 a4 00 f3 2b 27 a4 01 1f 22 a4
                hex 00 f2 2b 27 a4 01 1f 22 a4 00 2b 27 a4 01 1f 22
                hex a4 00 f2 2b 27 a4 01 1f 22 a4 00 f3 2b 27 a4 02
                hex 1f 22 2b 27 a4 01 1f 22 a4 00 f2 2c 29 a4 01 20
                hex 24 a4 00 f3 2c 29 a4 01 20 24 a4 00 f4 2c 29 a4
                hex 02 20 24 2c 29 a4 01 20 24 a4 00 f3 2c 29 a4 01
                hex 20 24 a4 00 f2 2c 29 a4 01 20 24 a4 00 2c 2b a4
                hex 01 26 23 a4 00 f2 2c 2b a4 01 26 23 a4 00 f3 2c
                hex 2b a4 02 26 23 f4 2c 2b a4 01 26 23 a4 00 27 26
                hex a4 01 23 84 1f 00 e2 18 04 7f 00 18 02 7f 00 18
                hex 01 e3 24 07 9c 55 00 02 7f 00 e2 9c 00 18 01 18
                hex 02 7f 00 24 02 7f 00 e1 26 01 e3 27 03 e2 24 03
                hex 14 04 7f 00 14 02 7f 00 e1 18 01 e3 20 07 9c 55
                hex 00 02 7f 00 e2 9c 00 1f 01 1f 03 1f 01 e1 2c 01
                hex 2e 00 2c 00 e2 2b 05 e3 1f 01 82 01 e4 fa 1a f5
                hex 11 fa 1a f5 11 e5 fa 1a e4 f5 11 e6 ff 1a e4 f5
                hex 11 fa 1a f5 11 e5 fa 1a e4 f5 11 fa 1a f5 11 fa
                hex 1a f5 11 e5 fa 1a e4 f5 11 e6 ff 1a e4 f5 11 e5
                hex fa 1a e4 f5 11 fa 1a f5 11 fa 1a f5 11 e5 fa 1a
                hex e4 f5 11 e6 ff 1a e4 f5 11 fa 1a f5 11 e5 fa 1a
                hex e4 f5 11 fa 1a f5 11 fa 1a ff 1a fa 1a 84 fa 1a
                hex 00 fa 1a 00 82 01 e6 ff 1a e4 1a ff 1a 84 e6 ff
                hex 1a 01 82 00 e0 a4 02 f5 27 f3 00 f5 24 f3 27 f5
                hex 27 f3 24 f5 2b f3 27 f5 30 f3 2b f5 2b f3 30 f5
                hex 30 f3 2b f5 33 f3 30 f5 37 f3 33 f5 35 f3 37 f5
                hex 33 f3 35 f5 35 f3 33 f5 33 f3 35 f5 32 f3 33 f5
                hex 30 f3 32 f5 32 f3 30 f5 30 f3 32 f5 2e f3 30 f5
                hex 2b f3 2e f5 27 f3 2b f5 24 f3 27 f5 27 f3 24 f5
                hex 2c f3 27 f5 2e f3 2c f5 30 f3 2e f5 2c f3 30 f5
                hex 33 f3 2c f5 38 f3 33 f5 3a f3 38 f5 3c f3 3a f5
                hex 38 f3 3c f5 2c f3 38 f5 33 f3 2c f5 30 f3 33 f5
                hex 2e f3 30 f5 29 f3 2e f5 2e f3 29 f5 30 f3 2e f5
                hex 32 f3 30 f5 35 f3 32 84 f5 2c 03 f5 29 03 82 00
                hex e0 a4 00 f2 2b 27 a4 01 1f 22 a4 00 f3 2b 27 a4
                hex 01 1f 22 a4 00 f4 2b 27 a4 01 1f 22 a4 00 2b 27
                hex a4 02 1f 22 2b 27 a4 01 1f 22 a4 00 f3 2b 27 a4
                hex 01 1f 22 a4 00 2c 29 a4 01 20 24 a4 00 2c 29 a4
                hex 01 20 24 a4 00 2c 29 a4 01 20 24 a4 00 2c 29 a4
                hex 02 20 24 2c 29 a4 01 20 24 a4 00 2c 27 a4 01 20
                hex 24 a4 00 f3 2c 27 a4 01 20 24 a4 00 f4 2c 27 a4
                hex 02 20 24 2c 27 a4 01 20 24 a4 00 f3 2c 27 a4 01
                hex 20 24 a4 00 f2 2c 27 a4 01 20 24 a4 00 26 22 a4
                hex 01 1d 22 a4 00 f2 26 22 a4 01 1d 22 a4 00 f3 26
                hex 22 a4 02 1d 22 82 01 f4 26 a4 01 00 a4 00 f4 26
                hex 84 a4 01 00 01 e2 18 04 7f 00 18 02 7f 00 18 01
                hex e3 24 07 9c 55 00 02 7f 00 e2 9c 00 11 04 7f 00
                hex 29 03 e1 2b 01 e3 2c 03 e1 29 03 e2 14 04 7f 00
                hex 14 03 e1 1b 01 e3 2c 05 96 03 00 05 e2 92 22 05
                hex 2e 03 e1 20 00 22 00 e3 23 03 e2 17 03 82 01 e4
                hex fa 1a f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 e6 ff
                hex 1a e4 f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 fa 1a
                hex f5 11 fa 1a f5 11 e5 fa 1a e4 f5 11 e6 ff 1a e4
                hex f5 11 e5 fa 1a e4 f5 11 fa 1a f5 11 fa 1a f5 11
                hex e5 fa 1a e4 f5 11 e6 ff 1a e4 f5 11 fa 1a f5 11
                hex e5 fa 1a e4 f5 11 fa 1a f5 11 fa 1a ff 1a fa 1a
                hex 84 fa 1a 00 fa 1a 00 82 01 e6 ff 1a e4 1a e6 ff
                hex 1a 84 e4 ff 1a 01 82 00 e0 a4 00 f5 21 f3 00 f5
                hex 1e f3 21 f5 21 f3 1e f5 25 f3 21 f5 2a f3 25 f5
                hex 25 f3 2a f5 21 f3 25 f5 25 f3 21 f5 2d f3 25 f5
                hex 2c f3 2d f5 2a f3 2c f5 25 f3 2a f5 21 f3 25 f5
                hex 20 f3 21 f5 1e f3 20 f5 25 f3 1e f5 26 f3 25 f5
                hex 21 f3 26 f5 25 f3 21 f5 28 f3 25 f5 2a f3 28 f5
                hex 25 f3 2a f5 26 f3 25 f5 28 f3 26 f5 26 f3 28 f5
                hex 25 f3 26 f5 26 f3 25 f5 28 f3 26 f5 2a f3 28 f5
                hex 2d f3 2a f5 2c f3 2d f5 2a f3 2c f5 28 f3 2a f5
                hex 26 f3 28 f5 25 f3 26 f5 28 f3 25 f5 26 f3 28 f5
                hex 25 f3 26 f5 23 f3 25 f5 21 f3 23 f5 20 f3 21 f5
                hex 19 f3 20 f5 25 f3 19 f5 29 84 f3 25 00 82 00 e0
                hex a4 00 f2 25 21 a4 01 19 1c a4 00 f3 25 21 a4 01
                hex 19 1c a4 00 f4 25 21 a4 01 19 1c a4 00 25 21 a4
                hex 02 19 1c 25 21 a4 01 19 1c a4 00 f3 25 21 a4 01
                hex 19 1c a4 00 f2 25 21 a4 01 19 1c a4 00 25 21 a4
                hex 01 19 1c a4 00 f2 25 21 a4 01 19 1c a4 00 f3 25
                hex 21 a4 02 19 1c 25 21 a4 01 19 1c a4 00 f2 26 23
                hex a4 01 1a 1e a4 00 f3 26 23 a4 01 1a 1e a4 00 f4
                hex 26 23 a4 02 1a 1e 26 23 a4 01 1a 1e a4 00 f3 26
                hex 23 a4 01 1a 1e a4 00 f2 26 23 a4 01 1a 1e a4 00
                hex 26 23 a4 01 1a 1e a4 00 f2 26 23 a4 01 1a 1e a4
                hex 00 f3 26 23 a4 02 1a 1e f4 26 23 a4 01 1a 1e a4
                hex 00 f2 26 23 a4 01 1a 84 1e 00 e2 12 04 7f 00 12
                hex 02 7f 00 12 01 e3 1e 07 9c 55 00 02 7f 00 e2 9c
                hex 00 12 04 7f 00 1e 02 7f 00 e1 20 01 e3 21 03 e2
                hex 1e 03 12 04 7f 00 12 02 7f 00 12 01 e3 1e 07 9c
                hex 55 00 02 7f 00 e2 9c 00 12 04 7f 00 e3 1e 02 7f
                hex 00 e1 20 01 e3 21 03 1e 01 1e 01 82 00 e0 a4 00
                hex f5 21 f3 00 f5 1e f3 21 f5 21 f3 1e f5 25 f3 21
                hex f5 2a f3 25 f5 25 f3 2a f5 21 f3 25 f5 25 f3 21
                hex f5 2d f3 25 f5 2c f3 2d f5 2a f3 2c f5 25 f3 2a
                hex f5 21 f3 25 f5 20 f3 21 f5 1e f3 20 f5 25 f3 1e
                hex f5 26 f3 25 f5 21 f3 26 f5 25 f3 21 f5 28 f3 25
                hex f5 2a f3 28 f5 25 f3 2a f5 27 f3 25 f5 2a f3 27
                hex f5 27 f3 2a f5 23 f3 27 f5 21 f3 23 f5 20 f3 21
                hex f5 1e f3 20 f5 1b f3 1e f5 27 f3 1b f5 23 f3 27
                hex f5 2f f3 23 f5 2a f3 2f f5 26 f3 2a f5 28 f3 26
                hex f5 26 f3 28 f5 25 f3 26 f5 23 f3 25 f5 2f f3 23
                hex f5 2d f3 2f f5 2c f3 2d f5 2a f3 2c f5 25 84 f3
                hex 2a 00 82 00 e0 a4 00 f2 25 21 a4 01 19 1c a4 00
                hex f3 25 21 a4 01 19 1c a4 00 f4 25 21 a4 01 19 1c
                hex a4 00 25 21 a4 02 19 1c 25 21 a4 01 19 1c a4 00
                hex f3 25 21 a4 01 19 1c a4 00 f2 26 23 a4 01 1e 19
                hex a4 00 26 23 a4 01 1e 19 a4 00 f2 26 23 a4 01 1e
                hex 19 a4 00 f3 26 23 a4 02 1e 19 26 23 a4 01 1e 19
                hex a4 00 27 23 a4 01 1e 1b a4 00 f3 27 23 a4 01 1e
                hex 1b a4 00 f4 27 23 a4 02 1e 1b 27 23 a4 01 1e 1b
                hex a4 00 f3 27 23 a4 01 1e 1b a4 00 f2 27 23 a4 01
                hex 1e 1b a4 00 26 21 a4 01 1e 1a a4 00 f2 26 21 a4
                hex 01 1e 1a a4 00 f3 26 21 a4 02 1e 1a f4 29 25 a4
                hex 01 20 1d a4 00 f2 29 25 a4 01 20 84 1d 00 e2 12
                hex 04 7f 00 12 02 7f 00 12 01 e3 1e 07 9c 55 96 05
                hex 00 02 7f 00 e2 9c 00 92 12 04 7f 00 1e 02 7f 00
                hex e1 20 01 e3 21 03 e2 1e 03 0f 04 7f 00 0f 02 7f
                hex 00 0f 01 e3 27 07 9c 55 96 05 00 02 7f 00 e2 9c
                hex 00 92 98 20 0e 03 82 01 26 e3 00 e1 23 24 84 e3
                hex 25 03 19 01 00 01 e0 f5 29 07 9c 55 00 07 b2 01
                hex 00 2f 9c 00 00 17 82 00 e0 a4 00 f2 29 25 a4 01
                hex 20 23 a4 00 f3 29 25 a4 01 1d 23 a4 00 f4 29 25
                hex a4 01 20 23 a4 00 29 25 a4 02 1d 23 29 25 a4 01
                hex 20 23 a4 00 f3 29 25 a4 01 1d 23 a4 00 f2 29 25
                hex a4 01 20 23 a4 00 29 25 a4 01 1d 23 a4 00 f2 29
                hex 25 a4 01 20 23 a4 00 f3 29 25 a4 02 1d 23 29 25
                hex a4 01 20 23 a4 00 29 25 a4 01 1d 23 a4 00 f3 29
                hex 25 a4 01 20 23 a4 00 f4 29 25 a4 02 1d 23 29 25
                hex a4 01 1d 23 a4 00 f3 29 25 a4 01 1d 23 a4 00 f2
                hex 29 25 a4 01 1d 23 a4 00 29 f1 25 a4 01 1d 23 f0
                hex 29 25 1d 84 23 0c e2 0d 04 0d 03 7f 07 25 03 19
                hex 00 7f 10 e3 25 01 e1 23 03 24 01 e3 31 02 7f 00
                hex e2 25 01 7f 0b 19 03 e3 0d 01 7f 10 e4 fa 1a 02
                hex f7 1a 01 fa 1a 03 f7 1a 01 fa 1a 03 f7 1a 01 fa
                hex 1a 03 f7 1a 01 fa 1a 03 f7 1a 01 fa 1a 03 f7 1a
                hex 01 fa 1a 03 e6 f7 1a 01 e4 fa 1a 03 f7 1a 01 e6
                hex fa 1a 03 e4 f7 1a 01 fa 1a 03 f7 1a 01 fa 1a 03
                hex f7 1a 01 fa 1a 03 e6 fa 1a 12 00 1b 82 00 e0 a4
                hex 00 f1 2c 2b a4 01 26 23 a4 00 2c 2b a4 01 26 23
                hex a4 00 2c 2b a4 01 26 23 a4 00 2c 2b a4 02 26 23
                hex 27 26 a4 01 23 1f a4 00 f3 2c 2b a4 01 26 23 a4
                hex 00 f2 2c 2b a4 01 26 23 a4 00 f3 2c 2b a4 01 26
                hex 23 a4 00 f4 2c 2b a4 01 26 23 a4 00 27 26 a4 02
                hex 23 1f 2c 2b a4 01 26 23 a4 00 f3 2c 2b a4 01 26
                hex 23 2c 2b 26 23 2c 2b 26 23 27 26 23 84 1f 00 00
                hex 3f 82 01 e2 23 e0 1f e3 1a e0 18 17 84 13 0d e0
                hex b2 00 92 f1 1d 01 b2 10 00 05 b2 01 00 03 b2 00
                hex f1 19 0f 9a 03 f1 19 03 b2 10 00 07 b2 01 00 07
                hex b2 00 00 07 82 00 92 b2 00 f1 1d f0 20 f1 1d f0
                hex 20 f1 1d f0 20 f2 1d f1 20 f2 1d f1 20 f2 1d f1
                hex 20 f3 1d f2 20 f3 1d f2 20 f3 1d f2 20 f4 1d 8c
                hex 01 f3 20 84 e5 fa 1a 0b fc 0d 06 0e 10 0e 21 0e
                hex 23 0e 5d 0e 21 0e 9c 0e 21 0e a8 0e 5d 0e 21 0e
                hex 82 08 e7 2e e8 2e e7 2e e8 2e 84 e7 2e 05 e8 2e
                hex 05 00 2f e2 22 05 e3 1d 02 e2 92 16 05 e1 98 44
                hex 25 02 e3 92 2e 02 9c 25 00 05 e2 9c 00 22 02 e3
                hex 00 03 96 1f 00 01 e2 00 01 82 00 7f 92 25 e1 00
                hex 00 84 e3 24 02 e2 25 00 e1 00 00 00 00 82 02 e5
                hex ff 11 e4 f5 14 e6 fa 11 e5 ff 14 e4 f6 11 e5 fa
                hex 14 e6 ff 11 e4 f5 14 11 e5 ff 14 e6 11 e4 f5 14
                hex e5 ff 11 84 e4 f5 14 00 f3 14 00 f5 14 00 e6 ff
                hex 14 02 e4 f5 14 00 f3 14 00 f5 14 00 e9 27 08 ea
                hex 30 08 e9 27 08 ea 30 14 e2 27 03 96 0f 00 01 e3
                hex 92 0f 02 e2 22 05 1e 02 e3 25 03 9c 55 00 04 e2
                hex 9c 00 24 02 e3 00 01 9c 55 00 03 82 02 9c 00 7f
                hex e2 1d e3 25 84 e1 24 02 0e ad 18 ad 22 ad 2c ad
                hex 7a ad f6 ad b0 ad 20 b0 53 ad 95 ad b2 ae b0 ad
                hex 77 b0 2c ad 7a ad 69 af b0 ad c3 b0 83 ba 84 df
                hex 85 01 89 39 8a 0d 01 84 3a 85 02 89 35 8a 01 01
                hex 84 80 89 34 01 84 74 85 04 89 33 01 84 9d 85 05
                hex 89 31 00 83 ba 84 bd 85 01 89 39 8a 0d 01 84 11
                hex 85 02 89 35 8a 01 01 84 52 89 34 01 84 23 85 04
                hex 89 33 01 84 37 85 05 89 31 00 83 b5 84 7e 85 00
                hex 89 34 8a 80 01 83 b3 84 3f 01 83 b2 89 32 01 83
                hex b1 89 30 02 00 83 b5 84 75 85 00 89 34 8a 80 01
                hex 83 b3 84 3a 01 83 b2 89 32 01 83 b1 89 30 02 00
                hex 89 3f 8a 03 01 89 3e 01 8a 05 01 89 3d 01 8a 07
                hex 01 89 3c 01 8a 08 01 89 3b 01 8a 0a 01 89 3a 02
                hex 89 39 8a 0c 02 89 38 8a 0b 02 89 37 02 89 36 02
                hex 89 35 01 8a 0c 01 89 34 01 8a 0b 01 89 33 02 89
                hex 32 02 89 31 04 00 80 be 81 eb 82 01 83 38 84 a8
                hex 85 06 89 3e 8a 0e 01 80 bd 81 2b 82 02 01 81 6b
                hex 83 37 8a 09 01 80 bc 81 ab 01 80 bb 81 eb 89 3d
                hex 8a 03 01 81 2b 82 03 83 36 01 80 ba 81 96 01 81
                hex d6 01 80 b9 81 16 82 04 83 35 89 3c 01 80 b8 81
                hex 56 01 81 96 83 34 01 80 b7 81 d6 01 80 b6 81 16
                hex 82 05 89 3b 01 81 56 83 33 01 80 b5 81 96 01 81
                hex d6 01 80 b4 81 16 82 06 83 32 89 3a 8a 09 01 80
                hex b3 81 56 01 81 96 83 31 8a 03 01 80 b2 81 d6 01
                hex 80 b1 81 16 82 07 89 39 01 81 56 01 81 96 01 80
                hex 30 83 30 01 89 38 04 89 37 04 89 36 8a 09 02 8a
                hex 03 02 89 35 04 89 34 04 89 33 04 89 32 04 89 31
                hex 04 00 80 be 81 cc 82 01 83 38 84 2f 85 06 89 3e
                hex 8a 0e 01 80 bd 81 0c 82 02 01 81 4c 83 37 8a 09
                hex 01 80 bc 81 8c 01 80 bb 81 cc 89 3d 8a 03 01 81
                hex 59 82 03 83 36 01 80 ba 81 99 01 81 d9 01 80 b9
                hex 81 19 82 04 83 35 89 3c 01 80 b8 81 59 01 81 99
                hex 83 34 01 80 b7 81 d9 01 80 b6 81 19 82 05 89 3b
                hex 01 81 59 83 33 01 80 b5 81 99 8a 09 01 81 d9 8a
                hex 03 01 80 b4 81 19 82 06 83 32 89 3a 01 80 b3 81
                hex 59 01 81 99 83 31 01 80 b2 81 d9 01 80 b1 81 19
                hex 82 07 89 39 01 81 59 01 81 99 01 80 30 83 30 01
                hex 89 38 03 8a 09 01 89 37 01 8a 03 03 89 36 04 89
                hex 35 04 89 34 04 89 33 03 00 80 be 81 eb 82 01 83
                hex 38 84 a8 85 06 89 3e 8a 0e 01 80 bd 81 2b 82 02
                hex 01 81 6b 83 37 8a 09 01 80 bc 81 ab 01 80 bb 81
                hex eb 89 3d 8a 03 01 81 96 82 03 83 36 01 80 ba 81
                hex d6 01 81 16 82 04 01 80 b9 81 56 83 35 89 3c 01
                hex 80 b8 81 96 01 81 d6 83 34 01 80 b7 81 16 82 05
                hex 01 80 b6 81 56 89 3b 01 81 96 83 33 01 80 b5 81
                hex d6 8a 09 01 81 16 82 06 8a 03 01 80 b4 81 56 83
                hex 32 89 3a 01 80 b3 81 96 01 81 d6 83 31 01 80 b2
                hex 81 16 82 07 01 80 b1 81 56 89 39 01 81 96 01 81
                hex d6 01 80 30 83 30 01 89 38 03 8a 09 01 89 37 01
                hex 8a 03 03 89 36 04 89 35 04 89 34 04 89 33 03 00
                hex 80 b9 81 d5 82 00 01 80 b8 81 46 01 81 d5 01 80
                hex b7 01 80 b6 01 80 b9 81 8e 01 80 b8 81 2f 01 81
                hex 8e 01 80 b7 01 80 b9 81 6a 01 80 b8 81 23 01 81
                hex 6a 01 80 b7 01 80 b9 81 5e 01 80 b8 81 1f 01 81
                hex 5e 01 80 b7 01 80 b6 02 80 b5 02 80 b4 01 80 b3
                hex 02 80 b2 01 80 b1 00 80 b9 81 c6 82 00 01 80 b8
                hex 81 41 01 81 c6 01 80 b7 01 80 b9 81 84 01 80 b8
                hex 81 2b 01 81 84 01 80 b7 01 80 b9 81 62 01 80 b8
                hex 81 20 01 81 62 01 80 b9 81 57 01 80 b8 81 1d 01
                hex 81 57 01 80 b7 01 80 b6 02 80 b5 02 80 b4 01 80
                hex b3 02 00 80 b9 81 d5 82 00 01 80 b8 81 46 01 81
                hex d5 01 80 b7 01 80 b9 81 8e 01 80 b8 81 2f 01 81
                hex 8e 01 80 b7 01 80 b9 81 6a 01 80 b8 81 23 01 81
                hex 6a 01 80 b9 81 5e 01 80 b8 81 1f 01 81 5e 01 80
                hex b7 01 80 b6 02 80 b5 02 80 b4 01 80 b3 02 00

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

sub1            lda #0                       ; $b133
                sta arr_shared1+5,x
                sta arr_shared1+3,x
                sta arr_shared1+6,x
                sta arr_shared1+13,x
                lda #$30
                sta arr_shared1+7,x
                sta arr_shared1+10,x
                sta arr_shared1+16,x
                rts

sub2            asl a                        ; $b14d
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

sub3            lda arr_shared1+3,x          ; $b168
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

                sta arr1+8                   ; $b1de (unaccessed)
                lda arr_shared1+14,x         ; unaccessed
                sta arr1+10                  ; unaccessed
                lda arr_shared1+15,x         ; unaccessed
                sta arr1+11                  ; unaccessed

+               lda arr1+12                  ; $b1ea
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

                jmp sub4                     ; $b204 (unaccessed)
                jmp sub8                     ; unaccessed

sub4            asl a                        ; $b20a
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

                lda #$30                     ; $b25a (unaccessed)
                ldx #0                       ; unaccessed
-               sta arr_shared2+173,x        ; unaccessed
                inx                          ; unaccessed
                cpx #4                       ; unaccessed
                bne -                        ; unaccessed
                lda #0                       ; unaccessed

+               sta arr_shared2+37           ; $b268
                rts

sub5            pha                          ; $b26c
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

                ; $b2b1: unaccessed up to $b2c9
+               iny
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

                ; $b2ca: unaccessed up to $b2df
++              iny
                iny
                lda (ptr4),y
                iny
                sta ram26
                lda (ptr4),y
                iny
                sta arr_shared2+0
                copy #<note_freqs1, ptr6+0
                copy #>note_freqs1, ptr6+1

cod2            pla                          ; $b2e0
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

sub6            copy arr2+0, ptr3+0          ; $b326
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

sub7            asl a                        ; $b35f
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

                ; $b3b3: unaccessed up to $b3cd
+               sta ram19
                ldx #0
--              copy ram19, ram8
                lda #0
                sta arr_shared2+48,x
-               ldy #0
                lda arr_shared2+8,x
                sta ptr5+0
                lda arr_shared2+13,x
                sta ptr5+1
                ;
cod3            ; $b3ce: unaccessed up to $b40e
                lda arr_shared2+48,x
                beq +
                dec arr_shared2+48,x
                jmp ++
+               lda (ptr5),y
                bmi cod4
                lda arr_shared2+53,x
                cmp #$ff
                bne +
                iny
                lda (ptr5),y
                iny
                sta arr_shared2+48,x
                jmp ++
+               iny
                sta arr_shared2+48,x
++              clc
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
                copy #0, arr_shared2+5
                rts
                ;
                ; $b40f: unaccessed up to $b45f
cod4            cmp #$80
                beq cod8
                cmp #$82
                beq cod6
                cmp #$84
                beq cod7
                pha
                cmp #$8e
                beq cod5
                cmp #$92
                beq cod5
                cmp #$a2
                beq cod5
                and #%11110000
                cmp #$f0
                beq cod5
                cmp #$e0
                beq cod9
                iny
cod5            iny
                pla
                jmp cod3
cod6            iny
                lda (ptr5),y
                iny
                sta arr_shared2+53,x
                jmp cod3
cod7            iny
                lda #$ff
                sta arr_shared2+53,x
                jmp cod3
cod8            iny
                lda (ptr5),y
                iny
                jsr sub26
                jmp cod3
cod9            iny
                pla
                and #%00001111
                asl a
                jsr sub26
                jmp cod3

sub8            lda ram18                    ; $b460
                bne +
                rts                          ; $b465 (unaccessed)
+               ldx #0
-               lda arr_shared2+28,x
                beq +

                sub #1                       ; $b46d (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                bne +                        ; unaccessed
                jsr sub9                     ; unaccessed
                lda arr_shared2+33,x         ; unaccessed
                and #%01111111               ; unaccessed
                sta arr_shared2+33,x         ; unaccessed

+               inx                          ; $b480
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
                lda #0                       ; $b4a9 (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                jsr sub9                     ; unaccessed
+               jsr sub9                     ; $b4b1
                lda arr_shared2+33,x
                and #%01111111
                sta arr_shared2+33,x
                inx
                cpx #5
                bne -
                lda arr_shared2+3
                beq +

                sub #1                       ; $b4c6 (unaccessed)
                sta ram20                    ; unaccessed
                copy #1, ram21               ; unaccessed
                jmp cod10                    ; unaccessed

+               lda arr_shared2+4            ; $b4d4
                beq ++
                sub #1
                sta arr_shared2+5
                inc ram20
                lda ram20
                cmp arr3+0
                beq +
                copy #1, ram21               ; $b4ea (unaccessed)
                jmp cod10                    ; unaccessed
+               copy #0, ram20               ; $b4f2
                copy #1, ram21
                jmp cod10
++              inc ram19
                lda ram19
                cmp arr3+1
                bne cod10
                inc ram20
                lda ram20
                cmp arr3+0
                beq +
                sta ram21
                jmp cod10
+               ldx #0                       ; $b51b (unaccessed)
                stx ram20                    ; unaccessed
                inx                          ; unaccessed
                stx ram21                    ; unaccessed
cod10           jsr sub13                    ; $b524
cod11           sec                          ; $b527
                lda ram22
                sbc ram24
                sta ram22
                lda ram23
                sbc ram25
                sta ram23
                ldx #0
-               lda arr_shared2+33,x
                beq +

                sub #1                       ; $b541 (unaccessed)
                sta arr_shared2+33,x         ; unaccessed
                bne +                        ; unaccessed
                sta arr_shared2+18,x         ; unaccessed
                sta arr_shared2+165,x        ; unaccessed
                sta arr_shared2+161,x        ; unaccessed
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed

+               inx                          ; $b558
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
                jsr sub29
                rts

sub9            ldy arr_shared2+48,x         ; $b576
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
cod12           lda (ptr5),y                 ; $b593
                bpl +
                jmp cod16
+               beq cod13
                cmp #$7f
                bne +
                jmp cod15
+               cmp #$7e
                bne +
                jmp cod14                    ; $b5a7 (unaccessed)
+               sta arr_shared2+18,x
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
+               lda #0                       ; $b5e7 (unaccessed)
                sta arr_shared2+153,x        ; unaccessed
++              cpx #2                       ; $b5ec
                bcc +
                jmp cod17
+               lda #0
                sta arr_shared2+79,x
cod13           jmp cod17

cod14           lda arr_shared2+38,x         ; $b5fb (unaccessed)
                cmp #1                       ; unaccessed
                beq cod13                    ; unaccessed
                lda #1                       ; unaccessed
                sta arr_shared2+38,x         ; unaccessed
                jsr sub24                    ; unaccessed
                jmp cod17                    ; unaccessed

cod15           lda #0                       ; $b60d
                sta arr_shared2+18,x
                sta arr_shared2+121,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
                sta arr_shared2+62,x
                sta arr_shared2+58,x
                cpx #2
                bcs +
+               jmp cod17
-               pla
                asl a
                asl a
                asl a
                and #%01111000
                sta arr_shared2+23,x
                iny
                jmp cod12
--              pla
                and #%00001111
                asl a
                jsr sub26
                iny
                jmp cod12
cod16           pha
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
-               sta arr_shared2+48,x
                jmp cod18
cod17           lda arr_shared2+53,x
                cmp #$ff
                bne -
                iny
                lda (ptr5),y
                sta arr_shared2+48,x
cod18           clc
                iny
                tya
                adc ptr5+0
                sta arr_shared2+8,x
                lda #0
                adc ptr5+1
                sta arr_shared2+13,x
                lda arr_shared2+2
                beq +
                sta arr_shared2+79,x         ; $b689 (unaccessed)
                copy #0, arr_shared2+2       ; unaccessed
+               rts                          ; $b691

sub10           lda (ptr5),y                 ; $b692
                pha
                iny
                pla
                rts

jump_table1     ; $b698; partially unaccessed
                dw jumptbl1a                 ;  0
                dw jumptbl1b                 ;  1
                dw jumptbl1c                 ;  2
                dw jumptbl1d                 ;  3
                dw jumptbl1e                 ;  4
                dw jumptbl1f                 ;  5
                dw jumptbl1g                 ;  6
                dw jumptbl1h                 ;  7
                dw jumptbl1i                 ;  8
                dw jumptbl1n                 ;  9
                dw jumptbl1k                 ; 10
                dw jumptbl1l                 ; 11
                dw jumptbl1j                 ; 12
                dw jumptbl1m                 ; 13
                dw jumptbl1p                 ; 14
                dw jumptbl1q                 ; 15
                dw jumptbl1r                 ; 16
                dw jumptbl1s                 ; 17
                dw jumptbl1u                 ; 18
                dw jumptbl1t                 ; 19
                dw jumptbl1o                 ; 20
                dw jumptbl1u                 ; 21
                dw jumptbl1v                 ; 22
                dw jumptbl1v                 ; 23
                dw jumptbl1x                 ; 24
                dw jumptbl1y                 ; 25
                dw jumptbl1z                 ; 26
                dw sub11                     ; 27
                dw sub11                     ; 28

jumptbl1a       jsr sub10                    ; $b6d2 (unaccessed)
                jsr sub26                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1b       jsr sub10                    ; $b6db
                sta arr_shared2+53,x
                jmp cod12

jumptbl1c       lda #$ff                     ; $b6e4
                sta arr_shared2+53,x
                jmp cod12

jumptbl1d       jsr sub10                    ; $b6ec (unaccessed)
                sta arr3+2                   ; unaccessed
                jsr sub14                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1e       jsr sub10                    ; $b6f8 (unaccessed)
                sta arr3+3                   ; unaccessed
                jsr sub14                    ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1f       jsr sub10                    ; $b704 (unaccessed)
                sta arr_shared2+3            ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1g       jsr sub10                    ; $b70d
                sta arr_shared2+4
                jmp cod12

jumptbl1h       jsr sub10                    ; $b716 (unaccessed)
                copy #0, ram18               ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1i       jsr sub10                    ; $b721 (unaccessed)
                sta arr_shared2+1            ; unaccessed
                sta arr_shared2+121,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1j       jsr sub10                    ; $b72d
                sta arr_shared2+157,x
                lda #2
                sta arr_shared2+153,x
                jmp cod12

jumptbl1k       jsr sub10                    ; $b73b (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #3                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1l       jsr sub10                    ; $b749
                sta arr_shared2+157,x
                lda #4
                sta arr_shared2+153,x
                jmp cod12

jumptbl1m       jsr sub10                    ; $b757
                sta arr_shared2+157,x
                lda #0
                sta arr_shared2+169,x
                lda #1
                sta arr_shared2+153,x
                jmp cod12

jumptbl1n       lda #0                       ; $b76a
                sta arr_shared2+157,x
                sta arr_shared2+153,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
                jmp cod12

jumptbl1o       jsr sub10                    ; $b77b (unaccessed)
                sta arr_shared2+2            ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1p       jsr sub10                    ; $b784
                pha
                lda arr_shared2+181,x
                bne ++
                lda arr2+4
                and #%00000010
                beq +
                lda #$30                     ; $b794 (unaccessed)
+               sta arr_shared2+173,x
++              pla
                pha
                and #%11110000
                sta arr_shared2+177,x
                pla
                and #%00001111
                sta arr_shared2+181,x
                jmp cod12

jumptbl1q       jsr sub10                    ; $b7a9 (unaccessed)
                pha                          ; unaccessed
                and #%11110000               ; unaccessed
                sta arr_shared2+189,x        ; unaccessed
                pla                          ; unaccessed
                and #%00001111               ; unaccessed
                sta arr_shared2+193,x        ; unaccessed
                cmp #0                       ; unaccessed
                beq +                        ; unaccessed
                jmp cod12                    ; unaccessed
+               sta arr_shared2+185,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1r       jsr sub10                    ; $b7c5 (unaccessed)
                sta arr_shared2+43,x         ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1s       lda #$80                     ; $b7ce (unaccessed)
                sta arr_shared2+43,x         ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1t       jsr sub10                    ; $b7d6 (unaccessed)
                sta arr_shared2+28,x         ; unaccessed
                dey                          ; unaccessed
                jmp cod18                    ; unaccessed

jumptbl1u       jsr sub10                    ; $b7e0
                sta arr_shared2+125,x
                clc
                asl a
                asl a
                asl a
                asl a
                ora arr_shared2+125,x
                sta arr_shared2+125,x
                jmp cod12

jumptbl1v       jsr sub10                    ; $b7f4 (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #5                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1x       jsr sub10                    ; $b802 (unaccessed)
                sta arr_shared2+157,x        ; unaccessed
                lda #7                       ; unaccessed
                sta arr_shared2+153,x        ; unaccessed
                jmp cod12                    ; unaccessed

jumptbl1y       jsr sub10                    ; $b810
                sta arr_shared2+74,x
                jmp cod12

jumptbl1z       jsr sub10                    ; $b819 (unaccessed)
                ora #%10000000               ; unaccessed
                sta arr_shared2+33,x         ; unaccessed
                jmp cod12                    ; unaccessed

sub11           sub #1                       ; $b824
                cpx #3
                beq +
                asl a
                sty ram7
                tay
cod19           lda (ptr6),y
                sta arr_shared2+62,x
                iny
                lda (ptr6),y
                sta arr_shared2+58,x
                ldy ram7
                rts
+               and #%00001111
                ora #%00010000
                sta arr_shared2+62,x
                lda #0
                sta arr_shared2+58,x
                rts

sub12           sub #1                       ; $b84a
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
++              jmp cod19
                rts                          ; $b881 (unaccessed)
cod20           ora #%00010000
                pha
                lda arr_shared2+153,x
                cmp #2
                bne ++

                pla                          ; $b88c (unaccessed)
                sta arr_shared2+165,x        ; unaccessed
                lda #0                       ; unaccessed
                sta arr_shared2+161,x        ; unaccessed
                lda arr_shared2+62,x         ; unaccessed
                ora arr_shared2+58,x         ; unaccessed
                bne +                        ; unaccessed
                lda arr_shared2+165,x        ; unaccessed
                sta arr_shared2+62,x         ; unaccessed
                lda arr_shared2+161,x        ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; unaccessed

++              pla                          ; $b8aa
                sta arr_shared2+62,x
                lda #0
                sta arr_shared2+58,x
                rts

sub13           clc                          ; $b8b4
                lda ram22
                adc ram26
                sta ram22
                lda ram23
                adc arr_shared2+0
                sta ram23
                rts

sub14           tya                          ; $b8c8
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

sub15           lda #0                       ; $b90c
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

sub16           lda arr_shared2+74,x         ; $b931
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
                lda #$7f                     ; $b95b (unaccessed)
+               sta arr_shared2+23,x
cod21           lda arr_shared2+153,x
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
cod23           jmp cod29
cod24           jmp cod31                    ; $b98a (unaccessed)
cod25           jmp cod33                    ; unaccessed
cod26           jmp cod34                    ; unaccessed
cod27           jmp cod28                    ; unaccessed
rts1            rts                          ; $b996

                ; $b997: unaccessed up to $ba0f
cod28           lda arr_shared2+62,x
                pha
                lda arr_shared2+58,x
                pha
                lda arr_shared2+157,x
                and #%00001111
                sta ram7
                lda arr_shared2+153,x
                cmp #5
                beq ++
                lda arr_shared2+18,x
                sub ram7
                bpl +
                lda #1
+               bne +
                lda #1
+               jmp +
++              lda arr_shared2+18,x
                add ram7
                cmp #$60
                bcc +
                lda #$60
+               sta arr_shared2+18,x
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
                cmp #6
                beq +
                lda #6
                sta arr_shared2+153,x
                jmp cod21
+               lda #8
                sta arr_shared2+153,x
++              jmp cod21

sub17           lda arr_shared2+62,x         ; $ba10
                sta arr_shared2+66,x
                lda arr_shared2+58,x
                sta arr_shared2+70,x
                lda arr_shared2+43,x
                cmp #$80
                beq +

                ; $ba23: unaccessed up to $ba4a
                lda arr_shared2+18,x
                beq +
                clc
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

+               jsr sub20                    ; $ba4b
                jsr sub21
                rts
cod29           lda arr_shared2+157,x        ; $ba52
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
++              lda arr_shared2+157,x
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
+               lda arr_shared2+165,x
                sta arr_shared2+62,x
                lda arr_shared2+161,x
                sta arr_shared2+58,x
cod30           jmp rts1

cod31           lda arr_shared2+157,x        ; $bac6 (unaccessed)
                sta ptr3+0                   ; unaccessed
                copy #0, ptr3+1              ; unaccessed
                jsr sub19                    ; unaccessed
                jsr sub28                    ; unaccessed
                jmp rts1                     ; unaccessed

cod32           lda arr_shared2+157,x        ; $bad8
                sta ptr3+0
                copy #0, ptr3+1
                jsr sub18
                jsr sub28
                jmp rts1

sub18           clc                          ; $baea
                lda arr_shared2+62,x
                adc ptr3+0
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                adc ptr3+1
                sta arr_shared2+58,x
                bcc +
                lda #$ff                     ; $bafd (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; $bb05

sub19           sec                          ; $bb06
                lda arr_shared2+62,x
                sbc ptr3+0
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                sbc ptr3+1
                sta arr_shared2+58,x
                bcs +
                lda #0                       ; $bb19 (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
+               rts                          ; $bb21

                ; $bb22: unaccessed up to $bb85
cod33           sec
                lda arr_shared2+62,x
                sbc arr_shared2+157,x
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                sbc #0
                sta arr_shared2+58,x
                bmi +
                cmp arr_shared2+161,x
                bcc +
                bne ++
                lda arr_shared2+62,x
                cmp arr_shared2+165,x
                bcc +
                jmp rts1
cod34           clc                          ; $bb48
                lda arr_shared2+62,x
                adc arr_shared2+157,x
                sta arr_shared2+62,x
                lda arr_shared2+58,x
                adc #0
                sta arr_shared2+58,x
                cmp arr_shared2+161,x
                bcc ++
                bne +
                lda arr_shared2+62,x
                cmp arr_shared2+165,x
                bcs +
                jmp rts1
+               lda arr_shared2+165,x
                sta arr_shared2+62,x
                lda arr_shared2+161,x
                sta arr_shared2+58,x
                lda #0
                sta arr_shared2+153,x
                sta arr_shared2+165,x
                sta arr_shared2+161,x
++              jmp rts1

cod35           lda arr_shared2+169,x        ; $bb86
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
                sta arr_shared2+169,x        ; $bbb2 (unaccessed)
                jmp rts1                     ; unaccessed
+               inc arr_shared2+169,x        ; $bbb8
                jmp rts1
++              lda arr_shared2+157,x
                and #%00001111
                clc
                adc arr_shared2+18,x
                jsr sub11
                lda #0
                sta arr_shared2+169,x
                jmp rts1

sub20           lda arr_shared2+181,x        ; $bbd2
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
                lda dat9,y
                jmp cod37
+               ora arr_shared2+177,x
                tay
                lda dat9,y
                sta ptr3+0
                copy #0, ptr3+1
                jmp +
++              sub #$10                     ; $bc11
                sta ram7
                sec
                lda #$0f
                sbc ram7
                ora arr_shared2+177,x
                tay
                lda dat9,y
                sta ptr3+0
                copy #0, ptr3+1
                jmp +
cod36           sub #$20                     ; $bc2b
                ora arr_shared2+177,x
                tay
                lda dat9,y
cod37           eor #%11111111               ; $bc35
                sta ptr3+0
                copy #$ff, ptr3+1
                clc
                lda ptr3+0
                adc #1
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
+               lda arr2+4                   ; $bc4a
                and #%00000010
                beq +

                ; $bc51: unaccessed up to $bc6b
                lda #$0f
                clc
                adc arr_shared2+177,x
                tay
                clc
                lda dat9,y
                adc #1
                adc ptr3+0
                sta ptr3+0
                lda ptr3+1
                adc #0
                sta ptr3+1
                lsr ptr3+1
                ror ptr3+0

+               sec                          ; $bc6c
                lda arr_shared2+66,x
                sbc ptr3+0
                sta arr_shared2+66,x
                lda arr_shared2+70,x
                sbc ptr3+1
                sta arr_shared2+70,x
                rts

                clc                          ; $bc7e (unaccessed)
                lda arr_shared2+66,x         ; unaccessed
                adc ptr3+0                   ; unaccessed
                sta arr_shared2+66,x         ; unaccessed
                lda arr_shared2+70,x         ; unaccessed
                adc ptr3+1                   ; unaccessed
                sta arr_shared2+70,x         ; unaccessed
                rts                          ; unaccessed

sub21           lda arr_shared2+193,x        ; $bc90
                bne +
                lda #0
                sta arr_shared2+197,x
                rts

                ; $bc9b: unaccessed up to $bccd
+               clc
                adc arr_shared2+185,x
                and #%00111111
                sta arr_shared2+185,x
                lsr a
                cmp #$10
                bcc +
                sub #$10
                sta ram7
                sec
                lda #$0f
                sbc ram7
                ora arr_shared2+189,x
                tay
                lda dat9,y
                lsr a
                sta ram7
                jmp ++
+               ora arr_shared2+189,x
                tay
                lda dat9,y
                lsr a
                sta ram7
++              sta arr_shared2+197,x
                rts

sub22           lda arr_shared2+85,x         ; $bcce
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

                ; $bd15: unaccessed up to $bd2f
                clc
                lda arr_shared2+18,x
                adc arr_shared2+7
                cmp #1
                bcc +
                cmp #$5f
                bcc ++
                lda #$5f
                bne ++
+               lda #1
++              sta arr_shared2+18,x
                jmp cod40

cod38           lda arr_shared2+7            ; $bd30
                add #1
                jmp cod40
cod39           clc                          ; $bd39
                lda arr_shared2+18,x
                adc arr_shared2+7
                beq +
                bpl ++
+               lda #1                       ; $bd44 (unaccessed)
++              cmp #$60
                bcc cod40
                lda #$60                     ; $bd4a (unaccessed)
cod40           jsr sub11
                lda #1
                sta arr_shared2+149,x
                jmp cod42
cod41           ldy #3                       ; $bd57
                lda (ptr4),y
                beq cod42
                lda arr_shared2+149,x
                beq cod42
                lda arr_shared2+18,x
                jsr sub11
                lda #0
                sta arr_shared2+149,x
cod42           lda arr_shared2+101,x        ; $bd6d
                beq cod43

                ; $bd72: unaccessed up to $bda3
                sta ptr4+1
                lda arr_shared2+97,x
                sta ptr4+0
                lda arr_shared2+137,x
                cmp #$ff
                beq cod43
                jsr sub23
                sta arr_shared2+137,x
                clc
                lda arr_shared2+7
                adc arr_shared2+62,x
                sta arr_shared2+62,x
                lda arr_shared2+7
                bpl +
                lda #$ff
                bmi ++
+               lda #0
++              adc arr_shared2+58,x
                sta arr_shared2+58,x
                jsr sub28

cod43           lda arr_shared2+109,x        ; $bda4
                beq cod44

                ; $bda9: unaccessed up to $bded
                sta ptr4+1
                lda arr_shared2+105,x
                sta ptr4+0
                lda arr_shared2+141,x
                cmp #$ff
                beq cod44
                jsr sub23
                sta arr_shared2+141,x
                lda arr_shared2+7
                sta ptr3+0
                rol a
                bcc +
                copy #$ff, ptr3+1
                jmp ++
+               lda #0
                sta ptr3+1
++              ldy #4
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
                jsr sub28

cod44           lda arr_shared2+117,x        ; $bdee
                beq +
                ;
                ; $bdf3: unaccessed up to $be19
                sta ptr4+1
                lda arr_shared2+113,x
                sta ptr4+0
                lda arr_shared2+145,x
                cmp #$ff
                beq +
                jsr sub23
                sta arr_shared2+145,x
                lda arr_shared2+7
                pha
                lda arr_shared2+125,x
                and #%11110000
                sta arr_shared2+125,x
                pla
                ora arr_shared2+125,x
                sta arr_shared2+125,x
                ;
+               rts                          ; $be1a

sub23           add #4                       ; $be1b
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
cod45           pha                          ; $be3d
                lda arr_shared2+38,x
                bne +
                pla
                rts
                ;
+               ; $be45: unaccessed up to $be67
                ldy #2
                lda (ptr4),y
                bne +
                pla
                rts
+               pla
                lda #$ff
                rts
++              sta ram7
                lda arr_shared2+38,x
                bne +
                dey
                lda (ptr4),y
                cmp #$ff
                bne cod45
                lda ram7
                sub #1
                rts
+               lda ram7
                rts

sub24           ; $be68: unaccessed up to $bee4
                tya
                pha
                lda arr_shared2+85,x
                beq +
                sta ptr4+1
                lda arr_shared2+81,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr_shared2+129,x
+               lda arr_shared2+93,x
                beq +
                sta ptr4+1
                lda arr_shared2+89,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr_shared2+133,x
+               lda arr_shared2+101,x
                beq +
                sta ptr4+1
                lda arr_shared2+97,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr_shared2+137,x
+               lda arr_shared2+109,x
                beq +
                sta ptr4+1
                lda arr_shared2+105,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr_shared2+141,x
+               lda arr_shared2+117,x
                beq +
                sta ptr4+1
                lda arr_shared2+113,x
                sta ptr4+0
                ldy #2
                lda (ptr4),y
                beq +
                sub #1
                sta arr_shared2+145,x
+               pla
                tay
                rts

sub25           lda #0                       ; $bee5
                sta arr_shared2+129,x
                sta arr_shared2+133,x
                sta arr_shared2+137,x
                sta arr_shared2+141,x
                sta arr_shared2+145,x
                rts

sub26           sta ram9                     ; $bef7
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
                lda dat8,x
                tay
                lda dat4,y
                sta ptr3+0
                iny
                lda dat4,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)

dat4            ; $bf2b: partially unaccessed
                dw sub27
                dw sub27
                dw sub28
                dw sub28
                dw sub27
                dw sub28

sub27           ; $bf37; called by dat4
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
++              lda #0
                sta arr_shared2+81,x
                sta arr_shared2+85,x
cod46           ror ram9                     ; $bf7a
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
++              lda #0
                sta arr_shared2+89,x
                sta arr_shared2+93,x
cod47           ror ram9
                bcc ++
                ;
                ; $bfbc: unaccessed up to $bfed
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
                cmp arr_shared2+97,x
                bne +
                lda ptr3+1
                cmp arr_shared2+101,x
                bne +
                jmp cod48
+               lda ptr3+0
                sta arr_shared2+97,x
                lda ptr3+1
                sta arr_shared2+101,x
                lda #0
                sta arr_shared2+137,x
                jmp cod48
                ;
++              lda #0                       ; $bfee
                sta arr_shared2+97,x
                sta arr_shared2+101,x
cod48           ror ram9                     ; $bff6
                bcc ++
                ;
                ; $bffa: unaccessed up to $c02b
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
                cmp arr_shared2+105,x
                bne +
                lda ptr3+1
                cmp arr_shared2+109,x
                bne +
                jmp cod49
+               lda ptr3+0
                sta arr_shared2+105,x
                lda ptr3+1
                sta arr_shared2+109,x
                lda #0
                sta arr_shared2+141,x
                jmp cod49
                ;
++              lda #0                       ; $c02c
                sta arr_shared2+105,x
                sta arr_shared2+109,x
cod49           ror ram9                     ; $c034
                bcc ++
                ;
                ; $c038: unaccessed up to $c069
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
                cmp arr_shared2+113,x
                bne +
                lda ptr3+1
                cmp arr_shared2+117,x
                bne +
                jmp cod50
+               lda ptr3+0
                sta arr_shared2+113,x
                lda ptr3+1
                sta arr_shared2+117,x
                lda #0
                sta arr_shared2+145,x
                jmp cod50
                ;
++              lda #0                       ; $c06a
                sta arr_shared2+113,x
                sta arr_shared2+117,x
cod50           ldy ram7                     ; $c072
                rts

sub28           lda dat8,x                   ; $c075
                tay
                lda jump_table2,y
                sta ptr3+0
                iny
                lda jump_table2,y
                sta ptr3+1
                ldy #0
                jmp (ptr3)

jump_table2     ; $c089; partially unaccessed
                dw jumptbl2b
                dw jumptbl2c
                dw rts2
                dw jumptbl2c
                dw jumptbl2b
                dw rts2

rts2            rts                          ; $c095 (unaccessed)

jumptbl2b       lda arr_shared2+58,x         ; $c096
                bmi ++
                cmp #8
                bcc +
                lda #7                       ; $c09f (unaccessed)
                sta arr_shared2+58,x         ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr_shared2+62,x         ; unaccessed
+               rts                          ; $c0a9

++              lda #0                       ; $c0aa (unaccessed)
                sta arr_shared2+62,x         ; unaccessed
                sta arr_shared2+58,x         ; unaccessed
                rts                          ; unaccessed

                ; $c0b3: unaccessed up to $c0cf
jumptbl2c       lda arr_shared2+58,x
                bmi ++
                cmp #$10
                bcc +
                lda #$0f
                sta arr_shared2+58,x
                lda #$ff
                sta arr_shared2+62,x
+               rts
++              lda #0
                sta arr_shared2+62,x
                sta arr_shared2+58,x
                rts

sub29           lda ram18                    ; $c0d0
                bne +
                copy #0, snd_chn             ; $c0d5 (unaccessed)
                rts                          ; unaccessed

sub30           copy #$c0, joypad2           ; $c0db
                copy #$40, joypad2
                rts
+               lda arr2+5
                and #%00000001
                bne +
                jmp cod52                    ; $c0ed (unaccessed)
+               lda arr_shared2+18
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
                lda #0                       ; $c110 (unaccessed)
+               bne +
                lda arr_shared2+23
                beq +
                lda #1
+               pha
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
                copy #7,   arr_shared2+70    ; $c131 (unaccessed)
                copy #$ff, arr_shared2+66    ; unaccessed
+               lda arr_shared2+79           ; $c13b
                beq +
                ;
                ; $c140: unaccessed up to $c15d
                and #%10000000
                beq cod52
                lda arr_shared2+79
                sta arr1+1
                and #%01111111
                sta arr_shared2+79
                jsr sub30
                copy arr_shared2+66, arr1+2
                copy arr_shared2+70, arr1+3
                jmp cod52
                ;
cod51           copy #$30, arr1+0            ; $c15e
                jmp cod52
+               copy #8, arr1+1
                jsr sub30
                copy arr_shared2+66, arr1+2
                copy arr_shared2+70, arr1+3
cod52           lda arr2+5                   ; $c176
                and #%00000010
                bne +
                jmp cod54                    ; $c17d (unaccessed)
+               lda arr_shared2+19
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
                lda #0                       ; $c1a0 (unaccessed)
+               bne +
                lda arr_shared2+24           ; $c1a4 (unaccessed)
                beq +                        ; unaccessed
                lda #1                       ; unaccessed
+               pha                          ; $c1ab
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
                copy #7,   arr_shared2+71    ; $c1c1 (unaccessed)
                copy #$ff, arr_shared2+67    ; unaccessed
+               lda arr_shared2+80           ; $c1cb
                beq +

                ; $c1d0: unaccessed up to $c1ed
                and #%10000000
                beq cod54
                lda arr_shared2+80
                sta arr1+5
                and #%01111111
                sta arr_shared2+80
                jsr sub30
                copy arr_shared2+67, arr1+6
                copy arr_shared2+71, arr1+7
                jmp cod54

cod53           copy #$30, arr1+4            ; $c1ee
                jmp cod54
+               copy #8, arr1+5
                jsr sub30
                copy arr_shared2+67, arr1+6
                copy arr_shared2+71, arr1+7
cod54           lda arr2+5                   ; $c206
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
                copy #7,   arr_shared2+72    ; $c227 (unaccessed)
                copy #$ff, arr_shared2+68    ; unaccessed
+               copy arr_shared2+68, arr1+10 ; $c231
                copy arr_shared2+72, arr1+11
                jmp cod55
++              copy #0, arr1+8
cod55           lda arr2+5                   ; $c242
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
                lda #0                       ; $c269 (unaccessed)
+               bne +
                lda arr_shared2+26
                beq +
                lda #1
+               ora #%00110000
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
++              copy #$30, arr1+12
rts3            rts

dat5            hex 00 40 80 c0              ; $c29b (partially unaccessed)

dat6            ; $c29f; partially unaccessed
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

dat7            ; $c39f: partially unaccessed
                hex 01 02 03 04 05

dat8            ; $c3a4: partially unaccessed
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

dat9            ; $c529; partially unaccessed data
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

                pad $c629, $ff
