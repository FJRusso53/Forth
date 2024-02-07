\ Win32F Windows-AIMind22.h   Header File
\ Frank J. Russo
\ Version 1.1.4 230513
\
Decimal
\
Defer menubegin#
Defer MenuClose-display#
Defer menufileclose#
Defer menufileopen#
\
Needs struct.f
\
\ ********************************************************************************
\ Data Structures for Channel Arrays
\ When accessing the array elements W! & W@ MUST be used
\
0 nostack1
1 char+ field+ psio	\ 2 byte Integer Value same as neno
1 char+ field+ acto	\ Activation Level 0 - 64
1 char+ field+ juxo		\ NOT USED
0 char+ field+ poso	\ 1 byte Character Value Part of speech 1 - 15
1 char+ field+ preo	\ link to previous connected concept
1 char+ field+ seqo	\ link to sequel connected concept
1 char+ field+ enxo	\ NOT USED
dup 16 swap - +         	\ bytes reserved for growth
Constant psi-size       	\ element is 16 bytes in length
\
0 nostack1
1 char+ field+ neno	\ 2 byte Integer Value
2 +                     		\ acto already assigned
1 char+ field+ fexo	\ NOT USED
1+                      		\ poso already assigned
0 char+ field+ gendero \ M - F - N
0 char+ field+ S-PO 	\ S - P
1 char+ field+ fino		\ NOT USED
1 char+ field+ audo	\ NOT USED
0 char+ field+ glbo	\ Global descriptor
dup 16 swap - +  		\ bytes reserved for growth
Constant en-size 		\ element is 16 bytes in length
\
0 nostack1
1 char+ field+ hashkey  \ Hash table key
0 char+ field+ povo    	\ point of view
0 char+ field+ stov	\ Start of Time of voice
dup 8 swap - +   		\ bytes reserved for growth
Constant aud-size 		\ element is 8 bytes in length
\
0 nostack1
3 char+ field+ hashv   	 \ Hash Value of the word concept 4 byte Word
3 char+ field+ dict-loc 	\ offset into dictionary
0 char+ field+ wleno    	\ length of the word
dup 12 swap - +   		\ bytes reserved for growth
Constant hash-size	\ element is 12 bytes in length
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
\ ********************************************************************************
\
\ Self determining size of multiplier based on memory available not to exceed 10
\

\
\ Create MD-Header z," Begining of Mind Dump Memory Space"
\
Variable act ( INSTANTIATE; OLD- & NEWCONCEPT etc. )
Variable aud ( enVocab; Audition; Speech: auditory recall-tag )
Variable bias ( Parser; newConcept: an expected POS )
Variable counter \ used in Get-New-Thought routine
Variable decpsi1 ( decremend concept 1 to accelerate de-activation )
Variable decpsi2 ( decremend concept 2 for avoiding excess repetition )
Variable decpsi3 ( decremend concept 3 to keep track of most recent psi )
Variable dirobj ( flag to indicate seeking of a direct object )
Variable enx ( new-, oldConcept; Instantiate; Reify: x-fer Psi-En )
Variable fex ( new-, oldConcept; enVocab: Psi-to-English fiber-out )
Variable fin ( new-, oldConcept; enVocab: English-to-Psi fiber-in )
Variable fyi ( for rotation through display modalities )
Variable inert ( Think; English-trigger )
Variable Inet-time  ( used for tracking internet connection intervals )
Variable email-time ( used for tracking email connection intervals )
Variable jolt  ( 13jun2006 nounPhrase activation to nounAct )
Variable jrt ( "junior time" for memories moved in Rejuvenate )
Variable jux ( Parser; Instantiate: a JUXtaposed word )
Variable len ( length, for avoiding non-words in AUDITION )
Variable lump ( psiDamp -- level of post-thought activation )
Variable motjuste ( best word for selection as part of a thought )
Variable nlt ( not-later-than, for isolating time-points )
Variable opt ( option, for flushing out a desired part of speech )
Variable pho ( Listen; Audition; Speech: phoneme of input/output )
Variable pos ( old- & newConcept; enVocab: part-of-speech )
Variable pov ( point-of-view: # for internal; * for external )
Variable pre   ( previous concept associated with another concept )
Variable prev-conct ( previous concept locator )
Variable psi   ( associative tag from auditory engram to Psi mindcore )
Variable recon ( Eagerness to seek reconnaissance answers. )
Variable rv    ( "recall-vector" for diagnostic display of thought processes )
Variable seq   ( subSEQuent concept associated with another concept )
Variable server-hits ( Used by AI-Mind-net.f to track Internet rquest)
Variable spike ( 1aug2005: for potential use in spreadAct )
Variable subj  ( 15sep2005 flag to supercharge subject-nouns )
Variable topic ( topic for a question to be asked )
Variable tult  ( AUDITION; audSTM: t penultimate, or time-minus-one )
Variable uract ( original activation for HCI )
Variable urpre ( original pre for safeguarding during function-calls )
Variable urpsi ( original German:ur psi for use in psiDamp, etc. )
Variable urseq ( original seq for safeguarding during function-calls )
Variable zone  ( ACTIVATE; SPREADACT: time-zone for "pre" and "seq" )
\
\ Create MD-Header2 z," Ending of Mind Dump Memory Space"
\
Variable var-end-area -1 var-end-area ! \ Dummy Variable not used except as a marker
\
\ ********************************************************************************
\
( Additions by FJRusso 060524 )
\
 1  Constant warm
 0  Constant cold
CHAR . Constant C.
CHAR # Constant C#
CHAR * Constant C*
CHAR { Constant C{
CHAR [ Constant C[
0ah Constant CLf
CHAR M Constant male
CHAR F Constant female
CHAR N Constant neuter
CHAR S Constant singular
CHAR P Constant plural
CHAR ! Value exclm-pt
CHAR . Value period
CHAR ? Value question-mark
\ 1 Constant I
2 Constant YOU
3 Constant AM
4 Constant ARE
5 Constant WHO
6 Constant WHAT
7 Constant WHEN
\ 8 Constant WHERE
9 Constant WHY
10 Constant HOW
\ 11 Constant DO
12 Constant ME
13 Constant MY
14 Constant YOUR
101 Constant dlg-cancel
102 Constant dlg-ok
103 Constant dlg-delete
110 Constant dlg-input
111 Constant dlg-output
112 Constant dlg-phrase
113 Constant dlg-listbox
114 Constant dlg-lock
115 Constant dlg-unlock
200 Constant IDM_Close
201 Constant IDM_Exit
901 Constant dlg-Cold
902 Constant dlg-Warm
0x10000 Constant FunctionKey
0x50000 Constant ControlKey
0x90000 Constant ShiftKey
cold Value bootflag
\
0 Value actv		\ ( Activation State Noun = 0 / Verb =1 / Activate = 2 )
0 Value aispeech        \ Ai Speech Flag
0 value ck-start     \ Used to ckeck repeating sentence
0 Value cns-time	\ CNS time T
0 Value concept		\ -1 = new 0 = old
0 Value delay-cycle-time
0 Value eeg-temp	\ used to swing the baseline eeg up and then down to base eeg
0 Value email-flag	\ if email is waiting to process
0 Value get-thought1	\ used by get-thought to make sure the same thought is not recirculated
0 Value glbdom		\ Global Domain
0 Value hash-sort       \ Sorting needed 080830
0 Value hit-flag	\ Used in Search AudRecog
0 Value juxflag 	\ Flag when 'Not' is received from user input stream
0 Value keyb-in		\ Flag for keyboard input
0 Value logfile-ptr	\ Log file pointer
0 Value midway    \ Mid point between EOC & T
0 Value nen-search-Value \ used in Nen-search routine
0 Value new-cns         \ used to adjust new core size in .advmem
0 Value pre-pos
0 Value print-mode	\ Console = 0 - Printer = -1
0 Value Process-Window-stat
0 Value QFlag		\ Question Flag
0 Value question	\ nen for question asked
0 Value quit-flag	\ Used to signal program to exit
0 Value rethought	\ used to bring back old thoughts when idle
0 Value screenheight
0 Value screenwidth
0 Value search-array
0 Value search-array-counter
0 Value SOLV \ Start of last voice added 200907
0 Value SPO-State	\ Singular - plural state of noun or verb
0 Value start-of-word
0 Value Status-Window-stat
0 Value str1
0 Value str2
0 Value time-delay-cycle
0 Value word-exec	\ Flag initiate evaluation of user input
0 Value workfile-ptr	\ Working file pointer
2000 Value think-delay-default	\ = 2.0 seconds
80 Value InBufSize
neuter   Value gender	\ used to hold gender state
singular Value pos-flag	\ used to hold singular or plural strate
False Value #aud10
False Value #aud13
\
\ ********************************************************************************
\ Timers
\
0 Value timer1C		\ Counter associated with Timer1
0 Value timer1 		\ Thought Generation interval varies 2.5 seconds - 60 seconds
False Value timer1Flag
0 Value timer2		\ CNS data save 5 minutes (Mind Dump)
False Value timer2Flag
0 Value timer3		\ Web Page Update 1 minute
False Value timer3Flag
0 Value timer4		\ Email Access 15 minutes
False Value timer4Flag
0 Value timer5		\ Display Timer
False Value timer5Flag
\ ********************************************************************************
\
\ Sentence Structure Words
0 Value subject
0 Value verb
0 Value auxv
0 Value negv
0 Value verb-object
0 Value punc
\
\ Variables Used by Enboot
\ Variable t0 0 t0 !
\ 0 Value W-Count
0 Value t01
0 Value t02
0 Value tnen
0 Value tlen
0 Value tpos
0 Value enboot-ptr
0 Value enboot-count
0 Value enboot-flag
0 Value enboot-counter
\
\ ********************************************************************************
\
\ Variable cns-save-time \ Time of next mind-dump
Variable conj            \ Conjecture
Variable diagmessagnr    \ Message Counter
Variable DiagnosticW-loc \ present line available in the diagnostic message window
Variable eegmax
Variable eeg-monitor	 \ used to monitor eeg baseline
Variable eeg-yinc	 \ incremental Value of y axis
Variable HIB-Loc         \ screen x location of input for the Human-input-buffer
Variable keyb-time       \ Timer for keyboard input
Variable max-word-len	 \ size of largest word in memory
Variable nrcol 		 \ NR of columns to plot in eeg-graph
\ Variable search-pt
Variable starttime
Variable StatusW-loc     \ present line available in the system message window
Variable think-timer
Variable t0              \ Temporary Variables
Variable t1
Variable t2
Variable t3
Variable L1
Variable L2
Variable tidle 	 	 \ How long idle? holds starting time of going idle
Variable trun 		 \ used to calc run time it is the actual starting time
Variable word-count
\ Cycle counters for present run
Variable motoriumcycle
Variable securitycycle
Variable volitioncycle
Variable sensoriumcycle
Variable thinkcycle
Variable emotioncycle
Variable rejuvenatecycle
\
\ By creating dummy Variables around the CNS allows to dump the core to disk
\ and retrieve disk saved memory the same way FJR 060523
\
Variable cns-core-start 0xffff cns-core-start ! \ Dummy Variable not used except as a marker
\
 5000 Value think-delay  \ 5.0 seconds Changed from 10 to 5  230510
  165 Value slow-delay	\ = 165 miliseconds .165 seconds
    0 Value EOD 		\ EndOfDictionary
    0 Value dictionary	\ pointer to dictionary
    0 Value dict-offset	\ Offset into dictionary
 5120 Value dict-size	\ Starting size of dictionary - increased size  210219
 5120 Value hashrows	\ Starting size - increased size  220111
    0 Value hash-count
hashrows hash-size * Value hashtable-size
Variable cns     ( "central nervous system" array size )
Variable byear   ( year of birth )
Variable bmonth  ( month of birth )
Variable bday    ( day of birth )
Variable bhour   ( hour of birth )
Variable bminute ( minute of birth )
Variable bsecond ( second of birth )
Variable vault+
Variable talive   ( How long I have been alive in minutes )
Variable truntime ( max run time recorded in minutes )
Variable EEG      ( for EGO safety measure if users neglect the AI )
Variable IQ	  ( an invitation to code an IQ algorithm )
Variable t   	  ( time as incremented during auditory memory storage )
Variable tov   	  ( TABULARASA; REIFY; ENGLISH; time-of-voice )
Variable vault    ( enBoot; audSTM; Rejuvenate: bootstrap )
Variable nen-max  ( used to determine max nen in use)
Variable nen          ( English lexical concept number )
create RTdate 64 allot RTDate 64 0 fill \ Holds the date of longest continuous operation
Variable cont-run \ continuous run timer
\
\ create space for expansion of 1024 bytes
create var-space 1024 var-space cont-run - - dup allot var-space swap 0 fill
\
Variable cns-core-end 0xffff cns-core-end ! \ Dummy Variable used only as a marker
\
\ Pointers to Memory Channels New 2011 FJR
0 Value psi{
0 Value en{
0 Value aud{
0 Value hash{
0 Value temp{
\
Create Mind-output-buffer InBufSize Allot Mind-output-buffer InBufSize erase
Create Mind-Last-Thought InBufSize Allot Mind-Last-Thought  InBufSize erase
Create workfile-buffer 1024 Allot workfile-buffer 1024 erase
Create human-input-buffer InBufSize Allot human-input-buffer InBufSize erase
Create Display-Buffer 80 Allot Display-Buffer 80 erase
Create Display-Buffer-2 900 Allot Display-Buffer-2 900 erase
Create tempspace 24 allot tempspace 24 erase
Create eeg-space 608 allot eeg-space 608 32 fill
Create ip-addr-space 24 allot ip-addr-space 24 erase s" Not Available" ip-addr-space swap cmove
Create Temp-Buffer 80 Allot Temp-Buffer 80 erase
Create Status-Buffer 80 allot Status-Buffer 80 erase
\
Create old-sentence 12 allot old-sentence 12 erase
old-sentence Value old-sub
old-sub  4 + Value old-verb
old-verb 4 + Value old-obj
\
Create Buffer-Space 1024 Allot Buffer-Space 1024 erase
\
\ ***************************************************************************************
\
\ Message Area
\
Create datafile z," AIMind23.dat"
Create msg1 z," AI-Enboot-data.txt has been reconstructed - "
Create msg2 z," AI-Mind Log File Opened - "
Create msg3 z," AI-Mind Log File Closed - "
Create msg4 z," ABORTING - "
Create msg5 z," AI-Mind ' Shelley '"
Create msg6 z," Win32Forth"
Create msg7 z," Born on - "
Create msg8 z," Version 2.1.0 230513"
Create msg9 z," AIMind23.F "
Create Msg-Seperator z," ****************************************************************"
Create msg10 z," Shelley has gone into a SLEEP Phase"
Create msg11 z," Press any key to Awaken"
Create msg12 z," Shelley Is alive and awake"
Create msg13 z," Mind Core Rejuvinated"
Create msg14 z," Thinking for -  "
Create msg15 z," ' = Mind Thought ("
\ Msg 16 - 19 found in AI-Mind-net.f
Create msg20 z," AIMind webpage updated"
Create msg20a z," Webpage posting @ "   \ Put a time stamp on output 090821
Create msg20b z," ------- posted to site"
Create msg20c z," ------- File Upload Failed"
Create msg21 72 allot msg21 72 0 fill \
Create msg22 z," X Years XX Months X Weeks XX Days XX Hours XX Minutes"
Create msg23 z," Present Run time: "
Create msg23a z," Continous-run time: "
Create msg24 z," Running Version 160101 Rev -<BR>       ** UPDATED **<BR>" \ Used in HTML Web Page
Create msg25  z," F1: F-Key Help   F2: Mind Dump   F3: User Func   F4: Web Page On/Off"
Create msg25a z," F5: Email On/Off F6: Rejuvenate  F7: Scr Refresh F8: Update Web Page"
Create msg25b z," F9: ESC Key     F10: Shift F-Key Help           F11: Ctrl F-Key help          F12: Abort Run"
Create msg26  z," ShftF1: Get-Thought ShftF2:             ShftF3:             ShftF4:"
Create msg26a z," ShftF5: Check email ShftF6: SMTP-Test   ShftF7: Email-port-check              ShftF8:"
Create msg26b z," ShftF9: Thought Processes               ShftF10:            ShftF11:          ShftF12:"
Create msg27  z," CtltF1: Create Note  CtltF2: .reset      CtltF3: .cold       CtltF4: .print-data"
Create msg27a z," CtltF5: .Human-Input CtltF6: .AdvMem     CtltF7: AI-Speech   CtltF8:"
Create msg27b z," CtltF9:              CtltF10:            CtltF11:            CtltF12: Special Abort"
Create msg28  z," User Functions callable from AI-Human input line "
Create msg28a z," .reset       .psi        .en       .hash            .vocab1"
Create msg28b z," .vocab     .aud       .cold    .print-data    .Human-Input"
Create msg30  z," AI Checking for E-mail ---"
Create msg30a z," E-mail checking complete @ "
Create msg30b z," E-mail processing complete"
Create msg31 z," Human Voice - "
Create msg32 z," AI Voice -- "
\
\ End Message Area
\ ********************************************************************************
\
\ Following used by the display window
\
   0 Value using98/NT?          \ are we running Windows98 or WindowsNT?
   0 Value BrowseWindow
   0 Value text-len             \ length of text
   0 Value text-ptr             \ address of current text line
   0 Value text-blen            \ total text buffer length
   0 Value line-tbl             \ address of the line pointer table
   0 Value line-cur             \ the current top screen line
   0 Value line-last            \ the last file line
   0 Value col-cur              \ the current left column
1000 Value max-lines            \ initial maximum nuber of lines
 512 Value max-cols             \ maximum width of text currently editing
  90 Value screen-cols          \ default rows and columns at startup
  23 Value screen-rows
  90 Value nrcol#
  40 Value nrrow#
   0 Value stacksize
   0 Value file-flag
   0 Value x-pos
   0 Value y-pos
\ 903 Value Alife:
\
Create w-display 24 80 * allot w-display 24 80 * erase
Create QUOTE$ char " c,
Create cur-filename max-path allot
Create trashcan 1024 allot
Create line-buffer 512 Allot line-buffer 512 erase
Create Dir-Path MAX-PATH allot Dir-Path MAX-PATH erase
\
