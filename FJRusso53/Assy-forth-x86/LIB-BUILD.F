\ UPDATED 231227
( WORDS TO BE COMPILED DURING INITIALIZATION:
 ANEW FORGET CTYPE WORDS DUMP PAUSE ALLOT '  
 HEX BINARY OCTAL LASTNFA IF -IF ELSE THEN ENDIF
 Z," PAUSE ."  
) 
\ **************
\ SPACE RESERVED FOR DEFINING VARIABLES, CONSTANTS AND VALUES
0 VALUE mgarptr
0 VALUE offsetptr
VARIABLE TV1
VARIABLE TV2
CREATE msgarr 32 4 * 16 + allot
\ **************
: BMARRAY   \ BUILD MESSAGE INDEX ARRAY 
USERBASE MESSAGES - PARSEINIT
mgarptr msgarr !
BEGIN@
4 +TO mgarptr
messages 0 parse
1+ +TO offsetptr DROP 
offsetptr msgarr mgarptr + !
messages offsetptr + C@
0=
UNITL@
;
\
\  CONTROL WORDS 
: >MARK         ( -- addr )   HERE 0 , ;  \ mark a link for later resolution
: <MARK         ( -- addr )   HERE ;
: >RESOLVE      ( addr -- )   HERE CELL+ SWAP ! ;
: <RESOLVE      ( addr -- )   , ;
: IF     ?COMP HERE 2 CELLS - @ DUP ['] COMPILE =
         SWAP ['] LIT = OR 0=
         HERE CELL - @ ['] DUP = AND
         IF CELL NEGATE ALLOT COMPILE -?BRANCH
         ELSE COMPILE ?BRANCH
         THEN >MARK 2 ; IMMEDIATE
: -IF    ?COMP COMPILE -?BRANCH >MARK 2 ; IMMEDIATE
: THEN   ?COMP 2 ?PAIRS COMPILE _THEN >RESOLVE ; IMMEDIATE
: ENDIF  [COMPILE] THEN ; IMMEDIATE
: ELSE   ?COMP 2 ?PAIRS COMPILE BRANCH >MARK SWAP >RESOLVE 2 ; IMMEDIATE
\ 
: TI1   \  Interpreter
begin
  accept drop 
  begin
    poc zcount 0 fill
    tib bl word count find
    fflag @
    if
      execute
    else
      number emsg 
    then
    in @ s_len @ <>
   until
   0 in ! quit
   bye
until
exit
;
\ **************
: ANEW
TIB BL WORD COUNT NEWHEADER 
GCFA NFA 4 - ! 
;
\
: FORGET
TIB BL WORD COUNT FIND 
LFA @ DUP DUP @ LATEST ! DUP
DPR @ SWAP - SWAP DPR !
0 FILL DROP   
;
\
: CTYPE
BEGIN@
>R DUP C@ CMAX EMIT 1+
R> 1- DUP
UNTIL@ DROP
;
\
: ."         
TIB 34 WORD      \ PARSE INPUT STRING TIB " WORD
COUNT PAD SWAP        \ GET LENGTH
2DUP 2>R CMOVE 2R<    \ MOVE THE DATA IN THE TIB TO THE DATA AREA
TYPE 1 _IN @ + _IN !  \ INCREMENT THE _IN OFFSET
PAD ZCOUNT ERASE
; 
\
: WORDS
PAD 160 ERASE
PAD HLD ! 0 TV1 ! LATEST @
BEGIN@
DUP 9 + DUP 1 + SWAP C@ DUP >R 
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
: DUMP   ( ADDD, COUNT --- )
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
>R BTOH PAD ZCOUNT TYPE BL EMIT
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
: PAUSE
MS +
BEGIN@
MS OVER > =0
UNTIL@
DROP
;
\
: ALLOT 
DUP + 1000 + MEMQ <
IF@ 
DPR +! 0
THEN@ 
DROP
;
\
: ' TIB BL WORD FIND ;
\
: HEX 16 BASE ! ; 
\
: BINARY 2 BASE ! ;
\
: OCTAL 8 BASE ! ;
\
: FILE-EXIST         ; ( ADDR -- F )
80000000h OPEN-FILE SWAP DUP 0>
IF CLOSE-FILE DROP ELSE DROP THEN
;
\
: LASTNFA       \ (  -- NFA ) RETURNS NFA ADDRESS OF LAST WORD CREATED 
LAST 9 PLUS 
;
\
: Z,"	       ( -<string">- )  
34 PARSE 2DUP HERE SWAP CMOVE 
NIP DUP HERE + DPR ! 		   
0 C,  			\ null-terminated chars at here
;
\
