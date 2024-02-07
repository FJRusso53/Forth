anew Email       \ FJR 071104
\ Vs 1.2 A
\ 4email-interface.f
\ needs c:\aimind-i\wininet.f
\ needs c:\aimind-i\sock.f
\ **************************************************************************************
\
110 value pop3-port	\ default value
25  value smtp-port	\ default value
0 value #recs		\ # of messages in the inbox
0 value pop3-socket
0 value smtp-socket
0 value receive-buffer
0 value new-msg-buffer
0 value header-buffer
0 value hd-buf-ptr
0 value Msg-Size
0 value op-param
\
create eom   0x0d c, 0x0a c, 0x2e c, 0x0d c, 0x0a c,
create eoh   0x0d c, 0x0a c, 0x0d c, 0x0a c,
create ebt s" < EOT >" dup allot ebt swap cmove
create recs$ 16 allot recs$ 16 32 fill
create n>string$ 8 allot n>string$ 8 0 fill
\
\ Create a data structure to hold as much info as is possible
\
0 nostack1
32 char+ field+ pop3-server$
32 char+ field+ smtp-server$
32 char+ field+ user$
32 char+ field+ userpw$
1024 char+ field+ tmp$
1024 char+ field+ tmp1$
constant mem-size
\
\ **************************************************************************************
\
: activate-bit ( bit# - n+bit ) 1 swap lshift ;
: bit@         ( n bit# - bit ) activate-bit and ;
: bit!  ( n 1/0 bit# - n-bit! )      \ puts a bit ( 1/0 ) in n
   dup activate-bit rot
       if   rot or nip               \ 1 ( 1 1-bit# - 1-bit )
       else drop over swap bit@ dup
            if   -                   \ 3 ( 0 1-bit# - 0-bit )
            else drop                \ 2 ( 0 0-bit# - 0-bit )
            then
       then
;
: WriteSocketLine ( adr u s - F )
  dup >r Sock-Write 0= if r> drop exit then
  crlf$ count r> sock-write 0=
;
: test-bit   ( n bit# - true/false ) bit@ 0<>  ;
: init-pop3  ( addr n - s Flag ) pop3-port sock-open ;
: init-smtp  ( addr n - s Flag ) smtp-port sock-open ;
: wPop3 ( adr u - ) pop3-socket WriteSocketLine abort" Can't write to the pop3-server."  ;
: WSmtp ( adr u - ) smtp-socket WriteSocketLine abort" Can't write to the smtp-server."  ;
: "tS   ( adr u - ) smtp-socket Sock-Write abort" Can't write to the smtp-server."      ;
: read-pop3-socket ( buffer n - n f ) pop3-socket sock-Read dup 0= ;
: read-smtp-socket ( buffer n - n f ) smtp-socket sock-read dup 0= ;
: _rP  ( adr size - u ) read-pop3-socket abort" pop3-server did not respond." ;
: rP   ( adr - adr u )  dup max-dyn-string _rP ;
: rS   ( adr - adr u )  dup maxstring read-smtp-socket abort" smtp-server did not respond."  ;
: +ok? ( adr len - )    s" +OK" search nip nip ;
: rP-ok?  ( - ) receive-buffer rP +ok? ;
: rS-ok?  ( - ) pad rS +ok? ;
: transaction-state? ( - flag ) s" NOOP" wPop3  rP-ok? ;
: encryption-key   ( - adr count  ) s" 4ePost"  ;
\
\ **************************************************************************************
\
: encrypt/decrypt$ ( orginal$|encrypted$ count - encrypted$|orginal$ count )
   encryption-key 2 pick  0 locals| key-char cnt max-key |
   -rot 0
       do   i  max-key /mod drop 2 pick  + c@ to key-char  \ key-char
            dup i + c@                                     \ char to encript/decript
            dup i 1+ key-char + 8 /mod drop tuck test-bit not swap bit! \ encript/decript
            i op-param tmp$ + c!                                    \ store it
       loop
    2drop op-param tmp$ cnt
;
: n>string ( n a -- )
\ Converts numbers to counted string for output to a file
\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
 >r dup >r abs s>d <# #s r> sign #>
 r@ char+ swap dup >r cmove r> r> c!
;
\
\ **************************************************************************************
\
: Retrieve-msg ( n - Adr Length )

 dup 1 #recs between
 op-param tmp1$ zcount 0 fill
 if
   n>string$ n>string
   S" RETR " op-param tmp1$ swap cmove
   n>string$ count op-param tmp1$ zcount + swap cmove
   begin
    100 _ms op-param tmp1$ zcount WPop3 rp-ok?
   until
   receive-buffer rp
 else drop 0
 then
;
\
\ **************************************************************************************
\
: Delete-msg ( N - Flag )

 op-param tmp$ 1024 0 fill
 dup 1 #recs between
 if
   n>string$ n>string
   S" Dele " op-param tmp$ swap cmove
   n>string$ count op-param tmp$ zcount + swap cmove
   op-param tmp$ zcount WPop3 RP-ok?
 else drop 0
 then
;
\
\ **************************************************************************************
\
: get-mail-stats ( - count size )
  receive-buffer zcount 0 fill
  begin
   100 _ms s" STAT" wpop3 rp-ok?
  until
  receive-buffer zcount
\ process line of input getting the count and total size and leave on stack e.g. '+ok 16 25345 '
   3 /string evaluate
  over to #recs \ save # of msgs available
;
\
\ **************************************************************************************
\
: Get-Mail-List (  -  )

    begin
     100 _ms s" LIST" wPop3 rp-ok?
    until
    receive-buffer rp
    \ On return from rp stack has address and size.
    op-param tmp$ zcount 0 fill
    op-param tmp$ swap cmove  \ move received data to the Tmp$
    \ process the text in tmp$ retrieving the # and size
    op-param tmp$ zcount
    \ find the size of the largest email message
	over dup zcount 3 - + swap  \ Loop from Adr till Adr + zcount
	do
	  I dup 32 crlf$ count search 2drop
	  over 2dup - evaluate \ e.g. '  1  2345 ' leaving 2 numbers on the stack Msg# and Msg-Size
	  dup Msg-size > if to msg-size else drop then drop
	  swap - 2 +
	+loop
;
\
\ **************************************************************************************
\
: Get-msg-headers  (  -  Addr Count )
\
    #recs 0= if get-mail-stats 2drop then \ this is just incase someone has not already called it
\
    header-buffer max-dyn-string 32 fill
    header-buffer to hd-buf-ptr
 #recs
 if
    #recs 1+ 1
    do
\	header-buffer zcount + dup to hd-buf-ptr 80 bl fill
	i n>string$ n>string \ convert index # to a string
	n>string$ dup c@ swap 1+ swap
	recs$ 4 + swap cmove ascii 0 recs$ 8 + c!
        begin
	 100 _ms recs$ 16 wPop3 rp-ok?
        until
        receive-buffer rp

	\ Search buffer for "Subject: " & "From: "
	2dup s" Subject: "  search

	  if 	\ append to header-buffer
	     over swap crlf$ count search 2drop
	     n>string$ count hd-buf-ptr swap cmove
	     s"  - " hd-buf-ptr 3 + swap cmove
             over - 34 min hd-buf-ptr 6 + swap cmove
	     s" From: "    search

	     if
		over swap crlf$ count search 2drop
		over - 2 + hd-buf-ptr 41 + swap cmove
		hd-buf-ptr max-dyn-string crlf$ count search 2drop 2 + to hd-buf-ptr
	     else 2drop
             then

         else 4drop
         then

    loop
    0 hd-buf-ptr c!
 then \ end of check for # of messages available
header-buffer zcount
;
\
\ **************************************************************************************
\
: Authorization ( flag userpw-addr n user-addr n - flag)  \ 080101
    receive-buffer zcount 0 fill
    op-param tmp$ zcount 0 fill
    s" USER " op-param tmp$ swap cmove op-param tmp$ zcount + swap cmove    \ ' USER account-name'
    op-param tmp$ zcount wPop3 rP-ok? op-param tmp$ zcount 0 fill

    if
      receive-buffer zcount 0 fill
      op-param tmp$ zcount 0 fill
      s" PASS " op-param tmp$ swap cmove op-param tmp$ zcount + swap cmove  \ ' PASS account-password'
      op-param tmp$ zcount wPop3 rP-ok? op-param tmp$ zcount 0 fill
      not if drop 0 then
    else drop 0
    then
;
\
\ **************************************************************************************
\
: init-inmail	( addr n addr n addr n - flag )
   op-param pop3-server$ 32 0 fill
   0 to #recs
   op-param pop3-server$ swap cmove
   op-param user$ swap cmove
   op-param userpw$ swap cmove
   op-param pop3-server$ zcount init-pop3 not \ invert the flag returned
   if
      dup to pop3-socket
      if  rP-ok? drop -1 op-param userpw$ zcount op-param user$ zcount Authorization
      else 0
      then
   else drop 0
   then
;
\
\ **************************************************************************************
\
: init-outmail	( addr n - flag )
   op-param smtp-server$ 32 0 fill
   dup op-param smtp-server$ swap cmove
   init-smtp dup to smtp-socket
   if -1 Authorization else 0 then
;
\
\ **************************************************************************************
\
: init-connection ( - flag )
 inet-check
   if
\ initialize all variables
     0 to header-buffer
     0 to new-msg-buffer
     0 to receive-buffer
     0 to op-param
     mem-size malloc to op-param
     op-param mem-size 0 fill
     max-dyn-string
     dup malloc to receive-buffer
     dup malloc to new-msg-buffer
     malloc to header-buffer
     receive-buffer max-dyn-string 0 fill
     new-msg-buffer max-dyn-string 0 fill
     header-buffer  max-dyn-string 0 fill
     recs$ 16 32 fill s" TOP" recs$ swap cmove
     0 to #recs
   then
 inet-stat
;
\
\ **************************************************************************************
\
: Close-email
  transaction-state? 	  drop 100 _ms
  s" QUIT" WPOP3 rP-ok?   drop 100 _ms
  pop3-socket sock-close  drop 100 _ms
\  smtp-socket closesocket
  header-buffer  free to header-buffer
  new-msg-buffer free to new-msg-buffer
  receive-buffer free to receive-buffer
  op-param	 free to op-param
;
\
\ **************************************************************************************
\
: Email-Avail ( addr len addr len -- ) \ Updated 071104 FJR
\ Check to see if connection to Email ports is possible
inet-check \ Internet connection available?
if
   pop3-avail not
   if \ pop3 port not in use at moment
    init-pop3
    not to pop3-avail \ save status
    sock-close drop
   else 2drop
   then
   init-smtp
   not to smtp-avail
   sock-close drop
else 4drop 0 to pop3-avail 0 to smtp-avail
then
;
\
\ *********************************************************************************
\
