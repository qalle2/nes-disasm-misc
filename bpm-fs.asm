; Famistudio at the start of bank 2.
; Only these subs are called from the outside: fs_init, fs_play, fs_update
; Download "NES Sound Engine" from https://famistudio.org and see
; "famistudio_asm6.asm".

fs_temp         equ $9f    ; Famistudio temp
ram11           equ $a0
ram12           equ $a1
fs_dat_ptr      equ $a2    ; 2 bytes; bank 2; Famistudio data pointer
ptr2            equ $a4    ; 2 bytes; bank 2 (overlaps)
fs_env_value    equ $0200  ; famistudio_env_value
fs_env_repeat   equ $020b  ; famistudio_env_repeat
fs_env_addr_lo  equ $0216  ; famistudio_env_addr_lo
fs_env_addr_hi  equ $0221  ; famistudio_env_addr_hi
arr13           equ $022b
fs_env_ptr      equ $022c  ; famistudio_env_ptr
fs_pit_env_va_l equ $0237  ; famistudio_pitch_env_value_lo
fs_pit_env_va_h equ $023a  ; famistudio_pitch_env_value_hi
fs_pit_env_rep  equ $023d  ; famistudio_pitch_env_repeat
fs_pit_env_ad_l equ $0240  ; famistudio_pitch_env_addr_lo
fs_pit_env_ad_h equ $0243  ; famistudio_pitch_env_addr_hi
fs_pit_env_ptr  equ $0246  ; famistudio_pitch_env_ptr
fs_pit_env_fiva equ $0249  ; famistudio_pitch_env_fine_value
arr22           equ $024c
arr23           equ $0250
arr24           equ $0254
arr25           equ $0258
arr26           equ $025d
fs_chn_note     equ $0262  ; famistudio_chn_note
fs_chn_instru   equ $0267  ; famistudio_chn_instrument
fs_song_spd     equ $026b  ; famistudio_song_speed
fs_chn_repeat   equ $026c  ; famistudio_chn_repeat
arr30           equ $0271
arr31           equ $0276
fs_chn_ref_len  equ $027b  ; famistudio_chn_ref_len
arr33           equ $0280
fs_chn_env_ovr  equ $0285  ; famistudio_chn_env_override
arr35           equ $028a
arr36           equ $028f
arr37           equ $0294
fs_tem_adv_row  equ $029b  ; famistudio_tempo_advance_row
fs_pal_adj      equ $029c  ; famistudio_pal_adjust
fs_songlist_lo  equ $029d  ; famistudio_song_list_lo
fs_songlist_hi  equ $029e  ; famistudio_song_list_hi
fs_instru_lo    equ $029f  ; famistudio_instrument_lo
fs_instru_hi    equ $02a0  ; famistudio_instrument_hi
fs_dpcm_lo      equ $02a1  ; famistudio_dpcm_list_lo
fs_dpcm_hi      equ $02a2  ; famistudio_dpcm_list_hi
fs_dpcm_effect  equ $02a3  ; famistudio_dpcm_effect
fs_pulse1_prev  equ $02a4  ; famistudio_pulse1_prev
fs_pulse2_prev  equ $02a5  ; famistudio_pulse2_prev
ram61           equ $02a6
ram62           equ $02a7
ram63           equ $02a8
ram64           equ $02a9
ram65           equ $02aa
ram66           equ $02ab
ram67           equ $02ac
ram68           equ $02ad
ram69           equ $02ae
ram70           equ $02af
ram71           equ $02b0
ram72           equ $02b1
ram73           equ $02b2
arr38           equ $02b3
arr39           equ $02b4
arr40           equ $02b5
arr41           equ $02b6
arr42           equ $02b7
arr43           equ $02b8
arr44           equ $02b9
arr45           equ $02ba
arr46           equ $02bb
arr47           equ $02bc
arr48           equ $02bd
arr49           equ $02be
arr50           equ $02bf
arr51           equ $02c0
arr52           equ $02c1

sq1_vol         equ $4000
sq1_sweep       equ $4001
sq1_lo          equ $4002
sq1_hi          equ $4003
sq2_vol         equ $4004
sq2_sweep       equ $4005
sq2_lo          equ $4006
sq2_hi          equ $4007
tri_linear      equ $4008
tri_lo          equ $400a
tri_hi          equ $400b
noise_vol       equ $400c
noise_lo        equ $400e
noise_hi        equ $400f
dmc_freq        equ $4010
dmc_raw         equ $4011
dmc_start       equ $4012
dmc_len         equ $4013
snd_chn         equ $4015

FS_CHN_CNT      equ  5  ; FAMISTUDIO_NUM_CHANNELS
FS_DUTY_CYC_CNT equ  3  ; FAMISTUDIO_NUM_DUTY_CYCLES
FS_SLIDE_CNT    equ  4  ; FAMISTUDIO_NUM_SLIDES
FS_ENV_CNT      equ 11  ; FAMISTUDIO_NUM_ENVELOPES
FS_PIT_ENV_CNT  equ  3  ; FAMISTUDIO_NUM_PITCH_ENVELOPES
FS_ENV_VOL_OFF  equ  0  ; FAMISTUDIO_ENV_VOLUME_OFF
FS_ENV_NOTE_OFF equ  1  ; FAMISTUDIO_ENV_NOTE_OFF
FS_ENV_DUTY_OFF equ  2  ; FAMISTUDIO_ENV_DUTY_OFF
FS_CH0_ENVS     equ  0  ; FAMISTUDIO_CH0_ENVS
FS_CH1_ENVS     equ  3  ; FAMISTUDIO_CH1_ENVS
FS_CH2_ENVS     equ  6  ; FAMISTUDIO_CH2_ENVS
FS_CH3_ENVS     equ  8  ; FAMISTUDIO_CH3_ENVS
FS_NOI_SLI_IND  equ  3  ; FAMISTUDIO_NOISE_SLIDE_INDEX

                base $8000

fs_init         ; "famistudio_init"
                ; "reset APU, initialize sound engine with some music data"
                ; in:
                ;     A    = platform (0=PAL, other=NTSC)
                ;     YYXX = pointer to music data
                ; an entry point from outside
                ; called by: init
                ;
                stx fs_songlist_lo
                sty fs_songlist_hi
                stx fs_dat_ptr+0
                sty fs_dat_ptr+1
                tax
                beq +
                lda #97
+               sta fs_pal_adj
                jsr fs_stop
                ;
                ldy #1
                lda (fs_dat_ptr),y      ; music data
                sta fs_instru_lo
                iny
                lda (fs_dat_ptr),y      ; music data
                sta fs_instru_hi
                iny
                lda (fs_dat_ptr),y      ; music data
                sta fs_dpcm_lo
                iny
                lda (fs_dat_ptr),y      ; music data
                sta fs_dpcm_hi
                ;
                lda #$80
                sta fs_pulse1_prev
                sta fs_pulse2_prev
                ;
                lda #%00001111
                sta snd_chn
                lda #%10000000
                sta tri_linear
                lda #%00000000
                sta noise_hi
                lda #%00110000
                sta sq1_vol
                sta sq2_vol
                sta noise_vol
                lda #%00001000
                sta sq1_sweep
                sta sq2_sweep
                jmp fs_stop

fs_stop         ; "famistudio_music_stop"
                ; called by: fs_init, fs_play
                ;
                lda #0
                sta fs_song_spd
                sta fs_dpcm_effect
                ;
                ldx #0
set_channels    sta fs_chn_repeat,x
                sta fs_chn_instru,x
                sta fs_chn_note,x
                sta fs_chn_ref_len,x
                sta arr33,x
                sta fs_chn_env_ovr,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                lda #0
                inx
                cpx #FS_CHN_CNT
                bne set_channels
                ;
                ldx #0
-               sta arr37,x             ; set_duty_cycles
                inx
                cpx #FS_DUTY_CYC_CNT
                bne -
                ;
                ldx #0
-               sta arr22,x             ; set_slides
                inx
                cpx #FS_SLIDE_CNT
                bne -
                ;
                ldx #0
-               lda #<fs_dummy_env      ; set_envelopes
                sta fs_env_addr_lo,x
                lda #>fs_dummy_env
                sta fs_env_addr_hi,x
                lda #0
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                inx
                cpx #FS_ENV_CNT
                bne -
                ;
                ldx #0
-               lda #<fs_dum_pit_env    ; set_pitch_envelopes
                sta fs_pit_env_ad_l,x
                lda #>fs_dum_pit_env
                sta fs_pit_env_ad_h,x
                lda #0
                sta fs_pit_env_rep,x
                sta fs_pit_env_va_l,x
                sta fs_pit_env_va_h,x
                sta fs_pit_env_fiva,x
                lda #1
                sta fs_pit_env_ptr,x
                inx
                cpx #FS_PIT_ENV_CNT
                bne -
                ;
                jmp fs_sample_stop

fs_play         ; "famistudio_music_play"; called by: init
                ; an entry point from outside, at start + $00dd
                ;
                ldx fs_songlist_lo
                stx fs_dat_ptr+0
                ldx fs_songlist_hi
                stx fs_dat_ptr+1
                ldy #0
                cmp (fs_dat_ptr),y      ; music data
                bcc +
                rts                     ; $80ed (unaccessed)
+               asl a
                sta fs_dat_ptr+0
                asl a
                tax
                asl a
                adc fs_dat_ptr+0
                stx fs_dat_ptr+0
                adc fs_dat_ptr+0
                adc #$05
                tay
                lda fs_songlist_lo
                sta fs_dat_ptr+0
                jsr fs_stop
                ;
                ldx #0
-               lda (fs_dat_ptr),y      ; music data
                sta arr25,x
                iny
                lda (fs_dat_ptr),y      ; music data
                sta arr26,x
                iny
                lda #0
                sta fs_chn_repeat,x
                sta fs_chn_instru,x
                sta fs_chn_note,x
                sta fs_chn_ref_len,x
                lda #$f0
                sta arr33,x
                lda #$ff
                sta arr35,x
                sta arr36,x
                inx
                cpx #FS_CHN_CNT
                bne -
                ;
                lda fs_pal_adj
                beq +
                iny
                iny
+               lda (fs_dat_ptr),y      ; music data
                sta arr37+3
                iny
                lda (fs_dat_ptr),y      ; music data
                sta arr37+4
                lda #$00
                sta arr37+5
                lda #$06
                sta arr37+6
                sta fs_song_spd
                rts

ucod1           ; unaccessed chunk ($8153)
                tax
                beq +
                jsr fs_sample_stop
                lda #0
                sta fs_env_value+0
                sta fs_env_value+3
                sta fs_env_value+6
                sta fs_env_value+8
                lda fs_song_spd
                ora #%10000000
                bne ++
+               lda fs_song_spd
                and #%01111111
++              sta fs_song_spd
                rts
                ; $8177

fs_get_pitch    ; "famistudio_get_note_pitch_macro"
                ; called by: fs_update
                ;
                clc
                lda fs_pit_env_fiva,y
                adc fs_pit_env_va_l,y
                sta ptr2+0
                lda fs_pit_env_fiva,y
                and #%10000000
                beq +
                lda #$ff
+               adc fs_pit_env_va_h,y
                sta ptr2+1
                lda arr22,y
                beq +

ucod2           ; unaccessed chunk ($8193)
                lda arr24,y
                cmp #$80
                ror a
                sta fs_temp
                lda arr23,y
                ror a
                clc
                adc ptr2+0
                sta ptr2+0
                lda fs_temp
                adc ptr2+1
                sta ptr2+1
                ; $81aa

+               clc
                lda fs_notes_lsb,x
                adc ptr2+0
                sta ptr2+0
                lda fs_notes_msb,x
                adc ptr2+1
                sta ptr2+1
                rts

fs_upd_row      ; "famistudio_update_row"
                ; called by: fs_upd_row_del
                ;
                jsr fs_upd_chan
                bcc +++
                txa
                tay
                ldx fs_chn_env,y
                lda fs_chn_instru,y
                cpy #$04
                bcc ++
                lda fs_chn_note+4
                bne +
                jsr fs_sample_stop      ; unaccessed ($81d0)
                ldx #$04                ; unaccessed
                bne +++                 ; unaccessed
+               jsr sub11
                ldx #$04
                jmp +++
++              jsr fs_set_instr
+++             rts

fs_upd_row_del  ; "famistudio_update_row_with_delays"
                ; called by: fs_update
                ;
                lda fs_tem_adv_row
                beq +
                lda arr35,x
                bmi ++
                lda #$ff                ; unaccessed ($81ed)
                sta arr35,x             ; unaccessed
                jsr fs_upd_row          ; unaccessed
                jmp ++                  ; unaccessed
+               lda arr35,x
                bmi +++
                sec
                sbc #1
                sta arr35,x
                bpl +++
++              jsr fs_upd_row
+++             lda arr36,x
                bmi +
                sec
                sbc #1                  ; unaccessed ($820d)
                sta arr36,x             ; unaccessed
                bpl +                   ; unaccessed
                lda #0                  ; unaccessed
                sta fs_chn_note,x       ; unaccessed
+               rts

fs_update       ; "famistudio_update"
                ; an entry point from outside, at start + $021b
                ; called by: nmi
                ;
                lda fs_dat_ptr+0
                pha
                lda fs_dat_ptr+1
                pha
                lda fs_song_spd
                bmi +
                bne ++
+               jmp cod10               ; unaccessed ($8228)
++              lda arr37+6
                cmp fs_song_spd
                ldx #$00
                stx fs_tem_adv_row
                bcc +
                sbc fs_song_spd
                sta arr37+6
                ldx #$01
                stx fs_tem_adv_row
                ;
+               ldx #0
-               jsr fs_upd_row_del
                inx
                cpx #FS_CHN_CNT
                bne -
                ;
                ldx #0
--              lda fs_env_repeat,x
                beq +
                dec fs_env_repeat,x
                bne +++
+               lda fs_env_addr_lo,x
                sta fs_dat_ptr+0
                lda fs_env_addr_hi,x
                sta fs_dat_ptr+1
                ;
                ldy fs_env_ptr,x
-               lda (fs_dat_ptr),y
                bpl +
                clc
                adc #64
                sta fs_env_value,x
                iny
                bne ++
+               bne +
                iny
                lda (fs_dat_ptr),y
                tay
                jmp -
                ;
+               iny
                sta fs_env_repeat,x
++              tya
                sta fs_env_ptr,x
+++             inx
                cpx #FS_ENV_CNT
                bne --
                ;
                ldx #$00
                jmp cod2

cod1            ; unaccessed chunk ($828e)
                ;
                lda fs_pit_env_rep,x
                sec
                sbc #1
                sta fs_pit_env_rep,x
                and #%01111111
                beq cod3
                ;
                lda fs_pit_env_ad_l,x
                sta fs_dat_ptr+0
                lda fs_pit_env_ad_h,x
                sta fs_dat_ptr+1
                ;
                ldy fs_pit_env_ptr,x
                dey
                dey
                lda (fs_dat_ptr),y
                clc
                adc #$40
                sta ram11
                clc
                adc fs_pit_env_va_l,x
                sta fs_pit_env_va_l,x
                ;
                lda ram11
                bpl +
                lda #$ff
+               adc fs_pit_env_va_h,x
                sta fs_pit_env_va_h,x
                jmp cod7
                ; $82c7

cod2            lda fs_pit_env_rep,x
                cmp #$81
                bcs cod1
                and #%01111111
                beq cod3
                dec fs_pit_env_rep,x
                bne cod7
                ;
cod3            lda fs_pit_env_ad_l,x
                sta fs_dat_ptr+0
                lda fs_pit_env_ad_h,x
                sta fs_dat_ptr+1
                ldy #0
                lda (fs_dat_ptr),y
                sta fs_temp
                ldy fs_pit_env_ptr,x
cod4            lda (fs_dat_ptr),y
                bpl cod5
                clc
                adc #$40
                bit fs_temp
                bmi ucod3
                sta fs_pit_env_va_l,x
                ora #%00000000
                bmi +
                lda #0
                jmp ++
+               lda #$ff
++              sta fs_pit_env_va_h,x
                iny
                jmp cod6

ucod3           ; unaccessed chunk ($830a)
                sta ram11
                clc
                adc fs_pit_env_va_l,x
                sta fs_pit_env_va_l,x
                lda ram11
                and #%10000000
                bpl +
                lda #$ff
+               adc fs_pit_env_va_h,x
                sta fs_pit_env_va_h,x
                iny
                jmp cod6
                ; $8325

cod5            bne +
                iny
                lda (fs_dat_ptr),y
                tay
                jmp cod4
+               iny
                ora fs_temp
                sta fs_pit_env_rep,x
cod6            tya
                sta fs_pit_env_ptr,x
cod7            inx
                cpx #FS_PIT_ENV_CNT
                bne cod2

                ldx #0                  ; update_slides
fs_slide_proc   lda arr22,x             ; slide_process
                beq fs_slide_next

ucod4           ; unaccessed chunk ($8344)
                clc
                lda arr22,x
                adc arr23,x
                sta arr23,x
                lda arr22,x
                and #%10000000
                beq fs_pos_slide
                lda #$ff                ; negative_slide
                adc arr24,x
                sta arr24,x
                bpl fs_slide_next
                jmp fs_clr_slide
fs_pos_slide    adc arr24,x             ; positive_slide
                sta arr24,x
                bmi fs_slide_next
fs_clr_slide    lda #0                  ; clear_slide
                sta arr22,x
                ; $836f

fs_slide_next   inx
                cpx #FS_SLIDE_CNT
                bne fs_slide_proc

cod10           lda fs_chn_note+0
                bne +
                jmp ++                  ; unaccessed ($8379)
+               clc
                adc fs_env_value+1
                clc
                adc fs_pal_adj
                tax
                ldy #$00
                jsr fs_get_pitch
                lda ptr2+0
                sta ram62
                lda ptr2+1
                sta ram63
                lda arr33
                ora fs_env_value+0+FS_ENV_VOL_OFF
                tax
                lda fs_volume_tbl,x
                ;
++              ldx fs_env_value+2
                ora fs_duty_lut,x
                sta ram61
                lda fs_chn_note+1
                bne +
                jmp ++
+               clc
                adc fs_env_value+4
                clc
                adc fs_pal_adj
                tax
                ldy #$01
                jsr fs_get_pitch
                lda ptr2+0
                sta ram65
                lda ptr2+1
                sta ram66
                lda arr33+1
                ora fs_env_value+3+FS_ENV_VOL_OFF
                tax
                lda fs_volume_tbl,x
                ;
++              ldx fs_env_value+5
                ora fs_duty_lut,x
                sta ram64
                lda fs_chn_note+2
                bne +
                jmp ++
+               clc
                adc fs_env_value+7
                clc
                adc fs_pal_adj
                tax
                ldy #$02
                jsr fs_get_pitch
                lda ptr2+0
                sta ram68
                lda ptr2+1
                sta ram69
                lda arr33+2
                ora fs_env_value+6+FS_ENV_VOL_OFF
                tax
                lda fs_volume_tbl,x
                ;
++              ora #%10000000
                sta ram67

                ; "famistudio_update_channel_sound"

                lda fs_chn_note+3
                bne fs_nocut            ; never taken
                jmp fs_set_volume

fs_nocut        ; unaccessed chunk ($8411)
                clc
                adc fs_env_value+9
                ldy arr22+3
                beq +
                sta fs_temp
                lda arr23+3
                sta ptr2+0
                lda arr24+3
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                ror ptr2+0
                cmp #$80
                ror a
                lda ptr2+0
                ror a
                ;
                clc
                adc fs_temp
                ;
+               and #%00001111          ; no_noise_slide
                eor #%00001111
                sta fs_temp
                ldx fs_env_value+10
                lda fs_duty_lut,x
                asl a
                and #%10000000
                ora fs_temp
                sta ram71
                lda arr33+3
                ora fs_env_value+8+FS_ENV_VOL_OFF
                tax
                lda fs_volume_tbl,x
                ; $845a

fs_set_volume   ldx fs_env_value+10
                ora fs_duty_lut,x
                ora #%11110000
                sta ram70
                lda fs_song_spd
                bmi +
                clc
                lda arr37+5
                adc arr37+3
                sta arr37+5
                lda arr37+6
                adc arr37+4
                sta arr37+6
                ;
+               ldx #$00
                jsr sub13
                ldx #$0f
                jsr sub13
                lda ram61
                sta sq1_vol
                lda ram62
                sta sq1_lo
                lda ram63
                cmp fs_pulse1_prev
                beq +
                sta fs_pulse1_prev
                sta sq1_hi
+               lda ram64
                sta sq2_vol
                lda ram65
                sta sq2_lo
                lda ram66
                cmp fs_pulse2_prev
                beq +
                sta fs_pulse2_prev
                sta sq2_hi
+               lda ram67
                sta tri_linear
                lda ram68
                sta tri_lo
                lda ram69
                sta tri_hi
                lda ram70
                sta noise_vol
                lda ram71
                sta noise_lo
                pla
                sta fs_dat_ptr+1
                pla
                sta fs_dat_ptr+0
                rts

fs_set_instr    ; "famistudio_set_instrument"
                ; called by: fs_upd_row
                ;
                sty ram11
                asl a
                tay
                lda fs_instru_hi
                adc #$00
                sta fs_dat_ptr+1
                lda fs_instru_lo
                sta fs_dat_ptr+0
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                iny
                sta fs_env_addr_hi,x
                inx
                stx ram12
                ldx ram11
                lda fs_chn_env_ovr,x
                lsr a
                ldx ram12
                bcc +
                iny                     ; unaccessed ($8509)
                jmp ++                  ; unaccessed
                ;
+               lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                ;
++              lda #$01
                sta arr13,x
                lda #0
                sta fs_env_value+10,x
                sta fs_env_repeat,x
                sta fs_env_ptr,x
                lda ram11
                cmp #$02
                bne +
                iny
                iny
                bne ++                  ; unconditional
                ;
+               inx
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                lda #0
                sta fs_env_repeat,x
                sta fs_env_ptr,x
                stx ram12
                ldx ram11
                lda fs_chn2duty,x
                tax
                lda arr37,x
                ldx ram12
                sta fs_env_value,x
                ;
++              ldx ram11
                lda fs_chn_env_ovr,x
                bmi +
                lda fs_chn2pit_env,x
                bmi +
                tax
                lda #$01
                sta fs_pit_env_ptr,x
                lda #0
                sta fs_pit_env_rep,x
                sta fs_pit_env_va_l,x
                sta fs_pit_env_va_h,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_l,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_h,x
                ;
+               ldx ram11
                rts

fs_upd_chan     ; "famistudio_update_channel"
                ; called by: fs_upd_row
                ;
                lda fs_chn_repeat,x
                beq +
                dec fs_chn_repeat,x
                clc
                rts
+               lda #$00
                sta ram12
                lda arr25,x
                sta fs_dat_ptr+0
                lda arr26,x
                sta fs_dat_ptr+1
                ldy #0
cod12           lda (fs_dat_ptr),y
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1
+               cmp #$61
                bcs +
                jmp cod13
+               ora #%00000000
                bpl +
                jmp cod14
+               cmp #$70
                bcc +
                and #%00001111
                asl a
                asl a
                asl a
                asl a
                sta arr33,x
                jmp cod12
+               stx fs_temp

                ; "jmp_to_opcode"
                and #%00001111
                tax
                lda fs_jmp_tbl_lo,x     ; jump to index X in jump table
                sta ptr2+0
                lda fs_jmp_tbl_hi,x
                sta ptr2+1
                ldx fs_temp
                jmp (ptr2)

fs_opcode2      stx fs_temp
                lda fs_chn2pit_env,x
                tax
                lda (fs_dat_ptr),y
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($85e3)
+               sta fs_pit_env_fiva,x
                ldx fs_temp
                jmp cod12

fs_clr_pitch    ; "opcode_clear_pitch_override_flag"
                lda #$7f
                and fs_chn_env_ovr,x
                sta fs_chn_env_ovr,x
                jmp cod12

fs_overr_pitch  ; "opcode_override_pitch_envelope"
                lda #$80
                ora fs_chn_env_ovr,x
                sta fs_chn_env_ovr,x
                stx fs_temp
                lda fs_chn2pit_env,x
                tax
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_l,x
                iny
                lda (fs_dat_ptr),y
                sta fs_pit_env_ad_h,x
                lda #0
                tay
                sta fs_pit_env_rep,x
                lda #1
                sta fs_pit_env_ptr,x
                ldx fs_temp
                clc
                lda #$02
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1        ; unaccessed ($8627)
+               jmp cod12

fs_clr_arp      ; "opcode_clear_arpeggio_override_flag" (unaccessed)
                lda #$fe
                and fs_chn_env_ovr,x
                sta fs_chn_env_ovr,x
                jmp cod12

fs_overr_arp    ; "opcode_override_arpeggio_envelope" (unaccessed)
                lda #$01
                ora fs_chn_env_ovr,x
                sta fs_chn_env_ovr,x
                stx fs_temp
                lda fs_chn2arp_env,x
                tax
                lda (fs_dat_ptr),y
                sta fs_env_addr_lo,x
                iny
                lda (fs_dat_ptr),y
                sta fs_env_addr_hi,x
                lda #0
                tay
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                ldx fs_temp
                clc
                lda #$02
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1
+               jmp cod12

fs_rst_arp      ; "opcode_reset_arpeggio" (unaccessed)
                stx fs_temp
                lda fs_chn2arp_env,x
                tax
                lda #0
                sta fs_env_repeat,x
                sta fs_env_value,x
                sta fs_env_ptr,x
                ldx fs_temp
                jmp cod12
                ; $8682

fs_opcode3      stx fs_temp
                lda fs_chn2duty,x
                tax
                lda (fs_dat_ptr),y
                sta arr37,x
                sta ram11
                ldx fs_temp
                lda fs_chn2dut_env,x
                tax
                lda ram11
                sta fs_env_value,x
                ldx fs_temp
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($86a0)
+               jmp cod12

fs_opcode4      lda (fs_dat_ptr),y
                sta arr35,x
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($86ae)
+               jmp cod17

fs_opcode5      ; unaccessed chunk ($86b3)
                lda #$40
                sta ram12
                lda (fs_dat_ptr),y
                sta arr36,x
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1
+               jmp cod12

fs_opcode1      ; unaccessed chunk
                lda #$80
                ora ram12
                sta ram12
                jmp cod12

                ; "noise_slide" (unaccessed)
-               lda (fs_dat_ptr),y
                iny
                sta arr22+3
                lda (fs_dat_ptr),y
                iny
                sec
                sbc (fs_dat_ptr),y
                sta arr23+3
                bpl +
                lda #$ff
                bmi ++
+               lda #0
++              asl arr23+3
                rol a
                asl arr23+3
                rol a
                asl arr23+3
                rol a
                asl arr23+3
                rol a
                sta arr24+3
                jmp +

fs_slide        ; "opcode_slide" (unaccessed)
                cpx #3
                beq -
                stx fs_temp
                lda fs_chn2slide,x
                tax
                lda (fs_dat_ptr),y
                iny
                sta arr22,x
                lda (fs_dat_ptr),y
                clc
                adc fs_pal_adj
                sta ram11
                iny
                lda (fs_dat_ptr),y
                ldy ram11
                adc fs_pal_adj
                stx ram11
                tax
                sec
                lda fs_notes_lsb,y
                sbc fs_notes_lsb,x
                sta ptr2+1
                lda fs_notes_msb,y
                sbc fs_notes_msb,x
                ldx ram11
                sta arr24,x
                lda ptr2+1
                asl a
                sta arr23,x
                rol arr24,x
                ldx fs_temp
                ldy #$02
+               lda (fs_dat_ptr),y      ; "slide_done_pos"?
                sta fs_chn_note,x
                clc
                lda #$03
                adc fs_dat_ptr+0
                sta fs_dat_ptr+0
                bcc +
                inc fs_dat_ptr+1
+               ldy #$00
                jmp +
                ; $8754

cod13           sta fs_chn_note,x
                ldy fs_chn2slide,x
                bmi +
                lda #0
                sta arr22,y
+               bit ram12
                bmi ++
                bvs +
                lda #$ff
                sta arr36,x
+               lda fs_chn_note,x
                beq ++
-               sec
                jmp cod16
++              cpx #4                  ; unaccessed ($8775)
                beq -                   ; unaccessed
                clc                     ; unaccessed
                jmp cod16               ; unaccessed
cod14           and #%01111111
                lsr a
                bcs ++
                asl a
                asl a
                sta fs_chn_instru,x
                jmp cod12
                ;
--              lda (fs_dat_ptr),y
                sta fs_song_spd
                inc fs_dat_ptr+0
                bne +
                inc fs_dat_ptr+1        ; unaccessed ($8793)
+               jmp cod12
                ;
-               lda (fs_dat_ptr),y
                sta fs_temp
                iny
                lda (fs_dat_ptr),y
                sta fs_dat_ptr+1
                lda fs_temp
                sta fs_dat_ptr+0
                dey
                jmp cod12
++              cmp #$3d
                beq --
                ;
                cmp #$3c
                beq ucod8
                bcc cod15
                cmp #$3e
                beq -
                ;
                clc
                lda fs_dat_ptr+0
                adc #$03
                sta arr30,x
                lda fs_dat_ptr+1
                adc #$00
                sta arr31,x
                lda (fs_dat_ptr),y
                sta fs_chn_ref_len,x
                iny
                lda (fs_dat_ptr),y
                sta fs_temp
                iny
                lda (fs_dat_ptr),y
                sta fs_dat_ptr+1
                lda fs_temp
                sta fs_dat_ptr+0
                ldy #$00
                jmp cod12

ucod8           ; unaccessed chunk ($87de)
                stx fs_temp
                lda fs_chn_env,x
                tax
                lda fs_env_addr_lo,x
                sta ptr2+0
                lda fs_env_addr_hi,x
                sta ptr2+1
                ldy #0
                lda (ptr2),y
                beq +
                sta fs_env_ptr,x
                lda #0
                sta fs_env_repeat,x
+               ldx fs_temp
                clc
                jmp cod16
                ; $8802

cod15           sta fs_chn_repeat,x
cod16           lda fs_chn_ref_len,x
                beq cod17
                dec fs_chn_ref_len,x
                bne cod17
                lda arr30,x
                sta arr25,x
                lda arr31,x
                sta arr26,x
                rts
cod17           lda fs_dat_ptr+0
                sta arr25,x
                lda fs_dat_ptr+1
                sta arr26,x
                rts

fs_jmp_tbl_lo   ; "famistudio_opcode_jmp_lo" (partially unaccessed)
                dl $2700
                dl fs_slide
                dl fs_opcode1
                dl fs_overr_pitch
                dl fs_clr_pitch
                dl fs_overr_arp
                dl fs_clr_arp
                dl fs_rst_arp
                dl fs_opcode2
                dl fs_opcode3
                dl fs_opcode4
                dl fs_opcode5
                dl fs_jmp_tbl_lo
                dl fs_jmp_tbl_lo
                ;
fs_jmp_tbl_hi   ; "famistudio_opcode_jmp_hi" (partially unaccessed)
                dh $2700
                dh fs_slide
                dh fs_opcode1
                dh fs_overr_pitch
                dh fs_clr_pitch
                dh fs_overr_arp
                dh fs_clr_arp
                dh fs_rst_arp
                dh fs_opcode2
                dh fs_opcode3
                dh fs_opcode4
                dh fs_opcode5
                dh fs_jmp_tbl_lo
                dh fs_jmp_tbl_lo
                hex 88

fs_sample_stop  ; "famistudio_sample_stop"
                ; called by: fs_stop, ucod1, fs_upd_row
                lda #%00001111
                sta snd_chn
                rts

                ldx #$01                ; unaccessed ($884a)
                stx fs_dpcm_effect      ; unaccessed

cod18           asl a
                asl a
                clc
                adc fs_dpcm_lo
                sta fs_dat_ptr+0
                lda #0
                adc fs_dpcm_hi
                sta fs_dat_ptr+1
                lda #%00001111
                sta snd_chn
                ldy #0
                lda (fs_dat_ptr),y
                sta dmc_start
                iny
                lda (fs_dat_ptr),y
                sta dmc_len
                iny
                lda (fs_dat_ptr),y
                sta dmc_freq
                iny
                lda (fs_dat_ptr),y
                sta dmc_raw
                lda #%00011111
                sta snd_chn
                rts

sub11           ; called by: fs_upd_row
                ;
                ldx fs_dpcm_effect
                beq cod18

ucod9           ; unaccessed chunk ($8887)
                tax
                lda snd_chn
                and #%00010000
                beq +
                rts
+               sta fs_dpcm_effect
                txa
                jmp cod18

                ; unaccessed chunk
                stx fs_dat_ptr+0
                sty fs_dat_ptr+1
                ldy #0
                lda fs_pal_adj
                bne +
                iny
                iny
+               lda (fs_dat_ptr),y
                sta ram72
                iny
                lda (fs_dat_ptr),y
                sta ram73
                ;
                ldx #0
-               jsr sub12
                txa
                clc
                adc #15
                tax
                cpx #30
                bne -
                ;
                rts

sub12           ; unaccessed chunk
                ; called by: sub11, sub12b
                lda #0
                sta arr40,x
                sta arr38,x
                sta arr41,x
                sta arr48,x
                lda #$30
                sta arr42,x
                sta arr45,x
                sta arr51,x
                rts

sub12b          ; unaccessed chunk
                asl a
                tay
                jsr sub12
                lda ram72
                sta fs_dat_ptr+0
                lda ram73
                sta fs_dat_ptr+1
                lda (fs_dat_ptr),y
                sta arr39,x
                iny
                lda (fs_dat_ptr),y
                sta arr40,x
                rts
                ; $88f3

sub13           ; called by: fs_update
                ;
                lda arr38,x
                beq +
                dec arr38,x             ; $88f8 (unaccessed)
                bne cod19               ; unaccessed
+               lda arr40,x
                bne ucod10
                rts

ucod10          ; unaccessed chunk ($8903)
                sta fs_dat_ptr+1
                lda arr39,x
                sta fs_dat_ptr+0
                ldy arr41,x
                clc
-               lda (fs_dat_ptr),y
                bmi ++
                beq +++
                iny
                bne +
                jsr sub14
+               sta arr38,x
                tya
                sta arr41,x
                jmp cod19
++              iny
                bne +
                jsr sub14
+               stx fs_temp
                adc fs_temp
                tax
                lda (fs_dat_ptr),y
                iny
                bne +
                stx ram11
                ldx fs_temp
                jsr sub14
                ldx ram11
+               sta fs_pit_env_va_l,x
                ldx fs_temp
                jmp -

                ; unaccessed chunk
+++             sta arr40,x
cod19           lda ram61
                and #%00001111
                sta fs_temp
                lda arr42,x
                and #%00001111
                cmp fs_temp
                bcc +
                lda arr42,x
                sta ram61
                lda arr43,x
                sta ram62
                lda arr44,x
                sta ram63
+               lda ram64
                and #%00001111
                sta fs_temp
                lda arr45,x
                and #%00001111
                cmp fs_temp
                bcc +
                lda arr45,x
                sta ram64
                lda arr46,x
                sta ram65
                lda arr47,x
                sta ram66
+               lda arr48,x
                beq +
                sta ram67
                lda arr49,x
                sta ram68
                lda arr50,x
                sta ram69
+               lda ram70
                and #%00001111
                sta fs_temp
                lda arr51,x
                and #%00001111
                cmp fs_temp
                bcc +
                lda arr51,x
                sta ram70
                lda arr52,x
                sta ram71
+               rts
                ; $89bd

sub14           ; called by: ucod10
                inc fs_dat_ptr+1
                inc arr40,x
                rts

fs_dummy_env    hex c0 7f 00 00         ; famistudio_dummy_envelope
fs_dum_pit_env  hex 00 c0 7f 00 01      ; famistudio_dummy_pitch_envelope

fs_notes_lsb    ; "famistudio_note_table_lsb" (partially unaccessed, $89cc)
                ; PAL
                hex 00
                hex 68 b6 0e 6f d9 4b c6 48 d1 60 f6 92  ; octave 0
                hex 34 db 86 37 ec a5 62 23 e8 b0 7b 49  ; octave 1
                hex 19 ed c3 9b 75 52 31 11 f3 d7 bd a4  ; octave 2
                hex 8c 76 61 4d 3a 29 18 08 f9 eb de d1  ; octave 3
                hex c6 ba b0 a6 9d 94 8b 84 7c 75 6e 68  ; octave 4
                hex 62 5d 57 52 4e 49 45 41 3e 3a 37 34  ; octave 5
                hex 31 2e 2b 29 26 24 22 20 1e 1d 1b 19  ; octave 6
                hex 18 16 15 14 13 12 11 10 0f 0e 0d 0c  ; octave 7
                ; NTSC
                hex 00
                hex 5b 9c e6 3b 9a 01 72 ea 6a f1 7f 13  ; octave 0
                hex ad 4d f3 9d 4c 00 b8 74 34 f8 bf 89  ; octave 1
                hex 56 26 f9 ce a6 80 5c 3a 1a fb df c4  ; octave 2
                hex ab 93 7c 67 52 3f 2d 1c 0c fd ef e1  ; octave 3
                hex d5 c9 bd b3 a9 9f 96 8e 86 7e 77 70  ; octave 4
                hex 6a 64 5e 59 54 4f 4b 46 42 3f 3b 38  ; octave 5
                hex 34 31 2f 2c 29 27 25 23 21 1f 1d 1b  ; octave 6
                hex 1a 18 17 15 14 13 12 11 10 0f 0e 0d  ; octave 7
                ;
fs_notes_msb    ; "famistudio_note_table_msb" (partially unaccessed, $8a8e)
                ; PAL
                hex 00
                hex 0c 0b 0b 0a 09 09 08 08 07 07 06 06  ; octave 0
                hex 06 05 05 05 04 04 04 04 03 03 03 03  ; octave 1
                hex 03 02 02 02 02 02 02 02 01 01 01 01  ; octave 2
                hex 01 01 01 01 01 01 01 01 00 00 00 00  ; octave 3
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 4
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 5
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 6
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 7
                ; NTSC
                hex 00
                hex 0d 0c 0b 0b 0a 0a 09 08 08 07 07 07  ; octave 0
                hex 06 06 05 05 05 05 04 04 04 03 03 03  ; octave 1
                hex 03 03 02 02 02 02 02 02 02 01 01 01  ; octave 2
                hex 01 01 01 01 01 01 01 01 01 00 00 00  ; octave 3
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 4
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 5
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 6
                hex 00 00 00 00 00 00 00 00 00 00 00 00  ; octave 7

fs_chn_env      ; "famistudio_channel_env"
                db FS_CH0_ENVS+FS_ENV_VOL_OFF
                db FS_CH1_ENVS+FS_ENV_VOL_OFF
                db FS_CH2_ENVS+FS_ENV_VOL_OFF
                db FS_CH3_ENVS+FS_ENV_VOL_OFF
                db $ff

fs_chn2arp_env  ; "famistudio_channel_to_arpeggio_env"
                db FS_CH0_ENVS+FS_ENV_NOTE_OFF
                db FS_CH1_ENVS+FS_ENV_NOTE_OFF
                db FS_CH2_ENVS+FS_ENV_NOTE_OFF
                db FS_CH3_ENVS+FS_ENV_NOTE_OFF
                db $ff

fs_chn2slide    ; "famistudio_channel_to_slide"
                db 0, 1, 2, FS_NOI_SLI_IND, $ff

fs_chn2pit_env  ; "famistudio_channel_to_pitch_env"
                db 0, 1, 2, $ff, $ff

fs_chn2duty     ; "famistudio_channel_to_dutycycle"
                db 0, 1, $ff, 2, $ff

fs_chn2dut_env  ; "famistudio_channel_to_duty_env"
                db FS_CH0_ENVS+FS_ENV_DUTY_OFF
                db FS_CH1_ENVS+FS_ENV_DUTY_OFF
                db $ff
                db FS_CH3_ENVS+FS_ENV_DUTY_OFF
                db $ff

fs_duty_lut     ; "famistudio_duty_lookup"
                hex 30 70 b0 f0

fs_volume_tbl   ; "famistudio_volume_table" ($8b72)
                hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                hex 00 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
                hex 00 01 01 01 01 01 01 01 01 01 01 01 02 02 02 02
                hex 00 01 01 01 01 01 01 01 02 02 02 02 02 03 03 03
                hex 00 01 01 01 01 01 02 02 02 02 03 03 03 03 04 04
                hex 00 01 01 01 01 02 02 02 03 03 03 04 04 04 05 05
                hex 00 01 01 01 02 02 02 03 03 04 04 04 05 05 06 06
                hex 00 01 01 01 02 02 03 03 04 04 05 05 06 06 07 07
                hex 00 01 01 02 02 03 03 04 04 05 05 06 06 07 07 08
                hex 00 01 01 02 02 03 04 04 05 05 06 07 07 08 08 09
                hex 00 01 01 02 03 03 04 05 05 06 07 07 08 09 09 0a
                hex 00 01 01 02 03 04 04 05 06 07 07 08 09 0a 0a 0b
                hex 00 01 02 02 03 04 05 06 06 07 08 09 0a 0a 0b 0c
                hex 00 01 02 03 03 04 05 06 07 08 09 0a 0a 0b 0c 0d
                hex 00 01 02 03 04 05 06 07 07 08 09 0a 0b 0c 0d 0e
                hex 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
