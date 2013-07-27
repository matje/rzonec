$ORIGIN .
$ORIGIN example.com.
$ORIGIN example123456789012345678901234567890123456789012345678901234567890.com.
$ORIGIN ex\789am\123ple.com.
$ORIGIN ex\456am\123ple.com.
$ORIGIN ex\.am\;ple.com.
$ORIGIN ex\.am\0ple.com.
$ORIGIN example.com
$ORIGIN $origin

$TTL 3601
$TTL 360as1
$TTL 36h01
$TTL 3 29
$TTL 9 ;29
   
; some blank lines and bad entries
		
 asldaklasd asd'
asd
;asdlkasdll
    	 	 ;
	 		      ;;;;;;;;;;;;;;
	;askldas 2q38eujaoid asdaskdl;a
;	lkasdlkdk;sa;d;we;wqe;;sd
;			
	  	 	 ;	 	;; 	
aap


; start with zone contents

$ORIGIN www.example.com.

@ 				RRTODO
@ 			IN	RRTODO
@ 			IN 7200	RRTODO
@ 			   300	RRTODO

test			IN 7200	RRTODO
				RRTODO
pom.example.com.  RRTODO 

$TTL 3w12s

