\
\ Beale-Cypher Header File- Windows Version
\ Frank J. Russo
\ Header Vers 1.1 200731
\ Last Updated 200731
\
0 nostack1
3 char+ field+ Line-Addr	\ 4 byte word containing Line address pointer
1 char+ field+ Line-size	\ 2 byte Interger value lenght of line
constant field-size               \ element is 6 bytes in length
\
\ Pointers to Memory Array
0 value BealBook{
\
44 Constant comma
101 Constant dlg-cancel
102 Constant dlg-ok
103 Constant dlg-update
200 Constant IDM_Close
201 Constant IDM_Exit
\
0 value bufptr
0 value file-flag
0 value infile-ptr
0 value infile-buffer
0 value outfile-ptr
0 value outfile-buffer
0 value msgptr
0 value zero-buffer
\
0 value core-lines   \ a To be used to identify the # of lines in the core file
0 value code-flag    \ b set default value
0 value D1$ \ pointer to buffer for the code book
0 value D2$ \ pointer to buffer for results input file
0 value f
0 value f1
0 value f2
0 value filesize1
0 value f1eof
0 value f2eof
0 value g-startpt
0 value hits
0 value index-value  \ c Index value
0 value InFile-Lines \ d # of lines in Input File
0 value Lc \ in line counter
0 value line# \ L line :
0 value line2 \ l2 output line counter
60 value line-key \  Lines per page in reference book
0 value page#
0 value p1 \ pointer
0 value r  \ Result value output
0 value s
0 value string-lenght \ l length of process string
0 value t
0 value token1
0 value word# \ word
0 value w1
0 value x-SP \ Random starting point in FIle #1
\
create file1 z," BookofBeale.txt"  \  Core File
\ create file1 z," Catholic Prayer-win.txt" \ Test.txt"   \  Core File
create file2 z," beale3.txt"           \ Input process File Beale2
create file3 z," Results.txt"         \ Output Results File
create file4 z," Beale1.txt"          \ Input process File
create file5 z," Results.txt"         \ Temp input file
\
create SOM 16 Allot SOM 16 erase
create A$ 16 Allot A$ 16 erase
create B$ 1024 Allot B$ 1024 erase
create D$ 1024 Allot D$ 1024 erase   \ temporary for testing
create E$ 1024 Allot E$ 1024 erase
create OF$ 1024 Allot OF$ 1024 erase
create T$ 1024 Allot T$ 1024 erase
create T0-Buffer 1024 allot T0-Buffer 1024 erase
create EOM 16 Allot EOM 16 erase
\
create file-desc z," zero-file"
create file-name 64 allot file-name 64 erase
create msg3  48 allot msg3  48 erase
create msg3A 48 allot msg3A 48 erase
create msg4 z," Process Terminated"
create msg5 z," Press any Key to TERMINATE"
create msg6 z," 9999999"  \ eol marker
create Msg-Blank z,"                          "
create Msg-Done z," Process Completed"
\
s" Frank J. Russo" T0-Buffer swap cmove
0A0Dh T0-Buffer zcount + !
s" Version 1.0     180314" T0-Buffer zcount + swap cmove
\
