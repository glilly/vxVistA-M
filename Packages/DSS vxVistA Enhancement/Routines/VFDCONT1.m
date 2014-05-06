VFDCONT1 ;DSS/SGM - CONTINGENCY UTILITIES CONTINUED; 10/26/2011 16:55
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;
 ;This routine should only be called from within VFDCONT* routines
 ;
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  ------------------------------------------------------
 ; 2028  File 9000010, direct global read of entire file
 ;         controlled subscription - not a subscriber
 ;10035  Direct global read of many fields in PATIENT file (#2)
 ;          Direct global read of ^DPT("CN") - not supported
 ;10062  PID^VADPT6
 ;10086  ^%ZIS
 ;10089  ^%ZISC
 ;       HTFM^XLFDT
 ;
INP(NODE,ROU) ; main loop for getting next inpatient to gen report
 ; NODE - req - contingency report type
 ;  ROU - req - tag^routine that generates the contingency report for an
 ;              individual patient.  Program D @ROU.
 ;              tag^routine should expect that the output device is Open
 ;              and ready for use.  It should also not close the device.
 ;
 N I,X,Y,Z,NXT,STOP,VFDCNT
 Q:$G(NODE)=""  Q:$G(ROU)=""
 S (STOP,VFDCNT)=0
 F  S NXT=$$NXTINP(NODE) Q:NXT<1  D  Q:STOP
 .N DFN,FILE,HS,VFDPAT,WARD
 .Q:$$CKSTOP
 .S DFN=+NXT,WARD=$P(NXT,U,2)
 .Q:'$$CKPAT(DFN)
 .I NODE="HSI" S HS=$$HSINP^VFDCONT0(WARD) Q:'HS
 .S X=$$PATIENT(DFN) I $P(X,U)=-1 Q
 .S VFDPAT=X
 .S FILE=$$FILENAME(X,NODE,WARD) I FILE?1"-1^".E Q
 .I $$OPEN(PATH,FILE) Q
 .D @ROU,^%ZISC
 .S X=VFDPAT_U_DFN_U_PATH_U_FILE D LOG(NODE,X)
 .Q
 Q
 ;
OUT ; main loop to get next clinic and patient to gen report
 ; NODE = "HSO"
 N I,R,X,Y,Z,HS,ROU,STOP,VDATE,VFDCL,VFDCNT,VFDEND,VFDPAT,VIEN
 S (STOP,VFDCNT)=0
 S ROU="HS^VFDCONT2(DFN,HS)"
 S VFDEND=$$HSAPPT^VFDCONT0
 S:VINIT ^XTMP("VFDCONT",NODE,0,"LAST","VST")=$$HSVST^VFDCONT0
 F  S VFDCL=$$NXTOUT Q:VFDCL<1  D  Q:STOP
 .Q:$$CKSTOP
 .S HS=$$HS^VFDCONT0(VFDCL) Q:'HS
 .S VDATE=DT-.000001
 .F  S VDATE=$O(^SC(VFDCL,"S",VDATE)) Q:VDATE>VFDEND!'VDATE  D
 ..S VIEN=0 F  S VIEN=$O(^SC(VFDCL,"S",VDATE,1,VIEN)) Q:'VIEN  D
 ...S DFN=+^SC(VFDCL,"S",VDATE,1,VIEN,0)
 ...Q:'$$CKPAT(DFN,1)
 ...; has HS already be generated?
 ...Q:$D(^XTMP("VFDCONT",NODE,"PAT",DFN,HS))
 ...S X=$$PATIENT(DFN) I $P(X,U)=-1 Q
 ...S VFDPAT=X
 ...S FILE=$$FILENAME(X,NODE) I FILE?1"-1^".E Q
 ...I $$OPEN(PATH,FILE) Q
 ...D @ROU,^%ZISC
 ...S X=VFDPAT_U_DFN_U_PATH_U_FILE D LOG(NODE,X)
 ...Q
 ..Q
 .Q
 I 'STOP F  S VDATE=$$NXTVST Q:VDATE<1  D  Q:STOP
 .Q:$$CKSTOP
 .S VIEN=0 F  S VIEN=$O(^AUPNVSIT("B",VDATE,VIEN)) Q:'VIEN  D
 ..S X=$G(^AUPNVSIT(VIEN,0)) Q:X=""
 ..S DFN=$P(X,U,5),VFDCL=+$P(X,U,22) Q:'DFN  Q:'$$CKPAT(DFN,1)
 ..S HS=$$HS^VFDCONT0(VFDCL) Q:'HS
 ..; has HS already be generated?
 ..Q:$D(^XTMP("VFDCONT",NODE,"PAT",DFN,HS))
 ..S X=$$PATIENT(DFN) I $P(X,U)=-1 Q
 ..S VFDPAT=X
 ..S FILE=$$FILENAME(X,NODE) I FILE?1"-1^".E Q
 ..I $$OPEN(PATH,FILE) Q
 ..D @ROU,^%ZISC
 ..S X=VFDPAT_U_DFN_U_PATH_U_FILE D LOG(NODE,X)
 ..Q
 .Q
 Q
 ;
 ;-----------------------  Private Subroutines  -----------------------
ERR(N) ;
 N X S N=$G(N),X=""
 I N=1 S X="Unable to lock global node: "_R
 I N=2 S X="No patient file record exists for DFN="_DFN
 Q "-1^"_X
 ;
CKPAT(DFN,OUT) ; check to see if report should be created
 ;  DFN - req - patient file ien
 N I,X,DAT
 F I=0,.101,.105,.35 I $D(^DPT(DFN,I)) S DAT(I)=^(I)
 ; has patient died?
 Q:+$G(DAT(.35)) 0
 ; is this an test patient?
 Q:+$P($G(DAT(0)),U,21) 0
 I '$G(OUT) Q 1
 ; is this an inpatient?
 Q:+$G(DAT(.105)) 0
 Q:$D(DAT(.101)) 0
 Q 1
 ;
CKSTOP() ; check to see if user asked for Taskman process to stop
 N X,MAX
 S MAX=50 I NODE="HSO" S MAX=10
 I $G(ZTQUEUED)>0 Q 0
 S VFDCNT=1+VFDCNT I VFDCNT#MAX Q 0
 I '$$S^%ZTLOAD Q 0
 S (STOP,ZTSTOP)=1
 S X="Taskman process requested to stop at "_$$NOW^VFDCONT0("Te")
 D LOG(NODE,X)
 Q 1
 ;
FILENAME(PAT,NODE,INP) ; return a unique filename
 ; PAT - req - output of $$PATIENT
 ;NODE - req - contingency report type
 ; INP - opt - inpatient ward name
 N T,X,Y,Z
 S NODE=$G(NODE),INP=$G(INP)
 S T=$TR($$HTFM^XLFDT($H),".")_"X"_$R(100000)
 S Z=$S(INP'="":INP_U,1:"")_PAT_T
 I NODE'="" S Z=Z_U_NODE
 S Z=Z_".txt"
 Q $TR(Z,"^ ,","___")
 ;
LOG(NODE,DATA) ; log the creation of a file
 N I S I=1+$O(^XTMP("VFDCONT",NODE,0,"LOG"," "),-1),^(I)=$G(DATA)
 ; this next node prevents the same HS type from being generated more
 ; than once per patient.
 S:NODE="HSO" ^XTMP("VFDCONT",NODE,"PAT",DFN,HS)=""
 Q
 ;
NXTINP(NODE) ; get the next inpatient ward and dfn
 ; return next dfn^ward or -1^msg or 0 if no more inpatients
 N I,R,X,Y,Z
 S R=$NA(^XTMP("VFDCONT",NODE,0,"LAST"))
 L +@R:+3 E  Q $$ERR(1)
 S X=$G(@R) I X="~" L -@R Q 0
 S X=$Q(@X),Y=$S(X="":0,1:$QS(X,1)="CN")
 S @R=$S(Y:X,1:"~") L -@R
 Q $S(Y:$QS(X,3)_U_$QS(X,2),1:0)
 ;
NXTOUT() ; get the next outpatient clinic
 ; S ^XTMP("VFDCONT","HSO",0,"LAST") = last file 44 ien processed
 ; Return clinic_ien^dfn or -1^msg or 0 if no more outpatients
 N I,J,K,R,T,X,Y,Z,HS
 S T="~"
 S R=$NA(^XTMP("VFDCONT",NODE,0,"LAST"))
 L +@R:3 E  Q $$ERR(1)
 S X=$G(@R) I X'=T S X=$O(^SC(X)) I X<1 S X=T
 S @R=X L -@R
 Q $S(X>0:X,1:0)
 ;
NXTVST() ; get the VISIT file patient
 ; S ^XTMP("VFDCONT","HSO",0,"LAST","VST")=last visit date.time
 ; Return next DFN or -1^msg or 0 if no more outpatients
 N I,R,T,X,Y,Z
 S T="~"
 S R=$NA(^XTMP("VFDCONT",NODE,0,"LAST","VST"))
 L +@R:3 E  Q $$ERR(1)
 S X=$G(@R) I X=T L -@R Q 0
 S X=$O(^AUPNVSIT("B",X)) I X>(DT+.24) S X=T
 S @R=X L -@R
 Q $S(X>0:X,1:0)
 ;
OPEN(PATH,FILE) ; open the HFS device and USE it
 ; Boolean return
 N I,X,Y,Z,%ZIS,IOP,POP
 S IOP="HFS" I $G(NODE)="MAR" S IOP="HFS;P-HP-LASER-COMPRESS"
 S %ZIS("HFSMODE")="W",%ZIS("HFSNAME")=PATH_FILE
 D ^%ZIS I 'POP U IO
 Q POP
 ;
PATIENT(DFN) ; return patient name with MRN or last-four-ssn
 N I,X,Y,Z,ID,VA
 S Z=$G(^DPT(+$G(DFN),0)) I $P(Z,U)="" Q $$ERR(2)
 D PID^VADPT6 S ID=$S($G(VA("MRN"))'="":VA("MRN"),1:VA("BID"))
 Q $P(Z,U)_U_ID
