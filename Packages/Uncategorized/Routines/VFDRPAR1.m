VFDRPAR1 ;DSS/WLC - ARRA STANDARD REPORTING ; 06/03/2011 11:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
EN(RPT) ; OPTIONS: VFD ARRA EMER DEPT 1 REPORT
 ;                 VFD ARRA EMER DEPT 2 REPORT
 N I,X,Y,Z,START,END,VFD1
 S RPT=$G(RPT)
 I RPT'=1,RPT'=2 W !!?3,"Invalid report number received" Q
 Q:$$DATE^VFDCFM(.START,.END,1)<1
 S Z="EN"_RPT_"(.VFD1,START,END,RPT)" D @Z W !!,VFD1
 Q
 ;
EN1(VFD1,START,END,REPORT) ; RPC:  VFD ARRA ED-1
 D EN2(.VFD1,$G(START),$G(END),1)
 Q
 ;
EN2(VFD1,START,END,REPORT) ; RPC:  VFD ARRA ED-2
 N I,X,Y,Z,VFD
 S REPORT=$G(REPORT) S:'REPORT REPORT=2
 D CLN,ERV(.VFD,START,END,REPORT)
 I +$G(@VFD@(0))=-1 S VFD1=^(0) Q
 ; ixml is expecting vfd(n) where n is numeric
 D IXML^VFDRPARX(.VFD1,"VFDRPAR1",START,END,.VFD)
 D CLN
 Q
 ;
ERV(VFDREP,START,END,REPORT)  ; RPC:  VFD ARRA REPORTS
 ; NQF 0495 - Emergency Dept Report 1
 ;  Population - all patients seen in ED who were admitted
 ;   Numerator - median time in minutes (depart-arrival)
 ; Denominator -
 ;   1.1 - all ED visits - (Observation + Mental Health)
 ;   1.2 - All ED observation encounters
 ;   1.3 - All ED encounters for patients with a Dx of Psych/MH
 ;
 ; NQF 0495 - Emergency Dept Report 2
 ;  Same criteria for ED Report 1 except instead of ED arrival date,
 ;  the starting time will be the time when the decision to admit was
 ;  made.  If there is no record of decision to admit time, then
 ;  count encounter in totals (denominator) but do no include the ED
 ;  time (depart_time - decide_time) in the numerator data set for
 ;  calculating median times.
 ;
 ;Description of ^TMP("VFDRPAR1",$J)
 ; ^TMP("VFDRPAR1",$J,"MOVE",ADM)=p1^p2^...^p8 where
 ;     ADM = admission movement ien     p5 = ED LOS (minutes)
 ;      p1 = DFN                        p6 = ED visit date
 ;      p2 = admit ward (ien;name)      p7 = ED check-in
 ;      p3 = Boolean MH visit           p8 = ED check-out
 ;      p4 = admit LOS
 ; ^TMP("VFDRPAR1",$J,"ENC",n)=total number of ED encounters where
 ;      n = OBS or MH or OTHER or TOTAL
 ; ^TMP("VFDRPAR1",$J,"TIDFF",n) = median time in ED where
 ;      n = OBS or MH or OTHER or TOTAL
 ; ^TMP("VFDRPAR1",$J,"TDIFF",n,time)=total number of instances
 ;      n = OBS or MH or OTHER or TOTAL
 ;   time = # minutes spent in ED
 ; Note: TOTAL<(OBS+MH+OTHER) since could have a MH OBS
 ;
 N I,J,X,Y,Z,CLIN,DATTIME,LOS,SDARRY,SDDATE,SDDFN
 S VFDREP=$NA(^TMP("VFDRPAR1",$J)) K @VFDREP
 S START=$G(START) I START'?7N S @VFDREP@(0)="-1^invalid Start date." Q
 S END=$G(END) S:'END END=DT S END=END\1+.24
 I END<START S @VFDREP@(0)="-1^Start date is after End date." Q
 S CLIN=$$FIND1^DIC(44,,"X","EMERGENCY ROOM")
 S DATTIME=$$NOW^XLFDT
 ; next two lines only relevant for report 2
 S ADT=$$FIND1^DIC(101.43,,"X","ADMISSION DECISION TIME")
 S PMZ=$$FIND1^DIC(101.41,,"X","PMZ ADMISSION DECISION TIME")
 ; get all encounters in ED for date range
 S SDARRAY(1)=START_";"_END
 S SDARRAY(2)=CLIN
 S SDARRAY("FLDS")="1;2;3;4;9;11;12;22"
 S SDARRAY("SORT")="P"
 ; ^TMP($J,"SDAMA301",dfn,encounter_date_time)
 I $$SDAPI^SDAMA301(.SDARRAY)>0 D
 . S SDDFN=0 F  S SDDFN=$O(^TMP($J,"SDAMA301",SDDFN)) Q:SDDFN=""  D
 . . ; exclude patients from population if age less than 18
 . . Q:$$AGE(+SDDFN)  S SDDATE=0
 . . F  S SDDATE=$O(^TMP($J,"SDAMA301",SDDFN,SDDATE)) Q:SDDATE=""  D
 . . . N ADM,DECIDE,LOC,LOS,MH,OBS,PROV,SDAPPT,SDCKIN,SDCKOT,VDIF,VISIT
 . . . S SDAPPT=^TMP($J,"SDAMA301",SDDFN,SDDATE) ;appointment data
 . . . S VISIT=0,X=$P(SDAPPT,U,12) I X>0 S VISIT=$P(^SCE(X,0),U,5)
 . . . S SDCKIN=$P(SDAPPT,U,9) ; Check-in
 . . . S:'SDCKIN SDCKIN=SDDATE
 . . . S SDCKOT=$P(SDAPPT,U,11) ; Check-out
 . . . ; if report 2, +DECIDE means that there was a decide to admit
 . . . ; data filed.  If so, then SDCKIN means admit decision d/t
 . . . ; If not, the SDCKIN left unchanged.
 . . . I REPORT=2 S DECIDE=$$DECIDE(SDDFN)
 . . . ; check if patient was admitted, if not exclude from population
 . . . Q:'$$INPAT(SDDFN,SDCKOT\1,SDCKOT)
 . . . Q:LOS>120  ; if admit LOS>120 exclude
 . . . S OBS=LOC["OBSERVATION" ; Boolean as to admitted for observation
 . . . S MH=$$MH(VISIT) ; Boolean indicate psych/MH
 . . . S VDIF=$$FMDIFF^XLFDT(SDCKOT,SDCKIN,2)+.5\60
 . . . ; record each record found just in case
 . . . S X=SDDFN_U_$TR(LOC,U,";")_U_MH_U_LOS_U_VDIF_U_SDDATE_U_SDCKIN_U_SDCKOT
 . . . S @VFDREP@("MOVE",ADM)=X
 . . . ; get data to calculate median times
 . . . ; count total number of encounters
 . . . S ^("TOTAL")=1+$G(@VFDREP@("ENC","TOTAL"))
 . . . I OBS S ^("OBS")=1+$G(@VFDREP@("ENC","OBS"))
 . . . I MH S ^("MH")=1+$G(@VFDREP@("ENC","MH"))
 . . . I 'OBS,'MH S ^("OTHER")=1+$G(@VFDREP@("ENC","OTHER"))
 . . . ; if report 1 or report=2&decide, then add time span
 . . . I REPORT=2,'DECIDE Q
 . . . ; count number of individual encounter times lengths
 . . . S ^(VDIF)=1+$G(@VFDREP@("TDIFF","TOTAL",VDIF))
 . . . I OBS S ^(VDIF)=1+$G(@VFDREP@("TDIFF","OBS",VDIF))
 . . . I MH S ^(VDIF)=1+$G(@VFDREP@("TDIFF","MH",VDIF))
 . . . I 'OBS,'MH S ^(VDIF)=1+$G(@VFDREP@("TDIFF","OTHER",VDIF))
 . . . S ^(X)=1+$G(@VFDREP@("ENC",X))
 . . . Q
 . . Q
 . Q
 ; calculate median times and values for report
 ; set up global for XML generator
 S I=0 F Z="OTHER","OBS","MH" D
 . S I=I+1,X=$NA(@VFDREP@("TDIFF",Z))
 . S Y=0 I $D(@X) S Y=$$MEDIAN(X),@X=Y
 . S @VFDREP@(I,"NOTMET")=0
 . S J=$S(REPORT=1:"0495",1:"0497")
 . S @VFDREP@(I,"PQRI")="NQF "_J
 . S @VFDREP@(I,"EXCL")=0
 . S @VFDREP@(I,"MEETS")=Y ; median time
 . S @VFDREP@(I,"ELIG")=$G(@VFDREP@("ENC",Z))
 . Q
 Q
 ;
 ;----------------------- PRIVATE SUBROUTINES  ------------------------
AGE(DFN) Q $$GET1^DIQ(2,DFN_",",.033)<18
 ;
CLN  ; clean up temp globals
 K ^TMP($J,"SDAMA301"),^TMP("VFDRPAR1")
 Q
 ;
DECIDE(DFN) ; extrinsic function to find decision to admit time
 ; Boolean value indicates whether or not to include the ED time in the
 ; numerator data set.
 N I,J,K,X,Y,Z,VFDRET,VFLG
 I $G(DFN)<1 Q 0
 D AGET^ORWORR(.VFDRET,DFN)
 S I="",VFLG=0 F  S I=$O(^TMP("ORR",$J,I)) Q:I=""  S J=0 D  Q:VFLG
 . F  S J=$O(^TMP("ORR",$J,I,J)) Q:'J  S Y=+^(J) D  Q:VFLG
 . . N I,J,DATE,IENS S IENS="1,"_Y_","
 . . Q:$$GET1^DIQ(100.001,IENS,.01,"I")'=ADT
 . . S Y=+$P(IENS,",",2),K=0
 . . F  S K=$O(^OR(100,Y,4.5,K)) Q:'K  I $P(^(K,0),U,2)=PMZ D  Q:VFLG
 . . . S DATE=+$G(^OR(100,Y,4.5,K,1))
 . . . I DATE,DATE'<SDCKIN,DATE'>SDCKOT S SDCKIN=DATE,VFLG=1
 . . . Q
 . . Q
 . Q
 K ^TMP("ORR",$J)
 Q VFLG
 ; 
INPAT(DFN,DATE,APPT) ; was the patient an inpatient for date
 ;  DFN - req - pointer to the patient file
 ; DATE - req - FM date to determine if patient an inpatient
 ; APPT - opt - FM date.time - if time >2200 AND patient not an
 ;        inpatient on DATE, then see if patient was an inpatient
 ;        on DATE+1
 ;Extrinsic function - Boolean - 1:patient an inpatient
 ;This will set and leave defined local variables: ADM,LOC,LOS,PROV
 ;
 N I,X,Y,Z,ADMDT,VA,VAIP
 S VAIP("D")=DATE\1 D IN5^VADPT
 ; if not an inpatient, check for next day
 I '$G(VAIP(13)) D  I '$G(VAIP(13)) Q 0
 .Q:'$G(APPT)  S Y=$P(APPT,".",2) Q:Y<2200
 .K VAIP S VAIP("D")=$$FMADD^XLFDT(DATE\1,1) D IN5^VADPT
 .Q
 S ADM=+VAIP(13),ADMDT=+VAIP(13,1) ; admission movement ifn
 ; visit date.time if after admission date.time
 I APPT,APPT>ADMDT Q 0
 ; does type of movement indicate from ED?
 I $$GET1^DIQ(405,ADM_",",.04,"E")'["EMERGENCY" Q 0
 N %,%D,%DT,%H,%M,%Y,DGPMIFN,LOA,LOAS,LOP
 S DGPMIFN=ADM D ^DGPMLOS
 ; set some local variables to be used by calling module
 S LOS=$P(X,U,5) ;   length of stay for admission event
 S PROV=VAIP(13,5) ; DUZ^primary care physician for admission
 S LOC=VAIP(13,4) ;  IEN^ward for admission
 Q 1
 ;
ISINTBL(TABLE) ; Boolean check to see if value is in mapping table
 N I,X,Y,Z
 I $G(TABLE)="" Q -1
 D ISINTBL^VFDRPARL("VFDA","VFDW",TABLE)
 Q +$G(VFDA(1))
 ;
MH(VST) ; does the encounter indicate psych/MH
 ; VST - opt - pointer to VISIT file
 N I,X,Y,Z,RVED,RVSD,VFDA,VFDR,VFDW
 I '$G(VST) Q 0
 ; get all a visit
 S VFDR=$NA(^TMP("PXKENC",$J)) K @VFDR D ENCEVENT^PXKENC(VISIT)
 S I=0 F  S I=$O(@VFDR@(VST,"POV",I)) Q:'I  S X=+^(I,0) D
 .S Y=$$GET1^DIQ(80,X_",",.01) S:Y'="" VFDW(1)=$G(VFDW(1))_Y_U
 .Q
 K @VFDR I $$ISINTBL("CMS TABLE 7.01 MENTAL DISORDERS")>0 Q 1
 ; check for SNOMED codes
 S I=0 F  S I=$O(^VFD(21640.01,"AD",VST,I)) Q:'I  D
 .S X=$P($G(^VFD(21640.01,I,0)),U) S:X'="" VFDW(1)=$G(VFDW(1))_X_U
 .Q
 Q $$ISINTBL("JC TABLE 3-150 MENTAL DISORDERS VALUE SET")=1
 ;
MEDIAN(VFDLIST) ; get median value from a list of numbers
 ; VFDLIST - req - named reference containing the list of numbers where
 ;           @vfdlist@(n)=<total number of instances of n>
 ; Return value n which is the median value
 I $G(VFDLIST)="" Q ""
 I $O(@VFDLIST@(""))="" Q ""
 N A,B,I,J,L,X,Y,Z,N,MID,MIDL,MIDR,STOP,TOT
 ; get total number of instances
 S TOT=0,N="" F  S N=$O(@VFDLIST@(N)) Q:N=""  S TOT=TOT+@VFDLIST@(N)
 ; check if there is only one instance
 S X=$O(@VFDLIST@("")),Y=$O(@VFDLIST@(X)) I Y="" Q X
 ; get left edge for median from the total number
 S MID=TOT\2,(Y,Z,STOP)=0
 S Z=0,N="" F  S N=$O(@VFDLIST@(N)) Q:N=""  D  Q:STOP
 .S Y=@VFDLIST@(N) I (Z+Y)'<MID S STOP=1
 .E  S Z=Z+Y
 .Q
 ; value N [@vfdlist(N)] contains left edge for median
 ; Z+Y = total number of instances up to and including @vfdlist@(N)
 ; does @vfdlist@(N) stradle the median so that N is median?
 I (Z+Y)>MID Q N
 ; is @vfdlist@(N) the last value in the list?
 S X=$O(@VFDLIST@(N)) I X="" Q N
 S MIDL=N,MIDR=X
 ; if total number is odd, then MIDR is median
 I TOT#2 Q MIDR
 ; have even number of instances, so median is (MIDL+MIDR)/2
 ; figure least number of significant decimals
 S L=$L($P(MIDL,".",2)),X=$L($P(MIDR,".",2)) S:X<L L=X
 Q $J(MIDL+MIDR/2,0,L)
