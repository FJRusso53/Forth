\ Encrypt.F
\ Frank J. Russo
\ Version 3.1  Support for Folder - Directory - Sub-Diretory Processing
\ Storing & Recovery of original file Suffix
\ Date 210126
\
\ Average run time of 470 ms per Mb.
\
\ MB_OK z" TEST Point" z" TEST Point 1" NULL call MessageBox
\
ANEW Encrypt20
\
True value CreateTurnkey? \ set to TRUE if you want to create a turnkey application
\
' only forth also definitions hidden also forth
\
chdir \Win32Forth\src\lib
needs Resources.f
needs excontrols.f
include SUB_DIRS.F \ src\lib
\
include Encrypt.h
\
chdir \Win32Forth\include
include string.f
\
chdir Win32Forth\proj\Encrypt
\
HEX   \  ALL numerics used are in HEX NOT Decimal !!!!!!
\
\ ***************************************************************************************
\
FileOpenDialog filelocate "E N C R Y P T I O N - Select your input file :" "All Files|*.*|"
\
\ ***************************************************************************************
\
: Folder-Browse
z" E N C R Y P T I O N - Select a Folder" Dir-Path hWnd BrowseForFolder
;
\
\ ***************************************************************************************
\
: createfile2 ( adr slen fmode -- fileid ior ) \ 160428
\ Need to be able to detect if a file already exist
\ return -1fh = failed to open
\
   -rot MAXSTRING _LOCALALLOC ascii-z              \ fmode adrstr - & convert to zstring
   2>r                                             \ ( r: adrstr fmode  )
   0                                               \ hTemplateFile
   FILE_FLAG_SEQUENTIAL_SCAN                       \ fdwAttrsAndFlag
   CREATE_NEW                                      \ fdwCreate
   0                                               \ lpsa
   [ FILE_SHARE_READ FILE_SHARE_WRITE or ] literal \ fdwShareMode
   2r>                                             \ fdwAcess(fmode) lpszName(adr)
   call CreateFile
   dup INVALID_HANDLE_VALUE =                      \ fileid ior - 0 = success
   _LOCALFREE ;
\
\ ***************************************************************************************
\
: ENC-Msg-Proc ( msg, buffer --- )
\ moves messages in header file to text out buffer for display
to bufptr to msgptr
msgptr 20 null instrb swap drop
msgptr swap dup bufptr ! 1 +to bufptr bufptr swap cmove
;
\
\ ***************************************************************************************
\
: Enc-PW-bypass ( - F) \ 200805 Corrected and Functioning
\
\ Check for bypass
  bypass 9 password 9 COMPARE not
  If    \ Do they match ?
        \ Bypass and Password match got a hit
        \ Retrieve encryption key from file
	infile-buffer-ptr inb-len @ infile-ptr read-file
	drop bytes-read !
	0 0 infile-ptr REPOSITION-FILE drop \ reset file pointer to begining of file Version 1.
	  infile-buffer-ptr msg3 msg1 - 0Ah InstrB + 1+ dup \ locate 0Ah in stream +1
	  infile-buffer-ptr msg3 msg1 - IDM_Exit InstrB + \ locate idm-exit in stream
          \ len = EDP - STP
          swap - Pw-len !
         Pw-len @ password swap cmove   \ Move key to Password field
      0
      Else -1
  Then
;
\
\ ***************************************************************************************
\
: Enc-PW  \ (addr n ---) Updated 150819
\
\ Code encryption key to values of 0 - F
\
dup 9 = lock-flag @ not and  \ Check to see if lenght of PW = 9 and Lock-Flag = Unlock = 0
if  2drop Enc-PW-bypass else -1 then
if
 0 Do Dup Dup @ ( 31 or) 0F and dup
	not if 1+ endif
	swap C! 1+ loop drop  \ Encrypt the password
then
\
lock-flag @
if
  password pw-len @ msg2a swap cmove \ move the encrypted pw to message field for output to file
  msg2a zcount + IDM_Exit swap c! \ end of PW identifier
then
;
\
\ ***************************************************************************************
\
: ENC-Proc1 	\ ( -- ) Creates an Output file name Revised 200805
\
Outfile 0FFh erase
Infile count dup Outfile c! Outfile 1+ swap cmove \ duplicate name to outfile

\ search for '.' at end of file name
outfile count 2e -instrb 1- -  \ returns with address and offset
lock-flag @
   if
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
\ Revision 2008005 Recover original file extension
	0 0 infile-ptr REPOSITION-FILE drop 		 \ reset file pointer to begining of file
	infile-buffer-ptr inb-len @ infile-ptr read-file 2drop \ Read in Header Data
	infile-buffer-ptr 60 IDM_Exit InstrB + 1+ dup 	 \ locate idm-exit (C9h) End of the Password
	\ need trap if idm-exit not located
	infile-buffer-ptr 60 DFh InstrB + 		 \ locate DFh End of the file extension
	\ need trap if DFh not located
	over - over over \ Adr C Adr C
	0 Do Dup dup C@ 64h - swap C! 1+ loop drop swap drop \ Decrypt File Suffix
	\ Adr C on stack
	\ s" unl"  to be used only for an early version
   then
   rot swap over zcount erase cmove \ change suffix on file name
   outfile zcount 1- swap c! \ Save length

\ Checking for outfile name = infile name and correct
   infile count outfile count strcmp
   if 	\ file names are indentical 1
	31 Outfile dup count 1+ swap drop swap c! \ increment the count byte and store
	outfile count + 1 - c!                    \ append a '1' to the end of the file name
   then
;
\
\ ***************************************************************************************
\
: ENC-Proc2 \ Open Input file \ Updated 151005

  infile count r/o open-file 0=	  \ attempt to open input file r/o read only
  if
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 * dup
    FFFFH >
    if drop FFFFH then
    inb-len !
  else drop 0 to file-flag   \ File open failure
  then
;
\
\ ***************************************************************************************
\
: ENC-Proc3 \ Updated 160428 ( - ) Called from :M On_Command: Case OK
0 to process-count
 Begin
   outfile count w/o create-file dup 0<>  \ Create output file rtn with FileID - IOR
   If
     2drop ( FileID - IOR ) outfile count
     process-count 0=
     if
       1+ 2dup swap 1- c! 2dup + 1- 30H swap c!
     endif
     + 1- dup C@ 1+ swap C!
     1 +to process-count
     process-count 3 > if -1 -1 else 0 endif \ 3 attempts to open a file with an additional extensio (x.x1 - 3)
   else -1
   endif
 Until
 \ outfile count w/o create-file 0=   \ Create output file
  0=
  if
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
	then
  else drop 2drop 0 to file-flag \ File open failure
	 infile-ptr close-file	 \ Close input file
  then
;
\
\ ***************************************************************************************
\
: ENC-Proc4 \ 200805 editorial Close input file
\
   MB_OK z" TEST Point" z" TEST Point 3" NULL call MessageBox
\
   infile-ptr close-file drop \ Close input file
   infile count r/w open-file 0=  \ attempt to reopen input file r/w
   if
	to infile-ptr   \ Save file pointer
	infile-ptr file-size 2drop to infile-len
	inb-len @ infile-buffer-ptr swap erase  \ erase file buffer clear space

	0 0 infile-ptr REPOSITION-FILE drop \ move pointer to start of file

	begin \ write 0's to file
		infile-buffer-ptr infile-len inb-len @ min infile-ptr write-file
		infile-len inb-len @ - dup to infile-len 1 <
	until

	infile-ptr close-file drop \ Close input file
	infile count delete-file drop
   then
;
\
\ ***************************************************************************************
\
: Enc-Proc5 \ only for encrypted files 200805 Addition made in Ver2*
\
	0 0 infile-ptr REPOSITION-FILE drop \ reset file pointer to begining of file
	infile-buffer-ptr inb-len @ infile-ptr read-file \ read
	drop bytes-read !
	infile-buffer-ptr msg1 zcount swap over 2 - strndx
\
	if
	  2drop \ Version is 2 or greater
	  True to version2
	  infile-buffer-ptr msg3 msg1 - DFh InstrB \ Locate DFh in the header of the input stream
	  1+ to inb-offset \ save location after the 0DFh
	  drop
	  inb-offset 0 infile-ptr REPOSITION-FILE drop \ set file pointer to begining of file Version 2.
\	  infile-buffer-ptr inb-len @ infile-ptr read-file \ read
\	  drop bytes-read !
	else
	  2drop 0 0 infile-ptr REPOSITION-FILE drop \  reset file pointer to begining of file Version 1.
	then
\
	inb-len @ infile-buffer-ptr swap erase  \ clear space
	infile-len inb-offset - to infile-len
;
\
\ ***************************************************************************************
\
variable cx-v
variable Rotate-V
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
\
\ ***************************************************************************************
\
variable start-p
variable textposition
variable End-P
variable pw-inc
variable offset-v
: Enc-Fetch       \ Fetch word from buffer
        Begin

                00FF00 8 start-p @ textposition C@ + C@ swap LShift and Cx-V !
                End-P @ textposition C@ - C@ 000000ff and Cx-V +!

                Enc-Rotate \  Actual Encrypting & Decrypting of words

                \ reload values to buffer
                cx-v @ DUP FF00 AND 8 rshift start-p @ textposition @ + c!
                00ff and end-p @ textposition @ - c!

                1 pw-inc +! pw-inc @ pw-len @ =
                if 0 pw-inc ! then

                1 textposition +! textposition @ offset-v @ 2 / >
        Until
;
\
\ ***************************************************************************************
\
variable new-start-p
: Enc-Main-Proc \ Updated 150818

0 0 0 0 pw-inc ! textposition ! new-start-p ! cx-v ! \ initiate values to 0
\
Infile-Buffer-ptr Start-P !      \ set Starting point to the beginning of the Buffer
\
  Begin
        password pw-inc @ + C@ offset-v C! \ load Offset-V with byte from PW phrase

        1 pw-inc +! pw-inc C@ pw-len C@ =
        if 0 pw-inc ! then             \ reset to 0 if at end of password buffer

        pw-inc C@ password + c@ rotate-v c!  \ Load Rotate Value
        start-p @ offset-v C@ + end-p !      \ Establish End Pt

        end-p @ infile-buffer-ptr bytes-read @ 1- + >
	\ End Pt at end of In-Buffer
        if   \ true if not at end of in-buffer
           infile-buffer-ptr bytes-read @ 1- + end-p !
           end-p @ start-p @ - offset-v C!
       then

        end-p @ 1+ new-start-p !   \ Save next start pt
        Enc-Fetch
        new-start-p @ start-p ! 0 textposition !
        new-start-p @ 1+ infile-buffer-ptr bytes-read @ + >

  until
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

:M StartSize:   ( -- w h ) \ the width and height of our window
                1D0 120
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
		5 B0 s" IN - File:" textout: dc
		2 D8 s" Out - File:" textout: dc
;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super  \ do anything superclass needs

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

\ Allocate memory
		0FFFFH malloc to infile-buffer-ptr  \ allocate buffer space 64K (FFFFh) size
		infile-buffer-ptr 0FFFFH erase      \ clear space

		folder-select 0=   \ update 151005
		if ENC-Proc2 then  \ Open Input file

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
                50 D0h 178 24	Move:     Edit_1
		ES_LEFT 	+STYLE:   Edit_1

                self		Start:    Text_2
                50 50 110 12	Move:     Text_2
				GetStyle: Text_2
		SS_CENTER 	+Style:   Text_2
                s" Enter Encryption Key 8 - 32 Characters"
				SetText:  Text_2

                dlg-phrase	SetID:    PassWordBox1
                self 		Start:    PassWordBox1
                50 65 140 15 	Move:     PassWordBox1

                self		Start:    Text_1
                50 A8 178 24	Move:     Text_1
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
		dlg-lock of 1 lock-flag !
				folder-select 0=	\ update 151005
				if
				  ENC-Proc1 \ Creates Output file name
				  Outfile count SetText: Edit_1
				  winpause
				then
			 endof 	\ selection of Lock Button

		dlg-unlock of 0 lock-flag !
				folder-select 0=	\ update 151005
				if
				  ENC-Proc1 \ Creates Output file name
				  Outfile count SetText: Edit_1
				  winpause
				then
			   endof \ Selection of Un-Lock Button

		dlg-delete of delete-flag not to delete-flag endof \ selection of Delete Original Button

		dlg-cancel of 2drop On_Done: super
			      0 call PostQuitMessage endof 		\ Exit

		dlg-phrase of 1 phrase-flag ! endof			\ Encryption Key Box selected

		dlg-ok of Phrase-Flag @
\
			  ms@ to process-timer \ get current time
			  if GetText: PassWordBox1 dup pw-len ! password swap cmove
			     Pw-len @ 8 <
\
			     if
			      MB_OK z" E N C R Y P T" z" Encryption Key Less then 8 characters!"
			      NULL call MessageBox
			     else
\
				\ Change Status Display
				msg4 t-buffer enc-msg-proc winpause
			        password pw-len @ enc-pw	\ Encrypt Password
				infile-buffer-ptr 0FFFFH erase

			Begin           \ Added 151006 for Folder support
		          1 +to File-counter
		           folder-select

				if \ to process a folder of files
					dir-buffer dup folder-offset +
					zcount 0dH InstrB    \ InstrB (Addr1 N1 B -- Addr1 N2) \ Forward Search
					infile 0FFH erase
					dup infile ! 2dup infile 1+ swap cmove
					+ swap - 1+ to folder-offset
					ENC-Proc2 \ Open input file
					ENC-Proc1 \ Create Output file name
					infile-buffer-ptr  0FFFFH erase
					infile  count SetText: Text_1
					Outfile count SetText: Edit_1
					winpause
				then
\
				GetText: Edit_1                 \ Get name of outfile if edited
				dup outfile ! outfile 1+ swap cmove
				enc-proc3                       \ Open Output File write headers
				file-flag not
\
				if  \ unsuccessful opening of both files
				MB_OK z" E N C R Y P T" z" Unable to Open Files"
\				On_Done: super
				else
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
						Enc-Main-Proc 			\ encrypt buffer
						infile-buffer-ptr bytes-read @
						outfile-ptr write-file drop
						infile-len bytes-read @ - dup to infile-len 0=
\
					until \ files size is reduced to 0

					msg5 t3-buffer enc-msg-proc
					msg-blank t4-buffer enc-msg-proc
					msg-blank t-buffer enc-msg-proc
					Paint: self
					WinPause  			\ to process messages
					outfile-ptr close-file drop     \ Close output file
					delete-flag

					if		   \ Delete original file
						enc-proc4       \ Need to first zero out all the data in the original file
					else
						infile-ptr close-file drop \ Close input file
					then

				then

		     dir-buffer 0=
			if -1 \ dir-buffer empty check
			else dir-buffer folder-offset + c@ 0=
			endif

                    Until           \  Added 151060 for Folder option
\
				ms@ process-timer - to process-timer \ get current time calc elapsed time
				infile-buffer-ptr 0FFFFH erase
                                SDIR-Close
				password 20 erase
				Dir-Path MAX-PATH erase
				Infile 0FFH erase
				Outfile 0FFH erase
				bypass 9 erase
				infile-buffer-ptr ?dup	\ Release allocated memory
				if free drop then
				    s" Quit"	SetText: Button_2
				    msg-blank count SetText: Text_1
				    s" - - "	SetText: Button_1
				    False GetHandle: Button_1 Call EnableWindow Drop
\ btnNameInsidePopup.Visibility = Visibility.Collapsed;
				    winpause
				then
\
			  else MB_OK z" E N C R Y P T" z" Missing Encryption Key!"
			       NULL call MessageBox

			  then

			endof
        endcase
;M

;Object
\
\ ***************************************************************************************
\
CreateTurnkey? [IF]

: ENCRYPT
		Start: EncryptWindow ;
chdir Programming\Win32Forth\proj\Encrypt
' ENCRYPT turnkey Encrypt20               \ create - Encrypt20.exe
        s" Lock.ICO" s" Encrypt20.exe" AddAppIcon
         1 pause-seconds \ bye

[ELSE]

\ ***************************************************************************************

: ENCRYPT       ( -- )                  \ start running the program
		Start: EncryptWindow ;

\ ***************************************************************************************

: XENC        ( -- )                  \ close the window
              Close: EncryptWindow
	       BYE
;
[THEN]

cr cr .( Type: ENCRYPT to start, and: XENC to stop) cr

\ ***************************************************************************************
