    jsr initialise

    ;get phybase
    move.w  #2,-(a7) 
    trap    #14
    addq.l  #2,a7 
    move.l  d0,a0
    ;a0 contains phybase

    move.l  d0,phybase
    ;clear screen
    move.l  #7999,d0
clear_loop:
    clr.l   (a0)+ 
    dbf     d0,clear_loop

    move.l  phybase,a0 

    ;Well the 16bit value per color register is calculated as follows:
    ;red*256+green*16+blue
    ;each between 0 and 7
    ;7 on ST corresponds to 255 on PC, so to get an approximative colo on ST, divide each PC color 
    ;component by 32 to get the ST value.
    ;ST color 0x700 is PC RGB #ff0000 (HTML notation)

    ;now set palette
    move.w   #$000,$ff8240 ;0000 col0 (bg)       
    move.w   #$700,$ff8242 ;0001 col1 (red)
    move.w   #$070,$ff8244 ;0010 col2 (green)
    move.w   #$007,$ff8246 ;0011 col2 (blue)
    move.w   #$333,$ff8248 ;0100 col3 (gray)
    move.w   #$300,$ff824a ;0101 col4 (dark red)
    move.w   #$030,$ff824c ;0110 col5 (dark green)
    move.w   #$003,$ff824e ;0111 col6 (dark blue)
    move.w   #$142,$ff8250 ;1000 col7 (mid green)
    move.w   #$412,$ff8252 ;1001 col8 (mid red)
    move.w   #$124,$ff8254 ;1010 col9 (mid blue)
    
    ;first 16 pixels (a0 is phybase)
    ;read from bottom to top
    ;each subsequent word has the bit of the relative bitplane (00 01 10 11)
    move.w  #%1000000000000000,(a0)
    move.w  #%0100000000000001,2(a0)
    move.w  #%0000000000000000,4(a0)
    move.w  #%0000000000000001,6(a0)    

    ;advance 8 bytes, move to the next 16 pixels
    addq.l  #8,a0

    move.w  #%1000000000000000,(a0)
    move.w  #%0100000000000000,2(a0)
    move.w  #%0000000000000000,4(a0)
    move.w  #%0000000000000000,6(a0)
    
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
phybase:    dc.l 0 