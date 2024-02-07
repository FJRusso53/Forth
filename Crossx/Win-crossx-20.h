\ Win-Crossxref-20.H
\ Frank J. Russo
\ Version 5.1 208006
\
Decimal \ Numeric Base
\
1024 Constant wfrec
\
0 Value stacksize
0 Value infile-ptr
0 Value infile-buffer-ptr
0 Value file-flag
0 Value infile-len
0 Value PReport
0 Value temp1-ptr
0 Value temp2-ptr
0 Value temp3-ptr
0 Value word-type
0 Value workfile-ptr
0 Value eof-ptr
0 Value workfile-count
0 Value var-table
0 Value var-table-offset
0 Value Def-table
0 Value Def-table-offset
0 Value hash-count
0 Value include-ptr
0 Value fileinuse
90 Value nrcol#
34 Value nrrow#
34 Value quote
False Value ?include
\
\ Variables
\
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
3 char+ field+ hashv    	\ Hash value of the word concept 4 byte Word
3 char+ field+ dict-loc 	\ offset into dictionary
1 char+ field+ Hloc	\ table location
0 char+ field+ wleno    	\ length of the word
dup 12 swap - +   		\ bytes reserved for growth
constant hash-size	\ element is 16 bytes in length
\
\ 64 bytes per name
0 nostack1
1    char+ field+ Occurances
0    char+ field+ wrdtype
1    char+ field+ diskaddress
0    char+ field+ nlength
29  char+ field+ dname
3    char+ field+ Dhash
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
\ Create workfile-buffer wfrec Allot workfile-buffer wfrec erase
\ Create line-buffer 512 Allot line-buffer 512 erase
Create file-name 127 Allot file-name 127 erase
Create temp-ptr-area 36 allot temp-ptr-area 36 erase
Create temp1$ 8 allot temp1$ 8 erase
Create w-display 10 80 * allot w-display 10 80 * erase
Create QUOTE$ char " c,
Create Incl-state include-size allot Incl-state include-size erase
\ Message Area
Create msg1 z," Cross-Reference Utility"
Create msg2 z," Version 5.1 208006"
Create msg3 z," Developed by Frank J. Russo"
Create msg4 z," Nr# of Variables Identified:      "
Create msg5 z," Nr# of Definitions Identified:      "
Create msg6 z," Nr# of Lines Processed:      "
Create msg7 z," Nr# of Included Files: "
Create msg8 z,"  - Completed"
Create msg8A z," Word Name                  Occurrences Line #'s"
Create msg9d z," Program Limitations - Maximum # of Definitions = 1600 and Variables = 1600"
Create msg9e z,"         Tracks each variable / definition for a maximum of 1024 occurances"
Create msg9f z,"         Naming lengths limited to 30 characters (Will be Truncated if longer)"
Create msg10 z," Processing File - "
Create msg13 z," Failure on opening file"
Create msg15 z," Failure to load line into bufffer"
Create msg16 z," Processing Line # - "
\
\ Following used by the display window
\
   0 Value using98/NT?          \ are we running Windows98 or WindowsNT?
   0 Value BrowseWindow
   0 Value text-len             \ length of text
   0 Value text-ptr             \ address of current text line
   0 Value text-blen            \ total text buffer length
\
   0 Value line-tbl             \ address of the line pointer table
   0 Value line-cur             \ the current top screen line
   0 Value line-last            \ the last file line
   0 Value col-cur              \ the current left column
\
1000 Value max-lines            \ initial maximum nuber of lines
 512 Value max-cols             \ maximum width of text currently editing
\
  90 Value screen-cols          \ default rows and columns at startup
  23 Value screen-rows
\
Create cur-filename max-path Allot cur-filename max-path erase
Create workfile-buffer wfrec Allot workfile-buffer wfrec erase
Create trashcan 1024 Allot trashcan 1024 erase
Create line-buffer 512 Allot line-buffer 512 erase
\
