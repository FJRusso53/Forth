\ AI-dot-calls.f 080101
\ ***************************************************************************************
\
defer diag-message \ to be able to send messages to the main program display module
defer log-entry    \ to be able to send messages to the main program loggin module
\
\ Area for dot functions callable by AI and user
\
: output-test
printer? if 60 else ( screenheight 2 -) 60 then to print-mode
." print-mode " . 9 emit ." Screenheight " screenheight . cr
;
\
\ ***************************************************************************************
\
: .psi ( show concepts in the Psi array ) \ atm 14oct2005 Updated FJR 070425
\  Displays the contents of the deep mindcore "Psi".
output-test wait
0 t1 ! \ line counter
page
 CR ." Psi mindcore concepts"
 CR ." time:     psi    act    jux    pre     pos   seq    enx" cr
 T @
 Depth 1 > if swap else 1 then
\ Test to make sure the loop values are proper
2dup < if drop 1 then
DO
 I 5 .r ." :" 2 spaces
 I >psi{ psio W@ 5 .r 2 spaces \ psi
 I >psi{ acto W@ 4 .r 3 spaces \ act
 I >psi{ juxo W@ 4 .r 3 spaces \ jux
 I >psi{ preo W@ 4 .r 3 spaces \ pre
 I >psi{ poso C@ 5 .r 2 spaces \ pos
 I >psi{ seqo W@ 4 .r 3 spaces \ seq
 I >psi{ enxo W@ enx ! enx @ 5 .r 5 spaces \ enx = transfer-to-English.
 ." to -> "
 i >aud{ hashkey W@ dup >hash{ dict-loc @ dictionary + swap >hash{ wleno c@ type cr
 1 t1 +!
 t1 @ print-mode / print-mode * t1 @ =

 if
 printer?
 if noop else wait then page
 CR ." Psi mindcore concepts"
 CR ." time:     psi    act    jux    pre     pos   seq    enx" cr
 then

 0 aud ! \ Zero out the auditory associative tag.

 LOOP
printer? if page then
; \ End of .psi -- called when user types: .psi [ENTER]
\
\ ********************************************************************************
\
: .en ( show vocabulary in the English lexicon array ) \ atm 14oct2005 Updated FJR 070425
\  Displays the English lexicon array "en{".
output-test wait
page
 CR ." English lexical fibers"
 CR ." Time     nen    act    fex    pos gen Tns  GLBD   fin    Aud" cr
 0 t1 ! \ line counter
 T @
 Depth 1 > if swap else 1 then
\ Test to make sure the loop values are proper
2dup < if drop 1 then
DO
 I >en{ neno W@
 I 5 .r 2 spaces  5 .r 2 spaces
 I >en{ acto w@ 5 .r 2 spaces
 I >en{ fexo W@ 5 .r 2 spaces
 I >en{ poso C@ 4 .r 3 spaces
 I >en{ gendero c@ emit 3 spaces
 I >en{ S-PO c@ emit 3 spaces
 I >en{ glbo c@ 2 .r 2 spaces
 I >en{ fino W@ 5 .r 2 spaces
 I >en{ audo W@ 5 .r 4 spaces
 ." to -> "
 i >aud{ hashkey W@ dup >hash{ dict-loc @ dictionary + swap >hash{ wleno c@ type cr
 1 t1 +!
 t1 @ print-mode / print-mode * t1 @ =
\
 if
 printer?
 if noop else wait then page
 CR ." English lexical fibers"
 CR ." Time     nen    act    fex    pos gen Tns  GLBD   fin    Aud" cr
 then
\
 0 aud ! \ Zero out the auditory associative tag.
\
 LOOP
printer? if page then
; \ End of .en -- called when user types: .en [ENTER]
\
\ ********************************************************************************
\
: .aud ( show engrams in the auditory memory array ) \ FJR 080101
\  Display the auditory memory channel.

output-test wait
page
 CR ." Auditory memory nodes"
 CR ."  Time     Hash Key    STOV    POV" cr

 T @
 Depth 1 > if swap else vault+ @ then
\ Test to make sure the loop values are proper
2dup <= if 2drop T @ eod then
DO ( Show the Aud channel starting with vault+.)
 I 5 .r 6 spaces
 I >aud{ hashkey W@ 4 .r 9 spaces
 I >aud{ stov c@ emit 6 spaces
 i >aud{ povo c@ emit 4 spaces
 ." to -> "
 i >aud{ hashkey W@ dup >hash{ dict-loc @ dictionary + swap >hash{ wleno c@ type cr

 I print-mode / print-mode * I =
 if
   printer?
	if noop else wait then page
 CR ." Auditory memory nodes"
 CR ."  Time     Hash Key    STOV    POV" cr
 then
\ if page ." t pho act pov beg ctu psi crc len" cr then
 LOOP
printer? if page then
; \ End of .aud -- called when user types: .aud [ENTER]
\
\ ********************************************************************************
\
: .hash ( show Hash Table array ) \ FJR 080114
\
output-test wait
page
 CR ." Hash Table"
 CR ."  Time     Hash Value    Dictionary Offset    Word Length" cr

hash-count
 Depth 1 > if swap else 1 then
\ Test to make sure the loop values are proper
2dup < if drop 1 then

DO ( Show the Aud channel starting with vault+.)
 I 5 .r 3 spaces
 I >hash{ hashv    @ 12 .r  4 spaces
 I >hash{ dict-loc @  6 .r 21 spaces
 I >hash{ wleno   c@  3 .r  5 spaces
 ." to -> "
 I dup >hash{ dict-loc @ dictionary + swap >hash{ wleno c@ type cr

 I print-mode / print-mode * I =
 if
   printer?
	if noop else wait then page
 CR ." Hash Table"
 CR ."  Time     Hash Value    Dictionary Offset    Word Length" cr
 then
\ if page ." t pho act pov beg ctu psi crc len" cr then
 LOOP
printer? if page then
;
\
\ ********************************************************************************
\
: .vocab1 ( POS -- ) \ Called by .vocab ( updated 070428 FJR )
 to t02
 max-word-len @ + 10 to t01 \ hold length of largest word in core memory
 cr
 s"   Nen      Concept" type t01 spaces
 s" POS    Gender   Tense   Global" type cr
 T @ 1
	do \ loop through the mind-core

		I nen-search
		if \ nen found
		   dup aud !
		   >en{ poso C@ t02 =

			if
			 aud @ dup >en{ neno w@ 5 .r 6 spaces  \ display nen value
			 dup >aud{ hashkey W@ dup >hash{ dict-loc @ dictionary + swap >hash{ wleno c@ dup >R type
			 t01 R> - spaces

			 dup >en{ poso C@ 5 spaces 4 .R 7 spaces
			 dup >en{ gendero C@ emit 7 spaces
			 dup >en{ S-PO C@ emit 8 spaces
			 >en{ glbo c@ .
			 cr
			endif

		endif

	 loop
 cr cr
;
\
\ ********************************************************************************
\
: .vocab ( updated 070408 FJR )
\ display vocabulary by types
\ POS: 1=adj 2=adv 3=conj 4=interj 5=noun 6=prep 7=pron
\ 8=verb 9=names 10=affirmation 11=Symbol 12=numbers 15=Exec

\ max-word-len @ + 10 to t01 \ hold length of largest word in core memory
output-test wait
page
0 counter !
16 1 do \ loop through the 13 defined types

	i case
	 1 of cr S" Adjectives" type cr endof
	 2 of cr S" Adverbs" type cr endof
	 3 of cr S" Conjections" type cr endof
	 4 of cr S" Interjections" type cr endof
	 5 of cr S" Nouns" type cr endof
	 6 of cr S" Prepositions" type cr endof
	 7 of cr S" Pronouns" type cr endof
	 8 of cr S" Verbs" type cr endof
	 9 of cr S" Names" type cr endof
	10 of cr S" Affirmations" type cr endof
	11 of cr S" Symbols" type cr endof
	12 of cr S" Numbers" type cr endof
	15 of cr S" Executable Commands" type cr endof
	endcase

	i .vocab1
 loop
printer? if page then
;
\
\ ********************************************************************************
\
: .Print-data

Printer
." PSI " cr
eod .psi
." EN " cr
eod .en
." AUD " cr
1 .aud
." Vocabulary " cr
.vocab
." Hash Table" cr
.hash
." Dictionary" cr
dictionary dict-offset 16 + dump
console
;
\
\ ***************************************************************************************
\
: .EEG-Graph ( Updated 071009 )
\ Graph the EEG and keep it as a moving graph
\ Can only display if screenwdith is > 80 this gives 5 columns minimum
\ If window minimized no graphing occurs or is accumulated

FYI @ 1 and  if s" .EEG-Graph Entered" diag-message then

screenwidth 80 >
if
eeg @ eeg-monitor @ > if eeg @ eeg-monitor ! then \ if eeg > monitor set monitor to eeg
eeg @ eeg-monitor @ 3 eeg-yinc @ * - < if  eeg-monitor @ eeg ! then \ if eeg < monitor - 3 incs reset to monitor
eeg @ 120 > if 100 dup eeg ! eegmax ! 10 to eeg-temp then
\ constantly recalc eegmax value eeg = 70 % of eegmax
eeg @ 10 * 70 / 10 * dup eegmax @ > if eegmax !  else drop then
\ calc the increment of the y axis based on max eeg
eegmax @ 10 / 1 max eeg-yinc !
screenwidth 76 - 1-  \ calc the number of columns
49 min nrcol ! \ use the smaller of the 2 not to excee 49
\ There are 10 rows and min 5 columns up to 49
\ Step 1 is to move col to col-1 from 0 to nrcol
eeg-space 10 0

  do
    dup dup 50 + over rot 1+ swap nrcol @ cmove
    swap nrcol @ + 32 swap c!
  loop
  drop

\ Blank Out Last Column
eeg-space 10 0
  do
    dup i 50 * + nrcol @ + 32 swap c!
  loop
drop

\ Step 2 Fill last column with present value
eeg @ eeg-temp + eeg-yinc @ /  \ Nr of rows to fill represent the value
10 0
  do
     dup i >
	if
         eeg-space i 50 * + nrcol @ + 88 swap C!
	then
  loop
drop
\
\ Step 3 Plot out graph
eeg-space 5 15
  do
    75 i gotoxy dup 50 + swap nrcol @ 1+ type
  -1 +loop
drop
eeg-space 500 + dup
75 16 gotoxy dup 50 + swap nrcol @ 1+ type
75 17 gotoxy nrcol @ 1+ type
75  5 gotoxy nrcol @ 1+ type
then
FYI @ 2 and
   if
    eeg-yinc @ eegmax @ eeg @
    msg21 72 0 fill
    s" EEG Values: EEG = " msg21 swap cmove
    tempspace dup 8 0 fill >string tempspace count msg21 zcount + swap cmove
    s"   EEG-Max = " msg21 zcount + swap cmove
    tempspace dup 8 0 fill >string tempspace count msg21 zcount + swap cmove
    s"   EEG-Yinc = " msg21 zcount + swap cmove
    tempspace dup 8 0 fill >string tempspace count msg21 zcount + swap cmove
    msg21 zcount diag-message
    msg21 zcount 0 fill
   then
\ next lines are for diagnostics
\ eeg-temp eeg-yinc @ eegmax @ eeg @
\ 75 17 gotoxy
\ 75 17 gotoxy
\ 3 .r 3 spaces 3 .r 3 spaces 3 .r 3 spaces 3 .r 3 spaces
\
FYI @ 1 and  if s" .EEG-Graph Exited" diag-message then
;
\
\ ********************************************************************************
\
: .notes
\ Simply logs in notes entered after Forth Word .notes
2drop
;
\
\ ********************************************************************************
\
: .reset \ Changed 080101 FJR
\ Reset mind core back to begining but maintains running variables
eod 1+ psi{
cns @ 1- psi{ psi-size + 1-
over - 0 fill

eod 1+ en{
cns @ 1- en{ en-size + 1-
over - 0 fill

vault+ @ >aud{
cns @ 1- >aud{ aud-size + 1-
over - 0 fill

\ Reset T and TOV values
vault+ @ dup T ! dup tov !
1- tult ! \ The last previous time is "t-ultimate".

\ reset max NEN value
EOD en{ neno W@ dup nen-max ! nen !
EOD 1+ T !

workfile-buffer 1024 0 fill s" Memory Reset to Vault+ " workfile-buffer swap cmove

 32 workfile-buffer zcount + C!
 get-local-time time-buf >time" 2drop
 time$ zcount workfile-buffer zcount + swap cmove
 32 workfile-buffer zcount + C!
 log-entry
 workfile-buffer 1024 0 fill
 ms@ 30000 + dup think-timer ! 60000 + inert !
;
\
\ ********************************************************************************
\
:  .acto ( -- ) \ 230225 Updated FJR uses Get-Addr code
( created to set all excessive activation levels back to 64 on reloading of core )
	t @ eod
	do
	      psi{ psi-size I get-addr acto w@ 63 >
		    IF s" Activation-limit has been exceeded  " 2dup type I . cr diagnostic-window
			63 psi{ psi-size I get-addr acto w! \ set the activation back to the limit.
		    THEN
	loop
;
\
\ ********************************************************************************
\
: .mind-dump mind-dump# ;  \ 230228 FJR
\
\ ********************************************************************************
\
