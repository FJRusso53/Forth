\ Encrypt.F
\ Frank J. Russo
\ Version 1.3
\ Date 101031
\
\ MB_OK z" TEST Point" z" TEST Point 1" NULL call MessageBox
\
ANEW PROGRAM

TRUE value CreateTurnkey? \ set to TRUE if you want to create a turnkey application

only forth also definitions hidden also forth

include encrypt.h
include string.f
needs excontrols.f

HEX   \  ALL numerics used are in HEX NOT Decimal !!!!!!

\ ***************************************************************************************

FileOpenDialog filelocate "E N C R Y P T I O N - Select your input file :" "All Files|*.*|"

\ ***************************************************************************************

: ENC-Msg-Proc ( msg, buffer --- )
\ moves messages in header file to text out buffer for display
to bufptr to msgptr
msgptr 20 null instrb swap drop
msgptr swap dup bufptr ! 1 +to bufptr bufptr swap cmove
;

\ ***************************************************************************************

: Enc-PW ( addr n ---)
\ Codes encryption key to values of 0 - F
\ Assumes password address and length on top of stack  (addr n ---)
0 Do Dup Dup @ 31 or 0F and swap C! 1+ loop drop
;

\ ***************************************************************************************

: ENC-Proc1 		\ ( -- ) Creates an Output file name

Outfile 7f erase
Infile count dup Outfile c! Outfile 1+ swap cmove	\ duplicate name to outfile

\ returns with address and offset need to adjust length of file name string
\ search for '.' at end of file name

outfile count 2e -instrb 1- -

lock-flag @
   if
      s" loc"
   else
      s" unl"
   then
rot swap cmove		                          \ change suffix on file name
outfile zcount 1- swap c!

\ Checking for outfile name = infile name and correct
infile count outfile count strcmp \ DROP
   if 	\ file names are indentical 1
	31 Outfile dup count 1+ swap drop swap c! \ increment the count byte and store
	outfile count + 1 - c!                    \ append a '1' to the end of the file name
   then
;

\ ***************************************************************************************

: ENC-Proc2 \ Open Input file Allocate memory
infile count r/o open-file 0=	  \ attempt to open input file r/o read only
  if
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 * dup
    FFFFH >
    if drop FFFFH then
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size

    dup inb-len ! infile-buffer-ptr swap erase  \ clear space

  else drop 2drop 0 to file-flag   \ File open failure

  then
;

\ ***************************************************************************************

: ENC-Proc3
outfile count r/w create-file 0=   \ Create output file
  if
    \ success opening
    to outfile-ptr

    else drop 2drop 0 to file-flag \ File open failure
	 infile-ptr close-file	   \ Close input file
  then
;
\ ***************************************************************************************

: ENC-Proc4 ( 091019)
\ Close input file
infile-ptr close-file drop \ Close input file
\ Reopen input file r/w mode
infile count r/w open-file 0=  \ attempt to open input file r/w
if
  to infile-ptr   \ Save file pointer
  infile-ptr file-size 2drop to infile-len
  \ erase file buffer
  inb-len @ infile-buffer-ptr swap erase  \ clear space
  \ move pointer to start of file
  0 0 infile-ptr REPOSITION-FILE drop
\ write 0's to file
 begin
     infile-buffer-ptr infile-len inb-len @ min infile-ptr write-file
     infile-len inb-len @ - dup to infile-len 1 <
  until

  infile-ptr close-file drop \ Close input file
  infile count delete-file drop
\
then
;

\ ***************************************************************************************

: Enc-Rotate
0 I-Counter !
                   Begin
                     cx-v @ dup
                     lock-flag @   \ Test for Lock or Unlock

                     if           \ Lock
                        1 and swap 1 rshift cx-v !
                        if cx-V @ 8000 or cx-v !  \ rotate low bit to high bit pos
                        then
                     else         \ Unlock
                        8000 and swap 1 lshift cx-v !
                        if cx-V @ 0001 or cx-v !  \ rotate high bit to low bit pos
                        then
                     then
                     1 I-Counter +! I-Counter @ Rotate-V @ =  \ test for end of loop
                    Until
;

\ ***************************************************************************************

: Enc-Fetch       \ Fetch word from buffer
        Begin

                00FF00 8 start-p @ textposition C@ + C@ swap LShift and Cx-V !
                End-P @ textposition C@ - C@ 000000ff and Cx-V +!

                Enc-Rotate \  Actual locking & unlocking of words

                \ reload values to buffer
                cx-v @ DUP FF00 AND 8 rshift start-p @ textposition @ + c!
                00ff and end-p @ textposition @ - c!

                1 pw-inc +! pw-inc @ pw-len @ =
                if 0 pw-inc ! then

                1 textposition +! textposition @ offset-v @ 2 / >
        Until
;

\ ***************************************************************************************

: Enc-Main-Proc

0 0 0 0 pw-inc ! textposition ! new-start-p ! cx-v ! \ initiate values to 0

Infile-Buffer-ptr Start-P !      \ set Starting point to the beginning of the Buffer

  Begin
        password pw-inc @ + C@ offset-v C! \ load Offset-V with byte from PW phrase

        1 pw-inc +! pw-inc C@ pw-len C@ =
        if 0 pw-inc ! then             \ reset to 0 if at end of password buffer

        pw-inc C@ password + c@ rotate-v c!  \ Load Rotate Value
        start-p @ offset-v C@ + end-p !      \ Establish End Pt

        end-p @ infile-buffer-ptr bytes-read @ 1- + >
	\ End Pt at end of In-Buffer
        if                                     \ true if not at end of in-buffer

           infile-buffer-ptr bytes-read @ 1- + end-p !
           end-p @ start-p @ - offset-v C!

       then

        end-p @ 1+ new-start-p !                             \ Save next start pt
        Enc-Fetch

        new-start-p @ start-p ! 0 textposition !
        new-start-p @ 1+ infile-buffer-ptr bytes-read @ + >

  until
;

\ ***************************************************************************************
\
\ Define an object "EncryptWindow" that is a super object of class "Window"
\

:Object EncryptWindow    <Super Window

Staticcontrol Text_1     \ a static text window
StaticControl Text_2     \ a static text window
StaticControl Text_4     \ a static text
EditControl   Edit_1	 \ Edit box
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
CheckControl  Check_1    \ a check box
RadioControl  Radio_1    \ a radio button
RadioControl  Radio_2    \ another radio button
PassWordBox   PassWordBox1 \ A Password Box found in 'excontrols.f'

:M StartSize:   ( -- w h ) \ the width and height of our window
                195 120
                ;M

:M StartPos:    ( -- x y ) \ the screen origin of our window
                50 50
                ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" E N C R Y P T I O N"
                ;M

:M On_Paint:    \ ( --- ) all window refreshing is done by On_Paint:
		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc

                \ set the backgroundcolor for text to ltblue
                ltblue SetBkColor: dc

                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc
		30 10 t-buffer count textout: dc \ update status
		msg1 t1-buffer enc-msg-proc 130  3 t1-buffer count textout: dc \ Version Display
		msg2 t2-buffer enc-msg-proc 130 10 t2-buffer count textout: dc \ Author Display
		64 100 t3-buffer count textout: dc \ more messages
		50 8F t4-buffer count textout: dc \ update progress line
		5 B8 s" IN - File:" textout: dc
		2 D8 s" Out - File:" textout: dc
;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super             \ do anything superclass needs

		gethandle: self Start: filelocate
		filelocate
		dup 1+ swap c@ dup infile ! infile 1+ swap cmove

		ENC-Proc2 \ Open Input file Allocate memory

                dlg-lock 	SetID:    Radio_1
                self 	        Start:    Radio_1
                31 30 40 18	Move:     Radio_1
                s" Lock" 	SetText:  Radio_1
                                GetStyle: Radio_1 \ get the default style
		WS_GROUP        +Style:   Radio_1 \ Start a group
				SetStyle: Radio_1

                dlg-unlock	SetID:    Radio_2
                self 		Start:    Radio_2
                133 30 49 18	Move:     Radio_2
                s" UnLock"  	SetText:  Radio_2
		WS_GROUP        +Style:   Radio_2 \ end a group

                dlg-delete	SetID:    Check_1
                self 		Start:    Check_1
                90 30 80 18	Move:     Check_1
                s" Delete Original"  SetText: Check_1

		self		Start:    Edit_1
                50 D0 140 20	Move:     Edit_1
		ES_LEFT 	+STYLE:   Edit_1

                self		Start:    Text_2
                50 60 110 12	Move:     Text_2
				GetStyle: Text_2
		SS_CENTER 	+Style:   Text_2
                s" Enter Encryption Key 8 - 32 Characters"
				SetText:  Text_2

                dlg-phrase	SetID:    PassWordBox1
                self 		Start:    PassWordBox1
                50 75 140 15 	Move:     PassWordBox1

                self		Start:    Text_1
                50 AA 140 20	Move:     Text_1
                filelocate dup c@ swap 1+ swap
				SetText:  Text_1 \ Load input file name to display

                dlg-ok 		SetID:    Button_1
                self 		Start:    Button_1
                31 FC 25 18 	Move:     Button_1
                s" OK" 		SetText:  Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                +Style:   Button_1

                dlg-cancel	SetID:    Button_2
                self 		Start:    Button_2
                133 FC 45 18 	Move:     Button_2
                s" Cancel"	SetText:  Button_2

		1 0 phrase-flag ! lock-flag !

		msg3 t-buffer enc-msg-proc       \ Status line
\		msg-blank t3-buffer enc-msg-proc \ Progress line
\		msg-blank t4-buffer enc-msg-proc
		Paint: self

;M

:M On_Done:     ( -- )          	   \ things to do before program
		On_Done: super             \ then do things superclass needs
                CreateTurnkey? if bye then \ terminate application
;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )

	over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: [ self ]
;M

:M On_Command:  ( hCtrl code ID -- f )

        case
		dlg-lock   of 1 lock-flag ! ENC-Proc1 \ Creates Output file name
				Outfile count SetText: Edit_1
				winpause
			 endof 	\ selection of Lock Button
		dlg-unlock of 0 lock-flag ! ENC-Proc1 \ Creates Output file name
				Outfile count SetText: Edit_1
				winpause
			 endof 	\ Selection of Un-Lock Button
		dlg-delete of delete-flag not to delete-flag endof \ selection of Delete Original Button
		dlg-cancel of 2drop On_Done: super
			      0 call PostQuitMessage endof 		\ Exit
		dlg-phrase of 1 phrase-flag ! endof			\ Encryption Key Box selected
		dlg-ok of Phrase-Flag @

			  if GetText: PassWordBox1 dup pw-len ! password swap cmove
			     Pw-len @ 8 <
			     if

			MB_OK z" E N C R Y P T" z" Encryption Key Less then 8 characters!"
			NULL call MessageBox

			     else

				\ Change Status Display
				msg4 t-buffer enc-msg-proc winpause
				GetText: Edit_1                 \ Get name of outfile if edited
				dup outfile ! outfile 1+ swap cmove
				enc-proc3                       \ Open Output File
				password pw-len @ enc-pw	\ Encrypt Password

				file-flag
			  if  \ success on opening both files

			     begin
			\ Main procedure to read in data encrypt and write out data

				infile-buffer-ptr inb-len @ infile-ptr read-file
				drop bytes-read !

				\ Change Progress Display
				msg6 t4-buffer enc-msg-proc
				decimal infile-len (.) t4-buffer +place hex
				Paint: self

				WinPause  			\ to process messages

				Enc-Main-Proc 			\ encrypt buffer
				infile-buffer-ptr bytes-read @ outfile-ptr write-file
				infile-len bytes-read @ - dup to infile-len 0=
			     until				\ files size is reduced to 0

				msg5 t3-buffer enc-msg-proc
				msg-blank t4-buffer enc-msg-proc
				msg-blank t-buffer enc-msg-proc
				Paint: self

				outfile-ptr close-file drop     \ Close output file
				delete-flag

				if		   \ Delete original file
				   enc-proc4       \ Need to first zero out all the data in the original file
				else
				   infile-ptr close-file drop \ Close input file
				then

				infile-buffer-ptr ?dup	\ Release allocated memory
				if free drop then

				s" Quit"	SetText: Button_2
				msg-blank count SetText: Text_1
				s" - - "	SetText: Button_1
				False GetHandle: Button_1 Call EnableWindow Drop
				winpause

			   else
				MB_OK z" E N C R Y P T" z" Unable to Open Files"
				On_Done: super
				0 call PostQuitMessage
			   then
			   then

			  else MB_OK z" E N C R Y P T" z" Missing Encryption Key!"
			       NULL call MessageBox

			  then

			endof
        endcase
;M

;Object

\ ***************************************************************************************

CreateTurnkey? [IF]

: ENCRYPT
		Start: EncryptWindow ;

' ENCRYPT turnkey Encrypt2               \ create - Encrypt2.exe

[ELSE]

\ cr cr .( Type: ENCRYPT to start, and: XENC to stop) cr

\ ***************************************************************************************

: ENCRYPT       ( -- )                  \ start running the program
		Start: EncryptWindow ;

\ ***************************************************************************************

: XENC        ( -- )                  \ close the window
              Close: EncryptWindow ;

[THEN]

cr cr .( Type: ENCRYPT to start, and: XENC to stop) cr

\ ***************************************************************************************
