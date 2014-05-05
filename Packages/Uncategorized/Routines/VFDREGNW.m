VFDREGNW ;DSS/LM - vxVistA ScreenMan Registration Hooks ;January 24, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
ASKID ;From ASKID^DPTLK2
 ; Skip or stuff selected patient identifiers
 ; 
 I $G(DPTID)=.09 D  Q  ;Skip SSN
 .I DPT("DR")=DPTID S DPT("DR")="" Q
 .S DPT("DR")=$P(DPT("DR"),";"_DPTID)
 .Q
 I $G(DPTID)=391 S DPT("DR")=DPT("DR")_"///13" ;NON-VETERAN (OTHER)
 I $G(DPTID)=1901!($G(DPTID)=.301) S DPT("DR")=DPT("DR")_"///N"
 Q
