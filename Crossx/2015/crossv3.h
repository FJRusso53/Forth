\ Cross-reference Utility Header File
\ Crossx.F
\ Frank J. Russo
\ Date 050831

\ Pointers
0 value bufptr 
0 value msgptr 
0 value infile-ptr
0 value infile-buffer-ptr
0 value file-flag
0 value Def-area-ptr
0 value proc-area-ptr
0 value infile-len
0 value next-open-Def
0 value next-open-entry
0 value PReport
34 value quote
0 value temp1-ptr
0 value temp2-ptr
0 value temp3-ptr
0 value word-type
0 value workfile-ptr
0 value eof-ptr
0 value workfile-position
0 value workfile-count
0 value var-table
0 value var-table-offset
0 value Def-table
0 value Def-table-offset

\ Constants
13 Constant Carrige-rtn
10 Constant Line-feed

\ Variables
Variable nrvar
Variable nrdef
Variable nroccur
Variable linecount
Variable linenr
Variable maxnrvar
Variable bytes-read
Variable Inb-Len
Variable Line-len
Variable Line-offset
Variable temp3
Variable temp1
Variable plines

Create TextBuffer 120 Allot TextBuffer 120 erase
Create search-param 96 allot search-param 96 erase
Create workfile-buffer 1024 Allot workfile-buffer 1024 erase
Create line-buffer 512 Allot line-buffer 512 erase
Create file-name 64 Allot file-name 64 erase
Create temp-ptr-area 220 allot temp-ptr-area 220 erase
create QUOTE$ char " c,

\ Message Area
create msg1 z," Cross-Reference Utility"
create msg2 z," Version 2.0 - 050824"
create msg3 z," Developed by Frank J. Russo"
create msg8 z,"  - Completed"
create msg8A z," Word Name                  Occurances        Line #'s"
create msg9 z," Proper usage" 
create msg9A z,"         1st FLOAD this utility" 
create msg9B z,"         2nd put the name of your file on the stack s" quote$ 1 +z", 
	    +z,"  file.f" quote$ 1 +z", 
create msg9c z,"         3rd enter Crossref (or s" quote$ 1 +z", +z,"  file.f" quote$ 1 +z", +z,"  crossref)"

create msg9d z," Program Limitations - Maxuimum # of Definitions = 297 and Variables = 297"
create msg10 z," Processing File - "
create msg13 z," Failure on opening file"
create msg14 z," : :M \ ( CREATE VARIABLE FVARIABLE 2VARIABLE VALUE CODE CONSTANT "
	    +z," FCONSTANT 2CONSTANT S" quote$ 1 +z", +z,"  Z," quote$ 1 +z", 
	    +z,"  +Z," quote$ 1 +z", +z,"  "
	    +z," CALL INCLUDE NEEDS :OBJECT "
create msg15 z," Failure to load line into bufffer"
create msg16 z," Line # - "
create msg17 z," A report will appear on the screen"
create msg17a z," To send a report to the printer enter 'True to PREPORT' prior to executing program"
create msg18 z," File - "
 