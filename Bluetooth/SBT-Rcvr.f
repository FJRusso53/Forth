\
\ Simple Serial Bluetooth Receiver Trial
\ FJRusso 230708
\
: BT-Trial ;
0 Value bufferin 0 Value bufferout
0 Value timer1 0 Value BTO 0 Value Mac-Addr
Create MasterSBTName z" ESP32-BT-Master" drop
Create SlaveSBTName z" ESP32-BT-Slave" drop
Create msg1 z" Acknowledged  " drop
\
Also Bluetooth
\
: SBT-Slave-init ( -- )
SerialBT.new to BTO ." BTO = " BTO . cr
BTO SerialBT.enableSSP ." SSP Enabled" cr
SlaveSBTName 0 BTO SerialBT.begin drop 250 ms
esp_bt_dev_get_address to Mac-addr
." ESP32-BT-Slave is Visible" cr ." Awaiting Connection" cr
msg1 z>s + $crlf swap 2 - 2 cmove ;
\
: SBT-Receive ( addr n -- n )
{ Inbuffer bcounter }
BTO SerialBT.available
IF Inbuffer bcounter erase 0 to bcounter
InBuffer 80 BTO SerialBT.readBytes to bcounter
." Incoming Data - " Inbuffer bcounter type
\ Sends an Acknowledgement to the controller
msg1 z>s BTO SerialBT.write drop
." Acknowledgement Sent" cr 20 ms BTO SerialBT.Flush
bcounter Else 0 Then ;
\
: SBT-Send ( addr -- n )
{ outbuffer }
$crlf outbuffer z>s + 2 cmove outbuffer z>s
BTO serialbt.write ( bto -- n ) \ Bytes written returned
20 ms BTO SerialBT.flush
;
\
: SBT-Exit
BTO SerialBT.end 0 to BTO ;
\
: Init ( -- )
80 allocate drop to bufferin 80 allocate drop to bufferout
bufferin 80 erase bufferout 80 erase ;
\
: Connection-Wait ( -- )
ms-ticks 60000 + to timer1
\ Wait for a connection
Begin BTO 3000 SerialBT.connected
ms-ticks timer1 > Or Until
." Connection accepted" cr ;
\
\ A blank Enter key will terminate the program
\ No user input accepted
\
: Main ( -- )
init SBT-Slave-init Connection-Wait
Begin bufferin 80 SBT-Receive drop
key? IF Key 13 = IF 1 Else 0 Then Else 0 Then
Until
SBT-Exit cr ." Bluetooth Closed" cr
bufferin free to bufferin bufferout free to bufferout ;
