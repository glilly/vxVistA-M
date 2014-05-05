VFDREGU ;DSS/LM/SMP - Patient Registration Utilities ; 06/04/2013 11:00
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;  DBIA#  Supported References
 ;  -----  --------------------
 ;   2171  $$NNT^XUAF4
 ;   2263  $$GET^XPAR
 ;   2541  $$KSP^XUPARAM
 ;  10103  $$FMDIFF^XLFDT
 ;  10104  $$UP^XLFSTR
 ;
 Q
ISVOE() ;;Is (this environment) VistA Office EHR?
 ;
 N VFDRDINS S VFDRDINS=$$KSP^XUPARAM("INST") ;KSP Default Institution
 Q:'VFDRDINS 0 ;No default institution
 N VFDRINS S VFDRINS=$$NNT^XUAF4(VFDRDINS) ;NAME^NUMBER^TYPE
 Q $P(VFDRINS,U,3)="VOE"
 ;
ENV(VFDRSLT) ;;Type of environment
 ; Returns internal value of field 95 for default INSTITUTION.
 ; If field 95 is null, returns "V"
 ; 
 S VFDRSLT=$$GET1^DIQ(4,+$$KSP^XUPARAM("INST"),95,"I")
 S:VFDRSLT="" VFDRSLT="V"
 Q
 ;
AGE(VFDDOB,VFDATE,FLG) ;;Pediatric-aware age
 ; VFDDOB - req - Date of Birth in FileMan format
 ; VFDATE - opt - Fileman date format to use as end date in age calc
 ;                Default to today
 ;    FLG - opt - Boolean flag indicating that called by RPC
 ; RETURN:
 ;   if extrinsic function, return age in days,weeks,months,years
 ;      e.g., 3d, 6w, 14m, 55
 ;   if RPC call, return age string days^weeks^months^years
 ;                or -1^message
 ;
 N %,%D,%H,%M,%T,%Y,X,W,X,Y,BEG,DAYS,END,MON,RET,WEEKS
 S FLG=$G(FLG)
 I '$G(VFDDOB) Q $S('FLG:"",1:"-1^No date of birth received")
 S VFDATE=$G(VFDATE) S:'VFDATE VFDATE=DT
 S DAYS=$$GET^XPAR("ALL","VFDR AGE IN DAYS") S:'DAYS DAYS=30
 S WEEKS=$$GET^XPAR("ALL","VFDR AGE IN WEEKS") S:'WEEKS WEEKS=26
 S MON=$$GET^XPAR("ALL","VFDR AGE IN MONTHS") S:'MON MON=24
 ;
 ; To do: Replace above with VFDR AGE multi-instance parameter and use ^VFDCXPR
 ; N VFDLIST D GET^VFDCXPR(.VFDLST,"~VFDR AGE")
 ; 
 ; INSTANCE DOMAIN: 1:DAYS;2:WEEKS;3:MONTHS
 ; 
 ; Example return
 ; VFDLST(1)="1^DAYS^14^14"
 ; VFDLST(2)="2^WEEKS^12^12"
 ; VFDLST(3)="3^MONTHS^12^12"
 ; 
 S Y=$$FMDIFF^XLFDT(VFDATE,VFDDOB) ; age in days
 S:FLG RET=Y I 'FLG,Y'>DAYS Q Y_"d"
 S X=Y\7 S:FLG RET=RET_U_X I 'FLG,X'>WEEKS Q X_"w"
 ;parse dates and reset y,m,d so that end date always has larger values
 S END(1)=$E(VFDATE,1,3),END(2)=$E(VFDATE,4,5),END(3)=$E(VFDATE,6,7)
 S BEG(1)=$E(VFDDOB,1,3),BEG(2)=$E(VFDDOB,4,5),BEG(3)=$E(VFDDOB,6,7)
 I END(2)<BEG(2) S END(1)=END(1)-1,END(2)=END(2)+12
 I END(3)<BEG(3) S END(2)=END(2)-1,END(3)=END(3)+30
 S X=END(1)-BEG(1)*12+END(2)-BEG(2)
 S:FLG RET=RET_U_X I 'FLG,X'>MON Q X_"m"
 ;S X=END(1)-BEG(1)
 S X=X\12
 Q:'FLG X
 Q RET_U_X
 ;
AGERPC(VFDRET,DFN,VFDFLG) ; RPC: VFD DG PAT AGE
 ;    DFN - req - pointer to the patient file
 ; VFDFLG - opt - set of codes indicating single age value to return
 ;                D:days, W:weeks, M:months, Y:years
 ;                default to <null>
 ; RETURN:
 ;   Age string - days^weeks^months^years
 ;   If valid flag, return that single age only
 ;      since the RPC passed in the flag, it knows type of age
 ;   if problems, return -1^message
 ;
 N X,Y,DOB,DOD
 I $G(DFN)<1 S VFDRET="-1^No patient received" Q
 S VFDFLG=$E($G(VFDFLG)) S:VFDFLG?.E1L.E VFDFLG=$$UP^XLFSTR(VFDFLG)
 S X=$G(^DPT(DFN,0)),DOB=$P(X,U,3),DOD=+$G(^(.35))
 I 'DOB S VFDRET="-1^Patient has no date of birth"
 S X=$$AGE(DOB,DOD,1)
 I VFDFLG=""!("DWMY"'[VFDFLG) S VFDRET=X Q
 S Y=VFDFLG
 S VFDRET=$S(Y="D":$P(X,U),Y="W":$P(X,U,2),Y="M":$P(X,U,3),1:$P(X,U,4))
 Q
 ;
DPTAGE() ;;[Private] called from File 2 Field 21601 [Computed]
 ;Leave Naked at ^DPT(DFN,0)
 N DOB,DATE,VFD,VFD0 S DATE=$P($G(^(.35)),U),DOB=$P($G(^(0)),U,3)
 S VFD0=D0
 I 'DOB Q X
 S VFD=$$AGE(DOB,DATE) I $E(VFD,$L(VFD))?1N S VFD=$$GET1^DIQ(2,VFD0,.033)
 S D0=VFD0 I $D(^DPT(D0,0))
 Q VFD
