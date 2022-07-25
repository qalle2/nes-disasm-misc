; An unofficial disassembly of the PRG ROM of "DVD Screensaver for NES" by
; Johnybot, https://johnybot.itch.io/nes-dvd-screensaver
; Disassembled by qalle. Assembles with ASM6.

; --- Constants ---------------------------------------------------------------

temp            equ $00  ; many uses
prev_tile       equ $01  ; previous tile
pointer         equ $02  ; 2 bytes
wait_for_nmi    equ $04
scroll_h        equ $06
scroll_v        equ $07
scroll_h_delta  equ $08
scroll_v_delta  equ $09
color           equ $0a  ; logo color (0-2)
ppu_ctrl_copy   equ $0b
ppu_mask_copy   equ $0c
unused          equ $0d

ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
ppu_scroll      equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007
dmc_freq        equ $4010
joypad2         equ $4017

; --- Macros ------------------------------------------------------------------

; force 16-bit addressing with operands <= $ff
macro adcw _zp
                db $6d, _zp, $00
endm
macro staw _zp
                db $8d, _zp, $00
endm
macro ldaw _zp
                db $ad, _zp, $00
endm
macro ldxw _zp
                db $ae, _zp, $00
endm
macro incw _zp
                db $ee, _zp, $00
endm

; --- Initialization ----------------------------------------------------------

                base $c000

reset           sei                     ; initialize the NES
                cld
                ldx #$40
                stx joypad2
                ldx #$ff
                txs
                inx
                stx ppu_ctrl
                stx ppu_mask
                stx dmc_freq

-               bit ppu_status          ; wait for VBlank
                bpl -

-               lda #$00                ; fill RAM with $00 except $02xx w/ $fe
                sta $00,x
                sta $0100,x
                sta $0300,x
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                lda #$fe
                sta $0200,x
                inx
                bne -

-               bit ppu_status          ; wait for VBlank
                bpl -

                lda #$0d
                sta unused

                lda ppu_status          ; set NT0
                lda #$20
                sta ppu_addr
                lda #$00
                sta ppu_addr
                ldx #<(nt_data-$4000)
                ldy #>(nt_data-$4000)
                jsr set_nt-$4000        ; X, Y = address

                lda ppu_status          ; set NT2
                lda #$28
                sta ppu_addr
                lda #$00
                sta ppu_addr
                ldx #<(nt_data-$4000)
                ldy #>(nt_data-$4000)
                jsr set_nt-$4000        ; X, Y = address

                lda ppu_status          ; set initial palette
                lda #$3f
                sta ppu_addr
                lda #$00
                sta ppu_addr
                lda #<(initial_palette-$4000)
                ldx #>(initial_palette-$4000)
                ldy #32
                jsr set_palette-$4000   ; A, X = address, Y = length

                lda #191                ; initial scroll values
                sta scroll_h
                lda #199
                sta scroll_v
                lda #$ff                ; initial direction (up & left)
                staw scroll_h_delta
                staw scroll_v_delta
                lda #0                  ; initial color
                staw color

                lda #%00011110          ; show background & sprites
                sta ppu_mask_copy
                lda #%10010000          ; NMI on VBlank, use PT1 for background
                sta ppu_ctrl_copy
                sta ppu_ctrl
                jmp main_loop-$4000

; --- Main loop ---------------------------------------------------------------

main_loop       inc wait_for_nmi        ; set flag
-               lda wait_for_nmi        ; wait until NMI routine clears flag
                bne -
                jsr scroll_sub-$4000
                jmp main_loop-$4000

scroll_sub      ; if collision with screen edge, change direction and color;
                ; then change scroll values in RAM
                ;
                ldaw scroll_v           ; vertical collision?
                cmp #200
                bne +
                jsr change_color-$4000
                lda #$ff
                staw scroll_v_delta
                jmp scroll_sub_h-$4000
                ;
+               cmp #0
                bne scroll_sub_h
                jsr change_color-$4000
                lda #1
                staw scroll_v_delta
                ;
scroll_sub_h    ldaw scroll_h           ; horizontal collision?
                cmp #$c0
                bne +
                jsr change_color-$4000
                lda #$ff
                staw scroll_h_delta
                jmp apply_delta-$4000
                ;
+               cmp #0
                bne apply_delta
                jsr change_color-$4000
                lda #1
                staw scroll_h_delta
                ;
apply_delta     ldaw scroll_h           ; update scroll values
                clc
                adcw scroll_h_delta
                staw scroll_h
                ldaw scroll_v
                clc
                adcw scroll_v_delta
                staw scroll_v
                rts

change_color    ; change logo color (0-2)
                ;
                incw color
                ldaw color
                cmp #3
                bne +
                lda #0
                staw color
+               rts

set_pointer     ; set pointer (called by set_palette)
                ;
                sta pointer+0
                stx pointer+1
                sty temp                ; length
                rts

set_palette     ; set palette (called by initialization)
                ;
                jsr set_pointer-$4000
                ldy #0
-               lda (pointer),y
                sta ppu_data
                iny
                cpy temp
                bne -
                rts

set_nt          ; decode RLE-encoded data into name table (called by
                ; initialization)
                ;
                stx pointer+0
                sty pointer+1
                ldy #0
                jsr read_and_inc-$4000
                sta temp                ; index of special tile
                ;
--              jsr read_and_inc-$4000
                cmp temp                ; if not special tile, write it to VRAM
                beq +                   ; and proceed...
                sta ppu_data
                sta prev_tile
                bne --                  ; unconditional
                ;
+               jsr read_and_inc-$4000  ; ...otherwise read another byte and
                cmp #$00                ; repeat previously-output tile that
                beq +                   ; many times; exit if terminator
                tax
                lda prev_tile
-               sta ppu_data
                dex
                bne -
                beq --                  ; unconditional
                ;
+               rts

read_and_inc    ; read from pointer & increment (called by set_nt)
                ;
                lda (pointer),y
                inc pointer+0
                bne +                   ; always taken
                inc pointer+1           ; unaccessed
+               rts

; --- Interrupt routines ------------------------------------------------------

nmi             pha                     ; push A, X, Y
                txa
                pha
                tya
                pha
                ;
                lda ppu_status
                lda #$3f
                sta ppu_addr
                lda #$03
                sta ppu_addr
                ldxw color
                lda colors-$4000,x
                sta ppu_data
                ;
                lda scroll_h
                sta ppu_scroll
                lda scroll_v
                sta ppu_scroll
                lda ppu_ctrl_copy
                sta ppu_ctrl
                lda ppu_mask_copy
                sta ppu_mask
                ;
                pla                     ; pull Y, X, A
                tay
                pla
                tax
                pla
                ;
                dec wait_for_nmi        ; clear flag to let main loop run once
                ;
                rti

; --- Arrays ------------------------------------------------------------------

initial_palette hex 0f 0f 0f 11
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f
                hex 0f 0f 0f 0f

nt_data         ; RLE-encoded name table data; read by set_nt
                ;
                hex 01                  ; special tile index = $01
                hex 00 01 fe            ; output tile $00; repeat $fe times
                hex 00 01 fe
                hex 00 01 fe
                hex 00 01 3a
                hex 08 09 0a 0b 0c 0d 0e 0f
                hex 00 01 17
                hex 18 19 1a 1b 1c 1d 1e 1f
                hex 00 01 17
                hex 28 29 2a 2b 2c 2d 2e 2f
                hex 00 01 17
                hex 38 39 3a 3b 3c 3d 3e 3f
                hex 00 01 17
                hex 48 49 4a 4b 4c 4d 4e 4f
                hex 00 01 3e
                hex 00
                hex 01 00               ; end

colors          hex 11 15 19            ; logo colors (blue, red, green)

; --- Interrupt vectors -------------------------------------------------------

                pad $fffa, $ff
                dw nmi-$4000, reset-$4000, $0000  ; IRQ unaccessed
