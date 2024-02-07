; Forth-Core.asm
;
; FJRusso Vs 1.3
; Frank's attempt at a FORTH Core in 32 bit Assm
; Tuesday 19 September 2023 12:00 hours
; 
; Using MASM32 in VS 2022
;
.486
.MODEL flat,stdcall
.stack 1024 
;
.data ; Data Section
;
DSB DB 32 dup (0H) ; A buffer between the data stack and return stack
R0 Db 1024 dup (0H) ; Return Stack Base of size 1024 
RSB DB 32 dup (0H) ; Buffer between return stack and data area
PAD DB 256 dup (0H) ; Output buffer
TIB DB 256 dup (0H) ; Input buffer
S0 DD 0 ; Stack base starting point
RSP DD R0 + 1023
msg1 DB ' Forth by FJRusso' , 0h
msg2 DB ' September 2023' , 0h
crlf$ DB 13, 10, 0h
LATEST DD 0
DPR DD 0
PREVIOUS DD h_COMPILE
;
NEXTC macro byte
   MOV EAX, [EDI]
   ADD EDI, 4
   JMP EAX 
endm
;
.code 
;
; ---------------------------------------------------------------------------
;
Forth_Thread:
DD do_LAST 
DD do_LATEST
DD do_PUSH1
DD do_SPACE
DD do_h_PLUS
DD do_h_2TIMES
DD do_SPACE
DD do_h_MINUS
DD do_h_DUP
DD do_h_2DIVIDE
DD do_h_SWAP
DD do_h_OVER
DD do_h_ROT
DD do_h_UNDERPLUS
DD do_h_ABS
DD do_h_U2DIVIDE
DD do_PUSH0
DD do_h_D2TIMES
DD do_h_D2DIVIDE
DD do_h_DROP
DD do_h_TUCK
DD do_h_LIT
DD 4096
DD do_h_LIT
DD 7
DD do_h_2DUP
DD do_h_RROT32
DD do_h_DROP
DD do_h_LROT32
DD do_h_DUP
DD do_h_2DROP
DD do_EMIT
DD do_Endless
;
main:
PUSH ESP
POP S0 ; Saving Stack Pointer Base 
LEA EAX, h_COMPILE
PUSH EAX
POP LATEST
LEA EAX, USER_BASE
PUSH EAX
POP DPR
PUSH 0 ;  simply here to clear last stack entry
POP EAX
;
; Inner Interpreter
;
LEA EDI ,  Forth_Thread ; Load DI with Forth_Thread
NEXTC
;
; Dictionary Begins
; -------------------- PRIMITIVES CORE CODE 
;
_COLON:
DD 0000    ; No previous words  Pointer to previous words
DB 5
DB 'DOCOL'
do_COLON:
POP EAX
PUSH EDI
mov edi, eax
mov eax, [edi]
add edi, 4
JMP EAX 
;
_SEMI:
DD _COLON
DB 4
DB 'SEMI'
do_SEMI:
POP EDI
NEXTC
;
;
_PUSH1:      ; PUSH 1 onto data stack
DD _SEMI    
DB 1, '1'    ; Name of Definition counted string name
do_PUSH1: 
MOV EAX , 01H    ; Action Code
PUSH EAX
NEXTC        ; End of definition
;
_RS:  ; Restore Stack pointer to base (  --  )
DD _PUSH1
DB 2
DB '..'
do_RS:
MOV ESP , DWORD PTR [ S0 + 1023  ]
NEXTC
;

_PUSH0: ; PUSH 0 onto stack
DD _RS
DB 1
DB '0'
do_PUSH0:
MOV EAX,0
PUSH EAX
NEXTC
;
_SPACE: 
DD _PUSH0
DB 2
DB 'BL'
do_SPACE:
PUSH 32
NEXTC
;
_LATEST: ; Returns address of the variable LATEST
DD _SPACE
DB 6
DB 'LATEST'
do_LATEST:
LEA EAX, LATEST
PUSH EAX
NEXTC
;
_LAST: ; Returns header addr of Last Word in Dict
DD _LATEST
DB 4
DB 'LAST'
do_LAST:
MOV EAX, DWORD PTR [LATEST]
PUSH EAX
NEXTC
;
_COMPILE: ; ( -- )  \ compile xt following
DD _LATEST
DB 7
DB 'COMPILE'
do_COMPILE:
POP EBX
push ebx
mov  ebx, [esi]
add  esi, 4
NEXTC
;
_DP: ; retrieve DP data
DD _COMPILE
DB 2
db 'DP'
do_DP:
; TBD
PUSH 0
NEXTC
;
;   -------------------- Memory Operators -------------------------------------
;
h_FETCH:  ; ( a1 -- n1 )     ; \  get the cell n1 from address a1
DD _DP      
DB 1
DB "@"
do_h_FETCH: 
    POP EBX 
    mov ebx, 0 [ebx]
    push ebx
    NEXTC
 ; 
h_STORE:  ; ( n1 a1 -- )     ; \  store cell n1 into address a1
DD h_FETCH     
DB 1
DB "!"
do_h_STORE: 
    POP EBX 
    pop [ebx]
    pop ebx
    NEXTC
 ; 
h_PLUSSTORE:      ; ( n1 a1 -- )     ; \  add cell n1 to the contents of address a1
DD h_STORE     
DB 2
DB "+!"
do_h_PLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], eax
    pop ebx
    NEXTC
 ; 
h_CFETCH:      ; ( a1 -- c1 )     ; \  fetch the character c1 from address a1
DD h_PLUSSTORE 
DB 2
DB "C@"
do_h_CFETCH: 
    POP EBX 
    movzx ebx, byte ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
h_CSTORE:      ; ( c1 a1 -- )     ; \  store character c1 into address a1
DD h_CFETCH    
DB 2
DB "C!"
do_h_CSTORE: 
    POP EBX 
    pop eax
    mov 0 [ebx], al
    pop ebx
    NEXTC
 ; 
h_CPLUSSTORE:    ; ( c1 a1 -- )     ; \  add character c1 to the contents of address a1
DD h_CSTORE    
DB 3
DB "C+!"
do_h_CPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], al
    pop ebx
    NEXTC
 ; 
h_WFETCH:      ; ( a1 -- w1 )     ; \  fetch the word ; (16bit) w1 from address a1
DD h_CPLUSSTORE
DB 2
DB "W@"
do_h_WFETCH: 
    POP EBX 
    movzx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
h_SWFETCH:     ; ( a1 -- w1 )     ; \  fetch and sign extend the word ; 
DD h_WFETCH    
DB 7
DB "SWFETCH"
do_h_SWFETCH: 
    POP EBX 
    movsx ebx, word ptr 0 [ebx]
    push ebx
    NEXTC
 ; 
h_WSTORE:      ; ( w1 a1 -- )     ; \  store word ; (16bit) w1 into address a1
DD h_SWFETCH   
DB 2
DB "W!"
do_h_WSTORE: 
    POP EBX 
    pop eax
    mov 0 [ebx], ax
    pop ebx
    NEXTC
 ; 
h_WPLUSSTORE:     ; ( w1 a1 -- )     ; \  add word ; (16bit) w1 to the contents of address a1
DD h_WSTORE    
DB 3
DB "W+!"
do_h_WPLUSSTORE: 
    POP EBX 
    pop eax
    add 0 [ebx], ax
    pop ebx
    NEXTC
 ; 
; \  -------------------- Char Operators ---------------------------------------

h_CHARS:  ; ( n1 -- n1*char )  ; \  multiply n1 by the character size ; (1)
DD h_WPLUSSTORE
DB 5
DB "CHARS"
do_h_CHARS: 
    NEXTC
 ; 
h_CHARPLUS:  ; ( a1 -- a1+char )  ; \  add the characters size in bytes to a1
DD h_CHARS     
DB 5
DB "CHAR+"
do_h_CHARPLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
; 
; \  -------------------- Arithmetic Operators ---------------------------------
;
h_PLUS:   ; ( n1 n2 -- n3 )  ; \  add n1 to n2, return sum n3
DD h_CHARPLUS      
DB 1
DB "+"
do_h_PLUS: 
    POP EBX 
    pop eax
    add eax, ebx
    PUSH EAX
    NEXTC
 ; 
h_MINUS:   ; ( n1 n2 -- n3 )  ; \  subtract n2 from n1, return difference n3
DD h_PLUS         
DB 1
DB "-"
do_h_MINUS: 
    POP EBX ; n2
    pop eax ; n1
    sub eax, ebx ; n1 - n2
    push eax
    NEXTC
 ; 
h_UNDERPLUS:   ; ( a x b -- a+b x )  ; \  add top of stack to third stack item
DD h_MINUS         
DB 6
DB "UNDER+"
do_h_UNDERPLUS: 
    POP EBX 
    add 4 [esp], ebx
    NEXTC
 ; 
h_NEGATE:   ; ( n1 -- n2 )  ; \  negate n1, returning 2's complement n2
DD h_UNDERPLUS    
DB 6
DB "NEGATE"
do_h_NEGATE: 
    POP EBX 
    neg ebx
    push ebx
    NEXTC
 ; 
h_ABS:     ; ( n -- |n| )  ; \  return the absolute value of n1 as n2
DD h_NEGATE    
DB 3
DB "ABS"
do_h_ABS: 
    POP EBX 
    mov ecx, ebx  ; \  save value
    sar ecx, 31  ; \  x < 0 ? 0xffffffff : 0
    xor ebx, ecx  ; \  x < 0 ? ~x : x
    sub ebx, ecx  ; \  x < 0 ? ; (~x)+1 : x
    push ebx
    NEXTC
 ; 
h_2TIMES:      ; ( n1 -- n2 )  ; \  multiply n1 by two
DD h_ABS       
DB 2
DB "2*"
do_h_2TIMES: 
    POP EBX 
    add ebx, ebx
    push ebx
    NEXTC
 ; 
h_2DIVIDE:      ; ( n1 -- n2 )  ; \  signed divide n1 by two
DD h_2TIMES        
DB 2
DB "2/"
do_h_2DIVIDE: 
    POP EBX 
    sar ebx, 1
    push ebx
    NEXTC
 ; 
h_U2DIVIDE:     ; ( n1 -- n2 )  ; \  unsigned divide n1 by two
DD h_2DIVIDE        
DB 3
DB "U2/"
do_h_U2DIVIDE: 
    POP EBX 
    shr ebx, 1
    PUSH EBX
    NEXTC
 ; 
h_1PLUS:     ; ( n1 -- n2 )  ; \  add one to n1
DD h_U2DIVIDE       
DB 2
DB "1+"
do_h_1PLUS: 
    POP EBX 
    add ebx, 1
    push ebx
    NEXTC
 ; 
h_1MINUS:      ; ( n1 -- n2 )  ; \  subtract one from n1
DD h_1PLUS        
DB 2
DB "1-"
do_h_1MINUS: 
    POP EBX 
    sub ebx, 1
    push ebx
    NEXTC
 ; 
h_D2TIMES:     ; ( d1 -- d2 )  ; \  multiply the double number d1 by two
DD h_1MINUS        
DB 3
DB "D2*"
do_h_D2TIMES: 
    POP EBX 
    pop eax
    shl eax, 1
    rcl ebx, 1
    push eax
    PUSH EBX
    NEXTC
 ; 
h_D2DIVIDE:     ; ( d1 -- d2 )  ; \  divide the double number d1 by two
DD h_D2TIMES       
DB 3
DB "D2/"
do_h_D2DIVIDE: 
    POP EBX 
    pop eax
    sar ebx, 1
    rcr eax, 1
    push eax
    PUSH EBX
    NEXTC
 ; 
h_RROT32:  	; ( n1 n2 -- ror) ; ( 32 Bit Rotation of word right)
DD h_D2DIVIDE       
DB 6
DB "RROT32"
do_h_RROT32: 
 POP ECX
 POP EBX
 ror ebx, cl
 push ebx
    NEXTC
 ; 
h_LROT32:  	; ( n1 n2 -- rol) ; ( 32 Bit Rotation of word left)
DD h_RROT32    
DB 6
DB "LROT32"
do_h_LROT32: 
 POP ECX 
 pop ebx
 rol ebx, cl
 push ebx
    NEXTC
 ; 
h_GETADDR:  	; ( addr1, size, count -- addr2 )  ; \  for an array
DD h_LROT32    
DB 7
DB "GETADDR"
do_h_GETADDR: 
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
h_LIT:  ; ( -- n )     ; \  push the literal value following LIT in the
DD h_GETADDR   
DB 3
DB "LIT"
do_h_LIT:  ;  dictionary onto the data stack
    mov eBx, [EDI]
    PUSH EBX
    ADD EDI , 4
    NEXTC
 ; 
h_DROP:  ; ( n -- )     ; \  discard top entry on data stack
DD h_LIT       
DB 4
DB "DROP"
do_h_DROP: 
    POP EBX 
    NEXTC
 ; 
h_DUP:     ; ( n -- n n )     ; \  duplicate top entry on data stack
DD h_DROP      
DB 3
DB "DUP"
do_h_DUP: 
    MOV EBX , 0 [ESP] 
    push ebx
    NEXTC
 ; 
h_SWAP:  ; ( n1 n2 -- n2 n1 )  ; \  exchange first and second items on data stack
DD h_DUP       
DB 4
DB "SWAP"
do_h_SWAP: 
    POP EBX 
    mov eax, [esp]
    mov [esp], ebx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
h_OVER:  ; ( n1 n2 -- n1 n2 n1 )  ; \  copy second item to top of data stack
DD h_SWAP      
DB 4
DB "OVER"
do_h_OVER: 
    mov ebx, 4 [esp]
    PUSH EBX
    NEXTC
 ; 
h_ROT:     ; ( n1 n2 n3 -- n2 n3 n1 )  ; \  rotate third item to top of data stack
DD h_OVER      
DB 3
DB "ROT"
do_h_ROT: 
    POP EBX 
    mov ecx, 0 [esp]
    mov eax, 4 [esp]
    mov 0 [esp], ebx
    mov 4 [esp], ecx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
h_MINUSROT:  ; ( n1 n2 n3 -- n3 n1 n2 )  ; \  rotate top of data stack to third item
DD h_ROT       
DB 4
DB "-ROT"
do_h_MINUSROT: 
    POP EBX 
    mov ecx, 4 [esp]
    mov eax, 0 [esp]
    mov 4 [esp], ebx
    mov 0 [esp], ecx
    mov ebx, eax
    PUSH EBX
    NEXTC
 ; 
h_IFDUP:  ; ( n -- n [n] )  ; \  duplicate top of data stack if non-zero
DD h_MINUSROT      
DB 4
DB "?DUP"
do_h_IFDUP: 
    POP EBX 
    test    ebx, ebx
    je short @@1A
    push    ebx
@@1A:
    NEXTC
 ; 
h_NIP:     ; ( n1 n2 -- n2 )  ; \  discard second item on data stack
DD h_IFDUP      
DB 3
DB "NIP"
do_h_NIP: 
    POP EBX 
    POP EAX
    PUSH EBX
    NEXTC
 ; 
h_TUCK:  ; ( n1 n2 -- n2 n1 n2 )  ; \  copy top data stack to under second item
DD h_NIP       ; SWAP OVER
DB 4
DB "TUCK"
do_h_TUCK: 
    POP EBX
    PUSH 0 [ESP]
    MOV 4 [ESP], EBX
    PUSH EBX
    NEXTC
 ; 
h_PICK:  ; ( ... k -- ... n[k] )
DD h_TUCK      
DB 4
DB "PICK"
do_h_PICK: 
    POP EBX 
    mov ebx, 0 [esp] [ebx*4]  ; \  just like that!
    PUSH EBX
    NEXTC
; 
; \ -------------------- Double Arithmetic Operators --------------------------
h_StoD:       ; ( n1 -- d1 ) \ convert single signed single n1 to a signed double d1
DD h_PICK 
DB 'S>D'
do_h_StoD:
    pop ebx
    push    ebx
    shl     ebx, 1         ; \ put sign bit into carry
    sbb     ebx, ebx
    push ebx
    nextc
;
; \  -------------------- Cell Operators ---------------------------------------

h_CELL:  ; ( -- 4 )  ; \  cell size
DD h_StoD      
DB 4
DB "CELL"
do_h_CELL: 
    POP EBX 
    PUSH 4
    NEXTC
 ; 
h_CELLS:  ; ( n1 -- n1*cell )  ; \  multiply n1 by the cell size
DD h_CELL      
DB 5
DB "CELLS"
do_h_CELLS: 
    POP EBX 
    shl ebx, 2
    NEXTC
 ; 
h_CELLSPLUS:  ; ( a1 n1 -- a1+n1*cell )  ; \  multiply n1 by the cell size and add
DD h_CELLS     
DB 6
DB "CELLS+"
do_h_CELLSPLUS: 
    POP EBX 
     ; \  the result to address a1
    pop eax
    lea ebx, 0 [ebx*4] [eax]
    NEXTC
 ; 
h_CELLSMINUS:  ; ( a1 n1 -- a1-n1*cell )  ; \  multiply n1 by the cell size and subtract
DD h_CELLSPLUS    
DB 6
DB "CELLS-"
do_h_CELLSMINUS: 
    POP EBX 
     ; \  the result from address a1
    lea eax, 0 [ebx*4]
    pop ebx
    sub ebx, eax
    NEXTC
 ; 
h_CELLPLUS:  ; ( a1 -- a1+cell )  ; \  add a cell to a1
DD h_CELLSMINUS    
DB 5
DB "CELL+"
do_h_CELLPLUS: 
    POP EBX 
    add ebx, 4
    NEXTC
 ; 
h_CELLMINUS:  ; ( a1 -- a1-cell )  ; \  subtract a cell from a1
DD h_CELLPLUS     
DB 5
DB "CELL-"
do_h_CELLMINUS: 
    POP EBX 
    sub ebx, 4
    NEXTC
 ; 
h_PLUSCELLS:  ; ( n1 a1 -- n1*cell+a1 )  ; \  multiply n1 by the cell size and add
DD h_CELLMINUS     
DB 6
DB "+CELLS"
do_h_PLUSCELLS: 
    POP EBX 
     ; \  the result to address a1
    pop eax
    lea ebx, 0 [eax*4] [ebx]
    NEXTC
 ; 
h_MINUSCELLS:  ; ( n1 a1 -- a1-n1*cell )  ; \  multiply n1 by the cell size and
DD h_PLUSCELLS    
DB 6
DB "-CELLS"
do_h_MINUSCELLS: 
    POP EBX 
     ; \  subtract the result from address a1
    pop eax
    shl eax, 2
    sub ebx, eax
    NEXTC
 ; 
; \  -------------------- Stack Operations -------------------------------------

h_SPFETCH:     ; ( -- addr )  ; \  get addr, the pointer to the top item on data stack
DD h_MINUSCELLS    
DB 3
DB "SP@"
do_h_SPFETCH: 
    mov ebx, esp
    PUSH EBX
    NEXTC
 ; 
h_SPSTORE:     ; ( addr -- )  ; \  set the data stack to point to addr
DD h_SPFETCH      
DB 3
DB "SP!"
do_h_SPSTORE: 
    POP EBX 
    mov esp, ebx
    NEXTC
 ; 
h_RPFETCH:     ; ( -- a1 )  ; \  get a1 the address of the return stack
DD h_SPSTORE       
DB 3
DB "RP@"
do_h_RPFETCH: 
    mov ebx, RSP
    PUSH EBX
    NEXTC
 ; 
h_RPSTORE:     ; ( a1 -- )  ; \  set the address of the return stack
DD h_RPFETCH      
DB 3
DB "RP!"
do_h_RPSTORE: 
    POP EBX 
    mov RSP, ebx
    NEXTC
 ; 
h_TOR:      ; ( n1 -- ) ; ( R: -- n1 )  ; \  push n1 onto the return stack
DD h_RPSTORE       
DB 2
DB ">R"
do_h_TOR: 
POP EAX
SUB RSP, 4
PUSH RSP
POP EBX
MOV [EBX] , EAX
    NEXTC
 ; 
h_RFROM:      ; ( -- n1 ) ; ( R: n1 -- )  ; \  pop n1 off the return stack
DD h_TOR        
DB 2
DB "R>"
do_h_RFROM: 
PUSH RSP
POP EBX
MOV EAX , [EBX] ; DWORD PTR [RSP]
PUSH EAX
ADD RSP , 4
    NEXTC
 ; 
h_RFETCH:      ; ( -- n1 ) ; ( R: n1 -- n1 )  ; \  get a copy of the top of the return stack
DD h_RFROM        
DB 2
DB "R@"
do_h_RFETCH: 
MOV EAX , DWORD PTR [RSP]
PUSH EAX
    NEXTC
 ; 
h_DUPTOR:  ; ( n1 -- n1 ) ; ( R: -- n1 )  ; \  push a copy of n1 onto the return stack
DD h_RFETCH        
DB 5
DB "DUP>R"
do_h_DUPTOR: 
    mov ebx, [ESP]
    SUB RSP, 4
    mov [RSP], ebx
    NEXTC
 ; 
h_RFROMDROP:  ; ( -- ) ; ( R: n1 -- )  ; \  discard one item off of the return stack
DD h_DUPTOR     
DB 6
DB "R>DROP"
do_h_RFROMDROP: 
    ADD RSP, 4
    NEXTC
 ; 
h_2TOR:     ; ( n1 n2 -- ) ; ( R: -- n1 n2 )  ; \  push two items onto the returnstack
DD h_RFROMDROP    
DB 3
DB "2>R"
do_h_2TOR: 
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
h_2RFROM:    ; ( -- n1 n2 ) ; ( R: n1 n2 -- )  ; \  pop two items off the return stack
DD h_2TOR       
DB 3
DB "2R>"
do_h_2RFROM: 
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
h_2RFETCH:     ; ( -- n1 n2 )     ; \  get a copy of the top two items on the return stack
DD h_2RFROM       
DB 3
DB "2R@"
do_h_2RFETCH: 
    MOV EBX , [RSP-4]
    PUSH EBX
    MOV EBX ,[RSP]
    PUSH EBX
    NEXTC
 ; 
 h_2DUP:     ; ( N1 N2 -- N1 N2 n1 n2 )     ; \  DUPLICATE TOP 2 ITEMS ON STACK
DD h_2RFETCH       
DB 4
DB "2DUP"
do_h_2DUP: 
    MOV EBX , 4 [ESP]
    MOV EAX , 0 [ESP]
    PUSH EBX
    PUSH EAX
    NEXTC
 ; 
  h_2DROP:     ; ( n1 n2 -- )     ; \  DROP TOP 2 ITEMS ON STACK
DD h_2DUP       
DB 4
DB "2DUP"
do_h_2DROP: 
    ADD ESP, 8
    NEXTC
 ;
; ---------------External Words Included Here----------------------
;
_PARSE: 
DD h_2DROP
DB 5
dB 'PARSE'
do_PARSE:
; CTD
NEXTC
;
_NOOP:
DD _PARSE
DB 4
DB 'NOOP'
do_NOOP:
NEXTC
;
_Endless:    ; ENDLESS LOOP
DD _NOOP
DB 7
DB 'ENDLESS'
do_Endless:
JMP do_Endless
; -------------------------------------------------------------------
;  Colon Defnitions
; -------------------------------------------------------------------
_DOUBLE: ; ( n -- 2n ) double the value on stack
DD _Endless
DB 2
DB '2*'
do_Double:
PUSH $ + 10
JMP do_COLON
DD do_h_DUP
DD do_h_PLUS
DD do_SEMI
;
_PRINT: ; ( n -- ) \ display as signed single
DD _DOUBLE
DB 1
DB '.'
do_PRINT:
PUSH $ + 10
JMP do_COLON 
DD do_h_StoD
DD do_Ddot
DD do_SEMI
;
_TYPE: 
DD _PRINT
DB 5
DB 'PRINT'
do_TYPE:
push $ + 10
JMP do_COLON
; CTBD   *************************************
DD do_SEMI
;
_PDdotP:   ; (D.) ( d -- addr len ) \ convert as signed double to ascii string
DD _TYPE
DB 5
DB '(D.)'
do_PDdotP:
PUSH $ + 10
JMP do_COLON
; CTBD  ***************************************
DD do_SEMI
;
_EMIT: ; Display one character
dd _PDdotP
DB 4
DB 'EMIT'
do_EMIT:
push $ + 10
JMP do_COLON
DD do_TYPE  ;  ***************** Needs more Work 
DD do_SEMI
;
_Ddot: ;( d -- ) \ display as signed double
DD _EMIT ; (D.)
DB 2
DB 'D.'
do_Ddot:
PUSH $ + 10
JMP do_COLON
DD do_PDdotP ; (D.)
DD do_TYPE
DD do_SPACE
DD do_EMIT
DD do_SEMI
;
_COMMA: ; , ( n -- )  ( compile cell at HERE, increment DP)
DD _Ddot
DB 5
DB 'COMMA'
do_COMMA:  ; HERE  ! CELL DP +!  ;
PUSH $ + 10
JMP do_COLON
DD do_HERE
DD do_h_STORE
DD do_h_CELL 
DD do_DP
DD do_h_PLUSSTORE ; +!
DD do_SEMI
;
h_HERE:
DD _COMMA
DB 4
DB 'HERE'
do_HERE:
PUSH $ + 10
JMP do_COLON
DD DPR ; -------------  Needs Work
DD do_h_FETCH
DD do_SEMI
;
h_COMPILE:
DD h_HERE
db 8
DB 'COMPILE,'
PUSH $ + 10
JMP do_COLON
DD do_COMPILE
DD do_COMMA
DD do_SEMI
;
USER_BASE DW 0 ; Start of USER Area Dictionary
;
END main