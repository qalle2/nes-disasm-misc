; Irritating Ship for the NES. Assembles with ASM6.

; Original game:
;     filename: "Irritating Ship (NESdev Compo 2022).nes"
;     MD5:      a79c032efdd6fc1586e222a2dad89df8
;     authors:  Fiskbit, Trirosmos
;     website:  https://fiskbit.itch.io/irritating-ship

; Difficulty levels:
;     normal: +2 extra lives/checkpoint, max. 9
;     hard:   +1 extra life/checkpoint,  max. 3
;     expert: no extra lives
;     secret: time attack (press 3 * select in title screen);
;             time per checkpoint: 900 on NTSC, 750 on PAL, glitches on Dendy
;             (at least on FCEUX)

; Palettes:
;     default: 0f 00 10 20, except SPR1 = 0f 17 27 37
;     hue of colors 1-3 of BG0 increases by 5 when activating a checkpoint
;         (e.g. 0f 05 15 25)

; Tiles in pattern table 0 (background); all used except where noted (data may
; be incomplete):
;     00-09: digits "0"-"9"
;     0a-23: letters "A"-"Z"          ("QZ" not rendered)
;     24:    " "
;     25-26: walls - vertical
;     27-28: walls - horizontal
;     29-30: walls - diagonal 1
;     31-34: walls - 16*16 px sphere
;     35-38: walls - ~10*10 px sphere (none rendered)
;     39-64: walls - other curved
;     65-6a: walls - diagonal 2       (only 65, 66 rendered)
;     6b-7a: walls - tight corner     (only 6b-72, 75, 77-78 rendered)
;     7b-7e: walls - 90-degree corner
;     7f-8f: walls - misc             (only 80, 87, 8a-8b, 8f rendered)
;     db-e1: ",:/?'!."
;     e2-f3: checkpoints etc.
;     f4-f7: end-game item?           (none rendered)
;     f8-fb: solid colors 0-3         (only f9 rendered)
;     fc-ff: 16*16 px diamond shape

; Tiles in pattern table 1 (sprites); all used:
;     00-0c: ship,      turning from top to right
;     10-1c: exhaust 1, turning from top to right
;     20-2c: exhaust 2, turning from top to right
;     30-3a: explosion (last tile blank)
;     50-57: debris
;     c0-c5: big ball?
;     f0-f9: digits 0-9
;     fe:    star

; No PT data read programmatically.

; Sprite slots (8*8 px):
;     $00:     ship             (palette 0)
;     $01:     exhaust          (palette 1)
;     $06-$09: extra life icons (palette 0)
;     $06-$15: stars            (palette 3)
;     $12-$19: debris           (palette 0)
; (checkpoint icons are BG)

; "Unlimited lives" code:
;     "DEC $41" -> "LDA #$41"
;     910c:a9 = OZAOGO
;     (the game crashes if you crash before the 1st checkpoint)

; Was there supposed to be a second ship in this game?
;   - subs get_x_accel, get_y_accel and move_plr take an argument that's
;     always 0
;   - that argument is used to index player's position, speed and rotation
;   - there's unused RAM after those variables, enough for a second ship
;   - human-controlled (joypad 2 isn't read, however), computer-controlled or
;     a ghost?

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff.
; Variables shared with sound engine: region, sq1_prev, sq2_prev.

ptr1            equ $00  ; jump/data ptr (2 bytes, overlaps)
temp1           equ $00
temp2           equ $01
ptr2            equ $02  ; jump ptr (2 bytes, overlaps)
temp3           equ $02
temp4           equ $04
temp5           equ $0e
temp6           equ $0f
region          equ $10  ; 0=NTSC, 1=PAL, 2=Dendy
ppu_ctrl_copy1  equ $11
ppu_ctrl_copy2  equ $12
ppu_mask_copy1  equ $13
ppu_mask_copy2  equ $14
mode            equ $15  ; game status, offset to mode_jump_table (not skill!)
next_mode       equ $16  ; not sure about this
ram3            equ $17
ram4            equ $18
ram5            equ $19
scroll_x        equ $1a  ; ppu_scroll X copy
ram6            equ $1b
scroll_y        equ $1c  ; ppu_scroll Y copy
ram7            equ $1d
main_loop_flag  equ $1e  ; run if nonzero
free_spr_index  equ $20  ; next free index on OAM page
nmi_flag        equ $21  ; do stuff if nonzero
ptr3            equ $22  ; jump ptr (2 bytes)
arr1            equ $24
arr2            equ $25
ram11           equ $26
ram12           equ $27
str_to_print    equ $29  ; which string to print (=id*2+2; 0=none; see consts)
ram13           equ $2a
buttons_changed equ $2b  ; joypad - buttons having changed to "on"
buttons_held    equ $2c  ; joypad - buttons being pressed
ptr4            equ $2d  ; data ptr
ptr5            equ $2f  ; data ptr
ptr6            equ $31  ; data ptr
ram16           equ $33
ram17           equ $34
ram18           equ $35
ram19           equ $36
ram20           equ $37
ram21           equ $38
ram22           equ $39
ram23           equ $3a
ram24           equ $3b
ram25           equ $3c
ram26           equ $3d
ram27           equ $3e
skill           equ $3f  ; what the game calls "mode"; see constants
gravity         equ $40  ; 0=off, 1=on
lives_left      equ $41
ram28           equ $42
ram29           equ $43
ram30           equ $44
ram31           equ $45
ram32           equ $46
ram_jump_code   equ $47  ; a JMP absolute instruction (3 bytes)
ram36           equ $4a
ram37           equ $4c
sel_press_cnt   equ $4d  ; how many times select pressed on title
plr_x           equ $4e  ; 3 bytes, high first, unsigned
plr_y           equ $51  ; 3 bytes, high first, unsigned (on screen)
plr_x_spd       equ $54  ; 3 bytes, high first, signed (two's complement)
plr_y_spd       equ $57  ; 3 bytes, high first, signed (two's complement)
plr_rot         equ $5a  ; 0-47, 0=top, incr. clockwise
plr_rot_inquad  equ $5b  ; within quadrant (0=up/down...12=left/right)
plr_quad        equ $5c  ; quadrant (0-3, 0=top right, incr. clockwise)
; $5d seems to be unused
sq1_prev        equ $74
sq2_prev        equ $75

arr5            equ $0110  ; negative=no data in PPU buffer?
arr6            equ $0113
arr7            equ $0133
tile_row_top    equ $0150  ; 32*1 tiles (where are these read?)
tile_row_btm    equ $0170  ; 32*1 tiles

oam_page        equ $0200  ; 256 bytes

str_buffer      equ $0400  ; 36 bytes; str_ptr_tbl points here
ram40           equ $0424
ram41           equ $0425
warm_boot_ram   equ $0426  ; 6 bytes; string to check for warm boot
arr15           equ $042c
arr16           equ $0434
ram42           equ $043b
deb_x_hi        equ $043c  ; debris X positions - high bytes
deb_x_mid       equ $0444  ; debris X positions - middle bytes
deb_x_lo        equ $044c  ; debris X positions - low bytes
deb_y_hi        equ $0454  ; debris Y positions - high bytes
deb_y_mid       equ $045c  ; debris Y positions - middle bytes
deb_y_lo        equ $0464  ; debris Y positions - low bytes
deb_x_spds_hi   equ $046c  ; debris X speeds - high bytes
deb_x_spds_mid  equ $0474  ; debris X speeds - middle bytes
deb_x_spds_lo   equ $047c  ; debris X speeds - low bytes
deb_y_spds_hi   equ $0484  ; debris Y speeds - high bytes
deb_y_spds_mid  equ $048c  ; debris Y speeds - middle bytes
deb_y_spds_lo   equ $0494  ; debris Y speeds - low bytes
stars_x         equ $049c  ; 12 bytes
stars_y         equ $04a8  ; 12 bytes
stars_unkn1     equ $04b4  ; star-related? (12 bytes)
stars_unkn2     equ $04c0  ; star-related? (12 bytes)
; $04cc-$04d7 seem to be unaccessed
arr33           equ $04d8
arr34           equ $04dc
arr35           equ $04e0
arr36           equ $04e4
chex_touched    equ $04e9  ; checkpoints touched (2 bytes, LSB of 1st = 1st)
thrust_used     equ $04eb  ; thrust used (7 bytes, each 0-9)
crash_cnt       equ $04f2  ; number of ships crashed (3 bytes, each 0-9)
time_spent      equ $04f5  ; time spent (4 bytes: hr, min, sec, frames)
time_left       equ $04f9  ; 4 bytes; in time attack
arr43           equ $04fd

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

; external addresses in "irriship-snd-eng.bin"
snd_eng1        equ snd_eng_bin+$0
snd_eng2        equ snd_eng_bin+$88
snd_eng3        equ snd_eng_bin+$9a
snd_eng4        equ snd_eng_bin+$d7
snd_eng5        equ snd_eng_bin+$e3
snd_eng6        equ snd_eng_bin+$d29

; PPU memory space
ppu_nt0         equ $2000
ppu_at0         equ $23c0
ppu_nt2         equ $2800
ppu_at2         equ $2bc0
ppu_pal         equ $3f00

; unofficial opcode AXS immediate; X = (A & X) - value without borrow;
; updates NZC; 2 cycles
AXS_IMM         equ $cb

; values of "mode" variable
; intermediate states between title/ingame/dead:
;     boot to title:             MODE_PREP_TITLE
;     ingame to title:        4, MODE_PREP_TITLE
;     respawn on title:    3, 5, MODE_PREP_TITLE
;     title to ingame:     4, 6, MODE_PREP_INGAM
;     respawn ingame:   3, 5, 6, MODE_PREP_INGAM
;
MODE_PREP_TITLE equ  1  ; prepare title screen
MODE_PREP_INGAM equ  2  ; prepare game proper ("ingame")
MODE_DEAD       equ  3  ; dead on title screen or game proper
MODE_VICTORY    equ  7
MODE_WAIT_B     equ  8  ; wait for button B
MODE_CREDITS    equ  9
MODE_WAIT_A     equ 10  ; wait for button A
MODE_TITLE      equ 11  ; alive on title screen
MODE_INGAME     equ 12  ; alive in game proper

; values of "skill" variable
SKILL_NORMAL    equ 0
SKILL_HARD      equ 1
SKILL_EXPERT    equ 2
SKILL_SECRET    equ 3  ; time attack

; offsets to str_ptr_tbl; used in str_to_print and print_strings
STR_ID_NONE     equ -1  ; no string to print
STR_ID_BLAKPALS equ  0
STR_ID_BUFFER   equ  2  ; str_buffer (in RAM)
STR_ID_TITLE    equ  3
STR_ID_NORMAL1  equ  4
STR_ID_OFF1     equ  7
STR_ID_VICTORY1 equ  9
STR_ID_VICTORY2 equ 10
STR_ID_VICTORY3 equ 11
STR_ID_VICTORY4 equ 12
STR_ID_STATS    equ 13
STR_ID_CREDITS  equ 14
STR_ID_NORMAL2  equ 15
STR_ID_OFF2     equ 19
STR_ID_NTSC     equ 21

; use my rotation hack (0=no, 1=yes); just press d-pad to accelerate in that
; direction
ROTATE_HACK     equ 0

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

                ; iNES header; see https://www.nesdev.org/wiki/INES
                db "NES", $1a
                db 2, 1                 ; 32k PRG, 8k CHR
                db %00000000, %00001000  ; NROM, horiz. mirr., NES 2.0 header
                hex 00 00 00 00
                hex 02 00 00 01         ; what are these?

; --- PRG ROM start -----------------------------------------------------------

; labels: "sub" = subroutine, "cod" = code, "dat" = data, "icod" = indirectly
; accessed code, "idat" = indirectly accessed data

                base $8000

stack_to_ppu    ; $8000; copy 16 bytes from stack to PPU
rept 16         ;
                pla
                sta ppu_data
endr            ;
                tya
                bne non_rle_blk
                beq start_blk           ; unconditional
                ;
--              txs                     ; restore SP, $ff -> arr5, 0 -> ram13
                ldx #$ff
                stx arr5
                inx
                stx ram13
-               rts
                ;
flush_ppu_buf   ; $804f; called by nmi
                ;
                ; print string if there's any (STR_ID_NONE*2+2 = 0)
                lda str_to_print
                beq +
                jsr print_strings
                ;
+               lda arr5
                bmi -                   ; exit if negative
                copy #$80, ptr1+1
                copy #$80, ptr2+1
                tsx                     ; SP -> X, $0f -> SP
                txa
                ldx #$0f
                txs
                tax
                ;
start_blk       ; pull PPU address; exit if high byte is negative
                pla
                bmi --
                sta ppu_addr
                pla
                sta ppu_addr
                ;
                pla                     ; VRLLLLLL?
                asl a
                tay
                lda ppu_ctrl_copy1
                bcc +                   ; always taken
                ora #%00000100          ; vertical; address autoincrement 32
+               sta ppu_ctrl
                tya
                bmi ++                  ; R set? (never taken)
                lsr a
                bne non_rle_blk
                lda #64                 ; length 0=64
                ;
non_rle_blk     cmp #16
                bcc +                   ; never taken
                sbc #16
                tay
                jmp stack_to_ppu

                ; start unaccessed chunk ($8091)
+               ldy #0
                sbc #0
                eor #%00001111
                asl a
                asl a
                sta ptr1+0
                jmp (ptr1)
                ;
++              lsr a
                and #%00111111
                bne +
                lda #$40
+               eor #%11111111
                adc #$11
                sta temp4
                pla
                tay
                lda temp4
                sty temp4
                bpl +
-               ;
rept 16         ;
                sty ppu_data
endr            ;
                adc #$10
                bmi -
                bcc start_blk
+               tay
                lda dat1,y
                sta ptr2+0
                ldy temp4
                lda #0
                jmp (ptr2)
                ; end unaccessed chunk

; -----------------------------------------------------------------------------

print_strings   ; $80f6; print strings (palette/NT data) from str_ptr_tbl
                ; in: A: string id*2+2
                ; each set of strings:
                ;   - zero or more strings:
                ;       - PPU address (2 bytes, high first)
                ;       - 1 byte: VRLLLLLL:
                ;           V: print vertically?
                ;           R: RLE encoded?
                ;           LLLLLL: output length (0=64)
                ;       - data (1 byte if R=1, else outputLength bytes)
                ;   - terminator ($80-$ff)
                ; called by flush_ppu_buf, sub28, mode_prep_title, end_screen,
                ; credits_screen, sub47

                tay                     ; ptr1 = source address
                lda str_ptr_tbl-2,y
                sta ptr1+0
                lda str_ptr_tbl-1,y
                sta ptr1+1

print_strs_loop ldy #0                  ; position within one string
                lda (ptr1),y            ; PPU address high / terminator
                bmi exit_print_loop
                sta ppu_addr
                iny
                lda (ptr1),y            ; PPU address low
                sta ppu_addr
                ;
                iny
                lda (ptr1),y            ; VRLLLLLL
                iny
                asl a
                tax
                lda ppu_ctrl_copy1
                bcc +
                ora #%00000100          ; vertical; address autoincrement 32
+               sta ppu_ctrl
                txa
                bmi rle_string
                ;
                lsr a                   ; non-RLE string
                bne +
                lda #64
+               tax                     ; X = bytes left
-               lda (ptr1),y
                sta ppu_data
                iny
                dex
                bne -
                ;
next_string     tya                     ; add pos within string to address
                add ptr1+0
                sta ptr1+0
                lda ptr1+1
                adc #0
                sta ptr1+1
                jmp print_strs_loop
                ;
exit_print_loop lda #(STR_ID_NONE*2+2)  ; no string to print
                sta str_to_print
                rts
                ;
rle_string      lsr a
                and #%00111111
                bne +
                lda #64
+               tax                     ; X = bytes left
                lda (ptr1),y
                iny
-               sta ppu_data
                dex
                bne -
                jmp next_string

; -----------------------------------------------------------------------------

dat1            ; $8159, unaccessed
                hex b3 b6 b9 bc bf c2 c5 c8
                hex cb ce d1 d4 d7 da dd e0

cod1            ; $8169
rept 32         ;
                pla
                sta ppu_data
endr            ;
                jmp (ptr3)

                pad $8200, $00

nmisub2         ; $8200; called by nmi
                lda ppu_ctrl_copy1
                sta ppu_ctrl
                lda nmi_flag
                beq rts1
                ;
sub1            ; $8209; called by sub51, sub52
                tsx
                stx temp1
                ldx #$4f
                txs
                ldx ram11
                stx ppu_addr
                ldy ram12
                sty ppu_addr
                copy #$20, ptr3+0
                jmp cod1

icod1           ; $8220; jumped indirectly via ptr3
                stx ppu_addr
                tya
                ora #%00100000
                sta ppu_addr
                ldx #$6f
                txs
                copy #$33, ptr3+0
                jmp cod1

icod2           ; $8233
                ldx temp1
                txs
                stz nmi_flag
rts1            rts

nmisub3         ; $823b: write $24 four times to PPU; called by nmi
                ;
                ldy ram22
                lda arr34,y
                sta ppu_addr
                tax
                ;
                lda arr35,y
                sta ppu_addr
                ora #%00100000
                tay
                ;
                lda #$24
                sta ppu_data
                sta ppu_data
                stx ppu_addr
                sty ppu_addr
                sta ppu_data
                sta ppu_data
                rts

fill_nt0_space  ; $8262: fill NT0 with space character;
                ; called by end_screen, credits_screen, sub47
                ;
                lda #>ppu_nt0
                sta ppu_addr
                lda #<ppu_nt0
                sta ppu_addr
                ;
                ldy #240
                lda #$24
-               sta ppu_data
                sta ppu_data
                sta ppu_data
                sta ppu_data
                dey
                bne -
                rts

; -----------------------------------------------------------------------------

; string data
; note: ASCII to game encoding: subtract 55 from "A"-"Z" and 48 from "0"-"9"

macro dwbe _word
                db >(_word), <(_word)
endm
macro nt0_str _y, _x, _len
                dwbe ppu_nt0+(_y)*32+(_x)
                db _len
endm
macro pal_str _rle, _len
                dwbe ppu_pal
                db (_rle)*$40|(_len)
endm
macro at0_fill _byte
                dwbe ppu_at0
                db $40|0                ; RLE encoded, length 0=64
                db _byte
endm

str_ptr_tbl     ; string data pointer table ($8280); read by print_strings
                ;
                dw pal_black            ;  0
                dw pal_default          ;  1
                dw str_buffer           ;  2 (in RAM)
                dw str_title            ;  3
                dw str_normal1          ;  4
                dw str_hard1            ;  5
                dw str_expert1          ;  6
                dw str_off1             ;  7
                dw str_on1              ;  8
                dw str_victory1         ;  9
                dw str_victory2         ; 10
                dw str_victory3         ; 11
                dw str_victory4         ; 12
                dw str_stats            ; 13
                dw str_credits          ; 14
                dw str_normal2          ; 15
                dw str_hard2            ; 16
                dw str_expert2          ; 17
                dw str_secret           ; 18
                dw str_off2             ; 19
                dw str_on2              ; 20
                dw str_ntsc             ; 21
                dw str_pal              ; 22
                dw str_pal              ; 23

pal_black       ; $82b0; fill palette with black
                ;
                pal_str 1, 32
                hex 0f                  ; byte to repeat
                ;
                hex ff                  ; terminator

pal_default     ; set default palette
                ;
                pal_str 0, 32
                hex 0f 00 10 20         ; black, shades of gray
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 00 10 20
                hex 0f 17 27 37         ; black, shades of orange
                hex 0f 00 10 20
                hex 0f 00 10 20
                ;
                hex ff

str_title       ; title screen
                ;
                at0_fill $00
                ;
                nt0_str 2, 2, 59        ; "IRRITATING" - lines 1 & 2
                hex fc f9 ff fc f9 fc f9 fc f9
                hex ff fc f9 ff 24 fc fc f9 ff
                hex fc f9 ff fd 24 fd f9 f9 fd
                hex 24 24 24 24 24
                hex 24 f9 24 f9 24 f9 24 24 f9
                hex 24 24 f9 24 fc f9 24 f9 24
                hex 24 f9 24 f9 fd f9 f9 24 fd
                ;
                nt0_str 4, 2, 27        ; "IRRITATING" - line 3
                hex fc f9 ff ff 24 ff 24 fc f9
                hex ff 24 f9 fc ff f9 24 f9 24
                hex fc f9 ff f9 fe f9 fe f9 f9
                ;
                nt0_str 6, 10, 11       ; "SHIP" - line 1
                hex fc f9 ff f9 24 f9 fc f9 ff
                hex f9 f9
                ;
                nt0_str 7, 10, 11       ; "SHIP" - line 2
                hex fe f9 fd f9 f9 f9 24 f9 24
                hex f9 f9
                ;
                nt0_str 8, 10, 11       ; "SHIP" - line 3
                hex fc f9 ff fe 24 f9 fc f9 ff fe 24
                ;
                nt0_str 11, 13, 5       ; "START"
                db "START"-55
                ;
                nt0_str 13, 14, 3       ; start icon - line 1
                hex e6 e7 e8
                ;
                nt0_str 14, 14, 3       ; start icon - line 2
                hex e9 ea eb
                ;
                nt0_str 19, 7, 2        ; mode (skill) icon - line 1
                hex e2 e3
                ;
                nt0_str 20, 7, 2        ; mode (skill) icon - line 2
                hex e4 e5
                ;
                nt0_str 19, 22, 2       ; gravity icon - line 1
                hex e2 e3
                ;
                nt0_str 20, 22, 2       ; gravity icon - line 2
                hex e4 e5
                ;
                nt0_str 22, 19, 7       ; "GRAVITY"
                db "GRAVITY"-55
                ;
                nt0_str 23, 6, 4
                db "MODE"-55            ; "MODE"
                ;
                nt0_str 25, 4, 23       ; "2022 NESDEV COMPETITION"
                db "2022"-48, $24, "NESDEV"-55, $24, "COMPETITION"-55
                ;
                nt0_str 26, 8, 15       ; "GAME BY FISKBIT"
                db "GAME"-55, $24, "BY"-55, $24, "FISKBIT"-55
                ;
                nt0_str 27, 7, 18       ; "SOUND BY TRIROSMOS"
                db "SOUND"-55, $24, "BY"-55, $24, "TRIROSMOS"-55
                ;
                hex ff

str_normal1     nt0_str 22, 5, 6        ; "NORMAL"
                db "NORMAL"-55
                hex ff

str_hard1       nt0_str 22, 5, 6        ; " HARD "
                db $24, "HARD"-55, $24
                hex ff

str_expert1     nt0_str 22, 5, 6        ; "EXPERT"
                db "EXPERT"-55
                hex ff

str_off1        nt0_str 23, 21, 3       ; "OFF"
                db "OFF"-55
                hex ff

str_on1         nt0_str 23, 21, 3       ; " ON"
                db $24, "ON"-55
                hex ff

str_victory1    ; victory screen 1
                ;
                at0_fill $ff
                ;
                nt0_str 3, 8, 16        ; "CONGRATULATIONS!"
                db "CONGRATULATIONS"-55, $e0
                ;
                nt0_str 5, 3, 26        ; "YOU'VE SURVIVED YOUR TRIP,"
                db "YOU"-55, $df, "VE"-55, $24, "SURVIVED"-55, $24
                db "YOUR"-55, $24, "TRIP"-55, $db
                ;
                nt0_str 6, 3, 23        ; "JUST ANOTHER DAY IN THE"
                db "JUST"-55, $24, "ANOTHER"-55, $24, "DAY"-55, $24
                db "IN"-55, $24, "THE"-55
                ;
                nt0_str 7, 3, 21        ; "LIFE OF SPACE TRAVEL."
                db "LIFE"-55, $24, "OF"-55, $24, "SPACE"-55, $24
                db "TRAVEL"-55, $e1
                ;
                nt0_str 9, 3, 23        ; "GOOD THING THERE WASN'T"
                db "GOOD"-55, $24, "THING"-55, $24, "THERE"-55, $24
                db "WASN"-55, $df, "T"-55
                ;
                nt0_str 10, 3, 18       ; "ANY TRAFFIC TODAY!"
                db "ANY"-55, $24, "TRAFFIC"-55, $24, "TODAY"-55, $e0
                ;
                hex ff

str_victory2    ; victory screen 2
                ;
                at0_fill $ff
                ;
                nt0_str 3, 14, 4        ; "HUH?"
                db "HUH"-55, $de
                ;
                nt0_str 5, 3, 17        ; "DID YOU GET LOST?"
                db "DID"-55, $24, "YOU"-55, $24, "GET"-55, $24, "LOST"-55, $de
                ;
                nt0_str 6, 3, 20        ; "YOU ALMOST HAD IT..."
                db "YOU"-55, $24, "ALMOST"-55, $24, "HAD"-55, $24
                db "IT"-55, $e1, $e1, $e1
                ;
                nt0_str 8, 3, 26        ; "MAYBE THIS IS GOOD ENOUGH."
                db "MAYBE"-55, $24, "THIS"-55, $24, "IS"-55, $24
                db "GOOD"-55, $24, "ENOUGH"-55, $e1
                ;
                hex ff

str_victory3    ; victory screen 3
                ;
                at0_fill $ff
                ;
                nt0_str 3, 11, 11       ; "INCREDIBLE."
                db "INCREDIBLE"-55, $e1
                ;
                nt0_str 5, 3, 13        ; "YOU TRULY ARE"
                db "YOU"-55, $24, "TRULY"-55, $24, "ARE"-55
                ;
                nt0_str 6, 3, 26        ; "AN IRRITATING SHIP MASTER."
                db "AN"-55, $24, "IRRITATING"-55, $24, "SHIP"-55, $24
                db "MASTER"-55, $e1
                ;
                hex ff

str_victory4    ; victory screen 4
                ;
                at0_fill $ff
                ;
                nt0_str 3, 14, 4        ; "WOW!"
                db "WOW"-55, $e0
                ;
                nt0_str 5, 3, 24        ; "THAT'S SOME GOOD FLYING!"
                db "THAT"-55, $df, $1c, $24, "SOME"-55, $24, "GOOD"-55, $24
                db "FLYING"-55, $e0
                ;
                nt0_str 6, 3, 19        ; "MAYBE YOU NEED MORE"
                db "MAYBE"-55, $24, "YOU"-55, $24, "NEED"-55, $24, "MORE"-55
                ;
                nt0_str 7, 3, 12        ; "CHALLENGE..."
                db "CHALLENGE"-55, $e1, $e1, $e1
                ;
                nt0_str 9, 3, 23        ; "PRESS SELECT 3 TIMES ON"
                db "PRESS"-55, $24, "SELECT"-55, $24, "3"-48, $24
                db "TIMES"-55, $24, "ON"-55
                ;
                nt0_str 10, 3, 17       ; "THE TITLE SCREEN."
                db "THE"-55, $24, "TITLE"-55, $24, "SCREEN"-55, $e1
                ;
                hex ff

str_stats       ; victory screen statistics
                ;
                nt0_str 14, 2, 11       ; "DIFFICULTY:"
                db "DIFFICULTY"-55, $dc
                ;
                nt0_str 16, 2, 8        ; "GRAVITY:"
                db "GRAVITY"-55, $dc
                ;
                nt0_str 18, 2, 13       ; "CONSOLE TYPE:"
                db "CONSOLE"-55, $24, "TYPE"-55, $dc
                ;
                nt0_str 21, 2, 11       ; "TIME SPENT:"
                db "TIME"-55, $24, "SPENT"-55, $dc
                ;
                nt0_str 23, 2, 12       ; "THRUST USED:"
                db "THRUST"-55, $24, "USED"-55, $dc
                ;
                nt0_str 25, 2, 14       ; "SHIPS CRASHED:"
                db "SHIPS"-55, $24, "CRASHED"-55, $dc
                ;
                nt0_str 27, 2, 28       ; "CHECKPOINTS SKIPPED:     /12"
                db "CHECKPOINTS"-55, $24, "SKIPPED"-55, $dc
                db $24, $24, $24, $24, $24, $dd, "12"-48
                ;
                hex ff

str_normal2     nt0_str 14, 24, 6       ; "NORMAL"
                db "NORMAL"-55
                hex ff

str_hard2       nt0_str 14, 26, 4       ; "HARD"
                db "HARD"-55
                hex ff

str_expert2     nt0_str 14, 24, 6       ; "EXPERT"
                db "EXPERT"-55
                hex ff

str_secret      nt0_str 14, 24, 6       ; "SECRET"
                db "SECRET"-55
                hex ff

str_off2        nt0_str 16, 27, 3       ; "OFF"
                db "OFF"-55
                hex ff

str_on2         nt0_str 16, 28, 2       ; "ON"
                db "ON"-55
                hex ff

str_ntsc        nt0_str 18, 26, 4       ; "NTSC"
                db "NTSC"-55
                hex ff

str_pal         nt0_str 18, 27, 3       ; "PAL"
                db "PAL"-55
                hex ff

str_credits     ; credits screen after victory screen
                ;
                nt0_str 5, 8, 15        ; "IRRITATING SHIP"
                db "IRRITATING"-55, $24, "SHIP"-55
                ;
                nt0_str 7, 4, 23        ; "2022 NESDEV COMPETITION"
                db "2022"-48, $24, "NESDEV"-55, $24, "COMPETITION"-55
                ;
                nt0_str 8, 12, 7        ; "VERSION"
                db "VERSION"-55
                ;
                nt0_str 12, 2, 24       ; "DESIGN, ART, PROGRAMMING"
                db "DESIGN"-55, $db, $24, "ART"-55, $db, $24, "PROGRAMMING"-55
                ;
                nt0_str 13, 23, 7       ; "FISKBIT"
                db "FISKBIT"-55
                ;
                nt0_str 15, 2, 12       ; "MUSIC, SOUND"
                db "MUSIC"-55, $db, $24, "SOUND"-55
                ;
                nt0_str 16, 21, 9       ; "TRIROSMOS"
                db "TRIROSMOS"-55
                ;
                nt0_str 18, 2, 9        ; "LIBRARIES"
                db "LIBRARIES"-55
                ;
                nt0_str 19, 21, 9       ; "FAMITONE2"
                db "FAMITONE"-55, $02
                ;
                nt0_str 20, 19, 11      ; "FAMITRACKER"
                db "FAMITRACKER"-55
                ;
                hex ff

                hex b4 b4 b5 b5         ; $8704, unaccessed

; -----------------------------------------------------------------------------

sub2            ; $8708; called by reset
                sta ram29
                stx ram30
                sta ram31
                stx ram32
                ;
sub3            ; $8710; called by sub22, sub28
                clc
                lda ram29
                adc #$b3
                sta ram29
                adc ram30
                sta ram30
                adc ram31
                sta ram31
                eor ram29
                and #%01111111
                tax
                lda ram31
                adc ram32
                sta ram32
                eor ram30
                rts

sub4            ; $872d; called by draw_stars
                lsr a
                sta temp1
                lda #0
                ldy #8
-               bcc +
                add temp2
+               ror a
                ror temp1
                dey
                bne -
                rts

sub5            ; $8740; called by draw_stars
                eor #%11111111
                sta temp2
                lda temp1
                eor #%11111111
                add #1
                sta temp1
                bcc +
                inc temp2
+               rts

inc_thrust_cntr ; $8752; increment amount of thrust used; called by accel_plr
                ;
                ldy #6
                sec
-               lda thrust_used,y
                adc #0
                cmp #10
                bcc +
                sbc #10
                sta thrust_used,y
                dey
                bpl -
                ;
                ; limit to 9,999,999
                lda #9
                ldy #6
-               sta thrust_used,y
                dey
                bpl -
                rts
                ;
+               sta thrust_used,y
                rts

inc_crash_cnt   ; $8775; increment number of ships crashed; called by mode_dead
                ;
                ldy #2
                sec
-               lda crash_cnt,y
                adc #0
                cmp #10
                bcc +
                sbc #10
                sta crash_cnt,y
                dey
                bpl -
                ;
                ; limit to 999
                lda #9
                ldy #2
-               sta crash_cnt,y
                dey
                bpl -
                rts
                ;
+               sta crash_cnt,y
                rts

get_chex_skipd  ; $8798; return number of checkpoints skipped in temp1 (ones)
                ; and temp2 (tens); called by end_screen
                ;
                copy #$ff, temp2
                ldy #1
                lda #0
                ;
                ; count checkpoints touched (bits set in 2 bytes)
--              ldx chex_touched,y
                stx temp1
                ldx #8
-               lsr temp1
                adc #0
                dex
                bne -
                dey
                bpl --
                ;
                ; get number of checkpoints skipped
                sta temp1
                lda #12
                sub temp1
                ;
                ; split into tens and ones
-               inc temp2
                sub #10
                bcs -
                adc #10
                sta temp1
                lda temp2
                bne +
                copy #$24, temp2        ; space
+               rts

inc_time_spent  ; $87cc; increment amount of time spent; called by mode_ingame
                ;
                ldy region
                ;
                ; frames
                lda time_spent+3
                add #1
                cmp console_fps,y
                bcc +
                lda #0
+               sta time_spent+3
                ;
                ; seconds and minutes
                ldx #1
-               lda time_spent+1,x
                adc #0
                cmp #60
                bcc +
                lda #0
+               sta time_spent+1,x
                dex
                bpl -
                ;
                ; hours
                lda time_spent+0
                adc #0
                cmp #100
                bcc +
                ;
                ; limit to 99:99:99.59/.49
                lda console_fps_m1,y
                sta time_spent+3
                lda #59
                sta time_spent+2
                sta time_spent+1
                lda #99
+               sta time_spent+0
                rts

console_fps     db 60, 50, 50           ; NTSC/PAL/Dendy
console_fps_m1  db 59, 49, 49           ; NTSC/PAL/Dendy, minus one

to_decimal      ; $8814; in: byte in A; return tens in Y and ones in A;
                ; called by end_screen
                ;
                ldy #$ff
-               iny
                sub #10
                bcs -
                adc #10
                rts

dec_time_left   ; decrement timer on secret skill ($881f; happens every frame)
                ; out: carry: clear if time has run out, else set
                ; called by accel_plr, mode_ingame
                ;
                ; if on title screen or not secret skill, exit with carry set
                lda skill
                cmp #SKILL_SECRET
                bne +
                lda mode
                cmp #MODE_TITLE
                beq +
                ;
                ; if no time left, exit with carry clear
                ldx #3
                lda #$00
-               ora time_left,x
                dex
                bpl -
                cmp #1
                bcc rts2
                ;
                ; decrement time left and exit with carry set
                ldx #3
-               dec time_left,x
                bpl +
                lda #9
                sta time_left,x
                dex
                bpl -
                ;
+               sec
rts2            rts

time_extend     ; increase amount of time left ($884a); called by sub31, sub48
                ;
                ; Y: NTSC=3, PAL=7, Dendy=11
                ldy #3
                lda region
                beq +
                asl a
                asl a
                adc #3
                tay
                ;
+               ldx #3
                clc
-               lda time_left,x
                adc time_extend_tbl,y   ; reads out of bounds?
                cmp #10
                bcc +
                sbc #10
+               sta time_left,x
                dey
                dex
                bpl -
                rts

time_extend_tbl ; how much time to add
                db 0, 9, 0, 0           ; NTSC
                db 0, 7, 5, 0           ; PAL

; -----------------------------------------------------------------------------

sub13           ; $8874; called by mode_title, mode_ingame
                jsr rotate_plr
                jsr accel_plr
                ;
                lda gravity             ; apply gravity
                beq +
                jsr grav_acc_plr
                ;
+               ldx #0
                jsr move_plr
                jsr sub14
                lda plr_y+0
                cmp #$f0
                bcc ++
                ;
                lda #$10
                bit plr_y_spd+0
                bpl +
                lda #$f0
+               add plr_y+0
                sta plr_y+0
                lda mode
                cmp #MODE_INGAME
                bne ++
                ;
                lda #1
                ldy ram17
                beq +
                copy #1, ram4
                lda #7
+               sta ram5
                copy #4, next_mode
                rts
                ;
++              jsr set_exhaust_spr
                jsr set_ship_spr
                rts

sub14           ; $88bc; called by sub13
                ;
                lda plr_y_spd+0
                bpl pos_y_spd
                ;
                ; negative Y speed; similar to "positive" section below
                bit ram16
                bmi rts3
                lda plr_y+0
                cmp #$7b
                bcs rts3
                lda #$7c
                sbc plr_y+0
                cmp #$11
                bcs rts3
                sta ram27
                lda ppu_ctrl_copy2
                sta temp5
                jsr sub53
                stz ram16
                lda scroll_y
                eor ram6
                cmp #$10
                bcc ++
                jsr sub41
                bcs ++
                lda #$80
                sta ram16
                sta ram17
                lda temp5
                sta ppu_ctrl_copy2
                lda scroll_y
                adc #$10
                and #%11110000
                cmp #$f0
                bcc +
                ;
                lda #0
+               sta scroll_y
                lda ram6
                sub scroll_y
                sta ram27
                add plr_y+0
                rts
                ;
++              copy #$7b, plr_y+0
rts3            rts
                ;
pos_y_spd       ; $8914; positive Y speed; similar to "negative" section above
                bit ram16
                bvs rts4
                lda plr_y+0
                cmp #$9c
                bcc rts4
                lda plr_y+0
                sbc #$9b
                cmp #$11
                bcs rts4
                sta ram27
                jsr sub54
                stz ram16
                lda scroll_y
                eor ram6
                cmp #$10
                bcc ++
                jsr sub44
                bcs ++
                copy #$40, ram16
                lda scroll_y
                and #%11110000
                cmp #$f0
                bcc +
                ;
                lda #$e0
+               sta scroll_y
                lda scroll_y
                sub ram6
                bcs +
                sbc #$0f
+               sta ram27
                lda plr_y+0
                sub ram27
                rts
                ;
++              copy #$9b, plr_y+0
rts4            rts

set_ship_spr    ; $8962; set player ship sprite;
                ; called by: sub13, sub29, mode_dead, sub47, sub48, sub49
                ;
                lda plr_rot_inquad      ; tile
                sta oam_page+0*4+1
                ldy plr_quad            ; attributes
                lda quad_to_attr,y
                sta oam_page+0*4+2
                lda plr_x+0             ; X
                sta oam_page+0*4+3
                lda plr_y+0             ; Y
                sta oam_page+0*4+0
                rts

set_exhaust_spr ; $897a; set player's exhaust sprite; called by sub13
                ;
                lda ram25
                beq ++
                ;
                cmp #$0b                ; tile
                lda #$10
                bcc +
                lda #$20
+               ora plr_rot_inquad
                sta oam_page+1*4+1
                ;
                ldy plr_quad            ; attributes
                lda quad_to_attr,y
                ora #%00000001          ; palette 1
                sta oam_page+1*4+2
                ;
                jsr get_exhaust_x       ; X
                sta oam_page+1*4+3
                ;
                jsr get_exhaust_y       ; Y
                sta oam_page+1*4+0
++              rts

rotate_plr      ; react to left/right arrow and update player rotation
                ; variables ($89a2); called by sub13
                ;
if ROTATE_HACK  ;
                ; this code written by qalle
                lda buttons_held
                ldx #7
-               cmp rot_hack_tbl,x
                beq +
                dex
                bpl -
                bmi update_quadr        ; nothing pressed (unconditional)
                ; U, UR, R, DR, D, DL, L, UL
rot_hack_tbl    db %1000, %1001, %0001, %0101, %0100, %0110, %0010, %1010
+               txa
                sta plr_rot             ; multiply by 6
                asl a
                adc plr_rot             ; carry is always clear
                asl a
                sta plr_rot
                pad $89c1, $ea
else            ;
                lda buttons_held        ; left pressed?
                lsr a
                bcc ++
                ;
                lda plr_rot             ; rotate ship right
                cmp #47
                bcc +
                lda #254
+               adc #1
                sta plr_rot
                jmp update_quadr
                ;
++              lsr a                   ; right pressed?
                bcc rts6
                ;
                dec plr_rot             ; rotate ship left
                bpl update_quadr
                lda #47
                sta plr_rot
endif           ;
update_quadr    ; update quadrant ($89c1)
                lda plr_rot
                ldy #255
-               iny
                sub #12
                bpl -
                sty plr_quad
                ;
                ; update rotation within quadrant (0=up/down...12=left/right)
                adc #12
                sta temp1
                tya
                lsr a
                bcc +
                lda #12
                sub temp1
                jmp ++
+               lda temp1
++              sta plr_rot_inquad
rts6            rts

accel_plr       ; $89e2; accelerate player (add acceleration to speed);
                ; called by sub13
                ;
                lda buttons_held
if ROTATE_HACK  ;
                and #%00001111
else            ;
                and #%10000000
endif           ;
                bne +
-               stz ram25
                rts
+               jsr dec_time_left
                bcc -
                lda buttons_changed
                bpl +
                lda #0
                jsr snd_eng5
+               jsr inc_thrust_cntr
                ldy plr_rot
                ;
                ldx #0
                jsr get_x_accel         ; writes temp1 (2 bytes)
                lda temp1+0
                add plr_x_spd+2
                sta plr_x_spd+2
                lda temp1+1
                bpl +
                dex                     ; sign extend acceleration
+               adc plr_x_spd+1
                sta plr_x_spd+1
                txa
                adc plr_x_spd+0
                sta plr_x_spd+0
                ;
                ldx #0
                jsr get_y_accel         ; writes temp1 (2 bytes)
                lda temp1+0
                add plr_y_spd+2
                sta plr_y_spd+2
                lda temp1+1
                bpl +
                dex                     ; sign extend acceleration
+               adc plr_y_spd+1
                sta plr_y_spd+1
                txa
                adc plr_y_spd+0
                sta plr_y_spd+0
                ;
                dec ram25
                beq +
                bpl ++
+               copy #$14, ram25
++              jsr limit_speed
                rts

limit_speed     ; limit player's X and Y speed ($8a42); called by accel_plr
                ;
                ; limit X speed according to region
                ;
                ldy region
                lda plr_x_spd+0
                bmi +
                ;
                cmp max_pos_x_spds,y    ; positive
                bcc +++
                lda max_pos_x_spds,y
                sta plr_x_spd+0
                jmp ++
                ;
+               cmp max_neg_x_spds,y    ; negative
                bcs +++
                lda max_neg_x_spds,y
                sta plr_x_spd+0
                ;
++              lda #0                  ; clear fractional
                sta plr_x_spd+2
                sta plr_x_spd+1
                ;
+++             ; limit Y speed regardless of region
                ;
                lda plr_y_spd+0
                bmi +
                ;
                cmp #16                 ; positive
                bcc +++
                lda #16
                sta plr_y_spd+0
                jmp ++
                ;
+               cmp #(256-16)           ; negative
                bcs +++
                lda #(256-16)
                sta plr_y_spd+0
                ;
++              lda #0                  ; clear fractional
                sta plr_y_spd+2
                sta plr_y_spd+1
                ;
+++             rts

max_pos_x_spds  db 14,     12,     12      ; NTSC/PAL/Dendy
max_neg_x_spds  db 256-14, 256-12, 256-12  ; NTSC/PAL/Dendy

grav_acc_plr    ; apply gravitational acceleration to player ($8a89)
                ; called by sub13
                ;
                lda ram37
                beq +
                ;
                ldy region
                lda plr_y_spd+2
                clc
                adc gravities_lo,y
                sta plr_y_spd+2
                lda plr_y_spd+1
                adc gravities_hi,y
                sta plr_y_spd+1
                lda plr_y_spd+0
                adc #0
                sta plr_y_spd+0
+               rts

                ; gravity for NTSC/PAL/Dendy ($8aa5); PAL = ~1.44*NTSC
gravities_lo    dl 640, 922, 922
gravities_hi    dh 640, 922, 922

; -----------------------------------------------------------------------------

grav_acc_debris ; apply gravitational acceleration to debris ($8aab)
                ; called by move_debris
                ;
                ldy region
                ldx #7
-               lda deb_y_spds_lo,x
                clc
                adc gravities_lo,y
                sta deb_y_spds_lo,x
                lda deb_y_spds_mid,x
                adc gravities_hi,y
                sta deb_y_spds_mid,x
                lda deb_y_spds_hi,x
                adc #0
                sta deb_y_spds_hi,x
                dex
                bpl -
                rts

get_x_accel     ; $8ace; get player X acceleration; called by accel_plr
                ; in: X (always 0)
                ; out: X acceleration in temp1 (2 bytes, low first)
                ;
                ldy plr_rot_inquad,x
                lda region
                beq +
                tya
                add #13
                tay
+               lda accels_x_lo,y
                sta temp1+0
                lda accels_x_hi,y
                sta temp1+1
                ;
                lda plr_quad,x
                and #%00000010
                beq +
                ;
-               lda temp1+0             ; quadrants 2/3 (left); negate temp1
                eor #%11111111
                add #1
                sta temp1+0
                lda temp1+1
                eor #%11111111
                adc #0
                sta temp1+1
+               rts

get_y_accel     ; $8afb; get player Y acceleration; called by accel_plr
                ; in: X (always 0)
                ; out: Y acceleration in temp1 (2 bytes, low first)
                ;
                ldy plr_rot_inquad,x
                lda region
                beq +
                tya
                add #13
                tay
+               lda accels_y_lo,y
                sta temp1+0
                lda accels_y_hi,y
                sta temp1+1
                ;
                lda plr_quad,x
                beq +
                cmp #3
                bcc -         ; if quadrant 1/2 (down), negate temp1 and return
+               rts

; -----------------------------------------------------------------------------

get_exhaust_x   ; X of player's exhaust -> A; called by set_exhaust_spr
                ldy plr_rot_inquad
                lda exhaust_x_ofs,y
                sta temp1
                lda plr_quad
                and #2
                beq +
                lda temp1               ; left quadrants; negate offset
                eor #%11111111
                add #1
                jmp ++
+               lda temp1
++              add plr_x+0
                rts

exhaust_x_ofs   db 0,     0,     0,     0
                db 256-4, 256-5, 256-5, 256-5
                db 256-6, 256-6, 256-6, 256-6
                db 256-6

get_exhaust_y   ; Y of player's exhaust -> A; called by set_exhaust_spr
                ldy plr_rot_inquad
                lda exhaust_y_ofs,y
                sta temp1
                lda plr_quad
                beq +
                cmp #3
                bcs +
                lda temp1               ; bottom quadrants; negate offset
                eor #%11111111
                add #1
                jmp ++
+               lda temp1
++              add plr_y+0
                rts

exhaust_y_ofs   db 6, 6, 6, 6
                db 6, 5, 5, 5
                db 4, 0, 0, 0
                db 0

; -----------------------------------------------------------------------------

                ; X/Y acceleration of ship; 26 values per array;
                ; index: plr_rot_inquad, plus 13 if region = PAL/Dendy;
                ; read by get_x_accel, get_y_accel
                ;
                ; maximum acceleration:
                ;          PAL  NTSC ratio
                ;          ---- ---- -----
                ;       Y  4135 2872 1.44
                ;       X  2983 2513 1.19
                ;   ratio  1.39 1.14
                ;
                ; Y/X ratios (1.39, 1.14) = NES pixel aspect ratios
                ; PAL/NTSC X ratio (1.19) is close to NTSC/PAL FPS ratio (1.20)
                ;
accels_y_hi     ; $8b6f
                ; NTSC
                dh 65536-2872, 65536-2847, 65536-2774, 65536-2653
                dh 65536-2487, 65536-2278, 65536-2030, 65536-1748
                dh 65536-1436, 65536-1099, 65536- 743, 65536- 374
                dh 0
                ; PAL/Dendy
                dh 65536-4135, 65536-4100, 65536-3994, 65536-3820
                dh 65536-3581, 65536-3281, 65536-2924, 65536-2517
                dh 65536-2067, 65536-1582, 65536-1070, 65536- 539
                dh 0
                ;
accels_y_lo     ; $8b89
                ; NTSC
                dl 65536-2872, 65536-2847, 65536-2774, 65536-2653
                dl 65536-2487, 65536-2278, 65536-2030, 65536-1748
                dl 65536-1436, 65536-1099, 65536- 743, 65536- 374
                dl 0
                ; PAL/Dendy
                dl 65536-4135, 65536-4100, 65536-3994, 65536-3820
                dl 65536-3581, 65536-3281, 65536-2924, 65536-2517
                dl 65536-2067, 65536-1582, 65536-1070, 65536- 539
                dl 0
                ;
accels_x_hi     ; $8ba3
                ; NTSC
                dh    0,  328,  650,  961
                dh 1256, 1529, 1776, 1993
                dh 2176, 2321, 2427, 2491
                dh 2513
                ; PAL/Dendy
                dh    0,  389,  772, 1141
                dh 1491, 1816, 2109, 2366
                dh 2583, 2756, 2881, 2957
                dh 2983
                ;
accels_x_lo     ; $8bbd
                ; NTSC
                dl    0,  328,  650,  961
                dl 1256, 1529, 1776, 1993
                dl 2176, 2321, 2427, 2491
                dl 2513
                ; PAL/Dendy
                dl    0,  389,  772, 1141
                dl 1491, 1816, 2109, 2366
                dl 2583, 2756, 2881, 2957
                dl 2983

quad_to_attr    ; player's ship's quadrant to sprite attribute byte ($8bd7)
                ; no flip, V flip, V & H flip, H flip
                db %00000000, %10000000, %11000000, %01000000

draw_hud        ; draw extra lives or timer ($8bdb)
                ; called by mode_ingame, mode_dead, mode5, sub48, sub49
                ;
                copy #$10, temp1
                ldx free_spr_index      ; index on OAM page
                ldy skill
                cpy #SKILL_SECRET
                beq draw_timer
                ;
                ldy lives_left          ; 0 / 1-4 / 5+ lives left?
                beq rts10
                cpy #5
                bcc cod2
                ldy #1
                ;
cod2            ; draw extra life icons (one if 5+ lives)
                lda temp1
                sta oam_page+3,x
                add #8
                sta temp1
                lda #18
                sta oam_page+0,x
                lda #0
                sta oam_page+1,x
                sta oam_page+2,x
                inx
                inx
                inx
                inx
                dey
                bne cod2
                ;
                lda lives_left
                cmp #5
                bcc +
                ;
                ; draw number of extra lives (5+)
                ora #$f0                ; digits are $f0-$f9 on PT1
                sta oam_page+1,x
                lda #18
                sta oam_page+0,x
                lda temp1
                sta oam_page+3,x
                lda #%00000000
                sta oam_page+2,x
                inx
                inx
                inx
                inx
+               stx free_spr_index
rts10           rts
                ;
draw_timer      ; 4 digits
                ldy #0
-               lda time_left,y
                ora #$f0
                sta oam_page+1,x
                lda #$12
                sta oam_page+0,x
                lda temp1
                sta oam_page+3,x
                add #8
                sta temp1
                lda #%00000000
                sta oam_page+2,x
                inx
                inx
                inx
                inx
                iny
                cpy #4
                bcc -
                stx free_spr_index
                rts

sub20           ; $8c5a; called by mode_title, mode_ingame
                ;
                copy #1, ram28
                lda #0
                sta plr_rot_inquad
                sta plr_quad
                sta plr_x_spd+0
                sta plr_x_spd+1
                sta plr_x_spd+2
                sta plr_y_spd+1
                sta plr_y_spd+2
                lda #$fa
                sta plr_y_spd+0
                rts

move_plr        ; add player speed to position; called by sub13, sub29;
                ; in: X (always 0)
                ;
                lda plr_x+2,x
                clc
                adc plr_x_spd+2,x
                sta plr_x+2,x
                lda plr_x+1,x
                adc plr_x_spd+1,x
                sta plr_x+1,x
                lda plr_x+0,x
                adc plr_x_spd+0,x
                sta plr_x+0,x
                ;
                lda plr_y+2,x
                clc
                adc plr_y_spd+2,x
                sta plr_y+2,x
                lda plr_y+1,x
                adc plr_y_spd+1,x
                sta plr_y+1,x
                lda plr_y+0,x
                adc plr_y_spd+0,x
                sta plr_y+0,x
                ;
                rts

draw_stars      ; draw 12 star sprites? ($8c9a);
                ; called by sub28, mode_title, mode_ingame, mode_dead, mode5
                ;
                ldx free_spr_index      ; index on OAM page
                beq rts11
                ;
                ldy #11
                sty temp3               ; loop counter
                ;
-               ldy temp3
                lda ram27
                beq +++
                ;
                sta temp2
                lda dat10,y
                clc
                adc stars_unkn2,y
                jsr sub4
                sta temp2
                bit plr_y_spd+0
                bmi +
                jsr sub5
+               ldy temp3
                lda temp1
                clc
                adc stars_unkn1,y
                sta stars_unkn1,y
                lda stars_y,y
                adc temp2
                sta stars_y,y
                bit temp2
                bmi +
                bcc +++
                ;
                lda #0
                bcs ++
+               bcs +++
                ;
                lda #$ff
++              sta stars_y,y
                lda dat9,y
                adc ram32
                sta stars_x,y
                lda ram31
                and #%01111111
                sta stars_unkn2,y
                ;
+++             lda stars_y,y           ; Y position
                sta oam_page+0,x
                lda stars_x,y           ; X position
                sta oam_page+3,x
                lda #%00100011          ; attribute (behind BG, palette 3)
                sta oam_page+2,x
                lda #$fe                ; tile (star)
                sta oam_page+1,x
                ;
                db AXS_IMM, $fc         ; X = (A & X) - value without borrow
                beq +
                dec temp3
                bpl -
                ;
+               stx free_spr_index
rts11           rts

dat9            hex ec 42 73 61 2d 94 28 22  ; $8d11
                hex c9 e1 62 a9
dat10           hex 20 28 30 38 40 48 50 58
                hex 60 68 70 78

sub22           ; $8d29; called by mode_dead
                ;
                ldx #0
                ldy #0
--              lda plr_x+0,y
                sty temp1
                ldy #8
-               sta deb_x_hi,x
                inx
                dey
                bne -
                ldy temp1
                iny
                cpy #$0c
                bcc --
                ;
                ldy #7
-               jsr sub3
                lsr a
                lsr a
                sub #$20
                php
                clc
                adc deb_x_spds_mid,y
                sta deb_x_spds_mid,y
                lda deb_x_spds_hi,y
                adc #0
                plp
                sbc #0
                sta deb_x_spds_hi,y
                txa
                lsr a
                sub #$20
                php
                clc
                adc deb_y_spds_mid,y
                sta deb_y_spds_mid,y
                lda deb_y_spds_hi,y
                adc #0
                plp
                sbc #0
                sta deb_y_spds_hi,y
                dey
                bpl -
                ;
                rts

move_debris     ; move debris ($8d7b); called by mode_dead, mode5
                ;
                lda gravity
                beq +
                jsr grav_acc_debris
                ;
+               ldy free_spr_index      ; index on OAM page
                ldx #7                  ; debris index (7...0)
                ;
deb_mov_loop    lda deb_x_lo,x          ; X move
                clc
                adc deb_x_spds_lo,x
                sta deb_x_lo,x
                lda deb_x_mid,x
                adc deb_x_spds_mid,x
                sta deb_x_mid,x
                lda deb_x_hi,x
                adc deb_x_spds_hi,x
                sta deb_x_hi,x
                sta oam_page+3,y
                bit ram3
                bmi +
                ;
                ror a                   ; ??
                eor deb_x_spds_hi,x
                bpl +
                jsr sub24
                jmp ++
                ;
+               lda deb_y_lo,x          ; Y move
                clc
                adc deb_y_spds_lo,x
                sta deb_y_lo,x
                lda deb_y_mid,x
                adc deb_y_spds_mid,x
                sta deb_y_mid,x
                lda deb_y_hi,x
                adc deb_y_spds_hi,x
                sta deb_y_hi,x
                bit ram3
                bmi +
                ;
                ror a                   ; ??
                eor deb_y_spds_hi,x
                bpl +
                jsr sub24
                jmp ++
                ;
+               lda deb_y_hi,x
                sta oam_page+0,y
                lda #%00000000
                sta oam_page+2,y
                txa
                ora #$50                ; debris is $50-$57 in PT1
                sta oam_page+1,y
                iny
                iny
                iny
                iny
++              dex
                bpl deb_mov_loop
                ;
                sty free_spr_index
                rts

sub24           ; $8dfc; called by move_debris
                lda #$ff
                sta deb_y_hi,x
                sta deb_y_spds_hi,x
                sta deb_y_spds_mid,x
                sta deb_y_spds_lo,x
                rts

sub25           ; $8e0b; called by sub29
                lda ram28
                beq rts12
                ldy #0
                ldx free_spr_index      ; index on OAM page
-               cpy #8
                bcs +
                lda arr15,y
                sta oam_page+3,x
                lda arr16,y
                sta oam_page+0,x
                lda #0
                sta oam_page+1,x
                sta oam_page+2,x
                iny
                lda #$ff
                db AXS_IMM, $fc         ; X = (A & X) - value without borrow
                jmp -
+               stx free_spr_index
                ;
sub26           ; $8e35
                ldy #6
-               lda arr15,y
                sta arr15+1,y
                lda arr16,y
                sta arr16+1,y
                dey
                bpl -
                copy plr_x+0, arr15
                copy plr_y+0, arr16
rts12           rts

; -----------------------------------------------------------------------------

mode_jump_table ; $8e51; read by use_jump_table; offset = mode variable
                ;
                dw mode0                ;  0
                dw mode_prep_title      ;  1
                dw mode_prep_ingam      ;  2
                dw mode_dead            ;  3
                dw mode4                ;  4
                dw mode5                ;  5
                dw mode6                ;  6
                dw end_screen           ;  7
                dw wait_for_b           ;  8
                dw credits_screen       ;  9
                dw wait_for_a           ; 10
                dw mode_title           ; 11
                dw mode_ingame          ; 12

write_ppu       ; $8e6b; write A to PPU Y*8 times
rept 8          ;
                sta ppu_data
endr            ;
                dey
                bne write_ppu
                rts

warm_boot_chk   ; $8e87; string to check for warm boot
                db %01010101, "SHIP", %10101010

mode0           ; $8e8d; called by mode_jump_table
                ;
                ; copy warm boot check string to RAM
                ldy #5
-               lda warm_boot_chk,y
                sta warm_boot_ram,y
                dey
                bpl -
                ;
                ; if invalid difficulty/gravity, restore defaults
                lda skill
                cmp #SKILL_SECRET
                bcs +
                lda gravity
                cmp #2
                bcc ++
+               lda #0
                sta skill               ; SKILL_NORMAL
                sta gravity             ; off
                ;
++              lda #MODE_PREP_TITLE
                sta mode
                sta next_mode
                jsr sub27
                jmp mode_prep_title

sub27           ; $8eb6; copy default palette to str_buffer
                ldy #(36-1)
-               lda pal_default,y
                sta str_buffer,y
                dey
                bpl -
                stz ram40
                rts

sub28           ; $8ec7; called by mode_prep_title, mode6
                ;
                lda #(STR_ID_BLAKPALS*2+2)  ; black palettes
                jsr print_strings
                bit ppu_status
                ;
                lda #>ppu_at0           ; clear AT0
                sta ppu_addr
                lda #<ppu_at0
                sta ppu_addr
                lda #0
                ldy #8
                jsr write_ppu           ; write A to PPU Y*8 times
                ;
                ldy #>ppu_at2           ; clear AT2
                sty ppu_addr
                ldy #<ppu_at2
                sty ppu_addr
                ldy #8
                jsr write_ppu           ; write A to PPU Y*8 times
                ;
                ; reset player's location, speed & rotation
                lda #0
                ldy #16
-               sta plr_x-1,y
                dey
                bne -
                ;
                ldy #7
                lda #$ef
-               sta arr16,y
                dey
                bpl -
                ;
                lda #0
                sta ram36
                sta ram27
                sta ram37
                lda #$ff
                sta ram21
                sta ram22
                sta arr36+1
                ldy #3
-               sta arr33,y
                dey
                bpl -
                jsr hide_sprites
                ;
                ldy #$0b
-               jsr sub3
                sta stars_y,y
                jsr sub3
                sta stars_x,y
                dey
                bpl -
                jsr draw_stars
                ;
                lda #%00000010
                sta oam_page+2*4+2
                lda #%01000010
                sta oam_page+3*4+2
                lda #%10000010
                sta oam_page+4*4+2
                lda #%11000010
                sta oam_page+5*4+2
                rts

mode_prep_title ; $8f48; called by mode_jump_table, mode0;
                ; executed when entering title screen from boot/respawn/ingame
                ;
                lda ram3
                cmp #1
                beq ++
                ;
                ; if secret difficulty, restore default difficulty & gravity
                lda skill
                cmp #SKILL_SECRET
                bne +
                lda #0
                sta skill               ; SKILL_NORMAL
                sta gravity             ; off
                ;
+               lda #0                  ; disable rendering
                sta ppu_mask_copy2
                sta ppu_mask_copy1
                sta ppu_mask
                jsr sub28
                jsr sub59
                jsr sub47
                ;
                ; print difficulty ("NORMAL"/" HARD "/"EXPERT")
                lda skill
                asl a
                adc #(STR_ID_NORMAL1*2+2)
                jsr print_strings
                ;
                ; print gravity ("OFF"/" ON")
                lda gravity
                asl a
                adc #(STR_ID_OFF1*2+2)
                jsr print_strings
                ;
                lda #0
                sta arr33+3
                sta ram24
                sta sel_press_cnt
                copy #1, arr33+2
                copy #2, arr33+1
                copy #$0b, ram5
                copy #1, ram4
                lda #%00011110          ; enable rendering
                sta ppu_mask_copy2
                lda #%10001000          ; enable NMI
                sta ppu_ctrl_copy2
                sta ppu_ctrl
                ;
++              jsr mode_prep_ingam
                lda mode
                cmp next_mode
                beq +
                copy #$80, ram4
+               rts

mode_title      ; $8fb0
                lda buttons_held
                and #%10000011
                beq +
                sta ram37
+               lda buttons_changed
                beq ++
                ;
                ; if 3 consecutive select presses, start time attack mode
                cmp #%00100000
                bne +
                lda sel_press_cnt
                add #1
                sta sel_press_cnt
                cmp #3
                bne ++
                copy #4, next_mode
                copy #6, ram5
                lda #0
                sta ram4
                sta gravity
                lda #SKILL_SECRET
                sta skill
                lda #4
                jsr snd_eng5
                rts
                ;
+               stz sel_press_cnt
++              stz ram27
                jsr hide_sprites
                lda ram28
                bne ++
                jsr sub38
                lda ram28
                beq +
                jsr sub20
                jsr sub26
                jmp ++
+               jsr sub13
                jmp +
++              jsr sub29
                lda ram28
                bne +
                copy #6, ram5
                copy #4, next_mode
                stz ram4
+               jsr draw_stars
                jsr sub34
                rts

sub29           ; $9022
                ldx #0
                jsr move_plr
                lda plr_y+0
                cmp #$e0
                bcc +
                copy #$f0, plr_y+0
                stz plr_y_spd+0
+               lda ram42
                cmp #$f0
                bne +
                stz ram28
+               jsr set_ship_spr
                jsr sub25
                rts

mode_prep_ingam ; $9047; called by mode_jump_table, mode_prep_title;
                ; executed when entering game proper ("ingame") from
                ; respawn/title
                ;
                lda ram26
                bne +
                copy #9, ram26
+               dec ram26
                bne ++
                ldy ram5
                sty next_mode
                cpy #$0b
                bcc +
                lda buttons_held
                and #%01111111
                sta buttons_held
+               cpy #$0c
                bne ++
                jsr snd_eng4
++              lda ram26
                add #3
                and #%00001100
                asl a
                asl a
                jmp sub30

mode_ingame     ; $9074
                lda buttons_held
                and #%10000011
                beq +
                sta ram37
+               jsr hide_sprites
                lda ram28
                bne ++
                jsr sub33
                lda ram28
                beq +
                jsr sub20
                jsr sub26
                jmp ++
+               lda ram37
                beq +
                jsr inc_time_spent
                jsr dec_time_left
                bcs +
                lda buttons_changed
                and #%00100000
                beq +
                copy #4, next_mode
                copy #6, ram5
                stz ram4
+               jsr sub13
                jmp +++
++              jsr sub29
                lda ram28
                bne +++
                copy #7, ram5
                copy #4, next_mode
+++             jsr draw_hud
                jsr draw_stars
                jsr sub34
                jsr sub40
                stz ram27
                rts

mode_dead       ; $90d7
                jsr hide_sprites
                lda ram26
                bne +
                copy #$6c, ram26
                jsr snd_eng3
                jsr sub22
+               lda oam_page+0*4+1
                cmp #$30
                bcc +
                cmp #$3a
                bcs +
                adc #1
                pha
                jsr set_ship_spr
                pla
                sta oam_page+0*4+1
                lda #%00000001
                sta oam_page+0*4+2
+               jsr draw_hud
                dec ram26
                bne ++
                jsr inc_crash_cnt
                dec lives_left
                bmi +
                copy #1, ram4
+               lda #6
                ldy ram3
                bpl +
                lda #1
+               sta ram5
                copy #5, next_mode
++              jsr draw_stars
                jsr move_debris
                jsr sub40
                rts

mode4           ; $912c; called by mode_jump_table, mode5
                lda ram26
                bne +
                copy #$0d, ram26
                jsr snd_eng3
+               dec ram26
                bne +
                copy ram5, next_mode
                lda #%00000000
                sta ppu_mask_copy2      ; disable rendering
                sta ppu_ctrl_copy2      ; disable NMI on VBlank
+               lda ram26
                cmp #$0d
                bcs +
                add #3
                and #%00001100
                eor #%00001100
                asl a
                asl a
                jsr sub30
+               rts

mode5           ; $9158
                jsr hide_sprites
                jsr mode4
                inc lives_left
                jsr draw_hud
                dec lives_left
                jsr draw_stars
                jmp move_debris         ; ends with RTS

mode6           ; $916b
                jsr sub28
                lda ram3
                bne +
                jsr sub48
                jmp ++
+               jsr sub49
++              copy #$0c, ram5
                copy #MODE_PREP_INGAM, next_mode
                copy #0, ram4
                lda #%00011110          ; enable rendering
                sta ppu_mask_copy2
                lda ppu_ctrl_copy2
                ora #%10001000          ; enable NMI on VBlank
                sta ppu_ctrl_copy2
                sta ppu_ctrl
                rts

end_screen      ; $9195; show end screen

                jsr hide_sprites
                stz scroll_y
                jsr fill_nt0_space

                ; print one of four victory messages
                ;
                lda skill               ; secret difficulty?
                cmp #SKILL_SECRET
                bne +
                lda #(STR_ID_VICTORY3*2+2)
                jmp ++
                ;
+               ldy ram3                ; looks like nonzero=good
                beq +
                lda #(STR_ID_VICTORY2*2+2)
                jmp ++
                ;
+               lda crash_cnt+0         ; no crashes?
                ora crash_cnt+1
                ora crash_cnt+2
                bne +
                lda #(STR_ID_VICTORY4*2+2)
                jmp ++
                ;
+               lda #(STR_ID_VICTORY1*2+2)
++              jsr print_strings

                ; print statistics strings
                lda #(STR_ID_STATS*2+2)
                jsr print_strings

                ; print difficulty ("NORMAL"/"HARD"/"EXPERT"/"SECRET")
                lda skill
                asl a
                adc #(STR_ID_NORMAL2*2+2)
                jsr print_strings

                ; print gravity setting ("OFF"/"ON")
                lda gravity
                asl a
                adc #(STR_ID_OFF2*2+2)
                jsr print_strings

                ; print console type ("NTSC" for NTSC, "PAL" for PAL/Dendy)
                lda region
                asl a
                adc #(STR_ID_NTSC*2+2)
                jsr print_strings

                ; print amount of thrust used
                ;
                lda #>(ppu_nt0+23*32+23)
                sta ppu_addr
                lda #<(ppu_nt0+23*32+23)
                sta ppu_addr
                ldx #$24                ; space in PT0
                ldy #0
                ;
-               lda thrust_used,y
                bne +
                stx ppu_data
                beq ++
+               sta ppu_data
                ldx #$00                ; "0" in PT0
++              iny
                cpy #7
                bne -

                ; print number of ships crashed
                ;
                lda #>(ppu_nt0+25*32+27)
                sta ppu_addr
                lda #<(ppu_nt0+25*32+27)
                sta ppu_addr
                ldx #$24
                ldy #0
                ;
-               lda crash_cnt,y
                bne +
                stx ppu_data
                beq ++
+               sta ppu_data
                ldx #0
++              iny
                cpy #2
                bcc -
                ldx #0
                cpy #3
                bne -

                ; print number of checkpoints skipped
                jsr get_chex_skipd
                lda #>(ppu_nt0+27*32+25)
                sta ppu_addr
                lda #<(ppu_nt0+27*32+25)
                sta ppu_addr
                copy ptr1+1, ppu_data
                copy ptr1+0, ppu_data

                ; print amount of time spent (HH:MM:SS.FF)
                ;
                lda #>(ppu_nt0+21*32+19)
                sta ppu_addr
                lda #<(ppu_nt0+21*32+19)
                sta ppu_addr
                ;
                ldx #0
-               lda time_spent,x
                jsr to_decimal          ; tens -> Y, ones -> A
                sty ppu_data
                sta ppu_data
                lda time_separs,x
                sta ppu_data
                inx
                cpx #4
                bcc -

                copy #8, ram5
                copy #MODE_PREP_INGAM, next_mode
                copy #0, ram4
                lda #%00011110          ; enable rendering
                sta ppu_mask_copy2
                lda #%10001000          ; enable NMI, use PT1 for sprites
                sta ppu_ctrl_copy2
                sta ppu_ctrl
                rts

time_separs     hex dc dc e1 24         ; time separators ("::. ", $9281)

credits_screen  ; $9285; show credits screen
                ;
                jsr fill_nt0_space
                ;
                lda #(STR_ID_CREDITS*2+2)
                jsr print_strings
                ;
                copy #$0a, ram5
                copy #MODE_PREP_INGAM, next_mode
                copy #0, ram4
                lda #%00011110          ; enable rendering
                sta ppu_mask_copy2
                lda #%10001000          ; enable NMI, PT1 for sprites
                sta ppu_ctrl_copy2
                sta ppu_ctrl
                ;
wait_for_b      ; $92a4; wait for button B
                bit buttons_changed
                bvc wait_for_a
                copy #9, ram5
                copy #4, next_mode
                rts
                ;
wait_for_a      ; $92b1; wait for button A
                bit buttons_changed
                bpl +
                copy #1, ram5
                copy #4, next_mode
                copy #0, ram4
+               rts

sub30           ; $92c2; called by mode_prep_ingam, mode4
                ;
                sta temp1
                ldy ram13
                lda #$3f
                sta arr5+0,y
                lda #$00
                sta arr5+1,y
                lda #$20
                sta arr5+2,y
                lda #$ff
                sta arr7,y
                tya
                add #$1f
                tay
                ldx #$1f
                ;
-               lda str_buffer+3,x
                and #%00001111
                cmp #$0d
                bcs +
                lda str_buffer+3,x
                sub temp1
                bcs ++
+               lda #$0f
++              sta arr6,y
                dey
                dex
                bpl -
                ;
                tya
                add #$20
                sta ram13
                rts

sub31           ; $9302; called by sub33
                ;
                lda arr33,y
                tay
                cmp #$0c
                bne +
                copy #1, ram28
                rts
                ;
+               sty ram40
                inc ram40
                copy #$14, ram41
                sty temp1
                jsr mark_chkp_touch
                jsr time_extend
                ldy temp1
                ;
                ; add lives and limit to maximum, according to difficulty
                ldx skill
                lda lives_left
                clc
                adc lives_to_add,x
                cmp max_lives,x
                bcc +
                lda max_lives,x
+               sta lives_left
                ;
                copy ram17, ram18
                ;
                lda checkpts_x,y
                asl a
                asl a
                asl a
                add #4
                sta arr36+2
                ;
                lda checkpts_y,y
                sub #6
                sta arr36+3
                lda checkpts_unkn,y
                sbc #0
                sta arr36+4
                ;
                copy ptr5+0, ptr6+0
                copy ptr5+1, ptr6+1
                lda checkpts_y,y
                sub ram19
                cmp #6
                beq +
                tay
                ldx #2
                bcs cod3
                ;
-               jsr sub58
                iny
                cpy #6
                bcc -
                ;
+               rts
                ;
cod3            jsr sub57
                dey
                cpy #7
                bcs cod3
                rts

                ; $9380
lives_to_add    db 2, 1, 0, 0           ; normal/hard/expert/secret
max_lives       db 9, 3, 0, 0           ; normal/hard/expert/secret

sub32           ; $9388; called by sub33
                ;
                lda checkpts_y,x
                sub ram19
                sta temp3
                asl a
                asl a
                asl a
                asl a
                sta temp1
                lda ram6
                and #%00001111
                ora temp1
                eor #%11111111
                sub #$0e
                sta temp1
                lda checkpts_x,x
                asl a
                asl a
                asl a
                add #2
                sta temp2
                rts

sub33           ; $93af; called by mode_ingame
                ;
                ldy ram22
                bmi +
                lda ram36
                beq +
                stz ram36
                jsr sub31
                ldy ram22
                lda #$ff
                sta arr33,y
+               copy #$ff, ram22
                ldy #3
                ;
-               lda arr33,y
                cmp #$ff
                beq cod4
                tax
                jsr sub32
                lda temp3
                cmp #$ff
                beq +
                cmp #$11
                bcs ++
+               lda temp1
                sub #8
                sub plr_y+0
                bcs cod4
                adc #$13
                bcc cod4
                lda temp2
                sub #8
                sub plr_x+0
                bcs cod4
                adc #$13
                bcc cod4
                sty ram22
                lda #1
                cpx #$0c
                bne +
                lda #3
+               sta ram23
                lda temp1
                sub #2
                sta arr36
                lda temp2
                sub #2
                jsr sub35
cod4            dey
                bpl -
                rts
                ;
++              lda #$ff
                sta arr33,y
                jmp cod4

sub34           ; $9424; called by mode_title, mode_ingame
                ;
                lda arr36
                bit plr_y_spd+0
                bpl +
                add ram27
                jmp ++
+               sub ram27
++              sta arr36
                bit arr36+1
                bmi rts13
                sta oam_page+2*4+0
                sta oam_page+3*4+0
                add #8
                sta oam_page+4*4+0
                sta oam_page+5*4+0
                lda arr36+1
                dec arr36+1
-               ora #%11000000
                sta oam_page+2*4+1
                sta oam_page+3*4+1
                sta oam_page+4*4+1
                sta oam_page+5*4+1
rts13           rts
                ;
sub35           ; $9460; called by sub33, sub38
                ;
                sta oam_page+2*4+3
                sta oam_page+4*4+3
                add #8
                sta oam_page+3*4+3
                sta oam_page+5*4+3
                lda #5
                jmp -

mark_chkp_touch ; $9474; mark checkpoint as touched; called by sub31
                ;
                ldy ram22
                lda arr33,y
                and #%00000111
                tax
                lda arr33,y
                lsr a
                lsr a
                lsr a
                tay
                lda chex_touched,y
                ora powers_of_2,x       ; 1<<x
                sta chex_touched,y
                rts

was_chkp_touchd ; $948d; has checkpoint number Y been touched?
                ; Z flag clear if yes; called by sub45, sub46
                ;
                tya
                and #%00000111
                tax
                tya
                lsr a
                lsr a
                lsr a
                tay
                lda chex_touched,y
                and powers_of_2,x       ; 1<<x
                rts

powers_of_2     ; $949d
                db %00000001, %00000010, %00000100, %00001000
                db %00010000, %00100000, %01000000, %10000000

sub38           ; $94a5; called by mode_title
                ;
                ldy ram22
                bmi +
                lda ram24
                bpl +
                copy #1, ram24
                jsr sub39
+               copy #$ff, ram22
                ;
                ldy #3
-               lda arr33,y
                cmp #$ff
                beq +
                tax
                lda dat16,x
                sub #8
                sub plr_y+0
                bcs +
                adc #$13
                bcc +
                lda dat15,x
                sub #8
                sub plr_x+0
                bcs +
                adc #$13
                bcc +
                ;
                sty ram22
                lda dat17,x
                sta ram23
                lda dat16,x
                sub #2
                sta arr36
                lda dat15,x
                sub #2
                jsr sub35
+               dey
                bpl -
                ;
                lda ram36
                bne +
                sta ram24
+               stz ram36
                rts

dat15           hex 3e b6 7a            ; $9507
dat16           hex 99 99 69
dat17           hex 01 01 03

sub39           ; $9510; called by sub38
                ;
                ldy ram22
                ldx arr33,y
                bne ++
                lda skill
                add #1
                cmp #SKILL_SECRET
                bcc +
                lda #SKILL_NORMAL
+               sta skill
                asl a
                adc #(STR_ID_NORMAL1*2+2)  ; "NORMAL"/" HARD "/"EXPERT"
                sta str_to_print
                rts
                ;
++              dex
                bne +
                lda gravity
                eor #%00000001
                sta gravity
                asl a
                adc #(STR_ID_OFF1*2+2)  ; "OFF"/" ON"
                sta str_to_print
                rts
+               copy #1, ram28
                rts

sub40           ; $953e; called by mode_ingame, mode_dead
                ;
                lda ram41
                beq rts14
                dec ram41
                and #%00000011
                bne rts14
                lda str_buffer+4
                add #1
                cmp #$0d
                bcc +
                lda #1
+               sta str_buffer+4
                ora #%00010000
                sta str_buffer+5
                eor #%00110000
                sta str_buffer+6
                lda #(STR_ID_BUFFER*2+2)
                sta str_to_print
rts14           rts

                ; unaccessed ($9568)
                copy #4, ram41
                rts

; $956e; lvl_blks_tl, lvl_blks_tr, lvl_blks_bl, lvl_blks_br are 192 bytes each,
; indexed by level data bytes and read by sub43, sub44
; tiles used: 24-34, 39-66, 6b-72, 75, 77-78, 7b-7e, 80, 87, 8a-8b, 8f

lvl_blks_tl     ; top left tile of each level data block
                hex 25 24 24 24 2a 24 2c 2d 24 2b 2b 24 24 24 28 28
                hex 24 2e 24 26 26 24 24 24 2f 2c 2f 28 28 30 6b 30
                hex 2f 27 27 26 2f 24 2c 29 2a 24 29 24 29 24 24 24
                hex 24 65 24 24 25 66 2f 2b 2e 24 66 2e 66 27 25 24
                hex 2b 2e 24 30 24 28 2b 2e 24 27 24 24 24 2d 24 24
                hex 2d 24 2f 7d 7e 24 2f 2b 24 24 78 7c 66 24 7c 2b
                hex 30 24 26 24 25 24 2e 24 29 2d 30 7b 24 29 27 24
                hex 24 5c 24 5f 24 24 24 34 24 24 62 25 24 57 24 62
                hex 32 33 3d 24 56 61 24 4b 24 58 55 28 27 4c 5b 5d
                hex 24 46 42 46 25 24 80 39 80 24 24 24 25 80 25 24
                hex 2d 2d 28 24 28 24 24 2c 24 31 24 26 24 2f 53 24
                hex 24 4a 2c 27 72 24 6d 29 24 24 24 24 8a 8a 8a 8a

lvl_blks_tr     ; top right tile of each level data block
                hex 24 24 26 29 24 2b 24 2e 24 2c 2c 24 25 2d 28 30
                hex 25 24 24 24 24 2f 29 6d 66 25 28 28 28 24 24 25
                hex 66 27 7e 25 30 71 24 2a 2b 24 2a 24 27 24 24 26
                hex 2d 2e 25 2f 24 2a 28 65 26 2f 2a 24 27 2c 24 24
                hex 6e 24 2f 24 26 2e 65 24 2f 65 25 24 24 2e 24 26
                hex 30 24 30 27 24 6f 66 2a 24 77 28 24 2a 2d 24 65
                hex 24 24 25 26 24 2f 2f 24 2c 28 2d 7c 7d 27 2c 24
                hex 5b 5d 5e 60 25 24 33 24 26 61 32 24 24 58 24 28
                hex 24 27 3e 55 24 62 24 4c 57 24 56 32 4b 24 5c 24
                hex 45 41 24 25 24 24 24 3a 24 80 80 24 24 26 80 24
                hex 28 28 30 2d 30 24 24 24 29 28 24 24 25 2e 54 24
                hex 49 27 29 34 24 24 24 27 24 2b 2b 75 8a 8a 8a 8f

lvl_blks_bl     ; bottom left tile of each level data block
                hex 25 24 24 29 24 24 2b 24 2e 24 24 2c 24 2c 24 24
                hex 24 2d 24 30 26 2f 24 24 66 2b 66 27 27 24 24 24
                hex 6c 24 24 26 30 2f 26 25 24 24 2a 29 2a 28 27 24
                hex 24 2b 27 24 2d 25 26 24 65 2f 2a 65 2a 24 65 29
                hex 24 2d 28 24 2f 24 24 25 24 24 2c 2f 28 24 8b 28
                hex 24 2e 2b 24 24 24 30 24 7b 24 2b 25 65 24 7e 2f
                hex 27 27 30 24 7e 24 65 7b 2a 24 24 26 24 25 24 24
                hex 24 61 28 64 24 58 24 24 59 24 24 2d 7c 5b 5d 24
                hex 25 24 3f 24 26 24 32 50 52 5c 24 24 24 51 24 62
                hex 28 48 44 48 57 31 24 3b 28 28 24 24 25 24 25 24
                hex 29 27 27 27 27 31 28 33 27 26 2c 33 27 30 25 2f
                hex 4d 4f 2b 24 2d 71 24 6e 80 80 24 80 24 24 80 24

lvl_blks_br     ; bottom right tile of each level data block
                hex 24 24 26 2a 24 24 2c 2d 24 26 2b 24 2d 24 24 24
                hex 25 2e 2f 24 24 30 25 24 2a 6e 27 27 2c 24 24 25
                hex 2a 24 24 25 24 72 24 24 24 29 24 2c 24 28 27 2b
                hex 24 65 65 26 2e 24 24 2b 30 66 24 2e 24 2b 2e 27
                hex 6d 28 30 29 30 25 26 24 7d 2b 25 28 2e 87 24 30
                hex 24 2f 2c 24 24 70 25 24 28 24 2c 24 2e 29 24 66
                hex 27 2c 25 7d 24 2b 30 7c 2b 24 24 25 24 24 26 7b
                hex 24 62 63 24 57 24 24 24 5a 24 25 28 24 5c 24 24
                hex 24 24 40 24 24 24 24 51 5b 5d 26 25 50 52 61 28
                hex 47 43 28 25 58 32 24 3c 28 28 24 80 80 26 24 31
                hex 27 27 27 27 2c 28 32 27 34 24 29 27 34 2d 24 2e
                hex 4e 24 2a 24 28 24 24 24 24 24 80 24 24 80 24 80

level_data      ; what main game world looks like; also affects where
                ; collisions occur ($986e)
                ; read by sub43 via ptr4 and by sub44 via ptr5
                ; length: 2224 (= 139*16; ~10 screens vertically)
                ; contains values 0-191
                ; each byte denotes a block (2*2 tiles) and is an index to
                ; lvl_blks_tl etc.
                ; common values (20 occurrences or more):
                ;     00-04, 0e, 10, 14, 21, 29, 2a, 2d, 9b
                ; checkpoint icons are not here
                ;
                hex 00 01 01 01 01 01 01 01 01 01 01 01 01 01 01 02
                hex 00 01 01 01 01 01 01 01 01 01 01 01 01 01 01 02
                hex 00 01 01 01 01 01 01 01 01 01 01 01 01 01 01 02
                hex 03 04 01 01 01 01 01 01 01 01 01 01 01 01 05 06
                hex 01 03 04 01 01 01 01 01 01 01 01 01 01 05 06 01
                hex 01 01 03 04 01 01 01 01 01 01 01 01 05 06 01 01
                hex 01 01 01 03 04 01 01 01 01 01 01 05 06 01 01 01
                hex 01 01 01 01 03 04 01 01 01 01 05 06 01 01 01 01
                hex 01 01 01 01 01 00 01 01 01 01 02 01 01 01 01 01
                hex 01 01 01 01 01 00 01 01 01 01 02 01 01 01 01 01
                hex 01 01 01 01 07 08 01 01 01 01 02 01 01 01 01 01
                hex 01 01 01 07 08 01 01 01 01 01 02 01 01 01 01 01
                hex 01 01 07 08 01 01 01 01 01 01 09 01 01 01 01 01
                hex 01 07 08 01 01 01 01 01 01 0a 0b 01 01 01 01 01
                hex 0c 08 01 01 01 01 01 01 0a 0d 0e 0e 0e 0e 0f 01
                hex 10 01 01 01 01 01 01 0a 0d 11 01 01 01 01 12 13
                hex 10 01 01 01 01 01 0a 0d 11 01 01 01 01 01 01 14
                hex 10 01 01 01 01 01 15 11 01 01 01 01 01 01 01 14
                hex 16 04 01 01 01 01 01 01 01 01 01 17 01 01 01 14
                hex 0c 18 04 01 01 01 01 01 01 01 05 19 01 01 01 14
                hex 10 12 18 04 01 01 01 01 01 05 06 10 01 01 01 14
                hex 10 01 12 18 04 01 01 01 05 06 01 10 01 01 01 14
                hex 10 01 01 12 1a 1b 1b 1b 1c 1d 01 10 01 01 01 14
                hex 10 01 01 01 01 01 01 01 01 15 1d 10 01 01 01 14
                hex 10 01 01 1e 01 01 01 01 01 01 15 1f 01 01 01 14
                hex 10 01 01 20 21 21 21 22 01 01 01 23 01 01 01 14
                hex 10 01 01 12 24 01 01 10 01 01 01 23 01 01 01 14
                hex 16 04 01 01 12 24 01 10 01 01 01 23 01 01 01 14
                hex 01 03 04 01 01 12 13 16 04 01 01 25 01 01 01 14
                hex 01 01 03 04 01 01 14 01 03 04 01 01 01 01 01 14
                hex 01 01 01 00 01 01 14 01 01 03 04 01 01 01 05 26
                hex 01 01 01 00 01 01 15 1d 01 01 03 04 01 05 06 01
                hex 01 01 01 27 01 01 01 15 0e 0e 0f 03 28 06 01 01
                hex 01 01 01 29 2a 01 01 01 01 01 12 24 2b 01 01 01
                hex 01 01 01 01 29 2a 01 01 01 01 01 12 24 01 01 01
                hex 01 01 01 01 01 29 2c 21 21 04 01 01 12 24 01 01
                hex 01 01 07 2d 2d 2d 2d 2d 2d 18 04 01 01 12 24 01
                hex 01 07 08 01 01 01 01 01 01 12 18 04 01 01 12 24
                hex 07 08 01 01 01 01 01 01 01 01 12 18 04 01 01 02
                hex 00 01 01 01 0a 2e 2e 2a 01 01 01 12 18 04 01 02
                hex 00 01 01 2f 0b 01 30 11 01 01 01 05 31 08 01 02
                hex 00 01 01 02 01 30 11 01 01 01 0a 32 08 01 01 02
                hex 00 01 01 33 1d 34 01 01 01 0a 0d 11 01 01 01 09
                hex 00 01 01 01 15 35 01 01 01 36 11 01 01 01 37 38
                hex 03 04 01 01 01 39 3a 01 01 01 01 01 01 37 3b 02
                hex 01 03 04 01 01 01 39 3a 01 01 01 01 37 3b 01 02
                hex 01 01 03 04 01 01 01 39 3a 01 01 37 3b 01 01 02
                hex 01 01 01 03 04 01 01 01 39 3c 3d 3e 01 01 01 02
                hex 01 01 01 01 3f 2a 01 01 01 15 1d 00 01 40 01 02
                hex 30 41 2d 2d 42 43 2a 01 01 01 44 00 01 23 01 02
                hex 34 01 01 01 01 15 45 01 01 01 46 47 01 23 01 02
                hex 00 01 01 01 01 01 01 01 01 37 3b 01 01 23 01 02
                hex 00 01 48 3a 01 01 01 01 37 3b 01 01 37 3b 01 02
                hex 27 01 01 39 3a 01 01 37 3b 01 01 37 3b 01 01 09
                hex 29 2a 01 01 39 3c 49 3b 01 01 0a 4a 01 01 0a 0b
                hex 01 29 2a 01 01 4b 4c 01 01 0a 0b 10 01 01 15 1d
                hex 01 01 29 2a 01 01 01 01 0a 0b 01 29 2a 01 01 44
                hex 01 01 01 29 2c 21 21 3d 0b 01 01 01 4d 4e 01 02
                hex 0c 2d 2d 2d 2d 2d 2d 4f 01 50 01 0c 08 01 05 06
                hex 10 01 01 01 01 01 01 02 07 51 24 10 01 01 52 01
                hex 10 01 01 53 21 54 01 55 08 01 12 56 04 01 12 24
                hex 10 01 01 14 01 00 01 01 01 57 01 12 18 04 01 02
                hex 10 01 01 58 42 35 01 01 37 3b 01 05 06 00 01 02
                hex 29 2a 01 01 01 39 3a 37 3b 01 59 5a 0e 5b 01 02
                hex 01 29 2a 01 01 01 39 5c 01 01 01 01 01 01 01 02
                hex 01 01 29 2a 01 01 01 39 3a 01 01 01 01 01 01 02
                hex 01 01 01 5d 1b 5e 01 01 5f 60 2e 2e 2e 2e 2e 61
                hex 01 01 30 11 01 01 01 37 3b 15 1d 01 01 01 01 01
                hex 01 30 11 01 01 01 37 3b 01 01 15 1d 01 01 01 01
                hex 30 11 01 01 53 49 3b 01 01 01 01 15 1d 01 01 01
                hex 29 2a 01 01 58 62 01 01 63 64 01 65 66 1d 01 01
                hex 01 29 2a 01 01 67 01 01 09 27 01 01 01 15 1d 01
                hex 01 01 29 2a 01 01 01 0a 0b 29 2a 01 01 01 15 1d
                hex 01 01 01 29 2a 01 0a 0b 01 01 29 2e 64 01 01 44
                hex 01 01 01 01 29 68 0b 01 01 01 01 01 00 01 01 02
                hex 69 0e 0e 0e 0e 6a 0e 0e 0e 0e 6a 0e 5b 01 01 02
                hex 00 01 01 01 01 6b 01 01 01 01 6b 01 01 01 01 02
                hex 00 01 6c 54 01 01 01 6c 54 01 01 01 01 01 01 02
                hex 00 01 02 6d 21 21 21 6e 6d 21 21 21 21 21 21 6e
                hex 00 01 6f 2d 2d 2d 4f 01 01 01 70 71 2d 2d 72 73
                hex 00 01 01 01 01 01 02 01 01 01 74 75 76 77 01 78
                hex 6d 21 21 21 54 01 02 01 01 79 7a 01 02 00 01 02
                hex 7b 2d 2d 2d 7c 01 02 01 01 7d 7e 01 02 00 01 02
                hex 00 01 01 01 01 01 02 79 7f 80 01 81 82 00 01 02
                hex 00 01 6c 21 21 21 6e 7d 7e 01 83 84 85 80 01 02
                hex 00 01 6f 2d 2d 2d 2d 86 01 81 87 88 89 01 01 8a
                hex 00 01 01 01 01 01 01 01 83 84 85 8b 01 76 8c 8d
                hex 6d 21 21 21 21 21 21 21 87 88 89 01 01 8a 01 01
                hex 8e 8f 2d 90 91 92 2d 2d 90 93 01 76 8c 8d 01 01
                hex 94 01 01 01 95 01 76 77 01 95 01 8a 01 01 01 01
                hex 00 96 01 76 21 21 82 97 21 21 8c 8d 01 01 01 01
                hex 00 01 01 02 7b 98 2d 2d 2d 2d 2d 99 2d 2d 2d 4f
                hex 00 01 9a 02 00 01 01 9b 01 01 96 01 9a 01 01 02
                hex 00 01 01 02 9c 01 01 96 9b 01 01 96 76 77 01 02
                hex 00 9a 01 02 00 9b 01 01 96 01 01 01 9d 00 01 02
                hex 00 01 01 02 00 96 01 01 01 96 9b 01 02 9e 01 02
                hex 00 01 9a 02 00 01 96 9b 01 01 01 9b 02 00 01 02
                hex 00 01 01 02 9c 01 01 01 9b 01 01 96 02 00 01 02
                hex 00 96 01 02 00 9b 01 01 96 9b 01 01 9d 00 9a 02
                hex 00 01 01 9f 86 96 9b 01 01 01 9b 01 02 00 01 02
                hex 00 01 01 01 01 01 01 9b 01 01 96 9b 02 00 01 02
                hex 00 01 01 01 9b 01 01 96 9b 01 01 96 02 00 96 02
                hex a0 1b 60 2e a1 1b 1b 1b a2 2e a3 1b a4 00 01 02
                hex 00 01 a5 2d 86 01 01 01 9f 2d a6 01 02 00 01 02
                hex 00 76 21 21 21 a7 2e a8 21 21 21 77 02 00 01 9d
                hex 00 9f 2d 13 01 01 01 01 01 0c 2d 86 02 00 01 02
                hex 27 01 01 14 01 01 01 01 01 10 01 01 09 00 01 02
                hex 29 2a 01 a9 0e 0e 6a 0e 0e 8b 01 0a 0b 00 96 02
                hex 01 29 2a 01 01 01 23 01 01 01 0a 0b 01 00 01 02
                hex 01 01 29 2a 01 0a aa 2a 01 0a 0b 01 01 00 01 02
                hex 01 01 30 11 01 15 6a 11 01 15 1d 01 01 00 9a 02
                hex 01 30 11 01 01 01 23 01 01 01 15 1d 01 00 01 02
                hex 30 11 01 ab 2e 2e aa 2e 2e ac 01 15 1d 00 01 02
                hex 34 01 01 14 01 01 01 01 01 10 01 01 4b 7c 01 02
                hex 00 01 01 14 01 01 01 01 01 16 21 21 21 21 21 6e
                hex 00 01 01 a5 2d ad 2d 42 6a 41 2d 2d 2d 2d 72 73
                hex ae 01 01 01 01 01 01 01 af 01 01 57 01 01 01 78
                hex b0 b1 21 21 21 b2 21 21 21 21 3d aa 2c b3 01 02
                hex 8e 8f 4f 01 07 2d 2d 2d 2d 2d 4f 01 07 a6 01 02
                hex 94 01 6f 2d 08 01 6c 21 04 01 6f 2d 08 01 01 8a
                hex 00 01 81 21 21 21 6e 01 03 21 21 21 21 21 8c 8d
                hex 00 01 a5 42 b4 2d 2d 42 b4 2d 2d 42 b4 2d 72 73
                hex ae 01 01 01 b5 01 b6 01 b5 01 b6 01 b5 01 01 78
                hex b0 b1 21 21 21 3d b7 21 21 3d b7 21 21 b3 01 02
                hex 7b 2d ad 2d 2d 2d ad 2d 2d 2d ad 2d 2d a6 01 02
                hex 00 b8 01 9b 01 b8 01 9b 01 b8 01 9b 01 b8 01 02
                hex 03 04 b8 01 9b 01 b8 01 9b 01 b8 01 9b 01 b9 06
                hex 01 03 04 b8 01 9b 01 b8 01 9b 01 b8 01 ba 06 01
                hex 01 01 03 04 b8 01 9b 01 b8 01 9b 01 b9 06 01 01
                hex 01 01 01 03 04 bb bc bd bc be bc bf 06 01 01 01
                hex 01 01 01 01 03 04 01 01 01 01 05 06 01 01 01 01
                hex 01 01 01 01 01 03 04 01 01 05 06 01 01 01 01 01
                hex 01 01 01 01 01 01 03 04 05 06 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 03 06 01 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01

checkpts_y      ; Y positions of checkpoints ($a11e);
                ; read by sub31, sub32, sub45, sub46
                hex 1a 24 33 3b 3e 4a 52 56
                hex 64 71 74 7a 83
                hex ff

checkpts_unkn   ; probably checkpoint-related ($a12c);
                ; read by sub31, sub45, sub46
                hex 00 00 00 00 00 00 00 00
                hex 00 00 00 00 00 ff

checkpts_x      ; X positions of checkpoints ($a13a);
                ; read by sub31, sub32, sub45, sub46
                hex 12 17 08 03 1c 1b 1c 02
                hex 03 1c 03 1b 0f 00

sub41           ; $a148; sub41/sub42/sub43 called by sub14, sub51, sub52
                ;
                lda ptr4+1
                cmp #$a1
                bne +
                lda ptr4+0
                cmp #$1e
                bne +
                clc
                rts
+               ldx #0
                jsr sub57
                ;
sub42           ; $a15b
                inc ram19
                bne sub43
                inc ram20
                ;
sub43           ; $a161
                ldy #0
                jsr sub55
                copy arr1, ram11
                copy arr2, ram12
                stz ptr1+0
                ;
-               ldy #0
                lda (ptr4),y            ; block from level_data -> X
                inc ptr4+0
                bne +
                inc ptr4+1
+               tax
                ;
                ldy ptr1+0              ; Y = target index
                lda lvl_blks_tl,x       ; read 2*2 tiles of block
                sta tile_row_top+0,y
                lda lvl_blks_tr,x
                sta tile_row_top+1,y
                lda lvl_blks_bl,x
                sta tile_row_btm+0,y
                lda lvl_blks_br,x
                sta tile_row_btm+1,y
                iny
                iny
                sty ptr1+0
                cpy #32
                bne -
                ;
                lda ram19
                add #$0f
                sta ptr1+0
                lda ram20
                adc #0
                sta ptr1+1
                jsr sub45
                copy #1, nmi_flag
                sec
                rts

sub44           ; $a1b5; called by sub14
                ;
                ldy #0
                jsr sub56
                lda ptr4+0
                sub #$10
                sta ptr4+0
                bcs +
                dec ptr4+1
+               lda ram20
                bmi +
                ora ram19
                bne ++
+               lda #$ff
                sta ram19
                sta ram20
                ldx #0
                jsr sub58
                clc
                rts
                ;
++              lda ram19
                sub #1
                sta ram19
                bcs +
                dec ram20
+               copy arr1, ram11
                copy arr2, ram12
                ldy #2
                jsr sub56
                lda ram11
                eor #%00001000
                sta ram11
                copy #$1e, ptr1+0
                ;
-               lda ptr5+0
                sub #1
                sta ptr5+0
                bcs +
                dec ptr5+1
+               ldy #0
                lda (ptr5),y            ; read level_data
                tax
                ldy ptr1+0
                lda lvl_blks_tl,x
                sta tile_row_top+0,y
                lda lvl_blks_tr,x
                sta tile_row_top+1,y
                lda lvl_blks_bl,x
                sta tile_row_btm+0,y
                lda lvl_blks_br,x
                sta tile_row_btm+1,y
                dey
                dey
                sty ptr1+0
                bpl -
                lda ram19
                sub #1
                sta ptr1+0
                lda ram20
                sbc #0
                sta ptr1+1
                jsr sub46
                copy #1, nmi_flag
                sec
                rts

sub45           ; $a242; called by sub41, sub42, sub43
                ;
                ldx ram21
-               inx
                lda checkpts_unkn,x
                cmp ptr1+1
                bcc -
                bne ++
                lda checkpts_y,x
                cmp ptr1+0
                bcc -
                bne ++
                stx ram21
                ldy ram21
                jsr was_chkp_touchd
                bne rts15
                ;
                ldx ram21
                ldy #3
-               lda arr33,y
                cmp #$ff
                beq +
                dey
                bpl -
                bmi rts15
+               txa
                sta arr33,y
                lda ram11
                sta arr34,y
                lda checkpts_x,x
                tax
                ora ram12
                sta arr35,y
                lda arr33,y
                cmp #$0c
                beq +
                lda #$f0
                sta tile_row_top+0,x
                lda #$f1
                sta tile_row_top+1,x
                lda #$f2
                sta tile_row_btm+0,x
                lda #$f3
                sta tile_row_btm+1,x
rts15           rts
                ;
++              dex
                stx ram21
                rts
                ;
+               lda #$ec
                sta tile_row_top+0,x
                lda #$ed
                sta tile_row_top+1,x
                lda #$ee
                sta tile_row_btm+0,x
                lda #$ef
                sta tile_row_btm+1,x
                rts

sub46           ; $a2b7; called by sub44
                ;
                ldx ram21
                inx
-               dex
                bmi ++
                lda checkpts_unkn,x
                cmp ptr1+1
                beq +
                bcs -
                bne ++
+               lda checkpts_y,x
                cmp ptr1+0
                beq +
                bcs -
                bne ++
+               stx ram21
                ldy ram21
                jsr was_chkp_touchd
                bne rts16
                ;
                ldx ram21
                ldy #3
-               lda arr33,y
                cmp #$ff
                beq +
                dey
                bpl -
                bmi rts16
+               txa
                sta arr33,y
                lda ram11
                sta arr34,y
                lda checkpts_x,x
                tax
                ora ram12
                sta arr35,y
                lda #$f0
                sta tile_row_top+0,x
                lda #$f1
                sta tile_row_top+1,x
                lda #$f2
                sta tile_row_btm+0,x
                lda #$f3
                sta tile_row_btm+1,x
rts16           rts
++              stx ram21
                rts

sub47           ; $a316; called by mode_prep_title
                ;
                lda #0
                sta ram6
                sta scroll_y
                sta lives_left
                lda #(256-4)
                sta scroll_x
                copy #$c0, ram16
                jsr fill_nt0_space
                ;
                lda #(STR_ID_TITLE*2+2)
                jsr print_strings
                ;
                copy #$7c, plr_x+0      ; plr start pos in title screen
                copy #$80, plr_x+1
                copy #$8f, plr_y+0
                copy #$80, plr_y+1
                jsr set_ship_spr
                rts

sub48           ; $a342; called by mode6
                ;
                lda #0
                jsr snd_eng2
                jsr snd_eng4
                jsr sub27
                lda #0
                sta ram6
                sta scroll_y
                sta lives_left
                sta ram17
                lda #0
                ldy #1
-               sta chex_touched,y
                dey
                bpl -
                ;
                ldy #17
                lda #0
-               sta thrust_used,y
                dey
                bpl -
                ;
                lda #<level_data
                sta ptr5+0
                lda #>level_data
                sta ptr5+1
                lda #$ff
                sta ram19
                sta ram20
                jsr sub50
                copy #$0f, temp6
                jsr sub51
                ldx #0
                jsr sub58
                jsr sub58
                copy #$40, ram16
                jsr time_extend
                copy #$7c, plr_x+0      ; set plr start pos in main game
                copy #$80, plr_x+1
                copy #$bf, plr_y+0
                copy #$80, plr_y+1
                jsr set_ship_spr
                jsr draw_hud
                rts

sub49           ; $a3a9; called by mode6
                ;
                lda #0
                jsr snd_eng2
                jsr snd_eng4
                lda #$d0
                sta ram6
                sta scroll_y
                lda ppu_ctrl_copy2
                ora #%00000010          ; use NT2
                sta ppu_ctrl_copy2
                copy ram18, ram17
                copy ptr6+0, ptr5+0
                copy ptr6+1, ptr5+1
                lda arr36+3
                sub #$11
                sta ram19
                lda arr36+4
                sbc #0
                sta ram20
                jsr sub50
                copy #$11, temp6
                jsr sub52
                stz ram16
                copy arr36+2, plr_x+0
                copy #$80, plr_x+1
                copy #$93, plr_y+0
                copy #$80, plr_y+1
                jsr set_ship_spr
                jsr draw_hud
                rts

sub50           ; $a3fe; called by sub48, sub49
                ;
                stz scroll_x
                copy ptr5+0, ptr4+0
                copy ptr5+1, ptr4+1
                stz nmi_flag
                copy #>ppu_at0, arr1
                copy #<ppu_at0, arr2
                lda ppu_ctrl_copy1
                sta ppu_ctrl
                rts

sub51           ; $a41c; called by sub48
-               jsr sub43
                jsr sub1
                dec temp6
                bne -
                rts

sub52           ; $a427; called by sub49
-               jsr sub42
                jsr sub1
                dec temp6
                bne -
                rts

sub53           ; $a432; called by sub14
                ;
                lda ram6
                sub ram27
                sta scroll_y
                bcs +
                sbc #$0f
                sta scroll_y
                lda ppu_ctrl_copy1
                eor #%00000010          ; flip between NT0/NT2
                sta ppu_ctrl_copy2
+               rts

sub54           ; $a446; called by sub14
                ;
                lda ram6
                add ram27
                sta scroll_y
                cmp #$f0
                bcc +
                adc #$0f
                sta scroll_y
                lda ppu_ctrl_copy1
                eor #%00000010          ; flip between NT0/NT2
                sta ppu_ctrl_copy2
+               rts

sub55           ; $a45c; called by sub41, sub42, sub43
                ;
                lda arr2,y
                sub #$40
                sta arr2,y
                lda arr1,y
                sbc #0
                ora #%00100000
                and #%00101011
                sta arr1,y
                and #%00000011
                cmp #3
                bcc +
                lda arr2,y
                cmp #$c0
                bcc +
                lda #$80
                sta arr2,y
+               rts

sub56           ; $a484; called by sub44
                ;
                lda arr2,y
                add #$40
                sta arr2,y
                lda arr1,y
                adc #0
                sta arr1,y
                and #%00000011
                cmp #3
                bne +
                lda arr2,y
                cmp #$c0
                bcc +
                lda #0
                sta arr2,y
                lda arr1,y
                eor #%00001011
                sta arr1,y
+               rts

sub57           ; $a4b0; called by sub31, sub41
                lda ptr5,x
                add #16
                sta ptr5,x
                bcc +
                inc ptr5+1,x
+               rts

sub58           ; $a4bc; called by sub31, sub44, sub48
                lda ptr5,x
                sub #16
                sta ptr5,x
                bcs +
                dec ptr5+1,x
+               rts

sub59           ; $a4c8; called by mode_prep_title
                lda #$ff
                sta sq1_prev
                sta sq2_prev
                jsr snd_eng3
                ldx #$fb
                ldy #$ad
                jsr snd_eng6
                rts

; -----------------------------------------------------------------------------

                pad $a4d9, $ff
snd_eng_bin     incbin "irriship-snd-eng.bin"  ; sound engine

; -----------------------------------------------------------------------------

                pad $c800, $00

reset           sei
                ldx #0
                stx ppu_ctrl            ; disable NMI
                stx ppu_mask            ; disable rendering
                sta snd_chn
                lda #%01000000
                sta joypad2
                ;
                ; check for warm boot
                ldy #(6-1)
-               lda warm_boot_ram,y
                cmp warm_boot_chk,y
                bne +
                dey
                bpl -
                ;
                lda gravity             ; warm boot
                asl a
                asl a
                ora skill
                tay
                jmp ++
                ;
+               ldy #0                  ; cold boot
                ;
++              bit ppu_status
-               bit ppu_status
                bpl -
                cld
                ;
                ; clear RAM (fill with $00 except OAM page with $ff)
-               lda #$ff
                sta oam_page,x
                lda #$00
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
                sty temp2               ; 0 if cold boot
                stx dmc_raw             ; X is still 0
                stx dmc_len
                dex
                txs
                stx arr5
                stz dmc_start
                lda #$4c                ; JMP absolute opcode
                sta ram_jump_code+0
                bit temp1
                nop
                nop
                nop
                nop
                nop
                nop
                copy #$82, ptr3+1
                copy #$0f, dmc_freq
                nop
                bit temp1
                lda #$7e
                ldx #$20
                jsr sub2
                ;
                ; NTSC/PAL detection (count cycles between VBlanks?)
                ;
                ldx #0
--              bit ppu_status
                bmi +
                ldy #57
-               dey
                bne -
                bit temp1
                inx
                jmp --
                ;
+               stx temp1
                ldy #6
-               lda loop_counts-1,y
                cmp temp1
                bcs +
                dey
                bne -
                ;
+               lda regions,y
                sta region
                ;
                lda temp2
                and #%00000011
                sta skill
                lda temp2
                lsr a
                lsr a
                sta gravity
                ;
                jmp use_jump_table

loop_counts     db 197, 182, 159, 79, 72, 60  ; $c8b4
regions         db 0, 2, 1, 0, 2, 1, 0

read_joypad     ; $c8c1; called by main_loop
                ;
                ; init joypads
                ldx #1
                stx buttons_changed
                stx joypad1
                dex
                stx joypad1
                ;
                ; read 8 standard joypad or Famicom expansion contrlr buttons
                ; (don't use buttons_held as we need old value later)
-               lda joypad1
                and #%00000011
                cmp #1
                rol buttons_changed
                bcc -
                ;
                ; prevent simultaneous up&down or left&right
                lda buttons_changed
                and #%00001010
                lsr a
                eor #%11111111
                and buttons_changed
                sta buttons_changed
                ;
                ; get buttons that have changed to "on" from previous status
                ; and finally update buttons being pressed
                tay
                eor buttons_held
                and buttons_changed
                sta buttons_changed
                sty buttons_held
                rts

main_loop       ; $c8ec; called by: nothing (see use_jump_table)
                ;
-               lda main_loop_flag
                beq -
                inc ram7
                jsr read_joypad
                ;
use_jump_table  ; $c8f5; indirect JSR to entry number mode in mode_jump_table
                ; called by reset
                ;
                lda mode
                asl a
                tax
                lda mode_jump_table+0,x
                sta ram_jump_code+1
                lda mode_jump_table+1,x
                sta ram_jump_code+2
                jsr ram_jump_code
                ;
                copy next_mode, mode
                copy ram4, ram3
                stz main_loop_flag
                jmp main_loop

hide_sprites    ; $c915; called by sub28, mode_title, mode_ingame, mode_dead,
                ; mode5, icod12
                ;
                lda #$ff
                ldx #60
-               sta oam_page+ 0*4,x
                sta oam_page+16*4,x
                sta oam_page+32*4,x
                sta oam_page+48*4,x
                db AXS_IMM, 4           ; X = (A & X) - value without borrow
                bpl -
                lda #(6*4)
                sta free_spr_index
                rts

; -----------------------------------------------------------------------------

nmi             ; $c92e
                pha                     ; push A, X, Y
                txa
                pha
                tya
                pha

                ; if MODE_TITLE or MODE_INGAME, store "sprite 0 hit" status
                lda mode
                cmp #MODE_TITLE
                bcc +
                lda ppu_status
                and #%01000000
                ora ram36
                sta ram36

+               lda main_loop_flag      ; skip stuff if flag set
                beq +
                jmp nmi_end

+               lda ram28
                bne ++++
                lda ram36
                beq +++++
                lda ram22
                bmi +++

                lda mode
                cmp #MODE_INGAME
                beq +
                lda ram24
                bne +++++

                dec ram24
                bne ++
+               jsr nmisub3
++              lda arr36
                sta oam_page+2*4+0
                sta oam_page+3*4+0
                add #8
                sta oam_page+4*4+0
                sta oam_page+5*4+0
                copy #4, arr36+1
                lda ram23
                jsr snd_eng5
                jmp +++++

+++             lda #$30                ; 1st explosion tile in PT1
                sta oam_page+0*4+1
                lda #MODE_DEAD
                sta mode
                sta next_mode
                lda #2                  ; play sound or stop music?
                jsr snd_eng5

++++            stz ram36

+++++           bit ppu_status
                jsr flush_ppu_buf
                jsr nmisub2
                lda ppu_mask_copy1
                sta ppu_mask

                lda scroll_x            ; set scroll
                sta ppu_scroll
                ldy scroll_y
                sty ppu_scroll

                stz oam_addr            ; do OAM DMA
                lda #>oam_page
                sta oam_dma

                lda ppu_mask_copy2
                sta ppu_mask
                sta ppu_mask_copy1

                lda ppu_ctrl_copy2
                sta ppu_ctrl
                sta ppu_ctrl_copy1

                copy scroll_y, ram6

nmi_end         jsr snd_eng1
                inc main_loop_flag

                pla                     ; pull Y, X, A
                tay
                pla
                tax
                pla
                rti

                ; unaccessed ($c9d8)
                lda main_loop_flag
-               cmp main_loop_flag
                bne -
                rts

; -----------------------------------------------------------------------------

                pad $ffe0, $00

                ; unaccessed
                db " IRRITATING SHIP"
                hex 24 01 f2 fb 20 00 01 0e 00 e4

                ; interrupt vectors
                pad $fffa
                dw nmi, reset, reset    ; IRQ unaccessed

; --- CHR ROM -----------------------------------------------------------------

                base $0000
                incbin "irriship-bg.bin"
                incbin "irriship-spr.bin"
