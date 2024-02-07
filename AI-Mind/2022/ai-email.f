anew aiEmail       \ FJR 230513
\ Vs 1.3 A
\
\ **************************************************************************************
\
create AI s" SUBJECT: AI" dup allot ai swap cmove
create procs-table 128 allot procs-table 128 0 fill
0 value eot
0 value email-stat
0 value email-buffer
0 value email-buf-ptr
0 value emailfile-ptr
0 value emailfile-len
0 value email-addr-hash
0 value efile-lines
0 value e-string
0 value hash-table
0 value pop3-Avail
0 value smtp-avail
\
include 4email-interface.f
\
\ **************************************************************************************
\
: email-file-open
	s" email-file.log" r/w open-file \ open life file
	if \ error occured file not located
	 drop
	 s" email-file.log" r/w create-file \ Create log file drop
	 drop to emailfile-ptr
	else
	 to emailfile-ptr
	 emailfile-ptr file-size drop + to emailfile-len
	 emailfile-len 1024 / 2 + 1024 * dup malloc to e-string \ allocate buffer for file read / write
         e-string swap 0 fill
	 tempspace 16 0 fill
	 \ count # of lines in file
         0 to efile-lines

	begin
	  1 +to efile-lines
	  e-string 80 emailfile-ptr read-line
	  xor not nip
	until

	0 0 emailfile-ptr REPOSITION-FILE drop
	efile-lines 4 * 4 + dup malloc to hash-table
	hash-table swap 0 fill
	efile-lines 2 / dup to efile-lines 0

	do
	  tempspace 16 emailfile-ptr read-line 2drop
	  \ convert string to number save to hash-table
	  tempspace swap (number?) 2drop i 4 * hash-table + !
	  tempspace 16 0 fill
	  e-string 80 emailfile-ptr read-line 3drop
	loop

	e-string zcount 0 fill
\ REPOSITION-FILE( ud fileid -- ior ) go to start of file
	emailfile-len 0 emailfile-ptr REPOSITION-FILE drop
	then

tempspace zcount 0 fill \ empty out the space
\ s" Display Hash Table Values" cr type cr
\ efile-lines 0 do i 4 * hash-table + @ . cr loop cr
;
\
\ **************************************************************************************
\
: EMProc1 ( Addr Len -- F )
    s" FROM: " search
    if
      over swap crlf$ count search
    else
      2drop 0
    then
;
\
\ **************************************************************************************
\
: ai-process ( Adr Count - ) \ Updated 080109 FJRusso

0 to eot
2dup upper \ convert entire buffer to upper case for searcing
2dup EMProc1 2drop
swap 6 + swap over -
2dup over + 1+ swap
 do	\ Replace bl in address with '+'
   i c@ bl =
   if 43 i c! then
 loop

2dup sendmail-test
\ display-buffer zcount erase
 if
   s" E-Mail Sent to " display-buffer swap cmove
   display-buffer zcount + swap cmove
 else
   2drop s" E-Mail Send FAILED" display-buffer swap cmove
 then
 display-buffer zcount
 2dup diagnostic-window >logfile
 display-buffer zcount erase

2dup s" < EOT >" search
if drop 1- to eot else 2drop 2dup + to eot then

begin
   s" AI: " search

   if
     over eot <

     if
       swap 4 + swap
       2dup crlf$ count search 2drop
       2 pick - 1+ 2 pick swap
       email-buffer zcount + swap cmove 0
     else -1
     then

   else -1
   then

until
2drop
;
\
\ **************************************************************************************
\
: email-addr-process ( addr n -- )
\
2dup
-1 "#hash to email-addr-hash \ convert input to hash value
\ look up value in Hash Table
efile-lines 0
do
  i 4 * hash-table + @ email-addr-hash =
  if 0 to email-addr-hash leave then
loop
\
email-addr-hash
if \ value not 0 then need to save
   email-addr-hash tempspace >string
   tempspace count emailfile-ptr write-line drop \ count e-string swap cmove
   \ crlf$ count e-string zcount + swap cmove
   swap 6 + swap 6 -
   emailfile-ptr write-line drop
else 2drop
then
;
\
\ **************************************************************************************
\
: AI-email ( Updated 070725)

\ timer1 -if 0 KillTimer drop false to timer1flag 0 to timer1 else drop then
s" Connecting ----- " diagnostic-window
init-connection	\ Initializes connections returns a flag if successful MUST be called first
dup to email-stat

If \ Successful internet connection
0 3 0 do \ try 3 times to make a connection
   drop
   ai-ftp email-password zcount
   ai-ftp email-user zcount
   ai-ftp pop3-addr zcount
   init-inmail
   dup if leave then \ successful login
   250 _ms
loop

 if \ Successful log onto host
  s" Login Successful " diagnostic-window
  display-buffer zcount 0 fill
  Get-mail-stats ( - N N ) \ Returns the # of messages and the total size on the stack
  2dup \ save to evaluate later
  swap tempspace >string
  S" Number of messages on server = " display-buffer swap cmove
  tempspace count display-buffer zcount + swap cmove
  S"      Size = " display-buffer zcount + swap cmove
  tempspace >string tempspace count display-buffer zcount + swap cmove
  display-buffer zcount
  2dup diagnostic-window >logfile
  drop

if \ any messages available continue processing

  Get-Mail-List  ( -  Adr N ) 2drop

\ Get a listing of msgs  ‘ msg# Subj From size’
  Get-msg-headers ( -  Addr N ) 2dup upper \ Allow for any case input
\
  email-file-open \ open email address log file & process the senders (From:)
  over swap

  begin
   emproc1 ( header-buffer len -- addr len F )
   -if
    drop 2dup 2>r drop over -
    email-addr-process 2r>
   then
   dup 0=
  until
  drop

\ Processing Headers
 procs-table 128 0 fill
 #recs 1+ 1

 do
  dup 41 ai zcount search nip nip

  if
   i procs-table zcount + c!
  then

  128 crlf$ count search 2drop 2 +

 loop

 drop

 display-buffer zcount 0 fill
 procs-table zcount s" # E-Mail messages for the AI = " display-buffer swap cmove
 tempspace >string tempspace count display-buffer zcount + swap cmove
 display-buffer zcount
 2dup diagnostic-window >logfile
 display-buffer zcount 0 fill
 procs-table dup zcount + swap
\
\ allocate memory for retrieved message bodies.
\
 email-buffer \ Does buffer exist >0
 if
   email-buf-ptr zcount email-buffer swap cmove
   0 email-buffer email-buf-ptr zcount nip + !
   email-buffer zcount + email-buf-ptr over - 0 fill
   email-buffer to email-buf-ptr
 else 	\ buffer does not exist and need to create it
   procs-table zcount nip inbufsize * 1024 +
   dup malloc to email-buffer
   email-buffer swap 0 fill
   email-buffer to email-buf-ptr
 then

 2dup - \ checking to see if there are messages to be processed
 if

  do
   i c@ Retrieve-msg ( n - Adr Count )
   dup
     if ai-process ( Adr Count - )
        I c@ delete-msg drop  \ remove message from email in box
     else drop
     then
  loop

 else 2drop
 then

 drop

 hash-table free to hash-table
 e-string free to e-string
 emailfile-ptr close-file to emailfile-ptr \ close emailfile

then \ end of check for any mail available

Close-email

 else 0 to email-stat s" Unable to Log on to Host" 2dup diagnostic-window >logfile

 then \ End of check for login

else 0 to email-stat 0 to inet-stat s" Unable to Connect to Internet" 2dup diagnostic-window >logfile

then  		\ End of check for internet connection
0 think-delay 0 0 SetTimer to timer1 false to timer1flag \ reset Timer
email-buf-ptr 	\ return as a flag to calling routine
;
\
\ **************************************************************************************
\
: email-port-check
ai-ftp smtp-addr zcount
ai-ftp pop3-addr zcount
Email-Avail
;
\
\ **************************************************************************************
\
