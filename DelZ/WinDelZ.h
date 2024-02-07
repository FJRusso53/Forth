\
\ Delete Z Header File- Windows Version -
\ Frank J. Russo
\ Header 1.0.0 151105
\
101 Constant dlg-cancel
102 Constant dlg-ok
200 Constant IDM_Close
201 Constant IDM_Exit
\
0 value infile-ptr
0 value file-flag
0 value loop-counter
0 value bufptr
0 value msgptr
0 value drive-ptr
10 value drive%
\ 0 value zero-buffer
\
variable Drive-Size
variable Nr.Clusters
variable cluster.size
variable timer
variable timer2
\
create T-Buffer   48 Allot T-Buffer   48 erase
create T1-Buffer  48 Allot T1-Buffer  48 erase
create T2-Buffer  48 Allot T2-Buffer  48 erase
create T3-Buffer  48 Allot T3-Buffer  48 erase
create T3a-Buffer 48 Allot T3a-Buffer 48 erase
create T4-Buffer  48 Allot T4-Buffer  48 erase
create T5-Buffer  48 Allot T5-Buffer  48 erase
create T6-Buffer  48 Allot T6-Buffer  48 erase
create zero-buffer 4096 allot zero-buffer 4096 erase
create input-drive z," C:\"
create file-desc z," temp\zero-file"
create file-name 64 allot file-name 64 erase
create msg1 z," Frank J. Russo"
create msg2 z,"  Version 2.0.1"
create msg3  48 allot msg3  48 erase
create msg3A 48 allot msg3A 48 erase
create msg4 z," Process Terminated"
create msg5 z," Press any Key to TERMINATE"
create msg6 z," A directory folder named 'Temp' MUST exist on the Drive. If not exit and create one."
create msg7 z," Free Clusters = "
create msg8 z," Enter the Drive letter to clear - "
create msg9 z," % of free clusters to process "
create Msg-Blank z,"                          "
create Msg-Done z," Process Completed"
\
