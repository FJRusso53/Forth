\ Encrypt-Core.F
\ Frank J. Russo
\ Version 1.0
\ Date 210910
\
\ ***************************************************************************************
\
\ Addition by FJR 2120906
CODE RROT ( u1 n2 -- u2) ( Rotate u1 n2 bits to the right) \ 16 bit rotation
		mov     ecx, ebx ( ebx auto pops first value = n2 = count)
		pop     ebx ( pop target value)
		ror     bx, cl
		next     c;  ( ebx pushed onto stack)
\
\ Addition by FJR 2120906
CODE LROT ( u1 n2 -- u2) ( Rotate u1 n2 bits to the left) \ 16 bit rotation
		mov     ecx, ebx  ( ebx auto pops first value = n2 = count)
		pop     ebx ( pop target value)
		rol	bx, cl
		next    c;  ( ebx pushed onto stack)
\
\ Addition by FJR 2120906
CODE GET-ADDR{ ( addr1, size, count -- addr2 )
\ An array look up addr1 base array address, size of record (row), count = row #
		mov eax, ebx
                pop  ebx
		push edx
                imul  ebx
		pop  edx
		pop  ebx
		add eax, ebx
		push eax
                next  c;
\
0 value ?Lock
0 value rot-V
Variable Cx-V
\
\ ***************************************************************************************
\
: PW-Enc ( addr n -- ) \ Encrypt password
 0 Do Dup Dup @ ( 31 ) 0Fh and
	dup 2 < if 1+ endif
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
\ Fetch word from buffer 210215 passes values to calling routine
        Begin

                FF00H 8 Start-P @ textposition @ + C@ swap LShift and Cx-V !
                End-P @ textposition @ - C@ FFH and Cx-V +!

                Enc-Rotate \  Actual Encrypting & Decrypting of words

                \ reload values to buffer
                Cx-V @ Dup FF00H AND 8 rshift Start-P @ textposition @ + c!
                FFH and End-P @ textposition @ - c!

                1 pw-inc +! pw-inc @ PW-Size @ =
                if 0 pw-inc ! then
		pw-inc @ PWAdr + c@ to rot-v        	\ Load Rotate Value

                1 textposition +! textposition @ offset-v @ 2 / >=
        Until
;
\
\ ***************************************************************************************
\
: ?odd ( n -- f ) 2 /MOD drop ;
\
\ ***************************************************************************************
\
0 Value BufArd
0 Value Buf-size
\
: Enc-Main-Proc \ Updated 210915   ( PWAdr, PW-Size, BufArd, Buf-size, ?Lock  ---   )
\
to ?Lock to Buf-size to BufArd to PW-Size to PWAdr \ Values on the stack passed to the routine
0 0 0 0 pw-inc ! textposition ! new-start-p ! Cx-V ! \ initiate values to 0
\
BufArd Start-P !      \ set Starting point to the beginning of the Buffer
\
  Begin
        PWAdr pw-inc @ + C@
	Dup ?Odd Not	\ Is the value an odd number?
		If 1+ Then \ Offset-V needs to be an Odd number
	offset-v ! 	  \ Load Offset-V with byte from PW phrase

        1 pw-inc +! pw-inc @ PW-Size @ =
        if 0 pw-inc ! then             \ reset to 0 if at end of password buffer

        pw-inc @ PWAdr + c@ to rot-v        	\ Load Rotate Value
        Start-P @ offset-v @ + End-P !      \ Establish End Pt

        End-P @ BufArd Buf-size @ 1- + >
	\ End Pt at end of In-Buffer
        if   \ true if not at end of in-buffer
           BufArd Buf-size @ 1- + End-P !
           end-p @ start-p @ - offset-v !
       then

        End-P @ 1+ new-start-p !   \ Save next start pt
        Enc-Fetch
        new-start-p @ Start-P ! 0 textposition !
        new-start-p @ 1+ BufArd Buf-size @ + >

  until
;
\
\ ***************************************************************************************
\
