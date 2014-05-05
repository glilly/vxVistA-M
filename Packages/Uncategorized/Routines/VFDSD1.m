VFDSD1 ;DSS/PDW - PATIENT LIST FOR SCHED PROV;15 Jan 2009 10:03
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should on be invoked from the VFDSD routine
 ;
 ; ICR#  Supported Description
 ;-----  -------------------------------------------------
 ; 2055  $$VFIELD^DILFD
 ;10035  Direct global read of .01 field in file 2
 ;10040  Direct global read of .01 field in file 44
 ;10103  $$FMTE^XLFDT
 ;
SCHPATLK(VFDRSLT,VFDINFO) ;RPC VFD SD SCHED PROV PAT LIVDSZDST
 ;sub routine entry to perform work
 ; See SCHPATLK^VFDSD for details on variables
 N G,I,N,R,X,Y,Z,APPT,DFN,EDT,ERR,LOC,PROV,SDT,TMP,VFD
 S G=$NA(^TMP("VFDSCHPAT",$J)) K @G
 S VFDRSLT=G,I="" M Z=VFDINFO
 F  S I=$O(Z(I)) Q:I=""  S Z=Z(I) D  Q:$G(VFD)="TEST"!$D(ERR)
 .S X=$P(Z,U),Y=$P(Z,U,2)
 .; qa data input
 .Q:'$$QA
 .I X="LOC" S VFD(X,Y)=""
 .I "EDT^SDT"[X S @X=Y
 .I X="PRV" S:Y="A" VFD("PRV")="A" I Y'="A" S VFD("PRV",Y)=""
 .Q
 I $D(ERR) S @G@(1)=ERR Q
 S X=$$SDSCHPRV I (X<1)!($G(VFD)="TEST") S @G@(1)=X Q
 ; now have VFD("LOC",loc)=""  VFD("PRV",duz#)=""
 ; additional qa
 I '$D(VFD("LOC")),'$D(VFD("PRV")) S VFD("PRV",DUZ)=""
 I $D(VFD("LOC")),'$D(VFD("PRV")) S VFD("PRV")="A"
 I $G(VFD("PRV"))'="A" S VFD("PRV")=""
 I '$D(VFD("LOC")) S VFD("LOC")="A"
 I '$G(SDT) S SDT=DT
 I '$G(EDT) S EDT=DT
 I EDT?7N S EDT=EDT+.24
 S SDT=SDT-.000001
 S:'($D(VFD("LOC"))#2) VFD("LOC")=""
 S:'($D(VFD("PRV"))#2) VFD("PRV")=""
 S R=$NA(^SC("VFDBYLOC")),(N,PROV)=0
 F  S PROV=$O(@R@(PROV)) Q:'PROV  D
 .I VFD("PRV")'="A",'$D(VFD("PRV",PROV)) Q
 .S LOC=0 F  S LOC=$O(@R@(PROV,LOC)) Q:'LOC  D
 ..I VFD("LOC")'="A",'$D(VFD("LOC",LOC)) Q
 ..I '$D(TMP("LOC",LOC)) S TMP("LOC",LOC)=$P(^SC(LOC,0),U)
 ..S APPT=SDT F  S APPT=$O(@R@(PROV,LOC,APPT)) Q:APPT>EDT!'APPT  D
 ...S Y=$P(APPT,":",1,2)
 ...I '$D(TMP("DT",Y)) S TMP("DT",Y)=$TR($$FMTE^XLFDT(Y),"@"," ")
 ...S Z=0 F  S Z=$O(@R@(PROV,LOC,APPT,Z)) Q:'Z  S DFN=^(Z) D
 ....S TMP("DFN",DFN)=$P(^DPT(DFN,0),U)
 ....S X=DFN_";"_TMP("DFN",DFN)_U_LOC_";"_TMP("LOC",LOC)_U
 ....S X=X_Y_";"_TMP("DT",Y)
 ....S N=N+1,@G@(TMP("DFN",DFN),$P(APPT,":",1,2),N)=X
 ....Q
 ...Q
 ..Q
 .Q
 I '$D(@G) S @G@(1)=$$ERR(7)
 Q
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ERR(A) ;
 I A=1 Q "-1^Invalid input mnemonic received: "_X
 I A=2 Q "-1^Invalid value received for "_X_": "_Y
 I A=3 Q "-1^Location does not exist: "_Y
 I A=4 Q "-1^Provider ien does not exist: "_Y
 I A=5 Q "-1^Invalid start date received: "_Y
 I A=6 Q "-1^Invalid end date received: "_Y
 I A=7 Q "-1^No appointments found for search criteria"
 I A=8 Q "-1^SCHEDULED PROVIDER FIELD not defined in file 44"
 Q 1
 ;
QA() ; qa input
 I "^EDT^LOC^PRV^SDT^TEST^"'[(U_X_U) S ERR=$$ERR(1) Q 0
 I X="TEST" S VFD="TEST" Q 0
 I 'Y Q 1
 I +Y'=Y S ERR=$$ERR(2) Q 0
 I X="LOC",'$D(^SC(Y)) S ERR=$$ERR(3) Q 0
 I X="PRV",Y="A" Q 1
 I X="PRV",'$D(^VA(200,Y)) S ERR=$$ERR(4) Q 0
 I X="SDT",Y'?7N.1".".6N S ERR=$$ERR(5) Q 0
 I X="EDT",Y'?7N.1".".6N S ERR=$$ERR(6) Q 0
 Q 1
 ;
SDSCHPRV() ;RPC: 
 ; check to see in scheduling provider field definition added to 44
 N I,X,Y,Z,DIERR
 S X=$$VFIELD^DILFD(44.003,21600.01)
 Q $S(X>0:1,1:$$ERR(8))
