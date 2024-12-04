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
region          equ $10  ; 0/1/2=NTSC/PAL/Dendy; shared with sound engine
ram4            equ $11
ppu_ctrl_copy   equ $12
ppu_mask_copy1  equ $13
ppu_mask_copy2  equ $14
task1           equ $15
task2           equ $16
ram7            equ $17
ram8            equ $18
ram9            equ $19
hscroll1        equ $1a
hscroll2        equ $1b
ram10           equ $1c
vscroll1        equ $1d
vscroll2        equ $1e
ram11           equ $1f
ram12           equ $20
ram13           equ $21
ram14           equ $23
ram15           equ $24
ptr3            equ $25  ; 2 bytes
arr1            equ $27
ram16           equ $29
ram17           equ $2a
ram18           equ $2c
ram19           equ $2d
buttons_changed equ $2e  ; joypad buttons that were just pressed
buttons_held    equ $2f  ; all joypad buttons being held now
ptr4            equ $30  ; 2 bytes
ram20           equ $32
ram21           equ $33
ram22           equ $34
ram23           equ $36
ram24           equ $37
ram25           equ $38
ram26           equ $39
ram27           equ $3a
ram28           equ $3c
ram29           equ $3d
ram30           equ $3e
ram31           equ $3f
ram32           equ $40
ram33           equ $41
ram34           equ $42
ram35           equ $43
ram36           equ $44
ram37           equ $45
ram38           equ $47
ram39           equ $48
ram40           equ $49
ram41           equ $4a
ram42           equ $4b
ram43           equ $4c
ram44           equ $4d
ram45           equ $4e
arr2            equ $51  ; 9 bytes?
ram_shared      equ $70  ; shared with sound engine
ram49           equ $71

arr3            equ $0110
arr4            equ $0133
arr5            equ $0150
arr6            equ $0170

oam_copy        equ $0200  ; $100 bytes

arr_shared1     equ $0300  ; shared with sound engine; 256 bytes?

arr7            equ $0400
ram50           equ $0424
arr8            equ $043c
arr9            equ $0444
arr10           equ $044c
arr11           equ $0454
arr12           equ $045c
arr13           equ $0464
arr14           equ $046c
arr15           equ $0474
arr16           equ $047c
arr17           equ $0484
arr18           equ $048c
arr19           equ $0494
arr20           equ $049c
arr21           equ $04a8
arr22           equ $04b4
arr23           equ $04c0

arr_shared2     equ $0500  ; shared with sound engine; 256 bytes?

arr24           equ $0600

arr25           equ $0700

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
oam_addr        equ $2003
ppu_scroll      equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007

dmc_freq        equ $4010
dmc_raw         equ $4011
dmc_start       equ $4012
dmc_len         equ $4013
oam_dma         equ $4014
snd_chn         equ $4015
joypad1         equ $4016
joypad2         equ $4017

; entry points to sound engine
sndeng_entry1   equ sound_engine+$0000
sndeng_entry2   equ sound_engine+$0088
sndeng_entry3   equ sound_engine+$009a
sndeng_entry4   equ sound_engine+$00d7
sndeng_entry5   equ sound_engine+$00e3
sndeng_entry6   equ sound_engine+$13d8

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
macro copy _src, _dst
                ; use this only if A is ignored later
                lda _src
                sta _dst
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

cod0            rept 16                      ; 8000
                    pla
                    sta ppu_data
                endr
                tya                          ; 8040
                bne ++
                beq cod1
                ;
-               txs                          ; 8045
                ldx #$ff
                stx arr3+0
                inx
                stx ram19
rts1            rts
                ;
sub1            lda ram18                    ; 804f
                beq +
                jsr print_str
+               lda arr3+0
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
                ;
                sta ppu_addr
                pla
                sta ppu_addr
                pla
                asl a
                tay
                lda ram4
                bcc +
                ora #%00000100               ; 807a (unaccessed)
+               sta ppu_ctrl                 ; 807c
                tya
                bmi cod2
                lsr a
                bne ++
                lda #$40                     ; 8085 (unaccessed)
++              cmp #$10                     ; 8087
                bcc +
                sbc #$10
                tay
                jmp cod0

                ; 8091-80f5: unaccessed code
+               ldy #0                       ; 8091
                sbc #0
                eor #%00001111
                asl a
                asl a
                sta ptr1+0
                jmp (ptr1)
cod2            lsr a                        ; 809e
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
                lda dat1,y
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
                lda ram4
                bcc +
                ora #%00000100               ; 811a (unaccessed)
+               sta ppu_ctrl                 ; 811c
                txa
                bmi cod3
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
                sta ram18
                rts
cod3            lsr a                        ; 8145
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
dat1            hex b3 b6 b9 bc bf c2 c5 c8  ; 8159
                hex cb ce d1 d4 d7 da dd e0

cod4            rept 32                      ; 8169
                    pla
                    sta ppu_data
                endr
                jmp (ptr3)                   ; 81e9

                pad $8200, $00               ; 81ec (unaccessed)

sub2            lda ram4                     ; 8200
                sta ppu_ctrl
                lda ram15
                beq rts2
sub3            tsx                          ; 8209
                stx ptr1+0
                ldx #$4f
                txs
                ldx ram16
                stx ppu_addr
                ldy ram17
                sty ppu_addr
                lda #$20
                sta ptr3+0
                jmp cod4

                ; $8220: indirectly accessed
                stx ppu_addr
                tya
                ora #%00100000
                sta ppu_addr
                ldx #$6f
                txs
                lda #$33
                sta ptr3+0
                jmp cod4

                ; $8233: indirectly accessed
                ldx ptr1+0
                txs
                lda #0
                sta ram15
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
                dw arr7                      ;  2
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

sub4            sta ram38                    ; 86c8
                stx ram39
                sta ram40
                stx ram41
sub5            clc                          ; 86d0
                lda ram38
                adc #$b3
                sta ram38
                adc ram39
                sta ram39
                adc ram40
                sta ram40
                eor ram38
                and #%01111111
                tax
                lda ram40
                adc ram41
                sta ram41
                eor ram39
                rts

sub6            lsr a                        ; 86ed
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

sub7            bit buttons_changed          ; 871d
                bpl +
                lda ram28
                eor #%00000001
                sta ram28
                lda #1
                jsr sndeng_entry5
                lda #$10
                sta ram35
+               jsr sub8
                lda buttons_held
                and #%01000000
                beq +
                jsr sub8
+               lda task2
                cmp #3
                beq +
                jsr sub10
                jmp sub9
+               jsr sub9                     ; 8748 (unaccessed)
                lda #$30                     ; unaccessed
                sta oam_copy+0*4+1           ; unaccessed
                rts                          ; unaccessed

dat2            hex 00 00 ff 00              ; 8751 (last byte unaccessed)
                hex 00 00 ff 00              ; 8755 (last byte unaccessed)
                hex 00 00 ff                 ; 8759
dat3            hex 00 c0 40 00              ; 875c (last byte unaccessed)
                hex 00 88 78 00              ; 8760 (last byte unaccessed)
                hex 00 88 78                 ; 8764
dat4            hex 00 00 00 00              ; 8767 (last byte unaccessed)
                hex 00 00 00 00              ; 876b (last byte unaccessed)
                hex ff ff ff                 ; 876f
dat5            hex 00 00 00 00              ; 8772 (last byte unaccessed)
                hex c0 88 88 00              ; 8776 (last byte unaccessed)
                hex 40 78 78                 ; 877a

sub8            lda buttons_held             ; 877d
                and #%00001111
                ldy arr2+2
                cpy #0
                bne +
                and #%11110111               ; 8787 (unaccessed)
+               cpy #$e7                     ; 8789
                bcc +
                and #%11111011
+               tax
                lda arr2+1
                clc
                adc dat3,x
                sta arr2+1
                lda arr2+0
                adc dat2,x
                sta arr2+0
                cmp #$50
                bcs +
                sbc #$4f
                add ram31
                sta ram31
                lda #$50
                sta arr2+0
+               lda arr2+0
                cmp #$85
                bcc +
                sbc #$84
                add ram31
                sta ram31
                lda #$84
                sta arr2+0
+               lda arr2+3
                clc
                adc dat5,x
                sta arr2+3
                lda arr2+2
                adc dat4,x
                sta arr2+2
                rts

dat6            hex 00 24 00                 ; 87cf

sub9            lda arr2+2                   ; 87d2
                sta oam_copy+0*4+0
                sta oam_copy+3*4+0
                ;
                copy #0, oam_copy+0*4+2
                copy #2, oam_copy+3*4+2
                copy #4, oam_copy+0*4+1
                lda ram12
                lsr a
                lsr a
                lsr a
                lda #$0e
                adc #0
                sta oam_copy+3*4+1
                ;
                ldy ram28
                lda arr2+0
                clc
                adc dat6,y
                sta oam_copy+0*4+3
                ;
                iny
                lda arr2+0
                clc
                adc dat6,y
                sta oam_copy+3*4+3
                sta oam_copy+2*4+3
                ;
                copy #$fe, oam_copy+2*4+0
                ;
                ldy ram35
                beq +
                dey
                sty ram35
                tya
                lsr a
                lsr a
                sta oam_copy+2*4+1
                copy arr2+2, oam_copy+2*4+0
                copy #0,     oam_copy+2*4+2
+               rts

sub10           lda ram29                    ; 882a
                beq rts3

                ; 882e-884d: unaccessed code
                cmp #$0b                     ; 882e
                lda #$10
                bcc +
                lda #$20                     ; 8834
+               lda #$10
                sta oam_copy+1*4+1
                lda #1
                sta oam_copy+1*4+2
                lda arr2+0
                sta oam_copy+1*4+3
                jsr arr2+2
                add #6
                sta oam_copy+1*4+0

rts3            rts                          ; 884e

sub11           lda #$10                     ; 884f
                sta ptr1+0
                ldx ram14
                ldy ram37
                beq rts4

                ; 8859-889c: unaccessed code
                cpy #5                       ; 8859
                bcc cod5
                ldy #1                       ; 885d
                ;
cod5            lda ptr1+0
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
                bne cod5
                ;
                lda ram37
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
+               stx ram14

rts4            rts                          ; 889d
sub12           ldx ram14                    ; 889e
                beq rts5
                lda ram11
                sub ram34
                rol a
                eor #%00000001
                ror a
                lda ram33
                adc #0
                sta ptr2+1
                ldy #$0b
                sty ptr2+0
-               ldy ptr2+0
                lda ptr2+1
                beq cod6
                sta ptr1+1
                lda dat8,y
                clc
                adc arr23,y
                jsr sub6
                sta ptr1+1
                ldy ptr2+0
                lda ptr1+0
                clc
                adc arr22,y
                sta arr22,y
                lda arr21,y
                adc ptr1+1
                sta arr21,y
                bit ptr1+1
                bmi +
                bcc cod6
                lda #0
                bcs ++                       ; always
                ;
+               bcs cod6                     ; 88e6 (unaccessed)
                lda #$ff                     ; 88e8 (unaccessed)
++              sta arr21,y                  ; 88ea
                lda dat7,y
                adc ram41
                sta arr20,y
                lda ram40
                and #%01111111
                sta arr23,y
cod6            lda arr21,y                  ; 88fc
                sta oam_copy,x
                lda arr20,y
                sta oam_copy+3,x
                lda #$23
                sta oam_copy+2,x
                lda #$fe
                sta oam_copy+1,x
                axs_imm $fc                  ; 8912: equiv. to 4*INX
                beq +
                dec ptr2+0
                bpl -
+               stx ram14
rts5            rts

dat7            ; $891d (partially unaccessed)
                hex ec 42 73 61 2d 94 28 22
                hex c9 e1 62 a9

dat8            ; $8929
                db  4*8,  5*8,  6*8,  7*8, 8*8, 9*8, 10*8, 11*8
                db 12*8, 13*8, 14*8, 15*8

                ; 8935-899d: unaccessed code
                rts                          ; 8935 (could be data byte $60)
                lda arr2+0                   ; 8936
                pha
                add #2
                sta arr2+0
                lda arr2+2
                pha
                add #2
                sta arr2+2
                ldx #0
                ldy #0
                ;
--              lda arr2,y
                sty ptr1+0
                ldy #8
-               sta arr8,x
                inx
                dey
                bne -
                ldy ptr1+0
                iny
                cpy #8
                bcc --
                ;
                pla
                sta arr2+2
                pla
                sta arr2+0
                ldy #7
                ;
-               jsr sub5
                lsr a
                lsr a
                sub #$20
                php
                clc
                adc arr15,y
                sta arr15,y
                lda arr14,y
                adc #0
                plp
                sbc #0
                sta arr14,y
                txa
                lsr a
                sub #$20
                php
                clc
                adc arr18,y
                sta arr18,y
                lda arr17,y
                adc #0
                plp
                sbc #0
                sta arr17,y
                dey
                bpl -
                ;
                rts

rts6            rts                          ; 899e

                ; 899f-8a27: unaccessed code
                ldy ram14                    ; 899f
                ldx #7
                ;
-               lda arr10,x                  ; 89a3
                clc
                adc arr16,x
                sta arr10,x
                lda arr9,x
                adc arr15,x
                sta arr9,x
                lda arr8,x
                adc arr14,x
                sta arr8,x
                sta oam_copy+3,y
                bit ram7
                bmi +
                ror a                        ; 89c6
                eor arr14,x
                bpl +
                jsr sub13                    ; 89cc
                jmp ++
                ;
+               lda arr13,x                  ; 89d2
                clc
                adc arr19,x
                sta arr13,x
                ;
                lda arr12,x
                adc arr18,x
                sta arr12,x
                ;
                lda arr11,x
                adc arr17,x
                sta arr11,x
                bit ram7
                bmi +
                ror a                        ; 89f2
                eor arr17,x
                bpl +
                jsr sub13                    ; 89f8
                jmp ++
+               lda arr11,x                  ; 89fe
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
                ;
                sty ram14
                rts

sub13           lda #$ff                     ; 8a19
                sta arr11,x
                sta arr17,x
                sta arr18,x
                sta arr19,x
                rts

task_jump_table ; $8a28 (partially unaccessed)
                dw sub14                     ;  0
                dw sub17                     ;  1
                dw sub19                     ;  2
                dw sub21                     ;  3
                dw sub22                     ;  4
                dw sub23                     ;  5
                dw sub24                     ;  6
                dw sub25                     ;  7
                dw sub27                     ;  8
                dw sub26                     ;  9
                dw sub28                     ; 10
                dw sub18                     ; 11
                dw sub20                     ; 12

ppu_fill        ; $8a42; write A to PPU Y*8 times
                ; called by: sub16
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                dey
                bne ppu_fill
                rts

sub14           lda #0                       ; 8a5e
                sta ram23
                lda #1
                sta task1
                sta task2
                jsr sub15
                jsr sub42
                jmp sub17

sub15           ldy #$23                     ; 8a71
-               lda str_palette,y
                sta arr7,y
                dey
                bpl -
                lda #0
                sta ram50
                rts

sub16           bit ppu_status               ; 8a82
                ;
                ; clear AT0
                lda #>ppu_at0
                sta ppu_addr
                lda #<ppu_at0
                sta ppu_addr
                lda #0
                ldy #8
                jsr ppu_fill
                ;
                ; clear AT2
                ldy #>ppu_at2
                sty ppu_addr
                ldy #<ppu_at2
                sty ppu_addr
                ldy #8
                jsr ppu_fill
                ;
                ; clear array
                lda #0
                ldy #9
-               sta arr2-1,y
                dey
                bne -
                ;
                jsr clear_oam_copy
                ldy #11
                ;
-               jsr sub5
                sta arr21,y
                jsr sub5
                sta arr20,y
                dey
                bpl -
                ;
                jsr sub12
                jsr sub34
                rts

sub17           jsr clear_oam_copy           ; 8aca
                lda ram7
                cmp #1
                beq +
                lda #0
                sta ppu_mask_copy2
                sta ppu_mask_copy1
                sta ppu_mask
                jsr sndeng_entry3
                jsr sub33
                lda #$0b
                sta ram9
                lda #1
                sta ram8
                lda #%00011110
                sta ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
+               jsr sub19
                lda task1
                cmp task2
                beq +
                lda #$80
                sta ram8
+               rts

sub18           lda #0                       ; 8b03
                sta ram33
                jsr clear_oam_copy
                lda buttons_changed
                and #%10010000
                beq +
                lda #0
                jsr sndeng_entry2
                lda #6
                sta ram9
                lda #4
                sta task2
                lda #0
                sta ram8
                lda #0
                sta ram23
+               rts

sub19           lda ram30                    ; 8b26
                bne +
                lda #9
                sta ram30
+               dec ram30
                bne ++
                ldy ram9
                sty task2
                cpy #$0b
                bcc +
                lda buttons_held
                and #%01111111
                sta buttons_held
+               cpy #$0c
                bne ++
                jsr sndeng_entry4
                ;
++              lda ram30                    ; 8b47
                add #3
                and #%00001100
                asl a
                asl a
                jmp sub29

sub20           lda ppu_mask_copy1           ; 8b53
                ora #%00011110
                sta ppu_mask_copy2
                lda buttons_changed
                and #%00010000
                beq +
                lda ram36
                eor #%00000001
                sta ram36
+               lda ram36
                beq +
                lda ppu_mask_copy1
                and #%11100001
                sta ppu_mask_copy2
                rts
+               ldy ram23
                lda dat10,y
                sta ram32
                lda dat9,y
                sta ram31
                lda dat12,y
                sta ram34
                lda dat11,y
                sta ram33
                lda ram25
                beq +
                ldy #4
                jmp cod7
+               lda buttons_held
                and #%00100000
                beq +
                ldy #2
cod7            asl ram32                    ; 8b97
                rol ram31
                asl ram34
                rol ram33
                dey
                bne cod7
+               jsr clear_oam_copy           ; 8ba2
                jsr sub7
                jsr sub12
                jsr sub40
                lda ram24
                bne +
                lda ram23
                asl a
                tay
                iny
                iny
                lda ptr4+0
                cmp dat14,y
                bne +
                lda ptr4+1
                cmp dat14+1,y
                bne +
                lda #$10
                sta ram22
                sta ram24
                lda #0
                sta ram27
                sta ram26
+               lda ram24
                beq +
                lda ram27
                add ram34
                sta ram27
                lda ram26
                adc ram33
                sta ram26
                lda arr2+2
                add #$10
                cmp ram26
                bcs +
                lda #1
                sta ram25
+               lda #0
                sta ram31
                sta ram32
                sta ram33
                sta ram34
                rts

sub21           jsr clear_oam_copy           ; 8bfb
                lda ram30
                bne +
                lda #$16
                sta ram30
+               lda oam_copy+0*4+1
                cmp #$30
                bcc +
                cmp #$3a
                bcs +
                adc #1
                pha
                jsr sub9
                pla
                sta oam_copy+0*4+1
                lda #1
                sta oam_copy+0*4+2
+               dec ram30
                bne +
                lda #0
                sta ram24
                sta ram22
                lda #1
                sta ram8
                lda #6
                ldy ram7
                sta ram9
                lda #5
                sta task2
+               jsr sub12
                jsr rts6
                rts

                ; $8c3f: unaccessed or maybe JMP ($5a5a)
                hex 6c 5a 5a

sub22           lda ram30                    ; 8c42
                bne +
                lda #$0d
                sta ram30
+               dec ram30
                bne +
                lda ram9
                sta task2
                lda #0
                sta ppu_mask_copy2
                sta ppu_ctrl_copy
+               lda ram30
                cmp #$0d
                bcs +
                add #3
                and #%00001100
                eor #%00001100
                asl a
                asl a
                jsr sub29
+               rts

sub23           jsr clear_oam_copy           ; 8c6b
                jsr sub22
                jsr sub12
                jmp rts6

sub24           jsr sub16                    ; 8c77
                lda #$0c
                sta ram9
                lda #2
                sta task2
                lda #0
                sta ram8
                lda #%00011110
                sta ppu_mask_copy2
                lda ppu_ctrl_copy
                ora #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts

sub25           ; 8c94-8cba: unaccessed code
                jsr clear_oam_copy           ; 8c94
                lda #0
                sta vscroll2
                jsr clear_nt0
                lda #2*11
                jsr print_str
                lda #8
                sta ram9
                lda #2
                sta task2
                lda #0
                sta ram8
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
sub26           jsr clear_nt0                ; 8cbf
                lda #16*2
                jsr print_str
                lda #$0a
                sta ram9
                lda #2
                sta task2
                lda #0
                sta ram8
                lda #%00011110
                sta ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl

sub27           bit buttons_changed          ; 8cde
                bvc sub28
                lda #9                       ; 8ce2
                sta ram9
                lda #4
                sta task2
                rts

sub28           bit buttons_changed          ; 8ceb
                bpl +
                lda #1                       ; 8cef
                sta ram9
                lda #4
                sta task2
                lda #0
                sta ram8
+               rts                          ; 8cfb

sub29           sta ptr1+0                   ; 8cfc
                ldy ram19
                lda #$3f
                sta arr3,y
                lda #0
                sta arr3+1,y
                lda #$20
                sta arr3+2,y
                lda #$ff
                sta arr4,y
                tya
                add #$1f
                tay
                ldx #$1f
-               lda arr7+3,x                 ; 8d1b
                and #%00001111
                cmp #$0d
                bcs +
                lda arr7+3,x
                sub ptr1+0
                bcs ++
+               lda #$0f
++              sta arr3+3,y                 ; 8d2e
                dey
                dex
                bpl -
                tya
                add #$20
                sta ram19
                rts

lvlblkdat_tl    ; $8d3c; top left tile of each 2*2-tile level block
                hex f8 38 f8 f8 40 a1 61 f8
                hex 31 f8 50 c1 f8 f8 91 41
                hex f8 51 f8 f8 71 59 34 f8
                hex f8 f8 f8 f8 f8 40 38 38
                hex f8 f8 37 38 38 37 28 69
                hex 37 37 38 37 37 25 6f 38
                hex 38 47 38 f8 37 37 48 79
                hex 48 38 6d 28 6a 34 f8 39
                hex 7e 9e 25 28 39 f8 f8 7a
                hex 48 37 38 48 38 f8 f8 34
                hex 34 99 25 89 25 88 f8 f8
                hex f8 34 99 25 26 f8 35 34
                hex f8 f8 f8 25 f8 f8 f8 39
                hex f8 37 8b 8d 24 39 f8 34
                hex f8 46 f8 f8 f8 60 31 40
                hex 51 51 51 31 40 64 40 38
                hex 38 64 51 64 31 53 38 31
                hex f8 31 40 51 32 f8 42 f8
                hex f8 f8 40 52 30 f8 30 40
                hex 38 38 53 f8 53 f8 f8 42
                hex 34 25 a2 f8 f8 25 25 92
                hex 34 34 25 44 25 f8 33 f8
                hex f8 50 41 a6 50 f8 61 f8
                hex 41 61 40 f8 f8 f8 f8 f8

lvlblkdat_tr    ; $8dfc; top right tile of each 2*2-tile level block
                hex f8 39 37 f8 41 51 f8 f8
                hex f8 f8 51 41 f8 40 61 31
                hex 50 61 f8 50 31 31 f8 34
                hex 34 34 f8 f8 7b 7c 38 39
                hex f8 f8 38 38 39 6a 28 38
                hex 39 38 39 39 8b 25 28 38
                hex 39 9e 39 f8 39 7a 48 7a
                hex 49 7a 28 8f 28 f8 37 f8
                hex 48 25 6f 69 f8 f8 37 48
                hex 79 38 38 79 38 34 f8 f8
                hex f8 89 99 25 8a 25 f8 34
                hex 34 f8 25 35 f8 88 25 f8
                hex 34 f8 24 89 34 34 f8 f8
                hex 34 38 25 38 25 f8 f8 f8
                hex 44 f8 f8 f8 50 61 f8 41
                hex 61 61 41 50 63 61 63 38
                hex 38 61 63 41 50 38 54 50
                hex 50 f8 41 61 f8 f8 f8 f8
                hex f8 30 52 f8 31 32 31 61
                hex 38 54 38 f8 54 50 30 f8
                hex 93 94 f8 f8 44 25 46 f8
                hex 34 24 26 25 46 33 f8 f8
                hex f8 51 31 31 a5 60 40 40
                hex 51 f8 52 f8 f8 f8 92 f8

lvlblkdat_bl    ; $8ebc; bottom left tile of each 2*2-tile level block
                hex f8 48 f8 28 f8 91 f8 f8
                hex 41 f8 51 f8 71 f8 f8 40
                hex a1 61 31 50 c1 c1 34 f8
                hex 50 f8 89 25 25 f8 48 48
                hex 94 f8 9f 38 38 37 38 38
                hex 37 37 38 8d 37 f8 37 38
                hex 79 f8 38 28 69 37 f8 37
                hex f8 38 37 38 38 8f 28 39
                hex 34 f8 f8 48 9e 6f f8 39
                hex f8 8d 48 f8 7a 25 25 44
                hex 99 f8 f8 34 f8 34 26 f8
                hex 25 88 f8 f8 34 f8 34 35
                hex 25 25 f8 f8 f8 25 25 49
                hex f8 47 39 37 34 8b f8 46
                hex f8 f8 6e 27 f8 f8 52 50
                hex 41 52 61 41 50 41 f8 63
                hex 38 61 61 61 41 38 38 54
                hex 50 54 50 54 f8 50 41 32
                hex f8 f8 f8 f8 40 f8 40 f8
                hex 63 38 63 50 38 f8 50 61
                hex 34 f8 26 24 25 25 25 34
                hex 46 34 f8 f8 f8 f8 f8 f8
                hex 33 b6 40 40 51 f8 f8 f8
                hex 51 31 f8 31 42 f8 f8 30

lvlblkdat_br    ; $8f7c; bottom right tile of each 2*2-tile level block
                hex f8 49 47 29 40 61 f8 27
                hex 31 50 61 40 31 f8 f8 41
                hex 51 f8 f8 51 41 41 f8 6b
                hex 6c 34 25 25 8a 88 48 9e
                hex f8 93 48 38 39 38 38 38
                hex 39 38 8b 39 39 f8 38 7a
                hex 39 f8 6a 28 39 39 f8 39
                hex f8 39 38 6a 38 f8 69 f8
                hex f8 f8 7e 48 25 28 37 f8
                hex 7e 38 79 37 48 99 94 25
                hex 25 34 f8 f8 34 f8 f8 88
                hex 8a 25 f8 34 f8 34 f8 25
                hex 46 89 34 34 44 35 26 f8
                hex a2 48 f8 38 f8 25 24 f8
                hex f8 f8 25 28 60 f8 f8 51
                hex 31 f8 40 51 51 31 40 38
                hex 64 f8 40 40 53 38 38 51
                hex 53 31 53 31 f8 42 31 f8
                hex 32 40 f8 f8 41 f8 52 f8
                hex 64 64 38 31 38 40 51 f8
                hex f8 f8 f8 25 25 25 25 f8
                hex 34 34 34 f8 f8 f8 f8 33
                hex f8 61 b5 41 61 f8 f8 50
                hex 41 f8 30 50 f8 30 a2 31

dat9            hex 00 00 00 ff 00 00 01     ; $903c
dat10           hex 00 00 00 80 00 80 00     ; $9043
dat11           hex 00 00 00 00 00 00 00     ; $904a
dat12           hex 80 40 20 80 80 80 40     ; $9051
hscroll_data    hex 04 00 00 00 04 00 34     ; $9058
dat13           hex 00 00 00 00 00 80 00     ; $905f

level_data      ; $9066; level data; byte = which 2*2-tile block;
                ; first left to right, then up (forward);
                ; the first row repeats ten times instead of one;
                ; 172*16 = 2752 bytes
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 01 00 00 00 00 00 00 02 01 00 00 00 00 00 00 02
                hex 03 00 00 04 05 06 00 07 03 00 00 04 05 06 00 07
                hex 00 00 04 08 09 0a 06 00 00 00 04 08 09 0a 06 00
                hex 00 04 08 00 00 09 0a 06 00 04 08 00 00 09 0a 06
                hex 0b 08 00 00 00 00 09 0a 0b 08 00 00 00 00 09 0a
                hex 0c 00 00 0d 0e 00 00 09 0c 00 00 0d 0e 00 00 09
                hex 00 00 0d 0f 10 11 00 00 00 00 0d 0f 10 11 00 00
                hex 00 0d 0f 12 00 13 11 00 00 0d 0f 12 00 13 11 00
                hex 0d 0f 12 0d 0e 00 13 11 0d 0f 12 0d 0e 00 13 11
                hex 14 12 0d 0f 10 11 00 13 14 12 0d 0f 10 11 00 13
                hex 00 0d 0f 12 00 13 11 00 00 0d 0f 12 00 13 11 00
                hex 0d 0f 12 0d 0e 00 13 11 0d 0f 12 0d 0e 00 13 11
                hex 15 12 0d 0f 10 11 00 13 15 12 0d 0f 10 11 00 13
                hex 16 00 17 12 00 18 00 00 16 00 17 12 00 18 00 00
                hex 16 00 19 00 00 19 00 00 16 00 19 00 00 19 00 00
                hex 1a 1b 1c 06 00 1d 1b 1b 1a 1b 1c 06 00 1d 1b 1b
                hex 00 00 09 0a 0b 08 00 00 00 00 09 0a 0b 08 00 00
                hex 00 00 00 09 0c 00 00 00 00 00 00 09 0c 00 00 00
                hex 1e 1e 1e 1e 1e 1e 1f 20 21 22 1e 1e 1e 1e 1e 1e
                hex 23 23 23 23 23 23 24 00 00 25 26 26 27 23 23 23
                hex 23 23 23 23 23 23 24 00 00 28 00 00 29 23 23 23
                hex 23 23 23 23 23 23 2a 1b 1b 2b 00 00 29 23 23 23
                hex 23 23 23 23 23 23 24 00 00 2c 2d 2d 2e 27 23 23
                hex 23 23 23 23 23 23 24 00 00 28 00 00 00 29 23 23
                hex 23 23 23 23 23 23 2f 1e 1e 30 00 00 31 2e 26 27
                hex 23 23 23 23 23 23 32 33 33 34 00 00 28 00 00 29
                hex 23 23 23 23 23 23 24 00 00 35 36 36 37 38 00 29
                hex 23 23 23 23 23 23 39 36 36 3a 26 26 3b 03 00 29
                hex 23 23 3c 26 26 3b 33 33 33 3d 00 00 19 00 00 29
                hex 33 3e 3f 00 00 19 00 00 00 40 41 2d 42 43 44 45
                hex 00 46 47 36 36 48 1f 1b 1b 49 3f 00 00 46 3f 00
                hex 1e 4a 23 23 23 23 24 00 00 29 47 36 36 4b 4c 1e
                hex 33 33 33 33 33 33 33 20 21 45 33 33 33 33 33 33
                hex 1b 1b 1b 1b 4d 1b 4e 00 00 4f 1b 4d 1b 1b 50 1b
                hex 00 00 00 00 19 00 00 00 00 16 00 19 00 00 16 00
                hex 2d 2d 2d 2d 51 2d 52 2d 2d 53 2d 54 00 00 55 2d
                hex 00 00 00 00 16 00 19 00 00 00 00 19 00 00 16 00
                hex 00 00 00 00 16 00 19 00 00 00 00 19 00 00 16 00
                hex 1b 1b 50 1b 56 00 57 1b 50 1b 1b 58 00 00 59 1b
                hex 00 00 16 00 00 00 19 00 16 00 00 19 00 00 16 00
                hex 5a 2d 53 2d 5a 2d 54 00 55 2d 2d 5b 2d 2d 5e 2d
                hex 16 00 00 00 16 00 19 00 16 00 00 19 00 00 16 00
                hex 16 00 00 00 16 00 19 00 16 00 00 19 00 00 16 00
                hex 5f 1b 60 00 59 1b 61 4d 1a 1b 1b 58 00 00 59 1b
                hex 16 00 19 00 16 00 00 19 00 00 00 19 00 00 16 00
                hex 5c 00 62 2d 53 2d 2d 63 2d 2d 2d 63 2d 2d 53 2d
                hex 1b 4e 00 64 1b 60 00 64 1b 4e 00 64 1b 60 00 64
                hex 00 00 00 19 00 19 00 19 00 00 00 19 00 19 00 19
                hex 00 64 1b 61 1b 65 1b 66 00 64 1b 61 1b 65 1b 66
                hex 00 19 00 00 00 19 00 00 00 19 00 00 00 19 00 00
                hex 1b 58 00 64 1b 61 1b 4d 1b 58 00 64 1b 61 1b 4d
                hex 00 19 00 19 00 00 00 19 00 19 00 19 00 00 00 19
                hex 1b 65 1b 66 00 64 1b 61 1b 65 1b 66 00 64 1b 61
                hex 00 19 00 00 00 19 00 00 00 19 00 00 00 19 00 00
                hex 1b 61 1b 4d 1b 58 00 64 1b 61 1b 4d 1b 58 00 64
                hex 00 00 00 19 00 19 00 19 00 00 00 19 00 19 00 19
                hex 00 64 1b 61 1b 65 1b 66 00 64 1b 61 1b 65 1b 66
                hex 00 19 00 00 00 19 00 00 00 19 00 00 00 19 00 00
                hex 1b 58 00 64 1b 61 1b 4d 1b 58 00 64 1b 61 1b 4d
                hex 00 19 00 19 00 00 00 19 00 19 00 19 00 00 00 19
                hex 1b 65 1b 66 00 64 1b 61 1b 65 1b 66 00 64 1b 61
                hex 00 19 00 00 00 19 00 00 00 19 00 00 00 19 00 00
                hex 1b 61 1b 4d 1b 58 00 64 1b 61 1b 4d 1b 58 00 64
                hex 00 00 00 19 00 19 00 19 00 00 00 19 00 19 00 19
                hex 00 64 1b 61 1b 65 1b 66 00 64 1b 61 1b 65 1b 66
                hex 00 19 00 00 00 19 00 00 00 19 00 00 00 19 00 00
                hex 1b 66 00 21 1b 61 1b 1b 1b 66 00 21 1b 61 1b 1b
                hex 1e 1e 1e 67 00 68 00 00 00 00 68 00 00 69 1e 1e
                hex 23 23 23 3f 00 5d 2d 2d 2d 2d 54 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 6a 2d 54 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 57 1b 1b 1b 1b 65 1b 1b 49 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 6a 2d 5b 2d 2d 5a 2d 54 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 5d 2d 2d 6b 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 6c 2d 54 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 6d 1b 58 00 00 4f 1b 65 1b 1b 49 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 62 2d 2d 5e 2d 54 00 00 29 23 23
                hex 23 23 23 3f 00 00 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 00 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 6d 1b 60 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 5d 2d 2d 5c 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 6d 1b 58 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 6e 1b 1b 6f 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 00 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 70 2d 2d 5e 2d 54 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 6a 2d 54 00 00 16 00 5d 2d 2d 6b 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 57 1b 1b 1a 1b 58 00 00 29 23 23
                hex 23 23 23 6a 2d 54 00 00 00 00 5d 2d 2d 6b 23 23
                hex 23 23 23 3f 00 19 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 1b 1b 1b 1b 65 1b 1b 49 23 23
                hex 23 23 23 6a 2d 54 00 00 00 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 5d 2d 2d 71 00 19 00 00 29 23 23
                hex 23 23 23 3f 00 19 00 00 16 00 19 00 00 29 23 23
                hex 33 33 33 72 1b 61 1b 1b 1a 1b 66 00 00 73 33 33
                hex 00 00 00 00 00 00 00 74 11 00 00 00 00 75 04 76
                hex 00 75 00 00 00 00 00 00 13 11 00 00 00 77 78 00
                hex 00 77 79 00 00 00 00 00 00 13 11 00 04 08 13 11
                hex 7a 08 13 11 00 00 00 00 00 00 13 7a 08 00 00 13
                hex 7b 11 00 13 11 00 00 00 00 00 04 7b 11 00 00 04
                hex 00 13 11 00 13 11 00 00 00 04 08 00 13 11 04 08
                hex 00 00 13 11 00 13 11 00 04 08 00 00 00 77 78 00
                hex 00 00 00 13 11 00 13 7a 08 00 00 00 04 08 13 11
                hex 11 00 00 00 13 11 04 7b 11 00 00 04 08 00 00 13
                hex 13 11 00 00 00 7c 7d 00 13 11 04 08 00 00 00 00
                hex 00 13 11 00 7e 7f 80 81 00 77 78 00 00 00 00 00
                hex 00 00 13 82 7f 23 23 80 83 08 13 11 00 00 00 00
                hex 00 00 04 84 85 23 23 86 87 11 00 13 11 00 00 00
                hex 00 04 08 00 88 85 86 89 00 13 11 00 13 11 00 00
                hex 04 08 00 00 00 8a 8b 00 00 00 13 11 00 13 11 00
                hex 08 00 00 00 04 08 13 11 00 00 00 13 11 00 13 7a
                hex 11 00 00 04 08 00 8c 13 11 00 00 00 13 11 04 7b
                hex 13 11 04 08 00 00 00 00 13 11 00 00 00 77 78 00
                hex 00 7c 7d 00 74 11 04 76 00 13 11 00 04 08 8d 00
                hex 82 7f 80 81 00 77 8e 00 00 00 13 7a 08 00 00 74
                hex 84 85 23 80 83 08 00 00 8f 00 04 7b 11 00 00 04
                hex 00 88 85 86 87 11 00 00 00 04 08 00 13 11 04 08
                hex 00 00 8a 8b 00 13 11 90 04 08 00 00 00 77 78 00
                hex 00 91 08 8d 00 00 13 7a 08 00 00 00 04 08 13 11
                hex 11 00 92 00 74 11 04 7b 11 00 00 04 08 00 91 7b
                hex 13 7a 08 00 00 7c 7d 00 13 11 04 08 0d 93 00 00
                hex 00 13 11 00 7e 7f 80 81 00 77 78 00 94 12 00 95
                hex 00 96 13 82 7f 23 23 80 83 08 13 11 00 92 00 00
                hex 00 00 04 84 85 23 23 23 80 81 00 77 7a 08 00 92
                hex 00 04 78 00 88 85 23 23 23 80 83 08 13 11 91 08
                hex 04 08 13 11 04 84 85 23 23 23 80 81 00 13 11 00
                hex 08 00 04 7b 08 00 88 85 23 23 23 80 81 00 13 7a
                hex 81 00 13 11 00 97 00 88 85 23 23 23 80 81 7e 98
                hex 80 81 04 7b 7a 7b 11 00 8a 85 23 23 23 99 9a 23
                hex 23 99 78 00 9b 00 77 7a 08 88 85 23 86 89 88 85
                hex 9c 89 13 11 00 9d 78 13 11 00 88 9c 89 00 00 88
                hex 08 00 00 13 11 04 7b 11 13 11 04 7b 11 00 00 04
                hex 00 74 11 00 13 78 00 13 11 77 08 00 13 11 04 08
                hex 00 00 13 11 00 13 11 00 77 08 00 00 00 77 78 00
                hex 00 00 00 13 11 00 13 7a 08 00 00 00 04 08 13 11
                hex 11 00 00 00 13 11 04 7b 11 00 00 91 08 00 00 13
                hex 8d 00 00 00 00 9e 08 00 13 9f 00 00 00 00 00 00
                hex 6f 00 00 4f 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b
                hex a0 2d a1 16 00 00 00 00 00 00 00 00 00 00 00 00
                hex 16 00 00 16 00 00 00 00 00 00 00 00 00 00 00 00
                hex a2 00 00 a3 1b a4 a5 a5 a5 a5 a6 1b 1b 1b 1b 1b
                hex a7 00 00 00 00 19 00 00 00 00 19 00 00 00 00 00
                hex 4f 1b 1b 1b 1b a8 00 00 00 00 19 00 00 00 00 00
                hex 16 00 00 00 00 a9 2d 2d 2d 2d aa ab 2d 2d 2d ac
                hex 16 00 00 00 00 16 00 00 00 00 00 16 00 00 00 19
                hex a3 1b 1b 1b 1b a2 00 00 00 00 00 16 00 00 00 19
                hex 00 00 00 00 00 6c 2d 2d 2d 2d a1 6c 2d 2d 2d aa
                hex 00 00 ad 00 00 00 00 ae 00 00 00 00 ad 00 00 00
                hex ae 00 00 00 ae 00 00 00 af 00 00 ae 00 00 00 00
                hex 00 00 00 ae 00 00 00 ad 00 00 00 00 00 ad 00 00
                hex 00 ae 00 00 00 ae b0 00 00 00 ad 00 00 00 00 00
                hex 00 00 ad 00 00 00 00 00 b0 00 ae 00 af 00 00 ae
                hex af 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 1b 1b 50 1b 1b 1b b1 06 0d b2 1b 1b 1b 4d 1b 1b
                hex 00 00 16 00 00 00 09 0a 0f 12 00 00 00 19 00 00
                hex 00 00 16 00 00 00 0d 0f 0a 06 00 00 00 19 00 00
                hex 2d 2d 53 2d 2d 2d b3 12 09 b4 2d 2d 2d 63 2d 2d
                hex 00 b5 b6 93 00 00 00 00 00 00 00 00 b5 b6 93 00
                hex 00 b7 b8 b9 00 ae 00 af 00 75 92 00 b7 b8 b9 00
                hex 75 ba bb bc 00 00 00 00 00 77 78 ad bd bb bc 00
                hex 77 78 00 00 be 00 b0 00 ae bf 8d 00 00 21 1b 4e
                hex bf 8d 00 af 00 00 00 00 00 00 00 00 00 00 b0 00

dat14           hex 76 90 96 91 86 92 56 93  ; $9b26
                hex a6 94 f6 96 96 99 26 9b

sub30           lda ram22                    ; 9b36
                beq sub31
                lda ptr4+0
                pha
                lda ptr4+1
                pha
                lda #$66
                sta ptr4+0
                lda #$90
                sta ptr4+1
                jsr sub31
                dec ram22
                bne +
                lda ram24
                beq +
                inc ram23
                lda #0
                sta ram24
                sta ram25
                jsr sub41
                ldy ram23
                lda hscroll_data,y
                sta hscroll1
                sta hscroll2
                lda ram11
                sec
                sbc dat13,y
                sta ram10
                cpy #7
                bne +

                lda #1                       ; 9b73 (unaccessed)
                sta ram9                     ; unaccessed
                lda #4                       ; unaccessed
                sta task2                    ; unaccessed
                lda #0                       ; unaccessed
                sta ram8                     ; unaccessed
                jsr sndeng_entry3            ; unaccessed

+               pla                          ; 9b82
                sta ptr4+1
                pla
                sta ptr4+0
                rts

sub31           inc ram20                    ; 9b89
                bne sub32
                inc ram21
sub32           ldy #0                       ; 9b8f
                jsr sub39
                lda arr1+0
                sta ram16
                lda arr1+1
                sta ram17
                lda #0
                sta ptr1+0
-               ldy #0
                lda (ptr4),y
                inc ptr4+0
                bne +
                inc ptr4+1
+               tax
                ldy ptr1+0
                lda lvlblkdat_tl,x
                sta arr5,y
                lda lvlblkdat_tr,x
                sta arr5+1,y
                lda lvlblkdat_bl,x
                sta arr6,y
                lda lvlblkdat_br,x
                sta arr6+1,y
                iny
                iny
                sty ptr1+0
                cpy #$20
                bne -
                lda #1
                sta ram15
                sec
                rts
sub33           lda #0                       ; 9bd3
                sta vscroll1
                sta vscroll2
                sta hscroll1
                sta hscroll2
                jsr clear_nt0
                lda #STR_ID_TITLE            ; print title screen
                jsr print_str
                rts
sub34           jsr sndeng_entry4            ; 9be6
                ldy ram23
                lda hscroll_data,y
                sta hscroll1
                sta hscroll2
                lda dat13,y
                sta ram10
                lda #0
                sta vscroll1
                sta vscroll2
                sta ram11
                sta ram37
                sta ram28
                sta ram35
                sta ram31
                sta ram32
                sta ram33
                sta ram34
                lda ram23
                asl a
                tay
                lda dat14,y
                sta ptr4+0
                lda dat14+1,y
                sta ptr4+1
                lda #$ff
                sta ram20
                sta ram21
                jsr sub35
                lda #$0a
                sta ram3
                jsr sub36
                lda #5
                sta ram3
                jsr sub37
                lda #$6a
                sta arr2+0
                lda #$80
                sta arr2+1
                lda #$bf
                sta arr2+2
                lda #$80
                sta arr2+3
                jsr sub9
                jsr sub11
                rts
sub35           lda #0                       ; 9c49
                sta ram15
                lda #$23
                sta arr1+0
                lda #$c0
                sta arr1+1
                lda ram4
                sta ppu_ctrl
                rts
sub36           lda ptr4+0                   ; 9c5b
                pha
                lda ptr4+1
                pha
-               lda #<level_data
                sta ptr4+0
                lda #>level_data
                sta ptr4+1
                jsr sub32
                jsr sub3
                dec ram3
                bne -
                pla
                sta ptr4+1
                pla
                sta ptr4+0
                rts
sub37           jsr sub32                    ; 9c7a
                jsr sub3
                dec ram3
                bne sub37
                rts

-               jsr sub31                    ; 9c85 (unaccessed)
                jsr sub3                     ; unaccessed
                dec ram3                     ; unaccessed
                bne -                        ; unaccessed
                rts                          ; 9c8f (unaccessed)

sub38           lda ram11                    ; 9c90
                sec
                sbc ram34
                sta ram11
                lda vscroll1
                sbc ram33
                sta vscroll2
                bcs +
                sbc #$0f
                sta vscroll2
                lda ram4
                eor #%00000010
                sta ppu_ctrl_copy
+               rts

                ; 9caa-9cbf: unaccessed code
                lda vscroll1                 ; 9caa
                add ram33
                sta vscroll2
                cmp #$f0
                bcc +
                adc #$0f                     ; 9cb5
                sta vscroll2
                lda ram4
                eor #%00000010
                sta ppu_ctrl_copy
+               rts                          ; 9cbf

sub39           lda arr1+1,y                 ; 9cc0
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

sub40           lda ppu_ctrl_copy            ; 9ce8
                sta ram2
                jsr sub38
                lda ram10
                add ram32
                sta ram10
                lda hscroll2
                adc ram31
                sta hscroll2
                lda vscroll2
                eor vscroll1
                cmp #$10
                bcc +
                jsr sub30
+               rts

sub41           lda arr7+4                   ; 9d08
                add #5
                cmp #$0d
                bcc +
                sbc #$0c                     ; 9d12 (unaccessed)
+               sta arr7+4                   ; 9d14
                ora #%00010000
                sta arr7+5
                eor #%00110000
                sta arr7+6
                lda #6
                sta ram18
                rts

sub42           lda #$ff                     ; 9d26
                sta ram_shared
                sta ram49
                jsr sndeng_entry3
                ldx #8
                ldy #$ad
                jsr sndeng_entry6
                rts

                ; Famitone2 sound engine
sound_engine    incbin "prox-snd-eng.bin"    ; $9d37
                if $ != $c629
                    error "sound engine binary size mismatch"
                endif

                pad $c700, $00               ; c629 (unaccessed)

reset           ; $c700; initialise the NES
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
                ;
                ; clear RAM (oam_copy with $ff, the rest with $00)
-               lda #$ff
                sta oam_copy,x
                lda #0
                sta $00,x
                pha
                sta $0300,x
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                inx
                bne -
                ;
                bit $00
                stx dmc_raw
                stx dmc_len
                ;
                dex
                txs
                stx arr3+0
                ;
                copy #0,   dmc_start
                copy #$4c, ram42
                bit $00
                rept 6
                    nop
                endr
                copy #$82, ptr3+1
                copy #$0f, dmc_freq
                nop
                ;
                bit $00
                lda #$7e
                ldx #$20
                jsr sub4
                ;
                ; how many times does the loop run in one frame?
                ldx #0
--              bit ppu_status
                bmi +
                ldy #57
-               dey
                bne -
                bit $00
                inx
                jmp --
                ;
+               ; determine console region based on that
                stx $00
                ldy #6
-               lda region_loopcnts-1,y
                cmp $00
                bcs +
                dey
                bne -
+               lda regions,y
                sta region
                jmp to_main_loop

region_loopcnts db 197, 182, 159, 79, 72, 60  ; $c78f
regions         db 0, 2, 1, 0, 2, 1, 0        ; $c795

; -----------------------------------------------------------------------------

read_joypad     ; $c79c; called by clear_oam_copy
                ;
                ldx #1
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

; -----------------------------------------------------------------------------

clear_oam_copy  ; $c7c7; called by sub16, sub17, sub18, sub20, sub21, sub23,
                ; sub25
                ;
                lda #$ff
                ldx #$3c
-               sta oam_copy+$00,x
                sta oam_copy+$40,x
                sta oam_copy+$80,x
                sta oam_copy+$c0,x
                axs_imm 4                    ; $c7d7: equiv. to 4*DEX
                bpl -
                ;
                lda #$10
                sta ram14
                rts

; -----------------------------------------------------------------------------

main_loop       lda ram13
                beq main_loop
                inc ram12
                jsr read_joypad
                ;
to_main_loop    ; $c7e9; called by reset
                lda task1
                asl a
                tax
                lda task_jump_table+0,x
                sta ram43
                lda task_jump_table+1,x
                sta ram44
                jsr ram42
                ;
                copy task2, task1
                copy ram8, ram7
                copy #0, ram13
                jmp main_loop

; -----------------------------------------------------------------------------

nmi             ; $c809; NMI routine
                ;
                pha
                txa
                pha
                tya
                pha
                ;
                lda task1
                cmp #$0b
                bcc +
                lda ppu_status
                and #%01000000
                ora ram45
                sta ram45
                beq +
                lda #0
                sta ram36
                lda ppu_mask_copy2
                ora #%00011110
                sta ppu_mask_copy2
                lda ram35
                cmp #$0f
                bne +
                lda ram28
                eor #%00000001
                sta ram28
                lda #0
                sta ram35
                lda #$fe
                sta oam_copy+2*4+0
                lda oam_copy+0*4+3
                ldy oam_copy+3*4+3
                sta oam_copy+3*4+3
                sty oam_copy+0*4+3
+               lda ram13
                beq +
                jmp nmi_end                  ; c84e (unaccessed)
+               lda ram45                    ; c851
                beq +
                ;
                lda #$30
                sta oam_copy+0*4+1
                lda #$ff
                sta oam_copy+0*4+4
                ;
                lda #3
                sta task1
                sta task2
                lda #2
                jsr sndeng_entry5
                lda #0
                sta ram45
                ;
+               bit ppu_status
                jsr sub1
                jsr sub2
                ;
                lda ppu_mask_copy1
                sta ppu_mask
                ;
                lda hscroll2                 ; c87c
                sta ppu_scroll
                ldy vscroll2
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
                sta ram4
                ;
                lda hscroll2
                sta hscroll1
                lda vscroll2
                sta vscroll1
nmi_end         jsr sndeng_entry1
                inc ram13
                ;
                pla
                tay
                pla
                tax
                pla
                rti

; -----------------------------------------------------------------------------

                lda ram13                    ; c8b1 (unaccessed)
-               cmp ram13                    ; unaccessed
                bne -                        ; unaccessed
                rts                          ; unaccessed

                pad $ffe0, $00               ; c8b8 (unaccessed)

                ; ffe0-fff9: unaccessed data
                db " PROXIMITY SHIFT"
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
