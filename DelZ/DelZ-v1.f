\
\ Delete Z - Program to zero out all unused clusters on a disk
\
\ Frank J. Russo
\ Version 1.0.1 120315
\
\ Needs NoConsole.f
\
Needs Resources.f

Anew DelZero

\
0 value infile-ptr
0 value file-flag
variable Nr.Clusters
variable cluster.size
variable timer
variable timer2
create tempbuf1 1024 allot
create zero-buffer 4096 allot zero-buffer 4096 erase
create tempbuf2 1024 allot
create default-drive z," C:\"
create input-drive 8 allot input-drive 8 erase
create file-desc z," \temp\zero-file"
create file-name 64 allot file-name 64 erase
\
: DZ-File
\ Get drive
\ Get free disk apce
\ Get cluster size
\ Get free clusters
s" A directory folder named'temp' MUST exist on your computer" type cr
s"   If not exit and create one" type cr cr
s" Enter the Drive letter to clear (e.g. c: d: g: ...) - " type
input-drive 8 erase
input-drive 8 accept
    dup 0> if drop
        input-drive get-fspace \ cr .s cr
        dup 0= if
                s" Error has occured trying to use "
                type input-drive 8 type cr
                2drop drop
               else * cluster.size ! drop 2 - dup Nr.Clusters ! -1
               endif
       endif
\
;
\
: DZ-File-Temp
\ Open new temp File
file-name 64 erase
input-drive zcount file-name swap cmove
file-desc zcount file-name zcount + swap cmove
file-name zcount r/w create-file drop dup to infile-ptr
\
;
\
: Del-Z
\
\ Loop writing to file 0's
\
 0 10 gotoxy s" Press any Key to TERMINATE" type
10 11 gotoxy s" Cluster #" type
ms@ timer !
 Nr.Clusters @ 1 + 0 do
      10 12 gotoxy i .
      i dup 1000 / 1000 * =

        if
           i 1000 >

           if
             s" Time elasped - " type s" seconds " ms@ dup timer2 ! timer @ - 1000 / . type
             8 spaces i . s" of " type Nr.Clusters @ .
           then

        then

      zero-buffer cluster.size @ infile-ptr write-file drop
      KEY? if 0 15 gotoxy  s" Process Terminated" type cr leave endif
       loop
\
\ Close file
	 infile-ptr close-file to infile-ptr 0 to file-flag \ Close input file
\ Delete file
         file-name zcount delete-file drop
\
;
\
: DelZ
cls
  DZ-File
  IF
    DZ-File-Temp
    0> IF
     Del-Z
    ENDIF
  ENDIF
;
\
