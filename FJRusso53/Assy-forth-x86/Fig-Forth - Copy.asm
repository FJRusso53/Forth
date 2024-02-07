Comment ~ 
Fig-Forth.asm
 FJRusso Vs 2.52  
 Saturday, January 06, 2024 11:25:12 AM  
 Frank's attempt at a Fig-FORTH Core in 32 bit Assmembler
 
 ACCOMPLISHMENTS:
 I/O Built
 ." , S" , . , ' , .S , .. ,
 emit, ms@, pause, wcount, words, ALLOT, ALLOCATE, FREE, TYPE,
 Constant, Variable, Value, TO, +TO, PARSE-STR, ANEW, FORGET, I2HEX, DUMP,
 [If], [Else], [Then], [BEGIN], [UNTIL], 
 OPEN-FILE, CREATE-FILE, CLOSE-FILE, FILE-EXIST, FILE-SIZE, READ-FILE,
 LOAD, 
 *****************************************************************************
 Above words are all working
 
 Notes to Self:
7 PROC CreateFile           : DONE
1 PROC CloseHandle          : DONE
4 PROC ReadFile             : DONE
4 PROC WriteFile
1 PROC DeleteFile
2 PROC MoveFile
4 PROC SetFilePointer       : DONE
1 PROC FlushFileBuffers
2 PROC SetEndOfFile
 invoke atodw, ADDR MyDecimalString                ; CONVERT ASCII STRING TO NUMBER (EAX)
 invoke dwtoa, dwValue:DWORD, lpBuffer:DWORD       ; CONVERT DWORD NUMBER TO ASCII STRING
 invoke udw2str, dwNumber:DWORD, pszString:DWORD   ; Convert unsigned DWORD to string
 invoke ustr2dw, ustr2dw proc pszString:DWORD      ; Convert string to unsigned DWORD (EAX)
 invoke Free, proc public pv:DWORD
 invoke GlobalUnlock, pMem
 invoke GlobalFree, hMemory
 invoke GlobalAlloc,0,TV1            ; GMEM_MOVEABLE=0 or GMEM_ZEROINIT=2
 invoke GlobalLock, hMemory
 hex2bin proc src:DWORD,dst:DWORD
 bin2hex proc lpString:DWORD,lnString:DWORD,lpbuffer:DWORD
 GetNumberOfConsoleInputEvents 
 GetSystemTime
 GetLocalTime
 typedef struct _SYSTEMTIME {
  WORD wYear;
  WORD wMonth;
  WORD wDayOfWeek;
  WORD wDay;
  WORD wHour;
  WORD wMinute;
  WORD wSecond;
  WORD wMilliseconds;
 } SYSTEMTIME, 
 ;
 Using MASM32 in VS 2022
 end of Comments ~
;
.486
.MODEL flat,stdcall
option casemap :none   ; case sensitive
;
.stack 4096 
;
; #########################################################################
;
      ;include \masm32\include\windows.inc
      ;include \masm32\macros\macros.asm
      ;
      include \masm32\include\masm32.inc
      ;include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      ;include \masm32\include\masm32rt.inc
      ;
      includelib \masm32\lib\masm32.lib
      ;includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
;
NEXTC macro byte
   MOV EAX, [EDI]
   ADD EDI, 4
   JMP DWORD PTR [EAX] 
endm
;
BRNEXT macro byte
   mov edi, [edi]
   mov eax, -4 [edi]
   jmp DWORD PTR [eax]
endm
;
Main   PROTO
;      
; #########################################################################
;
.code
;
Forth_Thread:
DD COLD         ; BOOT CALL
SCRINIT1:
DD SCRINIT      ; INITIALIZE SCREEN DISPLAY
ABORT1:
DD ABORT        ; USED AFTER COMPLETION OF ACTIONS
DD QUIT         ; ISSUES 'OK' PROMPT
DD TI1          ; THE TEXT INTERPRETER
;
; ---------------------------------------------------------------------------
;
    Start:
    .LISTALL
      	invoke Main
;
	LEA EDI, Forth_Thread 			; Load DI with Forth_Thread
	NEXTC
;
TI1: ; Text Interpreter
;
DD do_TI1
do_TI1:
PUSH $ + 10
JMP do_DOCOL
 @ACCEPT:                                        ; Label
 DD BEGIN@                                       ; CYCLE TILL 'bye' IS RECEIVED
 DD ACCEPT, DROP
 DD BEGIN@                                       ; CYCLE TRHOUGH INPUT STRING
 DD POC, ZCOUNT, PUSH0, FILL                     ; erase input buffer
 DD TIB, LIT, 32, WORD@                          ; INPUT BUFFER, SEARCH DELIMITER, PARSE INPUT STRING
 DD COUNT, FIND                                  ; GET LENGTH, LOCATE INPUT CHAR STRING IN DICTIONARY
 DD INTERPRET                                    ; CALL ADDRESS INTERPRETER
 DD S_LEN, @, _IN, @                             ; S_LEN _IN - 1 > 
 DD MINUS, PUSH1, GT@
 DD UNTIL@ 
 DD PUSH0, _IN, STORE, QUIT                    ; 0 _IN !  DISPLAY 'ok'
 DD QBYE
 DD UNTIL@ 
 DD @@EXIT
 @@EXIT:
 DD do_EXIT
 do_EXIT:
 LEA eax, CRLF+10
 push eax
 call StdOut
 lea eax, Msg8
 push eax
 call StdOut
 lea eax, Msg20
 push eax 
 call StdOut
 push 256
 LEA eax, TIB+9
 push eax
 call StdIn ; await Enter Key
 push 0
 call ExitProcess
;
EOI:
; #########################################################################
;
Main proc
  ; -------------------------------
  ; console mode library procedures
  ; -------------------------------
  lea eax, Msg9
  push eax
  call StdOut
;
ret
;
Main endp
;
; _________________________________________________________________________________
;  SYSTEM VARIABLES DEFINED ALL VERIFIED
;
ENDOFLINE:
DD 0000 
DD do_ENDOFLINE
DB 0, 9, 'ENDOFLINE'
do_ENDOFLINE:
NEXTC
;
_venum?: ; negate value flag
DD ENDOFLINE
venum?:
DD do_venum?
DB 0, 6, 'VENUM?'
do_venum?:
LEA EAX, VENUMQ
PUSH EAX
NEXTC
;
_Gone:
DD _venum?
DD do_Gone
DB 0, 4, 'GONE'
do_Gone:
LEA EAX, gone
PUSH EAX
NEXTC
;
_KEYIN:
DD _Gone
DD do_KEYIN
DB 0, 5, 'KEYIN'
do_KEYIN:
LEA EAX, KEYIN
PUSH EAX 
NEXTC
;
hMemory:
DD _KEYIN
DD do_HMEM
DB 0, 4, 'HMEM'
do_HMEM:
LEA EAX, _hMemory
PUSH EAX 
NEXTC
;
_pMem:
DD hMemory
DD do_PMEM
DB 0, 4, 'PMEM'
do_PMEM:
LEA EAX, pMem
PUSH EAX 
NEXTC
;
_MSG3:
DD _pMem
DD do_MSG3
DB 0, 4, 'MSG3'
do_MSG3:
LEA EAX, Msg3
PUSH EAX 
NEXTC
;
_MSG4:
DD _MSG3
DD do_MSG4
DB 0, 4, 'MSG4'
do_MSG4:
LEA EAX, Msg4
PUSH EAX 
NEXTC
;
_MSG22:
DD _MSG3
DD do_MSG22
DB 0, 5, 'MSG22'
do_MSG22:
LEA EAX, Msg22
PUSH EAX 
NEXTC
;
_SEP1:
DD _MSG22
DD do_SEP1
DB 0, 5,'SEP1$'
do_SEP1:
LEA EAX, SEP1$
PUSH EAX
NEXTC
;
_FCOUNTER:
DD _SEP1
DD do_FCOUNTER
DB 0, 8, 'FCOUNTER'
do_FCOUNTER:
LEA EAX, FCOUNTER
PUSH EAX
NEXTC
;
_MALADDR:
DD _FCOUNTER
DD do_MALADDR
DB 0, 11, 'MALLOCHADDR'
do_MALADDR:
LEA EAX, MALLOCHADDR
PUSH EAX
NEXTC
;
_S_ADR:
DD _MALADDR
DD do_S_ADR
DB 0, 5, 'S_ADR'
do_S_ADR:
LEA EAX, S_ADR
PUSH EAX
NEXTC
;
_RO:
DD _S_ADR
DD do_DOCON
DB 0, 3, 'R/O'
DD -2147483648
;
_WO:
DD _RO
DD do_DOCON
DB 0, 3, 'W/O'
DD 1073741824
;
_RW:
DD _WO
DD do_DOCON
DB 0, 3, 'R/W'
DD -1073741824
;
_UB:
DD _RW
DD do_UB
DB 0, 8, 'USERBASE'
do_UB:
LEA EAX, USER_BASE
PUSH EAX
NEXTC
;
_COMPF:
DD _UB
DD do_COMPF
DB 0, 6, 'COMPF?'
do_COMPF:
LEA EAX, COMPFQ
PUSH EAX
NEXTC
;
_MESSAGES:
DD _COMPF
DD do_MESSAGES
DB 0, 8, 'MESSAGES'
do_MESSAGES:
LEA EAX, MESSAGES
PUSH EAX
NEXTC
;
_MsgF1:
dd _MESSAGES
dd do_MsgF1
db 0, 5, 'MsgF1'
do_MsgF1:
LEA EAX, MsgF1
PUSH EAX
NEXTC
;
; ________________________________________________________________
;                       END OF SYSTEM VARIABLE SECTION
; ________________________________________________________________
;                       Dictionary Begins
; -------------------- PRIMITIVES CORE CODE ----------------------
;
_NULL:              ; VERIFIED   231224
DD _MsgF1
DD NULL
DB 0, 4, 'NULL'
NULL:
NEXTC
;
_COLD:      ; VERIFIED
DD _NULL 
COLD: 
DD do_COLD
DB 0, 4, 'COLD'
do_COLD:
PUSH ESP
POP [S0+8]                          ; Saving Stack Pointer Base 
MOV EBP, [RSP]                      ; RETURN STACK POINTER
LEA EAX, _EOD                       ; END OF DATA VERY LAST WORD IN DICTIONARY
PUSH EAX
POP [LATEST+12]
LEA EAX, USER_BASE
PUSH EAX
POP [DPR+9]
PUSH [PAD+9]
POP [HLD+9]
MOV [STATE+11], 0                   ;  Interpreter mode
    LEA EAX, USER_BASE              ; Calc Data SPACE USED 
    LEA ECX, DSB
    SUB EAX, ECX
    MOV [TV1+9], EAX                ; Need to convert value to string & display
    MOV EAX, EOC                    ; Calc Core SPACE USED 
    SUB EAX, Forth_Thread
    MOV [TV2+9], EAX                ; Need to convert value to string & display
    MOV EAX, MEMLIMIT
    SUB EAX, [DPR+9]                ; Calc Free Application space 
    MOV [TV3+9], EAX                ; Need to convert value to string & display
    LEA EAX, PAD+9                  ; RESET PAD POINTER
    MOV [HLD+9], EAX
    call GetProcessHeap 
    MOV MALLOCHADDR, EAX            ; heap address save in Variable
NEXTC
;
_ABT1:               ; USED IN NORMAL STARTUP
DD _COLD
ABT1:
DD do_ABT1
DB 0, 4, 'ABT1'
do_ABT1:
PUSH $ + 10
JMP do_DOCOL
DD WDCOUNT, PAD, DCW, @
DD DWTOA, PAD, PUSH0, STDOUT
DD CRLF, PUSH0, STDOUT
DD CRLF, PUSH0, STDOUT
DD PUSH0, ABFLG, STORE
DD SEMI
;
_ABT2:              ; USED WHEN ERROR OCCURS
DD _ABT1
ABT2:
DD do_ABT2
DB 0, 4, 'ABT2'
do_ABT2:
MOV [ABFLG+15], 0       ; RESET ABORTFLAG
MOV ESP, [S0+8]         ; RESET STACK POINTER
MOV EBP, [RSP]          ; RESET RETURN STACK POINTER
MOV [_IN+9], 0          ; RESET IN BUFFER OFFSET
MOV [S_LEN+11] ,0       ; RESET IN BUFFER LENGTH
LEA EDI, ABORT1
ADD EDI, 4              ; EDI POINTS TO QUIT IN FORTH THREAD
NEXTC
;
_ABORT:                 ; VERIFIED
DD _ABT2
ABORT: 
DD do_ABORT
DB 0, 5, 'ABORT'
do_ABORT:
PUSH $ + 10
JMP do_DOCOL
DD DECIMAL, PUSH0, STATE, STORE
DD ABFLG, @, EQU0
DD IF@, ABT1
DD ELSE@, ABT2
DD THEN@
DD SEMI
;
_ABORT@:
DD _ABORT
ABORT@:
DD do_ABORT@
DB 0, 7, '(ABORT)'
do_ABORT@:
MOV [ABFLG+15], -1
LEA EDI, ABORT1 ; Load DI with Forth_Thread
NEXTC
;
_SCRINIT:
DD _ABORT@
SCRINIT:
DD do_SCRINIT
DB 0, 7, 'SCRINIT'
do_SCRINIT:
    call ClearScreen
    push ypos
    push xpos
    call locate
    lea eax, Msg1
    push eax
    call StdOut
    lea eax, Msg1A
    push eax 
    call StdOut
    lea eax, Msg2
    push eax
    call StdOut
    lea eax, CRLF+11
    push eax 
    call StdOut
    lea eax, Msg12
    push eax
    call StdOut
    push [HLD+9]
    push TV1+9
    call udw2str        ; Convert unsigned DWORD to string
    push [HLD+9]
    call StdOut
    ADD [HLD+9], 16
    lea eax, Msg15 
    push eax
    call StdOut
    lea eax, Msg13
    push eax
    call StdOut
    push [HLD+9]
    push TV2+9
    call udw2str        ; Convert unsigned DWORD to string
    push [HLD+9]
    call StdOut
    ADD [HLD+9], 16
    lea eax, Msg15
    push eax
    call StdOut
    lea eax, Msg14
    push eax
    call StdOut
    push [HLD+9]
    push TV3+9
    call udw2str        ; Convert unsigned DWORD to string
    push [HLD+9]
    call StdOut
    ADD [HLD+9], 16
    lea eax, Msg16
    push eax
    call StdOut
    lea eax, Msg17
    push eax
    call StdOut
NEXTC
;
_SEMI:      ; VERIFIED  231224
DD _SCRINIT
SEMI:
DD do_SEMI
DB 0, 1, ';'
do_SEMI:
MOV EAX, [STATE+11]
CMP EAX, 0
JE SEM1
LEA EBX, do_SEMI
MOV EAX, [DPR+9]
MOV [EAX], EBX
PUSH [DPR+9]
POP EAX
ADD EAX, 4
PUSH EAX
POP [DPR+9]
NEXTC
SEM1:
MOV EDI, [EBP]
ADD EBP, 4
NEXTC
;
_PUSH1:      ; ( -- 1 ) PUSH 1 onto data stack   ; VERIFIED
DD _SEMI
PUSH1:
DD do_PUSH1
DB 0, 1, '1'    ; Name of Definition counted string name
do_PUSH1: 
PUSH 01H
NEXTC        ; End of definition
;
_RS:        ; Restore Stack pointer to base (  --  )    VERIFIED
DD _PUSH1
RS:
DD do_RS
DB 0, 2, '..'
do_RS:
MOV ESP, [S0+8]
NEXTC
;
_PUSH0:     ;( -- 0 ) PUSH 0 onto stack  ; VERIFIED
DD _RS
PUSH0:
DD do_PUSH0
DB 0, 1, '0'
do_PUSH0:
PUSH 0H
NEXTC
;
_LAST: ; Returns header addr of Last Word in Dict  VERIFIED 231227
DD _PUSH0
DD do_LAST
DB 0, 4,'LAST'
do_LAST:
MOV EAX, DWORD PTR [LATEST+12]
PUSH EAX
NEXTC
;
_COMPILE: ; ( XT -- )    compile xt following
DD _LAST
COMPILE: 
DD do_COMPILE
DB 0, 7,'COMPILE'
do_COMPILE:
mov  ebx, [edi] ; ip  equ  <edi>  Instruction Pointer for Forth
add  edi, 4
NEXTC
;
;   -------------------- Memory Operators -------------------------------------
;
_FETCH:  ; ( a1 -- n1 )  get the cell n1 from address a1    ; VERIFIED
DD _COMPILE 
@: 
DD do_FETCH
DB 0, 1, "@"
do_FETCH: 
    POP EBX 
    mov ebx, 0 [ebx]
    push ebx
    NEXTC
 ; 
_STORE:  ; ( n1 a1 -- )  store cell n1 into address a1   ; VERIFIED 240102
DD _FETCH   
STORE:
DD do_STORE
DB 0, 1, "!"
do_STORE: 
    POP EAX 
    POP EBX
    MOV [EAX], EBX
    NEXTC
 ; 
_PLUSSTORE:      ; ( n1 a1 -- ) add cell n1 to the contents of address a1   ; VERIFIED
DD _STORE  
PLUSSTORE:
DD do_PLUSSTORE
DB 0, 2, "+!"
do_PLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], eax
    NEXTC
 ; 
_MINUSSTORE:      ; ( n1 a1 -- ) add cell n1 to the contents of address a1  ; VERIFIED
DD _PLUSSTORE 
MINUSSTORE:
DD do_MINUSSTORE
DB 0, 2, "-!"
do_MINUSSTORE: 
    POP EBX 
    pop eax
    SUB 0 [ebx], eax
    NEXTC
 ;
_C@:      ; ( a1 -- c1 )     ;    fetch the character c1 from address a1 VERIFIED
DD _MINUSSTORE 
C@:
DD do_C@
DB 0, 2, "C@"
do_C@: 
    POP EBX 
    movzx ebx, byte ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
_CSTORE:      ; ( c1 a1 -- )     ;    store character c1 into address a1     VERIFIED
DD _C@ 
DD do_CSTORE
CSTORE:
DB 0, 2, "C!"
do_CSTORE: 
    POP EBX 
    pop eax
    mov 0 [ebx], al
    ; pop ebx
    NEXTC
 ; 
_CPLUSSTORE:    ; ( c1 a1 -- )     ;    add character c1 to the contents of address a1  VERIFIED
DD _CSTORE  
CPLUSSTORE:
DD do_CPLUSSTORE
DB 0, 3, "C+!"
do_CPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], al
    NEXTC
 ; 
WFETCH:      ; ( a1 -- w1 )     ;    fetch the word ; (16bit) w1 from address a1
DD _CPLUSSTORE
DD do_WFETCH
DB 0, 2, "W@"
do_WFETCH: 
    POP EBX 
    movzx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
SWFETCH:     ; ( a1 -- w1 )     ;    fetch and sign extend the word ; 
DD WFETCH 
DD do_SWFETCH
DB 0, 3, "SW@"
do_SWFETCH: 
    POP EBX 
    movsx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
WSTORE:      ; ( w1 a1 -- )     ;    store word ; (16bit) w1 into address a1
DD SWFETCH 
DD do_WSTORE
DB 0, 2, "W!"
do_WSTORE: 
    POP EBX 
    pop eax
    mov 0 [ebx], ax
    pop ebx
    NEXTC
 ; 
WPLUSSTORE:     ; ( w1 a1 -- )     ;    add word ; (16bit) w1 to the contents of address a1
DD WSTORE
DD do_WPLUSSTORE
DB 0, 3, "W+!"
do_WPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], ax
    pop ebx
    NEXTC
; 
_MEM?:                   ; ( -- n ) Checks memory useage limit  VERIFIED
DD WPLUSSTORE
MEM?:
DD do_MEM?
DB 0, 4, 'MEM?'
do_MEM?:
MOV EAX, MEMLIMIT
SUB EAX, [DPR+9]
PUSH EAX
NEXTC
;
;    -------------------- Char Operators ---------------------------------------

_CHARS:  ; ( n1 -- n1*char )  ;    multiply n1 by the character size ; (1)  VERIFIED
DD _MEM?
CHARS:
DD do_CHARS
DB 0, 5, "CHARS"
do_CHARS: 
    NEXTC
 ; 
_CHARPLUS:  ; ( a1 -- a1+char )  ;    add the characters size in bytes to a1  VERIFIED
DD _CHARS 
CHARPLUS:
DD do_CHARPLUS
DB 0, 5, "CHAR+"
do_CHARPLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
; 
;    -------------------- Arithmetic Operators ---------------------------------
;
_PLUS:   ; ( n1 n2 -- n3 )  add n1 to n2, return sum n3   ; VERIFIED
DD _CHARPLUS   
PLUS:
DD do_PLUS
DB 0, 1, "+"
do_PLUS: 
    POP EBX   ; n2
    pop eax   ; n1
    add eax, ebx   ; N1 + N2
    PUSH EAX
    NEXTC
 ; 
_MINUS:   ; ( n1 n2 -- n3 ) subtract n2 from n1, return difference n3   ; VERIFIED
DD _PLUS 
MINUS:
DD do_MINUS
DB 0, 1, "-"
do_MINUS: 
    POP EBX ; n2
    pop eax ; n1
    sub eax, ebx ; n1 - n2
    push eax
    NEXTC
 ; 
UNDERPLUS:   ; ( a x b -- a+b x )  ;    add top of stack to third stack item    VERIFIED
DD _MINUS 
DD do_UNDERPLUS
DB 0, 6, "UNDER+"
do_UNDERPLUS: 
    POP EBX 
    add 4 [esp], ebx
    NEXTC
 ; 
_NEGATE:   ; ( n1 -- n2 )  ;    negate n1, returning 2's complement n2  VERIFIED
DD UNDERPLUS  
NEGATE:
DD do_NEGATE
DB 0, 6, "NEGATE"
do_NEGATE: 
    POP EBX 
    neg ebx
    push ebx
    NEXTC
 ; 
_ABS:     ; ( n -- |n| )  ;    return the absolute value of n1 as n2    VERIFIED
DD _NEGATE 
ABS:
DD do_ABS
DB 0, 3, "ABS"
do_ABS: 
    POP EBX 
    mov ecx, ebx  ;    save value
    sar ecx, 31  ;    x < 0 ? 0xffffffff : 0
    xor ebx, ecx  ;    x < 0 ? ~x : x
    sub ebx, ecx  ;    x < 0 ? ; (~x)+1 : x
    push ebx
    NEXTC
 ; 
_2TIMES:      ; ( n1 -- n2 )  ;    multiply n1 by two       VERIFIED
DD _ABS 
TIMES2:
DD do_2TIMES
DB 0, 2, "2*"
do_2TIMES: 
    POP EBX 
    add ebx, ebx
    push ebx
    NEXTC
 ; 
_2DIVIDE:      ; ( n1 -- n2 )  ;    signed divide n1 by two     VERIFIED
DD _2TIMES 
DIVIDE2:
DD do_2DIVIDE
DB 0, 2, "2/"
do_2DIVIDE: 
    POP EBX 
    sar ebx, 1
    push ebx
    NEXTC
 ; 
U2DIVIDE:     ; ( n1 -- n2 )  ;    unsigned divide n1 by two
DD _2DIVIDE 
DD do_U2DIVIDE
DB 0, 3, "U2/"
do_U2DIVIDE: 
    POP EBX 
    shr ebx, 1
    PUSH EBX
    NEXTC
 ; 
_1PLUS:     ; ( n1 -- n2 )  add one to n1   ; VERIFIED
DD U2DIVIDE
PLUS1:
DD do_1PLUS
DB 0, 2, "1+"
do_1PLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
 ; 
 _2PLUS:     ; ( n1 -- n2 )  add one to n1   ; VERIFIED
DD _1PLUS
PLUS2:
DD do_2PLUS
DB 0, 2, "2+"
do_2PLUS: 
    POP EBX 
    add ebx, 2
    push ebx
    NEXTC
 ;
_1MINUS:      ; ( n1 -- n2 )  subtract one from n1    ; VERIFIED
DD _2PLUS
MINUS1:
DD do_1MINUS
DB 0, 2, "1-"
do_1MINUS: 
    POP EBX 
    sub ebx, 1
    push ebx
    NEXTC
 ; 
D2TIMES:     ; ( d1 -- d2 )  ;    multiply the double number d1 by two
DD _1MINUS
DD do_D2TIMES
DB 0, 3, "D2*"
do_D2TIMES: 
    POP EBX 
    pop eax
    shl eax, 1
    rcl ebx, 1
    push eax
    PUSH EBX
    NEXTC
 ; 
D2DIVIDE:     ; ( d1 -- d2 )  ;    divide the double number d1 by two
DD D2TIMES
DD do_D2DIVIDE
DB 0, 3, "D2/"
do_D2DIVIDE: 
    POP EBX 
    pop eax
    sar ebx, 1
    rcr eax, 1
    push eax
    PUSH EBX
    NEXTC
 ; 
RROT32:  	; ( n1 n2 -- ror) ; ( 32 Bit Rotation of word right)
DD D2DIVIDE
DD do_RROT32
DB 0, 6, "RROT32"
do_RROT32: 
 POP ECX
 POP EBX
 ror ebx, cl
 push ebx
    NEXTC
 ; 
LROT32:  	; ( n1 n2 -- rol) ; ( 32 Bit Rotation of word left)
DD RROT32
DD do_LROT32
DB 0, 6, "LROT32"
do_LROT32: 
 POP ECX 
 pop ebx
 rol ebx, cl
 push ebx
    NEXTC
 ; 
_GETADDR:  	; ( addr1, size, count -- addr2 )  ;    for an array
DD LROT32 
DD do_GETADDR
DB 0, 7, "GETADDR"
do_GETADDR: 
    POP EAX 
	pop ebx
	push edx
	imul ebx
	pop edx
	pop ebx
	add eax, ebx
	push eax
    NEXTC
;
_LIT:  ; ( -- n )  push the literal value following LIT in the ; VERIFIED
DD _GETADDR
LIT:
DD do_LIT
DB 0, 3, "LIT"
do_LIT:              ;  PUSH onto the data stack
    mov ebx, [EDI]
    PUSH EBX
    ADD EDI , 4
    NEXTC
 ; 
_DROP:  ; ( n -- )   discard top entry on data stack   ; VERIFIED
DD _LIT  
DROP:
DD do_DROP
DB 0, 4, "DROP"
do_DROP: 
    POP EBX 
    NEXTC
 ; 
_DUP:     ; ( n -- n n )    duplicate top entry on data stack   ; VERIFIED
DD _DROP  
DUP@:
DD do_DUP
DB 0, 3, "DUP"
do_DUP: 
    MOV EBX , 0 [ESP] 
    push ebx
    NEXTC
 ; 
_SWAP:  ; ( n1 n2 -- n2 n1 )  exchange first and second items on data stack  ; VERIFIED
DD _DUP  
SWAP:
DD do_SWAP
DB 0, 4, "SWAP"
do_SWAP: 
    POP EBX 
    mov eax, [esp]
    mov [esp], ebx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
_OVER:  ; ( n1 n2 -- n1 n2 n1 )  copy second item to top of data stack   ; VERIFIED
DD _SWAP
OVER:
DD do_OVER
DB 0, 4, "OVER"
do_OVER: 
    mov ebx, 4 [esp]
    PUSH EBX
    NEXTC
 ; 
_ROT:     ; ( n1 n2 n3 -- n2 n3 n1 )  rotate third item to top of data stack ; VERIFIED
DD _OVER 
ROT:
DD do_ROT
DB 0, 3, "ROT"
do_ROT: 
    POP EBX 
    mov ecx, 0 [esp]
    mov eax, 4 [esp]
    mov 0 [esp], ebx
    mov 4 [esp], ecx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
MINUSROT:  ; ( n1 n2 n3 -- n3 n1 n2 )  ;    rotate top of data stack to third item  VERIFIED
DD _ROT   
DD do_MINUSROT
DB 0, 4, "-ROT"
do_MINUSROT: 
    POP EBX 
    mov ecx, 4 [esp]
    mov eax, 0 [esp]
    mov 4 [esp], ebx
    mov 0 [esp], ecx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
IFDUP:  ; ( n -- n [n] )  ;    duplicate top of data stack if non-zero      VERIFIED
DD MINUSROT
DD do_IFDUP
DB 0, 4, "?DUP"
do_IFDUP: 
    POP EBX 
    PUSH EBX
    test    ebx, ebx
    je short @@1A
    push    ebx
@@1A:
    NEXTC
 ; 
_NIP:     ; ( n1 n2 -- n2 )  ;    discard second item on data stack      VERIFIED
DD IFDUP 
NIP:
DD do_NIP
DB 0, 3, "NIP"
do_NIP: 
    POP EBX 
    POP EAX
    PUSH EBX
    NEXTC
 ; 
TUCK:  ; ( n1 n2 -- n2 n1 n2 )  ;    copy top data stack to under second item      VERIFIED 
DD _NIP       ; SWAP OVER
DD do_TUCK
DB 0, 4, "TUCK"
do_TUCK: 
    POP EBX
    PUSH 0 [ESP]
    MOV 4 [ESP], EBX
    PUSH EBX
    NEXTC
 ; 
_PICK:  ; ( ... k -- ... n[k] )   VERIFIED     
DD TUCK 
PICK:
DD do_PICK
DB 0, 4, "PICK"
do_PICK: 
    POP EBX 
    mov ebx, 0 [esp] [ebx*4]  ;    just like that!
    PUSH EBX
    NEXTC
; 
;   -------------------- Double Arithmetic Operators --------------------------
_StoD:       ; ( n1 -- d1 )   convert single signed single n1 to a signed double d1
DD _PICK 
StoD:
DD do_StoD
DB 0, 3, 'S>D'
do_StoD:
    pop     ebx
    push    ebx
    shl     ebx, 1         ;   put sign bit into carry
    sbb     ebx, ebx
    push    ebx
    NEXTC
;
;    -------------------- Cell Operators ---------------------------------------

_CELL:  ; ( -- 4 ) cell size        ; VERIFIED
DD _StoD  
CELL:
DD do_CELL
DB 0, 4, "CELL"
do_CELL: 
    PUSH 4
    NEXTC
 ; 
_CELLS:  ; ( n1 -- n1*cell )  ;    multiply n1 by the cell size     ; VERIFIED
DD _CELL 
CELLS:
DD do_CELLS
DB 0, 5, "CELLS"
do_CELLS: 
    POP EBX 
    shl ebx, 2
    PUSH EBX
    NEXTC
 ; 
_CELLSPLUS:  ; ( a1 n1 -- a1+n1*cell )  ;    multiply n1 by the cell size and add  ; VERIFIED
DD _CELLS 
CELLSPLUS:
DD do_CELLSPLUS
DB 0, 6, "CELLS+"
do_CELLSPLUS: 
    POP EBX 
     ;    the result to address a1
    pop eax
    lea ebx, 0 [ebx*4] [eax]
    PUSH EBX
    NEXTC
 ; 
_CELLSMINUS:  ; ( a1 n1 -- a1-n1*cell )  ;    multiply n1 by the cell size and subtract  ; VERIFIED
DD _CELLSPLUS 
CELLSMINUS:
DD do_CELLSMINUS
DB 0, 6, "CELLS-"
do_CELLSMINUS: 
    POP EBX 
     ;    the result from address a1
    lea eax, 0 [ebx*4]
    pop ebx
    sub ebx, eax
    PUSH EBX
    NEXTC
 ; 
_CELLPLUS:  ; ( a1 -- a1+cell )  ;    add a cell to a1  ; VERIFIED
DD _CELLSMINUS  
CELLPLUS:
DD do_CELLPLUS
DB 0, 5, "CELL+"
do_CELLPLUS: 
    POP EBX 
    add ebx, 4
    PUSH EBX
    NEXTC
 ; 
_CELLMINUS:  ; ( a1 -- a1-cell )  ;    subtract a cell from a1  ; VERIFIED
DD _CELLPLUS 
CELLMINUS:
DD do_CELLMINUS
DB 0, 5, "CELL-"
do_CELLMINUS: 
    POP EBX 
    sub ebx, 4
    PUSH EBX
    NEXTC
 ; 
_PLUSCELLS:  ; ( n1 a1 -- n1*cell+a1 )  ;    multiply n1 by the cell size and add ; VERIFIED
DD _CELLMINUS 
PLUSCELLS:
DD do_PLUSCELLS
DB 0, 6, "+CELLS"
do_PLUSCELLS: 
    POP EBX 
     ;    the result to address a1
    pop eax
    lea ebx, 0 [eax*4] [ebx]
    PUSH EBX
    NEXTC
 ; 
_MINUSCELLS:  ; ( n1 a1 -- a1-n1*cell )  ;    multiply n1 by the cell size and ; VERIFIED
DD _PLUSCELLS  
MINUSCELLS:
DD do_MINUSCELLS
DB 0, 6, "-CELLS"
do_MINUSCELLS: 
    POP EBX 
     ;    subtract the result from address a1
    pop eax
    shl eax, 2
    sub ebx, eax
    PUSH EBX
    NEXTC
; 
;    -------------------- Stack Operations -------------------------------------
;
_DEPTH:         ; ( -- n ) return the current data stack depth (n excluded)  ; VERIFIED
DD _MINUSCELLS
DEPTH:
DD do_DEPTH
DB 0, 5, 'DEPTH'
do_DEPTH:
    mov     ebx, [S0+8] 
    sub     ebx, esp
    sar     ebx, 2  ; shift right two is divide by 4
    PUSH EBX
    NEXTC
;
SPFETCH:     ; ( -- addr )  ;    get addr, the pointer to the top item on data stack  ; VERIFIED
DD _DEPTH    
DD do_SPFETCH
DB 0, 3, "SP@"
do_SPFETCH: 
    PUSH ESP
    NEXTC
 ;  
SPSTORE:     ; ( addr -- )  ;    set the data stack to point to addr   ; VERIFIED
DD SPFETCH  
DD do_SPSTORE
DB 0, 3, "SP!"
do_SPSTORE: 
    POP EBX 
    mov esp, ebx
    NEXTC
 ; 
RPFETCH:     ; ( -- a1 )  ;    get a1 the address of the return stack   ; VERIFIED
DD SPSTORE     
DD do_RPFETCH
DB 0, 3, "RP@"
do_RPFETCH: 
    PUSH EBP
    NEXTC
 ; 
RPSTORE:     ; ( a1 -- )  ;    set the address of the return stack   ; VERIFIED
DD RPFETCH 
DD do_RPSTORE
DB 0, 3, "RP!"
do_RPSTORE: 
    POP EBX 
    mov EBP, ebx
    NEXTC
 ; 
_TOR:      ; ( n1 -- ) ; ( R: -- n1 )  push n1 onto the return stack   ; VERIFIED
DD RPSTORE 
TOR:
DD do_TOR
DB 0, 2, ">R"
do_TOR: 
POP EAX
SUB EBP, 4
MOV [EBP], EAX
NEXTC
 ; 
_FROMR:      ; ( -- n1 ) ; ( R: n1 -- )  ;    pop n1 off the return stack  ; VERIFIED
DD _TOR
FROMR:
DD do_FROMR
DB 0, 2, "R>"
do_FROMR: 
MOV EAX, [EBP] 
PUSH EAX
ADD EBP, 4
NEXTC
 ; 
_RFETCH:      ; ( -- n1 ) ; ( R: n1 -- n1 )  ;    get a copy of the top of the return stack  ; VERIFIED
DD _FROMR
DD do_RFETCH
DB 0, 2, "R@"
do_RFETCH: 
MOV EAX, [EBP]
PUSH EAX
NEXTC
 ; 
_DUPTOR:  ; ( n1 -- n1 ) ; ( R: -- n1 )  ;    push a copy of n1 onto the return stack  ; VERIFIED
DD _RFETCH 
DUPTOR:
DD do_DUPTOR
DB 0, 5, "DUP>R"
do_DUPTOR: 
    mov ebx, [ESP]
    SUB EBP, 4
    mov [EBP], ebx
    NEXTC
 ; 
_RFROMDROP:  ; ( -- ) ; ( R: n1 -- )  ;    discard one item off of the return stack  ; VERIFIED
DD _DUPTOR  
RFROMDROP:
DD do_RFROMDROP
DB 0, 6, "R>DROP"
do_RFROMDROP: 
    ADD EBP, 4
    NEXTC
 ; 
_2TOR:     ; ( n1 n2 -- ) ; ( R: -- n1 n2 )  ;    push two items onto the return stack  ; VERIFIED
DD _RFROMDROP 
@2TOR:
DD do_2TOR
DB 0, 3, "2>R"
do_2TOR: 
    POP EBX
    SUB EBP, 4
    MOV [EBP], EBX
    POP EBX
    SUB EBP, 4
    MOV [EBP], EBX
    NEXTC
 ; 
_2RFROM:    ; ( -- n1 n2 ) ; ( R: n1 n2 -- )  ;    pop two items off the return stack  ; VERIFIED
DD _2TOR  
FROMR2:
DD do_2RFROM
DB 0, 3, "2R>"
do_2RFROM: 
    PUSH [EBP]
    ADD EBP, 4
    PUSH [EBP]
    ADD EBP, 4
    NEXTC
 ; 
_2RFETCH:     ; ( -- n1 n2 )     ;    get a copy of the top two items on the return stack  ; VERIFIED
DD _2RFROM  
DD do_2RFETCH
DB 0, 3, "2R@"
do_2RFETCH: 
   PUSH [EBP]
   PUSH [EBP+4]
   NEXTC
 ; 
_2DUP:     ; ( N1 N2 -- N1 N2 n1 n2 )  DUPLICATE TOP 2 ITEMS ON STACK       ; VERIFIED
DD _2RFETCH  
DUP2:
DD do_2DUP
DB 0, 4, "2DUP"
do_2DUP: 
    MOV EBX , 4 [ESP]
    MOV EAX , 0 [ESP]
    PUSH EBX
    PUSH EAX
    NEXTC
 ; 
_2DROP:     ; ( n1 n2 -- )  DROP TOP 2 ITEMS ON STACK ; VERIFIED
DD _2DUP 
DD do_2DROP
DB 0, 5, "2DROP"
do_2DROP: 
    ADD ESP, 8
    NEXTC
;
;   -------------------- Comparison Operators ---------------------------------

_EQU0:          ; ( n1 -- f1 )      return true if n1 equals zero  ; VERIFIED
DD _2DROP
EQU0 DD do_EQU0
DB 0, 2, "0="
do_EQU0:
    POP EBX
    sub     ebx,  1
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_0NE:         ; v( n1 -- f1 )      return true if n1 is not equal to zero  ; VERIFIED
DD _EQU0
@0NE:
DD do_0NE
DB 0, 3, "0<>"
do_0NE:
    POP EBX
    sub     ebx, 1
    sbb     ebx, ebx
    not     ebx
	push ebx
    NEXTC
;
_0LT:         ; ( n1 -- f1 )      return true if n1 is less than zero  ; VERIFIED
DD _0NE
DD do_0LT
DB 0, 2, "0<"
do_0LT:
    POP EBX
    sar ebx,  31
	push ebx
    NEXTC
 ;
_0GT:          ; ( n1 -- f1 )      return true (-1) if n1 is greater than zero  ; VERIFIED
DD _0LT
DD do_0GT
DB 0, 2, "0>"
do_0GT:
    POP EBX
    dec     ebx
    cmp     ebx, 7fffffffh
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_EQU:          ; ( n1 n2 -- f1 )   return true (-1) if n1 is equal to n2  ; VERIFIED
DD _0GT
EQU@:
DD do_EQU
DB 0, 1, "="
do_EQU:
    POP EBX
    pop     eax
    sub     ebx, eax
    sub     ebx, 1
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_NEQ:         ; ( n1 n2 -- f1 )   return true if (-1) n1 is not equal to n2  ; VERIFIED
DD _EQU
NEQ:
DD do_NEQ
DB 0, 2, "<>"
do_NEQ:
    POP EBX
    pop     eax
    sub     eax, ebx
    neg     eax
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_LT:          ; ( n1 n2 -- f1 )   return true if n1 is less than n2   ; VERIFIED
DD _NEQ
LT@:
DD do_LT
DB 0, 1, "<"
do_LT:
    POP EBX
    pop eax
    cmp eax, ebx
    JB short @@1
    xor ebx, ebx
	push ebx
    NEXTC
@@1:       
    mov ebx, -1
	push ebx
    NEXTC
 ;
_GT:          ; ( n1 n2 -- f1 )   return true if n1 is greater than n2  ; VERIFIED
DD _LT
GT@:
DD do_GT
DB 0, 1, ">"
do_GT:
    POP EBX
    pop eax
    cmp eax, ebx
    JA  short @@1
    xor ebx, ebx
	push ebx
    NEXTC
 ;
_LTE:         ; ( n1 n2 -- f1 )   return true if n1 is less than n2  ; VERIFIED 
DD _GT
DD do_LTE
DB 0, 2, "<="
do_LTE:
    POP EBX
    pop eax
    cmp eax, ebx
    JBE short @@1
    xor ebx, ebx
	push ebx
    NEXTC
;
_GTE:        ;  ( n1 n2 -- f1 )   return true if n1 is greater than n2   ; VERIFIED
DD _LTE
DD do_GTE
DB 0, 2, ">="
do_GTE:
    POP EBX
    pop eax
    cmp eax, ebx
    JAE short @@1
    xor ebx, ebx
	push ebx
    NEXTC
 ;
ULT:        ;  ( u1 u2 -- f1 )   return true if unsigned u1 is less than  
DD _GTE
DD do_ULT
DB 0, 2, "U<"
do_ULT:
    POP EBX  ;   unsigned u2
    pop eax
    cmp eax, ebx
    sbb ebx, ebx
	push ebx
    NEXTC
 ;
UGT:         ; ( u1 u2 -- f1 )   return true if unsigned u1 is greater than
DD ULT
DD do_UGT
DB 0, 2, "U>"
do_UGT:
    POP EBX   ;   unsigned n2
    pop eax
    cmp ebx, eax
    sbb ebx, ebx
	push ebx
    NEXTC
 ;
DULT:        ; ( ud1 ud2 -- f1 )   return true if unsigned double ud1 is
DD UGT
DD do_DULT
DB 0, 3, "DU<"
do_DULT:
    POP EBX ;   less than unsigned double ud2
    pop     eax
    pop     ecx
    xchg    edx, 0 [esp]    ;  save UP
    sub     edx, eax
    sbb     ecx, ebx
    sbb     ebx, ebx
    pop     edx             ;  restore UP
	push ebx
    NEXTC
 ;
UMIN:       ; ( u1 u2 -- n3 )   return the lesser of unsigned u1 and
DD DULT
DD do_UMIN
DB 0, 4, "UMIN"
do_UMIN:
    POP EBX ;  unsigned u2
    pop     eax
    cmp     ebx, eax
    jb      @@1UMN
    mov     ebx, eax
@@1UMN:
	push ebx
    NEXTC
 ;
_MIN:        ; ( n1 n2 -- n3 )   return the lesser of n1 and n2  ; VERIFIED
DD UMIN
MIN:
DD do_MIN
DB 0, 3, "MIN"
do_MIN:
    POP     EBX
    pop     eax
    cmp     ebx, eax
    JB      @@1MN
    mov     ebx, eax
@@1MN:
	push    ebx
    NEXTC
 ;
_UMAX:       ; ( u1 u2 -- n3 )   return the greater of unsigned u1 and U2   ; VERIFIED
DD _MIN
DD do_UMAX
DB 0, 4, "UMAX"
do_UMAX:
    POP EBX ;  unsigned u2
     pop     eax
     cmp     ebx, eax
     ja      @@1UMX
     mov     ebx, eax
@@1UMX:
	 push ebx
    NEXTC
 ;
_MAX:       ;  ( n1 n2 -- n3 )   return the greater of n1 and n2   ; VERIFIED
DD _UMAX
DD do_MAX
DB 0, 3, "MAX"
do_MAX:
    POP EBX
    pop     eax
    cmp     ebx, eax
    JA      @@1MX
    mov     ebx, eax
@@1MX:
	push ebx
    NEXTC
 ;
_0MAX:       ; ( n1 -- n2 )   return n2 the greater of n1 and zero   ; VERIFIED
DD _MAX
DD do_0MAX
DB 0, 4, "0MAX"
do_0MAX:
    POP EBX
    cmp     ebx, 0
    JA      @@10MX
    xor     ebx, ebx
@@10MX:
	push ebx
    NEXTC
 ;
_WITHIN:     ; ( n1 low high -- f1 )   f1=true if ( (n1 >= low) and (n1 < high) )   ; VERIFIED
DD _0MAX
DD do_WITHIN
DB 0, 6, "WITHIN"
do_WITHIN:
    POP EBX
    pop     eax
    pop     ecx
    sub     ebx, eax
    sub     ecx, eax
    sub     ecx, ebx
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_BETWEEN:     ; ( n1 low high -- f1 )   f1=true if ( (n1 >= low) and (n1 <= high) )   ; VERIFIED
DD _WITHIN
DD do_BETWEEN
DB 0, 7, "BETWEEN"
do_BETWEEN:
    POP EBX
    add     ebx, 1      ;  bump high
    pop     eax
    pop     ecx
    sub     ebx, eax
    sub     ecx, eax
    sub     ecx, ebx
    sbb     ebx, ebx
	push ebx
    NEXTC
;

;   -------------------- Double memory Operators ------------------------------

_2FETCH:          ; ( a1 -- d1 )   fetch the double number d1 from address a1
DD _BETWEEN
DD do_2FETCH
DB 0, 2, "2@"
do_2FETCH:
    POP EBX
    push    4 [ebx]
     mov     ebx, 0 [ebx]
	push ebx
    NEXTC
 ;
_2STORE:          ; ( d1 a1 -- )   store the double number d1 into address a1
DD _2FETCH
DD do_2STORE
DB 0, 2, "2!"
do_2STORE:
    POP EBX
    pop     0 [ebx]
    pop     4 [ebx]
    pop     ebx
    NEXTC
;

;   -------------------- Double Stack Operators -------------------------------

_2NIP:       ;  ( n1 n2 n3 n4 -- n3 n4 )   discard third and fourth items from data stack  ; VERIFIED
DD _2STORE
DD do_2NIP
DB 0, 4, "2NIP"
do_2NIP:
    POP EBX
    pop     eax
    mov     4 [esp], eax
    pop     eax
	push ebx
    NEXTC
 ;
_2SWAP:      ; ( n1 n2 n3 n4 -- n3 n4 n1 n2 )   exchange the two topmost doubles  ; VERIFIED
DD _2NIP
SWAP2:
DD do_2SWAP
DB 0, 5, "2SWAP"
do_2SWAP:
    POP EBX
    mov     eax, 4 [esp]      ;  eax=n2
    mov     ecx, 8 [esp]      ;  ecx=n1
    mov     4 [esp], ebx      ;  n1 n4 n3 eax=n2 ecx=n1 ebx=n4
    mov     ebx, 0 [esp]      ;  ebx=3
    mov     0 [esp], ecx      ;  n3 n4 n1
    mov     8 [esp], ebx      ;  n3 n4 n3
    mov     ebx, eax          ;  n3 n4 n1 n2
	push ebx
    NEXTC
 ;
_2OVER:      ; ( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2 )   copy second double on top  ; VERIFIED
DD _2SWAP
DD do_2OVER
DB 0, 5, "2OVER"
do_2OVER:
    POP EBX
                mov     eax, 8 [esp]
                push    ebx
                push    eax
                mov     ebx, 12 [esp]
		push ebx
    NEXTC
 ;
_2ROT:       ; ( n1 n2 n3 n4 n5 n6 -- n3 n4 n5 n6 n1 n2 )   VERIFIED
DD _2OVER
DD do_2ROT
DB 0, 4, "2ROT"
do_2ROT:
    POP EBX
                pop     eax
                xchg    ebx, 0 [esp]
                xchg    eax, 4 [esp]
                xchg    ebx, 8 [esp]
                xchg    eax, 12 [esp]
                push    eax
		push ebx
    NEXTC
 ;
_3DROP:      ; ( n1 n2 n3 -- )   discard three items from the data stack  ; VERIFIED 
DD _2ROT
DD do_3DROP
DB 0, 5, "3DROP"
do_3DROP:
    add     esp, 12
    NEXTC
 ;
_4DROP:      ; ( n1 n2 n3 n4 -- )   discard four items from the data stack   ; VERIFIED
DD _3DROP
DD do_4DROP
DB 0, 5, "4DROP"
do_4DROP:
    add     esp, 16
    NEXTC
 ;
_3DUP:       ; ( n1 n2 n3 -- n1 n2 n3 n1 n2 n3 )   duplicate 3 topmost cells  ; VERIFIED
DD _4DROP
DD do_3DUP
DB 0, 4, "3DUP"
do_3DUP:
    POP EBX
                mov     eax, 0 [esp]      ;  n2
                mov     ecx, 4 [esp]      ;  n1
                push    ebx               ;  n3
                push    ecx               ;  n1
                push    eax               ;  n2
		push ebx
    NEXTC
 ;
_4DUP:       ; ( a b c d -- a b c d a b c d )   duplicate 4 topmost cells  ; VERIFIED
DD _3DUP
DD do_4DUP
DB 0, 4, "4DUP"
do_4DUP:
    POP EBX
    mov     eax, 8 [esp]
    push    ebx
    push    eax
    mov     ebx, 12 [esp]
    mov     eax, 8 [esp]
    push    ebx
    push    eax
    mov     ebx, 12 [esp]
	push ebx
    NEXTC
;
; \ -------------------- Signed Multiply & Divide -----------------------------
;
_MODIVIDE:       ; ( n1 n2 -- rem quot ) \ integer signed single divide with remainder & quotient
DD _4DUP
MODIVIDE:
DD do_MODIVIDE
DB 0, 4, '/MOD'
do_MODIVIDE:
  POP     EBX
  pop     ecx
  mov     eax, ecx
  xor     eax, ebx
  jns     short @@1A1
  mov     eax, ecx        ; low order part to eax
  mov     ecx, edx        ; save UP
  cdq
  idiv    ebx
  test    edx, edx        ; set zero flag
  je      short @@2
  add     edx, ebx        ; add divisor to remainder
  sub     eax, 1             ; decrement quotient
  jmp     short @@2
@@1A1:
  mov     eax, ecx        ; low order part to eax
  mov     ecx, edx
  cdq
  idiv    ebx
@@2:            
  push    edx
  mov     ebx, eax
  mov     edx, ecx        ; restore UP
  PUSH    EBX
NEXTC
;
_MMULT:                     ; CODE M*         ( n1 n2 -- d1 )     VERIFIED 231202
DD _MODIVIDE                ; \ multiply n1 by n2, return double result d1
DD do_MMULT
DB 0, 2, 'M*'
do_MMULT:
   POP EBX
   mov     ecx, edx        ;\ save UP
   pop     eax
   imul    ebx
   push    eax
   mov     ebx, edx
   mov     edx, ecx        ;\ restore UP
   PUSH EBX
   NEXTC
;
_MULT:                      ; CODE *          ( n1 n2 -- n3 )   VERIFIED 231202
DD _MMULT                   ; \ multiply n1 by n2, return single result n3
DD do_MULT
DB 0, 1, '*'
do_MULT:
   POP EBX
   mov     ecx, edx       ; \ save UP
   pop     eax
   mul     ebx
   mov     ebx, eax
   mov     edx, ecx       ; \ restore UP
   PUSH EBX
   NEXTC
;
comment ~

CODE SM/REM     ( d n -- rem quot )
                mov     ecx, edx        \ save UP
                pop     edx
                pop     eax
                idiv    ebx
                push    edx
                mov     ebx, eax
                mov     edx, ecx        \ restore UP
                next    c;

CODE FM/MOD     ( d n -- rem quot )
                pop     ecx             \ high numerator
                mov     eax, ecx        \ copy for testing
                xor     eax, ebx        \ test against denominator
                jns     short @@1       \ if signs differ jump

                xchg    ecx, edx        \ save UP
                pop     eax
                idiv    ebx
                test    edx, edx        \ set zero flag
                je      short @@2
                add     edx, ebx        \ add divisor to remainder
                sub     eax, # 1             \ decrement quotient
                jmp     short @@2

@@1:            xchg    ecx, edx        \ preserve DX in CX, DX=high num
                pop     eax             \ EAX=low numerator
                idiv    ebx             \ perform the division

@@2:            push    edx             \ push remainder
                mov     ebx, eax        \ quotient to EBX
                mov     edx, ecx        \ restore UP
                next    c;

CODE */MOD      ( n1 n2 n3 -- remainder quotient ) \ integer single multiply and divide:
                \ give remainder and quotient of [n1*n2]/n3. Intermediate result n1*n2
                \ is a double, so there is no overflow.
                pop     ecx
                pop     eax
                push    edx             \ save UP
                imul    ecx
                mov     ecx, edx
                xor     ecx, ebx
                jns     short @@1

                idiv    ebx
                test    edx, edx        \ set zero flag
                je      short @@2
                add     edx, ebx        \ add divisor to remainder
                sub     eax, # 1             \ decrement quotient
                jmp     short @@2

@@1:            idiv    ebx
@@2:            mov     ebx, eax
                pop     ecx
                push    edx
                mov     edx, ecx        \ restore UP
                next    c;

: */            ( n1 n2 n3 -- quotient ) \ same as */MOD but gives only quotient
                */MOD NIP ;
~
;
;   ------------------------ String counting -----------------------
;
_COUNT:      ; ( str -- addr len ) byte counted strings      ; VERIFIED
DD _MULT
COUNT:
DD do_COUNT
DB 0, 5, "COUNT"
do_COUNT:
   MOV EBX, [ESP]
   movzx   ebx, byte ptr  [ebx-1]
   push    ebx
   NEXTC
 ;
WCOUNT:    ;  ( str -- addr len )    word (2 bytes) counted strings
DD _COUNT
DD do_WCOUNT
DB 0, 6, "WCOUNT"
do_WCOUNT:
    POP EBX
    add     ebx, 2
    push    ebx
    movzx   ebx, word ptr [ebx-2]
	push ebx
    NEXTC
 ;
LCOUNT:    ;  ( str -- addr len )    long (4 bytes) counted strings
DD WCOUNT
DD do_LCOUNT
DB 0, 6, "LCOUNT"
do_LCOUNT:
    POP EBX
    add  ebx, 4
    push ebx
    mov  ebx,  [ebx-4]
	push ebx
    NEXTC
 ;
_ZCOUNT:     ; ( str -- addr len ) null terminated string, whose 1st char is at addr   ; VERIFIED
DD LCOUNT
ZCOUNT:
DD do_ZCOUNT
DB 0, 6, "ZCOUNT"
do_ZCOUNT:
        MOV     EBX, [ESP]
        PUSH    EDI
        mov     ecx, -1                 ;  scan way on up there... it had better stop!
        xor     eax, eax                ;  look for null
        mov     edi, ebx                ;  edi = absolute address of string
        repnz   scasb
        add     ecx, 2
        neg     ecx
        POP     EDI
	    push    ecx
    NEXTC
;
_ADJSTRING:    ; ( c-addr1 u1 n -- c-addr2 u2 )    ; VERIFIED
; /STRING is used to remove or add characters relative to the left end of the
; ** character string. Positive values of n will exclude characters from the string
; ** while negative values of n will include characters to the left of the string.
DD _ZCOUNT
ADJSTRING:
DD do_ADJSTRING
DB 0, 7, '/STRING'
do_ADJSTRING:
                POP     EBX
                pop     eax
                test    ebx, ebx       ; Added two lines to allow a negative argument
                JBE     short @@1SDJ   ; to be passed to /STRING, so the string will
                cmp     ebx, eax       ; be expanded.
                JBE     short @@1SDJ   
                mov     ebx, eax
@@1SDJ:         add     0 [esp], ebx
                sub     eax, ebx
                mov     ebx, eax
                PUSH    EBX
NEXTC
;
ADDNULL:     ; ( c-addr -- )  Append a NULL to the counted string.    ; VERIFIED
DD _ADJSTRING
DD do_ADDNULL
DB 0, 5, '+NULL'
do_ADDNULL:
   POP     EBX
   mov     CL, BYTE PTR [ebx-1]         ; length
   AND     ECX, 00FFH
   ADD     EBX, ECX
   mov     BYTE PTR [EBX], 0                 ; zero the char
   NEXTC
;
;    -------------------- Logical Operators ------------------------------------

_AND:     ; ( n1 n2 -- n3 )  ;    perform bitwise AND of n1,n2, return result n3     ; VERIFIED
DD ADDNULL
AND@:
DD do_AND
DB 0, 3, "AND"
do_AND:
    POP EBX
    pop ecx
    and ebx, ecx
    push ebx
    NEXTC
 ;
_OR:      ; ( n1 n2 -- n3 )  ;    perform bitwise OR of n1,n2, return result n3    ; VERIFIED
DD _AND
OR@:
DD do_OR
DB 0, 2, "OR"
do_OR:
    POP EBX
    pop ecx
    or ebx, ecx
    push ebx
    NEXTC
 ;
_XOR:     ; ( n1 n2 -- n3 )  ;    perform bitwise XOR of n1,n2, return result n3    ; VERIFIED
DD _OR
XOR@:
DD do_XOR
DB 0, 3, "XOR"
do_XOR:
    POP EBX
    pop ecx
    xor ebx, ecx
    push ebx
    NEXTC
 ;
_INVERT:  ; ( n1 -- n2 )     ;    perform a bitwise -1 XOR on n1, return result n2    ; VERIFIED
DD _XOR
DD do_INVERT
DB 0, 6, "INVERT"
do_INVERT:
    POP EBX
    not ebx
    push ebx
    NEXTC
 ;
_LSHIFT:  ; ( u1 n -- u2 )  ;    shift u1 left by n bits ; (multiply)    ; VERIFIED
DD _INVERT
DD do_LSHIFT
DB 0, 6, "LSHIFT"
do_LSHIFT:
    POP EBX
    mov ecx, ebx
    pop ebx
    shl ebx, cl
    push ebx
    NEXTC
 ;
_RSHIFT:  ; ( u1 n -- u2 )  ;    shift u1 right by n bits ; (divide)    ; VERIFIED
DD _LSHIFT
DD do_RSHIFT
DB 0, 6, "RSHIFT"
do_RSHIFT:
    POP EBX
    mov ecx, ebx
    pop ebx
    shr ebx, cl
    push ebx
    NEXTC
 ;
_INCR:  ; ( addr -- )  ;    increment the contents of addr 
DD _RSHIFT
INCR@:
DD do_INCR
DB 0, 4, "INCR"
do_INCR:
    POP EBX
    add dword ptr 0 [ebx],  1
    NEXTC
 ;
_DECR:  ; ( addr -- )  ;    decrement the contents of addr 
DD _INCR
DECR@:
DD do_DECR
DB 0, 4, "DECR"
do_DECR:
    POP EBX
    sub dword ptr 0 [ebx],  1
    NEXTC
 ;
CINCR:  ; ( addr -- )  ;    increment the BYTE contents of addr
DD _DECR
DD do_CINCR
DB 0, 5, "CINCR"
do_CINCR:
    POP EBX
    mov eax, [ebx]
    add eax,  1
    mov [ebx], eax
    NEXTC
 ;
CDECR:  ; ( addr -- )  ;    decrement the BYTE contents of addr
DD CINCR
DD do_CDECR
DB 0, 5, "CDECR"
do_CDECR:
    POP EBX
    mov eax, [ebx]
    sub eax,  1
    mov [ebx], eax
    NEXTC
 ;
_ON:      ; ( addr -- )  ;    set the contents of addr to ON ; (-1)
DD CDECR
DD do_ON
ON:
DB 0, 2, "ON"
do_ON:
    POP EBX
    mov dword ptr 0 [ebx], -1
    NEXTC
 ;
_OFF:     ; ( addr -- )  ;    set the contents of addr of OFF ; (0)
DD _ON
OFF:
DD do_OFF
DB 0, 3, "OFF"
do_OFF:
    POP EBX
    mov dword ptr 0 [ebx],  0
    NEXTC
;
;    -------------------- Other Operators ------------------------------------
;
_DOCOLN:                    ; COMPILER CODE VERIFIED 240102
DD _OFF
COLN: 
DD do_COLN
DB 0, 4, 'COLN'
do_COLN:  
    MOV EBX, NFA
    MOV EAX, ECX
    ADD EAX, EBX
    ADD EAX, 1
    push EAX
    JMP do_DOCOL
;
_DOCOL:                     ; ( ADDR -- )  runtime for colon definitions  VERIFIED 240102
DD _DOCOLN
DOCOL:
DD do_DOCOL
DB 0, 5, "DOCOL"
do_DOCOL:  
    POP EAX
    SUB EBP, 4
    MOV [EBP], EDI
    mov edi, eax
    mov eax, [edi]
    add edi, 4
    JMP DWORD PTR [EAX]
;
_DODOES:  ;( -- a1 )   ;  runtime for DOES>
DD _DOCOL 
DODOES:
DD do_DODOES
DB 0, 6, "DODOES"
do_DODOES: 
    mov     [ebp-4], esi   ;  rpush esi
    mov     esi, ecx        ;  new esi
    lea     ebx, 4 [eax]
    mov     eax, [esi-4]
    sub     ebp,  4
    JMP     EAX
;
_DOVAR1:   ;( -- a1 )   ;  runtime for CREATE and VARIABLE   VERIFIED 231201
DD _DODOES  
DOVAR1:
DD do_DOVAR1
DB 0, 5, "DOVAR1"
do_DOVAR1: 
    MOV EAX, [NFA+9]
    MOV ECX, 0
    MOV CL, BYTE PTR [EAX]
    ADD EAX, ECX
    INC EAX
    PUSH EAX
    NEXTC
;
_DOVAR:   ;( -- a1 )   ;  runtime for CREATE and VARIABLE   VERIFIED 231201
DD _DOVAR1  
DOVAR:
DD do_DOVAR
DB 0, 5, "DOVAR"
do_DOVAR: 
    ADD EAX, 5      ;
    MOV ECX, 0
    MOV CL, BYTE PTR [EAX]
    ADD EAX, ECX
    INC EAX
    PUSH EAX
    NEXTC
; 
_DOUSER:  ;( -- a1 )   ;  runtime for USER variables
DD _DOVAR 
DOUSER:
DD do_DOUSER
DB 0, 6, "DOUSER"
do_DOUSER: 
    mov     ebx, 4 [eax] ;  get offset
    add     ebx, edx     ;  add absolute user base
    PUSH EBX
    NEXTC
; 
_DOCON:   ;( -- n1 )   ;  runtime for constants   VERIFIED 231201
DD _DOUSER  
DOCON:
DD do_DOCON
DB 0, 5, "DOCON"
do_DOCON: 
   MOV EAX, 0
    MOV EBX, [NFA+9]
    MOV AL, BYTE PTR [EBX]
    ADD EAX, EBX
    INC EAX          
    PUSH [EAX]
    NEXTC
; 
_DODEFER:  ;( -- )     ;  runtime for DEFER
DD _DOCON 
DODEFER:
DD do_DODEFER
DB 0, 7, "DODEFER"
do_DODEFER: 
    mov     eax, 4 [eax]
    JMP EAX

_DOVALUE:  ;( -- n1 )  ;  runtime for VALUE fetch    VERIFIED 231201
DD _DODEFER  
DOVALUE:
DD do_DOVALUE
DB 0, 7, "DOVALUE"
do_DOVALUE: 
    MOV EAX, 0
    MOV EBX, [NFA+9]
    MOV AL, BYTE PTR [EBX]
    ADD EAX, EBX
    INC EAX          
    PUSH [EAX]
    NEXTC
 ; 
_DOVALUESTORE:  ;( n1 -- )   ;  runtime for VALUE store    VERIFIED 231201
DD _DOVALUE
VALUESTORE:
DD do_VALUESTORE
DB 0, 8, "DOVALUE!"
do_VALUESTORE: 
    POP EAX         ; DISCARD CFA POPINTER
    MOV EAX, 0
    MOV EBX, [NFA+9]
    MOV AL, BYTE PTR [EBX]
    ADD EAX, EBX
    inc eax         ; ADD EAX, 9
    POP EBX         ; RETRIEVE VALUE N1
    mov [eax], ebx  ; SAVE VALUE
    NEXTC
 ; 
_DOVALPLUSTORE:  ;( n1 -- )   ;  runtime for VALUE increment   VERIFIED 231201
DD _DOVALUESTORE  
DOVALPLUSTORE:
DD do_VALPLUSTORE
DB 0, 9, "DOVALUE+!"
do_VALPLUSTORE: 
    POP EAX         ; DISCARD CFA POPINTER
    MOV EAX, 0
    MOV EBX, [NFA+9]
    MOV AL, BYTE PTR [EBX]
    ADD EAX, EBX
    inc eax         ;ADD EAX, 9
    POP EBX         ; RETRIEVE VALUE N1
    add     [eax], ebx
    NEXTC
 ; 
_DO2VALUE:  ;( d1 -- )   ;  runtime for 2VALUE fetch
DD _DOVALPLUSTORE 
DO2VALUE:
DD do_DO2VALUE
DB 0, 8, "DO2VALUE"
do_DO2VALUE: 
    POP EBX 
    push    ebx
    mov     ecx, 4 [eax]
    push    4 [ecx]
    mov     ebx, 0 [ecx]
    NEXTC
 ; 
_DOOFF:      ;( n -- )    ;  run-time for OFFSET and FIELD+
DD _DO2VALUE  
DOOFF:
DD do_DOOFF
DB 0, 5, "DOOFF"
do_DOOFF: 
    POP EBX 
    add ebx, 4 [eax]
    NEXTC
 ; 
SOURCE_:        ; ( -- addr len )     (SOURCE)                 2@ ;
DD _DOOFF
DD do_SOURCE_
DB 0, 6, 'SOURCE'
do_SOURCE_:
    mov ebx, _SOURCE     ; -----------------Needs work 
    push [ebx]
    add ebx, 4
    push [ebx]
    NEXTC
;
_HEADER_:   ;( addr len -- )   standard voc header word
DD SOURCE_
DD do__HEADER_
DB 0, 8, '(HEADER)'
do__HEADER_:
   mov     ecx, CURRENT       ; get current vocab
;  mov     eax, VHEAD VOC#0 - [ecx] ; fetch header word to execute
   JMP     eax
;
;   -------------------- Block Memory Operators -------------------------------
;
 _CMOVE:          ; (  from to count -- )     move "count" bytes from address "from" to   ; VERIFIED
 DD _HEADER_      ;  address "to" - start with the first byte of "from"
 CMOVE@:
 DD do_CMOVE
 DB 0, 5, 'CMOVE'
 do_CMOVE:
                MOV     _EDI , EDI
                POP     EBX
                mov     ecx, ebx
                mov     eax, esi
                pop     edi
                pop     esi
                rep     movsb
                mov     esi, eax
;               xor     edi, edi
                MOV     EDI, _EDI
                NEXTC
;
_FILL:      ;   ( addr len char -- )  fill addr with char for len bytes  
DD  _CMOVE
FILL:
DD do_FILL
DB 0, 4, 'FILL'
do_FILL:
                POP     EBX             ;  CHAR
                mov     bh, 32          ;  bh & bl = char = 32
                shl     ebx,  16
                mov     eax, ebx
                shr     eax,  16
                or      eax, ebx
FILLJ:          mov     ebx, edi        ;  ebx = base POINTER
                pop     ecx             ;  ecx = len
                pop     edi             ;  edi = addr
                push    ecx             ;  optimize
                shr     ecx,  2
                rep     stosD
                pop     ecx
                and     ecx,  3
                rep     stosB
                mov     edi, ebx        ;  restore
                NEXTC                   ;  FILL
;
_ERASE:     ;( addr u -- )  ; VERIFIED
;  *G If u is greater than zero, clear all bits in each of u consecutive address
;  ** units of memory beginning at addr .
DD _FILL
ERASE:
DD do_ERASE
DB 0, 5, 'ERASE'
do_ERASE:
                xor     eax, eax
                jmp     FILLJ
;
BLANK:     ;( c-addr u -- )           ANSI         String
;  *G If u is greater than zero, store the character value for space in u consecutive
;  ** character positions beginning at c-addr.
DD _ERASE
DD do_BLANK
DB 0, 5, 'BLANK'
do_BLANK:
                mov     eax, 20202020h ;  all blanks
                jmp     FILLJ
;
; -------------------- Parse Input Stream --------------------
;
TOBODY:       ;( cfa -- pfa ) \ convert code field address to parameter field address
DD BLANK
DD do_TOBODY
DB 0, 5, ">BODY"
do_TOBODY:
    POP EBX
    add ebx,  4
    PUSH EBX
    NEXTC
 ;
BODYOFF:      ;( pfa -- cfa ) \ convert parameter field address to code field address
DD TOBODY
DD do_BODYOFF
DB 0, 5, "BODY>"
do_BODYOFF:
    POP EBX
    sub ebx,  4
    PUSH EBX
    NEXTC
;
_WORD:       ; ( SADDR char -- Caddr ) CADDR = COUNTED STRING       ; VERIFIED
DD BODYOFF
WORD@:
DD do_WORD
DB 0, 4, "WORD"
do_WORD: ; ( SADDR BL -- SADDR, LEN )
; parse the input stream for a string delimited by char. Skip all leading char. Give a
; counted string (the string is ended with a blank, not included in count).
; If char is a blank treat all control characters as delimiter.
; Use only inside colon definition.
    POP     EBX                 ; delimiter CHAR
    CMP     [S_LEN+11], 1
    JA      @@W1
    NEXTC
@@W1:
    POP     EAX                 ; ADDRESS OF STRING
    PUSH    EDI
    push    esi     	
    MOV     EDI, EAX            ; edi = input pointer
    MOV     EAX, 0
    mov     al, BL              ; al = delimiter = SPACE 
    add     edi, [_IN+9]    	; add _IN
    mov     ecx, [S_LEN+11]     ; ecx = input length
    sub     ecx, [_IN+9]        ; subtract _IN
    ja      short @@9A
    xor     ecx, ecx   			; at end of input
    MOV     [_IN+9], 0
    jmp     @@8A
@@9A:
    cmp     al,   BL
    jne     short @@5A
                                ; Delimiter is a blank, treat all chars <= 32 as the delimiter
@@1B:
    cmp     [edi], al           ; leading delimiter?
    ja      short @@2B
    ADD     EDI, 1
    JMP     @@1B
    sub     ecx,  1
    jnz     short @@1B
    mov     esi, edi    		; esi = start of word
    mov     ecx, edi    		; ecx = end of word
    jmp     short @@7A
@@2B:
    mov     esi, edi    		; esi = start of word
@@3B:
    cmp     [edi], al     		; end of word?
    je      short @@4B
    add     edi,  1
    sub     ecx,  1
    jnz     short @@3B
    mov     ecx, edi    		; ecx = end of word
    jmp     short @@7A
@@4B:
    mov     ecx, edi    		; ecx = end of word DELIMITER FOUND
    add     edi,  1  			; skip over ending delimiter
    jmp     short @@7A
						        ; delimiter is not a blank
@@5A:
    repz    scasb
    jne     short @@6A
    mov     esi, edi    		; end of input
    mov     ecx, edi
    jmp     short @@7A
@@6A:
    sub     edi,  1    			; backup
    add     ecx,  1
    mov     esi, edi    		; esi = start of word
    repnz   scasb
    mov     ecx, edi    		; ecx = end of word
    jne     short @@7A
    sub     ecx,  1   	 		; account for ending delimiter
                                ; Update _IN pointer and get word length
@@7A:
    sub     edi, S_ADR          ; offset from start
    mov     [_IN+9] , edi       ; update _IN
    sub     ecx, esi    		; length of word
    cmp     ecx,  MAXCOUNTED    ; max at MAXCOUNTED
    jbe     short @@8A
    mov     ecx,  MAXCOUNTED    ; clip to MAXCOUNTED
						        ; Move string to pocket
@@8A:
    mov     edi, POCKET         ; edi = pocket
    PUSH    EDI
    mov     [edi], cl           ; store count byte
    add     edi,  1
    rep     movsb       	    ; move rest of word
    mov     eax,  32
    stosb               	    ; append a BLANK to pocket
    POP     EAX
    pop     esi
    POP     EDI
    INC     EAX
    PUSH    EAX
    NEXTC                       ; END OF WORD: 
;
PARSENAME:  ; ( "<spaces>name" -- c-addr u ) ; parse the input stream
DD _WORD
DD do_PARSENAME
DB 0, 9, "PARSENAME"
do_PARSENAME:
    POP EBX
    ; for a string delimited by spaces. Skip all leading spaces.
    ; Give the string as address and count.
    push    ebx
    mov     eax, S_ADR           ; edi = input pointer
    add     eax, [_IN+9]   		     ; add _IN
    push    eax         		 ; address of output eax = input char
    mov     ecx, [S_LEN+11]          ; ecx = input length
    sub     ecx, [_IN+9]    		 ; subtract _IN
    ja      short @@1C
    xor     ecx, ecx   			 ; at end of input
    jmp     short @@8C

@@1C:
    push    eax
    mov     eax, [eax]
    cmp     eax,  32        ; leading delimiter?
    pop     eax
    ja      @@2C
    add     eax,  1    		; go to next character
    sub     ecx,  1
    jnz     @@1C

    mov     ebx, eax    	; ebx = start of word
    mov     ecx, ebx   		; ecx = end of word
    jmp     short @@7C

@@2C:
    mov     ebx, eax    	; ebx = start of word
@@3C:
    push    eax
    mov     eax, [eax]
    cmp     eax,  32        ; end of word?
    pop     eax
    jbe     @@4C
    add     eax,  1
    sub     ecx,  1
    jnz     short @@3C
    mov     ecx, eax        ; ecx = end of word
    jmp     short @@7C

@@4C:
    mov     ecx, eax    	; ecx = end of word
    add     eax,  1    		; skip over ending delimiter
            ; update _IN pointer and get word length
@@7C:
    sub     eax, S_ADR       ; offset from start
    mov     [_IN+9] , eax  		 ; update _IN
    sub     ecx, ebx    	 ; length of word
    mov     0 [esp], ebx     ; save on stack
@@8C:
    mov     ebx, ecx    	 ; and length
    NEXTC
;
_PARSEINIT:          ; ( BUFFLEN -- )
DD PARSENAME
PARSEINIT:
DD do_PARSEINIT
DB 0, 9, 'PARSEINIT'
do_PARSEINIT:
POP S1_LEN
MOV [_1IN+10], 0
NEXTC
;
_PARSE:      ; ( BUFFERRADDR, char "ccc<char>" -- c-addr u ) ; parse the input stream
DD _PARSEINIT
PARSE:
DD do_PARSE
DB 0, 5, "PARSE"
do_PARSE:
    POP     EBX                     ; CHARACTER TO SEARCH FOR
    POP     S1_ADR                  ; BUFFER TO SEARCH
    mov     eax, S1_ADR             ; S_ADR = input pointer
    add     eax, [_1IN+10]  	    ; add _IN
    push    eax         			; address of INput
    mov     dl, BL      			; char to scan for eax = input char
    mov     ecx, S1_LEN             ; ecx = input length
    sub     ecx, [_1IN+10]  		; subtract _IN
    ja      short @@1D
    xor     ecx, ecx                ; at end of input
    jmp     short @@8D

@@1D:
    mov     ebx, eax    			; ebx = start of word
@@3D:
    cmp     [eax], dl        		; end of word?
    je      short @@4D
    add     eax,  1
    sub     ecx,  1
    jnz     short @@3D
    mov     ecx, eax    			; ecx = end of word
    jmp     short @@7D

@@4D:
    mov     ecx, eax    			; ecx = end of word
    add     eax,  1    			    ; skip over ending delimiter
                                    ; update _IN pointer and get word length
@@7D:
    sub     eax, S1_ADR             ; offset from start
    mov     [_1IN+10] , eax      	; update _IN
    sub     ecx, ebx    			; length of word
    mov     4 [esp], ebx            ; save on stack
@@8D:
    mov     ebx, ecx    			; and length
    PUSH EBX
    NEXTC                           ; END OF PARSE
 ;
_PARSESTR:  ; ( Addr Len -- Addr Len)       VERIFIED 231205
DD _PARSE
PARSESTR:
DD do_PARSESTR
DB 0, 9, "PARSE-STR"
do_PARSESTR:
POP EBX             ;   EBX register = LENGTH OF STRING
POP EAX             ;   Load String Address
PUSH EDX            ;   Save register set
PUSH EAX            ;   Save String address
ADD EAX , EBX       ;   Add length to addr to find End of string
MOV EDX , EAX       ;   Save End of string
POP EAX             ;   restore string addr
MOV ECX,  0000      ;   Load Counter
@@1E:
push eax
mov eax, [eax]
CMP eax,  32        ;   advance over leading spaces
pop eax
JNE SHORT @@2E
INC EAX
CMP EAX, EDX
JE SHORT @@3E       ;   end of string encountered
JMP SHORT @@1E
@@2E:
PUSH EAX            ;   save starting address
@@4E:
INC ECX
push eax
mov AL, BYTE PTR [eax]
CMP AL,  32        ;   locate a space
pop eax
JE SHORT @@3E       ; trailing space found
CMP EAX, EDX
JE SHORT @@3E       ;   past end of string
INC EAX
JMP SHORT @@4E
@@3E:
DEC ECX
MOV EBX, ECX        ;   move counter to ebx
POP EAX
POP EDX
PUSH EAX
push ebx
NEXTC               ; END OF PARSESTR
;
_NOOP:      ; VERIFIED
DD _PARSESTR
NOOP:
DD do_NOOP
DB 0, 4, 'NOOP'
do_NOOP:
NEXTC
;
_HERE:      ; VERIFIED
DD _NOOP
HERE:
DD do_HERE
DB 0, 4, 'HERE'
do_HERE:
mov ebx, [DPR+9]
push ebx
NEXTC
;
_UPPERCASE: ; ( SADDR LEN -- SADDR)     ; VERIFIED
DD _HERE
UPPERCASE:
DD do_UPPERCASE
DB 0, 9, 'UPPERCASE'
do_UPPERCASE:
POP ECX  ; STRING LENGTH
MOV  EBX ,[ESP]
AND ECX, 0FFH
MOV EAX, 0
MOV [TV$+9], EBX 
push TV$+9
call szUpper
NEXTC       ; UPPERCASE
;
_LOWERCASE: ; ( SADDR LEN -- SADDR)     ; VERIFIED
DD _UPPERCASE
LOWERCASE:
DD do_LOWERCASE
DB 0, 9, 'LOWERCASE'
do_LOWERCASE:
POP ECX  ; STRING LENGTH
MOV  EBX ,[ESP]
AND ECX, 0FFH
MOV EAX, 0
MOV [TV$+9], EBX 
push TV$+9
call szLower
NEXTC       ; LOWERCASE
;
_FIND: ; ( SADDR LEN -- cfa   ) Search dictionary for a word         VERIFIED
DD _LOWERCASE
FIND:
DD do_FIND
DB 0, 4, 'FIND'
do_FIND:
MOV FCOUNTER, 0
MOV [CFA+9], 0
MOV [LFA+9], 0
MOV [NFA+9], 0
MOV [FFLAG+11], 0
MOV EAX, 0
POP ECX     ; LENGTH
AND CX, 0FH
CMP CX, 0
JA @@01
MOV [FFLAG+11], 0
POP EAX     ; REMOVE ADDRESS FROM STACK
PUSH [CFA+9]    
NEXTC       ; ABORT
@@01:
POP EAX     ; POCKET ADDRESS
PUSH EDI    ; INTERPRETER POINTER
PUSH [LATEST+12] 
@@6F:
INC FCOUNTER
POP EBX
CMP CL,  [EBX+9]
JNZ @@1F
; WORD LENGHTS ARE EQUAL CMP WORDS
MOV [LFA+9], EBX
PUSH EBX
ADD EBX, 9
MOV [NFA+9], EBX    
POP EBX
PUSH EBX
MOV CL, BYTE PTR [POC+9]
AND CX, 0FH
ADD EBX, 4
PUSH [EBX]
POP [CFA+9]
ADD EBX, 6
MOV ESI, EAX
MOV EDI, EBX
REPE CMPSB
POP EBX
MOV CL, BYTE PTR [POC+9]
JNZ @@1F 
POP EDI
MOV [FFLAG+11], -1
JMP @@5F
@@1F:
MOV EBX, [EBX] ; LINK ADDRESS
PUSH EBX
PUSH [EBX] ; LINK ADDRESS
POP EBX 
CMP EBX, 0
JZ @@6F1
MOV EBX, [ESP] ; RECOVER ADDRESS
MOV [NFA+9], 0
MOV [LFA+9], 0
JMP @@6F
@@6F1:
POP ECX
POP EDI
PUSH POCKET
POP [CFA+9]
INC [CFA+9]
MOV [FFLAG+11], 0
@@5F:
PUSH [CFA+9]
NEXTC ; FIND: LEAVING CFA
;
_GTNUMBER:    ;( ud addr len -- ud addr len )    VERIFIED 231211
DD _FIND
GTNUMBER:
DD do_GTNUMBER
DB 0, 8, 'GTNUMBER'
do_GTNUMBER:
                POP     EBX
                test    ebx, ebx                ; check if anything to convert
                je      short @@4H              ; zero, so skip
                mov     [ebp-4], edi
                mov     [ebp-8], edx            ; save UP
                mov     esi, [esp]              ; esi = address
                mov     edi, [BASE+10]          ; get the number base
@@1H:           movzx   eax, byte ptr [esi]     ; get next digit
                cmp     al,  '0'
                jb      short @@3H              ; if below '0' branch to done
                cmp     al,  '9'
                jbe     short @@2H              ; go convert it
                and     al,  0DFH               ; convert to uppercase
                cmp     al,  'A'                ; if below 'A'
                jb      short @@3H              ; then branch to done
                sub     al,  7
@@2H:           sub     al,  '0'
                cmp     eax, edi
                jae     short @@3H              ; out of base range
                xchg    eax, 4 [esp]            ; high word * base
                mul     edi
                xchg    eax, 8 [esp]            ; low word * base
                mul     edi
                add     eax, 4 [esp]            ; add
                adc     edx, 8 [esp]
                mov     8 [esp], eax            ; store result
                mov     4 [esp], edx
                add     esi,  1
                sub     ebx,  1
                jnz     short @@1H
@@3H:           mov     [esp], esi              ; address of unconvertable digit
                mov     edi, [ebp-4]
                mov     edx, [ebp-8]            ; save UP
@@4H:            
NEXTC
;
_NUMINIT:      ; ( -- )                  initialise number values
DD _GTNUMBER
NUMINIT:
DD do_NUMINIT
DB 0, 7, 'NUMINIT'
do_NUMINIT:
MOV DOUBLEQ, -1                ; false to double?
MOV DPLOCATION, -1             ; -1 to dp-location
MOV VENUMQ, 0                  ; false to -ve-num?
NEXTC
;
_NEWNUMB: ; ( ADDR F -- N F )  ONLY WORKS FOR DECIMAL INTEGERS (+/-)       ; VERIFIED 231219
DD _NUMINIT
NEWNUMB:
DD do_NEWNUMB
DB 0, 7,'NEWNUMB'
do_NEWNUMB:
POP EBX
CMP EBX, 0
JNE @NEWNUMB
call atol   ; CONVERT ASCII STRING TO NUMBER (EAX)
PUSH EAX
PUSH -1
NEXTC
@NEWNUMB:
PUSH -13    ; UNDEFINED
PUSH 0
NEXTC
;
_NEWHEADER:   ; ( ADDR LEN  -  )
DD _NEWNUMB
NEWHEADER:
DD do_NEWHEADER
DB 0, 7, 'NEWHEADER'
do_NEWHEADER:
POP ECX     ; LENGTH
POP EBX     ; ADDR TIB
PUSH EDI
PUSH ECX
AND ECX, 00FFH
INC ECX
MOV EDX, [LATEST+12]     ; PREVIOUS LFA
MOV EAX, [DPR+9]
MOV [LFA+9], EAX        ; SAVE LFA
MOV [EAX],  EDX     ; LOAD LFA
MOV [LATEST+12], EAX     ; UPDATE LATEST WITH NEW LFA
ADD EAX, 8          ; BFA
MOV BYTE PTR [EAX], 0
INC EAX             ; MOVE TO NFA
MOV [NFA+9], EAX        ; SAVE NFA 
MOV EDI, EAX
SUB EBX, 1
MOV ESI, EBX
REP MOVSB           ; LOAD NFA WITH LENGTH BYTE AND STRING
MOV EAX, [DPR+9]          
POP ECX
INC ECX
ADD ECX, 9         
ADD EAX, ECX        ; CFA
MOV [CFA+9], EAX
MOV EAX, [LFA+9]
ADD EAX, 4
PUSH [CFA+9]
POP [EAX]           ; SAVE CFA
PUSH [CFA+9]
POP EAX
PUSH EAX
POP [DPR+9]
POP EDI
NEXTC       ; EXIT NEWHEADER
;
_KBREAD:   ; READ INPUT FROM KEYBOARD        ; VERIFIED
DD _NEWHEADER
KBREAD:
DD do_KBREAD
DB 0, 6, 'KBREAD'
do_KBREAD:
lea eax, MsgQ
push eax
call StdOut
push 256        ; LENGTHOF TIB
LEA eax, TIB
ADD EAX, 9
push eax
call StdIn
LEA EBX, TIB    ; ADD A SPACE TO END OF INPUT LINE
ADD EBX, 9
ADD EBX, EAX
PUSH 20H
POP [EBX]
ADD EAX, 1
MOV [S_LEN+11], EAX
PUSH EAX
NEXTC
;
_CLS: ; CLEAR SCREEN     ; VERIFIED
DD _KBREAD
CLS:
DD do_CLS
DB 0, 3, 'CLS'
do_CLS:
    invoke ClearScreen
NEXTC
;
_CR: ; EMIT CRLF ; VERIFIED
DD _CLS
CR:
DD do_CR
DB 0, 2, 'CR'
do_CR:
lea eax, CRLF+10
push eax
call StdOut
NEXTC
;
_DABS:           ; ( d1 -- d2 )    \ return the absolute value of d1 as d2
DD _CR
DD do_DABS
DB 0, 4, 'DABS'
do_DABS:
POP     EBX
test    ebx, ebx
jns     short @@1K
pop     eax
neg     ebx
neg     eax
sbb     ebx, 0
push    eax
@@1K:   NEXTC
;
_HOLD:       ; ( char -- ) \ insert char in number output picture - see <#
DD _DABS
DABS:
DD do_HOLD
DB 0, 4, 'HOLD'
do_HOLD:
mov     eax, 4 [EDX]   ; UP EQU EDX  ( [EDX] + 4 )  CELLS = + 4  MOV EAX, [EDX] + 4
sub     eax, 1
mov     BYTE PTR [eax], 32
mov     4 [EDX], eax   ; DUP USER HLD CELL+ ( numeric output pointer )
pop     ebx
PUSH    EBX
NEXTC
;
_SPACES: ; ( N -- )
DD _HOLD
SPACES:
DD do_SPACES
DB 0, 6, 'SPACES'
do_SPACES:
POP ECX ; NUMBER OF SPACES
@@1L:
 lea eax, SPACE$
 call StdOut
 DEC BL
 CMP BL, 0
 JNZ @@1L
 NEXTC
;
POUND:              ; CODE #  ( d1 -- d2 ) \ convert a digit in pictured number output - see <#
DD _SPACES
DD do_POUND
DB 0, 1, '#'
do_POUND:
POP EBX
MOV EAX, EBX
MOV ECX, BASE
DIV CL
cmp AH,  9
jbe short @@1M
add AH,  7
@@1M:           
add AH,  48           ; '0' 48D, 30H
PUSH EAX
MOV EAX, [HLD+9]
SUB EAX, 1
MOV [HLD+9], EAX
POP EDX
MOV BYTE PTR [EAX], DH
MOV DH, 0
PUSH EDX
NEXTC
;
itohex:                  ; (PAD N -- PAD)       VERIFIED 231206
DD POUND
DD do_I2HEX
DB 0, 5, 'I2HEX'
do_I2HEX:
    push   edi           ; save a call-preserved register for scratch space
    mov    edi, [esp+8]  ; out pointer

    mov    eax, [esp+4]  ; number

    mov    ecx, 8        ; 8 hex digits, fixed width zero-padded
@@loopA:
    rol    eax, 4        ; rotate the high 4 bits to the bottom
    mov    edx, eax
    and    edx, 0fH      ; and isolate 4-bit integer in EDX
    CMP    DL, 0
    JNZ    @@loopB
    DEC    ECX           ; SKIP LEADING 0'S
    MOV    BYTE PTR [EDI], 32
    INC    EDI
    JMP    @@loopA
@@loop:                  ; do {
    rol    eax, 4        ; rotate the high 4 bits to the bottom
@@loopB:
    mov    edx, eax
    and    edx, 0fH      ; and isolate 4-bit integer in EDX

    MOV    DL, byte PTR [HEX_TABLE + edx]
    ; movzx  edx, DL     
    mov    [edi], DL     ; copy a character from the lookup table
    inc    edi           ; loop forward in the output buffer

    dec    ecx
    jnz    @@loop        ; }while(--ecx)
    MOV    BYTE PTR [EDI], 72
    pop    edi
    POP    EAX
    NEXTC
;
__UNTIL:     ;    ( f1 -- )       \ "runtime" if f1=FALSE branch to after BEGIN
DD itohex
DD do__UNTIL
DB 0, 6, '_UNTIL'
do__UNTIL:
test    ebx, ebx
pop     ebx
je      short @@11A
mov     eSI, 4 [edi]
add     edi, 8
PUSH    [ESI]
POP     ESI
jmp     ESI
@@11A:            
   mov edi, [edi]
   PUSH [EDI]
   POP ESI
   SUB ESI, 4
   ;mov eax, -4 [edi]
   PUSH [ESI]
   POP ESI
   jmp ESI
;
_IF@:        ; INTERACTIVE IF - THEN PAIR    ; VERIFIED
DD __UNTIL
IF@: 
DD do_IF@
DB 0, 3, '[IF]'
do_IF@:
POP EBX
CMP EBX,0
JZ @IF
NEXTC       ; CONTINUE PROCESS NEXT WORDS
@IF:        ; SKIP WORDS TILL do_THEN@ FOUND
cmp [edi], ELSE@
JZ @IF1a
CMP [EDI], THEN@
JZ @IF1
ADD EDI, 4
JMP @IF
@IF1a:
ADD EDI, 4
@IF1:
; CONTINUE PROCESSING WORDS
NEXTC
;
_ELSE@:      ; INTERACTIVE
DD _IF@
ELSE@: 
DD do_ELSE@
DB 0, 5, '[ELSE]'
do_ELSE@:
CMP [EDI], THEN@
JZ else1
ADD EDI, 4
JMP do_ELSE@
else1:
NEXTC
;
_THEN@:      ; INTERACTIVE  ; VERIFIED
DD _ELSE@
THEN@: 
DD do_THEN@
DB 0, 5, '[THEN]'
do_THEN@:
; NOOP
NEXTC
;
HASHV:     ; ( a1 n1 #threads -- n2 )        verified 231210
DD _THEN@
DD do_HASHV
DB 0, 5, 'HASHV'
do_HASHV:
 POP     EBX
 pop     eax                     ; pop count into EAX
 mov     [EBP-4], edx            ; save UP
 mov     [EBP-8], ebx            ; save # of threads
 pop     ebx                     ; get string address into EBX
 mov     ecx, eax                ; copy count into ECX
 add     ebx, ecx
 neg     ecx
@@1HV:
 rol     eax,  7                 ; rotate result some
 xor     al, [ebx] [ecx]
 add     ecx,  1
 JB      @@1HV                   ; +ve, keep going
 xor     edx, edx                ; clear high part of dividend
 div     DWORD PTR [EBP-8]       ; perform modulus by #threads
 mov     ebx, edx                ; move result into EBX
 mov     edx, [EBP-4]            ; restore UP
 lea     ebx, [ebx*4]            ; multiply by cell size
 push    ebx
 NEXTC
;
_EXECUTE:   ;( cfa -- )  execute a Forth word, given its cfa  ; VERIFIED 231229
DD HASHV
EXECUTE:
DD do_EXECUTE
DB 0, 7, 'EXECUTE'
do_EXECUTE:
   POP EAX
   JMP EAX  ; DWORD PTR [EAX]
;
_EMSG:                  ; VERIFIED 231219
DD _EXECUTE
EMSG:
DD do_EMSG
DB 0, 5, 'EMSG?'
do_EMSG:
MOV EAX, [ESP]
CMP EAX, -1
JE @EMSG
POP EAX
lea eax, Msg10
push eax
call StdOut
lea eax, POC+9
add eax, 1
push eax
call StdOut
lea eax, Msg11
push eax
call StdOut
PUSH ABORT@
@EMSG:
POP EAX
NEXTC
; JMP DWORD PTR [EAX]
;
COMMENT ~
NCODE (C")      ( -- addr )                    \ for c" type strings
                push    ebx
                movzx   ecx, byte ptr [esi]    \ length of string
                mov     ebx, esi               \ start of the string in TOS
                lea     esi, 9 [ecx] [ebx]     \ optimised next, account for len & null at end
                and     esi, # -4              \ align
                mov     eax, -4 [esi]          \ next word
                exec    c;                     \ go do it

NCODE (Z")      ( -- addr )                    \ for z" type strings
                push    ebx
                lea     ebx, 1 [esi]           \ start of string in TOS
                movzx   ecx, byte ptr [esi]    \ length of string
                lea     esi, 8 [ecx] [ebx]     \ optimised next, account for len & null at end
                and     esi, # -4              \ align
                mov     eax, -4 [esi]          \ next word
                exec    c;                     \ go do it
~
;
_PDOTP:                        ; ( -- addr len )                
DD _EMSG
DD do_PDOTP
DB 0, 4, '(.")'
do_PDOTP:
lea     ecx, [edi]             ; start of string
movzx   ebx, byte ptr [edi]    ; length of string in TOS
push    ecx                    ; save addr of string
lea     esi, 4 [ecx] [ebx]     ; optimised next, account for len & null at end
and     esi, -4                ; align
LEA EAX, do_TYPE               ; mov     eax, # ' TYPE          \ next word
JMP     EAX                    ; go do it
;
_Endless:    ; ENDLESS LOOP      VERIFIED
DD _PDOTP
DD do_Endless
DB 0, 7, 'ENDLESS'
do_Endless:
JMP do_Endless
;
_QMISSING: ; ( f --  )
DD _Endless 
?MISSING:
DD do_?MISSING
DB 0, 8, '?MISSING'
do_?MISSING:
; POP EAX
NEXTC
;
_BYE:       ; VERIFIED
DD _QMISSING
BYE:
DD do_BYE
DB 0, 3, 'BYE'
do_BYE:
MOV BYEFLAG, 0H 
NEXTC
;
_QBYE:      ; VERIFIED
DD _BYE
QBYE:
DD do_QBYE
DB 0, 4, '?BYE'
do_QBYE:
PUSH BYEFLAG 
NEXTC
;
_QUIT:      ; VERIFIED
DD _QBYE 
QUIT:
DD do_QUIT
DB 0, 4, 'QUIT'
do_QUIT:
lea eax, Msg6
push eax
call StdOut
JMP do_QSTACK
NEXTC
;
; invoke atodw, ADDR MyDecimalString                ; CONVERT ASCII STRING TO NUMBER (EAX)
; invoke ustr2dw, ustr2dw proc pszString:DWORD      ; Convert string to unsigned DWORD (EAX)
;
_DWTOA:  ; ( N, ADDR -- )  CONVERT DWORD NUMBER TO ASCII STRING     VERIFIED
DD _QUIT
DWTOA:
DD do_DWTOA
DB 0, 5, 'DWTOA'
do_DWTOA:
call dwtoa
NEXTC
; 
_udw2str:  ; ( N, ADDR -- )   Convert unsigned DWORD to string
DD _DWTOA
udw2str:
DD do_udw2str
DB 0, 7, 'UDW2STR'
do_udw2str:
call udw2str
NEXTC
;
_stdout: ; ( ADDR LEN -- )  NOTE: SAME AS 'TYPE'    VERIFIED
DD _udw2str
STDOUT:
DD do_STDOUT
DB 0, 6, 'STDOUT'
do_STDOUT: 
ADD ESP, 4      ; IGNORE LENGTH 
call StdOut
NEXTC
;
_TYPE: ; ( ADDR LEN -- )        VERIFIED
DD _stdout
TYPE@:
DD do_TYPE
DB 0, 4, 'TYPE'
do_TYPE:
POP ECX         ; GET LENGTH BYTE
MOV EAX, [ESP]  ; COPY TOP OF STACK TO EAX
ADD EAX, ECX
MOV BYTE PTR [EAX], 0   ; MUST HAVE A 0H AT END OF OUTPUT
call StdOut
NEXTC
;
_ms:            ; ( -- N ) GET SYSTEM TIME IN MILLISECONDS  VERIFIED
DD _TYPE
MS:
DD do_MS
DB 0, 3, 'MS@'
do_MS:
LEA EBX, _SYSTIME
push EBX
CALL GetLocalTime
LEA EBX, _SYSTIME
MOV ECX, 60
ADD EBX, 8
MOV EAX, 0
ADD AX, WORD PTR [EBX]  ; LOAD HOURS
ADD EBX, 2
MUL ECX         ; CONVERT HOURS TO MINUTES
ADD AX, WORD PTR [EBX]  ; LOAD MINUTES
ADD EBX, 2
MUL ECX         ; CONVERT MINUTES TO SECONDS
ADD AX, WORD PTR [EBX]  ; LOAD SECONDS
ADD EBX, 2
MOV ECX, 1000
MUL ECX         ; CONVERT SECONDS TO MILLISECONDS
ADD AX, WORD PTR [EBX]  ; LOAD MILLISCONDS
PUSH EAX
NEXTC
;
_WDCOUNT:       ;  COUNT THE WORDS IN THE DICTIONARY       VERIFIED
DD _ms
WDCOUNT:
DD do_WDCOUNT
DB 0, 7, 'WDCOUNT'
do_WDCOUNT:
PUSHAD
MOV EBX, [LATEST+12]
MOV ECX, 0
@WDC1:
INC ECX
PUSH [EBX]
MOV EAX, [ESP]
CMP EAX, 0
POP EBX
JZ @WDC2
JMP @WDC1
@WDC2:
MOV [DCW+9], ECX
POPAD
NEXTC                   ; END OF WDCOUNT
;
_QSTACK:                ; QUERY STACK STATUS   VERIFIED 231201
DD _WDCOUNT
QSTACK:
DD do_QSTACK
DB 0, 6, '?STACK'
do_QSTACK:
CMP ESP, [S0+8]
JA @QS1
MOV EAX, [S0+8]
SUB EAX, 1023
CMP ESP, EAX
JB @QS2
MOV [SERROR+16], 0           ; INBOUNDS
NEXTC
@QS1:
MOV [SERROR+16], -4         ; stack underflow
NEXTC
@QS2:
MOV [SERROR+16], -3         ; stack overflow
NEXTC
;
_GCFA:  ; ( -- CFA)  PUT THE CFA ON THE STACK OF THE NEXT EXECUTABLE WORD    VERIFIED 231201
DD _QSTACK
GCFA:
DD do_GCFA
DB 0, 4, 'TICK'
do_GCFA:
MOV EAX, [EDI]
PUSH EAX
ADD EDI, 4
NEXTC
;
 _BTOH:   ; ( BYTE - 'XX')       VERIFIED 231207
 DD _GCFA
 BTOH:
 DD do_BTOH
 DB 0, 4, 'BTOH'
 do_BTOH:
 POP EAX            ;   BYTE TO CONVERT IN AX
 PUSH EDI
 LEA EDI, PAD
 MOV EDX, 0
 MOV [EDI], EDX
 MOV ECX, 2
 ROL EAX, 24
@@loopB2H:
 rol    Eax, 4        ; rotate the high 4 bits to the bottom
 mov    edx, eax
 and    edx, 0fH      ; and isolate 4-bit integer in EDX
 MOV    DL, byte PTR [HEX_TABLE + edx]
 mov    [edi], DL     ; copy a character from the lookup table
 inc    edi           ; loop forward in the output buffer
 dec    ecx
 jnz    @@loopB2H        ; }while(--ecx)
 POP EDI
 NEXTC
;
_BEXT:      ; ( N, -- C,C,C,C)  EXTRACT INDIVIDUAL BYTES FROM WORD  VERIFIED 231207
 DD _BTOH
 DD do_BEXT
 DB 0, 4, 'BEXT'
 do_BEXT:
 POP EAX
 MOV EBX, EAX
 AND EAX, 0FF000000H
 ROR EAX, 24
 PUSH EAX
 MOV EAX, EBX
 AND EAX, 000FF0000H
 ROR EAX, 16
 PUSH EAX
 MOV EAX, EBX
 AND EAX, 00000FF00H
 ROR EAX, 8
 PUSH EAX
 MOV EAX, EBX
 AND EAX, 0000000FFH
 PUSH EAX
 NEXTC
;
_CMAX:      ; ( C -- C ) CHECK IF C < 32 IF TRUE RETURN 46 '.'  VERIFIED 231208 
DD _BEXT
DD do_CMAX
DB 0, 4, 'CMAX'
do_CMAX:
MOV EAX, [ESP]
MOV ECX, 31
SUB EAX, ECX
JA CMAX0
MOV EAX, 46
MOV [ESP], EAX
CMAX0:
NEXTC
;
;   --------------------------- File Control Words -------------------------------------
; R/O = 80000000H   W/O = 40000000H  R/W = C0000000H (-40000000H)
;     -2147483648         1073741824     -1073741824
;
_FILEOPEN:         ; (ADDR, LEN, MODE -- IOR, F )        VERIFIED 231214
DD _CMAX
DD do_FILEOPEN
DB 0, 9, 'OPEN-FILE'
do_FILEOPEN:
POP EAX                 ; MODE
POP EBX                 ; LENGTH - NOT USED
POP [HLD+9] ; ADDR
PUSH 0                  ;  
PUSH 80000000H          ;  128 = NORMAL
PUSH 3                  ;  DISPOSITION 3 = OPEN ONLY IF EXIST
PUSH 0                  ;
PUSH 3                  ;  SHARE MODES 1 READ 2 WRITE 3 BOTH
PUSH EAX                ;  WRITE ONLY MODE R/O, W/O, R/W 
PUSH [HLD+9]            ;
call CreateFileA 
PUSH EAX
invoke GetLastError
push eax
NEXTC
;
_FILECLOSE:         ; ( HDL -- FLG )        VERIFIED 231212
DD _FILEOPEN
DD do_FILECLOSE
DB 0, 10, 'CLOSE-FILE'
do_FILECLOSE:
CALL CloseHandle
; PUSH EAX
invoke GetLastError
push eax
NEXTC
;
_FILECREATE:          ; (ADDR     - HLD FLG)    VERIFIED 231212
DD _FILECLOSE
DD do_FILECREATE
DB 0, 11, 'CREATE-FILE'
do_FILECREATE:       
POP [HLD+9]
PUSH 0                  ;  
PUSH 80000000H          ;  128 = NORMAL
PUSH 2                  ;
PUSH 0                  ;
PUSH 3                  ;  SHARE MODES 1 READ 2 WRITE 3 BOTH
PUSH 40000000H          ;  WRITE ONLY MODE 
PUSH [HLD+9]                ;
; HLD - FILENAME PTR, ACCESS, SHARE, NULL, 2 - CREATE, 128 - NORMAL, HANDLE
call CreateFileA 
PUSH EAX
CALL GetLastError
push eax
NEXTC
;
_GetFileSize:   ; ( FileID -- UD F )        VERIFIED 231213
DD _FILECREATE
DD do_GFS
DB 0, 9, 'FILE-SIZE'
do_GFS:
LEA EAX, TV1
POP EBX
PUSH EAX
PUSH EBX
CALL GetFileSize
PUSH EAX
NEXTC
;
_FPARMSRW:  ;    ( addr len fileid -- 0 0 ptr len addr fileid ) VERIFIED 231214
;                 parms for read/write
DD _GetFileSize
DD do_FPARMSRW
DB 0, 9, 'FPARMSRW'
do_FPARMSRW:
   POP     ESI                     ; RETURN VALUE
   POP     EBX                     ; HANDLE
   POP EAX                         ; LENGTH
   POP ECX                         ; ADDR
   PUSH 0
   PUSH ESP
   PUSH EAX
   PUSH ECX
   PUSH    EBX
   PUSH    ESI
   RET ; NEXTC
;
_READFILE:          ; (  BUFFER, #BYTES, HNDL  -- BREAD, ior )  ior = 0 = success     VERIFIED 231214
DD _FPARMSRW
DD do_READFILE
DB 0, 9, 'READ-FILE'
do_READFILE:
CALL do_FPARMSRW
CALL ReadFile
MOV EAX, [ESP-4]
PUSH EAX
CALL GetLastError
PUSH EAX
NEXTC
;
_WRITEFILE:          ; (  BUFFER, #BYTER, HNDL  -- len ior )  ior = 0 = success
DD _READFILE
DD do_WRITEFILE
DB 0, 10, 'WRITE-FILE'
do_WRITEFILE:
CALL do_FPARMSRW
CALL WriteFile
CALL GetLastError
PUSH EAX
NEXTC
;
_fileposition:             ; ( fileid -- len-ud ior ) 0 0 rot FILE_CURRENT SETFP  VERIFIED 231216
DD _WRITEFILE              ; RETURN FILE POSITION
DD do_FILEPOSITION
DB 0, 13, 'FILE-POSITION'
do_FILEPOSITION:
POP EAX     ; FILE ID
PUSH 1      ; START POINT
PUSH 0      ; NULL
PUSH 0      ; # BYTES TO MOVE
PUSH EAX
Call SetFilePointer  
PUSH EAX
CALL GetLastError 
PUSH EAX
NEXTC
;
_repositionfile:            ; ( len-ud fileid -- ior ) ; ior - 0 = success  FILE_BEGIN SetFP nip nip 
DD _fileposition            ; VERIFIED 231216
DD do_REPOSITIONFILE
DB 0, 15, 'REPOSITION-FILE'
do_REPOSITIONFILE:
POP EAX     ; FILE ID
POP EBX     ; # BYTES TO MOVE
PUSH 0      ; START POINT
PUSH 0      ; NULL
PUSH EBX     
PUSH EAX
Call SetFilePointer  
PUSH EAX
CALL GetLastError 
PUSH EAX
NEXTC
;
;  -------------------- Memory Management functions -------------------------- 
;
_MALLOC:
DD _repositionfile
DD do_MALLOC
DB 0, 6, 'MALLOC'
do_MALLOC:

NEXTC
;
_ALLOCATE:  ; ( N -- ADDR FL )      ; VERIFIED
DD _MALLOC
DD do_ALLOCATE
DB 0, 8, 'ALLOCATE'
do_ALLOCATE:
push 0
call GlobalAlloc           ; GMEM_MOVEABLE=0 or GMEM_ZEROINIT=2
mov _hMemory,eax
.if eax!=0
push _hMemory
call GlobalLock
mov pMem,eax
PUSH pMem
CALL GetLastError
PUSH EAX
.else
lea eax, Msg18
push eax
call StdOut
PUSH 0
.endif
NEXTC
;
_free:          ; ( pMem -- ) release global memory allocated  VERIFIED 231201
DD _ALLOCATE 
DD do_FREE
DB 0, 4, 'FREE'
do_FREE:
mov eax, [esp]
push eax
call GlobalUnlock
call GlobalFree
NEXTC
;
_ALIGN:   ; ( ADDR -  ADDR)     VERIFIED 231222
DD _free
ALIGN@:
DD do_ALIGN
DB 0, 5, 'ALIGN'
do_ALIGN:
POP EAX
ADD EAX, 3
AND EAX, -4
PUSH EAX
NEXTC
;
;   -------------------- End of CODE Definitions ---------------------------
EOCD:
;   -------------------- Begining of Colon Definitions ---------------------
;
_DECIMAL:                   ; 10 BASE !       VERIFIED 240102
DD _ALIGN
DECIMAL: 
DD do_DECIMAL
DB 0, 7, 'DECIMAL'
do_DECIMAL:
PUSH $ + 10
JMP do_DOCOL 
DD LIT, 10, BASE, STORE, SEMI
;
HEX:                        ;    16 BASE !       VERIFIED
DD _DECIMAL
DD do_HEX
DB 0, 3, 'HEX'
do_HEX:
PUSH $ + 10
JMP do_DOCOL 
DD LIT, 16, BASE, STORE, SEMI
;
_BINARY:                    ;    2 BASE !       VERIFIED
DD HEX
DD do_BINARY
DB 0, 6, 'BINARY'
do_BINARY:
PUSH $ + 10
JMP do_DOCOL 
DD LIT, 2, BASE, STORE, SEMI
;
_OCTAL:                     ;    8 BASE !       VERIFIED  240102
DD _BINARY
DD do_OCTAL
DB 0, 5, 'OCTAL'
do_OCTAL:
PUSH $ + 10
JMP do_DOCOL 
DD LIT, 8, BASE, STORE, SEMI
;
_HEADER:                    ; VERIFIED 231223
DD _OCTAL
HEADER:
DD do_HEADER
DB 0, 6, 'HEADER'
do_HEADER:
PUSH $ + 10
JMP do_DOCOL 
DD STATE, @, IF@, do_S_ADR, @, ELSE@, TIB, THEN@
DD LIT, 32, WORD@, COUNT 
DD DUP2, UPPERCASE, DROP
DD NEWHEADER;  _HEADER_  ; Same as (HEADER)
DD SEMI
;
_PRINT: ; ( n -- )   display as signed single       VERIFIED 240105
DD _HEADER
PRINT:
DD do_PRINT
DB 0, 1, '.'
do_PRINT:
PUSH $ + 10
JMP do_DOCOL 
DD PAD, SWAP, DWTOA             ; CONVERT n TO ASCII
DD PAD, PUSH0, STDOUT  ; DISPLAY DATA
DD SEMI
;
_EMIT: ; ( CHAR -- ) Display one character      VERIFIED
dd _PRINT
EMIT:
DD do_EMIT
DB 0, 4, 'EMIT'
do_EMIT:
POP EAX
MOV BYTE PTR PAD+9, BYTE PTR AL
MOV BYTE PTR PAD+10, 0
LEA EAX, PAD+9
PUSH EAX
PUSH 1
push $ + 10
JMP do_DOCOL
DD TYPE@  
DD SEMI
;
_qmark:                  ;  ( addr -- ) \ display single stored at address
DD _EMIT
DD do_QMARK
DB 0, 1, '?'
do_QMARK:  ;  @ . ;
PUSH $ + 10
JMP do_DOCOL
DD do_FETCH, do_PRINT
DD SEMI
;
_COMMA: ; , ( n -- )  ( compile cell at HERE, increment DP)
DD _qmark
COMMA:
DD do_COMMA
DB 0, 1, ','
do_COMMA:  ; HERE ! CELL DP +!  ;
PUSH $ + 10
JMP do_DOCOL
DD HERE, STORE, CELL, DPR, PLUSSTORE 
DD SEMI
;
_WCOMMA: ; : W, ( n -- )  ( compile word at HERE, increment DP)
DD _COMMA
DD do_WCOMMA
DB 0, 2, 'W,'
do_WCOMMA:
PUSH $ + 10
JMP do_DOCOL
DD HERE                                     ; HERE W! 2 DP +!  ;
DD do_WSTORE, LIT, 2, DPR, PLUSSTORE
DD SEMI
;
_CCOMMA:     ; C,  ( n -- )  ( compile byte at HERE, increment DP)
DD _WCOMMA
CCOMMA:
DD do_CCOMMA
DB 0, 2, 'C,'
do_CCOMMA:
PUSH $ + 10
JMP do_DOCOL                
DD HERE                                     ; HERE C! DP INCR ;
DD CSTORE, DPR, INCR@
DD SEMI
;
_CREATE:        ; ( "<spaces>name" -- )    Create a definition for name.   VERIFIED 231201
DD _CCOMMA
CREATE:
DD do_CREATE
DB 0, 6, 'CREATE'
do_CREATE:
PUSH $ + 10
JMP do_DOCOL 
DD HEADER       ;HEADER DOVAR COMPILE, ;
DD VARHEAD      ;DD do_DOVAR do_COMPILECOMMA
DD PUSH0, COMMA
DD SEMI
;
_CONHEAD:       ; COMPLETE HEADER FOR CONSTANT  VERIFIED 231201
DD _CREATE
CONHEAD:
DD do_CONHEAD
DB 0, 7, 'CONHEAD' 
do_CONHEAD:
MOV EAX, [NFA+9]
SUB EAX, 5 
MOV [EAX], do_DOCON
NEXTC
;
_CONSTANT:  ; ( n "name" -- )    create a constant (unchangeable) value    ; VERIFIED 231223
DD _CONHEAD
CONSTANT:
DD do_CONSTANT
DB 1, 8, 'CONSTANT'
do_CONSTANT: 
PUSH $ + 10
JMP do_DOCOL
DD HEADER      ; HEADER DOCON COMPILE, , ;
DD CONHEAD     ; LEAVE ADDRESS OF DOCON
DD COMMA       ; LEAVE VALUE
DD SEMI
;
_VARHEAD:       ; COMPLETE HEADER FOR VARIABLE  VERIFIED 231201
DD _CONSTANT
VARHEAD:
DD do_VARHEAD
DB 0, 7, 'VARHEAD' 
do_VARHEAD:
MOV EAX, [NFA+9]
SUB EAX, 5
LEA EBX, do_DOVAR1
MOV [EAX], EBX
NEXTC
;
_VARIABLE:      ; ( "name" -- )      create a variable (changeable) value     VERIFIED 231223
DD _VARHEAD
VARIABLE:
DD do_VARIABLE
DB 1, 8, 'VARIABLE'
do_VARIABLE:
PUSH $ + 10
JMP do_DOCOL
DD CREATE    ; CREATE 0 , ;
DD PUSH0
DD COMMA
DD SEMI
;
_VALUE:         ; ( n "name" -- )  \ create a self fetching changeable value  VERIFIED 231223
DD _VARIABLE
VALUE:
DD do_VALUE
DB 1, 5, 'VALUE'
do_VALUE:
PUSH $ + 10
JMP do_DOCOL
DD STATE, @
DD IF@, do_S_ADR, @                                         ; DETERMINS WHERE INPUT IS FROM
DD ELSE@, TIB
DD THEN@
DD LIT, 32, WORD@, COUNT
DD DUP2, UPPERCASE, DROP
DD NEWHEADER                                                       ; 'n TO value-name' will change a value
DD GCFA, do_DOVALUE, NFA, @, LIT, 5, MINUS, STORE                     ; DOVALUE COMPILE
DD COMMA                                                           ; ( n )     ,  Parameter field
DD SEMI
;
_LITERAL:       ;( n -- )
DD _VALUE       ; COMPILE LIT , ; IMMEDIATE 
LITERAL:
DD do_LITERAL
DB 1, 7, 'LITERAL'
do_LITERAL:
PUSH $ + 10
JMP do_DOCOL
DD do_COMPILE
DD LIT
DD do_COMMA
DD do_SEMI
;
_CHAR:  ; ( "c" -- char )
 ;   parse char from input stream and put its ascii code on stack.
 ;   If <c> is longer than a char, takes its first char.
 ;   If parse area is empty return 0.
 ;   BL WORD COUNT 0<> SWAP C@ AND ;
DD _LITERAL
CHAR@:
DD do_CHAR
DB 0, 4, 'CHAR'
do_CHAR:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, do_WORD, do_COUNT
DD do_0NE   ; 0 <>
DD do_SWAP, C@, do_AND
DD do_SEMI
;
PCHARP:
DD _CHAR
DD do_PCHARP
DB 1, 6, '[CHAR]'
do_PCHARP:
PUSH $ + 10
JMP do_DOCOL
DD do_CHAR
DD do_LITERAL
DD do_SEMI
;
_NUMBER?:        ; ( addr len -- d1 f1 ) 
DD PCHARP
NUMBER?:
DD do_NUMBER?
DB 0, 7, 'NUMBER?'
do_NUMBER?:
PUSH $ + 10
JMP do_DOCOL
COMMENT ~
DD NUMINIT, OVER, C@, LIT, '-'               ; CHAR 45
DD EQU, DUP@, venum, STORE
DD NEGATE
DD STRINGADJ
DD PUSH0, PUSH0
DD SWAP2
DD GTNUMBER
DD NIP
;                if false exit then leave if not all converted
;                -ve-num? if dnegate then true 
~
DD PNUMBERP
DD SEMI
;
_NUMBER:     ; ( str -- d ) COUNT (NUMBER?) ?MISSING   
DD _NUMBER?
NUMBER:
DD do_NUMBER
DB 0, 6, 'NUMBER'
do_NUMBER:
PUSH $ + 10
JMP do_DOCOL
DD COUNT, NUMBER?, ?MISSING
DD SEMI
;        
;   -------------------- NUMBER DEFINITIONS ---------------------------
;
POUNDS:         ;( d1 -- d2 ) \ consume last digits in a pictured number output - see <#
DD _NUMBER      ; BEGIN  #  2DUP OR 0= UNTIL ;
DD do_POUNDS
DB 0, 2, '#S'
do_POUNDS:
PUSH $ + 10
JMP do_DOCOL
DD do_BEGIN@
DD do_POUND
DD do_2DUP
DD do_OR
DD do_0GT       ; do_EQU0
DD do_UNTIL@
DD do_SEMI
;
_PDDOTP:            ; (D.) ( d -- addr len )   convert as signed double to ascii string
DD POUNDS
DD do_PDDOTP
DB 0, 4, '(D.)'
do_PDDOTP:          ; TUCK DABS  <# #S ROT SIGN #> ;
PUSH $ + 10
JMP do_DOCOL
DD do_TUCK
DD do_DABS
DD do_RPOUND
DD do_POUNDS
;DD do_ROT
;DD do_SIGN
DD do_LPOUND
DD do_SEMI
;
_DDOT:              ;( d -- )   display as signed double
DD _PDDOTP          ; (D.) TYPE SPACE ;
DD do_DDOT
DB 0, 2, 'D.'
do_DDOT:
PUSH $ + 10
JMP do_DOCOL
DD do_PDDOTP        ; (D.)
DD do_TYPE
DD LIT, 32
DD do_EMIT
DD do_SEMI
;
DDOTR:  ; ( d w -- ) \ display as signed double right justified in w wide field
DD _DDOT
DD do_DDOTR
DB 0, 3, 'D.R'
do_DDOTR:           ; >R (D.) R> OVER - SPACES TYPE ;
PUSH $ + 10
JMP do_DOCOL
DD do_TOR
DD do_DDOT
DD do_FROMR
DD OVER
DD MINUS
DD do_SPACES
DD do_TYPE
DD SEMI
;
SIGN:                  ; ( f1 -- ) \ insert a sign in pictured number output - see <#
DD DDOTR               ; 0< IF  [CHAR] - HOLD  THEN ;
DD do_SIGN
DB 0, 4, 'SIGN'
do_SIGN:
PUSH $ + 10
JMP do_DOCOL
DD do_0LT
DD do_IF
DD do_PCHARP            ; [CHAR]
DD 45                   ; '-' CHAR
DD do_HOLD
DD do_THEN
DD do_SEMI
;
RPOUND:             ; <# ( ud -- ) \ begin a pictured number output. Full example :
DD SIGN             ; : test dup 0< if negate -1 else 0 then >r
DD do_RPOUND        ; s>d <# [char] $ hold # # [char] . hold # # # [char] , hold #S r> sign #>
DB 0, 2, '<#'          ; cr type ;
do_RPOUND:          ; PAD HLD ! ;
PUSH $ + 10
JMP do_DOCOL
DD PAD
DD LIT, 12
DD PLUS
DD HLD, STORE
DD SEMI
;
LPOUND:              ; #> ( d1 -- addr len ) \ ends a pictured number output - see <#
DD RPOUND            ;2DROP  HLD @ PAD OVER - ;
DD do_LPOUND
DB 0, 2, '#>'
do_LPOUND:
PUSH $ + 10
JMP do_DOCOL
DD do_2DROP
DD HLD, DUP@, @
DD PAD  ;do_OVER
;DD do_SWAP, 
DD MINUS    ; NO NEED TO CALC LENGTH
DD SEMI
;
_IMMEDIATE:              ; ( -- )  VERIFIED 231227
DD LPOUND                ; \ mark the last header created as an immediate word
IMMEDIATE:
DD do_IMMEDIATE          ; LAST @ N>BFA BFA_IMMEDIATE ( TOGGLE ) over c@ or swap c! ;
DB 0, 9, 'IMMEDIATE'
do_IMMEDIATE:
PUSH $ + 10
JMP do_DOCOL
DD LASTNFA, MINUS1, DUP@, PUSH1, SWAP, do_CSTORE
DD do_SEMI
;
_IF:
DD _IMMEDIATE
DD do_IF
DB 0, 2, 'IF'
do_IF:
PUSH $ + 10
JMP do_DOCOL
COMMENT ~
    SWAP ['] LIT = OR 0=
    HERE CELL - @ ['] DUP = AND
    IF CELL NEGATE ALLOT COMPILE -?BRANCH
    ELSE COMPILE ?BRANCH
    THEN >MARK 2 ; IMMEDIATE
        ~
DD do_IMMEDIATE
DD do_SEMI
;
_ELSE:
DD _IF
DD do_ELSE
DB 0, 4, 'ELSE'
do_ELSE:
PUSH $ + 10
JMP do_DOCOL
COMMENT ~
       ?COMP  2 ?PAIRS  COMPILE 
       BRANCH >MARK  SWAP >RESOLVE  2 ; IMMEDIATE
        ~
DD do_IMMEDIATE
DD do_SEMI
;
_THEN:
DD _ELSE
DD do_THEN
DB 0, 4, 'THEN'
do_THEN:
PUSH $ + 10
JMP do_DOCOL
COMMENT ~
        ?COMP  2 ?PAIRS  COMPILE 
        _THEN >RESOLVE ; IMMEDIATE
        ~
DD do_IMMEDIATE
DD SEMI
;
_NIF:
DD _THEN
DD do_NIF
DB 0, 2, '-IF'
do_NIF:
PUSH $ + 10
JMP do_DOCOL

DD do_SEMI
;
_LMARK:         ; <MARK ( -- addr )   HERE ;
DD _NIF
DD do_LMARK
DB 0, 5, '<MARK'
do_LMARK:
PUSH $ + 10
JMP do_DOCOL
DD HERE
DD SEMI
;
_QCOMP:         ; ?COMP  STATE @ 0=  THROW_COMPONLY   ?THROW  ;
DD _LMARK       ; CHECK FOR COMPILATION STATE THROW ERROR IF NOT
DD do_?COMP
DB 0, 5, '?COMP'
do_?COMP:
PUSH $ + 10
JMP do_DOCOL
DD STATE, @, EQU0
DD SEMI
;
QPAIRS:                ; ?PAIRS        ( n1 n2 -- )  XOR THROW_MISMATCH ?THROW ; \ Sometimes used in applications.
DD _QCOMP
DD do_?PAIRS
DB 0, 6, '?PAIRS'
do_?PAIRS:
PUSH $ + 10
JMP do_DOCOL
DD do_XOR
DD do_SEMI
;
_BEGIN:            ; BEGIN  ?COMP  COMPILE _BEGIN <MARK CELL+ 1 ; IMMEDIATE
DD QPAIRS
DD do_BEGIN
DB 1, 5, 'BEGIN'
do_BEGIN:
PUSH $ + 10
JMP do_DOCOL
DD do_?COMP
DD do_COMPILE
DD do_LMARK
DD PUSH1
DD do_CELLPLUS
DD SEMI
;
LRESOLVE:       ; : <RESOLVE      ( addr -- )   , ;
DD _BEGIN
DD do_LRESOLVE
DB 0, 8, '<RESOLVE'
do_LRESOLVE:
PUSH $ + 10
JMP do_DOCOL
DD do_COMMA
DD SEMI
;
_BEGIN@:                    ; NOW USING THE CONTROL STACK  (CSP)
DD LRESOLVE                 ; verified working from interpreter 240101
BEGIN@:
DD do_BEGIN@
DB 0, 6, '[BEGIN]'
do_BEGIN@:
MOV EAX, CSP
SUB EAX, 4
MOV [EAX], EDI
MOV CSP, EAX
NEXTC
;
_UNTIL@:                    ; verified working from interpreter 240101
DD _BEGIN@
UNTIL@:
DD do_UNTIL@
DB 0, 6, '[UNTIL]'
do_UNTIL@:
POP EAX
CMP EAX, 0
JE @BU
MOV EAX, CSP
MOV EDI, [EAX]
NEXTC
@BU:
MOV EAX, CSP
ADD EAX, 4      ; BEGIN-UNTIL IS NOW COMPLETED DROP ADDRESS
MOV CSP, EAX
NEXTC
;
_UNTIL:         ; UNTIL ( F1 -- ) ?COMP  1 ?PAIRS  COMPILE _UNTIL  <RESOLVE ; IMMEDIATE
DD _UNTIL@ 
DD do_UNTIL
DB 0, 5, 'UNTIL'
do_UNTIL:
PUSH $ + 10
JMP do_DOCOL
DD do_?COMP
DD PUSH1
DD do_?PAIRS
DD do_COMPILE
DD do__UNTIL
DD do_LRESOLVE
DD SEMI
;
_dotR:               ;( n w -- ) \ display as signed single right justified in w wide field
DD _UNTIL@                   
DD do_dotR
DB 0, 2, '.R'
do_dotR:
PUSH $ + 10
JMP do_DOCOL
DD do_TOR, do_StoD, do_FROMR, do_DDOTR                      ; >R  S>D  R>  D.R
DD SEMI
;
_dotS: ;     ( -- ) \ display current data stack contents  VERIFIED 240106
DD _dotR
DD do_dotS
DB 0, 2, '.S'
do_dotS:
PUSH $ + 10
JMP do_DOCOL
DD PAD, LIT, 80, ERASE
DD QSTACK 
DD DEPTH, SMAX, MIN, SERROR, @, EQU0
DD IF@  ;  STACKERROR = 0
DD DUP@  ;  MIN = 0 
DD IF@
DD S0, @, LIT, 4, MINUS, TV3, STORE
DD LIT, 91, EMIT, DUP@                              ; do_DOTP, "["
DD PAD, SWAP, DWTOA, PAD, PUSH0                     ; invoke dwtoa, dwValue:DWORD, lpBuffer:DWORD 
DD STDOUT                                           ; DISPLAY ASCII TEXT IN PAD
DD LIT, 93, EMIT, LIT, 32, EMIT                     ; do_DOTP, "]"
DD BEGIN@, TV3, @, @                                ; BEGIN TV3 @ @
DD PAD, SWAP, DWTOA, PAD, PUSH0                     ; invoke dwtoa, dwValue:DWORD, lpBuffer:DWORD 
DD STDOUT                                           ; , PAD, LIT, 16, ERASE ; CLEAR PAD
DD LIT, 4, TV3, MINUSSTORE                          ; SDTOUT 4 TV3 -!   
DD LIT, 32, EMIT
DD MINUS1, DUP@, @0NE
DD UNTIL@
DD PLUS1
DD THEN@
DD THEN@
DD EQU0
DD IF@
DD LIT, Mempty, PUSH0, STDOUT       
; DISPLAY 'EMPTY' MESSAGE RESET STACK
DD THEN@ 
DD SERROR, @, PUSH0, NEQ                            ; STACKERROR <> 0
DD IF@
DD LIT, Msg22, PUSH0, STDOUT ; , RS                 ; DISPLAY 'STACKERROR' MESSAGE
DD THEN@
DD SEMI
;
COMMENT ~
\ -------------------- Error Handler ----------------------------------------

: CATCH         ( cfa -- flag ) \ execute the word given by its cfa in a way that
                \ will pass control to the word just after CATCH, whatever an error
                \ occurs while cfa is executed or not - see THROW which may be
                \ used inside the word "cfa" to handle errors if any.
                \ if no error occured, flag is 0, else the flag is given by THROW
                \ Beware: if an error occurs, any parameters for the word "cfa" are
                \ still on the stack, under "flag"
                SP@ >R
                LP @ >R
                OP @ >R
                HANDLER @ >R
                RP@ HANDLER !
                EXECUTE
                R> HANDLER !
                R>DROP
                R>DROP
                R>DROP
                0 ;

: THROW 	( n -- )
\ throw an error, identified by n, while executing a word
\ whose execution is "protected" by CATCH .
                ?DUP
                IF      HANDLER @ RP!
                        R> HANDLER !
                        R> OP !
                        R> LP !
                        R> SWAP >R
                        SP! DROP
                        R>
                THEN ;

: ABORT         ( -- )
                THROW_ABORT THROW ;

: NABORT!       ( addr n -- ) \ set message, n throw
                SWAP MSG ! THROW ;

: ABORT!        ( addr -- )  \ abort, print counted string passed
                THROW_ABORTQ NABORT! ;

NCODE ?THROW    ( f n -- )
\                SWAP IF THROW ELSE DROP THEN ;
                pop     eax
                test    eax, eax
                jz      short @@9
                mov     eax, # ' THROW         \ flag set, throw
                exec                           \ go do it
@@9:            pop     ebx                    \ correct tos
                next    c;


NCODE (("))     ( -- counted-string )
                push    ebx
                mov     ebx, 0 [ebp]
                movzx   ecx, byte ptr 0 [ebx]
                lea     eax, 5 [ebx] [ecx]  \ account for null at end
                and     eax, # -4       \ align
                mov     0 [ebp], eax
                next    c;

: (ABORT")      ( f -- )
                ((")) SWAP
                IF      ABORT!
                THEN    DROP ;

in-system

: ABORT"        ( flag -<ccc>- -- ) \ abort and display message ccc if flag is true
                COMPILE (ABORT")  ,"  ; IMMEDIATE
                
\ ------------------------------------------------------------

: U.            ( u -- ) \ display as unsigned single
                0 D. ;
: U.R           ( u w -- ) \ display as unsigned single right justified in w wide field
                0 SWAP D.R ;
: H.            ( u -- ) \ display as signed single in hexadecimal whatever BASE is
                BASE @ SWAP  HEX U.  BASE ! ;
: ?             ( addr -- ) \ display single stored at address
                @ . ;
;
\ -------------------- Structured Conditionals ------------------------------

: ?EXEC  STATE @     THROW_INTERPONLY ?THROW  ;
: >MARK         ( -- addr )   HERE 0 , ;           \ mark a link for later resolution
: <MARK         ( -- addr )   HERE ;
: >RESOLVE      ( addr -- )   HERE CELL+ SWAP ! ;
: <RESOLVE      ( addr -- )   , ;
: AHEAD  ?COMP  COMPILE  BRANCH  >MARK 2 ; IMMEDIATE

\ gah Modified to optimize DUP IF into -IF
: IF     ?COMP  HERE 2 CELLS - @ DUP ['] COMPILE =
                SWAP ['] LIT = OR 0=
                HERE CELL - @ ['] DUP = AND
                IF CELL NEGATE ALLOT COMPILE -?BRANCH
                ELSE COMPILE ?BRANCH
                THEN >MARK 2 ; IMMEDIATE
: -IF    ?COMP  COMPILE -?BRANCH  >MARK 2 ; IMMEDIATE
: THEN   ?COMP  2 ?PAIRS  COMPILE _THEN >RESOLVE ; IMMEDIATE
: ENDIF  [COMPILE] THEN ; IMMEDIATE
: ELSE   ?COMP  2 ?PAIRS  COMPILE BRANCH >MARK  SWAP >RESOLVE  2 ; IMMEDIATE
: AGAIN  ?COMP  1 ?PAIRS  COMPILE _AGAIN  <RESOLVE ; IMMEDIATE
: WHILE  ?COMP  COMPILE _WHILE  >MARK 2  2SWAP ; IMMEDIATE
: REPEAT ?COMP  1 ?PAIRS  COMPILE _REPEAT <RESOLVE  2 ?PAIRS >RESOLVE ; IMMEDIATE
: DO     ?COMP  COMPILE (DO)   >MARK 3 ; IMMEDIATE
: ?DO    ?COMP  COMPILE (?DO)  >MARK 3 ; IMMEDIATE
: LOOP   ?COMP  3 ?PAIRS  COMPILE (LOOP)   DUP 2 CELLS+ <RESOLVE >RESOLVE ; IMMEDIATE
: +LOOP  ?COMP  3 ?PAIRS  COMPILE (+LOOP)  DUP 2 CELLS+ <RESOLVE >RESOLVE ; IMMEDIATE
NCODE BRANCH    ( -- )                    \ "runtime" for branch always
                brnext 

NCODE ?BRANCH   ( f1 -- )                 \ "runtime" for branch on f1=FALSE
                test    ebx, ebx
                pop     ebx
                je      short @@1        \ yes, do branch
                mov     eax, 4 [esi]      \ optimised next
                add     esi, # 8
                exec ; jmp     [eax]
@@1:            brnext 

NCODE -?BRANCH  ( f1 -- fl )             \ non-destructive "runtime" for branch on f1=FALSE
                test    ebx, ebx
                je      short @@1        \ yes, do branch
                mov     eax, 4 [esi]      \ optimised next
                add     esi, # 8
                exec  ; jmp     [eax]
@@1:            brnext 

\ -------------------- Eaker CASE statement ---------------------------------

: CASE   ?COMP  COMPILE _CASE  0 ; IMMEDIATE
: OF     ?COMP  COMPILE _OF  >MARK 4 ; IMMEDIATE
: ENDOF  ?COMP  4 ?PAIRS  COMPILE _ENDOF  >MARK  SWAP >RESOLVE  5 ; IMMEDIATE

: ENDCASE  ?COMP  COMPILE _ENDCASE
           BEGIN  ?DUP WHILE  5 ?PAIRS  >RESOLVE  REPEAT ; IMMEDIATE

; ---------------------------------------------------------------------------------------------------
: QUERY         ; ( -- ) accept a line of input from the user to TIB
                 TIB DUP MAXSTRING ACCEPT   (SOURCE) 2!
                 >IN OFF
                 0 TO SOURCE-ID 0 TO SOURCE-POSITION ;;
 
 : ?MISSING        ( f -- )
                 0= THROW_UNDEFINED AND THROW 
 
 : _INTERPRET      ( -- )
                 BEGIN   BL WORD DUP C@
                 WHILE   SAVE-SRC FIND ?DUP
                         IF      STATE @ =
                                 IF      COMPILE,           COMPILE TIME
                                 ELSE    EXECUTE ?STACK     INTERPRET
                                 THEN
                         ELSE    NUMBER NUMBER,
                         THEN    ?UNSAVE-SRC
                 REPEAT  DROP ;
; ------------------------------------------------------------------------------
~
;
_ACCEPT:
DD _dotS
ACCEPT:
DD do_ACCEPT
DB 0, 6, 'ACCEPT'
do_ACCEPT:                          ; ( -- NBREAD)
PUSH $ + 10
JMP do_DOCOL
DD TIB, ZCOUNT, ERASE 
DD KBREAD                           ; ( -- n ) EAX = NBREAD n
DD TIB, SWAP, UPPERCASE
DD SEMI
;
_FORGET:
DD _ACCEPT
FORGET:
DD do_FORGET
DB 0, 6, 'FORGET'
do_FORGET:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, WORD@, COUNT, FIND     ; LOCATE LFA OF WORD TO REMOVE
DD LFA, @, DUP@, DUP@, @, LATEST, STORE, DUP@
DD DPR, @, SWAP, MINUS, SWAP, DPR, STORE
DD PUSH0, FILL, DROP                    ; ERASE SPACE FROM LFA TO END OF DICT (DPR)
DD SEMI
;
_DOTP:                      ; VERIFIED 240107
DD _FORGET
DD do_DOTP
DB 1, 2, '."'
do_DOTP:                    ; HERE [CHAR] " PARSE ", 0 C, ALIGN COUNT
PUSH $ + 10
JMP do_DOCOL
DD PAD, ZCOUNT, ERASE
DD TIB, LIT, '"', WORD@     ; PARSE INPUT STRING TIB " WORD
DD COUNT                    ; GET LENGTH
DD PAD, SWAP                ; MOVE THE DATA IN THE TIB TO THE DATA AREA
DD DUP2, @2TOR, CMOVE@, FROMR2
DD TYPE@
DD PUSH1, _IN, PLUSSTORE    ; 1 _IN @ + _IN !     INCREMENT THE _IN OFFSET
DD PAD, ZCOUNT, ERASE
DD SEMI
;
_PAUSE:         ; ( N -- ) PAUSE FOR N MILLISECONDS          VERIFIED
DD _DOTP
PAUSE@:
DD do_PAUSE
DB 0, 5, 'PAUSE'
do_PAUSE:
PUSH $ + 10
JMP do_DOCOL
DD MS, PLUS
DD BEGIN@
DD MS, OVER, GT@, EQU0
DD UNTIL@
DD DROP
DD SEMI
NEXTC
;
_KEY:       ; ( -- C )  INPUTS A CHARACTER FROM KEYBOARD
DD _PAUSE
KEY:
DD do_KEY  
DB 0, 3, 'KEY'
do_KEY:

NEXTC
;
_KEYQ:      ; ( -- N ) CHECK FOR CHARACTER IN BUFFER
DD _KEY
DD do_KEYQ
DB 0, 4,'KEY?'
do_KEYQ:
push  KEYIN
push 0
call GetNumberOfConsoleInputEvents
NEXTC
;
_ALLOT:         ; ( n -- ) \ allocate n bytes at HERE, increment DP         VERIFIED
DD _KEYQ        ; DUP 256 + ?MEMCHK DP +! ;
ALLOT:
DD do_ALLOT
DB 0, 5, 'ALLOT'
do_ALLOT:
PUSH $ + 10
JMP do_DOCOL
DD DUP@, LIT, 256, PLUS
DD MEM?, LT@
DD IF@, DPR, PLUSSTORE, PUSH0
DD THEN@, DROP
DD SEMI
;
_TICK:      ; ( -- ADDR ) RETURNS THE CFA OF THE NEXT INPUT WORD   VERIFIED 231214
DD _ALLOT
DD do_TICK
DB 0, 1, "'"
do_TICK:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, WORD, COUNT, FIND
DD SEMI
;
_TO:                        ; VERIFIED 231201
DD _TICK 
TO:
DD do_TO
DB 0, 2, 'TO'
do_TO:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, WORD@, COUNT, FIND
DD VALUESTORE
DD SEMI
;
_PTO:                        ; VERIFIED 231201
DD _TO 
PTO:
DD do_PTO
DB 0, 3, '+TO'
do_PTO:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, WORD@, COUNT, FIND
DD DOVALPLUSTORE
DD SEMI
;
_ZCOMMAQ:             ; Z,"  ( -<string">- )  \ compile string delimited by " as uncounted
DD _PTO               ;      chars null-terminated chars at here
DD do_ZCOMM           ;      HERE [CHAR] " PARSE Z", 0 C, ALIGN ZCOUNT \N->CRLF
DB 0, 3,'Z,"'
do_ZCOMM:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 34, PARSE, DUP2, HERE, SWAP, CMOVE@
DD NIP, DUP@, HERE, PLUS, DPR, STORE
DD PUSH0, CCOMMA
DD SEMI
;
_ANEW:              ; MARKER FOR USE OF FORGET      VERIFIED 231205
DD _ZCOMMAQ
ANEW:
DD do_ZCOMMAQ
DB 0, 4, 'ANEW'
do_ZCOMMAQ:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, 32, WORD@, COUNT
DD NEWHEADER 
DD GCFA, NOOP, NFA, LIT, 4, MINUS, STORE 
DD SEMI
;
_WORDS:                 ; listing of dictionary words          VERIFIED 231224
DD _ANEW
WORDS:
DD do_WORDS             
DB 0, 5, 'WORDS'
do_WORDS:
PUSH $ + 10  
JMP do_DOCOL
DD PAD, LIT, 160, ERASE
DD PAD, HLD, STORE, PUSH0, TV1, STORE
DD LATEST, @
DD BEGIN@
DD DUP@, LIT, 9, PLUS, DUP@, PUSH1, PLUS, SWAP, C@, DUP@, TOR   ; SAVE LENGTH
DD HLD, @, SWAP, CMOVE@, FROMR                                  ; RECOVER LENGTH
DD PUSH1, TV1, PLUSSTORE                                        ; INCREMENT COUNTER
DD LIT, 16, SWAP, MINUS, PAD, ZCOUNT, PLUS, SWAP
DD LIT, 32, FILL                                                ; ADD SPACES TO END OF THE BUFFER 
DD LIT, 12, HLD, PLUSSTORE
DD TV1, @, LIT, 8, EQU@
DD IF@
DD PAD, ZCOUNT, TYPE@, CR, LIT, 100, PAUSE@
DD PUSH0, TV1, STORE, PAD, ZCOUNT, LIT, 0, FILL
DD PAD, HLD, STORE
DD THEN@
DD @, DUP@, @0NE
DD UNTIL@
DD TV1, @, LIT, 0, GT@
DD IF@
DD PAD, ZCOUNT, TYPE@, CR, CR
DD PUSH0, TV1, STORE, PAD, ZCOUNT, LIT, 0, FILL
DD THEN@
DD SEMI
;
_CTYPE:  ; ( STRING, LEN -- )       VERIFIED 231208
DD _WORDS
CTYPE:
DD do_CTYPE
DB 0, 5, 'CTYPE'
do_CTYPE:
PUSH $ + 10
JMP do_DOCOL
DD BEGIN@
DD do_TOR
DD DUP@, C@, do_CMAX, do_EMIT
DD MINUS1
DD do_FROMR, MINUS1, DUP@
DD UNTIL@, do_2DROP
DD SEMI
;
_DUMP:         ; ( ADDR, N --  )  VERIFIED 231224
DD _CTYPE
DD do_COLN
DB 0, 4, 'DUMP'
DD do_CR
@DLOOP1:
DD TV1, STORE, TV2, STORE
DD PAD, HLD, STORE
DD TV2, @, TV1, @, PLUS     ; CALC END POINT AND SAVE
DD BEGIN@, do_TOR                               ; BEGIN0
DD HLD, @, TV2, @, do_I2HEX    
DD ZCOUNT, do_TYPE
DD do_SEP1, ZCOUNT, do_TYPE
DD PAD, ZCOUNT, ERASE
DD LIT, 4, BEGIN@, do_TOR                   ; BEGIN1
DD TV2, @, @, do_BEXT
DD LIT, 4, BEGIN@, do_TOR                   ; BEGIN2
DD do_BTOH, PAD, ZCOUNT, do_TYPE, LIT, 32, do_EMIT
DD do_FROMR, MINUS1, DUP@  
DD UNTIL@                                        ; UNTIL2
DD DROP 
DD TV2, DUP@, @, LIT, 4, PLUS, SWAP, STORE ; TV2 DUP @  4 + SWAP !
DD do_FROMR, MINUS1, DUP@  
DD UNTIL@                                        ; UNTIL1
DD DROP, do_SEP1, ZCOUNT, do_TYPE
DD LIT, 125, do_PAUSE
DD TV2, @, LIT, 16, MINUS, LIT, 16, do_CTYPE
DD do_SEP1, ZCOUNT, do_TYPE, do_CR
DD do_FROMR, DUP@, TV2, @, MINUS, do_0GT
DD UNTIL@                                        ; UNTIL0
DD DROP, do_CR
DD SEMI
;
_FILEEXIST:         ; ( ADDR -- F )  0 = FILE EXIST   -1 = FILE NOT FOUND   VERIFIED 231213
DD _DUMP
FILEEXIST:
DD do_FILEQ
DB 0, 10, 'FILEEXIST'
do_FILEQ:
PUSH $ + 10
JMP do_DOCOL
DD LIT, 80000000H, do_FILEOPEN, do_SWAP, do_DUP, do_0GT
DD do_IF@, do_FILECLOSE, do_DROP, do_ELSE@, do_NIP
DD do_THEN@
DD do_SEMI
;
_COMMENT1:                          ; VERIFIED 122322
DD _FILEEXIST
DD do_COLN
DB 1, 1, '\'                        ; IMMEDIATE WORDS
DD LIT, 13, do_PARSE, do_2DROP   ; ASSUMES INPUT BUFFER HAS BEEN PLACED ON STACK             
DD do_SEMI
;
_COMMENT2:
DD _COMMENT1
DD do_COLN
DB 1, 1, '('                        ; IMMEDIATE WORDS
DD LIT, 41, do_PARSE, do_2DROP   ; ASSUMES INPUT BUFFER HAS BEEN PLACED ON STACK  
DD do_SEMI
;
_PNUMBERP:                        ; ( ADDR LEN -- ADDR FLAG )   VERIFIED 231219
DD _COMMENT2                    ; CHECKS TO SEE IF HEX CODE 'H' ON END OR 1ST CHAR > 9
PNUMBERP:
DD do_PNUMBERP
DB 0, 8, '(NUMBER)'
do_PNUMBERP:
PUSH $ + 10
JMP do_DOCOL
DD OVER, SWAP, MINUS1, PLUS, C@, LIT, 'H', EQU@
DD SWAP, DUP@, C@, LIT, '9' , GT@, ROT, OR@
DD NEWNUMB
DD SEMI
;
_INTERPRET:                 ; VERIFIED 231221
DD _PNUMBERP
INTERPRET:
DD do_INTERPRET
DB 0, 9, 'INTERPRET'
do_INTERPRET:
PUSH $ + 10
JMP do_DOCOL
DD FFLAG, @                              ; FLAG = TRUE <>0 THEN EXECUTE
DD IF@, EXECUTE     
DD ELSE@, NUMBER, EMSG, THEN@          ; ? NUMBER AVAILABLE ON STACK    
DD SEMI
;
_BPA:    ; (  --  )
DD _INTERPRET
TOBPA:
DD do_COLN
DB 0, 4, '>BPA'
;PUSH $ + 10
;JMP do_DOCOL
DD NFA, @, LIT, 2, MINUS, C@
DD IF@, EXECUTE, ELSE@, do_COMMA, THEN@
DD SEMI
;
NUMBER@:   ;
DD _BPA
TONUMBER: 
DD do_NUMBER@
DB 0, 7, '>NUMBER'
do_NUMBER@:
PUSH $ + 10
JMP do_DOCOL
DD NUMBER, do_IF@, do_COMMA, do_THEN
DD do_SEMI
;
_LOAD:      ; ( ADDR LEN -- )  COMPILE FROM A FILE   WORK IN PROGRESS --  
DD NUMBER@
DD do_COLN
DB 0, 4, 'LOAD'
do_LOAD:
DD S_LEN, STORE, PUSH0, _IN, STORE
DD do_S_ADR, STORE, STATE, do_ON, do_COMPF, do_ON
DD BEGIN@
DD do_S_ADR, do_FETCH, LIT, 32, WORD
DD COUNT, DUP2, UPPERCASE, OVER, do_TYPE, do_CR, FIND        
DD FFLAG, @ 
DD IF@, TOBPA
DD ELSE@, NUMBER@
DD THEN@
;
DD S_LEN, @, _IN, @, MINUS        ; S_LEN @ _IN @ - 
DD UNTIL@
DD STATE, do_OFF, do_COMPF, do_OFF
DD do_CR, TIB, do_S_ADR, STORE
DD PUSH0, DUP@, S_LEN, STORE, _IN, STORE
DD SEMI
;
_COLON:         ; 
DD _LOAD        ; Link File Addess (LFA) Pointer to previous words
DD do_COLN      ; CFA - Code Field Address
DB 0, 1, ':'       ; NFA - NAME FIELD
do_COLON:
DD STATE, @, IF@, do_S_ADR, @, ELSE@, TIB, THEN@
DD LIT, 32, WORD, COUNT
DD DUP2, UPPERCASE, DROP
DD NEWHEADER, GCFA, do_COLN, 
NFA, LIT, 4, MINUS,  STORE
DD SEMI
;
COMMENT ~
: IF     ?COMP  HERE 2 CELLS - @ DUP ['] COMPILE =
                SWAP ['] LIT = OR 0=
                HERE CELL - @ ['] DUP = AND
                IF CELL NEGATE ALLOT COMPILE -?BRANCH
                ELSE COMPILE ?BRANCH
                THEN >MARK 2 ; IMMEDIATE
: -IF    ?COMP  COMPILE -?BRANCH  >MARK 2 ; IMMEDIATE
: THEN   ?COMP  2 ?PAIRS  COMPILE _THEN >RESOLVE ; IMMEDIATE
: ENDIF  [COMPILE] THEN ; IMMEDIATE
: ELSE   ?COMP  2 ?PAIRS  COMPILE BRANCH >MARK  SWAP >RESOLVE  2 ; IMMEDIATE
~
;
_LASTNFA:           ; (  -- NFA ) RETURNS NFA ADDRESS OF LAST WORD CREATED VERIFIED 231227
DD _COLON
LASTNFA: 
DD do_LASTNFA
DB 0, 7, 'LASTNFA'
do_LASTNFA:
PUSH $ + 10
JMP do_DOCOL
DD do_LAST, LIT, 9, PLUS
DD SEMI
;
_LOADFILE1:
DD _LASTNFA
LOADFILE1: 
DD do_ARRBLD
DB 0, 9, 'LOADFILE1'
do_ARRBLD:
PUSH $ + 10
JMP do_DOCOL
DD PUSH0, STATE, do_ON, do_VALUE
DB 'FH1'
DD STATE, do_OFF
DD do_MsgF1, do_PUSH0, LIT, -2147483648, do_FILEOPEN
DD DROP, do_FILECLOSE, DROP
DD SEMI
;
_TESTING:
DD _LOADFILE1
TEST1: 
DD TESTING
DB 0, 5, 'TEST1'
TESTING:
PUSH $ + 10
JMP do_DOCOL
DD LIT, 35, TV1, STORE
DD SEMI
;
_MOD:            ; ( n1 n2 -- rem ) \ integer single divide : remainder  VERIFIED 240105
DD _TESTING
MODREM: 
DD do_MOD
DB 0, 3, 'MOD'
do_MOD:
PUSH $ + 10
JMP do_DOCOL
DD MODIVIDE, DROP
DD SEMI
;
_DIVIDE:         ;  ( n1 n2 -- quot ) \ integer single divide : quotient  VERIFIED 240105
DD _MOD
DIVIDE: 
DD do_DIVIDE
DB 0, 1, '\'
do_DIVIDE:
PUSH $ + 10
JMP do_DOCOL
DD MODIVIDE, NIP
DD SEMI
;
_SP:                            ; ( -- ADDR N)  EG S" TEXT TO HANDLE"         VERIFIED
DD _DIVIDE
SP@:
DD do_SP
DB 1, 2, 'S"'                   ; IMMEDIATE WORD
do_SP:
PUSH $ + 10
JMP do_DOCOL
DD TIB, LIT, '"', WORD@                       ; PARSE INPUT STRING TIB " WORD
DD COUNT                                      ; GET LENGTH
DD PUSH1, _IN, PLUSSTORE                      ; 1 _1IN @ + _1IN !     INCREMENT THE _IN OFFSET
DD SCRATCH, DUP@, LIT, 80, ERASE
DD SWAP                                       ; MOVE THE DATA IN THE TIB TO THE DATA AREA
DD DUP2, @2TOR, CMOVE@, FROMR2
DD STATE, @
DD IF@                                        ; IF IN COMPILE STATE
DD HERE, OVER, CCOMMA, OVER, ALLOT, MINUS1, SWAP, CMOVE@
DD PUSH0, CCOMMA, ALIGN@
DD THEN@
DD SEMI
;
_COMPILEC:
DD _SP
COMPILEC: 
DD do_COLN
DB 0, 8, 'COMPILE,'
DD do_COMPILE
DD do_COMMA
DD do_SEMI
;
EOC:
; #########################################################################
;
.data ; Data Section
;
DSB db 'DSBUFFER', 32 dup (0H) ; A buffer between the data stack and return stack
R0 db 1024 dup (0H) ; Return Stack Base of size 1024 
RSB db 'RSBUFFER', 32 dup (0H) ; Buffer between return stack and CONTROL STACK
C0 db 1024 DUP (0H) ; CONTROL WORDS STACK
CSB db 'CSBUFFER', 32 DUP (0H) ; Buffer between CONTROL stack and data area
; PAD db 160 dup (0H) ; Output buffer
; TIB db 160 dup (0H) ; Input buffer
; POC db 160 dup (0H) ; Pocket 
; SCRATCH db 160 DUP (0H) ; SCRATCH PAD FOR CONVERSIONS
_SYSTIME DD 4 dup (0H) ; SYSTEM TIME  SEE STRUCTURE IN NOTES ABOVE 
; -----------------------------
_EDI DD 0
_hMemory DD 0

_SOURCE DD TIB, 0
ABORTFLAG DD 0
BYEFLAG DD 1        ; EXIT FLAG
COMPFQ DD 0         ; COMPILE FLAG = 1 IN COMPILE MODE
CSP DD C0 + 1023    ; CONTROL STACK POINTER
CURRENT DD 0
DOUBLEQ DD 0        ; double value
DPLOCATION DD -1    ; decimal point location
FCOUNTER DD 0       ; FIND COUNTER
gone dd 0
KEYIN DD 0
MALLOCHADDR DD 0   ; heap address
MALLOCLINK  DD 0   ; head of single linked list
MAXBUFFER DD 260
MAXCOUNTED DD 255
MAXSTRING DD 255
MEMLIMIT DD USER_BASE+(1024*64)
pMem DD 0
POCKET DD POC+9
PREVIOUS DD EOD
RSP DD R0 + 1023 ; RETURN STACK POINTER
S_ADR DD TIB+9
S1_ADR DD 0
SIGNFLAG DD 0
S1_LEN DD 0
VENUMQ DD 0
xpos DD 0       ; SCREEN COORDINATES
ypos DD 0
; -----------------------------
Msg1 db  '        Fig-Forth vs 2.51', 13, 10, 0h
Msg1A db '            FJRusso', 13, 10, 0h
Msg2 db  '     Friday, January 05, 2024' , 13, 10, 0h
Msg3 db ' sdfj rjsdl; fFDKJ;SDFORSJ 34854356 lksirn 54kvf 35kfg ', 0h ; NOT USED
Msg4 db ' AIFVJOI FAOJ AVFAO VOI54 fghgfh6U04R NFRRdfgbbgV NARV ', 0h ; NOT USED
Msg5 db ' Text Interpreter entered ', 0h
Msg6 db ' ok', 13, 10, 0h
Msg7 db ' wait key -- ', 0h
Msg8 db ' Exiting FORTH', 13, 10, 0h
Msg9 db ' Fig Forth Begining', 0h
Msg10 db ' ERROR OCCURED - ', 0h
Msg11 db ' - NOT FOUND', 13, 10, 0h
Msg12 db ' Data Section - ', 0h
Msg13 db ' Core Space - ', 0h
Msg14 db ' Appl Space - ', 0h
Msg15 db ' bytes used', 13, 10, 0h
Msg16 db ' bytes free', 13, 10, 0h
Msg17 db ' Words in Dictionary - ',0h
Msg18 db ' Failure to Allocate memory', 13, 10, 0h
Msg19 db ' Process ABORTED ', 13, 10, 0h
Msg20 db ' Press ENTER to continue --- ', 0h
Msg21 db ' Process Terminated', 0H
Msg22 db ' Stack Underflow ERROR', 0H
Msg23 db ' Stack Overflow ERROR', 0H
;
MsgQ db ' ? ', 0H
MsgF1 db 'build-array.f', 0H
Mempty db ' empty ', 0h
; crlf$ db 13, 10, 0h
SEP1$ db ' | ', 0h
SPACE$ db 20H,0H
HEX_TABLE db "0123456789ABCDEF"
%Date       db  " &@Date ", 0H      ; DATE Compiled
%Time       db  " &@Time", 0H       ; TIME Compiled
;
MESSAGES DB  ' No Errors ', 13, 10, 0h,
 '        Fig-Forth vs 2.51', 13, 10, 0h,
 '            FJRusso', 13, 10, 0h,
 '     Friday, January 05, 2024' , 13, 10, 0h,
 ' sdfj rjsdl; fFDKJ;SDFORSJ 34854356 lksirn 54kvf 35kfg ', 0h, ; NOT USED
 ' AIFVJOI FAOJ AVFAO VOI54 fghgfh6U04R NFRRdfgbbgV NARV ', 0h, ; NOT USED
 ' Text Interpreter entered ', 0h,
 ' ok', 13, 10, 0h,
 ' wait key -- ', 0h,
 ' Exiting FORTH', 13, 10, 0h,
 ' Fig Forth Begining', 0h,
 ' ERROR OCCURED - ', 0h
 MESSAGES2 DB ' - NOT FOUND', 13, 10, 0h,
 ' Data Section - ', 0h,
 ' Core Space - ', 0h,
 ' Appl Space - ', 0h,
 ' bytes used', 13, 10, 0h,
 ' bytes free', 13, 10, 0h,
 ' Words in Dictionary - ',0h,
 ' Failure to Allocate memory', 13, 10, 0h,
 ' Process ABORTED ', 13, 10, 0h,
 ' Press ENTER to continue --- ', 0h,
 ' Process Terminated', 0H,
 ' Stack Underflow ERROR', 0H,
 ' Stack Overflow ERROR', 0H, 0H
;
; ********************
; STSYEM VARIABLES, CONSTANTS & VALUES 
; ********************
;
;
_LATEST DD _COMPILEC                       ; Returns address of the variable LATEST           ; VERIFIED
LATEST DD do_DOVAR                         ; LAST WORD IN DICTIONARY
DB 0, 6,'LATEST'
DD 0
;
__IN DD _LATEST  
_IN DD do_DOVAR
DB 0, 3, '_IN'
DD 0
;
_LFA DD __IN
LFA DD do_DOVAR
DB 0, 3, 'LFA'
DD 0
;
_NFA DD _LFA
NFA DD do_DOVAR
DB 0, 3, 'NFA'
DD 0
;
_CFA DD _NFA
CFA DD do_DOVAR
DB 0, 3, 'CFA'
DD 0
;
_PFA DD _CFA
PFA DD do_DOVAR
DB 0, 3, 'PFA'
DD 0
;
__1IN DD _PFA  
_1IN DD do_DOVAR
DB 0, 3, '_1IN'
DD 0
;
_S_MAX DD __1IN
SMAX DD do_DOCON
DB 0, 4, 'SMAX'
DD 8
;
_S_LEN DD _S_MAX
S_LEN DD do_DOVAR
DB 0, 5, 'S_LEN'
DD 0
;
_HLD DD _S_LEN
HLD DD do_DOVAR
DB 0, 3, 'HLD'
DD 0
;
_CRLF DD _HLD
CRLF DD do_DOVAR
DB 0, 4, 'CRLF'
DB 13, 10, 0, 0
;
_DCW DD _CRLF
DCW DD do_DOVAR
DB 0, 3, 'DCW'
DD 0
;
_S0 DD _DCW
S0 DD do_DOVAR
DB 0, 2, 'S0'
DD 0
;
_DPR DD _S0
DPR DD do_DOVAR
DB 0, 3, 'DPR'
DD 0
;
_STACKERROR DD _DPR
SERROR DD do_DOVAR
DB 0, 10, 'STACKERROR'
DD 0
;
_ABORTFLAG DD _STACKERROR
ABFLG DD do_DOVAR
DB 0, 9, 'ABORTFLAG'
DD 0
;
_FINDFLAG DD _ABORTFLAG
FFLAG DD do_DOVAR
DB 0, 5, 'FFLAG'
DD 0
;
_STATE DD _FINDFLAG
STATE DD do_DOVAR
DB 0, 5, 'STATE'
DD 0
;
_BASE DD _STATE
BASE DD do_DOVAR
DB 0, 4, 'BASE'
DD 0
;
_TV1 DD _BASE 
TV1 DD do_DOVAR
DB 0, 3, 'TV1'
DD 0
;
_TV2  DD _TV1 
TV2 DD do_DOVAR
DB 0, 3, 'TV2'
DD 0
;
_TV3  DD _TV2 
TV3 DD do_DOVAR
DB 0, 3, 'TV3'
DD 0
;
_TV$  DD _TV3
TV$ DD do_DOVAR
DB 0, 3, 'TV$'
DD 0
;
_SPACE DD _TV$                  
SPACE DD do_DOCON
DB 1, 5, 'SPACE'
DD 32
;
_BL DD _SPACE                   
BLK DD do_DOCON
DB 1, 3, 'BLK'
DD 32
;
_FH1 DD _BL
FH1 DD do_DOVALUE
DB 0, 3, 'FH1'
DD 0
;
_FH2 DD _FH1
FH2 DD do_DOVALUE
DB 0, 3, 'FH2'
DD 0
;
_FH3 DD _FH2
FH3 DD do_DOVALUE
DB 0, 3, 'FH2'
DD 0
; ********************
;  SYSTEM BUFFER AREA
; ********************
_FS1 DD _FH3     ; FILE 1 SIZE
FS1 DD do_DOVALUE
DB 0, 3, 'FS1'
DD 0
;
_FS2 DD _FS1     ; FILE 2 SIZE
FS2 DD do_DOVALUE
DB 0, 3, 'FS2'
DD 0
;
_FS3 DD _FS2     ; FILE 3 SIZE
FS3 DD do_DOVALUE
DB 0, 3, 'FS3'
DD 0
;
_FB1 DD _FS3     ; FILE 1 BUFFER
FB1 DD do_DOVAR
DB 0, 3, 'FB1'
DB 1024 DUP (0H)
;
_FB2 DD _FB1     ; FILE 2 BUFFER
FB2 DD do_DOVAR
DB 0, 3, 'FB2'
DB 1024 DUP (0H)
;
_FB3 DD _FB2     ; FILE 3 BUFFER
FB3 DD do_DOVAR
DB 0, 3, 'FB3'
DB 1024 DUP (0H)
;
_PAD DD _FB3     ; OUTPUT BUFFER
PAD DD do_DOVAR
DB 0, 3, 'PAD'
DB 256 DUP (0H)
;
_TIB DD _PAD     ; INPUT BUFFER
TIB DD do_DOVAR
DB 0, 3, 'TIB'
DB 256 DUP (0H)
;
_SCRATCH DD _TIB       ; SCRATCH PAD FOR CONVERSIONS
SCRATCH DD do_DOVAR
DB 0, 7, 'SCRATCH'
DB 256 DUP (0H)
;
_POC DD _SCRATCH
POC DD do_DOVAR
DB 0, 3, 'POC'
DB 256 DUP (0H) 
;
_EOD DD _POC
EOD DD do_DOVALUE
DB 0, 3, 'EOD'
DD 0
;
USER_BASE DD 0
DD 16364 dup (0H); Start of USER Area Dictionary 64k

END Start
; #########################################################################