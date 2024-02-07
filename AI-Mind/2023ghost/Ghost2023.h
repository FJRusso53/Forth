( ghost2023.h MindForth Ghost in the Machine source code as of 2019-11-05 )
\ First working artificial intelligence for autonomous humanoid robots.
\ First Working AGI with unsupervised learning for embodiment in robots.
( http://www.complang.tuwien.ac.at/forth/win32forth/W32for42.exe )
( http://dl.acm.org/citation.cfm?doid=307824.307853 -- Association for Computing Machinery )
\
\ Header file for Ghost2023.f   by FJRusso
\
0 Value multiplier  \ See last line of code
\
0 nostack1
3 char+ field+ hashv   	 \ Hash Value of the word concept 4 byte Word
3 char+ field+ dict-loc 	\ offset into dictionary
0 char+ field+ wleno    	\ length of the word
dup 12 swap - +   		\ bytes reserved for growth
Constant hash-size	\ element is 12 bytes in length
\
((      0  psy{ @ . ." "  \ 2017JUN14: Show tru
      1  psy{ @ . ." "  \ 2017JUN14: Show psi
      2  psy{ @ . ." "  \ 2016JUL25: Show hlc
      3  psy{ @ . ." "  \ 2017JUN14: Show act
      4  psy{ @ . ." "  \ 2017JUN14: Show mtx
      5  psy{ @ . ." "  \ 2017JUN14: Show jux
      6  psy{ @ . ." "  \ 2017JUN14: Show pos
      7  psy{ @ . ." "  \ 2017JUN14: Show dba
      8  psy{ @ . ." "  \ 2017JUN14: Show num
      9  psy{ @ . ." "  \ 2017JUN14: Show mfn
     10  psy{ @ . ." "  \ 2017JUN14: Show pre
     11  psy{ @ . ." "  \ 2019-09-28: Show seq
     12  psy{ @ . ." "  \ 2019-09-28: Show tgn
     13  psy{ @ . ." "  \ 2019-09-28: Show tdt
     14  psy{ @ . ." "  \ 2019-09-28: Show tkb
     15  psy{ @ . ." "  \ 2019-09-28: Show tia
     16  psy{ @ . ." "  \ 2019-09-28: Show tch
     17  psy{ @ . ." "  \ 2019-09-28: Show tdj
     18  psy{ @ . ." "  \ 2019-09-28: Show tdv
     19  psy{ @ . ." "  \ 2019-09-28: Show tpr
     20  psy{ @ . ."   "  \ 2019-09-29: Show rv
      0  ear{ @ . ." "  \ 2016aug04: Show ear{ ASCII
      1  ear{ @ . ." "  \ 2016JUL25: Show activation
      2  ear{ @ .       \ 2016JUL25: Show audpsi concept number
      0  ear{ @ EMIT ."  "   \ 2016aug04: Show ear{ pho
))
\
0 nostack1
3 char+ field+ psytru
3 char+ field+ psypsi
3 char+ field+ psyhlc
3 char+ field+ psyact
3 char+ field+ psymtx
3 char+ field+ psyjux
3 char+ field+ psypos
3 char+ field+ psydba
3 char+ field+ psynum
3 char+ field+ psymfn
3 char+ field+ psypre
3 char+ field+ psyseq
3 char+ field+ psytng
3 char+ field+ psytdt
3 char+ field+ psytkb
3 char+ field+ psytia
3 char+ field+ psytch
3 char+ field+ psytdj
3 char+ field+ psytdv
3 char+ field+ psytpr
3 char+ field+ psyrv
Constant psy-size
\
0 nostack1
3 char+ field+ earpho
3 char+ field+ earact
3 char+ field+ earaudpsi
Constant ear-size
\
Variable var-start-area 0 var-start-area ! \ Dummy Variable not used except as a marker
DECIMAL  ( 2016JUL25: use decimal numbers )
variable abc  ( 2018-10-19: AudBuffer transfer character )
variable act 0 act ! ( 2016JUL25: activation level  )
variable actbase ( 2016JUL28: AudRecog discrimination activation base )
variable actpsi  ( 2018-06-19: psi from which activation is to be spread )
variable anset   ( 2018-09-07: Sets "an" before a vowel at start of noun )
variable aud  ( 2016aug14: auditory recall-tag for activating engrams)
variable audbase  ( 2016aug22: recall-vector for VerbGen )
variable audjuste  ( 2016aug14: NounPhrase motjuste aud for Speech module )
variable audnum  ( 2018-06-22: de-globalizes the "num" variable )
variable audpsi  ( 2016JUL25: concept number of word in ear{ array )
variable audrec  ( 2016JUL28: auditory recognition concept-number )
variable audrun 1 audrun ! ( 2016JUL28: counter of loops through AudRecog )
variable audstop  ( 2019-09-30: flag to stop Speech module after one word )
variable auxverb  ( 2018-12-13: such as 800=BE; 818=DO; or modal verb )
variable b1   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b2   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b3   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b4   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b5   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b6   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b7   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b8   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b9   ( 2019-06-16: buffer character 01 in OutBuffer )
variable b10  ( 2018-10-19: buffer character 10 in OutBuffer )
variable b11  ( 2018-10-19: buffer character 11 in OutBuffer )
variable b12  ( 2018-10-19: buffer character 12 in OutBuffer )
variable b13  ( 2018-10-19: buffer character 13 in OutBuffer )
variable b14  ( 2018-10-19: buffer character 14 in OutBuffer )
variable b15  ( 2018-10-19: buffer character 15 in OutBuffer )
variable b16  ( 2018-10-19: buffer character 16 in OutBuffer )
\ variable bday ( 2016sep06: TIME&DATE day of birth )
variable becon 0 becon !  ( 2018-06-19: detect be-verb for InFerence )
\ variable bhour ( 2016sep06: TIME&DATE hour of birth )
variable bias 5 bias ! ( 2016aug23: Parser; NewConcept: expected POS )
variable binc  ( 2018-10-19: OutBuffer "b" increment for EnVerbGen )
\ variable bminute ( 2016sep06: TIME&DATE minute of birth )
\ variable bmonth ( 2016sep06: TIME&DATE month of birth )
\ variable bsec ( 2016sep06: TIME&DATE  second of birth )
\ variable byear ( 2016sep06: TIME&DATE year of birth )
variable c1   ( 2019-06-16: character in AudBuffer )
variable c2   ( 2019-06-16: character in AudBuffer )
variable c3   ( 2019-06-16: character in AudBuffer )
variable c4   ( 2019-06-16: character in AudBuffer )
variable c5   ( 2019-06-16: character in AudBuffer )
variable c6   ( 2019-06-16: character in AudBuffer )
variable c7   ( 2019-06-16: character in AudBuffer )
variable c8   ( 2019-06-16: character in AudBuffer )
variable c9   ( 2019-06-16: character in AudBuffer )
variable c10  ( 2018-10-19: character in AudBuffer )
variable c11  ( 2018-10-19: character in AudBuffer )
variable c12  ( 2018-10-19: character in AudBuffer )
variable c13  ( 2018-10-19: character in AudBuffer )
variable c14  ( 2018-10-19: character in AudBuffer )
variable c15  ( 2018-10-19: character in AudBuffer )
variable c16  ( 2018-10-19: character in AudBuffer )
variable catdobj  ( 2019-02-20: concat-direct-object for ConJoin "AND".  )
variable catiobj  ( 2019-02-20: concat-indirect-object for ConJoin "AND". )
variable catsubj  ( 2019-02-20: concat-subject for ConJoin "AND". )
variable catverb  ( 2019-02-20: concat-verb for ConJoin "AND". )
\ variable cns  3000 cns !  ( 2019-09-29: MindGrid size beyond which AI fails to run )
variable coda 160 coda !  ( 2019-10-11: memory to be recycled in ReJuvenate )
variable conj ( 2018-07-09: AI4U: oldConcept; Conjoin: conjunction )
variable dba  ( 2016JUL25: case for nouns; person for verbs )
variable dirobj  ( 2016aug22: flag indicates seeking for a direct object )
variable dobmfn  ( 2018-06-21: for InFerence to pass gender to AskUser )
variable dobseq  ( 2018-06-21: for transfer within InFerence )
variable dunnocon  ( 2018-10-07: condition of "I-don't-know" for queries. )
variable edge  0 edge ! ( 2016sep06: Rejuvenate edge-of-thought flag )
variable eot  ( 2016JUL26: end of text carriage-return )
variable etc  ( 2019-02-20: number of ideas simultaneously active for ConJoin)
variable eureka  ( 2018-11-10: value for use in until-loop )
variable foom    ( 2018-09-07: arbitrary trigger for invoking the Spawn module )
variable fyi 0 fyi ! ( 2019-11-05: for a bare-bones human-computer interaction )
\ variable fyi 4 fyi ! ( 2019-11-05: TAB to rotate through display modalities )
variable gencon      ( 2018-10-19: EnVerbGen status flag )
variable hap   ( 2019-11-05: a "haptic" sensation of touch for TacRecog )
variable haptac  ( 2019-11-05: for transfer from TacRecog to EnVerbPhrase )
variable hlc  1 hlc ! ( 2016JUL25: human language code )
variable holdnum   ( 2018-06-22: transfer from subject to verb )
variable impetus   ( 2018-09-23: incentive or trigger for volitional action )
variable infincon  ( 2018-06-22: infinitive condition flag )
variable inft  ( 2018-06-21: inference-time for AskUser )
variable inhibcon  ( 2016sep04: flag for neural inhibition )
variable iob  ( 2016JUL25: time-of-indirect-object for parser module )
variable isolation  ( 2018-10-07: counter to trigger "TEACH ME SOMETHING" )
variable jrt ( 2016sep06: ReJuvenate "junior time" for memories moved )
variable jux  0 jux ! ( 2016JUL25: holds psi # of a JUXtaposed word )
variable kbcon  ( 2018-06-22: flag for awaiting a yes-or-no answer )
variable kbzap  ( 2018-06-22: holds 432=YES or 404=NO for KbRetro )
variable krt ( 2016aug23: knowledge representation time )
variable lastpho  ( 2016aug23:  to avoid extra "S" on verbs )
variable len ( 2016JUL27: length, for avoiding non-words in AudInput)
variable mfn  ( 2016JUL25: "masculine feminine neuter" gender flag )
variable midway 0 midway ! ( 2016JUL25: adjustable time-limit )
variable mjact  ( 2016aug14: motjuste-activation for defaulting to 701=I )
variable monopsi  ( 2016JUL28: for use in audRecog module )
variable moot  ( 2018-06-19: flag to prevent associations during queries )
variable morphpsi  ( 2016JUL29: "for audRecog recognition of morphemes" )
variable motjuste  ( 2016aug14: "best word for inclusion in a thought" )
variable mtx ( 2017jun14: machine-translation xfer tag for flag-panel. )
variable negjux  ( 2016aug22: flag for 250=NOT juxtaposed to a verb )
variable newpsi   ( 2018-06-21: for singular-nounstem assignments )
variable nounlock  ( 2016aug14: for a verb to lock onto a seq-noun )
variable nphrnum 0 nphrnum ! ( 2016aug23: NounPhrase number )
variable nphrpos 0 nphrpos ! ( 2016aug26: NounPhrase part-of-speech )
variable num 0 num !  ( 2016JUL25: number-flag for the psy array )
variable numsubj   ( 2018-06-22: for number of subject )
variable nxt  ( 2016JUL29: number incremented for each new concept )
variable objprep  ( 2018-11-15: object of a prepositionl for EnPrep )
variable oldpsi  ( 2016JUL28: audpsi becomes oldpsi for OldConcept )
variable onset  0 onset ! ( 2016aug01: of an auditory memory engram )
variable PAL  1 PAL ! ( 2019-10-29: Permissive Action Link for AudBuffer and OutBuffer )
variable pho  ( 2016JUL25: phoneme of input/output & internal reentry )
variable phodex  0 phodex ! ( 2016aug23: pho-index for AudBuffer )
variable pos  ( 2019-10-04: 1=adj; 2=adv; 3=conj; 4=interj; 5=noun; 6=prep; 7=pron; 8=verb )
variable pov 1 pov !  ( 2016JUL29: point-of-view: 1=self; 2=dual; 3=alien )
variable prc  ( 2016JUL28: provisional recognition in AudRecog )
variable prclen  ( 2016JUL28:  lenth of stem when prc is declared )
variable pre  ( 2016JUL25: previous concept associated with a concept )
variable prednom  ( 2018-06-21: predicate nominative for InFerence )
variable prejux  ( 2016-08-26: previous jux to carry NOT to verb )
variable prep    ( 2018-11-10: preposition identifier for EnPrep )
variable prepcon  ( 2016aug27: prepositional condition-flag for parsing )
variable prepgen  ( 2016-08-27: urgency to generate a prepositional phrase )
variable prepsi   ( 2019-04-06: identification of concept for activation to spread to )
variable prevtag  ( 2016aug28: "previous concept" for "pre" in InStantiate )
variable prsn  0 prsn ! ( 2016aug23: 1st, 2nd, 3rd person of verb-forms )
variable psi  ( 2016JUL25: identifier of a psi concept in Psy mindcore )
variable psi20   ( 2019-09-29:  recall-vector "aud" in Rejuvenate )
variable psibase ( 2016JUL29: "winning psibase with winning actbase" )
variable putnum  ( 2018-06-22: putative number for subj-verb agreement )
variable qucon   ( 2018-06-19: query-condition for dealing with query-words )
variable quobj   ( 2018-06-21: query-object for yes-or-no questions )
variable quobjaud ( 2018-06-22: auditory recall-tag for AskUser module )
variable qusnum  ( 2018-06-21: query-subject-number for AskUser module )
variable qusub   ( 2018-06-21: internal provisional query-subject )
variable quverb  ( 2018-06-21: query-verb for yes-or-no questions )
variable qv1psi  ( 2016aug22: concept for SpreadAct to seek as a subject )
variable qv2num  ( 2018-06-19: number of a verb in a who+verb+dir.obj response )
variable qv2psi  ( 2016aug22: concept for SpreadAct to seek as a verb )
variable qv3psi  ( 2016aug22: concept for SpreadAct to seek as ind. obj. )
variable qv4psi  ( 2016aug22: concept for SpreadAct to seek as dir. obj.  )
variable qvdocon ( 2018-12-18: Query-condition for Who+Verb+Direct-Object )
variable recnum  ( 2016JUL29: "recognized number of a recognized word" )
variable rjc  0 rjc !  ( 2016aug29: rejuvenation counter for tracking )
variable rv   ( 2016aug01: recall-vector for auditory memory )
variable seq  ( 2016JUL25: subSEQuent concept associated with another )
variable seqdob  ( 2018-06-21: for direct object transfer within InFerence )
variable seqneed  ( 2016aug28: noun/pronoun or verb needed as a "seq" )
variable seqpsi ( 2016-08-26: synaptic deglobalized "seq" in SpreadAct )
variable seqrvx ( 2018-06-21: for rvx transfer within InFerence )
variable seqtkb ( 2018-06-21: for transfer during InFerence )
variable seqverb ( 2018-06-21: interstitial carrier for InFerence )
variable snu  ( 2016aug22: subject-number as parameter for verb-selection )
variable spacegap  ( 2019-09-30: to add gap of one space in Speech )
variable spt  ( 2016JUL28: blank space time before start of a word )
variable stemgap  ( 2016JUL29: "for avoiding false AudRecog stems" )
variable subjectflag  ( 2016aug14: flag for when seeking a subject )
variable subjnom ( 2018-06-21: subject-nominative for InFerence )
variable subjnum ( 2016aug25: for agreement with predicate nominative )
variable subjpre  ( 2016aug28: subject-pre to be held for verb in parsing )
variable subjpsi  ( 2016aug22: parameter to govern person of verb-forms )
variable sublen  ( 2016JUL29: "length of AudRecog subpsi word-stem" )
variable subpsi  ( 2016JUL29: "for AudRecog of sub-component wordstems" )
variable svo1  ( 2017jun15: subject -- item #1 in subject-verb-object )
variable svo2  ( 2016aug17: second item among subj-VERB-indirobj-object )
variable svo3  ( 2016aug17: third item among subj-verb-INDIROBJ-object )
variable svo4  ( 2016aug17: fourth item among subj-verb-IndirObj-OBJECT )
\ variable t  0 t ! ( 2016JUL25: time incremented during AudMem storage )
variable t2s  ( 2019-09-30: auditory text-to-speech index for Speech )
variable tai  ( 2016aug27: time of artificial intelligence diagnostics )
variable tbev ( 2017-06-15: time of be-verb for use with negation )
variable tcj  ( 2019-09-28: conceptual flag-panel time-of-conjunction )
variable tdj  ( 2019-09-28: conceptual flag-panel time-of-adjective )
variable tdo  ( 2016aug27: time-of-direct-object for a parser module )
variable tdt  ( 2019-09-28: time-of-dative conceptual indirect-object flag )
variable tdv  ( 2019-09-28: conceptual flag-panel time-of-adverb )
variable tgn  ( 2019-09-28: conceptual flag-panel time-of-genitive )
variable tia  ( 2019-09-28: conceptual flag-panel time-of-ablative )
variable tin   ( 2016aug29: time-of-input for interactive display )
variable tio   ( 2016aug27: time-of-indirect-object for parser module )
variable tkb  ( 2016JUL25: time-in-knowledge-base of an idea )
variable tkbn ( 2018-06-21: time of retroactive KB noun adjustment )
variable tkbo ( 2018-06-21: time of retroactive KB direct-object adjustment )
variable tkbprep  ( 2019-10-29: time of object of preposition for EnPrep )
variable tkbv  ( 2018-06-21: time of KbRetro verb adjustment )
variable tnpr  ( 2019-10-26: time-of-noun-preposition for EnPrep )
variable topic  ( 2016aug25: conceptual topic for a question to be asked )
variable tpp  ( 2016aug27: time-of-preposition for parsing )
variable tpr  ( 2019-09-28: conceptual flag-panel time-of-preposition )
variable tpu  ( 2018-06-24: time-pen-ultimate before current I/O )
variable trc  ( 2016aug29:  tabula-rasa-counter like rjc )
variable tru    ( 2017jun14: truth-value tag for conceptual flag-panel )
variable tseln  ( 2016aug22: time of selection of noun for neural inhibition )
variable tselo  ( 2018-11-10: time of selection of object )
variable tselp  ( 2018-11-10: time of selection of preposition )
variable tsels  ( 2016aug22: time of selection of subject )
variable tselv  ( 2016aug22: time of selection of verb for neural inhibition )
variable tsj   ( 2016aug27: time-of-subject for parsing )
variable tult  ( 2016JUL31: t penultimate, or time-minus-one )
variable tvb  ( 2016aug27: time-of-verb for parsing )
variable tvpr ( 2019-10-26: time-of-verb-preposition for EnPrep )
variable unk  ( 2016JUL26: general "unknown" all-purpose variable )
variable us1  ( 2018-06-20: "the" upstream noun #1 for EnArticle to keep track of )
variable us2  ( 2018-06-20: "the" upstream noun #2 for EnArticle to keep track of )
variable us3  ( 2018-06-20: "the" upstream noun #3 for EnArticle to keep track of )
variable us4  ( 2018-06-20: "the" upstream noun #4 for EnArticle to keep track of )
variable us5  ( 2018-06-20: "the" upstream noun #5 for EnArticle to keep track of )
variable us6  ( 2018-06-20: "the" upstream noun #6 for EnArticle to keep track of )
variable us7  ( 2018-06-20: "the" upstream noun #7 for EnArticle to keep track of )
variable usn  ( 2018-09-07: rotation-number for us1-us7 EnArticle concepts )
variable usx  ( 2018-09-07: transfer-variable for us1-us7 upstream variables )
\ variable vault 2067 vault ! ( 2019-09-28: dynamically calculated size of MindBoot )
variable verbcon  ( 2016aug27: verb-condition for seeking indirect objects )
variable verblock ( 2016aug22: for subject-noun to lock onto seq-verb )
variable verbprsn ( 2018-06-22: reverting to zero for infinitive forms )
variable verbpsi  ( 2016aug22: psi concept-number of verb in the psy{ array )
variable vphraud  ( 2016aug22: holds aud-fetch of verb-form for speech module )
variable vrsn 20191105 vrsn ! ( version identifier: 2019-11-05 )
variable wasvcon  ( 2019-02-22: query-condition for what-AUXILIARY-SUBJECT-VERB )
variable whatcon  ( 2018-06-19: flag for condition of answering a what-query )
variable wherecon ( 2018-11-10: flag for condition of answering a where-query )
variable whocon   ( 2018-12-18: flag for condition of answering a who-query )
variable whoq    ( 2019-01-15: flag for letting AskUser ask a who-question )
variable yncon   ( 2018-06-21: statuscon to trigger yes-or-no AskUser query )
variable ynverb  ( 2018-06-21: yes-or-no verb for AskUser )
\
\ ********************************************************************************
\
( Additions by FJRusso 231020 )
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
 5120 Value dict-size	\ Starting size of dictionary   231020
 5120 Value hashrows	\ Starting size 231020
    0 Value hash-count
hashrows hash-size * Value hashtable-size
Variable cns (  "central nervous system" array size )
Variable byear   ( year of birth )
Variable bmonth  ( month of birth )
Variable bday    ( day of birth )
Variable bhour   ( hour of birth )
Variable bminute ( minute of birth )
Variable bsec ( second of birth )
Variable vault+
Variable talive   ( How longhave been alive in minutes )
Variable truntime ( max run time recorded in minutes )
Variable EEG      ( for EGO safety measure if users neglect the AI )
Variable IQ	  ( an invitation to code an IQ algorithm )
Variable t 0 t ! ( 2016JUL25: time incremented during AudMem storage  time as incremented during auditory memory storage )
Variable tov   	  ( TABULARASA; REIFY; ENGLISH; time-of-voice )
Variable vault 2067 vault ! ( 2019-09-28: dynamically calculated size of MindBoot enBoot; audSTM; Rejuvenate: bootstrap )
Variable nen-max  ( used to determine max nen in use)
Variable nen          ( English lexical concept number )
create RTdate 64 allot RTDate 64 0 fill \ Holds the date of longest continuous operation
Variable cont-run \ continuous run timer
\
\ create space for expansion of 1024 bytes
create var-space 1024 var-space cont-run - - dup allot var-space swap 0 fill
\
Variable cns-core-end 0xffff cns-core-end ! \ Dummy Variable used only as a marker
