anew AI-email       \ FJR 070531
\ Vs 1.1 A

WinLibrary WININET.DLL
\
\ **************************************************************************************
\
create pop3-server$ 32 allot pop3-server$ 32 0 fill
s" mail.com" pop3-server$ swap cmove
create smtp-server$ 32 allot smtp-server$ 32 0 fill
s" mail.com" smtp-server$ swap cmove
create tmp$ 250 allot tmp$ 250 0 fill
maxstring create msg-id$ allot msg-id$ maxstring 0 fill
create header-file$ 32 allot header-file$ 32 0 fill
create file$ 32 allot file$ 32 0 fill
create eot-octet   0xd c, 0xa c, 0x2e c, 0xd c, 0xa c,
create end-of-body ascii * c, 0xd c, 0xa c, 0xd c, 0xa c,
CREATE $JJJJMMDD 10 ALLOT $JJJJMMDD 10 0 FILL
\ create encpw$ 32 allot encpw$ 32 0 fill
create user$ 32 allot user$ 32 0 fill
create pw$ 32 allot pw$ 32 0 fill
s" aimind-i@aimind-i.com" user$ swap cmove
s" f�Z86EA" pw$ swap cmove
\
true value mDele-
0 value msgtree-base
0 value &account
0 value &outbox
0 value &last-cluster
0 value &msg-viewing
0 value record-size
0 value buffer
0 value #free-list
0 value prev-free-record
0 value first-free-record
0 value pop3-socket
0 value smtp-socket
110 value pop3-port
110 value smtp-port
0 value #new-mail
0 value last-selected-rec
30 value #days-to-keep-msg
0 value receive-buffer
0 value new-msg-buffer
0 VALUE records-pointer
0 VALUE aptrs  \ an array of cells containing pointers to record
0 value fid
0 value inet-stat
\
35 constant /date
22 constant /msg-ID
72 constant /line
200 constant deleted-cluster-
201 dup constant adresbook- constant cluster-
202 constant msg-list-
204 constant msg-grp-
206 constant account-
210 constant spam-
1 constant outbox
0 constant spambox
5 constant /end-of-body
5 constant len-last-octet
13 constant carret
10 constant lf
\ **************************************************************************************
\
\ needs toolset.f  	\ My toolset which prevents me from re-event the wheel again.
\ needs profiler.f 	\ For measuring small elapsed times.
 needs struct.f   	\ C-like structures, database definitions and memory structures
\ needs shell_R.f  	\ Thanks to a discussion on comp.lang.forth and Leo Wong
 needs w_search.f 	\ Searching/extracting strings with wildcards
 needs sockets.f
\
\ **************************************************************************************
\
struct{ \ msg-header
               /line Field:  msg-To
                   1 Field:  cnt-To

                    4 Field:  msg-subject-flag \ Re: Fw:
offset acc-cluster-name
                /line Field:  msg-Subject
offset acc-cnt-cluster-name
                    1 Field:  cnt-Subject \ including msg-subject-flag when > 0
offset  msg-flag
              /msg-ID Field:  record-ID \ The first byte = msg-flag. ASCII means it is a msg
offset acc-name
                /line Field:  msg-From
offset acc-cnt-name
                    1 Field:  cnt-From
offset next-group                        \ rel pointer to the next cluster
                /date Field:  msg-Date
                    1 Field:  cnt-Date
                    1 Field:  msg-imported
offset acc-password
                /line Field:  msg-Reply-To
offset acc-cnt-password
                    1 Field:  cnt-Reply-To
                    1 Field:  msg-Status        \ 0=read 1=to-send
offset &h-cluster                         \ In clusters
              1 cells Field:  &R-cluster  \ rel pointer to cluster in message
offset grp-last-read
              1 cells Field:  next-Outbox
offset msg-protocol   \ When msg is in the outbox 0=msg
              1 cells Field:  msg-reserved2
              /msg-ID Field:  Reply-on-ID \ Ref to a previous msg
}struct msg-header

struct{
  maxstring field: tmp-to
  maxstring field: tmp-subj
  maxstring field: tmp-msg-
  maxstring field: tmp-msg-id
}struct  tmp-buffer

\
\ **************************************************************************************
\
 s" RE: " tmp$ place tmp$ 1+ @ constant repl$_   \ Only valid for 32bits Forth
 s" Fw: " tmp$ place tmp$ 1+ @ constant fw$_     \ Only valid for 32bits Forth
: n>aptr   ( n -- a )   S" aptrs +cells                 " EVALUATE ; IMMEDIATE
: r>record ( n -- a )   S" records-pointer ( CHARS) +   " EVALUATE ; IMMEDIATE
: record>r ( a -- n )   S" records-pointer ( CHARS) -   " EVALUATE ; IMMEDIATE
: n>record ( n -- a )   S" n>aptr @ r>record            " EVALUATE ; IMMEDIATE
: get-pop3-server  ( - IP ior ) pop3-server$  1+ zGetHostIP ;
: get-smtp-server  ( - IP ior ) smtp-server$  1+ zGetHostIP ;
: init-pop3  ( - s )   pop3-server$ zcount pop3-port client-open   ;
: init-smtp  ( - s )   smtp-server$ zcount smtp-port client-open ;
: .send    ( adr u - adr u )  cr ." > " 2dup type ;
: "wP ( adr u - ) .send pop3-socket WriteSocketLine abort" Can't write to the pop3-server."  ;
: "wS ( adr u - ) .send smtp-socket WriteSocketLine abort" Can't write to the smtp-server."  ;
: "tS ( adr u - ) .send smtp-socket WriteSocket abort" Can't write to the smtp-server."      ;
: init-receive-buffer   ( - ) max-dyn-string malloc to receive-buffer ;
: init-new-msg-buffer   ( - ) max-dyn-string malloc to new-msg-buffer ;
: 0term ( $ count - ) + 0 swap c!  ;
: 0terminated ( adr-counted-string - ) dup c@ 1+ 0term ;
\
\ init-receive-buffer  initialization-chain chain-add init-receive-buffer
\ init-new-msg-buffer  initialization-chain chain-add init-new-msg-buffer
\
: read-pop3-socket ( buffer n - n f )    pop3-socket ReadSocket  ;
: read-smtp-socket ( buffer n - n f )    smtp-socket ReadSocket  ;
: _rP ( adr size - u )  read-pop3-socket abort" pop3-server did not respond." ;
: rP  ( adr - adr u )   dup max-dyn-string _rP ;
: rS   ( adr - adr u )  dup maxstring read-smtp-socket abort" smtp-server did not respond."  ;
: open-line ( adr size - adr2 /line )
   2dup  s" *" tmp$ place crlf$ count tmp$ +place tmp$ count
   2swap false w-search
      if   drop nip over - 2 +
      else 2drop over + nip 0
      then
 ;

: -eol ( n - n1 )  2 - 0 max  ;
: rtype ( adr count - ) open-line -eol  type cr ;
: rPt  ( - )   cr receive-buffer rP rtype ; \ receive from Pop3-server and type
: rSt  ( - )   cr here rS rtype ;           \ receive from Smtp-server and type
: "wSr  ( adr u - )      "wS rSt ;
: "wPr  ( adr u - )      "wP rPt ;
: +space>$ ( adr - )  s"  " rot +place  ;
: n>tmp$   ( n - )    0 (d.) tmp$ place ;
: n>+tmp$  ( n - )    0 (d.) +place tmp$ +space>$ ;
: acc-spam$      ( rec-adr - spam$ )   [ 0 acc-password 34 + ] literal + ;
: acc-cluster-*  ( rec-adr - spam$ )   [ 0 acc-cluster-name 1 - ] literal + ;
: ##d ( #zeros d - )    rot 0 ?do  #  loop  ;
: 0.$ ( n pos - adr n ) swap s>d <# ##d #>  ;
: +msg-id$ ( n pos - )  0.$  msg-id$ +place ;
: today         ( - day month year )
  get-local-time time-buf dup 6 + w@ over 2 + w@ rot w@ ;
: jjjjmmdd   ( day month year  - adr ) \ July 6th, 2002 - 17:48 stack corrected
    4 swap s>d <# ##d #> $jjjjmmdd  place
    2 swap s>d <# ##d #> $jjjjmmdd +place
    2 swap s>d <# ##d #> $jjjjmmdd +place
    $jjjjmmdd
 ;
: gen-msg-id ( n - )
   today jjjjmmdd count msg-id$ place
   time-buf dup>r 8 + w@ 2  +msg-id$
     r@ 10 + w@ 2  +msg-id$
     r@ 12 + w@ 2  +msg-id$
     r> 14 + w@ 4  +msg-id$
     0XFFFF and   4  +msg-id$
 ;
: unfold ( adr n ascii1 ascii2 - >adr len flag )
   2over rot scan 2>r scan
     if   1+ 2r>
            if    over - true
            else  drop 0 false
            then
     else  2r> 2drop 1- 0 false
     then
 ;

: file-size>s (  ( fileid -- len )    file-size drop d>s  ;
: map-hndl>vadr ( m_hndl - vadr ) >hfileAddress @ ;

\ : >last-record ( database_hdr_hndl record-size - vadr )
\    >r dup map-hndl>vadr swap >hfileLength @ r> - +
\ ;

: >carret$ ( from count - adr count )
   2dup carret scan 0<>
     if    nip over -
     else  drop
     then
 ;

: cont_@_?   ( adr len - >adr len )    ascii @ scan  ;

: header-missing? ( adr count - adr count )
   dup 0=
       if    2drop s" -- Missing --"
       then
 ;

: -string  ( adr1 cnt1 adr2 cnt2 - adr1+cnt2 cnt1-cnt2 )
  dup>r + swap r> - rot drop
 ;

: *>buffer ( - )   s" *" buffer place  ;
: *new-line>buffer ( - )   s" *" buffer place   eot-octet 2 buffer +place ;
: get-msg-field  ( hdr len adr-spec len - hdr /hdr adr-after len )
   buffer +place buffer count
   2over false w-search
      if 2over 2swap -string >carret$
      else 2drop over false
      then
   /line min
 ;

: get-header-from-new-line ( hdr len adr-spec len - hdr /hdr adr-after len )
   *new-line>buffer get-msg-field
 ;

: get-from-field ( hdr len - hdr len adr-after len )
   s" From: " *>buffer get-msg-field header-missing?
 ;

: get-Subject-field ( hdr len - hdr len adr-after len )
   s" Subject: " get-header-from-new-line header-missing?
 ;

: get-to-field ( hdr len - hdr len adr-after len )
   s" To: " get-header-from-new-line
 ;

: get-cc-field ( hdr len - hdr len adr-after len )
   s" Cc: " get-header-from-new-line
 ;

: get-bcc-field ( hdr len - hdr len adr-after len )
   s" Bcc: " get-header-from-new-line
;

: get-date-field ( hdr len - hdr len adr-after len )
   s" Date: " get-header-from-new-line header-missing?
 ;

: get-replyto-field ( hdr len - hdr len adr-after len )
   s" Reply-To: " get-header-from-new-line
 ;

: extract-email-adres ( adr len - email-adr len flag )
   2dup ascii < ascii > unfold
     if    2swap
     then
   2drop 2dup cont_@_? nip 0> swap /line min swap
 ;

: write-msg-field ( adr len field-adr cnt-adr  - )
   >r swap dup>r cmove 2r> swap c!
 ;

: cluster-mail  ( to cnt  rec-msg - spam-in-msg- ) \ 0 = cluster found
   0 locals| spam-in-msg- |
          swap 1 max swap -rot &last-cluster r>record
                begin
                    dup>r  msg-flag c@ account- =
                         if   r@ acc-spam$ count
                         else r@ acc-cluster-* r@ acc-cnt-cluster-name c@ 1+
                         then
                         2over
                    false w-search nip nip
                       if    r@ record>r 3 pick &R-cluster ! r>drop false
                             dup to spam-in-msg-
                       else  r> next-group @ dup r>record
                             swap 0<> and
                       then
                dup 0=
                until
            4drop  spam-in-msg-
 ;

: strip-Re ( adr1 cnt1 rec-adr - )
   >r  ."    Subject: " 2dup type
   /line min over @  sp@ 4 upper repl$_ =
      if    r@ msg-subject-flag  s" Re: " 4 pick swap cmove
      else  r@ msg-Subject   0 r@ msg-subject-flag c!
      then
   r> cnt-Subject write-msg-field
 ;

map-handle out-hndl
map-handle msg-hndl
map-handle hdr-hndl
map-handle hdr-idx-hndl
map-handle database-hdr-hndl
: message?      ( rec-adr - flag )   msg-flag c@ deleted-cluster- <  ;
: header-count ( - hdr-adr count ) hdr-hndl dup map-hndl>vadr swap >hfileLength @ ;
: type-space    ( adr cnt -  )   type space  ;
: type-cr       ( adr cnt -  )   type cr  ;
: include-subject-flag    ( adr - adr-incl-Re )
   msg-subject-flag dup c@ 0= if  4 +  then ;
: _list-header ( rec-adr - )
   dup>r message?
     if  cr r@ .
         r@ record-ID     /msg-ID                       type-space
         r@ msg-To        r@ cnt-To c@       ." To: "   type-cr tab
         r@ include-subject-flag  r@ cnt-Subject c@  ." Subj: " type-cr tab
         r@ msg-From      r@ cnt-From c@     ." From: " type-space
         r@ msg-Date      r@ cnt-Date c@                type-cr tab
         r@ msg-Reply-To  r@ cnt-Reply-To c@ ." Reply to: "   type
         r> ."  ->" &R-cluster ?
     else r>drop
     then

 ;

create r-end$ 10 allot r-end$ 10 0 fill s" *" r-end$ place
eot-octet len-last-octet r-end$ +place

: r-end?   ( buffer n -  buffer n flag )
     2dup 1- tuck + swap lf -scan  5 <
             if    TRUE
             else  dup 4 - len-last-octet
                   eot-octet len-last-octet compare
                     if    drop false
                     else  nip over - 1+ true
                     then
             then
 ;

: retr-msg-fragments   ( buffer size - adr cnt )
   -dup -dup 0 locals| cnt max-size |
       begin   max-size _rP  r-end?
               not over +to cnt over negate +to max-size
       while   + dup
       repeat
    2drop cnt
 ;

: scan-for-body ( buffer count - body )
   end-of-body /end-of-body 2swap false w-search not abort" No header received." +
 ;

\ Notes:
\ 1. My may ISP generate 2 different headers for the same when asked 2 times !
\ 2. Some fields belong to the header, not to the body.
\ 3. Sometimes he loves to add a number of zero's after sending an email.

: retr ( n total-size hdr-size - ) \ n and size are retrieved from maillist.tmp
   drop locals|  total-size   |
   total-size maxstring + to total-size
   s" retr " tmp$ place  n>+tmp$ tmp$ count "wP
   total-size malloc dup>r  total-size retr-msg-fragments to total-size
   msg-id$ count pad place s" .bdy"  pad +place pad +null
   pad count r/w create-file abort" Can't create file for message."  >r
   dup total-size scan-for-body tuck swap - total-size swap -
   r@ write-file abort" Can't write to messsage."
   r> close-file drop
   r> release
;

: dele    ( n - )        s" DELE " tmp$ place n>+tmp$ tmp$ count "wPr ;
: +ok?    ( adr len - )  s" +OK*" 2swap false w-search nip nip  ;
: rP-ok?  ( - )          receive-buffer rP +ok? ;
: rS-ok?  ( - )          pad rS +ok? ;

: transaction-state? ( - flag )     s" NOOP" "wP  rP-ok? ;

: (msg-header-name ( adr count - name$ )
    header-file$ place s" .hdr" header-file$ +place header-file$
  ;
: msg-header-name ( - name$ )  msg-id$ count (msg-header-name  ;
: file-name$ ( extension count - file$ )    msg-id$ count file$ place file$ +place file$ +null file$ ;
: cut-line ( adr - next-line /buffer )   dup>r open-line  tuck + r> rot -  ;
: wP-ok?  ( - )    "wP  receive-buffer 5 _rP drop  ;

\ The header goes 2 times over the line.
\ 1. To get the size and to look for spam.
\ 2. To get the mail.
\ The idea is to be able to delete spam before downloading the whole message.

: get-header ( n - size-header )
    true 0 locals| size first-line- |
    msg-header-name count r/w create-file abort" Can't create message file." >r
    s" top " tmp$ place n>+tmp$ 0 n>+tmp$ tmp$ count wP-ok?

      begin   receive-buffer off receive-buffer rP r-end?  not  \ first-line- and
      while   first-line-   \ skip first line in mail.tmp
                 if    dup>r open-line  tuck + r> rot - false to first-line-
                 else
                 then
              dup +to size r@ write-file abort" Can't save header."
      repeat
   len-last-octet -
   dup +to size r@ write-file drop
   r> close-file drop size
 ;

: get-mail ( - #new-mail )
    0  s" maillist.tmp" r/w open-file drop >r  \ min 1 file-length
        begin  buffer maxstring r@ read-line drop
        while  buffer over bl scan >r 1+ r@ 1- number? 2drop
               buffer rot r> - number? 2drop
               swap  over 0> over 0> and
                        if    over gen-msg-id over get-header
                              1+ mDele- @
                                if    dup dele    \ Delete when mDele- is true
                                then
                              database-hdr-hndl close-map-file
                              hdr-hndl close-map-file 2drop
                        else  2drop
                        then
        repeat
   r> close-file 2drop
 ;

: mail-list ( - )
   s" LIST"  "wP \ check +OK
   s" maillist.tmp" r/w create-file abort" Can't create message file." >r
      begin   receive-buffer off receive-buffer rP r-end? not
      while   r@ write-file abort" Can't save message listing."
      repeat
   r@ write-file
   r> close-file 2drop
 ;
: activate-bit ( bit# - n+bit )        1 swap lshift ;

: bit@         ( n bit# - bit )         activate-bit and ;
' bit@ alias bit-active?
: test-bit     ( n bit# - true/false )  bit@ 0<>  ;

: bit!  ( n 1/0 bit# - n-bit! )      \ puts a bit ( 1/0 ) in n
   dup activate-bit rot
       if   rot or nip               \ 1 ( 1 1-bit# - 1-bit )
       else drop over swap bit@ dup
            if   -                   \ 3 ( 0 1-bit# - 0-bit )
            else drop                \ 2 ( 0 0-bit# - 0-bit )
            then
       then
 ;
: encryption-key ( - adr count  )    s" 4ePost"  ;

: encrypt/decrypt$ ( orginal$|encrypted$ count - encrypted$|orginal$ count )
   encryption-key 2 pick  0 locals| key-char cnt max-key |
   -rot 0
       do   i  max-key /mod drop 2 pick  + c@ to key-char  \ key-char
            dup i + c@                                   \ char to encript/decript
            dup i 1+ key-char + 8 /mod drop tuck test-bit not swap bit! \ encript/decript
            i tmp$ + c!                                  \ store it
       loop
    2drop tmp$ cnt
   ;


: pass  ( - )
   s" PASS " .send pop3-socket  WriteSocket drop
   &account r>record dup acc-password  swap acc-cnt-password c@
   encrypt/decrypt$  pop3-socket WriteSocketLine drop
 ;
: merge$  ( adr2 count2 adr1 count1 - pad count1+2 ) pad place pad +place pad count ;
: pop3-user  ( - )
  &account r>record acc-cluster-name /line 2dup cont_@_? nip -
  s" USER "  merge$ "wP rPt rPt  ;

: mail-authorize ( - )
   s" HELLO"      "wP rPt
   pop3-user
   pass
   rP-ok? not abort" Invalid password or account."
 ;

: mail-transactions ( - )
   transaction-state?
     if     mail-list  get-mail +to #new-mail
     else   true abort" Transaction state error"
     then
    s" QUIT"  "wP rPt
   cr ." End mail"
  ;

: +date$+sp ( - ) date$ +place date$ +space>$ ;

\ Wed, 24 Jun 2002 19:15:09 +0200
: gmt-days  ( day - adr cnt )
        case
           0 of s" Sun" endof
           1 of s" Mon" endof
           2 of s" Tue" endof
           3 of s" Wed" endof
           4 of s" Thu" endof
           5 of s" Fri" endof
           6 of s" Sat" endof
                abort" A bad day."
        endcase
 ;

: gmt-months  ( month - adr cnt )
        case
           1 of s" Jan" endof
           2 of s" Feb" endof
           3 of s" Mar" endof
           4 of s" Apr" endof
           5 of s" May" endof
           6 of s" Jun" endof
           7 of s" Jul" endof
           8 of s" Aug" endof
           9 of s" Sep" endof
          10 of s" Oct" endof
          11 of s" Nov" endof
          12 of s" Dec" endof
                abort" A bad month."
        endcase
 ;

create gmt-zone$ 10 allot gmt-zone$ 10 0 fill
s" +0200+" gmt-zone$ place

: >gmt" ( time_structure -- )
                dup  4 + w@ gmt-days  date$  place s" , " date$ +place
                dup  6 + w@ 0 (d.)      +date$+sp
                dup  2 + w@ gmt-months  +date$+sp
                dup w@     0 (d.)    +date$+sp
                dup  8 + w@ 0 (d.)    date$ +place s" :" date$ +place \ hours
                dup 10 + w@ 2 .#"     date$ +place s" :" date$ +place \ minutes
                    12 + w@ 2 .#"    +date$+sp                        \ seconds
                gmt-zone$ count       date$ +place
                date$ count ;

: .gmt ( -- ) get-local-time time-buf >gmt" type ;

: start-smtp    ( - )          s" HELO  4th"   "wSr  ( 100 MS) ;   \ 220

: merge-rcpt"   ( adr count - pad count ) s" RCPT TO: " merge$ ;
\ : nntp-rcpt     ( adr count - ) merge-rcpt" "wN ;
: smtp-rcpt     ( adr count - ) merge-rcpt" "wSr ;  \ 250

: gmt-date"     ( - pad count ) get-local-time time-buf >gmt" s" Date: " merge$ ;
: smtp-date     ( - )           gmt-date"  "wS ;
\ : nntp-date     ( - )           gmt-date"  "wN ;

: data"         ( - adr count )    s" DATA " ;
: smtp-data     ( adr count - )    data" "wSr ;      \ 250
\ : nntp-data     ( adr count - )    data" "wN ;


: 4ePost-footer" ( adr count - tmp$ count ) ( f: time - )
\   r/w open-file abort" Can't find file for statistics."
\   dup file-size>s swap close-file drop
   2drop 0 tmp$ !
   s" =="  tmp$ +place crlf$ count tmp$ +place
   s" 4ePost: " tmp$ +place s>d (UD,.) tmp$ +place
   s"  bytes in mail. Elapsed time to buffer: " tmp$ +place
\   pad fvalue-to-string pad count tmp$ +place
   s"  sec." tmp$ +place
   tmp$ count
 ;

: eot-octed"    ( - adr count )  eot-octet 2 + 3 ;
: smtp-end-msg  ( - )            ( eot-octed") s" ." "wSr ; \ 354
\ : nntp-end-msg  ( - adr count )  eot-octed" "wNr_ ;

: x-mailer"     ( - adr count ) s" X-Mailer: 4ePost V1.10 compiled with Win32Forth" ;
: smtp-x-mailer ( - )           x-mailer" "wS ;
\ : nntp-x-mailer ( - )           x-mailer" "wN ;

: get-subject$  ( rec-adr - pad count )
    dup msg-Subject swap cnt-Subject c@ s" Subject: " merge$ \ cr 2dup dump
 ;

: smtp-subject    ( rec-adr - )    get-subject$ "wS  ;
\ : nntp-subject    ( rec-adr - )    get-subject$ "wN  ;

: *search-header ( adr count - adr count flag )   header-count false *search  ;

: add-additional-lines (  adr count-incl-EOL  adr-file /size - adr count-tot-field )
   3 pick 0 locals| /size-left &start  |
   >r 2 pick swap - r> swap - over - to /size-left
   begin  2dup + c@ bl = /size-left 0> and
   while  + dup s"   " rot -eol swap   cmove /size-left open-line
          dup negate +to /size-left
   repeat
   + &start - &start swap
 ;

: open-header-line ( adr1 - adr-msg-id count-id )
    dup header-count >r - r> swap - open-line
 ;

: get-reply-on-name  ( rec-adr - adr count )
   Reply-on-ID /msg-ID (msg-header-name count ;

\ : reply-on-header-exist? ( rec-adr - flag )   get-reply-on-name file-exist?  ;
: fold ( adr n ascii1 ascii2 - pad len )
   >r pad c! tuck pad 1+ swap move pad over 1+ + r> swap c! 2 + pad swap
;
: get-from$ ( - adr count )
   tmp$ off  &account r>record  dup>r
  (( acc-name r@ acc-cnt-name c@  ascii "  ascii " fold
   tmp$ place  s"  " +tmp$
   r@ ))
   acc-cluster-name  r>  acc-cnt-cluster-name c@ ascii < ascii > fold tmp$ place \ +tmp$
   tmp$ count
 ;

: smtp-from       ( - )   100 ms get-from$  s" MAIL FROM: " merge$ "wSr ; \ 250
: to"        ( adr count - ) s" To: " merge$  ;
: smtp-to    ( - )           to" "wS          ;
: sender" ( - adr count ) \ Is used to fill the from field when a msg is received
   100 ms s" From: " tmp$ place
   &account r>record dup>r acc-name r@ acc-cnt-name c@  ascii "  ascii " fold tmp$ +place
   s"  " tmp$ +place
   r@  acc-cluster-name r> acc-cnt-cluster-name c@
   ascii < ascii > fold tmp$ +place  tmp$ count
 ;

: smtp-empty-line ( - ) s" " "wS ;
: smtp-sender ( - ) sender" "wS ;
: .sending ( - )  cr ." Sending the body." ;
: map-file-to-send ( count adr - vadr cnt )
   out-hndl open-map-file abort" Body of message not found."
   out-hndl map-hndl>vadr out-hndl >hfileLength @
 ;

: smtp-send-bdy ( count adr - f: time )
   map-file-to-send   .sending
   tsc_init
   smtp-socket WriteSocketLine abort" Can't write to the smtp-server."
   elapsed delta_t
 ;

: email-adres?   ( record - email-adres|news-group cnt msg-flag )
    dup dup msg-flag c@ cluster- <
    over &R-cluster c@
    last-selected-rec record>r 0= and
    abort" You can not send a message from the spambox.\nUse the addressbook or select a cluster."
       if   &R-cluster @ r>record
       then
    dup msg-flag c@ msg-grp- <=
       if   nip dup acc-cluster-name over acc-cnt-cluster-name c@ rot
            msg-flag c@ msg-grp- <>
       else drop dup msg-From over cnt-From c@ true
       then
 ;

: fold-email-adres ( adr cnt - adr2 cnt2 )
    s" *<*>" 2over false w-search
      if     2drop
      else   2drop ascii < ascii > fold
      then
 ;

: pad$_ok? ( - pad count flag )     pad +null pad count dup 2 /line between  ;
: init-dlg ( adr count - pad base ) pad place pad msgtree-base ;

: show-entry ( - )
   last-selected-rec dup message? not abort" Select a message."
   cr dup>r  ." Record adres: " .
        ." Id msg: " r@ record-ID   /msg-ID                    type-cr
        r@ msg-From      r@ cnt-From c@     ." From: "         type-cr
        r@ msg-To        r@ cnt-To c@       ." To: "           type-cr
        r@ include-subject-flag  r@ cnt-Subject c@  ." Subj: " type-cr
        r@ msg-Reply-To  r@ cnt-Reply-To c@ ." Reply to: "     type-cr
        ." Date: " r@ msg-Date      r@ cnt-Date c@             type-cr
        r> ." Cluster: " &R-cluster @ r>record
           dup acc-cluster-name swap acc-cnt-cluster-name c@   type-cr
 ;

: ask-subject ( - adr cnt )
   last-selected-rec dup msg-flag c@ cluster- <
        if    s" Re: " tmp$ place dup msg-subject-flag
               swap cnt-Subject c@ over c@ 0 >
                  if     4 -
                  then
               swap 4 + swap
              tmp$ +place tmp$ count
        else  drop s" Your subject."
        then
\    init-dlg  Start: subjectDlg 0=
       if    abort
       then
    pad$_ok?
    /line min 0=
       if    true abort" Missing subject, message aborted."
       then
 ;

\ October 19th, 2002 Jos: added: outbox-adr
: outbox-adr ( - adr-outbox )  &outbox r>record next-Outbox ;
: id>tmp$ ( rec-adr - )       record-ID /msg-ID tmp$ place ;
: msg-name>tmp$ ( rec-adr - ) id>tmp$ s" .bdy" tmp$ +place tmp$ +null ;
: hdr-name>tmp$ ( rec-adr - ) id>tmp$ s" .hdr" tmp$ +place tmp$ +null ;


: check-msg-to-send ( - )
 last-selected-rec dup>r
   decimal
   msg-name>tmp$ tmp$ count r/w open-file
   abort" Can't find the message. \nSave it first and restart 4ePost."
   dup file-size>s  swap close-file drop
   s" Message to: " receive-buffer place
   r@ msg-To        r> cnt-To c@  receive-buffer +place \ receive-buffer +null
   receive-buffer count
   s" The size is: " tmp$ place rot n>+tmp$
   s" bytes." tmp$ +place tmp$ count
\   infobox
 ;

: send-smtp-message ( rec-adr - )
   start-smtp smtp-from
   dup msg-To over cnt-To c@ 2dup
    extract-email-adres drop ascii < ascii > fold
    tmp$ place tmp$ count smtp-rcpt  \  Email adres receiver
    smtp-data  smtp-sender smtp-date   smtp-to
    dup smtp-subject
\    dup smtp-references
   smtp-x-mailer
   record-ID /msg-ID tmp$ place s" .bdy" tmp$ +place tmp$ dup +null count 2dup
   smtp-empty-line smtp-send-bdy
   4ePost-footer" "wS
   smtp-end-msg
 ;

: fold-to$ ( rec-adr - tmp$-folded count )
    dup msg-To over cnt-To c@ 2dup
    extract-email-adres drop ascii < ascii > fold
    tmp$ place tmp$ count
 ;

: .Message-error   ( rec-adr - )
    beep cr cr ." ERROR: At message to: "
    dup msg-To swap cnt-To c@ type
    cr ." The text of a message is missing. Message NOT SEND." cr
 ;



: send-smtp-messages  ( - )
   outbox-adr @ dup 0= if drop exit then
   r>record
      begin   dup msg-Status @
                 if   dup msg-protocol c@ not
                          if    dup true
                                   if    send-smtp-message
                                   else  .Message-error
                                   then
                          then
                 then
              next-Outbox @
              dup r>record swap
              0=
      until
    s" QUIT"  "wSr
   drop
 ;

: write-quote ( adr count - )
   fid write-line abort" Can write to the new message"
 ;

\ July 21st, 2003 Move a ref. to the old header
: reply-on-ref-id ( &old-msg new-rec - )
    over message?
      if    swap record-ID  swap Reply-on-ID /msg-ID cmove
      else  2drop
      then
 ;

\ July 8th, 2003 Jos: Now all new messages will automatically go to the outbox.
: msg>outbox ( - )
\   prepare-message
   last-selected-rec record>r
\   extend-database
   last-selected-rec >r
   r>record r@ reply-on-ref-id
   new-msg-buffer count dup r@ cnt-To c!  r@ msg-To swap cmove
   new-msg-buffer maxstring + count dup r@ cnt-Subject c! r@ msg-Subject swap cmove
   new-msg-buffer tmp-msg- c@ r@ msg-protocol c!
   new-msg-buffer tmp-msg-id count 4 - r@ record-ID swap cmove
   get-local-time time-buf >gmt" dup r@ cnt-Date c! r@ msg-Date swap cmove
   1 activate-bit  r@ msg-Status c!
   outbox-adr @    r@ next-Outbox !
   r@ record>r outbox-adr !
   &outbox  r> &R-cluster !
   new-msg-buffer off
  ;

: reply-to-mail ( - )
   &msg-viewing dup 0= abort" Select a message to reply to."
 ;

: create-header/bdy ( - Hndl )
    count r/w create-file abort" Can't create file."
 ;

: ask-DeleteAfter  ( - )
   #days-to-keep-msg n>tmp$ tmp$ count \ init-dlg  Start: DeleteAfterDwnDlg >r
   pad count number? \ r>
   and not abort" Messages are not deleted."
   d>s to #days-to-keep-msg
;

: init-outbox ( - )
\    outbox >record dup>r record-size 0 fill \ outbox
    msg-list- r@ msg-flag c!
    s" outbox" tuck r@ acc-cluster-name dup>r swap cmove
    r> over 0term
    r@ acc-cnt-cluster-name c!
    r@ record>r to &outbox
    spambox r> next-group !
 ;

: ask_password  ( - encrypted-password$ count )
    s"   2 till 30 numbers or letters  " \ init-dlg  Start: passwordDlg
    dup>r here !
    pad$_ok? 0= r> 0= or
       if   \ s" Warning Password not changed.:"
            \ s" Invalid password." \ infoBox 30 min 1 max
       then
    encrypt/decrypt$
 ;

: ask_timezone  ( - pop3-server count )
    gmt-zone$ count \ init-dlg  Start: zoneDlg
    >r
    pad$_ok? 0= r>  and
       if   2drop  \ s" Warning: Timezone not changed:"
             \ s" Invalid timezone.\nTry something like +0700"
             \ infoBox
            gmt-zone$ count
       then
       5 min gmt-zone$ place
\    z" gmt-zone"  gmt-zone$  $>4ePost-profile
 ;

: init-socket
   SocketsStartup  abort" SocketsStartup error."
   cr  ." IP: " my-ip-addr   NtoA type
   s"   Socket connection Successful!" type cr
;

: Inet-Check 		\ Try 3 times to see if an Internet connection is available
 0 to inet-stat
 3 0 do
 0 call InternetAttemptConnect    \ Attempt to make an internet connection
 0= if -1 to inet-stat leave then \ active internet connection
 500 _ms \ delay .5 seconds
 loop
\ inet-stat is checked for success on return to calling module.
;

: POP-Get
receive-buffer zcount 0 fill
	begin   receive-buffer off receive-buffer rP r-end? not
	while
	repeat
receive-buffer zcount cr type cr
;

: POP-TEST
rPt
\ s" LOGIN"  "wP rPt
tmp$ zcount 0 fill
s" USER " tmp$ swap cmove
user$ zcount tmp$ zcount + swap cmove tmp$ zcount "wp rPt
s" PASS " pop3-socket writesocket drop
pw$ zcount encrypt/decrypt$
pop3-socket writesocketline drop
rp-ok?
;

: test
sizeof msg-header to record-size \ should be < 2024 ( buffer-size)
cls
init-receive-buffer
init-new-msg-buffer
inet-check
inet-stat
if
	s" Internet connection available" type cr
	init-socket
	s" Connecting to: " type user$ zcount type cr
	init-pop3
	dup to pop3-socket
	s" Pop3 handle = " type . cr
	pop-test
	if
	  s" STAT" "wP rPt
	  s" LIST" "wP POP-Get
	  s" RETR 6" "wP POP-Get
	  transaction-state? cr
	  s" QUIT" "wP rPt
	then
	pop3-socket closesocket drop
	s" Pop3 connection Closed" type cr
	init-smtp
	dup s" SMTP handle = " type . cr
	closesocket drop
	s" SMTP connection Closed" type cr
   else
	s" Internet connection NOT available" type cr
then
init-receive-buffer free
init-new-msg-buffer free
;
