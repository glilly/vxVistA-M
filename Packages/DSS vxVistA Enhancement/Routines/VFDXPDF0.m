VFDXPDF0 ;DSS/SGM - COMMON MODULES FOR VFDXPDF* ;
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be accessed via ^VFDXPD
 ;
ERR(N,VFDXX,SP) ;
 ;;Problems Encountered Retrieving HFS Files
 ;;Failed to Retrieve File(s)
 ;;Not a KIDS HFS Patch Description File
 ;;Not a KIDS HFS Install File
 ;;Problems Encountered Filing Data To File 21692
 N R,X,Y,Z,VFDR
 I $G(@VFDERR@(N))="" S @VFDERR@(N)=$P($T(ERR+N),";",3)
 D RPTSET($NA(@VFDERR@(N)),.VFDXX,$G(SP))
 Q
 ;
FLIST ;;Get All HFS Kids File From Directory [.DAT, .KID, .TXT]
 ; initializes VCNT,VTOT
 N I,X,Y,Z,VFDXERR
 D XINIT(,1)
 K VFDLIST D FLIST^VFDXPD0(.VFDLIST,PATH,0,.VFDXERR)
 I $D(VFDXERR) D ERR(1,.VFDXERR,1) K VFDLIST Q
 ; vfdlist(filename_root,filename_extension)=actual FN^uppercased FN
 S (X,VCNT,VTOT)=0
 F  S X=$O(VFDLIST(X)) Q:X=""  S VTOT=1+VTOT F Z="TXT","KID" D
 .S Y=$G(VFDLIST(X,Z)) S:Y'="" $P(VFDLIST(X,Z),U,2)=$$UP^VFDXPD0(Y)
 .Q
 Q
 ;
GLBNAME ; initial named references
 D KILL^VFDXPD
 S VFDDATA=$NA(^TMP("VFDXPD",$J,"DATA"))
 S VFDERR=$NA(^TMP("VFDXPD",$J,"ERR"))
 S VFDFILE=$NA(^TMP("VFDXPD",$J,"FILE"))
 S VFDCNVT=$NA(^TMP("VFDXPD",$J,"CNVT"))
 ;S VRPT=$NA(^TMP($J,"RPT","DATA"))
 ;S VCNVT=$NA(^TMP($J,"RPT","CNVT"))
 Q
 ;
RPTSET(VFDR,VFDXX,SP) ; set report nodes where last subscript is numeric
 ;     VFDR - req - named array (@VFDR@(n))
 ; [.]VFDXX - req - value to be added to @VFDR@(n)
 ;       SP - opt - Boolean, if true pad value with 3 <spaces>
 N I,N,Y
 Q:$D(VFDXX)=0  S N=+$G(@VFDR@(0)),SP=$S($G(SP):"   ",1:"")
 I $G(VFDXX)'="" S N=N+1,@VFDR@(N)=SP_VFDXX
 I $D(VFDXX)>9 D
 .S I=0 F  S I=$O(VFDXX(I)) Q:I=""  S N=N+1,@VFDR@(N)=SP_VFDXX(I)
 .Q
 S @VFDR@(0)=N
 Q
 ;
XDSP(T,NL,INC) ;
 ;   T - opt - text to be written
 ;  NL - opt - Boolean, write to new line (default to 0)
 ; INC - opt - 0:do not increment VCNT
 ;             1:increment VCNT (default if not passed or null)
 ;             2:increment VCNT only
 S T=$G(T),NL=$G(NL),INC=$G(INC) S:INC="" INC=1
 S:INC VCNT=1+VCNT I INC=2 S T=""
 N TAB S TAB=0 I T'="",'NL,$X,$X<40 S TAB=40
 D UPD^VFDXPD0(T,VCNT,VTOT,TAB)
 Q
 ;
XINIT(X,N) ;
 ;;Get All HFS Kids Files From Directory [.DAT, .KID, .TXT]
 ;;Converting HFS *.DAT Files To *.TXT and *.KID Files
 ;;Process *.TXT HFS Files
 ;;Process *.KID HFS Files
 ;;Filing Data [Get IENS / Create Stub Records]
 ;;Filing Data [Convert IN to Pointers]
 ;;Filing Data [Convert Req Builds to Pointers]
 ;;Filing Data [File Remaining Data to File 21692]
 S VCNT=0,X=$G(X) I +$G(N) S N=$P($T(XINIT+N),";",3) S:N'="" X=N
 D INIT^VFDXPD0(X)
 Q
