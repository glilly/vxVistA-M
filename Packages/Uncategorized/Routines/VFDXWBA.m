VFDXWBA ;DSS/LM/SGM - BROKER AUDIT FOR HIPAA/CCHIT ; 06/23/2011 17:25
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 86
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is not to be invoked directly.  It is only invoked
 ;from the VFDXWB routine
 ;
 ; ICR#   SUPPORTED REFERENCES
 ;------  ------------------------------------------------------
 ;  767   Global read of $P(DG(38.1,DFN,0),U,2)
 ;           DSS not a controlled subscriber
 ; 2053   UPDATE^DIE
 ; 2263   $$GET^XPAR
 ; 2320   ^%ZISH: CLOSE, $$LIST, OPEN, $$PWD
 ;10013   ^DIK
 ;10103   ^XLFDT: $$FMADD, $$NOW
 ;        Global read of files
 ;         8994   - AVFD whole file index
 ;           
 ;------------------------  RPC AUDIT SUPPORT  ------------------------
 ;
ARCHIVE ;[Option] VFD RPC AUDIT ARCHIVE
 ; Come here from tasked option to copy/purge VFD RPC AUDIT LOG
 ;
 N VFDAYS,VFDEDT,VFDHNDL,VFDPATH,VFDFILE,VFDMODE,VFDSDT
 S VFDAYS=$$GET^XPAR("SYS","VFD RPC AUDIT DAYS-TO-KEEP")
 S:'VFDAYS VFDAYS=7 S VFDEDT=$$FMADD^XLFDT(DT,-VFDAYS,0,0,0)
 S VFDSDT=$P($O(^VFD(21615,"B",0)),".") Q:'VFDSDT!'(VFDSDT<VFDEDT)
 S VFDHNDL="VFD-"_$J
 S VFDPATH=$$GET^XPAR("SYS","VFD RPC AUDIT PATH")
 S:VFDPATH="" VFDPATH=$$PWD^%ZISH
 S VFDFILE="RPC-Audit-"_VFDSDT_"-"_VFDEDT_".txt"
 S VFDMODE=$S($$EXISTS(VFDPATH,VFDFILE):"A",1:"W")
 N IO,POP D OPEN^%ZISH(VFDHNDL,VFDPATH,VFDFILE,VFDMODE)
 I POP D XCPT($$NOW^XLFDT,"RPC Audit Archive","Open failed: "_VFDFILE) Q
 N VFDA,VFDFN,VFDI,VFDT,VFDX U IO
 S VFDT=VFDSDT
 F  S VFDT=$O(^VFD(21615,"B",VFDT)) Q:'VFDT!'(VFDT<VFDEDT)  D
 .S VFDA=0 F  S VFDA=$O(^VFD(21615,"B",VFDT,VFDA))  Q:'VFDA  D WRT,DIK
 .Q
 D CLOSE^%ZISH(VFDHNDL)
 ; Archive/Purge complete
 Q
 ;
 ;---------------------  called From LOG^XWBDLOG  ---------------------
 ;
RPCLOG ; called From LOG^XWBDLOG
 ; 6/22/2011/SGM - only logging RPCs if VFDDFN>0 (patient only)
 ; Mod to XWBTCPM inits to null or sets these variables
 ;   VFDDFN  VFDAUDIT,VFDPMODE,VFDUMODE, VFDHNDL
 ;     if +VFDPMODE or +VFDUMODE, then audit all patients or users
 ; Mod to DGSEC4 will set VFDDFN=DFN
 ; Field 21600.01 in file 8994 determines if RPC should be audited
 ; Data in file 21615, 21615.1 will determine if audit filed
 ; ^VFD(21615.1,1,1) = patients to be audited
 ; ^VFD(21615.1,1,2) = patients not to be audited
 ; ^VFD(21615.1,1,3) = users to be audited
 ; ^VFD(21615.1,1,4) = users not to be audited
 ;
 ; VFDIENS and VFDDFN() will be defined from the last time through this
 ; audit.  If patient context is the same, then add subsequent RPC logs
 ; to the DATA word processing field in the PATIENT multiple in the VFD
 ; RPC AUDIT LOG FILE.
 ;
 ; This module MUST guarantee that VFDIENS="" or VFDIENS="#," or
 ; VFDIENS="#,#,"
 ;
 Q:'$G(DUZ)
 N X,Y,Z
 ; filter out events not to be logged
 Q:$$FILTER
 ; filter guarantees that VFDDFN>0
 ;
 ; has patient context changed since last time?
 ;  first time through audit log, initialize VFDIENS
 I '$G(VFDDFN(0)) S VFDDFN(0)=VFDDFN,VFDIENS=""
 ; check if patient context has changed
 E  I VFDDFN'=VFDDFN(0) S VFDDFN(0)=VFDDFN,VFDIENS=""
 ;
 I 'VFDIENS D NEWLOG Q:'VFDIENS
 ;
 ; if first time through the audit, then vfdiens has 1 ","
 ; if second or subsequent time through audit, then vfdiens has 2 ","
 I $L(VFDIENS,",")=2 D NEWDFN Q:$L(VFDIENS,",")'=3
 D ADDREC
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ADDREC ; Add a data record
 ; VFDIENS is defined
 N X,Y,Z,VFD0,VFD1,VFDRPC,VFDX
 N X,Y,Z,V1,V2,RPC
 S RPC=0
 S V2=+VFDIENS,V1=+$P(VFDIENS,",",2)
 I 'V1!'V2!($G(MSG)="") Q
 S MSG=$$TR(MSG) I MSG?1"RPC: ".E D
 .S X=$P(MSG,"RPC: ",2) I X]"" S RPC=$O(^XWB(8994,"AVFD",X,0))
 .Q
 S:MSG?1"rd: [XWB]".E RPC=0 ;Skip next read
 Q:'RPC  ;RPC is not in audit list
 S:MSG?1"Call: ".E MSG=$$XP(MSG)
 S Y=$G(^VFD(21615,V1,1,V2,1,0)) S:Y="" Y="^^^^"_DT_U
 S Z=1+$P(Y,U,3),$P(Y,U,3,4)=Z_U_Z,^VFD(21615,V1,1,V2,1,0)=Y
 S ^VFD(21615,V1,1,V2,1,Z,0)=$H_U_MSG
 Q
 ;
DIK ; Purge one VFD RPC AUDIT LOG entry after archiving
 ; Variable VFDA required
 I $G(VFDA) N DA,DIK S DIK="^VFD(21615,",DA=VFDA D ^DIK
 Q
 ;
EXISTS(VFDPATH,VFDFILE) ; Test existence of path/file
 ; Return 1 if and only if path and file are specified and
 ; file exists in path.  Else return 0.
 I '$L($G(VFDPATH))!'$L($G(VFDFILE)) Q
 N VFDARR,VFDRET
 S VFDARR(VFDFILE)="" I $$LIST^%ZISH(VFDPATH,$NA(VFDARR),$NA(VFDRET))
 Q $O(VFDRET(""))[VFDFILE
 ;
FILTER() ; determine if RPC AUDIT record should be created or not
 ; Boolean extrinsic function, return 1 is no record to be filed
 ; User specific screens
 I VFDUMODE,'$D(^VFD(21615.1,1,3,"B",+DUZ)) Q 1
 I 'VFDUMODE,$D(^VFD(21615.1,1,4,"B",+DUZ)) Q 1
 ; Patient specific screens
 I VFDDFN<1 Q 1
 N X,Y S X=0,Y=VFDPMODE S:'Y Y=-1
 ; check to see if a Sensitive Patient
 I 13[Y,'$P($G(^DGSL(38.1,+VFDDFN,0)),U,2) S X=1
 ; check vxvista filters
 I 'X,13[Y,'$D(^VFD(21615.1,1,1,"B",+VFDDFN)) S X=1
 I 'X,Y=-1,$D(^VFD(21615.1,1,2,"B",+VFDDFN)) S X=1
 ; End screens
 I X S VFDDFN=""
 Q X
 ;
NEWDFN ; Create a new PATIENT multiple entry
 ; VFDIENS set in newlog
 ;
 N X,Y,Z,DIERR,VFD0,VFDA,VFDER,VFDIEN,VIEN
 S VIEN="?+1,"_VFDIENS
 S VFDA(21615.01,VIEN,.01)=+VFDDFN
 D UPDATE^DIE(,"VFDA","VFDIEN","VFDER")
 I '$D(DIERR) S VFDIENS=VFDIEN(1)_","_VFDIENS
 Q
 ;
NEWLOG ; Create a new log entry
 ; VFDHNDL and DUZ are defined
 N X,Y,Z,DIERR,VFDER,VFDFDA,VFDIEN,VFDR
 S VFDR=$NA(VFDFDA(21615,"+1,"))
 S @VFDR@(.01)=$P(VFDHNDL,"~")
 S @VFDR@(.02)=+DUZ
 S @VFDR@(.03)=$P(VFDHNDL,"~",2)
 D UPDATE^DIE(,"VFDFDA","VFDIEN","VFDER")
 I '$D(DIERR) S VFDIENS=$G(VFDIEN(1))_","
 Q
 ;
TR(X) ; Translate control characters in message
 ; Note: The following temporarily translates all control characters to "|".
 ;       To do: Revise translation to meaningful values
 Q $TR(X,$C(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31),"|||||||||||||||||||||||||||||||")
 ;
WRT ; Write one VFD RPC AUDIT LOG entry to archive file
 ; Assumes valid context
 Q:'$G(^VFD(21615,VFDA,0))  W ^(0),!
 S VFDFN=0 F  S VFDFN=$O(^VFD(21615,VFDA,1,VFDFN)) Q:'VFDFN  D
 .Q:'$G(^VFD(21615,VFDA,1,VFDFN,0))  W ^(0),!
 .F VFDI=1:1 Q:'$D(^VFD(21615,VFDA,1,VFDFN,1,VFDI,0))  W ^(0),!
 .Q
 W !
 Q
 ;
XCPT(VXDT,APPL,DESC,HLID,SVER,DATA,VFDXVARS) ; Record exception
 ; Wraps vxVistA exception handler
 Q:$T(XCPT^VFDXX)=""
 D XCPT^VFDXX(.VXDT,.APPL,.DESC,.HLID,.SVER,.DATA,.VFDXVARS)
 Q
 ;
XP(X) ; Expand parameters in X
 S X=$G(X)
 N %,I,PAR F I=0:1 S %=$NA(XWB(5,"P",I)) Q:'(X[%)  D
 .S PAR=$G(@(%))
 .S X=$P(X,%)_$S(PAR=+PAR:PAR,1:""""_PAR_"""")_$P(X,%,2)
 .Q
 Q X
