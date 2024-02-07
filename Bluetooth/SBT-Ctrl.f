\
\ Simple Serial Bluetooth Controller Trial
\ FJRusso 230708
\
: SBT-Trial ;
0 Value inbuffer 0 Value outbuffer 0 Value etimer
0 Value BTO 0 Value Mac-Addr
Create MasterSBTName z" ESP32-BT-Master" drop
Create SlaveSBTName z" ESP32-BT-Slave" drop
Create msg1 z" Master Initialized" drop
\
Also Bluetooth
\
: SBT-Master-init   ( -- )
\ acquire a BT handle
SerialBT.new ( -- ) to BTO ." BTO = " BTO . cr
BTO SerialBT.enableSSP ( BTO -- )  ." SSP Enabled" cr
\ Begin BT by providing a name and the status 1 = controller 0 = receiver
MasterSBTName 1 BTO SerialBT.begin ( a n hndl -- ior ) drop 250 ms
." ESP32-BT-Controller is Visible" cr ." Connecting - "
esp_bt_dev_get_address to Mac-addr \ Not a necessary step
\ Connect Controller to a receiver
SlaveSBTName BTO SerialBT.connect ( a hndl -- ior ) 500 ms
IF ." Successful" cr Else ." Unsuccessful" cr Then ;
\
: SBT-Receive ( addr n -- n )
{ inbuffer bcounter }
BTO SerialBT.available ( bto -- ior )  IF
InBuffer bcounter BTO SerialBT.readBytes ( a n bto -- n )  to bcounter
." Incoming Data - " Inbuffer bcounter Type bcounter
10 ms BTO SerialBT.flush Else 0 Then ;
\
: SBT-Send ( addr -- n )
{ outbuffer }
\ add CR LF to end of output buffer string
$crlf outbuffer z>s + 2 cmove outbuffer z>s
BTO serialbt.write ( a n bto -- n ) \ Bytes written returned
10 ms BTO SerialBT.flush  ;
\
: SBT-Exit
BTO SerialBT.end ( bto -- )  0 to BTO ;
\
: Init
80 allocate drop to inbuffer 80 allocate drop to outbuffer
inbuffer 80 erase outbuffer 80 erase ;
\
: CKTime ( -- ) \ Calc and display elapsed time
ms-ticks etimer -
." Elapsed time = " . ."  ms" cr
ms-ticks to etimer ;
\
\ Allows for user input to be tramsmitted to the receiving SBT unit
\ A blank Enter key will terminate the program
\
: MAIN
." Let's Begin" cr
Init SBT-Master-init ms-ticks to etimer
key? IF key drop Then \ Clear the input stream
\ Sends message to receiving unit
msg1 z>s outbuffer swap cmove outbuffer SBT-Send drop
\
Begin inbuffer 80 SBT-Receive IF CkTime Then
Key? IF outbuffer 80 2dup erase accept
0= IF 1 Else outbuffer SBT-Send drop ms-ticks to etimer 0
key? IF key drop Then Then Else 0 Then Until
\
SBT-Exit cr ." Bluetooth Closed" cr
inbuffer free to inbuffer outbuffer free to outbuffer ;
\
