VFDPXIM2 ;DSS/WLC - MAIN ENTRY TO VFDPXIM ROUTINES ; 10 Oct 2013  5:17 PM
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**10**;11 Jun 2013;Build 5
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;All Integration Agreements for VFDPXIM*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ;1889   $$DATA2PCE^PXAPI
 ;1894   ENCEVENT^PXKENC
 ;2056   GET1^DIQ
 ;       $$FIND1^DIC
 ;       FILE^DIE
 ;       NOW^XLFDT
 ;
 ; This RPC will set a drug order as administered by setting the STOP or
 ; EXPIRATION DATE to NOW.  This will in effect expire the order when
 ; Outpatient or Inpatient Pharmacy normally does so.  It also creates
 ; a Visit and V Immunization records using $$DATA2PCE^PXAPI
 ;
 ; See RPC:  VFD PXIM GET IMM ORDERS - this validates that the order
 ; is an immunization order.
 ;  INPUT STRING:
 ;    1-DOSE = Dose administered
 ;    2-UNIT = Unit of dose administered
 ;    3-WHO = Who did the administration, Pointer to New Persons (#200)
 ;    4-START = Start Date/Time of administration 
 ;    5-END = End Date/Time of administration
 ;    6-ORN = Internal CPRS Order number pointer (#100)
 ;    7-LOC = Location, pointer to Hospital Location (#44)
 ;    8-VFD IMM = pointer to VFD immunization (#21630.01)
 ;  OUTPUT:
 ;    VFDIM=-1^Error Text
 ;    or
 ;    VFDIM=1^Success updated
 ;
ADMIN(VFDIM,VFDRAY)  ;RPC: VFD PXIM ADMIN - Entry point
 N DR,DIE,DA,PSOIEN,VFDORD,VFDSTA
 D DATA Q:VFDIM["-1"
 S VFDIM="1^Administration Successful."
 S VFDORD=$P(VFDRAY,U,6),VFDSTA="",VFDSTA=$$FIND1^DIC(100.01,,,"COMPLETE")
 I VFDSTA D STATUS^ORCSAVE2(VFDORD,VFDSTA)
 ;Set Prescription Status to 10 ("DONE")
 S PSOIEN=+$G(^OR(100,VFDORD,4))
 S DR="100///10",DIE="^PSRX(",DA=PSOIEN D ^DIE
 Q
 ;
 ;------------------------ PRIVATE SUBROUTINES ------------------------
 ;
DATA ;Get and Validate data
 N DFN,DFNR,DOSE,END,IMM,LOC,ORN,OPROV,PKG,PREF,UNIT,VFDAY
 N VFDIMM,WHO,WHEN
 S VFDAY=$G(VFDRAY)
 I '$D(VFDAY)!(VFDAY="") S VFDIM="-1^No data passed" Q
 S DOSE=$P(VFDAY,U,1),UNIT=$P(VFDAY,U,2),WHO=$P(VFDAY,U,3),WHEN=$P(VFDAY,U,4)
 S END=$P(VFDAY,U,5),ORN=$P(VFDAY,U,6),LOC=$P(VFDAY,U,7),VFDIMM=$P(VFDAY,U,8)
 I 'ORN S VFDIM="-1^No Order number sent" Q
 I '$D(^OR(100,ORN)) S VFDIM="-1^Invalid Order number." Q
 S PREF=$G(^OR(100,ORN,4))
 S DFNR=$P(^OR(100,ORN,0),U,2) I DFNR["DPT" S DFN=+DFNR
 I '$D(DFN)!(DFN="") S VFDIM="-1^No DFN for order" Q
 I PREF["P" S VFDIM="-1^Order in PENDING status." Q
 I DOSE="" S VFDIM="-1^Invalid data for Dose" Q
 I UNIT="" S VFDIM="-1^Invalid data for Unit" Q
 I WHO="" S WHO=DUZ ;Use current login
 I LOC="" S VFDIM="-1^Invalid data for Location" Q
 I VFDIMM="" S VFDIM="-1^Invalid VFD Immunization" Q
 S IMM=$P($G(^VFD(21630.01,VFDIMM,3)),U,3) ;Pointer to 9999999.14
 I IMM="" S VFDIM="-1^Invalid VFD Immunization pointer" Q
 S OPROV=$P(^OR(100,ORN,0),U,4)
 ; Get dialog
 N DLG,DLGN
 S DLG=$P(^OR(100,ORN,0),U,5),DLGN=$$GET1^DIQ(101.41,DLG_",",.01)
 ; Get first 8 diagnosis
 N DIAG,DIAGN,I
 S DIAGN=0,I=1
 F  S DIAGN=$O(^OR(100,ORN,5.1,DIAGN)) Q:'DIAGN!(I>7)  D
 .S DIAG(I)=^OR(100,ORN,5.1,DIAGN,0)
 .S I=1+1
 S PKG="",PKG=$O(^DIC(9.4,"C","VFD",PKG))
 S:'WHEN!(WHEN="") WHEN=$E($$NOW^XLFDT,1,12)
 S:'END!(END="") END=$E($$NOW^XLFDT,1,12)
 S VFDIM="1^All data is good"
 ;
PCEDATA ;Create Visit and V Immunization (#9000010.11) record
 N VFDRA,I,OK,VISITIEN,VFDSCR
 K VISITIEN
 S VFDRA("ENCOUNTER",1,"ENC D/T")=WHEN
 S VFDRA("ENCOUNTER",1,"PATIENT")=DFN
 S VFDRA("ENCOUNTER",1,"HOS LOC")=LOC
 S VFDRA("ENCOUNTER",1,"SERVICE CATEGORY")="X" ;Ancillary Package Daily Data
 S VFDRA("ENCOUNTER",1,"ENCOUNTER TYPE")="A" ;Ancillary
 S VFDRA("ENCOUNTER",1,"CHECKOUT D/T")=END
 S VFDSCR="VFD IMMUNOLOGY"
 S VFDRA("IMMUNIZATION",1,"IMMUN")=IMM ;Pointer to 9999999.14 
 S I=1 F I=$O(DIAG(I)) Q:'I  D
 .S:I=1 VFDRA("IMMUNIZATION",1,"DIAGNOSIS")=DIAG(I)
 .S:I>1 VFDRA("IMMUNIZATION",1,"DIAGNOSIS "_I)=DIAG(I)
 S VFDRA("IMMUNIZATION",1,"ENC PROVIDER")=WHO
 S VFDRA("IMMUNIZATION",1,"EVENT D/T")=WHEN
 S VFDSCR="VFD IMMUNOLOGY"
 S OK=$$DATA2PCE^PXAPI("VFDRA",PKG,VFDSCR,.VISITIEN)
 I OK<0 S VFDIM="-1^Problem adding PCE data." Q
 I '$D(VISITIEN)!(VISITIEN="") S VFDIM="-1^No visit returned from DATA2PCE" Q
 I '$D(^AUPNVSIT(VISITIEN,0)) S VFDIM="-1^No Visit record" Q
 D ENCEVENT^PXKENC(VISITIEN)
 ; Get V IMM record from visit
 N MM,NODE,VFDVIM,VIM,VIS,VREC,ICNT
 S (VIM,VIS,VFDVIM)="",ICNT=0
 F  S VIM=$O(^TMP("PXKENC",$J,VISITIEN,"IMM",VIM)) Q:'VIM!(VFDIM["-1")  D
 .S NODE="",VFDVIM=VIM
 .F  S NODE=$O(^TMP("PXKENC",$J,VISITIEN,"IMM",VIM,NODE)) Q:NODE=""!(VFDIM["-1")  D
 ..S MM="",VIS=""
 ..Q:NODE'=0
 ..S:NODE=0 VREC=$G(^AUPNVIMM(VIM,0))
 ..I VREC="" S VFDIM="-1^No V-Immunization record" Q
 ..S MM=$P(VREC,U) ;Visit Immunization pointer
 ..I MM=IMM S VIS=VIM,ICNT=ICNT+1 ;Visit Imm = VFD Imm pointer
 K ^TMP("PXKENC",$J) ;Clean up ^TMP from ENCEVENT^PXKENC
 I VIS="" S VFDIM="-1^No V-Immunization/Immunization record"
 I ICNT>1 S VFDIM="-1^Multiple Immunization for Immunization Visit record"
 ;
VFDATA ;Update V Immunization (#9000010.11) record with VFD fields
 N DIERR,VFDA,VFDIEN
 S VFDIEN=VFDVIM_",",VFDA(9000010.11,VFDIEN,21600.01)=DOSE
 S VFDA(9000010.11,VFDIEN,21600.02)=UNIT
 S VFDA(9000010.11,VFDIEN,21600.03)=VFDIMM
 D FILE^DIE(,"VFDA")
 S:'$D(DIERR) VFDIM="1^V-Immunization record Successful."
 S:$D(DIERR) VFDIM="-1^V-Immunization record Unsuccessful."
 ;
PSDATA ;Update inpatient pharmacy order with expiration date
 N REC
 I DLGN["PSJ" D
 .S REC=+PREF
 .N DIERR,VFDA,VFDIEN
 .S VFDIEN=DFN_",",VFDA(55.06,VFDIEN,34)=$E($$NOW^XLFDT,1,12)
 .D FILE^DIE(,"VFDA")
 .S:'$D(DIERR) VFDIM="1^Inpatient Order Successfully updated."
 .S:$D(DIERR) VFDIM="-1^Inpatient Order Unsuccess."
 ; Update outpatient pharmacy with expiration date
 I DLGN["PSO" D
 .N DIERR,VFDA,VFDIEN
 .S VFDIEN=PREF_",",VFDA(52,VFDIEN,26)=$E($$NOW^XLFDT,1,12)
 .D FILE^DIE(,"VFDA")
 .S:'$D(DIERR) VFDIM="1^Outpatient Order Successfully updated."
 .S:$D(DIERR) VFDIM="-1^Outpatient Order Unsuccessful."
 Q
