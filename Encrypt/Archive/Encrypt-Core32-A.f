\ Encrypt-Core.F
\ Frank J. Russo
\ Version 1.0
\ Date 210915
\
HEX \  ALL numerics used are in 'HEX' NOT Decimal !!!!!!
\
: RRot noop ;
\
: LRot noop ;
\
\ ***************************************************************************************
\

\
\ ***************************************************************************************
\
: PW-Enc ( addr n -- ) \ Encrypt password
Noop
;
\
\ ***************************************************************************************
\
: Enc-Rotate  (  ---  )
\ 210215 Changed for speed to use assembly calls )
\ updated to use pointers to memory locations
\
noop
;
\
\ ***************************************************************************************
\

\
: Enc-Fetch (  ---  )
\ cr Start-P @ . 9 emit End-P @ . 9 emit  textposition @ . cr
\ Start-P @ End-P @ Start-P @ - 1+ dump cr
\ Fetch word from buffer 210215 passes values to calling routine
Noop
;
\
\ ***************************************************************************************
\

\
: Enc-Main-Proc \ Updated 210915   ( PWAdr, PW-Size, BufArd, Buf-size, ?Lock  ---   )
Noop
;
\
