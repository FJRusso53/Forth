\ Cross-reference Utility Header File
\ Crossx.F
\ Frank J. Russo
\ Date 070917
\
768 constant wfrec
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
false value ?include
0 value fileinuse
\ Variables
Variable nrvar
Variable nrdef
Variable nroccur 255 nroccur !
Variable linecount
Variable Tlinecount
Variable maxnrvar 1820 maxnrvar !
Variable bytes-read
Variable Inb-Len
Variable Line-len
Variable Line-offset
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
\ 36 bytes per name
0 nostack1
0 char+ field+ Occurances
0 char+ field+ wrdtype
1 char+ field+ diskaddress
0 char+ field+ nlength
26 char+ field+ dname
3 char+ field+ Dhash
constant table-size
\
0 nostack1
3 char+ field+ File-ptr
3 char+ field+ Filesize
3 char+ field+ Bytread
3 char+ field+ FBuf-ptr
3 char+ field+ LnOffset
3 char+ field+ lncount
0 char+ field+ inclFile
constant include-size
\
Create file-names 1024 allot file-names 1024 erase
Create workfile-buffer 1024 Allot workfile-buffer 1024 erase
Create line-buffer 512 Allot line-buffer 512 erase
Create file-name 127 Allot file-name 127 erase
Create temp-ptr-area 36 allot temp-ptr-area 36 erase
create temp1$ 8 allot temp1$ 8 erase
create w-display 10 80 * allot w-display 10 80 * erase
create QUOTE$ char " c,
create Incl-state include-size allot Incl-state include-size erase
\ Message Area
create msg1 z," Cross-Reference Utility"
create msg2 z," Version 4.00 - 080101"
create msg3 z," Developed by Frank J. Russo"
create msg4 z," Nr# of Variables Identified: "
create msg5 z," Nr# of Definitions Identified: "
create msg6 z," Nr# of Lines Processed:  "
create msg7 z," Nr# of Included Files: "
create msg8 z,"  - Completed"
create msg8A z," Word Name                  Occurances  Line #'s"
create msg9 z," Proper usage"
create msg9A z,"         1st FLOAD this utility"
create msg9B z,"         2nd put the name of your file on the stack s" quote$ 1 +z",
	    +z,"  file.f" quote$ 1 +z",
create msg9c z,"         3rd enter Crossref (or s" quote$ 1 +z", +z,"  file.f" quote$ 1 +z", +z,"  crossref)"
create msg9d z," Program Limitations - Maximum # of Definitions = 1820 and Variables = 1820"
create msg9e z,"         Tracks each variable / definition for a maximum of 255 occurances"
create msg9f z,"         Naming lengths limited to 27 characters (Will be Truncated if longer)"
create msg10 z," Processing File - "
create msg13 z," Failure on opening file"
create msg16 z," Processing Line # - "
create msg17 z," A report will appear on the screen"
create msg17a z," To send a report to the printer enter 'True to PREPORT' prior to executing program"
