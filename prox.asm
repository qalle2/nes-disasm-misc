; Proximity Shift (NESdev Compo 2023) by Fiskbit, Trirosmos.
; Unofficial disassembly by qalle.
; Assembles with ASM6.
; Command used to disassemble:
;     python3 nesdisasm.py
;     -c prox.cdl --no-access 0800-1fff,2008-3fff,4020-5fff,6000-7fff
;     --no-write 8000-ffff prox-prg.bin

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff
; note: some "arr"s aren't arrays

ptr1            equ $00  ; 2 bytes
ptr2            equ $02  ; 2 bytes
arr5            equ $04
ram4            equ $0e
arr12           equ $0f
ram5            equ $10
ram6            equ $11
arr13           equ $12
arr14           equ $13
arr15           equ $14
arr16           equ $15
arr17           equ $16
arr18           equ $17
arr19           equ $18
arr20           equ $19
ram7            equ $1a
ram8            equ $1b
ram9            equ $1c
arr21           equ $1d
arr22           equ $1e
arr23           equ $1f
ram10           equ $20
ram11           equ $21
ram12           equ $23
arr25           equ $24  ; not an array
ptr3            equ $25  ; 2 bytes
arr27           equ $27
arr28           equ $28
ram14           equ $29
ram15           equ $2a
ram17           equ $2c
ram18           equ $2d
ram19           equ $2e
ram20           equ $2f
ptr4            equ $30  ; 2 bytes
ram23           equ $32
ram24           equ $33
ram25           equ $34
ram27           equ $36
ram28           equ $37
ram29           equ $38
ram30           equ $39
ram31           equ $3a
arr29           equ $3c
ram32           equ $3d
ram33           equ $3e
arr30           equ $3f
arr31           equ $40
ram34           equ $41
ram35           equ $42
ram36           equ $43
ram37           equ $44
ram38           equ $45
ram40           equ $47
ram41           equ $48
ram42           equ $49
ram43           equ $4a
ram44           equ $4b
ram45           equ $4c
ram46           equ $4d
ram47           equ $4e
arr32           equ $50
arr33           equ $51
ram48           equ $52
ram49           equ $53
ram50           equ $54
ptr5            equ $5a
ram56           equ $5c
ram57           equ $5d
ram58           equ $5e
arr34           equ $5f
arr35           equ $60
ram59           equ $61
ram60           equ $62
ram61           equ $63
ram62           equ $64
ram63           equ $65
ram64           equ $66
arr36           equ $67  ; not an array
ram65           equ $68
ram66           equ $69
ram67           equ $6a
ram68           equ $6b
ram69           equ $6c
ram70           equ $6d
ram71           equ $6e
ram72           equ $6f
ram73           equ $70
ram74           equ $71
ptr6            equ $72  ; 2 bytes
ram77           equ $74
ram78           equ $75
ram79           equ $76
ram80           equ $77
ptr7            equ $79  ; 2 bytes
ptr8            equ $7b  ; 2 bytes
ptr9            equ $7f
ptr10           equ $81
arr41           equ $83
arr42           equ $84
arr43           equ $85
ram87           equ $86
ram88           equ $87
ram89           equ $88
arr61           equ $0110
arr62           equ $0111
arr63           equ $0112
arr64           equ $0113
arr65           equ $0133
arr66           equ $0150
arr67           equ $0151
arr68           equ $0170
arr69           equ $0171
arr70           equ $0200
arr71           equ $0201
arr72           equ $0202
arr73           equ $0203
ram136          equ $0204
ram137          equ $0205
ram138          equ $0206
ram139          equ $0207
ram140          equ $0208
ram141          equ $0209
ram142          equ $020a
ram143          equ $020b
ram144          equ $020c
ram145          equ $020d
ram146          equ $020e
ram147          equ $020f
arr74           equ $0240
arr75           equ $0280
arr76           equ $02c0
arr77           equ $0300
ram148          equ $0301
ram149          equ $0302
arr78           equ $0303
arr79           equ $0304
arr80           equ $0305
arr81           equ $0306
arr82           equ $0307
arr83           equ $0308
arr84           equ $0309
arr85           equ $030a
arr86           equ $030b
arr87           equ $030c
arr88           equ $030d
arr89           equ $030e
arr90           equ $030f
arr91           equ $0310
arr92           equ $0311
arr96           equ $0400
arr97           equ $0403
ram150          equ $0404
ram151          equ $0405
ram152          equ $0406
ram153          equ $0424
arr98           equ $043c
arr99           equ $0444
arr100          equ $044c
arr101          equ $0454
arr102          equ $045c
arr103          equ $0464
arr104          equ $046c
arr105          equ $0474
arr106          equ $047c
arr107          equ $0484
arr108          equ $048c
arr109          equ $0494
arr110          equ $049c
arr111          equ $04a8
arr112          equ $04b4
arr113          equ $04c0
arr114          equ $04ea
ram155          equ $04eb
ram156          equ $04ec
ram157          equ $04ed
ram158          equ $04ee
ram159          equ $04ef
ram160          equ $04f0
ram161          equ $04f1
arr115          equ $04f2
ram162          equ $04f3
ram163          equ $04f4
ram164          equ $04f5
ram165          equ $04f7
ram166          equ $04f8
ram167          equ $04f9
ram168          equ $04fa
ram169          equ $04fb
ram170          equ $04fc
ram171          equ $04fd
ram172          equ $04fe
ram173          equ $04ff
arr116          equ $0500
ram174          equ $0501
ram175          equ $0502
ram176          equ $0503
ram177          equ $0504
ram178          equ $0505
ram179          equ $0507
arr117          equ $0508
arr118          equ $050d
arr119          equ $0512
ram180          equ $0513
ram181          equ $0514
ram182          equ $0515
arr120          equ $0517
ram183          equ $0518
ram184          equ $0519
ram185          equ $051a
arr121          equ $051c
arr122          equ $0521
ram186          equ $0525
arr123          equ $0526
arr124          equ $052b
arr125          equ $0530
arr126          equ $0535
arr127          equ $053a
arr128          equ $053e
arr129          equ $0542
ram187          equ $0543
ram188          equ $0544
ram189          equ $0545
arr130          equ $0546
ram190          equ $0547
ram191          equ $0548
arr131          equ $054a
arr132          equ $054f
ram192          equ $0550
arr133          equ $0551
arr134          equ $0555
arr135          equ $0559
arr136          equ $055d
arr137          equ $0561
arr138          equ $0565
arr139          equ $0569
arr140          equ $056d
arr141          equ $0571
arr142          equ $0575
arr143          equ $0579
ram193          equ $057a
ram194          equ $057b
ram195          equ $057c
arr144          equ $057d
ram196          equ $057e
ram197          equ $0580
arr145          equ $0581
arr147          equ $0585
arr148          equ $0589
arr149          equ $058d
arr150          equ $0591
arr151          equ $0595
arr152          equ $0599
arr153          equ $059d
arr154          equ $05a1
arr155          equ $05a5
arr156          equ $05a9
arr157          equ $05ad
arr158          equ $05b1
arr159          equ $05b5
arr160          equ $05b9
arr161          equ $05bd
arr162          equ $05c1
arr163          equ $05c5
ram198          equ $05c6
ram199          equ $05c8
arr164          equ $0600
arr166          equ $0700

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
misc1           equ $4009
tri_lo          equ $400a
tri_hi          equ $400b
noise_vol       equ $400c
misc2           equ $400d
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

; PPU memory
ppu_nt0         equ $2000
ppu_at0         equ $23c0
ppu_palette     equ $3f00

; --- Header ------------------------------------------------------------------

                ; https://www.nesdev.org/wiki/NES_2.0
                base $0000
                db "NES", $1a           ; file id
                db 2, 1                 ; 32k PRG ROM, 8k CHR ROM
                hex 00 08               ; horiz. mirroring, NROM, NES 2.0 hdr
                hex 00 00 00 00
                hex 02 00 00 01         ; multi-region, def.exp.device=1

; --- PRG ROM start -----------------------------------------------------------

; labels: 'sub' = subroutine, 'cod' = code, 'dat' = data

                base $8000

cod1            rept 16
                    pla
                    sta ppu_data
                endr
                tya                          ; 8040
                bne cod5                     ; 8041: d0 44
                beq cod4                     ; 8043: f0 24
cod2            txs                          ; 8045: 9a
                ldx #$ff                     ; 8046: a2 ff
                stx arr61                    ; 8048: 8e 10 01
                inx                          ; 804b: e8
                stx ram18                    ; 804c: 86 2d
cod3            rts                          ; 804e: 60
sub1            lda ram17                    ; 804f: a5 2c
                beq +                        ; 8051: f0 03
                jsr sub2                     ; 8053: 20 f6 80
+               lda arr61                    ; 8056: ad 10 01
                bmi cod3                     ; 8059: 30 f3
                lda #$80                     ; 805b: a9 80
                sta ptr1+1                   ; 805d: 85 01
                lda #$80                     ; 805f: a9 80
                sta ptr2+1                   ; 8061: 85 03
                tsx                          ; 8063: ba
                txa                          ; 8064: 8a
                ldx #$0f                     ; 8065: a2 0f
                txs                          ; 8067: 9a
                tax                          ; 8068: aa
cod4            pla                          ; 8069: 68
                bmi cod2                     ; 806a: 30 d9
                sta ppu_addr                 ; 806c: 8d 06 20
                pla                          ; 806f: 68
                sta ppu_addr                 ; 8070: 8d 06 20
                pla                          ; 8073: 68
                asl a                        ; 8074: 0a
                tay                          ; 8075: a8
                lda ram6                     ; 8076: a5 11
                bcc +                        ; 8078: 90 02
                ora #%00000100               ; 807a: 09 04    (unaccessed)
+               sta ppu_ctrl                 ; 807c: 8d 00 20
                tya                          ; 807f: 98
                bmi cod6                     ; 8080: 30 1c
                lsr a                        ; 8082: 4a
                bne cod5                     ; 8083: d0 02
                lda #$40                     ; 8085: a9 40    (unaccessed)
cod5            cmp #$10                     ; 8087: c9 10
                bcc +                        ; 8089: 90 06
                sbc #$10                     ; 808b: e9 10
                tay                          ; 808d: a8
                jmp cod1                     ; 808e: 4c 00 80

+               ldy #0                       ; 8091: a0 00    (unaccessed)
                sbc #0                       ; 8093: e9 00    (unaccessed)
                eor #%00001111               ; 8095: 49 0f    (unaccessed)
                asl a                        ; 8097: 0a       (unaccessed)
                asl a                        ; 8098: 0a       (unaccessed)
                sta ptr1+0                   ; 8099: 85 00    (unaccessed)
                jmp (ptr1)                   ; 809b: 6c 00 00 (unaccessed)
cod6            lsr a                        ; 809e: 4a       (unaccessed)
                and #%00111111               ; 809f: 29 3f    (unaccessed)
                bne +                        ; 80a1: d0 02    (unaccessed)
                lda #$40                     ; 80a3: a9 40    (unaccessed)
+               eor #%11111111               ; 80a5: 49 ff    (unaccessed)
                adc #$11                     ; 80a7: 69 11    (unaccessed)
                sta arr5                     ; 80a9: 85 04    (unaccessed)
                pla                          ; 80ab: 68       (unaccessed)
                tay                          ; 80ac: a8       (unaccessed)
                lda arr5                     ; 80ad: a5 04    (unaccessed)
                sty arr5                     ; 80af: 84 04    (unaccessed)
                bpl +                        ; 80b1: 10 36    (unaccessed)
-               sty ppu_data                 ; 80b3: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80b6: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80b9: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80bc: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80bf: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80c2: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80c5: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80c8: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80cb: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80ce: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80d1: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80d4: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80d7: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80da: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80dd: 8c 07 20 (unaccessed)
                sty ppu_data                 ; 80e0: 8c 07 20 (unaccessed)
                adc #$10                     ; 80e3: 69 10    (unaccessed)
                bmi -                        ; 80e5: 30 cc    (unaccessed)
                bcc cod4                     ; 80e7: 90 80    (unaccessed)
+               tay                          ; 80e9: a8       (unaccessed)
                lda dat2,y                   ; 80ea: b9 59 81 (unaccessed)
                sta ptr2+0                   ; 80ed: 85 02    (unaccessed)
                ldy arr5                     ; 80ef: a4 04    (unaccessed)
                lda #0                       ; 80f1: a9 00    (unaccessed)
                jmp (ptr2)                   ; 80f3: 6c 02 00 (unaccessed)

sub2            tay                          ; 80f6: a8
                lda $8257,y                  ; 80f7: b9 57 82
                sta ptr1+0                   ; 80fa: 85 00
                lda dat3,y                   ; 80fc: b9 58 82
                sta ptr1+1                   ; 80ff: 85 01
cod7            ldy #0                       ; 8101: a0 00
                lda (ptr1),y                 ; 8103: b1 00
                bmi cod9                     ; 8105: 30 39
                sta ppu_addr                 ; 8107: 8d 06 20
                iny                          ; 810a: c8
                lda (ptr1),y                 ; 810b: b1 00
                sta ppu_addr                 ; 810d: 8d 06 20
                iny                          ; 8110: c8
                lda (ptr1),y                 ; 8111: b1 00
                iny                          ; 8113: c8
                asl a                        ; 8114: 0a
                tax                          ; 8115: aa
                lda ram6                     ; 8116: a5 11
                bcc +                        ; 8118: 90 02
                ora #%00000100               ; 811a: 09 04    (unaccessed)
+               sta ppu_ctrl                 ; 811c: 8d 00 20
                txa                          ; 811f: 8a
                bmi cod10                    ; 8120: 30 23
                lsr a                        ; 8122: 4a
                bne +                        ; 8123: d0 02
                lda #$40                     ; 8125: a9 40    (unaccessed)
+               tax                          ; 8127: aa
-               lda (ptr1),y                 ; 8128: b1 00
                sta ppu_data                 ; 812a: 8d 07 20
                iny                          ; 812d: c8
                dex                          ; 812e: ca
                bne -                        ; 812f: d0 f7
cod8            tya                          ; 8131: 98
                clc                          ; 8132: 18
                adc ptr1+0                   ; 8133: 65 00
                sta ptr1+0                   ; 8135: 85 00
                lda ptr1+1                   ; 8137: a5 01
                adc #0                       ; 8139: 69 00
                sta ptr1+1                   ; 813b: 85 01
                jmp cod7                     ; 813d: 4c 01 81
cod9            lda #0                       ; 8140: a9 00
                sta ram17                    ; 8142: 85 2c
                rts                          ; 8144: 60
cod10           lsr a                        ; 8145: 4a
                and #%00111111               ; 8146: 29 3f
                bne +                        ; 8148: d0 02
                lda #$40                     ; 814a: a9 40
+               tax                          ; 814c: aa
                lda (ptr1),y                 ; 814d: b1 00
                iny                          ; 814f: c8
-               sta ppu_data                 ; 8150: 8d 07 20
                dex                          ; 8153: ca
                bne -                        ; 8154: d0 fa
                jmp cod8                     ; 8156: 4c 31 81

dat2            hex b3 b6 b9 bc bf c2 c5 c8  ; 8159 (unaccessed)
                hex cb ce d1 d4 d7 da dd e0  ; 8161 (unaccessed)

cod11           rept 32                      ; 8169
                    pla
                    sta ppu_data
                endr
                jmp (ptr3)                   ; 81e9

                pad $8200, $00               ; 81ec (unaccessed)

sub3            lda ram6                     ; 8200: a5 11
                sta ppu_ctrl                 ; 8202: 8d 00 20
                lda arr25                    ; 8205: a5 24
                beq cod12                    ; 8207: f0 31
sub4            tsx                          ; 8209: ba
                stx ptr1+0                   ; 820a: 86 00
                ldx #$4f                     ; 820c: a2 4f
                txs                          ; 820e: 9a
                ldx ram14                    ; 820f: a6 29
                stx ppu_addr                 ; 8211: 8e 06 20
                ldy ram15                    ; 8214: a4 2a
                sty ppu_addr                 ; 8216: 8c 06 20
                lda #$20                     ; 8219: a9 20
                sta ptr3+0                   ; 821b: 85 25
                jmp cod11                    ; 821d: 4c 69 81
                stx ppu_addr                 ; 8220: 8e 06 20
                tya                          ; 8223: 98
                ora #%00100000               ; 8224: 09 20
                sta ppu_addr                 ; 8226: 8d 06 20
                ldx #$6f                     ; 8229: a2 6f
                txs                          ; 822b: 9a
                lda #$33                     ; 822c: a9 33
                sta ptr3+0                   ; 822e: 85 25
                jmp cod11                    ; 8230: 4c 69 81
                ldx ptr1+0                   ; 8233: a6 00
                txs                          ; 8235: 9a
                lda #0                       ; 8236: a9 00
                sta arr25                    ; 8238: 85 24
cod12           rts                          ; 823a: 60
sub5            lda #$20                     ; 823b: a9 20
                sta ppu_addr                 ; 823d: 8d 06 20
                lda #0                       ; 8240: a9 00
                sta ppu_addr                 ; 8242: 8d 06 20
                ldy #$f0                     ; 8245: a0 f0
                lda #$f8                     ; 8247: a9 f8
-               sta ppu_data                 ; 8249: 8d 07 20
                sta ppu_data                 ; 824c: 8d 07 20
                sta ppu_data                 ; 824f: 8d 07 20
                sta ppu_data                 ; 8252: 8d 07 20
                dey                          ; 8255: 88
                bne -                        ; 8256: d0 f1
dat3            rts                          ; 8258: 60

                ; pointers to PPU strings
                dw str_blackpal              ; 8259 (unaccessed)
                dw str_palette               ; 825b (unaccessed)
                dw arr96                     ; 825d
                dw str_title                 ; 825f
                dw str_normal1               ; 8261 (unaccessed)
                dw str_hard1                 ; 8263 (unaccessed)
                dw str_expert1               ; 8265 (unaccessed)
                dw str_irritating1           ; 8267 (unaccessed)
                dw str_off1                  ; 8269 (unaccessed)
                dw str_on1                   ; 826b (unaccessed)
                dw str_congrats              ; 826d (unaccessed)
                dw str_gotlost               ; 826f (unaccessed)
                dw str_master                ; 8271 (unaccessed)
                dw str_wow                   ; 8273 (unaccessed)
                dw str_stats                 ; 8275 (unaccessed)
                dw str_credits               ; 8277 (unaccessed)
                dw str_normal2               ; 8279 (unaccessed)
                dw str_hard2                 ; 827b (unaccessed)
                dw str_expert2               ; 827d (unaccessed)
                dw str_irritating2           ; 827f (unaccessed)
                dw str_secret                ; 8281 (unaccessed)
                dw str_off2                  ; 8283 (unaccessed)
                dw str_on2                   ; 8285 (unaccessed)
                dw str_ntsc                  ; 8287 (unaccessed)
                dw str_pal                   ; 8289 (unaccessed)
                dw str_pal                   ; 828b (unaccessed)

                ; PPU strings

macro ppustr _addr, _len
                db >(_addr), <(_addr), _len
endm

                ; tiles $00-$09 = "0"-"9" (subtract 48 from ASCII digits)
                ; tiles $0a-$23 = "A"-"Z" (subtract 55 from ASCII uppercase)

str_blackpal    ppustr ppu_palette, $40|32   ; 828d (unaccessed)
                hex 0f
                hex ff
str_palette     ppustr ppu_palette, 32       ; 8292
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 17 27 37
                hex 0f 01 11 21
                hex 0f 00 10 20
                hex ff
str_title       ppustr ppu_at0, $40          ; 82b6
                hex 00
                ; "PROXIMITY" (3 rows; tiles $f8-$ff = "@ABCDEFG" here)
                ppustr ppu_nt0+6*32+1, 30
                db "AA@DA@DAA@A@A@D@AEDA@D@DAG@A@A"+184
                ppustr ppu_nt0+7*32+1, 30
                db "AA@A@@A@A@@A@@A@AFGA@A@@A@@FAG"+184
                ppustr ppu_nt0+8*32+1, 29
                db "G@@G@@AAG@A@G@G@A@@G@G@@G@@@A"+184
                ; "SHIFT" (3 rows; tiles $f8-$ff = "@ABCDEFG" here)
                ppustr ppu_nt0+10*32+8, 16
                db "DAG@A@A@D@AA@DAG"+184
                ppustr ppu_nt0+11*32+8, 15
                db "FAE@AAA@A@AE@@A"+184
                ppustr ppu_nt0+12*32+8, 15
                db "DAG@A@G@G@G@@@G"+184
                ppustr ppu_nt0+23*32+4, 23
                db "2023"-48, $f8, "NESDEV"-55, $f8, "COMPETITION"-55
                ppustr ppu_nt0+24*32+8, 15
                db "GAME"-55, $f8, "BY"-55, $f8, "FISKBIT"-55
                ppustr ppu_nt0+25*32+7, 18
                db "SOUND"-55, $f8, "BY"-55, $f8, "TRIROSMOS"-55
                hex ff

                ; 8395-86c7: unaccessed data
str_normal1     ppustr ppu_nt0+22*32+3, 10   ; 8395
                db $24, $24, "NORMAL"-55, $24, $24
                hex ff
str_hard1       ppustr ppu_nt0+22*32+3, 10   ; 83a3
                db $24, $24, $24, "HARD"-55, $24, $24, $24
                hex ff
str_expert1     ppustr ppu_nt0+22*32+3, 10   ; 83b1
                db $24, $24, "EXPERT"-55, $24, $24
                hex ff
str_irritating1 ppustr ppu_nt0+22*32+3, 10   ; 83bf
                db "IRRITATING"-55
                hex ff
str_off1        ppustr ppu_nt0+23*32+21, 3   ; 83cd
                db "OFF"-55
                hex ff
str_on1         ppustr ppu_nt0+23*32+21, 3   ; 83d4
                db $24, "ON"-55
                hex ff
str_congrats    ppustr ppu_at0, $40          ; 83db
                hex ff
                ppustr ppu_nt0+3*32+8, 16
                db "CONGRATULATIONS"-55, $e0
                ppustr ppu_nt0+5*32+3, 26
                db "YOU"-55, $df, "VE"-55, $24, "SURVIVED"-55, $24, "YOUR"-55
                db $24, "TRIP"-55, $db
                ppustr ppu_nt0+6*32+3, 23
                db "JUST"-55, $24, "ANOTHER"-55, $24, "DAY"-55, $24, "IN"-55
                db $24, "THE"-55
                ppustr ppu_nt0+7*32+3, 21
                db "LIFE"-55, $24, "OF"-55, $24, "SPACE"-55, $24, "TRAVEL"-55
                db $e1
                ppustr ppu_nt0+9*32+3, 23
                db "GOOD"-55, $24, "THING"-55, $24, "THERE"-55, $24, "WASN"-55
                db $df, "T"-55
                ppustr ppu_nt0+10*32+3, 18
                db "ANY"-55, $24, "TRAFFIC"-55, $24, "TODAY"-55, $e0
                hex ff
str_gotlost     ppustr ppu_at0, $40          ; 8471
                hex ff
                ppustr ppu_nt0+3*32+14, 4
                db "HUH"-55, $de
                ppustr ppu_nt0+5*32+3, 17
                db "DID"-55, $24, "YOU"-55, $24, "GET"-55, $24, "LOST"-55, $de
                ppustr ppu_nt0+6*32+3, 20
                db "YOU"-55, $24, "ALMOST"-55, $24, "HAD"-55, $24, "IT"-55, $e1
                db $e1, $e1
                ppustr ppu_nt0+8*32+3, 26
                db "MAYBE"-55, $24, "THIS"-55, $24, "IS"-55, $24, "GOOD"-55
                db $24, "ENOUGH"-55, $e1
                hex ff
str_master      ppustr ppu_at0, $40          ; 84c5
                hex ff
                ppustr ppu_nt0+3*32+11, 11
                db "INCREDIBLE"-55, $e1
                ppustr ppu_nt0+5*32+3, 13
                db "YOU"-55, $24, "TRULY"-55, $24, "ARE"-55
                ppustr ppu_nt0+6*32+3, 26
                db "AN"-55, $24, "IRRITATING"-55, $24, "SHIP"-55, $24
                db "MASTER"-55, $e1
                hex ff
str_wow         ppustr ppu_at0, $40          ; 8505
                hex ff
                ppustr ppu_nt0+3*32+14, 4
                db "WOW"-55, $e0
                ppustr ppu_nt0+5*32+3, 24
                db "THAT"-55, $df, "S"-55, $24, "SOME"-55, $24, "GOOD"-55, $24
                db "FLYING"-55, $e0
                ppustr ppu_nt0+6*32+3, 19
                db "MAYBE"-55, $24, "YOU"-55, $24, "NEED"-55, $24, "MORE"-55
                ppustr ppu_nt0+7*32+3, 12
                db "CHALLENGE"-55, $e1, $e1, $e1
                ppustr ppu_nt0+9*32+3, 23
                db "PRESS"-55, $24, "SELECT"-55, $24, "3"-48, $24, "TIMES"-55
                db $24, "ON"-55
                ppustr ppu_nt0+10*32+3, 17
                db "THE"-55, $24, "TITLE"-55, $24, "SCREEN"-55, $e1
                hex ff
str_stats       ppustr ppu_nt0+14*32+2, 11   ; 857f
                db "DIFFICULTY"-55, $dc
                ppustr ppu_nt0+16*32+2, 8
                db "GRAVITY"-55, $dc
                ppustr ppu_nt0+18*32+2, 13
                db "CONSOLE"-55, $24, "TYPE"-55, $dc
                ppustr ppu_nt0+21*32+2, 11
                db "TIME"-55, $24, "SPENT"-55, $dc
                ppustr ppu_nt0+23*32+2, 12
                db "THRUST"-55, $24, "USED"-55, $dc
                ppustr ppu_nt0+25*32+2, 14
                db "SHIPS"-55, $24, "CRASHED"-55, $dc
                hex ff
str_normal2     ppustr ppu_nt0+14*32+24, 6   ; 85d7
                db "NORMAL"-55
                hex ff
str_hard2       ppustr ppu_nt0+14*32+26, 4   ; 85e1
                db "HARD"-55
                hex ff
str_expert2     ppustr ppu_nt0+14*32+24, 6   ; 85e9
                db "EXPERT"-55
                hex ff
str_irritating2 ppustr ppu_nt0+14*32+20, 10  ; 85f3
                db "IRRITATING"-55
                hex ff
str_secret      ppustr ppu_nt0+14*32+24, 6   ; 8601
                db "SECRET"-55
                hex ff
str_off2        ppustr ppu_nt0+16*32+27, 3   ; 860b
                db "OFF"-55
                hex ff
str_on2         ppustr ppu_nt0+16*32+28, 2   ; 8612
                db "ON"-55
                hex ff
str_ntsc        ppustr ppu_nt0+18*32+26, 4   ; 8618
                db "NTSC"-55
                hex ff
str_pal         ppustr ppu_nt0+18*32+27, 3   ; 8620
                db "PAL"-55
                hex ff
str_credits     ppustr ppu_nt0+5*32+8, 15    ; 8627
                db "IRRITATING"-55, $24, "SHIP"-55
                ppustr ppu_nt0+7*32+4, 23
                db "2022"-48, $24, "NESDEV"-55, $24, "COMPETITION"-55
                ppustr ppu_nt0+8*32+12, 7
                db "VERSION"-55
                ppustr ppu_nt0+12*32+2, 24
                db "DESIGN"-55, $db, $24, "ART"-55, $db, $24, "PROGRAMMING"-55
                ppustr ppu_nt0+13*32+23, 7
                db "FISKBIT"-55
                ppustr ppu_nt0+15*32+2, 12
                db "MUSIC"-55, $db, $24, "SOUND"-55
                ppustr ppu_nt0+16*32+21, 9
                db "TRIROSMOS"-55
                ppustr ppu_nt0+18*32+2, 9
                db "LIBRARIES"-55
                ppustr ppu_nt0+19*32+21, 9
                db "FAMITONE"-55, "2"-48
                ppustr ppu_nt0+20*32+19, 11
                db "FAMITRACKER"-55
                hex ff

                hex b4 b4 b5 b5              ; 86c4

sub6            sta ram40                    ; 86c8: 85 47
                stx ram41                    ; 86ca: 86 48
                sta ram42                    ; 86cc: 85 49
                stx ram43                    ; 86ce: 86 4a
sub7            clc                          ; 86d0: 18
                lda ram40                    ; 86d1: a5 47
                adc #$b3                     ; 86d3: 69 b3
                sta ram40                    ; 86d5: 85 47
                adc ram41                    ; 86d7: 65 48
                sta ram41                    ; 86d9: 85 48
                adc ram42                    ; 86db: 65 49
                sta ram42                    ; 86dd: 85 49
                eor ram40                    ; 86df: 45 47
                and #%01111111               ; 86e1: 29 7f
                tax                          ; 86e3: aa
                lda ram42                    ; 86e4: a5 49
                adc ram43                    ; 86e6: 65 4a
                sta ram43                    ; 86e8: 85 4a
                eor ram41                    ; 86ea: 45 48
                rts                          ; 86ec: 60
sub8            lsr a                        ; 86ed: 4a
                sta ptr1+0                   ; 86ee: 85 00
                lda #0                       ; 86f0: a9 00
                ldy #8                       ; 86f2: a0 08
-               bcc +                        ; 86f4: 90 03
                clc                          ; 86f6: 18
                adc ptr1+1                   ; 86f7: 65 01
+               ror a                        ; 86f9: 6a
                ror ptr1+0                   ; 86fa: 66 00
                dey                          ; 86fc: 88
                bne -                        ; 86fd: d0 f5
                rts                          ; 86ff: 60

                eor #%11111111               ; 8700: 49 ff    (unaccessed)
                sta ptr1+1                   ; 8702: 85 01    (unaccessed)
                lda ptr1+0                   ; 8704: a5 00    (unaccessed)
                eor #%11111111               ; 8706: 49 ff    (unaccessed)
                clc                          ; 8708: 18       (unaccessed)
                adc #1                       ; 8709: 69 01    (unaccessed)
                sta ptr1+0                   ; 870b: 85 00    (unaccessed)
                bcc +                        ; 870d: 90 02    (unaccessed)
                inc ptr1+1                   ; 870f: e6 01    (unaccessed)
+               rts                          ; 8711: 60       (unaccessed)
                ldy #$ff                     ; 8712: a0 ff    (unaccessed)
-               iny                          ; 8714: c8       (unaccessed)
                sec                          ; 8715: 38       (unaccessed)
                sbc #$0a                     ; 8716: e9 0a    (unaccessed)
                bcs -                        ; 8718: b0 fa    (unaccessed)
                adc #$0a                     ; 871a: 69 0a    (unaccessed)
                rts                          ; 871c: 60       (unaccessed)

sub9            bit ram19                    ; 871d: 24 2e
                bpl +                        ; 871f: 10 0f
                lda arr29                    ; 8721: a5 3c
                eor #%00000001               ; 8723: 49 01
                sta arr29                    ; 8725: 85 3c
                lda #1                       ; 8727: a9 01
                jsr sub40                    ; 8729: 20 1a 9e
                lda #$10                     ; 872c: a9 10
                sta ram36                    ; 872e: 85 43
+               jsr sub10                    ; 8730: 20 7d 87
                lda ram20                    ; 8733: a5 2f
                and #%01000000               ; 8735: 29 40
                beq +                        ; 8737: f0 03
                jsr sub10                    ; 8739: 20 7d 87
+               lda arr17                    ; 873c: a5 16
                cmp #3                       ; 873e: c9 03
                beq +                        ; 8740: f0 06
                jsr sub12                    ; 8742: 20 2a 88
                jmp sub11                    ; 8745: 4c d2 87
+               jsr sub11                    ; 8748: 20 d2 87 (unaccessed)
                lda #$30                     ; 874b: a9 30    (unaccessed)
                sta arr71                    ; 874d: 8d 01 02 (unaccessed)
                rts                          ; 8750: 60       (unaccessed)

dat7            hex 00 00 ff 00              ; 8751 (last byte unaccessed)
                hex 00 00 ff 00              ; 8755 (last byte unaccessed)
                hex 00 00 ff                 ; 8759
dat8            hex 00 c0 40 00              ; 875c (last byte unaccessed)
                hex 00 88 78 00              ; 8760 (last byte unaccessed)
                hex 00 88 78                 ; 8764
dat9            hex 00 00 00 00              ; 8767 (last byte unaccessed)
                hex 00 00 00 00              ; 876b (last byte unaccessed)
                hex ff ff ff                 ; 876f
dat10           hex 00 00 00 00              ; 8772 (last byte unaccessed)
                hex c0 88 88 00              ; 8776 (last byte unaccessed)
                hex 40 78 78                 ; 877a

sub10           lda ram20                    ; 877d: a5 2f
                and #%00001111               ; 877f: 29 0f
                ldy ram49                    ; 8781: a4 53
                cpy #0                       ; 8783: c0 00
                bne +                        ; 8785: d0 02
                and #%11110111               ; 8787: 29 f7    (unaccessed)
+               cpy #$e7                     ; 8789: c0 e7
                bcc +                        ; 878b: 90 02
                and #%11111011               ; 878d: 29 fb
+               tax                          ; 878f: aa
                lda ram48                    ; 8790: a5 52
                clc                          ; 8792: 18
                adc dat8,x                   ; 8793: 7d 5c 87
                sta ram48                    ; 8796: 85 52
                lda arr33                    ; 8798: a5 51
                adc dat7,x                   ; 879a: 7d 51 87
                sta arr33                    ; 879d: 85 51
                cmp #$50                     ; 879f: c9 50
                bcs +                        ; 87a1: b0 0b
                sbc #$4f                     ; 87a3: e9 4f
                clc                          ; 87a5: 18
                adc arr30                    ; 87a6: 65 3f
                sta arr30                    ; 87a8: 85 3f
                lda #$50                     ; 87aa: a9 50
                sta arr33                    ; 87ac: 85 51
+               lda arr33                    ; 87ae: a5 51
                cmp #$85                     ; 87b0: c9 85
                bcc +                        ; 87b2: 90 0b
                sbc #$84                     ; 87b4: e9 84
                clc                          ; 87b6: 18
                adc arr30                    ; 87b7: 65 3f
                sta arr30                    ; 87b9: 85 3f
                lda #$84                     ; 87bb: a9 84
                sta arr33                    ; 87bd: 85 51
+               lda ram50                    ; 87bf: a5 54
                clc                          ; 87c1: 18
                adc dat10,x                  ; 87c2: 7d 72 87
                sta ram50                    ; 87c5: 85 54
                lda ram49                    ; 87c7: a5 53
                adc dat9,x                   ; 87c9: 7d 67 87
                sta ram49                    ; 87cc: 85 53
                rts                          ; 87ce: 60

dat11           hex 00 24 00                 ; 87cf

sub11           lda ram49                    ; 87d2: a5 53
                sta arr70                    ; 87d4: 8d 00 02
                sta ram144                   ; 87d7: 8d 0c 02
                lda #0                       ; 87da: a9 00
                sta arr72                    ; 87dc: 8d 02 02
                lda #2                       ; 87df: a9 02
                sta ram146                   ; 87e1: 8d 0e 02
                lda #4                       ; 87e4: a9 04
                sta arr71                    ; 87e6: 8d 01 02
                lda ram10                    ; 87e9: a5 20
                lsr a                        ; 87eb: 4a
                lsr a                        ; 87ec: 4a
                lsr a                        ; 87ed: 4a
                lda #$0e                     ; 87ee: a9 0e
                adc #0                       ; 87f0: 69 00
                sta ram145                   ; 87f2: 8d 0d 02
                ldy arr29                    ; 87f5: a4 3c
                lda arr33                    ; 87f7: a5 51
                clc                          ; 87f9: 18
                adc dat11,y                  ; 87fa: 79 cf 87
                sta arr73                    ; 87fd: 8d 03 02
                iny                          ; 8800: c8
                lda arr33                    ; 8801: a5 51
                clc                          ; 8803: 18
                adc dat11,y                  ; 8804: 79 cf 87
                sta ram147                   ; 8807: 8d 0f 02
                sta ram143                   ; 880a: 8d 0b 02
                lda #$fe                     ; 880d: a9 fe
                sta ram140                   ; 880f: 8d 08 02
                ldy ram36                    ; 8812: a4 43
                beq +                        ; 8814: f0 13
                dey                          ; 8816: 88
                sty ram36                    ; 8817: 84 43
                tya                          ; 8819: 98
                lsr a                        ; 881a: 4a
                lsr a                        ; 881b: 4a
                sta ram141                   ; 881c: 8d 09 02
                lda ram49                    ; 881f: a5 53
                sta ram140                   ; 8821: 8d 08 02
                lda #0                       ; 8824: a9 00
                sta ram142                   ; 8826: 8d 0a 02
+               rts                          ; 8829: 60
sub12           lda ram32                    ; 882a: a5 3d
                beq cod16                    ; 882c: f0 20

                cmp #$0b                     ; 882e: c9 0b    (unaccessed)
                lda #$10                     ; 8830: a9 10    (unaccessed)
                bcc +                        ; 8832: 90 02    (unaccessed)
                lda #$20                     ; 8834: a9 20    (unaccessed)
+               lda #$10                     ; 8836: a9 10    (unaccessed)
                sta ram137                   ; 8838: 8d 05 02 (unaccessed)
                lda #1                       ; 883b: a9 01    (unaccessed)
                sta ram138                   ; 883d: 8d 06 02 (unaccessed)
                lda arr33                    ; 8840: a5 51    (unaccessed)
                sta ram139                   ; 8842: 8d 07 02 (unaccessed)
                jsr ram49                    ; 8845: 20 53 00 (unaccessed)
                clc                          ; 8848: 18       (unaccessed)
                adc #6                       ; 8849: 69 06    (unaccessed)
                sta ram136                   ; 884b: 8d 04 02 (unaccessed)

cod16           rts                          ; 884e: 60
sub13           lda #$10                     ; 884f: a9 10
                sta ptr1+0                   ; 8851: 85 00
                ldx ram12                    ; 8853: a6 23
                ldy ram38                    ; 8855: a4 45
                beq cod18                    ; 8857: f0 44

                cpy #5                       ; 8859: c0 05    (unaccessed)
                bcc cod17                    ; 885b: 90 02    (unaccessed)
                ldy #1                       ; 885d: a0 01    (unaccessed)
cod17           lda ptr1+0                   ; 885f: a5 00    (unaccessed)
                sta arr73,x                  ; 8861: 9d 03 02 (unaccessed)
                clc                          ; 8864: 18       (unaccessed)
                adc #8                       ; 8865: 69 08    (unaccessed)
                sta ptr1+0                   ; 8867: 85 00    (unaccessed)
                lda #$12                     ; 8869: a9 12    (unaccessed)
                sta arr70,x                  ; 886b: 9d 00 02 (unaccessed)
                lda #0                       ; 886e: a9 00    (unaccessed)
                sta arr71,x                  ; 8870: 9d 01 02 (unaccessed)
                sta arr72,x                  ; 8873: 9d 02 02 (unaccessed)
                inx                          ; 8876: e8       (unaccessed)
                inx                          ; 8877: e8       (unaccessed)
                inx                          ; 8878: e8       (unaccessed)
                inx                          ; 8879: e8       (unaccessed)
                dey                          ; 887a: 88       (unaccessed)
                bne cod17                    ; 887b: d0 e2    (unaccessed)
                lda ram38                    ; 887d: a5 45    (unaccessed)
                cmp #5                       ; 887f: c9 05    (unaccessed)
                bcc +                        ; 8881: 90 18    (unaccessed)
                ora #%11110000               ; 8883: 09 f0    (unaccessed)
                sta arr71,x                  ; 8885: 9d 01 02 (unaccessed)
                lda #$12                     ; 8888: a9 12    (unaccessed)
                sta arr70,x                  ; 888a: 9d 00 02 (unaccessed)
                lda ptr1+0                   ; 888d: a5 00    (unaccessed)
                sta arr73,x                  ; 888f: 9d 03 02 (unaccessed)
                lda #0                       ; 8892: a9 00    (unaccessed)
                sta arr72,x                  ; 8894: 9d 02 02 (unaccessed)
                inx                          ; 8897: e8       (unaccessed)
                inx                          ; 8898: e8       (unaccessed)
                inx                          ; 8899: e8       (unaccessed)
                inx                          ; 889a: e8       (unaccessed)
+               stx ram12                    ; 889b: 86 23    (unaccessed)

cod18           rts                          ; 889d: 60
sub14           ldx ram12                    ; 889e: a6 23
                beq cod22                    ; 88a0: f0 7a
                lda arr23                    ; 88a2: a5 1f
                sec                          ; 88a4: 38
                sbc ram35                    ; 88a5: e5 42
                rol a                        ; 88a7: 2a
                eor #%00000001               ; 88a8: 49 01
                ror a                        ; 88aa: 6a
                lda ram34                    ; 88ab: a5 41
                adc #0                       ; 88ad: 69 00
                sta ptr2+1                   ; 88af: 85 03
                ldy #$0b                     ; 88b1: a0 0b
                sty ptr2+0                   ; 88b3: 84 02
cod19           ldy ptr2+0                   ; 88b5: a4 02
                lda ptr2+1                   ; 88b7: a5 03
                beq cod21                    ; 88b9: f0 41
                sta ptr1+1                   ; 88bb: 85 01
                lda dat13,y                  ; 88bd: b9 29 89
                clc                          ; 88c0: 18
                adc arr113,y                 ; 88c1: 79 c0 04
                jsr sub8                     ; 88c4: 20 ed 86
                sta ptr1+1                   ; 88c7: 85 01
                ldy ptr2+0                   ; 88c9: a4 02
                lda ptr1+0                   ; 88cb: a5 00
                clc                          ; 88cd: 18
                adc arr112,y                 ; 88ce: 79 b4 04
                sta arr112,y                 ; 88d1: 99 b4 04
                lda arr111,y                 ; 88d4: b9 a8 04
                adc ptr1+1                   ; 88d7: 65 01
                sta arr111,y                 ; 88d9: 99 a8 04
                bit ptr1+1                   ; 88dc: 24 01
                bmi +                        ; 88de: 30 06
                bcc cod21                    ; 88e0: 90 1a
                lda #0                       ; 88e2: a9 00
                bcs cod20                    ; 88e4: b0 04
+               bcs cod21                    ; 88e6: b0 14    (unaccessed)
                lda #$ff                     ; 88e8: a9 ff    (unaccessed)
cod20           sta arr111,y                 ; 88ea: 99 a8 04
                lda dat12,y                  ; 88ed: b9 1d 89
                adc ram43                    ; 88f0: 65 4a
                sta arr110,y                 ; 88f2: 99 9c 04
                lda ram42                    ; 88f5: a5 49
                and #%01111111               ; 88f7: 29 7f
                sta arr113,y                 ; 88f9: 99 c0 04
cod21           lda arr111,y                 ; 88fc: b9 a8 04
                sta arr70,x                  ; 88ff: 9d 00 02
                lda arr110,y                 ; 8902: b9 9c 04
                sta arr73,x                  ; 8905: 9d 03 02
                lda #$23                     ; 8908: a9 23
                sta arr72,x                  ; 890a: 9d 02 02
                lda #$fe                     ; 890d: a9 fe
                sta arr71,x                  ; 890f: 9d 01 02

                hex cb fc                    ; 8912 (unaccessed)

                beq +                        ; 8914: f0 04
                dec ptr2+0                   ; 8916: c6 02
                bpl cod19                    ; 8918: 10 9b
+               stx ram12                    ; 891a: 86 23
cod22           rts                          ; 891c: 60

dat12           hex ec                       ; 891d (unaccessed)
                hex 42 73 61 2d 94 28 22 c9  ; 891e
                hex e1 62 a9                 ; 8926
dat13           hex 20 28 30 38 40 48 50 58  ; 8929
                hex 60 68 70 78              ; 8931

                rts                          ; 8935: 60       (unaccessed)
                lda arr33                    ; 8936: a5 51    (unaccessed)
                pha                          ; 8938: 48       (unaccessed)
                clc                          ; 8939: 18       (unaccessed)
                adc #2                       ; 893a: 69 02    (unaccessed)
                sta arr33                    ; 893c: 85 51    (unaccessed)
                lda ram49                    ; 893e: a5 53    (unaccessed)
                pha                          ; 8940: 48       (unaccessed)
                clc                          ; 8941: 18       (unaccessed)
                adc #2                       ; 8942: 69 02    (unaccessed)
                sta ram49                    ; 8944: 85 53    (unaccessed)
                ldx #0                       ; 8946: a2 00    (unaccessed)
                ldy #0                       ; 8948: a0 00    (unaccessed)
cod23           lda arr33,y                  ; 894a: b9 51 00 (unaccessed)
                sty ptr1+0                   ; 894d: 84 00    (unaccessed)
                ldy #8                       ; 894f: a0 08    (unaccessed)
-               sta arr98,x                  ; 8951: 9d 3c 04 (unaccessed)
                inx                          ; 8954: e8       (unaccessed)
                dey                          ; 8955: 88       (unaccessed)
                bne -                        ; 8956: d0 f9    (unaccessed)
                ldy ptr1+0                   ; 8958: a4 00    (unaccessed)
                iny                          ; 895a: c8       (unaccessed)
                cpy #8                       ; 895b: c0 08    (unaccessed)
                bcc cod23                    ; 895d: 90 eb    (unaccessed)
                pla                          ; 895f: 68       (unaccessed)
                sta ram49                    ; 8960: 85 53    (unaccessed)
                pla                          ; 8962: 68       (unaccessed)
                sta arr33                    ; 8963: 85 51    (unaccessed)
                ldy #7                       ; 8965: a0 07    (unaccessed)
-               jsr sub7                     ; 8967: 20 d0 86 (unaccessed)
                lsr a                        ; 896a: 4a       (unaccessed)
                lsr a                        ; 896b: 4a       (unaccessed)
                sec                          ; 896c: 38       (unaccessed)
                sbc #$20                     ; 896d: e9 20    (unaccessed)
                php                          ; 896f: 08       (unaccessed)
                clc                          ; 8970: 18       (unaccessed)
                adc arr105,y                 ; 8971: 79 74 04 (unaccessed)
                sta arr105,y                 ; 8974: 99 74 04 (unaccessed)
                lda arr104,y                 ; 8977: b9 6c 04 (unaccessed)
                adc #0                       ; 897a: 69 00    (unaccessed)
                plp                          ; 897c: 28       (unaccessed)
                sbc #0                       ; 897d: e9 00    (unaccessed)
                sta arr104,y                 ; 897f: 99 6c 04 (unaccessed)
                txa                          ; 8982: 8a       (unaccessed)
                lsr a                        ; 8983: 4a       (unaccessed)
                sec                          ; 8984: 38       (unaccessed)
                sbc #$20                     ; 8985: e9 20    (unaccessed)
                php                          ; 8987: 08       (unaccessed)
                clc                          ; 8988: 18       (unaccessed)
                adc arr108,y                 ; 8989: 79 8c 04 (unaccessed)
                sta arr108,y                 ; 898c: 99 8c 04 (unaccessed)
                lda arr107,y                 ; 898f: b9 84 04 (unaccessed)
                adc #0                       ; 8992: 69 00    (unaccessed)
                plp                          ; 8994: 28       (unaccessed)
                sbc #0                       ; 8995: e9 00    (unaccessed)
                sta arr107,y                 ; 8997: 99 84 04 (unaccessed)
                dey                          ; 899a: 88       (unaccessed)
                bpl -                        ; 899b: 10 ca    (unaccessed)
                rts                          ; 899d: 60       (unaccessed)

sub15           rts                          ; 899e: 60

                ldy ram12                    ; 899f: a4 23    (unaccessed)
                ldx #7                       ; 89a1: a2 07    (unaccessed)
cod24           lda arr100,x                 ; 89a3: bd 4c 04 (unaccessed)
                clc                          ; 89a6: 18       (unaccessed)
                adc arr106,x                 ; 89a7: 7d 7c 04 (unaccessed)
                sta arr100,x                 ; 89aa: 9d 4c 04 (unaccessed)
                lda arr99,x                  ; 89ad: bd 44 04 (unaccessed)
                adc arr105,x                 ; 89b0: 7d 74 04 (unaccessed)
                sta arr99,x                  ; 89b3: 9d 44 04 (unaccessed)
                lda arr98,x                  ; 89b6: bd 3c 04 (unaccessed)
                adc arr104,x                 ; 89b9: 7d 6c 04 (unaccessed)
                sta arr98,x                  ; 89bc: 9d 3c 04 (unaccessed)
                sta arr73,y                  ; 89bf: 99 03 02 (unaccessed)
                bit arr18                    ; 89c2: 24 17    (unaccessed)
                bmi +                        ; 89c4: 30 0c    (unaccessed)
                ror a                        ; 89c6: 6a       (unaccessed)
                eor arr104,x                 ; 89c7: 5d 6c 04 (unaccessed)
                bpl +                        ; 89ca: 10 06    (unaccessed)
                jsr sub16                    ; 89cc: 20 19 8a (unaccessed)
                jmp cod25                    ; 89cf: 4c 13 8a (unaccessed)
+               lda arr103,x                 ; 89d2: bd 64 04 (unaccessed)
                clc                          ; 89d5: 18       (unaccessed)
                adc arr109,x                 ; 89d6: 7d 94 04 (unaccessed)
                sta arr103,x                 ; 89d9: 9d 64 04 (unaccessed)
                lda arr102,x                 ; 89dc: bd 5c 04 (unaccessed)
                adc arr108,x                 ; 89df: 7d 8c 04 (unaccessed)
                sta arr102,x                 ; 89e2: 9d 5c 04 (unaccessed)
                lda arr101,x                 ; 89e5: bd 54 04 (unaccessed)
                adc arr107,x                 ; 89e8: 7d 84 04 (unaccessed)
                sta arr101,x                 ; 89eb: 9d 54 04 (unaccessed)
                bit arr18                    ; 89ee: 24 17    (unaccessed)
                bmi +                        ; 89f0: 30 0c    (unaccessed)
                ror a                        ; 89f2: 6a       (unaccessed)
                eor arr107,x                 ; 89f3: 5d 84 04 (unaccessed)
                bpl +                        ; 89f6: 10 06    (unaccessed)
                jsr sub16                    ; 89f8: 20 19 8a (unaccessed)
                jmp cod25                    ; 89fb: 4c 13 8a (unaccessed)
+               lda arr101,x                 ; 89fe: bd 54 04 (unaccessed)
                sta arr70,y                  ; 8a01: 99 00 02 (unaccessed)
                lda #0                       ; 8a04: a9 00    (unaccessed)
                sta arr72,y                  ; 8a06: 99 02 02 (unaccessed)
                txa                          ; 8a09: 8a       (unaccessed)
                ora #%01010000               ; 8a0a: 09 50    (unaccessed)
                sta arr71,y                  ; 8a0c: 99 01 02 (unaccessed)
                iny                          ; 8a0f: c8       (unaccessed)
                iny                          ; 8a10: c8       (unaccessed)
                iny                          ; 8a11: c8       (unaccessed)
                iny                          ; 8a12: c8       (unaccessed)
cod25           dex                          ; 8a13: ca       (unaccessed)
                bpl cod24                    ; 8a14: 10 8d    (unaccessed)
                sty ram12                    ; 8a16: 84 23    (unaccessed)
                rts                          ; 8a18: 60       (unaccessed)
sub16           lda #$ff                     ; 8a19: a9 ff    (unaccessed)
                sta arr101,x                 ; 8a1b: 9d 54 04 (unaccessed)
                sta arr107,x                 ; 8a1e: 9d 84 04 (unaccessed)
                sta arr108,x                 ; 8a21: 9d 8c 04 (unaccessed)
                sta arr109,x                 ; 8a24: 9d 94 04 (unaccessed)
                rts                          ; 8a27: 60       (unaccessed)

dat15           hex 5e                       ; 8a28
dat16           hex 8a ca 8a 26 8b fb 8b 42  ; 8a29
                hex 8c 6b 8c 77 8c           ; 8a31
                hex 94 8c de 8c bf 8c eb 8c  ; 8a36 (unaccessed)
                hex 03 8b 53 8b              ; 8a3e

sub17           sta ppu_data                 ; 8a42: 8d 07 20
                sta ppu_data                 ; 8a45: 8d 07 20
                sta ppu_data                 ; 8a48: 8d 07 20
                sta ppu_data                 ; 8a4b: 8d 07 20
                sta ppu_data                 ; 8a4e: 8d 07 20
                sta ppu_data                 ; 8a51: 8d 07 20
                sta ppu_data                 ; 8a54: 8d 07 20
                sta ppu_data                 ; 8a57: 8d 07 20
                dey                          ; 8a5a: 88
                bne sub17                    ; 8a5b: d0 e5
                rts                          ; 8a5d: 60
                lda #0                       ; 8a5e: a9 00
                sta ram27                    ; 8a60: 85 36
                lda #1                       ; 8a62: a9 01
                sta arr16                    ; 8a64: 85 15
                sta arr17                    ; 8a66: 85 16
                jsr sub18                    ; 8a68: 20 71 8a
                jsr sub35                    ; 8a6b: 20 26 9d
                jmp cod26                    ; 8a6e: 4c ca 8a
sub18           ldy #$23                     ; 8a71: a0 23
-               lda str_palette,y            ; 8a73: b9 92 82
                sta arr96,y                  ; 8a76: 99 00 04
                dey                          ; 8a79: 88
                bpl -                        ; 8a7a: 10 f7
                lda #0                       ; 8a7c: a9 00
                sta ram153                   ; 8a7e: 8d 24 04
                rts                          ; 8a81: 60
sub19           bit ppu_status               ; 8a82: 2c 02 20
                lda #$23                     ; 8a85: a9 23
                sta ppu_addr                 ; 8a87: 8d 06 20
                lda #$c0                     ; 8a8a: a9 c0
                sta ppu_addr                 ; 8a8c: 8d 06 20
                lda #0                       ; 8a8f: a9 00
                ldy #8                       ; 8a91: a0 08
                jsr sub17                    ; 8a93: 20 42 8a
                ldy #$2b                     ; 8a96: a0 2b
                sty ppu_addr                 ; 8a98: 8c 06 20
                ldy #$c0                     ; 8a9b: a0 c0
                sty ppu_addr                 ; 8a9d: 8c 06 20
                ldy #8                       ; 8aa0: a0 08
                jsr sub17                    ; 8aa2: 20 42 8a
                lda #0                       ; 8aa5: a9 00
                ldy #9                       ; 8aa7: a0 09
-               sta arr32,y                  ; 8aa9: 99 50 00
                dey                          ; 8aac: 88
                bne -                        ; 8aad: d0 fa
                jsr sub71                    ; 8aaf: 20 c7 c7
                ldy #$0b                     ; 8ab2: a0 0b
-               jsr sub7                     ; 8ab4: 20 d0 86
                sta arr111,y                 ; 8ab7: 99 a8 04
                jsr sub7                     ; 8aba: 20 d0 86
                sta arr110,y                 ; 8abd: 99 9c 04
                dey                          ; 8ac0: 88
                bpl -                        ; 8ac1: 10 f1
                jsr sub14                    ; 8ac3: 20 9e 88
                jsr sub27                    ; 8ac6: 20 e6 9b
                rts                          ; 8ac9: 60
cod26           jsr sub71                    ; 8aca: 20 c7 c7
                lda arr18                    ; 8acd: a5 17
                cmp #1                       ; 8acf: c9 01
                beq +                        ; 8ad1: f0 22
                lda #0                       ; 8ad3: a9 00
                sta arr15                    ; 8ad5: 85 14
                sta arr14                    ; 8ad7: 85 13
                sta ppu_mask                 ; 8ad9: 8d 01 20
                jsr sub38                    ; 8adc: 20 d1 9d
                jsr sub26                    ; 8adf: 20 d3 9b
                lda #$0b                     ; 8ae2: a9 0b
                sta arr20                    ; 8ae4: 85 19
                lda #1                       ; 8ae6: a9 01
                sta arr19                    ; 8ae8: 85 18
                lda #$1e                     ; 8aea: a9 1e
                sta arr15                    ; 8aec: 85 14
                lda #$88                     ; 8aee: a9 88
                sta arr13                    ; 8af0: 85 12
                sta ppu_ctrl                 ; 8af2: 8d 00 20
+               jsr sub20                    ; 8af5: 20 26 8b
                lda arr16                    ; 8af8: a5 15
                cmp arr17                    ; 8afa: c5 16
                beq +                        ; 8afc: f0 04
                lda #$80                     ; 8afe: a9 80
                sta arr19                    ; 8b00: 85 18
+               rts                          ; 8b02: 60
                lda #0                       ; 8b03: a9 00
                sta ram34                    ; 8b05: 85 41
                jsr sub71                    ; 8b07: 20 c7 c7
                lda ram19                    ; 8b0a: a5 2e
                and #%10010000               ; 8b0c: 29 90
                beq +                        ; 8b0e: f0 15
                lda #0                       ; 8b10: a9 00
                jsr sub37                    ; 8b12: 20 bf 9d
                lda #6                       ; 8b15: a9 06
                sta arr20                    ; 8b17: 85 19
                lda #4                       ; 8b19: a9 04
                sta arr17                    ; 8b1b: 85 16
                lda #0                       ; 8b1d: a9 00
                sta arr19                    ; 8b1f: 85 18
                lda #0                       ; 8b21: a9 00
                sta ram27                    ; 8b23: 85 36
+               rts                          ; 8b25: 60
sub20           lda ram33                    ; 8b26: a5 3e
                bne +                        ; 8b28: d0 04
                lda #9                       ; 8b2a: a9 09
                sta ram33                    ; 8b2c: 85 3e
+               dec ram33                    ; 8b2e: c6 3e
                bne cod27                    ; 8b30: d0 15
                ldy arr20                    ; 8b32: a4 19
                sty arr17                    ; 8b34: 84 16
                cpy #$0b                     ; 8b36: c0 0b
                bcc +                        ; 8b38: 90 06
                lda ram20                    ; 8b3a: a5 2f
                and #%01111111               ; 8b3c: 29 7f
                sta ram20                    ; 8b3e: 85 2f
+               cpy #$0c                     ; 8b40: c0 0c
                bne cod27                    ; 8b42: d0 03
                jsr sub39                    ; 8b44: 20 0e 9e
cod27           lda ram33                    ; 8b47: a5 3e
                clc                          ; 8b49: 18
                adc #3                       ; 8b4a: 69 03
                and #%00001100               ; 8b4c: 29 0c
                asl a                        ; 8b4e: 0a
                asl a                        ; 8b4f: 0a
                jmp sub22                    ; 8b50: 4c fc 8c
                lda arr14                    ; 8b53: a5 13
                ora #%00011110               ; 8b55: 09 1e
                sta arr15                    ; 8b57: 85 14
                lda ram19                    ; 8b59: a5 2e
                and #%00010000               ; 8b5b: 29 10
                beq +                        ; 8b5d: f0 06
                lda ram37                    ; 8b5f: a5 44
                eor #%00000001               ; 8b61: 49 01
                sta ram37                    ; 8b63: 85 44
+               lda ram37                    ; 8b65: a5 44
                beq +                        ; 8b67: f0 07
                lda arr14                    ; 8b69: a5 13
                and #%11100001               ; 8b6b: 29 e1
                sta arr15                    ; 8b6d: 85 14
                rts                          ; 8b6f: 60
+               ldy ram27                    ; 8b70: a4 36
                lda dat23,y                  ; 8b72: b9 43 90
                sta arr31                    ; 8b75: 85 40
                lda dat22,y                  ; 8b77: b9 3c 90
                sta arr30                    ; 8b7a: 85 3f
                lda dat25,y                  ; 8b7c: b9 51 90
                sta ram35                    ; 8b7f: 85 42
                lda dat24,y                  ; 8b81: b9 4a 90
                sta ram34                    ; 8b84: 85 41
                lda ram29                    ; 8b86: a5 38
                beq +                        ; 8b88: f0 05
                ldy #4                       ; 8b8a: a0 04
                jmp cod28                    ; 8b8c: 4c 97 8b
+               lda ram20                    ; 8b8f: a5 2f
                and #%00100000               ; 8b91: 29 20
                beq cod29                    ; 8b93: f0 0d
                ldy #2                       ; 8b95: a0 02
cod28           asl arr31                    ; 8b97: 06 40
                rol arr30                    ; 8b99: 26 3f
                asl ram35                    ; 8b9b: 06 42
                rol ram34                    ; 8b9d: 26 41
                dey                          ; 8b9f: 88
                bne cod28                    ; 8ba0: d0 f5
cod29           jsr sub71                    ; 8ba2: 20 c7 c7
                jsr sub9                     ; 8ba5: 20 1d 87
                jsr sub14                    ; 8ba8: 20 9e 88
                jsr sub33                    ; 8bab: 20 e8 9c
                lda ram28                    ; 8bae: a5 37
                bne +                        ; 8bb0: d0 20
                lda ram27                    ; 8bb2: a5 36
                asl a                        ; 8bb4: 0a
                tay                          ; 8bb5: a8
                iny                          ; 8bb6: c8
                iny                          ; 8bb7: c8
                lda ptr4+0                   ; 8bb8: a5 30
                cmp cod47,y                  ; 8bba: d9 26 9b
                bne +                        ; 8bbd: d0 13
                lda ptr4+1                   ; 8bbf: a5 31
                cmp dat28,y                  ; 8bc1: d9 27 9b
                bne +                        ; 8bc4: d0 0c
                lda #$10                     ; 8bc6: a9 10
                sta ram25                    ; 8bc8: 85 34
                sta ram28                    ; 8bca: 85 37
                lda #0                       ; 8bcc: a9 00
                sta ram31                    ; 8bce: 85 3a
                sta ram30                    ; 8bd0: 85 39
+               lda ram28                    ; 8bd2: a5 37
                beq +                        ; 8bd4: f0 1a
                lda ram31                    ; 8bd6: a5 3a
                clc                          ; 8bd8: 18
                adc ram35                    ; 8bd9: 65 42
                sta ram31                    ; 8bdb: 85 3a
                lda ram30                    ; 8bdd: a5 39
                adc ram34                    ; 8bdf: 65 41
                sta ram30                    ; 8be1: 85 39
                lda ram49                    ; 8be3: a5 53
                clc                          ; 8be5: 18
                adc #$10                     ; 8be6: 69 10
                cmp ram30                    ; 8be8: c5 39
                bcs +                        ; 8bea: b0 04
                lda #1                       ; 8bec: a9 01
                sta ram29                    ; 8bee: 85 38
+               lda #0                       ; 8bf0: a9 00
                sta arr30                    ; 8bf2: 85 3f
                sta arr31                    ; 8bf4: 85 40
                sta ram34                    ; 8bf6: 85 41
                sta ram35                    ; 8bf8: 85 42
                rts                          ; 8bfa: 60
                jsr sub71                    ; 8bfb: 20 c7 c7
                lda ram33                    ; 8bfe: a5 3e
                bne +                        ; 8c00: d0 04
                lda #$16                     ; 8c02: a9 16
                sta ram33                    ; 8c04: 85 3e
+               lda arr71                    ; 8c06: ad 01 02
                cmp #$30                     ; 8c09: c9 30
                bcc +                        ; 8c0b: 90 13
                cmp #$3a                     ; 8c0d: c9 3a
                bcs +                        ; 8c0f: b0 0f
                adc #1                       ; 8c11: 69 01
                pha                          ; 8c13: 48
                jsr sub11                    ; 8c14: 20 d2 87
                pla                          ; 8c17: 68
                sta arr71                    ; 8c18: 8d 01 02
                lda #1                       ; 8c1b: a9 01
                sta arr72                    ; 8c1d: 8d 02 02
+               dec ram33                    ; 8c20: c6 3e
                bne +                        ; 8c22: d0 14
                lda #0                       ; 8c24: a9 00
                sta ram28                    ; 8c26: 85 37
                sta ram25                    ; 8c28: 85 34
                lda #1                       ; 8c2a: a9 01
                sta arr19                    ; 8c2c: 85 18
                lda #6                       ; 8c2e: a9 06
                ldy arr18                    ; 8c30: a4 17
                sta arr20                    ; 8c32: 85 19
                lda #5                       ; 8c34: a9 05
                sta arr17                    ; 8c36: 85 16
+               jsr sub14                    ; 8c38: 20 9e 88
                jsr sub15                    ; 8c3b: 20 9e 89
                rts                          ; 8c3e: 60
                jmp ($5a5a)                  ; 8c3f: 6c 5a 5a (unaccessed)
sub21           lda ram33                    ; 8c42: a5 3e
                bne +                        ; 8c44: d0 04
                lda #$0d                     ; 8c46: a9 0d
                sta ram33                    ; 8c48: 85 3e
+               dec ram33                    ; 8c4a: c6 3e
                bne +                        ; 8c4c: d0 0a
                lda arr20                    ; 8c4e: a5 19
                sta arr17                    ; 8c50: 85 16
                lda #0                       ; 8c52: a9 00
                sta arr15                    ; 8c54: 85 14
                sta arr13                    ; 8c56: 85 12
+               lda ram33                    ; 8c58: a5 3e
                cmp #$0d                     ; 8c5a: c9 0d
                bcs +                        ; 8c5c: b0 0c
                clc                          ; 8c5e: 18
                adc #3                       ; 8c5f: 69 03
                and #%00001100               ; 8c61: 29 0c
                eor #%00001100               ; 8c63: 49 0c
                asl a                        ; 8c65: 0a
                asl a                        ; 8c66: 0a
                jsr sub22                    ; 8c67: 20 fc 8c
+               rts                          ; 8c6a: 60
                jsr sub71                    ; 8c6b: 20 c7 c7
                jsr sub21                    ; 8c6e: 20 42 8c
                jsr sub14                    ; 8c71: 20 9e 88
                jmp sub15                    ; 8c74: 4c 9e 89
                jsr sub19                    ; 8c77: 20 82 8a
                lda #$0c                     ; 8c7a: a9 0c
                sta arr20                    ; 8c7c: 85 19
                lda #2                       ; 8c7e: a9 02
                sta arr17                    ; 8c80: 85 16
                lda #0                       ; 8c82: a9 00
                sta arr19                    ; 8c84: 85 18
                lda #$1e                     ; 8c86: a9 1e
                sta arr15                    ; 8c88: 85 14
                lda arr13                    ; 8c8a: a5 12
                ora #%10001000               ; 8c8c: 09 88
                sta arr13                    ; 8c8e: 85 12
                sta ppu_ctrl                 ; 8c90: 8d 00 20
                rts                          ; 8c93: 60

                jsr sub71                    ; 8c94: 20 c7 c7 (unaccessed)
                lda #0                       ; 8c97: a9 00    (unaccessed)
                sta arr22                    ; 8c99: 85 1e    (unaccessed)
                jsr sub5                     ; 8c9b: 20 3b 82 (unaccessed)
                lda #$16                     ; 8c9e: a9 16    (unaccessed)
                jsr sub2                     ; 8ca0: 20 f6 80 (unaccessed)
                lda #8                       ; 8ca3: a9 08    (unaccessed)
                sta arr20                    ; 8ca5: 85 19    (unaccessed)
                lda #2                       ; 8ca7: a9 02    (unaccessed)
                sta arr17                    ; 8ca9: 85 16    (unaccessed)
                lda #0                       ; 8cab: a9 00    (unaccessed)
                sta arr19                    ; 8cad: 85 18    (unaccessed)
                lda #$1e                     ; 8caf: a9 1e    (unaccessed)
                sta arr15                    ; 8cb1: 85 14    (unaccessed)
                lda #$88                     ; 8cb3: a9 88    (unaccessed)
                sta arr13                    ; 8cb5: 85 12    (unaccessed)
                sta ppu_ctrl                 ; 8cb7: 8d 00 20 (unaccessed)
                rts                          ; 8cba: 60       (unaccessed)

                hex dc dc                    ; 8cbb           (unaccessed)

                ; e1 24 = SBC (24,x)
                ; 24 nn = BIT nn
                hex e1 24                    ; 8cbd           (unaccessed)

                jsr sub5                     ; 8cbf: 20 3b 82 (unaccessed)
                lda #$20                     ; 8cc2: a9 20    (unaccessed)
                jsr sub2                     ; 8cc4: 20 f6 80 (unaccessed)
                lda #$0a                     ; 8cc7: a9 0a    (unaccessed)
                sta arr20                    ; 8cc9: 85 19    (unaccessed)
                lda #2                       ; 8ccb: a9 02    (unaccessed)
                sta arr17                    ; 8ccd: 85 16    (unaccessed)
                lda #0                       ; 8ccf: a9 00    (unaccessed)
                sta arr19                    ; 8cd1: 85 18    (unaccessed)
                lda #$1e                     ; 8cd3: a9 1e    (unaccessed)
                sta arr15                    ; 8cd5: 85 14    (unaccessed)
                lda #$88                     ; 8cd7: a9 88    (unaccessed)
                sta arr13                    ; 8cd9: 85 12    (unaccessed)
                sta ppu_ctrl                 ; 8cdb: 8d 00 20 (unaccessed)
                bit ram19                    ; 8cde: 24 2e    (unaccessed)
                bvc +                        ; 8ce0: 50 09    (unaccessed)
                lda #9                       ; 8ce2: a9 09    (unaccessed)
                sta arr20                    ; 8ce4: 85 19    (unaccessed)
                lda #4                       ; 8ce6: a9 04    (unaccessed)
                sta arr17                    ; 8ce8: 85 16    (unaccessed)
                rts                          ; 8cea: 60       (unaccessed)
+               bit ram19                    ; 8ceb: 24 2e    (unaccessed)
                bpl +                        ; 8ced: 10 0c    (unaccessed)
                lda #1                       ; 8cef: a9 01    (unaccessed)
                sta arr20                    ; 8cf1: 85 19    (unaccessed)
                lda #4                       ; 8cf3: a9 04    (unaccessed)
                sta arr17                    ; 8cf5: 85 16    (unaccessed)
                lda #0                       ; 8cf7: a9 00    (unaccessed)
                sta arr19                    ; 8cf9: 85 18    (unaccessed)
+               rts                          ; 8cfb: 60       (unaccessed)

sub22           sta ptr1+0                   ; 8cfc: 85 00
                ldy ram18                    ; 8cfe: a4 2d
                lda #$3f                     ; 8d00: a9 3f
                sta arr61,y                  ; 8d02: 99 10 01
                lda #0                       ; 8d05: a9 00
                sta arr62,y                  ; 8d07: 99 11 01
                lda #$20                     ; 8d0a: a9 20
                sta arr63,y                  ; 8d0c: 99 12 01
                lda #$ff                     ; 8d0f: a9 ff
                sta arr65,y                  ; 8d11: 99 33 01
                tya                          ; 8d14: 98
                clc                          ; 8d15: 18
                adc #$1f                     ; 8d16: 69 1f
                tay                          ; 8d18: a8
                ldx #$1f                     ; 8d19: a2 1f
cod30           lda arr97,x                  ; 8d1b: bd 03 04
                and #%00001111               ; 8d1e: 29 0f
                cmp #$0d                     ; 8d20: c9 0d
                bcs +                        ; 8d22: b0 08
                lda arr97,x                  ; 8d24: bd 03 04
                sec                          ; 8d27: 38
                sbc ptr1+0                   ; 8d28: e5 00
                bcs cod31                    ; 8d2a: b0 02
+               lda #$0f                     ; 8d2c: a9 0f
cod31           sta arr64,y                  ; 8d2e: 99 13 01
                dey                          ; 8d31: 88
                dex                          ; 8d32: ca
                bpl cod30                    ; 8d33: 10 e6
                tya                          ; 8d35: 98
                clc                          ; 8d36: 18
                adc #$20                     ; 8d37: 69 20
                sta ram18                    ; 8d39: 85 2d
                rts                          ; 8d3b: 60

dat17           hex f8 38 f8 f8 40 a1 61 f8  ; 8d3c
                hex 31 f8 50 c1 f8 f8 91 41  ; 8d44
                hex f8 51 f8 f8 71 59 34 f8  ; 8d4c
                hex f8 f8 f8 f8 f8 40 38 38  ; 8d54
                hex f8 f8 37 38 38 37 28 69  ; 8d5c
                hex 37 37 38 37 37 25 6f 38  ; 8d64
                hex 38 47 38 f8 37 37 48 79  ; 8d6c
                hex 48 38 6d 28 6a 34 f8 39  ; 8d74
                hex 7e 9e 25 28 39 f8 f8 7a  ; 8d7c
                hex 48 37 38 48 38 f8 f8 34  ; 8d84
                hex 34 99 25 89 25 88 f8 f8  ; 8d8c
                hex f8 34 99 25 26           ; 8d94
                hex f8                       ; 8d99 (unaccessed)
                hex 35 34 f8 f8 f8 25        ; 8d9a

                ; 8da0-8dfb: unaccessed data
                hex f8 f8 f8 39 f8 37 8b 8d  ; 8da0
                hex 24 39 f8 34 f8 46 f8 f8  ; 8da8
                hex f8 60 31 40 51 51 51 31  ; 8db0
                hex 40 64 40 38 38 64 51 64  ; 8db8
                hex 31 53 38 31 f8 31 40 51  ; 8dc0
                hex 32 f8 42 f8 f8 f8 40 52  ; 8dc8
                hex 30 f8 30 40 38 38 53 f8  ; 8dd0
                hex 53 f8 f8 42 34 25 a2 f8  ; 8dd8
                hex f8 25 25 92 34 34 25 44  ; 8de0
                hex 25 f8 33 f8 f8 50 41 a6  ; 8de8
                hex 50 f8 61 f8 41 61 40 f8  ; 8df0
                hex f8 f8 f8 f8              ; 8df8

dat18           hex f8 39 37 f8 41 51 f8 f8  ; 8dfc
                hex f8 f8 51 41 f8 40 61 31  ; 8e04
                hex 50 61 f8 50 31 31 f8 34  ; 8e0c
                hex 34 34 f8 f8 7b 7c 38 39  ; 8e14
                hex f8 f8 38 38 39 6a 28 38  ; 8e1c
                hex 39 38 39 39 8b 25 28 38  ; 8e24
                hex 39 9e 39 f8              ; 8e2c
                hex 39 7a 48 7a 49 7a 28 8f  ; 8e30
                hex 28 f8 37 f8 48 25 6f 69  ; 8e38
                hex f8 f8 37 48 79 38 38 79  ; 8e40
                hex 38 34 f8 f8 f8 89 99 25  ; 8e48
                hex 8a 25 f8 34 34 f8 25 35  ; 8e50
                hex f8                       ; 8e58

                hex 88                       ; 8e59 (unaccessed)
                hex 25 f8 34 f8 24 89        ; 8e5a

                ; 8e60-8ebb: unaccessed data
                hex 34 34 f8 f8 34 38 25 38  ; 8e60
                hex 25 f8 f8 f8 44 f8 f8 f8  ; 8e68
                hex 50 61 f8 41 61 61 41 50  ; 8e70
                hex 63 61 63 38 38 61 63 41  ; 8e78
                hex 50 38 54 50 50 f8 41 61  ; 8e80
                hex f8 f8 f8 f8 f8 30 52 f8  ; 8e88
                hex 31 32 31 61 38 54 38 f8  ; 8e90
                hex 54 50 30 f8 93 94 f8 f8  ; 8e98
                hex 44 25 46 f8 34 24 26 25  ; 8ea0
                hex 46 33 f8 f8 f8 51 31 31  ; 8ea8
                hex a5 60 40 40 51 f8 52 f8  ; 8eb0
                hex f8 f8 92 f8              ; 8eb8

dat20           hex f8 48 f8 28 f8 91 f8 f8  ; 8ebc
                hex 41 f8 51 f8 71 f8 f8 40  ; 8ec4
                hex a1 61 31 50 c1 c1 34 f8  ; 8ecc
                hex 50 f8 89 25 25 f8 48 48  ; 8ed4
                hex 94 f8 9f 38 38 37 38 38  ; 8edc
                hex 37 37 38 8d 37 f8 37 38  ; 8ee4
                hex 79 f8 38 28 69 37 f8 37  ; 8eec
                hex f8 38 37 38 38 8f 28 39  ; 8ef4
                hex 34 f8 f8 48 9e 6f f8 39  ; 8efc
                hex f8 8d 48 f8 7a 25 25 44  ; 8f04
                hex 99 f8 f8 34 f8 34 26 f8  ; 8f0f
                hex 25 88 f8 f8 34           ; 8f14
                hex f8                       ; 8f19 (unaccessed)
                hex 34 35 25 25 f8 f8        ; 8f1a

                ; 8f20-8f7b: unaccessed data
                hex f8 25 25 49 f8 47 39 37  ; 8f20
                hex 34 8b f8 46 f8 f8 6e 27  ; 8f28
                hex f8 f8 52 50 41 52 61 41  ; 8f30
                hex 50 41 f8 63 38 61 61 61  ; 8f38
                hex 41 38 38 54 50 54 50 54  ; 8f40
                hex f8 50 41 32 f8 f8 f8 f8  ; 8f48
                hex 40 f8 40 f8 63 38 63 50  ; 8f50
                hex 38 f8 50 61 34 f8 26 24  ; 8f58
                hex 25 25 25 34 46 34 f8 f8  ; 8f60
                hex f8 f8 f8 f8 33 b6 40 40  ; 8f68
                hex 51 f8 f8 f8 51 31 f8 31  ; 8f70
                hex 42 f8 f8 30              ; 8f78

dat21           hex f8 49 47 29 40 61 f8 27  ; 8f7c
                hex 31 50 61 40 31 f8 f8 41  ; 8f84
                hex 51 f8 f8 51 41 41 f8 6b  ; 8f8c
                hex 6c 34 25 25 8a 88 48 9e  ; 8f94
                hex f8 93 48 38 39 38 38 38  ; 8f9c
                hex 39 38 8b 39 39 f8 38 7a  ; 8fa4
                hex 39 f8 6a 28 39 39 f8 39  ; 8fac
                hex f8 39 38 6a 38 f8 69 f8  ; 8fb4
                hex f8 f8 7e 48 25 28 37 f8  ; 8fbc
                hex 7e 38 79 37 48 99 94 25  ; 8fc4
                hex 25 34 f8 f8 34 f8 f8 88  ; 8fcc
                hex 8a 25 f8 34 f8           ; 8fd4

                hex 34                       ; 8fd9 (unaccessed)
                hex f8 25 46                 ; 8fda
                hex 89 34 34
                hex 44                       ; 8fe0 (unaccessed)

                ; 8fe1-903b: unaccessed data
                hex 35 26 f8 a2 48 f8 38 f8  ; 8fe1
                hex 25 24 f8 f8 f8 25 28 60  ; 8fe9
                hex f8 f8 51 31 f8 40 51 51  ; 8ff1
                hex 31 40 38 64 f8 40 40 53  ; 8ff9
                hex 38 38 51 53 31 53 31 f8  ; 9001
                hex 42 31 f8 32 40 f8 f8 41  ; 9009
                hex f8 52 f8 64 64 38 31 38  ; 9011
                hex 40 51 f8 f8 f8 f8 25 25  ; 9019
                hex 25 25 f8 34 34 34 f8 f8  ; 9021
                hex f8 f8 33 f8 61 b5 41 61  ; 9029
                hex f8 f8 50 41 f8 30 50 f8  ; 9031
                hex 30 a2 31                 ; 9039

dat22           hex 00 00 00                 ; 903c
                hex ff 00 00 01              ; 903f (unaccessed)
dat23           hex 00 00 00                 ; 9043
                hex 80 00 80 00              ; 9046 (unaccessed)
dat24           hex 00 00 00                 ; 904a
                hex 00 00 00 00              ; 904d (unaccessed)
dat25           hex 80 40 20                 ; 9051
                hex 80 80 80 40              ; 9054 (unaccessed)
dat26           hex 04 00 00                 ; 9058
                hex 00 04 00 34              ; 905b (unaccessed)
dat27           hex 00 00 00                 ; 905f
                hex 00 00 80 00              ; 9062 (unaccessed)

                hex 00 00 00 00 00 00 00 00  ; 9066
                hex 00 00 00 00 00 00 00 00  ; 906e
                hex 01 00 00 00 00 00 00 02  ; 9076
                hex 01 00 00 00 00 00 00 02  ; 907e
                hex 03 00                    ; 9086
                hex 00 04 05 06 00 07 03 00  ; 9088
                hex 00 04 05 06 00 07 00 00  ; 9090
                hex 04 08 09 0a 06 00 00 00  ; 9098
                hex 04 08 09 0a 06 00 00 04  ; 90a0
                hex 08 00 00 09 0a 06 00 04  ; 90a8
                hex 08 00 00 09 0a 06 0b 08  ; 90b0
                hex 00 00 00 00 09 0a 0b 08  ; 90b8
                hex 00 00 00 00 09 0a 0c 00  ; 90c0
                hex 00 0d 0e 00 00 09 0c 00  ; 90c8
                hex 00 0d 0e 00 00 09 00 00  ; 90d0
                hex 0d 0f 10 11 00 00 00 00  ; 90d8
                hex 0d 0f 10 11 00 00 00 0d  ; 90e0
                hex 0f 12 00 13 11 00 00 0d  ; 90e8
                hex 0f 12 00 13 11 00 0d 0f  ; 90f0
                hex 12 0d 0e 00 13 11 0d 0f  ; 90f8
                hex 12 0d 0e 00 13 11 14 12  ; 9100
                hex 0d 0f 10 11 00 13 14 12  ; 9108
                hex 0d 0f 10 11 00 13 00 0d  ; 9110
                hex 0f 12 00 13 11 00 00 0d  ; 9118
                hex 0f 12 00 13 11 00 0d 0f  ; 9120
                hex 12 0d 0e 00 13 11 0d 0f  ; 9128
                hex 12 0d 0e 00 13 11 15 12  ; 9130
                hex 0d 0f 10 11 00 13 15 12  ; 9138
                hex 0d 0f 10 11 00 13 16 00  ; 9140
                hex 17 12 00 18 00 00 16 00  ; 9148
                hex 17 12 00 18 00 00 16 00  ; 9150
                hex 19 00 00 19 00 00 16 00  ; 9158
                hex 19 00 00 19 00 00 1a 1b  ; 9160
                hex 1c 06 00 1d 1b 1b 1a 1b  ; 9168
                hex 1c 06 00 1d 1b 1b 00 00  ; 9170
                hex 09 0a 0b 08 00 00 00 00  ; 9178
                hex 09 0a 0b 08 00 00 00 00  ; 9180
                hex 00 09 0c 00 00 00 00 00  ; 9188
                hex 00 09 0c 00 00 00 1e 1e  ; 9190
                hex 1e 1e 1e 1e 1f 20 21 22  ; 9198
                hex 1e 1e 1e 1e 1e 1e 23 23  ; 91a0
                hex 23 23 23 23 24 00 00 25  ; 91a8
                hex 26 26 27 23 23 23 23 23  ; 91b0
                hex 23 23 23 23 24 00 00 28  ; 91b8
                hex 00 00 29 23 23 23 23 23  ; 91c0
                hex 23 23 23 23 2a 1b 1b 2b  ; 91c8
                hex 00 00 29 23 23 23 23 23  ; 91d0
                hex 23 23 23 23 24 00 00 2c  ; 91d8
                hex 2d 2d 2e 27 23 23 23 23  ; 91e0
                hex 23 23 23 23 24 00 00 28  ; 91e8
                hex 00 00 00 29 23 23 23 23  ; 91f0
                hex 23 23 23 23 2f 1e 1e 30  ; 91f8
                hex 00 00 31 2e 26 27 23 23  ; 9200
                hex 23 23 23 23 32 33 33 34  ; 9208
                hex 00 00 28 00 00 29 23 23  ; 9210
                hex 23 23 23 23 24 00 00 35  ; 9218
                hex 36 36 37 38 00 29 23 23  ; 9220
                hex 23 23 23 23 39 36 36 3a  ; 9228
                hex 26 26 3b 03 00 29 23 23  ; 9230
                hex 3c 26 26 3b 33 33 33 3d  ; 9238
                hex 00 00 19 00 00 29 33 3e  ; 9240
                hex 3f 00 00 19 00 00 00 40  ; 9248
                hex 41 2d 42 43 44 45 00 46  ; 9250
                hex 47 36 36 48 1f 1b 1b 49  ; 9258
                hex 3f 00 00 46 3f 00 1e 4a  ; 9260
                hex 23 23 23 23 24 00 00 29  ; 9268
                hex 47 36 36 4b 4c 1e 33 33  ; 9270
                hex 33 33 33 33 33 20 21 45  ; 9278
                hex 33 33 33 33 33 33 1b 1b  ; 9280
                hex 1b 1b 4d 1b 4e 00 00 4f  ; 9288
                hex 1b 4d 1b 1b 50 1b 00 00  ; 9290
                hex 00 00 19 00 00 00 00 16  ; 9298
                hex 00 19 00 00 16 00 2d 2d  ; 92a0
                hex 2d 2d 51 2d 52 2d 2d 53  ; 92a8
                hex 2d 54 00 00 55 2d 00 00  ; 92b0
                hex 00 00 16 00 19 00 00 00  ; 92b8
                hex 00 19 00 00 16 00 00 00  ; 92c0
                hex 00 00 16 00 19 00 00 00  ; 92c8
                hex 00 19 00 00 16 00 1b 1b  ; 92d0
                hex 50 1b 56 00 57 1b 50 1b  ; 92d8
                hex 1b 58 00 00 59 1b 00 00  ; 92e0
                hex 16 00 00 00 19 00 16 00  ; 92e8
                hex 00 19 00 00 16 00 5a 2d  ; 92f0
                hex 53 2d 5a 2d 54 00 55 2d  ; 92f8
                hex 2d 5b 2d 2d 5e 2d 16 00  ; 9300
                hex 00 00 16 00 19 00 16 00  ; 9308
                hex 00 19 00 00 16 00 16 00  ; 9310
                hex 00 00 16 00 19 00 16 00  ; 9318
                hex 00 19 00 00 16 00 5f 1b  ; 9320
                hex 60 00 59 1b 61 4d 1a 1b  ; 9328
                hex 1b 58 00 00 59 1b 16 00  ; 9330
                hex 19 00 16 00 00 19 00 00  ; 9338
                hex 00 19 00 00 16 00 5c 00  ; 9340
                hex 62 2d 53 2d 2d 63 2d 2d  ; 9348
                hex 2d 63 2d 2d 53 2d        ; 9350

                ; 9356-9b25: unaccessed data
                hex 1b 4e 00 64 1b 60 00 64  ; 9356
                hex 1b 4e 00 64 1b 60 00 64  ; 935e
                hex 00 00 00 19 00 19 00 19  ; 9366
                hex 00 00 00 19 00 19 00 19  ; 936e
                hex 00 64 1b 61 1b 65 1b 66  ; 9376
                hex 00 64 1b 61 1b 65 1b 66  ; 937e
                hex 00 19 00 00 00 19 00 00  ; 9386
                hex 00 19 00 00 00 19 00 00  ; 938e
                hex 1b 58 00 64 1b 61 1b 4d  ; 9396
                hex 1b 58 00 64 1b 61 1b 4d  ; 939e
                hex 00 19 00 19 00 00 00 19  ; 93a6
                hex 00 19 00 19 00 00 00 19  ; 93ae
                hex 1b 65 1b 66 00 64 1b 61  ; 93b6
                hex 1b 65 1b 66 00 64 1b 61  ; 93be
                hex 00 19 00 00 00 19 00 00  ; 93c6
                hex 00 19 00 00 00 19 00 00  ; 93ce
                hex 1b 61 1b 4d 1b 58 00 64  ; 93d6
                hex 1b 61 1b 4d 1b 58 00 64  ; 93de
                hex 00 00 00 19 00 19 00 19  ; 93e6
                hex 00 00 00 19 00 19 00 19  ; 93ee
                hex 00 64 1b 61 1b 65 1b 66  ; 93f6
                hex 00 64 1b 61 1b 65 1b 66  ; 93fe
                hex 00 19 00 00 00 19 00 00  ; 9406
                hex 00 19 00 00 00 19 00 00  ; 940e
                hex 1b 58 00 64 1b 61 1b 4d  ; 9416
                hex 1b 58 00 64 1b 61 1b 4d  ; 941e
                hex 00 19 00 19 00 00 00 19  ; 9426
                hex 00 19 00 19 00 00 00 19  ; 942e
                hex 1b 65 1b 66 00 64 1b 61  ; 9436
                hex 1b 65 1b 66 00 64 1b 61  ; 943e
                hex 00 19 00 00 00 19 00 00  ; 9446
                hex 00 19 00 00 00 19 00 00  ; 944e
                hex 1b 61 1b 4d 1b 58 00 64  ; 9456
                hex 1b 61 1b 4d 1b 58 00 64  ; 945e
                hex 00 00 00 19 00 19 00 19  ; 9466
                hex 00 00 00 19 00 19 00 19  ; 946e
                hex 00 64 1b 61 1b 65 1b 66  ; 9476
                hex 00 64 1b 61 1b 65 1b 66  ; 947e
                hex 00 19 00 00 00 19 00 00  ; 9486
                hex 00 19 00 00 00 19 00 00  ; 948e
                hex 1b 66 00 21 1b 61 1b 1b  ; 9496
                hex 1b 66 00 21 1b 61 1b 1b  ; 949e
                hex 1e 1e 1e 67 00 68 00 00  ; 94a6
                hex 00 00 68 00 00 69 1e 1e  ; 94ae
                hex 23 23 23 3f 00 5d 2d 2d  ; 94b6
                hex 2d 2d 54 00 00 29 23 23  ; 94be
                hex 23 23 23 3f 00 19 00 00  ; 94c6
                hex 00 00 19 00 00 29 23 23  ; 94ce
                hex 23 23 23 6a 2d 54 00 00  ; 94d6
                hex 00 00 19 00 00 29 23 23  ; 94de
                hex 23 23 23 3f 00 19 00 00  ; 94e6
                hex 00 00 19 00 00 29 23 23  ; 94ee
                hex 23 23 23 3f 00 57 1b 1b  ; 94f6
                hex 1b 1b 65 1b 1b 49 23 23  ; 94fe
                hex 23 23 23 3f 00 19 00 00  ; 9506
                hex 00 00 19 00 00 29 23 23  ; 950e
                hex 23 23 23 6a 2d 5b 2d 2d  ; 9516
                hex 5a 2d 54 00 00 29 23 23  ; 951e
                hex 23 23 23 3f 00 19 00 00  ; 9526
                hex 16 00 19 00 00 29 23 23  ; 952e
                hex 23 23 23 3f 00 19 00 00  ; 9536
                hex 16 00 5d 2d 2d 6b 23 23  ; 953e
                hex 23 23 23 3f 00 19 00 00  ; 9546
                hex 16 00 19 00 00 29 23 23  ; 954e
                hex 23 23 23 3f 00 19 00 00  ; 9556
                hex 6c 2d 54 00 00 29 23 23  ; 955e
                hex 23 23 23 3f 00 19 00 00  ; 9566
                hex 00 00 19 00 00 29 23 23  ; 956e
                hex 23 23 23 3f 00 19 00 00  ; 9576
                hex 00 00 19 00 00 29 23 23  ; 957e
                hex 23 23 23 6d 1b 58 00 00  ; 9586
                hex 4f 1b 65 1b 1b 49 23 23  ; 958e
                hex 23 23 23 3f 00 19 00 00  ; 9596
                hex 16 00 19 00 00 29 23 23  ; 959e
                hex 23 23 23 3f 00 62 2d 2d  ; 95a6
                hex 5e 2d 54 00 00 29 23 23  ; 95ae
                hex 23 23 23 3f 00 00 00 00  ; 95b6
                hex 16 00 19 00 00 29 23 23  ; 95be
                hex 23 23 23 3f 00 00 00 00  ; 95c6
                hex 16 00 19 00 00 29 23 23  ; 95ce
                hex 23 23 23 6d 1b 60 00 00  ; 95d6
                hex 16 00 19 00 00 29 23 23  ; 95de
                hex 23 23 23 3f 00 5d 2d 2d  ; 95e6
                hex 5c 00 19 00 00 29 23 23  ; 95ee
                hex 23 23 23 3f 00 19 00 00  ; 95f6
                hex 00 00 19 00 00 29 23 23  ; 95fe
                hex 23 23 23 6d 1b 58 00 00  ; 9606
                hex 00 00 19 00 00 29 23 23  ; 960e
                hex 23 23 23 3f 00 6e 1b 1b  ; 9616
                hex 6f 00 19 00 00 29 23 23  ; 961e
                hex 23 23 23 3f 00 00 00 00  ; 9626
                hex 16 00 19 00 00 29 23 23  ; 962e
                hex 23 23 23 3f 00 70 2d 2d  ; 9636
                hex 5e 2d 54 00 00 29 23 23  ; 963e
                hex 23 23 23 3f 00 19 00 00  ; 9646
                hex 16 00 19 00 00 29 23 23  ; 964e
                hex 23 23 23 6a 2d 54 00 00  ; 9656
                hex 16 00 5d 2d 2d 6b 23 23  ; 965e
                hex 23 23 23 3f 00 19 00 00  ; 9666
                hex 16 00 19 00 00 29 23 23  ; 966e
                hex 23 23 23 3f 00 57 1b 1b  ; 9676
                hex 1a 1b 58 00 00 29 23 23  ; 967e
                hex 23 23 23 6a 2d 54 00 00  ; 9686
                hex 00 00 5d 2d 2d 6b 23 23  ; 968e
                hex 23 23 23 3f 00 19 00 00  ; 9696
                hex 00 00 19 00 00 29 23 23  ; 969e
                hex 23 23 23 3f 00 19 1b 1b  ; 96a6
                hex 1b 1b 65 1b 1b 49 23 23  ; 96ae
                hex 23 23 23 6a 2d 54 00 00  ; 96b6
                hex 00 00 19 00 00 29 23 23  ; 96be
                hex 23 23 23 3f 00 5d 2d 2d  ; 96c6
                hex 71 00 19 00 00 29 23 23  ; 96ce
                hex 23 23 23 3f 00 19 00 00  ; 96d6
                hex 16 00 19 00 00 29 23 23  ; 96de
                hex 33 33 33 72 1b 61 1b 1b  ; 96e6
                hex 1a 1b 66 00 00 73 33 33  ; 96ee
                hex 00 00 00 00 00 00 00 74  ; 96f6
                hex 11 00 00 00 00 75 04 76  ; 96fe
                hex 00 75 00 00 00 00 00 00  ; 9706
                hex 13 11 00 00 00 77 78 00  ; 970e
                hex 00 77 79 00 00 00 00 00  ; 9716
                hex 00 13 11 00 04 08 13 11  ; 971e
                hex 7a 08 13 11 00 00 00 00  ; 9726
                hex 00 00 13 7a 08 00 00 13  ; 972e
                hex 7b 11 00 13 11 00 00 00  ; 9736
                hex 00 00 04 7b 11 00 00 04  ; 973e
                hex 00 13 11 00 13 11 00 00  ; 9746
                hex 00 04 08 00 13 11 04 08  ; 974e
                hex 00 00 13 11 00 13 11 00  ; 9756
                hex 04 08 00 00 00 77 78 00  ; 975e
                hex 00 00 00 13 11 00 13 7a  ; 9766
                hex 08 00 00 00 04 08 13 11  ; 976e
                hex 11 00 00 00 13 11 04 7b  ; 9776
                hex 11 00 00 04 08 00 00 13  ; 977e
                hex 13 11 00 00 00 7c 7d 00  ; 9786
                hex 13 11 04 08 00 00 00 00  ; 978e
                hex 00 13 11 00 7e 7f 80 81  ; 9796
                hex 00 77 78 00 00 00 00 00  ; 979e
                hex 00 00 13 82 7f 23 23 80  ; 97a6
                hex 83 08 13 11 00 00 00 00  ; 97ae
                hex 00 00 04 84 85 23 23 86  ; 97b6
                hex 87 11 00 13 11 00 00 00  ; 97be
                hex 00 04 08 00 88 85 86 89  ; 97c6
                hex 00 13 11 00 13 11 00 00  ; 97ce
                hex 04 08 00 00 00 8a 8b 00  ; 97d6
                hex 00 00 13 11 00 13 11 00  ; 97de
                hex 08 00 00 00 04 08 13 11  ; 97e6
                hex 00 00 00 13 11 00 13 7a  ; 97ee
                hex 11 00 00 04 08 00 8c 13  ; 97f6
                hex 11 00 00 00 13 11 04 7b  ; 97fe
                hex 13 11 04 08 00 00 00 00  ; 9806
                hex 13 11 00 00 00 77 78 00  ; 980e
                hex 00 7c 7d 00 74 11 04 76  ; 9816
                hex 00 13 11 00 04 08 8d 00  ; 981e
                hex 82 7f 80 81 00 77 8e 00  ; 9826
                hex 00 00 13 7a 08 00 00 74  ; 982e
                hex 84 85 23 80 83 08 00 00  ; 9836
                hex 8f 00 04 7b 11 00 00 04  ; 983e
                hex 00 88 85 86 87 11 00 00  ; 9846
                hex 00 04 08 00 13 11 04 08  ; 984e
                hex 00 00 8a 8b 00 13 11 90  ; 9856
                hex 04 08 00 00 00 77 78 00  ; 985e
                hex 00 91 08 8d 00 00 13 7a  ; 9866
                hex 08 00 00 00 04 08 13 11  ; 986e
                hex 11 00 92 00 74 11 04 7b  ; 9876
                hex 11 00 00 04 08 00 91 7b  ; 987e
                hex 13 7a 08 00 00 7c 7d 00  ; 9886
                hex 13 11 04 08 0d 93 00 00  ; 988e
                hex 00 13 11 00 7e 7f 80 81  ; 9896
                hex 00 77 78 00 94 12 00 95  ; 989e
                hex 00 96 13 82 7f 23 23 80  ; 98a6
                hex 83 08 13 11 00 92 00 00  ; 98ae
                hex 00 00 04 84 85 23 23 23  ; 98b6
                hex 80 81 00 77 7a 08 00 92  ; 98be
                hex 00 04 78 00 88 85 23 23  ; 98c6
                hex 23 80 83 08 13 11 91 08  ; 98ce
                hex 04 08 13 11 04 84 85 23  ; 98d6
                hex 23 23 80 81 00 13 11 00  ; 98de
                hex 08 00 04 7b 08 00 88 85  ; 98e6
                hex 23 23 23 80 81 00 13 7a  ; 98ee
                hex 81 00 13 11 00 97 00 88  ; 98f6
                hex 85 23 23 23 80 81 7e 98  ; 98fe
                hex 80 81 04 7b 7a 7b 11 00  ; 9906
                hex 8a 85 23 23 23 99 9a 23  ; 990e
                hex 23 99 78 00 9b 00 77 7a  ; 9916
                hex 08 88 85 23 86 89 88 85  ; 991e
                hex 9c 89 13 11 00 9d 78 13  ; 9926
                hex 11 00 88 9c 89 00 00 88  ; 992e
                hex 08 00 00 13 11 04 7b 11  ; 9936
                hex 13 11 04 7b 11 00 00 04  ; 993e
                hex 00 74 11 00 13 78 00 13  ; 9946
                hex 11 77 08 00 13 11 04 08  ; 994e
                hex 00 00 13 11 00 13 11 00  ; 9956
                hex 77 08 00 00 00 77 78 00  ; 995e
                hex 00 00 00 13 11 00 13 7a  ; 9966
                hex 08 00 00 00 04 08 13 11  ; 996e
                hex 11 00 00 00 13 11 04 7b  ; 9976
                hex 11 00 00 91 08 00 00 13  ; 997e
                hex 8d 00 00 00 00 9e 08 00  ; 9986
                hex 13 9f 00 00 00 00 00 00  ; 998e
                hex 6f 00 00 4f 1b 1b 1b 1b  ; 9996
                hex 1b 1b 1b 1b 1b 1b 1b 1b  ; 999e
                hex a0 2d a1 16 00 00 00 00  ; 99a6
                hex 00 00 00 00 00 00 00 00  ; 99ae
                hex 16 00 00 16 00 00 00 00  ; 99b6
                hex 00 00 00 00 00 00 00 00  ; 99be
                hex a2 00 00 a3 1b a4 a5 a5  ; 99c6
                hex a5 a5 a6 1b 1b 1b 1b 1b  ; 99ce
                hex a7 00 00 00 00 19 00 00  ; 99d6
                hex 00 00 19 00 00 00 00 00  ; 99de
                hex 4f 1b 1b 1b 1b a8 00 00  ; 99e6
                hex 00 00 19 00 00 00 00 00  ; 99ee
                hex 16 00 00 00 00 a9 2d 2d  ; 99f6
                hex 2d 2d aa ab 2d 2d 2d ac  ; 99fe
                hex 16 00 00 00 00 16 00 00  ; 9a06
                hex 00 00 00 16 00 00 00 19  ; 9a0e
                hex a3 1b 1b 1b 1b a2 00 00  ; 9a16
                hex 00 00 00 16 00 00 00 19  ; 9a1e
                hex 00 00 00 00 00 6c 2d 2d  ; 9a26
                hex 2d 2d a1 6c 2d 2d 2d aa  ; 9a2e
                hex 00 00 ad 00 00 00 00 ae  ; 9a36
                hex 00 00 00 00 ad 00 00 00  ; 9a3e
                hex ae 00 00 00 ae 00 00 00  ; 9a46
                hex af 00 00 ae 00 00 00 00  ; 9a4e
                hex 00 00 00 ae 00 00 00 ad  ; 9a56
                hex 00 00 00 00 00 ad 00 00  ; 9a5e
                hex 00 ae 00 00 00 ae b0 00  ; 9a66
                hex 00 00 ad 00 00 00 00 00  ; 9a6e
                hex 00 00 ad 00 00 00 00 00  ; 9a76
                hex b0 00 ae 00 af 00 00 ae  ; 9a7e
                hex af 00 00 00 00 00 00 00  ; 9a86
                hex 00 00 00 00 00 00 00 00  ; 9a8e
                hex 1b 1b 50 1b 1b 1b b1 06  ; 9a96
                hex 0d b2 1b 1b 1b 4d 1b 1b  ; 9a9e
                hex 00 00 16 00 00 00 09 0a  ; 9aa6
                hex 0f 12 00 00 00 19 00 00  ; 9aae
                hex 00 00 16 00 00 00 0d 0f  ; 9ab6
                hex 0a 06 00 00 00 19 00 00  ; 9abe
                hex 2d 2d 53 2d 2d 2d b3 12  ; 9ac6
                hex 09 b4 2d 2d 2d 63 2d 2d  ; 9ace
                hex 00 b5 b6 93 00 00 00 00  ; 9ad6
                hex 00 00 00 00 b5 b6 93 00  ; 9ade
                hex 00 b7 b8 b9 00 ae 00 af  ; 9ae6
                hex 00 75 92 00 b7 b8 b9 00  ; 9aee
                hex 75 ba bb bc 00 00 00 00  ; 9af6
                hex 00 77 78 ad bd bb bc 00  ; 9afe
                hex 77 78 00 00 be 00 b0 00  ; 9b06
                hex ae bf 8d 00 00 21 1b 4e  ; 9b0e
                hex bf 8d 00 af 00 00 00 00  ; 9b16
                hex 00 00 00 00 00 00 b0 00  ; 9b1e

cod47           hex 76                       ; 9b26
dat28           hex 90 96 91 86 92 56 93     ; 9b27
                hex a6 94 f6 96 96 99 26 9b  ; 9b2e (unaccessed)

sub23           lda ram25                    ; 9b36: a5 34
                beq sub24                    ; 9b38: f0 4f
                lda ptr4+0                   ; 9b3a: a5 30
                pha                          ; 9b3c: 48
                lda ptr4+1                   ; 9b3d: a5 31
                pha                          ; 9b3f: 48
                lda #$66                     ; 9b40: a9 66
                sta ptr4+0                   ; 9b42: 85 30
                lda #$90                     ; 9b44: a9 90
                sta ptr4+1                   ; 9b46: 85 31
                jsr sub24                    ; 9b48: 20 89 9b
                dec ram25                    ; 9b4b: c6 34
                bne +                        ; 9b4d: d0 33
                lda ram28                    ; 9b4f: a5 37
                beq +                        ; 9b51: f0 2f
                inc ram27                    ; 9b53: e6 36
                lda #0                       ; 9b55: a9 00
                sta ram28                    ; 9b57: 85 37
                sta ram29                    ; 9b59: 85 38
                jsr sub34                    ; 9b5b: 20 08 9d
                ldy ram27                    ; 9b5e: a4 36
                lda dat26,y                  ; 9b60: b9 58 90
                sta ram7                     ; 9b63: 85 1a
                sta ram8                     ; 9b65: 85 1b
                lda arr23                    ; 9b67: a5 1f
                sec                          ; 9b69: 38
                sbc dat27,y                  ; 9b6a: f9 5f 90
                sta ram9                     ; 9b6d: 85 1c
                cpy #7                       ; 9b6f: c0 07
                bne +                        ; 9b71: d0 0f

                lda #1                       ; 9b73: a9 01    (unaccessed)
                sta arr20                    ; 9b75: 85 19    (unaccessed)
                lda #4                       ; 9b77: a9 04    (unaccessed)
                sta arr17                    ; 9b79: 85 16    (unaccessed)
                lda #0                       ; 9b7b: a9 00    (unaccessed)
                sta arr19                    ; 9b7d: 85 18    (unaccessed)
                jsr sub38                    ; 9b7f: 20 d1 9d (unaccessed)

+               pla                          ; 9b82: 68
                sta ptr4+1                   ; 9b83: 85 31
                pla                          ; 9b85: 68
                sta ptr4+0                   ; 9b86: 85 30
                rts                          ; 9b88: 60
sub24           inc ram23                    ; 9b89: e6 32
                bne sub25                    ; 9b8b: d0 02
                inc ram24                    ; 9b8d: e6 33
sub25           ldy #0                       ; 9b8f: a0 00
                jsr sub32                    ; 9b91: 20 c0 9c
                lda arr27                    ; 9b94: a5 27
                sta ram14                    ; 9b96: 85 29
                lda arr28                    ; 9b98: a5 28
                sta ram15                    ; 9b9a: 85 2a
                lda #0                       ; 9b9c: a9 00
                sta ptr1+0                   ; 9b9e: 85 00
-               ldy #0                       ; 9ba0: a0 00
                lda (ptr4),y                 ; 9ba2: b1 30
                inc ptr4+0                   ; 9ba4: e6 30
                bne +                        ; 9ba6: d0 02
                inc ptr4+1                   ; 9ba8: e6 31
+               tax                          ; 9baa: aa
                ldy ptr1+0                   ; 9bab: a4 00
                lda dat17,x                  ; 9bad: bd 3c 8d
                sta arr66,y                  ; 9bb0: 99 50 01
                lda dat18,x                  ; 9bb3: bd fc 8d
                sta arr67,y                  ; 9bb6: 99 51 01
                lda dat20,x                  ; 9bb9: bd bc 8e
                sta arr68,y                  ; 9bbc: 99 70 01
                lda dat21,x                  ; 9bbf: bd 7c 8f
                sta arr69,y                  ; 9bc2: 99 71 01
                iny                          ; 9bc5: c8
                iny                          ; 9bc6: c8
                sty ptr1+0                   ; 9bc7: 84 00
                cpy #$20                     ; 9bc9: c0 20
                bne -                        ; 9bcb: d0 d3
                lda #1                       ; 9bcd: a9 01
                sta arr25                    ; 9bcf: 85 24
                sec                          ; 9bd1: 38
                rts                          ; 9bd2: 60
sub26           lda #0                       ; 9bd3: a9 00
                sta arr21                    ; 9bd5: 85 1d
                sta arr22                    ; 9bd7: 85 1e
                sta ram7                     ; 9bd9: 85 1a
                sta ram8                     ; 9bdb: 85 1b
                jsr sub5                     ; 9bdd: 20 3b 82
                lda #8                       ; 9be0: a9 08
                jsr sub2                     ; 9be2: 20 f6 80
                rts                          ; 9be5: 60
sub27           jsr sub39                    ; 9be6: 20 0e 9e
                ldy ram27                    ; 9be9: a4 36
                lda dat26,y                  ; 9beb: b9 58 90
                sta ram7                     ; 9bee: 85 1a
                sta ram8                     ; 9bf0: 85 1b
                lda dat27,y                  ; 9bf2: b9 5f 90
                sta ram9                     ; 9bf5: 85 1c
                lda #0                       ; 9bf7: a9 00
                sta arr21                    ; 9bf9: 85 1d
                sta arr22                    ; 9bfb: 85 1e
                sta arr23                    ; 9bfd: 85 1f
                sta ram38                    ; 9bff: 85 45
                sta arr29                    ; 9c01: 85 3c
                sta ram36                    ; 9c03: 85 43
                sta arr30                    ; 9c05: 85 3f
                sta arr31                    ; 9c07: 85 40
                sta ram34                    ; 9c09: 85 41
                sta ram35                    ; 9c0b: 85 42
                lda ram27                    ; 9c0d: a5 36
                asl a                        ; 9c0f: 0a
                tay                          ; 9c10: a8
                lda cod47,y                  ; 9c11: b9 26 9b
                sta ptr4+0                   ; 9c14: 85 30
                lda dat28,y                  ; 9c16: b9 27 9b
                sta ptr4+1                   ; 9c19: 85 31
                lda #$ff                     ; 9c1b: a9 ff
                sta ram23                    ; 9c1d: 85 32
                sta ram24                    ; 9c1f: 85 33
                jsr sub28                    ; 9c21: 20 49 9c
                lda #$0a                     ; 9c24: a9 0a
                sta arr12                    ; 9c26: 85 0f
                jsr sub29                    ; 9c28: 20 5b 9c
                lda #5                       ; 9c2b: a9 05
                sta arr12                    ; 9c2d: 85 0f
                jsr sub30                    ; 9c2f: 20 7a 9c
                lda #$6a                     ; 9c32: a9 6a
                sta arr33                    ; 9c34: 85 51
                lda #$80                     ; 9c36: a9 80
                sta ram48                    ; 9c38: 85 52
                lda #$bf                     ; 9c3a: a9 bf
                sta ram49                    ; 9c3c: 85 53
                lda #$80                     ; 9c3e: a9 80
                sta ram50                    ; 9c40: 85 54
                jsr sub11                    ; 9c42: 20 d2 87
                jsr sub13                    ; 9c45: 20 4f 88
                rts                          ; 9c48: 60
sub28           lda #0                       ; 9c49: a9 00
                sta arr25                    ; 9c4b: 85 24
                lda #$23                     ; 9c4d: a9 23
                sta arr27                    ; 9c4f: 85 27
                lda #$c0                     ; 9c51: a9 c0
                sta arr28                    ; 9c53: 85 28
                lda ram6                     ; 9c55: a5 11
                sta ppu_ctrl                 ; 9c57: 8d 00 20
                rts                          ; 9c5a: 60
sub29           lda ptr4+0                   ; 9c5b: a5 30
                pha                          ; 9c5d: 48
                lda ptr4+1                   ; 9c5e: a5 31
                pha                          ; 9c60: 48
-               lda #$66                     ; 9c61: a9 66
                sta ptr4+0                   ; 9c63: 85 30
                lda #$90                     ; 9c65: a9 90
                sta ptr4+1                   ; 9c67: 85 31
                jsr sub25                    ; 9c69: 20 8f 9b
                jsr sub4                     ; 9c6c: 20 09 82
                dec arr12                    ; 9c6f: c6 0f
                bne -                        ; 9c71: d0 ee
                pla                          ; 9c73: 68
                sta ptr4+1                   ; 9c74: 85 31
                pla                          ; 9c76: 68
                sta ptr4+0                   ; 9c77: 85 30
                rts                          ; 9c79: 60
sub30           jsr sub25                    ; 9c7a: 20 8f 9b
                jsr sub4                     ; 9c7d: 20 09 82
                dec arr12                    ; 9c80: c6 0f
                bne sub30                    ; 9c82: d0 f6
                rts                          ; 9c84: 60

-               jsr sub24                    ; 9c85: 20 89 9b (unaccessed)
                jsr sub4                     ; 9c88: 20 09 82 (unaccessed)
                dec arr12                    ; 9c8b: c6 0f    (unaccessed)
                bne -                        ; 9c8d: d0 f6    (unaccessed)
                rts                          ; 9c8f: 60       (unaccessed)

sub31           lda arr23                    ; 9c90: a5 1f
                sec                          ; 9c92: 38
                sbc ram35                    ; 9c93: e5 42
                sta arr23                    ; 9c95: 85 1f
                lda arr21                    ; 9c97: a5 1d
                sbc ram34                    ; 9c99: e5 41
                sta arr22                    ; 9c9b: 85 1e
                bcs +                        ; 9c9d: b0 0a
                sbc #$0f                     ; 9c9f: e9 0f
                sta arr22                    ; 9ca1: 85 1e
                lda ram6                     ; 9ca3: a5 11
                eor #%00000010               ; 9ca5: 49 02
                sta arr13                    ; 9ca7: 85 12
+               rts                          ; 9ca9: 60

                lda arr21                    ; 9caa: a5 1d    (unaccessed)
                clc                          ; 9cac: 18       (unaccessed)
                adc ram34                    ; 9cad: 65 41    (unaccessed)
                sta arr22                    ; 9caf: 85 1e    (unaccessed)
                cmp #$f0                     ; 9cb1: c9 f0    (unaccessed)
                bcc +                        ; 9cb3: 90 0a    (unaccessed)
                adc #$0f                     ; 9cb5: 69 0f    (unaccessed)
                sta arr22                    ; 9cb7: 85 1e    (unaccessed)
                lda ram6                     ; 9cb9: a5 11    (unaccessed)
                eor #%00000010               ; 9cbb: 49 02    (unaccessed)
                sta arr13                    ; 9cbd: 85 12    (unaccessed)
+               rts                          ; 9cbf: 60       (unaccessed)

sub32           lda arr28,y                  ; 9cc0: b9 28 00
                sec                          ; 9cc3: 38
                sbc #$40                     ; 9cc4: e9 40
                sta arr28,y                  ; 9cc6: 99 28 00
                lda arr27,y                  ; 9cc9: b9 27 00
                sbc #0                       ; 9ccc: e9 00
                ora #%00100000               ; 9cce: 09 20
                and #%00101011               ; 9cd0: 29 2b
                sta arr27,y                  ; 9cd2: 99 27 00
                and #%00000011               ; 9cd5: 29 03
                cmp #3                       ; 9cd7: c9 03
                bcc +                        ; 9cd9: 90 0c
                lda arr28,y                  ; 9cdb: b9 28 00
                cmp #$c0                     ; 9cde: c9 c0
                bcc +                        ; 9ce0: 90 05
                lda #$80                     ; 9ce2: a9 80
                sta arr28,y                  ; 9ce4: 99 28 00
+               rts                          ; 9ce7: 60
sub33           lda arr13                    ; 9ce8: a5 12
                sta ram4                     ; 9cea: 85 0e
                jsr sub31                    ; 9cec: 20 90 9c
                lda ram9                     ; 9cef: a5 1c
                clc                          ; 9cf1: 18
                adc arr31                    ; 9cf2: 65 40
                sta ram9                     ; 9cf4: 85 1c
                lda ram8                     ; 9cf6: a5 1b
                adc arr30                    ; 9cf8: 65 3f
                sta ram8                     ; 9cfa: 85 1b
                lda arr22                    ; 9cfc: a5 1e
                eor arr21                    ; 9cfe: 45 1d
                cmp #$10                     ; 9d00: c9 10
                bcc +                        ; 9d02: 90 03
                jsr sub23                    ; 9d04: 20 36 9b
+               rts                          ; 9d07: 60
sub34           lda ram150                   ; 9d08: ad 04 04
                clc                          ; 9d0b: 18
                adc #5                       ; 9d0c: 69 05
                cmp #$0d                     ; 9d0e: c9 0d
                bcc +                        ; 9d10: 90 02
                sbc #$0c                     ; 9d12: e9 0c    (unaccessed)
+               sta ram150                   ; 9d14: 8d 04 04
                ora #%00010000               ; 9d17: 09 10
                sta ram151                   ; 9d19: 8d 05 04
                eor #%00110000               ; 9d1c: 49 30
                sta ram152                   ; 9d1e: 8d 06 04
                lda #6                       ; 9d21: a9 06
                sta ram17                    ; 9d23: 85 2c
                rts                          ; 9d25: 60
sub35           lda #$ff                     ; 9d26: a9 ff
                sta ram73                    ; 9d28: 85 70
                sta ram74                    ; 9d2a: 85 71
                jsr sub38                    ; 9d2c: 20 d1 9d
                ldx #8                       ; 9d2f: a2 08
                ldy #$ad                     ; 9d31: a0 ad
                jsr sub41                    ; 9d33: 20 0f b1
                rts                          ; 9d36: 60
sub36           lda ram57                    ; 9d37: a5 5d
                ror a                        ; 9d39: 6a
                bcc +                        ; 9d3a: 90 06
                jsr sub48                    ; 9d3c: 20 60 b4
                jmp cod48                    ; 9d3f: 4c 4e 9d
+               lda #$30                     ; 9d42: a9 30
                sta arr35                    ; 9d44: 85 60
                sta ram62                    ; 9d46: 85 64
                sta ram69                    ; 9d48: 85 6c
                lda #0                       ; 9d4a: a9 00
                sta ram65                    ; 9d4c: 85 68
cod48           ldx #0                       ; 9d4e: a2 00
                jsr sub43                    ; 9d50: 20 68 b1
                ldx #$0f                     ; 9d53: a2 0f
                jsr sub43                    ; 9d55: 20 68 b1
                ldx #$1e                     ; 9d58: a2 1e
                jsr sub43                    ; 9d5a: 20 68 b1
                ldx #$2d                     ; 9d5d: a2 2d
                jsr sub43                    ; 9d5f: 20 68 b1
                lda arr35                    ; 9d62: a5 60
                sta sq1_vol                  ; 9d64: 8d 00 40
                lda ram59                    ; 9d67: a5 61
                sta sq1_sweep                ; 9d69: 8d 01 40
                lda ram60                    ; 9d6c: a5 62
                sta sq1_lo                   ; 9d6e: 8d 02 40
                lda ram61                    ; 9d71: a5 63
                cmp ram73                    ; 9d73: c5 70
                beq +                        ; 9d75: f0 05
                sta ram73                    ; 9d77: 85 70
                sta sq1_hi                   ; 9d79: 8d 03 40
+               lda ram62                    ; 9d7c: a5 64
                sta sq2_vol                  ; 9d7e: 8d 04 40
                lda ram63                    ; 9d81: a5 65
                sta sq2_sweep                ; 9d83: 8d 05 40
                lda ram64                    ; 9d86: a5 66
                sta sq2_lo                   ; 9d88: 8d 06 40
                lda arr36                    ; 9d8b: a5 67
                cmp ram74                    ; 9d8d: c5 71
                beq +                        ; 9d8f: f0 05
                sta ram74                    ; 9d91: 85 71
                sta sq2_hi                   ; 9d93: 8d 07 40
+               lda ram65                    ; 9d96: a5 68
                sta tri_linear               ; 9d98: 8d 08 40
                lda ram66                    ; 9d9b: a5 69
                sta misc1                    ; 9d9d: 8d 09 40
                lda ram67                    ; 9da0: a5 6a
                sta tri_lo                   ; 9da2: 8d 0a 40
                lda ram68                    ; 9da5: a5 6b
                sta tri_hi                   ; 9da7: 8d 0b 40
                lda ram69                    ; 9daa: a5 6c
                sta noise_vol                ; 9dac: 8d 0c 40
                lda ram70                    ; 9daf: a5 6d
                sta misc2                    ; 9db1: 8d 0d 40
                lda ram71                    ; 9db4: a5 6e
                sta noise_lo                 ; 9db6: 8d 0e 40
                lda ram72                    ; 9db9: a5 6f
                sta noise_hi                 ; 9dbb: 8d 0f 40
                rts                          ; 9dbe: 60
sub37           ldx #$30                     ; 9dbf: a2 30
                stx ram58                    ; 9dc1: 86 5e
                ldx #$9e                     ; 9dc3: a2 9e
                stx arr34                    ; 9dc5: 86 5f
                ldx ram5                     ; 9dc7: a6 10
                jsr sub44                    ; 9dc9: 20 0a b2
                lda #1                       ; 9dcc: a9 01
                sta ram57                    ; 9dce: 85 5d
                rts                          ; 9dd0: 60
sub38           ldx #$e5                     ; 9dd1: a2 e5
                stx ram58                    ; 9dd3: 86 5e
                ldx #$9d                     ; 9dd5: a2 9d
                stx arr34                    ; 9dd7: 86 5f
                lda #0                       ; 9dd9: a9 00
                ldx ram5                     ; 9ddb: a6 10
                jsr sub44                    ; 9ddd: 20 0a b2
                lda #0                       ; 9de0: a9 00
                sta ram57                    ; 9de2: 85 5d
                rts                          ; 9de4: 60

                hex 0d 00 0d 00 0d 00 0d 00  ; 9de5
                hex 00 10 0e                 ; 9ded
                hex b8 0b                    ; 9df0 (unaccessed)
                hex 0f 00 16 00 01 40 06 96  ; 9df2
                hex 00 18 00 22 00 22 00 22  ; 9dfa
                hex 00 22 00 22 00           ; 9e02
                hex 00 3f                    ; 9e07 (unaccessed)

                lda #0                       ; 9e09: a9 00    (unaccessed)
                sta ram57                    ; 9e0b: 85 5d    (unaccessed)
                rts                          ; 9e0d: 60       (unaccessed)

sub39           lda #1                       ; 9e0e: a9 01
                sta ram57                    ; 9e10: 85 5d
                rts                          ; 9e12: 60
                lda ram57                    ; 9e13: a5 5d    (unaccessed)
                eor #%00000001               ; 9e15: 49 01    (unaccessed)
                sta ram57                    ; 9e17: 85 5d    (unaccessed)
                rts                          ; 9e19: 60       (unaccessed)
sub40           pha                          ; 9e1a: 48
                ldx ram77                    ; 9e1b: a6 74
                inx                          ; 9e1d: e8
                txa                          ; 9e1e: 8a
                and #%00000011               ; 9e1f: 29 03
                sta ram77                    ; 9e21: 85 74
                tax                          ; 9e23: aa
                lda dat29,x                  ; 9e24: bd 2c 9e
                tax                          ; 9e27: aa
                pla                          ; 9e28: 68
                jmp cod53                    ; 9e29: 4c 4d b1

dat29           hex 00 0f 1e 2d 3e 01 f3 00  ; 9e2c
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

sub41           stx ptr6+0                   ; b10f: 86 72
                sty ptr6+1                   ; b111: 84 73
                ldy #0                       ; b113: a0 00
                lda ram5                     ; b115: a5 10
                asl a                        ; b117: 0a
                tay                          ; b118: a8
                lda (ptr6),y                 ; b119: b1 72
                sta ram148                   ; b11b: 8d 01 03
                iny                          ; b11e: c8
                lda (ptr6),y                 ; b11f: b1 72
                sta ram149                   ; b121: 8d 02 03
                ldx #0                       ; b124: a2 00
-               jsr sub42                    ; b126: 20 33 b1
                txa                          ; b129: 8a
                clc                          ; b12a: 18
                adc #$0f                     ; b12b: 69 0f
                tax                          ; b12d: aa
                cpx #$3c                     ; b12e: e0 3c
                bne -                        ; b130: d0 f4
                rts                          ; b132: 60
sub42           lda #0                       ; b133: a9 00
                sta arr80,x                  ; b135: 9d 05 03
                sta arr78,x                  ; b138: 9d 03 03
                sta arr81,x                  ; b13b: 9d 06 03
                sta arr88,x                  ; b13e: 9d 0d 03
                lda #$30                     ; b141: a9 30
                sta arr82,x                  ; b143: 9d 07 03
                sta arr85,x                  ; b146: 9d 0a 03
                sta arr91,x                  ; b149: 9d 10 03
                rts                          ; b14c: 60
cod53           asl a                        ; b14d: 0a
                tay                          ; b14e: a8
                jsr sub42                    ; b14f: 20 33 b1
                lda ram148                   ; b152: ad 01 03
                sta ptr6+0                   ; b155: 85 72
                lda ram149                   ; b157: ad 02 03
                sta ptr6+1                   ; b15a: 85 73
                lda (ptr6),y                 ; b15c: b1 72
                sta arr79,x                  ; b15e: 9d 04 03
                iny                          ; b161: c8
                lda (ptr6),y                 ; b162: b1 72
                sta arr80,x                  ; b164: 9d 05 03
                rts                          ; b167: 60
sub43           lda arr78,x                  ; b168: bd 03 03
                beq +                        ; b16b: f0 05
                dec arr78,x                  ; b16d: de 03 03
                bne cod55                    ; b170: d0 38
+               lda arr80,x                  ; b172: bd 05 03
                bne +                        ; b175: d0 01
                rts                          ; b177: 60
+               sta ptr5+1                   ; b178: 85 5b
                lda arr79,x                  ; b17a: bd 04 03
                sta ptr5+0                   ; b17d: 85 5a
                ldy arr81,x                  ; b17f: bc 06 03
                clc                          ; b182: 18
-               lda (ptr5),y                 ; b183: b1 5a
                bmi +                        ; b185: 30 0d
                beq cod54                    ; b187: f0 1e
                iny                          ; b189: c8
                sta arr78,x                  ; b18a: 9d 03 03
                tya                          ; b18d: 98
                sta arr81,x                  ; b18e: 9d 06 03
                jmp cod55                    ; b191: 4c aa b1
+               iny                          ; b194: c8
                stx ram56                    ; b195: 86 5c
                adc ram56                    ; b197: 65 5c
                and #%01111111               ; b199: 29 7f
                tax                          ; b19b: aa
                lda (ptr5),y                 ; b19c: b1 5a
                iny                          ; b19e: c8
                sta arr82,x                  ; b19f: 9d 07 03
                ldx ram56                    ; b1a2: a6 5c
                jmp -                        ; b1a4: 4c 83 b1
cod54           sta arr80,x                  ; b1a7: 9d 05 03
cod55           lda arr35                    ; b1aa: a5 60
                and #%00001111               ; b1ac: 29 0f
                sta ram56                    ; b1ae: 85 5c
                lda arr82,x                  ; b1b0: bd 07 03
                and #%00001111               ; b1b3: 29 0f
                cmp ram56                    ; b1b5: c5 5c
                bcc +                        ; b1b7: 90 0f
                lda arr82,x                  ; b1b9: bd 07 03
                sta arr35                    ; b1bc: 85 60
                lda arr83,x                  ; b1be: bd 08 03
                sta ram60                    ; b1c1: 85 62
                lda arr84,x                  ; b1c3: bd 09 03
                sta ram61                    ; b1c6: 85 63
+               lda arr85,x                  ; b1c8: bd 0a 03
                beq +                        ; b1cb: f0 0c
                sta ram62                    ; b1cd: 85 64
                lda arr86,x                  ; b1cf: bd 0b 03
                sta ram64                    ; b1d2: 85 66
                lda arr87,x                  ; b1d4: bd 0c 03
                sta arr36                    ; b1d7: 85 67
+               lda arr88,x                  ; b1d9: bd 0d 03
                beq +                        ; b1dc: f0 0c

                sta ram65                    ; b1de: 85 68    (unaccessed)
                lda arr89,x                  ; b1e0: bd 0e 03 (unaccessed)
                sta ram67                    ; b1e3: 85 6a    (unaccessed)
                lda arr90,x                  ; b1e5: bd 0f 03 (unaccessed)
                sta ram68                    ; b1e8: 85 6b    (unaccessed)

+               lda ram69                    ; b1ea: a5 6c
                and #%00001111               ; b1ec: 29 0f
                sta ram56                    ; b1ee: 85 5c
                lda arr91,x                  ; b1f0: bd 10 03
                and #%00001111               ; b1f3: 29 0f
                cmp ram56                    ; b1f5: c5 5c
                bcc +                        ; b1f7: 90 0a
                lda arr91,x                  ; b1f9: bd 10 03
                sta ram69                    ; b1fc: 85 6c
                lda arr92,x                  ; b1fe: bd 11 03
                sta ram71                    ; b201: 85 6e
+               rts                          ; b203: 60

                jmp sub44                    ; b204: 4c 0a b2 (unaccessed)
                jmp sub48                    ; b207: 4c 60 b4 (unaccessed)

sub44           asl a                        ; b20a: 0a
                jsr sub45                    ; b20b: 20 6c b2
                lda #0                       ; b20e: a9 00
                tax                          ; b210: aa
-               sta arr35,x                  ; b211: 95 60
                inx                          ; b213: e8
                cpx #$10                     ; b214: e0 10
                bne -                        ; b216: d0 f9
                lda #$30                     ; b218: a9 30
                sta ram69                    ; b21a: 85 6c
                lda #$0f                     ; b21c: a9 0f
                sta snd_chn                  ; b21e: 8d 15 40
                lda #8                       ; b221: a9 08
                sta ram59                    ; b223: 85 61
                sta ram63                    ; b225: 85 65
                lda #$c0                     ; b227: a9 c0
                sta joypad2                  ; b229: 8d 17 40
                lda #$40                     ; b22c: a9 40
                sta joypad2                  ; b22e: 8d 17 40
                lda #$ff                     ; b231: a9 ff
                sta ram159                   ; b233: 8d ef 04
                lda #0                       ; b236: a9 00
                tax                          ; b238: aa
-               sta arr122,x                 ; b239: 9d 21 05
                sta arr152,x                 ; b23c: 9d 99 05
                sta arr153,x                 ; b23f: 9d 9d 05
                sta arr155,x                 ; b242: 9d a5 05
                sta arr154,x                 ; b245: 9d a1 05
                sta arr128,x                 ; b248: 9d 3e 05
                sta arr127,x                 ; b24b: 9d 3a 05
                inx                          ; b24e: e8
                cpx #4                       ; b24f: e0 04
                bne -                        ; b251: d0 e6
                lda ram158                   ; b253: ad ee 04
                and #%00000010               ; b256: 29 02
                beq +                        ; b258: f0 0e

                lda #$30                     ; b25a: a9 30    (unaccessed)
                ldx #0                       ; b25c: a2 00    (unaccessed)
-               sta arr157,x                 ; b25e: 9d ad 05 (unaccessed)
                inx                          ; b261: e8       (unaccessed)
                cpx #4                       ; b262: e0 04    (unaccessed)
                bne -                        ; b264: d0 f8    (unaccessed)
                lda #0                       ; b266: a9 00    (unaccessed)

+               sta ram186                   ; b268: 8d 25 05
                rts                          ; b26b: 60
sub45           pha                          ; b26c: 48
                lda ram58                    ; b26d: a5 5e
                sta ptr8+0                   ; b26f: 85 7b
                lda arr34                    ; b271: a5 5f
                sta ptr8+1                   ; b273: 85 7c
                ldy #0                       ; b275: a0 00
-               clc                          ; b277: 18
                lda (ptr8),y                 ; b278: b1 7b
                adc ram58                    ; b27a: 65 5e
                sta arr114,y                 ; b27c: 99 ea 04
                iny                          ; b27f: c8
                lda (ptr8),y                 ; b280: b1 7b
                adc arr34                    ; b282: 65 5f
                sta arr114,y                 ; b284: 99 ea 04
                iny                          ; b287: c8
                cpy #8                       ; b288: c0 08
                bne -                        ; b28a: d0 eb
                lda (ptr8),y                 ; b28c: b1 7b
                sta ram158                   ; b28e: 8d ee 04
                iny                          ; b291: c8
                cpx #1                       ; b292: e0 01
                beq +                        ; b294: f0 1b
                cpx #2                       ; b296: e0 02
                beq cod56                    ; b298: f0 30
                lda (ptr8),y                 ; b29a: b1 7b
                iny                          ; b29c: c8
                sta ram173                   ; b29d: 8d ff 04
                lda (ptr8),y                 ; b2a0: b1 7b
                iny                          ; b2a2: c8
                sta arr116                   ; b2a3: 8d 00 05
                lda #$a9                     ; b2a6: a9 a9
                sta ptr10+0                  ; b2a8: 85 81
                lda #$c3                     ; b2aa: a9 c3
                sta ptr10+1                  ; b2ac: 85 82
                jmp cod57                    ; b2ae: 4c e0 b2

+               iny                          ; b2b1: c8       (unaccessed)
                iny                          ; b2b2: c8       (unaccessed)
                lda (ptr8),y                 ; b2b3: b1 7b    (unaccessed)
                iny                          ; b2b5: c8       (unaccessed)
                sta ram173                   ; b2b6: 8d ff 04 (unaccessed)
                lda (ptr8),y                 ; b2b9: b1 7b    (unaccessed)
                iny                          ; b2bb: c8       (unaccessed)
                sta arr116                   ; b2bc: 8d 00 05 (unaccessed)
                lda #$69                     ; b2bf: a9 69    (unaccessed)
                sta ptr10+0                  ; b2c1: 85 81    (unaccessed)
                lda #$c4                     ; b2c3: a9 c4    (unaccessed)
                sta ptr10+1                  ; b2c5: 85 82    (unaccessed)
                jmp cod57                    ; b2c7: 4c e0 b2 (unaccessed)
cod56           iny                          ; b2ca: c8       (unaccessed)
                iny                          ; b2cb: c8       (unaccessed)
                lda (ptr8),y                 ; b2cc: b1 7b    (unaccessed)
                iny                          ; b2ce: c8       (unaccessed)
                sta ram173                   ; b2cf: 8d ff 04 (unaccessed)
                lda (ptr8),y                 ; b2d2: b1 7b    (unaccessed)
                iny                          ; b2d4: c8       (unaccessed)
                sta arr116                   ; b2d5: 8d 00 05 (unaccessed)
                lda #$a9                     ; b2d8: a9 a9    (unaccessed)
                sta ptr10+0                  ; b2da: 85 81    (unaccessed)
                lda #$c3                     ; b2dc: a9 c3    (unaccessed)
                sta ptr10+1                  ; b2de: 85 82    (unaccessed)

cod57           pla                          ; b2e0: 68
                tay                          ; b2e1: a8
                jsr sub46                    ; b2e2: 20 26 b3
                ldx #1                       ; b2e5: a2 01
                stx ram165                   ; b2e7: 8e f7 04
                dex                          ; b2ea: ca
-               lda #$7f                     ; b2eb: a9 7f
                sta arr120,x                 ; b2ed: 9d 17 05
                lda #$80                     ; b2f0: a9 80
                sta arr124,x                 ; b2f2: 9d 2b 05
                lda #0                       ; b2f5: a9 00
                sta arr159,x                 ; b2f7: 9d b5 05
                sta arr162,x                 ; b2fa: 9d c1 05
                sta arr152,x                 ; b2fd: 9d 99 05
                sta arr131,x                 ; b300: 9d 4a 05
                sta arr125,x                 ; b303: 9d 30 05
                sta arr156,x                 ; b306: 9d a9 05
                sta arr119,x                 ; b309: 9d 12 05
                inx                          ; b30c: e8
                cpx #4                       ; b30d: e0 04
                bne -                        ; b30f: d0 da
                ldx #$ff                     ; b311: a2 ff
                inx                          ; b313: e8
                stx ram167                   ; b314: 8e f9 04
                jsr sub47                    ; b317: 20 5f b3
                jsr sub54                    ; b31a: 20 c8 b8
                lda #0                       ; b31d: a9 00
                sta ram169                   ; b31f: 8d fb 04
                sta ram170                   ; b322: 8d fc 04
                rts                          ; b325: 60
sub46           lda arr114                   ; b326: ad ea 04
                sta ptr7+0                   ; b329: 85 79
                lda ram155                   ; b32b: ad eb 04
                sta ptr7+1                   ; b32e: 85 7a
                clc                          ; b330: 18
                lda (ptr7),y                 ; b331: b1 79
                adc ram58                    ; b333: 65 5e
                sta ptr8+0                   ; b335: 85 7b
                iny                          ; b337: c8
                lda (ptr7),y                 ; b338: b1 79
                adc arr34                    ; b33a: 65 5f
                sta ptr8+1                   ; b33c: 85 7c
                lda #0                       ; b33e: a9 00
                tax                          ; b340: aa
                tay                          ; b341: a8
                clc                          ; b342: 18
                lda (ptr8),y                 ; b343: b1 7b
                adc ram58                    ; b345: 65 5e
                sta ram160                   ; b347: 8d f0 04
                iny                          ; b34a: c8
                lda (ptr8),y                 ; b34b: b1 7b
                adc arr34                    ; b34d: 65 5f
                sta ram161                   ; b34f: 8d f1 04
                iny                          ; b352: c8
-               lda (ptr8),y                 ; b353: b1 7b
                sta arr115,x                 ; b355: 9d f2 04
                iny                          ; b358: c8
                inx                          ; b359: e8
                cpx #6                       ; b35a: e0 06
                bne -                        ; b35c: d0 f5
                rts                          ; b35e: 60
sub47           asl a                        ; b35f: 0a
                clc                          ; b360: 18
                adc ram160                   ; b361: 6d f0 04
                sta ptr7+0                   ; b364: 85 79
                lda #0                       ; b366: a9 00
                tay                          ; b368: a8
                tax                          ; b369: aa
                adc ram161                   ; b36a: 6d f1 04
                sta ptr7+1                   ; b36d: 85 7a
                clc                          ; b36f: 18
                lda (ptr7),y                 ; b370: b1 79
                adc ram58                    ; b372: 65 5e
                sta ptr8+0                   ; b374: 85 7b
                iny                          ; b376: c8
                lda (ptr7),y                 ; b377: b1 79
                adc arr34                    ; b379: 65 5f
                sta ptr8+1                   ; b37b: 85 7c
                ldy #0                       ; b37d: a0 00
                stx ram166                   ; b37f: 8e f8 04
-               clc                          ; b382: 18
                lda (ptr8),y                 ; b383: b1 7b
                adc ram58                    ; b385: 65 5e
                sta arr117,x                 ; b387: 9d 08 05
                iny                          ; b38a: c8
                lda (ptr8),y                 ; b38b: b1 7b
                adc arr34                    ; b38d: 65 5f
                sta arr118,x                 ; b38f: 9d 0d 05
                iny                          ; b392: c8
                lda #0                       ; b393: a9 00
                sta arr125,x                 ; b395: 9d 30 05
                sta arr121,x                 ; b398: 9d 1c 05
                lda #$ff                     ; b39b: a9 ff
                sta arr126,x                 ; b39d: 9d 35 05
                inx                          ; b3a0: e8
                cpx #5                       ; b3a1: e0 05
                bne -                        ; b3a3: d0 dd
                lda #0                       ; b3a5: a9 00
                sta ram176                   ; b3a7: 8d 03 05
                sta ram177                   ; b3aa: 8d 04 05
                lda ram178                   ; b3ad: ad 05 05
                bne +                        ; b3b0: d0 01
                rts                          ; b3b2: 60

+               sta ram166                   ; b3b3: 8d f8 04 (unaccessed)
                ldx #0                       ; b3b6: a2 00    (unaccessed)
cod58           lda ram166                   ; b3b8: ad f8 04 (unaccessed)
                sta ram79                    ; b3bb: 85 76    (unaccessed)
                lda #0                       ; b3bd: a9 00    (unaccessed)
                sta arr125,x                 ; b3bf: 9d 30 05 (unaccessed)
cod59           ldy #0                       ; b3c2: a0 00    (unaccessed)
                lda arr117,x                 ; b3c4: bd 08 05 (unaccessed)
                sta ptr9+0                   ; b3c7: 85 7f    (unaccessed)
                lda arr118,x                 ; b3c9: bd 0d 05 (unaccessed)
                sta ptr9+1                   ; b3cc: 85 80    (unaccessed)
cod60           lda arr125,x                 ; b3ce: bd 30 05 (unaccessed)
                beq +                        ; b3d1: f0 06    (unaccessed)
                dec arr125,x                 ; b3d3: de 30 05 (unaccessed)
                jmp cod61                    ; b3d6: 4c f2 b3 (unaccessed)
+               lda (ptr9),y                 ; b3d9: b1 7f    (unaccessed)
                bmi cod62                    ; b3db: 30 32    (unaccessed)
                lda arr126,x                 ; b3dd: bd 35 05 (unaccessed)
                cmp #$ff                     ; b3e0: c9 ff    (unaccessed)
                bne +                        ; b3e2: d0 0a    (unaccessed)
                iny                          ; b3e4: c8       (unaccessed)
                lda (ptr9),y                 ; b3e5: b1 7f    (unaccessed)
                iny                          ; b3e7: c8       (unaccessed)
                sta arr125,x                 ; b3e8: 9d 30 05 (unaccessed)
                jmp cod61                    ; b3eb: 4c f2 b3 (unaccessed)
+               iny                          ; b3ee: c8       (unaccessed)
                sta arr125,x                 ; b3ef: 9d 30 05 (unaccessed)
cod61           clc                          ; b3f2: 18       (unaccessed)
                tya                          ; b3f3: 98       (unaccessed)
                adc ptr9+0                   ; b3f4: 65 7f    (unaccessed)
                sta arr117,x                 ; b3f6: 9d 08 05 (unaccessed)
                lda #0                       ; b3f9: a9 00    (unaccessed)
                adc ptr9+1                   ; b3fb: 65 80    (unaccessed)
                sta arr118,x                 ; b3fd: 9d 0d 05 (unaccessed)
                dec ram79                    ; b400: c6 76    (unaccessed)
                bne cod59                    ; b402: d0 be    (unaccessed)
                inx                          ; b404: e8       (unaccessed)
                cpx #5                       ; b405: e0 05    (unaccessed)
                bne cod58                    ; b407: d0 af    (unaccessed)
                lda #0                       ; b409: a9 00    (unaccessed)
                sta ram178                   ; b40b: 8d 05 05 (unaccessed)
                rts                          ; b40e: 60       (unaccessed)
cod62           cmp #$80                     ; b40f: c9 80    (unaccessed)
                beq cod65                    ; b411: f0 38    (unaccessed)
                cmp #$82                     ; b413: c9 82    (unaccessed)
                beq cod63                    ; b415: f0 21    (unaccessed)
                cmp #$84                     ; b417: c9 84    (unaccessed)
                beq cod64                    ; b419: f0 27    (unaccessed)
                pha                          ; b41b: 48       (unaccessed)
                cmp #$8e                     ; b41c: c9 8e    (unaccessed)
                beq +                        ; b41e: f0 13    (unaccessed)
                cmp #$92                     ; b420: c9 92    (unaccessed)
                beq +                        ; b422: f0 0f    (unaccessed)
                cmp #$a2                     ; b424: c9 a2    (unaccessed)
                beq +                        ; b426: f0 0b    (unaccessed)
                and #%11110000               ; b428: 29 f0    (unaccessed)
                cmp #$f0                     ; b42a: c9 f0    (unaccessed)
                beq +                        ; b42c: f0 05    (unaccessed)
                cmp #$e0                     ; b42e: c9 e0    (unaccessed)
                beq cod66                    ; b430: f0 23    (unaccessed)
                iny                          ; b432: c8       (unaccessed)
+               iny                          ; b433: c8       (unaccessed)
                pla                          ; b434: 68       (unaccessed)
                jmp cod60                    ; b435: 4c ce b3 (unaccessed)
cod63           iny                          ; b438: c8       (unaccessed)
                lda (ptr9),y                 ; b439: b1 7f    (unaccessed)
                iny                          ; b43b: c8       (unaccessed)
                sta arr126,x                 ; b43c: 9d 35 05 (unaccessed)
                jmp cod60                    ; b43f: 4c ce b3 (unaccessed)
cod64           iny                          ; b442: c8       (unaccessed)
                lda #$ff                     ; b443: a9 ff    (unaccessed)
                sta arr126,x                 ; b445: 9d 35 05 (unaccessed)
                jmp cod60                    ; b448: 4c ce b3 (unaccessed)
cod65           iny                          ; b44b: c8       (unaccessed)
                lda (ptr9),y                 ; b44c: b1 7f    (unaccessed)
                iny                          ; b44e: c8       (unaccessed)
                jsr sub66                    ; b44f: 20 f7 be (unaccessed)
                jmp cod60                    ; b452: 4c ce b3 (unaccessed)
cod66           iny                          ; b455: c8       (unaccessed)
                pla                          ; b456: 68       (unaccessed)
                and #%00001111               ; b457: 29 0f    (unaccessed)
                asl a                        ; b459: 0a       (unaccessed)
                jsr sub66                    ; b45a: 20 f7 be (unaccessed)
                jmp cod60                    ; b45d: 4c ce b3 (unaccessed)

sub48           lda ram165                   ; b460: ad f7 04
                bne +                        ; b463: d0 01
                rts                          ; b465: 60       (unaccessed)
+               ldx #0                       ; b466: a2 00
-               lda arr121,x                 ; b468: bd 1c 05
                beq +                        ; b46b: f0 13

                sec                          ; b46d: 38       (unaccessed)
                sbc #1                       ; b46e: e9 01    (unaccessed)
                sta arr121,x                 ; b470: 9d 1c 05 (unaccessed)
                bne +                        ; b473: d0 0b    (unaccessed)
                jsr sub49                    ; b475: 20 76 b5 (unaccessed)
                lda arr122,x                 ; b478: bd 21 05 (unaccessed)
                and #%01111111               ; b47b: 29 7f    (unaccessed)
                sta arr122,x                 ; b47d: 9d 21 05 (unaccessed)

+               inx                          ; b480: e8
                cpx #5                       ; b481: e0 05
                bne -                        ; b483: d0 e3
                lda ram170                   ; b485: ad fc 04
                bmi +                        ; b488: 30 08
                ora ram169                   ; b48a: 0d fb 04
                beq +                        ; b48d: f0 03
                jmp cod69                    ; b48f: 4c 27 b5
+               lda ram168                   ; b492: ad fa 04
                beq +                        ; b495: f0 0b
                lda #0                       ; b497: a9 00
                sta ram168                   ; b499: 8d fa 04
                lda ram167                   ; b49c: ad f9 04
                jsr sub47                    ; b49f: 20 5f b3
+               ldx #0                       ; b4a2: a2 00
-               lda arr121,x                 ; b4a4: bd 1c 05
                beq +                        ; b4a7: f0 08
                lda #0                       ; b4a9: a9 00    (unaccessed)
                sta arr121,x                 ; b4ab: 9d 1c 05 (unaccessed)
                jsr sub49                    ; b4ae: 20 76 b5 (unaccessed)
+               jsr sub49                    ; b4b1: 20 76 b5
                lda arr122,x                 ; b4b4: bd 21 05
                and #%01111111               ; b4b7: 29 7f
                sta arr122,x                 ; b4b9: 9d 21 05
                inx                          ; b4bc: e8
                cpx #5                       ; b4bd: e0 05
                bne -                        ; b4bf: d0 e3
                lda ram176                   ; b4c1: ad 03 05
                beq +                        ; b4c4: f0 0e

                sec                          ; b4c6: 38       (unaccessed)
                sbc #1                       ; b4c7: e9 01    (unaccessed)
                sta ram167                   ; b4c9: 8d f9 04 (unaccessed)
                lda #1                       ; b4cc: a9 01    (unaccessed)
                sta ram168                   ; b4ce: 8d fa 04 (unaccessed)
                jmp cod68                    ; b4d1: 4c 24 b5 (unaccessed)

+               lda ram177                   ; b4d4: ad 04 05
                beq cod67                    ; b4d7: f0 26
                sec                          ; b4d9: 38
                sbc #1                       ; b4da: e9 01
                sta ram178                   ; b4dc: 8d 05 05
                inc ram167                   ; b4df: ee f9 04
                lda ram167                   ; b4e2: ad f9 04
                cmp arr115                   ; b4e5: cd f2 04
                beq +                        ; b4e8: f0 08
                lda #1                       ; b4ea: a9 01    (unaccessed)
                sta ram168                   ; b4ec: 8d fa 04 (unaccessed)
                jmp cod68                    ; b4ef: 4c 24 b5 (unaccessed)
+               lda #0                       ; b4f2: a9 00
                sta ram167                   ; b4f4: 8d f9 04
                lda #1                       ; b4f7: a9 01
                sta ram168                   ; b4f9: 8d fa 04
                jmp cod68                    ; b4fc: 4c 24 b5
cod67           inc ram166                   ; b4ff: ee f8 04
                lda ram166                   ; b502: ad f8 04
                cmp ram162                   ; b505: cd f3 04
                bne cod68                    ; b508: d0 1a
                inc ram167                   ; b50a: ee f9 04
                lda ram167                   ; b50d: ad f9 04
                cmp arr115                   ; b510: cd f2 04
                beq +                        ; b513: f0 06
                sta ram168                   ; b515: 8d fa 04
                jmp cod68                    ; b518: 4c 24 b5
+               ldx #0                       ; b51b: a2 00    (unaccessed)
                stx ram167                   ; b51d: 8e f9 04 (unaccessed)
                inx                          ; b520: e8       (unaccessed)
                stx ram168                   ; b521: 8e fa 04 (unaccessed)
cod68           jsr sub53                    ; b524: 20 b4 b8
cod69           sec                          ; b527: 38
                lda ram169                   ; b528: ad fb 04
                sbc ram171                   ; b52b: ed fd 04
                sta ram169                   ; b52e: 8d fb 04
                lda ram170                   ; b531: ad fc 04
                sbc ram172                   ; b534: ed fe 04
                sta ram170                   ; b537: 8d fc 04
                ldx #0                       ; b53a: a2 00
-               lda arr122,x                 ; b53c: bd 21 05
                beq +                        ; b53f: f0 17

                sec                          ; b541: 38       (unaccessed)
                sbc #1                       ; b542: e9 01    (unaccessed)
                sta arr122,x                 ; b544: 9d 21 05 (unaccessed)
                bne +                        ; b547: d0 0f    (unaccessed)
                sta arr119,x                 ; b549: 9d 12 05 (unaccessed)
                sta arr155,x                 ; b54c: 9d a5 05 (unaccessed)
                sta arr154,x                 ; b54f: 9d a1 05 (unaccessed)
                sta arr128,x                 ; b552: 9d 3e 05 (unaccessed)
                sta arr127,x                 ; b555: 9d 3a 05 (unaccessed)

+               inx                          ; b558: e8
                cpx #5                       ; b559: e0 05
                bne -                        ; b55b: d0 df
                ldx #0                       ; b55d: a2 00
-               jsr sub56                    ; b55f: 20 31 b9
                lda arr119,x                 ; b562: bd 12 05
                beq +                        ; b565: f0 03
                jsr sub62                    ; b567: 20 ce bc
+               jsr sub57                    ; b56a: 20 10 ba
                inx                          ; b56d: e8
                cpx #4                       ; b56e: e0 04
                bne -                        ; b570: d0 ed
                jsr sub68                    ; b572: 20 d0 c0
                rts                          ; b575: 60
sub49           ldy arr125,x                 ; b576: bc 30 05
                beq +                        ; b579: f0 06
                dey                          ; b57b: 88
                tya                          ; b57c: 98
                sta arr125,x                 ; b57d: 9d 30 05
                rts                          ; b580: 60
+               sty ram175                   ; b581: 8c 02 05
                lda #$0f                     ; b584: a9 0f
                sta ram174                   ; b586: 8d 01 05
                lda arr117,x                 ; b589: bd 08 05
                sta ptr9+0                   ; b58c: 85 7f
                lda arr118,x                 ; b58e: bd 0d 05
                sta ptr9+1                   ; b591: 85 80
cod70           lda (ptr9),y                 ; b593: b1 7f
                bpl +                        ; b595: 10 03
                jmp cod77                    ; b597: 4c 40 b6
+               beq cod72                    ; b59a: f0 5c
                cmp #$7f                     ; b59c: c9 7f
                bne +                        ; b59e: d0 03
                jmp cod74                    ; b5a0: 4c 0d b6
+               cmp #$7e                     ; b5a3: c9 7e
                bne +                        ; b5a5: d0 03
                jmp cod73                    ; b5a7: 4c fb b5 (unaccessed)
+               sta arr119,x                 ; b5aa: 9d 12 05
                jsr sub52                    ; b5ad: 20 4a b8
                lda arr122,x                 ; b5b0: bd 21 05
                bmi +                        ; b5b3: 30 05
                lda #0                       ; b5b5: a9 00
                sta arr122,x                 ; b5b7: 9d 21 05
+               jsr sub65                    ; b5ba: 20 e5 be
                lda #0                       ; b5bd: a9 00
                sta arr123,x                 ; b5bf: 9d 26 05
                lda ram174                   ; b5c2: ad 01 05
                sta arr143,x                 ; b5c5: 9d 79 05
                lda #0                       ; b5c8: a9 00
                lda arr144,x                 ; b5ca: bd 7d 05
                and #%11110000               ; b5cd: 29 f0
                sta arr144,x                 ; b5cf: 9d 7d 05
                lsr a                        ; b5d2: 4a
                lsr a                        ; b5d3: 4a
                lsr a                        ; b5d4: 4a
                lsr a                        ; b5d5: 4a
                ora arr144,x                 ; b5d6: 1d 7d 05
                sta arr144,x                 ; b5d9: 9d 7d 05
                lda arr152,x                 ; b5dc: bd 99 05
                cmp #6                       ; b5df: c9 06
                beq +                        ; b5e1: f0 04
                cmp #8                       ; b5e3: c9 08
                bne cod71                    ; b5e5: d0 05
+               lda #0                       ; b5e7: a9 00    (unaccessed)
                sta arr152,x                 ; b5e9: 9d 99 05 (unaccessed)
cod71           cpx #2                       ; b5ec: e0 02
                bcc +                        ; b5ee: 90 03
                jmp cod79                    ; b5f0: 4c 68 b6
+               lda #0                       ; b5f3: a9 00
                sta arr132,x                 ; b5f5: 9d 4f 05
cod72           jmp cod79                    ; b5f8: 4c 68 b6

cod73           lda arr123,x                 ; b5fb: bd 26 05 (unaccessed)
                cmp #1                       ; b5fe: c9 01    (unaccessed)
                beq cod72                    ; b600: f0 f6    (unaccessed)
                lda #1                       ; b602: a9 01    (unaccessed)
                sta arr123,x                 ; b604: 9d 26 05 (unaccessed)
                jsr sub64                    ; b607: 20 68 be (unaccessed)
                jmp cod79                    ; b60a: 4c 68 b6 (unaccessed)

cod74           lda #0                       ; b60d: a9 00
                sta arr119,x                 ; b60f: 9d 12 05
                sta arr143,x                 ; b612: 9d 79 05
                sta arr155,x                 ; b615: 9d a5 05
                sta arr154,x                 ; b618: 9d a1 05
                sta arr128,x                 ; b61b: 9d 3e 05
                sta arr127,x                 ; b61e: 9d 3a 05
                cpx #2                       ; b621: e0 02
                bcs +                        ; b623: b0 00
+               jmp cod79                    ; b625: 4c 68 b6
cod75           pla                          ; b628: 68
                asl a                        ; b629: 0a
                asl a                        ; b62a: 0a
                asl a                        ; b62b: 0a
                and #%01111000               ; b62c: 29 78
                sta arr120,x                 ; b62e: 9d 17 05
                iny                          ; b631: c8
                jmp cod70                    ; b632: 4c 93 b5
cod76           pla                          ; b635: 68
                and #%00001111               ; b636: 29 0f
                asl a                        ; b638: 0a
                jsr sub66                    ; b639: 20 f7 be
                iny                          ; b63c: c8
                jmp cod70                    ; b63d: 4c 93 b5
cod77           pha                          ; b640: 48
                and #%11110000               ; b641: 29 f0
                cmp #$f0                     ; b643: c9 f0
                beq cod75                    ; b645: f0 e1
                cmp #$e0                     ; b647: c9 e0
                beq cod76                    ; b649: f0 ea
                pla                          ; b64b: 68
                and #%01111111               ; b64c: 29 7f
                sty ram78                    ; b64e: 84 75
                tay                          ; b650: a8
                lda dat38,y                  ; b651: b9 98 b6
                sta ptr8+0                   ; b654: 85 7b
                iny                          ; b656: c8
                lda dat38,y                  ; b657: b9 98 b6
                sta ptr8+1                   ; b65a: 85 7c
                ldy ram78                    ; b65c: a4 75
                iny                          ; b65e: c8
                jmp (ptr8)                   ; b65f: 6c 7b 00
cod78           sta arr125,x                 ; b662: 9d 30 05
                jmp cod80                    ; b665: 4c 75 b6
cod79           lda arr126,x                 ; b668: bd 35 05
                cmp #$ff                     ; b66b: c9 ff
                bne cod78                    ; b66d: d0 f3
                iny                          ; b66f: c8
                lda (ptr9),y                 ; b670: b1 7f
                sta arr125,x                 ; b672: 9d 30 05
cod80           clc                          ; b675: 18
                iny                          ; b676: c8
                tya                          ; b677: 98
                adc ptr9+0                   ; b678: 65 7f
                sta arr117,x                 ; b67a: 9d 08 05
                lda #0                       ; b67d: a9 00
                adc ptr9+1                   ; b67f: 65 80
                sta arr118,x                 ; b681: 9d 0d 05
                lda ram175                   ; b684: ad 02 05
                beq +                        ; b687: f0 08
                sta arr132,x                 ; b689: 9d 4f 05 (unaccessed)
                lda #0                       ; b68c: a9 00    (unaccessed)
                sta ram175                   ; b68e: 8d 02 05 (unaccessed)
+               rts                          ; b691: 60
sub50           lda (ptr9),y                 ; b692: b1 7f
                pha                          ; b694: 48
                iny                          ; b695: c8
                pla                          ; b696: 68
                rts                          ; b697: 60

                ; a jump table?
dat38           dw $b6d2                     ; b698 (unaccessed)
                dw $b6db                     ; b69a
                dw $b6e4                     ; b69c
                dw $b6ec                     ; b69e (unaccessed)
                dw $b6f8                     ; b6a0 (unaccessed)
                dw $b704                     ; b6a2 (unaccessed)
                dw $b70d                     ; b6a4
                dw $b716                     ; b6a6 (unaccessed)
                dw $b721                     ; b6a8 (unaccessed)
                dw $b76a                     ; b6aa
                dw $b73b                     ; b6ac (unaccessed)
                dw $b749                     ; b6ae
                dw $b72d                     ; b6b0
                dw $b757                     ; b6b2
                dw $b784                     ; b6b4
                dw $b7a9                     ; b6b6 (unaccessed)
                dw $b7c5                     ; b6b8 (unaccessed)
                dw $b7ce                     ; b6ba (unaccessed)
                dw $b7e0                     ; b6bc
                dw $b7d6                     ; b6be (unaccessed)
                dw $b77b                     ; b6c0 (unaccessed)
                dw $b7e0                     ; b6c2 (unaccessed)
                dw $b7f4                     ; b6c4 (unaccessed)
                dw $b7f4                     ; b6c6 (unaccessed)
                dw $b802                     ; b6c8 (unaccessed)
                dw $b810                     ; b6ca
                dw $b819                     ; b6cc (unaccessed)
                dw $b824                     ; b6ce (unaccessed)
                dw $b824                     ; b6d0 (unaccessed)

                jsr sub50                    ; b6d2: 20 92 b6 (unaccessed)
                jsr sub66                    ; b6d5: 20 f7 be (unaccessed)
                jmp cod70                    ; b6d8: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b6db: 20 92 b6
                sta arr126,x                 ; b6de: 9d 35 05
                jmp cod70                    ; b6e1: 4c 93 b5
                lda #$ff                     ; b6e4: a9 ff
                sta arr126,x                 ; b6e6: 9d 35 05
                jmp cod70                    ; b6e9: 4c 93 b5
                jsr sub50                    ; b6ec: 20 92 b6 (unaccessed)
                sta ram163                   ; b6ef: 8d f4 04 (unaccessed)
                jsr sub54                    ; b6f2: 20 c8 b8 (unaccessed)
                jmp cod70                    ; b6f5: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b6f8: 20 92 b6 (unaccessed)
                sta ram164                   ; b6fb: 8d f5 04 (unaccessed)
                jsr sub54                    ; b6fe: 20 c8 b8 (unaccessed)
                jmp cod70                    ; b701: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b704: 20 92 b6 (unaccessed)
                sta ram176                   ; b707: 8d 03 05 (unaccessed)
                jmp cod70                    ; b70a: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b70d: 20 92 b6
                sta ram177                   ; b710: 8d 04 05
                jmp cod70                    ; b713: 4c 93 b5
                jsr sub50                    ; b716: 20 92 b6 (unaccessed)
                lda #0                       ; b719: a9 00    (unaccessed)
                sta ram165                   ; b71b: 8d f7 04 (unaccessed)
                jmp cod70                    ; b71e: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b721: 20 92 b6 (unaccessed)
                sta ram174                   ; b724: 8d 01 05 (unaccessed)
                sta arr143,x                 ; b727: 9d 79 05 (unaccessed)
                jmp cod70                    ; b72a: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b72d: 20 92 b6
                sta arr153,x                 ; b730: 9d 9d 05
                lda #2                       ; b733: a9 02
                sta arr152,x                 ; b735: 9d 99 05
                jmp cod70                    ; b738: 4c 93 b5
                jsr sub50                    ; b73b: 20 92 b6 (unaccessed)
                sta arr153,x                 ; b73e: 9d 9d 05 (unaccessed)
                lda #3                       ; b741: a9 03    (unaccessed)
                sta arr152,x                 ; b743: 9d 99 05 (unaccessed)
                jmp cod70                    ; b746: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b749: 20 92 b6
                sta arr153,x                 ; b74c: 9d 9d 05
                lda #4                       ; b74f: a9 04
                sta arr152,x                 ; b751: 9d 99 05
                jmp cod70                    ; b754: 4c 93 b5
                jsr sub50                    ; b757: 20 92 b6
                sta arr153,x                 ; b75a: 9d 9d 05
                lda #0                       ; b75d: a9 00
                sta arr156,x                 ; b75f: 9d a9 05
                lda #1                       ; b762: a9 01
                sta arr152,x                 ; b764: 9d 99 05
                jmp cod70                    ; b767: 4c 93 b5
                lda #0                       ; b76a: a9 00
                sta arr153,x                 ; b76c: 9d 9d 05
                sta arr152,x                 ; b76f: 9d 99 05
                sta arr155,x                 ; b772: 9d a5 05
                sta arr154,x                 ; b775: 9d a1 05
                jmp cod70                    ; b778: 4c 93 b5
                jsr sub50                    ; b77b: 20 92 b6 (unaccessed)
                sta ram175                   ; b77e: 8d 02 05 (unaccessed)
                jmp cod70                    ; b781: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b784: 20 92 b6
                pha                          ; b787: 48
                lda arr159,x                 ; b788: bd b5 05
                bne cod81                    ; b78b: d0 0c
                lda ram158                   ; b78d: ad ee 04
                and #%00000010               ; b790: 29 02
                beq +                        ; b792: f0 02
                lda #$30                     ; b794: a9 30    (unaccessed)
+               sta arr157,x                 ; b796: 9d ad 05
cod81           pla                          ; b799: 68
                pha                          ; b79a: 48
                and #%11110000               ; b79b: 29 f0
                sta arr158,x                 ; b79d: 9d b1 05
                pla                          ; b7a0: 68
                and #%00001111               ; b7a1: 29 0f
                sta arr159,x                 ; b7a3: 9d b5 05
                jmp cod70                    ; b7a6: 4c 93 b5

                jsr sub50                    ; b7a9: 20 92 b6 (unaccessed)
                pha                          ; b7ac: 48       (unaccessed)
                and #%11110000               ; b7ad: 29 f0    (unaccessed)
                sta arr161,x                 ; b7af: 9d bd 05 (unaccessed)
                pla                          ; b7b2: 68       (unaccessed)
                and #%00001111               ; b7b3: 29 0f    (unaccessed)
                sta arr162,x                 ; b7b5: 9d c1 05 (unaccessed)
                cmp #0                       ; b7b8: c9 00    (unaccessed)
                beq +                        ; b7ba: f0 03    (unaccessed)
                jmp cod70                    ; b7bc: 4c 93 b5 (unaccessed)
+               sta arr160,x                 ; b7bf: 9d b9 05 (unaccessed)
                jmp cod70                    ; b7c2: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b7c5: 20 92 b6 (unaccessed)
                sta arr124,x                 ; b7c8: 9d 2b 05 (unaccessed)
                jmp cod70                    ; b7cb: 4c 93 b5 (unaccessed)
                lda #$80                     ; b7ce: a9 80    (unaccessed)
                sta arr124,x                 ; b7d0: 9d 2b 05 (unaccessed)
                jmp cod70                    ; b7d3: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b7d6: 20 92 b6 (unaccessed)
                sta arr121,x                 ; b7d9: 9d 1c 05 (unaccessed)
                dey                          ; b7dc: 88       (unaccessed)
                jmp cod80                    ; b7dd: 4c 75 b6 (unaccessed)

                jsr sub50                    ; b7e0: 20 92 b6
                sta arr144,x                 ; b7e3: 9d 7d 05
                clc                          ; b7e6: 18
                asl a                        ; b7e7: 0a
                asl a                        ; b7e8: 0a
                asl a                        ; b7e9: 0a
                asl a                        ; b7ea: 0a
                ora arr144,x                 ; b7eb: 1d 7d 05
                sta arr144,x                 ; b7ee: 9d 7d 05
                jmp cod70                    ; b7f1: 4c 93 b5

                jsr sub50                    ; b7f4: 20 92 b6 (unaccessed)
                sta arr153,x                 ; b7f7: 9d 9d 05 (unaccessed)
                lda #5                       ; b7fa: a9 05    (unaccessed)
                sta arr152,x                 ; b7fc: 9d 99 05 (unaccessed)
                jmp cod70                    ; b7ff: 4c 93 b5 (unaccessed)
                jsr sub50                    ; b802: 20 92 b6 (unaccessed)
                sta arr153,x                 ; b805: 9d 9d 05 (unaccessed)
                lda #7                       ; b808: a9 07    (unaccessed)
                sta arr152,x                 ; b80a: 9d 99 05 (unaccessed)
                jmp cod70                    ; b80d: 4c 93 b5 (unaccessed)

                jsr sub50                    ; b810: 20 92 b6
                sta arr131,x                 ; b813: 9d 4a 05
                jmp cod70                    ; b816: 4c 93 b5
                jsr sub50                    ; b819: 20 92 b6 (unaccessed)
                ora #%10000000               ; b81c: 09 80    (unaccessed)
                sta arr122,x                 ; b81e: 9d 21 05 (unaccessed)
                jmp cod70                    ; b821: 4c 93 b5 (unaccessed)
sub51           sec                          ; b824: 38
                sbc #1                       ; b825: e9 01
                cpx #3                       ; b827: e0 03
                beq cod83                    ; b829: f0 12
                asl a                        ; b82b: 0a
                sty ram78                    ; b82c: 84 75
                tay                          ; b82e: a8
cod82           lda (ptr10),y                ; b82f: b1 81
                sta arr128,x                 ; b831: 9d 3e 05
                iny                          ; b834: c8
                lda (ptr10),y                ; b835: b1 81
                sta arr127,x                 ; b837: 9d 3a 05
                ldy ram78                    ; b83a: a4 75
                rts                          ; b83c: 60
cod83           and #%00001111               ; b83d: 29 0f
                ora #%00010000               ; b83f: 09 10
                sta arr128,x                 ; b841: 9d 3e 05
                lda #0                       ; b844: a9 00
                sta arr127,x                 ; b846: 9d 3a 05
                rts                          ; b849: 60
sub52           sec                          ; b84a: 38
                sbc #1                       ; b84b: e9 01
                cpx #3                       ; b84d: e0 03
                beq cod85                    ; b84f: f0 31
                asl a                        ; b851: 0a
                sty ram78                    ; b852: 84 75
                tay                          ; b854: a8
                lda arr152,x                 ; b855: bd 99 05
                cmp #2                       ; b858: c9 02
                bne cod84                    ; b85a: d0 22
                lda (ptr10),y                ; b85c: b1 81
                sta arr155,x                 ; b85e: 9d a5 05
                iny                          ; b861: c8
                lda (ptr10),y                ; b862: b1 81
                sta arr154,x                 ; b864: 9d a1 05
                ldy ram78                    ; b867: a4 75
                lda arr128,x                 ; b869: bd 3e 05
                ora arr127,x                 ; b86c: 1d 3a 05
                bne +                        ; b86f: d0 0c
                lda arr155,x                 ; b871: bd a5 05
                sta arr128,x                 ; b874: 9d 3e 05
                lda arr154,x                 ; b877: bd a1 05
                sta arr127,x                 ; b87a: 9d 3a 05
+               rts                          ; b87d: 60
cod84           jmp cod82                    ; b87e: 4c 2f b8
                rts                          ; b881: 60       (unaccessed)
cod85           ora #%00010000               ; b882: 09 10
                pha                          ; b884: 48
                lda arr152,x                 ; b885: bd 99 05
                cmp #2                       ; b888: c9 02
                bne cod86                    ; b88a: d0 1e

                pla                          ; b88c: 68       (unaccessed)
                sta arr155,x                 ; b88d: 9d a5 05 (unaccessed)
                lda #0                       ; b890: a9 00    (unaccessed)
                sta arr154,x                 ; b892: 9d a1 05 (unaccessed)
                lda arr128,x                 ; b895: bd 3e 05 (unaccessed)
                ora arr127,x                 ; b898: 1d 3a 05 (unaccessed)
                bne +                        ; b89b: d0 0c    (unaccessed)
                lda arr155,x                 ; b89d: bd a5 05 (unaccessed)
                sta arr128,x                 ; b8a0: 9d 3e 05 (unaccessed)
                lda arr154,x                 ; b8a3: bd a1 05 (unaccessed)
                sta arr127,x                 ; b8a6: 9d 3a 05 (unaccessed)
+               rts                          ; b8a9: 60       (unaccessed)

cod86           pla                          ; b8aa: 68
                sta arr128,x                 ; b8ab: 9d 3e 05
                lda #0                       ; b8ae: a9 00
                sta arr127,x                 ; b8b0: 9d 3a 05
                rts                          ; b8b3: 60
sub53           clc                          ; b8b4: 18
                lda ram169                   ; b8b5: ad fb 04
                adc ram173                   ; b8b8: 6d ff 04
                sta ram169                   ; b8bb: 8d fb 04
                lda ram170                   ; b8be: ad fc 04
                adc arr116                   ; b8c1: 6d 00 05
                sta ram170                   ; b8c4: 8d fc 04
                rts                          ; b8c7: 60
sub54           tya                          ; b8c8: 98
                pha                          ; b8c9: 48
                lda ram164                   ; b8ca: ad f5 04
                sta arr43                    ; b8cd: 85 85
                lda #0                       ; b8cf: a9 00
                sta ram87                    ; b8d1: 85 86
                ldy #3                       ; b8d3: a0 03
-               asl arr43                    ; b8d5: 06 85
                rol ram87                    ; b8d7: 26 86
                dey                          ; b8d9: 88
                bne -                        ; b8da: d0 f9
                lda arr43                    ; b8dc: a5 85
                sta arr41                    ; b8de: 85 83
                lda ram87                    ; b8e0: a5 86
                tay                          ; b8e2: a8
                asl arr43                    ; b8e3: 06 85
                rol ram87                    ; b8e5: 26 86
                clc                          ; b8e7: 18
                lda arr41                    ; b8e8: a5 83
                adc arr43                    ; b8ea: 65 85
                sta arr41                    ; b8ec: 85 83
                tya                          ; b8ee: 98
                adc ram87                    ; b8ef: 65 86
                sta arr42                    ; b8f1: 85 84
                lda ram163                   ; b8f3: ad f4 04
                sta arr43                    ; b8f6: 85 85
                lda #0                       ; b8f8: a9 00
                sta ram87                    ; b8fa: 85 86
                jsr sub55                    ; b8fc: 20 0c b9
                lda arr41                    ; b8ff: a5 83
                sta ram171                   ; b901: 8d fd 04
                lda arr42                    ; b904: a5 84
                sta ram172                   ; b906: 8d fe 04
                pla                          ; b909: 68
                tay                          ; b90a: a8
                rts                          ; b90b: 60
sub55           lda #0                       ; b90c: a9 00
                sta ram89                    ; b90e: 85 88
                ldy #$10                     ; b910: a0 10
-               asl arr41                    ; b912: 06 83
                rol arr42                    ; b914: 26 84
                rol a                        ; b916: 2a
                rol ram89                    ; b917: 26 88
                pha                          ; b919: 48
                cmp arr43                    ; b91a: c5 85
                lda ram89                    ; b91c: a5 88
                sbc ram87                    ; b91e: e5 86
                bcc +                        ; b920: 90 08
                sta ram89                    ; b922: 85 88
                pla                          ; b924: 68
                sbc arr43                    ; b925: e5 85
                pha                          ; b927: 48
                inc arr41                    ; b928: e6 83
+               pla                          ; b92a: 68
                dey                          ; b92b: 88
                bne -                        ; b92c: d0 e4
                sta ram88                    ; b92e: 85 87
                rts                          ; b930: 60
sub56           lda arr131,x                 ; b931: bd 4a 05
                beq cod87                    ; b934: f0 2a
                lda arr131,x                 ; b936: bd 4a 05
                and #%00001111               ; b939: 29 0f
                sta ram78                    ; b93b: 85 75
                sec                          ; b93d: 38
                lda arr120,x                 ; b93e: bd 17 05
                sbc ram78                    ; b941: e5 75
                bpl +                        ; b943: 10 02
                lda #0                       ; b945: a9 00
+               sta arr120,x                 ; b947: 9d 17 05
                lda arr131,x                 ; b94a: bd 4a 05
                lsr a                        ; b94d: 4a
                lsr a                        ; b94e: 4a
                lsr a                        ; b94f: 4a
                lsr a                        ; b950: 4a
                sta ram78                    ; b951: 85 75
                clc                          ; b953: 18
                lda arr120,x                 ; b954: bd 17 05
                adc ram78                    ; b957: 65 75
                bpl +                        ; b959: 10 02
                lda #$7f                     ; b95b: a9 7f    (unaccessed)
+               sta arr120,x                 ; b95d: 9d 17 05
cod87           lda arr152,x                 ; b960: bd 99 05
                beq cod93                    ; b963: f0 31
                cmp #1                       ; b965: c9 01
                beq +                        ; b967: f0 1b
                cmp #2                       ; b969: c9 02
                beq cod88                    ; b96b: f0 1a
                cmp #3                       ; b96d: c9 03
                beq cod89                    ; b96f: f0 19
                cmp #6                       ; b971: c9 06
                beq cod90                    ; b973: f0 18
                cmp #8                       ; b975: c9 08
                beq cod91                    ; b977: f0 17
                cmp #5                       ; b979: c9 05
                beq cod92                    ; b97b: f0 16
                cmp #7                       ; b97d: c9 07
                beq cod92                    ; b97f: f0 12
                jmp cod103                   ; b981: 4c d8 ba
+               jmp cod108                   ; b984: 4c 86 bb
cod88           jmp cod98                    ; b987: 4c 52 ba
cod89           jmp cod102                   ; b98a: 4c c6 ba (unaccessed)
cod90           jmp cod104                   ; b98d: 4c 22 bb (unaccessed)
cod91           jmp cod105                   ; b990: 4c 48 bb (unaccessed)
cod92           jmp cod94                    ; b993: 4c 97 b9 (unaccessed)
cod93           rts                          ; b996: 60

cod94           lda arr128,x                 ; b997: bd 3e 05 (unaccessed)
                pha                          ; b99a: 48       (unaccessed)
                lda arr127,x                 ; b99b: bd 3a 05 (unaccessed)
                pha                          ; b99e: 48       (unaccessed)
                lda arr153,x                 ; b99f: bd 9d 05 (unaccessed)
                and #%00001111               ; b9a2: 29 0f    (unaccessed)
                sta ram78                    ; b9a4: 85 75    (unaccessed)
                lda arr152,x                 ; b9a6: bd 99 05 (unaccessed)
                cmp #5                       ; b9a9: c9 05    (unaccessed)
                beq cod95                    ; b9ab: f0 11    (unaccessed)
                lda arr119,x                 ; b9ad: bd 12 05 (unaccessed)
                sec                          ; b9b0: 38       (unaccessed)
                sbc ram78                    ; b9b1: e5 75    (unaccessed)
                bpl +                        ; b9b3: 10 02    (unaccessed)
                lda #1                       ; b9b5: a9 01    (unaccessed)
+               bne +                        ; b9b7: d0 02    (unaccessed)
                lda #1                       ; b9b9: a9 01    (unaccessed)
+               jmp cod96                    ; b9bb: 4c ca b9 (unaccessed)
cod95           lda arr119,x                 ; b9be: bd 12 05 (unaccessed)
                clc                          ; b9c1: 18       (unaccessed)
                adc ram78                    ; b9c2: 65 75    (unaccessed)
                cmp #$60                     ; b9c4: c9 60    (unaccessed)
                bcc cod96                    ; b9c6: 90 02    (unaccessed)
                lda #$60                     ; b9c8: a9 60    (unaccessed)
cod96           sta arr119,x                 ; b9ca: 9d 12 05 (unaccessed)
                jsr sub51                    ; b9cd: 20 24 b8 (unaccessed)
                lda arr128,x                 ; b9d0: bd 3e 05 (unaccessed)
                sta arr155,x                 ; b9d3: 9d a5 05 (unaccessed)
                lda arr127,x                 ; b9d6: bd 3a 05 (unaccessed)
                sta arr154,x                 ; b9d9: 9d a1 05 (unaccessed)
                lda arr153,x                 ; b9dc: bd 9d 05 (unaccessed)
                lsr a                        ; b9df: 4a       (unaccessed)
                lsr a                        ; b9e0: 4a       (unaccessed)
                lsr a                        ; b9e1: 4a       (unaccessed)
                ora #%00000001               ; b9e2: 09 01    (unaccessed)
                sta arr153,x                 ; b9e4: 9d 9d 05 (unaccessed)
                pla                          ; b9e7: 68       (unaccessed)
                sta arr127,x                 ; b9e8: 9d 3a 05 (unaccessed)
                pla                          ; b9eb: 68       (unaccessed)
                sta arr128,x                 ; b9ec: 9d 3e 05 (unaccessed)
                clc                          ; b9ef: 18       (unaccessed)
                lda arr152,x                 ; b9f0: bd 99 05 (unaccessed)
                adc #1                       ; b9f3: 69 01    (unaccessed)
                sta arr152,x                 ; b9f5: 9d 99 05 (unaccessed)
                cpx #3                       ; b9f8: e0 03    (unaccessed)
                bne cod97                    ; b9fa: d0 11    (unaccessed)
                cmp #6                       ; b9fc: c9 06    (unaccessed)
                beq +                        ; b9fe: f0 08    (unaccessed)
                lda #6                       ; ba00: a9 06    (unaccessed)
                sta arr152,x                 ; ba02: 9d 99 05 (unaccessed)
                jmp cod87                    ; ba05: 4c 60 b9 (unaccessed)
+               lda #8                       ; ba08: a9 08    (unaccessed)
                sta arr152,x                 ; ba0a: 9d 99 05 (unaccessed)
cod97           jmp cod87                    ; ba0d: 4c 60 b9 (unaccessed)

sub57           lda arr128,x                 ; ba10: bd 3e 05
                sta arr129,x                 ; ba13: 9d 42 05
                lda arr127,x                 ; ba16: bd 3a 05
                sta arr130,x                 ; ba19: 9d 46 05
                lda arr124,x                 ; ba1c: bd 2b 05
                cmp #$80                     ; ba1f: c9 80
                beq +                        ; ba21: f0 28

                lda arr119,x                 ; ba23: bd 12 05 (unaccessed)
                beq +                        ; ba26: f0 23    (unaccessed)
                clc                          ; ba28: 18       (unaccessed)
                lda arr129,x                 ; ba29: bd 42 05 (unaccessed)
                adc #$80                     ; ba2c: 69 80    (unaccessed)
                sta arr129,x                 ; ba2e: 9d 42 05 (unaccessed)
                lda arr130,x                 ; ba31: bd 46 05 (unaccessed)
                adc #0                       ; ba34: 69 00    (unaccessed)
                sta arr130,x                 ; ba36: 9d 46 05 (unaccessed)
                sec                          ; ba39: 38       (unaccessed)
                lda arr129,x                 ; ba3a: bd 42 05 (unaccessed)
                sbc arr124,x                 ; ba3d: fd 2b 05 (unaccessed)
                sta arr129,x                 ; ba40: 9d 42 05 (unaccessed)
                lda arr130,x                 ; ba43: bd 46 05 (unaccessed)
                sbc #0                       ; ba46: e9 00    (unaccessed)
                sta arr130,x                 ; ba48: 9d 46 05 (unaccessed)

+               jsr sub60                    ; ba4b: 20 d2 bb
                jsr sub61                    ; ba4e: 20 90 bc
                rts                          ; ba51: 60
cod98           lda arr153,x                 ; ba52: bd 9d 05
                beq cod101                   ; ba55: f0 6c
                lda arr155,x                 ; ba57: bd a5 05
                ora arr154,x                 ; ba5a: 1d a1 05
                beq cod101                   ; ba5d: f0 64
                lda arr127,x                 ; ba5f: bd 3a 05
                cmp arr154,x                 ; ba62: dd a1 05
                bcc cod99                    ; ba65: 90 2f
                bne +                        ; ba67: d0 0d
                lda arr128,x                 ; ba69: bd 3e 05
                cmp arr155,x                 ; ba6c: dd a5 05
                bcc cod99                    ; ba6f: 90 25
                bne +                        ; ba71: d0 03
                jmp cod93                    ; ba73: 4c 96 b9
+               lda arr153,x                 ; ba76: bd 9d 05
                sta ptr7+0                   ; ba79: 85 79
                lda #0                       ; ba7b: a9 00
                sta ptr7+1                   ; ba7d: 85 7a
                jsr sub59                    ; ba7f: 20 06 bb
                cmp arr154,x                 ; ba82: dd a1 05
                bcc cod100                   ; ba85: 90 30
                bmi cod100                   ; ba87: 30 2e
                bne cod101                   ; ba89: d0 38
                lda arr128,x                 ; ba8b: bd 3e 05
                cmp arr155,x                 ; ba8e: dd a5 05
                bcc cod100                   ; ba91: 90 24
                jmp cod93                    ; ba93: 4c 96 b9
cod99           lda arr153,x                 ; ba96: bd 9d 05
                sta ptr7+0                   ; ba99: 85 79
                lda #0                       ; ba9b: a9 00
                sta ptr7+1                   ; ba9d: 85 7a
                jsr sub58                    ; ba9f: 20 ea ba
                lda arr154,x                 ; baa2: bd a1 05
                cmp arr127,x                 ; baa5: dd 3a 05
                bcc cod100                   ; baa8: 90 0d
                bne cod101                   ; baaa: d0 17
                lda arr155,x                 ; baac: bd a5 05
                cmp arr128,x                 ; baaf: dd 3e 05
                bcc cod100                   ; bab2: 90 03
                jmp cod93                    ; bab4: 4c 96 b9
cod100          lda arr155,x                 ; bab7: bd a5 05
                sta arr128,x                 ; baba: 9d 3e 05
                lda arr154,x                 ; babd: bd a1 05
                sta arr127,x                 ; bac0: 9d 3a 05
cod101          jmp cod93                    ; bac3: 4c 96 b9

cod102          lda arr153,x                 ; bac6: bd 9d 05 (unaccessed)
                sta ptr7+0                   ; bac9: 85 79    (unaccessed)
                lda #0                       ; bacb: a9 00    (unaccessed)
                sta ptr7+1                   ; bacd: 85 7a    (unaccessed)
                jsr sub59                    ; bacf: 20 06 bb (unaccessed)
                jsr sub67                    ; bad2: 20 75 c0 (unaccessed)
                jmp cod93                    ; bad5: 4c 96 b9 (unaccessed)

cod103          lda arr153,x                 ; bad8: bd 9d 05
                sta ptr7+0                   ; badb: 85 79
                lda #0                       ; badd: a9 00
                sta ptr7+1                   ; badf: 85 7a
                jsr sub58                    ; bae1: 20 ea ba
                jsr sub67                    ; bae4: 20 75 c0
                jmp cod93                    ; bae7: 4c 96 b9
sub58           clc                          ; baea: 18
                lda arr128,x                 ; baeb: bd 3e 05
                adc ptr7+0                   ; baee: 65 79
                sta arr128,x                 ; baf0: 9d 3e 05
                lda arr127,x                 ; baf3: bd 3a 05
                adc ptr7+1                   ; baf6: 65 7a
                sta arr127,x                 ; baf8: 9d 3a 05
                bcc +                        ; bafb: 90 08
                lda #$ff                     ; bafd: a9 ff    (unaccessed)
                sta arr128,x                 ; baff: 9d 3e 05 (unaccessed)
                sta arr127,x                 ; bb02: 9d 3a 05 (unaccessed)
+               rts                          ; bb05: 60
sub59           sec                          ; bb06: 38
                lda arr128,x                 ; bb07: bd 3e 05
                sbc ptr7+0                   ; bb0a: e5 79
                sta arr128,x                 ; bb0c: 9d 3e 05
                lda arr127,x                 ; bb0f: bd 3a 05
                sbc ptr7+1                   ; bb12: e5 7a
                sta arr127,x                 ; bb14: 9d 3a 05
                bcs +                        ; bb17: b0 08
                lda #0                       ; bb19: a9 00    (unaccessed)
                sta arr128,x                 ; bb1b: 9d 3e 05 (unaccessed)
                sta arr127,x                 ; bb1e: 9d 3a 05 (unaccessed)
+               rts                          ; bb21: 60

cod104          sec                          ; bb22: 38       (unaccessed)
                lda arr128,x                 ; bb23: bd 3e 05 (unaccessed)
                sbc arr153,x                 ; bb26: fd 9d 05 (unaccessed)
                sta arr128,x                 ; bb29: 9d 3e 05 (unaccessed)
                lda arr127,x                 ; bb2c: bd 3a 05 (unaccessed)
                sbc #0                       ; bb2f: e9 00    (unaccessed)
                sta arr127,x                 ; bb31: 9d 3a 05 (unaccessed)
                bmi cod106                   ; bb34: 30 36    (unaccessed)
                cmp arr154,x                 ; bb36: dd a1 05 (unaccessed)
                bcc cod106                   ; bb39: 90 31    (unaccessed)
                bne cod107                   ; bb3b: d0 46    (unaccessed)
                lda arr128,x                 ; bb3d: bd 3e 05 (unaccessed)
                cmp arr155,x                 ; bb40: dd a5 05 (unaccessed)
                bcc cod106                   ; bb43: 90 27    (unaccessed)
                jmp cod93                    ; bb45: 4c 96 b9 (unaccessed)
cod105          clc                          ; bb48: 18       (unaccessed)
                lda arr128,x                 ; bb49: bd 3e 05 (unaccessed)
                adc arr153,x                 ; bb4c: 7d 9d 05 (unaccessed)
                sta arr128,x                 ; bb4f: 9d 3e 05 (unaccessed)
                lda arr127,x                 ; bb52: bd 3a 05 (unaccessed)
                adc #0                       ; bb55: 69 00    (unaccessed)
                sta arr127,x                 ; bb57: 9d 3a 05 (unaccessed)
                cmp arr154,x                 ; bb5a: dd a1 05 (unaccessed)
                bcc cod107                   ; bb5d: 90 24    (unaccessed)
                bne cod106                   ; bb5f: d0 0b    (unaccessed)
                lda arr128,x                 ; bb61: bd 3e 05 (unaccessed)
                cmp arr155,x                 ; bb64: dd a5 05 (unaccessed)
                bcs cod106                   ; bb67: b0 03    (unaccessed)
                jmp cod93                    ; bb69: 4c 96 b9 (unaccessed)
cod106          lda arr155,x                 ; bb6c: bd a5 05 (unaccessed)
                sta arr128,x                 ; bb6f: 9d 3e 05 (unaccessed)
                lda arr154,x                 ; bb72: bd a1 05 (unaccessed)
                sta arr127,x                 ; bb75: 9d 3a 05 (unaccessed)
                lda #0                       ; bb78: a9 00    (unaccessed)
                sta arr152,x                 ; bb7a: 9d 99 05 (unaccessed)
                sta arr155,x                 ; bb7d: 9d a5 05 (unaccessed)
                sta arr154,x                 ; bb80: 9d a1 05 (unaccessed)
cod107          jmp cod93                    ; bb83: 4c 96 b9 (unaccessed)

cod108          lda arr156,x                 ; bb86: bd a9 05
                cmp #1                       ; bb89: c9 01
                beq +                        ; bb8b: f0 10
                cmp #2                       ; bb8d: c9 02
                beq cod109                   ; bb8f: f0 2d
                lda arr119,x                 ; bb91: bd 12 05
                jsr sub51                    ; bb94: 20 24 b8
                inc arr156,x                 ; bb97: fe a9 05
                jmp cod93                    ; bb9a: 4c 96 b9
+               lda arr153,x                 ; bb9d: bd 9d 05
                lsr a                        ; bba0: 4a
                lsr a                        ; bba1: 4a
                lsr a                        ; bba2: 4a
                lsr a                        ; bba3: 4a
                clc                          ; bba4: 18
                adc arr119,x                 ; bba5: 7d 12 05
                jsr sub51                    ; bba8: 20 24 b8
                lda arr153,x                 ; bbab: bd 9d 05
                and #%00001111               ; bbae: 29 0f
                bne +                        ; bbb0: d0 06
                sta arr156,x                 ; bbb2: 9d a9 05 (unaccessed)
                jmp cod93                    ; bbb5: 4c 96 b9 (unaccessed)
+               inc arr156,x                 ; bbb8: fe a9 05
                jmp cod93                    ; bbbb: 4c 96 b9
cod109          lda arr153,x                 ; bbbe: bd 9d 05
                and #%00001111               ; bbc1: 29 0f
                clc                          ; bbc3: 18
                adc arr119,x                 ; bbc4: 7d 12 05
                jsr sub51                    ; bbc7: 20 24 b8
                lda #0                       ; bbca: a9 00
                sta arr156,x                 ; bbcc: 9d a9 05
                jmp cod93                    ; bbcf: 4c 96 b9
sub60           lda arr159,x                 ; bbd2: bd b5 05
                bne +                        ; bbd5: d0 01
                rts                          ; bbd7: 60
+               clc                          ; bbd8: 18
                adc arr157,x                 ; bbd9: 7d ad 05
                and #%00111111               ; bbdc: 29 3f
                sta arr157,x                 ; bbde: 9d ad 05
                cmp #$10                     ; bbe1: c9 10
                bcc +                        ; bbe3: 90 1c
                cmp #$20                     ; bbe5: c9 20
                bcc cod110                   ; bbe7: 90 28
                cmp #$30                     ; bbe9: c9 30
                bcc cod111                   ; bbeb: 90 3e
                sec                          ; bbed: 38
                sbc #$30                     ; bbee: e9 30
                sta ram78                    ; bbf0: 85 75
                sec                          ; bbf2: 38
                lda #$0f                     ; bbf3: a9 0f
                sbc ram78                    ; bbf5: e5 75
                ora arr158,x                 ; bbf7: 1d b1 05
                tay                          ; bbfa: a8
                lda dat44,y                  ; bbfb: b9 29 c5
                jmp cod112                   ; bbfe: 4c 35 bc
+               ora arr158,x                 ; bc01: 1d b1 05
                tay                          ; bc04: a8
                lda dat44,y                  ; bc05: b9 29 c5
                sta ptr7+0                   ; bc08: 85 79
                lda #0                       ; bc0a: a9 00
                sta ptr7+1                   ; bc0c: 85 7a
                jmp cod113                   ; bc0e: 4c 4a bc
cod110          sec                          ; bc11: 38
                sbc #$10                     ; bc12: e9 10
                sta ram78                    ; bc14: 85 75
                sec                          ; bc16: 38
                lda #$0f                     ; bc17: a9 0f
                sbc ram78                    ; bc19: e5 75
                ora arr158,x                 ; bc1b: 1d b1 05
                tay                          ; bc1e: a8
                lda dat44,y                  ; bc1f: b9 29 c5
                sta ptr7+0                   ; bc22: 85 79
                lda #0                       ; bc24: a9 00
                sta ptr7+1                   ; bc26: 85 7a
                jmp cod113                   ; bc28: 4c 4a bc
cod111          sec                          ; bc2b: 38
                sbc #$20                     ; bc2c: e9 20
                ora arr158,x                 ; bc2e: 1d b1 05
                tay                          ; bc31: a8
                lda dat44,y                  ; bc32: b9 29 c5
cod112          eor #%11111111               ; bc35: 49 ff
                sta ptr7+0                   ; bc37: 85 79
                lda #$ff                     ; bc39: a9 ff
                sta ptr7+1                   ; bc3b: 85 7a
                clc                          ; bc3d: 18
                lda ptr7+0                   ; bc3e: a5 79
                adc #1                       ; bc40: 69 01
                sta ptr7+0                   ; bc42: 85 79
                lda ptr7+1                   ; bc44: a5 7a
                adc #0                       ; bc46: 69 00
                sta ptr7+1                   ; bc48: 85 7a
cod113          lda ram158                   ; bc4a: ad ee 04
                and #%00000010               ; bc4d: 29 02
                beq +                        ; bc4f: f0 1b

                lda #$0f                     ; bc51: a9 0f    (unaccessed)
                clc                          ; bc53: 18       (unaccessed)
                adc arr158,x                 ; bc54: 7d b1 05 (unaccessed)
                tay                          ; bc57: a8       (unaccessed)
                clc                          ; bc58: 18       (unaccessed)
                lda dat44,y                  ; bc59: b9 29 c5 (unaccessed)
                adc #1                       ; bc5c: 69 01    (unaccessed)
                adc ptr7+0                   ; bc5e: 65 79    (unaccessed)
                sta ptr7+0                   ; bc60: 85 79    (unaccessed)
                lda ptr7+1                   ; bc62: a5 7a    (unaccessed)
                adc #0                       ; bc64: 69 00    (unaccessed)
                sta ptr7+1                   ; bc66: 85 7a    (unaccessed)
                lsr ptr7+1                   ; bc68: 46 7a    (unaccessed)
                ror ptr7+0                   ; bc6a: 66 79    (unaccessed)

+               sec                          ; bc6c: 38
                lda arr129,x                 ; bc6d: bd 42 05
                sbc ptr7+0                   ; bc70: e5 79
                sta arr129,x                 ; bc72: 9d 42 05
                lda arr130,x                 ; bc75: bd 46 05
                sbc ptr7+1                   ; bc78: e5 7a
                sta arr130,x                 ; bc7a: 9d 46 05
                rts                          ; bc7d: 60

                clc                          ; bc7e: 18       (unaccessed)
                lda arr129,x                 ; bc7f: bd 42 05 (unaccessed)
                adc ptr7+0                   ; bc82: 65 79    (unaccessed)
                sta arr129,x                 ; bc84: 9d 42 05 (unaccessed)
                lda arr130,x                 ; bc87: bd 46 05 (unaccessed)
                adc ptr7+1                   ; bc8a: 65 7a    (unaccessed)
                sta arr130,x                 ; bc8c: 9d 46 05 (unaccessed)
                rts                          ; bc8f: 60       (unaccessed)

sub61           lda arr162,x                 ; bc90: bd c1 05
                bne +                        ; bc93: d0 06
                lda #0                       ; bc95: a9 00
                sta arr163,x                 ; bc97: 9d c5 05
                rts                          ; bc9a: 60

+               clc                          ; bc9b: 18       (unaccessed)
                adc arr160,x                 ; bc9c: 7d b9 05 (unaccessed)
                and #%00111111               ; bc9f: 29 3f    (unaccessed)
                sta arr160,x                 ; bca1: 9d b9 05 (unaccessed)
                lsr a                        ; bca4: 4a       (unaccessed)
                cmp #$10                     ; bca5: c9 10    (unaccessed)
                bcc +                        ; bca7: 90 17    (unaccessed)
                sec                          ; bca9: 38       (unaccessed)
                sbc #$10                     ; bcaa: e9 10    (unaccessed)
                sta ram78                    ; bcac: 85 75    (unaccessed)
                sec                          ; bcae: 38       (unaccessed)
                lda #$0f                     ; bcaf: a9 0f    (unaccessed)
                sbc ram78                    ; bcb1: e5 75    (unaccessed)
                ora arr161,x                 ; bcb3: 1d bd 05 (unaccessed)
                tay                          ; bcb6: a8       (unaccessed)
                lda dat44,y                  ; bcb7: b9 29 c5 (unaccessed)
                lsr a                        ; bcba: 4a       (unaccessed)
                sta ram78                    ; bcbb: 85 75    (unaccessed)
                jmp cod114                   ; bcbd: 4c ca bc (unaccessed)
+               ora arr161,x                 ; bcc0: 1d bd 05 (unaccessed)
                tay                          ; bcc3: a8       (unaccessed)
                lda dat44,y                  ; bcc4: b9 29 c5 (unaccessed)
                lsr a                        ; bcc7: 4a       (unaccessed)
                sta ram78                    ; bcc8: 85 75    (unaccessed)
cod114          sta arr163,x                 ; bcca: 9d c5 05 (unaccessed)
                rts                          ; bccd: 60       (unaccessed)

sub62           lda arr134,x                 ; bcce: bd 55 05
                beq +                        ; bcd1: f0 1a
                sta ptr8+1                   ; bcd3: 85 7c
                lda arr133,x                 ; bcd5: bd 51 05
                sta ptr8+0                   ; bcd8: 85 7b
                lda arr145,x                 ; bcda: bd 81 05
                cmp #$ff                     ; bcdd: c9 ff
                beq +                        ; bcdf: f0 0c
                jsr sub63                    ; bce1: 20 1b be
                sta arr145,x                 ; bce4: 9d 81 05
                lda ram179                   ; bce7: ad 07 05
                sta arr143,x                 ; bcea: 9d 79 05
+               lda arr136,x                 ; bced: bd 5d 05
                beq cod121                   ; bcf0: f0 7b
                sta ptr8+1                   ; bcf2: 85 7c
                lda arr135,x                 ; bcf4: bd 59 05
                sta ptr8+0                   ; bcf7: 85 7b
                lda arr147,x                 ; bcf9: bd 85 05
                cmp #$ff                     ; bcfc: c9 ff
                beq cod120                   ; bcfe: f0 57
                jsr sub63                    ; bd00: 20 1b be
                sta arr147,x                 ; bd03: 9d 85 05
                lda arr119,x                 ; bd06: bd 12 05
                beq cod121                   ; bd09: f0 62
                ldy #3                       ; bd0b: a0 03
                lda (ptr8),y                 ; bd0d: b1 7b
                beq cod117                   ; bd0f: f0 28
                cmp #1                       ; bd11: c9 01
                beq cod116                   ; bd13: f0 1b

                clc                          ; bd15: 18       (unaccessed)
                lda arr119,x                 ; bd16: bd 12 05 (unaccessed)
                adc ram179                   ; bd19: 6d 07 05 (unaccessed)
                cmp #1                       ; bd1c: c9 01    (unaccessed)
                bcc +                        ; bd1e: 90 08    (unaccessed)
                cmp #$5f                     ; bd20: c9 5f    (unaccessed)
                bcc cod115                   ; bd22: 90 06    (unaccessed)
                lda #$5f                     ; bd24: a9 5f    (unaccessed)
                bne cod115                   ; bd26: d0 02    (unaccessed)
+               lda #1                       ; bd28: a9 01    (unaccessed)
cod115          sta arr119,x                 ; bd2a: 9d 12 05 (unaccessed)
                jmp cod119                   ; bd2d: 4c 4c bd (unaccessed)

cod116          lda ram179                   ; bd30: ad 07 05
                clc                          ; bd33: 18
                adc #1                       ; bd34: 69 01
                jmp cod119                   ; bd36: 4c 4c bd
cod117          clc                          ; bd39: 18
                lda arr119,x                 ; bd3a: bd 12 05
                adc ram179                   ; bd3d: 6d 07 05
                beq +                        ; bd40: f0 02
                bpl cod118                   ; bd42: 10 02
+               lda #1                       ; bd44: a9 01    (unaccessed)
cod118          cmp #$60                     ; bd46: c9 60
                bcc cod119                   ; bd48: 90 02
                lda #$60                     ; bd4a: a9 60    (unaccessed)
cod119          jsr sub51                    ; bd4c: 20 24 b8
                lda #1                       ; bd4f: a9 01
                sta arr151,x                 ; bd51: 9d 95 05
                jmp cod121                   ; bd54: 4c 6d bd
cod120          ldy #3                       ; bd57: a0 03
                lda (ptr8),y                 ; bd59: b1 7b
                beq cod121                   ; bd5b: f0 10
                lda arr151,x                 ; bd5d: bd 95 05
                beq cod121                   ; bd60: f0 0b
                lda arr119,x                 ; bd62: bd 12 05
                jsr sub51                    ; bd65: 20 24 b8
                lda #0                       ; bd68: a9 00
                sta arr151,x                 ; bd6a: 9d 95 05
cod121          lda arr138,x                 ; bd6d: bd 65 05
                beq cod123                   ; bd70: f0 32

                sta ptr8+1                   ; bd72: 85 7c    (unaccessed)
                lda arr137,x                 ; bd74: bd 61 05 (unaccessed)
                sta ptr8+0                   ; bd77: 85 7b    (unaccessed)
                lda arr148,x                 ; bd79: bd 89 05 (unaccessed)
                cmp #$ff                     ; bd7c: c9 ff    (unaccessed)
                beq cod123                   ; bd7e: f0 24    (unaccessed)
                jsr sub63                    ; bd80: 20 1b be (unaccessed)
                sta arr148,x                 ; bd83: 9d 89 05 (unaccessed)
                clc                          ; bd86: 18       (unaccessed)
                lda ram179                   ; bd87: ad 07 05 (unaccessed)
                adc arr128,x                 ; bd8a: 7d 3e 05 (unaccessed)
                sta arr128,x                 ; bd8d: 9d 3e 05 (unaccessed)
                lda ram179                   ; bd90: ad 07 05 (unaccessed)
                bpl +                        ; bd93: 10 04    (unaccessed)
                lda #$ff                     ; bd95: a9 ff    (unaccessed)
                bmi cod122                   ; bd97: 30 02    (unaccessed)
+               lda #0                       ; bd99: a9 00    (unaccessed)
cod122          adc arr127,x                 ; bd9b: 7d 3a 05 (unaccessed)
                sta arr127,x                 ; bd9e: 9d 3a 05 (unaccessed)
                jsr sub67                    ; bda1: 20 75 c0 (unaccessed)

cod123          lda arr140,x                 ; bda4: bd 6d 05
                beq cod125                   ; bda7: f0 45

                sta ptr8+1                   ; bda9: 85 7c    (unaccessed)
                lda arr139,x                 ; bdab: bd 69 05 (unaccessed)
                sta ptr8+0                   ; bdae: 85 7b    (unaccessed)
                lda arr149,x                 ; bdb0: bd 8d 05 (unaccessed)
                cmp #$ff                     ; bdb3: c9 ff    (unaccessed)
                beq cod125                   ; bdb5: f0 37    (unaccessed)
                jsr sub63                    ; bdb7: 20 1b be (unaccessed)
                sta arr149,x                 ; bdba: 9d 8d 05 (unaccessed)
                lda ram179                   ; bdbd: ad 07 05 (unaccessed)
                sta ptr7+0                   ; bdc0: 85 79    (unaccessed)
                rol a                        ; bdc2: 2a       (unaccessed)
                bcc +                        ; bdc3: 90 07    (unaccessed)
                lda #$ff                     ; bdc5: a9 ff    (unaccessed)
                sta ptr7+1                   ; bdc7: 85 7a    (unaccessed)
                jmp cod124                   ; bdc9: 4c d0 bd (unaccessed)
+               lda #0                       ; bdcc: a9 00    (unaccessed)
                sta ptr7+1                   ; bdce: 85 7a    (unaccessed)
cod124          ldy #4                       ; bdd0: a0 04    (unaccessed)
-               clc                          ; bdd2: 18       (unaccessed)
                rol ptr7+0                   ; bdd3: 26 79    (unaccessed)
                rol ptr7+1                   ; bdd5: 26 7a    (unaccessed)
                dey                          ; bdd7: 88       (unaccessed)
                bne -                        ; bdd8: d0 f8    (unaccessed)
                clc                          ; bdda: 18       (unaccessed)
                lda ptr7+0                   ; bddb: a5 79    (unaccessed)
                adc arr128,x                 ; bddd: 7d 3e 05 (unaccessed)
                sta arr128,x                 ; bde0: 9d 3e 05 (unaccessed)
                lda ptr7+1                   ; bde3: a5 7a    (unaccessed)
                adc arr127,x                 ; bde5: 7d 3a 05 (unaccessed)
                sta arr127,x                 ; bde8: 9d 3a 05 (unaccessed)
                jsr sub67                    ; bdeb: 20 75 c0 (unaccessed)

cod125          lda arr142,x                 ; bdee: bd 75 05
                beq +                        ; bdf1: f0 27

                sta ptr8+1                   ; bdf3: 85 7c    (unaccessed)
                lda arr141,x                 ; bdf5: bd 71 05 (unaccessed)
                sta ptr8+0                   ; bdf8: 85 7b    (unaccessed)
                lda arr150,x                 ; bdfa: bd 91 05 (unaccessed)
                cmp #$ff                     ; bdfd: c9 ff    (unaccessed)
                beq +                        ; bdff: f0 19    (unaccessed)
                jsr sub63                    ; be01: 20 1b be (unaccessed)
                sta arr150,x                 ; be04: 9d 91 05 (unaccessed)
                lda ram179                   ; be07: ad 07 05 (unaccessed)
                pha                          ; be0a: 48       (unaccessed)
                lda arr144,x                 ; be0b: bd 7d 05 (unaccessed)
                and #%11110000               ; be0e: 29 f0    (unaccessed)
                sta arr144,x                 ; be10: 9d 7d 05 (unaccessed)
                pla                          ; be13: 68       (unaccessed)
                ora arr144,x                 ; be14: 1d 7d 05 (unaccessed)
                sta arr144,x                 ; be17: 9d 7d 05 (unaccessed)

+               rts                          ; be1a: 60
sub63           clc                          ; be1b: 18
                adc #4                       ; be1c: 69 04
                tay                          ; be1e: a8
                lda (ptr8),y                 ; be1f: b1 7b
                sta ram179                   ; be21: 8d 07 05
                dey                          ; be24: 88
                dey                          ; be25: 88
                dey                          ; be26: 88
                tya                          ; be27: 98
                ldy #0                       ; be28: a0 00
                cmp (ptr8),y                 ; be2a: d1 7b
                beq +                        ; be2c: f0 07
                ldy #2                       ; be2e: a0 02
                cmp (ptr8),y                 ; be30: d1 7b
                beq cod127                   ; be32: f0 1d
                rts                          ; be34: 60
+               iny                          ; be35: c8
                lda (ptr8),y                 ; be36: b1 7b
                cmp #$ff                     ; be38: c9 ff
                bne cod126                   ; be3a: d0 01
                rts                          ; be3c: 60
cod126          pha                          ; be3d: 48
                lda arr123,x                 ; be3e: bd 26 05
                bne +                        ; be41: d0 02
                pla                          ; be43: 68
                rts                          ; be44: 60

+               ldy #2                       ; be45: a0 02    (unaccessed)
                lda (ptr8),y                 ; be47: b1 7b    (unaccessed)
                bne +                        ; be49: d0 02    (unaccessed)
                pla                          ; be4b: 68       (unaccessed)
                rts                          ; be4c: 60       (unaccessed)
+               pla                          ; be4d: 68       (unaccessed)
                lda #$ff                     ; be4e: a9 ff    (unaccessed)
                rts                          ; be50: 60       (unaccessed)
cod127          sta ram78                    ; be51: 85 75    (unaccessed)
                lda arr123,x                 ; be53: bd 26 05 (unaccessed)
                bne +                        ; be56: d0 0d    (unaccessed)
                dey                          ; be58: 88       (unaccessed)
                lda (ptr8),y                 ; be59: b1 7b    (unaccessed)
                cmp #$ff                     ; be5b: c9 ff    (unaccessed)
                bne cod126                   ; be5d: d0 de    (unaccessed)
                lda ram78                    ; be5f: a5 75    (unaccessed)
                sec                          ; be61: 38       (unaccessed)
                sbc #1                       ; be62: e9 01    (unaccessed)
                rts                          ; be64: 60       (unaccessed)
+               lda ram78                    ; be65: a5 75    (unaccessed)
                rts                          ; be67: 60       (unaccessed)
sub64           tya                          ; be68: 98       (unaccessed)
                pha                          ; be69: 48       (unaccessed)
                lda arr134,x                 ; be6a: bd 55 05 (unaccessed)
                beq +                        ; be6d: f0 13    (unaccessed)
                sta ptr8+1                   ; be6f: 85 7c    (unaccessed)
                lda arr133,x                 ; be71: bd 51 05 (unaccessed)
                sta ptr8+0                   ; be74: 85 7b    (unaccessed)
                ldy #2                       ; be76: a0 02    (unaccessed)
                lda (ptr8),y                 ; be78: b1 7b    (unaccessed)
                beq +                        ; be7a: f0 06    (unaccessed)
                sec                          ; be7c: 38       (unaccessed)
                sbc #1                       ; be7d: e9 01    (unaccessed)
                sta arr145,x                 ; be7f: 9d 81 05 (unaccessed)
+               lda arr136,x                 ; be82: bd 5d 05 (unaccessed)
                beq +                        ; be85: f0 13    (unaccessed)
                sta ptr8+1                   ; be87: 85 7c    (unaccessed)
                lda arr135,x                 ; be89: bd 59 05 (unaccessed)
                sta ptr8+0                   ; be8c: 85 7b    (unaccessed)
                ldy #2                       ; be8e: a0 02    (unaccessed)
                lda (ptr8),y                 ; be90: b1 7b    (unaccessed)
                beq +                        ; be92: f0 06    (unaccessed)
                sec                          ; be94: 38       (unaccessed)
                sbc #1                       ; be95: e9 01    (unaccessed)
                sta arr147,x                 ; be97: 9d 85 05 (unaccessed)
+               lda arr138,x                 ; be9a: bd 65 05 (unaccessed)
                beq +                        ; be9d: f0 13    (unaccessed)
                sta ptr8+1                   ; be9f: 85 7c    (unaccessed)
                lda arr137,x                 ; bea1: bd 61 05 (unaccessed)
                sta ptr8+0                   ; bea4: 85 7b    (unaccessed)
                ldy #2                       ; bea6: a0 02    (unaccessed)
                lda (ptr8),y                 ; bea8: b1 7b    (unaccessed)
                beq +                        ; beaa: f0 06    (unaccessed)
                sec                          ; beac: 38       (unaccessed)
                sbc #1                       ; bead: e9 01    (unaccessed)
                sta arr148,x                 ; beaf: 9d 89 05 (unaccessed)
+               lda arr140,x                 ; beb2: bd 6d 05 (unaccessed)
                beq +                        ; beb5: f0 13    (unaccessed)
                sta ptr8+1                   ; beb7: 85 7c    (unaccessed)
                lda arr139,x                 ; beb9: bd 69 05 (unaccessed)
                sta ptr8+0                   ; bebc: 85 7b    (unaccessed)
                ldy #2                       ; bebe: a0 02    (unaccessed)
                lda (ptr8),y                 ; bec0: b1 7b    (unaccessed)
                beq +                        ; bec2: f0 06    (unaccessed)
                sec                          ; bec4: 38       (unaccessed)
                sbc #1                       ; bec5: e9 01    (unaccessed)
                sta arr149,x                 ; bec7: 9d 8d 05 (unaccessed)
+               lda arr142,x                 ; beca: bd 75 05 (unaccessed)
                beq +                        ; becd: f0 13    (unaccessed)
                sta ptr8+1                   ; becf: 85 7c    (unaccessed)
                lda arr141,x                 ; bed1: bd 71 05 (unaccessed)
                sta ptr8+0                   ; bed4: 85 7b    (unaccessed)
                ldy #2                       ; bed6: a0 02    (unaccessed)
                lda (ptr8),y                 ; bed8: b1 7b    (unaccessed)
                beq +                        ; beda: f0 06    (unaccessed)
                sec                          ; bedc: 38       (unaccessed)
                sbc #1                       ; bedd: e9 01    (unaccessed)
                sta arr150,x                 ; bedf: 9d 91 05 (unaccessed)
+               pla                          ; bee2: 68       (unaccessed)
                tay                          ; bee3: a8       (unaccessed)
                rts                          ; bee4: 60       (unaccessed)

sub65           lda #0                       ; bee5: a9 00
                sta arr145,x                 ; bee7: 9d 81 05
                sta arr147,x                 ; beea: 9d 85 05
                sta arr148,x                 ; beed: 9d 89 05
                sta arr149,x                 ; bef0: 9d 8d 05
                sta arr150,x                 ; bef3: 9d 91 05
                rts                          ; bef6: 60
sub66           sta ram80                    ; bef7: 85 77
                sty ram78                    ; bef9: 84 75
                ldy #0                       ; befb: a0 00
                clc                          ; befd: 18
                adc ram156                   ; befe: 6d ec 04
                sta ptr7+0                   ; bf01: 85 79
                tya                          ; bf03: 98
                adc ram157                   ; bf04: 6d ed 04
                sta ptr7+1                   ; bf07: 85 7a
                clc                          ; bf09: 18
                lda (ptr7),y                 ; bf0a: b1 79
                adc ram58                    ; bf0c: 65 5e
                sta ptr8+0                   ; bf0e: 85 7b
                iny                          ; bf10: c8
                lda (ptr7),y                 ; bf11: b1 79
                adc arr34                    ; bf13: 65 5f
                sta ptr8+1                   ; bf15: 85 7c
                lda dat43,x                  ; bf17: bd a4 c3
                tay                          ; bf1a: a8
                lda dat39,y                  ; bf1b: b9 2b bf
                sta ptr7+0                   ; bf1e: 85 79
                iny                          ; bf20: c8
                lda dat39,y                  ; bf21: b9 2b bf
                sta ptr7+1                   ; bf24: 85 7a
                ldy #0                       ; bf26: a0 00
                jmp (ptr7)                   ; bf28: 6c 79 00

dat39           hex 37 bf                    ; bf2b
                hex 37 bf 75 c0 75 c0 37 bf  ; bf2d (unaccessed)
                hex 75 c0                    ; bf35 (unaccessed)

                lda (ptr8),y                 ; bf37: b1 7b
                sta ram80                    ; bf39: 85 77
                iny                          ; bf3b: c8
                ror ram80                    ; bf3c: 66 77
                bcc cod128                   ; bf3e: 90 32
                clc                          ; bf40: 18
                lda (ptr8),y                 ; bf41: b1 7b
                adc ram58                    ; bf43: 65 5e
                sta ptr7+0                   ; bf45: 85 79
                iny                          ; bf47: c8
                lda (ptr8),y                 ; bf48: b1 7b
                adc arr34                    ; bf4a: 65 5f
                sta ptr7+1                   ; bf4c: 85 7a
                iny                          ; bf4e: c8
                lda ptr7+0                   ; bf4f: a5 79
                cmp arr133,x                 ; bf51: dd 51 05
                bne +                        ; bf54: d0 0a
                lda ptr7+1                   ; bf56: a5 7a
                cmp arr134,x                 ; bf58: dd 55 05
                bne +                        ; bf5b: d0 03
                jmp cod129                   ; bf5d: 4c 7a bf
+               lda ptr7+0                   ; bf60: a5 79
                sta arr133,x                 ; bf62: 9d 51 05
                lda ptr7+1                   ; bf65: a5 7a
                sta arr134,x                 ; bf67: 9d 55 05
                lda #0                       ; bf6a: a9 00
                sta arr145,x                 ; bf6c: 9d 81 05
                jmp cod129                   ; bf6f: 4c 7a bf
cod128          lda #0                       ; bf72: a9 00
                sta arr133,x                 ; bf74: 9d 51 05
                sta arr134,x                 ; bf77: 9d 55 05
cod129          ror ram80                    ; bf7a: 66 77
                bcc cod130                   ; bf7c: 90 32
                clc                          ; bf7e: 18
                lda (ptr8),y                 ; bf7f: b1 7b
                adc ram58                    ; bf81: 65 5e
                sta ptr7+0                   ; bf83: 85 79
                iny                          ; bf85: c8
                lda (ptr8),y                 ; bf86: b1 7b
                adc arr34                    ; bf88: 65 5f
                sta ptr7+1                   ; bf8a: 85 7a
                iny                          ; bf8c: c8
                lda ptr7+0                   ; bf8d: a5 79
                cmp arr135,x                 ; bf8f: dd 59 05
                bne +                        ; bf92: d0 0a
                lda ptr7+1                   ; bf94: a5 7a
                cmp arr136,x                 ; bf96: dd 5d 05
                bne +                        ; bf99: d0 03
                jmp cod131                   ; bf9b: 4c b8 bf
+               lda ptr7+0                   ; bf9e: a5 79
                sta arr135,x                 ; bfa0: 9d 59 05
                lda ptr7+1                   ; bfa3: a5 7a
                sta arr136,x                 ; bfa5: 9d 5d 05
                lda #0                       ; bfa8: a9 00
                sta arr147,x                 ; bfaa: 9d 85 05
                jmp cod131                   ; bfad: 4c b8 bf
cod130          lda #0                       ; bfb0: a9 00
                sta arr135,x                 ; bfb2: 9d 59 05
                sta arr136,x                 ; bfb5: 9d 5d 05
cod131          ror ram80                    ; bfb8: 66 77
                bcc cod132                   ; bfba: 90 32

                clc                          ; bfbc: 18       (unaccessed)
                lda (ptr8),y                 ; bfbd: b1 7b    (unaccessed)
                adc ram58                    ; bfbf: 65 5e    (unaccessed)
                sta ptr7+0                   ; bfc1: 85 79    (unaccessed)
                iny                          ; bfc3: c8       (unaccessed)
                lda (ptr8),y                 ; bfc4: b1 7b    (unaccessed)
                adc arr34                    ; bfc6: 65 5f    (unaccessed)
                sta ptr7+1                   ; bfc8: 85 7a    (unaccessed)
                iny                          ; bfca: c8       (unaccessed)
                lda ptr7+0                   ; bfcb: a5 79    (unaccessed)
                cmp arr137,x                 ; bfcd: dd 61 05 (unaccessed)
                bne +                        ; bfd0: d0 0a    (unaccessed)
                lda ptr7+1                   ; bfd2: a5 7a    (unaccessed)
                cmp arr138,x                 ; bfd4: dd 65 05 (unaccessed)
                bne +                        ; bfd7: d0 03    (unaccessed)
                jmp cod133                   ; bfd9: 4c f6 bf (unaccessed)
+               lda ptr7+0                   ; bfdc: a5 79    (unaccessed)
                sta arr137,x                 ; bfde: 9d 61 05 (unaccessed)
                lda ptr7+1                   ; bfe1: a5 7a    (unaccessed)
                sta arr138,x                 ; bfe3: 9d 65 05 (unaccessed)
                lda #0                       ; bfe6: a9 00    (unaccessed)
                sta arr148,x                 ; bfe8: 9d 89 05 (unaccessed)
                jmp cod133                   ; bfeb: 4c f6 bf (unaccessed)

cod132          lda #0                       ; bfee: a9 00
                sta arr137,x                 ; bff0: 9d 61 05
                sta arr138,x                 ; bff3: 9d 65 05
cod133          ror ram80                    ; bff6: 66 77
                bcc cod134                   ; bff8: 90 32

                clc                          ; bffa: 18       (unaccessed)
                lda (ptr8),y                 ; bffb: b1 7b    (unaccessed)
                adc ram58                    ; bffd: 65 5e    (unaccessed)
                sta ptr7+0                   ; bfff: 85 79    (unaccessed)
                iny                          ; c001: c8       (unaccessed)
                lda (ptr8),y                 ; c002: b1 7b    (unaccessed)
                adc arr34                    ; c004: 65 5f    (unaccessed)
                sta ptr7+1                   ; c006: 85 7a    (unaccessed)
                iny                          ; c008: c8       (unaccessed)
                lda ptr7+0                   ; c009: a5 79    (unaccessed)
                cmp arr139,x                 ; c00b: dd 69 05 (unaccessed)
                bne +                        ; c00e: d0 0a    (unaccessed)
                lda ptr7+1                   ; c010: a5 7a    (unaccessed)
                cmp arr140,x                 ; c012: dd 6d 05 (unaccessed)
                bne +                        ; c015: d0 03    (unaccessed)
                jmp cod135                   ; c017: 4c 34 c0 (unaccessed)
+               lda ptr7+0                   ; c01a: a5 79    (unaccessed)
                sta arr139,x                 ; c01c: 9d 69 05 (unaccessed)
                lda ptr7+1                   ; c01f: a5 7a    (unaccessed)
                sta arr140,x                 ; c021: 9d 6d 05 (unaccessed)
                lda #0                       ; c024: a9 00    (unaccessed)
                sta arr149,x                 ; c026: 9d 8d 05 (unaccessed)
                jmp cod135                   ; c029: 4c 34 c0 (unaccessed)

cod134          lda #0                       ; c02c: a9 00
                sta arr139,x                 ; c02e: 9d 69 05
                sta arr140,x                 ; c031: 9d 6d 05
cod135          ror ram80                    ; c034: 66 77
                bcc cod136                   ; c036: 90 32

                clc                          ; c038: 18       (unaccessed)
                lda (ptr8),y                 ; c039: b1 7b    (unaccessed)
                adc ram58                    ; c03b: 65 5e    (unaccessed)
                sta ptr7+0                   ; c03d: 85 79    (unaccessed)
                iny                          ; c03f: c8       (unaccessed)
                lda (ptr8),y                 ; c040: b1 7b    (unaccessed)
                adc arr34                    ; c042: 65 5f    (unaccessed)
                sta ptr7+1                   ; c044: 85 7a    (unaccessed)
                iny                          ; c046: c8       (unaccessed)
                lda ptr7+0                   ; c047: a5 79    (unaccessed)
                cmp arr141,x                 ; c049: dd 71 05 (unaccessed)
                bne +                        ; c04c: d0 0a    (unaccessed)
                lda ptr7+1                   ; c04e: a5 7a    (unaccessed)
                cmp arr142,x                 ; c050: dd 75 05 (unaccessed)
                bne +                        ; c053: d0 03    (unaccessed)
                jmp cod137                   ; c055: 4c 72 c0 (unaccessed)
+               lda ptr7+0                   ; c058: a5 79    (unaccessed)
                sta arr141,x                 ; c05a: 9d 71 05 (unaccessed)
                lda ptr7+1                   ; c05d: a5 7a    (unaccessed)
                sta arr142,x                 ; c05f: 9d 75 05 (unaccessed)
                lda #0                       ; c062: a9 00    (unaccessed)
                sta arr150,x                 ; c064: 9d 91 05 (unaccessed)
                jmp cod137                   ; c067: 4c 72 c0 (unaccessed)

cod136          lda #0                       ; c06a: a9 00
                sta arr141,x                 ; c06c: 9d 71 05
                sta arr142,x                 ; c06f: 9d 75 05
cod137          ldy ram78                    ; c072: a4 75
                rts                          ; c074: 60
sub67           lda dat43,x                  ; c075: bd a4 c3
                tay                          ; c078: a8
                lda dat40,y                  ; c079: b9 89 c0
                sta ptr7+0                   ; c07c: 85 79
                iny                          ; c07e: c8
                lda dat40,y                  ; c07f: b9 89 c0
                sta ptr7+1                   ; c082: 85 7a
                ldy #0                       ; c084: a0 00
                jmp (ptr7)                   ; c086: 6c 79 00

                ; a jump table?
dat40           dw $c096                     ; c089
                dw $c0b3                     ; c08b (unaccessed)
                dw $c095                     ; c08d (unaccessed)
                dw $c0b3                     ; c08f (unaccessed)
                dw $c096                     ; c091 (unaccessed)
                dw $c095                     ; c093 (unaccessed)

                rts                          ; c095 (unaccessed)

                lda arr127,x                 ; c096: bd 3a 05
                bmi cod138                   ; c099: 30 0f
                cmp #8                       ; c09b: c9 08
                bcc +                        ; c09d: 90 0a
                lda #7                       ; c09f: a9 07    (unaccessed)
                sta arr127,x                 ; c0a1: 9d 3a 05 (unaccessed)
                lda #$ff                     ; c0a4: a9 ff    (unaccessed)
                sta arr128,x                 ; c0a6: 9d 3e 05 (unaccessed)
+               rts                          ; c0a9: 60

cod138          lda #0                       ; c0aa: a9 00    (unaccessed)
                sta arr128,x                 ; c0ac: 9d 3e 05 (unaccessed)
                sta arr127,x                 ; c0af: 9d 3a 05 (unaccessed)
                rts                          ; c0b2: 60       (unaccessed)
                lda arr127,x                 ; c0b3: bd 3a 05 (unaccessed)
                bmi cod139                   ; c0b6: 30 0f    (unaccessed)
                cmp #$10                     ; c0b8: c9 10    (unaccessed)
                bcc +                        ; c0ba: 90 0a    (unaccessed)
                lda #$0f                     ; c0bc: a9 0f    (unaccessed)
                sta arr127,x                 ; c0be: 9d 3a 05 (unaccessed)
                lda #$ff                     ; c0c1: a9 ff    (unaccessed)
                sta arr128,x                 ; c0c3: 9d 3e 05 (unaccessed)
+               rts                          ; c0c6: 60       (unaccessed)
cod139          lda #0                       ; c0c7: a9 00    (unaccessed)
                sta arr128,x                 ; c0c9: 9d 3e 05 (unaccessed)
                sta arr127,x                 ; c0cc: 9d 3a 05 (unaccessed)
                rts                          ; c0cf: 60       (unaccessed)

sub68           lda ram165                   ; c0d0: ad f7 04
                bne cod140                   ; c0d3: d0 11
                lda #0                       ; c0d5: a9 00    (unaccessed)
                sta snd_chn                  ; c0d7: 8d 15 40 (unaccessed)
                rts                          ; c0da: 60       (unaccessed)
sub69           lda #$c0                     ; c0db: a9 c0
                sta joypad2                  ; c0dd: 8d 17 40
                lda #$40                     ; c0e0: a9 40
                sta joypad2                  ; c0e2: 8d 17 40
                rts                          ; c0e5: 60
cod140          lda ram159                   ; c0e6: ad ef 04
                and #%00000001               ; c0e9: 29 01
                bne +                        ; c0eb: d0 03
                jmp cod143                   ; c0ed: 4c 76 c1 (unaccessed)
+               lda arr119                   ; c0f0: ad 12 05
                beq cod141                   ; c0f3: f0 69
                lda arr120                   ; c0f5: ad 17 05
                asl a                        ; c0f8: 0a
                beq cod141                   ; c0f9: f0 63
                and #%11110000               ; c0fb: 29 f0
                sta ram78                    ; c0fd: 85 75
                lda arr143                   ; c0ff: ad 79 05
                beq cod141                   ; c102: f0 5a
                ora ram78                    ; c104: 05 75
                tax                          ; c106: aa
                lda $c29f,x                  ; c107: bd 9f c2
                sec                          ; c10a: 38
                sbc arr163                   ; c10b: ed c5 05
                bpl +                        ; c10e: 10 02
                lda #0                       ; c110: a9 00    (unaccessed)
+               bne +                        ; c112: d0 07
                lda arr120                   ; c114: ad 17 05
                beq +                        ; c117: f0 02
                lda #1                       ; c119: a9 01
+               pha                          ; c11b: 48
                lda arr144                   ; c11c: ad 7d 05
                and #%00000011               ; c11f: 29 03
                tax                          ; c121: aa
                pla                          ; c122: 68
                ora dat41,x                  ; c123: 1d 9b c2
                ora #%00110000               ; c126: 09 30
                sta arr35                    ; c128: 85 60
                lda arr130                   ; c12a: ad 46 05
                and #%11111000               ; c12d: 29 f8
                beq +                        ; c12f: f0 0a
                lda #7                       ; c131: a9 07    (unaccessed)
                sta arr130                   ; c133: 8d 46 05 (unaccessed)
                lda #$ff                     ; c136: a9 ff    (unaccessed)
                sta arr129                   ; c138: 8d 42 05 (unaccessed)
+               lda arr132                   ; c13b: ad 4f 05
                beq cod142                   ; c13e: f0 25

                and #%10000000               ; c140: 29 80    (unaccessed)
                beq cod143                   ; c142: f0 32    (unaccessed)
                lda arr132                   ; c144: ad 4f 05 (unaccessed)
                sta ram59                    ; c147: 85 61    (unaccessed)
                and #%01111111               ; c149: 29 7f    (unaccessed)
                sta arr132                   ; c14b: 8d 4f 05 (unaccessed)
                jsr sub69                    ; c14e: 20 db c0 (unaccessed)
                lda arr129                   ; c151: ad 42 05 (unaccessed)
                sta ram60                    ; c154: 85 62    (unaccessed)
                lda arr130                   ; c156: ad 46 05 (unaccessed)
                sta ram61                    ; c159: 85 63    (unaccessed)
                jmp cod143                   ; c15b: 4c 76 c1 (unaccessed)

cod141          lda #$30                     ; c15e: a9 30
                sta arr35                    ; c160: 85 60
                jmp cod143                   ; c162: 4c 76 c1
cod142          lda #8                       ; c165: a9 08
                sta ram59                    ; c167: 85 61
                jsr sub69                    ; c169: 20 db c0
                lda arr129                   ; c16c: ad 42 05
                sta ram60                    ; c16f: 85 62
                lda arr130                   ; c171: ad 46 05
                sta ram61                    ; c174: 85 63
cod143          lda ram159                   ; c176: ad ef 04
                and #%00000010               ; c179: 29 02
                bne +                        ; c17b: d0 03
                jmp cod146                   ; c17d: 4c 06 c2 (unaccessed)
+               lda ram180                   ; c180: ad 13 05
                beq cod144                   ; c183: f0 69
                lda ram183                   ; c185: ad 18 05
                asl a                        ; c188: 0a
                beq cod144                   ; c189: f0 63
                and #%11110000               ; c18b: 29 f0
                sta ram78                    ; c18d: 85 75
                lda ram193                   ; c18f: ad 7a 05
                beq cod144                   ; c192: f0 5a
                ora ram78                    ; c194: 05 75
                tax                          ; c196: aa
                lda $c29f,x                  ; c197: bd 9f c2
                sec                          ; c19a: 38
                sbc ram198                   ; c19b: ed c6 05
                bpl +                        ; c19e: 10 02
                lda #0                       ; c1a0: a9 00    (unaccessed)
+               bne +                        ; c1a2: d0 07
                lda ram183                   ; c1a4: ad 18 05 (unaccessed)
                beq +                        ; c1a7: f0 02    (unaccessed)
                lda #1                       ; c1a9: a9 01    (unaccessed)
+               pha                          ; c1ab: 48
                lda ram196                   ; c1ac: ad 7e 05
                and #%00000011               ; c1af: 29 03
                tax                          ; c1b1: aa
                pla                          ; c1b2: 68
                ora dat41,x                  ; c1b3: 1d 9b c2
                ora #%00110000               ; c1b6: 09 30
                sta ram62                    ; c1b8: 85 64
                lda ram190                   ; c1ba: ad 47 05
                and #%11111000               ; c1bd: 29 f8
                beq +                        ; c1bf: f0 0a
                lda #7                       ; c1c1: a9 07    (unaccessed)
                sta ram190                   ; c1c3: 8d 47 05 (unaccessed)
                lda #$ff                     ; c1c6: a9 ff    (unaccessed)
                sta ram187                   ; c1c8: 8d 43 05 (unaccessed)
+               lda ram192                   ; c1cb: ad 50 05
                beq cod145                   ; c1ce: f0 25

                and #%10000000               ; c1d0: 29 80    (unaccessed)
                beq cod146                   ; c1d2: f0 32    (unaccessed)
                lda ram192                   ; c1d4: ad 50 05 (unaccessed)
                sta ram63                    ; c1d7: 85 65    (unaccessed)
                and #%01111111               ; c1d9: 29 7f    (unaccessed)
                sta ram192                   ; c1db: 8d 50 05 (unaccessed)
                jsr sub69                    ; c1de: 20 db c0 (unaccessed)
                lda ram187                   ; c1e1: ad 43 05 (unaccessed)
                sta ram64                    ; c1e4: 85 66    (unaccessed)
                lda ram190                   ; c1e6: ad 47 05 (unaccessed)
                sta arr36                    ; c1e9: 85 67    (unaccessed)
                jmp cod146                   ; c1eb: 4c 06 c2 (unaccessed)

cod144          lda #$30                     ; c1ee: a9 30
                sta ram62                    ; c1f0: 85 64
                jmp cod146                   ; c1f2: 4c 06 c2
cod145          lda #8                       ; c1f5: a9 08
                sta ram63                    ; c1f7: 85 65
                jsr sub69                    ; c1f9: 20 db c0
                lda ram187                   ; c1fc: ad 43 05
                sta ram64                    ; c1ff: 85 66
                lda ram190                   ; c201: ad 47 05
                sta arr36                    ; c204: 85 67
cod146          lda ram159                   ; c206: ad ef 04
                and #%00000100               ; c209: 29 04
                beq cod148                   ; c20b: f0 35
                lda ram194                   ; c20d: ad 7b 05
                beq cod147                   ; c210: f0 2c
                lda ram184                   ; c212: ad 19 05
                beq cod147                   ; c215: f0 27
                lda ram181                   ; c217: ad 14 05
                beq cod147                   ; c21a: f0 22
                lda #$81                     ; c21c: a9 81
                sta ram65                    ; c21e: 85 68
                lda ram191                   ; c220: ad 48 05
                and #%11111000               ; c223: 29 f8
                beq +                        ; c225: f0 0a
                lda #7                       ; c227: a9 07    (unaccessed)
                sta ram191                   ; c229: 8d 48 05 (unaccessed)
                lda #$ff                     ; c22c: a9 ff    (unaccessed)
                sta ram188                   ; c22e: 8d 44 05 (unaccessed)
+               lda ram188                   ; c231: ad 44 05
                sta ram67                    ; c234: 85 6a
                lda ram191                   ; c236: ad 48 05
                sta ram68                    ; c239: 85 6b
                jmp cod148                   ; c23b: 4c 42 c2
cod147          lda #0                       ; c23e: a9 00
                sta ram65                    ; c240: 85 68
cod148          lda ram159                   ; c242: ad ef 04
                and #%00001000               ; c245: 29 08
                beq cod150                   ; c247: f0 51
                lda ram182                   ; c249: ad 15 05
                beq cod149                   ; c24c: f0 48
                lda ram185                   ; c24e: ad 1a 05
                asl a                        ; c251: 0a
                beq cod149                   ; c252: f0 42
                and #%11110000               ; c254: 29 f0
                sta ram78                    ; c256: 85 75
                lda ram195                   ; c258: ad 7c 05
                beq cod149                   ; c25b: f0 39
                ora ram78                    ; c25d: 05 75
                tax                          ; c25f: aa
                lda $c29f,x                  ; c260: bd 9f c2
                sec                          ; c263: 38
                sbc ram199                   ; c264: ed c8 05
                bpl +                        ; c267: 10 02
                lda #0                       ; c269: a9 00    (unaccessed)
+               bne +                        ; c26b: d0 07
                lda ram185                   ; c26d: ad 1a 05
                beq +                        ; c270: f0 02
                lda #1                       ; c272: a9 01
+               ora #%00110000               ; c274: 09 30
                sta ram69                    ; c276: 85 6c
                lda #0                       ; c278: a9 00
                sta ram70                    ; c27a: 85 6d
                lda ram197                   ; c27c: ad 80 05
                ror a                        ; c27f: 6a
                ror a                        ; c280: 6a
                and #%10000000               ; c281: 29 80
                sta ram78                    ; c283: 85 75
                lda ram189                   ; c285: ad 45 05
                and #%00001111               ; c288: 29 0f
                eor #%00001111               ; c28a: 49 0f
                ora ram78                    ; c28c: 05 75
                sta ram71                    ; c28e: 85 6e
                lda #0                       ; c290: a9 00
                sta ram72                    ; c292: 85 6f
                beq cod150                   ; c294: f0 04
cod149          lda #$30                     ; c296: a9 30
                sta ram69                    ; c298: 85 6c
cod150          rts                          ; c29a: 60

dat41           hex 00 40 80                 ; c29b
                hex c0 00 00 00 00 00 00 00  ; c29e (unaccessed)
                hex 00 00 00 00 00 00 00 00  ; c2a6 (unaccessed)
                hex 00                       ; c2ae
                hex 00 01 01 01 01 01 01 01  ; c2af (unaccessed)
                hex 01 01 01 01 01 01 01     ; c2b7 (unaccessed)
                hex 01                       ; c2be
                hex 00 01 01 01 01 01 01 01  ; c2bf (unaccessed)
                hex 01 01 01 01 01 01 01     ; c2c7 (unaccessed)
                hex 02                       ; c2ce
                hex 00 01 01 01 01 01 01 01  ; c2cf (unaccessed)
                hex 01 01 02                 ; c2d7 (unaccessed)
                hex 02 02 02 02              ; c2da (unaccessed)
                hex 03                       ; c2de
                hex 00 01 01 01 01 01 01 01  ; c2df (unaccessed)
                hex 02 02 02 02 03 03 03     ; c2e7 (unaccessed)
                hex 04                       ; c2ee
                hex 00                       ; c2ef (unaccessed)
                hex 01 01                    ; c2f0
                hex 01                       ; c2f2 (unaccessed)
                hex 01                       ; c2f3
                hex 01 02 02 02 03           ; c2f4 (unaccessed)
                hex 03                       ; c2f9
                hex 03                       ; c2fa (unaccessed)
                hex 04                       ; c2fb
                hex 04 04                    ; c2fc (unaccessed)
                hex 05                       ; c2fe
                hex 00 01 01 01 01 02 02 02  ; c2ff (unaccessed)
                hex 03 03 04 04 04 05 05 06  ; c307 (unaccessed)
                hex 00                       ; c30f (unaccessed)
                hex 01 01 01 01 02 02        ; c310
                hex 03                       ; c316 (unaccessed)
                hex 03                       ; c317
                hex 04                       ; c318 (unaccessed)
                hex 04                       ; c319
                hex 05                       ; c31a (unaccessed)
                hex 05                       ; c31b
                hex 06 06 07 00 01 01 01 02  ; c31c (unaccessed)
                hex 02 03 03 04 04 05 05 06  ; c324 (unaccessed)
                hex 06 07 08 00 01 01 01 02  ; c32c (unaccessed)
                hex 03 03 04 04              ; c334 (unaccessed)
                hex 05 06 06 07 07 08 09 00  ; c338 (unaccessed)
                hex 01 01 02 02 03 04 04 05  ; c340
                hex 06                       ; c348 (unaccessed)
                hex 06                       ; c349
                hex 07                       ; c34a (unaccessed)
                hex 08                       ; c34b

                ; c34c-c38f: unaccessed data
                hex 08 09 0a 00 01 01 02 02  ; c34c
                hex 03 04 05 05 06 07 08 08  ; c354
                hex 09 0a 0b 00 01 01 02 03  ; c35c
                hex 04 04 05 06 07 08 08 09  ; c364
                hex 0a 0b 0c 00 01 01 02 03  ; c36c
                hex 04 05 06 06 07 08 09 0a  ; c374
                hex 0b 0c 0d 00 01 01 02 03  ; c37c
                hex 04 05 06 07 08 09 0a 0b  ; c384
                hex 0c 0d 0e 00              ; c38c

                hex 01 02 03 04 05 06        ; c390
                hex 07                       ; c396 (unaccessed)
                hex 08                       ; c397
                hex 09                       ; c398 (unaccessed)
                hex 0a                       ; c399
                hex 0b                       ; c39a (unaccessed)
                hex 0c                       ; c39b
                hex 0d 0e 0f 01 02 03 04 05  ; c39c (unaccessed)

dat43           hex 00 00 00 00              ; c3a4

                hex 00 5b 0d 9c 0c e6 0b 3b  ; c3a8 (unaccessed)
                hex 0b 9a 0a 01 0a 72 09 ea  ; c3b0 (unaccessed)
                hex 08 6a 08 f1 07 7f 07 13  ; c3b8 (unaccessed)
                hex 07                       ; c3c0 (unaccessed)

                hex ad 06 4d 06 f3 05        ; c3c1
                hex 9d 05                    ; c3c7 (unaccessed)
                hex 4c 05 00 05 b8 04 74 04  ; c3c9
                hex 34 04 f8 03              ; c3d1 (unaccessed)
                hex bf 03 89 03 56 03 26 03  ; c3d5
                hex f9 02 ce 02 a6 02 80 02  ; c3dd
                hex 5c 02 3a 02 1a 02 fb 01  ; c3e5
                hex df 01 c4 01 ab 01 93 01  ; c3ed
                hex 7c 01 67 01 52 01 3f 01  ; c3f5
                hex 2d 01 1c 01 0c 01 fd 00  ; c3fd
                hex ef 00 e1 00 d5 00 c9 00  ; c405
                hex bd 00                    ; c40d
                hex b3 00                    ; c40f (unaccessed)
                hex a9 00                    ; c411
                hex 9f 00                    ; c413 (unaccessed)
                hex 96 00 8e 00              ; c415
                hex 86 00                    ; c419 (unaccessed)
                hex 7e 00                    ; c41b
                hex 77 00                    ; c41d (unaccessed)
                hex 70 00                    ; c41f

                ; c421-c528: unaccessed data
                hex 6a 00 64 00 5e 00 59 00  ; c421
                hex 54 00 4f 00 4b 00 46 00  ; c429
                hex 42 00 3f 00 3b 00 38 00  ; c431
                hex 34 00 31 00 2f 00 2c 00  ; c439
                hex 29 00 27 00 25 00 23 00  ; c441
                hex 21 00 1f 00 1d 00 1b 00  ; c449
                hex 1a 00 18 00 17 00 15 00  ; c451
                hex 14 00 13 00 12 00 11 00  ; c459
                hex 10 00 0f 00 0e 00 0d 00  ; c461
                hex 68 0c b6 0b 0e 0b 6f 0a  ; c469
                hex d9 09 4b 09 c6 08 48 08  ; c471
                hex d1 07 60 07 f6 06 92 06  ; c479
                hex 34 06 db 05 86 05 37 05  ; c481
                hex ec 04 a5 04 62 04 23 04  ; c489
                hex e8 03 b0 03 7b 03 49 03  ; c491
                hex 19 03 ed 02 c3 02 9b 02  ; c499
                hex 75 02 52 02 31 02 11 02  ; c4a1
                hex f3 01 d7 01 bd 01 a4 01  ; c4a9
                hex 8c 01 76 01 61 01 4d 01  ; c4b1
                hex 3a 01 29 01 18 01 08 01  ; c4b9
                hex f9 00 eb 00 de 00 d1 00  ; c4c1
                hex c6 00 ba 00 b0 00 a6 00  ; c4c9
                hex 9d 00 94 00 8b 00 84 00  ; c4d1
                hex 7c 00 75 00 6e 00 68 00  ; c4d9
                hex 62 00 5d 00 57 00 52 00  ; c4e1
                hex 4e 00 49 00 45 00 41 00  ; c4e9
                hex 3e 00 3a 00 37 00 34 00  ; c4f1
                hex 31 00 2e 00 2b 00 29 00  ; c4f9
                hex 26 00 24 00 22 00 20 00  ; c501
                hex 1e 00 1d 00 1b 00 19 00  ; c509
                hex 18 00 16 00 15 00 14 00  ; c511
                hex 13 00 12 00 11 00 10 00  ; c519
                hex 0f 00 0e 00 0d 00 0c 00  ; c521

dat44           ; c529-c578: unaccessed data
                hex 00 00 00 00 00 00 00 00  ; c529
                hex 00 00 00 00 00 00 00 00  ; c531
                hex 00 00 00 00 00 00 01 01  ; c539
                hex 01 01 01 01 01 01 01 01  ; c541
                hex 00 00 00 00 01 01 01 01  ; c549
                hex 02 02 02 02 02 02 02 02  ; c551
                hex 00 00 00 01 01 01 02 02  ; c559
                hex 02 03 03 03 03 03 03 03  ; c561
                hex 00 00 00 01 01 02 02 03  ; c569
                hex 03 03 04 04 04 04 04 04  ; c571

                hex 00 00 01 02 02 03 03 04  ; c579
                hex 04 05 05 06 06 06 06 06  ; c581

                ; c589-c628: unaccessed data
                hex 00 00 01 02 03 04 05 06  ; c589
                hex 07 07 08 08 09 09 09 09  ; c591
                hex 00 01 02 03 04 05 06 07  ; c599
                hex 08 09 09 0a 0b 0b 0b 0b  ; c5a1
                hex 00 01 02 04 05 06 07 08  ; c5a9
                hex 09 0a 0b 0c 0c 0d 0d 0d  ; c5b1
                hex 00 01 03 04 06 08 09 0a  ; c5b9
                hex 0c 0d 0e 0e 0f 10 10 10  ; c5c1
                hex 00 02 04 06 08 0a 0c 0d  ; c5c9
                hex 0f 11 12 13 14 15 15 15  ; c5d1
                hex 00 02 05 08 0b 0e 10 13  ; c5d9
                hex 15 17 18 1a 1b 1c 1d 1d  ; c5e1
                hex 00 04 08 0c 10 14 18 1b  ; c5e9
                hex 1f 22 24 26 28 2a 2b 2b  ; c5f1
                hex 00 06 0c 12 18 1e 23 28  ; c5f9
                hex 2d 31 35 38 3b 3d 3e 3f  ; c601
                hex 00 09 12 1b 24 2d 35 3c  ; c609
                hex 43 4a 4f 54 58 5b 5e 5f  ; c611
                hex 00 0c 18 25 30 3c 47 51  ; c619
                hex 5a 62 6a 70 76 7a 7d 7f  ; c621

                pad $c700, $00               ; c629 (unaccessed)

reset           sei                          ; c700
                ldx #0
                stx ppu_ctrl
                stx ppu_mask
                sta snd_chn
                lda #$40
                sta joypad2
                bit ppu_status
-               bit ppu_status
                bpl -
                cld
-               lda #$ff                     ; c71a: a9 ff
                sta arr70,x                  ; c71c: 9d 00 02
                lda #0                       ; c71f: a9 00
                sta ptr1,x                   ; c721: 95 00
                pha                          ; c723: 48
                sta arr77,x                  ; c724: 9d 00 03
                sta arr96,x                  ; c727: 9d 00 04
                sta arr116,x                 ; c72a: 9d 00 05
                sta arr164,x                 ; c72d: 9d 00 06
                sta arr166,x                 ; c730: 9d 00 07
                inx                          ; c733: e8
                bne -                        ; c734: d0 e4
                bit ptr1+0                   ; c736: 24 00
                stx dmc_raw                  ; c738: 8e 11 40
                stx dmc_len                  ; c73b: 8e 13 40
                dex                          ; c73e: ca
                txs                          ; c73f: 9a
                stx arr61                    ; c740: 8e 10 01
                lda #0                       ; c743: a9 00
                sta dmc_start                ; c745: 8d 12 40
                lda #$4c                     ; c748: a9 4c
                sta ram44                    ; c74a: 85 4b
                bit ptr1+0                   ; c74c: 24 00
                nop                          ; c74e: ea
                nop                          ; c74f: ea
                nop                          ; c750: ea
                nop                          ; c751: ea
                nop                          ; c752: ea
                nop                          ; c753: ea
                lda #$82                     ; c754: a9 82
                sta ptr3+1                   ; c756: 85 26
                lda #$0f                     ; c758: a9 0f
                sta dmc_freq                 ; c75a: 8d 10 40
                nop                          ; c75d: ea
                bit ptr1+0                   ; c75e: 24 00
                lda #$7e                     ; c760: a9 7e
                ldx #$20                     ; c762: a2 20
                jsr sub6                     ; c764: 20 c8 86
                ldx #0                       ; c767: a2 00
cod153          bit ppu_status               ; c769: 2c 02 20
                bmi +                        ; c76c: 30 0b
                ldy #$39                     ; c76e: a0 39
-               dey                          ; c770: 88
                bne -                        ; c771: d0 fd
                bit ptr1+0                   ; c773: 24 00
                inx                          ; c775: e8
                jmp cod153                   ; c776: 4c 69 c7
+               stx ptr1+0                   ; c779: 86 00
                ldy #6                       ; c77b: a0 06
-               lda $c78e,y                  ; c77d: b9 8e c7
                cmp ptr1+0                   ; c780: c5 00
                bcs +                        ; c782: b0 03
                dey                          ; c784: 88       (unaccessed)
                bne -                        ; c785: d0 f6    (unaccessed)
+               lda dat46,y                  ; c787: b9 95 c7
                sta ram5                     ; c78a: 85 10
                jmp cod155                   ; c78c: 4c e9 c7

                hex c5 b6 9f 4f 48           ; c78f (unaccessed)
                hex 3c                       ; c794
dat46           hex 00 02 01 00 02 01        ; c795 (unaccessed)
                hex 00                       ; c79b

sub70           ldx #1                       ; c79c: a2 01
                stx ram19                    ; c79e: 86 2e
                stx joypad1                  ; c7a0: 8e 16 40
                dex                          ; c7a3: ca
                stx joypad1                  ; c7a4: 8e 16 40
-               lda joypad1                  ; c7a7: ad 16 40
                and #%00000011               ; c7aa: 29 03
                cmp #1                       ; c7ac: c9 01
                rol ram19                    ; c7ae: 26 2e
                bcc -                        ; c7b0: 90 f5
                lda ram19                    ; c7b2: a5 2e
                and #%00001010               ; c7b4: 29 0a
                lsr a                        ; c7b6: 4a
                eor #%11111111               ; c7b7: 49 ff
                and ram19                    ; c7b9: 25 2e
                sta ram19                    ; c7bb: 85 2e
                tay                          ; c7bd: a8
                eor ram20                    ; c7be: 45 2f
                and ram19                    ; c7c0: 25 2e
                sta ram19                    ; c7c2: 85 2e
                sty ram20                    ; c7c4: 84 2f
                rts                          ; c7c6: 60
sub71           lda #$ff                     ; c7c7: a9 ff
                ldx #$3c                     ; c7c9: a2 3c
-               sta arr70,x                  ; c7cb: 9d 00 02
                sta arr74,x                  ; c7ce: 9d 40 02
                sta arr75,x                  ; c7d1: 9d 80 02
                sta arr76,x                  ; c7d4: 9d c0 02

                hex cb 04                    ; c7d7 (unaccessed)

                bpl -                        ; c7d9: 10 f0
                lda #$10                     ; c7db: a9 10
                sta ram12                    ; c7dd: 85 23
                rts                          ; c7df: 60
cod154          lda ram11                    ; c7e0: a5 21
                beq cod154                   ; c7e2: f0 fc
                inc ram10                    ; c7e4: e6 20
                jsr sub70                    ; c7e6: 20 9c c7
cod155          lda arr16                    ; c7e9: a5 15
                asl a                        ; c7eb: 0a
                tax                          ; c7ec: aa
                lda dat15,x                  ; c7ed: bd 28 8a
                sta ram45                    ; c7f0: 85 4c
                lda dat16,x                  ; c7f2: bd 29 8a
                sta ram46                    ; c7f5: 85 4d
                jsr ram44                    ; c7f7: 20 4b 00
                lda arr17                    ; c7fa: a5 16
                sta arr16                    ; c7fc: 85 15
                lda arr19                    ; c7fe: a5 18
                sta arr18                    ; c800: 85 17
                lda #0                       ; c802: a9 00
                sta ram11                    ; c804: 85 21
                jmp cod154                   ; c806: 4c e0 c7

nmi             pha                          ; c809
                txa
                pha
                tya
                pha
                lda arr16                    ; c80e: a5 15
                cmp #$0b                     ; c810: c9 0b
                bcc +                        ; c812: 90 36
                lda ppu_status               ; c814: ad 02 20
                and #%01000000               ; c817: 29 40
                ora ram47                    ; c819: 05 4e
                sta ram47                    ; c81b: 85 4e
                beq +                        ; c81d: f0 2b
                lda #0                       ; c81f: a9 00
                sta ram37                    ; c821: 85 44
                lda arr15                    ; c823: a5 14
                ora #%00011110               ; c825: 09 1e
                sta arr15                    ; c827: 85 14
                lda ram36                    ; c829: a5 43
                cmp #$0f                     ; c82b: c9 0f
                bne +                        ; c82d: d0 1b
                lda arr29                    ; c82f: a5 3c
                eor #%00000001               ; c831: 49 01
                sta arr29                    ; c833: 85 3c
                lda #0                       ; c835: a9 00
                sta ram36                    ; c837: 85 43
                lda #$fe                     ; c839: a9 fe
                sta ram140                   ; c83b: 8d 08 02
                lda arr73                    ; c83e: ad 03 02
                ldy ram147                   ; c841: ac 0f 02
                sta ram147                   ; c844: 8d 0f 02
                sty arr73                    ; c847: 8c 03 02
+               lda ram11                    ; c84a: a5 21
                beq +                        ; c84c: f0 03
                jmp cod156                   ; c84e: 4c a6 c8 (unaccessed)
+               lda ram47                    ; c851: a5 4e
                beq +                        ; c853: f0 19
                lda #$30                     ; c855: a9 30
                sta arr71                    ; c857: 8d 01 02
                lda #$ff                     ; c85a: a9 ff
                sta ram136                   ; c85c: 8d 04 02
                lda #3                       ; c85f: a9 03
                sta arr16                    ; c861: 85 15
                sta arr17                    ; c863: 85 16
                lda #2                       ; c865: a9 02
                jsr sub40                    ; c867: 20 1a 9e
                lda #0                       ; c86a: a9 00
                sta ram47                    ; c86c: 85 4e
+               bit ppu_status               ; c86e: 2c 02 20
                jsr sub1                     ; c871: 20 4f 80
                jsr sub3                     ; c874: 20 00 82
                lda arr14                    ; c877: a5 13
                sta ppu_mask                 ; c879: 8d 01 20
                lda ram8                     ; c87c: a5 1b
                sta ppu_scroll               ; c87e: 8d 05 20
                ldy arr22                    ; c881: a4 1e
                sty ppu_scroll               ; c883: 8c 05 20
                lda #0                       ; c886: a9 00
                sta oam_addr                 ; c888: 8d 03 20
                lda #2                       ; c88b: a9 02
                sta oam_dma                  ; c88d: 8d 14 40
                lda arr15                    ; c890: a5 14
                sta ppu_mask                 ; c892: 8d 01 20
                sta arr14                    ; c895: 85 13
                lda arr13                    ; c897: a5 12
                sta ppu_ctrl                 ; c899: 8d 00 20
                sta ram6                     ; c89c: 85 11
                lda ram8                     ; c89e: a5 1b
                sta ram7                     ; c8a0: 85 1a
                lda arr22                    ; c8a2: a5 1e
                sta arr21                    ; c8a4: 85 1d
cod156          jsr sub36                    ; c8a6: 20 37 9d
                inc ram11                    ; c8a9: e6 21
                pla                          ; c8ab: 68
                tay                          ; c8ac: a8
                pla                          ; c8ad: 68
                tax                          ; c8ae: aa
                pla                          ; c8af: 68
                rti                          ; c8b0: 40

                lda ram11                    ; c8b1 (unaccessed)
-               cmp ram11                    ; c8b3 (unaccessed)
                bne -                        ; c8b5 (unaccessed)
                rts                          ; c8b7 (unaccessed)

                pad $ffe0, $00               ; c8b8 (unaccessed)

                hex 20 50 52 4f 58 49 4d 49  ; ffe0 (unaccessed)
                hex 54 59 20 53 48 49 46 54  ; ffe8 (unaccessed)
                hex e7 b0 b4 aa 20 80 01 0e  ; fff0 (unaccessed)
                hex 00 f3                    ; fff8 (unaccessed)

                ; NMI/reset/IRQ vectors (IRQ unaccessed)
                pad $fffa
                dw nmi, reset, reset

                pad $10000, $ff

; --- CHR ROM -----------------------------------------------------------------

                base $0000
                incbin "prox-chr.bin"
                pad $2000, $ff
