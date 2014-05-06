VFDPT ;DSS/LM - Patient file support
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
ONEID(VFDRSLT,VFDFN) ;Remote Procedure - VFD PT ONE ID
 ; VFDFN=Patient IEN
 S VFDRSLT=$$ID(.VFDFN)
 Q
ID(DFN) ;[Private] - Patient ID
 ; DFN=Patient IEN
 ; 
 ; See also ID^VFDWDPT1
 ;
 ; From specification -
 ; 
 ;                  Computed:
 ;                          If default Alternate ID exists, then this
 ;                          Else if 1 & only 1 Alt ID exists, then this
 ;                          Else if more than 1 Alt ID exists, then null
 ;                          Else if SSN (.09) exists, then SSN
 ;
 Q:'($G(DFN)>0) "-1^Missing or invalid DFN"
 N I,J,VFDID
 S J=$O(^DPT(DFN,21600,"AX",1,0))
 I J S VFDID=$P($G(^DPT(DFN,21600,J,0)),U,2) ;DEFAULT Alternate ID
 ; Next is Exactly one Alternate ID -
 E  I $P($G(^DPT(DFN,21600,0)),U,4)=1 S J=$P(^(0),U,3),VFDID=$P($G(^(J,0)),U,2)
 E  I $P($G(^DPT(DFN,21600,0)),U,4)>1 S VFDID="" ;More than one Alternate ID
 E  S VFDID=$P($G(^DPT(DFN,0)),U,9) ;SSN
 Q $S($L(VFDID):VFDID,1:"-1^ID not found")
 ;
