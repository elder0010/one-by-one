;------------------------------------------------------
;INITIALISE
initialise:
    clr.l   -(a7)           ; clear stack
    move.w  #32,-(a7)       ; prepare for super mode
    trap    #1              ; call gemdos
    addq.l  #6,a7           ; clear up stack
    move.l  d0,old_stack    ; backup old stack pointer
    
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
;------------------------------------------------------

;------------------------------------------------------
;RESTORE
restore:
    ;restore old palette
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

    move.l  old_stack,-(a7) ;restore old stack pt into a7
    move.w  #32,-(a7)       ;back to user mode
    trap    #1              ; call gemdos
    addq.l  #6,a7           ; clear up stack

    clr.l   -(a7)           ; clean exit
    trap    #1              ;call gemdos
    rts

old_stack: dc.l     $0
old_palette: dc.l   $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
old_screen: dc.l    $0
old_resolution: dc.w $0