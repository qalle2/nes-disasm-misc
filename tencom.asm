; "The Ten Commandments on NES" by Debiru, website
; https://debiru.itch.io/the-ten-commandments-on-nes
; unofficial disassembly by qalle
; assembles with ASM6

; --- Constants ---------------------------------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array

ram1            equ $00
ram2            equ $01
ram3            equ $02
ram4            equ $03
ptr1            equ $04
ram5            equ $06
ram6            equ $07
ram7            equ $08
ram8            equ $09
ram9            equ $0a
ram10           equ $0b
scroll_h        equ $0c
scroll_v        equ $0d
ppu_ctrl_copy   equ $10
ppu_mask_copy   equ $12
ram_indir_jmp   equ $14  ; 3 bytes
ptr2            equ $17
ptr3            equ $19
ptr4            equ $22
ptr5            equ $2a
ptr6            equ $2c
ram11           equ $32

arr1            equ $01c0
sprite_data     equ $0200
arr2            equ $0300

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

; --- Macros ------------------------------------------------------------------

macro copy _src, _dst
                lda _src
                sta _dst
endm

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
                stx ppu_mask            ; disable rendering
                stx dmc_freq
                stx ppu_ctrl            ; disable NMI on VBlank

                bit ppu_status
-               bit ppu_status
                bpl -
-               bit ppu_status
                bpl -

                lda #%01000000
                sta joypad2

                ; fill palettes with black
                copy #$3f, ppu_addr
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

                copy #$00, ptr4+0
                copy #$08, ptr4+1
                jsr clear_y

                ; store "JMP indir_rts" at ram_indir_jmp
                lda #$4c                ; JMP absolute
                sta ram_indir_jmp+0
                lda #<indir_rts
                sta ram_indir_jmp+1
                lda #>indir_rts
                sta ram_indir_jmp+2
                ;
                lda #%10000000          ; enable NMI on VBlank
                sta ppu_ctrl_copy
                sta ppu_ctrl
                lda #%00000110          ; enable sprite & BG left column
                sta ppu_mask_copy
                ;
                lda ram2
-               cmp ram2
                beq -

                ldx #$34
                ldy #$18
-               dex
                bne -
                dey
                bne -

                lda ppu_status
                and #%10000000          ; VBlank flag
                sta ram1
                jsr disable_render

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

                lda ppu_mask_copy
                and #%00011000          ; sprite & BG enable
                bne +
                jmp +++
+               lda #>sprite_data
                sta oam_dma
                lda ram6
                bne +
                jmp ++
+               ldx #$00
                stx ram6
                copy #$3f, ppu_addr
                stx ppu_addr

                to_ppu arr1+0, ram7
                tax
                ;
                to_ppu arr1+1, ram7
                to_ppu arr1+2, ram7
                to_ppu arr1+3, ram7
                stx ppu_data
                ;
                to_ppu arr1+5, ram7
                to_ppu arr1+6, ram7
                to_ppu arr1+7, ram7
                stx ppu_data
                ;
                to_ppu arr1+9, ram7
                to_ppu arr1+10, ram7
                to_ppu arr1+11, ram7
                stx ppu_data
                ;
                to_ppu arr1+13, ram7
                to_ppu arr1+14, ram7
                to_ppu arr1+15, ram7
                stx ppu_data
                ;
                to_ppu arr1+17, ram9
                to_ppu arr1+18, ram9
                to_ppu arr1+19, ram9
                stx ppu_data
                ;
                to_ppu arr1+21, ram9
                to_ppu arr1+22, ram9
                to_ppu arr1+23, ram9
                stx ppu_data
                ;
                to_ppu arr1+25, ram9
                to_ppu arr1+26, ram9
                to_ppu arr1+27, ram9
                stx ppu_data
                ;
                to_ppu arr1+29, ram9
                to_ppu arr1+30, ram9
                to_ppu arr1+31, ram9

++              lda ram4
                beq +
                copy #$00, ram4
                lda ram5
                beq +
                jsr sub10
                ;
+               lda #$00
                sta ppu_addr
                sta ppu_addr
                lda scroll_h
                sta ppu_scroll
                lda scroll_v
                sta ppu_scroll
                lda ppu_ctrl_copy
                sta ppu_ctrl
+++             lda ppu_mask_copy
                sta ppu_mask
                ;
                inc ram2
                inc ram3
                lda ram3
                cmp #6
                bne nmi_end
                copy #0, ram3
                ;
nmi_end         jsr ram_indir_jmp

                pla                     ; pull Y, X, A
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
                jmp nmi_end

; -----------------------------------------------------------------------------

                sta ram_indir_jmp+1     ; unaccessed
                stx ram_indir_jmp+2     ; unaccessed
indir_rts       rts                     ; $8210

                ; $8211: unaccessed chunk
                sta ptr2+0
                stx ptr2+1
                ldx #$00
                lda #$20
--              sta ptr3+0
                ldy #$00
-               lda (ptr2),y
                sta arr1,x
                inx
                iny
                dec ptr3+0
                bne -
                inc ram6
                rts
                sta ptr2+0
                stx ptr2+1
                ldx #$00
                lda #$10
                bne --
                sta ptr2+0
                stx ptr2+1
                ldx #$10
                txa
                bne --

; -----------------------------------------------------------------------------

sub1            ; $823e; called by cod2
                sta ptr2+0
                jsr sub15
                and #%00011111
                tax
                lda ptr2+0
                sta arr1,x
                inc ram6
                rts

sub2            ; $824e; called by reset
                lda #$0f
                ldx #$00
-               sta arr1,x
                inx
                cpx #32
                bne -
                stx ram6
                rts

sub3            ; $825d; called by sub4
                tax
                lda dat1,x
                sta ram9
                lda dat2,x
                sta ram10
                sta ram6
                rts

-               tax                     ; $826b
                lda dat1,x
                sta ram7
                lda dat2,x
                sta ram8
                sta ram6
                rts
                ;
sub4            ; $8279; called by reset
                jsr sub3
                txa
                jmp -

disable_render  ; $8280; hide sprites & background; called by reset
                lda ppu_mask_copy
                and #%11100111
                sta ppu_mask_copy
                jmp sub8

enable_render   ; $8289; show sprites & background; called by cod2
                lda ppu_mask_copy
                ora #%00011000
-               sta ppu_mask_copy
                jmp sub8

                ; $8292: unaccessed chunk
                lda ppu_mask_copy
                ora #%00001000
                bne -
                lda ppu_mask_copy
                ora #%00010000
                bne -
                sta ppu_mask_copy
                rts
                lda ram1
                ldx #$00
                rts
                lda ppu_ctrl_copy
                ldx #$00
                rts
                sta ppu_ctrl_copy
                rts

hide_sprites    ; $82ae; called by reset
                ldx #$00
                lda #$ff
-               sta sprite_data,x
                inx
                inx
                inx
                inx
                bne -
                rts

                ; $82bc: unaccessed chunk
                asl a
                asl a
                asl a
                asl a
                asl a
                and #%00100000
                sta ptr2+0
                lda ppu_ctrl_copy
                and #%11011111
                ora ptr2+0
                sta ppu_ctrl_copy
                rts

                ; $82ce: unaccessed chunk
                tax
                lda #$f0
-               sta sprite_data,x
                inx
                inx
                inx
                inx
                bne -
                rts

                ; $82db: unaccessed chunk
                copy #$01, ram4
                lda ram2
-               cmp ram2
                beq -
                lda ram1
                beq +
-               lda ram3
                cmp #$05
                beq -
+               rts

; -----------------------------------------------------------------------------

sub8            ; $82f0; called by disable_render, enable_render
                copy #1, ram4
                lda ram2
-               cmp ram2
                beq -
                rts

                ; $82fb: unaccessed chunk
                sta ptr2+0
                txa
                bne +
                lda ptr2+0
                cmp #$f0
                bcs +
                sta scroll_v
                lda #$00
                sta ptr2+0
                beq ++
+               sec
                lda ptr2+0
                sbc #$f0
                sta scroll_v
                copy #$02, ptr2+0
++              jsr sub14
                sta scroll_h
                txa
                and #%00000001
                ora ptr2+0
                sta ptr2+0
                lda ppu_ctrl_copy
                and #%11111100
                ora ptr2+0
                sta ppu_ctrl_copy
                rts
                and #%00000001
                asl a
                asl a
                asl a
                sta ptr2+0
                lda ppu_ctrl_copy
                and #%11110111
                ora ptr2+0
                sta ppu_ctrl_copy
                rts
                and #%00000001
                asl a
                asl a
                asl a
                asl a
                sta ptr2+0
                lda ppu_ctrl_copy
                and #%11101111
                ora ptr2+0
                sta ppu_ctrl_copy
                rts

; -----------------------------------------------------------------------------

sub9            ; $834f; called by cod2
                sta ptr2+0
                stx ptr2+1
                jsr sub14
                sta ptr3+0
                stx ptr3+1
                ldy #$00
-               lda (ptr3),y
                sta ppu_data
                inc ptr3+0
                bne +
                inc ptr3+1
+               lda ptr2+0
                bne +
                dec ptr2+1
+               dec ptr2+0
                lda ptr2+0
                ora ptr2+1
                bne -
                rts

                ; $8376: unaccessed chunk
                sta ptr1+0
                stx ptr1+1
                ora ptr1+1
                sta ram5
                rts
                sta ptr1+0
                stx ptr1+1
sub10           ldy #$00
--              lda (ptr1),y
                iny
                cmp #$40
                bcs +
                sta ppu_addr
                lda (ptr1),y
                iny
                sta ppu_addr
                lda (ptr1),y
                iny
                sta ppu_data
                jmp --
+               tax
                lda ppu_ctrl_copy
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
                lda (ptr1),y
                iny
                sta ppu_addr
                lda (ptr1),y
                iny
                tax
-               lda (ptr1),y
                iny
                sta ppu_data
                dex
                bne -
                lda ppu_ctrl_copy
                sta ppu_ctrl
                jmp --
+++             rts

; -----------------------------------------------------------------------------

set_ppu_addr    ; $83d4; X*256+A -> PPU address; called by cod2
                stx ppu_addr
                sta ppu_addr
                rts

                ; $83db: unaccessed chunk
                sta ppu_data
                rts
                sta ptr3+0
                stx ptr3+1
                jsr sub15
                ldx ptr3+1
                beq +
                ldx #$00
-               sta ppu_data
                dex
                bne -
                dec ptr3+1
                bne -
+               ldx ptr3+0
                beq +
-               sta ppu_data
                dex
                bne -
+               rts
                ora #%00000000
                beq +
                lda #$04
+               sta ptr2+0
                lda ppu_ctrl_copy
                and #%11111011
                ora ptr2+0
                sta ppu_ctrl_copy
                sta ppu_ctrl
                rts
                lda ram2
                ldx #$00
                rts
                tax
-               jsr sub8
                dex
                bne -
                rts

                ; $8422; partially unaccessed; read by sub3, sub4
dat1            dl dat3, dat4, dat5, dat6, dat7, dat8, dat9, dat10, dat11
dat2            dh dat3, dat4, dat5, dat6, dat7, dat8, dat9, dat10, dat11

                ; $8434; unaccessed
dat3            hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
dat4            hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
dat5            hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f
dat6            hex 0f 0f 0f 0f 0f 0f 0f 0f
                hex 0f 0f 0f 0f 0f 0f 0f 0f

                ; $8474; partially unaccessed
dat7            hex 00 01 02 03 04 05 06 07
                hex 08 09 0a 0b 0c 0f 0f 0f
dat8            hex 10 11 12 13 14 15 16 17
                hex 18 19 1a 1b 1c 00 00 00
dat9            hex 10 21 22 23 24 25 26 27
                hex 28 29 2a 2b 2c 10 10 10
dat10           hex 30 31 32 33 34 35 36 37
                hex 38 39 3a 3b 3c 20 20 20
dat11           hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30
                hex 30 30 30 30 30 30 30 30

; -----------------------------------------------------------------------------

clear_y         ; $84f4; called by reset
                ldy #$00
                beq +
                lda #$00                ; unaccessed
                ldx #$85                ; unaccessed
                jmp arr2                ; unaccessed
+               rts

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
macro copyline _src, _dst
                lda #<_src
                ldx #>_src
                jsr sub17
                ldx #0
                lda #_dst
                jsr sub9
endm

cod2            ; $8500; called by reset
                ;
                lajs $00, $02
                lajs $01, $14
                lajs $02, $20
                lajs $03, $30
                ;
                ldx #>$2042
                lda #<$2042
                jsr set_ppu_addr        ; X*256+A -> PPU address
                ;
                copyline line1a, 28
                copyline line1b, 32
                copyline line_empty, 32
                copyline line2a, 32
                copyline line2b, 32
                copyline line_empty, 32
                copyline line3a, 32
                copyline line3b, 32
                copyline line3c, 32
                copyline line_empty, 32
                copyline line4a, 32
                copyline line4b, 32
                copyline line_empty, 32
                copyline line5a, 32
                copyline line5b, 32
                copyline line_empty, 32
                copyline line6, 32
                copyline line_empty, 32
                copyline line7a, 32
                copyline line7b, 32
                copyline line_empty, 32
                copyline line8, 32
                copyline line_empty, 32
                copyline line9a, 32
                copyline line9b, 32
                copyline line_empty, 32
                copyline line10, 32
                ;
                jsr enable_render
-               jmp -

                ldy #$00                ; $86af (unaccessed)
                beq +                   ; unaccessed
                lda #<dat12             ; unaccessed
                ldx #>dat12             ; unaccessed
                jmp arr2                ; unaccessed
+               rts                     ; unaccessed

sub13           ; $86bb; called by reset
                ;
                copy #<dat12, ptr5+0
                copy #>dat12, ptr5+1
                copy #<arr2, ptr6+0
                copy #>arr2, ptr6+1
                ldx #$da
                copy #$ff, ram11
                ldy #$00
                ;
-               inx
                beq +
--              lda (ptr5),y
                sta (ptr6),y
                iny
                bne -
                inc ptr5+1              ; $86dd (unaccessed)
                inc ptr6+1              ; unaccessed
                bne -                   ; unaccessed
+               inc ram11
                bne --
                rts

sub14           ; $86e8; called by sub9
                ldy #$01
                lda (ptr4),y
                tax
                dey
                lda (ptr4),y
                inc ptr4+0
                beq +
                inc ptr4+0
                beq ++
                rts                     ; $86f8 (unaccessed)
+               inc ptr4+0              ; unaccessed
++              inc ptr4+1
                rts

sub15           ; $86fe; called by sub1
                ldy #$00
                lda (ptr4),y
                inc ptr4+0
                beq +
                rts                     ; $8706 (unaccessed)
+               inc ptr4+1
                rts

                ldy #$00                ; $870a (unaccessed)
                lda (ptr4),y            ; unaccessed

sub16           ; $870e; called by cod2
                ldy ptr4+0
                beq +
                dec ptr4+0              ; $8712 (unaccessed)
                ldy #$00                ; unaccessed
                sta (ptr4),y            ; unaccessed
                rts                     ; unaccessed
+               dec ptr4+1
                dec ptr4+0
                sta (ptr4),y
                rts

                lda #$00                ; $8720 (unaccessed)
                ldx #$00                ; unaccessed

sub17           ; $8724; called by cod2
                pha
                lda ptr4+0
                sec
                sbc #2
                sta ptr4+0
                bcs +
                dec ptr4+1
+               ldy #$01
                txa
                sta (ptr4),y
                pla
                dey
                sta (ptr4),y
                rts

sub18           ; $873a; called by reset
                copy #$25, ptr5+0
                copy #$03, ptr5+1
                lda #$00
                tay
                ldx #$00
                beq +
-               sta (ptr5),y            ; unaccessed
                iny                     ; unaccessed
                bne -                   ; unaccessed
                inc ptr5+1              ; unaccessed
                dex                     ; unaccessed
                bne -                   ; unaccessed
+
-               cpy #$00                ; $8753
                beq +
                sta (ptr5),y            ; unaccessed
                iny                     ; unaccessed
                bne -                   ; unaccessed
+               rts

                ; $875d; read by cod2
line_empty      db "                                ", $00
line1b          db "      gods before me            ", $00
line2a          db "    2.Thou shalt not make unto  ", $00
line2b          db "      thee any graven image     ", $00
line3a          db "    3.Thou shalt not take the   ", $00
line3b          db "      name of the Lord thy God  ", $00
line3c          db "      in vain                   ", $00
line4a          db "    4.Remember the sabbath day, ", $00
line4b          db "      to keep it holy           ", $00
line5a          db "    5.Honor thy father and thy  ", $00
line5b          db "      mother                    ", $00
line6           db "    6.Thou shalt not murder     ", $00
line7a          db "    7.Thou shalt not commit     ", $00
line7b          db "      adultery                  ", $00
line8           db "    8.Thou shalt not steal      ", $00
line9a          db "    9.Thou shalt not bear false ", $00
line9b          db "    witness against thy neighbor", $00
line10          db "    10.Thou shalt not covet     ", $00
line1a          db "1.Thou shalt have no other ", $00

dat12           ; $89cb; read by sub13
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
                incbin "tencom-chr.bin"
                pad $2000, $00
