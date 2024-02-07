\
anew file-config
0 value infile-ptr1
0 value infile-ptr2
0 value linecount
0 value linelength
0 value file1eof
create B$ 2048 Allot B$ 2048 erase
create E$ 48 Allot E$ 48 erase
create T$ 1024 Allot T$ 1024 erase
create file1 z," Beale4.txt"            \ Input process File
create file2 z," Beale5.txt"            \ Output process File
\
: FC-open
file1 zcount r/w open-file drop to infile-ptr1
file2 zcount r/w open-file drop to infile-ptr2
\
;
\
: fcoutput ( lenght  -- )
t$ 1024 erase
dup 0 =

 if    \ Line contains only a CRLF
   drop
    t$ zcount infile-ptr2 write-line drop
else
   dup 240 >
   if
      2 / b$ + 16 32 scan drop b$ -   \  locate the next space character (32) subtract starting point for a distance
      dup b$ swap 1+  t$ swap cmove
      t$ zcount infile-ptr2 write-line drop \ writes first half of line with 0a0dh on end
      dup b$ + swap linelength swap -
       infile-ptr2 write-line drop
   else
      b$ swap infile-ptr2 write-line drop \ Functioning as required 180329
   endif
 endif

;
\
: file-process
begin
b$ 2048 2dup erase infile-ptr1
read-line drop to file1eof  ( addr len file-ID -- len eof ior)
\ Linecount s" Line #" type . 09 emit s" length = " type . 09 emit s" EOF " type . cr b$ 16 type cr
linecount 1+ to linecount
dup to linelength
fcoutput
file1eof 0 =
until
s" Line Count = " type linecount .
;
\
: fcstart
cls
fc-open
file-process
infile-ptr1 close-file drop
infile-ptr2 close-file drop
;
\
