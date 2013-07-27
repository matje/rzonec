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

@ 				SOA	RDATA_SOA
@ 			IN	A	1.2.3.4
@ 			IN	A	213.154.224.1
@ 			IN	A	666.666.666.666
@ 			IN	A	1337.133.337.137
@ 			IN	A	1.2.3.4.5
@ 			IN	A	1.2.3
@ 			IN 7200	NS	RDATA_NS
@ 			   300	MD	RDATA_MD
@ 			   300	MF	RDATA_MF
@ 			   300	CNAME	RDATA_CNAME

test			IN 7200	RDATA
				RDATA
pom.example.com.  RDATA 

$TTL 3w12s

