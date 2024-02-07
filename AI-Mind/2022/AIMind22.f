\ Win32F Windows-AIMind22.F
\ Frank J. Russo
\ Version 2.1.0 230513
\
Anew Win-AIMind-24
\
False value turnkey?
Chdir c:\programming\Win32Forth\proj\AIMind-I\2022
Include AIMind22.h  \  Header file for all varibles, values, constants, ....
\ Include \Programming\Win32Forth\src\lib\AcceleratorTables.f
\ Needs NoConsole.f
\ Needs excontrols.f
Needs Resources.f
\
\ Needs multitaskingclass.f
\ wTasks myTasks
\ 50 Set#Jobs: myTasks
\ Start: myTasks
\
\ ***************************************************************************************
\
: Range  ( V, LL, UL -- T/F ) \ FJRusso determines if V is in the range of LL -> UL
{: V1 LL1 UL1 :} \ Define local variables
v1 LL1 >= v1 UL1 <= and
;
\
\ ***************************************************************************************
\
: diagnostic-window ( addr, count --- ) \ revised to catch IF logfile is closed
\
\ Need Code to display messages in the diagnostic window
\
1 diagmessagnr +! \ Basically this is a line counter
\
fyi @ 0BH = \ output to logfile
IF
   logfile-ptr dup IF write-line drop Else drop 2drop endif
Else
   2drop
Then
;
\
\ ***************************************************************************************
\
((
: Disable-Timers
timer1 -if 0 KillTimer drop False to timer1flag 0 to timer1 Else drop Then
timer2 -if 0 KillTimer drop False to timer2flag 0 to timer2 Else drop Then
timer3 -if 0 KillTimer drop False to timer3flag 0 to timer3 Else drop Then
timer4 -if 0 KillTimer drop False to timer4flag 0 to timer4 Else drop Then
timer5 -if 0 KillTimer drop False to timer5flag 0 to timer5 Else drop Then
s" Disable-Timers"  diagnostic-window winpause
;
\
\ ********************************************************************************
\
: ProcessMsg  \ Implementation 230301 FJR
8 + w@ dup
cr ." Got a Message for "
case
  timer1 of ." Timer1" cr 0 think-delay timer1 0 SetTimer drop False to Timer1Flag endof
 \ timer2 of ." Timer2" cr 0 300000     timer2 0 SetTimer drop False to Timer2Flag endof
  timer2 of ." Timer2" cr 0 to timer2 False to Timer2Flag endof
  timer3 of ." Timer3" cr 0 to timer3  endof
  timer4 of ." Timer4" cr 0 to timer4  endof
  timer5 of ." Timer5" cr 0 to timer5  endof
endcase
0 KillTimer drop
;
\
\ ********************************************************************************
\
: TimerMsg ( pmsg f -- pmsg f ) \ Implementation 230301 FJR
 -IF
   drop dup @ 0= over cell + @ WM_TIMER = and
   IF
    ProcessMsg False
   Else True
   Then
  Then
;
\
msg-chain chain-add TimerMsg
))
\
\ ***************************************************************************************
\
defer mind-dump#
\
include ai-func-calls.f
include wininet.f
ftp-size newuser AI-FTP  \ ftp-size found in wininet.f
include ai-dot-calls.f
include sock.f
include ai-mind-net.f
include ai-email.f
\ include file-emit.f
\ include AI-Speech.f
\ include \Win32Forth\Win32Forth615\proj\AIMind-I\Key-Processing.f
\
defer GLT \ Get Last thought
defer Begin-Alife#
defer Status-Window#
defer Main-Window#
defer Process-Window#
defer Aud13#
defer Aud10#
defer GOT \ Get Old Thought
defer Inet-Proc
defer English#
defer close-display#
\
\ ***************************************************************************************
\
: Title ( - ) \ Updated 230510 FJR
\
	w-display 24 80 * erase
	Temp-Buffer 80 erase
	msg5 zcount w-display swap cmove \ First Line
\
	msg6 zcount w-display 80 + swap cmove  \ Second Line
\
	byear @ bday @ bmonth @ \ Birth Date
	msg7 zcount temp-buffer swap cmove
	s>d <# # # #>  temp-buffer zcount + swap cmove
	20H TEMP-BUFFER ZCOUNT 1 + + C!
	s>d <# # # #>  temp-buffer zcount + swap cmove
	20H TEMP-BUFFER ZCOUNT 1 + + C!
	s>d <# # # #>  temp-buffer zcount + swap cmove
	s"  at " temp-buffer zcount + swap cmove
	bhour @ s>d <# # # #>  temp-buffer zcount + swap cmove
	s" :" temp-buffer zcount + swap cmove
	bminute @ s>d <# # # #> temp-buffer zcount + swap cmove
	s"  am " temp-buffer zcount + swap cmove
	temp-buffer zcount w-display 80 2 * + swap cmove \ Third Line
\
	temp-buffer zcount erase
        talive @ ms@ trun @  - 60000 / + s>d <# # # #>
	msg14 zcount temp-buffer zcount + swap cmove
	temp-buffer zcount + swap cmove
	s"  Minutes " temp-buffer zcount + swap cmove
	temp-buffer zcount w-display 80 3 * + swap cmove \ Line 4
\
        get-local-time time-buf >date" w-display 80 4 * + dup >r swap cmove \ Line 5
\
        s"    " r> zcount + dup >r swap cmove     \ Date Display
\
        time-buf >time" r> zcount + dup >r swap cmove    \ Time Display
	r> zcount + 1- 32 swap c! \  minor fix to display
\
;
\
\ ********************************************************************************
\
: Title1 ( - #)
\
display-buffer-2 900 32 fill
\
        S" Motorium Cycle = "
        display-buffer-2 5 + swap cmove
        S" Security Cycle = "
        display-buffer-2 33 + swap cmove
        S" IP Address = "
        display-buffer-2 64 + swap cmove
        S" Volition Cycle = "
        display-buffer-2 5 + 90 + swap cmove
        S" Think Cycle = "
        display-buffer-2 33 + 90 + swap cmove
	S" EMail: "
	display-buffer-2 64 + 90 + swap cmove
        S" Sensorium Cycle = "
        display-buffer-2 5 + 180 + swap cmove
        S" Emotion Cycle = "
        display-buffer-2 33 + 180 + swap cmove
        S" Rejuvenation Cycle = "
        display-buffer-2 5 + 270 + swap cmove
        S" IQ = "
        display-buffer-2 33 + 270 + swap cmove
        S" EEG = "
        display-buffer-2 5 + 360 + swap cmove
        S" T-Time = "
        display-buffer-2 33 + 360 + swap cmove
        S" TOV = "
        display-buffer-2 5 + 450 + swap cmove
        S" Dictionary = "
        display-buffer-2 33 + 450 + swap cmove
        S" Slow-Delay = "
        display-buffer-2 5 + 540 + swap cmove
        S" Think-Delay = "
        display-buffer-2 33 + 540 + swap cmove
        S" Run-Time = "
        display-buffer-2 5 + 630 + swap cmove
        S" Hash Table = "
        display-buffer-2 33 + 630 + swap cmove
	S" Start Time: "
	display-buffer-2 5 + 720 + swap cmove
	time-buf >time" display-buffer-2 737 + swap cmove
        S" Server Hits = "
        display-buffer-2 33 + 720 + swap cmove
\
;
\
\ ********************************************************************************
\
: Title2 ( -- # ) \ Updated 230510 FJR
\

  tempspace 8 erase
  motoriumcycle @   tempspace >string tempspace count display-buffer-2 22  + swap cmove tempspace 8 erase \ Motorium @ Cycle =
  securitycycle @   tempspace >string tempspace count display-buffer-2 50  + swap cmove tempspace 8 erase \ Security @ Cycle =
  volitioncycle @   tempspace >string tempspace count display-buffer-2 112 + swap cmove tempspace 8 erase \ Volition @ Cycle =
  thinkcycle @      tempspace >string tempspace count display-buffer-2 137 + swap cmove tempspace 8 erase \ Think @ Cycle =
 ( ms@ elapsed-time - 60000 /  \ Calc time running
  tempspace >string tempspace count display-buffer-2 169 + dup >r s"     " r> swap cmove
  swap cmove tempspace 8 erase \ )
  sensoriumcycle @  tempspace >string tempspace count display-buffer-2 203 + swap cmove tempspace 8 erase \ Sensorium @ Cycle =
  emotioncycle @    tempspace >string tempspace count display-buffer-2 229 + swap cmove tempspace 8 erase \ Emotion @ Cycle =
  rejuvenatecycle @ tempspace >string tempspace count display-buffer-2 296 + swap cmove tempspace 8 erase \ Rejuvenation @ Cycle =
  IQ @ 		    tempspace >string tempspace count display-buffer-2 308 + swap cmove tempspace 8 erase \
  EEG @ 	    tempspace >string tempspace count display-buffer-2 372 + swap cmove tempspace 8 erase \ ." (" eegmax @ . ." )  "
  t @		    tempspace >string tempspace count display-buffer-2 402 + swap cmove tempspace 8 erase \ T:Time
  tov @ 	    tempspace >string tempspace count display-buffer-2 461 + swap cmove tempspace 8 erase \ Time of Voice
  dict-offset       tempspace >string tempspace count display-buffer-2 496 + swap cmove tempspace 8 erase \ ." / "  dict-size . \ dictionary size
  slow-delay        tempspace >string tempspace count display-buffer-2 558 + swap cmove tempspace 8 erase \
  think-delay       tempspace >string tempspace dup c@ 1+ swap c! tempspace dup c@ + 32 swap c! \  minor fix to display
  tempspace count  display-buffer-2 587 + swap cmove tempspace 8 erase \
  \ display-buffer-2 dup zcount conct @ 		>string zcount 5 32 fill \
  ms@ trun @ - 60000 /  tempspace >string tempspace count display-buffer-2 646 + dup >r s"     " r> swap cmove
  swap cmove tempspace 8 erase
  s" Minutes" display-buffer-2 652 + swap cmove
  hash-count tempspace >string tempspace count display-buffer-2 676 + swap cmove tempspace 8 erase   \
  ip-addr-space zcount display-buffer-2 77 + dup 13 32 fill swap cmove
  s" TBD   " display-buffer-2 161 + swap cmove
  Server-hits @ tempspace >string tempspace count display-buffer-2 767 + swap cmove tempspace 8 erase \

\
;
\
\ ********************************************************************************
\
: Calc-midway  T @ EOD - 2 / EOD + to Midway ;
\
\ ********************************************************************************
\
: #line"        ( n1 - a1 n2 ) \ get the address and length a1,n2 of line n1
line-tbl swap 0max line-last min cells+ 2@ tuck - 2 - 0max
;
\
\ ***************************************************************************************
\
: center-page \ ( count - offset - pixels)
\
	nrcol# 2/ char-width * \ Center of page
	swap   2/ char-width * -
;
\
\ ***************************************************************************************
\
: AI-Wake-Up
\
s" AI-Wake-Up" 2dup diagnostic-window type cr cr
random-init \ Initialize Random number generator
\
\ Initialize variables
0 motoriumcycle ! 	0 securitycycle  !	0 volitioncycle   !	0 sensoriumcycle !
0 thinkcycle !		0 emotioncycle !	0 rejuvenatecycle !	0 to quit-flag
0 diagmessagnr !	7 HIB-Loc !		0Bh FYI !		0 keyb-time !
0 pho !			0 to word-exec		0 T !			0 TOV !
0 Vault  !		0 Nen !			5480660 truntime !   	0 to rethought
63963 talive !		0 max-word-len !	0 to get-thought1	singular to pos-flag
5 bias !		2 lump !		0 server-hits !
0 recon !		0 to Inet-Stat		0 inet-time !		0 to timer1C
0 to timer1		0 to timer2		0 to timer3		0 to timer4
0 to timer5             0 to hash-sort
False To timer1Flag	False to timer2Flag	False to timer3Flag	False to timer4Flag
False To timer5Flag
neuter to gender	0 cont-run !	        65 eeg !		65 iq !
0 to EOD		0 to time-delay-cycle	0 email-time !
\
bl>buffer
>RTDate \ Load Todays Date (AI-func-calls.f)
\
eeg-space 500 + 50 95 fill
s" E.E.G. Charting " eeg-space 550 + swap cmove
human-input-buffer inbufsize erase
Mind-output-buffer  inbufsize erase
\
\ delay onset of new thought for 1/2 minute or till user types in a concept
ms@ dup starttime ! dup trun ! dup tidle ! dup inet-time !
30000 + think-timer ! \ 60000 + inert !
\
\ Zero out all sentence items
0 dup to subject dup to verb dup to auxv dup to negv to verb-object
0 dup old-sub ! dup old-verb ! old-obj !
\
\ Set Birthday to default
2006 byear ! 7 bmonth ! 11 bday ! 07 bhour ! 34 bminute ! 0 bsecond !
\
\ Open AI Log Files
\
s" Open AI Log File " 2dup diagnostic-window type cr cr
\
	get-local-time time-buf >date" 2drop
	s" AIMind22.log" w/o open-file \ open life file
	IF \ error occured file not located
	 drop
	 s" AIMind22.log" w/o create-file \ Create log file drop
	drop to logfile-ptr
	msg5 zcount workfile-buffer swap cmove \ Log File Opened Write out Header
	13 workfile-buffer zcount + C!
	Msg6 zcount workfile-buffer zcount + swap cmove
	13 workfile-buffer zcount + C!
	Msg7 zcount workfile-buffer zcount + swap cmove
	13 workfile-buffer zcount + C!
	log-file-write
	Msg9 zcount workfile-buffer swap cmove
	msg8 zcount workfile-buffer ZCOUNT + swap cmove
	13 workfile-buffer zcount + C!
	( msg24 zcount 5 - workfile-buffer ZCOUNT + swap cmove
	13 workfile-buffer zcount + C! )
	Msg-Seperator zcount workfile-buffer ZCOUNT + swap cmove
	13 workfile-buffer zcount + C!
	log-file-write
	Else
	 to logfile-ptr
	 logfile-ptr file-size drop
	 logfile-ptr REPOSITION-FILE drop \ REPOSITION-FILE( ud fileid -- ior ) go to end of file
	Then
	msg2 zcount workfile-buffer swap cmove \ Log File Opened
	msg9 zcount workfile-buffer ZCOUNT + swap cmove
	Msg8 zcount workfile-buffer zcount + swap cmove
	13 workfile-buffer zcount + C!
	( msg24 zcount 5 - workfile-buffer ZCOUNT + swap cmove
	13 workfile-buffer zcount + C! )
	date$ zcount workfile-buffer zcount + swap cmove
	>LogFile
Title
s" AI-Wake-Up - Completed" 2dup diagnostic-window type cr cr
;
\
\ ********************************************************************************
\
: Mind-Dump ( 080126 FJR )
\ Write out the memory core and the dictionary space
\
fyi @ 1 and  IF s" Mind-Dump Entered"  diagnostic-window Then
 workfile-buffer 1024 0 fill     \ be sure buffer is blank
 -1 \ t @ cns-time = not quit-flag or \ time-line change has occured or quit flag is set
   If
	maxwordsize	\ Determine size of largest word in Dictionary
	ms@  trun @ - 60000 / cont-run @ + dup
	quit-flag
	 IF
	   dup cont-run !
	   talive @
	 Else
	   ms@ trun @ - 60000 / talive @ +
	 Then
	cns @ 2 - >aud{ 1+ !	\ Save Talive
	dup cns @ 1- >aud{ 1+ !	\ Save Cont-run
	truntime @ >
\
	IF
	     >RTDate
	     truntime ! s" Max run time = " workfile-buffer swap cmove
	     truntime @ tempspace >string
	     tempspace count workfile-buffer zcount + swap cmove
	     s"  Minutes" workfile-buffer zcount + swap cmove
	     log-file-write
	Else drop
	Then
	t @ to cns-time
	datafile zcount w/o open-file drop to workfile-ptr \ open life file
\	s" Begining of Mind Dump Core Variables" workfile-ptr write-file drop crlf$ count workfile-ptr write-file drop
	cns-core-start cns-core-end cns-core-start - workfile-ptr write-file drop \ write out memory core
\	s" Ending of Mind Dump Core Variables " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
	  en{ cns @  en-size * workfile-ptr write-file drop
\	s" en{ array " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
	 psi{ cns @ psi-size * workfile-ptr write-file drop
\	s" psi{ array " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
	 aud{ cns @ aud-size * workfile-ptr write-file drop
\	s" aud{ array " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
	hash{ hashtable-size   workfile-ptr write-file drop
\	s" hash{ array " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
	dictionary dict-offset   workfile-ptr write-file drop   \ Save dictionary after memory core
\	s" Dictionary " workfile-ptr write-file drop  crlf$ count workfile-ptr write-file drop
\
	workfile-ptr close-file drop
	s" Mind Dump Processed."  diagnostic-window
	\ Log File Entry
	workfile-buffer 1024 0 fill s" Memory Dump to File " workfile-buffer swap cmove
	>logfile
   Then
\
 workfile-buffer 1024 0 fill
\
;
' mind-dump is mind-dump#
\
\ ********************************************************************************
\
: SPREADACT ( spreading Activation ) \ atm 23jan2006 Updated 080308 FJR
\ Called by Activate to spread activation among concepts.
\ It follows "pre" and "seq" tags to find related concepts.

\ fyi @ 1 and  IF  s" :SpreadAct Entered" 2dup type cr diagnostic-window  Then
\
pre @  \ 0> dup
IF (( s" pre(vious) Concept exist" 2dup type cr  diagnostic-window )) \ IF a pre(vious) concept exists...
     zone @ dup 5 - swap

     Do \ Look from present position backward up to 5 concepts
		I >psi{ psio W@ pre @ =

		IF \ Find the "pre" concept...
		  1 I >psi{ acto w+! \ 8sep2005 minor "pre" boost
\
\ Negative activation levels not possible 080308
		  I >psi{ acto w@ 1 < \ Do not permit negative activations.
		    IF \ 7aug2005
			1 I >psi{ acto w! \ Reset to one;
		    THEN
\
		  I >psi{ acto w@ 63 >
		    IF ( s" Activation-limit has been exceeded  " 2dup type I . cr diagnostic-window)
			63 I >psi{ acto w! \ set the activation back to the limit.
		    THEN
\
		LEAVE
		THEN \ End of middle if-clause.
\
    -1 +LOOP
\
THEN \ End of outer if-clause pre > 0
\
seq @ \ 0>
IF  (( s" A sub(seq)uent concept exist " 2dup type cr diagnostic-window ))
    zone @ dup 5 + swap \ 2dup s" Seq Loop - " type . . cr
    Do  \ Look from present position forward up to 5 concepts
	  I >psi{ psio W@ seq @ =

	  IF  ( s" a match of 'seq' is found " type cr )
            spike @ I >psi{ acto w+! \  2aug2005 "spike" and not "bulge"
\
\ Negative activation levels not possible 080308
		  I >psi{ acto w@ 1 < \ Do not permit negative activations.
		    IF \ 7aug2005
			1 I >psi{ acto w! \ Reset to one;
		    THEN
\
            I >psi{ acto w@ 63 >
	       IF \ If activation-limit has been exceeded
	          63 I  >psi{ acto w! \ set the activation back to the limit.
	      THEN
          LEAVE
          THEN \ End of middle if-clause.
\
    LOOP \ Seq > 0
\
THEN \ End of outer if-clause.
\
\ fyi @ 1 and  IF  s" :SpreadAct Exited" 2dup type cr diagnostic-window Then
;
\
\ ********************************************************************************
\
: Activate  (   ---   ) \ Updated 23022 FJR
\ New Combined activation routine for Noun / Verb & Activate
\ Uses value of Actv to set direction 0 = nounact / 1 = verbact / 2 = activate
\
 fyi @ 1 and  IF s" :Activate Entered" diagnostic-window then
\
\ actv 2 = IF  psiDecay  Then \ 8oct2005 Favor new activations over old and unresolved.
psi @ t @ eod > and  \ psi > 0 and T > EOD
IF
 EOD T @ 1-
 DO \ Search back to end of dictionary.
   I >psi{ psio W@ psi @ =
\
   IF \ If concept "psi" is found...
\
     ACTV case
            \ Noun - Activate all the nodes equally.
	    0 of jolt @ I >psi{ acto w@ max 33 max 63 min I >psi{ acto w! endof 	\ 070419 FJR
            \ Verb - Assume a pre-existing lower-tier.
	    1 of I >psi{ acto w@ 2* 16 +      33 max 63 min I >psi{ acto w! endof
	    \ Activate Impart a set value, not an increment.
	    2 of 16 I >psi{ acto w+!  endof \ change from 21 to 16 080309
          endcase
\  IF psio is a question Zero for sake of other concepts.
 I >psi{ psio W@ Who How Range IF 0 I >psi{ acto w! THEN
 I >psi{ preo  W@ pre ! ( save pre for use in SPREADACT )
 I >psi{ seqo W@ seq ! ( save seq for use in SPREADACT )
 I zone ! ( for use in SPREADACT )
\
 ACTV case \ Calc spike value for use in SPREADACT
	0 of I >psi{ acto w@ -if 5 /  2 * 10 + Else drop 6 Then spike ! endof    \ Noun Spike Values 080308 update
	1 of I >psi{ acto w@ -if 5 / 1+ 4 * ( 1-) Else drop 0 Then spike ! endof \ Verb Spike Values 070419 update
	2 of I >psi{ acto w@ -if 5 / 2 * 2 +  Else drop 1 Then spike ! endof \ Activate Spike Values from OldConcept
      endcase
\
seq @ IF SPREADACT  Then \ Call ONLY IF needed for spreading activation
\
 0 pre ! \ blank out "pre" for safety
 0 seq ! \ blank out "seq" for safety
\
 THEN \ end of test for "psi" concept
\
 -1 +LOOP \ end of backwards Loop
\
THEN \ End of check for non-zero "psi" from OLDCONCEPT.
\
fyi @ 1 and  IF s" Activate Exited" diagnostic-window Then
\
;
\
\ ********************************************************************************
\
: INSTANTIATE (   ---   )
\ Create a concept-fiber node atm 14oct2005 updated FJR 101031
\ Called from the PARSER module to create a new node of a Psi concept.
\
\ fyi @ 1 and  IF s" :INSTANTIATE" 2dup type cr diagnostic-window Then
\
 ( concept fiber psi )           		psi @ T @ >psi{ psio W!
 ( If activation > 64 reset to max) act @ 0< IF 64 act ! Then
 ( Set "act" activation level. ) 	act @ T @ >psi{ acto W!
 ( Store JUXtaposition tags. )   	jux @ T @ >psi{ juxo W!
 ( Store PREvious associand. )   pre @ T @ >psi{ preo W!
 ( Store functional pos code. )  	pos @ T @ >psi{ poso C!
 ( Store the subSEQuent tag. )   	seq @ T @ >psi{ seqo W!
 ( Store the EN-transfer tag. ) 	enx @ T @ >psi{ enxo W!
 ( Reset for safety. )  			0 seq ! 0 enx !
\ fyi @ 1 and  IF s" :INSTANTIATE exit" 2dup type cr diagnostic-window Then
; \ End of INSTANTIATE; return to Parser module.
\
\ ********************************************************************************
\
: enVocab (   ---   )
\ English Vocabulary node creation atm 14oct2005 101030 FJR
\ Called from bootstrap; NEWCONCEPT or OLDCONCEPT to create a node on a quasi-concept-fiber
\ by "attaching" to it associative tags for En(glish) vocab(ulary).
\ fyi @ 1 and  IF s" :enVocab" 2dup type cr diagnostic-window Then
\
 ( Number "nen" of English )       		nen @  T @ >en{ neno W!
 ( Do not store the activation level; it is a transient.)
 ( Store mindcore EXit tag. )      		fex @  T @ >en{ fexo W!
 ( Store part of speech "pos".)    		pos @  T @ >en{ poso C!
 ( Store part of speech "Gender".) 	gender T @ >en{ gendero C!
 ( Store part of speech "Plural".) 	pos-flag T @ >en{ S-PO C!
 ( Store mindcore IN tag. )        		fin @ T @ >en{ fino W!
 ( Store the auditory "aud" tag. ) ( aud) T @ dup >en{ audo W!
 ( Advance time counter ) 			1 T +!
\ fyi @ 1 and  IF s" :enVocab exit" 2dup type cr diagnostic-window Then
; \ End of enVocab; return to OLDCONCEPT or NEWCONCEPT.
\
\ *******************************************************************************
\ Below Code is linked to Parsing of the input thoughts
\
\ Test for Adjective & Adverb
\ Test for is - are - am  form of verb
\ Test Singular - Plural condition
\
\ *******************************************************************************
\
: Inet-Process ( FJR 101223) \ Internet access related
fyi @ 1 and  IF s" :Inet Process Entered" diagnostic-window Then
Timer3Flag
  IF \ update html page every minute
	false to timer3flag
	1 +to timer1C
	GLT
	fyi @ 1 and  IF s" :html-page-update Entered" diagnostic-window Then
	\ sentence-proc	\ loads up the Mind-output-buffer
        ( html-page-update )
        fyi @ 1 and  IF s" Html Page Updated" diagnostic-window Then
	Mind-output-buffer zcount 0 fill
	timer1C 4 >
	ms@ inet-time ! \ reset timer
	IF
	   msg20a zcount diagnostic-window
	   24 diagnosticw-loc @ gotoxy \ got to previous line displayed
	   ms@ trun @  - 60000 / . ." Minutes       "  \ 090821
	   ( ai-ftp ftpservice ftp-size cmove  ) 	\ copy the FTP data into the service call
	   ( FTP->Server )				\ FTP to server every 5 minutes
	   securitycycle @ to time-delay-cycle  \ reset with existing cycle count
	   ms@ 60000 + to delay-cycle-time      \ reset delay
	   IF msg20b zcount diagnostic-window 0 to timer1C \ 101223 update
                Else msg20c zcount diagnostic-window 4 to timer1C \ set timer to try again in 1 minute 101223
           Then \ Inet handle >0 on stack = success
	Else
	drop
	Then
 Then
 fyi @ 1 and  IF s" :Inet-Process Exited" diagnostic-window Then
;
' Inet-Process is Inet-Proc
\
\ ********************************************************************************
\
: enb-assemble \ FJR 101030
\
 0 act !  0 jux !  0 pre ! 0 seq !
 display-buffer tlen 2dup
 -1 "#hash   t @ >hash{ hashv !
 dict-offset t @ >hash{ dict-loc !
 tlen t @ >hash{ wleno c!
 t @ dup >aud{ hashkey w!
 0  t @  >aud{ stov c!
 C# t @  >aud{ povo c!
 dup >r dictionary dict-offset + SWAP CMOVE R> +TO DICT-OFFSET
 tnen psi !  tpos pos ! tnen enx ! INSTANTIATE
 tnen nen !  tpos pos ! tnen fex ! tnen fin ! t @ aud ! enVocab
 0 dup len ! to tlen Tnen nen-max 2dup @ > IF ! Else 2drop Then
;
\
\ ********************************************************************************
\
: TABULARASA \ FJR 101030
\ Clears the mind arrays
 psi{  cns @ 1- psi-size * erase
 en{   cns @ 1- en-size  * erase
 aud{  cns @ 1- aud-size * erase
 hash{ hashtable-size erase
\ End of TABULARASA; return to ALIFE.
;
\
\ ********************************************************************************
\
: enb-process { S1 L1 }  \ Updated 230509 FJR
\ need to seperate out 6 values
\ NEN, Length, Concept Word, POS, Gender, PS
display-buffer 80 erase
workfile-buffer zcount
7 0 Do
\      44 locate-char1 \ ( Addr1 C -- Addr1 Addr2 ) Looking for a comma e.g. data field   1,1,A,1,78,83,0
\ For String to Number use: S" 1234" (NUMBER?) (str len -- N 0 ior)
\    swap 2dup -
over swap 44 scan to L1 to S1 S1 over -
    i 2 =
      IF
	display-buffer swap cmove	\ got to get the concept word out
      Else
        (NUMBER?) 2drop \ save number to proper field
\
         I Case
	    0 of to tnen Endof
	    1 of to tlen Endof
	    3 of to tpos Endof
	    4 of to gender Endof
	    5 of to pos-flag Endof
	    6 of to GLBDom Endof
	 Endcase
\
      Then
\      1+
\      Begin
\         dup c@ bl = IF 1+ 0 Else -1 Then
S1 1+ L1
\      Until
    Loop
Drop
enb-assemble
display-buffer 80 erase
;
\
\ ' enb-process is enb-process>
\
\ ********************************************************************************
\
: EnBoot ( Revised 230509)
{ W-Count }
\
s" EnBoot - entered "  diagnostic-window
s" Bootflag = " type bootflag . cr
\
T @ IF TABULARASA Then
1 T ! 0 dup vault ! dup vault+ ! nen-max !
\
s" enboot1.csv"  r/o open-file 0= \ attempt to open input file r/o read only
  IF
s" Success opening enboot1.csv" type cr
    to enboot-ptr   			\ save file pointer
  Else
S" Opening enboot1.csv failed" type cr
  Then
\
\ ." Read in First Line get Dictionary Word Count"  cr
workfile-buffer workfile-buffer 128 enboot-ptr read-line 2drop
4 0 Do 44 scan swap 1+ swap Loop drop 3  (NUMBER?) 2drop to W-Count
\ ."  skip Instruction lines" cr
0 0
Begin
2drop
workfile-buffer workfile-buffer 128 enboot-ptr read-line 2drop \ Changed from 64 to 128 210218
workfile-buffer over type cr
s" NEN, Length, Concept" search ( Enboot1.csv" search )
Until
\
\ ." Read in Dictionary" cr
2drop
0 to enboot-counter
W-Count 0 Do
1 +to enboot-counter
workfile-buffer zcount erase
workfile-buffer 64 enboot-ptr read-line drop
\
 IF
   workfile-buffer + 1- t0 ! enb-process  \ process line
 Else drop
 Then
Loop
\
\ ." By Pass File Header" cr
workfile-buffer 64 enboot-ptr read-line 2drop drop \ By Pass File Headers
workfile-buffer 64 enboot-ptr read-line 2drop drop \                 "
workfile-buffer zcount erase
\
Begin \ Load Knowledge Base predefined sentences from the enboot1.csv file
\
	  workfile-buffer zcount erase
          workfile-buffer dup 64 enboot-ptr read-line 2drop \ 2dup type cr
	  C# pov ! mind-output-buffer zcount erase
	  Mind-output-buffer swap cmove
\	  Paint: Main-Window#
\	  winpause
	  CLf pho ! True to #aud10 Aud10#
	  eod t @ Do i >aud{ stov @ 0> IF i to SOLV Then -1 +loop
	  t @ dup to rethought vault+ !
         workfile-buffer zcount s" ** END OF KNOWLEDGE BASE **" Search Nip Nip
\
Until
s" ** KNOWLEDGE BASE ** Loaded"  diagnostic-window
\ ." Clean up needed of runtime variables"  cr
   t @
   dup vault ! 	\ Retain size of enBoot for Rejuvenate.
   dup tov !
   dup to hash-count
   nlt !  	\ nlt may be basis for DAMP functions )
\
   nen-max @ 1+ nen !
   5 bias !  	 	\ Expect first to parse a noun=5.
   0 pho !	 	        \ Reset to prevent reduplication.
   0 pre ! 0 seq !  	\ Prevent carry-overs.
   vault @ vault+ ! 	\ Initialize Vault+ to Vault
   T @ dup to eod to rethought
\
enboot-ptr
  IF
   enboot-ptr close-file drop \ closefile
  Then
s" EnBoot - exited "  2dup type cr diagnostic-window
;
\
\ ***************************************************************************************
\
((
\ audSTM is called from the AUDITION module.
: audSTM ( auditory Short Term Memory ) \ atm 14oct2005
  t @ vault @ > IF  \ If time has advanced beyond bootstrap,
    pho @ 32 > IF  audRecog  THEN  ( ASCII 32 = SPACE-bar )
  THEN  \ end of test to prevent "recognition" of bootstrap.
    t @ 1-  0 aud{ @  0 = IF  1 beg !  THEN  \ zero  2sep2005 X 0=
    t @ 1-  0 aud{ @ 32 = IF  1 beg !  THEN  \ SPACE-bar.
    pho @  t @  0 aud{ !  \  Store the pho(neme) at time t
 \      0  t @  1 aud{ !  \  Store no act(ivation) level.
    pov @  t @  2 aud{ !  \  point-of-view: internal #, external *
    beg @  t @  3 aud{ !  \  beg(inning)?  1 Yes or 0 No.
    ctu @  t @  4 aud{ !  \  continuation? 1=Y or 0 = No.
    ctu @ 0 = IF  \ 27jul2005 Store no false recognitions.
      psi @  t @  5 aud{ !  \  ultimate psi tag # to a concept.
      \ 0 psi !  \ 26jul2002 Safety precaution reset.
    THEN  \ 27jul2005 end of attempt to avoid false recognitions.
    pho @ 32 = IF t @ spt !  THEN  \ Update "space" time.
;  \ End of audSTM; return to AUDITION.

\ kbTraversal keeps the AI from becoming too dull.
:  kbTraversal ( reactivate KB concepts )  \  3sep2008

    35 pov !  \  3sep2008 Make sure pov is "internal".

    psiDecay  \  3sep2008 Suppress currently active concepts.
    psiDecay  \  3sep2008 Suppress currently active concepts.
    psiDecay  \  3sep2008 Suppress currently active concepts.

    kbtv @ 4 > IF  1 kbtv !  THEN  \  3sep2008 Cycle through values.

    CR ." KB-traversal: With kbtv at " kbtv @ .   \  3sep2008

    kbtv @ 1 = IF  \  3sep2008
      39 psi !     \  3sep2008 Psi concept #39 for "ROBOTS" in enBoot.
      ." activating concept of ROBOTS" CR
      62 nounval ! \  3sep2008 High enough for slosh-over?
      nounAct      \  3sep2008 Activate the indicated concept.
    THEN  \  3sep2008

    kbtv @ 2 = IF  \  3sep2008
      37 psi !     \  3sep2008 Psi concept #37 for "PEOPLE" in enBoot.
      ." activating concept of PEOPLE" CR
      62 nounval ! \  3sep2008 High enough for slosh-over?
      nounAct      \  3sep2008 Use the concept in a sentence of thought.
    THEN  \  3sep2008

    kbtv @ 3 = IF  \  3sep2008
      56 psi !     \  3sep2008 Psi concept #56 for "YOU" in enBoot.
      ." activating concept of YOU" CR
      62 nounval ! \  3sep2008 High enough for slosh-over?
      nounAct      \  3sep2008 Use the concept in a sentence of thought.
    THEN  \  3sep2008

    kbtv @ 4 = IF  \  3sep2008
      68 psi !     \  3sep2008 Psi concept #68 for "TRUTH" in enBoot.
      ." activating concept of TRUTH" CR
      62 nounval ! \  3sep2008 High enough for slosh-over?
      nounAct      \  3sep2008 Use the concept in a sentence of thought.
    THEN  \  3sep2008

    42 pov !  \  3sep2008 Set pov to "external" to await input.

;  \  3sep2008 End of kbTraversal; return to Rejuvenate.
\
\ ********************************************************************************
\
\ The Article module aims for the following entelechy goals.
\ [ ] It shall insert "THE" before something just mentioned.
\ [ ] It shall substitute "AN" for "A" when warranted.
\ [ ] It shall decide properly between the use of "A" and "THE".
\ Article is the first expansion of the Forthmind after its
\ emergence from debugging as a True AI in January of 2008.
: Article ( nen --  ) \  select "a" or "the" before a noun 1sep2008 230227 FJR
\
  en{ en-size rot get-addr S-PO c@ dup 83 =
IF    \ 27aug2008 If noun is singular...
    EoD dup T @ swap - 2 /  +  t @
     DO  \ 27aug2208 Look backwards for 1=A.
      en{ en-size I get-addr neno W@ 40 =
      IF  \ 27aug2008 If #1 "A" is found,
       en{ en-size I get-addr audo W@ aud !  \ 27aug2008 Recall-vector for "A".
        LEAVE  \ 27aug2008 Use the most recent engram of "A".
      THEN  \ 27aug2008 End of search for #1 "A".
    -1 +LOOP  \ 27aug2008 End of loop finding the word "A".
\    SPEECH  \ 27aug2008 Speak or display the word "A".
\
  Else 80 =
         IF    \ 27aug2008 If noun is plural...
    Midway  t @
    DO  \ Look backwards for 358=the.
        en{ en-size I get-addr neno W@ 358 =
         IF  \ If #358 "the" is found,
              en{ en-size I get-addr audo W@ aud !  \ Recall-vector for "the".
              LEAVE  \ Use the most recent engram of "the".
         THEN  \ End of search for #7 "the".
    -1 +LOOP  \ End of loop finding the word "the".
\    SPEECH  \ Speak or display the word "the".
       THEN    \ 27aug2008 End of test for a plural noun.
THEN    \ 27aug2008 End of test for a singular noun.
;  \ 25aug2008 End of Article; return to nounPhrase.
\
\ ********************************************************************************
\
\ The Predicate module aims for the following entelechy goals.
\ [ ] If no predicate nominative is known, detour into a question.
\ [ ] If no transitive verb is most active, default to a verb of being.
\ [ ] If no direct object is found, detour into asking a question.
\ [ ] If a transitive verb is most active, try to find a direct object.
\ [X] Find whatever verb is most active after a noun-phrase.
\ 29aug2008 Predicate is initially a clone of verbPhrase
\ and then radically modified to serve certain purposes.
: Predicate ( supervise verb syntax ) \  1sep2008
  REIFY       \ move abstract Psi concepts to enVocab reality
  0 act !     \ precaution even though zeroed in REIFY
  0 aud !     \ Start with a zero auditory recall-tag.
  0 detour !  \ 19dec2007 Reset this abort-flag at the outset.
  0 motjuste !
  8 opt !  \ Look for option eight (a verb).
  0 psi !  \ Start with a zero Psi associative tag.

  adverbact 32 > IF  \ 29aug2008 Idea for inserting adverbs.
    \ adVerb           \ 29aug2008 Module does not exist yet.
  THEN  \ 29aug2008 End of idea for insertion of adverbs.

  fyi @ 1 > IF CR  \ 18jun2006 New wording for Tutorial clarity.
\ ."   verbPhrase preview with slosh-over indicated by + --"
 ."   Predicate preview with slosh-over indicated by + --" \ 29aug2008
    CR
 ."   Noun & verb activation must slosh over onto logical direct objects."
    CR  ."    " \ 9nov2005 Show word and what it associates to.
  THEN
  midway @ t  @ DO  \ Search backwards through enVocab
    I      4 en{ @  8 = IF  \ 27aug2008 only look at predicate/verbs
      fyi @ 3 = IF  ." Predicate" THEN  \ 29aug2008 change
      fyi @ 2 > IF      \ 24sep2005 Check the display-flag status.
        I 1 en{ @ 0 > IF
           CR ."     cand. act = " I 1 en{ @ . ."  "
           ." w. psi seq #"
           I 6 psi{ @ seq ! seq @ . ."  "  \ 24aug2008 W. psi "seq" #...
           I 6  en{ @ unk  !  \ 27aug2008 Temporary use of "unk"
           BEGIN
           unk @ 0 aud{ @ EMIT  1 unk +!
           unk @ 0 aud{ @ 32 =  \ Using a blank SPACE-bar.
           UNTIL
           ."  w. nodal dir. obj. "  \ 4sep2005 focussing on slosh-over
           midway @ t @ DO  \ Look beyond verb for the "seq" concept
             I   0  psi{ @   seq @  =  IF  \ If match of "seq" is found,
               I 1  psi{ @ . ." = act "  \ Correct node of psi?
               I 7  psi{ @   psi7 !    \ 24aug2008 Get the enx as psi7
               LEAVE                   \ Stop looking after one find.
             THEN       \  End of check for the "seq" concept
           -1  +LOOP    \  End of backwards search for "seq" concept
           midway @ t @ DO  \ Use enx to get the aud recall-vector
             I   0  en{ @    psi7 @ = IF  \ 27aug2008
               I 6  en{ @  rv ! \ 27aug2008 Store auditory recall-vector.
               LEAVE    \ Use only the most recent auditory engram.
             THEN
         \ -1  +LOOP    \ End of backwards search for "psi6" vocab item.
           -1  +LOOP    \  1sep2008 End of search for "psi7" vocab item.
           rv @ 0 > IF  \ Avoid crashes if rv is negative.
             BEGIN
               rv @ 0 aud{ @ EMIT  1 rv +!
               rv @ 0 aud{ @ 32 =  \ Using a blank SPACE-bar.
             UNTIL        \ Stop when a blank space is found.

           THEN
           ."  spike = " spike @ .    \ 4sep2005 from spreadAct?
           0 rv !    \ Zero out the auditory associative tag.
           ."     "  \ Space to set apart chosen verb.
        THEN    \ End of test for positive (non-zero) activations.
      THEN      \ End of test of display-flag status.
      I    1 en{ @  act @ > IF  ( if en1 is higher )

        I  0 en{ @  motjuste !  ( store psi-tag of verb )
        I  4 en{ @  predpos ! ( 29aug2008 grab winning part of speech )
        I  6 en{ @  aud !  ( 27aug2008 auditory recall-vector )

        fyi @ 2 > IF        \ 9nov2005 Diagnostic mode
          CR ." Predicate: aud = "  \ 29aug2008
          aud @ . \ aud recall-vector is...
          aud @ rv !  \ make aud the recall-vector "rv"
          ." urging psi concept #" motjuste @ . ."  " \ 5aug2005 psi #?
          BEGIN       \ Start displaying the word-engram.
            rv @ 0 aud{ @ EMIT  1 rv +!
            rv @ 0 aud{ @ 32 =  \ Using a blank SPACE-bar.
          UNTIL        \ Stop when a blank space is found.
          ."  "
          0 rv !       \ Zero out the auditory associative tag.
        THEN           \ End of test for Diagnostic mode.

        I  1 en{ @  act !  ( to test for a higher en1 )

          fyi @ 3 = IF CR   \ Diagnostic mode
            ."  Predicate: act = " act @ . ."   "  \ 29aug2008
          THEN
        ELSE  \ An error-trap (?) is needed here.
      THEN  \ end of test for en1 highest above zero.
    THEN    \ end of test for opt=8 verbs
  -1 +LOOP  \ end of loop cycling back through English lexicon
   act @  verbval !   \ 3apr2007 For transferring val(ue) to verbAct.
   0 psi !            \ A precaution lest psi transit SPEECH.

   \ 22jan2008 verb-psi for calculating "thotnum"
   motjuste @ 0 > IF motjuste @ vbpsi ! THEN  \ 22jan2008

  fyi @ 2 > IF   \ Test for origin of YES-bug.
    CR ."  Predicate: motjuste = " motjuste @ . ." going into SPEECH."
    CR ."  Predicate: aud = " aud @ . ." going into SPEECH." \ 29aug2008
  THEN           \ End of test for origin of YES-bug.

  motjuste @ 0 = IF  \  3jan2008  If no candidate-verb is found...
    1 detour !   \  3jan2008 Set the detour flag to 1-as-true.
    fyi @ 1 > IF  \  6jan2008 Display in both Tutorial and Diagnostic.
      CR ."   Predicate: detouring when no candidate-verb is found. "
      CR ."   Predicate: detour value is at " detour @ .  \  29aug2008
    THEN          \  3jan2008 End of test for Tutorial mode
  \ LEAVE   \  3jan2008 Go back up to any calling module. e.g., SVO.
  \ LEAVE   \  3jan2008 Ting's manual says LEAVE is for DO-loops.
  THEN  \  3jan2008 End of test for no candidate verb found.

  motjuste @ 0 > IF  \ 15sep2005 Prevent aud-0 of spurious "YES".
\ motjuste @ psi !   \ 10jun2006 For use in verbAct module.
\ verbAct            \  7jun2006 For slosh-over of subj+verb onto object.
  \ act @ 18 < IF  \ 13jan2008 Lower so that crest-noun finds a verb.
    act @ 20 < IF  \ 16jan2008 To detour from low-activation verbs.

      1 detour !   \ 27dec2007 Set the detour flag to 1-as-true.
      1 recon !    \  1sep2008 So that ENGLISH will call ASK.

      fyi @ 1 > IF  \  6jan2008 Display in Tutorial and in Diagnostic.
    CR ."     Predicate: detour because verb-activation is only " act @ .
      THEN          \ 27dec2007 End of test for Tutorial mode
    THEN      \ 27dec2007 End of test for verb with activation too low.

    detour @ 0 = IF  \  3jan2008 Speak verb only if detour is false.

\   motjuste @ lopsi @ = NOT IF  \ 14jan2008 If new psi different from hipsi
\   hipsi @  lopsi ! \ 14jan2008 Prepare to psi-damp old cresting word.
\   lopsi @ urpsi !  \ 14jan2008 Prepare to send urpsi into psiDamp.
\   62 caller !      \ 14jan2008 verbPhrase identified by AI4U page number.
\   psiDamp          \ 14jan2008 Damp the old crest just before new crest.

    62 caller !      \ 22jan2008 verbPhrase identified by AI4U page number.
    psiDamp          \ 22jan2008 Suppress background activations.

\   THEN  \ 14jan2008 End of test to avoid psi-damping the same word.
    motjuste @  hipsi !  \ 14jan2008 Tag the currently cresting word...
    \ ...so that it may be converted to lopsi when the next word crests.
    fyi @ 2 > IF    \ 14jan2008 Select what display mode to show in...
      CR ."  Predicate: lopsi @ hipsi = " lopsi @ . hipsi @ . \ 29aug2008
    THEN            \ 14jan2008 End of fyi-test.

    motjuste @ psi ! \ 11jan2008 For use in verbAct module.
    verbAct          \ 11jan2008 For slosh-over of subj+verb onto object.
      SPEECH         \  To say or display the verb
    THEN             \  3jan2008 End of "detour" test.
  THEN               \ 15sep2005 End of test for motjuste = 0.

 detour @ 0 = IF     \  3jan2008 Only finish vPhr if "detour" is false.

  10 act !  \ 3apr2007 From JSAI: Some activation is necessary.
  fyi @ 2 > IF CR    \ Clean up the Tutorial display.
  ."   in Predicate after SPEECH output of verb" \ 29aug2008
  THEN
  fyi @ 2 > IF CR    \ Seeing what calls psiDamp
  ."   from Predicate after speaking of verb, psiDamping #" motjuste @ .
  THEN
  motjuste @  urpsi !  \ For use in psiDamp.
  22 residuum !  \ Trying to let spike win, over residual activation.
  62 caller !    \ 13jan2008 verbPhrase identified by AI4U page number.
\ psiDamp        \ 29apr2005 Necessary for chain of thought.
\ psiDamp        \ 14jan2008 Commenting out and using lopsi & hipsi.
  0 caller !     \ 13jan2008 Reset caller-ID for safety.
   2 residuum !  \ 28aug2005 Restore minimal psiDamp value.
  enDamp     \ to de-activate English concepts
  32 EMIT        \ Insert a SPACE.
  15 residuum !  \ Give direct objects higher residuum than subjects.
  1 dirobj ! \ 14sep2005 Declare seeking of a direct object.

  fyi @ 2 = IF  \ 30nov2007 For greater clarity in Tutorial mode.
  CR ."          Predicate calls nounPhrase for object of sentence." CR

  THEN

\ 0 dopsi !      \ 22jan2008 Clear old value before new value.
  nounPhrase     \ To express direct object of verb,

  \ 22jan2008 direct-object psi for "thotnum"
  motjuste @ 0 > IF motjuste @ dopsi ! THEN  \ 22jan2008

  0 dirobj !     \ 14sep2005 No longer seeking a direct object.
  2 residuum !   \ 28aug2005 Restore minimal psiDamp value.

 THEN  \  3jan2008 End of test that skips code if "detour" is true.

  fyi @ 2 > IF     \  6jan2008 Test for high fyi value.
  CR ."   Predicate end: detour = " detour @ .  \  3jan2008
  THEN             \  6jan2008 End of test.
;  \  1sep2008 End of Predicate; return to ENGLISH.


\ The whatIs module aims for the following entelechy goals.
\ [ ] Use "is" after both user-questions and self-questions.
\ [X] Ask "What is...?" instead of "What do...do?"
\ whatIs is a clone of whatAuxSDo with changes made
\ to ask "WHAT IS" rather than "WHAT DO... DO"
: whatIs ( what IS Subjects ) \  1sep2008
\  4jan2008 Calls to psiDecay may gradually be commented out.
  psiDecay   \ In the isolated module psiDecay has carte blanche.
  \ Call interrogative pronoun "what":
  midway @  t @  DO  \ Look backwards for 54=what.
    I       0 en{ @  54 = IF  \ If #54 "what" is found,
      54 motjuste !  \ "nen" concept #54 for "what".
      I     6 en{ @  aud !  \ 27aug2008 Recall-vector for "what".
      LEAVE  \ Use the most recent engram of "what".
    THEN  \ End of search for #54 "what".
  -1 +LOOP  \ End of loop finding the word "what".
  SPEECH    \ Speak or display the word "what".
  fyi @ 2 > IF CR  \ Diagnostic message,
\ ."   from whatAuxSDo after speaking of WHAT, psiDamping concept #54"
  ."   from whatIs after speaking of WHAT, psiDamping concept #54"
  THEN
  54 urpsi !  \ For use in psiDamp to de-activate the "WHAT" concept.
  42 caller ! \ 13jan2008 whatAuxSDo identified by AI4U page number.
  psiDamp     \  6aug2005 As when verbPhrase has sent a verb to Speech.
  0 caller !  \ 13jan2008 Reset caller-ID for safety.
  \ Call a form of the auxiliary verb "do":
  \  auxVerb   \  7sep2005 Any of several auxiliary verbs.
  \  1sep2008 Fetch the verb of being "IS".
  midway @  t @  DO  \ Look backwards for 66=IS.
    I       0 en{ @  66 = IF  \ If #66 "IS" is found,
      66 motjuste !  \ "nen" concept #66 for "IS".
      I     6 en{ @  aud !  \  1sep2008 Recall-vector for "IS".
      LEAVE  \ Use the most recent engram of "IS".
    THEN  \ End of search for #66 "IS".
  -1 +LOOP  \ End of loop finding the word "IS".
  SPEECH    \ Speak or display the word "IS".
  fyi @ 2 > IF CR  \ Diagnostic message,
\ ."   from whatAuxSDo after speaking of WHAT, psiDamping concept #54"
  ."   from whatIs after speaking of IS, psiDamping concept #66"
  THEN
  66 urpsi !  \ For use in psiDamp to de-activate the "IS" concept.
\ 42 caller ! \ 13jan2008 whatAuxSDo identified by AI4U page number.
  psiDamp     \  6aug2005 As when verbPhrase has sent a verb to Speech.
  0 caller !  \ 13jan2008 Reset caller-ID for safety.
  0 motjuste !  \ 7sep2005 safety measure
  midway @  t @  DO  \ Look backwards for "topic".
    I       0 en{ @  topic @ = IF  \ If "topic" is found,
      topic @ motjuste !   \ mixing apples & oranges?
      I     6 en{ @ aud ! \ 27aug2008 Auditory recall-vector for "topic".
      LEAVE
    THEN     \ End of search for #"topic".
  -1 +LOOP  \ End of loop finding the lexical "topic" item.
  motjuste @ urpsi !   \ 7sep2005 for sake of psiDamp
  15 residuum !  \ whatAuxSDo module -- 14sep2005 nota bene.
\ 42 caller !    \ 13jan2008 whatAuxSDo identified by AI4U page number.
  psiDamp        \ Damp urpsi but leave residuum of activation.
  1 caller !     \ 13jan2008 Reset caller-ID for safety.
   2 residuum !
  SPEECH     \ Speak or display the lexical "topic".
\ midway @  t @  DO  \ Look backwards for 59=do.
\   I       0 en{ @  59 = IF  \ If #59 "do" is found,
\     59 motjuste !  \ "nen" concept #59 for "do".
\     I     6 en{ @  aud !  \ 27aug2008 Recall-vector for "do".
\     LEAVE  \ Use the most recent engram of "do".
\   THEN  \ End of search for #59 "do".
\ -1 +LOOP  \ End of loop finding auxiliary verb "do".
\ SPEECH    \ Speak or display the auxiliary verb "do".
\ fyi @ 2 > IF CR  \ Diagnostic message,
\ ."   from whatAuxSDo after speaking of DO, psiDamping concept #59 DO"
\ THEN
\ 59 urpsi !  \ For use in psiDamp to de-activate the "DO" concept.
\ 42 caller ! \ 13jan2008 whatAuxSDo identified by AI4U page number.
\ psiDamp     \  6aug2005 As when verbPhrase has sent a verb to Speech.
\ 0 caller !  \ 13jan2008 Reset caller-ID for safety.
  psiDecay    \ Reduce unresolved activation on ignored concepts.
;  \ 1sep2008 End of whatIs; return to ASK.

:  GusRecog  ( gustatory recognition robot mind-module stub )
  ( See http://ai.neocities.org/GusRecog.html )
  ( See http://mind.sourceforge.net/gusrecog.html )
;   \ 2018-07-09: GusRecog will return to the Sensorium mind-module.

:  OlfRecog  ( olfactory recognition robot mind-module stub )
  ( See http://ai.neocities.org/OlfRecog.html )
  ( See http://mind.sourceforge.net/olfrecog.html )
;   \ 2018-07-09: OlfRecog will return to the Sensorium mind-module.

:  TacRecog  ( http://ai.neocities.org/TacRecog.html )
  755 haptac !  \ 2019-11-05: a default value of 755=SOMETHING
  hap @  1 = IF  551 haptac ! THEN  \ 2019-11-05: identifier of noun 551=ONE
  hap @  2 = IF  582 haptac ! THEN  \ 2019-11-05: identifier of noun 582=TWO
  hap @  3 = IF  583 haptac ! THEN  \ 2019-11-05: identifier of noun 583=THREE
  hap @  4 = IF  544 haptac ! THEN  \ 2019-11-05: identifier of noun 544=FOUR
  hap @  5 = IF  545 haptac ! THEN  \ 2019-11-05: identifier of noun 545=FIVE
  hap @  6 = IF  566 haptac ! THEN  \ 2019-11-05: identifier of noun 566=SIX
  hap @  7 = IF  577 haptac ! THEN  \ 2019-11-05: identifier of noun 577=SEVEN
  hap @  8 = IF  588 haptac ! THEN  \ 2019-11-05: identifier of noun 588=EIGHT
  hap @  9 = IF  559 haptac ! THEN  \ 2019-11-05: identifier of noun 559=NINE
  hap @ 10 = IF  590 haptac ! THEN  \ 2019-11-05: identifier of noun 590=ZERO
  haptac @ 0 > IF  \ 2019-11-05:
    701 actpsi !  \ 2019-11-05: activate 701=I as a self-aware subject.
    823 actpsi !  \ 2019-11-05: activate 823=FEEL as a verb of sentience.
  THEN  \ 2019-11-05: end of test for positive haptac
;   \ 2019-11-05: TacRecog returns to Sensorium or EnVerbPhrase.
\
:  VisRecog  ( http://ai.neocities.org/VisRecog.html )
\ The visual recognition module of MindForth AI for robots
\ when fully implemented will serve the purpose of letting
\ AI Minds dynamically describe what they see in real time
\ instead of fetching knowledge from the AI knowledge base.
  svo4  @ 0 = IF  \ 2016aug31: if no direct object is available;
    midway @  t @  DO  \ 2016aug31: search for an automatic default
      I       1 psy{ @  760 = IF  \ 2017jun143: 760=NOTHING
        I     6 psy{ @  nphrpos !   \ 2017-09-01: set for EnArticle.
        I    20 psy{ @  aud !       \ 2019-09-29:  hold address for Speech
        LEAVE       \ 2016aug31: one engram is enough.
      THEN          \ end of test for concept # 760=NOTHING
    -1 +LOOP      \ 2016aug31: end of backwards loop
  THEN    \ end of test for subject-verb-object item #4
; \ 2019-09-30: VisRecog returns to Sensorium +/- NLP generation modules.
))
\
\ ***************************************************************************************
\
: Pre-Seq \ FJR 101031
\ called from Parser. Original code in Oldconcept and Newconcept removed
\ Connects N-V-O
\
fyi @ 1 and  IF s" :Pre-Seq Entered"  diagnostic-window Then
pos @ dup 5 = swap 	\ noun
      dup 7 = rot or	\ pronoun
      swap 8 = or	\ verb
IF   \ Process only nouns pronouns or verbs
  urpre @ pre !
  psi   @ urpre !
  pre   @ 0= IF 0 seq ! Else psi @ seq ! Then
  seq   @ prev-conct @ >psi{ seqo w!
  T @ prev-conct !
Else \ Ignore concepts not nouns pronouns or verbs
  0 pre !
  0 seq !
Then
fyi @ 1 and  IF s" :Pre-Seq Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: audrecog ( Addr N H# --  ) \ Updated 230226 FJR
fyi @ 1 and  IF s" :audrecog" diagnostic-window Then
\
\ Compare Hash Value on stack with array of hash values stored
0 t1 ! 0 to hit-flag
hash-count 1
Do
  dup hash{ hash-size i get-addr hashv @ =
  IF i to hit-flag ( ." Hash Value Found @ " hit-flag . cr ) Leave
 Then \ save hash array element # in hit-flag
Loop
\
\ Leaves Hash # on stack
hit-flag        \ Got a match in Hash Array ?
 IF
  hit-flag 0 T @ 0 to hit-flag
  Do            \ locate concept in Aud{ array
    dup aud{ aud-size I get-addr hashkey w@ =
    \ Drop the hash array element #, get nen, save I = recall vector and leave Loop
    IF i dup to hit-flag dup >en{ neno W@ psi ! t1 ! drop leave Then
  -1 +Loop
  hit-flag 0= IF drop Then
 Then
\
fyi @ 1 and  IF s" :audrecog exited" diagnostic-window Then
;
\
\ ********************************************************************************
\
: Adj-ing ( Adr, L -- ) \ FJR Updated 071016
\ Test for a base verb
fyi @ 1 and  IF s" :Adj-ing Entered" diagnostic-window Then
3 - \ drop 'ing' from end of word
2dup -1 "#Hash audrecog
hit-flag
IF 3drop
Else
    ms@ think-timer !
    ( process - ask question )
    C# pov !
    s" IS " Mind-output-buffer swap cmove
    2 pick 2 pick Mind-output-buffer zcount + swap cmove
    s"  A VERB ? " Mind-output-buffer zcount + swap cmove
    Mind-output-buffer zcount 2dup diagnostic-window type
    Paint: Main-Window#  winpause
\
    ( Mind-output-buffer 64 erase )
    0 to keyb-in
    2 to QFlag
    3drop
Then
fyi @ 1 and  IF s" :Adj-ing Exited" diagnostic-window Then
;
\
\ *******************************************************************************
\
: Test-Adj-Adv ( Updated FJR 071012 )
\ Test to see IF new word is Adjective or adverb
\
fyi @ 1 and  IF s" Test for Adj & Adverb "  diagnostic-window Then
start-of-word len @
	2Dup 3 - + 3 s" FUL"    compare 	IF 1 pos ! 2drop exit Then \ Adjective
	2Dup 4 - + 4 s" LESS" compare	IF 1 pos ! 2drop exit Then
	2Dup 3 - + 3 s" BLE"    compare	IF 1 pos ! 2drop exit Then
	2Dup 2 - + 2 s" IC"        compare	IF 1 pos ! 2drop exit Then
	2Dup 4 - + 4 s" ICAL"   compare	IF 1 pos ! 2drop exit Then
	2Dup 3 - + 3 s" ING"     compare	IF 1 pos ! Adj-ing exit Then
	     2 - + 2 s" LY"             compare 	IF 2 pos ! Then \ Adverb
;
\
\ *******************************************************************************
\
: Test-Plural ( Updated 101031 FJR ) \ Called from : NewConcept
\ Is the noun singular or plural? Look for 'S' on end of new words only.
\
fyi @ 1 and  IF s" Test for Plural"  diagnostic-window Then
\
0 to pos-flag
fyi @ t @ len @ 0 \ Save values that will change set Flag = 0
3 fyi !
start-of-word len @
1- + 1 s" S" strcmp \ search word (only New Concepts) to see if it end with an 'S'
  if
    fyi @ 2 > if s" Plural Noun Identified (-s)." diagnostic-window then
    drop -1 dup len +! dup t +! \ -1 = Flag reduce value of T
  then
\
 if  \ Flag set calc new CRC
\
  plural to pos-flag
\  crc @ ascii S - crc ! \ Calc new CRC - Subtract out the Value of 'S' from CRC

\ calc new hash value for search
  dup 1- start-of-word swap -1 "#hash \ Calc Hash Value
  audrecog \ see if the root is in the dictionary
  drop \ Hash Value
  hit-flag \ Hit-Flag set -1 if a match is found for singular form of noun
  if
  \ T1 hold location of word found
   t1 @ dup
   en{ gendero  c@ to gender dup	\ retrieve gender of base word 070204
   en{ glbo     c@ to GlbDom 		\ retrieve Global Domain
   en{ neno W@ psi ! 			\ t @ aud{ psio W! \ set aud{ psio to nen of base word
  then
\
then
\
\ restore all values
0 to hit-flag
len ! t ! fyi !
\ Return to New-Concept
;
\
\ *******************************************************************************
\
: PARSER (   ---   )
\ determine the part of speech  atm 14oct2005
\ Called from oldConcept or newConcept Changes by FJR 070325
\ to help the Artificial Mind comprehend verbal input by properly
\ assigning associative tags with flags.
\ The "bias" has no control over recognized oldConcept words.
\
fyi @ 1 and  IF s" :PARSER"  diagnostic-window Then
\
\ New code to identify the part of a sentence for new concepts
concept		\ 0 = old , -1 = new
IF  test-adj-adv Then 	\ Only IF New Concept Limited Test for Adjectives or Adverbs
\
 uract @ dup 1- uract ! act !
 Pre-Seq	        \ Sets the Pre and Seq values to be loaded by Instantiate
 INSTANTIATE 	\ Create a new instance of a Psi concept.
\
 \ After a word is instantiated, expectations may change.
 \ Recognitions and expectations are pos-code terminants.
\
 pos @ case
	1 of 5 endof \ Noun follows adjective
	2 of 8 endof \ Verb follows adverb
	3 of 5 endof \ Noun follows conjunction ????? need a fix here can be 2 verbs
	4 of 5 endof \ Noun follows interjection
	5 of 8 endof \ Verb follows Noun
	6 of 5 endof \ Noun follows preposition
	7 of 8 endof \ Verb follows Pronoun
	8 of 5 endof \ Noun follows verb
	9 of 8 endof \ Verb follows Names
	10 of 5 endof \ Noun follows Acknowledgements
	11 of 5 endof \ expect a noun after use of a symbol
	12 of 5 endof \ expect a noun after use of a number
	15 of 5 endof \ expect a noun after use of an executable word
       endcase
\
 bias !
 psi @ dup jux !
 296 = \ Does it = "NOT" Concept
 IF -1 to juxflag Then \ For the next time around not now.
\
fyi @ 1 and  IF s" :Parser Exited"  diagnostic-window Then
\
; \ End of Parser; return to oldConcept or newConcept.
\
\ ********************************************************************************
\
: OLDCONCEPT (   ---   )
\  recognize a known word  atm 5jun2006 Updated 230510 FJR
\ Called from Pho=32 to create a fresh concept-node for a recognized input word.
\
fyi @ 1 and  IF s" :OldConcept Entered" diagnostic-window Then
\
 24 act @ max act !
\ 100606 FJR Build up in trade-off with psiDecay. Keep larger of values aud for 'am & are'
POV @ C* =
    IF
psi @ case  \ updated 230508 PSI holds NEN & Hit-Flag holds AUD Vector
	1         of YOU psi ! YOU to hit-flag      endof   \ Change I ( I = 1 ) to You
	ME     of YOU psi ! YOU to hit-flag      endof   \ Change Me to You
	MY      of YOUR psi ! YOUR to hit-flag endof   \ Change My to Your
	YOU    of 1 psi ! 1 to hit-flag                  endof   \ Change You to I
	YOUR of MY psi ! MY to hit-flag            endof   \ Change Your to My
      endcase
    Then
\
	hit-flag >en{ fexo W@ fex !   \ retrieve the fiber-out flag.
	hit-flag >en{ poso C@ pos ! \ So as to parse by word-recognition,
	hit-flag >en{ gendero C@ to gender
	hit-flag >en{ S-PO C@ to pos-flag
	hit-flag >en{ glbo c@ to glbdom
	hit-flag >en{ fino W@ fin !
	hit-flag >aud{ hashkey w@ t @ >aud{ hashkey w!
	T @ aud !
\
NEN @ PSI @ NEN ! ENVOCAB NEN ! -1 T +!
\
 pov @ C# = IF fex @ psi ! THEN \ during internal (#) "pov";
 pov @ C* = IF fin @ psi ! THEN   \ external (*) "pov"
 psi @ enx ! \ Assume Psi number = En(glish) number.

pov @ C* = \ Test IF Human user has asked a question
IF
psi @ case
 	11      of 11 to question        endof \ Subactivate auxiliary "do = 11".
	How   of How to question    endof \ Subactivate question "how"
        378    of     1 act !                 endof \ 25aug2008 Article "the = 378"
	What  of What to question   endof \ Subactivate question "what".
	When of When to question  endof \ Subactivate question "when"
	8         of 8 to question         endof \ Subactivate question "where = 8"
	Who   of Who to question    endof \ Subactivate question "who".
	Why   of Why to question     endof \ Subactivate question "why"
      endcase
Then
\
 PARSER \ Determine the part-of-speech "pos".
 0 pos ! 0 to pos-flag \ Reset the part-of-speech "pos" flag.
\
 pov @ C* =
 IF \ 5jun2006 Only activate external input
    2 to actv Activate \ Re-activate recent nodes of the concept.
 THEN \ 5jun2006 Internal mode calls superAct direcly.
\
 \ Reset for safety.
 neuter to gender
 singular to pos-flag
 0 to glbdom
\
fyi @ 1 and  IF s" :OldConcept Exited" diagnostic-window Then
\
; \ End of OLDCONCEPT; return to AUDITION.
\
\ ********************************************************************************
\
: NEWCONCEPT ( Addr Len Hashv -- )
\ machine learning of new concepts atm 13jun2006 updated 080830 FJR
\ Called from AUDITION when the AI Mind must learn the concept of a new word.
\
fyi @ 1 and  IF s" :NewConcept Entered" diagnostic-window Then
 t @ aud !
 hash-count >hash{ hashv !
 0 swap rot swap 2dup \ duplicate the addr and length
 dictionary dict-offset + swap cmove
 dict-offset hash-count >hash{ dict-loc !
 len @ dup hash-count >hash{ wleno c!
 +to dict-offset
 hash-count t @ >aud{ hashkey !
 pov @ T @ >aud{ povo c!
 1 +to hash-count -1 to hash-sort \ set flag to indicate hash-table is in need of sorting
 36 act ! \ 6aug2005 For greater SVO assertion of new concepts.
 bias @ pos ! \ Expectancy for Parser module.
\
 pos @ 5 = IF test-plural Else 0 to pos-flag Then  \ Test IF new noun is singular or plural
 pos-flag  \ IF flag not set use exisiting values
  IF
    nen @ psi @ nen !
  Else
    singular to pos-flag
    1 nen +! nen @ \ Increment "nen" beyond English bootstrap concepts.
  Then
\
 nen @ dup
 psi ! 	   \ Let psi & n(umeric) En(glish) have same identifier.
 dup fex ! \ Let f(iber)-ex also have the same numeric identifier.
 dup fin ! \ Let f(iber)-in a;so have the same numeric identifier.
     enx ! \ Set the transfer-to-English "enx" flag.
\
 PARSER  \ Determine the part-of-speech "pos", Then instantiate.
 enVocab \ Create an ENglish vocabulary node
 -1 T +! \ Envocab advances T
 nen !   \ restore Nen
 0 fex ! \ blank the fiber-out flag why ?
 0 fin ! \ blank the fiber-in flag why ?
\
 pos @ 5 = pos-flag singular = and
 IF 		 \ 070507 FJR If a new noun is encountered and it is not plural form...
   1 recon !     \ recon set to ask questions.
   nen @ topic ! \ 4aug2002 hold onto the noun as a "topic".
 THEN
\
 neuter to gender
 singular to pos-flag
 0 to glbdom
 over
\
 1 IQ +! \ Increment IQ for each new concept learned
\
fyi @ 1 and  IF s" :NewConcept Exited" diagnostic-window Then
\
; \ End of NEWCONCEPT; return to AUDITION.
\
\ ********************************************************************************
\
: num-eval ( addr n V --- )
fyi @ 1 and  IF s" :num-eval"  diagnostic-window Then
rot rot
2dup (number?) \ N 0 Flag
IF
   drop dictionary dict-offset + !
   dict-offset t @ >en{ fexo  W!
   12 T @ >en{ poso c!
   neuter T @ >en{ gendero c!
   4 +to dict-offset \ 3drop 0
   s" Number identified " ( 2dup type) diagnostic-window
   2dup 2dup type cr diagnostic-window
   rot 0
Else 2drop rot -1
Then
fyi @ 1 and  IF s" :num-eval exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: Pho=32  ( address n hashvalue -- )   \ FJR Updated 200829
\ Upon identification of a SPACE retroactively adjust end of word.
fyi @ 1 and  IF s" :Pho=32 Entered" diagnostic-window Then
	t @ 1- tult ! \ The last previous time is "t-ultimate".
	audrecog
	psi @
		IF ( drop hash-value ) 	\ If audRecog & audSTM provide positive psi,
			0 to concept 	\ Tell parser old concept found
			OLDCONCEPT 	\ Create a new node of an old concept;
			\
			\ If Old and a Pos = 10 = Affirmation Then need to further process
			\
		Else \ If there is no psi-tag "psi";
                        num-eval \ returns -1 IF not a number and 0 IF a numeric was found
                        IF
			  len @
			  IF \ IF the incoming word has a positive length,
			    -1 to concept \ Tell parser new concept found
			    NEWCONCEPT    \ to create a new node of a new concept;
			  Else drop ( hash-value )
			  Then \ end of test for a positive-length word;
			Then
		Then \ end of test for the presence of a move-tag;

	 0 len ! \ zero out the length
	 0 aud ! \ Zero out the auditory "aud" recall-tag.
	 0 psi ! \ Zero out for all concepts
	 0 to hit-flag
	 1 word-count +! \ Increment word counter
fyi @ 1 and  IF s" :Pho=32 Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: Punctuation ( -- ) \ FJR 230518 \ Check for punctuation at end of sentence
fyi @ 1 and  IF s" :Punctuation Entered" diagnostic-window Then
0 to punc
human-input-buffer zcount 1- + dup c@
Case \ If Found replace with a space for the time being
   exclm-pt 	     of 32 swap c! 1 to punc endof ( Exclamation point found )
   period	  	     of 32 swap c! 1 to punc endof ( period found )
   question-mark of 32 swap c! 1 to punc endof ( question mark found )
Endcase
punc 0 = IF drop Else 0 to punc Endif   \ ?????
\ check for space at end of sentence added 200903
human-input-buffer zcount 1- + c@
32 <>
IF
  human-input-buffer zcount  + dup 32 swap c! 1+ 0 swap c! \ add space to end of sentence
Endif
fyi @ 1 and  IF s" :punctuation Exited" diagnostic-window Then
;
\
\ ********************************************************************************
\
: Aud-process ( addr -- ) \ addr = input-buffer \ Called from Aud13/10
fyi @ 1 and  IF s" :Aud13/10-process Entered"  diagnostic-window Then
to start-of-word 0 len !
punctuation
s" Aud-process --- " type start-of-word zcount type s"  --- " type cr
start-of-word
  Begin
   dup c@ 32 = \ Checking for a space as first character
    IF 1+ to start-of-word start-of-word 0
    Else
      zcount s"  " search  \ locate a space
\
    IF
      2dup 2>R
      drop start-of-word -
      dup len ! start-of-word swap
      2dup -1 "#HASH \ T @ >hash{ hashv !
      pov @ T @ >aud{ povo c!
      word-count @ IF 0 T @ >aud{ stov c! Then
      Pho=32 ( addr N Hash# ) drop  cr diagnostic-window \ display word
      2r> 1- swap 1+ dup to start-of-word swap not
      1 T +!
     Else -1
     Then \ End of space search
    Then \ End of space check
\
  Until
\
  drop
  0 word-count !
  0 len !
 fyi @ 1 and  IF s" :Aud-process Exited" diagnostic-window Then
;
\
\ ********************************************************************************
\
: Word-execution
s" Word-execution Entered"  diagnostic-window
\
\ pho = Char46 = '.' = period ( NEN 25 )
\ Idea is to execute the word in the human-input-buffer
\ Direct access to mind subroutines
\
human-input-buffer zcount ['] evaluate catch \ execute word in buffer
IF
     2drop \ failed to execute
     cr ." Execution of instructions FAILED"
Then
cr  ." Temporary Wait Press any key to continue --- "
Wait cr ." Continue" cr
GLT
22 diagnosticw-loc !
s"  - Word-execution called. " human-input-buffer zcount + swap cmove human-input-buffer zcount
>LogFile
\
human-input-buffer zcount 0 fill
C# pov ! \ 25jul2002 Set "pov" to "internal".
0 to word-exec
0 pho !
ms@ 60000 + inert !             	        \ reset inert timer
securitycycle @ to time-delay-cycle 	\ reset with existing cycle count
ms@ 60000 + to delay-cycle-time     	\ reset delay
\
s" Word-execution Exited"  diagnostic-window
false to word-exec
;
\
\ ***************************************************************************************
\
((
: LISTEN
\
\ preparation for Audition FJR Updated 080223
\ gather and preprocess all keyboad input
\
fyi @ 1 and  IF s" Listen Entered"  diagnostic-window Then
\
    0 to QFlag   \ reset Question flag IF input is being received
    pho @
    -if  ( dup IF )
	 case
		 9 of ( Tab-key-process) endof 	\ TAB
		10 of ( LF linefeed ) endof \ LF = 0aH
		13 of ( s" CR-Key-Entered" type cr) ( CR-Key-Entered)  endof 	\ CR
		27 of ( Esc-key-pressed) endof 	\ Esc
		46 of True to word-exec   endof	\ A Period
	 endcase
\
    Else drop ms@ keyb-time ! \ Pho = 0 Special Key processing occured
    Then \ end of checking for Pho > 0
\
fyi @ 1 and  IF s" Listen Exited"  diagnostic-window Then
\
; \ End of LISTEN; return to AUDITION.
))
\
\ ********************************************************************************
\
: AUD13 \ accept auditory input  FJR Updated 230218
\ Handles the input of ASCII as phonemes from USER
\
fyi @ 1 and  IF s" Aud13 Entered" diagnostic-window Then
\
 t @ nlt !
\
	\ New code for processing words in Human Input Buffer
	#aud13 \ CR-Key-Entered  --  Flag set true on receipt of Enter Key
	IF   s" Audition Pho = 13 " diagnostic-window
	\ Check to see if 1st character in buffer is a '.'
	human-input-buffer c@ C. = IF True to word-exec Else False to word-exec Then
	word-exec \ IF word-execution flag is raised Do not continue to process buffer
	   IF word-execution
	   Else
		s" Processing ---  " diagnostic-window
		5 bias !  \ 26jul2002 To help the Parser module 5 = noun.
		0 pre ! 0 seq ! 0 urpre ! 0 urseq ! \ Initialize values
		T @ 1- prev-conct !
		0 word-count !
\
		  msg31 zcount diagnostic-window  human-input-buffer zcount 2dup diagnostic-window
		  2dup upper  \ Convert to all upper case
		  2dup s" *** " type type s"  *** " type cr \ screen display
\
		  2 > \ check length is > 2 bytes
		 IF
		  c[ t @ >aud{ stov C!	\ 166 is ASCII bracket '[' Human input identifier
		  t @ to SOLV
		  Aud-process winpause
		  True to Timer1flag 5000 to think-delay \ reset think timer
		 Else drop
		 Then
\
		  human-input-buffer zcount erase
		  null pho !  \ Prevent "pho" from reduplicating.
		  C# pov !   \ 25jul2002 Set "pov" to "Internal".
\
	 Then \ end of test for word-execution flag - process of buffers
\
	Then \ end of test Pho = 13
	False to #aud13
\
 fyi @ 1 and  IF s" Aud13 Exited" diagnostic-window Then
;
' Aud13 is Aud13#
\
\ ********************************************************************************
\
: AUD10 ( Addr L -- )
( accept auditory input ) \ FJR Updated 230218
\ Handles the input of ASCII as phonemes from AI-Mind
\
fyi @ 1 and  IF s" Aud10 Entered" diagnostic-window Then
\
 t @ nlt !
\	PHO = Lf = 0ah = 10
	#aud10 \ End of line of Mind thought  Mind thought ends with a line feed, 0ah not a CR 13h
	IF
		  s" Audition PHO = 0Ah " diagnostic-window
                  Mind-output-buffer zcount 0>
		  IF
		  \ dup zcount + 1- swap
		  c{ t @ >aud{ stov C!	\ 123 is ASCII brace '{' AI input
		  t @ tov ! 		        \ set the time of the new voice input = present time
		  dup zcount msg32 zcount diagnostic-window diagnostic-window
		  Aud-process winpause
		  \ False to Timer2Flag
		 Else Drop
		 Then
\
      \ Locate call to generate text to speech at this point ( 101228 )
                 ( Mind-output-buffer aispeech IF AI-Speech Then )
		  Paint: Main-Window#
		  winpause  \ Mind-output-buffer zcount erase
		  0 to juxflag
		  C* pov !    \ 200911 Set POV to "external".
		  null pho ! \ Prevent "pho" from reduplicating.
\
\		Then \ end of test POV = Mind
\
	Then \ end of test Pho = 0ah
\
	0 T @ 1- >psi{ seqo w! \ Closes out the last concept so there is no sequel concept
	5 bias ! \ restore for next input of a noun
	0 pho ! \ Prevent "pho" from reduplicating.
\
 False to #aud10
 fyi @ 1 and  IF s" Aud10 Exited" diagnostic-window Then
\
; \ End of AUDITION; return to SENSORIUM or SVO1.
' Aud10 is Aud10#
\
\ ********************************************************************************
\
: psiDecay ( --- ) \ Last Updated 230507
( let conceptual activations dwindle atm 13 Jun2006
 Updated 101031 FJRusso
 Called mainly from the SECURITY module to make all positive non-zero mindcore psi1 activations
 decrease slightly, so as to simulate neuronal excitation-decay for the purpose of letting stray
 activations dwindle away over time.
 Thinking keeps activations high; psiDecay lowers them.
 In a robot mind with an upper tier of activation for concepts riding a moving wave of consciousness,
 psiDecay lets afterthought concepts sink gradually through a lower tier of residual activation. )

 fyi @ 1 and  IF s" :PSIDecay Entered" diagnostic-window Then
\
t @ eod >
IF
T @ EOD
DO \ Loop thru recent time.
 I >psi{ psio W@
 -if ( 0> )
   I >psi{ acto w@ 1- dup 0<
   IF drop 2 Then
   I >psi{ acto w! \ 230507

 \ 21sep2005 Next line of active code zeroes out the
 \ concepts so that question elements will not linger.

      Case ( I psi{ psio W@ )
	11 of 0 I >psi{ acto w! endof \ Zero out DO
  	How of 0 I >psi{ acto w! endof \ Zero out how
	What of 0 I >psi{ acto w! endof \ Zero out what
  	When of 0 I >psi{ acto w! endof \ Zero out when
	8 of 0 I >psi{ acto w! endof \ Zero out where
	Who of 0 I >psi{ acto w! endof \ Zero out who
	Why of 0 I >psi{ acto w! endof \ Zero out why
      Endcase

   decpsi1 @ decpsi2 @ =
   IF \ Hasten deactivation of repeats:
    I >psi{ acto w@ 8 - dup 0<
    IF drop 0 Then
    I >psi{ acto w! \ 20apr2006
   THEN \ 20apr2006

 Else drop

 Then \ end of test for psio > 0

LOOP \ end of finding and reducing positive activations
Then
\
fyi @ 1 and  IF s" :PSIDecay Exited" diagnostic-window Then
\
;
\
\ ********************************************************************************
\
: psiDamp ( --- )
( reduce activation of a concept  \ atm 20apr2006
Called from nounPhrase or verbPhrase to semi-activate a concept that was
briefly activated. )
\
( 13jun2006 Do not lower post-thought activations too far.
   31mar2007 residuum LUMP and its value come from JSAI. )
 20 lump !
\
fyi @ 1 and  IF s" :PsiDamp Entered" diagnostic-window Then
(
fyi @ 2 and
IF \ Too detailed for Tutorial mode.
   s" PSIDamp for urpsi = " display-buffer swap cmove
   urpsi @ tempspace >string tempspace count display-buffer zcount + swap cmove
   s"  and lump = " display-buffer zcount + swap cmove
   lump @  tempspace >string tempspace count display-buffer zcount + swap cmove
 display-buffer zcount diagnostic-window
THEN
)
\
T @ EOD
DO \ Loop backwards.
 I >psi{ psio W@ urpsi @ =
 IF \ If psi0 is found,
 lump @ I >psi{ acto w!
 THEN \ Set in psiDamp or in calling module.
LOOP \ End of backwards loop.
\
 0 lump ! \ 15sep2005 safety measure
 psiDecay \ 21sep2005 For the sake of the Moving Wave Algorithm.
\
fyi @ 1 and  IF s" :PSIDamp Exited" diagnostic-window Then
\
; \ psiDamp returns to nounPhrase, verbPhrase, etc.
\
\ ********************************************************************************
\
: EnDamp ( deactivate English lexicon concepts ) \ atm 14oct2005
\ Called from nounPhrase and verbPhrase to de-activate all concepts in the English lexicon.
\ Updated FJR 080120
fyi @ 1 and  IF s" :EnDamp Entered" diagnostic-window Then
\
T @ EOD
DO
    0 I >en{ acto w! \ Store zero en{ acto.
LOOP
\
fyi @ 1 and  IF s" :EnDamp Exited" diagnostic-window Then
\
; \ enDamp returns to nounPhrase or verbPhrase.
\
\ ********************************************************************************
\
(( : audDamp ( deactivate auditory engrams ) \ FJR 230222
(  audDamp is called from AUDITION upon recognition of  a known word, and resets auditory
 engram activations  to zero so that additional words may be recognized. )
fyi @ 1 and  IF s" audDamp Entered" diagnostic-window Then
   EOD  T @
   DO    \ Loop backwards through time.
        0 I  >aud{ !      \ Replace excitation with zero.
   -1 +LOOP
fyi @ 1 and  IF s" audDamp Exited" diagnostic-window Then
;  \  end of audDamp; return to AUDITION. ))
\
\ ********************************************************************************
\
: REIFY  ( -- ) \ Updated 230227 FJR
(  Express abstract concepts as real words atm 14oct2005 updated 070428 FJR
 Called by nounPhrase or verbPhrase to flush abstract Psi concepts into the real names of English
 language reality. )
\
fyi @ 1 and  IF s" :REIFY Entered" diagnostic-window Then
\
\ Move all positive concepts with any activation to the en{ array
\
Midway T @
Do
	PSI{ psi-size I get-addr acto w@
	-IF
	 EN{ en-size I get-addr acto w!
	Else drop
	Then
-1 +LOOP
\
0 act ! 		\ Reset the act(ivation) level.
\
fyi @ 1 and  IF s" :REIFY Exited" diagnostic-window Then

; \ End of reification; return to nounPhrase or verbPhrase.
\
\ ********************************************************************************
\
: NounPhrase ( --- ) \ nounPhrase is called by SVO and verbPhrase.
( select part of a thought a subject or an object atm 10jun2006  Updated FJR 230227)
\
fyi @ 1 and  IF s" :Nounphrase Entered"  diagnostic-window Then
\
 REIFY ( to move abstract Psi concepts to enVocab reality )
\
 0 act !        \ Start with a zero ACTivation level
 0 jolt !
 0 aud !        \ Start with a zero auditory recall-tag.
 0 motjuste !
 0 psi !        \ Start with a zero Psi concept tag.
\
EOD SOLV 2dup =
IF 2drop
Else 1-
DO \ Search from current time to End of Dictionary
 I >en{ poso C@ dup bias @ = swap opt @ = or \ Can select Nouns or Pronouns
\
 IF
   I >en{ acto w@ act @ >
\
   IF
     I >en{ neno W@ motjuste ! 	\ get Nen of the concept.
     I aud ! 					\ Save auditory recall-vector.
     I >en{ acto w@ act ! 		\ Save to test for a higher en{ acto.
   THEN 						\ end of test for higher en{ acto.
\
 THEN 				\ end of if-clause checking for nouns & pronouns.
\
-1 +LOOP 			\ end of Loop searching for most active noun or pronouns.
Then
\
 EnDamp 			\ zero all en{ acto
\
 Motjuste @ NOT \ =0 No selection made FJR 230227
 IF \ 7jun2006 If no highly active noun is found...
    408 Nen-Search 	\ Call interrogative pronoun "what":
   IF 			\ If #408 "what" is found,
      408 motjuste ! 	\ "nen" concept #408 for "what".
      aud !
   THEN \ End of search for #408 "what".
\
\  Exit \ Do not say the low-activation noun.
\
 THEN \ 31aug2005 End of test for activation threshold.
\
 motjuste @ psi !   \ 1jun2006 For use in Activate module.
 act @ jolt ! 		\ 7jun2006 So nounAct activates all nodes equally.
 0 to actv Activate  \ nounact 7jun2006 To impart a winning activation equally.
 0 jolt ! 			 \ 7jun2006 Safety measure after use of jolt.
\
 psiDamp \ to de-activate Psi concepts                  080308
\
 motjuste @ topic !     \ Hold for possible question
 0 act ! \ Reset for safety.
 0 psi ! \ 26jul2002 Reset for safety.
\
fyi @ 1 and  IF s" :NounPhrase Exited"  diagnostic-window Then
\
; \ End of nounPhrase; return to SVO or verbPhrase.
\
\ ********************************************************************************
\
: Verbphrase (  --  ) \ Updated 230227 FJR
fyi @ 1 and  IF s" Verbphrase Entered"  diagnostic-window Then
\
 REIFY \ move abstract Psi concepts to enVocab reality
\
 0 act !                \ precaution even though zeroed in REIFY
 0 aud !                \ Start with a zero auditory recall-tag.
 0 motjuste !
 8 opt !                \ Look for option eight a verb
 0 psi !                \ Start with a zero Psi associative tag.
 8 Bias !
 0 Len !
 0 aud !
 0 to verb
 0 to verb-object
\
EOD SOLV 2dup =
IF 2drop
Else 1-
 DO 			\ Search backwards through enVocab
 en{ en-size I get-addr poso C@ 8 = 	\ only look at predicate/verbs POS = 8
\
 IF
 en{ en-size I get-addr acto w@ act @ >
\
  IF
      en{ en-size I get-addr neno W@ motjuste !  \ store psi-tag of verb
      I aud !                   \ en{ audo W@  auditory recall-vector
      en{ en-size I get-addr acto w@ act !       \ to test for a higher en1
  THEN          \ end of test for en{ highest above zero.
\
 THEN           \ end of test for opt=8 verbs
\
 -1 +LOOP       \ end of Loop cycling back through English lexicon
Then
\
 motjuste @ \ 0>
 IF \ 15sep2005 Prevent aud-0 of spurious "YES".
\
\ Check for use of 'AM 59'
\
	 motjuste @ 59 = \ = 'am'
	 IF
	  Subject >en{ neno W@ 276 ( 50) <>
	   IF 221 motjuste ! 221 nen-search drop aud ! Then \ replace with 'is'
	 Then
\
\ Checking subj and verb are in agreement IF 'is' or 'are' used
\
 motjuste @ 221 = \ = 'is'
    IF
	 aud @ >en{ S-PO c@ spo-state = not
	 IF 70 motjuste ! 70 nen-search drop aud ! Then \ IF plural Then use 'are'
    Else
	 motjuste @ 70 = \ = 'are'
	 IF
	  aud @ >en{ S-PO c@ spo-state = not
	   IF 221 motjuste ! 221 nen-search drop aud ! Then \ IF singular Then use 'is'
	 Then
    Then
\
 motjuste @ psi ! \ 10jun2006 For use in New-Act module.
 act @ 15 >
 IF
  1 to actv Activate \ For slosh-over of subj+verb onto object.
  aud @ to verb
  motjuste @ urpsi !     \ For use in psiDamp.
  22 lump !              \ Trying to let spike win over residual activation.
  psiDamp                \ 29apr2005 Necessary for chain of thought.
  subject >en{ psio w@ urpsi !
  psiDamp
  2 lump !               \ 28aug2005 Restore minimal psiDamp value.
\
  enDamp \ to de-activate English concepts
\
  15 lump !  \ 17sep2005 Give direct objects higher lump than subjects.
  1 dirobj ! \ 14sep2005 Declare seeking of a direct object.
\
  5 dup bias ! opt ! \ select only Nouns no pronouns
  nounPhrase \ To express direct object of verb,
  aud @ to verb-object
\
 Else
 0 aud ! psiDamp enDamp
 THEN  \ End of check for activation above 15 080309
THEN \ 15sep2005 End of test for motjuste > 0.
\
 0 dirobj ! \ 14sep2005 No longer seeking a direct object.
 2 lump ! \ 28aug2005 Restore minimal psiDamp value.
\
fyi @ 1 and  IF s" Verbphrase Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: Verbclip ( lower activation on all verbs ) \ 30jan2008
fyi @ 1 and  IF s" verbclip Entered"  diagnostic-window Then
\
\ verbClip is a module that clips activation on verbs down to
\ a subconscious level when the Audition module starts to process
\
t @  EOD
  DO     \  Loop in recent time.
    I >psi{ poso C@ 8 =
    IF I >psi{ acto w@ 20 >   \ 30jan2008 If activation is high... > 20
       IF 20 I >psi{ acto w! THEN \ set activation = 20
    Then
  LOOP  \ Loop looking for pos=8 verbs.
winpause
\
fyi @ 1 and  IF s" verbclip Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: verbClear (  --  ) \ remove activation from all verbs ) \  230227 FJR Updated
\ verbClear is an attempt to let subject-nouns activate only
\ truly associated verbs because all verbs are at zero activation.
\ The end of SVO calls verbClear so that user-input may still
\ activate a verb before the AI Mind responds to the user input.
  Midway  T @
  DO     \  Loop backwards in recent time.
     psi{ psi-size I get-addr dup poso c@ 8 =
     IF  \ 24aug2008 Moving "pos" over by one.
        acto 0 swap W!    \ 230227 Set verbs to zero activation.
     Else Drop THEN  \ 2apr2007 End of test for pos=8 verbs.
  -1  +LOOP  \  End of backwards loop looking for pos=8 verbs.
;  \ End of function verbClear.
\
\ ********************************************************************************
\
: conjoin ( -- )
fyi @ 1 and  IF s" conjoin Entered"  diagnostic-window Then
((
\
\ Called from English
\ Conjoin selects a hopefully appropriate conjunction and allows the AI to answer a question
\ with a statement, under the assumption here that the thinking of the AI will tend to
\ display a modicum of explanatory logic.
\
fyi @ 1 and  IF s" :Conjoin Entered" diagnostic-window Then
\
\ Section below revised 100501 Not fully implemented
question case
	11 of 11  endof \  question "how"
	14 of 14  endof \  question "when"
	15 of 15  endof \  question "where"
	16 of 18  endof \  question "why"  leaves pointer to 'because' Revised 100501
 	54 of 54  endof \  question "what".
	55 of 55  endof \  question "who".
      endcase
\
 dup conj !
 dup motjuste !  \ "nen" concept for conjunction;
 nen-search
 IF aud ! Else drop Then   \ Recall-vector for conjunction.
 2 EEG +!        \ Answering a question is a bump of 2 to the EEG
\
\ Then
\ -----------------
 s" A question has been asked of the AI" human-input-buffer swap cmove
 s"  Question = " human-input-buffer zcount + swap cmove
 question nen-search
 IF
   0 0 sentproc1 mind-input-buffer zcount
 Else
   drop question tempspace >string
   tempspace count
 Then
 human-input-buffer zcount + swap cmove
 human-input-buffer zcount
 2dup
 workfile-buffer zcount erase
 log-file-write
 diagnostic-window
 human-input-buffer zcount 0 fill
 mind-input-buffer zcount 0 fill
 0 to question  \ Reset after any use.
\
fyi @ 1 and  IF s" :Conjoin Exited" diagnostic-window Then
\
\ End of Conjoin; return to the SVO module.
\
))
;
\
\ ********************************************************************************
\
: Check-Phrase  ( -- F ) \ Created 230302 FJR Called From Sentence-Proc
\ Checks to see if sentence created has been recently used
\ Locate last AI Voice '{' stov
fyi @ 1 and  IF s" Check-Phrase Enterered"  diagnostic-window Then
T @ to ck-start False to Hit-Flag 0 Counter !
439 T @ Do
	I to ck-start
	aud{ aud-size ck-start get-addr stov c@ 123 =
	IF \ '{' has been located
		en{ en-size ck-start get-addr neno w@ en{ en-size Subject get-addr neno w@ =
		IF \ subjects are same
			en{ en-size ck-start 1+ get-addr neno w@ en{ en-size Verb get-addr neno w@ =
			IF \ verbs are same
				en{ en-size ck-start 2 + get-addr neno w@ en{ en-size Verb-Object get-addr neno w@ =
				IF True to Hit-Flag  ( Objects are same ) Leave
				Else 1 Counter +! Counter @ 10 >= IF Leave Then
				Then
			Else 1 Counter +! Counter @ 10 >= IF Leave Then
			Then
		Else 1 Counter +! Counter @ 10 >= IF Leave Then
		Then
	Then
-1 +Loop
." Check done " 9 emit counter @ . 9 emit ck-start . cr
0 Counter ! Hit-Flag
fyi @ 1 and  IF s" Check-Phrase Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: SentProc1   ( t-nen Address, N --- )
\ 200910 corrected to use the mind-output-buffer and not the human-input-buffer
\
fyi @ 1 and  IF s" SentProc1 Entered"  diagnostic-window Then
\
1 IF
  Temp-Buffer zcount 0 fill
  Temp-Buffer swap cmove
  dup tempspace >string
  tempspace count Temp-Buffer zcount + swap cmove
  Temp-Buffer zcount
  diagnostic-window Temp-Buffer zcount 0 fill
 Else 2drop
 THEN
\
1 counter +!
>aud{ hashkey w@ dup >hash{ wleno c@ swap
>hash{ dict-loc @ dictionary +
swap mind-output-buffer zcount + swap cmove
bl mind-output-buffer zcount + C!
fyi @ 1 and  IF s" SentProc1 Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: Sentence-Proc (  --  ) \ Called from SVO1 Updated 230302 FJR
\
fyi @ 1 and  IF s" Sentence-Proc Entered"  diagnostic-window Then
\
\ Modified 070105
\ Moving word concepts found by AI-Mind to buffer
\
\ Code to check for repeating thought
Counter @ \ save on stack just a safety action
Check-Phrase ( -- F ) \ False = repeating / True = non repeating
swap Counter ! \ restore counter
\
Not IF ( non repeating )
  subject 0> IF subject s" Sentence-Subject. " sentproc1 Then
  auxv 0> IF auxv s" Sentence-auxv. " sentproc1 Then
  negv 0> IF negv s" Sentence-negv. " sentproc1 Then
  verb 0> IF verb s" Sentence-verb. " sentproc1 Then
  verb-object 0> IF verb-object s" Sentence-verb-obj. " sentproc1 Then
Else
Then
\
\ Zero out all sentence items
0 dup to subject dup to verb dup to auxv dup to negv to verb-object
\
fyi @ 1 and  IF s" Sentence-Proc Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: SVO1 (  ---  )  \ updated 230517 Also known as SPEECH
\
fyi @ 1 and  IF s" SVO1 Entered"  diagnostic-window Then
\
\ The AI fills in the next line by generating a thought:
\
subject        >en{ neno w@ old-sub !
verb             >en{ neno w@ old-verb !
verb-object >en{ neno w@ old-obj !
\
Mind-output-buffer zcount erase
Sentence-Proc
Mind-output-buffer zcount
-IF diagnostic-window
	counter @ 2 > \ Do not output thought IF less than 3 concepts generated
		IF
		  0 counter !
		  pho @  \ save in case invoked by input thought
		  Clf pho ! True to #aud10 ( ASCII 0ah LF to trip a retroactive change )
	          0 to word-exec
		  AUD10 pho ! \ restore previous value
		  3000 _MS \ time delay to allow for viewing
		Then
Else 2Drop \ Need to restore old thought if new one not generated
old-sub @ s" Restore Previous Subject " sentproc1
old-verb @ s" Restore Previous Verb " sentproc1
old-obj @ s" Restore Previous Object " sentproc1
Then
\
fyi @ 1 and  IF s" SVO1 Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: SVO ( Subject + Verb + Object ) \ 230221 FJR
\ Called by ENGLISH to fabricate an english sentence.
\ is negated by negSVO it is one structure for an English sentence.
\
 fyi @ 1 and IF s" :SVO Entered"  diagnostic-window Then
\
 17 lump ! 	  \ 17sep2005 Subj. lumps lower than dir. obj. lumps for chains.
 5 bias ! 7 opt ! \ Select nouns or Pronoun
\
 nounPhrase 	( finds a subject - noun or pronoun ) winpause
aud @
  -IF                                   \ If a Subj noun has been found
    to Subject  		         \ save concept word found to subject
    aud @ >en{ S-PO c@ to SPO-State	\ retrieve subject Singular - Plural state
    motjuste @ decpsi1 @ =
  Then
\
 IF 	\ 20apr2006 Check for repetition...
 motjuste @ decpsi2 ! \ so as to accelerate de-activations...
 THEN 	\ and thus avoid quasi-flatliners.
\
 motjuste @ decpsi1 ! 	\ 20apr2006 Keep track of just-thought concept.
 0 motjuste ! 		\ 20apr2006 Safety measure moved here from nounPhrase.
\
 verbPhrase ( finds "le mot juste" for verb and for object ) winpause
 verb
 IF    \ If an active verb is found
        \ If thought is same as previous thought Do not use
   subject >en{ neno w@ old-sub @  =
    IF
     verb  >en{ neno w@ old-verb @ =
       IF
	verb-object >en{ neno w@ dup old-obj @ = swap subject >en{ neno w@ = or
\ Update to check and see if Object = Subject IF Then ignore 230221 FJR
	  IF   0 dup to subject dup to verb dup to auxv dup to negv to verb-object
	  Else svo1
          Then
	Else svo1
	Then
    Else svo1
    Then
 Then
\
0 to SPO-State
VerbClip
\
fyi @ 1 and  IF s" :SVO Exited"  diagnostic-window Then
\
; \ End of SVO; return to the ENGLISH module.
\
\ ********************************************************************************
\
: auxVerb (  --  ) \ auviliary Verb ) atm 14oct2005 Updated 230508 FJR
\ Provides part of a compound verb form.
\
fyi @ 1 and  IF s" :AuxVerb Entered" diagnostic-window Then
\
8 bias ! 0 len !
 \ "do" -- call a form of the auxiliary verb "do":
11 nen-search
IF
   11 motjuste ! \ "nen" concept #141 for "do".
   dup aud ! to auxv
Then
\
 11 urpsi ! \ For use in psiDamp to de-activate the "DO" concept.
 psiDamp \ 6aug2005 As when verbPhrase has sent a verb to Speech.
fyi @ 1 and  IF s" :AuxVerb Exited" diagnostic-window Then
\
; \ End of auxVerb; return to the negSVO module.
\
\ ********************************************************************************
\
: negSVO (  --  )  \ Updated 230508 FJR
fyi @ 1 and  IF s" negSVO Entered"  diagnostic-window Then
\
 5 bias ! 7 opt !
 nounPhrase \ for subject of negSVO sentence.
 aud @ to Subject

 auxVerb \ Fetch a form of auxiliary verb "do".
 0 aud !

 296 nen-search \ Look backwards for 283 = not.

 IF \ If #283 "not" is found,
 aud ! \ Recall-vector for "not".
 296 motjuste ! \ "nen" concept #283 for "not".
 THEN \ End of search for #283 "not".

aud @ dup 0 > if to negv else drop then \ just in case #12 not found

verbPhrase \ Find a verb +/- a direct object.

Sentence-Proc

10 pho ! ( ASCII 13 CR to trip a retroactive change )
0 to word-exec
AUD10 \ to receive the carriage-return CR 13
0 pho !
mind-output-buffer inbufsize erase

  enDamp    \ Deactivate the English lexicon.
\  audDamp  \ Protect audRecog? Not required

5 bias ! \ 29jul2002 Expect next to parse a noun=5.
s" NegSVO 'Not' concept " workfile-buffer zcount + swap cmove
log-file-write
\
fyi @ 1 and  IF s" negSVO Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: whatAuxSDo
( what DO Subjects DO ) \ atm 31oct2005 Updated FJR 080119
\ Generates a question in the form: what + Auxiliary + Subject + "Do"
\ where the Subject is a pre-selected "topic" concept from NewConcept

fyi @ 1 and  IF s" :WhatAuxSDo Entered" diagnostic-window Then
topic @ nen-search
\
IF to verb \ got a topic and a match
 \ move aud recall vector
\
\ Call interrogative pronoun "what":
What nen-search IF to subject Then
\
\ Call form of auxiliary verb "do": \ 7sep2005 Any of several auxiliary verbs.
 auxVerb auxv to verb-object
\
 0 to word-exec
 SVO1
\
 What urpsi !	\ For use in psiDamp to de-activate the "WHAT" concept.
 psiDamp	\ 6aug2005 As when verbPhrase has sent a verb to Speech.
 141 urpsi !	\ For use in psiDamp to de-activate the "DO" concept.
 psiDamp	\ 6aug2005 As when verbPhrase has sent a verb to Speech.
 psiDecay	\ Reduce unresolved activation on ignored concepts.
 verbClear
\
 fyi @ 1 and  IF s" :WhatAuxSDo Topic Found" diagnostic-window Then
\
Else
 fyi @ 1 and  IF s" :WhatAuxSDo No Topic Found / Matched" diagnostic-window Then
\
Then \ end of check for a topic and a topic match
\
fyi @ 1 and  IF s" :WhatAuxSDo Exited" diagnostic-window Then
\
; \ End of whatAuxSDo; return to ASK.
\
\ ********************************************************************************
\
: ASK ( selector of question formats ) \ atm 22jan2006
\ ASK enables the AI to ask a question, query a database,
\ search the Web with a search engine, or swallow ontologies.
\
fyi @ 1 and  IF s" :ASK Entered" diagnostic-window Then
\
 whatAuxSDo \ 4aug2002 Ask a "What Do blanks do?" question.
 3 EEG +!   \ Asking questions increases EEG activity
 0 recon !  \ 4aug2002 Reset the incentive to ask questions.
 0 topic !  \ 11Dec06 FJR reset the topic to null
\
fyi @ 1 and  IF s" :ASK Exited" diagnostic-window Then
; \ End of ASK; return to ENGLISH.
\
\ ********************************************************************************
\
: Get-Last-Thought
\ Retrieve the Last thought of the AI mind
\
fyi @ 1  IF s" Get-Last-Thought of AI" diagnostic-window Then
Mind-output-buffer zcount 2 + erase
\
  t @ tov @ \ This is the begining of the AI's last thought
\
  Do
    i >aud{ hashkey w@ dup >hash{ dict-loc @ dictionary + swap
    >hash{ wleno c@
    Mind-output-buffer zcount + swap cmove
    bl Mind-output-buffer zcount + C!
    i 1+ >aud{ stov c@ IF leave Then
  Loop
  s" AI's last thought - " diagnostic-window
  Mind-output-buffer zcount diagnostic-window
\
fyi @ 1 and  IF s" Get-Last-Thought Exited" diagnostic-window Then
\
;
' Get-Last-Thought is GLT
\
\ ***************************************************************************************
\
: ENGLISH  \ atm 22jan2006
\ Called by THINK and in turn calls SVO or any other particular English syntax structure.
\
fyi @ 1 and  IF s" :English Entered"  diagnostic-window Then
ms@ 60000 + inert ! \ If the AI is thinking, it is not inert. Reset timer
\
\ Need to test IF external input has asked a question of the AI
( question IF conjoin Then )  \ Any value here will activate the conjoin function
\
 recon @        		\ anything >0 will trigger the asking of a question
 IF
   ASK 1 to QFlag   	\ If urge to learn...
 ELSE        		        \ If no novelty...
   juxflag   		        \ jux @ 283 = not
   IF        		                \ "NOT" Concept was found in user input
     0 to juxflag 0 jux !
     negSVO \ transformation of Chomsky;
   ELSE SVO                 \ The "positive" S-V-O syntax.
   THEN                           \ End of test for verb-negation.
 THEN                             \ end of test for QFlag
\
fyi @ 1 and  IF s" :English Exited"  diagnostic-window Then
\
; \ Return to the THINK module which calls ENGLISH syntax.
\
' English is English#
\ ********************************************************************************
\
: Acknow-Word ( Updated 070401 )
\
fyi @ 1 and  IF s" :Acknow-Word Entered"  diagnostic-window Then
\ Code removed till later
fyi @ 1 and  IF s" :Acknow-Word Exited"  diagnostic-window Then
\ Returning to :THINK
;
\
\ ********************************************************************************
\
: THINK (  --  ) \ Called by the main ALIFE1 function.
\
fyi @ 1 and  IF  s" Think Entered"  diagnostic-window Then
\
 1 thinkcycle +!
 thinkcycle @ 1000000 =
 IF 0 thinkcycle ! s" THINK Cycle Reset to 0 "  diagnostic-window Then \ start over
\
 word-count @ 1 =
  IF
   Acknow-Word
  Else \ continue to process
\
 Midway EOD max tov @ swap  \ Midway point in thought chains
\ Change to truly examine ONLY recent Psi nodes.
\ 1/2 distance from eod to tov 080914
\
 DO 	\ Examine recent Psi nodes for Nouns or Pronouns
 I >psi{ poso C@ dup 5 = swap 7 = or \ 29aug2005 Look for nouns and pronouns not verbs.
	IF
	    I >psi{ acto w@ 2 >
\
	    IF \ 15oct2005 For chains of thought
	      C# pov ! ENGLISH C* pov !
	     LEAVE
	    THEN \ End of check for the activity of a found concept.
\
	THEN \ End of test for active opt=5 nouns.
\
 -1 +LOOP   \ End of backwards Loop seeking activations.
 Then            \ End of word-count check
\
 False to Timer1Flag \ reset timer flag
      QFlag
	IF
	  ms@ think-timer @ 30000 + > \ allow 30 seconds for input to AI question FJR 12Dec06
	     IF
		QFlag 2 = IF Then  \  ????????
		0 to QFlag ( Get-Thought)
	     Then
	Then
\
C* pov !        \ Return to 'external' point-of-view.
\
fyi @ 1 and  IF  s" Think Exited"  diagnostic-window Then
; \ End of THINK; return to the main ALIFE1 loop.
\
\ ***************************************************************************************
\
: Main-Fileopen
;
\
\ ***************************************************************************************
\
: Main-Fileclose
;
\
\ ********************************************************************************
\
: Time-Tracking ( Updated 230508 FJRusso )
\ Time checking to be done for various activities
\ Set up a small process delay - slowdown
\
fyi @ 1 and  IF s" :Time-Tracking Entered"  diagnostic-window Then
slow-delay _ms \ delay milliseconds here
winpause
get-local-time time-buf >time" 2drop ( time$)
time$ zcount w-display 4 80 * 11 + + swap cmove \ Load in updated time
\
\ Time passed since last CNS save
get-local-time ms@
dup tidle @ < IF dup tidle ! dup starttime ! ms@ trun @ - 60000 / talive +! dup trun ! Then
\
ms@ timer2 > IF Mind-Dump ms@ 300000 + to Timer2 Then
\
ms@ timer1 > IF True to Timer1Flag ms@ think-delay + to Timer1 Then
\
\ fyi @ 1 and  IF s" :Time-Tracking Mind-dump" diagnostic-window Then
\
\ If idle for more than 1 minute process email
ms@ tidle @ - 60000 / \ calc minutes
\
    IF
\        fyi @ 1 and  IF s" :Time-Tracking Email-Process Entered" diagnostic-window Then
	email-flag
	IF      \ If there is email to process Do it now
\	   em-process 0 to QFlag 0 recon ! 0 topic ! psidecay psidecay  \ 081003 updated
	Else
\	   No email to process
	   \ If no user input keep increasing till a minute is reached
	   think-delay 500 + 60000 min to think-delay ms@ tidle !
	   think-delay 60000 >
                IF 5000 to think-delay Then
	   \ 0 think-delay timer1 0 SetTimer drop False to Timer1Flag \ reset Timer
	Then
    Then

\ fyi @ 1 and  IF s" :Time-Tracking email process exited" diagnostic-window Then

fyi @ 0= IF ( Delay-Adjust) Then \ only IF diagnostics not running 101227

\ think-delay 29500 > hash-sort and IF hash{-sort Then

\ Re: sleep cycle
\ 11:59:30 PM = 86370000
\  5:59:30 AM = 21570000
\ ms@ 86370000 > IF 21570000 ( hibernate) Then \ Send to Hibernate the wake-up time
\
\  0 IF server-stat  \ ByPass not used at present
\       IF
\	   server-poll 1 t1 +!
\	   25 ms key?
\	Then
\    Then
\
  ms@ timer5 - 1000 >  \ 1 second has passed
  IF
     Paint: Main-Window#
     winpause
     ms@ to timer5  \ reset timer
 Then
\
fyi @ 1 and  IF s" :Time-Tracking Exited"  diagnostic-window Then
;
\
\ ********************************************************************************
\
: MOTORIUM ( stub for volitional control of actuators in robots )
\ MOTORIUM is a stub where you may insert robot motor code.
\
\ fyi @ 1 and  IF s" MOTORIUM Entered"  diagnostic-window Then
\
 1 motoriumcycle +!
 motoriumcycle @ 1000000 =
 IF 0 motoriumcycle !
      s" MOTORIUM Cycle Reset to 0 "  diagnostic-window
 Then \ Start over
 \ 7 EMIT \ The only power of the AI is to ring a bell.
 ( MOVE_FORWARD ) \ See ACM SIGPLAN Notices 33(12):25-31 of
 ( MOVE_BACKWARDS ) \ December 1998 for a paper by Paul Frenger,
 ( STOP_MOTION ) \ "Mind.Forth: Thoughts on Artificial
 ( TURN_LEFT ) \ Intelligence and Forth" for discussion
 ( TURN_RIGHT ) \ of the Mind.Forth MOTORIUM on page 26.
\ fyi @ 1 and  IF s" MOTORIUM Exited"  diagnostic-window Then
; \ end of MOTORIUM stub; return to ALIFE when implemented.
\
\ ********************************************************************************
\
: SECURITY
\ fyi @ 1 and  IF s" Security Entered" 2dup type cr diagnostic-window Then
 1 securitycycle +!
 securitycycle @ 1000000 =
 IF 0 securitycycle !
     s" SECURITY Cycle Reset to 0 "  diagnostic-window
 Then \ Start over
\
\ fyi @ 1 and  IF s" Security Exited" 2dup type cr diagnostic-window Then
;
\
\ ***************************************************************************************
\
: SENSORIUM ( sensory input channels Updated FJR 230220)
\
\ Handles the input of sensory perception.
\
 1 sensoriumcycle +!
  sensoriumcycle 2/ 2* sensoriumcycle =
  IF psiDecay Then \ For every other dycle
\
\ fyi @ 1 and  IF s" SENSORIUM Entered" diagnostic-window Then
\
 AUD13 ( for USER entry or reentry of phonemic ASCII )
 ( SMELL -- normal sensory stub for later implementation )
 ( VISION -- normal sensory stub for seed AI expansion )
 ( TOUCH -- normal haptics stub for cybernetic organisms )
 ( TASTE -- normal sensory stub for cyborg alife )
 ( SYNAESTHESIA -- an option in a multisensory AI )
 ( VOX -- Voice - Audio for Sound input from Microphone )
 ( COMPASS -- exotic sensory stub for use in robots )
 ( GEIGER -- exotic: Geiger counter )
 ( GPS -- exotic: Global Positioning System )
 ( INFRARED -- exotic )
 ( RADAR -- exotic: Radio Detection And Ranging )
 ( SONAR -- exotic: Sound Navigation And Ranging )
 ( VSA -- exotic: Voice Stress Analyzer lie detector )
 ( Wi-Fi -- exotic: 802.11 wireless fidelity )
\ fyi @ 1 and  IF  s" SENSORIUM Exited"  diagnostic-window Then
; \ Return to ALIFE1
\
\ ********************************************************************************
\
: Alife1 ( Updated 230508 FJR )

\ s" (Alife1) Bootflag = " type bootflag . cr cr
\ 0 think-delay 0 0 SetTimer to timer1 False to timer1flag	        \ Set Think timer
\ 0 300000     0 0 SetTimer to timer2 False to timer2flag
ms@ 300000 + to Timer2 \ Set Mind-Dump timer 5 minutes
ms@ think-delay + to Timer1  \  Loading first Think cycle time
 t @ to CNS-Time
 eeg @ 10 * 7 / eegmax @ max eegmax ! 				\ initialize eegmax
 eeg @ eeg-monitor !
 maxwordsize
 workfile-buffer zcount 0 fill
\
 bootflag cold =
	IF
	  \ Initial Greeting from the AI
	  C# pov !
	  s" HELLO I AM SHELLEY AN AI MIND "
	  Mind-output-buffer swap cmove
	  Paint: Main-Window#
	  winpause
	  CLf pho ! True to #aud10 Aud10
	  eod t @ Do i >aud{ stov @ 0> IF i to SOLV Then -1 +loop
	  t @ dup to rethought vault+ !

	Else \ Warm Bootup
	  C# pov ! \ 200911 Set "pov" to "internal".
	  Get-Last-Thought
	  Mind-output-buffer zcount type
	Then
	  C* pov !

 s" Checking Internet & E-Mail availability....."  diagnostic-window
 cr s" Checking Internet & E-Mail availability..... " type
 inet-check ( - F )
 IF
    s" Internet Connection Available" diagnostic-window
    cr s" Internet Connection Available" type cr
    ip-addr-space zcount erase
    s" Available" ip-addr-space swap cmove
    s" Email Port Checking ---- " type
    email-port-check
    s" Done " type cr
  Else
    s" Internet Connection NOT Available"  diagnostic-window
    cr s" Internet Connection NOT Available" type cr
  Then
 s" Initialization Completed"  2dup diagnostic-window type cr
 0 to inet-stat \ reset to 0 = closed
 ms@ to timer5  \ set timer to update display
 calc-midway
\
BEGIN 	\ Start the main program mind Loop running.
\
SECURITY winpause
MOTORIUM winpause 			\ Robotic activation of motor initiatives.
SENSORIUM winpause
Timer1Flag IF THINK winpause Then
Calc-Midway
(( Following is to setup Multi-Tasking events Not in use as of 230508
// [']  SECURITY Submit: myTasks  	 \ For human control and operation of the AI.
// [']  SENSORIUM Submit: myTasks	 \ Other human-robot input senses.
// [']  MOTORIUM Submit: myTasks	 \ Robotic activation of motor initiatives.
// WaitforAll: myTasks
// [']  THINK Submit: myTasks			\ Syntax and vocabulary of natural languages.
\   inet-stat     IF ( ['] Inet-Process Submit: myTasks)  Then 	\ If Internet connection is available
\   email-stat  IF ( ['] email-process Submit: myTasks) Then 	\ If Email is turned on
\   ['] Time-Tracking  Submit: myTasks	\ Timed events are handled from here
\   WaitforAll: myTasks
))
TIME-TRACKING 					\ Timed events are handled from here
  sp0 @ sp! \ RESET THE DATA STACK
  quit-flag
Until 	\ Repeat IF the AI has not met with misadventure or the Quit flag was set
 0BH fyi !
 s" Closing - We're done. " Type cr
\
;
\
\ ***************************************************************************************
\
: ALIFE: ( artificial Life ) \ FJR 230508
\
s" ALIFE: Wake - Up Call" 2dup type cr diagnostic-window
\
s" Lets wake-up AI-Mind" 2dup type cr diagnostic-window
AI-Wake-Up \ Lets wake-up AI-Mind
s"  AI-Response " Mind-output-buffer swap cmove
		Paint: Main-Window#
		winpause
\
warm bootflag =

 IF
s" Warm Boot: " type cr cr
 datafile zcount r/o open-file swap to workfile-ptr \ open life file

 0= IF
	s" Warm Boot - File opened." 2dup workfile-buffer swap cmove
	log-file-write type cr cr
	cns-core-start cns-core-end cns-core-start - workfile-ptr read-file 2drop
 Else
	s" Warm Boot - File Failed to open." 2dup workfile-buffer swap cmove
	log-file-write type cr cr
	cold to bootflag
 Then

 Then
\
\ Allocate array memory space
\
s" Allocate array memory space" 2dup type diagnostic-window
	cns @ en-size  * malloc to en{
	cns @ psi-size * malloc to psi{
	cns @ aud-size * malloc to aud{
	hashtable-size   malloc to hash{
        dict-size malloc to dictionary winpause
\ Error check for allocation errors
en{ 0 = psi{ 0 = or aud{ 0 = or hash{ 0 = or dictionary 0 = or
IF ." Error in Allocatng Array Memory Space!!! " cr
Else s"   --  Complete" 2dup type cr diagnostic-window
\
s" TABULARASA" 2dup type diagnostic-window
	TABULARASA  \ Clears the mind arrays
	winpause
s"   --  Complete" 2dup type cr diagnostic-window
\
warm bootflag =
\
 IF 	\ Load memory arrays from life file
 s" Load memory arrays from life file" 2dup type cr diagnostic-window
	  en{ cns @  en-size * workfile-ptr read-file 2drop
 s" en{ Loaded " 2dup type cr diagnostic-window
	 psi{ cns @ psi-size * workfile-ptr read-file 2drop
s" psi{ Loaded " 2dup type cr diagnostic-window
	 aud{ cns @ aud-size * workfile-ptr read-file 2drop
s" aud{ Loaded " 2dup type cr diagnostic-window
	hash{ hashtable-size   workfile-ptr read-file 2drop
s" hash{ Loaded " 2dup type cr diagnostic-window
        dictionary dict-offset workfile-ptr read-file 2drop
s" dictionary Loaded " 2dup type cr diagnostic-window
	workfile-ptr close-file drop    \ close work file winpause
s" Data file closed " 2dup type cr diagnostic-window
        cns @ 1- >aud{ 1+ @ cont-run !   \ recover the continuous run time
\ Compare Talive stored with back up value in CNS core
	talive @ cns @ 2 - >aud{ 1+ @ = not
	IF \ values are not equal
	  talive @ cns @ 2 - >aud{ 1+ @ max talive ! \ recover larger of the 2
	Then
	EOD T @ 1- Do i >aud{ stov @ 0> IF i to SOLV leave endif -1 +loop
	s" eod, T, SOLV = " type  solv T @ eod  . . . cr
winpause 1000 _ms
 Else
 s" Cold Boot" 2dup type cr diagnostic-window
   1 to hash-count
   1 to dict-offset
 s" bootflag = " type bootflag . cr cr
enBoot
 Then
\
\ 0 IF server Then \ By Pass not in use at present
\ hash{-sort
>RTDate winpause
t @ eod > IF  .acto then \ reset any high activations, over 63 back to 63
False enable: Begin-Alife#
True enable: Status-Window#
True enable: Process-Window#
\
s" ALIFE1 Processing routine" 2dup type cr diagnostic-window
ALIFE1 \ Main Processing routine
s" ALIFE1 Processing routine exited" 2dup type cr diagnostic-window
s" ALIFE: Call exiting" 2dup type cr diagnostic-window
Then \ Exit from Memory allocation error
\
;
\
\ ********************************************************************************
\
\ ********************************************************************************
\
: Close-alife \ FJR 101031 FJR
\
\ Shut down program
\
fyi @ 1 and  IF s" Close-alife Entered" 2dup type cr diagnostic-window Then
4 to timer1C true to timer3flag
\ inet-stat IF Inet-Process 0 to inet-stat Then \ If Internet connection is available
\ email-stat IF 0 to email-stat email-buf-ptr free Then
\ 0 IF server-cleanup Then  \ By Pass, not in use at present, internet server option when Available
\ status-window
ms@ trun @ - 60000 /      \ total run time minutes
dup talive +!             	    \ save the total thinking time in core and dump core
dup cns @ 1- >aud{ 1+ !  \ save the continuous run time in the last element of AUD{
eeg-monitor @ eeg !	    \ restore eeg
\
\ Disable-Timers \ All Timers must be disabled
\
mind-dump
\
\ free allocated memory
en{     ?dup IF free to en{    Else drop endif
psi{    ?dup IF free to psi{   Else drop endif
aud{   ?dup IF free to aud{  Else drop endif
hash{ ?dup IF free to hash{ Else drop endif
temp{ ?dup IF free to temp{ Else drop endif
dictionary ?dup IF free to dictionary Else drop endif
s" Allocated Memory Released"  diagnostic-window
\
workfile-buffer 1024 0 fill
MSG14 zcount workfile-buffer swap cmove
talive @ tempspace >string
tempspace count workfile-buffer zcount + swap cmove
s"  Minutes" workfile-buffer zcount + swap cmove
log-file-write
\ Log-File-Close
s" Close-alife Exited" 2dup type cr diagnostic-window
;
\
\ ***************************************************************************************
\
FileOpenDialog filelocate "AIMind-I - Select your input file :" "All Files|*.*|"
\
\ ***************************************************************************************
\
: Folder-Browse
z" AIMind-I - Select a Folder" Dir-Path hWnd BrowseForFolder
;
\
\ ***************************************************************************************
\       Define the Status-WINDOW child window class object
\ ***************************************************************************************
\
:Object Status-WINDOW: <super child-window
\
        Font bFont
        int alreadyPainting
        int paintAgain
	int hidden?
\
Record: LPWinScrollInfo
        int cbSize
        int fMask
        int nMin
        int nMax
        int nPage
        int nPos
        int nTrackPos
;RecordSize: sizeof(LPWinScrollInfo)
\
:M ClassInit:   (  )
                ClassInit: Super
                False to alreadyPainting
                False to paintAgain
		False to hidden?
                char-width        Width: bFont
                char-height      Height: bFont
                s" Courier" SetFacename: bFont
;M
\
:M On_Init:     (  )
                On_Init: super
                Create: bFont
		False enable: Status-Window#
;M
\
:M On_Done:     (  )
                Delete: bFont   \ delete the font when no longer needed
                On_Done: super
;M
\
:M On_Paint:    \ ( - ) all window refreshing is done by On_Paint:
\
		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                white AddrOf: wRect FillRect: dc
\
                \ set the backgroundcolor for text to ltblue
                green SetBkColor: dc
\
                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc
\
		s" Status Window " nip center-page 0
		s" Status Window " textout: dc
\
                \ set the backgroundcolor for text to ltblue
                white SetBkColor: dc
\
                \ and set the Textcolor to yellow
                Blue SetTextColor: dc
		char-height 17 to char-height
		title2
		9 0 Do
		0 char-height I 1+ * swap over
		display-buffer-2 90 I * + 32
		textout: dc
		dup 32 char-width * swap display-buffer-2 90 I * + 32 + 32
		textout: dc
		64 char-width * swap display-buffer-2 90 I * + 64 + 26
		textout: dc
		Loop
		to char-height
\		s" Status Window Painting" cr type cr
\
;M
\
:M StartSize:   ( width height - pixels ) nrcol# 1 - char-width * 13 char-height * ;M
:M StartPos:    ( x y )   5 10 char-height * ;M
:M Hide:        ( f1  )
                dup hidden? <>
                IF   dup to hidden?
			IF      SW_HIDE       Show: self
			ELSE    SW_SHOWNORMAL Show: self
			THEN
		     Update: self
                ELSE    drop
                THEN
;M
\
:M Refresh:    ( - ) Paint: self ;M  \ refresh the windows contents


:M WindowTitle:  z" AIMind Status " ;M
:M OnWmCommand:  ( hwnd msg wparam lparam  hwnd msg wparam lparam )
        over LOWORD ( Command ID )
;M
\
;Object
\
\
\ ***************************************************************************************
\       Define the Query-WINDOW child window class object
\ ***************************************************************************************
\
:Object Query-WINDOW <super child-window

        Font bFont
        int alreadyPainting
        int paintAgain
	int hidden?

Record: LPWinScrollInfo
        int cbSize
        int fMask
        int nMin
        int nMax
        int nPage
        int nPos
        int nTrackPos
;RecordSize: sizeof(LPWinScrollInfo)
\
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
\
:M ClassInit:   (  )
                ClassInit: Super
                FALSE to alreadyPainting
                FALSE to paintAgain
		False to hidden?
                char-width        Width: bFont
                char-height      Height: bFont
                s" Courier" SetFacename: bFont
;M

:M On_Init:     (  )
                On_Init: super
                Create: bFont

                dlg-Cold 	SetID:    Button_1
                self 		Start:    Button_1
                16 32 40 20 	Move:     Button_1
                s" Cold" 	SetText:  Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                +Style:   Button_1

                dlg-Warm	SetID:    Button_2
                self 		Start:    Button_2
                128 32 48 20 	Move:     Button_2
                s" Warm"	SetText:  Button_2
\
;M

:M On_Done:     (  )
                Delete: bFont   \ delete the font when no longer needed
\
\                On_Done: super
;M
:M On_Paint:    \ ( - ) all window refreshing is done by On_Paint:

		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                white AddrOf: wRect FillRect: dc

                \ set the backgroundcolor for text to ltblue
                green SetBkColor: dc

                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc

		12 8 s" Please Select how to start: " textout: dc
\
;M
:M StartSize:   ( width height - pixels ) 26 char-width * 4 char-height * ;M
:M StartPos:    ( x y )   31 DCh ;M
:M Hide:        ( f1  )
                dup hidden? <>
                IF      dup to hidden?
			IF      SW_HIDE       Show: self
			ELSE    SW_SHOWNORMAL Show: self
			THEN
\        Update: self
\        Refresh: EditorWindow
                ELSE    drop
                THEN
;M
\
:M Refresh:     (  )          \ refresh the windows contents
                Paint: self
;M
:M WindowTitle:    z" QUERY " ;M
:M OnWmCommand:  ( hwnd msg wparam lparam  hwnd msg wparam lparam )
        over LOWORD ( Command ID )
\        cr ." Query-WINDOW Accelerator command ID: " dup
        dup dup
	901 = swap 902 = or
	IF
	    901 = IF cold to bootflag Else warm to bootflag endif
            s" Exiting Query-WINDOW" 2dup type cr  diagnostic-window
	    True enable: Begin-Alife#
	    Hide: self
\	    On_Done: self
	    Paint: Main-Window#
	    winpause
	    s" ALIFE: Called" 2dup diagnostic-window type cr
            Alife: Main-Window#
	    s" ALIFE: Returned" 2dup diagnostic-window type cr
	    On_Done: [ self ]
	    On_Done: Main-Window#
        Else 2drop
	endif
;M
\
;Object
\
\ ***************************************************************************************
\       Define the Process-WINDOW child window class object
\ ***************************************************************************************
\
:Object Process-WINDOW: <super child-window
\
        Font bFont
        int alreadyPainting
        int paintAgain
	int hidden?

Record: LPWinScrollInfo
        int cbSize
        int fMask
        int nMin
        int nMax
        int nPage
        int nPos
        int nTrackPos
;RecordSize: sizeof(LPWinScrollInfo)
\
:M ClassInit:   (  )
                ClassInit: Super
                False to alreadyPainting
                False to paintAgain
		True to hidden?
                char-width        Width: bFont
                char-height      Height: bFont
                s" Courier" SetFacename: bFont
                ;M
\
:M On_Paint:    (  )          \ screen redraw procedure
                SaveDC: dc    \ save device context
                Handle: bFont SetFont: dc       \ set the font to be used
\
		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                white AddrOf: wRect FillRect: dc
\
                \ set the backgroundcolor for text to ltblue
                green SetBkColor: dc
\
                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc
\
		s" Process Window " nip center-page 0
		s" Process Window " textout: dc
\
                \ set the backgroundcolor for text to ltblue
                white SetBkColor: dc
\
                \ and set the Textcolor to yellow
                Blue SetTextColor: dc
\
                text-ptr ?dup
                IF      screen-rows 0
       ?do      char-width char-height i *      \ x, y
                line-cur i + #line"
                col-cur /string
                screen-cols min                 \ clip to win
                TabbedTextOut: dc
                word-split drop                 \ x
                char-width +    \ extra space
                i char-height *                 \ y
                over char-width / >r
                spcs screen-cols r> - 0max      \ at least zero
                spcs-max min TextOut: dc        \ and less than max
        Loop    2drop
                THEN
                using98/NT? 0=          \ only support variable sized scroll bars in Windows98 and WindowsNT
                line-last 32767 > OR    \ IF we have a big file, revert to non-resizable scroll buttons
                IF
        \ set the vertical scroll bar limits
        FALSE line-last screen-rows - 0max 32767 min 0 SB_VERT
        GetHandle: self Call SetScrollRange drop

        \ position the vertical button in the scroll bar
        TRUE line-cur line-last 32767 min line-last 1 - 1 max */ 32767 min SB_VERT
        GetHandle: self Call SetScrollPos drop

        \ set the horizontal scroll bar limits
        FALSE max-cols screen-cols 3 - - 0max col-cur max 32767 min 0 SB_HORZ
        GetHandle: self Call SetScrollRange drop

        \ position the horizontal button in the scroll bar
        TRUE col-cur 32767 min SB_HORZ
        GetHandle: self Call SetScrollPos drop
                ELSE
        \ set the vertical scroll bar limits and position
        screen-rows to nPage
        line-cur to nPos
        0 to nMin
        line-last to nMax
        SIF_ALL to fMask
        TRUE LPWinScrollInfo SB_VERT
        GetHandle: self Call SetScrollInfo drop

        screen-cols to nPage
        col-cur to nPos
        0 to nMin
        max-cols to nMax
        SIF_ALL to fMask
        TRUE LPWinScrollInfo SB_HORZ
        GetHandle: self Call SetScrollInfo drop
                THEN
\ restore the original font
                RestoreDC: dc
        ;M

:M On_Init:     (  )
                On_Init: super
                Create: bFont
		False enable: Process-Window#
		True enable: MenuClose-display#
		False to hidden?
                ;M
\
:M On_Done:     (  )
                Delete: bFont   \ delete the font when no longer needed
                On_Done: super
                ;M
\
:M StartSize:   ( width height - pixels ) nrcol# 1- char-width * 12 char-height * ;M
:M StartPos:    ( x y )   5 25 char-height * ;M
:M Erase:       (  )          \ erase the text window
                get-dc
                0 0
                screen-cols char-width  *
                screen-rows char-height * WHITE FillArea: dc
                release-dc
                ;M
\
:M Hide:  ( f1 --   ) ( Updated 230224 FJR)
                dup hidden? <>
                IF    dup to hidden?
			IF          SW_HIDE                     Show: self
			ELSE   SW_SHOWNORMAL Show: self
			THEN
                ELSE   drop
                THEN
	On_Done: self
 ;M
\
:M Refresh:     (  )  Paint: self ;M    \ refresh the windows contents
\
:M VPosition:   ( n1  )       \ move to line n1 in file
                0max line-last 1+ screen-rows 1- - 0max min to line-cur
                ;M
\
:M HPosition:   ( n1  )       \ move to column n1
                0max max-cols 1+ screen-cols 1- - 0max min to col-cur
                ;M
\
:M Home:        (  )          \ goto the top of the current file
                0 VPosition: self
                0 HPosition: self
                Refresh: self
                ;M
\
:M End:         (  )          \ goto the end of the current file
                line-last 1+ VPosition: self
                0            HPosition: self
                Refresh: self
                ;M
\
:M VScroll:     ( n1  )       \ scroll up or down n1 lines in file
                line-cur + VPosition: self
                Refresh: self
                ;M
\
:M VPage:       ( n1  )       \ scroll up or down n1 pages in file
                screen-rows * line-cur + VPosition: self
                Refresh: self
                ;M
\
:M HScroll:     ( n1  )       \ scroll horizontally n1 characters
                col-cur + HPosition: self
                Refresh: self
                ;M

\
:M HPage:       ( n1  )       \ scroll horizontally by n1 page
                screen-cols * col-cur + HPosition: self
                Refresh: self
                ;M

:M WindowStyle: (  style )            \ return the window style
                WindowStyle: super
                WS_VSCROLL or           \ add vertical scroll bar
                WS_HSCROLL or           \ add horizontal scroll bar
                ;M
\
:M WM_VSCROLL   ( h m w l  res )
                swap word-split >r
        CASE
                SB_BOTTOM        OF          End: self   ENDOF
                SB_TOP           OF         Home: self   ENDOF
                SB_LINEDOWN      OF    1 VScroll: self   ENDOF
                SB_LINEUP        OF   -1 VScroll: self   ENDOF
                SB_PAGEDOWN      OF    1   VPage: self   ENDOF
                SB_PAGEUP        OF   -1   VPage: self   ENDOF
                SB_THUMBTRACK    OF     line-last 32767 >
        IF     line-last r@ 32767 */ VPosition: self
        ELSE             r@          VPosition: self
        THEN             ENDOF
        ENDCASE r>drop
                Paint: self
                0 ;M
\
:M WM_HSCROLL   ( h m w l  res )
                swap word-split >r
        CASE
                SB_BOTTOM        OF          End: self   ENDOF
                SB_TOP           OF         Home: self   ENDOF
                SB_LINELEFT      OF   -1 HScroll: self   ENDOF
                SB_LINERIGHT     OF    1 HScroll: self   ENDOF
                SB_PAGELEFT      OF   -1   HPage: self   ENDOF
                SB_PAGERIGHT     OF    1   HPage: self   ENDOF
                SB_THUMBPOSITION OF r@ HPosition: self
         Refresh: self   ENDOF
                SB_THUMBTRACK    OF r@ HPosition: self
         Refresh: self   ENDOF
        ENDCASE r>drop
                Paint: self
                0 ;M
\
;Object
\
\ ***************************************************************************************
:Object Main-Window   <Super Window
\ ***************************************************************************************
\
Staticcontrol Text_1     \ a static text window AI response box
EditControl   Edit_1	 \ Edit box Human input box
ButtonControl Button_1   \ a button
\
\ Rectangle EditRect
\
:M On_Init:             (  )
   On_Init: super
\   NumKeys EnableAccelerators
\   FunctionKeys EnableAccelerators
\   CharKeys EnableAccelerators
\
                dlg-phrase	SetID:    Edit_1
		self		Start:    Edit_1
                9 char-width * char-height 7 * char-height 2 / +
		240 20 		Move: Edit_1
		ES_LEFT 	+STYLE:   Edit_1 \ Human Input Box
\
                dlg-ok 		SetID:    Button_1
                self 		Start:    Button_1
                12 char-width * 240 + char-height 7 * char-height 2 / +
                50 20 	        Move:     Button_1
                s" Enter" 		SetText:  Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                +Style:   Button_1
\
                self		Start:    Text_1
                9 char-width * char-height 6 *
		240 20 		Move:  Text_1
                Mind-output-buffer zcount SetText:  Text_1 \ AI-Response
		On_Paint: self
\
self Start: Query-WINDOW
On_Done: self
;M
\
:M ClassInit:   	ClassInit: super ;M
:M WindowStyle:         ( style ) WindowStyle: Super  ( WS_CLIPCHILDREN or) ;M
:M ParentWindow:        ( hwndParent | 0=NoParent ) parent ;M
:M SetParent:           ( hwndparent  ) to parent ;M
:M WindowHasMenu:       ( f ) true ;M
:M WindowTitle:    z" AIMind (Win32Forth) " ;M
:M StartSize:      ( width height - pixels ) nrcol# char-width * nrrow# char-height * ;M
:M StartPos:       ( x y ) CenterWindow: Self ;M
:M Close:          s" Close: Main-Window" type cr Close: super ;M
:M DefaultIcon: ( -- hIcon )
		s" C:\Programming\Win32Forth\Icons\AI\AI-Mind-1.ico" LoadIconFile
		dup .wndclass .hIcon !
		dup 0=
                IF	\ Loading default Icon
			DECIMAL drop 100 z" w32fConsole.dll" \ Win32Forth Icon
			Call GetModuleHandle Call LoadIcon
			dup .wndclass .hIcon ! HEX
		Else .wndclass .hIcon @
                EndIF
;M
\
\ ***************************************************************************************
\
:M On_Paint:    \ ( - ) all window refreshing is done by On_Paint:
\
		\ get the Client area of the window and fill it Ltblue
                AddrOf: wRect GetClientRect: self
                ltblue AddrOf: wRect FillRect: dc
\
                \ set the backgroundcolor for text to ltblue
                ltblue SetBkColor: dc
\
                \ and set the Textcolor to yellow
                ltyellow SetTextColor: dc
\
		w-display zcount nip center-page 0
			w-display zcount textout: dc
		w-display 80 + zcount nip center-page char-width 2 * - char-height
			w-display 80 + zcount textout: dc
		w-display 160 + zcount nip center-page 130 - char-height 2 *
			w-display 160 + zcount textout: dc
		w-display 240 + zcount nip center-page dup 2 / + char-height 2 *
			w-display 240 + zcount textout: dc
		w-display 320 + zcount nip center-page char-width + char-height 3 * char-height 3 / +
			w-display 320 + zcount textout: dc
\
		s" AI-Mind : " nip 0 char-height 6 * s" AI-Mind : " textout: dc
		s" Human :  " nip 0 char-height 7 * char-height 2 / + s" Human : " textout: dc
\
		Mind-output-buffer zcount SetText:  Text_1 \ AI-Response
\
;M
\
:M On_Done:
\
	1 to quit-flag
	s" On-Done Main-Window" 2dup type cr diagnostic-window
	Close-alife Log-File-Close
	s" Return from Close-Alife"  type cr
\
\	FunctionKeys DisableAccelerators
\	NumKeys DisableAccelerators
\	CharKeys DisableAccelerators
\
\   Close: self s" Close: self Main-Window" type cr
   0 call PostQuitMessage drop s" PostQuitMessage" type cr winpause
   On_Done: super 0 s" On_Done: super 0" type cr winpause
   turnkey? IF ( bye Else bye) quit Else quit Then \ terminate application
;M
\
\ ***************************************************************************************
\
\ :M On_Size:     ( h m w  )  \ handle resize message
\                col-cur >r screen-cols >r
\                Width  char-width  / to screen-cols
\                r> screen-cols - col-cur + r> min 0max to col-cur
\
\                line-cur >r screen-rows >r
\                Height char-height / to screen-rows
\                r> screen-rows - line-cur + r> min 0max to line-cur
\ ;M
\
\ ***************************************************************************************
\
:M WM_SYSCOMMAND ( hwnd msg wparam lparam  res )
                over 0xF000 and 0xF000 <>
                IF
		    over LOWORD
                    DoMenu: CurrentMenu
		    0
                Else
		    DefWindowProc: [ self ]
                Then
;M
\
\ ***************************************************************************************
\
:M OnWmCommand:  ( hwnd msg wparam lparam )
\ Processing of Function Keys
        over LOWORD ( Command ID )
\        dup cr ." Main-Window Accelerator command ID: " . cr
	On_Command: [ self ]
;M
\
:M On_Command:
\ dup cr ." Main-Window Accelerator command ID: " . cr
	case
            dlg-ok of ." DLG-Ok" cr
                GetText: edit_1
                human-input-buffer swap cmove
		human-input-buffer zcount type cr
                13 pho ! C* pov ! True to #aud13
		S" " SetText: edit_1 [ self ] winpause endof
\	    dlg-phrase of  ." DLG-Phrase" cr  \  Can be used to evalute individual key strokes
\		GetText: edit_1
\                human-input-buffer swap cmove
\		human-input-buffer zcount  2dup type cr
\		+ 1- c@ . cr
\		human-input-buffer zcount erase
\	        winpause endof
	    275 of drop 1 to quit-flag endof \ On_Done: [ self ] endof
	    276 of drop
		z" INFO"
		z" Win32Forth Windows AIMind-I \n Developed By F J Russo \n Version 2.0.4 230510"
		msgBox: Main-Window#
		endof \ Help endof
	    277 of drop Alife: winpause endof
	    278 of drop Close-display# winpause endof
	    279 of drop 1 to Status-Window-stat
		self Start: Status-WINDOW:  winpause endof
	    280 of drop 1 to Process-Window-stat
		self Start: Process-WINDOW: winpause endof
	endcase
;M
\
\ ***************************************************************************************
\
:M msgBox: ( z$menu z$text - ) swap MB_OK   MessageBox: Self drop       ;M
\
\ ***************************************************************************************
\
;Object
' Main-Window is Main-Window#
\
\ ***************************************************************************************
\
: Close-display ( Updated 230224 FJR)
	s"  *** Closing Process Display" cr diagnostic-window
	0 to Process-Window-stat
	True  enable: Process-Window#
	False enable: MenuClose-display#
	text-ptr ?dup IF free drop Then
	line-tbl ?dup IF free drop Then
	0 to line-last
	0 to line-cur
	erase: Process-window: winpause
	True hide: Process-window: winpause
	Paint: Main-Window# winpause
;
' Close-display is Close-display#
\
\ ********************************************************************************
\
MENUBAR ApplicationBar
    POPUP "&File"
        :MENUITEM menufileclose "&Close File... \tCtrl-C"
                 Main-Fileclose Paint: Main-Window  ;
        :MENUITEM menufileopen  "&Open File...  \tCtrl-O"
		 Main-fileopen Paint: Main-Window ;
        :MENUITEM menuexit      "&Exit \tAlt-F4" 1 to quit-flag ; \ Close: Main-Window ;

    POPUP "Help"
        :MENUITEM MenuInfo       "&Info"
        z" Info"
        z" Win32Forth Windows AIMind-I \n Developed By F J Russo Feb 2023"
        msgBox: Main-Window   	;
    POPUP "ALIFE"
        :MENUITEM    Begin-Alife "&Alife... \tCtrl-A" ALIFE: ;
	:MENUITEM	 MenuClose-display "Close-&Display... \tCtrl-D" Close-display ;
	:MENUITEM	 Status-Window "&Status-Window... \tCtrl-S"
				1 to Status-Window-stat
				( s" *** Status-Window-stat = " 2dup type cr diagnostic-window)
				Status-Window-stat . ;
	:MENUITEM	 Process-Window "&Process-Window... \tCtrl-P"
				1 to Process-Window-stat
				( s" *** Process-Window-stat = " 2dup type cr diagnostic-window)
				( Process-Window-stat .)  ;
\	:MENUITEM	 Help-Window: ;

ENDBAR
' MenuClose-display is MenuClose-display#
' menufileclose is menufileclose#
' menufileopen  is menufileopen#
' Begin-Alife is Begin-Alife#
' Status-Window is Status-Window#
' Process-Window is Process-Window#
\
\ ***************************************************************************************
\
\ The Main Application Program  This is the entrance into the program
\
: AIMind-I
\
\  Initialization coding
\
cls
S" \Programming\Win32Forth\proj\AIMind-I\2022" "chdir
\
   Title
   Title1
   Title2
\
   start: Main-Window
   ApplicationBar SetMenuBar: Main-Window
   gethandle: Main-Window
   Paint: Main-Window
   False enable: MenuClose-display
   False enable: Begin-Alife
   False enable: Status-Window
   False enable: Process-Window
   False enable: menufileclose
   False enable: menufileopen
   winpause
   turnkey? IF MessageLoop ( bye) THEN
\
;
\
\ ********************************************************************************
\
\ include \Programming\Win32Forth\src\lib\AcceleratorTablekeys.f
\
: core-diag ( Addr C -- )
 human-input-buffer swap cmove 2dup upper
 13 pho ! C* pov ! ( CR-Key-Entered) True to #aud13
 AUD13
;
\ ********************************************************************************
\
\ End of main module
\
\ ---------------------------End of Source code------------------------------------
\
\ For computers with small memory available this allows for sizing of arrays and not
\ crashing the system.
\ Data structure for the 4 arrays, PSI{, EN{, AUD{, and HASH{ require
\ psi-size + en-size + aud-size + hash-size bytes
\
app-free psi-size en-size + aud-size + hash-size + 1024 * / 9 * 10 / ( 90% of available )
10 min \ Self determining array sizes 10K set as initial size. Remove this line to use value calc above
to multiplier
1024 multiplier * cns !
\
\ This value only applies to initial start up.
\ Afterward CNS is read from data file
\
\ change to increase or decrease size of CNS ( 1024 multiplier * )
\ Use the minimum of calc value or 10.
\
\
\ ********************************************************************************
\
 ( [else] AIMind-I )
 turnkey?
 [if]
	Chdir c:\programming\Win32Forth\proj\AIMind-I
         ' AIMind-I turnkey AIMind-I-22.exe
         s" C:\Programming\Win32Forth\Icons\AI\AI-Mind-1.ico"  \ location & name of icon added into program
         s" AIMind-I-21.exe" AddAppIcon \ Icon

 [then]
s" Let's Begin -- AiMind-I" cr type cr
\
\ ********************************************************************************
\
