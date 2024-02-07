\ WinInet.F Library
\ FJRusso
\ 071104
\
\  This is intended to be a simple wordset for WinInet.DLL interface in Win32Forth.
\
\ : FTP-Put-File ( Addr1 Addr2 addr3 addr4 addr5 addr6 -- Flag ) - Send a file to server
\   Addr1 zstring to local file name
\   Addr2 zstring to Local Directory if other than root.  Use NULL of no change
\   Addr3 zstring to Server Directory if other than root. Use NULL of no change
\   Addr4 zstring to User Password
\   Addr5 zstring to User Username
\   Addr6 zstring to Server name or IP address 200.100.90.20
\   Addr7 zstring to a name for the session
\
\   Flag 0= failure / 1= insufficient parameters / 1> connection made : Handle used
\
\ : FTP-Get-File	\ Get a file off of server
\
\ : Inet-error 		\ Display Last server internet response
\
\ 0 call InternetAttemptConnect     \ Attempt to make an internet connection
\   0= active internet connection
\ **************************************************************************
\
anew wininet.f
\
\ Structure for FTP service
\
0 nostack1
31 char+ field+ Fname
31 char+ field+ Ldir
31 char+ field+ Rdir
31 char+ field+ password
31 char+ field+ username
63 char+ field+ FTPserver
15 char+ field+ sessionID
31 char+ field+ email-user
31 char+ field+ email-password
31 char+ field+ pop3-addr
31 char+ field+ smtp-addr
constant ftp-size
ftp-size newuser ftpservice
\
0 value INTERNET_OPEN_TYPE_PRECONFIG    // 0   use registry configuration
1 value INTERNET_OPEN_TYPE_DIRECT       // 1   direct to net
3 value INTERNET_OPEN_TYPE_PROXY        // 3   via named proxy
1 value INTERNET_SERVICE_FTP		// 1   FTP Service type
3 value INTERNET_SERVICE_HTTP		// 3   HTTP Service
0 value inet-stat			// 0   internet connection status
\
\ Following values used when writting a new file to a server
0 value infile-ptr
0 value infile-len
0 value infile-buffer-ptr
\ 0 value file-flag
\
0x10000000 value INTERNET_FLAG_ASYNC          // 0x10000000  this request is asynchronous (where supported)
0x01000000 value INTERNET_FLAG_OFFLINE        // 0x01000000  use offline semantics
0x00000000 value FTP_TRANSFER_TYPE_UNKNOWN    // 0x00000000
0x00000001 value FTP_TRANSFER_TYPE_ASCII      // 0x00000001
0x00000002 value FTP_TRANSFER_TYPE_BINARY     // 0x00000002
0x04000000 value INTERNET_FLAG_NO_CACHE_WRITE // 0x04000000 don't write this item to the cache
0x80000000 value GENERIC_READ                 // 0x80000000
0x40000000 value GENERIC_WRITE                // 0x40000000
0x00000010 value INTERNET_FLAG_NEED_FILE      // 0x00000010
0x08000000 value INTERNET_FLAG_PASSIVE 	      // 0x08000000
0x00000080 value FILE_ATTRIBUTE_NORMAL	      // 0x00000080 used to create or get a file
\
create proxy 80 allot proxy 80 0 fill			\ not used at present
create proxy-bypass 80 allot proxy-bypass 80 0 fill	\ not used at present
create chdir-name 1024 allot chdir-name 1024 0 fill 	\ Change working directory on server
\ create dir-path 1024 allot dir-path 1024 0 fill 	\ Hold directory path of server
create FTP-Command 64 allot FTP-command 64 0 fill 	\ Hold FTP command
create error-buffer 1024 allot error-buffer 1024 0 fill \ Buffer used for error messages
Variable dwContext 0 dwContext ! 			\ DWORD_PTR dwContext
\
\ **************************************************************************
\
winlibrary wininet.dll

\ Import functions to the dll

5 PROC InternetOpen
0 value inet-handle
\ HINTERNET InternetOpen(
\  LPCTSTR lpszAgent,
\  DWORD dwAccessType,
\  LPCTSTR lpszProxyName,
\  LPCTSTR lpszProxyBypass,
\  DWORD dwFlags
\ );

8 PROC InternetConnect
0 value inet-connect-handle
\ HINTERNET InternetConnect(
\  HINTERNET hInternet,
\  LPCTSTR lpszServerName,
\  INTERNET_PORT nServerPort,
\  LPCTSTR lpszUsername,
\  LPCTSTR lpszPassword,
\  DWORD dwService,
\  DWORD dwFlags,
\  DWORD_PTR dwContext
\ );

2 PROC FtpSetCurrentDirectory
\ BOOL FtpSetCurrentDirectory(
\  HINTERNET hConnect,
\  LPCTSTR lpszDirectory
\ );

3 PROC FtpGetCurrentDirectory
variable dir-size 1024 dir-size !
\ BOOL FtpGetCurrentDirectory(
\   HINTERNET hConnect,
\  LPTSTR lpszCurrentDirectory,
\   LPDWORD lpdwCurrentDirectory
\ );

7 PROC FtpGetFile
\ BOOL FtpGetFile(
\ HINTERNET hConnect,
\  LPCTSTR lpszRemoteFile,
\  LPCTSTR lpszNewFile,
\  BOOL fFailIfExists,
\  DWORD dwFlagsAndAttributes,
\  DWORD dwFlags,
\  DWORD_PTR dwContext
\ );

5 Proc FtpPutFile
\ BOOL FtpPutFile(
\  HINTERNET hConnect,
\  LPCTSTR lpszLocalFile,
\  LPCTSTR lpszNewRemoteFile,
\  DWORD dwFlags,
\  DWORD_PTR dwContext
\ );

5 PROC FtpOpenFile
0 value open-file-handle
\ HINTERNET FtpOpenFile(
\  HINTERNET hConnect,
\  LPCTSTR lpszFileName,
\  DWORD dwAccess,
\  DWORD dwFlags,
\  DWORD_PTR dwContext
\ );

6 PROC FtpCommand \ Send Server a direct FTP command
variable FtpCommandresp 0 FtpCommandresp !
\ BOOL FtpCommand(
\  HINTERNET hConnect,
\  BOOL fExpectResponse,
\  DWORD dwFlags,
\  LPCTSTR lpszCommand,
\  DWORD_PTR dwContext,
\  HINTERNET* phFtpCommand
\ );

1 PROC InternetAttemptConnect \ Attempt to make internet connection
\ DWORD InternetAttemptConnect(
\   DWORD dwReserved
\ );

4 PROC InternetWriteFile
variable inb-len
variable bytes-read
variable BytesWritten
\ BOOL InternetWriteFile(
\  HINTERNET hFile,
\  LPCVOID lpBuffer,
\  DWORD dwNumberOfBytesToWrite,
\  LPDWORD lpdwNumberOfBytesWritten
\ );

3 PROC InternetGetLastResponseInfo
Variable dwError
Variable dwBuf-Len
\ Retrieves the last error description or server response on the thread calling this function.
\ BOOL InternetGetLastResponseInfo(
\  LPDWORD lpdwError,
\  LPTSTR lpszBuffer,
\  LPDWORD lpdwBufferLength
\ );

1 PROC InternetCloseHandle
\ BOOL InternetCloseHandle(
\  HINTERNET hInternet
\ );
\
\ End of Procs for WinInet.dll
\
\ **************************************************************************
: Inet-Open ( --- Flag )
\
0 to inet-handle 	  \ initialize handle to null
INTERNET_FLAG_ASYNC 	  \ dwflag
proxy-bypass 		  \ Not Used at present
proxy 			  \ Not Used at present
INTERNET_OPEN_TYPE_DIRECT \ Type flag
ftpservice sessionid	  \ Session ID = Name used by sender
call InternetOpen
to inet-handle 		  \ if Handle = 0  no connection
;
\ **************************************************************************
: Inet-error
dwbuf-len dup 1024 swap !
error-buffer
dwerror
call InternetGetLastResponseInfo
drop
cr error-buffer dwbuf-len @ type cr ." Error # " dwerror @ . cr
;
\ **************************************************************************
: Inet-Connect
\
0 		      \ dwContext Not used
INTERNET_FLAG_PASSIVE \ dwFlags
INTERNET_SERVICE_FTP  \ dwService
ftpservice password   \ userpw
ftpservice username   \ username
21 		      \ FTP Port #
ftpservice ftpserver  \ server-name
inet-handle
call InternetConnect
dup 0=
if
 drop
 dwbuf-len dup 1024 swap !
 error-buffer
 dwerror
 call InternetGetLastResponseInfo
 drop
else to inet-connect-handle
then
;

\ **************************************************************************
: Inet-Directory ( LPZSTR -- ) \ Get current directory
\
 1024 dir-size ! dir-size
 dir-path dup 1024 0 fill
 inet-connect-handle
 call FtpGetCurrentDirectory drop
 100 _ms
;

\ **************************************************************************
: Change-Inet-Directory  ( LPZSTR -- ) \ Change working Directory
\
 inet-connect-handle
 call FtpSetCurrentDirectory drop
 100 _ms
;

\ **************************************************************************
: FTP-Put-File ( Addr1 Addr2 addr3 addr4 addr5 addr6 -- Flag )
\ updated 071009
\ Steps :
\ call InternetOpen
\ call InternetConnect
\ call FtpSetCurrentDirectory - Optional - use if not working in the root directory
\ call FtpPutFile
\ call InternetCloseHandle
\
\ All data needed is now stored in the data structure ftpservice
\
Inet-open
inet-handle
if \ 0> success in connecting =0 then no connection available

 0 to inet-connect-handle \ initialize handle to null
 \ Connect to server
 Inet-Connect
 \ Change server working Directory
 ftpservice rdir zcount
 if \ not a NULL
  Change-Inet-Directory
 else drop \ using root no need to change directory
 then
 \
 \ Send file to server
 \
 0 				\ dwcontext not used
 FTP_TRANSFER_TYPE_BINARY 	\ Transfer Mode Flag
 INTERNET_FLAG_NEED_FILE 	\ Cache Flag
 or 				\ combine into dwFlags
 ftpservice fname 		\ remote-file name on stack
 dup				\ local-file name on stack

 inet-connect-handle
 call FtpPutFile \ keep flag for failure check
 100 _MS

 \ Close Internet handle
 begin
  inet-handle call InternetCloseHandle not
 until

then

\ Flag on stack 0 = failure 1 success

;

\ **************************************************************************
: Ftp-OpenFile
\
\ Assumes name of file to write to server is loaded into 'local-file'
\ Assumes server directory has been selected
\
\ HINTERNET FtpOpenFile(
\  HINTERNET hConnect,
\  LPCTSTR lpszFileName,
\  DWORD dwAccess,
\  DWORD dwFlags,
\  DWORD_PTR dwContext
\ );

inet-connect 			\ returns a handle in inet-connect-handle
 >r 				\ zstring to local file name
 0 				\ dwContext
 FTP_TRANSFER_TYPE_ASCII 	\ Transfer Mode Flag
 INTERNET_FLAG_NO_CACHE_WRITE 	\ Cache Flag
 or 				\ combine into dwFlags
 Generic_write			\ type flag
 r> 				\ local-file name
 inet-connect-handle
 call FtpOpenFile
 to open-file-handle
;
\ **************************************************************************

: FTP-WriteFile
\ Assumes successful opening of file on server

\ BOOL InternetWriteFile(
\  HINTERNET hFile,
\  LPCVOID lpBuffer,
\  DWORD dwNumberOfBytesToWrite,
\  LPDWORD lpdwNumberOfBytesWritten
\ );
\
\ Open local file
\ Get file size
\ Malloc memory to readin file for transfer.
\ zstring on stack with local file name
 \ local-file
   zcount r/o open-file 0=	  \ attempt to open input file r/o read only
  if
    1 to file-flag \ success opening
    dup to infile-ptr file-size 2drop to infile-len  \ save file pointer get file length
    infile-len 10 / 1+ 10 * dup
    FFFFH >
    if drop FFFFH then
    dup

    malloc to infile-buffer-ptr    \ calc & allocate buffer space up to 64K (FFFFh) size

    dup inb-len ! infile-buffer-ptr swap erase  \ clear space

 \ Need to set up a loop to read in and write out from local file.
 \ Begin
 infile-buffer-ptr inb-len @ infile-ptr read-file
 drop bytes-read !
\ BOOL InternetWriteFile(
\  HINTERNET hFile,
\  LPCVOID lpBuffer,
\  DWORD dwNumberOfBytesToWrite,
\  LPDWORD lpdwNumberOfBytesWritten
 byteswritten      \ returned from server
 bytes-read @      \ sent to server
 infile-buffer-ptr \ output buffer
 open-file-handle  \ server ahndle to file
 call InternetWriteFile drop
 \ Until \

 infile-buffer-ptr ?dup	\ Release allocated memory
 if free drop then
 infile-ptr close-file	\ Close input file

else 3drop 0 to file-flag   \ File open failure

then

;
\ **************************************************************************
: FTP-Put-NewFile

Inet-open
inet-handle
if 			  \ 0> success in connecting =0 then no connection available
 0 to inet-connect-handle \ initialize handle to null
 Inet-Connect
 Ftp-OpenFile
 FTP-WriteFile
 begin
  inet-handle call InternetCloseHandle not
 until
then
inet-handle \ leave on stack as indicator to calling program if success
\ 0 = faliure 0> success
;

\ **************************************************************************
: FTP-Get-File \ Updated 070218
\ Steps :
\ call InternetOpen
\ call InternetConnect
\ call FtpSetCurrentDirectory - Optional - use if not working in the root directory
\ call FtpGetFile
\ call InternetCloseHandle
\
\ All data needed is now stored in the data structure ftpservice
\
Inet-open
inet-handle
if 			  \ 0> success in connecting =0 then no connection available
 0 to inet-connect-handle \ initialize handle to null
 Inet-Connect
 \ Change working Directory
 ftpservice rdir zcount
 if \ not a NULL
  Change-Inet-Directory
 else drop \ using root no need to change directory
 then
\
\ Send file to server
\
 0 				\ dwcontext not used
 FTP_TRANSFER_TYPE_BINARY 	\ Transfer Mode Flag
 INTERNET_FLAG_NEED_FILE 	\ Cache Flag
 or 				\ combine into dwFlags
 FILE_ATTRIBUTE_NORMAL		\ file attributes
 False				\ Boolean for if file exist to get anyway
 ftpservice fname 		\ remote-file name on stack
 dup 				\ local-file name on stack

 inet-connect-handle

 call FtpGetFile drop
 100 _MS

 begin
  inet-handle call InternetCloseHandle not
 until
then

inet-handle \ leave on stack as indicator to calling program if success
\ 0 = faliure 1> success

;
\
\ **************************************************************************************
\
: Inet-Check ( - F ) \ Try 3 times to see if an Internet connection is available
 0 to inet-stat
 3 0 do
 0 call InternetAttemptConnect    \ Attempt to make an internet connection
 0= if -1 to inet-stat leave then \ active internet connection
 500 _ms \ delay .5 seconds
 loop
\ inet-stat is checked for success on return to calling module.
inet-stat
;
\ **************************************************************************
