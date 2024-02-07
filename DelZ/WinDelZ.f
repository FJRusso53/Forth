\
\ Delete Z - Windows Version - Program to zero out all unused clusters on a disk
\
\ Frank J. Russo
\ Version 2.0.2 151023
\
\
Anew Del-Z
\
include WinDelZ.h
Needs Resources.f
include string.f

TRUE value Turnkey? \ set to TRUE if you want to create a turnkey application
only forth also definitions hidden also forth
\ needs excontrols.f
\
\ ***************************************************************************************
\
: Msg-Proc ( msg, buffer --- )
\ moves messages to text out buffer for display
to bufptr to msgptr
msgptr 30h null instrb swap drop
msgptr swap dup bufptr ! 1 +to bufptr bufptr swap cmove
;
\
\ ***************************************************************************************
\
: DZ-File \ Updated 151023 removed the 94% limitation
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
                2drop drop
               else
		   * cluster.size ! drop 2 - dup Nr.Clusters ! -1
               endif
;
\
\ ***************************************************************************************
\
: DZ-File-Temp
\ Open new temp File
file-name 64 erase
input-drive 3 file-name swap cmove
file-desc zcount file-name zcount + swap cmove
file-name zcount r/w create-file drop dup to infile-ptr
1 to file-flag  \  Indicates file is open
msg5 t4-buffer msg-proc
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
: DZ-Main
         input-drive swap cmove
         DZ-File
         IF
           DZ-File-Temp
         ENDIF
;
\
\ ***************************************************************************************
\
\ Define an object "DelZWindow" that is a super object of class "Window"
\
:Object DelZWindow    <Super Window

StaticControl Text_1     \ a static text window
StaticControl Text_2     \ a static text window
StaticControl Text_3     \ a static text window
StaticControl Text_4     \ a static text window
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
EditControl   Edit_1	 \ Edit box
EditControl   Edit_2	 \ Edit box

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

		10h 60h   msg7 zcount textout: dc \ Available cluster space
		78h 60h   T6-Buffer zcount textout: dc \
		10H 80h   msg9 zcount textout: dc \ % to process
		50h A0h   t4-buffer count textout: dc  \ Terminate Message
                50h B0h   t3-buffer count textout: dc  \
		50h C0h   t3A-buffer count textout: dc \

;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super             \ do anything superclass needs

                self		Start:    Text_1
                1h 10h 193h 24h Move:     Text_1
				GetStyle: Text_1
		SS_CENTER 	+Style:   Text_1
                msg6 zcount
				SetText:  Text_1

                self		 Start:    Text_2
                10h 40h C8h 12h  Move:     Text_2
				 GetStyle: Text_2
                msg8 zcount
				 SetText:  Text_2

		self		Start:    Edit_1
                E0h 40H 24 12h  Move:     Edit_1
		ES_LEFT 	+STYLE:   Edit_1
                s" C:\"         SetText:  Edit_1

		self		Start:    Edit_2
                D0h 80H 24 12h  Move:     Edit_2
		ES_LEFT 	+STYLE:   Edit_2
                s" 10"          SetText:  Edit_2

                dlg-cancel	SetID:    Button_2
                self 		Start:    Button_2
                133h FCh 45h 18h Move:    Button_2
                s" Cancel"	SetText:  Button_2

                dlg-ok 		SetID:    Button_1
                self 		Start:    Button_1
                31h FCh 25h 18h Move:     Button_1
                s" OK" 		SetText:  Button_1

		GetText: Edit_1 \ get the drive letter address returned
                input-drive swap cmove
		DZ-File
		Nr.Clusters @ (.) T6-Buffer swap cmove

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
                dlg-ok          of
                                s" - - "	SetText: Button_1
                                GetText: Edit_2 \ get the % of Disk to process
				\ Convert Text to number
	\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
				(NUMBER?) swap drop
				if to drive% else drop 10 to drive% then
				GetText: Edit_1 \ get the drive letter address returned
                                \ DZ-Main
                                input-drive swap cmove
                                DZ-File
                                 IF
                                   DZ-File-Temp 0>
                                    IF
                                \
                                \ Loop writing to file 0's
                                \
                                        msg5 t4-buffer msg-proc \ Load buffer with Terminate instructions
                                        ms@ timer ! \ save start time
\     0FFFFh malloc to zero-buffer
					Nr.Clusters @
					drive% dup 50 - 0>
					   if
					    100 swap - * 100 / Nr.Clusters @ swap -
					   else
					    * 100 /
					   endif
					to loop-counter
					Nr.Clusters @ (.) T6-Buffer swap cmove
                                        loop-counter 1+ 0

                                             do
                                                i dup 10000 / 10000 * =
                                                if
                                                      i DZ-Time
                                         	      Paint: self WinPause  \ to process messages
                                                      \ i dup 10000 / 10000 * =   \ Multiple of 10,000
                                                      \ if
                                                        \ Nr.Clusters @ 10000 /        \ Nr of 10k groups
                                                        \ i 10000 / dup                \ Nr 10K groups processed
                                                        \ rot swap - swap              \ calc remaining # grops to process
                                                        \ timer2 @ timer @ -           \ Elapsed time
                                                        \ \                            \10K groups per second \ i 10000 \ swap \ Present count
                                                        \ *                            \ remaining time
                                                      \ then
                                                then

                                                zero-buffer cluster.size @ infile-ptr write-file
 						IF  \ writefile failed then exit loop
                                                 MB_OK z" W i n D e l Z" z" Error writing to Disk"
                                                 NULL call MessageBox
                                                 Leave
						endif
\
\                                                KEY?
\                                                  if
\                                                   msg-blank t4-buffer msg-proc
\                                                   Paint: self WinPause
\                                                   leave
\                                                  endif

                                              loop
\
                                        loop-counter DZ-Time
                                        msg-done t4-buffer msg-proc
                                        Paint: self WinPause
                                        \ Close file
                                        infile-ptr close-file to infile-ptr 0 to file-flag \ Close process file
                                        \ Delete file
                                        file-name zcount delete-file drop
\ zero-buffer ?dup if free drop then

                                        s" Quit"	SetText: Button_2
                                        s" - - "	SetText: Button_1
				        False GetHandle: Button_1 Call EnableWindow Drop
                                        winpause

                                   then
\
                                 then
\
                                endof
                dlg-cancel      of
                                file-flag
                                if   \ Check to see if files are open
                                  \ Close file
                                  infile-ptr close-file to infile-ptr 0 to file-flag \ Close process file
                                  \ Delete file
                                  file-name zcount delete-file drop
                                endif
                                2drop On_Done: super
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
