VFDVFOI3 ;DSS/SGM - DIR PROMPT FOR SITE SPECIFIC DATA ;23AUG2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine was written by Document Storage Systems, Inc for the VSA
 ;This routine was written for the VSA for Cache only.
 ;It will perform much of the setup that is necessary
 ;to make the VA's FOIA Cache.dat ready for use on your
 ;system.
 ;
 ;This routine should be installed in your VAH account
 ;or your production account.  This routine is only to
 ;be called by VFDVFOIA
 ;
 ;DBIA# Supported References
 ;----- --------------------------------------------
 ; 2051 FIND^DIC, $$FIND1^DIC
 ;10006 ^DIC
 ;10026 ^DIR
 ;10104 $$UP^XLFSTR
 ;
A() N I,J,L,X,Y,Z,ARR,TAG,VDEV,VFDABORT,VFDVNUMB
 ;VFDVMODE="A" mode asks ALL;  "B" mode asks some and defaults those flagged with "b"
 F I=1:1:20 D ASK(I) Q:+$G(VFDABORT)  ;NOT ALL 20 QUESTIONS WILL BE THERE
 I '$D(VFDABORT) D TERM
 Q $G(VFDABORT)
 ;
ASK(I)  N VFDVLINE,VFDVPIEC,X,Y,M
 S TAG="A"_I,X=$T(@TAG) Q:X="" 
 S Y=$P(X,";",3),VFDV=$P(Y,"^") S M=$P(Y,"^",2),Y=$P(Y,"^",3),VFDVLINE=+Y,VFDVPIEC=$P(Y,",",2)
 D ARR(I)
 S X=-1
 I $D(ARR) D
 .I M'[VFDVMODE S:M[$$LOW^XLFSTR(VFDVMODE)&$D(ARR("B")) X=ARR("B") Q  ;Do not ask, but maybe take the default
 .S VFDVNUMB=$G(VFDVNUMB)+1
 .I VFDVLINE&VFDVPIEC S X=$TR($P($G(VFDTAB(VFDVLINE)),";",VFDVPIEC),"_")
 .E  S X=VFDV
 .W @IOF W !!!?12,"*****  QUESTION #",VFDVNUMB,": ",X,"  *****",!
 .S X=$$DIR(.ARR) ;HERE IS WHERE WE ASK
 I X<-1 S VFDABORT=1 Q
 I X=""!(X=-1)!(X=0) Q
 S:VFDV]"" VFDV(VFDV)=X ;STORE THE ANSWER
 I VFDVLINE,VFDVPIEC D S(VFDVLINE,VFDVPIEC) ;Store a tick in the VFDTAB array
 Q
 ;
 ;
ARR(L) ; setup ARR() to pass to $$DIR for question #L
 N I,J,K,X,Y,Z
 K ARR S K=0
 F J=0:1 S X=$P($T(@("A"_L)+J),";",3,99) Q:X=""  D
 .S Y=$S(J:$P(X,";"),1:0),Z=$P(X,";",2,99)
 .I Y="B" X Z I Z="" Q  ;DEFAULT IS EXECUTABLE STRING SETTING 'Z'
 .E  I Y'="a" S ARR(Y)=Z Q
 .S K=K+1,ARR("A",K)="   "_Z
 .Q
 I L=6 S (J,K)=0 D
 .F  S J=$O(^DD(8989.3,320,21,J)) Q:'J  S K=K+1,ARR("A",K)=^(J,0)
 .S K=K+1,ARR("A",K)="  "
 .Q
 Q
 ;
 ;
 ;
 ;
DIR(DIR) ; setup DIR prompt - return Y
 N I,X,Y,Z,DIERR,DIROUT,DIRUT,DTOUT,DUOUT,VFDVB,VFDVER
 S Y=-1 D ^DIR I Y=U S Y=-1
OUT Q $S($D(DTOUT):-3,$D(DUOUT):-2,1:Y)
 ;
 ;
 ;
 ;
S(L,P) N I D S^VFDVFOI2(L,P) Q
 ;
 ;
 ;
 ;
 ;
 ;
TERM ; get pointer to terminal type file
 N I,X,Y,Z,DIERR,VFDVER
 S X=$$FIND1^DIC(3.2,,"QX","C-VT320",,,"VFDVER")
 S VFDV("C-VT320")=$S(X>0:X,1:"")
 K DIERR,VFDVER
 S X=$$FIND1^DIC(3.2,,"QX","P-OTHER",,,"VFDVER")
 S VFDV("P-OTHER")=$S(X>0:X,1:"")
 Q
 ;
 ;
 ;
YN(A,B) ; yes/no/press return
 N Z
 S Z(0)="E",Z("A")="   Press <ENTER> to continue" W !
 I $G(A)'="" D  I '$D(Z) Q -1
 .S A=$G(A),B=$G(B)
 .S Z(0)="YO"_$S(A["?":"A",1:"")
 .S Z("A")=A,Z("B")=$P("NO^YES",U,1+B)
 .Q
 Q $$DIR(.Z)
 ;
 ;
ATAG(I) ;(DUMMY FOR CALLS FROM VFDVFOIJ)
 ;;subscript of VFDV ^VFDVMODE mode of entry(0 or 1) ^ co-ordinates of VFDTAB  ; DIR(0)
A1 ;;VOL^Ab^3,1;F^3:30^S:X?.E1L.E X=$$UP^XLFSTR(X)
 ;;A;Enter Volume name
 ;;a;Recommendation is to use the name of the Cache database that this
 ;;a;configuration is running
 ;;B;S Z=$G(^%ZOSF("VOL"))
 ;
A2 ;;DOMNAME^A^4,1;4.2,.01
 ;;A;Enter a new DOMAIN name
 ;;a;Create a new primary DOMAIN for your system
 ;;a;  Please enter a domain name for your system.
 ;;a;  Recommendation: use a subdomain of your domain name
 ;;a;  For example: for DSSINC.COM, this VistA server domain name could
 ;;a;               be FOIA.DSSINC.COM
 ;;a;  Each separate VistA configuration on your network will need its
 ;;a;  own VistA Domain name.
 ;;a;  This name may or may not be available via the Internet.  However,
 ;;a;  each VistA configuration requires a primary domain be set up
 ;;a; 
 ;;B;S Z=$O(^DIC(4.2,0)) S:$D(^(+Z,0)) Z=$P(^(0),U) 
 ;
 ;A3 ;;;NULL
 ;
 ;A4 ;;;TELNET
 ;
 ;A5 ;;0;HFS
 ;
A6 ;;DEFDIR^Ab^8,1;F^1:50^D DCK^VFDVFOI3
 ;;A;Enter a default HFS directory
 ;;B;S Z=$P($G(^XTV(8989.3,1,"DEV")),U) S:Z="" Z="c:\hfs\"
 ;
DCK ; check for NT or UNIX directory syntax
 N OS S OS="NT" I $T(OS^%ZOSV) S OS=$$OS^%ZOSV
 I OS="NT" D  Q
 .I X?1"\\"1A1.ANP1"\"1A1.ANP1"\" Q
 .I X?1A1":"1"\"1A1.ANP1"\" Q
 .K X
 Q
 ;
A7 ;;DNS^Ab^18,1;8989.3,51
 ;;A;Enter your DNS IP address
 ;;B;S Z=$P($G(^XTV(8989.3,1,"DNS")),U) S:Z="" Z="127.0.0.1"
 ;
A9 ;;INSTNUMB^Ab;FO^1:5^K:X'?1N.AN X
 ;;A;Enter a STATION NUMBER for your institution
 ;;B;S Z=$G(^DD("SITE",1)) I Z<100 F Z=101:1 Q:'$D(^DIC(4,"D",Z))
 ;
A8 ;;INSTNAME^AB^19,1;4,.01
 ;;A;Enter a name for your institution
 ;;a;The name must be 3-30 characters.
 ;;a;A new entry will be created in the INSTITUTION file.
 ;;a;This entry will be used as your default institution.
 ;;a;  
 ;
A4 ;;TZ^AB^8,2;4.3,1
 ;;A;Enter your time zone
 ;;B;S Z="EST"
 ;
A10 ;;PORT^A^10,2;N^9000:32000:0
 ;;A;Enter Port Number for Broker
 ;;B;S Z=9210
 ;;a;Enter the port number you would like the Broker to use
 ;;a;This value is stored in file 8994.1 RPC BROKER SITE PARAMETERS
 ;;a;  
 ;
 ;
 ;
 ;A11 ;;%SYS^A;SOM^1:%ZSTART;2:%ZSTOP;3:Both;0:Neither
 ;;A;Select create %SYS Routine option
 ;;B;0
 ;;a;Cache has two user defined system routines that will be run whenever
 ;;a;Cache is started or stopped.  This option will create those routines
 ;;a;if you so desire.
 ;;a;%ZSTART - if this routine exists in the %SYS namespace, Cache will
 ;;a;          run this routine at startup.  Cache will be looking for a
 ;;a;          specific line label in %ZSTART.  This created routine will
 ;;a;          run START^VFDVZSTU in the namespace you are running this
 ;;a;          program.  START^VFDVZSTU will start up Taskman.
 ;;a;
 ;;a;%ZSTOP - if this routine exists in the %SYS namespace, Cache will
 ;;a;         run this routine at shutdown.  This created routine will
 ;;a;         run STOP^VFDVZSTU in the namespace you are running this
 ;;a;         program.  STOP^VFDVZSTU will shutdown Taskman and other
 ;;a;         persistent VistA routines.
 ;;a;
 ;
 ;
 ;
A12 ;;AUDIT^Ab^;SOM^1:YES, Audit;2:NO, do not turn auditing on
 ;;A;Do you want to begin AUDITing selected files?
 ;;B;S Z="YES"
 ;
