VFDALTID ;DSS/LM - Additional utilities supporting Alternate ID ;November 30, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ; 
 ; Subroutines and functions in this routine augment alternate ID editing
 ; and are not remote procedure calls.
 ; 
 Q
DSP(VFDFILE,VFDIEN,VFDNOHDR) ;[Public] Display ALTERNATE ID values
 ; VFDFILE=[Optional] File number 2 or 200.  Default is PATIENT file.
 ; VFDIEN=[Required] Internal Entry Number to display
 ; VFDNOHDR=[Optional] Flag '1' indicating no header. Default is include.
 ; 
 ; 
 I $G(VFDIEN)>0 S VFDFILE=$G(VFDFILE,2) I VFDFILE=2!(VFDFILE=200) D @VFDFILE
 Q
2 ;[Private] Continuation of DSP for PATIENT file ALTERNATE ID
 W:'$G(VFDNOHDR) !!,"TYPE ALTERNATE ID",?36,"LOCATION",?67,"EXPIRES  DFLT",!
 N VFDA,VFDZ S VFDA=0 F  S VFDA=$O(^DPT(+VFDIEN,21600,VFDA)) Q:'VFDA  D
 .S VFDZ=$G(^(VFDA,0)) Q:'$L(VFDZ)
 .W !,$E($P(VFDZ,U,5),1,3) ;TYPE
 .W ?5,$P(VFDZ,U,2) ;ALTERNATE ID
 .W:+VFDZ ?36,$P($G(^DIC(4,+VFDZ,0)),U) ;LOCATION
 .W:$P(VFDZ,U,3) ?67,$$FMTE^XLFDT($P(VFDZ,U,3),"2D")
 .W:$P(VFDZ,U,4) ?77,"X"
 .Q
 W !
 Q
200 ;[Private] Continuation of DSP for NEW PERSON file ALTERNATE ID
 Q
YN() ;[Public] Return '1' (true) if and only if Enter/Edit Alternate ID = YES
 ;
 N DIR,X,Y S DIR(0)="Y",DIR("A")="Enter/Edit ALTERNATE ID"
 D ^DIR Q:$D(DIRUT) 0
 Q +Y
