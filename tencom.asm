; "The Ten Commandments on NES" by Debiru, website
; https://debiru.itch.io/the-ten-commandments-on-nes
; unofficial disassembly by qalle
; assembles with ASM6

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array

ram0            equ $00
ram1            equ $01
ram2            equ $02
ram3            equ $03
ram4            equ $04
ram5            equ $05
ram6            equ $06
ram7            equ $07
ram8            equ $08
ram9            equ $09
ram10           equ $0a
ram11           equ $0b
ram12           equ $0c
ram13           equ $0d
ram14           equ $10
ram15           equ $12
ram16           equ $14
ram17           equ $15
ram17b          equ $16
ram18           equ $17
ram19           equ $18
ram20           equ $19
ram21           equ $1a
ram22           equ $22
ram23           equ $23
ram26           equ $2a
ram27           equ $2b
ram28           equ $2c
ram29           equ $2d
ram30           equ $32

arr5            equ $01c0
sprite_data     equ $0200
ram31           equ $0300

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
oam_addr        equ $2003
ppu_scroll      equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007

dmc_freq        equ $4010
oam_dma         equ $4014
joypad2         equ $4017

; --- iNES header -------------------------------------------------------------

                base $0000
                db "NES", $1a           ; file id
                db 2, 1                 ; 32k PRG, 8k CHR
                db %00000000, %00000000  ; mapper 0 (NROM), horiz. mirroring
                pad $0010, $00

; --- PRG ROM start -----------------------------------------------------------

; labels: 'sub' = subroutine, 'cod' = code, 'dat' = data

                base $8000

reset           sei
                ldx #$ff
                txs
                inx
                stx ppu_mask
                stx dmc_freq
                stx ppu_ctrl

                bit ppu_status
-               bit ppu_status
                bpl -
-               bit ppu_status
                bpl -

                lda #%01000000
                sta joypad2

                ; fill palettes with black
                lda #$3f
                sta ppu_addr
                stx ppu_addr            ; X is still 0
                lda #$0f
                ldx #$20
-               sta ppu_data
                dex
                bne -

                ; clear NT0-NT3 (PPU $2000-$2fff)
                txa                     ; 0 -> A
                ldy #$20
                sty ppu_addr
                sta ppu_addr
                ldy #16
-               sta ppu_data
                inx
                bne -
                dey
                bne -

                ; clear RAM
                txa                     ; 0 -> A
-               sta $00,x
                sta $0100,x
                sta $0200,x
                sta $0300,x
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                inx
                bne -

                lda #$04
                jsr sub4
                jsr sub2
                jsr hide_sprites
                jsr sub18
                jsr sub13

                lda #$00
                sta ram22
                lda #$08
                sta ram23
                jsr sub12

                lda #$4c
                sta ram16
                lda #$10
                sta ram17
                lda #$82
                sta ram17b
                lda #$80
                sta ram14
                sta ppu_ctrl
                lda #$06
                sta ram15
                lda ram1
-               cmp ram1
                beq -

                ldx #$34
                ldy #$18
-               dex
                bne -
                dey
                bne -

                lda ppu_status
                and #%10000000
                sta ram0
                jsr sub5

                lda #$00
                sta ppu_scroll
                sta ppu_scroll
                sta oam_addr

                jmp cod2

; -----------------------------------------------------------------------------

macro to_ppu _src1, _src2
                ldy _src1
                lda (_src2),y
                sta ppu_data
endm

nmi             ; $80bc
                pha                     ; push A, X, Y
                txa
                pha
                tya
                pha

                lda ram15
                and #%00011000
                bne +
                jmp +++
+               lda #>sprite_data
                sta oam_dma
                lda ram7
                bne +
                jmp ++
+               ldx #$00
                stx ram7
                lda #$3f
                sta ppu_addr
                stx ppu_addr

                to_ppu arr5+0, ram8
                tax
                ;
                to_ppu arr5+1, ram8
                to_ppu arr5+2, ram8
                to_ppu arr5+3, ram8
                stx ppu_data
                ;
                to_ppu arr5+5, ram8
                to_ppu arr5+6, ram8
                to_ppu arr5+7, ram8
                stx ppu_data
                ;
                to_ppu arr5+9, ram8
                to_ppu arr5+10, ram8
                to_ppu arr5+11, ram8
                stx ppu_data
                ;
                to_ppu arr5+13, ram8
                to_ppu arr5+14, ram8
                to_ppu arr5+15, ram8
                stx ppu_data
                ;
                to_ppu arr5+17, ram10
                to_ppu arr5+18, ram10
                to_ppu arr5+19, ram10
                stx ppu_data
                ;
                to_ppu arr5+21, ram10
                to_ppu arr5+22, ram10
                to_ppu arr5+23, ram10
                stx ppu_data
                ;
                to_ppu arr5+25, ram10
                to_ppu arr5+26, ram10
                to_ppu arr5+27, ram10
                stx ppu_data
                ;
                to_ppu arr5+29, ram10
                to_ppu arr5+30, ram10
                to_ppu arr5+31, ram10

++              lda ram3                     ; 81c0: a5 03
                beq +                        ; 81c2: f0 0b
                lda #$00                     ; 81c4: a9 00
                sta ram3                     ; 81c6: 85 03
                lda ram6                     ; 81c8: a5 06
                beq +                        ; 81ca: f0 03
                jsr sub10                    ; 81cc: 20 83 83 (unaccessed)
                ;
+               lda #$00                     ; 81cf: a9 00
                sta ppu_addr                 ; 81d1: 8d 06 20
                sta ppu_addr                 ; 81d4: 8d 06 20
                lda ram12                    ; 81d7: a5 0c
                sta ppu_scroll               ; 81d9: 8d 05 20
                lda ram13                    ; 81dc: a5 0d
                sta ppu_scroll               ; 81de: 8d 05 20
                lda ram14                    ; 81e1: a5 10
                sta ppu_ctrl                 ; 81e3: 8d 00 20
+++             lda ram15                    ; 81e6: a5 12
                sta ppu_mask                 ; 81e8: 8d 01 20
                ;
                inc ram1                     ; 81eb: e6 01
                inc ram2                     ; 81ed: e6 02
                lda ram2                     ; 81ef: a5 02
                cmp #$06                     ; 81f1: c9 06
                bne cod1                     ; 81f3: d0 04
                lda #$00                     ; 81f5: a9 00
                sta ram2                     ; 81f7: 85 02
                ;
cod1            jsr ram16                    ; 81f9: 20 14 00

                pla                          ; pull Y, X, A
                tay
                pla
                tax
                pla
                rti

; -----------------------------------------------------------------------------

irq             ; $8202 (unaccessed chunk)
                pha
                txa
                pha
                tya
                pha
                lda #$ff
                jmp cod1

; -----------------------------------------------------------------------------

                sta ram17                    ; 820c: 85 15    (unaccessed)
                stx ram17b                   ; 820e: 86 16    (unaccessed)
                rts                          ; 8210: 60

                sta ram18                    ; 8211: 85 17    (unaccessed)
                stx ram19                    ; 8213: 86 18    (unaccessed)
                ldx #$00                     ; 8215: a2 00    (unaccessed)
                lda #$20                     ; 8217: a9 20    (unaccessed)
                ;
--              sta ram20                    ; 8219: 85 19    (unaccessed)
                ldy #$00                     ; 821b: a0 00    (unaccessed)
-               lda (ram18),y                ; 821d: b1 17    (unaccessed)
                sta arr5,x                   ; 821f: 9d c0 01 (unaccessed)
                inx                          ; 8222: e8       (unaccessed)
                iny                          ; 8223: c8       (unaccessed)
                dec ram20                    ; 8224: c6 19    (unaccessed)
                bne -                        ; 8226: d0 f5    (unaccessed)
                inc ram7                     ; 8228: e6 07    (unaccessed)
                rts                          ; 822a: 60       (unaccessed)

                sta ram18                    ; 822b: 85 17    (unaccessed)
                stx ram19                    ; 822d: 86 18    (unaccessed)
                ldx #$00                     ; 822f: a2 00    (unaccessed)
                lda #$10                     ; 8231: a9 10    (unaccessed)
                bne --                       ; 8233: d0 e4    (unaccessed)
                sta ram18                    ; 8235: 85 17    (unaccessed)
                stx ram19                    ; 8237: 86 18    (unaccessed)
                ldx #$10                     ; 8239: a2 10    (unaccessed)
                txa                          ; 823b: 8a       (unaccessed)
                bne --                       ; 823c: d0 db    (unaccessed)

; -----------------------------------------------------------------------------

sub1            sta ram18                    ; 823e: 85 17
                jsr sub15                    ; 8240: 20 fe 86
                and #%00011111               ; 8243: 29 1f
                tax                          ; 8245: aa
                lda ram18                    ; 8246: a5 17
                sta arr5,x                   ; 8248: 9d c0 01
                inc ram7                     ; 824b: e6 07
                rts                          ; 824d: 60

sub2            lda #$0f                     ; 824e: a9 0f
                ldx #$00                     ; 8250: a2 00
-               sta arr5,x                   ; 8252: 9d c0 01
                inx                          ; 8255: e8
                cpx #$20                     ; 8256: e0 20
                bne -                        ; 8258: d0 f8
                stx ram7                     ; 825a: 86 07
                rts                          ; 825c: 60

sub3            tax                          ; 825d: aa
                lda dat1,x                   ; 825e: bd 22 84
                sta ram10                    ; 8261: 85 0a
                lda dat2,x                   ; 8263: bd 2b 84
                sta ram11                    ; 8266: 85 0b
                sta ram7                     ; 8268: 85 07
                rts                          ; 826a: 60

-               tax                          ; 826b: aa
                lda dat1,x                   ; 826c: bd 22 84
                sta ram8                     ; 826f: 85 08
                lda dat2,x                   ; 8271: bd 2b 84
                sta ram9                     ; 8274: 85 09
                sta ram7                     ; 8276: 85 07
                rts                          ; 8278: 60
                ;
sub4            jsr sub3                     ; 8279: 20 5d 82
                txa                          ; 827c: 8a
                jmp -                        ; 827d: 4c 6b 82

sub5            lda ram15                    ; 8280: a5 12
                and #%11100111               ; 8282: 29 e7
                sta ram15                    ; 8284: 85 12
                jmp sub8                     ; 8286: 4c f0 82

sub6            lda ram15                    ; 8289: a5 12
                ora #%00011000               ; 828b: 09 18
-               sta ram15                    ; 828d: 85 12
                jmp sub8                     ; 828f: 4c f0 82

                lda ram15                    ; 8292: a5 12    (unaccessed)
                ora #%00001000               ; 8294: 09 08    (unaccessed)
                bne -                        ; 8296: d0 f5    (unaccessed)
                lda ram15                    ; 8298: a5 12    (unaccessed)
                ora #%00010000               ; 829a: 09 10    (unaccessed)
                bne -                        ; 829c: d0 ef    (unaccessed)
                sta ram15                    ; 829e: 85 12    (unaccessed)
                rts                          ; 82a0: 60       (unaccessed)

                lda ram0                     ; 82a1: a5 00    (unaccessed)
                ldx #$00                     ; 82a3: a2 00    (unaccessed)
                rts                          ; 82a5: 60       (unaccessed)

                lda ram14                    ; 82a6: a5 10    (unaccessed)
                ldx #$00                     ; 82a8: a2 00    (unaccessed)
                rts                          ; 82aa: 60       (unaccessed)

                sta ram14                    ; 82ab: 85 10    (unaccessed)
                rts                          ; 82ad: 60       (unaccessed)

hide_sprites    ; $82ae
                ldx #$00
                lda #$ff
-               sta sprite_data,x
                inx
                inx
                inx
                inx
                bne -
                rts

                ; $82bc; unaccessed chunk
                asl a
                asl a
                asl a
                asl a
                asl a
                and #%00100000
                sta ram18
                lda ram14
                and #%11011111
                ora ram18
                sta ram14
                rts

                ; $82ce; unaccessed chunk
                tax
                lda #$f0
-               sta sprite_data,x
                inx
                inx
                inx
                inx
                bne -
                rts

                ; $82db; unaccessed chunk
                lda #$01
                sta ram3
                lda ram1
-               cmp ram1
                beq -
                lda ram0
                beq +
-               lda ram2
                cmp #$05
                beq -
+               rts

; -----------------------------------------------------------------------------

sub8            lda #$01                     ; 82f0: a9 01
                sta ram3                     ; 82f2: 85 03
                lda ram1                     ; 82f4: a5 01
-               cmp ram1                     ; 82f6: c5 01
                beq -                        ; 82f8: f0 fc
                rts                          ; 82fa: 60

                ; $82fb; unaccessed chunk
                sta ram18
                txa
                bne +
                lda ram18
                cmp #$f0
                bcs +
                sta ram13
                lda #$00
                sta ram18
                beq ++
+               sec
                lda ram18
                sbc #$f0
                sta ram13
                lda #$02
                sta ram18
++              jsr sub14
                sta ram12
                txa
                and #%00000001
                ora ram18
                sta ram18
                lda ram14
                and #%11111100
                ora ram18
                sta ram14
                rts

                ; $832e; unaccessed chunk
                and #%00000001
                asl a
                asl a
                asl a
                sta ram18
                lda ram14
                and #%11110111
                ora ram18
                sta ram14
                rts

                ; $833e; unaccessed chunk
                and #%00000001
                asl a
                asl a
                asl a
                asl a
                sta ram18
                lda ram14
                and #%11101111
                ora ram18
                sta ram14
                rts

; -----------------------------------------------------------------------------

sub9            sta ram18                    ; 834f: 85 17
                stx ram19                    ; 8351: 86 18
                jsr sub14                    ; 8353: 20 e8 86
                sta ram20                    ; 8356: 85 19
                stx ram21                    ; 8358: 86 1a
                ldy #$00                     ; 835a: a0 00
-               lda (ram20),y                ; 835c: b1 19
                sta ppu_data                 ; 835e: 8d 07 20
                inc ram20                    ; 8361: e6 19
                bne +                        ; 8363: d0 02
                inc ram21                    ; 8365: e6 1a
+               lda ram18                    ; 8367: a5 17
                bne +                        ; 8369: d0 02
                dec ram19                    ; 836b: c6 18    (unaccessed)
+               dec ram18                    ; 836d: c6 17
                lda ram18                    ; 836f: a5 17
                ora ram19                    ; 8371: 05 18
                bne -                        ; 8373: d0 e7
                rts                          ; 8375: 60

                ; $8376; unaccessed chunk
                sta ram4
                stx ram5
                ora ram5
                sta ram6
                rts
                sta ram4
                stx ram5
sub10           ldy #$00
--              lda (ram4),y
                iny
                cmp #$40
                bcs +
                sta ppu_addr
                lda (ram4),y
                iny
                sta ppu_addr
                lda (ram4),y
                iny
                sta ppu_data
                jmp --
+               tax
                lda ram14
                cpx #$80
                bcc +
                cpx #$ff
                beq +++
                ora #%00000100
                bne ++
+               and #%11111011
++              sta ppu_ctrl
                txa
                and #%00111111
                sta ppu_addr
                lda (ram4),y
                iny
                sta ppu_addr
                lda (ram4),y
                iny
                tax
-               lda (ram4),y
                iny
                sta ppu_data
                dex
                bne -
                lda ram14
                sta ppu_ctrl
                jmp --
+++             rts

; -----------------------------------------------------------------------------

set_ppu_addr    stx ppu_addr                 ; $83d4
                sta ppu_addr
                rts

                ; $83db; unaccessed chunk
                sta ppu_data
                rts
                sta ram20
                stx ram21
                jsr sub15
                ldx ram21
                beq +
                ldx #$00
-               sta ppu_data
                dex
                bne -
                dec ram21
                bne -
+               ldx ram20
                beq +
-               sta ppu_data
                dex
                bne -
+               rts
                ora #%00000000
                beq +
                lda #$04
+               sta ram18
                lda ram14
                and #%11111011
                ora ram18
                sta ram14
                sta ppu_ctrl
                rts
                lda ram1
                ldx #$00
                rts
                tax
-               jsr sub8
                dex
                bne -
                rts

                ; $8422; partially unaccessed
dat1            hex 34 44 54 64 74 84 94 a4
                hex b4
dat2            hex 84 84 84 84 84 84 84 84
                hex 84

                ; $8434; unaccessed
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f

                ; $8474; partially unaccessed
                hex 00 01 02 03 04 05 06 07
                hex 08 09 0a 0b 0c 0f 0f 0f
                hex 10 11 12 13 14 15 16 17
                hex 18 19 1a 1b 1c 00 00 00
                hex 10 21 22 23 24 25 26 27
                hex 28 29 2a 2b 2c 10 10 10
                hex 30 31 32 33 34 35 36 37
                hex 38 39 3a 3b 3c 20 20 20
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30

; -----------------------------------------------------------------------------

sub12           ldy #$00                     ; 84f4: a0 00
                beq +                        ; 84f6: f0 07
                lda #$00                     ; 84f8: a9 00    (unaccessed)
                ldx #$85                     ; 84fa: a2 85    (unaccessed)
                jmp ram31                     ; 84fc: 4c 00 03 (unaccessed)
+               rts                          ; 84ff: 60

macro lajs _arg1, _arg2
                lda #_arg1
                jsr sub16
                lda #_arg2
                jsr sub1
endm
macro lxajs _arg1, _arg2, _arg3
                ldx #_arg1
                lda #_arg2
                jsr _arg3
endm
macro readline _arg1, _arg2
                lda #<_arg1
                ldx #>_arg1
                jsr sub17
endm
macro writeline _arg
                ldx #0
                lda #_arg
                jsr sub9
endm

cod2            ; $8500
                lajs $00, $02
                lajs $01, $14
                lajs $02, $20
                lajs $03, $30
                ;
                ldx #>$2042
                lda #<$2042
                jsr set_ppu_addr        ; X*256+A -> PPU address
                ;
                readline line1a
                writeline 28
                readline line1b
                writeline 32
                readline line_empty
                writeline 32
                readline line2a
                writeline 32
                readline line2b
                writeline 32
                readline line_empty
                writeline 32
                readline line3a
                writeline 32
                readline line3b
                writeline 32
                readline line3c
                writeline 32
                readline line_empty
                writeline 32
                readline line4a
                writeline 32
                readline line4b
                writeline 32
                readline line_empty
                writeline 32
                readline line5a
                writeline 32
                readline line5b
                writeline 32
                readline line_empty
                writeline 32
                readline line6
                writeline 32
                readline line_empty
                writeline 32
                readline line7a
                writeline 32
                readline line7b
                writeline 32
                readline line_empty
                writeline 32
                readline line8
                writeline 32
                readline line_empty
                writeline 32
                readline line9a
                writeline 32
                readline line9b
                writeline 32
                readline line_empty
                writeline 32
                readline line10
                writeline 32
                ;
                jsr sub6                     ; 86a9: 20 89 82
-               jmp -                        ; 86ac: 4c ac 86

                ldy #$00                     ; 86af: a0 00    (unaccessed)
                beq +                        ; 86b1: f0 07    (unaccessed)
                lda #$cb                     ; 86b3: a9 cb    (unaccessed)
                ldx #$89                     ; 86b5: a2 89    (unaccessed)
                jmp ram31                     ; 86b7: 4c 00 03 (unaccessed)
+               rts                          ; 86ba: 60       (unaccessed)

sub13           lda #$cb                     ; 86bb: a9 cb
                sta ram26                    ; 86bd: 85 2a
                lda #$89                     ; 86bf: a9 89
                sta ram27                    ; 86c1: 85 2b
                lda #$00                     ; 86c3: a9 00
                sta ram28                    ; 86c5: 85 2c
                lda #$03                     ; 86c7: a9 03
                sta ram29                    ; 86c9: 85 2d
                ldx #$da                     ; 86cb: a2 da
                lda #$ff                     ; 86cd: a9 ff
                sta ram30                    ; 86cf: 85 32
                ldy #$00                     ; 86d1: a0 00
                ;
-               inx                          ; 86d3: e8
                beq +                        ; 86d4: f0 0d
--              lda (ram26),y                ; 86d6: b1 2a
                sta (ram28),y                ; 86d8: 91 2c
                iny                          ; 86da: c8
                bne -                        ; 86db: d0 f6
                inc ram27                    ; 86dd: e6 2b    (unaccessed)
                inc ram29                    ; 86df: e6 2d    (unaccessed)
                bne -                        ; 86e1: d0 f0    (unaccessed)
+               inc ram30                    ; 86e3: e6 32
                bne --                       ; 86e5: d0 ef
                rts                          ; 86e7: 60

sub14           ldy #$01                     ; 86e8: a0 01
                lda (ram22),y                ; 86ea: b1 22
                tax                          ; 86ec: aa
                dey                          ; 86ed: 88
                lda (ram22),y                ; 86ee: b1 22
                inc ram22                    ; 86f0: e6 22
                beq +                        ; 86f2: f0 05
                inc ram22                    ; 86f4: e6 22
                beq ++                       ; 86f6: f0 03
                rts                          ; 86f8: 60       (unaccessed)
+               inc ram22                    ; 86f9: e6 22    (unaccessed)
++              inc ram23                    ; 86fb: e6 23
                rts                          ; 86fd: 60

sub15           ldy #$00                     ; 86fe: a0 00
                lda (ram22),y                ; 8700: b1 22
                inc ram22                    ; 8702: e6 22
                beq +                        ; 8704: f0 01
                rts                          ; 8706: 60       (unaccessed)
+               inc ram23                    ; 8707: e6 23
                rts                          ; 8709: 60

                ldy #$00                     ; 870a: a0 00    (unaccessed)
                lda (ram22),y                ; 870c: b1 22    (unaccessed)

sub16           ldy ram22                    ; 870e: a4 22
                beq +                        ; 8710: f0 07
                dec ram22                    ; 8712: c6 22    (unaccessed)
                ldy #$00                     ; 8714: a0 00    (unaccessed)
                sta (ram22),y                ; 8716: 91 22    (unaccessed)
                rts                          ; 8718: 60       (unaccessed)
+               dec ram23                    ; 8719: c6 23
                dec ram22                    ; 871b: c6 22
                sta (ram22),y                ; 871d: 91 22
                rts                          ; 871f: 60

                lda #$00                     ; 8720: a9 00    (unaccessed)
                ldx #$00                     ; 8722: a2 00    (unaccessed)

sub17           pha                          ; 8724: 48
                lda ram22                    ; 8725: a5 22
                sec                          ; 8727: 38
                sbc #$02                     ; 8728: e9 02
                sta ram22                    ; 872a: 85 22
                bcs +                        ; 872c: b0 02
                dec ram23                    ; 872e: c6 23
+               ldy #$01                     ; 8730: a0 01
                txa                          ; 8732: 8a
                sta (ram22),y                ; 8733: 91 22
                pla                          ; 8735: 68
                dey                          ; 8736: 88
                sta (ram22),y                ; 8737: 91 22
                rts                          ; 8739: 60

sub18           lda #$25                     ; 873a: a9 25
                sta ram26                    ; 873c: 85 2a
                lda #$03                     ; 873e: a9 03
                sta ram27                    ; 8740: 85 2b
                lda #$00                     ; 8742: a9 00
                tay                          ; 8744: a8
                ldx #$00                     ; 8745: a2 00
                beq cod3                     ; 8747: f0 0a
-               sta (ram26),y                ; 8749: 91 2a    (unaccessed)
                iny                          ; 874b: c8       (unaccessed)
                bne -                        ; 874c: d0 fb    (unaccessed)
                inc ram27                    ; 874e: e6 2b    (unaccessed)
                dex                          ; 8750: ca       (unaccessed)
                bne -                        ; 8751: d0 f6    (unaccessed)
cod3            cpy #$00                     ; 8753: c0 00
                beq +                        ; 8755: f0 05
                sta (ram26),y                ; 8757: 91 2a    (unaccessed)
                iny                          ; 8759: c8       (unaccessed)
                bne cod3                     ; 875a: d0 f7    (unaccessed)
+               rts                          ; 875c: 60

line_empty      db "                                ", $00  ; $875d
line1b          db "      gods before me            ", $00  ; $877e
line2a          db "    2.Thou shalt not make unto  ", $00  ; $879f
line2b          db "      thee any graven image     ", $00  ; $87c0
line3a          db "    3.Thou shalt not take the   ", $00  ; $87e1
line3b          db "      name of the Lord thy God  ", $00  ; $8802
line3c          db "      in vain                   ", $00  ; $8823
line4a          db "    4.Remember the sabbath day, ", $00  ; $8844
line4b          db "      to keep it holy           ", $00  ; $8865
line5a          db "    5.Honor thy father and thy  ", $00  ; $8886
line5b          db "      mother                    ", $00  ; $88a7
line6           db "    6.Thou shalt not murder     ", $00  ; $88c8
line7a          db "    7.Thou shalt not commit     ", $00  ; $88e9
line7b          db "      adultery                  ", $00  ; $890a
line8           db "    8.Thou shalt not steal      ", $00  ; $892b
line9a          db "    9.Thou shalt not bear false ", $00  ; $894c
line9b          db "    witness against thy neighbor", $00  ; $896d
line10          db "    10.Thou shalt not covet     ", $00  ; $898e
line1a          db "1.Thou shalt have no other ", $00       ; $89af

                hex 8d 0e 03 8e 0f 03 8d 15
                hex 03 8e 16 03 88 b9 ff ff
                hex 8d 1f 03 88 b9 ff ff 8d
                hex 1e 03 8c 21 03 20 ff ff
                hex a0 ff d0 e8 60

                pad $fffa, $00          ; $89f0 (unaccessed)

; --- Interrupt vectors -------------------------------------------------------

                dw nmi, reset, irq      ; IRQ unaccessed
                pad $10000, $ff

; --- CHR ROM -----------------------------------------------------------------

                base $0000
                incbin "tencom.chr"
                pad $2000, $00
