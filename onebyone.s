;
;       VBL replayer for unpacked SNDH files
;       Special example for Tobe and Gloky/MJJ
;
;       Depending on your tune - all timers now free ;)
;
;       gwEm 2005, 2006, 2013, 2019, 2020, 2021, 2024
;

PALETTE_BASE: equ $ff8240
W_PALETTE_00: equ PALETTE_BASE+0
W_PALETTE_01: equ PALETTE_BASE+2
W_PALETTE_02: equ PALETTE_BASE+4
W_PALETTE_03: equ PALETTE_BASE+6
W_PALETTE_04: equ PALETTE_BASE+8
W_PALETTE_05: equ PALETTE_BASE+10
W_PALETTE_06: equ PALETTE_BASE+12
W_PALETTE_07: equ PALETTE_BASE+14
W_PALETTE_08: equ PALETTE_BASE+16
W_PALETTE_09: equ PALETTE_BASE+18
W_PALETTE_10: equ PALETTE_BASE+20
W_PALETTE_11: equ PALETTE_BASE+22
W_PALETTE_12: equ PALETTE_BASE+24
W_PALETTE_13: equ PALETTE_BASE+26
W_PALETTE_14: equ PALETTE_BASE+28
W_PALETTE_15: equ PALETTE_BASE+30

BORDER_COLOUR_0: equ $245
BORDER_COLOUR_1: equ $262
BORDER_COLOUR_2: equ $454
BORDER_COLOUR_3: equ $447

LOGO_COLOUR_0: equ $256
LOGO_COLOUR_1: equ $545
LOGO_COLOUR_2: equ $046

;Colour palette mappings
;0 - 03
;1 - 02
;2 - 10
;3 - 13
BORDER_C0: equ W_PALETTE_05
BORDER_C1: equ W_PALETTE_07
BORDER_C2: equ W_PALETTE_08
BORDER_C3: equ W_PALETTE_11 

LOGO_C0: equ W_PALETTE_07
LOGO_C1: equ W_PALETTE_11
LOGO_C2: equ W_PALETTE_12
;LOGO_C3: equ W_PALETTE_13 


        section text
;................................................................
        ;jsr disable_mouse
        move.l  4(sp),a5                ; address to basepage
        move.l  $0c(a5),d0              ; length of text segment
        add.l   $14(a5),d0              ; length of data segment
        add.l   $1c(a5),d0              ; length of bss segment
        add.l   #$1000,d0               ; length of stackpointer
        add.l   #$100,d0                ; length of basepage
        move.l  a5,d1                   ; address to basepage
        add.l   d0,d1                   ; end of program
        and.l   #-2,d1                  ; make address even
        move.l  d1,sp                   ; new stackspace

        move.l  d0,-(sp)                ; mshrink()
        move.l  a5,-(sp)                ;
        move.w  d0,-(sp)                ;
        move.w  #$4a,-(sp)              ;
        trap    #1                      ;
        lea     12(sp),sp               ;  

        clr.l   -(sp)                   ; supervisor mode
        move.w  #$20,-(sp)              ;
        trap    #1                      ;
        addq.l  #6,sp                   ;
        move.l  d0,oldusp               ; store old user stack pointer

        jsr initialise

        jsr draw_img

        jsr get_time_addresses

        ;init timer to 00:00
        move.l  addr_minute_digit0,a0 
        jsr write_character
        move.l  addr_minute_digit1,a0 
        jsr write_character
        move.l  addr_second_digit0,a0 
        jsr write_character
        move.l  addr_second_digit1,a0 
        jsr write_character
        

        move.l  $70.w,oldvbl            ; store old VBL
        move.l  #vbl,$70.w              ; steal VBL

        jsr     MUSIC+0                 ; init music


frame:
        cmp.l   #50*60*3+18*50,global_timect
        beq     exit 

        cmp.b   #$39,$fffc02   ;space pressed?
        bne     frame         
        ;move.w  #7,-(sp)                ; wait for a key
        ;trap    #1                      ;
        ;addq.l  #2,sp                   ;

exit:
        jsr     MUSIC+4                 ; de-init music

        move.l  oldvbl,$70.w            ; restore VBL

        jsr restore

        ;jsr enable_mouse

        move.l  oldusp(pc),-(sp)        ; user mode
        move.w  #$20,-(sp)              ;
        trap    #1                      ;
        addq.l  #6,sp                   ;

        clr.w   -(sp)                   ; pterm()
        move.w  #$4c,-(sp)              ;
        trap    #1                      ;
;................................................................
vbl:    
        ;add.w   #-70,$ff8240
        jsr     MUSIC+8                 ; call music

        ;jsr     write_character
        ;store d0-d7
        movem.l d0-d7,store_d0d7
        movem.l a0-a7,store_a0a7

;----------------------------------------------------------------
        ;time check - tick every 50 frames (1 second)
        move.w  time_frame,d0 
        dbf     d0,nosecond
        ;https://nguillaumin.github.io/perihelion-m68k-tutorials/_on_fading_to_black.html
        
        ;every second increment second_digit_1
        move.l  elapsed_seconds_digit1,d0 
        add.l   #1,d0 
        cmpi.l  #10+26,d0
        bne noreset_second_digit1
        move.l  #26,d0
        addq.l  #1,can_inc_seconds_digit0
noreset_second_digit1:
        move.l  d0,character
        move.l  d0,elapsed_seconds_digit1
        move.l  addr_second_digit1,a0 
        jsr write_character
        move.w  #50,d0 ;50 frames per second
nosecond:
        move.w  d0,time_frame

        ;every 10 seconds increment second_digit_0
        move.l  can_inc_seconds_digit0,d0
        beq     noinc_second_digit0
        clr.l   can_inc_seconds_digit0
        move.l  elapsed_seconds_digit0,d0 
        addi.l   #1,d0 
        ;;addq.l  #1,elapsed_seconds_digit0
        cmpi.l  #6+26,d0 
        bne     noreset_second_digit0
        addq.l  #1,can_inc_minutes_digit1
        move.l  #26,d0 
noreset_second_digit0: 
        move.l  d0,elapsed_seconds_digit0
        move.l  d0,character 
        move.l  addr_second_digit0,a0 
        jsr     write_character
noinc_second_digit0:

        ;every 59 seconds increment minute_digit_1 
        move.l  can_inc_minutes_digit1,d0 
        beq     no_inc_minute_digit_1
        clr.l   can_inc_minutes_digit1
        move.l  elapsed_minutes_digit1,d0 
        addi.l  #1,d0 
        cmpi.l  #10+26,d0 
        bne     noreset_minute_digit1
        move.l  #26,d0 
noreset_minute_digit1:
        move.l  d0,character
        move.l  d0,elapsed_minutes_digit1
        move.l  addr_minute_digit1,a0 
        jsr write_character
;-----------------------------------------------------------------
no_inc_minute_digit_1:
        move.w  time_colour_cycle_border,d0 
        dbf     d0,nocycle_border
        bsr     cycle_colours_border
        move.w  #4,d0 
nocycle_border:
        move.w  d0,time_colour_cycle_border


        move.w  time_colour_cycle_logo,d0 
        dbf     d0,nocycle_logo
      ;  bsr     cycle_colours_logo
        move.w  #4,d0 
nocycle_logo:
        move.w  d0,time_colour_cycle_logo
;----------------------------------------------------------------   


      ;; add.l #$a0,$ff8240
        addi.l  #1,global_timect


        ;restore d0-d7
        movem.l store_d0d7,d0-d7
        movem.l store_a0a7,a0-a7

        move.l  oldvbl(pc),-(sp)        ; go to old vector (system friendly ;) )
        rts

initialise:
        ;store old palette
        move.l  #old_palette,a0 
        movem.l PALETTE_BASE,d0-d7 
        movem.l d0-d7,(a0)

        ;store old screen 
        move.w  #2,-(a7)        ;get phybase
        trap    #14
        addq.l  #2,a7 
        move.l  d0,old_screen

        ;store old resolution
        move.w  #4,-(a7)
        trap    #14
        addq.l  #2,a7 
        move.w  d0,old_resolution

        ;set low resolution
        move.w  #0,-(a7)    ;low resolution
        move.l  #-1,-(a7)   ;keep physbase
        move.l  #-1,-(a7)   ;keep logbase
        move.w  #5,-(a7)    ;change screen
        trap    #14 
        add.l   #12,a7
        rts

restore:
        move.l  #old_palette,a0
        movem.l (a0),d0-d7
        movem.l d0-d7,PALETTE_BASE

        ;restore old resolution and old screen
        move.w  old_resolution,d0 ;res in d0
        move.w  d0,-(a7)        ;push resolution
        move.l  old_screen,d0   ;screen in d0
        move.l  d0,-(a7)        ;push physbase
        move.l  d0,-(a7)        ;push logbase
        move.w  #5,-(a7)        ;change
        trap    #14
        add.l   #12,a7 
        rts 

draw_img:
        movem.l picture+2,d0-d7 ;put picture palette in d0-d7
        movem.l d0-d7,PALETTE_BASE   ;set palette

        move.w  #2,-(a7)        ;get phybase
        trap    #14
        addq.l  #2,a7 

        ;override colours that will be cycled 
        move.w #BORDER_COLOUR_0,BORDER_C0
        move.w #BORDER_COLOUR_1,BORDER_C1 
        move.w #BORDER_COLOUR_2,BORDER_C2 
        move.w #BORDER_COLOUR_3,BORDER_C3

        move.l  d0,a0          ;put phybase in a0
        move.l  #picture+34,a1 ;a1 points to picture

        move.l  #7999,d0
draw_loop:
        move.l  (a1)+,(a0)+     ;move one longword to screen (draw the image)
        dbf     d0,draw_loop  
        rts

        ;palette colours
        ;0 - 03
        ;1 - 02
        ;2 - 10
        ;3 - 13
cycle_colours_border:
        ;movem.l picture+2,d0-d7 ;put picture palette in d0-d7
        ;movem.l d0-d7,PALETTE_BASE

        move.b  frame_colour_cycle_border,d0
        addq.b  #1,d0 
        move.b  d0,frame_colour_cycle_border
        cmp.b   #1,d0
        bne     f1
f0: 
        move.w  #BORDER_COLOUR_0,BORDER_C0
        move.w  #BORDER_COLOUR_1,BORDER_C1 
        move.w  #BORDER_COLOUR_2,BORDER_C2 
        move.w  #BORDER_COLOUR_3,BORDER_C3

        rts 
f1:
        cmp.b   #2,d0 
        bne     f2
        move.w  #BORDER_COLOUR_1,BORDER_C0
        move.w  #BORDER_COLOUR_2,BORDER_C1 
        move.w  #BORDER_COLOUR_3,BORDER_C2 
        move.w  #BORDER_COLOUR_0,BORDER_C3
        rts
f2:
        cmp.b   #3,d0 
        bne     f3

        move.w  #BORDER_COLOUR_2,BORDER_C0
        move.w  #BORDER_COLOUR_3,BORDER_C1 
        move.w  #BORDER_COLOUR_0,BORDER_C2 
        move.w  #BORDER_COLOUR_1,BORDER_C3
        rts
f3:

        move.w  #BORDER_COLOUR_3,BORDER_C0
        move.w  #BORDER_COLOUR_0,BORDER_C1 
        move.w  #BORDER_COLOUR_1,BORDER_C2 
        move.w  #BORDER_COLOUR_2,BORDER_C3

        clr.w   frame_colour_cycle_border
        rts


cycle_colours_logo:
        ;movem.l picture+2,d0-d7 ;put picture palette in d0-d7
        ;movem.l d0-d7,PALETTE_BASE

        move.w  frame_colour_cycle_logo,d0
        addq.w  #1,d0 
        move.w  d0,frame_colour_cycle_logo
        cmp.w   #1,d0
        bne     f1l
f0l: 
        move.w  #LOGO_COLOUR_0,LOGO_C0
        move.w  #LOGO_COLOUR_1,LOGO_C1 
        move.w  #LOGO_COLOUR_2,LOGO_C2 


        rts 
f1l:
        cmp.w   #2,d0 
        bne     f2l
        move.w  #LOGO_COLOUR_1,LOGO_C0
        move.w  #LOGO_COLOUR_2,LOGO_C1 
        move.w  #LOGO_COLOUR_0,LOGO_C2 

        rts
f2l:
   

        move.w  #LOGO_COLOUR_2,LOGO_C0
        move.w  #LOGO_COLOUR_0,LOGO_C1 
        move.w  #LOGO_COLOUR_1,LOGO_C2 

        clr.w   frame_colour_cycle_logo
        rts



;a0 = target of the write
;character = char to write
write_character:
        ;move.l  minute_digit0,a0

       ; add.l   #8,a0 
    
        move.l  #charset+34,a3  ;points to charset start

        move.l  #font_lookup,a1 
        move.l  #character,a2 
        move.l  (a2),d0 ;fetch the actual value of character
        mulu    #4,d0   ;multiply by 4 (it's a longword)
        add.l   d0,a1   ;sum the char offset with the font lookup base address

        move.l  (a1),d0 ;now fetch the value in the lookup table
        add.l   d0,a3   ;add to the font base 

        ;write!
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        add.l   #160,a3 
        add.l   #160,a0
        move.b  (a3),(a0)
        move.b  2(a3),2(a0)
        rts


get_time_addresses:
        move.w  #2,-(a7)                ;get phybase
        trap    #14
        addq.l  #2,a7 
        move.l  d0,a0                   ;put phybase in a0
        add.l   #160*8*23+8*16,a0     ;offset  y 

        move.l  a0,addr_minute_digit0
        addq.l  #1,a0 

        move.l  a0,addr_minute_digit1

        addq.l  #8,a0 
        move.l  a0,addr_second_digit0

        addq.l  #7,a0 
        move.l  a0,addr_second_digit1
        rts 

disable_mouse:
        move.l  #mus_off,-(a7) ; pointer to IKBD instruction
        move.w  #0,-(a7)  ; length of instruction - 1
        move.w  #25,-(a7)               ; send instruction to IKBD
        trap    #14
        addq.l  #8,a7
        rts

enable_mouse:
        move.l  #mus_on,-(a7) ; pointer to IKBD instruction
        move.w  #0,-(a7)  ; length of instruction - 1
        move.w  #25,-(a7)               ; send instruction to IKBD
        trap    #14
        addq.l  #8,a7
        rts
;-----------------------------------------------------------------------
        section data

mus_off: dc.b    $12
mus_on: dc.b    $08

oldvbl: ds.l    1
oldusp: ds.l    1


old_stack: dc.l     $0
old_palette: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
old_screen: dc.l    $0
old_resolution: dc.w $0

store_d0d7: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
store_a0a7: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0 

time_frame: dc.w    50

time_colour_cycle_border: dc.w 4
time_colour_cycle_logo: dc.w 4

frame_colour_cycle_border: dc.b 0
frame_colour_cycle_logo: dc.b 0

;................................................................

MUSIC:  incbin  data\ONEBYONE.SND            ; SNDH file to include (this one needs 50Hz replay)

picture: incbin  data\logo_multi.pi1

charset: incbin data\charset_8x8.pi1

font_lookup: dc.l 0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73,80,81,88,89,96,97,104,105,112,113,120,121,128,129,136,137,144,145,152,153,160,161,168,169,176,177,184,185,192,193,200,201,208,209,216,217,224,225,232,233,240,241,248,249,256,257,264,265,272,273,280,281,288,289,296,297,304,305,312,313

character:      dc.l 26

addr_minute_digit0:  dc.l    $0
addr_minute_digit1:  dc.l    $0
addr_second_digit0:  dc.l    $0
addr_second_digit1:  dc.l    $0

can_inc_seconds_digit0: dc.l $0
can_inc_minutes_digit1: dc.l $0


elapsed_minutes_digit0:        dc.l   26 
elapsed_minutes_digit1:        dc.l   26

elapsed_seconds_digit0:        dc.l   26      ;26 is character "0"
elapsed_seconds_digit1:        dc.l   26      ;26 is character "0"

elapsed_minutes:        dc.l   26

global_timect:          dc.l    0