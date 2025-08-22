    jsr initialise

    move.l  #old_palette,a0         ; put backup address in a0
    movem.l $ff8240,d0-d7         ; all palettes in d0-d7
    movem.l d0-d7,(a0)              ; move data into old_palette

    movem.l picture+2,d0-d7 ;put picture palette in d0-d7
    movem.l d0-d7,$ff8240   ;set palette

    move.w  #2,-(a7)        ;get phybase
    trap    #14
    addq.l  #2,a7 

    move.l  d0,a0          ;put phybase in a0
    move.l  #picture+34,a1 ;a1 points to picture
    
    move.l  #7999,d0 

    bsr MUSIC               ;init music

draw_loop:
    move.l  (a1)+,(a0)+     ;move one longword to screen (draw the image)
    dbf     d0,draw_loop  

;VBLANK loop
frame:
    move.w  #37,-(a7)   ; wait VBL
    trap    #14
    addq.l  #2,a7 

    bsr MUSIC+$8 

    cmp.b    #$39,$fffc02   ;space pressed?
    bne      frame          

    move.l  #old_palette,a0
    movem.l ($a0),d0-d7 
    movem.l d0-d7,$ff8240

exit:
    jsr     restore

    jsr MUSIC+$4
    clr.l   -(a7)
    trap    #1
    
;------------------------------------------------------
;INITIALISE
initialise:
    clr.l   -(a7)           ; clear stack
    move.w  #32,-(a7)       ; prepare for super mode
    trap    #1              ; call gemdos
    addq.l  #6,a7           ; clear up stack
    move.l  d0,old_stack    ; backup old stack pointer
    rts 
;------------------------------------------------------

;------------------------------------------------------
;RESTORE
restore:
    move.l  old_stack,-(a7) ;restore old stack pt into a7
    move.w  #32,-(a7)       ;back to user mode
    trap    #1              ; call gemdos
    addq.l  #6,a7           ; clear up stack

    clr.l   -(a7)           ; clean exit
    trap    #1              ;call gemdos
    rts 
    
;---------------------------------------------------------
;DATA SECTION
old_stack: dc.l 0
old_palette: dc.l $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0

picture: incbin  data\logo.pi1
MUSIC:  incbin  data\DMACAFFE.SND            ; SNDH file to include (this one needs 50Hz replay)

