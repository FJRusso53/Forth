0 Value t1*
0 Value t2*
0 Value t3*
0 Value t4*

: foldercopy ( "src path" "dst path" -- ) ( * Frank Russo 240207 )
( copy folder of files ) (  t1* = SRC, t2* = size, t3* = DEST, t4* = size )
cr ." Folder Copy .vs. 1.0 240213" cr cr
0 to t0*
bl parse bl parse 
64 allocate throw to t1* t1* 64 0 fill
64 allocate throw to t3* t3* 64 0 fill
dup to t2* t1* swap cmove 
dup to t4* t3* swap cmove
t3* t4* open-dir drop to t5*
Begin
t5* read-dir dup
IF 
  1 +to t0*
  2dup t1* t2* + swap cmove
  t3* t4* + swap cmove
  ." Moving file FROM - " t3* z>s type ."  TO - " t1* z>s type cr
  t3* z>s r/o bin open-file   throw to t6* \ { inf1 } 
  t1* z>s w/o bin create-file throw to t7* \ { outf1 } 
  Begin
    here 1024 t6* read-file drop \ throw
    dup 0<> 
    IF here swap t7* write-file throw drop 0 100 TDelay
    Else drop 1 100 TDelay
    Then
  Until 
  t7* close-file throw 
  t6* close-file throw
  t1* t2* + z>s 0 fill
  t3* t4* + z>s 0 fill 
  0
Else 1
Then
Until
..
t5* close-dir throw 0 to t5* 
t1* free throw 0 to t1*
t3* free throw 0 to t3* 
t0* . ."  Files moved" cr
;
