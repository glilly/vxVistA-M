VFDPSUTL ;DSS/LM - Support Utility for Rx Processing ; 07/10/2012 17:05
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ;-----  --------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2056  ^DIQ: $$GET1, GETS
 ;10060  Fileman read of fields in file 200
 ;10056  Fileman read of fields in file 5
 ;10090  f
 ;10103  $$DT^XLFDT
 ; 3065  ^XLFNAME: $$STDNAME, $$NAMEFMT
 ;10104  $$UP^XLFSTR
 ; 2541  $$KSP^XUPARAM
 ;       Fileman read of all fields in files:
 ;10056      5
 ;10060    200
 ;10090      4
 ;       ----------  Unsupported Calls  ----------
 ;       Fileman read of files:  40.8, 44, 52, 52.41, 59, 100
 ;       Direct global read of ^PSRX
 ;       Direct global set of ^PSRX
 Q
SITE(VFDPOIEN) ;;Return Pharmacy OUTPATIENT SITE for order
 ; VFDPOIEN=ORDER IEN (File 100)
 ;
 N VFDPEN,VFDHLOC,VFDOLOC,VFDPRXEN,VFDMCD,VFDSITE
 ; 5/14/2009 If exactly one File 59 entry, return it regardless of order location
 S VFDSITE=$O(^PS(59,0)) I VFDSITE,'$O(^PS(59,VFDSITE)) Q VFDSITE ;One and only!
 ; End insert 5/14/2009
 Q:'$G(VFDPOIEN) ""
 S VFDPEN=$$FIND1^DIC(52.41,,"X",+VFDPOIEN,"B")
 S VFDPRXEN=$O(^PSRX("APL",+VFDPOIEN,"")) ;ORDER->PRESCRIPTION may be 1->MANY
 S:VFDPEN VFDHLOC=$$GET1^DIQ(52.41,VFDPEN,1.1,"I") ;If Pending
 S:'$G(VFDHLOC)&VFDPRXEN VFDHLOC=$$GET1^DIQ(52,VFDPRXEN,5,"I") ;If processed
 D:'$G(VFDHLOC)  ;ORDER:PATIENT LOCATION
 .S VFDOLOC=$$GET1^DIQ(100,+VFDPOIEN,6,"I")
 .S:$P(VFDOLOC,";",2)="SC(" VFDHLOC=+VFDOLOC
 .Q
 Q:'$G(VFDHLOC) ""
 Q $$PSITE(+VFDHLOC) ;VFDP*1.0*4 - Replacing next (unreachable)
 S VFDMCD=$$GET1^DIQ(44,VFDHLOC,3.5,"I")
 Q:'$G(VFDMCD) "" S VFDSITE=$$GET1^DIQ(40.8,VFDMCD,21600.01,"I")
 Q VFDSITE
 ;
ADR(VFDPOIEN,VFDPXIEN,VFDP) ;;Patient location specific OUTPATIENT SITE address
 ; VFDPOIEN=ORDER IEN (File 100)
 ; VFDPXIEN=PRESCRIPTION IEN (File 52)
 ; VFDP=[Optional] LVN of target, defaults to PSOLBL
 ; 
 ; Either VFDPOIEN or VFDPXIEN is required
 ; 
 ; VFDP*1.0*2 - Use INSTITUTION:RX PRINT ADDRESS, if possible 
 N VFDSUB S VFDP=$G(VFDP,"PSOLBL"),VFDP=$NA(@VFDP) Q:$E(VFDP)="^"  ;Target
 F VFDSUB="CNAME","CPNAME","CADD1","CADD2","CADD3","CPHONE #","CPHONE1 #","CPHONE2 #","CPHONE3 #","CZIP","CCITY","CSTATE" D
 .K @VFDP@(VFDSUB) ;Clear
 .Q
 D IADR(.VFDPOIEN,.VFDPXIEN,.VFDP) Q:$L($G(@VFDP@("CNAME")))  ;RX PRINT ADDRESS
 ; End VFDP*1.0*2 - If no RX PRINT ADDRESS, fall through to File 59 address
 ; 
 I $G(VFDPXIEN),'$G(VFDPOIEN) S VFDPOIEN=$$GET1^DIQ(52,+VFDPXIEN,39.3,"I")
 Q:'$G(VFDPOIEN)  N VFDSITE S VFDSITE=$$SITE(+VFDPOIEN) Q:'VFDSITE
 ; The rest is copied from routine ^VFDPOAE (DSS/WLC)
 D GETS^DIQ(59,VFDSITE_",","**","","VFDARR")
 S VFDREF=$NA(VFDARR(59,""_VFDSITE_","_""))
 S @VFDP@("CNAME")=@VFDREF@(.01)
 S @VFDP@("CADD1")=@VFDREF@(.02)
 S @VFDP@("CPHONE #")="("_@VFDREF@(.03)_") "_@VFDREF@(.04)
 S @VFDP@("CZIP")=@VFDREF@(.05)
 S @VFDP@("CCITY")=@VFDREF@(.07)
 S @VFDP@("CSTATE")=@VFDREF@(.08)
 Q
INST(VFDPOIEN,VFDPXIEN) ;[Private] Patient-location INSTITUTION
 ; VFDPOIEN=ORDER IEN (File 100)
 ; VFDPXIEN=PRESCRIPTION IEN (File 52)
 ; 
 ; Either VFDPOIEN or VFDPXIEN is required
 ; 
 I $G(VFDPXIEN),'$G(VFDPOIEN) S VFDPOIEN=$$GET1^DIQ(52,+VFDPXIEN,39.3,"I")
 Q:'$G(VFDPOIEN) ""
 N VFDHLOC S VFDHLOC=$$GET1^DIQ(100,VFDPOIEN,6,"I")
 S VFDHLOC=$S(VFDHLOC[";SC(":+VFDHLOC,1:"") Q:'VFDHLOC ""
 Q $$GET1^DIQ(44,VFDHLOC,3,"I")
 ;
IADR(VFDPOIEN,VFDPXIEN,VFDP) ;[Private] INSTITUTION -> VFD ADDRESS
 ; VFDPOIEN=ORDER IEN (File 100)
 ; VFDPXIEN=PRESCRIPTION IEN (File 52)
 ; VFDP=[Optional] LVN of target, defaults to PSOLBL
 ; 
 ; Either VFDPOIEN or VFDPXIEN is required
 ;
 N VFDINST S VFDINST=$$INST(.VFDPOIEN,.VFDPXIEN) Q:'VFDINST
 N VFDAIEN
 ; 7/19/2010 - Use File 21612 pointer to File 4
 S VFDAIEN=$$AP4^VFDADR1(+VFDINST,1)
 ; 7/19/2010 - End insert
 S VFDAIEN=$$GET1^DIQ(4,VFDINST,21612.01,"I") ;Rx VFD ADDRESS IEN
 Q:'VFDAIEN!(VFDAIEN=21612.01)  S VFDP=$G(VFDP,"PSOLBL"),VFDP=$NA(@VFDP) Q:$E(VFDP)="^"  ;Target
 N VFDADR,VFDSUB D GETS^DIQ(21612,VFDAIEN,"*",,$NA(VFDADR))
 N VFDR S VFDR=$NA(VFDADR(21612,VFDAIEN_",")) D
 .S @VFDP@("CNAME")=@VFDR@(.01)
 .S @VFDP@("CPNAME")=@VFDR@(.03) ;1.0*2 (T1)
 .S @VFDP@("CADD1")=@VFDR@(.111)
 .S @VFDP@("CADD2")=@VFDR@(.112)
 .S @VFDP@("CADD3")=@VFDR@(.113)
 .S @VFDP@("CPHONE #")=@VFDR@(.131) ;PHONE (1)
 .S @VFDP@("CPHONE1 #")=@VFDR@(.131) ;PHONE (1) ;1.8*2 (T1)
 .S @VFDP@("CPHONE2 #")=@VFDR@(.132) ;PHONE (2) ;1.8*2 (T1)
 .S @VFDP@("CPHONE3 #")=@VFDR@(.133) ;PHONE (3) ;1.8*2 (T1)
 .S @VFDP@("CZIP")=@VFDR@(.116)
 .S @VFDP@("CCITY")=@VFDR@(.114)
 .S @VFDP@("CSTATE")=@VFDR@(.115)
 .Q
 Q
PSRXIEN() ;;Next available IEN in File 52
 ; Called by ^VFDPSOR
 ; 
 N X L +^PSRX(0):2 E  Q "" ;File in use
 S X=$O(^PSRX(" "),-1)+1 S ^PSRX(X,0)=""
 S $P(^PSRX(0),U,3)=X,$P(^(0),U,4)=$P(^(0),U,4)+1
 L -^PSRX(0) Q X
 ;
LICENSE(VFDRSLT,VFDUZ) ;;Return license data for user VFDUZ
 ; VFDUZ=NEW PERSON IEN
 ; VFDRSLT=Results array.  VFDRSLT=number of entries
 ;                         VFDRSLT(1)=LICENSE#^STATE ABBREVIATION
 ;                         VFDRSLT(2)=Etc.
 ;                         
 ; Rules:
 ; 
 ;   1) Exclude expired [EXPIRATION DATE exists and DT > EXPIRATION DATE].
 ;   2) If one and only one [non-expired] license, return that one.
 ;   3) Return [non-expired] license(s) for default institution:state.
 ;   4) Return all [non-expired] licenses.
 ;
 Q:'$G(VFDUZ)  ;Invalid user
 N VFDATA D GETS^DIQ(200,+VFDUZ,"54.1*","IN",$NA(VFDATA))
 Q:'$D(VFDATA)  ;No license data for specified user
 N VFDCNT,VFDFLT,VFDT,VFDIENS S VFDCNT=0,VFDFLT=0,VFDT=$$DT^XLFDT
 ; Steve wants a generic RPC for default institution IEN and attributes.
 ; To do: Replace next with call to generic VFD RPC
 N VFDINST S VFDINST=$$KSP^XUPARAM("INST")
 N VFDEFST S VFDEFST=$S(VFDINST:$$GET1^DIQ(4,VFDINST,.02,"I"),1:"") ;INST:STATE
 ; Pre-analysis
 S VFDIENS="" F  S VFDIENS=$O(VFDATA(200.541,VFDIENS)) Q:'VFDIENS  D
 .I $G(VFDATA(200.541,VFDIENS,2,"I")),VFDT>VFDATA(200.541,VFDIENS,2,"I") ;Expired
 .I  K VFDATA(200.541,VFDIENS) Q  ;Exclude
 .S VFDCNT=1+VFDCNT ;Total non-expired licenses
 .I VFDEFST,VFDEFST=VFDATA(200.541,VFDIENS,.01,"I") ;STATE=KSP INSTITUTION:STATE
 .I  S VFDFLT=1+VFDFLT,VFDFLT(VFDIENS)="" ;Default STATE license
 .Q
 ; End pre-analysis
 Q:'VFDCNT  ;No non-expired license data
 N VFDI,VFDST,VFDR
 I VFDCNT=1 D  Q  ;Return one and only one non-expired license
 .S VFDIENS=$O(VFDATA(200.541,0)),VFDR=$NA(VFDATA(200.541,VFDIENS))
 .S VFDST=$$GET1^DIQ(5,+$G(@VFDR@(.01,"I")),1)
 .S VFDRSLT=1,VFDRSLT(1)=$G(@VFDR@(1,"I"))_U_VFDST_U_$G(@VFDR@(2,"I"))
 .Q
 I VFDFLT S VFDRSLT=VFDFLT D  Q  ;Has license(s) for default state
 .S VFDIENS="" F VFDI=1:1 S VFDIENS=$O(VFDFLT(VFDIENS)) Q:'VFDIENS  D
 ..S VFDR=$NA(VFDATA(200.541,VFDIENS))
 ..S VFDST=$$GET1^DIQ(5,+$G(@VFDR@(.01,"I")),1)
 ..S VFDRSLT(VFDI)=$G(@VFDR@(1,"I"))_U_VFDST_U_$G(@VFDR@(2,"I"))
 ..Q
 .Q
 S VFDRSLT=0 D  Q  ; Return all
 .S VFDIENS="" F VFDI=1:1 S VFDIENS=$O(VFDATA(200.541,VFDIENS)) Q:'VFDIENS  D
 ..S VFDR=$NA(VFDATA(200.541,VFDIENS))
 ..S VFDST=$$GET1^DIQ(5,+$G(@VFDR@(.01,"I")),1),VFDRSLT=VFDI
 ..S VFDRSLT(VFDI)=$G(@VFDR@(1,"I"))_U_VFDST_U_$G(@VFDR@(2,"I"))
 ..Q
 .Q
 Q
DEA(VFDUZ) ;;Return DEA number
 ; VFDUZ=NEW PERSON IEN
 ; 
 ; Return format DEA#^EXPIRATION DATE (internal format)^EXPIRED FLAG
 ; 
 Q:'$G(VFDUZ) "" ;Invalid user
 N VFDEA,VFDT,VFDXDT S VFDT=$$DT^XLFDT
 S VFDEA=$$GET1^DIQ(200,+VFDUZ,53.2),VFDXDT=$$GET1^DIQ(200,+VFDUZ,747.44,"I")
 Q VFDEA_U_VFDXDT_U_(VFDXDT]""&(VFDT>VFDXDT))
 ;
NPI(VFDUZ) ;;Return National Provider Identifier
 ; VFDUZ=NEW PERSON IEN
 ; 
 ; Return format NPI^EXPIRATION DATE (internal format)
 ; 
 N VFDI,VFDY,VFDZ S VFDY="" Q:'$G(VFDUZ) VFDY
 S VFDY=$$GET1^DIQ(200,VFDUZ,41.99) Q:$L(VFDY) VFDY  ;9/16/2008 - Added
 S VFDI=0 F  S VFDI=$O(^VA(200,+VFDUZ,21600,VFDI)) Q:'VFDI  D
 .S VFDZ=$G(^(VFDI,0)) Q:'($$UP^XLFSTR($P(VFDZ,U,5))?1"NPI".E)
 .S VFDY=VFDY_$S($L(VFDY):U,1:"")_$P(VFDZ,U,2,3)
 .Q
 Q VFDY
 ;
PSITE(VFDHLOC) ;Return OUTPATIENT SITE corresponding to given HOSPITAL LOCATION
 ; Rx autofinish patch VFDP*1.0*4
 ; VFDHLOC=[Required] HOSPITAL LOCATION IEN
 ; 
 ; Return=OUTPATIENT SITE IEN or NULL if not computable
 ;
 Q:'$G(VFDHLOC) ""  N VFDY
 S VFDY=$$GET1^DIQ(44,+VFDHLOC,22900,"I") S:VFDY=22900 VFDY=""
 Q:VFDY VFDY
 ; File 44 field #22900 not defined.  Try DIVISION pointer
 N VFDMCD S VFDMCD=$$GET1^DIQ(44,+VFDHLOC,3.5,"I")
 I VFDMCD S VFDY=$$GET1^DIQ(40.8,+VFDMCD,21600.01,"I") S:VFDY=21600.01 VFDY=""
 Q:VFDY VFDY
 ; File 44 field 3.5 -> File 40.8 field 21600.01 not useable. Try INSTITUTION pointer
 N VFDXNST S VFDXNST=$$GET1^DIQ(44,+VFDHLOC,3) ; INSTITUTION External format
 Q:'$L(VFDXNST) ""
 Q $$FIND1^DIC(59,,"X",VFDXNST,"D") ;Exact match to RELATED INSTITUTION
 ;
PAT(IENS) ; get patient demographics [From SGM modification to ^VFDPOAF]
 N X,Y,Z,VFDTMP K PATDEM
 D DEM^VFDCDPT(.VFDTMP,IENS)
 S Z("PAT NAME")=VFDTMP(1)
 S Z("PAT AD L1")=VFDTMP(11)
 S Z("PAT AD L2")=VFDTMP(12)
 S Z("PAT AD L3")=VFDTMP(13)
 S Z("PAT AD CITY")=VFDTMP(14)
 S X=VFDTMP(15) S:$P(X,U,3)'="" X=$P(X,U,3) S Z("PAT AD STATE")=X
 S X=VFDTMP(16) S:$P(X,U,2)'="" X=$P(X,U,2) S Z("PAT AD ZIP")=X
 S Z("PAT DOB")=$P(VFDTMP(3),";",2)
 S Z("PHONE #")=VFDTMP(18)
 M PATDEM=Z
 Q
 ;
SET(LBL,VAL) ; [From SGM modification to ^VFDPOAF]
 N X S X=LBL S:$G(VAL)'="" X=X_U_VAL
 S CNT=CNT+1,@VFDPBA@(REC,CNT)=X
 Q
NAMEFMT(VFDUZ) ;;Wraps calls to ^XLFNAME
 ; VFDUZ=NEW PERSON IEN
 ; 
 ; Return $$NAMEFMT^XLFNAME default format
 ;
 Q:'$G(VFDUZ) "" ;Invalid user
 N VFDNAME S VFDNAME=$$GET1^DIQ(200,+VFDUZ,.01) Q:'$L(VFDNAME) ""
 D STDNAME^XLFNAME(.VFDNAME,"FC") Q:'($D(VFDNAME)>1) ""
 Q $$NAMEFMT^XLFNAME(.VFDNAME)
 ;
TEXT(VFDRSLT,VFDNUM) ;;VFD PS NUMBER TO TEXT
 ; VFDNUM=non-negative integer
 ;
 S VFDRSLT=$$NUMTOTXT($G(VFDNUM))
 Q
 ;
 ;-----------------------  Private Subroutines  -----------------------
NUMTOTXT(N) ;;[Private] Recursive number to text
 ; N=non-negative integer
 ;
 Q:'(N?1.N) ""
 N Y S Y=""
 I N<13 S Y=$S(N=0:"zero",N=1:"one",N=2:"two",N=3:"three",N=4:"four",N=5:"five",N=6:"six",N=7:"seven",N=8:"eight",N=9:"nine",N=10:"ten",N=11:"eleven",N=12:"twelve",1:"") Q Y
 I N<20 S Y=$S(N=13:"thir",N=14:"four",N=15:"fif",N=16:"six",N=17:"seven",N=18:"eigh",N=19:"nine",1:"")_"teen" Q Y
 N N1,N2
 I N<100 S N1=N\10,N2=N#10 S Y=$S(N1=2:"twen",N1=3:"thir",N1=4:"for",N1=5:"fif",N1=8:"eigh",1:$$NUMTOTXT(N1))_"ty" S:N2 Y=Y_"-"_$$NUMTOTXT(N2) Q Y
 I N<1000 S N1=N\100,N2=N#100 S Y=$$NUMTOTXT(N1)_" hundred" S:N2 Y=Y_" "_$$NUMTOTXT(N2) Q Y
 I N<1000000 S N1=N\1000,N2=N#1000 S Y=$$NUMTOTXT(N1)_" thousand" S:N2 Y=Y_" "_$$NUMTOTXT(N2) Q Y
 S N1=N\1000000,N2=N#1000000 S Y=$$NUMTOTXT(N1)_" million" S:N2 Y=Y_" "_$$NUMTOTXT(N2) Q Y
 ;
