\
\ Beale Cypher  Adaptation by Frank Russo March 2018
\
\ Frank J. Russo
\ Version 1.1 200730
\ LAST Update 207030
\
Anew Beale-Cypher
\
Needs Resources.f
Include Beale.h
\ Include C:\Programming\Win32Forth\include\file-emit.f
\
\ \Private\Win32Forth\src\lib\
\
\ : current-dir$  ( -- a1 )       \ get the full path to the current directory
\
\ : $current-dir! ( a1 -- f1 )    \ a1 is a null terminated directory string
\
FALSE value Turnkey? \ set to TRUE if you want to create a turnkey application
only forth also definitions hidden also forth
\
RANDOM-INIT
\
\  *****************************************************************************
\  Subroutine Section
\  *****************************************************************************
\
: B-Term
bealbook{ dup zcount erase free drop
infile-buffer free drop
SOM dup EOM swap - erase
;
\
\ ********************************************************************************
\
: >string ( n a -- ) \ 180403
\ Converts numbers to counted string for output to a file
\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
 >r dup >r abs s>d <#  # # # # # # #s r> sign #>
 r@ char+ swap dup >r cmove r> r> c!
;
\
\  *****************************************************************************
\
: File-Mapping (  ---  )  ( 180427 )
0 to core-lines
file1 zcount r/w open-file not
\ check on opening status
if  \ successful opening
  dup to infile-ptr
  file-size 2drop to filesize1

\ Check for Free Mem vs Filesize
  filesize1 ?MEMCHK

  filesize1 1024 + malloc to d1$
  d1$ filesize1 erase
  d1$ filesize1 + to f1eof

\ Load Code Book in memory
  d1$ filesize1 1024 + infile-ptr read-file cr 2drop \ . .  s"  - Read-File Completed " type cr ( dup ?WINERROR drop)
   infile-ptr close-file drop

\ Map file in memory count # of lines in File
  d1$ filesize1
   begin
      0aH scan swap 1+ swap
      core-lines 1+ to core-lines
      over f1eof =
   until
   2drop

\ Build Index  bealbook{addr, len}
  core-lines 100 + field-size  * 1024 / 1+ 1024 * dup malloc to bealbook{
  bealbook{ swap erase
  d1$ filesize1
  core-lines 1 do
          over >r
           0aH scan
           over r> dup I field-size * bealbook{ + Line-Addr !
	   - I field-size * bealbook{ + Line-size C!
	   swap 1+ swap
       loop

  infile-ptr close-file drop
else s" Unable to open code book -- "  cr type .s cr
endif
sp0 @ sp! \ Reset the data stack
;
\
\  *****************************************************************************
\
\ : CODE SEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ *G Search the string specified by c-addr1 u1 for the (sub)string specified by c-addr2 u2.
\ ** If flag is true <> 0, a match was found at c-addr3 with u3 characters remaining.
\ ** If flag is false = 0 there was no match and c-addr3 is c-addr1 and u3 is u1.
\
\ ******************************************************************************
\
: B-L-1 (  --  )  \ 180410
   \ G = Start point / H = Hit/No Hit
   Bealbook{ g-startpt field-size * + dup @ swap line-size c@ ( addr len )
   e$ zcount search \ returns the address count flag \   Use SEARCH vs STRNDX  ***
   not
   if
     g-startpt 1+ to g-startpt 2drop
   else
      1 to Hits drop  \ b-check
   endif
;
\
\ ******************************************************************************
\
\ CODE SCAN ( adr len char -- adr' len' ) \ search first occurence of char "char" in string
\
\ ******************************************************************************
\
: B-token ( inbuffer, length, char --- count)
\ Counts # of elements seperated by Char ( 180515 )
to token1 0 to t
begin
   token1 scan
   t 1+ to t
   1- swap 1+ swap
   dup 0<
until
\ t 1- to t
2drop t
;
\
\  *****************************************************************************
\
: B-Locate (  ---  )
\ Locate Word in Code Book Update: 18518
x-SP  to g-startpt
0 to hits
0 to Line#
0 to page#
0 to r
0 to word#

begin
   B-L-1
   g-startpt core-lines = hits 1 = or
until

hits 0 =
if
 1 to g-startpt
   begin
     B-L-1
     g-startpt core-lines = hits 1 = or
   until
endif

hits 1 =
if
\ Calc code result ( -- ) \ 180427
   g-startpt line-key / to page#
   g-startpt page# line-key * - to Line#
   Bealbook{ g-startpt field-size * +  @  \ Locate word in line
   swap over - 32 b-token 1+ to word#

\  Assembly Code Word
   page# 10000 * line# 100 * word# + + to r
   g-startpt 1+ to x-sp
endif

hits 0 = if 0 to r endif

;
\
\  *****************************************************************************
\
: B-Code ( -- ) \ Codes Incomming text file Update: 180523
\
file3 zcount file-status
0= if file3 zcount r/w open-file else file3 zcount r/w create-file endif drop to outfile-ptr
1024 64 * malloc to outfile-buffer
outfile-buffer 1024 64 * erase
file2 zcount r/w open-file not \ infile count r/w open-file 0=  attempt to open input file r/w
if to infile-ptr
0 to f cr cr

	Begin \ Read in File to be coded/decoded
           T$ 256 erase B$ 1024 erase OF$ 64 erase
	   T$ 256 infile-ptr \ Buffer pointer
	   read-line 2drop dup dup f 1+ to f ( adr len fileid -- len eof ior )
	   to f2eof
	   If  T$ B$ rot cmove

\ Process Input Line
              B$ zcount 32 B-Token B$ swap  ( addr length 32 -- count )
              0 do
\                  locate word & extract
                   dup zcount 32 scan ( --- addr count) \ Locate char 32 space in string \ USE SCAN vs INSTRB ****
		   -rot 2dup swap - rot swap
\		   clear string preload space / load search word / add space to end --- _WORD_
		   E$ 1024 erase 32 E$ c! E$ 1+
		   swap cmove 1+ swap drop ( B$+  -- )
		   32 E$ zcount + c! \ s" going to B-Token" type cr
		   \ e$ zcount type cr
 	           B-Locate  \ s" return from b-token" type cr
		   a$ 16 erase r A$ >string
		   09 A$ zcount + c! 	   \ Add Tab char to end of data
		   A$ 1+ outfile-buffer zcount + 8 cmove
                   r  dup 0= if E$ zcount type drop cr else drop endif
		   \ Lc 1+ to Lc
		   \ Lc 6 = If 0 to Lc cr else 9 emit endif
              loop
	      msg6 zcount outfile-buffer zcount + swap cmove
	      09 outfile-buffer zcount + c!
	      drop
	    else drop
	    endif

        f2eof not

	Until
Outfile-Buffer zcount 2dup outfile-ptr write-line  drop erase \ output to Results file and clear buffer
infile-ptr close-file drop 0 to infile-ptr  \ close #2  Input Process File
outfile-ptr close-file drop 0 to outfile-ptr \ close #3  Results File
else
endif
\
;
\
\  *****************************************************************************
: B-Decode \ label decode 180523
\  *****************************************************************************
\
file3 zcount r/w open-file not \ infile count r/w open-file 0=  attempt to open input file r/w
if
  dup to infile-ptr file-size 2drop 1024 + dup \ get file size add 1024
  malloc to infile-buffer  \ create buffer
  infile-buffer swap erase \ zero buffer
  infile-buffer infile-ptr file-size 2drop infile-ptr read-file 2drop \ Load File into memory buffer for processing
  infile-ptr close-file drop \ close Input Process File
  infile-buffer to D2$  \ D2$ moving pointer in buffer
  infile-buffer zcount + to F2eof

\ process input file
  Begin
        D2$ 7 (NUMBER?) 2drop to r \ convert string to a number
	r 9999999 =
	If
	   cr  \ eol
	else
           r 0  >  \  If r = 0 then display a space (32) do not process
           if
              r 10000 / to Page# \ break number down to page, line and word
              r Page# 10000 *  - 100 /  to line#
              r Page# 10000 * line# 100 * + - to word#
              page# line-key * line# + to p1 \ Points to line in book where word is located
              Bealbook{ p1 field-size * + dup @ swap line-size c@  ( addr len ) \ gets address and length of line in book
              word# 1 do 32 scan swap 1+ swap loop ( addSt len ) over swap 32 scan drop \ addrstart addrend len
              over -  2dup type 47 scan 0 > if cr else drop endif
           else d2$ 6 - to d2$
           endif
           space
	endif
     d2$ 8 + to d2$
     F2eof d2$ - 0 <=
  Until

  infile-buffer zcount erase
else drop S" Input file not located" cr type cr

endif
\
\ if asc(t$(w)) = 47 then print else print t$(w), chr$(32); endif
;
\
\  *****************************************************************************
: Main-Routine \ Temporary staring point to test out sub modules.
\  *****************************************************************************
\
cls
s" *****************************************************************************" type cr
RANDOM-INIT
File-Mapping
RANDOM-INIT
core-lines RANDOM to x-SP //  x = Random starting point in core file
\
s" Start -- (0-1)  0 = code / 1 = decode " type key cr \ Get input single keystroke
48 - to code-flag
\ s" Enter a key -- # of lines per page generally 25 - 60  --  " type
\ t$ 3 accept cr T$ swap (NUMBER?) 2drop to line-key
\ line-key 25 < if 45 to line-key endif
core-lines line-key / 999 > if core-lines 999 / - 5 to line-key s" Key = "  type line-key . cr endif // Cannot have more than 999 pages
s" # of Core Lines = " type core-lines . s" Starting Point = " type x-SP . cr
s" *****************************************************************************" type cr
\
code-flag
   case
	0 of B-Code endof \ code the input file
        1 of B-Decode endof \ decode the input file
   endcase \ anything other than 0 or 1 basically aborts
\ sp0 @ sp! \ Reset the data stack
cr cr
s" *****************************************************************************" type cr
sp0 @ sp! \ Reset the data stack
\
B-Term
\
\  *****************************************************************************
;
\

