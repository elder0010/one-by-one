;
;       VBL replayer for unpacked SNDH files
;       Special example for Tobe and Gloky/MJJ
;
;       Depending on your tune - all timers now free ;)
;
;       gwEm 2005, 2006, 2013, 2019, 2020, 2021, 2024
;

        section text
;................................................................
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

        move.l  $70.w,oldvbl            ; store old VBL
        move.l  #vbl,$70.w              ; steal VBL

        bsr     MUSIC+0                 ; init music

        move.w  #7,-(sp)                ; wait for a key
        trap    #1                      ;
        addq.l  #2,sp                   ;

        bsr     MUSIC+4                 ; de-init music

        move.l  oldvbl,$70.w            ; restore VBL

        jsr restore

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
        bsr     MUSIC+8                 ; call music

        ;store d0-d7
        movem.l d0-d7,store_d0d7

;----------------------------------------------------------------
        ;time check - tick every 50 frames (1 second)
        move.w  time_frame,d0 
        dbf     d0,nosecond
        add.w   #$1,$ff8240
        move.w  #50,d0
nosecond:
        move.w  d0,time_frame
;----------------------------------------------------------------     

        ;restore d0-d7
        movem.l store_d0d7,d0-d7

        move.l  oldvbl(pc),-(sp)        ; go to old vector (system friendly ;) )
        rts

initialise:
        ;store old palette
        move.l  #old_palette,a0 
        movem.l $ff8240,d0-d7 
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
        movem.l d0-d7,$ff8240

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
        movem.l d0-d7,$ff8240   ;set palette

        move.w  #2,-(a7)        ;get phybase
        trap    #14
        addq.l  #2,a7 

        move.l  d0,a0          ;put phybase in a0
        move.l  #picture+34,a1 ;a1 points to picture

        move.l  #7999,d0
draw_loop:
        move.l  (a1)+,(a0)+     ;move one longword to screen (draw the image)
        dbf     d0,draw_loop  
        rts

oldvbl: ds.l    1
oldusp: ds.l    1


old_stack: dc.l     $0
old_palette: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
old_screen: dc.l    $0
old_resolution: dc.w $0

store_d0d7: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0

time_frame: dc.w    50

;................................................................
picture: incbin  data\logo2.pi1

MUSIC:  incbin  data\ONEBYONE.SND            ; SNDH file to include (this one needs 50Hz replay)
