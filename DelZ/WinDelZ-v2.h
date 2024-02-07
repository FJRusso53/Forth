\
\ Delete Z Header File- Windows Version -
\ Frank J. Russo
\ Header 1.0.2 211006
\
101 Constant dlg-cancel
102 Constant dlg-ok
103 Constant dlg-update
200 Constant IDM_Close
201 Constant IDM_Exit

\
0 Value infile-ptr
0 Value file-flag
0 Value loop-counter
0 Value bufptr
0 Value msgptr
0 Value drive-ptr
10 Value drive%
0 Value zero-buffer
0 Value PBInc
0 Value PBIP
\
Variable Drive-Size
Variable Nr.Clusters
Variable cluster.size
Variable timer
Variable timer2
\
Create T-Buffer    48 Allot T-Buffer   48 erase
Create T0-Buffer  48 Allot T0-Buffer  48 erase
Create T1-Buffer  48 Allot T1-Buffer  48 erase
Create T2-Buffer  48 Allot T2-Buffer  48 erase
Create T3-Buffer  48 Allot T3-Buffer  48 erase
Create T3a-Buffer 48 Allot T3a-Buffer 48 erase
Create T4-Buffer  48 Allot T4-Buffer  48 erase
Create T5-Buffer  48 Allot T5-Buffer  48 erase
Create T6-Buffer  48 Allot T6-Buffer  48 erase
Create T7-Buffer  48 Allot T6-Buffer  48 erase
Create input-drive z," C:\"
Create file-desc z," \zero-file"
Create file-name 64 allot file-name 64 erase
Create msg3  48 allot msg3  48 erase
Create msg3A 48 allot msg3A 48 erase
Create msg4 z," Process Terminated"
Create msg5 z," Press any Key to TERMINATE"
Create msg7 z," Free Clusters = "
Create msg8 z," Enter the Drive letter to clear - "
Create msg9 z," % of free clusters to process "
Create msg10 z," Error writing to Disk"
Create Msg-Blank z,"                          "
Create Msg-Done z," Process Completed"
\
s" Frank J. Russo" T0-Buffer swap cmove
0A0Dh T0-Buffer zcount + !
s"  Version 2.3.0   211006" T0-Buffer zcount + swap cmove
\
