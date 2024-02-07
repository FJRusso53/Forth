\
\ Delete Z - Windows Version - Program to zero out all unused clusters on a disk
\
\ Frank J. Russo
\ Version 2.3 211006
\ Addition of a Progress Bar
\
Anew Del-Z
\
Include WinDelZ-v2.h
Needs \Programming\Win32Forth\src\lib\Resources.f
Needs \Programming\Win32Forth\src\lib\Progressbar.f
Defer _DelZWindow
Defer _PB1
\
True value Turnkey? \ set to TRUE if you want to create a turnkey application
only forth also definitions hidden also forth
\
\ ***************************************************************************************
\
: Msg-Proc ( msg, buffer --- )
\ moves messages to text out buffer for display
to bufptr to msgptr
msgptr zcount swap drop
msgptr swap dup bufptr ! 1 +to bufptr bufptr swap cmove
;
\
\ ***************************************************************************************
\
: DZ-File ( -- Flag ) \ Updated 151023 removed the 94% limitation
\ Get drive
\ Get free disk apce
\ Get cluster size
\ Get free clusters
        input-drive get-fspace
        dup 0= if
                msg3 48 erase
                s" Error has occured trying to use drive - " msg3 swap cmove
                input-drive 3 msg3 zcount + swap cmove
		MB_OK  z" W i n D e l Z" msg3
		NULL call MessageBox
                msg3 48 erase
                2drop 2drop
               else
		   * cluster.size ! drop 2 - dup Nr.Clusters !
		   T6-Buffer 10 32 fill
		   Nr.Clusters @ (.)
		   T6-Buffer swap cmove
                   drop -1
               endif
;
\
\ ***************************************************************************************
\
: a-dir? ( -- flag )  \ Addition 170922
\
  input-drive 3 file-name swap cmove  \  Move Drive letter to file name field
  s" Temp1" file-name zcount + swap cmove \ Move directory name to file name field
  file-name call PathFileExists   \  Returns 1 is exist 0 if not
    not if file-name call CreateDirectory file-name call PathFileExists else 1 then
\ Issue - call CreateDirectory does not return a value.
\ call PathFileExists is used to check and see if the directory was created
\
;
\ ***************************************************************************************
\
: DZ-File-Temp ( -- flag )  \ updated 170922 implement a-dir? function
\ Check to see if a directory names TEMP exist in the root of the drive.  171010
\
\ Open new temp File
file-name 64 erase
a-dir?  \ check to see if directory 'Temp' exist on the root directory of the drive
if
  file-desc zcount file-name zcount + swap cmove
  file-name zcount r/w create-file drop dup to infile-ptr
  1 to file-flag  \  Indicates file is open
  msg5 t4-buffer msg-proc
else
  0 0 to file-flag
then
;
\
\ ***************************************************************************************
\
: DZ-Time  ( N - )
msg3 48 erase
msg3a 48 erase
s" Time elasped - "  msg3 swap cmove
ms@ dup timer2 ! timer @ - 1000 / (.)
msg3 zcount + swap cmove
s"  Seconds "  msg3 zcount + swap cmove
msg3 t3-buffer msg-proc
(.) msg3a swap cmove
s"  of  " msg3a zcount + swap cmove
loop-counter (.) msg3a zcount + swap cmove
s"  Clusters Processed " msg3a zcount + swap cmove
msg3a t3a-buffer msg-proc
;
\
\ ***************************************************************************************
\
: DZ-Process  \ Main Processing Loop
                                             Do
						Drop 	\ remove previously left loop counter
                                                I Dup 10000 / 10000 * =
                                                IF
                                                      i DZ-Time
                                                      Nr.Clusters @ 10000 - dup Nr.Clusters !
                                                      T6-Buffer 10 32 fill
                                                      (.) T6-Buffer swap cmove  \ Convert # to Ascii string move into buffer
                                         	      Paint: [ _DelZWindow ] WinPause  \ to process messages

((							PBIP 25 > \ Calc Remaining time
								IF
									I timer2 @ timer @ - 1000 /  /  \
									loop-counter I - swap / . cr
								EndIF
))
                                                EndIF
\
						I PBInc / PBIP =    			\ Progress Bar Incremented Check
							IF
								PBIP 1+ to  PBIP 	\ Advance the PB counter
								Stepit: _PB1 		\ Advance PB by defined increment (1)
							Endif
                                                zero-buffer cluster.size @ infile-ptr write-file
 						IF  			\ writefile failed
							msg10 zcount T7-buffer swap cmove Paint: [ _DelZWindow ]
							I Leave  	\ Put loop counter on stack / exit loop
						Endif
					       I 			\ Put the loop counter on stack
                                              Loop
\
;
\
\ ***************************************************************************************
\
\ Define an object "DelZWindow" that is a super object of class "Window"
\
:Object DelZWindow    <Super Window

StaticControl Text_1		\ a static text window
StaticControl Text_2     	\ a static text window
StaticControl Text_3     	\ a static text window
StaticControl Text_4     	\ a static text window
ButtonControl Button_1	\ a button
ButtonControl Button_2	\ another button
ButtonControl Button_3 	\ another button
EditControl   Edit_1	 	\ Edit box
EditControl   Edit_2	 	\ Edit box
Progressbar PB1	 	 	\ Progress Bar
' PB1 IS _PB1

:M StartSize:   ( -- w h )      \ the width and height of our window
                195h 138h
                ;M

:M StartPos:    ( -- x y )      \ the screen origin of our window
                50h 50h
                ;M

:M WindowStyle: ( -- style )  \ New 2017
		WS_OVERLAPPED WS_SYSMENU OR ;M

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

		10h 60h   msg7 zcount textout: dc 	\ Available cluster space
		78h 60h   T6-Buffer zcount textout: dc 	\
		10H 80h   msg9 zcount textout: dc 	\ % to process
		50h A0h   t4-buffer count textout: dc  	\ Terminate Message
                50h B0h   t3-buffer count textout: dc  	\
		50h C0h   t3A-buffer count textout: dc
		50h D0h   T7-buffer zcount textout: dc

;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super  \ do anything superclass needs

                self		Start:    Text_1
                7bh 10h 99h 24h    Move:   Text_1  \ adjusted box size and centered box
		SS_CENTER 	+Style:   Text_1
                T0-Buffer zcount	SetText: Text_1 \ combined msg1 & msg2 with CR

                self		 Start:    Text_2
                10h 40h C8h 12h  Move:     Text_2
                msg8 zcount	 SetText:  Text_2

		self		Start:    Edit_1
                E0h 40H 24 12h  Move:     Edit_1
		ES_LEFT 	+STYLE:   Edit_1
                s" C:\"         SetText:  Edit_1

		self			Start:    Edit_2
                D0h 80H 30 12h  Move:     Edit_2 \ Expanded box width 170921
		ES_RIGHT 	+STYLE:   Edit_2 \ Justify Right
                s" 10"          	SetText:  Edit_2

                dlg-cancel	SetID:    Button_2
                self 			Start:    Button_2
                133h FCh 45h 18h Move:    Button_2
                s" Cancel"	SetText:  Button_2

                dlg-ok 		SetID:    Button_1
                self 			Start:    Button_1
                31h FCh 25h 18h Move:     Button_1
                s" OK" 		SetText:  Button_1

                dlg-update	SetID:    Button_3
                self 			Start:    Button_3
                B2h FCh 45h 18h Move:     Button_3
                s" Update" 	SetText:  Button_3

                self			Start:    PB1
                D8h 60h 90h 12h Move:     PB1
		PBS_SMOOTH +Style:   PB1
		0 100		SetRange: PB1 \ Set Min Max Range for Bar
		1			SetStep:   PB1 \ Set step increment
		0			SetValue: PB1 \ Set current position

		Msg-Blank zcount T7-Buffer swap cmove
		GetText: Edit_1 \ get the drive letter address returned
                input-drive swap cmove
		DZ-File drop
		SW_HIDE Show: PB1 \ Hide the Progress Bar
		Paint: [ self ]
		Winpause
;M

:M On_Done:     ( -- )          	   	\ things to do before program exits
		On_Done: super             \ then do things superclass needs
                Turnkey? if bye then 	   \ terminate application
;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )

	over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: [ self ]
;M

\ :M WM_CHAR ( h m w l -- res )  \ 160611
\           over 13 = \ Checking for Enter Key
\           if
\        \ Got it Now update screen values
\               GetText: Edit_1 \ get the drive letter address returned
\               input-drive swap cmove
\		DZ-File drop
\		Paint: [ self ] Winpause
\		FALSE
\	   else TRUE
\           endif
\ ;M

:M On_Command:  ( hCtrl code ID -- f )
        case
                dlg-ok          of
                                s" - - "	SetText: Button_1
				FALSE Enable: 	Button_1
				SW_HIDE Show: Button_1
                                s" - - "	SetText: Button_3
				FALSE Enable:    Button_3
				SW_HIDE Show:  Button_3
                                GetText: Edit_2 			\ get the % of Disk to process
				(NUMBER?) swap drop 	\ Convert Text to number
				if to drive% else drop 10 to drive% then
				s" ---"	SetText: Edit_2
				FALSE 	Enable:  Edit_2
				GetText: Edit_1 			\ get the drive letter address returned
                                input-drive swap cmove
                                DZ-File
                                 IF 					\ Success
                                   DZ-File-Temp 0>    	\ Open temporary write file  0 = fail to open
                                    IF 				\ Success
                                        msg5 t4-buffer msg-proc \ Load buffer with Terminate instructions
                                        ms@ timer ! \ save start time
					Nr.Clusters @
					drive%
					dup 99 = 		\ If = 99% clear all but .25G of free space
					IF
					   drop dup 61440 >
					   IF 			\ Large amount of free space > .25 G
						   61440 -
					   Else 		\ small amount of free space < .25G
						   100 /  - 	\ use all but 1% of the free space
					   Endif
					Else
					   dup 49 - 0>
					   IF 100 swap - * 100 / Nr.Clusters @ swap -
					   Else * 100 /
					   Endif
					Endif
					dup 10000 > IF 10000 / 10000 * Endif	\ Rounding to groups of 10K 161208
					to loop-counter
					cluster.size @ malloc to zero-buffer
                                        T6-Buffer 10 32 fill Paint: [ self ]
					Nr.Clusters @ (.) T6-Buffer swap cmove
					SW_HIDE Show: Edit_2  				\ Hide Edit_2 box
					msg9 zcount erase 					\ Clear message
					SW_RESTORE Show: PB1 			\ Show Progress Bar
                                        Paint: [ self ] Winpause
					loop-counter 100 / to PBInc
					1 to PBIP
                                        0 loop-counter 1+ 0
					DZ-Process							\ Main Processing Loop
                                        DZ-Time								\ Calc Processing Time
                                        msg-done t4-buffer msg-proc
                                        Paint: [ self ] WinPause
                                        \ Close file
                                        infile-ptr close-file to infile-ptr 0 to file-flag 	\ Close process file
                                        \ Delete file
                                        file-name zcount delete-file drop
					zero-buffer ?dup if free drop then  		\ Release allocated memory buffer
                                        s" Quit"	SetText: Button_2
                                        winpause
\
                                   Endif
\
                                 Endif
\
                                Endof
\
                dlg-cancel      OF
                                file-flag
                                IF   \ Check to see if files are open
                                  \ Close file
                                  infile-ptr close-file to infile-ptr 0 to file-flag \ Close process file
                                  \ Delete file
                                  file-name zcount delete-file drop
                                Endif
                                2drop On_Done: super
                                0 call PostQuitMessage
				Endof 		\ Exit
\
                dlg-update      OF
				  GetText: Edit_1 \ get the drive letter address returned
				  input-drive swap cmove
				  T6-Buffer 10 32 fill Paint: [ self ]
				  DZ-File drop
				  Paint: [ self ] Winpause
				Endof
        Endcase
;M

;Object
\
' DelZWindow IS _DelZWindow
\
\ ***************************************************************************************
\
Turnkey? [IF]

: DelZ
	Start: DELZWindow ;
' DelZ turnkey DelZ3                \ create .exe
        s" \Programming\Win32Forth\Icons\Eraser.ico" s" Delz3.exe" AddAppIcon
        1 pause-seconds \ bye

[ELSE]

cr .( Type: DelZ to start) cr

\ ***************************************************************************************

: DelZ       ( -- )                  \ start running the program
		Start: DelZWindow ;

\ ***************************************************************************************

[THEN]

cr .( Type: DelZ to start) cr

\ ***************************************************************************************
