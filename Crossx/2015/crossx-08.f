\ Crossx.F
\ Frank J. Russo
\ Version 4.0.0
\ Date 070923

ANEW Crossxref

only forth also definitions hidden also forth

include crossx-08.h
include string.f
include file-emit.f
\ defer Main-Process-loop#

Decimal
\ ********************************************************************************
\
: CHANNEL ( row struc-size -< name >- )
\ Array code for Psi - En - Aud memory channel arrays.  Rewritten FJR 061118
 CREATE   ( Returns address of newly named channel. )
 dup ,    ( Stores size of rows from stack to array.)
 * MALLOC , ( Reserves given quantity of cells for array.)
 DOES>    ( member; row -- a-addr )
 Tuck @ * swap cell+ @ +
; \ End of code for arrays to be created with "cns" size.
\
\ ********************************************************************************
\
24 hash-size CHANNEL hash{ ( Hash Table )
0 hash{ 1+ hash-size 24 * 1- erase
\
\ ***************************************************************************************
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
nrvar @ 1 cr
do
  i dup 3 .r 2 spaces table-size * var-table + dup dname zcount type
  dhash @ 30 getxy nip gotoxy . cr
loop
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
: hash-build ( Add Len -- )
\ cr 2dup type space [char] , emit space
-1 "#hash  \ dup .
1 +to hash-count
hash-count hash{ !
hash-count dup hash{ hloc W!
;
\ ***************************************************************************************
: Initv
1 nrvar ! 1 nrdef ! 0 plines !
0 to infile-ptr
0 to infile-buffer-ptr
0 to file-flag
0 to infile-len
0 to temp1-ptr
0 to temp2-ptr
0 to word-type
0 to workfile-ptr
0 to eof-ptr
0 to workfile-count
0 to hash-count
0 file-count !
255 nroccur !
1820 maxnrvar !
0 linecount !
0 Tlinecount !
workfile-buffer wfrec 32 fill
line-buffer 512 erase
file-name 64 erase
temp-ptr-area 32 erase
temp1$ 8 erase
file-names 1024 erase
\
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
: Report-Sortv3 \ ( -- )

\ table-size bytes per name - record

\ Occurances - 1  -  Occurances limited to 255
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27
\ hash - 4
\ inclfile - 1

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
cr msg10 zcount type file-name count type
msg8 zcount type cr cr
Msg4 zcount type nrvar @ 1- . cr
Msg5 zcount type nrdef @ 1- . cr
Msg6 zcount type Tlinecount @ . cr
file-count @ 1- dup
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
	      dup Occurances c@ dup 3 .r 6 spaces
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
: P-Reportv3 \ If PReport True then print output
Printer
2 to PReport
reportv3
false to PReport
console
;
\ ***************************************************************************************
: Cxref-fileopen 	  \ ( file name, length -- )
 2dup
 r/o open-file 0=	  \ attempt to open input file r/o read only
  if
    1 to file-flag \ success opening
     1 file-count +! file-count @ to fileinuse
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 *
    65535 min \ space to allocate for file buffer max of 64K
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    dup inb-len ! infile-buffer-ptr swap erase  \ clear space
    dup file-names zcount + dup >r ! r> 1+ swap cmove
  else 2drop 0 to file-flag   \ File open failure

  then
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
\ strend   		\ ( Addr1 N1 -- Addr1 N2 )
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
  = if 3drop i unloop exit then
  swap > if drop 0 unloop exit then
loop
drop 0
;
\ ***************************************************************************************
: varupdatev3  \ ( addr --- F)

\ table-size bytes per name
\ Occurances - 1
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27
\ hash - 4
\ inclfile - 1

\ update table entry for # of occurances
dup dup c@ 1+ swap c!
\ read from file entry data
dup diskaddress w@ wfrec * 0 \ calc offset into file Locate # * wfrec (bytes / record)
\ reposition file pointer
workfile-ptr reposition-file drop
\ read in entry data
work-file-read
\ update line # in data
c@ \ # occurances including present
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
	    = if nip I table-size * + -1 unloop exit then
	  loop
    else drop
    then
2drop 0
;
\ ***************************************************************************************
: LoadDefv3 \ ( addr Len -- addr len)
nrdef @ maxnrvar @ <
if
	\ check to see if name length is > 26
	dup 26 > if drop 26 then
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

else ." Maximum Nr of Definitions exceeded - " 0 30 x_gotoxy 2 spaces maxnrvar @ .
then
;
\ ***************************************************************************************
: LoadVarv3 \ ( addr Len -- )
nrvar @ maxnrvar @ <
if
	\ check to see if name length is > 26
	dup 26 > if drop 26 then
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

else ." Maximum Nr of Variables exceeded - " 0 32 x_gotoxy 2 spaces maxnrvar @ .
then
;
\ ***************************************************************************************
: New-Get \ (addr len -- Addr len)

+ line-len @ line-offset @ -
skip-spaces 1+ line-offset +!
endofword dup line-offset +!
;
\ ***************************************************************************************
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
infile-ptr close-file  drop incl-state File-ptr @ to infile-ptr
\ release memory
infile-buffer-ptr free drop
\ reload Previous State
incl-state FBuf-ptr @ dup to infile-buffer-ptr
incl-state Lncount  @ linecount !
incl-state Filesize @ inb-len !
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
inb-len @ incl-state Filesize !
2>r
incl-state Bytread !
incl-state FBuf-ptr !
line-offset @ incl-state LnOffset !
linecount @ incl-state Lncount !
fileinuse incl-state inclFile c!
\ Open File
2r> cxref-fileopen
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
		1 of 13 to word-type New-Get loaddefv3  ( GotDef) endof  \ :Object
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
		20 of 13 to word-type New-Get loaddefv3 ( GotDef) endof	\ :MENUITEM
		21 of 30 to word-type New-Get loadvarv3 ( GotCreate)  endof
		22 of 13 to word-type New-Get loaddefv3 ( GotDef) endof	\ NEEDS
		23 of 13 to word-type New-Get loaddefv3 ( GotDef) endof	\ DEFER
		24 of 5  to word-type New-Get loadvarv3 ( GotValue) endof

	endcase
;
\ ***************************************************************************************
: LineParse \ ( addr, len -- flag)
	1 Tlinecount +! \ Tlinecount @ 1942 = if breaker then
	1 linecount +!
	DUP line-len !
	2dup UPPER \ convert input steam to upper case

		( Line-Load )
		line-buffer zcount erase
		over line-buffer bytes-read @ cmove
		0 line-offset !

		Begin
		   0 12 x_gotoxy msg16 zcount type linecount ?
		   \ linecount @ 2841 = if breaker then
		   line-buffer line-offset @ + \
		   DUP C@ bl <> swap DUP c@ 9 <> 2 roll and \ Check for space and tab

		       if
			  dup c@ 13 <> \ check for CR
			    if
		              endofword dup line-offset +! 1+ resword dup

		              if >r 2dup type cr r> reswordid

		              else
			         drop 1-
				 2dup -1 "#Hash var-table nrvar @ Crx-search

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
\
\ ***************************************************************************************
\
: Main-Process-loop ( -- )

	Begin
	infile-buffer-ptr inb-len @ infile-ptr read-line \ up to max 64K
	drop swap 1+ bytes-read !

	if
	  infile-buffer-ptr bytes-read @ LineParse \ begin processing file lines
	  \ infile-buffer-ptr inb-len @ erase
	else -1
	then
	dup ?include and if incl-done then
	until
;
\ ' Main-Process-loop is Main-Process-loop#
\ ***************************************************************************************
: Crossref
	ms@ >r \ get present time
	Decimal Title Initv \ Base 10 Display title screen initialize variables
		Depth 0= \ Stack = 0  then there is no file name on the stack to process
	   if
		msg9 zcount cr cr type cr
		msg9a zcount type cr
		msg9b zcount type cr
		msg9c zcount type cr cr
		msg9d zcount type cr
		msg9e zcount type cr
		msg9f zcount type cr cr
		msg17 zcount type cr cr
		msg17a zcount type cr cr

	   else
		\ get file name off of stack & save at file-name
		over over dup file-name dup 2 roll swap c! 1+ swap cmove

		CXref-fileopen file-flag \ open file allocate memory and working tables

		  if  \ file open successful

			65535 malloc to Var-table \ New variable table holds 2048 names
			var-table 65535 erase \ clear space

			65535 malloc to Def-table \ New Definition table holds 2048 names
			Def-table 65535 erase \ clear space

			s" Crossxv3.wrk" r/w create-file drop to workfile-ptr \ open work file
			0 10 x_gotoxy MSG10 zcount type file-name count type
			msg10 zcount workfile-buffer swap cmove

			work-file-write
			workfile-ptr file-position 2drop to eof-ptr
			depth to stacksize
			Main-Process-loop

    s" c:\Crossref.txt" open-output-to-file abort" fileemit error"
    cr cr cr
\ Install error check for fiel opening
    >FileAndScreen

 report-sortv3 reportv3 PReport if P-Reportv3 then
 ms@ r> - . ." milliseconds to process" cr
 >screen
 close-output-to-file
s" You can view the results in the file C:\crossref.txt" type cr
			file-flag if infile-ptr close-file drop then  \ Close input file
			workfile-ptr close-file drop \ close work file
			infile-buffer-ptr If infile-buffer-ptr free drop then \ Release allocated memory
			var-table         if var-table free drop then
			def-table	  if def-table free drop then
			['] hash{ >body cell+ @        free drop
		  else  msg13 zcount cr cr type ."  - " file-name count type cr cr

		  then

	   then

;
\ ***************************************************************************************
\ title
\		msg9 zcount cr cr type cr
\		msg9a zcount type cr
\		msg9b zcount type cr
\		msg9c zcount type cr cr
\		msg9d zcount type cr
\		msg9e zcount type cr
\		msg9f zcount type cr cr
\		msg17 zcount type cr cr
\		msg17a zcount type cr cr
\
