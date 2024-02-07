\ Implemented for use in AI-Mind
\ FJRusso 080101 Updated
\ Thanks goes to Tom Dixon For his help and sock.f
\
Anew AIMind-Net
\
0 value sock
0 value sock1
0 value server-stat
0 value htmlfile-ptr
0 value htmlfile1-ptr
0 value sendbuf-len

create sendbuf  1024 allot
create recdvbuf 1024 allot
create file-buffer 160 allot
create srch-msg z," </TABLE>"
create srch-msg2 z," ##0"
create srch-msg2a z," ##A"
create srch-msg2b z," </html>"
create srch-msg3 z," !-- REMARK --"
create msg16 z," TODAY is "
create msg17 z," <html><head><title>Forth AI-Mind</title></head><body><br><hr>"
            +z," <h3>Web page file requested not found by AI.</h3><br><hr></body></html>"
create msg17a z," File - C:\aimind-i\AI-Mind1.htm - Not located"
create msg18 z," &comments=Thank+you+for+your+e-mail+message+to+the+AIMind.+%0D%0A"
	+z," %0D%0AYour+Input+to+help+train+the+AI-Mind+has+been+processed+and+is+now+part+of+it's+Core+Memory"
create msg18a 64 allot msg18a 64 32 fill
\
: server-init ( -- )
  0 to sock 80 sock-create dup to sock
  dup -1 =
  if
    abort" Unable to make socket!"  0 to server-stat
  else
    -1 to server-stat 5 sock sock-listen
  then
;
\ ********************************************************************************
: server-cleanup ( -- )
  sock sock-close drop
  0 to server-stat
;
\ ********************************************************************************
: stype ( sock str len -- sock )
  2>r dup 2r> rot sock-write drop
;
\ ********************************************************************************
: scr ( sock -- sock )
  crlf$ count stype
;
\ ********************************************************************************
: servaccept ( sock -- sock ) \ fetch a line from client
  dup sendbuf 1+ 255 rot sock-read sendbuf c!
;
\ ********************************************************************************
: cr2trailing? ( -- flag ) \ returns true if buffer ends in a double cr
  sendbuf count dup 0 = if 2drop false exit then
  dup 4 < if + 2 - W@ $0A0D = exit then
  + 4 - @ $0A0D0A0D =
;
\ ********************************************************************************
: ##0 ( addr count ---  )
\ Load value from stack to output line as a string
recdvbuf 256 0 fill
sendbuf recdvbuf rot sendbuf-len swap dup >r - cmove r> 3 - swap
3 + rot \ bring value to top
tempspace >string
tempspace dup 1+ swap c@ recdvbuf zcount + swap cmove
recdvbuf zcount + rot cmove
sendbuf 256 0 fill
recdvbuf zcount sendbuf swap cmove
sendbuf zcount to sendbuf-len drop
;
\ ********************************************************************************
: ##A  \ ( addr count ---  )  Updated 070422
recdvbuf 256 0 fill
sendbuf recdvbuf rot sendbuf-len swap dup >r - cmove r> 3 - swap
3 + rot \ bring value to top
zcount recdvbuf zcount + swap cmove
s"      " recdvbuf zcount + swap cmove \ blankout next 5 space incase of carry over
recdvbuf zcount + rot cmove
sendbuf 256 0 fill
recdvbuf zcount sendbuf swap cmove
sendbuf zcount to sendbuf-len drop
;
\ ********************************************************************************
: load-values ( Updated 070727 FJR )
  \ load stack with values to be moved to webpage 'First in Last Out'
  quit-flag
  if   s" <FONT COLOR=#CC0000>  ** Stopped ** <FONT COLOR=#000000>"
  else s" <FONT COLOR=#33CC00>  ** Running ** <FONT COLOR=#000000>"
  then
  get-local-time time-buf >time" 2drop
  time$ zcount date$ zcount
  ms@ trun @ - 60000 / cont-run @ server-hits @ Hash-Count \ ms@ tidle @ - 60000 /
  tov @ t @ dup eeg @ iq @ Dict-Offset cns @ rejuvenatecycle @ emotioncycle @
  sensoriumcycle @ Thinkcycle @ volitioncycle @ securitycycle @ motoriumcycle @
  talive @ ms@ trun @  - 60000 / + ( Talive in minutes )
  DUP 60 /   	\ Talive in hours
  SWAP       	\ minutes come off first
  RTDate 	\ Date of Continuouos run
\  truntime @ 	\ Truntime in minutes
;

\ ********************************************************************************
: sendbuf-read
  sendbuf 256 0 fill
  0 to sendbuf-len
  sendbuf 254 htmlfile-ptr read-line drop
;

\ ********************************************************************************
: html-disp

\ Open file for output of HTML headers 'AI-Mind1.html'
s" AI-Mind1.htm" r/o open-file 0= 		\ open input file r/o read only
\
\ If files opens need to load stack with values to send out to web page
\ Must be loaded in reverse order of use, Last in First off.
\
if \ File has opened continue to process
  to htmlfile-ptr
  load-values
\
  begin
  sendbuf-read
  dup
  if
 	>r to sendbuf-len
	sendbuf sendbuf-len srch-msg2 zcount \ msg2 = '##0' marker in file for data
	search \ --- addr len ior
 	if \ marker located
	  ##0
        else
	  2drop
	then
	sock1 sendbuf sendbuf-len stype scr drop r>
\
  sendbuf sendbuf-len srch-msg zcount search 	\ Does the read in line contain end of table marker?
  >R 2drop R>					\ </TABLE>
    if >R
	sendbuf 256 0 fill
	s" <br>" sendbuf swap cmove		 \ Load a webpage line feed into buffer
	msg16 zcount sendbuf zcount + swap cmove \ load message to buffer
	sendbuf zcount + swap cmove     	 \ move date into buffer
	bl sendbuf zcount + c! 			 \ put a space between the date and the time
	sendbuf zcount + swap cmove     	 \ move time into buffer
	sock1 sendbuf zcount stype scr drop r>	 \ send it out to web page
    then

  else swap drop 				\ no data available last line read
  then
  not until
  htmlfile-ptr close-file drop
else 						\ send message to web page file not found
  drop sendbuf 256 0 fill
  msg17 zcount sendbuf swap cmove  		\ load message to buffer
  sock1 sendbuf zcount stype scr drop
then 						\ end of IF on file opening
;
\ ********************************************************************************
: html-page-update \ Updated 070508

\ Open file for Input of HTML headers
s" AI-Mind1.htm" r/o open-file 0= 		\ open input file r/o read only
\
\ If files opens need to load stack with values to send out to web page
\ Must be loaded in reverse order of use, Last in First off.
\
if \ File has opened continue to process
  to htmlfile-ptr
  s" index.html" w/o open-file 	\ AI-Mind.html open output file
  \ 0 htmlfile-ptr REPOSITION-FILE drop	\ Move to begining of file
  if \ error occured file not located
     drop
     s" index.html" w/o create-file \ AI-Mind Create output file
     drop
  then
  to htmlfile1-ptr
\
\ Lets begin Processing
\
load-values

begin
  file-buffer 160 0 fill
  sendbuf-read
  dup
  if
 	>r to sendbuf-len
	sendbuf sendbuf-len srch-msg2 zcount \ msg2 = '##0' marker in file for data
	search \ --- adrr len ior
 	if \ marker located
	   ##0
        else
	  2drop sendbuf sendbuf-len srch-msg2a zcount \ msg2 = '##A' marker in file for data2drop
          search if ##A else 2drop then
	then
	sendbuf file-buffer sendbuf-len cmove
	0dh file-buffer zcount + c!
	0ah file-buffer zcount + c!
        file-buffer zcount htmlfile1-ptr write-file drop r>
\
  sendbuf sendbuf-len srch-msg3 zcount search 	\ Does the read in line contain REMARK marker?
  if 2drop >R
   file-buffer 160 0 fill
   msg24 zcount file-buffer swap cmove 	\ load message to buffer
   0dh file-buffer zcount + c!
   0ah file-buffer zcount + c!
   file-buffer zcount htmlfile1-ptr write-file drop r>
  else 2drop
  then
\
  file-buffer zcount srch-msg zcount search 	 \ Does the read in line contain end of table marker?
  >R 2drop R>					 \ </TABLE>
    if >R
	file-buffer 160 0 fill
	s" <br>" file-buffer swap cmove		 \ Load a webpage line feed into buffer
	msg16 zcount file-buffer zcount + swap cmove \ load message to buffer
	file-buffer zcount + swap cmove     	 \ move date into buffer
	bl file-buffer zcount + c! 		 \ put a space between the date and the time
	file-buffer zcount + swap cmove     	 \ move time into buffer
	file-buffer zcount + swap cmove     	 \ move status into buffer
	0dh file-buffer zcount + c!
	0ah file-buffer zcount + c!
        file-buffer zcount htmlfile1-ptr write-file drop
	file-buffer 160 0 fill
	s" <br> AI-Mind Previous Thought - " file-buffer swap cmove
	s" <font color=#0000FF>" file-buffer zcount + swap cmove
	human-input-buffer zcount file-buffer zcount + swap cmove \ load message to bufferhtmlfile1-ptr write-file drop
	file-buffer zcount htmlfile1-ptr write-file drop  r>
    then
\
  else swap drop 				 \ no data available last line read
  then
  not
  sendbuf sendbuf-len srch-msg2b zcount \ msg2 = ' <\html>'
  search \ --- addr len ior
  if 3drop -1 else 2drop then \ marker located
until
msg18a 64 htmlfile1-ptr write-file drop
htmlfile-ptr  close-file drop
htmlfile1-ptr close-file drop

else 				\ send message to file not found
  drop sendbuf 256 0 fill
  msg17A zcount diag-message	\ load message to buffer

then 				\ end of IF on file opening
;

\ ********************************************************************************
: server-poll ( -- )
    sock sock-accept?
      if sock sock-accept
	 \ convert client address to string send to Diagnostic window
	 s" Client addr: " workfile-buffer swap cmove
	 iaddr>str 2dup workfile-buffer zcount + swap cmove
	 workfile-buffer zcount diag-message \ Display Client address
	 workfile-buffer 1024 0 fill
	 s" Client addr: " workfile-buffer swap cmove
	 workfile-buffer zcount + swap cmove \ save Client address in buffer
	 begin servaccept dup sock-closed? cr2trailing? or until
	 dup to sock1 \ save sock # for use in HTML-Disp
         s" HTTP/1.0 200 OK" stype scr
	 s" Server: Forth AI-Mind" stype scr
	 s" Connection: Close" stype scr scr
	 1 server-hits +!
         html-disp
         10 ms sock-close drop
	 13 workfile-buffer zcount + c!
	 s" Internet Connection Processed! " 2dup diag-message
	 workfile-buffer zcount + swap cmove
	 get-local-time time-buf >time" 2drop
	 time$ zcount workfile-buffer zcount + swap cmove
	 32 workfile-buffer zcount + C!
	 log-entry
      then
;
\ ********************************************************************************
: server ( -- ) ( Updated 070613 )
		get-local-time time-buf >date"
		time-buf >time" 4drop 			\ date$ - time$
		s" server.com" host>iaddr 		\ get my ip address
		inet_ntoa ip-addr-space swap cmove	\ convert addr to string save to local string
                server-init
;
\
\ ********************************************************************************
\ Client - Side Surfing the net.
\
: sdump ( sock -- )
  begin
    dup sock-read? if dup recdvbuf 256 rot sock-read recdvbuf swap type then
    dup sock-closed? key? or until
  sock-close drop
;
\
\ ********************************************************************************
\
: SendMail-Test  ( Addr n -- Addr n F ) \ Created By FJRusso 080101
\
\ This sends out an email via a web site cgi.  '/cgi-bin/AI-SMTP.cgi'
\ Direct access to my SMTP is not possible using port 25.
\
inet-check
if
      sendbuf zcount erase
      recdvbuf zcount erase
      
ai-ftp ftpserver zcount 80 sock-open not
      if
        to sock
        s" GET http://" sendbuf swap cmove
        ai-ftp ftpserver zcount sendbuf zcount + swap cmove
        s" /cgi-bin/AI-SMTP.cgi" sendbuf zcount + swap cmove
        s" ?recipient=" sendbuf zcount + swap cmove
	sendbuf zcount + swap cmove ( 'name@Yahoo.com' is on the stack as addr, len)
\        s" &Cc=Copyname@Lycos.com" sendbuf zcount + swap cmove
\	 s" &Bcc=BlindCopyName@aol.com" sendbuf zcount + swap cmove
	s" &Bcc=FJRusso@yahoo.com" sendbuf zcount + swap cmove
        s" &subject=AI-Mind" sendbuf zcount + swap cmove
        msg18 zcount sendbuf zcount + swap cmove
        sendbuf zcount sock sock-write drop
        crlf$ count sock sock-write drop
        sock sdump
        s" Connection: close" sock sock-write drop
        crlf$ count sock sock-write drop
        crlf$ count sock sock-write drop
        sendbuf zcount erase
        recdvbuf zcount erase
        -1
      else 0
      then
else 2drop 0
then
;
\
\ ********************************************************************************
\
: Client-Test ( addr len -- F ) \ FJR Updated 071103
inet-check
if
   ai-ftp ftpserver zcount 80 sock-open not
   if
     to sock
     sendbuf zcount erase
     s" GET http://" sendbuf swap cmove
     sendbuf zcount + swap cmove
     sendbuf zcount sock sock-write drop
     crlf$ count sock sock-write drop
     sock sdump
     s" Connection: close" sock sock-write drop
     crlf$ count sock sock-write drop
     crlf$ count sock sock-write drop
     sendbuf zcount erase
     -1
   else 0
   then
else 0
then
;
\
\ ********************************************************************************
\
: FTP<-Server \ Download from server a file - Functioning 070217
\
\ All required info is in the data structure ftpservice
\
\ Set local directory
dir-path 1024 0 fill current-dir$ 	\ get currect path
zcount dir-path swap cmove	  	\ and save
ftpservice ldir zcount
null = not
if $current-dir! 			\ Set new path
else drop
then

FTP-Get-File
\
dir-path $current-dir! drop \ Restore path
;
\
\ ********************************************************************************
\
: FTP->Server \ Updated 070217
\
\ All required info is in the data structure ftpservice
\
\ Set local directory
dir-path 1024 0 fill current-dir$ 	\ get currect path
zcount dir-path swap cmove	  	\ and save
ftpservice ldir zcount
0= not
if $current-dir! 			\ Set new path
else drop
then

\ Uses the ftpservice data structure

FTP-Put-File
\
dir-path $current-dir! drop \ Restore path
;
\
\ ********************************************************************************
\
