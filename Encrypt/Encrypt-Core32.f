\ Encrypt-Core.F
\ Frank J. Russo
\ Version 1.0
\ Date 210915
\
HEX \  ALL numerics used are in 'HEX' NOT Decimal !!!!!!
//
CODE RROT ( n1 n2 -- ror) ( 32 Bit Rotation of word right)
     mov ecx, ebx
     pop ebx
     ror ebx, cl
     next c;
//
CODE LROT ( n1 n2 -- rol) ( 32 Bit Rotation of word left)
     mov ecx, ebx
     pop ebx
     rol ebx, cl
     next c;
//
CODE GETADDR  ( addr1, size, count -- addr2 )
	mov eax, ebx
	pop  ebx
	push edx
	imul  ebx
	pop  edx
	pop  ebx
	add eax, ebx
	push eax
	next c;
\
\ ***************************************************************************************
\
0 value ?Lock
0 value rot-V
Variable Cx-V
\
\ ***************************************************************************************
\
: PW-Enc ( addr n -- ) \ Encrypt password 32 bits 211111
 0 Do Dup Dup @ 1Fh and
	dup 2 < IF 1+ Then
	swap C! 1+
    loop
drop
;
\
\ ***************************************************************************************
\
: Enc-Rotate  (  ---  )
\ 210215 Changed for speed to use assembly calls )
\ updated to use pointers to memory locations
\
                     ?Lock  @  \ Test for Lock or Unlock
                     if           \ Lock
			Cx-V @ Rot-V RROT Cx-V !
                     else         \ Unlock
			Cx-V @ Rot-V LROT Cx-V !
                     then
;
\
\ ***************************************************************************************
\
Variable pw-inc
Variable textposition
Variable Start-P
Variable End-P
Variable new-start-p
Variable Offset-V
0 Value PW-Size
0 Value PWAdr
\
: Enc-Fetch (  ---  )
\ cr Start-P @ . 9 emit End-P @ . 9 emit  textposition @ . cr
\ Start-P @ End-P @ Start-P @ - 1+ dump cr
\ Fetch word from buffer 210215 passes values to calling routine
        Begin

		Start-P @ textposition @ + C@ 8 LShift
		End-P @ textposition @ - C@ +
		Start-P @ textposition @ 1+ + C@ 8 LShift
		End-P @ textposition @ 1+ - C@ +
		Swap 10 LShift + Cx-V !

                Enc-Rotate \  Actual Encrypting & Decrypting of words

                \ reload values to buffer
		Cx-V @ Dup FFFF0000 and 10 RShift
		Dup FF and swap FF00 and 8 RShift
		Start-P @ textposition @ + C!
		End-P @ textposition @ - C!
		Dup FF and swap FF00 and 8 RShift
		Start-P @ textposition @ 1+ + C!
		End-P @ textposition @ 1+ - C!

                1 pw-inc +! pw-inc @ PW-Size @ =
                IF 0 pw-inc ! Then
		pw-inc @ PWAdr + c@ to rot-v        	\ Load Rotate Value

                2 textposition +! textposition @ offset-v @ 2 / >=
        Until
;
\
\ ***************************************************************************************
\
0 Value BufArd
0 Value Buf-size
0 Value EOI-Flag
\
: Enc-Main-Proc \ Updated 210915   ( PWAdr, PW-Size, BufArd, Buf-size, ?Lock  ---   )
\
to ?Lock to Buf-size to BufArd to PW-Size to PWAdr \ Values on the stack passed to the routine
0 0 0 0 pw-inc ! textposition ! new-start-p ! Cx-V ! \ initiate values to 0
\
BufArd Start-P !      \ set Starting point to the beginning of the Buffer
\
  Begin
	False to EOI-Flag \ set End of Input Flag to false
        PWAdr pw-inc @ + C@
	1+ 4 / 4 * 1-
	dup 3 < IF drop 3 Then \ Offset-v must be a value >2 and a multiple of 4 - 1
	offset-v ! 	  \ Load Offset-V with byte from PW phrase

        1 pw-inc +! pw-inc @ PW-Size @ =
        IF 0 pw-inc ! Then   \ reset to 0 if at end of password buffer

        pw-inc @ PWAdr + c@ to rot-v 	\  Load Rotate Value
        Start-P @ offset-v @ + End-P !	\ Establish End Pt

        End-P @ BufArd Buf-size @ 1- + >
	\ End Pt at end of In-Buffer ?
        IF   \ true at end of in-buffer
           BufArd Buf-size @ 1- + End-P ! \ set End-P to end of buffer
           end-p @ start-p @ - offset-v ! \ recalc offset-v
	   offset-v @ Dup
	   3 > IF
			  4 / 4 * 1- offset-v ! \ multiple of 4 - 1
			  Start-P @ offset-v @ + End-P !
		 Else Drop True to EOI-Flag \ less then 4 characters remain & will be ignored
		Then
       Then

        End-P @ 1+ new-start-p !   \ Save next start pt
        EOI-Flag Not
		IF
			Enc-Fetch
			new-start-p @ Start-P ! 0 textposition !
		Then
        new-start-p @ 1+ BufArd Buf-size @ + >
	EOI-Flag Or

  until
;
\
\ ***************************************************************************************
\
\s
\ The below lines can be used for testing
\ 1. Load True / False into dirc
\ 2. Password pwsize buffer bsize dirc Enc-Main-Proc
\
variable pwsize
variable bsize
variable dirc
create password 32 allot password 32 erase
create buffer 1024 allot buffer 1024 erase
s" FjR *210915* " password swap cmove
password zcount pwsize ! drop
s"   Frank J. Russo 2021  " buffer zcount + swap cmove
s"  Bytes remaining to process - " buffer zcount + swap cmove
s"  Encryption Completed" buffer zcount + swap cmove
s"  Process time (ms) = " buffer zcount + swap cmove
buffer zcount bsize ! drop
password pwsize @ pw-enc
\
\ ***************************************************************************************
\
