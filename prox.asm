; Proximity Shift (NESdev Compo 2023) by Fiskbit, Trirosmos.
; Unofficial disassembly by qalle.
; Assembles with ASM6.
; Command used to disassemble:
;     python3 nesdisasm.py
;     -c prox.cdl --no-access 0800-1fff,2008-3fff,4020-5fff,6000-7fff
;     --no-write 8000-ffff prox-prg.bin

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff

ptr1            equ $00  ; 2 bytes
ptr2            equ $02  ; 2 bytes
ram1            equ $04
ram2            equ $0e
ram3            equ $0f
ram4            equ $10
ram5            equ $11
ppu_ctrl_copy   equ $12
ppu_mask_copy1  equ $13
ppu_mask_copy2  equ $14
ram7            equ $15
ram8            equ $16
ram9            equ $17
ram10           equ $18
ram11           equ $19
ram12           equ $1a
ram13           equ $1b
ram14           equ $1c
ram15           equ $1d
ram16           equ $1e
ram17           equ $1f
ram18           equ $20
ram19           equ $21
ram20           equ $23
ram21           equ $24
ptr3            equ $25  ; 2 bytes
arr1            equ $27
ram22           equ $29
ram23           equ $2a
ram24           equ $2c
ram25           equ $2d
buttons_changed equ $2e  ; joypad buttons that were just pressed
buttons_held    equ $2f  ; all joypad buttons being held now
ptr4            equ $30  ; 2 bytes
ram26           equ $32
ram27           equ $33
ram28           equ $34
ram29           equ $36
ram30           equ $37
ram31           equ $38
ram32           equ $39
ram33           equ $3a
ram34           equ $3c
ram35           equ $3d
ram36           equ $3e
ram37           equ $3f
ram38           equ $40
ram39           equ $41
ram40           equ $42
ram41           equ $43
ram42           equ $44
ram43           equ $45
ram44           equ $47
ram45           equ $48
ram46           equ $49
ram47           equ $4a
ram48           equ $4b
ram49           equ $4c
ram50           equ $4d
ram51           equ $4e
arr2            equ $50
ram52           equ $52
ram53           equ $53
ram54           equ $54
ptr5            equ $5a
ram55           equ $5c
ram56           equ $5d
ram57           equ $5e
ram58           equ $5f
arr3            equ $60  ; 16 bytes
ram59           equ $70
ram60           equ $71
ptr6            equ $72  ; 2 bytes
ram61           equ $74
ram62           equ $75
ram63           equ $76
ram64           equ $77
ptr7            equ $79  ; 2 bytes
ptr8            equ $7b  ; 2 bytes
ptr9            equ $7f  ; 2 bytes
ptr10           equ $81  ; 2 bytes
ram65           equ $83
ram66           equ $84
ram67           equ $85
ram68           equ $86
ram69           equ $87
ram70           equ $88

arr4            equ $0110
arr5            equ $0133
arr6            equ $0150
arr7            equ $0170

oam_copy        equ $0200  ; $100 bytes

arr8            equ $0300

arr9            equ $0400
ram71           equ $0424
arr10           equ $043c
arr11           equ $0444
arr12           equ $044c
arr13           equ $0454
arr14           equ $045c
arr15           equ $0464
arr16           equ $046c
arr17           equ $0474
arr18           equ $047c
arr19           equ $0484
arr20           equ $048c
arr21           equ $0494
arr22           equ $049c
arr23           equ $04a8
arr24           equ $04b4
arr25           equ $04c0
arr26           equ $04ea
ram72           equ $04f0
ram73           equ $04f1
arr27           equ $04f2
ram74           equ $04f7
ram75           equ $04f8
ram76           equ $04f9
ram77           equ $04fa
ram78           equ $04fb
ram79           equ $04fc
ram80           equ $04fd
ram81           equ $04fe
ram82           equ $04ff

arr28           equ $0500
arr29           equ $0508
arr30           equ $050d
arr31           equ $0512
arr32           equ $0517
arr33           equ $051c
arr34           equ $0521
arr35           equ $0526
arr36           equ $052b
arr37           equ $0530
arr38           equ $0535
arr39           equ $053a
arr40           equ $053e
arr41           equ $0542
arr42           equ $0546
arr43           equ $054a
arr44           equ $054f
arr45           equ $0551
arr46           equ $0555
arr47           equ $0559
arr48           equ $055d
arr49           equ $0561
arr50           equ $0565
arr51           equ $0569
arr52           equ $056d
arr53           equ $0571
arr54           equ $0575
arr55           equ $0579
arr56           equ $057d
arr57           equ $0581
arr58           equ $0585
arr59           equ $0589
arr60           equ $058d
arr61           equ $0591
arr62           equ $0595
arr63           equ $0599
arr64           equ $059d
arr65           equ $05a1
arr66           equ $05a5
arr67           equ $05a9
arr68           equ $05ad
arr69           equ $05b1
arr70           equ $05b5
arr71           equ $05b9
arr72           equ $05bd
arr73           equ $05c1
arr74           equ $05c5

arr75           equ $0600

arr76           equ $0700

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
ppu_nt2         equ $2800
ppu_at2         equ $2bc0
ppu_palette     equ $3f00

; string ids
STR_ID_TITLE    equ 4*2

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

macro axs_imm _operand
                ; undocumented instruction:
                ; X, N, Z, C = ((A AND X) - operand without borrow)
                ; https://www.nesdev.org/wiki/Programming_with_unofficial_opcodes
                db $cb, #_operand
endm

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

--              rept 16                      ; 8000
                    pla
                    sta ppu_data
                endr
                tya                          ; 8040
                bne ++
                beq cod1
-               txs                          ; 8045
                ldx #$ff
                stx arr4+0
                inx
                stx ram25
rts1            rts
                ;
sub1            lda ram24                    ; 804f
                beq +
                jsr print_str
+               lda arr4+0
                bmi rts1
                lda #$80
                sta ptr1+1
                lda #$80
                sta ptr2+1
                tsx
                txa
                ldx #15
                txs
                tax
cod1            pla                          ; 8069
                bmi -
                sta ppu_addr
                pla
                sta ppu_addr
                pla
                asl a
                tay
                lda ram5
                bcc +
                ora #%00000100               ; 807a (unaccessed)
+               sta ppu_ctrl                 ; 807c
                tya
                bmi +++
                lsr a
                bne ++
                lda #$40                     ; 8085 (unaccessed)
++              cmp #$10                     ; 8087
                bcc +
                sbc #$10
                tay
                jmp --

                ; 8091-80f5: unaccessed code
+               ldy #0                       ; 8091
                sbc #0
                eor #%00001111
                asl a
                asl a
                sta ptr1+0
                jmp (ptr1)
+++             lsr a                        ; 809e
                and #%00111111
                bne +
                lda #$40
+               eor #%11111111
                adc #$11
                sta ram1
                pla
                tay
                lda ram1
                sty ram1
                bpl +
-               rept 16
                    sty ppu_data
                endr
                adc #16
                bmi -
                bcc cod1
+               tay
                lda dat2,y
                sta ptr2+0
                ldy ram1
                lda #0
                jmp (ptr2)

print_str       ; $80f6: copy string to PPU buffer; A = string_id * 2
                tay
                lda str_ptrs-2,y
                sta ptr1+0
                lda str_ptrs-1,y
                sta ptr1+1
                ;
--              ldy #0                       ; 8101
                lda (ptr1),y
                bmi ++
                sta ppu_addr
                iny
                lda (ptr1),y
                sta ppu_addr
                iny
                lda (ptr1),y
                iny
                asl a
                tax
                lda ram5
                bcc +
                ora #%00000100               ; 811a (unaccessed)
+               sta ppu_ctrl                 ; 811c
                txa
                bmi +++
                lsr a
                bne +
                lda #$40                     ; 8125 (unaccessed)
+               tax                          ; 8127
-               lda (ptr1),y
                sta ppu_data
                iny
                dex
                bne -
---             tya                          ; 8131
                add ptr1+0
                sta ptr1+0
                lda ptr1+1
                adc #0
                sta ptr1+1
                jmp --
                ;
++              lda #0                       ; 8140
                sta ram24
                rts
+++             lsr a                        ; 8145
                and #%00111111
                bne +
                lda #$40
+               tax
                lda (ptr1),y
                iny
                ;
-               sta ppu_data
                dex
                bne -
                jmp ---

                ; 8159-8168: unaccessed data
dat2            hex b3 b6 b9 bc bf c2 c5 c8  ; 8159
                hex cb ce d1 d4 d7 da dd e0

cod2            rept 32                      ; 8169
                    pla
                    sta ppu_data
                endr
                jmp (ptr3)                   ; 81e9

                pad $8200, $00               ; 81ec (unaccessed)

sub3            lda ram5                     ; 8200
                sta ppu_ctrl
                lda ram21
                beq rts2
sub4            tsx                          ; 8209
                stx ptr1+0
                ldx #$4f
                txs
                ldx ram22
                stx ppu_addr
                ldy ram23
                sty ppu_addr
                lda #$20
                sta ptr3+0
                jmp cod2
                stx ppu_addr
                tya
                ora #%00100000
                sta ppu_addr
                ldx #$6f
                txs
                lda #$33
                sta ptr3+0
                jmp cod2
                ldx ptr1+0
                txs
                lda #0
                sta ram21
rts2            rts

clear_nt0       ; fill NT0 with a blank tile ($f8)
                lda #>ppu_nt0                ; 823b
                sta ppu_addr
                lda #<ppu_nt0
                sta ppu_addr
                ldy #$f0
                lda #$f8
-               sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                dey
                bne -
                rts

str_ptrs        ; pointers to PPU strings ($8259)
                dw str_blackpal              ;  0 (unaccessed)
                dw str_palette               ;  1 (unaccessed)
                dw arr9                      ;  2
                dw str_title                 ;  3
                dw str_normal1               ;  4 (unaccessed)
                dw str_hard1                 ;  5 (unaccessed)
                dw str_expert1               ;  6 (unaccessed)
                dw str_irritating1           ;  7 (unaccessed)
                dw str_off1                  ;  8 (unaccessed)
                dw str_on1                   ;  9 (unaccessed)
                dw str_congrats              ; 10 (unaccessed)
                dw str_gotlost               ; 11 (unaccessed)
                dw str_master                ; 12 (unaccessed)
                dw str_wow                   ; 13 (unaccessed)
                dw str_stats                 ; 14 (unaccessed)
                dw str_credits               ; 15 (unaccessed)
                dw str_normal2               ; 16 (unaccessed)
                dw str_hard2                 ; 17 (unaccessed)
                dw str_expert2               ; 18 (unaccessed)
                dw str_irritating2           ; 19 (unaccessed)
                dw str_secret                ; 20 (unaccessed)
                dw str_off2                  ; 21 (unaccessed)
                dw str_on2                   ; 22 (unaccessed)
                dw str_ntsc                  ; 23 (unaccessed)
                dw str_pal                   ; 24 (unaccessed)
                dw str_pal                   ; 25 (unaccessed)

                ; PPU strings

macro ppustr _addr, _len
                db >(_addr), <(_addr), _len
endm

                ; tiles $00-$09 = "0"-"9" (subtract 48 from ASCII digits)
                ; tiles $0a-$23 = "A"-"Z" (subtract 55 from ASCII uppercase)

                ; 828d-8291: unaccessed data
str_blackpal    ppustr ppu_palette, $40|32   ; 828d
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

                ; 8395-86c3: unaccessed data
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

                hex b4 b4 b5 b5              ; 86c4 (unaccessed)

sub6            sta ram44                    ; 86c8
                stx ram45
                sta ram46
                stx ram47
sub7            clc                          ; 86d0
                lda ram44
                adc #$b3
                sta ram44
                adc ram45
                sta ram45
                adc ram46
                sta ram46
                eor ram44
                and #%01111111
                tax
                lda ram46
                adc ram47
                sta ram47
                eor ram45
                rts

sub8            lsr a                        ; 86ed
                sta ptr1+0
                lda #0
                ldy #8
-               bcc +
                add ptr1+1
+               ror a
                ror ptr1+0
                dey
                bne -
                rts

                ; 8700-871c: unaccessed code
                eor #%11111111               ; 8700
                sta ptr1+1
                lda ptr1+0
                eor #%11111111
                add #1
                sta ptr1+0
                bcc +
                inc ptr1+1                   ; 870f
+               rts
                ldy #$ff
-               iny
                sub #$0a
                bcs -
                adc #$0a
                rts

sub9            bit buttons_changed          ; 871d
                bpl +
                lda ram34
                eor #%00000001
                sta ram34
                lda #1
                jsr sub40
                lda #$10
                sta ram41
+               jsr sub10
                lda buttons_held
                and #%01000000
                beq +
                jsr sub10
+               lda ram8
                cmp #3
                beq +
                jsr sub12
                jmp sub11
+               jsr sub11                    ; 8748 (unaccessed)
                lda #$30                     ; unaccessed
                sta oam_copy+1               ; unaccessed
                rts                          ; unaccessed

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

sub10           lda buttons_held             ; 877d
                and #%00001111
                ldy ram53
                cpy #0
                bne +
                and #%11110111               ; 8787 (unaccessed)
+               cpy #$e7                     ; 8789
                bcc +
                and #%11111011
+               tax
                lda ram52
                clc
                adc dat8,x
                sta ram52
                lda arr2+1
                adc dat7,x
                sta arr2+1
                cmp #$50
                bcs +
                sbc #$4f
                add ram37
                sta ram37
                lda #$50
                sta arr2+1
+               lda arr2+1
                cmp #$85
                bcc +
                sbc #$84
                add ram37
                sta ram37
                lda #$84
                sta arr2+1
+               lda ram54
                clc
                adc dat10,x
                sta ram54
                lda ram53
                adc dat9,x
                sta ram53
                rts

dat11           hex 00 24 00                 ; 87cf

sub11           lda ram53                    ; 87d2
                sta oam_copy+0
                sta oam_copy+3*4
                lda #0
                sta oam_copy+2
                lda #2
                sta oam_copy+3*4+2
                lda #4
                sta oam_copy+1
                lda ram18
                lsr a
                lsr a
                lsr a
                lda #$0e
                adc #0
                sta oam_copy+3*4+1
                ldy ram34
                lda arr2+1
                clc
                adc dat11,y
                sta oam_copy+3
                iny
                lda arr2+1
                clc
                adc dat11,y
                sta oam_copy+3*4+3
                sta oam_copy+2*4+3
                lda #$fe
                sta oam_copy+2*4
                ldy ram41
                beq +
                dey
                sty ram41
                tya
                lsr a
                lsr a
                sta oam_copy+2*4+1
                lda ram53
                sta oam_copy+2*4
                lda #0
                sta oam_copy+2*4+2
+               rts
sub12           lda ram35                    ; 882a
                beq rts3

                ; 882e-884d: unaccessed code
                cmp #$0b                     ; 882e
                lda #$10
                bcc +
                lda #$20                     ; 8834
+               lda #$10
                sta oam_copy+4+1
                lda #1
                sta oam_copy+4+2
                lda arr2+1
                sta oam_copy+4+3
                jsr ram53
                add #6
                sta oam_copy+4

rts3            rts                          ; 884e

sub13           lda #$10                     ; 884f
                sta ptr1+0
                ldx ram20
                ldy ram43
                beq rts4

                ; 8859-889c: unaccessed code
                cpy #5                       ; 8859
                bcc cod3
                ldy #1                       ; 885d
cod3            lda ptr1+0
                sta oam_copy+3,x
                add #8
                sta ptr1+0
                lda #$12
                sta oam_copy,x
                lda #0
                sta oam_copy+1,x
                sta oam_copy+2,x
                inx
                inx
                inx
                inx
                dey
                bne cod3
                lda ram43
                cmp #5
                bcc +
                ora #%11110000               ; 8883
                sta oam_copy+1,x
                lda #$12
                sta oam_copy,x
                lda ptr1+0
                sta oam_copy+3,x
                lda #0
                sta oam_copy+2,x
                inx
                inx
                inx
                inx
+               stx ram20

rts4            rts                          ; 889d
sub14           ldx ram20                    ; 889e
                beq rts5
                lda ram17
                sub ram40
                rol a
                eor #%00000001
                ror a
                lda ram39
                adc #0
                sta ptr2+1
                ldy #$0b
                sty ptr2+0
-               ldy ptr2+0
                lda ptr2+1
                beq +++
                sta ptr1+1
                lda dat13,y
                clc
                adc arr25,y
                jsr sub8
                sta ptr1+1
                ldy ptr2+0
                lda ptr1+0
                clc
                adc arr24,y
                sta arr24,y
                lda arr23,y
                adc ptr1+1
                sta arr23,y
                bit ptr1+1
                bmi +
                bcc +++
                lda #0
                bcs ++
+               bcs +++                      ; 88e6 (unaccessed)
                lda #$ff                     ; 88e8 (unaccessed)
++              sta arr23,y                  ; 88ea
                lda dat12,y
                adc ram47
                sta arr22,y
                lda ram46
                and #%01111111
                sta arr25,y
+++             lda arr23,y                  ; 88fc
                sta oam_copy,x
                lda arr22,y
                sta oam_copy+3,x
                lda #$23
                sta oam_copy+2,x
                lda #$fe
                sta oam_copy+1,x
                axs_imm $fc                  ; 8912: equiv. to 4*INX
                beq +
                dec ptr2+0
                bpl -
+               stx ram20
rts5            rts

dat12           hex ec                       ; 891d (unaccessed)
                hex 42 73 61 2d 94 28 22 c9  ; 891e
                hex e1 62 a9                 ; 8926
dat13           hex 20 28 30 38 40 48 50 58  ; 8929
                hex 60 68 70 78              ; 8931

                ; 8935-899d: unaccessed code
                rts                          ; 8935 (could be data byte $60)
                lda arr2+1                   ; 8936
                pha
                add #2
                sta arr2+1
                lda ram53
                pha
                add #2
                sta ram53
                ldx #0
                ldy #0
                ;
--              lda arr2+1,y
                sty ptr1+0
                ldy #8
-               sta arr10,x
                inx
                dey
                bne -
                ldy ptr1+0
                iny
                cpy #8
                bcc --
                ;
                pla
                sta ram53
                pla
                sta arr2+1
                ldy #7
                ;
-               jsr sub7
                lsr a
                lsr a
                sub #$20
                php
                clc
                adc arr17,y
                sta arr17,y
                lda arr16,y
                adc #0
                plp
                sbc #0
                sta arr16,y
                txa
                lsr a
                sub #$20
                php
                clc
                adc arr20,y
                sta arr20,y
                lda arr19,y
                adc #0
                plp
                sbc #0
                sta arr19,y
                dey
                bpl -
                ;
                rts

rts6            rts                          ; 899e

                ; 899f-8a27: unaccessed code
                ldy ram20                    ; 899f
                ldx #7
-               lda arr12,x                  ; 89a3
                clc
                adc arr18,x
                sta arr12,x
                lda arr11,x
                adc arr17,x
                sta arr11,x
                lda arr10,x
                adc arr16,x
                sta arr10,x
                sta oam_copy+3,y
                bit ram9
                bmi +
                ror a                        ; 89c6
                eor arr16,x
                bpl +
                jsr sub16                    ; 89cc
                jmp ++
+               lda arr15,x                  ; 89d2
                clc
                adc arr21,x
                sta arr15,x
                lda arr14,x
                adc arr20,x
                sta arr14,x
                lda arr13,x
                adc arr19,x
                sta arr13,x
                bit ram9
                bmi +
                ror a                        ; 89f2
                eor arr19,x
                bpl +
                jsr sub16                    ; 89f8
                jmp ++
+               lda arr13,x                  ; 89fe
                sta oam_copy,y
                lda #0
                sta oam_copy+2,y
                txa
                ora #%01010000
                sta oam_copy+1,y
                iny
                iny
                iny
                iny
++              dex                          ; 8a13
                bpl -
                sty ram20
                rts

sub16           lda #$ff                     ; 8a19
                sta arr13,x
                sta arr19,x
                sta arr20,x
                sta arr21,x
                rts

dat15           hex 5e                       ; 8a28
dat16           hex 8a ca 8a 26 8b fb 8b 42  ; 8a29
                hex 8c 6b 8c 77 8c
                hex 94 8c de 8c bf 8c eb 8c  ; 8a36 (unaccessed)
                hex 03 8b 53 8b

sub17           sta ppu_data                 ; 8a42
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                dey
                bne sub17
                rts
                lda #0
                sta ram29
                lda #1
                sta ram7
                sta ram8
                jsr sub18
                jsr sub35
                jmp sub19b

sub18           ldy #$23                     ; 8a71
-               lda str_palette,y
                sta arr9,y
                dey
                bpl -
                lda #0
                sta ram71
                rts

sub19           bit ppu_status               ; 8a82
                lda #>ppu_at0
                sta ppu_addr
                lda #<ppu_at0
                sta ppu_addr
                lda #0
                ldy #8
                jsr sub17
                ldy #>ppu_at2
                sty ppu_addr
                ldy #<ppu_at2
                sty ppu_addr
                ldy #8
                jsr sub17
                lda #0
                ldy #9
-               sta arr2,y
                dey
                bne -
                jsr sub71
                ldy #$0b
-               jsr sub7
                sta arr23,y
                jsr sub7
                sta arr22,y
                dey
                bpl -
                jsr sub14
                jsr sub27
                rts

sub19b          jsr sub71                    ; 8aca
                lda ram9
                cmp #1
                beq +
                lda #0
                sta ppu_mask_copy2
                sta ppu_mask_copy1
                sta ppu_mask
                jsr sub38
                jsr sub26
                lda #$0b
                sta ram11
                lda #1
                sta ram10
                lda #%00011110
                sta ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
+               jsr sub20
                lda ram7
                cmp ram8
                beq +
                lda #$80
                sta ram10
+               rts
                lda #0
                sta ram39
                jsr sub71
                lda buttons_changed
                and #%10010000
                beq +
                lda #0
                jsr sub37
                lda #6
                sta ram11
                lda #4
                sta ram8
                lda #0
                sta ram10
                lda #0
                sta ram29
+               rts

sub20           lda ram36                    ; 8b26
                bne +
                lda #9
                sta ram36
+               dec ram36
                bne ++
                ldy ram11
                sty ram8
                cpy #$0b
                bcc +
                lda buttons_held
                and #%01111111
                sta buttons_held
+               cpy #$0c
                bne ++
                jsr sub39
                ;
++              lda ram36                    ; 8b47
                add #3
                and #%00001100
                asl a
                asl a
                jmp sub22
                lda ppu_mask_copy1
                ora #%00011110
                sta ppu_mask_copy2
                lda buttons_changed
                and #%00010000
                beq +
                lda ram42
                eor #%00000001
                sta ram42
+               lda ram42
                beq +
                lda ppu_mask_copy1
                and #%11100001
                sta ppu_mask_copy2
                rts
+               ldy ram29
                lda dat23,y
                sta ram38
                lda dat22,y
                sta ram37
                lda dat25,y
                sta ram40
                lda dat24,y
                sta ram39
                lda ram31
                beq +
                ldy #4
                jmp cod4
+               lda buttons_held
                and #%00100000
                beq +
                ldy #2
cod4            asl ram38                    ; 8b97
                rol ram37
                asl ram40
                rol ram39
                dey
                bne cod4
+               jsr sub71                    ; 8ba2
                jsr sub9
                jsr sub14
                jsr sub33
                lda ram30
                bne +
                lda ram29
                asl a
                tay
                iny
                iny
                lda ptr4+0
                cmp dat28,y
                bne +
                lda ptr4+1
                cmp dat28+1,y
                bne +
                lda #$10
                sta ram28
                sta ram30
                lda #0
                sta ram33
                sta ram32
+               lda ram30
                beq +
                lda ram33
                add ram40
                sta ram33
                lda ram32
                adc ram39
                sta ram32
                lda ram53
                add #$10
                cmp ram32
                bcs +
                lda #1
                sta ram31
+               lda #0
                sta ram37
                sta ram38
                sta ram39
                sta ram40
                rts
                jsr sub71
                lda ram36
                bne +
                lda #$16
                sta ram36
+               lda oam_copy+1
                cmp #$30
                bcc +
                cmp #$3a
                bcs +
                adc #1
                pha
                jsr sub11
                pla
                sta oam_copy+1
                lda #1
                sta oam_copy+2
+               dec ram36
                bne +
                lda #0
                sta ram30
                sta ram28
                lda #1
                sta ram10
                lda #6
                ldy ram9
                sta ram11
                lda #5
                sta ram8
+               jsr sub14
                jsr rts6
                rts
                jmp ($5a5a)                  ; 8c3f (unaccessed)

sub21           lda ram36                    ; 8c42
                bne +
                lda #$0d
                sta ram36
+               dec ram36
                bne +
                lda ram11
                sta ram8
                lda #0
                sta ppu_mask_copy2
                sta ppu_ctrl_copy
+               lda ram36
                cmp #$0d
                bcs +
                add #3
                and #%00001100
                eor #%00001100
                asl a
                asl a
                jsr sub22
+               rts
                jsr sub71
                jsr sub21
                jsr sub14
                jmp rts6
                jsr sub19
                lda #$0c
                sta ram11
                lda #2
                sta ram8
                lda #0
                sta ram10
                lda #%00011110
                sta ppu_mask_copy2
                lda ppu_ctrl_copy
                ora #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts

                ; 8c94-8cba: unaccessed code
                jsr sub71                    ; 8c94
                lda #0
                sta ram16
                jsr clear_nt0
                lda #2*11
                jsr print_str
                lda #8
                sta ram11
                lda #2
                sta ram8
                lda #0
                sta ram10
                lda #%00011110
                sta ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts

                hex dc dc                    ; 8cbb (unaccessed)

                ; e1 24 = SBC (24,x)
                ; 24 nn = BIT nn
                hex e1 24                    ; 8cbd (unaccessed)

                ; 8cbf-8cfb: unaccessed code
                jsr clear_nt0                ; 8cbf
                lda #16*2
                jsr print_str
                lda #$0a
                sta ram11
                lda #2
                sta ram8
                lda #0
                sta ram10
                lda #%00011110
                sta ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                bit buttons_changed
                bvc +
                lda #9                       ; 8ce2
                sta ram11
                lda #4
                sta ram8
                rts
+               bit buttons_changed          ; 8ceb
                bpl +
                lda #1                       ; 8cef
                sta ram11
                lda #4
                sta ram8
                lda #0
                sta ram10
+               rts                          ; 8cfb

sub22           sta ptr1+0                   ; 8cfc
                ldy ram25
                lda #$3f
                sta arr4,y
                lda #0
                sta arr4+1,y
                lda #$20
                sta arr4+2,y
                lda #$ff
                sta arr5,y
                tya
                add #$1f
                tay
                ldx #$1f
-               lda arr9+3,x                 ; 8d1b
                and #%00001111
                cmp #$0d
                bcs +
                lda arr9+3,x
                sub ptr1+0
                bcs ++
+               lda #$0f
++              sta arr4+3,y                 ; 8d2e
                dey
                dex
                bpl -
                tya
                add #$20
                sta ram25
                rts

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

dat28           hex 76 90 96 91 86 92 56 93  ; 9b26
                hex a6 94 f6 96 96 99 26 9b  ; 9b2e (unaccessed)

sub23           lda ram28                    ; 9b36
                beq sub24
                lda ptr4+0
                pha
                lda ptr4+1
                pha
                lda #$66
                sta ptr4+0
                lda #$90
                sta ptr4+1
                jsr sub24
                dec ram28
                bne +
                lda ram30
                beq +
                inc ram29
                lda #0
                sta ram30
                sta ram31
                jsr sub34
                ldy ram29
                lda dat26,y
                sta ram12
                sta ram13
                lda ram17
                sec
                sbc dat27,y
                sta ram14
                cpy #7
                bne +

                lda #1                       ; 9b73 (unaccessed)
                sta ram11                    ; unaccessed
                lda #4                       ; unaccessed
                sta ram8                     ; unaccessed
                lda #0                       ; unaccessed
                sta ram10                    ; unaccessed
                jsr sub38                    ; unaccessed

+               pla                          ; 9b82
                sta ptr4+1
                pla
                sta ptr4+0
                rts

sub24           inc ram26                    ; 9b89
                bne sub25
                inc ram27
sub25           ldy #0                       ; 9b8f
                jsr sub32
                lda arr1+0
                sta ram22
                lda arr1+1
                sta ram23
                lda #0
                sta ptr1+0
-               ldy #0
                lda (ptr4),y
                inc ptr4+0
                bne +
                inc ptr4+1
+               tax
                ldy ptr1+0
                lda dat17,x
                sta arr6,y
                lda dat18,x
                sta arr6+1,y
                lda dat20,x
                sta arr7,y
                lda dat21,x
                sta arr7+1,y
                iny
                iny
                sty ptr1+0
                cpy #$20
                bne -
                lda #1
                sta ram21
                sec
                rts
sub26           lda #0                       ; 9bd3
                sta ram15
                sta ram16
                sta ram12
                sta ram13
                jsr clear_nt0
                lda #STR_ID_TITLE            ; print title screen
                jsr print_str
                rts
sub27           jsr sub39                    ; 9be6
                ldy ram29
                lda dat26,y
                sta ram12
                sta ram13
                lda dat27,y
                sta ram14
                lda #0
                sta ram15
                sta ram16
                sta ram17
                sta ram43
                sta ram34
                sta ram41
                sta ram37
                sta ram38
                sta ram39
                sta ram40
                lda ram29
                asl a
                tay
                lda dat28,y
                sta ptr4+0
                lda dat28+1,y
                sta ptr4+1
                lda #$ff
                sta ram26
                sta ram27
                jsr sub28
                lda #$0a
                sta ram3
                jsr sub29
                lda #5
                sta ram3
                jsr sub30
                lda #$6a
                sta arr2+1
                lda #$80
                sta ram52
                lda #$bf
                sta ram53
                lda #$80
                sta ram54
                jsr sub11
                jsr sub13
                rts
sub28           lda #0                       ; 9c49
                sta ram21
                lda #$23
                sta arr1+0
                lda #$c0
                sta arr1+1
                lda ram5
                sta ppu_ctrl
                rts
sub29           lda ptr4+0                   ; 9c5b
                pha
                lda ptr4+1
                pha
-               lda #$66
                sta ptr4+0
                lda #$90
                sta ptr4+1
                jsr sub25
                jsr sub4
                dec ram3
                bne -
                pla
                sta ptr4+1
                pla
                sta ptr4+0
                rts
sub30           jsr sub25                    ; 9c7a
                jsr sub4
                dec ram3
                bne sub30
                rts

-               jsr sub24                    ; 9c85 (unaccessed)
                jsr sub4                     ; unaccessed
                dec ram3                     ; unaccessed
                bne -                        ; unaccessed
                rts                          ; 9c8f (unaccessed)

sub31           lda ram17                    ; 9c90
                sec
                sbc ram40
                sta ram17
                lda ram15
                sbc ram39
                sta ram16
                bcs +
                sbc #$0f
                sta ram16
                lda ram5
                eor #%00000010
                sta ppu_ctrl_copy
+               rts

                ; 9caa-9cbf: unaccessed code
                lda ram15                    ; 9caa
                add ram39
                sta ram16
                cmp #$f0
                bcc +
                adc #$0f                     ; 9cb5
                sta ram16
                lda ram5
                eor #%00000010
                sta ppu_ctrl_copy
+               rts                          ; 9cbf

sub32           lda arr1+1,y                 ; 9cc0
                sub #$40
                sta arr1+1,y
                lda arr1,y
                sbc #0
                ora #%00100000
                and #%00101011
                sta arr1,y
                and #%00000011
                cmp #3
                bcc +
                lda arr1+1,y
                cmp #$c0
                bcc +
                lda #$80
                sta arr1+1,y
+               rts

sub33           lda ppu_ctrl_copy            ; 9ce8
                sta ram2
                jsr sub31
                lda ram14
                add ram38
                sta ram14
                lda ram13
                adc ram37
                sta ram13
                lda ram16
                eor ram15
                cmp #$10
                bcc +
                jsr sub23
+               rts

sub34           lda arr9+4                   ; 9d08
                add #5
                cmp #$0d
                bcc +
                sbc #$0c                     ; 9d12 (unaccessed)
+               sta arr9+4                   ; 9d14
                ora #%00010000
                sta arr9+5
                eor #%00110000
                sta arr9+6
                lda #6
                sta ram24
                rts

sub35           lda #$ff                     ; 9d26
                sta ram59
                sta ram60
                jsr sub38
                ldx #8
                ldy #$ad
                jsr sub41
                rts

sub36           lda ram56                    ; 9d37
                ror a
                bcc +
                jsr sub48
                jmp ++
+               lda #$30
                sta arr3+0
                sta arr3+4
                sta arr3+12
                lda #0
                sta arr3+8
++              ldx #0
                jsr sub43
                ldx #$0f
                jsr sub43
                ldx #$1e
                jsr sub43
                ldx #$2d
                jsr sub43
                lda arr3+0
                sta sq1_vol
                lda arr3+1
                sta sq1_sweep
                lda arr3+2
                sta sq1_lo
                lda arr3+3
                cmp ram59
                beq +
                sta ram59
                sta sq1_hi
+               lda arr3+4
                sta sq2_vol
                lda arr3+5
                sta sq2_sweep
                lda arr3+6
                sta sq2_lo
                lda arr3+7
                cmp ram60
                beq +
                sta ram60
                sta sq2_hi
+               lda arr3+8
                sta tri_linear
                lda arr3+9
                sta misc1
                lda arr3+10
                sta tri_lo
                lda arr3+11
                sta tri_hi
                lda arr3+12
                sta noise_vol
                lda arr3+13
                sta misc2
                lda arr3+14
                sta noise_lo
                lda arr3+15
                sta noise_hi
                rts

sub37           ldx #$30                     ; 9dbf
                stx ram57
                ldx #$9e
                stx ram58
                ldx ram4
                jsr sub44
                lda #1
                sta ram56
                rts

sub38           ldx #$e5                     ; 9dd1
                stx ram57
                ldx #$9d
                stx ram58
                lda #0
                ldx ram4
                jsr sub44
                lda #0
                sta ram56
                rts

                hex 0d 00 0d 00 0d 00 0d 00  ; 9de5
                hex 00 10 0e                 ; 9ded
                hex b8 0b                    ; 9df0 (unaccessed)
                hex 0f 00 16 00 01 40 06 96  ; 9df2
                hex 00 18 00 22 00 22 00 22  ; 9dfa
                hex 00 22 00 22 00           ; 9e02
                hex 00 3f                    ; 9e07 (unaccessed)

                lda #0                       ; 9e09 (unaccessed)
                sta ram56                    ; unaccessed
                rts                          ; unaccessed

sub39           lda #1                       ; 9e0e
                sta ram56
                rts

                lda ram56                    ; 9e13 (unaccessed)
                eor #%00000001               ; unaccessed
                sta ram56                    ; unaccessed
                rts                          ; unaccessed

sub40           pha                          ; 9e1a
                ldx ram61
                inx
                txa
                and #%00000011
                sta ram61
                tax
                lda dat29,x
                tax
                pla
                jmp sub42b

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

sub41           stx ptr6+0                   ; b10f
                sty ptr6+1
                ldy #0
                lda ram4
                asl a
                tay
                lda (ptr6),y
                sta arr8+1
                iny
                lda (ptr6),y
                sta arr8+2
                ldx #0
-               jsr sub42
                txa
                add #$0f
                tax
                cpx #$3c
                bne -
                rts

sub42           lda #0                       ; b133
                sta arr8+5,x
                sta arr8+3,x
                sta arr8+6,x
                sta arr8+13,x
                lda #$30
                sta arr8+7,x
                sta arr8+10,x
                sta arr8+16,x
                rts

sub42b          asl a                        ; b14d
                tay
                jsr sub42
                lda arr8+1
                sta ptr6+0
                lda arr8+2
                sta ptr6+1
                lda (ptr6),y
                sta arr8+4,x
                iny
                lda (ptr6),y
                sta arr8+5,x
                rts

sub43           lda arr8+3,x                 ; b168
                beq +
                dec arr8+3,x
                bne +++
+               lda arr8+5,x
                bne +
                rts
+               sta ptr5+1
                lda arr8+4,x
                sta ptr5+0
                ldy arr8+6,x
                clc
-               lda (ptr5),y
                bmi +
                beq ++
                iny
                sta arr8+3,x
                tya
                sta arr8+6,x
                jmp +++
+               iny
                stx ram55
                adc ram55
                and #%01111111
                tax
                lda (ptr5),y
                iny
                sta arr8+7,x
                ldx ram55
                jmp -
++              sta arr8+5,x
+++             lda arr3+0
                and #%00001111
                sta ram55
                lda arr8+7,x
                and #%00001111
                cmp ram55
                bcc +
                lda arr8+7,x
                sta arr3+0
                lda arr8+8,x
                sta arr3+2
                lda arr8+9,x
                sta arr3+3
+               lda arr8+10,x
                beq +
                sta arr3+4
                lda arr8+11,x
                sta arr3+6
                lda arr8+12,x
                sta arr3+7
+               lda arr8+13,x
                beq +

                sta arr3+8                   ; b1de (unaccessed)
                lda arr8+14,x                ; unaccessed
                sta arr3+10                  ; unaccessed
                lda arr8+15,x                ; unaccessed
                sta arr3+11                  ; unaccessed

+               lda arr3+12                  ; b1ea
                and #%00001111
                sta ram55
                lda arr8+16,x
                and #%00001111
                cmp ram55
                bcc +
                lda arr8+16,x
                sta arr3+12
                lda arr8+17,x
                sta arr3+14
+               rts

                jmp sub44                    ; b204 (unaccessed)
                jmp sub48                    ; b207 (unaccessed)

sub44           asl a                        ; b20a
                jsr sub45
                lda #0
                tax
-               sta arr3,x
                inx
                cpx #16
                bne -
                lda #$30
                sta arr3+12
                lda #$0f
                sta snd_chn
                lda #8
                sta arr3+1
                sta arr3+5
                lda #$c0
                sta joypad2
                lda #$40
                sta joypad2
                lda #$ff
                sta arr26+5
                lda #0
                tax
-               sta arr34,x
                sta arr63,x
                sta arr64,x
                sta arr66,x
                sta arr65,x
                sta arr40,x
                sta arr39,x
                inx
                cpx #4
                bne -
                lda arr26+4
                and #%00000010
                beq +

                lda #$30                     ; b25a (unaccessed)
                ldx #0                       ; unaccessed
-               sta arr68,x                  ; unaccessed
                inx                          ; unaccessed
                cpx #4                       ; unaccessed
                bne -                        ; unaccessed
                lda #0                       ; unaccessed

+               sta arr34+4                  ; b268
                rts

sub45           pha                          ; b26c
                lda ram57
                sta ptr8+0
                lda ram58
                sta ptr8+1
                ldy #0
-               clc
                lda (ptr8),y
                adc ram57
                sta arr26,y
                iny
                lda (ptr8),y
                adc ram58
                sta arr26,y
                iny
                cpy #8
                bne -
                lda (ptr8),y
                sta arr26+4
                iny
                cpx #1
                beq +
                cpx #2
                beq ++
                lda (ptr8),y
                iny
                sta ram82
                lda (ptr8),y
                iny
                sta arr28+0
                lda #$a9
                sta ptr10+0
                lda #$c3
                sta ptr10+1
                jmp +++

                ; b2b1-b2c9: unaccessed code
+               iny                          ; b2b1
                iny
                lda (ptr8),y
                iny
                sta ram82
                lda (ptr8),y
                iny
                sta arr28+0
                lda #$69
                sta ptr10+0
                lda #$c4
                sta ptr10+1
                jmp +++

                ; b2ca-b2df: unaccessed code
++              iny                          ; b2ca
                iny
                lda (ptr8),y
                iny
                sta ram82
                lda (ptr8),y
                iny
                sta arr28+0
                lda #$a9
                sta ptr10+0
                lda #$c3
                sta ptr10+1

+++             pla                          ; b2e0
                tay
                jsr sub46
                ldx #1
                stx ram74
                dex
-               lda #$7f
                sta arr32,x
                lda #$80
                sta arr36,x
                lda #0
                sta arr70,x
                sta arr73,x
                sta arr63,x
                sta arr43,x
                sta arr37,x
                sta arr67,x
                sta arr31,x
                inx
                cpx #4
                bne -
                ldx #$ff
                inx
                stx ram76
                jsr sub47
                jsr sub54
                lda #0
                sta ram78
                sta ram79
                rts

sub46           lda arr26+0                  ; b326
                sta ptr7+0
                lda arr26+1
                sta ptr7+1
                clc
                lda (ptr7),y
                adc ram57
                sta ptr8+0
                iny
                lda (ptr7),y
                adc ram58
                sta ptr8+1
                lda #0
                tax
                tay
                clc
                lda (ptr8),y
                adc ram57
                sta ram72
                iny
                lda (ptr8),y
                adc ram58
                sta ram73
                iny
-               lda (ptr8),y
                sta arr27,x
                iny
                inx
                cpx #6
                bne -
                rts

sub47           asl a                        ; b35f
                add ram72
                sta ptr7+0
                lda #0
                tay
                tax
                adc ram73
                sta ptr7+1
                clc
                lda (ptr7),y
                adc ram57
                sta ptr8+0
                iny
                lda (ptr7),y
                adc ram58
                sta ptr8+1
                ldy #0
                stx ram75
-               clc
                lda (ptr8),y
                adc ram57
                sta arr29,x
                iny
                lda (ptr8),y
                adc ram58
                sta arr30,x
                iny
                lda #0
                sta arr37,x
                sta arr33,x
                lda #$ff
                sta arr38,x
                inx
                cpx #5
                bne -
                lda #0
                sta arr28+3
                sta arr28+4
                lda arr28+5
                bne +
                rts

                ; b3b3-b45f: unaccessed code
+               sta ram75                    ; b3b3
                ldx #0
--              lda ram75                    ; b3b8
                sta ram63
                lda #0
                sta arr37,x
-               ldy #0                       ; b3c2
                lda arr29,x
                sta ptr9+0
                lda arr30,x
                sta ptr9+1
                ;
cod5            lda arr37,x                  ; b3ce
                beq +
                dec arr37,x                  ; b3d3
                jmp ++
+               lda (ptr9),y                 ; b3d9
                bmi +++
                lda arr38,x                  ; b3dd
                cmp #$ff
                bne +
                iny                          ; b3e4
                lda (ptr9),y
                iny
                sta arr37,x
                jmp ++
+               iny                          ; b3ee
                sta arr37,x
++              clc                          ; b3f2
                tya
                adc ptr9+0
                sta arr29,x
                lda #0
                adc ptr9+1
                sta arr30,x
                dec ram63
                bne -
                ;
                inx
                cpx #5
                bne --
                ;
                lda #0                       ; b409
                sta arr28+5
                rts
+++             cmp #$80                     ; b40f
                beq cod6
                cmp #$82                     ; b413
                beq ++
                cmp #$84                     ; b417
                beq +++
                pha                          ; b41b
                cmp #$8e
                beq +
                cmp #$92                     ; b420
                beq +
                cmp #$a2                     ; b424
                beq +
                and #%11110000               ; b428
                cmp #$f0
                beq +
                cmp #$e0                     ; b42e
                beq cod7
                iny                          ; b432
+               iny                          ; b433
                pla
                jmp cod5
++              iny                          ; b438
                lda (ptr9),y
                iny
                sta arr38,x
                jmp cod5
+++             iny                          ; b442
                lda #$ff
                sta arr38,x
                jmp cod5
cod6            iny                          ; b44b
                lda (ptr9),y
                iny
                jsr sub66
                jmp cod5
cod7            iny                          ; b455
                pla
                and #%00001111
                asl a
                jsr sub66
                jmp cod5

sub48           lda ram74                    ; b460
                bne +
                rts                          ; b465 (unaccessed)
+               ldx #0                       ; b466
-               lda arr33,x
                beq +

                sub #1                       ; b46d (unaccessed)
                sta arr33,x                  ; unaccessed
                bne +                        ; unaccessed
                jsr sub49                    ; b475 (unaccessed)
                lda arr34,x                  ; unaccessed
                and #%01111111               ; unaccessed
                sta arr34,x                  ; unaccessed

+               inx                          ; b480
                cpx #5
                bne -
                lda ram79
                bmi +
                ora ram78
                beq +
                jmp cod8
+               lda ram77
                beq +
                lda #0
                sta ram77
                lda ram76
                jsr sub47
+               ldx #0
-               lda arr33,x
                beq +
                lda #0                       ; b4a9 (unaccessed)
                sta arr33,x                  ; unaccessed
                jsr sub49                    ; unaccessed
+               jsr sub49                    ; b4b1
                lda arr34,x
                and #%01111111
                sta arr34,x
                inx
                cpx #5
                bne -
                lda arr28+3
                beq +

                sub #1                       ; b4c6 (unaccessed)
                sta ram76                    ; unaccessed
                lda #1                       ; unaccessed
                sta ram77                    ; unaccessed
                jmp +++                      ; unaccessed

+               lda arr28+4                  ; b4d4
                beq ++
                sub #1
                sta arr28+5
                inc ram76
                lda ram76
                cmp arr27+0
                beq +
                lda #1                       ; b4ea (unaccessed)
                sta ram77                    ; unaccessed
                jmp +++                      ; unaccessed
+               lda #0                       ; b4f2
                sta ram76
                lda #1
                sta ram77
                jmp +++
++              inc ram75                    ; b4ff
                lda ram75
                cmp arr27+1
                bne +++
                inc ram76
                lda ram76
                cmp arr27+0
                beq +
                sta ram77
                jmp +++
+               ldx #0                       ; b51b (unaccessed)
                stx ram76                    ; unaccessed
                inx                          ; unaccessed
                stx ram77                    ; unaccessed
+++             jsr sub53                    ; b524
cod8            sec                          ; b527
                lda ram78
                sbc ram80
                sta ram78
                lda ram79
                sbc ram81
                sta ram79
                ldx #0
-               lda arr34,x
                beq +

                sub #1                       ; b541 (unaccessed)
                sta arr34,x                  ; unaccessed
                bne +                        ; unaccessed
                sta arr31,x                  ; b549 (unaccessed)
                sta arr66,x                  ; unaccessed
                sta arr65,x                  ; unaccessed
                sta arr40,x                  ; unaccessed
                sta arr39,x                  ; unaccessed

+               inx                          ; b558
                cpx #5
                bne -
                ldx #0
-               jsr sub56
                lda arr31,x
                beq +
                jsr sub62
+               jsr sub57
                inx
                cpx #4
                bne -
                jsr sub68
                rts

sub49           ldy arr37,x                  ; b576
                beq +
                dey
                tya
                sta arr37,x
                rts
+               sty arr28+2
                lda #$0f
                sta arr28+1
                lda arr29,x
                sta ptr9+0
                lda arr30,x
                sta ptr9+1
                ;
cod9            lda (ptr9),y                 ; b593
                bpl +
                jmp cod13
+               beq cod10
                cmp #$7f
                bne +
                jmp cod12
+               cmp #$7e
                bne +
                jmp cod11                    ; b5a7 (unaccessed)
+               sta arr31,x                  ; b5aa
                jsr sub52
                lda arr34,x
                bmi +
                lda #0
                sta arr34,x
+               jsr sub65
                lda #0
                sta arr35,x
                lda arr28+1
                sta arr55,x
                lda #0
                lda arr56,x
                and #%11110000
                sta arr56,x
                lsr a
                lsr a
                lsr a
                lsr a
                ora arr56,x
                sta arr56,x
                lda arr63,x
                cmp #6
                beq +
                cmp #8
                bne ++
+               lda #0                       ; b5e7 (unaccessed)
                sta arr63,x                  ; unaccessed
++              cpx #2                       ; b5ec
                bcc +
                jmp cod14
+               lda #0
                sta arr44,x
cod10           jmp cod14                    ; b5f8

cod11           lda arr35,x                  ; b5fb (unaccessed)
                cmp #1                       ; unaccessed
                beq cod10                    ; unaccessed
                lda #1                       ; b602 (unaccessed)
                sta arr35,x                  ; unaccessed
                jsr sub64                    ; unaccessed
                jmp cod14                    ; unaccessed

cod12           lda #0                       ; b60d
                sta arr31,x
                sta arr55,x
                sta arr66,x
                sta arr65,x
                sta arr40,x
                sta arr39,x
                cpx #2
                bcs +
+               jmp cod14
-               pla                          ; b628
                asl a
                asl a
                asl a
                and #%01111000
                sta arr32,x
                iny
                jmp cod9
--              pla                          ; b635
                and #%00001111
                asl a
                jsr sub66
                iny
                jmp cod9
cod13           pha                          ; b640
                and #%11110000
                cmp #$f0
                beq -
                cmp #$e0
                beq --
                pla
                and #%01111111
                sty ram62
                tay
                lda jump_table1,y
                sta ptr8+0
                iny
                lda jump_table1,y
                sta ptr8+1
                ldy ram62
                iny
                jmp (ptr8)
-               sta arr37,x                  ; b662
                jmp cod15
cod14           lda arr38,x                  ; b668
                cmp #$ff
                bne -
                iny
                lda (ptr9),y
                sta arr37,x
cod15           clc                          ; b675
                iny
                tya
                adc ptr9+0
                sta arr29,x
                lda #0
                adc ptr9+1
                sta arr30,x
                lda arr28+2
                beq +
                sta arr44,x                  ; b689 (unaccessed)
                lda #0                       ; unaccessed
                sta arr28+2                  ; unaccessed
+               rts                          ; b691

sub50           lda (ptr9),y                 ; b692
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
                dw sub51                     ; b6ce (unaccessed)
                dw sub51                     ; b6d0 (unaccessed)

jumptbl1a       jsr sub50                    ; b6d2 (unaccessed)
                jsr sub66                    ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1b       jsr sub50                    ; b6db
                sta arr38,x
                jmp cod9

jumptbl1c       lda #$ff                     ; b6e4
                sta arr38,x
                jmp cod9

jumptbl1d       jsr sub50                    ; b6ec (unaccessed)
                sta arr27+2                  ; unaccessed
                jsr sub54                    ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1e       jsr sub50                    ; b6f8 (unaccessed)
                sta arr27+3                  ; unaccessed
                jsr sub54                    ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1f       jsr sub50                    ; b704 (unaccessed)
                sta arr28+3                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1g       jsr sub50                    ; b70d
                sta arr28+4
                jmp cod9

jumptbl1h       jsr sub50                    ; b716 (unaccessed)
                lda #0                       ; unaccessed
                sta ram74                    ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1i       jsr sub50                    ; b721 (unaccessed)
                sta arr28+1                  ; unaccessed
                sta arr55,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1j       jsr sub50                    ; b72d
                sta arr64,x
                lda #2
                sta arr63,x
                jmp cod9

jumptbl1k       jsr sub50                    ; b73b (unaccessed)
                sta arr64,x                  ; unaccessed
                lda #3                       ; unaccessed
                sta arr63,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1l       jsr sub50                    ; b749
                sta arr64,x
                lda #4
                sta arr63,x
                jmp cod9

jumptbl1m       jsr sub50                    ; b757
                sta arr64,x
                lda #0
                sta arr67,x
                lda #1
                sta arr63,x
                jmp cod9

jumptbl1n       lda #0                       ; b76a
                sta arr64,x
                sta arr63,x
                sta arr66,x
                sta arr65,x
                jmp cod9

jumptbl1o       jsr sub50                    ; b77b (unaccessed)
                sta arr28+2                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1p       jsr sub50                    ; b784
                pha
                lda arr70,x
                bne ++
                lda arr26+4
                and #%00000010
                beq +
                lda #$30                     ; b794 (unaccessed)
+               sta arr68,x                  ; b796
++              pla                          ; b799
                pha
                and #%11110000
                sta arr69,x
                pla
                and #%00001111
                sta arr70,x
                jmp cod9

jumptbl1q       jsr sub50                    ; b7a9 (unaccessed)
                pha                          ; unaccessed
                and #%11110000               ; unaccessed
                sta arr72,x                  ; unaccessed
                pla                          ; unaccessed
                and #%00001111               ; unaccessed
                sta arr73,x                  ; unaccessed
                cmp #0                       ; unaccessed
                beq +                        ; unaccessed
                jmp cod9                     ; b7bc (unaccessed)
+               sta arr71,x                  ; b7bf (unaccessed)
                jmp cod9                     ; unaccessed

jumptbl1r       jsr sub50                    ; b7c5 (unaccessed)
                sta arr36,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1s       lda #$80                     ; b7ce (unaccessed)
                sta arr36,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1t       jsr sub50                    ; b7d6 (unaccessed)
                sta arr33,x                  ; unaccessed
                dey                          ; unaccessed
                jmp cod15                    ; unaccessed

jumptbl1u       jsr sub50                    ; b7e0
                sta arr56,x
                clc
                asl a
                asl a
                asl a
                asl a
                ora arr56,x
                sta arr56,x
                jmp cod9

jumptbl1v       jsr sub50                    ; b7f4 (unaccessed)
                sta arr64,x                  ; unaccessed
                lda #5                       ; unaccessed
                sta arr63,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1x       jsr sub50                    ; b802 (unaccessed)
                sta arr64,x                  ; unaccessed
                lda #7                       ; unaccessed
                sta arr63,x                  ; unaccessed
                jmp cod9                     ; unaccessed

jumptbl1y       jsr sub50                    ; b810
                sta arr43,x
                jmp cod9

jumptbl1z       jsr sub50                    ; b819 (unaccessed)
                ora #%10000000               ; unaccessed
                sta arr34,x                  ; unaccessed
                jmp cod9                     ; unaccessed

sub51           sub #1                       ; b824
                cpx #3
                beq +
                asl a
                sty ram62
                tay
cod16           lda (ptr10),y                ; b82f
                sta arr40,x
                iny
                lda (ptr10),y
                sta arr39,x
                ldy ram62
                rts
+               and #%00001111               ; b83d
                ora #%00010000
                sta arr40,x
                lda #0
                sta arr39,x
                rts

sub52           sub #1                       ; b84a
                cpx #3
                beq +++
                asl a
                sty ram62
                tay
                lda arr63,x
                cmp #2
                bne ++
                lda (ptr10),y
                sta arr66,x
                iny
                lda (ptr10),y
                sta arr65,x
                ldy ram62
                lda arr40,x
                ora arr39,x
                bne +
                lda arr66,x
                sta arr40,x
                lda arr65,x
                sta arr39,x
+               rts
++              jmp cod16                    ; b87e
                rts                          ; b881 (unaccessed)
+++             ora #%00010000               ; b882
                pha
                lda arr63,x
                cmp #2
                bne ++

                pla                          ; b88c (unaccessed)
                sta arr66,x                  ; unaccessed
                lda #0                       ; unaccessed
                sta arr65,x                  ; unaccessed
                lda arr40,x                  ; unaccessed
                ora arr39,x                  ; unaccessed
                bne +                        ; unaccessed
                lda arr66,x                  ; b89d (unaccessed)
                sta arr40,x                  ; unaccessed
                lda arr65,x                  ; unaccessed
                sta arr39,x                  ; unaccessed
+               rts                          ; b8a9 (unaccessed)

++              pla                          ; b8aa
                sta arr40,x
                lda #0
                sta arr39,x
                rts

sub53           clc                          ; b8b4
                lda ram78
                adc ram82
                sta ram78
                lda ram79
                adc arr28+0
                sta ram79
                rts

sub54           tya                          ; b8c8
                pha
                lda arr27+3
                sta ram67
                lda #0
                sta ram68
                ldy #3
-               asl ram67
                rol ram68
                dey
                bne -
                lda ram67
                sta ram65
                lda ram68
                tay
                asl ram67
                rol ram68
                clc
                lda ram65
                adc ram67
                sta ram65
                tya
                adc ram68
                sta ram66
                lda arr27+2
                sta ram67
                lda #0
                sta ram68
                jsr sub55
                lda ram65
                sta ram80
                lda ram66
                sta ram81
                pla
                tay
                rts

sub55           lda #0                       ; b90c
                sta ram70
                ldy #$10
-               asl ram65
                rol ram66
                rol a
                rol ram70
                pha
                cmp ram67
                lda ram70
                sbc ram68
                bcc +
                sta ram70
                pla
                sbc ram67
                pha
                inc ram65
+               pla
                dey
                bne -
                sta ram69
                rts

sub56           lda arr43,x                  ; b931
                beq cod17
                lda arr43,x
                and #%00001111
                sta ram62
                sec
                lda arr32,x
                sbc ram62
                bpl +
                lda #0
+               sta arr32,x
                lda arr43,x
                lsr a
                lsr a
                lsr a
                lsr a
                sta ram62
                clc
                lda arr32,x
                adc ram62
                bpl +
                lda #$7f                     ; b95b (unaccessed)
+               sta arr32,x                  ; b95d
cod17           lda arr63,x                  ; b960
                beq rts7
                cmp #1
                beq +
                cmp #2
                beq ++
                cmp #3
                beq +++
                cmp #6
                beq cod18
                cmp #8
                beq cod19
                cmp #5
                beq cod20
                cmp #7
                beq cod20
                jmp cod24
+               jmp cod27
++              jmp cod22                    ; b987
+++             jmp cod23                    ; b98a (unaccessed)
cod18           jmp cod25                    ; b98d (unaccessed)
cod19           jmp cod26                    ; b990 (unaccessed)
cod20           jmp cod21                    ; b993 (unaccessed)
rts7            rts                          ; b996

                ; b997-ba0f: unaccessed code
cod21           lda arr40,x                  ; b997
                pha
                lda arr39,x
                pha
                lda arr64,x
                and #%00001111
                sta ram62
                lda arr63,x
                cmp #5
                beq ++
                lda arr31,x                  ; b9ad
                sub ram62
                bpl +
                lda #1                       ; b9b5
+               bne +                        ; b9b7
                lda #1                       ; b9b9
+               jmp +                        ; b9bb
++              lda arr31,x                  ; b9be
                add ram62
                cmp #$60
                bcc +
                lda #$60                     ; b9c8
+               sta arr31,x                  ; b9ca
                jsr sub51
                lda arr40,x
                sta arr66,x
                lda arr39,x
                sta arr65,x
                lda arr64,x
                lsr a
                lsr a
                lsr a
                ora #%00000001
                sta arr64,x
                pla
                sta arr39,x
                pla
                sta arr40,x
                clc
                lda arr63,x
                adc #1
                sta arr63,x
                cpx #3
                bne ++
                cmp #6                       ; b9fc
                beq +
                lda #6                       ; ba00
                sta arr63,x
                jmp cod17
+               lda #8                       ; ba08
                sta arr63,x
++              jmp cod17                    ; ba0d

sub57           lda arr40,x                  ; ba10
                sta arr41,x
                lda arr39,x
                sta arr42,x
                lda arr36,x
                cmp #$80
                beq +

                ; ba23-ba4a: unaccessed code
                lda arr31,x                  ; ba23
                beq +
                clc                          ; ba28
                lda arr41,x
                adc #$80
                sta arr41,x
                lda arr42,x
                adc #0
                sta arr42,x
                sec
                lda arr41,x
                sbc arr36,x
                sta arr41,x
                lda arr42,x
                sbc #0
                sta arr42,x

+               jsr sub60                    ; ba4b
                jsr sub61
                rts
cod22           lda arr64,x                  ; ba52
                beq +++
                lda arr66,x
                ora arr65,x
                beq +++
                lda arr39,x
                cmp arr65,x
                bcc ++
                bne +
                lda arr40,x
                cmp arr66,x
                bcc ++
                bne +
                jmp rts7
+               lda arr64,x
                sta ptr7+0
                lda #0
                sta ptr7+1
                jsr sub59
                cmp arr65,x
                bcc +
                bmi +
                bne +++
                lda arr40,x
                cmp arr66,x
                bcc +
                jmp rts7
++              lda arr64,x                  ; ba96
                sta ptr7+0
                lda #0
                sta ptr7+1
                jsr sub58
                lda arr65,x
                cmp arr39,x
                bcc +
                bne +++
                lda arr66,x
                cmp arr40,x
                bcc +
                jmp rts7
+               lda arr66,x                  ; bab7
                sta arr40,x
                lda arr65,x
                sta arr39,x
+++             jmp rts7                     ; bac3

cod23           lda arr64,x                  ; bac6 (unaccessed)
                sta ptr7+0                   ; unaccessed
                lda #0                       ; unaccessed
                sta ptr7+1                   ; unaccessed
                jsr sub59                    ; unaccessed
                jsr sub67                    ; unaccessed
                jmp rts7                     ; unaccessed

cod24           lda arr64,x                  ; bad8
                sta ptr7+0
                lda #0
                sta ptr7+1
                jsr sub58
                jsr sub67
                jmp rts7

sub58           clc                          ; baea
                lda arr40,x
                adc ptr7+0
                sta arr40,x
                lda arr39,x
                adc ptr7+1
                sta arr39,x
                bcc +
                lda #$ff                     ; bafd (unaccessed)
                sta arr40,x                  ; unaccessed
                sta arr39,x                  ; unaccessed
+               rts                          ; bb05

sub59           sec                          ; bb06
                lda arr40,x
                sbc ptr7+0
                sta arr40,x
                lda arr39,x
                sbc ptr7+1
                sta arr39,x
                bcs +
                lda #0                       ; bb19 (unaccessed)
                sta arr40,x                  ; unaccessed
                sta arr39,x                  ; unaccessed
+               rts                          ; bb21

                ; bb22-bb85: unaccessed code
cod25           sec                          ; bb22
                lda arr40,x
                sbc arr64,x
                sta arr40,x
                lda arr39,x
                sbc #0
                sta arr39,x
                bmi +
                cmp arr65,x                  ; bb36
                bcc +
                bne ++                       ; bb3b
                lda arr40,x                  ; bb3d
                cmp arr66,x
                bcc +
                jmp rts7                     ; bb45
cod26           clc                          ; bb48
                lda arr40,x
                adc arr64,x
                sta arr40,x
                lda arr39,x
                adc #0
                sta arr39,x
                cmp arr65,x
                bcc ++
                bne +                        ; bb5f
                lda arr40,x                  ; bb61
                cmp arr66,x
                bcs +
                jmp rts7                     ; bb69
+               lda arr66,x                  ; bb6c
                sta arr40,x
                lda arr65,x
                sta arr39,x
                lda #0
                sta arr63,x
                sta arr66,x
                sta arr65,x
++              jmp rts7                     ; bb83

cod27           lda arr67,x                  ; bb86
                cmp #1
                beq +
                cmp #2
                beq ++
                lda arr31,x
                jsr sub51
                inc arr67,x
                jmp rts7
+               lda arr64,x
                lsr a
                lsr a
                lsr a
                lsr a
                clc
                adc arr31,x
                jsr sub51
                lda arr64,x
                and #%00001111
                bne +
                sta arr67,x                  ; bbb2 (unaccessed)
                jmp rts7                     ; unaccessed
+               inc arr67,x                  ; bbb8
                jmp rts7
++              lda arr64,x                  ; bbbe
                and #%00001111
                clc
                adc arr31,x
                jsr sub51
                lda #0
                sta arr67,x
                jmp rts7

sub60           lda arr70,x                  ; bbd2
                bne +
                rts
+               clc
                adc arr68,x
                and #%00111111
                sta arr68,x
                cmp #$10
                bcc +
                cmp #$20
                bcc ++
                cmp #$30
                bcc +++
                sub #$30
                sta ram62
                sec
                lda #$0f
                sbc ram62
                ora arr69,x
                tay
                lda dat44,y
                jmp cod28
+               ora arr69,x
                tay
                lda dat44,y
                sta ptr7+0
                lda #0
                sta ptr7+1
                jmp +
++              sub #$10                     ; bc11
                sta ram62
                sec
                lda #$0f
                sbc ram62
                ora arr69,x
                tay
                lda dat44,y
                sta ptr7+0
                lda #0
                sta ptr7+1
                jmp +
+++             sub #$20                     ; bc2b
                ora arr69,x
                tay
                lda dat44,y
cod28           eor #%11111111               ; bc35
                sta ptr7+0
                lda #$ff
                sta ptr7+1
                clc
                lda ptr7+0
                adc #1
                sta ptr7+0
                lda ptr7+1
                adc #0
                sta ptr7+1
+               lda arr26+4                  ; bc4a
                and #%00000010
                beq +

                ; bc51-bc6b: unaccessed code
                lda #$0f                     ; bc51
                clc
                adc arr69,x
                tay
                clc
                lda dat44,y
                adc #1
                adc ptr7+0
                sta ptr7+0
                lda ptr7+1
                adc #0
                sta ptr7+1
                lsr ptr7+1
                ror ptr7+0

+               sec                          ; bc6c
                lda arr41,x
                sbc ptr7+0
                sta arr41,x
                lda arr42,x
                sbc ptr7+1
                sta arr42,x
                rts

                clc                          ; bc7e (unaccessed)
                lda arr41,x                  ; unaccessed
                adc ptr7+0                   ; unaccessed
                sta arr41,x                  ; unaccessed
                lda arr42,x                  ; unaccessed
                adc ptr7+1                   ; unaccessed
                sta arr42,x                  ; unaccessed
                rts                          ; unaccessed

sub61           lda arr73,x                  ; bc90
                bne +
                lda #0
                sta arr74,x
                rts

                ; bc9b-bccd: unaccessed code
+               clc                          ; bc9b
                adc arr71,x
                and #%00111111
                sta arr71,x
                lsr a
                cmp #$10
                bcc +
                sub #$10                     ; bca9
                sta ram62
                sec
                lda #$0f
                sbc ram62
                ora arr72,x
                tay
                lda dat44,y
                lsr a
                sta ram62
                jmp ++
+               ora arr72,x                  ; bcc0
                tay
                lda dat44,y
                lsr a
                sta ram62
++              sta arr74,x                  ; bcca
                rts

sub62           lda arr46,x                  ; bcce
                beq +
                sta ptr8+1
                lda arr45,x
                sta ptr8+0
                lda arr57,x
                cmp #$ff
                beq +
                jsr sub63
                sta arr57,x
                lda arr28+7
                sta arr55,x
+               lda arr48,x
                beq cod32
                sta ptr8+1
                lda arr47,x
                sta ptr8+0
                lda arr58,x
                cmp #$ff
                beq cod31
                jsr sub63
                sta arr58,x
                lda arr31,x
                beq cod32
                ldy #3
                lda (ptr8),y
                beq cod29
                cmp #1
                beq +++

                ; bd15-bd2f: unaccessed code
                clc                          ; bd15
                lda arr31,x
                adc arr28+7
                cmp #1
                bcc +
                cmp #$5f                     ; bd20
                bcc ++
                lda #$5f                     ; bd24
                bne ++
+               lda #1                       ; bd28
++              sta arr31,x                  ; bd2a
                jmp cod30

+++             lda arr28+7                  ; bd30
                add #1
                jmp cod30
cod29           clc                          ; bd39
                lda arr31,x
                adc arr28+7
                beq +
                bpl ++
+               lda #1                       ; bd44 (unaccessed)
++              cmp #$60                     ; bd46
                bcc cod30
                lda #$60                     ; bd4a (unaccessed)
cod30           jsr sub51                    ; bd4c
                lda #1
                sta arr62,x
                jmp cod32
cod31           ldy #3                       ; bd57
                lda (ptr8),y
                beq cod32
                lda arr62,x
                beq cod32
                lda arr31,x
                jsr sub51
                lda #0
                sta arr62,x
cod32           lda arr50,x                  ; bd6d
                beq +++

                ; bd72-bda3: unaccessed code
                sta ptr8+1                   ; bd72
                lda arr49,x
                sta ptr8+0
                lda arr59,x
                cmp #$ff
                beq +++
                jsr sub63                    ; bd80
                sta arr59,x
                clc
                lda arr28+7
                adc arr40,x
                sta arr40,x
                lda arr28+7
                bpl +
                lda #$ff                     ; bd95
                bmi ++
+               lda #0                       ; bd99
++              adc arr39,x                  ; bd9b
                sta arr39,x
                jsr sub67

+++             lda arr52,x                  ; bda4
                beq +++                      ; bda7

                ; bda9-bded: unaccessed code
                sta ptr8+1                   ; bda9
                lda arr51,x
                sta ptr8+0
                lda arr60,x
                cmp #$ff
                beq +++
                jsr sub63                    ; bdb7
                sta arr60,x
                lda arr28+7
                sta ptr7+0
                rol a
                bcc +
                lda #$ff                     ; bdc5
                sta ptr7+1
                jmp ++
+               lda #0                       ; bdcc
                sta ptr7+1
++              ldy #4                       ; bdd0
-               clc
                rol ptr7+0
                rol ptr7+1
                dey
                bne -
                clc
                lda ptr7+0
                adc arr40,x
                sta arr40,x
                lda ptr7+1
                adc arr39,x
                sta arr39,x
                jsr sub67

+++             lda arr54,x                  ; bdee
                beq +                        ; bdf1

                ; bdf3-be19: unaccessed code
                sta ptr8+1                   ; bdf3
                lda arr53,x
                sta ptr8+0
                lda arr61,x
                cmp #$ff
                beq +
                jsr sub63                    ; be01
                sta arr61,x
                lda arr28+7
                pha
                lda arr56,x
                and #%11110000
                sta arr56,x
                pla
                ora arr56,x
                sta arr56,x

+               rts                          ; be1a

sub63           add #4                       ; be1b
                tay
                lda (ptr8),y
                sta arr28+7
                dey
                dey
                dey
                tya
                ldy #0
                cmp (ptr8),y
                beq +
                ldy #2
                cmp (ptr8),y
                beq ++
                rts
+               iny
                lda (ptr8),y
                cmp #$ff
                bne cod33
                rts
cod33           pha                          ; be3d
                lda arr35,x
                bne +
                pla
                rts

                ; be45-be67: unaccessed code
+               ldy #2                       ; be45
                lda (ptr8),y
                bne +
                pla                          ; be4b
                rts
+               pla                          ; be4d
                lda #$ff
                rts
++              sta ram62                    ; be51
                lda arr35,x
                bne +
                dey                          ; be58
                lda (ptr8),y
                cmp #$ff
                bne cod33
                lda ram62                    ; be5f
                sub #1
                rts
+               lda ram62                    ; be65
                rts

                ; be68-bee4: unaccessed
sub64           tya                          ; be68
                pha
                lda arr46,x
                beq +
                sta ptr8+1                   ; be6f
                lda arr45,x
                sta ptr8+0
                ldy #2
                lda (ptr8),y
                beq +
                sub #1                       ; be7c
                sta arr57,x
+               lda arr48,x                  ; be82
                beq +
                sta ptr8+1                   ; be87
                lda arr47,x
                sta ptr8+0
                ldy #2
                lda (ptr8),y
                beq +
                sub #1                       ; be94
                sta arr58,x
+               lda arr50,x                  ; be9a
                beq +
                sta ptr8+1                   ; be9f
                lda arr49,x
                sta ptr8+0
                ldy #2
                lda (ptr8),y
                beq +
                sub #1                       ; beac
                sta arr59,x
+               lda arr52,x                  ; beb2
                beq +
                sta ptr8+1                   ; beb7
                lda arr51,x
                sta ptr8+0
                ldy #2
                lda (ptr8),y
                beq +
                sub #1                       ; bec4
                sta arr60,x
+               lda arr54,x                  ; beca
                beq +
                sta ptr8+1                   ; becf
                lda arr53,x
                sta ptr8+0
                ldy #2
                lda (ptr8),y
                beq +
                sub #1                       ; bedc
                sta arr61,x
+               pla                          ; bee2
                tay
                rts

sub65           lda #0                       ; bee5
                sta arr57,x
                sta arr58,x
                sta arr59,x
                sta arr60,x
                sta arr61,x
                rts

sub66           sta ram64                    ; bef7
                sty ram62
                ldy #0
                add arr26+2
                sta ptr7+0
                tya
                adc arr26+3
                sta ptr7+1
                clc
                lda (ptr7),y
                adc ram57
                sta ptr8+0
                iny
                lda (ptr7),y
                adc ram58
                sta ptr8+1
                lda dat43,x
                tay
                lda dat39,y
                sta ptr7+0
                iny
                lda dat39,y
                sta ptr7+1
                ldy #0
                jmp (ptr7)

dat39           hex 37 bf                    ; bf2b
                hex 37 bf 75 c0 75 c0 37 bf  ; bf2d (unaccessed)
                hex 75 c0                    ; bf35 (unaccessed)

                lda (ptr8),y                 ; bf37
                sta ram64
                iny
                ror ram64
                bcc ++
                clc
                lda (ptr8),y
                adc ram57
                sta ptr7+0
                iny
                lda (ptr8),y
                adc ram58
                sta ptr7+1
                iny
                lda ptr7+0
                cmp arr45,x
                bne +
                lda ptr7+1
                cmp arr46,x
                bne +
                jmp +++
+               lda ptr7+0
                sta arr45,x
                lda ptr7+1
                sta arr46,x
                lda #0
                sta arr57,x
                jmp +++
++              lda #0                       ; bf72
                sta arr45,x
                sta arr46,x
+++             ror ram64                    ; bf7a
                bcc ++
                clc
                lda (ptr8),y
                adc ram57
                sta ptr7+0
                iny
                lda (ptr8),y
                adc ram58
                sta ptr7+1
                iny
                lda ptr7+0
                cmp arr47,x
                bne +
                lda ptr7+1
                cmp arr48,x
                bne +
                jmp +++
+               lda ptr7+0
                sta arr47,x
                lda ptr7+1
                sta arr48,x
                lda #0
                sta arr58,x
                jmp +++
++              lda #0                       ; bfb0
                sta arr47,x
                sta arr48,x
+++             ror ram64                    ; bfb8
                bcc ++                       ; bfba

                ; bfbc-bfed: unaccessed code
                clc                          ; bfbc
                lda (ptr8),y
                adc ram57
                sta ptr7+0
                iny
                lda (ptr8),y
                adc ram58
                sta ptr7+1
                iny
                lda ptr7+0
                cmp arr49,x
                bne +
                lda ptr7+1                   ; bfd2
                cmp arr50,x
                bne +
                jmp +++                      ; bfd9
+               lda ptr7+0                   ; bfdc
                sta arr49,x
                lda ptr7+1
                sta arr50,x
                lda #0
                sta arr59,x
                jmp +++

++              lda #0                       ; bfee
                sta arr49,x
                sta arr50,x
+++             ror ram64                    ; bff6
                bcc ++                       ; bff8

                ; bffa-c02b: unaccessed code
                clc                          ; bffa
                lda (ptr8),y
                adc ram57
                sta ptr7+0
                iny
                lda (ptr8),y
                adc ram58
                sta ptr7+1
                iny
                lda ptr7+0
                cmp arr51,x
                bne +
                lda ptr7+1                   ; c010
                cmp arr52,x
                bne +
                jmp +++                      ; c017
+               lda ptr7+0                   ; c01a
                sta arr51,x
                lda ptr7+1
                sta arr52,x
                lda #0
                sta arr60,x
                jmp +++

++              lda #0                       ; c02c
                sta arr51,x
                sta arr52,x
+++             ror ram64                    ; c034
                bcc ++

                ; c038-c069: unaccessed code
                clc                          ; c038
                lda (ptr8),y
                adc ram57
                sta ptr7+0
                iny
                lda (ptr8),y
                adc ram58
                sta ptr7+1
                iny
                lda ptr7+0
                cmp arr53,x
                bne +
                lda ptr7+1                   ; c04e
                cmp arr54,x
                bne +
                jmp +++                      ; c055
+               lda ptr7+0                   ; c058
                sta arr53,x
                lda ptr7+1
                sta arr54,x
                lda #0
                sta arr61,x
                jmp +++

++              lda #0                       ; c06a
                sta arr53,x
                sta arr54,x
+++             ldy ram62                    ; c072
                rts

sub67           lda dat43,x                  ; c075
                tay
                lda jump_table2,y
                sta ptr7+0
                iny
                lda jump_table2,y
                sta ptr7+1
                ldy #0
                jmp (ptr7)                   ; c086

jump_table2     dw jumptbl2b                 ; c089
                dw jumptbl2c                 ; c08b (unaccessed)
                dw rts8                      ; c08d (unaccessed)
                dw jumptbl2c                 ; c08f (unaccessed)
                dw jumptbl2b                 ; c091 (unaccessed)
                dw rts8                      ; c093 (unaccessed)

rts8            rts                          ; c095 (unaccessed)

jumptbl2b       lda arr39,x                  ; c096
                bmi ++
                cmp #8
                bcc +
                lda #7                       ; c09f (unaccessed)
                sta arr39,x                  ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr40,x                  ; unaccessed
+               rts                          ; c0a9

++              lda #0                       ; c0aa (unaccessed)
                sta arr40,x                  ; unaccessed
                sta arr39,x                  ; unaccessed
                rts                          ; unaccessed

                ; c0b3-c0cf: unaccessed code
jumptbl2c       lda arr39,x                  ; c0b3
                bmi ++
                cmp #$10                     ; c0b8
                bcc +
                lda #$0f                     ; c0bc
                sta arr39,x
                lda #$ff
                sta arr40,x
+               rts                          ; c0c6
++              lda #0                       ; c0c7
                sta arr40,x
                sta arr39,x
                rts

sub68           lda ram74                    ; c0d0
                bne +
                lda #0                       ; c0d5 (unaccessed)
                sta snd_chn                  ; unaccessed
                rts                          ; unaccessed

sub69           lda #$c0                     ; c0db
                sta joypad2
                lda #$40
                sta joypad2
                rts
+               lda arr26+5                  ; c0e6
                and #%00000001
                bne +
                jmp cod35                    ; c0ed (unaccessed)
+               lda arr31+0                  ; c0f0
                beq cod34
                lda arr32+0
                asl a
                beq cod34
                and #%11110000
                sta ram62
                lda arr55+0
                beq cod34
                ora ram62
                tax
                lda $c29f,x
                sub arr74+0
                bpl +
                lda #0                       ; c110 (unaccessed)
+               bne +                        ; c112
                lda arr32+0
                beq +
                lda #1
+               pha                          ; c11b
                lda arr56+0
                and #%00000011
                tax
                pla
                ora dat41,x
                ora #%00110000
                sta arr3+0
                lda arr42+0
                and #%11111000
                beq +
                lda #7                       ; c131 (unaccessed)
                sta arr42+0                  ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr41+0                  ; unaccessed
+               lda arr44+0                  ; c13b
                beq +

                ; c140-c15d: unaccessed code
                and #%10000000               ; c140
                beq cod35
                lda arr44+0                  ; c144
                sta arr3+1
                and #%01111111
                sta arr44+0
                jsr sub69
                lda arr41+0
                sta arr3+2
                lda arr42+0
                sta arr3+3
                jmp cod35

cod34           lda #$30                     ; c15e
                sta arr3+0
                jmp cod35
+               lda #8                       ; c165
                sta arr3+1
                jsr sub69
                lda arr41+0
                sta arr3+2
                lda arr42+0
                sta arr3+3
cod35           lda arr26+5                  ; c176
                and #%00000010
                bne +
                jmp cod37                    ; c17d (unaccessed)
+               lda arr31+1                  ; c180
                beq cod36
                lda arr32+1
                asl a
                beq cod36
                and #%11110000
                sta ram62
                lda arr55+1
                beq cod36
                ora ram62
                tax
                lda $c29f,x
                sub arr74+1
                bpl +
                lda #0                       ; c1a0 (unaccessed)
+               bne +                        ; c1a2
                lda arr32+1                  ; c1a4 (unaccessed)
                beq +                        ; unaccessed
                lda #1                       ; c1a9 (unaccessed)
+               pha                          ; c1ab
                lda arr56+1
                and #%00000011
                tax
                pla
                ora dat41,x
                ora #%00110000
                sta arr3+4
                lda arr42+1
                and #%11111000
                beq +
                lda #7                       ; c1c1 (unaccessed)
                sta arr42+1                  ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr41+1                  ; unaccessed
+               lda arr44+1                  ; c1cb
                beq +

                ; c1d0-c1ed: unaccessed code
                and #%10000000               ; c1d0
                beq cod37
                lda arr44+1                  ; c1d4
                sta arr3+5
                and #%01111111
                sta arr44+1
                jsr sub69
                lda arr41+1
                sta arr3+6
                lda arr42+1
                sta arr3+7
                jmp cod37

cod36           lda #$30                     ; c1ee
                sta arr3+4
                jmp cod37
+               lda #8                       ; c1f5
                sta arr3+5
                jsr sub69
                lda arr41+1
                sta arr3+6
                lda arr42+1
                sta arr3+7
cod37           lda arr26+5                  ; c206
                and #%00000100
                beq +++
                lda arr55+2
                beq ++
                lda arr32+2
                beq ++
                lda arr31+2
                beq ++
                lda #$81
                sta arr3+8
                lda arr42+2
                and #%11111000
                beq +
                lda #7                       ; c227 (unaccessed)
                sta arr42+2                  ; unaccessed
                lda #$ff                     ; unaccessed
                sta arr41+2                  ; unaccessed
+               lda arr41+2                  ; c231
                sta arr3+10
                lda arr42+2
                sta arr3+11
                jmp +++
++              lda #0                       ; c23e
                sta arr3+8
+++             lda arr26+5                  ; c242
                and #%00001000
                beq rts9
                lda arr31+3
                beq ++
                lda arr32+3
                asl a
                beq ++
                and #%11110000
                sta ram62
                lda arr55+3
                beq ++
                ora ram62
                tax
                lda $c29f,x
                sub arr74+3
                bpl +
                lda #0                       ; c269 (unaccessed)
+               bne +                        ; c26b
                lda arr32+3
                beq +
                lda #1
+               ora #%00110000               ; c274
                sta arr3+12
                lda #0
                sta arr3+13
                lda arr56+3
                ror a
                ror a
                and #%10000000
                sta ram62
                lda arr41+3
                and #%00001111
                eor #%00001111
                ora ram62
                sta arr3+14
                lda #0
                sta arr3+15
                beq rts9
++              lda #$30                     ; c296
                sta arr3+12
rts9            rts                          ; c29a

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

reset                                        ; c700
irq             sei
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
-               lda #$ff
                sta oam_copy,x
                lda #0
                sta ptr1,x
                pha
                sta arr8,x
                sta arr9,x
                sta arr28,x
                sta arr75,x
                sta arr76,x
                inx
                bne -
                bit ptr1+0
                stx dmc_raw
                stx dmc_len
                dex
                txs
                stx arr4+0
                lda #0
                sta dmc_start
                lda #$4c
                sta ram48
                bit ptr1+0
                nop
                nop
                nop
                nop
                nop
                nop
                lda #$82
                sta ptr3+1
                lda #$0f
                sta dmc_freq
                nop
                bit ptr1+0
                lda #$7e
                ldx #$20
                jsr sub6
                ldx #0
--              bit ppu_status
                bmi +
                ldy #$39
-               dey
                bne -
                bit ptr1+0
                inx
                jmp --
                ;
+               stx ptr1+0
                ldy #6
-               lda $c78e,y
                cmp ptr1+0
                bcs +
                dey                          ; c784 (unaccessed)
                bne -                        ; unaccessed
+               lda dat46,y                  ; c787
                sta ram4
                jmp cod38

                hex c5 b6 9f 4f 48           ; c78f (unaccessed)
                hex 3c                       ; c794
dat46           hex 00 02 01 00 02 01        ; c795 (unaccessed)
                hex 00                       ; c79b

read_joypad     ldx #1                       ; c79c
                stx buttons_changed
                stx joypad1
                dex
                stx joypad1
-               lda joypad1
                and #%00000011
                cmp #1
                rol buttons_changed
                bcc -
                ;
                ; if d-pad up and/or left pressed, ignore opposite direction
                lda buttons_changed
                and #%00001010
                lsr a
                eor #%11111111
                and buttons_changed
                sta buttons_changed
                ;
                ; in buttons_changed, ignore buttons that were also pressed in
                ; buttons_held; copy original buttons_changed to buttons_held
                tay
                eor buttons_held
                and buttons_changed
                sta buttons_changed
                sty buttons_held
                rts

sub71           lda #$ff                     ; c7c7
                ldx #$3c
-               sta oam_copy+$00,x
                sta oam_copy+$40,x
                sta oam_copy+$80,x
                sta oam_copy+$c0,x
                axs_imm 4                    ; c7d7: equiv. to 4*DEX
                bpl -
                ;
                lda #$10
                sta ram20
                rts

-               lda ram19
                beq -
                inc ram18
                jsr read_joypad
                ;
cod38           lda ram7                     ; c7e9
                asl a
                tax
                lda dat15,x
                sta ram49
                lda dat16,x
                sta ram50
                jsr ram48
                lda ram8
                sta ram7
                lda ram10
                sta ram9
                lda #0
                sta ram19
                jmp -

nmi             pha                          ; c809
                txa
                pha
                tya
                pha
                ;
                lda ram7
                cmp #$0b
                bcc +
                lda ppu_status
                and #%01000000
                ora ram51
                sta ram51
                beq +
                lda #0
                sta ram42
                lda ppu_mask_copy2
                ora #%00011110
                sta ppu_mask_copy2
                lda ram41
                cmp #$0f
                bne +
                lda ram34
                eor #%00000001
                sta ram34
                lda #0
                sta ram41
                lda #$fe
                sta oam_copy+2*4
                lda oam_copy+3
                ldy oam_copy+3*4+3
                sta oam_copy+3*4+3
                sty oam_copy+3
+               lda ram19
                beq +
                jmp nmi_end                  ; c84e (unaccessed)
+               lda ram51                    ; c851
                beq +
                ;
                lda #$30
                sta oam_copy+1
                lda #$ff
                sta oam_copy+4
                ;
                lda #3
                sta ram7
                sta ram8
                lda #2
                jsr sub40
                lda #0
                sta ram51
                ;
+               bit ppu_status
                jsr sub1
                jsr sub3
                ;
                lda ppu_mask_copy1
                sta ppu_mask
                ;
                lda ram13                    ; c87c
                sta ppu_scroll
                ldy ram16
                sty ppu_scroll
                ;
                lda #0                       ; c886
                sta oam_addr
                lda #>oam_copy
                sta oam_dma
                ;
                lda ppu_mask_copy2
                sta ppu_mask
                sta ppu_mask_copy1
                ;
                lda ppu_ctrl_copy
                sta ppu_ctrl
                sta ram5
                ;
                lda ram13
                sta ram12
                lda ram16
                sta ram15
nmi_end         jsr sub36
                inc ram19
                ;
                pla
                tay
                pla
                tax
                pla
                rti

                lda ram19                    ; c8b1 (unaccessed)
-               cmp ram19                    ; unaccessed
                bne -                        ; unaccessed
                rts                          ; unaccessed

                pad $ffe0, $00               ; c8b8 (unaccessed)

                ; ffe0-fff9: unaccessed data
                hex 20 50 52 4f 58 49 4d 49
                hex 54 59 20 53 48 49 46 54
                hex e7 b0 b4 aa 20 80 01 0e
                hex 00 f3

                ; interrupt vectors
                pad $fffa, $ff
                dw nmi, reset, irq           ; IRQ unaccessed

                pad $10000, $ff

; --- CHR ROM -----------------------------------------------------------------

                base $0000
                incbin "prox-chr.bin"
                pad $2000, $ff
