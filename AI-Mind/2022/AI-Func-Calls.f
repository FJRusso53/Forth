\ AI-Func-Calls.f 210219
\ ***************************************************************************************
\ See time control words in util.f
\ ***************************************************************************************
\
anew AI-Func-Calls.f
\
: bl>buffer bl workfile-buffer zcount + C! ;
\
\ ********************************************************************************
\
: +type ( addr len -- ) \ FJR 080410
\ Types out lines > 256 characters
0 do dup i + c@ emit loop
drop
;
\
\ ********************************************************************************
\
: >RTDate \ 081213 FJR
   RTDate 64 0 fill
   get-local-time time-buf >month,day,year" RTDate swap cmove \ Load Todays Date
;
\
\ ***************************************************************************************
\
code Get-Addr ( addr1, size, row -- addr2 ) \ 30% reduction in time
		mov eax, ebx
                pop  ebx
		push edx
                imul  ebx
		pop  edx
		pop  ebx
		add eax, ebx
		push eax
		pop ebx
                next  c;
\
\ ********************************************************************************
\
: >Aud{ ( Row -- Addr )  ( 101030 FJR)
aud-size * aud{ +
;
\
\ ***************************************************************************************
\
: >En{ ( Row -- Addr )  ( 101030 FJR)
en-size * en{ +
;
\
\ ***************************************************************************************
\
: >PSI{ ( Row -- Addr )  ( 101030 FJR)
psi-size * psi{ +
;
\
\ ***************************************************************************************
\
: >hash{ ( Row -- Addr )  ( 101030 FJR)
hash-size * hash{ +
;
\
\ ***************************************************************************************
\
: hash{-sort 	\ FJR 210322
( Improved sort efficiency )
( get-addr func 30% faster than >hash{ call )
( Duplicate address on stack instead of repeated calls to get address )
\
\ Sort the Hash Table
\
tempspace 16 0 fill
hash-count 1- 1
do
  hash-count i 1+
  do
    hash{ hash-size j get-addr hashv dup dup @ \ ADj ADj Nj
    hash{ hash-size i get-addr hashv dup @ \ ADj ADj Nj ADi Ni
    rot swap ( ADj ADj ADi Nj Ni ) >
    if
      ( hash{ hash-size i get-addr) dup tempspace hash-size cmove
      ( j >hash{ i >hash{ )   hash-size cmove
      tempspace swap  (  j >hash{ ) hash-size cmove
    then
  loop

loop

tempspace 16 0 fill
0 to hash-sort
;
\
\ ********************************************************************************
\
: c[toc{   \ FJR 230509
\ Changing the STOV to c{ for all questions asked
t @ eod >
If
  t @ eod
  Do
    i >en{ neno w@ dup What = swap Who = or
    If c{ i >aud{ stov c! Then
  Loop
Then
;
\
\ ***************************************************************************************
\
: search{ ( N -- address ) 1- 4 * search-array + ;
\
\ ***************************************************************************************
\
: center-dertm \ ( count --- count offset)
\ Calculates center of display line
dup 2 / screenwidth 2 / swap -
;
\
\ ********************************************************************************
\
: Nen-Search \ ( NEN -- ARV, flag ) Find a NEN in the EN{ array Updated 230224 FJR
\
 to nen-search-value \ move off stack to search parameter
 0 \ put on stack for return flag

1 T @ 1-
DO \ Look backwards for NEN on stack.
( I >en{) en{ en-size I get-addr neno W@ nen-search-value =  \ en{ en-size I get-addr neno W@
 IF 		\ Found,
   drop 	\ lose the 0 flag
   I   		\ Recall-vector for NEN.
   -1 leave	\ Return to caller
 THEN    	\ End of search for NEN.
-1 +LOOP 	\ End of loop finding the lexical NEN item.

\ if we get here NEN not found leave 0 flag on stack
;
\
\ ********************************************************************************
\
: >string ( n a -- )
\ Converts numbers to counted string for output to a file
\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
 >r dup >r abs s>d <# #s r> sign #>
 r@ char+ swap dup >r cmove r> r> c!
;
\
\ ***************************************************************************************
\
: Min>convt
\ Convert minutes to Years / months / weeks / days / hours
\ not fully functional part of program
talive @
52560 /mod ( total minutes --> remainder  #years ) .
40320 /mod ( remainder     --> remainder2 #months ) .
10080 /mod ( remainder2    --> remainder3 #weeks ) .
1440  /mod ( remainder3    --> remainder4 #days ) .
60    /mod ( remainder4    --> #minutes   #hours ) .
\ Locate X in msg22 and replace with values
;
\
\ ***************************************************************************************
\
: strcmp \ (add1 len1 addr2 len2 --- f )
\ compares 2 strings add1 len1 addr2 len2
\ returns non zero for a match zero no match
\
\ Code not used -- Replaced with 'COMPARE'
\
(
T1 ! swap T2 ! 0 T3 !
to str2 to str1
T1 @ T2 @ = dup
IF
  drop
  t1 @ 0

 	do
	 str1 c@ str2 c@ =

	 If
	  1 +to str1
	  1 +to str2
	  1 T3 +!
         else leave
	 then

	loop

  t3 @ t2 @ =
  if -1 else 0 then

Then )
;
\
\ ***************************************************************************************
\
: maxwordsize ( 230224 FJR)
\ calc the length of the largest word 'concept' in memory
t @ 0
  do
    hash{ hash-size I get-addr wleno C@ dup max-word-len @ >
    if max-word-len ! else drop then
  loop
;
\
\ ********************************************************************************
\
: Locate-Char1 ( Addr1 C -- Addr2 )
\ Code not used -- Replaced with 'SCAN'  230509
(( over swap
to T01  \ Save Character to search for
to T02  \ Save address to start @

Begin

  T02 c@ T01  =

  if \ C located
    -1
  else
     T02 1+ to T02
     T02 T0 @ >
     if -1 else 0 then
  then

Until

T02
))
;
\
\ ********************************************************************************
\
: Locate-Char2 ( c, n1, n2 -- V ) \ 101030 FJR
\ Search from n1 to n2 looking for character in AUD{ Stov
	do
	dup i >aud{ stov C@ =  \  dup aud{ aud-size i get-addr stov C@ =
	if drop I unloop exit then
	loop
	drop 0 \ change here to return 0 if not found
;
\
\ ***************************************************************************************
\
: work-file-read
\
workfile-buffer 1024 0 fill
workfile-buffer 1024 workfile-ptr read-file 2drop
;
\
\ ***************************************************************************************
\
: work-file-write
\
workfile-buffer 1024 workfile-ptr write-file drop
workfile-buffer 1024 0 fill
;
\
\ ***************************************************************************************
\
: log-file-write (  -- ior ) \ Revised to catch if logfile is closed 210219
\
\ fyi @ 1 and  if s" Log-file-write Entered" diagnostic-window then
workfile-buffer zcount 2dup logfile-ptr dup
if write-line drop else drop 2drop endif \ WRITE-LINE to FILE
0 fill
\ fyi @ 1 and  if s" Log-file-write Exited" diagnostic-window then
;
\
\ ********************************************************************************
\
: Log-File-Close
\
\ fyi @ 1 and  if s" Log-file-close Entered" diagnostic-window then
workfile-buffer 1024 0 fill
msg3 zcount workfile-buffer swap cmove \ Log File Closed message
get-local-time time-buf >date"
workfile-buffer zcount + swap cmove
bl>buffer
time-buf >time" workfile-buffer zcount + swap cmove
13 workfile-buffer zcount + C!
s" Run Time = " workfile-buffer zcount + swap cmove
ms@ trun @ - 60000 / tempspace >string
tempspace count workfile-buffer zcount + swap cmove
s"  Minutes" workfile-buffer zcount + swap cmove
13 workfile-buffer zcount + C!
s" Max run time = " workfile-buffer zcount + swap cmove
truntime @ tempspace >string
tempspace count workfile-buffer zcount + swap cmove
s"  Minutes" workfile-buffer zcount + swap cmove
log-file-write
Msg-Seperator zcount workfile-buffer swap cmove
log-file-write
logfile-ptr close-file to logfile-ptr \ close log file
;
\
\ ********************************************************************************
\
: >LogFile ( addr N -- ) \ 070616 FJRusso
\
workfile-buffer zcount nip
0= if workfile-buffer swap cmove then
bl>buffer
get-local-time time-buf >time" 2drop
time$ zcount workfile-buffer zcount + swap cmove
bl>buffer
log-file-write
;
\
\ ***************************************************************************************
\
: Pre-Seq-find ( n, dir, nen -- n ) ( 101222 FJR)
urpsi !
to pre-pos
0 swap \ default value flag
dup 5 pre-pos * + swap 1 pre-pos * +
do
  urpsi @ i >psi{ psio w@ =  \ urpsi @ psi{ psi-size i get-addr psio w@ =
  if drop i leave then
pre-pos +loop
0 to pre-pos
0 urpsi !
;
\
\ ***************************************************************************************
\
0 value mindtest
\
: mind-test \ 101030 FJR
 cls cr
 1300 4 * malloc to mindtest
\ Find first occurance of '[' in aud{ stov - Edge of Human Input
 0 counter !
 c[ T @ eod
 locate-char2 T1 !
begin
  counter @ dup 8 / 8 * = if cr then
  1 counter +!
  en{ en-size 2dup t1 @ get-addr w@ >r
  2dup t1 @ 1+ get-addr w@ >r
  t1 @ 2 + get-addr w@ r> r>
  + +
  dup mindtest counter @ 4 * + !
  5 .r 3 spaces
  c[ T @ t1 @ 1+
  locate-char2 dup T1 !
  not
until
cr cr
." # of hits = " counter @ . cr
cr  ." Temporary Wait Press any key to continue"
Wait
cr
0 t1 !
counter @ 1- 1
do
  counter @ 1+ i 1+
  do
    mindtest j 4 * + @
    mindtest i 4 * + @
    2dup >
    if
     mindtest j 4 * + !
     mindtest i 4 * + !
    else
     2drop
    then
  loop
loop
\
counter @ 1+ 1
do
 mindtest i 4 * + @
 5 .r 3 spaces
 i dup 8 / 8 * =
 if
   cr
 then
loop
\
cr cr
cr  ." Temporary Wait - Press any key to continue"
Wait
mindtest free to mindtest
\
;
\
\ ***************************************************************************************
\
: convert-space ( addr len -- ) \ 100502
\
\ Takes a line of text and replaces ' ' with '+'
\
 0 do
 dup 1+ swap dup C@ 32 =
 if
   43 swap C!
 else drop
 then
 loop
 drop
 ;

\
\ ********************************************************************************
\
: REJUVENATE  \ Rejuvenation FJR 101113

 1 rejuvenatecycle +!

fyi @ 1 and  if s" :Rejuvenate Entered" diagnostic-window then

Mind-Dump#
\
\ Need to change External input questions from aud{STOV = c[ to c{
\ so questions will be removed from core on rejuvenation
\ find What = 54 and Who = 55
\
c[toc{
\ Find first occurance of '{' in aud{ stov - Edge of AI generated thought
 c{ T @ Vault+ @   \  Keeping the AI greeting
 locate-char2 jrt !
\
\ Find first occurance of '[' in aud{ stov - Edge of Human Input
 c[ T @ jrt @
 locate-char2 T1 !

\ Move Data
begin
 t1 @ >en{ psio w@
 if
  t1 @  >en{ jrt @ >en{  en-size  cmove
  t1 @ >psi{ jrt @ >psi{ psi-size cmove
  t1 @ >aud{ jrt @ >aud{ aud-size cmove
  jrt @ dup >en{ audo w!
  1 t1 +! 1 jrt +!
 else 1 t1 +!
 then
 t1 @ >aud{ stov c@
 if
  c[ T @ t1 @
  locate-char2
  dup 0= if drop t @ then T1 ! \ Character not located --- finished
 then
 t @ t1 @ <=
until
t @ jrt @
\
\ clear remaining memory
\
do
 i >en{   en-size erase
 i >psi{ psi-size erase
 i >aud{ aud-size erase
loop
\
jrt @ t ! \ Set T to new starting point
\ Set New TOV
t @
begin
 1- dup >aud{ stov c@ c[ =
until
tov !
\
msg13 zcount >LogFile

fyi @ 1 and  if s" :Rejuvenate Exited" diagnostic-window then

; \ End of New-Rej; return to the Security mind-module.
\
\ ********************************************************************************
\
: Mind-Consolidate ( 100703 FJR removes redundant mind concepts)
\
 mind-dump#
\
\ Find first occurance of '[' in aud{ stov - Edge of Human Input
\
 TOV @ 1- EOD 1+
 DO
  \
   c[ TOV @ I \ Locate c[
   locate-char2 dup T1 !
    dup 0= if leave then
   c[ TOV @ T1 @ 1+
   locate-char2 dup T2 ! \ Locate Next c[
   dup 0= if drop leave then
   swap - L1 !
  \
  TOV @ 1- T2 @ 1+
  DO
   \
    c[ TOV @ I 1+
    locate-char2 dup T3 !
    dup 0= if drop leave then
    t2 @ - L2 !
    L1 @ L2 @ =

         If     \ If length of T1 and T2 are = loop and compare values
           -1 L1 @ 0
           do
            T1 @ I + >en{ neno @ T2 @ I + >en{ neno @ <> if drop 0 leave then
           loop
           if c{ t2 @ >aud{ stov c! then
         Then

    T3 @ T2 !
    L2 @
  +loop
\
 T1 @ I - L1 @ +
 +Loop
s" Completed " cr type cr
\
 REJUVENATE
 Mind-Dump#
;
\
\ ***************************************************************************************
\
