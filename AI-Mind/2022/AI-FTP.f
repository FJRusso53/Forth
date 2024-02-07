\
\ Load the AI-FTP data structure with default values
\
: AIFTP-fill
AI-FTP
dup ftp-size 0 fill
dup fname s" index.html" rot swap cmove
dup rdir s" public_html/" rot swap cmove
\ using default AI directory
dup username s" aimind-i" rot swap cmove
dup password s" FJR07AI" rot swap cmove
dup FTPserver s" aimind-i.com" rot swap cmove
dup sessionID s" 4thAIMind" rot swap cmove
\
\ added email connection fields
\
dup email-user s" aimind-i@aimind-i.com" rot swap cmove
dup email-password s" FJR07AI" rot swap cmove
dup pop3-addr s" mail.aimind-i.com" rot swap cmove
smtp-addr s" mail.aimind-i.com" rot swap cmove
\
;
