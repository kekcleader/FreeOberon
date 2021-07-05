forking server example in oberon
================================

to compile

>make

run

>./s

test

>telnet localhost 2055

write something

>հեյ

stdout of the client

> $ telnet localhost 2055  
Trying ::1...  
telnet: connect to address ::1: Connection refused  
Trying 127.0.0.1...  
Connected to localhost.  
Escape character is '^]'.  
հեյ  
Affirmative, DaveConnection closed by foreign host.  

stdout of the server:

>$ ./s
socket created.  
binding completed.  
listen okay  
accept okay  
forked okay  
received message is հեյ  
