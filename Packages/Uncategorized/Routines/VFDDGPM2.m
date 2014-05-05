VFDDGPM2 ;DSS/LM/SGM - Patient movement events for Billing ; 11/15/2013 12:03
 ;;2009.1;DSS,INC VXVISTA;**13**;06 Apr 2010;Build 1
 ;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ; ICR#  Supported Reference
 ; ----  ----------------------------------------------
 ; 1889  $$DATA2PCE^PXAPI
 ; 2053  FILE^DIE
 ; 10013 ^DIK
 ; 2056  $$GET1^DIQ
 ;       EN^DSICPX
 ; 10061 IN5^VADPT
 ;       XCPT^VFDXX
 ;  489  ^VSIT
 ; 10103 $$HADD^XLFDT
 ; 10063 ^%ZTLOAD
 ;       ----------  FILE ACCESSES  ----------
 ;       FILE 42 - FM read using ^DIQ for field 44
 ;       FILE 405
 ;         FM read using ^DIQ for fields .01,.03,.06,.14,.16,.27
 ;         Direct global read of ^DGPM(ien,0),^DGPM("CA")
 ;         FM update of fields .01,.03,.04,.27 using ^DIE APIs
 ;       FILE 9000010
 ;         FM read using ^DIQ for field .07
 ;         FM update of field .07 using FILE^DIE
 ;         Direct global read of ^AUPNVSIT("B",date,ien)
 ;           ^AUPNVSIT("C",dfn,ien),^AUPNVSIT(ien,150)
 ;       FILE V HOSPITALIZATION
 ;         FM delete an entry using ^DIK
 ;         Direct global read of ^AUPNVINP("AD")
 ;
 Q
EN ;Protocol VFD DGPM ADMIT/VISIT EVENTS action
 ; Reference to ^UTILITY("DGPM" is supported by DBIA# 1181
 ;
 Q:'$G(DGPMDA)  ;Reality check
 I '$D(^DGPM(DGPMDA)),$G(DGPMT)=3,$L($G(DGPMP)) ;Cancel Discharge
 E  Q:'$D(^DGPM(DGPMDA))  ;Other cancelled movement
 I DGPMT=1,$D(^DGPM(DGPMDA)) ;Process admission visit in background
 E  D DQ Q  ;Other events in foreground
 N VFDX,ZTDESC,ZTIO,ZTRTN,ZTDTH,ZTSAVE,ZTSK
 F VFDX="DFN","DGPMCA","DGPMDA","DGPMA","DGPMP","DGPMT" S ZTSAVE(VFDX)=""
 S ZTSAVE("^UTILITY(""DGPM"",$J,")=""
 S ZTDESC="VFD ADMIT/VISIT Events",ZTIO=""
 S ZTDTH=$$HADD^XLFDT($H,0,0,0,30),ZTRTN="DQ^VFDDGPM2" ;+30 seconds
 D ^%ZTLOAD
 Q
 ;
POST(VFDALL,VECHO) ;
 ; Called from post-install on VFD VXVISTA UPDATE 2011.1.2 to make
 ; sure that admit movements have a VISIT file pointer.
 ; VFDALL - opt - Boolean, if true check all admission movements
 ;                else only check admit movements with a discharge date
 ;  VECHO - opt - Boolean, if true do screen writes to indicate working
 ;                else no screen writes
 N I,X,Y,Z,DGPMCA,DGPMDA
 S VFDALL=$G(VFDALL),VECHO=$G(VECHO)
 S DGPMDA=0
 F  S DGPMDA=$O(^DGPM(DGPMDA)) Q:'DGPMDA  S X=$G(^(DGPMDA,0)) D:X
 . ; quit if no date.time, not admit movement, already has visit ptr
 . Q:$P(X,U,2)'=1  Q:$P(X,U,27)
 . I 'VFDALL,'$P(X,U,17) Q  ; has an associated discharge movement
 . S DGPMCA=DGPMDA D 1
 . I $G(VECHO) U IO(0) W "."
 . Q 
 Q
 ;
EN2 ; Alternate entry - Process ALL admission movements, whether or not
 ;    a corresponding discharge exists
 ; 
 D POST(1) Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES ------------------------
 ;
DQ ; Tasked from EN^VFDDGPM2
 ;
 ;OPTION         VALUE OF DGPMT
 ;------         --------------
 ;admit                 1
 ;transfer              2
 ;discharge             3
 ;check-in              4
 ;check-out             5
 ;t.s. transfer         6
 ;
 I 0<$G(DGPMT),DGPMT<4!(DGPMT=6) D @DGPMT
 Q
 ;
1 ; Admit
 ; also called from post-install on VFD VXVISTA UPDATE 2011.1.2 to make
 ; sure that all admit movements have a VISIT file pointer.
 ; 1) Confirm or create inpatient VISIT
 N VFD,VFD27,VFDADA,VFDVSIT,VSIX
 S VFDADA=$$CONFIRM(DGPMDA,"V01") I 'VFDADA D XCPT(,,$P(VFDADA,U,2)) Q
 D GETS(.VFD,405,VFDADA_",",".01;.03;.27")
 S VFDVSIT=$G(VFD(.27))
 I VFDVSIT D  Q:'$D(VFD) ; Update the visit
 . S VSIX=$P($$MATCH^VSITGET(VFD(.27)),U)
 . Q:VSIX=""
 . Q:VSIX=VFD(.01)
 . K VSIX S VSIX(9000010,VFD(.27)_",",.01)=VFD(.01),VFDFG=1 D FILE("VSIX")
 . Q
 I '(VFDVSIT>0) N DFN,VDT D  Q:'VFDVSIT
 . ; get VISIT to file to this patient movement file entry
 . ; first check to see if VISIT exists
 . S VDT=$G(VFD(.01)),DFN=$G(VFD(.03)),VFDVSIT=$$XVSIT(VDT,DFN)
 . ; create a new VISIT file entry if necessary
 . I 'VFDVSIT S VFDVSIT=$$MAKEVSIT(VFDADA,VDT,DFN)
 . I VFDVSIT K VFD S VFD(405,VFDADA_",",.27)=VFDVSIT D FILE("VFD") Q
 . D XCPT(,,"V01 VISIT failed Error "_VFDVSIT,,1,"DGPMDA="_VFDADA)
 . Q
 ;
 ; 2) Confirm or set field #.07 = "H"
 I '($$GET1(9000010,VFDVSIT,.07)="H") D
 . ;
 . ; The following ^VSIT call does not change service category
 . ; Comment-out and troubleshoot later
 . ; 
 . ;N VSIT ;S VSIT("IEN")=VFDVSIT
 . ;S VSIT(0)="",VSIT("PKG")="VFD"
 . ;S (VSIT,VSIT("VDT"))=$$GET1^DIQ(405,VFDADA,.01,"I")
 . ;S VSIT("PAT")=$$GET1^DIQ(405,VFDADA,.03,"I")
 . ;S VSIT("LOC")=$$WL2HL($$GET1^DIQ(405,VFDADA,.06,"I"))
 . ;S VSIT("SVC")="H" D ^VSIT ;Set service category
 . ;I VSIT("IEN")<0 D XCPT(,,"V01 VISIT "_VFDVSIT_" SVC failed, Error "_$P(VSIT("IEN"),U),,3)
 . ;
 . ; DATA2PCE wrapper also does not change service category
 . ; Disable and troubleshoot later
 . ; 
 . I 0,$T(EN^DSICPX)]"" D  Q  ;Intentionally disabled
 . . N VFDNPUT,VFDRSLT
 . . S VFDNPUT(1)="VISIT^"_VFDVSIT
 . . S VFDNPUT(2)="PACKAGE^VFD"
 . . S VFDNPUT(3)="ENC DT^"_$$GET1^DIQ(405,VFDADA,.01,"I")
 . . S VFDNPUT(4)="ENC PATIENT^"_$$GET1^DIQ(405,VFDADA,.03,"I")
 . . S VFDNPUT(5)="ENC HOSPITAL LOC^"_$$WL2HL($$GET1^DIQ(405,VFDADA,.06,"I"))
 . . S VFDNPUT(6)="ENC SERVICE CATEGORY^H"
 . . D EN^DSICPX(.VFDRSLT,.VFDNPUT)
 . . Q:$G(VFDRSLT(1))>0
 . . D XCPT(,,"V01 VISIT "_VFDVSIT_" SVC failed. Error "_$P($G(VFDRSLT(1)),U),,3)
 . . Q
 . ;
 . ; Temporary expedient - Set service category directly
 . K VFD S VFD(9000010,VFDVSIT_",",.07)="H" D FILE("VFD")
 . Q
 ; 3) Confirm PTF (file 45) entry or record exception.
 I '$$GET1(405,VFDADA,.16) D
 . D XCPT(,,"V01 DGMPDA="_VFDADA_" has no PTF entry")
 . Q
 ; 4) Process associated treating specialty transfer movement
 D 6
 Q
 ;
2 ; Transfer
 Q
 ;
3 ;  Discharge
 ;
 ; Confirm or create V HOSPITALIZATION entry
 ;   A)   FILE NAME: V HOSPITALIZATION     D) DATA GLOBAL: ^AUPNVINP(
 ;   B) FILE NUMBER: 9000010.02            E) TOTAL GLOBAL ENTRIES: 0
 ;   C) NUM OF FLDS: 32                    F) FILE ACCESS:      DD: @
 ;=====================================================================
 ; STUB FIELDS -
 ;   .01          DATE OF DISCHARGE   [0;1] [RD]               ********
 ;   .019         LENGTH OF STAY   [ ; ] [CJ8]                 COMPUTED
 ;   .02          PATIENT NAME   [0;2] [RP9000001'I]           ********
 ;   .03          VISIT   [0;3] [R*P9000010'I]                 ********
 ;   .04          ADMITTING SERVICE   [0;4] [RP45.7']          ********
 ;   .05          DISCHARGE SERVICE   [0;5] [RP45.7']          ********
 ;   .06          DISCHARGE TYPE   [0;6] [R*P405.1']           ********
 ;   .07          ADMISSION TYPE   [0;7] [R*P405.1']           ********
 ;=====================================================================
 ;
 I '$D(^DGPM(DGPMDA)) D 13 Q  ;Cancel discharge
 N I,X,Y,VFD,VFDA,VFDADA,VFDIEN,VFDIENR,VFDIENS,VFDMSG
 S VFDADA=$$CONFIRM(DGPMDA,"V03") I 'VFDADA D XCPT(,,$P(VFDADA,U,2)) Q
 K VFDA D GETS(.VFDA,405,DGPMDA,".01;.03;.04")
 S VFD(.01)=$G(VFDA(.01)) ;   DATE [time] OF DISCHARGE
 S VFD(.02)=$G(VFDA(.03)) ;   9000001 is DINUM'ed
 S VFD(.06)=$G(VFDA(.04)) ;   DISCHARGE TYPE
 S VFD(.05)=$$DTS(DGPMDA) ;   Last Treating Specialty before discharge
 K VFDA D GETS(.VFDA,405,VFDADA,".04;.27")
 S VFD(.03)=$G(VFDA(.27)) ;   Corresponding admission VISIT
 S VFD(.07)=$G(VFDA(.04)) ;   ADMISSION TYPE
 S VFD(.04)=$$ATS(VFDADA) ;   Admin Treating Specialty AKA ADMIT SERV
 ;
 S VFDIEN=$O(^AUPNVINP("AD",+VFD(.03),""))
 I VFDIEN S VFDIENS=VFDIEN_",",VFDIENR(1)=VFDIEN
 E  S VFDIENS="+1,"
 K VFDA
 F I=.01:.01:.07 I $D(VFD(I)) S VFDA(9000010.02,VFDIENS,I)=VFD(I)
 I VFDIENS D FILE("VFDA") I 1 ;   Edit existing entry
 E  D UPDATE^DIE(,"VFDA","VFDIENR","VFDMSG")
 I '$G(VFDIENR(1)) D
 . S X="V03 V HOSPITALIZATION failed DGPMDA="_DGPMDA
 . S Y=$G(VFDMSG("DIERR",1,"TEXT",1))
 .D XCPT(,,X,,1,Y)
 .Q
 Q
 ;
6 ; Treating Specialty Transfer
 ; After processing an admission (DGPMT=1) come here to process the
 ;   paired specialty transfer movement.
 ; Also come here on treating specialty transfer movement DGPMT=6
 ;
 Q:'$G(DGPMCA)  Q:'$G(DGPMDA)  N VFDTSDA
 S VFDTSDA=$S(DGPMCA=DGPMDA:$O(^DGPM("APHY",DGPMCA,0)),1:DGPMDA)
 ; try to compute treating specialty movement IEN
 Q:'VFDTSDA  Q:$$CONFIRM(VFDTSDA)'=DGPMCA ;Double-check
 ;
 ; File 405 fields
 ; 
 ;  .01          DATE/TIME   [0;1] [RDX]
 ;  .03          PATIENT   [0;3] [RP2'I]
 ;  .08          PRIMARY PHYSICIAN   [0;8] [*P200']
 ;  .09          FACILITY TREATING SPECIALTY   [0;9] [R*P45.7'a]
 ;  .19          ATTENDING PHYSICIAN   [0;19] [R*P200']
 ;  .27          VISIT FILE ENTRY   [0;27] [*P9000010'X]
 ; 
 ; File 9000010.06 fields
 ; 
 ;  .01          PROVIDER   [0;1] [RP200']
 ;  .02          PATIENT NAME   [0;2] [RP9000001'I]
 ;  .03          VISIT   [0;3] [R*P9000010'I]
 ;  .04          PRIMARY/SECONDARY   [0;4] [RS]
 ;  .05          OPERATING/ATTENDING   [0;5] [S]
 ;  1201         EVENT DATE AND TIME   [12;1] [D]
 ;  
 N FLD,PKG,SRC,VFD,VFDAPRV,VFDPPRV,VFDDFN,VFDVIEN,VFDEVDT
 S PKG=$$LKPKG^XPDUTL("VFD")
 I 'PKG D XCPT(,,"VFD package lookup failed") Q  ;Required for DATA2PCE
 S VFDVIEN=$$GET1(405,DGPMCA,.27) ;Corresponding admission visit IEN
 S FLD=".01;.03;.08;.19" D GETS(.VFD,405,VFDTSDA,FLD)
 S VFDEVDT=$G(VFD(.01)) ;   Treating specialty transfer D/T
 S VFDDFN=$G(VFD(.03)) ;    Treating specialty transfer patient
 S VFDPPRV=$G(VFD(.08)) ;   Primary provider
 S VFDAPRV=$G(VFD(.19)) ;   Attending physician
 ;
 ; Prep. call to DATA2PCE
 ; 7/1/2010 - Prevent PuTTY disconnect when running in foreground
 ;N %ZIS,IO,IOP,POP S IOP="NULL" S %ZIS="0" D ^%ZIS U:'POP IO
 K VFD K ^TMP("VFDDGPM",$J) S VFD=$NA(^TMP("VFDDGPM",$J,"PROVIDER"))
 ; Not required for existing visits:
 ;   "ENCOUNTER",1,"ENC D/T"
 ;   "ENCOUNTER",1,"PATIENT"
 S @VFD@(1,"NAME")=VFDPPRV
 S @VFD@(1,"PRIMARY")=1
 S @VFD@(2,"NAME")=VFDAPRV
 S @VFD@(2,"ATTENDING")=1
 S SRC="VFD DGPM ADMIT/VISIT EVENTS"
 S X=$$DATA2PCE^PXAPI(VFD,PKG,SRC,.VFDVIEN)
 I X<0 D XCPT(,,"DATA2PCE error "_X_" filing V PROVIDER")
 K ^TMP("VFDDGPM",$J)
 Q
 ;
13 ; Cancelled Discharge
 ; DGPMP has 0-node of cancelled movement
 ;
 ;Q  ;Uncomment this line to disable 'cancel discharge' processing
 ; 
 N VFD,VFDADA
 S VFDADA=$P(DGPMP,U,14) I 'VFDADA D  Q
 . D XCPT(,,"V13 DGPMDA="_DGPMDA_" #.14 not found")
 . Q
 N VFDVIEN S VFDVIEN=$$GET1(405,VFDADA,.27) ;Related admission VISIT
 I 'VFDVIEN D  Q
 . D XCPT(,,"V13 DGPMDA="_DGPMDA_" VISIT# not found")
 . Q 
 N VFDIEN S VFDIEN=$O(^AUPNVINP("AD",VFDVIEN,""))
 I 'VFDIEN D  Q
 . D XCPT(,,"V13 DGPMDA="_DGPMDA_" V HOSP not found")
 . Q
 N DA,DIK S DA=VFDIEN,DIK="^AUPNVINP(" D ^DIK
 D XCPT(,,"V13 V HOSP IEN="_VFDIEN_" deleted",,3)
 Q
 ;
 
ATS(VFDADA) ; Admission Treating Specialty
 ; VFDADA=[Required]Admission movement IEN
 ; Uses "CA" cross-reference to identify corresponding Treating
 ; Specialty Transfer
 ; 
 Q:'$G(VFDADA) ""
 N VFDA,VFDY S VFDA=""
 F  S VFDA=$O(^DGPM("CA",VFDADA,VFDA)) Q:'VFDA!$D(VFDY)  D
 . ;FACILITY MOVEMENT TYPE=PROVIDER/SPECIALTY CHANGE
 . I $P($G(^DGPM(VFDA,0)),U,4)=42 S VFDY=$P(^DGPM(VFDA,0),U,9)
 . Q
 Q $G(VFDY)
 ;
CONFIRM(IEN,VTAG) ; confirm ADMISSION/CHECK-IN MOVEMENT
 N I,X,Y,Z
 S X="" I +$G(IEN) S X=$$GET1(405,IEN,.14)
 S Y=X I 'X S Y=U_VTAG_" DGPMDA="_DGPMDA_" #.14 not found"
 Q Y
 ;
DTS(VFDDDA) ; Discharge Treating Specialty
 ; VFDDDA=[Required]Discharge movement IEN
 ; Uses IN5^VADPT  Returns LAST treating specialty (TS)
 ; Note that the discharge movement itself does not have a TS
 ; 
 Q:'$G(VFDDDA) ""  N DFN,VAIP,VAROOT,VFD
 S DFN=$$GET1(405,VFDDDA,.03)
 S VAIP("D")="LAST",VAROOT="VFD" D IN5^VADPT
 Q $P($G(VFD(17,6)),U)
 ;
FILE(VFDX) ; wrap FILE^DIE
 N I,J,X,Y,Z,DIERR,VFDER
 D FILE^DIE(,VFDX,"VFDER")
 Q
 ;
GET1(FILE,IENS,FLD,FLG) ; wrap GET1^DIQ
 N I,J,X,Y,Z,DIERR,VFDER
 S:$G(FLG)="" FLG="I"
 I '$G(FILE)!'$G(IENS)!'$G(FLD) Q ""
 Q $$GET1^DIQ(FILE,IENS,FLD,FLG,,"VFDER")
 ;
GETS(VFDX,VFILE,VIENS,VFDFLD,FLG) ; wrap GETS^DIQ
 N I,J,X,Y,Z,DIERR,VFDER,VFDTMP
 K VFDX Q:$G(VFILE)<1  Q:'$G(VIENS)  Q:'$G(VFDFLD)
 S FLG=$G(FLG) S:FLG="" FLG="I"
 D GETS^DIQ(VFILE,VIENS,VFDFLD,FLG,"VFDTMP","VFDER")
 Q:$D(DIERR)  K Z M Z=VFDTMP(VFILE,VIENS)
 S I=0 F  S I=$O(Z(I)) Q:'I  S VFDX(I)=Z(I,"I")
 Q
 ;
MAKEVSIT(VFDA,VDT,DFN) ; Wraps ^VSIT to force-create VISIT entry
 ;
 ; VFDA=[Required] File 405 IEN
 ; VDT=[Required] Visit DATE.TIME (FileMan format)
 ; DFN=[Required] Patient IEN
 ; 
 Q:'VFDA "" N VFDWL,VSIT
 S VSIT("VDT")=VDT
 S VSIT("PAT")=DFN
 S VFDWL=$$GET1(405,VFDA,.06) I 'VFDWL D  Q ""
 .D XCPT(,,"VSIT DGPMDA="_VFDA_" #.06 not found")
 .Q
 S VSIT("LOC")=$$GET1(42,VFDWL,44)
 S VSIT("IO")="INPATIENT"
 S VSIT("SVC")="H"
 S VSIT("PKG")="VFD"
 S VSIT(0)="F" D ^VSIT
 Q +VSIT("IEN")
 ;
VXVISTA() Q ^%ZOSF("ZVX")["VX"
 ;
WL2HL(VFD) ; Ward Location IEN to Hospital Location IEN
 ;VFD=[Required] Ward Location IEN
 Q $$GET1(42,+$G(VFD),44)
 ;
XCPT(VXDT,APPL,DESC,HLID,SVER,DATA,VFDXVARS) ; Record exception
 ; Wraps vxVistA exception handler
 Q:'$$VXVISTA
 S:'$L($G(APPL)) APPL="VFD MOVEMENT EVENTS"
 D XCPT^VFDXX(.VXDT,.APPL,.DESC,.HLID,.SVER,.DATA,.VFDXVARS)
 Q
 ;
XVSIT(VDT,DFN) ; Returns VISIT IEN if and only if VISIT exists
 ;Else returns 0
 ;
 ; VISIT must match VDT, DFN and must be of inpatient type (#15002=1)
 ; VDT - req - Visit DATE.TIME (FileMan format)
 ; DFN - req - Patient IEN
 I '$G(VDT)!'$G(DFN) Q 0
 N A,X,INV
 S INV=(9999999-$P(VDT,".")) S:VDT["." INV=INV_"."_$P(VDT,".",2)
 S (A,X)=0 F  S A=$O(^AUPNVSIT("AA",DFN,INV,A)) Q:'A  D  Q:X
 . I $P($G(^AUPNVSIT(A,150)),U,2) S X=1
 . Q
 S:'X A=0
 Q A
