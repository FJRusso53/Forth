\ Win-Crossxref-21.F
\ Frank J. Russo
\ Version 5.2 211118
\
Needs Resources.f
\
Anew Cross-Xref
\ ********************************************************************************
False value turnkey?
\
chdir \programming\Win32Forth\proj\crossx
Include \Programming\Win32Forth\include\file-emit.f
Include win-crossx-22.h \ Header File
\
Defer menubegin#
Defer MenuClose-display#
Defer menufileclose#
Defer menufileopen#
Defer xref-Window#
\
\ ********************************************************************************
\
: CHANNEL ( row struc-size -< name >- )
\ Array code for Psi - En - Aud memory channel arrays.  Rewritten FJR 061118
 CREATE   ( Returns address of newly named channel. )
 dup ,    ( Stores size of rows from stack To array.)
 * MALLOC , ( Reserves given quantity of cells for array.)
 DOES>    ( member; row -- a-addr )
 Tuck @ * swap cell+ @ +
;
\
\ ********************************************************************************
30 hash-size CHANNEL hash{ ( Hash Table )
0 hash{ 1+ hash-size 24 * 1- erase
\ ***************************************************************************************
\
: hash-build ( Add Len -- )
2Dup  \ save the name & address
-1 "#hash
1 +to hash-count
hash-count hash{ !
hash-count dup hash{ hloc W!
dup hash-count hash{ wleno c!
hash-count hash{ HName swap cmove
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
\ s" (( "		hash-build
s" : "  	        hash-build
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
s" FIELD+ "	hash-build
s" \S "		hash-build
\ s" $SHELL "	hash-build
;
\
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
	  IF
	    infile-ptr close-file To infile-ptr 0 To file-flag \ Close input file
	    file-name count erase 0 file-name !
	    w-display dup 9 80 * 18 + + 60 0 fill
	    file-flag enable: MenuBegin#
	    False enable: Menufileclose#
            True enable: MenuFileOpen#
	  Then
;
\ ***************************************************************************************
: Cxref-Mem-deallot
\ Release allocated memory
\ Arranged in order from last allocated To first
\
        text-ptr 	  	  ?dup IF Free To text-ptr Then
	def-table           ?dup IF Free To def-table Then
	var-table 	  ?dup IF Free To var-table Then
	infile-buffer-ptr ?dup IF Free To infile-buffer-ptr Then
	line-tbl 	  	  ?dup IF Free To line-tbl Then
	['] hash{ >body cell+ @   Free drop
\
;
\ ***************************************************************************************
: Cxref-fileopen \ ( file name n -- )

0 To file-flag \ set default flag condition

dup not IF drop count Then ?dup \ check To see IF a file was selected or cancel selected
IF
  dup file-name ! file-name 1+ swap cmove 	\ get file name & save at file-name location
  file-name dup 1+ swap c@ r/o open-file 0=	\ attempt To open input file r/o read only
  IF
\
    1 To file-flag
    1 file-count +! file-count @ To fileinuse \ success opening
    file-flag enable: MenuBegin#
    file-name count
    w-display 9 80 * 18 + + dup zcount erase
    swap cmove
    dup To infile-ptr file-size 2drop To infile-len  \ save file pointer get file length
    infile-len 1000 Max 1000 / 1+ 1000 * \ Round up next 1000 bytes
    65535 min dup \ space To allocate for file buffer max of 64K
    malloc To infile-buffer-ptr    \ calc & allocate buffer space up To 64K (FFFFh) size
    dup inb-len ! infile-buffer-ptr swap erase  \ clear space
    file-name count dup file-names zcount + dup >r ! r> 1+ swap cmove
\
  Else 2drop 0 To file-flag   \ File open failure
  Then
Else drop
Then
    file-flag enable: MenuFileclose#
   False enable: MenuFileOpen#
;
\ ***************************************************************************************
: cxref-mem-allot
\
    65535 malloc To Var-table \ Variable table holds 1638 names
\
\ table-size bytes per name
\ Occurances - 2
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 30
\ hash - 4
\
   var-table 65535 erase \ clear space
\
   65535 malloc To Def-table \ Definition table holds 1638 names
\
\ table-size bytes per name
\
\ Occurances - 2
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 30
\ hash - 4
\
   Def-table 65535 erase \ clear space
\
;
\ ***************************************************************************************
: center-page \ ( count --- offset - pixels) \ Midpoint of a line
	nrcol# 2/ char-width * \ Center of page
	swap   2/ char-width * -
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
: Line-Format
	outline-buffer 128 erase
	outline-buffer swap 32 fill
	outline-buffer zcount + swap cmove
	outline-buffer zcount outfile-ptr write-line drop
;
\ ***************************************************************************************
: Title
	msg1 zcount center-dertm Line-Format
	msg2 zcount center-dertm Line-Format
	msg3 zcount center-dertm Line-Format
	outline-buffer 128 erase
	0dh outline-buffer c! outline-buffer 1+ 50 32 fill
	get-local-time time-buf dup
	>date" outline-buffer zcount + swap cmove
	2020h outline-buffer zcount + !
	>time" outline-buffer zcount + swap cmove
	outline-buffer zcount outfile-ptr write-line drop
;
\ ***************************************************************************************
: Title1
	outline-buffer 128 erase
	0dh outline-buffer c! outline-buffer 1+ 50 32 fill
	get-local-time time-buf dup
	>date" outline-buffer zcount + swap cmove
	2020h outline-buffer zcount + !
	>time" outline-buffer zcount + swap cmove
	outline-buffer zcount outfile-ptr write-line drop
	outline-buffer 128 erase
	msg10 zcount outline-buffer swap cmove
	file-name count outline-buffer zcount + swap cmove
	msg8 zcount outline-buffer zcount + swap cmove
	0dh outline-buffer zcount + c!
	outline-buffer zcount outfile-ptr write-line drop
	outline-buffer 128 erase
	0dh outline-buffer c!
	msg8A zcount outline-buffer zcount + swap cmove
	0dh outline-buffer zcount + c!
	outline-buffer zcount outfile-ptr write-line drop
;
\ ***************************************************************************************
: Title2 ( N, Adr, L --  )
	outline-buffer 128 erase
	outline-buffer swap cmove
	s>d (d.) outline-buffer zcount + swap cmove
	2920h outline-buffer zcount + !
	0dh outline-buffer zcount + c!
	outline-buffer zcount outfile-ptr write-line drop
;
\ ***************************************************************************************
: New-Page
   PReport 2 = plines @ 60 > and
   IF
	Title1
	msg1 zcount center-dertm Line-Format
	msg2 zcount center-dertm Line-Format
	outline-buffer 128 erase
	outline-buffer 84 95 ( _ )  fill
	0dh outline-buffer zcount + c!
	outline-buffer zcount outfile-ptr write-line drop
	11 plines !
	outline-buffer 128 erase
  Then
;
\ ***************************************************************************************
Turnkey? Not   \ Not generating an executable Turnkey? = False
[IF]
s" Inserting Colon definitions for Test1, Test2 & Test3" cr type cr
\
: test1
hash-count 1+ 1 cr
do
  i dup 3 .r 2 spaces hash{ @ .
  20 spaces ( 50 getxy swap drop  gotoxy )
  I hash{ wleno c@
  I hash{ Hname swap type cr
loop
;
\ ***************************************************************************************
: test2
cr
nrvar @ dup 1 >
IF
1 cr
do
  i dup 3 .r 2 spaces table-size * var-table + dup dname zcount type
  dhash @ 20 spaces . cr ( 50 getxy swap drop  gotoxy . cr)
loop
Else drop
Then
;
\ ***************************************************************************************
: test3
Cls
test1 cr
test2 cr
Cxref-Fileclose
Cxref-Mem-deallot
;
[ENDIF]
\ ***************************************************************************************
: Init-vars
1 nrvar ! 1 nrdef ! 0 plines !
0 To temp1-ptr
0 To temp2-ptr
0 To word-type
0 To eof-ptr
0 To workfile-count
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
\
\ Occurances - 2  -  Occurances limited To 1024
\ type - 1
\ disk address - 2
\ name length - 1
\ name - 30
\ hash - 4
\
2 0 Do  cr
	i 0=
		IF nrvar var-table  \ First time though sort the Variable Table
		Else nrdef def-table \ second time through sort the definition table
		Then
	To str1 @ dup temp1 !
	1 >
\
	IF
		temp-ptr-area To temp3-ptr
		str1 To temp1-ptr
\
		temp1 @ 1 Do temp1 @ I temp1-ptr table-size + To temp2-ptr
\
			 Do
				 temp1-ptr 6 + 27 temp2-ptr 6 + 27 compare
				 1 =
				 IF \ second item in list is smaller than first item
					temp1-ptr temp3-ptr table-size cmove
					temp2-ptr temp1-ptr table-size cmove
					temp3-ptr temp2-ptr table-size cmove
				Then
\
				table-size +To temp2-ptr
			Loop
\
			table-size +To temp1-ptr
		  Loop
\
	Then
\
Loop
;
\ ***************************************************************************************
: Reportv3
\
0 plines !
Title  6 plines +!
outline-buffer 128 erase
0dh outline-buffer c!
msg10 zcount outline-buffer zcount + swap cmove
file-names count 2dup
outline-buffer zcount + swap cmove
w-display 9 80 * 18 + + dup zcount erase swap cmove
msg8 zcount outline-buffer zcount + swap cmove
\
outline-buffer zcount outfile-ptr write-line drop
outline-buffer 128 erase
Msg4 zcount outline-buffer swap cmove
nrvar @ 1-  s>d (d.)
outline-buffer zcount + swap cmove
\
outline-buffer zcount outfile-ptr write-line drop
outline-buffer 128 erase
Msg5 zcount outline-buffer swap cmove
nrdef @ 1- s>d (d.)
outline-buffer zcount + swap cmove
\
outline-buffer zcount outfile-ptr write-line drop
outline-buffer 128 erase
Msg6 zcount outline-buffer swap cmove
Tlinecount @ s>d (d.)
outline-buffer zcount + swap cmove
\
outline-buffer zcount outfile-ptr write-line drop
outline-buffer 128 erase
winpause
file-count @ 1- ?dup
IF
   file-names count + swap
   outline-buffer 128 32 fill
   Msg7 zcount swap over outline-buffer swap cmove
   swap s>d (d.) rot outline-buffer + swap cmove
   outline-buffer 28 outfile-ptr write-line drop
   outline-buffer 128 32 fill
   [char] - outline-buffer 3 + c!
   file-count @ 1-
    0 Do
	dup count dup I swap  >r 65 + outline-buffer 1+ c!
	outline-buffer 5 + swap cmove
	outline-buffer 90 outfile-ptr write-line drop
	r> + 1+
    Loop
drop
Then
	outline-buffer 128 erase
	0d0dh outline-buffer !
	msg8A zcount outline-buffer zcount + swap cmove
	outline-buffer zcount outfile-ptr write-line drop
	outline-buffer 128 erase
	outline-buffer 84 95 ( _ )  fill
	outline-buffer zcount outfile-ptr write-line drop
11 plines +!
2 0 Do  cr 1 plines +!
	i 0=
		IF      var-table nrvar @ 1- S" Variables:    ( "  Title2 2 plines +!
		Else def-table nrdef @ 1- S" Definitions:  ( "  Title2 2 plines +!
		Then
	To str1
	i 0=
		IF nrvar   \ put # variable on stack
		Else nrdef \ put # definitions on stack
		Then
	@ dup 0>
	IF
	 1 Do
	      I table-size * str1 +
	      dup dname over nlength c@ dup >r type
	      27 r> - 2 + spaces
	      dup Occurances w@ dup 3 .r 6 spaces
	      swap diskaddress w@ wfrec *
	      0 workfile-ptr reposition-file drop
		\ read from disk file record containing the line #'s where name was found
		work-file-read
	      0 Do
		  workfile-buffer i 3 * + dup c@ swap 1+ w@ swap
		  i 0> IF i 8 /mod drop 0=  \ Looking for a multiples of 8

		          IF cr 1 plines +! new-page 38 spaces Then \ advance To next line
		       Then
		  dup 1 = IF drop bl Else 63 + Then emit
		  5 .r ."  "
		Loop

		cr 1 plines +! new-page
	  Loop
	Else drop
	Then
s" ____________________________________________________________________________________"
type cr 1 plines +! new-page
Loop
	s" You can view the results in the file crossref.txt" type cr
	ms@ StartTime -  . ." milliseconds To process" cr
	winpause
;
\ ***************************************************************************************
: Skip-Spaces \ (addr len -- addr count)
\ s" Skip Spaces " type
swap To str1
0 swap 0 Do
	   str1 c@ bl <>
	   IF leave
	   Else 1+
	   Then
	   1 +To str1
         Loop
str1 swap
;
\ ***************************************************************************************
: endofword \ ( addr -- addr N )
\ cr s" endofword" type
\ Looking for a space or CR ()OD
dup line-len @ line-offset @ - 0
Do
  dup c@ 33 <
  IF I swap leave Then
  1+
Loop
drop
;
\ ***************************************************************************************
: resword  \ ( Addr2 len2 -- addr2 Len2 F )

 2dup dup 1 = IF 1+ Then \ increase length by 1 To add space
-1 "#Hash
\ Search hash table for a match
hash-count 1+ 1

Do
  dup i hash{ hashv @ over over
  = IF 3drop i unloop exit ( i -1 leave) Then
  swap > IF 0 unloop exit ( leave) Then
Loop
0
( 0< IF >r 3drop r> -1 Else 0 Then )
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
workfile-ptr file-position 2drop wfrec - 0  \ back up To begining of last record read
workfile-ptr reposition-file
work-file-write drop
eof-ptr 0 workfile-ptr reposition-file \ go To end of file
drop
;
\ ***************************************************************************************
: Crx-search ( addr len hash tableaddr count -- addr len flag )
dup IF
     1+ 1 Do
	    2dup I table-size * + dhash @
	    = IF nip I table-size * + -1 unloop exit ( 0 leave) Then
	  Loop
    Else drop
    Then
2drop 0
\ IF 0 Else -1 Then
;
\ ***************************************************************************************
: LoadDefv3 \ ( addr Len -- addr len)
nrdef @ maxnrvar @ <
IF
	to temp1-ptr
	to temp2-ptr
	1 +to workfile-count
	nrdef @ table-size * To def-table-offset  \ offset into the definition table
	1 def-table-offset def-table + c! \ save initial occurance
	word-type def-table-offset def-table + wrdtype c! 		\ Save word type
	workfile-count def-table-offset def-table + diskaddress W! 	\ Save disk location 2 bytes
	temp1-ptr def-table-offset def-table + nlength c! 		\ save length of name
	temp2-ptr def-table-offset def-table + dname temp1-ptr cmove 	\ Save name
	temp2-ptr temp1-ptr -1 "#hash
	def-table-offset def-table + dhash !				\ save name hash value
	\ write info To disk
	workfile-buffer dup fileinuse swap c! 1+
	linecount @ swap w!
	work-file-write
	workfile-ptr file-position 2drop To eof-ptr
	1 nrdef +!

Else
	StartPos: xref-Window#
        200 + swap 200 + swap message-origin
        s" Maximum Nr of Definitions exceeded..." "message
        1000 ms message-off
Then
;
\ ***************************************************************************************
: LoadVarv3 \ ( addr Len -- )
nrvar @ maxnrvar @ <
IF
	To temp1-ptr
	To temp2-ptr
	1 +To workfile-count
	nrvar @ table-size * To var-table-offset   \ offset into the variable table
	1 var-table-offset var-table +  c! \ save initial occurance
	word-type var-table-offset var-table + wrdtype c! 	     \ Save word type
	workfile-count var-table-offset var-table + diskaddress W!   \ Save disk location 2 bytes
	temp1-ptr var-table-offset var-table + nlength c! 	     \ save length of name
	temp2-ptr var-table-offset var-table + dname temp1-ptr cmove \ Save name
	temp2-ptr temp1-ptr -1 "#hash
	var-table-offset var-table + dhash !
	\ write info To disk
	workfile-buffer dup fileinuse swap c! 1+
	linecount @ swap w!
	work-file-write
	workfile-ptr file-position 2drop To eof-ptr
	1 nrvar +!

Else
	StartPos: xref-Window#
        200 + swap 200 + swap message-origin
        s" Maximum Nr of Variables exceeded..." "message
        1000 ms message-off
Then
;
\ ***************************************************************************************
: New-Get \ (addr len -- Addr len)

+ line-len @ line-offset @ -
skip-spaces 1+ line-offset +!
endofword dup line-offset +!
\ check To see IF name length is > 26
\ dup 26 >
\ IF drop 26 Then
;
\ **************************************************************************************
: GotComment2 \ (addr len -- )

drop dup line-len @ line-offset @ - s" )" search \ Locate ' ) '
IF
drop swap - line-offset +!
Else 3drop line-Len @ line-offset ! \ skip To end of line
Then
;
\ ***************************************************************************************
: GotComment \ (addr len -- )

2drop
\ skip To end of line
line-Len @ line-offset !
;
\ ***************************************************************************************
: GotString \ (addr len -- )
word-type 18 < \ S" Z," +Z," ."
IF
+ line-len @ skip-spaces line-offset +!
line-len @ 0
   Do dup c@ quote = swap 1+ swap 1 line-offset +! \ locate next " ignoring everything in between
     IF drop leave Then
   Loop
1 line-offset +!

Else 2drop  \ +z", ignore

Then

;
\ ***************************************************************************************
: Incl-done
\ On Completion of Included File
\ Close file
infile-ptr close-file drop incl-state File-ptr @ To infile-ptr
\ release memory
infile-buffer-ptr Free drop
\ reload Previous State
incl-state FBuf-ptr @ dup To infile-buffer-ptr
incl-state Lncount  @ linecount !
incl-state Filesize# @ inb-len !
incl-state Bytread  @ bytes-read !
incl-state LnOffset @ dup line-offset !
incl-state inclFile c@ To fileinuse
false To ?include
rot drop 0
\
;
\ ***************************************************************************************
: Gotinclude \ (addr len -- )
\ ? Already processing an included file IF so ignore
?include IF 2drop exit Then
New-Get
line-Len @ line-offset ! \ remainder of line ignored
\ save existing info To be recalled later
true To ?include
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
 IF
	\ Load new state
	infile-buffer-ptr bytes-read @
	0 linecount  !
 Else
	incl-state FBuf-ptr @
	incl-state bytread @
	-1 To file-flag
 Then
\
;
\ ***************************************************************************************
: GotCall \ (addr len -- )

\ get definition
+ line-len @ skip-spaces line-offset +!
endofword dup line-offset +!
\ check To see IF name length is > 26
26 min
\ locate definition IF found update
2dup
2dup -1 "#Hash def-table nrdef @ Crx-search
nrdef @ table-size * =
\ Not found Load into Def Table
IF
drop
loaddefv3
Else drop
Then
;
\ ***************************************************************************************
: Reswordid

	case
		1 of 13 To word-type New-Get loaddefv3  ( GotDef) endof \ :Object
		2 of 23 To word-type GotCALL endof 	\ CALL
		3 of 12 To word-type New-Get loaddefv3 ( Code) endof \ CODE
		4 of 16 To word-type GotString endof 	\ +z,"
		5 of 21 To word-type GotComment2 endof 	\ '('
		6 of 10 To word-type New-Get loaddefv3  ( GotDef) endof \ ':'
		7 of 20 To word-type GotComment endof 	\ '\'
		8 of 14 To word-type GotString endof 	\ .",
		9 of 11 To word-type New-Get loaddefv3  ( GotDef) endof \ :M
		10 of 14 To word-type GotString endof 	\ S"
		11 of 24 To word-type GotInclude endof  \ INCLUDE
		12 of 17 To word-type GotString endof 	\ +z",
		13 of 15 To word-type GotString endof 	\ z,"
		14 of 6 To word-type New-Get loadvarv3 ( GotConstant) endof
		15 of 7 To word-type New-Get loadvarv3 ( GotConstant) endof
		16 of 8 To word-type New-Get loadvarv3 ( GotConstant) endof
		17 of 1 To word-type New-Get loadvarv3 ( GotVariable) endof
		18 of 2 To word-type New-Get loadvarv3 ( GotVariable) endof
		19 of 3 To word-type New-Get loadvarv3 ( GotVariable) endof
		20 of 13 To word-type New-Get loaddefv3 endof	\ :MENUITEM
		21 of 30 To word-type New-Get loadvarv3 ( GotCreate)  endof
		22 of 13 To word-type New-Get loaddefv3 endof	\ NEEDS
		23 of 13 To word-type New-Get loaddefv3 endof	\ DEFER
		24 of 5  To word-type New-Get loadvarv3 ( GotValue) endof
		25 of 9  To word-type New-Get loadvarv3 ( GotConstant) endof
		26 of 20 To word-type GotComment endof 	\ '\s'
	endcase

;
\ ***************************************************************************************
: display-update ( n -- adr n ) \ Updated 211118
\
temp1$ 8 32 fill
(.) \ >string
temp1$ over swap c!
temp1$ count drop swap cmove
temp1$ count drop 5
;
\ ***************************************************************************************
: LineParse \ ( addr, len -- flag)
	1 Tlinecount +! \ Tlinecount @  1988 = IF breaker Then
	1 linecount +!
	DUP line-len !
	2dup UPPER \ convert input steam To upper case

		( Line-Load )
		line-buffer zcount erase
		over line-buffer bytes-read @ cmove
		0 line-offset !  		   \ setup endpoint startpoint
		Nrvar @ 1- display-update
		w-display 80 5 * + 29 + swap cmove \ Move line count To display
		Nrdef @ 1- display-update
		w-display 80 6 * + 31 + swap cmove \ Move line count To display
		linecount @ display-update
		w-display 80 7 * + 24 + swap cmove \ Move line count To display

		Begin
		   line-buffer line-offset @ + \
		   DUP C@ bl <> swap DUP c@ 9 <> 2 roll and \ Check for space and tab

		       IF
			  dup c@ 13 <> \ check for CR
			    IF
		              endofword dup line-offset +! 1+ resword dup

		              IF reswordid

		              Else
			         2drop 1- 2dup -1 "#Hash var-table nrvar @ Crx-search

				 IF varupdatev3
				   Else
				      2dup -1 "#Hash def-table nrdef @ Crx-search IF varupdatev3 Else 2drop Then
				 Then

		             Then

			    Else line-Len @ line-offset ! drop
			    Then

		       Else 1 line-offset +! drop
		       Then

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
                FALSE To alreadyPainting
                FALSE To paintAgain
		TRUE To hidden?
                char-width        Width: bFont
                char-height      Height: bFont
                s" Courier" SetFacename: bFont
                ;M

:M On_Paint:    ( -- )          \ screen redraw procedure
                SaveDC: dc                      \ save device context
                Handle: bFont SetFont: dc       \ set the font To be used
                text-ptr ?dup
                IF      screen-rows 0
                       ?do      char-width char-height i *      \ x, y
                                line-cur i + #line"
                                col-cur /string
                                screen-cols min                 \ clip To win
                                TabbedTextOut: dc
                                word-split drop                 \ x
                                char-width +                    \ extra space
                                i char-height *                 \ y
                                over char-width / >r
                                spcs screen-cols r> - 0max      \ at least zero
                                spcs-max min TextOut: dc        \ and less than max
                        Loop    2drop
                THEN
                using98/NT? 0=          \ only support variable sized scroll bars in Windows98 and WindowsNT
                line-last 32767 > OR    \ IF we have a big file, revert To non-resizable scroll buttons
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
                        screen-rows To nPage
                        line-cur To nPos
                        0 To nMin
                        line-last To nMax
                        SIF_ALL To fMask
                        TRUE LPWinScrollInfo SB_VERT
                        GetHandle: self Call SetScrollInfo drop

                        screen-cols To nPage
                        col-cur To nPos
                        0 To nMin
                        max-cols To nMax
                        SIF_ALL To fMask
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
                IF      dup To hidden?
                        IF           SW_HIDE       Show: self
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

:M VPosition:   ( n1 -- )       \ move To line n1 in file
                0max line-last 1+ screen-rows 1- - 0max min To line-cur
                ;M

:M HPosition:   ( n1 -- )       \ move To column n1
                0max max-cols 1+ screen-cols 1- - 0max min To col-cur
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
:M On_Init:             ( -- )
   On_Init: super
   Self Start: Display-WINDOW         \ Then startup the editor child window
;M
\
:M ClassInit:  ( -- ) ClassInit: super   ;M
:M WindowStyle:         ( -- style )  WS_OVERLAPPED WS_SYSMENU OR ;M
:M ParentWindow:        ( -- hwndParent | 0=NoParent )    parent        ;M
:M SetParent:           ( hwndparent -- )       To parent               ;M
:M WindowHasMenu:       ( -- f )                true                    ;M
\
:M On_Paint:    \ ( --- ) all window refreshing is done by On_Paint:

		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc

                \ set the backgroundcolor for text To ltblue
                ltblue SetBkColor: dc

                \ and set the Textcolor To yellow
                ltyellow SetTextColor: dc

		w-display zcount nip center-page 0
			w-display zcount textout: dc \ Title Display
		w-display 80 + zcount nip center-page char-height
			w-display 80 + zcount textout: dc \ Author Display
		w-display 160 + zcount nip center-page char-height 2*
			w-display 160 + zcount textout: dc \ Version Display
		nrcol# 25 - char-width * dup char-height 3 *
		w-display 240 + zcount textout: dc \ Date & Time Display
		10 5 Do I
			w-display i 80 * + zcount
			?dup
			  IF
			     2>R char-height * 5 swap 2r> textout: dc
			  Else 2drop
			  Then
		     Loop
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
		   turnkey? IF bye Then \ terminate application
;M
\
:M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
                over 0xF000 and 0xF000 <>
                IF      over LOWORD
                        DoMenu: CurrentMenu
                        0
                Else    DefWindowProc: [ self ]
                Then
;M
\
:M msgBox: ( z$menu z$text - ) swap MB_OK   MessageBox: Self drop       ;M
\
;Object
' xref-Window is xref-Window#
\
\ ***************************************************************************************
\
\       Setup the line pointers and scroll bar for a new file
\
: set-line-pointers ( -- )
                wait-cursor
                1 To line-last          \ one total lines To start
                text-ptr line-tbl !     \ init first line
                1 +to line-cur          \ bump To next line pointer
                text-ptr text-len
                begin   0x0D scan dup
                while   2 /string over line-tbl line-cur    cells+ !
                        1 +to line-cur                  \ bump current line
                        max-lines line-cur =            \ while not full
                        IF      4000 +to max-lines
                                max-lines 4 + cells line-tbl realloc
                                s" Failed To adjust the line pointer table"
                                ?TerminateBox
                                To line-tbl
                        Then
                repeat  drop  dup      line-tbl line-cur    cells+ !
                                       line-tbl line-cur 1+ cells+ !
                line-cur To line-last                   \ set total lines
                0 To line-cur
                arrow-cursor
;
\
\ ***************************************************************************************
\
: set-longest-line ( -- )
                wait-cursor
                0
                line-last 1+ 0
                Do      i #line" nip max
                Loop    2 + To max-cols
                arrow-cursor
;
\
\ ***************************************************************************************
\
: Open-Display-file    ( a1 n1 -- )
                2dup r/o open-file 0=
                IF
			StartPos: xref-Window
                        200 + swap 200 + swap message-origin
                        s" Reading Text File..." "message
\
                        >r 127 min cur-filename place
                        \ release/allocate the text buffer
                        text-ptr ?dup IF Free drop Then
                        r@ file-size 2drop To text-len
                        text-len 10000 + To text-blen
                        text-blen malloc To text-ptr
\
                        \ release/allocate line pointer table
                        line-tbl ?dup IF Free drop Then
\
                        1000 To max-lines
                        max-lines 4 + cells malloc To line-tbl
                        \ read the file into memory
                        text-ptr text-len r@ read-file drop
                        To text-len
                        r> close-file drop
                        set-line-pointers
                        set-longest-line
\
                        300 ms message-off
			false enable: MenuBegin#
			false hide: display-window
                        Refresh: display-window
\
                Else    2drop drop
\
                Then
;
\
\ ***************************************************************************************
\
: Close-display
	false enable: MenuClose-display#
	text-ptr ?dup IF Free drop Then
	line-tbl ?dup IF Free drop Then
	0 To line-last
	0 To line-cur
	erase: display-window
	true hide: display-window
	Paint: xref-Window
;
\
\ ***************************************************************************************
\
: Main-Process-loop ( -- )
\
	Begin
	infile-buffer-ptr inb-len @ infile-ptr read-line \ up To max 64K
	drop swap 1+ bytes-read !
\
	IF
	  infile-buffer-ptr bytes-read @
	  LineParse \ begin processing file lines
	Else -1
	Then
	dup ?include and IF incl-done Then
	Until
;
\
\ ***************************************************************************************
\
: Crossref
\
	file-flag \ If file is open process
\
		  IF  \ file open successful
			false enable: MenuBegin#
			true enable: MenuClose-display#
			depth To stacksize
			w-display 80 5 * + dup 80 erase msg4 zcount rot swap cmove
			w-display 80 6 * + dup 80 erase msg5 zcount rot swap cmove
			w-display 80 7 * + dup 80 erase msg6 zcount rot swap cmove
			Paint: xref-Window
			s" Crossxv3.wrk" r/w create-file drop To workfile-ptr \ open work file
			msg10 zcount workfile-buffer swap cmove
\
			work-file-write
			workfile-ptr file-position 2drop To eof-ptr
\
			ms@ to StartTime \ get present time
			Main-Process-loop
\
			msg8 zcount w-display 80 9 * + zcount + swap cmove
 			report-sortv3
\
			\ Open Output Report File
			s" Crossref.txt" r/w create-file abort" file-Open error"
			dup to outfile-ptr FdEmit>File ! ..
			>file reportv3
			s" You can view the results in the file crossref.txt" type cr
			ms@ r> -  . ." milliseconds to process" cr >screen
			outfile-ptr close-file To outfile-ptr \ close report file
			workfile-ptr close-file To workfile-ptr \ close work file
			s" Crossxv3.wrk" delete-file drop
			s" Crossref.txt" open-display-file
		  Then
\
\ 		  sp0 @ stacksize 4 * - sp! \ RESET THE DATA STACK
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
\
    POPUP "Help"
        MENUITEM        "&Info"
                        z" Info"
                        z" Win32Forth Cross-Reference Utility \n Developed By F J Russo"
                        msgBox: xref-Window                   	;
    POPUP "Process"
        :MENUITEM        menubegin "&Begin... \tCtrl-B" Crossref ;
	:MENUITEM	 MenuClose-display "Close-&Display... \tCtrl-D" Close-display ;
\
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
   Init-vars init-hash
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
   cxref-mem-allot
\
   start: xref-Window
   ApplicationBar SetMenuBar: xref-Window
   Paint: xref-Window
   file-flag enable: MenuBegin
   False enable: MenuClose-display#
   False enable: MenuFileClose
;
\
 turnkey?
 [IF]
         ' cxref Turnkey Crossref21.exe
          s" WIN32FOR.ICO"  s" Crossref21.exe" AddAppIcon
	  s" Completed " cr type cr
 [ELSE]
s" Completed " cr type cr
\ cxref
 [ENDIF]
\
\s
