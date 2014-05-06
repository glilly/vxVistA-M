VFDCDPT1 ;DSS/SGM - VARIOUS RPCS TO THE VADPT API ; 09/21/2012 14:48
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;As of 3/1/2006 this routine should not be directly invoked.
 ;See routine VFDCDPT
 ;
DEM(VFDRET,DFN,SSN,PERM,VFDCONF,VFDFLG) ; get all patient demographics
 ;You must pass either DFN or SSN
 ;Input    Description
 ;-------  --------------------------------------------------
 ;PERM     if 1, then return permanent address
 ;         else return whatever ADD^VADPT returns {default}
 ;VFDCONF  p1^p2 - flag to return confidential address
 ;         p1 - req - confidential address category
 ;          p1 is a string of one or more numerics, e.g, 134
 ;             1 = Eligibility/Enrollment
 ;             2 = Appointment/Scheduling
 ;             3 = Co-payments/Veterans Billing
 ;             4 = Medical Records
 ;             5 = All Others
 ;          p2 - opt - FM date to determine if confidential date is
 ;               effective.  Default value is TODAY
 ;VFDFLG   if DISFLG=1, return internal^external values if appropriate
 ;         default is 0, to return single external value
 ;         Example, for a STATE field,
 ;           if 0 then return abbrev (or name if abbrev is null)
 ;           if 1 return IFN-file-5^name^abbrev
 ;    In definition of VFDRET(), if VFDFLG=1 then return items in [...]
 ; On error return -1^error message
 ;Else return:
 ; VFDCDAT()  Description
 ; ---------  ------------------------------------------
 ;     1      patient name
 ;     2      ssn;dashed ssn;
 ;     3      dob int;ext
 ;     4      age
 ;     5      sex
 ;     6      date of death int;ext
 ;     7      race
 ;     8      religion
 ;     9      marital status
 ;    10      employment status
 ;    11      1st st add
 ;    12      2nd st add
 ;    13      3rd st add
 ;    14      city
 ;    15      state abbr [or ien^state name^state abbr]
 ;    16      zip (9 or 5) [or internal zip^external zip]
 ;    17      county [or multiple ien^county name]
 ;    18      home phone
 ;    19      work phone
 ;    20      LastName^FirstName^Middle^Suffix/Title
 ; ---- VFDRET(21) - VFDRET(28) all refer to confidential address  ----
 ;    21      confidential address category bitmap
 ;[Default value of "00000".  This is a 5 char string of 0s and 1s
 ; where each bit refers to whether or not the particular category
 ; is active or not as of the date in the VFDCONF param.  Only those
 ; categories requested in VFDCONF param will have a bit value of 1]
 ;    22      street address 1
 ;    23      street address 2
 ;    24      street address 3
 ;    25      city
 ;    26      state abbr [or ien^state name^state abbr]
 ;    27      zip (9 or 5) [or internal zip^external zip]
 ;    28      county [or multiple ien^county name]
 ; -------------------------------------------------------------
 ;    29      primary elig ^ other elig ^ other elig ^ ...
 ;    30      1 if patient is a veteran, else 0
 ;    31      code^name of current means test status
 ; -------------------------------------------------------------
 ;            vxVista fields 21601.01 - 21601.04
 ;    32      Age
 ;    33      Time of Birth
 ;    34      Preferred Language [int^ext if vfdflg]
 ;    35      Preliminary cause of death
 ;    36      Preliminary Diagnosis of death [int^ext if vfdflg]
 ;    
 N I,J,X,Y,Z,DIERR,VFD,VFDERM,VFDS,VXD
 I $G(DFN)>0 S X=$$GET(DFN) I +X=-1 S VFDRET(1)=X Q
 I $G(DFN)'>0 D  Q:$D(RET)
 .I $G(SSN)="" S VFDRET(1)=$$ERR(1) Q
 .S X=$$GET(SSN,1) S:X>0 DFN=+X S:X'>0 VFDRET(1)=$$ERR(2)
 .Q
 ;get patient demographics [VADM(n)]
 S VAN=1,VAN(1)=12,VAV="VADM" D ^VADPT0
 ;get address data [VAPA(n)]
 S:$G(PERM)>0 VAPA("P")=""
 S VFDCONF=$G(VFDCONF),VFDFLG=+$G(VFDFLG)
 I VFDCONF'="",$$PATCH^XPDUTL("DG*5.3*489") D
 .S Y="",X=$P(VFDCONF,U) I X'="" F I=1:1:5 S:X[I Y=Y_I
 .Q:Y=""  S X=$P(VFDCONF,U,2) S:X'?7N X=DT
 .S VFDCONF=Y_U_X
 .S VAPA("CD")=X
 .Q
 D ADD^VADPT
 S VAOA("A")=5 D OAD^VADPT ;get other address info VAOA(n) - employer=5
 D OPD^VADPT ;get other patient data [VAPD(n)]
 D ELIG^VADPT ;get elibility info [VAEL(n)]
 D NAMECOM(.VFDERM,$G(VADM(1)))
 S VFDRET(20)=$S(+VFDERM'=-1:VFDERM,1:"")
 S VFDRET(1)=$G(VADM(1))
 S VFDRET(2)=$TR($G(VADM(2)),U,";")
 S X=$P($G(VADM(3)),U)
 S VFDRET(3)=$S(X:X_";"_$$FMTE^XLFDT(X,"5PZ"),1:"")
 S VFDRET(4)=$G(VADM(4))
 S VFDRET(5)=$P($G(VADM(5)),U)
 S X=$P($G(VADM(6)),U)
 S VFDRET(6)=$S(X:X_";"_$$FMTE^XLFDT(X,"5PZ"),1:"")
 S VFDRET(7)=$P($G(VADM(8)),U,2)
 S VFDRET(8)=$P($G(VADM(9)),U,2)
 S VFDRET(9)=$P($G(VADM(10)),U,2)
 S VFDRET(10)=$P($G(VAPD(7)),U,2)
 S VFDRET(11)=$G(VAPA(1))
 S VFDRET(12)=$G(VAPA(2))
 S VFDRET(13)=$G(VAPA(3))
 S VFDRET(14)=$G(VAPA(4))
 S VFDRET(15)=$$STATE($G(VAPA(5)),VFDFLG)
 S X=$G(VAPA(11)),VFDRET(16)=$S(VFDFLG:X,1:$P(X,U,2))
 S X=$G(VAPA(7)),VFDRET(17)=$S(VFDFLG:X,1:$P(X,U,2))
 S VFDRET(18)=$G(VAPA(8))
 S VFDRET(19)=$G(VAOA(8))
 F I=21:1:28 S VFDRET(I)=""
 I VFDCONF'="",+$G(VAPA(12)) D
 .S X="00000",Z=$P(VFDCONF,U)
 .F I=1:1:5 I $P($G(VAPA(22,I)),U,3)="Y",Z[I S $E(X,I)=1
 .Q:X="00000"  S VFDRET(21)=X
 .F I=13,14,15,16 S VFDRET(I+9)=VAPA(I)
 .S VFDRET(26)=$$STATE(VAPA(17),VFDFLG)
 .S X=VAPA(18),VFDRET(27)=$S(VFDFLG:X,1:$P(X,U,2))
 .S X=VAPA(19),VFDRET(28)=$S(VFDFLG:X,1:$P(X,U,2))
 .Q
 S X=$P($G(VAEL(1)),U,2),I=0
 F  S I=$O(VAEL(1,I)) Q:'I  S X=X_U_$P(VAEL(1,I),U,2)
 S VFDRET(29)=X
 S VFDRET(30)=$G(VAEL(4))
 S VFDRET(31)=$G(VAEL(9))
 ;Age, Time Of Birth, Pref Lang, Cause Diagnosis Of Death 
 D VX(.VFDS,DFN) ; 32 - 36
 S J=0,I=31 F  S J=$O(VFDS(J)) Q:'J  S I=I+1,VFDRET(I)=VFDS(J)
 D KVA^VADPT
 Q
 ;
NAMECOM(RET,VNAME) ;  RPC: VFDC XUTIL NAME COMPONENT
 ;return name components for standard VistA name
 ;Return: RET = LastName^FirstName^Middle^Suffix/Title
 ;        on error - return -1^error message
 N X I $G(VNAME)="" S RET=$$ERR(3) Q
 D STDNAME^XLFNAME(.VNAME,"CF") S RET=""
 F X="FAMILY","GIVEN","MIDDLE","SUFFIX" S RET=RET_$G(VNAME(X))_U
 Q
 ;
 ;---------- private subroutines - may be called from VFDCPT ----------
 ;
COUNTY() ; return county name or number
 ; called from various county fields in the PATIENT file.  The PATIENT
 ; file field output transform will have Z0 set to the pointer to the
 ; state file and Y set to the county multiple pointer in that state
 ; entry.
 ;   ST - req - pointer to the state file
 ; CNTY - req - pointer to county multiple in that state file entry
 ;  FLG - opt - Boolean, 1:return county name; 0:return county number
 ;              default to 0
 ; on error or problem, return <null>
 ;
 N X,RET S RET=""
 S ST=$G(ST),CNTY=$G(CNTY),FLG=$G(FLG)
 I ST<1!(CNTY<1) Q RET
 S X=$G(^DIC(5,+ST,1,+CNTY,0)) I X="" Q RET
 ; special exemption for NHDP vxVistA site 109
 I 'FLG,$P($$SITE^VASITE,U,3)=109 S FLG=1
 S:'FLG FLG=3
 Q $P(X,U,FLG)
 ;
ERR(A) ;
 I A=1 S A="No patient DFN or SSN received"
 I A=2 S A="SSN "_SSN_" not found in the Patient file"
 I A=3 S A="No name received"
 I A=4 S A="No lookup value received"
 I A=5 S A="No match found for lookup value: "_PAT
 I A=6 S A="Bad data detected, "_$NA(^DPT(DFN,0))_" does not exist"
 Q "-1^"_A
 ;
GET(X,TYPE) ; validate input value
 ;Return DFN^name^ssn;dashed-ssn  OR  on error return -1^error message
 ;   X - req - lookup value
 ;TYPE - opt - Boolean, default=0 - 1:lookup value is SSN
 ;  0 & (X is 9 digit) - first check for DFN value, then SSN
 N Y,Z,DFN,PAT S PAT=$G(X),TYPE=$G(TYPE)
 I PAT="" Q $$ERR(4)
 I 'TYPE,PAT=+PAT,$D(^DPT(PAT,0)) S DFN=PAT
 I '$D(DFN) D
 .N DIERR,VFDERR S Z=0
 .I PAT?9N.1"P" S Z=$$FIND1^DIC(2,,"QX",PAT,"SSN",,"VFDERR")
 .I '$D(DIERR),Z>0 S DFN=Z Q
 .K DIERR S Z=$$FIND1^DIC(2,,"QMX",PAT,,,"VFDERR")
 .I '$D(DIERR),Z>0 S DFN=Z
 .Q
 I '$D(DFN) Q $$ERR(5)
 S Z=$G(^DPT(DFN,0)) I Z="" Q $$ERR(6)
 S Y=$P(Z,U,9) I Y]"" S Y=Y_";"_$E(Y,1,3)_"-"_$E(Y,4,5)_"-"_$E(Y,6,99)
 Q DFN_U_$P(Z,U)_U_Y
 ;
STATE(X,VFDFLG) ;  return state data
 ;X - req - +X=ien to file 5
 ;    if $P(X,U,2)'="" then it must be the .01 value from file 5
 ;VFDFLG - opt - default=0 - Boolean
 ;         1:return state's ien^name^abbreviation
 ;         0:return state abbreviation, if abbrev="", return state name
 N Z,VFDEN,VFDERR,VFDNM
 S X=$G(X),VFDEN=+X,VFDNM=$P(X,U,2),VFDFLG=+$G(VFDFLG)
 I VFDEN<1 Q ""
 I VFDNM="" S VFDNM=$$GET1^DIQ(5,VFDEN,.01,,,"VFDERR")
 S Z=$$GET1^DIQ(5,VFDEN,1,,,"VFDERR") ; state abbr
 I 'VFDFLG S X=$S(Z'="":Z,1:VFDNM)
 E  S Z=VFDEN_U_VFDNM_U_Z
 Q Z
 ;
VX(VFDDEM,DFN) ; get vxvista specific fields from file 2
 N F,I,J,X,Y,Z,DA,DIC,DIERR,VFDER,VFDSX
 K VFDDEM Q:$G(DFN)<1
 D GETS^DIQ(2,DFN_",","21601:21601.04","IE","VFDSX","VFDER")
 F I=0,.01,.02,.03,.04 S F=21601+I,VFDDEM(F)=""
 Q:$D(DIERR)  S Z=$NA(VFDSX(2,DFN_","))
 ; age,time of birth,language,cause of death,death diagnosis
 F I=0,.01,.02,.03,.04 S F=21601+I D
 . S X=@Z@(F,"E")
 . I VFDFLG,"^.02^.04^"[(U_I_U) S X=@Z@(F,"I")_U_X
 . S:X=U X="" S VFDDEM(F)=X
 . Q
 Q
