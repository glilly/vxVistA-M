VFDI0006 ;DSS/SGM - ENV/PRE/POST VXVISTA 2013.0 ; 6/11/2013 18:22
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**6**;16 Aug 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This is the entry point for the environmental check for vxVistA
 ; 2013.0 and the corresponding GUIs for vxCPRS, vxVitals, vxBCMA
 ;   VFDI0005A - executable code for vxVistA and vxVistA Updates
 ;   VFDI0005B - executable code for vxCPRS
 ;   VFDI0005C - executable code for vxBCMA
 ;   VFDI0005D - executable code for vxVitals
 ;
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  --------------------------------------------
 ;
 ;
ENV ; environmental check for vxVistA 2013.0
 Q
 ;
PRE ; pre-install for vxVistA 2013.0
 K XUMF,VFDIDUZ S XUMF=1 I $G(DUZ(0))'="@" M VFDIDUZ=DUZ S DUZ(0)="@"
 D PRE1
 K XUMF I $D(VFDIDUZ) K DUZ M DUZ=VFDIDUZ K VFDIDUZ
 Q
 ;
PREBCMA ; pre-install for vxBCMA 2013.0
 Q
 ;
PRECPRS ; pre-install for vxCPRS 2013.0
 Q
 ;
PREGMV ; pre-install for vxVitals 2013.0
 Q
 ;
POST ; post-install for vxVistA 2013.0
 Q
 ;
POSTBCMA ; post-install for vxBCMA 2013.0
 Q
 ;
POSTCPRS ; post-install for vxCPRS 2013.0
 Q
 ;
POSTGMV ; post-install for vxVitals 2013.0
 Q
 ;
 ;=====================================================================
 ;
PRE1 ; Edit TIU DOCUMENT DEFINITION entry CRITICAL LABS(LAST 24 HOURS)
 N VFDIEN,VFDERR,VFDFDA
 S VFDIEN=$$FIND1^DIC(8925.1,,"OX","CRITICAL LABS(LAST 24 HOURS)",,,"VFDERR")
 I 'VFDIEN!($D(VFDERR)) Q
 S VFDFDA(8925.1,VFDIEN_",",.01)="CRITICAL LABS (LAST 24 HOURS)"
 D FILE^DIE(,"VFDFDA","VFDERR")
 Q
 ;
 ;=====================================================================
 ;
POST1 ;
 Q
 ;
 ;---------------------------------------------------------------------
DATA(TAG,NOP) ; Process $T() lines generically
 N I,J,X,Y,Z
 S Z=$P($T(@TAG),";",3,999) K VFDATA Q:Z=""
 S J=0 I $G(NOP) S VFDATA(1)=Z
 E  F I=1:1:$L(Z,U) S X=$P(Z,U,I) S:$L(X) J=J+1,VFDATA(J)=X
 Q $D(VFDATA)
