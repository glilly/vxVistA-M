XUSBSE2 ;FO-OAK/JLI-CONNECT WITH HTTP SERVER AND GET REPLY ;5/24/07  13:47
 ;;8.0;KERNEL;**404,439**;Jul 10, 1995;Build 12
 Q
 ;
POST(SERVER,PORT,PAGE,DATA) ;
 Q $$ENTRY(SERVER,$G(PORT),$G(PAGE),"POST",$G(DATA))
 ;
GET(SERVER,PORT,PAGE) ;
 Q $$ENTRY(SERVER,$G(PORT),$G(PAGE),"GET")
 ;
ENTRY(SERVER,PORT,PAGE,HTTPTYPE,DATA) ;
 N DONE,XVALUE,XWBICNT,XWBRBUF,XWBSBUF,XWBTDEV,XWBDEBUG,XWBOS,XWBT,XWBTIME,POP
 N $ESTACK,$ETRAP S $ETRAP="D TRAP^XUSBSE2"
 S PAGE=$G(PAGE,"/") I PAGE="" S PAGE="/"
 S HTTPTYPE=$G(HTTPTYPE,"GET")
 S DATA=$G(DATA),PORT=$G(PORT,80)
 D SAVDEV^%ZISUTL("XUSBSE") ;S IO(0)=$P
 D INIT^XWBTCPM
 D OPEN^XWBTCPM2(SERVER,PORT)
 I POP Q "DIDN'T OPEN CONNECTION"
 S XWBSBUF=""
 U XWBTDEV
 D WRITE^XWBRW(HTTPTYPE_" "_PAGE_" HTTP/1.0"_$C(13,10))
 I HTTPTYPE="POST" D
 . D WRITE^XWBRW("Referer: http://"_$$KSP^XUPARAM("WHERE")_$C(13,10))
 . D WRITE^XWBRW("Content-Type: application/x-www-form-urlencoded"_$C(13,10))
 . D WRITE^XWBRW("Cache-Control: no-cache"_$C(13,10))
 . D WRITE^XWBRW("Content-Length: "_$L(DATA)_$C(13,10,13,10))
 . D WRITE^XWBRW(DATA)
 D WRITE^XWBRW($C(13,10))
 D WBF^XWBRW
 S XWBRBUF="",DONE=0,XWBICNT=0
 S XVALUE=$$DREAD($C(13,10)) I XVALUE'[200 S XVALUE=$P(XVALUE," ",2,3)
 I '$T S XVALUE=$$DREAD($C(13,10,13,10)),XVALUE=$$DREAD($C(13,10))
 D CLOSE ;I IO="|TCP|80" U IO D ^%ZISC
 Q $P(XVALUE,$C(13,10))
 ;
CLOSE ;
 D CLOSE^%ZISTCP,GETDEV^%ZISUTL("XUSBSE") I $L(IO) U IO
 Q
 ;
DREAD(D,TO) ;Delimiter Read
 N R,S,DONE,C,L
 N $ES,$ET S $ET="S DONE=1,$EC="""" Q"
 S R="",DONE=0,D=$G(D,$C(13)),C=0
 S TO=$S($G(TO)>0:TO,$G(XWBTIME(1))>0:XWBTIME(1),1:60)/2+1
 U XWBTDEV
 F  D  Q:DONE
 . S L=$F(XWBRBUF,D),L=$S(L>0:L,1:$L(XWBRBUF)+1),R=R_$E(XWBRBUF,1,L-1),XWBRBUF=$E(XWBRBUF,L,32000)
 . I (R[D)!(C>TO) S DONE=1 Q
 . R XWBRBUF:2 S:'$T C=C+1 S:$L(XWBRBUF) C=0
 . I $G(XWBDEBUG)>2,$L(XWBRBUF) D LOG^XWBDLOG($E("rd ("_$L(XWBRBUF)_"): "_XWBRBUF,1,255))
 . Q
 Q R
 ;
TRAP ;
 I '(($EC["READ")!($EC["WRITE")) D ^%ZTER
 D CLOSE,LOG^XWBDLOG("Error: "_$$EC^%ZOSV):$G(XWBDEBUG),UNWIND^%ZTER
 Q
 ;
 ;Test code below here
 ; MODIFY THE PROGRAM TO CHANGE THE 10.161.12.182 TO
 ; IP ADDRESSES FOR THE WORKSTATION WITH THE BSE SAMPLE
 ; SERVER
EN(ADDRESS) ; test with input address or 10.161.12.182 if none entered
 N VALUE,PAGE,SERVER,PORT
 S ADDRESS=$G(ADDRESS,"10.237.131.26")
 S PAGE="/",SERVER=ADDRESS,PORT=80
 I SERVER["/" D
 . I SERVER["//" S SERVER=$P(SERVER,"//",2)
 . I SERVER["/" S PAGE="/"_$P(SERVER,"/",2,99),SERVER=$P(SERVER,"/")
 . I SERVER[":" S PORT=$P(SERVER,":",2),SERVER=$P(SERVER,":")
 . Q
 S VALUE=$$ENTRY(SERVER,PORT,PAGE) ; $G(ADDRESS,"10.237.131.26"))
 D HOME^%ZIS ;I IO="|TCP|80" U IO D ^%ZISC
 W !,VALUE
 Q
 ;
EN1 ;
 D EN("10.237.131.26/page1.htm")
 Q
 ;
EN2 ;
 D EN("10.237.131.26/level2/page2.htm")
 Q
 ;
 ;
TESTPOST ;
 W !,$$POST("10.237.131.26","/","xVAL=XWBHDL851-487411_0")
 I IO="|TCP|80" U IO D ^%ZISC
 Q
 ;
 ;Sample of what IIS returns
 ;HTTP/1.1 200 OK
 ;Server: Microsoft-IIS/5.1
 ;Date: Mon, 12 Feb 2007 22:57:55 GMT
 ;X-Powered-By: ASP.NET
 ;X-AspNet-Version: 1.1.4322
 ;Set-Cookie: ASP.NET_SessionId=vsiqfgygjwsaru55bj4aik45; path=/
 ;Cache-Control: private
 ;Content-Type: text/html; charset=utf-8
 ;
 ;999999999^MONSON,STEVE^CLEVELAND VAMC^541^136672^^
 ;