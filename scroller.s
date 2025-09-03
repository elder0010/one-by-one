;image is 320x200 - we know that 16 pixels = 4 words in low res, so:
;320/16 = 20  split the line in blocks of 16 pixels
;20*4 = 80    each block is 4 words, so one line is 80 words (or 160 bytes)

;each char is 32 px high so for example char at (3,5) has an y offset of 
;char_y_offset = 3*(160*32) where 3 is the char "y" 
;keep in mind that each row of chars has 10 chars

;each char is 32 px wide so for example char at (3,5) as an x offset of 
;char_x_offset = 16*5
;because 32 pixels = 16 bytes (or 8 words)

;offset = char_y_offset + char_x_offset = 3*(160*32)+5*16 = 15540 bytes for the letter C (3,5)
    jsr initialise
    
    movem.l font+2,d0-d7 
    movem.l d0-d7,$ff8240   ;init palette 

    move.w  #2,-(a7)
    trap    #14
    addq.l  #2,a7
    move.l  d0,screen       ;store screen pointer

main:
    move.w  #37,-(a7)       ; wait VBL
    trap    #14
    addq.l  #2,a7 

    cmp     #0,font_counter ;check if new character in msg
    bne     has_character   ;if not, get new character 

    move.w  #2,font_counter ;reset font counter

    ;point new char in font
    move.l  message_pointer,a0  ;pointer to msg
    clr.l   d0
    move.b  (a0),d0             ;put ascii value in d0

    cmp     #0,d0 ;reached end?
    bne not_end
end:
    move.l  #message,message_pointer
    move.l  message_pointer,a0 
    clr.l   d0 
    move.b  (a0),d0 ;and put the message pointer in d0 
not_end:
    ;d0 contains a char address
    add.l   #1,message_pointer ;increment msg pointer
    
    add.b   #-$20,d0        ;align char to ASCII standard 
    divu    #10,d0          ;divide the ascii code by 10 - this puts the qutient in the lower word, ant the remainder in the higher word of d0

    move.w  d0,d1           ;d1 contains y (3)
    swap    d0              ;swap high and low words of d0 
    move.w  d0,d2           ;d2 contains x (5)

    ;now do the math 
    mulu    #16,d2          ;5*16
    mulu    #32,d1          ;32*3=96
    mulu    #160,d1       ;96*160

    move.l  #font+34,a0     ;put the font start in a0 

    ;combine x and y offset 
    add.l   d2,d1 
    ;add to the base address (font start)
    add.l    d1,a0           ;a0 has the address of the correct letter

    move.l  a0,font_address ;store it!

has_character:
    add.w   #-1,font_counter 

    move.l  screen,a0 
    move.l  screen,a1 
    move.l  font_address,a2 
    
    ;SCROLL PART 
    ;to make it easy we move the scroller by 16 px each time (8 words)
    
    ;a0 and a1 points to the start of the screen
    ;offset the a1 reg  
    ;by 8 bytes, which is 16 pixels (4 words!)
    add.l   #8,a1           
    ;now copy 32 lines 
    move.l  #31,d1 

  
    ;a2 points to char in the font
    move.l  #18,d0  ;we are shifting the content of the screen 16 px left.
                    ;we need to shift 304 pixels (skipping the last 16px column)
                    ;so the loop iterates 19 (18+1) times
scroll:
    move.w  (a1)+,(a0)+
    move.w  (a1)+,(a0)+
    move.w  (a1)+,(a0)+
    move.w  (a1)+,(a0)+ ;16 pixels moved
    dbf     d0,scroll   ;continue moving 16 pixels clusters

    move.l  #18,d0      ;reset looping counter 

    ;now copy 16 pixels of the char in the last 16px column of the screen
    move.w  (a2),(a0)+
    move.w  2(a2),(a0)+
    move.w  4(a2),(a0)+
    move.w  6(a2),(a0)+
    add.l   #8,a1       ;increment screen pointer by 8, align with a0

    add.l   #160,a2   ;next line of font 
    dbf     d1,scroll   ;do another line 

    add.l   #8,font_address ;move 16px forward in font 
space_check:
    cmp.b   #$39,$fffc02   ;space pressed?
    bne     main 

    jsr     restore 

    clr.l   -(a7)
    trap    #1


    include initlib.s 

    section data 
screen: dc.l $0

font_address: dc.l $0

font_counter: dc.w $0

message_pointer: dc.l message

font: incbin  data/charset.pi1

message:
    dc.b    "A  COOL  SCROLLER!    BUT  A  BIT  FAST, "
    dc.b    "  SCROLLING  16  PIXELS  EACH  VBL."
    dc.b    "    THAT'S 2.5 SCREENS EACH SECOND!"
    dc.b    "             "
    dc.b    0