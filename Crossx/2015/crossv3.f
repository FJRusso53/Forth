\ Crossx.F
\ Frank J. Russo
\ Version 3.00
\ Date 050831

ANEW Crossxref

only forth also definitions hidden also forth

include crossv3.h
include string.f

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
: New-Page
	msg1 zcount center-dertm spaces type cr
	msg2 zcount center-dertm spaces type cr
	cr 50 spaces .date 2 spaces .time cr cr
	cr msg10 zcount type file-name count type 
	msg8 zcount type cr cr
	cr cr msg8A zcount type cr cr 
s" ____________________________________________________________________________________"
	type cr
11 plines !

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
0 to Def-area-ptr
0 to proc-area-ptr
0 to infile-len
0 to next-open-Def
0 to next-open-entry
0 to temp1-ptr
0 to temp2-ptr
0 to word-type
0 to workfile-ptr
0 to eof-ptr
0 to workfile-position
0 to workfile-count
workfile-buffer 1024 32 fill
100 nroccur ! 0 linecount !
0 linenr ! 65535 220 / maxnrvar !
TextBuffer 120 erase
line-buffer 512 erase
file-name 64 erase
temp-ptr-area 220 erase
;
\ ***************************************************************************************
: Report-Sortv3 \ ( -- )
\ 32 bytes per name

\ Occurances - 1  -  Occurances limited to 255
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 27

2 0 do  cr
	i 0 = 
		if nrvar var-table 
		else nrdef def-table
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

	else drop
	then
loop
; 
\ ***************************************************************************************
: Report-Sort \ (addr N -- )
temp-ptr-area to temp3-ptr
dup 1 >
if swap to temp1-ptr dup  

   1 do dup I temp1-ptr 220 + to temp2-ptr 

	do
		temp1-ptr 3 + 15 temp2-ptr 3 + 15 compare
		1 = 

		if \ second item in list is smaller than first item
		   temp1-ptr temp3-ptr 220 cmove
		   temp2-ptr temp1-ptr 220 cmove
		   temp3-ptr temp2-ptr 220 cmove
		then

		220 +to temp2-ptr
	loop

     220 +to temp1-ptr
     loop

else drop
then
; 
\ ***************************************************************************************
: Reportv3
0 plines !
Title  6 plines +!
cr msg10 zcount type file-name count type 
msg8 zcount type cr cr
s" Nr# of Variable Identified: " type nrvar @ . cr
s" Nr# of Definitions Identified: " type nrdef @ . cr
s" Nr# of Lines Processed: " type linecount @ . cr
cr cr msg8A zcount type cr cr 
s" ____________________________________________________________________________________"
type cr 11 plines +!
2 0 do  cr 1 plines +!
	i 1 = 
		if var-table s" Variables: ( " type nrvar @ . s" )" type cr cr 2 plines +!
		else def-table s" Definitions: ( " type nrdef @ . s" )" type cr  2 plines +!
		then
	to str1
	i 1 = 
		if nrvar
		else nrdef
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
	      0 workfile-ptr reposition-file drop work-file-read
	      0 do
		  workfile-buffer i 2 * + dup C@ swap 1 + c@ 256 * + \ . s" / " type
		  i 0> if i 6 /mod drop 0=  \ Looking for a multiples of 8

		          if cr 1 plines +! 49 spaces then \ advance to next line
		       then
		  . s" / " type
		loop 

		cr 1 plines +! 
	      32 +to str1
	  loop
	else drop
	then
s" ____________________________________________________________________________________"
type cr 1 plines +!
loop
;
\ ***************************************************************************************
: Report 
0 plines !
Title  6 plines +!
cr msg10 zcount type file-name count type 
msg8 zcount type cr cr
s" Nr# of Variable Identified: " type nrvar @ . cr
s" Nr# of Definitions Identified: " type nrdef @ . cr
s" Nr# of Lines Processed: " type linecount @ . cr
cr cr msg8A zcount type cr cr 
s" ____________________________________________________________________________________"
type cr 11 plines +!
2 0 do  cr 1 plines +!
	i 1 = 
		if proc-area-ptr s" Variables: ( " type nrvar @ . s" )" type cr cr 2 plines +!
		else def-area-ptr s" Definitions: ( " type nrdef @ . s" )" type cr  2 plines +!
		then
	to str1
	i 1 = 
		if nrvar
		else nrdef
		then
	@ dup 0>
	if
	 dup str1 swap report-sort
	 0 do

	      str1 1 + c@  \ Occurances
	      \ str1 2 + c@  \ word type
	      str1 c@	   \ Word Size
	      str1 3 + 	   \ Name address
	      swap dup 15 swap - swap 2 roll swap
	      type 8 + spaces . 12 spaces
	      str1 19 + str1 1 + c@ 0 

		do
		  dup C@ over 1 + c@ 256 * + . s" / " type
		  2 + 
		  i 0> if i 7 /mod drop 0=  \ Looking for a multiples of 8

		          if cr 1 plines +! 37 spaces then \ advance to next line
		       then
		loop 

		cr 1 plines +! 
	      220 +to str1
	  loop
	else drop
	then
s" ____________________________________________________________________________________"
type cr 1 plines +!
loop
;
\ ***************************************************************************************
: P-Report
Printer 
report
console
; 
\ ***************************************************************************************
: P-Reportv3
Printer 
reportv3
console
; 
\ ***************************************************************************************
: Cxref-fileopen 	  \ ( file name, length -- flag)

 over over dup file-name dup 2 roll swap c! 1 + swap cmove 

 r/o open-file 0=	  \ attempt to open input file r/o read only
  if 
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 * dup
    65535 >
    if drop 65535 then
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    dup inb-len ! infile-buffer-ptr swap erase  \ clear space

    65535 malloc to proc-area-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    proc-area-ptr 65535 erase  \ clear space
    proc-area-ptr to next-open-entry 

   65535 malloc to def-area-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size
    def-area-ptr 65535 erase  \ clear space
    def-area-ptr to next-open-def 

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
\ cr s" resword" type		(  --- flag )
2dup dup 1 = if drop 2 then
\ s" -" type 2dup type s" -" type cr 
msg14 zcount 3 roll 3 roll
strndx		\ ( add1 len1 addr2 len2 --- addr1 len1 offset )
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
: varupdate  \ ( addr --- F)
\ cr s" Varupdate" type
dup dup 1 + c@ 
dup 100 <
if
   2dup 1 + swap 1 + c!
   2 * 19 + +
   linecount @ swap !
   drop 1
else 
   s" Maximum Nr of Occurances for this variable exceeded - 100 " 0 34 x_gotoxy type
   3 spaces drop dup c@ swap 3 + swap type drop 0
then
;
\ ***************************************************************************************
: locatedefv3 ( addr len - addr len)

search-param 96 0 fill
dup search-param c!
search-param 1 + swap cmove
def-table nrdef @ 32 * search-param 28 search 
if drop varupdatev3
else 2drop
then
;
\ ***************************************************************************************
: LocateDef ( addr2 len2 --- addr1, offset )
\ cr s" LocateDEF" type 
  nrdef @
   if	\ Number of Definitions > 0 
	2dup locatedefv3
	def-area-ptr to temp1-ptr
	temp1 ! to temp2-ptr 
	0 to str-flag
	0 nrdef @ 0 
	    do 
		temp1-ptr c@ temp1 @ = \ word lengths = ?

		if
		    temp1-ptr 3 + temp1-ptr c@ temp2-ptr temp1 @ COMPARE NOT 

		    if 1 to str-flag leave then

		then

	    220 +to temp1-ptr
	    loop

	    str-flag
	    if 1 else 0 then
  else drop 0
  then
  swap drop temp1-ptr swap
;
\ ***************************************************************************************
: locatevarv3 ( addr len - addr len)

search-param 32 0 fill
dup search-param c!
search-param 1 + swap cmove
var-table nrvar @ 32 * search-param 28 search 
if drop varupdatev3
else 2drop
then
;
\ ***************************************************************************************
: Locatevar ( addr2 len2 --- addr1, offset )
\ cr s" LocateVar" type 
nrvar @
if	\ Number of variables > 0 
	2dup locatevarv3
	proc-area-ptr to temp1-ptr
	temp1 ! to temp2-ptr 
	0 to str-flag
	0 nrvar @ 0 do 
		temp1-ptr c@ temp1 @ = \ word lengths = ?
		if
		    temp1-ptr 3 + temp1-ptr c@ temp2-ptr temp1 @ COMPARE NOT 
		    if 1 to str-flag leave then
		then
	    220 +to temp1-ptr
	    loop
	    str-flag
	    if 1 else 0 then
else drop 0
then
swap drop temp1-ptr swap
;
\ **************************************************************************************
: LoadDefv3 \ ( addr Len -- addr len)

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
;
\ ***************************************************************************************
: LoadDEF \ ( addr Len -- )
\ cr s" Load Definition Table " type cr
nrdef @ maxnrvar @ <
if 
 2dup loaddefv3
 1 nrdef +! 
 dup

 next-open-def c! \ save length of name
 1 next-open-def 1 + c! \ save initial occurance
 word-type next-open-def 2 + c! \ Save word type
 next-open-def 3 + swap cmove \ Save name
 next-open-def 19 + linecount @ swap !
 next-open-def 220 + to next-open-def

else s" Maximum Nr of Definitions exceeded - " 0 30 x_gotoxy type 2 spaces maxnrvar @ .
then
;
\ **************************************************************************************
: LoadVarv3 \ ( addr Len -- addr len)

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
;
\ **************************************************************************************
: LoadVar \ ( addr Len -- )
\ cr s" Load Variable Table " type cr
nrvar @ maxnrvar @ <
if 
 2dup loadvarv3 \ new routine use disk for temp storage & increase variable count & occurances
 1 nrvar +! 
 dup
 next-open-entry c! \ save length of name
 1 next-open-entry 1 + c! \ save initial occurance
 word-type next-open-entry 2 + c! \ Save word type
 next-open-entry 3 + swap cmove \ Save name
 next-open-entry 19 + linecount @ swap !
 next-open-entry 220 + to next-open-entry

else s" Maximum Nr of Variables exceeded - " 0 32 x_gotoxy type 2 spaces maxnrvar @ .
then
;
\ ***************************************************************************************
: GotDef
\ cr s" Definition " type cr

+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
 loaddef
;
\ ***************************************************************************************
: GotCreate
\ cr s" Create " type cr
+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
loadvar
;
\ ***************************************************************************************
: GotVariable \ (addr len -- )
\ cr s" Variable " type cr
+ 1 - line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
loadvar
;
\ ***************************************************************************************
: GotCode
\ cr s" Code " type cr
2drop
;
\ ***************************************************************************************
: GotConstant
\ cr s" Constant " type cr
+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
loadvar
;
\ ***************************************************************************************
: GotComment2
\ cr s" Comment2" type cr
2drop
\ skip to end of line
line-Len @ line-offset !
;
\ ***************************************************************************************
: GotComment
\ cr s" Comment" type cr
2drop
\ skip to end of line
line-Len @ line-offset !
;
\ ***************************************************************************************
: GotString
+ line-len @ skip-spaces line-offset +!
line-len @ 0
   do dup c@ quote = swap 1 + swap 1 line-offset +!
     if drop leave then
   loop
1 line-offset +!
;
\ ***************************************************************************************
: GotValue 
\ cr s" Value" type
+ line-len @ skip-spaces line-offset +!
line-len @ endofword dup line-offset +!
loadvar
;
\ ***************************************************************************************
: GotCall
2drop
;
\ ***************************************************************************************
: Reswordid 
\ cr s" Reswordid" type
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
		83 of 22 to word-type GotString endof
		89 of 23 to word-type GotString endof
		93 of 24 to word-type GotString endof
		100 of 13 to word-type GotDef endof
		104 of 14 to word-type GotDef endof
		115 of 15 to word-type GotDef endof
	endcase
;
\ ***************************************************************************************
: Line-Load \ ( addr, len -- flag )
	\ cr s" line-load" type
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
\ cr s" Line-Parse" type
0 temp3 !
2dup Up-Case
   begin
	Line-Load 0 line-offset ! \ setup endpt startpt
	0 12 x_gotoxy msg16 zcount type linecount ? \ 8 spaces

	if
		Begin
		line-buffer line-offset @ + \ OVER + SWAP 
		   DUP C@ 32 <> swap DUP c@ 9 <> 2 roll and
		     
		       if 
			  dup c@ 13 <>
			    if
		              line-len @ endofword dup line-offset +! 1 + resword dup

		              if 3dup drop type cr reswordid
		              else
			         drop 1 - 
			         2dup Locatevar Dup 0=

				 if 2drop 2dup LocateDef then

			         if varupdate 3drop
			         else
				      3drop 
			         then

		              then

			    else line-Len @ line-offset ! drop
			    then

		       else 1 line-offset +! drop
		       then

		     line-offset @ line-len @ >= 
		until
	        
	else msg15 zcount cr cr type cr
	then

depth 2 >

if 
  depth 2 - 0 do drop loop
then

line-offset @ - swap line-offset @ + swap
\ 1 temp3 +! temp3 @ 21 =   
\ cr temp3 @ .   .s cr
 dup 0<
  until \ end of buffer
depth 0 >

if 
  depth 0 do drop loop
then
;
\ ***************************************************************************************
: Crossref

	Decimal Title Initv 
		Depth 0=
	   if  
		msg9 zcount cr cr type cr
		msg9a zcount type cr
		msg9b zcount type cr
		msg9c zcount type cr cr
		msg9d zcount type cr cr
		msg17 zcount type cr
		msg17a zcount type cr

	   else
		CXref-fileopen file-flag

		  if  \ file open successful

			s" Crossxv3.wrk" r/w create-file drop to workfile-ptr \ open work file
			0 10 x_gotoxy MSG10 zcount type file-name count type
			msg10 zcount workfile-buffer swap cmove
			
			work-file-write
			workfile-ptr file-position 2drop to eof-ptr

			Begin
			infile-buffer-ptr inb-len @ infile-ptr read-file
				drop bytes-read ! 

			infile-buffer-ptr inb-len @ LineParse

			infile-len bytes-read @ - dup to infile-len 0=
			until

			Report PReport if P-Report then 
			report-sortv3 reportv3 PReport if P-Reportv3 then

			file-flag if infile-ptr close-file drop then  \ Close input file
			workfile-ptr close-file drop \ close work file

			infile-buffer-ptr 	\ Release allocated memory
			if infile-buffer-ptr free drop then

			proc-area-ptr 		\ Release allocated memory
			if proc-area-ptr free drop then

			Def-area-ptr 		\ Release allocated memory
			if Def-area-ptr free drop then

		  else  msg13 zcount cr cr type s"  - " type file-name count type cr cr

		  then

	   then
;
\ ***************************************************************************************

 