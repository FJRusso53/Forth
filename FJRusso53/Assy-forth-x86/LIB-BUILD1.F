\ WORDS TO BE COMPILED DURING INITIALIZATION: 
( ANEW FORGET CTYPE WORDS DUMP PAUSE ALLOT '  
  HEX BINARY OCTAL ) 
0 value test1   \ TEST WORDS FOR LOADER 
variable test3  123 test3 !	
234 constant NULL1 
\ 
: GTN TEST3 @ NULL * 2 / 
\ 
: ANEW1
TIB BL WORD COUNT NEWHEADER 
GCFA NFA 4 - ! 
;
\ 
: FORGET1
TIB BL WORD COUNT FIND 
LFA @ DUP DUP @ LATEST ! DUP
DPR @ SWAP - SWAP DPR ! 
0 FILL DROP   
;
\ 
: CTYPE1 
BEGIN@ 
>R DUP C@ CMAX EMIT 1+ 
R> 1- DUP 
UNTIL@ DROP 
;
\ 
: WORDS1
PAD 160 ERASE
PAD HLD ! 0 TV1 ! LATEST @
BEGIN@
DUP 8 + DUP 1 + SWAP C@ DUP >R 
HLD @ SWAP CMOVE R>    
1 TV1 +!                   
16 SWAP - PAD ZCOUNT + SWAP
32 FILL                               
12 HLD +! TV1 @ 8 =
IF@
PAD ZCOUNT TYPE CR 100 PAUSE
0 TV1 ! PAD ZCOUNT 0 FILL
PAD HLD !
THEN@
@ DUP 0<> 
UNTIL@
TV1 @ 0 >
IF@
PAD ZCOUNT TYPE CR CR
0 TV1 ! PAD ZCOUNT 0 FILL
THEN@
;
\ 
: DUMP1
TV1 !  TV2 ! CR PAD HLD !
TV2 @ TV1 @ +     
BEGIN@ >R                               
HLD @ TV2 @ I2HEX
PAD ZCOUNT TYPE
SEP1 ZCOUNT TYPE
PAD ZCOUNT ERASE
4 BEGIN@ 
>R TV2 @ @ BEXT
4 BEGIN@ 
>R BTOH PAD ZCOUNT TYPE 32 EMIT
R> 1- DUP  
UNTIL@                                        
DROP TV2 DUP @ 4 + SWAP ! R> 1- DUP  
UNTIL@                                       
DROP SEP1 ZCOUNT TYPE 125 PAUSE
TV2 @ 16 - 16 CTYPE
SEP1 ZCOUNT TYPE CR 
R> DUP TV2 @ - 0GT 
UNTIL@                                       
DROP CR
;
\ 
: PAUSE1
MS +
BEGIN@
MS OVER > =0
UNTIL@
DROP
;
\ 
: ALLOT1 
DUP + 1000 + MEMQ <
IF@ 
DPR +! 0
THEN@ 
DROP
;
\ 
: '1 TIB BL WORD FIND ;
\ 
: HEX1 16 BASE ! ; 
\ 
: BINARY1 2 BASE ! ;
\ 
: OCTAL1 8 BASE ! ;
\ 
