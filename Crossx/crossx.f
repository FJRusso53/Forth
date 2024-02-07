\ Crossx.F
\ Frank J. Russo
\ Version 3.1.1
\ Date 070822

ANEW Crossxref

only forth also definitions hidden also forth

include crossx.h
include string.f
include file-emit.f

Decimal
\ ***************************************************************************************
: center-dertm \ ( count --- offset)
dup 2 / 40 swap -
;
\ ***************************************************************************************
: work-file-read
workfile-buffer 1024 0 fill
workfile-buffer 1024 workfile-ptr read-file 2drop
;
\ ***************************************************************************************
: work-file-write
workfile-buffer 1024 workfile-ptr write-file drop
workfile-buffer 1024 32 fill
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
: Title
	cls cr
	msg1 zcount center-dertm spaces type cr
	msg2 zcount center-dertm spaces type cr
	msg3 zcount center-dertm spaces type cr
	cr 50 spaces .date 2 spaces .time cr cr
;
\ ***************************************************************************************
: Initv
0 nrvar ! 0 nrdef ! 0 plines !
0 to bufptr
0 to msgptr
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
0 to healer
workfile-buffer 1024 32 fill
255 nroccur !
65535 2 / 32 / maxnrvar !
0 linecount !
line-buffer 512 erase
file-name 64 erase
temp-ptr-area 32 erase
;
\ ***************************************************************************************
: Report-Sortv3 \ ( -- )

\ 32 bytes per name - record

\ Occurances - 1  -  Occurances limited to 255
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27

2 0 do  cr
	i 0 =
		if nrvar var-table  \ First time though sor the Variable Table
		else nrdef def-table \ second time through sort the definition table
		then
	to str1 @ dup temp1 !
	1 >

	if
		temp-ptr-area to temp3-ptr
		str1 to temp1-ptr

		temp1 @ 1 do temp1 @ I temp1-ptr 32 + to temp2-ptr

			 do
				temp1-ptr 5 + 27 temp2-ptr 5 + 27 compare
				1 =

				if \ second item in list is smaller than first item
					temp1-ptr temp3-ptr 32 cmove
					temp2-ptr temp1-ptr 32 cmove
					temp3-ptr temp2-ptr 32 cmove
				then

				32 +to temp2-ptr
			loop

			32 +to temp1-ptr
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
." Nr# of Variable Identified: " nrvar @ . cr
." Nr# of Definitions Identified: " nrdef @ . cr
." Nr# of Lines Processed: " linecount @ . cr
cr cr msg8A zcount type cr cr
." ____________________________________________________________________________________"
cr 11 plines +!
2 0 do  cr 1 plines +!
	i 0 =
		if var-table ." Variables: ( " nrvar @ . ." )" cr cr 2 plines +!
		else def-table ." Definitions: ( " nrdef @ . ." )" cr cr 2 plines +!
		then
	to str1
	i 0 =
		if nrvar \ put # variable on stack
		else nrdef \ put # definitions on stack
		then
	@ dup 0>
	if
	 0 do

	      str1 c@  \ Occurances
	      str1 2 + w@  1024 *  \ disk address
	      swap
	      str1 4 + c@    \ Word Size
	      str1 5 + 	     \ Name address
	      swap dup 27 swap - swap 2 roll swap
	      type 8 + spaces dup . swap 12 spaces
	      0 workfile-ptr reposition-file drop
		\ read from disk file record containing the line #'s where name was found
		work-file-read
	      0 do
		  workfile-buffer i 2 * + dup C@ swap 1 + c@ 256 * +
		  i 0> if i 6 /mod drop 0=  \ Looking for a multiples of 8

		          if cr 1 plines +! new-page 49 spaces then \ advance to next line
		       then
		  . ." / "
		loop

		cr 1 plines +! new-page
	      32 +to str1
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
: Cxref-fileopen 	  \ ( file name, length -- flag)

 over over dup file-name dup 2 roll swap c! 1 + swap cmove
\ get file name off of stack & save at file-name

 r/o open-file 0=	  \ attempt to open input file r/o read only
  if
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 *
    65535 min \ space to allocate for file buffer max of 64K
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    dup inb-len ! infile-buffer-ptr swap erase  \ clear space

   32768 malloc to Var-table \ New variable table holds 1024 names

\ 32 bytes per name
\ Occurances - 1
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27

   var-table 32768 erase \ clear space

   32768 malloc to Def-table \ New Definition table holds 1024 names

\ 32 bytes per name

\ Occurances - 1
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27

   Def-table 32768 erase \ clear space


  else 0 to file-flag   \ File open failure

  then
;
\ ***************************************************************************************
: Skip-Spaces \ (addr len -- addr count)
\ s" Skip Spaces " type
swap to str1
0 swap 0 do
	   str1 c@ 32 <>
	   if leave
	   else 1 +
	   then
	   1 +to str1
         loop
str1 swap
;
\ ***************************************************************************************
: endofword \ ( addr Len -- addr N )
\ cr s" endofword" type
\ Looking for a space or CR ()OD
strend   		\ ( Addr1 N1 -- Addr1 N2 )
;
\ ***************************************************************************************
: resword  \ ( Addr2 len2 -- addr2 Len2 F )

2dup dup 1 = if drop 2 then
msg14 zcount 3 roll 3 roll
strndx		\ Search ( add1 len1 addr2 len2 --- start-addr remaining-bytes flag )
2 roll 2 roll 2drop
;
\ ***************************************************************************************
: varupdatev3  \ ( addr --- F)

\ 32 bytes per name
\ Occurances - 1
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27

\ update table entry for # of occurances
4 - dup dup c@ 1 + swap c!
\ read from file entry data
dup 2 + w@ 1024 * 0 \ calc offset into file Locate # * 1024 (bytes / record)
\ reposition file pointer
workfile-ptr reposition-file drop
\ read in entry data
work-file-read
\ update line # in data
c@ \ # occurances including present
1 - 2 * \ 2 bytes per occurance
workfile-buffer +
linecount @ swap w!
\ write file entry
workfile-ptr file-position 2drop 1024 - 0  \ back up to begining of last record read
workfile-ptr reposition-file
work-file-write drop
eof-ptr 0 workfile-ptr reposition-file \ go to end of file
drop
;
\ ***************************************************************************************
: locatedefv3 ( addr len --- )

search-param 96 0 fill
27 min \ truncate name length to 27 characters
dup search-param c!
search-param 1 + swap cmove
def-table nrdef @ 32 * search-param 27 search
if drop varupdatev3
then
;
\ ***************************************************************************************
: locatevarv3 ( addr len --- )

search-param 96 0 fill
27 min \ truncate name length to 27 characters
dup search-param c!
search-param 1 + swap cmove
var-table nrvar @ 32 * search-param 27 search
if drop varupdatev3 -1
else 2drop 0
then
;
\ ***************************************************************************************
: LoadDefv3 \ ( addr Len -- addr len)
nrdef @ maxnrvar @ <
if
	to temp1-ptr
	to temp2-ptr
	1 +to workfile-count
	nrdef @ 32 * to def-table-offset  \ offset into the definition table
	1 def-table-offset def-table + c! \ save initial occurance
	word-type def-table-offset def-table + 1 + c! \ Save word type
	workfile-count def-table-offset def-table + 2 + W! \ Save disk location 2 bytes
	temp1-ptr def-table-offset def-table + 4 + c! \ save length of name
	temp2-ptr def-table-offset def-table + 5 + temp1-ptr cmove \ Save name
	\ write info to disk
	linecount @ workfile-buffer w!
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
	to temp1-ptr
	to temp2-ptr
	1 +to workfile-count
	nrvar @ 32 * to var-table-offset  \ offset into the variable table
	1 var-table-offset var-table +  c! \ save initial occurance
	word-type var-table-offset var-table + 1 + c! \ Save word type
	workfile-count var-table-offset var-table + 2 + W! \ Save disk location 2 bytes
	temp1-ptr var-table-offset var-table + 4 + c! \ save length of name
	temp2-ptr var-table-offset var-table + 5 + temp1-ptr cmove \ Save name
	\ write info to disk
	linecount @ workfile-buffer w!
	work-file-write
	workfile-ptr file-position 2drop to eof-ptr
	1 nrvar +!

else ." Maximum Nr of Variables exceeded - " 0 32 x_gotoxy 2 spaces maxnrvar @ .
then
;
\ **************************************************************************************
: GotDef \ (addr len -- )

+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup 1 + line-offset +!
\ check to see if name length is > 27
27 min
loaddefv3
;
\ ***************************************************************************************
: GotCreate \ (addr len -- )

+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
\ check to see if name length is > 27
27 min
loadvarv3
;
\ ***************************************************************************************
: GotVariable \ (addr len -- )

+ 1 - line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
\ check to see if name length is > 27
27 min
loadvarv3
;
\ ***************************************************************************************
: GotCode
\ Not functioning at this time ignore
2drop
;
\ ***************************************************************************************
: GotConstant \ (addr len -- )

+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
\ check to see if name length is > 27
27 min
loadvarv3
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
word-type 17 < \ S" Z," +Z," ."
if
+ line-len @ skip-spaces line-offset +!
line-len @ 0
   do dup c@ quote = swap 1 + swap 1 line-offset +! \ locate next " ignoring everything in between
     if drop leave then
   loop
1 line-offset +!

else 2drop  \ +z", ignore

then

;
\ ***************************************************************************************
: GotValue \ (addr len -- )

+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
\ check to see if name length is > 27
dup 27 >
if drop 27 then
loadvarv3
;
\ ***************************************************************************************
: GotCall \ (addr len -- )

\ get definition
+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup 1 + line-offset +!
\ check to see if name length is > 27
27 min
\ locate definition if found update
2dup locatedefv3
nrdef @ 32 * =
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
		1 of 10 to word-type GotDef endof
		2 of 11 to word-type GotDef endof
		6 of 20 to word-type GotComment endof
		8 of 21 to word-type GotComment2 endof
		10 of 30 to word-type GotCreate endof
		17 of 1 to word-type GotVariable endof
		26 of 2 to word-type GotVariable endof
		36 of 3 to word-type GotVariable endof
		40 of 5 to word-type GotValue endof
		46 of 4 to word-type GotValue endof
		52 of 12 to word-type GotCode endof
		54 of 6 to word-type GotConstant endof
		65 of 7 to word-type GotConstant endof
		75 of 8 to word-type GotConstant endof
		81 of 23 to word-type GotCALL endof
		88 of 23 to word-type GotDef endof
		92 of 24 to word-type GotDef endof
		103 of 13 to word-type GotDef endof
		111 of 14 to word-type GotString endof \ s"
		116 of 15 to word-type GotString endof \ z,"
		120 of 16 to word-type GotString endof \ +z,"
		123 of 17 to word-type GotString endof \ +z",
		130 of 14 to word-type GotString endof \ .",

	endcase
depth dup 2 >
if
  2 do drop loop
else drop
then
;
\ ***************************************************************************************
: Line-Load \ ( addr len -- flag )
	line-buffer 512 erase
	2dup
	line-feed
	instrb dup
	if  \ locate a delimiter
	1 linecount +! 1 + DUP line-len ! line-buffer swap cmove
	-1
	else 0
	then
;
\ ***************************************************************************************
: LineParse \ ( addr, len -- flag)
	0 temp3 !
	2dup Up-Case \ convert entire input steam to upper case
	begin

		Line-Load 0 line-offset ! \ setup endpoint startpoint
		0 12 x_gotoxy msg16 zcount type linecount ?

	if
		Begin
		   0 to healer
		   line-buffer line-offset @ + \
		   DUP C@ 32 <> swap DUP c@ 9 <> 2 roll and \ Check for space and tab

		       if
			  dup c@ 13 <> \ check for CR
			    if
		              line-len @ endofword dup line-offset +! 1 + resword dup

		              if 3dup drop type cr reswordid

		              else
			         drop 1 -
			         2dup Locatevarv3 0=

				 if LocateDefv3 then

		              then

			    else line-Len @ line-offset ! drop
			    then

		       else 1 line-offset +! drop
		       then

		     line-offset @ line-len @ >=
		until

	else 	\ self healing trap
		1 +to healer
		healer 3 >
		if
			msg15 zcount cr type cr depth
			dup 0>

			  if
			    ." Stack Values Remaining -- "
			    0 do . 8 spaces loop cr cr
			  else drop
			  then

			abort
		then

		1 line-offset +!
	then

	depth 2 >

	if
	  depth 2 - 0 do drop loop
	then

	line-offset @ - swap line-offset @ + swap
	dup 0<
	until \ end of buffer
	depth 0 >

	if
	  depth 0 do drop loop
        then
;
\ ***************************************************************************************
: Crossref
	ms@ >r \ save present time
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

   \ to file and to screen

		CXref-fileopen file-flag \ open file allocate memory and working tables

		  if  \ file open successful

			s" Crossxv3.wrk" r/w create-file drop to workfile-ptr \ open work file
			0 10 x_gotoxy MSG10 zcount type file-name count type
			msg10 zcount workfile-buffer swap cmove

			work-file-write
			workfile-ptr file-position 2drop to eof-ptr

			Begin
			infile-buffer-ptr inb-len @ infile-ptr read-file \ up to max 64K
				drop bytes-read !

			infile-buffer-ptr bytes-read @ LineParse \ begin processing file lines
			infile-buffer-ptr inb-len @ erase
			infile-len bytes-read @ - dup to infile-len 0=
			until

    s" c:\Crossref.txt" open-output-to-file abort" fileemit error"
    cr cr cr
    >FileAndScreen

			report-sortv3 reportv3 PReport if P-Reportv3 then

 >screen
 close-output-to-file
s" You can view the results in the file C:\crossref.txt" type cr

			file-flag if infile-ptr close-file drop then  \ Close input file
			workfile-ptr close-file drop \ close work file

			infile-buffer-ptr 	\ Release allocated memory
			if infile-buffer-ptr free drop then

			var-table		\ Release allocated memory
			if var-table free drop then

			def-table		\ Release allocated memory
			if def-table free drop then

		  else  msg13 zcount cr cr type ."  - " file-name count type cr cr

		  then

	   then
ms@ r> 2dup cr . . - . cr
;
\ ***************************************************************************************
title
		msg9 zcount cr cr type cr
		msg9a zcount type cr
		msg9b zcount type cr
		msg9c zcount type cr cr
		msg9d zcount type cr
		msg9e zcount type cr
		msg9f zcount type cr cr
		msg17 zcount type cr cr
		msg17a zcount type cr cr
