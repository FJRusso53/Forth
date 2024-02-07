\
\ Delete Z - Program to zero out all unused clusters on a disk
\
\ Frank J. Russo
\ Version 1.0.1 120315
\
\
Needs Resources.f

Anew Del-Z

False value turnkey?
only forth also definitions hidden also forth
\ needs excontrols.f
\
101 Constant dlg-cancel
102 Constant dlg-ok
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
        input-drive get-fspace cr .s cr
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
: DelZero
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
: DZ-Main
cls
  DZ-File
  IF
    DZ-File-Temp
    0> IF
     DelZero
    ENDIF
  ENDIF
;
\
\ ***************************************************************************************
\
\
\ Define an object "DelZWindow" that is a super object of class "Window"
\
:Object DelZWindow    <Super Window

StaticControl Text_1     \ a static text window
StaticControl Text_2     \ a static text window
StaticControl Text_4     \ a static text window
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
CheckControl  Check_1    \ a check box
RadioControl  Radio_1    \ a radio button
RadioControl  Radio_2    \ another radio button

:M StartSize:   ( -- w h )      \ the width and height of our window
                195h 120h
                ;M

:M StartPos:    ( -- x y )      \ the screen origin of our window
                50h 50h
                ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" D E L E T E  &  Z E R O"
                ;M

:M On_Paint:    \ ( --- ) all window refreshing is done by On_Paint:

		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc

                \ set the backgroundcolor for text to ltblue
                ltblue SetBkColor: dc

                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc

\		30 10 t-buffer count textout: dc \ update status
\		msg1 t1-buffer enc-msg-proc 130 3 t1-buffer count textout: dc \ Version Display
\		msg2 t2-buffer enc-msg-proc 130 10 t2-buffer count textout: dc \ Author Display
\		64 100 t3-buffer count textout: dc \ more messages
\		50 8F t4-buffer count textout: dc \ update progress line
\		5 B8 s" IN - File:" textout: dc
\		2 D8 s" Out - File:" textout: dc

;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super             \ do anything superclass needs

                self		Start:    Text_4
                50h D0h 140h 20h Move:    Text_4

\                self		Start:    Text_2
\                50h 60h 110h 12h Move:     Text_2
\				GetStyle: Text_2
\		SS_CENTER 	+Style:   Text_2
\                s" Enter Encryption Key 8 - 32 Characters"
\				SetText:  Text_2
\
                dlg-ok 		SetID:    Button_1
                self 		Start:    Button_1
                31h FCh 25h 18h Button_1
                s" OK" 		SetText:  Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                +Style:   Button_1

                dlg-cancel	SetID:    Button_2
                self 		Start:    Button_2
                133h FCh 45h 18h Move:    Button_2
                s" Cancel"	SetText:  Button_2

		Paint: self
;M

:M On_Done:     ( -- )          	   \ things to do before program
		On_Done: super             \ then do things superclass needs
                Turnkey? if bye then \ terminate application
;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )

	over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: [ self ]
;M

:M On_Command:  ( hCtrl code ID -- f )
        case
                dlg-ok of endof
                dlg-cancel of 2drop On_Done: super
                        0 call PostQuitMessage endof 		\ Exit
        endcase
;M

;Object
\
\
\
Turnkey? [IF]

: DelZ
		Start: DELZWindow ;

' DelZ turnkey DelZ                \ create .exe

[ELSE]

cr .( Type: DelZ to start) cr

\ ***************************************************************************************

: DelZ       ( -- )                  \ start running the program
		Start: DelZWindow ;

\ ***************************************************************************************

[THEN]

cr .( Type: DelZ to start) cr

\ ***************************************************************************************
