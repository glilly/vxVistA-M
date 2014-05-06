VFDCONT2 ;DSS/SGM - CONTINGENCY PHARMACY;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;
 ;This routine should not be invoked except by VFDCONT* routines
 ;ICR #  SUPPORTED REFERENCE
 ;-----  ---------------------------------------------------------------
 ;  744  ENX^GMTSDVR - controlled subscription, not a subscriber
 ; 2051  $$FIND1^DIC
 ; 2053  FILE^DIE
 ; 3429  FM read field .42, file 101.24 - private ICR between OR and PSB
 ;10103  $$FMADD^XLFDT
 ;10114  FM read of .01 field, file 3.5
 ;3889   RPC^PSBO - no ICR for calling NEW^PSBO1 or DQ^PSBO or to edit
 ;                  file 53.69
 ;
 ;----------------------------------------------------------------------
 ;                         HEALTH SUMMARY REPORT
 ;----------------------------------------------------------------------
HS(DFN,HS,BEG,END) ;  call HS to generate health summary
 ; DFN - req - IEN to the PATIENT file (#2)
 ;  HS - req - ien to health summary type file (#142)
 ; BEG - opt - FM start date
 ; END - opt - FM end date
 ; ZTQUEUED required to keep ENX^GMRSDVR quiet
 N I,J,X,Y,Z,ZTQUEUED
 S ZTQUEUED=""
 I $G(DFN)>0,$G(HS)>0 D ENX^GMTSDVR(DFN,HS,$G(BEG),$G(END))
 Q
 ;
 ;----------------------------------------------------------------------
 ;               MEDICAL ADMINISTRATION RECORD (MAR) REPORT
 ;----------------------------------------------------------------------
MAR(DFN) ; print an MAR for a single patient
 ; this variables were placed in ZTSAVE() in DEV^PSGMMAR
 N I,J,X,Y,Z
 N PSGDT,PSGMARB,PSGMARDF,PSGMARFD,PSGMARS,PSGMARSD,PSGMARWD,PSGMARWG
 N PSGMTYPE,PSGP,PSGPAT,PSGRBPPN,PSGSS
 ; variables saved if exists in ENDEV^PSGTI
 N PSJSYSL,PSJSYSP,PSJSYSP0,PSJSYSU,PSJSYSW,PSJSYSW0
 ; start setting variables
 S PSGDT=$$NOW^VFDCONT0("S")
 S PSGMARDF=MARTYPE
 S PSGMARSD=DT
 S PSGMARFD=$$FMADD^XLFDT(DT,PSGMARDF-1)
 S PSGMARB=3
 S PSGMARS=3
 S (PSGMARWD,PSGMARWG)=0
 S PSGMTYPE=1
 S PSGPAT=DFN,PSGPAT(DFN)=""
 S PSGRBPPN=""
 S PSGSS="P"
 ;
MARENQ ; copied from ENQ^PSGMMAR - don't want PSGMMAR doing ^%ZISC
 N DRGI,DRGN,DRGT,LN,P,PSIVUP,PSJORIFN,PSGMSORT
 K ^TMP($J)
 D ^PSGMMAR0 I $D(^TMP($J))>9 D ^PSGMMAR1 K ^TMP($J) D DONE^PSGMMAR
 Q
 ;
MARTEST(DFN,SDT) ;
 ; set up variables and test
 ; values from VOSQA on 12/18/2009
 N PSGDT,PSGMARB,PSGMARDF,PSGMARFD,PSGMARS,PSGMARSD,PSGMARWD,PSGMARWG
 N PSGMTYPE,PSGP,PSGPAT,PSGRBPPN,PSGSS
 ; variables saved if exists in ENDEV^PSGTI
 N PSJSYSL,PSJSYSP,PSJSYSP0,PSJSYSU,PSJSYSW,PSJSYSW0
 ; start setting variables
 I $G(DUZ)<.5 D INITOS^VFDCONT0
 S DFN=+$G(DFN) Q:DFN<1!'$D(^PS(55,DFN))
 S SDT=$G(SDT) S:'SDT SDT=DT
 S PSGDT=SDT S:SDT'["." PSGDT=SDT_".12" S SDT=SDT\1
 S PSGMARSD=SDT
 S PSGMARDF=7
 S PSGMARFD=$$FMADD^XLFDT(PSGMARSD,PSGMARDF-1)
 S PSGMARB=3
 S PSGMARS=3
 S (PSGMARWD,PSGMARWG)=0
 S PSGMTYPE=1
 S PSGPAT=DFN,PSGPAT(DFN)=""
 S PSGRBPPN=""
 S PSGSS="P"
 D MARENQ Q
 ;
 ;**********  Notes on meaning of PS variables  **********
 ; PSGDT = $$NOW^XLFDT
 ; PSGMARB - MAR form - default to 3
 ;   1 to print BLANK (no data) MARs for patient
 ;   2 to print MARs complete with orders
 ;   3 to print both
 ; PSGMARDF - number of days - default to 7
 ;   7 or 14
 ; PSGMARFD - end date - compute based upon PSGMARSD and PASMARDF
 ; PSGMARS - default to 3
 ;   1: CONTINUOUS ONLY    2: PRN ONLY    3: BOTH    4: ORDERS ONLY
 ; PSGMARSD - Fileman start date (date only)
 ; PSGMARWD = 1 ???
 ; PSGMARWG = 0
 ; PSGMTYPE - med choices - default to 1
 ;   can be 1 or a list of the others (eg. 2,5,6,)
 ;   1.  All medications
 ;   2.  Non-IV medications only
 ;   3.  IVPB
 ;   4.  LVPs
 ;   5.  TPNs
 ;   6.  Chemotherapy medications (IV)",DIR("?",8)=""
 ; PSGP = -1 [incrementer for patient selection]
 ; PSGPAT - array of patients to print (by patient - we have only 1)
 ;   PSGPAT = DFN
 ;   PSGPAT(DFN) = ""
 ; PSGRBPPN = ""
 ; PSGSS - select by - always choose (P)atient
 ;   (G)roup   (W)ard   (C)linic   (P)atient
 ;   If PSGSS="W" then expects variables PSGTM,PSGTMALL
 ;
 ;----------------------------------------------------------------------
 ;              MEDICAL ADMINISTRATION HISTORY (MAH) REPORT
 ;----------------------------------------------------------------------
MAH(DFN) ; print MAH for a single patient
 N I,J,X,Y,Z,DIERR,VFD,VFDAT,VFDER
 ; create new record in file 53.69 - fields .01:.05 filed
 D NEW^PSBO1(.VFD,"MH")
 Q:VFD(0)<1  K Z
 ; file remaining fields in file 53.69
 S X=$$HFS^VFDCONT0("HFS") S:X>0 Z(.06)=X
 S Z(.07)=$$NOW^VFDCONT0("T")
 S Z(.08)="MAH Contingency"
 S Z(.11)="P"
 S Z(.12)=DFN
 S Z(.16)=$$FMADD^XLFDT(DT,1-$$MAXDAYS)
 S Z(.18)=DT
 S Z(.19)=.24
 M VFDAT(53.69,(+VFD(0))_",")=Z
 D FILE^DIE(,"VFDAT","VFDER")
 ; line DQ copied from PSBO routine and modified
 ;DQ(PSBRPT) ; Dequeue report from Taskman
 N PSBDFN,PSBRPT,PSBWRD
 S PSBRPT=+VFD(0)
 I $$SETUP^PSBO D EN^PSBOMH
 K ^TMP("PSBO",$J)
 Q
 ;
MAXDAYS() ; return maximum days allowed by CPRS
 N I,X,Y,Z
 S Y=-1
 S X=$$FIND1^DIC(101.24,"","X","ORRP BCMA MAH","B")
 I X>0 S Y=$$GET1^DIQ(101.24,X_",",.42) S:'Y Y=-1
 I Y<0 S Y=7
 Q Y
