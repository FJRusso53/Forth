; Forth-Core.asm
;
; FJRusso Vs 1.0 
; Frank's attempt at a FORTH Core in 32 bit Assmembler
; 231028 1830
; 
; Using MASM32 in VS 2022
;
.486
.MODEL flat,stdcall
option casemap :none   ; case sensitive
;
.stack 4096 
;
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
   JMP EAX 
endm

BRNEXT macro byte
   mov edi, [edi]
   mov eax, -4 [edi]
   jmp [eax]
endm
;
Main        PROTO
DEFCOUNT    PROTO
;
;      
; #########################################################################
;
.data ; Data Section
;
DSB DB 'DSBUFFER', 32 dup (0H) ; A buffer between the data stack and return stack
R0 DB 1024 dup (0H) ; Return Stack Base of size 1024 
RSB DB 'RSBUFFER', 32 dup (0H) ; Buffer between return stack and data area
PAD DB 256 dup (0H) ; Output buffer
TIB DB 256 dup (0H) ; Input buffer
POC DB 256 dup (0H) ; Pocket 
; -----------------------------
_EDI DD 0
_IN DD 0
_SOURCE DD TIB, 0
BASE DD 0
BYEFLAG DD 1
CFA DD 0
CURRENT DD 0
DOUBLEQ DD 0                            ; double value
DPLOCATION DD -1                        ; decimal point location
DPR DD 0
FCOUNTER DD 0
FFLAG DD 0
gone dd 0
HLD DD PAD
LATEST DD _Endless
LFA DD 0
MAXBUFFER DD 260
MAXCOUNTED DD 255
MAXSTRING DD 255
MEMLIMIT DD USER_BASE+(1024*64)
NFA DD 0
POCKET DD POC
PREVIOUS DD _TO
RSP DD R0 + 1023
S_ADR DD TIB
SIGNFLAG DD 0
S_LEN DD 0
SMAX DD 8
S0 DD 0 ; Stack base starting point pointer
STATE DD 0
testv DD 0
VENUMQ DD 0
VOCCOUNT DD 0
xpos DD 0
ypos DD 0
; -----------------------------
Msg1 DB  ' Forth VS 3.0 ' , 0h
Msg1A DB '   FJRusso ' , 0h
Msg2 DB  ' November 2023 ' , 13, 10, 0h
Msg3 DB ' abcDef1 8 ghiJklm; ? noPQres / tuvwXyz.', 0h
Msg4 DB ' AB.CDEfFG,HIJKL&mMNO PQrRST@UV WXYyZ', 0h
Msg5 DB ' Text Interpreter entered ', 0h
Msg6 DB ' ok', 13, 10, 0h
Msg7 DB ' wait key -- ', 0h
Msg8 DB ' Exiting', 13, 10, 0h
Msg9 DB ' Fig Forth Begining', 0h
Msg10 DB ' ERROR OCCURED - ', 0h
Msg11 DB ' NOT FOUND', 13, 10, 0h
MsgQ DB ' ? ', 0H
Mempty DB ' empty ', 0h
; -----------------------------
crlf$ DB 13, 10, 0h
SPACE$ DB 20H,0H
HEX_TABLE DB "0123456789abcdef"
;
; DONE ASSEMBLING COLON DEFINITIONS
; DD Inter1   ; THE TEXT INTERPRETER
;
.code
;
Forth_Thread:
 DD do_COLD
 DD do_WORD
 DD do_FIND
 DD do_COMPILE
 DD Forth_Thread
 BOOT3: 
 DB 256 dup (0H) ; EMPTY BUFFER SPACE 
; ---------------------------------------------------------------------------
;
    start:
      	invoke Main
;
 ; -------------------------------
 ; Boot Sector
 ; -------------------------------
 CALL DEFCOUNT
 LEA EDI, Forth_Thread      ; Load DI with Forth_Thread
 NEXTC
;
; #########################################################################
;
Main proc
  ; -------------------------------
  ; console mode library procedures
  ; -------------------------------
invoke StdOut, ADDR Msg9
;
ret
;
Main endp
;
DEFCOUNT proc
  ; -----------------------------------------
  ; Count number of definitions in vocabulary
  ; -----------------------------------------
mov FCOUNTER, 0
PUSH [LATEST]
BOOT1:
INC FCOUNTER
POP EBX
MOV EAX, [EBX] ; LINK ADDRESS
CMP EAX, 0
JZ BOOT2
MOV EBX, [EBX] ; RECOVER ADDRESS
PUSH EBX
JMP BOOT1
BOOT2:
PUSH FCOUNTER
POP VOCCOUNT
ret
DEFCOUNT endp
;
; __________________________________
;  USER VARIABLES DEFINED (SYSTEM)
; __________________________________
ENDOFLINE:
DD 0000 
DD do_ENDOFLINE
DB  9, 'ENDOFLINE'
do_ENDOFLINE:
NEXTC
;
_PAD:
DD ENDOFLINE
DD do_PAD
DB 3, 'PAD'
do_PAD:
LEA EAX, PAD
PUSH EAX 
NEXTC
;
_HLD:
DD _PAD
DD do_HLD
DB 3, 'HLD'
do_HLD:
LEA EAX, HLD
PUSH EAX 
NEXTC
;
_STATE:
DD _HLD
DD do_STATE
DB 5, 'STATE'
do_STATE:
LEA EAX, STATE
PUSH EAX 
NEXTC
;
_BL:
DD _STATE
DD do_BL
DB 2, 'BL'
do_BL:
push 20h
NEXTC
;
_BASE:
DD _BL
DD do_BASE
DB 4, 'BASE'
do_BASE:
LEA EAX, BASE
PUSH EAX ; $-4
NEXTC
;
venum: ; negate value flag
DD _BASE
DD do_venum
DB 5, 'VENUM?'
do_venum:
LEA EAX, VENUMQ
PUSH EAX
NEXTC
;
Gone:
DD venum
DD do_Gone
DB 4, 'GONE'
do_Gone:
LEA EAX, gone
PUSH EAX
NEXTC
;
TESTV:
DD Gone
DD do_TESTV
DB 5, 'TESTV'
do_TESTV:
LEA EAX, testv
PUSH EAX
NEXTC
;
_POC:
DD TESTV
DD do_POC
DB 3, 'POC' 
do_POC:
LEA EAX, POC
PUSH EAX
NEXTC
;
_DPR:
DD _POC
DD do_DPR
DB 3, 'DPR'
do_DPR:
LEA EAX, DPR
PUSH EAX 
NEXTC
;
_FINDFLAG:
DD _DPR
DD do_FFLAG
DB 5, 'FFLAG'
do_FFLAG:
LEA EAX, FFLAG
PUSH EAX 
NEXTC
;
_LFA:
DD _FINDFLAG
DD do_LFA
DB 3, 'LFA'
do_LFA:
LEA EAX, LFA
PUSH EAX 
NEXTC
;
_NFA:
DD _LFA
DD do_NFA
DB 3, 'NFA'
do_NFA:
LEA EAX, NFA
PUSH EAX 
NEXTC
;
_CFA:
DD _NFA
DD do_CFA
DB 3, 'CFA'
do_CFA:
LEA EAX, CFA
PUSH EAX 
NEXTC
;
_BYE:
DD _CFA
DD do_BYE
DB 3, 'BYE'
do_BYE:
LEA EAX, BYEFLAG
PUSH EAX 
NEXTC
;
__IN:
DD _BYE
DD do_IN
DB 3, '_IN'
do_IN:
LEA EAX, _IN
PUSH EAX 
NEXTC
;
_S_LEN:
DD __IN
DD do_S_LEN
DB 5, 'S_LEN'
do_S_LEN:
LEA EAX, S_LEN
PUSH EAX 
NEXTC
;
_S_MAX:
DD _S_LEN
DD do_SMAX
DB 5, 'SMAX'
do_SMAX:
LEA EAX, SMAX
PUSH EAX 
NEXTC
;
; ________________________________________________________________
;                       Dictionary Begins
; -------------------- PRIMITIVES CORE CODE --------------------
;
_NULL:
DD _S_MAX
DD do_NULL
DB 1, 0
do_NULL:
NEXTC
;
_COLD:
DD _NULL 
DD do_COLD
DB  4, 'COLD'
do_COLD:
PUSH ESP
POP S0 ; Saving Stack Pointer Base 
MOV EBP, [RSP] ; RETURN STACK POINTER
LEA EAX, USER_BASE
PUSH EAX
POP DPR
PUSH 0 ;  simply here to clear last stack entry
POP EAX
MOV STATE, EAX
; Boot parameters
MOV S_LEN, EOCD - SOCD     ; lENGTH OF THE BOOT COLON DEFS
PUSH SOCD                  ; START OF COLON DEF AREA
PUSH 32                    ; SPACE DELIMITER
;
    invoke ClearScreen
    invoke locate,xpos,ypos
    invoke StdOut,ADDR Msg1 
    invoke StdOut,ADDR crlf$
    invoke StdOut,ADDR Msg1A 
    invoke StdOut,ADDR crlf$
    invoke StdOut,ADDR Msg2
NEXTC
;
_QUIT:
DD _COLD 
DD do_QUIT
DB  4, 'QUIT'
do_QUIT:
invoke StdOut,ADDR Msg6  
NEXTC
;
_COLON:
DD _QUIT       ; Link File Addess (LFA) No previous words  Pointer to previous words
DD do_COLON     ; CFA - Code Field Address
DB 1, ':'       ; NFA - NAME FIELD
do_COLON:
POP EAX
MOV [EBP-4], EDI
SUB EBP, 4
mov edi, eax
mov eax, [edi]
add edi, 4
JMP EAX 
;
_SEMI:
DD _COLON
DD do_SEMI
DB 1, ';'
do_SEMI:
MOV EDI, [EBP]
ADD EBP, 4
NEXTC
;
_PUSH1:      ; PUSH 1 onto data stack
DD _SEMI
DD do_PUSH1
DB 1, '1'    ; Name of Definition counted string name
do_PUSH1: 
PUSH 01H
NEXTC        ; End of definition
;
_RS:  ; Restore Stack pointer to base (  --  )
DD _PUSH1
DD do_RS
DB 2, '..'
do_RS:
MOV ESP , S0
NEXTC
;
_PUSH0: ; PUSH 0 onto stack
DD _RS
DD do_PUSH0
DB 1, '0'
do_PUSH0:
PUSH 0H
NEXTC
;
SPACE: 
DD _PUSH0
DD do_SPACE
DB 2,'BL'
do_SPACE:
PUSH 32
NEXTC
;
_LATEST: ; Returns address of the variable LATEST
DD SPACE
DD do_LATEST
DB 6,'LATEST'
do_LATEST:
LEA EAX, LATEST
PUSH EAX
NEXTC
;
_LAST: ; Returns header addr of Last Word in Dict
DD _LATEST
DD do_LAST
DB 4,'LAST'
do_LAST:
MOV EAX, DWORD PTR [LATEST]
PUSH EAX
NEXTC
;
_COMPILE: ; ( -- )    compile xt following
DD _LATEST
DD do_COMPILE
DB 7,'COMPILE'
do_COMPILE:
mov  ebx, [edi] ; ip  equ  <edi>  Instruction Pointer for Forth
add  edi, 4
PUSH EBX
PUSH DPR
POP EAX
MOV [EAX], EBX
ADD DPR, 4
NEXTC
;
;   -------------------- Memory Operators -------------------------------------
;
FETCH:  ; ( a1 -- n1 )     ;    get the cell n1 from address a1
DD _COMPILE 
DD do_FETCH
DB 1, "@"
do_FETCH: 
    POP EBX 
    mov ebx, 0 [ebx]
    push ebx
    NEXTC
 ; 
h_STORE:  ; ( n1 a1 -- )     ;    store cell n1 into address a1
DD FETCH     
DD do_STORE
DB 1, "!"
do_STORE: 
    POP EAX 
    POP EBX
    MOV [EAX], EBX
    NEXTC
 ; 
h_PLUSSTORE:      ; ( n1 a1 -- )     ;    add cell n1 to the contents of address a1
DD h_STORE  
DD do_PLUSSTORE
DB 2, "+!"
do_PLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], eax
    pop ebx
    NEXTC
 ; 
CFETCH:      ; ( a1 -- c1 )     ;    fetch the character c1 from address a1
DD h_PLUSSTORE 
DD do_CFETCH
DB 2, "C@"
do_CFETCH: 
    POP EBX 
    movzx ebx, byte ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
CSTORE:      ; ( c1 a1 -- )     ;    store character c1 into address a1
DD CFETCH 
DD do_CSTORE
DB 2, "C!"
do_CSTORE: 
    POP EBX 
    pop eax
    mov 0 [ebx], al
    pop ebx
    NEXTC
 ; 
CPLUSSTORE:    ; ( c1 a1 -- )     ;    add character c1 to the contents of address a1
DD CSTORE  
DD do_CPLUSSTORE
DB 3, "C+!"
do_CPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], al
    pop ebx
    NEXTC
 ; 
WFETCH:      ; ( a1 -- w1 )     ;    fetch the word ; (16bit) w1 from address a1
DD CPLUSSTORE
DD do_WFETCH
DB 2, "W@"
do_WFETCH: 
    POP EBX 
    movzx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
SWFETCH:     ; ( a1 -- w1 )     ;    fetch and sign extend the word ; 
DD WFETCH 
DD do_SWFETCH
DB 3, "SW@"
do_SWFETCH: 
    POP EBX 
    movsx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
WSTORE:      ; ( w1 a1 -- )     ;    store word ; (16bit) w1 into address a1
DD SWFETCH 
DD do_WSTORE
DB 2, "W!"
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
DB 3, "W+!"
do_WPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], ax
    pop ebx
    NEXTC
; 
MEMQ:
DD WPLUSSTORE
DD do_MEMQ
DB 4, 'MEM?'
do_MEMQ:
MOV EAX, MEMLIMIT
SUB EAX, DPR
PUSH EAX
NEXTC
;
;    -------------------- Char Operators ---------------------------------------

h_CHARS:  ; ( n1 -- n1*char )  ;    multiply n1 by the character size ; (1)
DD MEMQ
DD do_CHARS
DB 5, "CHARS"
do_CHARS: 
    NEXTC
 ; 
CHARPLUS:  ; ( a1 -- a1+char )  ;    add the characters size in bytes to a1
DD h_CHARS 
DD do_CHARPLUS
DB 5, "CHAR+"
do_CHARPLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
; 
;    -------------------- Arithmetic Operators ---------------------------------
;
_PLUS:   ; ( n1 n2 -- n3 )  ;    add n1 to n2, return sum n3
DD CHARPLUS     
DD 0000 ; DD do_PLUS
DB 1, "+"
do_PLUS: 
    POP EBX   ; n2
    pop eax   ; n1
    add eax, ebx   ; N1 + N2
    PUSH EAX
    NEXTC
 ; 
MINUS:   ; ( n1 n2 -- n3 )  ;    subtract n2 from n1, return difference n3
DD _PLUS 
DD do_MINUS
DB 1, "-"
do_MINUS: 
    POP EBX ; n2
    pop eax ; n1
    sub eax, ebx ; n1 - n2
    push eax
    NEXTC
 ; 
UNDERPLUS:   ; ( a x b -- a+b x )  ;    add top of stack to third stack item
DD MINUS 
DD do_UNDERPLUS
DB 6, "UNDER+"
do_UNDERPLUS: 
    POP EBX 
    add 4 [esp], ebx
    NEXTC
 ; 
_NEGATE:   ; ( n1 -- n2 )  ;    negate n1, returning 2's complement n2
DD UNDERPLUS  
DD do_NEGATE
DB 6, "NEGATE"
do_NEGATE: 
    POP EBX 
    neg ebx
    push ebx
    NEXTC
 ; 
_ABS:     ; ( n -- |n| )  ;    return the absolute value of n1 as n2
DD _NEGATE 
DD do_ABS
DB 3, "ABS"
do_ABS: 
    POP EBX 
    mov ecx, ebx  ;    save value
    sar ecx, 31  ;    x < 0 ? 0xffffffff : 0
    xor ebx, ecx  ;    x < 0 ? ~x : x
    sub ebx, ecx  ;    x < 0 ? ; (~x)+1 : x
    push ebx
    NEXTC
 ; 
_2TIMES:      ; ( n1 -- n2 )  ;    multiply n1 by two
DD _ABS 
DD do_2TIMES
DB 2, "2*"
do_2TIMES: 
    POP EBX 
    add ebx, ebx
    push ebx
    NEXTC
 ; 
_2DIVIDE:      ; ( n1 -- n2 )  ;    signed divide n1 by two
DD _2TIMES 
DD do_2DIVIDE
DB 2, "2/"
do_2DIVIDE: 
    POP EBX 
    sar ebx, 1
    push ebx
    NEXTC
 ; 
U2DIVIDE:     ; ( n1 -- n2 )  ;    unsigned divide n1 by two
DD _2DIVIDE 
DD do_U2DIVIDE
DB 3, "U2/"
do_U2DIVIDE: 
    POP EBX 
    shr ebx, 1
    PUSH EBX
    NEXTC
 ; 
_1PLUS:     ; ( n1 -- n2 )  ;    add one to n1
DD U2DIVIDE
DD do_1PLUS
DB 2, "1+"
do_1PLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
 ; 
_1MINUS:      ; ( n1 -- n2 )  ;    subtract one from n1
DD _1PLUS
DD do_1MINUS
DB 2, "1-"
do_1MINUS: 
    POP EBX 
    sub ebx, 1
    push ebx
    NEXTC
 ; 
D2TIMES:     ; ( d1 -- d2 )  ;    multiply the double number d1 by two
DD _1MINUS
DD do_D2TIMES
DB 3, "D2*"
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
DB 3, "D2/"
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
DB 6, "RROT32"
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
DB 6, "LROT32"
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
DB 7, "GETADDR"
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
LIT:  ; ( -- n )     ;    push the literal value following LIT in the
DD _GETADDR 
DD do_LIT
DB 3, "LIT"
do_LIT:              ;  PUSH onto the data stack
    mov ebx, [EDI]
    PUSH EBX
    ADD EDI , 4
    NEXTC
 ; 
DROP:  ; ( n -- )     ;    discard top entry on data stack
DD LIT  
DD do_DROP
DB 4, "DROP"
do_DROP: 
    POP EBX 
    NEXTC
 ; 
h_DUP:     ; ( n -- n n )     ;    duplicate top entry on data stack
DD DROP  
DD do_DUP
DB 3, "DUP"
do_DUP: 
    MOV EBX , 0 [ESP] 
    push ebx
    NEXTC
 ; 
SWAP:  ; ( n1 n2 -- n2 n1 )  ;    exchange first and second items on data stack
DD h_DUP  
DD do_SWAP
DB 4, "SWAP"
do_SWAP: 
    POP EBX 
    mov eax, [esp]
    mov [esp], ebx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
OVER:  ; ( n1 n2 -- n1 n2 n1 )  ;    copy second item to top of data stack
DD SWAP
DD do_OVER
DB 4, "OVER"
do_OVER: 
    mov ebx, 4 [esp]
    PUSH EBX
    NEXTC
 ; 
ROT:     ; ( n1 n2 n3 -- n2 n3 n1 )  ;    rotate third item to top of data stack
DD OVER 
DD do_ROT
DB 3, "ROT"
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
MINUSROT:  ; ( n1 n2 n3 -- n3 n1 n2 )  ;    rotate top of data stack to third item
DD ROT   
DD do_MINUSROT
DB 4, "-ROT"
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
IFDUP:  ; ( n -- n [n] )  ;    duplicate top of data stack if non-zero
DD MINUSROT
DD do_IFDUP
DB 4, "?DUP"
do_IFDUP: 
    POP EBX 
    test    ebx, ebx
    je short @@1A
    push    ebx
@@1A:
    NEXTC
 ; 
NIP:     ; ( n1 n2 -- n2 )  ;    discard second item on data stack
DD IFDUP 
DD do_NIP
DB 3, "NIP"
do_NIP: 
    POP EBX 
    POP EAX
    PUSH EBX
    NEXTC
 ; 
TUCK:  ; ( n1 n2 -- n2 n1 n2 )  ;    copy top data stack to under second item
DD NIP       ; SWAP OVER
DD do_TUCK
DB 4, "TUCK"
do_TUCK: 
    POP EBX
    PUSH 0 [ESP]
    MOV 4 [ESP], EBX
    PUSH EBX
    NEXTC
 ; 
h_PICK:  ; ( ... k -- ... n[k] )
DD TUCK 
DD do_PICK
DB 4, "PICK"
do_PICK: 
    POP EBX 
    mov ebx, 0 [esp] [ebx*4]  ;    just like that!
    PUSH EBX
    NEXTC
; 
;   -------------------- Double Arithmetic Operators --------------------------
StoD:       ; ( n1 -- d1 )   convert single signed single n1 to a signed double d1
DD h_PICK 
DD do_StoD
DB 3, 'S>D'
do_StoD:
    pop ebx
    push    ebx
    shl     ebx, 1         ;   put sign bit into carry
    sbb     ebx, ebx
    push ebx
    NEXTC
;
;    -------------------- Cell Operators ---------------------------------------

_CELL:  ; ( -- 4 )  ;    cell size
DD StoD  
DD do_CELL
DB 4, "CELL"
do_CELL: 
    PUSH 4
    NEXTC
 ; 
_CELLS:  ; ( n1 -- n1*cell )  ;    multiply n1 by the cell size
DD _CELL 
DD do_CELLS
DB 5, "CELLS"
do_CELLS: 
    POP EBX 
    shl ebx, 2
    NEXTC
 ; 
CELLSPLUS:  ; ( a1 n1 -- a1+n1*cell )  ;    multiply n1 by the cell size and add
DD _CELLS  
DD do_CELLSPLUS
DB 6, "CELLS+"
do_CELLSPLUS: 
    POP EBX 
     ;    the result to address a1
    pop eax
    lea ebx, 0 [ebx*4] [eax]
    NEXTC
 ; 
CELLSMINUS:  ; ( a1 n1 -- a1-n1*cell )  ;    multiply n1 by the cell size and subtract
DD CELLSPLUS 
DD do_CELLSMINUS
DB 6, "CELLS-"
do_CELLSMINUS: 
    POP EBX 
     ;    the result from address a1
    lea eax, 0 [ebx*4]
    pop ebx
    sub ebx, eax
    NEXTC
 ; 
CELLPLUS:  ; ( a1 -- a1+cell )  ;    add a cell to a1
DD CELLSMINUS  
DD do_CELLPLUS
DB 5, "CELL+"
do_CELLPLUS: 
    POP EBX 
    add ebx, 4
    PUSH EBX
    NEXTC
 ; 
CELLMINUS:  ; ( a1 -- a1-cell )  ;    subtract a cell from a1
DD CELLPLUS 
DD do_CELLMINUS
DB 5, "CELL-"
do_CELLMINUS: 
    POP EBX 
    sub ebx, 4
    NEXTC
 ; 
PLUSCELLS:  ; ( n1 a1 -- n1*cell+a1 )  ;    multiply n1 by the cell size and add
DD CELLMINUS  
DD do_PLUSCELLS
DB 6, "+CELLS"
do_PLUSCELLS: 
    POP EBX 
     ;    the result to address a1
    pop eax
    lea ebx, 0 [eax*4] [ebx]
    NEXTC
 ; 
MINUSCELLS:  ; ( n1 a1 -- a1-n1*cell )  ;    multiply n1 by the cell size and
DD PLUSCELLS  
DD do_MINUSCELLS
DB 6, "-CELLS"
do_MINUSCELLS: 
    POP EBX 
     ;    subtract the result from address a1
    pop eax
    shl eax, 2
    sub ebx, eax
    NEXTC
; 
;    -------------------- Stack Operations -------------------------------------
;
_DEPTH: ;      ( -- n ) \ return the current data stack depth (n excluded)
DD MINUSCELLS
DD do_DEPTH
DB 5, 'DEPTH'
do_DEPTH:
    mov     ebx, S0 
    sub     ebx, esp
    sar     ebx, 2  ; shift right two is divide by 4
    PUSH EBX
    NEXTC
;
SPFETCH:     ; ( -- addr )  ;    get addr, the pointer to the top item on data stack
DD _DEPTH    
DD do_SPFETCH
DB 3, "SP@"
do_SPFETCH: 
    mov ebx, esp
    PUSH EBX
    NEXTC
 ; 
SPSTORE:     ; ( addr -- )  ;    set the data stack to point to addr
DD SPFETCH  
DD do_SPSTORE
DB 3, "SP!"
do_SPSTORE: 
    POP EBX 
    mov esp, ebx
    NEXTC
 ; 
RPFETCH:     ; ( -- a1 )  ;    get a1 the address of the return stack
DD SPSTORE     
DD do_RPFETCH
DB 3, "RP@"
do_RPFETCH: 
    mov ebx, RSP
    PUSH EBX
    NEXTC
 ; 
RPSTORE:     ; ( a1 -- )  ;    set the address of the return stack
DD RPFETCH 
DD do_RPSTORE
DB 3, "RP!"
do_RPSTORE: 
    POP EBX 
    mov RSP, ebx
    NEXTC
 ; 
TOR:      ; ( n1 -- ) ; ( R: -- n1 )  ;    push n1 onto the return stack
DD RPSTORE  
DD do_TOR
DB 2, ">R"
do_TOR: 
POP EAX
SUB RSP, 4
MOV [RSP], EAX
NEXTC
 ; 
RFROM:      ; ( -- n1 ) ; ( R: n1 -- )  ;    pop n1 off the return stack
DD TOR      
DD do_RFROM
DB 2, "R>"
do_RFROM: 
MOV EAX , [RSP] 
PUSH EAX
ADD RSP, 4
    NEXTC
 ; 
RFETCH:      ; ( -- n1 ) ; ( R: n1 -- n1 )  ;    get a copy of the top of the return stack
DD RFROM
DD do_RFETCH
DB 2, "R@"
do_RFETCH: 
MOV EAX , DWORD PTR [RSP]
PUSH EAX
    NEXTC
 ; 
DUPTOR:  ; ( n1 -- n1 ) ; ( R: -- n1 )  ;    push a copy of n1 onto the return stack
DD RFETCH 
DD do_DUPTOR
DB 5, "DUP>R"
do_DUPTOR: 
    mov ebx, [ESP]
    SUB RSP, 4
    mov [RSP], ebx
    NEXTC
 ; 
RFROMDROP:  ; ( -- ) ; ( R: n1 -- )  ;    discard one item off of the return stack
DD DUPTOR     
DD do_RFROMDROP
DB 6, "R>DROP"
do_RFROMDROP: 
    ADD RSP, 4
    NEXTC
 ; 
_2TOR:     ; ( n1 n2 -- ) ; ( R: -- n1 n2 )  ;    push two items onto the returnstack
DD RFROMDROP 
DD do_2TOR
DB 3, "2>R"
do_2TOR: 
    POP EBX
    SUB RSP, 4
    PUSH RSP
    POP EAX
    MOV [EAX], EBX
    POP EBX
    SUB RSP, 4
    PUSH RSP
    POP EAX
    MOV [EAX], EBX
    NEXTC
 ; 
_2RFROM:    ; ( -- n1 n2 ) ; ( R: n1 n2 -- )  ;    pop two items off the return stack
DD _2TOR  
DD do_2RFROM
DB 3, "2R>"
do_2RFROM: 
    ADD RSP, 4
    PUSH RSP
    POP EAX
    MOV EBX , [EAX]
    PUSH EBX
    SUB RSP, 4
    PUSH RSP
    POP EAX
    MOV EBX ,[EAX]
    PUSH EBX
    ADD RSP, 8
    NEXTC
 ; 
_2RFETCH:     ; ( -- n1 n2 )     ;    get a copy of the top two items on the return stack
DD _2RFROM  
DD do_2RFETCH
DB 3, "2R@"
do_2RFETCH: 
    MOV EBX , [RSP-4]
    PUSH EBX
    MOV EBX ,[RSP]
    PUSH EBX
    NEXTC
 ; 
_2DUP:     ; ( N1 N2 -- N1 N2 n1 n2 )     ;    DUPLICATE TOP 2 ITEMS ON STACK
DD _2RFETCH  
DD do_2DUP
DB 4, "2DUP"
do_2DUP: 
    MOV EBX , 4 [ESP]
    MOV EAX , 0 [ESP]
    PUSH EBX
    PUSH EAX
    NEXTC
 ; 
_2DROP:     ; ( n1 n2 -- )     ;    DROP TOP 2 ITEMS ON STACK
DD _2DUP 
DD do_2DROP
DB 5, "2DROP"
do_2DROP: 
    ADD ESP, 8
    NEXTC
;
;   -------------------- Comparison Operators ---------------------------------

EQU0:          ; ( n1 -- f1 )      return true if n1 equals zero
DD _2DROP
DD do_EQU0
DB 2, "0="
do_EQU0:
    POP EBX
    sub     ebx,  1
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_0NE:         ; v( n1 -- f1 )      return true if n1 is not equal to zero
DD EQU0
DD do_0NE
DB 3, "0<>"
do_0NE:
    POP EBX
    sub     ebx, 1
    sbb     ebx, ebx
    not     ebx
	push ebx
    NEXTC
 ;
_0LT:         ; ( n1 -- f1 )      return true if n1 is less than zero
DD _0NE
DD do_0LT
DB 2, "0<"
do_0LT:
    POP EBX
    sar ebx,  31
	push ebx
    NEXTC
 ;
_0GT:          ; ( n1 -- f1 )      return true if n1 is greater than zero
DD _0LT
DD do_0GT
DB 2, "0>"
do_0GT:
    POP EBX
    dec     ebx
    cmp     ebx, 7fffffffh
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_EQU:          ; ( n1 n2 -- f1 )   return true if n1 is equal to n2
DD _0GT
DD do_EQU
DB 1, "="
do_EQU:
    POP EBX
    pop     eax
    sub     ebx, eax
    sub     ebx, 1
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_NEQ:         ; ( n1 n2 -- f1 )   return true if n1 is not equal to n2
DD _EQU
DD do_NEQ
DB 2, "<>"
do_NEQ:
    POP EBX
    pop     eax
    sub     eax, ebx
    neg     eax
    sbb     ebx, ebx
	push ebx
    NEXTC
 ;
_LT:          ; ( n1 n2 -- f1 )   return true if n1 is less than n2
DD _NEQ
DD do_LT
DB 1, "<"
do_LT:
    POP EBX
    pop eax
    cmp eax, ebx
    jl short @@1
    xor ebx, ebx
	push ebx
    NEXTC
@@1:       
    mov ebx, -1
	push ebx
    NEXTC
 ;
_GT:          ; ( n1 n2 -- f1 )   return true if n1 is greater than n2
DD _LT
DD do_GT
DB 1, ">"
do_GT:
    POP EBX
    pop eax
    cmp eax, ebx
    jg  short @@1
    xor ebx, ebx
	push ebx
    NEXTC
 ;
_LTE:         ; ( n1 n2 -- f1 )   return true if n1 is less than n2
DD _GT
DD do_LTE
DB 2, "<="
do_LTE:
    POP EBX
    pop eax
    cmp eax, ebx
    jle short @@1
    xor ebx, ebx
	push ebx
    NEXTC
;
_GTE:        ;  ( n1 n2 -- f1 )   return true if n1 is greater than n2
DD _LTE
DD do_GTE
DB 2, ">="
do_GTE:
    POP EBX
    pop eax
    cmp eax, ebx
    jge short @@1
    xor ebx, ebx
	push ebx
    NEXTC
 ;
ULT:        ;  ( u1 u2 -- f1 )   return true if unsigned u1 is less than
DD _GTE
DD do_ULT
DB 2, "U<"
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
DB 2, "U>"
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
DB 3, "DU<"
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
DB 4, "UMIN"
do_UMIN:
    POP EBX ;  unsigned u2
    pop     eax
    cmp     ebx, eax
    jb      @@1
    mov     ebx, eax
	push ebx
    NEXTC
 ;
_MIN:        ; ( n1 n2 -- n3 )   return the lesser of n1 and n2
DD UMIN
DD do_MIN
DB 3, "MIN"
do_MIN:
    POP     EBX
    pop     eax
    cmp     ebx, eax
    jl      @@1
    mov     ebx, eax
	push    ebx
    NEXTC
 ;
_UMAX:       ; ( u1 u2 -- n3 )   return the greater of unsigned u1 and
DD _MIN
DD do_UMAX
DB 4, "UMAX"
do_UMAX:
    POP EBX ;  unsigned u2
     pop     eax
     cmp     ebx, eax
     ja      @@1
     mov     ebx, eax
	 push ebx
    NEXTC
 ;
_MAX:       ;  ( n1 n2 -- n3 )   return the greater of n1 and n2
DD _UMAX
DD do_MAX
DB 3, "MAX"
do_MAX:
    POP EBX
    pop     eax
    cmp     ebx, eax
    jg      @@1
    mov     ebx, eax
	push ebx
    NEXTC
 ;
_0MAX:       ; ( n1 -- n2 )   return n2 the greater of n1 and zero
DD _MAX
DD do_0MAX
DB 4, "0MAX"
do_0MAX:
    POP EBX
    cmp     ebx, 0
    jg      @@1
    xor     ebx, ebx
	push ebx
    NEXTC
 ;
_WITHIN:     ; ( n1 low high -- f1 )   f1=true if ( (n1 >= low) and (n1 < high) )
DD _0MAX
DD do_WITHIN
DB 6, "WITHIN"
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
_BETWEEN:     ; ( n1 low high -- f1 )   f1=true if ( (n1 >= low) and (n1 <= high) )
DD _WITHIN
DD do_BETWEEN
DB 7, "BETWEEN"
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
DB 2, "2@"
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
DB 2, "2!"
do_2STORE:
    POP EBX
    pop     0 [ebx]
    pop     4 [ebx]
    pop     ebx
    NEXTC
;

;   -------------------- Double Stack Operators -------------------------------

_2NIP:       ;  ( n1 n2 n3 n4 -- n3 n4 )   discard third and fourth items from data stack
DD _2STORE
DD do_2NIP
DB 4, "2NIP"
do_2NIP:
    POP EBX
    pop     eax
    mov     4 [esp], eax
    pop     eax
	push ebx
    NEXTC
 ;
_2SWAP:      ; ( n1 n2 n3 n4 -- n3 n4 n1 n2 )   exchange the two topmost doubles
DD _2NIP
DD do_2SWAP
DB 5, "2SWAP"
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
_2OVER:      ; ( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2 )   copy second double on top
DD _2SWAP
DD do_2OVER
DB 5, "2OVER"
do_2OVER:
    POP EBX
                mov     eax, 8 [esp]
                push    ebx
                push    eax
                mov     ebx, 12 [esp]
		push ebx
    NEXTC
 ;
_2ROT:       ; ( n1 n2 n3 n4 n5 n6 -- n3 n4 n5 n6 n1 n2 )     rotate 3 double
DD _2OVER
DD do_2ROT
DB 4, "2ROT"
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
_3DROP:      ; ( n1 n2 n3 -- )   discard three items from the data stack
DD _2ROT
DD do_3DROP
DB 5, "3DROP"
do_3DROP:
    POP EBX
                add     esp, 8
                pop     ebx
    NEXTC
 ;
_4DROP:      ; ( n1 n2 n3 n4 -- )   discard four items from the data stack
DD _3DROP
DD do_4DROP
DB 5, "4DROP"
do_4DROP:
    POP EBX
                add     esp, 12
                pop     ebx
    NEXTC
 ;
_3DUP:       ; ( n1 n2 n3 -- n1 n2 n3 n1 n2 n3 )   duplicate 3 topmost cells
DD _4DROP
DD do_3DUP
DB 4, "3DUP"
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
_4DUP:       ; ( a b c d -- a b c d a b c d )   duplicate 4 topmost cells
DD _3DUP
DD do_4DUP
DB 4, "4DUP"
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
;   ------------------------ String counting -----------------------

COUNT:      ; ( str -- addr len )   byte counted strings
DD _4DUP
DD do_COUNT
DB 5, "COUNT"
do_COUNT:
   MOV     EBX, [ESP]
   movzx   ebx, byte ptr  [ebx-1]
   push    ebx
   NEXTC
 ;
WCOUNT:    ;  ( str -- addr len )    word (2 bytes) counted strings
DD COUNT
DD do_WCOUNT
DB 6, "WCOUNT"
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
DB 6, "LCOUNT"
do_LCOUNT:
    POP EBX
    add  ebx, 4
    push ebx
    mov  ebx,  [ebx-4]
	push ebx
    NEXTC
 ;
ZCOUNT:     ; ( str -- addr len )    null terminated string, whose 1rst char is at addr
DD LCOUNT
DD do_ZCOUNT
DB 6, "ZCOUNT"
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
STRINGADJ:    ;( c-addr1 u1 n -- c-addr2 u2 ) \ ANSI   String
;\ *G Adjust the character string at c-addr1 by n characters. The resulting character
;\ ** string, specified by c-addr2 u2, begins at c-addr1 plus n characters and is u1
;\ ** minus n characters long. \n
;\ ** If n1 greater than len1, then returned len2 will be zero. \n
;\ ** For early (pre Nov 2000) versions of W32F, if n1 less than zero,
;\ ** then returned length u2 was zero.
;\ *P /STRING is used to remove or add characters relative to the left end of the
;\ ** character string. Positive values of n will exclude characters from the string
;\ ** while negative values of n will include characters to the left of the string.
DD ZCOUNT
DD do_STRINGADJ
DB 9, 'STRINGADJ'
do_STRINGADJ:
       POP     EBX
       pop     eax
       test    ebx, ebx       
       jle     short @@1G      
       cmp     ebx, eax       
       jbe     short @@1G     
       mov     ebx, eax
@@1G:  add     0 [esp], ebx
       sub     eax, ebx
       mov     ebx, eax
       PUSH    EBX
       NEXTC
;
ADDNULL:     ; ( c-addr -- )  Append a NULL to the counted string.
DD STRINGADJ
DD do_ADDNULL
DB 5, '+NULL'
do_ADDNULL:
   POP     EBX
   mov     CL, BYTE PTR [ebx-1]         ; length
   AND     ECX, 00FFH
   ADD     EBX, ECX
   mov     BYTE PTR [EBX], 0                 ; zero the char
   NEXTC
;
;    -------------------- Logical Operators ------------------------------------

_AND:     ; ( n1 n2 -- n3 )  ;    perform bitwise AND of n1,n2, return result n3
DD ADDNULL
DD do_AND
DB 3, "AND"
do_AND:
    POP EBX
    pop ecx
    and ebx, ecx
    push ebx
    NEXTC
 ;
_OR:      ; ( n1 n2 -- n3 )  ;    perform bitwise OR of n1,n2, return result n3
DD _AND
DD do_OR
DB 2, "OR"
do_OR:
    POP EBX
    pop ecx
    or ebx, ecx
    push ebx
    NEXTC
 ;
_XOR:     ; ( n1 n2 -- n3 )  ;    perform bitwise XOR of n1,n2, return result n3
DD _OR
DD do_XOR
DB 3, "XOR"
do_XOR:
    POP EBX
    pop ecx
    xor ebx, ecx
    push ebx
    NEXTC
 ;
_INVERT:  ; ( n1 -- n2 )     ;    perform a bitwise -1 XOR on n1, return result n2
DD _XOR
DD do_INVERT
DB 6, "INVERT"
do_INVERT:
    POP EBX
    not ebx
    push ebx
    NEXTC
 ;
_LSHIFT:  ; ( u1 n -- u2 )  ;    shift u1 left by n bits ; (multiply)
DD _INVERT
DD do_LSHIFT
DB 6, "LSHIFT"
do_LSHIFT:
    POP EBX
    mov ecx, ebx
    pop ebx
    shl ebx, cl
    push ebx
    NEXTC
 ;
_RSHIFT:  ; ( u1 n -- u2 )  ;    shift u1 right by n bits ; (divide)
DD _LSHIFT
DD do_RSHIFT
DB 6, "RSHIFT"
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
DD do_INCR
DB 4, "INCR"
do_INCR:
    POP EBX
    add dword ptr 0 [ebx],  1
    pop ebx
    NEXTC
 ;
_DECR:  ; ( addr -- )  ;    decrement the contents of addr
DD _INCR
DD do_DECR
DB 4, "DECR"
do_DECR:
    POP EBX
    sub dword ptr 0 [ebx],  1
    pop ebx
    NEXTC
 ;
CINCR:  ; ( addr -- )  ;    increment the BYTE contents of addr
DD _DECR
DD do_CINCR
DB 5, "CINCR"
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
DB 5, "CDECR"
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
DB 2, "ON"
do_ON:
    POP EBX
    mov dword ptr 0 [ebx], -1
    pop ebx
    NEXTC
 ;
_OFF:     ; ( addr -- )  ;    set the contents of addr of OFF ; (0)
DD _ON
DD do_OFF
DB 3, "OFF"
do_OFF:
    POP EBX
    mov dword ptr 0 [ebx],  0
    pop ebx
    NEXTC
;
;    -------------------- Other Operators ------------------------------------
;
DOCOL:   ; ( -- )        runtime for colon definitions
DD _OFF
DD do_DOCOL
DB 7, "DOCOLON"
do_DOCOL:  
    mov     [ebp-4], esi   ;   rpush return addr
    lea     esi, 8 [eax]
    mov     eax, 4 [eax]
    sub     ebp,  4
    JMP EAX ;
;
DODOES:  ;( -- a1 )   ;  runtime for DOES>
DD DOCOL 
DD do_DODOES
DB 6, "DODOES"
do_DODOES: 
    mov     [ebp-4], esi   ;  rpush esi
    mov     esi, ecx        ;  new esi
    lea     ebx, 4 [eax]
    mov     eax, [esi-4]
    sub     ebp,  4
    JMP EAX
;
DOVAR:   ;( -- a1 )   ;  runtime for CREATE and VARIABLE
DD DODOES  
DD do_DOVAR
DB 5, "DOVAR"
do_DOVAR: 
    lea  ebx, 4 [eax]
    push ebx
    NEXTC
; 
DOUSER:  ;( -- a1 )   ;  runtime for USER variables
DD DOVAR  
DD do_DOUSER
DB 6, "DOUSER"
do_DOUSER: 
    mov     ebx, 4 [eax] ;  get offset
    add     ebx, edx     ;  add absolute user base
    PUSH EBX
    NEXTC
; 
DOCON:   ;( -- n1 )   ;  runtime for constants
DD DOUSER  
DD do_DOCON
DB 5, "DOCON"
do_DOCON: 
    mov     ebx, 4 [eax]
    PUSH EBX
    NEXTC
; 
DODEFER:  ;( -- )     ;  runtime for DEFER
DD DOCON 
DD do_DODEFER
DB 7, "DODEFER"
do_DODEFER: 
    mov     eax, 4 [eax]
    JMP EAX

DOVALUE:  ;( -- n1 )  ;  runtime for VALUE fetch
DD DODEFER  
DD do_DOVALUE
DB 7, "DOVALUE"
do_DOVALUE: 
    mov     ebx, 4 [eax]
    PUSH EBX
    NEXTC
 ; 
DOVALUESTORE:  ;( n1 -- )   ;  runtime for VALUE store
DD DOVALUE
DD do_DOVALUESTORE
DB 8, "DOVALUE!"
do_DOVALUESTORE: 
    POP EBX         ; RETRIEVE VALUE N1
    mov [eax], ebx  ; SAVE VALUE
    NEXTC
 ; 
DOVALPLUSTORE:  ;( n1 -- )   ;  runtime for VALUE increment
DD DOVALUESTORE  
DD do_DOVALPLUSTORE
DB 9, "DOVALUE+!"
do_DOVALPLUSTORE: 
    POP EBX 
    add     [eax-8], ebx
    pop     ebx
    NEXTC
 ; 
DO2VALUE:  ;( d1 -- )   ;  runtime for 2VALUE fetch
DD DOVALUESTORE 
DD do_DO2VALUE
DB 8, "DO2VALUE"
do_DO2VALUE: 
    POP EBX 
    push    ebx
    mov     ecx, 4 [eax]
    push    4 [ecx]
    mov     ebx, 0 [ecx]
    NEXTC
 ; 
DOOFF:      ;( n -- )    ;  run-time for OFFSET and FIELD+
DD DO2VALUE  
DD do_DOOFF
DB 5, "DOOFF"
do_DOOFF: 
    POP EBX 
    add ebx, 4 [eax]
    NEXTC
 ; 
SOURCE_:        ; ( -- addr len )     (SOURCE)                 2@ ;
DD DOOFF
DD do_SOURCE_
DB 6, 'SOURCE'
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
DB 8, '(HEADER)'
do__HEADER_:
   mov     ecx, CURRENT       ; get current vocab
;  mov     eax, VHEAD VOC#0 - [ecx] ; fetch header word to execute
   JMP     eax
;
;   -------------------- Block Memory Operators -------------------------------
;
 _CMOVE:          ; (  from to count -- )     move "count" bytes from address "from" to
 DD _HEADER_     ;  address "to" - start with the first byte of "from"
 DD do_CMOVE
 DB 5, 'CMOVE'
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
_FILL:      ;( addr len char -- )        ;  fill addr with char for len bytes
DD  _CMOVE
DD do_FILL
DB 4, 'FILL'
do_FILL:
                POP     EBX
                mov     bh, bl          ;  bh & bl = char
                shl     ebx,  16
                mov     eax, ebx
                shr     eax,  16
                or      eax, ebx
FILLJ:          mov     ebx, edi        ;  ebx = base
                pop     ecx             ;  ecx = len
                pop     edi             ;  edi = addr
                push    ecx             ;  optimize
                shr     ecx,  2
                rep     stosd
                pop     ecx
                and     ecx,  3
                rep     stosb
                mov     edi, ebx        ;  restore
                NEXTC                   ;  FILL
;
_ERASE:     ;( addr u -- )             ANSI        Core Ext
;  *G If u is greater than zero, clear all bits in each of u consecutive address
;  ** units of memory beginning at addr .
DD _FILL
DD do_ERASE
DB 5, 'ERASE'
do_ERASE:
                xor     eax, eax
                jmp     FILLJ
;
BLANK:     ;( c-addr u -- )           ANSI         String
;  *G If u is greater than zero, store the character value for space in u consecutive
;  ** character positions beginning at c-addr.
DD _ERASE
DD do_BLANK
DB 5, 'BLANK'
do_BLANK:
                mov     eax, 20202020h ;  all blanks
                jmp     FILLJ
;
; -------------------- Parse Input Stream --------------------
;
TOBODY:       ;( cfa -- pfa ) \ convert code field address to parameter field address
DD BLANK
DD do_TOBODY
DB 5, ">BODY"
do_TOBODY:
    POP EBX
    add ebx,  4
    PUSH EBX
    NEXTC
 ;
BODYOFF:      ;( pfa -- cfa ) \ convert parameter field address to code field address
DD TOBODY
DD do_BODYOFF
DB 5, "BODY>"
do_BODYOFF:
    POP EBX
    sub ebx,  4
    PUSH EBX
    NEXTC
;
_WORD:       ; ( char SADDR -- Caddr ) CADDR = COUNTED STRING
DD BODYOFF
DD do_WORD
DB 4, "WORD"
do_WORD: ; ( SADDR BL -- SADDR )
; parse the input stream for a string delimited by char. Skip all leading char. Give a
; counted string (the string is ended with a blank, not included in count).
; If char is a blank treat all control characters as delimiter.
; Use only inside colon definition.
    POP     EBX ; delimiter CHAR
    CMP     S_LEN, 1
    JG      @@W1
    NEXTC
@@W1:
    POP     EAX ; ADDRESS OF STRING
    PUSH    EDI
    push    esi     	
    MOV     EDI, EAX            ; edi = input pointer
    MOV     EAX, 0
    mov     al, bl              ; al = delimiter
    add     edi, _IN    		; add _IN
    mov     ecx, S_LEN          ; ecx = input length
    sub     ecx, _IN    		; subtract _IN
    ja      short @@9A
    xor     ecx, ecx   			; at end of input
    MOV     _IN, 0
    jmp     @@8A
@@9A:
    cmp     al,  32
    jne     short @@5A
                                ; Delimiter is a blank, treat all chars <= 32 as the delimiter
@@1B:
    cmp     [edi], al           ; leading delimiter?
    ja      short @@2B
    pop     esi
    POP     EDI
    PUSH    0
    NEXTC
    sub     ecx,  1
    jnz     short @@1B
    mov     esi, edi    		; esi = start of word
    mov     ecx, edi    		; ecx = end of word
    jmp     short @@7A
@@2B:
    mov     esi, edi    		; esi = start of word
@@3B:
    cmp     [edi], al     		; end of word?
    jbe     short @@4B
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
    sub     edi, S_ADR              ; offset from start
    mov     _IN , edi   		    ; update _IN
    sub     ecx, esi    		    ; length of word
    cmp     ecx,  MAXCOUNTED        ; max at MAXCOUNTED
    jbe     short @@8A
    mov     ecx,  MAXCOUNTED        ; clip to MAXCOUNTED
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
    JMP do_COUNT
    NEXTC                       ; WORD: 
;
PARSENAME:  ; ( "<spaces>name" -- c-addr u ) ; parse the input stream
DD _WORD
DD do_PARSENAME
DB 10, "PARSENAME"
do_PARSENAME:
    POP EBX
    ; for a string delimited by spaces. Skip all leading spaces.
    ; Give the string as address and count.
    push    ebx
    mov     eax, S_ADR           ; edi = input pointer
    add     eax, _IN   		 ; add _IN
    push    eax         		 ; address of output eax = input char
    mov     ecx, S_LEN            ; ecx = input length
    sub     ecx, _IN    		; subtract _IN
    ja      short @@1C
    xor     ecx, ecx   			 ; at end of input
    jmp     short @@8C

@@1C:
    push    eax
    mov     eax, [eax]
    cmp     eax,  32      ; leading delimiter?
    pop     eax
    ja      @@2C
    add     eax,  1    		; go to next character
    sub     ecx,  1
    jnz     @@1C

    mov     ebx, eax    		; ebx = start of word
    mov     ecx, ebx   		 ; ecx = end of word
    jmp     short @@7C

@@2C:
    mov     ebx, eax    			; ebx = start of word
@@3C:
    push    eax
    mov     eax, [eax]
    cmp     eax,  32              ; end of word?
    pop     eax
    jbe     @@4C
    add     eax,  1
    sub     ecx,  1
    jnz     short @@3C
    mov     ecx, eax    		; ecx = end of word
    jmp     short @@7C

@@4C:
    mov     ecx, eax    			; ecx = end of word
    add     eax,  1    		; skip over ending delimiter
            ; update _IN pointer and get word length
@@7C:
    sub     eax, S_ADR              ; offset from start
    mov     _IN , eax  		 ; update _IN
    sub     ecx, ebx    		; length of word
    mov     0 [esp], ebx            ; save on stack
@@8C:
    mov     ebx, ecx    			; and length
    NEXTC
;
PARSE:      ; ( char "ccc<char>" -- c-addr u ) ; parse the input stream
DD PARSENAME
DD do_PARSE
DB 5, "PARSE"
do_PARSE:
    POP EBX
    ; for a string delimited by char. Skip ONLY ONE leading char.
    ; Give the string as address and count.
    mov     eax, S_ADR              	; edi = input pointer
    add     eax, _IN    			; add _IN
    push    eax         			; address of output
    push    edx
    mov     dl, bl      				; char to scan for eax = input char
    mov     ecx, S_LEN              	; ecx = input length
    sub     ecx, _IN    			; subtract _IN
    ja      short @@1D
    xor     ecx, ecx    ; at end of input
    jmp     short @@8D

@@1D:
    mov     ebx, eax    				; ebx = start of word
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
    add     eax,  1    			; skip over ending delimiter
            ; update _IN pointer and get word length
@@7D:
    sub     eax, S_ADR              		; offset from start
    mov     _IN , eax   			; update _IN
    sub     ecx, ebx    			; length of word
    mov     4 [esp], ebx            	; save on stack
@@8D:
    mov     ebx, ecx    				; and length
    pop     edx
    PUSH EBX
    NEXTC
 ;

PARSESTR:  ; ( Addr Len -- Addr Len)
DD PARSE
DD do_PARSESTR
DB 9, "PARSE-STR"
do_PARSESTR:
POP EBX ;   EBX register will be popped from stack at entry
POP EAX ;   Load String Address
PUSH EDX ;   Save register set
PUSH EAX ;   Save String address
ADD EAX , EBX ;    Add length to addr to find End of string
MOV EDX , EAX ;   Save End of string
POP EAX ;   restore string addr
MOV ECX,  0000 ;   Load Counter
@@1E:
push eax
mov eax, [ebx]
CMP eax,  32 ;   advance over leading spaces
pop eax
JNE SHORT @@2E
INC EAX
CMP EAX, EDX
JE SHORT @@3E ;   end of string encountered
JMP SHORT @@1E
@@2E:
PUSH EAX ;   save starting address
@@4E:
INC ECX
push eax
mov eax, [eax]
CMP eax,  32 ;   locate a space
pop eax
JE SHORT @@3E ; trailing space found
CMP EAX, EDX
JE SHORT @@3E ;   past end of string
INC EAX
JMP SHORT @@4E
@@3E:
DEC ECX
MOV EBX, ECX ;   move counter to ebx
POP EAX
POP EDX
PUSH EAX
push ebx
NEXTC
;   EBX register will be pushed on stack at exit
;
_NOOP:
DD PARSESTR
DD do_NOOP
DB 4, 'NOOP'
do_NOOP:
NEXTC
;
_HERE:
DD _NOOP
DD do_HERE
DB 5, 'HERE'
do_HERE:
mov ebx, [DPR]
push ebx
NEXTC
;
_UPPERCASE: ; ( SADDR LEN -- SADDR)
DD _HERE
DD do_UPPERCASE
DB 9, 'UPPERCASE'
do_UPPERCASE:
POP ECX  ; STRING LENGTH
MOV  EBX ,[ESP]
AND ECX, 0FFH
MOV EAX, 0
UPC:
CMP CL, 0
JZ @@11
MOV AL, [EBX]
cmp AL, 96
JL @@10
MOV AL, [EBX]
CMP AL, 122
JG @@10
MOV AL, [EBX]
AND AL, 05FH
MOV [EBX], AL
@@10:
INC EBX
DEC CL
JMP UPC
@@11:
NEXTC       ; UPPERCASE
;
_LOWERCASE: ; ( SADDR -- SADDR)
DD _UPPERCASE
DD do_LOWERCASE
DB 9, 'LOWERCASE'
do_LOWERCASE:
POP EBX  ; STRING ADDRESS
PUSH EBX ; SAVE ADDRESS
MOV ECX, [EBX-1] ; LENGTH
AND ECX, 0FFH
MOV EAX, 0
UPC1:
CMP CL, 0
JZ @@11a
MOV AL, [EBX]
cmp AL, 65
JL @@10a
MOV AL, [EBX]
CMP AL, 90
JG @@10a
MOV AL, [EBX]
OR AL, 020H
MOV [EBX], AL
@@10a:
INC EBX
DEC CL
JMP UPC1
@@11a:
NEXTC       ; LOWERCASE
;
FIND: ; ( SADDR LEN -- cfa   ) Search dictionary for a word
DD _LOWERCASE
DD do_FIND
DB 4, 'FIND'
do_FIND:
MOV FCOUNTER, 0
MOV CFA, 0
MOV LFA, 0
MOV NFA, 0
MOV FFLAG, 0
MOV EAX, 0
POP ECX     ; LENGTH
AND CX, 0FH
CMP CX, 0
JG @@01
MOV FFLAG, 0
POP EAX     ; REMOVE ADDRESS FROM STACK
PUSH CFA    
NEXTC       ; ABORT
@@01:
POP EAX     ; POCKET ADDRESS
PUSH EDI    ; INTERPRETER POINTER
PUSH [LATEST] 
@@6F:
INC FCOUNTER
POP EBX
CMP CL,  [EBX+8]
JNZ @@1F
; WORD LENGHTS ARE EQUAL CMP WORDS
MOV NFA, EBX
ADD NFA, 8
MOV LFA, EBX
PUSH EBX
MOV CL, [POC]
AND CX, 0FH
ADD EBX, 4
PUSH [EBX]
POP CFA
ADD EBX, 5
MOV ESI, EAX
MOV EDI, EBX
REPE CMPSB
POP EBX
MOV CL, [POC]
JNZ @@1F 
POP EDI
MOV FFLAG, -1
JMP @@5F
@@1F:
MOV EBX, [EBX] ; LINK ADDRESS
PUSH EBX
PUSH [EBX] ; LINK ADDRESS
POP EBX 
CMP EBX, 0
JZ @@6F1
MOV EBX, [ESP] ; RECOVER ADDRESS
MOV NFA, 0
MOV LFA, 0
JMP @@6F
@@6F1:
POP ECX
POP EDI
PUSH POCKET
POP CFA
INC CFA
MOV FFLAG, 0
@@5F:
PUSH CFA
NEXTC ; FIND: LEAVING CFA
;
GTNUMBER:    ;( ud addr len -- ud addr len )
DD _LOWERCASE
DD do_GTNUMBER
DB 8, 'GTNUMBER'
do_GTNUMBER:
                POP     EBX
                test    ebx, ebx                ;\ check if anything to convert
                je      short @@4H              ;\ zero, so skip
                mov     [ebp-4], esi
                mov     [ebp-8], edx            ;\ save UP
                mov     esi, [esp]              ;\ esi = address
                mov     edi, BASE               ;\ get the number base
@@1H:           ; movzx   eax, [esi]              ;\ get next digit
                cmp     al,  '0'
                jb      short @@3H              ;\ if below '0' branch to done
                cmp     al,  '9'
                jbe     short @@2H              ;\ go convert it
                and     al,  0DFH                ;\ convert to uppercase
                cmp     al,  'A'                ;\ if below 'A'
                jb      short @@3H              ;\ then branch to done
                sub     al,  7
@@2H:           sub     al,  '0'
                cmp     eax, edi
                jae     short @@3H              ;\ out of base range
                xchg    eax, 4 [esp]            ;\ high word * base
                mul     edi
                xchg    eax, 8 [esp]            ;\ low word * base
                mul     edi
                add     eax, 4 [esp]            ;\ add
                adc     edx, 8 [esp]
                mov     8 [esp], eax            ;\ store result
                mov     4 [esp], edx
                add     esi,  1
                sub     ebx,  1
                jnz     short @@1H
@@3H:           mov     [esp], esi              ;\ address of unconvertable digit
                mov     esi, [ebp-4]
                mov     edx, [ebp-8]            ;\ save UP
                xor     edi, edi                ;\ edi is zero
@@4H:            
NEXTC
;
NUMINIT:      ; ( -- )                  initialise number values
DD GTNUMBER
DD do_NUMINIT
DB 7, 'NUMINIT'
do_NUMINIT:
MOV DOUBLEQ, -1                ; false to double?
MOV DPLOCATION, -1             ; -1 to dp-location
MOV VENUMQ, 0                  ; false to -ve-num?
NEXTC
;
NEWNUMBER: ; ( ADDR -- N F )  ONLY WORKS FOR INTEGERS (+/-)
DD NUMINIT
DD do_NEWNUMB
DB 7,'NEWNUMBER'
do_NEWNUMB:
    ; POP EAX           ; LEFT OVER FLAG
    POP EBX             ; ADDR
    MOV CL, [EBX-1]     ; COUNTED STRING
    AND ECX, 00FFH
    PUSH 0
    MOV AL, [EBX] 
    CMP AL, 45 
    JNE @@1J1           ; FIRST CHARACTER IS NOT A '-' SIGN
    MOV SIGNFLAG, -1
    @@1J1:
    MOV CH, BYTE PTR BASE
    MOV EAX, 0
    MOV EDX, 0
    MOV [ESP], EDX
    TEST ECX, ECX
    JZ @EXIT
    @@1J:
    CMP CL, 0
    JZ @DONE
    MUL CH
    MOV DL, [EBX]
    SUB DL, 48
    CMP DL, 9
    JG @EXIT
    ADD EAX, EDX
    INC EBX
    DEC CL
    JMP @@1J
    @ERROR:
    ADD ESP, 4
    PUSH 0
    JMP @EXIT
    @DONE:
    CMP SIGNFLAG, 0
    JZ @DONE1
    PUSH EAX
    MOV EAX, 0
    POP ECX
    SUB EAX, ECX
    @DONE1:
    MOV [ESP], EAX
    PUSH -1
    @EXIT:
    NEXTC
;
NEWHEADER:
DD NEWNUMBER
DD do_NEWHEAD
DB 7, 'NEWHEADER'
do_NEWHEAD:
POP ECX
POP EBX
PUSH EDI
PUSH ECX
AND ECX, 00FFH
INC ECX
MOV EAX, DPR
PUSH LATEST
POP [EAX]
ADD EAX, 8
MOV EDI, EAX
SUB EBX, 1
MOV ESI, EBX
REP MOVSB
SUB EAX, 8
PUSH EAX
POP LATEST
POP ECX
INC ECX
ADD ECX, 12
ADD EAX, ECX
MOV DPR, EAX
POP EDI
NEXTC
;
KBREAD:   ; READ INPUT FROM KEYBOARD
DD NEWHEADER
DD do_KBREAD
DB 6, 'KBREAD'
do_KBREAD:
invoke StdOut,ADDR MsgQ
invoke StdIn, ADDR TIB, LENGTHOF TIB
LEA EBX, TIB    ; ADD A SPACE TO END OF INPUT LINE
ADD EBX, EAX
PUSH 20H
POP [EBX]
ADD EAX, 1
MOV S_LEN, EAX
PUSH EAX
; invoke StdOut,ADDR crlf$
NEXTC
;

CLS: ; CLEAR SCREEN
DD KBREAD
DD do_CLS
DB 3, 'CLS'
do_CLS:
    invoke ClearScreen
NEXTC
;
CR: ; EMIT CRLF
DD CLS
DD do_CR
DB 2, 'CR'
do_CR:
invoke StdOut,ADDR crlf$
NEXTC
;
DABS:           ; ( d1 -- d2 )    \ return the absolute value of d1 as d2
DD CR
DD do_DABS
DB 4, 'DABS'
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
HOLD:       ; ( char -- ) \ insert char in number output picture - see <#
DD DABS
DD do_HOLD
DB 4, 'HOLD'
do_HOLD:
mov     eax, 4 [EDX]   ; UP EQU EDX  ( [EDX] + 4 )  CELLS = + 4  MOV EAX, [EDX] + 4
sub     eax, 1
mov     [eax], bl
mov     4 [EDX], eax   ; DUP USER HLD CELL+ ( numeric output pointer )
pop     ebx
PUSH    EBX
NEXTC
;
SPACES: ; ( N -- )
DD HOLD
DD do_SPACES
DB 6, 'SPACES'
do_SPACES:
POP ECX ; NUMBER OF SPACES
@@1L:
 invoke StdOut, ADDR SPACE$
 DEC BL
 CMP BL, 0
 JNZ @@1L
 NEXTC
;
POUND:              ; CODE #  ( d1 -- d2 ) \ convert a digit in pictured number output - see <#
DD SPACES
DD do_POUND
DB 1, '#'
do_POUND:
  POP     EBX
  push    edx       ; save UP
  mov     ecx, BASE [EDX]
  sub     edx, edx
  mov     eax, ebx
  div     ecx
  mov     ebx, eax
  mov     eax, 4 [esp]
  div     ecx
  mov     4 [esp], eax
  mov     eax, edx
  pop     edx        ; restore UP
  cmp     al,  9
  jbe     short @@1M
  add     al,  7
@@1M:           
  add     al,  '0'
  mov     ecx, HLD [EDX]
  lea     edi, PAD [EDX]
  sub     edi, ecx
  cmp     edi,  80
  jge     short @@2M
  sub     ecx,  1
@@2M:
  mov     [ecx], al
  mov     HLD [EDX]  , ecx
  xor     edi, edi   ; restore 0
NEXTC
;
itohex:                  ; (PAD N -- PAD)
DD POUND
DD do_ITOHEX
DB 5, 'I2HEX'
do_ITOHEX:
    push   edi           ; save a call-preserved register for scratch space
    mov    edi, [esp+8]  ; out pointer
    mov    eax, [esp+4]  ; number

    mov    ecx, 8        ; 8 hex digits, fixed width zero-padded
@@loop:                  ; do {
    rol    eax, 4        ; rotate the high 4 bits to the bottom

    mov    edx, eax
    and    edx, 0fH      ; and isolate 4-bit integer in EDX

    ADD    DL, HEX_TABLE ; byte [HEX_TABLE + edx]
    ; movzx  edx, DL     
    mov    [edi], DL     ; copy a character from the lookup table
    inc    edi           ; loop forward in the output buffer

    dec    ecx
    jnz    @@loop   ; }while(--ecx)

    pop    edi
    POP    EAX
    NEXTC
;
__UNTIL:     ;    ( f1 -- )       \ "runtime" if f1=FALSE branch to after BEGIN
DD itohex
DD do__UNTIL
DB 6, '_UNTIL'
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
_IF@:        ; INTERACTIVE IF - THEN PAIR
DD __UNTIL
DD do_IF@
DB 3, 'IF*'
do_IF@:
POP EBX
CMP EBX,0
JZ @IF
NEXTC       ; CONTINUE PROCESS NEXT WORDS
@IF:        ; SKIP WORDS TILL do_THEN@ FOUND
CMP [EDI], do_THEN@
JZ @IF1
ADD EDI, 4
JMP @IF
@IF1:
; CONTINUE PROCESSING WORDS
NEXTC
;
_ELSE@:      ; INTERACTIVE
DD _IF@
DD do_ELSE@
DB 5, 'ELSE*'
do_ELSE@:
; NOOP
NEXTC
;
_THEN@:      ; INTERACTIVE
DD _ELSE@
DD do_THEN@
DB 5, 'THEN*'
do_THEN@:
; NOOP
NEXTC
;
HASHV:     ;( a1 n1 #threads -- n2 )
DD _THEN@
DD do_HASHV
DB 5, 'HASHV'
do_HASHV:
 POP     EBX
 pop     eax                     ; pop count into EAX
 mov     [RSP-4], edx           ; save UP
 mov     [RSP-8], ebx           ; save # of threads
 pop     ebx                     ; get string address into EBX
 mov     ecx, eax                ; copy count into ECX
 add     ebx, ecx
 neg     ecx
@@1HV:
 rol     eax,  7                 ; rotate result some
 xor     al, [ebx] [ecx]
 add     ecx,  1
 jl      @@1HV                   ; +ve, keep going
 xor     edx, edx                ; clear high part of dividend
 div     [RSP-8]                 ; perform modulus by #threads
 mov     ebx, edx                ; move result into EBX
 mov     edx, [RSP-4]            ; restore UP
 lea     ebx, [ebx*4]            ; multiply by cell size
 NEXTC
;
EXECUTE:   ;( cfa -- )  execute a Forth word, given its cfa
DD HASHV
DD do_EXECUTE
DB 7, 'EXECUTE'
do_EXECUTE:
   POP EAX
   jmp eax
;
_EMSG:
DD EXECUTE
DD do_EMSG
DB 5, 'EMSG?'
do_EMSG:
MOV EAX, [ESP]
CMP EAX, 0
JNZ @EMSG
invoke StdOut,ADDR Msg10
invoke StdOut,ADDR POC+1
invoke StdOut,ADDR Msg11
@EMSG:
NEXTC
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

NCODE (S")      ( -- addr len )                \ for s" type strings
                push    ebx
                lea     ecx, 1 [esi]           \ start of string
                movzx   ebx, byte ptr [esi]    \ length of string in TOS
                push    ecx                    \ save addr of string
                lea     esi, 8 [ecx] [ebx]     \ optimised next, account for len & null at end
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
_DOTP:                         ; ( -- addr len -- )                
DD _EMSG
DD do_DOTP
DB 2, ".'"
do_DOTP:
lea     ecx, [edi]             ; start of string
movzx   ebx, byte ptr [edi]    ; length of string in TOS
push    ecx                    ; save addr of string
lea     esi, 4 [ecx] [ebx]     ; optimised next, account for len & null at end
and     esi, -4                ; align
LEA EAX, do_TYPE               ; mov     eax, # ' TYPE          \ next word
JMP     EAX                    ; go do it
;
_TYPE: ; ( ADDR LEN -- )
DD _DOTP
DD do_TYPE
DB 4, 'TYPE'
do_TYPE:
ADD ESP, 4 ; IGNORE LENGTH 
invoke StdOut,ADDR [ESP]
ADD ESP, 4 ; REMOVE ADDRESS
NEXTC
;
_TO:
DD _TYPE 
DD do_TO
DB 2, 'TO'
do_TO:
MOV EAX, [EDI]  ; GET DEST ADDR 
ADD EDI, 4      ; ADV POINTER 
JMP do_DOVALUESTORE
;
_Endless:    ; ENDLESS LOOP
DD _TO
DD do_Endless
DB 7, 'ENDLESS'
do_Endless:
JMP do_Endless
;
;   -------------------- End of CODE Definitions ---------------------------
;
USER_BASE DD 4096 dup (0H); Start of USER Area Dictionary 16k  (16364)
;
;   -------------------- Colon Definitions -----------------------------
;
SOCD:
DB ': , HERE ! CELL DPR +! ;'       ; COMMA DEF
;DB ': DECIMAL 10 BASE ! ;'          ; DECIMAL DEF
;DB ': ABORT DECIMAL 0 STATE ! ;'    ; ABORT DEF
;DB ': INTER1 ;'                     ; INTERPRETER DEF
;
EOCD:
DB 256 dup (0H) ; EMPTY BUFFER SPACE 
;   -------------------------------------------------------------------
END start