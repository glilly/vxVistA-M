VFDOR ;DSS/RAF GENERAL RPC UTILITIES ; 10/31/11 2:21pm
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 Q
HFLAB(VFDHFLST,DFN) ;loop thru the ^PXRMINDX xref looking for the most recent V HEALTH FACTOR entry identifying
 ; Called from RPC ???
 ; the reference lab preferred by the patient's insurance plan will be entered
 ; via reminder template. This RPC call will return a list of reference lab
 ; entries found in the HEALTH FACTORS file and if found, identify which one is
 ; the patient's most recent preferred lab.
 ; 
 ; For reference, the V HEALTH FACTORS are stored in ^AUPNVHF(
 ;
 ;DBIA# Description of all VistA APIs in the VFDMOS routines
 ;----- ------------------------------------------------------
 ;      $$FIND1^DIC
 ;      $$ROOT^DILFD
 ;      $$GET1^DIQ
 ;      $$NOW^XLFDT
 ;      fileman read of ^AUTTHF("AC"
 ;      fileman read of ^ORD(101.43
 ;      fileman read of ^PXRMINDX(9000010.23
 ;
 ;
 ; Input
 ;   DFN = IEN of patient in file 2
 ; Output
 ;   VFDHFLST(HF NAME_HF IEN)=<HF NAME>^<Date/Time>  If present, the d/t value identifies the current preferred lab
 ;   VFDHFLST(HF NAME_HR IEN)= . . .
 ;   The array will be returned in alphabetical order except for the last item for the IN-HOUSE
 ;
 N CNT,X,VFDVIEN,VFDVDT,VFDVLDT,VFDVLAB
 S X=$$X^VFDXTX("VFDOR~HFLAB",1)
 I $$TRIM^XLFSTR(X)'="" D  Q
 . X X
 ;
 S X=$$FIND1^DIC(9999999.64,,"X","LAB INTERFACE","B")  ;health factor category linked to all preferred lab entries
 S VFDVIEN=0 F  S VFDVIEN=$O(^AUTTHF("AC",X,VFDVIEN)) Q:'VFDVIEN  D
 .N VFDLNM
 .S VFDLNM=$$GET1^DIQ(9999999.64,VFDVIEN,.01,"E",)
 .S VFDHFLST(VFDLNM_VFDVIEN)=VFDVIEN_U_VFDLNM
 .S VFDVDT=$O(^PXRMINDX(9000010.23,"PI",DFN,VFDVIEN,""),-1) Q:VFDVDT=""  D  ;get most recent HF entry
 ..S VFDVDT(VFDVDT,VFDVIEN)=""
 I $O(VFDVDT(0)) D
 .N VFDVSUB,VFDVLDT,VFDVLAB
 .S VFDVLDT=$O(VFDVDT(""),-1),VFDVLAB=$O(VFDVDT(VFDVLDT,""))  ;gets the most recent preferred lab health factor
 .S VFDSUB=$$GET1^DIQ(9999999.64,VFDVLAB,.01,"E",)_VFDVLAB
 .S VFDHFLST(VFDSUB)=VFDHFLST(VFDSUB)_U_VFDVLDT  ;set date flag on preferred lab variable
 ;I $D(VFDHFLST) S VFDHFLST("ZZ")="^IN-HOUSE^"
 I '$D(VFDHFLST) D
 .S VFDHFLST(0)="-1^No preferred labs found in the Health Factor file."
 Q
 ;
 ;
ORDERID(VFDORLST,VFDEVNT) ;
 ; Pass CPRS order number(s) array and get group order ID back
 ; Called from RPC . . .
 ; Inputs
 ;  VFDORLST:<byref> Array of IDs for this group.
 ;           VFDORLST(1)= ORIFN (CPRS order number)
 ;           VFDORLST(2)= ORIFN . . .
 ;  VFDEVNT: set of codes: 0=UNKNOWN, 1=ORDER, 2=REPRINT, 3=PRINT
 ;
 ; Outputs
 ;  Returns the #21695 Order Groups Number (w checksum)
 ;      eg  123455
 ;  or  0^err #^err msg
 ;
 N X,OGN,VFDI,VFDOERR,VFDPKG,VFDLPREF,VFDPREF,VFDGLST
 N R94,ISLAB,DIERR,VFDMSG,STATUS
 ;K ^XTMP("VFDOR")
 ;S VFDEVNT=$G(VFDEVNT) ;seeing if this is necessary 3/16/10
 S VFDI=""
 F  S VFDI=$O(VFDORLST(VFDI)) Q:'VFDI  D  ;
 . ;call from ORWDX passed format ORIFN;1^1^1^E
 . S VFDOERR=+VFDORLST(VFDI) ;OERR #
 . S R94=$$GET1^DIQ(100,VFDOERR,12,"I","","VFDMSG") ; #9.4 IEN
 . S VFDPREF=$$GET1^DIQ(100,VFDOERR,33,"I","","VFDMSG") ; PKG REF
 . ;S ^XTMP("VFDOR","PKGREF",VFDOERR)=VFDPREF
 . ; When called from ORWDX, only lab orders appear to have been set
 . ;  and have a package reference entry
 . ;
 . S VFDGLST(VFDOERR)=""
 . S VFDGLST(VFDOERR,1)=VFDPREF
 . S VFDGLST(VFDOERR,2)=R94
 . ;
 . S ISLAB=(R94=$$GETPKG^VFDUOGF("LAB SERVICE"))
 . I ISLAB D  ;
 . . N VFDIENS,VFDCOL
 . . N R69,R6901,R6903
 . . ; Determine and update Package Reference
 . . S R69=$P(VFDPREF,";",2)
 . . S R6901=$P(VFDPREF,";",3)
 . . ;S ^XTMP("VFDOR","LABPASS",VFDOERR,$H)=""
 . . S R6903=$$OERR6903^VFDLAOGF(R69,R6901,"",VFDOERR,)
 . . I 'R6903 D  Q  ;
 . . . ;S ^XTMP("VFDOR","OERR6903-ERR",VFDOERR,$H)=R6903
 . . ;
 . . S VFDPREF=R69_";"_R6901_";"_R6903
 . . S VFDGLST(VFDOERR,1)=VFDPREF
 . . ;S ^XTMP("VFDOR",VFDOERR,"LPREF")=VFDPREF
 . . I "23"[VFDEVNT D  ;3=print, 2=reprint
 . . . ; get collection type
 . . . S VFDIENS=R6901_","_R69_","
 . . . S VFDCOL=$$GET1^DIQ(69.01,VFDIENS,4,"I","","VFDMSG")
 . . . ;screen out all but send patient (SP) orders
 . . . I VFDCOL'="SP" D  ;
 . . . . S VFDGLST(VFDOERR,"WC")=1  ;K VFDGLST(VFDOERR)
 . . . ; this flag is used to stop WC orders from being added to the ORM
 . . ;
 . ;
 ;
 S STATUS="0^1^No Group Assigned"
 I $D(VFDGLST) D  ;
 . S X=$$ADDGROUP^VFDUOGF(.VFDGLST,VFDEVNT)
 . S OGN=$P(X,U,2)
 . S STATUS=OGN
 ;
 ;====================================begin VXPRE/OS removal
 ;====================================================end VXPRE/OS removal
 Q STATUS
 ;
SCREEN(Y,FROM,DIR,XREF,VFDVLAB)  ;create screened subset of orderable items
 I $G(VFDVLAB)=0 Q
 I $T(TABPATH^VFDHHLOT)="" Q  ;this is needed in case a value for VFDLAB is passed
 ; Y(n)=IEN^.01 Name^.01 Name -or- IEN^Synonym <.01 Name>^.01 Name
 ; this is a modified copy of ORDITM^ORWDX and called from ORWDX
 N I,IEN,CNT,X,DTXT,CURTM,HL7XDREF,IEN60,FILE,REF,IENS
 ;S I=0,CNT=44,CURTM=$$NOW^XLFDT
 ;DSS/PDW create @GBL@("D",IEN60) ref for $D test for lab test IENs
 K HL7XDREF,VFDTRANS
 ;will need 2 more parameters SYS and TAB
 I +$G(VFDVLAB)>0 D
 .I '$D(^AUTTHF(VFDVLAB,0)) Q
 .S VFDTRANS=$P(^AUTTHF(VFDVLAB,0),U)
 .D TABPATH^VFDHHLOT(.REF,VFDTRANS,"VXLRORDER") ;=>REF=21625.0106^502,15,
 .I +REF D
 . .S FILE=+REF,IENS="1,"_$P(REF,U,2)
 . .S HL7XDREF=$$ROOT^DILFD(FILE,IENS,1) ;=>^VFDH(21625.01,15,30,502,10)
 . .S HL7XDREF=$NA(@HL7XDREF@("D")) ;=>^VFDH(21625.01,15,30,502,10,"D")
 ;DSS/PDW end SETUP of HL7X table mapping test
 S I=0,CNT=44,CURTM=$$NOW^XLFDT
 F  Q:I'<CNT  S FROM=$O(^ORD(101.43,XREF,FROM),DIR) Q:FROM=""  D
 . S IEN="" F  S IEN=$O(^ORD(101.43,XREF,FROM,IEN),DIR) Q:'IEN  D
 . . N VFDX
 . . S VFDX=^ORD(101.43,XREF,FROM,IEN)
 . . I +$P(VFDX,U,3),$P(VFDX,U,3)<CURTM Q
 . . Q:$P(VFDX,U,5)
 . . ;DSS/PDW START ;TEST $D(@..IEN60) is in VFD HL7x table 
 . . I $L($G(HL7XDREF)) S IEN60=+$P(^ORD(101.43,IEN,0),U,2) I $L(VFDX),'$D(@HL7XDREF@(IEN60)) Q
 . . ;DSS/PDW end ;TEST $D(@..IEN60) is in VFD HL7x table
 . . I $L($G(HL7XDREF)) I $$TRANS^VFDHHLOT(VFDTRANS,"VXLRORDER",+$G(IEN60),"HLT")<1 Q
 . . S I=I+1
 . . I 'VFDX S Y(I)=IEN_U_$P(VFDX,U,2)_U_$P(VFDX,U,2)
 . . E  S Y(I)=IEN_U_$P(VFDX,U,2)_$C(9)_"<"_$P(VFDX,U,4)_">"_U_$P(VFDX,U,4)  ;I=I+1 
 Q
 ;
ENUM(DFN) ; look up alternate identifier for TTU patient
 ; 
 N VFDMRN
 S VFDMRN=$$ID^VFDDFN(DFN,,"MRN",,1)  ; DSS/RAF add 5th param to return null instead of -1^msg
 Q VFDMRN
 ;
AP(REF,ORID) ; utility needed to stop undefined LR7OB69 error when user
 ; selects an AP order then right clicks the RESULTS option
 N VFDTNAM,VFDSS,VFD10143,VFD60
 S VFD10143=$$VALUE^ORX8(+ORID,"ORDERABLE",,"I")
 S VFD60=$$GET1^DIQ(101.43,+VFD10143,2,"I","","VFDMSG")
 S VFDSS=$$GET1^DIQ(60,+VFD60_",",4,"I","VFDMSG")
 S VFDTNAM=$$GET1^DIQ(60,+VFD60_",",.01,"E","VFDMSG")
 I VFDSS="SP" D  Q REF
 .S ^XTMP("ORXPND",$J,1,0)=VFDTNAM
 .S ^XTMP("ORXPND",$J,2,0)="  "
 .S ^XTMP("ORXPND",$J,3,0)="This option is not available at this time for Anatomic Path results"
 .S REF=$NA(^XTMP("ORXPND",$J))
 S REF=""
 Q REF
