\ HTTP Web Server
\ Tom Dixon

needs http
needs httpecho
needs httpmime
needs httpfile

\ Setup Server
80 httpserver http
http setup-http
http serv-init

\ Run the Server
: www-server begin http serv-poll 10 ms key? until ;

