VFDPSB2 ;DSS/LM - vxBCMA to vxPAMS interface ; 6/23/2009
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
DQ ;Tasked from RPC: VFD BCMA EVENT after filing data to AUDIT LOG multiple
 ; of BCMA MEDICATION LOG file.
 ; 
 ; VFDIEN is File 53.79 IEN
 ; VFDIENR(1) is AUDIT LOG multiple IEN
 ; 
 ; Other VFD* variables may also be referenced.
 ; 
 ; Example VFD* variable values:
 ; 
 ;   VFD50IEN=3009
 ;   VFDIEN=261
 ;   VFDIENR("1")=15
 ;   VFDIENS=1,3009,
 ;   VFDLIST("0")=1
 ;   VFDLIST("1")=DD^3009^THYROID 1GR (60MG) TABS
 ;   VFDNDC=00002-1025-04
 ;   VFDSCAN=000002102504
 ;   VFDTAB=UDTAB
 ;
 N VFDFDA,VFDR,VFDVMIEN
 S VFDVMIEN=$$FIND1^DIC(9000010.14,,"QX",VFDIEN,"VFD")
 I VFDVMIEN<1 S VFDR=$NA(VFDFDA(9000010.14,"+1,")) D  ;New V MEDICATION
 .S @VFDR@(.01)=VFD50IEN ;DRUG IEN
 .S @VFDR@(21600.01)=VFDNDC
 .S @VFDR@(21600.02)=VFDIEN
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDVMIEN))
 .S VFDVMIEN=$G(VFDVMIEN(1))
 .Q
 I VFDVMIEN<1 D  Q  ;Fatal error
 .D XCPT(,,"V MEDICATION entry failed to file",,1,"File 53.79 IEN="_VFDIEN)
 .Q
 ;
 ; Populate additional V MEDICATION fields
 ;
 ;The following annotated field list is copied from an Email from James Gray
 ;time-stamped Fri 4/3/2009 8:04 PM
 ;
 ;^AUPNVMED(D0,0)= (#.01) MEDICATION [1P:50]             Required
 ;^ (#.02) PATIENT NAME [2P:9000001]                     Required
 ;              ==>^ (#.03) VISIT [3P:9000010]           Required
 ;^ (#.04) NAME OF NON-TABLE DRUG                        Optional
 ;              ==>[4F] ^ (#.05) SIG [5F]                Optional
 ;^ (#.06) QUANTITY [6N]                                 Required
 ;^ (#.07) DAYS PRESCRIBED [7N]                          Used
 ;^ (#.08) DATE DISCONTINUED [8D]                        Optional
 ;^ (#.09)
 ;              ==>*PROVIDER [9P:200] ^
 ;^AUPNVMED(D0,11)= (#1101) COMMENT [1F]                 Optional
 ;^ (#1102) PRESCRIPTION NUMBER [2F]                     Required for OP
 ;               ==>(#1103) BILLED? [3S]                 Not used
 ;^ (#1104) ABBRV SIG [4F] ^                             Optional
 ;(#1105) CHRONIC? [5S] ^                                Optional
 ;(#1201) EVENT DATE&TIME [1D]                          Used
 ;^ (#1202) ORDERING PROVIDER                            Used
 ;               ==>[2P:200] ^ (#1203) CLINIC [3P:40.7]  Used for OP
 ;^ (#1204) ENCOUNTER PROVIDER [4P:200]                  Used
 ;^  ^  ^  ^ (#1208) PARENT [8P:9000010.14]              Used if relevant
 ;               ==>^ (#1209) EXTERNAL KEY [9F] ^        Not used
 ;(#1210) OUTSIDE PROVIDER NAME                          Used
 ;         [10F] ^ (#1211) ORDERING DATE [11D]           May be used
 ;^ (#1212) ALTERNATE DRUG NAME [12F]                    May be used
 ;^ (#1213) ANCILLARY POV [13P:80] ^                     May be used
 ; (#1501) DATE PASSED TO EXTERNAL [1D] ^                Not used
 ;
 N VFD55,VFDATA,VFDB,VFDCMT,VFDD0,VFDGVN,VFDPPR,VFDPR,VFDTYPE,VFDUNT S VFDCMT=""
 D GETS^DIQ(53.79,VFDIEN_",","**","I",$NA(VFDATA))
 S VFDR=$NA(VFDFDA(9000010.14,VFDVMIEN_",")),VFDB=$NA(VFDATA(53.79,VFDIEN_","))
 S @VFDR@(.02)=@VFDB@(.01,"I") ;PATIENT IEN (DFN)
 S VFDVIEN=$$VISIT(@VFDB@(.01,"I"),@VFDB@(.06,"I"))
 S:VFDVIEN @VFDR@(.03)=VFDVIEN ;VISIT IEN
 S VFD55=@VFDB@(.11,"I"),VFDTYPE=$E(VFD55,$L(VFD55)) ;File 55 order# + U or V
 S VFDD0=$$DD0(VFDIEN) ;DISPENSE DRUG 0-node iff exactly one dispense drug
 S VFDGVN=$P(VFDD0,U,3) S:VFDGVN @VFDR@(.06)=VFDGVN ;DOSES GIVEN (numeric units)
 S VFDUNT=$P(VFDD0,U,4) S:VFDUNT]"" VFDCMT="UNIT="_VFDUNT ;UNIT OF ADMINISTRATION
 S:@VFDB@(.06,"I") @VFDR@(1201)=@VFDB@(.06,"I") ;EVENT (ACTION) DATE.TIME
 S VFDPR=$$UVPR(@VFDR@(.02),VFD55)
 S:VFDPR @VFDR@(1202)=+VFDPR ;ORDERING PROVIDER (#.09 is marked for deletion)
 S VFDPPR=$$INPR(@VFDR@(.02),@VFDB@(.06,"I"))
 S:VFDPPR @VFDR@(1204)=+VFDPPR ;PRIMARY PROVIDER, if inpatient
 S:$L(VFDCMT) @VFDR@(1101)=VFDCMT ;COMMENT
 ; 
 D FILE^DIE(,$NA(VFDFDA))
 Q
VISIT(VFDFN,VFDT) ;[Private] Return VISIT associated with BCMA MEDICATION LOG entry
 ; VFDFN=[Required] PATIENT internal entry number
 ; VFDT=[Optional] Fileman date.time of medication administration
 ;                 ACTION DATE/TIME defaults to NOW
 ;
 I $G(VFDFN)>0 S VFDT=$G(VFDT,$$NOW^XLFDT)
 E  D  Q ""
 .D XCPT(,,"Patient IEN required for $$VISIT()",,2," V MED IEN="_$G(VFDVMIEN))
 .Q
 N DFN,VAIP,VFDVIEN S DFN=VFDFN,VAIP("D")=$P(VFDT,".") D IN5^VADPT ;INPATIENT
 I $G(VAIP(13))>0 S VFDVIEN=$$GET1^DIQ(405,VAIP(13),.27,"I") Q:VFDVIEN>0 VFDVIEN
 I $G(VAIP(13))>0 D
 .D XCPT(,,"Admission VISIT not found",,2,"File 405 IEN="_VAIP(13))
 .Q
 ; Either not INPATIENT or no correlated inpatient VISIT..
 K ^TMP("PXHSV",$J) D VISIT^PXRHS01(VFDFN,VFDT,,,"DX")
 I '$O(^TMP("PXHSV",$J,0)) D  Q ""
 .D XCPT(,,"No qualifying VISIT found",,2,"DFN="_VFDFN_", VDT="_VFDT_", V MED IEN="_$G(VFDVMIEN))
 .Q
 N VFDIDT,VFDSC,VFDQ S (VFDVIEN,VFDQ)=0
 S VFDIDT="" F  S VFDIDT=$O(^TMP("PXHSV",$J,VFDIDT)) Q:VFDQ!'VFDIDT  D
 .S VFDVIEN=0 F  S VFDVIEN=$O(^AUPNVSIT("AA",VFDFN,VFDIDT,VFDVIEN)) Q:VFDQ!'VFDVIEN  D
 ..S VFDSC=$P($G(^AUPNVSIT(VFDVIEN,0)),U,7) I VFDSC]"" S VFDQ="DX"[VFDSC
 ..Q
 .Q
 Q:VFDVIEN VFDVIEN
 I '$O(^TMP("PXHSV",$J,0)) D  Q ""
 .D XCPT(,,"No qualifying 'D' or 'X' VISIT found",,2,"DFN="_VFDFN_", VDT="_VFDT_", V MED IEN="_$G(VFDVMIEN))
 .Q
 S VFDIDT="" F  S VFDIDT=$O(^TMP("PXHSV",$J,VFDIDT)) Q:VFDIEN!'VFDIDT  D
 .S VFDVIEN=$O(^AUPNVSIT("AA",VFDFN,VFDIDT,0)) ;Most qualifying VISIT
 .Q
 Q:VFDVIEN VFDVIEN  ;Next should be unreachable!
 D  Q ""
 .D XCPT(,,"No qualifying VISIT found",,2,"DFN="_VFDFN_", VDT="_VFDT_", V MED IEN="_$G(VFDVMIEN))
 .Q
 ;
DD0(VFDIEN) ;[Private] If one and only one DISPENSE DRUG multiple entry
 ; return 0-node of that entry.
 ; 
 ; VFDIEN=[Required] BCMA MEDICATION LOG IEN
 ; 
 I $G(VFDIEN)>0 N VFDDIEN S VFDDIEN=$O(^PSB(53.79,VFDIEN,.5,0))
 E  Q ""
 I VFDDIEN,VFDDIEN=$O(^PSB(53.79,VFDIEN,.5," "),-1) Q $G(^(VFDDIEN,0))
 Q ""
 ;
UVPR(VFDFN,VFD55) ;[Private] UNIT DOSE or IV order PROVIDER (pointer to File 200)
 ; VFDFN=[Required] PATIENT IEN (File 55 IEN)
 ; VFD55=[Required] ORDER NUMBER with SUFFIX
 ; 
 I $G(VFDFN)>0,$G(VFD55)>0 N VFDATA,VFDFLD,VFDIEN,VFDSUBDD,VFDTYPE,VFDY
 E  Q ""
 ;
 S VFDTYPE=$E(VFD55,$L(VFD55)),VFDFLD=$S(VFDTYPE="U":62,VFDTYPE="V":100,1:"")
 Q:'VFDFLD "" S VFDSUBDD=$S(VFDTYPE="U":55.06,VFDTYPE="V":55.01,1:"")
 ;
 S VFDIEN=$$FIND1^DIC(VFDSUBDD,","_VFDFN_",","X",+VFD55,"B") Q:'VFDIEN ""
 S VFDY=$$GET1^DIQ(VFDSUBDD,VFDIEN_","_VFDFN_",",$S(VFDTYPE="U":1,VFDTYPE="V":.06,1:""),"I")
 Q $S(VFDY:VFDY_U_$$GET1^DIQ(200,VFDY,.01),1:"")
 ;
INPR(DFN,VFDT) ;[Private] PRIMARY PROVIDER, if inpatient
 ; DFN=[Required] PATIENT IEN
 ; VFDT=[Required] Date.time of encounter
 ; 
 ; Return=PRIMARY CARE PHYSICIAN assigned to the patient in
 ;        internal^external format. (e.g., 3^SMITH,JACOB)
 ; 
 I $G(DFN)>0,$G(VFDT)>0 N VAIP S VAIP("D")=$P(VFDT,".")
 E  Q ""
 D IN5^VADPT Q $G(VAIP(7))
 ;
XCPT(VXDT,APPL,DESC,HLID,SVER,DATA,VFDXVARS) ;[Private] Record exception
 ; Wraps vxVistA exception handler
 S:'$L($G(APPL)) APPL="VXBCMA to VXPAMS INTERFACE"
 I $T(XCPT^VFDXX)]"" D XCPT^VFDXX(.VXDT,.APPL,.DESC,.HLID,.SVER,.DATA,.VFDXVARS)
 Q
