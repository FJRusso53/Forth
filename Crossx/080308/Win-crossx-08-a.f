\ Win-Crossxref-08.F
\ Frank J. Russo
\ Version 5.0.1 080308
\
Needs NoConsole.f
Needs Resources.f

Anew Cross-Xref

false value turnkey?

include string.f
include file-emit.f

defer menubegin#
defer MenuClose-display#
defer menufileclose#
defer menufileopen#
defer xref-Window#
\
Decimal
\
1024 constant wfrec
0 value stacksize
0 value infile-ptr
0 value infile-buffer-ptr
0 value file-flag
0 value infile-len
0 value PReport
34 value quote
0 value temp1-ptr
0 value temp2-ptr
0 value temp3-ptr
0 value word-type
0 value workfile-ptr
0 value eof-ptr
0 value workfile-count
0 value var-table
0 value var-table-offset
0 value Def-table
0 value Def-table-offset
0 value hash-count
90 value nrcol#
34 value nrrow#
false value ?include
0 value include-ptr
0 value fileinuse
\ Variables
Variable nrvar
Variable nrdef
Variable nroccur 340 nroccur !
Variable linecount
Variable Tlinecount
Variable maxnrvar 1600 maxnrvar !
Variable bytes-read
Variable Inb-Len
Variable Line-len
Variable Line-offset
Variable temp3
Variable temp1
Variable plines
Variable file-count
\
0 nostack1
3 char+ field+ hashv    \ Hash value of the word concept 4 byte Word
3 char+ field+ dict-loc \ offset into dictionary
1 char+ field+ Hloc	\ table location
0 char+ field+ wleno    \ length of the word
dup 12 swap - +   	\ bytes reserved for growth
constant hash-size	\ element is 16 bytes in length
\
\ 40 bytes per name
0 nostack1
1 char+ field+ Occurances
0 char+ field+ wrdtype
1 char+ field+ diskaddress
0 char+ field+ nlength
29 char+ field+ dname
3 char+ field+ Dhash
constant table-size
\
0 nostack1
3 char+ field+ File-ptr
3 char+ field+ Filesize#
3 char+ field+ Bytread
3 char+ field+ FBuf-ptr
3 char+ field+ LnOffset
3 char+ field+ lncount
0 char+ field+ inclFile
constant include-size
\
Create file-names 1024 allot file-names 1024 erase
Create search-param 96 allot search-param 96 erase
Create workfile-buffer wfrec Allot workfile-buffer wfrec erase
Create line-buffer 512 Allot line-buffer 512 erase
Create file-name 127 Allot file-name 127 erase
Create temp-ptr-area 36 allot temp-ptr-area 36 erase
create temp1$ 8 allot temp1$ 8 erase
create w-display 10 80 * allot w-display 10 80 * erase
create QUOTE$ char " c,
create Incl-state include-size allot Incl-state include-size erase

\ Message Area
create msg1 z," Cross-Reference Utility"
create msg2 z," Version 5.01 - 080308"
create msg3 z," Developed by Frank J. Russo"
create msg4 z," Nr# of Variables Identified:      "
create msg5 z," Nr# of Definitions Identified:      "
create msg6 z," Nr# of Lines Processed:      "
create msg7 z," Nr# of Included Files: "
create msg8 z,"  - Completed"
create msg8A z," Word Name                  Occurances  Line #'s"
create msg9d z," Program Limitations - Maximum # of Definitions = 1600 and Variables = 1600"
create msg9e z,"         Tracks each variable / definition for a maximum of 1024 occurances"
create msg9f z,"         Naming lengths limited to 30 characters (Will be Truncated if longer)"
create msg10 z," Processing File - "
create msg13 z," Failure on opening file"
create msg15 z," Failure to load line into bufffer"
create msg16 z," Processing Line # - "
\
\ Following used by the display window
\
   0 value using98/NT?          \ are we running Windows98 or WindowsNT?
   0 value BrowseWindow
   0 value text-len             \ length of text
   0 value text-ptr             \ address of current text line
   0 value text-blen            \ total text buffer length

   0 value line-tbl             \ address of the line pointer table
   0 value line-cur             \ the current top screen line
   0 value line-last            \ the last file line
   0 value col-cur              \ the current left column

1000 value max-lines            \ initial maximum nuber of lines
 512 value max-cols             \ maximum width of text currently editing

  90 value screen-cols          \ default rows and columns at startup
  23 value screen-rows
create cur-filename max-path allot
\
\ ********************************************************************************
\
: CHANNEL ( row struc-size -< name >- )
\ Array code for Psi - En - Aud memory channel arrays.  Rewritten FJR 061118
 CREATE   ( Returns address of newly named channel. )
 dup ,    ( Stores size of rows from stack to array.)
 * MALLOC , ( Reserves given quantity of cells for array.)
 DOES>    ( member; row -- a-addr )
 Tuck @ * swap cell+ @ +
;
\
\ ********************************************************************************
24 hash-size CHANNEL hash{ ( Hash Table )
0 hash{ 1+ hash-size 24 * 1- erase
\ ***************************************************************************************
\
: hash-build ( Add Len -- )
-1 "#hash
1 +to hash-count
hash-count hash{ !
hash-count dup hash{ hloc W!
;
\ ********************************************************************************
\
: init-hash
\  Calc Hash Value
s" :OBJECT " 	hash-build
s" CALL " 	hash-build
s" CODE " 	hash-build
S" +Z," temp1$ swap cmove temp1$ zcount + quote swap c! temp1$ zcount
+ bl swap c! temp1$ zcount hash-build temp1$ 8 erase
s" ( " 		hash-build
s" : "  	hash-build
s" \ " 		hash-build
[char] . temp1$ c! [char] " temp1$ zcount + c! bl temp1$ zcount + c! temp1$ zcount hash-build temp1$ 8 erase
s" :M " 	hash-build
temp1$ [char] S swap c! temp1$ zcount + quote swap c! temp1$ zcount + bl swap c!
temp1$ zcount hash-build temp1$ 8 erase
s" INCLUDE " 	hash-build
S" +Z"  temp1$ swap cmove temp1$ zcount + quote swap c! temp1$ zcount
+ bl swap c! temp1$ zcount hash-build temp1$ 8 erase
S" Z,"  temp1$ swap cmove temp1$ zcount + quote swap c! temp1$ zcount
+ bl swap c! temp1$ zcount hash-build temp1$ 8 erase
s" CONSTANT " 	hash-build
s" FCONSTANT " 	hash-build
s" 2CONSTANT " 	hash-build
s" VARIABLE " 	hash-build
s" FVARIABLE " 	hash-build
s" 2VARIABLE " 	hash-build
s" :MENUITEM "	hash-build
s" CREATE " 	hash-build
s" NEEDS " 	hash-build
s" DEFER "	hash-build
s" VALUE " 	hash-build
;
\
\ ***************************************************************************************
\
: >string ( n a -- )
\ Converts numbers to counted string for output to a file
\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
 >r dup >r abs s>d <# #s r> sign #>
 r@ char+ swap dup >r cmove r> r> c!
;
\ ***************************************************************************************
\
: #line"        ( n1 -- a1 n2 ) \ get the address and length a1,n2 of line n1
                line-tbl swap 0max line-last min cells+ 2@ tuck - 2 - 0max ;
\
\ ***************************************************************************************

FileOpenDialog filelocate "X-Ref Utility - Select your input file :" "All Files|*.*|"

\ ***************************************************************************************
\
: Cxref-Fileclose

	file-flag
	  if
	    infile-ptr close-file to infile-ptr 0 to file-flag \ Close input file
	    file-name count erase 0 file-name !
	    w-display dup 9 80 * 18 + + 60 0 fill
	    file-flag enable: MenuBegin#
	    false enable: Menufileclose#
	  then
;
\ ***************************************************************************************
: Cxref-Mem-deallot
\ Release allocated memory
\ Arranged in order fromlast allocated to first
\
        text-ptr 	  ?dup if free drop then
	def-table         ?dup if free drop then
	var-table 	  ?dup if free drop then
	infile-buffer-ptr ?dup If free drop then
	line-tbl 	  ?dup if free drop then
	['] hash{ >body cell+ @   free drop
\
;
\ ***************************************************************************************
: Cxref-fileopen \ ( file name n -- )

0 to file-flag \ set default flag condition

dup not if drop count then ?dup \ check to see if a file was selected or cancel selected
if
  dup file-name ! file-name 1+ swap cmove 	\ get file name & save at file-name location
  file-name dup 1+ swap c@ r/o open-file 0=	\ attempt to open input file r/o read only
  if
\
    1 to file-flag
    1 file-count +! file-count @ to fileinuse \ success opening
    file-flag enable: MenuBegin#
    file-name count
    w-display 9 80 * 18 + + dup zcount erase
    swap cmove
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 *
    65535 min \ space to allocate for file buffer max of 64K
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    dup inb-len ! infile-buffer-ptr swap erase  \ clear space
    file-name count dup file-names zcount + dup >r ! r> 1+ swap cmove
\
  else 2drop 0 to file-flag   \ File open failure
  then
else drop
then
    file-flag enable: Menufileclose#
;
\ ***************************************************************************************
: cxref-mem-allot
\
    65535 malloc to Var-table \ Variable table holds 1820 names
\
\ table-size bytes per name
\ Occurances - 2
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27
\ hash - 4
\
   var-table 65535 erase \ clear space
\
   65535 malloc to Def-table \ Definition table holds 1820 names
\
\ table-size bytes per name
\
\ Occurances - 2
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27
\ hash - 4
\
   Def-table 65535 erase \ clear space
\
;
\ ***************************************************************************************
: center-page \ ( count --- offset - pixels)
\
	nrcol# 2/ char-width * \ Center of page
	swap   2/ char-width * -
\
;
\
\ ***************************************************************************************
\
: center-dertm \ ( count --- offset)
dup 2 / 40 swap -
;
\ ***************************************************************************************
: work-file-read
workfile-buffer wfrec 0 fill
workfile-buffer wfrec workfile-ptr read-file 2drop
;
\ ***************************************************************************************
: work-file-write
workfile-buffer wfrec workfile-ptr write-file drop
workfile-buffer wfrec 32 fill
;
\ ***************************************************************************************
: Title1
	cr 50 spaces .date 2 spaces .time cr cr
	cr msg10 zcount type file-name count type
	msg8 zcount type cr cr
	cr cr msg8A zcount type cr cr
;
\ ***************************************************************************************
: New-Page
   PReport 2 = plines @ 60 > and
   if
	Title1
	msg1 zcount center-dertm spaces type cr
	msg2 zcount center-dertm spaces type cr

." ____________________________________________________________________________________"
cr 11 plines !
  then
;
\ ***************************************************************************************
: test1
hash-count 1+ 1 cr
do
  i dup 3 .r 2 spaces hash{ @ . cr
loop
;
\ ***************************************************************************************
: test2
cr
nrvar @ dup 1 >
if
1 cr
do
  i dup 3 .r 2 spaces table-size * var-table + dup dname zcount type
  dhash @ 30 getxy nip gotoxy . cr
loop
else drop
then
;
\ ***************************************************************************************
: Title
	cls cr
	msg1 zcount center-dertm spaces type cr
	msg2 zcount center-dertm spaces type cr
	msg3 zcount center-dertm spaces type cr
	cr 50 spaces .date 2 spaces .time cr cr
;
\ ***************************************************************************************
: Initv
1 nrvar ! 1 nrdef ! 0 plines !
0 to temp1-ptr
0 to temp2-ptr
0 to word-type
0 to eof-ptr
0 to workfile-count
0 file-count !
1024 nroccur !
1600 maxnrvar !
0 linecount !
0 Tlinecount !
workfile-buffer wfrec 32 fill
line-buffer 512 erase
file-name 64 erase
temp-ptr-area 32 erase
temp1$ 8 erase
file-names 1024 erase
;
\ ***************************************************************************************
: Report-Sortv3 \ ( -- )

\ table-size bytes per name - record

\ Occurances - 2  -  Occurances limited to 1024
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 30
\ hash - 4

2 0 do  cr
	i 0=
		if nrvar var-table  \ First time though sort the Variable Table
		else nrdef def-table \ second time through sort the definition table
		then
	to str1 @ dup temp1 !
	1 >

	if
		temp-ptr-area to temp3-ptr
		str1 to temp1-ptr

		temp1 @ 1 do temp1 @ I temp1-ptr table-size + to temp2-ptr

			 do
				temp1-ptr 5 + 27 temp2-ptr 5 + 27 compare
				1 =

				if \ second item in list is smaller than first item
					temp1-ptr temp3-ptr table-size cmove
					temp2-ptr temp1-ptr table-size cmove
					temp3-ptr temp2-ptr table-size cmove
				then

				table-size +to temp2-ptr
			loop

			table-size +to temp1-ptr
		  loop

	then

loop
;
\ ***************************************************************************************
: Reportv3

0 plines !
Title  6 plines +!
cr msg10 zcount type
file-names count 2dup type
w-display 9 80 * 18 + + dup zcount erase swap cmove
msg8 zcount type cr cr
Msg4 zcount type nrvar @ 1- . cr
Msg5 zcount type nrdef @ 1- . cr
Msg6 zcount type Tlinecount @ . cr
file-count @ 1- ?dup
if
  file-names count +
  over Msg7 zcount type . cr
  swap 0 do
      dup count i over >r ."  " 65 + emit ."  - " type cr r> + 1+
    loop
drop
then
cr cr msg8A zcount type cr
." ____________________________________________________________________________________"
cr 11 plines +!
2 0 do  cr 1 plines +!
	i 0=
		if   var-table ." Variables:   ( " nrvar @ 1- . ." )" cr cr 2 plines +!
		else def-table ." Definitions: ( " nrdef @ 1- . ." )" cr cr 2 plines +!
		then
	to str1
	i 0=
		if nrvar   \ put # variable on stack
		else nrdef \ put # definitions on stack
		then
	@ dup 0>
	if
	 1 do
	      I table-size * str1 +
	      dup dname over nlength c@ dup >r type
	      27 r> - 2 + spaces
	      dup Occurances w@ dup 3 .r 6 spaces
	      swap diskaddress w@ wfrec *
	      0 workfile-ptr reposition-file drop
		\ read from disk file record containing the line #'s where name was found
		work-file-read
	      0 do
		  workfile-buffer i 3 * + dup c@ swap 1+ w@ swap
		  i 0> if i 8 /mod drop 0=  \ Looking for a multiples of 8

		          if cr 1 plines +! new-page 38 spaces then \ advance to next line
		       then
		  dup 1 = if drop bl else 63 + then emit
		  5 .r ."  "
		loop

		cr 1 plines +! new-page
	  loop
	else drop
	then
s" ____________________________________________________________________________________"
type cr 1 plines +! new-page
loop
;
\ ***************************************************************************************
: Skip-Spaces \ (addr len -- addr count)
\ s" Skip Spaces " type
swap to str1
0 swap 0 do
	   str1 c@ bl <>
	   if leave
	   else 1+
	   then
	   1 +to str1
         loop
str1 swap
;
\ ***************************************************************************************
: endofword \ ( addr -- addr N )
\ cr s" endofword" type
\ Looking for a space or CR ()OD
dup line-len @ line-offset @ - 0
do
  dup c@ 33 <
  if I swap leave then
  1+
loop
drop
;
\ ***************************************************************************************
: resword  \ ( Addr2 len2 -- addr2 Len2 F )

 2dup dup 1 = if 1+ then \ increase length by 1 to add space
-1 "#Hash
\ Search hash table for a match
hash-count 1+ 1

do
  dup i hash{ hashv @ over over
  = if 3drop i unloop exit ( i -1 leave) then
  swap > if 0 unloop exit ( leave) then
loop
0
( 0< if >r 3drop r> -1 else 0 then )
;
\ ***************************************************************************************
: varupdatev3  \ ( addr --- F)

\ table-size bytes per name
\ Occurances - 2
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 29
\ hash - 4
\ inclfile - 1

\ update table entry for # of occurances
dup dup w@ 1+ swap w!
\ read from file entry data
dup diskaddress w@ wfrec * 0 \ calc offset into file Locate # * wfrec (bytes / record)
\ reposition file pointer
workfile-ptr reposition-file drop
\ read in entry data
work-file-read
\ update line # in data
w@ \ # occurances including present
1 - 3 * \ 3 bytes per occurance
workfile-buffer + dup
fileinuse swap c! 1+
linecount @ swap w!
\ write file entry
workfile-ptr file-position 2drop wfrec - 0  \ back up to begining of last record read
workfile-ptr reposition-file
work-file-write drop
eof-ptr 0 workfile-ptr reposition-file \ go to end of file
drop
;
\ ***************************************************************************************
: Crx-search ( addr len hash tableaddr count -- addr len flag )
dup if
     1+ 1 do
	    2dup I table-size * + dhash @
	    = if nip I table-size * + -1 unloop exit ( 0 leave) then
	  loop
    else drop
    then
2drop 0
\ if 0 else -1 then
;
\ ***************************************************************************************
: LoadDefv3 \ ( addr Len -- addr len)
nrdef @ maxnrvar @ <
if
	to temp1-ptr
	to temp2-ptr
	1 +to workfile-count
	nrdef @ table-size * to def-table-offset  \ offset into the definition table
	1 def-table-offset def-table + c! \ save initial occurance
	word-type def-table-offset def-table + wrdtype c! 		\ Save word type
	workfile-count def-table-offset def-table + diskaddress W! 	\ Save disk location 2 bytes
	temp1-ptr def-table-offset def-table + nlength c! 		\ save length of name
	temp2-ptr def-table-offset def-table + dname temp1-ptr cmove 	\ Save name
	temp2-ptr temp1-ptr -1 "#hash
	def-table-offset def-table + dhash !				\ save name hash value
	\ write info to disk
	workfile-buffer dup fileinuse swap c! 1+
	linecount @ swap w!
	work-file-write
	workfile-ptr file-position 2drop to eof-ptr
	1 nrdef +!

else
	StartPos: xref-Window#
        200 + swap 200 + swap message-origin
        s" Maximum Nr of Definitions exceeded..." "message
        1000 ms message-off
then
;
\ ***************************************************************************************
: LoadVarv3 \ ( addr Len -- )
nrvar @ maxnrvar @ <
if
	to temp1-ptr
	to temp2-ptr
	1 +to workfile-count
	nrvar @ table-size * to var-table-offset   \ offset into the variable table
	1 var-table-offset var-table +  c! \ save initial occurance
	word-type var-table-offset var-table + wrdtype c! 	     \ Save word type
	workfile-count var-table-offset var-table + diskaddress W!   \ Save disk location 2 bytes
	temp1-ptr var-table-offset var-table + nlength c! 	     \ save length of name
	temp2-ptr var-table-offset var-table + dname temp1-ptr cmove \ Save name
	temp2-ptr temp1-ptr -1 "#hash
	var-table-offset var-table + dhash !
	\ write info to disk
	workfile-buffer dup fileinuse swap c! 1+
	linecount @ swap w!
	work-file-write
	workfile-ptr file-position 2drop to eof-ptr
	1 nrvar +!

else
	StartPos: xref-Window#
        200 + swap 200 + swap message-origin
        s" Maximum Nr of Variables exceeded..." "message
        1000 ms message-off
then
;
\ ***************************************************************************************
: New-Get \ (addr len -- Addr len)

+ line-len @ line-offset @ -
skip-spaces 1+ line-offset +!
endofword dup line-offset +!
\ check to see if name length is > 26
\ dup 26 >
\ if drop 26 then
;
\ **************************************************************************************
: GotComment2 \ (addr len -- )

drop dup line-len @ line-offset @ - s" )" search \ Locate ' ) '
if
drop swap - line-offset +!
else 3drop line-Len @ line-offset ! \ skip to end of line
then
;
\ ***************************************************************************************
: GotComment \ (addr len -- )

2drop
\ skip to end of line
line-Len @ line-offset !
;
\ ***************************************************************************************
: GotString \ (addr len -- )
word-type 18 < \ S" Z," +Z," ."
if
+ line-len @ skip-spaces line-offset +!
line-len @ 0
   do dup c@ quote = swap 1+ swap 1 line-offset +! \ locate next " ignoring everything in between
     if drop leave then
   loop
1 line-offset +!

else 2drop  \ +z", ignore

then

;
\ ***************************************************************************************
: Incl-done
\ On Completion of Included File
\ Close file
infile-ptr close-file drop incl-state File-ptr @ to infile-ptr
\ release memory
infile-buffer-ptr free drop
\ reload Previous State
incl-state FBuf-ptr @ dup to infile-buffer-ptr
incl-state Lncount  @ linecount !
incl-state Filesize# @ inb-len !
incl-state Bytread  @ bytes-read !
incl-state LnOffset @ dup line-offset !
incl-state inclFile c@ to fileinuse
false to ?include
rot drop 0
\
;
\ ***************************************************************************************
: Gotinclude \ (addr len -- )
\ ? Already processing an included file if so ignore
?include if 2drop exit then
New-Get
line-Len @ line-offset ! \ remainder of line ignored
\ save existing info to be recalled later
true to ?include
\ save present state
infile-ptr incl-state File-ptr !
inb-len @ incl-state Filesize# !
2>r
incl-state Bytread !
incl-state FBuf-ptr !
line-offset @ incl-state LnOffset !
linecount @ incl-state Lncount !
fileinuse incl-state inclFile c!
\ Open File
2r> Cxref-fileopen
file-flag
 if
	\ Load new state
	infile-buffer-ptr bytes-read @
	0 linecount  !
 else
	incl-state FBuf-ptr @
	incl-state bytread @
	-1 to file-flag
 then
\
;
\ ***************************************************************************************
: GotCall \ (addr len -- )

\ get definition
+ line-len @ skip-spaces line-offset +!
endofword dup line-offset +!
\ check to see if name length is > 26
26 min
\ locate definition if found update
2dup
2dup -1 "#Hash def-table nrdef @ Crx-search
nrdef @ table-size * =
\ Not found Load into Def Table
if
drop
loaddefv3
else drop
then
;
\ ***************************************************************************************
: Reswordid

	case
		1 of 13 to word-type New-Get loaddefv3  ( GotDef) endof \ :Object
		2 of 23 to word-type GotCALL endof 	\ CALL
		3 of 12 to word-type New-Get loaddefv3 ( Code) endof \ CODE
		4 of 16 to word-type GotString endof 	\ +z,"
		5 of 21 to word-type GotComment2 endof 	\ '('
		6 of 10 to word-type New-Get loaddefv3  ( GotDef) endof \ ':'
		7 of 20 to word-type GotComment endof 	\ '\'
		8 of 14 to word-type GotString endof 	\ .",
		9 of 11 to word-type New-Get loaddefv3  ( GotDef) endof \ :M
		10 of 14 to word-type GotString endof 	\ S"
		11 of 24 to word-type GotInclude endof  \ INCLUDE
		12 of 17 to word-type GotString endof 	\ +z",
		13 of 15 to word-type GotString endof 	\ z,"
		14 of 6 to word-type New-Get loadvarv3 ( GotConstant) endof
		15 of 7 to word-type New-Get loadvarv3 ( GotConstant) endof
		16 of 8 to word-type New-Get loadvarv3 ( GotConstant) endof
		17 of 1 to word-type New-Get loadvarv3 ( GotVariable) endof
		18 of 2 to word-type New-Get loadvarv3 ( GotVariable) endof
		19 of 3 to word-type New-Get loadvarv3 ( GotVariable) endof
		20 of 13 to word-type New-Get loaddefv3 endof	\ :MENUITEM
		21 of 30 to word-type New-Get loadvarv3 ( GotCreate)  endof
		22 of 13 to word-type New-Get loaddefv3 endof	\ NEEDS
		23 of 13 to word-type New-Get loaddefv3 endof	\ DEFER
		24 of 5  to word-type New-Get loadvarv3 ( GotValue) endof

	endcase

;
\ ***************************************************************************************
: display-update ( n -- adr n )

temp1$ 8 32 fill temp1$ >string
temp1$ count drop 5
;
\ ***************************************************************************************
: LineParse \ ( addr, len -- flag)
	1 Tlinecount +! \ Tlinecount @  1988 = if breaker then
	1 linecount +!
	DUP line-len !
	2dup UPPER \ convert input steam to upper case

		( Line-Load )
		line-buffer zcount erase
		over line-buffer bytes-read @ cmove
		0 line-offset !  		   \ setup endpoint startpoint
		Nrvar @ 1- display-update
		w-display 80 5 * + 29 + swap cmove \ Move line count to display
		Nrdef @ 1- display-update
		w-display 80 6 * + 31 + swap cmove \ Move line count to display
		linecount @ display-update
		w-display 80 7 * + 24 + swap cmove \ Move line count to display

		Begin
		   line-buffer line-offset @ + \
		   DUP C@ bl <> swap DUP c@ 9 <> 2 roll and \ Check for space and tab

		       if
			  dup c@ 13 <> \ check for CR
			    if
		              endofword dup line-offset +! 1+ resword dup

		              if reswordid

		              else
			         2drop 1- 2dup -1 "#Hash var-table nrvar @ Crx-search

				 if varupdatev3
				   else
				      2dup -1 "#Hash def-table nrdef @ Crx-search if varupdatev3 else 2drop then
				 then

		             then

			    else line-Len @ line-offset ! drop
			    then

		       else 1 line-offset +! drop
		       then

		     line-offset @ line-len @ >=
		until

	line-buffer bytes-read @ erase
	sp0 @ stacksize 4 * - sp! \ RESET THE DATA STACK
        0
;
\ ***************************************************************************************
\       Define the Display-WINDOW child window class object
\ ***************************************************************************************
:Object Display-WINDOW <super child-window

        Font bFont
        int alreadyPainting
        int paintAgain
	int hidden?

Record: LPWinScrollInfo
        int cbSize
        int fMask
        int nMin
        int nMax
        int nPage
        int nPos
        int nTrackPos
;RecordSize: sizeof(LPWinScrollInfo)

:M ClassInit:   ( -- )
                ClassInit: Super
                FALSE to alreadyPainting
                FALSE to paintAgain
		TRUE to hidden?
                char-width        Width: bFont
                char-height      Height: bFont
                s" Courier" SetFacename: bFont
                ;M

:M On_Paint:    ( -- )          \ screen redraw procedure
                SaveDC: dc                      \ save device context
                Handle: bFont SetFont: dc       \ set the font to be used
                text-ptr ?dup
                IF      screen-rows 0
                       ?do      char-width char-height i *      \ x, y
                                line-cur i + #line"
                                col-cur /string
                                screen-cols min                 \ clip to win
                                TabbedTextOut: dc
                                word-split drop                 \ x
                                char-width +                    \ extra space
                                i char-height *                 \ y
                                over char-width / >r
                                spcs screen-cols r> - 0max      \ at least zero
                                spcs-max min TextOut: dc        \ and less than max
                        loop    2drop
                THEN
                using98/NT? 0=          \ only support variable sized scroll bars in Windows98 and WindowsNT
                line-last 32767 > OR    \ if we have a big file, revert to non-resizable scroll buttons
                IF
                        \ set the vertical scroll bar limits
                        FALSE line-last screen-rows - 0max 32767 min 0 SB_VERT
                        GetHandle: self Call SetScrollRange drop

                        \ position the vertical button in the scroll bar
                        TRUE line-cur line-last 32767 min line-last 1 - 1 max */ 32767 min SB_VERT
                        GetHandle: self Call SetScrollPos drop

                        \ set the horizontal scroll bar limits
                        FALSE max-cols screen-cols 3 - - 0max col-cur max 32767 min 0 SB_HORZ
                        GetHandle: self Call SetScrollRange drop

                        \ position the horizontal button in the scroll bar
                        TRUE col-cur 32767 min SB_HORZ
                        GetHandle: self Call SetScrollPos drop
                ELSE
                        \ set the vertical scroll bar limits and position
                        screen-rows to nPage
                        line-cur to nPos
                        0 to nMin
                        line-last to nMax
                        SIF_ALL to fMask
                        TRUE LPWinScrollInfo SB_VERT
                        GetHandle: self Call SetScrollInfo drop

                        screen-cols to nPage
                        col-cur to nPos
                        0 to nMin
                        max-cols to nMax
                        SIF_ALL to fMask
                        TRUE LPWinScrollInfo SB_HORZ
                        GetHandle: self Call SetScrollInfo drop
                THEN
\ restore the original font
                RestoreDC: dc
        ;M

:M On_Init:     ( -- )
                On_Init: super
                Create: bFont
                ;M

:M On_Done:     ( -- )
                Delete: bFont   \ delete the font when no longer needed
                On_Done: super
                ;M

:M StartSize:      ( -- width height - pixels ) screen-cols char-width * screen-rows char-height * ;M
:M StartPos:       ( -- x y )   0 11 char-height * ;M
:M Erase:       ( -- )          \ erase the text window
                get-dc
                0 0
                screen-cols char-width  *
                screen-rows char-height * WHITE FillArea: dc
                release-dc
                ;M
:M Hide:        ( f1 -- )
                dup hidden? <>
                IF      dup to hidden?
                        IF      SW_HIDE       Show: self
                        ELSE    SW_SHOWNORMAL Show: self
                        THEN
\                        Update: self
\                        Refresh: EditorWindow
                ELSE    drop
                THEN
                ;M

:M Refresh:     ( -- )          \ refresh the windows contents
                Paint: self
                ;M

:M VPosition:   ( n1 -- )       \ move to line n1 in file
                0max line-last 1+ screen-rows 1- - 0max min to line-cur
                ;M

:M HPosition:   ( n1 -- )       \ move to column n1
                0max max-cols 1+ screen-cols 1- - 0max min to col-cur
                ;M

:M Home:        ( -- )          \ goto the top of the current file
                0 VPosition: self
                0 HPosition: self
                Refresh: self
                ;M

:M End:         ( -- )          \ goto the end of the current file
                line-last 1+ VPosition: self
                0            HPosition: self
                Refresh: self
                ;M

:M VScroll:     ( n1 -- )       \ scroll up or down n1 lines in file
                line-cur + VPosition: self
                Refresh: self
                ;M


:M VPage:       ( n1 -- )       \ scroll up or down n1 pages in file
                screen-rows * line-cur + VPosition: self
                Refresh: self
                ;M

:M HScroll:     ( n1 -- )       \ scroll horizontally n1 characters
                col-cur + HPosition: self
                Refresh: self
                ;M


:M HPage:       ( n1 -- )       \ scroll horizontally by n1 page
                screen-cols * col-cur + HPosition: self
                Refresh: self
                ;M

:M WindowStyle: ( -- style )            \ return the window style
                WindowStyle: super
                WS_VSCROLL or           \ add vertical scroll bar
                WS_HSCROLL or           \ add horizontal scroll bar
                ;M

:M WM_VSCROLL   ( h m w l -- res )
                swap word-split >r
        CASE
                SB_BOTTOM        OF          End: self   ENDOF
                SB_TOP           OF         Home: self   ENDOF
                SB_LINEDOWN      OF    1 VScroll: self   ENDOF
                SB_LINEUP        OF   -1 VScroll: self   ENDOF
                SB_PAGEDOWN      OF    1   VPage: self   ENDOF
                SB_PAGEUP        OF   -1   VPage: self   ENDOF
                SB_THUMBTRACK    OF     line-last 32767 >
                                        IF     line-last r@ 32767 */ VPosition: self
                                        ELSE             r@          VPosition: self
                                        THEN             ENDOF
        ENDCASE r>drop
                Paint: self
                0 ;M

:M WM_HSCROLL   ( h m w l -- res )
                swap word-split >r
        CASE
                SB_BOTTOM        OF          End: self   ENDOF
                SB_TOP           OF         Home: self   ENDOF
                SB_LINELEFT      OF   -1 HScroll: self   ENDOF
                SB_LINERIGHT     OF    1 HScroll: self   ENDOF
                SB_PAGELEFT      OF   -1   HPage: self   ENDOF
                SB_PAGERIGHT     OF    1   HPage: self   ENDOF
                SB_THUMBPOSITION OF r@ HPosition: self
                                         Refresh: self   ENDOF
                SB_THUMBTRACK    OF r@ HPosition: self
                                         Refresh: self   ENDOF
        ENDCASE r>drop
                Paint: self
                0 ;M


;Object
\
\ ***************************************************************************************
\
:Object xref-Window   <Super Window

\
\ Rectangle EditRect
\
\
:M On_Init:             ( -- )
   On_Init: super
   self Start: Display-WINDOW         \ then startup the editor child window
\
;M
\
:M ClassInit:           ( -- )
	ClassInit: super
;M
:M WindowStyle:         ( -- style )   WindowStyle: Super  ( WS_CLIPCHILDREN or) ;M
:M ParentWindow:        ( -- hwndParent | 0=NoParent )    parent        ;M
:M SetParent:           ( hwndparent -- )       to parent               ;M
:M WindowHasMenu:       ( -- f )                true                    ;M
\
:M On_Paint:    \ ( --- ) all window refreshing is done by On_Paint:

		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc

                \ set the backgroundcolor for text to ltblue
                ltblue SetBkColor: dc

                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc

		w-display zcount nip center-page 0
			w-display zcount textout: dc \ Title Display
		w-display 80 + zcount nip center-page char-height
			w-display 80 + zcount textout: dc \ Author Display
		w-display 160 + zcount nip center-page char-height 2*
			w-display 160 + zcount textout: dc \ Version Display
		nrcol# 25 - char-width * dup char-height 3 *
		w-display 240 + zcount textout: dc \ Date & Time Display
		10 5 do I
			w-display i 80 * + zcount
			?dup
			  if
			     2>R char-height * 5 swap 2r> textout: dc
			  else 2drop
			  then
		     loop
;M
\
:M WindowTitle:    z" Win32Forth Cross-Reference Utility" ;M
\
:M StartSize:      ( -- width height - pixels ) nrcol# char-width * nrrow# char-height * ;M
\
:M StartPos:       ( -- x y )              CenterWindow: Self ;M
\
:M Close:          Close: super            ;M
\
:M On_Done:
		   Cxref-Fileclose
		   Cxref-Mem-deallot
                   Close: self
                   0 call PostQuitMessage drop
                   On_Done: super 0
		   turnkey? if bye then \ terminate application
;M
\
\ :M On_Size:     ( h m w -- )                  \ handle resize message
\                col-cur >r screen-cols >r
\                Width  char-width  / to screen-cols
\                r> screen-cols - col-cur + r> min 0max to col-cur
\
\                line-cur >r screen-rows >r
\                Height char-height / to screen-rows
\                r> screen-rows - line-cur + r> min 0max to line-cur
\ ;M
\
:M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
                over 0xF000 and 0xF000 <>
                if      over LOWORD
                        DoMenu: CurrentMenu
                        0
                else    DefWindowProc: [ self ]
                then
;M
\
:M msgBox: ( z$menu z$text - ) swap MB_OK   MessageBox: Self drop       ;M
\
;Object
\
' xref-Window is xref-Window#
\
\       Setup the line pointers and scroll bar for a new file
\
: set-line-pointers ( -- )
                wait-cursor
                1 to line-last          \ one total lines to start
                text-ptr line-tbl !     \ init first line
                1 +to line-cur          \ bump to next line pointer
                text-ptr text-len
                begin   0x0D scan dup
                while   2 /string over line-tbl line-cur    cells+ !
                        1 +to line-cur                  \ bump current line
                        max-lines line-cur =            \ while not full
                        if      4000 +to max-lines
                                max-lines 4 + cells line-tbl realloc
                                s" Failed to adjust the line pointer table"
                                ?TerminateBox
                                to line-tbl
                        then
                repeat  drop  dup      line-tbl line-cur    cells+ !
                                       line-tbl line-cur 1+ cells+ !
                line-cur to line-last                   \ set total lines
                0 to line-cur
                arrow-cursor
;
\
: set-longest-line ( -- )
                wait-cursor
                0
                line-last 1+ 0
                do      i #line" nip max
                loop    2 + to max-cols
                arrow-cursor
;
\
\ ***************************************************************************************
\
: Open-Display-file    ( a1 n1 -- )
                2dup r/o open-file 0=
                if
			StartPos: xref-Window
                        200 + swap 200 + swap message-origin
                        s" Reading Text File..." "message

                        >r 127 min cur-filename place
                        \ release/allocate the text buffer
                        text-ptr ?dup if free drop then
                        r@ file-size 2drop to text-len
                        text-len 10000 + to text-blen
                        text-blen malloc to text-ptr

                        \ release/allocate line pointer table
                        line-tbl ?dup if free drop then

                        1000 to max-lines
                        max-lines 4 + cells malloc to line-tbl
                        \ read the file into memory
                        text-ptr text-len r@ read-file drop
                        to text-len
                        r> close-file drop
                        set-line-pointers
                        set-longest-line

                        300 ms message-off
			false enable: MenuBegin#
			false hide: display-window
                        Refresh: display-window

                else    2drop drop

                then
;
\
\ ***************************************************************************************
\
: Close-display
	false enable: MenuClose-display#
	text-ptr ?dup if free drop then
	line-tbl ?dup if free drop then
	0 to line-last
	0 to line-cur
	erase: display-window
	true hide: display-window
	Paint: xref-Window
;
\
\ ***************************************************************************************
\
: Main-Process-loop ( -- )

	Begin
	infile-buffer-ptr inb-len @ infile-ptr read-line \ up to max 64K
	drop swap 1+ bytes-read !

	if
	  infile-buffer-ptr bytes-read @
	  LineParse \ begin processing file lines
	else -1
	then
	dup ?include and if incl-done then
	until
;
\
\ ***************************************************************************************
\
: Crossref

	file-flag \ If file is open process

		  if  \ file open successful
			false enable: MenuBegin#
			true enable: MenuClose-display#
			depth to stacksize
			w-display 80 5 * + dup 80 erase msg4 zcount rot swap cmove
			w-display 80 6 * + dup 80 erase msg5 zcount rot swap cmove
			w-display 80 7 * + dup 80 erase msg6 zcount rot swap cmove
			Paint: xref-Window
			ms@ >r \ get present time
			s" Crossxv3.wrk" r/w create-file drop to workfile-ptr \ open work file
			msg10 zcount workfile-buffer swap cmove

			work-file-write
			workfile-ptr file-position 2drop to eof-ptr

			Main-Process-loop

			msg8 zcount w-display 80 9 * + zcount + swap cmove
 			report-sortv3
			s" Crossref.txt" open-output-to-file abort" fileemit error"
			>file reportv3
			s" You can view the results in the file crossref.txt" type cr
			ms@ r> -  . ." milliseconds to process" cr >screen
			workfile-ptr close-file to workfile-ptr \ close work file
			s" Crossref.txt" open-display-file
		  then

sp0 @ stacksize 4 * - sp! \ RESET THE DATA STACK
;
\
\ ***************************************************************************************
\
MENUBAR ApplicationBar
    POPUP "&File"
        :MENUITEM menufileclose "&Close File... \tCtrl-C"
                 Cxref-Fileclose Paint: xref-Window  ;
        :MENUITEM menufileopen  "&Open File...  \tCtrl-O"
		Cxref-Fileclose gethandle: xref-Window Start: filelocate 0
		Cxref-fileopen Paint: xref-Window ;
        MENUITEM        "&Exit \tAlt-F4" Close: xref-Window	;

    POPUP "Help"
        MENUITEM        "&Info"
                        z" Info"
                        z" Win32Forth Cross-Reference Utility \n Developed By F J Russo"
                        msgBox: xref-Window                   	;
    POPUP "Process"
        :MENUITEM        menubegin "&Begin... \tCtrl-B" Crossref ;
	:MENUITEM	 MenuClose-display "Close-&Display... \tCtrl-D" Close-display ;

ENDBAR
' menubegin is menubegin#
' MenuClose-display is MenuClose-display#
' menufileclose is menufileclose#
' menufileopen  is menufileopen#
\
\ ***************************************************************************************
\
\ The main application program
\
: cxref
   Initv init-hash
\
   msg1 zcount w-display swap cmove 	     \ Title Display
   msg2 zcount w-display 80 + swap cmove     \ Author Display
   msg3 zcount w-display 80 2 * + swap cmove \ Version Display
   get-local-time time-buf >date" w-display 80 3 * + dup >r swap cmove
   s"    " r> zcount + dup >r swap cmove     \ Date Display
   time-buf >time" r> zcount + swap cmove    \ Time Display
   msg9d zcount w-display 80 5 * + swap cmove
   msg9e zcount w-display 80 6 * + swap cmove
   msg9f zcount w-display 80 7 * + swap cmove
   msg10 zcount w-display 80 9 * + swap cmove
\
   start: xref-Window
   ApplicationBar SetMenuBar: xref-Window
   gethandle: xref-Window Start: filelocate
   file-flag enable: MenuBegin
   0 Cxref-fileopen Paint: xref-Window
   file-flag enable: MenuBegin
   false enable: MenuClose-display#
   cxref-mem-allot
   turnkey? IF MessageLoop bye THEN
;
\
 turnkey?
 [if]
         NoConsoleIO  NoConsoleInImage
         ' cxref turnkey Crossref.exe
         s" WIN32FOR.ICO" s" Crossref.exe" AddAppIcon
        1 pause-seconds bye
\ [else]  cxref
 [then]
\
\s
