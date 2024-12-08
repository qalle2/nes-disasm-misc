; Proximity Shift (NESdev Compo 2023) by Fiskbit, Trirosmos.
; Unofficial disassembly by qalle.
; Assembles with ASM6.
; Command used to disassemble:
;     python3 nesdisasm.py
;     -c prox.cdl --no-access 0800-1fff,2008-3fff,4020-5fff,6000-7fff
;     --no-write 8000-ffff prox-prg.bin
; Palettes:
;     BG0: playfield; for the first few stages:
;       1st stage: 0f 00 10 20
;       2nd stage: 0f 05 15 25
;       3rd stage: 0f 0a 1a 2a
;       4th stage: 0f 03 13 23
;     others: ??
; There are likely 7 stages. Playfield color changes between them.
; 4th stage scrolls sideways (or is the first to do so).
;
; task1, task2:
;    1:          title screen fading in
;    11:         on title screen
;    4, 6, 2:    transition from title screen to in-game
;    12:         in-game & transitioning between levels
;    3, 5, 6, 2: exploding & respawning in-game
; task1 & task2 seem to be the same in frame resolution (in FCEUX Hex Editor)
;
; Sprite slots:
;   ship: 0
;   shadow ship: usually 3, but 2 when switching
;   stars: 4-15 (tile $fe)

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff

cod_dat_ptr     equ $00  ; 2 bytes; code & data pointer
cod_ptr         equ $02  ; 2 bytes; some code pointer
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
task3           equ $19  ; often the next task
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
cod_ptr2        equ $25  ; 2 bytes; set to $82xx on reset
arr1            equ $27
ram16           equ $29
ram17           equ $2a
str_to_print    equ $2c
ram19           equ $2d
buttons_changed equ $2e  ; joypad buttons that were just pressed
buttons_held    equ $2f  ; all joypad buttons being held now
lvl_dat_ptr     equ $30  ; 2 bytes; level data pointer
ram20           equ $32
ram21           equ $33
ram22           equ $34
stage           equ $36  ; starts from 0
ram24           equ $37
ram25           equ $38
ram26           equ $39
ram27           equ $3a
ram28           equ $3c
ram29           equ $3d
timer           equ $3e  ; fadein, fadeout, explosion
ram31           equ $3f
ram32           equ $40
ram33           equ $41
ram34           equ $42
ram35           equ $43
ram36           equ $44
ram37           equ $45
prng            equ $47  ; pseudorandom number generator?; 4 bytes
ram42           equ $4b
ram43           equ $4c
ram44           equ $4d
ram45           equ $4e
arr2            equ $51  ; 9 bytes?
plr_x_hi        equ $51  ; player X pos high (value $50-$84)
plr_x_lo        equ $52  ; player X pos low ($00/$40/$80/$c0)
plr_y_hi        equ $53  ; player Y pos high
plr_y_lo        equ $54  ; player Y pos low ($00/$40/$80/$c0)
    ; $55-$59: related to player X/Y?
ram_shared      equ $70  ; shared with sound engine
ram49           equ $71

; these are probably read using PLA
palette_copy    equ $0110  ; 35 bytes:
    ; byte  0:    ? (negative = no data)
    ; bytes 1-2:  ?
    ; bytes 3-34: payload
arr4            equ $0133
curr_lvlblkrow  equ $0150  ; 64 bytes; 1 row of level blocks; 32*2 tiles

oam_copy        equ $0200  ; $100 bytes

arr_shared1     equ $0300  ; shared with sound engine; 256 bytes?

ppu_buffer      equ $0400  ; $24 bytes
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
stars_x         equ $049c  ; star X positions; 12 bytes
stars_y         equ $04a8  ; star Y positions; 12 bytes
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

; PPU strings
STR_ID_PPUBUF   equ 3*2  ; PPU buffer
STR_ID_TITLE    equ 4*2  ; title screen
STR_TERM        equ $ff  ; terminator

; colours
COL_BG          equ $0f  ; background (black)

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

cod1            rept 16
                    pla
                    sta ppu_data
                endr
                tya
                bne ++
                beq cod2
                ;
-               txs
                ldx #$ff
                stx palette_copy+0           ; mark as empty
                inx
                stx ram19
rts1            rts
                ;
                ; $804f; called by nmi
sub1            lda str_to_print
                beq +
                jsr print_str
+               lda palette_copy+0
                bmi rts1                     ; empty?
                ;
                copy #$80, cod_dat_ptr+1
                copy #$80, cod_ptr+1
                tsx
                txa
                ldx #$0f
                txs
                tax
cod2            pla
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
                ora #%00000100               ; $807a (unaccessed)
+               sta ppu_ctrl
                tya
                bmi cod3
                lsr a
                bne ++
                lda #$40                     ; $8085 (unaccessed)
++              cmp #$10
                bcc +
                sbc #$10
                tay
                jmp cod1
                ;
                ; $8091: unaccessed up to $80f5
+               ldy #0
                sbc #0
                eor #%00001111
                asl a
                asl a
                sta cod_dat_ptr+0
                jmp (cod_dat_ptr)
cod3            lsr a
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
                bcc cod2
                ;
+               tay
                lda dat1,y
                sta cod_ptr+0
                ldy ram1
                lda #0
                jmp (cod_ptr)

print_str       ; $80f6: copy string to PPU buffer; A = string_id * 2;
                ; called by sub1, sub22, sub23, sub30
                tay
                lda str_ptrs-2,y
                sta cod_dat_ptr+0
                lda str_ptrs-1,y
                sta cod_dat_ptr+1
                ;
--              ldy #0
                lda (cod_dat_ptr),y
                bmi ++
                sta ppu_addr
                iny
                lda (cod_dat_ptr),y
                sta ppu_addr
                iny
                lda (cod_dat_ptr),y
                iny
                asl a
                tax
                lda ram4
                bcc +
                ora #%00000100
+               sta ppu_ctrl
                txa
                bmi +++
                ;
                lsr a
                bne +
                lda #$40
+               tax
-               lda (cod_dat_ptr),y
                sta ppu_data
                iny
                dex
                bne -
                ;
---             tya
                add cod_dat_ptr+0
                sta cod_dat_ptr+0
                lda cod_dat_ptr+1
                adc #0
                sta cod_dat_ptr+1
                jmp --
                ;
++              copy #0, str_to_print
                rts
                ;
+++             lsr a
                and #%00111111
                bne +
                lda #$40
+               tax
                lda (cod_dat_ptr),y
                iny
                ;
-               sta ppu_data
                dex
                bne -
                jmp ---

dat1            ; $8159; read by sub1
                hex b3 b6 b9 bc bf c2 c5 c8
                hex cb ce d1 d4 d7 da dd e0

cod5            ; $8169; copy 32 bytes from stack to PPU; called by sub3, sub4
                rept 32
                    pla
                    sta ppu_data
                endr
                jmp (cod_ptr2)

                pad $8200, $00               ; $81ec (unaccessed)

sub2            ; $8200; called by nmi
                copy ram4, ppu_ctrl
                lda ram15
                beq rts2
                ;
sub3            ; $8209; called by sub33, sub34, sub35
                tsx
                stx cod_dat_ptr+0
                ldx #$4f                     ; end of arr4
                txs
                ldx ram16
                stx ppu_addr
                ldy ram17
                sty ppu_addr
                copy #<sub4, cod_ptr2+0
                jmp cod5

sub4            ; $8220; indirectly called by sub3
                stx ppu_addr
                tya
                ora #%00100000
                sta ppu_addr
                ldx #$6f                     ; middle of curr_lvlblkrow
                txs
                copy #<sub5, cod_ptr2+0
                jmp cod5

sub5            ; $8233: indirectly called by sub4
                ldx cod_dat_ptr+0
                txs
                copy #0, ram15
rts2            rts

clear_nt0       ; $823b; fill NT0 with a blank tile ($f8);
                ; called by sub22, sub23, sub30
                copy #>ppu_nt0, ppu_addr
                copy #<ppu_nt0, ppu_addr
                ldy #$f0
                lda #$f8
-               sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                dey
                bne -
                rts

str_ptrs        ; $8259; pointers to PPU strings; partially unaccessed;
                ; read by print_str
                dw str_blackpal              ;  0
                dw str_palette               ;  1
                dw ppu_buffer                ;  2
                dw str_title                 ;  3
                dw str_normal1               ;  4
                dw str_hard1                 ;  5
                dw str_expert1               ;  6
                dw str_irritating1           ;  7
                dw str_off1                  ;  8
                dw str_on1                   ;  9
                dw str_congrats              ; 10
                dw str_gotlost               ; 11
                dw str_master                ; 12
                dw str_wow                   ; 13
                dw str_stats                 ; 14
                dw str_credits               ; 15
                dw str_normal2               ; 16
                dw str_hard2                 ; 17
                dw str_expert2               ; 18
                dw str_irritating2           ; 19
                dw str_secret                ; 20
                dw str_off2                  ; 21
                dw str_on2                   ; 22
                dw str_ntsc                  ; 23
                dw str_pal                   ; 24
                dw str_pal                   ; 25

                ; $828d; PPU strings; partially unaccessed; tiles:
                ;     $00-$09 = "0"-"9" (subtract 48 from ASCII digits)
                ;     $0a-$23 = "A"-"Z" (subtract 55 from ASCII uppercase)

macro ppustr _addr, _len
                db >(_addr), <(_addr), _len
endm

str_blackpal    ppustr ppu_palette, $40|32
                db $0f, STR_TERM
str_palette     ppustr ppu_palette, 32
                db COL_BG, $00, $10, $20
                db COL_BG, $00, $10, $20
                db COL_BG, $00, $10, $20
                db COL_BG, $00, $10, $20
                db COL_BG, $00, $10, $20
                db COL_BG, $17, $27, $37
                db COL_BG, $01, $11, $21
                db COL_BG, $00, $10, $20
                db STR_TERM
str_title       ppustr ppu_at0, $40
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
                db STR_TERM
str_normal1     ppustr ppu_nt0+22*32+3, 10
                db $24, $24, "NORMAL"-55, $24, $24, STR_TERM
str_hard1       ppustr ppu_nt0+22*32+3, 10
                db $24, $24, $24, "HARD"-55, $24, $24, $24, STR_TERM
str_expert1     ppustr ppu_nt0+22*32+3, 10
                db $24, $24, "EXPERT"-55, $24, $24, STR_TERM
str_irritating1 ppustr ppu_nt0+22*32+3, 10
                db "IRRITATING"-55, STR_TERM
str_off1        ppustr ppu_nt0+23*32+21, 3
                db "OFF"-55, STR_TERM
str_on1         ppustr ppu_nt0+23*32+21, 3
                db $24, "ON"-55, STR_TERM
str_congrats    ppustr ppu_at0, $40
                db $ff
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
                db STR_TERM
str_gotlost     ppustr ppu_at0, $40
                db $ff
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
                db STR_TERM
str_master      ppustr ppu_at0, $40
                db $ff
                ppustr ppu_nt0+3*32+11, 11
                db "INCREDIBLE"-55, $e1
                ppustr ppu_nt0+5*32+3, 13
                db "YOU"-55, $24, "TRULY"-55, $24, "ARE"-55
                ppustr ppu_nt0+6*32+3, 26
                db "AN"-55, $24, "IRRITATING"-55, $24, "SHIP"-55, $24
                db "MASTER"-55, $e1
                db STR_TERM
str_wow         ppustr ppu_at0, $40
                db $ff
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
                db STR_TERM
str_stats       ppustr ppu_nt0+14*32+2, 11
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
                db STR_TERM
str_normal2     ppustr ppu_nt0+14*32+24, 6
                db "NORMAL"-55, STR_TERM
str_hard2       ppustr ppu_nt0+14*32+26, 4
                db "HARD"-55, STR_TERM
str_expert2     ppustr ppu_nt0+14*32+24, 6
                db "EXPERT"-55, STR_TERM
str_irritating2 ppustr ppu_nt0+14*32+20, 10
                db "IRRITATING"-55, STR_TERM
str_secret      ppustr ppu_nt0+14*32+24, 6
                db "SECRET"-55, STR_TERM
str_off2        ppustr ppu_nt0+16*32+27, 3
                db "OFF"-55, STR_TERM
str_on2         ppustr ppu_nt0+16*32+28, 2
                db "ON"-55, STR_TERM
str_ntsc        ppustr ppu_nt0+18*32+26, 4
                db "NTSC"-55, STR_TERM
str_pal         ppustr ppu_nt0+18*32+27, 3
                db "PAL"-55, STR_TERM
str_credits     ppustr ppu_nt0+5*32+8, 15
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
                db STR_TERM

; -----------------------------------------------------------------------------

                hex b4 b4 b5 b5              ; $86c4 (unaccessed)

prng_init       ; $86c8; init pseudorandom number generator?; called by reset
                sta prng+0
                stx prng+1
                sta prng+2
                stx prng+3
                ;
prng_get        ; $86d0; pseudorandom number generator?; called by sub16, sub21
                clc                          ; prng[0] += 0xb3
                lda prng+0
                adc #$b3
                sta prng+0
                adc prng+1                   ; prng[1] += prng[0] + carry
                sta prng+1
                adc prng+2                   ; prng[2] += prng[1] + carry
                sta prng+2
                eor prng+0                   ; X = (prng[0] ^ prng[2]) & 0x7f
                and #%01111111
                tax
                lda prng+2                   ; prng[3] += prng[2] + carry
                adc prng+3
                sta prng+3
                eor prng+1                   ; A ^= prng[1]
                rts

sub8            ; $86ed; called by sub15
                lsr a
                sta cod_dat_ptr+0
                lda #0
                ;
                ldy #8
-               bcc +
                add cod_dat_ptr+1
+               ror a
                ror cod_dat_ptr+0
                dey
                bne -
                rts

sub9            ; $8700; unaccessed up to $871c
                eor #%11111111
                sta cod_dat_ptr+1
                lda cod_dat_ptr+0
                eor #%11111111
                add #1
                sta cod_dat_ptr+0
                bcc +
                inc cod_dat_ptr+1
+               rts
                ldy #$ff
-               iny
                sub #$0a
                bcs -
                adc #$0a
                rts

sub10           ; $871d; called by in_game
                bit buttons_changed
                bpl +
                lda ram28
                eor #%00000001
                sta ram28
                lda #1
                jsr sndeng_entry5
                copy #$10, ram35
+               jsr move_player
                lda buttons_held
                and #%01000000
                beq +
                jsr move_player
+               lda task2
                cmp #3
                beq +
                jsr sub13
                jmp sub12
+               jsr sub12
                copy #$30, oam_copy+0*4+1    ; ship tile
                rts

                ; $8751; read by move_player; index = d-pad %UDLR
plr_x_chg_hi    db >0, >192, >(65536-192), >0  ; -, R,  L,  LR
                db >0, >136, >(65536-136), >0  ; D, DR, DL, DLR
                db >0, >136, >(65536-136)      ; U, UR, UL
plr_x_chg_lo    db <0, <192, <(65536-192), <0
                db <0, <136, <(65536-136), <0
                db <0, <136, <(65536-136)

                ; $8767; read by move_player; index = d-pad %UDLR
plr_y_chg_hi    db >0,           >0,           >0,          >0
                db >192,         >136,         >136,        >0
                db >(65536-192), >(65536-136), >(65536-136)
plr_y_chg_lo    db <0,           <0,           <0,          <0
                db <192,         <136,         <136,        <0
                db <(65536-192), <(65536-136), <(65536-136)

move_player     ; $877d; called by sub10
                lda buttons_held             ; get d-pad status
                and #%00001111
                ldy plr_y_hi
                cpy #0                       ; ignore up if at top of screen
                bne +
                and #%11110111
+               cpy #231                     ; ignore down if at btm of scrn
                bcc +
                and #%11111011
+               tax                          ; X = d-pad status for later
                ;
                ; move player horizontally
                lda plr_x_lo
                clc
                adc plr_x_chg_lo,x
                sta plr_x_lo
                lda plr_x_hi
                adc plr_x_chg_hi,x
                sta plr_x_hi
                cmp #80
                bcs +
                sbc #79                      ; carry always clear
                add ram31
                sta ram31
                copy #80, plr_x_hi
+               lda plr_x_hi
                cmp #133
                bcc +
                sbc #132                     ; carry always set
                add ram31
                sta ram31
                copy #132, plr_x_hi
                ;
+               ; move player vertically
                lda plr_y_lo
                clc
                adc plr_y_chg_lo,x
                sta plr_y_lo
                lda plr_y_hi
                adc plr_y_chg_hi,x
                sta plr_y_hi
                rts

plr_spr_x_add   ; $87cf; read by sub12
                db 0, 36, 0

sub12           ; $87d2; called by sub10, explode, sub31
                lda plr_y_hi                 ; ship & shadow ship Y
                sta oam_copy+0*4+0
                sta oam_copy+3*4+0
                ;
                copy #$00, oam_copy+0*4+2    ; ship attributes
                copy #$02, oam_copy+3*4+2    ; shadow ship attributes
                copy #$04, oam_copy+0*4+1    ; ship tile
                ;
                ; shadow ship tile = $0e + ((ram12 >> 2) & 1)
                lda ram12
                lsr a
                lsr a
                lsr a
                lda #$0e
                adc #0
                sta oam_copy+3*4+1
                ;
                ldy ram28                    ; ship X pos
                lda plr_x_hi
                clc
                adc plr_spr_x_add,y
                sta oam_copy+0*4+3
                ;
                iny                          ; shadow ship X pos
                lda plr_x_hi
                clc
                adc plr_spr_x_add,y
                sta oam_copy+3*4+3
                sta oam_copy+2*4+3
                ;
                ; secondary sprite of shadow ship
                copy #$fe, oam_copy+2*4+0      ; Y
                ldy ram35
                beq +
                dey
                sty ram35
                tya
                lsr a
                lsr a
                sta oam_copy+2*4+1             ; tile
                copy plr_y_hi, oam_copy+2*4+0  ; Y
                copy #$00,     oam_copy+2*4+2  ; attributes
+               rts

sub13           ; $882a; called by sub10
                lda ram29
                beq ++
                ;
                ; unaccessed up to $884d
                cmp #$0b                     ; $882e
                lda #$10
                bcc +
                lda #$20
+               copy #$10,     oam_copy+1*4+1
                copy #$01,     oam_copy+1*4+2
                copy plr_x_hi, oam_copy+1*4+3
                jsr plr_y_hi                 ; ???
                add #6
                sta oam_copy+1*4+0
                ;
++              rts                          ; $884e

sub14           ; $884f; called by sub31
                copy #$10, cod_dat_ptr+0
                ldx ram14
                ldy ram37
                beq ++
                ;
                ; unaccessed up to $889c
                cpy #5                       ; $8859
                bcc loop1
                ldy #1
                ;
loop1           lda cod_dat_ptr+0
                sta oam_copy+3,x
                add #8
                sta cod_dat_ptr+0
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
                bne loop1
                ;
                lda ram37
                cmp #5
                bcc +
                ora #%11110000
                sta oam_copy+1,x
                lda #$12
                sta oam_copy,x
                lda cod_dat_ptr+0
                sta oam_copy+3,x
                lda #0
                sta oam_copy+2,x
                inx
                inx
                inx
                inx
+               stx ram14
                ;
++              rts                          ; $889d

sub15           ; $889e; called by sub21, in_game, explode, ingame_fadeout
                ldx ram14
                beq rts3
                lda ram11
                sub ram34
                rol a
                eor #%00000001
                ror a
                lda ram33
                adc #0
                sta cod_ptr+1
                ldy #11
                sty cod_ptr+0
                ;
loop1b          ldy cod_ptr+0
                lda cod_ptr+1
                beq cod6
                sta cod_dat_ptr+1
                lda dat3,y
                clc
                adc arr23,y
                jsr sub8
                sta cod_dat_ptr+1
                ;
                ldy cod_ptr+0
                lda cod_dat_ptr+0
                clc
                adc arr22,y
                sta arr22,y
                lda stars_y,y
                adc cod_dat_ptr+1
                sta stars_y,y
                bit cod_dat_ptr+1
                bmi +
                bcc cod6
                ;
                lda #0
                bcs ++                       ; always
                ;
+               bcs cod6                     ; $88e6 (unaccessed)
                lda #$ff                     ; unaccessed
++              sta stars_y,y                ; $88ea
                lda dat2,y
                adc prng+3
                sta stars_x,y
                lda prng+2
                and #%01111111
                sta arr23,y
                ;
cod6            lda stars_y,y
                sta oam_copy+0,x
                lda stars_x,y
                sta oam_copy+3,x
                lda #%00100011
                sta oam_copy+2,x
                lda #$fe                     ; star tile
                sta oam_copy+1,x
                axs_imm $fc                  ; $8912: equiv. to 4*INX
                beq +
                dec cod_ptr+0
                bpl loop1b
                ;
+               stx ram14
rts3            rts

dat2            ; $891d; read by sub15
                hex ec 42 73 61 2d 94 28 22
                hex c9 e1 62 a9

dat3            ; $8929; read by sub15
                db  4*8,  5*8,  6*8,  7*8, 8*8, 9*8, 10*8, 11*8
                db 12*8, 13*8, 14*8, 15*8

                ; $8935 (unaccessed; could be data byte $60)
                rts

sub16           ; $8936; unaccessed up to $899d
                lda plr_x_hi
                pha
                add #2
                sta plr_x_hi
                lda plr_y_hi
                pha
                add #2
                sta plr_y_hi
                ldx #0
                ldy #0
                ;
--              lda arr2,y
                sty cod_dat_ptr+0
                ldy #8
-               sta arr8,x
                inx
                dey
                bne -
                ldy cod_dat_ptr+0
                iny
                cpy #8
                bcc --
                ;
                pla
                sta plr_y_hi
                pla
                sta plr_x_hi
                ldy #7
                ;
loop1c          jsr prng_get
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
                bpl loop1c
                ;
                rts

rts4            rts                          ; $899e

sub17           ; $899f; unaccessed up to $8a18
                ldy ram14
                ldx #7
                ;
loop1d          lda arr10,x
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
                ror a
                eor arr14,x
                bpl +
                jsr sub18
                jmp ++
                ;
+               lda arr13,x
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
                ror a
                eor arr17,x
                bpl +
                jsr sub18
                jmp ++
+               lda arr11,x
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
++              dex
                bpl loop1d
                ;
                sty ram14
                rts

sub18           ; $8a19; unaccessed up to $8a27
                lda #$ff
                sta arr11,x
                sta arr17,x
                sta arr18,x
                sta arr19,x
                rts

task_jump_table ; $8a28; called by main_loop; partially unaccessed
                dw sub19                     ;  0
                dw title_fadein              ;  1
                dw ingame_fadein2            ;  2
                dw explode                   ;  3
                dw title_fadeout             ;  4
                dw ingame_fadeout            ;  5
                dw ingame_fadein1            ;  6
                dw sub22                     ;  7
                dw sub24                     ;  8
                dw sub23                     ;  9
                dw sub25                     ; 10
                dw on_title                  ; 11
                dw in_game                   ; 12

ppu_fill        ; $8a42; write A to PPU Y*8 times
                ; called by: sub21
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

sub19           ; $8a5e; called by task_jump_table
                copy #0, stage
                lda #1
                sta task1
                sta task2
                jsr sub20
                jsr sub41
                jmp title_fadein

sub20           ; $8a71; called by sub19
                ldy #35
-               lda str_palette,y
                sta ppu_buffer,y
                dey
                bpl -
                copy #0, ram50
                rts

sub21           ; $8a82; called by ingame_fadein1
                bit ppu_status
                ;
                ; clear AT0
                copy #>ppu_at0, ppu_addr
                copy #<ppu_at0, ppu_addr
                lda #0
                ldy #8
                jsr ppu_fill                 ; write A to PPU Y*8 times
                ;
                ; clear AT2
                ldy #>ppu_at2
                sty ppu_addr
                ldy #<ppu_at2
                sty ppu_addr
                ldy #8
                jsr ppu_fill                 ; write A to PPU Y*8 times
                ;
                ; clear array
                lda #0
                ldy #9
-               sta arr2-1,y
                dey
                bne -
                ;
                jsr clear_oam_copy           ; fill oam_copy with $ff
                ;
                ldy #11
-               jsr prng_get
                sta stars_y,y
                jsr prng_get
                sta stars_x,y
                dey
                bpl -
                ;
                jsr sub15
                jsr sub31
                rts

title_fadein    ; $8aca; called by task_jump_table, sub19
                jsr clear_oam_copy           ; fill oam_copy with $ff
                lda ram7
                cmp #1
                beq +
                lda #0
                sta ppu_mask_copy2
                sta ppu_mask_copy1
                sta ppu_mask
                jsr sndeng_entry3
                jsr sub30
                copy #11, task3
                copy #1,  ram8
                copy #%00011110, ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
+               jsr ingame_fadein2
                lda task1
                cmp task2
                beq +
                copy #$80, ram8
+               rts

on_title        ; $8b03; called by task_jump_table
                copy #0, ram33
                jsr clear_oam_copy           ; fill oam_copy with $ff
                lda buttons_changed
                and #%10010000
                beq +
                lda #0
                jsr sndeng_entry2
                copy #6, task3
                copy #4, task2
                copy #0, ram8
                copy #0, stage
+               rts

ingame_fadein2  ; $8b26; called by task_jump_table, title_fadein
                lda timer
                bne +
                copy #9, timer
+               dec timer
                bne ++
                ldy task3
                sty task2
                cpy #11
                bcc +
                lda buttons_held
                and #%01111111
                sta buttons_held
+               cpy #$0c
                bne ++
                jsr sndeng_entry4
++              lda timer
                add #3
                and #%00001100
                asl a
                asl a
                jmp sub26

in_game         ; $8b53; called by task_jump_table
                lda ppu_mask_copy1
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
                ;
+               ldy stage
                lda stages_dat2,y
                sta ram32
                lda stages_dat1,y
                sta ram31
                lda stages_dat4,y
                sta ram34
                lda stages_dat3,y
                sta ram33
                ;
                lda ram25
                beq +
                ldy #4
                jmp loop2
+               lda buttons_held
                and #%00100000
                beq +
                ldy #2
                ;
loop2           asl ram32
                rol ram31
                asl ram34
                rol ram33
                dey
                bne loop2
                ;
+               jsr clear_oam_copy           ; fill oam_copy with $ff
                jsr sub10
                jsr sub15
                jsr sub39
                lda ram24
                bne +
                ;
                ; if reached next stage's level data...
                lda stage
                asl a
                tay
                iny
                iny
                lda lvl_dat_ptr+0
                cmp level_data_ptrs,y
                bne +
                lda lvl_dat_ptr+1
                cmp level_data_ptrs+1,y
                bne +
                ;
                ; ...do this
                lda #$10
                sta ram22
                sta ram24
                lda #0
                sta ram27
                sta ram26
                ;
+               lda ram24
                beq +
                lda ram27
                add ram34
                sta ram27
                lda ram26
                adc ram33
                sta ram26
                lda plr_y_hi
                add #$10
                cmp ram26
                bcs +
                copy #1, ram25
                ;
+               lda #0
                sta ram31
                sta ram32
                sta ram33
                sta ram34
                rts

explode         ; $8bfb; called by task_jump_table
                jsr clear_oam_copy           ; fill oam_copy with $ff
                lda timer
                bne +
                copy #22, timer
+               lda oam_copy+0*4+1           ; ship tile
                cmp #$30
                bcc +
                cmp #$3a
                bcs +
                adc #1                       ; carry always clear
                pha
                jsr sub12
                pla
                sta oam_copy+0*4+1
                copy #$01, oam_copy+0*4+2    ; ship attribute
                ;
+               dec timer
                bne +
                lda #0
                sta ram24
                sta ram22
                copy #1, ram8
                lda #6
                ldy ram7
                sta task3
                copy #5, task2
+               jsr sub15
                jsr rts4
                rts

                hex 6c 5a 5a                 ; $8c3f (unaccessed)

title_fadeout   ; $8c42; or maybe a general fadeout; called by task_jump_table,
                ; ingame_fadeout
                lda timer
                bne +
                copy #13, timer
+               dec timer
                bne +
                copy task3, task2
                lda #%00000000
                sta ppu_mask_copy2
                sta ppu_ctrl_copy
+               lda timer
                cmp #13
                bcs +
                add #3
                and #%00001100
                eor #%00001100
                asl a
                asl a
                jsr sub26
+               rts

ingame_fadeout  ; $8c6b; called by task_jump_table
                jsr clear_oam_copy           ; fill oam_copy with $ff
                jsr title_fadeout
                jsr sub15
                jmp rts4

ingame_fadein1  ; $8c77; called by task_jump_table
                jsr sub21
                copy #12, task3
                copy #2,  task2
                copy #0,  ram8
                copy #%00011110, ppu_mask_copy2
                lda ppu_ctrl_copy
                ora #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts

sub22           ; $8c94; unaccessed up to $8cba
                jsr clear_oam_copy           ; fill oam_copy with $ff
                copy #0, vscroll2
                jsr clear_nt0
                lda #2*11
                jsr print_str
                copy #8, task3
                copy #2, task2
                copy #0, ram8
                copy #%00011110, ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts

                hex dc dc                    ; $8cbb (unaccessed)

                ; e1 24 = SBC ($24,x)
                ; 24 nn = BIT nn
                hex e1 24                    ; $8cbd (unaccessed)

sub23           ; $8cbf; unaccessed
                jsr clear_nt0
                lda #16*2
                jsr print_str
                copy #10, task3
                copy #2,  task2
                copy #0,  ram8
                copy #%00011110, ppu_mask_copy2
                lda #%10001000
                sta ppu_ctrl_copy
                sta ppu_ctrl

sub24           ; $8cde; unaccessed
                bit buttons_changed
                bvc sub25
                copy #9, task3
                copy #4, task2
                rts

sub25           ; $8ceb; unaccessed
                bit buttons_changed
                bpl +
                copy #1, task3
                copy #4, task2
                copy #0, ram8
+               rts

sub26           ; $8cfc; called by ingame_fadein2, title_fadeout
                sta cod_dat_ptr+0
                ldy ram19
                lda #$3f
                sta palette_copy+0,y         ; positive = has data
                lda #$00
                sta palette_copy+1,y         ; ?
                lda #$20
                sta palette_copy+2,y         ; ?
                lda #$ff
                sta arr4,y
                tya
                add #31
                tay
                ;
                ldx #31
-               lda ppu_buffer+3,x
                and #%00001111
                cmp #$0d
                bcs +
                lda ppu_buffer+3,x
                sub cod_dat_ptr+0
                bcs ++
+               lda #$0f                     ; black
++              sta palette_copy+3,y
                dey
                dex
                bpl -
                ;
                tya
                add #$20
                sta ram19
                rts

                ; tiles for each 2*2-tile level block; 192 bytes/table;
                ; read by sub29; bytes used (in hexadecimal):
                ;     24-29, 30-35, 37-39, 40-42, 44, 46-49, 50-54, 59,
                ;     60, 61, 63, 64, 69-6f, 71, 79-7c, 7e, 88-8b, 8d, 8f,
                ;     91-94, 99, 9e, 9f, a1, a2, a5, a6, b5, b6, c1, f8

lvlblkdat_tl    ; $8d3c; top left tile of each 2*2-tile level block
                hex f8 38 f8 f8 40 a1 61 f8 31 f8 50 c1 f8 f8 91 41
                hex f8 51 f8 f8 71 59 34 f8 f8 f8 f8 f8 f8 40 38 38
                hex f8 f8 37 38 38 37 28 69 37 37 38 37 37 25 6f 38
                hex 38 47 38 f8 37 37 48 79 48 38 6d 28 6a 34 f8 39
                hex 7e 9e 25 28 39 f8 f8 7a 48 37 38 48 38 f8 f8 34
                hex 34 99 25 89 25 88 f8 f8 f8 34 99 25 26 f8 35 34
                hex f8 f8 f8 25 f8 f8 f8 39 f8 37 8b 8d 24 39 f8 34
                hex f8 46 f8 f8 f8 60 31 40 51 51 51 31 40 64 40 38
                hex 38 64 51 64 31 53 38 31 f8 31 40 51 32 f8 42 f8
                hex f8 f8 40 52 30 f8 30 40 38 38 53 f8 53 f8 f8 42
                hex 34 25 a2 f8 f8 25 25 92 34 34 25 44 25 f8 33 f8
                hex f8 50 41 a6 50 f8 61 f8 41 61 40 f8 f8 f8 f8 f8

lvlblkdat_tr    ; $8dfc; top right tile of each 2*2-tile level block
                hex f8 39 37 f8 41 51 f8 f8 f8 f8 51 41 f8 40 61 31
                hex 50 61 f8 50 31 31 f8 34 34 34 f8 f8 7b 7c 38 39
                hex f8 f8 38 38 39 6a 28 38 39 38 39 39 8b 25 28 38
                hex 39 9e 39 f8 39 7a 48 7a 49 7a 28 8f 28 f8 37 f8
                hex 48 25 6f 69 f8 f8 37 48 79 38 38 79 38 34 f8 f8
                hex f8 89 99 25 8a 25 f8 34 34 f8 25 35 f8 88 25 f8
                hex 34 f8 24 89 34 34 f8 f8 34 38 25 38 25 f8 f8 f8
                hex 44 f8 f8 f8 50 61 f8 41 61 61 41 50 63 61 63 38
                hex 38 61 63 41 50 38 54 50 50 f8 41 61 f8 f8 f8 f8
                hex f8 30 52 f8 31 32 31 61 38 54 38 f8 54 50 30 f8
                hex 93 94 f8 f8 44 25 46 f8 34 24 26 25 46 33 f8 f8
                hex f8 51 31 31 a5 60 40 40 51 f8 52 f8 f8 f8 92 f8

lvlblkdat_bl    ; $8ebc; bottom left tile of each 2*2-tile level block
                hex f8 48 f8 28 f8 91 f8 f8 41 f8 51 f8 71 f8 f8 40
                hex a1 61 31 50 c1 c1 34 f8 50 f8 89 25 25 f8 48 48
                hex 94 f8 9f 38 38 37 38 38 37 37 38 8d 37 f8 37 38
                hex 79 f8 38 28 69 37 f8 37 f8 38 37 38 38 8f 28 39
                hex 34 f8 f8 48 9e 6f f8 39 f8 8d 48 f8 7a 25 25 44
                hex 99 f8 f8 34 f8 34 26 f8 25 88 f8 f8 34 f8 34 35
                hex 25 25 f8 f8 f8 25 25 49 f8 47 39 37 34 8b f8 46
                hex f8 f8 6e 27 f8 f8 52 50 41 52 61 41 50 41 f8 63
                hex 38 61 61 61 41 38 38 54 50 54 50 54 f8 50 41 32
                hex f8 f8 f8 f8 40 f8 40 f8 63 38 63 50 38 f8 50 61
                hex 34 f8 26 24 25 25 25 34 46 34 f8 f8 f8 f8 f8 f8
                hex 33 b6 40 40 51 f8 f8 f8 51 31 f8 31 42 f8 f8 30

lvlblkdat_br    ; $8f7c; bottom right tile of each 2*2-tile level block
                hex f8 49 47 29 40 61 f8 27 31 50 61 40 31 f8 f8 41
                hex 51 f8 f8 51 41 41 f8 6b 6c 34 25 25 8a 88 48 9e
                hex f8 93 48 38 39 38 38 38 39 38 8b 39 39 f8 38 7a
                hex 39 f8 6a 28 39 39 f8 39 f8 39 38 6a 38 f8 69 f8
                hex f8 f8 7e 48 25 28 37 f8 7e 38 79 37 48 99 94 25
                hex 25 34 f8 f8 34 f8 f8 88 8a 25 f8 34 f8 34 f8 25
                hex 46 89 34 34 44 35 26 f8 a2 48 f8 38 f8 25 24 f8
                hex f8 f8 25 28 60 f8 f8 51 31 f8 40 51 51 31 40 38
                hex 64 f8 40 40 53 38 38 51 53 31 53 31 f8 42 31 f8
                hex 32 40 f8 f8 41 f8 52 f8 64 64 38 31 38 40 51 f8
                hex f8 f8 f8 25 25 25 25 f8 34 34 34 f8 f8 f8 f8 33
                hex f8 61 b5 41 61 f8 f8 50 41 f8 30 50 f8 30 a2 31

                ; stage-specific data read by in_game
stages_dat1     hex 00 00 00 ff 00 00 01     ; $903c
stages_dat2     hex 00 00 00 80 00 80 00     ; $9043
stages_dat3     hex 00 00 00 00 00 00 00     ; $904a
stages_dat4     hex 80 40 20 80 80 80 40     ; $9051

                ; stage-specific data read by sub27, sub31
stages_hscroll  hex 04 00 00 00 04 00 34     ; $9058
stages_dat5     hex 00 00 00 00 00 80 00     ; $905f

                ; level data; byte = which 2*2-tile block;
                ; first left to right, then up (forward);
                ; the first row repeats ten times instead of one;
                ; 172*16 = 2752 bytes; bytes used: $00-$bf;
                ; read by sub27, sub33
level_data      hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ; $9066
                ;
level_data1     hex 01 00 00 00 00 00 00 02 01 00 00 00 00 00 00 02  ; $9076
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
                ;
level_data2     hex 1e 1e 1e 1e 1e 1e 1f 20 21 22 1e 1e 1e 1e 1e 1e  ; $9196
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
                ;
level_data3     hex 1b 1b 1b 1b 4d 1b 4e 00 00 4f 1b 4d 1b 1b 50 1b  ; $9286
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
                ;
level_data4     hex 1b 4e 00 64 1b 60 00 64 1b 4e 00 64 1b 60 00 64  ; $9356
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
                ;
level_data5     hex 1e 1e 1e 67 00 68 00 00 00 00 68 00 00 69 1e 1e  ; $94a6
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
                ;
level_data6     hex 00 00 00 00 00 00 00 74 11 00 00 00 00 75 04 76  ; $96f6
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
                ;
level_data7     hex 6f 00 00 4f 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b 1b  ; $9996
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

level_data_ptrs ; $9b26; read by in_game, sub31
                dw level_data1
                dw level_data2
                dw level_data3
                dw level_data4
                dw level_data5
                dw level_data6
                dw level_data7
                dw level_data_ptrs

sub27           ; $9b36; called by sub39
                lda ram22
                beq sub28
                lda lvl_dat_ptr+0
                pha
                lda lvl_dat_ptr+1
                pha
                copy #<level_data, lvl_dat_ptr+0
                copy #>level_data, lvl_dat_ptr+1
                jsr sub28
                dec ram22
                bne +
                lda ram24
                beq +
                inc stage
                lda #0
                sta ram24
                sta ram25
                jsr sub40
                ldy stage
                lda stages_hscroll,y
                sta hscroll1
                sta hscroll2
                lda ram11
                sec
                sbc stages_dat5,y
                sta ram10
                cpy #7
                bne +
                copy #1, task3               ; $9b73 (unaccessed)
                copy #4, task2               ; unaccessed
                copy #0, ram8                ; unaccessed
                jsr sndeng_entry3            ; unaccessed
+               pla                          ; $9b82
                sta lvl_dat_ptr+1
                pla
                sta lvl_dat_ptr+0
                rts

sub28           ; $9b89; called by sub27, sub35
                inc ram20
                bne sub29
                inc ram21
                ;
sub29           ; $9b8f; called by sub28, sub33, sub34
                ldy #0
                jsr sub38
                copy arr1+0, ram16
                copy arr1+1, ram17
                copy #0,     cod_dat_ptr+0
                ;
-               ldy #0
                lda (lvl_dat_ptr),y
                inc lvl_dat_ptr+0
                bne +
                inc lvl_dat_ptr+1
+               tax
                ldy cod_dat_ptr+0
                lda lvlblkdat_tl,x
                ;hex a9 36 ea                 ; cheat
                sta curr_lvlblkrow,y
                lda lvlblkdat_tr,x
                sta curr_lvlblkrow+1,y
                lda lvlblkdat_bl,x
                ;hex a9 36 ea                 ; cheat
                sta curr_lvlblkrow+32,y
                lda lvlblkdat_br,x
                sta curr_lvlblkrow+32+1,y
                iny
                iny
                sty cod_dat_ptr+0
                cpy #32
                bne -
                ;
                copy #1, ram15
                sec
                rts

sub30           ; $9bd3; called by title_fadein
                lda #0
                sta vscroll1
                sta vscroll2
                sta hscroll1
                sta hscroll2
                jsr clear_nt0
                lda #STR_ID_TITLE            ; print title screen
                jsr print_str
                rts

; -----------------------------------------------------------------------------

sub31           ; $9be6; called by sub21
                jsr sndeng_entry4
                ldy stage
                lda stages_hscroll,y
                sta hscroll1
                sta hscroll2
                lda stages_dat5,y
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
                ;
                ; set lvl_dat_ptr to this stage's level data
                lda stage
                asl a
                tay
                lda level_data_ptrs,y
                sta lvl_dat_ptr+0
                lda level_data_ptrs+1,y
                sta lvl_dat_ptr+1
                ;
                lda #$ff
                sta ram20
                sta ram21
                jsr sub32
                copy #$0a, ram3
                jsr sub33
                copy #5, ram3
                jsr sub34
                ;
                copy #>$6a80, plr_x_hi
                copy #<$6a80, plr_x_lo
                copy #>$bf80, plr_y_hi
                copy #<$bf80, plr_y_lo
                ;
                jsr sub12
                jsr sub14
                rts

sub32           ; $9c49; called by sub31
                copy #0, ram15
                copy #>ppu_at0, arr1+0
                copy #<ppu_at0, arr1+1
                copy ram4, ppu_ctrl
                rts

sub33           ; $9c5b; called by sub31
                lda lvl_dat_ptr+0
                pha
                lda lvl_dat_ptr+1
                pha
-               copy #<level_data, lvl_dat_ptr+0
                copy #>level_data, lvl_dat_ptr+1
                jsr sub29
                jsr sub3
                dec ram3
                bne -
                pla
                sta lvl_dat_ptr+1
                pla
                sta lvl_dat_ptr+0
                rts

sub34           ; $9c7a; called by sub31
                jsr sub29
                jsr sub3
                dec ram3
                bne sub34
                rts

; -----------------------------------------------------------------------------

sub35           ; $9c85; unaccessed; called by ??
                jsr sub28
                jsr sub3
                dec ram3
                bne sub35
                rts

sub36           ; $9c90; called by sub39
                lda ram11
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

sub37           ; $9caa; unaccessed up to $9cbf; called by ??
                lda vscroll1
                add ram33
                sta vscroll2
                cmp #$f0
                bcc +
                adc #$0f
                sta vscroll2
                lda ram4
                eor #%00000010
                sta ppu_ctrl_copy
+               rts

sub38           ; $9cc0; called by sub29
                lda arr1+1,y
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

sub39           ; $9ce8; called by in_game
                copy ppu_ctrl_copy, ram2
                jsr sub36
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
                jsr sub27
+               rts

sub40           ; $9d08; called by sub27
                lda ppu_buffer+4
                add #5
                cmp #$0d
                bcc +
                sbc #$0c
+               sta ppu_buffer+4
                ora #%00010000
                sta ppu_buffer+5
                eor #%00110000
                sta ppu_buffer+6
                copy #STR_ID_PPUBUF, str_to_print
                rts

sub41           ; $9d26; called by sub19
                lda #$ff
                sta ram_shared
                sta ram49
                jsr sndeng_entry3
                ldx #8
                ldy #$ad
                jsr sndeng_entry6
                rts

sound_engine    ; Famitone2 sound engine
                incbin "prox-snd-eng.bin"    ; $9d37
                if $ != $c629
                    error "sound engine binary size mismatch"
                endif

                pad $c700, $00               ; $c629 (unaccessed)

reset           ; $c700; initialise the NES
irq             sei
                ldx #0
                stx ppu_ctrl
                stx ppu_mask
                sta snd_chn
                copy #$40, joypad2
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
                dex                          ; X = $ff
                txs
                stx palette_copy+0           ; mark as empty
                ;
                copy #0,   dmc_start
                copy #$4c, ram42
                bit $00
                rept 6
                    nop
                endr
                copy #>sub3, cod_ptr2+1
                copy #$0f,   dmc_freq
                nop
                ;
                bit $00
                lda #$7e
                ldx #$20
                jsr prng_init
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

region_loopcnts db 197, 182, 159, 79, 72, 60  ; $c78f; read by reset
regions         db 0, 2, 1, 0, 2, 1, 0        ; $c795; read by reset

; -----------------------------------------------------------------------------

read_joypad     ; $c79c; called by main_loop
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

clear_oam_copy  ; $c7c7; called by sub21, title_fadein, on_title, in_game,
                ; explode, ingame_fadeout, sub22
                lda #$ff
                ldx #$3c
-               sta oam_copy+$00,x
                sta oam_copy+$40,x
                sta oam_copy+$80,x
                sta oam_copy+$c0,x
                axs_imm 4                    ; $c7d7: equiv. to 4*DEX
                bpl -
                ;
                copy #$10, ram14
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
                copy ram8,  ram7
                copy #0,    ram13
                jmp main_loop

; -----------------------------------------------------------------------------

nmi             ; $c809
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
                copy #0, ram36
                lda ppu_mask_copy2
                ora #%00011110
                sta ppu_mask_copy2
                lda ram35
                cmp #$0f
                bne +
                lda ram28
                eor #%00000001
                sta ram28
                copy #0,   ram35
                copy #$fe, oam_copy+2*4+0    ; hide 2ndary shadow ship sprite
                lda oam_copy+0*4+3           ; swap X of ship and shadow ship
                ldy oam_copy+3*4+3
                sta oam_copy+3*4+3
                sty oam_copy+0*4+3
                ;
+               lda ram13
                beq +
                jmp nmi_end                  ; $c84e (unaccessed)
+               lda ram45
                beq +
                ;
                copy #$30, oam_copy+0*4+1    ; ship tile
                copy #$ff, oam_copy+1*4+0
                ;
                lda #3
                sta task1
                sta task2
                lda #2
                jsr sndeng_entry5
                copy #0, ram45
                ;
+               bit ppu_status
                jsr sub1
                jsr sub2
                ;
                copy ppu_mask_copy1, ppu_mask
                ;
                copy hscroll2, ppu_scroll
                ldy vscroll2
                sty ppu_scroll
                ;
                copy #0,         oam_addr
                copy #>oam_copy, oam_dma
                ;
                lda ppu_mask_copy2
                sta ppu_mask
                sta ppu_mask_copy1
                ;
                lda ppu_ctrl_copy
                sta ppu_ctrl
                sta ram4
                ;
                copy hscroll2, hscroll1
                copy vscroll2, vscroll1
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

sub42           lda ram13                    ; $c8b1 (unaccessed)
-               cmp ram13                    ; unaccessed
                bne -                        ; unaccessed
                rts                          ; unaccessed

                pad $ffe0, $00               ; $c8b8 (unaccessed)

                ; $ffe0: unaccessed up to $fff9
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
