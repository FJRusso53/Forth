\ Encrypt.H
\ Frank J. Russo
\ Date 210214
\
\ Constants, Pointers, Variables and Messages
\
\ 0 value hMenu
\ Create In-buffer 2048 allot In-buffer 2048 erase
\ Create ps 64 allot ps 64 erase ( paintstruct )
\ Create tm 64 Allot tm 64 erase ( textmetrics)
\ Variable Bytes-Written
\ Variable cxCharW
\ Variable CxClient
\ Variable cyCharH
\ Variable CyClient
\ Variable enc-cond
\ Variable hdlg
\ Variable Input-flag
\ Variable OutB-Len
\ Variable temp-buf
\ Variable Test-Bit
\
Needs struct.f
\
struct{
     int .style        \  = CS_HREDRAW | CS_VREDRAW ;
     int .lpfnWndProc   \ = WndProc ;
     int .cbClsExtra    \ = 0 ;
     int .cbWndExtra    \ = 0 ;
     int .hInstance    \  = hInstance ;
     int .hIcon        \  = LoadIcon (NULL, IDI_APPLICATION) ;
     int .hCursor       \ = LoadCursor (NULL, IDC_ARROW) ;
     int .hbrBackground \ = (HBRUSH) GetStockObject (WHITE_BRUSH) ;
     int .lpszMenuName  \ = NULL ;
     int .lpszClassName \ = szAppName ;
}struct _wndclass
sizeof _wndclass mkstruct: .wndclass \ applying the structure
\
\
0 Value bufptr
0 Value dc
0 Value delete-flag
0 Value file-counter
0 Value file-flag
0 Value folder-select
0 Value folder-offset
0 Value hWnd
0 Value hdlc
0 Value inb-offset
0 Value infile-buffer-ptr
0 Value infile-len
0 Value infile-ptr
0 Value msgptr
0 Value outfile-ptr
0 Value process-count
0 Value process-timer
0 Value xptr
0 Value yptr
0 Value version2

     1 Constant IDM_Begin
101 Constant dlg-cancel
102 Constant dlg-ok
103 Constant dlg-delete
110 Constant dlg-input
111 Constant dlg-output
112 Constant dlg-phrase
113 Constant dlg-listbox
114 Constant dlg-lock
115 Constant dlg-unlock
200 Constant IDM_Close \ 0C8h
201 Constant IDM_Exit \ 0C9H
216 Constant win-id
0x10000 Constant FunctionKey
0x50000 Constant ControlKey
0x90000 Constant ShiftKey
char * Constant Star$

decimal
Create Infile 0FFH Allot Infile 0FFH erase
Create Outfile 0FFH Allot Outfile 0FFH erase
Create Password 32 Allot Password 32 erase
Create rect 16 allot rect 16 erase ( rectangle )
Create T-Buffer 48 Allot T-Buffer 48 erase
Create T1-Buffer 48 Allot T1-Buffer 48 erase
Create T2-Buffer 48 Allot T2-Buffer 48 erase
Create T3-Buffer 48 Allot T3-Buffer 48 erase
Create T4-Buffer 48 Allot T3-Buffer 48 erase
Create Dir-Path MAX-PATH allot Dir-Path MAX-PATH erase
\ Create Dir-Buffer MAX-PATH allot Dir-Buffer MAX-PATH erase

\  Message Area

Create msg1 z,"  Version 4.0 "
Create msg1a z," Property of "
Create msg2 z," Frank J. Russo 2021  "
msg2 zcount t-buffer swap cmove
t-buffer zcount + 2 - dup 0dh swap c! 1+ 0ah swap c!
t-buffer zcount msg2 swap cmove
T-Buffer 48 erase
Create msg2a 48 Allot msg2a 48 erase \ PW
Create msg2b   8 Allot msg2b    8 erase \ File extension
Create msg3 z," Status - Awaiting Input"
Create msg4 z," Status - Processing    "
Create msg5 z," Encryption Completed"
Create msg6 z," Bytes remaining to process - "
Create msg7 z," Process time (ms) = "
Create Msg-Blank z,"                          "
\
Variable Bytes-Read
Variable Byte-1
Variable Byte-2
Variable Enc-Word
Variable I-Counter
Variable InB-Len
Variable Phrase-flag
Variable PW-Len
Variable Lock-Flag
Variable xloc
Variable yloc
\
HEX
Create bypass 10 Allot bypass 10 erase
bypass
dup 2A swap c! 1+  \ *
dup 20 swap c! 1+  \
dup 0ED swap c! 1+ \ Alt1953
dup 46 swap c! 1+  \ F
dup 6A swap c! 1+  \ j
dup 52 swap c! 1+  \ R
dup 0AF swap c! 1+ \ Alt2015
dup 20 swap c! 1+  \
2A swap c!         \ *
Decimal
