VFDTIU0 ;DSS/RAF - PATIENT DATA OBJECTS ; 03 Aug 2012 14:03
 ;;2011.1.1;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 7
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;ICR#  Supported Description
 ;----  ---------------------------------------------------------------
 ;      ^%DT
 ;      ^DIQ: $$GET1, GETS
 ;      $$DEM^VFDCDPT
 ;      $$CNVT^VFDCDT
 ;      $$APPT^VFDCVT0
 ;      $$ID^VFDDFN
 ;      ^%ZOSF("TEST")
 ;3647  EN^GMVPXRM
 ;3365  PROBL^ORQQPL3(.VFDLST,DFN,VFDCON)
 ;        same call used by CPRS problem list tab n PROB
 ;1647  FASTVIT^ORQQVI(.VFD,DFN,DT,DT)
 ;        used in both Vitals calls. Same call CPRS coversheet uses
 ;3366  AGET^ORWORR(.ROOT,DFN,"2^0",13,0,0,)
 ;        Used in RXTEXT to find free text RX orders for patient
 ;10103 ^XLFDT: $$FMADD, $$FMTE, $$NOW
 ;10105 $$SQRT^XLFMTH
 ;      
 ;2343  $$NAME^XUSER(DUZ,)
 ;        Returns user name in a mixed case First Last format in CUSER
 ;      ----------  FILE ACCESSES  ----------
 ;      FM read of file 9.4, field 1 using GET1^DIQ
 ;      FM read of file 52, field .01
 ;      FM read of file 100, fields .8*,5,22,33 using DIQ APIs
 ;      Direct global read of ^OR(100,"ACT"), ^OR(100,ien,0), ^(3)
 ;        ^OR(100,ien,4.5,1,2,seq,0)
 ;      Direct global read of ^DPT(dfn,21600,ien,0)
 ;      Direct global read of ^PXRMINDX(120.5,"IP",type,date,date,0)
 ;        ^PXRMINDX(120.5,"IP",8,dfn,date,0)
 ;
PNAME(DFN,FIRST) ; returns the patient name in FIRST LAST format
 ; Second paramter added to allow object to be used to also return the first name only
 ; FIRST=1 will strip off the last name
 ;
 N VFDDEM,VFDPNAME
 D KILL,DEM(.VFDDEM,DFN)
 I $G(VFDDEM(1))]"" S VFDPNAME=$P(VFDDEM(1),",",2)_" "_$P(VFDDEM(1),",")
 E  S VFDPNAME="-1^NO PATIENT NAME FOUND"
 I $G(FIRST)=1,VFDPNAME]"" S VFDPNAME=$P(VFDPNAME," ")
 Q VFDPNAME
 ;
NMADD(DFN) ; returns patient name and address information
 ; if temporary address in active, it will be used in this object
 N CNT,VFDDEM,SP,VFDCS,VFDPNAME
 S $P(SP," ",30)="",CNT=1
 D KILL,DEM(.VFDDEM,DFN)
 I $G(VFDDEM(1))]"" S VFDPNAME=$P(VFDDEM(1),",",2)_" "_$P(VFDDEM(1),",")
 S VFDCS=$G(VFDDEM(14))_", "_$G(VFDDEM(15))
 S ^TMP("VFDTIU0",$J,CNT,0)=$G(VFDPNAME),CNT=CNT+1
 S ^TMP("VFDTIU0",$J,CNT,0)=$S($G(VFDDEM(11))]"":$G(VFDDEM(11)),1:"Missing address information"),CNT=CNT+1
 I $L(VFDDEM(12)) S ^TMP("VFDTIU0",$J,CNT,0)=$G(VFDDEM(12)),CNT=CNT+1
 I $L(VFDDEM(13)) S ^TMP("VFDTIU0",$J,CNT,0)=$G(VFDDEM(13)),CNT=CNT+1
 S ^TMP("VFDTIU0",$J,CNT,0)=$G(VFDCS),CNT=CNT+1
 S ^TMP("VFDTIU0",$J,CNT,0)=$E(SP,1,$L($G(VFDCS))-5)_$G(VFDDEM(16)),CNT=CNT+1
 Q $$TMP
 ;
VITALS(DFN) ; returns all of today's vitals
 ;
 N NUM,SP,VFD,VFDATA,VFDATE,VFDOTH,VFDTIME,VFDVAL,VFDVIT
 S VFD(0)="",$P(SP," ",8)=""
 D KILL,FASTVIT^ORQQVI(.VFD,DFN,DT,DT)
 I $D(VFD(1)) D
 .S ^TMP("VFDTIU0",$J,1,0)="Vital Signs found for "_$$CNVT(DT)
 .S NUM=0 F  S NUM=$O(VFD(NUM)) Q:'NUM  I $D(VFD(NUM)) D
 ..S VFDATA=VFD(NUM),VFDVIT=$P(VFDATA,U,2),VFDVAL=$P(VFDATA,U,5),VFDATE=$$CNVT($P(VFDATA,U,4))
 ..S VFDOTH=$P(VFDATA,U,6),VFDTIME="@"_$P(VFDATE,"@",2)
 ..S ^TMP("VFDTIU0",$J,NUM+1,0)=VFDVIT_$E(SP,1,($L(SP)-$L(VFDVIT)))_VFDVAL_$E(SP,1,($L(SP)-$L(VFDVAL)))_VFDTIME_$E(SP,1,($L(SP)-$L(VFDTIME)))_"  "_VFDOTH
 E  S ^TMP("VFDTIU0",$J,1,0)="No Vitals results found for Today"
 Q $$TMP
 ;
VIT5D(DFN) ; returns all coversheet vitals within the last 5 days
 ;
 N NUM,SP,VFD,VFDBDT,VFDATE,VFDATA,VFDOTH,VFDTIME,VFDVAL,VFDVIT,X,Y
 ;set beginning date to T-5
 S X="T-5" D ^%DT S VFDBDT=Y
 S VFD(0)="",$P(SP," ",8)=""
 D KILL,FASTVIT^ORQQVI(.VFD,DFN,VFDBDT,DT)
 I $D(VFD(1)) D
 .S ^TMP("VFDTIU0",$J,1,0)="Most recent Vital Signs found between "_$$CNVT(VFDBDT)_" and "_$$CNVT(DT)
 .S NUM=0 F  S NUM=$O(VFD(NUM)) Q:'NUM  I $D(VFD(NUM)) D
 ..S VFDATA=VFD(NUM),VFDVIT=$P(VFDATA,U,2),VFDVAL=$P(VFDATA,U,5),VFDATE=$$CNVT($P(VFDATA,U,4))
 ..S VFDOTH=$P(VFDATA,U,6),VFDTIME="@"_$P(VFDATE,"@",2)
 ..S ^TMP("VFDTIU0",$J,NUM+1,0)=VFDVIT_$E(SP,1,($L(SP)-$L(VFDVIT)))_VFDVAL_$E(SP,1,($L(SP)-$L(VFDVAL)))_VFDATE_$E(SP,1,($L(SP)-$L(VFDATE)))_"  "_VFDOTH
 E  S ^TMP("VFDTIU0",$J,1,0)="No Vitals results found within the last 5 days"
 Q $$TMP
 ;
CUSER(DUZ) ; returns the name of the current user in First Last format
 Q $$NAME^XUSER(DUZ)
 ;
PHONE(DFN) ; returns the home and work phone number if available
 ;
 N VFDDEM
 D KILL,DEM(.VFDDEM,DFN)
 S ^TMP("VFDTIU0",$J,1,0)="Patient Phone Numbers"
 S ^TMP("VFDTIU0",$J,2,0)="Home: "_$S($G(VFDDEM(18))]"":$G(VFDDEM(18)),1:"No data found")
 S ^TMP("VFDTIU0",$J,3,0)="Work: "_$S($G(VFDDEM(19))]"":$G(VFDDEM(19)),1:"No data found")
 Q $$TMP
 ;
FAPPT(DFN) ; get next future appointment
 ;
 K ^TMP("VFDC",$J,"APPT") D KILL
 N VFDATA,VFDDATE,VFDNODE,VFDNUM,VFDRT,VFDSTOP,VNOW,X
 D NOW
 S VFDDATE=$$FMADD^XLFDT(VNOW,365)
 S VFDATA=DFN_U_VNOW_U_VFDDATE_U
 D APPT^VFDCVT0(.VFDRT,VFDATA,)
 S (VFDSTOP,VFDNUM)=0 F  S VFDNUM=$O(^TMP("VFDC",$J,"APPT",VFDNUM)) Q:'VFDNUM!VFDSTOP  I $D(^TMP("VFDC",$J,"APPT",VFDNUM)) D
 .S VFDNODE=^TMP("VFDC",$J,"APPT",VFDNUM)
 .S ^TMP("VFDTIU0",$J,1,0)=$P(VFDNODE,U)_"   "_$P(VFDNODE,U,2)
 .I $P(VFDNODE,U,3)>VNOW S VFDSTOP=1 Q
 I '$D(^TMP("VFDTIU0",$J,1,0)) S ^TMP("VFDTIU0",$J,1,0)="No future appointment found"
 Q $$TMP
 ;
LAPPT(DFN) ; get most recent past appointment
 ;
 K ^TMP("VFDC",$J,"APPT") D KILL
 N VFDATA,VFDNODE,VFDNUM,VFDRT,VNOW,X
 D NOW
 S VFDATA=DFN_U_U_VNOW_U
 D APPT^VFDCVT0(.VFDRT,VFDATA,)
 S VFDNUM=0 F  S VFDNUM=$O(^TMP("VFDC",$J,"APPT",VFDNUM)) Q:'VFDNUM  I $D(^TMP("VFDC",$J,"APPT",VFDNUM)) D
 .S VFDNODE=^TMP("VFDC",$J,"APPT",VFDNUM)
 .I $P(VFDNODE,U,3)>VNOW Q
 .S ^TMP("VFDTIU0",$J,1,0)=$P(VFDNODE,U)_"   "_$P(VFDNODE,U,2)
 I '$D(^TMP("VFDTIU0",$J,1,0)) S ^TMP("VFDTIU0",$J,1,0)="No past appointment found"
 Q $$TMP
 ;
PROB(DFN,VFDCON,VFDCAT) ; returns a list of both active and inactive problems
 ; VFDCON = context of the filter
 ;          "B" - returns both active and inactive problems
 ;          "I" - returns only inactive problems
 ;          "A" - returns only active probelms
 ; VFDCAT = category filter
 ;          "m" - returns problems assigned a category of med/surg
 ;          "f" - returns problems assigned a category of family
 ;          "s" - returns problems assigned a category of social
 ;          "u" - returns unassigned problems (not an official category but needed as a filter)
 ;          ""  - returns ALL problems, active and inactive if VFDCAT is null
 ;
 ; If VFDCON is not defined the default will be ACTIVE problems
 ;
 N CNT,VFDCATXT,VFDLST,VFDNUM
 S VFDCATXT=$S($G(VFDCAT)="m":"MED/SURG",$G(VFDCAT)="f":"FAMILY",$G(VFDCAT)="s":"SOCIAL",1:"")
 D KILL,PROBL^ORQQPL3(.VFDLST,DFN,$G(VFDCON))
 S CNT=2
 S VFDNUM=0 F  S VFDNUM=$O(VFDLST(VFDNUM)) Q:'VFDNUM  D
 .I $G(VFDCAT)]"" D
 ..I $P(VFDLST(VFDNUM),U,19)=$G(VFDCAT) D
 ...S ^TMP("VFDTIU0",$J,CNT,0)="     "_$P(VFDLST(VFDNUM),U,3)_"("_$P(VFDLST(VFDNUM),U,4)_")",CNT=CNT+1
 .I $G(VFDCAT)="" D  ;needed to build all problems when VFDCAT is passed as a null value
 ..S ^TMP("VFDTIU0",$J,CNT,0)="     "_$P(VFDLST(VFDNUM),U,3)_"("_$P(VFDLST(VFDNUM),U,4)_")",CNT=CNT+1
 .I $G(VFDCAT)="u",$P(VFDLST(VFDNUM),U,19)="" D
 ..S ^TMP("VFDTIU0",$J,CNT,0)="     "_$P(VFDLST(VFDNUM),U,3)_"("_$P(VFDLST(VFDNUM),U,4)_")",CNT=CNT+1
 I $D(^TMP("VFDTIU0",$J)),$G(VFDCAT)'="u" D
 .S ^TMP("VFDTIU0",$J,1,0)="All Active "_$G(VFDCATXT)_" Problems"
 I $D(^TMP("VFDTIU0",$J)),$G(VFDCAT)="u" D
 .S ^TMP("VFDTIU0",$J,1,0)="Unassigned Problems"
 I '$D(^TMP("VFDTIU0",$J)) S ^TMP("VFDTIU0",$J,1,0)="No Active "_$G(VFDCATXT)_" Problems found."
 Q $$TMP
 ;
DCMEDS(DFN) ; returns discontinued meds for a patient
 ; temporary work up code to find the best way to get dc'd meds
 ;
 ; the status codes used in this object are DC=1, DC/edit=12
 ;
 ; This code can be used until the ALL OUTPATIENT health summary gets fixed by having the 
 ; "P" and "P","A" nodes in ^PS(55, reindexed. After that has been corrected the following
 ; call can be used:
 ; D RPT^ORWRP(.ROOT,DFN,"OR_RXOP:ALL OUTPATIENT~RXOP;ORDV06;28;10",,,,)
 ; this will return all the meds for a patient that can be screened for status
 ;
 N VFDARRAY,VFDDATE,VFDDCDT,VFDNUM,VFDPREF,VFDORIFN,VFDRX,VFDSP,VFDSTA,VFDSTRNG,VFDSTXT,VFDTXT
 D KILL S $P(VFDSP,".",132)="."
 S CNT=2,VFDDATE=0 F  S VFDDATE=$O(^OR(100,"ACT",DFN_";DPT(",VFDDATE)) Q:'VFDDATE  D
 .S VFDNUM=0 F  S VFDNUM=$O(^OR(100,"ACT",DFN_";DPT(",VFDDATE,VFDNUM)) Q:'VFDNUM  D
 ..S VFDORIFN=0 F  S VFDORIFN=$O(^OR(100,"ACT",DFN_";DPT(",VFDDATE,VFDNUM,VFDORIFN)) Q:'VFDORIFN  D
 ...I $D(^OR(100,VFDORIFN,0)),($$GET1^DIQ(9.4,$P(^OR(100,VFDORIFN,0),U,14),1,"E")="PSO") D
 ....K VFDARRAY
 ....D GETS^DIQ(100,VFDORIFN,".8*","","VFDARRAY") S VFDPREF=$$GET1^DIQ(100,VFDORIFN,33,"I")
 ....S VFDRX=$$GET1^DIQ(52,VFDPREF,.01,"I"),VFDSTA=$P(^OR(100,VFDORIFN,3),U,3)
 ....Q:$G(VFDRX)=""  ; bad VFDPREF pointer may cause subscript error if null value passes this point
 ....S VFDDCDT=$P($$GET1^DIQ(100,VFDORIFN,22,"E"),"@")
 ....I (VFDSTA=1)!(VFDSTA=12) D
 .....; formatting the output
 .....S VFDTXT=$G(VFDARRAY(100.008,"1,"_VFDORIFN_",",.1,1)),VFDSTXT=$$GET1^DIQ(100,VFDORIFN,5,,"E")
 .....S VFDSTRNG=" "_VFDTXT,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,57-$L(VFDSTRNG))
 .....S VFDSTRNG=VFDSTRNG_VFDRX,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,67-$L(VFDSTRNG))
 .....S VFDSTRNG=VFDSTRNG_VFDDCDT,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,76-$L(VFDSTRNG))
 .....S ^TMP("VFDTIU0",$J,+$G(VFDRX),0)=VFDSTRNG_"   "_VFDORIFN
 .....;S ^TMP("VFDTIU0",$J,CNT,0)=VFDSTRNG,CNT=CNT+1
 I '$D(^TMP("VFDTIU0",$J)) S ^TMP("VFDTIU0",$J,1,0)="No discontinued medications found."
 E  S ^TMP("VFDTIU0",$J,1,0)="Discontinued Medications                                 Rx #        Dc Date"
 Q $$TMP
 ;
EXPMEDS(DFN) ; returns a list of expired meds for a patient
 ; temporary work up code to find the best way to get expired meds
 ; the status used for this screen is Expired=7
 ;
 ; This code can be used until the ALL OUTPATIENT health summary gets fixed by having the 
 ; "P" and "P","A" nodes in ^PS(55, reindexed. After that has been corrected the following
 ; call can be used:
 ; D RPT^ORWRP(.ROOT,DFN,"OR_RXOP:ALL OUTPATIENT~RXOP;ORDV06;28;10",,,,)
 ; this will return all the meds for a patient that can be screened for status
 ;
 N CNT,VFDARRAY,VFDPREF,VFDORIFN,VFDRX,VFDSP,VFDSTA,VFDSTRNG,VFDSTDT,VFDSTXT,VFDTXT
 D KILL S $P(VFDSP,".",132)="."
 S CNT=2,VFDORIFN=0 F  S VFDORIFN=$O(^OR(100,VFDORIFN)) Q:'VFDORIFN  D
 .I $D(^OR(100,VFDORIFN,0)) I $P(^OR(100,VFDORIFN,0),U,2)=(DFN_";DPT(")&($P(^OR(100,VFDORIFN,0),U,14)=60) D
 ..D GETS^DIQ(100,VFDORIFN,".8*","","VFDARRAY") S VFDPREF=$$GET1^DIQ(100,VFDORIFN,33,"I")
 ..S VFDRX=$$GET1^DIQ(52,VFDPREF,.01,"I"),VFDSTA=$P(^OR(100,VFDORIFN,3),U,3)
 ..S VFDSTDT=$P($$GET1^DIQ(100,VFDORIFN,22,"E"),"@")
 ..I VFDSTA=7 D
 ...; formatting the output
 ...S VFDTXT=$G(VFDARRAY(100.008,"1,"_VFDORIFN_",",.1,1)),VFDSTXT=$$GET1^DIQ(100,VFDORIFN,5,,"E")
 ...S VFDSTRNG="  "_VFDTXT,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,65-$L(VFDSTRNG))
 ...S VFDSTRNG=VFDSTRNG_VFDRX,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,76-$L(VFDSTRNG))
 ...S VFDSTRNG=VFDSTRNG_VFDSTDT,VFDSTRNG=VFDSTRNG_$E(VFDSP,1,85-$L(VFDSTRNG))
 ...S ^TMP("VFDTIU0",$J,CNT,0)=VFDSTRNG,CNT=CNT+1
 I '$D(^TMP("VFDTIU0",$J)) S ^TMP("VFDTIU0",$J,1,0)="No expired medications found."
 E  S ^TMP("VFDTIU0",$J,1,0)="Expired Medications                                              Rx #       Expiration Date"
 Q $$TMP
 ;
RXTEXT(DFN) ; find all pharmacy text order for a patient
 ; gets list of all Nursing orders for patient
 ; DFN=patient IEN from file 2
 ; 13 = nursing orders display group
 ; Returns data in ^TMP("ORR",$J)
 ;
 N I,J,H,Z,CNT,COMM,END,EDT,LINE,NXT,QUIT,ORD,ROOT,SDT,VAR,VAR1,VFD,ORD
 D KILL,AGET^ORWORR(.ROOT,DFN,"2^0",13,0,0)
 S H=$O(^TMP("ORR",$J,"")),NXT=.9
 F  S NXT=$O(^TMP("ORR",$J,H,NXT)) Q:'NXT  D
 . I $D(^TMP("ORR",$J,H,.1)) S ORD=+$G(^(NXT)) D
 . . S I=0 F  S I=$O(^OR(100,ORD,4.5,I)) Q:'I  D
 . . . S J=0 F  S J=$O(^OR(100,ORD,4.5,I,J)) Q:'J  D
 . . . . ;Rx Text orders will have ~99 on the first line
 . . . . I $G(^OR(100,ORD,4.5,I,J,1,0))["~99" S VFD(ORD)="" Q
 S (I,END,QUIT)=0,CNT=3 F  S I=$O(VFD(I)) Q:'I  D
 . K VAR,VAR1 S END=0
 . F J=1:1 Q:'$D(^OR(100,I,4.5,J))  I $G(^(J,0))["COMMENT" S COMM=J Q
 . S Z=$G(^OR(100,I,0)),SDT=$$DATE($P(Z,U,8)),EDT=$$DATE($P(Z,U,9))
 . S (H,QUIT)=0
 . F  S H=$O(^OR(100,I,4.5,COMM,2,H)) Q:'H  D  I END D LINE Q:END
 . . S VAR=$G(^OR(100,I,4.5,COMM,2,H,0))_"~",VAR1=$G(VAR1)_VAR
 . . I $G(^OR(100,I,4.5,COMM,2,H,0))["$" S END=1
 I $D(LINE) D
 . M ^TMP("VFDTIU0",$J)=LINE
 . S ^TMP("VFDTIU0",$J,1,0)="All Free Text Pharmacy Orders"
 . S ^TMP("VFDTIU0",$J,2,0)=""
 . Q
 E  S ^TMP("VFDTIU0",$J,1,0)="No Free Text Pharmacy Orders found"
 Q $$TMP
 ;
ELMRN(DFN) ; return MRN from alternative identifier in file 2
 ;
 N VFDMRN
 S VFDMRN=$$ID^VFDDFN(DFN,,"MRN",,1)
 Q VFDMRN
 ;
VIT1(DFN,TYPE) ; Individual Vitals call - returns the value of the latest vital sign passed in
 ; TYPE = IEN from Vitals Type file 120.51
 ; This will only work with date type vitals like EDD(24) and LMP(23)
 ; CIRCUMFERENCE/GIRTH 120.51 = 20
 N DATE,EDATE,IEN,QUAL,VAL,VITALS
 S (EDATE,VAL)=0
 S QUAL=""
 I '$D(^PXRMINDX(120.5,"IP",TYPE,DFN)) Q "No results found for "_$$GET1^DIQ(120.51,TYPE,.01,"E",)
 S DATE=$O(^PXRMINDX(120.5,"IP",TYPE,DFN,""),-1)  ;get most recent date
 I DATE S IEN=$O(^PXRMINDX(120.5,"IP",TYPE,DFN,DATE,0)) Q:'IEN  D
 .D EN^GMVPXRM(.VITALS,IEN)
 .I (TYPE=23)!(TYPE=24) S EDATE=+VITALS(7)
 .I 'EDATE S VAL=+VITALS(7)
 .S SEQ=0 F  S SEQ=$O(VITALS(12,SEQ)) Q:'SEQ  D
 ..I +$G(VITALS(12,SEQ))>0 S QUAL=$G(QUAL)_$P(VITALS(12,SEQ),U,2)_","
 .;remove the trailing comma from the QUAL variable
 .I $D(QUAL) S QUAL=$E(QUAL,1,($L(QUAL)-1)),QUAL=$E(QUAL,1,44)
 I VAL I TYPE=20 Q $J(VAL,2,1)_" inches"_$S('$L(QUAL):"",1:"  Qualifier(s): "_$G(QUAL))
 I VAL Q VAL_$S('$L(QUAL):"",1:"  Qualifier(s): "_$G(QUAL))
 I EDATE Q $$CNVT(EDATE)_"  "_$S('$L(QUAL):"",1:"  Qualifier(s): "_$G(QUAL))
 ; the call above id OK without the first parameter but xindex will flag it
 I 'EDATE Q "No results found for "_$$GET1^DIQ(120.51,TYPE,.01,"E",)
 Q
 ;
BSA(DFN) ; calculate BSA from height in cm and weight in kg
 ; WEIGHT IEN from 120.51 = 9
 ; HEIGHT IEN from 120.51 = 8
 ;
 N HEIGHT,WEIGHT,NOHEIGHT,NOWEIGHT,VAL
 S (HEIGHT,NOHEIGHT,NOWEIGHT,VAL,WEIGHT)=0
 ; get weight and divide it by 2.2 to convert to kg
 S WEIGHT=$$WEIGHT(DFN)
 ;I +$G(WEIGHT)=0 Q "No wieight found. Can not calculate the BSA"
 I +$G(WEIGHT)>0 S WEIGHT=$J((WEIGHT/2.2),2,2)
 ; get height and multiply it times 2.54 to convert to cm
 S HEIGHT=$$HEIGHT(DFN)
 I +$G(HEIGHT)>0 S HEIGHT=$J((HEIGHT*2.54),2,2)
 I +$G(HEIGHT)>0,+$G(WEIGHT)>0 S VAL=((HEIGHT*WEIGHT)/3600) Q "BSA= "_$$SQRT^XLFMTH(VAL,3)
 I 'HEIGHT S NOHEIGHT=1
 I 'WEIGHT S NOWEIGHT=1
 I NOHEIGHT!NOWEIGHT Q "Missing value(s) for height and/or weight. Could not calculate the BSA."
 Q
 ;
BMI(DFN) ; caclulate the Body Mass Index from the hieght in inches and weight in pounds.
 ;calculation: (weight in lbs/(height in inches x height in inches) x 703
 N BMI,HGT,WGT
 S (BMI,HGT,WGT)=0
 S HGT=$$HEIGHT(DFN),WGT=$$WEIGHT(DFN)
 I 'HGT!'WGT Q "No value found for Height and/or Weight. Could not calculate the BMI"
 I +$G(WGT)>0,+$G(HGT)>0 S BMI=WGT/(HGT*HGT)*703
 I +$G(BMI)>0 Q $J(BMI,2,1)
 Q
 ;
LAST4(DFN) ; returns the last four of the SSN for a patient
 N VFDDEM
 D DEM(.VFDDEM,DFN)
 I '$L(VFDDEM(2)) Q "No SSN on record"
 Q $P(VFDDEM(2),"-",3)
 ;
LASTDCDT(DFN)  ; find the last discharge date/time
 ; DFN = PATIENT IDENTIFIER
 ; TEST = [requuired] return 1 or zero based on true or false
 ; DATE = [required] returns FM date
 ; VALUE = [optional] display value for reminder
 ; TEXT = [optional] display text
 ; VAIP(13) = IEN of admission in patient movement file
 ; VAIP(13,1) = admission date/time (FM) in 1st piece
 ; VAIP(17) = IEN of discharge in patient movement file
 ; VAIP(17,1) = discharge date/time (FM) in 1st piece
 N VAIP
 S VAIP("D")="LAST",(VALUE,TEST)=0,(DATE,TEXT)=""
 D IN5^VADPT
 S DATE=$P(VAIP(17,1),U) I +DATE>0 Q $$DATE(DATE)
 E  Q "No discharge date found"
 Q
 ;=============== U T I L I T I E S ============================
WEIGHT(DFN) ; <private> finds most recent patient weight needed for object calculations
 ; check to see if VistA always stores the value in pounds
 ; IEN of weight vital sign is 9
 N DATE,WEIGHT,IEN
 S (DATE,IEN,WEIGHT)=0
 S DATE=$O(^PXRMINDX(120.5,"IP",9,DFN,""),-1)  ;get most recent date for weight
 I DATE S IEN=$O(^PXRMINDX(120.5,"IP",9,DFN,DATE,0)) Q:'IEN  D
 .D EN^GMVPXRM(.VITALS,IEN)
 .S WEIGHT=+VITALS(7)
 .K IEN,VITALS
 I $G(WEIGHT) Q WEIGHT
 I '$G(WEIGHT) Q 0
 Q
 ;
TMP() Q "~@"_$NA(^TMP("VFDTIU0",$J))
KILL K ^TMP("VFDTIU0",$J) Q
 ;
NOW() S VNOW=$E($$NOW^XLFDT,1,12) Q
 ;
LINE ; <private> compose LINE() array to merge once done
 ; this code is part of RXTEXT free text pharmacy object
 Q:'$D(VAR1)  N CNT2 S CNT2=3
 F  D  Q:QUIT
 .I $P(VAR1,"~",CNT2)["$" D  Q
 ..S LINE(CNT,0)="Start Date: "_SDT_"   End Date: "_EDT,CNT=CNT+1
 ..S LINE(CNT,0)="",QUIT=1,CNT=CNT+1
 .;$P(VAR1,"~",CNT2)'["$" is true at this point
 .S LINE(CNT,0)=$P(VAR1,"~",CNT2),CNT=CNT+1,CNT2=CNT2+1
 Q
 ;
HEIGHT(DFN) ;<private>  finds the most recent patient height needed for object calculations
 ; check to see if VistA always stores the value in inches
 ; IEN of height vital sign is 8
 N DATE,HEIGHT,IEN
 S DATE=$O(^PXRMINDX(120.5,"IP",8,DFN,""),-1)  ;get most recent date for height
 I DATE S IEN=$O(^PXRMINDX(120.5,"IP",8,DFN,DATE,0)) Q:'IEN  D
 .D EN^GMVPXRM(.VITALS,IEN)
 .S HEIGHT=+VITALS(7)
 .K IEN,VITALS
 I $G(HEIGHT) Q HEIGHT
 I '$G(HEIGHT) Q 0
 Q
 ;
DATE(X) N I,J,H,Y,Z S Y=$G(X) S:Y Y=$$FMTE^XLFDT(X) Q Y
 ;
DEM(VFDDEM,DFN) ; <private> demographics utility call
 D DEM^VFDCDPT(.VFDDEM,DFN)
 Q
 ;
CNVT(VFDDATE) ; <private> date conversion utility call
 Q $$CNVT^VFDCDT(,VFDDATE,"F","E",,,1)
 Q
 ;
APPT(XXX,YYY) ; <private> returns appointment information
 Q
