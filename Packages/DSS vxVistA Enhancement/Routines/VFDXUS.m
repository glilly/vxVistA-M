VFDXUS ;DSS/LM - Kernel Signon Remote Procedure Calls
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 Q
CLONE(RESULT,FROM,LIST,TDT,FLDS,CLRFLG,CLRLST) ;;[Create and] clone NEW PERSON
 ; file entries from LIST.  Implements RPC: VFDXUS CLONE NEW PERSON
 ; 
 ; FROM=Template user IEN (required)
 ; LIST=Array of DUZ^NAME^SEX^SSN (required),
 ;      where either DUZ or the other 3 parameters are supplied
 ; TDT=Termination date.time (optional)
 ; FLDS=Array of supplementary fields to clone for each user (optional)
 ; CLRFLG=Flag indicating to pre-clear keys, files, and secondary menus
 ; CLRLST=Array of additional fields to pre-clear in target users
 ; 
 ; RESULT=0 for success or -1^Error message
 ;
 I $G(FROM),$D(^VA(200,+FROM)) S FROM=+FROM
 E  S RESULT="-1^Invalid template user" Q
 N XUTMP S XUTMP=FROM,XUTMP(0)=$$GET1^DIQ(200,FROM,.01) ;Setup for ^XUBLK
 N XUTERMDT S XUTERMDT=$G(TDT)
 I $D(LIST(1))#2
 E  S RESULT="-1^No target users" Q
 N NLIST,VFDI,VFDJ S VFDJ=0 F VFDI=1:1 Q:'$D(LIST(VFDI))  D:'LIST(VFDI)
 .S VFDJ=VFDJ+1,NLIST(VFDJ)=$P(LIST(VFDI),U,2,4)
 .Q
 I VFDJ D CREATE(.VFDNUSRS,.NLIST) I VFDNUSRS(1)<0 S RESULT=VFDNUSRS(1) Q
 I VFDJ N I,J S J=0 F I=1:1 Q:'$D(LIST(I))  D:'LIST(I)
 .S J=J+1,$P(LIST(I),U)=+VFDNUSRS(J)
 .Q
 I VFDJ,'(J=VFDJ) S RESULT="-1^New user checksum error" Q
 N VFDERR,VFDA,VFDR,XUSER S (VFDERR,XUSER)=0,RESULT="-1^General error"
 F VFDI=1:1 Q:'$D(LIST(VFDI))!VFDERR  D  ;Main processing loop
 .S VFDR="VFDA(200,"""_+LIST(VFDI)_","")" K VFDA ;FDA root
 .F VFDJ=1:1 Q:'$D(CLRLST(VFDJ))  D  ;Process Clear list
 ..S @VFDR@(+CLRLST(VFDJ))="@"
 ..Q
 .D:$D(VFDA) FILE^DIE(,"VFDA") ;Clear fields
 .N VFDX K VFDA
 .F VFDJ=1:1 Q:'$D(FLDS(VFDJ))  D  ;Process Supplementary fields list
 ..S VFDX=$$GET1^DIQ(200,FROM,FLDS(VFDJ),"I")
 ..S @VFDR@(FLDS(VFDJ))=$S(VFDX]"":VFDX,1:"@")
 ..Q
 .D:$D(VFDA) FILE^DIE(,"VFDA") ;Supplementary fields
 .S XUSER=VFDI
 .S XUSER(VFDI)=+LIST(VFDI)_U_$$GET1^DIQ(200,+LIST(VFDI),.01)_U_U_$G(CLRFLG)
 .Q
 S:'VFDERR RESULT=0
 D:XUSER  ;Schedule Task
 .N X,ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
    .S ZTDESC="VFDXUS Clone users",ZTDTH=$H,ZTIO="",ZTRTN="CLONE^XUSERBLK"
 .F X="XUTMP","XUTERMDT","XUSER","XUSER(" S ZTSAVE(X)=""
 .D ^%ZTLOAD S:'(ZTSK>0) RESULT="-1^Attempt to schedule task failed"
 .Q
 Q
CREATE(RESULT,LIST) ;;Create NEW PERSON file entries from LIST
 ; Implements RPC: VFDXUS CREATE NEW PERSON
 ; 
 ; LIST=Array of NAME^SEX^SSN of users to create
 ; 
 ; RESULT=Array of new user IEN's, or Result(1)=-1^Error message
 ; 
 S RESULT(1)="-1^No entrys to process"
 N VFDA,VFDERR,VFDI,VFDIENR,VFDMSGR,VFDR
 N DIC S (DIC,DIC(0))="" ;Anticipate LAYGO+1^XUA4A7
 S VFDR="VFDA(200,""+1,"")",VFDERR=0
 F VFDI=1:1 Q:'$D(LIST(VFDI))!VFDERR  D
 .K VFDA
 .S @VFDR@(.01)=$P(LIST(VFDI),U)
 .S @VFDR@(4)=$P(LIST(VFDI),U,2)
 .S @VFDR@(9)=$P(LIST(VFDI),U,3)
 .D UPDATE^DIE(,"VFDA","VFDIENR","VFDMSGR")
 .I $G(VFDIENR(1))>0 S RESULT(VFDI)=VFDIENR(1)
 .E  S VFDERR=1
 .Q
 S:VFDERR RESULT(1)="-1^Failed to create user "_VFDI_U_LIST(VFDI)
 Q
