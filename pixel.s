    jsr initialise

    ;get phybase
    move.w  #2,-(a7) 
    trap    #14
    addq.l  #2,a7 
    move.l  d0,a0
    ;a0 contains phybase

    ;clear screen
    move.l  #7999,d0
clear_loop:
    clr.l   (a0)+ 
    dbf     d0,clear_loop

frame:
    move.w  #37,-(a7)       ; wait VBL
    trap    #14
    addq.l  #2,a7 

    cmp.b   #$39,$fffc02   ;space pressed?
    bne     frame
    
exit:
    jsr     restore

    clr.l   -(a7)
    trap    #1
    include initlib.s

;---------------------------------------------------------
;DATA SECTION
old_stack: dc.l 0