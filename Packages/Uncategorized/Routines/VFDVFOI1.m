VFDVFOI1 ;DSS/SGM - SETUP VA FOIA CACHE.DAT ;23AUG2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine was written by Document Storage Systems, Inc for the VSA
 ;This routine was written for the VSA for Cache only.  It will perform
 ;much of the setup that is necessary to make the VA's FOIA Cache.dat
 ;ready for use on your system.
 ;
 ;This routine should be installed in your VAH account or your production
 ;account.  This routine is only to be called by VFDVFOI*
 ;
 ;DBIA# Supported References
 ;----- --------------------------------------------
 ; 2050 MSG^DIALOG
 ; 2051 $$FIND1^DIC
 ; 2053 ^DIE: FILE, UPDATE
 ; 2056 $$GET1^DIQ
 ;10013 ^DIK
 ;10096 Execute ^%ZOSF nodes
 ;10097 GETENV^%ZOSV
 ;
 ;
 ;
D1 ; get environment
 N Y D GETENV^%ZOSV S VFDV("ENV")=Y D S(2,1) Q
 ;
 ;
 ;
D2 ; set some %zosf nodes
 N X S X=$$ENV(1)
 I X'="" S ^%ZOSF("PROD")=X,^%ZOSF("MGR")=X D S(9,1)
 Q
 ;
 ;
 ;
D3 ; %zosf("vol")
 N X S X=$G(VFDV("VOL"))
 I X'="" S ^%ZOSF("VOL")=X D S(10,1),D1
 Q
 ;
 ;
 ;
D4 ; clean up Taskman globals
 K ^%ZTSCH,^%ZTSK S ^%ZTSK(0)="TASKS^14.4" D S(11,1) Q
 ;
 ;
 ;
D5 ; update the VOLUME file with VFDV("VOL")
 N I,X,Y,Z,VOL S VOL=$G(VFDV("VOL")) Q:VOL=""
 S X=$$DEL(14.5) I X>0 D S(12,1)
 I $$UPD(1)>0 D S(13,1)
 Q
 ; set up Z() for UPD
Z1 S FILE=14.5
 S Z(.01)=VOL,Z(5)=$$ENV(1)
 S Z(.1)="G",Z(1)="N",Z(2)="Y",Z(3)="N",Z(6)=1,Z(9)=1
 Q
 ;
 ;
 ;
D6 ; delete then add Taskman site params
 N I,X,Y,Z,DA,DIK,TEXT
 S X=$$DEL(14.7) I X>0 D S(14,1)
 I $$UPD(2)>0 D S(15,1)
 Q
Z2 S FILE=14.7
 S Z(.01)=$$ENV(4)
 S Z(4)=256,Z(5)=30,Z(6)=50,Z(7)=1,Z(8)="G",Z(10)=0,Z(11)=1
 Q
 ;
 ;
 ;
 ;
D7 ; initialize Fileman
 D ^DINIT,S(16,1) Q
 ;
 ;
 ;
D8 ; initialize kernel
 D ^ZTMGRSET,S(17,1) Q
 ;
 ;
 ;
D9 ; clean up domain file [4.2]
 N I,X,Y,Z,VDOM,DA,DIE,DR
 I $G(VFDV("DOMNAME"))="" S X=$G(VFDV("INSTNAME")) Q:X=""  S VFDV("DOMNAME")="FOIA."_X_".COM" ;CREATE DOMAIN NAME FROM INSTITUTION!
 S DIE=4.2,(VFDV("DOM",0),DA)=$O(^DIC(4.2,0)),DR=".01///"_VFDV("DOMNAME") D ^DIE D  D S(4,2) ;domain NAME
 .F DA=0:0 S DA(1)=VFDV("DOM",0),DIK="^DIC(4.2,"_DA(1)_",2,",DA=$O(^DIC(4.2,DA(1),2,0)) Q:DA'>0  D ^DIK ;DELETE SYNONYMS
 S VDOM=$G(VFDV("DOMNAME"))
 S VDOM("VISTA.PLATINUM.MED.VA.GOV")=""
 S VDOM("FORUM.VA.GOV")="",VDOM("FORUM.MED.VA.GOV")=""
 S VDOM("VISTA.MED.VA.GOV")="",VDOM("GOV")=""
 S VDOM(VDOM)=""
 S I=0
 F  S I=$O(^DIC(4.2,I)) Q:'I  S X=$P(^(I,0),U) I '$D(VDOM(X)) Q:'$$DEL(4.2,I)  ;DELETE MOST DOMAINS
 D S(2,2) S I=0
 F  S I=$O(^DIC(4.2,I)) Q:'I  S Y=$P(^(I,0),U,2) S:Y'="C" X=$$FILE(1,I) ;All domains: C = MailMan will not allow users to address mail to this domain
 D S(3,2)
 I $$FILE(3,VFDV("DOM",0))>0 S X=$$UPD(4) ;TRANSMISSION SCRIPT multiple
 Q
Z4 S FILE=4.21
 S Z(.01)="TCP/IP",Z(1.1)=30,Z(1.2)="SMTP",Z(1.4)="127.0.0.1"
 F I=0:0 S I=$O(^%ZIS(1,"B","NULL",I)) Q:'I  S X=$O(^(I,0)) Q:'X
 S:I Z(1.3)="NULL"
 S Z(2)="VFDVB"
 S VFDVB(1)="O H="_VDOM_",P=TCP/IP-MAILMAN"
 S VFDVB(2)="C TCPCHAN-SOCKET25/NT"
 M VFDVA(4.21,"?+1,"_VFDV("DOM",0)_",")=Z ;MAY BE ^DIC(4.2,2)!
 S VIEN(1)=""
 Q
 ; set up Z() for FILE
F1 S FILE=4.2,Z(1)="C" Q
F3 S FILE=4.2,Z(1)="S",Z(1.7)="n" Q
 ;
 ;
 ;
 ;
D11 ; create a new INSTITUTION
 N X S X=$G(VFDV("INSTNAME")) Q:X=""
 S X=$O(^DIC(4,"B",X,""),-1) I 'X S X=$$UPD(8)
 I X>0 S VFDV("INST",0)=X I $$FILE(8,X) D S(20,1) ;need this below in Z17+4 & for ^IBE(350.9)
 Q
F8 ;
Z8 S FILE=4,Z(.01)=VFDV("INSTNAME"),Z(11)="L",Z(13)=1,Z(99)=$G(VFDV("INSTNUMB"),888),X=+$G(VFDV("DOM",0)) S:X Z(60)=X ;STATUS=LOCAL;FACILITY TYPE=MC;NUMBER=888
 S VIEN(1)="" Q  ;WE DON'T CARE WHAT IEN IT IS
 ;
 ;
 ;
D12 ; update KERNEL SYSTEM PARAMETERS (8989.3)
 N I,X,Y,Z,TEST,VFDVA
 S TEST=$D(^XTV(8989.3,1))
 I 'TEST,'$G(VFDV("DOM",0)) Q
 S:'TEST X=$$UPD(9) S:TEST X=$$FILE(9,1)
 Q:X<1  D S(20,2)
 F I=0:0 S I=$O(^XTV(8989.3,1,4,I)) Q:'I  S X=$$FILE(12,I_",1")
 I $G(VFDV("VOL"))'="" S X=$$UPD(10)
 Q
F9 ;
Z9 S FILE=8989.3
 S Z(.01)=$G(VFDV("DOM",0))
 S Z(9)="O",Z(9.8)="a",Z(31.1)=9999999
 S X=$G(VFDV("DNS")) S:X="" X="127.0.0.1" S Z(51)=X
 S Z(202)=5,Z(203)=600,Z(204)=1,Z(205)=1,Z(206)=0,Z(209)="Y",Z(210)=300
 S Z(211)=0,Z(214)=90,Z(218)=0,Z(230)=3600,Z(501)=0 ;,Z(503)=$$SID^%ZOSV NO!
 S X=$G(VFDV("DEFDIR")),Z(320)=$S(X'="":X,1:"")
 S X=$G(VFDV("INST",0)) S:X Z(217)=X
 Q
F12 S FILE=8989.304,Z(.01)="@" Q
Z10 S FILE=8989.304
 S VFDVA(FILE,"+1,1,",.01)=VFDV("VOL")
 S VFDVA(FILE,"+1,1,",2)=256
 Q
 ;
 ;
 ;
D13 ; update MAILMAN SITE PARAM (4.3)
 N I,X,Y,Z,TEST,VFDVA
 S TEST=$D(^XMB(1,1))
 I '$G(VFDV("DOM",0)) Q
 S:'TEST X=$$UPD(11) S:TEST X=$$FILE(11,1)
 Q:X<1  S X=VFDV("DOM",0) X ^DD(4.3,.01,1,3,1) ;^XMB("NETNAME") AND ^("NAME")
 D S(9,2)
 Q
Z11 S FILE=4.3
 S Z(.01)=$G(VFDV("DOM",0))
 S X=$G(VFDV("TZ")),Y=$O(^XMB(4.4,"B","EST",0)) S:X!Y Z(1)=$S(X:+X,1:Y)
 S Z(4)=DT,Z(40)=1 I $O(^%ZIS(1,"B","NULL",0)) S Z(8.25)="NULL"
 S VIEN(1)=1 ;MUST BE ^XMB(1,1)
 Q
F11 D Z11 Q
 ;
 ;
 ;
D14 ; update RPC BROKER SITE PARAMS (8994.1)
 N I,X,Y,Z
 I '$G(VFDV("DOM",0)) Q
 S X=$P(^XWB(8994.1,0),U,1,2) K ^XWB(8994.1) S ^XWB(8994.1,0)=X
 I $$UPD(12)>0 D S(11,2)
 Q
Z12 S FILE=8994.1
 S VFDVA(8994.1,"+1,",.01)=VFDV("DOM",0)
 S X=+$O(^%ZIS(14.7,0)) I X D
 .S VFDVA(8994.17,"+2,+1,",.01)=X
 .S X=$G(VFDV("PORT")) S:'X X=9210
 .S VFDVA(8994.171,"+3,+2,+1,",.01)=X
 .S VFDVA(8994.171,"+3,+2,+1,",2)=1
 .Q
 Q
 ;
 ;
 ;
 ;
D15 ; create VFDV SYS MGMT mail group
 N I,X,Y,Z
 S X=$O(^XMB(3.8,"B","VFDV SYS MGMT",""),-1) I 'X S X=$$UPD(15)
 I X>0 S VFDV("MG")=+X D S(12,2)
 Q
Z15 ;
 ;;This mail group was set up by the VSA program that initializes the
 ;;VA's FOIA Cache.dat.  POSTMASTER is added as a member.  The purpose
 ;;of this mail group was to have a group to receive system related
 ;;messages.  Several of the VistA processes expected a mail group
 ;;with active users in it.
 N I
 S FILE=3.8,VIEN(1)=""
 S Z(.01)="VFDV SYS MGMT",Z(4)="PU",Z(7)="n",Z(10)=0
 M VFDVA(FILE,"+1,")=Z K Z
 S VFDVA(3.81,"+2,+1,",.01)=.5
 K VFDVB S VFDVA(FILE,"+1,",3)="VFDVB"
 F I=1:1:5 S VFDVB(I)=$P($T(Z15+I),";",3)
 Q
 ;
 ;
 ;
D16 ; add VFDV SYS MGMT to bulletins
 ;;XTRMON
 ;;
 N I,X,Y,Z,VSUC,VN S VSUC=0
 Q:'$G(VFDV("MG"))
 F I=1:1 S X=$P($T(D16+I),";",3) Q:X=""  D
 .S VN=+$O(^XMB(3.6,"B",X,0)) Q:'VN
 .Q:$D(^XMB(3.6,VN,2,"B",VFDV("MG")))
 .I $$UPD(16)>0 S VSUC=1
 .Q
 I VSUC D S(13,2)
 Q
Z16 S FILE=3.62,VIEN(1)=""
 S VFDVA(3.62,"+1,"_VN_",",.01)=VFDV("MG")
 Q
 ;
 ;
 ;
D17 ; init HL files
 N I,J,X,Y,Z
 S X=$$DEL(869.3,1) I X>0,$$UPD(17)>0 D S(14,2)
 I $$DEL(772)>0 D S(15,2)
 I $$DEL(773)>0 D S(16,2)
 F I=0:0 S I=$O(^HLCS(870,I)) Q:'I  D
 .S X=$$FILE(17,I),J=0
 .F  S J=$O(^HLCS(870,I,1,J)) Q:'J  S X=$$FILE("17A",J_","_I)
 .S J=0
 .F  S J=$O(^HLCS(870,I,2,J)) Q:'J  S X=$$FILE("17B",J_","_I)
 .Q
 D S(17,2),S(18,2):$$UPD("17A")>0
 Q
F17 S FILE=870,Z(4.5)=0
 N J F J=5:1:11,400.06 S Z(J)="@"
 Q
F17A S FILE=870.019,Z(.01)="@" Q
F17B S FILE=870.01,Z(.01)="@" Q
Z17 S FILE=869.3
 S Z(.01)=1,Z(.03)="T",Z(11)=1,Z(12)=1
 S Z(41)=14,Z(42)=30,Z(43)=90,Z(44)=90,Z(51)=15
 S X=$G(VFDV("DOM",0)) S:+X Z(.02)=X
 S X=$G(VFDV("INST",0)) S:X Z(.04)=X
 Q
Z17A S FILE=870,VIEN(1)=""
 S Z(.01)="LL999CIVH",Z(2)=4,Z(3)="MS",Z(4.5)=1,Z(21)=10
 S Z(400.02)=5000,Z(400.03)="M",Z(400.04)="N"
 Q
 ;
 ;
 ;
D20 ; set ^DD("SITE")
 N X
 S X=$G(VFDV("INSTNAME")) I X]"" S ^DD("SITE")=X
 S X=$G(VFDV("INSTNUMB")) S:'X X=888 S ^("SITE",1)=X D S(22,1)
 Q
 ;
 ;
 ;
D22IVM ;FILE 301.9
 Q:'$G(VFDV("INSTNUMB"))
 S X=$$DEL(301.9)
 I $$UPD(22)
 Q
Z22 S VIEN(1)=1,FILE=301.9,Z(.01)=VFDV("INSTNUMB"),Z(.03)=1,Z(.05)=1,Z(.06)=2960823,Z(.08)=0,Z(15)=0,Z(20)=0
 S X=$O(^XMB(3.8,"B","IVM MESSAGES",0)) I X S Z(.02)=X
 S X=$O(^XMB(3.8,"B","DGEN ELIGIBILITY ALERT",0)) I X S Z(.09)=X
 Q
 ;
 ;
 ;
 ;
 ;
 ;
 ;---------------  subroutines  ---------------
DEL(F,DA) ; delete some or all entries in a file
 N I,X,Y,Z,DIK
 S DIK=$G(^DIC(F,0,"GL")) Q:DIK="" -1
 I $G(DA) D ^DIK
 I '$G(DA) F DA=0:0 S DA=$O(@(DIK_"DA)")) Q:'DA  D ^DIK
 Q 1
 ;
 ;
 ;
ENV(P) Q $P($G(VFDV("ENV")),U,P)
 ;
 ;
 ;
FILE(L,DA) ; file data for an existing entry, using 'F' tag
 N I,J,X,Y,Z,DIERR,FILE,VFDVA,VFDVER,VIEN
 Q:$G(L)<1 -1
 D @("F"_L)
 M VFDVA(FILE,DA_",")=Z K Z I '$D(VFDVA) Q -1
 D FILE^DIE(,"VFDVA","VFDVER") ;FILE INTERNAL VALUES
 S X=1 I $D(DIERR) D MSG S X=-1
 Q X
 ;
F13 D Z13 Q
F14 S FILE=19,X=VOPT(6),Z($P(X,U))=$P(X,U,2,99) Q
 ;
GET(FILE,IENS,FLD,VFDVA) ;
 N I,X,Y,DIERR,VFDVER
 I '$G(FILE)!'$G(IENS)!'$G(FLD) Q -1
 I $E(IENS,$L(IENS))'="," S IENS=IENS_","
 D GETS^DIQ(FILE,IENS,FLD,"I","VFDVA","VFDVER")
 S X=1 I $D(DIERR) K VFDVA S X=0
 Q X
 ;
 ;
 ;
 ;
 ;
MSG N X W ! D MSG^DIALOG("EW",,,,"VFDVER") S X=$$YN^VFDVFOI3
 Q
 ;
 ;
 ;
 ;
 ;
S(L,P) D S^VFDVFOI2(L,P) Q  ;tick in VFDTAB
 ;
 ;
 ;
 ;
 ;
UPD(L) ; add a new entry to a file, using 'Z' tag
 N I,X,Y,Z,DIERR,FILE,VFDVA,VFDVB,VFDVER,VIEN
 Q:$G(L)<1 -1
 D @("Z"_L)
 I '$D(VFDVA) M VFDVA(FILE,"+1,")=Z
 K Z I '$D(VFDVA) Q -1
 I '$D(VIEN(1)) S VIEN(1)=1
 D UPDATE^DIE(,"VFDVA","VIEN","VFDVER")
 S X=$G(VIEN(1)) I $D(DIERR) S X=$O(VFDVA(0)) W:X !,"UPDATING ",$P("SUB",1,'$D(^DIC(X))),"FILE ",X," ---" D MSG H 1 S X=-1
 Q X
 ;
 ;
 ;
 ;
Z13 S FILE=19.2,VIEN(1)="" ;OPTION SCHEDULING  --NOT USED?
 S:'VOPT Z(.01)=VOPT(0)
 I VOPT(1) S X=VOPT(3) S:+X Z(2)=X S:X?1"S".1U Z(9)=X
 S:VOPT(4)'="" Z(6)=VOPT(4)
 S:VOPT(5)'="" Z(15)=VOPT(5)
 Q
 ;
 ;
 ;
