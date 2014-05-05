VFDRPARB ;DSS/RAC - ARRA PATIENT MOVEMENT LIST ; 05/31/2011 00:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This API returns data regarding the movement file
 ;Input start and end dates of movements.
 ;
 ; Input:
 ;    Start Date in FM format
 ;    End Date in FM format
 ;
 ; Output:
 ;  An array containing the following:
 ;
 ;  Patient Name
 ;  Patient DFN
 ;  Admission Date - FM format
 ;  Discharge Date - FM format
 ;  Length of Stay - Calculated
 ;  Discharge Location - Text
 ;  Date of Death - FM Format
 ;  Age
 ;  Admit Diagnosis - ICD9 code from ^DGPM(DGPMIEN,21600)
 ;  Admission_Type
 ;  Admission_Location
 ;  Discharge Type
 ;
 Q
EN ; Interactive entry to prompt for date range
 N END,START,VFD
 Q:$$DATE^VFDCFM(.START,.END,1)<1
 D GETPT(.VFD,START,END)
 Q
 ;
GETPT(VFDRET,START,END,VFDFILN,VFDPATH) ;
 ;;PT_IEN^PT_NAME^ADMT_DT^DSCH_DT^LENGTH_OF_STAY^DSCH_LOC^DT_DEATH^
 ;;PT_AGE^ADMIT_DX^ADMIT_TYPE^ADMIT_LOC^DSCH_TYPE
 ; get all inpatients for a date range
 ;   START - req - start date for when patient was an inpatient
 ;     END - opt -   end date for when patient was an inpatient
 ; VFDFILN - opt - name of .CSV HFS file to be generated
 ; VFDPATH - opt - path or directory where to place the HFS file
 ;  VFDRET - return 1^<filename> created OR -1^error_msg
 ;
 N X,Y,Z,DFN,NT,VADM,VA,VAIP,VFDDTS,VFDMOV,VFDR,VFDX,VFDY
 S X=$$DATE^VFDRPARU($G(START),$G(END)) I +X=1 S VFDRET=X Q
 S START=+X,END=$P(X,U,2)
 S:$G(VFDFILN)="" VFDFILN="PT_ADMT.CSV"
 S:$G(VFDPATH)="" VFDPATH=$$DEFDIR^%ZISH
 S VFDX=$NA(^TMP("VFDRPARB",$J)) K @VFDX
 S VFDR=$NA(^TMP("VFDDGPMU",$J)) K @VFDR
 ; inpat^vfddgpmu will validate dates
 ;Get all patient movements with date range
 D INPAT^VFDDGPMU(.VFDMOV,START,END)
 S X=@VFDMOV@(0) I +X=-1 S VFDRET=X Q
 S DFN=0,CNT=1,@VFDX@(1)=$P($T(GETPT+1),";",3)_$P($T(GETPT+2),";",3)
 I X F  S DFN=$O(@VFDR@(DFN)) Q:'DFN  S VFDNT=0 D
 .F  S VFDNT=$O(@VFDR@(DFN,VFDNT)) Q:'VFDNT  S VFDY=^(VFDNT) D
 ..N ADT,ADX,AGE,ALOC,ATYPE,DDT,DGPMIFN,DLOC,DOD,DTYPE,LOS,NAME,VA,VADM
 ..N VAIP
 ..S VAIP("E")=VFDNT D DEM^VADPT,IN5^VADPT
 ..S NAME=VADM(1) ;                              patient name
 ..S DOD=$P(VADM(6),U) ;                         date of death
 ..S AGE=VADM(4) ;                               age
 ..S DGPMIFN=VAIP(13) D ^DGPMLOS S LOS=$P(X,U) ; LOS
 ..S ADT=$P(VAIP(13,1),U) ;                      admit dt
 ..S ATYPE=$P(VAIP(13,2),U,2) ;                  admit type
 ..S ALOC=$P(VAIP(13,4),U,2) ;                   admit ward
 ..S ADX=$G(^DGPM(VFDNT,21600)) ;                admit diagnosis
 ..S DDT=$P(VAIP(17,1),U) ;                      discharge dt
 ..S DLOC=$P(VAIP(17,4),U,2) ;                   discharge ward
 ..S DTYPE=$$FACMOVE(VAIP(17)) ;                 discharge fac movement
 ..S X=DFN_U_NAME_U_ADT_U_DDT_U_LOS_U_DLOC_U_DOD_U_AGE_U_ADX_U_ATYPE_U_ALOC_U_DTYPE
 ..S CNT=1+CNT,@VFDX@(CNT)=X
 ..Q
 .Q
 S VFDDTS(0)=3,VFDDTS(1)=4,VFDDTS(2)=7
 D CSVOUT^VFDRPARI(VFDFILN,VFDX,U,U,.VFDDTS,VFDPATH)
 K @VFDR,@VFDX D KVAR^VADPT,KVA^VADPT
 S VFDRET="1^"_VFDFILN
 Q
 ;
FACMOVE(MOVE) ; for any movement, get the facility movement (.04 field)
 I +$G(MOVE)<1 Q ""
 N X S X=$P($G(^DGPM(MOVE,0)),U,4)
 Q $S('X:"",1:$P($G(^DG(405.1,X,0)),U))
