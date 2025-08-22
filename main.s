    jsr initialise

    movem.l picture+2,d0-d7 ;put picture palette in d0-d7
    movem.l d0-d7,$ff8240   ;set palette

    move.w  #2,-(a7)        ;get phybase
    trap    #14
    addq.l  #2,a7 

    move.l  d0,a0          ;put phybase in a0
    move.l  #picture+34,a1 ;a1 points to picture
    
    move.l  #7999,d0 

loop:
    move.l  (a1)+,(a0)+      ;move one longword to screen
    dbf     d0,loop  

    move.w  #7,-(a7)         ;wait keypress
    trap    #1 
    addq.l  #2,a7

    jsr     restore


    clr.l   -(a7)
    trap    #1
    
initialise:
    ;------------------------------------------------------
    ;INITIALISE
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
    
    
old_stack: dc.l 0
old_palette: dc.l 0 

picture: incbin  data\logo.pi1