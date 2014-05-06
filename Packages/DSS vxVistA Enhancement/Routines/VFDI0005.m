VFDI0005 ;DSS/SGM - ENV/PRE/POST VXVISTA 2013.0 ; 6/11/2013 18:22
V ;;2013.0;;;;Build 6
 ;
 ; This is the entry point for the environmental check for vxVistA
 ; 2013.0 and the corresponding GUIs for vxCPRS, vxVitals, vxBCMA
 ;   VFDI0005A - executable code for vxVistA and vxVistA Updates
 ;   VFDI0005B - executable code for vxCPRS
 ;   VFDI0005C - executable code for vxBCMA"RTN","VFDI0005",9,0)
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
 D PRE1,PRE2 ; 6/11/2013
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
 D POST1,POST2 ; 11/07/2013
 D POST^VFDIPSS9 ; 10/7/2013 vxPharmacy
 K XUMF I $D(VFDIDUZ) K DUZ M DUZ=VFDIDUZ K VFDIDUZ
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
PR1 ;;101.24^101.41^120.51^142.1
 ;
PRE1 ; ADD KIDS EXPORT FIELD (#21609.6) TO TOP LEVEL OF FILE
 N I,J,X,Y,Z,VFDATA
 I $$DATA("PR1") S X=$$KEXPORT^VFDI000R(,.VFDATA)
 ; if messaging desired, do it here
 Q
 ;
PRE2 ; clean up any FM Identifiers
 N I,J,X,Y,Z,VFDATA
 ; 6/11/2013 - file 21611 identifiers moved to write identifiers F I=.02,.03 K ^DD(21611,0,"ID",I)
 ;
 Q
 ;
 ;=====================================================================
PO1 ;;N AG S AG=$G(DUZ("AG")) I '$P(^(0),U,11),$S($D(APCDOVRR)!$D(VSIT):1,AG?1"I".01"HS":1,$G(^%ZOSF("ZVX"))["VX":1,1:AG?1"V"0.1"A")
 ;
POST1 ; update the vxVistA Version Parameter
 N I,J,X,Y,Z,VER
 I $G(^%ZOSF("ZVX"))="" S ^%ZOSF("ZVX")="VXOS"
 S VER=$P($T(V),";",3) I VER>0 D CHG^VFDCXPR(,"SYS~VFD VXVISTA VERSION~1~"_VER)
 Q
 ;
POST2 ; fixed File 9000010 screen lookup logic
 N I,J,X,Y,Z,VFDATA
 Q:'$$DATA("PO1",1)
 S Z=$G(^DD(9000010,0,"SCR")) I Z'=VFDATA(1) S ^("SCR")=VFDATA(1)
 Q
 ;
 ;---------------------------------------------------------------------
DATA(TAG,NOP) ; Process $T() lines generically
 N I,J,X,Y,Z
 S Z=$P($T(@TAG),";",3,999) K VFDATA Q:Z=""
 S J=0 I $G(NOP) S VFDATA(1)=Z
 E  F I=1:1:$L(Z,U) S X=$P(Z,U,I) S:$L(X) J=J+1,VFDATA(J)=X
 Q $D(VFDATA)
