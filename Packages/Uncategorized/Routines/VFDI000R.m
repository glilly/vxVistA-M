VFDI000R ;DSS/LM/SGM - COMMON KIDS SUPPORT UTILITIES ; 6/7/2013 10:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; this routine first introduced in VFD VXVISTA UPDATE 2011.1.1 Tnn
 ; this routine is only invoked via VFDI0000
 ; ICR#  Supported Description
 ;-----  --------------------------------------------------------------
 ;       $$OREF^DILF
 ;       All nodes in ^%ZOSF may be referenced
 Q
 ;
 ;>>>>>>>>>>>>>>>>>>>>>>>>>> Routine Utilites <<<<<<<<<<<<<<<<<<<<<<<<<
 ;
COPYRTN(VFDRFR,VFDRTO) ; From COPYRTN^VFDI0000
 ; VFDRFR=[Required] 'From' routine name
 ; VFDRTO=[Required] 'To' routine name
 ;
 N X,Y,Z,VFD
 S X=$G(VFDRFR),VFD=$$GLBREF
 I $S('$$TEST(X):1,1:$G(VFDRTO)="") Q 0
 D LOADRTN(X,VFD) Q:'$D(@VFD) 0
 D SAVERTN(VFDRTO,VFD)
 Q 1
 ;
LOADRTN(VFDRNAM,VFDARRY) ; From LOADRTN^VFDI0000
 ; VFDRNAM - Req - Load-from routine name
 ; VFDARRY - Opt - $NAME of target global array
 ;                 Default to ^TMP("VFDI0000",$J)
 ;
 N X,DIF,XCNP,VFD
 S X=$G(VFDRNAM),VFD=$$GLBREF($G(VFDARRY)) K @VFD
 Q:'$$TEST(X) 0
 S XCNP=0,DIF=$$OREF(VFD) X ^%ZOSF("LOAD")
 Q 1
 ;
SAVERTN(VFDRNAM,VFDARRY) ; From SAVERTN^VFDI0000
 ; VFDRNAM - Req - Save-to routine name
 ; VFDARRY - Req - $NAME of source global array (global required)
 ;                 Default to ^TMP("VFDI0000",$J)
 ;
 N %,DIE,X,XCM,XCN,VFD
 S VFD=$$GLBREF($G(VFDARRY))
 I $S($G(VFDRNAM)="":1,$E(VFD)'=U:1,1:'$D(@VFD)) Q 0
 S X=VFDRNAM,XCN=0,DIE=$$OREF^DILF(VFD) X ^%ZOSF("SAVE")
 Q 1
 ;
 ;>>>>>>>>>>>>>>>>>>>>>>>>>> Global Utilites <<<<<<<<<<<<<<<<<<<<<<<<<<
 ;
KEXPORT(FILE,VLIST) ;
 ; Create field ^DD(file#,21609.6) for top-level DD node
 ; INPUT PARAMETERS:
 ;   FILE - opt - DD#
 ; .VLIST - opt - list of DDs to have field added
 ;                vlist(dd#) = ""  or
 ;                vlist(n) = dd1^dd2^dd3^dd4^dd5^dd6 for n=1,2,3,...
 ; RETURN:
 ; Extrinsic function returns total number of DDs which had the 21906.9
 ;   field created
 ; Input parameter .VLIST killed and reset to:
 ;   VLIST(dd#) = 1, 0, -1, -2  where
 ;                 1 = ^dd(dd#,21906.9) created
 ;                 0 = ^dd(dd#,21906.9) already exists
 ;                -2 = ^dd(dd#,0) does not exist
 ;                -1 = ^dic(dd#,0) does not exist [not top-level file]      
KE ;
 ;;21609.6,0)="KIDS EXPORT^S^1:YES;0:NO;^21609.6;1^Q"
 ;;21609.6,21,0)="^^2^2^3111026^"
 ;;21609.6,21,1,0)="Answer YES if you wish to be able to export specific entries in this file"
 ;;21609.6,21,2,0)="using the KIDS Transport option.  Use this field in the screening logic."
 ;;21609.6,"DT")=DT
 ;;"GL",21609.6,1,21609.6)=""
 ;;"B","KIDS EXPORT",21609.6)=""
 ;;
 N I,J,X,Y,Z,DDFLD,TOT,VFDD
 S TOT=0 I $G(FILE)>0 S VFDD(+FILE)=""
 S I="" F  S I=$O(VLIST(I)) Q:I=""  S X=VLIST(I) D
 . I X="" S:I>0 VFDD(+I)="" Q
 . F J=1:1:$L(X,U) S Y=$P(X,U,J) I Y>0 S VFDD(+Y)=""
 . Q
 ;
 F I=1:1:7 S X=$P($T(KE+I),";",3,99) S @("DDFLD("_X)
 ;
 S I=0 F  S I=$O(VFDD(I)) Q:'I  D
 . I $D(^DD(I,21609.6)) S VFDD(I)=0 Q
 . I '$D(^DD(I,0)) S VFDD(I)=-2 Q
 . I '$D(^DIC(I,0)) S VFDD(I)=-1 Q
 . M ^DD(I)=DDFLD S TOT=TOT+1,VFDD(I)=1
 . Q
 ;
 K VLIST M VLIST=VFDD
 Q TOT
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
GLBREF(X) Q $S($G(X)'="":X,1:$NA(^TMP("VFDI0000",$J)))
OREF(X) Q $$OREF^DILF(X)
TEST(X) Q:$G(X)="" 0 X ^%ZOSF("TEST") Q $T
