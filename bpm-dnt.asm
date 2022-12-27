; "Donut, NES CHR codec decompressor" by Johnathan Roatch.
; Bank 3, CPU address $d5cd.
; See https://www.nesdev.org/wiki/User:Ns43110/donut.s

pln_buf         equ $b8    ; plane buffer (8 bytes)
pb8_ctrl        equ $c0    ; pb8 control
even_odd        equ $c1    ; even_odd
blk_ofs         equ $c2    ; block offset
pln_def         equ $c3    ; plane_def
blk_ofs_end     equ $c4    ; block offset end
blk_hdr         equ $c5    ; block header
is_rotated      equ $c6    ; is rotated?
stream_ptr      equ $c7    ; stream pointer (2 bytes)
blk_cnt         equ $c9    ; block count
blk_buf         equ $0100  ; block buffer (64 bytes)
ppu_data        equ $2007

                base $d5cd

decomp_blk      ; Decompress a variable-size block from stream_ptr, output
                ; 64 bytes to blk_buf,x.
                ; out: carry = failure, Y = # of bytes read, X += 64
                ; block header bits: L M l m bb B R:
                ;     R: rotate plane bits (135-deg. reflection)
                ;     bbB:
                ;         000 = all planes $00
                ;         010 = L planes $00, M planes pb8
                ;         100 = L planes pb8, M planes $00
                ;         110 = all planes pb8
                ;         001 = in extra byte, for each bit from MSB:
                ;               0 = $00 plane, 1 = pb8 plane
                ;         011 = in extra byte, decode only 1 pb8 plane and
                ;               duplicate for each bit from MSB:
                ;               0 = $00 plane, 1 = duplicated plane
                ;               if extra byte = $00, don't decode pb8 plane
                ;         1x1 = uncompressed block
                ;     m: M planes predict from $ff
                ;     l: L planes predict from $ff
                ;     M: M ^= L
                ;     L: L ^= M
                ; 00101010 = uncompressed 64-byte block (ASCII "*")
                ; called by: decomp

                ldy #0
                txa
                clc
                adc #64
                bcs +                   ; error; exit (never taken)
                sta blk_ofs_end
                lda (stream_ptr),y
                iny
                sta blk_hdr
                cmp #$2a
                beq raw_blk_loop        ; never taken
                cmp #$c0
                bcc normal_blk          ; always taken
+               rts                     ; unaccessed ($d5e4)

read_pln_def    ; "read_plane_def_from_stream"
                ror a
                lda (stream_ptr),y
                iny
                bne +++                 ; always taken

raw_blk_loop    ; "raw_block_loop" (unaccessed, $d5eb)
                lda (stream_ptr),y
                iny
                sta blk_buf,x
                inx
                cpy #65                 ; size of raw block
                bcc raw_blk_loop
                bcs exit_sub

normal_blk      stx blk_ofs             ; do_normal_block
                and #%11011111
                sta even_odd
                lsr a
                ror is_rotated
                lsr a
                bcs read_pln_def
                ;
                ; "unpack_shorthand_plane_def"
                and #%00000011
                tax
                lda pln_def_tbl,x
                ;
+++             ror is_rotated
                sta pln_def
                sty pb8_ctrl
                clc
                lda blk_ofs

pln_loop        adc #8                  ; plane_loop
                sta blk_ofs
                ;
                lda even_odd
                eor blk_hdr
                sta even_odd
                and #%00110000
                beq +                   ; "not predicted from $ff"
                lda #$ff
+               asl pln_def
                bcc do_zero_pln
                ;
                ldy pb8_ctrl            ; do_pb8_plane
                bit is_rotated
                bpl +                   ; "don't rewind input pointer"
                ldy #2                  ; unaccessed ($d62d)
+               tax
                lda (stream_ptr),y
                iny
                sta pb8_ctrl
                txa
                bvs rotd_pb8_pln
                ;
                ; "do_normal_pb8_plane"
                ldx blk_ofs
                rol pb8_ctrl
pb8_loop        bcc +
                lda (stream_ptr),y
                iny
+               dex
                sta blk_buf,x
                asl pb8_ctrl
                bne pb8_loop
                sty pb8_ctrl
                ;
end_pln         bit even_odd
                bpl +
                ;
                ; "XOR M onto L"
                ldy #8
-               dex
                lda blk_buf,x
                eor blk_buf+8,x
                sta blk_buf,x
                dey
                bne -
+               bvc +
                ;
                ; "XOR L onto M"
                ldy #8
-               dex
                lda blk_buf,x
                eor blk_buf+8,x
                sta blk_buf+8,x
                dey
                bne -
                ;
+               lda blk_ofs
                cmp blk_ofs_end
                bcc pln_loop

                ldy pb8_ctrl
exit_sub        clc
                tya
                adc stream_ptr+0
                sta stream_ptr+0
                bcc +
                inc stream_ptr+1
+               ldx blk_ofs_end
                dec blk_cnt
                rts

do_zero_pln     ; "do_zero_plane"
                ldx blk_ofs
                ldy #8
-               dex
                sta blk_buf,x
                dey
                bne -
                beq end_pln

rotd_pb8_pln    ; "do_rotated_pb8_plane"
                ldx #8
-               asl pb8_ctrl            ; buffered_pb8_loop
                bcc +                   ; use_previous
                lda (stream_ptr),y
                iny
+               dex
                sta pln_buf,x
                bne -
                ;
                sty pb8_ctrl
                ldy #8
                ldx blk_ofs
                ;
flip_bits       asl pln_buf+0           ; flip_bits_loop
                ror a
                asl pln_buf+1
                ror a
                asl pln_buf+2
                ror a
                asl pln_buf+3
                ror a
                asl pln_buf+4
                ror a
                asl pln_buf+5
                ror a
                asl pln_buf+6
                ror a
                asl pln_buf+7
                ror a
                dex
                sta blk_buf,x
                dey
                bne flip_bits
                ;
                beq end_pln             ; unconditional

pln_def_tbl     db %00000000            ; shorthand_plane_def_table
                db %01010101
                db %10101010
                db %11111111

decomp          ; "Decompress X*64 bytes from AAYY to ppu_data; PPU is in
                ; forced blank, ppu_addr already set."
                ; This is the only entry point in this file, $00ff bytes from
                ; the start.
                ; in: X = block count
                ; called by: sub16
                ;
                sty stream_ptr+0
                sta stream_ptr+1
                stx blk_cnt
                ;
--              ldx #64
                jsr decomp_blk
                cpx #$80
                bne +                   ; end block upload
                ;
                ldx #64                 ; copy 64 bytes (index $40-$7f) to PPU
-               lda blk_buf,x
                sta ppu_data
                inx
                bpl -
                ;
                ldx blk_cnt
                bne --
                ;
+               rts
