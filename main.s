    jsr initialise

    movem.l picture+2,d0-d7 ;put picture palette in d0-d7
    movem.l d0-d7,$ff8240   ;set palette

    move.w  #2,-(a7)        ;get phybase
    trap    #14
    addq.l  #2,a7 

    move.l  d0,a0          ;put phybase in a0
    move.l  #picture+34,a1 ;a1 points to picture
    
    bsr MUSIC               ;init music
    
    move.l  #7999,d0
draw_loop:
    move.l  (a1)+,(a0)+     ;move one longword to screen (draw the image)
    dbf     d0,draw_loop  

;VBLANK loop
frame:
    move.w  #37,-(a7)       ; wait VBL
    trap    #14
    addq.l  #2,a7 

    bsr MUSIC+$8 

    cmp.b   #$39,$fffc02   ;space pressed?
    bne     frame          

exit:
    bsr MUSIC+$4 ;uninstall music player

    ;reset audio chip
    move.b  #7,$ff8800 ;channel A/B/C tone, noise + port A/B IO
    move.b  #$ff,$ff8802 ;channel A volume in d0

    jsr     restore

    clr.l   -(a7)
    trap    #1

    include initlib.s 

;---------------------------------------------------------
;DATA SECTION
picture: incbin  data\logo.pi1
MUSIC:  incbin  data\DMACAFFE.SND            ; SNDH file to include (this one needs 50Hz replay)

