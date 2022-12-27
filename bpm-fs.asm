; Famistudio at the start of bank 2.
; Only these subs are called from the outside: init, play, update
; Download "NES Sound Engine" from https://famistudio.org and see
; "famistudio_asm6.asm".

temp            equ $9f
temp_pitch      equ $a0    ; temp_pitch
temp_x          equ $a1    ; tmp_x
dat_ptr         equ $a2    ; data pointer (2 bytes)
ptr2            equ $a4    ; 2 bytes, overlaps
env_val         equ $0200  ; famistudio_env_value
env_rep         equ $020b  ; famistudio_env_repeat
env_adr_lo      equ $0216  ; famistudio_env_addr_lo
env_adr_hi      equ $0221  ; famistudio_env_addr_hi
env_ptr         equ $022c  ; famistudio_env_ptr
ptch_env_val_lo equ $0237  ; famistudio_pitch_env_value_lo
ptch_env_val_hi equ $023a  ; famistudio_pitch_env_value_hi
ptch_env_rep    equ $023d  ; famistudio_pitch_env_repeat
ptch_env_adr_lo equ $0240  ; famistudio_pitch_env_addr_lo
ptch_env_adr_hi equ $0243  ; famistudio_pitch_env_addr_hi
ptch_env_ptr    equ $0246  ; famistudio_pitch_env_ptr
ptch_env_fine   equ $0249  ; famistudio_pitch_env_fine_value
slide_step      equ $024c  ; famistudio_slide_step
slide_ptch_lo   equ $0250  ; famistudio_slide_pitch_lo
slide_ptch_hi   equ $0254  ; famistudio_slide_pitch_hi
chn_ptr_lo      equ $0258  ; famistudio_chn_ptr_lo
chn_ptr_hi      equ $025d  ; famistudio_chn_ptr_hi
chn_note        equ $0262  ; famistudio_chn_note
chn_instru      equ $0267  ; famistudio_chn_instrument
song_spd        equ $026b  ; famistudio_song_speed
chn_rep         equ $026c  ; famistudio_chn_repeat
chn_ret_lo      equ $0271  ; famistudio_chn_return_lo
chn_ret_hi      equ $0276  ; famistudio_chn_return_hi
chn_ref_len     equ $027b  ; famistudio_chn_ref_len
chn_vol_trk     equ $0280  ; famistudio_chn_volume_track
chn_env_ovr     equ $0285  ; famistudio_chn_env_override
chn_note_delay  equ $028a  ; famistudio_chn_note_delay
chn_cut_delay   equ $028f  ; famistudio_chn_cut_delay
duty_cycle      equ $0294  ; famistudio_duty_cycle
tempo_adv_row   equ $029b  ; famistudio_tempo_advance_row
pal_adj         equ $029c  ; famistudio_pal_adjust
songlist_lo     equ $029d  ; famistudio_song_list_lo
songlist_hi     equ $029e  ; famistudio_song_list_hi
instru_lo       equ $029f  ; famistudio_instrument_lo
instru_hi       equ $02a0  ; famistudio_instrument_hi
dpcm_list_lo    equ $02a1  ; famistudio_dpcm_list_lo
dpcm_list_hi    equ $02a2  ; famistudio_dpcm_list_hi
dpcm_effect     equ $02a3  ; famistudio_dpcm_effect
pulse1_prev     equ $02a4  ; famistudio_pulse1_prev
pulse2_prev     equ $02a5  ; famistudio_pulse2_prev
out_buf         equ $02a6  ; famistudio_output_buf
sfx_adr_lo      equ $02b1  ; famistudio_sfx_addr_lo
sfx_adr_hi      equ $02b2  ; famistudio_sfx_addr_hi
sfx_rep         equ $02b3  ; famistudio_sfx_repeat
sfx_ptr_lo      equ $02b4  ; famistudio_sfx_ptr_lo
sfx_ptr_hi      equ $02b5  ; famistudio_sfx_ptr_hi
sfx_ofs         equ $02b6  ; famistudio_sfx_offset
sfx_buf         equ $02b7  ; famistudio_sfx_buffer

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

CHN_CNT         equ  5  ; FAMISTUDIO_NUM_CHANNELS
DUTY_CYC_CNT    equ  3  ; FAMISTUDIO_NUM_DUTY_CYCLES
SLIDE_CNT       equ  4  ; FAMISTUDIO_NUM_SLIDES
ENV_CNT         equ 11  ; FAMISTUDIO_NUM_ENVELOPES
PTCH_ENV_CNT    equ  3  ; FAMISTUDIO_NUM_PITCH_ENVELOPES
ENV_VOL_OFF     equ  0  ; FAMISTUDIO_ENV_VOLUME_OFF
ENV_NOTE_OFF    equ  1  ; FAMISTUDIO_ENV_NOTE_OFF
ENV_DUTY_OFF    equ  2  ; FAMISTUDIO_ENV_DUTY_OFF
CHN0_ENVS       equ  0  ; FAMISTUDIO_CH0_ENVS
CHN1_ENVS       equ  3  ; FAMISTUDIO_CH1_ENVS
CHN2_ENVS       equ  6  ; FAMISTUDIO_CH2_ENVS
CHN3_ENVS       equ  8  ; FAMISTUDIO_CH3_ENVS
NOI_SLI_IND     equ  3  ; FAMISTUDIO_NOISE_SLIDE_INDEX

macro add _src
                clc
                adc _src
endm
macro sub _src
                sec
                sbc _src
endm
macro asr_a
                cmp #$80
                ror a
endm

                base $8000

init            ; "famistudio_init"
                ; "reset APU, initialize sound engine with some music data"
                ; in:
                ;     A    = platform (0=PAL, other=NTSC)
                ;     YYXX = pointer to music data
                ; an entry point from outside
                ; called by: main program init
                ;
                stx songlist_lo
                sty songlist_hi
                stx dat_ptr+0
                sty dat_ptr+1
                tax
                beq +
                lda #97
+               sta pal_adj
                jsr stop
                ;
                ldy #1
                lda (dat_ptr),y         ; music data
                sta instru_lo
                iny
                lda (dat_ptr),y         ; music data
                sta instru_hi
                iny
                lda (dat_ptr),y         ; music data
                sta dpcm_list_lo
                iny
                lda (dat_ptr),y         ; music data
                sta dpcm_list_hi
                ;
                lda #$80
                sta pulse1_prev
                sta pulse2_prev
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
                jmp stop

stop            ; "famistudio_music_stop"
                ; called by: init, play
                ;
                lda #0
                sta song_spd
                sta dpcm_effect
                ;
                ldx #0
set_channels    sta chn_rep,x
                sta chn_instru,x
                sta chn_note,x
                sta chn_ref_len,x
                sta chn_vol_trk,x
                sta chn_env_ovr,x
                lda #$ff
                sta chn_note_delay,x
                sta chn_cut_delay,x
                lda #0
                inx
                cpx #CHN_CNT
                bne set_channels
                ;
                ldx #0
-               sta duty_cycle,x        ; set_duty_cycles
                inx
                cpx #DUTY_CYC_CNT
                bne -
                ;
                ldx #0
-               sta slide_step,x        ; set_slides
                inx
                cpx #SLIDE_CNT
                bne -
                ;
                ldx #0
-               lda #<dummy_env         ; set_envelopes
                sta env_adr_lo,x
                lda #>dummy_env
                sta env_adr_hi,x
                lda #0
                sta env_rep,x
                sta env_val,x
                sta env_ptr,x
                inx
                cpx #ENV_CNT
                bne -
                ;
                ldx #0
-               lda #<dummy_ptch_env    ; set_pitch_envelopes
                sta ptch_env_adr_lo,x
                lda #>dummy_ptch_env
                sta ptch_env_adr_hi,x
                lda #0
                sta ptch_env_rep,x
                sta ptch_env_val_lo,x
                sta ptch_env_val_hi,x
                sta ptch_env_fine,x
                lda #1
                sta ptch_env_ptr,x
                inx
                cpx #PTCH_ENV_CNT
                bne -
                ;
                jmp sample_stop

play            ; "famistudio_music_play"
                ; an entry point from outside, at start + $00dd
                ; called by: main program init
                ;
                ldx songlist_lo
                stx dat_ptr+0
                ldx songlist_hi
                stx dat_ptr+1
                ldy #0
                cmp (dat_ptr),y         ; music data
                bcc +
                rts                     ; $80ed (unaccessed)
+               asl a
                sta dat_ptr+0
                asl a
                tax
                asl a
                adc dat_ptr+0
                stx dat_ptr+0
                adc dat_ptr+0
                adc #5
                tay
                lda songlist_lo
                sta dat_ptr+0
                jsr stop
                ;
                ldx #0
-               lda (dat_ptr),y         ; music data
                sta chn_ptr_lo,x
                iny
                lda (dat_ptr),y         ; music data
                sta chn_ptr_hi,x
                iny
                lda #0
                sta chn_rep,x
                sta chn_instru,x
                sta chn_note,x
                sta chn_ref_len,x
                lda #$f0
                sta chn_vol_trk,x
                lda #$ff
                sta chn_note_delay,x
                sta chn_cut_delay,x
                inx
                cpx #CHN_CNT
                bne -
                ;
                lda pal_adj
                beq +
                iny
                iny
+               lda (dat_ptr),y         ; music data
                sta duty_cycle+3
                iny
                lda (dat_ptr),y         ; music data
                sta duty_cycle+4
                lda #0
                sta duty_cycle+5
                lda #6
                sta duty_cycle+6
                sta song_spd
                rts

ucod1           ; unaccessed chunk ($8153)
                tax
                beq +
                jsr sample_stop
                lda #0
                sta env_val+0
                sta env_val+3
                sta env_val+6
                sta env_val+8
                lda song_spd
                ora #%10000000
                bne ++
+               lda song_spd
                and #%01111111
++              sta song_spd
                rts
                ; $8177

get_pitch       ; "famistudio_get_note_pitch_macro"
                ; called by: update
                ;
                clc
                lda ptch_env_fine,y
                adc ptch_env_val_lo,y
                sta ptr2+0
                lda ptch_env_fine,y
                and #%10000000
                beq +
                lda #$ff
+               adc ptch_env_val_hi,y
                sta ptr2+1
                lda slide_step,y
                beq +

ucod2           ; unaccessed chunk ($8193)
                lda slide_ptch_hi,y
                asr_a
                sta temp
                lda slide_ptch_lo,y
                ror a
                add ptr2+0
                sta ptr2+0
                lda temp
                adc ptr2+1
                sta ptr2+1
                ; $81aa

+               clc
                lda note_tbl_lsb,x
                adc ptr2+0
                sta ptr2+0
                lda note_tbl_msb,x
                adc ptr2+1
                sta ptr2+1
                rts

upd_row         ; "famistudio_update_row"
                ; called by: upd_row_delays
                ;
                jsr upd_chn
                bcc +++
                txa
                tay
                ldx chn_env,y
                lda chn_instru,y
                cpy #4
                bcc ++
                lda chn_note+4
                bne +
                jsr sample_stop         ; unaccessed ($81d0)
                ldx #4                  ; unaccessed
                bne +++                 ; unaccessed
+               jsr sub11
                ldx #4
                jmp +++
++              jsr set_instru
+++             rts

upd_row_delays  ; "famistudio_update_row_with_delays"
                ; called by: update
                ;
                lda tempo_adv_row
                beq +
                lda chn_note_delay,x
                bmi ++
                lda #$ff                ; unaccessed ($81ed)
                sta chn_note_delay,x    ; unaccessed
                jsr upd_row             ; unaccessed
                jmp ++                  ; unaccessed
+               lda chn_note_delay,x
                bmi +++
                sub #1
                sta chn_note_delay,x
                bpl +++
++              jsr upd_row
+++             lda chn_cut_delay,x
                bmi +
                sub #1                  ; unaccessed ($820d)
                sta chn_cut_delay,x     ; unaccessed
                bpl +                   ; unaccessed
                lda #0                  ; unaccessed
                sta chn_note,x          ; unaccessed
+               rts

update          ; "famistudio_update"
                ; an entry point from outside, at start + $021b
                ; called by: main program nmi
                ;
                lda dat_ptr+0
                pha
                lda dat_ptr+1
                pha
                lda song_spd
                bmi +
                bne ++
+               jmp cod10               ; unaccessed ($8228)
++              lda duty_cycle+6
                cmp song_spd
                ldx #0
                stx tempo_adv_row
                bcc +
                sbc song_spd
                sta duty_cycle+6
                ldx #1
                stx tempo_adv_row
                ;
+               ldx #0
-               jsr upd_row_delays
                inx
                cpx #CHN_CNT
                bne -
                ;
                ldx #0
--              lda env_rep,x
                beq +
                dec env_rep,x
                bne +++
+               lda env_adr_lo,x
                sta dat_ptr+0
                lda env_adr_hi,x
                sta dat_ptr+1
                ;
                ldy env_ptr,x
-               lda (dat_ptr),y
                bpl +
                add #64
                sta env_val,x
                iny
                bne ++
+               bne +
                iny
                lda (dat_ptr),y
                tay
                jmp -
                ;
+               iny
                sta env_rep,x
++              tya
                sta env_ptr,x
+++             inx
                cpx #ENV_CNT
                bne --
                ;
                ldx #0
                jmp cod2

cod1            ; unaccessed chunk ($828e)
                ;
                lda ptch_env_rep,x
                sub #1
                sta ptch_env_rep,x
                and #%01111111
                beq cod3
                ;
                lda ptch_env_adr_lo,x
                sta dat_ptr+0
                lda ptch_env_adr_hi,x
                sta dat_ptr+1
                ;
                ldy ptch_env_ptr,x
                dey
                dey
                lda (dat_ptr),y
                add #$40
                ;
                sta temp_pitch          ; pitch_relative
                clc
                adc ptch_env_val_lo,x
                sta ptch_env_val_lo,x
                lda temp_pitch
                bpl +
                lda #$ff
+               adc ptch_env_val_hi,x   ; pitch_relative_pos
                sta ptch_env_val_hi,x
                jmp cod7
                ; $82c7

cod2            lda ptch_env_rep,x
                cmp #$81
                bcs cod1
                and #%01111111
                beq cod3
                dec ptch_env_rep,x
                bne cod7
                ;
cod3            lda ptch_env_adr_lo,x
                sta dat_ptr+0
                lda ptch_env_adr_hi,x
                sta dat_ptr+1
                ldy #0
                lda (dat_ptr),y
                sta temp
                ldy ptch_env_ptr,x
cod4            lda (dat_ptr),y
                bpl cod5
                add #$40
                bit temp
                bmi ucod3
                sta ptch_env_val_lo,x
                ora #%00000000
                bmi +
                lda #0
                jmp ++
+               lda #$ff
++              sta ptch_env_val_hi,x
                iny
                jmp cod6

ucod3           ; unaccessed chunk ($830a)
                sta temp_pitch
                clc
                adc ptch_env_val_lo,x
                sta ptch_env_val_lo,x
                lda temp_pitch
                and #%10000000
                bpl +
                lda #$ff
+               adc ptch_env_val_hi,x
                sta ptch_env_val_hi,x
                iny
                jmp cod6
                ; $8325

cod5            bne +
                iny
                lda (dat_ptr),y
                tay
                jmp cod4
+               iny
                ora temp
                sta ptch_env_rep,x
cod6            tya
                sta ptch_env_ptr,x
cod7            inx
                cpx #PTCH_ENV_CNT
                bne cod2

                ldx #0                  ; update_slides
slide_proc      lda slide_step,x        ; slide_process
                beq slide_next

ucod4           ; unaccessed chunk ($8344)
                clc
                lda slide_step,x
                adc slide_ptch_lo,x
                sta slide_ptch_lo,x
                lda slide_step,x
                and #%10000000
                beq pos_slide
                lda #$ff                ; negative_slide
                adc slide_ptch_hi,x
                sta slide_ptch_hi,x
                bpl slide_next
                jmp clr_slide
pos_slide       adc slide_ptch_hi,x     ; positive_slide
                sta slide_ptch_hi,x
                bmi slide_next
clr_slide       lda #0                  ; clear_slide
                sta slide_step,x
                ; $836f

slide_next      inx
                cpx #SLIDE_CNT
                bne slide_proc

cod10           lda chn_note+0
                bne +
                jmp ++                  ; unaccessed ($8379)
+               add env_val+1
                add pal_adj
                tax
                ldy #0
                jsr get_pitch
                lda ptr2+0
                sta out_buf+1
                lda ptr2+1
                sta out_buf+2
                lda chn_vol_trk
                ora env_val+0+ENV_VOL_OFF
                tax
                lda vol_tbl,x
                ;
++              ldx env_val+2
                ora duty_tbl,x
                sta out_buf+0
                lda chn_note+1
                bne +
                jmp ++
+               add env_val+4
                add pal_adj
                tax
                ldy #1
                jsr get_pitch
                lda ptr2+0
                sta out_buf+4
                lda ptr2+1
                sta out_buf+5
                lda chn_vol_trk+1
                ora env_val+3+ENV_VOL_OFF
                tax
                lda vol_tbl,x
                ;
++              ldx env_val+5
                ora duty_tbl,x
                sta out_buf+3
                lda chn_note+2
                bne +
                jmp ++
+               add env_val+7
                add pal_adj
                tax
                ldy #2
                jsr get_pitch
                lda ptr2+0
                sta out_buf+7
                lda ptr2+1
                sta out_buf+8
                lda chn_vol_trk+2
                ora env_val+6+ENV_VOL_OFF
                tax
                lda vol_tbl,x
                ;
++              ora #%10000000
                sta out_buf+6

                ; "famistudio_update_channel_sound"

                lda chn_note+3
                bne nocut               ; never taken
                jmp set_volume

nocut           ; unaccessed chunk ($8411)
                add env_val+9
                ldy slide_step+3
                beq +
                sta temp
                lda slide_ptch_lo+3
                sta ptr2+0
                lda slide_ptch_hi+3
                asr_a
                ror ptr2+0
                asr_a
                ror ptr2+0
                asr_a
                ror ptr2+0
                asr_a
                lda ptr2+0
                ror a
                ;
                add temp
                ;
+               and #%00001111          ; no_noise_slide
                eor #%00001111
                sta temp
                ldx env_val+10
                lda duty_tbl,x
                asl a
                and #%10000000
                ora temp
                sta out_buf+10
                lda chn_vol_trk+3
                ora env_val+8+ENV_VOL_OFF
                tax
                lda vol_tbl,x
                ; $845a

set_volume      ldx env_val+10
                ora duty_tbl,x
                ora #%11110000
                sta out_buf+9
                lda song_spd
                bmi +
                clc
                lda duty_cycle+5
                adc duty_cycle+3
                sta duty_cycle+5
                lda duty_cycle+6
                adc duty_cycle+4
                sta duty_cycle+6
                ;
+               ldx #0
                jsr sub13
                ldx #$0f
                jsr sub13
                lda out_buf+0
                sta sq1_vol
                lda out_buf+1
                sta sq1_lo
                lda out_buf+2
                cmp pulse1_prev
                beq +
                sta pulse1_prev
                sta sq1_hi
+               lda out_buf+3
                sta sq2_vol
                lda out_buf+4
                sta sq2_lo
                lda out_buf+5
                cmp pulse2_prev
                beq +
                sta pulse2_prev
                sta sq2_hi
+               lda out_buf+6
                sta tri_linear
                lda out_buf+7
                sta tri_lo
                lda out_buf+8
                sta tri_hi
                lda out_buf+9
                sta noise_vol
                lda out_buf+10
                sta noise_lo
                pla
                sta dat_ptr+1
                pla
                sta dat_ptr+0
                rts

set_instru      ; "famistudio_set_instrument"
                ; called by: upd_row
                ;
                sty temp_pitch
                asl a
                tay
                lda instru_hi
                adc #0
                sta dat_ptr+1
                lda instru_lo
                sta dat_ptr+0
                lda (dat_ptr),y
                sta env_adr_lo,x
                iny
                lda (dat_ptr),y
                iny
                sta env_adr_hi,x
                inx
                stx temp_x
                ldx temp_pitch
                lda chn_env_ovr,x
                lsr a
                ldx temp_x
                bcc +
                iny                     ; unaccessed ($8509)
                jmp ++                  ; unaccessed
                ;
+               lda (dat_ptr),y
                sta env_adr_lo,x
                iny
                lda (dat_ptr),y
                sta env_adr_hi,x
                ;
++              lda #1
                sta env_ptr-1,x
                lda #0
                sta env_val+10,x
                sta env_rep,x
                sta env_ptr,x
                lda temp_pitch
                cmp #2
                bne +
                iny
                iny
                bne ++                  ; unconditional
                ;
+               inx
                iny
                lda (dat_ptr),y
                sta env_adr_lo,x
                iny
                lda (dat_ptr),y
                sta env_adr_hi,x
                lda #0
                sta env_rep,x
                sta env_ptr,x
                stx temp_x
                ldx temp_pitch
                lda chn_to_duty,x
                tax
                lda duty_cycle,x
                ldx temp_x
                sta env_val,x
                ;
++              ldx temp_pitch
                lda chn_env_ovr,x
                bmi +
                lda chn_to_ptch_env,x
                bmi +
                tax
                lda #1
                sta ptch_env_ptr,x
                lda #0
                sta ptch_env_rep,x
                sta ptch_env_val_lo,x
                sta ptch_env_val_hi,x
                iny
                lda (dat_ptr),y
                sta ptch_env_adr_lo,x
                iny
                lda (dat_ptr),y
                sta ptch_env_adr_hi,x
                ;
+               ldx temp_pitch
                rts

upd_chn         ; "famistudio_update_channel"
                ; called by: upd_row
                ;
                lda chn_rep,x
                beq +
                dec chn_rep,x
                clc
                rts
                ;
+               lda #0
                sta temp_x
                lda chn_ptr_lo,x
                sta dat_ptr+0
                lda chn_ptr_hi,x
                sta dat_ptr+1
                ldy #0
cod12           lda (dat_ptr),y
                inc dat_ptr+0
                bne +
                inc dat_ptr+1
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
                sta chn_vol_trk,x
                jmp cod12
+               stx temp

                ; "jmp_to_opcode"
                and #%00001111
                tax
                lda jmp_tbl_lo,x        ; jump to index X in jump table
                sta ptr2+0
                lda jmp_tbl_hi,x
                sta ptr2+1
                ldx temp
                jmp (ptr2)

opcode2         stx temp
                lda chn_to_ptch_env,x
                tax
                lda (dat_ptr),y
                inc dat_ptr+0
                bne +
                inc dat_ptr+1           ; unaccessed ($85e3)
+               sta ptch_env_fine,x
                ldx temp
                jmp cod12

clr_ptch_ovr    ; "opcode_clear_pitch_override_flag"
                lda #$7f
                and chn_env_ovr,x
                sta chn_env_ovr,x
                jmp cod12

ovr_ptch_env    ; "opcode_override_pitch_envelope"
                lda #$80
                ora chn_env_ovr,x
                sta chn_env_ovr,x
                stx temp
                lda chn_to_ptch_env,x
                tax
                lda (dat_ptr),y
                sta ptch_env_adr_lo,x
                iny
                lda (dat_ptr),y
                sta ptch_env_adr_hi,x
                lda #0
                tay
                sta ptch_env_rep,x
                lda #1
                sta ptch_env_ptr,x
                ldx temp
                clc
                lda #2
                adc dat_ptr+0
                sta dat_ptr+0
                bcc +
                inc dat_ptr+1           ; unaccessed ($8627)
+               jmp cod12

clr_arp_ovr     ; "opcode_clear_arpeggio_override_flag" (unaccessed)
                lda #$fe
                and chn_env_ovr,x
                sta chn_env_ovr,x
                jmp cod12

ovr_arp_env     ; "opcode_override_arpeggio_envelope" (unaccessed)
                lda #1
                ora chn_env_ovr,x
                sta chn_env_ovr,x
                stx temp
                lda chn_to_arp,x
                tax
                lda (dat_ptr),y
                sta env_adr_lo,x
                iny
                lda (dat_ptr),y
                sta env_adr_hi,x
                lda #0
                tay
                sta env_rep,x
                sta env_val,x
                sta env_ptr,x
                ldx temp
                clc
                lda #2
                adc dat_ptr+0
                sta dat_ptr+0
                bcc +
                inc dat_ptr+1
+               jmp cod12

rst_arp         ; "opcode_reset_arpeggio" (unaccessed)
                stx temp
                lda chn_to_arp,x
                tax
                lda #0
                sta env_rep,x
                sta env_val,x
                sta env_ptr,x
                ldx temp
                jmp cod12
                ; $8682

opcode3         stx temp
                lda chn_to_duty,x
                tax
                lda (dat_ptr),y
                sta duty_cycle,x
                sta temp_pitch
                ldx temp
                lda chn_to_duty_env,x
                tax
                lda temp_pitch
                sta env_val,x
                ldx temp
                inc dat_ptr+0
                bne +
                inc dat_ptr+1           ; unaccessed ($86a0)
+               jmp cod12

opcode4         lda (dat_ptr),y
                sta chn_note_delay,x
                inc dat_ptr+0
                bne +
                inc dat_ptr+1           ; unaccessed ($86ae)
+               jmp cod17

opcode5         ; unaccessed chunk ($86b3)
                lda #$40
                sta temp_x
                lda (dat_ptr),y
                sta chn_cut_delay,x
                inc dat_ptr+0
                bne +
                inc dat_ptr+1
+               jmp cod12

opcode1         ; unaccessed chunk
                lda #$80
                ora temp_x
                sta temp_x
                jmp cod12

                ; "noise_slide" (unaccessed)
-               lda (dat_ptr),y
                iny
                sta slide_step+3
                lda (dat_ptr),y
                iny
                sec
                sbc (dat_ptr),y
                sta slide_ptch_lo+3
                bpl +
                lda #$ff
                bmi ++
+               lda #0
++              asl slide_ptch_lo+3
                rol a
                asl slide_ptch_lo+3
                rol a
                asl slide_ptch_lo+3
                rol a
                asl slide_ptch_lo+3
                rol a
                sta slide_ptch_hi+3
                jmp +

slide           ; "opcode_slide" (unaccessed)
                cpx #3
                beq -
                stx temp
                lda chn_to_slide,x
                tax
                lda (dat_ptr),y
                iny
                sta slide_step,x
                lda (dat_ptr),y
                add pal_adj
                sta temp_pitch
                iny
                lda (dat_ptr),y
                ldy temp_pitch
                adc pal_adj
                stx temp_pitch
                tax
                sec
                lda note_tbl_lsb,y
                sbc note_tbl_lsb,x
                sta ptr2+1
                lda note_tbl_msb,y
                sbc note_tbl_msb,x
                ldx temp_pitch
                sta slide_ptch_hi,x
                lda ptr2+1
                asl a
                sta slide_ptch_lo,x
                rol slide_ptch_hi,x
                ldx temp
                ldy #2
+               lda (dat_ptr),y         ; "slide_done_pos"?
                sta chn_note,x
                clc
                lda #3
                adc dat_ptr+0
                sta dat_ptr+0
                bcc +
                inc dat_ptr+1
+               ldy #0
                jmp +
                ; $8754

cod13           sta chn_note,x
                ldy chn_to_slide,x
                bmi +
                lda #0
                sta slide_step,y
+               bit temp_x
                bmi ++
                bvs +
                lda #$ff
                sta chn_cut_delay,x
+               lda chn_note,x
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
                sta chn_instru,x
                jmp cod12
                ;
--              lda (dat_ptr),y
                sta song_spd
                inc dat_ptr+0
                bne +
                inc dat_ptr+1           ; unaccessed ($8793)
+               jmp cod12
                ;
-               lda (dat_ptr),y
                sta temp
                iny
                lda (dat_ptr),y
                sta dat_ptr+1
                lda temp
                sta dat_ptr+0
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
                clc                     ; opcode_set_reference
                lda dat_ptr+0
                adc #3
                sta chn_ret_lo,x
                lda dat_ptr+1
                adc #0
                sta chn_ret_hi,x
                lda (dat_ptr),y
                sta chn_ref_len,x
                iny
                lda (dat_ptr),y
                sta temp
                iny
                lda (dat_ptr),y
                sta dat_ptr+1
                lda temp
                sta dat_ptr+0
                ldy #0
                jmp cod12

ucod8           ; unaccessed chunk ($87de)
                stx temp
                lda chn_env,x
                tax
                lda env_adr_lo,x
                sta ptr2+0
                lda env_adr_hi,x
                sta ptr2+1
                ldy #0
                lda (ptr2),y
                beq +
                sta env_ptr,x
                lda #0
                sta env_rep,x
+               ldx temp
                clc
                jmp cod16
                ; $8802

cod15           sta chn_rep,x
cod16           lda chn_ref_len,x
                beq cod17
                dec chn_ref_len,x
                bne cod17
                lda chn_ret_lo,x
                sta chn_ptr_lo,x
                lda chn_ret_hi,x
                sta chn_ptr_hi,x
                rts
cod17           lda dat_ptr+0
                sta chn_ptr_lo,x
                lda dat_ptr+1
                sta chn_ptr_hi,x
                rts

jmp_tbl_lo      ; "famistudio_opcode_jmp_lo" (partially unaccessed)
                dl $2700
                dl slide
                dl opcode1
                dl ovr_ptch_env
                dl clr_ptch_ovr
                dl ovr_arp_env
                dl clr_arp_ovr
                dl rst_arp
                dl opcode2
                dl opcode3
                dl opcode4
                dl opcode5
                dl jmp_tbl_lo
                dl jmp_tbl_lo
                ;
jmp_tbl_hi      ; "famistudio_opcode_jmp_hi" (partially unaccessed)
                dh $2700
                dh slide
                dh opcode1
                dh ovr_ptch_env
                dh clr_ptch_ovr
                dh ovr_arp_env
                dh clr_arp_ovr
                dh rst_arp
                dh opcode2
                dh opcode3
                dh opcode4
                dh opcode5
                dh jmp_tbl_lo
                dh jmp_tbl_lo
                hex 88

sample_stop     ; "famistudio_sample_stop"
                ; called by: stop, ucod1, upd_row
                lda #%00001111
                sta snd_chn
                rts

                ldx #1                  ; unaccessed ($884a)
                stx dpcm_effect         ; unaccessed

cod18           asl a
                asl a
                add dpcm_list_lo
                sta dat_ptr+0
                lda #0
                adc dpcm_list_hi
                sta dat_ptr+1
                lda #%00001111
                sta snd_chn
                ldy #0
                lda (dat_ptr),y
                sta dmc_start
                iny
                lda (dat_ptr),y
                sta dmc_len
                iny
                lda (dat_ptr),y
                sta dmc_freq
                iny
                lda (dat_ptr),y
                sta dmc_raw
                lda #%00011111
                sta snd_chn
                rts

sub11           ; called by: upd_row
                ;
                ldx dpcm_effect
                beq cod18

ucod9           ; unaccessed chunk ($8887)
                tax
                lda snd_chn
                and #%00010000
                beq +
                rts
+               sta dpcm_effect
                txa
                jmp cod18

                ; unaccessed chunk
                stx dat_ptr+0
                sty dat_ptr+1
                ldy #0
                lda pal_adj
                bne +
                iny
                iny
+               lda (dat_ptr),y
                sta sfx_adr_lo
                iny
                lda (dat_ptr),y
                sta sfx_adr_hi
                ;
                ldx #0
-               jsr sfx_clr_chn
                txa
                add #15
                tax
                cpx #30
                bne -
                ;
                rts

sfx_clr_chn     ; "famistudio_sfx_clear_channel" (unaccessed)
                ; called by: sub11, sfx_play
                lda #0
                sta sfx_ptr_hi,x
                sta sfx_rep,x
                sta sfx_ofs,x
                sta sfx_buf+6,x
                lda #$30
                sta sfx_buf,x
                sta sfx_buf+3,x
                sta sfx_buf+9,x
                rts

sfx_play        ; "famistudio_sfx_play" (unaccessed)
                asl a
                tay
                jsr sfx_clr_chn
                ;
                lda sfx_adr_lo
                sta dat_ptr+0
                lda sfx_adr_hi
                sta dat_ptr+1
                ;
                lda (dat_ptr),y
                sta sfx_ptr_lo,x
                iny
                lda (dat_ptr),y
                sta sfx_ptr_hi,x
                ;
                rts
                ; $88f3

sub13           ; called by: update
                ;
                lda sfx_rep,x
                beq +
                dec sfx_rep,x           ; $88f8 (unaccessed)
                bne upd_buf             ; unaccessed
+               lda sfx_ptr_hi,x
                bne ucod10
                rts

ucod10          ; unaccessed chunk ($8903)
                sta dat_ptr+1
                lda sfx_ptr_lo,x
                sta dat_ptr+0
                ldy sfx_ofs,x
                clc
-               lda (dat_ptr),y
                bmi ++
                beq +++
                iny
                bne +
                jsr sub14
+               sta sfx_rep,x
                tya
                sta sfx_ofs,x
                jmp upd_buf
++              iny
                bne +
                jsr sub14
+               stx temp
                adc temp
                tax
                lda (dat_ptr),y
                iny
                bne +
                stx temp_pitch
                ldx temp
                jsr sub14
                ldx temp_pitch
+               sta ptch_env_val_lo,x
                ldx temp
                jmp -

+++             sta sfx_ptr_hi,x        ; unaccessed

                ; unaccessed chunk
upd_buf         lda out_buf+0           ; update_buf
                and #%00001111
                sta temp
                lda sfx_buf,x
                and #%00001111
                cmp temp
                bcc +
                lda sfx_buf,x
                sta out_buf+0
                lda sfx_buf+1,x
                sta out_buf+1
                lda sfx_buf+2,x
                sta out_buf+2
                ;
+               lda out_buf+3           ; no_pulse1
                and #%00001111
                sta temp
                lda sfx_buf+3,x
                and #%00001111
                cmp temp
                bcc +
                lda sfx_buf+3,x
                sta out_buf+3
                lda sfx_buf+4,x
                sta out_buf+4
                lda sfx_buf+5,x
                sta out_buf+5
                ;
+               lda sfx_buf+6,x         ; no_pulse2
                beq +
                sta out_buf+6
                lda sfx_buf+7,x
                sta out_buf+7
                lda sfx_buf+8,x
                sta out_buf+8
                ;
+               lda out_buf+9           ; no_triangle
                and #%00001111
                sta temp
                lda sfx_buf+9,x
                and #%00001111
                cmp temp
                bcc +
                lda sfx_buf+9,x
                sta out_buf+9
                lda sfx_buf+10,x
                sta out_buf+10
                ;
+               rts                     ; no_noise
                ; $89bd

sub14           ; called by: ucod10
                inc dat_ptr+1
                inc sfx_ptr_hi,x
                rts

dummy_env       hex c0 7f 00 00         ; famistudio_dummy_envelope
dummy_ptch_env  hex 00 c0 7f 00 01      ; famistudio_dummy_pitch_envelope

note_tbl_lsb    ; "famistudio_note_table_lsb" (partially unaccessed, $89cc)
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
note_tbl_msb    ; "famistudio_note_table_msb" (partially unaccessed, $8a8e)
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

chn_env         ; "famistudio_channel_env"
                db CHN0_ENVS+ENV_VOL_OFF
                db CHN1_ENVS+ENV_VOL_OFF
                db CHN2_ENVS+ENV_VOL_OFF
                db CHN3_ENVS+ENV_VOL_OFF
                db $ff

chn_to_arp      ; "famistudio_channel_to_arpeggio_env"
                db CHN0_ENVS+ENV_NOTE_OFF
                db CHN1_ENVS+ENV_NOTE_OFF
                db CHN2_ENVS+ENV_NOTE_OFF
                db CHN3_ENVS+ENV_NOTE_OFF
                db $ff

chn_to_slide    ; "famistudio_channel_to_slide"
                db 0, 1, 2, NOI_SLI_IND, $ff

chn_to_ptch_env ; "famistudio_channel_to_pitch_env"
                db 0, 1, 2, $ff, $ff

chn_to_duty     ; "famistudio_channel_to_dutycycle"
                db 0, 1, $ff, 2, $ff

chn_to_duty_env ; "famistudio_channel_to_duty_env"
                db CHN0_ENVS+ENV_DUTY_OFF
                db CHN1_ENVS+ENV_DUTY_OFF
                db $ff
                db CHN3_ENVS+ENV_DUTY_OFF
                db $ff

duty_tbl        ; "famistudio_duty_lookup"
                hex 30 70 b0 f0

vol_tbl         ; "famistudio_volume_table" ($8b72)
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
