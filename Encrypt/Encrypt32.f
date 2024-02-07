\ Encrypt-21.F
\ Frank J. Russo
\ Version 4.0  Support for Folder - Directory - Sub-Diretory Processing
\ Date 211111
\
\ Average run time of 176 ms per Mb.
\
ANEW 32Encrypt21
\
\ ' only forth also definitions hidden also forth
\
chdir \Programming\Win32Forth\src\lib
Needs Resources.f
Needs excontrols.f
\
chdir \Programming\Win32Forth\proj\Encrypt
Include SUB_DIRS.F
Include Encrypt32.h
Include Encrypt-Core32.f
\
chdir \Programming\Win32Forth\proj\Encrypt
\
True Value Turnkey? \ set to TRUE if you want to create a turnkey application
\
HEX   \  ALL numerics used are in 'HEX' NOT Decimal !!!!!!
\
\ ***************************************************************************************
\
FileOpenDialog filelocate "E N C R Y P T I O N - Select your input file :" "All Files|*.*|"
\
\ ***************************************************************************************
\
: Folder-Browse z" E N C R Y P T I O N - Select a Folder" Dir-Path hWnd BrowseForFolder ;
\
: ENC-Msg-Proc ( msg, buffer --- ) \ Updated 210214 use of SCAN
\ moves messages in header file to text out buffer for display
to bufptr to msgptr
msgptr 20 null scan drop msgptr - \ lenght of msg
msgptr swap dup bufptr ! 1 +to bufptr bufptr swap cmove
;
\
\ ***************************************************************************************
\
: Enc-PW-bypass ( - F) \ 210216 Using SCAN call
\
\ Check for bypass
  bypass 9 password 9 COMPARE not
  IF    \ Do they match ?
        \ Bypass and Password match got a hit
        \ Retrieve encryption key from file
	infile-buffer-ptr inb-len @ infile-ptr read-file
	drop bytes-read !
	0 0 infile-ptr REPOSITION-FILE drop \ reset file pointer to begining of file Version 1.
	  infile-buffer-ptr msg3 msg1 - 0Ah SCAN ( InstrB) drop 1+ dup \ locate 0Ah in stream +1
	  infile-buffer-ptr msg3 msg1 - IDM_Exit SCAN ( InstrB) drop \ locate idm-exit in stream
          swap - Pw-len !
         Pw-len @ password swap cmove   \ Move key to Password field
      0
      Else -1
  EndIF
;
\
\ ***************************************************************************************
\
: Enc-PW  \ (addr n ---) Updated 210214
\
\ Code encryption key to values of 1 - F
\
dup 9 = lock-flag @ not and  \ Check to see if lenght of PW = 9 and Lock-Flag = Unlock = 0
IF  2drop Enc-PW-bypass Else -1 EndIF
IF PW-Enc EndIF
\
lock-flag @
IF
  password pw-len @ msg2a swap cmove \ move the encrypted pw to message field for output to file
  msg2a zcount + IDM_Exit swap c! \ end of PW identifier
EndIF
;
\
\ ***************************************************************************************
\
: ENC-Proc1 ( -- )	\  Creates an Output file name \ Revised 211111
\
Outfile 0FFh erase
Infile count dup Outfile c! Outfile 1+ swap cmove \ duplicate name to outfile

\ search for '.' at end of file name Use of -SCAN call
outfile count Dup Rot + Swap 2e ( -instrb) -SCAN drop 1+  \ returns with address and offset
lock-flag @
   IF
	dup zcount 0 Do Dup dup C@ 64h + swap C! 1+ loop drop  \ Encrypt the file Suffix
	dup zcount ( adr n ) \ move to output file
	msg2b 8 erase msg2b swap cmove
	msg2b zcount + DFh swap c! \ end of Header identifier
\ Save original file Suffix
\
      s" loc"
\
   else
\
\ Revision 210216 Use of SCAN call
\ Recover original file extension
	0 0 infile-ptr REPOSITION-FILE drop 		 \ reset file pointer to begining of file
	infile-buffer-ptr inb-len @ infile-ptr read-file 2drop \ Read in Header Data
	infile-buffer-ptr 60 IDM_Exit SCAN ( InstrB) drop 1+ dup 	 \ locate idm-exit (C9h) End of the Password
	\ need trap if idm-exit not located
	infile-buffer-ptr 60 DFh SCAN ( InstrB) drop 		 \ locate DFh End of the file extension
	\ need trap if DFh not located
	over - over over \ Adr C Adr C
	0 Do Dup dup C@ 64h - swap C! 1+ loop drop swap drop \ Decrypt File Suffix
	\ Adr C on stack
	\ s" unl"  to be used only for an early version
   EndIF
   rot swap over zcount erase cmove \ change suffix on file name
   outfile zcount 1- swap c! \ Save length

\ Checking for outfile name = infile name and correct
\ Use of COMPARE
\ \ COMPARE compares two strings. The return value is:
\ 0 = string1 = string2
\ -1 = string1 < string2
\ 1 = string1 > string2
   infile count outfile count ( strcmp) COMPARE 0=
   IF 	\ file names are indentical
	31 Outfile dup count 1+ swap drop swap c! \ increment the count byte and store
	outfile count + 1 - c!                    \ append a '1' to the end of the file name
   EndIF
;
\
\ ***************************************************************************************
\
: ENC-Proc2 \ Open Input file \ Updated 151005
  infile count r/o open-file 0=	  \ attempt to open input file r/o read only
  IF
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 * dup
    FFFFH >
    IF drop FFFFH EndIF
    inb-len !
  Else drop 0 to file-flag   \ File open failure
  EndIF
;
\
\ ***************************************************************************************
\
: ENC-Proc3 (   -   ) \ Updated 211112  Called from :M On_Command: Case OK
\ Open Output File
\
 0 to process-count
 Begin
   outfile count w/o open-file NOT  \ open output file rtn with FileID - IOR
   IF \ File Exist
     close-file
     outfile count
     outfile count + 1- c@ dup
     30 39 between
     \ process-count 0=
     IF
	1+ outfile count + 1- c!
     Else
        drop outfile count  1+ swap 1- c!
	+ 30H swap c!
     EndIF
     \ + 1- dup C@ 1+ swap C!
     1 +to process-count
     process-count 9 > if -1 -1 else 0 endif \ 9 attempts to open a file with an additional extensio (x.x1 - 3)
   Else -1
   EndIF
 Until
 outfile count w/o create-file 0=   \ Create output file
  IF
    \ success opening new file
    to outfile-ptr
    lock-flag @  \ Addition made in Ver2*
	if \ File is to be encrypted
	   \ Version 2 identification bytes
	    msg1  zcount outfile-ptr write-file drop \ Version #
	    msg1a zcount outfile-ptr write-file drop \ Property statement
	    msg2  zcount outfile-ptr write-file drop \ Owner
	    msg2a zcount outfile-ptr write-file drop \ encrypted PW
	    msg2b zcount outfile-ptr write-file drop \ encrypted file extension
	EndIF
  Else drop 2drop 0 to file-flag \ File open failure
	 infile-ptr close-file	 \ Close input file
  EndIF
;

\
\ ***************************************************************************************
\
: ENC-Proc4 \ 200805 Close input file
\
\   MB_OK z" TEST Point" z" TEST Point 3" NULL call MessageBox
\
   infile-ptr close-file drop \ Close input file
   infile count r/w open-file 0=  \ attempt to reopen input file r/w
   IF
	to infile-ptr   \ Save file pointer
	infile-ptr file-size 2drop to infile-len
	inb-len @ infile-buffer-ptr swap erase  \ erase file buffer clear space

	0 0 infile-ptr REPOSITION-FILE drop \ move pointer to start of file

	Begin \ write 0's to file
		infile-buffer-ptr infile-len inb-len @ min infile-ptr write-file
		infile-len inb-len @ - dup to infile-len 1 <
	Until

	infile-ptr close-file drop \ Close input file
	infile count delete-file drop \ Delete file
   EndIF
;

\
\ ***************************************************************************************
\
: Enc-Proc5 \ Revised 211111
\ Revised to use SCAN & SEARCH calls
\
	0 0 infile-ptr REPOSITION-FILE drop \ reset file pointer to begining of file
	infile-buffer-ptr inb-len @ infile-ptr read-file \ read
	drop bytes-read !
	infile-buffer-ptr msg1 zcount swap over 2 - ( strndx) SEARCH
\
	if
	  2drop \ Version is 4 or greater
	  True to version2
	  infile-buffer-ptr dup msg3 msg1 - DFh SCAN drop  \ Locate DFh in the header of the input stream
	  swap -
	  1+ to inb-offset \ save location after the 0DFh
	  drop
	  inb-offset 0 infile-ptr REPOSITION-FILE drop \ set file pointer to begining of file Version 2.
	else
	  2drop 0 0 infile-ptr REPOSITION-FILE drop \  reset file pointer to begining of file Version 1.
	EndIF
\
	inb-len @ infile-buffer-ptr swap erase  \ clear space
	infile-len inb-offset - to infile-len
;

\
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

:M StartSize: ( -- w h ) 1D4 140	;M \ the width and height of our window
:M StartPos: ( -- x y )    50 50	;M \ the screen origin of our window
:M WindowTitle: ( -- Zstring )  z" E N C R Y P T I O N"  ;M       \ window caption
:M WindowStyle: ( -- style )  \
		WS_OVERLAPPED WS_SYSMENU OR ;M
:M DefaultIcon: ( -- hIcon )
		s" ENC-Lock.ico" LoadIconFile
		dup .wndclass .hIcon !
		dup 0=
                if	\ Loading default Icon
			DECIMAL drop 100 z" w32fConsole.dll" \ Win32Forth Icon
			Call GetModuleHandle Call LoadIcon
			dup .wndclass .hIcon ! HEX
		else .wndclass .hIcon @
                EndIF
;M

:M On_Paint:    \ ( --- ) all window refreshing is done by On_Paint:
		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc
\
                \ set the backgroundcolor for text to ltblue
                ltblue SetBkColor: dc
\
                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc
		30 10 t-buffer count textout: dc \ update status
		msg1 t1-buffer enc-msg-proc 130  3 t1-buffer count textout: dc \ Version Display
		msg2 t2-buffer enc-msg-proc 130 10 t2-buffer count textout: dc \ Author Display
		64 100 t3-buffer count textout: dc \ more messages
		50 8F t4-buffer count textout: dc \ update progress line
		5 B0 s" IN - File:" textout: dc
		2 D8 s" Out - File:" textout: dc
;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super  \ do anything superclass needs
\
		GetHandle: self to hWnd Folder-Browse
		if
			1 to folder-select
			dir-path 1+ zcount
			s" *.*" 1 SDIR	\ retrieves list of files in directory and subdirectories
		else
			gethandle: self Start: filelocate
			filelocate
			dup 1+ swap c@ dup infile ! infile 1+ swap cmove \ moves name of input file to the buffer infile
		endif
\
\ Allocate memory
		0FFFFH malloc to infile-buffer-ptr  \ allocate buffer space 64K (FFFFh) size
		infile-buffer-ptr 0FFFFH erase      \ clear space
\
		folder-select 0=   \ update 151005
		if ENC-Proc2 EndIF  \ Open Input file
\
                dlg-lock 		SetID:    Radio_1
                self 	        	Start:      Radio_1
                31 30 40 18	Move:     Radio_1
                s" Lock" 	SetText:  Radio_1
					GetStyle: Radio_1 \ get the default style
		WS_GROUP        +Style:   Radio_1 \ Start a group
					SetStyle: Radio_1
\
                dlg-unlock	SetID:    Radio_2
                self 			Start:      Radio_2
                133 30 49 18	Move:     Radio_2
                s" UnLock"  	SetText:  Radio_2
		WS_GROUP  +Style:   Radio_2 \ end a group
\
                dlg-delete	SetID:    Check_1
                self 			Start:      Check_1
                90 30 80 18	Move:     Check_1
                s" Delete Original"  SetText: Check_1
\
		self		Start:    Edit_1
                50 D0h 178 24	Move:     Edit_1
		ES_LEFT 	+STYLE:   Edit_1
\
                self			Start:    	Text_2
                50 50 110 12	Move:      Text_2
					GetStyle: Text_2
		SS_CENTER +Style:    Text_2
                s" Enter Encryption Key 8 - 32 Characters"
					SetText:  Text_2
\
                dlg-phrase	SetID:    PassWordBox1
                self 			Start:     PassWordBox1
                50 65 140 18 Move:    PassWordBox1
					GetStyle: PassWordBox1
		ES_LEFT	+Style:   PassWordBox1
\
                self		Start:    Text_1
                50 A8 178 24	Move:     Text_1
                filelocate dup c@ swap 1+ swap
				SetText:  Text_1 \ Load input file name to display
\
                dlg-ok 		SetID:    Button_1
                self 			Start:    Button_1
                31 FC 25 18 	Move:     Button_1
                s" OK" 		SetText:  Button_1
					GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
					+Style:   Button_1
\
                dlg-cancel	SetID:    Button_2
                self 			Start:    Button_2
                133 FC 45 18 Move:     Button_2
                s" Cancel"	SetText:  Button_2
\
		1 0 phrase-flag ! lock-flag !
\
		msg3 t-buffer enc-msg-proc       \ Status line
\		msg-blank t3-buffer enc-msg-proc \ Progress line
\		msg-blank t4-buffer enc-msg-proc
		Paint: self
\
;M

:M On_Done:     ( -- )          	   \ things to do before program
		On_Done: super             \ EndIF do things superclass needs
                Turnkey? if bye EndIF \ terminate application
;M
\
:M WM_COMMAND  ( hwnd msg wparam lparam -- res )
	over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: [ self ]
;M
\
:M On_Command:  ( hCtrl code ID -- f )
\
        Case
		dlg-lock of 1 lock-flag !
				folder-select 0=	\ update 151005
				IF
				  ENC-Proc1 \ Creates Output file name
				  Outfile count SetText: Edit_1
				  winpause
				EndIF
			 EndOF 	\ selection of Lock Button

		dlg-unlock of 0 lock-flag !
				folder-select 0=	\ update 151005
				if
				  ENC-Proc1 \ Creates Output file name
				  Outfile count SetText: Edit_1
				  winpause
				EndIF
			   EndOF \ Selection of Un-Lock Button

		dlg-delete of delete-flag not to delete-flag endof \ selection of Delete Original Button

		dlg-cancel of 2drop On_Done: super
			      0 call PostQuitMessage endof 		\ Exit

		dlg-phrase of 1 phrase-flag ! endof			\ Encryption Key Box selected

		dlg-ok of Phrase-Flag @
\
			  ms@ to process-timer \ get current time
			  IF GetText: PassWordBox1 dup pw-len ! password swap cmove
			     Pw-len @ 8 <
\
			     IF
			      MB_OK z" E N C R Y P T" z" Encryption Key Less EndIF 8 characters!"
			      NULL call MessageBox
			     Else
\
				\ Change Status Display
				msg4 t-buffer enc-msg-proc winpause
			        password pw-len @ enc-pw	\ Encrypt Password
				infile-buffer-ptr 0FFFFH erase

			Begin           \ Added 151006 for Folder support
		          1 +to File-counter
		           folder-select
				IF \ to process a folder of files
					dir-Buffer folder-offset + dup
					zcount 0dH SCAN    \ (Addr1 N1 B -- Addr1 N2) \ Forward Search
					Drop over -
					infile 0FFH erase
					dup infile ! dup 1+ +to folder-offset
					infile 1+ swap cmove
					ENC-Proc2 \ Open input file
					ENC-Proc1 \ Create Output file name
					infile-buffer-ptr  0FFFFH erase
					infile  count SetText: Text_1
					Outfile count SetText: Edit_1
					winpause
				EndIF
\
				GetText: Edit_1                 \ Get name of outfile if edited
				dup outfile ! outfile 1+ swap cmove
				enc-proc3                       \ Open Output File write headers
				file-flag not
\
				IF  \ unsuccessful opening of both files
				MB_OK z" E N C R Y P T" z" Unable to Open Files"
\				On_Done: super
				Else
					lock-flag @ not if Enc-Proc5 endif  \ corrected to test if lock-flag is 0 = unlock
					begin \ Main procedure to read in data, encrypt-decrypt and write out data
						infile-buffer-ptr inb-len @ infile-ptr read-file
						drop bytes-read !
\
				\ Change Progress Display
						msg6 t4-buffer enc-msg-proc
						decimal infile-len (.) t4-buffer +place hex
						Paint: self
\
						WinPause  			\ to process messages
\
						password pw-len infile-buffer-ptr bytes-read Lock-Flag \ Values passed on stack
						Enc-Main-Proc 			\ encrypt buffer
						infile-buffer-ptr bytes-read @
						outfile-ptr write-file drop
						infile-len bytes-read @ - dup to infile-len 0=
\
					Until \ files size is reduced to 0
\
					msg5 t3-buffer enc-msg-proc
					msg-blank t4-buffer enc-msg-proc
					msg-blank t-buffer enc-msg-proc
					Paint: self
					WinPause  			\ to process messages
					outfile-ptr close-file drop     \ Close output file
					delete-flag
\
					IF		   \ Delete original file
						enc-proc4       \ Need to first zero out all the data in the original file
					Else
						infile-ptr close-file drop \ Close input file
					EndIF
\
				EndIF
\
		     dir-path @ 0=
			IF -1 \ dir-path empty check
			Else dir-Buffer folder-offset + c@ 0=
			Endif
\
                    Until           \  Added 151060 for Folder option
\
				ms@ process-timer - to process-timer \ get current time calc elapsed time
				\ Change Progress Display
				msg7 t4-buffer enc-msg-proc
				decimal process-timer (.) t4-buffer +place hex
				Paint: self
				Winpause
				infile-buffer-ptr 0FFFFH erase
                                SDIR-Close
				password 20 erase
				Dir-Path MAX-PATH erase
				0 to Dir-Buffer
				Infile 0FFH erase
				Outfile 0FFH erase
				bypass 9 erase
				infile-buffer-ptr ?dup	\ Release allocated memory
				if free drop EndIF
				    s" Quit"	SetText: Button_2
				    msg-blank count SetText: Text_1
				    s" - - "	SetText: Button_1
				    False GetHandle: Button_1 Call EnableWindow Drop
\ btnNameInsidePopup.Visibility = Visibility.Collapsed;
				    winpause
				EndIF
\
			  Else MB_OK z" E N C R Y P T" z" Missing Encryption Key!"
			       NULL call MessageBox

			  EndIF

			EndOF
        endcase
;M

\
;Object
\
\ ***************************************************************************************
\
Turnkey? [IF]
\
: ENCRYPT
		Start: EncryptWindow ;
chdir \Programming\Win32Forth\proj\Encrypt
' ENCRYPT turnkey Encrypt32.exe
        s" ENC-Lock.ico" s" Encrypt32.exe"
	AddAppIcon

\         \ 1 pause-seconds \ bye
\ winver winnt4 >=
\ [IF] \ For V6.0.0.0 Common-Controls
\ current-dir$ count pad place
\ s" \" pad +place
\ s" Encrypt32.exe" pad +place
\ pad count "path-file drop AddToFile
\ CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST
\ s" Encrypt32.exe.manifest" "path-file drop AddResource
\ 101 s" Lock.ico" "path-file drop AddIcon
\ false EndUpdate
\ [else]
\ s" Lock.ico" s" Encrypt32.exe" Prepend<home>\ AddAppIcon
\ [EndIF]

[ELSE]

\ ***************************************************************************************

: ENCRYPT       ( -- )                  \ start running the program
		Start: EncryptWindow ;

\ ***************************************************************************************

: XENC        ( -- )                  \ close the window
              Close: EncryptWindow
	       BYE
;
[EndIF]

cr cr .( Type: ENCRYPT to Start, Type XENC to Quit) cr

\ ***************************************************************************************
\s
